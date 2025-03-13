local mq = require('mq')
local imgui = require('ImGui')
local data = require('data')
local gui = require
local buttonCallbacks = {}



buttonCallbacks.callbackRegistry = {}

 function buttonCallbacks.SetBotTitleButtonCallback(botTitle, botName)
    if botTitle == '' then return end

    mq.delay(5000, function() return mq.TLO.Spawn(botName)() end)
    if mq.TLO.Spawn(botName)() then
        mq.cmdf('/target "%s"', botName)
        mq.delay(250)
        mq.cmdf("/say ^title %s", botTitle:gsub(" ", "_"))
    end
end

 function buttonCallbacks.deleteBotButtonCallback(botName)
    if not mq.TLO.Spawn(botName)() then
        mq.cmdf('/say ^botspawn %s', botName)
        mq.delay(10000, function() return mq.TLO.Spawn(botName)() end)
    end
    if mq.TLO.Spawn(botName)() then
        mq.cmdf('/target %s', botName)
        mq.delay(500)
        mq.cmdf('/say ^botdelete')
        mq.delay(1000)
        mq.cmdf('/say ^botdelete confirm')
        mq.delay(250)
        data.ClearBotList()
        mq.cmdf('/say ^botlist')
    end
end

 function buttonCallbacks.SetBotLastNameButtonCallback(botLastName, botName)
    if botLastName == '' then return end
    mq.delay(5000, function() return mq.TLO.Spawn(botName)() end)
    if mq.TLO.Spawn(botName)() then
        mq.cmdf('/target "%s"', botName)
        mq.delay(250)
        mq.cmdf("/say ^lastname %s", botLastName:gsub(" ", "_"))
    end
end

 function buttonCallbacks.SetBotSuffixButtonCallback(botSuffix, botName)
    if botSuffix == '' then return end
    mq.delay(5000, function() return mq.TLO.Spawn(botName)() end)
    if mq.TLO.Spawn(botName)() then
        mq.cmdf('/target "%s"', botName)
        mq.delay(250)
        mq.cmdf("/say ^suffix %s", botSuffix:gsub(" ", "_"))
    end
end

 function buttonCallbacks.spawnBotGroupButtonCallback(groupMembers)
    local raidUnlocked = false
    local foundEmptyGroup = false
    local raidGroupCount = 12
    local groupMemberCount = 6
    local IAmGroupLeader = false
    for i = 1, #groupMembers do
        if groupMembers[i] == mq.TLO.Me.Name() then
            IAmGroupLeader = true
        end
    end
    for i = 1, #groupMembers do
        if not mq.TLO.Spawn(groupMembers[i])() then
            mq.cmdf('/say ^botspawn %s', groupMembers[i])
            mq.delay(5000, function() return mq.TLO.Spawn(groupMembers[i])() end)
        end

        if IAmGroupLeader then
            mq.cmdf('/invite %s', groupMembers[i])
        else
            if not mq.TLO.Window("RaidWindow").Open() then
                mq.TLO.Window("RaidWindow").DoOpen()
            end
            mq.cmdf("/notify RaidWindow RAID_UnLockButton LeftMouseUp")
            mq.delay(500)
            mq.cmdf('/raidinvite %s', groupMembers[i])
        end
    end
    if not IAmGroupLeader then
        mq.cmdf("/notify RaidWindow RAID_LockButton LeftMouseUp")
        mq.delay(500)
        local currentRaidGroup = 1
        local totalEmptyGroupSlots = 0
        local foundGroup = false

        for i = 1, 72 do
            local raidSlot = mq.TLO.Window("RaidWindow").Child("RAID_PlayerList").List(i, 2)()
            printf("Slot [%i]: %s", i, raidSlot)

            if raidSlot == 'empty' then
                totalEmptyGroupSlots = totalEmptyGroupSlots + 1
            elseif raidSlot == nil then
                if totalEmptyGroupSlots == 6 then
                    printf("Found Candidate Group: %i", currentRaidGroup)
                    foundGroup = true
                    break
                else
                    totalEmptyGroupSlots = 0 -- Reset only if the previous group didn't qualify
                end
                currentRaidGroup = currentRaidGroup + 1
            else
                totalEmptyGroupSlots = 0 -- Reset if encountering a non-empty slot
            end
        end

        if not foundGroup then
            printf("No fully empty group found.")
        else
            for i = 1, mq.TLO.Window("RaidWindow").Child("RAID_NotInGroupPlayerList").Items() do
                mq.cmdf("/notify RaidWindow RAID_NotInGroupPlayerList ListSelect %i", i)
                mq.delay(10)
                mq.cmdf('/notify RaidWindow RAID_Group%iButton LeftMouseUp', currentRaidGroup)
                mq.delay(10)
            end
        end
    end
end

local function EmptyCallback()
    printf("This button does nothing yet.")
end

local function SpawnedBotsAttackCallback()
    if mq.TLO.Target.ID() ~= 0 then
        mq.cmdf('/say ^attack spawned')
    end
    printf('Callback triggered')
end

local function BackOffCallback()
    mq.cmdf('/say ^release spawned')
    mq.cmdf('/say ^botsummon spawned')
end

local function SetupCampCallback()
    mq.cmdf('/say ^botsummon spawned')
    mq.delay(500)
    mq.cmdf('/say ^guard spawned')
end

local function ClearCampCallback()
    mq.cmdf('/say ^guard clear spawned')
    mq.delay(500)
    mq.cmdf('/say ^botsummon spawned')
end

local function EnableAutoDefendCallback()
    mq.cmdf('/say ^oo autodefend enable')
end

local function DisableAutoDefendCallback()
    mq.cmdf('/say ^oo autodefend disable')
end

local function SummonBotsCallback()
    mq.cmdf('/say ^botsummon spawned')
end

local function CheckBotUpgradesCallback()
    if not mq.TLO.Cursor() then
        printf("You need an item on your cursor to do this.")
    else
        data.ClearPotentialBotItemUpgrades()
        mq.cmd('/say ^iu')
    end
end
local function ToggleWindowShow()
mq.cmd('/puppeteer')
end

local function EnableHoldBotsCallback()
    mq.cmdf('/say ^hold spawned')

end
local function DisableHoldBotsCallback()
    mq.cmdf('/say ^hold clear spawned')

end




buttonCallbacks.callbackRegistry.defaultCallback = EmptyCallback
buttonCallbacks.callbackRegistry.SpawnedAtkCallback = SpawnedBotsAttackCallback
buttonCallbacks.callbackRegistry.BackOffCallback = BackOffCallback
buttonCallbacks.callbackRegistry.SetupCampCallback = SetupCampCallback
buttonCallbacks.callbackRegistry.ClearCampCallback = ClearCampCallback
buttonCallbacks.callbackRegistry.EnableAutoDefendCallback = EnableAutoDefendCallback
buttonCallbacks.callbackRegistry.DisableAutoDefendCallback = DisableAutoDefendCallback
buttonCallbacks.callbackRegistry.SummonBotsCallback = SummonBotsCallback
buttonCallbacks.callbackRegistry.CheckBotUpgradesCallback = CheckBotUpgradesCallback
buttonCallbacks.callbackRegistry.ToggleShowWindow = ToggleWindowShow
buttonCallbacks.callbackRegistry.EnableHoldBotsCallback = EnableHoldBotsCallback
buttonCallbacks.callbackRegistry.DisableHoldBotsCallback = DisableHoldBotsCallback

return buttonCallbacks
