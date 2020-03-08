local tbUi = Ui:CreateClass("WishingPanel")
tbUi.tbWishList = {
	"希望能够早日遇见那尚未谋面的一世情缘",	
	"希望我等生死相交的弟兄，此情不改",	
	"望能执子之手，与子偕老",	
	"心中无他求，惟愿君安好",	
	"希望我心上之人，一世平安快乐",	
	"希望家族能够蒸蒸日上，越来越好", 
	"家族称霸武林，指日可待",	
	"希望这个江湖能越来越热闹，越来越鼎盛",	
	"希望族中的弟兄越来越帅，姐妹越来越美",	
	"日照香炉生紫烟，紫烟先不说，香炉在哪？", 
	"江湖纷乱，谁拔了剑，成了侠，动了情，结了缘？",	
	"愿我掌中青锋，斩尽天下恶徒！",	
	"愿我手中双锤，扫尽天下狂徒！",	
	"愿我掌中冷锋，正我雪峰之名！",
	"愿我手中长剑，渡化愚昧宵小！",	
	"愿我掌中机簧，捍我世家之名！",	
	"愿我手握长枪，伴我傲笑红尘！",	
	"愿我掌中铜棍，伏尽天下邪魔！",	
	"愿我背上长弓，尽诛不义之徒！",	
}

tbUi.tbOnClick = 
{
    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end,

    BtnCheck = function (self)
    	Ui:OpenWindow("WishListCheckPanel", self.tbData)
    end,

    BtnWish = function (self)
    	if me.GetUserValue(Activity.WishAct.GROUP, Activity.WishAct.WISH_COUNT) > 0 then
    		me.CenterMsg("每个角色只能进行一次许愿")
    		return
    	end
    	Ui:OpenWindow("WishListPanel", "WishList")
    end,
}
for i = 1, 10 do
	tbUi.tbOnClick["WishBar" .. i] = function (self)
		self:ShowWishContent(i)
	end
end
function tbUi:RegisterEvent()
    return
    {
        {UiNotify.emNOTIFY_WISHACT_DATA_CHANGED, self.OnDataUpadte}
    }
end

function tbUi:OnOpen()
	if not Kin:HasKin() then
		me.CenterMsg("请先加入一个家族")
		return 0
	end
end

function tbUi:OnOpenEnd()
	self.tbData = Activity.WishAct.tbData or self.tbData or {}
	self:TryUpdateWishData()
	self:CleanSelectedItem()
	self.pPanel:SetActive("BtnWish", GetTime() < Activity.WishAct.nTrueEndTime)
	self.pPanel:SetActive("BtnCheck", GetTime() < Activity.WishAct.nTrueEndTime)
end

function tbUi:TryUpdateWishData()
	if not self.dwKinId or self.dwKinId ~= me.dwKinId or not self.nLastUpdateTime or GetTime() - self.nLastUpdateTime >= 60 then
		RemoteServer.TryCallWishActFunc("TryGetData")
		self.dwKinId = me.dwKinId
		self.nLastUpdateTime = GetTime()
	end
end

function tbUi:CleanSelectedItem()
	for i = 1, 10 do
		self.pPanel:SetActive("WishName" .. i, false)
	end
	self:UpdateWishItem()
end

function tbUi:UpdateWishItem()
	for i = 1, 10 do
		local bShow = self.tbData[i] or false
		self.pPanel:SetActive("WishBar" .. i, bShow)
		if bShow then
			local tbInfo = self.tbData[i]
			local szPortrait, szAltas = PlayerPortrait:GetSmallIcon(tbInfo[Activity.WishAct.HEADID])
			self.pPanel:Sprite_SetSprite("SpRoleHead" .. i, szPortrait, szAltas)
			local szFaction = Faction:GetIcon(tbInfo[Activity.WishAct.FACTION])
			self.pPanel:Sprite_SetSprite("SpFaction" .. i, szFaction)

			local nLike = tbInfo[Activity.WishAct.LIKE]
			self.pPanel:Label_SetText("Txt" .. i, nLike)
		end
	end
end

function tbUi:ShowWishContent(nSelectedIdx)
	self:CleanSelectedItem()
	self.pPanel:SetActive("WishName" .. nSelectedIdx, true)
	self.pPanel:Label_SetText("WishNameTxt" .. nSelectedIdx, self.tbData[nSelectedIdx][Activity.WishAct.CONTENT])
	self:StartCloseItemTimer()
end

function tbUi:CloseItemState()
	self:CleanSelectedItem()
	self.nCloseTimer = nil
end

function tbUi:StartCloseItemTimer()
	self:CloseTimer()
	self.nCloseTimer = Timer:Register(Env.GAME_FPS * 5, self.CloseItemState, self)
end

function tbUi:CloseTimer()
	if self.nCloseTimer then
		Timer:Close(self.nCloseTimer)
		self.nCloseTimer = nil
	end
end

function tbUi:OnClose()
	self:CloseTimer()
end

function tbUi:OnDataUpadte(tbData)
	self.tbData = tbData
	self:UpdateWishItem()
end

local tbAct = Activity.WomanAct

local tbListUi = Ui:CreateClass("WishListPanel")

tbListUi.tbSetting = 
{
	["WishList"] = 
	{
		tbList = tbUi.tbWishList;
		szDefaultInput = "点击输入愿望（30字）";
		szEmptyTip = "愿望不能为空";
		szButtonText = "许愿";
		szDesc1 = "需消耗%s %s 元宝";
		nDesc1Pay = Activity.WishAct.nPayWishCost;
		fnDone = function (self,szLabel)
			local bRet, nErr = Activity.WishAct:CheckWishContent(szLabel)
			if not bRet then
				me.CenterMsg(Activity.WishAct.tbErrMsg[nErr])
				return
			end
			local nWishType = self.nSelectedIdx == 0 and Activity.WishAct.Wish_Type_Pay or Activity.WishAct.Wish_Type_Free
			local fnWish = function ()
				if nWishType == Activity.WishAct.Wish_Type_Pay then
					if me.GetMoney("Gold") < Activity.WishAct.nPayWishCost then
						me.CenterMsg("元宝不足")
						return
					end
				end
				RemoteServer.TryCallWishActFunc("TryWish", szLabel, nWishType)
			end
			local szTip =  "尊敬的侠士，您当前许下的愿望是：\n[FFFE0D]「" .. szLabel ..  "」[-]\n只能许愿一次，无法修改，是否确定？"
			if nWishType == Activity.WishAct.Wish_Type_Pay then
				local _, szMoneyEmotion = Shop:GetMoneyName("Gold")
				szTip =  string.format("尊敬的侠士，您当前许下的愿望是：\n[FFFE0D]「" .. szLabel ..  "」[-]\n只能许愿一次，无法修改，是否确定？(需花费%s%s)", Activity.WishAct.nPayWishCost, szMoneyEmotion)
			end
			me.MsgBox(szTip, {{"确定", fnWish}, {"取消"}})
		end;
	};
	["LabelList"] = 
	{
		tbList = tbAct.tbFree;
		szDefaultInput = string.format("点击描述%s（最多7字）", tbAct.szActDes);
		szEmptyTip = string.format("%s不能为空", tbAct.szActDes);
		szButtonText = string.format("添加%s", tbAct.szActDes);
		szDesc1 = "需消耗%s %s 元宝";
		nDesc1Pay = tbAct.nPayLabelCost;
		szDesc2 = string.format("拥有量产%s签", tbAct.szActDes);
		szDesc3 = "*%s";
		nDesc3ItemId = tbAct.nImpressionLabelItemID;
		fnDone = function (self,szLabel)
			if not self.tbParam then
				return
			end
			local nAcceptId = self.tbParam[1]
			if not nAcceptId then
				me.CenterMsg("你要送给谁？？")
				return
			end
			local nType = self.nSelectedIdx == 0 and tbAct.PayLabel or tbAct.FreeLabel
			local bRet, szMsg = tbAct:CheckCommon(me, nAcceptId, nType, szLabel)
			if not bRet then
				me.CenterMsg(szMsg)
				return 
			end

			local tbParam = {nAcceptId, nType, szLabel}
			local fnSend = function ()
				RemoteServer.TrySendLabel(tbParam)
			end

			if nType == tbAct.PayLabel then
				me.MsgBox(string.format(" 是否花费[FFFE0D]%d元宝[-]添加自定义%s\n[FFFE0D]「" .. szLabel ..  "」[-]", tbAct.nPayLabelCost, tbAct.szActDes), {{"确定", fnSend}, {"取消"}})
			else
				RemoteServer.TrySendLabel(tbParam)
			end
		end;
		szIconAtlas = "UI/Atlas/Item/Item/Item7.prefab";
		szIconSprite = "Mark1";
	};
}
function tbListUi:OnOpenEnd(szType, ...)
	self.szType = szType
	local tbSetting = self.tbSetting[szType]
	if not tbSetting then
		return
	end
	local tbSelectList = tbSetting.tbList
	if not tbSelectList then 
		return 
	end

	self.tbSelectList = Lib:CopyTB(tbSelectList)
	self.tbSelectSetting = Lib:CopyTB(tbSetting)
	self.tbParam = {...}
	local fnSetItem = function (itemObj, nIdx)
		itemObj.pPanel:Label_SetText("WishTxt", self.tbSelectList[nIdx])
		itemObj.pPanel:Toggle_SetChecked("Main", false)
		itemObj.pPanel.OnTouchEvent = function (btn)
			self.nSelectedIdx = nIdx
		end
	end
	self.ScrollView:Update(#self.tbSelectList, fnSetItem)

	self.pPanel:Label_SetText("WishTxt",tbSetting.szDefaultInput or "请输入")
	self.pPanel:Button_SetText("BtnWish",tbSetting.szButtonText or "确定")

	self:RefreshDesUi()
end

function tbListUi:RefreshDesUi()
	local tbSetting = self.tbSetting[self.szType]
	if not tbSetting then
		return 
	end
	if tbSetting.szDesc1 or tbSetting.szDesc2 or tbSetting.szDesc3 then
		local _, szMoneyEmotion = Shop:GetMoneyName("Gold")
		self.pPanel:SetActive("DescNode", true)
		if tbSetting.szDesc1 then
			self.pPanel:SetActive("Desc1", true)
			self.pPanel:Label_SetText("Desc1",string.format(tbSetting.szDesc1, tbSetting.nDesc1Pay or 0, szMoneyEmotion) or "")
		else
			self.pPanel:SetActive("Desc1", false)
		end
		
		if tbSetting.szDesc2 then
			self.pPanel:SetActive("Desc2", true)
			self.pPanel:Label_SetText("Desc2",tbSetting.szDesc2 or "")
		else
			self.pPanel:SetActive("Desc2", false)
		end
		
		if tbSetting.szDesc3 then
			self.pPanel:SetActive("Desc3", true)
			self.pPanel:Label_SetText("Desc3", string.format(tbSetting.szDesc3, tbSetting.nDesc3ItemId and me.GetItemCountInAllPos(tbSetting.nDesc3ItemId) or 0) or "")
		else
			self.pPanel:SetActive("Desc3", false)
		end
		
		if tbSetting.szIconAtlas and tbSetting.szIconSprite then
			self.pPanel:Sprite_SetSprite("Sprite", tbSetting.szIconSprite, tbSetting.szIconAtlas)
			self.pPanel:SetActive("Sprite", true)
		else
			self.pPanel:SetActive("Sprite", false)
		end
	else
		self.pPanel:SetActive("DescNode", false)
	end
end

function tbListUi:OnClose()
	self.szType = nil
	self.tbSelectList = nil
	self.tbSelectSetting = nil
	self.tbParam = nil
	self.nSelectedIdx = nil
end

tbListUi.tbUiInputOnChange = {
	WishTxt = function (self)
		self.nSelectedIdx = 0
	end,
}

tbListUi.tbOnClick = {
	WishTxt = function (self)
		self.nSelectedIdx = 0
	end,
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end,
	BtnWish = function (self)
		if not self.nSelectedIdx or not self.tbSelectSetting then
			me.CenterMsg(self.tbSelectSetting.szEmptyTip or "不能为空")
			return
		end
		local szLabel
		if self.nSelectedIdx == 0 then
			szLabel = self.pPanel:Input_GetText("WishTxt")
		else
			szLabel = self.tbSelectList[self.nSelectedIdx]
		end
		if Lib:IsEmptyStr(szLabel) then
			me.CenterMsg(self.tbSelectSetting.szEmptyTip or "不能为空")
			return
		end

		local fnDone = self.tbSelectSetting.fnDone
		if not fnDone then
			return
		end
		fnDone(self,szLabel)
		Ui:CloseWindow(self.UI_NAME)
	end
}

function tbListUi:RegisterEvent()
    return
    {
        {UiNotify.emNOTIFY_WOMAN_SYNDATA, self.RefreshDesUi}
    }
end

local tbCheckUi = Ui:CreateClass("WishListCheckPanel")
tbCheckUi.nCountInPage = 5
function tbCheckUi:OnOpenEnd(tbData)
	self.tbData = tbData
	self.nCurPage = 1
	self.nMaxPage = math.ceil((#self.tbData - 0.1)/self.nCountInPage)
	self.tbHadLike = Activity.WishAct:GetHadLike()
	self:Update()
end

function tbCheckUi:Update()
	self.tbHadLike = Activity.WishAct:GetHadLike()
	local nBeginIndex = (self.nCurPage - 1)*self.nCountInPage
	for i = 1, self.nCountInPage do
		local nIdx = nBeginIndex + i
		local tbInfo = self.tbData[nIdx]
		self.pPanel:SetActive("WishChakItem" .. i, tbInfo or false)
		if tbInfo then
			local szPortrait, szAltas = PlayerPortrait:GetSmallIcon(tbInfo[Activity.WishAct.HEADID])
			self.pPanel:Sprite_SetSprite("SpRoleHead" .. i, szPortrait, szAltas)
			local szFaction = Faction:GetIcon(tbInfo[Activity.WishAct.FACTION])
			self.pPanel:Sprite_SetSprite("SpFaction" .. i, szFaction)
			self.pPanel:Label_SetText("lbRoleName" .. i, tbInfo[Activity.WishAct.NAME])
			self.pPanel:Label_SetText(string.format("Txt%d_1", i), tbInfo[Activity.WishAct.CONTENT])
			self.pPanel:Label_SetText(string.format("Txt%d_2", i), tbInfo[Activity.WishAct.LIKE])

			local nPlayerId = tbInfo[Activity.WishAct.PLAYERID]
			self.pPanel:SetActive("ThumbsUpMark" .. i, not self.tbHadLike[nPlayerId])
		end
	end
	local bShowPage = self.nMaxPage > 0
	self.pPanel:SetActive("Pages", bShowPage)
	self.pPanel:SetActive("BtnLeft", bShowPage)
	self.pPanel:SetActive("BtnRight", bShowPage)
	self.pPanel:Label_SetText("Pages", string.format("%d/%d", self.nCurPage, self.nMaxPage))
	self.pPanel:Label_SetText("Times", string.format("剩余点赞次数：%d", Activity.WishAct:GetLastLike()))
end

function tbCheckUi:TryLike(nIdx)
	local nChooseIdx = (self.nCurPage - 1)*self.nCountInPage + nIdx
	local nTarPlayerId = self.tbData[nChooseIdx][Activity.WishAct.PLAYERID]
	local bRet, nErr = Activity.WishAct:CheckLike(me, nTarPlayerId)
	if not bRet then
		me.CenterMsg(Activity.WishAct.tbErrMsg[nErr])
		return
	end

	RemoteServer.TryCallWishActFunc("TryLike", nTarPlayerId)
end

function tbCheckUi:RegisterEvent()
    return
    {
        {UiNotify.emNOTIFY_WISHACT_DATA_CHANGED, self.Update}
    }
end


tbCheckUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end,
	BtnLeft = function (self)
		if self.nCurPage <= 1 then
			return
		end

		self.nCurPage = self.nCurPage - 1
		self:Update()
	end,
	BtnRight = function (self)
		if self.nCurPage >= self.nMaxPage then
			return
		end

		self.nCurPage = self.nCurPage + 1
		self:Update()
	end,
}

for i = 1, tbCheckUi.nCountInPage do
	tbCheckUi.tbOnClick["ThumbsUp" .. i] = function (self)
		self:TryLike(i)
	end
end