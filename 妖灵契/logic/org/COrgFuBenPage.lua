local COrgFuBenPage = class("COrgFuBenPage", CPageBase)

function COrgFuBenPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function COrgFuBenPage.OnInitPage(self)
	self.m_RewardBtn = self:NewUI(1, CButton)
	self.m_TipsBtn = self:NewUI(2, CButton)
	self.m_CountLabel = self:NewUI(3, CLabel)
	self.m_ResetBtn = self:NewUI(4, CButton)
	self.m_ResetLabel = self:NewUI(5, CLabel)
	self.m_BossScrollView = self:NewUI(6, CScrollView)
	self.m_BossGrid = self:NewUI(7, CGrid)
	self.m_BossBox = self:NewUI(8, CBox)
	self.m_CostLabel = self:NewUI(9, CLabel)
	self.m_BossBox:SetActive(false)
	self:InitContent()
end

function COrgFuBenPage.InitContent(self)
	self.m_RewardBtn:AddUIEvent("click", callback(self, "OnRewardBtn"))
	-- self.m_TipsBtn:SetHint(data.helpdata.DATA[define.Help.Key.OrgTuitu].content, enum.UIAnchor.Side.BottomLeft)
	self.m_TipsBtn:AddUIEvent("click", callback(self, "OnClickHelp"))
	self.m_ResetBtn:AddUIEvent("click", callback(self, "OnResetBtn"))
	g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgEvent"))
end

function COrgFuBenPage.OnClickHelp(self)
	CHelpView:ShowView(function(oView)
		oView:ShowHelp(define.Help.Key.OrgTuitu)
	end)
end

function COrgFuBenPage.ShowPage(self, itemid, args)
	CPageBase.ShowPage(self)
	netorg.C2GSOpenOrgFBUI()
end

function COrgFuBenPage.OnOrgEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Org.Event.OnOrgFBBossList then
		if oCtrl.m_EventData then
			self:SetCountLabel(oCtrl.m_EventData.left)
			self:SetResetLabel(oCtrl.m_EventData.rest, oCtrl.m_EventData.cost)
			self:RefreshBossGrid(oCtrl.m_EventData.boss_list)
		end
	elseif oCtrl.m_EventID == define.Org.Event.OnOrgFBBossHP then
		self:RefreshOrgBossHP()
	end
end

function COrgFuBenPage.SetCountLabel(self, iCount)
	self.m_CountLabel:SetText(string.format("今日可挑战次数：%s", iCount))
end

function COrgFuBenPage.SetResetLabel(self, iReset, iCost)
	if iReset > 0 then
		self.m_CostLabel:SetActive(false)
		self.m_ResetLabel:SetActive(true)
		self.m_ResetLabel:SetText(string.format("本周可重置次数：%s", iReset))
	else
		self.m_CostLabel:SetText(iCost)
		self.m_ResetLabel:SetActive(false)
		self.m_CostLabel:SetActive(true)
	end

end

function COrgFuBenPage.OnRewardBtn(self, oBtn)
	printc("COrgFuBenPage.OnRewardBtn")
	COrgFuBenRewardView:ShowView()
end

function COrgFuBenPage.OnResetBtn(self, oBtn)
	printc("COrgFuBenPage.OnResetBtn")
	local orgpos = g_AttrCtrl.org_pos
	if g_OrgCtrl:GetPosition(g_AttrCtrl.org_pos).buy ~= COrgCtrl.Has_Power then
		g_NotifyCtrl:FloatMsg("仅会长和副会长可以重置")
		return
	end
	netorg.C2GSRestOrgFuBen()
end

function COrgFuBenPage.NewBox(self)
	local oBox = self.m_BossBox:Clone()
	oBox.m_NameLabel = oBox:NewUI(1, CLabel)
	oBox.m_Slider = oBox:NewUI(2, CSlider)
	oBox.m_ForeSprite = oBox:NewUI(3, CSprite)
	oBox.m_FinishSprite = oBox:NewUI(4, CSprite)
	oBox.m_SelectSprite = oBox:NewUI(5, CSprite)
	oBox.m_BossTexture = oBox:NewUI(6, CTexture)
	oBox.m_FinishSprite:SetActive(false)
	oBox.m_SelectSprite:SetActive(false)
	oBox:SetActive(true)
	return oBox
end

function COrgFuBenPage.RefreshBossGrid(self, boss_list)
	local boss_list = boss_list
	local oBox
	for i,v in ipairs(boss_list) do
		local oBox = self.m_BossGrid:GetChild(i) or self:NewBox()
		if oBox then
			oBox.m_ID = v.bid
			oBox.m_Slider:SetValue(v.hp/100)
			oBox.m_Slider:SetSliderText(v.hp.."%")
			local dData = data.orgdata.OrgFuBen[oBox.m_ID]
			oBox.m_Level = dData.level
			oBox.m_NameLabel:SetText(dData.name)
			oBox.m_BossTexture:LoadCardPhoto(dData.shape)
			oBox.m_BossTexture:SetGreySprites(v.status == 2)
			--1在战斗中,2未解锁,0死亡
			oBox.m_FinishSprite:SetActive(v.hp <= 0)
			oBox.m_SelectSprite:SetActive(v.status == 1)
			if v.status == 1 then
				if v.hp > 65 and v.hp <= 100 then
					oBox.m_ForeSprite:SetSpriteName("bg_gonghui_jindutiao03")
				elseif v.hp > 0 and v.hp <= 65 then
					oBox.m_ForeSprite:SetSpriteName("bg_gonghui_jindutiao04")
				else
					oBox.m_ForeSprite:SetSpriteName("bg_gonghui_jindutiao04")
				end
			elseif v.status == 2 then
				oBox.m_ForeSprite:SetSpriteName("bg_gonghui_jindutiao02")
			end
			oBox:AddUIEvent("click", callback(self, "OnClickBossBox", oBox))
			self.m_BossGrid:AddChild(oBox)
		end
	end
	self.m_BossGrid:Reposition()
end

function COrgFuBenPage.OnClickBossBox(self, oBox)
	local openGrade = data.globalcontroldata.GLOBAL_CONTROL.org_activity.open_grade
	if openGrade > g_AttrCtrl.grade then
		g_NotifyCtrl:FloatMsg(string.format("角色需要达到%d级可开启赏金玩法", openGrade))
		return
	end
	--[[
	if oBox.m_Level > g_OrgCtrl.m_Org.info.level then
		g_NotifyCtrl:FloatMsg(string.format("公会等级需要达到%d级才可击杀该赏金头领", oBox.m_Level))
		return
	end
	]]
	netorg.C2GSClickOrgFBBoss(oBox.m_ID)
	--点击的时候发一次给服务器用来刷新
	netorg.C2GSOpenOrgFBUI()
end

function COrgFuBenPage.RefreshOrgBossHP(self)
	local dInfo = g_OrgCtrl:GetOrgBossInfo()
	for i,oBox in ipairs(self.m_BossGrid:GetChildList()) do
		if oBox.m_ID == data.boss_id then
			oBox.m_Slider:SetValue(dInfo.percent)
			return
		end
	end
end

return COrgFuBenPage