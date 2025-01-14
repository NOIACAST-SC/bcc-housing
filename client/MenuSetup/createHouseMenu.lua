---- Variables ----
local ownerId, houseRadius, doors, houseCoords, InvLimit, ownerSource, taxAmount = nil, nil, {}, nil, nil, nil, nil
Inmenu = false

AddEventHandler('bcc-housing:MenuClose', function()
    while true do
        Wait(5)
        if IsControlJustReleased(0, 0x156F7119) then
            if Inmenu then
                Inmenu = false
                MenuData.CloseAll() break
            end
        end
    end
end)

------ Main House Creation ------
function CreateHouseMenu()
    Inmenu = true
    TriggerEvent('bcc-housing:MenuClose')
    MenuData.CloseAll()
    local elements = {
        { label = _U("setOwner"), value = 'setowner', desc = _U("setOwner_desc") },
        { label = _U("setRadius"), value = 'setradius', desc = _U("setRadius_desc") },
        { label = _U("doorCreation"), value = 'doorcreation', desc = _U("doorCreation_desc") },
        { label = _U("houseCoords"), value = 'setHouseCoords', desc = _U("houseCoords_desc") },
        { label = _U("setInvLimit"), value = 'setInvLimit', desc = _U("setInvLimit_desc") },
        { label = _U("taxAmount"), value = 'settaxamount', desc = _U("taxAmount_desc") },
        { label = _U("Confirm"), value = 'confirm', desc = "" },
    }

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = _U("creationMenuName"),
            align = 'top-left',
            elements = elements,
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value == 'setowner' then
                PlayerList('CreateHouseMenu')
            elseif data.current.value == 'setradius' then
                local myInput = {
                    type = "enableinput",                                               -- don't touch
                    inputType = "input",                                                -- input type
                    button = _U("Confirm"),                                             -- button name
                    placeholder = _U("setRadius"),                               -- placeholder name
                    style = "block",                                                    -- don't touch
                    attributes = {
                        inputHeader = "",                                               -- header
                        type = "number",                                                -- inputype text, number,date,textarea ETC
                        pattern = "[0-9]",                                              --  only numbers "[0-9]" | for letters only "[A-Za-z]+"
                        title = _U("InvalidInput"),                                     -- if input doesnt match show this message
                        style = "border-radius: 10px; background-color: ; border:none;" -- style
                    }
                }
                TriggerEvent("vorpinputs:advancedInput", json.encode(myInput), function(result)
                    if tonumber(result) > 0 then
                        houseRadius = tonumber(result)
                        VORPcore.NotifyRightTip(_U("radiusSet"), 4000)
                    else
                        VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
                    end
                end)
            elseif data.current.value == 'doorcreation' then
                doorCreationMenu()
            elseif data.current.value == 'setHouseCoords' then
                houseCoords = GetEntityCoords(PlayerPedId())
                VORPcore.NotifyRightTip(_U("houseCoordsSet"), 4000)
            elseif data.current.value == 'setInvLimit' then
                local myInput = {
                    type = "enableinput",                                               -- don't touch
                    inputType = "input",                                                -- input type
                    button = _U("Confirm"),                                             -- button name
                    placeholder = _U("setInvLimit"),                               -- placeholder name
                    style = "block",                                                    -- don't touch
                    attributes = {
                        inputHeader = "",                                               -- header
                        type = "number",                                                -- inputype text, number,date,textarea ETC
                        pattern = "[0-9]",                                              --  only numbers "[0-9]" | for letters only "[A-Za-z]+"
                        title = _U("InvalidInput"),                                     -- if input doesnt match show this message
                        style = "border-radius: 10px; background-color: ; border:none;" -- style
                    }
                }
                TriggerEvent("vorpinputs:advancedInput", json.encode(myInput), function(result)
                    if tonumber(result) > 0 then
                        InvLimit = tonumber(result)
                        VORPcore.NotifyRightTip(_U("invLimitSet"), 4000)
                    else
                        VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
                    end
                end)
            elseif data.current.value == 'settaxamount' then
                local myInput = {
                    type = "enableinput",                                               -- don't touch
                    inputType = "input",                                                -- input type
                    button = _U("Confirm"),                                             -- button name
                    placeholder = _U("taxAmount"),                               -- placeholder name
                    style = "block",                                                    -- don't touch
                    attributes = {
                        inputHeader = "",                                               -- header
                        type = "number",                                                -- inputype text, number,date,textarea ETC
                        pattern = "[0-9]",                                              --  only numbers "[0-9]" | for letters only "[A-Za-z]+"
                        title = _U("InvalidInput"),                                     -- if input doesnt match show this message
                        style = "border-radius: 10px; background-color: ; border:none;" -- style
                    }
                }
                TriggerEvent("vorpinputs:advancedInput", json.encode(myInput), function(result)
                    if tonumber(result) > 0 then
                        taxAmount = tonumber(result)
                        VORPcore.NotifyRightTip(_U("taxAmountSet"), 4000)
                    else
                        VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
                    end
                end)
            elseif data.current.value == 'confirm' then
                MenuData.CloseAll()
                TriggerServerEvent('bcc-housing:CreationDBInsert', ownerId, houseRadius, doors, houseCoords, InvLimit, ownerSource, taxAmount)
                doors, ownerId, houseCoords, houseRadius, ownerSource = nil, nil, nil, nil, nil
                VORPcore.NotifyRightTip(_U("houseCreated"), 4000)
            end
        end)
end

--------- Show the player list credit to vorp admin for this
function doorCreationMenu()
    Inmenu = false
    local doorMenuElements = {}

    MenuData.CloseAll()

    if #doorMenuElements == 0 or nil then
        table.insert(doorMenuElements, { label = _U("createDoor"), value = 'doorcreation', desc = "" })
    end
    for k, v in pairs(doors) do
        doorMenuElements[#doorMenuElements + 1] = {
            label = _U("doorId") .. v,
            value = "door" .. k,
            desc = "" .. "<span style=color:MediumSeaGreen;> ",
            info = v
        }
    end

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title      = _U("creationMenuName"),
            subtext    = _U("createdDoorList"),
            align      = 'top-left',
            elements   = doorMenuElements,
            lastmenu   = 'CreateHouseMenu',
            itemHeight = "4vh",
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value == 'doorcreation' then
                MenuData.CloseAll()
                local door = exports['bcc-doorlocks']:createDoor()
                table.insert(doors, door)
                while true do
                    Wait(10)
                    if #MenuData.GetOpenedMenus() <= 0 then
                        doorCreationMenu() break
                    end
                end
            end
        end)
end

--------- Show the player list credit to vorp admin for this
function PlayerList(lastmenu)
    MenuData.CloseAll()
    Inmenu = false
    local elements = {}
    local players = GetPlayers()

    table.sort(players, function(a, b)
        return a.serverId < b.serverId
    end)

    for k, playersInfo in pairs(players) do
        elements[#elements + 1] = {
            label = playersInfo.PlayerName .. "<br> " .. _U("CharacterStaticId") .. ' ' .. playersInfo.staticid,
            value = "players" .. k,
            desc = _U("StaticId") .. "<span style=color:MediumSeaGreen;> ",
            info = playersInfo
        }
    end

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title      = _U("creationMenuName"),
            subtext    = _U("StaticId_desc"),
            align      = 'top-left',
            elements   = elements,
            lastmenu   = lastmenu,
            itemHeight = "4vh",
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value then
                if lastmenu == 'CreateHouseMenu' then
                    ownerId = data.current.info.staticid
                    ownerSource = data.current.info.serverId
                    VORPcore.NotifyRightTip(_U("OwnerSet"), 4000)
                    MenuData.CloseAll()
                    CreateHouseMenu()
                elseif lastmenu == 'HousingManagementMenu' then
                    VORPcore.NotifyRightTip(_U("givenAccess"), 4000)
                    TriggerServerEvent('bcc-housing:NewPlayerGivenAccess', data.current.info.staticid, HouseId, data.current.info.serverId)
                end
            end
        end)
end

RegisterNetEvent('bcc-housing:ClientRecHouseLoad', function(recOwnerSource) --Used to load houses after given one or given access so you dont have to relog to gain access
    TriggerServerEvent('bcc-housing:CheckIfHasHouse', recOwnerSource)
end)