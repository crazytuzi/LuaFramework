--
-- Author: Kumo.Wang
-- Date: Fri Jun  3 15:25:55 2016
-- Boss的详细信息
--
local QUIDialog = import(".QUIDialog")
local QUIDialogSocietyDungeonBossInfo = class("QUIDialogSocietyDungeonBossInfo", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QSocietyDungeonArrangement = import("...arrangement.QSocietyDungeonArrangement")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QVIPUtil = import("...utils.QVIPUtil")

QUIDialogSocietyDungeonBossInfo.EVENT_EXIT = "EVENT_EXIT"

function QUIDialogSocietyDungeonBossInfo:ctor(options)
	local ccbFile = "ccb/Dialog_society_fuben_boss.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerOK", callback = handler(self, QUIDialogSocietyDungeonBossInfo._onTriggerOK)},
		{ccbCallbackName = "onTriggerPlus", callback = handler(self, QUIDialogSocietyDungeonBossInfo._onTriggerPlus)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogSocietyDungeonBossInfo._onTriggerClose)},
	}
	QUIDialogSocietyDungeonBossInfo.super.ctor(self, ccbFile, callBacks, options)

	self.isAnimation = true
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._curHp = options.bossHp
	self._curHurt = options.allHurt or 0
	self._chapter = options.chapter
	self._wave = options.wave
	self._activityBuffList = options.activityBuffList

	self._fightCounts = 0

	self._scoietyWaveConfig = QStaticDatabase.sharedDatabase():getScoietyWave(self._wave, self._chapter)
	self._bossId = self._scoietyWaveConfig.boss
	self._bossLevel = self._scoietyWaveConfig.levels
	self._little_monster = self._scoietyWaveConfig.little_monster

	local function addMaskLayer(ccb, mask)
	    local width = ccb:getContentSize().width
	    local height = ccb:getContentSize().height
	    local maskLayer = CCLayerColor:create(ccc4(0,0,0,150), width, height)
	    maskLayer:setAnchorPoint(ccp(0, 0.5))
	    maskLayer:setPosition(ccp(0, -height/2))

	    local ccclippingNode = CCClippingNode:create()
	    ccclippingNode:setStencil(maskLayer)
	    ccb:retain()
	    ccb:removeFromParent()
	    ccb:setPosition(ccp(0, 0))
	    ccclippingNode:addChild(ccb)
	    ccb:release()

	    mask:addChild(ccclippingNode)
	    return maskLayer
	end
	self._expMask = addMaskLayer(self._ccbOwner.sp_hp, self._ccbOwner.sp_mask)

	self:_init()
end

function QUIDialogSocietyDungeonBossInfo:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogSocietyDungeonBossInfo:viewDidAppear()
	QUIDialogSocietyDungeonBossInfo.super.viewDidAppear(self)

	self.unionProxy = cc.EventProxy.new(remote.union)
    self.unionProxy:addEventListener(remote.union.SOCIETY_BUY_FIGHT_COUNT_SUCCESS, handler(self, self.updateUnionHandler))
end

function QUIDialogSocietyDungeonBossInfo:viewWillDisappear()
	QUIDialogSocietyDungeonBossInfo.super.viewWillDisappear(self)

	self.unionProxy:removeAllEventListeners()
end

function QUIDialogSocietyDungeonBossInfo:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogSocietyDungeonBossInfo:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	self:dispatchEvent({name = QUIDialogSocietyDungeonBossInfo.EVENT_EXIT})

	app.sound:playSound("common_cancel")
   	self:playEffectOut()
end

function QUIDialogSocietyDungeonBossInfo:_exitFromBattle()
	-- local bossList = remote.union:getConsortiaBossList(self._chapter)
	-- if not bossList or #bossList == 0 then return end
	-- for _, value in pairs(bossList) do
	-- 	if value.chapter == self._chapter and value.wave == self._wave then
	-- 		self._curHp = value.bossHp
	-- 	end
	-- end
 --    self:updateHp()
end

function QUIDialogSocietyDungeonBossInfo:_onTriggerOK(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_ok) == false then return end
	-- if self._canFight then
	if self._fightCounts > 0 and self:_isCanFight() then
		remote.union:setFightWave(self._wave)
		self:_gotoTeamArrangement()
	else
		if self._curHp == 0 then
			app.tip:floatTip("魂师大人，BOSS已被击败了")
			return
		end

		if self._fightCounts <= 0 then
			self:_onTriggerPlus()
			return
		end
		app.tip:floatTip("魂师大人，无法攻击")
	end
end

function QUIDialogSocietyDungeonBossInfo:_gotoTeamArrangement()
    local societyDungeonArrangement = QSocietyDungeonArrangement.new({ chapter = self._chapter, wave = self._wave, 
    	bossId = self._bossId, bossHp = self._curHp, bossLevel = self._bossLevel, little_monster = self._little_monster, activityBuffList = self._activityBuffList } )
    -- self:viewAnimationOutHandler()
    self:popSelf()
	
	local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.SOCIETYDUNGEON_ATTACK_TEAM)
    remote.teamManager:saveTeamToLocal(teamVO, remote.teamManager.SOCIETYDUNGEON_ATTACK_TEAM)

    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
        options = {arrangement = societyDungeonArrangement, backCallback = function()
                if remote.union:checkHaveUnion() == false then
					app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
                end
            end}})

end

function QUIDialogSocietyDungeonBossInfo:_onTriggerPlus(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_plus) == false then return end
	if remote.union:checkUnionDungeonIsOpen(true) == false then
		return
	end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCountBase", options = {cls = "QBuyCountUnionInstance"}}, {isPopCurrentDialog = false})
end

function QUIDialogSocietyDungeonBossInfo:updateUnionHandler( event )
	if event.name == remote.union.SOCIETY_BUY_FIGHT_COUNT_SUCCESS then
		local userConsortia = remote.user:getPropForKey("userConsortia")
		self._fightCounts = userConsortia.consortia_boss_fight_count
		self:updateFightCount(self._fightCounts)
		-- self:updateBtn()
	end
end

function QUIDialogSocietyDungeonBossInfo:_init()
	local isFinalBoss = remote.union:checkIsFinalWave(self._chapter, self._wave)
	-- 初始化标题
	local character = QStaticDatabase.sharedDatabase():getCharacterByID(self._bossId)
	-- self._ccbOwner.frame_tf_title = setShadow5(self._ccbOwner.frame_tf_title)
	self._ccbOwner.frame_tf_title:setString(character.name)

	local scale = self._scoietyWaveConfig.boss_small_scale or 1
	-- 初始化BOSS形象
 	if not self._avatarHero then
 		self._ccbOwner.node_avatar:setScaleX( -scale )
 		self._ccbOwner.node_avatar:setScaleY( scale )
	 	self._avatarHero = QUIWidgetActorDisplay.new(self._bossId)
		self._ccbOwner.node_avatar:addChild(self._avatarHero)
	end
	if isFinalBoss then
		self._avatarHero:setOpacity(UNION_DUNGEON_MAX_BOSS_OPACITY)
	end

	-- 刷新BOSS血条
	self:updateHp()

	-- 初始化可挑战BOSS次数
	local userConsortia = remote.user:getPropForKey("userConsortia")
	self._fightCounts = userConsortia.consortia_boss_fight_count
	self:updateFightCount(self._fightCounts)

	-- 初始化击杀奖励说明
	local tbl = QStaticDatabase.sharedDatabase():getluckyDrawById(self._scoietyWaveConfig.reward_personal)
	-- QPrintTable(tbl)
	self._ccbOwner.tf_explain:setString("伤害越高，奖励越多，击杀者可额外获得"..tbl[1].count.."宗门贡献")
	self._ccbOwner.tf_killed_award:setString("宗门经验 + "..self._scoietyWaveConfig.sociaty_exp)
	self._ccbOwner.tf_fight_award:setString("基础奖励："..self._scoietyWaveConfig.battle_reward)
	local item = QUIWidgetItemsBox.new()
	item:setPromptIsOpen(true)
	self._ccbOwner.node_fight_award_icon:addChild(item)
	item:setGoodsInfo(nil, "consortiaMoney", 0)

	if isFinalBoss then
		self._ccbOwner.node_kill_award:setVisible(false)
		self._ccbOwner.tf_explain:setString("伤害越高，奖励越多")
		self._ccbOwner.node_challange_award:setPositionY(20)
	end
	-- 初始化挑战按钮
	-- self:updateBtn()

	-- 初始化BOSS说明
	tbl = QStaticDatabase.sharedDatabase():getScoietyWave(self._wave, self._chapter)
	if tbl and tbl.wenan_type then
		self._ccbOwner.tf_boss_explain:setString(tbl.wenan_type)
	else
		self._ccbOwner.tf_boss_explain:setString("")
	end
end

function QUIDialogSocietyDungeonBossInfo:updateBtn()
	-- if self._fightCounts ~= 0 and self:_isCanFight() then
	-- 	-- makeNodeFromGrayToNormal(self._ccbOwner.node_btn_ok)
	-- 	-- self._ccbOwner.btn_ok:setEnabled(true)
	-- 	self._canFight = true
	-- else
	-- 	-- makeNodeFromNormalToGray(self._ccbOwner.node_btn_ok)
	-- 	-- self._ccbOwner.btn_ok:setEnabled(false)
	-- 	self._canFight = false
	-- end
end

function QUIDialogSocietyDungeonBossInfo:updateHp( curHp )
	local isFinalBoss = remote.union:checkIsFinalWave(self._chapter, self._wave)

	if curHp then self._curHp = curHp end
	local curHp = 0
	local totalHp = self:getTotalHp( self._bossId, self._bossLevel )
	local curUnit = ""
	local totalUnit = ""
	local sx = self._curHp / totalHp
	-- self._ccbOwner.tf_hp:setString("生命值："..self._curHp.." / "..totalHp)
	if isFinalBoss then
		curHp, curUnit = q.convertLargerNumber(self._curHurt)
		totalHp, totalUnit = q.convertLargerNumber(totalHp)
		self._ccbOwner.tf_hp:setString(curHp..(curUnit or "").." / ???")
		self._expMask:setScaleX(1)
	else
		curHp, curUnit = q.convertLargerNumber(self._curHp)
		totalHp, totalUnit = q.convertLargerNumber(totalHp)
		self._expMask:setScaleX( sx )
		self._ccbOwner.tf_hp:setString(curHp..(curUnit or "").." / "..totalHp..(totalUnit or ""))
	end
end

function QUIDialogSocietyDungeonBossInfo:getTotalHp( bossId, bossLevel )
	if not self._bossId or not self._bossLevel then return 0 end

	if not bossId then bossId = self._bossId end
	if not bossLevel then bossLevel = self._bossLevel end

	local characterData = QStaticDatabase.sharedDatabase():getCharacterDataByID( bossId, bossLevel )
	local totalHp = characterData.hp_value + characterData.hp_grow * characterData.npc_level

	return totalHp
end

function QUIDialogSocietyDungeonBossInfo:updateFightCount( fightCount )
	self._fightCounts = fightCount
	self._ccbOwner.tf_fight_count:setString( fightCount )

    local buyCount = remote.user.userConsortia.consortia_boss_buy_count or 0
	if remote.user.userConsortia.consortia_boss_buy_at ~= nil and q.refreshTime(remote.user.c_systemRefreshTime) > remote.user.userConsortia.consortia_boss_buy_at then
		buyCount = 0
	end
	local totalVIPNum = QVIPUtil:getCountByWordField("sociaty_chapter_times", QVIPUtil:getMaxLevel())
	local totalNum = QVIPUtil:getCountByWordField("sociaty_chapter_times")
	self._ccbOwner.btn_plus:setVisible(totalVIPNum > totalNum or totalNum > buyCount)
end

function QUIDialogSocietyDungeonBossInfo:_isCanFight()
	-- nanzhang: 建议把这个函数搬到QUnion里去，因为这个判断应该比较常用
	local bossList = remote.union:getConsortiaBossList(self._chapter)
	if not bossList or #bossList == 0 then return true end

	-- local isPreBossDead = false

	for _, value in pairs(bossList) do
		if value.wave == self._wave and value.bossHp == 0 then
			return false
		end
		-- if value.wave == self._wave - 1 then
		-- 	if value.bossHp == 0 then
		-- 		isPreBossDead = true
		-- 	end
		-- end
	end

	-- if isPreBossDead or self._wave == 1 then return true end

	return true
end

return QUIDialogSocietyDungeonBossInfo