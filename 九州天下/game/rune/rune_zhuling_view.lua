local POINTER_ANGLE_LIST = {
	[1] = 0,
	[2] = -60,
	[3] = -120,
	[4] = 180,
	[5] = 120,
	[6] = 60,
}

RuneZhuLingView = RuneZhuLingView or BaseClass(BaseRender)
-- 祭炼
function RuneZhuLingView:__init()
	local slot_cfg = RuneData.Instance:GetRuneZhulingSlotCfg()
	for i = 1, 6 do
		local va_text = self:FindVariable("reward_text" .. i)
		va_text:SetValue(slot_cfg[i].description)
	end

	self.need_gold_text = self:FindVariable("need_gole_text")

	self.is_show_star_list = {}
	for i=1, 5 do
		self.is_show_star_list[i] = self:FindVariable("is_show_star" .. i)
	end

	self.is_max_level = self:FindVariable("IsMaxLevel")

	self.is_show_maxhp = self:FindVariable("is_show_maxhp")
	self.is_show_gongji = self:FindVariable("is_show_gongji")
	self.is_show_fangyu = self:FindVariable("is_show_fangyu")
	self.is_show_mingzhong = self:FindVariable("is_show_mingzhong")
	self.is_show_shanbi = self:FindVariable("is_show_shanbi")
	self.is_show_baoji = self:FindVariable("is_show_baoji")
	self.is_show_kangbao = self:FindVariable("is_show_kangbao")

	self.lingli_prog_text = self:FindVariable("lingli_prog_text")
	self.lingli_prog_value = self:FindVariable("lingli_prog_value")
	self.jilian_level_str = self:FindVariable("jilian_level_str")

	self.btn_text = self:FindVariable("btn_text")
	self.btn_zhuling = self:FindObj("BtnZhuLing")

	self.maxhp = self:FindVariable("maxhp")
	self.gongji = self:FindVariable("gongji")
	self.fangyu = self:FindVariable("fangyu")
	self.shanbi = self:FindVariable("shanbi")
	self.mingzhong = self:FindVariable("mingzhong")
	self.baoji = self:FindVariable("baoji")
	self.jianren = self:FindVariable("jianren")
	self.attr_add = self:FindVariable("attr_add")

	self.next_maxhp = self:FindVariable("next_maxhp")
	self.next_gongji = self:FindVariable("next_gongji")
	self.next_fangyu = self:FindVariable("next_fangyu")
	self.next_shanbi = self:FindVariable("next_shanbi")
	self.next_mingzhong = self:FindVariable("next_mingzhong")
	self.next_baoji = self:FindVariable("next_baoji")
	self.next_jianren = self:FindVariable("next_jianren")
	self.next_attr_add = self:FindVariable("next_attr_add")

	self.level_prog_text = self:FindVariable("level_prog_text")
	self.level_prog_value = self:FindVariable("level_prog_value")

	self.capability = self:FindVariable("capability")
	self.cost_img = self:FindVariable("cost_img")

	self:ListenEvent("OnZhuLing", BindTool.Bind(self.OnZhuLing, self))
	self:ListenEvent("OnSpawnCircle", BindTool.Bind(self.OnClickZhuLing, self))
	self:ListenEvent("OnOpenHelp", BindTool.Bind(self.OnOpenHelp, self))

	self.play_ani_toggle = self:FindObj("AnimToggle").toggle

	self.stars_list = {}
	local stars_obj = self:FindObj("Stars")
	for i = 1, 5 do
		self.stars_list[i] = stars_obj:FindObj("star"..i)
	end

	self.slot_cell_list = {}
	for i = 1, 8 do
		local slot_obj = self:FindObj("RuneItme" .. i)
		local slot_cell = RuneFuLingCell.New(slot_obj, self)
		slot_cell:SetIndex(i)
		slot_cell:SetClickCallBack(BindTool.Bind(self.SlotClick, self, i))
		table.insert(self.slot_cell_list, slot_cell)
	end

	self.show_hight_light_list = {}
	for i = 1, 6 do
		self.show_hight_light_list[i] = self:FindVariable("ShowHightLight" .. i)
	end

	self.center_pointer = self:FindObj("CenterPointer")
	self.handle_slide_obj = self:FindObj("HandleSlideObj")

	self.cur_select_index = 1
	self.is_rolling = false

	self.cur_reward_index = 1
	self.zhuling_slot_bless = 0
	self.delay_flush_prog_timer = nil

	self:ResetLastLevel()
	self.is_zhuling = false
end

function RuneZhuLingView:__delete()
	self.is_show_star_list = {}

	self.is_max_level = nil

	self.is_show_maxhp = nil
	self.is_show_gongji = nil
	self.is_show_fangyu = nil
	self.is_show_mingzhong = nil
	self.is_show_shanbi = nil
	self.is_show_baoji = nil
	self.is_show_kangbao = nil

	self.lingli_prog_text = nil
	self.lingli_prog_value = nil
	self.jilian_level_str = nil

	self.maxhp = nil
	self.gongji = nil
	self.fangyu = nil
	self.shanbi = nil
	self.mingzhong = nil
	self.baoji = nil
	self.jianren = nil
	self.attr_add = nil

	self.next_maxhp = nil
	self.next_gongji = nil
	self.next_fangyu = nil
	self.next_shanbi = nil
	self.next_mingzhong = nil
	self.next_baoji = nil
	self.next_jianren = nil
	self.next_attr_add = nil

	self.level_prog_text = nil
	self.level_prog_value = nil

	self.capability = nil

	self.play_ani_toggle = nil

	for k,v in pairs(self.slot_cell_list) do
		v:DeleteMe()
	end
	self.slot_cell_list = {}

	self.show_hight_light_list = {}

	self.center_pointer = nil
	self.btn_text = nil
	self.btn_zhuling = nil

	self.delay_flush_prog_timer = nil

	self.stars_list = {}

	self.is_zhuling = false
	self.cost_img = nil
	self.need_gold_text = nil
end

function RuneZhuLingView:CloseCallBack()
	TipsCtrl.Instance:DestroyFlyEffectByViewName(ViewName.Rune)
	self.is_zhuling = false
end

function RuneZhuLingView:InitView()
	self:FlushView()
end

function RuneZhuLingView:OnRewardDataChange(cur_reward_slot, zhuling_slot_bless)
	self:ResetVariable()
	self:ResetHighLight()

	self:SaveVariable(cur_reward_slot + 1, zhuling_slot_bless)
	self:TrunPointer()
end

function RuneZhuLingView:TrunPointer()
	if self.is_rolling then
		return
	end

	if self.play_ani_toggle.isOn then
		local angle = POINTER_ANGLE_LIST[self.cur_reward_index]
		self.center_pointer.transform.localRotation = Quaternion.Euler(0, 0, angle)
		self:ShowHightLight()
		self:FlushLingLiProg()
		return
	end

	self.is_rolling = true
	self:SetAllToggleEnabled(false)
	local time = 0
	local tween = self.center_pointer.transform:DORotate(
		Vector3(0, 0, -360 * 20),
		20,
		DG.Tweening.RotateMode.FastBeyond360)
	tween:SetEase(DG.Tweening.Ease.OutQuart)
	tween:OnUpdate(function ()
		time = time + UnityEngine.Time.deltaTime
		if time >= 1 then
			tween:Pause()
			local angle = POINTER_ANGLE_LIST[self.cur_reward_index]
			local tween1 = self.center_pointer.transform:DORotate(
					Vector3(0, 0, -360 * 3 + angle),
					2,
					DG.Tweening.RotateMode.FastBeyond360)
			tween1:OnComplete(function ()
				self:SetAllToggleEnabled(true)
				self:ShowHightLight()
				if false == self:FlushProgressEffect() then
					self.is_rolling = false 
				end
			end)
		end
	end)
end

function RuneZhuLingView:ResetVariable()
	local rune_info = RuneData.Instance:GetRuneZhulingInfo()
	self.zhuling_slot_bless = rune_info.zhuling_slot_bless
end

function RuneZhuLingView:ResetHighLight()
	for k,v in pairs(self.show_hight_light_list) do
		v:SetValue(false)
	end
end

function RuneZhuLingView:SaveVariable(cur_reward_index, zhuling_slot_bless)
	self.cur_reward_index = cur_reward_index
	self.zhuling_slot_bless = zhuling_slot_bless
end

function RuneZhuLingView:ShowHightLight()
	for i = 1, 6 do
		self.show_hight_light_list[i]:SetValue(i == self.cur_reward_index)
	end
end

function RuneZhuLingView:FlushProgressEffect()
	local slot_cfg = RuneData.Instance:GetRuneZhulingSlotCfg()
	if slot_cfg and slot_cfg[self.cur_reward_index] and slot_cfg[self.cur_reward_index].param1 > 0 and self.zhuling_slot_bless > 0 then
		if self.center_pointer.gameObject.activeInHierarchy and self.handle_slide_obj.gameObject.activeInHierarchy then
			TipsCtrl.Instance:ShowFlyEffectManager(ViewName.Rune, "effects2/prefab/ui/ui_guangdian1_prefab", "UI_guangdian1", self.center_pointer, self.handle_slide_obj, nil, 1)
		end
	else
		self:FlushLingLiProg()
		return false
	end

	if self.delay_flush_prog_timer then
		GlobalTimerQuest:CancelQuest(self.delay_flush_prog_timer)
		self.delay_flush_prog_timer = nil
	end
	self.delay_flush_prog_timer = GlobalTimerQuest:AddDelayTimer(function() 
			self:FlushLingLiProg()
			self.is_rolling = false 
			end, 2)
	return true
end

function RuneZhuLingView:SetAllToggleEnabled(enabled)
	for k,v in pairs(self.slot_cell_list) do
		v:SetToggleEnabled(enabled)
	end
end

function RuneZhuLingView:FlushLingLiProg()
	local other_cfg = RuneData.Instance:GetOtherCfg()
	if self.lingli_prog_text and self.lingli_prog_value then
		self.lingli_prog_text:SetValue(self.zhuling_slot_bless .. "/" .. other_cfg.zhuling_slot_max_value)
		self.lingli_prog_value:SetValue(self.zhuling_slot_bless / other_cfg.zhuling_slot_max_value)
	end

	local cost_str = other_cfg.zhuling_cost or ""
	if self.cost_img ~= nil then
		local bundle, name = ResPath.GetImages("icon_gold_1000")
		local check_item = other_cfg.zhuling_items
		if check_item ~= nil then
			local num = ItemData.Instance:GetItemNumInBagById(check_item)
			if num ~= nil and num >= 1 then
				bundle, name = ResPath.GetImages("icon_lottery_" .. check_item)
				cost_str = string.format(Language.Advance.CostStr, 1, num)
			end
		end

		self.cost_img:SetAsset(bundle, name)
	end

	if self.need_gold_text ~= nil then
		self.need_gold_text:SetValue(cost_str)
	end
end

function RuneZhuLingView:SlotClick(index)
	if self.is_rolling then
		return
	end
	self.is_zhuling = false
	local is_lock = RuneData.Instance:GetIsLockByIndex(index)
	local cfg = RuneData.Instance:GetRuneZhulingGradeCfg(index - 1,0)
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local slot_list = RuneData.Instance:GetSlotList()
	if slot_list[index] and slot_list[index].type < 0 then
		if is_lock or role_level < cfg.open_level then
			local cfg = RuneData.Instance:GetRuneZhulingGradeCfg(index - 1,0)
			local openLayer = RuneData.Instance:GetSlotOpenLayerByIndex(index)
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Rune.LockTipStr,cfg.open_level,openLayer))
		else
			RuneCtrl.Instance:SetSlotIndex(index)
			RuneCtrl.Instance:OpenRuneBagView(RUNE_CELL_TYPE.RUNE_XIANGQIAN_BTN)
		end
		return
	end

	self.cur_select_index = index

	self:ResetLastLevel()
	self:FlushView()
end

function RuneZhuLingView:FlushView()
	local rune_info = RuneData.Instance:GetRuneZhulingInfo()
	if nil == rune_info.zhuling_slot_bless then
		return
	end
	self:ResetVariable()
	self:FlushLingLiProg()

	local slot_list = RuneData.Instance:GetSlotList()
	for k, v in ipairs(self.slot_cell_list) do
		local slot_data = slot_list[k]
		v:SetHighLight(k == self.cur_select_index and slot_data.type >= 0)
		v:SetData(slot_data)
	end

	local grade = rune_info.run_zhuling_list[self.cur_select_index] and rune_info.run_zhuling_list[self.cur_select_index].grade or 0
	local zhuling_bless = rune_info.run_zhuling_list[self.cur_select_index] and rune_info.run_zhuling_list[self.cur_select_index].zhuling_bless or 0

	local grade_cfg = RuneData.Instance:GetRuneZhulingGradeCfg(self.cur_select_index - 1, grade)
	self.level_prog_text:SetValue(zhuling_bless .. "/" .. grade_cfg.need_bless)
	self.level_prog_value:SetValue(zhuling_bless / grade_cfg.need_bless)
	self.jilian_level_str:SetValue(CommonDataManager.GetDaXie(grade_cfg.client_grade))

	--属性
	local cur_attr = CommonDataManager.GetAttributteByClass(grade_cfg)
	self.maxhp:SetValue(cur_attr.max_hp)
	self.gongji:SetValue(cur_attr.gong_ji)
	self.fangyu:SetValue(cur_attr.fang_yu)
	self.shanbi:SetValue(cur_attr.shan_bi)
	self.mingzhong:SetValue(cur_attr.ming_zhong)
	self.baoji:SetValue(cur_attr.bao_ji)
	self.jianren:SetValue(cur_attr.jian_ren)
	self.attr_add:SetValue(grade_cfg.special_add / 100)

	local next_grade_cfg = RuneData.Instance:GetRuneZhulingGradeCfg(self.cur_select_index - 1, grade + 1)
	self.is_max_level:SetValue(nil == next_grade_cfg)

	self.btn_text:SetValue(nil == next_grade_cfg and Language.Common.YiManJi or Language.Rune.ZhuRuLingLi)
	self.btn_zhuling.button.interactable = nil ~= next_grade_cfg

	local other_cfg = RuneData.Instance:GetOtherCfg()
	local cost_str = other_cfg.zhuling_cost or ""
	if self.cost_img ~= nil then
		local bundle, name = ResPath.GetImages("icon_gold_1000")
		local check_item = other_cfg.zhuling_items
		if check_item ~= nil then
			local num = ItemData.Instance:GetItemNumInBagById(check_item)
			if num ~= nil and num >= 1 then
				bundle, name = ResPath.GetImages("icon_lottery_" .. check_item)
				cost_str = string.format(Language.Advance.CostStr, num, 1)
			end
		end

		self.cost_img:SetAsset(bundle, name)
	end

	self.need_gold_text:SetValue(cost_str)

	local next_attr = CommonDataManager.GetAttributteByClass(next_grade_cfg)
	if nil ~= next_grade_cfg then
		self.next_maxhp:SetValue(next_attr.max_hp)
		self.next_gongji:SetValue(next_attr.gong_ji)
		self.next_fangyu:SetValue(next_attr.fang_yu)
		self.next_shanbi:SetValue(next_attr.shan_bi)
		self.next_mingzhong:SetValue(next_attr.ming_zhong)
		self.next_baoji:SetValue(next_attr.bao_ji)
		self.next_jianren:SetValue(next_attr.jian_ren)
		self.next_attr_add:SetValue(next_grade_cfg and next_grade_cfg.special_add / 100 or 0)
	else
		self.level_prog_text:SetValue("0/0")
		self.level_prog_value:SetValue(1)
	end

	self.is_show_maxhp:SetValue((nil ~= grade_cfg and cur_attr.max_hp > 0) or (nil ~= next_grade_cfg and next_attr.max_hp > 0))
	self.is_show_gongji:SetValue((nil ~= grade_cfg and cur_attr.gong_ji > 0) or (nil ~= next_grade_cfg and next_attr.gong_ji > 0))
	self.is_show_fangyu:SetValue((nil ~= grade_cfg and cur_attr.fang_yu > 0) or (nil ~= next_grade_cfg and next_attr.fang_yu > 0))
	self.is_show_mingzhong:SetValue((nil ~= grade_cfg and cur_attr.shan_bi > 0) or (nil ~= next_grade_cfg and next_attr.shan_bi > 0))
	self.is_show_shanbi:SetValue((nil ~= grade_cfg and cur_attr.ming_zhong > 0) or (nil ~= next_grade_cfg and next_attr.ming_zhong > 0))
	self.is_show_baoji:SetValue((nil ~= grade_cfg and cur_attr.bao_ji > 0) or (nil ~= next_grade_cfg and next_attr.bao_ji > 0))
	self.is_show_kangbao:SetValue((nil ~= grade_cfg and cur_attr.jian_ren > 0) or (nil ~= next_grade_cfg and next_attr.jian_ren > 0))

	local stars_count = grade % 5 > 0 and grade % 5 or 5
	stars_count = grade <= 0 and 0 or stars_count
	for i = 1, 5 do
		self.is_show_star_list[i]:SetValue(i <= stars_count)
	end

	--战力
	local select_data = self.slot_cell_list[self.cur_select_index]:GetData()
	local select_rune_data = RuneData.Instance:GetAttrInfo(select_data.quality, select_data.type, select_data.level)
	local attr_info = CommonStruct.AttributeNoUnderline()
	-- 因为合太代码报错，先以此屏蔽报错
	if select_rune_data ~= nil and next(select_rune_data) ~= nil then
		local attr_type_1 = Language.Rune.AttrType[select_rune_data.attr_type_0]
		local attr_type_2 = Language.Rune.AttrType[select_rune_data.attr_type_1]
	end
	if attr_type_1 then
		RuneData.Instance:CalcAttr(attr_info, attr_type_1, select_rune_data.add_attributes_0 * grade_cfg.special_add / 10000)
	end
	if attr_type_2 then
		RuneData.Instance:CalcAttr(attr_info, attr_type_2, select_rune_data.add_attributes_1 * grade_cfg.special_add / 10000)
	end

	local zhuling_cap = CommonDataManager.GetCapabilityCalculation(cur_attr)
	local rune_axtra_cap = CommonDataManager.GetCapabilityCalculation(attr_info)
	self.capability:SetValue(zhuling_cap + rune_axtra_cap)

	self:FlushStars()
	local linglizhi = rune_info.zhuling_slot_bless
	if linglizhi > 0 and self.is_zhuling then
		self:OnZhuLing()
	end
end

function RuneZhuLingView:ResetLastLevel()
	local rune_info = RuneData.Instance:GetRuneZhulingInfo()
	self.last_level = rune_info.run_zhuling_list[self.cur_select_index] and rune_info.run_zhuling_list[self.cur_select_index].grade or 0
end

function RuneZhuLingView:FlushStars()
	local rune_info = RuneData.Instance:GetRuneZhulingInfo()
	if nil == rune_info.zhuling_slot_bless then
		return
	end

	local level = rune_info.run_zhuling_list[self.cur_select_index] and rune_info.run_zhuling_list[self.cur_select_index].grade or 0
	local index = level % 5
	if index == 0 then
		for k, v in pairs(self.stars_list) do
			v.grayscale.GrayScale = level <= 0 and 255 or 0
		end
	else
		for i = 1, index do
			self.stars_list[i].grayscale.GrayScale = 0
		end
		for i = index + 1, 5 do
			self.stars_list[i].grayscale.GrayScale = 255
		end
	end
	if level == self.last_level + 1 then
		self.last_level = level
		if index == 0 then
			index = 5
		end
		EffectManager.Instance:PlayAtTransform("effects2/prefab/misc/effect_baodian_prefab", "Effect_baodian", self.stars_list[index].transform, 1.0, nil, nil)
	end
end

function RuneZhuLingView:OnZhuLing()
	if self.is_rolling then
		return
	end

	if nil == self.slot_cell_list[self.cur_select_index] then
		return
	end

	local select_data = self.slot_cell_list[self.cur_select_index]:GetData()
	if nil == select_data or (select_data and select_data.type < 0) then
		TipsCtrl.Instance:ShowSystemMsg(Language.Rune.PleaseSelect)
		return
	end

	local rune_info = RuneData.Instance:GetRuneZhulingInfo()
	if rune_info.zhuling_slot_bless <= 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Rune.NoLingLi)
	end

	RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_ZHULING, self.cur_select_index - 1)
	self.is_zhuling = true
end

function RuneZhuLingView:OnClickZhuLing()
	local function call()
		self:OnSpawnCircle()
	end

	local other_cfg = RuneData.Instance:GetOtherCfg()

	local cost_str = other_cfg.zhuling_cost or ""
	local check_item = other_cfg.zhuling_items
	if check_item ~= nil then
		local num = ItemData.Instance:GetItemNumInBagById(check_item)
		if num ~= nil and num >= 1 then
			call()
			return
		end
	end

	TipsCtrl.Instance:ShowCommonAutoView("rune_zhuling_view", string.format(Language.Rune.ZhuLingBuyTips, other_cfg.zhuling_cost), call)
end

function RuneZhuLingView:OnSpawnCircle()
	if self.is_rolling then
		return
	end
	if nil == self.slot_cell_list[self.cur_select_index] then
		return
	end

	local select_data = self.slot_cell_list[self.cur_select_index]:GetData()
	if nil == select_data or (select_data.type < 0 and select_data.type < 0) then
		TipsCtrl.Instance:ShowSystemMsg(Language.Rune.PleaseSelect)
		return
	end

	local other_cfg = RuneData.Instance:GetOtherCfg()
	if PlayerData.Instance:GetRoleVo().gold < other_cfg.zhuling_cost then
		TipsCtrl.Instance:ShowLackDiamondView()
		return
	end

	local rune_info = RuneData.Instance:GetRuneZhulingInfo()
	if rune_info.zhuling_slot_bless >= other_cfg.zhuling_slot_max_value then
		TipsCtrl.Instance:ShowSystemMsg(Language.Rune.MaxLingLi)
		return
	end

	RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_RAND_ZHILING_SLOT)
end

function RuneZhuLingView:OnOpenHelp()
	local tips_id = 220
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function RuneZhuLingView:GetSelectIndex()
	return self.cur_select_index
end


-----------------------RuneFuLingCell---------------------------
RuneFuLingCell = RuneFuLingCell or BaseClass(BaseRender)
function RuneFuLingCell:__init(obj, parant)
	self.parent = parant
	self.is_lock = self:FindVariable("IsLock")
	self.image_res = self:FindVariable("ImageRes")
	self.itemlevel = self:FindVariable("ItemLevel")
	self.show_level_text = self:FindVariable("ShowLevelText")

	self:ListenEvent("Click", BindTool.Bind(self.Click, self))
end

function RuneFuLingCell:__delete()
end

function RuneFuLingCell:SetCurrentSelect(index)
	self.select_rune_index = index
end

function RuneFuLingCell:Click()
	if self.clickcallback then
		self.clickcallback(self, self.data)
	end
end

function RuneFuLingCell:SetClickCallBack(callback)
	self.clickcallback = callback
end

function RuneFuLingCell:SetIndex(index)
	self.index = index
end

function RuneFuLingCell:SetHighLight(state)
	self.root_node.toggle.isOn = state
end

function RuneFuLingCell:SetToggleEnabled(enabled)
	if enabled and nil ~= self.data then
		local lock_state = RuneData.Instance:GetIsLockByIndex(self.index)
		local cfg = RuneData.Instance:GetRuneZhulingGradeCfg(self.index - 1,0)
		local role_level = GameVoManager.Instance:GetMainRoleVo().level
		self.is_lock:SetValue(lock_state or (role_level < cfg.open_level))
		self.itemlevel:SetValue(string.format(Language.Rune.OpenLevel,cfg.open_level))
		self.root_node.toggle.enabled = not lock_state and self.data.type >= 0
	else
		self.root_node.toggle.enabled = false
	end
end

function RuneFuLingCell:SetData(data)
	if not data or not next(data) then
		return
	end
	self.data = data

	local item_id = RuneData.Instance:GetRealId(data.quality, data.type)
	if item_id > 0 then
		self.image_res:SetAsset(ResPath.GetItemIcon(item_id))
	end

	self:SetToggleEnabled(true)

	local open_level = RuneData.Instance:GetCurOpenLevelSeq()
	self.show_level_text:SetValue(open_level == self.index)
end

function RuneFuLingCell:GetData()
	return self.data
end