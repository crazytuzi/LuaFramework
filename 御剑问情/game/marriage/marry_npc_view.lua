MarryNpcView = MarryNpcView or BaseClass(BaseView)

function MarryNpcView:__init()
	self.ui_config = {"uis/views/marriageview_prefab","MarryNpcView"}
end

function MarryNpcView:__delete()

end

function MarryNpcView:LoadCallBack()
	self:ListenEvent("OnMarryYuyueBtn", BindTool.Bind(self.OnMarryYuyueBtn, self))
	self:ListenEvent("OnMarryJiehunBtn", BindTool.Bind(self.OnMarryJiehunBtn, self))
	self:ListenEvent("OnMarryLihunBtn", BindTool.Bind(self.OnMarryLihunBtn, self))
	self:ListenEvent("OnMarryLeaveBtn", BindTool.Bind(self.OnMarryLeaveBtn, self))
end

function MarryNpcView:OnMarryYuyueBtn()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.lover_name == nil or main_role_vo.lover_name == "" then
		TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.Not_Marry)
		return
	end
	local hunyan_seq = MarriageData.Instance:GetYuYueRoleInfo().param_ch4
	if hunyan_seq > 0 then
		ViewManager.Instance:Open(ViewName.WeddingYuYueView)
	else
		ViewManager.Instance:Open(ViewName.MarriageWedding)
	end
end

function MarryNpcView:OnMarryJiehunBtn()
	local is_open, tips = OpenFunData.Instance:CheckIsHide("marriage")
	if is_open then
		self:Close()
		ViewManager.Instance:Open(ViewName.Wedding)
	else
		if tips then
			SysMsgCtrl.Instance:ErrorRemind(tips)
		end
	end
end

function MarryNpcView:OnMarryLihunBtn()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.lover_name == nil or main_role_vo.lover_name == "" then
		TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.Not_Marry)
		return
	end

	local is_online = ScoietyData.Instance:GetFriendIsOnlineById(main_role_vo.lover_uid)
	local divorce_intimacy_dec = MarriageData.Instance:GetIntimacyCost()

	if is_online == 1 then
		local function func()
			MarriageCtrl.Instance:SendDivorceReq(1)
		end
		local des = string.format(Language.Marriage.DivorceQuestionDes, main_role_vo.lover_name)
		TipsCtrl.Instance:ShowCommonAutoView("", des, func)
	else
		local function ok_func()
			MarriageCtrl.Instance:SendDivorceReq(1)
		end
		-- local diamond_cost = MarriageData.Instance:GetDivorceCost()
		local des = string.format(Language.Marriage.OneSideDivorceQuestion)
		TipsCtrl.Instance:ShowCommonAutoView("", des, ok_func)
	end
end

function MarryNpcView:OnMarryLeaveBtn()
	self:Close()
end
