HunQiContentView = HunQiContentView or BaseClass(BaseRender)

local EFFECT_CD = 1
local DISCOUNT_HUNQI_PRASE = 11

function HunQiContentView:__init()
	self.effect_cd = 0

	self.select_hunqi_index = 0								--选择的魂器index
	self.select_kapai_index = 0								--选择的卡牌index
	self.discount_close_time = 0
	self.discount_index = 0

	self.model_display = self:FindObj("ModelDisplay")		--模型
	self.oct_agon = self:FindObj("Octagon")					--八边形
	self.equip_list = self:FindObj("EquipList")				--魂器列表
	self.effect_obj = self:FindObj("EffectObj")				--升级特效位置

	self.hunqi_equip_list = {}
	for i = 0, HunQiData.SHENZHOU_WEAPON_COUNT-1 do
		local obj = self.equip_list.transform:GetChild(i).gameObject
		local equip_cell = HunQiEquipItemCell.New(obj)
		equip_cell:SetIndex(i+1)
		equip_cell:SetClickCallBack(BindTool.Bind(self.ClickHunQiCallBack, self))
		table.insert(self.hunqi_equip_list, equip_cell)
	end

	self.oct_agon_list = {}
	for i = 0, HunQiData.SHENZHOU_WEAPON_SLOT_COUNT-1 do
		local obj = self.oct_agon.transform:GetChild(i).gameObject
		local oct_agon_cell = OctAgonItemCell.New(obj)
		oct_agon_cell:SetIndex(i+1)
		oct_agon_cell:SetClickCallBack(BindTool.Bind(self.ClickKaPaiCallBack, self))
		table.insert(self.oct_agon_list, oct_agon_cell)
	end

	self.button_text = self:FindVariable("ButtonText")				--按钮描述
	self.cost_text = self:FindVariable("CostText")					--消耗描述
	self.have_select = self:FindVariable("HaveSelect")				--是否选中魂器
	self.is_max = self:FindVariable("IsMax")						--对应八卦牌是否已满级
	self.power = self:FindVariable("Power")							--战斗力
	self.hunqi_name = self:FindVariable("HunQiName")				--魂器名字
	self.skill_is_active = self:FindVariable("SkillIsActive")		--是否已激活技能
	self.skill_des = self:FindVariable("SkillDes")					--技能描述
	self.show_skill_des = self:FindVariable("ShowSkillDes")			--展示技能描述
	self.skill_level = self:FindVariable("SkillLevel")				--技能等级
	self.skill_res = self:FindVariable("SkillRes")					--技能图标资源
	self.hunqi_title_name = self:FindVariable("HunQiTitleName")		--魂器名字
	self.show_soul_redpoint = self:FindVariable("ShowSoulRedPoint")	--聚魂红点
	self.total_power = self:FindVariable("TotalPower")				--总战力

	self.show_bipin_icon = self:FindVariable("ShowBiPingIcon")      --比拼图标
	self.discount_time = self:FindVariable("BiPinTime")

	self:ListenEvent("ClickButton", BindTool.Bind(self.ClickButton, self))
	self:ListenEvent("OpenAttrView", BindTool.Bind(self.OpenAttrView, self))
	self:ListenEvent("ClickSkill", BindTool.Bind(self.ClickSkill, self))
	self:ListenEvent("ClickHelp", BindTool.Bind(self.ClickHelp, self))
	self:ListenEvent("OpenSoul", BindTool.Bind(self.OpenSoul, self))
	self:ListenEvent("OnClickBiPin", BindTool.Bind(self.OnClickBiPin, self))
end

function HunQiContentView:__delete()
	for _, v in ipairs(self.hunqi_equip_list) do
		v:DeleteMe()
	end
	self.hunqi_equip_list = {}

	for _, v in ipairs(self.oct_agon_list) do
		v:DeleteMe()
	end
	self.oct_agon_list = {}

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.discount_timer then
		GlobalTimerQuest:CancelQuest(self.discount_timer)
		self.discount_timer = nil
	end
end

function HunQiContentView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(173)
end

function HunQiContentView:OpenSoul()
	ViewManager.Instance:Open(ViewName.GatherSoulView)
end

function HunQiContentView:ClickSkill()
	local hunqi_index = self.select_hunqi_index-1
	local level = HunQiData.Instance:GetHunQiLevelByIndex(hunqi_index)
	local skill_info = HunQiData.Instance:GetSkillInfoByIndex(hunqi_index, level)
	local next_skill_info = HunQiData.Instance:GetSkillInfoByIndex(hunqi_index, level, true)
	if nil == skill_info then
		return
	end

	local skill_name = HunQiData.Instance:GetHunQiSkillByIndex(hunqi_index)
	local skill_level = skill_info.skill_level
	local skill_res_id = HunQiData.Instance:GetHunQiSkillResIdByIndex(hunqi_index)
	local asset, bunble = ResPath.GetHunQiSkillRes(skill_res_id)
	local now_des = ""
	local next_des = ""
	local levelup_des = ""
	if level > 0 then
		now_des = skill_info.skill_dec
	end
	if nil ~= next_skill_info then
		next_des = next_skill_info.skill_dec
		levelup_des = string.format(Language.HunQi.LevelUpDes, next_skill_info.level)
	end
	
	HunQiCtrl.Instance:ShowSkillTips(skill_name, skill_level, now_des, next_des, levelup_des, asset, bunble)
end


function HunQiContentView:OnClickBiPin()
	DisCountCtrl.Instance:JumpToViewIndex(self.discount_index)
	ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {self.discount_index})
end

function HunQiContentView:OpenAttrView()
	local attr_list = HunQiData.Instance:GetAllAttrInfo()
	TipsCtrl.Instance:ShowAttrView(attr_list)
end

function HunQiContentView:ClickButton()
	if self.select_hunqi_index <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.HunQi.NotSelectHunQi)
		return
	end
	if self.select_kapai_index <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.HunQi.NotSelectKaPai)
		return
	end

	HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_UPGRADE_WEAPON_SLOT, self.select_hunqi_index-1, self.select_kapai_index-1)
end

function HunQiContentView:FlushLeftView()
	local hunqi_list = HunQiData.Instance:GetHunQiList()
	if nil == hunqi_list then
		return
	end
	for k, v in ipairs(self.hunqi_equip_list) do
		if k == self.select_hunqi_index then
			v:SetToggleState(true)
		else
			v:SetToggleState(false)
		end
		v:SetData(hunqi_list[k])
	end
	self:FlushLeftContent()
	self:FlushTotalPower()
end

function HunQiContentView:FlushLeftContent()
	local hunqi_name, color_num = HunQiData.Instance:GetHunQiNameAndColorByIndex(self.select_hunqi_index - 1)
	local color = SOUL_NAME_COLOR[color_num]
	hunqi_name = ToColorStr(hunqi_name, color)
	self.hunqi_title_name:SetValue(hunqi_name)
end

function HunQiContentView:FlushModel()
	if nil == self.model then
		self.model = RoleModel.New("hunqi_content_panel")
		self.model:SetDisplay(self.model_display.ui3d_display)
	end
	if self.select_hunqi_index > 0 then
		self.is_model_change = true
		local res_id = HunQiData.Instance:GetHunQiResIdByIndex(self.select_hunqi_index-1)
		local asset, bunble = ResPath.GetHunQiModel(res_id)
		local function complete_callback()
			self.is_model_change = false
			if self.model then
				local is_active_special = HunQiData.Instance:IsActiveSpecial(self.select_hunqi_index)
				self.model:ShowAttachPoint(AttachPoint.Weapon, not is_active_special)
				self.model:ShowAttachPoint(AttachPoint.Weapon2, is_active_special)
			end
		end
		self.model:SetPanelName(HunQiData.Instance:SetSpecialModle(res_id))
		self.model:SetMainAsset(asset, bunble, complete_callback)
		self.model:ResetRotation()
	else
		self.model:ClearModel()
	end
end

--改变模型特效
function HunQiContentView:FlushModelEffect()
	if not self.is_model_change then
		if self.model then
			local is_active_special = HunQiData.Instance:IsActiveSpecial(self.select_hunqi_index)
			self.model:ShowAttachPoint(AttachPoint.Weapon, not is_active_special)
			self.model:ShowAttachPoint(AttachPoint.Weapon2, is_active_special)
		end
	end
end

function HunQiContentView:FlushCostDes()
	local hunqi_list = HunQiData.Instance:GetHunQiList()
	if nil == hunqi_list then
		return
	end

	local kapai_level_list = hunqi_list[self.select_hunqi_index].weapon_slot_level_list
	if nil == kapai_level_list then
		return
	end
	local select_kapai_level = kapai_level_list[self.select_kapai_index] or 0
	local select_kapai_data = HunQiData.Instance:GetSlotAttrByLevel(self.select_hunqi_index-1, self.select_kapai_index-1, select_kapai_level)
	if nil == select_kapai_data then
		return
	end
	local item_data = select_kapai_data[1].up_level_item or {}
	local item_id = item_data.item_id or 0
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_cfg then
		return
	end
	local item_name = item_cfg.name or ""
	local item_color = SOUL_NAME_COLOR[item_cfg.color] or TEXT_COLOR.WHITE
	local now_num = ItemData.Instance:GetItemNumInBagById(item_id)
	local cost_num = item_data.num or 0
	local now_num_str = now_num
	if now_num < cost_num then
		now_num_str = ToColorStr(now_num, TEXT_COLOR.RED_1)
	else
		now_num_str = ToColorStr(now_num, TEXT_COLOR.TONGYONG_TS)
	end
	local cost_des = string.format(Language.HunQi.NeedCostDes, ToColorStr(item_name, item_color), now_num_str, cost_num)
	self.cost_text:SetValue(cost_des)
end


function HunQiContentView:FlushRightView()
	if self.select_hunqi_index <= 0 then
		self.have_select:SetValue(false)
		return
	end
	self.have_select:SetValue(true)

	local hunqi_list = HunQiData.Instance:GetHunQiList()
	if nil == hunqi_list then
		return
	end
	--设置魂器名字
	local hunqi_name, color_num = HunQiData.Instance:GetHunQiNameAndColorByIndex(self.select_hunqi_index - 1)
	local color = SOUL_NAME_COLOR[color_num]
	hunqi_name = ToColorStr(hunqi_name, color)
	self.hunqi_name:SetValue(hunqi_name)

	--设置卡牌数据
	local kapai_level_list = hunqi_list[self.select_hunqi_index].weapon_slot_level_list
	if nil == kapai_level_list then
		return
	end
	local select_index = 0
	local is_select_change = false
	local is_active_skill = true
	for k, v in ipairs(self.oct_agon_list) do
		--判断卡牌红点
		local is_show_redpoint = false
		local kapai_level = kapai_level_list[k]
		if nil ~= kapai_level and kapai_level < HunQiData.SLOT_MAX_LEVEL then
			local kapai_data = HunQiData.Instance:GetSlotAttrByLevel(self.select_hunqi_index-1, k-1, kapai_level)
			if nil ~= kapai_data then
				kapai_data = kapai_data[1]
				local up_level_item_data = kapai_data.up_level_item
				local now_item_num = ItemData.Instance:GetItemNumInBagById(up_level_item_data.item_id)
				if now_item_num >= up_level_item_data.num then
					is_show_redpoint = true
				end
			end
		end

		if is_show_redpoint and not is_select_change then
			select_index = k
			is_select_change = true
		end
		if self.select_kapai_index == k and is_show_redpoint then
			select_index = self.select_kapai_index
		end
		
		v:ShowRedPoint(is_show_redpoint)
		local res_id = HunQiData.Instance:GetHunQiResIdByIndex(self.select_hunqi_index-1)
		local data = {parent_res_id = res_id, level = kapai_level}
		v:SetData(data)
	end

	--设置技能是否已激活
	local hunqi_level = HunQiData.Instance:GetHunQiLevelByIndex(self.select_hunqi_index-1)
	self.skill_is_active:SetValue(hunqi_level > 0)

	--设置技能图标
	local skill_res_id = HunQiData.Instance:GetHunQiSkillResIdByIndex(self.select_hunqi_index-1)
	self.skill_res:SetAsset(ResPath.GetHunQiSkillRes(skill_res_id))

	--设置技能等级
	local skill_info = HunQiData.Instance:GetSkillInfoByIndex(self.select_hunqi_index-1, hunqi_level)
	if nil ~= skill_info then
		self.skill_level:SetValue("Lv." .. skill_info.skill_level)
	end

	--刷新选中
	if select_index > 0 then
		self.select_kapai_index = select_index
	end
	for k, v in ipairs(self.oct_agon_list) do
		if k == self.select_kapai_index then
			v:SetToggleState(true)
		else
			v:SetToggleState(false)
		end
	end

	--设置战斗力
	local capability = HunQiData.Instance:GetHunQiCapability(self.select_hunqi_index)
	self.power:SetValue(capability)

	--判断卡牌是否满级
	local select_kapai_level = kapai_level_list[self.select_kapai_index] or 0
	if select_kapai_level >= HunQiData.SLOT_MAX_LEVEL then
		self.cost_text:SetValue("")
		self.button_text:SetValue(Language.Common.YiManJi)
		self.is_max:SetValue(true)
		return
	end
	self.is_max:SetValue(false)

	if select_kapai_level <= 0 then
		self.button_text:SetValue(Language.Common.Activate)
	else
		self.button_text:SetValue(Language.Common.UpGrade)
	end

	--设置消耗描述
	self:FlushCostDes()
end

function HunQiContentView:UpGradeResult(result)
	if result ~= 1 then
		return
	end
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		EffectManager.Instance:PlayAtTransformCenter(
				"effects2/prefab/ui/ui_jinengshengji_1_prefab",
				"UI_Jinengshengji_1",
				self.effect_obj.transform,
				2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

function HunQiContentView:FlushElementRed()
	local hunqi_list = HunQiData.Instance:GetHunQiList()
	if hunqi_list == nil then
		return
	end

	local is_show = false
	for k1, v1 in ipairs(hunqi_list) do
		if is_show then
			break
		end
		local hunqi_level = v1.weapon_level
		local element_level_list = v1.element_level_list
		for k2, v2 in ipairs(element_level_list) do
			local next_attr_info = HunQiData.Instance:GetSoulAttrInfo(k1-1, k2-1, v2+1)
			if nil ~= next_attr_info then
				local attr_info = HunQiData.Instance:GetSoulAttrInfo(k1-1, k2-1, v2)
				attr_info = attr_info[1]
				local limit_level = attr_info.huqi_level_limit
				if hunqi_level >= limit_level then
					local up_level_item = attr_info.up_level_item
					local have_num = ItemData.Instance:GetItemNumInBagById(up_level_item.item_id)
					if have_num >= up_level_item.num then
						is_show = true
						break
					end
				end
			end
		end
	end
	self.show_soul_redpoint:SetValue(is_show)
end

function HunQiContentView:InitView()
	self.select_hunqi_index = 1
	self.select_kapai_index = 1

	--隐藏技能描述
	self.show_skill_des:SetValue(false)

	self:FlushLeftView()

	self:FlushModel()

	self:FlushModelEffect()

	self:FlushRightView()

	self:FlushElementRed()

	local discount_info, index = DisCountData.Instance:GetDiscountInfoByType(DISCOUNT_HUNQI_PRASE)
	self.discount_index = index
	self.show_bipin_icon:SetValue(discount_info ~= nil)

	self.discount_close_time = discount_info and discount_info.close_timestamp or 0
	if discount_info and self.discount_timer == nil then
		self:UpdateTimer()
		if self.discount_timer then
			GlobalTimerQuest:CancelQuest(self.discount_timer)
			self.discount_timer = nil
		end
		self.discount_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateTimer, self), 1)
	end
end

function HunQiContentView:UpdateTimer()
	local time = self.discount_close_time - TimeCtrl.Instance:GetServerTime()
	if time <= 0 then
		GlobalTimerQuest:CancelQuest(self.discount_timer)
		self.discount_timer = nil
		self.show_bipin_icon:SetValue(false)
	else
		if time > 24 * 3600 then
			self.discount_time:SetValue(TimeUtil.FormatSecond(time, 7))
		else
			self.discount_time:SetValue(TimeUtil.FormatSecond(time, 1))
		end
	end
end


function HunQiContentView:FlushView()
	self:FlushLeftView()
	self:FlushRightView()
	self:FlushModelEffect()
	self:FlushElementRed()
end

function HunQiContentView:ClickHunQiCallBack(cell)
	if nil == cell then
		return
	end
	cell:SetToggleState(true)
	local index = cell:GetIndex()
	if index == self.select_hunqi_index then
		return
	end
	self.select_hunqi_index = index

	self.select_kapai_index = 1
	self:FlushModel()
	self:FlushRightView()
	self:FlushLeftContent()
end

function HunQiContentView:ClickKaPaiCallBack(cell)
	if nil == cell then
		return
	end
	cell:SetToggleState(true)
	local index = cell:GetIndex()
	if index == self.select_kapai_index then
		return
	end
	self.select_kapai_index = index

	local data = cell:GetData()
	local level = data.level

	if level >= HunQiData.SLOT_MAX_LEVEL then
		self.cost_text:SetValue("")
		self.button_text:SetValue(Language.Common.YiManJi)
		self.is_max:SetValue(true)
		return
	end

	self.is_max:SetValue(false)
	if level <= 0 then
		self.button_text:SetValue(Language.Common.Activate)
	else
		self.button_text:SetValue(Language.Common.UpGrade)
	end

	--设置消耗描述
	local select_kapai_data = HunQiData.Instance:GetSlotAttrByLevel(self.select_hunqi_index-1, index-1, level)
	if nil == select_kapai_data then
		return
	end
	local item_data = select_kapai_data[1].up_level_item or {}
	local item_id = item_data.item_id or 0
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_cfg then
		return
	end
	local item_name = item_cfg.name or ""
	local item_color = SOUL_NAME_COLOR[item_cfg.color] or TEXT_COLOR.WHITE
	local now_num = ItemData.Instance:GetItemNumInBagById(item_id)
	local cost_num = item_data.num or 0
	local now_num_str = now_num
	if now_num < cost_num then
		now_num_str = ToColorStr(now_num, TEXT_COLOR.RED_1)
	else
		now_num_str = ToColorStr(now_num, TEXT_COLOR.TONGYONG_TS)
	end
	local cost_des = string.format(Language.HunQi.NeedCostDes, ToColorStr(item_name, item_color), now_num_str, cost_num)
	self.cost_text:SetValue(cost_des)
end

--刷新总战斗力
function HunQiContentView:FlushTotalPower()
	local all_attr_info = HunQiData.Instance:GetAllAttrInfo()
	local capability = CommonDataManager.GetCapabilityCalculation(all_attr_info)
	self.total_power:SetValue(capability)
end

-------------------------------------------------------------------------------
-------------------------------HunQiEquipItemCell------------------------------
-------------------------------------------------------------------------------
HunQiEquipItemCell = HunQiEquipItemCell or BaseClass(BaseCell)
function HunQiEquipItemCell:__init()
	self.name = self:FindVariable("Name")
	self.icon_res = self:FindVariable("IconRes")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.is_active = self:FindVariable("IsActive")

	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
end

function HunQiEquipItemCell:__delete()

end

function HunQiEquipItemCell:OnFlush()
	if nil == self.data then
		return
	end

	local level = self.data.weapon_level
	local name_des = "Lv." .. level
	self.name:SetValue(name_des)

	--判断是否激活
	if level <= 0 then
		self.is_active:SetValue(false)
	else
		self.is_active:SetValue(true)
	end

	--设置红点
	local is_show = false
	local kapai_level_list = self.data.weapon_slot_level_list
	if nil == kapai_level_list then
		return
	end
	for k, v in ipairs(kapai_level_list) do
		if v < HunQiData.SLOT_MAX_LEVEL then
			local kapai_data = HunQiData.Instance:GetSlotAttrByLevel(self.index-1, k-1, v)
			if nil ~= kapai_data then
				kapai_data = kapai_data[1]
				local up_level_item_data = kapai_data.up_level_item
				local now_item_num = ItemData.Instance:GetItemNumInBagById(up_level_item_data.item_id)
				if now_item_num >= up_level_item_data.num then
					is_show = true
					break
				end
			end
		end
	end
	self.show_red_point:SetValue(is_show)

	--设置图标
	local model_res_id = HunQiData.Instance:GetHunQiResIdByIndex(self.index-1)
	local param = model_res_id - (math.floor(model_res_id/1000) * 1000)
	local res_id = "HunQi_" .. param
	self.icon_res:SetAsset(ResPath.GetHunQiImg(res_id))
end

function HunQiEquipItemCell:SetToggleState(state)
	self.root_node.toggle.isOn = state
end

-------------------------------------------------------------------------------
-------------------------------OctAgonItemCell------------------------------
-------------------------------------------------------------------------------
OctAgonItemCell = OctAgonItemCell or BaseClass(BaseCell)
function OctAgonItemCell:__init()
	self.gray = self:FindVariable("Gray")
	self.level = self:FindVariable("Level")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.ka_pai_res = self:FindVariable("KaPaiRes")

	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
end

function OctAgonItemCell:__delete()

end

function OctAgonItemCell:OnFlush()
	if nil == self.data then
		return
	end
	self.gray:SetValue(self.data.level <= 0)
	self.level:SetValue(self.data.level)

	if self.data.parent_res_id then
		local parent_param = self.data.parent_res_id - (math.floor(self.data.parent_res_id/1000) * 1000)
		local res_id = "KaPai" .. parent_param .. "_" .. self.index
		self.ka_pai_res:SetAsset(ResPath.GetHunQiKaPaiImg(parent_param,res_id))
	end
end

function OctAgonItemCell:SetToggleState(state)
	self.root_node.toggle.isOn = state
end

function OctAgonItemCell:ShowRedPoint(state)
	self.show_red_point:SetValue(state)
end