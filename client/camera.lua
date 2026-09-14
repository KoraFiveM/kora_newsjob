local holdingCam, holdingMic, holdingBmic = false, false, false
local activeBroadcast = false -- true while the movie/news cam overlay is up
local cameraActive = false    -- toggled by camera:Activate

local camModel, camanimDict, camanimName = 'prop_v_cam_01', 'missfinale_c2mcs_1', 'fin_c2_mcs_1_camman'
local micModel, micanimDict, micanimName = 'p_ing_microphonel_01', 'missheistdocksprep1hold_cellphone', 'hold_cellphone'
local bmicModel, bmicanimDict, bmicanimName = 'prop_v_bmike_01', 'missfra1', 'mcs2_crew_idle_m_boom'

local cam_net, mic_net, bmic_net = nil, nil, nil

local UI = { x = 0.000, y = -0.001 }
local fov_max, fov_min, zoomspeed = 70.0, 5.0, 10.0
local speed_lr, speed_ud = 8.0, 8.0
local fov = (fov_max + fov_min) * 0.5
local new_z = 0.0


local function isReporter()
	return PlayerJob and PlayerJob.name == 'reporter'
end

local function HideHUDThisFrame()
	HideHelpTextThisFrame()
	HideHudAndRadarThisFrame()
	for _, component in ipairs({1, 2, 3, 4, 6, 7, 8, 9, 11, 12, 13, 15, 18, 19}) do
		HideHudComponentThisFrame(component)
	end
end

local function DisplayNotification(str)
	SetTextComponentFormat('STRING')
	AddTextComponentSubstringPlayerName(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

local function drawRct(x, y, width, height, r, g, b, a)
	DrawRect(x + width / 2, y + height / 2, width, height, r, g, b, a)
end

local function CheckInputRotation(cam, zoomvalue)
	local rightAxisX = GetDisabledControlNormal(0, 220)
	local rightAxisY = GetDisabledControlNormal(0, 221)
	if rightAxisX ~= 0.0 or rightAxisY ~= 0.0 then
		local rotation = GetCamRot(cam, 2)
		new_z = rotation.z + rightAxisX * -1.0 * speed_ud * (zoomvalue + 0.1)
		local new_x = math.max(math.min(20.0, rotation.x + rightAxisY * -1.0 * speed_lr * (zoomvalue + 0.1)), -89.5)
		SetCamRot(cam, new_x, 0.0, new_z, 2)
	end
end

local function HandleZoom(cam)
	local lPed = PlayerPedId()
	local zoomOutKey, zoomInKey = 241, 242
	if IsPedSittingInAnyVehicle(lPed) then
		zoomOutKey, zoomInKey = 17, 16
	end

	if IsControlJustPressed(0, zoomOutKey) then
		fov = math.max(fov - zoomspeed, fov_min)
	elseif IsControlJustPressed(0, zoomInKey) then
		fov = math.min(fov + zoomspeed, fov_max)
	end

	local current_fov = GetCamFov(cam)
	if math.abs(fov - current_fov) < 0.1 then
		fov = current_fov
	end
	SetCamFov(cam, current_fov + (fov - current_fov) * 0.05)
end

local function spawnAttachedProp(model, boneId, offset, rot)
	local hash = GetHashKey(model)
	RequestModel(hash)
	while not HasModelLoaded(hash) do
		Wait(50)
	end

	local ped = PlayerPedId()
	local plyCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, -5.0)
	local obj = CreateObject(hash, plyCoords.x, plyCoords.y, plyCoords.z, true, true, false)

	local waited = 0
	while not DoesEntityExist(obj) and waited < 3000 do
		Wait(10)
		waited = waited + 10
	end

	local netId = ObjToNet(obj)
	SetNetworkIdExistsOnAllMachines(netId, true)
	NetworkSetNetworkIdDynamic(netId, true)
	SetNetworkIdCanMigrate(netId, false)

	AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, boneId),
		offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, true, true, false, true, 0, true)

	SetModelAsNoLongerNeeded(hash)
	return netId
end

local function despawnAttachedProp(netId)
	if not netId then return end
	local obj = NetToObj(netId)
	if DoesEntityExist(obj) then
		DetachEntity(obj, true, true)
		DeleteEntity(obj)
	end
end

local function playHoldAnim(dict, name)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Wait(50)
	end
	TaskPlayAnim(PlayerPedId(), dict, name, 1.0, -1, -1, 50, 0, 0, 0, 0) -- 50 = upper body only (32+16+2)
	RemoveAnimDict(dict)
end

local function refreshHoldAnim(dict, name)
	if not IsEntityPlayingAnim(PlayerPedId(), dict, name, 3) then
		playHoldAnim(dict, name)
	end
end

local function disableCombatControlsThisFrame()
	DisablePlayerFiring(PlayerId(), true)
	DisableControlAction(0, 25, true) -- aim
	DisableControlAction(0, 44, true) -- cover
	DisableControlAction(0, 37, true) -- weapon wheel
	SetCurrentPedWeapon(PlayerPedId(), GetHashKey('WEAPON_UNARMED'), true)
end

local function RunBroadcastCam(opts)
	activeBroadcast = true
	SetTimecycleModifier('default')
	SetTimecycleModifierStrength(0.3)

	local scaleform = RequestScaleformMovie('security_camera')
	while not HasScaleformMovieLoaded(scaleform) do Wait(10) end

	local newsScaleform
	if opts.isNews then
		newsScaleform = RequestScaleformMovie('breaking_news')
		while not HasScaleformMovieLoaded(newsScaleform) do Wait(10) end
	end

	local lPed = PlayerPedId()
	local vehicle = GetVehiclePedIsIn(lPed)
	local cam = CreateCam('DEFAULT_SCRIPTED_FLY_CAMERA', true)

	AttachCamToEntity(cam, lPed, 0.0, 0.0, 1.0, true)
	SetCamRot(cam, 2.0, 1.0, GetEntityHeading(lPed))
	SetCamFov(cam, fov)
	RenderScriptCams(true, false, 0, 1, 0)

	if opts.isNews then
		PushScaleformMovieFunction(scaleform, 'SET_CAM_LOGO')
		PushScaleformMovieFunction(newsScaleform, 'breaking_news')
		PopScaleformMovieFunctionVoid()

		BeginScaleformMovieMethod(newsScaleform, 'SET_TEXT')
		PushScaleformMovieMethodParameterString(QB.lang('text.breaking_news'))
		PushScaleformMovieMethodParameterString(QB.lang('text.bottom_breaking_news'))
		EndScaleformMovieMethod()

		BeginScaleformMovieMethod(newsScaleform, 'SET_SCROLL_TEXT')
		PushScaleformMovieMethodParameterInt(0) -- top ticker
		PushScaleformMovieMethodParameterInt(0) -- first string, start at 0
		PushScaleformMovieMethodParameterString(QB.lang('text.title_breaking_news'))
		EndScaleformMovieMethod()

		BeginScaleformMovieMethod(newsScaleform, 'DISPLAY_SCROLL_TEXT')
		PushScaleformMovieMethodParameterInt(0) -- top ticker
		PushScaleformMovieMethodParameterInt(0) -- index of string
		EndScaleformMovieMethod()
	else
		PushScaleformMovieFunction(scaleform, 'security_camera')
		PopScaleformMovieFunctionVoid()
	end

	local exitPad, exitControl = opts.exitControl[1], opts.exitControl[2]

	while activeBroadcast and holdingCam and not IsEntityDead(lPed) and GetVehiclePedIsIn(lPed) == vehicle do
		if IsControlJustPressed(exitPad, exitControl) then
			PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
			activeBroadcast = false
		end

		SetEntityRotation(lPed, 0, 0, new_z, 2, true)
		local zoomvalue = (1.0 / (fov_max - fov_min)) * (fov - fov_min)
		CheckInputRotation(cam, zoomvalue)
		HandleZoom(cam)
		HideHUDThisFrame()

		if opts.isNews then
			DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
			DrawScaleformMovie(newsScaleform, 0.5, 0.63, 1.0, 1.0, 255, 255, 255, 255)
		else
			drawRct(UI.x, UI.y + 0.0, 1.0, 0.15, 0, 0, 0, 255)  -- top bar
			DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
			drawRct(UI.x, UI.y + 0.85, 1.0, 0.16, 0, 0, 0, 255) -- bottom bar
		end

		local camHeading = math.max(-180.0, math.min(180.0, GetGameplayCamRelativeHeading()))
		local camPitch = math.max(-70.0, math.min(42.0, GetGameplayCamRelativePitch()))
		camPitch = (camPitch + 70.0) / 112.0
		camHeading = (camHeading + 180.0) / 360.0

		SetTaskMoveNetworkSignalFloat(lPed, 'Pitch', camPitch)
		SetTaskMoveNetworkSignalFloat(lPed, 'Heading', camHeading * -1.0 + 1.0)

		Wait(0)
	end

	activeBroadcast = false
	ClearTimecycleModifier()
	fov = (fov_max + fov_min) * 0.5
	RenderScriptCams(false, false, 0, 1, 0)
	SetScaleformMovieAsNoLongerNeeded(scaleform)
	if newsScaleform then SetScaleformMovieAsNoLongerNeeded(newsScaleform) end
	DestroyCam(cam, false)
	SetNightvision(false)
	SetSeethrough(false)
end


local function StartCamHoldLoop()
	CreateThread(function()
		while holdingCam do
			if not isReporter() then
				TriggerEvent('Cam:ToggleCam')
				break
			end

			refreshHoldAnim(camanimDict, camanimName)
			disableCombatControlsThisFrame()

			if not activeBroadcast then
				if IsControlJustReleased(1, 244) then
					RunBroadcastCam({ isNews = false, exitControl = {0, 177} })
				elseif IsControlJustReleased(1, 38) then
					RunBroadcastCam({ isNews = true, exitControl = {1, 177} })
				end
			end

			Wait(0)
		end
	end)
end

RegisterNetEvent('Cam:ToggleCam', function()
	if holdingCam then
		ClearPedSecondaryTask(PlayerPedId())
		despawnAttachedProp(cam_net)
		cam_net = nil
		holdingCam = false
		activeBroadcast = false
		return
	end

	if not isReporter() then return end

	holdingCam = true
	cam_net = spawnAttachedProp(camModel, 28422, vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0))
	playHoldAnim(camanimDict, camanimName)
	DisplayNotification(QB.lang('text.weazle_overlay'))
	StartCamHoldLoop()
end)


local function StartBmicHoldLoop()
	CreateThread(function()
		while holdingBmic do
			if not isReporter() then
				TriggerEvent('Mic:ToggleBMic')
				break
			end

			refreshHoldAnim(bmicanimDict, bmicanimName)
			disableCombatControlsThisFrame()
			if IsPedInAnyVehicle(PlayerPedId(), false) then
				TriggerEvent('Mic:ToggleBMic')
				break
			end

			Wait(100)
		end
	end)
end

RegisterNetEvent('Mic:ToggleBMic', function()
	if holdingBmic then
		ClearPedSecondaryTask(PlayerPedId())
		despawnAttachedProp(bmic_net)
		bmic_net = nil
		holdingBmic = false
		return
	end

	if not isReporter() then return end

	holdingBmic = true
	bmic_net = spawnAttachedProp(bmicModel, 28422, vector3(-0.08, 0.0, 0.0), vector3(0.0, 0.0, 0.0))
	playHoldAnim(bmicanimDict, bmicanimName)
	StartBmicHoldLoop()
end)


RegisterNetEvent('Mic:ToggleMic', function()
	if holdingMic then
		ClearPedSecondaryTask(PlayerPedId())
		despawnAttachedProp(mic_net)
		mic_net = nil
		holdingMic = false
		return
	end

	if not isReporter() then return end

	holdingMic = true
	mic_net = spawnAttachedProp(micModel, 60309, vector3(0.055, 0.05, 0.0), vector3(240.0, 0.0, 0.0))
	playHoldAnim(micanimDict, micanimName)
end)


RegisterNetEvent('camera:Activate', function()
	cameraActive = not cameraActive
end)

AddEventHandler('onResourceStop', function(resourceName)
	if GetCurrentResourceName() ~= resourceName then return end
	despawnAttachedProp(cam_net)
	despawnAttachedProp(mic_net)
	despawnAttachedProp(bmic_net)
end)