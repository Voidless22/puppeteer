local mq = require('mq')
local imgui = require('ImGui')
local utils = require('utils')
local data = require('data')
local events = require('events')
local createGroupSubscreen = {}

local groupName
local ColumnID_GrpSlot = 0
local ColumnID_Name = 1
local ColumnID_Class = 2
local ColumnID_Remove = 3
local ColumnID_AddToGroup = 3
local projectedGroup = {}

local includeSelfInProjectedGrp = false
local lastModifiedGroupIndex = nil


local function saveGroupData(gui, groupName, projectedGroup,noReturn)
    -- let's save it in our groups table
    data.SetGroupComposition(groupName, projectedGroup)
    -- then write the entire groups table again
    mq.pickle('puppeteer-groups-' .. mq.TLO.Me.Name() .. '.lua', data.GetGroupComposition())
    -- clear index slates and go back to select
    if not noReturn then
    gui.clearGroupManagementSelections()
    gui.SetActiveSubscreen("SelectGroup")
    end
end


local function prepGroupData(gui, selectedGroup)
    -- clean the slate for projected group
    projectedGroup = {}
    -- now let's get the group we actually want
    projectedGroup = data.GetGroupComposition(selectedGroup)
    -- is this a new group from the last time we did this? if so let's set the initial Group Name, and refresh our last index.
    if lastModifiedGroupIndex ~= gui.selectedGroupIndex then
        groupName = selectedGroup
        lastModifiedGroupIndex = gui.selectedGroupIndex
    end
    -- okay, since this group was already made, am I in here? let's flip that switch if I am.
    -- While we're at it, we need to make sure all the bots in this group actually still exist.
    for index, value in ipairs(projectedGroup) do
        local botFound = false
        if value == mq.TLO.Me.Name() then
            includeSelfInProjectedGrp = true
        end
        for _, botEntry in ipairs(data.GetBotNameList()) do
            if botEntry == value then
                botFound = true
            end
        end
        if not botFound and value ~= mq.TLO.Me.Name() then
            printf(
            "The following bot: [%s] was not found in the available bot list, and will be removed from the group.", value)
            table.remove(projectedGroup, index)
            saveGroupData(gui, groupName, projectedGroup)
        end
    end
end


function createGroupSubscreen.drawCreateGroupSubscreen(gui, selectedGroup)
    -- We have a group selected to read from, let's get the data prepped
    if selectedGroup ~= nil then
        prepGroupData(gui, selectedGroup)
    else
        -- let's refresh our indexes
        if lastModifiedGroupIndex ~= gui.selectedGroupIndex then
            gui.clearGroupManagementSelections()
            projectedGroup = {}
            groupName = selectedGroup
            lastModifiedGroupIndex = gui.selectedGroupIndex
        end
    end

    utils.CenterText("Create a Group")
    utils.BetterNewLine(5)
    utils.CenterText("Group Name")
    includeSelfInProjectedGrp = ImGui.Checkbox("Include Self In Group", includeSelfInProjectedGrp)
    -- We already did this check in prepGroupData, but A) if there isn't a group to prep, and B) if the value is changed, we need to do this.
    -- Are we supposed to be in group?
    local foundInGroup = false
    for _, value in ipairs(projectedGroup) do
        if value == mq.TLO.Me.Name() then
            if includeSelfInProjectedGrp then
                foundInGroup = true
            else
                table.remove(projectedGroup, _)
            end
        end
    end
    -- okay we aren't in the group, and we're supposed to be. Is there room? if so, add us in, if not let the user know.
    if not foundInGroup and includeSelfInProjectedGrp then
        if #projectedGroup < 6 then
            table.insert(projectedGroup, mq.TLO.Me.Name())
        else
            printf("You can't be added to this group because it is full. Remove a bot to continue.")
            includeSelfInProjectedGrp = false
        end
    end


    ImGui.SameLine()
    ImGui.SetNextItemWidth(200)
    groupName = ImGui.InputText("##CreateGroupName", groupName)
    ImGui.SameLine()

    if ImGui.Button("Save Group", ImVec2(96, 24)) then
        saveGroupData(gui, groupName, projectedGroup)
    end
    utils.BetterNewLine(5)
    utils.CenterText("Projected Group")
    utils.BetterNewLine(10)
    if imgui.BeginTable('##projectedGroup', 4, ImGuiTableFlags.Borders) then
        imgui.TableSetupColumn('Slot', ImGuiTableColumnFlags.WidthFixed, 50, ColumnID_GrpSlot)
        imgui.TableSetupColumn('Bot Name', ImGuiTableColumnFlags.WidthStretch, 100, ColumnID_Name)
        imgui.TableSetupColumn('Class',
            ImGuiTableColumnFlags.WidthFixed, 100, ColumnID_Class)
        imgui.TableSetupColumn('',
            ImGuiTableColumnFlags.WidthFixed, 75,
            ColumnID_Remove)
        imgui.TableSetupScrollFreeze(0, 1) -- Make row always visible

        -- Display data
        imgui.TableHeadersRow()

        local clipper = ImGuiListClipper.new()
        clipper:Begin(6)
        while clipper:Step() do
            for row_n = clipper.DisplayStart, clipper.DisplayEnd - 1, 1 do
                local bot = data.GetBotDataByName(projectedGroup[row_n + 1])
                if bot then
                    imgui.PushID(bot.Name .. row_n)
                else
                    imgui.PushID("GroupSlot" .. row_n)
                end

                imgui.TableNextRow()
                imgui.TableNextColumn()
                imgui.Text(string.format("%i", row_n + 1))
                imgui.TableNextColumn()

                if projectedGroup[row_n + 1] == mq.TLO.Me.Name() then
                    imgui.Text(mq.TLO.Me.Name())
                    imgui.TableNextColumn()
                    imgui.Text(mq.TLO.Me.Class())
                    imgui.TableNextColumn()
                else
                    if bot then
                        imgui.Text(bot.Name)
                        imgui.TableNextColumn()
                        imgui.Text(bot.Class)
                        imgui.TableNextColumn()
                        if imgui.SmallButton('Remove') then
                            table.remove(projectedGroup, row_n + 1)
                        end
                    end
                end

                imgui.PopID()
            end
        end
        imgui.EndTable()
    end

    utils.BetterNewLine(25)
    utils.CenterText("Available Bots")
    utils.BetterNewLine(5)
    if ImGui.BeginTable("##AvailableBots", 3, bit32.bor(ImGuiTableFlags.Borders, ImGuiTableFlags.Sortable, ImGuiTableFlags.ScrollY), ImVec2(500, 200)) then
        imgui.TableSetupColumn('Bot Name', ImGuiTableColumnFlags.WidthStretch, 50, ColumnID_Name)
        imgui.TableSetupColumn('Class', ImGuiTableColumnFlags.WidthStretch, 50, ColumnID_Class)
        imgui.TableSetupColumn('', ImGuiTableColumnFlags.WidthStretch, 50, ColumnID_AddToGroup)
        imgui.TableSetupScrollFreeze(0, 1) -- Make row always visible

        -- Display data
        imgui.TableHeadersRow()
        local botList = data.GetBotData()
        for index, value in ipairs(botList) do
            local inGroup = false
            for i = 1, #projectedGroup do
                if value.Name == projectedGroup[i] then
                    inGroup = true
                end
            end
            if not inGroup then
                imgui.TableNextRow()
                imgui.TableNextColumn()
                imgui.Text(value.Name)
                imgui.TableNextColumn()
                imgui.Text(value.Class)
                imgui.TableNextColumn()
                if imgui.SmallButton('Add to Group##' .. index) then
                    if #projectedGroup == 6 then
                        printf("Group is full, remove a character to continue.")
                    else
                        table.insert(projectedGroup, value.Name)
                    end
                end
            end
        end
        ImGui.EndTable()
    end
    ImGui.NewLine()
    utils.CenterItem(200)
    if ImGui.Button("Spawn and Invite Group", ImVec2(200, 128)) then
        events.SetButtonState("SpawnBotGroup", true, function() return { projectedGroup } end)
    end
end

return createGroupSubscreen
