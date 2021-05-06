local COrgChamberInfoPage = class("COrgChamberInfoPage", CPageBase)

function COrgChamberInfoPage.ctor(self, cb)
	CPageBase.ctor(self, cb)
end

function COrgChamberInfoPage.OnInitPage(self)
	self.m_ApproveBtn = self:NewUI(1, CButton)
	self.m_ExitBtn = self:NewUI(2, CButton)
	self.m_OrgInfoPart = self:NewUI(3, CBox)
	self.m_EditBtn = self:NewUI(4, CButton)
	self.m_ChangeFlagBtn = self:NewUI(5, CButton)
	self.m_UpgradeBtn = self:NewUI(6, CButton)
	self.m_UpgradeTween = self.m_UpgradeBtn:GetComponent(classtype.TweenScale)
	self.m_EditAimPart = self:NewUI(7, CBox)
	self.m_HuiZhangExitBtn = self:NewUI(8, CButton)
	self.m_EmailBtn = self:NewUI(9, CButton)
	self.m_EmailPart = self:NewUI(10, COrgEmailPart)
	self:InitContent()
end

function COrgChamberInfoPage.InitContent(self)
	self.m_InitInfoBox = self:InitInfoPart()
	self.m_EditAimBox = self:CreateEditAimPart()
	self.m_ApproveBtn.m_IgnoreCheckEffect = true

	self.m_ApproveBtn:AddUIEvent("click", callback(self, "OnClickApprove"))
	self.m_ExitBtn:AddUIEvent("click", callback(self, "OnExit"))
	self.m_EditBtn:AddUIEvent("click", callback(self, "OnEdit"))
	self.m_ChangeFlagBtn:AddUIEvent("click", callback(self, "OnChangeFlag"))
	self.m_UpgradeBtn:AddUIEvent("click", callback(self, "OnUpgrade"))
	self.m_HuiZhangExitBtn:AddUIEvent("click", callback(self, "OnHuiZhangExit"))
	self.m_EmailBtn:AddUIEvent("click", callback(self, "OnEmail"))
	self.m_InitInfoBox:RefreshUI()
	self:SetLimitData()
	self:CheckRedDot()
	self:CheckQQPlugin()
	
	g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
	g_QQPluginCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnQQPluginEvent"))
end

function COrgChamberInfoPage.OnQQPluginEvent(self)
	self:DelayCall(0, "CheckQQPlugin")
end

function COrgChamberInfoPage.CheckQQPlugin(self)
	local bPresident = (g_AttrCtrl.org_pos == 1)
	if g_QQPluginCtrl:IsQQLogin() then
		local guildId = tostring(g_AttrCtrl.org_id)
		local guildName = g_AttrCtrl.orgname
		local dServer = g_LoginCtrl:GetConnectServer()
		local zoneId = tostring(g_ServerCtrl:ServerKeyToNumer(dServer.server_id))
		local roleId = tostring(g_AttrCtrl.pid)
		if g_QQPluginCtrl:HasBindQQGroup() then
			if g_QQPluginCtrl:IsRelation(define.QQPlugin.Relation.QunZhu) then
				self.m_InitInfoBox.m_BindQQLabel:SetText("[u]解绑Q群[-]")
				self.m_InitInfoBox.m_BindQQLabel:AddUIEvent("click", function()
						-- g_NotifyCtrl:FloatMsg("解绑Q群") 
						g_AndroidCtrl:UnBindGroup(guildId, zoneId, roleId)
					end)
			elseif g_QQPluginCtrl:HasJoinQQGroup() then
				self.m_InitInfoBox.m_BindQQLabel:SetText("(已加Q群)")
					self.m_InitInfoBox.m_BindQQLabel:AddUIEvent("click", function() 
							g_NotifyCtrl:FloatMsg("已加入Q群, 进入APP可以退出") 
						end)
			else
				self.m_InitInfoBox.m_BindQQLabel:SetText("[u]加入Q群[-]")
				self.m_InitInfoBox.m_BindQQLabel:AddUIEvent("click", function()
						-- g_NotifyCtrl:FloatMsg("加入Q群") 
						g_AndroidCtrl:GameJoinQQGroup(guildId, zoneId, roleId)
					end)
			end
			self.m_InitInfoBox.m_BindQQLabel:SetActive(true)
			return
		elseif bPresident then
			self.m_InitInfoBox.m_BindQQLabel:SetText("[u]绑定Q群[-]")
			self.m_InitInfoBox.m_BindQQLabel:AddUIEvent("click", function() 
					-- g_NotifyCtrl:FloatMsg("绑定Q群") 
					g_AndroidCtrl:GameBindGroup(guildId, zoneId, guildName, roleId)
				end)
			self.m_InitInfoBox.m_BindQQLabel:SetActive(true)
			return
		end
	end
	self.m_InitInfoBox.m_BindQQLabel:SetActive(false)
	self.m_InitInfoBox.m_BindQQLabel:AddUIEvent("click", nil)
end

function COrgChamberInfoPage.InitInfoPart(self)
	local oInfoPart = self.m_OrgInfoPart
	oInfoPart.m_AimLabel = oInfoPart:NewUI(1, CLabel)
	oInfoPart.m_FlagLabel = oInfoPart:NewUI(2, CLabel)
	oInfoPart.m_NameLabel = oInfoPart:NewUI(3, CLabel)
	oInfoPart.m_GradeLabel = oInfoPart:NewUI(4, CLabel)
	oInfoPart.m_PresidentLabel = oInfoPart:NewUI(5, CLabel)
	oInfoPart.m_MemberLabel = oInfoPart:NewUI(6, CLabel)
	oInfoPart.m_ExpLabel = oInfoPart:NewUI(7, CLabel)
	oInfoPart.m_PrestigeLabel = oInfoPart:NewUI(8, CLabel)
	oInfoPart.m_RankLabel = oInfoPart:NewUI(9, CLabel)
	oInfoPart.m_FlagBgSprite = oInfoPart:NewUI(10, CSprite)
	oInfoPart.m_IDLabel = oInfoPart:NewUI(11, CLabel)
	oInfoPart.m_ActiveLabel = oInfoPart:NewUI(12, CLabel)
	oInfoPart.m_CashLabel = oInfoPart:NewUI(13, CLabel)
	oInfoPart.m_ExpSlider = oInfoPart:NewUI(14, CSlider)
	oInfoPart.m_BindQQLabel = oInfoPart:NewUI(15, CLabel)
	oInfoPart.m_ParentView = self
	local oHintData = data.orgdata.Hint
	oInfoPart.m_MemberLabel:SetOrgHint(oHintData.memcnt.title, oHintData.memcnt.hint, enum.UIAnchor.Side.Right)
	oInfoPart.m_PrestigeLabel:SetOrgHint(oHintData.prestige.title, oHintData.prestige.hint, enum.UIAnchor.Side.Right)
	oInfoPart.m_RankLabel:SetOrgHint(oHintData.rank.title, oHintData.rank.hint, enum.UIAnchor.Side.Right)
	oInfoPart.m_ActiveLabel:SetOrgHint(oHintData.active_point.title, oHintData.active_point.hint, enum.UIAnchor.Side.Right)
	oInfoPart.m_CashLabel:SetOrgHint(oHintData.cash.title, oHintData.cash.hint, enum.UIAnchor.Side.Right)

	function oInfoPart.RefreshUI(self)
		local oData = g_OrgCtrl:GetMyOrgInfo()
		oInfoPart.m_AimLabel:SetText(oData.aim)
		oInfoPart.m_NameLabel:SetText(oData.name)
		oInfoPart.m_GradeLabel:SetText("公会等级:" .. oData.level)
		oInfoPart.m_PresidentLabel:SetText("公会会长:" .. oData.leadername)
		oInfoPart.m_MemberLabel:SetText(string.format("[u]公会人数[/u]:%d/%d", oData.memcnt, g_OrgCtrl:GetMaxMember(oData.level)))
		oInfoPart.m_ExpLabel:SetText(string.format("%s/%s", oData.exp, g_OrgCtrl:GetLvUpExpNeed(oData.level)))
		oInfoPart.m_ExpSlider:SetValue(oData.exp / g_OrgCtrl:GetLvUpExpNeed(oData.level))
		oInfoPart.m_PrestigeLabel:SetText("[u]公会声望[/u]:" .. oData.prestige)
		if oData.rank == 0 then
			oInfoPart.m_RankLabel:SetText("[u]公会排名[/u]:未上榜")
		else
			oInfoPart.m_RankLabel:SetText("[u]公会排名[/u]:" .. oData.rank)
		end
		oInfoPart.m_IDLabel:SetText("公会ID:" .. oData.orgid)
		local str = nil
		if oData.active_point > g_OrgCtrl:GetOrgGradeData(oData.level).active_point then
			str = "[715A48][u]公会活跃[/u]:[1B9880]"
		else
			str = "[715A48][u]公会活跃[/u]:[DB5B4D]"
		end
		oInfoPart.m_ActiveLabel:SetText(str .. oData.active_point)
		oInfoPart.m_CashLabel:SetText("[u]公会资金[/u]:" .. oData.cash)
		oInfoPart.m_FlagLabel:SetText(oData.sflag)
		oInfoPart.m_FlagBgSprite:SetSpriteName(g_OrgCtrl:GetFlagIcon(oData.flagbgid))
		oInfoPart.m_ParentView.m_UpgradeTween.enabled = (oData.exp >= g_OrgCtrl:GetLvUpExpNeed(oData.level))
	end
	return oInfoPart
end

function COrgChamberInfoPage.OnEmail(self)
	if g_OrgCtrl:GetMyOrgInfo().mail_rest > 0 then
		self.m_EmailPart:ShowEdit()
	else
		g_NotifyCtrl:FloatMsg(string.format("每天仅可发放%s次通知，请于明天再来发放", g_OrgCtrl:GetRule().mail_cnt))
	end
end

function COrgChamberInfoPage.SetLimitData(self)
	self.m_Limit = g_OrgCtrl:GetPosition(g_AttrCtrl.org_pos)
	if self.m_Limit.exit_tips == COrgCtrl.HuiZhangExitTip and g_OrgCtrl:GetMyOrgInfo().memcnt > 1 then
		self.m_HuiZhangExitBtn:SetActive(true)
		self.m_ExitBtn:SetActive(false)
	else
		self.m_HuiZhangExitBtn:SetActive(false)
		self.m_ExitBtn:SetActive(true)
	end
	self.m_EditBtn:SetActive(self.m_Limit.edit_aim == COrgCtrl.Has_Power)
	self.m_ChangeFlagBtn:SetActive(self.m_Limit.edit_flag == COrgCtrl.Has_Power)
	self.m_UpgradeBtn:SetActive(self.m_Limit.upgrade == COrgCtrl.Has_Power)
	self.m_ApproveBtn:SetActive(self.m_Limit.agree_reject_join == COrgCtrl.Has_Power)
	self.m_EmailBtn:SetActive(self.m_Limit.mail == COrgCtrl.Has_Power)
end

function COrgChamberInfoPage.NotOpen(self)
	g_NotifyCtrl:FloatMsg("该功能暂未开放")
end

function COrgChamberInfoPage.CreateEditAimPart(self)
	local oEditPart = self.m_EditAimPart
	oEditPart.m_CloseBtn = oEditPart:NewUI(1, CButton)
	oEditPart.m_AimInput = oEditPart:NewUI(2, CInput)
	oEditPart.m_SubmitBtn = oEditPart:NewUI(3, CButton)
	oEditPart.m_CloseBtn:AddUIEvent("click", callback(self, "OnCloseEditAim"))
	oEditPart.m_SubmitBtn:AddUIEvent("click", callback(self, "OnSumbitEditAim"))
	function oEditPart.ShowEdit(self)
		oEditPart:SetActive(true)
		oEditPart.m_AimInput:SetText(g_OrgCtrl:GetMyOrgInfo().aim)
	end
	return oEditPart
end

function COrgChamberInfoPage.OnCloseEditAim(self)
	self.m_EditAimBox:SetActive(false)
end

function COrgChamberInfoPage.OnSumbitEditAim(self)
	local AimStr = self.m_EditAimBox.m_AimInput:GetText()
	local len = #CMaskWordTree:GetCharList(AimStr)

	if AimStr == "" then
		g_NotifyCtrl:FloatMsg("请输入内容")
	elseif len > g_OrgCtrl:GetRule().max_aim_len then
		g_NotifyCtrl:FloatMsg(string.format("长度超出%s字符", g_OrgCtrl:GetRule().max_aim_len))
	elseif g_MaskWordCtrl:IsContainMaskWord(AimStr) then
		g_NotifyCtrl:FloatMsg("内容存在敏感词，请重新输入")
	else
		netorg.C2GSUpdateAim(AimStr)
	end
end



function COrgChamberInfoPage.OnClickMember(self)
	g_OrgCtrl:GetMemberList(define.Org.HandleType.OpenMemberView)
end

function COrgChamberInfoPage.OnClickApprove(self)
	netorg.C2GSOrgApplyList()
end

function COrgChamberInfoPage.OnHuiZhangExit(self)
	if g_OrgCtrl:GetMyOrgInfo().memcnt > 1 then
		local windowConfirmInfo = {
			msg = "委任会长后才可退出公会",
			thirdStr = "确定",
			thirdCallback = function ()end,
			hideOk = true,
			hideCancel = true,
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	end
end
function COrgChamberInfoPage.OnExit(self)
	if g_QQPluginCtrl:HasBindQQGroup() and g_QQPluginCtrl:IsRelation(define.QQPlugin.Relation.QunZhu) then
		g_NotifyCtrl:FloatMsg("解绑Q群后才可退出公会")
		return
	end
	-- local windowConfirmInfo = {
		-- msg = "退会后24小时内无法加入其它公会，是否继续退出？\n(首次退会不会有退会冷却CD)",
		-- okStr = "是",
		-- cancelStr = "否",
		-- okCallback = function()
			netorg.C2GSLeaveOrg()
	-- 	end
	-- }
	-- g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function COrgChamberInfoPage.OnEdit(self)
	self.m_EditAimBox:ShowEdit()
end

function COrgChamberInfoPage.OnChangeFlag(self)
	COrgChangeFlagView:ShowView()
end

function COrgChamberInfoPage.OnUpgrade(self)
	g_OrgCtrl:PromoteOrgLevel()
end

function COrgChamberInfoPage.CheckRedDot(self)
	if g_OrgCtrl:HasApplyList() then
		self.m_ApproveBtn:AddEffect("RedDot", 20, Vector3.New(-20, -20, 0))
	else
		self.m_ApproveBtn:DelEffect("RedDot")
	end
end

function COrgChamberInfoPage.OnNotify(self, oCtrl)
	if define.Org.Event.GetOrgAim == oCtrl.m_EventID then
		self:OnCloseEditAim()
		self.m_InitInfoBox:RefreshUI()
	elseif oCtrl.m_EventID == define.Org.Event.DelMember then
		if oCtrl.m_EventData ~= g_AttrCtrl.pid then
			self.m_InitInfoBox:RefreshUI()
		end
	elseif oCtrl.m_EventID == define.Org.Event.OnDealApply then
		self.m_InitInfoBox:RefreshUI()
	elseif oCtrl.m_EventID == define.Org.Event.OnChangePos then
		if oCtrl.m_EventData.pid == g_AttrCtrl.pid then
			self:SetLimitData()
		end
	elseif oCtrl.m_EventID == define.Org.Event.UpdateOrgInfo then
		self.m_InitInfoBox:RefreshUI()
		self:SetLimitData()
		self:CheckRedDot()
	end
end

return COrgChamberInfoPage