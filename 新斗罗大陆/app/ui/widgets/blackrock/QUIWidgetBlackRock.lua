local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetBlackRock = class("QUIWidgetBlackRock", QUIWidget)
local QUIWidgetActorDisplay = import("..actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")
local QUIViewController = import("...QUIViewController")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")
local QUIWidgetAnimationPlayer = import("....widgets.QUIWidgetAnimationPlayer")

QUIWidgetBlackRock.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetBlackRock:ctor(options)
	local ccbFile = "ccb/Widget_black_mountain_ren.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerChapter", callback = handler(self, self._onTriggerChapter)},
        {ccbCallbackName = "onTriggerSeeAwards", callback = handler(self, self._onTriggerSeeAwards)},
    }
	QUIWidgetBlackRock.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	-- setShadow6(self._ccbOwner.tf_condition)
	-- setShadow6(self._ccbOwner.tf_name)
end

function QUIWidgetBlackRock:setInfo(info,parent)
	self._parent = parent
	self._info = info
	local chapterInfo = self._info[1]
	self._ccbOwner.tf_name:setString(chapterInfo.name)

	self._ccbOwner.node_avatar:removeAllChildren()

	-- QPrintTable(chapterInfo)

	local minForce = chapterInfo.monster_battleforce
	local maxForce = self._info[#self._info].monster_battleforce

	local num1,uint1 = q.convertLargerNumber(minForce)
	local num2,uint2 = q.convertLargerNumber(maxForce)
	self._ccbOwner.tf_condition:setString(string.format("战力：%s~%s", (num1..uint1), (num2..uint2)))

	if remote.user:getHistoryTopForce() < minForce then
		self._ccbOwner.tf_name:setColor(UNITY_COLOR.gray)
		self._ccbOwner.tf_condition:setColor(COLORS.F)
	else
		-- self._ccbOwner.tf_name:setColor(COLORS.G)
		self._ccbOwner.tf_condition:setColor(COLORS.c)
	end

	if chapterInfo.enterance then
		QSetDisplayFrameByPath(self._ccbOwner.sp_door_bg,chapterInfo.enterance)
	end

	self._ccbOwner.node_effect_1:removeAllChildren()
	self._ccbOwner.node_effect_2:removeAllChildren()
	if chapterInfo.effect then
		local effectTbl = string.split(chapterInfo.effect, ";")
		local addEffect = function(path,node)
			if string.find(path, "fca/", 1, true) then
				local fcaAnimation = QUIWidgetFcaAnimation.new(path, "res")
				fcaAnimation:playAnimation("animation", true)
				node:addChild(fcaAnimation)
				fcaAnimation:setPositionX(chapterInfo.effect_shifting_x or 0)
				fcaAnimation:setPositionY(chapterInfo.effect_shifting_y or -35)
			else
				local effect1 = QUIWidgetAnimationPlayer.new()
				effect1:playAnimation(path, nil, nil)
				node:addChild(effect1)
				effect1:setPositionX(chapterInfo.effect_shifting_x or 0)
				effect1:setPositionY(chapterInfo.effect_shifting_y or -35)					
			end
		end
		if effectTbl[1] and effectTbl[1] ~= "" then
			addEffect(effectTbl[1],self._ccbOwner.node_effect_1)
		end

		if effectTbl[2] and effectTbl[2] ~= "" then
			addEffect(effectTbl[2],self._ccbOwner.node_effect_2)
		end
	end
end

function QUIWidgetBlackRock:getChapterInfo()
	return self._info
end

function QUIWidgetBlackRock:_onTriggerSeeAwards(event)
	if self._parent and self._parent:isMoving() then return end
	if q.buttonEventShadow(event, self._ccbOwner.btn_awards) == false then return end
	app.sound:playSound("common_switch")
    local info = self._info
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRockAwardsTips", 
        options = {info = info}}, {isPopCurrentDialog = false})	
end

function QUIWidgetBlackRock:_onTriggerChapter(event)
	if self._parent and self._parent:isMoving() then return end
	if q.buttonEventShadow(event, self._ccbOwner.btn_click) == false then return end
	app.sound:playSound("common_switch")

	local selectInfo = self._info or {}

    local force = 0
    for _,v in ipairs(selectInfo) do
        if force == 0 or force > v.monster_battleforce then
            force = v.monster_battleforce
        end
    end
    if force > (remote.user:getHistoryTopForce() or 0) then
        app.tip:floatTip("魂师大人，您的战力还未达到进入要求哦~")
        return
    end

    --之前放弃的还没结束
    local progress = remote.blackrock:getProgress(remote.user.userId)
    local teamInfo = remote.blackrock:getTeamInfo()
    if remote.blackrock:getTeamIsEnd() == false and progress ~= nil and progress.isEnd == true then
        local chapterId = teamInfo.chapterId
        local configs = QStaticDatabase:sharedDatabase():getBalckRockConfig()
        local name = configs[tostring(chapterId)][1].name
        local startTime = teamInfo.teamProgress.fightStartAt/1000
        local passTime = q.serverTime() - startTime
        local totalTime = remote.blackrock:getTotalFightTime()
        app.tip:floatTip(string.format("魂师大人，您在%s节的战斗还未结束，队伍结束倒计时：%s", name, q.timeToHourMinuteSecond(math.max(totalTime - passTime, 0))))
        return
    end

    if q.isEmpty(selectInfo) == false then
    	--根据本地记录队伍筛选
    	local teamSelectSet = app:getUserOperateRecord():getBlackRockTeamSetInfo()
        remote.blackrock:blackRockGetChapterTeamListRequest(selectInfo[1].id,"",function (data)
            if self:safeCheck() then
                local teams = data.blackRockGetChapterTeamListResponse.teams or {}
                remote.blackrock:setCurrentAllTeams(teams)
                app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRockChoose", 
                    options = {info = selectInfo, teams = teams}})
            end
        end)
    end
end

function QUIWidgetBlackRock:showItemTips(index)
	local chapterInfo = self._info[1]
	if chapterInfo["item_show_id_"..index] ~= nil then
		local typeName = remote.items:getItemType(chapterInfo["item_show_id_"..index])
		if typeName == nil then
			typeName = ITEM_TYPE.ITEM
		end
		app.tip:itemTip(typeName, chapterInfo["item_show_id_"..index])
	end
end

function QUIWidgetBlackRock:getContentSize()
	return self._ccbOwner.sp_mark:getContentSize()
end


return QUIWidgetBlackRock