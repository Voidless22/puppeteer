local mq = require('mq')


local data = {}

data.BotNameList = {}
data.CharacterBots = {}

function data.SetBotData(key, botData)
    if botData == nil then
        printf("Nill bot data")
    else
        print(botData.Name)
        data.CharacterBots[tonumber(key)] = botData
        data.BotNameList[tonumber(key)] = botData.Name
    end
end

function data.GetBotData(index)
return data.CharacterBots[tonumber(index)]
end


function data.GetBotNameList()
    return data.BotNameList
end

 function data.refreshBotListButton()
    mq.cmd('/say ^botlist')
    mq.delay(500)
    mq.doevents()
end


return data
