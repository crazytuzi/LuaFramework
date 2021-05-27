MapView = MapView or BaseClass(BaseView)
MapViewCheckKey = {
	Npc = 1,
	Other = 2,
}
MapView.DEF_WIDTH = 730							-- 宽
MapView.DEF_HEIGHT = 460						-- 高

function MapView:__init()
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.texture_path_list[1] = 'res/xui/map.png'
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"map_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
	}

	self.check_state_list = {
		[MapViewCheckKey.Npc] = false,
		[MapViewCheckKey.Other] = true,
	}

	self:InitArgs()
end

function MapView:__delete()
	self:UnBindEvents()
end

function MapView:InitArgs()
	self.npc_item_list = {}
	self.monster_item_list = {}
	self.guild_enemy_item_list = {}
	self.door_item_list = {}
	self.boss_item_list = {}
	self.exp_fire_item_list = {}

	self.check_box_list = {}
	self.map_scale = 1
	self.scale_x = 0
	self.scale_y = 0
	self.is_in_transmit = false
	self.map_layout = nil
	self.img_small_map = nil
	self.img_role_dir_bg = nil
	self.floor_layout = nil
	self.img_role = nil
end

function MapView:BindEvents()
	self.eh_load_quit = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind1(self.OnSceneLoadingQuite, self))
	self.eh_pos_change = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_POS_CHANGE, BindTool.Bind1(self.OnMainRolePosChange, self))
	self.eh_move_end = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_MOVE_END, BindTool.Bind1(self.OnMainRoleMoveEnd, self))

	XUI.AddClickEventListener(self.node_t_list.btn_rand_deliver.node, BindTool.Bind(self.OnClickRandDeliver, self))
	XUI.AddClickEventListener(self.node_t_list.btn_back_city.node, BindTool.Bind(self.OnClickBackCity, self))
	XUI.AddClickEventListener(self.node_t_list.btn_deliver.node, BindTool.Bind(self.OnClickDeliver, self))

	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, function ()
		local hc_id = CLIENT_GAME_GLOBAL_CFG.mainui_stone[1]
		local sj_id = CLIENT_GAME_GLOBAL_CFG.mainui_stone[2]
		local hc_num = BagData.Instance:GetItemDurabilityInBagById(hc_id, nil)
		local sj_num = BagData.Instance:GetItemDurabilityInBagById(sj_id, nil)
		self.node_t_list.lbl_hc_num.node:setString(tostring(hc_num / 1000))
		self.node_t_list.lbl_sj_num.node:setString(tostring(sj_num / 1000))
		self.node_t_list.btn_back_city.node:setGrey(hc_num <= 0)
		self.node_t_list.btn_rand_deliver.node:setGrey(sj_num <= 0)
	end)
end

function MapView:UnBindEvents()
	if nil ~= self.eh_load_quit then
		GlobalEventSystem:UnBind(self.eh_load_quit)
		self.eh_load_quit = nil
	end
	if nil ~= self.eh_pos_change then
		GlobalEventSystem:UnBind(self.eh_pos_change)
		self.eh_pos_change = nil
	end
	if nil ~= self.eh_move_end then
		GlobalEventSystem:UnBind(self.eh_move_end)
		self.eh_move_end = nil
	end
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function MapView:LoadCallBack(index, loaded_times)
	if 1 == loaded_times then
		local size = self.root_node:getContentSize()
		self:CreateTopTitle(nil, size.width / 2, size.height - 45)

		self:BindEvents()
		self:CreateMyCheckBox(MapViewCheckKey.Npc, self.node_t_list.layout_box_show_npc.node)
		self:CreateMyCheckBox(MapViewCheckKey.Other, self.node_t_list.layout_box_show_other.node)

		local map_pos = self.ph_list.ph_map
		self.floor_layout = XUI.CreateLayout(map_pos.x, map_pos.y, map_pos.w, map_pos.h)
		self.floor_layout:setTouchEnabled(false)
		self.floor_layout:setBackGroundColor(COLOR3B.BLACK)
		self.node_t_list.layout_local.node:addChild(self.floor_layout, 8, 8)

		self.map_layout = XLayout:create()
		self.map_layout:setAnchorPoint(0.5, 0.5)
		self.map_layout:setTouchEnabled(true)
		self.map_layout:setPosition(map_pos.x, map_pos.y)
		self.map_layout:setClippingEnabled(true)
		self.map_layout:setContentWH(map_pos.w, map_pos.h)
		self.node_t_list.layout_local.node:addChild(self.map_layout, 10)

		self.img_bg = XUI.CreateImageViewScale9(0, 0, 740, 470,  ResPath.GetMap("img9_map_mask"), true, cc.rect(80,103,102,96))
		self.img_bg:setAnchorPoint(0, 0)
		self.map_layout:addChild(self.img_bg, 2)

		self.img_small_map = XImage:create()
		self.img_small_map:setTouchEnabled(false)
		self.img_small_map:setAnchorPoint(0, 0)
		self.img_small_map:setPosition(0, 0)
		self.map_layout:addChild(self.img_small_map, 1, 1)

		self.img_role_dir_bg = XUI.CreateImageView(0, 0, ResPath.GetMap("role_dir"), true)
		self.img_role_dir_bg:setAnchorPoint(0.51, 0.276)
		self.map_layout:addChild(self.img_role_dir_bg, 99, 99)

		self.img_role = XUI.CreateImageView(0, 0, ResPath.GetMap("main_role"), true)
		self.img_role:setAnchorPoint(0.5, 0.5)
		self.map_layout:addChild(self.img_role, 100, 100)
		

		self.draw_node = cc.DrawNode:create()
		self.map_layout:addChild(self.draw_node, 98, 98)

		self.map_layout:addTouchEventListener(BindTool.Bind1(self.LayoutOnClick, self))

		self:Flush(0, "all")
		-- self:SetStoneIconAndNum(501)
		-- self:SetStoneIconAndNum(502)


		if IS_ON_CROSSSERVER then
			self.node_t_list.btn_deliver.node:setVisible(false)
		end
	end
end

function MapView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	if self.timer == nil then
		self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.OnFlushMapMark, self), 0.5)
	end
	self:Flush(0, "open")
end

function MapView:ShowIndexCallBack(index)
	local hc_id = CLIENT_GAME_GLOBAL_CFG.mainui_stone[1]
	local sj_id = CLIENT_GAME_GLOBAL_CFG.mainui_stone[2]
	local hc_num = BagData.Instance:GetItemDurabilityInBagById(hc_id, nil)
	local sj_num = BagData.Instance:GetItemDurabilityInBagById(sj_id, nil)

	self.node_t_list.lbl_hc_num.node:setString(tostring(hc_num / 1000))
	self.node_t_list.btn_back_city.node:loadTexture(ResPath.GetItem(ItemData.Instance:GetItemConfig(hc_id).icon))
	self.node_t_list.btn_back_city.node:setGrey(hc_num <= 0)
	-- self.node_t_list.btn_rand_deliver.node:setColor(hc_num <= 0 and COLOR3B.GRAY or COLOR3B.WHITE)
	self.node_t_list.lbl_sj_num.node:setString(tostring(sj_num / 1000))
	self.node_t_list.btn_rand_deliver.node:loadTexture(ResPath.GetItem(ItemData.Instance:GetItemConfig(sj_id).icon))
	self.node_t_list.btn_rand_deliver.node:setGrey(sj_num <= 0)
	-- self.node_t_list.btn_rand_deliver.node:setColor(sj_num <= 0 and COLOR3B.GRAY or COLOR3B.WHITE)
end

--界面关闭回调
function MapView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function MapView:ReleaseCallBack()
	self:InitArgs()
	self:UnBindEvents()
	
end

function MapView:OnFlush(param_t, index)
	if not self:IsLoadedIndex(0) then return end

	local scene_id = Scene.Instance:GetSceneId()
	local config = ConfigManager.Instance:GetSceneConfig(scene_id)
	if nil == config then
		return
	end

	for k,v in pairs(param_t) do
		if k == "all" then
			self.draw_node:clear()
			local res_id = Config_scenelist[scene_id].res_id
			local path = ResPath.GetGameSmallMapPath(res_id)

			local function load_callback()
				local size = self.img_small_map:getContentSize()
				if size.width <= 0 or size.height <= 0 then
					return
				end

				self.map_scale = math.min(self.DEF_WIDTH / size.width, self.DEF_HEIGHT / size.height)
				self.scale_x = 1
				self.scale_y = 1
				local offset_width = 0
				local offset_height = 0
				if res_id ~= scene_id then
					local target_map_cfg = MapData.Instance:GetMapXmlConfig(scene_id)
					local source_map_cfg = MapData.Instance:GetMapXmlConfig(res_id)
					self.scale_x = target_map_cfg.logic_width / source_map_cfg.logic_width
					self.scale_y = target_map_cfg.logic_height / source_map_cfg.logic_height
					offset_width, offset_height = self:PositionChangeToLittle(target_map_cfg.res_x, target_map_cfg.res_y)
				end
				self.img_small_map:setScale(self.map_scale)
				self.img_small_map:setPosition(- offset_width, - offset_height)
				self.img_bg:setPosition(- offset_width, - offset_height)
				self.img_bg:setContentWH(
					size.width * self.map_scale * self.scale_x + 10,
					size.height * self.map_scale * self.scale_y + 10
				)
				-- self.map_layout:setContentWH(
				-- 	size.width * self.map_scale * self.scale_x,
				-- 	size.height * self.map_scale * self.scale_y
				-- )

				--设置小地图各种图标位置
				self:SetMapMainRoleImg()
				self:SetItemList(self.npc_item_list, MapData.Instance:GetNpcList(scene_id), MapNpcRender, MapViewCheckKey.Npc, 31)
				self:SetItemList(self.door_item_list, MapData.Instance:GetDoorList(scene_id), MapDoorRender, MapViewCheckKey.Other, 34)
				self:OnFlushMapMark()
			end

			XUI.AsyncLoadTexture(self.img_small_map, path, load_callback)

		elseif k == "open" then
			self:SetMapMainRoleImg()
			self:SetItemList(self.npc_item_list, MapData.Instance:GetNpcList(scene_id), MapNpcRender, MapViewCheckKey.Npc, 31)
			self:SetItemList(self.door_item_list, MapData.Instance:GetDoorList(scene_id), MapDoorRender, MapViewCheckKey.Other, 34)
			self:OnFlushMapMark()
			
		elseif k == MapViewCheckKey.Other then
			self:SetItemList(self.door_item_list, MapData.Instance:GetDoorList(scene_id), MapDoorRender, MapViewCheckKey.Other, 34)
			self:OnFlushMapGuildEnemy()

		elseif k == MapViewCheckKey.Npc then
			self:SetItemList(self.npc_item_list, MapData.Instance:GetNpcList(scene_id), MapNpcRender, MapViewCheckKey.Npc, 31)
		end
	end
end

function MapView:CreateMyCheckBox(key, parent)
	if nil == self.check_box_list then
		self.check_box_list = {}
	end
	self.check_box_list[key] = {}
	self.check_box_list[key].status = self.check_state_list[key]
	self.check_box_list[key].node = XUI.CreateImageView(20, 22, ResPath.GetCommon("bg_checkbox_hook"), true)
	self.check_box_list[key].node:setVisible(self.check_box_list[key].status)
	parent:addChild(self.check_box_list[key].node, 99)
	XUI.AddClickEventListener(parent, BindTool.Bind(self.OnCheckBoxClicked, self, key))
end

function MapView:OnCheckBoxClicked(key)
	if nil == self.check_box_list[key] or nil == self.check_box_list[key].node then return end
	local check_box = self.check_box_list[key]
	check_box.status = not check_box.status
	check_box.node:setVisible(check_box.status)

	self.check_state_list[key] = check_box.status

	self:Flush(0, key)
end

--小地图点击事件
function MapView:LayoutOnClick(sender, event_type, touch)
	if event_type ~= XuiTouchEventType.Ended then return end

	MoveCache.task_id = 0
	GuajiCtrl.Instance:ClearAllOperate()

	local node_point = sender:convertToNodeSpace(touch:getLocation()) 
	local x, y = self:PositionChangeToScene(node_point.x, node_point.y)
	MoveCache.end_type = MoveEndType.MapMove
	GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), x, y, 1)
end

--加载完场景
function MapView:OnSceneLoadingQuite()
	self:Flush(0, "all")
end

function MapView:ClickFlyShoeHandler()
	if not Scene.Instance:GetSceneLogic():GetIsCanFly() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CanNotFly)
		return
	end
end

function MapView:OnRecycleNpc()
	if self.map_alert == nil then
		self.map_alert = Alert.New()
	end
	self.map_alert:SetShowCheckBox(true)
	self.map_alert:SetLableString(Language.Map.RecycleNpcTips)
	self.map_alert:SetOkFunc(function ()
		
		Scene.SendQuicklyTransportReq(7)
	self:Close()
  	end)
	self.map_alert:Open()
	
end

function MapView:OnFlushMapBoss()
	local scene_id = Scene.Instance:GetSceneId()
	local now_time = Status.NowTime
	local boss_list = BossData.Instance:GetSceneBossListBySceneId(scene_id)
	local map_boss_list = MapData.GetMapBossList(scene_id)
	
	for k,v in pairs(boss_list) do
		for key,value in pairs(map_boss_list) do
			if v.refresh_time > 0 then
				v.refresh_time = v.refresh_time - (now_time - v.now_time)
				v.refresh_time = v.refresh_time > 0 and v.refresh_time or 0
				v.now_time = now_time
			end
			if value.BossId == v.boss_id then
				value.refresh_time = v.refresh_time
				break
			end
		end
	end

	self:SetItemList(self.boss_item_list, map_boss_list, MapBossRender, MapViewCheckKey.Other, 35)
end

function MapView:OnFlushMapMark()
	self:OnFlushMapGuildEnemy()
	self:OnFlushMapMonster()
	self:OnFlushMapBoss()
	-- self:OnFlushExpFire()
end

-----------------------------------------------------
--当前地图角色移动相关
-----------------------------------------------------
--角色移动回调
function MapView:OnMainRolePosChange()
	if not self:IsOpen() or not self:IsLoadedIndex(0) then
		return
	end

	self:SetMapMainRoleImg()
	self:DrawWalkPath()
end

function MapView:DrawWalkPath()
	self:ClearWalkPath()

	local main_role = Scene.Instance:GetMainRole()
	local pos_list = main_role:GetPathPosList()
	local pos_count = #pos_list
	if pos_count <= 0 and not pos_list[pos_count] then
		return
	end

	--画线
	local now_x, now_y = self:PositionChangeToLittle(main_role:GetLogicPos())
	local spinodal_x, spinodal_y = 0, 0

	for i = main_role:GetPathPosIndex(), pos_count do
		spinodal_x, spinodal_y = self:PositionChangeToLittle(pos_list[i].x, pos_list[i].y)
		self.draw_node:drawSegment(cc.p(now_x, now_y), cc.p(spinodal_x, spinodal_y), 1, cc.c4f(0.894, 0.741, 0.137, 1))
		now_x, now_y = spinodal_x, spinodal_y
	end
end

function MapView:ClearWalkPath()
	if not self:IsLoadedIndex(0) then
		return
	end
	self.draw_node:clear()
end

--人物移动结束后事件
function MapView:OnMainRoleMoveEnd()
	self:ClearWalkPath()
end

-- 随机传送
function MapView:OnClickRandDeliver()
	self:CheckUseStone(CLIENT_GAME_GLOBAL_CFG.mainui_stone[2])
end

-- 回城传送
function MapView:OnClickBackCity()
	self:CheckUseStone(CLIENT_GAME_GLOBAL_CFG.mainui_stone[1])
end

function MapView:OnClickDeliver()
	if self.map_alert == nil then
		self.map_alert = Alert.New()
	end
	self.map_alert:SetShowCheckBox(true)
	self.map_alert:SetLableString(Language.Map.DeliveryNpcTips)
	self.map_alert:SetOkFunc(function ()
		Scene.SendQuicklyTransportReqByNpcId(CLIENT_GAME_GLOBAL_CFG.chuansong_npc_id)
		self:Close()
  	end)
	self.map_alert:Open()
end

function MapView:CheckUseStone(item_id)
	local num = BagData.Instance:GetItemNumInBagById(item_id, nil)
	if num <= 0 then
		local param = {item_id}
		TipCtrl.Instance:OpenQuickBuyItem(param)
	else
		local stone_item = BagData.Instance:GetItem(item_id)
		if stone_item ~= nil then
			BagCtrl.Instance:SendUseItem(stone_item.series, 1)
		end
	end
end

--设置小地图角色人物小图标
function MapView:SetMapMainRoleImg()
	if nil ~= self.img_role then
		local main_role = Scene.Instance:GetMainRole()
		local dir = main_role.vo.dir
		local role_now_x, role_now_y = main_role:GetLogicPos()
		local role_now_map_x, role_now_map_y = self:PositionChangeToLittle(role_now_x, role_now_y)
		self.img_role:setPosition(role_now_map_x, role_now_map_y)
		self.img_role_dir_bg:setPosition(role_now_map_x, role_now_map_y)
		self.img_role_dir_bg:setRotation(dir * 45)
	end
end

--小地图坐标转换成世界地图逻辑坐标
function MapView:PositionChangeToScene(x, y)
	local world_width = HandleRenderUnit:GetLogicWidth()
	local world_height = HandleRenderUnit:GetLogicHeight()
	local size = self.img_small_map:getContentSize()

	if size.width <= 0 or size.height <= 0 or self.map_scale <= 0 then
		return -1, -1
	end

	return GameMath.Round(x * world_width / size.width / self.map_scale / self.scale_x), GameMath.Round(y * world_height / size.height / self.map_scale / self.scale_y)
end

--场景坐标转换成小地图像素坐标
function MapView:PositionChangeToLittle(x, y)
	local world_width = HandleRenderUnit:GetLogicWidth()
	local world_height = HandleRenderUnit:GetLogicHeight()

	if nil == self.img_small_map or world_width <= 0 or world_height <= 0 then
		return -1, -1
	end
	local size = self.img_small_map:getContentSize()

	return x * size.width / world_width * self.map_scale * self.scale_x,
		y * size.height / world_height * self.map_scale * self.scale_y
end

function MapView:SetItemList(item_list, data_list, item_render, list_def, order)
	if not self.map_layout then return end

	for _, v in pairs(item_list) do
		v:SetVisible(false)
	end
	if nil == data_list then return end

	local name_visible = false
	if list_def and (nil == self.check_box_list[list_def] or self.check_box_list[list_def].status) then
		name_visible = true
	end

	for i, v in pairs(data_list) do
		if nil == item_list[i] then
			item_list[i] = item_render.New(self)
			self.map_layout:addChild(item_list[i]:GetView(), order or 29)
		else
			item_list[i]:SetVisible(true)
		end
		v.name_visible = name_visible
		item_list[i]:SetData(v)
	end
end

----------------------------------------------------
-- npc
----------------------------------------------------
MapNpcRender = MapNpcRender or BaseClass(BaseRender)
function MapNpcRender:__init(map_view)
	self.map_view = map_view
end

function MapNpcRender:__delete()
end

function MapNpcRender:CreateChild()
	BaseRender.CreateChild(self)

	self.img_npc_flag = XUI.CreateImageView(0, 0, ResPath.GetMap("npc"), true)
	self.view:addChild(self.img_npc_flag)

	self.text_npc_name = XUI.CreateText(0, 20, 200, 18, nil, "", nil, 18, nil)
	self.text_npc_name:setColor(COLOR3B.GREEN)
	self.view:addChild(self.text_npc_name)
end

function MapNpcRender:OnFlush()
	local now_map_x, now_map_y = self.map_view:PositionChangeToLittle(self.data.posx, self.data.posy)
	self.view:setPosition(now_map_x, now_map_y)
	self.text_npc_name:setString(StdNpc[self.data.id].name)
	self.text_npc_name:setVisible(self.data.name_visible)
end

----------------------------------------------------
-- 敌对行会成员
----------------------------------------------------
function MapView:OnFlushMapGuildEnemy()
	local role_list = Scene.Instance:GetRoleList()
	local guild_enemy_list = {}
	for k,v in pairs(role_list) do
		local role_vo = v:GetVo()
		-- 通过颜色判断出是敌对行会成员
		if role_vo.name_color == 4294927360 then
			local logic_x, logic_y = v:GetLogicPos()
			guild_enemy_list[#guild_enemy_list + 1] = {
				name = role_vo.name,
				color = UInt2C3b(role_vo.name_color),
				x = logic_x,
				y = logic_y,
			}
		end
	end
	self:SetItemList(self.guild_enemy_item_list, guild_enemy_list, MapGuildEnemyRender, MapViewCheckKey.Other, 32)
end

MapGuildEnemyRender = MapGuildEnemyRender or BaseClass(BaseRender)
function MapGuildEnemyRender:__init(map_view)
	self.map_view = map_view
end

function MapGuildEnemyRender:__delete()
end

function MapGuildEnemyRender:CreateChild()
	BaseRender.CreateChild(self)

	self.img_npc_flag = XUI.CreateImageView(0, 0, ResPath.GetMap("guild_enemy"), true)
	self.view:addChild(self.img_npc_flag)

	self.text_name = XUI.CreateText(0, 20, 200, 18, nil, "", nil, 18, nil)
	self.view:addChild(self.text_name)
end

function MapGuildEnemyRender:OnFlush()
	local now_map_x, now_map_y = self.map_view:PositionChangeToLittle(self.data.x, self.data.y)
	self.view:setPosition(now_map_x, now_map_y)
	self.text_name:setString(self.data.name)
	self.text_name:setColor(self.data.color)
	self.text_name:setVisible(self.data.name_visible)
end

----------------------------------------------------
-- 怪物
----------------------------------------------------
function MapView:OnFlushMapMonster()
	self:SetItemList(self.monster_item_list, Scene.Instance:GetMonsterList(), MapMonsterRender, nil, 30)
end

MapMonsterRender = MapMonsterRender or BaseClass(BaseRender)
function MapMonsterRender:__init(map_view)
	self.map_view = map_view
end

function MapMonsterRender:__delete()
end

function MapMonsterRender:CreateChild()
	BaseRender.CreateChild(self)

	self.img_monster = XUI.CreateImageView(0, 0, ResPath.GetMap("monster"), true)
	self.view:addChild(self.img_monster)
end

function MapMonsterRender:OnFlush()
	local x, y = self.data:GetLogicPos()
	local now_map_x, now_map_y = self.map_view:PositionChangeToLittle(x, y)
	self.view:setPosition(now_map_x, now_map_y)
end

----------------------------------------------------
-- 经验火
----------------------------------------------------
function MapView:OnFlushExpFire()
	self:SetItemList(self.exp_fire_item_list, Scene.Instance:GetSpecialObjExpFireList(), MapExpFireRender, nil, 36)
end

MapExpFireRender = MapExpFireRender or BaseClass(BaseRender)
function MapExpFireRender:__init(map_view)
	self.map_view = map_view
end

function MapExpFireRender:__delete()
end

function MapExpFireRender:CreateChild()
	BaseRender.CreateChild(self)
	self.img_monster = XUI.CreateImageView(0, 0, ResPath.GetMap("fire_1"), true)
	self.view:addChild(self.img_monster)
end

function MapExpFireRender:OnFlush()
	local x, y = self.data:GetLogicPos()
	if self.data:GetVo() then
		local path = self.data:GetVo().model_id == 365 and "fire_1" or "fire_2"
		self.img_monster:loadTexture(ResPath.GetMap(path))
	end
	local now_map_x, now_map_y = self.map_view:PositionChangeToLittle(x, y)
	self.view:setPosition(now_map_x, now_map_y)
end

----------------------------------------------------
-- BOSS
----------------------------------------------------
MapBossRender = MapBossRender or BaseClass(BaseRender)
function MapBossRender:__init(map_view)
	self.map_view = map_view
end

function MapBossRender:__delete()
end

function MapBossRender:CreateChild()
	BaseRender.CreateChild(self)

	self.img_monster = XUI.CreateImageView(0, 0, ResPath.GetMap("icon_die"), true)
	self.view:addChild(self.img_monster)

	self.text_name = XUI.CreateText(0, 20, 400, 18, nil, "", nil, 18, nil)
	self.text_name:setColor(COLOR3B.RED)
	self.view:addChild(self.text_name)
	self.area_type = XUI.CreateRichText(0, 40, 200, 18, true)
	XUI.RichTextSetCenter(self.area_type)
	self.view:addChild(self.area_type)
end

function MapBossRender:OnFlush()
	local now_map_x, now_map_y = self.map_view:PositionChangeToLittle(self.data.x, self.data.y)
	self.data.refresh_time = self.data.refresh_time or 0
	self.view:setPosition(now_map_x, now_map_y)
	local s = string.find(self.data.name, "{")
	if s then
		split_result = Split(self.data.name, "}")
		RichTextUtil.ParseRichText(self.area_type, split_result[1] .. "}", 18)
		self.text_name:setString(split_result[2])
	else	
		self.text_name:setString(self.data.name)
	end
	self.text_name:setColor(self.data.refresh_time <= 0 and COLOR3B.RED or COLOR3B.G_W)
	self.img_monster:setGrey(self.data.refresh_time > 0)
	self.text_name:setVisible(self.data.name_visible)
end

----------------------------------------------------
-- 传送门
----------------------------------------------------
MapDoorRender = MapDoorRender or BaseClass(BaseRender)
function MapDoorRender:__init(map_view)
	self.map_view = map_view
end

function MapDoorRender:__delete()
end

function MapDoorRender:CreateChild()
	BaseRender.CreateChild(self)

	self.img_door = XUI.CreateImageView(0, 0, ResPath.GetMap("door"), true)
	self.view:addChild(self.img_door)

	self.text_scene_name = XUI.CreateText(0, 21, 200, 18, nil, "", nil, 18, nil)
	self.text_scene_name:setColor(COLOR3B.BLUE)
	self.view:addChild(self.text_scene_name)
end

function MapDoorRender:OnFlush()
	local now_map_x, now_map_y = self.map_view:PositionChangeToLittle(self.data.posx, self.data.posy)
	self.view:setPosition(now_map_x, now_map_y)
	self.text_scene_name:setString(self.data.name)
	self.text_scene_name:setVisible(self.data.name_visible)
end