--
-- Author: Your Name
-- Date: 2015-01-19 20:39:10
--
local QBattleDialog = import("...QBattleDialog")
local QNightmareDialogWin = class("QNightmareDialogWin", QBattleDialog)

local QUIWidgetHeroHead = import("....widgets.QUIWidgetHeroHead")
local QBattleDialogAgainstRecord = import(".....ui.battle.QBattleDialogAgainstRecord")
local QUIWidgetItemsBox = import("....widgets.QUIWidgetItemsBox")

function QNightmareDialogWin:ctor(options,owner)
	local ccbFile = "ccb/Battle_Dialog_Victory2.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerNext", callback = handler(self, QNightmareDialogWin._onTriggerNext)},
		{ccbCallbackName = "onTriggerData", callback = handler(self, QNightmareDialogWin._onTriggerData)},
	}
	if owner == nil then 
		owner = {}
	end
	--设置该节点启用enter事件
	self:setNodeEventEnabled(true)
	QNightmareDialogWin.super.ctor(self,ccbFile,owner,callBacks)
	
	setShadow5(self._ccbOwner.tip)

	self._ccbOwner.sunwell_tips:setVisible(false)
	self._ccbOwner.node_star:setVisible(false)
	self._ccbOwner.node_title_over:setVisible(false)
	self._ccbOwner.node_title_lose:setVisible(not options.isWin)
	self._ccbOwner.node_light:setVisible(options.isWin)
	self._ccbOwner.node_title:setVisible(true)
	self._ccbOwner.node_title_win:setVisible(options.isWin)
	self._ccbOwner.tip:setString("")
	self._ccbOwner.money_baoji:setVisible(false)
	self._ccbOwner.node_blackrock:setVisible(false)
	self._ccbOwner.node_again:setVisible(false)
	
	self.info = options.info

	-- self._ccbOwner.tf_level2:setString(self.info.level)
	-- self._ccbOwner.tf_arena:setString("+"..self.info.arenaMoney)
	self._ccbOwner.node_normal:setVisible(true)
	self._ccbOwner.node_score:setVisible(false)
	self._ccbOwner.icon_exp:setVisible(false)
	self._ccbOwner.tf_exp:setVisible(false)
	self._ccbOwner.tf_money:setString("+0")
	self._ccbOwner.icon_money:setPositionX((self._ccbOwner.icon_money:getPositionX() + self._ccbOwner.icon_exp:getPositionX())/2 - 75)
	self._ccbOwner.tf_money:setPositionX((self._ccbOwner.tf_money:getPositionX() + self._ccbOwner.tf_exp:getPositionX())/2 - 75)
	

	-- if options.rankInfo ~= nil then
	--    self.rankInfo = options.rankInfo
	-- end

	--掉落物品显示
 	 self._itemsBox = {}
	local awards = {}
	local moneyCount = 0
	--节假日活动掉落
	if options.awards then
		if options.awards.dungeonPassAward ~= nil then
			for _, value in ipairs(options.awards.dungeonPassAward) do
				local typeName = remote.items:getItemType(value.type)
				if typeName == ITEM_TYPE.MONEY then
					moneyCount = value.count or 0
				else
					table.insert(awards, {id = value.id or 0, type = value.type, count = value.count or 0})
				end
			end
		end
		remote.nightmare:setChestResult(options.awards.bossBoxAward)
		-- if options.awards.bossBoxAward ~= nil then
		-- 	for _, value in ipairs(options.awards.bossBoxAward) do
		-- 		table.insert(awards, {id = value.id or 0, type = value.type, count = value.count or 0})
		-- 	end
		-- end
	end
	self._ccbOwner.tf_money:setString("+"..moneyCount)

	for index,value in ipairs(awards) do
    	self._itemsBox[index] = QUIWidgetItemsBox.new()
    	self._itemsBox[index]:setPromptIsOpen(true)
		if self._ccbOwner["item"..index] then
			self._ccbOwner["item"..index]:addChild(self._itemsBox[index])
			self._itemsBox[index]:setGoodsInfo(value.id,value.type,value.count)
		end
	end
	local awardsNum = #awards
	if awardsNum < 5 and awardsNum > 0 then
		self._ccbOwner.node_item:setPositionX(-(awardsNum - 1) * 96/2)
	end

	--初始化魂师头像
	self.heroBox = {}
	for index,value in pairs(self.info.heros) do
		local heroHead = QUIWidgetHeroHead.new()
		self._ccbOwner["hero_node" .. index]:addChild(heroHead)
		heroHead:setHeroSkinId(value.skinId)
		heroHead:setHero(value.actorId)
		heroHead:setLevel(value.level)
		heroHead:setBreakthrough(value.breakthrough)
        heroHead:setGodSkillShowLevel(value.godSkillGrade)
		heroHead:setStar(value.grade)
		heroHead:showSabc()
		table.insert(self.heroBox, heroHead)
	end
	local heroNum = #self.heroBox
	if heroNum < 4 and heroNum > 0 then
		self._ccbOwner.node_hero:setPositionX(-(heroNum - 1) * 147/2)
	end

	-- 中心对齐
	centerAlignBattleDialogVictory2(self._ccbOwner, self.heroBox, #self.heroBox, self._itemsBox, awardsNum)

  	self._audioHandler = app.sound:playSound("battle_complete")
    audio.stopBackgroundMusic()
	
	self._openTime = q.time()
end

function QNightmareDialogWin:onEnter()
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QNightmareDialogWin:onExit()
   	if self.prompt ~= nil then
   		self.prompt:removeItemEventListener()
   	end
end

function QNightmareDialogWin:_onTriggerNext()
  	app.sound:playSound("common_item")
	self:onClose()
end

function QNightmareDialogWin:_backClickHandler()
	if q.time() - self._openTime > 3.5 then
		self._ccbOwner:onChoose()
  	end
end

function QNightmareDialogWin:onClose()
	self._ccbOwner:onChoose()
	audio.stopSound(self._audioHandler)
end

function QNightmareDialogWin:_onCloseRankTop()
  if self.rankTop ~= nil then
     self.rankTop:close()
     self.rankTop = nil
  end
end

function QNightmareDialogWin:_onTriggerData(event)
    app.sound:playSound("common_small")
    QBattleDialogAgainstRecord.new({},{}) 
end

return QNightmareDialogWin