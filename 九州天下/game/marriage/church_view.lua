ChurchView = ChurchView or BaseClass(BaseView)

function ChurchView:__init()
	self.ui_config = {"uis/views/marriageview","ChurchView"}
end

function ChurchView:__delete()

end

function ChurchView:LoadCallBack()
	self.is_show_help = self:FindVariable("IsShowHelp")
	self.is_show_help:SetValue(false)

	self:ListenEvent("Close",BindTool.Bind(self.ClickClose, self))
	self:ListenEvent("HelpClick",BindTool.Bind(self.HelpClick, self))
	self:ListenEvent("CloseHelp",BindTool.Bind(self.CloseHelp, self, false))
	self:ListenEvent("MarryClick",BindTool.Bind(self.MarryClick, self))
	self:ListenEvent("DivorceClick",BindTool.Bind(self.DivorceClick, self, false))
end

function ChurchView:ReleaseCallBack()

end

function ChurchView:ClickClose()
	self:Close()
end

function ChurchView:HelpClick()
	local tips_id = 70 -- 婚宴帮助
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ChurchView:CloseHelp()
	self.is_show_help:SetValue(false)
end

function ChurchView:MarryClick()
	local list = ScoietyData.Instance:GetTeamInfo()

	if list == nil or next(list) == nil then
		TipsCtrl.Instance:ShowSystemMsg("当前状态未组队")
		return
	end

	if list.member_count ~= 2 then
		TipsCtrl.Instance:ShowSystemMsg("当前队伍人数不为2人")
		return
	end

	local friden_info = nil
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	for k,v in pairs(list.team_member_list) do
		if main_role_vo.name ~= v.name then
			friden_info = v
		end
	end

	local friend_data = ScoietyData.Instance:GetFriendInfoByName(friden_info.name)

	local conditions = MarriageData.Instance:GetMarriageConditions()
	if friend_data == nil then
		TipsCtrl.Instance:ShowSystemMsg("男女双方需要是好友关系")
		return
	end
	if friend_data.intimacy < conditions.marry_limit_intimacy then
		TipsCtrl.Instance:ShowSystemMsg("当前亲密度不足"..conditions.marry_limit_intimacy)
		return
	end

	for k,v in pairs(list.team_member_list) do
		if v.level < conditions.marry_limit_level then
			TipsCtrl.Instance:ShowSystemMsg("男女双方均达到"..conditions.marry_limit_level.."级方可结婚")
			return
		end
	end

	local tmp_sex = nil
	for k,v in pairs(list.team_member_list) do
		if tmp_sex == nil then
			tmp_sex = v.sex
		else
			if tmp_sex == v.sex then
				TipsCtrl.Instance:ShowSystemMsg("当前队伍应互为异性")
				return
			end
		end
	end
	MarriageCtrl.Instance:SendMarryReq(friend_data.user_id)
end

function ChurchView:DivorceClick()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.lover_name == nil or main_role_vo.lover_name == "" then
		TipsCtrl.Instance:ShowSystemMsg("当前状态未结婚")
		return
	end

	local is_online = ScoietyData.Instance:GetFriendIsOnlineById(main_role_vo.lover_uid)
	local divorce_intimacy_dec = MarriageData.Instance:GetIntimacyCost()

	if is_online == 1 then
		local function func()
			MarriageCtrl.Instance:SendDivorceReq(0)
		end
		local des = string.format(Language.Marriage.DivorceQuestionDes, main_role_vo.lover_name, divorce_intimacy_dec)
		TipsCtrl.Instance:ShowCommonAutoView("", des, func)
	else
		local function ok_func()
			MarriageCtrl.Instance:SendDivorceReq(1)
		end
		local diamond_cost = MarriageData.Instance:GetDivorceCost()
		local des = string.format(Language.Marriage.OneSideDivorceQuestion, diamond_cost, divorce_intimacy_dec)
		TipsCtrl.Instance:ShowCommonAutoView("", des, ok_func)
	end

	-- local list = ScoietyData.Instance:GetTeamInfo()

	-- if list == nil or next(list) == nil then
	-- 	--未组队
	-- 	MarriageCtrl.Instance:ShowOneSidedDivorceOrNotTips()
	-- 	return
	-- end

	-- if list.member_count ~= 2 then
	-- 	--队伍人数不为2人
	-- 	MarriageCtrl.Instance:ShowOneSidedDivorceOrNotTips()
	-- 	return
	-- end

	-- local friden_info = nil
	-- for k,v in pairs(list.team_member_list) do
	-- 	if main_role_vo.name ~= v.name then
	-- 		friden_info = v
	-- 		break
	-- 	end
	-- end
	-- if friden_info.name ~= main_role_vo.lover_name then
	-- 	--队友不是结婚对象
	-- 	MarriageCtrl.Instance:ShowOneSidedDivorceOrNotTips()
	-- 	return
	-- end
end
