require("scripts/game/superme_vip/superme_vip_data")
require("scripts/game/superme_vip/superme_vip_view")

SuperMeVipCtrl = SuperMeVipCtrl or BaseClass(BaseController)

function SuperMeVipCtrl:__init()
	if SuperMeVipCtrl.Instance then
		ErrorLog("[SuperMeVipCtrl] attempt to create singleton twice!")
		return
	end
	SuperMeVipCtrl.Instance = self

	self:CreateRelatedObjs()
	self:RegisterAllProtocols()

end

function SuperMeVipCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	SuperMeVipCtrl.Instance = nil
	if self.roledata_change_callback then
		RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)
		self.roledata_change_callback = nil 
	end
end	

function SuperMeVipCtrl:RegisterAllProtocols()
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.OnRecvMainRoleInfo, self))
	self.roledata_change_callback = BindTool.Bind1(self.RoleDataChangeCallback,self)			--监听人物属性数据变化
	RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)
end

function SuperMeVipCtrl:OnRecvMainRoleInfo()
	RemindManager.Instance:DoRemind(RemindName.Privilege)
end

function SuperMeVipCtrl:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.ACTOR_DRAW_GOLD_COUNT or key == OBJ_ATTR.ACTOR_SUPER_VIP then		
		if ViewManager.Instance then
			ViewManager.Instance:FlushView(ViewName.MainUi, 0, "icon_pos")
		end
		if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SUPER_VIP) >0  then
			self.view:Flush(0, "recycle_success")
		end
	end
end

function SuperMeVipCtrl:CreateRelatedObjs()
	self.data = SuperMeData.New()
	self.view = SuperMeView.New(ViewName.SuperMe)
end

function SuperMeVipCtrl:OnTodayPrayMoneyDataIss(protocol)
	-- self.data:SetPrayMoneyData(protocol)
end

function SuperMeVipCtrl:OpenSuperMeReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetVIPLevRewardsFlagReq)
	protocol:EncodeAndSend()
end