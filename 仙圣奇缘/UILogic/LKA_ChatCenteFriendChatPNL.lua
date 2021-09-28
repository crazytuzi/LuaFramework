--------------------------------------------------------------------------------------
-- 文件名: 	LKA_ChatCenterWnd.lua
-- 版  权:    (C)深圳美天互动科技有限公司
-- 创建人: 		陆奎安
-- 日  期:    2014-12-5 9:37
-- 版  本:    1.0
-- 描  述:    好友聊天框界面
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

local chatSpace = 52 --聊天框之间的间隔
local chat_h = 50
local chat_v = 3
local chatStrLen = chat_h*chat_v  --可输入最大字数
local chatStrNum = 150  --可输入最大字数
local chatStrWidth = 20 -- 宽
g_oldChatTime  = 0

function Game_ChatCenter:scrollToBottom()
	local function jumpToBottom()
		if not g_WndMgr:getWnd("Game_ChatCenter") then return end
		
		self.ListView_ChatList:jumpToBottom()
	end
	g_Timer:pushTimer(0.2, jumpToBottom)
end

function Game_ChatCenter:setChatItem(Panel_ChatListItem, tb_chatMSG)
    Panel_ChatListItem:setVisible(true)
    
	local Label_Name = tolua.cast(Panel_ChatListItem:getChildByName("Label_Name"),"Label")
	if tb_chatMSG.uin == g_TBSocial.curChat_uin  then
		Label_Name:setText("["..g_TBSocial.friendList[g_TBSocial.curChat_uin].name.."]:")
	else
		Label_Name:setText("["..g_Hero:getMasterName().."]:")
	end
	
	local Label_Dialogure = tolua.cast(Label_Name:getChildByName("Label_Dialogure"),"Label")
	Label_Dialogure:setText(tb_chatMSG.msg)
	
	local nHeight  = chatSpace + Label_Dialogure:getSize().height
	Label_Name:setPosition(ccp(Label_Name:getPosition().x, nHeight - 38))

    Panel_ChatListItem:setSize(CCSizeMake(Panel_ChatListItem:getSize().width, nHeight))
	
	local uinMsg = g_TBSocial.gamerMsg[tb_chatMSG.uin]
	if uinMsg == nil then
		uinMsg = g_TBSocial.friendList[tb_chatMSG.uin]
		g_TBSocial.gamerMsg[tb_chatMSG.uin] = uinMsg
	end
	
	local nTime = tonumber(tb_chatMSG.time)
	local strTime = os.date("%X", nTime)
	local nDate = os.date("%d", nTime)
	local nMonth = os.date("%m", nTime)
	local nYear = os.date("%Y", nTime)
	local Label_Time = tolua.cast(Label_Name:getChildByName("Label_Time"), "Label")
    Label_Time:setText(nYear.."/"..nMonth.."/"..nDate.."  "..strTime)
	Label_Time:setPosition(ccp(Label_Name:getSize().width + 10, 0))
end 

function Game_ChatCenter:setChatWnd()
	if g_TBSocial.gamerMsg[g_TBSocial.curChat_uin] == nil or  g_TBSocial.gamerMsg[g_TBSocial.curChat_uin] == {} then	
		g_MsgMgr:requestRelationGetRoleInfo(g_TBSocial.curChat_uin)
		return
	end
	if not g_TBSocial.ChatMSGNum[g_TBSocial.curChat_uin] then
	else
		g_TBSocial.ChatMSGNum[g_TBSocial.curChat_uin].number = 0
	end
    
	local tb_Info = g_TBSocial.gamerMsg[g_TBSocial.curChat_uin]

    self.ListView_ChatList:setDirection(SCROLLVIEW_DIR_VERTICAL)
    self.ListView_ChatList:removeAllItems()
    self.ListView_ChatList:removeAllChildren()
	local is_DivStatus = true
    if g_TBSocial.ChatMSG[g_TBSocial.curChat_uin] then
        for k,v in ipairs(g_TBSocial.ChatMSG[g_TBSocial.curChat_uin]) do
			local nNum = #g_TBSocial.ChatMSG[g_TBSocial.curChat_uin]
			if #g_TBSocial.ChatMSG[g_TBSocial.curChat_uin] > 50 and k<( nNum - 50 ) then
			else
				local chatMsg = v.msg
				local chatPlayer = v.uin
				local chatTime = tonumber(v.time)
				local Panel_ChatListItem 
				if g_oldChatTime < chatTime and is_DivStatus  then
					Panel_ChatListItem = tolua.cast(g_WidgetModel.Panel_ChatListItemDiv:clone(), "Layout")
					self.ListView_ChatList:pushBackCustomItem(Panel_ChatListItem)
					is_DivStatus = false
				end
				if chatPlayer == g_TBSocial.curChat_uin then
					Panel_ChatListItem = tolua.cast(g_WidgetModel.Panel_ChatListItemOther:clone(), "Layout")
					self.ListView_ChatList:pushBackCustomItem(Panel_ChatListItem)
					self:setChatItem(Panel_ChatListItem, v)
				else
					Panel_ChatListItem = tolua.cast(g_WidgetModel.Panel_ChatListItemMe:clone(), "Layout")
					self.ListView_ChatList:pushBackCustomItem(Panel_ChatListItem)
					self:setChatItem(Panel_ChatListItem, v)
				end	
				if k == #g_TBSocial.ChatMSG[g_TBSocial.curChat_uin]  and is_DivStatus  then
					Panel_ChatListItem = tolua.cast(g_WidgetModel.Panel_ChatListItemDiv:clone(), "Layout")
					self.ListView_ChatList:pushBackCustomItem(Panel_ChatListItem)
					is_DivStatus = false
				end
			end
        end
    else
        g_TBSocial.ChatMSG[g_TBSocial.curChat_uin] = {}
    end
	self:scrollToBottom()
end

function Game_ChatCenter:addChatItem(tbData)
	local Panel_ChatListItem = tolua.cast(g_WidgetModel.Panel_ChatListItemMe:clone(), "Layout")
    self:setChatItem(Panel_ChatListItem, tbData)
    self.ListView_ChatList:pushBackCustomItem(Panel_ChatListItem)

	self:scrollToBottom()
	local Panel_FriendsItem = self.ListView_Friends:getFirstChild()
	local Button_FriendsItem = tolua.cast(Panel_FriendsItem:getChildByName("Button_FriendsItem"), "Button")
	local Label_Dialogue = tolua.cast(Button_FriendsItem:getChildByName("Label_Dialogue"),"Label")
	local strText = stringSub(tbData.msg, 1, 20).."...."
	if not tbData.msg or tbData.msg == "" then strText = "" end 
	Label_Dialogue:setText(strText)
end 

function Game_ChatCenter:addChatOtherItem(target_uin, tbData)
	g_TBSocial.ChatMSGNum[target_uin].number = 0
	
	local Panel_ChatListItem = tolua.cast(g_WidgetModel.Panel_ChatListItemOther:clone(), "Layout")
    self:setChatItem(Panel_ChatListItem, tbData)
	self.ListView_ChatList:pushBackCustomItem(Panel_ChatListItem)
	self:scrollToBottom()
	
	local Panel_FriendsItem = self.ListView_Friends:getFirstChild()
	local Button_FriendsItem = tolua.cast(Panel_FriendsItem:getChildByName("Button_FriendsItem"), "Button")
	local Label_Dialogue = tolua.cast(Button_FriendsItem:getChildByName("Label_Dialogue"),"Label")
	local strText = stringSub(tbData.msg,1,20).."...."
	if not tbData.msg or tbData.msg == "" then text = "" end 
	Label_Dialogue:setText(strText)
end 

function Game_ChatCenter:destroyFriendChatWnd()

end
--打开界面调用
function Game_ChatCenter:updataFriendChatWnd()
	self:setChatWnd()
end
