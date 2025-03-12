local mq                 = require('mq')
local imgui              = require('ImGui')
local data               = require('data')
local buttonState        = require('buttonState')
local globalDashbar      = {}

local buttonOuterPadding = 8
local minButtonSize      = 48
local buttonSpacing      = 8
local buttonTable        = data.GetGlobalDashbarButtons()
local outerPaddingX      = 16
local outerPaddingY      = 34
local scrollPadBuffer    = 8
local function drawButtonGrid()
    buttonTable = data.GetGlobalDashbarButtons()
    local drawlist = ImGui.GetWindowDrawList()
    local columnCount = math.floor((ImGui.GetWindowSizeVec().x - (buttonOuterPadding * 1.5)) /
        (minButtonSize + buttonSpacing))
    local rowCount = math.ceil(#buttonTable / columnCount) -- Calculate the number of rows correctly

    local currentColumn = 1
    ImGui.SetCursorPos(outerPaddingX, outerPaddingY)
    -- Set the window size to fit the total height needed for the grid
    if ImGui.GetWindowSizeVec().y > minButtonSize * rowCount + (outerPaddingY * 2) + scrollPadBuffer then
        ImGui.SetWindowSize(ImGui.GetWindowSizeVec().x,
            rowCount * (minButtonSize + buttonSpacing) + outerPaddingY + scrollPadBuffer)
    end



    for index, value in ipairs(buttonTable) do
        local prevCursorPos = ImGui.GetCursorPosVec()
        local prevScreenCursorPos = ImGui.GetCursorScreenPosVec()
        -- Capture the draw list to overlay custom visuals
        local drawList = ImGui.GetWindowDrawList()
        -- toggle drawlist locs
        local buttonMin = prevScreenCursorPos
        local buttonMax = ImVec2(prevScreenCursorPos.x + minButtonSize, prevScreenCursorPos.y + minButtonSize)

        local buttonLabel = value.Name .. '##' .. index
        -- if the text won't fit in the button, empty the label for later
        if ImGui.CalcTextSizeVec(value.Name).x > minButtonSize then
            buttonLabel = "##" .. value.Name .. index
        end

        -- now we actually add the button
        if ImGui.Button(buttonLabel, ImVec2(minButtonSize, minButtonSize)) then
            if value.toggleState ~= nil then
                buttonState.FlipToggle(index..'-DashbarBtn')
            end
            buttonState.SetButtonState(index..'-DashbarBtn', true)
        end



        -- if we have an empty label that means we need to wrap it
        if buttonLabel == "##" .. value.Name .. index then
            ImGui.SetCursorPos(prevCursorPos)
            local labelSize = ImGui.CalcTextSizeVec(value.Name, false, minButtonSize)
            local buttonCenter = ImGui.GetCursorPosVec() + ImVec2(minButtonSize / 2, minButtonSize / 2)
            ImGui.SetCursorPos(buttonCenter - (labelSize / 2))
            ImGui.PushTextWrapPos(ImGui.GetCursorPosX() + minButtonSize)
            ImGui.TextWrapped(value.Name)
        end

        -- Draw the semi-transparent overlay only if toggleState exists
        if value.toggleState ~= nil then
            local overlayColor = value.toggleState and ImVec4(0, 1, 0, 0.3) or ImVec4(1, 0, 0, 0.3)
            drawList:AddRectFilled(buttonMin, buttonMax, ImGui.GetColorU32(overlayColor), 0)
        end

        if value.tooltip ~= nil then
            ImGui.SetItemTooltip(value.tooltip)
        end

        if currentColumn < columnCount then
            ImGui.SetCursorPosX(prevCursorPos.x + (minButtonSize + buttonSpacing))
            ImGui.SetCursorPosY(prevCursorPos.y)
            currentColumn = currentColumn + 1
        else
            ImGui.SetCursorPosX(outerPaddingX)
            ImGui.SetCursorPosY(prevCursorPos.y + (minButtonSize + buttonSpacing))
            currentColumn = 1
        end
    end
end
function globalDashbar.DrawGlobalDashbar(gui)
    drawButtonGrid()
end

return globalDashbar
