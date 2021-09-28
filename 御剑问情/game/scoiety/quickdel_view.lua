QuickDelView = QuickDelView or BaseClass(BaseView)
function QuickDelView:__init()
	self.ui_config = {"uis/views/scoietyview_prefab", "QuickClearView"}
end

function QuickDelView:__delete()

end

function QuickDelView:ReleaseCallBack()
	self.check_intimacy = nil
	self.check_friendlev = nil
	self.check_offline = nil
	self.input_intimacy = nil
	self.input_lev = nil
	self.input_day = nil
end

function QuickDelView:LoadCallBack()
	self.is_intimacy = true
	self.is_lev = true
	self.is_offline = true

	self.check_intimacy = self:FindObj("CheckIntimacy")
	self.check_friendlev = self:FindObj("CheckFriendLev")
	self.check_offline = self:FindObj("CheckOffLine")
	self.input_intimacy = self:FindObj("InputIntimacy")
	self.input_lev = self:FindObj("InputLev")
	self.input_day = self:FindObj("InputDay")


	self:ListenEvent("Close", BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("ClickClear", BindTool.Bind(self.ClickClear, self))

	self:ListenEvent("ClickIntimacy", BindTool.Bind(self.ClickInput, self, 1))
	self:ListenEvent("ClickLevel", BindTool.Bind(self.ClickInput, self, 2))
	self:ListenEvent("ClickLeaveDay", BindTool.Bind(self.ClickInput, self, 3))

	self.check_intimacy.toggle:AddValueChangedListener(BindTool.Bind(self.CheckIntimacy, self))
	self.check_friendlev.toggle:AddValueChangedListener(BindTool.Bind(self.CheckFriendLev, self))
	self.check_offline.toggle:AddValueChangedListener(BindTool.Bind(self.CheckOffLine, self))
end

function QuickDelView:OpenCallBack()
	self.check_intimacy.toggle.isOn = true
	self.check_friendlev.toggle.isOn = true
	self.check_offline.toggle.isOn = true
end

function QuickDelView:CloseWindow()
	self:Close()
end

function QuickDelView:CloseCallBack()

end

function QuickDelView:ChangeInput(param, text)
	if param == 1 then
		self.input_intimacy.input_field.text = text
	elseif param == 2 then
		self.input_lev.input_field.text = text
	elseif param == 3 then
		self.input_day.input_field.text = text
	end
end

function QuickDelView:ClickInput(param)
	local max_num = 9999
	local normal_str = ""
	if param == 1 then
		normal_str = self.input_intimacy.input_field.text
	elseif param == 2 then
		max_num = 1000
		normal_str = self.input_lev.input_field.text
	elseif param == 3 then
		normal_str = self.input_day.input_field.text
	end
	TipsCtrl.Instance:OpenCommonInputView(normal_str, BindTool.Bind(self.ChangeInput, self, param), nil, max_num)
end

function QuickDelView:ClickClear()
	local intimacy = self.input_intimacy.input_field.text
	local lev = self.input_lev.input_field.text
	local day = self.input_day.input_field.text

	if not self.is_intimacy and not self.is_lev and not self.is_offline then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.IsSelectNull)
		return
	end

	if intimacy == "" and self.is_intimacy then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.IntimacyDes)
		return
	elseif lev == "" and self.is_lev then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.LevDes)
		return
	elseif day == "" and self.is_offline then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.OfflineDes)
		return
	end

	local friend_info = ScoietyData.Instance:GetFriendInfo()
	if not next(friend_info) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.NotFriendList)
		return
	end
	-- 提取符合条件的玩家
	local clear_list = {}
	for k,v in ipairs(friend_info) do
		local leave_time = math.ceil(TimeCtrl.Instance:GetServerTime()) - v.last_logout_timestamp
		local leave_day = math.floor((leave_time / 3600) / 24)
		if (self.is_intimacy and v.intimacy < tonumber(intimacy)) or (self.is_lev and v.level < tonumber(lev)) or (self.is_offline and leave_day > tonumber(day)) then
			table.insert(clear_list, v)
		end
	end
	--没有符合条件的玩家
	if not next(clear_list) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.NotAccordFriend)
		return
	end
	-- 循环删除
	for k,v in ipairs(clear_list) do
		ScoietyCtrl.Instance:DeleteFriend(v.user_id)
	end
end

function QuickDelView:CheckIntimacy(ison)
	self.is_intimacy = ison
end

function QuickDelView:CheckFriendLev(ison)
	self.is_lev = ison
end

function QuickDelView:CheckOffLine(ison)
	self.is_offline = ison
end