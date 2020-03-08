local tbUi = Ui:CreateClass("WeddingWelcomeApplyPanel");
tbUi.Friend_List = 1
tbUi.Kin_List	 = 2
tbUi.Apply_List  = 3

local szNoneFriendTip = "暂无可邀请的好友"
local szNoneKinMemberTip = "暂无可邀请的家族成员"
local szNoneApplyTip = "暂无可邀请的申请列表"

tbUi.tbSetting = 
{
	[tbUi.Friend_List] = {
		szBtnName = "Tab1";
		fnGetList = function () return Wedding:GetFriendList() end;
		fnGetNoneTip = function () return szNoneFriendTip end;
		fnSetItem = function (itemObj)
			local tbRoleInfo = itemObj.tbInfo
			local szName = tbRoleInfo.szName or tbRoleInfo.szWantedName;
			local nLevel = tbRoleInfo.nLevel;
			itemObj.pPanel:Label_SetText("RoleName", szName);
			itemObj.pPanel:Label_SetText("lbLevel", nLevel);
			local SpFaction = Faction:GetIcon(tbRoleInfo.nFaction)
			itemObj.pPanel:Sprite_SetSprite("SpFaction",  SpFaction);
			local szPortrait, szAltas = PlayerPortrait:GetSmallIcon(tbRoleInfo.nPortrait)
			itemObj.pPanel:Sprite_SetSprite("SpRoleHead",  szPortrait, szAltas);
			local nHonorLevel = tbRoleInfo.nHonorLevel or 0
			itemObj.pPanel:SetActive("PlayerTitle", nHonorLevel > 0);
			if nHonorLevel > 0 then
				itemObj.pPanel:Sprite_Animation("PlayerTitle", "Title" .. nHonorLevel .. "_");
			end
			local nVipLevel = tbRoleInfo.nVipLevel or 0
			if nVipLevel == 0 then
				itemObj.pPanel:SetActive("VIP", false)
			else
				itemObj.pPanel:SetActive("VIP", true)
				itemObj.pPanel:Sprite_Animation("VIP",  Recharge.VIP_SHOW_LEVEL[nVipLevel]);
			end
		end;
		fnOnClick = function (itemObj)
			local tbRoleInfo = itemObj.tbInfo
			RemoteServer.OnWeddingRequest("SendWelcome", Wedding.Welcome_PersonalFriend, tbRoleInfo.dwID);
		end;
		nOneKeyType = Wedding.Welcome_Onekey_Frined;
		fnCheckOneKey = function () 
			local tbList = Wedding:GetFriendList()
			if not next(tbList) then
				return false, szNoneFriendTip
			end
			return true
		end;
	};
	[tbUi.Kin_List] = {
		szBtnName = "Tab2";
		fnGetList = function () return Wedding:GetKinMember() end;
		fnGetNoneTip = function ()
			if me.dwKinId > 0 then
				return szNoneFriendTip 
			else
				return "请先加入家族"
			end 
		end;
		fnSetItem = function (itemObj)
			local tbMemberData = itemObj.tbInfo
			local szName = tbMemberData.szName or "-";
			local nLevel = tbMemberData.nLevel;
			itemObj.pPanel:Label_SetText("RoleName", szName);
			itemObj.pPanel:Label_SetText("lbLevel", nLevel);
			local SpFaction = Faction:GetIcon(tbMemberData.nFaction)
			itemObj.pPanel:Sprite_SetSprite("SpFaction",  SpFaction);
			local szPortrait, szAltas = PlayerPortrait:GetSmallIcon(tbMemberData.nPortrait)
			itemObj.pPanel:Sprite_SetSprite("SpRoleHead",  szPortrait, szAltas);
			local nHonorLevel = tbMemberData.nHonorLevel or 0
			itemObj.pPanel:SetActive("PlayerTitle", nHonorLevel > 0);
			if nHonorLevel > 0 then
				itemObj.pPanel:Sprite_Animation("PlayerTitle", "Title" .. nHonorLevel .. "_");
			end
			local nVipLevel = tbMemberData.nVipLevel or 0
			if nVipLevel == 0 then
				itemObj.pPanel:SetActive("VIP", false)
			else
				itemObj.pPanel:SetActive("VIP", true)
				itemObj.pPanel:Sprite_Animation("VIP",  Recharge.VIP_SHOW_LEVEL[nVipLevel]);
			end
		end;
		fnOnClick = function (itemObj)
			local tbMemberData = itemObj.tbInfo
			RemoteServer.OnWeddingRequest("SendWelcome", Wedding.Welcome_PersonalKin, tbMemberData.nMemberId);
		end;
		nOneKeyType = Wedding.Welcome_Onekey_Kin;
		fnRequestData = function () 
			if me.dwKinId > 0 then
				Kin:UpdateMemberList(); 
			end
		end;
		fnCheckOneKey = function () 
			local tbList = Wedding:GetKinMember()
			if not next(tbList) then
				return false, szNoneKinMemberTip
			end
			return true
		end;
	};
	[tbUi.Apply_List] = {
		szBtnName = "Tab3";
		fnGetList = function () return Wedding:GetWeddingMapApply() end;
		fnGetNoneTip = function () return "暂无人申请" end;
		fnSetItem = function (itemObj)
			itemObj["BtnInvitation"].pPanel:Label_SetText("Label", "同意")
			local tbInfo = itemObj.tbInfo
			local szName = tbInfo.szName or "-";
			local nLevel = tbInfo.nLevel;
			itemObj.pPanel:Label_SetText("RoleName", szName);
			itemObj.pPanel:Label_SetText("lbLevel", nLevel);
			local SpFaction = Faction:GetIcon(tbInfo.nFaction)
			itemObj.pPanel:Sprite_SetSprite("SpFaction",  SpFaction);
			local szPortrait, szAltas = PlayerPortrait:GetSmallIcon(tbInfo.nPortrait)
			itemObj.pPanel:Sprite_SetSprite("SpRoleHead",  szPortrait, szAltas);
			local nHonorLevel = tbInfo.nHonorLevel or 0
			itemObj.pPanel:SetActive("PlayerTitle", nHonorLevel > 0);
			if nHonorLevel > 0 then
				itemObj.pPanel:Sprite_Animation("PlayerTitle", "Title" .. nHonorLevel .. "_");
			end
			local nVipLevel = tbInfo.nVipLevel or 0
			if nVipLevel == 0 then
				itemObj.pPanel:SetActive("VIP", false)
			else
				itemObj.pPanel:SetActive("VIP", true)
				itemObj.pPanel:Sprite_Animation("VIP",  Recharge.VIP_SHOW_LEVEL[nVipLevel]);
			end
			itemObj.pPanel:Label_SetText("FamilyName", tbInfo.szKinName or "-");
		end;
		fnOnClick = function (itemObj)
			local tbInfo = itemObj.tbInfo
			RemoteServer.OnWeddingRequest("SendWelcome", Wedding.Welcome_PersonalApply, tbInfo.nPlayerId);
		end;
		fnCheckOneKey = function () 
			local tbList = Wedding:GetWeddingMapApply()
			if not next(tbList) then
				return false, szNoneApplyTip
			end
			return true
		end;
		nOneKeyType = Wedding.Welcome_Onekey_Apply;
	};
}
function tbUi:OnOpen(nType)
	Wedding:RequestWelcome()
end

function tbUi:OnOpenEnd(nType)
	self:SwitchContainer(nType or self.Friend_List)
end

-- 家族成员刷新不是实时的，只有家族成员上线后家族数据有变化才能同步到数据
function tbUi:RefreshUi(nListType)
	local tbSetting = self.tbSetting[nListType]
	if not tbSetting then
		return
	end
	if tbSetting.fnRequestData then
		tbSetting.fnRequestData()
	end
	local tbList = tbSetting.fnGetList()
	local bHaveData = next(tbList) and true or false
	self.pPanel:SetActive("Tip", not bHaveData)
	self.pPanel:Label_SetText("Tip", tbSetting.fnGetNoneTip())
	self.pPanel:SetActive("ScrollView", bHaveData)
	self.pPanel:Label_SetText("InvitationCard", Wedding:GetWelcomeCount())
	local bApplyList = (nListType == self.Apply_List)
	self.pPanel:SetActive("BtnEmpty", bApplyList)
	local fnSetItem = function(itemObj, nIdx)
		itemObj.nListType = nListType
		local tbInfo = tbList[nIdx]
		if tbInfo then
			itemObj.pPanel:SetActive("FamilyName", bApplyList)
			itemObj.pPanel:SetActive("FamilyTitle", bApplyList)
			itemObj.pPanel:SetActive("AlreadyInvited", false)
			itemObj["BtnInvitation"].pPanel:Label_SetText("Label", "邀请")
			itemObj.tbInfo = tbInfo;
			tbSetting.fnSetItem(itemObj)
			itemObj["BtnInvitation"].tbInfo = tbInfo
			itemObj["BtnInvitation"].pPanel.OnTouchEvent = tbSetting.fnOnClick;
		end
	end
	self.ScrollView:Update(#tbList, fnSetItem)
end

function tbUi:SwitchContainer(nType)
	nType = nType or self.nType
	for nListType, v in pairs(self.tbSetting) do
		if nListType == nType then
			self.nType = nListType
			self:RefreshUi(nListType)
		end
		self.pPanel:Toggle_SetChecked(v.szBtnName, nListType == nType)
	end
	if nType == self.Apply_List then
		Ui:ClearRedPointNotify("Wedding_ApplyWelcome");
	end
end

function tbUi:OnSynKinDataFinish()
	if self.nType and self.nType == tbUi.Kin_List then
		self:SwitchContainer()
	end
end

function tbUi:RegisterEvent()
    return
    {
        { UiNotify.emNOTIFY_SYNC_WEDDING_WELCOME,           self.SwitchContainer},
        { UiNotify.emNOTIFY_SYNC_KIN_DATA,           self.OnSynKinDataFinish},
    };
end

tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end;
	Tab1 = function (self)
		self:SwitchContainer(self.Friend_List)
	end;
	Tab2 = function (self)
		self:SwitchContainer(self.Kin_List)
	end;
	Tab3 = function (self)
		self:SwitchContainer(self.Apply_List)
	end;
	BtnInviteAll = function (self)
		local tbSetting = self.tbSetting[self.nType]
		local fnCheckOneKey = tbSetting.fnCheckOneKey
		if not fnCheckOneKey then
			return
		end
		local bRet, szMsg = fnCheckOneKey()
		if not bRet then
			me.CenterMsg(szMsg)
			return
		end

		RemoteServer.OnWeddingRequest("SendWelcome", tbSetting.nOneKeyType);
	end;
	BtnEmpty = function (self)
		if self.nType ~= self.Apply_List then
			return
		end
		local tbSetting = self.tbSetting[self.nType]
		if not tbSetting then
			return
		end
		local tbList = tbSetting.fnGetList()
		if not next(tbList) then
			me.CenterMsg("没有可清理的申请信息", true)
			return
		end
		RemoteServer.OnWeddingRequest("ClearWelcomeApply");
	end;
}
