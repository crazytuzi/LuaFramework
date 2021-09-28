--[[
 --
 -- add by vicky
 -- 2014.09.10
 --
 --]]

 local data_pingbi_pingbi = require("data.data_pingbi_pingbi")
 local data_config_config = require("data.data_config_config") 

 local MAX_TEXT_LEN = 40

 -- 聊天保存的最大数量 
 local MAX_CHAT_NUM = data_config_config[1].max_chat_num 

 -- 发言时间间隔 
 local kChatTime = data_config_config[1].kchattime	

 -- 更新聊天界面时间
 local kUpdateTime = data_config_config[1].kupdatetime  


 local ChatLayer = class("ChatLayer", function()
 	display.addSpriteFramesWithFile("ui/ui_window_base.plist", "ui/ui_window_base.png")
 	return require("utility.ShadeLayer").new()
 end)


 function ChatLayer:getChatList()
 	local curType = "1"
 	if self.chatType == self.FRIEND_CHAT_TYPE then	
 		curType = "5"
	end
 	RequestHelper.chat.getList({
 		type = curType, 
 		name = game.player:getPlayerName(), 
 		account = self.friendAccount,
 		callback = function(data)
 			-- dump(data)
 			if string.len(data["0"]) > 0 then
 				dump(data["0"]) 
 			else

 				game.player:setChatNewNum(0)
 				PostNotice(NoticeKey.MainMenuScene_chatNewNum) 
 				self:init(data)
 			end
 		end
 		})
 end


 function ChatLayer:reGetChatList()
 	local curType = "1"
 	if self.chatType == self.FRIEND_CHAT_TYPE then	
 		curType = "5"
	end

	--GameRequest 没有loading界面，在聊天里不应有这个界面
 	GameRequest.chat.getList({
 		type = curType, 
 		name = game.player:getPlayerName(), 
 		account = self.friendAccount,
 		callback = function(data)
 			-- dump(data)
 			if string.len(data["0"]) > 0 then 
 				dump(data["0"]) 
 			else
 				self:updateChatData(data)
 			end
 			self._updateTime = kUpdateTime 
 		end
 		})

 end 

 function ChatLayer:load()
	return GameState.load()
 end

 function ChatLayer:save(curChatData)
	GameState.save(curChatData)
 end


 function ChatLayer:writeToChatData(tableMsg) 
 	local curChatData = self:load()  
 	if curChatData == nil or type(curChatData) ~= "table" then 
 		curChatData = {} 
 	end 

 	if tableMsg ~= nil and type(tableMsg) == "table" then 
 		for i, v in ipairs(tableMsg) do 
 			table.insert(curChatData, v) 
 		end 
 		-- dump(curChatData) 

 		local needRemoveNum = #curChatData - MAX_CHAT_NUM 
 		if needRemoveNum > 0 then 
	 		for i = 1, needRemoveNum do 
	 			table.remove(curChatData, 1) 
	 		end  
	 	end 
		
		self:save(curChatData) 
	end 

	return curChatData 
 end


 function ChatLayer:clearChatData()
 	local chatData = {}
 	self:save(chatData) 
 end 


 function ChatLayer:sendMsg(msg)
 	self._time = kChatTime
 	local curRename = ""
 	local curType   = "1"

 	if self.chatType == self.FRIEND_CHAT_TYPE then	
 		curRename = self.friendAccount
 		curType   = "5"
	end

 	GameRequest.chat.sendMsg({
 		type = curType, 
 		msg = msg, 
 		recname = curRename, 
 		para1 = "", 
 		para2 = "", 
 		para3 = "", 
 		callback = function(data)
 			dump(data)
 			if data.errCode ~= nil and data.errCode > 0 then
 				show_tip_label(data_error_error[data.errCode].prompt)
 			else
 				self._lastChatMsg = msg 
 				self:sendMsgSuccess(msg)
 			end
 		end
 		})
 end
 


 function ChatLayer:ctor(data,chatType,chatIndex)
 	self._dumpList = {}
 	self.FRIEND_CHAT_TYPE = 1

 	self.chatType = chatType
 	self._lastChatMsg = "" 

 	local proxy = CCBProxy:create()
    self._rootnode = {}

    local path = "chat/chat_bg.ccbi"
    self._updateTime = kUpdateTime  

    if chatType == self.FRIEND_CHAT_TYPE then
    	path = "friend/friend_chat_bg.ccbi"
    	self.friendIndex = chatIndex
    	self._updateTime = 0  
    end



    local node = CCBuilderReaderLoad(path, proxy, self._rootnode) 
    node:setPosition(display.width / 2, display.height / 2)
    self:addChild(node)


	self:initFile()

    -- 关闭
    self._rootnode["tag_close"]:addHandleOfControlEvent(function(eventName, sender)
    	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
            self:removeFromParentAndCleanup(true)
        end, CCControlEventTouchUpInside)

	-- 发送
    self._rootnode["sendBtn"]:addHandleOfControlEvent(function(eventName, sender)
    	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
            self:checkMsg(self._editBox:getText())
        end, CCControlEventTouchUpInside)

    local chatNode = self._rootnode["chatBox_node"]
    local cntSize = chatNode:getContentSize()

    self._editBox = ui.newEditBox({
        image = "#win_base_inner_bg_black.png",
        size = CCSizeMake(cntSize.width * 0.9, cntSize.height * 0.9),
        x = cntSize.width/2, 
        y = cntSize.height/2 
    })

    self._editBox:setFont(FONTS_NAME.font_fzcy, 22)
    self._editBox:setFontColor(FONT_COLOR.WHITE)
    self._editBox:setMaxLength(MAX_TEXT_LEN)
    self._editBox:setPlaceHolder("请输入聊天内容")
    self._editBox:setPlaceholderFont(FONTS_NAME.font_fzcy, 22)
    self._editBox:setPlaceholderFontColor(FONT_COLOR.WHITE)
    self._editBox:setReturnType(1)
    self._editBox:setInputMode(0)

    chatNode:addChild(self._editBox)

    self._time = 0 
    
    self._height = 0 

    game.player:setChatNewNum(0)
	PostNotice(NoticeKey.MainMenuScene_chatNewNum) 

	self:init(data)

 end

 function ChatLayer:initFile()
    self.fileName = "chatData.json"
    if self.chatType == 1 then
		self:initFriendChat()
		self.fileName = tostring(game.player.m_uid).."_chatWith_"..tostring(self.friendAccount).."_Data.json"	
	end

	 local function eventListen(param)
	     -- dump(param)
	     local returnValue = {}
	     if param.errorCode then 
	         dump("读取存储文件失败error:" .. param.errorCode) 
	     else 
	         if param.name == "save" then 
	             dump("save:") 
	             returnValue = param.values 

	         elseif param.name == "load" then 
	             dump("load:") 
	             returnValue = param.values 
	         end 
	     end 

	     return returnValue 
	 end 

	 GameState.init(eventListen, self.fileName) 
end



function ChatLayer:initFriendChat()
	local mid_height = display.height - self._rootnode["up_node"]:getContentSize().height - self._rootnode["down_node"]:getContentSize().height
    self._rootnode["mid_node"]:setContentSize(CCSize(display.width*0.9,mid_height))
    self._rootnode["mid_bg"]:setContentSize(CCSize(display.width*0.9,mid_height*0.97))
    self._rootnode["scrollView"]:setContentSize(CCSize(display.width*0.9,mid_height*0.94))
    self._rootnode["scrollView"]:setViewSize(CCSize(display.width*0.9,mid_height*0.94))

    self:initFriendData()
    self:initFriendContent()
 

end



function ChatLayer:readFromFriendChatFile()
	local friendChatTable = {}

	return friendChatTable
end


 function ChatLayer:init(data)
 	local curData
 	if self.chatType == 1 then
 		curData = self:readFromFriendChatFile()
 	else
 		curData = data
 		-- 如果是世界聊天且玩家切服，需要把本地聊天信息删除 
 		if game.player.m_isChangedServer == true then 
 			game.player.m_isChangedServer = false 
	 		self:clearChatData() 
	 	end 
 	end

 	local msgAry = self:writeToChatData(curData["1"]) 

 	
 	for i, v in ipairs(msgAry) do 
 		dump(v)
 		local isLeft = true 
 		if v.name == game.player:getPlayerName() then
 			isLeft = false 
 		end

 		self:createItem({
 			gender = v.sex, 
 			isLeft = isLeft, 
 			name = v.name, 
 			msg = v.msg,
 			guildName = v.sendRoleFaction
 			}) 		

 		if i == #msgAry then 
 			table.insert(self._dumpList, v) 
 		end
 	end 



 	self:resetScrollView() 
 	self:initTimeSchedule() 
 end




 -- 加载新消息 
 function ChatLayer:updateChatData(data) 
 	local msgAry = self:writeToChatData(data["1"]) 
 	local last 
 	local count = #self._dumpList 
 	if count <= 0 then
 		self._dumpList = msgAry 
 	else 
 		last = self._dumpList[count] 
	 	for i, v in ipairs(msgAry) do 
	 		if last.t < v.t then 
	 			table.insert(self._dumpList, v) 
	 		end
	 	end
	end 

	for i, v in ipairs(self._dumpList) do 
		if v.name ~= game.player:getPlayerName() and (last == nil or v.t > last.t) then 
			local isLeft = true 
	 		if v.name == game.player:getPlayerName() then
	 			isLeft = false 
	 		end

	 		local chatItem = require("game.Chat.ChatItem").new({
		 		gender = v.sex, 
	 			isLeft = isLeft, 
	 			name = v.name, 
	 			msg = v.msg,
	 			guildName = v.sendRoleFaction
	 		})

	 		chatItem:setVisible(false)
	 		self:addChild(chatItem)

	 		chatItem:runAction(transition.sequence({
	 			CCDelayTime:create(i * 0.5), 
	 			CCCallFuncN:create(function(node) 
	 					self:removeChild(node, false)
	 					node:setVisible(true)
	 					self:addToScrollView(node, node:getIsLeft()) 
		 			end) , 
	 			CCCallFunc:create(function()
	 					self:resetScrollView() 
	 				end)
	 			}))
		end 
	end

	count = #self._dumpList 
	if count > 0 then
		last = self._dumpList[count]
		self._dumpList = {}
		table.insert(self._dumpList, last)
	end
 end 


 function ChatLayer:createItem(param)
 	dump(param)
 	local chatItem = require("game.Chat.ChatItem").new({
	 		gender = param.gender, 
	 		isLeft = param.isLeft, 
	 		name = param.name, 
	 		msg = param.msg,
	 		guildName = param.guildName
	 		})

 	self:addToScrollView(chatItem, param.isLeft) 
 end


 function ChatLayer:addToScrollView(chatItem, isLeft)
 	if chatItem == nil then
 		return
 	end 

 	local listViewSize = self._rootnode["listView"]:getContentSize()
 	local posX = 15
 	if not isLeft then 
 		posX = listViewSize.width - 15
 	end

 	local itemH = chatItem:getContentSize().height 
	if itemH < 100 then 
		self._height = self._height + 10 
	end

	local itemH = chatItem:getContentSize().height 

	chatItem:setPosition(posX, -self._height) 
	self._rootnode["contentView"]:addChild(chatItem) 

	self._height = self._height + itemH 
 end


 -- 重置列表位置
 function ChatLayer:resetScrollView() 
 	local listViewSize = self._rootnode["listView"]:getContentSize()
 	local contentViewSize = self._rootnode["contentView"]:getContentSize()

 	local sz = CCSizeMake(contentViewSize.width, contentViewSize.height + self._height)

    self._rootnode["descView"]:setContentSize(sz)
    self._rootnode["contentView"]:setPosition(ccp(sz.width / 2, sz.height))

    local scrollView = self._rootnode["scrollView"]
    scrollView:updateInset()

 --    dump("=======================")  
	-- dump(self._height .. ", " .. listViewSize.height) 

    if self._height < listViewSize.height then  
	    scrollView:setContentOffset(CCPointMake(0, -sz.height + scrollView:getViewSize().height), false) 
	else
		self._rootnode["scrollView"]:getContainer():setPosition(0, 0)
	end

 end 


 -- 发送消息成功后
 function ChatLayer:sendMsgSuccess(msg)
 	-- 加进scrollView 
 	self:createItem({
 			gender = game.player:getGender(), 
 			isLeft = false, 
 			name = game.player:getPlayerName(), 
 			msg = msg 
 			}) 

 	self:resetScrollView() 

 	self._editBox:setText("")
 end


 function ChatLayer:initTimeSchedule()
 	self:reGetChatList()
	self:schedule(function()
			if self._time > 0 then 
				self._time = self._time - 1
			end

			if self._updateTime > 0 then
		 		self._updateTime = self._updateTime - 1
		 	end

		 	if self._updateTime <= 0 then
		 		self:reGetChatList()
		 	end 
		end, 1)
 end


  -- 检测是否含有敏感词汇
 function ChatLayer:checkSensitiveWord(wordStr)

	-- 不过滤空格
	local endWordStr = wordStr 
	for i, v in ipairs(data_pingbi_pingbi) do 
		local contian = string.find(endWordStr, v.words) 
		if contian ~= nil then 
			bHas = true 
			local tmpStr = ""
			for j = 1, string.utf8len(v.words) do  
				tmpStr = tmpStr .. "*" 
			end  
			endWordStr = string.gsub(endWordStr, v.words, tmpStr) 
		end 
	end 

	return bHas, endWordStr   
 end


 function ChatLayer:checkMsg(msg) 
 	local canSend = true 
 	local length = string.utf8len(msg) 
 	if length <= 0 then 
 		show_tip_label("发送内容不能为空") 
 		return 
 	end 

 	if(game.player:getLevel() < 15) then
 		show_tip_label("英雄您的等级不足15级，练练再来吧!")
 		return 
 	end

 	if self._time > 0 then
 		show_tip_label("您发言太快请稍后重试")
 		return 
 	end

 	if msg == self._lastChatMsg then 
 		self:sendMsgSuccess(msg) 
 		return 
 	end 

	if length > MAX_TEXT_LEN then 
		show_tip_label("发送内容最多40个字")
		local text = string.gsub(msg, 1, MAX_TEXT_LEN)
		self._editBox:setText(text)
		-- return 
	end
	
 	local bContain, endWordStr = self:checkSensitiveWord(msg)
	-- if bContain then
	-- 	canSend = false
	-- 	show_tip_label("含有敏感词汇，请重新输入")
	-- end

	if canSend then 
		self:sendMsg(endWordStr)
	end 
 end 


 function ChatLayer:onExit()
 	if self._schedule ~= nil then 
        self.scheduler.unscheduleGlobal(self._schedule) 
    end

	self:unscheduleUpdate()
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
 end


 function ChatLayer:initFriendData()

 	local listData = FriendModel.getList(1)
     local cellData = listData[self.friendIndex]

     --基础的
     self.friendAccount     = cellData.account
     self.battlepoint 		= cellData.battlepoint or 0
     self.charm       		= cellData.charm       or 0
     self.cls         		= cellData.cls         or 1
     self.level       		= cellData.level       or 0
     self.name        		= cellData.name        or 0
     self.resId       		= cellData.resId       or 0

 end

 function ChatLayer:initFriendContent()
 	self.heroNameTTF =  ResMgr.createShadowMsgTTF({text = "",color = ccc3(255,210,0)})--n
 	self._rootnode["heroName"]:getParent():addChild(self.heroNameTTF)

 	self._rootnode["zhanli_num"]:setString(self.battlepoint)
 	self._rootnode["charm_num"]:setString(self.charm)

 	self._rootnode["level"]:setString(self.level)
 	self.heroNameTTF:setString(self.name)
 	local heroPosX,heroPosY = self._rootnode["heroName"]:getPosition()
 	self.heroNameTTF:setPosition(ccp(heroPosX+self.heroNameTTF:getContentSize().width/2,heroPosY))

 	-- --更新头像
 	ResMgr.refreshIcon({id = self.resId,itemBg = self._rootnode["headIcon"],resType = ResMgr.HERO,cls = self.cls})
 end

 return ChatLayer
 