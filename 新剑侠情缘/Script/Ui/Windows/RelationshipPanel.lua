local tbUi = Ui:CreateClass("RelationshipPanel")
tbUi.tbOnClick =
{
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,
}

local tbTypeIds = {
	Self = {0},	--主人
	Sworns = {12, 11, 10},
	Teachers = {3, 4},
	Students = {5, 6, 7, 8, 9},
	Couple = {1},	--夫妻
	BiWuZhaoQin = {2},	--情缘
	OtherBestFriends = {13, 14, 2},	--挚友
}

function tbUi:RegisterEvent()
	return {
		{UiNotify.emNOTIFY_SYNC_VIEW_RELATION, self.OnDataChange},
		{UiNotify.emNOTIFY_MAP_ENTER, self.OnEnterMap},
	}
end

function tbUi:OnOpen(nPlayerId)
	self:Refresh(nPlayerId)
end

function tbUi:OnClose()
	if 	self.nPlayerId == me.dwID then
		local bCanNotViewFriend = not self.pPanel:Toggle_GetChecked("Toggle1")
		local bCanNotViewStrange = not self.pPanel:Toggle_GetChecked("Toggle2")
		FriendShip:CheckChangeCanViewRelation(bCanNotViewFriend, bCanNotViewStrange)
	end
end

function tbUi:OnDataChange(nPlayerId)
	self:Refresh(nPlayerId)
end

function tbUi:OnEnterMap()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi:ResetUI()
	self.pPanel:Label_SetText("Role", "")

	for _, tbIds in pairs(tbTypeIds) do
		for _, nId in ipairs(tbIds) do
			self:UpdateNode(nId)
		end
	end
end

-- [dwRoleId] = {
-- 	nUpdateTime  = 123;
	-- Self = {};
	-- Marry = {};
	-- Engaged ={};
	-- BiWuZhaoQin = {};
	-- Teachers = { {}, ... };
	-- Students= { {}, ... };
	-- Sworns= { {}, ... };
	-- OtherBestFriends= { {}, ... };
-- };
function tbUi:Refresh(nPlayerId)
	self.nPlayerId = nPlayerId or me.dwID
	local bIsMy = self.nPlayerId == me.dwID
	self.pPanel:SetActive("Toggle1", bIsMy)
	self.pPanel:SetActive("Toggle2", bIsMy)
	if bIsMy then
		self.pPanel:Toggle_SetChecked("Toggle1", me.GetUserValue(FriendShip.SAVE_GROUP, FriendShip.SAVE_KEY_VIEW_FRIEND) == 0)
		self.pPanel:Toggle_SetChecked("Toggle2", me.GetUserValue(FriendShip.SAVE_GROUP, FriendShip.SAVE_KEY_VIEW_STRANGE) == 0)
	end

	self:ResetUI()

	local tbData = FriendShip:GetViewRelationData(self.nPlayerId)
	if not tbData then
		return
	end

	self.pPanel:Label_SetText("Role", string.format("%s的关系谱", tbData.Self[1]))

	self.bSelfMale = tbData.Self[4]
	self:UpdateNode(tbTypeIds.Self[1], tbData.Self)
	local bBiWuZhaoQinUsed = self:UpdateLovers(tbData.Marry, tbData.Engaged, tbData.BiWuZhaoQin)
	self:UpdateTeachers(tbData.Teachers)
	self:UpdateStudents(tbData.Students)
	self:UpdateSwornFriends(tbData.Sworns)
	self:UpdateFriends(tbData.OtherBestFriends, bBiWuZhaoQinUsed)
end

function tbUi:UpdateLovers(tbMarry, tbEngaged, tbBiWuZhaoQin)
	local bBiWuZhaoQinUsed = false
	self.Head2.pPanel:SetActive("Mark2", false)
	self.pPanel:Label_SetText("Relationship5", "挚友")
	local szDesc, bEngaged = self:GetLoverDesc(tbMarry, tbEngaged, tbBiWuZhaoQin)
	self.pPanel:Label_SetText("Relationship1", szDesc)

	local tbCouple = tbMarry or tbEngaged
	local nCoupleId = tbTypeIds.Couple[1]
	local szRelation = self.bSelfMale and "妻" or "夫"
	if not tbCouple and not tbBiWuZhaoQin then
		self:UpdateNode(nCoupleId, nil, szRelation)
		return bBiWuZhaoQinUsed
	end

	szRelation = "缘"
	if tbCouple then
		szRelation = tbCouple[4] and "妻" or "夫"
	end
	self:UpdateNode(nCoupleId, tbCouple or tbBiWuZhaoQin, szRelation)
	if tbCouple and tbBiWuZhaoQin and tbCouple[1]~=tbBiWuZhaoQin[1] then
		self.Head2.pPanel:SetActive("Mark2", true)
		self.pPanel:Label_SetText("Relationship5", "情缘")
		self:UpdateNode(tbTypeIds.BiWuZhaoQin[1], tbBiWuZhaoQin)
		bBiWuZhaoQinUsed = true
	end

	local pHead = self["Head"..nCoupleId]
	pHead.pPanel:Sprite_SetSprite("Mark1", bEngaged and "Relationship3" or "Relationship4")

	return bBiWuZhaoQinUsed
end

function tbUi:GetLoverDesc(tbMarry, tbEngaged, tbBiWuZhaoQin)
	if not tbMarry and not tbEngaged and not tbBiWuZhaoQin then
		return "侠侣", false
	end

	local tbCouple = tbMarry or tbEngaged
	if not tbCouple then
		return "情缘", false
	end

	return tbMarry and "侠侣" or (tbCouple[4] and "未婚妻" or "未婚夫"), not tbMarry
end

function tbUi:UpdateTeachers(tbTeachers)
	if not next(tbTeachers or {}) then
		return
	end
	for i, tb in ipairs(tbTeachers) do
		self:UpdateNode(tbTypeIds.Teachers[i], tb)
	end
end

function tbUi:UpdateStudents(tbStudents)
	if not next(tbStudents or {}) then
		return
	end
	for i, tb in ipairs(tbStudents) do
		self:UpdateNode(tbTypeIds.Students[i], tb)
	end
end

function tbUi:UpdateSwornFriends(tbFriends)
	if not next(tbFriends or {}) then
		return
	end
	for i, tb in ipairs(tbFriends) do
		self:UpdateNode(tbTypeIds.Sworns[i], tb)
	end
end

function tbUi:UpdateFriends(tbFriends, bBiWuZhaoQinUsed)
	if not next(tbFriends or {}) then
		return
	end
	for i, tb in ipairs(tbFriends) do
		if i>#tbTypeIds.OtherBestFriends then
			break
		end
		if i==#tbTypeIds.OtherBestFriends and bBiWuZhaoQinUsed then
			break
		end
		self:UpdateNode(tbTypeIds.OtherBestFriends[i], tb)
	end
end

function tbUi:UpdateNode(nId, tbData, szRelation)
	local pHead = self["Head"..nId]
	pHead.pPanel.OnTouchEvent = function() end --disable
	if szRelation then
    	pHead.pPanel:Label_SetText("MarkTxt"..nId, szRelation)
    end
	if not tbData then
		pHead.pPanel:Label_SetText("Name"..nId, "")
		pHead.pPanel:Sprite_SetSprite("HeadIcon"..nId, "CommonHead", "UI/Atlas/Head/Partner/Partner_Others_02.prefab")
		return
	end
	local szName, nPortrait, nPid = unpack(tbData)
	pHead.pPanel:Label_SetText("Name"..nId, szName)

	local szSprite, szAtlas = PlayerPortrait:GetPortraitIcon(nPortrait)
    pHead.pPanel:Sprite_SetSprite("HeadIcon"..nId, szSprite, szAtlas)

    pHead.pPanel.OnTouchEvent = function()
    	self:ShowPopUp(nPid, szName)
	end
end

function tbUi:ShowPopUp(nPid, szName)
	if self.nPlayerId==nPid  or nPid == me.dwID then
		return
	end
	FriendShip:OnChatClickRolePopup(nPid, false, nil,nil,szName)
end