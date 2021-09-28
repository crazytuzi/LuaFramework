require("game/appearance/multi_mount/multi_mount_data")
require("game/appearance/multi_mount/multi_mount_huan_hua_view")
MultiMountCtrl = MultiMountCtrl or BaseClass(BaseController)

function MultiMountCtrl:__init()
	if MultiMountCtrl.Instance ~= nil then
		ErrorLog("[MultiMountCtrl] attempt to create singleton twice!")
		return
	end
	MultiMountCtrl.Instance = self
	self.data = MultiMountData.New()
	-- self.huanhua_view = MultiMountHuanHuaView.New()
	self:RegisterMultiMountProtocols()
end

function MultiMountCtrl:__delete()
	if self.refuse_multi_Timer then
		GlobalTimerQuest:CancelQuest(self.refuse_multi_Timer)
		self.refuse_multi_Timer = nil
	end
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	if nil ~= self.huanhua_view then
		self.huanhua_view:DeleteMe()
		self.huanhua_view = nil
	end

	MultiMountCtrl.Instance = nil
end

-- 注册协议
function MultiMountCtrl:RegisterMultiMountProtocols()
	self:RegisterProtocol(SCMultiMountAllInfo, "OnSCMultiMountAllInfo")
	self:RegisterProtocol(SCMultiMountChangeNotify, "OnSCMultiMountChangeNotify")
end

function MultiMountCtrl:OpenHuanhuaView()
	-- self.huanhua_view:Open()
end

function MultiMountCtrl:OnSCMultiMountAllInfo(protocol)
	self.data:SetMultiMountAllInfo(protocol)
	ViewManager.Instance:FlushView(ViewName.AppearanceView)
	RemindManager.Instance:Fire(RemindName.MultiMount)
end

function MultiMountCtrl:OnSCMultiMountChangeNotify(protocol)
	self.data:SetMultiMountChangeNotifyInfo(protocol)
	if protocol.notify_type == MULTI_MOUNT_CHANGE_NOTIFY_TYPE.MULTI_MOUNT_CHANGE_NOTIFY_TYPE_SELECT_MOUNT or
		protocol.notify_type == MULTI_MOUNT_CHANGE_NOTIFY_TYPE.MULTI_MOUNT_CHANGE_NOTIFY_TYPE_UPGRADE or
		protocol.notify_type == MULTI_MOUNT_CHANGE_NOTIFY_TYPE.MULTI_MOUNT_CHANGR_NOTIFY_TYPE_UPGRADE_EQUIP then
		ViewManager.Instance:FlushView(ViewName.AppearanceView)
		RemindManager.Instance:Fire(RemindName.MultiMount)
	elseif protocol.notify_type == MULTI_MOUNT_CHANGE_NOTIFY_TYPE.MULTI_MOUNT_CHANGE_NOTIFY_TYPE_ACTIVE_SPECIAL_IMG or
		protocol.notify_type == MULTI_MOUNT_CHANGE_NOTIFY_TYPE.MULTI_MOUNT_CHANGE_NOTIFY_TYPE_USE_SPECIAL_IMG or
		protocol.notify_type == MULTI_MOUNT_CHANGE_NOTIFY_TYPE.MULTI_MOUNT_CHANGE_NOTIFY_TYPE_UPLEVEL_SPECIAL_IMG then
		-- self.huanhua_view:Flush()
		RemindManager.Instance:Fire(RemindName.MultiMount)
	elseif protocol.notify_type == MULTI_MOUNT_CHANGE_NOTIFY_TYPE.MULTI_MOUNT_CHANGE_NOTIFY_TYPE_INVITE_RIDE then
		self:OpenAnswerMultiMountInviteView()
	end
end

function MultiMountCtrl:OnMultiMountUpgradeResult(result)
	if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
		local view = ViewManager.Instance:GetView(ViewName.AppearanceView)
		if view then
			view:MultiMountUpgradeResult(result)
		end
	end
end

-- 协议请求
function MultiMountCtrl:SendMultiModuleReq(opera_type, param_1, param_2, param_3)
	local protocol = ProtocolPool.Instance:GetProtocol(CSMultiMountOperaReq)
	protocol.opera_type = opera_type
	protocol.reserve = 0
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol.param_3 = param_3 or 0
	protocol:EncodeAndSend()
end

-- 双人坐骑化形进阶协议请求
function MultiMountCtrl:SendImageMultiMountUpgradeReq(image_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSMultimountImageUpgrade)
	protocol.image_id = image_id or 0
	protocol:EncodeAndSend()
end

--------------双人坐骑回复请求--------
function MultiMountCtrl:OpenAnswerMultiMountInviteView()
	local multi_notify_data = self.data:GetMultiMountChangeNotify()
	local obj = Scene.Instance:GetObjByUId(multi_notify_data.param_1)
	local str = ""
	if nil ~= obj then
		str = string.format(Language.MultiMount.InviteToSitMount, obj.vo.name or "")
	end
	TipsCtrl.Instance:ShowCommonAutoView("", str, BindTool.Bind(self.AnswerMultiMountInvite, self, 1), BindTool.Bind(self.AnswerMultiMountInvite, self, 0))
	self.refuse_multi_Timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(TipsCtrl.CloseCommonAutoView, TipsCtrl.Instance), 5)
end

function MultiMountCtrl:AnswerMultiMountInvite(is_ok)
	if self.refuse_multi_Timer then
		GlobalTimerQuest:CancelQuest(self.refuse_multi_Timer)
		self.refuse_multi_Timer = nil
	end

	local multi_notify_data = self.data:GetMultiMountChangeNotify()
	MultiMountCtrl.Instance:SendMultiModuleReq(MULTI_MOUNT_REQ_TYPE.MULTI_MOUNT_REQ_TYPE_INVITE_RIDE_ACK, multi_notify_data.param_1, is_ok)
end