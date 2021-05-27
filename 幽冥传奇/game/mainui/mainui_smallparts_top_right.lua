----------------------------------------------------
-- 主ui小部件（地图）
----------------------------------------------------
MainuiSmallParts = MainuiSmallParts or BaseClass()

function MainuiSmallParts:InitTopRight()
	self.mt_layout_top_right = nil

	
	self.eh_change_scene = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind1(self.OnSceneChangeComplete, self))
	self.eh_mainrole_pos = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_POS_CHANGE, BindTool.Bind1(self.OnMainRolePosChange, self))

	self.map_area_change_handle = GlobalEventSystem:Bind(SceneEventType.SCENE_AREA_ATTR_CHANGE,BindTool.Bind(self.OnAreaChange,self))

	self.server_time_handler = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.OnServerTimeChange, self),3)
	self.net_delay_handler = GlobalEventSystem:Bind(LoginEventType.GAME_NET_DELAY,BindTool.Bind(self.OnNetDelay,self))
	self.map_occpy_change = GlobalEventSystem:Bind(MapOccupyChangeEvent.MAP_OCCUPYCHANGE, BindTool.Bind(self.OnOccpuyChange,self))
end

function MainuiSmallParts:DeleteTopRight()
	GlobalEventSystem:UnBind(self.eh_mainrole_pos)
	GlobalEventSystem:UnBind(self.eh_change_scene)
	GlobalEventSystem:UnBind(self.map_area_change_handle)
	GlobalEventSystem:UnBind(self.map_occpy_change)
	if self.server_time_handler then
		GlobalTimerQuest:CancelQuest(self.server_time_handler)
		self.server_time_handler = nil
	end	

	if self.net_delay_handler then
		GlobalEventSystem:UnBind(self.net_delay_handler)
		self.net_delay_handler = nil
	end
end

function MainuiSmallParts:InitTopRightUi()
	local screen_size = HandleRenderUnit:GetSize()
	local layout_width, layout_height = 181, 88
	self.mt_layout_top_right = MainuiMultiLayout.CreateMultiLayout(screen_size.width - layout_width, screen_size.height - layout_height, cc.p(0, 0), cc.size(layout_width, layout_height), self.mt_layout_root, -1)

	local img_map = XUI.CreateImageView(0, 0, ResPath.GetMainui("map_normal"), true)
	img_map:setAnchorPoint(0,0)
	self.mt_layout_top_right:TextureLayout():addChild(img_map, 999)
	XUI.AddClickEventListener(img_map, function()
		local client_scene_cfg = SceneForClientConfig[Scene.Instance:GetSceneId()]
		if client_scene_cfg and client_scene_cfg.isNotOpenSmallMap then
			SystemHint.Instance:FloatingTopRightText(string.format(Language.Common.NotOpenSmallMap,Scene.Instance:GetSceneName()))
			return 
		end	
		ViewManager.Instance:Open(ViewName.Map)
	end, false)
	--名称
	self.label_map_name = XUI.CreateText(0, 48, layout_width, 25, cc.TEXT_ALIGNMENT_CENTER, "", nil, 20,nil,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	self.label_map_name:setAnchorPoint(0, 0.5)
	self.label_map_name:setColor(COLOR3B.OLIVE)
	self.mt_layout_top_right:TextLayout():addChild(self.label_map_name)
	--坐标
	self.label_mainrole_pos = XUI.CreateText(-18, 20, layout_width - 10, 25, cc.TEXT_ALIGNMENT_RIGHT, "", nil, 18, COLOR3B.BRIGHT_GREEN,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	self.label_mainrole_pos:setAnchorPoint(0, 0.5)
	self.mt_layout_top_right:TextLayout():addChild(self.label_mainrole_pos)
	--战斗区
	self.label_mainrole_area = XUI.CreateText(18, 20, layout_width - 10, 25, cc.TEXT_ALIGNMENT_LEFT, "", nil, 18, COLOR3B.OLIVE,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	self.label_mainrole_area:setAnchorPoint(0, 0.5)
	self.mt_layout_top_right:TextLayout():addChild(self.label_mainrole_area)

	-- 网络延迟
	-- self.img_net_delay = XUI.CreateImageView(38,layout_height - 24,ResPath.GetMainui("net_delay_1"),true)
	self.img_net_delay = XUI.CreateImageView(15,layout_height - 25,ResPath.GetMainui("net_delay_1"),true)
	self.img_net_delay:setAnchorPoint(0,0)
	self.mt_layout_top_right:TextureLayout():addChild(self.img_net_delay, 1000)

	-- self.server_time_txt = XUI.CreateText(120, layout_height - 15, 200, 0, cc.TEXT_ALIGNMENT_LEFT, "", nil, 20,COLOR3B.OLIVE)
	self.server_time_txt = XUI.CreateText(110, layout_height - 15, 200, 0, cc.TEXT_ALIGNMENT_LEFT, "", nil, 20,COLOR3B.OLIVE)
	self.server_time_txt:setAnchorPoint(0,0.5)
	self.mt_layout_top_right:TextLayout():addChild(self.server_time_txt)

	--电池电量
	-- self.img_battery = XUI.CreateImageView(70,layout_height - 24,ResPath.GetMainui("battery_bg"),true)
	self.img_battery = XUI.CreateImageView(56,layout_height - 23,ResPath.GetMainui("battery_bg"),true)
	self.img_battery:setAnchorPoint(0,0)
	self.mt_layout_top_right:TextureLayout():addChild(self.img_battery, 1000)
	--电量Bar
	-- self.battery_prog_1 = XUI.CreateLoadingBar(self.img_battery:getPositionX() + 3, layout_height - 21, ResPath.GetMainui("battery_bg_1"), true)
	self.battery_prog_1 = XUI.CreateLoadingBar(self.img_battery:getPositionX() + 2, layout_height - 20, ResPath.GetMainui("battery_bg_1"), true)
	self.battery_prog_1:setAnchorPoint(0,0)
	self.battery_prog_1:setScale9Enabled(true)
	self.battery_prog_1:setContentWH(30, 10)
	self.mt_layout_top_right:TextureLayout():addChild(self.battery_prog_1, 1000)
	-- self.battery_prog_2 = XUI.CreateLoadingBar(self.img_battery:getPositionX() + 3, layout_height - 21, ResPath.GetMainui("battery_bg_2"), true)
	-- self.battery_prog_2:setAnchorPoint(0,0)
	-- self.battery_prog_2:setScale9Enabled(true)
	-- self.battery_prog_2:setContentWH(30, 10)
	-- self.mt_layout_top_right:TextureLayout():addChild(self.battery_prog_2, 1000)
end




function MainuiSmallParts:ChangeTopRightShowState(show_menu)
	-- if show_menu then
	-- 	self.mt_layout_top_right:FadeOut(PLAY_TIME)
	-- else
	-- 	self.mt_layout_top_right:FadeIn(PLAY_TIME)
	-- end
end

----------------------------------------------------------
-- 地图
----------------------------------------------------------
function MainuiSmallParts:OnSceneChangeComplete()
	self.label_map_name:setString(Scene.Instance:GetSceneName())
	self:OnOccpuyChange()
end

function MainuiSmallParts:OnMainRolePosChange(x, y)
	self.label_mainrole_pos:setString(x .. "," .. y)
end

function MainuiSmallParts:OnAreaChange()
	local is_pk = Scene.Instance:IsPkArea()

	if not is_pk then
		self.label_mainrole_area:setString(Language.Map.PkArea)
		self.label_mainrole_area:setColor(COLOR3B.RED)
	else	
		self.label_mainrole_area:setString(Language.Map.SafeArea)
		self.label_mainrole_area:setColor(COLOR3B.GREEN)
	end	
	
end

-- 网络延迟
function MainuiSmallParts:OnServerTimeChange()
	local time = TimeCtrl.Instance:GetServerTime()
	local t = os.date("*t",time)
	self.server_time_txt:setString(string.format("%02s",t.hour) .. ":" .. string.format("%02s",t.min) )
end	

function MainuiSmallParts:OnNetDelay(delay)
	local index = 1
	if delay <= 0.2 then
		index = 1
	elseif 	delay <= 0.6 then
		index = 2
	else
		index = 3
	end	
	self.img_net_delay:loadTexture(ResPath.GetMainui("net_delay_" .. index))

	self:OnBattery()
end	

--电池电量
function MainuiSmallParts:OnBattery()
	local battery = PlatformAdapter.GetBatteryPercent()
	battery = math.min(battery,100)
	self.battery_prog_1:setPercent(battery)
	if battery >= 75 then
		self.battery_prog_1:loadTexture(ResPath.GetMainui("battery_bg_1"), true)
	elseif battery < 75 and battery >= 25 then
		self.battery_prog_1:loadTexture(ResPath.GetMainui("battery_bg_2"), true)
	else
		self.battery_prog_1:loadTexture(ResPath.GetMainui("battery_bg_3"), true)
	end
end

function MainuiSmallParts:OnOccpuyChange()
	local scene_id = Scene.Instance:GetSceneId()
	local guild_id = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GUILD_ID)
	local state = GuildData.Instance:GetMapOccupyState(scene_id, guild_id)
	local color = {
		[1] = COLOR3B.WHITE,
		[2] = COLOR3B.GREEN,
		[3] = COLOR3B.RED,
	}
	self.label_map_name:setColor(color[state])
end