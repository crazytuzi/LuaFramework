require "Core.Module.DramaDirector.DramaCross.AbsDrama"
-- 剧情横渡
Crossing = class("Crossing", AbsDrama);
Crossing.DELAY_TIMES = {0.3, 0.55, 0.75, 0.95}
Crossing.DURATION_MOVE_TIME = 5
Crossing.CARRIER_NAME = "Drama/Carrier"
Crossing.CARRIER_MOVE_NAME = "run"
Crossing.CARRIER_WAIT_NAME = "stand"
local insert = table.insert
local _sortfunc = table.sort

function Crossing:New()
	self = {};
	setmetatable(self, {__index = Crossing})
	self._camera_path = "Path_10004_01_c"
	self._carrier_path = "Path_10004_01"
	self._from_posId = 103
	self._to_posId = 104
	return self;
end
-- 初始化角色位置,轨迹
function Crossing:_Init()
	self._carrier = GameObject.Find(Crossing.CARRIER_NAME)
	self._carrier = self._carrier:GetComponent("Animator")
	--[[    self._onData = function (cmd , args)
        --logTrace("onData:cmd=" .. cmd .. ", args=" .. tostring(args))
        SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetTeamFBData, self._onData);
        self:_OnData(args.m)
        self:_OnBegin()
    end
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetTeamFBData, self._onData);
    SocketClientLua.Get_ins():SendMessage(CmdType.GetTeamFBData, { });
    --]]
	local data = PartData.GetMyTeam()
	if data then data = data.m end
	--self._hero:StopCurrentActAndAI()

	local h = self._hero
	local pet = h.pet
	local puppet = h.puppet
	local hires = h:GetHires()
	if pet then pet:StopAI() end
	if puppet then puppet:StopAI() end
	if hires then for i, v in pairs(hires) do v:StopAI() end end
	
	self:_OnData(data)
	self:_OnBegin()
end
function Crossing:_OnData(team)
	-- logTrace("Crossing:_OnData,team=" .. tostring(team))
	-- logTrace(self._from_posId .."__" .. self._camera_path .. "___" .. type(self._hero))
	self._index = 1
	if team and # team > 0 then
		local hid = tostring(self._hero.id)
		self._roles = {}
		for i, v in pairs(team) do insert(self._roles, v) end
		_sortfunc(self._roles, function(v1, v2) return(v1.pid) >(v2.pid) end)
		for i, v in ipairs(self._roles) do if tostring(v.pid) == hid then self._index = i end end
	end
	if self._hero:IsDie() then SocketClientLua.Get_ins():SendMessage(CmdType.PlayerRelive, {t = 0}) end
	self:_SetHeroPos(self._from_posId)
	SceneEventManager.ClearCameraCache()
end
function Crossing:_GetPos(spos_id, ind)
	-- logTrace(",sid=" .. tostring(spos_id) .. ",ind=" .. tostring(ind))
	local _coordinate = DramaMgr:GetScenePosByID(spos_id)
	-- PrintTable (string.split(_coordinate.coordinate1[ind],"|"))
	return string.split(_coordinate.coordinate1[ind], "|")
end
function Crossing:_SetHeroPos(sid)
	local poss = self:_GetPos(sid, self._index)
	-- logTrace(",_SetHeroPos,x=" .. (poss[1]/100) .. ",z=" .. (poss[2]/100))
	local pos = Vector3(poss[1] / 100, 0.1, poss[2] / 100)
	--    logTrace("_SetHeroPos:pos=" .. tostring(pos) .. ",ind=" .. self._index .. ",hid=" .. self._hero.id)
	self._hero:SetPosition(pos)
	DramaProxy.SendTransLate(self._hero.id, poss[1], poss[2])
end
-- 开始剧情
function Crossing:_OnBegin()
	self:_UploadCarrier()
	
	self._timer = DramaMgr:_GetTimer(Crossing.DURATION_MOVE_TIME, 1, function()
		self:_Move()
	end)
    Crossing.RecordCross(self:_GetPos(self._to_posId, self._index))
end
-- 上载具
function Crossing:_UploadCarrier()
	local go = self._carrier.gameObject
	self._allChildTransForm = UIUtil.GetComponentsInChildren(go, "Transform")
	self._posTrf = UIUtil.GetChildInComponents(self._allChildTransForm, "pos_0" .. self._index)
	--    logTrace(tostring(self._carrier) .. "___" .. tostring(go))
	self._timer2 = DramaMgr:_GetTimer(Crossing.DELAY_TIMES[self._index], 1, function()
        if not self._hero then return end
		local pos = self._posTrf.position
		--         logTrace("_UploadCarrier,pox=" .. tostring(pos) .. ",cpos=" .. tostring(self._hero.transform.position))
		self._hero:MoveTo(pos)
	end)
end
-- 载具移动
function Crossing:_Move()
    if not self._hero then return end
	self._hero.transform.parent = self._posTrf
	if self._roles then
		for i, v in ipairs(self._roles) do
			local roleController = MapRoleList.GetInstance():GetRole(tostring(v.pid))
			-- logTrace("_Move:ind=" .. i .. ",id=" .. v.pid .. ",controller=" .. type(roleController))
			if roleController then
				local p = UIUtil.GetChildInComponents(self._allChildTransForm, "pos_0" .. i)
				roleController:StopCurrentActAndAI()
				local trf = roleController.transform
				if trf then trf.parent = p end
			end
		end
	end
	-- self._carrier:Play(Crossing.CARRIER_MOVE_NAME)
	-- self._camera:TraceRolePath(nil,self._carrier_path,function() self:_MoveOver() end,self._carrier,self._carrier)
	-- self._camera:PlayPath()
	self._camera:CameraPath(self._camera_path, function() self:_MoveOver() end)
	self._camera:PlayPath()
	local cpath = PathAction:New():InitPath(self._carrier.transform, self._carrier_path)
	cpath:Play()
end
-- 移动结束
function Crossing:_MoveOver()
	-- self._carrier:Play(Crossing.CARRIER_WAIT_NAME)
	self:_DownCarrier()
	self._timer = DramaMgr:_GetTimer(Crossing.DURATION_MOVE_TIME, 1, function()
		self:End()
        Util.RemoveData("Crossing.targetPos")
        Util.RemoveData("Crossing.currentMap")
        Crossing.targetPos = nil
	end)
end
-- 下载具
function Crossing:_DownCarrier()
    if not self._hero then return end
	self._hero.transform.parent = nil
	if self._roles then
		for i, v in pairs(self._roles) do
			local roleController = MapRoleList.GetInstance():GetRole(tostring(v.pid))
			-- logTrace("_DownCarrier:ind=" .. i .. ",id=" .. v.pid .. ",controller=" .. type(roleController))
			if roleController then
				local trf = roleController.transform
				if trf then trf.parent = nil end
			end
		end
	end
	self._timer2 = DramaMgr:_GetTimer(Crossing.DELAY_TIMES[self._index], 1, function()
        if not self._hero then return end
		local poss = Crossing.targetPos --self:_GetPos(self._to_posId, self._index)
		local heroPos = self._hero.transform.position
		DramaProxy.SendTransLate(self._hero.id,poss[1], poss[2])	 
		self._hero:MoveTo(pos)
	--local hpos = self._hero.transform.position
	--self:_RefreshPoss(hpos.x, hpos.z, hpos)
	-- self:_RefreshPoss(poss[1], poss[2], pos)
	end)
end

-- 记录过河
function Crossing.RecordCross(pos)
    Crossing.targetPos = pos
    Util.SetString("Crossing.targetPos", pos[1] .. "_" .. pos[2])
    Util.SetString("Crossing.currentMap", GameSceneManager.mapId)
    if Crossing.timer then Crossing.timer:Stop() Crossing.timer = nil end
    local t = InstanceDataManager.GetInsByMapId(GameSceneManager.id).time
    Crossing.timer = Timer.New(function() 
        Util.RemoveData("Crossing.targetPos")
        Util.RemoveData("Crossing.currentMap")
    end, t, 1)
end
-- 完成过河
function Crossing.EndCross()
    local ps = Util.GetString("Crossing.targetPos")
    if not ps or ps == "" then return end
    ps = string.split(ps, "_")
    local ms = Util.GetString("Crossing.currentMap")
    if ms == GameSceneManager.mapId then
        local hid = PlayerManager.playerId
        if not hid then return end
		local pos = Vector3(ps[1] / 100, 0.1, ps[2] / 100)
        HeroController.GetInstance():SetPosition(pos)
	    DramaProxy.SendTransLate(hid, ps[1], ps[2])
    end
    Util.RemoveData("Crossing.targetPos")
    Util.RemoveData("Crossing.currentMap")
    Crossing.targetPos = nil
end

--刷新宠物,傀儡,雇佣,位置
function Crossing:_RefreshPoss(x, z, pos)
	local h = self._hero
	local pet = h.pet
	local puppet = h.puppet
	local hires = h:GetHires()
	local r = 50
	local mr = math.random
	if pet then
		pet:SetPosition(pos)
		DramaProxy.SendTransLate(pet.id, x + mr(- r, r), z + mr(- r, r))
	end
	if puppet then
		puppet:SetPosition(pos)
		DramaProxy.SendTransLate(puppet.id, x + mr(- r, r), z + mr(- r, r))
	end
	if hires then for i, v in pairs(hires) do
			v:SetPosition(pos)
			DramaProxy.SendTransLate(v.id, x + mr(- r, r), z + mr(- r, r))
		end end
--if pet then pet:StartAI() end
--if puppet then puppet:StartAI() end
--if hires then for i, v in pairs(hires) do v:StartAI() end end
end

-- 结束剧情
function Crossing:_OnEnd()
    if not self._hero then return end
	local h = self._hero
	local pet = h.pet
	local puppet = h.puppet
	local hires = h:GetHires()
	if pet then pet:StartAI() end
	if puppet then puppet:StartAI() end
	if hires then for i, v in pairs(hires) do v:StartAI() end end
end
-- 清理
function Crossing:Clear()
	if self._timer then
		self._timer:Stop()
		self._timer = nil
	end
	if self._timer2 then
		self._timer2:Stop()
		self._timer2 = nil
	end
	self._hero = nil
	self._camera = nil
	self._carrier = nil
	self._roles = nil
	self._allChildTransForm = nil
	self._posTrf = nil
	self._onData = nil
    if Crossing.timer then Crossing.timer:Stop() Crossing.timer = nil end
end