local mq = require('mq')
local utils = require('utils')
local data = require('data')
local events = {}


function SetBotTitleEventCallback(botTitle, botName)
    if botTitle == '' then return end

    mq.delay(5000, function() return mq.TLO.Spawn(botName)() end)
    if mq.TLO.Spawn(botName)() then
        mq.cmdf('/target "%s"', botName)
        mq.delay(250)
        mq.cmdf("/say ^title %s", botTitle:gsub(" ", "_"))
    end
end
function SetBotLastNameEventCallback(botLastName, botName)
    if botLastName == '' then return end
    mq.delay(5000, function() return mq.TLO.Spawn(botName)() end)
    if mq.TLO.Spawn(botName)() then
        mq.cmdf('/target "%s"', botName)
        mq.delay(250)
        mq.cmdf("/say ^lastname %s", botLastName:gsub(" ", "_"))
    end
end

function SetBotSuffixEventCallback(botSuffix, botName)
    if botSuffix == '' then return end
    mq.delay(5000, function() return mq.TLO.Spawn(botName)() end)
    if mq.TLO.Spawn(botName)() then
        mq.cmdf('/target "%s"', botName)
        mq.delay(250)
        mq.cmdf("/say ^suffix %s", botSuffix:gsub(" ", "_"))
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
    } )

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
    SetBotTitle = {activated = false, callback = SetBotTitleEventCallback, args = {} },
    SetBotSuffix = {activated = false, callback = SetBotSuffixEventCallback, args = {} },
    SetBotLastName = {activated = false, callback = SetBotLastNameEventCallback, args = {} }

}

return events