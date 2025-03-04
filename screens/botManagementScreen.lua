local mq = require ('mq')
local imgui = require('ImGui')
local utils = require('utils')
local data = require('data')
local botManagementScreen = {}
local selectBotComboWidth = 350

function botManagementScreen.DrawBotManagementScreen(gui)
    if ImGui.Button("<", ImVec2(32, 32)) then
        gui.selectedBotIndex = 0
        gui.SetActiveScreen("Welcome")
    end
    ImGui.SameLine()
    utils.CenterText("Select or Create a Bot...")
    ImGui.PushItemWidth(selectBotComboWidth)
    utils.CenterItem()
    gui.selectedBotIndex = ImGui.ListBox("##BotList", gui.selectedBotIndex, data.GetBotNameList())
    ImGui.PopItemWidth()

    local buttonPadding = 4
    local buttonSizeY = 24
    local startPoint = (ImGui.GetWindowSizeVec().x - selectBotComboWidth) / 2
    local buttonWidth = (selectBotComboWidth / 3) - buttonPadding

    ImGui.SetCursorPosX(startPoint - (buttonPadding / 2))
    if ImGui.Button("Create a Bot", ImVec2(buttonWidth, buttonSizeY)) then
        gui.selectedBotIndex = 0
        gui.SetActiveSubscreen("CreateBot")
    end
    ImGui.SameLine()
    if ImGui.Button("Refresh Bot List", ImVec2(buttonWidth, buttonSizeY)) then gui.buttonStates.refreshBotList.activated = true end
    ImGui.SameLine()
    if ImGui.Button("Delete a Bot", ImVec2(buttonWidth, buttonSizeY)) then
        gui.selectedBotIndex = 0
        gui.SetActiveScreen("DeleteBot")
    end
    if gui.selectedBotIndex ~= 0 then
        gui.SetActiveSubscreen("BotConfiguration")
    end
end


return botManagementScreen