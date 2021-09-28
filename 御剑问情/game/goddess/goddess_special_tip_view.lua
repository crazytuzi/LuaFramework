GoddessSpecialTipView = GoddessSpecialTipView or BaseClass(BaseView)


function GoddessSpecialTipView:__init()
	self.ui_config = {"uis/views/goddess_prefab", "GoddessSpecialTip"}
	self.play_audio = true
end

function GoddessSpecialTipView:__delete()
	-- body
end

function GoddessSpecialTipView:LoadCallBack()

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("Item"))
	self.display = self:FindObj("Display")
	self.model = RoleModel.New("display_model_sepcial_goddess")
	self.model:SetDisplay(self.display.ui3d_display)

	self.hp_value = self:FindVariable("hp_value")
	self.attack_value = self:FindVariable("attack_value")
	self.fangyu_value = self:FindVariable("fangyu_value")
	self.sepcial_name = self:FindVariable("SpecialName")
	self.fight_power = self:FindVariable("FightPower")
	self.add_attr_per = self:FindVariable("AddAttrPer")
	self.free_time = self:FindVariable("FreeTime")
	self.cost_value = self:FindVariable("CostValue")
    self.show_cancel_btn = self:FindVariable("ShowCancelHuanHua")
    self.show_huan_hua_btn = self:FindVariable("ShowHuanHuaBtn")
    self.show_buy_btn = self:FindVariable("ShowBuyBtn")
    self.show_limit_text = self:FindVariable("ShowLimitText")
    self.show_fetch_flag = self:FindVariable("ShowFetchFlag")
    self.show_active_btn = self:FindVariable("ShowActiveBtn")
    self.show_red_point = self:FindVariable("ShowRedPoint")
    self.level = self:FindVariable("Level")

	self:ListenEvent("OnClickBuy",BindTool.Bind(self.OnClickBuy,self))
	self:ListenEvent("Close",BindTool.Bind(self.ClickClose, self))
	self:ListenEvent("OnClickActive",BindTool.Bind(self.OnClickActive, self))
	self:ListenEvent("OnClickHuanHua",BindTool.Bind(self.OnClickHuanHua, self))
	self:ListenEvent("OnClickCancelIma", BindTool.Bind(self.OnClickCancleHuanHua, self))
	self:ListenEvent("OnCLickFetch", BindTool.Bind(self.OnCLickFetch))
end

function GoddessSpecialTipView:ReleaseCallBack()
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
	self.add_attr_per = nil
	self.free_time = nil
	self.display = nil
	self.cost_value = nil
    self.show_cancel_btn = nil
    self.show_huan_hua_btn = nil
    self.show_buy_btn = nil
    self.show_limit_text = nil
    self.show_fetch_flag = nil
    self.show_active_btn = nil
    self.show_red_point = nil
    self.level = nil
    self:RemoveCountDown()

end


function GoddessSpecialTipView:OpenCallBack()
	self:Flush()
end


function GoddessSpecialTipView:CloseCallBack()
	-- body
end

function GoddessSpecialTipView:ClickClose()
	self:Close()
end

function GoddessSpecialTipView:InitModel()
	local special_xiannv_cfg = GoddessData.Instance:GetSpecialGoddessCfg()
	if special_xiannv_cfg == nil then
		return 
	end
	local resid = special_xiannv_cfg.resid
	--resid = GoddessData.Instance:GetXianNvHuanHuaCfg(GoddessData.Instance:GetHuanHuaId()).resid
	self.model:SetMainAsset(ResPath.GetGoddessModel(resid))
end

function GoddessSpecialTipView:InitDataDisplay()
	local special_xiannv_cfg = GoddessData.Instance:GetSpecialGoddessCfg()
	if special_xiannv_cfg == nil then
		return 
	end
	--战力显示
	local maxhp = special_xiannv_cfg.maxhp or 0
	local gongji  = special_xiannv_cfg.gongji or 0
	local fangyu = special_xiannv_cfg.fangyu or 0
    self.hp_value:SetValue(maxhp)
	self.attack_value:SetValue(gongji)
	self.fangyu_value:SetValue(fangyu)

	local all_xiannv_power = 0
	for i=1,GameEnum.MAX_XIANNV_ID + 1 do
		local xiannv_id = GoddessData.Instance:GetShowXnIdList()[i] or 0
		local xiannv_item = GoddessData.Instance:GetXianNvItem(xiannv_id) or 0
		if xiannv_item.xn_zizhi > 0 then
			local add_power = GoddessData.Instance:GetChuZhanCapability(xiannv_id) or 0
			all_xiannv_power = all_xiannv_power + add_power
		end
	end
	local base_fight_power = GoddessData.Instance:GetSpecialBaseCapability() or 0
	self.fight_power:SetValue(base_fight_power + all_xiannv_power)
	--特殊效果
	local other_cfg = GoddessData.Instance:GetXianNvOtherCfg()
	if next(other_cfg) == nil then
		return 
	end
	self.add_attr_per:SetValue(other_cfg.attr_percent / 100)
	self.cost_value:SetValue(other_cfg.activate_card_cost)

	local str_name = special_xiannv_cfg.name or ""
	self.sepcial_name:SetValue(str_name)
	local data = {item_id = special_xiannv_cfg.active_item}
    self.item:SetData(data)

    --免费时间
    local free_remind_time = GoddessData.Instance:GetSpecialGoddessFreeTime()
    if free_remind_time <= 0 then
        self.show_limit_text:SetValue(false) 
    else
        self:RemoveCountDown()
        self.count_down = CountDown.Instance:AddCountDown(free_remind_time, 1, BindTool.Bind(self.FlushCountDown, self))
    end
end

--按钮的显示
function GoddessSpecialTipView:OnFlushButtonState()
	local other_cfg = GoddessData.Instance:GetXianNvOtherCfg()
	if next(other_cfg) == nil then
		return 
	end
	local item_id = GoddessData.Instance:GetSpecialGoddessItemId()
	local limit_free_time = GoddessData.Instance:GetSpecialGoddessFreeTime()
	--背包是否有激活卡
	local has_card_in_bag = ItemData.Instance:GetItemIndex(item_id)
	local active_flag = GoddessData.Instance:GetSpecialGoddessActiveFlag()  --是否激活
	local can_fetch = GoddessData.Instance:GetSpecialGoddessFetchFlag()     --能否领取
	local has_fetch = GoddessData.Instance:HasGetSpecialGoddess()           --是否领取
	local is_new_player = GoddessData.Instance:IsNewGoddessSystemPlayer()   --是否是新玩家
	local level = GoddessData.Instance:GetSpecialGoddessLevel()
	if level == 0 then
		level = 1
	end
	self.level:SetValue(level)
    --购买按钮 不能领取，背包里没有
    self.show_buy_btn:SetValue(active_flag == 0 and has_card_in_bag == -1 and can_fetch == 0 and has_fetch == 0)
    --领取按钮 
    self.show_fetch_flag:SetValue(can_fetch == 1 and active_flag == 0 and has_card_in_bag == -1)
    --激活按钮 
    self.show_active_btn:SetValue((has_fetch == 1 or has_card_in_bag ~= -1) and active_flag == 0)

    self.show_red_point:SetValue(has_card_in_bag ~= -1)
    --限时文字
    if is_new_player == 1 and limit_free_time > 0 and can_fetch == 0 and active_flag == 0 and has_fetch == 0 and has_card_in_bag == -1 then
		self.show_limit_text:SetValue(true)
	else
		self.show_limit_text:SetValue(false)
	end
	--幻化
	local huanhua_id = GoddessData.Instance:GetHuanHuaId() or -1
	local special_xiannv_id = other_cfg.special_xiannv_id
	self.show_huan_hua_btn:SetValue(active_flag == 1 and huanhua_id ~= special_xiannv_id)
	self.show_cancel_btn:SetValue(active_flag == 1 and huanhua_id == special_xiannv_id)
end

function GoddessSpecialTipView:OnFlush()
	self:InitDataDisplay()
	self:InitModel()
	self:OnFlushButtonState()
end


function GoddessSpecialTipView:OnClickBuy()
	local special_xiannv_cfg = GoddessData.Instance:GetSpecialGoddessCfg()
	if special_xiannv_cfg == nil then
		return 
	end
	local special_xiannv_id = special_xiannv_cfg.id

	local other_cfg = GoddessData.Instance:GetXianNvOtherCfg()
	if next(other_cfg) == nil then
		return 
	end
	local cost_gold = other_cfg.activate_card_cost or 0
 
    local ok_fun = function ()
        local vo = GameVoManager.Instance:GetMainRoleVo()
        if vo.gold < cost_gold then
            TipsCtrl.Instance:ShowLackDiamondView()
            return
        else
           GoddessCtrl.Instance:SentSpecialXiannvOperaReq(SPECIAL_GODDESS_OPER_TYPE.OPERA_TYPE_BUY_ACTIVATE_CARD,special_xiannv_id,0)
        end
    end
    local tips_text = string.format(Language.Goddess.BuySpecialTips, cost_gold)
    TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, tips_text)
    return
end

function GoddessSpecialTipView:OnClickActive()
	local item_id = GoddessData.Instance:GetSpecialGoddessItemId()
	local has_card_in_bag = ItemData.Instance:GetItemIndex(item_id)
    if has_card_in_bag == -1 then
        local special_xiannv_cfg = GoddessData.Instance:GetSpecialGoddessCfg()
        local name = special_xiannv_cfg.name or ""
        TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Common.ActivedErrorTips, name))
        return
    end

	local active_num = #(GoddessData.Instance:GetXiannvActiveList())
	if active_num <= 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Goddess.ActiveCondition)
		return
	end

	local special_xiannv_cfg = GoddessData.Instance:GetSpecialGoddessCfg()
	if special_xiannv_cfg == nil then
		return 
	end
	local speical_xiannv_id = special_xiannv_cfg.id
	GoddessCtrl.Instance:SendXiannvActiveHuanhua(speical_xiannv_id,ItemData.Instance:GetItemIndex(item_id))
end

function GoddessSpecialTipView:OnClickHuanHua()
	local special_xiannv_cfg = GoddessData.Instance:GetSpecialGoddessCfg()
	if special_xiannv_cfg == nil then
		return 
	end
	local speical_xiannv_id = special_xiannv_cfg.id
	GoddessCtrl.Instance:SentXiannvImageReq(speical_xiannv_id)
end

function GoddessSpecialTipView:OnClickCancleHuanHua()
	GoddessCtrl.Instance:SentXiannvImageReq(-1)
end

function GoddessSpecialTipView:OnCLickFetch( )
	local special_xiannv_cfg = GoddessData.Instance:GetSpecialGoddessCfg()
	if special_xiannv_cfg == nil then
		return 
	end
	local special_xiannv_id = special_xiannv_cfg.id
	GoddessCtrl.Instance:SentSpecialXiannvOperaReq(SPECIAL_GODDESS_OPER_TYPE.OPERA_TYPE_GET_ACTIVATE_CARD,special_xiannv_id,0)
end

--设置时间
function GoddessSpecialTipView:SetTime(time)
    local show_time_str = ""
    if time > 3600 * 24 then
        show_time_str = TimeUtil.FormatSecond(time, 7)
    elseif time > 3600 then
        show_time_str = TimeUtil.FormatSecond(time, 1)
    else
        show_time_str = TimeUtil.FormatSecond(time, 4)
    end
    self.free_time:SetValue(show_time_str)
end

function GoddessSpecialTipView:FlushCountDown(elapse_time, total_time)
    local time_interval = total_time - elapse_time
    if time_interval > 0 then
        self:SetTime(time_interval)
    else
        self.show_limit_text:SetValue(false)
    end
end

function GoddessSpecialTipView:RemoveCountDown()
    if CountDown.Instance:HasCountDown(self.count_down) then
        CountDown.Instance:RemoveCountDown(self.count_down)
        self.count_down = nil
    end
end