local mq = require('mq')
local imgui = require('ImGui')
local utils  = require('utils')
local data = require('data')
local selectBotSubscreen = {}
local selectBotComboWidth = 350

function selectBotSubscreen.drawSelectBotSubscreen(gui) 
    ImGui.SetCursorPosY((ImGui.GetWindowSizeVec().y / 2) - 24 - ((26 * imgui.GetTextLineHeightWithSpacing()) / 2))
    utils.CenterText("Select or Create a Bot...")
    ImGui.PushItemWidth(selectBotComboWidth)
    utils.CenterItem()

    gui.botConfigSelectedBotIndex = ImGui.ListBox("##BotList", gui.botConfigSelectedBotIndex, data.GetBotNameList(), nil, 25)
    ImGui.PopItemWidth()

    local buttonPadding = 4
    local buttonSizeY = 24
    local startPoint = (ImGui.GetWindowSizeVec().x - selectBotComboWidth) / 2
    local buttonWidth = (selectBotComboWidth / 3) - buttonPadding

    ImGui.SetCursorPosX(startPoint - (buttonPadding / 2))
    if ImGui.Button("Create a Bot", ImVec2(buttonWidth, buttonSizeY)) then
        gui.botConfigSelectedBotIndex = 0
        gui.SetActiveScreen("CreateBot")
    end
    ImGui.SameLine()
    if ImGui.Button("Refresh Bot List", ImVec2(buttonWidth, buttonSizeY)) then gui.buttonStates.refreshBotList.activated = true end
    ImGui.SameLine()
    if ImGui.Button("Delete a Bot", ImVec2(buttonWidth, buttonSizeY)) then
        gui.botConfigSelectedBotIndex = 0
        gui.SetActiveScreen("DeleteBot")
    end
end



return selectBotSubscreen