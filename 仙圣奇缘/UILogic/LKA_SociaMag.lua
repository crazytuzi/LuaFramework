 --------------------------------------------------------------------------------------
-- 文件名: LKA_SocialMsgWnd.lua
-- 版  权:    (C)深圳美天互动科技有限公司
-- 创建人: 陆奎安
-- 日  期:    2014-10-5 9:37
-- 版  本:    1.0
-- 描  述:    社交消息回调
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------
SocialMsg = class("SocialMsg")
SocialMsg.__index = SocialMsg

function SocialMsg:ctor()
	self.m_autoHandselFirend = true  	--是否自动赠送爱心
end
--查找玩家回应
function SocialMsg:addCheckNameWnd(msg)
	local exis =  msg.exist 
	local name =  msg.name
	local FindMsg = {}
    local function sendMsgMgr()
        FindMsg.target_name = name
        FindMsg.msg = g_ClientMsgTips.ConfirmInputText
        g_MsgMgr:requestRelationAddFriend(FindMsg)	
		if g_WndMgr:isVisible("Game_Social1") then
			if g_WndMgr:getWnd("Game_Social1") then
				g_WndMgr:getWnd("Game_Social1").TextField_Input:setText("")
			end
		end		
    end 
    local function CallBackCancel()
    end 
	if exis == true then
		local textTlie = _T("向【")..name.._T("】打招呼")
		g_ClientMsgTips:showConfirmInput(textTlie,_T("您好，我可以加您为好友吗？"),20,sendMsgMgr,CallBackCancel)
	else
		g_ClientMsgTips:showMsgConfirm(_T("没有该玩家!"))
	end
end
--信息存储
function SocialMsg:initTBFreindMsg(msginfo)
    local tb_heroMsg = g_Hero.tbMasterBase
    local my_tbMsg = {}
	my_tbMsg.uin = msginfo.uin
    my_tbMsg.vip = msginfo.vip
    my_tbMsg.level =  msginfo.level
    my_tbMsg.fighting = msginfo.fighting
    my_tbMsg.profession = msginfo.profession
    my_tbMsg.area = msginfo.area
    my_tbMsg.industry = msginfo.industry
    if msginfo.area <= 0 then
        my_tbMsg.area = 102
    end
    my_tbMsg.card_info = msginfo.card_info
    my_tbMsg.signature = msginfo.signature
    my_tbMsg.name = msginfo.name
    my_tbMsg.is_man = msginfo.is_man
	my_tbMsg.msgNumber = 0
    g_TBSocial.gamerMsg[msginfo.uin] = my_tbMsg
    return msginfo.uin
end
--离线消息
function SocialMsg:RelationGetOfflineMsg(msginfo)
	for i,v in ipairs(msginfo.friend_chat_msg) do
		self:RelationRecvMsg(v)
	end
	for i,v in ipairs(msginfo.friend_req_msg) do
		self:RelationRecvMsg(v,false)
	end
end
--发送消息回应
function SocialMsg:RelationSendMsgResponse(msginfo)
	local  msg_info  =  msginfo.msg_info
	local myMsg = {}
    myMsg.role_info = msg_info.role_info
    myMsg.msg = msg_info.msg
	myMsg.time = os.time() 
	myMsg.uin = g_MsgMgr:getUin()
	myMsg.name = g_Hero:getMasterName()
	local friendUin = msg_info.role_info.uin
	if g_WndMgr:isVisible("Game_ChatCenter") then
		if g_WndMgr:getWnd("Game_ChatCenter") then
			g_WndMgr:getWnd("Game_ChatCenter"):addChatItem(myMsg)
		end
	else
		--
	end

	g_SALMgr:saveChatData(myMsg,friendUin)
	local tbData  = {}
    tbData.uin = g_MsgMgr:getUin() 
    tbData.msg = myMsg.msg
    tbData.time = myMsg.time
	tbData.name = g_Hero:getMasterName()
	if not g_TBSocial.ChatMSG then
		g_TBSocial.ChatMSG = {}
	end
	table.insert(g_TBSocial.ChatMSG[friendUin],tbData)
end


--设置个人信息回应
function SocialMsg:RelationSetRoleInfoResponse(msginfo)
    local RT_is_man = msginfo.is_man
    local RT_area = msginfo.area
    local RT_signature = msginfo.signature
    local RT_profession = msginfo.profession
    local RT_industry = msginfo.industry
    local my_tbMsg = g_TBSocial.gamerMsg[g_MsgMgr:getUin()]
    
    my_tbMsg.profession = RT_profession
    my_tbMsg.area = RT_area
    my_tbMsg.signature = RT_signature
    my_tbMsg.industry = RT_industry
    my_tbMsg.is_man = RT_is_man
	if g_WndMgr:getWnd("Game_Social1") then
		g_WndMgr:getWnd("Game_Social1"):setImageMyProfilePNL()
	end
 end
--获取uin的玩家信息回应
function SocialMsg:RelationGetRoleInfoResponse(msginfo)
	local RT_uin = self:initTBFreindMsg(msginfo)
	if RT_uin == g_MsgMgr:getUin() then
		return
	end
	if g_WndMgr:getTopWndName() == "Game_ArenaRank" then 
		g_WndMgr:showWnd("Game_ArenaRank")
	elseif g_WndMgr:getTopWndName() == "Game_Social1" then
	end
end
 --设置处理好友申请信息回应  
function SocialMsg:RelationDealAddFriendResponse(msginfo)
    local is_target_deal = msginfo.is_target_deal
    local is_accept = msginfo.is_accept
    local tb_target_role = msginfo.target_role
    local target_uin = tb_target_role.uin
	local name = tb_target_role.name
	
	local function addFriend()
		g_TBSocial.friendList[target_uin] = tb_target_role
		if  g_TBSocial.gamerMsg[target_uin] == nil or g_TBSocial.gamerMsg[target_uin] == {} then
			g_TBSocial.gamerMsg[target_uin] = tb_target_role
		end
		g_SALMgr:saveGamerMsgTable(tb_target_role)
		g_FriendNum = g_FriendNum or 0
		g_FriendNum = g_FriendNum + 1
		if g_WndMgr:getTopWndName() == "Game_Social1" then
			if g_WndMgr:getWnd("Game_Social1") then
				local curCheck = g_WndMgr:getWnd("Game_Social1").ckEquip:getCheckIndex()
				if curCheck == 1 then
					g_WndMgr:getWnd("Game_Social1"):upDateFriendList()
				end
			end
		end
	end
	

	if not is_target_deal then
		if is_accept then
			-- g_MsgMgr:requestRelationGetFriendList()
			addFriend()
			g_ClientMsgTips:showMsgConfirm(_T("您已添加[")..name.._T("]为好友"))
			g_TBSocial.curFriendNum = g_TBSocial.curFriendNum + 1
			if g_WndMgr:getTopWndName() == "Game_Social1" then
				if g_WndMgr:getWnd("Game_Social1") then
					g_WndMgr:getWnd("Game_Social1"):showNotes(true,2,g_TBSocial.curFriendNum)
				end
			end
		else
			g_ClientMsgTips:showMsgConfirm(_T("您已忽略[")..name.._T("]的申请"))
			g_TBSocial.ApplicationList[target_uin] = nil
		end
	else
		if is_accept then
			-- g_MsgMgr:requestRelationGetFriendList()
			addFriend()
			g_ClientMsgTips:showMsgConfirm("["..name.."]".._T("已同意您的请求"))
			g_TBSocial.curFriendNum = g_TBSocial.curFriendNum + 1
			if g_WndMgr:getTopWndName() == "Game_Social1" then
				if g_WndMgr:getWnd("Game_Social1") then
					g_WndMgr:getWnd("Game_Social1"):showNotes(true,2,g_TBSocial.curFriendNum)
				end
			end
		else
			g_ClientMsgTips:showMsgConfirm("【"..name.."】".._T("已忽略您的请求"))
		end
	end
    g_TBSocial.ApplicationList[target_uin] = nil
	--cur_msgName = 4  ---------------当前消息标记 4为处理好友申请信息回应
	if g_WndMgr:getTopWndName() == "Game_Social1" then
		if g_WndMgr:getWnd("Game_Social1") then
			g_WndMgr:getWnd("Game_Social1"):upDateApplicationPNL()
		end
	end
end

 ---好友列表
function SocialMsg:RelationGetFriendListResponse(msginfo)
    local TB_role_list = msginfo.role_list
    g_TBSocial.friendList = {}
	g_FriendNum = 0
    if TB_role_list then
        for i,v in ipairs(TB_role_list) do
            g_TBSocial.friendList[v.uin] = v
			if  g_TBSocial.gamerMsg[v.uin] == nil or g_TBSocial.gamerMsg[v.uin] == {} then
				g_TBSocial.gamerMsg[v.uin] = v
			end
			g_SALMgr:saveGamerMsgTable(v)
			g_FriendNum = g_FriendNum or 0
			g_FriendNum = g_FriendNum + 1 
        end	
    end 
	if g_WndMgr:getTopWndName() == "Game_Social1" then
		if g_WndMgr:getWnd("Game_Social1") then
			local curCheck = g_WndMgr:getWnd("Game_Social1").ckEquip:getCheckIndex()
			if curCheck == 1 then
				g_WndMgr:getWnd("Game_Social1"):upDateFriendList()
			end
		end
	end
	if g_WndMgr:getWnd("Game_ChatCenter") and g_WndMgr:isVisible("Game_ChatCenter") then
		if g_WndMgr:getWnd("Game_Home") then
			g_WndMgr:getWnd("Game_Home").g_initSocial = 1
		end
		g_SALMgr:initSocialApplicationListData(62)
		return
	end
	if g_WndMgr:getWnd("Game_Home").g_initSocial == 0 then
		g_WndMgr:getWnd("Game_Home").g_initSocial = 1
		g_SALMgr:initSocialApplicationListData()
	end
end
 
function SocialMsg:RelationRmFriendResponse(msginfo)
 	g_TBSocial.friendList[msginfo.target_role.uin] = nil
 	g_TBSocial.gamerMsg[msginfo.target_role.uin] = nil
 	g_FriendNum = (g_FriendNum or 1) - 1

    g_Hero:OnFriendDelete(msginfo.target_role.uin)

 	if g_WndMgr:getTopWndName() == "Game_Social1" then
 		if g_WndMgr:getWnd("Game_Social1") then
 			local curCheck = g_WndMgr:getWnd("Game_Social1").ckEquip:getCheckIndex()
 			if curCheck == 1 then
 				g_WndMgr:getWnd("Game_Social1"):upDateFriendList()
 			end
 		end
 	end
 	--g_MsgMgr:requestRelationGetFriendList()
	if not msginfo.is_target_rm then
		g_ClientMsgTips:showMsgConfirm(string.format(_T("已与【%s】断绝好友关系"), msginfo.target_role.name))
	else
		g_ClientMsgTips:showMsgConfirm(string.format(_T("【%s】与你断绝好友关系"), msginfo.target_role.name))
	end
 end

--设置好友申请信息回应
function SocialMsg:RelationAddFriendResponse(msginfo)
    local success = msginfo.success
    local target_uin = msginfo.target_uin
    local msg = msginfo.msg
    local target_name = msginfo.target_name
    local timestamp = msginfo.timestamp
	if target_uin then
		g_ClientMsgTips:showMsgConfirm(_T("向【")..target_name.._T("】打招呼成功"))
	end
end
 
---附近的人回应
function SocialMsg:RelationGetNearByListResponse(msginfo)
    local TB_role_list = msginfo.role_list
    g_TBSocial.NeighborList = {}
    for i, v in ipairs(TB_role_list) do
		if v and v.uin and v.uin > 0 then
			table.insert(g_TBSocial.NeighborList, v)
		end
    end
	if g_WndMgr:getWnd("Game_Social1") then
		g_WndMgr:getWnd("Game_Social1"):upDateNeighborPNL()
	end
 end

--发送处理申请tb
function SocialMsg:setDealAddFmsg(Tg_nUin,is_accept)
    local msg = {}
	msg.target_uin = Tg_nUin
	msg.is_accept = is_accept
	g_MsgMgr:requestRelationDealAddFriend(msg)
end

 ---收到消息
 function SocialMsg:RelationRecvMsg(msginfo, bIsOnline)
    local msg_info = msginfo.msg_info 
    local RelationMsgType = msginfo.type
    local is_offline = msg_info.is_offline
	local timestamp = msg_info.timestamp
	local msg = msg_info.msg
	local role_info = msg_info.role_info
    local target_name = role_info.target_name
    local level = role_info.level
	local name = role_info.name
	local target_uin = role_info.uin
	local vip = role_info.vip
	local area = role_info.area
	local card_info = role_info.card_info
	local signature = role_info.signature
	local profession = role_info.profession
	local fighting = role_info.fighting
	local industry = role_info.industry
	local is_man = role_info.is_man
	local curWnd = g_WndMgr:getWnd("Game_Social1")
    if RelationMsgType == 1 then  --申请信息------当前消息标记 3为好友申请信息回应
		if not curWnd or not g_WndMgr:isVisible("Game_Social1") then
			if bIsOnline then 
				if g_Hero.bubbleNotify then
					if g_Hero.bubbleNotify.social then
						g_Hero.bubbleNotify.social = g_Hero.bubbleNotify.social + 1
					end
				end
			end
			local HomeFunWnd = g_WndMgr:getWnd("Game_HomeFunctionList")
			if HomeFunWnd and g_WndMgr:getWnd("Game_HomeFunctionList").Button_Social then
				g_SetBubbleNotify(g_WndMgr:getWnd("Game_HomeFunctionList").Button_Social, g_Hero.bubbleNotify.social, 20, 20)
			end
			local HomeWnd = g_WndMgr:getWnd("Game_Home")
			if HomeWnd then
				HomeWnd:addNoticeAnimation_Friend()
			end
		end 
		local tbApplication = {}
		tbApplication.msg = msg
		tbApplication.role_info = role_info
		tbApplication.timestamp = timestamp
		tbApplication.name = target_name or name
		tbApplication.level = level
		tbApplication.uin = target_uin
		tbApplication.vip = vip
		tbApplication.card_info = card_info
		tbApplication.area = area
		tbApplication.signature = signature
		tbApplication.profession = profession
		tbApplication.fighting = fighting
		tbApplication.industry = industry
		tbApplication.is_man = is_man

		if card_info[1] then
			tbApplication.card_info = {[1]={}}
			tbApplication.card_info[1].star_lv = card_info[1].star_lv
			tbApplication.card_info[1].configid = card_info[1].configid
			tbApplication.card_info[1].breachlv = card_info[1].breachlv
		end 
        if target_uin ~= 0 and target_uin then          
		    if not g_TBSocial.ApplicationList[target_uin] then 
                g_TBSocial.ApplicationList[target_uin] = {}
		        g_TBSocial.curApplicatNum = g_TBSocial.curApplicatNum + 1
            end
            g_TBSocial.ApplicationList[target_uin] = tbApplication
        end
		if curWnd then
			if g_WndMgr:getWnd("Game_Social1") and g_WndMgr:isVisible("Game_Social1") then
				local curCheck = g_WndMgr:getWnd("Game_Social1").ckEquip:getCheckIndex()
				if curCheck == 2 then
					g_WndMgr:getWnd("Game_Social1"):upDateApplicationPNL()
				else
					curWnd:showNotes(true,3)
				end
			end	
		end
    elseif RelationMsgType == 2 then --聊天
		if target_uin == g_MsgMgr:getUin() then
		else
			local tbData  = {}
			tbData.uin = target_uin
			tbData.msg = msg
			tbData.name = target_name
			tbData.role_info = role_info
			tbData.time = timestamp
			if  g_TBSocial.gamerMsg[target_uin] == nil or  g_TBSocial.gamerMsg[target_uin] == {} then
				if target_name then
					g_TBSocial.gamerMsg[target_uin] = tbData.role_info
				else
					g_setMyMsgstatus = 4
					g_MsgMgr:requestRelationGetRoleInfo(target_uin)
				end
			end
			if g_TBSocial.ChatMSGNum[target_uin] == nil then
				g_TBSocial.ChatMSGNum[target_uin]={}
				g_TBSocial.ChatMSGNum[target_uin].number = 0
			end
			if g_TBSocial.ChatMSGNum[target_uin].number == nil then
				g_TBSocial.ChatMSGNum[target_uin].number = 0
			end
			g_TBSocial.ChatMSGNum[target_uin].number = g_TBSocial.ChatMSGNum[target_uin].number + 1	
			if g_TBSocial.ChatMSG[target_uin] then
				table.insert(g_TBSocial.ChatMSG[target_uin],tbData)
			else
				g_TBSocial.ChatMSG[target_uin] = {}
				table.insert(g_TBSocial.ChatMSG[target_uin],tbData)
			end

			g_TBSocial.NewChatNumber = g_TBSocial.NewChatNumber + 1
			g_SALMgr:saveChatData(tbData,target_uin)
			if g_WndMgr:getWnd("Game_ChatCenter") and g_WndMgr:isVisible("Game_ChatCenter") then
				local curCheck = g_WndMgr:getWnd("Game_ChatCenter").ButtonGroup:getButtonCurIndex()
				if curCheck == 2 then
					if target_uin == g_TBSocial.curChat_uin then 
						g_TBSocial.NewChatNumber = g_TBSocial.NewChatNumber - 1
						g_TBSocial.ChatMSGNum[target_uin].number = 0
						g_WndMgr:getWnd("Game_ChatCenter"):addChatOtherItem(target_uin,tbData)
					else
						g_WndMgr:getWnd("Game_ChatCenter"):updateFriendChatItem(target_uin, tbData.msg)
					end
				end
				g_WndMgr:getWnd("Game_ChatCenter"):showNotes(true)
			end	

			--local numChatCenter = g_TBSocial.NewChatNumber
			--g_Hero:setBubbleNotify("ChatCenter",numChatCenter)
			g_SetBubbleNotify(g_WndMgr:getWnd("Game_Home").Button_ChatCenter,g_Hero:getBubbleNotify("ChatCenter") + g_TBSocial.NewChatNumber, 20, 20)		
		end  
    end
 end

--设置是否自动赠送爱心请求
function SocialMsg:autoHandselFriendRequest(enable)
    local msg = zone_pb.SetAutoReturnHeartFlagReq()
    if enable then
        msg.is_auto_return_heart = true
    else
	    msg.is_auto_return_heart = false
    end
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SET_AUTO_RETURN_HEART_FLAG_REQ, msg)
end

--是否自动赠送爱心
function SocialMsg:setAutoHandselFriend(enable)
    self.m_autoHandselFirend = enable
end

function SocialMsg:getAutoHandselFriend()
    return self.m_autoHandselFirend
end

g_SocialMsg = SocialMsg.new()