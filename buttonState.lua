local mq = require('mq')
local imgui = require('ImGui')
local data = require('data')
local buttonCallbacks = require('buttonCallbacks')

local buttonState = {}

buttonState.buttonStateData = {
    SetBotTitle = { activated = false, callback = buttonCallbacks.SetBotTitleButtonCallback, args = {} },
    SetBotSuffix = { activated = false, callback = buttonCallbacks.SetBotSuffixButtonCallback, args = {} },
    SetBotLastName = { activated = false, callback = buttonCallbacks.SetBotLastNameButtonCallback, args = {} },
    SpawnBotGroup = { activated = false, callback = buttonCallbacks.spawnBotGroupButtonCallback, args = {} },
    DeleteBot = { activated = false, callback = buttonCallbacks.deleteBotButtonCallback, args = {} },

}

function buttonState.GetButtonStateData(buttonName)
    if buttonName ~= nil then
        return buttonState.buttonStateData[buttonName]
    else
        return buttonState.buttonStateData
    end
end

function buttonState.SetButtonState(button, state, args)
    if button == nil then
        printf('invalid Button supplied to set state of.')
        return
    end
    if args ~= nil then
        buttonState.buttonStateData[button].args = args
    end
    buttonState.buttonStateData[button].activated = state
end

function buttonState.FlipToggle(button)
    buttonState.buttonStateData[button].toggleState = not buttonState.buttonStateData[button].toggleState
end

function buttonState.InitDashbarButtons()
    local dashbarButtons = data.GetGlobalDashbarButtons()
    if dashbarButtons ~= nil then
        printf('dashbarButtons Found.')
        for index, value in ipairs(dashbarButtons) do
            buttonState.buttonStateData[string.format('%i-DashbarBtn', index)] = value
        end
    end
end

function buttonState.ConnectDashbarCallbacks()
    for _, button in pairs(buttonState.GetButtonStateData()) do
        if type(button.callback) == "string" then
            button.callback = buttonCallbacks.callbackRegistry[button.callback]
        end
        if type(button.negativeCallback) == "string" then
            button.negativeCallback = buttonCallbacks.callbackRegistry[button.negativeCallback]
        end
        if type(button.positiveCallback) == "string" then
            button.positiveCallback = buttonCallbacks.callbackRegistry[button.positiveCallback]
        end
    end
end

function buttonState.StateManager()
    for index, value in pairs(buttonState.GetButtonStateData()) do
        if value ~= nil and value.activated then
            -- okay this is a toggle button
            if value.toggleState ~= nil then
                -- is it off? let's call the negative callback, accounting for if an args table is supplied.
                if value.toggleState == false and value.negativeCallback ~= nil then
                    if value.negativeArgs ~= nil then
                        value.negativeCallback(unpack(value.negativeArgs()))
                    else
                        value.negativeCallback()
                    end
                    -- let's do the same for the positive callback
                elseif value.toggleState == true and value.positiveCallback ~= nil then
                    if value.positiveArgs ~= nil then
                        value.positiveCallback(unpack(value.positiveArgs()))
                    else
                        value.positiveCallback()
                    end
                end
            else
                -- okay this isn't a toggle button, just call the callback with/without args
                if value.args ~= nil then
                    value.callback(unpack(value.args()))
                else
                    value.callback()
                end
            end
            -- all done here, clean up activated state
            buttonState.SetButtonState(index, false)
        end
    end
end

return buttonState
