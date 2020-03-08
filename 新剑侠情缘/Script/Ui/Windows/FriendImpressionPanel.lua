local tbUi = Ui:CreateClass("FriendImpressionPanel")

local tbAct = Activity.WomanAct
local emPLAYER_STATE_NORMAL = 2 --正常在线状态

function tbUi:OnOpen(nTargetId)
	self.nTargetId = nTargetId
	RemoteServer.TrySynLabelData()
	self:RefreshUi()
end

function tbUi:RefreshUi()
	local szTitle = tbAct.bTSMode and "赠送祝福" or "添加印象"
	self.pPanel:Label_SetText("Title", szTitle)
	local nStartTime, nEndTime = tbAct:GetTimeInfo()
	if nStartTime and nEndTime then
		local tbStartTime = os.date("*t", nStartTime);
		local tbEndTime = os.date("*t", nEndTime);
		local szTime = string.format("%s年%s月%s日 - %s月%s日", tbStartTime.year, tbStartTime.month, tbStartTime.day, tbEndTime.month, tbEndTime.day)
		if tbAct:IsEndSendLabel() then
			szTime = tbAct.bTSMode and "已结束，诸位侠士可查看过往的祝福" or "已结束，诸位侠士可查看过往的印象"
		end
		self.pPanel:Label_SetText("Tip1", szTime);
	end
	self.pPanel:Label_SetText("Tip2", string.format("＊点击%s标签可查看该条%s的详情", tbAct.szActDes, tbAct.szActDes));
	local szTip3 = "＊点击赠送祝福可对该师父添加祝福"
	if not tbAct.bTSMode then
		szTip3 = "＊点击添加印象可对该好友添加印象"
	end
	self.pPanel:Label_SetText("Tip3", szTip3);

	self:RefreshFriendUi()
end

function tbUi:RefreshFriendUi()

	self:RefreshFriendData()

	local fnOnClick = function(itemObj)
		self.dwFriendId = itemObj.dwID;
		local nCDTime = Activity.WomanAct.tbPlayerRequestCD[self.dwFriendId]
		local nTime = GetTime()
		if not nCDTime or nTime > nCDTime then
			Activity.WomanAct.tbPlayerRequestCD[self.dwFriendId] = nTime + 60
			RemoteServer.TrySynLabelData(self.dwFriendId)
		end
		
		self:RefreshLabelUi(itemObj.tbLabelInfo or {})
	end

	local tbItemObj = {}
	local nSelectIndex = 1

	local fnSetItem = function (itemObj, nIdx)
		local tbInfo = self.tbAllFriend[nIdx];
		local tbFriendData = FriendShip:GetFriendDataInfo(tbInfo.dwID) or {}
		local szName = tbFriendData.szName or tbInfo.szName or "未知";
		local nLevel = tbInfo.nLevel or 0;
		itemObj.pPanel:Label_SetText("Name", szName);
		itemObj.pPanel:Label_SetText("lbLevel", nLevel);

		local SpFaction = Faction:GetIcon(tbInfo.nFaction);
		itemObj.pPanel:Sprite_SetSprite("SpFaction",  SpFaction);

		local szPortrait, szAltas = PlayerPortrait:GetSmallIcon(tbInfo.nPortrait);
		if tbInfo.nState == emPLAYER_STATE_NORMAL then
			itemObj.pPanel:Sprite_SetSprite("SpRoleHead",  szPortrait, szAltas);
		else
			itemObj.pPanel:Sprite_SetSpriteGray("SpRoleHead",  szPortrait, szAltas);
		end

		local nImityLevel = FriendShip:GetFriendImityLevel(me.dwID, tbInfo.dwID) or 0;
		local szImity = me.dwID == tbInfo.dwID and "【自己】" or string.format("亲密度等级: %s", nImityLevel)
		itemObj.pPanel:Label_SetText("Intimacy", szImity);

		local tbLabelInfo = tbInfo.tbLabelInfo or {}
		local nHadLabelCount = tbInfo.nHadLabelCount or 0
		itemObj.pPanel:Label_SetText("Impression", string.format("已有%s: %s/15", tbAct.szActDes, nHadLabelCount));

		itemObj.dwID = tbInfo.dwID;
		itemObj.tbLabelInfo = tbLabelInfo;
		itemObj.pPanel.OnTouchEvent = fnOnClick;

		tbItemObj[nIdx] = itemObj;

		itemObj.pPanel:Toggle_SetChecked("Main", false);

		itemObj.pPanel:SetActive("MasterMark", tbAct.bTSMode and TeacherStudent:IsMyTeacher(tbInfo.dwID)) 

		if self.dwFriendId then
			if self.dwFriendId == tbInfo.dwID then
				nSelectIndex = nIdx
			end
		else
			if self.nTargetId and self.nTargetId == tbInfo.dwID then
				nSelectIndex = nIdx
			end
		end
	end

	self.ScrollView1:Update(#self.tbAllFriend, fnSetItem)

	local selectItemObj = tbItemObj[nSelectIndex]
	if selectItemObj then
		selectItemObj.pPanel:Toggle_SetChecked("Main", true);
		fnOnClick(selectItemObj);
	end
end

function tbUi:RefreshFriendData()
	local tbPriorData = tbAct:GetPriorData()
	local tbFriend = FriendShip:GetAllFriendData() or {}
	self.tbAllFriend = {}
	local tbAllFriend = {}
	if tbPriorData then
		tbAllFriend = Lib:CopyTB(tbPriorData)
	else
		tbAllFriend = Lib:CopyTB(tbFriend)
		if next(tbAllFriend) then
			--按在线和亲密度值排序， 在线的》 亲密
			local fnSort = function (a, b)
				if a.nState == emPLAYER_STATE_NORMAL and b.nState == emPLAYER_STATE_NORMAL then
					return a.nImity > b.nImity
				elseif a.nState == emPLAYER_STATE_NORMAL then
					return true
				elseif b.nState == emPLAYER_STATE_NORMAL then
					return false
				else
					return a.nImity > b.nImity
				end
			end
			table.sort(tbAllFriend, fnSort)
		end

		local tbRoleInfo = nil;
		if self.nTargetId then
			for nIndex,tbInfo in ipairs(tbAllFriend) do
				if tbInfo.dwID == self.nTargetId then
					tbRoleInfo = tbInfo
					table.remove(tbAllFriend,nIndex)
					break;
				end
			end
		end
		if tbRoleInfo then
			table.insert(tbAllFriend, 1, tbRoleInfo);
		end

		local tbMy = 
		{
			nState = emPLAYER_STATE_NORMAL;
			nImity = 0;
			szName = me.szName;
			dwID = me.dwID;
			nFaction = me.nFaction;
			nPortrait = me.nPortrait;
			nLevel = me.nLevel;
		}
		table.insert(tbAllFriend, 1, tbMy)
	end
	
	local fnSortByTime = function (a, b)
		return a.nTime > b.nTime
	end
	
	for _, tbFriendInfo in ipairs(tbAllFriend) do
		local tbLabelInfo = tbAct:GetLabelInfo()
		local tbInfo = tbLabelInfo[tbFriendInfo.dwID]
		tbFriendInfo.tbLabelInfo = {}
		if tbInfo then
			tbFriendInfo.nHadLabelCount = tbInfo.nHadLabelCount or 0
			local tbFreeLabel = tbInfo.tbFreeLabel or {}
			local tbPayLabel = tbInfo.tbPayLabel or {}
			local tbPayLabelPlayer = tbInfo.tbPayLabelPlayer or {}
			local tbLabelTime = tbInfo.tbLabelTime or {}

			local tbAllFreeLabel = {}
			local tbAllPayLabel = {}

			for szLabel, nCount in pairs(tbFreeLabel) do
				local nTime =  0
				if tbLabelTime[tbAct.FreeLabel] and tbLabelTime[tbAct.FreeLabel][szLabel] then
					nTime = tbLabelTime[tbAct.FreeLabel][szLabel]
				end
				local tbTemp = {}
				tbTemp.szLabel = szLabel
				tbTemp.nCount = nCount
				tbTemp.nTime = nTime
				tbTemp.nType = tbAct.FreeLabel
				table.insert(tbAllFreeLabel, tbTemp)
			end
			for szLabel, nCount in pairs(tbPayLabel) do
				local nTime = 0
				if tbLabelTime[tbAct.PayLabel] and tbLabelTime[tbAct.PayLabel][szLabel] then
					nTime = tbLabelTime[tbAct.PayLabel][szLabel]
				end
				local tbTemp = {}
				tbTemp.szLabel = szLabel
				tbTemp.nCount = nCount
				tbTemp.nTime = nTime
				tbTemp.nType = tbAct.PayLabel
				local tbPayLabelPlayer = tbPayLabelPlayer[szLabel] or {}
				local tbPlayer = tbPayLabelPlayer.tbPlayerInfo or {}
				if next(tbPlayer) then
					table.sort(tbPlayer, fnSortByTime)
					tbTemp.tbPlayerInfo = tbPlayer
				end
				table.insert(tbAllPayLabel, tbTemp)
			end

			table.sort(tbAllFreeLabel, fnSortByTime)
			table.sort(tbAllPayLabel, fnSortByTime)

			for _, tbInfo in pairs(tbAllPayLabel) do
				table.insert(tbFriendInfo.tbLabelInfo, tbInfo)
			end

			for _, tbInfo in ipairs(tbAllFreeLabel) do
				table.insert(tbFriendInfo.tbLabelInfo, tbInfo)
			end
		end
	end
	
	self.tbAllFriend = tbAllFriend
end

local tbLabelUiName = 
{
	Impression1 = true;
	Impression2 = true;
	Impression3 = true;
	Impression4 = true;
	Impression5 = true;
	Impression6 = true;
}

local nNumPerRow = 2;

function tbUi:RefreshLabelUi(tbLabelInfo)
	local tbAllLabel = Lib:CopyTB(tbLabelInfo)
	table.insert(tbAllLabel, {nAddLabel = true})

	local fnOnClick = function (itemObj)
		local szLabel = itemObj.szLabel
		local nType = itemObj.nType
		local tbParam = {self.dwFriendId, nType, szLabel}
		local tbPlayerInfo = itemObj.tbPlayerInfo
		local fnSend = function ()
			RemoteServer.TrySendLabel(tbParam)
		end
		
		if nType == tbAct.FreeLabel then
			local szMsg
			if tbAct.bTSMode then
				if not TeacherStudent:IsMyTeacher(self.dwFriendId) then
					szMsg = self.dwFriendId == me.dwID and string.format("不可对自己添加%s", tbAct.szActDes) or string.format("只能为师父添加%s", tbAct.szActDes)
				end
			else
				if not FriendShip:IsFriend(me.dwID, self.dwFriendId) then
					local szMan = self.dwFriendId == me.dwID and "自己" or "陌生人"
					szMsg = string.format("不可对%s添加%s", szMan, tbAct.szActDes)
				end
			end
			if szMsg then
				me.CenterMsg(szMsg)
				return
			end
			me.MsgBox(string.format(" 是否消耗%d个%s添加印象[FFFE0D]「" .. szLabel ..  "」[-]", tbAct.nNeedConsumeImpressionLabel, Item:GetItemTemplateShowInfo(tbAct.nImpressionLabelItemID, me.nFaction, me.nSex) or string.format("%s签", tbAct.szActDes)), {{"确定", fnSend}, {"取消"}})
		else
			local szMsg
			if tbAct.bTSMode then
				if not FriendShip:IsFriend(me.dwID, self.dwFriendId) and me.dwID ~= self.dwFriendId and not TeacherStudent:IsMyTeacher(self.dwFriendId) then
					szMsg = string.format("只能为师父添加%s", tbAct.szActDes)
				end
			else
				if not FriendShip:IsFriend(me.dwID, self.dwFriendId) and me.dwID ~= self.dwFriendId then
					szMsg = string.format("不可对陌生人添加%s", tbAct.szActDes)
				end
			end
			if szMsg then
				me.CenterMsg(szMsg)
				return
			end 
			Ui:OpenWindow("FriendImpressionAgreePanel", tbParam, tbPlayerInfo)
		end
	end
	
	local fnAddClick = function (itemObj)
		local szMsg
		if tbAct.bTSMode then
			if not TeacherStudent:IsMyTeacher(self.dwFriendId) then
				szMsg = string.format("只能为师父添加%s", tbAct.szActDes)
			end
		else
			if not FriendShip:IsFriend(me.dwID, self.dwFriendId) then
				local szMan = self.dwFriendId == me.dwID and "自己" or "陌生人"
				szMsg = string.format("不可对%s添加%s", szMan, tbAct.szActDes)
			end
		end
		if szMsg then
			me.CenterMsg(szMsg)
			return
		end
		Ui:OpenWindow("WishListPanel", "LabelList", self.dwFriendId)
	end

	local fnSetItem = function (itemObj, nIdx)
		for szUiName,_ in pairs(tbLabelUiName) do
			itemObj.pPanel:SetActive(szUiName, false)
		end
		for nIdx = 1, 6 do
			local szUiTxt = tbAct.bTSMode and "赠送祝福" or "添加印象"
			itemObj["Impression" ..nIdx].pPanel:Label_SetText("Txt" ..nIdx, szUiTxt)
		end
		local nCur = (nIdx - 1) * nNumPerRow + 1;
		local nStep = nCur + nNumPerRow - 1;

		local tbIndex = {nCur,nStep}

		for _, nIndex in ipairs(tbIndex) do
			local tbInfo = tbAllLabel[nIndex]
			if tbInfo then
				-- 添加新祝福
				if tbInfo.nAddLabel then
					local szAddLabelUiName = nIndex % 2 == 0 and "Impression4" or "Impression1"
					itemObj.pPanel:SetActive(szAddLabelUiName, true)
					itemObj[szAddLabelUiName].pPanel.OnTouchEvent = fnAddClick;
				else
					-- 玩家已有祝福
					local szLabel = tbInfo.szLabel
					local nCount = tbInfo.nCount
					local nType = tbInfo.nType
					local tbPlayerInfo = tbInfo.tbPlayerInfo

					if nType == tbAct.FreeLabel then
						local szFreeLabelUiName = nIndex % 2 == 0 and "Impression5" or "Impression2"
						local szFreeLabelTxtUiName = nIndex % 2 == 0 and "Txt5" or "Txt2"
						local szFreeLabelEvaluateUiName = nIndex % 2 == 0 and "Evaluate5" or "Evaluate2"
						itemObj.pPanel:SetActive(szFreeLabelUiName, true)
						itemObj[szFreeLabelUiName].pPanel:Label_SetText(szFreeLabelTxtUiName, szLabel or "-");
						itemObj[szFreeLabelUiName].pPanel:Label_SetText(szFreeLabelEvaluateUiName, string.format("已有%s名好友描述", nCount));
						itemObj[szFreeLabelUiName].szLabel = szLabel
						itemObj[szFreeLabelUiName].nType = nType
						itemObj[szFreeLabelUiName].tbPlayerInfo = tbPlayerInfo or {}
						itemObj[szFreeLabelUiName].pPanel.OnTouchEvent = fnOnClick;
					else
						local szPayLabelUiName = nIndex % 2 == 0 and "Impression6" or "Impression3"
						local szPayLabelTxtUiName = nIndex % 2 == 0 and "Txt6" or "Txt3"
						local szPayLabelEvaluateUiName = nIndex % 2 == 0 and "Evaluate6" or "Evaluate3"
						itemObj.pPanel:SetActive(szPayLabelUiName, true)
						itemObj[szPayLabelUiName].pPanel:Label_SetText(szPayLabelTxtUiName, szLabel or "-");
						itemObj[szPayLabelUiName].pPanel:Label_SetText(szPayLabelEvaluateUiName, string.format("已有%s名好友描述", nCount));
						itemObj[szPayLabelUiName].szLabel = szLabel
						itemObj[szPayLabelUiName].nType = nType
						itemObj[szPayLabelUiName].tbPlayerInfo = tbPlayerInfo or {}
						itemObj[szPayLabelUiName].pPanel.OnTouchEvent = fnOnClick;
					end
				end
				itemObj.pPanel:SetActive("Main", true)
			else
				itemObj.pPanel:SetActive("Main", false)
			end
		end
	end

	self.ScrollView2:Update(math.ceil(#tbAllLabel/nNumPerRow), fnSetItem)
end

function tbUi:OnClose()
	self.nTargetId = nil
	self.dwFriendId = nil
	tbAct:ClearPriorData()
end

function tbUi:RegisterEvent()
    return {
          		{UiNotify.emNOTIFY_WOMAN_SYNDATA, self.RefreshUi, self},
     	   }
end

tbUi.tbOnClick = 
{
    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end,
 }

----------------------------------------------------------------------
local tbAgreeUi = Ui:CreateClass("FriendImpressionAgreePanel")
local tbTitleDes = 
{
 	[tbAct.FreeLabel] = "暂不显示免费标签好友",
 	[tbAct.PayLabel] = "以下好友表示赞同:",
}

local tbPlayerDes = 
{
 	[tbAct.FreeLabel] = "",
 	[tbAct.PayLabel] = "",
}
 function tbAgreeUi:OnOpen(tbParam, tbPlayerInfo)
 	self.tbParam = tbParam or {}
 	self.tbPlayerInfo = tbPlayerInfo or {}
 	self:UpdateUi()
 end

 function tbAgreeUi:UpdateUi()
 	local nType = self.tbParam and self.tbParam[2]
 	local szTitle = tbTitleDes[nType] or "以下好友表示赞同:"

 	self.pPanel:Label_SetText("Title", szTitle)
 	local szPlayer = tbPlayerDes[nType] or ""
 	local nLen = #self.tbPlayerInfo
 	for nIndex, tbInfo in ipairs(self.tbPlayerInfo) do
 		if tbInfo.szName then
 			if nLen == nIndex then
 				szPlayer = szPlayer ..tbInfo.szName
 			else
 				szPlayer = szPlayer ..tbInfo.szName .."\n"
 			end
 		end
 	end
 	if nLen >= tbAct.nSavePayCount then
 		szPlayer = szPlayer .."等"
 	end
 	self.pPanel:Label_SetText("Name",szPlayer)
 end

 tbAgreeUi.tbOnClick = 
{
    BtnAgree = function (self)
  	 	local nPlayerId = self.tbParam and self.tbParam[1]
    	local nType = self.tbParam and self.tbParam[2]
    	local szLabel = self.tbParam and self.tbParam[3]
    	if not nPlayerId or not nType or not szLabel then
    		return
    	end
    	if tbAct.bTSMode and not TeacherStudent:IsMyTeacher(nPlayerId) then
			me.CenterMsg(string.format("只能为师父添加%s", tbAct.szActDes))
			return
		end
		if not tbAct.bTSMode and not FriendShip:IsFriend(me.dwID, nPlayerId) then
			local szMan = nPlayerId == me.dwID and "自己" or "陌生人"
			me.CenterMsg(string.format("不可对%s添加%s", szMan, tbAct.szActDes))
			return
		end
        local fnSend = function ()
			RemoteServer.TrySendLabel(self.tbParam)
			Ui:CloseWindow(self.UI_NAME)
		end
		if nType == tbAct.PayLabel then
			local szDes = tbAct.bTSMode and "师父" or "好友"
			me.MsgBox(string.format(" 是否花费[FFFE0D]%d元宝[-]为你的%s添加%s[FFFE0D]「" .. szLabel ..  "」[-]", tbAct.nPayLabelCost, szDes, tbAct.szActDes), {{"确定", fnSend}, {"取消"}})
		end
    end,
 }

function tbAgreeUi:OnScreenClick()
    Ui:CloseWindow(self.UI_NAME);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
end