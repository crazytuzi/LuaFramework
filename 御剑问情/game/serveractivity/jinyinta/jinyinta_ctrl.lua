require("game/serveractivity/jinyinta/jinyinta_data")
require("game/serveractivity/jinyinta/jinyinta_view")

JinYinTaCtrl = JinYinTaCtrl or BaseClass(BaseController)

function JinYinTaCtrl:__init()
	if JinYinTaCtrl.Instance then
		print_error("[JinYinTaCtrl]:Attempt to create singleton twice!")
	end
	JinYinTaCtrl.Instance = self

	self.view = JinYinTaView.New(ViewName.JinYinTaView)
	self.data = JinYinTaData.New()

	self:RegisterAllProtocols()
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MianUIOpenComlete, self))
end

function JinYinTaCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

    if self.main_view_complete then
    	GlobalEventSystem:UnBind(self.main_view_complete)
        self.main_view_complete = nil
    end


	JinYinTaCtrl.Instance = nil
end

function JinYinTaCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRALevelLotteryInfo, "OnRALevelLotteryInfo")						--随机活动金银塔
	self:RegisterProtocol(SCRALevelLotteryRewardList, "OnRALevelLotteryRewardList")
	self:RegisterProtocol(SCRALevelLotteryActivityInfo, "OnSCRALevelLotteryActivityInfo")
end

 
 --随机活动金银塔抽奖活动
function JinYinTaCtrl:OnRALevelLotteryInfo(protocol)
	self.data:SetLevelLotteryInfo(protocol)
	if self.view:IsOpen() and self.view:IsLoaded() then
		self.view:FlushCurrLevel()
	end
end

--随机活动金银塔抽奖活动
function JinYinTaCtrl:OnRALevelLotteryRewardList(protocol)
	self.data:SetLevelLotteryRewardList(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	JinYinTaData.Instance:FlushHallRedPoindRemind()
	RemindManager.Instance:Fire(RemindName.JINYINTA)
end

 -- 抽奖次数与免费时间
function JinYinTaCtrl:OnSCRALevelLotteryActivityInfo(protocol)
	self.data:SetLotteryActivityInfo(protocol)
 	if self.view:IsOpen() and self.view:IsLoaded() then
		self.view:FlushNextTime()
	end
	JinYinTaData.Instance:FlushHallRedPoindRemind()
	RemindManager.Instance:Fire(RemindName.JINYINTA)
end

function JinYinTaCtrl:MianUIOpenComlete()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_JINYINTA)
	if is_open then
		-- 请求记录信息
	 	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_JINYINTA,RA_TOTAL_CHARGE_OPERA_TYPE.RA_LEVEL_LOTTERY_OPERA_TYPE_QUERY_INFO)
	 	-- 请求活动信息	
	 	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_JINYINTA,RA_TOTAL_CHARGE_OPERA_TYPE.RA_LEVEL_LOTTERY_OPERA_TYPE_ACTIVITY_INFO)
	end
end
