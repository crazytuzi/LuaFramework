TipsCongratulationView = TipsCongratulationView or BaseClass(BaseView)
function TipsCongratulationView:__init()
	self.ui_config = {"uis/views/congratulate_prefab", "CongratulationTip"}
	self.view_layer = UiLayer.Pop
	self.is_auto = false
	self.can_show_auto = true
	self.auto_view_str = ""
	self.ok_str = ""
	self.canel_str = ""
	self.play_audio = true
	self.is_special = false
end

function TipsCongratulationView:LoadCallBack()
	self:ListenEvent("CloseWindow",
		BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("SendEgg",
		BindTool.Bind(self.SendEgg, self))
	self:ListenEvent("SendFlower",
		BindTool.Bind(self.SendFlower, self))

	self.image_obj = self:FindObj("image_obj")
	self.raw_image_obj = self:FindObj("raw_image_obj")
	self.rich_text = self:FindObj("decs")
	self.check = self:FindObj("Check")
	self.image_res = self:FindVariable("TouxiangImg")

	self.check.toggle:AddValueChangedListener(BindTool.Bind(self.ChangeAuto, self))
	self.role_info_event = GlobalEventSystem:Bind(OtherEventType.RoleInfo,
		BindTool.Bind(self.RoleInfoChange, self))
end

function TipsCongratulationView:ReleaseCallBack()
	self.image_obj = nil
	self.raw_image_obj = nil
	self.check = nil
	self.rich_text = nil
	self.image_res = nil
	GlobalEventSystem:UnBind(self.role_info_event)
end

function TipsCongratulationView:CloseCallBack()
	self.role_info = nil
end

function TipsCongratulationView:OpenCallBack()
	local friendid = CongratulationData.Instance:GetTips().uid
	CheckCtrl.Instance:SendQueryRoleInfoReq(friendid)
	self:Flush()
	CongratulationCtrl.Instance:SetTipShow()
end

function TipsCongratulationView:CloseWindow()
	self.is_auto = false
	CongratulationData.Instance:ClearTips()
	self:Close()
end

function TipsCongratulationView:SendFlower()
	CongratulationCtrl.Instance:SendReq(self.friendid, CONGRATULATION_TYPE.FLOWER)
	if self.is_auto then
		CongratulationData.Instance:SetAuto(self.is_auto, CONGRATULATION_TYPE.FLOWER)
	end
	self:CloseWindow()
end

function TipsCongratulationView:SendEgg()
	CongratulationCtrl.Instance:SendReq(self.friendid,CONGRATULATION_TYPE.EGG)
	if self.is_auto then
		CongratulationData.Instance:SetAuto(self.is_auto,CONGRATULATION_TYPE.EGG)
	end
	self:CloseWindow()
end

function TipsCongratulationView:OnFlush()
	self.tips_data = CongratulationData.Instance:GetTips()
	self.heli_type = self.tips_data.heli_type
	self.friendid = self.tips_data.uid
	self.param1 = self.tips_data.param1
	self.param2 = self.tips_data.param2
	self:SetShowDec()
	self:FlushHead()
end

function TipsCongratulationView:SetShowDec()
	local friend_name = ScoietyData.Instance:GetFriendNameById(self.friendid)
	local context = self.rich_text:GetComponent(typeof(RichTextGroup))

	if self.heli_type == SC_FRIEND_HELI_REQ_YTPE.SC_FRIEND_HELI_UPLEVEL_REQ then
		local des = string.format(Language.Congratulation.TipContext1, friend_name,self.param1)
		RichTextUtil.ParseRichText(context, des, nil, COLOR.BLACK_1, nil, nil, 24)
	elseif self.heli_type == SC_FRIEND_HELI_REQ_YTPE.SC_FRIEND_HELI_SKILL_BOSS_FETCH_EQUI_REQ then
		local des2 = string.format(Language.Congratulation.TipContext3,friend_name, self.param1, self.param2)
		RichTextUtil.ParseRichText(context, des2, nil, COLOR.BLACK_1, nil, nil, 24)
	end
end

function TipsCongratulationView:FlushHead()
	if self.role_info == nil then return end
	local role_id = self.role_info.role_id or 0
	local prof = self.role_info.prof or 1
	local sex = self.role_info.sex or 1
	AvatarManager.Instance:SetAvatarKey(role_id, self.role_info.avatar_key_big, self.role_info.avatar_key_small)
	local avatar_path_small = AvatarManager.Instance:GetAvatarKey(role_id)
	CommonDataManager.SetAvatar(role_id, self.raw_image_obj, self.image_obj, self.image_res, sex, prof, true)

end

function TipsCongratulationView:ChangeAuto(ison)
	self.is_auto = ison
end

--查看角色有变化时
function TipsCongratulationView:RoleInfoChange(role_id, role_info)
	if self.friendid == role_id then
		self.role_info = role_info
		self:Flush()
	end
end
