require("game/happy_hit_egg/happy_hit_egg_view")
require("game/happy_hit_egg/happy_hit_egg_data")

HappyHitEggCtrl = HappyHitEggCtrl or BaseClass(BaseController)
function HappyHitEggCtrl:__init()
	if HappyHitEggCtrl.Instance then
		print_error("[HappyHitEggCtrl] Attemp to create a singleton twice !")
	end
	HappyHitEggCtrl.Instance = self
	self.data = HappyHitEggData.New()
	self.view = HappyHitEggView.New(ViewName.HappyHitEggView)

	self:RegisterAllProtocols()
	
	ActivityData.Instance:NotifyActChangeCallback(BindTool.Bind(self.ActivityChange, self))
	--绑定红点回调
	self.reddot_activate = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.reddot_activate, RemindName.HappyEggRemind)
end

function HappyHitEggCtrl:__delete()
	HappyHitEggData.Instance = nil
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

function HappyHitEggCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAHuanLeZaDanInfo, "OnSCRAHuanLeZaDanInfo")
	self:RegisterProtocol(SCRAHuanLeZaDanResultInfo, "OnSCRAHuanLeZaDanResultInfo")
end

function HappyHitEggCtrl:OnSCRAHuanLeZaDanInfo(protocol)
	self.data:SetRAHuanLeZaDanInfo(protocol)													--服务器下发协议
	 if self.view:IsOpen() and self.view:IsLoaded() then
		self.view:FlushNextTime()
	end
	self.view:Flush()																			--协议放松下来后刷新
	RemindManager.Instance:Fire(RemindName.HappyEggRemind)						            	--红点
end

function HappyHitEggCtrl:OnSCRAHuanLeZaDanResultInfo(protocol)
	self.data:HappyHitEggBaoTaoResultInfo(protocol)												--服务器下发协议
	TipsCtrl.Instance:ShowTreasureView(HappyHitEggData.Instance:GetChestShopMode())	            --显示寻宝奖励界面
	self.view:Flush()																			--协议放松下来后刷新
	RemindManager.Instance:Fire(RemindName.HappyEggRemind)						            	--红点				
end

function HappyHitEggCtrl:ActivityChange(activity_type, status, next_time, open_type)

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_ZADAN then
		-- 活动开启之后才请求
		if status == ACTIVITY_STATUS.OPEN then
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_ZADAN,RA_HUANLEZADAN_OPERA_TYPE.RA_HUANLEZADAN_OPERA_TYPE_QUERY_INFO,0,0)
		end
	end
end


function HappyHitEggCtrl:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.HappyEggRemind and ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_ZADAN)  then
		self.data:FlushHallRedPoindRemind()
	end
end

