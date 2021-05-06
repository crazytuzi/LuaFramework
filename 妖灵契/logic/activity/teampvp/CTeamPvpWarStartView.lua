local CTeamPvpWarStartView = class("CTeamPvpWarStartView", CViewBase)

function CTeamPvpWarStartView.ctor(self, ob)
	CViewBase.ctor(self, "UI/Activity/TeamPvp/TeamPvpWarStartView.prefab", ob)
	self.m_GroupName = "WarMain"
end

function CTeamPvpWarStartView.OnCreateView(self)
	self.m_LeftSlot = self:NewUI(1, CBox)
	self.m_RightSlot = self:NewUI(2, CBox)
	self.m_Middle = self:NewUI(3, CBox)
	self:InitContent()
end

function CTeamPvpWarStartView.InitContent(self)
	local oView = CWarFloatView:GetView()
	if oView then
		oView:SetActive(false)
	end

	self.m_InfoBoxArr = {}
	self.m_LoadCount = 0
	self.m_InfoBoxArr[1] = self:CreateInfoBox(self.m_LeftSlot)
	self.m_InfoBoxArr[2] = self:CreateInfoBox(self.m_RightSlot)

	self:SetData()
end

function CTeamPvpWarStartView.OnShowView(self)
	if self.m_LoadCount < 4 then
		self:SetActive(false)
	end
end

function CTeamPvpWarStartView.CreateInfoBox(self, oInfoBox)
	oInfoBox.m_LeaderBox = oInfoBox:NewUI(1, CBox)
	oInfoBox.m_MemberBox = oInfoBox:NewUI(2, CBox)
	oInfoBox.m_Grid = oInfoBox:NewUI(3, CGrid)

	oInfoBox.m_MemberBoxArr = {self:CreateMemberBox(oInfoBox.m_LeaderBox), self:CreateMemberBox(oInfoBox.m_MemberBox)}
	oInfoBox.m_Grid:SetActive(false)
	oInfoBox.m_ShapeBoxArr = {}
	oInfoBox.m_Grid:InitChild(function (obj, index)
		oInfoBox.m_ShapeBoxArr[index] = self:CreateShapeBox(obj, index)
		return oInfoBox.m_ShapeBoxArr[index]
	end)

	function oInfoBox.SetData(self, oData)
		local parlist = {}
		for i,memberData in ipairs(oData) do
			oInfoBox.m_MemberBoxArr[i]:SetData(memberData)
			for _, partnerData in ipairs(memberData.parlist) do
				table.insert(parlist, partnerData)
			end
		end
		for i,v in ipairs(oInfoBox.m_ShapeBoxArr) do
			oInfoBox.m_ShapeBoxArr[i]:SetData(parlist[i])
		end
	end

	function oInfoBox.PlayAni(self)
		oInfoBox.m_Grid:SetActive(false)
		oInfoBox.m_Grid:SetActive(true)
	end

	return oInfoBox
end

function CTeamPvpWarStartView.CreateShapeBox(self, obj, idx)
	local oShapeBox = CBox.New(obj)
	oShapeBox.m_ShapeSprite = oShapeBox:NewUI(1, CSprite)
	oShapeBox.m_GradeLabel = oShapeBox:NewUI(2, CLabel)
	oShapeBox.m_ShapeBgSprite = oShapeBox:NewUI(3, CSprite)
	oShapeBox.m_StarGrid = oShapeBox:NewUI(4, CGrid)
	oShapeBox.m_StarBoxArr = {}
	oShapeBox.m_StarGrid:Clear()
	oShapeBox.m_StarGrid:InitChild(function (starBox, idx)
		local oStarBox = CBox.New(starBox)
		oStarBox.m_BgSprite = oStarBox:NewUI(1, CSprite)
		oStarBox.m_StarSprite = oStarBox:NewUI(2, CSprite)
		oStarBox.m_StarSprite:SetActive(false)
		oShapeBox.m_StarBoxArr[idx] = oStarBox
		return oStarBox
	end)
	function oShapeBox.SetData(self, oData)
		if oData then
			oShapeBox:SetActive(true)
			oShapeBox.m_ShapeSprite:SpriteAvatar(oData.shape)
			oShapeBox.m_GradeLabel:SetText(oData.grade)
			local partnerData = data.partnerdata.DATA[oData.par]
			if partnerData then
				g_PartnerCtrl:ChangeRareBorder(oShapeBox.m_ShapeBgSprite, partnerData.rare)
			end
			for i,v in ipairs(oShapeBox.m_StarBoxArr) do
				v.m_StarSprite:SetActive(i <= oData.star)
			end
		else
			oShapeBox:SetActive(false)
		end
	end
	return oShapeBox
end

function CTeamPvpWarStartView.CreateMemberBox(self, oMemberBox)
	oMemberBox.m_Texture = oMemberBox:NewUI(1, CTexture)
	oMemberBox.m_NameLabel = oMemberBox:NewUI(2, CLabel)
	oMemberBox.m_ParnetView = self
	function oMemberBox.SetData(self, oData)
		if oData then
			oMemberBox:SetActive(true)
			oMemberBox.m_ParnetView:SetTexture(oMemberBox.m_Texture, oData.shape)
			oMemberBox.m_NameLabel:SetText(oData.name)
		else
			oMemberBox:SetActive(false)
		end
	end
	return oMemberBox
end

function CTeamPvpWarStartView.SetData(self)
	self.m_Data = {g_TeamPvpCtrl:GetOwnTeamInfo(), g_TeamPvpCtrl:GetOtherTeamInfo()}
	for i,v in ipairs(self.m_Data) do
		self.m_InfoBoxArr[i]:SetData(v)
	end

end

function CTeamPvpWarStartView.SetTexture(self, oTexture, shape)
	oTexture:LoadArenaPhoto(shape, callback(self, "AfterLoadPhoto"))
end

function CTeamPvpWarStartView.AfterLoadPhoto(self)
	self.m_LoadCount = self.m_LoadCount + 1
	if self.m_LoadCount >= 4 then
		self:SetActive(true)
		self.m_TimerID = Utils.AddTimer(callback(self, "OnNotifyClose"), 0, 4)
		self.m_ShowTimerID = Utils.AddTimer(callback(self, "OnNotifyShow"), 0, 1)
	end
end

function CTeamPvpWarStartView.OnNotifyShow(self)
	self.m_Middle:SetActive(true)
	self.m_InfoBoxArr[1]:PlayAni()
	self.m_InfoBoxArr[2]:PlayAni()
end

function CTeamPvpWarStartView.Destroy(self)
	if self.m_TimerID then
		Utils.DelTimer(self.m_TimerID)
		self.m_TimerID = nil
	end
	if self.m_ShowTimerID then
		Utils.DelTimer(self.m_ShowTimerID)
		self.m_ShowTimerID = nil
	end
	CViewBase.Destroy(self)
	if g_WarCtrl:IsPlayRecord() and not g_NetCtrl:IsProtoRocord() then
		netwar.C2GSEndFilmBout(g_WarCtrl:GetWarID(), 1)
	end
end

function CTeamPvpWarStartView.OnNotifyClose(self)
	self:CloseView()
	if not g_WarCtrl:IsPlayRecord() then
		CWarFloatView:ShowView()
		CWarMainView:ShowView()
		local oView = CMainMenuView:GetView()
		if oView then
			oView:SetActive(true)
		end
	else
		CWarWatchView:ShowView()
	end
end

return CTeamPvpWarStartView
