require "Core.Module.DramaDirector.DramaTimeLine.DramaAbs"
require "Core.Module.DramaDirector.DramaTimeLine.DramaCamera"
require "Core.Module.DramaDirector.DramaTimeLine.DramaDialog"
require "Core.Module.DramaDirector.DramaTimeLine.DramaActor"
require "Core.Module.DramaDirector.DramaTimeLine.DramaRole"
require "Core.Module.DramaDirector.DramaTimeLine.DramaTimeScale"
require "Core.Module.DramaDirector.DramaTimeLine.DramaAction"
--剧情时间轴
DramaTimer = class("DramaTimer")
DramaTimer.CLONE_HERO = true
local _sortfunc = table.sort
local tableInsert = table.insert
DramaTimer.FaceTimer = nil --淡入淡出时间

--剧情初始化
function DramaTimer.Init(did)
	DramaTimer.configs = DramaProxy.GetDramaConfig(did)
	local sortFunc = function(a, b) return a.eventId < b.eventId end
	_sortfunc(DramaTimer.configs, sortFunc)
	DramaTimer._InitPlotParam(DramaTimer.configs[1])
	DramaTimer.events = {}
	DramaTimer.endCount = 0
end
function DramaTimer._InitPlotParam(c)
	DramaTimer.plotParam = c.plotParam-- 第一条配置中取剧情参数
	DramaTimer.plotId = tonumber(c.plotId) -- 第一条配置中取剧情id
	--剧情配置:什么时候可跳过,剧情结束延迟刷怪物
	DramaTimer.cancelPoint = tonumber(DramaTimer.plotParam[1])
	local len = # DramaTimer.plotParam
	DramaTimer.refreshMonsterTime = len > 1 and tonumber(DramaTimer.plotParam[2]) or nil
	if len > 2 then DramaTimer._InitFaceTime(DramaTimer.plotParam[3]) end
end
function DramaTimer._InitFaceTime(arg)
	if not arg then return end
	arg = string.trim(arg)
	if string.len(arg) == 0 then return end
	local ss = string.split(arg, '_')
	for i = 1, 6 do ss[i] = tonumber(ss[i]) / 1000 end
	ss[7] = ss[7] == '0' and Color.black or Color.white
	ss[8] = ss[8] == '0' and Color.black or Color.white
	DramaTimer.FaceTimer = ss
end
-- 开始剧情
function DramaTimer.Begin()
	if not DramaTimer.configs or # DramaTimer.configs == 0 then return end
	DramaTimer._BeginGlobal()
	DramaTimer._BeginConfig()
	DramaTimer._BeginSkip()
end
function DramaTimer._BeginConfig(fixed)
	local sortFunc = function(a, b)
		if a.eventStartTime < b.eventStartTime then return true
		elseif a.eventStartTime == b.eventStartTime then return a.eventId < b.eventId
		end
		return false
	end
	_sortfunc(DramaTimer.configs, sortFunc)
	local hkind = PlayerManager.GetPlayerKind()
	local skipTime = 0
	local len = # DramaTimer.configs
	DramaTimer.totalCount = 0
	for i = 1, len, 1 do
		local v = DramaTimer.configs[i]
		local p4 = v[DramaAbs.EvenParam4]
		--Warning(p4 .. '__' .. v.eventStartTime)
		if p4 == hkind then --和主角职业一样的事件跳过
			if i < len then
				local gt = DramaTimer.configs[i + 1].eventStartTime - v.eventStartTime
				skipTime = skipTime + gt
			--Warning(skipTime .."___"..gt .. ',' .. config[DramaAbs.EvenParam4])
			end
		else
			DramaTimer.totalCount = DramaTimer.totalCount + 1
			DramaTimer._HandleEvent(v, skipTime, fixed)
		end
	end
end
function DramaTimer._BeginGlobal()
	local mask = DramaTimer.CLONE_HERO
	and LayerMask.GetMask(Layer.Default, Layer.Water, Layer.TransparentFX, Layer.ReceiveShadow, Layer.Hero, Layer.NPC)
	or LayerMask.GetMask(Layer.Default, Layer.Water, Layer.TransparentFX, Layer.ReceiveShadow, Layer.Hero, Layer.NPC)
	MainCameraController.GetInstance():FilterMask(mask)
	if GameSceneManager.map then
		local mapRoler = GameSceneManager.map:GetMapRole()
		if(mapRoler) then
			mapRoler:HideRole(ControllerType.NPC)
			mapRoler:HideNamePanels()
		end
	end
	SceneActiveMgr.Stop()
	SceneActiveMgr.EnableType(SceneActiveType.SCENE_EFFECT, true)--显示所有场景效果
	SceneActiveMgr.EnableType(SceneActiveType.NPC, true)--显示所有npc
	SceneActiveMgr.EnableType(SceneActiveType.MONSTER, false)
	SceneActiveMgr.EnableType(SceneActiveType.PET, false)
	SceneActiveMgr.EnableType(SceneActiveType.PLAYER, false)
end
function DramaTimer._BeginSkip()
	DramaTimer._canSkip = false
	if DramaTimer.cancelPoint > 0 then
		DramaTimer.skipTimer = DramaDirector.GetTimer(DramaTimer.cancelPoint / 1000, 1, function()
			DramaTimer.skipTimer = nil
			DramaTimer._canSkip = true
			ModuleManager.SendNotification(DialogNotes.SHOW_SKIP_BTN);
		end)
	end
end
-- 结束剧情
function DramaTimer.End(drama)
	if not DramaTimer.events then return end
	RemoveTableItem(DramaTimer.events, drama)
	DramaTimer.endCount = DramaTimer.endCount + 1
	if DramaTimer.endCount == DramaTimer.totalCount then
		DramaDirector.End(true)
		DramaTimer.Clear()
	end
end
-- 加速事件开始
function DramaTimer.AccelEvent(time)
	for i, v in ipairs(DramaTimer.events) do v:CutTime(time) end
end
-- 处理事件
function DramaTimer._HandleEvent(config, skipTime, fixed)
	local t = config[DramaAbs.EvenType]
	local e = nil
	if t == DramaEventType.CameraPath or t == DramaEventType.CameraPoint
	or t == DramaEventType.CameraShake then
		e = DramaCamera.New()
	elseif t == DramaEventType.DialogSubtitle or t == DramaEventType.DialogBubble
		or t == DramaEventType.DialogRole then
		e = DramaDialog.New()
	elseif t == DramaEventType.RoleShow or t == DramaEventType.RolePath
		or t == DramaEventType.RoleMove or t == DramaEventType.RoleAction then
		e = DramaRole.New()
	elseif t == DramaEventType.EntityEffect or t == DramaEventType.EntityScene then
		e = DramaActor.New()
	elseif t == DramaEventType.TimeScale then
		e = DramaTimeScale.New()
	elseif t == DramaEventType.BornNpc or t == DramaEventType.DeleteNpc
		or t == DramaEventType.GiveTrump or t == DramaEventType.DeleteTrump
		or t == DramaEventType.GuideStep
		then
		e = DramaAction.New()
	else
		return
	end
	e:Init(config, DramaDirector.hero, DramaDirector.camera)
	if not fixed then
		e:Ready(skipTime)
	else
		e:FixedExecute()
	end
	tableInsert(DramaTimer.events, e)
end
-- 是否可以跳过
function DramaTimer.CanSkip()
	return DramaTimer._canSkip
end
-- 清理
function DramaTimer.Clear()
	if not DramaTimer.events then return end
	MainCameraController.GetInstance():RevertMask()
	if GameSceneManager.map then
		local mapRoler = GameSceneManager.map:GetMapRole()
		if(mapRoler) then
			mapRoler:ShowRole()
			mapRoler:ShowNamePanels()
		end
	end
	SceneActiveMgr.Start()
	SceneActiveMgr.EnableType(SceneActiveType.MONSTER, true)
	SceneActiveMgr.EnableType(SceneActiveType.PET, true)
	SceneActiveMgr.EnableType(SceneActiveType.PLAYER, true)
	if DramaTimer.skipTimer then
		DramaTimer.skipTimer:Stop()
		DramaTimer.skipTimer = nil
	end
	for i, v in ipairs(DramaTimer.events) do
		v:FixedExecute()
		v:Dispose()
	end
	DramaTimer.FaceTimer = nil
	DramaTimer.events = nil
end

function DramaTimer.LogicHandler(did)
	DramaTimer.Init(did)
	DramaTimer._BeginConfig(true)
end
