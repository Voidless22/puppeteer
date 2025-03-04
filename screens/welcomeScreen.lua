local mq = require ('mq')
local imgui = require('ImGui')
local utils = require('utils')
--local gui = require('gui')
local welcomeScreen = {}
function welcomeScreen.DrawWelcomeScreen(gui)
    utils.CenterText("Welcome to Puppeteer.")
    local buttonWidth = 256
    ImGui.SetCursorPosX((ImGui.GetWindowSizeVec().x / 2) - buttonWidth)
    if ImGui.Button("Bot Management", ImVec2(buttonWidth, 24)) then
        gui.SetActiveScreen("BotManagement")
    end
    ImGui.SameLine()
    if ImGui.Button("Global Dashboard", ImVec2(buttonWidth, 24)) then
        gui.selectedBotIndex = 0
        gui.SetActiveScreen("GlobalDashboard")
    end
end


return welcomeScreen