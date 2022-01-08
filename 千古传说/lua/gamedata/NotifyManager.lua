
NotifyMessageLayer = require("lua.logic.notify.NotifyMessageLayer")
ServerChatLayer = require("lua.logic.notify.ServerChatLayer")

--test add by wuqi
TuhaoChatLayer = require("lua.logic.notify.TuhaoChatLayer")

local NotifyManager = class('NotifyManager')

NotifyManager.MSG_DEL_EMAIL = "NotifyManager.MSG_DEL_EMAIL"

local nobody = localizable.NotifyManager_nobody --nobody

function NotifyManager:ctor()
	TFDirector:addProto(s2c.GET_CARD_NOTIFY, 	 self, self.GetCardNotify)
	TFDirector:addProto(s2c.GET_EQUIP_NOTIFY, 	 self, self.GetEquipNotify)
	TFDirector:addProto(s2c.FIRST_CHANGE_NOTIFY,self, self.ArenaTop1ChangedNotify)
	TFDirector:addProto(s2c.ARENA_BALANCE_NOTIFY,self, self.ArenaBalanceNotify)
	TFDirector:addProto(s2c.ARENA_BALANCE_TRAILER_NOTIFY,self, self.ArenaBalanceTrailerNotify)
	TFDirector:addProto(s2c.WORLD_BOSS_BALANCE_NOTIFY,self, self.WorldBossBalanceNotify)

	TFDirector:addProto(s2c.RETURN_NOTIFY_NUM,   self, self.ReceiveNotifyNum)
	TFDirector:addProto(s2c.RETURN_FIGHT_NOTIFY, self, self.ReceiveFightNotify)
	TFDirector:addProto(s2c.RETURN_SYSTEM_NOTIFY,self, self.ReceiveSystemNotify)
	TFDirector:addProto(s2c.SYSTEM_NOTICE_MESSAGE,self, self.ReceiveEmergencyNotify)

	TFDirector:addProto(s2c.REPEAT_SYSTEM_MESSAGE,self, self.repeatSystemMessage)
	TFDirector:addProto(s2c.REPEAT_SYSTEM_MESSAGE_LIST,self, self.repeatSystemMessageList)
	TFDirector:addProto(s2c.DEL_REPEAT_SYSTEM_MESSAGE,self, self.delRepeatSystemMessage)

	-- 邮件状态变更
	TFDirector:addProto(s2c.MAIL_STATE_CHANGED,			self, 		self.receiveEmailStatusChanged)
	TFDirector:addProto(s2c.MAIL_STATE_CHANGED_LIST,	self, 		self.receiveEmailListStatusChanged)
	TFDirector:addProto(s2c.DELETE_MAIL_SUCCESS,		self, 		self.receiveDelEmailCallback)
	TFDirector:addProto(s2c.GET_MAIL_REWARD_SUCCESS,	self, 		self.receiveRewardEmailCallback)

	--事件展示功能
	TFDirector:addProto(s2c.ARENA_TOP5_CHANGED_NOTIFY,	self, 		self.receiveArenaTop5Callback)
	TFDirector:addProto(s2c.CLIMB_PASSED_NOTIFY,		self, 		self.receiveClimbPassCallback)
	TFDirector:addProto(s2c.HERO_RANK_TOP1_ONLINE_NOTIFY,self, 		self.receiveHeroTop1Callback)
	TFDirector:addProto(s2c.ARENA_RANK_TOP1_ONLINE_NOTIFY,self, 	self.receiveArenaTop1Callback)

	TFDirector:addProto(s2c.EGG_FRENZY_NOTICE_MESSAGE,self, 	self.receiveGoldEggCallback)

	TFDirector:addProto(s2c.NOTIFY,self, 	self.receiveNotifyCallback)

	--宝石通知
	TFDirector:addProto(s2c.OBTAIN_GEM_NOTIFY, 	 self, self.obtainGemNotify)

	--added by wuqi
	--vip皇上线通知等
	TFDirector:addProto(s2c.ONLINE_TO_SERVER_NOTIFY, self, self.receiveOnlineToServerCallback)

	self.maxNofifyCount = 15

	self.fightNotifyList = TFArray:new()
	self.systemNotifyList = TFArray:new()

	self.fightNotifyNum = 0
	self.systemNotifyNum = 0
	self.selectBtnIndex = 1

	self.bOpenNotice = false



	self.bOpenNotice = false

	self.MessageArray = TFArray:new()
	self.repeatSystemMessageArray = TFArray:new()
	self.serverChatArray = TFArray:new()

	--added by wuqi
	self.tuhaoChatArray = TFArray:new()

	self:addRepeatSystemMessageTimer()
end

function NotifyManager:reset()
	if self.fightNotifyList then
		self.fightNotifyList:clear()
	end

	if self.systemNotifyList then
		self.systemNotifyList:clear()
	end

	if self.repeatSystemMessageArray then
		self.repeatSystemMessageArray:clear()
	end

	self.fightNotifyNum = 0
	self.systemNotifyNum = 0
	self.queryAllFightNotify = false


	self.MessageArray:clear()
end

function NotifyManager:GetCardNotify(event)
	local msgData = event.data
	if msgData.playerName == MainPlayer.name then
		return
	end

	local cardConfig = RoleData:objectByID(msgData.cardId)
	if cardConfig == nil then
		return
	end

	local nameRGBValue = '#ff4ef5'
	if cardConfig.quality == 5 then
		nameRGBValue = '#ff9c00'
	end

	local strFormat = localizable.NotifyManager_getRole_strFormat
	-- {
	-- 	[[<p style="text-align:left margin:5px">
	-- 	<font color="#feff8f" fontSize="26">%s</font><font color="#ffffff" fontSize="26">今日与</font><font color="]]..nameRGBValue..[[" fontSize="26">%s</font><font color="#ffffff" fontSize="26">义结金兰，江湖为之一震！</font></p>]],

	-- 	[[<p style="text-align:left margin:5px">
	-- 	<font color="#feff8f" fontSize="26">%s</font><font color="#ffffff" fontSize="26">成功招募</font><font color="]]..nameRGBValue..[[" fontSize="26">%s</font><font color="#ffffff" fontSize="26">，实在是可喜可贺！</font></p>]],

	-- 	[[<p style="text-align:left margin:5px">
	-- 	<font color="#feff8f" fontSize="26">%s</font><font color="#ffffff" fontSize="26">招募了</font><font color="]]..nameRGBValue..[[" fontSize="26">%s</font><font color="#ffffff" fontSize="26">，快来围观！</font></p>]],
	-- }
	local strFormatChat = localizable.NotifyManager_getRole_strFormatChat
	-- {
	-- 	[[<p style="text-align:left margin:5px">
	-- 	<font color="#ff0000" fontSize="26">%s</font><font color="#000000" fontSize="26">今日与</font><font color="]]..nameRGBValue..[[" fontSize="26">%s</font><font color="#000000" fontSize="26">义结金兰，江湖为之一震！</font></p>]],

	-- 	[[<p style="text-align:left margin:5px">
	-- 	<font color="#ff0000" fontSize="26">%s</font><font color="#000000" fontSize="26">成功招募</font><font color="]]..nameRGBValue..[[" fontSize="26">%s</font><font color="#000000" fontSize="26">，实在是可喜可贺！</font></p>]],

	-- 	[[<p style="text-align:left margin:5px">
	-- 	<font color="#ff0000" fontSize="26">%s</font><font color="#000000" fontSize="26">招募了</font><font color="]]..nameRGBValue..[[" fontSize="26">%s</font><font color="#000000" fontSize="26">，快来围观！</font></p>]],
	-- }


	local radomIndex = math.random(1, #strFormat)
	local notifyStr = stringUtils.format(strFormat[radomIndex], msgData.playerName, nameRGBValue, cardConfig.name)
	local notifyStrChat = stringUtils.format(strFormatChat[radomIndex], msgData.playerName, nameRGBValue, cardConfig.name)

	if cardConfig.quality == 5 then
		self:sendMsgToChat(notifyStrChat)
	end
	self:addMessage(notifyStr, 1, 1)

end

function NotifyManager:GetEquipNotify(event)
	local msgData = event.data
	local equipConfig = ItemData:objectByID(msgData.equipId)
	if equipConfig == nil then
		return
	end

	local nameRGBValue = '#ff4ef5'
	if equipConfig.quality == 5 then
		nameRGBValue = '#ff9c00'
	end

	local strFormat = localizable.NotifyManager_getEquip_strFormat
	-- {
	-- 	[[<p style="text-align:left margin:5px">
	-- 	<font color="#feff8f" fontSize="26">%s</font><font color="#ffffff" fontSize="26">获得了</font><font color="]]..nameRGBValue..[[" fontSize="26">%s</font><font color="#ffffff" fontSize="26"> x%s，一统江湖指日可待！</font></p>]],

	-- 	[[<p style="text-align:left margin:5px">
	-- 	<font color="#feff8f" fontSize="26">%s</font><font color="#ffffff" fontSize="26">获得了</font><font color="]]..nameRGBValue..[[" fontSize="26">%s</font><font color="#ffffff" fontSize="26"> x%s，快来围观！</font></p>]],
	-- }
	local strFormatChat = localizable.NotifyManager_getEquip_strFormatChat
	-- {
	-- 	[[<p style="text-align:left margin:5px">
	-- 	<font color="#ff0000" fontSize="26">%s</font><font color="#000000" fontSize="26">获得了</font><font color="]]..nameRGBValue..[[" fontSize="26">%s</font><font color="#000000" fontSize="26"> x%s，一统江湖指日可待！</font></p>]],

	-- 	[[<p style="text-align:left margin:5px">
	-- 	<font color="#ff0000" fontSize="26">%s</font><font color="#000000" fontSize="26">获得了</font><font color="]]..nameRGBValue..[[" fontSize="26">%s</font><font color="#000000" fontSize="26"> x%s，快来围观！</font></p>]],
	-- }


	local radomIndex = math.random(1, #strFormat)
	local notifyStr = stringUtils.format(strFormat[radomIndex], msgData.playerName, nameRGBValue, equipConfig.name,msgData.number)
	local notifyStrChat = stringUtils.format(strFormatChat[radomIndex], msgData.playerName, nameRGBValue, equipConfig.name,msgData.number)


	-- self:ShowNotifyMessage(notifyStr)
	if equipConfig.quality == 5 then
		self:sendMsgToChat(notifyStrChat)
	end
	self:addMessage(notifyStr, 1, 1)
end

--[[
获得宝石通知
]]
function NotifyManager:obtainGemNotify(event)
	local msgData = event.data
	local operationType = msgData.operationType
		if operationType and operationType >0  then
		if operationType == 203 then
			return
		elseif operationType == 204 then
			return
		elseif operationType == 207 then
			return
		elseif operationType == 211 then
			return
		end
	end

	local goodsTemplate = ItemData:objectByID(msgData.templateId)
	if goodsTemplate == nil then
		return
	end

	local nameRGBValue = '#ff4ef5'
	if goodsTemplate.quality == 5 then
		nameRGBValue = '#ff9c00'
	end

	
	local operationStrFormat = ''
	if operationType and operationType >0  then
		if operationType == 104 then
			--operationStrFormat = "，通过宝石合成，"--[[<font color="#000000" fontSize="26">，通过宝石合成，</font>]]
			operationStrFormat = localizable.NotifyManager_operationStrFormat1
		elseif operationType == 203 then
			--operationStrFormat = "，通过宝石拆卸，"--[[<font color="#000000" fontSize="26">，通过宝石拆卸，</font>]]
			operationStrFormat = localizable.NotifyManager_operationStrFormat2
		elseif operationType == 204 then
			--operationStrFormat = "，通过装备升星，"--[[<font color="#000000" fontSize="26">，通过装备升星，</font>]]
			operationStrFormat = localizable.NotifyManager_operationStrFormat3
		elseif operationType == 207 then
			--operationStrFormat = "，通过出售装备，"--[[<font color="#000000" fontSize="26">，通过出售装备，</font>]]
			operationStrFormat = localizable.NotifyManager_operationStrFormat4
		elseif operationType == 211 then
			--operationStrFormat = "，通过装备重铸，"--[[<font color="#000000" fontSize="26">，通过装备重铸，</font>]]
			operationStrFormat = localizable.NotifyManager_operationStrFormat5
		end
	end

	local strFormat = localizable.NotifyManager_obtainGemNotify_strFormat
	-- {
	-- 	[[<p style="text-align:left margin:5px">
	-- 	<font color="#feff8f" fontSize="26">%s</font><font color="#ffffff" fontSize="26">%s</font><font color="#ffffff" fontSize="26">获得了</font><font color="]]..nameRGBValue..[[" fontSize="26">%s</font><font color="#ffffff" fontSize="26"> x%s，一统江湖指日可待！</font></p>]],

	-- 	[[<p style="text-align:left margin:5px">
	-- 	<font color="#feff8f" fontSize="26">%s</font><font color="#ffffff" fontSize="26">%s</font><font color="#ffffff" fontSize="26">获得了</font><font color="]]..nameRGBValue..[[" fontSize="26">%s</font><font color="#ffffff" fontSize="26"> x%s，快来围观！</font></p>]],
	-- }
	local strFormatChat = localizable.NotifyManager_obtainGemNotify_strFormatChat
	-- {
	-- 	[[<p style="text-align:left margin:5px">
	-- 	<font color="#ff0000" fontSize="26">%s</font><font color="#000000" fontSize="26">%s</font><font color="#000000" fontSize="26">获得了</font><font color="]]..nameRGBValue..[[" fontSize="26">%s</font><font color="#000000" fontSize="26"> x%s，一统江湖指日可待！</font></p>]],

	-- 	[[<p style="text-align:left margin:5px">
	-- 	<font color="#ff0000" fontSize="26">%s</font><font color="#000000" fontSize="26">%s</font><font color="#000000" fontSize="26">获得了</font><font color="]]..nameRGBValue..[[" fontSize="26">%s</font><font color="#000000" fontSize="26"> x%s，快来围观！</font></p>]],
	-- }

	local radomIndex = math.random(1, #strFormat)
	local notifyStr = stringUtils.format(strFormat[radomIndex], msgData.playerName,operationStrFormat, nameRGBValue, goodsTemplate.name,msgData.number)
	local notifyStrChat = stringUtils.format(strFormatChat[radomIndex], msgData.playerName,operationStrFormat, nameRGBValue, goodsTemplate.name,msgData.number)

	-- self:ShowNotifyMessage(notifyStr)
	-- if goodsTemplate.quality == 5 then
	self:sendMsgToChat(notifyStrChat)
	-- end
	self:addMessage(notifyStr, 1, 1)
end

function NotifyManager:ArenaTop1ChangedNotify(event)
	--quanhuan closed 2015-11-16 19:16:05
	-- local msgData = event.data
	-- local chineseRank = EnumWuxueLevelType
	-- local strFormat =[[<p style="text-align:left margin:5px"><font color="#ffffff" fontSize="26"> 群豪技痒，谱已重著！ </font>
	-- 	<font color="#feff8f" fontSize="26">%s</font><font color="#ffffff" fontSize="26"> 在群豪谱中击败了 </font><font color="#ff4ef5" fontSize="26">%s</font><font color="#ffffff" fontSize="26">，夺得了第%s名的宝座！</font></p>]]

	-- print("msgData = ", msgData)
	-- local notifyStr = stringUtils.format(strFormat, msgData.winerName, msgData.loserName, chineseRank[msgData.rank])

	-- -- self:ShowNotifyMessage(notifyStr)

	-- self:addMessage(notifyStr, 1, 2)
	-- --self:sendMsgToChat(notifyStr)
end

function NotifyManager:ArenaBalanceNotify(event)
	-- local strFormat =[[<p style="text-align:left margin:5px"><font color="#ffffff" fontSize="26">群豪论剑，勇冠武林！状元：</font>
	-- 	<font color="#feff8f" fontSize="26">%s</font><font color="#ffffff" fontSize="26">，榜眼：</font><font color="#ff4ef5" fontSize="26">%s</font><font color="#ffffff" fontSize="26">，探花：</font><font color="#FF0000" fontSize="26">%s</font><font color="#ffffff" fontSize="26">，今日英雄已成谱，明日群豪谁当先？</font></p>]]
	local strFormat = localizable.NotifyManager_arena_strFormat

	local balanceInfoTab = event.data.rankingInfo
	local tabLength = #balanceInfoTab
	local notifyStr = ""
	if tabLength > 2 then
		notifyStr = stringUtils.format(strFormat, balanceInfoTab[1].name, balanceInfoTab[2].name,balanceInfoTab[3].name)
	elseif tabLength > 1 then
		notifyStr = stringUtils.format(strFormat, balanceInfoTab[1].name, balanceInfoTab[2].name,nobody)
	elseif tabLength > 0 then
		notifyStr = stringUtils.format(strFormat, balanceInfoTab[1].name,nobody,nobody)
	else
		notifyStr = stringUtils.format(strFormat, nobody,nobody,nobody)
	end

	-- self:ShowNotifyMessage(notifyStr)

	self:addMessage(notifyStr, 1, 1)
end

--[[
群豪谱结算预告
]]
function NotifyManager:ArenaBalanceTrailerNotify(event)
	-- local strFormat =[[<p style="text-align:left margin:5px"><font color="#ffffff" fontSize="26">群豪谱将在21:00进行结算，状元：</font>
	-- 	<font color="#feff8f" fontSize="26">%s</font><font color="#ffffff" fontSize="26">，探花：</font><font color="#ff4ef5" fontSize="26">%s</font><font color="#ffffff" fontSize="26">，榜眼：</font><font color="#FF0000" fontSize="26">%s</font><font color="#ffffff" fontSize="26">，谁与争锋？</font></p>]]

	--local strFormat =[[<p style="text-align:left margin:5px"><font color="#ffffff" fontSize="26">群豪谱将于21：00结算奖励，论何人武功第一，谁与争锋！敬请群雄抓紧时间争夺武林霸主之位！</font></p>]]
	local strFormat = localizable.NotifyManager_ArenaBalanceTrailer_strFormat

	local balanceInfoTab = event.data.rankingInfo
	local tabLength = #balanceInfoTab
	local notifyStr = ""
	if tabLength > 2 then
		notifyStr = stringUtils.format(strFormat, balanceInfoTab[1].name, balanceInfoTab[2].name,balanceInfoTab[3].name)
	elseif tabLength > 1 then
		notifyStr = stringUtils.format(strFormat, balanceInfoTab[1].name, balanceInfoTab[2].name,nobody)
	elseif tabLength > 0 then
		notifyStr = stringUtils.format(strFormat, balanceInfoTab[1].name,nobody,nobody)
	else
		notifyStr = stringUtils.format(strFormat, nobody,nobody,nobody)
	end

	-- self:ShowNotifyMessage(notifyStr)

	self:addMessage(notifyStr, 1, 2)
end

--[[
世界BOSS结算
]]
function NotifyManager:WorldBossBalanceNotify(event)
	-- local strFormat =[[<p style="text-align:left margin:5px"><font color="#ffffff" fontSize="26">走火入魔，万人伏之，</font>
	-- 	<font color="#feff8f" fontSize="26">%s</font><font color="#ffffff" fontSize="26">最暴力，对伏魔录Boss造成 </font><font color="#ff4ef5" fontSize="26">%s</font><font color="#ffffff" fontSize="26">伤害，</font><font color="#FF0000" fontSize="26">%s</font><font color="#ffffff" fontSize="26"> ，</font><font color="#FF0000" fontSize="26">%s</font><font color="#ffffff" fontSize="26">紧跟其后，分别造成了</font><font color="#FF0000" fontSize="26">%s</font><font color="#FFFFFF" fontSize="26"> ，</font><font color="#FF0000" fontSize="26">%s</font><font color="#FFFFFF" fontSize="26"> 伤害</font></p>]]

	local strFormat = localizable.NotifyManager_WorldBoss_strFormat
	local balanceInfoTab = event.data.rankingInfo
	if balanceInfoTab == nil then
		print("")
		return
	end

	local tabLength = #balanceInfoTab
	local notifyStr = ""
	if tabLength > 2 then
		notifyStr = stringUtils.format(strFormat, balanceInfoTab[1].name,balanceInfoTab[1].totalDamage, balanceInfoTab[2].name,balanceInfoTab[3].name,balanceInfoTab[2].totalDamage,balanceInfoTab[3].totalDamage)
	elseif tabLength > 1 then
		notifyStr = stringUtils.format(strFormat, balanceInfoTab[1].name,balanceInfoTab[1].totalDamage, balanceInfoTab[2].name,nobody,balanceInfoTab[2].totalDamage,0,0)
	elseif tabLength > 0 then
		notifyStr = stringUtils.format(strFormat, balanceInfoTab[1].name,balanceInfoTab[1].totalDamage,nobody,nobody,0,0)
	else
		notifyStr = stringUtils.format(strFormat, nobody,0,nobody,nobody,0,0)
	end

	-- self:ShowNotifyMessage(notifyStr)

	self:addMessage(notifyStr, 1, 1)
end

--紧急通知
function NotifyManager:ReceiveEmergencyNotify(event)
	if event.data.content == nil then
		return
	end

	local content = event.data.content
	if content == "" then
		return
	end

	-- local strFormat = [[<p style="text-align:left margin:5px"><font color="#FF0000" fontSize="26">%s</font></p>]]
	local strFormat = [[<p style="text-align:left margin:5px"><font color="#FF4444" fontSize="26">{p1}</font></p>]]
	local notifyStr = stringUtils.format(strFormat, content)

	-- self:RemoveNotifyMessage()
	-- self:ShowNotifyMessage(notifyStr)

	local disTimes 		= 2
	local disPriority 	= 3

	self:addMessage(notifyStr, disTimes, disPriority)

	self:sendMsgToChat(notifyStr)
end

--可重复系统消息主动推出
function NotifyManager:repeatSystemMessage(event)
	local data = event.data
	print("NotifyManager:repeatSystemMessage--->",data)
	for notify in self.repeatSystemMessageArray:iterator() do 
		if notify.messageId == data.messageId then
			for key ,value in pairs(data) do
				notify[key] =  value
				return
			end
		end
	end
	local notify = clone(data)
	notify.cur_time = notify.intervalTime
	notify.isAdd = false
	notify.add_times = 0
	self.repeatSystemMessageArray:pushBack(notify)
end
--可重复系统消息列表主动推出
function NotifyManager:repeatSystemMessageList(event)
	local data = event.data
	print("NotifyManager:repeatSystemMessageList--->",data)
	self.repeatSystemMessageArray:clear()
	if data.msg then
		for i=1,#data.msg do
			local notify = clone(data.msg[i])
			notify.cur_time = notify.intervalTime
			notify.isAdd = false
			notify.add_times = 0
			self.repeatSystemMessageArray:pushBack(notify)
		end
	end
end
--可重复系统消息删除
function NotifyManager:delRepeatSystemMessage(event)
	local data = event.data
	print("NotifyManager:delRepeatSystemMessage--->",data)
	for notify in self.repeatSystemMessageArray:iterator() do 
		if notify.messageId == data.messageId then
			self.repeatSystemMessageArray:removeObject(notify)
			return
		end
	end
end

function NotifyManager:getRepeatSystemMessageById(messageId )
	for notify in self.repeatSystemMessageArray:iterator() do 
		if notify.messageId == messageId then
			return notify
		end
	end
end

function NotifyManager:updateRepeatSystemMessage()
	if self.repeatSystemMessageArray:length() == 0 then
		return
	end
	local nowTime  = MainPlayer:getNowtime()
	local removeArray = TFArray:new()
	for notify in self.repeatSystemMessageArray:iterator() do
		if notify.beginTime == nil or notify.beginTime <= nowTime then
			if notify.endTime == nil or notify.endTime >= nowTime then
				if notify.repeatTime == nil or notify.repeatTime > notify.add_times then
					if notify.isAdd == false then
						notify.cur_time = notify.cur_time + 1
						if notify.cur_time >= notify.intervalTime then
						print("-------------------------add 1111-------------------------->",notify.messageId)
							notify.cur_time = 0
							notify.isAdd = true
							-- notify.add_times = notify.add_times + 1
							local strFormat = [[<p style="text-align:left margin:5px"><font color="#FF4444" fontSize="26">{p1}</font></p>]]
							local notifyStr = stringUtils.format(strFormat, notify.content)
							self:sendMsgToChat(notifyStr)
							self:addMessage(notifyStr,1,notify.priority,notify.messageId)
						end
					end
				else
					removeArray:pushBack(notify)
				end
			else
				removeArray:pushBack(notify)
			end
		end
	end
	for v in removeArray:iterator() do
		print("removre ---------->",v)
		self.repeatSystemMessageArray:removeObject(v)
	end
	removeArray:clear()
end

function NotifyManager:addRepeatSystemMessageTimer()
	if self.repeatSystemMessageTimer == nil then
		self.repeatSystemMessageTimer = TFDirector:addTimer(1000,-1,nil,function ()
			self:updateRepeatSystemMessage()
		end)
	end
end


function NotifyManager:ShowNotifyMessage(notifyStr)
	if not tolua.isnull(self.notifyLayer) then
		return
	end

	local currentScene = Public:currentScene()
    if currentScene.__cname == "FightResultScene" or currentScene.__cname == "FightScene" then
       return
    end

	self:RemoveNotifyMessage()

	self.notifyLayer = NotifyMessageLayer:new()
	self.notifyLayer:setPosition(ccp(GameConfig.WS.width/2, 110))
	self.notifyLayer:setZOrder(500)
	currentScene:addLayer(self.notifyLayer)

    self.notifyLayer:ShowText(notifyStr)
end

function NotifyManager:RemoveNotifyMessage()
	if not tolua.isnull(self.notifyLayer) then
		Public:currentScene():removeLayer(self.notifyLayer)
	end
	self.notifyLayer = nil
end

function NotifyManager:ShowNotifyInfoLayer()
	if self.selectBtnIndex == 1 and self.fightNotifyNum == 0 then
        if self.systemNotifyNum > 0 then
        	self.selectBtnIndex = 2
        end
    elseif NotifyManager.selectBtnIndex == 2 and self.systemNotifyNum == 0 then
        if self.fightNotifyNum > 0 then
        	self.selectBtnIndex = 1
        end
    end

	AlertManager:addLayerByFile("lua.logic.notify.NotifyInfoLayer", AlertManager.BLOCK_AND_GRAY)
    AlertManager:show()
end

function NotifyManager:RefreshNotifyInfoLayer()
	local layer = AlertManager:getLayerByName("lua.logic.notify.NotifyInfoLayer")
	if layer ~= nil then
		layer:RefreshUI()
	end
end

function NotifyManager:ReceiveNotifyNum(event)

	if event.data.fightNotifyNum ~= nil then
		self.fightNotifyNum = event.data.fightNotifyNum
	end

	if event.data.systemNotifyNum ~= nil then
		self.systemNotifyNum = event.data.systemNotifyNum
	end
end

function NotifyManager:SendQueryMsg(code)
	if code == c2s.QUERY_FIGHT_NOTIFY then
		if  self:needSendFightNotify() == false then
			self:RefreshNotifyInfoLayer()
			return
		end
		if not self.queryAllFightNotify then
			local msg = {false}
			TFDirector:send(code, msg)
			self.queryAllFightNotify = true
		else
			local msg = {true}
			TFDirector:send(code, msg)
		end
	elseif code == c2s.QUERY_SYSTEM_NOTIFY then
		if  self:needSendSystemNotify() == false then
			self:RefreshNotifyInfoLayer()
			return
		end
		TFDirector:send(code, {false})
    end
end

function NotifyManager:needSendFightNotify()
	if self.fightNotifyList:length() == 0 then
		return true
	end
	if self.fightNotifyNum > 0 then
		return true
	end
	return false
end

function NotifyManager:needSendSystemNotify()
	if self.systemNotifyList:length() == 0 then
		return true
	end
	if self.systemNotifyNum > 0 then
		return true
	end
	return false
end
--按照id排序
local function sortlist( v1,v2 )
	if v1.status == nil then
		v1.status = 1
	end

	if v2.status == nil then
		v2.status = 1
	end

    if v1.status > v2.status then
        return false
    end
    if v1.status == v2.status then
		if v1.canGet == false and v2.canGet == true then
			return false
		end
		if v1.canGet == v2.canGet then
			if v1.time < v2.time then
				return false
			end
		end
	end
    return true
end

function NotifyManager:ReceiveFightNotify(event)
	print("NotifyManager:ReceiveFightNotify", event.data.list)
	if event.data.list ~= nil then
		local count = #event.data.list
		local i = count
		while i >= 1 do
			-- self.fightNotifyList:pushBack(event.data.list[i])
			self.fightNotifyList:pushFront(event.data.list[i])
			i = i - 1
		end

		if self.fightNotifyList:length() > self.maxNofifyCount then
			self.fightNotifyList:splice(self.fightNotifyList:length()+1, self.fightNotifyList:length()-self.maxNofifyCount)
		end
	end
	-- if self.fightNotifyList:length() > 1 then
	-- 	self.fightNotifyList:sort(sortlist)
	-- end
	self:RefreshNotifyInfoLayer()
end

function NotifyManager:addSystemNotify( notify )
	for _notify in self.systemNotifyList:iterator() do
		if notify.id == _notify.id then
			_notify = notify
			return
		end
	end
	self.systemNotifyList:pushBack(notify)
end

function NotifyManager:ReceiveSystemNotify(event)
	-- print("NotifyManager:ReceiveSystemNotify", event.data.notifyList)
	-- self.systemNotifyList:clear()
	if event.data.notifyList ~= nil then
		local count = #event.data.notifyList
		local i = count
		while i >= 1 do
			self:addSystemNotify(event.data.notifyList[i])
			i = i - 1
		end
	end
	if self.systemNotifyList:length() > 1 then
		print("-------------sort")
		self.systemNotifyList:sort(sortlist)
	end
	print("self.systemNotifyList = ",self.systemNotifyList)
	self:RefreshNotifyInfoLayer()
end

--红点判断逻辑
--是否该新邮件未读
function NotifyManager:isUnReadMail(id)
	for i=1, self.systemNotifyList:length() do
		local mail = self.systemNotifyList:objectAt(i)
		if mail.id == id and mail.status == 0 then
			return true
		end
	end
	return false
end

--是否有邮件未读（1:战斗，2：系统）
function NotifyManager:isHaveUnReadMailForType(type)

	if type == 1 then
		return self.fightNotifyNum > 0
	elseif type == 2 then
		return self.systemNotifyNum > 0
	end
	return false
end

--是否有邮件未读
function NotifyManager:isHaveUnReadMail()
	if self.fightNotifyNum > 0 then
		return true
	elseif self.systemNotifyNum > 0 then
		return true
	end
	return false
end

--进入相应邮件界面，红点消失
function NotifyManager:onIntoMailLayer(type)
	--服务端记录，并推送前端
	--do nothing
	if type == 1 then
		self.fightNotifyNum = 0;
	elseif type == 2 then
		self.systemNotifyNum = 0;
	end 
end

function NotifyManager:openNoticeLayer()
	if self.bOpenNotice == false then
		self.bOpenNotice = true
		local content = require("lua.table.t_s_notice")
		local layer  = require("lua.logic.notify.NoticeLayer"):new(content)
    	AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
   	 	AlertManager:show()
	end
end


function NotifyManager:addMessage(disContent, disTimes, disPriority,reapteMessageId)
	local showTime 		= disTimes or 1
	local showPriority 	= disPriority or 1
	if reapteMessageId == nil then
		reapteMessageId = 0
	end

	local len = self.MessageArray:length()
	
	if len >= 10 and disPriority == 1 then
		print("---NotifyManager:addMessag 已达到最大10条 不在添加，优先级高的不加限制")
		return
	end

	local msgNode = {
		content  = disContent,
		times 	 = showTime,
		priority = showPriority,
		reapteMessageId = reapteMessageId,
	}

	self.MessageArray:push(msgNode)

	local function sortCmp(node1, node2)
		if node1 == nil then
			return false
		end

		if node1 and node2 and node1.priority > node2.priority then
			return true
		end

		return false
	end


	local len = self.MessageArray:length()

	if len > 1 then
		self.MessageArray:sort(sortCmp)
	end

	print("----------------NotifyManager:addMessage--------count", len)
	if self.notifyLayer == nil then
		local msgNode = self.MessageArray:front()
		print("msgNode = ", msgNode)
		if msgNode then
			print("msgNode.content 11 = ", msgNode.content)
			msgNode.times = msgNode.times - 1
			self:displayMessage(msgNode.content)
		end
	end
end

function NotifyManager:displayMessageCompelete()
	self:RemoveNotifyMessage()
	print("self.MessageArray:length( ----------->",self.MessageArray:length())
	if self.MessageArray:length() == 0 then
		return
	end
	--否还有公告
	local msgNode = self.MessageArray:front()
	while self.MessageArray:length() > 0 and msgNode == nil do
		self.MessageArray:popFront()
		msgNode = self.MessageArray:front()
	end
	if self.MessageArray:length() == 0 or msgNode == nil then
		print("广播播完了")
		return
	end

	print("msgNode.times = ", msgNode.times)
	if msgNode.times > 0 then
		msgNode.times = msgNode.times - 1
		self:displayMessage(msgNode.content)

	else
		if msgNode.reapteMessageId ~= 0 then
			print("-------------------------add -------------------------->",msgNode.reapteMessageId)
			local notify = self:getRepeatSystemMessageById(msgNode.reapteMessageId )
			if notify then
				notify.isAdd = false
				notify.add_times = notify.add_times + 1
			end
		end
		self.MessageArray:popFront()

		self:displayMessageCompelete()
	end

end


function NotifyManager:displayMessage(notifyStr)
	-- if not tolua.isnull(self.notifyLayer) then
	-- 	return
	-- end

	local currentScene = Public:currentScene()
    if currentScene.__cname == "FightResultScene" or currentScene.__cname == "FightScene" then
       return
    end

    if self.notifyLayer == nil then
		self.notifyLayer = NotifyMessageLayer:new()
		self.notifyLayer:setPosition(ccp(GameConfig.WS.width/2, 25))
		self.notifyLayer:setZOrder(500)
		currentScene:addLayer(self.notifyLayer)

	    self.notifyLayer:ShowText(notifyStr)
   	end
end

function NotifyManager:changeEmailStatus(emaildata)

	print("-------changeEmailStatus-----emaildata = ", emaildata)
	if emaildata == nil then
		return
	end
	-- 	required int32 id = 1;					//邮件ID
	-- required int32 status = 2;				//状态：0、未读；1、已读；2、已领取；3、删除
	local notifyId = emaildata.id
	local status   = emaildata.status

    for v in self.systemNotifyList:iterator() do
    	if notifyId == v.id then
    		if status == 3 or status == 2 then
    			self.systemNotifyList:removeObject(v)
    		end

    		return
    	end
    end

    self:RefreshNotifyInfoLayer()
end


function NotifyManager:receiveEmailStatusChanged(event)
	hideLoading()

	self:changeEmailStatus(event.data)

	
	TFDirector:dispatchGlobalEventWith(NotifyManager.MSG_DEL_EMAIL, {})
	self:RefreshNotifyInfoLayer()
end

function NotifyManager:receiveEmailListStatusChanged(event)
	hideLoading()

	if event.data.mail == nil then
		return
	end

	for i,v in pairs(event.data.mail) do
		self:changeEmailStatus(v)
	end

	self:RefreshNotifyInfoLayer()
end


function NotifyManager:delEmail(emailID)
	showLoading()
	if 1 then
		print("del emailID = ", emailID)
		-- return
	end

	TFDirector:send(c2s.REQUEST_DEL_EMAIL, {emailID})
end

function NotifyManager:delAllEmail()
	if self.systemNotifyList:length() < 1 then
		--toastMessage("大侠，你的邮件已经是空的了！")
		toastMessage(localizable.NotifyManager_Email_empty)
		return
	end
	-- local can_del = false
	local nowTime = MainPlayer:getNowtime()
	for v in self.systemNotifyList:iterator() do
		if v.status == 1 and (nowTime - math.floor(v.time/1000)) > 12*3600 then
			-- can_del = true
			self:delEmail(0)
			return
		end
    end

	-- if can_del == false then
	--toastMessage("当前无可删除邮件")
	toastMessage(localizable.NotifyManager_Email_candel)
	-- end
end

function NotifyManager:getAllEmailReward()
	for v in self.systemNotifyList:iterator() do
		if v.canGet == true then
			showLoading()
			TFDirector:send(c2s.REQUEST_ALL_EMAIL_REWARDS, {})
			return
		end
    end
	--toastMessage("没有可领取邮件")
	toastMessage(localizable.NotifyManager_Email_bukeling)

 
end

-- /删除邮件成功，避免进度条卡死
function NotifyManager:receiveDelEmailCallback(event)
	hideLoading()
	--toastMessage("删除已读邮件成功")
	toastMessage(localizable.NotifyManager_Email_shanchuchenggong)
	print(" NotifyManager:receiveDelEmailCallback event = ", event.data)
end

-- 领取邮件成功，避免进度条卡死 
function NotifyManager:receiveRewardEmailCallback(event)
	hideLoading()

end


function NotifyManager:sendMsgToChat(content)
	--[[
message ChatInfo
{
	required int32 chatType = 1;	// 聊天类型；1、公共，2、私聊；3、帮派； 
	required string message = 2;	//消息;
	required int32 playerId = 3;	//说话人的id 
	required string name = 4;		//说话人的名字 
}
]]
	local msg = {}
	msg.chatType = EnumChatType.Public
	msg.roleId 	 = 0
	msg.content  = content --"11213141"
	msg.name     = "系统公告"
	msg.timestamp= MainPlayer:getNowtime() * 1000

	ChatManager:addReceive(msg)
end

--群豪谱前5名变换
function NotifyManager:receiveArenaTop5Callback(event)

	print("event = ",event.data)
	local oldName = event.data.oldName
	local newName = event.data.newName
	local ranking = event.data.ranking

	local chineseRank = EnumWuxueLevelType
	-- local strFormatChat =[[<p style="text-align:left margin:5px"><font color="#000000" fontSize="26"> 群豪技痒，谱已重著！ </font>
	-- 	<font color="#ff0000" fontSize="26">%s</font><font color="#000000" fontSize="26"> 在群豪谱中击败了 </font>
	-- 	<font color="#ff0000" fontSize="26">%s</font><font color="#000000" fontSize="26">，夺得了第%s名的宝座！</font></p>]]
	-- local strFormat =[[<p style="text-align:left margin:5px"><font color="#ffffff" fontSize="26"> 群豪技痒，谱已重著！ </font>
	-- 	<font color="#feff8f" fontSize="26">%s</font><font color="#ffffff" fontSize="26"> 在群豪谱中击败了 </font>
	-- 	<font color="#feff8f" fontSize="26">%s</font><font color="#ffffff" fontSize="26">，夺得了第%s名的宝座！</font></p>]]

	local strFormatChat = localizable.NotifyManager_ArenaChange_strFormatChat
	local strFormat = localizable.NotifyManager_ArenaChange_strFormat

	local notifyStrChat = stringUtils.format(strFormatChat, newName, oldName, chineseRank[ranking])
	local notifyStr = stringUtils.format(strFormat, newName, oldName, chineseRank[ranking])
	self:sendMsgToChat(notifyStrChat)
	self:addMessage(notifyStr, 1, 1)
end

--无量山通关
function NotifyManager:receiveClimbPassCallback(event)
	
	local playerName = event.data.name
	local gameLevel = event.data.gameLevel

	-- local strFormatChat =[[<p style="text-align:left margin:5px"><font color="#ff0000" fontSize="26">%s</font>
	-- 	<font color="#000000" fontSize="26">竟然击败了无量山第</font><font color="#ff0000" fontSize="26"> %s </font>
	-- 	<font color="#000000" fontSize="26">关的强敌，真是战力非凡，群雄敬仰</font></p>]]
	-- local strFormat =[[<p style="text-align:left margin:5px"><font color="#feff8f" fontSize="26">%s</font>
	-- 	<font color="#ffffff" fontSize="26">竟然击败了无量山第</font><font color="#feff8f" fontSize="26"> %s </font>
	-- 	<font color="#ffffff" fontSize="26">关的强敌，真是战力非凡，群雄敬仰</font></p>]]


	local strFormatChat = localizable.NotifyManager_ClimbPass_strFormatChat
	local strFormat = localizable.NotifyManager_ClimbPass_strFormat
	
	local notifyStrChat = stringUtils.format(strFormatChat, playerName, gameLevel)
	local notifyStr = stringUtils.format(strFormat, playerName, gameLevel)

	self:sendMsgToChat(notifyStrChat)
	self:addMessage(notifyStr, 1, 1)
end

--英雄榜第一名上线
function NotifyManager:receiveHeroTop1Callback(event)

	print("event = ",event.data)
	local playerName = event.data.name	

	-- local strFormatChat =[[<p style="text-align:left margin:5px"><font color="#000000" fontSize="26">晴空一声响雷，天边飘来七彩祥云，原来是英雄榜第一名的</font>
	-- 	<font color="#ff0000" fontSize="26"> %s </font>
	-- 	<font color="#000000" fontSize="26">上线了！</font></p>]]
	-- local strFormat =[[<p style="text-align:left margin:5px"><font color="#ffffff" fontSize="26">晴空一声响雷，天边飘来七彩祥云，原来是英雄榜第一名的</font>
	-- 	<font color="#feff8f" fontSize="26"> %s </font>
	-- 	<font color="#ffffff" fontSize="26">上线了！</font></p>]]

	local strFormatChat = localizable.NotifyManager_HeroTop_strFormatChat
	local strFormat = localizable.NotifyManager_HeroTop_strFormat

	print("msgData = ", msgData)
	local notifyStrChat = stringUtils.format(strFormatChat, playerName)
	local notifyStr = stringUtils.format(strFormat, playerName)

	self:sendMsgToChat(notifyStrChat)
	self:addMessage(notifyStr, 1, 1)
end

--群豪谱第一名上线
function NotifyManager:receiveArenaTop1Callback(event)
	local playerName = event.data.name

	-- local strFormatChat =[[<p style="text-align:left margin:5px"><font color="#000000" fontSize="26">周围突然安静了下来，众人被一股强劲的霸气压制，原来是群豪谱第一名的</font>
	-- 	<font color="#ff0000" fontSize="26"> %s </font>
	-- 	<font color="#000000" fontSize="26">上线了！</font></p>]]
	-- local strFormat =[[<p style="text-align:left margin:5px"><font color="#ffffff" fontSize="26">周围突然安静了下来，众人被一股强劲的霸气压制，原来是群豪谱第一名的</font>
	-- 	<font color="#feff8f" fontSize="26"> %s </font>
	-- 	<font color="#ffffff" fontSize="26">上线了！</font></p>]]

	
	local strFormatChat = localizable.NotifyManager_ArenaTop_strFormatChat
	local strFormat = localizable.NotifyManager_ArenaTop_strFormat

	print("msgData = ", msgData)
	local notifyStrChat = stringUtils.format(strFormatChat, playerName)
	local notifyStr = stringUtils.format(strFormat, playerName)

	self:sendMsgToChat(notifyStrChat)		
	self:addMessage(notifyStr, 1, 1)
end

--vip皇上线等
function NotifyManager:receiveOnlineToServerCallback(event)
	local playerName = event.data.name
	local type = event.data.type

	print("++++++++ vip皇上线啦 +++++++++++ name = ", playerName)
	print("type == ", type)

	if type == 100 then
		-- local strFormatChat =[[<p style="text-align:left margin:5px"><font color="#000000" fontSize="26">众人只觉气息为之凝滞，融融富贵之气缓缓逼近，原来是【皇•VIP】</font>
		-- 	<font color="#ff0000" fontSize="26"> %s </font>
		-- 	<font color="#000000" fontSize="26">上线了！</font></p>]]
		-- local strFormat =[[<p style="text-align:left margin:5px"><font color="#ffffff" fontSize="26">众人只觉气息为之凝滞，融融富贵之气缓缓逼近，原来是【皇•VIP】</font>
		-- 	<font color="#feff8f" fontSize="26"> %s </font>
		-- 	<font color="#ffffff" fontSize="26">上线了！</font></p>]]
		local strFormatChat = localizable.NotifyManager_vip_strFormatChat
		local strFormat = localizable.NotifyManager_vip_strFormat

		local notifyStrChat = stringUtils.format(strFormatChat, playerName)
		local notifyStr = stringUtils.format(strFormat, playerName)

		self:sendMsgToChat(notifyStrChat)		
		self:addMessage(notifyStr, 1, 1)
	end
end

function NotifyManager:receiveGoldEggCallback(event)
	-- required string playerName = 1; 	//玩家名字
	-- required int32 type = 2;			//资源id
	-- required int32 id = 3;
	-- required int32 num = 4;
	--
	--local eggDesc = {"银蛋","金蛋"}
	local eggDesc = localizable.NotifyManager_GoldEgg_eggDesc
	local eggInfo = event.data

    local commonReward = {}
    commonReward.type   = tonumber(eggInfo.type)
    commonReward.itemId = tonumber(eggInfo.id)
    commonReward.number = tonumber(eggInfo.num)

    local eggType = eggInfo.eggType
    local cardConfig = BaseDataManager:getReward(commonReward)

    if cardConfig == nil then
    	print("砸蛋砸出来的东西，本地配置表找不到")
    	return
    end

	local nameRGBValue = '#ff4ef5'
	if cardConfig.quality == 5 then
		nameRGBValue = '#ff9c00'
	end

	-- local rewarddesc = [[<p style="text-align:left margin:5px"><font color="#ffffff" fontSize="26">恭喜</font>
	-- 	<font color="#ff0000" fontSize="26">%s</font><font color="#ffffff" fontSize="26">在砸蛋活动中，砸开%s获得了</font><font color="]]..nameRGBValue..[[" fontSize="26">%s</font></p>]]

	-- local chatMsg = [[<p style="text-align:left margin:5px"><font color="#000000" fontSize="26">恭喜</font>
	-- 	<font color="#ff0000" fontSize="26">%s</font><font color="#000000" fontSize="26">在砸蛋活动中，砸开%s获得了</font><font color="]]..nameRGBValue..[[" fontSize="26">%s</font></p>]]

	local rewarddesc = localizable.NotifyManager_GoldEgg_rewarddesc
	local chatMsg 	 = localizable.NotifyManager_GoldEgg_chatMsg 

	local notifyStr = stringUtils.format(rewarddesc, eggInfo.playerName, eggDesc[eggType], nameRGBValue, cardConfig.name)

	local notifyStrChat = stringUtils.format(chatMsg, eggInfo.playerName, eggDesc[eggType], nameRGBValue, cardConfig.name)

	if cardConfig.quality == 5 then
		self:sendMsgToChat(notifyStrChat)
	end
	self:addMessage(notifyStr, 1, 1)
end

function NotifyManager:receiveNotifyCallback(event)
	--15 首次通关
	--16 排名上升

	local msgType = event.data.type
	local context = event.data.context
	local msgTab = string.split(context,',')
	
	if msgType == 15 then
		-- local strTemplete = [[<p style="text-align:left margin:5px"><font color="#ffffff" fontSize="26">
		-- %s完成后山第%d章节的首次通关，它将永久保存在排行榜中</font></p>]]
		-- local strTempleteChat = [[<p style="text-align:left margin:5px"><font color="#000000" fontSize="26">
		-- %s完成后山第%d章节的首次通关，它将永久保存在排行榜中</font></p>]]

		local strTemplete = localizable.NotifyManager_FationRank_strTemplete
		local strTempleteChat = localizable.NotifyManager_FationRank_strTempleteChat

		local notifyStr = stringUtils.format(strTemplete, msgTab[1], tonumber(msgTab[2]))
		local notifyStrChat = stringUtils.format(strTempleteChat, msgTab[1], tonumber(msgTab[2]))
		self:addMessage(notifyStr, 1, 1)
		self:sendMsgToChat(notifyStrChat)
	elseif msgType == 16 then
		-- local strTempleteChat = [[<p style="text-align:left margin:5px"><font color="#000000" fontSize="26">
		-- 在%s的带领下，%s后山第%d章节通关速度上升为第%d名</font></p>]]
		local strTempleteChat = localizable.NotifyManager_FationRank_strTempleteChat2
		local notifyStrChat = stringUtils.format(strTempleteChat, msgTab[1], msgTab[2], tonumber(msgTab[3]), tonumber(msgTab[4]))
		self:sendMsgToChat(notifyStrChat)		
	elseif msgType == 17 then
		-- local strTempleteChat = [[<p style="text-align:left margin:5px"><font color="#ffffff" fontSize="26">
		-- 第一名：%s帮派技压群雄，在本届帮派争锋战中一举夺魁，可喜可贺！</font></p>]]
		local strTempleteChat = localizable.NotifyManager_FationRank_strTempleteChat3
		local notifyStrChat = stringUtils.format(strTempleteChat, msgTab[1])
		self:addMessage(notifyStrChat, 1, 1)
	end
end



function NotifyManager:ShowServerChat(chat)
	if not tolua.isnull(self.serverChatLayer) then
		return
	end

	local currentScene = Public:currentScene()
    if currentScene.__cname == "FightResultScene" or currentScene.__cname == "FightScene" then
       return
    end

	self:RemoveServerChat()

	self.serverChatLayer = ServerChatLayer:new()
	self.serverChatLayer:setPosition(ccp(GameConfig.WS.width/2, 450))
	self.serverChatLayer:setZOrder(500)
	currentScene:addLayer(self.serverChatLayer)

    self.serverChatLayer:ShowText(notifyStr)
end



function NotifyManager:addServerChatNotify(name , content, vipLevel)

	local strFormat = [[<p style="text-align:left margin:5px"><font face = "simhei" color="#fffa7f" fontSize="22"> {p1} </font>
		<font face = "simhei" color="#ffffff" fontSize="22">：{p2}</font></p>]]


	local tSmileConfig = ChatManager:getSmileConfig()
    -- local szMSG = ChatManager:getPublicStr()
    -- local szInput = content
    local szInput = string.gsub(content, "([\\uE000-\\uF8FF]|\\uD83C[\\uDF00-\\uDFFF]|\\uD83D[\\uDC00-\\uDDFF])", "")

    -- 非系统信息则 需要处理html字符
    -- if message.roleId ~= 0 then
	szInput = szInput:gsub( "<", '&lt;')
	szInput = szInput:gsub( ">", '&gt;')
   	-- end

	print("content = ",content)
    for k, v in pairs(tSmileConfig) do
        szInput = string.gsub(szInput, k, v)
    end


	local notifyStr = stringUtils.format(strFormat, name , szInput)
	self:addServerChat(notifyStr, 1, 1, vipLevel)
end


function NotifyManager:RemoveServerChat()
	if not tolua.isnull(self.serverChatLayer) then
		self.serverChatLayer:removeFromParent(true)
		-- Public:currentScene():removeLayer(self.serverChatLayer)
	end
	self.serverChatLayer = nil
end

function NotifyManager:addServerChat(disContent, disTimes, temp, vipLevel)
	local showTime		= disTimes or 1

	local len = self.serverChatArray:length()
	
	if len >= 10 then
		print("---NotifyManager:addMessag 已达到最大10条 不在添加，优先级高的不加限制")
		return
	end

	local msgNode = {
		content  = disContent,
		times 	 = showTime,
		vipLevel = vipLevel
	}

	self.serverChatArray:push(msgNode)


	if self.serverChatLayer == nil then
		local msgNode = self.serverChatArray:front()
		print("msgNode = ", msgNode)
		if msgNode then
			print("msgNode.content 11 = ", msgNode.content)
			msgNode.times = msgNode.times - 1
			self:displayServerChat(msgNode.content, msgNode.vipLevel)
		end
	end
end

--added by wuqi
function NotifyManager:addTuhaoChatNotify(name , content, vipLevel)
	
    if not CommonManager:isTuhao() then
    	toastMessage("not tuhao")
    	return
    end

    local function requestChat()
		local tSmileConfig = ChatManager:getSmileConfig()
	    local szInput = string.gsub(content, "([\\uE000-\\uF8FF]|\\uD83C[\\uDF00-\\uDFFF]|\\uD83D[\\uDC00-\\uDDFF])", "")
		
		local Msg = {
			EnumChatType.VipDeclaration,
			szInput,
			NULL,
			0,
		}
		print("sendPublic",Msg)
		ChatManager:send(Msg)
	end
		
    if CommonManager:getTuhaoFreeTimes() > 0 then
    	requestChat()
    else
    	if CommonManager:getTuhaoItemNum() > 0 then
    		requestChat()
    	else
    		local item = ItemData:objectByID(CommonManager:getTuhaoItemId())
    		toastMessage(stringUtils.format(localizable.common_vip_tuhao_not_enough, item.name))
    		--toastMessage(localizable.common_vip_tuhao_not_enough)
    	end
    end
	
	--self:sendMsgToChat(notifyStr)
	--self:addMessage(notifyStr, 1, 1)
end


--added by wuqi
function NotifyManager:addTuhaoChat(disContent, disTimes, name, vipLevel)
	local showTime = disTimes or 1

	local strFormat = [[<p style="text-align:left margin:5px"><font face = "simhei" color="#fffa7f" fontSize="22"> {p1} </font>
		<font face = "simhei" color="#ffffff" fontSize="22">：{p2}</font></p>]]

	local tSmileConfig = ChatManager:getSmileConfig()
    local szInput = string.gsub(disContent, "([\\uE000-\\uF8FF]|\\uD83C[\\uDF00-\\uDFFF]|\\uD83D[\\uDC00-\\uDDFF])", "")

	szInput = szInput:gsub( "<", '&lt;')
	szInput = szInput:gsub( ">", '&gt;')

    for k, v in pairs(tSmileConfig) do
        szInput = string.gsub(szInput, k, v)
    end


	local notifyStr = stringUtils.format(strFormat, name , szInput)
	--self:addServerChat(notifyStr, 1, 1, vipLevel)

	local len = self.tuhaoChatArray:length()

	if len >= 10 then
		return
	end

	local msgNode = {
		content  = notifyStr,
		times 	 = disTimes,
		vipLevel = vipLevel
	}

	self.tuhaoChatArray:push(msgNode)

	if self.tuhaoChatLayer == nil then
		local msgNode = self.tuhaoChatArray:front()
		print("msgNode = ", msgNode)
		if msgNode then
			print("msgNode.content 11 = ", msgNode.content)
			msgNode.times = msgNode.times - 1
			self:displayTuhaoChat(msgNode.content, msgNode.vipLevel)
			print("%%%%%%%%%%%", msgNode.vipLevel)

			print("%%%%%%%%%%%", msgNode.vipLevel)
		end
	end
end

--added by wuqi
function NotifyManager:displayTuhaoChat(notifyStr, vipLevel)
	local currentScene = Public:currentScene()
	--只在非战斗场景显示
    --if currentScene.__cname == "FightResultScene" or currentScene.__cname == "FightScene" then
    if currentScene.__cname ~= "HomeScene" then
       return
    end

    local layer = currentScene.menu_layer
    if layer == nil then
    	return
    end
    
    if self.tuhaoChatLayer == nil then
		self.tuhaoChatLayer = TuhaoChatLayer:new()
		self.tuhaoChatLayer:setZOrder(500)
		self.tuhaoChatLayer:setVipLevel(vipLevel)
		self.tuhaoChatLayer:ShowText(notifyStr)
		self.tuhaoChatLayer:setTouchEnabled(false)
		self.tuhaoChatLayer:setPosition(ccp(GameConfig.WS.width/2, 466))
		layer:addLayer(self.tuhaoChatLayer)
	end
end

--added by wuqi
function NotifyManager:displayTuhaoChatCompelete()
	self:RemoveTuhaoChat()
	if self.tuhaoChatArray:length() == 0 then
		return
	end
	--否还有公告
	local msgNode = self.tuhaoChatArray:front()
	while self.tuhaoChatArray:length() > 0 and msgNode == nil do
		self.tuhaoChatArray:popFront()
		msgNode = self.tuhaoChatArray:front()
	end
	if self.tuhaoChatArray:length() == 0 or msgNode == nil then
		--print("广播播完了")
		return
	end

	print("msgNode.times = ", msgNode.times)
	if msgNode.times > 0 then
		msgNode.times = msgNode.times - 1
		self:displayTuhaoChat(msgNode.content, msgNode.vipLevel)
	else
		self.tuhaoChatArray:popFront()
		self:displayTuhaoChatCompelete()
	end
end

--added by wuqi
function NotifyManager:RemoveTuhaoChat()
	if not tolua.isnull(self.tuhaoChatLayer) then
		self.tuhaoChatLayer:removeFromParent(true)
	end
	self.tuhaoChatLayer = nil
end


function NotifyManager:displayServerChat(notifyStr, vipLevel)
	local currentScene = Public:currentScene()
    if currentScene.__cname ~= "HomeScene" then
       return
    end
    local layer = currentScene.menu_layer
    if layer == nil then
    	return
    end
    if self.serverChatLayer == nil then
		self.serverChatLayer = ServerChatLayer:new()
		self.serverChatLayer:setZOrder(500)
		self.serverChatLayer:setVipLevel(vipLevel)
		self.serverChatLayer:ShowText(notifyStr)

		--local root_bg = TFDirector:getChildByPath(layer, 'bg')
		--root_bg:addChild(self.serverChatLayer)
		self.serverChatLayer:setPosition(ccp(GameConfig.WS.width/2, 466))
		layer:addLayer(self.serverChatLayer)
	end
end

function NotifyManager:displayServerChatCompelete()
	self:RemoveServerChat()
	if self.serverChatArray:length() == 0 then
		return
	end
	--否还有公告
	local msgNode = self.serverChatArray:front()
	while self.serverChatArray:length() > 0 and msgNode == nil do
		self.serverChatArray:popFront()
		msgNode = self.serverChatArray:front()
	end
	if self.serverChatArray:length() == 0 or msgNode == nil then
		--print("广播播完了")
		return
	end

	print("msgNode.times = ", msgNode.times)
	if msgNode.times > 0 then
		msgNode.times = msgNode.times - 1
		self:displayServerChat(msgNode.content, msgNode.vipLevel)

	else
		self.serverChatArray:popFront()

		self:displayServerChatCompelete()
	end

end

return NotifyManager:new()
