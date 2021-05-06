local CNotifyView = class("CNotifyView", CViewBase)

function CNotifyView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Notify/NotifyView.prefab", cb)
	self.m_DepthType = "Notify"
end

function CNotifyView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_OrderBtn = self:NewUI(2, CButton)
	self.m_FloatTable = self:NewUI(3, CTable)
	self.m_FloatBoxClone = self:NewUI(4, CFloatBox)
	self.m_HintBox = self:NewUI(5, CHintBox)
	self.m_ProgressBar = self:NewUI(6, CProgressBox)
	self.m_DebugLabel = self:NewUI(7, CLabel)
	self.m_RumorBox = self:NewUI(8, CRumorBox)
	self.m_InviteOrgBtn = self:NewUI(9, CButton)
	self.m_LongPressBox = self:NewUI(10, CBox)
	self.m_TimeBox = self:NewUI(11, CBox)
	self.m_ConnectBox = self:NewUI(12, CBox)
	self.m_ExpBox = self:NewUI(13, CBox)
	self.m_RewardListBox = self:NewUI(14, CBox)
	self.m_OrgHintBox = self:NewUI(15, COrgHintBox)
	self.m_AniSwitchBox = self:NewUI(16, CAniSwitchBox)
	self.m_UIScreenEffectRoot = self:NewUI(17, CSprite)
	self.m_PowerChangeBox = self:NewUI(18, CPowerChangeBox)
	self.m_ExpBox.m_ExpCurLabel = self.m_ExpBox:NewUI(1, CLabel)
	self.m_ExpBox.m_ExpNextLabel = self.m_ExpBox:NewUI(2, CLabel)
	self.m_ExpBox.m_ExpDivLabel = self.m_ExpBox:NewUI(3, CLabel)
	self.m_ExpBox.m_ExpGroup = self.m_ExpBox:NewUI(4, CBox)
	self.m_ExpBox.m_ExpSlider = self.m_ExpBox:NewUI(5, CSlider)
	self.m_ExpBox.m_ExpDivGrid = self.m_ExpBox:NewUI(6, CGrid)

	self:InitContent()
end

function CNotifyView.InitContent(self)
	self.m_OrgHintBox:SetActive(false)
	self.m_HintBox:SetActive(false)
	self.m_ProgressBar:SetActive(false)
	self.m_FloatTable:SetActive(true)
	self.m_FloatBoxClone:SetActive(false)
	self.m_InviteOrgBtn:SetActive(false)
	self.m_ExpBox:SetActive(false)
	self.m_OrderBtn:SetActive(Utils.IsDevUser() or Utils.IsEditor())
	self.m_OrderBtn:AddUIEvent("click", callback(self, "OnOrder"))
	self.m_InviteOrgBtn:AddUIEvent("click", callback(self, "OnInviteOrg"))
	g_ChatCtrl:AddCtrlEvent("click", callback(self, "OnChatEvent"))
	g_AttrCtrl:AddCtrlEvent("click", callback(self, "OnAttrEvent"))
	self.m_DebugLabel:AddUIEvent("click", callback(self, "OnDebugLabel"))
	
	self.m_TimeBox.m_Label = self.m_TimeBox:NewUI(1, CLabel)
	self.m_TimeBox:SetActive(false)
	self.m_LongPressBox.m_AniSpr = self.m_LongPressBox:NewUI(1, CSprite)
	self:InitExpBarDiv()
	self.m_MsgList = {}
	self.m_ConnectBox.m_ConnectLabel = self.m_ConnectBox:NewUI(1, CLabel)
	self:SetConnect(false)
	-- local function refresh()
	-- 	self.m_DebugLabel:SetText(string.format("%d", collectgarbage("count")))
	-- 	return true
	-- end
	-- Utils.AddTimer(refresh, 0.1, 0)
end

function CNotifyView.Clear(self)
	self.m_RumorBox:Clear()
	self.m_ExpBox:SetActive(false)
end

function CNotifyView.ShowLongPressAni(self, pos, time)
	self.m_LongPressBox:SetActive(true)
	self.m_LongPressBox:SetPos(pos)
	if time then
		self.m_LongPressBox.m_AniSpr:SetUITweenDuration(time)
	end
	self.m_LongPressBox.m_AniSpr:UITweenPlay()
end

function CNotifyView.HideLongPressAni(self)
	self.m_LongPressBox.m_AniSpr:UITweenStop()
	self.m_LongPressBox:SetActive(false)
end

function CNotifyView.OnDebugLabel(self)
	local count1 = collectgarbage("count")
	local time1 = g_TimeCtrl:GetTimeMS()
	collectgarbage("collect")
	local count2 = collectgarbage("count")
	g_NotifyCtrl:FloatMsg(string.format("time:%dms, collect:%dk\n 回收前%d, 回收后%d", g_TimeCtrl:GetTimeMS()-time1, count1-count2,count1, count2))
end

function CNotifyView.OnChatEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Chat.Event.AddMsg then
		local oMsg = oCtrl.m_EventData
		if oMsg:IsHorseRace() then
			self.m_RumorBox:AddMsg(oMsg)
		end
	end
end

function CNotifyView.OnOrder(self, oBtn)
	if not (Utils.IsDevUser() or Utils.IsEditor()) then
		g_NotityCtrl:FloatMsg("没有权限打开该界面, 请联系客服")
		return
	end

	CGmView:ShowView()
	-- CNotifyView.g_Test = CNotifyView.g_Test + 1
	-- CNotifyView.g_Test = 0
	-- g_NotifyCtrl:FloatMsg("飘字测试"..tostring(CNotifyView.g_Test))
end

function CNotifyView.OnInviteOrg(self, oBtn)
	-- self.m_InviteOrgBtn:SetActive(false)
	-- if next(g_OrgCtrl.m_InviteOrgInfo) then
	-- 	local pbdata = g_OrgCtrl.m_InviteOrgInfo
	-- 	local windowConfirmInfo = {
	-- 		msg				= "[00FF00]" .. pbdata.pname.."\n[FFFFFF]邀请您加入\n"..pbdata.org_level.."级"..pbdata.org_name.."公会",
	-- 		title			= "入会邀请",
	-- 		okStr			= "同意",
	-- 		cancelStr		= "拒绝",
	-- 		forceConfirm	= true,
	-- 		--0拒绝邀请 1接受邀请
	-- 		okCallback = function ()netorg.C2GSDealInvited2Org(pbdata.pid, pbdata.orgid, 1) end,
	-- 		cancelCallback = function ()netorg.C2GSDealInvited2Org(pbdata.pid, pbdata.orgid, 0) end,
	-- 	}
	-- 	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function (oView)
	-- 		self.m_WinTipViwe = oView
	-- 	end)
	-- end
end

function CNotifyView.ShowOrgHint(self, sTitle, sDesc, nearWidget, nearType, vector2)
	self.m_OrgHintBox:SetActive(true)
	self.m_OrgHintBox:SetHintText(sTitle, sDesc)
	vector2 = vector2 or Vector2.zero
	UITools.NearTarget(nearWidget, self.m_OrgHintBox, nearType, vector2, true)
	g_UITouchCtrl:TouchOutDetect(self.m_OrgHintBox, callback(self, "HideOrgHint"))
end

function CNotifyView.HideOrgHint(self)
	self.m_OrgHintBox:SetActive(false)
end


function CNotifyView.ShowHint(self, text, nearWidget, nearType, vector2)
	self.m_HintBox:SetActive(true)
	self.m_HintBox:SetHintText(text)
	vector2 = vector2 or Vector2.zero
	UITools.NearTarget(nearWidget, self.m_HintBox, nearType, vector2, true)
	local function hide()
		self.m_HintBox:SetActive(false)
	end
	g_UITouchCtrl:TouchOutDetect(self.m_HintBox, hide)
end

function CNotifyView.HideHint(self)
	self.m_HintBox:SetActive(false)
end

function CNotifyView.FloatMsg(self, sText)
	table.insert(self.m_MsgList, sText)
	self:DelayCall(0, "ProcessFloatMsgList")
end

function CNotifyView.ProcessFloatMsgList(self)
	DOTween.DOKill(self.m_FloatTable.m_Transform, true)
	if self.m_AnimFloatBox then
		DOTween.DOKill(self.m_AnimFloatBox.m_Transform, true)
	end
	for i, sText in ipairs(self.m_MsgList) do
		local oBox = self:GetFloatBox()
		oBox:SetText(string.getstringdark(sText))
		oBox:ResizeBg()
		oBox:SetTimer(2, callback(self, "OnTimerUp"))
		if i == #self.m_MsgList then
			self:AddBoxWithAnim(oBox)
		else
			self.m_FloatTable:SetLocalPos(Vector3.zero)
			self.m_FloatTable:AddChild(oBox)
			oBox:SetAsFirstSibling()
		end
	end
	self.m_MsgList = {}
end

function CNotifyView.AddBoxWithAnim(self, oBox)
	oBox:SetParent(self.m_Transform)
	local iPos = oBox.m_BgSprite:GetHeight()/2
	oBox:SetLocalPos(Vector3.New(0, iPos, 0))
	DOTween.DOKill(self.m_FloatTable.m_Transform, true)
	local time = 0.75
	if self.m_FloatTable:GetCount() == 0 then
		self.m_FloatTable:AddChild(oBox)
	else
		local tween1 = DOTween.DOLocalMoveY(self.m_FloatTable.m_Transform, iPos*2, time)
		local weakid = weakref(oBox)
		DOTween.OnComplete(tween1, objcall(self, function(obj)
				local oRefBox = getrefobj(weakid)
				if oRefBox then
					DOTween.DOKill(oRefBox.m_Transform, true)
					obj.m_FloatTable:SetLocalPos(Vector3.zero)
					obj.m_FloatTable:AddChild(oRefBox)
					oRefBox:SetAsFirstSibling()
					obj.m_AnimFloatBox = nil
				end
			end))
	end
	oBox:SetLocalScale(Vector3.New(0.9, 0.9, 0.9))
	local tween2 = DOTween.DOScale(oBox.m_Transform, Vector3.one, time*1.4)
	DOTween.SetEase(tween2, enum.DOTween.Ease.OutElastic)
	self.m_AnimFloatBox = oBox
end


function CNotifyView.GetFloatBox(self)
	-- local sResKey = "CNotifyView.FloatBox"
	-- local oBox = g_ResCtrl:GetObjectFromCache(sResKey)
	-- if oBox then
	-- 	oBox:SetAlpha(1)
	-- else
	local oBox = self.m_FloatBoxClone:Clone()
		-- oBox:SetCacheKey(sResKey)
	-- end
	oBox:SetActive(true)
	return oBox
end

--装备属性变化提示飘字
function CNotifyView.FloatMsgAttrChange(self, sText, args)
	local oBox = self:GetFloatBox()
	oBox:SetText(string.getstringdark(sText))
	oBox:ResizeBg()
	self:AddFloatBoxAttrChange(oBox, args)
	return oBox
end

function CNotifyView.AddFloatBoxAttrChange(self, oBox, args)
	local hideTime = args.hideTime or 2
	oBox:SetTimer(hideTime, callback(self, "OnTimerUp"))
	self:AddBoxWithAnim(oBox)
end
--装备属性变化提示飘字

function CNotifyView.OnTimerUp(self, oBox)
	if self.m_AnimFloatBox == oBox then
		self.m_AnimFloatBox = nil
	end
	self.m_FloatTable:RemoveChild(oBox)
	g_ResCtrl:PutObjectInCache(oBox:GetCacheKey(), oBox)
	self.m_FloatTable:Reposition()
end

function CNotifyView.ShowProgress(self, cbFun, sText, waitTime, cancelFunc)
	self.m_ProgressBar:SetActive(true)
	local function hide()
		self.m_ProgressBar:SetActive(false)
		if cbFun then
			cbFun()
		end
	end
	local function cancel()
		if cancelFunc then
			self.m_ProgressBar:SetActive(false)
			cancelFunc()
		end
	end
	self.m_ProgressBar:SetProgress(sText, waitTime, hide, cancel)
end

function CNotifyView.ShowInviteOrgInfo(self)
	self.m_InviteOrgBtn:SetActive(true)
end

function CNotifyView.ShowTimeBox(self)
	self.m_TimeTimer = Utils.AddTimer(callback(self, "OnTimeUpdate"), 0.5, 0)
	self.m_TimeBox:SetActive(true)
end

function CNotifyView.OnTimeUpdate(self)
	local seconds = g_TimeCtrl:GetTimeS()
	self.m_TimeBox.m_Label:SetText(g_TimeCtrl:Convert(seconds))
	return true
end

function CNotifyView.CloseTimeBox(self)
	self.m_TimeBox:SetActive(false)
	if self.m_TimeTimer ~= nil then
		Utils.DelTimer(self.m_TimeTimer)
		self.m_TimeTimer = nil
	end
end

function CNotifyView.SwitchServerTime(self)
	if self.m_TimeTimer then
		self:CloseTimeBox()
	else
		self:ShowTimeBox()
	end
end

function CNotifyView.SetConnect(self, bShow, sTips)
	self.m_ConnectBox:SetActive(bShow)
	sTips = sTips or ""
	self.m_ConnectBox.m_ConnectLabel:SetText(sTips)
end

function CNotifyView.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		local data = oCtrl.m_EventData
		self:RefrehExp(data.dPreAttr, data.dAttr)
	end
end

function CNotifyView.RefrehExp(self, preData, curData)
	if self.m_ExpBox:GetActive() == false then
		return 
	end

	if not curData or not curData.exp then
		self.m_ExpBox.m_ExpSlider:SetValue(g_AttrCtrl:GetCurGradeExp()/g_AttrCtrl:GetUpgradeExp())		
		self.m_ExpBox.m_ExpCurLabel:SetText(tostring( math.floor(g_AttrCtrl:GetCurGradeExp())))
		self.m_ExpBox.m_ExpNextLabel:SetText(tostring( math.floor(g_AttrCtrl:GetUpgradeExp())))
	else
		if not curData.grade then
			curData.grade = g_AttrCtrl.grade
			preData.grade = g_AttrCtrl.grade
		end
		local preExpinfo = data.upgradedata.DATA[preData.grade]
		local nextExpinfo = data.upgradedata.DATA[preData.grade + 1]
		if not preExpinfo then		--等级为0的特殊处理
			preExpinfo = nextExpinfo
			preExpinfo.sum_player_exp = 0
		end
		if not nextExpinfo then		--满级的特殊处理
			self.m_ExpBox.m_ExpSlider:SetValue(g_AttrCtrl:GetCurGradeExp()/g_AttrCtrl:GetUpgradeExp())			
			self.m_ExpBox.m_ExpCurLabel:SetText(tostring( math.floor(g_AttrCtrl:GetCurGradeExp())))
			self.m_ExpBox.m_ExpNextLabel:SetText(tostring( math.floor(g_AttrCtrl:GetUpgradeExp())))
			return
		end
		local curGrade = -1
		local remainExp = curData.exp - preData.exp
		local addExp = 0
		local curExp = 0

		local function updateExp(delta)
			if addExp >= 1 then				--更新规则：按每个等级的经验更新量折半添加
				curExp = addExp/4 + curExp
				self.m_ExpBox.m_ExpSlider:SetValue(curExp/nextExpinfo.player_exp)
				self.m_ExpBox.m_ExpCurLabel:SetText(tostring( math.floor(g_AttrCtrl:GetCurGradeExp())))
				self.m_ExpBox.m_ExpNextLabel:SetText(tostring( math.floor(g_AttrCtrl:GetUpgradeExp())))
				addExp = addExp - addExp/4
			else
				if remainExp <= 0 then
					self.m_ExpBox.m_ExpSlider:SetValue(g_AttrCtrl:GetCurGradeExp()/g_AttrCtrl:GetUpgradeExp())	
					return false
				end
				if curGrade > 0 then
					curExp = 0
				else
					curGrade = preData.grade
					curExp = preData.exp - preExpinfo.sum_player_exp
				end
				preExpinfo = data.upgradedata.DATA[curGrade]
				nextExpinfo = data.upgradedata.DATA[curGrade + 1]
				curGrade = curGrade + 1
				if curExp + remainExp <= nextExpinfo.player_exp then
					addExp = remainExp
					remainExp = 0
				else
					addExp = nextExpinfo.player_exp - curExp
					remainExp = curExp + remainExp - nextExpinfo.player_exp
				end			
			end
			if addExp == 0 then
				return false
			end			
			return true
		end
		Utils.AddTimer(updateExp, 0.05, 0)
	end
end

function CNotifyView.UpdateExpbarVisible(self)
	if not self.m_ExpBox then
		return
	end

	local bVisible = false
	local iCnt = g_ViewCtrl:GetViewCount()
	if iCnt > 3 or (iCnt == 3 and CLoadingView:GetView() == nil)then
		local list = {"CWarResultView", "CCreateRoleView", "CDialogueMainView", "CLoginView",
		 "CPaTaView", "COrgMainView", "CLuckyDrawView", "CHouseExchangeView", "CEndlessPVEView", 
		"CMapBookView", "CLoginRewardNextView", "CHouseMainView", "CLoginNoticeView", "CDialogueAniView", "CTravelView", "CPartnerSkinView"}
		bVisible = true
		for k, v in pairs(g_ViewCtrl:GetViews()) do
			if table.index(list, k) ~= nil then
				bVisible = false 
				break
			end
		end
	end
	self.m_ExpBox:SetActive(bVisible)
	if bVisible then
		self:RefrehExp()
	end
end

function CNotifyView.InitExpBarDiv(self)
	if not self.m_ExpBox then
		return
	end
	local w = self.m_Container:GetWidth()
	self.m_ExpBox.m_ExpDivGrid:SetCellSize(w / 10, 100)
	self.m_ExpBox.m_ExpDivGrid:Reposition()
end

function CNotifyView.ClearFloat(self)
	self.m_FloatTable:Clear()
	self.m_AnimFloatBox = nil
end

return CNotifyView