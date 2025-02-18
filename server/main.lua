Tunnel = module("vrp", "lib/Tunnel")
Proxy = module("vrp", "lib/Proxy")
Tools = module("vrp","lib/Tools")
Resource = GetCurrentResourceName()
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
RegisterTunnel = {}
Tunnel.bindInterface(Resource, RegisterTunnel)



local arena = Tunnel.getInterface("thunder_arena")
local func = exports["vrp"]

vTunnel = Tunnel.getInterface(Resource)

local idgens = Tools.newIDGenerator()

local vehList = {}

local OpennedVehicle = {}

local OpennedOrg = {}

local OpennedChestUser = {}

local OpennedHouse = {}

dataVehicle = {}

dataHouseChest = {}

dataOrgChest = {}

vRP.prepare("vRP/get_portaLuvas","SELECT portaluvas FROM vrp_user_veiculos WHERE user_id = @user_id AND veiculo = @veiculo")
vRP.prepare("vRP/update_portaLuvas","UPDATE vrp_user_veiculos SET portaluvas = @portaluvas WHERE user_id = @user_id AND veiculo = @veiculo")
vRP.prepare("vRP/get_portaMalas","SELECT portamalas FROM vrp_user_veiculos WHERE user_id = @user_id AND veiculo = @veiculo")
vRP.prepare("vRP/update_portaMalas","UPDATE vrp_user_veiculos SET portamalas = @portamalas WHERE user_id = @user_id AND veiculo = @veiculo")

local classWeapons = {
	["WEAPON_SNSPISTOL_MK2"] = "PISTOLAS",
	["WEAPON_PISTOL_MK2"] = "PISTOLAS",
	["WEAPON_COMBATPISTOL"] = "PISTOLAS",
	["WEAPON_HEAVYPISTOL"] = "PISTOLAS",
	["WEAPON_PISTOL50"] = "PISTOLAS",
	["WEAPON_GUSENBERG"] = "SEMI-RIFLE",
	["WEAPON_MACHINEPISTOL"] = "SEMI-RIFLE",
	["WEAPON_SMG_MK2"] = "SEMI-RIFLE",
	["WEAPON_SMG"] = "SEMI-RIFLE",
	["WEAPON_ASSAULTSMG"] = "SEMI-RIFLE",
	["WEAPON_COMBATPDW"] = "SEMI-RIFLE",
	["WEAPON_SAWNOFFSHOTGUN"] = "SHOTGUN",
	["WEAPON_PUMPSHOTGUN_MK2"] = "SHOTGUN",
	["WEAPON_ASSAULTRIFLE"] = "RIFLE",
	["WEAPON_COMBATMG_MK2"] = "RIFLE",
	["WEAPON_ASSAULTRIFLE_MK2"] = "RIFLE",
	["WEAPON_SPECIALCARBINE_MK2"] = "RIFLE",
	["WEAPON_CARBINERIFLE"] = "RIFLE",
	["WEAPON_SPECIALCARBINE"] = "RIFLE",
	["WEAPON_STUNGUN"] = "STUNGUN",
}

vRP.prepare("sjr/insertLog","INSERT INTO sjr_logs (nome,passaporte,cargo,bau,item,qtd,acao) VALUES (@nome,@passaporte,@cargo,@bau,@item,@qtd,@acao)")
vRP.prepare("vRP/get_alltable","SELECT * FROM vrp_chests")
vRP.prepare("vRP/addChest","INSERT INTO vrp_chests (permiss,name,x,y,z,weight) VALUES (@permiss,@name,@x,@y,@z,@weight)")

vRP.prepare("vRP/deleteChest","DELETE FROM vrp_chests WHERE name = @name")

AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
    if source then
        vTunnel.loadChests(source,Chests)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATE CHEST
-----------------------------------------------------------------------------------------------------------------------------------------
-- RegisterCommand('createChest',function(source, args, rawCommand)
RegisterCommand('criarbau',function(source, args, rawCommand)
	local user_id = vRP.getUserId(source)
	if user_id and vRP.hasPermission(user_id,"developer.permissao") then
		local x,y,z = vRPclient.getPosition(source)

		local nome = vRP.prompt(source,"Nome do chest?","")
		if nome == "" then
			return
		end

		local perm = vRP.prompt(source,"Permissao do chest?","")
		if perm == "" then
			return
		end

		local tamanho = vRP.prompt(source,"Tamanho do chest?","")
		if tamanho == "" then
			return
		end

		vTunnel.addChest(-1,nome, { coords = vec3(x,y,z), weight = parseInt(tamanho), permission = perm } )
        Chests[nome] = { coords = vec3(x,y,z), weight = parseInt(tamanho), permission = perm }
		vRP.execute("vRP/addChest", { permiss = perm, name = nome, x = x, y = y, z = z, weight = parseInt(tamanho) })
        TriggerClientEvent("Notify", source, "sucesso", "Voce criou o bau "..nome..".", 5000)
	end
end)


RegisterServerEvent("foxzin:createChest")
AddEventHandler("foxzin:createChest", function(source)
    local user_id = vRP.getUserId(source)
    local x, y, z = vRPclient.getPosition(source)

    local nome = vRP.prompt(source, "Nome do chest?", "")
    if nome == "" then
        return
    end

    local perm = vRP.prompt(source, "Permissao do chest? Ex: perm.grota Ex lider: perm.lidergrota ", "")
    if perm == "perm.grota" then
        return
    end

    local tamanho = 5000 

    vTunnel.addChest(-1, nome, { coords = vec3(x, y, z), weight = tamanho, permission = perm })
    Chests[nome] = { coords = vec3(x, y, z), weight = tamanho, permission = perm }
    vRP.execute("vRP/addChest", { permiss = perm, name = nome, x = x, y = y, z = z, weight = tamanho })
end)


RegisterServerEvent("foxzin:blib")
AddEventHandler("foxzin:blib", function(source)
    local user_id = vRP.getUserId(source)
    if not user_id then
        TriggerClientEvent("Notify", source, "erro", "Não foi possível identificar o usuário.", 5000)
        return
    end

    local x, y, z = vRPclient.getPosition(source)

    local nome = vRP.prompt(source, "Nome da Organização?", "")
    if nome == "" then
        TriggerClientEvent("Notify", source, "erro", "Você deve fornecer um nome para a organização.", 5000)
        return
    end


    local localiza = vRP.prompt(source, "Localização ou (CDS) ONDE O BLIB FICARÁ?", "")
    if localiza == "" then
        TriggerClientEvent("Notify", source, "erro", "Você deve fornecer uma localização ou permissão.", 5000)
        return
    end

    TriggerClientEvent("Notify", source, "sucesso", "Aguarde até o próximo reinício da cidade para completar essa operação. Seu pedido já esta salvo um desenvolvedor ira atender a essa instalação", 9000)

    vTunnel.addloja(-1, nome, {
        coords = vec3(x, y, z),
        permission = localiza
    })
    
    Chests[nome] = {
        coords = vec3(x, y, z),
        permission = localiza
    }

    print(string.format("Executando query com: user_id=%d, permiss=%s, name=%s, coords=(%f, %f, %f)",
    user_id, localiza, nome, x, y, z))

    local query = [[
        INSERT INTO lojas (user_id, permiss, name, x, y, z) 
        VALUES (@user_id, @permiss, @name, @x, @y, @z);
    ]]


    local params = {
        user_id = user_id,
        permiss = localiza,
        name = nome,
        x = x,
        y = y,
        z = z
    }

    MySQL.Async.execute(query, params, function(affectedRows)
        if affectedRows > 0 then
            print("Loja salva com sucesso!")
        else
            print("Erro ao salvar loja no banco de dados.")
        end
    end)

    print(string.format("Usuário ID %d adicionou uma nova loja: %s (Localização: %s)", user_id, nome, localiza))
end)




-- RegisterCommand('deleteChest',function(source, args, rawCommand)
RegisterCommand('deletarbau',function(source, args, rawCommand)
	local user_id = vRP.getUserId(source)
	if user_id and vRP.hasPermission(user_id,"developer.permissao") then
		local x,y,z = vRPclient.getPosition(source)

		local nome = vRP.prompt(source,"Nome do chest?","")
		if nome == "" then
			return
		end
        if Chests[nome] then
            Chests[nome] = nil
            vTunnel.loadChests(-1,Chests )
            vRP.execute("vRP/deleteChest", { name = nome })

            TriggerClientEvent('Notify',source,'aviso', "Você deletou o bau "..nome, 5000)
        else
            TriggerClientEvent('Notify',source,'negado', "Esse bau que você informou não existe.", 5000)
        end
	end
end)

RegisterTunnel.getInventory = function()
    local source = source
    local user_id = vRP.getUserId(source)
    local identity = vRP.getUserIdentity(user_id)

    if user_id then
        local inv = vRP.getInventory(user_id)
        local amountMoc = vRP.getMochilaAmount(user_id)
        
        if inv then
            local inventory = {}

            for k, v in pairs(inv) do
                if Items[v.item] then
                    -- Verifica se a quantidade é menor ou igual a 0 ou se o item não é válido
                    if parseInt(v["amount"]) <= 0 or Items[v.item] == nil then
                        vRP.removeInventoryItem(user_id, v.item, parseInt(v["amount"]))
                    else
                        -- Garante que a quantidade é um número válido
                        v["amount"] = parseInt(v["amount"])
                        v["name"] = Items[v["item"]].name
                        v["peso"] = Items[v["item"]].weight
                        v["index"] = v["item"]
                        v["key"] = v["item"]
                        v["slot"] = k

                        -- Adiciona o item ao inventário
                        inventory[k] = v
                    end
                end
            end

            -- Cálculo do peso total e max_weight
            local totalWeight = vRP.computeInvWeight(user_id) + amountMoc * Items["mochila"].weight -- Supondo que o peso da mochila é armazenado em Items
            return {
                inventory = inventory,
                weight = totalWeight,
                max_weight = vRP.getInventoryMaxWeight(user_id)
            }
        end
    end
end


RegisterTunnel.getWeapons = function()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        return vRPclient.getWeapons(source)
    end
end

function getWeaponMuni(weapon)
    for k,v in pairs(weapon_ammos) do
		for l,w in pairs(v) do
            if w == weapon then
                return k
	        end
		end
    end
end

RegisterTunnel.storeWeapons = function(weapon)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if not vRP.checkPatrulhamento(user_id) then
            local weapons = vRPclient.getWeapons(source)
            local mensagem = ''
            for k,v in pairs(weapon) do
                if weapons[v] then
                    if v == "WEAPON_COMBATPDW" or v == "WEAPON_SPECIALCARBINE" or v == "WEAPON_COMBATPISTOL" or v == "WEAPON_STUNGUN" or v == "WEAPON_FLASHLIGHT" or v == "WEAPON_NIGHTSTICK" then
                    else
                        vRP.giveInventoryItem(user_id, v, 1, true)
                        if weapons[v].ammo > 0 then
                            local ammo = string.gsub(v, "WEAPON_", "AMMO_")
                            vRP.giveInventoryItem(user_id, ammo, weapons[v].ammo, true)
                        end
                        if weapons[v].ammo > 0 then
                            mensagem = mensagem .. "(Arma: " .. v .. " Municao: " .. weapons[v].ammo .. "x) - "
                        else
                            mensagem = mensagem .. "(Arma: " .. v .. " Municao: 0x) - "
                        end
                        weapons[v] = nil
                    end 
                else
                    return { error = "Você não possui essa arma." }
                end
            end
            vRPclient.replaceWeapons(source, weapons)
            vRP.sendLog("GARMAS", "O ID " .. user_id .. " guardou  [ " .. mensagem .. " ] ")
            return { success = "Você guardou seu armamento na mochila." }
        else
            TriggerClientEvent('Notify',source,'negado', "Você não pode guardar armas em patrulhamento.", 5000)
            return { error = "Você não pode guardar armas em patrulhamento." }
        end
    end
end

RegisterTunnel.swapSlot = function(slot, amount, targetslot)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
        local inv = vRP.getInventory(user_id)
        if inv[targetslot] then
            if inv[targetslot].item ~= inv[slot].item then
                if vRP.tryGetInventoryItem(user_id, inv[targetslot].item, inv[targetslot].amount, false, targetslot) then
                    if vRP.tryGetInventoryItem(user_id, inv[slot].item, inv[slot].amount, false, slot) then
                        vRP.giveInventoryItem(user_id, inv[targetslot].item, inv[targetslot].amount, false, slot)
                        vRP.giveInventoryItem(user_id, inv[slot].item, inv[slot].amount, false, targetslot)
                        return { error = "Item Com sucesso." }
                    end
                end
            else
                if vRP.tryGetInventoryItem(user_id, inv[slot].item, amount, false, slot) then
                    vRP.giveInventoryItem(user_id, inv[slot].item, amount, false, targetslot)
                    return { error = "Item Com sucesso." }
                end
            end
        else
            if vRP.tryGetInventoryItem(user_id, inv[slot].item, amount, false, slot) then
                vRP.giveInventoryItem(user_id, inv[slot].item, amount, false, targetslot)
                return { error = "Item Com sucesso." }
            end
        end
        return false
	end
end

RegisterTunnel.sendItem = function(slot, amount)
    local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
        local inv = vRP.getInventory(user_id)
        local nplayer = vRPclient.getNearestPlayer(source, 3)
        if not inv[slot] then return end
        if nplayer then
            local item = inv[slot].item
            local nuser_id = vRP.getUserId(nplayer)
            if vRP.computeInvWeight(nuser_id) + vRP.getItemWeight(tostring(item)) * parseInt(amount) <= vRP.getInventoryMaxWeight(nuser_id) then
                if item == "money" or item == "dinheirosujo" then
                    if amount >= 15000000 then
                        vRP.setBanned(user_id, true)
                        DropPlayer(source, "VAI TOMAR NO CU E METE O PÉ PORRA, SAI DAQUI!")
                        vRP.sendLog("ENVIAR","@everyone | O ID " ..user_id .." enviou o item " ..vRP.getItemName(item) .." na quantidade de " .. amount .. "x para o id " .. nuser_id .. " (SUSPEITO HACK)")
                    elseif amount >= 500000 then
                        if vRP.tryGetInventoryItem(user_id, item, parseInt(amount), true, slot) then
                            func:setBlockCommand(user_id, 5)
							vRPclient._CarregarObjeto(source,"mp_safehouselost@","package_dropoff","prop_paper_bag_small",16,28422)
							Citizen.Wait(3000)
							vRPclient._DeletarObjeto(source)
							vRP.giveInventoryItem(nuser_id, item, parseInt(amount), true)
                            vRPclient._playAnim(nplayer,true,{{"mp_common","givetake1_a"}},false)
                            vRP.sendLog("ENVIAR","@everyone | O ID " ..user_id .." enviou o item " ..vRP.getItemName(item) .. " na quantidade de " .. amount .. "x para o id " ..nuser_id .. ".")
                            return { success = "Você enviou com sucesso" }
                        end
                    else
                        if vRP.tryGetInventoryItem(user_id, item, parseInt(amount), true, slot) then
                            func:setBlockCommand(user_id, 5)
                            vRPclient._CarregarObjeto(source,"mp_safehouselost@","package_dropoff","prop_paper_bag_small",16,28422)
							Citizen.Wait(3000)
							vRPclient._DeletarObjeto(source)
                            vRP.giveInventoryItem(nuser_id, item, parseInt(amount), true)
                            vRPclient._playAnim(nplayer,true,{{"mp_common","givetake1_a"}},false)
                            vRP.sendLog("ENVIAR","O ID " ..user_id .." enviou o item " ..vRP.getItemName(item) .. " na quantidade de " .. amount .. "x para o id " ..nuser_id .. ".")
                            return { success = "Você enviou com sucesso" }
                        end
                    end


                elseif item == "WEAPON_PISTOL_MK2" or item == "WEAPON_SPECIALCARBINE_MK2" or item == "WEAPON_ASSAULTRIFLE_MK2" then
                    if amount >= 9 then
                        if vRP.tryGetInventoryItem(user_id, item, parseInt(amount), true, slot) then
                            func:setBlockCommand(user_id, 5)
                            vRPclient._CarregarObjeto(source,"mp_safehouselost@","package_dropoff","prop_paper_bag_small",16,28422)
							Citizen.Wait(3000)
							vRPclient._DeletarObjeto(source)
                            vRP.giveInventoryItem(nuser_id, item, parseInt(amount), true)
                            vRPclient._playAnim(nplayer,true,{{"mp_common","givetake1_a"}},false)
                            vRP.sendLog("ENVIAR","@everyone | O ID " ..user_id .." enviou o item " ..vRP.getItemName(item) .. " na quantidade de " .. amount .. "x para o id " ..nuser_id .. ".")
                            return { success = "Você enviou com sucesso" }
                        end
                    else
                        if vRP.tryGetInventoryItem(user_id, item, parseInt(amount), true, slot) then
                            func:setBlockCommand(user_id, 5)
                            vRPclient._CarregarObjeto(source,"mp_safehouselost@","package_dropoff","prop_paper_bag_small",16,28422)
							Citizen.Wait(3000)
							vRPclient._DeletarObjeto(source)
                            vRP.giveInventoryItem(nuser_id, item, parseInt(amount), true)
                            vRPclient._playAnim(nplayer,true,{{"mp_common","givetake1_a"}},false)
                            vRP.sendLog("ENVIAR","O ID " ..user_id .." enviou o item " ..vRP.getItemName(item) .. " na quantidade de " .. amount .. "x para o id " ..nuser_id .. ".")
                            return { success = "Você enviou com sucesso" }
                        end
                    end


                elseif vRP.tryGetInventoryItem(user_id, item, parseInt(amount), true, slot) then
                    func:setBlockCommand(user_id, 3)
                    vRPclient._CarregarObjeto(source,"mp_safehouselost@","package_dropoff","prop_paper_bag_small",16,28422)
					Citizen.Wait(3000)
					vRPclient._DeletarObjeto(source)
                    vRP.giveInventoryItem(nuser_id, item, parseInt(amount), true)
                   vRPclient._playAnim(nplayer,true,{{"mp_common","givetake1_a"}},false)
                    vRP.sendLog("ENVIAR","O ID " ..user_id .." enviou o item " ..vRP.getItemName(item) .. " na quantidade de " .. amount .. "x para o id " .. nuser_id .. ".")
                    return { success = "Você enviou com sucesso" }
                end
            else
                TriggerClientEvent("Notify", source, "negado", "Mochila do jogador cheia.", 6000)
                    return { error = "Mochila do jogador cheia." }
            end
        else
            TriggerClientEvent("Notify", source, "negado", "Nenhum jogador próximo.", 6000)
            return { error = "Nenhum jogador próximo." }
        end
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES DE UTILIZAÇÃO DE ITENS INVENTÁRIO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function play_eat(source, tipo, segundos)
	local prop = ""
	-- COMIDAS
    if tipo == "pao" then
        prop = "prop_food_burg2"
    elseif tipo == "sanduiche" then
        prop = "prop_cs_burger_01"
    elseif tipo == "pizza" then
        prop = "prop_taco_01"
    elseif tipo == "donut" then
        prop = "prop_amb_donut"
    elseif tipo == "marmita" then
        prop = "prop_taco_01"
    elseif tipo == "coxinha" then
        prop = "prop_food_cb_nugets"
    elseif tipo == "pipoca" then
        prop = "mah_popcorn"
    elseif tipo == "taco" then
        prop = "mah_taco"
    elseif tipo == "temaki" then
        prop = "mah_temaki"
    elseif tipo == "morango" then
        prop = "mah_morango"
    elseif tipo == "paodequeijo" then
        prop = "paodequeijo"
    elseif tipo == "laranja" then
        prop = "mah_laranja"
    elseif tipo == "trakinas" then
        prop = "mah_trakinas"
    elseif tipo == "frango" then
        prop = "mah_frango"
    elseif tipo == "pirulito" then
        prop = "mah_pirulito"
    elseif tipo == "doce" then
        prop = "mah_doce"
    elseif tipo == "espeto" then
        prop = "mah_espeto"
    elseif tipo == "bolo" then
        prop = "mah_scake"
    elseif tipo == "croissant" then
        prop = "mah_croissant"
    elseif tipo == "batata" then
        prop = "mah_batata"
    elseif tipo == "brigadeiro" then
        prop = "mah_brigadeiro"
    elseif tipo == "pastel" then
        prop = "mah_pastel"
    elseif tipo == "sorvete" then
        prop = "bag_sorvete"
    elseif tipo == "chocolate" then
        prop = "mah_chocolate"
    elseif tipo == "laranja" then
        prop = "mah_laranja"
    elseif tipo == "trakinas" then
        prop = "mah_trakinas"
    elseif tipo == "doce" then
        prop = "mah_doce"
    else tipo = "hamburguer"
        prop = "prop_cs_burger_01"
    end
    
	vRPclient._CarregarObjeto(source,"mp_player_inteat@burger","mp_player_int_eat_burger",prop,49,60309)
    SetTimeout(segundos * 1000, function() 
        vRPclient._DeletarObjeto(source)
        vRPclient._stopAnim(source, false)
    end)
end

function play_drink(source, tipo, segundos)
	local prop = ""
	-- BEBIDAS
	if tipo == "energetico" then
		prop = "prop_energy_drink"
	elseif tipo == "agua" then
		prop = "prop_ld_flow_bottle"
	elseif tipo == "cafe" then
		prop = "prop_fib_coffee"
	elseif tipo == "cocacola" then
		prop = "ng_proc_sodacan_01a"
	elseif tipo == "sucol" then
		prop = "ng_proc_sodacan_01b"
	elseif tipo == "sucol2" then
		prop = "ng_proc_sodacan_01b"
	elseif tipo == "sprunk"then
		prop = "ng_proc_sodacan_01b"

	-- BEBIDAS ALCOLICAS
	elseif tipo == "cerveja" then
		prop = "prop_amb_beer_bottle"
	elseif tipo == "whisky" then
		prop = "prop_drink_whisky"
	elseif tipo == "vodka" then
		prop = "p_whiskey_notop" 
	elseif tipo == "pinga" then
		prop = "p_whiskey_notop" 
	elseif tipo == "corote" then
		prop = "ng_proc_sodacan_01b"
	elseif tipo == "absinto" then
		prop = "prop_drink_whisky"
	elseif tipo == "skolb" then
		prop = "ng_proc_sodacan_01b"
	else
		prop = "prop_ld_flow_bottle"
	end
	
	vRPclient._CarregarObjeto(source,"mp_player_intdrink","loop_bottle",prop,49,60309)
    SetTimeout(segundos*1000, function() 
        vRPclient._DeletarObjeto(source)
        vRPclient._stopAnim(source, false)
    end)
end



RegisterTunnel.useItem = function(slot, amount)
    local source = source
    local user_id = vRP.getUserId(source)

    if user_id then
        local inv = vRP.getInventory(user_id)

        if inv then
            local invSlot = inv[tostring(slot)]
            if not invSlot or not invSlot.item then
                print("Slot inválido ou item não encontrado.")
                return
            end

            local item = invSlot.item

            if not Items[item] then
                print("Item não encontrado em Items: ", item)
                return
            end

            local itemType = Items[item].tipo
            print("USOU ITEM", item, itemType)

            if itemType then
                if amount == nil or amount <= 0 then
                    amount = vRP.getInventoryItemAmount(user_id, item)
                end

                -- Verifica se o tipo de item é "usar"
                if itemType == "usar" then

                    if item == "vale_carro" then
                    
                        local user_id = vRP.getUserId(source)
                        if user_id then
                            if vRP.tryGetInventoryItem(user_id, "vale_carro", 1, true, slot) then
                                TriggerClientEvent('closeInventory', source)
                                TriggerClientEvent("progress", source, 5000, "Resgatando veículo...")
                                vTunnel.blockButtons(source, true)
                                func:setBlockCommand(user_id, 5)
                    
                                SetTimeout(5000, function()
                                    vTunnel.blockButtons(source, false)
                    
                                    -- Lógica para adicionar o carro à garagem
                                    local veiculo = "boxville3"
                                    local placa = vRP.gerarPlaca()
                                    local ipva = os.time()
                                    local expired = "{}"
                    
                                    vRP.execute("vRP/inserir_veh", {
                                        veiculo = veiculo,
                                        user_id = user_id,
                                        placa = placa,
                                        ipva = ipva,
                                        expired = expired
                                    })
                    
                                    TriggerClientEvent("Notify", source, "sucesso", "Você resgatou um <b>"..veiculo.."</b>. Ele foi adicionado à sua garagem!", 6000)
                                end)
                                return { success = "Você resgatou um carro." }
                            else
                                TriggerClientEvent("Notify", source, "negado", "Você não tem um vale-carro para usar.", 6000)
                            end
                        end
                    
                    elseif item == "mochila" then
                        local currentWeight = vRP.getInventoryMaxWeight(user_id)
                        if currentWeight < 100 then
                            local sizeAmount = 30
                            if (currentWeight + sizeAmount) > 100 then 
                                sizeAmount = 100
                            end
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.addMochila(user_id, sizeAmount, sizeAmount >= 100 and true or false)
                                TriggerClientEvent('closeInventory', source)
                                TriggerClientEvent("Notify", source, "aviso", "Você equipou uma mochila normal.", 6000)
                                return { success = "Você equipou a mochila. Limite máximo de mochilas." }
                            end
                            return { success = "Você equipou uma mochila normal." }
                        else
                            TriggerClientEvent("Notify", source, "negado", "Você já atingiu o limite máximo com a mochila normal.", 10000)
                            return { error = "Você já atingiu o limite máximo." }
                        end
                    elseif item == "mochila_x" then
                       
                        local currentWeight = vRP.getInventoryMaxWeight(user_id)  -- Obtém a quantidade atual de mochilas
                        
                        if currentWeight >= 100 then
                            if currentWeight < 200 then
                                local sizeAmount = 50
                                if (currentWeight + sizeAmount) > 200 then 
                                    sizeAmount = 200
                                end
                                if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                    vRP.addMochila(user_id, sizeAmount, sizeAmount >= 200 and true or false)
                                    TriggerClientEvent('closeInventory', source)
                                    TriggerClientEvent("Notify", source, "aviso", "Você equipou uma mochila_x.", 6000)
                                    return { success = "Você equipou uma mochila_x normal. Limite máximo de mochilas." }
                                end

                                return { success = "Você equipou a mochila_x." }
                            else
                                TriggerClientEvent("Notify", source, "negado", "Você já atingiu o limite máximo de peso.", 6000)
                                return { error = "Você já atingiu o limite máximo." }
                            end
                        else
                            TriggerClientEvent("Notify", source, "negado", "Não pode usar se tiver menos de 100 kilos de mochila.", 10000)
                            return { error = "Não pode usar se tiver menos de 100 kilos de mochila." }
                        end

                    elseif item == "colete" then
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            TriggerClientEvent('closeInventory', source)
                            func:setBlockCommand(user_id, 4)
                            vTunnel.blockButtons(source, true)
                            vRPclient._playAnim(source, true, { { "anim@mp_fireworks", "place_firework_3_box" } }, false)
                            TriggerClientEvent("progress", source, 4000)
                            SetTimeout(4000, function()
                                vTunnel.blockButtons(source, false)
                                vRPclient._stopAnim(source, true)
                                SetPedArmour(source, 200)
                                TriggerClientEvent("Notify", source, "sucesso", "<b>Colete</b> colocado com sucesso.", 9000)
                            end)
                            return { success = "Colete colocado com sucesso." }
                        end
                    elseif item == "capuz" then
                        if vRP.getInventoryItemAmount(user_id, item, 1) >= 1 then
                            func:setBlockCommand(user_id, 6)
                            local nplayer = vRPclient.getNearestPlayer(source, 5)
                            if nplayer then
                                local nuser_id = vRP.getUserId(nplayer)

                                if vRPclient.isCapuz(nplayer) then
                                    vRPclient.setCapuz(nplayer, false)
                                    TriggerClientEvent("Notify", source, "sucesso", "Você retirou o capuz desse jogador.", 6000)
                                else
                                    vRPclient.setCapuz(nplayer, true)
                                    TriggerClientEvent("Notify", source, "sucesso", "Você colocou o capuz nesse jogador, para retirar use o item novamente.", 6000)
                                end
                                vRP.closeMenu(nplayer)
                                vRP.sendLog("CAPUZ", "O USER_ID: " .. user_id .. " usou o Capuz no USER_ID: " .. nuser_id)
                            else
                                TriggerClientEvent("Notify", source, "negado", "Nenhum jogador próximo.", 6000)
                                TriggerClientEvent('closeInventory', source)
                            end
                        end
                    elseif item == "garrafavazia" then
                        local status = vTunnel.checkNearbyProp(source, "prop_watercooler")
                        local max_distance = 2.0
                        if status then
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                TriggerClientEvent('closeInventory', source)
                                func:setBlockCommand(user_id, 10)
                                TriggerClientEvent("progress", source, 10000) 
                                vTunnel.blockButtons(source, true)
                                SetTimeout(10000, function()
                                    vRP.giveInventoryItem(user_id, "agua", 1, true)
                                    vRP.tryGetInventoryItem(user_id, "garrafavazia", 1, true, slot)
                                    vTunnel.blockButtons(source, false) 
                                    TriggerClientEvent("Notify", source, "sucesso", "Sucesso! Você encheu sua garrafinha.", 5000)
                                end)
                            else
                                TriggerClientEvent("Notify", source, "negado", "Você não possui uma garrafa vazia.", 5000)
                            end
                        else
                            TriggerClientEvent("closeInventory", source)
                        end
                    elseif item == "maconha" or item == "cocaina" or item == "lsd" or item == "heroina" or item == "metanfetamina" or item == "lancaperfume" or item == "balinha" then
                        local fome, sede = vRP.itemFood(item)
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            TriggerClientEvent('closeInventory', source)
                            func:setBlockCommand(user_id, 15)
                            vTunnel.blockButtons(source, true)
                            vRPclient._playAnim(source, true, { { "anim@amb@nightclub@peds@", "missfbi3_party_snort_coke_b_male3" } }, true)
                            TriggerClientEvent("progress", source, 15000)
                            SetTimeout(15000, function()
                                vTunnel._setEnergetico(source, true)
                                vRPclient._DeletarObjeto(source)
                                vRPclient._stopAnim(source, false)
                                vTunnel.blockButtons(source, false)
                                TriggerClientEvent("Notify", source, "sucesso", "Você usou uma droga, tome cuidado.", 5000)
                                SetTimeout(45000, function()
                                    vTunnel._setEnergetico(source, false)
                                    TriggerClientEvent("Notify", source, "sucesso", "Seu corpo voltou ao normal após o uso da droga. Tome cuidado da próxima vez.", 6000)
                                end)
                            end)
                        else
                            return { error = "Você não possui essa droga." }
                        end
                    elseif item == "lockpick" then
  
                       
                       -- Garantindo que o evento "receiveVehicleInfo" só seja registrado uma vez
                        if not alreadyRegistered then
                            RegisterNetEvent("receiveVehicleInfo")
                            AddEventHandler("receiveVehicleInfo", function(plate, model, netId, locked)
                                local user_id = vRP.getUserId(source)
                                if not user_id then return end

                                local plyCoords = GetEntityCoords(GetPlayerPed(source))
                                local x, y, z = plyCoords[1], plyCoords[2], plyCoords[3]

                                -- print("🔄 [SERVER] Dados recebidos do cliente:")
                                -- print("Placa:", plate)
                                -- print("Modelo:", model)
                                -- print("Network ID:", netId)
                                -- print("Está trancado:", locked)

                                -- Verifica se temos um veículo válido
                                if not plate or not netId then
                                    print("❌ Nenhum veículo encontrado para destrancar.")
                                    TriggerClientEvent("Notify", source, "negado", "Nenhum veículo encontrado por perto.", 6000)
                                    return
                                end

                                local plateUser = vRP.getUserByRegistration(plate)
                                -- print("📝 Buscando dono do veículo no banco de dados para a placa:", plate)

                                if plateUser then
                                    -- print("✔ Dono do veículo encontrado:", plateUser)

                                    if locked == 1 then
                                        TriggerClientEvent("Notify", source, "negado", "O veículo já está destrancado.", 6000)
                                        return
                                    end

                                    -- Inicia a animação de arrombamento
                                    vTunnel._startAnimHotwired(source)
                                    vTunnel.blockButtons(source, true)

                           
                          
                                    if vRP.tryGetInventoryItem(user_id, "lockpick", 1, true, slot) then
                                        TriggerClientEvent('closeInventory', source)
                                        Wait(500)

                                        vTunnel._startAnimHotwired(source)
                                        vTunnel.blockButtons(source, true)

                                        local finished = vRPclient.taskBar(source, 2500, math.random(10, 15))
                                        if finished then
                                            finished = vRPclient.taskBar(source, 2500, math.random(10, 15))
                                            if finished then
                                                finished = vRPclient.taskBar(source, 1500, math.random(7, 15))
                                                if finished then
                                                    finished = vRPclient.taskBar(source, 1000, math.random(7, 15))


                                                    if finished then

                                                        TriggerClientEvent("unlockVehicle", source, netId)
                                                        TriggerClientEvent("vrp_sounds:source", source, "lock", 0.1)
                                                        TriggerClientEvent("Notify", source, "negado", "Você destrancou o veículo, cuidado a polícia foi acionada.", 6000)
                                                        TriggerClientEvent("SetAsNoLongerOwned", -1, netId)

                                                        
                                                    else
                                                        TriggerClientEvent("Notify", source, "negado", "Falha ao tentar destrancar o veículo.", 6000)
                                                    end

                                                else
                                                    TriggerClientEvent("Notify", source, "negado", "Falha ao tentar destrancar o veículo.", 6000)
                                                end

                                            else
                                                TriggerClientEvent("Notify", source, "negado", "Falha ao tentar destrancar o veículo.", 6000)
                                            end
                                        else
                                            TriggerClientEvent("Notify", source, "negado", "Falha ao tentar destrancar o veículo.", 6000)
                                        end

                                        -- Finaliza a animação e desbloqueia os botões em qualquer caso
                                        vRPclient._stopAnim(source, false)
                                        vTunnel.blockButtons(source, false)
                                    end
                           
                       

                                   
                                    -- Finaliza a animação e desbloqueia os botões em qualquer caso
                                    vRPclient._stopAnim(source, false)
                                    vTunnel.blockButtons(source, false)
                                else
                                    print("❌ Nenhum dono encontrado para a placa:", plate)
                                    TriggerClientEvent("Notify", source, "negado", "Este veículo não está registrado.", 6000)
                                end
                            end)

                            alreadyRegistered = true
                        end

                        -- Pegando informações do veículo mais próximo quando a lockpick for usada
                        TriggerClientEvent("getNearestVehicleInfo", source)

                        return { success = "Lockpick em uso." }

                    elseif item == "repairkit" then
                        if not vRPclient.isInVehicle(source) then
                            local vehicle = vRPclient.getNearestVehicle(source, 5000)
                            if vehicle then
                                if vRP.tryGetInventoryItem(user_id, "repairkit", 1, true, slot) or vRP.hasPermission(user_id, "perm.mecanica") then
                                    TriggerClientEvent('closeInventory', source)
                                    func:setBlockCommand(user_id, 10)
                                    vTunnel.blockButtons(source, true)
                                    vRPclient._playAnim(source, false, { { "mini@repair", "fixing_a_player" } }, true)
                                    TriggerClientEvent("progress", source, 10000)
                                    SetTimeout(10000, function()
                                        TriggerClientEvent("reparar", source, vehicle)
                                        vTunnel.blockButtons(source, false)
                                        TriggerClientEvent("Notify", source, "sucesso", "Você reparou o veiculo.", 5000)
                                        vRPclient._stopAnim(source, false) 
                                    end)
                                    return { success = "Veiculo reparado com sucesso." }
                                end
                            else
                                TriggerClientEvent('Notify', source, 'aviso', 'Você Precisa estar Perto do Veiculo',5000)
                                vTunnel.blockButtons(source, false)
                                return { error = "Você precisa estar perto do veículo." }
                            end
                        else
                            TriggerClientEvent("Notify", source, "negado","Precisa estar próximo ou fora do veículo para efetuar os reparos.", 5000)
                            vTunnel.blockButtons(source, false)
                            return { error = "fique fora do veiculo para reparar." }
                        end

                    elseif item == "militec" then
                            if not vRPclient.isInVehicle(source) then
                                local vehicle = vRPclient.getNearestVehicle(source, 5000)
                                if vehicle then
                                    if vRP.tryGetInventoryItem(user_id, "militec", 1, true, slot) or vRP.hasPermission(user_id, "perm.mecanica") then
                                        TriggerClientEvent('closeInventory', source)
                                        func:setBlockCommand(user_id, 10)
                                        vTunnel.blockButtons(source, true)
                                        vRPclient._playAnim(source, false, { { "mini@repair", "fixing_a_player" } }, true)
                                        TriggerClientEvent("progress", source, 10000)
                                        SetTimeout(10000, function()
                                            TriggerClientEvent("repararMotor", source, vehicle) -- Assumindo um evento específico para reparar o motor
                                            vTunnel.blockButtons(source, false)
                                            TriggerClientEvent("Notify", source, "sucesso", "Você reparou o motor do veículo.", 5000)
                                            vRPclient._stopAnim(source, false) 
                                        end)
                                        return { success = "Motor reparado com sucesso." }
                                    end
                                else
                                    TriggerClientEvent('Notify', source, 'aviso', 'Você precisa estar perto do veículo.', 5000)
                                    vTunnel.blockButtons(source, false)
                                    return { error = "Você precisa estar perto do veículo." }
                                end
                            else
                                TriggerClientEvent("Notify", source, "negado", "Precisa estar próximo ou fora do veículo para efetuar os reparos.", 5000)
                                vTunnel.blockButtons(source, false)
                                return { error = "Fique fora do veículo para reparar o motor." }
                            end

                    elseif item == "pneus" then
                        if not vRPclient.isInVehicle(source) then
                            local vehicle = vRPclient.getNearestVehicle(source, 5000)
                            if vehicle then
                            if vRP.tryGetInventoryItem(user_id, "pneus", 1, true, slot) then
                                vRPclient._playAnim(source, false,{ { "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer" } },true)
                                func:setBlockCommand(user_id, 15)
                                vTunnel.blockButtons(source, true)
                                TriggerClientEvent("progress", source, 15000)
                                SetTimeout(15000, function()
                                    TriggerClientEvent('repararpneus', source, vehicle)
                                    vTunnel.blockButtons(source, false)
                                    vRPclient._stopAnim(source, false)
                                    TriggerClientEvent("Notify", source, "sucesso", "Você reparou o pneu do veiculo.",6000)
                                    TriggerClientEvent('closeInventory', source)
                                end)
                            end
                        else
                            TriggerClientEvent("Notify", source, "negado","Precisa estar próximo ou fora do veículo para efetuar os reparos.", 6000)
                            return { error = "Chegue mais perto do veiculo"}
                        end
                        return { success = "Você reparou o pneu do veiculo"}
                    end

                elseif item == "placa" then
                    if vRPclient.isInVehicle(source) then
                        local vehicle = vRPclient.getNearestVehicle(source, 5000)
                        if vehicle then
                            if vRP.tryGetInventoryItem(user_id, "placa", 1, true, slot) then
                                TriggerClientEvent('closeInventory', source)
                                TriggerClientEvent("progress", source, 15000)
                                SetTimeout(15000, function()
                                    local plate = vRP.generateRegistrationNumber() -- Gerar a nova placa
                                    local plate = "THUNDER0"
                                    TriggerClientEvent("cloneplates", source, plate) -- Definir a nova placa no veículo
                                    TriggerClientEvent("setPlateEveryone",plate)
                                    TriggerClientEvent("Notify", source, "sucesso", "Você clonou a placa do veículo com sucesso.", 6000)
                                    TriggerClientEvent('closeInventory', source)
                                end)
                                return { success = "Você clonou a placa" }
                            end
                        else
                            TriggerClientEvent("Notify", source, "negado", "Precisa estar dentro do veículo para efetuar a clonagem.", 6000)
                            return { error = "Você deve estar dentro do veículo" }
                        end
                    end
                end
            end


            if itemType == "remedio" then
                if item == "bandagem" then
                    if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                        TriggerClientEvent('closeInventory', source)
                        vTunnel.SetInventoryBlocked(source, 50000000) --
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        vRPclient._CarregarObjeto(source, "amb@world_human_clipboard@male@idle_a", "idle_c","v_ret_ta_firstaid", 49, 60309)
                        TriggerClientEvent("progress", source, 15000)
                        SetTimeout(15000, function()
                            vTunnel.blockButtons(source, false)
                            vTunnel.SetInventoryBlocked(source, 0) --
                            vRPclient._DeletarObjeto(source)
                            vTunnel._useBandagem(source)
                            TriggerClientEvent("Notify", source, "aviso","Você utilizou a bandagem, não tome nenhum tipo de dano para não ser cancelada..",6000)
                        end)
                        return { success = "Você usou a bandagem." }
                    end
                elseif item == "burflex" then
                    
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            TriggerClientEvent('closeInventory', source)
                            vTunnel.SetInventoryBlocked(source, 50000000)
                            func:setBlockCommand(user_id, 10)
                            vTunnel.blockButtons(source, true)
                            -- Carrega a animação e o objeto para simular a ingestão do burflex
                            vRPclient._CarregarObjeto(source, "mp_player_intdrink", "loop_bottle", "prop_cs_pills", 49, 60309)
                            TriggerClientEvent("progress", source, 10000)
                            SetTimeout(10000, function()
                                vTunnel.blockButtons(source, false)
                                vTunnel.SetInventoryBlocked(source, 0)
                                vRPclient._DeletarObjeto(source)
                                vTunnel._useBurflex(source)
                                
                                TriggerClientEvent("Notify", source, "aviso", "Você tomou o burflex. Sinta-se melhor!", 6000)
                            end)
                            return { success = "Você tomou o Burflex." }
                        end
                   
                    
                end
            end

        if itemType == "usarVIP" then
            if item == "alterarplaca" or item == "alterarrg" then
                TriggerClientEvent('closeInventory', source)
                local numero = vRP.prompt(source, "Digite o numero: (MAX 8) (EXEMPLO: FOXZIN01)", "")
                if numero ~= nil and numero ~= "" and numero and string.len(numero) == 8 then
                    if checkRG(numero) then
                        if vRP.request(source, "Tem certeza que deseja alterar seu registro para <b>" .. numero .. "</b> ?", 30) then
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.execute("vRP/update_registro", { user_id = user_id, registro = numero })
                                vRP.updateIdentity(user_id)
                                TriggerClientEvent("Notify", source, "sucesso","Você trocou o seu registro para <b>" ..numero .. "</b>.", 15000)
                            end
                        end
                    else
                        TriggerClientEvent("Notify", source, "negado", "Este registro ja existe.", 5000)
                    end
                else
                    TriggerClientEvent("Notify", source, "negado", "Digite o registro correto. (EXEMPLO: FOXZIN01)", 5000)
                end

            elseif item == "alterartelefone" then
                TriggerClientEvent('closeInventory', source)
                local numero = vRP.prompt(source, "Digite o numero: (MAX 6) (EXEMPLO: 123-456)", "")
                if tonumber(numero) ~= nil and numero ~= "" and tonumber(numero) and string.len(numero) == 6 then
                    numero = formatNumber(numero)
                    if checkNumber(numero) then
                        if vRP.request(source, "Tem certeza que deseja alterar o numero de telefone para <b>" .. numero .. "</b> ?", 30) then
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.execute("vRP/update_number", { user_id = user_id, telefone = numero })
                                vRP.updateIdentity(user_id)
                                TriggerClientEvent("Notify", source, "sucesso","Você trocou o numero de telefone para <b>" ..numero .. "</b>.", 15000)
                            end
                        end
                    else
                        TriggerClientEvent("Notify", source, "negado", "Este numero de telefone ja existe.", 5000)
                        TriggerClientEvent('closeInventory', source)
                    end
                else
                    TriggerClientEvent("Notify", source, "negado","Digite o numero de telefone correto. (EXEMPLO: 123456)", 5000)
                    TriggerClientEvent('closeInventory', source)
                end
            end
        end

        if itemType == "usarVIP" then
            if item == "cirurgia" then
                TriggerClientEvent('closeInventory', source)
                local user_id = vRP.getUserId(source)
                if user_id then
                    local confirmation = vRP.request(source, 'Você deseja Resetar seu personagem?', 15)
                    if confirmation then
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            TriggerEvent("nation:resetplayer",source,user_id)
                        end
                    else
                        vRPclient.notify(source, {"~r~Operação cancelada."})
                    end
                end
            end
        end

        if itemType == "usarVIP" then
            if item == "Heliponto" then
                TriggerClientEvent('closeInventory', source)
                local user_id = vRP.getUserId(source)
                if user_id then
                    local confirmation = vRP.request(source, 'Você deseja Utilizar seu credito de criar garagem?', 15)
                    if confirmation then
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            TriggerEvent("foxzin:garagem",source,user_id)
                        end
                    else
                        vRPclient.notify(source, {"~r~Operação cancelada."})
                    end
                end
            end
        end

        if itemType == "usarVIP" then
            if item == "Baufac" then
                TriggerClientEvent('closeInventory', source)
                local user_id = vRP.getUserId(source)
                if user_id then
                    local confirmation = vRP.request(source, 'Você deseja Utilizar seu credito de criar bau?', 15)
                    if confirmation then
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            TriggerEvent("foxzin:createChest",source,user_id)
                        end
                    else
                        vRPclient.notify(source, {"~r~Operação cancelada."})
                    end
                end
            end
        end

        if itemType == "usarVIP" then
            if item == "lojablib" then
                TriggerClientEvent('closeInventory', source)
                local user_id = vRP.getUserId(source)
                if user_id then
                    local confirmation = vRP.request(source, 'Você deseja Utilizar seu credito de criar blib de loja?', 15)
                    if confirmation then
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            TriggerEvent("foxzin:blib",source,user_id)
                        end
                    else
                        vRPclient.notify(source, {"~r~Operação cancelada."})
                    end
                end
            end
        end

        if itemType == "usar" then
            if item == "radio" then
                TriggerClientEvent('closeInventory', source)
                local user_id = vRP.getUserId(source)
                if user_id then
                    TriggerClientEvent("Foxzin:OpenRadio", source, user_id)
                else
                    vRPclient.notify(source, {"~r~Erro: ID do usuário não encontrado."})
                end
            end
        end 

        if itemType == "usar" then
            if item == "celular" then
                TriggerClientEvent('closeInventory', source)
                local user_id = vRP.getUserId(source)
                if user_id then
                    TriggerClientEvent("abrirCelular", source, user_id)
                else
                    vRPclient.notify(source, {"~r~Erro: ID do usuário não encontrado."})
                end
            end
        end

        if itemType == "usar" then
            if item == "rastreador" then
                TriggerClientEvent('closeInventory', source)
                local user_id = vRP.getUserId(source)
                if user_id then
                    local confirmation = vRP.request(source, 'Você deseja Rastrear seu Veiculo?', 15)
                    if confirmation then
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            TriggerClientEvent('rastrear', source)
                        end
                    else
                        vRPclient.notify(source, {"~r~Operação cancelada."})
                    end
                end
            end
        end

        if itemType == "usar" then
            if item == "chave" then
                TriggerClientEvent('closeInventory', source)
                local user_id = vRP.getUserId(source)
                if user_id then
                    local confirmation = vRP.request(source, 'Você deseja Remover o Rastreador?', 15)
                    if confirmation then
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            TriggerClientEvent('removerRastreador', source)
                        end
                    else
                        vRPclient.notify(source, {"~r~Operação cancelada."})
                    end
                end
            end
        end

        if itemType == "usarVIP" then
            if item == "valecasa" then
                TriggerClientEvent('closeInventory', source)
                local user_id = vRP.getUserId(source)
                if user_id then
                    local confirmation = vRP.request(source, 'Você deseja Usar seu Vale Casa?', 15)
                    if confirmation then
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            TriggerClientEvent('valecasa', source)
                        end
                    else
                        vRPclient.notify(source, {"~r~Operação cancelada."})
                    end
                end
            end
        end
      
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- /fome e sede
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------        
                                if itemType == "bebera" then
                                    local fome, sede = vRP.itemFood(item)
                                    if item == "energetico" then
                                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                            TriggerClientEvent('closeInventory', source)
                                            vTunnel.SetInventoryBlocked(source, 5) -- Bloqueia o inventário por um tempo
                                            func:setBlockCommand(user_id, 10)
                                            vTunnel.blockButtons(source, true)
                                            play_drink(source, item, 10000 * amount)  -- Inicia animação do consumo
                                            TriggerClientEvent("progress", source, 10000) -- Inicia o progresso de 10 segundos                        
                                            SetTimeout(10000, function()
                                                vRP.varyThirst(user_id, tonumber(sede))  -- Aumenta a sede com base no item
                                                vTunnel._setEnergetico(source, true)  -- Aplica o efeito do energético
                                                vTunnel.blockButtons(source, false)
                                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                                TriggerClientEvent("Notify", source, "sucesso", "Energetico utilizado com sucesso.", 5000)
                                                SetTimeout(45000, function()
                                                    vTunnel._setEnergetico(source, false)
                                                    TriggerClientEvent("Notify", source, "negado", "O efeito do energético acabou.", 5000)
                                                end)
                                            end)
                                        end
                                    end
                                end

                                if itemType == "comer" then
                                    if item == "sanduiche" then


                                        local fome, sede = vRP.itemFood(item)
                                        TriggerClientEvent('closeInventory', source)
                                        play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                                        func:setBlockCommand(user_id, 10)
                                        vTunnel.blockButtons(source, true)
                                        TriggerClientEvent("progress", source, 10000)
                                        
                                        SetTimeout(9500, function()
                                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                                vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                                                vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                                            
                                                vTunnel.blockButtons(source, false)
                                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                                TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                                            end
                                        end)


                                    end
                                end

                            if itemType == "comer" then
                                if item == "rosquinha" then

                                    local fome, sede = vRP.itemFood(item)
                                    TriggerClientEvent('closeInventory', source)
                                    play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                                    func:setBlockCommand(user_id, 10)
                                    vTunnel.blockButtons(source, true)
                                    TriggerClientEvent("progress", source, 10000)
                                    
                                    SetTimeout(9500, function()
                                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                            vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                                            vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                                        
                                            vTunnel.blockButtons(source, false)
                                            vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                            vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                            TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                                        end
                                    end)

                                end
                            end

                        if itemType == "comer" then
                            if item == "hotdog" then

                                local fome, sede = vRP.itemFood(item)
                                TriggerClientEvent('closeInventory', source)
                                play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                                func:setBlockCommand(user_id, 10)
                                vTunnel.blockButtons(source, true)
                                TriggerClientEvent("progress", source, 10000)
                                
                                SetTimeout(9500, function()
                                    if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                        vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                                        vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                                    
                                        vTunnel.blockButtons(source, false)
                                        vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                        vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                        TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                                    end
                                end)

                            end
                        end

                    if itemType == "comer" then
                        if item == "xburguer" then

                            local fome, sede = vRP.itemFood(item)
                            TriggerClientEvent('closeInventory', source)
                            play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                            func:setBlockCommand(user_id, 10)
                            vTunnel.blockButtons(source, true)
                            TriggerClientEvent("progress", source, 10000)
                            
                            SetTimeout(9500, function()
                                if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                    vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                                    vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                                
                                    vTunnel.blockButtons(source, false)
                                    vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                    vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                    TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                                end
                            end)

                        end
                    end

                if itemType == "comer" then
                    if item == "chips" then

                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        
                        SetTimeout(9500, function()
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                                vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                            
                                vTunnel.blockButtons(source, false)
                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                            end
                        end)

                    end
                end

                if itemType == "comer" then
                    if item == "batataf" then

                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        
                        SetTimeout(9500, function()
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                                vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                                
                                vTunnel.blockButtons(source, false)
                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                            end
                        end)

                    end
                end

                if itemType == "comer" then
                    if item == "pizza" then

                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        
                        SetTimeout(9500, function()
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                                vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                            
                                vTunnel.blockButtons(source, false)
                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                            end
                        end)

                    end
                end

                if itemType == "comer" then
                    if item == "frango" then

                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        
                        SetTimeout(9500, function()
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                                vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                                
                                vTunnel.blockButtons(source, false)
                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                            end
                        end)

                    end
                end

                if itemType == "comer" then
                    if item == "bcereal" then

                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        
                        SetTimeout(9500, function()
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                                vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                            
                                vTunnel.blockButtons(source, false)
                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                            end
                        end)

                    end
                end

                if itemType == "comer" then
                    if item == "chocolate" then

                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        
                        SetTimeout(9500, function()
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                                vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                            
                                vTunnel.blockButtons(source, false)
                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                            end
                        end)

                    end
                end

                if itemType == "comer" then
                    if item == "marmita" then

                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        
                        SetTimeout(9500, function()
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                                vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                            
                                vTunnel.blockButtons(source, false)
                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                            end
                        end)

                    end
                end

                if itemType == "comer" then
                    if item == "coxinha" then

                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        
                        SetTimeout(9500, function()
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                                vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                                
                                vTunnel.blockButtons(source, false)
                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                            end
                        end)

                    end
                end

                if itemType == "comer" then
                    if item == "pipoca" then

                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        
                        SetTimeout(9500, function()
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                                vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                            
                                vTunnel.blockButtons(source, false)
                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                            end
                        end)

                    end
                end

                if itemType == "comer" then
                    if item == "temaki" then

                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        
                        SetTimeout(9500, function()
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                                vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                            
                                vTunnel.blockButtons(source, false)
                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                            end
                        end)

                    end
                end

                if itemType == "comer" then
                    if item == "morango" then

                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        
                        SetTimeout(9500, function()
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                                vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                            
                                vTunnel.blockButtons(source, false)
                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                            end
                        end)

                    end
                end

                if itemType == "comer" then
                    if item == "paodequeijo" then

                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        
                        SetTimeout(9500, function()
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                                vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                            
                                vTunnel.blockButtons(source, false)
                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                            end
                        end)

                    end
                end

                if itemType == "comer" then
                    if item == "pirulito" then

                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        
                        SetTimeout(9500, function()
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                                vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                            
                                vTunnel.blockButtons(source, false)
                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                            end
                        end)

                    end
                end

                if itemType == "comer" then
                    if item == "laranja" then

                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        
                        SetTimeout(9500, function()
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                                vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                            
                                vTunnel.blockButtons(source, false)
                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                            end
                        end)

                    end
                end

                    if itemType == "comer" then
                        if item == "trakinas" then

                            local fome, sede = vRP.itemFood(item)
                            TriggerClientEvent('closeInventory', source)
                            play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                            func:setBlockCommand(user_id, 10)
                            vTunnel.blockButtons(source, true)
                            TriggerClientEvent("progress", source, 10000)
                            
                            SetTimeout(9500, function()
                                if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                    vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                                    vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                                    
                                    vTunnel.blockButtons(source, false)
                                    vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                    vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                    TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                                end
                            end)

                        end
                    end

                if itemType == "comer" then
                    if item == "doce" then

                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        
                        SetTimeout(9500, function()
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                                vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                            
                                vTunnel.blockButtons(source, false)
                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                            end
                        end)

                    end
                end

                if itemType == "comer" then
                    if item == "espeto" then

                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        
                        SetTimeout(9500, function()
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                                vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                            
                                vTunnel.blockButtons(source, false)
                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                            end
                        end)

                    end
                end

                if itemType == "comer" then
                    if item == "bolo" then

                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        
                        SetTimeout(9500, function()
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                                vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                                
                                vTunnel.blockButtons(source, false)
                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                            end
                        end)

                    end
                end

                if itemType == "comer" then
                    if item == "croissant" then

                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        
                        SetTimeout(9500, function()
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                                vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                            
                                vTunnel.blockButtons(source, false)
                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                            end
                        end)

                    end
                end

                if itemType == "comer" then
                    if item == "batata" then

                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        
                        SetTimeout(9500, function()
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                                vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                            
                                vTunnel.blockButtons(source, false)
                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                            end
                        end)

                    end
                end


            if itemType == "comer" then
                if item == "brigadeiro" then

                    local fome, sede = vRP.itemFood(item)
                    TriggerClientEvent('closeInventory', source)
                    play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                    func:setBlockCommand(user_id, 10)
                    vTunnel.blockButtons(source, true)
                    TriggerClientEvent("progress", source, 10000)
                    
                    SetTimeout(9500, function()
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                            vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                        
                            vTunnel.blockButtons(source, false)
                            vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                            vRPclient._stopAnim(source, false)  -- Interrompe a animação
                            TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                        end
                    end)

                end
            end


            if itemType == "comer" then
                if item == "pastel" then

                    local fome, sede = vRP.itemFood(item)
                    TriggerClientEvent('closeInventory', source)
                    play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                    func:setBlockCommand(user_id, 10)
                    vTunnel.blockButtons(source, true)
                    TriggerClientEvent("progress", source, 10000)
                    
                    SetTimeout(9500, function()
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                            vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                        
                            vTunnel.blockButtons(source, false)
                            vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                            vRPclient._stopAnim(source, false)  -- Interrompe a animação
                            TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                        end
                    end)

                end
            end

                if itemType == "comer" then
                    if item == "chocolate" then

                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        
                        SetTimeout(9500, function()
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                                vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                            
                                vTunnel.blockButtons(source, false)
                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                            end
                        end)

                    end
                end

            if itemType == "comer" then
                if item == "taco" then

                    local fome, sede = vRP.itemFood(item)
                    TriggerClientEvent('closeInventory', source)
                    play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                    func:setBlockCommand(user_id, 10)
                    vTunnel.blockButtons(source, true)
                    TriggerClientEvent("progress", source, 10000)
                    
                    SetTimeout(9500, function()
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                            vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                        
                            vTunnel.blockButtons(source, false)
                            vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                            vRPclient._stopAnim(source, false)  -- Interrompe a animação
                            TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                        end
                    end)

                end
            end

            if itemType == "comer" then
                if item == "pao" then

                    local fome, sede = vRP.itemFood(item)
                    TriggerClientEvent('closeInventory', source)
                    play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                    func:setBlockCommand(user_id, 10)
                    vTunnel.blockButtons(source, true)
                    TriggerClientEvent("progress", source, 10000)
                    
                    SetTimeout(9500, function()
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                            vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                        
                            vTunnel.blockButtons(source, false)
                            vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                            vRPclient._stopAnim(source, false)  -- Interrompe a animação
                            TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                        end
                    end)

                end
            end

            if itemType == "comer" then
                if item == "donut" then

                    local fome, sede = vRP.itemFood(item)
                    TriggerClientEvent('closeInventory', source)
                    play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                    func:setBlockCommand(user_id, 10)
                    vTunnel.blockButtons(source, true)
                    TriggerClientEvent("progress", source, 10000)
                    
                    SetTimeout(9500, function()
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                            vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                        
                            vTunnel.blockButtons(source, false)
                            vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                            vRPclient._stopAnim(source, false)  -- Interrompe a animação
                            TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                        end
                    end)

                end
            end


                if itemType == "comer" then
                    if item == "hamburguer" then

                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        play_eat(source, item, 10000)  -- Chama a função play_eat para carregar o prop de comida
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        
                        SetTimeout(9500, function()
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.varyThirst(user_id, 0)  -- Não altera a sede ao comer
                                vRP.varyHunger(user_id, 25)  -- Aumenta a fome ao comer
                            
                                vTunnel.blockButtons(source, false)
                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                TriggerClientEvent("Notify", source, "sucesso", "Você se alimentou-se com sucesso.", 5000)
                            end
                        end)

                    end
                end

                -- Caso o item seja do tipo "beber"
                if itemType == "beber" then
                    if item == "agua" then

                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        play_drink(source, item, 10000 * amount)  -- Animação do consumo
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        
                        SetTimeout(9500, function()
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.varyThirst(user_id, 40)  -- Aumenta a sede
                                vRP.varyHunger(user_id, 0)   -- Não altera a fome
                            
                                vTunnel.blockButtons(source, false)
                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                vRP.giveInventoryItem(user_id, "garrafavazia", 1, true)
                                TriggerClientEvent("Notify", source, "sucesso", "Você bebeu água.", 5000)
                            end
                        end)

                    end
                end

                
                -- Caso o item seja do tipo "beber"
                if itemType == "beber" then
                    if item == "leite" then

                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        play_drink(source, item, 10000 * amount)  -- Animação do consumo
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        
                        SetTimeout(9500, function()
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.varyThirst(user_id, 40)  -- Aumenta a sede
                                vRP.varyHunger(user_id, 0)   -- Não altera a fome
                                
                                vTunnel.blockButtons(source, false)
                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                TriggerClientEvent("Notify", source, "sucesso", "Você se bebeu-se com sucesso.", 5000)
                            end
                        end)

                    end
                end

            if itemType == "beber" then
                if item == "cafe" then

                    local fome, sede = vRP.itemFood(item)
                    TriggerClientEvent('closeInventory', source)
                    play_drink(source, item, 10000 * amount)  -- Animação do consumo
                    func:setBlockCommand(user_id, 10)
                    vTunnel.blockButtons(source, true)
                    TriggerClientEvent("progress", source, 10000)
                    
                    SetTimeout(9500, function()
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            vRP.varyThirst(user_id, 40)  -- Aumenta a sede
                            vRP.varyHunger(user_id, 0)   -- Não altera a fome
                        
                            vTunnel.blockButtons(source, false)
                            vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                            vRPclient._stopAnim(source, false)  -- Interrompe a animação
                            TriggerClientEvent("Notify", source, "sucesso", "Você se bebeu-se com sucesso.", 5000)
                        end
                    end)

                end
            end

                if itemType == "beber" then
                    if item == "cafecleite" then

                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        play_drink(source, item, 10000 * amount)  -- Animação do consumo
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        
                        SetTimeout(9500, function()
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.varyThirst(user_id, 40)  -- Aumenta a sede
                                vRP.varyHunger(user_id, 0)   -- Não altera a fome
                            
                                vTunnel.blockButtons(source, false)
                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                TriggerClientEvent("Notify", source, "sucesso", "Você se bebeu-se com sucesso.", 5000)
                            end
                        end)

                    end
                end

            if itemType == "beber" then
                if item == "cafeexpresso" then

                    local fome, sede = vRP.itemFood(item)
                    TriggerClientEvent('closeInventory', source)
                    play_drink(source, item, 10000 * amount)  -- Animação do consumo
                    func:setBlockCommand(user_id, 10)
                    vTunnel.blockButtons(source, true)
                    TriggerClientEvent("progress", source, 10000)
                    
                    SetTimeout(9500, function()
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            vRP.varyThirst(user_id, 40)  -- Aumenta a sede
                            vRP.varyHunger(user_id, 0)   -- Não altera a fome
                        
                            vTunnel.blockButtons(source, false)
                            vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                            vRPclient._stopAnim(source, false)  -- Interrompe a animação
                            TriggerClientEvent("Notify", source, "sucesso", "Você se bebeu-se com sucesso.", 5000)
                        end
                    end)

                end
            end

            if itemType == "beber" then
                if item == "capuccino" then

                    local fome, sede = vRP.itemFood(item)
                    TriggerClientEvent('closeInventory', source)
                    play_drink(source, item, 10000 * amount)  -- Animação do consumo
                    func:setBlockCommand(user_id, 10)
                    vTunnel.blockButtons(source, true)
                    TriggerClientEvent("progress", source, 10000)
                    
                    SetTimeout(9500, function()
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            vRP.varyThirst(user_id, 40)  -- Aumenta a sede
                            vRP.varyHunger(user_id, 0)   -- Não altera a fome
                        
                            vTunnel.blockButtons(source, false)
                            vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                            vRPclient._stopAnim(source, false)  -- Interrompe a animação
                            TriggerClientEvent("Notify", source, "sucesso", "Você se bebeu-se com sucesso.", 5000)
                        end
                    end)

                end
            end

            if itemType == "beber" then
                if item == "frappuccino" then

                    local fome, sede = vRP.itemFood(item)
                    TriggerClientEvent('closeInventory', source)
                    play_drink(source, item, 10000 * amount)  -- Animação do consumo
                    func:setBlockCommand(user_id, 10)
                    vTunnel.blockButtons(source, true)
                    TriggerClientEvent("progress", source, 10000)
                    
                    SetTimeout(9500, function()
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            vRP.varyThirst(user_id, 40)  -- Aumenta a sede
                            vRP.varyHunger(user_id, 0)   -- Não altera a fome
                        
                            vTunnel.blockButtons(source, false)
                            vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                            vRPclient._stopAnim(source, false)  -- Interrompe a animação
                            TriggerClientEvent("Notify", source, "sucesso", "Você se bebeu-se com sucesso.", 5000)
                        end
                    end)

                end
            end

                if itemType == "beber" then
                    if item == "cha" then

                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        play_drink(source, item, 10000 * amount)  -- Animação do consumo
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        
                        SetTimeout(9500, function()
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.varyThirst(user_id, 40)  -- Aumenta a sede
                                vRP.varyHunger(user_id, 0)   -- Não altera a fome
                            
                                vTunnel.blockButtons(source, false)
                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                TriggerClientEvent("Notify", source, "sucesso", "Você se bebeu-se com sucesso.", 5000)
                            end
                        end)

                    end
                end

            if itemType == "beber" then
                if item == "icecha" then

                    local fome, sede = vRP.itemFood(item)
                    TriggerClientEvent('closeInventory', source)
                    play_drink(source, item, 10000 * amount)  -- Animação do consumo
                    func:setBlockCommand(user_id, 10)
                    vTunnel.blockButtons(source, true)
                    TriggerClientEvent("progress", source, 10000)
                    
                    SetTimeout(9500, function()
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            vRP.varyThirst(user_id, 40)  -- Aumenta a sede
                            vRP.varyHunger(user_id, 0)   -- Não altera a fome
                        
                            vTunnel.blockButtons(source, false)
                            vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                            vRPclient._stopAnim(source, false)  -- Interrompe a animação
                            TriggerClientEvent("Notify", source, "sucesso", "Você se bebeu-se com sucesso.", 5000)
                        end
                    end)

                end
            end


                if itemType == "beber" then
                    if item == "sprunk" then

                        local fome, sede = vRP.itemFood(item)
                        TriggerClientEvent('closeInventory', source)
                        play_drink(source, item, 10000 * amount)  -- Animação do consumo
                        func:setBlockCommand(user_id, 10)
                        vTunnel.blockButtons(source, true)
                        TriggerClientEvent("progress", source, 10000)
                        
                        SetTimeout(9500, function()
                            if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                vRP.varyThirst(user_id, 40)  -- Aumenta a sede
                                vRP.varyHunger(user_id, 0)   -- Não altera a fome
                                
                                vTunnel.blockButtons(source, false)
                                vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                                vRPclient._stopAnim(source, false)  -- Interrompe a animação
                                TriggerClientEvent("Notify", source, "sucesso", "Você se bebeu-se com sucesso.", 5000)
                            end
                        end)

                    end
                end

            if itemType == "beber" then
                if item == "cocacola" then

                    local fome, sede = vRP.itemFood(item)
                    TriggerClientEvent('closeInventory', source)
                    play_drink(source, item, 10000 * amount)  -- Animação do consumo
                    func:setBlockCommand(user_id, 10)
                    vTunnel.blockButtons(source, true)
                    TriggerClientEvent("progress", source, 10000)
                    
                    SetTimeout(9500, function()
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            vRP.varyThirst(user_id, 40)  -- Aumenta a sede
                            vRP.varyHunger(user_id, 0)   -- Não altera a fome
                            
                            vTunnel.blockButtons(source, false)
                            vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                            vRPclient._stopAnim(source, false)  -- Interrompe a animação
                            TriggerClientEvent("Notify", source, "sucesso", "Você se bebeu-se com sucesso.", 5000)
                        end
                    end)

                end
            end

            if itemType == "beber" then
                if item == "sucol" then

                    local fome, sede = vRP.itemFood(item)
                    TriggerClientEvent('closeInventory', source)
                    play_drink(source, item, 10000 * amount)  -- Animação do consumo
                    func:setBlockCommand(user_id, 10)
                    vTunnel.blockButtons(source, true)
                    TriggerClientEvent("progress", source, 10000)
                    
                    SetTimeout(9500, function()
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                            vRP.varyThirst(user_id, 40)  -- Aumenta a sede
                            vRP.varyHunger(user_id, 0)   -- Não altera a fome
                        
                            vTunnel.blockButtons(source, false)
                            vRPclient._DeletarObjeto(source)  -- Remove o item consumido
                            vRPclient._stopAnim(source, false)  -- Interrompe a animação
                            TriggerClientEvent("Notify", source, "sucesso", "Você se bebeu-se com sucesso.", 5000)
                        end
                    end)

                end
            end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- / EQUIPAR
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
                   
                if itemType == "equipar" then
                    
                    local myWeapons = vRPclient.getWeapons(source)
                    TriggerClientEvent('closeInventory', source)
                    local blockWeapons = {}
                    local bloqueado = false

                    for k, v in pairs(myWeapons) do
                        local categoria = classWeapons[k]
                        if categoria ~= nil then
                            blockWeapons[categoria] = true
                        end

                        local categoria2 = classWeapons[item]
                        if categoria2 ~= nil then
                            if blockWeapons[categoria2] ~= nil then
                                bloqueado = true
                            end
                        end
                    end

                    if not bloqueado then
                        if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then

                            local weapons = {}
                            weapons[item] = { ammo = 0 }
                            vRPclient._giveWeapons(source, weapons)

                            vRP.sendLog("EQUIPAR", "O ID " .. user_id .." equipou a arma " .. vRP.getItemName(item) .. ".")
                            return { success = "Arma equipada com sucesso", used_amount = 1 }
                        end
                    else
                       TriggerClientEvent("Notify", source, "negado","Você ja possui uma arma dessa classe equipada!", 6000)
                        return { error = "Você ja possui uma arma dessa classe equipada!"}
                    end
                end

            
                if itemType == "recarregar" then

                    func:setCooldown(user_id, "inventario", 5)
                    local weapon = string.gsub(item, "AMMO_", "WEAPON_")
                    local municao = vRPclient.getAmmo(source, weapon)
                    local maxMunicao = 250
                    if vRPclient.checkWeapon(source, weapon) then
                        if municao < 250 then
                            if maxMunicao <= amount then
                                maxMunicao = maxMunicao - municao
                                amount = maxMunicao
                            else
                                maxMunicao = maxMunicao - municao
                                if amount > maxMunicao then
                                amount = maxMunicao
                                end
                            end

                            if vRP.tryGetInventoryItem(user_id, item, amount, true, slot) then
                                TriggerClientEvent('closeInventory', source)
                                local weapons = {}
                                weapons[weapon] = { ammo = amount }
                                vRPclient._giveWeapons(source, weapons, false)
                                vRP.sendLog("EQUIPAR","O ID " ..user_id .." recarregou a municao " ..vRP.getItemName(item) .. " na quantidade de " .. amount .. " x.")
                                return { success = "Munição equipada com sucesso", used_amount = amount}
                            end
                        else
                           TriggerClientEvent("Notify", source, "negado","Sua <b>" .. vRP.getItemName(weapon) .. "</b> ja esta com seu maximo de munição", 6000)
                            return { error =  "Sua <b>" .. vRP.getItemName(weapon) .. "</b> ja esta com seu maximo de munição" }
                        end
                    else
                       TriggerClientEvent("Notify", source, "negado","Você precisa estar com a <b>" ..vRP.getItemName(weapon) .. "</b> na mão para recarregar.",6000)
                        return { error = "Você precisa estar com a <b>" ..vRP.getItemName(weapon) .. "</b> na mão para recarregar." }
                    end
                end
                return { error = "Esse item não pode ser utilizado." }
			end
        end
    end
end






local droplist = {}
local dropCooldown = {}

function RegisterTunnel.dropItem(slot, amount)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then

        local inv = vRP.getInventory(user_id)
        if inv then
            if not inv[tostring(slot)] or inv[tostring(slot)].item == nil then
                return
            end

            local itemName = inv[tostring(slot)].item
            if vRP.tryGetInventoryItem(user_id, itemName, parseInt(amount), true, slot) then
                vRPclient._playAnim(source, true, { { "pickup_object", "pickup_low" } }, false)
                createDropItem(itemName, parseInt(amount), source)

                vRP.sendLog("DROPAR","O ID " .. user_id .." dropou o item " .. vRP.getItemName(itemName) .. " na quantidade de " .. amount .. "x.")
                return { success = "Você pegou o item com sucesso." }
            end
        end
	end
end

function RegisterTunnel.pegarItem(id)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
        local amount = droplist[id].count
		vRPclient._playAnim(source, true, { { "pickup_object", "pickup_low" } }, false)
        
        if vRP.computeInvWeight(user_id) + vRP.getItemWeight(tostring(droplist[id].item)) * parseInt(amount) <= vRP.getInventoryMaxWeight(user_id) then
            dropCache = droplist[id]

            if (droplist[id].count - amount) >= 1 then
                vTunnel._removeDrop(-1, id)

                local newamount = droplist[id].count - amount
                createDropItem(droplist[id].item, newamount, source)

                droplist[id] = nil
                idgens:free(id)
            else
                vTunnel._removeDrop(-1, id)
                droplist[id] = nil
                idgens:free(id)
            end

            if tostring(dropCache.item) == "money" then
                vRP.giveInventoryItem(user_id, tostring(dropCache.item), parseInt(amount), true)
            else
                vRP.giveInventoryItem(user_id, tostring(dropCache.item), parseInt(amount), true)
            end

            vRP.sendLog("https://discord.com/api/webhooks/1279010275034402918/z8USunDbD08SHQL3UaHX6avGygKDDA6G9Dnk0aF5_u5x-z5Upn2yXuxDC9NwL71_ho_e","O ID " .. user_id .. " pegou o item do chão " ..dropCache.item .. " na quantidade de " .. amount .."x.")
            return { success = "Você pegou o item com sucesso." }
        else
           TriggerClientEvent("Notify", source, "negado", "Mochila cheia.", 6000)
            return { error = "Mochila cheia." }
        end
        dropCooldown[id] = nil
	end
end


function createDropItem(item, count, source)
	local id = idgens:gen()
	local coords = GetEntityCoords(GetPlayerPed(source))

	droplist[id] = {
		item = item,
		count = count,
		x = coords[1],
		y = coords[2],
		z = coords[3],
		name = vRP.getItemName(item),
		key = item,
		index = vRP.getItemType(item),
		peso = vRP.getItemWeight(item)
	}
	vTunnel._updateDrops(source, id, droplist[id])

	local nplayers = vRPclient.getNearestPlayers(source, 100)
	for k in pairs(nplayers) do
		vTunnel._updateDrops(k, id, droplist[id])
	end
end



RegisterTunnel.shopAction = function(id, item, amount, slot)
    amount = parseInt(amount)
    if not amount or amount <= 0 then
        amount = 1
    end

    local source = source
    local user_id = vRP.getUserId(source)

    if user_id then
        if Shops[id] then
            if Shops[id].perm then
                if not RegisterTunnel.checkPermission(Shops[id].perm, source) then
                end
            end

            local items = Shops[id].items
            if items[item] then
                if Shops[id].mode == "buy" then
                    if vRP.computeInvWeight(user_id) + vRP.getItemWeight(item) * amount <= vRP.getInventoryMaxWeight(user_id) then
                        if parseInt(items[item]) == 0 or vRP.tryFullPayment(user_id, parseInt(items[item]) * amount) then
                            vRP.giveInventoryItem(user_id, item, amount, true, slot)
                            return { success = "Você comprou <b>" .. amount .. "x " .. vRP.getItemName(item) .. "</b> por <b>R$ " .. vRP.format(parseInt(items[item]) * amount) .. "</b>." }
                        else
                            TriggerClientEvent("Notify", source, "negado", "Você não possui dinheiro suficiente.", 6000)
                            return { error = "Você não possui dinheiro suficiente." }
                        end
                    else
                        return { error = "Mochila cheia." }
                    end
                elseif Shops[id].mode == "sell" then
                    if item and items[item] then
                        if vRP.tryGetInventoryItem(user_id, item, amount, slot) then
                            vRP.giveBankMoney(user_id, items[item] * amount, true)
                            return { success = "Você vendeu <b>" .. amount .. "x " .. vRP.getItemName(item) .. "</b> por <b>R$ " .. vRP.format(items[item] * amount) .. "</b>." }
                        else
                            return { error = "Você não possui o item necessário." }
                        end
                    else
                        return { error = "Item não encontrado na loja." }
                    end
                end
            else
                return { error = "Item não encontrado na loja." }
            end
        else
            return { error = "Loja não encontrada." }
        end
    else
        return { error = "Usuário inválido." }
    end
end


function RegisterTunnel.checkPermission(perm, src)
    local source = src or source
    local user_id = vRP.getUserId(source) 
    if user_id then
        if perm == nil or vRP.hasPermission(user_id, perm) then
            return true 
        end
    end

    return false 
end

RegisterServerEvent("checkPermission")
AddEventHandler("checkPermission", function(perm)
    local source = source
    local hasPermission = RegisterTunnel.checkPermission(perm, source)
    TriggerClientEvent("checkPermissionResponse", source, hasPermission)
end)



local Cooldowns = {}


-- RegisterTunnel.requireChest = function(data, maxbau, id)
--     local source = source
--     local user_id = vRP.getUserId(source)

--     vehList = exports.thunder_garages:garages_vehicle_list()
     
--     if user_id then
--         if data[1] == "VEHICLE" then
--             local vehicleNetworkId = NetworkGetEntityFromNetworkId(data[2])
            
--             if vehicleNetworkId == 0 then
--                 print("[ERRO] Network ID inválido!")
--                 return false
--             end
            
--             local plate = GetVehicleNumberPlateText(vehicleNetworkId)
            
--             local entityModel = GetEntityModel(vehicleNetworkId)
            
--             local name = vehList[entityModel] and vehList[entityModel].model or "desconhecido"
           
--             local uniqueID = plate .. ":" .. name
            
--             if name == "desconhecido" then
--                 TriggerClientEvent("Notify", source, "negado", "Veículo desconhecido ou sem cadastro!", 8000)
--                 return false
--             end
            
--             if OpennedVehicle[uniqueID] then 
--                 return false 
--             end
            
--             local cooldownTime = 10 -- tempo de espera em segundos
--             local lastOpened = Cooldowns[uniqueID] or 0
--             local currentTime = os.time()
--             if currentTime - lastOpened < cooldownTime then
--                 local timeRemaining = cooldownTime - (currentTime - lastOpened)
--                 TriggerClientEvent("Notify", source, "negado", "Você só pode abrir o porta-malas novamente em <b>"..timeRemaining.." segundo(s)</b>", 5000)
--                 return
--             end
--             Cooldowns[uniqueID] = currentTime
            
--             local nuser_id = vRP.getUserByRegistration(plate)
            
--             if not nuser_id then
--                 TriggerClientEvent("Notify", source, "negado", "Erro ao identificar o dono do veículo!", 8000)
--                 return false
--             end
            
--             vRPclient._playAnim(source, true, { { "amb@prop_human_parking_meter@female@idle_a", "idle_a_female" } }, true)
            
--             if not dataVehicle[uniqueID] then
--                 local rows = MySQL.query.await("SELECT portamalas FROM vehicle_chests WHERE user_id = ? AND vehicle = ?", {nuser_id, string.lower(name)})
                
--                 if rows and #rows > 0 then
--                     dataVehicle[uniqueID] = { json.decode(rows[1].portamalas) or {}, name, plate, false, true }
--                 else
--                     dataVehicle[uniqueID] = { {}, name, plate, true, true }
--                     MySQL.insert.await("INSERT INTO vehicle_chests (user_id, vehicle, portamalas) VALUES (?, ?, ?)", {
--                         nuser_id, string.lower(name), json.encode({})
--                     })
--                 end
--             end
            
--             local myVehicle, weight = {}, 0.0
--             for k, v in pairs(dataVehicle[uniqueID][1]) do
--                 if Items[v.item] then
--                     v.amount = parseInt(v.amount)
--                     v.name = Items[v.item].name
--                     v.peso = Items[v.item].weight
--                     v.index = v.item
--                     myVehicle[k] = v
--                     weight = weight + (Items[v.item].weight * v.amount)
--                 end
--             end
            
--             OpennedVehicle[uniqueID] = user_id
--             OpennedChestUser[user_id] = { tipo = "VEHICLE", name = uniqueID, vehname = name }
            
--             MySQL.update.await("UPDATE vehicle_chests SET portamalas = ? WHERE user_id = ? AND vehicle = ?", {
--                 json.encode(dataVehicle[uniqueID][1]), nuser_id, string.lower(name)
--             })
            
--             return { inventory = myVehicle, weight = weight, max_weight = vRP.getVehicleTrunk(name) }
--         end
--     end
-- end


RegisterTunnel.requireChest = function(data, maxbau, id)
    local source = source
    local user_id = vRP.getUserId(source)

    if user_id then
        -- 🔹 BAÚ DO CARRO (Já está funcionando, não precisa mudar)
        if data[1] == "VEHICLE" then
            vehList = exports.thunder_garages:garages_vehicle_list()
            local vehicleNetworkId = NetworkGetEntityFromNetworkId(data[2])

            if vehicleNetworkId == 0 then
                print("[ERRO] Network ID inválido!")
                return false
            end

            local plate = GetVehicleNumberPlateText(vehicleNetworkId)
            local entityModel = GetEntityModel(vehicleNetworkId)
            local name = vehList[entityModel] and vehList[entityModel].model or "desconhecido"
            local uniqueID = plate .. ":" .. name

            if name == "desconhecido" then
                TriggerClientEvent("Notify", source, "negado", "Veículo desconhecido ou sem cadastro!", 8000)
                return false
            end

            if OpennedVehicle[uniqueID] then 
                return false 
            end

            -- Cooldown para evitar spam
            local cooldownTime = 10
            local lastOpened = Cooldowns[uniqueID] or 0
            local currentTime = os.time()
            if currentTime - lastOpened < cooldownTime then
                local timeRemaining = cooldownTime - (currentTime - lastOpened)
                TriggerClientEvent("Notify", source, "negado", "Você só pode abrir o porta-malas novamente em <b>"..timeRemaining.." segundo(s)</b>", 5000)
                return
            end
            Cooldowns[uniqueID] = currentTime

            local nuser_id = vRP.getUserByRegistration(plate)

            if not nuser_id then
                TriggerClientEvent("Notify", source, "negado", "Erro ao identificar o dono do veículo!", 8000)
                return false
            end

            vRPclient._playAnim(source, true, { { "amb@prop_human_parking_meter@female@idle_a", "idle_a_female" } }, true)

            if not dataVehicle[uniqueID] then
                local rows = MySQL.query.await("SELECT portamalas FROM vehicle_chests WHERE user_id = ? AND vehicle = ?", {nuser_id, string.lower(name)})

                if rows and #rows > 0 then
                    dataVehicle[uniqueID] = { json.decode(rows[1].portamalas) or {}, name, plate, false, true }
                else
                    dataVehicle[uniqueID] = { {}, name, plate, true, true }
                    MySQL.insert.await("INSERT INTO vehicle_chests (user_id, vehicle, portamalas) VALUES (?, ?, ?)", {
                        nuser_id, string.lower(name), json.encode({})
                    })
                end
            end

            local myVehicle, weight = {}, 0.0
            for k, v in pairs(dataVehicle[uniqueID][1]) do
                if Items[v.item] then
                    v.amount = parseInt(v.amount)
                    v.name = Items[v.item].name
                    v.peso = Items[v.item].weight
                    v.index = v.item
                    myVehicle[k] = v
                    weight = weight + (Items[v.item].weight * v.amount)
                end
            end

            OpennedVehicle[uniqueID] = user_id
            OpennedChestUser[user_id] = { tipo = "VEHICLE", name = uniqueID, vehname = name }

            MySQL.update.await("UPDATE vehicle_chests SET portamalas = ? WHERE user_id = ? AND vehicle = ?", {
                json.encode(dataVehicle[uniqueID][1]), nuser_id, string.lower(name)
            })

            return { inventory = myVehicle, weight = weight, max_weight = vRP.getVehicleTrunk(name) }
        end

        -- 🔹 BAÚ DE FACÇÃO (Correção para permissão e peso)
        if data[1] == "GROUP" then

            -- local facChestName = data[3] -- Nome do baú da facção
            -- local chestKey = "orgChest:" .. facChestName -- Ajuste para o formato da tabela

            -- print("SERVER: Requisição de baú GROUP para: " .. facChestName)

            -- -- 1️⃣ Verifica se o baú existe na `vrp_chests` e busca o peso correto e a permissão necessária
            -- local chestInfo = MySQL.query.await("SELECT weight, permiss FROM vrp_chests WHERE name = ?", { facChestName })

            -- if not chestInfo or #chestInfo == 0 then
            --     print("SERVER: Baú de facção não encontrado na tabela vrp_chests: " .. facChestName)
            --     return false
            -- end

            -- local maxWeight = chestInfo[1].weight or 5000 -- Usa o peso correto da tabela
            -- local requiredPermission = chestInfo[1].permiss -- Permissão necessária

            -- -- 2️⃣ Verifica se o jogador tem permissão para abrir o baú
            -- if requiredPermission and not vRP.hasPermission(user_id, requiredPermission) then
            --     TriggerClientEvent("Notify", source, "negado", "Você não tem permissão para acessar este baú!", 8000)
            --     print("SERVER: Acesso negado ao baú " .. facChestName .. " para o usuário " .. user_id)
            --     return false
            -- end

            -- -- -- 3️⃣ Consulta na `vrp_srv_data` para buscar os itens do baú
            -- -- local rows = MySQL.query.await("SELECT dvalue FROM vrp_srv_data WHERE dkey = ?", { chestKey })

            -- -- if not rows or #rows == 0 then
            -- --     print("SERVER: Nenhum baú de facção encontrado para: " .. facChestName)
            -- --     return false
            -- -- end

            -- -- 3️⃣ Consulta na `vrp_srv_data` para buscar os itens do baú
            -- local rows = MySQL.query.await("SELECT dvalue FROM vrp_srv_data WHERE dkey = ?", { chestKey })

            -- if not rows or #rows == 0 then
            --     print("SERVER: Nenhum baú de facção encontrado para: " .. facChestName)
                
            --     -- Criar um baú vazio na `vrp_srv_data`
            --     local emptyChest = json.encode({})
            --     MySQL.query.await("INSERT INTO vrp_srv_data (dkey, dvalue) VALUES (?, ?)", { chestKey, emptyChest })
                
            --     -- Notificar o jogador para tentar novamente
            --     TriggerClientEvent("Notify", source, "aviso", "Baú criado! Tente abrir novamente.", 5000)

            --     return false
            -- end
            

            -- -- 4️⃣ Decodifica os itens armazenados no baú
            -- local chestData = json.decode(rows[1].dvalue) or {}

            -- -- 5️⃣ Calcula o peso real dos itens no baú
            -- local totalWeight = 0.0
            -- for k, v in pairs(chestData) do
            --     if Items[v.item] then
            --         v.amount = parseInt(v.amount)
            --         v.name = Items[v.item].name
            --         v.peso = Items[v.item].weight
            --         v.index = v.item
            --         totalWeight = totalWeight + (Items[v.item].weight * v.amount)
            --     end
            -- end

            -- -- 6️⃣ Retorna os dados formatados para a NUI
            -- local response = {
            --     inventory = chestData,
            --     weight = totalWeight,
            --     max_weight = maxWeight -- Agora usa o peso correto da `vrp_chests`
            -- }

            -- -- print("SERVER: Baú de facção aberto com sucesso: " .. json.encode(response))

            -- return response


            if OpennedOrg[data[3]] then return end
            vRPclient._playAnim(source, true, { { "amb@prop_human_parking_meter@female@idle_a","idle_a_female"} }, false)
            if (Chests[data[3]] and Chests[data[3]].permission ~= nil and vRP.hasPermission(user_id, Chests[data[3]].permission)) or (Chests[data[3]] and Chests[data[3]].permission == true) then
                if dataOrgChest[data[3]] == nil then
                    local rows = vRP.getSData("orgChest:" .. data[3])
                    dataOrgChest[data[3]] = { json.decode(rows) or {} }
                end

                local myOrgChest = {}
                local weight = 0.0
                for k, v in pairs(dataOrgChest[data[3]][1]) do
                    if Items[v.item] then
                        v["amount"] = parseInt(v["amount"])
						v["name"] = Items[v["item"]].name
						v["peso"] = Items[v["item"]].weight
						v["index"] = v["item"]
						v["key"] = v["item"]
						v["slot"] = k
                        myOrgChest[k] = v
                        weight = weight + (Items[v.item].weight * parseInt(v["amount"]))
                    end
                end
                OpennedChestUser[user_id] = { tipo = "GROUP", name = data[3] }
                OpennedOrg[data[3]] = user_id
                return { inventory = myOrgChest, weight = weight, max_weight = Chests[data[3]].weight }
            else
                TriggerClientEvent("Notify", source, "negado", "Você não tem permissão para acessar esse bau!", 8000)
            end


        end
    end
end


RegisterNetEvent("mirtin:openHouseChest")
AddEventHandler("mirtin:openHouseChest", function(houseID)
    local source = source
    local user_id = vRP.getUserId(source)
    if not user_id then return end

  

    -- local chestKey = "houseChest:" .. houseID

    -- -- 🔍 Verifica se o baú da casa já existe no banco de dados
    -- local rows = MySQL.query.await("SELECT dvalue FROM vrp_srv_data WHERE dkey = ?", { chestKey })

    -- if not rows or #rows == 0 then
    --     -- 🚀 Criando um novo baú vazio no banco de dados
    --     MySQL.execute("INSERT INTO vrp_srv_data (dkey, dvalue) VALUES (?, ?)", { chestKey, json.encode({}) })

    --     -- 🔔 Notifica o jogador e pede para tentar novamente
    --     TriggerClientEvent("Notify", source, "aviso", "Baú criado! Tente abrir novamente.", 5000)
    --     return
    -- end

    -- -- 📦 Se o baú já existir, obtém os itens armazenados
    -- local chestData = json.decode(rows[1].dvalue) or {}

    -- -- 🏡 Obtém a capacidade do baú (minBau) da tabela `mirtin_homes`
    -- local houseData = MySQL.query.await("SELECT minBau FROM mirtin_homes WHERE id = ?", { houseID })
    
    -- local maxWeight = 5000 -- Define um valor padrão caso não encontre no banco
    -- if houseData and #houseData > 0 then
    --     maxWeight = houseData[1].minBau or 5000
    -- end

    -- -- 🔥 Envia os dados do baú para o cliente abrir a NUI
    -- local chestInfo = {
    --     chest_type = "HOUSE",
    --     inventory = chestData,
    --     maxWeight = maxWeight
    -- }

    -- print("SERVER: Enviando dados do baú para o cliente:", json.encode(chestInfo, { indent = true }))
    -- TriggerClientEvent("mirtin:openInventory", source, chestInfo)


    local chestKey = "houseChest:" .. houseID
    local user_id = vRP.getUserId(source)

    -- 🔍 Verifica se o baú da casa já existe no banco de dados
    local rows = MySQL.query.await("SELECT dvalue FROM vrp_srv_data WHERE dkey = ?", { chestKey })

    if not rows or #rows == 0 then
        -- 🚀 Criando um novo baú vazio no banco de dados
        MySQL.execute("INSERT INTO vrp_srv_data (dkey, dvalue) VALUES (?, ?)", { chestKey, json.encode({}) })

        -- 🔔 Notifica o jogador e pede para tentar novamente
        TriggerClientEvent("Notify", source, "aviso", "Baú criado! Tente abrir novamente.", 5000)
        return
    end

    -- 📦 Se o baú já existir, obtém os itens armazenados
    local chestData = json.decode(rows[1].dvalue) or {}

    -- 🏡 Obtém a capacidade do baú (minBau) da tabela `mirtin_homes`
    local houseData = MySQL.query.await("SELECT minBau FROM mirtin_homes WHERE id = ?", { houseID })

    local maxWeight = 5000 -- Define um valor padrão caso não encontre no banco
    if houseData and #houseData > 0 then
        maxWeight = houseData[1].minBau or 5000
    end

    -- 🔥 Constrói o inventário e calcula o peso
    local myHouseChest = {}
    local weight = 0.0
    for k, v in pairs(chestData) do
        if Items[v.item] then
            v["amount"] = parseInt(v["amount"])
            v["name"] = Items[v["item"]].name
            v["peso"] = Items[v["item"]].weight
            v["index"] = v["item"]
            v["key"] = v["item"]
            v["slot"] = k
            myHouseChest[k] = v
            weight = weight + (Items[v.item].weight * parseInt(v["amount"]))
        end
    end

    -- 🔥 Envia os dados do baú para o cliente abrir a NUI
    local chestInfo = {
        chest_type = "HOUSE",
        inventory = myHouseChest,
        weight = weight,
        maxWeight = maxWeight
    }

    -- print("SERVER: Enviando dados do baú para o cliente:", json.encode(chestInfo, { indent = true }))
    TriggerClientEvent("mirtin:openInventory", source, chestInfo)


end)


-- RegisterNetEvent("mirtin:closeChest")
-- AddEventHandler("mirtin:closeChest", function(chestType, chestID, inventory)
--     local source = source
--     local user_id = vRP.getUserId(source)
--     if not user_id then return end

--     local chestKey
--     if chestType == "HOUSE" then
--         chestKey = "houseChest:" .. chestID
--     elseif chestType == "GROUP" then
--         chestKey = "orgChest:" .. chestID
--     else
--         return
--     end

--     local jsonData = json.encode(inventory)
--     print("SERVER: Salvando baú automaticamente ao fechar:", chestKey, jsonData) -- ✅ DEBUG

--     local exists = MySQL.scalar.await("SELECT COUNT(*) FROM vrp_srv_data WHERE dkey = ?", { chestKey })

--     if exists and exists > 0 then
--         MySQL.execute("UPDATE vrp_srv_data SET dvalue = ? WHERE dkey = ?", { jsonData, chestKey })
--         print("SERVER: Baú atualizado no banco!") -- ✅ DEBUG
--     else
--         MySQL.insert("INSERT INTO vrp_srv_data (dkey, dvalue) VALUES (?, ?)", { chestKey, jsonData })
--         print("SERVER: Novo baú criado no banco!") -- ✅ DEBUG
--     end
-- end)


RegisterTunnel.storeChestItem = function(playerslot, amount, targetslot)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if GetPlayerPing(source) > 0 then
            local identity = vRP.getUserIdentity(user_id)
            local inv = vRP.getInventory(user_id)
			if inv[playerslot].item == "money" then
				TriggerClientEvent("Notify", source, "negado", "Você não pode fazer isso com esse item.", 6000)
				return { error = { "Você não pode fazer isso com esse item." } }
			end
            if OpennedChestUser[user_id] and OpennedChestUser[user_id].tipo == "VEHICLE" then
                local bau = OpennedChestUser[user_id].name
                if OpennedVehicle[bau] and OpennedVehicle[bau] == user_id and dataVehicle[bau][1] ~= nil then
                    print("dataVehicle[bau][1] ~= nil")
                    if vRP.computeItemsWeight(dataVehicle[bau][1]) + vRP.getItemWeight(inv[playerslot].item) * parseInt(amount) <= vRP.getVehicleTrunk(OpennedChestUser[user_id].vehname) then
                        if vRP.tryGetInventoryItem(user_id, inv[playerslot].item, amount, true, playerslot) then
                            if dataVehicle[bau][1][tostring(targetslot)] then
                                dataVehicle[bau][1][tostring(targetslot)].amount = dataVehicle[bau][1][tostring(targetslot)].amount + amount
                            else
                                dataVehicle[bau][1][tostring(targetslot)] = { amount = amount, item = inv[playerslot].item }
                                vRP.sendLog("https://discord.com/api/webhooks/1279010420342001767/YWrYtXeKJAQvZmCNcOjW4PX8nwOTSC5iInmLcJ0_8o0jS85zqIJUxxJtSB8-vd8tZ-wa","O ID " .. user_id .. " colocou o ITEM: "..inv[playerslot].item.." no bau do CARRO: "..dataVehicle[bau][2].." PLACA: "..dataVehicle[bau][3].." na quantidade de " .. amount .."x.")
                            end
                        end
                    else
                        return { error = "Porta malas cheio."}
                    end
                else
                    return { error = "1 Você não está com esse bau aberto" }
                end
            elseif OpennedChestUser[user_id] and OpennedChestUser[user_id].tipo == "GROUP" then
                local bau = OpennedChestUser[user_id].name
                if OpennedOrg[bau] and OpennedOrg[bau] == user_id and dataOrgChest[bau][1] ~= nil then
                    if vRP.computeItemsWeight(dataOrgChest[bau][1]) + vRP.getItemWeight(inv[playerslot].item) * parseInt(amount) <= Chests[bau].weight then
                        if vRP.tryGetInventoryItem(user_id, inv[playerslot].item, amount, true, playerslot) then
                            -- if Chests[orgname].weebhook then
						    --     if Chests[orgname].weebhook ~= nil then
                            --         vRP.sendLog(Chests[orgname].weebhook, "```css\n["..orgname.."]\nO (ID: "..user_id..") Colocou o item:("..vRP.getItemName(inv[playerslot].item)..") Na quantidade ("..amount..")```")
                            --     end
                            -- end
                            if dataOrgChest[bau][1][tostring(targetslot)] then
                                dataOrgChest[bau][1][tostring(targetslot)].amount = dataOrgChest[bau][1][tostring(targetslot)].amount + amount
                            else
                                dataOrgChest[bau][1][tostring(targetslot)] = { amount = amount, item = inv[playerslot].item }
                            end
                            vRP.sendLog("https://discord.com/api/webhooks/1279010555952234598/dDJ-nA4r7mQZla6Seh6--rlt5Hv-M_GJbCG4BHxP-Z21rrVcirSgXjuhS9oTUEv_bO3l","O ID " .. user_id .. " colocou o ITEM: "..inv[playerslot].item.." no bau da FACS: "..bau.." na quantidade de " .. amount .."x.")
                            vRP.execute("sjr/insertLog", {nome = identity.nome.." "..identity.sobrenome, passaporte = user_id, cargo = vRP.getUserGroupByType(user_id,'org'), bau = bau, item = inv[playerslot].item, qtd = amount, acao = 'guardou'})
                        end
                    else
                        return { error = "Bau está cheio."}
                    end
                else
                    return { error = "2 Você não está com esse bau aberto" }
                end
            elseif OpennedChestUser[user_id] and OpennedChestUser[user_id].tipo == "HOUSE" then
                local bau = OpennedChestUser[user_id].name
                if OpennedHouse[bau] and OpennedHouse[bau] == user_id and dataHouseChest[bau][1] ~= nil then
                    if vRP.computeItemsWeight(dataHouseChest[bau][1]) + vRP.getItemWeight(inv[playerslot].item) * parseInt(amount) <= parseInt(dataHouseChest[bau][3]) then
                        if vRP.tryGetInventoryItem(user_id, inv[playerslot].item, amount, true, playerslot) then
                            if dataHouseChest[bau][1][tostring(targetslot)] then
                                dataHouseChest[bau][1][tostring(targetslot)].amount = dataHouseChest[bau][1][tostring(targetslot)].amount + amount
                            else
                                dataHouseChest[bau][1][tostring(targetslot)] = { amount = amount, item = inv[playerslot].item }
                            end
                        end
                        vRP.sendLog("https://discord.com/api/webhooks/1279010668221300787/f-wBdMcgh32JU7tSYXXPE19rFfXNhuagqvUeUmXwU0jSqmFjTLnQTBstb1N6rThdC5S-","O ID " .. user_id .. " colocou o ITEM: "..inv[playerslot].item.." no bau da CASA: "..bau.." na quantidade de " .. amount .."x.")
                    else
                        return { error = "Bau está cheio."}
                    end
                else
                    return { error = "3 Você não está com esse bau aberto" }
                end
            end
		end
	end
end

RegisterTunnel.takeChestItem = function(item, amount, playerslot, slot)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if GetPlayerPing(source) > 0 then
            local identity = vRP.getUserIdentity(user_id)
			if OpennedChestUser[user_id] and OpennedChestUser[user_id].tipo == "VEHICLE" then
                local bau = OpennedChestUser[user_id].name
				if OpennedVehicle[bau] and dataVehicle[bau] and OpennedVehicle[bau] == user_id and dataVehicle[bau][1][tostring(slot)] and dataVehicle[bau][1][tostring(slot)].item ~= nil then
                    if dataVehicle[bau][1][tostring(slot)].amount >= amount then
                        if vRP.computeInvWeight(user_id) + vRP.getItemWeight(tostring(dataVehicle[bau][1][tostring(slot)].item)) * parseInt(amount) <= vRP.getInventoryMaxWeight(user_id) then
                            vRP.giveInventoryItem(user_id, dataVehicle[bau][1][tostring(slot)].item,amount, true, playerslot)
                            vRP.sendLog("https://discord.com/api/webhooks/1279010420342001767/YWrYtXeKJAQvZmCNcOjW4PX8nwOTSC5iInmLcJ0_8o0jS85zqIJUxxJtSB8-vd8tZ-wa","O ID " .. user_id .. " retirou o ITEM: "..dataVehicle[bau][1][tostring(slot)].item.." no bau do CARRO: "..dataVehicle[bau][2].." PLACA: "..dataVehicle[bau][3].." na quantidade de " .. amount .."x.")

                            dataVehicle[bau][1][tostring(slot)].amount = dataVehicle[bau][1][tostring(slot)].amount - amount
                            if dataVehicle[bau][1][tostring(slot)].amount <= 0 then
                                dataVehicle[bau][1][tostring(slot)] = nil
                            end
                            return { success = "Item retirado com sucesso" }
                        else
                            return { error = "Mochila cheia." }
                        end
                    else
                        return { error = "Você está tentando dumpar itens." }
                    end
				else
					return { error = "4 Você não está com esse bau aberto." }
				end
            elseif OpennedChestUser[user_id] and OpennedChestUser[user_id].tipo == "GROUP" then
                local bau = OpennedChestUser[user_id].name
				if OpennedOrg[bau] and dataOrgChest[bau] and OpennedOrg[bau] == user_id and dataOrgChest[bau][1][tostring(slot)] and dataOrgChest[bau][1][tostring(slot)].item ~= nil then
                    if dataOrgChest[bau][1][tostring(slot)].amount >= amount then
                        if vRP.computeInvWeight(user_id) + vRP.getItemWeight(tostring(dataOrgChest[bau][1][tostring(slot)].item)) * parseInt(amount) <= vRP.getInventoryMaxWeight(user_id) then
                            vRP.giveInventoryItem(user_id, dataOrgChest[bau][1][tostring(slot)].item,amount, true, playerslot)
                            vRP.sendLog("https://discord.com/api/webhooks/1279010555952234598/dDJ-nA4r7mQZla6Seh6--rlt5Hv-M_GJbCG4BHxP-Z21rrVcirSgXjuhS9oTUEv_bO3l","O ID " .. user_id .. " retirou o ITEM: "..dataOrgChest[bau][1][tostring(slot)].item.." do bau da FACS: "..bau.." na quantidade de " .. amount .."x.")
                            vRP.execute("sjr/insertLog", {nome = identity.nome.." "..identity.sobrenome, passaporte = user_id, cargo = vRP.getUserGroupByType(user_id,'org'), bau = bau, item = dataOrgChest[bau][1][tostring(slot)].item, qtd = amount, acao = 'retirou'})
                            dataOrgChest[bau][1][tostring(slot)].amount = dataOrgChest[bau][1][tostring(slot)].amount - amount
                            if dataOrgChest[bau][1][tostring(slot)].amount <= 0 then
                                dataOrgChest[bau][1][tostring(slot)] = nil
                            end
                            -- if Chests[orgname].weebhook then
						    --     if Chests[orgname].weebhook ~= nil then
                            --         vRP.sendLog(Chests[orgname].weebhook,"```css\n["..orgname.."]\nO (ID: "..user_id..") Retirou o item:("..vRP.getItemName(tostring(dataOrgChest[bau][1][tostring(slot)].item))..") Na quantidade ("..amount..")```")
                            --     end
                            -- end
                            return { success = "Item retirado com sucesso" }
                        else
                            return { error = "Mochila cheia." }
                        end
                    else
                        return { error = "Você está tentando dumpar itens." }
                    end
				else
					return { error = "5 Você não está com esse bau aberto." }
				end
            elseif OpennedChestUser[user_id] and OpennedChestUser[user_id].tipo == "HOUSE" then
                
                local bau = OpennedChestUser[user_id].name
				if OpennedHouse[bau] and dataHouseChest[bau] and OpennedHouse[bau] == user_id and dataHouseChest[bau][1][tostring(slot)] and dataHouseChest[bau][1][tostring(slot)].item ~= nil then
                    if dataHouseChest[bau][1][tostring(slot)].amount >= amount then
                    
                        if vRP.computeInvWeight(user_id) + vRP.getItemWeight(tostring(dataHouseChest[bau][1][tostring(slot)].item)) * parseInt(amount) <= vRP.getInventoryMaxWeight(user_id) then
                            vRP.giveInventoryItem(user_id, dataHouseChest[bau][1][tostring(slot)].item,amount, true, playerslot)
                            vRP.sendLog("https://discord.com/api/webhooks/1279010668221300787/f-wBdMcgh32JU7tSYXXPE19rFfXNhuagqvUeUmXwU0jSqmFjTLnQTBstb1N6rThdC5S-","O ID " .. user_id .. " retirou o ITEM: "..dataHouseChest[bau][1][tostring(slot)].item.." do bau da CASA: "..bau.." na quantidade de " .. amount .."x.")
                            
                            dataHouseChest[bau][1][tostring(slot)].amount = dataHouseChest[bau][1][tostring(slot)].amount - amount
                            if dataHouseChest[bau][1][tostring(slot)].amount <= 0 then
                                dataHouseChest[bau][1][tostring(slot)] = nil
                            end
                            return { success = "Item retirado com sucesso" }
                        else
                            return { error = "Mochila cheia." }
                        end
                    else
                        return { error = "Você está tentando dumpar itens." }
                    end
				else
					return { error = "6 Você não está com esse bau aberto." }
				end
			end
		end
	end
end


RegisterCommand('organizar', function(source, args)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if vRP.hasPermission(user_id, 'admin.permissao') then
            local value = vRP.setOrganizing(user_id)
            if value then
                TriggerClientEvent('Notify', source, "sucesso", "Modo organizador ativado.",6000)
            else
                TriggerClientEvent('Notify', source, "sucesso", "Modo organizador desativado.",6000)
            end
        else
            TriggerClientEvent('Notify', source, "negado", "Você não tem acesso a esse comando.",6000)
        end
    end
end)


local openedRoubar = {}
local refusedRoubar = {}

RegisterCommand('roubar', function(source, args, rawCommand)
    local user_id = vRP.getUserId(source)
    local nplayer = vRPclient.getNearestPlayer(source, 5)
    local nuser_id = vRP.getUserId(nplayer)

    if vRPclient.isHandcuffed(source) or arena.inArena(source) then
        TriggerClientEvent('Notify', source, "negado", "Você não pode roubar agora.", 6000)
        return
    end

    if vTunnel.inVehicle(source) then
        TriggerClientEvent('Notify', source, "negado", "Você não pode roubar dentro do veículo.", 6000)
        return
    end

    if user_id then
        if vRP.hasPermission(nuser_id, 'perm.policia') then
            TriggerClientEvent('Notify', source, "negado", "Você não pode roubar um policial.", 6000)
            return
        end
        if refusedRoubar[nuser_id] and os.time() - refusedRoubar[nuser_id] < 30 then
            TriggerClientEvent('Notify', source, "negado", "O player recusou o roubo recentemente e não pode ser roubado agora.", 6000)
            return
        end
        local request = false
        if vRPclient.getHealth(nplayer) <= 101 then
            request = true
            vRPclient._playAnim(source, false, {{"amb@medic@standing@tendtodead@idle_a", "idle_a"}}, true)
            TriggerClientEvent('Notify', nplayer, "negado", "Você está sendo roubado.")
        else
            request = vRP.request(nplayer, 'Você aceita ser roubado?', 15)
        end

        if request then
            if nplayer and nuser_id then
                local identity = vRP.getUserIdentity(nuser_id)
                local name = identity.nome .. " " .. identity.sobrenome
                local inv = vRP.getInventory(user_id)
                local myInventory = {}
                local myweight = 0.0
                if inv then
                    for k, v in pairs(inv) do
                        if Items[v["item"]] then
                            v["amount"] = parseInt(v["amount"])
                            v["name"] = Items[v["item"]].name
                            v["peso"] = Items[v["item"]].weight
                            v["index"] = v["item"]
                            v["key"] = v["item"]
                            v["slot"] = k

                            myInventory[k] = v
                            myweight = myweight + (Items[v["item"]].weight * parseInt(v["amount"]))
                        end
                    end
                end

                local weapons = vRPclient.replaceWeapons(nplayer, {})
                for k, v in pairs(weapons) do
                    vRP.giveInventoryItem(nuser_id, k, 1, true)
                    if v.ammo > 0 then
                        local weapon = string.gsub(k, "WEAPON_", "AMMO_")
                        vRP.giveInventoryItem(nuser_id, weapon, v.ammo, true)
                    end
                end

                local inv2 = vRP.getInventory(nuser_id)
                local myHouseChest = {}
                local weight = 0.0

                for k, v in pairs(inv2) do
                    if Items[v["item"]] then
                        v["amount"] = parseInt(v["amount"])
                        v["name"] = Items[v["item"]].name
                        v["peso"] = Items[v["item"]].weight
                        v["index"] = v["item"]
                        v["key"] = v["item"]
                        v["slot"] = k
                        myHouseChest[k] = v
                        weight = weight + (Items[v["item"]].weight * parseInt(v["amount"]))
                    end
                end

                vTunnel.SetInventoryBlocked(nplayer, 0)
                func:setBlockCommand(nuser_id, 0)
                func:setBlockCommand(source, 0)
                openedRoubar[user_id] = nuser_id
                vTunnel.openInspect(source, {
                    source = {
                        inventory = myInventory,
                        weight = myweight,
                        max_weight = vRP.getInventoryMaxWeight(user_id)
                    },
                    target = {
                        inventory = myHouseChest,
                        weight = weight,
                        max_weight = vRP.getInventoryMaxWeight(nuser_id),
                        target_name = name
                    }
                })

                TriggerClientEvent('Notify', source, "sucesso", "Você está roubando.", 5000)
                TriggerClientEvent('Notify', nplayer, "negado", "Você está sendo roubado.", 5000)

                if vRPclient.getHealth(nplayer) > 101 then
                    vRPclient._playAnim(source, false, {{"misscarsteal4@director_grip", "end_loop_grip"}}, true)
                    vRPclient._playAnim(nplayer, false, {{"random@mugging3", "handsup_standing_base"}}, true)
                end
            else
                TriggerClientEvent('Notify', source, "negado", "Nenhum jogador próximo encontrado.", 5000)
            end
        else
            TriggerClientEvent('Notify', source, "negado", "O player recusou seu pedido de roubo.", 5000)
            refusedRoubar[nuser_id] = os.time()
        end
    end
end)


local openedRevistar = {}
local refusedRevistar = {}

RegisterServerEvent('target:revistar')
AddEventHandler('target:revistar', function()
    local source = source
    local user_id = vRP.getUserId(source)
    local nplayer = vRPclient.getNearestPlayer(source, 5)
    local nuser_id = vRP.getUserId(nplayer)

    if vRPclient.isHandcuffed(source) or arena.inArena(source) then
        TriggerClientEvent('Notify', source, "negado", "Você não pode revistar agora.", 6000)
        return
    end

    if vTunnel.inVehicle(source) then
        TriggerClientEvent('Notify', source, "negado", "Você não pode revistar dentro do veículo.", 6000)
        return
    end

    if user_id then
        if vRP.hasPermission(nuser_id, 'perm.policia') then
            TriggerClientEvent('Notify', source, "negado", "Você não pode revistar um policial.", 6000)
            return
        end
        if refusedRevistar[nuser_id] and os.time() - refusedRevistar[nuser_id] < 30 then
            TriggerClientEvent('Notify', source, "negado", "O player recusou a revista recentemente e não pode ser revistado agora.", 6000)
            return
        end

        local request = false
        if vRPclient.getHealth(nplayer) <= 101 then
            request = true
            vRPclient._playAnim(source, false, {{"amb@medic@standing@tendtodead@idle_a", "idle_a"}}, true)
            TriggerClientEvent('Notify', nplayer, "negado", "Você está sendo revistado.")
        elseif vRP.hasPermission(user_id, 'perm.disparo') then
            request = true
        else
            request = vRP.request(nplayer, 'Você aceita ser revistado?', 15)
        end

        if request then
            if nplayer and nuser_id then
                local identity = vRP.getUserIdentity(nuser_id)
                local name = identity.nome .. " " .. identity.sobrenome
                local inv = vRP.getInventory(user_id)
                local myInventory = {}
                local myweight = 0.0
                if inv then
                    for k, v in pairs(inv) do
                        if Items[v["item"]] then
                            v["amount"] = parseInt(v["amount"])
                            v["name"] = Items[v["item"]].name
                            v["peso"] = Items[v["item"]].weight
                            v["index"] = v["item"]
                            v["key"] = v["item"]
                            v["slot"] = k

                            myInventory[k] = v
                            myweight = myweight + (Items[v["item"]].weight * parseInt(v["amount"]))
                        end
                    end
                end

                local weapons = vRPclient.replaceWeapons(nplayer, {})
                for k, v in pairs(weapons) do
                    vRP.giveInventoryItem(nuser_id, k, 1, true)
                    if v.ammo > 0 then
                        local weapon = string.gsub(k, "WEAPON_", "AMMO_")
                        vRP.giveInventoryItem(nuser_id, weapon, v.ammo, true)
                    end
                end

                local inv2 = vRP.getInventory(nuser_id)
                local myHouseChest = {}
                local weight = 0.0

                for k, v in pairs(inv2) do
                    if Items[v["item"]] then
                        v["amount"] = parseInt(v["amount"])
                        v["name"] = Items[v["item"]].name
                        v["peso"] = Items[v["item"]].weight
                        v["index"] = v["item"]
                        v["key"] = v["item"]
                        v["slot"] = k
                        myHouseChest[k] = v
                        weight = weight + (Items[v["item"]].weight * parseInt(v["amount"]))
                    end
                end

                vTunnel.SetInventoryBlocked(nplayer, 0)
                func:setBlockCommand(nuser_id, 0)
                func:setBlockCommand(source, 0)
                openedRevistar[user_id] = nuser_id
                vTunnel.openInspect(source, {source = {inventory = myInventory, weight = myweight, max_weight = vRP.getInventoryMaxWeight(user_id)}, target = {inventory = myHouseChest, weight = weight, max_weight = vRP.getInventoryMaxWeight(nuser_id), target_name = name}})
                TriggerClientEvent('Notify', source, "sucesso", "Você está revistando.", 5000)
                TriggerClientEvent('Notify', nplayer, "negado", "Você está sendo revistado.", 5000)
                if vRPclient.getHealth(nplayer) > 101 then
                    vRPclient._playAnim(source, false, {{"misscarsteal4@director_grip", "end_loop_grip"}}, true)
                    vRPclient._playAnim(nplayer, false, {{"random@mugging3", "handsup_standing_base"}}, true)
                end
            else
                TriggerClientEvent('Notify', source, "negado", "Você não possui nenhum player próximo.", 5000)
            end
        else
            TriggerClientEvent('Notify', source, "negado", "O player recusou seu pedido de revista.", 5000)
            refusedRevistar[nuser_id] = os.time()
        end
    end
end)


RegisterTunnel.emitCloseListeners = function()
    local source = source
    local nplayer = vRPclient.getNearestPlayer(source, 5)
    local nuser_id = vRP.getUserId(nplayer)
    local user_id = vRP.getUserId(source)
    if user_id then
        if OpennedChestUser[user_id] then
            if OpennedChestUser[user_id].tipo == "HOUSE" then
                OpennedHouse[OpennedChestUser[user_id].name] = nil
                vRPclient._stopAnim(source, false)
            elseif OpennedChestUser[user_id].tipo == "VEHICLE" then
                OpennedVehicle[OpennedChestUser[user_id].name] = nil
                vRPclient._stopAnim(source, false)
            elseif OpennedChestUser[user_id].tipo == "GROUP" then
                OpennedOrg[OpennedChestUser[user_id].name] = nil
                vRPclient._stopAnim(source, false)
            end
        end
        if openedRevistar[user_id] then
            vTunnel.SetInventoryBlocked(nplayer, 0)
            openedRevistar[user_id] = nil
            func:setBlockCommand(nuser_id, 0)
            func:setBlockCommand(source, 0)
            vRPclient._stopAnim(source, false)
            vRPclient._stopAnim(nplayer, false)
        end
    end
end

local itensblock = {
	["algemas"] = true,
	["chave_algemas"] = true,
	["c4"] = true,
	["masterpick"] = true,
	["pendrive"] = true,
	["furadeira"] = true,
	["lockpick"] = true,
	["m-aco"] = true,
	["m-capa_colete"] = true,
	["m-corpo_ak47_mk2"] = true,
	["m-corpo_g3"] = true,
	["m-corpo_machinepistol"] = true,
	["m-corpo_pistol_mk2"] = true,
	["m-corpo_shotgun"] = true,
	["m-corpo_smg_mk2"] = true,
	["m-corpo_snspistol_mk2"] = true,
	["m-gatilho"] = true,
	["capsulas"] = true,
	["polvora"] = true,
	["pecadearma"] = true,
	["metal"] = true,
	["molas"] = true,
	["gatilho"] = true,
	["m-malha"] = true,
	["m-placametal"] = true,
	["m-tecido"] = true,
	["c-cobre"] = true,
	["c-ferro"] = true,
	["c-fio"] = true,
	["c-polvora"] = true,
	["l-alvejante"] = true,
	["folhamaconha"] = true,
	["maconha"] = true,
	["pastabase"] = true,
	["cocaina"] = true,
	["acidolsd"] = true,
	["colete"] = true,
	["capuz"] = true,
	["dinheirosujo"] = true,
	["scubagear"] = true,
	["relogioroubado"] = true,
	["colarroubado"] = true,
	["anelroubado"] = true,
	["brincoroubado"] = true,
	["pulseiraroubada"] = true,
	["carnedepuma"] = true,
	["carnedelobo"] = true,
	["carnedejavali"] = true,
	["lsd"] = true,
	["morfina"] = true,
	["heroina"] = true,
	["anfetamina"] = true,
	["metanfetamina"] = true,
	["tartaruga"] = true,
	["WEAPON_SNSPISTOL_MK2"] = true,
	["WEAPON_COMBATMG_MK2"] = true,
	["AMMO_SNSPISTOL_MK2"] = true,
	["WEAPON_PISTOL_MK2"] = true,
	["WEAPON_GUSENBERG"] = true,
	["WEAPON_PISTOL50"] = true,
	["WEAPON_HEAVYPISTOL"] = true,
	["WEAPON_HATCHET"] = true,
	["AMMO_PISTOL_MK2"] = true,
	["WEAPON_COMBATPISTOL"] = true,
	["WEAPON_COMBATPDW"] = true,
	["AMMO_COMBATPISTOL"] = true,
	["WEAPON_MACHINEPISTOL"] = true,
	["AMMO_MACHINEPISTOL"] = true,
	["WEAPON_SMG_MK2"] = true,
	["AMMO_SMG_MK2"] = true,
	["WEAPON_SMG"] = true,
	["AMMO_SMG"] = true,
	["WEAPON_ASSAULTSMG"] = true,
	["AMMO_ASSAULTSMG"] = true,
	["WEAPON_SAWNOFFSHOTGUN"] = true,
	["AMMO_SAWNOFFSHOTGUN"] = true,
	["WEAPON_PUMPSHOTGUN_MK2"] = true,
	["AMMO_PUMPSHOTGUN_MK2"] = true,
	["WEAPON_ASSAULTRIFLE_MK2"] = true,
	["AMMO_ASSAULTRIFLE_MK2"] = true,
	["WEAPON_SPECIALCARBINE_MK2"] = true,
	["AMMO_SPECIALCARBINE_MK2"] = true,
	["WEAPON_CARBINERIFLE"] = true,
	["AMMO_CARBINERIFLE"] = true,
	["WEAPON_SPECIALCARBINE"] = true,
	["AMMO_SPECIALCARBINE"] = true,
	["WEAPON_STUNGUN"] = true,
	["WEAPON_PETROLCAN"] = true,
	["AMMO_PETROLCAN"] = true,
}


RegisterTunnel.takeInspectItem = function(target, slot, amount)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
        if openedRevistar[user_id] then
            local id = parseInt(openedRevistar[user_id])
            local nplayer = vRP.getUserSource(id)
            if nplayer then
                local inv = vRP.getInventory(id)
                if not inv then return end
                local item = inv[target].item
                if vRP.hasPermission(user_id, "perm.policia") or vRP.hasPermission(user_id, "perm.disparo") then
                    if itensblock[item] ~= nil then
                        return { error = "Você não pode pegar esse item de bandidos." }
                    end
                end
    
                if item == "WEAPON_STUNGUN" then
                    return { error = "Você não pode pegar esse item." }
                end
    
                if vRP.computeInvWeight(user_id) + vRP.getItemWeight(tostring(item)) * parseInt(amount) <= vRP.getInventoryMaxWeight(user_id) then
                    if vRP.tryGetInventoryItem(id, item, amount, true, target) then
                        vRP.giveInventoryItem(user_id, item, amount, true, slot)
                        vRP.sendLog("SAQUEAR","O ID "..user_id .."saqueou o item ".. vRP.getItemName(item) .. "na quantidade ".. amount .. "x do ID "..id .. ".")
                            return { success = "Você pegou o item com sucesso." }
                    end
                else
                    return { error = "Mochila cheia." }
                end
            end
        end
	end
end

RegisterTunnel.takeInspectItem = function(target, slot, amount)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if openedRoubar[user_id] then  -- Troquei openedRevistar por openedRoubar
            local id = parseInt(openedRoubar[user_id])  -- Obtendo o id do jogador que está sendo roubado
            local nplayer = vRP.getUserSource(id)
            if nplayer then
                local inv = vRP.getInventory(id)
                if not inv then return end
                local item = inv[target].item
                if vRP.hasPermission(user_id, "perm.policia") or vRP.hasPermission(user_id, "perm.disparo") then
                    if itensblock[item] ~= nil then
                        return { error = "Você não pode pegar esse item de bandidos." }
                    end
                end

                if item == "WEAPON_STUNGUN" then
                    return { error = "Você não pode pegar esse item." }
                end

                if vRP.computeInvWeight(user_id) + vRP.getItemWeight(tostring(item)) * parseInt(amount) <= vRP.getInventoryMaxWeight(user_id) then
                    if vRP.tryGetInventoryItem(id, item, amount, true, target) then
                        vRP.giveInventoryItem(user_id, item, amount, true, slot)
                        vRP.sendLog("ROUBO", "O ID " .. user_id .. " pegou o item " .. vRP.getItemName(item) .. " na quantidade " .. amount .. "x do ID " .. id .. ".")
                        return { success = "Você pegou o item com sucesso." }
                    end
                else
                    return { error = "Mochila cheia." }
                end
            end
        end
    end
end



RegisterTunnel.putInspectItem = function(target, slot, amount)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
        if openedRevistar[user_id] then
            local id = parseInt(openedRevistar[user_id])
            local nplayer = vRP.getUserSource(id)
            if nplayer then
                local inv = vRP.getInventory(user_id)
                if not inv then return end
                local item = inv[target].item
                if vRP.computeInvWeight(id) + vRP.getItemWeight(tostring(item)) * parseInt(amount) <= vRP.getInventoryMaxWeight(id) then
                    if vRP.tryGetInventoryItem(user_id, item, amount, true, target) then
                        vRP.giveInventoryItem(id, item, amount, true, slot)
                        vRP.sendLog("SAQUEAR","O ID " ..user_id .." colocou o item " .. vRP.getItemName(item) .. " na quantidade " .. amount .. "x do ID " ..id .. " no ID "..id..".")
                        return { success = "Você colocou o item com sucesso." }
                    end
                else
                    return { error = "Mochila cheia." }
                end
            end
        end
	end
end

RegisterTunnel.putInspectItem = function(target, slot, amount)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if openedRoubar[user_id] then  -- Troquei openedRevistar por openedRoubar
            local id = parseInt(openedRoubar[user_id])  -- Obtendo o id do jogador que está sendo roubado
            local nplayer = vRP.getUserSource(id)
            if nplayer then
                local inv = vRP.getInventory(user_id)
                if not inv then return end
                local item = inv[target].item
                if vRP.computeInvWeight(id) + vRP.getItemWeight(tostring(item)) * parseInt(amount) <= vRP.getInventoryMaxWeight(id) then
                    if vRP.tryGetInventoryItem(user_id, item, amount, true, target) then
                        vRP.giveInventoryItem(id, item, amount, true, slot)
                        vRP.sendLog("ROUBO", "O ID " .. user_id .. " colocou o item " .. vRP.getItemName(item) .. " na quantidade " .. amount .. "x no ID " .. id .. ".")
                        return { success = "Você colocou o item com sucesso." }
                    end
                else
                    return { error = "Mochila cheia." }
                end
            end
        end
    end
end


function save_vehicles_chest()
    local count = 0

    for k in pairs(dataVehicle) do
        local nuser_id = vRP.getUserByRegistration(dataVehicle[k][3])
        if nuser_id then
            if not dataVehicle[k][4] then
                if dataVehicle[k][5] then
              
                    if OpennedVehicle[dataVehicle[k][3]..":"..dataVehicle[k][2]] == nil then
                        MySQL.update.await("UPDATE vehicle_chests SET portamalas = ? WHERE user_id = ? AND vehicle = ?", {
                            json.encode(dataVehicle[k][1]), nuser_id, string.lower(dataVehicle[k][2])
                        })
                        dataVehicle[k] = nil
                        count = count + 1
                    end
                else
                   
                    if OpennedVehicle[dataVehicle[k][3]..":"..dataVehicle[k][2]] == nil then
                        MySQL.update.await("UPDATE vehicle_chests SET portaluvas = ? WHERE user_id = ? AND vehicle = ?", {
                            json.encode(dataVehicle[k][1]), nuser_id, string.lower(dataVehicle[k][2])
                        })
                        dataVehicle[k] = nil
                        count = count + 1
                    end
                end
            else
                if dataVehicle[k][5] then
                  
                    if OpennedVehicle[dataVehicle[k][3]..":"..dataVehicle[k][2]] == nil then
                        MySQL.update.await("UPDATE vehicle_chests SET portamalas = ? WHERE user_id = ? AND vehicle = ?", {
                            json.encode(dataVehicle[k][1]), nuser_id, string.lower(dataVehicle[k][2])
                        })
                        dataVehicle[k] = nil
                        count = count + 1
                    end
                else
              
                    if OpennedVehicle[dataVehicle[k][3]..":"..dataVehicle[k][2]] == nil then
                        MySQL.update.await("UPDATE vehicle_chests SET portaluvas = ? WHERE user_id = ? AND vehicle = ?", {
                            json.encode(dataVehicle[k][1]), nuser_id, string.lower(dataVehicle[k][2])
                        })
                        dataVehicle[k] = nil
                        count = count + 1
                    end
                end
            end
        else
            if dataVehicle[k][5] then
              
                if OpennedVehicle[dataVehicle[k][3]..":"..dataVehicle[k][2]] == nil then
                    MySQL.update.await("UPDATE vehicle_chests SET portamalas = ? WHERE user_id IS NULL AND vehicle = ?", {
                        json.encode(dataVehicle[k][1]), string.lower(dataVehicle[k][2])
                    })
                    dataVehicle[k] = nil
                    count = count + 1
                end
            else
              
                if OpennedVehicle[dataVehicle[k][3]..":"..dataVehicle[k][2]] == nil then
                    MySQL.update.await("UPDATE vehicle_chests SET portaluvas = ? WHERE user_id IS NULL AND vehicle = ?", {
                        json.encode(dataVehicle[k][1]), string.lower(dataVehicle[k][2])
                    })
                    dataVehicle[k] = nil
                    count = count + 1
                end
            end
        end
    end

    if count > 0 then
        print("^1[INVENTÁRIO] ^0Atualizado PortaMala Veículo: ^1"..count)
    end

    SetTimeout(1 * 1000, save_vehicles_chest)
end


function save_org_chest()
    local count = 0
	for k in pairs(dataOrgChest) do
		if OpennedOrg[k] == nil then
            count = count + 1
			vRP.setSData("orgChest:" .. k, json.encode(dataOrgChest[k][1]))
           
			dataOrgChest[k] = nil
		end
	end

    if count > 0 then
		print("^1[INVENTÁRIO] ^0Total de baus de facção salvo(s): ^1"..count)
	end
	SetTimeout(30 * 1000, save_org_chest)
end


function checkRG(numero)
	local rows = vRP.query("vRP/getRegistro", {registro = numero} ) or nil
	if not rows[1] then
		return true
	end
end

function checkNumber(numero)
	local rows = vRP.query("vRP/getNumber", {telefone = numero} ) or nil
	if not rows[1] then
		return true
	end
end

function formatNumber(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1-'):reverse())..right
end


function save_house_chest()
	local count = 0
	for k in pairs(dataHouseChest) do
		if OpennedHouse[k] == nil then
            count = count + 1
			vRP.execute("mirtin/updateBau", { id = k, bau = json.encode(dataHouseChest[k][1]) })
			dataHouseChest[k] = nil
		end
	end

    if count > 0 then
		print("^1[INVENTÁRIO] ^0Total de bau de casa salvo(s): ^1"..count)
	end
	SetTimeout(30 * 1000, save_house_chest)
end

CreateThread(function()
	save_org_chest()
	save_vehicles_chest()
	save_house_chest()
    Items = vRP.getAllItens()

    local query = vRP.query("vRP/get_alltable")
    if #query > 0 then
        for k,v in pairs(query) do
            Chests[v.name] = { coords = vec3(v.x,v.y,v.z), weight = parseInt(v.weight), permission = v.permiss }
        end
    end
    Wait(2000)
    vTunnel.loadChests(-1,Chests)
end)

RegisterTunnel.getItems = function()
    return Items
end

RegisterServerEvent("updateVehList")
AddEventHandler("updateVehList", function(list) 
    vehList = list
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- REPARAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("tryreparar")
AddEventHandler("tryreparar",function(nveh)
	TriggerClientEvent("syncreparar",-1,nveh)
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- REPARARMOTOR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("tryrepararMotor")
AddEventHandler("tryrepararMotor",function(nveh)
	TriggerClientEvent("syncrepararMotor",-1,nveh)
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- REPARAR PNEUS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("tryrepararpneus")
AddEventHandler("tryrepararpneus",function(nveh)
	TriggerClientEvent("syncrepararpneus",-1,nveh)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CIRURGIA ITEM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("tryresetchar")
AddEventHandler("tryresetchar",function(source)
	TriggerClientEvent("syncresetchar",-1,source)
end)

RegisterServerEvent('item:usarCapuz')
AddEventHandler('item:usarCapuz', function()
    local source = source
    local user_id = vRP.getUserId(source)
    local item = "capuz"

    if user_id then
        if vRP.getInventoryItemAmount(user_id, item) >= 1 then
            func:setBlockCommand(user_id, 6)
            local nplayer = vRPclient.getNearestPlayer(source, 5)

            if nplayer then
                local nuser_id = vRP.getUserId(nplayer)

           
                if vRPclient.isCapuz(nplayer) then
            
                    vRPclient.setCapuz(nplayer, false)
                    TriggerClientEvent("Notify", source, "sucesso", "Você retirou o capuz desse jogador.", 6000)
                else
               
                    vRPclient.setCapuz(nplayer, true)
                    TriggerClientEvent("Notify", source, "sucesso", "Você colocou o capuz nesse jogador. Para retirar, use o item novamente.", 6000)
                end

                vRP.closeMenu(nplayer) 
                vRP.sendLog("CAPUZ", "O USER_ID: " .. user_id .. " usou o capuz no USER_ID: " .. nuser_id)
            else
                TriggerClientEvent("Notify", source, "negado", "Nenhum jogador próximo.", 6000)
                TriggerClientEvent('closeInventory', source)
            end
        else
            TriggerClientEvent("Notify", source, "negado", "Você não possui um capuz.", 6000)
        end
    end
end)




-------------------------------------------------------------------------------------------
-- SISTEMA DE BEBEDOR FEITO POR FOXZIN
-------------------------------------------------------------------------------------------


function vTunnel.checkNearbyProp(source, propName)
    TriggerClientEvent('vTunnel.checkPropNearby', source, propName)
    Citizen.Wait(500) -- Dá tempo para o cliente processar a solicitação (ajustável dependendo da necessidade)
end


RegisterNetEvent('vTunnel.propNearbyStatus')
AddEventHandler('vTunnel.propNearbyStatus', function(found, propName, slot)
    local source = source
    local user_id = vRP.getUserId(source) 
    if found then
        TriggerClientEvent('Notify', source, 'sucesso', 'Dispenser de água encontrado.', 5000)
        vTunnel.SetInventoryBlocked(source, 10) -- bloque inventario para evitar flods
        func:setBlockCommand(user_id, 10)
        TriggerClientEvent("progress", source, 10000) -- Barra de progresso de 10 segundos
        vTunnel.blockButtons(source, true)
        TriggerClientEvent('vTunnel.playAnimation', source)
        SetTimeout(10000, function()
            
            if vRP.tryGetInventoryItem(user_id, "garrafavazia", 1, true, slot) then
                vRP.giveInventoryItem(user_id, "agua", 1, true)
                vTunnel.blockButtons(source, false)
                TriggerClientEvent("Notify", source, "sucesso", "Sucesso! Você encheu sua garrafinha.", 5000)
            end
        end)
    else
        TriggerClientEvent("Notify", source, "negado", "Não há dispenser de água por perto.", 5000)
        TriggerClientEvent("closeInventory", source)
    end
end)

-- RegisterNetEvent("receiveVehicleInfo")
-- AddEventHandler("receiveVehicleInfo", function(plate, model, netId, locked)
--     local source = source
--     local user_id = vRP.getUserId(source)

--     print("🔄 [SERVER] Dados recebidos do cliente:")
--     print("Placa:", plate)
--     print("Modelo:", model)
--     print("Network ID:", netId)
--     print("Está trancado:", locked)

--     if not plate then
--         print("⚠ Nenhum veículo próximo identificado.")
--         TriggerClientEvent("Notify", source, "negado", "Nenhum veículo encontrado por perto.", 6000)
--         return
--     end

--     print("📝 Buscando dono do veículo no banco de dados para a placa:", plate)

--     local plateUser = vRP.getUserByRegistration(plate)

--     if plateUser then
--         print("✔ Dono do veículo encontrado:", plateUser)
--     else
--         print("❌ Veículo sem dono registrado no banco de dados.")
--     end
-- end)


-- RegisterCommand("testarveiculo", function(source)
--     print("🔍 Testando captura de veículo...")
--     TriggerClientEvent("getNearestVehicleInfo", source)
-- end)



-- RegisterCommand("destrancar", function(source)
--     local ped = GetPlayerPed(source)
--     local pos = GetEntityCoords(ped)
--     local vehicle = GetClosestVehicle(pos.x, pos.y, pos.z, 5.0, 0, 71)

--     if DoesEntityExist(vehicle) then
--         print("🚗 Veículo encontrado para destrancamento.")
--         SetVehicleDoorsLocked(vehicle, 1) -- Destranca o veículo
--         TriggerClientEvent("Notify", source, "sucesso", "Veículo destrancado com sucesso!", 6000)
--     else
--         print("❌ Nenhum veículo próximo encontrado para destrancar.")
--         TriggerClientEvent("Notify", source, "negado", "Nenhum veículo encontrado para destrancar.", 6000)
--     end
-- end)



