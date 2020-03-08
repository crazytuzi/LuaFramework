local tbUi = Ui:CreateClass("DrinkToDream_SincereWordsEdit")
tbUi.tbGivenContent = {
	{"我喜欢午后的风",
	"清晨的阳光",
	"还有任何时候的你",},
	{"我能给你的很少",
	"只有一个未来",
	"还有一个我",},
	{"我喜欢读有关爱情的书",
	"因为字里行间",
	"都是你",},
	{"忽而一幕似曾相识",
	"原来是想起了你",
	"不禁笑了笑自己",},
	{"我达达的马蹄声",
	"是个美丽的错误",
	"我不是归人，是个过客",},
	{"对不起，未经同意",
	"我和我自己",
	"就偷偷喜欢上了你",},
	{"不论多么冷风习习",
	"只要想起你",
	"自然而然温暖四起",},
}
tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end;
	BtnChoice = function (self)
		self:ChoosePlayer()
	end;
	BtnRandom = function (self)
		self:RandomSincereWordsContent()
	end;
	BtnShareLeft = function (self)
		self:ShareLink()
	end;
	BtnShareRight = function (self)
		self:ShareUrl()
	end;
	BtnEdit = function (self)
		self:Edit()
	end;
	BtnSubmission = function (self)
		self:Commit()
	end;
	BtnFabulous = function (self)
		self:Like()
	end;
	BtnQQ = function (self)
		Sdk:TlogShare("DrinkToDream")
		Sdk:ShareUrl("QQ", "快来看看我写的酒后衷言吧！", "剑侠情缘", "MSG_drinktodream", self:GetUrl());
	end;
	BtnQQSpace = function (self)
		Sdk:TlogShare("DrinkToDream")
		Sdk:ShareUrl("QZone", "快来看看我写的酒后衷言吧！", "剑侠情缘", "MSG_drinktodream", self:GetUrl());
	end;
	BtnWeixin = function (self)
		Sdk:TlogShare("DrinkToDream")
		Sdk:ShareUrl("WXSe", "快来看看我写的酒后衷言吧！", "剑侠情缘", "MSG_drinktodream", self:GetUrl());
	end;
	BtnCircleOfFriends = function (self)
		Sdk:TlogShare("DrinkToDream")
		Sdk:ShareUrl("WXMo", "快来看看我写的酒后衷言吧！", "剑侠情缘", "MSG_drinktodream", self:GetUrl());
	end;
}

tbUi.szUrl = "https://jxqy.qq.com/cp/a20190402sharem/index.shtml?sServerName=%s&sNickName=%s&sSincereWordsTo=%s&sSincereWords1=%s&sSincereWords2=%s&sSincereWords3=%s"

local tbTab = {"SincereWordsOne", "SincereWordsTwo","SincereWordsThree"}
for nIdx, szBtn in ipairs(tbTab) do
	tbUi.tbOnClick[szBtn] = function (self)
		self:ChangeTab(nIdx)
	end
end

function tbUi:RegisterEvent()
	return { {UiNotify.emNOTIFY_SYNC_DRINKTODREAM_DATA, self.OnSyncData} }
end

local tbAct = Activity.DrinkToDreamAct;
function tbUi:OnOpenEnd(nPlayerId, nTab)
	self.bSelf  = nPlayerId == me.dwID
	if not self.bSelf and not tbAct:GetPlayerData(nPlayerId) then
		return 0
	end

	self.nTab      = nTab or 1
	self.nPlayerId = nPlayerId
	for i = 1, tbAct.SINCEREWORDS_COUNT do
		self.pPanel:Toggle_SetChecked(tbTab[i], self.nTab == i)
	end
	self:UpdateContent()
	self.pPanel:SetActive("GroupQQ", false);
	self.pPanel:SetActive("GroupWeixin", false);
	self.bShareBtnOpen = false;
end

function tbUi:GetUrl()
	local tbServerMap = Client:GetDirFileData("ServerMap" .. Sdk:GetCurPlatform());
	local szSerName = tbServerMap[SERVER_ID or 0] or "";
	local tbData  = tbAct:GetPlayerData(self.nPlayerId)
	local tbAllSincereWords = tbData.tbSincereWords or {}
	local tbSincereWords    = tbAllSincereWords[self.nTab]
	local szSincereWordsTo = tbSincereWords and tbSincereWords.szName or ""
	local szSincereWords1 = tbSincereWords and tbSincereWords.tbContent and tbSincereWords.tbContent[1] or ""
	local szSincereWords2 = tbSincereWords and tbSincereWords.tbContent and tbSincereWords.tbContent[2] or ""
	local szSincereWords3 = tbSincereWords and tbSincereWords.tbContent and tbSincereWords.tbContent[3] or ""
	local szUrl = string.format(self.szUrl, Lib:UrlEncode(szSerName), Lib:UrlEncode(me.szName), 
		Lib:UrlEncode(szSincereWordsTo), Lib:UrlEncode(szSincereWords1), Lib:UrlEncode(szSincereWords2), Lib:UrlEncode(szSincereWords3))
	szUrl = string.gsub(szUrl, "+", "%%20")
	return szUrl;
end

--切页
function tbUi:ChangeTab(nTab)
	if self.nTab == nTab then
		return
	end

	if self.bEdit then
		local tbData = tbAct:GetPlayerData(self.nPlayerId)
		if tbData.tbSincereWords and tbData.tbSincereWords[self.nTab] then
			for i = 1, tbAct.SINCEREWORDS_COUNT do
				self.pPanel:Toggle_SetChecked(tbTab[i], self.nTab == i)
			end
			me.CenterMsg("编辑状态下不能切页")
			return
		end
	end
	self.nTab = nTab
	self:UpdateContent()
end

--更新内容
function tbUi:UpdateContent()
	self:CheckCanEdit()
	if self.bSelf then
		self:UpdateMyContent()
	else
		self:UpdateOtherContent()
	end
end

--检查可编辑
function tbUi:CheckCanEdit()
	if self.bSelf then
		local tbData = tbAct:GetPlayerData(self.nPlayerId)
		local tbAllSincereWords = tbData.tbSincereWords or {}
		local tbSincereWords = tbAllSincereWords[self.nTab]
		if not tbSincereWords then
			self.bEdit = true
		else
			self.bEdit = false
		end
	else
		self.bEdit = false
	end
end

--更新自己情书内容
function tbUi:UpdateMyContent()
	self.nChoosePlayerId = nil
	self.pPanel:SetActive("ContentGroup", true)
	self.pPanel:SetActive("BtnGroup", true)
	local tbData  = tbAct:GetPlayerData(self.nPlayerId)
	local tbAllSincereWords = tbData.tbSincereWords or {}

	local tbSincereWords    = tbAllSincereWords[self.nTab]
	self.pPanel:SetActive("BtnShareLeft", tbSincereWords or false)
	self.pPanel:SetActive("BtnShareRight", tbSincereWords or false)
	self.pPanel:SetActive("BtnChoice", not tbSincereWords)
	self.pPanel:SetActive("BtnEdit", not self.bEdit)
	self.pPanel:SetActive("BtnSubmission", self.bEdit)
	self.pPanel:SetActive("BtnRandom", self.bEdit)
	if not tbSincereWords then
		self.pPanel:Button_SetText("BtnChoice", "请选择")
	end
	self.pPanel:Label_SetText("NameTxt", tbSincereWords and tbSincereWords.szName or "")
	self.pPanel:Label_SetText("ChoiceTxt", tbSincereWords and tbSincereWords.szName and "致  " or "")
	for i = 1, tbAct.SINCEREWORDS_COUNT do
		self.pPanel:Input_SetText("InputField" .. i, tbSincereWords and tbSincereWords.tbContent and tbSincereWords.tbContent[i] or "")
		self.pPanel:SetActive("InputField" .. i, self.bEdit)
	end
	self.pPanel:Label_SetText("PlayerName", "----" .. me.szName)
	self.pPanel:SetActive("BtnFabulous", true)
	self.pPanel:Button_SetText("BtnFabulous", tbSincereWords and tbSincereWords.nLikeCount or 0)
end

--更新他人情书内容
function tbUi:UpdateOtherContent()
	local tbData  = tbAct:GetPlayerData(self.nPlayerId)
	local tbAllSincereWords = tbData.tbSincereWords or {}
	local tbSincereWords    = tbAllSincereWords[self.nTab]
	self.pPanel:SetActive("ContentGroup", tbSincereWords or false)
	self.pPanel:SetActive("BtnGroup", tbSincereWords or false)
	if not tbSincereWords then
		return
	end
	self.pPanel:SetActive("BtnShareLeft", false)
	self.pPanel:SetActive("BtnShareRight", false)
	self.pPanel:SetActive("BtnEdit", false)
	self.pPanel:SetActive("BtnChoice", false)
	self.pPanel:SetActive("BtnFabulous", true)
	self.pPanel:SetActive("BtnSubmission", false)
	self.pPanel:SetActive("BtnRandom", false)
	self.pPanel:Label_SetText("NameTxt", tbSincereWords and tbSincereWords.szName or "")
	self.pPanel:Label_SetText("ChoiceTxt", tbSincereWords and tbSincereWords.szName and "致  " or "")
	for i = 1, tbAct.SINCEREWORDS_COUNT do
		self.pPanel:Input_SetText("InputField" .. i, tbSincereWords and tbSincereWords.tbContent and tbSincereWords.tbContent[i] or "")
		self.pPanel:SetActive("InputField" .. i, self.bEdit)
	end
	self.pPanel:Label_SetText("PlayerName", "----" .. tbData.szName)
	local szLike = tbSincereWords.nLikeCount or 0
	self.pPanel:Button_SetText("BtnFabulous", szLike)
end

function tbUi:OnSyncData()
	self:UpdateContent()
end

--选择玩家
function tbUi:ChoosePlayer()
	local fnChooseCB = function (nChoosePlayerId, szName)
		self:_ChoosePlayer(nChoosePlayerId, szName)
	end
	Ui:OpenWindow("DrinkToDream_ChooseList", fnChooseCB, self.nChoosePlayerId)
end

function tbUi:_ChoosePlayer(nChoosePlayerId, szName)
	self.nChoosePlayerId = nChoosePlayerId
	self.pPanel:Button_SetText("BtnChoice", szName)
end

--随机衷言内容
function tbUi:RandomSincereWordsContent()
	if not self.bEdit then
		return
	end
	local nIdx = MathRandom(#self.tbGivenContent)
	local tbContent = self.tbGivenContent[nIdx]
	for i = 1, tbAct.SINCEREWORDS_COUNT do
		self.pPanel:Input_SetText("InputField" .. i, tbContent[i])
	end
end

--编辑衷言
function tbUi:Edit()
	local tbData = tbAct:GetPlayerData(self.nPlayerId)
	tbData.tbSincereWords  = tbData.tbSincereWords or {}
	tbAct:CheckData(tbData)
	local nModifyTimes = tbData.tbSincereWords[self.nTab].nModifyTimes or 0
	if nModifyTimes >= tbAct.MAX_MODIFY_TIMES then
		me.CenterMsg("当天修改次数已达上限")
		return
	end
	self.bEdit = true
	self:UpdateMyContent()
end

--提交衷言
function tbUi:Commit()
	local tbSincereWordsData = {nIdx = self.nTab, tbContent = {}, nProfessionPlayer = self.nChoosePlayerId}
	for i = 1, tbAct.SINCEREWORDS_COUNT do
		local szTextName = self.pPanel:Input_GetText("InputField" .. i)
		tbSincereWordsData.tbContent[i] = szTextName
	end
	tbAct:Commit(tbSincereWordsData)
end

--分享链接到好友频道
function tbUi:ShareLink()
	RemoteServer.DrinkToDreamClientCall("Share", self.nTab)
end

--分享链接到社交平台
function tbUi:ShareUrl()
	self.bShareBtnOpen = not self.bShareBtnOpen;
    local bLoginByQQ = Sdk:IsLoginByQQ();
    if bLoginByQQ then
    	self.pPanel:SetActive("GroupQQ", self.bShareBtnOpen);
    else
    	self.pPanel:SetActive("GroupWeixin", self.bShareBtnOpen);
    end
end

-- 点赞
function tbUi:Like()
	if self.nPlayerId == me.dwID then
		me.CenterMsg("不能给自己点赞")
		return
	end
	tbAct:Like(self.nPlayerId, self.nTab)
end

function tbUi:OnScreenClick()
	if self.bShareBtnOpen == true then
		local bLoginByQQ = Sdk:IsLoginByQQ();
    	if bLoginByQQ then
    		self.pPanel:SetActive("GroupQQ", false);
    	else
    		self.pPanel:SetActive("GroupWeixin", false);
    	end
    	self.bShareBtnOpen = false;
    end
end

local tbGrid = Ui:CreateClass("DrinkToDream_ChooseList")
function tbGrid:OnOpen(fnChooseCB, nChoosePlayerId)
	local tbList = FriendShip:GetAllFriendData()
	--按亲密度值排序，亲密度相等按等级排
	local fnSort = function (a, b)
		if a.nImity == b.nImity then
			return a.nLevel > b.nLevel
		else
			return a.nImity > b.nImity
		end
	end
	table.sort(tbList, fnSort )
	local fnSet = function (tbItem, nIdx)
		local tbData = tbList[nIdx]
		tbItem.RankingsList.pPanel:Label_SetText("lbRoleName", tbData.szName);
		if tbData.dwID == nChoosePlayerId then
			tbItem.pPanel:Button_SetSprite("RankingsList", "BtnWinterFortunePress")
		else
			tbItem.RankingsList.pPanel:Button_SetSprite("Main", "BtnWinterFortuneNormal")
		end
		tbItem.RankingsList.pPanel.OnTouchEvent = function ()
			fnChooseCB(tbData.dwID, tbData.szName)
			Ui:CloseWindow(self.UI_NAME)
		end
	end
	self.ScrollView:Update(#tbList, fnSet)
end

function tbGrid:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME)
end
