local mq                 = require('mq')
local imgui              = require('ImGui')
local data               = require('data')
local utils              = require('utils')

local stanceSelectWindow = {}

local stanceOptions      = {
    [1] = 'Passive',
    [2] = 'Balanced',
    [3] = 'Efficient',
    [4] = 'Aggressive', -- + 1 (5)
    [5] = 'Assist', -- + 1 (6)
    [6] = 'Burn', -- + 1 (7)
    [7] = 'AE Burn' -- + 2 (9)
}
local stanceDescriptions = {
    [1] = 'Idle. Does not Cast or engage in combat.',
    [2] = 'Overall balance and casts most spell types by default.',
    [3] =
    'More mana and aggro efficient (SKs will still cast hate line). Longer delays between detrimental spells, thresholds adjusted to cast less often.',
    [4] = 'Support Role. Most offensive spell types are disabled. Focused on heals, cures, CC, debuffs and slows.',
    [5] =
    'Much more aggressive in their cast times and thresholds. More DPS, debuffs and slow but a higher risk of snagging aggro.',
    [6] = "Murder. Doesn't care about aggro, just wants to kill. DPS machine.",
    [7] = "Murder EVERYTHING. Doesn't care about aggro, casts AEs. Everything must die ASAP."
}


local openSwapStanceWnd, showSwapStanceWnd = false, true
stanceSelectWindow.selectedBot = 1
stanceSelectWindow.projectedStance = 0
function stanceSelectWindow.DrawStanceSelectWindow()
    local buttonWidth = 96
    local buttonSizeY = 48
    local wndSize = ImVec2(350, 220)
    local viewport = ImGui.GetMainViewport()
    local center = viewport.Pos + (viewport.Size * 0.5) - (wndSize / 2)

    ImGui.SetNextWindowPos(center, ImGuiCond.Appearing, ImVec2(0.5, 0.5)) -- Centered
    --ImGui.SetNextWindowSizeConstraints(ImVec2(200, 0), ImVec2(FLT_MAX, FLT_MAX))
    openSwapStanceWnd, showSwapStanceWnd = ImGui.Begin("Swap Stance", openSwapStanceWnd,
        bit32.bor(ImGuiWindowFlags.NoResize))
    if showSwapStanceWnd then
        ImGui.SetWindowSize(350, 220)
        local spawnedBotList = data.GetSpawnedBotNameList()
        local botData = data.GetBotDataByName(spawnedBotList[stanceSelectWindow.selectedBot])
        utils.CenterText("Selected Bot")
        utils.BetterNewLine(5)
        if botData then
            utils.CenterText("Current Stance: %s", botData.Stance.name)
            if stanceSelectWindow.projectedStance == nil then
                stanceSelectWindow.projectedStance = botData.Stance.name
            end
        end
        stanceSelectWindow.selectedBot = ImGui.Combo("Selected Bot", stanceSelectWindow.selectedBot, spawnedBotList)
        utils.CenterText('Projected Stance: %s', stanceOptions[stanceSelectWindow.projectedStance])
        utils.BetterNewLine(5)
        stanceSelectWindow.projectedStance = ImGui.Combo("Projected Stance", stanceSelectWindow.projectedStance,
            stanceOptions)
        if ImGui.IsItemHovered() and stanceSelectWindow.projectedStance ~= 0 then
            ImGui.SetTooltip(stanceDescriptions[stanceSelectWindow.projectedStance])
        end
        utils.CenterItem(100)
        if ImGui.Button("Save##stancewnd", ImVec2(48, 24)) then
            local stanceID = stanceSelectWindow.projectedStance 
            if stanceSelectWindow.projectedStance  >= 4 and stanceSelectWindow.projectedStance  < 7 then
                stanceID = stanceID + 1
            end
            if stanceSelectWindow.projectedStance  == 7 then
                stanceID = stanceID + 2
            end
            mq.cmdf('/say ^stance %i byname %s', stanceID, spawnedBotList[stanceSelectWindow.selectedBot])
            data.SetShouldOpenStanceSelect(false)
        end
        ImGui.SameLine(0, 4)
        if ImGui.Button("Close##stanceWnd", ImVec2(48, 24)) then
            data.SetShouldOpenStanceSelect(false)
        end
    end
    ImGui.End()
end

return stanceSelectWindow
