--------------------------------------------------------------------------------------
-- 文件名:	SocialDict.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	陆奎安
-- 日  期:	2013-2-22 9:37
-- 版  本:	1.0
-- 描  述:	聊天界面
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

SocialApplicationList = class("SocialApplicationList")
SocialApplicationList.__index = SocialApplicationList

function SocialApplicationList:creat()
    self.g_chatlistTable = "chatlistTable"..g_MsgMgr:getUin() 
    self.g_SocialgamerMsgTable = "SocialgamerMsgTable"..g_MsgMgr:getUin() 
    self.g_ChatDataTable = "ChatDataTable"..g_MsgMgr:getUin() 
	self.g_MailDataTable = "MailDataTable"..g_MsgMgr:getUin() 
	self.g_BugDataTable = "BugDataTable"..g_MsgMgr:getUin() 
	local db = g_DbMgr:getDB()
    self.db = db

    if self.db ~= nil then
    	local createChatlistTable = "CREATE TABLE "..self.g_chatlistTable.." (uin  INTEGER PRIMARY KEY, time, lastMsg , number);"
	    db:exec(createChatlistTable)
	    local createGamerMsgTable = "CREATE TABLE "..self.g_SocialgamerMsgTable.." (uin  INTEGER PRIMARY KEY,name,vip,level,fighting,profession,industry,area,signature,isman,configid,starlv);"
	    db:exec(createGamerMsgTable)
	    local createChatDataTable = "CREATE TABLE "..self.g_ChatDataTable.." (id  INTEGER PRIMARY KEY, uin, curUin,time, msg);"
	    db:exec(createChatDataTable)
		local createMailDataTable = "CREATE TABLE "..self.g_MailDataTable.." (id  INTEGER PRIMARY KEY, mailId , mailTitle ,mailType , timestamp, gainFlag, context, dropNum1,dropIcon1 ,dropframePath1, dropNum2,dropIcon2 ,dropframePath2, dropNum3,dropIcon3 ,dropframePath3, dropNum4,dropIcon4 ,dropframePath4);"
	    db:exec(createMailDataTable)
		local createBugDataTable = "CREATE TABLE "..self.g_BugDataTable.." (id  INTEGER PRIMARY KEY, uin, bugType,title, content,time);"
	    db:exec(createBugDataTable)
    end
end

--删除聊天列表信息 --(uin  INTEGER PRIMARY KEY, time, lastMsg);"
function SocialApplicationList:DelSocialALData(uin)
    local dbStr = "DELETE  FROM "..self.g_chatlistTable.." where uin = "..uin
    self.db:exec(dbStr)
	g_TBSocial.ChatMSGNum[uin] = nil
end

--保存聊天列表信息 --(uin  INTEGER PRIMARY KEY, time, lastMsg);"
function SocialApplicationList:saveSocialALData(uin)
	g_TBSocial.ChatMSGNum[uin].number = g_TBSocial.ChatMSGNum[uin].number or 0
    local dbStr = "replace INTO "..self.g_chatlistTable.." VALUES ('"..uin.."', '"..g_TBSocial.ChatMSGNum[uin].lastTime.."', '"..g_TBSocial.ChatMSGNum[uin].lastMsg.."', "..g_TBSocial.ChatMSGNum[uin].number..");"
    self.db:exec(dbStr)
end

--读取聊天列表信息
function SocialApplicationList:upDateSocialALData()
    for row in self.db:nrows("SELECT * FROM "..self.g_chatlistTable) do
        local uin = tonumber(row.uin)
        if not g_TBSocial.ChatMSGNum[uin] then
            g_TBSocial.ChatMSGNum[uin] = {}
        end
        if not g_TBSocial.ChatMSG[uin] then
            g_TBSocial.ChatMSG[uin] = {}
        end
        local ntime = row.time or ""
        local lastMsg = row.lastMsg or ""

        g_TBSocial.ChatMSGNum[uin].lastMsg = lastMsg
        g_TBSocial.ChatMSGNum[uin].lastTime =  ntime
		g_TBSocial.ChatMSGNum[uin].number =  number
    end
end

--读取聊天信息  -(id  INTEGER PRIMARY KEY, uin, curUin, time, msg);
function SocialApplicationList:upDateChatData(uin)
    if g_TBSocial.ChatMSG[uin] and g_TBSocial.ChatMSG[uin][1] then
       return
    end
    for row in self.db:nrows("SELECT * FROM "..self.g_ChatDataTable.." where uin="..uin) do
        local tbData  = {}
        tbData.uin = tonumber(row.curUin)    
        tbData.msg = row.msg
        tbData.time = row.time
        if not g_TBSocial.ChatMSG[uin] then
             g_TBSocial.ChatMSG[uin] = {}
        end
        table.insert(g_TBSocial.ChatMSG[uin],tbData)
    end 
	g_oldChatTime =  os.time() 
	
	function ChatSort(tb1,tb2)
		return tb1.time < tb2.time
	end
	g_TBSocial.ChatMSG[uin] = g_TBSocial.ChatMSG[uin] or {}
	table.sort(g_TBSocial.ChatMSG[uin],ChatSort)
end

--保存聊天信息  -(id  INTEGER PRIMARY KEY, uin, curUin, time, msg);
function SocialApplicationList:saveChatData(tbData,friendUin)
    local roleInfo = "INSERT INTO "..self.g_ChatDataTable.." VALUES (NULL, "..friendUin..", "..tbData.uin..", '"..tbData.time.."', '"..tbData.msg.."');"           
    self.db:exec(roleInfo)
    if not g_TBSocial.ChatMSGNum[friendUin] then
        g_TBSocial.ChatMSGNum[friendUin] = {}
    end
    g_TBSocial.ChatMSGNum[friendUin].lastTime = tbData.time
    g_TBSocial.ChatMSGNum[friendUin].lastMsg = tbData.msg
	g_TBSocial.ChatMSGNum[friendUin].number = g_TBSocial.ChatMSGNum[friendUin].number 
    self:saveSocialALData(friendUin)
end

---保存GamerMsgTable
function SocialApplicationList:saveGamerMsgTable(tb_msg)
	local isman = 0
	local signature = ""
	local industry = ""
	local profession = ""
	local configid = 10
	local starlv = 0
	if tb_msg.card_info[1] then
		configid = tb_msg.card_info[1].configid
		starlv = tb_msg.card_info[1].star_lv
	end
	if tb_msg.is_man == true then
	   isman = 1
	else 
		isman = 0
	end
	if tb_msg.signature and tb_msg.signature ~= "" then
		signature =  tb_msg.signature
	else 
		signature = _T("人的一生确实是需要一个伟大的签名...")
	end

	if tb_msg.industry and tb_msg.industry ~= "" then
		industry = tb_msg.industry
	else
		industry = _T("其他")
	end

	if tb_msg.profession and tb_msg.profession ~= "" then
		profession =  tb_msg.profession
	else
		profession = _T("无业游民")
	end
	local roleInfo1 = "replace INTO "..(self.g_SocialgamerMsgTable or ("SocialgamerMsgTable"..g_MsgMgr:getUin())).." VALUES ("..tb_msg.uin..",'"..tb_msg.name.."','"..tb_msg.vip.."','"..tb_msg.level.."','"..tb_msg.fighting.."','"..profession.."','"..industry.."','"..tb_msg.area.."','"..signature.."','"..isman.."','"..configid.."','"..starlv.."');"
	self.db:exec(roleInfo1)
end

---读取GamerMsgTable --(uin  PRIMARY KEY,name,vip,level,fighting,profession,industry,area,signature,isman,configid,starlv);"
function SocialApplicationList:upDateGamerMsgDataByUin(uin)
    for row in self.db:nrows("SELECT * FROM "..(self.g_SocialgamerMsgTable or ("SocialgamerMsgTable"..g_MsgMgr:getUin())).." where uin="..uin) do
        local my_tbMsg = {}
        my_tbMsg.vip = row.vip
        my_tbMsg.level =  row.level
        my_tbMsg.fighting = row.fighting
        my_tbMsg.profession = row.profession
        my_tbMsg.area = tonumber( row.area)
        my_tbMsg.industry = row.industry
        if my_tbMsg.area <= 0 then
            my_tbMsg.area = 102
        end
        if not my_tbMsg.card_info then
            my_tbMsg.card_info = {}
        end
        my_tbMsg.card_info[1] = {["configid"] = tonumber(row.configid),["star_lv"] = tonumber(row.starlv)}
        my_tbMsg.signature = row.signature
   
        my_tbMsg.name = row.name
        my_tbMsg.is_man = row.isman
        my_tbMsg.msgNumber = 0
        g_TBSocial.gamerMsg[tonumber(row.uin)] = my_tbMsg
    end
end

function SocialApplicationList:upDateGamerMsgDataByTabel()
    for k,v in pairs(g_TBSocial.ChatMSGNum) do
        self:upDateGamerMsgDataByUin(k)
    end
	local wnd = g_WndMgr:getWnd("Game_Home")
	if wnd then
		wnd.g_IsupDate = 1
	end
end

function SocialApplicationList:initSocialApplicationListData(tag)
	self.curWndTag = tag or self.curWndTag
	
	local wnd = g_WndMgr:getWnd("Game_Home")
	if not wnd then return end
	
	wnd.g_initSocial = wnd.g_initSocial or 0
	wnd.g_IsupDate = wnd.g_IsupDate or 0
    if wnd.g_IsupDate == 0 then
        self:upDateSocialALData()
        self:upDateGamerMsgDataByTabel()
    end
	if wnd.g_initSocial == 0  then
		g_MsgMgr:ignoreCheckWaitTime(nil)
		g_MsgMgr:ignoreCheckWaitTime(true)
		local nNum = 1
		local function callbackSetMsg(fd, bOver)
			if nNum == 1 then
				g_MsgMgr:requestRelationGetRoleInfo(g_MsgMgr:getUin())
			elseif nNum == 2 then
				g_MsgMgr:requestRelationGetOfflineMsg()
			else
				g_MsgMgr:requestRelationGetFriendList()
			end 
			nNum = nNum + 1
		end                       
		g_Timer:pushLimtCountTimer(3, 0.3, callbackSetMsg)	
		return
	end
	
	if self.curWndTag == 62 then
		local instance = g_WndMgr:getWnd("Game_ChatCenter")
		if instance then
			instance.ButtonGroup:Click(2)
		end
	else
		g_WndMgr:openWnd("Game_Social1")
	end 
end

--保存邮件
function SocialApplicationList:saveMailData(tb_msg)
	local roleInfo1 = "INSERT INTO "..self.g_MailDataTable
	.." VALUES (NULL ,'"..tb_msg.mail_id.."','"..tb_msg.mail_title.."','"
	..tb_msg.mail_type.."','"..tb_msg.timestamp.."','"..tb_msg.gain_flag.."','"
	..tb_msg.context.."','"
	..tb_msg.drop_result[1].nNum.."','"..tb_msg.drop_result[1].icon.."','"..tb_msg.drop_result[1].framePath.."','"
	..tb_msg.drop_result[2].nNum.."','"..tb_msg.drop_result[2].icon.."','"..tb_msg.drop_result[2].framePath.."','"
	..tb_msg.drop_result[3].nNum.."','"..tb_msg.drop_result[3].icon.."','"..tb_msg.drop_result[3].framePath.."','"
	..tb_msg.drop_result[4].nNum.."','"..tb_msg.drop_result[4].icon.."','"..tb_msg.drop_result[4].framePath.."');"
	self.db:exec(roleInfo1)
end
--读取邮件
function SocialApplicationList:upDateMailDataByUin()
	g_Mail.tb_ConfigMgrMailItem = {}
	local i = 0
	for row in self.db:nrows("SELECT * FROM "..self.g_MailDataTable) do
        local my_tbMsg = {}
        my_tbMsg.mail_id = row.mailId
        my_tbMsg.mail_title =  row.mailTitle
		my_tbMsg.mail_type = tonumber(row.mailType)
        my_tbMsg.timestamp =  row.timestamp
		my_tbMsg.gain_flag = row.gainFlag
        my_tbMsg.context =  row.context
		my_tbMsg.drop_result = {} 
		my_tbMsg.drop_result[1] = {}
		my_tbMsg.drop_result[1].nNum = row.dropNum1 
		my_tbMsg.drop_result[1].icon =  row.dropIcon1
		my_tbMsg.drop_result[1].framePath = row.dropframePath1
		my_tbMsg.drop_result[2] = {}
		my_tbMsg.drop_result[2].nNum = row.dropNum2 
		my_tbMsg.drop_result[2].icon =  row.dropIcon2
		my_tbMsg.drop_result[2].framePath = row.dropframePath2
		my_tbMsg.drop_result[3] = {}
		my_tbMsg.drop_result[3].nNum = row.dropNum3 
		my_tbMsg.drop_result[3].icon =  row.dropIcon3
		my_tbMsg.drop_result[3].framePath = row.dropframePath3
		my_tbMsg.drop_result[4] = {}
		my_tbMsg.drop_result[4].nNum = row.dropNum4 
		my_tbMsg.drop_result[4].icon =  row.dropIcon4
		my_tbMsg.drop_result[4].framePath = row.dropframePath4
		table.insert(g_Mail.tb_ConfigMgrMailItem,my_tbMsg)
		i = i + 1
    end
end
--保存bug单
function SocialApplicationList:saveBugData(tb_bugMsg)
	if not tb_bugMsg then
		return
	end 
	local bugInfo = "INSERT INTO "..self.g_BugDataTable.." VALUES (NULL, "..g_MsgMgr:getUin()..", "..tb_bugMsg.type..", '"..tb_bugMsg.title.."', '"..tb_bugMsg.content.."', "..tb_bugMsg.time..");"           
	self.db:exec(bugInfo)
end
--读取bug单
function SocialApplicationList:upDateBugDataByUin()
	g_ChatCenter.Chat_Channel_BugReport = {}
	for row in self.db:nrows("SELECT * FROM "..self.g_BugDataTable) do
        local my_tbMsg = {}
        my_tbMsg.title = row.title
        my_tbMsg.content =  row.content
		my_tbMsg.type = row.bugType
        my_tbMsg.time =  row.time
		table.insert(g_ChatCenter.Chat_Channel_BugReport,my_tbMsg)
    end
end
g_SALMgr = SocialApplicationList:new()