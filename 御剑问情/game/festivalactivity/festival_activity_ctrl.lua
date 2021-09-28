require("game/festivalactivity/festival_activity_view")
require("game/festivalactivity/festival_activity_data")
require("game/festivalactivity/festival_activity_leichong/festival_activity_leichong_data")
require("game/festivalactivity/festival_activity_sanbao/festivity_activity_sanbao_data")
require("game/festivalactivity/festival_activity_makemooncake/make_mooncake_view")
require("game/festivalactivity/festival_activity_makemooncake/make_mooncake_data")
require("game/festivalactivity/festival_activity_equipment_view")
require("game/festivalactivity/festival_activity_taozhuang_view")
require("game/festivalactivity/festival_activity_xiaofeirank_view")
require("game/festivalactivity/festival_activity_chongzhirank_view")
require("game/festivalactivity/autumn_activity_panel_lianxuchongzhi")
require("game/festivalactivity/festival_activity_happy_ernie/autumn_activity_panel_happy_ernie_view")
require("game/festivalactivity/festival_activity_happy_ernie/autumn_activity_panel_happy_ernie_data")
require("game/festivalactivity/expense_nice_gift")
require("game/festivalactivity/expense_nice_gift_reward_pool_view")
require("game/festivalactivity/festival_activity_leichong/festival_activity_leichong_view")
require("game/festivalactivity/festival_activity_sanbao/festivity_activity_sanbao_view")
require("game/festivalactivity/landing_reward")
require("game/festivalactivity/landing_reward")require("game/festivalactivity/crazy_gift_view")FestivalActivityCtrl = FestivalActivityCtrl or BaseClass(BaseController)
function FestivalActivityCtrl:__init()
	if nil ~= FestivalActivityCtrl.Instance then
		return
	end

	FestivalActivityCtrl.Instance = self

	self.view = FestivalActivityView.New(ViewName.FestivalView)
	self.data = FestivalActivityData.New()
	self.leichong_data = FestivalLeiChongData.New()
	self.sanbao_data = VersionThreePieceData.New()
	self.festval_view = FestivalequipmentInfoView.New(ViewName.FestivalequipmentInfoView)
	self.make_cake_data = MakeMoonCakeData.New()

	self:RegisterAllProtocols()

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.SendExpenseInfo, self))
end

function FestivalActivityCtrl:__delete()
	FestivalActivityCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
	end

	if self.festval_view then
		self.festval_view:DeleteMe()
	end

	if self.data then
		self.data:DeleteMe()
	end

	if self.make_cake_data then
		self.make_cake_data:DeleteMe()
	end
end

function FestivalActivityCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAVersionTotalChargeInfo, "OnSCRAVersionTotalChargeInfo")

	self:RegisterProtocol(SCRATotalChargeFiveInfo, "OnSCRATotalChargeFiveInfo")

	-- 消费好礼
	self:RegisterProtocol(SCRAExpenseNiceGiftInfo, "OnSCRAExpenseNiceGiftInfo")
	self:RegisterProtocol(SCRAExpenseNiceGiftResultInfo, "OnSCRAExpenseNiceGiftResultInfo")

	-- 匠心月饼兑换次数
	self:RegisterProtocol(SCCollectSecondExchangeInfo, "OnCollectSecondExchangeInfo")
    --中秋连续充值
	self:RegisterProtocol(SCRAVersionContinueChongzhiInfo, "OnRAContinueChongzhiInfoZhongQiu")

	--充值排行
	self:RegisterProtocol(SCRAChongzhiRankTwoInfo, "OnRAChongzhiRankTwoInfo")

	--消费排行
	self:RegisterProtocol(SCRAConsumeGoldRankTwoInfo, "OnRAConsumeGoldRankTwoInfo")
end

--刷新通用方法，必须从此处刷新
function FestivalActivityCtrl:FlushView(key)
	if self.view then
		self.view:Flush(key)
	end
end

function FestivalActivityCtrl:SendEquipSeq(seq)
	self.festval_view:SendEquipSeq(seq)
	self.festval_view:Open()
end

function FestivalActivityCtrl:SetActivityStatus(protocol)
	self.data:SetActivityOpenList(protocol)

	--设置一个活动控制两个标签的显示
	for k,v in pairs(ONE_ID_DOUBLE_ACTIVITY) do
		if k == protocol.activity_type then
			protocol.activity_type = v
			self.data:SetActivityOpenList(protocol)
		end
	end

	self:FlushView("toggle")
	if self.data:GetActivityOpenNum() > 0 then
		MainUIView.Instance:SetFestivaluIcon(true)
	else
		if self.view:IsOpen() then
			self.view:Close()
		end
		MainUIView.Instance:SetFestivaluIcon(false)
	end

	--回头优化，这里有问题
	RemindManager.Instance:Fire(RemindName.FestivalActivity)
	RemindManager.Instance:Fire(RemindName.ExpenseNiceGiftRemind)
	RemindManager.Instance:Fire(RemindName.VesLeiChongRemind)
	RemindManager.Instance:Fire(RemindName.ZhongQiuLianXuChongZhi)
	RemindManager.Instance:Fire(RemindName.OpenFestivalPanel)
	RemindManager.Instance:Fire(RemindName.LoginRewardRemind)
end


--版本累充--
function FestivalActivityCtrl:OnSCRAVersionTotalChargeInfo(protocol)
	self.leichong_data:SetFesLeiChongInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush("vesleichong")
	end

	RemindManager.Instance:Fire(RemindName.VesLeiChongRemind)
end

--吉祥三宝--
function FestivalActivityCtrl:OnSCRATotalChargeFiveInfo(protocol)
	self.sanbao_data:SetSanBaoInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush("jixiangsanbao")
	end
end

function FestivalActivityCtrl:SendGetSanBaoActivityInfo()
	if IS_ON_CROSSSERVER then
		return
	end
	local protocol = ProtocolPool.Instance:GetProtocol(CSRATotalChargeFiveInfo)
	protocol:EncodeAndSend()
end
----------


----------------------------------------------------------------------------------
-------------------------------消费好礼-------------------------------------------
function FestivalActivityCtrl:OnSCRAExpenseNiceGiftInfo(protocol)

	self.data:SetExpenseNiceGiftInfo(protocol)

	if self.view then
		self.view:Flush("expensenicegift")
	end

	RemindManager.Instance:Fire(RemindName.ExpenseNiceGiftRemind)
end

function FestivalActivityCtrl:OnSCRAExpenseNiceGiftResultInfo(protocol)
	self.data:SetExpenseNiceGiftResultInfo(protocol)

	if self.view then
		self.view:ExpenseViewStartRoll()
	end
end

function FestivalActivityCtrl:SendExpenseNiceGiftInfo(opera_type, param_1, param_2)
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT, opera_type, param_1, param_2)
end

function FestivalActivityCtrl:SendExpenseInfo()
	FestivalActivityCtrl.Instance:SendExpenseNiceGiftInfo(RA_EXPENSE_NICE_GIFT_OPERA_TYPE.RA_EXPENSE_NICE_GIFT_OPERA_TYPE_QUERY_INFO)
end

--充值排行
function FestivalActivityCtrl:OnRAChongzhiRankTwoInfo(protocol)
	self.data:SendChongZhiRankInfo(protocol)
	self.view:Flush("chongzhirank")
end

--消费排行
function FestivalActivityCtrl:OnRAConsumeGoldRankTwoInfo(protocol)
	self.data:SendXiaoFeiRankInfo(protocol)
	self.view:Flush("xiaofeirank")
end

----------------------------- 匠心月饼活动兑换次数------------------------------
function FestivalActivityCtrl:OnCollectSecondExchangeInfo(protocol)
	self.make_cake_data:SetCollectExchangeInfo(protocol.exchange_times)
	if self.view:IsOpen() then
		self.view:Flush("make_moon_cake")
	end
	RemindManager.Instance:Fire(RemindName.MakeMoonAct)
end

----------------中秋连续充值协议-----------
function FestivalActivityCtrl:OnRAContinueChongzhiInfoZhongQiu(protocol)
	self.data:SetChongZhiZhongQiu(protocol)
	self.view:Flush("lianxuchongzhi")
	RemindManager.Instance:Fire(RemindName.ZhongQiuLianXuChongZhi)
end

---------------------后面添加需要新建文件夹，禁止直接在这个ctrl添加-----------------------------


