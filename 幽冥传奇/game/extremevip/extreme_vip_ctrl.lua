require("scripts/game/extremevip/extreme_vip_view")
require("scripts/game/extremevip/extreme_vip_data")
require("scripts/game/extremevip/extreme_vip_common_view")

-- 至尊VIP
ExtremeVipCtrl = ExtremeVipCtrl or BaseClass(BaseController)

function ExtremeVipCtrl:__init()
	if ExtremeVipCtrl.Instance ~= nil then
		ErrorLog("[ExtremeVipCtrl] Attemp to create a singleton twice !")
	end
	ExtremeVipCtrl.Instance = self

	self.vip_view = ExtremeVipView.New(ViewName.ExtremeVip)
	self.vip_common_view = ExtremeVipCommonView.New(ViewName.ExtremeVipCommonView)
	self.vip_data = ExtremeVipData.New()
	-- self.role_data_rcv_evt = GlobalEventSystem:Bind(LoginEventType.ENTER_GAME_SERVER_SUCC, BindTool.Bind(self.OnCheck, self))
	self.vip_qq_handle = GlobalEventSystem:Bind(ExtremeVipEvent.VIP_QQ_INFO_SUBMIT,BindTool.Bind(self.OnFlushMainuiIcon, self))
end

function ExtremeVipCtrl:__delete()
	self.vip_view:DeleteMe()
	self.vip_view = nil

	self.vip_data:DeleteMe()
	self.vip_data = nil

	if self.vip_qq_handle then
		GlobalEventSystem:UnBind(self.vip_qq_handle)
		self.vip_qq_handle = nil
	end

	ExtremeVipCtrl.Instance = nil
end

function ExtremeVipCtrl:ObjBuffChange(obj)
	if obj:GetType() == SceneObjType.MainRole then
		if RoleData.HasBuffGroup(BUFF_GROUP.VIP_MULTI_EXP) then
			self:SentVipInfoReq()
		end
	end
end

function ExtremeVipCtrl:GetAllVipInfo()
	VipCtrl.Instance:SentVipInfoReq()
end

function ExtremeVipCtrl:OnFlushMainuiIcon()
	ViewManager.Instance:FlushView(ViewName.MainUi, 0, "icon_pos")

	if not ExtremeVipData.Instance:IsExtremeVipIconShow() then
		self.vip_view:Close()
	end	
end

-- function ExtremeVipCtrl:OnCheck()
-- 	AgentMs:ZZVIPRequest(1)
-- end