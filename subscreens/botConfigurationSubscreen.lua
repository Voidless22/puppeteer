local mq = require('mq')
local imgui = require('ImGui')
local utils = require('utils')
local data = require('data')
local botConfigurationSubscreen = {}

local iconSize = 42
local iconXPadding = 6
local iconYPadding = 12
local textPadding = 12
local textSpacing = 16 -- Spacing between text lines
local centerRectSize
local windowSize
-- Useful bounds variables for cursor positioning
local windowCenter 
local rectTop 
local rectCenterX 
local rectCenterY 

local function drawCenterRect(selectedBotIndex, gui)
    local botData = data.RefreshData(selectedBotIndex)
    windowSize = ImGui.GetWindowSizeVec()

     windowCenter = ImVec2(windowSize.x / 2, windowSize.y / 2)
   
    local CenterText = {}
    if botData ~= nil then
        CenterText = {
            botData.Title,
            botData.Name,
            botData.Surname,
            botData.Suffix
        }
    end
    -- Calculate the total text height
    local textHeight = 0
    for _, text in ipairs(CenterText) do
        if text ~= '' then
            textHeight = textHeight + ImGui.CalcTextSizeVec(text).y + textSpacing
        end
    end

    -- Include icon height
    local totalContentHeight = iconSize + iconYPadding + textHeight + iconSize

    -- Rect Drawing Start
    local drawList = ImGui.GetWindowDrawList()
    local lastCursorScreenPos = ImGui.GetCursorScreenPosVec()
    centerRectSize = ImVec2(utils.getMaxButtonTextSize(CenterText) + (textPadding * 2), totalContentHeight)

    local rectScreenStartPos = lastCursorScreenPos + (windowSize - centerRectSize) / 2
    local rectScreenEndPos = rectScreenStartPos + centerRectSize

    rectTop = windowCenter.y - (centerRectSize.y / 2)
    rectCenterX = windowCenter.x
    rectCenterY = rectTop + (centerRectSize.y / 2)


    -- Draw the rectangle
    drawList:AddRect(rectScreenStartPos, rectScreenEndPos, ImGui.GetColorU32(ImVec4(255, 0, 0, 255)))

    -- Info Draw Start
    local botData = data.GetBotData(selectedBotIndex)
    local raceTexture = botData.Gender == "Male"
        and utils.RaceTextures['M' .. botData.Race:gsub("%s+", "")]
        or utils.RaceTextures['F' .. botData.Race:gsub("%s+", "")]

    ImGui.SetCursorPos(ImVec2(rectCenterX + iconXPadding - (iconSize / 2), rectTop + iconYPadding))
    ImGui.DrawTextureAnimation(raceTexture, iconSize, iconSize)

    -- Draw Texts
    local cursorY = rectTop + iconSize + iconYPadding
    for _, text in ipairs(CenterText) do
        if text ~= '' then
            ImGui.SetCursorPosX(rectCenterX - (ImGui.CalcTextSize(text) / 2) + (textPadding / 2))
            ImGui.SetCursorPosY(cursorY)
            ImGui.Text(text)
            cursorY = cursorY + ImGui.GetTextLineHeight() + textSpacing
        end
    end

    -- Draw the class icon
    ImGui.SetCursorPos(ImVec2(rectCenterX + iconXPadding - (iconSize / 2), cursorY))
    ImGui.DrawTextureAnimation(utils.ClassTextures[botData.Class], iconSize, iconSize)
end



local function drawInventoryCenter(selectedBotIndex, gui)
    -- Draw 22 icons in a circular pattern around the rectangle
    local radius = (centerRectSize.x / 2) + (iconSize * 3) -- Adjust distance from the rectangle
    local numIcons = 22
    local angleStep = (math.pi * 2) / numIcons             -- Divide full circle into 22 equal parts

    for i = 0, numIcons - 1 do
        local angle = i * angleStep
        local iconX = rectCenterX + math.cos(angle) * radius - (iconSize / 2)
        local iconY = rectCenterY + math.sin(angle) * radius - (iconSize / 2)

        ImGui.SetCursorPos(ImVec2(iconX, iconY))
        ImGui.DrawTextureAnimation(utils.EquipmentSlotTextures[i + 1], iconSize, iconSize) -- Use correct texture
    end
end



function botConfigurationSubscreen.drawBotConfigurationSubscreen(selectedBotIndex, gui)
    ImGui.SetCursorPosX(16)
    if ImGui.BeginChild("BotConfiguration", ImVec2(480, 512), ImGuiChildFlags.Border) then
        drawCenterRect(selectedBotIndex, gui)
      --  drawInventoryCenter(selectedBotIndex, gui)

        ImGui.EndChild()
    end
end

return botConfigurationSubscreen
