RegisterTunnel = RegisterTunnel or {}

local NEAR_SHOP = false

-- Função para organizar os itens das lojas em um formato específico
local function ParseItems(items)
    local response = {}
    local count = 0
    for k, v in pairs(items) do
        count = count + 1
        response[tostring(count)] = {
            price = v, 
            item = k, 
            slot = tostring(count) 
        }
    end
    return response
end


CreateThread(function()
    for k, v in pairs(Shops) do
        Shops[k].items = ParseItems(v.items)
    end
    SearchShopThread()
end)

-- Thread que procura por lojas próximas do jogador
function SearchShopThread()
    CreateThread(function()
        while not NEAR_SHOP do
            local sleep = 1002 -- Reduz processamento
            local ply = PlayerPedId()
            local plyCds = GetEntityCoords(ply)

            for k, v in pairs(Shops) do
                for i = 1, #v.coords do
                    local distance = #(plyCds - v.coords[i])
                    if distance < 4.0 then
                        NEAR_SHOP = true
                        NearShopThread(k, i)
                    end
                end
            end

            Wait(sleep)
        end
    end)
end



-- Tabela para armazenar o cooldown por loja
local shopCooldowns = {}

function HasPermission(perm, cb)
    TriggerServerEvent("checkPermission", perm)
    RegisterNetEvent("checkPermissionResponse")
    AddEventHandler("checkPermissionResponse", function(hasPermission)
        cb(hasPermission)
    end)
end

-- Função de interação com a loja
function NearShopThread(store, coordIndex)
    CreateThread(function()
        while NEAR_SHOP do
            local sleep = 500
            local player = PlayerPedId()
            local playerCoords = GetEntityCoords(player)
            local shopCoords = Shops[store].coords[coordIndex]
            local distance = #(playerCoords - vector3(shopCoords.x, shopCoords.y, shopCoords.z))

            -- Se o jogador estiver muito longe ou com pouca saúde, fecha a loja
            if distance > 4.0 or GetEntityHealth(player) <= 101 then
                CloseShop()
                break
            end

            -- Desenha o marcador no local da loja
            DrawMarker(
                29,
                shopCoords.x, shopCoords.y, shopCoords.z - 0.4,
                0, 0, 0, 0, 180.0, 0,
                0.7, 0.7, 0.7,
                255, 255, 255, 75,
                true, false, 0, true
            )

            -- Verifica se o jogador está perto o suficiente para interagir com a loja
            if distance <= 1.3 then
                sleep = 4

                if IsControlJustPressed(0, 38) then -- Botão [E]
                    -- Verifica se o jogador está em cooldown
                    if shopCooldowns[store] and GetGameTimer() < shopCooldowns[store] then
                        local remainingTime = math.ceil((shopCooldowns[store] - GetGameTimer()) / 1000)
                        TriggerEvent("Notify", "negado", "Espere " .. remainingTime .. " segundos para tentar novamente.", 5000)
                    else
                        -- Verifica permissão do jogador antes de abrir a loja
                        if not Shops[store].perm or Shops[store].perm == "" then
                            OpenShop(store)
                        else
                            HasPermission(Shops[store].perm, function(hasPermission)
                                if hasPermission then
                                    OpenShop(store)
                                else
                                    TriggerEvent("Notify", "negado", "Você não tem permissão para acessar esta loja.", 5000)
                                    shopCooldowns[store] = GetGameTimer() + 20000 -- Adiciona 20 segundos de cooldown
                                end
                            end)
                        end
                    end
                end
            end

            Wait(sleep)
        end
    end)
end

-- Função para abrir a loja
function OpenShop(store)
    SendNUIMessage({
        route = "OPEN_SHOP",
        payload = {
            mode = Shops[store].mode, -- Modo da loja: "buy" ou "sell"
            store_name = store, -- Nome da loja
            inventory = Shops[store].items, -- Inventário da loja
        }
    })
    SetNuiFocus(true, true)
end

-- Função para fechar a loja
function CloseShop()
    NEAR_SHOP = false
    SearchShopThread() -- Reinicia a busca por lojas próximas

    SendNUIMessage({
        route = "CLOSE_INVENTORY",
        payload = false
    })
    SetNuiFocus(false, false)
end
