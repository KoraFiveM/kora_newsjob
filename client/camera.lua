local activeItem
local prop
local items = {
    newscam = { model = 'prop_v_cam_01', bone = 28422, offset = vector3(0.0, 0.0, 0.0), anim = { 'missfinale_c2mcs_1', 'fin_c2_mcs_1_camman' } },
    newsmic = { model = 'prop_v_bmike_01', bone = 28422, offset = vector3(-0.08, 0.0, 0.0), anim = { 'missfra1', 'mcs2_crew_idle_m_boom' } },
    newsbmic = { model = 'p_ing_microphonel_01', bone = 60309, offset = vector3(0.055, 0.05, 0.0), anim = { 'missheistdocksprep1hold_cellphone', 'hold_cellphone' } },
}
local function isNewsEmployee() return exports.qbcore:getPlayerData().job.name == 'news' end
local function removeEquipment()
    if prop and DoesEntityExist(prop) then DeleteEntity(prop) end
    ClearPedSecondaryTask(PlayerPedId())
    prop, activeItem = nil, nil
    QB.camera.close('equipment_removed')
end
local function useEquipment(itemName)
    if not isNewsEmployee() then return end
    if activeItem then removeEquipment() return end
    local item = items[itemName]
    if not item then return end
    activeItem = itemName
    local ped, hash = PlayerPedId(), joaat(item.model)
    if not QB.stream.loadModel(hash) then return end
    prop = CreateObject(hash, GetEntityCoords(ped), true, true, false)
    AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, item.bone), item.offset.x, item.offset.y, item.offset.z, 0.0, 0.0, 0.0, true, true, false, true, 0, true)
    if not QB.stream.loadAnimDict(item.anim[1]) then return end
    TaskPlayAnim(ped, item.anim[1], item.anim[2], 1.0, -1.0, -1, 50, 0.0, false, false, false)
    SetModelAsNoLongerNeeded(hash)
    if itemName == 'newscam' then
        QB.camera.open({
            mode = 'recording',
            title = 'WEAZEL NEWS',
            subtitle = 'FIELD UNIT // LIVE',
            cameraLabel = 'NEWS CAM 01',
            recording = true,
            viewMode = 4,
        })
    end
end
RegisterNetEvent('Cam:ToggleCam', function() useEquipment('newscam') end)
RegisterNetEvent('Mic:ToggleMic', function() useEquipment('newsmic') end)
RegisterNetEvent('Mic:ToggleBMic', function() useEquipment('newsbmic') end)
CreateThread(function()
    while true do
        if activeItem then
            if not isNewsEmployee() or IsEntityDead(PlayerPedId()) or (activeItem == 'newscam' and not QB.camera.isOpen()) then
                removeEquipment()
            end
            Wait(0)
        else Wait(500) end
    end
end)
AddEventHandler('onResourceStop', function(resourceName) if GetCurrentResourceName() == resourceName then removeEquipment() end end)
