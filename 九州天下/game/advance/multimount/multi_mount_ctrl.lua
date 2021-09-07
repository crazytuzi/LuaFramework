require("game/advance/multimount/multi_mount_data")

MultiMountCtrl = MultiMountCtrl or BaseClass(BaseController)

function MultiMountCtrl:__init()
	if MultiMountCtrl.Instance ~= nil then
		ErrorLog("[MultiMountCtrl] attempt to create singleton twice!")
		return
	end
	MultiMountCtrl.Instance = self
	self.data = MultiMountData.New()
	self:RegisterMultiMountProtocols()
end

function MultiMountCtrl:__delete()
	if self.refuse_multi_Timer then
		GlobalTimerQuest:CancelQuest(self.refuse_multi_Timer)
		self.refuse_multi_Timer = nil
	end


	if self.bless_timer_list ~= nil then
		for k,v in pairs(self.bless_timer_list) do
			if v ~= nil then
				GlobalTimerQuest:CancelQuest(v)
			end
		end

		self.bless_timer_list = nil
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

	self:RegisterProtocol(CSMultiMountOperaReq)
end

function MultiMountCtrl:OpenHuanhuaView()
	self.huanhua_view:Open()
end

function MultiMountCtrl:OnSCMultiMountAllInfo(protocol)
	self.data:SetMultiMountAllInfo(protocol)
	AdvanceCtrl.Instance:FlushView("multi_mount")
	--ViewManager.Instance:FlushView(ViewName.AppearanceView)
	--RemindManager.Instance:Fire(RemindName.MultiMount)
	self:CheckBlessTimer(protocol.mount_list)
end

function MultiMountCtrl:OnSCMultiMountChangeNotify(protocol)
	self.data:SetMultiMountChangeNotifyInfo(protocol)
	if protocol.notify_type == MULTI_MOUNT_CHANGE_NOTIFY_TYPE.MULTI_MOUNT_CHANGE_NOTIFY_TYPE_SELECT_MOUNT or
		protocol.notify_type == MULTI_MOUNT_CHANGE_NOTIFY_TYPE.MULTI_MOUNT_CHANGE_NOTIFY_TYPE_UPGRADE or
		protocol.notify_type == MULTI_MOUNT_CHANGE_NOTIFY_TYPE.MULTI_MOUNT_CHANGR_NOTIFY_TYPE_UPGRADE_EQUIP or
		protocol.notify_type == MULTI_MOUNT_CHANGE_NOTIFY_TYPE.MULTI_MOUNT_CHANGE_NOTIFY_TYPE_UPLEVEL then
		AdvanceCtrl.Instance:FlushView("multi_mount")
		if protocol.notify_type == MULTI_MOUNT_CHANGE_NOTIFY_TYPE.MULTI_MOUNT_CHANGE_NOTIFY_TYPE_UPGRADE then
			local data = self.data:GetMultiDataList()
			if data ~= nil and next(data) ~= nil then
				self:CheckBlessTimer(data)
			end
		end
		--RemindManager.Instance:Fire(RemindName.MultiMount)
	-- elseif protocol.notify_type == MULTI_MOUNT_CHANGE_NOTIFY_TYPE.MULTI_MOUNT_CHANGE_NOTIFY_TYPE_ACTIVE_SPECIAL_IMG or
	-- 	protocol.notify_type == MULTI_MOUNT_CHANGE_NOTIFY_TYPE.MULTI_MOUNT_CHANGE_NOTIFY_TYPE_USE_SPECIAL_IMG or
	-- 	protocol.notify_type == MULTI_MOUNT_CHANGE_NOTIFY_TYPE.MULTI_MOUNT_CHANGE_NOTIFY_TYPE_UPLEVEL_SPECIAL_IMG then
	-- 	self.huanhua_view:Flush()
	-- 	RemindManager.Instance:Fire(RemindName.MultiMount)
	elseif protocol.notify_type == MULTI_MOUNT_CHANGE_NOTIFY_TYPE.MULTI_MOUNT_CHANGE_NOTIFY_TYPE_INVITE_RIDE then
		self:OpenAnswerMultiMountInviteView()
	end
end

function MultiMountCtrl:OnMultiMountUpgradeResult(result)
	-- if ViewManager.Instance:IsOpen(ViewName.Advance) then
	-- 	local view = ViewManager.Instance:GetView(ViewName.Advance)
	-- 	if view then
	-- 		view:MultiMountUpgradeResult(result)
	-- 	end
	-- end
	AdvanceCtrl.Instance:MultiMountUpGradeResult(result)
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

function MultiMountCtrl:CheckBlessTimer(multi_mount_data_list)
	if multi_mount_data_list == nil then
		self:OperaBlessTimer(true)
		return
	end

	local is_check = false
	if TipsCommonAutoView.AUTO_VIEW_STR_T["multi_mount_remind"] and TipsCommonAutoView.AUTO_VIEW_STR_T["multi_mount_remind"].is_auto_buy then
		self:OperaBlessTimer(true)
		return
	end

	local check_grade = self.data:GetRemindGrade()
	for k,v in pairs(multi_mount_data_list) do
		if v ~= nil and v.grade_bless > 0 and v.grade >= check_grade then
			is_check = true
			break
		end
	end

	self:OperaBlessTimer(not is_check)
end

function MultiMountCtrl:OperaBlessTimer(is_relese)
	if is_relese then
		if self.bless_timer_list ~= nil then
			for k,v in pairs(self.bless_timer_list) do
				if v ~= nil then
					GlobalTimerQuest:CancelQuest(v)
				end
			end

			self.bless_timer_list = nil
		end
	else
		if self.bless_timer_list == nil then
			self.bless_timer_list = {}

			local function timer_call(key)
				if key ~= nil and self.bless_timer_list ~= nil and self.bless_timer_list[key] ~= nil then
					GlobalTimerQuest:CancelQuest(self.bless_timer_list[key])
					self.bless_timer_list[key] = nil
					if next(self.bless_timer_list) == nil then
						self.bless_timer_list = nil
					end
					-- local date = os.date("*t", TimeCtrl.Instance:GetServerTime())
					-- local cur_data = nil
					-- if date ~= nil then
					-- 	cur_data = date.hour * 3600 + date.min * 60 + date.sec
					-- end

					-- if cur_data ~= nil then
					-- 	local delay = 24 * 3600 - cur_data + key
					-- 	self.bless_timer_list[key] = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(timer_call, key), delay)
					-- end 
					TipsCtrl.Instance:ShowCommonAutoView("multi_mount_remind", Language.Advance.MultiRemind, function (is_auto)
						ViewManager.Instance:Open(ViewName.Advance, TabIndex.multi_mount_jinjie)
						if is_auto then
							if self.bless_timer_list ~= nil then
								for k,v in pairs(self.bless_timer_list) do
									if v ~= nil then
										GlobalTimerQuest:CancelQuest(v)
									end
								end

								self.bless_timer_list = nil
							end							
						end
					end)
				end
			end

			local timer = self.data:GetRemindTimer()
			if timer ~= nil then
				for k,v in pairs(timer) do
					self.bless_timer_list[k] = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(timer_call, v), v)
				end
			end
		end
	end
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