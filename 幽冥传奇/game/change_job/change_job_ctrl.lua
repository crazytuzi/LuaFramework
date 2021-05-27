require("scripts/game/change_job/change_job_data")
require("scripts/game/change_job/change_job_view")

ChangeJobCtrl = ChangeJobCtrl or BaseClass(BaseController)

function ChangeJobCtrl:__init()
	if ChangeJobCtrl.Instance then
		ErrorLog("[ChangeJobCtrl] attempt to create singleton twice!")
		return
	end
	ChangeJobCtrl.Instance = self

	self:CreateRelatedObjs()
	self:RegisterAllProtocols()

end

function ChangeJobCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	ChangeJobCtrl.Instance = nil
	if self.roledata_change_callback then
		RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)
		self.roledata_change_callback = nil 
	end
end	

function ChangeJobCtrl:RegisterAllProtocols()
	self.roledata_change_callback = BindTool.Bind1(self.RoleDataChangeCallback,self)			--监听人物属性数据变化
	RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)
	-- self:RegisterProtocol(SCTodayPrayMoneyDataIss, "OnTodayPrayMoneyDataIss")
end

function ChangeJobCtrl:RoleDataChangeCallback(key, value)
	if  key == OBJ_ATTR.ACTOR_JOB_LEVEL then		
		if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_JOB_LEVEL) >0  then
			self.view:Flush(0, "recycle_success")
		end
	end
end

function ChangeJobCtrl:CreateRelatedObjs()
	self.data = ChangeJobData.New()
	self.view = ChangeJobView.New(ViewName.ChangeJob)
end

function ChangeJobCtrl:OnTodayPrayMoneyDataIss(protocol)
	self.data:SetPrayMoneyData(protocol)
	self.view:Flush()
end

function ChangeJobCtrl:ChangeJobReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSChangeJobReq)
	protocol:EncodeAndSend()
end