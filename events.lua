local mq = require('mq')
local utils = require('utils')
local data = require('data')
local events = {}

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
        Stance = {name = ''},
        Title = '',
        Surname = '',
        Suffix = ''
    })
end

function events.ItemUpgradeMsgEvent(line, name, itemSlot, currentBotItemLink)
    local botDataIndex
    local msgLinks = mq.ExtractLinks(line)
    local botName = mq.ParseDialogLink(name).text
    for index, value in ipairs(data.GetBotData()) do
        if botName == value.Name then
            printf('found bot')
            botDataIndex = index
        end
    end
    data.AddToPotentialBotItemUpgrades({ botName = botName, upgradeItem = mq.TLO.Cursor.ID(), itemSlot = itemSlot, itemName = msgLinks[2].text, line = line })
end
function events.GetStanceInfo(line, name, stanceName, stanceID)
    local botDataIndex
    for index, value in ipairs(data.GetBotData()) do
        if name == value.Name then
            printf('found bot')
            botDataIndex = index
        end
    end
    data.SetBotStanceData(botDataIndex, {name = stanceName, id = stanceID})
end


return events
