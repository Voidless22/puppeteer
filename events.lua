local mq = require('mq')
local utils = require('utils')
local data = require('data')
local events = {}

 function events.getBotList(line, botIndex, botName, botLevel, botGender, botDetails)
    local race = utils.findMatchInTable(botDetails, utils.Races)
    local class = utils.findMatchInTable(botDetails, utils.Classes)
    
    printf('Bot List Event')

    data.SetBotData(botIndex, {
        Name = botName,
        Level = botLevel,
        Gender = botGender,
        Race = race,
        Class = class
    } )

end

return events