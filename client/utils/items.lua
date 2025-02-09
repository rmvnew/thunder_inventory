----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNCIONALIDADE DE ITENS DO INVENTARIO
-----------------------------------------------------------------------------------------------------------------------------------------
local oxygen = 0
local in_scuba = false
local attachedProps = {}

local function drawOxygenText()
    local textColor
    if oxygen > 50 then
        textColor = {0, 255, 0}
    elseif oxygen > 30 then
        textColor = {0, 0, 255}
    else
        textColor = {255, 0, 0}
    end
    drawTxt("VOCÊ POSSUI ~c~"..oxygen.."% ~w~ DE OXIGÊNIO.", 4, 0.5, 0.96, 0.50, table.unpack(textColor), 100)
end

local function updateUnderwaterStatus()
    local ped = GetPlayerPed(-1)
    if IsPedSwimmingUnderWater(ped) then
        if in_scuba then
            drawOxygenText()
            SetPedDiesInWater(ped, false)
            SetPedMaxTimeUnderwater(ped, 10.0)
            if oxygen <= 0 then
                drawTxt("~r~VOCÊ NÃO POSSUI MAIS OXIGÊNIO.", 4, 0.5, 0.96, 0.50, 255, 0, 0, 100)
                SetPedDiesInWater(ped, true)
                SetPedMaxTimeUnderwater(ped, 0.0)
                oxygen = 0
            end
        else
            SetPedMaxTimeUnderwater(ped, 10.0)
            SetPedDiesInWater(ped, true)
        end
    end
end

function API.setScuba(status)
    if status then
        attachProp("p_s_scuba_tank_s", 24818, -0.25, -0.25, 0.0, 180.0, 90.0, 0.0, 'tank')
        attachProp("p_s_scuba_mask_s", 12844, 0.0, 0.0, 0.0, 180.0, 90.0, 0.0, 'mask')
        in_scuba = true
        oxygen = 100
    else
        in_scuba = false
        for _, prop in pairs(attachedProps) do
            DeleteEntity(prop)
        end
        attachedProps = {}
    end
end

function API.checkScuba()
    return in_scuba
end

function attachProp(modelName, boneNumber, x, y, z, xR, yR, zR, propType)
    local model = GetHashKey(modelName)
    local bone = GetPedBoneIndex(GetPlayerPed(-1), boneNumber)

    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(100)
    end

    local prop = CreateObject(model, 1.0, 1.0, 1.0, true, true, false)
    AttachEntityToEntity(prop, GetPlayerPed(-1), bone, x, y, z, xR, yR, zR, true, true, false, false, 2, true)
    table.insert(attachedProps, prop)

    if propType == 'tank' then
        scubaTank = prop
    elseif propType == 'mask' then
        scubaMask = prop
    end
end

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        if IsPedSwimmingUnderWater(GetPlayerPed(-1)) then
            sleep = 5
            updateUnderwaterStatus()
        end
        Citizen.Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 5000
        if IsPedSwimmingUnderWater(GetPlayerPed(-1)) and in_scuba then
            oxygen = math.max(0, oxygen - 1)
        end
        Citizen.Wait(sleep)
    end
end)


-----------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE USAR BANDAGEM
-----------------------------------------------------------------------------------------------------------------------------------------
local bandagem = false
local tempoBandagem = 0
local oldHealth = 0

function API.useBandagem()
    bandagem = true
    tempoBandagem = 60
    oldHealth = GetEntityHealth(PlayerPedId())
end

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local health = GetEntityHealth(ped)
        local waitTime = 1000

        if bandagem then
            waitTime = 1000
            -- Cancelamento da bandagem caso a vida esteja cheia
            if health >= 400 then
                tempoBandagem = 0
                bandagem = false
                TriggerEvent("Notify", "negado", "<b>Você Não Pode Utilizar a [BANDAGEM]</b> Pois Sua Vida Está Cheia.", 4000)
            -- Cancelamento caso o tempo de bandagem tenha acabado
            elseif tempoBandagem <= 0 then
                tempoBandagem = 0
                bandagem = false
                TriggerEvent("Notify", "negado", "<b>Sua Bandagem acabou</b>", 5000)
            -- Cancelamento caso o jogador tenha sofrido dano
            elseif oldHealth > health then
                tempoBandagem = 0
                bandagem = false
                TriggerEvent("Notify", "negado", "<b>A [BANDAGEM]</b> Foi Cancelada Pois Você sofreu algum dano.", 6000)
            -- Cancelamento caso o jogador esteja com a saúde muito baixa ou morto
            elseif health <= 101 then
                tempoBandagem = 0
                bandagem = false
                TriggerEvent("Notify", "negado", "A Bandagem Foi Cancelada pois Você morreu.", 4000)
            else
                -- Aumenta a vida gradualmente enquanto estiver abaixo de SetEntityHealth
                if health < 400 then
                    SetEntityHealth(ped, math.min(health + 2, 400)) -- Limita a saúde máxima a 300
                end
            end

            -- Reduz o tempo da bandagem em cada ciclo
            tempoBandagem = tempoBandagem - 1
            oldHealth = health
        end

        Citizen.Wait(waitTime)
    end
end)



-----------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE USAR BURFLEX
-----------------------------------------------------------------------------------------------------------------------------------------
local burflex = false
local tempoBurflex = 30 -- Metade do tempo da bandagem (15 segundos, considerando 500ms por ciclo)
local oldHealthBurflex = 0
local burflexAcumulado = 0.0  -- Variável para acumular os pontos de cura fracionados

function API.useBurflex()
    burflex = true
    tempoBurflex = 30
    oldHealthBurflex = GetEntityHealth(PlayerPedId())
    burflexAcumulado = 0.0
end

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local health = GetEntityHealth(ped)
        local waitTime = 500 -- Intervalo de 500ms

        if burflex then
            -- Cancelamento se a vida já estiver cheia
            if health >= 400 then
                tempoBurflex = 0
                burflex = false
                TriggerEvent("Notify", "negado", "<b>Você Não Pode Utilizar o [BURFLEX]</b> Pois Sua Vida Está Cheia.", 4000)
            -- Cancelamento se o tempo acabar
            elseif tempoBurflex <= 0 then
                tempoBurflex = 0
                burflex = false
                TriggerEvent("Notify", "negado", "<b>Seu Burflex acabou</b>", 5000)
            -- Cancelamento se a saúde estiver muito baixa ou o jogador estiver morto
            elseif health <= 101 then
                tempoBurflex = 0
                burflex = false
                TriggerEvent("Notify", "negado", "O Burflex Foi Cancelado pois Você morreu.", 4000)
            else
                if health < 400 then
                    -- Acumula a cura fracionada (70 pontos divididos por 25 ciclos ≈ 2,8 por ciclo)
                    burflexAcumulado = burflexAcumulado + (70 / 25)
                    local incremento = math.floor(burflexAcumulado)
                    if incremento > 0 then
                        SetEntityHealth(ped, math.min(health + incremento, 400))
                        burflexAcumulado = burflexAcumulado - incremento
                    end
                end
            end

            -- Reduz o tempo do efeito e atualiza a saúde anterior
            tempoBurflex = tempoBurflex - 1
            oldHealthBurflex = health
        end

        Citizen.Wait(waitTime)
    end
end)


-----------------------------------------------------------------------------------------------------------------------------------------
-- REPAIRVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("repairVehicle")
AddEventHandler("repairVehicle",function(index,status)
	if NetworkDoesNetworkIdExist(index) then
		local v = NetToEnt(index)
		if DoesEntityExist(v) then
			local fuel = GetVehicleFuelLevel(v)
			if status then
				SetVehicleFixed(v)
				SetVehicleDeformationFixed(v)
			end
			SetVehicleBodyHealth(v,1000.0)
			SetVehicleEngineHealth(v,1000.0)
			SetVehiclePetrolTankHealth(v,1000.0)
			SetVehicleFuelLevel(v,fuel)
		end
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- LOCKPICKVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("vrp_inventory:lockpickVehicle")
AddEventHandler("vrp_inventory:lockpickVehicle",function(index)
	if NetworkDoesNetworkIdExist(index) then
		local v = NetToEnt(index)
		if DoesEntityExist(v) then
			SetEntityAsMissionEntity(v,true,true)
			if GetVehicleDoorsLockedForPlayer(v,PlayerId()) == 1 then
				SetVehicleDoorsLocked(v,false)
				SetVehicleDoorsLockedForAllPlayers(v,false)
			else
				SetVehicleDoorsLocked(v,true)
				SetVehicleDoorsLockedForAllPlayers(v,true)
			end
			SetVehicleLights(v,2)
			Wait(200)
			SetVehicleLights(v,0)
			Wait(200)
			SetVehicleLights(v,2)
			Wait(200)
			SetVehicleLights(v,0)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BLOCKBUTTONS
-----------------------------------------------------------------------------------------------------------------------------------------
local blockButtons = false
function API.blockButtons(status)
	blockButtons = status
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADBUTTONS
-----------------------------------------------------------------------------------------------------------------------------------------
-- Thread para desativar ações do jogador quando blockButtons estiver ativado
Citizen.CreateThread(function()
    while true do
        local timeDistance = 500
        if blockButtons then
            timeDistance = 4
            local controls = {
                73, 75, 29, 47, 105, 187, 189, 190, 188, 311, 245, 257, 288, 37
            }
            for _, control in ipairs(controls) do
                DisableControlAction(1, control, true)
            end
            DisablePlayerFiring(PlayerPedId(), true)
        end
        Citizen.Wait(timeDistance)
    end
end)

-- Thread para gerenciar armas quando o jogador está morto
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)  -- Checa a cada 100ms para reduzir o uso da CPU
        local playerPed = GetPlayerPed(-1)
        if IsEntityDead(playerPed) and not IsPedInAnyVehicle(playerPed, true) then
            SetPedDropsWeaponsWhenDead(playerPed, false)
        end
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE ENERGETICO
-----------------------------------------------------------------------------------------------------------------------------------------
local energetico = false

function API.setEnergetico(status)
	if status then
		SetRunSprintMultiplierForPlayer(PlayerId(),1.30)
		energetico = true
	else
		SetRunSprintMultiplierForPlayer(PlayerId(),1.0)
		RestorePlayerStamina(PlayerId(),1.0)
		energetico = false
	end
end



-----------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE ENCHER A GARRAFA
-----------------------------------------------------------------------------------------------------------------------------------------
function API.checkFountain()
	local ped = PlayerPedId()
	local coords = GetEntityCoords(ped)

	if DoesObjectOfTypeExistAtCoords(coords,0.7,GetHashKey("prop_watercooler"),true) or DoesObjectOfTypeExistAtCoords(coords,0.7,GetHashKey("prop_watercooler_dark"),true) then
		return true,"fountain"
	end

	if IsEntityInWater(ped) then
		return true,"floor"
	end

	return false
end

function API.startAnimHotwired()
	while not HasAnimDictLoaded("anim@amb@clubhouse@tutorial@bkr_tut_ig3@") do
		RequestAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
		Citizen.Wait(10)
	end
	TaskPlayAnim(PlayerPedId(),"anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer",3.0,3.0,-1,49,5.0,0,0,0)
end



-----------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE ENCHER A GARRAFA
-----------------------------------------------------------------------------------------------------------------------------------------
function API.checkFountain()
	local ped = PlayerPedId()
	local coords = GetEntityCoords(ped)

	if DoesObjectOfTypeExistAtCoords(coords,0.7,GetHashKey("prop_watercooler"),true) or DoesObjectOfTypeExistAtCoords(coords,0.7,GetHashKey("prop_watercooler_dark"),true) then
		return true,"fountain"
	end

	if IsEntityInWater(ped) then
		return true,"floor"
	end

	return false
end

function API.startAnimHotwired()
	while not HasAnimDictLoaded("anim@amb@clubhouse@tutorial@bkr_tut_ig3@") do
		RequestAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
		Citizen.Wait(10)
	end
	TaskPlayAnim(PlayerPedId(),"anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer",3.0,3.0,-1,49,5.0,0,0,0)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- REPARAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent('reparar')
AddEventHandler('reparar',function(vehicle)
	TriggerServerEvent("tryreparar",VehToNet(vehicle))
end)

RegisterNetEvent('repararMotor')
AddEventHandler('repararMotor',function(vehicle)
	TriggerServerEvent("tryrepararMotor",VehToNet(vehicle))
end)

RegisterNetEvent('syncreparar')
AddEventHandler('syncreparar',function(index)
	if NetworkDoesNetworkIdExist(index) then
		local v = NetToVeh(index)
		local fuel = GetVehicleFuelLevel(v)
		if DoesEntityExist(v) then
			if IsEntityAVehicle(v) then
                SetVehicleEngineHealth(v, 1000 + 0.0)
				SetVehicleFixed(v)
				SetVehicleDirtLevel(v,0.0)
				SetVehicleUndriveable(v,false)
				SetEntityAsMissionEntity(v,true,true)
				SetVehicleOnGroundProperly(v)
				SetVehicleFuelLevel(v,fuel)
			end
		end
	end
end)

RegisterNetEvent('syncrepararMotor')
AddEventHandler('syncrepararMotor',function(index)
	if NetworkDoesNetworkIdExist(index) then
		local v = NetToVeh(index)
		if DoesEntityExist(v) then
			if IsEntityAVehicle(v) then
                SetVehicleEngineHealth(v, 1000 + 0.0)
			end
		end
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- REPARAR PNEUS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent('repararpneus')
AddEventHandler('repararpneus',function(vehicle)
	if IsEntityAVehicle(vehicle) then
		TriggerServerEvent("tryrepararpneus",VehToNet(vehicle))
	end
end)

RegisterNetEvent('syncrepararpneus')
AddEventHandler('syncrepararpneus',function(index)
	if NetworkDoesNetworkIdExist(index) then
        local v = NetToEnt(index)
        if DoesEntityExist(v) then
            for i = 0,8 do
                SetVehicleTyreFixed(v,i)
            end
        end
    end
end)



