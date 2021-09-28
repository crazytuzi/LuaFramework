require("game/one_yuan_snatch/one_yuan_snatch_view")
require("game/one_yuan_snatch/one_yuan_snatch_data")

OneYuanSnatchCtrl = OneYuanSnatchCtrl or BaseClass(BaseController)

function OneYuanSnatchCtrl:__init()
	if nil ~= OneYuanSnatchCtrl.Instance then
		print_error("[OneYuanSnatchCtrl] attempt to create singleton twice!")
		return
	end
	OneYuanSnatchCtrl.Instance = self
	self.view = OneYuanSnatchView.New(ViewName.OneYuanSnatchView)
	self.data = OneYuanSnatchData.New()


	self:RegisterAllProtocols()

	ActivityData.Instance:NotifyActChangeCallback(BindTool.Bind(self.ActivityCallBack, self))

end

function OneYuanSnatchCtrl:__delete()
	OneYuanSnatchCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.count_down_time_quest then
		GlobalTimerQuest:CancelQuest(self.count_down_time_quest)
		self.count_down_time_quest = nil
	end

end

function OneYuanSnatchCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCloudPurchaseInfo, "OnSCCloudPurchaseInfo")
	self:RegisterProtocol(SCCloudPurchaseConvertInfo, "OnSCCloudPurchaseConvertInfo")
	self:RegisterProtocol(SCCloudPurchaseBuyRecordInfo, "OnSCCloudPurchaseBuyRecordInfo")
	self:RegisterProtocol(SCCloudPurchaseServerRecord, "OnSCCloudPurchaseServerRecord")
	self:RegisterProtocol(SCCloudPurchaseUserInfo, "OnSCCloudPurchaseUserInfo")
	
end

function OneYuanSnatchCtrl:OnSCCloudPurchaseInfo(protocol)
	self.data:SetSCCloudPurchaseInfo(protocol)

	if self.view then
		self.view:Flush("snatch")
	end
end

function OneYuanSnatchCtrl:OnSCCloudPurchaseConvertInfo(protocol)
	self.data:SetSCCloudPurchaseConvertInfo(protocol)

	if self.view then
		self.view:Flush("integral")
	end
end

function OneYuanSnatchCtrl:OnSCCloudPurchaseBuyRecordInfo(protocol)
	self.data:SetSCCloudPurchaseBuyRecordInfo(protocol)

	if self.view then
		self.view:Flush("log")
	end
end

function OneYuanSnatchCtrl:OnSCCloudPurchaseServerRecord(protocol)
	self.data:SetSCCloudPurchaseServerRecord(protocol)

	if self.view then
		self.view:Flush("log")
	end
end

function OneYuanSnatchCtrl:OnSCCloudPurchaseUserInfo(protocol)
	self.data:SetCloudPurchaseUserInfo(protocol)

	if self.view then
		self.view:Flush("integral")
		self.view:Flush("ticket")
	end
end

function OneYuanSnatchCtrl:SendOperate(operate_type, param_1, param_2, param_3)
	local act_info = ActivityData.Instance:GetCrossRandActivityStatusByType(ACTIVITY_TYPE.KF_ONEYUANSNATCH)
	if act_info and act_info.status == ACTIVITY_STATUS.OPEN then
		KuaFuChongZhiRankCtrl.SendTianXiangOperate(ACTIVITY_TYPE.KF_ONEYUANSNATCH,operate_type, param_1, param_2)
	end
end


function OneYuanSnatchCtrl:ActivityCallBack(activity_type, status)
	if activity_type ~= ACTIVITY_TYPE.KF_ONEYUANSNATCH then return end

	local act_info = ActivityData.Instance:GetCrossRandActivityStatusByType(ACTIVITY_TYPE.KF_ONEYUANSNATCH)
	if act_info then
		MainUICtrl.Instance:FlushView()
		
		if act_info.status == ACTIVITY_STATUS.CLOSE and self.view then
			self.view:Close()
		end
	end
end


function OneYuanSnatchCtrl:SetCellCountDown(time)
	if not time then return end

	if not self.cell_time then self.cell_time = time end

	self.cell_time = self.cell_time > time and time or self.cell_time

	local count_down_func = function()
		self.cell_time = self.cell_time - 1
		
		if self.cell_time <= 0 then	
			self:SendOperate(RA_CLOUDPURCHASE_OPERA_TYPE.RA_CLOUDPURCHASE_OPERA_TYPE_INFO )
			GlobalTimerQuest:CancelQuest(self.count_down_time_quest)
			self.count_down_time_quest = nil
			self.cell_time = nil
		end
	end

	if not self.count_down_time_quest then
		self.count_down_time_quest = GlobalTimerQuest:AddRunQuest(count_down_func, 1)
	end
end