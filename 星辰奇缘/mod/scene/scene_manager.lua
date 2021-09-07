-- ----------------------------------------------------------
-- 逻辑模块 - 场景管理器
-- ----------------------------------------------------------
SceneManager = SceneManager or BaseClass(BaseManager)

local GameObject = UnityEngine.GameObject

function SceneManager:__init()
	SceneManager.Instance = self

	self.DefaultCameraSize = 1.95
	self.Mapsizeconvertvalue = 0.00526315  * self.DefaultCameraSize / 1.871345
	-- self.Mapsizeconvertvalue = self.DefaultCameraSize * 2 / 540

	local v = self.DefaultCameraSize * 2 / ctx.ScreenHeight

    ctx.CameraOffsetX = (ctx.ScreenWidth * 0.5 * v)
    ctx.CameraOffsetY = (ctx.ScreenHeight * 0.5 * v)

    ctx.ScreenScaleX = 960 / ctx.ScreenWidth
    ctx.ScreenScaleY = 540 / ctx.ScreenHeight

    SceneMgr.MapSizeConvertValue = self.Mapsizeconvertvalue

	self.sceneModel = SceneModel.New()
	self.sceneElementsModel = SceneElementsModel.New()
	self.MainCamera = MainCamera.New()

	self.quitCenter = function() self:Send10171() end
	self.enterCenter = function(mapId) self:Send10170(mapId) end
	self.resetSelfView = false

	self.deltaTime = 0

	self.sceneLogMark = false
	self.sceneLog = {}
end

function SceneManager:Init()
	self.MainCamera.sceneModel = self.sceneModel

	self.sceneElementsModel:AddListener()
	self:InitHandler()

	EventMgr.Instance:AddListener(event_name.logined, function() self:Get_Role_Info() end)
end

function SceneManager:InitSceneView()
	self.sceneModel:InitSceneView()
end



function SceneManager:FixedUpdate()
	self.deltaTime = Time.deltaTime
	self.sceneElementsModel:FixedUpdate()
	self.MainCamera:FixedUpdate()
end

function SceneManager:OnTick()
	self.sceneElementsModel:OnTick()
end

function SceneManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
	self:AddNetHandler(10100, self.On10100)
	self:AddNetHandler(10101, self.On10101)
	self:AddNetHandler(10102, self.On10102)
	self:AddNetHandler(10103, self.On10103)
	self:AddNetHandler(10110, self.On10110)
	self:AddNetHandler(10113, self.On10113)
	self:AddNetHandler(10114, self.On10114)
	self:AddNetHandler(10115, self.On10115)
	self:AddNetHandler(10116, self.On10116)
	self:AddNetHandler(10117, self.On10117)
	self:AddNetHandler(10118, self.On10118)
	self:AddNetHandler(10119, self.On10119)
	self:AddNetHandler(10120, self.On10120)
	self:AddNetHandler(10122, self.On10122)
	self:AddNetHandler(10123, self.On10123)
	self:AddNetHandler(10150, self.On10150)
	self:AddNetHandler(10160, self.On10160)
	-- self:AddNetHandler(10161, self.On10161)
	self:AddNetHandler(10162, self.On10162)
	-- self:AddNetHandler(10163, self.On10163)
	self:AddNetHandler(10164, self.On10164)
	self:AddNetHandler(10165, self.On10165)
	self:AddNetHandler(10166, self.On10166)
	self:AddNetHandler(10168, self.On10168)
	self:AddNetHandler(10169, self.On10169)

	self:AddNetHandler(10010, self.On10010)

	-- 跨服
	self:AddNetHandler(10170, self.On10170)
	self:AddNetHandler(10171, self.On10171)

	self:AddNetHandler(10173, self.On10173)
	self:AddNetHandler(10174, self.On10174)

	self:AddNetHandler(15017, self.On15017)
end

function SceneManager:Get_Role_Info()
	-- print("Get_Role_Info")
	local data = RoleManager.Instance.RoleData
	self.sceneElementsModel.self_unique = BaseUtils.get_unique_roleid(data.id, data.zone_id, data.platform)
    self:Send10101()

    if self.resetSelfView then
	    for k,v in pairs(self.sceneElementsModel.RoleView_List) do
	    	if k == self.sceneElementsModel.self_unique then
	    		self.sceneElementsModel.self_view = v
            	self.sceneElementsModel.self_data = v.data
	    	end
	    end
	    self.resetSelfView = false
	end
end

function SceneManager:Send10100(battle_id, id, code)
	-- print("发送10100")
	if code == nil then code = 0 end
	Connection.Instance:send(10100, { battle_id = battle_id, id = id, code = code })
end

function SceneManager:On10100(data)
	local battleid = data.battle_id
	local id = data.id
	local flag = data.result
	if flag == 0 then
	    local msg = data.msg
	    -- print(string.format("操作场景单位失败:%s", msg))
	end
	NoticeManager.Instance:FloatTipsByString(data.msg)
end

function SceneManager:Send10101()
	-- print("Send10101")
	Connection.Instance:send(10101, {})
end

function SceneManager:On10101(data)
	-- print(string.format("On10101 %s ", data.flag))
	EventMgr.Instance:Fire(event_name.socket_reconnect)
	if data.flag == 1 then
	    -- print("<color='#00ff00'>重新登录成功</font>")
	    LoginManager.Instance.reconnet_times = 0
		LoginManager.Instance.reconnet_step = 0
		LoginManager.Instance.reconnet_time = 0
		Connection.Instance:CloseReconnectView()
		NoticeManager.Instance.model.confirmTips:Clear()

	    self.sceneModel.enterSceneX = data.x
	    self.sceneModel.enterSceneY = data.y
	    self.sceneModel:Loadmap(data.base_id, 0)

		---------------------------------------------
		local roleData = RoleManager.Instance.RoleData
		local ride_Mark = (roleData.ride ~= data.ride)
		local ord_ride = roleData.ride
	    local event_Mark = (roleData.event ~= data.event)
	    local ord_event = roleData.event
		roleData.event = data.event
		roleData.ride = data.ride
		roleData.speed = data.speed
		if ride_Mark then EventMgr.Instance:Fire(event_name.role_ride_change, roleData.ride, ord_ride) end
		if event_Mark then EventMgr.Instance:Fire(event_name.role_event_change, roleData.event, ord_event) end
		-- print(string.format("%s %s %s", roleData.event, roleData.ride, roleData.speed))

		---------------------------------------------

	    -- self:Send10120()
	else
	    -- print("进入地图")
	    self.sceneModel.map_loading = false
	    self:Send10100(0, 0, 0)
	end
end

function SceneManager:On10102(data)
	-- --BaseUtils.dump(data, "On10102")
	self.sceneModel:ChangeMap(data)
end

function SceneManager:On10103(data)
	-- --BaseUtils.dump(data, "On10103")
	self.sceneModel:ChangeMapUnwalk(data)
end
--服务端通知地图切换
function SceneManager:On10110(data)
	-- print(string.format("On10110 %s %s", data.base_id, self.sceneModel.map_loading))
	--BaseUtils.dump(data,"服务端数据")
	--print(RoleManager.Instance.RoleData.event.."^^^^^^^^^^^^^^")
	---------------------------------------------
	local roleData = RoleManager.Instance.RoleData
	local ride_Mark = (roleData.ride ~= data.ride)
	local ride_event = roleData.ride
    local event_Mark = (roleData.event ~= data.event)
    local ord_event = roleData.event
	roleData.event = data.event
	roleData.ride = data.ride
	roleData.speed = data.speed
	if ride_Mark then EventMgr.Instance:Fire(event_name.role_ride_change, roleData.ride, ride_event) end
	if event_Mark then EventMgr.Instance:Fire(event_name.role_event_change, roleData.event, ord_event) end
	-- print(string.format("%s %s %s", roleData.event, roleData.ride, roleData.speed))

	---------------------------------------------

	if self.sceneModel.map_loading then
	    self.sceneModel.map_data_cache = data
	else
	    self.sceneModel.map_loading = true
	    self.sceneModel.map_data_cache = nil
	    self.sceneModel:jump_map(data)
	end
end

function SceneManager:Send10112()
	Connection.Instance:send(10112, {})
end

function SceneManager:On10113(data)
	-- print(string.format("on10113 接收到 %s 的玩家信息", data.name))
	--BaseUtils.dump(data,"10113___")
	-- if self:CurrentMapId() == 30008 then
	-- 	Log.Debug(string.format("on10113 接收到 %s %s %s %s 的玩家信息", data.rid, data.platform, data.zone_id, data.name))
	-- end
	self:SetSceneLog(10113, data)

	self.sceneElementsModel:UpdateRoleList({data})
end

function SceneManager:On10114(data)
	-- print(string.format("on10114 接收到 %s %s %s 的玩家离开场景", data.rid, data.platform, data.zone_id))
	-- if self:CurrentMapId() == 30008 then
	-- 	Log.Debug(string.format("on10114 接收到 %s %s %s 的玩家离开场景", data.rid, data.platform, data.zone_id))
	-- end
	self:SetSceneLog(10114, data)
	local uniqueroleid = BaseUtils.get_unique_roleid(data.rid, data.zone_id, data.platform)
	if uniqueroleid ~= SceneManager.Instance.sceneElementsModel.self_unique then
		self.sceneElementsModel:RemoveRole(uniqueroleid)
	end
end

function SceneManager:Send10115(map_base_id, x, y, dir)
	-- print(string.format("发送移动信息 %s %s %s %s", map_base_id, x, y, dir))
	Connection.Instance:send(10115, { map_base_id = map_base_id, x = x, y = y, dir = dir })
end

function SceneManager:On10115(data)
	-- print(string.format("on10115 接收到 %s 的移动信息", BaseUtils.get_unique_roleid(data.rid, data.zone_id, data.platform)))
	self:SetSceneLog(10115, data)
	self.sceneElementsModel:RoleMove(data)
end

function SceneManager:On10116(data)
	-- print(string.format("on10116 接收到%s条场景玩家信息", #data.role_list))
	--BaseUtils.dump(data,"10116")
	-- if self:CurrentMapId() == 30008 then
	-- 	Log.Debug(string.format("on10116 接收到 %s %s %s %s 的玩家信息", data.role_list[1].rid, data[1].role_list.platform, data.role_list[1].zone_id, data.role_list[1].name))
	-- end
	if self.sceneLogMark then
		for key, value in pairs(data.role_list) do
			self:SetSceneLog(10116, value)
		end
	end
	self.sceneElementsModel:UpdateRoleList(data.role_list)
end

function SceneManager:On10117(data)
	-- print(string.format("on10117 接收到 %s %s %s 的玩家 %s 信息", data.rid, data.platform, data.zone_id, data.name))
	-- --BaseUtils.dump(data)
	-- if self:CurrentMapId() == 30008 then
	-- 	Log.Debug(string.format("on10117 接收到 %s %s %s %s 的玩家信息", data.rid, data.platform, data.zone_id, data.name))
	-- end
	self:SetSceneLog(10117, data)
	self.sceneElementsModel:UpdateRoleList({data}, true)
end

function SceneManager:On10118(data)
	-- if self:CurrentMapId() == 30008 then
	-- 	Log.Debug(string.format("on10118 接收到 %s %s %s 的玩家信息", data.rid, data.platform, data.zone_id))
	-- end
	self:SetSceneLog(10118, data)
	self.sceneElementsModel:OnRoleTransport(data)
end

function SceneManager:Send10119(mapid, x, y)
	Connection.Instance:send(10119, { map_id = mapid, x = x, y = y })
end

function SceneManager:On10119(data)
	if data.flag == 1 then
		--成功
		EventMgr.Instance:Fire(event_name.trasport_success)
	end
	if data.msg ~= "" then
		NoticeManager.Instance:FloatTipsByString(data.msg)
	end
end

function SceneManager:Send10120()
	Connection.Instance:send(10120, {})
end

function SceneManager:On10120(data)
	self.sceneData = data
	-- print(string.format("on10120 接收到%s条场景单位信息", #data.unit_list))
	-- --BaseUtils.dump(data.unit_list)
	-- if Application.platform == RuntimePlatform.WindowsPlayer or Application.platform == RuntimePlatform.WindowsEditor then
	-- 	Log.Error(string.format("on10120 接收到%s条场景单位信息", #data.unit_list))
	-- end
	self.sceneElementsModel:UpdateNpcList(data.unit_list)
end

function SceneManager:Send10122()
	Connection.Instance:send(10122, {})
end

function SceneManager:On10122(data)

	-- print(string.format("on10122 接收到%s条场景玩家信息", #data.role_list))
	--BaseUtils.dump(data,"on10122")
	-- if self:CurrentMapId() == 30008 then
		-- Log.Debug(string.format("on10122 接收到 %s %s %s %s 的玩家信息", data.role_list[1].rid, data.role_list[1].platform, data.role_list[1].zone_id, data.role_list[1].name))
	-- end
	-- if Application.platform == RuntimePlatform.WindowsPlayer or Application.platform == RuntimePlatform.WindowsEditor then
	-- 	Log.Error(string.format("on10122 接收到 %s %s %s %s 的玩家信息", data.role_list[1].rid, data.role_list[1].platform, data.role_list[1].zone_id, data.role_list[1].name))
	-- end
	if self.sceneLogMark then
		for key, value in pairs(data.role_list) do
			self:SetSceneLog(10122, value)
		end
	end
	self.sceneElementsModel:UpdateRoleList(data.role_list)
	self.sceneElementsModel:GetRoleDir()
end

function SceneManager:On10123(data)
	-- print("on10123")
	-- --BaseUtils.dump(data)
	self:SetSceneLog(10123, data)
	self.sceneElementsModel:UpdateRoleStatus(data)
end

function SceneManager:On10150(data)
end

function SceneManager:On10160(data)
	-- print(string.format("On10160 接收到 %s 的场景单位信息", data.name))
	self.sceneElementsModel:UpdateNpcList({data})
end

function SceneManager:On10162(data)
	-- print(string.format("On10162 接收到 %s %s 的Npc离开场景", data.id, data.battle_id))
	local uniquenpcid = BaseUtils.get_unique_npcid(data.id, data.battle_id)
	self.sceneElementsModel:RemoveNpc(uniquenpcid)
end

function SceneManager:On10164(data)
	-- print(string.format("On10164 接收到 %s %s 的Npc场景移动", data.id, data.battle_id))
	-- local uniquenpcid = BaseUtils.get_unique_npcid(data.id, data.battle_id)
	self.sceneElementsModel:NpcMove(data)
end

function SceneManager:On10165(data)
	local str = data.msg
	local str2 = string.gsub(str, "#23f0f7", "#52910f")
	local time = math.max(2,string.utf8len(str2)/12.5)
	SceneTalk.Instance:ShowTalk_NPC(data.id, data.battle_id, str2, time)
end

function SceneManager:On10166(data)
	-- print(string.format("On10166 接收到 %s %s 的场景单位信息", data.id, data.battle_id))
	self.sceneElementsModel:UpdateNpcList({data})
end

function SceneManager:Send10167(map_base_id, members)
	Connection.Instance:send(10167, { map_base_id = map_base_id, members = members })
end

function SceneManager:On10168(data)
	-- print(string.format("On10168 接收到 %s %s 的场景单位信息", data.id, data.battle_id))
	-- --BaseUtils.dump(data)
	self.sceneElementsModel:UpdateRoleDir(data)
end

function SceneManager:Send10169()
	-- print("Send10169")
	Connection.Instance:send(10169, { })
end

function SceneManager:On10169(data)
	-- print(string.format("On10169 接收到%s条场景单位信息", #data.role_list))
	-- --BaseUtils.dump(data)
	for key, value in pairs(data.role_list) do
		self.sceneElementsModel:UpdateRoleDir(value)
	end
end

function SceneManager:Send10010(op_type)
	Connection.Instance:send(10010, { op_type = op_type })
end

function SceneManager:On10010(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
	if data.flag == 1 then
		if self.sceneElementsModel ~= nil and self.sceneElementsModel.self_view ~= nil then
			if self.sceneElementsModel.self_view.data.ride == SceneConstData.unitstate_walk
				or self.sceneElementsModel.self_view.data.ride == SceneConstData.unitstate_ride then
				SoundManager.Instance:Play(242)
			end
		end
	end
end

function SceneManager:On15017(data)
	-- --BaseUtils.dump(data, "on15017")
	self.MainCamera:CameraMove(data)
end

-- 进入跨服
function SceneManager:Send10170(map_base_id)
	if map_base_id == nil then
		map_base_id = 0
	end
	Connection.Instance:send(10170, { map_base_id = map_base_id})
end

function SceneManager:On10170(dat)
end

-- 退出跨服
function SceneManager:Send10171()
	Connection.Instance:send(10171, {})
end

function SceneManager:On10171(dat)
end

function SceneManager:On10173(data)
	if data.reason == 1 then
		AutoFarmManager.Instance:stopFarm()
		self.sceneElementsModel:Self_PathToTarget("68_1")
	end
end

function SceneManager:Send10174()
	Connection.Instance:send(10174, {})
end

function SceneManager:On10174(data)
	-- --BaseUtils.dump(data, "On10174")
	if data.flag == 1 then
		self.sceneElementsModel:Self_Transport(10009, 0, 0)
	else
		local currentNpcData = BaseUtils.copytab(DataUnit.data_unit[20090])
		currentNpcData.baseid = 20090
		local extra = {}
		extra.base = BaseUtils.copytab(DataUnit.data_unit[20090])
		extra.base.buttons = {
			{button_id = DialogEumn.ActionType.action86, button_args = { 1 }, button_desc = TI18N("<color='#ffff00'>查看剧情任务</color>"), button_show = ""}
			, {button_id = 999, button_args = {}, button_desc = TI18N("聊点别的"), button_show = ""}
		}
		extra.base.plot_talk = TI18N("完成<color='#ffff00'>100级剧情任务-[神侍考验]</color>后才能获得通往<color='#ffff00'>失落神殿</color>的资格，据我所知你还没完成呢，好好加油吧{face_1,3}")
		MainUIManager.Instance.dialogModel:Open(currentNpcData, extra, true)

		-- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.taskdrama)
	end
end

function SceneManager:MapData_Loaded()
	-- print("MapData_Loaded")
	self.sceneModel:LoadMapTexture()
end

-- --------------------------------
-- lua调用接口
-- --------------------------------

-- 清理场景
function SceneManager:Clean()
	self.sceneModel:Clean()

	self.sceneElementsModel:CleanElements()
	if self.sceneElementsModel.self_unique ~= nil then
	    self.sceneElementsModel:RemoveRole(self.sceneElementsModel.self_unique)
	end
	self.sceneElementsModel.self_view = nil
	if self.sceneElementsModel.self_pet_unique ~= nil then
	    self.sceneElementsModel:RemoveNpc(self.sceneElementsModel.self_pet_unique)
	end
	self.sceneElementsModel.self_pet_view = nil
	if self.sceneElementsModel.follow_npc_unique ~= nil then
	    self.sceneElementsModel:RemoveNpc(self.sceneElementsModel.follow_npc_unique)
	end
	self.sceneElementsModel.follow_npc_view = nil

	if self.sceneElementsModel.collection then
		self.sceneElementsModel.collection:Cancel()
	end

	self.MainCamera.folloewObject = nil
end

-- 获取当前场景ID
function SceneManager:CurrentMapId()
	if self.sceneModel.sceneView == nil then return 0 end
	return self.sceneModel.sceneView.mapid
end

-- 获取地图块
function SceneManager:GetMapCell()
    return self.sceneModel.sceneView.map_cells
end

function SceneManager:MyData()
	return self.sceneElementsModel.self_data
end

function SceneManager:SelfUniqueid()
	return self.sceneElementsModel.self_unique
end

function SceneManager:SetSceneActive(active)
	self.sceneModel:SetSceneActive(active)
	self.sceneElementsModel:SetSceneActive(active)
end

function SceneManager:FindSceneLogBuy(name)
	for key, value in pairs(self.sceneLog) do
		for _, data in ipairs(value) do
			if data.data.name == name then
				return value
			end
		end
	end
	return {TI18N("没有该人信息")}
end

function SceneManager:SetSceneLog(cmd, data)
	if self.sceneLogMark then
		local key = BaseUtils.get_unique_roleid(data.rid, data.zone_id, data.platform)
		local list = self.sceneLog[key]
		if list == nil then
			self.sceneLog[key] = {}
			list = self.sceneLog[key]
		end
		table.insert(list, { cmd = cmd, data = data, time = BaseUtils.BASE_TIME })
	end
end
--******************************--
--******************************--
------------ C# Call ------------
--******************************--
--******************************--
function SceneManager:MapClick(x, y)
	self.sceneElementsModel:MapClick(x, y)
end

function SceneManager:ClickUnitObject(objectName)
    self.sceneElementsModel:ClickUnitObject(objectName)
end

function SceneManager:ClickRoleObject(eventData, eventObject)
    self.sceneElementsModel:ClickRoleObject(eventData, eventObject)
end

function SceneManager:TouchSceneUnit(objectName)
	local func = function()
		self.sceneElementsModel:TouchSceneUnit(objectName)
	end
    LuaTimer.Add(80, func)
end