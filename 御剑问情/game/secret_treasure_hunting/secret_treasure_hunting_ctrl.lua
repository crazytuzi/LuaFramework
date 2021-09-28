require("game/secret_treasure_hunting/secret_treasure_hunting_view")
require("game/secret_treasure_hunting/secret_treasure_hunting_data")

SecretTreasureHuntingCtrl = SecretTreasureHuntingCtrl or BaseClass(BaseController)
function SecretTreasureHuntingCtrl:__init()
	if SecretTreasureHuntingCtrl.Instance then
		print_error("[SecretTreasureHuntingCtrl] Attemp to create a singleton twice !")
	end
	SecretTreasureHuntingCtrl.Instance = self

	self.data = SecretTreasureHuntingData.New()
	self.view = SecretTreasureHuntingView.New(ViewName.SecretTreasureHuntingView)

	self.activity_change = BindTool.Bind(self.ActivityChangeCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_change)

	self.reddot_activate = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.reddot_activate, RemindName.SecretTreasureHuntingRemind)

	self:RegisterAllProtocols()
end

function SecretTreasureHuntingCtrl:__delete()
	SecretTreasureHuntingCtrl.Instance = nil

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

function SecretTreasureHuntingCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAMiJingXunBaoInfo3, "OnSCRAMiJingXunBaoInfo")
	self:RegisterProtocol(SCRAMiJingXunBaoTaoResultInfo3, "OnSCRAMiJingXunBaoTaoResultInfo")
end

function SecretTreasureHuntingCtrl:OnSCRAMiJingXunBaoInfo(protocol)
	self.data:SetRAMiJingXunBaoInfo(protocol)
	self:FlushecretTreasureView()
end

function SecretTreasureHuntingCtrl:OnSCRAMiJingXunBaoTaoResultInfo(protocol)
	self.data:MiJingXunBaoTaoResultInfo(protocol)
	TipsCtrl.Instance:ShowTreasureView(SecretTreasureHuntingData.Instance:GetChestShopMode())
	self:FlushecretTreasureView()	
end

function SecretTreasureHuntingCtrl:SendGetKaifuActivityInfo(opera_type, param_1, param_2)
	local rand_activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIJINGXUNBAO3
	local opera_type = opera_type and opera_type or RA_MIJINGXUNBAO3_OPERA_TYPE.RA_MIJINGXUNBAO3_OPERA_TYPE_QUERY_INFO
	local param_1 = param_1 or 0
	local param_2 = param_2 or 0

	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(rand_activity_type, opera_type, param_1, param_2)
end

function SecretTreasureHuntingCtrl:ActivityChangeCallBack(activity_type, status, next_time, open_type)
	if activity_type ~= ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIJINGXUNBAO3 or status ~= ACTIVITY_STATUS.OPEN then return end

	local cur_activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIJINGXUNBAO3
	local opera_type = RA_MIJINGXUNBAO3_OPERA_TYPE.RA_MIJINGXUNBAO3_OPERA_TYPE_QUERY_INFO
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(cur_activity_type, opera_type)
end

function SecretTreasureHuntingCtrl:RemindChangeCallBack(remind_name, num)
	local activity_type =  ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIJINGXUNBAO3
	if remind_name == RemindName.SecretTreasureHuntingRemind and ActivityData.Instance:GetActivityIsOpen(activity_type) then
		self.data:FlushHallRedPoindRemind()
	end
end

function SecretTreasureHuntingCtrl:FlushecretTreasureView()
	if self.view and self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.SecretTreasureHuntingRemind)
end

