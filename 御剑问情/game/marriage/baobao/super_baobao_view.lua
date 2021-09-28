SuperBaoBaoView = SuperBaoBaoView or BaseClass(BaseView)

function SuperBaoBaoView:__init()
	self.ui_config = {"uis/views/marriageview_prefab", "SuperBaoBaoView"}
end

function SuperBaoBaoView:__delete()
end

function SuperBaoBaoView:ReleaseCallBack()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end

	self.hp_value = nil
	self.attack_value = nil
	self.fangyu_value = nil
	self.sepcial_name = nil
	self.fight_power = nil
	self.cost_value = nil
	self.add_attr_per = nil
	self.show_huan_hua_btn = nil
	self.show_buy_btn = nil
	self.show_cancel = nil
	self.show_limit_text = nil
	self.show_fetch_flag = nil
	self.show_active_btn = nil
	self.show_red_point = nil
	self.level = nil
	self.show_rename_btn = nil
	self.time_des = nil
end

function SuperBaoBaoView:LoadCallBack()
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("Item"))

	local display = self:FindObj("Display")
	self.model = RoleModel.New("super_baobao_panel")
	self.model:SetDisplay(display.ui3d_display)

	self.hp_value = self:FindVariable("hp_value")
	self.attack_value = self:FindVariable("attack_value")
	self.fangyu_value = self:FindVariable("fangyu_value")
	self.sepcial_name = self:FindVariable("SpecialName")
	self.fight_power = self:FindVariable("FightPower")
	self.cost_value = self:FindVariable("CostValue")
	self.add_attr_per = self:FindVariable("AddAttrPer")
	self.show_cancel = self:FindVariable("ShowCancelHuanHua")
	self.show_huan_hua_btn = self:FindVariable("ShowHuanHuaBtn")
	self.show_buy_btn = self:FindVariable("ShowBuyBtn")
	self.show_limit_text = self:FindVariable("ShowLimitText")
	self.show_fetch_flag = self:FindVariable("ShowFetchFlag")
	self.show_active_btn = self:FindVariable("ShowActiveBtn")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.level = self:FindVariable("Level")
	self.show_rename_btn = self:FindVariable("ShowReNameBtn")
	self.time_des = self:FindVariable("TimeDes")

	self:ListenEvent("OnClickBuy",BindTool.Bind(self.OnClickBuy,self))
	self:ListenEvent("Close",BindTool.Bind(self.ClickClose, self))
	self:ListenEvent("OnClickHuanHua",BindTool.Bind(self.OnClickHuanHua, self))
	self:ListenEvent("OnClickCancelIma",BindTool.Bind(self.OnClickCancelIma, self))
	self:ListenEvent("OnCLickFetch",BindTool.Bind(self.OnCLickFetch, self))
	self:ListenEvent("OnClickActive",BindTool.Bind(self.OnClickActive, self))
	self:ListenEvent("OnClickReName",BindTool.Bind(self.OnClickReName, self))
end

function SuperBaoBaoView:ClickClose()
	self:Close()
end

function SuperBaoBaoView:OnClickBuy()
	local other_cfg = BaobaoData.Instance:GetBabyOtherCfg()
	local item_cfg = ItemData.Instance:GetItemConfig(other_cfg.sup_baby_card_item_id)
	if nil == item_cfg then
		return
	end

	local cost_gold = other_cfg.sup_baby_need_gold
	local ok_fun = function ()
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if vo.gold < cost_gold then
			TipsCtrl.Instance:ShowLackDiamondView(function()
				self:Close()
			end)
			return
		else
			BaobaoCtrl.SendBabyOperaReq(BABY_REQ_TYPE.BABY_REQ_TYPE_SUP_BABY_QIFU, nil, nil, nil, 2)
		end
	end

	local gold_des = ToColorStr(cost_gold, TEXT_COLOR.BLUE1)
	local item_color = ITEM_COLOR[item_cfg.color]
	local item_name = ToColorStr(item_cfg.name, item_color)
	local tips_text = string.format(Language.Common.UsedGoldToBuySomething, gold_des, item_name)
	TipsCtrl.Instance:ShowCommonAutoView(nil, tips_text, ok_fun)
end

function SuperBaoBaoView:OnClickHuanHua()
	BaobaoCtrl.SendBabyOperaReq(BABY_REQ_TYPE.BABY_REQ_TYPE_SUP_BABY_VIEW, 1)
end

function SuperBaoBaoView:OnClickCancelIma()
	BaobaoCtrl.SendBabyOperaReq(BABY_REQ_TYPE.BABY_REQ_TYPE_SUP_BABY_VIEW, 0)
end

function SuperBaoBaoView:OnCLickFetch()
	BaobaoCtrl.SendBabyOperaReq(BABY_REQ_TYPE.BABY_REQ_TYPE_SUP_BABY_AWARD, nil, nil, nil, 2)
end

function SuperBaoBaoView:OnClickActive()
	local item_id = BaobaoData.Instance:GetSuperBabyItemId()
	local index = ItemData.Instance:GetItemIndex(item_id)
	if index >= 0 then
		PackageCtrl.Instance:SendUseItem(index)
	end
end

function SuperBaoBaoView:OnClickReName()
	local func = function(name)
		BaobaoCtrl.Instance:ReqSupBabyRename(name)
	end
	TipsCtrl.Instance:ShowRename(func, true, BaobaoData.Instance:GetBabyOtherCfg().rename_card_id)
end

function SuperBaoBaoView:OpenCallBack()
	self:FlushModel()
	self:FlushItem()
	self:Flush()
end

function SuperBaoBaoView:CloseCallBack()
	self:StopCountDown()
end

function SuperBaoBaoView:FlushModel()
	local info = BaobaoData.Instance:GetSuperBabyInfo()
	if info == nil then
		return
	end

	local cfg_info = BaobaoData.Instance:GetSuperBabyCfgInfo(math.max(info.baby_id, 0))
	if cfg_info == nil then
		return
	end
	
	local bundle, asset = ResPath.GetSpiritModel(cfg_info.res_id)
	self.model:SetMainAsset(bundle, asset)
	self.model:ResetRotation()
end

function SuperBaoBaoView:FlushName()
	local info = BaobaoData.Instance:GetSuperBabyInfo()
	if info == nil then
		return
	end

	local name = ""
	if BaobaoData.Instance:IsActiveSuperBaby() and info.baby_name ~= "" then
		name = info.baby_name
	else
		local cfg_info = BaobaoData.Instance:GetSuperBabyCfgInfo(math.max(info.baby_id, 0))
		if cfg_info then
			name = cfg_info.name
		end
	end
	self.sepcial_name:SetValue(name)
end

function SuperBaoBaoView:FlushItem()
	local item_id = BaobaoData.Instance:GetSuperBabyItemId()
	self.item:SetData({item_id = item_id})
	self.item:SetInteractable(false)
end

function SuperBaoBaoView:FlushContent()
	local info = BaobaoData.Instance:GetSuperBabyInfo()
	if info == nil then
		return
	end

	local cfg_info = BaobaoData.Instance:GetSuperBabyCfgInfo(math.max(info.baby_id, 0))
	local grade_cfg_info = BaobaoData.Instance:GetSuperBabyGradeCfg(math.max(info.grade, 0))
	if cfg_info == nil or grade_cfg_info == nil then
		return
	end

	--设置等级
	self.level:SetValue(grade_cfg_info.grade + 1)

	local other_cfg = BaobaoData.Instance:GetBabyOtherCfg()
	--设置消耗
	self.cost_value:SetValue(other_cfg.sup_baby_need_gold)

	local attribute = {}
	attribute.maxhp = cfg_info.maxhp + grade_cfg_info.maxhp
	attribute.gongji = cfg_info.gongji + grade_cfg_info.gongji
	attribute.fangyu = cfg_info.fangyu + grade_cfg_info.fangyu

	self.hp_value:SetValue(attribute.maxhp)
	self.attack_value:SetValue(attribute.gongji)
	self.fangyu_value:SetValue(attribute.fangyu)

	--计算加成的属性
	local all_baby_attr_info = BaobaoData.Instance:GetAllBabyAttrInfo()
	local add_attr_info = {}
	local add_per = grade_cfg_info.sup_baby_inc_attr_per / 10000
	add_attr_info.maxhp = all_baby_attr_info.maxhp * add_per
	add_attr_info.gongji = all_baby_attr_info.gongji * add_per
	add_attr_info.fangyu = all_baby_attr_info.fangyu * add_per

	--设置加成描述
	local add_str = string.format(Language.Marriage.SuperBaoBaoAddPerDes, add_per * 100)
	self.add_attr_per:SetValue(add_str)

	--计算总属性
	attribute.maxhp = attribute.maxhp + add_attr_info.maxhp
	attribute.gongji = attribute.gongji + add_attr_info.gongji
	attribute.fangyu = attribute.fangyu + add_attr_info.fangyu

	--计算战斗力
	local cap = CommonDataManager.GetCapabilityCalculation(attribute)
	self.fight_power:SetValue(cap)

	--刷新按钮显示
	local is_active = BaobaoData.Instance:IsActiveSuperBaby()

	self.show_rename_btn:SetValue(is_active)

	local can_get_reward_flag = BaobaoData.Instance:CanGetSuperReward()
	--是否可领取
	self.show_fetch_flag:SetValue(can_get_reward_flag)

	local item_id = BaobaoData.Instance:GetSuperBabyItemId()
	local num = ItemData.Instance:GetItemNumInBagById(item_id)
	local max_grade = BaobaoData.Instance:GetSuperBabyMaxGrade()
	local can_level_up = info.grade < max_grade and num > 0 or false

	self.show_red_point:SetValue(can_get_reward_flag or can_level_up)
	--是否可激活
	self.show_active_btn:SetValue(not is_active and can_level_up)
	--是否可购买
	self.show_buy_btn:SetValue(not can_get_reward_flag and not is_active and num <= 0)

	--是否可幻化（1出战 0收回）
	self.show_huan_hua_btn:SetValue(is_active and info.fight_flag == 0)
	--是否可取消幻化
	self.show_cancel:SetValue(is_active and info.fight_flag == 1)
end

function SuperBaoBaoView:StopCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function SuperBaoBaoView:StartCountDown()
	self:StopCountDown()
	self.show_limit_text:SetValue(false)

	--可领取大目标或者已激活大目标则不计时
	if BaobaoData.Instance:CanGetSuperReward() or BaobaoData.Instance:IsActiveSuperBaby() then
		return
	end

	local other_cfg = BaobaoData.Instance:GetBabyOtherCfg()
	local total_time = other_cfg.award_super_baby_limit_time * 3600
	local left_time = BaobaoData.Instance:LeftTimeByTotalTime(total_time)
	if left_time <= 0 then
		return
	end

	self.show_limit_text:SetValue(true)
	local des = TimeUtil.FormatBySituation(left_time)
	local function time_func(elapse_time, total_time)
		if elapse_time >= total_time then
			self.show_limit_text:SetValue(false)
			return
		end

		left_time = total_time - math.floor(elapse_time)
		des = TimeUtil.FormatBySituation(left_time)
		self.time_des:SetValue(des)
	end
	self.count_down = CountDown.Instance:AddCountDown(left_time, 1, time_func)

	--设置一次时间
	self.time_des:SetValue(des)
end

function SuperBaoBaoView:OnFlush()
	self:FlushContent()
	self:FlushName()
	self:StartCountDown()
end