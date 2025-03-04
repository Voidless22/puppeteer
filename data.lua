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

function data.GetBotTitle(index)
    if mq.TLO.Spawn(data.CharacterBots[tonumber(index)].Name)() then
        data.CharacterBots[tonumber(index)].Title = mq.TLO.Spawn(data.CharacterBots[tonumber(index)].Name).Title()
        return data.CharacterBots[tonumber(index)].Title
    else
        return ''
    end
end

function data.GetBotLastName(index)
    if mq.TLO.Spawn(data.CharacterBots[tonumber(index)].Name)() then
        data.CharacterBots[tonumber(index)].Surname = mq.TLO.Spawn(data.CharacterBots[tonumber(index)].Name).Surname()
        return data.CharacterBots[tonumber(index)].Surname
    else
        return ''
    end
end

function data.GetBotSuffix(index)
    if mq.TLO.Spawn(data.CharacterBots[tonumber(index)].Name)() then
        data.CharacterBots[tonumber(index)].Suffix = mq.TLO.Spawn(data.CharacterBots[tonumber(index)].Name).Suffix()
        return data.CharacterBots[tonumber(index)].Suffix
    else
        return ''
    end
end


function data.RefreshData(index)
    data.GetBotTitle(index)
    data.GetBotLastName(index)
    data.GetBotSuffix(index)
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
