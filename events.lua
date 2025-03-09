local mq = require('mq')
local utils = require('utils')
local data = require('data')
local events = {}


local function SetBotTitleEventCallback(botTitle, botName)
    if botTitle == '' then return end

    mq.delay(5000, function() return mq.TLO.Spawn(botName)() end)
    if mq.TLO.Spawn(botName)() then
        mq.cmdf('/target "%s"', botName)
        mq.delay(250)
        mq.cmdf("/say ^title %s", botTitle:gsub(" ", "_"))
    end
end

local function deleteBotEventCallback(botName)
    if not mq.TLO.Spawn(botName)() then
        mq.cmdf('/say ^botspawn %s', botName)
        mq.delay(10000, function() return mq.TLO.Spawn(botName)() end)
    end
    if mq.TLO.Spawn(botName)() then
        mq.cmdf('/target %s', botName)
        mq.delay(500)
        mq.cmdf('/say ^botdelete')
        mq.delay(2000)
        mq.cmdf('/say ^botdelete confirm')
    end
end


local function SetBotLastNameEventCallback(botLastName, botName)
    if botLastName == '' then return end
    mq.delay(5000, function() return mq.TLO.Spawn(botName)() end)
    if mq.TLO.Spawn(botName)() then
        mq.cmdf('/target "%s"', botName)
        mq.delay(250)
        mq.cmdf("/say ^lastname %s", botLastName:gsub(" ", "_"))
    end
end

local function SetBotSuffixEventCallback(botSuffix, botName)
    if botSuffix == '' then return end
    mq.delay(5000, function() return mq.TLO.Spawn(botName)() end)
    if mq.TLO.Spawn(botName)() then
        mq.cmdf('/target "%s"', botName)
        mq.delay(250)
        mq.cmdf("/say ^suffix %s", botSuffix:gsub(" ", "_"))
    end
end
local function spawnBotGroupEventCallback(groupMembers)
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

local function refreshBotListEventCallback()
end


function events.getBotList(line, botIndex, botName, botLevel, botGender, botDetails)
    local race = utils.findMatchInTable(botDetails, utils.Races)
    local class = utils.findMatchInTable(botDetails, utils.Classes)

    printf('Bot List Event')

    data.initBotData(tonumber(botIndex), {
        Name = botName,
        Level = botLevel,
        Gender = botGender,
        Race = race,
        Class = class,
        Title = '',
        Surname = '',
        Suffix = ''
    })
end

function events.GetEventState(event)
    if event ~= nil then
        return events.eventStates[event]
    else
        return events.eventStates
    end
end

function events.SetEventState(event, state, args)
    if event == nil then
        printf('invalid event supplied to set state of.')
        return
    end
    if state ~= true and state ~= false then
        printf("Invalid state toggle")
        return
    end
    if args ~= nil then
        events.eventStates[event].args = args
    end
    events.eventStates[event].activated = state
end

function events.EventStateManager()
    for index, value in pairs(events.GetEventState()) do
        if value ~= nil then
            if value.activated then
                if value.args ~= nil then
                    value.callback(unpack(value.args()))
                else
                    value.callback()
                end
                events.eventStates[index].activated = false
            end
        end
    end
end

events.eventStates = {
    SetBotTitle = { activated = false, callback = SetBotTitleEventCallback, args = {} },
    SetBotSuffix = { activated = false, callback = SetBotSuffixEventCallback, args = {} },
    SetBotLastName = { activated = false, callback = SetBotLastNameEventCallback, args = {} },
    SpawnBotGroup = { activated = false, callback = spawnBotGroupEventCallback, args = {} },
    DeleteBot = { activated = false, callback = deleteBotEventCallback, args = {} },
    refreshBotList = {activated = false, callback = data.refreshBotListButton, args = nil}
}

return events
