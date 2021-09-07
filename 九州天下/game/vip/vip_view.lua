require("game/vip/vip_content_view")
require("game/vip/recharge_content_view")
require("game/vip/vip_power_view")
require("game/vip/level_investment_view")
require("game/vip/month_investment_view")
VipView = VipView or BaseClass(BaseView)

function VipView:__init()
	VipView.Instance = self
	self.ui_config = {"uis/views/vipview","VipView"}
	self.full_screen = false
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].Openchognzhi)
	end
	self.play_audio = true
	self:SetMaskBg()
	self.def_index = 1
	self.cur_select = 1
end

function VipView:__delete()
	VipView.Instance = nil

end

function VipView:LoadCallBack()
	self:ListenEvent("close_view",
	 	BindTool.Bind(self.OnCloseBtnClick, self))
	self:ListenEvent("to_recharge_click",
	 	BindTool.Bind(self.RechargeClick,self))
	-- self:ListenEvent("vip_power_click",
	--  	BindTool.Bind(self.VipPowerClick,self))
	self:ListenEvent("OnClickLastButton",
		BindTool.Bind(self.OnClickLastButton, self))
	self:ListenEvent("OnClickNextButton",
		BindTool.Bind(self.OnClickNextButton, self))


	self.vip_content_obj = self:FindObj("vip_content_view")
	self.toggle_list = {}
	for i = 1, 4 do
		self.toggle_list[i] = self:FindObj("Toggle" .. i)
		self.toggle_list[i].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, i))
	end
	self.vip_content_view = VipContentView.New(self.vip_content_obj)
	self.level_investment_view = LevelInvestmentView.New(self:FindObj("LevelInvestment"))
	self.month_investment_view = MonthCardInvestmentView.New(self:FindObj("MonthCardInvestment"))
	self.show_power_click = self:FindVariable("show_power_click")
	self.show_recharge_click = self:FindVariable("show_recharge_click")
	self.next_vip_level_text = self:FindVariable("next_vip_level_text")
	self.show_top_toggle2 = self:FindVariable("show_top_toggle2")
	-- self.toggle1_text = self:FindVariable("Toggle1Text")
	self.btn_left_show = self:FindVariable("Btn_Left_Show")
	self.btn_right_show = self:FindVariable("Btn_Right_Show")

	self.remain_exp_text = self:FindVariable("remain_exp_text")
	self.vip_exp_slider = self:FindVariable("vip_exp_slider")
	self.show_remain_exp = self:FindVariable("show_remain_exp")
	self.show_text = self:FindVariable("show_text")
	self.show_final_desc = self:FindVariable("show_final_desc")
	self.title_text = self:FindVariable("title_text")
	self.total_exp = self:FindVariable("total_exp")
	self.current_exp = self:FindVariable("current_exp")
	-- self.current_vip_level_text = self:FindVariable("current_vip_level_text")
	self.current_vip_level_icon = self:FindVariable("current_vip_level_icon")
	self.show_remain_level_invest = self:FindVariable("ShopLevelInvestRed")
	self.show_remain_month_invest = self:FindVariable("ShopMonthInvestRed")
	self.show_chongzhi_investred = self:FindVariable("ShopChongZhiInvestRed")

	self.vip_power_view = VipPowerView.New(self:FindObj("vip_power_view"))
	self.is_first_open = true

	local vip_level = VipData.Instance:GetCurRewardFlagIndex()
	self.cur_select = vip_level
end

function VipView:OnCloseBtnClick()
	self:Close()
end

function VipView:OpenCallBack()
	self:ShowOrHideTab()
	self.event_quest = GlobalEventSystem:Bind(
		OpenFunEventType.OPEN_TRIGGER,
		BindTool.Bind(self.ShowOrHideTab, self))
end

function VipView:ShowOrHideTab()
	if not self:IsOpen() then return end
	local show_list = {}
	local open_fun_data = OpenFunData.Instance
	show_list[3] = open_fun_data:CheckIsHide("investview")
	show_list[4] = open_fun_data:CheckIsHide("investview")
	for k,v in pairs(show_list) do
		self.toggle_list[k]:SetActive(v)
	end
end

function VipView:ReleaseCallBack()
	if self.vip_content_view then
		self.vip_content_view:DeleteMe()
		self.vip_content_view = nil
	end

	if self.vip_power_view then
		self.vip_power_view:DeleteMe()
		self.vip_power_view = nil
	end


	if self.level_investment_view then
		self.level_investment_view:DeleteMe()
		self.level_investment_view = nil
	end

	if self.month_investment_view then
		self.month_investment_view:DeleteMe()
		self.month_investment_view = nil
	end

	-- 清理变量和对象
	self.vip_content_obj = nil
	self.rechange_content_obj = nil
	self.toggle_list = {}
	self.show_power_click = nil
	self.show_recharge_click = nil
	self.next_vip_level_text = nil
	self.show_top_toggle2 = nil
	self.remain_exp_text = nil
	self.vip_exp_slider = nil
	self.show_remain_exp = nil
	self.show_text = nil
	self.show_final_desc = nil
	self.title_text = nil
	self.total_exp = nil
	self.current_exp = nil
	-- self.current_vip_level_text = nil
	self.current_vip_level_icon = nil
	self.show_remain_level_invest = nil
	self.show_remain_month_invest = nil
	self.show_chongzhi_investred = nil
	self.btn_left_show = nil
	self.btn_right_show = nil

end

function VipView:OnToggleChange(index, isOn)
	if self.toggle_list[index] and isOn then
		self:ChangeToIndex(index)
	end
end

-- 左边按钮
function VipView:OnClickLastButton()
	if self.cur_select < 1 then
		self.cur_select = 1		
	end
	
	self.btn_right_show:SetValue(self.cur_select <= VipData.Instance:GetMaxVipLevel())
	self.btn_left_show:SetValue(self.cur_select > 2)
	--self.btn_left_show:SetValue(false)
	self.cur_select = self.cur_select - 1
	VipContentView.Instance:SetCurIndex(self.cur_select)
	VipContentView.Instance:SetCurrentVipId(self.cur_select)
	VipContentView.Instance:SetRewardText()
	VipContentView.Instance:FlushRewardState()
	-- VipContentView.Instance:FlushSelectEffect(self)
	-- self.root_node.toggle.isOn = true
end

-- 右边按钮
function VipView:OnClickNextButton()
	if self.cur_select < 1 then
		self.cur_select = 1
	end
	if self.cur_select > VipData.Instance:GetMaxVipLevel() then
		self.cur_select = VipData.Instance:GetMaxVipLevel()
	end
	self.cur_select = self.cur_select + 1
	if self.cur_select > VipData.Instance:GetMaxVipLevel() then
		self.cur_select = VipData.Instance:GetMaxVipLevel()
		-- self.btn_right_show:SetValue(false)
	end
	self.btn_right_show:SetValue(self.cur_select < VipData.Instance:GetMaxVipLevel())
	self.btn_left_show:SetValue(self.cur_select >= 2)
	 --self.btn_right_show:SetValue(false)
	VipContentView.Instance:SetCurIndex(self.cur_select)
	VipContentView.Instance:SetCurrentVipId(self.cur_select)
	VipContentView.Instance:SetRewardText()
	VipContentView.Instance:FlushRewardState()
	-- VipContentView.Instance:FlushSelectEffect(self)
	-- self.root_node.toggle.isOn = true
end

function VipView:ShowIndexCallBack(index)
	if index > 1 then
		if not self.toggle_list[index].isOn then
			-- self.show_top_toggle:SetValue(true)
			self.show_top_toggle2:SetValue(true)
			self.toggle_list[index].toggle.isOn = true
		end
		if index <= 2 then
			VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.VIP)
			-- self.toggle1_text:SetValue("福利")
			-- self.show_top_toggle:SetValue(true)
			self.show_top_toggle2:SetValue(false)
			if index == 1 then
				self:CalTimeToFlush()
			end
		else
			VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
			self.title_text:SetValue(Language.Common.Recharge)
			-- self.show_top_toggle:SetValue(false)
			self.show_top_toggle2:SetValue(true)
		end
	else
		self.toggle_list[1].toggle.isOn = true
		self:CalTimeToFlush()
	end
	self:Flush()
	if index == 3 then
		self.level_investment_view:OpenCallBack()
	end
end

function VipView:CloseCallBack()
	self.is_first_open = true
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.NONE)
	self.vip_content_view:SetActive(true)
	if self.event_quest then
		GlobalEventSystem:UnBind(self.event_quest)
	end
end

function VipView:RechargeClick()
	self:Close()
	ViewManager.Instance:Open(ViewName.RechargeView)
end

function VipView:VipPowerClick()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.VIP)
	self.vip_content_view:OpenCallBack()
	self.show_recharge_click:SetValue(true)
	self.show_power_click:SetValue(false)
	self.vip_content_view:SetActive(true)
	self.title_text:SetValue("V")
	self.btn_left_show:SetValue(true)
	self.btn_right_show:SetValue(true)

	if self.is_first_open then
		local vip_level = VipData.Instance:GetVipInfo().vip_level
		self.vip_content_view:SetCurrentVipId(vip_level)
		-- self.vip_content_view:JumpToCurrentVip()
		self.vip_content_view:FlushRewardState()
	end
	self.is_first_open = false
end

function VipView:CalTimeToFlush()
	local open_type = VipData.Instance:GetOpenType()
	if open_type == OPEN_VIP_RECHARGE_TYPE.VIP then
		self:VipPowerClick()
		-- local vip_level = VipData.Instance:GetVipInfo().vip_level
		local vip_level = self.cur_select
		self.btn_right_show:SetValue(vip_level < 30)
		self.btn_left_show:SetValue(vip_level >= 2)
		for i=1,vip_level do
			if VipData.Instance:GetIsVipRewardByVipLevel(i) then
				vip_level = i
				self.cur_select = i
				break
			end
		end
		self.vip_content_view:SetCurrentVipId(vip_level)
		-- self.vip_content_view:JumpToCurrentVip()
		self.vip_content_view:FlushRewardState()
	elseif open_type == OPEN_VIP_RECHARGE_TYPE.RECHANRGE then
		self:RechargeClick()
	end
end

function VipView:OpenTeToggle()
	self.toggle_list[2].toggle.isOn = true
end


function VipView:OnFlush(param_list)
	local index = self:GetShowIndex()	
	if index == 1 then				
		local current_vip_id = VipData.Instance:GetVipInfo().vip_level
		-- self.current_vip_level_text:SetValue(current_vip_id)
		self.current_vip_level_icon:SetAsset(ResPath.GetVipLevelIcon(current_vip_id))
		if current_vip_id < 30 then
			self.show_remain_exp:SetValue(true)
			self.show_text:SetValue(true)
			self.show_final_desc:SetValue(false)
		else
			self.show_remain_exp:SetValue(false)
			self.show_text:SetValue(false)
			self.show_final_desc:SetValue(true)
		end
		local total_exp = VipData.Instance:GetVipExp(current_vip_id)
		local passlevel_consume = VipData.Instance:GetVipExp(current_vip_id - 1)
		local current_exp = VipData.Instance:GetVipInfo().vip_exp + passlevel_consume
		if current_vip_id < 30 then
			self.next_vip_level_text:SetValue(current_vip_id + 1)
			self.remain_exp_text:SetValue(total_exp - current_exp)
		end
		if current_vip_id == 30 then
			self.vip_exp_slider:SetValue(1)
		else
			self.vip_exp_slider:SetValue(current_exp/total_exp)
			self.total_exp:SetValue(tostring(total_exp))
			self.current_exp:SetValue(tostring(current_exp))
		end
		-- self.rechange_content_view:OnFlush()
	elseif index == 3 then
		if not InvestData.FIRST_LEVEL_REMIND then
			InvestData.FIRST_LEVEL_REMIND = true
			RemindManager.Instance:Fire(RemindName.Invest)
		end
		self.level_investment_view:OnFlush()
	elseif index == 4 then
		if not InvestData.FIRST_MONTH_REMIND then
			InvestData.FIRST_MONTH_REMIND = true
			RemindManager.Instance:Fire(RemindName.Invest)
		end
		self.month_investment_view:OnFlush()
	end
	self.show_remain_level_invest:SetValue(InvestData.Instance:GetNormalInvestRemind())
	self.show_remain_month_invest:SetValue(InvestData.Instance:GetMonthInvestRemind())
	self.show_chongzhi_investred:SetValue(RechargeData.Instance:DayRechangeCanReward())
end

