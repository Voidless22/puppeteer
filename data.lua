local mq = require('mq')


local data = {}

data.BotNameList = {}
data.CharacterBots = {}

function data.initBotData(key, botData)
    if botData == nil then
        printf("Nill bot data")
    else
        print(botData.Name)
        data.CharacterBots[key] = botData
        data.BotNameList[key] = botData.Name
    end
end

function data.GetBotData(index)
    return data.CharacterBots[index]
end

function data.GetBotTitle(index)
    if mq.TLO.Spawn(data.CharacterBots[index].Name)() then
        data.CharacterBots[index].Title = mq.TLO.Spawn(data.CharacterBots[index].Name).Title()
        return data.CharacterBots[index].Title
    else
        return ''
    end
end

function data.GetBotLastName(index)
    if mq.TLO.Spawn(data.CharacterBots[index].Name)() then
        data.CharacterBots[index].Surname = mq.TLO.Spawn(data.CharacterBots[index].Name).Surname()
        return data.CharacterBots[index].Surname
    else
        return ''
    end
end

function data.GetBotSuffix(index)
    if mq.TLO.Spawn(data.CharacterBots[index].Name)() then
        data.CharacterBots[index].Suffix = mq.TLO.Spawn(data.CharacterBots[index].Name).Suffix()
        return data.CharacterBots[index].Suffix
    else
        return ''
    end
end


function data.RefreshData(index)
    data.GetBotTitle(index)
    data.GetBotLastName(index)
    data.GetBotSuffix(index)
    return data.CharacterBots[index]
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
