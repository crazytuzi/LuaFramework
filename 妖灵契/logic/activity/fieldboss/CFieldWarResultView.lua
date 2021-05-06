local CFieldWarResultView = class("CFieldWarResultView", CViewBase)

function CFieldWarResultView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/fieldboss/FieldWarResultView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CFieldWarResultView.OnCreateView(self)
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
	self.m_PartnerBtn = self:NewUI(11, CButton)
	self.m_PartnerEquipBtn = self:NewUI(12, CButton)
	self.m_EquipBtn = self:NewUI(13, CButton)
	self.m_BossResultPart = self:NewUI(14, CBox)
	self.m_Container = self:NewUI(15, CWidget)
	self.m_JiangliFenge = self:NewUI(16, CWidget)
	self.m_DelayCloseLabel = self:NewUI(17, CLabel)
	self.m_WinTipLabel = self:NewUI(18, CLabel)
	self.m_FailTipLabel = self:NewUI(19, CLabel)

	self.m_WinEffect = CEffect.New("Effect/UI/ui_eff_1159/Prefabs/ui_eff_1159_shengli.prefab", self:GetLayer(), false)
	self.m_WinEffect:SetParent(self.m_Win.m_Transform)
	self.m_FailEffect = CEffect.New("Effect/UI/ui_eff_1159/Prefabs/ui_eff_1159_shibai.prefab", self:GetLayer(), false)
	self.m_FailEffect:SetParent(self.m_Fail.m_Transform)
	self.m_EndEffect = CEffect.New("Effect/UI/ui_eff_1159/Prefabs/ui_eff_1159_zhandoujieshu.prefab", self:GetLayer(), false)
	self.m_EndEffect:SetParent(self.m_End.m_Transform)
	self.m_WinEffect:SetLocalPos(Vector3.New(0, 220, 0))
	self.m_FailEffect:SetLocalPos(Vector3.New(0, 220, 0))
	self.m_EndEffect:SetLocalPos(Vector3.New(0, 220, 0))
	
	self.m_PartnerBtn:AddUIEvent("click", callback(self, "OnClickPartner"))
	self.m_PartnerEquipBtn:AddUIEvent("click", callback(self, "OnClickPartnerEquip"))
	self.m_EquipBtn:AddUIEvent("click", callback(self, "OnClickEquip"))
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWarEvnet"))
	UITools.ResizeToRootSize(self.m_Container)
end

function CFieldWarResultView.OnShowView(self)
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
	self.m_DescLabel:SetActive(false)
	self.m_DelayCloseTimer = nil
	self.m_WarType = g_WarCtrl:GetWarType()
	netopenui.C2GSOpenInterface(define.OpenInterfaceType.WarResult)
end

function CFieldWarResultView.OnHideView(self)
	g_ViewCtrl:CloseInterface(define.OpenInterfaceType.WarResult)
	self:DoHideCallback()
	self.m_ExpGrid:Clear()
	self.m_ItemGrid:Clear()
	if self.m_BossResultGrid then
		self.m_BossResultGrid:Clear()
	end
	CViewBase.OnHideView(self)
end

function CFieldWarResultView.DoHideCallback(self)
	if self.m_WarType == define.War.Type.YjFuben then
		g_ActivityCtrl:GetYJFbCtrl():OnWarEnd()
	end
end

function CFieldWarResultView.OrgFuBenWarEnd(self)
	g_WarCtrl:SetWarEndAfterCallback(function ()
		if g_OrgCtrl:HasOrg() then
				COrgMainView:ShowView(function ()
				COrgActivityCenterView:ShowView()
			end)
		end
	end)
	self:CloseView()

end

function CFieldWarResultView.OnClickPartner(self)
	g_WarCtrl:SetWarEndAfterCallback(function ()
		CPartnerMainView:ShowView(function (oView)
			oView:SetActive(true)
			oView:ShowMainPage()
		end)
	end)
	self:CloseView()
end

function CFieldWarResultView.OnClickPartnerEquip(self)
	g_WarCtrl:SetWarEndAfterCallback(function ()
		CPartnerMainView:ShowView(function (oView)
			oView:SetActive(true)
			oView:ShowEquipPage()
		end)
	end)
	self:CloseView()
end

function CFieldWarResultView.OnClickEquip(self)
	g_WarCtrl:SetWarEndAfterCallback(function ()
		if g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.forge_strength.open_grade then
			CForgeMainView:ShowView(function (oView)
				oView:SetActive(true)
			end)
		else
			g_NotifyCtrl:FloatMsg(string.format("%d级开启突破功能哦", data.globalcontroldata.GLOBAL_CONTROL.forge_strength.open_grade))
		end
	end)
	self:CloseView()
end

function CFieldWarResultView.OnWarEvnet(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.ResultInfo then
		self:RefeshAll()
	elseif oCtrl.m_EventID == define.War.Event.EndWar then
		CViewBase.CloseView(self)
	end
end

function CFieldWarResultView.SetWin(self, bWin)
	if Utils.IsNil(self) then
		return
	end
	self.m_ExpGrid:SetActive(false)
	if bWin == true then
		if g_WarCtrl:GetWarType() == define.War.Type.Boss or self.m_WarType == define.War.Type.BossKing then
			self.m_ExpGrid:SetActive(false)
		else
			self.m_ExpGrid:SetActive(true)
		end
		self:RefreshResultTexture("win")
	elseif bWin == false then
		self.m_FailPart:SetActive(true)
		self:RefreshResultTexture("fail")
	else
		self.m_ExpGrid:SetActive(true)
		self:RefreshResultTexture("end")
	end
	self:RefreshWinFailTip(bWin)
end

function CFieldWarResultView.RefreshResultTexture(self, sType)
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

function CFieldWarResultView.SetWarID(self, id)
	self.m_WarID = id
	self:RefeshAll()
end

function CFieldWarResultView.RefeshAll(self)
	local dResultInfo = g_WarCtrl.m_ResultInfo
	
	if dResultInfo.war_id ~= self.m_WarID then
		return
	end
	self.m_ExpDatas = dResultInfo.exp_list
	self:RefreshExpGrid()
	self.m_ItemDatas = dResultInfo.item_list
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
	if self.m_WinState then
		self:RefreshWinFailTip(self.m_WinState)
	end
end

function CFieldWarResultView.ReloadWinFailTip(self)
	if self.m_WinState then
		self:RefreshWinFailTip(self.m_WinState)
	end
end

function CFieldWarResultView.RefreshExpGrid(self)
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
		oBox.m_Avatar:SpriteAvatar(dExp.shape)
		local dPartner = data.partnerdata.DATA[dExp.shape]
		printc(dExp.shape)
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
		oBox.m_LeftAddExp = dExp.add_exp
		oBox.m_CurExp = dExp.cur_exp
		oBox.m_CurGrade = dExp.cur_grade
		oBox.m_MaxExpFunc = dExp.max_exp_func
		oBox.m_LimitGrade = dExp.limit_grade
		oBox.m_AddExp = 0
		oBox.m_Step = math.ceil(dExp.add_exp / 60)
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

function CFieldWarResultView.BoxExpAnim(self, oBox)
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

function CFieldWarResultView.RefreshItemGrid(self)
	self.m_ItemGrid:Clear()
	for i, dItemInfo in ipairs(self.m_ItemDatas) do
		local oBox = self.m_ItemBox:Clone()
		oBox:SetActive(true)
		local config = {isLocal = true, uiType = 3}
		if  dItemInfo.virtual ~= 1010 then
			oBox:SetItemData(dItemInfo.sid, dItemInfo.amount, nil ,config)	
		else
			oBox:SetItemData(dItemInfo.virtual, dItemInfo.amount, dItemInfo.sid ,config)	
		end
		self.m_ItemGrid:AddChild(oBox)
	end
	self.m_JiangliFenge:SetActive(self.m_ItemGrid:GetCount()>0)
end

function CFieldWarResultView.RefreshWinFailTip(self, bWin)
	self.m_WinState = bWin
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
	self.m_ItemDatas = dResultInfo.item_list
	local iAmount = dResultInfo.reward_times or 0
	if iAmount >= tonumber(data.globaldata.GLOBAL.fieldboss_reward_limit.value) then
		self.m_JiangliFenge:SetActive(true)
		self.m_DescLabel:SetActive(true)
		self.m_DescLabel:SetText("伤害奖励已达上限，快去抢夺最后的宝箱吧~")
		self.m_ItemGrid:Clear()
	else
		self:RefreshItemGrid()
	end
end

function CFieldWarResultView.IsPartnerEquip(self, shape)
	return 
end

function CFieldWarResultView.RefreshEndlessRing(self)
	self.m_LittleTitleLabel:SetText(string.format("通关[F2B41AFF]%s[-]波", g_EndlessPVECtrl:GetRingInfo()))
end

function CFieldWarResultView.CloseView(self)
	CViewBase.CloseView(self)
	g_WarCtrl:SetInResult(false)
end


function CFieldWarResultView.SetDelayCloseView(self)
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

function CFieldWarResultView.Destroy(self)
	if self.m_DelayCloseTimer ~= nil then
		Utils.DelTimer(self.m_DelayCloseTimer)
		self.m_DelayCloseTimer = nil
	end
	CViewBase.Destroy(self)
end

return CFieldWarResultView