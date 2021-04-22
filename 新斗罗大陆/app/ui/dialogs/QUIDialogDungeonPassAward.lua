--
-- zxs
-- 通关奖励信息
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogDungeonPassAward = class("QUIDialogDungeonPassAward", QUIDialog)
local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetDungeonPassAwardBox = import("..widgets.QUIWidgetDungeonPassAwardBox")

function QUIDialogDungeonPassAward:ctor(options)
    local ccbFile = "ccb/Dialog_Dungeon_pass_award.ccbi"
    local callBacks = {
    }
    QUIDialogDungeonPassAward.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    self._showAni = false
    self._isSetShowAni = options.isSetShowAni
    self._callback = options.callback           -- 关闭回调用于不需要领取的
    self._getCallback = options.getCallback     -- 领取完毕后的回调用于需要领取的
    self._awardInfo = options.awardInfo or {}
    self._rewardList = {}
    self._headBox = {}
    self._totalWidth = self._ccbOwner.node_bar:getContentSize().width

    self:init()
    self:initPassAwards()
end

function QUIDialogDungeonPassAward:dealIntId(intId)
    local num = intId%1010000
    local num1 = math.floor(num/100)
    local num2 = num%100
    return num1, num2
end

function QUIDialogDungeonPassAward:getDiffNum(startId, conditionId)
    local startNum1, startNum2 = self:dealIntId(startId)
    local num1, num2 = self:dealIntId(conditionId)

    local offset = (num1-startNum1)*16+num2-startNum2
    if offset < 0 then
        offset = 0
    end
    local desc = string.format("通关%d-%d", num1, num2)
    return offset, desc
end

function QUIDialogDungeonPassAward:init()
    self._ccbOwner.node_info:setVisible(false)
    for i = 1, 3 do
        self._ccbOwner["node_head"..i]:removeAllChildren()
    end

    local passType = tonumber(self._awardInfo.type)
    if passType == 1 then
        -- 大图
        if self._awardInfo.pic then
            local icon = QSpriteFrameByPath(self._awardInfo.pic)
            if icon then
                self._ccbOwner.sp_image:setDisplayFrame(icon)
            end
        end
    elseif passType == 2 then
        self._ccbOwner.sp_image:setVisible(false)
        self._ccbOwner.node_info:setVisible(true)
        local dungeonIntId = remote.instance:getLastPassDungeonIntId(DUNGEON_TYPE.NORMAL)
        local awardCondition = string.split(self._awardInfo.conditions, ";")
        local awardsTbl = remote.items:analysisServerItem(self._awardInfo.awards)

        local startId = self._awardInfo.show_int_id
        for i, condition in pairs(awardCondition) do
            local conditionId = tonumber(condition)
            local diffNum, desc = self:getDiffNum(startId, conditionId)
            local info = {}
            info.pos = i
            info.conditionId = conditionId
            info.diffNum = diffNum
            info.desc = desc
            info.isComplete = dungeonIntId >= conditionId
            info.awards = awardsTbl[i]
            self._rewardList[#self._rewardList+1] = info
            startId = conditionId
        end
        if self._awardInfo.avatar then
            local avatar = CCSprite:create(self._awardInfo.avatar)
            self._ccbOwner.node_avatar:removeAllChildren()
            self._ccbOwner.node_avatar:addChild(avatar)

            avatar:setScale(self._awardInfo.scale or 1)
            avatar:setPositionX(self._awardInfo.pos_x or 0)
            avatar:setPositionY(self._awardInfo.pos_y or 0)
        end
        if self._awardInfo.desc_pic then
            self._ccbOwner.node_desc:removeAllChildren()
            local descPic = CCSprite:create(self._awardInfo.desc_pic)
            if descPic then
                descPic:setAnchorPoint(ccp(1.0, 1.0))
                self._ccbOwner.node_desc:addChild(descPic)
            end
        end

        local num1, num2 = self:dealIntId(dungeonIntId)
        local desc = string.format("(当前通关%d-%d)", num1, num2)
        self._ccbOwner.tf_cur_id:setString(desc)
    end
end

function QUIDialogDungeonPassAward:initPassAwards()
    local awardNum = #self._rewardList
    for i, v in pairs(self._rewardList) do
        local posX = i/awardNum*self._totalWidth 
        local headBox = QUIWidgetDungeonPassAwardBox.new()
        headBox:addEventListener(QUIWidgetDungeonPassAwardBox.EVENT_PASS_AWARD_CLICK, handler(self, self.itemClickHandler))
        self._ccbOwner["node_head"..i]:addChild(headBox)
        self._headBox[#self._headBox+1] = headBox
        self._ccbOwner["tf_pass"..i]:setString(v.desc)
    end

    self:updateHeadData()
end

function QUIDialogDungeonPassAward:updateHeadData()
    local awardNum = #self._rewardList
    local dungeonIntId = remote.instance:getLastPassDungeonIntId(DUNGEON_TYPE.NORMAL)
    local scaleX = 0
    local lastId = self._awardInfo.show_int_id
    for i, info in pairs(self._rewardList) do
        if info.conditionId <= dungeonIntId then
            scaleX = scaleX + 1/awardNum
            lastId = info.conditionId
            info.isGet = remote.instance:checkIsPassAwardGet(self._awardInfo.id, i)
        else
            local diffNum = self:getDiffNum(lastId, dungeonIntId)
            scaleX = scaleX + diffNum/info.diffNum/awardNum
            info.isGet = false
            break
        end
    end
    if scaleX > 1 then
        scaleX = 1
    end
    self._ccbOwner.node_bar:setScaleX(scaleX)

    for i, headBox in pairs(self._headBox) do
        headBox:setInfo(self._rewardList[i], i)
    end
end

function QUIDialogDungeonPassAward:itemClickHandler(event)
    local info = event.info
    remote.instance:dungeonGetPassAwardsRequest(self._awardInfo.id, info.pos, function(data)
        local awards = {}
        table.insert(awards, info.awards)
        local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAwardsAlert", 
            options = {awards = awards}},{isPopCurrentDialog = false} )
        dialog:setTitle("恭喜获得通关奖励")
        if self:safeCheck() then
            self:updateHeadData()
            self:checkCurPassAwardAllGet()
        end
    end)
end

-- 检测当前awardid的所有奖励是否全面领取
function QUIDialogDungeonPassAward:checkCurPassAwardAllGet()
    local dungeonIntId = remote.instance:getLastPassDungeonIntId(DUNGEON_TYPE.NORMAL)
    local isAllGet = remote.instance:checkCurPassAwardAllGet(dungeonIntId, self._awardInfo)
    self._showAni = isAllGet
end

function QUIDialogDungeonPassAward:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogDungeonPassAward:_onTriggerClose(event)
    if event then
        app.sound:playSound("common_cancel")
    end
    self:playEffectOut()
end

function QUIDialogDungeonPassAward:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
    if (self._showAni or self._isSetShowAni) and self._getCallback then
        self._getCallback(self._isSetShowAni)
    end
    if self._callback then
        self._callback()
    end
end

return QUIDialogDungeonPassAward