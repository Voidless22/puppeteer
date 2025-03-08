local mq = require('mq')
local imgui = require('ImGui')

local dashboardScreen = {}

local buttonSize = ImVec2(48, 48)
local buttonPadding = 4

 
local function CreateButtonGrid(gui, buttonSize, buttonPadding, buttonTable, columnCount, rowCount, gridWidth)
    if gridWidth == nil then
        gridWidth = ImGui.GetWindowSizeVec().x
    end
    if columnCount == nil then
        columnCount = math.floor((gridWidth - (buttonPadding * 2)) / (buttonSize.x + buttonPadding))
    end

    ImGui.SetCursorPosX(gridWidth / #buttonTable - buttonPadding)
    local StartCursorPos = ImGui.GetCursorPosVec()

    local currentColumn = 1
    local currentRow = 1

    for _, value in ipairs(buttonTable) do
        local lastCursorPos = ImGui.GetCursorPosVec()
        if ImGui.Button(value.text, ImVec2(buttonSize.x, buttonSize.y)) then
            printf("Button: %s Selected", value.text)
            value.callback(gui)
        end
        if currentColumn < columnCount then
            ImGui.SetCursorPos(ImVec2((lastCursorPos.x + buttonSize.x + buttonPadding), lastCursorPos.y))
            currentColumn = currentColumn + 1
        elseif currentColumn >= columnCount then
            ImGui.SetCursorPos(ImVec2(StartCursorPos.x, (lastCursorPos.y + buttonSize.y + buttonPadding)))
            currentRow = currentRow + 1
            currentColumn = 1
        end
    end
end

function dashboardScreen.DrawDashboardScreen(gui)

    ImGui.Button('32x32', ImVec2(48, 48))
end

return dashboardScreen
