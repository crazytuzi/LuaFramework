RebirthAdvanceView = RebirthAdvanceView or BaseClass(BaseRender)
-- 转生升级界面
function RebirthAdvanceView:__init()
	self.cell_list = {}
	self.select_index = 1
	self.is_auto = false		-- 是否自动升级
end

function RebirthAdvanceView:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end

	if self.item_leck_change then
		GlobalEventSystem:UnBind(self.item_leck_change)
		self.item_leck_change = nil
	end

end

function RebirthAdvanceView:LoadCallBack()
	self.model_display = self:FindObj("ModelDisplay")
	if self.model_display then
		self.model = RoleModel.New()
		self.model:SetDisplay(self.model_display.ui3d_display)
	end
	self.role_name = self:FindVariable("RoleName")
	self:SetModel()
	self.un_lock = self:FindVariable("Unlock")

	self:ListenEvent("OnClickRule", BindTool.Bind(self.OnClickRule, self))
	self.rebirth_level = self:FindVariable("RebirthLevel")
	self.capacity = self:FindVariable("Capacity")
	self.gongji = self:FindVariable("Gongji")
	self.hp = self:FindVariable("Hp")
	self.fangyu = self:FindVariable("Fangyu")
	self.mingzhong = self:FindVariable("Mingzhong")

	self.progress = self:FindVariable("Progress")
	self.percent = self:FindVariable("Percent")

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.cur_item_num = self:FindVariable("CurItemNum")
	self.cfg_item_num = self:FindVariable("CfgItemNum")

	self:ListenEvent("OnUpgrade", BindTool.Bind(self.OnUpgrade, self))
	self:ListenEvent("OnAutoUpgrade", BindTool.Bind(self.OnAutoUpgrade, self))
	self.upgrade_button = self:FindObj("UpgradeButton")	-- 点击是否有效果
	self.auto_button = self:FindObj("AutomaticButton")
	self.is_gray_btn = self:FindVariable("IsGrayBtn")	-- 是否置灰的
	self.is_gray_auto_btn = self:FindVariable("IsGrayAutoBtn")

	self.btn_upgrade_text = self:FindVariable("BtnUpgradeText")
	self.btn_upgrade_text:SetValue(Language.Rebirth.AutoUpgrade)

	self.item_leck_change = GlobalEventSystem:Bind(KnapsackEventType.KNAPSACK_LECK_ITEM, BindTool.Bind1(self.OnItemLeckChange, self))
	self.show_advance_red = self:FindVariable("ShowAdvanceRed")
	self.tip_text = self:FindVariable("TipText")
	self.show_tip_text = self:FindVariable("ShowTipText")
end

function RebirthAdvanceView:OnFlush()
	local rebirth_level = RebirthData.Instance:GetRebirthLevel()
	self.rebirth_level:SetValue(rebirth_level)

	local one_rebirth_cfg = RebirthData.Instance:GetOneRebirthCfgByLevel(rebirth_level)
	local cur_rebirth_attr = RebirthData.Instance:CalCurAttr(rebirth_level)

	local capacity = CommonDataManager.GetCapabilityCalculation(cur_rebirth_attr)
	self.capacity:SetValue(capacity)

	self.gongji:SetValue(cur_rebirth_attr.gongji)
	self.hp:SetValue(cur_rebirth_attr.maxhp)
	self.fangyu:SetValue(cur_rebirth_attr.fangyu)
	self.mingzhong:SetValue(cur_rebirth_attr.mingzhong)

	local cur_bless = RebirthData.Instance:GetCurBless()
	if 0 == one_rebirth_cfg.bless_max_value then
		self.progress:InitValue(0)
	else
		self.progress:SetValue(cur_bless/one_rebirth_cfg.bless_max_value)
	end
	self.percent:SetValue(cur_bless .. "/" .. one_rebirth_cfg.bless_max_value)

	local rebirth_num = ItemData.Instance:GetItemNumInBagById(one_rebirth_cfg.consume_item_id)
	self.item_cell:SetData({item_id = one_rebirth_cfg.consume_item_id})

	local active_level = RebirthData.Instance:GetSuitActivityGrade()
	local zhuansheng_level = RebirthData.Instance:GetZhuanShengLevelByActive(active_level)
	self.show_advance_red:SetValue(rebirth_num > 0 and rebirth_level < zhuansheng_level)

	if rebirth_num >= one_rebirth_cfg.consume_count then
		rebirth_num = ToColorStr(rebirth_num, COLOR.GREEN)
	else
		rebirth_num = ToColorStr(rebirth_num, COLOR.RED)
	end
	self.cur_item_num:SetValue(rebirth_num)
	self.cfg_item_num:SetValue(one_rebirth_cfg.consume_count)

	if rebirth_level >= zhuansheng_level then
		self.progress:InitValue(1)
	end

	local cfg = RebirthData.Instance:GetRebirthCfg()
	if cfg[#cfg].zhuansheng_level == rebirth_level then
		self.upgrade_button:SetActive(true)
		self.auto_button:SetActive(true)
		self.is_gray_btn:SetValue(true)
		self.is_gray_auto_btn:SetValue(true)
		self.show_advance_red:SetValue(false)
		return
	else
		self.show_tip_text:SetValue(rebirth_level >= zhuansheng_level)
		self.is_gray_btn:SetValue(rebirth_level >= zhuansheng_level)
		self.is_gray_auto_btn:SetValue(rebirth_level >= zhuansheng_level)
		self.upgrade_button.button.interactable = rebirth_level < zhuansheng_level
		self.auto_button.button.interactable = rebirth_level < zhuansheng_level
	end

	local next_rebirth_cfg = RebirthData.Instance:GetOneRebirthCfgByLevel(rebirth_level + 1)
	local next_activate_need_level = next_rebirth_cfg.activate_need_level

	local suit_grade_cfg = RebirthData.Instance:GetSuitGradeCfg(next_activate_need_level)
	self.tip_text:SetValue(ToColorStr(suit_grade_cfg.suit_name,COLOR.GREEN))
end

function RebirthAdvanceView:SetModel()
	local main_role = GameVoManager.Instance:GetMainRoleVo()
	if self.model then
		self.model:SetModelResInfo(main_role, nil, nil, nil, nil, true)
	end

	local str = ToColorStr(Language.Common.ScnenCampNameAbbr[main_role.camp], COLOR[CAMP_BY_STR[main_role.camp]])
	str = str .. "·" .. main_role.name
	self.role_name:SetValue(str)
end

function RebirthAdvanceView:OnClickRule()
	TipsCtrl.Instance:ShowHelpTipView(249)
end

-- 升级
function RebirthAdvanceView:OnUpgrade()
	RebirthCtrl.Instance:SendReqRebirthAllInfo(REBIRTH_REQ_TYPE.ZHUANSHENGSYSTEM_REQ_TYPE_ZHUANSHENG_LEVEL)
end

-- 自动升级按钮
function RebirthAdvanceView:OnAutoUpgrade()
	if self.is_auto then
		self.is_auto = false
		self.btn_upgrade_text:SetValue(Language.Rebirth.AutoUpgrade)
	else
		self.is_auto = true
		self.btn_upgrade_text:SetValue(Language.Rebirth.StopUpgrade)
	end	
	self:AutoUpgradeOnce()
end

function RebirthAdvanceView:FlushRebirthUpgrade(result)
	if 0 == result then 		-- 不再发送升级请求
		self.is_auto = false
		self.btn_upgrade_text:SetValue(Language.Rebirth.AutoUpgrade)
	elseif 1 == result then 	-- 继续发送请求
		if self.is_auto then
			self.btn_upgrade_text:SetValue(Language.Rebirth.StopUpgrade)
		end
		self:AutoUpgradeOnce()
	end
end

-- 自动升级
function RebirthAdvanceView:AutoUpgradeOnce()
	local upgrade_next_time = 0
	if self.upgrade_timer_quest then
		if self.upgrade_next_time >= Status.NowTime then
			upgrade_next_time = self.upgrade_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end
	if self.is_auto then
		self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.UpdateOcne, self), upgrade_next_time)
	end
end

function RebirthAdvanceView:UpdateOcne(upgrade_next_time)
	local cur_level = RebirthData.Instance:GetSuitActivityGrade()
	local suit_grade_cfg = RebirthData.Instance:GetRebirthCfg()
	local cfg_num =  #suit_grade_cfg
	if cur_level == cfg_num then self.is_auto = false return end

	RebirthCtrl.Instance:SendReqRebirthAllInfo(REBIRTH_REQ_TYPE.ZHUANSHENGSYSTEM_REQ_TYPE_ZHUANSHENG_LEVEL, 1, 1)

	self.upgrade_next_time = Status.NowTime + 0.1
end

function RebirthAdvanceView:OnItemLeckChange(item_id, item_count)
	local rebirth_level = RebirthData.Instance:GetRebirthLevel()
	local one_rebirth_cfg = RebirthData.Instance:GetOneRebirthCfgByLevel(rebirth_level)
	if item_id == one_rebirth_cfg.consume_item_id then
		self.btn_upgrade_text:SetValue(Language.Rebirth.AutoUpgrade)
	end
end

function RebirthAdvanceView:ClearData()
	self.is_auto = false
end
