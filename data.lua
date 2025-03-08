local mq = require('mq')


local data = {}

data.BotNameList = {}
data.CharacterBots = {}

data.Compositions = {
    Groups = {},
    Raids = {}
}

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
    if data.CharacterBots[index].Title == '' and mq.TLO.Spawn(data.CharacterBots[index].Name)() then
        data.CharacterBots[index].Title = mq.TLO.Spawn(data.CharacterBots[index].Name).Title()
    end
    return data.CharacterBots[index].Title
end

function data.GetBotLastName(index)
    if data.CharacterBots[index].Surname == '' and mq.TLO.Spawn(data.CharacterBots[index].Name)() then
        data.CharacterBots[index].Surname = mq.TLO.Spawn(data.CharacterBots[index].Name).Surname()
    end
    return data.CharacterBots[index].Surname
end

function data.GetBotSuffix(index)
    if data.CharacterBots[index].Suffix == '' and mq.TLO.Spawn(data.CharacterBots[index].Name)() then
        data.CharacterBots[index].Suffix = mq.TLO.Spawn(data.CharacterBots[index].Name).Suffix()
    end
    return data.CharacterBots[index].Suffix
end

function data.GetGroupComposition(groupName)
    if not data.Compositions.Groups[groupName] then
        printf("Group: %s is missing.", groupName)
        return false
    else
        return data.Compositions.Groups[groupName]
    end
end

function data.GetGroupCompositionList()
    return data.Compositions.Groups
end


function data.SetGroupComposition(groupName, groupData)
    if data.Compositions.Groups[groupName] == nil then
        printf("Group Name %s is missing", groupName)
    else
        data.Compositions.Groups[groupName] = groupData
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
