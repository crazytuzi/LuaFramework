MapLocalView = MapLocalView or BaseClass(BaseRender)

function MapLocalView:__init(instance)
	if instance == nil then
		return
	end

	self.icon_boss_obj_list = {}
	self.boss_icon_obj_list = {}
	self.icon_gather_obj_list = {}

	self.toggle_group = instance.toggle_group

	self.map_name = self:FindVariable("Name")
	self.map_image = self:FindObj("MapImage")
	self.map_cell_parent = self:FindObj("CellParent")
	self.main_role_icon = self:FindObj("MainroleIcon")
	self.target_icon = self:FindObj("TargetIcon")
	self.path_line = self:FindObj("PathLine")
	self.fly_shoe = self:FindObj("FlyShoe")
	self.icon_self = self:FindObj("IconSelf")
	self.monster_panl = self:FindObj("MonsterTip")

	self.mix_Level = self:FindVariable("MixLevel")
	self.recommend_gongji = self:FindVariable("RecommendGongji")
	self.equip_level = self:FindVariable("EquipLevel")
	self.blue_num = self:FindVariable("BlueNum")
	self.purple_num = self:FindVariable("Purplenum")
	self.standard_exp = self:FindVariable("StandardExp")

	self.monster_tip = self:FindVariable("monster_tip")

	self.show_line_change = self:FindVariable("ShowLineChange")
	self.line_name = self:FindVariable("LineName")
	self.show_is_zhu_cheng = self:FindVariable("IsZhuCheng")

	self.btn = {}
	for i = 1, 3 do
		self.btn[i] = self:FindObj("Btn" .. i)
	end

	local size_delta = self.map_image.rect.sizeDelta
	self.map_width = size_delta.x
	self.map_height = size_delta.y
	local listener = self.map_image:GetOrAddComponent(typeof(EventTriggerListener))
	listener:AddPointerClickListener(BindTool.Bind(self.OnClickMiniMap, self))

	self.list_table = {}
	for i = 1, 3 do
		self.list_table[i] = self:FindObj("List" .. i).transform
	end

	self:SetMapTargetImg(false)



	self:ListenEvent("OnClickButton",
		BindTool.Bind(self.OnClickButton, self))
	self:ListenEvent("OnClickFly",
		BindTool.Bind(self.OnClickFly, self))
	self:ListenEvent("OnClickChangeLine",
		BindTool.Bind(self.OnClickChangeLine, self))

	self.scene_id = Scene.Instance:GetSceneId()
	self.last_scene_id = 0
	self.is_draw_path = false
	self.is_can_draw_path = true
	self.last_move_end_time = 0
	self.is_zhu_cheng = false
	self.target_icon:SetActive(false)
	if not MinimapCamera.Instance then
		print_warning("MinimapCamera.Instance == nil")
	end

	self.eh_load_quit = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind1(self.OnSceneLoadingQuite, self))
	self.eh_pos_change = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_POS_CHANGE, BindTool.Bind1(self.OnMainRolePosChangeFunc, self))
	self.eh_move_end = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_MOVE_END, BindTool.Bind1(self.OnMainRoleMoveEnd, self))
	self.task_change = GlobalEventSystem:Bind(OtherEventType.TASK_CHANGE,BindTool.Bind(self.OnTaskChange, self))
	self.reset_pos = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_RESET_POS,BindTool.Bind(self.OnMainRoleMoveEnd, self))
	self.cannot_find_theway = GlobalEventSystem:Bind(ObjectEventType.CAN_NOT_FIND_THE_WAY, BindTool.Bind1(self.OnCanNotFindWay, self))

	self:Flush()
end

function MapLocalView:__delete()
	self:ClearCache()
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
	if nil ~= self.reset_pos then
		GlobalEventSystem:UnBind(self.reset_pos)
		self.reset_pos = nil
	end
	if nil ~= self.task_change then
		GlobalEventSystem:UnBind(self.task_change)
		self.task_change = nil
	end

	if nil ~= self.cannot_find_theway then
		GlobalEventSystem:UnBind(self.cannot_find_theway)
		self.cannot_find_theway = nil
	end

	self:RemoveCountDown()
	if self.delay_time2 then
		GlobalTimerQuest:CancelQuest(self.delay_time2)
		self.delay_time2 = nil
	end

	for k, v in pairs(self.boss_icon_obj_list) do
		GameObject.Destroy(v)
	end
	self.boss_icon_obj_list = {}

	for k, v in pairs(self.icon_gather_obj_list) do
		GameObject.Destroy(v)
	end
	self.icon_gather_obj_list = {}

	for k, v in pairs(self.icon_boss_obj_list) do
		GameObject.Destroy(v)
	end
	self.icon_boss_obj_list = {}
end

function MapLocalView:RemoveCountDown()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function MapLocalView:OnClickButton()
	self.monster_tip:SetValue(false)
end

function MapLocalView:OnClickFly()
	-- 当前场景无法移动
	local logic = Scene.Instance:GetSceneLogic()
	if logic and not logic:CanCancleAutoGuaji() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Rune.CanNotCancleGuaji)
		return
	end
	self:FlyToPos(self.scene_id, self.target_position.x, self.target_position.y)
	self.monster_tip:SetValue(false)

end

function MapLocalView:OnClickChangeLine()
	ViewManager.Instance:Open(ViewName.LineView)
	self.monster_tip:SetValue(false)
end

function MapLocalView:OnSceneLoadingQuite()
	self.scene_id = Scene.Instance:GetSceneId()
	self:Flush()
	self:ClearWalkPath()
end

function MapLocalView:OnTaskChange(task_event_type, task_id)
	local icon_table = MapData.Instance:GetNpcIcon()
	if icon_table then
		for _, v in pairs(icon_table) do
			local task_status = TaskData.Instance:GetNpcTaskStatus(v.npc_id)
			if task_status == TASK_STATUS.CAN_ACCEPT then
				v.jing_tan_hao_image:SetValue(true)
				v.wen_hao_image:SetValue(false)
			elseif task_status == TASK_STATUS.ACCEPT_PROCESS or task_status == TASK_STATUS.COMMIT then
				v.wen_hao_image:SetValue(true)
				v.jing_tan_hao_image:SetValue(false)
			else
				v.wen_hao_image:SetValue(false)
				v.jing_tan_hao_image:SetValue(false)
			end
		end
	end
end

function MapLocalView:OnFlush()
	if MinimapCamera.Instance then
		self.map_image.raw_image.texture = MinimapCamera.Instance.MapTexture
	end

	self.show_is_zhu_cheng:SetValue(self.scene_id == MapData.COUNTRYMAPCFG[GameEnum.ROLE_CAMP_1][3] or self.scene_id == MapData.COUNTRYMAPCFG[GameEnum.ROLE_CAMP_2][3] or self.scene_id == MapData.COUNTRYMAPCFG[GameEnum.ROLE_CAMP_3][3])

	self:FlushCell()
	self:SetMapMainRoleImg()
	self.delay_time2 = GlobalTimerQuest:AddDelayTimer(function() self:FlushBtn() end, 0.1)

	local open_line = PlayerData.Instance:GetAttr("open_line") or 0
	if open_line <= 0 then
		self.show_line_change:SetValue(false)
		return
	end
	self.show_line_change:SetValue(true)
	local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
	scene_key = scene_key + 1
	self.line_name:SetValue(string.format(Language.Common.Line, CommonDataManager.GetDaXie(scene_key)))
end

function MapLocalView:FlushBtn()
	for i = 1, 3 do
		self.btn[i].accordion_element:Refresh()
	end
end

-- 清空缓存
function MapLocalView:ClearCache()
	MapData.Instance:ClearInfo()
	MapData.Instance:ClearIcon()
end

-- logic坐标转ui坐标
function MapLocalView:LogicToUI(logic_x, logic_y)
	if not MinimapCamera.Instance then return end
	local wx, wy = GameMapHelper.LogicToWorld(logic_x, logic_y)
	local uipos = MinimapCamera.Instance:TransformWorldToUV(Vector3(wx, 0, wy))
	local ui_x, ui_y = self.map_width * uipos.x, self.map_height * uipos.y
	return ui_x, ui_y
end

-- ui坐标转logic坐标
function MapLocalView:UIToLogic(ui_x, ui_y)
	if not MinimapCamera.Instance then return end
	local uipos_x = ui_x / self.map_width
	local uipos_y =  ui_y / self.map_height
	local world_pos = MinimapCamera.Instance:TransformUVToWorld(Vector2(uipos_x, uipos_y))
	local logic_x, logic_y = GameMapHelper.WorldToLogic(world_pos.x, world_pos.z)
	return logic_x, logic_y
end

function MapLocalView:MoveToPos(scene_id, x, y)
	--GuajiCtrl.Instance:StopGuaji()
	--GuajiCtrl.Instance:ClearTaskOperate()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
	local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
	GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 0, 0, false, scene_key, true)
	self:DrawWalkPath()
end

function MapLocalView:FlyToPos(scene_id, x, y)
	if not GuajiCtrl.Instance:CheakCanFly() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Map.DontCanFly)
		return
	end
	local shot_id = MapData.Instance:GetFlyShoeId()
	local num = ItemData.Instance:GetItemNumInBagById(shot_id)
	local enough_money = ShopData.Instance:CheckCanBuyItem(shot_id)
	if VipData.Instance:GetIsCanFly(GameVoManager.Instance:GetMainRoleVo().vip_level) or num > 0 then
		Scene.Instance:GetMainRole():ClearAutoMove()
	end
	TaskCtrl.SendFlyByShoe(scene_id, x, y)
end

--设置小地图角色人物小图标
function MapLocalView:SetMapMainRoleImg()
	if not MinimapCamera.Instance then
		return
	end
	self.main_role_icon.transform:SetAsLastSibling()
	-- 旋转
	-- local forwardDir = Scene.Instance:GetMainRole():GetRoot().transform.forward
	-- local resultEuler = Quaternion.LookRotation(forwardDir).eulerAngles
	-- local cameraEuler = MinimapCamera.Instance.transform.localEulerAngles.y
	-- self.main_role_icon.rect.localRotation = Quaternion.Euler(0,0,-resultEuler.y + cameraEuler)

	local role_x, role_y = Scene.Instance:GetMainRole():GetLogicPos()
	local ui_x, ui_y = self:LogicToUI(role_x, role_y)
	self.main_role_icon.transform:SetLocalPosition(ui_x, ui_y, 0)


end

function MapLocalView:SetMapTargetImg(flag, x, y)
	self.fly_shoe.transform:SetAsLastSibling()
	if x and y then
		local ui_x, ui_y = self:LogicToUI(x, y)
		self.fly_shoe.transform:SetLocalPosition(ui_x, ui_y, 0)
	end
	if not flag then
		self.fly_shoe:SetActive(false)
		return
	end
	self.fly_shoe:SetActive(true)
end

--角色移动回调
function MapLocalView:OnMainRolePosChangeFunc()
	if not MapCtrl.Instance.view:IsLoaded() then
		return
	end
	self:SetMapMainRoleImg()
	self.fly_shoe:SetActive(true)
	if self.last_move_end_time + 0.2 > Status.NowTime then
		self.fly_shoe:SetActive(false)
	end
	if Scene.Instance:GetMainRole().vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		self.fly_shoe:SetActive(false)
		return
	end

	local main_role = Scene.Instance:GetMainRole()
	local path_pos_list = main_role:GetPathPosList()
	if self.last_path_pos_list ~= path_pos_list then
		self.last_path_pos_list = path_pos_list
		self:ClearWalkPath()
	end

	if not self.is_draw_path and not self.is_move_finished then
		self:DrawWalkPath()
	else
		self.is_move_finished = false
	end
	self:UpdateWalkPath()
end

--角色移动结束
function MapLocalView:OnMainRoleMoveEnd()
	if not MapCtrl.Instance.view:IsLoaded() then
		return
	end
	if Scene.Instance:GetMainRole().vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		return
	end
	self.fly_shoe:SetActive(false)
	self.is_move_finished = true
	self:ClearWalkPath()
	self.last_move_end_time = Status.NowTime
end

function MapLocalView:OnClickMiniMap(event)
	-- 当前场景无法移动
	local logic = Scene.Instance:GetSceneLogic()
	if logic and not logic:CanCancleAutoGuaji() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Rune.CanNotCancleGuaji)
		return
	end
	self.monster_tip:SetValue(false)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CanNotMoveInJump)
		return
	end
	local ok, localPosition = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(
		self.map_image.rect, event.position, event.pressEventCamera, localPosition)
	if not ok then
		return
	end

	local logic_x, logic_y = self:UIToLogic(localPosition.x, localPosition.y)
	if AStarFindWay:IsBlock(logic_x, logic_y) then
		return
	end
	GuajiCtrl.Instance:StopGuaji()
	self:MoveToPos(self.map_id, logic_x, logic_y)
	GlobalEventSystem:Fire(OtherEventType.MOVE_BY_CLICK)
end

-- 找不到去往目标的路径
function MapLocalView:OnCanNotFindWay()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	GuajiCtrl.Instance:StopGuaji()
end

-----------------------------------------------动态生成Cell------------------------------------------------------
function MapLocalView:FlushCell()
	self.map_id = self.scene_id
	if (self.map_id == self.last_scene_id) then
		return
	end

	local config = MapData.Instance:GetMapConfig(self.map_id)
	if not config then
		print_warning("No Map Config")
		return
	end

	-- 是否是主城
	self.is_zhu_cheng = (self.scene_id == MapData.COUNTRYMAPCFG[GameEnum.ROLE_CAMP_1][3] or self.scene_id == MapData.COUNTRYMAPCFG[GameEnum.ROLE_CAMP_2][3] or self.scene_id == MapData.COUNTRYMAPCFG[GameEnum.ROLE_CAMP_3][3])

	self.map_name:SetValue(config.name)

	local prefab_table = {}
	-- 读取Gather，不生成button
	-- local map_config = MapData.Instance:GetMapConfig(self.scene_id) or {}
	-- if map_config.scene_type ~= 0 or self.is_zhu_cheng then
	-- 	local gather_config = ConfigManager.Instance:GetAutoConfig("gather_auto").gather_list
	-- 	local last_gather_id = 0
	-- 	for _, v in pairs(config.gathers) do
	-- 		if (last_gather_id ~= v.id) then
	-- 			last_gather_id = v.id
	-- 			local name = ""
	-- 			if gather_config and gather_config[v.id] then
	-- 				name = gather_config[v.id].show_name
	-- 			end
	-- 			local info = {
	-- 				obj = object,
	-- 				x = v.x,
	-- 				y = v.y,
	-- 				id = v.id,
	-- 				obj_type = SceneObjType.GatherObj,
	-- 				scene_id = self.map_id,
	-- 				name = name,
	-- 				level = level
	-- 			}
	-- 			prefab_table[info] = info
	-- 		end
	-- 	end
	-- end
	MapData.Instance:SetInfo(prefab_table)
	PrefabPool.Instance:Load(AssetID("uis/views/map_prefab", "Button"), function (prefab)
		if nil == prefab then
			return
		end
		-- 生成NPC
		local npc_config = ConfigManager.Instance:GetAutoConfig("npc_auto").npc_list
		for _, v in pairs(config.npcs) do
			local object = GameObject.Instantiate(prefab)
			object.transform:SetParent(self.list_table[1], false)
			object:GetComponent("Toggle").group = self.toggle_group
			local obj_name = object:GetComponent(typeof(UIVariableTable)):FindVariable("Name")
			local name = ""
			if npc_config[v.id] and npc_config[v.id].show_name and npc_config[v.id].show_name ~= "" then
				name = npc_config[v.id].show_name
			end
			obj_name:SetValue(name)
			local info = {
				obj = object,
				x = v.x,
				y = v.y,
				id = v.id,
				obj_type = SceneObjType.Npc,
				scene_id = self.map_id,
				name = name,
				level = 0
			}
			prefab_table[info] = info
			object:GetComponent(typeof(UIEventTable)):ListenEvent("OnClick", function() self:ClickButton(info) end)
		end
		-- 生成Door
		for _, v in pairs(config.doors) do
			if v.target_door_id == 0 then return end
			local object = GameObject.Instantiate(prefab)
			object.transform:SetParent(self.list_table[3], false)
			object:GetComponent("Toggle").group = self.toggle_group
			local obj_name = object:GetComponent(typeof(UIVariableTable)):FindVariable("Name")
			local scene_config = MapData.Instance:GetMapConfig(v.target_scene_id)
			local name = ""
			local level = 0
			if scene_config then
				name = scene_config.name
				level = scene_config.levellimit
			end
			obj_name:SetValue(name)
			local info = {
				obj = object,
				x = v.x,
				y = v.y,
				id = v.id,
				obj_type = SceneObjType.Door,
				scene_id = self.map_id,
				name = name,
				level = level
			}
			prefab_table[info] = info
			object:GetComponent(typeof(UIEventTable)):ListenEvent("OnClick", function() self:ClickButton(info) end)
		end

		PrefabPool.Instance:Free(prefab)

		self:FlushIcon(scene_id)
	end)
	if not is_zhu_cheng then
		PrefabPool.Instance:Load(AssetID("uis/views/map_prefab", "Button1"), function (prefab)
			if nil == prefab then
				return
			end

			-- 生成Monster
			local monsters_list = MapData.Instance:GetSceneMonsterSort(config.monsters)
			if monsters_list and next(monsters_list) then
				for _,v in pairs(monsters_list) do
					local object = GameObject.Instantiate(prefab)
					object.transform:SetParent(self.list_table[2], false)
					object:GetComponent("Toggle").group = self.toggle_group
					local obj_name = object:GetComponent(typeof(UIVariableTable)):FindVariable("Name")
					local obj_level = object:GetComponent(typeof(UIVariableTable)):FindVariable("Level")
					obj_name:SetValue(v.name)
					obj_level:SetValue("Lv." .. v.level)
					
					local info = {
						obj = object,
						x = v.x,
						y = v.y,
						id = v.id,
						obj_type = SceneObjType.Monster,
						scene_id = self.map_id,
						name = v.name,
						level = v.level
					}
					prefab_table[info] = info
					object:GetComponent(typeof(UIEventTable)):ListenEvent("OnClick", function() self:ClickButton(info) end)
				end
			end

			PrefabPool.Instance:Free(prefab)

			self:FlushIcon(scene_id)
			self:OpenCallBack()
			self.btn[2].accordion_element.isOn = true
			GlobalTimerQuest:AddDelayTimer(function() self.btn[2].accordion_element:Refresh() end, 0.1)
		end)
	end
end

-- 点击右侧的按钮
function MapLocalView:ClickButton(index)
	local info = MapData.Instance:GetInfoByIndex(index)
	-- 当前场景无法移动
	local logic = Scene.Instance:GetSceneLogic()
	if logic and not logic:CanCancleAutoGuaji() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Rune.CanNotCancleGuaji)
		return
	end
	if info then
		if (info.obj_type == SceneObjType.Npc) then
			MoveCache.end_type = MoveEndType.NpcTask
			MoveCache.param1 = info.id
			GuajiCache.target_obj_id = info.id
			self:MoveToPos(info.scene_id, info.x, info.y)
		elseif (info.obj_type == SceneObjType.Monster) then
			local monsters_info = MapData.Instance:GetMonster(info.id)
			
				MoveCache.end_type = MoveEndType.Auto
				MoveCache.param1 = info.id
				GuajiCache.target_obj_id = info.id
				GuajiCache.guaji_type = GuajiType.Monster
				GuajiCache.monster_id = info.id
				self:MoveToPos(info.scene_id, info.x, info.y)
			if monsters_info ~= nil then
				self:SetMonterTip(index, monsters_info)
			end
		elseif (info.obj_type == SceneObjType.Door) then
			MoveCache.end_type = MoveEndType.Normal
			self:MoveToPos(info.scene_id, info.x, info.y)
		end
	end
end

function MapLocalView:OpenCallBack()
	self:SetMonterTip()
	local info = nil
	local monsters_info = MapData.Instance:GetInfoByType(SceneObjType.Monster)
	local main_role_level = GameVoManager.Instance:GetMainRoleVo().level or 0
	local level_diff = 1000
	if monsters_info then
		for k,v in pairs(monsters_info) do
			if v.level <= main_role_level then
				local temp = main_role_level - v.level
				if temp < level_diff then
					level_diff = temp
					info = v
				end
			end
		end
	end
	if info then
		local monsters_info = MapData.Instance:GetMonster(info.id)
		if monsters_info ~= nil then
			self:SetMonterTip(info, monsters_info)
			if info.obj then
				info.obj:GetComponent("Toggle").isOn = true
			end
		end
	end
end

function MapLocalView:SetMonterTip(index, monsters_info)
	if monsters_info then
		self.monster_tip:SetValue(true)
		local ui_x, ui_y = self:LogicToUI(index.x, index.y)
		local anchor_x = 0
		local anchor_y = 1
		if ui_x > 110 then --面板位置超出界面时改变锚点
			anchor_x = 1
		end
		if ui_y < -165 then
			anchor_y = 0
		end
		self.mix_Level:SetValue(monsters_info.mix_level)
		self.recommend_gongji:SetValue(monsters_info.recommend_gongji)
		self.equip_level:SetValue(CommonDataManager.GetDaXie(monsters_info.equip_level))
		self.blue_num:SetValue(monsters_info.blue_num)
		self.purple_num:SetValue(monsters_info.purple_num)
		self.standard_exp:SetValue(CommonDataManager.ConverMoney(monsters_info.standard_exp or 0))

		self.monster_panl.rect.pivot = Vector2(anchor_x, anchor_y)
		self.monster_panl.transform:SetLocalPosition(ui_x, ui_y, 0)
	else
		self.monster_tip:SetValue(false)
	end
end
-----------------------------------------------动态生成Icon------------------------------------------------------
function MapLocalView:FlushIcon(scene_id)
	if not MinimapCamera.Instance then
		return
	end
	local icon_table = {}
	local count_down = 4

	PrefabPool.Instance:Load(AssetID("uis/views/map_prefab", "Icon_NPC"), function (prefab)
		if nil == prefab then
			return
		end

		local npc_info, count = MapData.Instance:GetInfoByType(SceneObjType.Npc)
		for i = 1, count do
			local info = npc_info[i]
			local object = GameObject.Instantiate(prefab)
			local variable_table = object:GetComponent(typeof(UIVariableTable))
			local wen_hao_image = variable_table:FindVariable("WenHao")
			local jing_tan_hao_image = variable_table:FindVariable("JingTanHao")
			local npc_name = variable_table:FindVariable("NpcName")
			npc_name:SetValue(info.name)
			table.insert(icon_table, {obj = object, wen_hao_image = wen_hao_image, jing_tan_hao_image = jing_tan_hao_image, npc_id = info.id,npc_name = npc_name})
			self:SetMapImg(object, info.x, info.y)
			local task_status = TaskData.Instance:GetNpcTaskStatus(info.id)
			if task_status == TASK_STATUS.CAN_ACCEPT then
				jing_tan_hao_image:SetValue(true)
			elseif task_status == TASK_STATUS.ACCEPT_PROCESS or task_status == TASK_STATUS.COMMIT then
				wen_hao_image:SetValue(true)
			end
		end

		PrefabPool.Instance:Free(prefab)

		count_down = count_down - 1
		if (count_down == 0) then
			MapData.Instance:SetIcon(icon_table)
		end
	end)

	PrefabPool.Instance:Load(AssetID("uis/views/map_prefab", "Icon_Monster"), function (prefab)
		if nil == prefab then
			return
		end

		local monster_info, count = MapData.Instance:GetInfoByType(SceneObjType.Monster)
		for i = 1, count do
			local info = monster_info[i]
			local object = GameObject.Instantiate(prefab)
			table.insert(icon_table, {obj = object, })
			--local level = info.level or 0
			--object:GetComponent(typeof(UIVariableTable)):FindVariable("Name"):SetValue(level .. Language.Common.Ji)
			self:SetMapImg(object, info.x, info.y)
		end

		PrefabPool.Instance:Free(prefab)

		count_down = count_down - 1
		if (count_down == 0) then
			MapData.Instance:SetIcon(icon_table)
		end
	end)

	-- PrefabPool.Instance:Load(AssetID("uis/views/map_prefab", "Icon_Gather"), function (prefab)
	-- 	if nil == prefab then
	-- 		return
	-- 	end

	-- 	local gather_info, count = MapData.Instance:GetInfoByType(SceneObjType.GatherObj)
	-- 	for i = 1, count do
	-- 		local info = gather_info[i]
	-- 		local object = GameObject.Instantiate(prefab)
	-- 		table.insert(icon_table, {obj = object, })
	-- 		object:GetComponent(typeof(UIVariableTable)):FindVariable("Name"):SetValue(info.name)
	-- 		self:SetMapImg(object, info.x, info.y)
	-- 	end

	-- 	PrefabPool.Instance:Free(prefab)

	-- 	count_down = count_down - 1
	-- 	if (count_down == 0) then
	-- 		MapData.Instance:SetIcon(icon_table)
	-- 	end
	-- end)

	PrefabPool.Instance:Load(AssetID("uis/views/map_prefab", "Icon_Door"), function (prefab)
		if nil == prefab then
			return
		end

		local door_info, count = MapData.Instance:GetInfoByType(SceneObjType.Door)
		for i = 1, count do
			local info = door_info[i]
			local object = GameObject.Instantiate(prefab)
			table.insert(icon_table, {obj = object, })
			local level = info.level or 0
			if Scene.Instance:GetSceneType() == SceneType.GongChengZhan then
				local map_name = ConfigManager.Instance:GetAutoConfig("gongchengzhan_auto").other[1].door_name
				object:GetComponent(typeof(UIVariableTable)):FindVariable("Name"):SetValue(map_name)
			else
				object:GetComponent(typeof(UIVariableTable)):FindVariable("Name"):SetValue(info.name)
			end
			self:SetMapImg(object, info.x, info.y)
		end

		PrefabPool.Instance:Free(prefab)

		count_down = count_down - 1
		if (count_down == 0) then
			MapData.Instance:SetIcon(icon_table)
		end
	end)

	local boss_neutral_list = BossData.Instance:GetNeutralBossList(self.scene_id)
	if boss_neutral_list then

		PrefabPool.Instance:Load(AssetID("uis/views/map_prefab", "Icon_Boss"), function (prefab)
			if nil == prefab then
				return
			end

			for k, v in pairs(boss_neutral_list) do
				local info = boss_neutral_list[k]
				local object = GameObject.Instantiate(prefab)
				table.insert(icon_table, {obj = object, })
				local info_cfg = BossData.Instance:GetMonsterInfo(info.boss_id)
				local name = info_cfg.name
				if info_cfg and name then
				 	local level = info_cfg.level or 0
				 	local str = string.format(Language.Map.Boss_Show, name, level)
					object:GetComponent(typeof(UIVariableTable)):FindVariable("Name"):SetValue(str)
				end
				self:SetMapImg(object, info.born_x, info.born_y)
			end

			PrefabPool.Instance:Free(prefab)

			count_down = count_down - 1
			if (count_down == 0) then
				MapData.Instance:SetIcon(icon_table)
			end
		end)
	end

	local role_vo_camp = GameVoManager.Instance:GetMainRoleVo().camp
	local boss_miku_list = BossData.Instance:GetMikuBossList(self.scene_id - (role_vo_camp * 4 - 4))
	if boss_miku_list then

		PrefabPool.Instance:Load(AssetID("uis/views/map_prefab", "Icon_Boss"), function (prefab)
			if nil == prefab then
				return
			end

			for k, v in pairs(boss_miku_list) do
				local info = boss_miku_list[k]
				local object = GameObject.Instantiate(prefab)
				table.insert(icon_table, {obj = object, })
				local info_cfg = BossData.Instance:GetMonsterInfo(info.bossID)
				local name = info_cfg.name
				if info_cfg and name then
				 	local level = info_cfg.level or 0
				 	local str = string.format(Language.Map.Boss_Show, name, level)
					object:GetComponent(typeof(UIVariableTable)):FindVariable("Name"):SetValue(str)
				end
				self:SetMapImg(object, info.born_x, info.born_y)
			end

			PrefabPool.Instance:Free(prefab)

			count_down = count_down - 1
			if (count_down == 0) then
				MapData.Instance:SetIcon(icon_table)
			end
		end)
	end

	local boss_family_list = BossData.Instance:GetBossFamilyList(self.scene_id)
	if boss_family_list then

		PrefabPool.Instance:Load(AssetID("uis/views/map_prefab", "Icon_Boss"), function (prefab)
			if nil == prefab then
				return
			end

			for k, v in pairs(boss_family_list) do
				local info = boss_family_list[k]
				local object = GameObject.Instantiate(prefab)
				table.insert(icon_table, {obj = object, })
				local info_cfg = BossData.Instance:GetMonsterInfo(info.bossID)
				local name = info_cfg.name
				if info_cfg and name then
				 	local level = info_cfg.level or 0
				 	local str = string.format(Language.Map.Boss_Show, name, level)
					object:GetComponent(typeof(UIVariableTable)):FindVariable("Name"):SetValue(str)
				end
				self:SetMapImg(object, info.born_x, info.born_y)
			end

			PrefabPool.Instance:Free(prefab)

			count_down = count_down - 1
			if (count_down == 0) then
				MapData.Instance:SetIcon(icon_table)
			end
		end)
	end

	self:SetXingZuoYiJiBossIcon()
	self:SetMapIconBoss()
	self:SetMapIconGather()
end

-- 星座遗迹特殊处理，显示BOSS图标
function MapLocalView:SetXingZuoYiJiBossIcon()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type ~= SceneType.XingZuoYiJi then
		return
	end

	if self.is_load_boss_icon then return end

	self.is_load_boss_icon = true

	if self.boss_icon_obj_list and next(self.boss_icon_obj_list) then
		for k, v in pairs(self.boss_icon_obj_list) do
			GameObject.Destroy(v)
		end
	end
	self.boss_icon_obj_list = {}

	PrefabPool.Instance:Load(AssetID("uis/views/map_prefab", "Icon_Boss"), function (prefab)
		if nil == prefab then
			-- self.is_load_boss_icon = false
			return
		end

		local monster_list = Scene.Instance:GetObjMoveInfoList()
		for k, v in pairs(monster_list) do
			local vo = v:GetVo()
			if BaseSceneLogic.IsAttackMonster(vo.monster_id) and vo.obj_type == SceneObjType.Monster then
				local object = GameObject.Instantiate(prefab)
				table.insert(self.boss_icon_obj_list, object)
				self:SetMapImg(object, vo.pos_x, vo.pos_y)
			end
		end

		PrefabPool.Instance:Free(prefab)
		-- self.is_load_boss_icon = false
	end)
end

-- 公会争霸显示采集物
function MapLocalView:SetMapIconGather()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type ~= SceneType.LingyuFb then
		return
	end

	if self.icon_gather_obj_list and next(self.icon_gather_obj_list) then
		for k, v in pairs(self.icon_gather_obj_list) do
			GameObject.Destroy(v)
		end
	end
	self.icon_gather_obj_list = {}
	PrefabPool.Instance:Load(AssetID("uis/views/map_prefab", "Icon_Gather"), function (prefab)
		if nil == prefab then
			return
		end

		local other_config = GuildFightData.Instance:GetOtherConfig()
		if other_config then
			for i = 1, 2 do
				local object = GameObject.Instantiate(prefab)
				table.insert(self.icon_gather_obj_list, object)
				self:SetMapImg(object, other_config["woodcase_x" .. i], other_config["woodcase_y" .. i])
			end
		end

		PrefabPool.Instance:Free(prefab)
	end)
end

-- 公会争霸显示boss
function MapLocalView:SetMapIconBoss()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type ~= SceneType.LingyuFb then
		return
	end

	if self.is_load_boss_icon then return end

	self.is_load_boss_icon = true

	if self.icon_boss_obj_list and next(self.icon_boss_obj_list) then
		for k, v in pairs(self.icon_boss_obj_list) do
			GameObject.Destroy(v)
		end
	end
	self.icon_boss_obj_list = {}
	
	PrefabPool.Instance:Load(AssetID("uis/views/map_prefab", "Icon_Boss"), function (prefab)
		if nil == prefab then
			return
		end
		local other_config = GuildFightData.Instance:GetOtherConfig()
		if other_config then
			local object = GameObject.Instantiate(prefab)
			table.insert(self.icon_boss_obj_list, object)
			self:SetMapImg(object, other_config.boss_x, other_config.boss_y)
		end
		
		PrefabPool.Instance:Free(prefab)
	end)
end

function MapLocalView:SetMapImg(obj, x, y)
	obj.transform:SetParent(self.map_cell_parent.transform, false)
	local ui_x, ui_y = self:LogicToUI(x, y)
	obj.transform:SetLocalPosition(ui_x, ui_y, 0)
end


--------------------------------------------------------------------画路径线-----------------------------------------------------------------

function MapLocalView:ClearWalkPath()
	self.path_line.line_renderer.positionCount = 0
	self.path_line:SetActive(false)
	self.is_draw_path = false
	self:SetMapTargetImg(false)
	self.is_can_draw_path = false
	self:RemoveCountDown()
	self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self.is_can_draw_path = true end, 0.3)
end

function MapLocalView:DrawWalkPath()
	self.path_line:SetActive(true)
	local main_role = Scene.Instance:GetMainRole()
	local path_pos_list = main_role:GetPathPosList()

	if #path_pos_list <= 0 then
		self:ClearWalkPath()
		return
	end

	self.target_position = {}
	self.target_position.x = path_pos_list[#path_pos_list].x
	self.target_position.y = path_pos_list[#path_pos_list].y

	--设置结束位置图标
	self:SetMapTargetImg(true, self.target_position.x, self.target_position.y)

	if not self.is_can_draw_path then
		return
	end
	if Scene.Instance:GetMainRole().vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		self.fly_shoe:SetActive(false)
		return
	end

	--画线
	local count = #path_pos_list + 1
	-- if (count == 1) then
	--  count = 2
	-- end
	self.path_line.line_renderer.positionCount = count

	for i = 1, #path_pos_list do
		local role_spinodal_x, role_spinodal_y = self:LogicToUI(path_pos_list[i].x, path_pos_list[i].y)
		role_spinodal_x = role_spinodal_x + self.map_width / 2
		role_spinodal_y = role_spinodal_y - self.map_height / 2
		self.path_line.line_renderer:SetPosition(count - 1 - i, Vector3(role_spinodal_x, role_spinodal_y, 0))
	end
	-- if (#path_pos_list == 1) then
		local role_spinodal_x, role_spinodal_y = self:LogicToUI(path_pos_list[1].x, path_pos_list[1].y)
		role_spinodal_x = role_spinodal_x + self.map_width / 2
		role_spinodal_y = role_spinodal_y - self.map_height / 2
		self.path_line.line_renderer:SetPosition(count - 1, Vector3(role_spinodal_x, role_spinodal_y, 0))
	-- end

	self.is_draw_path = true
end

function MapLocalView:UpdateWalkPath()
	if not self.is_draw_path then
		-- self:DrawWalkPath()
		return
	end
	if not self.is_can_draw_path then
		return
	end
	local main_role = Scene.Instance:GetMainRole()
	local path_pos_list = main_role:GetPathPosList()
	local path_index = main_role:GetPathPosIndex()
	local total_count = #path_pos_list
	local count = total_count - path_index + 2
	self.path_line.line_renderer.positionCount = count

	local role_x, role_y = main_role:GetLogicPos()
	local role_spinodal_x, role_spinodal_y = self:LogicToUI(role_x, role_y)
	-- local path_pos_index = main_role:GetPathPosIndex()
	-- local next_pos = path_pos_list[path_pos_index]
	-- if next_pos then
	-- 	local next_x, next_y = self:LogicToUI(next_pos.x, next_pos.y)
	-- 	self.main_role_icon.transform:DORotate(Vector3(0, 0,
	-- 	 Vector3.Angle(
	-- 	 	Vector3(next_x - role_spinodal_x, next_y - role_spinodal_y, 0), Vector3.up)), 0.5)
	-- end

	role_spinodal_x = role_spinodal_x + self.map_width / 2
	role_spinodal_y = role_spinodal_y - self.map_height / 2
	self.path_line.line_renderer:SetPosition(count - 1, Vector3(role_spinodal_x, role_spinodal_y, 0))
end
