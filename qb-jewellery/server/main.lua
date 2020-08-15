ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Code

local timeOut = false

local alarmTriggered = false

RegisterServerEvent('qb-jewellery:server:setVitrineState')
AddEventHandler('qb-jewellery:server:setVitrineState', function(stateType, state, k)
    Config.Locations[k][stateType] = state
    TriggerClientEvent('qb-jewellery:client:setVitrineState', -1, stateType, state, k)
end)

RegisterServerEvent('qb-jewellery:server:vitrineReward')
AddEventHandler('qb-jewellery:server:vitrineReward', function()
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    local otherchance = math.random(1, 4)
    local odd = math.random(1, 4)

    if otherchance == odd then
        local item = math.random(1, #Config.VitrineRewards)
        local amount = math.random(Config.VitrineRewards[item]["amount"]["min"], Config.VitrineRewards[item]["amount"]["max"])
        if Player.addInventoryItem(Config.VitrineRewards[item]["item"], amount) then
        end
    else
        local amount = math.random(2, 4)
        if Player.addInventoryItem('10kgoldchain', amount) then
        end
    end
end)

RegisterServerEvent('qb-jewellery:server:setTimeout')
AddEventHandler('qb-jewellery:server:setTimeout', function()
    if not timeOut then
        timeOut = true
        TriggerEvent('qb-scoreboard:server:SetActivityBusy', "jewellery", true)
        Citizen.CreateThread(function()
            Citizen.Wait(Config.Timeout)

            for k, v in pairs(Config.Locations) do
                Config.Locations[k]["isOpened"] = false
                TriggerClientEvent('qb-jewellery:client:setVitrineState', -1, 'isOpened', false, k)
                TriggerClientEvent('qb-jewellery:client:setAlertState', -1, false)
                TriggerEvent('qb-scoreboard:server:SetActivityBusy', "jewellery", false)
            end
            timeOut = false
            alarmTriggered = false
        end)
    end
end)

RegisterServerEvent('qb-jewellery:server:PoliceAlertMessage')
AddEventHandler('qb-jewellery:server:PoliceAlertMessage', function(title, coords, blip)
    local src = source
    local alertData = {
        title = title,
        coords = {x = coords.x, y = coords.y, z = coords.z},
        description = "Possible robbery going on at the Vangelico Jeweler<br>Available camera's: 31, 32, 33, 34",
    }

    local Player = ESX.GetPlayerFromId(source)
        if Player ~= nil then 
            if Player.job.name == 'police' then
                if blip then
                    if not alarmTriggered then
                        TriggerClientEvent("qb-phone:client:addPoliceAlert", v, alertData)
                        TriggerClientEvent("qb-jewellery:client:PoliceAlertMessage", v, title, coords, blip)
                        alarmTriggered = true
                    end
                else
                    TriggerClientEvent("qb-phone:client:addPoliceAlert", v, alertData)
                    TriggerClientEvent("qb-jewellery:client:PoliceAlertMessage", v, title, coords, blip)
                end
            end
        end
end)

ESX.RegisterServerCallback('qb-jewellery:server:getCops', function(source, cb)
	local amount = 0
        local Player = ESX.GetPlayerFromId(source)
        if Player ~= nil then 
            if Player.job.name == 'police' then
                amount = amount + 1
            end
        end
	cb(amount)
end)