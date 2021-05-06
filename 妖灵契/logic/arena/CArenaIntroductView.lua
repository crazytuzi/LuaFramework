local CArenaIntroductView = class("CArenaIntroductView", CViewBase)

function CArenaIntroductView.ctor(self, ob)
	CViewBase.ctor(self, "UI/Arena/ArenaIntroductView.prefab", ob)
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
end

function CArenaIntroductView.OnCreateView(self)
	self.m_ScrollView = self:NewUI(1, CScrollView)
	self.m_GradeInfoGrid = self:NewUI(2, CGrid)
	self.m_InfoBox = self:NewUI(3, CBox)
	self.m_ItemBox = self:NewUI(4, CItemTipsBox)
	self.m_PlayerBox = self:NewUI(5, CBox)

	self:InitContent()
end

function CArenaIntroductView.InitContent(self)
	self.m_InfoBox:SetActive(false)
	self:SetActive(false)
	self:SetData()
end

function CArenaIntroductView.SetData(self)
	self.m_CurrentGrade = g_ArenaCtrl:GetGradeDataByPoint(g_ArenaCtrl.m_ArenaPoint)
	self.m_SortIds = g_ArenaCtrl:GetSortIds()
	for i = 1, #self.m_SortIds do
		local oData = g_ArenaCtrl:GetArenaGradeData(#self.m_SortIds - self.m_SortIds[i] + 1)
		local oInfoBox = self.m_InfoBox:Clone("oInfoBox")
		self:InitInfoBox(oInfoBox, oData, i)
		if oData.id == self.m_CurrentGrade.id then
			self:InitInfoBox(self.m_PlayerBox, oData, i, true)
		end
		self.m_GradeInfoGrid:AddChild(oInfoBox)
	end
	
	self:SetActive(true)
end

function CArenaIntroductView.InitInfoBox(self, oInfoBox, data, index, isPlayer)
	oInfoBox:SetActive(true)

	-- oInfoBox.m_BgSprite = oInfoBox:NewUI(1, CSprite)
	oInfoBox.m_PointLabel = oInfoBox:NewUI(2, CLabel)
	oInfoBox.m_TitleSprite = oInfoBox:NewUI(3, CSprite)
	oInfoBox.m_ItemGrid = oInfoBox:NewUI(4, CGrid)
	oInfoBox.m_NumSprite = oInfoBox:NewUI(5, CSprite)
	oInfoBox.m_GradeLabel = oInfoBox:NewUI(6, CLabel)
	oInfoBox.m_GradeLabel:SetText(data.rank_name)

	if index > 5 then
		oInfoBox.m_TitleSprite:SetSpriteName("pic_jinse")
	elseif index > 2 then
		oInfoBox.m_TitleSprite:SetSpriteName("pic_yinse")
	else
		oInfoBox.m_TitleSprite:SetSpriteName("pic_tongse")
	end
	local str = "text_%s_1"
	if isPlayer or (index > 2 and index <= 5) then
		str = "text_%s"
	end
	oInfoBox.m_NumSprite:SetSpriteName(string.format(str, index))

	if isPlayer then
		oInfoBox.m_PointLabel:SetText(g_ArenaCtrl.m_ArenaPoint)
	else
		oInfoBox.m_PointLabel:SetText(tostring(data.basescore))
	end
	for i,v in ipairs(data.weeky_award) do
		local oItemBox = self.m_ItemBox:Clone("oItemBox")
		oItemBox:SetItemData(v.id, v.num, nil, {isLocal = true, uiType = 2})
		oItemBox:SetActive(true)
		oInfoBox.m_ItemGrid:AddChild(oItemBox)
	end

	return oInfoBox
end

return CArenaIntroductView