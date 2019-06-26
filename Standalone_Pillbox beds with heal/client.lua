local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local InAction = false

Citizen.CreateThread(function()
    while true do

        Citizen.Wait(5)

        for i=1, #Config.BedList do
            local bedID   = Config.BedList[i]
            local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), bedID.objCoords.x, bedID.objCoords.y, bedID.objCoords.z, true)

            if distance < Config.MaxDistance and InAction == false then

                DrawSub('Tryk ~g~E~w~ for at lig på sengen')

                if IsControlJustReleased(0, Keys['E']) then
                    bedActive(bedID.objCoords.x, bedID.objCoords.y, bedID.objCoords.z, bedID.heading, bedID)
                end
            end
        end
    end
end)

function bedActive(x, y, z, heading)

    SetEntityCoords(GetPlayerPed(-1), x, y, z + 0.3)
    RequestAnimDict('missfbi5ig_0')
    while not HasAnimDictLoaded('missfbi5ig_0') do
        Citizen.Wait(0)
    end
    TaskPlayAnim(GetPlayerPed(-1), 'missfbi5ig_0' , 'lyinginpain_loop_steve' ,8.0, -8.0, -1, 1, 0, false, false, false )
    SetEntityHeading(GetPlayerPed(-1), heading + 180.0)
    InAction = true

    Citizen.CreateThread(function ()
        Citizen.Wait(5)
        local health = GetEntityHealth(PlayerPedId())

        if (health < 200)  then
            exports['mythic_notify']:DoHudText('inform', 'You are being treated, please wait');
            Citizen.Wait(5000)
            if InAction == true then
                while GetEntityHealth(PlayerPedId()) < 200 do
                    Citizen.Wait(2000)
                    SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) + 1)
                end
                exports['mythic_notify']:DoHudText('success', 'You are now healthy');
            end

        elseif (health == 200) then
            exports['mythic_notify']:DoHudText('inform', 'You do not need medical attention');
        end
    end)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)

            if InAction == true then
                DrawSub('Tryk ~g~X~w~ for at gå ud af sengen')
                if IsControlJustReleased(0, Keys['X']) then
                    ClearPedTasks(GetPlayerPed(-1))
                    FreezeEntityPosition(GetPlayerPed(-1), false)
                    SetEntityCoords(GetPlayerPed(-1), x + 1.0, y, z)
                    InAction = false
                end
            end
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
    end
end)

function DrawSub(msg, time)
    ClearPrints()
    SetTextEntry_2("STRING")
    AddTextComponentString(msg)
    DrawSubtitleTimed(time, 1)
end
