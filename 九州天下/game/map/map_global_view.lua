MapGlobalView = MapGlobalView or BaseClass(BaseRender)

local MAP_COUNT = 10

function MapGlobalView:__init(instance)
	if instance == nil then
		return
	end

	self.map_obj = self:FindObj("Map")

	self.map_img = {}
	self.label = {}
	-- self.map_name = {}
	-- self.level = {}
	self.lock = {}
	-- self.show_select = {}
	self.name_image = {}

	local role_camp = GameVoManager.Instance:GetMainRoleVo().camp
	for i = 1, MAP_COUNT do
		local scene_id = MapData.WORLDMAPCFG[i]
		if scene_id then

			self.map_img[scene_id] = self:FindObj("ImageIcon" .. i)

			local label_obj = self.map_img[scene_id]:GetComponent(typeof(UINameTable)):Find("Lable")
			if label_obj ~= nil then
				label_obj = U3DObject(label_obj)
			end
			self.label[scene_id] = label_obj

			local ui_variable_table = self.map_img[scene_id]:GetComponent(typeof(UIVariableTable))

			-- self.map_name[scene_id] = ui_variable_table:FindVariable("Name")
			-- self.level[scene_id] = ui_variable_table:FindVariable("Level")
			self.lock[scene_id] = ui_variable_table:FindVariable("IsLock")
			
			self.name_image[scene_id] = ui_variable_table:FindVariable("NameImage")
			-- self.show_select[scene_id] = ui_variable_table:FindVariable("ShowSelect")

			--if scene_id == MapData.COUNTRYMAPCFG[role_camp][3] then 	--是否本国王城
				--self.map_img[scene_id]:GetComponent(typeof(UIEventTable)):ListenEvent("OnClick", function() self:OnClickConuntry() end)
			--else
				self.map_img[scene_id]:GetComponent(typeof(UIEventTable)):ListenEvent("OnClick", function() self:OnClickButton(scene_id) end)
			--end

			--local map_config = MapData.Instance:GetMapConfig(scene_id)
			--if map_config then
				--local name = map_config.name or ""
				-- self.map_name[scene_id]:SetValue(name)

				self.name_image[scene_id]:SetAsset(ResPath.GetWorldMapNameImage(scene_id))

				-- local level = map_config.levellimit or 0
				-- local str = string.format(Language.Guild.XXGrade, level)
				-- if level >= 100 then
				-- 	local sub_level, rebirth = PlayerData.GetLevelAndRebirth(level)
				-- 	if sub_level <= 1 then
				-- 		str = string.format(Language.Common.LevelFormat3, rebirth)
				-- 	else
				-- 		str = string.format(Language.Common.LevelFormat, sub_level, rebirth)
				-- 	end
				-- end
				-- self.level[scene_id]:SetValue(str)
			--end
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

function MapGlobalView:OnClickConuntry()
	 MapCtrl.Instance.view:OnOpenCountry()
end

function MapGlobalView:OnClickButton(target_scene_id)
	local scene_id = Scene.Instance:GetSceneId()

	-- if target_scene_id == MapData.WORLDMAPCFG[8]
	-- 	or target_scene_id == MapData.WORLDMAPCFG[9]
	-- 	or target_scene_id == MapData.WORLDMAPCFG[10] then
	-- 	target_scene_id = MapData.WORLDMAPCFG[1]
	-- end

	if (self.is_can_click and target_scene_id ~= scene_id and self:GetIsCanGoToScene(target_scene_id, true)) then
		self.is_can_click = false

		-- self:SetHighLight(target_scene_id)

		local uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
		local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(uicamera, self.label[target_scene_id].rect.position)
		local rect = self.map_obj.rect
		local _, local_position_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, uicamera, Vector2(0, 0))

		local target_position = local_position_tbl
		target_position.x = target_position.x + self.map_width
		target_position.y = target_position.y - self.map_height
		local tweener = self.main_role_icon.rect:DOAnchorPos(target_position, 1, false)
		tweener:OnComplete(BindTool.Bind(self.OnMoveEnd, self, target_scene_id))
	end
end

function MapGlobalView:Flush()
	--等级限制
	local main_role = GameVoManager.Instance:GetMainRoleVo()
	local level = main_role.level
	for _, v in ipairs(MapData.WORLDMAPCFG) do
		local scene_config = MapData.Instance:GetMapConfig(v)
		local levellimit = scene_config.levellimit
		self.lock[v]:SetValue(level < levellimit)
		-- self.show_select[v]:SetValue(false)
		self.map_img[v].toggle.enabled = level >= levellimit
		self.map_img[v].toggle.isOn = false
	end

	local scene_id = Scene.Instance:GetSceneId()

	-- self:SetHighLight(scene_id)

	-- for k1, v1 in pairs(MapData.COUNTRYMAPCFG) do
	-- 	for k2, v2 in ipairs(v1) do
	-- 		if v2 == scene_id then
	-- 		 	self.show_select[MapData.COUNTRYMAPCFG[k1][3]]:SetValue(true)
	-- 		 	scene_id = MapData.COUNTRYMAPCFG[k1][3]
	-- 			break
	-- 		end
	-- 	end
	-- end

	if not self.label[scene_id] then
		self.main_role_icon:SetActive(false)
		return
	end

	self.main_role_icon:SetActive(true)
	local uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
	local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(uicamera, self.label[scene_id].rect.position)
	local rect = self.map_obj.rect
	local _, local_position_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, uicamera, Vector2(0, 0))
	self.main_role_icon.rect:SetLocalPosition(local_position_tbl.x, local_position_tbl.y, 0)

	self.map_img[scene_id].toggle.isOn = true
end

function MapGlobalView:OnMoveEnd(target_scene_id)
	self.is_can_click = true
	local scene_id = Scene.Instance:GetSceneId()
	if target_scene_id ~= scene_id then
		GuajiCtrl.Instance:ClearTaskOperate()
		MoveCache.scene_id = target_scene_id
		local scene_logic = Scene.Instance:GetSceneLogic()
		local x, y = scene_logic:GetTargetScenePos(target_scene_id)
		GuajiCtrl.Instance:MoveToScenePos(target_scene_id, x, y)
		-- if Scene.Instance:GetMainRole():IsFightState() then
		-- 	GuajiCtrl.Instance:MoveToScene(target_scene_id)
		-- else
		-- 	GuajiCtrl.Instance:FlyToScene(target_scene_id)
		-- end
	end
end

function MapGlobalView:GetIsCanGoToScene(target_scene_id, is_tip)
	local tip = ""
	local is_can_go = true

	local scene = MapData.Instance:GetMapConfig(target_scene_id)
	if scene ~= nil then
		local level = scene.levellimit or 0
		if level > PlayerData.Instance:GetRoleVo().level then
			tip = string.format(Language.Map.level_limit_tip, level)
			is_can_go = false
		end
	end

	if Scene.Instance:GetSceneType() ~= 0 then
		is_can_go = false
		tip = Language.Map.TransmitLimitTip
	end

	--if Scene.Instance:GetMainRole():IsFightState() then
	--	is_can_go = false
	--	tip = Language.Common.CannotFlyInFight
	--end

	if not is_can_go and is_tip and tip ~= "" then
		SysMsgCtrl.Instance:ErrorRemind(tip)
	end

	return is_can_go
end

-- function MapGlobalView:SetHighLight(scene_id)
-- 	for k,_ in pairs(self.show_select) do
-- 		if k == scene_id then
-- 			self.show_select[k]:SetValue(true)
-- 		else
-- 			self.show_select[k]:SetValue(false)
-- 		end
-- 	end
-- end