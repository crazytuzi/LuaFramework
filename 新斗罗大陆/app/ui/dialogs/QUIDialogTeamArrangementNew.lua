

local QUIDialog = import(".QUIDialog")
local QUIDialogTeamArrangementNew = class("QUIDialogTeamArrangementNew", QUIDialog)
local QUIWidgetHeroBattleArrayNew = import("..widgets.QUIWidgetHeroBattleArrayNew")
local QUIWidgetHeroBattleArrayButton = import("..widgets.QUIWidgetHeroBattleArrayButton")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")
local QUserData = import("...utils.QUserData")
local QUIViewController = import("..QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetHeroBattleArrayAvatar = import("..widgets.QUIWidgetHeroBattleArrayAvatar")
local QUIWidgetHeroSmallFrame = import(".QUIWidgetHeroSmallFrame")
local QBaseArrangementWithDataHandle = import("...arrangement.QBaseArrangementWithDataHandle")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetHeroBattleArrayForce = import("..widgets.QUIWidgetHeroBattleArrayForce")
local QUIWidgetHeroBattleArrayFighterInfoCell = import("..widgets.QUIWidgetHeroBattleArrayFighterInfoCell")


local SWITCH_DISTANCE = 1340
local SWITCH_DURATION = 0.3
local DELAY_DURATION = 0.05

local AVATAR_SCALE = 0.82

QUIDialogTeamArrangementNew.BUTTON_TYPE =
{
	ADD_PROP = 1,
	ONE_KEY_REFRESH = 2,
	SOUL_SPIRIT_ON = 3,
	GOD_ARM_ON = 4,

	SKIP_BATTLE = 99,
}


function QUIDialogTeamArrangementNew:ctor(options)
	local ccbFile = "ccb/Dialog_HeroBattleArray_new.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClickPVP", callback = handler(self, self._onTriggerClickPVP)},
		{ccbCallbackName = "onTriggerSkipFight", callback = handler(self, self._onTriggerSkipFight)},		
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},		
		{ccbCallbackName = "onTriggerFight", callback = handler(self, self._onTriggerFight)},		
	}
	QUIDialogTeamArrangementNew.super.ctor(self,ccbFile,callBacks,options)

    CalculateUIBgSize(self._ccbOwner.sp_array_bg_1)
    CalculateUIBgSize(self._ccbOwner.sp_array_bg_2)
    CalculateUIBgSize(self._ccbOwner.node_helper,1280)

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page and page.setAllUIVisible then page:setAllUIVisible(false) end
    if page and page.setScalingVisible then page:setScalingVisible(false) end

	if FinalSDK.isHXShenhe() then
        page:setScalingVisible(false)
    end
    self._force = 0
	self._arrangement = options.arrangement
	self._unlockedSlot = self._arrangement:getUnlockSlots()
	self._buttonTypes = options.buttonTypes or {} --
	self._isFighter = options.isFighter or false --
	self._backCallback = options.backCallback
	self._fighterStr = options.fighterStr or "敌方队伍" --

	self._arrayAvatarNodeListCache = {}
	self._arrayAvatarNodeList = {}


	self:_initialization()

end

function QUIDialogTeamArrangementNew:viewDidAppear()
	QUIDialogTeamArrangementNew.super.viewDidAppear(self)
	self:addBackEvent(false)
    -- QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetHeroSmallFrame.EVENT_FORMATION_CLICK, self._onHeroSmallFrameClick, self)
end

function QUIDialogTeamArrangementNew:viewWillDisappear()
	QUIDialogTeamArrangementNew.super.viewWillDisappear(self)

    -- QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetHeroSmallFrame.EVENT_FORMATION_CLICK, self._onHeroSmallFrameClick, self)

	self:removeBackEvent()
	if self._forceUpdate then
		self._forceUpdate:stopUpdate()
		self._forceUpdate = nil
	end
    if self._widgetHeroArrayProxy then
	  	self._widgetHeroArrayProxy:removeAllEventListeners()
	  	self._widgetHeroArrayProxy = nil
	end
	if self._handleCombinedSkill then
		scheduler.unscheduleGlobal(self._handleCombinedSkill)
		self._handleCombinedSkill = nil
	end
	-- for i,v in ipairs(self._arrayAvatarNodeList) do
	-- 	v:release()
	-- end
	-- for i,v in ipairs(self._arrayAvatarNodeListCache) do
	-- 	v:release()
	-- end
	if self._eleanTextureScheduler ~= nil then
		scheduler.unscheduleGlobal(self._eleanTextureScheduler)
		self._eleanTextureScheduler = nil
	end
end

--初始化函数
function QUIDialogTeamArrangementNew:_initialization()
	self._selectIndex = 1

	--2.初始化下方选择控件
	self._widgetHeroArray = QUIWidgetHeroBattleArrayNew.new({})
	-- self._widgetHeroArray:setPositionY(122 - display.cy)
	self._ccbOwner.node_teamField:addChild(self._widgetHeroArray)

	self._widgetHeroArray:initButtonByTeamIndexIds(self._arrangement:getTeamIndexIds())

    self._widgetHeroArrayProxy = cc.EventProxy.new(self._widgetHeroArray)
    self._widgetHeroArrayProxy:addEventListener(QUIWidgetHeroBattleArrayNew.HERO_CHANGED, handler(self, self._onHeroSmallFrameClick))
    self._widgetHeroArrayProxy:addEventListener(QUIWidgetHeroBattleArrayNew.EVENT_SELECT_TAB, handler(self, self._onHeroChangedTab))
	self._forceUpdate = QTextFiledScrollUtils.new()

	self:_initAdditionBtn()
	self:_initForceWidget()
	self:_updateDisplayInfo()
	self:_refreshHeroArray()
	self:_updateArrVisible()


	local tbl = self._arrangement:getArrangeMarkTable()

	if self._arrangement:getBackPagePath(tbl.teamIndex) then
		self._ccbOwner["sp_array_bg_"..self._selectIndex]:setDisplayFrame(self._arrangement:getBackPagePath(tbl.teamIndex))
		CalculateUIBgSize(self._ccbOwner["sp_array_bg_"..self._selectIndex])
	end	

	if self._isFighter then
		self:_initEnemyFighterInfo()
	end
end

--初始化战斗力控件
function QUIDialogTeamArrangementNew:_initForceWidget()

	local _type = 2

	self._widgetForce = QUIWidgetHeroBattleArrayForce.new({_type = _type})
	self._widgetForce:addEventListener(QUIWidgetHeroBattleArrayForce.EVENT_CLICK_PVP_BUTTON, handler(self, self._onTriggerClickPVP))
	if _type == 1 then--单队直接放在上方
		self._ccbOwner.node_battle_fire:addChild(self._widgetForce)
	else
		self._ccbOwner.node_battle_fire1:addChild(self._widgetForce)
	end
	local force = self._arrangement:getTeamArrangeForceByTrialNum(1)
	self._widgetForce:setForce(force)
end

--初始化敌方玩家信息
function QUIDialogTeamArrangementNew:_initEnemyFighterInfo()
	self._fighterInfoTbl = {}
	local infos = self._arrangement:getEnemyFighterInfos()
	if not q.isEmpty(infos) then
		local num = #infos
		for i,v in ipairs(infos) do
			local widgetEnemyFighter = QUIWidgetHeroBattleArrayFighterInfoCell.new()
			widgetEnemyFighter:addEventListener(QUIWidgetHeroBattleArrayFighterInfoCell.EVENT_FIGHTRT_TEAM_CLICK, handler(self, self._onTiggerClickTeam))
			widgetEnemyFighter:addEventListener(QUIWidgetHeroBattleArrayFighterInfoCell.EVENT_FIGHTRT_INFO_CLICK, handler(self, self._onTiggerClickInfo))
			self._ccbOwner.node_top:addChild(widgetEnemyFighter)
			widgetEnemyFighter:setInfo(v , i , self._fighterStr..i)
			widgetEnemyFighter:setButtonStated(i == 1)
			table.insert(self._fighterInfoTbl , widgetEnemyFighter)
			local size = widgetEnemyFighter:getContentSize()
			local offside = widgetEnemyFighter:getContentSize().width * 0.9
			local start = offside *(0.5 - 0.5 * num) + 100
			widgetEnemyFighter:setPositionX(start + (i - 1) *offside)
			widgetEnemyFighter:setPositionY(-40)

		end
	end

end

function QUIDialogTeamArrangementNew:_updateFighterInfoDisplay()
	local trialNum = self._arrangement:getTrialNum()
	self:changeFighterInfoDisplay(trialNum)
end


function QUIDialogTeamArrangementNew:changeFighterInfoDisplay(idx)
	if not q.isEmpty(self._fighterInfoTbl) then
		for i,widgetEnemyFighter in ipairs(self._fighterInfoTbl or {}) do
			widgetEnemyFighter:setButtonStated(idx == i)
		end

	end
end

--初始化按钮
function QUIDialogTeamArrangementNew:_initAdditionBtn()
	self._ccbOwner.node_skip_fight:setVisible(false)

	self._topBtnList = {}
	self._leftBtnList = {}

	for i,v in ipairs(self._buttonTypes ) do
		if v == QUIDialogTeamArrangementNew.BUTTON_TYPE.ADD_PROP then
			local btn = QUIWidgetHeroBattleArrayButton.new({btnType = QUIDialogTeamArrangementNew.BUTTON_TYPE.ADD_PROP 
				,btnStr="加成",clickCallBack = handler(self, self._onTriggerHelperDetail) })
			self._ccbOwner.node_top_right:addChild(btn)
			table.insert(self._topBtnList ,btn )
		elseif  v == QUIDialogTeamArrangementNew.BUTTON_TYPE.ONE_KEY_REFRESH then

			local btn = QUIWidgetHeroBattleArrayButton.new({btnType = QUIDialogTeamArrangementNew.BUTTON_TYPE.ONE_KEY_REFRESH 
				,btnStr="一键换队",clickCallBack = handler(self, self._onTriggerChangeTeam) })
			self._ccbOwner.node_top_right:addChild(btn)
			table.insert(self._topBtnList ,btn )
		elseif  v == QUIDialogTeamArrangementNew.BUTTON_TYPE.SOUL_SPIRIT_ON then

			local btn = QUIWidgetHeroBattleArrayButton.new({btnType = QUIDialogTeamArrangementNew.BUTTON_TYPE.SOUL_SPIRIT_ON 
				, btnStr="上阵魂灵" ,visibleIndex = remote.teamManager.TEAM_INDEX_MAIN
				,clickCallBack = handler(self, self._onTriggerSoulInfo)})
			self._ccbOwner.node_left:addChild(btn)	
			table.insert(self._leftBtnList ,btn )
		elseif  v == QUIDialogTeamArrangementNew.BUTTON_TYPE.GOD_ARM_ON then
			local btn = QUIWidgetHeroBattleArrayButton.new({btnType = QUIDialogTeamArrangementNew.BUTTON_TYPE.GOD_ARM_ON 
				, btnStr="上阵神器" ,visibleIndex = remote.teamManager.TEAM_INDEX_GODARM
				,clickCallBack = handler(self, self._onTriggerGodarmInfo)})
			self._ccbOwner.node_left:addChild(btn)	
			table.insert(self._leftBtnList ,btn )
		elseif  v == QUIDialogTeamArrangementNew.BUTTON_TYPE.SKIP_BATTLE then
			self._ccbOwner.node_skip_fight:setVisible(true)
		end
	end

	for i,v in ipairs(self._topBtnList) do
		v:setPositionX(- i * 80)
	end

	for i,v in ipairs(self._leftBtnList) do
		v:setPositionX(60)
	end
end

function QUIDialogTeamArrangementNew:updateButtonVisible()
	local curTeamIdx = self._arrangement:getTeamIndex()

	for i,v in ipairs(self._topBtnList) do
		v:setVisibleByIndex(curTeamIdx)
	end

	for i,v in ipairs(self._leftBtnList) do
		v:setVisibleByIndex(curTeamIdx)
	end



end


--刷新左右箭头显示
function QUIDialogTeamArrangementNew:_updateArrVisible()
	local curTeamIdx = self._arrangement:getTeamIndex()
	local teamIdxs = self._arrangement:getTeamIndexIds()
	self._ccbOwner.node_right_arr:setVisible(true)
	self._ccbOwner.node_left_arr:setVisible(true)

	if curTeamIdx == teamIdxs[1] then
		self._ccbOwner.node_right_arr:setVisible(false)
	elseif curTeamIdx == teamIdxs[#teamIdxs] then
		self._ccbOwner.node_left_arr:setVisible(false)
	end

	self:updateButtonVisible()
end

--创建avatar 对象
function QUIDialogTeamArrangementNew:_createAvatarNode()
	local avatarNode = QUIWidgetHeroBattleArrayAvatar.new()
	avatarNode:addEventListener(QUIWidgetHeroBattleArrayAvatar.AVATAR_SKILL_CLICK, handler(self, self._onClickEvnetAvatarSkillBtn))
	avatarNode:addEventListener(QUIWidgetHeroBattleArrayAvatar.AVATAR_ICON_CLICK, handler(self, self._onClickEvnetAvatarIconBtn))
	avatarNode:setScale(AVATAR_SCALE)
	self._ccbOwner.node_team_show_1:addChild(avatarNode)
	return avatarNode
end

--获得avatar缓存中的avatar对象
function QUIDialogTeamArrangementNew:_getAvatarByCache()
	-- if self._arrayAvatarNodeListCache[1] then
	-- 	local avatarNode = self._arrayAvatarNodeListCache[1]
	-- 	table.remove(self._arrayAvatarNodeListCache , 1)
	-- 	return avatarNode
	-- end
	return self:_createAvatarNode()
end

--加入avatar缓存
function QUIDialogTeamArrangementNew:_addAvatarToCache(avatarNode)
	-- avatarNode:setVisible(false)
	avatarNode:removeFromParent()
	-- table.insert(self._arrayAvatarNodeListCache , avatarNode)
end

--单条属性
function QUIDialogTeamArrangementNew:playProp(avatar,desc,value)
	if value == nil then value = 0 end
	value = math.floor(value)
	if value > 0 then
		table.insert(self._effectProps, desc..value)
	end
end

--全属性动画
function QUIDialogTeamArrangementNew:playAllProp()
	print("QUIDialogTeamArrangementNew:playAllProp")
	if #self._effectProps > 0 then
		local effect = QUIWidgetAnimationPlayer.new()
		effect:setPosition(0,0)
		self._ccbOwner.node_effect:addChild(effect)
		effect:playAnimation("ccb/effects/Arena_tips.ccbi", function(ccbOwner)
				-- ccbOwner.tf_value:setString(value)
				local i = 1
				while ccbOwner["tf_value"..i] ~= nil do
					ccbOwner["tf_value"..i]:setString("")
					i = i + 1
				end
				for index,value in ipairs(self._effectProps) do
					if ccbOwner["tf_value"..index] ~= nil then
						ccbOwner["tf_value"..index]:setString(value)
					end
				end
	        end,function()
	        	if self:safeCheck() then
	        		effect:removeFromParentAndCleanup(true)
	        	end
	        end)
	end
end

--点击技能图标刷新技能
function QUIDialogTeamArrangementNew:_onClickEvnetAvatarSkillBtn(event)
	local info = event.info

	if info.index == remote.teamManager.TEAM_INDEX_MAIN then
		QPrintTable(info)
		local assistSkillInfo = db:getAssistSkill(info.actorId)
		local skillInfo = remote.herosUtil:getUIHeroByID(info.actorId):getSkillBySlot(3)
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAssistHeroSkill", 
			options = {actorId = info.actorId, assistSkill = assistSkillInfo, skillSlotInfo = skillInfo}},{isPopCurrentDialog = false})
	elseif  info.index == remote.teamManager.TEAM_INDEX_GODARM then
	else
		if self._arrangement:operateHelpHeroSkill(info) then --判断是否点击援助技能 同时处理
			app.tip:floatTip("设置成功！该魂技将作为战斗中的援助魂技！")
			self:_updateDisplayInfo(info)
		end
	end
end

--点击阵容上的avatar刷新阵容
function QUIDialogTeamArrangementNew:_onClickEvnetAvatarIconBtn(event)
	local info = event.info


	if info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.LOCK_SOUL_ELE_TYPE and info.pos == 2 then

		local teamIdxs = self._arrangement:getTeamKeys()
		local num = #teamIdxs
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulTeamGuideTips",options = {soulTeamNum = num}})
		return
	elseif info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.LOCK_HERO_ELE_TYPE then	
		self._arrangement:getLockTipsByInfo(info)
		return
	elseif info.oType >= QBaseArrangementWithDataHandle.ELEMENT_TYPE.EMPTY_ELE_TYPE then
		return
	end

	self:updateByHandleInfo(info)

end

--点击下方icon刷新阵容 不适用
function QUIDialogTeamArrangementNew:_onHeroChanged(event)
	local info = event.info
	self:updateByHandleInfo(info)
end

--点击下方切换按钮
function QUIDialogTeamArrangementNew:_onHeroChangedTab(event)
	if self._isAction then return end
	local tbl = clone(self._arrangement:getArrangeMarkTable())

	if event.jobType then
		if not self._arrangement:setJobType(event.jobType) then
			return
		end
	elseif event.elementType then
		if not self._arrangement:setElementType(event.elementType) then
			return
		end
	elseif event.teamIndex then
		if not self._arrangement:setTeamIndex(event.teamIndex) then
			return
		end
	end

	self:_refreshHeroArray()
	local curTbl = self._arrangement:getArrangeMarkTable()
	if tbl.teamIndex ~= curTbl.teamIndex then
		local  isRight = tbl.teamIndex < curTbl.teamIndex 
		self:_playChangePageAction(self._selectIndex,self._selectIndex == 2 and 1 or 2,isRight)
	end

end

--点击下方icon刷新阵容
function QUIDialogTeamArrangementNew:_onHeroSmallFrameClick(event)
	local info = event.info
	self:updateByHandleInfo(info)
end

--刷新对象的响应
function QUIDialogTeamArrangementNew:updateByHandleInfo(info)
	print("QUIDialogTeamArrangementNew:updateByHandleInfo")
	local needUpdate , isUp = self._arrangement:operateSingleFormationByInfo(info)
	if needUpdate then
		self:_updateDisplayInfo(info)
	end

	if isUp then
		self:_updatePropInfo(info)
		self:_updateTarget(info)
		self:_refreshHeroArray()
	else -- 下阵没用动画 直接刷新下方列表
		self:_refreshHeroArray()
		local curTrialNum = self._arrangement:getTrialNum()
		local force = self._arrangement:getTeamArrangeForceByTrialNum(curTrialNum)
		self._widgetForce:setForce(force)

	end
	
end

--刷新下方列表
function QUIDialogTeamArrangementNew:_refreshHeroArray()

	local data = self._arrangement:getCurShowArrayList()
	self._widgetHeroArray:refreshListData(data)

	local tbl = self._arrangement:getArrangeMarkTable()
	self._widgetHeroArray:refreshButtonDisplay(tbl)
	local trialNum = self._arrangement:getTrialNum()
	local redtbl = self._arrangement:getArrangementRedTips(trialNum)
	self._widgetHeroArray:refreshButtonRedTips(redtbl)

end


--刷新上阵对象
--战斗力变化与对象动画
function QUIDialogTeamArrangementNew:_updateTarget(info)

	local heroDisplay = db:getCharacterByID(info.actorId or info.id)
	app.sound:playSound(heroDisplay.preparation)
	self._handleCombinedSkill = scheduler.performWithDelayGlobal(function()
		self:_judgeTransformation(info)
		end, 0)
	local force = self._arrangement:getTeamArrangeForceByTrialNum(info.trialNum)
	self._widgetForce:palyForceAction(force)
end

--上阵之后判断是否切页、跳转、转换队伍等操作
function QUIDialogTeamArrangementNew:_judgeTransformation(info)
	local state = self._arrangement:handleArrangeMark(info)
	if state == QBaseArrangementWithDataHandle.TRANSFORM_TYPE.NOT_REFRESH_TRANSFORM_TYPE then
	elseif state == QBaseArrangementWithDataHandle.TRANSFORM_TYPE.BUTTON_TRANSFORM_TYPE then
		self:_refreshHeroArray()
	elseif state == QBaseArrangementWithDataHandle.TRANSFORM_TYPE.PAGE_FRONT_TRANSFORM_TYPE then
		self:_playChangePageAction(self._selectIndex,self._selectIndex == 2 and 1 or 2,false)
	elseif state == QBaseArrangementWithDataHandle.TRANSFORM_TYPE.PAGE_BACK_TRANSFORM_TYPE then
		self:_playChangePageAction(self._selectIndex,self._selectIndex == 2 and 1 or 2,true)
	elseif state == QBaseArrangementWithDataHandle.TRANSFORM_TYPE.TEAM_TRANSFORM_TYPE then
		self:_playChangePageAction(self._selectIndex,self._selectIndex == 2 and 1 or 2,false)
	end

end


--显示属性变化
function QUIDialogTeamArrangementNew:_updatePropInfo(info)
	local trialNum = self._arrangement:getTrialNum()

	if info.trialNum ~= trialNum then -- 判断是否为当前队伍
		return
	end

	--如果是援助魂师浮动显示属性加成
	if info.index == remote.teamManager.TEAM_INDEX_HELP or info.index == remote.teamManager.TEAM_INDEX_HELP2 then
			local heroModel = remote.herosUtil:createHeroPropById(info.actorId)
			local teams = self._arrangement:getTeamArrangeIdsByData(trialNum,remote.teamManager.TEAM_INDEX_MAIN
				,QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE)
			local mainTeamNum = #teams or 0
			self._effectProps = {}
			self:playProp(avatar, "主力生命+", heroModel:getMaxHp()*mainTeamNum/4)
			self:playProp(avatar, "主力攻击+", heroModel:getMaxAttack()*mainTeamNum/4)
			self:playProp(avatar, "主力物理防御+", heroModel:getMaxArmorPhysical()*mainTeamNum/4)
			self:playProp(avatar, "主力法术防御+", heroModel:getMaxArmorMagic()*mainTeamNum/4)
			self:playProp(avatar, "主力物理穿透+", heroModel:getMaxPhysicalPenetration()*mainTeamNum/4)
			self:playProp(avatar, "主力法术穿透+", heroModel:getMaxMagicPenetration()*mainTeamNum/4)
			self:playProp(avatar, "主力命中+", heroModel:getMaxHit()*mainTeamNum/4)
			self:playProp(avatar, "主力闪避+", heroModel:getMaxDodge()*mainTeamNum/4)
			self:playProp(avatar, "主力暴击+", heroModel:getMaxCrit()*mainTeamNum/4)
			self:playProp(avatar, "主力抗暴+", heroModel:getMaxCriReduce()*mainTeamNum/4)
			self:playProp(avatar, "主力格挡+", heroModel:getMaxBlock()*mainTeamNum/4)
			self:playProp(avatar, "主力攻速+", heroModel:getMaxHaste()*mainTeamNum/4)
			self:playAllProp()
	end
end

--显示当前的阵容
function QUIDialogTeamArrangementNew:_updateDisplayInfo(info)
	print("QUIDialogTeamArrangementNew:_updateDisplayInfo")
	local maxWidth = self._ccbOwner.node_size:getContentSize().width

	local curShowinfo = self._arrangement:getCurShowTeamArrangement()
	-- for i,v in ipairs(self._arrayAvatarNodeList) do
	-- 	v:removeFromParent()
	-- end
	self._useNum = #curShowinfo or 1
	local offside = maxWidth / self._useNum
	for i,v in ipairs(curShowinfo) do
		local avatar = self._arrayAvatarNodeList[i]
		if avatar == nil then
			avatar = self:_getAvatarByCache()
			table.insert(self._arrayAvatarNodeList,avatar)
		end
		avatar:setPositionX(maxWidth * 0.5 - (i - 0.5) * offside )
		avatar:setInfo(v)
		avatar:setVisible(true)
		if info and v == info then
			avatar:showChooseAction()
		end
	end

end

--点击向右
function QUIDialogTeamArrangementNew:_onTriggerRight()
	self:_onTriggerArr(false)
end

--点击向左
function QUIDialogTeamArrangementNew:_onTriggerLeft()
	self:_onTriggerArr(true)
end


--点击箭头
function QUIDialogTeamArrangementNew:_onTriggerArr(isRight)
	if self._isAction then return end

	self._arrangement:changeTeamIndexByOffside(isRight and 1 or -1 )
	self:_playChangePageAction(self._selectIndex,self._selectIndex == 2 and 1 or 2,isRight)
end

--动画--切换当前界面
function QUIDialogTeamArrangementNew:_playChangePageAction(oldIndex, newIndex , isRight)
	if self._isAction then return end
	self._isAction = true
	--构建目标页签的展示
	self:_updateArrVisible()
	self:_updateFighterInfoDisplay()
	self:_refreshHeroArray()
	
	
	local maxWidth = self._ccbOwner.node_size:getContentSize().width
	local curShowinfo = self._arrangement:getCurShowTeamArrangement()
	local num = #curShowinfo or 1
	local width = maxWidth / num
	local offside = isRight and - SWITCH_DISTANCE or SWITCH_DISTANCE

	for i,avatar in ipairs(self._arrayAvatarNodeList) do
		-- local curPositionX = avatar:getPositionX()
		-- avatar:setPositionX(curPositionX - offside )
		avatar:removeFromParent()
	end
	self._arrayAvatarNodeList = {}
	for i,v in ipairs(curShowinfo) do
		local avatar = self:_getAvatarByCache()
		avatar:setVisible(true)
		avatar:setPositionX(maxWidth * 0.5 - (i - 0.5) * width)
		avatar:setInfo(v)
		table.insert(self._arrayAvatarNodeList,avatar)
	end
	self._selectIndex = newIndex

	--动画

	self._ccbOwner["sp_array_bg_"..oldIndex]:setPositionX(0)
	self._ccbOwner.node_team_show_1:setPositionX(offside)


	self._ccbOwner["sp_array_bg_"..newIndex]:setPositionX(offside)
	self._ccbOwner["sp_array_bg_"..newIndex]:setVisible(true)


	self._ccbOwner.sp_effect_bg:setPositionX(offside * 0.5)


	local teamIndex = self._arrangement:getTeamIndex()
	local scale = 1
	if self._arrangement:getBackPagePath(teamIndex) then
		self._ccbOwner["sp_array_bg_"..newIndex]:setDisplayFrame(self._arrangement:getBackPagePath(teamIndex))
		scale = CalculateUIBgSize(self._ccbOwner["sp_array_bg_"..newIndex])
	end	

	if self._arrangement:getEffectPagePath(teamIndex) then
		self._ccbOwner.sp_effect_bg:setDisplayFrame(self._arrangement:getEffectPagePath(teamIndex))
		self._ccbOwner.sp_effect_bg:setScale(0)
    	self._ccbOwner.sp_effect_bg:setVisible(true)
	end
    ------------------------------------------------------------------

	local arrOld1 = CCArray:create()
    arrOld1:addObject(CCDelayTime:create(DELAY_DURATION))
    arrOld1:addObject(CCMoveTo:create(SWITCH_DURATION,ccp( - offside,0)))
    arrOld1:addObject(CCCallFunc:create(function()
   		self._ccbOwner["sp_array_bg_"..oldIndex]:setVisible(false)
    end))
    self._ccbOwner["sp_array_bg_"..oldIndex]:stopAllActions()
    self._ccbOwner["sp_array_bg_"..oldIndex]:runAction(CCSequence:create(arrOld1))

    ------------------------------------------------------------------
	local arrNew = CCArray:create()
    arrNew:addObject(CCDelayTime:create(DELAY_DURATION))
    arrNew:addObject(CCMoveTo:create(SWITCH_DURATION, ccp(0 ,0)))
    arrNew:addObject(CCCallFunc:create(function()
    	if self:safeCheck() then
    		self:_ActionEndCallBack()
    	end
    end))
    self._ccbOwner.node_team_show_1:stopAllActions()
    self._ccbOwner.node_team_show_1:runAction(CCSequence:create(arrNew))

	local arrNew1 = CCArray:create()
    arrNew1:addObject(CCDelayTime:create(DELAY_DURATION))
    arrNew1:addObject(CCMoveTo:create(SWITCH_DURATION,ccp(0 ,0)))
    self._ccbOwner["sp_array_bg_"..newIndex]:stopAllActions()
    self._ccbOwner["sp_array_bg_"..newIndex]:runAction(CCSequence:create(arrNew1))

    ------------------------------------------------------------------

	local arrEffect = CCArray:create()
    arrEffect:addObject(CCDelayTime:create(DELAY_DURATION))
    arrEffect:addObject(CCScaleTo:create(DELAY_DURATION, scale ))
    arrEffect:addObject(CCMoveTo:create(SWITCH_DURATION * 0.5, ccp(- offside * 0.5 ,0)))
    arrEffect:addObject(CCScaleTo:create(DELAY_DURATION,0 ))
    arrEffect:addObject(CCCallFunc:create(function()
    	self._ccbOwner.sp_effect_bg:setVisible(false)
    end))

    self._ccbOwner.sp_effect_bg:stopAllActions()
    self._ccbOwner.sp_effect_bg:runAction(CCSequence:create(arrEffect))
end

function QUIDialogTeamArrangementNew:_ActionEndCallBack()
		self._ccbOwner.node_team_show_1:setPositionX(0)
		-- local tbl = {}
		-- for i,v in ipairs(self._arrayAvatarNodeList) do
		-- 	if i <= self._useNum then
		-- 		self:_addAvatarToCache(v)
		-- 	end
		-- end
		-- for i=1,self._useNum do
		-- 	table.remove(self._arrayAvatarNodeList , 1)
		-- end


		local curTrialNum = self._arrangement:getTrialNum()
		local force = self._arrangement:getTeamArrangeForceByTrialNum(curTrialNum)
		self._widgetForce:setForce(force)
		self._useNum = num
		self._isAction = false


		if self._eleanTextureScheduler ~= nil then
			scheduler.unscheduleGlobal(self._eleanTextureScheduler)
			self._eleanTextureScheduler = nil
		end
		self._eleanTextureScheduler = scheduler.performWithDelayGlobal(function ( ... )
			app:setIsClearSkeletonData(true)
		    app:cleanTextureCache()
		end, 0)
end

--点击pvp属性按钮
function QUIDialogTeamArrangementNew:_onTriggerClickPVP()
    app.sound:playSound("common_small")

    local teamKey = self._arrangement:getTeamKey()
    local fighter = remote.user:makeFighterByTeamKey(teamKey, 1)
    local extraProp = app.extraProp:getSelfExtraProp()

	local teams = self._arrangement:getCurHeroTeamActorIds(remote.teamManager.TEAM_INDEX_MAIN)
	fighter.heros = remote.user:getHerosFun(teams)
	teams = self._arrangement:getCurHeroTeamActorIds(remote.teamManager.TEAM_INDEX_HELP)
	fighter.subheros =  remote.user:getHerosFun(teams)
	teams = self._arrangement:getCurHeroTeamActorIds(remote.teamManager.TEAM_INDEX_HELP2)
	fighter.sub2heros =  remote.user:getHerosFun(teams)
	teams = self._arrangement:getCurHeroTeamActorIds(remote.teamManager.TEAM_INDEX_HELP3)
	fighter.sub3heros =  remote.user:getHerosFun(teams)

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPVPPropTip", 
        options = {teamKey = teamKey, fighter = fighter, extraProp = extraProp }}, {isPopCurrentDialog = false})
end

--点击跳过战斗
function QUIDialogTeamArrangementNew:_onTriggerSkipFight()
    app.sound:playSound("common_switch")
    local tipStr ="跳过战斗设置关闭，您将可以手动操作战斗"
    if not self._isSkipFight then
		tipStr ="已设置成跳过战斗"
    end
    app.tip:floatTip(tipStr)
	self:setUpdateSkipFightState()
end

--通用的帮助文档
function QUIDialogTeamArrangementNew:_onTriggerConditionInfo()
   app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHelperExplain"})
end

--点击魂灵按钮
function QUIDialogTeamArrangementNew:_onTriggerSoulInfo()
	app.sound:playSound("common_small")

	local soulSpirits = self._arrangement:getCurSoulSpiritTeamIds(remote.teamManager.TEAM_INDEX_MAIN)
	
	local mainTeam =  self._arrangement:getCurHeroTeamActorIds(remote.teamManager.TEAM_INDEX_MAIN)
	local helpTeam1 =  self._arrangement:getCurHeroTeamActorIds(remote.teamManager.TEAM_INDEX_HELP)
	local helpTeam2 = self._arrangement:getCurHeroTeamActorIds(remote.teamManager.TEAM_INDEX_HELP2)
	local helpTeam3 =  self._arrangement:getCurHeroTeamActorIds(remote.teamManager.TEAM_INDEX_HELP3)

   	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamSoulSpiritInfo",
   		options = {mainTeam = mainTeam, helpTeam1 = helpTeam1, helpTeam2 = helpTeam2, helpTeam3 = helpTeam3, soulSpiritId = soulSpirits}})
end

--点击神器按钮
function QUIDialogTeamArrangementNew:_onTriggerGodarmInfo(event)
	app.sound:playSound("common_small")
	local godarmInfo = self._arrangement:getCurShowTeamArrangement(true)
	if next(godarmInfo) == nil then
		app.tip:floatTip("神器未上阵~")
		return		
	end	

   	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGodarmTeamDetail",
   		options = {mainGodarmList = godarmInfo}})	
end

--点击一键换队
function QUIDialogTeamArrangementNew:_onTriggerChangeTeam(event)
	local teamIdxs = self._arrangement:getTeamKeys()
	local num = #teamIdxs

	if num == 3 then
		self:_changeTeamThree()

	else

	end
end

function QUIDialogTeamArrangementNew:_changeTeamThree()
	local teamTotalInfo = {}
	local teamIdxIds = self._arrangement:getTeamIndexIds()
	for i=1,3 do
		local infoTbl = {}
		for _,v in ipairs(teamIdxIds) do
			local targetArrangementData = clone(self._arrangement:getShowTeamArrangement(i,v))
			for _,info in ipairs(targetArrangementData or {}) do
				table.insert(infoTbl,info)
			end
		end
		table.insert(teamTotalInfo,infoTbl)
	end
	local fighter = self._arrangement:getEnemyFighterInfos()
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogQuickChangeThreeTeam",
		options = {	teamTotalInfo = teamTotalInfo ,enemyFighter = fighter,
			callBack = function ()
				if self:safeCheck() then
					self._arrangement:setShowTeamArrangementByInfo(teamTotalInfo)
					self:_updateDisplayInfo()
					self:_refreshHeroArray()
				end
		end , detailFunc = handler(self, self._onTiggerClickInfoBrief)
		}})


end

function QUIDialogTeamArrangementNew:_onTriggerFight(event)

	print("onTriggerFight")
	local curTeamIdx = self._arrangement:getTeamIndex()
	if curTeamIdx ~= remote.teamManager.TEAM_INDEX_MAIN then
		local isRight = false
		self._arrangement:setTeamIndex(remote.teamManager.TEAM_INDEX_MAIN)
		self:_playChangePageAction(self._selectIndex,self._selectIndex == 2 and 1 or 2,isRight)
		self:_refreshHeroArray()
		return
	end
	local teamIdxs = self._arrangement:getTeamKeys()
	local maxNum = #teamIdxs
	local curTrialNum = self._arrangement:getTrialNum()
	local teamIds = self._arrangement:getCurHeroTeamActorIds(remote.teamManager.TEAM_INDEX_MAIN)
	if not self._arrangement:teamValidity(teamIds, maxNum == 1 and nil or curTrialNum) then
		return 
	end
	for i,v in ipairs(teamIdxs) do
		if curTrialNum ~= i then
			local teamIds = self._arrangement:getHeroTeamActorIdsByData(i,remote.teamManager.TEAM_INDEX_MAIN)
			if q.isEmpty(teamIds) then
				local isRight = curTrialNum > i
				self._arrangement:setTrialNum(i)
				
				self:_playChangePageAction(self._selectIndex,self._selectIndex == 2 and 1 or 2,isRight)
				self:_refreshHeroArray()
				return 
			end
		end
	end

	
	if maxNum == 1 then
		local noticeStr = "战队"
		local noticeEndStr ="未上阵，确定开始战斗吗"
		local lackTbl = self._arrangement:getTeamInfoLackByTrialNum(1)
		if not q.isEmpty(lackTbl) then
			for i,v in ipairs(lackTbl) do
				if i >1 then
					noticeStr = noticeStr.."、"
				end
				noticeStr = noticeStr..(self:getLackStrByNoticeType(v))
			end
			noticeStr = noticeStr..noticeEndStr
			app:alert({content = noticeStr, title = "系统提示", callback = function (state)
					if state == ALERT_TYPE.CONFIRM then
						self._arrangement:startBattle()
					end
				end})	
			return
		end
	else
		for i,value in ipairs(teamIdxs) do
			local noticeStr ="第"..i.."战队"
			local noticeEndStr ="未上阵，确定开始战斗吗"
			local lackTbl = self._arrangement:getTeamInfoLackByTrialNum(i)
			if not q.isEmpty(lackTbl) then
				QPrintTable(lackTbl)
				for num,v in ipairs(lackTbl) do
					print(num)
					if num >1 then
						noticeStr = noticeStr.."、"
					end
					noticeStr = noticeStr..(self:getLackStrByNoticeType(v))
				end
				noticeStr = noticeStr..noticeEndStr
				app:alert({content = noticeStr, title = "系统提示", callback = function (state)
						if state == ALERT_TYPE.CONFIRM then
							self._arrangement:startBattle()
						end
					end})	
				return
			end
		end
	end

	self._arrangement:startBattle()
end

--获取提示类型
function QUIDialogTeamArrangementNew:getLackStrByNoticeType(noticeType)
	if noticeType == QBaseArrangementWithDataHandle.NOTICE_TYPE.LACK_MAIN then
		return "主力魂师"
	elseif noticeType == QBaseArrangementWithDataHandle.NOTICE_TYPE.LACK_HELP then
		return "援助魂师"
	elseif noticeType == QBaseArrangementWithDataHandle.NOTICE_TYPE.LACK_SOUL then
		return "魂灵"
	elseif noticeType == QBaseArrangementWithDataHandle.NOTICE_TYPE.LACK_GODARM then
		return "神器"
	end
	return ""
end

--点击切换队伍
function QUIDialogTeamArrangementNew:_onTiggerClickTeam(event)
	if self._isAction then return end
	local trialNum = event.trialNum
	local curTrialNum = self._arrangement:getTrialNum()
	-- 没有主力魂师也能切换队伍
	-- local teamIds = self._arrangement:getCurHeroTeamActorIds(remote.teamManager.TEAM_INDEX_MAIN)
	-- if not self._arrangement:teamValidity(teamIds, curTrialNum) then
	-- 	return 
	-- end

	local isRight = curTrialNum > trialNum
	self._arrangement:setTrialNum(trialNum)
	self:changeFighterInfoDisplay(trialNum)
	self:_playChangePageAction(self._selectIndex,self._selectIndex == 2 and 1 or 2,isRight)
	self:_refreshHeroArray()
end

--点击敌对属性
function QUIDialogTeamArrangementNew:_onTiggerClickInfo(event)
	local trialNum = event.trialNum
	print(trialNum)
	local fighter = self._arrangement:getEnemyFighter()
	if fighter == nil then
		self:_onTiggerClickTeam(event)
		return
	end
	local enemyFighterInfo = self._arrangement:getEnemyFighterInfoByIdx(trialNum)
	if q.isEmpty(enemyFighterInfo) then
		self:_onTiggerClickTeam(event)
		return
	end
	local heros_ = {}
	for i,v in ipairs(enemyFighterInfo.heroes or {}) do
		table.insert(heros_,1,v)
	end
    local subheros = enemyFighterInfo.supports or {}
    local godArm1List = enemyFighterInfo.godArmIdList or {}
    local soulSpirit = enemyFighterInfo.soulSpirits or {}
    local force = enemyFighterInfo.force or 0
  	local options_ = {fighter = fighter, isPVP = true ,heros = heros_ ,subheros = subheros , godArm1List = godArm1List 
   		,soulSpirit = soulSpirit ,forceTitle="战力 :" , isPVP = true , force = force or 0, trialNum = trialNum , showTeamForce = true }

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
   		options = options_ }, {isPopCurrentDialog = false})

end


function QUIDialogTeamArrangementNew:_onTiggerClickInfoBrief(event)
	local trialNum = event.trialNum
	local fighter = self._arrangement:getEnemyFighter()
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStormArenaEnemyTeamInfo",
			options = {trialNum = trialNum, info = fighter}}, {isPopCurrentDialog = false})
end

--点击属性按钮
function QUIDialogTeamArrangementNew:_onTriggerHelperDetail()
	app.sound:playSound("common_small")

	local helpTeam1 =  self._arrangement:getCurHeroTeamActorIds(remote.teamManager.TEAM_INDEX_HELP)
	local helpTeam2 = self._arrangement:getCurHeroTeamActorIds(remote.teamManager.TEAM_INDEX_HELP2)
	local helpTeam3 =  self._arrangement:getCurHeroTeamActorIds(remote.teamManager.TEAM_INDEX_HELP3)
	
   	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamHelperAddInfo",
   		options = {helpTeam1 = helpTeam1, helpTeam2 = helpTeam2, helpTeam3 = helpTeam3}})
end

--设置是否跳过战斗
function QUIDialogTeamArrangementNew:setUpdateSkipFightState()
    self._isSkipFight = not self._isSkipFight
    app:getUserData():setUserValueForKey(QUserData.Totem_Challenge_SKIP,self._isSkipFight and "1" or "0")
	self._ccbOwner.sp_select:setVisible(self._isSkipFight)
end

function QUIDialogTeamArrangementNew:onTriggerBackHandler(tag)

	self._arrangement:saveFormation()

   if self._backCallback then
    	self._backCallback()
    end

    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogTeamArrangementNew:onTriggerHomeHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end


return QUIDialogTeamArrangementNew