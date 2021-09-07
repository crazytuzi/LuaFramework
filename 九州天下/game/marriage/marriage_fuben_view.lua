MarriageFuBenView = MarriageFuBenView or BaseClass(BaseRender)

function MarriageFuBenView:__init(instance, mother_view)
	self.mother_view = mother_view

	self.can_enter_times = self:FindVariable("CanEnterTimes")
	self.can_buy_times = self:FindVariable("CanBuyTimes")
	self.diamond = self:FindVariable("Diamond")
	self.is_lover_in_team = self:FindVariable("IsLoverInTeam")
	self.self_name = self:FindVariable("SelfName")
	self.self_power = self:FindVariable("SelfPower")
	self.lover_name = self:FindVariable("LoverName")
	self.lover_power = self:FindVariable("LoverPower")
	self.self_def_icon = self:FindVariable("SelfDefIcon")
	self.lover_def_icon = self:FindVariable("LoverDefIcon")
	self.set_can_invite = self:FindVariable("SetCanInvite")

	self.self_image = self:FindObj("SelfImage")
	self.lover_image = self:FindObj("LoverImage")
	self.reward_list = {}
	self.reward_node_list = {}
	local obj_group = self:FindObj("ObjGroup")
	local child_number = obj_group.transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = obj_group.transform:GetChild(i).gameObject
		if string.find(obj.name, "ItemCell") ~= nil then
			self.reward_node_list[count] = obj
			self.reward_list[count] = ItemCellReward.New()
			self.reward_list[count]:SetInstanceParent(obj)
			count = count + 1
		end
	end

	self:ListenEvent("EnterClick", BindTool.Bind(self.ButtonClick, self))
	self:ListenEvent("BuyClick", BindTool.Bind(self.BuyClick, self))
	self:ListenEvent("ExitClick", BindTool.Bind(self.ExitClick, self))
	self:ListenEvent("InviteClick", BindTool.Bind(self.InviteClick, self))
	self:ListenEvent("OpenHelp", BindTool.Bind(self.OpenHelp, self))

	self.max_buy_times = MarriageData.Instance:GetMarriageConditions().fb_buy_times_limit
	self.diamond:SetValue(MarriageData.Instance:GetMarriageConditions().fb_buy_times_gold_cost)
	for k,v in pairs(self.reward_node_list) do
		v:SetActive(false)
	end
	local rewards = MarriageData.Instance:GetQingYuanFBReward()

	count = 1
	for k,v in pairs(rewards) do
		self.reward_node_list[count]:SetActive(true)
		local data = {}
		data.item_id = k
		self.reward_list[count]:SetData(data)
		count = count + 1
	end
	self.call = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.LoverInfoChange, self))
	self.call2 = GlobalEventSystem:Bind(OtherEventType.TEAM_INFO_CHANGE, BindTool.Bind(self.TeamChage, self))
end

function MarriageFuBenView:ShowOrHideTab()
end

function MarriageFuBenView:TeamChage()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local lover_in_team = false
	local list = ScoietyData.Instance:GetTeamUserList()
	for k,v in pairs(list) do
		if v == main_role_vo.lover_uid then
			lover_in_team = true
			break
		end
	end
	self.is_lover_in_team:SetValue(lover_in_team)
	if lover_in_team then
		CheckCtrl.Instance:SendQueryRoleInfoReq(main_role_vo.lover_uid)
	end
end

function MarriageFuBenView:LoverInfoChange(id, info)
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local lover_id = main_vo.lover_uid
	if lover_id == nil or lover_id == 0 then
		return
	end
	if id == lover_id then
		self.lover_name:SetValue(main_vo.lover_name)
		self.lover_power:SetValue(info.capability)
		local data = {}
		data.id = lover_id
		data.prof = info.prof
		data.sex = info.sex
		data.avatar_key_big = info.avatar_key_big
		data.avatar_key_small = info.avatar_key_small
		self:LoadHeadIcon(data, self.lover_def_icon, self.lover_image)
	end
end

function MarriageFuBenView:__delete()
	if self.reward_list then
		for k,v in pairs(self.reward_list) do
			v:DeleteMe()
		end
		self.reward_list = {}
	end
	GlobalEventSystem:UnBind(self.call)
	GlobalEventSystem:UnBind(self.call2)
end

function MarriageFuBenView:ExitClick()
	ScoietyCtrl.Instance:ExitTeamReq()
end

function MarriageFuBenView:InviteClick()
	if not ScoietyData.Instance:GetTeamState() then
		local param_t = {}
		param_t.must_check = 0
		param_t.assign_mode = 2
		ScoietyCtrl.Instance:CreateTeamReq(param_t)
		-- ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
	end
	ScoietyCtrl.Instance:InviteUserReq(GameVoManager.Instance:GetMainRoleVo().lover_uid)
end

--打开帮助
function MarriageFuBenView:OpenHelp()
	local tips_id = 73		--策划随便定义的
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function MarriageFuBenView:ButtonClick()
	local data = MarriageData.Instance:GetQingYuanFBInfo()
	if data.join_fb_times <= 0 or data.buy_fb_join_times >= data.join_fb_times then
		--够次数
		local list = ScoietyData.Instance:GetTeamInfo()
		if list == nil or next(list) == nil then
			TipsCtrl.Instance:ShowSystemMsg(Language.Society.NotTeam)
			return
		end
		if list.member_count ~= 2 then
			TipsCtrl.Instance:ShowSystemMsg(Language.Society.TeamNotEnough)
			return
		end
		FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_QINGYUAN)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.NotEnterTime)
	end
end

function MarriageFuBenView:BuyClick()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.lover_name == nil or main_role_vo.lover_name == "" then
		TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.MarryToBuyTimes)
		return
	end

	local data = MarriageData.Instance:GetQingYuanFBInfo()
	if data.buy_fb_join_times >= self.max_buy_times then
		--不能买
		TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.RestToOnly .. ToColorStr(self.max_buy_times, TEXT_COLOR.GREEN).."次")
	else
		--能买
		local reset_cost = MarriageData.Instance:GetMarriageConditions().fb_buy_times_gold_cost
		local str = string.format(Language.Marriage.ResetFuBen, ToColorStr(reset_cost, TEXT_COLOR.BLUE))
		local click_func = function ()
			MarriageCtrl.Instance:SendRestFuBenTimes()
		end
		TipsCtrl.Instance:ShowCommonAutoView("marriage_fuben", str, click_func, nil, true, nil, nil, Language.FB.ExpFbResetTimesRedStr)
	end
end

function MarriageFuBenView:OnFlush()
	local data = MarriageData.Instance:GetQingYuanFBInfo()
	if data == nil or next(data) == nil then
		return
	end
	
	if data.join_fb_times <= 0 then
		self.can_enter_times:SetValue(data.buy_fb_join_times + 1)
	else
		local des = data.buy_fb_join_times - data.join_fb_times
		self.can_enter_times:SetValue(des >= 0 and des + 1 or 0)
	end
	self.can_buy_times:SetValue(self.max_buy_times - data.buy_fb_join_times)

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	self.self_name:SetValue(main_role_vo.name)
	self.self_power:SetValue(main_role_vo.capability)

	data = {}
	data.id = main_role_vo.role_id
	data.prof = main_role_vo.prof
	data.sex = main_role_vo.sex
	data.avatar_key_big = main_role_vo.avatar_key_big
	data.avatar_key_small = main_role_vo.avatar_key_small
	self:LoadHeadIcon(data, self.self_def_icon, self.self_image)
	self:TeamChage()
	self.set_can_invite:SetValue(main_role_vo.lover_uid and main_role_vo.lover_uid > 0)
end

function MarriageFuBenView:LoadHeadIcon(data, def_icon, sp_icon)
	AvatarManager.Instance:SetAvatarKey(data.id, data.avatar_key_big, data.avatar_key_small)
	local avatar_path_small = AvatarManager.Instance:GetAvatarKey(data.id)
	if AvatarManager.Instance:isDefaultImg(data.id) == 0 or avatar_path_small == 0 then
		sp_icon.gameObject:SetActive(false)
		local bundle, asset = AvatarManager.GetDefAvatar(data.prof, false, data.sex)
		def_icon:SetAsset(bundle, asset)
	else
		local function callback(path)
			if path == nil then
				path = AvatarManager.GetFilePath(data.id, false)
			end
			sp_icon.raw_image:LoadSprite(path, function ()
				def_icon:SetAsset("", "")
				sp_icon.gameObject:SetActive(true)
			end)
		end
		AvatarManager.Instance:GetAvatar(data.id, false, callback)
	end
end