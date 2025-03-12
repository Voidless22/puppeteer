local mq                    = require('mq')
local imgui                 = require('ImGui')
local utils                 = require('utils')
local data                  = require('data')
local events                = require('events')
local buttonState           = require('buttonState')
local selectGroupSubscreen  = {}

local FLT_MIN, FLT_MAX      = mq.NumericLimits_Float()

local selectGroupComboWidth = 350
local buttonPadding         = 4
local buttonSizeY           = 24
local buttonWidth           = (selectGroupComboWidth / 2) - buttonPadding

local showDeleteModal       = false

function selectGroupSubscreen.drawSelectGroupSubscreen(gui)
    local startPoint = (ImGui.GetWindowSizeVec().x - selectGroupComboWidth) / 2

    ImGui.SetCursorPosY((ImGui.GetWindowSizeVec().y / 2) - 24 - ((26 * imgui.GetTextLineHeightWithSpacing()) / 2))

    utils.CenterText("Select or Create a Group...")

    utils.CenterItem()
    --   gui.selectedGroupIndex = ImGui.ListBox("##GroupList", gui.selectedGroupIndex, data.GetGroupCompositionList(), nil, 25)
    if ImGui.BeginListBox("##GroupList") then
        local groupList = data.GetGroupCompositionList()
        for i, group in ipairs(groupList) do
            local groupMembers = data.GetGroupComposition(group)

            local tooltipText = '[Members]'
            -- Add unique identifier for each selectable
            if ImGui.Selectable(string.format("%s##%d", group, i), gui.selectedGroupIndex == i) then
                gui.selectedGroupIndex = i
            end

            -- Tooltip logic — no selection required
            if ImGui.IsItemHovered() then
                for index, value in ipairs(groupMembers) do
                    print(value)
                    local botData = data.GetBotDataByName(value)
                    if botData then
                        tooltipText = string.format('%s\n[%i]: [%s] %s', tooltipText, index,
                            botData.Class,
                            value)
                    end
                end
                ImGui.SetTooltip(tooltipText)
            end
        end
        ImGui.EndListBox()
    end





    ImGui.SetCursorPosX(startPoint - (buttonPadding / 2))
    if ImGui.Button("Create a Group", ImVec2(buttonWidth, buttonSizeY)) then
        gui.clearGroupManagementSelections()
        gui.previousSubscreen = "SelectGroup"
        gui.SetActiveSubscreen("CreateGroup")
    end
    ImGui.SameLine()
    if ImGui.Button("Delete a Group", ImVec2(buttonWidth, buttonSizeY)) then
        if gui.selectedGroupIndex > 0 then
            if not ImGui.IsPopupOpen("Delete Group?") then
                ImGui.OpenPopup("Delete Group?")
            end
        end
    end
    local viewport = ImGui.GetMainViewport()
    local center = viewport.Pos + (viewport.Size * 0.5)

    ImGui.SetNextWindowPos(center, ImGuiCond.Appearing, ImVec2(0.5, 0.5)) -- Centered
    ImGui.SetNextWindowSizeConstraints(ImVec2(200, 0), ImVec2(FLT_MAX, FLT_MAX))
    if ImGui.BeginPopupModal("Delete Group?", nil, bit32.bor(ImGuiWindowFlags.NoResize, ImGuiWindowFlags.NoMove)) then
        utils.CenterText("Are you sure you want to delete this group?")
        utils.CenterText(data.GetGroupCompositionList()[gui.selectedGroupIndex])
        local startPoint = (ImGui.GetWindowSizeVec().x - selectGroupComboWidth) / 2
        ImGui.SetCursorPosX(startPoint - (buttonPadding / 2))

        if ImGui.Button("Yes", ImVec2(buttonWidth, buttonSizeY)) then
            data.SetGroupComposition(data.GetGroupCompositionList()[gui.selectedGroupIndex], nil)
            mq.pickle('puppeteer-groups.lua', data.GetGroupComposition())
            gui.clearGroupManagementSelections()
            ImGui.CloseCurrentPopup()
        end
        ImGui.SameLine()
        if ImGui.Button("No", ImVec2(buttonWidth, buttonSizeY)) then
            ImGui.CloseCurrentPopup()
        end

        ImGui.EndPopup()
    end

    ImGui.SetCursorPosX(startPoint - (buttonPadding / 2))

    if ImGui.Button("Spawn + Invite Group", ImVec2(buttonWidth, buttonSizeY)) and gui.selectedGroupIndex ~= 0 then
        gui.selectedGroupName = data.GetGroupCompositionList()[gui.selectedGroupIndex]
        buttonState.SetButtonState("SpawnBotGroup", true,
            function() return { data.GetGroupComposition(gui.selectedGroupName) } end)
    end
    ImGui.SameLine()

    if ImGui.Button("Edit Selected Group", ImVec2(buttonWidth, buttonSizeY)) then
        gui.selectedGroupName = data.GetGroupCompositionList()[gui.selectedGroupIndex]
        gui.previousSubscreen = "SelectGroup"
        gui.SetActiveSubscreen("CreateGroup")
    end
end

return selectGroupSubscreen
