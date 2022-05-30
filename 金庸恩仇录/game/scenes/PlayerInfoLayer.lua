local PlayerInfoLayer = class("PlayerInfoLayer", function (mainMenuNode)
	return require("utility.MyLayer").new({name = "PlayerInfoLayer"})
end)

function PlayerInfoLayer:ctor(mainMenuNode, cb)
	self:setNodeEventEnabled(true)
	self.playerInfoNode = mainMenuNode
	self:setNodeEventEnabled(true)
	self.schedulePlayerInfo = require("framework.scheduler")
	local proxy = CCBProxy:create()
	local ccbReader = proxy:createCCBReader()
	self._rootNode = self._rootNode or {}
	
	local node = CCBuilderReaderLoad("ccbi/mainmenu/playerinfo.ccbi", proxy, self._rootNode)
	node:setPosition(display.cx, display.height * 0.53)
	self:addChild(node)
	
	--关闭按钮
	self._rootNode["tag_close"]:addHandleOfControlEvent(function (sender,eventName)
		if cb ~= nil then
			cb()
		end
		if self.playerinfoTextscheduler then
			self.schedulePlayerInfo.unscheduleGlobal(self.playerinfoTextscheduler)
			self.playerinfoTextscheduler = nil
		end
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	--确定按钮
	self._rootNode["tag_ok_btn"]:addHandleOfControlEvent(function (sender,eventName)
		sender:runAction(transition.sequence({
		CCScaleTo:create(0.08, 0.8),
		CCCallFunc:create(function ()
			if cb ~= nil then
				cb()
			end
			if self.playerinfoTextscheduler then
				self.schedulePlayerInfo.unscheduleGlobal(self.playerinfoTextscheduler)
				self.playerinfoTextscheduler = nil
			end
			self:removeSelf()
		end),
		CCScaleTo:create(0.1, 1.2),
		CCScaleTo:create(0.02, 1)
		}))
	end,
	CCControlEventTouchUpInside)
	
	local playerHead = self._rootNode.tag_player_icon
	headImgName = game.player:getPlayerIconName()
	playerHead:setDisplayFrame(display.newSpriteFrame(headImgName))
	self._rootNode.tag_lv:setString(game.player.m_level)
	self._rootNode.tag_vip:setString(game.player.m_vip)
	self:ReqPlayerInfo()
	
end


function PlayerInfoLayer:ReqPlayerInfo(...)
	RequestHelper.getPlayerInfo({
	callback = function (data)
		dump(data)
		if #data["0"] > 0 then
			show_tip_label(data["0"])
			return
		end
		local info = data["1"]
		--dump(self._rootNode)
		self._rootNode.text_shangzhen:setString(info.fmtCnt[1] .. "/" .. info.fmtCnt[2])
		self._rootNode.text_gold:setString(info.gold)
		self._rootNode.text_silver:setString(info.silver)
		self._rootNode.text_xiahun:setString(info.soul)
		self._rootNode.text_hunyu:setString(info.hunYuVal)
		self._rootNode.text_lingyu:setString(info.petSoul or 0)
		self._rootNode.tag_tili:setString(info.physVal .. "/" .. info.physValLimit)
		self._rootNode.tag_naili:setString(info.resisVal .. "/" .. info.resisValLimit)
		local playerID = "(ID:" .. game.player:getPlayerID() .. ")"
		
		local text = ui.newTTFLabelWithOutline({
		text = game.player.m_name,
		font = FONTS_NAME.font_fzcy,
		size = 28,
		color = FONT_COLOR.PLAYER_NAME,
		outlineColor = display.COLOR_BLACK,
		align = ui.TEXT_ALIGN_LEFT
		})
		
		ResMgr.replaceKeyLableEx(text, self._rootNode, "player_name", 0, 0)
		text:align(display.LEFT_CENTER)
		
		local nx, ny = self._rootNode.player_name:getPosition()
		local playerIDLabel = ui.newTTFLabel({
		text = playerID,
		x = nx + text:getContentSize().width + 5,
		y = ny,
		font = FONTS_NAME.font_fzcy,
		size = 24,
		color = cc.c3b(100, 100, 100),
		align = ui.TEXT_ALIGN_LEFT
		})
		
		playerIDLabel:align(display.LEFT_CENTER)
		self._rootNode.player_name:getParent():addChild(playerIDLabel)
		
		game.player:updateMainMenu({
		tili = info.physVal,
		naili = info.resisVal
		})
		
		self.playerInfoNode.label_tili:setString(game.player.m_strength .. "/" .. game.player.m_maxStrength)
		self.playerInfoNode.label_naili:setString(game.player.m_energy .. "/" .. game.player.m_maxEnergy)
		self.tilihuifu_time = tonumber(info.physValTime[1])
		self.tilihuiman_time = tonumber(info.physValTime[2])
		self.nailihuifu_time = tonumber(info.resisValTime[1])
		self.nailihuiman_time = tonumber(info.resisValTime[2])
		self:Update()
	end
	})
end


function PlayerInfoLayer:Update()
	local function update()
		if self.tilihuifu_time > 0 then
			self.tilihuifu_time = self.tilihuifu_time - 1
			local text = format_time(self.tilihuifu_time)
			self._rootNode.tilihuifu_time:setString(text)
		end
		if 0 < self.tilihuiman_time then
			self.tilihuiman_time = self.tilihuiman_time - 1
			local text = format_time(self.tilihuiman_time)
			self._rootNode.tilihuiman_time:setString(text)
		end
		if 0 < self.nailihuifu_time then
			self.nailihuifu_time = self.nailihuifu_time - 1
			local text = format_time(self.nailihuifu_time)
			self._rootNode.nailihuifu_time:setString(text)
		end
		if 0 < self.nailihuiman_time then
			self.nailihuiman_time = self.nailihuiman_time - 1
			local text = format_time(self.nailihuiman_time)
			self._rootNode.nailihuiman_time:setString(text)
		end
		
		if self.tilihuifu_time == 0 and 0 < self.tilihuiman_time then
			self.schedulePlayerInfo.unscheduleGlobal(self.playerinfoTextscheduler)
			self:ReqPlayerInfo()
		elseif self.nailihuifu_time == 0 and 0 < self.nailihuiman_time then
			self.schedulePlayerInfo.unscheduleGlobal(self.playerinfoTextscheduler)
			self.ReqPlayerInfo()
		end
	end
	
	self.playerinfoTextscheduler = self.schedulePlayerInfo.scheduleGlobal(update, 1, false)
	--dump(self.playerinfoTextscheduler)
	
end

function PlayerInfoLayer:onExit()
	if self.playerinfoTextscheduler then
		self.schedulePlayerInfo.unscheduleGlobal(self.playerinfoTextscheduler)
		self.playerinfoTextscheduler = nil
	end
end

return PlayerInfoLayer