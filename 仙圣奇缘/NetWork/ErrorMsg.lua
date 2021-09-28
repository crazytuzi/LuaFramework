-- 文件名:	ErrorMsg.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	2015.11.12
-- 版  本:	1.0
-- 描  述:	处理网络异常时 断线重连
-- 应  用:  1维护 tbListen 添加活着 删除table中的元素。2 监控一条发送的消息 ListenMsg(MsgID) 与 RelieveListenMsg 配合使用。

--添加标准验证逻辑
local tbListen = 
{
	[msgid_pb.MSGID_SUMMON_CARD_REQUEST]=
	{
		[1]=msgid_pb.MSGID_SUMMON_CARD_RESPONSE, 
		[2]=msgid_pb.MSGID_DROP_RESULT_NOTIFY
	},

	-- [msgid_pb.MSGID_UPDATE_NEWBIE_GUIDE_REQUEST]=
	-- {
	-- 	[1]=msgid_pb.MSGID_UPDATE_NEWBIE_GUIDE_RESPONSE
	-- },

	[msgid_pb.MSGID_UPGRADE_CARD_REALM_REQUEST]=
	{
		[1]=msgid_pb.MSGID_UPGRADE_CARD_REALM_RESPONSE 
	},

	[msgid_pb.MSGID_ATTACK_SMALLPASS_REQUEST]=
	{
		[1]=msgid_pb.MSGID_BATTLESCENE_NOTIFY 
	},

	[msgid_pb.MSGID_CHANGE_ARRAYOP_REQUEST]=
	{
		[1]=msgid_pb.MSGID_CHANGE_ARRAYOP_RESPONSE
	},

	[msgid_pb.MSGID_BREACH_CARD_REQUEST]=
	{
		[1]=msgid_pb.MSGID_BREACH_CARD_RESPONSE
	},

	[msgid_pb.MSGID_STRENGTHEN_EQUIP_REQUEST]=
	{
		[1]=msgid_pb.MSGID_STRENGTHEN_EQUIP_RESPONSE
	},

	[msgid_pb.MSGID_MAP_POINT_INFO_REQUEST]=
	{
		[1]=msgid_pb.MSGID_MAP_POINT_INFO_RESPONSE, 
		[2]=msgid_pb.MSGID_MAP_STAR_BOX_NOTIFY 
	},

	[msgid_pb.MSGID_BATTLE_RESULT_REQUEST]=
	{
		[1]=msgid_pb.MSGID_BATTLE_RESULT_NOTIFY
	},

	[msgid_pb.MSGID_ONCE_LVUP_SKILL_REQUEST]=
	{
		[1]=msgid_pb.MSGID_ONCE_LVUP_SKILL_RESPONSE
	},

	[msgid_pb.MSGID_SWEEP_REQUEST]=
	{
		[1]=msgid_pb.MSGID_SWEEP_RESPONSE 
	},

	-- [msgid_pb.MSGID_SWEEP_JING_YING_REQUEST]={msgid_pb.MSGID_SWEEP_JING_YING_RESPONSE },

	[msgid_pb.MSGID_INSPIRE_REQUEST]=
	{
		[1]=msgid_pb.MSGID_INSPIRE_RESPONSE
	},

	--合成装备
	-- [msgid_pb.MSGID_COMPOSE_EQUIP_REQUEST]={ },

	[msgid_pb.MSGID_EQUIP_STRENGTHEN_ALL_REQUEST]=
	{
		[1]=msgid_pb.MSGID_EQUIP_STRENGTHEN_ALL_RESPONSE
	},

	[msgid_pb.MSGID_MAP_STAR_REWARD_REQUEST]=
	{
		[1]=msgid_pb.MSGID_MAP_STAR_REWARD_RESPONSE,
		[2]=msgid_pb.MSGID_MAP_STAR_BOX_NOTIFY
	},

	[msgid_pb.MSGID_EXCHANGEGOD_REQUEST]=
	{
		[1]=msgid_pb.MSGID_EXCHANGEGOD_RESPONSE
	},

	[msgid_pb.MSGID_COM_USE_ITEM_REQUEST]=
	{
		[1]=msgid_pb.MSGID_COM_USE_ITEM_RESPONSE
	},

	--社交获取资料请求
	-- [msgid_pb.MSGID_RELATION_GET_ROLEINFO_REQUEST]=
	-- {
	-- 	[1]=msgid_pb.MSGID_RELATION_GET_ROLEINFO_RESPONSE
	-- }

	--获取离线消息请求
	-- [msgid_pb.MSGID_RELATION_GET_OFFLINE_MSG_REQUEST]=
	-- {
	-- 	[1]=msgid_pb.MSGID_RELATION_GET_OFFLINE_MSG_RESPONSE
	-- }

	[msgid_pb.MSGID_TURNTABLESTART_REQUEST]=
	{
		[1]=msgid_pb.MSGID_TURNTABLESTART_RESPONSE
	},

	[msgid_pb.MSGID_SIGNIN_REFRESH_REQUEST]=
	{
		[1]=msgid_pb.MSGID_SIGNIN_REFRESH_RESPONSE
	},
}

-------------下方逻辑不要更改--------------------
ErrorMsg = class("ErrorMsg")
ErrorMsg.__index = ErrorMsg

function ErrorMsg:ctor()

	self.tbMsg = {}

	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_RECONNECT_RESUME_RESPONSE,handler(self,self.RespondErrorMsg))
end

function ErrorMsg:ClearErrorMsg()
	self.tbMsg = {}
end

--监控一条消息
--针对389消息 处理。客户端缓存一次buffer 
function ErrorMsg:ListenMsg(MsgID, tbMsg)
	self.tbMsg = {}
	self.tbMsg[MsgID] =  {}

	-- 保存消息队列
	self.tbMsg[MsgID].ListMsg = {}

	--保证断线后发送的消息 在重连后可以正常
	if tbMsg then
		self.tbMsg[MsgID].msg = { }
		self.tbMsg[MsgID].msg.msgID = MsgID
		self.tbMsg[MsgID].msg.buffer = tbMsg
	end
	
end

--在收到服务器响应后的处理
function ErrorMsg:RelieveMsg(MsgID)

	-- if self.tbMsg[MsgID] ~= nil then
	-- 	self.tbMsg[MsgID] = nil
	-- end
end


function ErrorMsg:RelieveListenMsg(mainKey, subID)
	if not mainKey or not subID then return end

	if not self.tbMsg[mainKey] then
		cclog("发送消息的时候 才会监控消息 没有ListenMsg 则对应的 table 为 nil")
	 return 
	end

	-- cclog("========ErrorMsg:RelieveListenMsg=========beg mainkey = "..mainKey.." subID ="..subID)
	local binsert = true
	for k, v in ipairs(self.tbMsg[mainKey].ListMsg)do
		if v == subID then
			binsert = false
			break
		end
	end

	if binsert then
		table.insert(self.tbMsg[mainKey].ListMsg, subID)
	end

	-- echoj("ErrorMsg:RelieveListenMsg ===enter====", self.tbMsg[mainKey])

	self:CheckListenMsg(mainKey)

	-- echoj("ErrorMsg:RelieveListenMsg ===onexit====", self.tbMsg[mainKey])

	-- cclog("========ErrorMsg:RelieveListenMsg=========end")
end

--维护监控msgid
--当table中有满的时候 就清空当前的
function ErrorMsg:CheckListenMsg(key)
	local tbtemp = tbListen[key]
	if not tbtemp then
		self.tbMsg[key] = nil
		table.remove(self.tbMsg, key)
	 	return
	end

	-- echoj("===ErrorMsg:CheckListenMsg===1= ",tbtemp)
	-- echoj("===ErrorMsg:CheckListenMsg===2= ",self.tbMsg[key])

	local bret = false

	for k, v in ipairs(tbtemp)do
		bret = false
		for m, n in ipairs(self.tbMsg[key].ListMsg)do
			if v == n then
				-- cclog(" v= "..v.." n= "..n)
				bret = true
				break
			end
		end

		if not bret then
			break
		end
	end

	if bret then
		-- cclog("===ErrorMsg:CheckListenMsg==clear== "..key)
		self.tbMsg[key] = nil
		table.remove(self.tbMsg, key)
	end
end

--通知服务器 
function ErrorMsg:SendErrorMsg()
	if not self.tbMsg then return end

	for k, v in pairs(self.tbMsg)do
		if v ~= nil then

			if v.msg then
				cclog("＝＝＝＝＝＝＝＝＝＝＝＝＝ErrorMsg:sendMsgRepace msgid ="..v.msg.msgID)
				g_MsgMgr:sendMsg(v.msg.msgID, v.msg.buffer)
			else

				cclog("＝＝＝＝＝＝＝＝＝＝＝＝＝ErrorMsg:SendErrorMsg msgid ="..k)
				local msg =  zone_pb.ReconnectResumeRequest()
				msg.msgid = k
				for m,n in ipairs(v.ListMsg)do
					table.insert(msg.last_resp_list, n)
				end

				g_MsgMgr:sendMsg(msgid_pb.MSGID_RECONNECT_RESUME_REQUEST, msg)
			end
		end
	end
end

--收到断线重连响应
function ErrorMsg:RespondErrorMsg(tbMsg)
	local msgDetail = zone_pb.ReconnectResumeResponse()
	msgDetail:ParseFromString(tbMsg.buffer)

	for k, v in ipairs(msgDetail.resp_list)do

		 local rootMsg = xxz_msg_pb.xxz_Msg()
         rootMsg:ParseFromString(v.resp_byte)

         local nResult = rootMsg.result

         	if(nResult > 0)then
				g_MsgNetWorkWarning:closeNetWorkWarning()

				--异常情况下清空所有监控的消息
				self:ClearErrorMsg()

				local szText = nil

				if nResult < 1000000 then
					szText = g_DataMgr:getMsgContentCsv(nResult)
				end
			   
			    if(szText)then
				    local curScene = CCDirector:sharedDirector():getRunningScene()
					
				    if szText.showtype == 1 then --消息显示类型: 0:自动消失, win32 1. 需点击才消失
					    if nResult == g_DataMgr:getMsgContentCsvID("EQEC_HasBeenKickOff")  then
		
					    else
					    	g_ClientMsgTips:showMsgConfirm(szText.Description_ZH, nil)
					    end
					    
				    else
						g_ShowServerSysTips({text = szText.Description_ZH,layout = curScene,y = 232,x = 620})
				    end
				    -- cclog(nMsgID.." ******RecvMsg error ******** %d %s", nResult, tostring(szText.Description_ZH))
			    else
				    -- cclog(nMsgID.." ******RecvMsg error ********, %d", nResult)

				    if nResult >= 1000000 then
			    		-- cclog("=========客户端 服务器 判断不一致=========="..rootMsg.client_debug_info)

			    		local curScene = CCDirector:sharedDirector():getRunningScene()
						
						g_ShowServerSysTips({text = rootMsg.client_debug_info,layout = curScene,y = 232,x = 620})
				    end
			    	
			    end
			else
			    local revcFunc =  g_MsgMgr:getRevcMsgCallBack(rootMsg.msgid)
			     if revcFunc then
			     	cclog("短线重连后 收到重连响应 "..rootMsg.msgid)
			     	revcFunc(rootMsg)
			     end
			end

	end
end

g_ErrorMsg = ErrorMsg.new()