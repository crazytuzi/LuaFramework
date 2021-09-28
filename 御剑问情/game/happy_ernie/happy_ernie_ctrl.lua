require("game/happy_ernie/happy_ernie_view")
require("game/happy_ernie/happy_ernie_data")

HappyErnieCtrl = HappyErnieCtrl or BaseClass(BaseController)
function HappyErnieCtrl:__init()
	if HappyErnieCtrl.Instance then
		print_error("[HappyErnieCtrl] Attemp to create a singleton twice !")
	end
	HappyErnieCtrl.Instance = self
	self.data = HappyErnieData.New()
	self.view = HappyErnieView.New(ViewName.HappyErnieView)

	self:RegisterAllProtocols()
	
	ActivityData.Instance:NotifyActChangeCallback(BindTool.Bind(self.ActivityChange, self))
	--绑定红点回调
	self.reddot_activate = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.reddot_activate, RemindName.HappyErnieRemind)
end

function HappyErnieCtrl:__delete()
	HappyErnieCtrl.Instance = nil
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.reddot_activate then
		RemindManager.Instance:UnBind(self.reddot_activate)
		self.reddot_activate = nil
	end
end

function HappyErnieCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAHuanLeYaoJiangInfo, "OnSCRAMiJingXunBaoInfo")
	self:RegisterProtocol(SCRAHuanLeYaoJiangTaoResultInfo, "OnSCRAHappyErnieTaoResultInfo")
end

function HappyErnieCtrl:OnSCRAMiJingXunBaoInfo(protocol)
	self.data:SetRAHappyErnieInfo(protocol)									-- 服务器下发协议
	if self.view:IsOpen() then												-- 协议下发后刷新
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.HappyErnieRemind)				-- 红点
end

function HappyErnieCtrl:OnSCRAHappyErnieTaoResultInfo(protocol)
	self.data:SetRAHappyErnieTaoResultInfo(protocol)												-- 服务器下发协议
	TipsCtrl.Instance:ShowTreasureView(self.data:GetChestShopMode())					-- 显示寻宝奖励界面
	if self.view:IsOpen() then
		self.view:Flush()																			-- 协议下发后刷新
	end
	RemindManager.Instance:Fire(RemindName.HappyErnieRemind)										-- 红点			
end

-- 申请开服活动信息
-- function HappyErnieCtrl:SendGetKaifuActivityInfo(rand_activity_type, opera_type, param_1, param_2)
-- 	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(rand_activity_type, opera_type, param_1, param_2)
-- end

function HappyErnieCtrl:ActivityChange(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_ERNIE then
		-- 活动开启之后才请求
		if status == ACTIVITY_STATUS.OPEN then
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_ERNIE,RA_HAPPYERNIE_OPERA_TYPE.RA_HAPPYERNIE_OPERA_TYPE_QUERY_INFO,0,0)
		end
	end
end


function HappyErnieCtrl:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.HappyErnieRemind and ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_ERNIE)  then
		self.data:FlushHallRedPoindRemind()
	end
end

