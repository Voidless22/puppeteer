local mq                    = require('mq')
local imgui                 = require('ImGui')
local utils                 = require('utils')
local data                  = require('data')
local selectGroupSubscreen  = {}
local selectGroupComboWidth = 350

function selectGroupSubscreen.drawSelectGroupSubscreen(gui)
    ImGui.SetCursorPosY((ImGui.GetWindowSizeVec().y / 2) - 24 - ((26 * imgui.GetTextLineHeightWithSpacing()) / 2))
    utils.CenterText("Select or Create a Group...")
    ImGui.PushItemWidth(selectGroupComboWidth)
    utils.CenterItem()

    gui.selectedGroupIndex = ImGui.ListBox("##GroupList",  gui.selectedGroupIndex, data.GetGroupCompositionList(), nil, 25)
    ImGui.PopItemWidth()

    local buttonPadding = 4
    local buttonSizeY = 24
    local startPoint = (ImGui.GetWindowSizeVec().x - selectGroupComboWidth) / 2
    local buttonWidth = (selectGroupComboWidth / 2) - buttonPadding

    ImGui.SetCursorPosX(startPoint - (buttonPadding / 2))
    if ImGui.Button("Create a Group", ImVec2(buttonWidth, buttonSizeY)) then
        gui.selectedGroupIndex = 0
        gui.previousSubscreen = "SelectGroup"
        gui.SetActiveSubscreen("CreateGroup")
    end
    ImGui.SameLine()
    if ImGui.Button("Delete a Group", ImVec2(buttonWidth, buttonSizeY)) then
        gui.selectedGroupIndex = 0
        gui.previousSubscreen = "SelectGroup"
        gui.SetActiveSubscreen("DeleteGroup")
    end
end

return selectGroupSubscreen
