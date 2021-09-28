--------------------------------------------------------------------------------------
-- 文件名: 	LKA_ChatCenterWnd.lua
-- 版  权:    (C)深圳美天互动科技有限公司
-- 创建人: 		陆奎安
-- 日  期:    2014-12-5 9:37
-- 版  本:    1.0
-- 描  述:    世界聊天框界面
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

Game_ChatCenter = class("Game_ChatCenter")
Game_ChatCenter.__index = Game_ChatCenter

g_ChatCenter = {
	Chat_Channel_World = {},
	Chat_Channel_Friend = {{1},{2}},
	Chat_Channel_League = {},
	Chat_Channel_Notice = {},
	Chat_Channel_BugReport = {},
}

local ChatChannel = { 
	macro_pb.Chat_Channel_World , --// 世界频道
	macro_pb.Chat_Channel_Friend , --// 好友频道
	macro_pb.Chat_Channel_League , --// 联盟频道
	macro_pb.Chat_Channel_Notice , --// 公告频道
	macro_pb.Chat_Channel_System,
	macro_pb.Chat_Channel_Bug , --// Bug
	macro_pb.Chat_Channel_Complain , --// 投诉
	macro_pb.Chat_Channel_Suggest , --// 建议
	macro_pb.Chat_Channel_Other, --// 其他
}

local ChatBugChannel = {
	macro_pb.Chat_Channel_Bug , --// Bug
	macro_pb.Chat_Channel_Complain , --// 投诉
	macro_pb.Chat_Channel_Suggest , --// 建议
	macro_pb.Chat_Channel_Other, --// 其他
	}

local nMaxChatStrNum = 100
local tbFirstBugOption = {"(BUG)".." ", _T("(投诉)").." ", _T("(建议)").." ", _T("(其他)").." "}
local tbFirstBugReport = {title = "", content = "",CheckBox = 1}

--add by zgj 检查内容重复
tbChatList = {}
local function checkRepeat(szText)
	for k, v in ipairs(tbChatList) do
		if v == szText then
			return false
		end
	end
	table.insert(tbChatList, szText)
	if #tbChatList >5 then
		table.remove(tbChatList, 1)
	end
	return true
end

local function scrollToBottom(listView)
	local function jumpToBottom()
		--有可能不存在，防止报错
		if listView:isExsit() then
			listView:jumpToBottom()
		end
	end
	g_Timer:pushTimer(0.2, jumpToBottom)
end

--设置listViewEx
function Game_ChatCenter:initListViewEx(listView, itemModel, funcUpdateListView, funcAdjustListView)
	if not listView then return end
	
	LuaListView = Class_LuaListView:create()
	LuaListView:setSize(listView:getSize())
	LuaListView:setPosition(listView:getPosition())
	LuaListView:setDirection(LISTVIEW_DIR_VERTICAL)
	
	if itemModel then
		LuaListView:setModel(itemModel)
	end
	
	if funcAdjustListView then
		LuaListView:setAdjustFunc(funcAdjustListView)
	end

	if funcUpdateListView then
		LuaListView:setUpdateFunc(funcUpdateListView)
	end
	
	listView:getParent():addChild(LuaListView:getListView(), 11)
	
	if listView:getName() == "ListView_Friends" then
		local imgScrollSlider = LuaListView:getScrollSlider()
		if not g_tbScrollSliderXY.ListView_Friends_Chat_X then
			g_tbScrollSliderXY.ListView_Friends_Chat_X = imgScrollSlider:getPositionX()
		end
		imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.ListView_Friends_Chat_X - 4)
	elseif listView:getName() == "ListView_BugReport" then
		local imgScrollSlider = LuaListView:getScrollSlider()
		if not g_tbScrollSliderXY.ListView_BugReport_Chat_X then
			g_tbScrollSliderXY.ListView_BugReport_Chat_X = imgScrollSlider:getPositionX()
		end
		imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.ListView_BugReport_Chat_X - 4)
	end

	return LuaListView
end
 
function Game_ChatCenter:setImage_BugReportDetailPNL(Panel_BugReportItem, nIndex)
	local Button_BugReportItem = tolua.cast(Panel_BugReportItem:getChildByName("Button_BugReportItem"), "Button")

	if self.nProIndex and self.nProIndex == 1 and nIndex ~= 1  then
		self.strTextField_Title_BugReport = self.TextField_Title_BugReport:getStringValue()
		self.strTextField_Area_BugReport = self.TextField_Area_BugReport:getStringValue()
		if (self.strTextField_Title_BugReport~="" or self.strTextField_Area_BugReport~="") then
			tbFirstBugReport = {title = self.strTextField_Title_BugReport, content = self.strTextField_Area_BugReport, CheckBox = self.nCurrentBugOptionIndex}
			self.bHasSavedNewBugReport = true
			local Panel_BugReportItem_First = self.ListView_BugReport:getFirstChild()
			local Button_BugReportItem_First = tolua.cast(Panel_BugReportItem_First:getChildByName("Button_BugReportItem"), "Button")
			local Label_ReportStatus = tolua.cast(Button_BugReportItem_First:getChildByName("Label_ReportStatus"), "Label")
			Label_ReportStatus:setText(_T("已保存"))
		end
	end
	
	local Image_CheckCover = tolua.cast(Button_BugReportItem:getChildByName("Image_CheckCover"), "ImageView")
	if self.Image_CheckCover then
		self.Image_CheckCover:setVisible(false)
	end
	self.Image_CheckCover = Image_CheckCover
	self.Image_CheckCover:setVisible(true)

	self.TextField_Title_BugReport:setMaxLength(400)
	self.TextField_Area_BugReport:setMaxLength(400)
	
	local function onTouch_TextField_Area_BugReport(pSender, eventType)
		if eventType == ccs.TextFiledEventType.insert_text or eventType == ccs.TextFiledEventType.delete_backward then
			local strInputValue = self.TextField_Area_BugReport:getStringValue()
			if not strInputValue or  strInputValue == "" then
				g_SetBtnEnable(self.Button_Submit_BugReport, false)
				g_SetBtnEnable(self.Button_Cancel_BugReport, false)
			else
				g_SetBtnEnable(self.Button_Submit_BugReport, true)
				g_SetBtnEnable(self.Button_Cancel_BugReport, true)
			end 

			self.TextField_Area_BugReport:setText(g_stringSize_insert(strInputValue,"\n",22,514))
			self.TextField_Area_BugReport:setPosition(ccp(-261, 145-self.TextField_Area_BugReport:getSize().height/2))
		end
	end
	self.TextField_Area_BugReport:addEventListenerTextField(onTouch_TextField_Area_BugReport)
	
	local function onTouch_TextField_Title_BugReport(pSender, eventType)
		if eventType == ccs.TextFiledEventType.insert_text or eventType == ccs.TextFiledEventType.delete_backward then
			local strInputValue = self.TextField_Title_BugReport:getStringValue()
			if not strInputValue or  strInputValue == "" then
				g_SetBtnEnable(self.TextField_Area_BugReport, false)
				g_SetBtnEnable(self.Button_Cancel_BugReport, false)
			else
				g_SetBtnEnable(self.TextField_Area_BugReport, true)
				g_SetBtnEnable(self.Button_Cancel_BugReport, true)
			end 
		end
	end
	self.TextField_Title_BugReport:addEventListenerTextField(onTouch_TextField_Title_BugReport)
	
	local tbBugReport = {}
	self.nProIndex = nIndex

	if nIndex == 1 then
		self.TextField_Title_BugReport:setText(tbFirstBugReport.title)
		self.TextField_Title_BugReport:setTouchEnabled(true)
		self.TextField_Area_BugReport:setTouchEnabled(true)
		self.TextField_Area_BugReport:setText(tbFirstBugReport.content)
		self.checkBoxGroup_BugReport:Click(tbFirstBugReport.CheckBox)
		self.Button_Submit_BugReport:setVisible(true)
		self.Button_Cancel_BugReport:setVisible(true)
		self.checkBoxGroup_BugReport:getButtonTouchEnabled(true)
	else
		tbBugReport = g_ChatCenter.Chat_Channel_BugReport[nIndex - 1]
		self.TextField_Title_BugReport:setText(tbBugReport.title)
		self.TextField_Area_BugReport:setTouchEnabled(false)
		self.TextField_Title_BugReport:setTouchEnabled(false)
		self.TextField_Area_BugReport:setText(tbBugReport.content)
		self.checkBoxGroup_BugReport:Click(tbBugReport.type)
		self.Button_Submit_BugReport:setVisible(false)
		self.Button_Cancel_BugReport:setVisible(false)
		self.checkBoxGroup_BugReport:getButtonTouchEnabled(false)
	end 
	
	self.TextField_Area_BugReport:setPosition(ccp(-261, 145-self.TextField_Area_BugReport:getSize().height/2))
	
	if not tbFirstBugReport.content or tbFirstBugReport.content == "" then
		g_SetBtnEnable(self.TextField_Area_BugReport, false)
		g_SetBtnEnable(self.Button_Submit_BugReport, false)
		g_SetBtnEnable(self.Button_Cancel_BugReport, false)
	else
		g_SetBtnEnable(self.TextField_Area_BugReport, true)
		g_SetBtnEnable(self.Button_Submit_BugReport, true)
		g_SetBtnEnable(self.Button_Cancel_BugReport, true)
	end 
end

function Game_ChatCenter:setImage_ChatPNL(Panel_FriendsItem, nIndex)
	local Button_FriendsItem = tolua.cast(Panel_FriendsItem:getChildByName("Button_FriendsItem"), "Button")
	
	local Image_CheckCover = tolua.cast(Button_FriendsItem:getChildByName("Image_CheckCover"), "ImageView")
	if self.Image_FriendCheckCover then
		self.Image_FriendCheckCover:setVisible(false)
	end 
	self.Image_FriendCheckCover = Image_CheckCover
	self.Image_FriendCheckCover:setVisible(true)
	self.Image_Head = tolua.cast(Button_FriendsItem:getChildByName("Image_Head"), "ImageView")
	
	g_TBSocial.NewChatNumber = g_TBSocial.NewChatNumber - self.tbServerMsg_Friend[nIndex].lastChat.number
	self.tbServerMsg_Friend[nIndex].lastChat.number = 0
	local uin = self.tbServerMsg_Friend[nIndex].key
	if not g_TBSocial.ChatMSGNum[uin] or not g_TBSocial.ChatMSGNum[uin].number  then
		g_TBSocial.ChatMSGNum[uin] = {}
	end
	g_TBSocial.ChatMSGNum[uin].number  = 0
	local uin = self.tbServerMsg_Friend[nIndex].key
	g_TBSocial.curChat_uin = uin
	g_SALMgr:upDateChatData(uin)
	self:showNotesChatItem(false, uin, self.Image_Head)
	self:showNotes(true)
	self:updataFriendChatWnd()
end

function Game_ChatCenter:setListViewItem_WorldChat()
	local function set_Panel_WorldChatItem(Panel_WorldChatItem, tbServerMsg)
		Panel_WorldChatItem:setVisible(true)
		local Label_Name = tolua.cast(Panel_WorldChatItem:getChildByName("Label_Name"), "Label")
		Label_Name:setText("["..tbServerMsg.sender_name.."]:")
		
		local Label_Dialogure = tolua.cast(Label_Name:getChildByName("Label_Dialogure"), "Label")
		Label_Dialogure:setText(tbServerMsg.content.."("..os.date("%X",tbServerMsg.send_time)..")")

		local nHeight  = Label_Dialogure:getSize().height + 0
		Label_Name:setPosition(ccp(5,nHeight-10))
		
		Label_Dialogure:setAnchorPoint(ccp(0, 1))
		Label_Dialogure:setPosition(ccp(Label_Name:getSize().width, 15))
		
		Panel_WorldChatItem:setSize(CCSizeMake(Panel_WorldChatItem:getSize().width, nHeight))
		
		local function onPressed_Label_Name(pSender, nTag)
			g_MsgMgr:requestViewPlayer(tbServerMsg.sender_uin)
		end
		g_SetBtnWithEvent(Label_Name, nil, onPressed_Label_Name, true)
	end
	
	self.ListView_WorldChatList:removeAllItems()
    for k, v in ipairs(g_ChatCenter.Chat_Channel_World) do
		local Panel_WorldChatItem = tolua.cast(g_WidgetModel.Panel_WorldChatItem:clone(), "Layout")
        self.ListView_WorldChatList:pushBackCustomItem(Panel_WorldChatItem)
        set_Panel_WorldChatItem(Panel_WorldChatItem, v)
	end

end

--显示冒泡
function Game_ChatCenter:showNotes()
	g_SetBubbleNotify(self.Button_FriendChat, g_TBSocial.NewChatNumber, 60, 20)
	g_SetBubbleNotify(g_WndMgr:getWnd("Game_Home").Button_ChatCenter, g_TBSocial.NewChatNumber, 20, 20)
end

--在单个聊天列表Item里显示冒泡
function Game_ChatCenter:showNotesChatItem(bIsVisible, uin, widget)
	local nNoticeNum 
	if bIsVisible then
		
	else
		g_TBSocial.ChatMSGNum[uin].number = 0
	end 
	g_TBSocial.ChatMSGNum[uin] = g_TBSocial.ChatMSGNum[uin] or {}
	if not g_TBSocial.ChatMSGNum[uin] or  not g_TBSocial.ChatMSGNum[uin].number then
		nNoticeNum = 0
		g_TBSocial.ChatMSGNum[uin] = {}
		g_TBSocial.ChatMSGNum[uin].number  = 0
	else
		nNoticeNum = g_TBSocial.ChatMSGNum[uin].number 
	end 
	g_SetBubbleNotify(widget, nNoticeNum, 50, 50)
end	

--删除信息
function Game_ChatCenter:deleteChatMsg(uin)
	g_TBSocial.ChatMSGNum[uin] = nil
	g_SALMgr:DelSocialALData(uin)
	self:updateFriendChat(self.ListView_Friends:getFirstChildIndex())
end

function Game_ChatCenter:setListViewItem_Friends(Panel_FriendsItem, nIndex)
	local uin, tbServerMsg_Friend, tbLastDialogue = self.tbServerMsg_Friend[nIndex].key, self.tbServerMsg_Friend[nIndex].value, self.tbServerMsg_Friend[nIndex].lastChat
	if uin == nil  then
		return
	end
	Panel_FriendsItem:setTag(uin)
	
	local Button_FriendsItem = tolua.cast(Panel_FriendsItem:getChildByName("Button_FriendsItem"), "Button")
	
	local Label_PlayerName = tolua.cast(Button_FriendsItem:getChildByName("Label_PlayerName"), "Label")
	if tbServerMsg_Friend.name == "小语" then
		Label_PlayerName:setText(getFormatSuffixLevel(_T("小语"), g_GetCardEvoluteSuffixByEvoLev(tbServerMsg_Friend.card_info[1].breachlv or 1)))
	else
		Label_PlayerName:setText(getFormatSuffixLevel(tbServerMsg_Friend.name, g_GetCardEvoluteSuffixByEvoLev(tbServerMsg_Friend.card_info[1].breachlv or 1)))
	end
	g_SetCardNameColorByEvoluteLev(Label_PlayerName, tbServerMsg_Friend.card_info[1].breachlv or 1)
	
	local LabelAtlas_Sex = tolua.cast(Label_PlayerName:getChildByName("LabelAtlas_Sex"), "LabelAtlas")
	if tbServerMsg_Friend.is_man == true or tbServerMsg_Friend.is_man == 1 or tbServerMsg_Friend.is_man == "1" then
		LabelAtlas_Sex:setStringValue(2)
	else
		LabelAtlas_Sex:setStringValue(1)
	end
	LabelAtlas_Sex:setPosition(ccp(Label_PlayerName:getSize().width + 8,0))
	
	local Label_Dialogue = tolua.cast(Button_FriendsItem:getChildByName("Label_Dialogue"), "Label")
	local strLastDialogue = stringSub(tbLastDialogue.lastMsg,1,20).."...."
	if not tbLastDialogue.lastMsg or tbLastDialogue.lastMsg == "" then
		strLastDialogue = ""
	end
    Label_Dialogue:setText(strLastDialogue)
	
	local Label_Level = tolua.cast(Button_FriendsItem:getChildByName("Label_Level"), "Label")
	Label_Level:setText(_T("Lv.")..tbServerMsg_Friend.level) 
	
	local Image_CheckCover = tolua.cast(Button_FriendsItem:getChildByName("Image_CheckCover"), "ImageView")
	Image_CheckCover:setVisible(false)
	
	local tbHeadInfo = {}
	local leaderID = tbServerMsg_Friend.card_info[1].configid
	local level = tbServerMsg_Friend.card_info[1].star_lv
	tbHeadInfo.Image_Icon = getCardIconImg(leaderID,level)
	tbHeadInfo.vip = tbServerMsg_Friend.vip
	tbHeadInfo.uin = tbServerMsg_Friend.uin
	tbHeadInfo.star = level
	tbHeadInfo.breachlv = tbServerMsg_Friend.card_info[1].breachlv
	tbHeadInfo.strName = tbServerMsg_Friend.name
	
	local Image_Head = tolua.cast(Button_FriendsItem:getChildByName("Image_Head"), "ImageView")
	g_SetPlayerHead(Image_Head, tbHeadInfo, true)

	tbLastDialogue.number  = tbLastDialogue.number or 0
	g_TBSocial.NewChatNumber = g_TBSocial.NewChatNumber + tbLastDialogue.number 
	self:showNotesChatItem(true, uin, Image_Head)	

	local function onPressed_Image_Head(pSender, nTag)
		g_MsgMgr:requestViewPlayer(uin)
	end
	g_SetBtnWithEvent(Image_Head, nil, onPressed_Image_Head, true)
	
	local function onPressed_Button_FriendsItem(pSender, nTag)
		self.ListView_Friends:scrollToTop()
	end
	g_SetBtnWithEvent(Button_FriendsItem, nil, onPressed_Button_FriendsItem, true)
end

function Game_ChatCenter:setListViewItem_SystemBrocast()
	local function setSystemBrocastItem(Panel_SystemBrocastItem, tbBrocastNotice)
		-- Panel_SystemBrocastItem:setVisible(true)
		-- local Label_Name = tolua.cast(Panel_SystemBrocastItem:getChildByName("Label_Name"), "Label")
		-- Label_Name:setText("[公告]:")
		
		-- local Label_Dialogure = tolua.cast(Label_Name:getChildByName("Label_Dialogure"), "Label")
		-- Label_Dialogure:setText(tbBrocastNotice.content.."("..os.date("%X",tbBrocastNotice.send_time)..")")
		-- if not tbBrocastNotice.sender_name or tbBrocastNotice.sender_name == ""  then
		-- 	Label_Dialogure:setColor(ccc3(255, 255, 0))
		-- else
		-- 	Label_Dialogure:setColor(ccc3(255, 255, 255))
			
		-- 	local function onPressed_Label_Name(pSender, nTag)
		-- 		g_MsgMgr:requestViewPlayer(tbBrocastNotice.sender_uin)
		-- 	end
		-- 	g_SetBtnWithEvent(Label_Name, nil, onPressed_Label_Name, true)
		-- end

		-- local nHeight  = Label_Dialogure:getSize().height + 0
		-- Label_Name:setPosition(ccp(5, nHeight - 10))
		
		-- Panel_SystemBrocastItem:setSize(CCSizeMake(Panel_SystemBrocastItem:getSize().width, nHeight))
		
		-- Label_Dialogure:setAnchorPoint(ccp(0, 1))
		-- Label_Dialogure:setPosition(ccp(Label_Name:getSize().width,15))
		local text, time = tbBrocastNotice:getDataTxt_time()
		local ShowText = _T("[公告]:")..text.."c11("..os.date("%X",time)..")"
		local Label_SystemBrocast = tolua.cast(Panel_SystemBrocastItem:getChildByName("Label_Dialogure"), "Label")
		Label_SystemBrocast:setAnchorPoint(ccp(0,0))
		gCreateColorLable(Label_SystemBrocast, ShowText)
		local pos = Label_SystemBrocast:getPosition()
		Label_SystemBrocast:setPosition(ccp(pos.x, pos.y-7))
	end
	
	local tbnotice = g_GameNoticeSystem:GetNoticFormRecode() or {}
    for k, v in ipairs(tbnotice) do
		local Panel_SystemBrocastItem = tolua.cast(g_WidgetModel.Panel_SystemBrocastItem:clone(),"Layout")
		Panel_SystemBrocastItem:setAnchorPoint(ccp(0,0))
        self.ListView_SystemBrocastList:pushBackCustomItem(Panel_SystemBrocastItem)
        setSystemBrocastItem(Panel_SystemBrocastItem, v)
        
	end
end

function Game_ChatCenter:setListViewItem_BugReport(Panel_BugReportItem, nIndex)
	local Button_BugReportItem = tolua.cast(Panel_BugReportItem:getChildByName("Button_BugReportItem"), "Button")
	
	local Label_ReportTitle = tolua.cast(Button_BugReportItem:getChildByName("Label_ReportTitle"), "Label")
	local Label_ReportStatus = tolua.cast(Button_BugReportItem:getChildByName("Label_ReportStatus"), "Label")
	local Image_SubmitFlag = tolua.cast(Button_BugReportItem:getChildByName("Image_SubmitFlag"), "ImageView")
	local Image_CheckCover = tolua.cast(Button_BugReportItem:getChildByName("Image_CheckCover"), "ImageView")
	
	if nIndex == 1 then
		Label_ReportTitle:setText(_T("创建新的问题...."))
		if self.bHasSavedNewBugReport == true then
			Label_ReportStatus:setText(_T("已保存"))
		else
			Label_ReportStatus:setText(_T("未创建"))
		end
		Image_SubmitFlag:setVisible(false)
		Image_CheckCover:setVisible(true)
	else  
		local tbBugReport = g_ChatCenter.Chat_Channel_BugReport[nIndex - 1]
		if not tbBugReport  then  return  end
		
		Label_ReportTitle:setText(tbFirstBugOption[tbBugReport.type]..tbBugReport.title)
		Label_ReportStatus:setText(getStrTime(tbBugReport.time))
		Image_SubmitFlag:setVisible(true)
		Image_CheckCover:setVisible(false)
	end
	
	local function onPressed_Button_BugReportItem(pSender, nTag)
		self.ListView_BugReport:scrollToTop()
	end
	g_SetBtnWithEvent(Button_BugReportItem, nil, onPressed_Button_BugReportItem, true)
end

--刷新界面
function Game_ChatCenter:updateWorldChat()
	if not self.bIsFirstRequest then
		self.bIsFirstRequest = true
		self.checkWorldChat = true
		g_MsgMgr:requestFirstChatRequest()
	end 
	self.ListView_WorldChatList:removeAllItems()
	self:setListViewItem_WorldChat()
	scrollToBottom(self.ListView_WorldChatList)
end

local function sortBroadcastChat(tbBrocastChatA, tbBrocastChatB)
	if not tbBrocastChatA.lastChat.lastTime then
		tbBrocastChatA.lastChat.lastTime  = 0
	end 
	if not tbBrocastChatB.lastChat.lastTime then
		tbBrocastChatB.lastChat.lastTime  = 0
	end
	if tbBrocastChatA.lastChat.lastTime == tbBrocastChatB.lastChat.lastTime then
		if tbBrocastChatA.value.level == tbBrocastChatB.value.level then
			return tbBrocastChatA.value.vip > tbBrocastChatA.value.vip
		else
			return tbBrocastChatB.value.level > tbBrocastChatA.value.level
		end
	else
		 
		return tonumber(tbBrocastChatA.lastChat.lastTime) > tonumber(tbBrocastChatB.lastChat.lastTime)
	end
end

--刷新单个聊天ListViewItem 
function Game_ChatCenter:updateFriendChatItem(uin, strLastDialogue)
	local Panel_FriendsItem = nil
	for i = 1, self.ListView_Friends:getChildrenCount() do
		local Panel_FriendsItemTemp = self.ListView_Friends:getChildByIndex(i-1)
		local nTag = Panel_FriendsItemTemp:getTag()
		if uin == nTag then	
			Panel_FriendsItem = Panel_FriendsItemTemp
		end
	end
	if not Panel_FriendsItem then return end
	
	local Button_FriendsItem = tolua.cast(Panel_FriendsItem:getChildByName("Button_FriendsItem"), "Button")
	
	local strText = stringSub(strLastDialogue,1,20).."...."
	if not strLastDialogue or strLastDialogue == "" then strText = "" end
	
	local Label_Dialogue = tolua.cast(Button_FriendsItem:getChildByName("Label_Dialogue"),"Label")
	Label_Dialogue:setText(strText)
	
	local Image_Head = tolua.cast(Button_FriendsItem:getChildByName("Image_Head"),"ImageView")
	self:showNotesChatItem(true, uin, Image_Head)	
end

function Game_ChatCenter:updateFriendChat(nBeginIndex)
	local nBeginIndex = nBeginIndex or 1
	
	self.Image_FriendCheckCover = nil
	self.tbServerMsg_Friend = {}
	g_TBSocial.NewChatNumber = 0
	for i,v in pairs(g_TBSocial.friendList) do
		local tb_ChatMSGNum = {}
		if g_TBSocial.ChatMSGNum[i] then
			tb_ChatMSGNum = g_TBSocial.ChatMSGNum[i]
		else
			tb_ChatMSGNum.lastTime = 0
			tb_ChatMSGNum.lastMsg = ""
			tb_ChatMSGNum.number = 0
		end
		if not tb_ChatMSGNum.number then tb_ChatMSGNum.number  = 0 end 
		g_TBSocial.NewChatNumber = g_TBSocial.NewChatNumber + tb_ChatMSGNum.number
		table.insert(self.tbServerMsg_Friend, {key=i, value = v, lastChat = tb_ChatMSGNum})
	end
	table.sort(self.tbServerMsg_Friend, sortBroadcastChat)
	
	self.ListView_Friends:updateItems(#self.tbServerMsg_Friend, nBeginIndex)
	
	local Image_Input = tolua.cast(self.Image_FriendChatPNL:getChildByName("Image_Input"), "TextField")
	local TextField_Input = tolua.cast(Image_Input:getChildByName("TextField_Input"), "TextField")
	if #self.tbServerMsg_Friend == 0 then
		TextField_Input:setTouchEnabled(false)
	else
		TextField_Input:setTouchEnabled(true)
	end 
end

--刷新公告
function Game_ChatCenter:updateSystemBroadcast()
	self.ListView_SystemBrocastList:removeAllItems()
	self:setListViewItem_SystemBrocast()
	scrollToBottom(self.ListView_SystemBrocastList)

	--注册刷新公告界面消息
	g_FormMsgSystem:RegisterFormMsg(FormMsg_ChatNotice_UpdataForm, handler(self, self.updateSystemBroadcast))
end

--刷新bug提交
local function sortBugReport(tbBugReportA, tbBugReportB)
	if tbBugReportA.time == tbBugReportB.time then
	else
		return tbBugReportA.time > tbBugReportA.time
	end
end

function Game_ChatCenter:updateBugReport()
	self.Image_CheckCover = nil
	table.sort(g_ChatCenter.Chat_Channel_BugReport, sortBugReport)
	self.ListView_BugReport:updateItems(#g_ChatCenter.Chat_Channel_BugReport + 1)
end

function Game_ChatCenter:initButton()
	local function onPressed_Button_Send(nTag, Image_ChatPNL, nChatWidth)
		local nChatWidth = nChatWidth or nChatWidth
		
		local Image_Input = tolua.cast(Image_ChatPNL:getChildByName("Image_Input"), "ImageView")
		local TextField_Input = tolua.cast(Image_Input:getChildByName("TextField_Input"), "TextField")
		
		local strInputValue = TextField_Input:getStringValue()
        if strInputValue == "" or strInputValue == nil then
			return
        end
		
		if nTag == 2 then
			strInputValue = g_stringSize_insert(strInputValue, "\n", 20, 550) 
			local tbInputMsg = {}
			tbInputMsg.msg = strInputValue
			tbInputMsg.target_uin = g_TBSocial.curChat_uin
			g_MsgMgr:requestRelationSendMsg(tbInputMsg)
		elseif nTag == 1 then
			local nNeedLevel = g_DataMgr:getGlobalCfgCsv("WorldChat_need_level")
			if g_Hero:getMasterCardLevel() < nNeedLevel then
				g_ClientMsgTips:showMsgConfirm(_T("需要等级达到")..nNeedLevel) 
				return
			end
			
			local nCoolTime = g_DataMgr:getGlobalCfgCsv("WorldChat_cool_time")
			local nCoolTimeMin = math.floor(nCoolTime*100/60)/100.0
			if self.bIsInCoolTime == true then
				g_ClientMsgTips:showMsgConfirm(_T("每")..nCoolTimeMin.._T("分钟才能发言一次哦，亲~"))
				return
			end
			
			strInputValue = g_stringSize_insert(strInputValue, "\n", 22, 800) 
			if checkRepeat(strInputValue) then
				
				--喇叭的配置id itembase 12
				local nHorn = g_Hero:getItemNumByCsv(12, 1)
				if nHorn > 0 then
					local tbInputMsg = {}
					tbInputMsg.uin = g_MsgMgr:getUin()
					tbInputMsg.channel = ChatChannel[nTag]
					tbInputMsg.title = ""
					tbInputMsg.content = strInputValue
					g_MsgMgr:requestChatRequest(tbInputMsg)
					g_ClientMsgTips:showMsgConfirm(_T("世界聊天发言消耗[嘹亮的号角]x1")) 
				else
					g_ClientMsgTips:showMsgConfirm(_T("世界聊天发言需要消耗[嘹亮的号角]，您拥有的数量为0")) 
				end
			else
				g_ClientMsgTips:showMsgConfirm(_T("不要频繁发送重复内容哟，亲")) 
			end
			
			local function clearCoolTime()
				self.bIsInCoolTime = false
			end
			
			g_Timer:pushTimer(nCoolTime, clearCoolTime)
			self.bIsInCoolTime = true
		else
			local tb_msg = {}
			tb_msg.uin = g_MsgMgr:getUin()
			tb_msg.channel = ChatChannel[nTag]
			tb_msg.title = ""
			tb_msg.content = strInputValue
			g_MsgMgr:requestChatRequest(tb_msg)
		end
		local Label_ChatNum = tolua.cast(Image_Input:getChildByName("Label_ChatNum"),"Label")
		Label_ChatNum:setText("0/"..nMaxChatStrNum)
		TextField_Input:setText("")
	end	
	
	--设置职业回调
    local function findFriendByName(ConfirmInputText)
		if ConfirmInputText  then
			if ConfirmInputText and ConfirmInputText ~= "" then
				g_MsgMgr:relationCheckNameRequest(ConfirmInputText)
			end	 
		end
    end 	
	local function onClick_Button(pSender, nTag)
		if nTag == 1 then
			onPressed_Button_Send(nTag, self.Image_WorldChatPNL, nChatWidth)
		elseif nTag == 2 then
			onPressed_Button_Send(nTag, self.Image_FriendChatPNL, 23)
		elseif nTag == 3 then
			g_SALMgr:initSocialApplicationListData(40)
		elseif nTag == 4 then

		elseif nTag == 5 then
			local strTextField_Title = self.TextField_Title_BugReport:getStringValue()
			local strTextField_Area = self.TextField_Area_BugReport:getStringValue()
			if strTextField_Title == "" or strTextField_Area == "" then
			else
				local tbBugReportInput = {}
				tbBugReportInput.title = strTextField_Title
				tbBugReportInput.content = strTextField_Area
				tbBugReportInput.type = self.nCurrentBugOptionIndex or 1
				tbBugReportInput.time = os.time()
				table.insert(g_ChatCenter.Chat_Channel_BugReport, tbBugReportInput)
				
				self:updateBugReport()
				
				local tbBugReportMsg = {}
				tbBugReportMsg.uin = g_MsgMgr:getUin()
				tbBugReportMsg.channel = ChatBugChannel[tbBugReportInput.type]  --ChatChannel[nTag]
				tbBugReportMsg.title = strTextField_Title
				tbBugReportMsg.content = strTextField_Area
				g_MsgMgr:requestChatRequest(tbBugReportMsg)
				
				g_SALMgr:saveBugData(tbBugReportInput)
				g_SetBtnEnable(self.Button_Submit_BugReport, false)
				g_SetBtnEnable(self.TextField_Area_BugReport, false)
				g_SetBtnEnable(self.Button_Cancel_BugReport, false)
			end 
		elseif nTag == 6 then
			self.TextField_Title_BugReport:setText("")
			self.TextField_Area_BugReport:setText("")
			local Panel_BugReportItem = self.ListView_BugReport:getFirstChild()
			local Button_BugReportItem = tolua.cast(Panel_BugReportItem:getChildByName("Button_BugReportItem"), "Button")
			local Label_ReportStatus = tolua.cast(Button_BugReportItem:getChildByName("Label_ReportStatus"), "Label")
			Label_ReportStatus:setText(_T("未创建"))
			
			self.strTextField_Title_BugReport = ""
			self.strTextField_Area_BugReport = ""
			self.checkBoxGroup_BugReport:Click(1)
			tbFirstBugReport = {title = "", content = "", CheckBox = 1}
			self.bHasSavedNewBugReport = false
			g_SetBtnEnable(self.Button_Submit_BugReport, false)
			g_SetBtnEnable(self.TextField_Area_BugReport, false)
			g_SetBtnEnable(self.Button_Cancel_BugReport, false)
		end
	end
	
	local Image_Input = tolua.cast(self.Image_WorldChatPNL:getChildByName("Image_Input"), "ImageView")
	self.Button_Send_WorldChat = tolua.cast(Image_Input:getChildByName("Button_Send"), "Button")
	g_SetBtnWithEvent(self.Button_Send_WorldChat, 1, onClick_Button, true)
	
	local Image_Input = tolua.cast(self.Image_FriendChatPNL:getChildByName("Image_Input"), "ImageView")
	self.Button_Send_FriendChat = tolua.cast(Image_Input:getChildByName("Button_Send"), "Button")
	g_SetBtnWithEvent(self.Button_Send_FriendChat, 2, onClick_Button, true)
	
	local Image_FriendsPNL = tolua.cast(self.Image_FriendChatPNL:getChildByName("Image_FriendsPNL"), "ImageView")
	self.Button_Submit_FriendChat = tolua.cast(Image_FriendsPNL:getChildByName("Button_Submit"), "Button")
	g_SetBtnWithEvent(self.Button_Submit_FriendChat, 3, onClick_Button, true)
	
	local Image_BugReportDetailPNL = tolua.cast(self.Image_BugReportPNL:getChildByName("Image_BugReportDetailPNL"), "ImageView")
	self.Button_Submit_BugReport = tolua.cast(Image_BugReportDetailPNL:getChildByName("Button_Submit"), "Button")
	g_SetBtnWithEvent(self.Button_Submit_BugReport, 5, onClick_Button, true)

	self.Button_Cancel_BugReport = tolua.cast(Image_BugReportDetailPNL:getChildByName("Button_Cancel"), "Button")
	g_SetBtnWithEvent(self.Button_Cancel_BugReport, 6, onClick_Button, true)
	
	local function initTextField(Image_ChatPNL, nTouchSizeWidth, bEnabled)
		local bEnabled = bEnabled or true
		
		local Image_Input = tolua.cast(Image_ChatPNL:getChildByName("Image_Input"), "ImageView")
		local TextField_Input = tolua.cast(Image_Input:getChildByName("TextField_Input"), "TextField")
		local Label_ChatNum = tolua.cast(Image_Input:getChildByName("Label_ChatNum"), "Label")
		Label_ChatNum:setText("0/"..nMaxChatStrNum)
		TextField_Input:setTouchSize(CCSizeMake(nTouchSizeWidth, 0))
		TextField_Input:setMaxLength(300)
		TextField_Input:setTouchEnabled(bEnabled)
		local function textFieldEvent(pSender, eventType)
			if eventType == ccs.TextFiledEventType.insert_text or eventType == ccs.TextFiledEventType.delete_backward then
				local mString = TextField_Input:getStringValue()
				local InputNum,maxString = stringNum(mString,nMaxChatStrNum)
				if InputNum >= nMaxChatStrNum then
					Label_ChatNum:setText(nMaxChatStrNum.."/"..nMaxChatStrNum)
					TextField_Input:setText(maxString)
					return
				end 
				Label_ChatNum:setText(InputNum.."/"..nMaxChatStrNum)
			end
		end
		TextField_Input:addEventListenerTextField(textFieldEvent) 
	end
	initTextField(self.Image_WorldChatPNL, 750)
	initTextField(self.Image_FriendChatPNL, 380)
end

function Game_ChatCenter:initListViewWnd()	
	--世界聊天
	self.ListView_WorldChatList = tolua.cast(self.Image_WorldChatPNL:getChildByName("ListView_WorldChatList"),"ListView")
	self.ListView_WorldChatList:removeAllItems()
	
	--公告
	self.ListView_SystemBrocastList = tolua.cast(self.Image_SystemBrocastPNL:getChildByName("ListView_SystemBrocastList"),"ListView")
	self.ListView_SystemBrocastList:removeAllItems()
	
	local Image_ChatPNL = tolua.cast(self.Image_FriendChatPNL:getChildByName("Image_ChatPNL"), "ImageView")
	self.ListView_ChatList = tolua.cast(Image_ChatPNL:getChildByName("ListView_ChatList"),"ListView")
	self.ListView_ChatList:removeAllItems()
	
	local function updataList_BugReport(Panel_BugReportItem, nIndex)
		self:setListViewItem_BugReport(Panel_BugReportItem, nIndex)
	end

	local function updataListView_Friends(Panel_FriendsItem, nIndex)
		self:setListViewItem_Friends(Panel_FriendsItem, nIndex)
	end
	
	local Image_FriendsPNL = tolua.cast(self.Image_FriendChatPNL:getChildByName("Image_FriendsPNL"), "ImageView")
	local ListView_Friends = tolua.cast(Image_FriendsPNL:getChildByName("ListView_Friends"), "ListViewEx")
	local Panel_FriendsItem = tolua.cast(g_WidgetModel.Panel_FriendsItem:clone(), "Layout")
	self.ListView_Friends = self:initListViewEx(ListView_Friends, Panel_FriendsItem, updataListView_Friends, function(Panel_FriendsItem, nIndex)
		self:setImage_ChatPNL(Panel_FriendsItem, nIndex)
	end)
	
	local Image_BugReportPNL = tolua.cast(self.Image_BugReportPNL:getChildByName("Image_BugReportPNL"), "ImageView")
	local ListView_BugReport = tolua.cast(Image_BugReportPNL:getChildByName("ListView_BugReport"), "ListView")
	local Panel_BugReportItem = tolua.cast(g_WidgetModel.Panel_BugReportItem:clone(), "Layout")
	self.ListView_BugReport = self:initListViewEx(ListView_BugReport, Panel_BugReportItem, updataList_BugReport, function(Panel_BugReportItem, nIndex)
		self:setImage_BugReportDetailPNL(Panel_BugReportItem, nIndex)
	end)
end

function Game_ChatCenter:initWnd()
	local Image_ChatCenterPNL = tolua.cast(self.rootWidget:getChildByName("Image_ChatCenterPNL"), "ImageView")
	
	self.Button_WorldChat = tolua.cast(Image_ChatCenterPNL:getChildByName("Button_WorldChat"), "Button")
	self.Button_FriendChat = tolua.cast(Image_ChatCenterPNL:getChildByName("Button_FriendChat"), "Button")
	self.Button_SystemBrocast = tolua.cast(Image_ChatCenterPNL:getChildByName("Button_SystemBrocast"), "Button")
	self.Button_BugReport = tolua.cast(Image_ChatCenterPNL:getChildByName("Button_BugReport"), "Button")
	
	self.Image_WorldChatPNL = tolua.cast(Image_ChatCenterPNL:getChildByName("Image_WorldChatPNL"), "ImageView")
	self.Image_FriendChatPNL = tolua.cast(Image_ChatCenterPNL:getChildByName("Image_FriendChatPNL"), "ImageView")
	self.Image_SystemBrocastPNL = tolua.cast(Image_ChatCenterPNL:getChildByName("Image_SystemBrocastPNL"), "ImageView")
	self.Image_BugReportPNL = tolua.cast(Image_ChatCenterPNL:getChildByName("Image_BugReportPNL"), "ImageView")
	
	--按钮组
	local ButtonGroup = ButtonGroup:create()
	self.ButtonGroup = ButtonGroup
	ButtonGroup:PushBack(self.Button_WorldChat, self.Image_WorldChatPNL, function()
		self:updateWorldChat()
	end, true)
	
	ButtonGroup:PushBack(self.Button_FriendChat, self.Image_FriendChatPNL, function()
		if not self.CheckData then
			self.CheckData = true
			ButtonGroup:setCheckData(false)
			g_SALMgr:initSocialApplicationListData(62)
		else
			self:showNotes(true)
			ButtonGroup:setCheckData(true)
		end
		self:updateFriendChat()
	end)
	
	ButtonGroup:PushBack(self.Button_SystemBrocast, self.Image_SystemBrocastPNL, function()
		self:updateSystemBroadcast()
	end)
	
	-- ButtonGroup:PushBack(self.Button_BugReport, self.Image_BugReportPNL, function()
		-- if not self.CheckBugData then
			-- self.CheckBugData = true
			-- g_SALMgr:upDateBugDataByUin()
		-- end
		-- self:updateBugReport()	
	-- end)
	
	self.checkBoxGroup_BugReport = CheckBoxGroup:New()
	local function onCheck_BugOption(nIndex)
		self.nCurrentBugOptionIndex = nIndex
    end
	
	local Image_BugReportDetailPNL = tolua.cast(self.Image_BugReportPNL:getChildByName("Image_BugReportDetailPNL"), "ImageView")
	for i = 1,4 do
		local CheckBox_Option = tolua.cast(Image_BugReportDetailPNL:getChildByName("CheckBox_Option"..i), "CheckBox")
		self.checkBoxGroup_BugReport:PushBack(CheckBox_Option, onCheck_BugOption)
	end
	
	local Image_ReportTitle = tolua.cast(Image_BugReportDetailPNL:getChildByName("Image_ReportTitle"), "ImageView")
	self.TextField_Title_BugReport = tolua.cast(Image_ReportTitle:getChildByName("TextField_Title"), "TextField")

	local Image_ReportDetail = tolua.cast(Image_BugReportDetailPNL:getChildByName("Image_ReportDetail"), "ImageView")
	self.TextField_Area_BugReport = tolua.cast(Image_ReportDetail:getChildByName("TextField_Area"), "TextField")


	self:initListViewWnd(widget)
	self:initButton()
	--self:updateFriendChat()
	--self:initFriendChatWnd()
	
	-- 暂时关闭客服功能
	self.Button_BugReport:setVisible(false)
	self.Image_BugReportPNL:setVisible(false)
end

function Game_ChatCenter:checkData()
	return true
end

function Game_ChatCenter:closeWnd(tbData)
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_ChatNotice_UpdataForm)
	self.strTextField_Title_BugReport = self.strTextField_Title_BugReport or ""
	self.strTextField_Area_BugReport = self.strTextField_Area_BugReport or ""
	if self.nProIndex and self.nProIndex == 1 then
		self.strTextField_Title_BugReport = self.TextField_Title_BugReport:getStringValue()
		self.strTextField_Area_BugReport = self.TextField_Area_BugReport:getStringValue()
		if (self.strTextField_Title_BugReport~="" or self.strTextField_Area_BugReport~="") then
			tbFirstBugReport = {title = self.strTextField_Title_BugReport,content = self.strTextField_Area_BugReport,CheckBox = self.nCurrentBugOptionIndex}
			self.bHasSavedNewBugReport = true
		end
	end

	self.ListView_WorldChatList:removeAllItems()
	self.ListView_SystemBrocastList:removeAllItems()
	self.ListView_ChatList:removeAllItems()
	self.ListView_Friends:updateItems(0)
	self.ListView_Friends:getListView():removeFromParentAndCleanup(true)
	self.ListView_BugReport:updateItems(0)
	self.ListView_BugReport:getListView():removeFromParentAndCleanup(true)

	g_Hero:setBubbleNotify("ChatCenter",0)
end

function Game_ChatCenter:destroyWnd()
	self:destroyFriendChatWnd()
end

function setChatCenterMessage(tbMsg)
	local ChatChannelIndex = {
		g_ChatCenter.Chat_Channel_World,
		g_ChatCenter.Chat_Channel_Friend ,
		g_ChatCenter.Chat_Channel_League ,
		g_ChatCenter.Chat_Channel_Notice ,
		g_ChatCenter.Chat_Channel_BugReport
	}
	local tb_ChannelMsg 
	for i,v in ipairs(tbMsg.chat_info) do
		local tb_msg = {}
		if v.channel == macro_pb.Chat_Channel_Bug or v.channel == macro_pb.Chat_Channel_Complain  
		or v.channel == macro_pb.Chat_Channel_Suggest or v.channel == macro_pb.Chat_Channel_Other
		or v.channel == macro_pb.Chat_Channel_System then
			return
		elseif    v.channel == macro_pb.Chat_Channel_Notice then
			tb_ChannelMsg = g_ChatCenter.Chat_Channel_Notice
			if #tb_ChannelMsg > 30 then --吱记录30条
				table.remove(tb_ChannelMsg, 1)
			end
		else
			tb_ChannelMsg = ChatChannelIndex[v.channel]

		end
		tb_msg.sender_uin = v.sender_uin
		tb_msg.sender_name = v.sender_name
		tb_msg.content = v.content
		tb_msg.send_time = v.send_time
		tb_msg.vip_lv = v.vip_lv
		table.insert(tb_ChannelMsg,tb_msg)
	end
end

--打开界面调用
function Game_ChatCenter:openWnd(uin)
    if g_bReturn  then  return  end

	self:showNotes(true)
	local nIndex = 1	
	if uin then
		nIndex = 2
	end 
	self.ButtonGroup:Click(nIndex)
	if nIndex == 2 then
		for i, v in ipairs(self.tbServerMsg_Friend) do
			if uin == v.key then 
				self.ListView_Friends:updateItems(#self.tbServerMsg_Friend,i)
			end
		end
	end

	--好友加上等级限制
	if not g_CheckFuncCanOpenByWidgetName("Button_Friend") then
		self.Button_FriendChat:addTouchEventListener(function (widget, eventType)
			if ccs.TouchEventType.ended == eventType then
				g_ClientMsgTips:showMsgConfirm(_T("好友功能尚未开放，努力升级哦"))
			end
		end)
	end
	
end

function Game_ChatCenter:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_ChatCenterPNL = tolua.cast(self.rootWidget:getChildByName("Image_ChatCenterPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_ChatCenterPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
	mainWnd:showMainHomeZoomInAnimation()
end

function Game_ChatCenter:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_ChatCenterPNL = tolua.cast(self.rootWidget:getChildByName("Image_ChatCenterPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	local function actionEndCall()
		if funcWndCloseAniCall then
			funcWndCloseAniCall()
		end
		mainWnd:showMainHomeZoomOutAnimation()
	end
	g_CreateUIDisappearAnimation_Scale(Image_ChatCenterPNL, actionEndCall, 1.05, 0.15, Image_Background)
end

