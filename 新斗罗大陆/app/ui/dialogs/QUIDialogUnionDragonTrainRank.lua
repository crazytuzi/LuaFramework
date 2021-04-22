--
-- zxs
-- 宗门武魂排行
--

local QUIDialog = import("..Dialogs.QUIDialog")
local QUIDialogUnionDragonTrainRank = class("QUIDialogUnionDragonTrainRank", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetUnionDragonTrainRank = import("..widgets.dragon.QUIWidgetUnionDragonTrainRank")
local QUIWidgetMyRankStyleDurian = import("..widgets.rank.QUIWidgetMyRankStyleDurian")
local QUIWidgetTeamMyRank = import("..widgets.rank.QUIWidgetTeamMyRank")

QUIDialogUnionDragonTrainRank.PERSONAL_RANK = "PERSONAL_RANK"
QUIDialogUnionDragonTrainRank.UNION_RANK = "UNION_RANK"

function QUIDialogUnionDragonTrainRank:ctor(options)
    local ccbFile = "ccb/Dialog_society_dragontrain_rank.ccbi"
    local callBack = {
        {ccbCallbackName = "onTriggerPersonalRank", callback = handler(self, self._onTriggerPersonalRank)},
        {ccbCallbackName = "onTriggerUnionRank", callback = handler(self, self._onTriggerUnionRank)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogUnionDragonTrainRank.super.ctor(self, ccbFile, callBack, options)

    self._actorId = options.actorId
    self._tab = options.tab or QUIDialogUnionDragonTrainRank.PERSONAL_RANK
    
    self._data = {}
    self._myRankData = {}
    self:_selectTab()
end

function QUIDialogUnionDragonTrainRank:viewDidAppear()
    QUIDialogUnionDragonTrainRank.super.viewDidAppear(self)
end

function QUIDialogUnionDragonTrainRank:viewWillDisappear()
    QUIDialogUnionDragonTrainRank.super.viewWillDisappear(self)
end

function QUIDialogUnionDragonTrainRank:_selectTab()
    self:updateButtonState()
    if self._listView then
        self._listView:clear()
    end

    if self._tab == QUIDialogUnionDragonTrainRank.PERSONAL_RANK then
        remote.dragon:consortiaDragonContributionRequest(self:safeHandler(function(data)
                self._data = data.rankings.top50 or {}
                self._myRankData = data.rankings.myself
                self:initListView()
                self:initMyRankInfo()
            end))
    elseif self._tab == QUIDialogUnionDragonTrainRank.UNION_RANK then
        remote.dragon:consortiaDragonContributionRequest(self:safeHandler(function(data)
                self._data = data.rankings.top50 or {}
                self._myRankData = data.rankings.myself
                self:initListView()
                self:initMyRankInfo()
            end))
    end
end

function QUIDialogUnionDragonTrainRank:initListView()
    if not self._data or #self._data == 0 then
        self._ccbOwner.node_empty:setVisible(true)
    else
        self._ccbOwner.node_empty:setVisible(false)
    end

    if not self._listView then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                local isCacheNode = true
                local itemData = self._data[index]
                local item = list:getItemFromCache()
                if not item then
                    item = QUIWidgetUnionDragonTrainRank:new()
                    isCacheNode = false
                end
                item:setInfo(itemData, index)
                info.item = item
                info.size = item:getContentSize()
                
                return isCacheNode
            end,
            spaceY = 6,
            isVertical = true,
            enableShadow = false,
            curOriginOffset = 6,
            curOffset = 6,
            totalNumber = #self._data,
        }
        self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listView:reload({totalNumber = #self._data})
    end
end

function QUIDialogUnionDragonTrainRank:initMyRankInfo()
    if not self._myRankData or not next(self._myRankData) then 
        return 
    end

    local widget = self:getSelfItem()
    self._ccbOwner.node_myRank:removeAllChildren()
    self._ccbOwner.node_myRank:addChild(widget)
end

function QUIDialogUnionDragonTrainRank:getSelfItem()
    local myInfo = self._myRankData
    local item = QUIWidgetTeamMyRank.new()
    item:setInfo(myInfo)
    local style = QUIWidgetMyRankStyleDurian.new()
    style:setPosition(ccp(-35, 0))
    item:setStyle(style)
    style:setAvatar(myInfo.avatar)
    style:setTFByIndex(1, "LV."..(myInfo.level or "0"))
    style:setTFByIndex(2, (myInfo.name or ""))
    style:setTFByIndex(3, "累计贡献武魂经验：")
    style:setTFByIndex(4, myInfo.dragonContribution or "0")
    style:setTFByIndex(5, "")
    style:autoLayout()
    return item
end

function QUIDialogUnionDragonTrainRank:updateButtonState()
    local isPersonal = self._tab == QUIDialogUnionDragonTrainRank.PERSONAL_RANK
    local isUnion = self._tab == QUIDialogUnionDragonTrainRank.UNION_RANK

    self._ccbOwner.btn_personal:setHighlighted(isPersonal)
    self._ccbOwner.btn_personal:setEnabled(not isPersonal)

    self._ccbOwner.btn_union:setHighlighted(isUnion)
    self._ccbOwner.btn_union:setEnabled(not isUnion)
end

function QUIDialogUnionDragonTrainRank:_onTriggerPersonalRank()
    if self._tab == QUIDialogUnionDragonTrainRank.PERSONAL_RANK then 
        return 
    end
    app.sound:playSound("common_small")
    self._tab = QUIDialogUnionDragonTrainRank.PERSONAL_RANK

    self:_selectTab()
end

function QUIDialogUnionDragonTrainRank:_onTriggerUnionRank()
    if self._tab == QUIDialogUnionDragonTrainRank.UNION_RANK then 
        return 
    end
    app.sound:playSound("common_small")
    self._tab = QUIDialogUnionDragonTrainRank.UNION_RANK

    self:_selectTab()
end

function QUIDialogUnionDragonTrainRank:_onTriggerClose(e)
    if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
    app.sound:playSound("common_small")
    self:playEffectOut()
end

function QUIDialogUnionDragonTrainRank:_backClickHandler()
    self:_onTriggerClose()
end

return QUIDialogUnionDragonTrainRank