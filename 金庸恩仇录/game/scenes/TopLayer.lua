local TopLayer = class("TopLayer", function()
	return display.newNode()
end)

function TopLayer:ctor(isOther)
	self:setNodeEventEnabled(true)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node
	if isOther ~= nil and isOther == true then
		node = CCBuilderReaderLoad("public/top_frame_other.ccbi", proxy, self._rootnode)
	else
		node = CCBuilderReaderLoad("public/top_frame.ccbi", proxy, self._rootnode)
	end
	node:setPosition(display.cx, display.height)
	self:addChild(node)
	self.toplayerSize = self._rootnode.tag_top_size:getContentSize()
	local bottom = require("game.scenes.BottomLayer").new(true)
	self:addChild(bottom)
	self.bottomSize = bottom:getContentSize()
	self.battlePoint = game.player.m_battlepoint
	self:setBattlePoint(self.battlePoint)
	if isOther then
		self.tili = game.player:getStrength()
		self.naili = game.player:getNaili()
		self:setTili(self.tili)
		self:setNaili(self.naili)
	else
		self.gold = game.player.m_gold
		self.silver = game.player.m_silver
		self:setGodNum(self.gold)
		self:setSilver(self.silver)
	end
	self.voiceBg = self._rootnode.tag_voice_bg
	self.infoBg = self._rootnode.tag_info_bar
	local broadcastBg = self._rootnode.broadcast_tag
	if broadcastBg ~= nil and self._broadcast == nil then
		game.broadcast:reSet(broadcastBg)
		self._broadcast = game.broadcast
	end
	
end

function TopLayer:onEnter()
	if self._rootnode.nowTimeLabel then
		self._rootnode.nowTimeLabel:setString(GetSystemTime())
		self._rootnode.nowTimeLabel:schedule(function()
			self._rootnode.nowTimeLabel:setString(GetSystemTime())
		end,
		60)
	end
end

function TopLayer:initBroadcast()
	local broadcastBg = self._rootnode.broadcast_tag
	game.broadcast:reSet(broadcastBg)
	self._broadcast = game.broadcast
end


function TopLayer:getVoiceSize()
	return self.voiceBg:getContentSize()
end

function TopLayer:setInfoBgVisible(visible)
	self.infoBg:setVisible(visible)
end

function TopLayer:updateBroadcastLevelUp()
	if self._broadcast ~= nil then
		self._broadcast:showHeroLevelUp()
	end
end

function TopLayer:updateBroadcastGetHero()
	if self._broadcast ~= nil then
		self._broadcast:showPlayerGetHero()
	end
end

function TopLayer:getTopLayerContentSize(...)
	return self.toplayerSize
end

function TopLayer:getBottomContentSize(...)
	return self.bottomSize
end

function TopLayer:setBattlePoint(num)
	self.battlePoint = num
	game.player.m_battlepoint = num
	self._rootnode.zhandouliLabel:setString(num)
end

function TopLayer:setGodNum(num)
	self.gold = num
	if self._rootnode.goldLabel ~= nil then
		self._rootnode.goldLabel:setString(num)
	end
	game.player:setGold(num)
end

function TopLayer:setSilver(num)
	self.silver = num
	if self._rootnode.silverLabel ~= nil then
		self._rootnode.silverLabel:setString(num)
	end
	game.player.m_silver = num
end

function TopLayer:setTili(num)
	dump(num)
	self.tili = num
	game.player.m_strength = self.tili
	self:updateTiliLbl()
end

function TopLayer:updateTiliLbl()
	if self._rootnode.tili_Label ~= nil then
		self._rootnode.tili_Label:setString(game.player.m_strength)
	end
end

function TopLayer:setNaili(num)
	self.naili = num
	if self._rootnode.naili_Label ~= nil then
		self._rootnode.naili_Label:setString(num)
	end
	game.player.m_energy = self.naili
end

function TopLayer:addBattlePoint(num)
	self:setBattlePoint(self.battlePoint + num)
end

function TopLayer:addGodNum(num)
	self:setGodNum(self.gold + num)
end

function TopLayer:addSilver(num)
	self:setSilver(self.silver + num)
end

function TopLayer:subBattlePoint(num)
	self:setBattlePoint(self.battlePoint - num)
end

function TopLayer:subGodNum(num)
	self:setGodNum(self.gold - num)
end

function TopLayer:subSilver(num)
	self:setSilver(self.silver - num)
end

function TopLayer:getContentSize(...)
	return self._rootnode.topFrameNode:getContentSize()
end

return TopLayer