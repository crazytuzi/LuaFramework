-- 领土争夺战聊天
ltzdzChatVoApi={
	nextSendTime=0, -- 下一次能发聊天的时间
	chatList1=nil,
	chatList2=nil,
}

function ltzdzChatVoApi:clear()
	self.nextSendTime=0
	self.chatList1=nil
	self.chatList2=nil
end

-- 展示聊天
function ltzdzChatVoApi:showChatDialog(layerNum,tabIndex)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzChatDialog"
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzChatTab1"
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzChatTab2"
	local td=ltzdzChatDialog:new(layerNum)
	local tbArr={getlocal("report_to_world"),getlocal("player_message_info_whisper")}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("chat"),true,layerNum)

	sceneGame:addChild(dialog,layerNum)
	td:tabClick(tabIndex or 0)
end

function ltzdzChatVoApi:showChatList(layerNum,istouch,isuseami,callBack,titleStr,parent,chatList,ally)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzChatListSmallDialog"
	ltzdzChatListSmallDialog:showChatList(layerNum,istouch,isuseami,callBack,titleStr,parent,chatList,ally)
end

-- 聊天接口
function ltzdzChatVoApi:chatSocket(refreshFunc,pType,msg,receive,rname)
	local function chatCallback(fn,data)
		local ret,sData=base:checkServerData2(data)
		if ret==true then
			if refreshFunc then
				refreshFunc()
			end
			if sData and sData.data and sData.data.chat then
				self:updateChat(sData.data.chat)
			end

			if sData and sData.ts then
				self.nextSendTime=sData.ts+30
			end
		end
	end
	local roomid=ltzdzVoApi.clancrossinfo.roomid
	local tid=ltzdzVoApi.clancrossinfo.tid
	socketHelper2:ltzdzChat(chatCallback,roomid,pType,msg,receive,rname,tid)
end

-- 构造chatVo（世界）
function ltzdzChatVoApi:getChat1()
	if self.chatList1 then
		return self.chatList1
	end
	self.chatList1={}

	require "luascript/script/game/gamemodel/ltzdz/ltzdzChatVo"

	local chatInfo=ltzdzFightApi.mapVo.chat
	if chatInfo then
		for k,v in pairs(chatInfo) do
			local chatVo=self:getChatVo(v)
			table.insert(self.chatList1,chatVo)
		end
	end
	return self.chatList1
end

-- 私聊
function ltzdzChatVoApi:getChat2()
	if self.chatList2 then
		return self.chatList2
	end
	self.chatList2={}

	require "luascript/script/game/gamemodel/ltzdz/ltzdzChatVo"

	local userInfo=ltzdzFightApi:getUserInfo()
	local chatInfo=userInfo.chat
	if chatInfo then
		for k,v in pairs(chatInfo) do
			local chatVo=self:getChatVo(v)
			table.insert(self.chatList2,chatVo)
		end
	end
	return self.chatList2
end

function ltzdzChatVoApi:getChatVo(data)
	local chatVo=ltzdzChatVo:new()

	local width=500-56
	local messageLabel=GetTTFLabelWrap(data[4],26,CCSizeMake(width, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	local lbHeight=messageLabel:getContentSize().height+5+32

	chatVo:initWithData(data,lbHeight,width)
	return chatVo
end

-- 更新聊天
function ltzdzChatVoApi:updateChat(chat)
	if not chat then
		return
	end
	local chatVo=self:getChatVo(chat)

	if chat[1]==1 then
		local chatInfo=ltzdzFightApi.mapVo.chat
		if not chatInfo then
			ltzdzFightApi.mapVo.chat={}
		end
		table.insert(ltzdzFightApi.mapVo.chat,chat)
		if self.chatList1 then
			-- local chatVo=self:getChatVo(chat)
			table.insert(self.chatList1,chatVo)
			local chatNum1=self:getMaxMore(1)
			if #self.chatList1>chatNum1 then
				for i=1,#self.chatList1-chatNum1 do
					table.remove(self.chatList1,i)
				end
			end

			eventDispatcher:dispatchEvent("ltzdz.newChat1",chatVo)

		end
	else
		local myuid=tostring(playerVoApi:getUid())
		local chatInfo=ltzdzFightApi.userInfo[myuid].chat
		if not chatInfo then
			ltzdzFightApi.userInfo[myuid].chat={}
		end
		table.insert(ltzdzFightApi.userInfo[myuid].chat,chat)
		if self.chatList2 then
			-- local chatVo=self:getChatVo(chat)
			table.insert(self.chatList2,chatVo)
			local chatNum2=self:getMaxMore(2)
			if #self.chatList2>chatNum2 then
				for i=1,#self.chatList2-chatNum2 do
					table.remove(self.chatList2,i)
				end
			end
		end
		eventDispatcher:dispatchEvent("ltzdz.newChat2",chatVo)
	end
	eventDispatcher:dispatchEvent("ltzdz.newChat",chatVo)
end

-- 聊天存储最大值
function ltzdzChatVoApi:getMaxMore(cType)
	local warCfg=ltzdzVoApi:getWarCfg()
	if cType==1 then
		return warCfg.chatNum1
	else
		return warCfg.chatNum2
	end
end

function ltzdzChatVoApi:getTypeInfo(cType)
	local color
	local icon
	if cType==1 then
		color=G_ColorWhite
		icon="chatBtnWorld.png"
	else
		color=G_ColorPurple
		icon="chatBtnFriend.png"
	end
	return color,icon
end

function ltzdzChatVoApi:getNameStr(data)
	local nameStr=""
	if data.cType==1 then
		nameStr=data.nickname
	else
		local uid=playerVoApi:getUid()
		if uid==data.senderId then
			nameStr=getlocal("chat_whisper_to",{data.receiverName})
		else
			nameStr=getlocal("chat_whisper_from",{data.nickname})
		end
	end
	return (nameStr .. ":")
end

-- 聊天列表（私聊）
-- isMap 小地图中需要显示自己
function ltzdzChatVoApi:getChatList(isMap)
	local sortUser={}
	local myuid=playerVoApi:getUid()
	local mapUserTb=G_clone(ltzdzFightApi:getMapUserList())
	local userTb=ltzdzFightApi:getUserList()
	local allay=userTb[tostring(myuid)].ally or 0

	for k,v in pairs(mapUserTb) do
		if tonumber(k)~=myuid and v.s and v.s<2 then
			local value=ltzdzFightApi:getUserInfo(k)
			if tonumber(k)==allay then
				table.insert(sortUser,1,{uid=k,value=value})
			else
				table.insert(sortUser,{uid=k,value=value})
			end
			
		end
	end
	if isMap then
		local value=ltzdzFightApi:getUserInfo(myuid)
		table.insert(sortUser,1,{uid=myuid,value=value})
	end
	return sortUser,allay
end




