local mq = require('mq')
local imgui = require('ImGui')
local utils = require('utils')
local data = require('data')
local botConfigurationSubscreen = {}


function botConfigurationSubscreen.drawBotConfigurationSubscreen(selectedBotIndex)
    local iconSize = 48
    local iconPadding = 4
    local textRowSpacing = 16
    if ImGui.BeginChild("BotConfiguration", ImVec2(480, 512), ImGuiChildFlags.Border) then
        ImGui.SetCursorPosX(16)
        local lastCursorPos = ImGui.GetCursorPosVec()
        local botData = data.GetBotData(selectedBotIndex)
        local raceTexture
        local classTexture
        if botData ~= nil then
            if botData.Gender == 1 then
                raceTexture = utils.RaceTextures['M' .. botData.Race:gsub("%s+", "")]
            else
                raceTexture = utils.RaceTextures['F' .. botData.Race:gsub("%s+", "")]
            end
            classTexture = utils.ClassTextures[botData.Class:gsub("%s+","")]
            lastCursorPos = ImGui.GetCursorPosVec()
            ImGui.DrawTextureAnimation(raceTexture, iconSize, iconSize)
            ImGui.SetCursorPos(ImVec2(lastCursorPos.x, lastCursorPos.y + (iconSize + iconPadding)))
            ImGui.DrawTextureAnimation(classTexture, iconSize, iconSize)
            ImGui.SetCursorPos(ImVec2(lastCursorPos.x + (iconSize + iconPadding), lastCursorPos.y))
            --ImGui.SameLine()
            lastCursorPos = ImGui.GetCursorPosVec()
            ImGui.Text(botData.Name)
            ImGui.SetCursorPos(ImVec2(lastCursorPos.x, lastCursorPos.y + textRowSpacing))
            lastCursorPos = ImGui.GetCursorPosVec()
            ImGui.Text(botData.Class)
            ImGui.SetCursorPos(ImVec2(lastCursorPos.x, lastCursorPos.y + textRowSpacing))
            lastCursorPos = ImGui.GetCursorPosVec()
            ImGui.Text(botData.Race)
            ImGui.SetCursorPos(ImVec2(lastCursorPos.x, lastCursorPos.y + textRowSpacing))
            lastCursorPos = ImGui.GetCursorPosVec()
            ImGui.Text(botData.Gender)     
            ImGui.SetCursorPos(ImVec2(lastCursorPos.x, lastCursorPos.y + textRowSpacing))
            lastCursorPos = ImGui.GetCursorPosVec()
            ImGui.Text("Level %s", botData.Level)
        end
        ImGui.EndChild()
    end
end

return botConfigurationSubscreen
