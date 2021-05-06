local CHouseFriendPart = class("CHouseFriendPart", CBox)

function CHouseFriendPart.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_InfoGrid = self:NewUI(1, CGrid)
	self.m_InfoBox = self:NewUI(2, CBox)
	self.m_NoFriendBox = self:NewUI(3, CTexture)
	self:InitContent()
end

function CHouseFriendPart.InitContent(self)
	self.m_InfoBoxArr = {}
	self.m_InfoBox:SetActive(false)
end

function CHouseFriendPart.SetData(self)
	self:SetActive(true)
	for i,v in ipairs(g_HouseCtrl.m_FriendList) do
		if self.m_InfoBoxArr[i] == nil then
			self.m_InfoBoxArr[i] = self:CreateInfoBox()
		end
		self.m_InfoBoxArr[i]:SetData(v)
		self.m_InfoBoxArr[i]:SetActive(true)
		if i == 1 and g_HouseCtrl.m_ShowFirstFriendEffect == true then
			g_HouseCtrl.m_ShowFirstFriendEffect = false
			self.m_InfoBoxArr[i]:AddEffect("bordermove", nil, nil, 6)
		else
			self.m_InfoBoxArr[i]:DelEffect("bordermove")
		end
	end
	g_HouseCtrl.m_ShowFirstFriendEffect = false
	self.m_NoFriendBox:SetActive(#g_HouseCtrl.m_FriendList <= 0)
	self.m_InfoGrid:SetActive(#g_HouseCtrl.m_FriendList > 0)

	for i = #g_HouseCtrl.m_FriendList + 1, #self.m_InfoBoxArr do
		self.m_InfoBoxArr[i]:SetActive(false)
	end
end

function CHouseFriendPart.CreateInfoBox(self)
	local oInfoBox = self.m_InfoBox:Clone()
	oInfoBox.m_AvatarSprite = oInfoBox:NewUI(1, CSprite)
	oInfoBox.m_NameLabel = oInfoBox:NewUI(2, CLabel)
	oInfoBox.m_FriendshipLabel = oInfoBox:NewUI(3, CLabel)
	oInfoBox.m_TeaArtMark = oInfoBox:NewUI(4, CSprite)
	oInfoBox.m_ItemSprite = oInfoBox:NewUI(5, CSprite)
	oInfoBox.m_MarkGrid = oInfoBox:NewUI(6, CGrid)
	oInfoBox:AddUIEvent("click", callback(self, "OnClickInfoBox", oInfoBox))
	oInfoBox.m_TeaArtMark:AddUIEvent("click", callback(self, "OnClickTeaArt", oInfoBox))
	oInfoBox.m_ItemSprite:AddUIEvent("click", callback(self, "OnClickItem", oInfoBox))
	self.m_InfoGrid:AddChild(oInfoBox)

	function oInfoBox.SetData(self, oData)
		local friendData = g_FriendCtrl:GetFriend(oData.frd_pid)
		oInfoBox.m_Data = oData
		oInfoBox.m_AvatarSprite:SpriteAvatar(friendData.shape)
		oInfoBox.m_NameLabel:SetText(friendData.name)
		oInfoBox.m_FriendshipLabel:SetText((friendData.friend_degree or "0"))
		oInfoBox.m_TeaArtMark:SetActive(oData.desk_empty == 1)
		oInfoBox.m_ItemSprite:SetActive(oData.coin ~= 0)
		oInfoBox.m_MarkGrid:Reposition()
	end

	return oInfoBox
end

function CHouseFriendPart.OnClickInfoBox(self, oInfoBox)
	-- printc("OnClickInfoBox: " .. oInfoBox.m_Data.frd_pid)
	nethouse.C2GSEnterHouse(oInfoBox.m_Data.frd_pid)
end

function CHouseFriendPart.OnClickTeaArt(self, oInfoBox)
	-- printc("OnClickTeaArt: " .. oInfoBox.m_Data.frd_pid)
	nethouse.C2GSOpenWorkDesk(oInfoBox.m_Data.frd_pid)
end

function CHouseFriendPart.OnClickItem(self, oInfoBox)
	-- printc("OnClickItem: " .. oInfoBox.m_Data.frd_pid)
	nethouse.C2GSRecieveHouseCoin(oInfoBox.m_Data.frd_pid)
end

return CHouseFriendPart