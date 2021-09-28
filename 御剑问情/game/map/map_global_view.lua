MapGlobalView = MapGlobalView or BaseClass(BaseRender)

local MAP_COUNT = 8
local IsWeekBossScene = {[2] = true, [4] = true, [5] = true, [6] = true, [7] = true}
function MapGlobalView:__init(instance)
	if instance == nil then
		return
	end

	self.map_obj = self:FindObj("Map")

	self.map_img = {}
	self.label = {}
	self.map_name = {}
	self.openlevel = {}
	self.lock = {}
	self.week_boss_panel = {}
	for i = 1, MAP_COUNT do
		local scene_id = MapData.WORLDCFG[i]
		self.map_img[scene_id] = self:FindObj("ImageIcon" .. i)
		if IsWeekBossScene[i] then
			self.week_boss_panel[scene_id] = self:FindVariable("BossNum" .. i)
		end

		local label_obj = self.map_img[scene_id]:GetComponent(typeof(UINameTable)):Find("Lable")
		if label_obj ~= nil then
			label_obj = U3DObject(label_obj)
		end
		self.label[scene_id] = label_obj

		self.map_name[scene_id] = self.map_img[scene_id]:GetComponent(typeof(UIVariableTable)):FindVariable("Name")
		self.openlevel[scene_id] = self.map_img[scene_id]:GetComponent(typeof(UIVariableTable)):FindVariable("OpenLevel")
		self.lock[scene_id] = self.map_img[scene_id]:GetComponent(typeof(UIVariableTable)):FindVariable("IsLock")
		self.map_img[scene_id]:GetComponent(typeof(UIEventTable)):ListenEvent("OnClick", function() self:OnClickButton(scene_id) end)
		local map_config = MapData.Instance:GetMapConfig(scene_id)
		if map_config then
			local name = map_config.name or ""
			self.map_name[scene_id]:SetValue(name)

			local level = map_config.levellimit or 1
			local str = level
			if level >= 100 then
				local sub_level, rebirth = PlayerData.GetLevelAndRebirth(level)
				if sub_level <= 1 then
					str = string.format(Language.Common.MapLevelFormat2, rebirth)
					self.openlevel[scene_id]:SetValue(str)
				else
					str = string.format(Language.Common.MapLevelFormat1, sub_level, rebirth)
					self.openlevel[scene_id]:SetValue(str)
				end
			else
				local sub_level, rebirth = PlayerData.GetLevelAndRebirth(level)
				if sub_level == 100 then
					sub_level = 0
				end
				str = string.format(Language.Common.MapLevelFormat3, sub_level)
				self.openlevel[scene_id]:SetValue(str)
			end
		end
	end

	local size_delta = self.map_obj.rect.sizeDelta
	self.map_width = size_delta.x / 2
	self.map_height = size_delta.y / 2

	self.main_role_icon = self:FindObj("MainroleIcon")

	self.is_can_click = true

	self.eh_load_quit = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind1(self.OnSceneLoadingQuite, self))

	self:Flush()
end

function MapGlobalView:__delete()
	if nil ~= self.eh_load_quit then
		GlobalEventSystem:UnBind(self.eh_load_quit)
		self.eh_load_quit = nil
	end
end


function MapGlobalView:OnSceneLoadingQuite()
	self:Flush()
end

function MapGlobalView:OnClickButton(target_scene_id)
	local scene_id = Scene.Instance:GetSceneId()
	if (self.is_can_click and target_scene_id ~= scene_id and self:GetIsCanGoToScene(target_scene_id, true)) then
		self.is_can_click = false
		-- 如果vip等级不够，且小飞鞋道具不足
		-- local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
		-- if not VipData.Instance:GetIsCanFly(vip_level) then
		-- 	local fly_shoe_id = MapData.Instance:GetFlyShoeId() or 0
		-- 	local num = ItemData.Instance:GetItemNumInBagById(fly_shoe_id) or 0
		-- 	if num <= 0 then
		-- 		self:OnMoveEnd(target_scene_id)
		-- 		ViewManager.Instance:Close(ViewName.Map)
		-- 		return
		-- 	end
		-- end

		local uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
		local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(uicamera, self.map_img[target_scene_id].rect.position)
		local rect = self.map_obj.rect
		local _, local_position_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, uicamera, Vector2(0, 0))

		local target_position = local_position_tbl
		target_position.x = target_position.x + self.map_width
		target_position.y = target_position.y - self.map_height
		local tweener = self.main_role_icon.rect:DOAnchorPos(target_position, 1, false)
		tweener:OnComplete(BindTool.Bind(self.OnMoveEnd, self, target_scene_id))
	end
end

function MapGlobalView:OnFlush()
	--等级限制
	local main_role = GameVoManager.Instance:GetMainRoleVo()
	local level = main_role.level
	for _, v in ipairs(MapData.WORLDCFG) do
		local scene_config = ConfigManager.Instance:GetSceneConfig(v)
		local levellimit = scene_config.levellimit
		self.lock[v]:SetValue(level < levellimit)
		self.map_img[v].toggle.enabled = level >= levellimit
		if self.week_boss_panel[v] then
			self.week_boss_panel[v]:SetValue(level >= levellimit and TianshenhutiData.Instance:GetWeekendBossCount(v))
		end
	end

	local scene_id = Scene.Instance:GetSceneId()
	if not self.label[scene_id] then
		self.main_role_icon:SetActive(false)
		return
	end
	self.main_role_icon:SetActive(true)
	local uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
	local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(uicamera, self.map_img[scene_id].rect.position)
	local rect = self.map_obj.rect
	local _, local_position_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, uicamera, Vector2(0, 0))
	self.main_role_icon.rect:SetLocalPosition(local_position_tbl.x, local_position_tbl.y, 0)

	self:SetToggleFalse()
	self.map_img[scene_id].toggle.isOn = true
end

function MapGlobalView:SetToggleFalse()
	for i = 1, MAP_COUNT do
		local scene_id = MapData.WORLDCFG[i]
		self.map_img[scene_id].toggle.isOn = false
	end
end

function MapGlobalView:OnMoveEnd(target_scene_id)
	self.is_can_click = true
	local scene_id = Scene.Instance:GetSceneId()
	if target_scene_id ~= scene_id then
		GuajiCtrl.Instance:ClearTaskOperate()
		if Scene.Instance:GetMainRole():IsFightState() then
			GuajiCtrl.Instance:MoveToScene(target_scene_id)
		else
			GuajiCtrl.Instance:FlyToScene(target_scene_id)
		end
	end
end

function MapGlobalView:GetIsCanGoToScene(target_scene_id, is_tip)
	local tip = ""
	local is_can_go = true

	local scene = ConfigManager.Instance:GetSceneConfig(target_scene_id)
	if scene ~= nil then
		local level = scene.levellimit or 0
		if level > PlayerData.Instance:GetRoleVo().level then
			tip = string.format(Language.Map.level_limit_tip, PlayerData.GetLevelString(level))
			is_can_go = false
		end
	end

	if Scene.Instance:GetSceneType() ~= 0 then
		is_can_go = false
		tip = Language.Map.TransmitLimitTip
	end

	if not is_can_go and is_tip and tip ~= "" then
		SysMsgCtrl.Instance:ErrorRemind(tip)
	end

	return is_can_go
end