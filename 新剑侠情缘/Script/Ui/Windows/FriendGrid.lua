

--好友
local tbFriendGrid = Ui:CreateClass("FriendGrid");

tbFriendGrid.SetUiImity = function ( tbUi, tbRoleInfo )
	local nImity = tbRoleInfo[FriendShip.tbDataType.emFriendData_Imity]
	local tbImitySet = FriendShip.tbIntimacyLevel[tbRoleInfo.nImityLevel]
	tbUi.pPanel:Label_SetText("IntimacyLevel", tbRoleInfo.nImityLevel .. "级")
	local bFull = tbRoleInfo.nMaxImity == FriendShip.nMaxImitiy
	local szPerCentDesc = bFull  and "" or string.format("%d/%d", nImity, tbRoleInfo.nMaxImity)
	tbUi.pPanel:Label_SetText("IntimacyPercent", szPerCentDesc);
	if bFull then
		tbUi.pPanel:Sprite_SetFillPercent("Intimacy1", 1)
	else
		tbUi.pPanel:Sprite_SetFillPercent("Intimacy1", math.min(nImity / tbRoleInfo.nMaxImity, 1))
	end
end

local function InitRoleBase(self, tbRoleInfo, bNoKinName)
	self.tbRoleInfo = tbRoleInfo

	local nVipLevel = tbRoleInfo.nVipLevel
	local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbRoleInfo.nHonorLevel)
	if ImgPrefix then
		self.pPanel:SetActive("lbRoleName", true)
		self.pPanel:SetActive("lbRoleName2", false)
		self.pPanel:Label_SetText("lbRoleName", tbRoleInfo.szName or tbRoleInfo.szWantedName)
		self.pPanel:SetActive("PlayerTitle", true);
		self.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
		if not nVipLevel or  nVipLevel == 0 then
			self.pPanel:SetActive("VIP", false)
		else
			self.pPanel:SetActive("VIP", true)
			self.pPanel:Sprite_Animation("VIP",  Recharge.VIP_SHOW_LEVEL[nVipLevel]);
		end

	else
		self.pPanel:SetActive("lbRoleName", false)
		self.pPanel:SetActive("lbRoleName2", true)
		self.pPanel:Label_SetText("lbRoleName2", tbRoleInfo.szName or tbRoleInfo.szWantedName)
		self.pPanel:SetActive("PlayerTitle", false);

		if not nVipLevel or  nVipLevel == 0 then
			self.pPanel:SetActive("VIP2", false)
		else
			self.pPanel:SetActive("VIP2", true)
			self.pPanel:Sprite_Animation("VIP2",  Recharge.VIP_SHOW_LEVEL[nVipLevel]);
		end

	end
	self.pPanel:Label_SetText("lbLevel", tbRoleInfo.nLevel)

	if tbRoleInfo.szKinName and not bNoKinName then
		self.pPanel:Label_SetText("lbKinName", tbRoleInfo.szKinName)
	end

	local SpFaction = Faction:GetIcon(tbRoleInfo.nFaction)

	local szPortrait, szAltas = PlayerPortrait:GetSmallIcon(tbRoleInfo.nPortrait)
	self.pPanel:Sprite_SetSprite("SpFaction",  SpFaction);
	if tbRoleInfo.nState ~= 0 then
		self.pPanel:Sprite_SetSprite("SpRoleHead",  szPortrait, szAltas);
		self.pPanel:Sprite_SetGray("Main", false);
	else
		self.pPanel:Sprite_SetSpriteGray("SpRoleHead",  szPortrait, szAltas);
		self.pPanel:Sprite_SetGray("Main", true);
	end

	local tbCanRecalledList = FriendRecall:GetCanRecallList();
	local tbRecallAwardList = FriendRecall:GetRecallAwardList();
	local tbRecalledPlayerList = FriendRecall.tbRecalledPlayerList;
	local bSpecial = (tbCanRecalledList[tbRoleInfo.dwID] ~= nil or tbRecalledPlayerList[tbRoleInfo.dwID] ~= nil or tbRecallAwardList[tbRoleInfo.dwID] ~= nil);

	if self.pPanel:CheckHasChildren("BackMark") then
		self.pPanel:SetActive("BackMark", bSpecial);
	end
	
	if bSpecial then
		if tbRoleInfo.nState ~= 4 and tbRoleInfo.nState ~= 0 then
			self.pPanel:Button_SetSprite("Main", "BtnListFourthSpecialNormal", 1)
		end
		self.pPanel:Button_SetSprite("Main", "BtnListFourthSpecialPress", 3)
	else
		if tbRoleInfo.nState ~= 4 and tbRoleInfo.nState ~= 0 then
			self.pPanel:Button_SetSprite("Main", "BtnListFourthNormal", 1)
		end
		self.pPanel:Button_SetSprite("Main", "BtnListFourthPress", 3)
	end
end

function tbFriendGrid:RefreshMarkInfo(nId)
	if self:RefreshWeddingMark(nId) then
		return
	end

	if self:RefreshLoverMark(nId) then
		return;
	end

	if self:RefreshSwornFriendMark(nId) then
		return;
	end

	self:RefreshMasterMark(nId);
end

function tbFriendGrid:RefreshWeddingMark(nId)
	local bEngaged = Wedding:IsEngaged(me.dwID, nId)
	local bMarry = Wedding:IsLover(me.dwID, nId)
	self.pPanel:SetActive("UnmarriedMark", bEngaged)
	self.pPanel:SetActive("MarriedMark", bMarry)
	local bWeddingMark = bEngaged or bMarry
	self.pPanel:SetActive("MasterMark", not (bWeddingMark))
	local nWeddingSex = me.GetUserValue(Wedding.nSaveGrp, Wedding.nSaveKeyGender)
	local tbLabel = {"妻", "夫"}
	if tbLabel[nWeddingSex] then
		self.pPanel:Label_SetText("UnmarriedTxt", tbLabel[nWeddingSex])
		self.pPanel:Label_SetText("MarriedMarkTxt", tbLabel[nWeddingSex])
	end
	return bWeddingMark
end

function tbFriendGrid:RefreshLoverMark(nId)
	local bSworn = BiWuZhaoQin.nLoverId and BiWuZhaoQin.nLoverId == nId;
	self.pPanel:SetActive("MasterMark", bSworn)
	if bSworn then
		self.pPanel:Label_SetText("MarkTxt", "缘");
	end
	return bSworn
end

function tbFriendGrid:RefreshMasterMark(nId)
	local bStudent = TeacherStudent:IsMyStudent(nId)
	local bTeacher = TeacherStudent:IsMyTeacher(nId)
	self.pPanel:SetActive("MasterMark", bStudent or bTeacher)
	if bStudent then
		self.pPanel:Label_SetText("MarkTxt", "徒")
	elseif bTeacher then
		self.pPanel:Label_SetText("MarkTxt", "师")
	end
end

function tbFriendGrid:RefreshSwornFriendMark(nId)
	local bSworn = SwornFriends:IsConnected(nId)
	self.pPanel:SetActive("MasterMark", bSworn)
	if bSworn then
		self.pPanel:Label_SetText("MarkTxt", "拜")
	end
	return bSworn
end

function tbFriendGrid:SetData(tbRoleInfo, nSendLeftTimes, nGetLeftTimes)
	InitRoleBase(self, tbRoleInfo);
	self:RefreshMarkInfo(tbRoleInfo.dwID);

	if tbRoleInfo.nImityLevel then
		tbFriendGrid.SetUiImity(self, tbRoleInfo)
	end

	local szRemmarkName = FriendShip:GetRemarkName(tbRoleInfo.dwID)
	if Lib:IsEmptyStr(szRemmarkName) then
		self.pPanel:SetActive("Remarks", false)
	else
		self.pPanel:SetActive("Remarks", true)
		self.pPanel:Label_SetText("RemarksName", szRemmarkName)
	end

end

tbFriendGrid.tbOnClick = {};


function tbFriendGrid.tbOnClick:BtnChat()
	Ui:CloseWindow("SocialPanel")
	Ui:OpenWindow("ChatLargePanel", ChatMgr.ChannelType.Private, self.tbRoleInfo.dwID)
end

function tbFriendGrid.tbOnClick:BtnDetails()
	local tbRoleInfo = self.tbRoleInfo
	Ui:OpenWindowAtPos("RightPopup", 200, -55, "Friend", {dwRoleId = tbRoleInfo.dwID})
	self.pPanel:Toggle_SetChecked("Main", true)
	Ui("SocialPanel").nSelFriendIndex = self.index
end

function tbFriendGrid.tbOnClick:Head()
	self.tbOnClick.BtnDetails(self)
end

function tbFriendGrid.tbOnClick:BtnChange()
	FriendShip:SetRemarkName(self.tbRoleInfo.dwID);
end


tbFriendGrid.tbOnDrag =
{
	Main = function (self, szWnd, nX, nY)
		self.pScrollView:OnDragList(nY)
	end	;
}

tbFriendGrid.tbOnDragEnd =
{
	Main = function (self)
		self.pScrollView:OnDragEndList()
	end	;
}





---仇人
-------------------------
local tbEnemyGrid = Ui:CreateClass("EnemyGrid");

function tbEnemyGrid:SetData(tbRoleInfo)
	InitRoleBase(self, tbRoleInfo);
	self.pPanel:Label_SetText("IntimacyLevel", math.ceil(tbRoleInfo.nHate / 10000));
	local szRemmarkName = FriendShip:GetRemarkName(tbRoleInfo.dwID)
	if Lib:IsEmptyStr(szRemmarkName) then
		self.pPanel:SetActive("Remarks", false)
	else
		self.pPanel:SetActive("Remarks", true)
		self.pPanel:Label_SetText("RemarksName", szRemmarkName)
	end

end

tbEnemyGrid.tbOnClick = {};

function tbEnemyGrid.tbOnClick:BtnRevenge()
	FriendShip:DoRevenge(self.tbRoleInfo)
end

function tbEnemyGrid.tbOnClick:BtnDelete()
	FriendShip:DelEnemy(self.tbRoleInfo)
end

function tbEnemyGrid.tbOnClick:Head()
	self.pPanel:Toggle_SetChecked("Main", true)
end

function tbEnemyGrid.tbOnClick:BtnChange()
	FriendShip:SetRemarkName(self.tbRoleInfo.dwID);
end

tbEnemyGrid.tbOnDrag =
{
	Main = function (self, szWnd, nX, nY)
		self.pScrollView:OnDragList(nY)
	end	;
}

tbEnemyGrid.tbOnDragEnd =
{
	Main = function (self)
		self.pScrollView:OnDragEndList()
	end	;
}



---通缉
-----------------
local tbWantedGrid = Ui:CreateClass("WantedGrid")

function tbWantedGrid:SetData(tbRoleInfo)
	InitRoleBase(self, tbRoleInfo)

	self.nLeftTime = tbRoleInfo.nEndTime - GetTime()

	self.pPanel:SetActive("btnIssueWante", false)
	self.pPanel:SetActive("btnArrest", false)
	self.pPanel:SetActive("killedMark", false)
	self.pPanel:SetActive("Wanteding", false)

	self.pPanel:Label_SetText("lbSenderName",  tbRoleInfo.szSenderName)

	if tbRoleInfo.szCactherName then --抓捕到的
		self.nLeftTime = nil;
		self.pPanel:SetActive("killedMark", true)
		self.pPanel:Label_SetText("txtWantedLeftTime", tbRoleInfo.szCactherName)
	else
		if tbRoleInfo.bSended then --未抓捕到的
			if tbRoleInfo.dwSenderID == me.dwID then --自己不能抓捕
				self.pPanel:SetActive("Wanteding", true)
			else
				self.pPanel:SetActive("btnArrest", true)
			end

			self.pPanel:Label_SetText("txtWantedLeftTime", Lib:TimeDesc(self.nLeftTime))

		else --可补发的
			self.pPanel:SetActive("btnIssueWante", true)

			self.pPanel:Label_SetText("txtWantedLeftTime", Lib:TimeDesc(self.nLeftTime))
		end
	end
end

function tbWantedGrid:UpdateWantedTimer()
	if  self.nLeftTime then
		self.nLeftTime = self.nLeftTime - 1
		if self.nLeftTime > 0 then
			self.pPanel:Label_SetText("txtWantedLeftTime", Lib:TimeDesc2(self.nLeftTime))
		else
			return false --通知parent 删除自己
		end
	end
	return true
end

tbWantedGrid.tbOnClick = {};

function tbWantedGrid.tbOnClick:btnIssueWante()
	Ui:OpenWindow("WantedTips", self.tbRoleInfo.dwWantedID, self.tbRoleInfo.szWantedName)
end

function tbWantedGrid.tbOnClick:btnArrest()
	if DegreeCtrl:GetDegree(me, "Catch") == 0 then
		me.BuyTimes("Catch", 1);
		return
	end

	--客户端上本来收到的就是过滤后的， server 上检查同家族或者 好友关系了
	RemoteServer.RequestCatchHim(self.tbRoleInfo.dwWantedID, self.tbRoleInfo.dwSenderID)
end

function tbWantedGrid.tbOnClick:Head()
	self.pPanel:Toggle_SetChecked("Main", true)
end



----好友申请
-----------------
local tbFriendApplyGrid = Ui:CreateClass("FriendApplyGrid")

function tbFriendApplyGrid:SetData(tbRoleInfo)
	InitRoleBase(self, tbRoleInfo, false)
end

tbFriendApplyGrid.tbOnClick = {}

function tbFriendApplyGrid.tbOnClick:BtnAgree()
	FriendShip:AcceptFriendRequest(self.tbRoleInfo.dwID)
end

function tbFriendApplyGrid.tbOnClick:Head()
	Ui:OpenWindowAtPos("RightPopup", -182, -134, "RoleSelect", {dwRoleId = self.tbRoleInfo.dwID})
end


local tbChatListGrid = Ui:CreateClass("ChatListGrid")

function tbChatListGrid:SetData(tbRoleInfo)
	InitRoleBase(self, tbRoleInfo, true);

	local tbUnRead = ChatMgr.PrivateChatUnReadCache[tbRoleInfo.dwID]
	local nUnReadNum = tbUnRead and #tbUnRead or 0;
	if nUnReadNum > 0 then
		self.pPanel:SetActive("redmark", true)
		self.pPanel:Label_SetText("lbMsgNum", nUnReadNum)
	else
		self.pPanel:SetActive("redmark", false)
	end
	local dwMyRoleId = Player:GetMyRoleId()
	self.pPanel:SetActive("Stranger", not FriendShip:IsFriend(dwMyRoleId , tbRoleInfo.dwID))

	local szRemmarkName = FriendShip:GetRemarkName(tbRoleInfo.dwID)
	self.pPanel:SetActive("BtnChange", false)
	if Lib:IsEmptyStr(szRemmarkName) then
		self.pPanel:SetActive("Remarks", false)
	else
		self.pPanel:SetActive("Remarks", true)
		self.pPanel:Label_SetText("RemarksName", szRemmarkName)
	end

	self:RefreshMarkInfo(tbRoleInfo.dwID);
	self.pPanel:SetActive("BtnDetails", tbRoleInfo.dwID > 0)
end

function tbChatListGrid:RefreshMarkInfo(nId)
	local bWeddingMark = self:RefreshWeddingMark(nId)
	if bWeddingMark then
		return;
	end

	if self:RefreshLoverMark(nId) then
		return;
	end

	if self:RefreshSwornFriendMark(nId) then
		return;
	end

	self:RefreshMasterMark(nId);
end

function tbChatListGrid:RefreshWeddingMark(nId)
	local bEngaged = Wedding:IsEngaged(me.dwID, nId)
	local bMarry = Wedding:IsLover(me.dwID, nId)
	self.pPanel:SetActive("UnmarriedMark", bEngaged)
	self.pPanel:SetActive("MarriedMark", bMarry)
	local bWeddingMark = bEngaged or bMarry
	self.pPanel:SetActive("MasterMark", not (bWeddingMark))
	local nWeddingSex = me.GetUserValue(Wedding.nSaveGrp, Wedding.nSaveKeyGender)
	local tbLabel = {"妻", "夫"}
	if tbLabel[nWeddingSex] then
		self.pPanel:Label_SetText("UnmarriedTxt", tbLabel[nWeddingSex])
		self.pPanel:Label_SetText("MarriedMarkTxt", tbLabel[nWeddingSex])
	end
	return bWeddingMark
end


function tbChatListGrid:RefreshLoverMark(nId)
	local bSworn = BiWuZhaoQin.nLoverId and BiWuZhaoQin.nLoverId == nId;
	self.pPanel:SetActive("MasterMark", bSworn)
	if bSworn then
		self.pPanel:Label_SetText("MarkTxt", "缘");
	end
	return bSworn
end

function tbChatListGrid:RefreshSwornFriendMark(nId)
	local bSworn = SwornFriends:IsConnected(nId)
	self.pPanel:SetActive("MasterMark", bSworn)
	if bSworn then
		self.pPanel:Label_SetText("MarkTxt", "拜")
	end
	return bSworn
end

function tbChatListGrid:RefreshMasterMark(nId)
	local bStudent = TeacherStudent:IsMyStudent(nId)
	local bTeacher = TeacherStudent:IsMyTeacher(nId)
	self.pPanel:SetActive("MasterMark", bStudent or bTeacher)
	if bStudent then
		self.pPanel:Label_SetText("MarkTxt", "徒")
	elseif bTeacher then
		self.pPanel:Label_SetText("MarkTxt", "师")
	end
end

tbChatListGrid.tbOnClick =  {
	BtnDetails = function (self)
		local dwID = self.tbRoleInfo.dwID
		FriendShip:OnChatClickRolePopup(dwID, true)		
		self.pPanel:Toggle_SetChecked("Main", true)
	end;
}


local tbSendBlessGrid =  Ui:CreateClass("SendBlessGrid")

function tbSendBlessGrid:SetData( tbRoleInfo, bInAct)
	InitRoleBase(self, tbRoleInfo, true);

	self.pPanel:SetActive("BtnBlessing", bInAct)
	self.pPanel:SetActive("BtnGoldBlessing", bInAct)

	if bInAct then
		if tbRoleInfo.nSendedVal then
			self.pPanel:Button_SetText("BtnBlessing", "已祝福")
			self.pPanel:SetActive("BtnGoldBlessing", false)
			self.pPanel:Button_SetEnabled("BtnBlessing", false)
		else
			self.pPanel:Button_SetText("BtnBlessing", "祝福")
			self.pPanel:SetActive("BtnGoldBlessing", true)
			self.pPanel:Button_SetEnabled("BtnBlessing", true)
		end
	end

	if tbRoleInfo.nGetVal then
		self.pPanel:SetActive("NoGet", false)
		self.pPanel:SetActive("Get", true)
		self.pPanel:Label_SetText("BlessingValue", tbRoleInfo.nGetVal)
	else
		self.pPanel:SetActive("NoGet", true)
		self.pPanel:SetActive("Get", false)
		self.pPanel:Label_SetText("BlessingValue", "预计" .. tbRoleInfo.nGetBlessVal)
	end

end

tbSendBlessGrid.tbOnClick = {
	BtnBlessing = function (self)
		SendBless:DoSendBless(self.tbRoleInfo.dwID )
	end;
	BtnGoldBlessing = function (self)
		local fnYes = function ()
			SendBless:DoSendBless(self.tbRoleInfo.dwID, true)
		end
		Ui:OpenWindow("MessageBox",
		  string.format("消耗%d元宝进行特殊祝福，对方将额外获得1祝福值，确定祝福吗？", SendBless.COST_GOLD),
		 { {fnYes},{} },
		 {"确定", "取消"});
	end;
}


local tbSendBlessGridWord =  Ui:CreateClass("SendBlessGridWord")

function tbSendBlessGridWord:SetData( tbRoleInfo, bInAct)
	self.tbRoleInfo = tbRoleInfo
	self.pPanel:Label_SetText("lbRoleName", tbRoleInfo.szName)
	self.pPanel:Label_SetText("lbLevel", tbRoleInfo.nLevel)
	local SpFaction = Faction:GetIcon(tbRoleInfo.nFaction)
	local szPortrait, szAltas = PlayerPortrait:GetSmallIcon(tbRoleInfo.nPortrait)
	self.pPanel:Sprite_SetSprite("SpFaction",  SpFaction);
	if tbRoleInfo.nState == 2 then
		self.pPanel:Sprite_SetSprite("SpRoleHead",  szPortrait, szAltas);
		self.pPanel:Button_SetSprite("Main", "BtnListFourthNormal", 1)
	else
		self.pPanel:Sprite_SetSpriteGray("SpRoleHead",  szPortrait, szAltas);
		self.pPanel:Button_SetSprite("Main", "BtnListFourthDisabled", 1)
	end

	if tbRoleInfo.nGetVal then
		self.pPanel:SetActive("NoWish", false)	
		self.pPanel:SetActive("ContentTxt", true)	
		self.pPanel:Label_SetText("ContentTxt", tbRoleInfo.szGetWord)	
		self.pPanel:SetActive("SpriteGold", tbRoleInfo.nGetVal == 2)
	else
		self.pPanel:SetActive("NoWish", true)	
		self.pPanel:SetActive("ContentTxt", false)	
		self.pPanel:SetActive("SpriteGold", false)	
	end

	if tbRoleInfo.nSendedVal then
		self.pPanel:SetActive("ViewMy", true)	
		self.pPanel:Button_SetText("BtnBlessing", "已祝福")
		self.pPanel:Button_SetEnabled("BtnBlessing", bInAct and false)
		self.pPanel:SetActive("BtnGoldBlessing", false)
	else
		self.pPanel:SetActive("ViewMy", false)	
		self.pPanel:Button_SetText("BtnBlessing", "祝福")
		self.pPanel:Button_SetText("BtnGoldBlessing", "元宝祝福")
		self.pPanel:SetActive("BtnGoldBlessing", true)
		self.pPanel:Button_SetEnabled("BtnBlessing", bInAct and true)
		self.pPanel:Button_SetEnabled("BtnGoldBlessing", bInAct and true)
	end

end

tbSendBlessGridWord.tbOnClick = {
	BtnBlessing = function (self)
		Ui:OpenWindow("NewYearTxtPanel", self.tbRoleInfo)
	end;
	BtnGoldBlessing = function (self)
		Ui:OpenWindow("NewYearTxtPanel", self.tbRoleInfo, true)	
	end;
	ViewMy = function (self)
		if self.tbRoleInfo.nSendedVal then
			local tbWordsGet = SendBless:GetWordsSend()
			local szWord = tbWordsGet[self.tbRoleInfo.dwID]
			if Lib:IsEmptyStr(szWord) then
				szWord = SendBless.szDefaultWord
			end
			Ui:OpenWindow("AttributeDescription", "送出的祝福语：\n\n" .. szWord)
		end
	end;
}


local tbRobClueGrid =  Ui:CreateClass("RobClueGrid")

function tbRobClueGrid:SetData(tbRoleInfo, bRob, bEnable, pParent)
	self.tbRoleInfo = tbRoleInfo
	self.pParent = pParent
	local nVipLevel = tbRoleInfo.nVipLevel
	local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbRoleInfo.nHonorLevel)
	self.pPanel:Label_SetText("RoleName", tbRoleInfo.szName)
	if ImgPrefix then
		self.pPanel:SetActive("PlayerTitle", true);
		self.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
	else
		self.pPanel:SetActive("PlayerTitle", false);
	end
	if not nVipLevel or  nVipLevel == 0 then
		self.pPanel:SetActive("VIP", false)
	else
		self.pPanel:SetActive("VIP", true)
		self.pPanel:Sprite_Animation("VIP",  Recharge.VIP_SHOW_LEVEL[nVipLevel]);
	end
	self.pPanel:Label_SetText("lbLevel", tbRoleInfo.nLevel)

	self.pPanel:Label_SetText("FamilyName", string.format("家族：%s", tbRoleInfo.szKinName or "") )

	local SpFaction = Faction:GetIcon(tbRoleInfo.nFaction)

	local szPortrait, szAltas = PlayerPortrait:GetSmallIcon(tbRoleInfo.nPortrait)
	self.pPanel:Sprite_SetSprite("SpFaction",  SpFaction);
	self.pPanel:Sprite_SetSprite("SpRoleHead",  szPortrait, szAltas);

	if FriendShip:IsFriend(me.dwID, tbRoleInfo.dwID) then
		self.pPanel:Label_SetText("Type", "好友")
	elseif FriendShip:IsHeIsMyEnemy(me.dwID, tbRoleInfo.dwID) then
		self.pPanel:Label_SetText("Type", "仇人")
	else
		if me.dwKinId ~= 0 and me.dwKinId == tbRoleInfo.dwKinId then
			self.pPanel:Label_SetText("Type", "家族")
		else
			self.pPanel:Label_SetText("Type", "陌生人")	
		end
	end

	self.pPanel:Button_SetText("BtnGive", bRob and "抢夺" or "赠送")
	self.pPanel:Button_SetEnabled("BtnGive", bEnable)

	self.bRob = bRob
end

tbRobClueGrid.tbOnClick = {
	BtnGive = function (self)
		local tbAct = Activity.CollectAndRobClue
		if self.bRob then
			tbAct:RobHim(self.tbRoleInfo.dwID)	
		else
			if self.pParent then
				self.pParent:DoSend(self.tbRoleInfo.dwID, self.tbRoleInfo.szName)
			end
		end
	end;
};