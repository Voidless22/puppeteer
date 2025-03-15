local mq = require('mq')
local imgui = require('ImGui')
local data = require('data')
local utils = require('utils')

local spellDash = {}

--[[
Flow:
Get All the Spawned Bots and their Spell Tables
Load the saved buttons,
 Gray out/disable any buttons that are assigned and the bot connected isn't Spawned

]]

local function setupSpellCategories()
    local categories = {}

    for _, botSpells in ipairs(data.GetSpells()) do
        for _, spellID in ipairs(botSpells.spellIDs) do
            local spellInfo = utils.GetSpellInfo(botSpells.Name, spellID)

            -- Ensure category and subcategory entries exist
            categories[spellInfo.Category] = categories[spellInfo.Category] or {}
            categories[spellInfo.Category][spellInfo.SpellSubcategory] =
                categories[spellInfo.Category][spellInfo.SpellSubcategory] or {}

            -- Add spell to the correct subcategory
            table.insert(categories[spellInfo.Category][spellInfo.SpellSubcategory], spellInfo)
        end
    end

    return categories
end
local function sortedKeys(tbl)
    local keys = {}
    for k in pairs(tbl) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return keys
end

local function extractSpellName(buttonLabel)
    return buttonLabel:match("^(.-) %(") or buttonLabel
end
local function extractBotName(buttonLabel)
    return buttonLabel:match("%((.-)%)") or ""  -- Matches everything inside the parentheses
end
local function DrawButtonGrid()
    local drawlist = ImGui.GetWindowDrawList()

    local windowWidth = ImGui.GetWindowWidth()
    local windowHeight = ImGui.GetWindowHeight()
    local spellDashBtns = data.GetSpellDashButtons()
    local buttonSize = 50 -- Fixed button size
    local padding = 5     -- Padding between buttons

    -- Calculate number of columns and rows that fit in the window
    local columns = math.floor(windowWidth / (buttonSize + padding))
    local rows = math.floor(windowHeight / (buttonSize + padding))

    if columns < 1 then columns = 1 end
    if rows < 1 then rows = 1 end

    -- Draw the grid of buttons
    for i = 1, columns * rows do
        local buttonLabel = spellDashBtns[i] and spellDashBtns[i].Name or "Button " .. i
        local prevCursorPos = ImGui.GetCursorPos()
        local prevScreenCursorPos = ImGui.GetCursorScreenPosVec()
        if ImGui.Button(buttonLabel, buttonSize, buttonSize) then
            local botName = extractBotName(buttonLabel)
            local spellName = extractSpellName(buttonLabel)
            if mq.TLO.Spawn(botName)() then

                mq.cmdf('/say ^cast spellid %i byname %s', mq.TLO.Spell(spellName).ID(), botName)

            end
            print(buttonLabel .. " clicked!")
        end


        if spellDashBtns[i] then
            local spellName = extractSpellName(buttonLabel) -- Get the spell name from button label
            local botName = extractBotName(buttonLabel)     -- Get the bot name from button label
            if not mq.TLO.Spawn(botName)() then
                local postScreenCursorPos = ImGui.GetCursorScreenPosVec()
                ImGui.SetCursorScreenPos(prevScreenCursorPos)
                local x = prevScreenCursorPos.x + buttonSize
                local y = prevScreenCursorPos.y + buttonSize
                local color = ImGui.GetColorU32(1, 0, 0, 0.25)
                drawlist:AddRectFilled(prevScreenCursorPos, ImVec2(x, y), color)
                ImGui.SetCursorScreenPos(postScreenCursorPos)
            end
            -- Only show tooltip if there's a spell assigned
            if ImGui.IsItemHovered() then
                ImGui.SetTooltip("Spell: " .. spellName .. "\nBot: " .. botName)
            end
        end
        -- Context menu to assign spells
        if ImGui.BeginPopupContextItem() then
            local categories = setupSpellCategories()
            for _, category in ipairs(sortedKeys(categories)) do
                if ImGui.BeginMenu(category) then
                    for _, subcategory in ipairs(sortedKeys(categories[category])) do
                        if ImGui.BeginMenu(subcategory) then
                            for _, spell in ipairs(categories[category][subcategory]) do
                                if ImGui.MenuItem(spell.Name) then
                                    -- Assign selected spell to the button
                                    spellDashBtns[i] = spell
                                    
                                    data.SavePlayerSpellDash(spellDashBtns)

                                    print("Assigned " .. spell.Name .. " to Button " .. i)
                                end
                            end
                            ImGui.EndMenu()
                        end
                    end
                    ImGui.EndMenu()
                end
            end

            ImGui.EndPopup()
        end

        -- Move to the next row if needed
        if i % columns ~= 0 then
            ImGui.SameLine()
        end
    end
end





function spellDash.DrawSpellDash(gui)
    ImGui.SetWindowSize(256, 120, ImGuiCond.Once)
    DrawButtonGrid()
end

return spellDash
