local mq = require('mq')
local utils = require('utils')
local data = require('data')
local events = {}


local function SetBotTitleButtonCallback(botTitle, botName)
    if botTitle == '' then return end

    mq.delay(5000, function() return mq.TLO.Spawn(botName)() end)
    if mq.TLO.Spawn(botName)() then
        mq.cmdf('/target "%s"', botName)
        mq.delay(250)
        mq.cmdf("/say ^title %s", botTitle:gsub(" ", "_"))
    end
end

local function deleteBotButtonCallback(botName)
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
        mq.cmdf('/say ^botlist')

    end
end


local function SetBotLastNameButtonCallback(botLastName, botName)
    if botLastName == '' then return end
    mq.delay(5000, function() return mq.TLO.Spawn(botName)() end)
    if mq.TLO.Spawn(botName)() then
        mq.cmdf('/target "%s"', botName)
        mq.delay(250)
        mq.cmdf("/say ^lastname %s", botLastName:gsub(" ", "_"))
    end
end

local function SetBotSuffixButtonCallback(botSuffix, botName)
    if botSuffix == '' then return end
    mq.delay(5000, function() return mq.TLO.Spawn(botName)() end)
    if mq.TLO.Spawn(botName)() then
        mq.cmdf('/target "%s"', botName)
        mq.delay(250)
        mq.cmdf("/say ^suffix %s", botSuffix:gsub(" ", "_"))
    end
end
local function spawnBotGroupButtonCallback(groupMembers)
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

function events.GetButtonState(button)
    if button ~= nil then
        return events.buttonStates[button]
    else
        return events.buttonStates
    end
end

function events.SetButtonState(button, state, args)
    if button == nil then
        printf('invalid event supplied to set state of.')
        return
    end
    if state ~= true and state ~= false then
        printf("Invalid state toggle")
        return
    end
    if args ~= nil then
        events.buttonStates[button].args = args
    end
    events.buttonStates[button].activated = state
end

function events.ButtonStateManager()
    for index, value in pairs(events.GetButtonState()) do
        if value ~= nil then
            if value.activated then
                if value.args ~= nil then
                    value.callback(unpack(value.args()))
                else
                    value.callback()
                end
                events.buttonStates[index].activated = false
            end
        end
    end
end

events.buttonStates = {
    SetBotTitle = { activated = false, callback = SetBotTitleButtonCallback, args = {} },
    SetBotSuffix = { activated = false, callback = SetBotSuffixButtonCallback, args = {} },
    SetBotLastName = { activated = false, callback = SetBotLastNameButtonCallback, args = {} },
    SpawnBotGroup = { activated = false, callback = spawnBotGroupButtonCallback, args = {} },
    DeleteBot = { activated = false, callback = deleteBotButtonCallback, args = {} },
}

return events
