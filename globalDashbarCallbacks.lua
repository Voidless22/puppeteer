local mq = require('mq')
local imgui = require('ImGui')
local globalDashbarCallbacks = {}

--[[
Global Dash Buttons:
1-Attack [target] spawned
2-Back Off
3-Guard Here (toggle)
5-Auto Assist On (toggle)
7-Summon to me

8-Port Group To (select submenu)
9-Upgrade? (itemuse spawned)
10-Swap Stance (select submenu)
11-Spawn Group
12-Swap Group
13-Camp Group


]]


function globalDashbarCallbacks.EmptyCallback()
    printf("This button does nothing yet.")
end

function globalDashbarCallbacks.SpawnedBotsAttackCallback()
    if mq.TLO.Target.ID() ~= 0 then
        mq.cmdf('/say ^attack spawned')
    end
    printf('Callback triggered')
end

function globalDashbarCallbacks.BackOffCallback()
    mq.cmdf('/say ^release spawned')
    mq.cmdf('/say ^botsummon spawned')
end

function globalDashbarCallbacks.SetupCampCallback()
    mq.cmdf('/say ^botsummon spawned')
    mq.delay(500)
    mq.cmdf('/say ^guard spawned')
end

function globalDashbarCallbacks.ClearCampCallback()
    mq.cmdf('/say ^guard clear spawned')
    mq.delay(500)
    mq.cmdf('/say ^botsummon spawned')
end

function globalDashbarCallbacks.EnableAutoDefendCallback()
    mq.cmdf('/say ^oo autodefend enable')
end

function globalDashbarCallbacks.DisableAutoDefendCallback()
    mq.cmdf('/say ^oo autodefend disable')
end

function globalDashbarCallbacks.SummonBotsCallback()
    mq.cmdf('/say ^botsummon spawned')
end

function globalDashbarCallbacks.CheckBotUpgradesCallback()
    if not mq.TLO.Cursor() then
        printf("You need an item on your cursor to do this.")
    else
        mq.cmd('/say ^iu')
    end
end

return globalDashbarCallbacks
