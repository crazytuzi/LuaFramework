local CWarResultView = class("CWarResultView", CViewBase)

function CWarResultView.ctor(self, cb)
	CViewBase.ctor(self, "UI/War/WarResultView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CWarResultView.OnCreateView(self)
	self.m_ExpGrid = self:NewUI(1, CGrid)
	self.m_ExpBox = self:NewUI(2, CBox)
	self.m_ItemGrid = self:NewUI(3, CGrid)
	self.m_ItemBox = self:NewUI(4, CItemTipsBox)
	self.m_DescLabel = self:NewUI(5, CLabel)
	self.m_LittleTitleLabel = self:NewUI(6, CLabel)
	self.m_Win = self:NewUI(7, CObject)
	self.m_Fail = self:NewUI(8, CObject)
	self.m_End = self:NewUI(9, CObject)
	self.m_FailPart = self:NewUI(10, CBox)
	self.m_PowerPartnerBtn = self:NewUI(11, CButton)
	self.m_PowerHeroBtn = self:NewUI(12, CButton)
	self.m_BossResultPart = self:NewUI(14, CBox)
	self.m_Container = self:NewUI(15, CWidget)
	self.m_JiangliFenge = self:NewUI(16, CWidget)
	self.m_DelayCloseLabel = self:NewUI(17, CLabel)
	self.m_WinTipLabel = self:NewUI(18, CLabel)
	self.m_FailTipLabel = self:NewUI(19, CLabel)
	self.m_ItemScrollView = self:NewUI(20, CScrollView)

	self.m_WinEffect = CEffect.New("Effect/UI/ui_eff_1159/Prefabs/ui_eff_1159_shengli.prefab", self:GetLayer(), false)
	self.m_WinEffect:SetParent(self.m_Win.m_Transform)
	self.m_FailEffect = CEffect.New("Effect/UI/ui_eff_1159/Prefabs/ui_eff_1159_shibai.prefab", self:GetLayer(), false)
	self.m_FailEffect:SetParent(self.m_Fail.m_Transform)
	self.m_EndEffect = CEffect.New("Effect/UI/ui_eff_1159/Prefabs/ui_eff_1159_zhandoujieshu.prefab", self:GetLayer(), false)
	self.m_EndEffect:SetParent(self.m_End.m_Transform)
	self.m_WinEffect:SetLocalPos(Vector3.New(0, 220, 0))
	self.m_FailEffect:SetLocalPos(Vector3.New(0, 220, 0))
	self.m_EndEffect:SetLocalPos(Vector3.New(0, 220, 0))

	self.m_PowerPartnerBtn:AddUIEvent("click", callback(self, "OnClickPowerPartner"))
	self.m_PowerHeroBtn:AddUIEvent("click", callback(self, "OnClickPowerHero"))
	g_EndlessPVECtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWarEvnet"))
	UITools.ResizeToRootSize(self.m_Container)

	self.m_BaseExpPos = self.m_ExpGrid:GetLocalPos()
	self.m_BaseFengePos = self.m_JiangliFenge:GetLocalPos()
	self.m_BaseScrollPos = self.m_ItemScrollView:GetLocalPos()
end

function CWarResultView.OnShowView(self)
	self.m_WarID = nil

	self.m_LittleTitleLabel:SetActive(false)
	self.m_JiangliFenge:SetActive(false)
	self.m_BossResultPart:SetActive(false)
	self.m_FailPart:SetActive(false)
	self.m_ExpBox:SetActive(false)
	self.m_ItemBox:SetActive(false)
	self.m_DelayCloseLabel:SetActive(false)
	self.m_WinTipLabel:SetActive(false)
	self.m_FailTipLabel:SetActive(false)
	self.m_DelayCloseTimer = nil
	self.m_WarType = g_WarCtrl:GetWarType()
	netopenui.C2GSOpenInterface(define.OpenInterfaceType.WarResult)
end

function CWarResultView.OnHideView(self)
	self.m_ExpGrid:SetLocalPos(self.m_BaseExpPos)
	self.m_JiangliFenge:SetLocalPos(self.m_BaseFengePos)
	self.m_ItemScrollView:SetLocalPos(self.m_BaseScrollPos)
	g_ViewCtrl:CloseInterface(define.OpenInterfaceType.WarResult)
	self:DoHideCallback()
	self.m_ExpGrid:Clear()
	self.m_ItemGrid:Clear()
	if self.m_BossResultGrid then
		self.m_BossResultGrid:Clear()
	end
	CViewBase.OnHideView(self)
end

function CWarResultView.DoHideCallback(self)
	
end

function CWarResultView.OrgFuBenWarEnd(self)
	g_WarCtrl:SetWarEndAfterCallback(function ()
		if g_OrgCtrl:HasOrg() then
				COrgMainView:ShowView(function ()
				COrgActivityCenterView:ShowView()
			end)
		end
	end)
	self:CloseView()

end

function CWarResultView.OnClickPowerPartner(self)
	g_WarCtrl:SetWarEndAfterCallback(function ()
		local level = data.globalcontroldata.GLOBAL_CONTROL.powerguide.open_grade
		if g_AttrCtrl.grade >= level then
			CPowerGuideMainView:ShowView(function(oView)
				oView:OpenTargetItem(1, 2)
			end)
		else
			g_NotifyCtrl:FloatMsg(string.format("达到%d级，开启此功能", level))
		end
	end)
	self:CloseView()
end

function CWarResultView.OnClickPowerHero(self)
	g_WarCtrl:SetWarEndAfterCallback(function ()
		local level = data.globalcontroldata.GLOBAL_CONTROL.powerguide.open_grade
		if g_AttrCtrl.grade >= level then
			CPowerGuideMainView:ShowView()
		else
			g_NotifyCtrl:FloatMsg(string.format("达到%d级，开启此功能", level))
		end
	end)
	self:CloseView()
end

function CWarResultView.OnWarEvnet(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.ResultInfo then
		self:RefeshAll()
	elseif oCtrl.m_EventID == define.War.Event.EndWar then
		CViewBase.CloseView(self)
	end
end

function CWarResultView.SetWin(self, bWin)
	self.m_ExpGrid:SetActive(false)
	if bWin == true then
		if g_WarCtrl:GetWarType() == define.War.Type.Boss or g_WarCtrl:GetWarType() == define.War.Type.BossKing then
			self.m_ExpGrid:SetActive(false)
		else
			self.m_ExpGrid:SetActive(true)
		end
		self:RefreshResultTexture("win")
	elseif bWin == false then
		self.m_FailPart:SetActive(true)
		self:RefreshResultTexture("fail")
		self:SetDelayCloseView()
		if g_PowerGuideCtrl:IsPowerPartnerRedDot() then
			self.m_PowerPartnerBtn:AddEffect("RedDot")
		else
			self.m_PowerPartnerBtn:DelEffect("RedDot")
		end
		if g_PowerGuideCtrl:IsPowerHeroRedDot() then
			self.m_PowerHeroBtn:AddEffect("RedDot")
		else
			self.m_PowerHeroBtn:DelEffect("RedDot")
		end
	else
		self.m_ExpGrid:SetActive(true)
		self:RefreshResultTexture("end")
	end
	self:RefreshWinFailTip(bWin)
end

function CWarResultView.RefreshResultTexture(self, sType)
	self.m_Win:SetActive(false)
	self.m_Fail:SetActive(false)
	self.m_End:SetActive(false)
	if sType == "win" then
		self.m_Win:SetActive(true)
	elseif sType == "fail" then
		self.m_Fail:SetActive(true)
	elseif sType == "end" then
		self.m_End:SetActive(true)	
	end
end

function CWarResultView.ShowEndlessPVEResult(self)
	self.m_ExpGrid:SetLocalPos(Vector3.New(0, 0, 0))
	self.m_JiangliFenge:SetLocalPos(Vector3.New(0, -50, 0))
	self.m_ItemScrollView:SetLocalPos(Vector3.New(0, -130, 0))
	self.m_LittleTitleLabel:SetActive(true)
	self:RefreshResultTexture("end")
	self:RefreshEndlessRing()
end

function CWarResultView.SetWarID(self, id)
	self.m_WarID = id
	self:RefeshAll()
	self:AutoDoShiMen()
end

function CWarResultView.RefeshAll(self)
	local dResultInfo = g_WarCtrl.m_ResultInfo
	
	if dResultInfo.war_id ~= self.m_WarID then
		return
	end
	self.m_ExpDatas = dResultInfo.exp_list
	self:RefreshExpGrid()
	self.m_ItemDatas = dResultInfo.item_list
	self:RefreshItemGrid()
	local sText = dResultInfo.desc or ""
	self.m_DescLabel:SetText(sText)
	local lContent = dResultInfo.content
	if lContent then
		self.m_BossResultPart:SetActive(true)
		self.m_ExpGrid:SetActive(false)
		self.m_FailPart:SetActive(false)
		self.m_BossResultGrid = self.m_BossResultPart:NewUI(1, CGrid)
		self.m_BossResultBox = self.m_BossResultPart:NewUI(2, CBox)
		self.m_BossResultGrid:Clear()
		self.m_BossResultBox:SetActive(false)
		for i,v in ipairs(lContent) do
			local oBox = self.m_BossResultBox:Clone()
			oBox:SetActive(true)
			oBox.m_Label = oBox:NewUI(1, CLabel)
			oBox.m_Label:SetText(v)
			self.m_BossResultGrid:AddChild(oBox)
		end
		self.m_BossResultGrid:Reposition()
	end
	
	local resultspr = dResultInfo.resultspr
	if resultspr then
		self:RefreshResultTexture("end")
	end
end

function CWarResultView.RefreshExpGrid(self)
	self.m_ExpGrid:Clear()
	for i, dExp in ipairs(self.m_ExpDatas) do
		local oBox = self.m_ExpBox:Clone()
		oBox:SetActive(true)
		oBox.m_Avatar = oBox:NewUI(1, CSprite)
		oBox.m_ExpLabel = oBox:NewUI(2, CLabel)
		oBox.m_LvLabel = oBox:NewUI(3, CLabel)
		oBox.m_Slider = oBox:NewUI(4, CSlider)
		oBox.m_BoderSpr = oBox:NewUI(5, CSprite)
		oBox.m_ExpEffect = oBox:NewUI(6, CUIEffect, false)
		oBox.m_ServerGradeLabel = oBox:NewUI(7, CLabel)
		oBox.m_DailyTrainTipsLabel = oBox:NewUI(8, CLabel)
		oBox.m_Avatar:SpriteAvatar(dExp.shape)
		local dPartner = data.partnerdata.DATA[dExp.shape]
		if not dPartner then
			for k,v in pairs(data.itemdata.PARTNER_SKIN) do
				if v.shape == dExp.shape then
					dPartner = data.partnerdata.DATA[v.partner_type]
					break
				end
			end
		end
		if dPartner then
			local rare = dPartner.rare
			local filename = define.Partner.CardColor[rare] or "hui"
			oBox.m_BoderSpr:SetSpriteName("bg_haoyoukuang_"..filename.."se")
			oBox.m_ServerGradeLabel:SetActive(false)
		else
			oBox.m_ServerGradeLabel:SetActive(dExp.is_over_grade or dExp.add_exp > 0)
			oBox.m_ServerGradeLabel:SetText(g_AttrCtrl:GetServerGradeWarDesc(dExp.cur_grade))
		end

		if not dPartner and self.m_WarType == define.War.Type.DailyTrain and g_TeamCtrl:IsLeader() and g_TeamCtrl:IsAllInTeam() then
			oBox.m_DailyTrainTipsLabel:SetActive(true)
		else
			oBox.m_DailyTrainTipsLabel:SetActive(false)
		end

		oBox.m_LeftAddExp = dExp.add_exp
		oBox.m_CurExp = dExp.cur_exp
		oBox.m_CurGrade = dExp.cur_grade
		oBox.m_MaxExpFunc = dExp.max_exp_func
		oBox.m_LimitGrade = dExp.limit_grade
		oBox.m_AddExp = 0
		oBox.m_Step = math.ceil(dExp.add_exp / 30)
		oBox.m_LvLabel:SetText(string.format("lv.%d", oBox.m_CurGrade))
		if oBox.m_CurGrade >= oBox.m_LimitGrade then
			oBox.m_ExpLabel:SetText("已满级")
			oBox.m_Slider:SetValue(1)
		else
			Utils.AddTimer(callback(self, "BoxExpAnim", oBox), 0, 0)
		end
		self.m_ExpGrid:AddChild(oBox)
	end
end

function CWarResultView.BoxExpAnim(self, oBox)
	if not oBox.m_LeftAddExp then
		return false
	end
	if oBox.m_LeftAddExp <= oBox.m_Step then
		oBox.m_Step = oBox.m_LeftAddExp
		oBox.m_LeftAddExp = nil
	else
		oBox.m_LeftAddExp = oBox.m_LeftAddExp - oBox.m_Step
	end
	oBox.m_AddExp = oBox.m_AddExp + oBox.m_Step
	oBox.m_CurExp = oBox.m_CurExp + oBox.m_Step
	if oBox.m_MaxExp == nil then
		oBox.m_MaxExp = oBox.m_MaxExpFunc(oBox.m_CurGrade)
	end
	if oBox.m_CurExp >= oBox.m_MaxExp and oBox.m_CurGrade < oBox.m_LimitGrade  then
		oBox.m_CurGrade = oBox.m_CurGrade + 1
		if not Utils.IsNil(oBox.m_LvLabel) then
			oBox.m_LvLabel:SetText(string.format("lv.%d#G(升级)#n", oBox.m_CurGrade))
			CWarResultView:DoBoxExpEffect(oBox)
		end
		oBox.m_MaxExp = nil
		oBox.m_Slider:SetValue(0)
		oBox.m_CurExp = 0
	else
		oBox.m_Slider:SetValue(oBox.m_CurExp/oBox.m_MaxExp)
	end
	if not Utils.IsNil(oBox.m_ExpLabel) then
		oBox.m_ExpLabel:SetText(string.format("EXP +%d", oBox.m_AddExp))
	end	
	return true
end

function CWarResultView.DoBoxExpEffect(cls, oBox)
	if oBox.m_ExpEffect and oBox.m_LvLabel then
		oBox.m_ExpEffect:Above(oBox.m_LvLabel)
		oBox.m_ExpEffect:SetActive(true)
	end
end

function CWarResultView.RefreshItemGrid(self)
	self.m_ItemGrid:Clear()
	for i, dItemInfo in ipairs(self.m_ItemDatas) do
		local oBox = self.m_ItemBox:Clone()
		oBox:SetActive(true)
		local config = {isLocal = true, uiType = 3}
		if dItemInfo.id and dItemInfo.id > 0 then
			config.id = dItemInfo.id
		end
		if  dItemInfo.virtual ~= 1010 then
			oBox:SetItemData(dItemInfo.sid, dItemInfo.amount, nil ,config)	
		else
			oBox:SetItemData(dItemInfo.virtual, dItemInfo.amount, dItemInfo.sid ,config)	
		end
		self.m_ItemGrid:AddChild(oBox)
	end
	self.m_JiangliFenge:SetActive(self.m_ItemGrid:GetCount()>0)
end

function CWarResultView.RefreshWinFailTip(self, bWin)
	local dResultInfo = g_WarCtrl.m_ResultInfo
	if dResultInfo.wintips and bWin then
		self.m_WinTipLabel:SetActive(true)
		self.m_WinTipLabel:SetText(dResultInfo.wintips)
	else
		self.m_WinTipLabel:SetActive(false)
	end
	
	if dResultInfo.failtips and not bWin then
		self.m_FailTipLabel:SetActive(true)
		self.m_FailTipLabel:SetText(dResultInfo.failtips)
	else
		self.m_FailTipLabel:SetActive(false)
	end

end

function CWarResultView.IsPartnerEquip(self, shape)
	return 
end

function CWarResultView.RefreshEndlessRing(self)
	self.m_LittleTitleLabel:SetText(string.format("通关[F2B41AFF]%s[-]波", g_EndlessPVECtrl:GetRingInfo()))
end

function CWarResultView.SetFieldBossView(self)
	if not self.m_FailPart.m_IsChange then
		local v = self.m_FailPart:GetLocalPos()
		self.m_FailPart:SetLocalPos(Vector3.New(v.x, -200, v.z))
		v = self.m_ExpGrid:GetLocalPos()
		self.m_ExpGrid:SetLocalPos(Vector3.New(v.x, -100, v.z))
	end
	self.m_FailPart.m_IsChange = true
end

function CWarResultView.CloseView(self)
	CViewBase.CloseView(self)
	g_WarCtrl:SetInResult(false)
end

function CWarResultView.OnNotify(self, oCtrl)
	if oCtrl.m_EventID == define.EndlessPVE.Event.OnWarEnd then
		self:RefreshEndlessRing()
	end
end

function CWarResultView.SetDelayCloseView(self)
	if self.m_DelayCloseTimer ~= nil then
		Utils.DelTimer(self.m_DelayCloseTimer)
		self.m_DelayCloseTimer = nil
	end
	self.m_DelayCloseLabel:SetActive(true)
	local cnt = 0
	local function update()
		local str = string.format("%ds后自动关闭", 3 - cnt)
		self.m_DelayCloseLabel:SetText(str)
		if cnt < 3 then
			cnt = cnt + 1
			return true
		end
		self:CloseView()
	end
	self.m_DelayCloseTimer = Utils.AddTimer(update, 1, 0)
end

function CWarResultView.Destroy(self)
	if self.m_DelayCloseTimer ~= nil then
		Utils.DelTimer(self.m_DelayCloseTimer)
		self.m_DelayCloseTimer = nil
	end
	self:StopAutoDoingShiMenTimer()
	CViewBase.Destroy(self)
end

function CWarResultView.StopAutoDoingShiMenTimer(self)
	if self.m_AutoDoingShimenTimer then
		Utils.DelTimer(self.m_AutoDoingShimenTimer)
		self.m_AutoDoingShimenTimer = nil
	end
end

function CWarResultView.AutoDoShiMen(self)
	if g_TaskCtrl:IsAutoDoingShiMen() and self.m_WarType == define.War.Type.ShiMen then
		local cb = function ( )
			self:CloseView()
		end
		self:StopAutoDoingShiMenTimer()
		self.m_AutoDoingShimenTimer = Utils.AddTimer(cb, 0, CTaskCtrl.AutoDoingSM.Time)
	end
end

return CWarResultView