--
-- Author: Your Name
-- Date: 2015-01-19 20:39:10
--
local QBattleDialogBaseFightEnd = import(".QBattleDialogBaseFightEnd")
local QFriendDialogWin = class("QFriendDialogWin", QBattleDialogBaseFightEnd)

function QFriendDialogWin:ctor(options, owner)
	print("<<<QFriendDialogWin>>>")
	--设置该节点启用enter事件
	self:setNodeEventEnabled(true)
	QFriendDialogWin.super.ctor(self, options, owner)
	self._audioHandler = app.sound:playSound("battle_complete")
	
	local isWin = options.isWin

	if isWin then
		local exp = options.exp

		self._ccbOwner.node_bg_win:setVisible(true)

	    self._ccbOwner.node_win_client:setVisible(true)

	    self._ccbOwner.node_win_text_title:setVisible(true)
	    self:setWinTextTitle({"zhan", "dou", "sheng", "li"})
	    -- hero head
		-- self._ccbOwner.ly_hero_head_size:setVisible(false)
		self._ccbOwner.node_hero_head:setVisible(true)
	   	self:setHeroInfo(exp)
	   	-- hero head 中心对齐
	    local teamHero = remote.teamManager:getActorIdsByKey(self.teamName, 1)
	    local heroHeadCount = #teamHero
		if heroHeadCount > 0 then
			local heroTotalWidth = self.heroHeadWidth * (heroHeadCount - 1) + (self.heroBox[1]:getSize().width * 1.5)
			self._ccbOwner.node_hero_head:setPositionX( self._ccbOwner.node_hero_head:getPositionX() + (self._ccbOwner.ly_hero_head_size:getContentSize().width - heroTotalWidth) / 2 )
		end
	else
		makeNodeFromNormalToGray(self._ccbOwner.node_bg_mvp)

		self._ccbOwner.node_bg_lost:setVisible(true)
		self._ccbOwner.node_lost_client:setVisible(true)

		self:hideAllPic()
		self:chooseBestGuide()
	end
end

function QFriendDialogWin:onEnter()
    -- self.prompt = app:promptTips()
    -- self.prompt:addItemEventListener(self)
end

function QFriendDialogWin:onExit()
   	-- if self.prompt ~= nil then
   	-- 	self.prompt:removeItemEventListener()
   	-- end
end

function QFriendDialogWin:_onTriggerNext()
  	app.sound:playSound("common_item")
	self:_onClose()
end

return QFriendDialogWin