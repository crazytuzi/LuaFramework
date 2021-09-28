SpiritMeetView = SpiritMeetView or BaseClass(BaseRender)

local MAP_COUNT = 8

function SpiritMeetView:__init(instance)
	if instance == nil then
		return
	end
	self.map_obj = self:FindObj("Map")
	self.residue_spirit_count = self:FindVariable("residue_spirit_count")
	self:ListenEvent("ClickHelp", BindTool.Bind(self.ClickHelp, self))
	self.is_show = self:FindVariable("is_show")
	self:ListenEvent("OnClickQuick",BindTool.Bind1(self.OnClickQuick, self))
	self.map_img = {}
	self.label = {}
	self.map_name = {}
	self.level = {}
	self.is_lock = {}
	self.spirit_count = {}
	self.has_spirit = {}
	self.has_spirit2 = {}
	for i = 1, MAP_COUNT do
		local scene_id = MapData.WORLDCFG[i]
		self.map_img[scene_id] = self:FindObj("ImageIcon" .. i)

		local label_obj = self.map_img[scene_id]:GetComponent(typeof(UINameTable)):Find("Lable")
		if label_obj ~= nil then
			label_obj = U3DObject(label_obj)
		end
		self.label[scene_id] = label_obj

		self.map_name[scene_id] = self.map_img[scene_id]:GetComponent(typeof(UIVariableTable)):FindVariable("Name")
		self.level[scene_id] = self.map_img[scene_id]:GetComponent(typeof(UIVariableTable)):FindVariable("Level")
		self.is_lock[scene_id] = self.map_img[scene_id]:GetComponent(typeof(UIVariableTable)):FindVariable("IsLock")
		self.spirit_count[scene_id] = self.map_img[scene_id]:GetComponent(typeof(UIVariableTable)):FindVariable("spirit_count")
		self.has_spirit[scene_id] = self.map_img[scene_id]:GetComponent(typeof(UIVariableTable)):FindVariable("IsHasSpirit")
		self.has_spirit2[scene_id] = self.map_img[scene_id]:GetComponent(typeof(UIVariableTable)):FindVariable("IsHasSpirit2")
		self.map_img[scene_id]:GetComponent(typeof(UIEventTable)):ListenEvent("OnClick", function() self:OnClickButton(scene_id) end)
		local map_config = MapData.Instance:GetMapConfig(scene_id)
		if map_config then
			local name = map_config.name or ""
			self.map_name[scene_id]:SetValue(name)

			local level = map_config.levellimit or 0
			local str = string.format(Language.Guild.XXGrade, level)
			if level >= 100 then
				local sub_level, rebirth = PlayerData.GetLevelAndRebirth(level)
				if sub_level <= 1 then
					str = string.format(Language.Common.LevelFormat3, rebirth)
				else
					str = string.format(Language.Common.LevelFormat, sub_level, rebirth)
				end
			end
			-- self.level[scene_id]:SetValue(ToColorStr(Language.GoldMember.Member_shop_level, COLOR.RED))
			self.level[scene_id]:SetValue(Language.GoldMember.Member_shop_level)
		end
	end

	local size_delta = self.map_obj.rect.sizeDelta
	self.map_width = size_delta.x / 2
	self.map_height = size_delta.y / 2

	self.main_role_icon = self:FindObj("MainroleIcon")

	self.is_can_click = true

	self.eh_load_quit = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind1(self.OnSceneLoadingQuite, self))

	self:Flush()

	for i = 1, 9 do
		local obj = self:FindObj("arrow" .. i)
		local rect_tran = obj:GetComponent(typeof(UnityEngine.RectTransform))
		local tween = rect_tran:DOAnchorPosY(10, 0.5)
		tween:SetEase(DG.Tweening.Ease.InOutSine)
		tween:SetLoops(-1, DG.Tweening.LoopType.Yoyo)
	end
end

function SpiritMeetView:__delete()
	if nil ~= self.eh_load_quit then
		GlobalEventSystem:UnBind(self.eh_load_quit)
		self.eh_load_quit = nil
	end
	self.is_show = nil
end

function SpiritMeetView:OpenCallBack()
	self:Flush()
end

function SpiritMeetView:CloseCallBack()
end


function SpiritMeetView:OnSceneLoadingQuite()
	self:Flush()
end

function SpiritMeetView:OnClickButton(target_scene_id)
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
		local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(uicamera, self.label[target_scene_id].rect.position)
		local rect = self.map_obj.rect
		local _, local_position_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, uicamera, Vector2(0, 0))

		local target_position = local_position_tbl
		target_position.x = target_position.x + self.map_width + 90
		target_position.y = target_position.y - self.map_height
		local tweener = self.main_role_icon.rect:DOAnchorPos(target_position, 1, false)
		tweener:OnComplete(BindTool.Bind(self.OnMoveEnd, self, target_scene_id))
	end
end

function SpiritMeetView:Flush()
	--等级限制
	local main_role = GameVoManager.Instance:GetMainRoleVo()
	local level = main_role.level
	for _, v in ipairs(MapData.WORLDCFG) do
		local scene_config = ConfigManager.Instance:GetSceneConfig(v)
		local levellimit = scene_config.levellimit
		self.map_img[v].toggle.enabled = level >= levellimit
		self.is_lock[v]:SetValue(level < levellimit)
		local blue_count, purple_count = SpiritData.Instance:GetSceneHasSpirit(v)
		self.has_spirit[v]:SetValue(blue_count > 0)
		self.has_spirit2[v]:SetValue(purple_count > 0)
		self.spirit_count[v]:SetValue(string.format(Language.JingLing.HasSpirit, blue_count))
	end

	local spirit_meet_cfg = SpiritData.Instance:GetSpiritAdvantageCfg()
	local spirit_meet_info = SpiritData.Instance:GetSpiritAdvantageInfo()
	local spirit_count = spirit_meet_info.today_gather_blue_jingling_count or 0
	local residue_count =  spirit_meet_cfg.other[1].times - spirit_count

	-- 屏蔽一键完成
	-- if level >= spirit_meet_cfg.other[1].skip_limit_level and residue_count > 0 then
	-- 	self.is_show:SetValue(true)
	-- else
	-- 	self.is_show:SetValue(false)
	-- end
	self.is_show:SetValue(false)

	if residue_count <= 0 then
		residue_count = ToColorStr(residue_count, TEXT_COLOR.RED2)
	else
		residue_count = ToColorStr(residue_count, TEXT_COLOR.GREEN_SPECIAL)
	end
	self.residue_spirit_count:SetValue(residue_count)

	local scene_id = Scene.Instance:GetSceneId()
	if not self.label[scene_id] then
		self.main_role_icon:SetActive(false)
		return
	end
	self.main_role_icon:SetActive(true)
	local uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
	local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(uicamera, self.label[scene_id].rect.position)
	local rect = self.map_obj.rect
	local _, local_position_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, uicamera, Vector2(0, 0))
	self.main_role_icon.rect:SetLocalPosition(local_position_tbl.x + 90, local_position_tbl.y, 0)

	self.map_img[scene_id].toggle.isOn = true
end

function SpiritMeetView:OnMoveEnd(target_scene_id)
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
	SpiritCtrl.Instance:CloseSpiritView()
end

function SpiritMeetView:GetIsCanGoToScene(target_scene_id, is_tip)
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

function SpiritMeetView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(217)
end

function SpiritMeetView:OnClickQuick()
	local spirit_meet_cfg = SpiritData.Instance:GetSpiritAdvantageCfg()
	local spirit_meet_info = SpiritData.Instance:GetSpiritAdvantageInfo()
	local spirit_count = spirit_meet_info.today_gather_blue_jingling_count or 0
	local residue_count =  spirit_meet_cfg.other[1].times - spirit_count

	local gold = residue_count * spirit_meet_cfg.other[1].skip_gather_consume
	local str = string.format(Language.QuickCompletion[SKIP_TYPE.SKIP_TYPE_JINGLING_ADVANTAGE], gold, residue_count)

	local ok_callback = function ()
		MarriageCtrl.Instance:SendCSSkipReq(SKIP_TYPE.SKIP_TYPE_JINGLING_ADVANTAGE, -1)
	end

	TipsCtrl.Instance:ShowCommonAutoView("", str, ok_callback, nil, true, nil, nil, Language.Task.YouXianBindGold)
end