require("game/kaifu_charge/kaifu_yueka_view")
require("game/kaifu_charge/kaifu_touzi_view")
require("game/kaifu_charge/kaifu_touzi_login_view")
require("game/kaifu_charge/kaifu_bipin_view")
require("game/kaifu_charge/kaifu_chongzhi_view")
require("game/kaifu_charge/kaifu_discount_view")
require("game/kaifu_charge/kaifu_rising_star_view")
require("game/kaifu_charge/kaifu_activity_panel_congzhi_rank")
require("game/kaifu_charge/kaifu_activity_panel_xiaofei_rank")
require("game/kaifu_charge/kaifu_activity_panel_group_buy")
require("game/kaifu_charge/kaifu_activity_panel_personal_buy")
require("game/kaifu_charge/kaifu_activity_7day_redpacket")
require("game/kaifu_charge/kaifu_red_equip_view")
require("game/kaifu_charge/kaifu_activity_panel_danbichongzhi")
require("game/kaifu_charge/kaifu_activity_panel_leiji_reward")
require("game/kaifu_charge/pink_equip_view")
require("game/kaifu_charge/kaifu_activity_panel_total_chognzhi")
require("game/kaifu_charge/kaifu_activity_panel_total_new_chognzhi")
require("game/kaifu_charge/kaifu_activity_panel_fenqi")
require("game/kaifu_charge/kaifu_activity_panel_thanksfeedback_view")
require("game/kaifu_charge/kaifu_meiri_zhanbei_view")
require("game/kaifu_charge/daily_charge_content")
require("game/kaifu_charge/kaifu_activity_panel_surper_charge_feedback_view")
KaiFuChargeView = KaiFuChargeView or BaseClass(BaseView)
-- index 对应活动号 读开服活动配置
local INDEX_TO_ACTIVITY_TYPE = {
	[TabIndex.kaifu_day_chongzhi_rank] = 2089,
	[TabIndex.kaifu_day_xiaofei_rank] = 2090,
	[TabIndex.kaifu_group_buy] = 2136,
	[TabIndex.kaifu_personal_buy] = 2056,
	[TabIndex.kaifu_day_red_packets] = 2159,
	[TabIndex.kaifu_leiji_reward] = 2081,
	[TabIndex.kaifu_danbi_chongzhi] = 2082,
	[TabIndex.kaifu_total_reward] = 2051,
	[TabIndex.kaifu_rush_chu] = 2174,
	[TabIndex.kaifu_rush_gao] = 2175,
	[TabIndex.kaifu_twe_lve] = 2160,
	[TabIndex.kaifu_pink_equip] = 2189,
	[TabIndex.kaifu_total_chongzhi] = 2091,
	[TabIndex.kaifu_new_total_chongzhi] = 2187,
	[TabIndex.kaifu_thanksfeedback] = 2195,
	[TabIndex.kaifu_meiri_zhanbei] = 2196,
	[TabIndex.kaifu_daily_charge] = 2104,
	[TabIndex.kaifu_super_charge] = 2204,
}

-- index 对应开启多少天(天数从开服开始计算)
local SYSTEM_INDEX = {
	[TabIndex.kaifu_yueka] = 9999,
	[TabIndex.kaifu_red_equip] = 7,
	[TabIndex.kaifu_touzi] = 9999,
	[TabIndex.kaifu_touzi_login] = 9999,
	[TabIndex.kaifu_rising_star] = 9999,
	[TabIndex.kaifu_discount] = 7,
}

--[[
	特殊开启规则 特殊处理
	TabIndex.kaifu_fenqizhizhui
]]

local  ACTIVITY_TYPE_LIST = {
	2174,
	2175,
	2051,
	2171,
	2091,
	2187,
}
function KaiFuChargeView:__init()
	self.ui_config = {"uis/views/kaifuchargeview","KaiFuChargeView"}
	self:SetMaskBg()
	self.def_index = TabIndex.kaifu_yueka
end


function KaiFuChargeView:__delete()

end

function KaiFuChargeView:LoadCallBack()
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self:ListenEvent("CloseView", BindTool.Bind(self.OnCloseClick, self))
	self.show_left_role = self:FindVariable("ShowLeftRole")
	self.show_rising_toggle = self:FindVariable("ShowRisingToggle")
	self.top_title = self:FindVariable("Title")
	self.remind_list = {
		[RemindName.KaiFuCharge_RisingStar] = self:FindVariable("KaiFuRisingRed"),
		[RemindName.KaiFuYueKaTab] = self:FindVariable("ShowYueKaRedPoint"),
		[RemindName.KaiFuLoginTouziTab] = self:FindVariable("ShowLoginTouziRedPoint"),
		[RemindName.KaiFuLevelTouziTab] = self:FindVariable("ShowLevelTouziRedPoint"),
		[RemindName.KaiFuChongZhiTab] = self:FindVariable("ShowSdayChargeRedPoint"),
		[RemindName.KaiFuBiPinTab] = self:FindVariable("ShowBipinRedPoint"),
		[RemindName.KaiFuLeiJiReward] = self:FindVariable("ShowLeiJiReward"),
		[RemindName.KaiFuTotalReward] = self:FindVariable("ShowTotalReward"),
		[RemindName.PinkEquip] = self:FindVariable("ShowPinkRedPoint"),
		[RemindName.LianChongTeHuiChu] = self:FindVariable("LianChongTeHuiChuRed"),
		[RemindName.LianChongTeHuiGao] = self:FindVariable("LianChongTeHuiGaoRed"),
		[RemindName.KaiFuRedEquip] = self:FindVariable("ShowRedEquipPoint"),
		[RemindName.KaiFuNewTotalReward] = self:FindVariable("KaiFuNewTotalReward"),
		[RemindName.FenQiZhiZhui] = self:FindVariable("FenQiZhiZhuiRedpoint"),
		[RemindName.KaiFuLeiJiChongZhi] = self:FindVariable("KaiFuLeiJiChongZhi"),
		[RemindName.RewardSeven] = self:FindVariable("KaiFuRewardSeven"),
		[RemindName.RemindGroupBuyRedpoint] = self:FindVariable("FirstChargeGroupBuyRedpoint"),
		[RemindName.XuFuCiLi] = self:FindVariable("ShowStartGiftRedPoint"),
		[RemindName.MeiRiZhanBei] = self:FindVariable("ShowLiBaoRedPoint"),
		[RemindName.SuperChargeFeedback] = self:FindVariable("ShowSuperChargeRemind"),
		[RemindName.ThanksFeedBackRedPoint] = self:FindVariable("ThanksFeedBackRedPoint"),
	}


	for k, _ in pairs(self.remind_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	for i = 1, 27 do
		self["toggle_"..i] = self:FindObj("toggle_".. i)
	end
	self.TabBar = self:FindObj("TabBar")
	self.toggle_1.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_yueka))
	self.toggle_2.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_touzi))
	self.toggle_3.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_bipin))
	self.toggle_4.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_seven))
	self.toggle_5.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_discount))
	self.toggle_6.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_rising_star))
	self.toggle_7.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_touzi_login))
	self.toggle_8.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_day_chongzhi_rank))
	self.toggle_9.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_day_xiaofei_rank))
	self.toggle_10.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_group_buy))
	self.toggle_11.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_personal_buy))
	self.toggle_12.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_day_red_packets))
	self.toggle_13.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_red_equip))
	self.toggle_14.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_danbi_chongzhi))
	self.toggle_15.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_leiji_reward))
	self.toggle_16.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_total_reward))
	self.toggle_17.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_rush_gao))
	self.toggle_18.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_rush_chu))
	self.toggle_19.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_twe_lve))
	self.toggle_20.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_pink_equip))
	self.toggle_21.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_total_chongzhi))
	self.toggle_22.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_new_total_chongzhi))
	self.toggle_23.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_fenqizhizhui))
	self.toggle_24.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_meiri_zhanbei))
	self.toggle_25.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_thanksfeedback))
	self.toggle_26.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_daily_charge))
	self.toggle_27.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.kaifu_super_charge))


	self.toggle_list = {
		[TabIndex.kaifu_yueka] = self.toggle_1,
		[TabIndex.kaifu_touzi] = self.toggle_2,
		[TabIndex.kaifu_bipin] = self.toggle_3,
		[TabIndex.kaifu_seven] = self.toggle_4,
		[TabIndex.kaifu_discount] = self.toggle_5,
		[TabIndex.kaifu_rising_star] = self.toggle_6,
		[TabIndex.kaifu_touzi_login] = self.toggle_7,
		[TabIndex.kaifu_day_chongzhi_rank] = self.toggle_8,
		[TabIndex.kaifu_day_xiaofei_rank] = self.toggle_9,
		[TabIndex.kaifu_group_buy] = self.toggle_10,
		[TabIndex.kaifu_personal_buy] = self.toggle_11,
		[TabIndex.kaifu_day_red_packets] = self.toggle_12,
		[TabIndex.kaifu_red_equip] = self.toggle_13,
		[TabIndex.kaifu_danbi_chongzhi] = self.toggle_14,
		[TabIndex.kaifu_leiji_reward] = self.toggle_15,
		[TabIndex.kaifu_total_reward] = self.toggle_16,
		[TabIndex.kaifu_rush_gao] = self.toggle_17,
		[TabIndex.kaifu_rush_chu] = self.toggle_18,
		[TabIndex.kaifu_twe_lve] = self.toggle_19,
		[TabIndex.kaifu_pink_equip] = self.toggle_20,
		[TabIndex.kaifu_total_chongzhi] = self.toggle_21,
		[TabIndex.kaifu_new_total_chongzhi] = self.toggle_22,
		[TabIndex.kaifu_fenqizhizhui] = self.toggle_23,
		[TabIndex.kaifu_meiri_zhanbei] = self.toggle_24,
		[TabIndex.kaifu_thanksfeedback] = self.toggle_25,
		[TabIndex.kaifu_daily_charge] = self.toggle_26,
		[TabIndex.kaifu_super_charge] = self.toggle_27,

	}

	-- 子面板
	self.yueka_view = KaiFuYueKaView.New()
	local yueka_content = self:FindObj("YueKaContent")
	yueka_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.kaifu_yueka
		self.yueka_view:SetInstance(obj)
	end)

	self.activity_panel_twelve = KaifuActivityPanelTwelve.New()
	local yueka_content = self:FindObj("KaifuActivityPanelTwelve")
	yueka_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.activity_panel_twelve:SetInstance(obj)
	end)

	self.rush_tall_baserender = LianXuChongZhiGao.New()
	local yueka_content = self:FindObj("RushtallBaseRender")
	yueka_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.rush_tall_baserender:SetInstance(obj)
	end)

	self.rush_chu_baserender = LianXuChongZhiChu.New()
	local yueka_content = self:FindObj("RushChuBaseRender")
	yueka_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.rush_chu_baserender:SetInstance(obj)
	end)

	self.totalconsume_view = OpenActTotalConsume.New()
	local total_content = self:FindObj("TotalComsume")
	total_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.kaifu_total_reward
		self.totalconsume_view:SetInstance(obj)
	end)

	self.total_chongzhi_view = OpenActTotalChongZhi.New()
	local total_chongzhi_content = self:FindObj("TotalChongZhi")
	total_chongzhi_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.kaifu_total_chongzhi
		self.total_chongzhi_view:SetInstance(obj)
	end)

	self.OpenNewTotalChongZhi = OpenNewTotalChongZhi.New()
	local new_total_chongzhi_content = self:FindObj("NewTotalChongZhi")
	new_total_chongzhi_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		--self.show_index = TabIndex.kaifu_total_chongzhi
		self.OpenNewTotalChongZhi:SetInstance(obj)
	end)

	self.touzi_view = KaiFuTouZiView.New()
	local touzi_content = self:FindObj("TouZiContent")
	touzi_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.kaifu_touzi
		self.touzi_view:SetInstance(obj)
	end)

	self.touzi_login_view = KaiFuTouZiLoginView.New()
	local touzi_login_content = self:FindObj("TouZiLoginContent")
	touzi_login_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.kaifu_touzi
		self.touzi_login_view:SetInstance(obj)
	end)

	-- self.bipin_view = KaiFuBiPinView.New()
	-- local bipin_content = self:FindObj("BiPinContent")
	-- bipin_content.uiprefab_loader:Wait(function(obj)
	-- 	obj = U3DObject(obj)
	-- 	self.show_index = TabIndex.kaifu_bipin
	-- 	self.bipin_view:SetInstance(obj)
	-- end)

	-- self.chongzhi_view = KaiFuChongZhiView.New()
	-- local chongzhi_content = self:FindObj("ChongZhiContent")
	-- chongzhi_content.uiprefab_loader:Wait(function(obj)
	-- 	obj = U3DObject(obj)
	-- 	self.show_index = TabIndex.kaifu_seven
	-- 	self.chongzhi_view:SetInstance(obj)
	-- end)

	self.discount_view = KaiFuDiscountView.New()
	local discount_content = self:FindObj("DiscountContent")
	discount_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.kaifu_discount
		self.discount_view:SetInstance(obj)
	end)

	self.rising_star_view = KaiFuRisingStarView.New()
	local rising_star_content = self:FindObj("RisingStarContent")
	rising_star_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.kaifu_rising_star
		self.rising_star_view:SetInstance(obj)
	end)

	self.chongzhi_rank_view = CongZhiRank.New()
	local chongzhi_rank_content = self:FindObj("DayChongZhiRank")
	chongzhi_rank_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.kaifu_day_chongzhi_rank
		self.chongzhi_rank_view:SetInstance(obj)
	end)

	self.xiaofei_rank_view = XiaoFeiRank.New()
	local xiaofei_rank_content = self:FindObj("DayXiaoFeiRank")
	xiaofei_rank_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.kaifu_day_xiaofei_rank
		self.xiaofei_rank_view:SetInstance(obj)
	end)

	self.group_buy_view = KaiFuGroupBuy.New()
	local group_buy_content = self:FindObj("FirstChargeGroupBuy")
	group_buy_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.kaifu_group_buy
		self.group_buy_view:SetInstance(obj)
	end)

	self.personal_buy_view = KaifuActivityPanelPersonBuy.New()
	local personal_buy_content = self:FindObj("PersonalBuyContent")
	personal_buy_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.kaifu_personal_buy
		self.personal_buy_view:SetInstance(obj)
	end)

	self.seven_day_view = SevenDayRedpacket.New()
	local seven_day_content = self:FindObj("DayRedPackets")
	seven_day_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.kaifu_day_red_packets
		self.seven_day_view:SetInstance(obj)
	end)


	self.red_equip_view = RedEquipActivity.New()
	local red_equip_content = self:FindObj("RedEquipActivity")
	red_equip_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.kaifu_red_equip
		self.red_equip_view:SetInstance(obj)
	end)


	self.danbi_chongzhi_view = KaifuActivityPanelDanBiChongZhi.New()
	local danbi_chongzhi_content = self:FindObj("DanBiChongZhi")
	danbi_chongzhi_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.kaifu_danbi_chongzhi
		self.danbi_chongzhi_view:SetInstance(obj)
	end)

	self.leiji_reward_view = LeiJiRewardView.New()
	local leiji_reward_content = self:FindObj("LeiJiReward")
	leiji_reward_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.kaifu_leiji_reward
		self.leiji_reward_view:SetInstance(obj)
	end)

	self.pink_equip_view = PinkEquipView.New()
	local pink_equip_content = self:FindObj("PinkEquip")
	pink_equip_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.kaifu_pink_equip
		self.pink_equip_view:SetInstance(obj)
	end)

	self.fenqizhizhui_view = KaiFuFenQiView.New()
	local pink_equip_content = self:FindObj("FenQiZhiZhuiContent")
	pink_equip_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.kaifu_fenqizhizhui
		self.fenqizhizhui_view:SetInstance(obj)
	end)

	self.daily_charge_content = DailyChargeContent.New()
	self:FindObj("DailyChargeContent").uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.kaifu_daily_charge
		self.daily_charge_content:SetInstance(obj)
	end)

	self.super_charge_feedback = SuperChargeFeedbackView.New()
	local super_charge_countent = self:FindObj("SuperChargeFeedback")
	super_charge_countent.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.kaifu_super_charge
		self.super_charge_feedback:SetInstance(obj)
	end)

	self.meirizhanbei_view = MeiRiZhanBeiView.New()
	local meiri_zhanbei_content = self:FindObj("MeiRiZhanBeiContent")
	meiri_zhanbei_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.kaifu_meiri_zhanbei
		self.meirizhanbei_view:SetInstance(obj)
	end)

	self.thanksfeedback_view = KaifuActivityPanelThanksFeedBack.New()
	local thanksfeedback_view = self:FindObj("ThanksFeedBack")
	thanksfeedback_view.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.kaifu_thanksfeedback
		self.thanksfeedback_view:SetInstance(obj)
	end)

	self.show_rising_toggle:SetValue(KaiFuChargeData.Instance:GetShengxingzhuliInfo().is_max_level == 1)

	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local bundle, asset = ResPath.GetKaiFuChargeImage("title")
	if server_day > 7 then
		bundle, asset = ResPath.GetKaiFuChargeImage("title_2")
	end
	self.top_title:SetAsset(bundle, asset)
end

function KaiFuChargeView:ReleaseCallBack()
	if self.yueka_view then
		self.yueka_view:DeleteMe()
		self.yueka_view = nil
	end

	if self.totalconsume_view then
		self.totalconsume_view:DeleteMe()
		self.totalconsume_view = nil
	end

	if self.total_chongzhi_view then
		self.total_chongzhi_view:DeleteMe()
		self.total_chongzhi_view = nil
	end

	if self.OpenNewTotalChongZhi then
		self.OpenNewTotalChongZhi:DeleteMe()
		self.OpenNewTotalChongZhi = nil
	end

	if self.rush_tall_baserender then
		self.rush_tall_baserender:DeleteMe()
		self.rush_tall_baserender = nil
	end

	if self.activity_panel_twelve then
		self.activity_panel_twelve:DeleteMe()
		self.activity_panel_twelve = nil
	end

	if self.rush_chu_baserender then
		self.rush_chu_baserender:DeleteMe()
		self.rush_chu_baserender = nil
	end

	if self.touzi_view then
		self.touzi_view:DeleteMe()
		self.touzi_view = nil
	end
	if self.touzi_login_view then
		self.touzi_login_view:DeleteMe()
		self.touzi_login_view = nil
	end
	if self.bipin_view then
		self.bipin_view:DeleteMe()
		self.bipin_view = nil
	end
	if self.discount_view then
		self.discount_view:DeleteMe()
		self.discount_view = nil
	end
	if self.rising_star_view then
		self.rising_star_view:DeleteMe()
		self.rising_star_view = nil
	end

	if self.chongzhi_view then
		self.chongzhi_view:DeleteMe()
		self.chongzhi_view = nil
	end

	if self.chongzhi_rank_view then
		self.chongzhi_rank_view:DeleteMe()
		self.chongzhi_rank_view = nil
	end

	if self.xiaofei_rank_view then
		self.xiaofei_rank_view:DeleteMe()
		self.xiaofei_rank_view = nil
	end

	if self.group_buy_view then
		self.group_buy_view:DeleteMe()
		self.group_buy_view = nil
	end

	if self.personal_buy_view then
		self.personal_buy_view:DeleteMe()
		self.personal_buy_view = nil
	end

	if self.seven_day_view then
		self.seven_day_view:DeleteMe()
		self.seven_day_view = nil
	end

	if self.red_equip_view then
		self.red_equip_view:DeleteMe()
		self.red_equip_view =nil
	end

	if self.danbi_chongzhi_view then
		self.danbi_chongzhi_view:DeleteMe()
		self.danbi_chongzhi_view =nil
	end

	if self.leiji_reward_view then
		self.leiji_reward_view:DeleteMe()
		self.leiji_reward_view =nil
	end

	if self.pink_equip_view then
		self.pink_equip_view:DeleteMe()
		self.pink_equip_view = nil
	end

	if self.fenqizhizhui_view then
		self.fenqizhizhui_view:DeleteMe()
		self.fenqizhizhui_view = nil
	end

	if self.daily_charge_content then
		self.daily_charge_content:DeleteMe()
		self.daily_charge_content = nil
	end

	if self.super_charge_feedback then
		self.super_charge_feedback:DeleteMe()
		self.super_charge_feedback = nil
	end

	if self.meirizhanbei_view then
		self.meirizhanbei_view:DeleteMe()
		self.meirizhanbei_view = nil
	end

	if self.thanksfeedback_view then
		self.thanksfeedback_view:DeleteMe()
		self.thanksfeedback_view = nil
	end

	self.toggle_list = nil
	for i = 1, 27 do
		self["toggle_" .. i] = nil
	end
	self.TabBar = nil
	self.show_left_role = nil
	self.show_rising_toggle = nil

	if RemindManager.Instance and self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
	self.remind_list = {}
	self.top_title = nil

	if nil ~= self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
	end
end

function KaiFuChargeView:OnCloseClick()
	self:Close()
end

function KaiFuChargeView:OpenCallBack()
	KaiFuChargeCtrl.Instance:SendXufuActivityOpenReq()
	KaiFuChargeData.Instance:SendDayRankInfo()
	local activity = KaiFuChargeData.Instance:GetBiPinActivity()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(activity,RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	KaiFuChargeCtrl.Instance:SendOpenGameActivityInfoReq()
	KaiFuChargeCtrl.Instance:SendShengxingzhuliIReq()
	KaifuActivityCtrl.Instance:SendRAOpenGameGiftShopBuyInfo()

	for i,v in ipairs(ACTIVITY_TYPE_LIST) do
		if ActivityData.Instance:GetActivityIsOpen(v) then
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(v, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
		end
	end

	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	for k,v in pairs(self.toggle_list) do
		if SYSTEM_INDEX[k] then
			local is_touzi = k == TabIndex.kaifu_touzi or k == TabIndex.kaifu_touzi_login
			if is_touzi and server_day <= SYSTEM_INDEX[k] then
				v:SetActive(KaiFuChargeData.Instance:GetKaiFuTouziAllRewardFlag(k))
			else
				v:SetActive(server_day <= SYSTEM_INDEX[k])
			end
		elseif INDEX_TO_ACTIVITY_TYPE[k] then
			if k == TabIndex.kaifu_day_red_packets then
				local is_open = ActivityData.Instance:GetActivityIsOpen(INDEX_TO_ACTIVITY_TYPE[k])
				v:SetActive(is_open or KaiFuChargeData.Instance:IsShowSevenDayActivity())
			else
				v:SetActive(ActivityData.Instance:GetActivityIsOpen(INDEX_TO_ACTIVITY_TYPE[k]))
			end
		elseif k == TabIndex.kaifu_fenqizhizhui then
			local is_open = not next(KaiFuChargeData.Instance:GetFenQiCfg())
			v:SetActive(not is_open)
		elseif k == TabIndex.kaifu_day_red_packets then

		elseif k == TabIndex.kaifu_meiri_zhanbei then

		else
			v:SetActive(false)
		end
	end
	local kaifu_time = TimeCtrl.Instance:GetCurOpenServerDay()				--当前开服天数
	if kaifu_time <= 6 then
		RemindManager.Instance:Fire(RemindName.KaiFuRedEquip)
	end
	RemindManager.Instance:Fire(RemindName.KaiFuChargeFirst)
end

function KaiFuChargeView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "all" then
			if self.show_index == TabIndex.kaifu_yueka then
				if self.yueka_view then
					self.yueka_view:Flush()
				end
			elseif self.show_index == TabIndex.kaifu_touzi then
				if self.touzi_view then
					self.touzi_view:Flush()
				end
			elseif self.show_index == TabIndex.kaifu_touzi_login then
				if self.touzi_login_view then
					self.touzi_login_view:Flush()
				end
			elseif self.show_index == TabIndex.kaifu_bipin then
				if self.bipin_view then
					self.bipin_view:Flush()
				end
			elseif self.show_index == TabIndex.kaifu_seven then
				if self.chongzhi_view then
					self.chongzhi_view:Flush()
				end
			elseif self.show_index == TabIndex.kaifu_discount then
				if self.discount_view then
					self.discount_view:Flush()
				end
			elseif self.show_index == TabIndex.kaifu_rising_star then
				if self.rising_star_view then
					self.rising_star_view:Flush()
				end
			elseif self.show_index == TabIndex.kaifu_day_chongzhi_rank then
				if self.chongzhi_rank_view then
					self.chongzhi_rank_view:Flush()
				end
			elseif self.show_index == TabIndex.kaifu_day_xiaofei_rank then
				if self.xiaofei_rank_view then
					self.xiaofei_rank_view:Flush()
				end
			elseif self.show_index == TabIndex.kaifu_group_buy then
				if self.group_buy_view then
					self.group_buy_view:Flush()
				end
			elseif self.show_index == TabIndex.kaifu_personal_buy then
				if self.personal_buy_view then
					self.personal_buy_view:Flush()
				end
			elseif self.show_index == TabIndex.kaifu_day_red_packets then
				if self.seven_day_view then
					self.seven_day_view:Flush()
				end
			elseif self.show_index == TabIndex.kaifu_red_equip then
				if self.red_equip_view then
					self.red_equip_view:Flush()
				end
			elseif self.show_index == TabIndex.kaifu_leiji_reward then
				self.leiji_reward_view:Flush()
			elseif self.show_index == TabIndex.kaifu_pink_equip then
				self.pink_equip_view:Flush()
			elseif self.show_index == TabIndex.kaifu_fenqizhizhui then
				self.fenqizhizhui_view:Flush()
			elseif self.show_index == TabIndex.kaifu_meiri_zhanbei then
				if self.meirizhanbei_view then
					self.meirizhanbei_view:Flush()
				end
			elseif self.show_index == TabIndex.kaifu_thanksfeedback then
				if self.thanksfeedback_view then
					self.thanksfeedback_view:Flush()
				end
			elseif self.show_index == TabIndex.kaifu_super_charge then
				if self.super_charge_feedback then
					self.super_charge_feedback:Flush()
				end
			end
		elseif k == "flush_yueka_view" then
			if self.yueka_view then
				self.yueka_view:Flush(v)
			end
		elseif k == "flush_touzi_view" then
			if self.touzi_view then
				self.touzi_view:Flush(v)
			end
		elseif k == "flush_touzi_login_view" then
			if self.touzi_login_view then
				self.touzi_login_view:Flush(v)
			end
		elseif k == "flush_bipin_view" then
			if self.bipin_view then
				self.bipin_view:Flush(v)
			end
		elseif k == "flush_chongzhi_view" then
			if self.chongzhi_view then
				self.chongzhi_view:Flush(v)
			end
		elseif k == "flush_discount_view" then
			if self.discount_view then
				self.discount_view:Flush(v)
			end
		elseif k == "flush_discount_view_show" then
			local open_info = KaiFuChargeData.Instance:GetDiscountOpenIndex()
			self:FlushDiscountView(#open_info > 0 and true or false)
			if self.discount_view then
				self.discount_view:ShowDiscountView(#open_info > 0 and true or false)
			end
		elseif k == "flush_rising_star_view" then
			if self.rising_star_view then
				self.rising_star_view:Flush(v)
				self.rising_star_view:FlushStar()
			end
		elseif k == "flush_chongzhi_rank_view" then
			if self.chongzhi_rank_view then
				self.chongzhi_rank_view:OnFlush()
				self.chongzhi_rank_view:FlushChongZhi()
			end
		elseif k == "flush_xiaofei_rank_view" then
			if self.xiaofei_rank_view then
				self.xiaofei_rank_view:OnFlush()
				self.xiaofei_rank_view:FlushXiaoFei()
			end
		elseif k == "kaifu_group_buy" then
			if self.group_buy_view then
				self.group_buy_view:Flush()
			end
		elseif k == "kaifu_personal_buy" then
			if self.personal_buy_view then
				self.personal_buy_view:Flush()
			end
		elseif k == "kaifu_day_red_packets" then
			if self.seven_day_view then
				self.seven_day_view:Flush()
			end
		elseif k == "red_equip_activity_flush" then
			if self.red_equip_view then
				self.red_equip_view:Flush()
			end
		elseif k == "danbi_chongzhi_flush" then
			if self.danbi_chongzhi_view then
				self.danbi_chongzhi_view:Flush()
			end
		elseif k == "leiji_reward_flush" then
			if self.leiji_reward_view then
				self.leiji_reward_view:Flush()
			end
		elseif k == "flush_acttotal_consume" then
			if self.totalconsume_view then
				self.totalconsume_view:Flush()
			end
		elseif k == "flush_New_total_chongzhi" then
			if self.OpenNewTotalChongZhi then
				self.OpenNewTotalChongZhi:Flush()
			end
		elseif k == "flush_acttotal_chongzhi" then
			if self.total_chongzhi_view then
				self.total_chongzhi_view:Flush()
			end
		elseif k == "rush_tall_baserender" then
			if self.rush_tall_baserender then
				self.rush_tall_baserender:FlushView()
			end
		elseif k == "rush_chu_baserender" then
			if self.rush_chu_baserender then
				self.rush_chu_baserender:FlushView()
			end
		elseif k == "kaifu_activity_panel_twelve" then
			if self.activity_panel_twelve then
				self.activity_panel_twelve:Flush()
			end
		elseif k == "pink_equip" then
			self.pink_equip_view:Flush()
		elseif k == "fenqi" then
			self.fenqizhizhui_view:Flush()
		elseif k == "meiri_zhanbei" then
			if self.meirizhanbei_view then
				self.meirizhanbei_view:Flush()
			end
		elseif self.show_index == TabIndex.kaifu_thanksfeedback then
			if self.thanksfeedback_view then
				self.thanksfeedback_view:Flush()
			end
		elseif k == "daily_charge_content" then
			if self.daily_charge_content then
				self.daily_charge_content:Flush()
			end
		elseif k == "super_charge_feedback" then
			if self.super_charge_feedback then
				self.super_charge_feedback:Flush()
			end
		end
	end
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()

	-- self.toggle_3:SetActive(server_day <= 7)
	-- self.toggle_4:SetActive(server_day <= 7)
	-- self.toggle_8:SetActive(server_day > 7)
	-- self.toggle_9:SetActive(server_day > 7)

	self.show_left_role:SetValue(self.show_index ~= TabIndex.kaifu_bipin)

	if self.show_index ~= TabIndex.kaifu_rising_star then
		if self.rising_star_view then
			self.rising_star_view:CloseCallBack()
		end
	end

	local spid = GLOBAL_CONFIG.package_info.config.agent_id
	self.toggle_24:SetActive(spid ~= "iml")
end

function KaiFuChargeView:FlushDiscountView(value)
	self.toggle_5:SetActive(value)
	if value ~= true and self.show_index == TabIndex.kaifu_discount then
		self.toggle_1.toggle.isOn = true
	end
end

function KaiFuChargeView:OnToggleChange(index, ison)
	if ison then
		self:ChangeToIndex(index)
		if TabIndex.kaifu_discount == index then
			KaiFuChargeData.Instance:SetXuFuRemind()
			RemindManager.Instance:Fire(RemindName.XuFuCiLi)
		end
	end
end

function KaiFuChargeView:ShowIndexCallBack(index)
	if nil ~= self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
	end
	if not self.toggle_list[index].toggle.isOn then
		if index == TabIndex.kaifu_total_reward then
			self.pos_index = 16
			self:TimerQuest()
		elseif index == TabIndex.kaifu_rush_gao or index == TabIndex.kaifu_rush_chu then
			self.pos_index = 19
			self:TimerQuest()
		elseif index == TabIndex.kaifu_meiri_zhanbei then
			self.pos_index = 24
			self:TimerQuest()
		end
	end
	self.toggle_list[index].toggle.isOn = true
	self:Flush()
end

function KaiFuChargeView:SetPosY()
	local posY = 0
	for i=1,self.pos_index do
		if self["toggle_"..i] then
			if self["toggle_"..i].gameObject.activeInHierarchy then
				posY = posY + 1
			end
		end
	end
	if self.TabBar then
 		self.TabBar.gameObject.transform.localPosition = Vector3(0, posY * 74, 0)
 	end
end

function KaiFuChargeView:TimerQuest()
	self.timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.SetPosY, self), 0.01)
end

function KaiFuChargeView:CurValueGrade()
	if self.bipin_view:IsOpen() then
		self.bipin_view:CurValueGrade()
	end
end

function KaiFuChargeView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.remind_list[remind_name] then
		self.remind_list[remind_name]:SetValue(num > 0)
	end
end

function KaiFuChargeView:GetBiPinGrade()
	local info = {}
	local cur_grade = 0
	local flag_seq = KaiFuChargeData.Instance:BiPinActCurRewardFlagSeq()
	if flag_seq >= 10 then return 0 end					-- 之前遗留 seq从5开始 不知道为什么 一共5段奖励
	for k,v in pairs(BiPinActiveType) do
		if v.active_type and ActivityData.Instance:GetActivityIsOpen(v.active_type) then
			info = v.func()
			cur_grade = info.grade or 0
			break
		end
	end
	return cur_grade
end