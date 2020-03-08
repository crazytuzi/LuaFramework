local tbUi = Ui:CreateClass("YXJQ_PlayerQS")
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
		self:RandomQSContent()
	end;
	BtnShareLeft = function (self)
		self:ShareLink()
	end;
	BtnShareRight = function (self)
		self:ShareScreenShot()
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
}
local tbTab = {"BtnLove", "BtnLTeacher","BtnFriend"}
for nIdx, szBtn in ipairs(tbTab) do
	tbUi.tbOnClick[szBtn] = function (self)
		self:ChangeTab(nIdx)
	end
end

function tbUi:RegisterEvent()
	return { {UiNotify.emNOTIFY_SYNC_YXJQ_DATA, self.OnSyncData} }
end

local tbAct = Activity.YinXingJiQingAct
function tbUi:OnOpenEnd(nPlayerId, nTab)
	self.bSelf  = nPlayerId == me.dwID
	if not self.bSelf and not tbAct:GetPlayerData(nPlayerId) then
		return 0
	end

	self.nTab      = nTab or 1
	self.nPlayerId = nPlayerId
	for i = 1, tbAct.QS_COUNT do
		self.pPanel:Toggle_SetChecked(tbTab[i], self.nTab == i)
	end
	self:UpdateContent()
end

function tbUi:ChangeTab(nTab)
	if self.nTab == nTab then
		return
	end

	if self.bEdit then
		local tbData = tbAct:GetPlayerData(self.nPlayerId)
		if tbData.tbQS and tbData.tbQS[self.nTab] then
			for i = 1, tbAct.QS_COUNT do
				self.pPanel:Toggle_SetChecked(tbTab[i], self.nTab == i)
			end
			me.CenterMsg("编辑状态下不能切页")
			return
		end
	end
	self.nTab = nTab
	self:UpdateContent()
end

function tbUi:UpdateContent()
	self:CheckCanEdit()
	if self.bSelf then
		self:UpdateMyContent()
	else
		self:UpdateOtherContent()
	end
end

function tbUi:CheckCanEdit()
	if self.bSelf then
		local tbData = tbAct:GetPlayerData(self.nPlayerId)
		local tbAllQS = tbData.tbQS or {}
		local tbQS = tbAllQS[self.nTab]
		if not tbQS then
			self.bEdit = true
		else
			self.bEdit = false
		end
	else
		self.bEdit = false
	end
end

function tbUi:UpdateMyContent()
	self.nChoosePlayerId = nil
	self.pPanel:SetActive("ContentGroup", true)
	self.pPanel:SetActive("BtnGroup", true)
	local tbData  = tbAct:GetPlayerData(self.nPlayerId)
	local tbAllQS = tbData.tbQS or {}
	local tbQS    = tbAllQS[self.nTab]
	self.pPanel:SetActive("BtnShareLeft", tbQS or false)
	self.pPanel:SetActive("BtnShareRight", true)
	self.pPanel:SetActive("BtnChoice", not tbQS)
	self.pPanel:SetActive("BtnEdit", not self.bEdit)
	self.pPanel:SetActive("BtnSubmission", self.bEdit)
	self.pPanel:SetActive("BtnRandom", self.bEdit)
	if not tbQS then
		self.pPanel:Button_SetText("BtnChoice", "请选择")
	end
	self.pPanel:Label_SetText("NameTxt", tbQS and tbQS.szName or "")
	self.pPanel:Label_SetText("ChoiceTxt", tbQS and tbQS.szName and "致  " or "")
	for i = 1, Activity.YinXingJiQingAct.QS_COUNT do
		self.pPanel:Input_SetText("InputField" .. i, tbQS and tbQS.tbContent and tbQS.tbContent[i] or "")
		self.pPanel:SetActive("InputField" .. i, self.bEdit)
	end
	self.pPanel:Label_SetText("PlayerName", "----" .. me.szName)
	self.pPanel:SetActive("BtnFabulous", true)
	self.pPanel:Button_SetText("BtnFabulous", tbQS and tbQS.nLikeCount or 0)
end

function tbUi:UpdateOtherContent()
	local tbData  = tbAct:GetPlayerData(self.nPlayerId)
	local tbAllQS = tbData.tbQS or {}
	local tbQS    = tbAllQS[self.nTab]
	self.pPanel:SetActive("ContentGroup", tbQS or false)
	self.pPanel:SetActive("BtnGroup", tbQS or false)
	if not tbQS then
		return
	end
	self.pPanel:SetActive("BtnShareLeft", false)
	self.pPanel:SetActive("BtnShareRight", false)
	self.pPanel:SetActive("BtnEdit", false)
	self.pPanel:SetActive("BtnChoice", false)
	self.pPanel:SetActive("BtnFabulous", true)
	self.pPanel:SetActive("BtnSubmission", false)
	self.pPanel:SetActive("BtnRandom", false)
	self.pPanel:Label_SetText("NameTxt", tbQS and tbQS.szName or "")
	self.pPanel:Label_SetText("ChoiceTxt", tbQS and tbQS.szName and "致  " or "")
	for i = 1, Activity.YinXingJiQingAct.QS_COUNT do
		self.pPanel:Input_SetText("InputField" .. i, tbQS and tbQS.tbContent and tbQS.tbContent[i] or "")
		self.pPanel:SetActive("InputField" .. i, self.bEdit)
	end
	self.pPanel:Label_SetText("PlayerName", "----" .. tbData.szName)
	local szLike = tbQS.nLikeCount or 0
	self.pPanel:Button_SetText("BtnFabulous", szLike)
end

function tbUi:OnSyncData()
	self:UpdateContent()
end

function tbUi:ChoosePlayer()
	local fnChooseCB = function (nChoosePlayerId, szName)
		self:_ChoosePlayer(nChoosePlayerId, szName)
	end
	Ui:OpenWindow("YXJQ_ChooseList", fnChooseCB)
end
 
function tbUi:_ChoosePlayer(nChoosePlayerId, szName)
	self.nChoosePlayerId = nChoosePlayerId
	self.pPanel:Button_SetText("BtnChoice", szName)
end

function tbUi:RandomQSContent()
	if not self.bEdit then
		return
	end
	local nIdx = MathRandom(#self.tbGivenContent)
	local tbContent = self.tbGivenContent[nIdx]
	for i = 1, Activity.YinXingJiQingAct.QS_COUNT do
		self.pPanel:Input_SetText("InputField" .. i, tbContent[i])
	end
end

function tbUi:ShareLink()
	RemoteServer.YinXingJiQingClientCall("Share", self.nTab)
end

function tbUi:ShareScreenShot()
	Ui:OpenWindow("YXJQ_SharePanel")
end 

function tbUi:Edit()
	local tbData = tbAct:GetPlayerData(self.nPlayerId)
	tbData.tbQS  = tbData.tbQS or {}
	tbAct:CheckData(tbData)
	local nModifyTimes = tbData.tbQS[self.nTab].nModifyTimes or 0
	if nModifyTimes >= tbAct.MAX_MODIFY then
		me.CenterMsg("当天修改次数已达上限")
		return
	end
	self.bEdit = true
	self:UpdateMyContent()
end

function tbUi:Commit()
	local tbQSData = {nIdx = self.nTab, tbContent = {}, nProfessionPlayer = self.nChoosePlayerId}
	for i = 1, Activity.YinXingJiQingAct.QS_COUNT do
		local szTextName = self.pPanel:Input_GetText("InputField" .. i)
		tbQSData.tbContent[i] = szTextName
	end
	tbAct:Commit(tbQSData)
end

function tbUi:Like()
	if self.nPlayerId == me.dwID then
		me.CenterMsg("不能给自己点赞")
		return
	end
	tbAct:Like(self.nPlayerId, self.nTab)
end

local tbGrid = Ui:CreateClass("YXJQ_ChooseList")
function tbGrid:OnOpen(fnChooseCB)
	local tbList = FriendShip:GetAllFriendData()
	local fnSet = function (tbItem, nIdx)
		local tbData = tbList[nIdx]
		tbItem.pPanel:Label_SetText("lbRoleName", tbData.szName)
		tbItem.pPanel.OnTouchEvent = function ()
			fnChooseCB(tbData.dwID, tbData.szName)
			Ui:CloseWindow(self.UI_NAME)
		end
	end
	self.ScrollView:Update(#tbList, fnSet)
end

function tbGrid:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME)
end