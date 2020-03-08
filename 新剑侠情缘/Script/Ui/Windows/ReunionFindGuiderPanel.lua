local tbUi = Ui:CreateClass("ReunionFindGuiderPanel")
function tbUi:OnOpenEnd(tbFriendList)
	local fnUpdate = function (itemObj, nIdx)
		local tbInfo = FriendShip:GetFriendDataInfo(tbFriendList[nIdx])
		itemObj.pPanel:Label_SetText("IntimacyLevel", "亲密度等级：" .. FriendShip:GetImityLevel(tbInfo.nImity))
		itemObj.pPanel:Label_SetText("Name", tbInfo.szName)
		itemObj.pPanel:Label_SetText("lbLevel", tbInfo.nLevel)
		local szIcon, szAtlas = PlayerPortrait:GetPortraitIcon(tbInfo.nPortrait)
		itemObj.pPanel:Sprite_SetSprite("SpRoleHead", szIcon,szAtlas)
		itemObj.pPanel:Sprite_SetSprite("SpFaction", Faction:GetIcon(tbInfo.nFaction))
		local szRelation = "好友"
		if TeacherStudent:IsMyStudent(tbInfo.dwID) or TeacherStudent:IsMyTeacher(tbInfo.dwID) then
			szRelation = "师徒"
		elseif me.dwKinId ~= 0 and tbInfo.dwKinId == me.dwKinId then
			szRelation = "家族"
		end
		itemObj.pPanel:Label_SetText("Relationship", szRelation)
		itemObj.BtnReunion.pPanel.OnTouchEvent = function ()
			Reunion:TryApply(tbFriendList[nIdx])
		end
	end
	self.View:Update(#tbFriendList, fnUpdate)
	local nPlace = Reunion:GetReservedPlace()
	self.pPanel:Label_SetText("Tip", string.format("剩余重逢名额：%d", nPlace))
	self.pPanel:SetActive("NoFriendTip", #tbFriendList == 0)
end

-- function tbUi:_OnDataUpdate(...)
-- end

-- function tbUi:OnDataUpdate(szType, ...)
-- 	self:_OnDataUpdate(szType, ...)
-- end

-- function tbUi:RegisterEvent()
--     return {
--         { UiNotify.emNOTIFY_REUNION_DATA_UPDATE, self.OnDataUpdate, self }
--     }
-- end

tbUi.tbOnClick = 
{
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end
}