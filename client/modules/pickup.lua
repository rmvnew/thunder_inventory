local droplist = {}

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE DROPAR ITENS
-----------------------------------------------------------------------------------------------------------------------------------------
function API.updateDrops(id,marker)
	droplist[id] = marker
end

function API.removeDrop(id)
	if droplist[id] ~= nil then
		droplist[id] = nil
	end
end

CreateThread(function()
    while true do
        local time = 2000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        -- if vRP.isHandcuffed() then
        --     goto skip_loop
        -- end

        for k,v in pairs(droplist) do
            local distance = #(coords - vector3(v.x,v.y,v.z))
            if distance <= 4.0 and GetEntityHealth(ped) > 101 then
                time = 2
                DrawMarker(22,v.x,v.y,v.z-0.7, 0,0,0,180.0,0,0,0.3,0.3,0.3,100, 5, 84, 255,0,0,0,20)
                    if distance < 1.0 then 
                        DrawText3D(v.x, v.y, v.z - 0.4, "Pressione ~q~[E] ~w~para pegar~q~ " .. v.count .. "x " .. v.item)
                    end

                    if IsControlJustPressed(0, 38) then 
                        Remote.pegarItem(k)
                        Wait(2000)
                    end
            end
        end

        -- ::skip_loop::

        Wait(time)
    end
end)

