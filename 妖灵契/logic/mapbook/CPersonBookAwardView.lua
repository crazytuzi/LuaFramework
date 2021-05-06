local CPersonBookAwardView = class("CPersonBookAwardView", CViewBase)


function CPersonBookAwardView.ctor(self, cb)
	CViewBase.ctor(self, "UI/MapBook/MapBookAwardView.prefab", cb)
	self.m_ExtendClose = "Black"
	self.m_DepthType = "Dialog"
end

function CPersonBookAwardView.OnCreateView(self)
	self.m_AutoBtn = self:NewUI(1, CButton)
	self.m_TitleLabel = self:NewUI(2, CLabel)
	self.m_Grid = self:NewUI(3, CGrid)
	self.m_ItemClone = self:NewUI(4, CItemTipsBox)
	self:InitContent()
end

function CPersonBookAwardView.InitContent(self)
	self.m_TitleLabel:SetText("本次挑战可获得如下奖励")
	self.m_ItemClone:SetActive(false)
	self.m_AutoBtn:AddUIEvent("click", callback(self, "OnAutoGoto"))
	self.m_AutoBtn:SetText("前往挑战")
end

function CPersonBookAwardView.SetData(self, oData)
	self.m_Data = oData
	self:RefreshAward()
end

function CPersonBookAwardView.RefreshAward(self)
	--self.m_TitleLabel:SetText(data.title)
	if self.m_Data.name == "李铁蛋" then
		g_GuideCtrl:AddGuideUI("mapbook_reward_view_1007_go_btn", self.m_AutoBtn)
	else
		g_GuideCtrl:AddGuideUI("mapbook_reward_view_1007_go_btn")
	end
	local guide_ui = {"mapbook_reward_view_1007_go_btn"}
	g_GuideCtrl:LoadTipsGuideEffect(guide_ui)


	local itemList = g_DialogueCtrl:GetNpcFightRewardItmeList(self.m_Data.rewards)
	local partId = tonumber(data.globaldata.GLOBAL.partner_reward_itemid.value)
	if itemList and next(itemList) then
		self.m_Grid:Clear()
		for i, v in ipairs(itemList) do
			local oBox = self.m_ItemClone:Clone()
			oBox:SetActive(true)
			local config = {isLocal = true,}
			if v.sid == partId then
				oBox:SetItemData(v.sid, v.amount, v.partnerId, config)
			else
				oBox:SetItemData(v.sid, v.amount, nil, config)			
			end				
			self.m_Grid:AddChild(oBox)
		end
		self.m_Grid:Reposition()
	end
end


function CPersonBookAwardView.OnAutoGoto(self)
	local iPartnerID = self.m_Data.npc_type
	local nd = data.npcdata.NPC.GLOBAL_NPC[iPartnerID]

	local pos = {
		x = nd.x,
		y = nd.y,
		z = nd.z,
	}
	g_GuideCtrl:ReqForwardTipsGuideFinish("mapbook_reward_view_1007_go_btn")
	CAutoPath:AutoWalk(pos, nd.sceneId, nd.id)
	CMapBookView:CloseView()
	self:OnClose()
end

return CPersonBookAwardView