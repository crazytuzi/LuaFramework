local commConst = require("src/config/CommDef")

local readCfg = function()
	if not G_CHAT_INFO.chatSetting then
		G_CHAT_INFO.chatSetting = getLocalRecordByKey(2,"chat_setting","11111")
		cclog("last chat setting:"..G_CHAT_INFO.chatSetting)
		if string.len(G_CHAT_INFO.chatSetting) ~= 5 then
			G_CHAT_INFO.chatSetting = "11111"
		end
	end
end


local channelIdServer2Client = function(serverId)
	cclog("sourid"..serverId)
	if serverId == commConst.Channel_ID_Privacy then
		return 5
	elseif serverId == commConst.Channel_ID_Team then
		return 4
	elseif serverId == commConst.Channel_ID_Faction then
		return 3
	elseif serverId == commConst.Channel_ID_World then
		return 2
	elseif serverId == commConst.Channel_ID_Bugle then
		return 6--小喇叭
	elseif serverId == commConst.Channel_ID_System then
		return 7
	end
end

local function isInBlack(name)
	if G_BLACK_INFO then
		for i,v in ipairs(G_BLACK_INFO) do
			if v.name and v.name == name then
				return true
			end
		end
	end
end

local on_recv_chat_sc_private_info = function(luabuffer)
    local t = g_msgHandlerInst:convertBufferToTable("PrivateOtherInfo", luabuffer)
    local roleName_anotherOne = t.roleSID
    local json = require("json")
	local path = getDownloadDir() .. "privateChatTargetList_" .. tostring(userInfo.currRoleStaticId) .. ".txt"
	local file = io.open(path, "r")
    if file == nil then
		file = io.open(path, "w")
        file:write(json.encode({}))
		io.close(file)
		file = io.open(path, "r")
    end
    local fileContent = file:read("*a")
    io.close(file)
	local table_private_chat_target_list = json.decode(fileContent)
    local bool_exists_in_table = false
    for k, v in ipairs(table_private_chat_target_list) do
        if v.roleSID == roleName_anotherOne then
            bool_exists_in_table = true
            break
        end
    end
    if not bool_exists_in_table then
        table.insert(table_private_chat_target_list, 1, t)
        if table.size(table_private_chat_target_list) > 20 then
            table.remove(table_private_chat_target_list, table.size(table_private_chat_target_list))
        end
    end
    file = io.open(path, "w")
    file:write(json.encode(table_private_chat_target_list))
	io.close(file)
    if G_MAINSCENE and G_MAINSCENE.chatLayer and G_MAINSCENE.chatLayer:getChildByTag(commConst.TAG_CHAT_PRIVATECHATLISTVIEW) and not bool_exists_in_table then
        G_MAINSCENE.chatLayer:removeChildByTag(commConst.TAG_CHAT_PRIVATECHATLISTVIEW)
        local privateChatListView = require("src/layers/chat/privateChatListView").new(G_MAINSCENE.chatLayer)
        privateChatListView:tableCellTouched(
            privateChatListView:getTableView()
            , privateChatListView:getTableView():cellAtIndex(0)
        )
        privateChatListView:setPosition(cc.p(136, 105))
        privateChatListView:setTag(commConst.TAG_CHAT_PRIVATECHATLISTVIEW)
        G_MAINSCENE.chatLayer:addChild(privateChatListView)
    end
end

local onRecvChatMsg = function(luabuffer)
	--cclog("onRecvChatMsg")
	local t = g_msgHandlerInst:convertBufferToTable("ReceiveMsgProtocol", luabuffer)
	local currRecord = {}
	--currRecord.channelId = channelIdServer2Client(luabuffer:popChar())
	currRecord.channelId = t.channel
	currRecord.text = t.message
	currRecord.usrId = t.roleSID
	currRecord.usrName = t.roleName
    currRecord.fileid = t.fileid
    currRecord.timeLen = t.voicelen
   -- if Device_target == cc.PLATFORM_OS_WINDOWS then
   --     currRecord.fileid = "fileid"
   --     currRecord.text = ""
   --     currRecord.timeLen = 10
   -- end

	--dump(currRecord)
	--dump(Channel_ID_Bugle)

	--小喇叭放到世界频道
	local isTrumpet = false
	if currRecord.channelId == commConst.Channel_ID_Bugle then
		currRecord.channelId = commConst.Channel_ID_World
		isTrumpet = true
	end

	--dump(currRecord)

	if isInBlack(currRecord.usrName) then
		--log("black !!!!!!!!!!!!!! name = "..currRecord.usrName)
		return
	end

	--dump(currRecord)
	--G_CHAT_INFO.uploadNum = 999
	-- if currRecord.usrId == userInfo.currRoleStaticId and G_CHAT_INFO.uploadNum and G_CHAT_INFO.uploadNum > 0 then
	-- 	local xhr = cc.XMLHttpRequest:new()
 --    	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	--     xhr:open("POST", require("netconfig").login_url)--"http://gameapi.szkuniu.com/api.php")
	    
	--     local function onReadyStateChange()
	--         dump(xhr.response)
	--     end
	--     xhr:registerScriptHandler(onReadyStateChange)

	--     local game_str = g_Channel_tab.game or "longwen"
 --    	local channel = g_Channel_tab.version_channel or g_Channel_tab.channel

 --    	local strToSend = "a=accept_speak&app_id=1001".."&channel="..channel.."&content="..currRecord.text.."&game="..game_str..
 --    					  "&m=user&open_id="..tostring(userInfo.userName or 0)..
 --    					  "&server_id="..userInfo.serverId.."&server_name="..userInfo.serverName..
 --    					  "&uid="..userInfo.currRoleStaticId.."&username="..currRecord.usrName

 --    	local strToSendEx = getMD5(strToSend.."&app_secret=3d9893d2960c4bca54706f1c0c1817b0")
 --    	strToSend = strToSend.."&sign="..strToSendEx
 --    	dump(strToSend)
	--     xhr:send(strToSend)
	--     G_CHAT_INFO.uploadNum = G_CHAT_INFO.uploadNum-1
	-- end
	--dump(currRecord.usrName)
	if currRecord.usrName == nil then
		currRecord.usrName = ""
	end

	local isHide = t.showname
	if isHide then
		currRecord.usrName = ""
	end
	currRecord.vipLvl = t.vip
	
	-- currRecord.linkNum = luabuffer:popChar()                     
	-- currRecord.linkInfo={}

	-- for i=1,currRecord.linkNum do
	-- 	currRecord.linkInfo[i]={}
	-- 	currRecord.linkInfo[i].anchorType = luabuffer:popChar()
	-- 	currRecord.linkInfo[i].anchorItemID = luabuffer:popInt()
	-- 	currRecord.linkInfo[i].anchorStr = luabuffer:popString()
	-- end
	-- currRecord.upNum = luabuffer:popInt()
	-- currRecord.downNum = luabuffer:popInt()

	-- local serverId = luabuffer:popInt()
	-- if G_ROLE_MAIN and MRoleStruct:getAttr(ROLE_LEVEL) < 50 and currRecord.channelId == 6 and serverId ~= userInfo.serverId then
	-- 	return
	-- end
	currRecord.factionType = t.title
	currRecord.targetName = t.targetName
	--喊人扩展
	local calltype = t.callType	--喊人类型
	--local otherParamNum = luabuffer:popInt()	--附加参数个数
	local callData = {}
	for i,v in ipairs(t.callParams) do
		callData[ i ] = v 	--附加参数
	end
	if calltype ~= 0 then   --类型不为0时需要添加跳转
		if currRecord.channelId == commConst.Channel_ID_Team and G_TEAM_INFO.has_team == true then
			return
		end
		currRecord.calltype = calltype
		currRecord.callData = callData
	end

	if currRecord.fileid ~= nil and string.len(currRecord.fileid) > 0 then
		currRecord.type = 3 
		--currRecord.text = string.sub(currRecord.text,3,#currRecord.text)
		--currRecord.text = string.sub(currRecord.text,1,#currRecord.text-2)
		--dump(currRecord.text)
		--currRecord.channelId = 6        
	else
		currRecord.type = 1
	end

	--if currRecord.channelId == 7 then--小喇叭永远1条
	--	G_CHAT_INFO[currRecord.channelId]=currRecord
	--else
		if not G_CHAT_INFO[currRecord.channelId] then
			G_CHAT_INFO[currRecord.channelId]={}
		end
		if #G_CHAT_INFO[currRecord.channelId]>= 30 then
			table.remove(G_CHAT_INFO[currRecord.channelId],1)
		end
		G_CHAT_INFO[currRecord.channelId][#G_CHAT_INFO[currRecord.channelId]+1] = currRecord
		readCfg()
		--local splitSymbolIdx = currRecord.channelId-1
		-- if currRecord.channelId == 7 then
		-- 	splitSymbolIdx = splitSymbolIdx-1
		-- end
		--if string.sub(G_CHAT_INFO.chatSetting,splitSymbolIdx,splitSymbolIdx) == "1" then
			if not G_CHAT_INFO[11] then
				G_CHAT_INFO[11]={}
			end

			if not (currRecord.channelId == commConst.Channel_ID_Team and currRecord.calltype and currRecord.calltype > 0) then
				if #G_CHAT_INFO[11] >= 30 then
					table.remove(G_CHAT_INFO[11],1)
				end
				G_CHAT_INFO[11][#G_CHAT_INFO[11]+1] = currRecord
			end
		--end
	--end

	if G_MAINSCENE then
        if currRecord.channelId == commConst.Channel_ID_Privacy then
            if G_CHAT_INFO.unReadPrivateRecord == nil then G_CHAT_INFO.unReadPrivateRecord = 0 end
            G_CHAT_INFO.unReadPrivateRecord = G_CHAT_INFO.unReadPrivateRecord + 1
            G_MAINSCENE:updateChatStartBtn()
        end

		local chatLayer =getRunScene():getChildByTag(305)
		if chatLayer then 
			--dump(currRecord)
			chatLayer:updateDisplayData(currRecord.channelId, isTrumpet)
            chatLayer:updatePrivateBtn()
		end  
        
        G_MAINSCENE.ChatAutoPlayLayer:addPlayMsg(currRecord)   
	end

	--cclog("currRecord.channelId"..currRecord.channelId.."~"..commConst.Channel_ID_System)
	if G_CHAT_INFO.chatPanel then
		if isTrumpet then
			if G_CHAT_INFO.chatPanel.addTopShowData then
				G_CHAT_INFO.chatPanel:addTopShowData({name = currRecord.usrName, text = currRecord.text})
			end
		end

		if currRecord.channelId == 4 then
			if G_CHAT_INFO.chatPanel.addTrumpetChatMsg then
				G_CHAT_INFO.chatPanel:addTrumpetChatMsg(currRecord.usrName, currRecord.text, currRecord.usrId, currRecord.vipLvl, currRecord.type==3, currRecord.channelId)
			end
		else
			if G_CHAT_INFO.chatPanel.addChatMsg then
				G_CHAT_INFO.chatPanel:addChatMsg(currRecord.usrName, currRecord.text, currRecord.usrId, (currRecord.channelId==1) and (currRecord.usrName~=G_ROLE_MAIN:getTheName()), currRecord.vipLvl,currRecord.type==3, currRecord.channelId)
			end
		end
	end
end

local readToFile = function()
	local temp = 0
	local fightKeep = {}
	local setfile = getDownloadDir().."chat_sys_"..tostring(userInfo.currRoleStaticId)..".cfg"
	local file = io.open(setfile,"r")
	if file then
		local line = file:read()
		while line do
			temp = temp + 1
			table.insert(fightKeep,line)
			line = file:read()
		end
		file:close()
	end

	return fightKeep
end

local onRecvHistoryChat = function(luabuffer)
	cclog("onRecvHistoryChat")
	local t = g_msgHandlerInst:convertBufferToTable("SendRecentMsgProtocol", luabuffer)
	local channelId = commConst.Channel_ID_World --channelIdServer2Client(commConst.Channel_ID_World)
	G_CHAT_INFO[channelId]={}
	G_CHAT_INFO[11]={}
	local recordCount = t.recentMsgSize
	for i,v in ipairs(t.recentMsg) do
		local currRecord={}
		currRecord.channelId = channelId
		currRecord.usrId = v.roleSID
		currRecord.usrName = v.roleName
		dump(currRecord.usrName)
		if currRecord.usrName == nil then
			currRecord.usrName = ""
		end
		currRecord.text = v.message
		currRecord.vipLvl = v.vip
		currRecord.factionType = v.title
		if string.sub(currRecord.text,1,2) == "*^" and string.sub(currRecord.text,#currRecord.text-1,#currRecord.text)=="^*" then
			currRecord.type = 3 
			currRecord.text = string.sub(currRecord.text,3,#currRecord.text)
			currRecord.text = string.sub(currRecord.text,1,#currRecord.text-2)
		else
			currRecord.type = 1
		end

		G_CHAT_INFO[currRecord.channelId][i] = currRecord
		readCfg()
		if string.sub(G_CHAT_INFO.chatSetting,1,1) == "1" then
			G_CHAT_INFO[11][i] = currRecord
		end
	end

	-- local saveData = readToFile()
	-- for i = 1 , #saveData do
	-- 	local item = stringsplit( saveData[i] , ",")
	-- 	local tempTable = { channelId = tonumber( item[1] ) , text = item[2] }

	-- 	if not G_CHAT_INFO[11] then G_CHAT_INFO[11]={} end
	-- 	if #G_CHAT_INFO[11] >= 30 then table.remove(G_CHAT_INFO[11],1) end
	-- 	G_CHAT_INFO[11][#G_CHAT_INFO[11]+1] = tempTable
	-- end

	if G_MAINSCENE then
		local chatLayer = getRunScene():getChildByTag(305)
		if chatLayer and chatLayer.updateDisplayData then 
			chatLayer:updateDisplayData(channelId)
		end
	end
end

local onRecvLinkData = function(luabuffer)
	local t = g_msgHandlerInst:convertBufferToTable("ClickAnchorRetProtocol", luabuffer) 
	--dump(t)
	local itemInfo = protobuf.decode("PBItem", t.itemInfo)--g_msgHandlerInst:convertBufferToTable("PBItem", t.itemInfo)
	--dump(itemInfo)
	local pos = itemInfo.slot
	--local instGrid = require("src/layers/bag/PackManager"):parseGird(luabuffer, pos)
	--local t = protobuf.decode("PBItem", itemInfo)
	local grid = MPackManager:convertPBItemToGrid(itemInfo)
	if G_MAINSCENE then
		--local chatLayer = getRunScene():getChildByTag(305)
		--if chatLayer then 
			--dump(instGrid)
			local Mtips = require "src/layers/bag/tips"
			Mtips.new(
			{ 
				--protoId = tonumber(protoId),
				grid = grid,
				isOther = true,
				pos = cc.p(0, 0),
				--actions = actions,
				zOrder = 499,
			})
		--end
	end
end

local onRecvUpDownData = function(luabuffer)
	local id = luabuffer:popInt()
	local upNum = luabuffer:popInt()
	local downNum = luabuffer:popInt()
	if G_CHAT_INFO[11] then
		dump(#G_CHAT_INFO[11])
		for i=1,#G_CHAT_INFO[11] do
			local item = G_CHAT_INFO[11][i]
			if item.usrId == id then
				item.upNum = upNum
				item.downNum = downNum
			end
		end
	end
	if G_MAINSCENE then
		local chatLayer = getRunScene():getChildByTag(305)
		if chatLayer and chatLayer.updateUpDownNum then 
			chatLayer:updateUpDownNum(id,upNum,downNum)
		end
	end
end

local onStartUpload = function(luabuffer)
	local id = luabuffer:popInt()
	G_CHAT_INFO.uploadNum = luabuffer:popInt()
end

--系统消息
local showSysMsg = function( servData )
	local t = g_msgHandlerInst:convertBufferToTable("SystemMsgProtocol", servData)
	if not t then
		print("SystemMsgProtocol error")
		return
	end
	local msg_type = t.type   		--1表示后端直接给前端Msg，2表示消息内容在客户端提示表
	local text = t.message   		--Msg：pushString类型，如果type为1，直接显示此msg内容，如果type为2，Msg可能为空
	local time = t.timeTick				--服务器时间 从1970时1月1日至今的秒数
	local sthID = t.eventID   		--事件类型
	local midID = t.tipsID   		--客户端提示表中消息的id
	local paramCount = t.paramNUm		--表明参数个数
	local temp = {}
	for i,v in ipairs(t.params) do
		temp[i] = v
	end
	local currRecord = { channelId = 6 }
	currRecord.time = time
	-- AudioEnginer.playEffect("sounds/uiMusic/ui_message.mp3",false)
	--log("sthID = "..tostring(sthID))
	--log("midID = "..tostring(midID))
	if msg_type == 1 then
		currRecord.text = text
	else
		local msg_item = getConfigItemByKeys("clientmsg",{"sth","mid"},{sthID,midID} )
		if msg_item then
			currRecord.text = string.format( msg_item.msg ,  temp[1] or "" , temp[2] or "" ,temp[3] or "" ,temp[4] or "" ,temp[5] or "" ,temp[6] or "" ,temp[7] or "" ,temp[8] or "" ,temp[9] or "" ,temp[10] or "" )
		else
			currRecord.text = ""
		end
	end
	--dump(currRecord)
	if currRecord.text and currRecord.text~="" then
		if not G_CHAT_INFO[6] then G_CHAT_INFO[6]={} end
		if #G_CHAT_INFO[6] >= 30 then table.remove(G_CHAT_INFO[6],1) end
		G_CHAT_INFO[6][#G_CHAT_INFO[6]+1] = currRecord
		if G_MAINSCENE then
			local chatLayer =getRunScene():getChildByTag(305)
			if chatLayer then 
				chatLayer:updateDisplayData(currRecord.channelId)
			end
		end

		local tempStr = ""
		tempStr = tempStr .. ( currRecord.channelId or "" ) .. "," .. ( currRecord.text or "" )
	end
end


--弹窗
local popItemWindow = function( sevData )	

	local function msgHandler( _item ) 
		local sub_node = MessageBoxYesNo(  _item.title , "" )
		_item.title = game.getStrByKey("tip")

		if sub_node then
			local width , height  = 400 , 145
			function createLayout()
				local tempNode = cc.Node:create()

				local text = require("src/RichText").new( tempNode , cc.p( 0 , 0 ) , cc.size( width - 40 , 0 ) , cc.p( 0 , 1 ) , 22 , 18 , MColor.white )
				text:addText( _item.content , MColor.white , false )
				text:setAutoWidth()
				text:format()

				tempNode:setContentSize( cc.size( width , math.abs( text:getContentSize().height )  ) )
				setNodeAttr( text , cc.p( 40 , 0 ) , cc.p( 0 , 0  ) )

				return tempNode
			end

			local scrollView1 = cc.ScrollView:create()	  
			scrollView1:setViewSize(cc.size( width + 40  , height  ) )--设置可视区域比文字区域大，防止字库导致字体大小不一致的显示问题
			scrollView1:setPosition( cc.p( -14 , 92  ) )
			scrollView1:setScale(1.0)
			scrollView1:ignoreAnchorPointForPosition(true)
			local layer = createLayout()
			scrollView1:setContainer( layer )
			scrollView1:updateInset()
			scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
			scrollView1:setClippingToBounds(true)
			scrollView1:setBounceable(true)
			scrollView1:setDelegate()
			sub_node:addChild(scrollView1)
			local layerSize = layer:getContentSize()
			scrollView1:setContentOffset( cc.p( 0 ,  height - layerSize.height  ) )
			
			if layerSize.height < height - 10  then
				scrollView1:setTouchEnabled( false )
			else
				scrollView1:setTouchEnabled( true )
			end  
		end
	end

	local t = g_msgHandlerInst:convertBufferToTable("PopOneMsgProtocol", sevData)
	msgHandler( { content = t.msg } )
end
local popWindow = function( sevData )	
	local t = g_msgHandlerInst:convertBufferToTable("PopAllWindowProtocol", sevData)
	local curTime =  t.timeTick 	--  当前服务器时间
	local num =  #t.windowInfo 		--  弹窗条数

	local function msgHandler( _item ) 
		local sub_node = nil
		if _item.title == "" then _item.title = game.getStrByKey("tip") end
		
		if _item.popType == 1 or _item.popType == 4 then
			sub_node = MessageBoxYesNo(  _item.title , "" )
		elseif _item.popType == 2 then
			local dayStr = tostring( os.date( "%x" , curTime ) )
			local memoryTime = tostring( getLocalRecordByKey( 2 , "popup_window2" .. _item.key .. tostring( userInfo.currRoleStaticId or 0 )  ) )
			if dayStr ~= memoryTime then
				setLocalRecordByKey( 2 , "popup_window2" .. _item.key .. ( userInfo.currRoleStaticId or 0 )  , dayStr )
				sub_node = MessageBoxYesNo( _item.title , "" )
			end
		elseif _item.popType == 3 then
			local memoryTime = tonumber( getLocalRecordByKey( 2 , "popup_window3" .. _item.key .. tostring( userInfo.currRoleStaticId or 0 ) )  )
			memoryTime = memoryTime or 0
			if _item.startTime > memoryTime then
				setLocalRecordByKey( 2 , "popup_window3" .. _item.key .. ( userInfo.currRoleStaticId or 0 )  , tostring( _item.startTime ) )
				sub_node = MessageBoxYesNo( _item.title , "" )
			end
		end
		if sub_node then
			local width , height  = 400 , 145
			function createLayout()
				local tempNode = cc.Node:create()

				local text = require("src/RichText").new( tempNode , cc.p( 0 , 0 ) , cc.size( width - 40 , 0 ) , cc.p( 0 , 1 ) , 22 , 18 , MColor.white )
				text:addText( _item.content , MColor.white , false )
				if _item.link ~= "" and _item.btContent ~= "" then text:addUrlItem( "\n" .. _item.btContent .. "|" .. _item.link ,  MColor.green ) end
				text:setAutoWidth()
				text:format()

				tempNode:setContentSize( cc.size( width , math.abs( text:getContentSize().height )  ) )
				setNodeAttr( text , cc.p( 40 , 0 ) , cc.p( 0 , 0  ) )

				return tempNode
			end

			local scrollView1 = cc.ScrollView:create()	  
			scrollView1:setViewSize(cc.size( width + 40  , height  ) )--设置可视区域比文字区域大，防止字库导致字体大小不一致的显示问题
			scrollView1:setPosition( cc.p( -14 , 92  ) )
			scrollView1:setScale(1.0)
			scrollView1:ignoreAnchorPointForPosition(true)
			local layer = createLayout()
			scrollView1:setContainer( layer )
			scrollView1:updateInset()
			scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
			scrollView1:setClippingToBounds(true)
			scrollView1:setBounceable(true)
			scrollView1:setDelegate()
			sub_node:addChild(scrollView1)
			local layerSize = layer:getContentSize()
			scrollView1:setContentOffset( cc.p( 0 ,  height - layerSize.height  ) )
			
			if layerSize.height < height - 10  then
				scrollView1:setTouchEnabled( false )
			else
				scrollView1:setTouchEnabled( true )
			end  
		end
	end

	for k,v in pairs(t.windowInfo) do
		local item = {}
		item.key = v.id			
		item.popType = v.windowType 			--  弹窗类型(1为每次登录后弹、2为每天在第一次登录后弹一次、3为整个有效时间周期里只弹一次、4为自定义频率）1 4 后台控制 ，2 3 前台标记
		item.startTime = v.startTime 			--  有效期开始时间
		item.title = v.title 			--  标题
		item.content = v.content 			--  内容
		item.link = v.link 			--  超链接
		item.btContent = v.btContent 		--  按钮内容
		msgHandler( item )
	end

	-- local cfg = {
	-- 				{ popType = 1 , title = "弹窗类型1" , content = "弹窗类型\n弹窗类型\n弹窗类型\n弹窗类型(1为每次登录后弹、2为每天在第一次登录后弹一次、3为整个有效时间周期里只弹一次、4为自定义频率）1 4 后台控制 ，2 3 前台标记",
	-- 					link = "baidu" ,btContent = "链接内容"
	-- 				 }
	-- 			}
	-- for i = 1 , #cfg do
	-- 	msgHandler( cfg[i] )
	-- end
end

local onDeleteChat = function(buff)
	local t = g_msgHandlerInst:convertBufferToTable("ClearChatMsgProtocol", buff)
	local roleSID = t.roleSID
	local roleName = t.roleName
	dump(roleSID)
	dump(roleName)
	if G_MAINSCENE then
		local chatLayer = getRunScene():getChildByTag(305)
		if chatLayer and chatLayer.deleteChatById then 
			--log("1111111111111111111111111111111111111")
			chatLayer:deleteChatById(roleSID)
		end
	end

	if G_CHAT_INFO.chatPanel then
		G_CHAT_INFO.chatPanel:deleteDataById(roleSID)
	end
end

g_msgHandlerInst:registerMsgHandler(CHAT_SC_RECEIVEMSG,onRecvChatMsg)
g_msgHandlerInst:registerMsgHandler(CHAT_SC_SENDRECMSG,onRecvHistoryChat)
g_msgHandlerInst:registerMsgHandler(CHAT_SC_CLICKANCHORRET,onRecvLinkData)
-- g_msgHandlerInst:registerMsgHandler(CHAT_SC_ASSESSWORD,onRecvUpDownData)
g_msgHandlerInst:registerMsgHandler(CHAT_SC_CHECKWORD,onStartUpload)

g_msgHandlerInst:registerMsgHandler(CHAT_SC_SYSTEM_MSG, showSysMsg)       --系统消息
g_msgHandlerInst:registerMsgHandler(CHAT_SC_POP_ALL_WINDOW , popWindow)        --弹窗
g_msgHandlerInst:registerMsgHandler(CHAT_SC_POP_ONE_SYSTEM , popItemWindow)        --弹窗通知

g_msgHandlerInst:registerMsgHandler(CHAT_SC_CLEAR_MSG , onDeleteChat)        --弹窗通知
g_msgHandlerInst:registerMsgHandler(CHAT_SC_PRIVATE_INFO, on_recv_chat_sc_private_info)        --收到私聊玩家职业等级消息