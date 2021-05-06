local COrgRedBagView = class("COrgRedBagView", CViewBase)

function COrgRedBagView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Org/OrgRedBagView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function COrgRedBagView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_Container = self:NewUI(2, CWidget)
	self.m_GetPart = self:NewUI(3, CBox)
	self.m_DetailPart = self:NewUI(4, CBox)
	self:InitContent()
end

function COrgRedBagView.InitContent(self)
	self:InitGetPart()
	self:InitDetailPart()
end

function COrgRedBagView.InitGetPart(self)
	self.m_GetIcon = self.m_GetPart:NewUI(1, CSprite)
	self.m_GetName = self.m_GetPart:NewUI(2, CLabel)
	self.m_GetGold = self.m_GetPart:NewUI(3, CLabel)
	self.m_DetailLink = self.m_GetPart:NewUI(4, CLabel)
	self.m_LuckLabel = self.m_GetPart:NewUI(5, CLabel)
	self.m_DetailLink:AddUIEvent("click", callback(self, "OnShowDetail"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function COrgRedBagView.InitDetailPart(self)
	self.m_NameLabel = self.m_DetailPart:NewUI(1, CLabel)
	self.m_MyGoldLabel = self.m_DetailPart:NewUI(2, CLabel)
	self.m_TotalLabel = self.m_DetailPart:NewUI(3, CLabel)
	self.m_RestLabel = self.m_DetailPart:NewUI(4, CLabel)
	self.m_ScrollView = self.m_DetailPart:NewUI(5, CScrollView)
	self.m_Grid = self.m_DetailPart:NewUI(6, CGrid)
	self.m_ItemBox = self.m_DetailPart:NewUI(7, CBox)
	self.m_IconSpr = self.m_DetailPart:NewUI(8, CSprite)
	self.m_MaxItemBox = self.m_DetailPart:NewUI(9, CBox)
	self.m_ScrollBtn = self.m_DetailPart:NewUI(10, CButton)
	self.m_ScrollBtn:AddUIEvent("click", callback(self, "DownMove"))
	self.m_ItemBox:SetActive(false)
	self.m_ScrollBtn:SetActive(false)
	self.m_MaxItemBox:SetActive(false)
end

function COrgRedBagView.SetType(self, sType)
	self.m_Type = sType
end

function COrgRedBagView.DoEffect(self)
	self.m_Container:SetLocalScale(Vector3.New(0.1, 0.1, 0.1))
	DOTween.DOScale(self.m_Container.m_Transform, Vector3.New(1, 1, 1), 1)
	DOTween.DOLocalRotate(self.m_Container.m_Transform, Vector3.New(0, 0, 720), 1, enum.DOTween.RotateMode.LocalAxisAdd)
end

function COrgRedBagView.OnShowDetail(self)
	if self.m_ID then
		if self.m_Type == "chat" then
			netchat.C2GSHongBaoOption("look", self.m_ID)
		else
			netorg.C2GSOrgRedPacket(self.m_ID)
		end
	end
end

function COrgRedBagView.RefreshDetail(self, data)
	self.m_DetailPart:SetActive(true)
	self.m_GetPart:SetActive(false)
	self.m_DetailData = data
	self.m_NameLabel:SetText(data["title"])
	self.m_IconSpr:SpriteAvatar(data["shape"])
	
	local getamount = #data["draw_list"]
	self.m_TotalLabel:SetText(string.format("已领取 %d/%d", getamount, data["amount"]))
	self.m_RestLabel:SetText(string.format("剩余 %d#w1", data["remain_gold"]))
	self.m_Grid:Clear()
	local maxidx = nil
	local maxgold = 0
	local mygold = 0
	for i, redpacked in ipairs(data["draw_list"]) do
		if redpacked.gold > maxgold then
			maxgold = redpacked.gold
			maxidx = i
		end
		if redpacked.pid == g_AttrCtrl.pid then
			mygold = redpacked.gold
		end
	end
	for i, redpacked in ipairs(data["draw_list"]) do
		local itemobj = self:CreateItem(i == maxidx)
		itemobj.m_NameLabel:SetText(redpacked.name)
		itemobj.m_GoldLable:SetText(tostring(redpacked.gold))
		self.m_Grid:AddChild(itemobj)
	end
	
	self.m_ScrollBtn:SetActive(self.m_Grid:GetCount() > 6)
	self.m_Grid:Reposition()
	self.m_ScrollView:ResetPosition()
	self.m_MyGoldLabel:SetText(string.format("本次抢夺：%d#w1", mygold))
end

function COrgRedBagView.RefreshGet(self, data)
	self.m_DetailPart:SetActive(false)
	self.m_GetPart:SetActive(true)
	self.m_ID = data.idx
	self.m_GetName:SetText(data.title)
	self.m_GetIcon:SpriteAvatar(data.shape)
	if data.gold == 0 then
		self.m_GetGold:SetActive(false)
		self.m_LuckLabel:SetText("很遗憾，红包已经空了")
	else
		self.m_GetGold:SetActive(true)
		self.m_LuckLabel:SetText("恭喜你成功领取了")
		self.m_GetGold:SetText(string.format("%d#w1", data.gold))
	end
end

function COrgRedBagView.CreateItem(self, ismax)
	local itemobj = self.m_ItemBox:Clone()
	if ismax then
		itemobj = self.m_MaxItemBox:Clone()
	end
	itemobj.m_NameLabel = itemobj:NewUI(1, CLabel)
	itemobj.m_GoldLable = itemobj:NewUI(2, CLabel)
	itemobj:SetActive(true)
	return itemobj
end

function COrgRedBagView.DownMove(self)
	self.m_ScrollView:Scroll(-1)
end

return COrgRedBagView