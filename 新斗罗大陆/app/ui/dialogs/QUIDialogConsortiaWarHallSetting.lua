-- @Author: zhouxiaoshu
-- @Date:   2019-04-28 17:29:32
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-05 11:30:44

local QUIDialogBaseUnion = import("..dialogs.QUIDialogBaseUnion")
local QUIDialogConsortiaWarHallSetting = class("QUIDialogConsortiaWarHallSetting", QUIDialogBaseUnion)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetConsortiaWarHallSetting = import("..widgets.consortiaWar.QUIWidgetConsortiaWarHallSetting")
local QListView = import("...views.QListView")

function QUIDialogConsortiaWarHallSetting:ctor(options)
    local ccbFile = "ccb/Dialog_Unionwar_arrange.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogConsortiaWarHallSetting._onTriggerClose)},
    }
    QUIDialogConsortiaWarHallSetting.super.ctor(self, ccbFile, callBacks, options)
    self:setSocietyNameVisible(false)

    self._data = {}
    self._updateHallList = {}
    self._hallId = options.hallId or 1

    self._ccbOwner.frame_tf_title:setString("设置阵容")
    self._ccbOwner.node_right_center:setVisible(false)
    self:initListView()
end

function QUIDialogConsortiaWarHallSetting:viewDidAppear()
    QUIDialogConsortiaWarHallSetting.super.viewDidAppear(self)
    self:addBackEvent(false)
end

function QUIDialogConsortiaWarHallSetting:viewWillDisappear()
    QUIDialogConsortiaWarHallSetting.super.viewWillDisappear(self)
    self:removeBackEvent()
end

function QUIDialogConsortiaWarHallSetting:setSocietyTopBar(page)
    if page and page.topBar then
        page.topBar:showWithStyle({TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.BATTLE_FORCE})
    end
end

function QUIDialogConsortiaWarHallSetting:initListView()
    for i = 1, 4 do
        table.insert(self._data, {index = i})
    end
	if not self._listView then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemFunc),
	        curOriginOffset = 0,
	        isVertical = true,
	        enableShadow = true,
	      	ignoreCanDrag = true,
            headIndex = self._hallId,
	        totalNumber = #self._data,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listView:refreshData()
	end
end

function QUIDialogConsortiaWarHallSetting:_renderItemFunc( list, index, info )
    -- body
    local isCacheNode = true
    local itemData = self._data[index]
    local item = list:getItemFromCache(self._selectTab)
    if not item then
		item = QUIWidgetConsortiaWarHallSetting.new()
		item:addEventListener(QUIWidgetConsortiaWarHallSetting.EVENT_HEAD_CLICK, handler(self, self.headClickHandler))
    	isCacheNode = false
    end
    item:setInfo(itemData)
    info.item = item
    info.size = item:getContentSize()

    item:registerItemBoxPrompt(index, list)

    return isCacheNode
end

function QUIDialogConsortiaWarHallSetting:headClickHandler(event)
    if not event.name then
        return
    end
    local info = event.info

    local callback = function(isUpdate)
        if isUpdate then
            self._updateHallList[info.hallId] = true
            self:initListView()
        end
    end
    if info.userId ~= 0 then
        local callback1 = function()
            remote.consortiaWar:consortiaWarQueryFighterRequest(info.userId, function(data)
                local fighterInfo = data.consortiaWarQueryFighterResponse.fighter or {}
                app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogStromArenaPlayerInfo",
                    options = {fighterInfo = fighterInfo, isPVP = true}}, {isPopCurrentDialog = false})
            end)
        end
        local callback2 = function()
            remote.consortiaWar:updateTempHall(false, info.hallId, {memberId = info.userId})
            callback(true)
        end
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMutipleChooseButtons", 
            options = {name1 = "查看阵容", name2 = "取消上阵", callback1 = callback1, callback2 = callback2}}, {isPopCurrentDialog = false})
    else
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogConsortiaWarHallSelect",
            options = {info = info, callback = callback}})
    end
end

function QUIDialogConsortiaWarHallSetting:onTriggerBackHandler()
    self:popSelf()
    local defenseInfoList = {}
    local isUpdate = false
    for hallId, v in pairs(self._updateHallList) do
        local hallInfo = remote.consortiaWar:getTempHallByHallId(hallId)
        local memberList = {}
        for i, v in pairs(hallInfo.memberList) do
            table.insert(memberList, {memberId = v.memberId, isLeader = v.isLeader})
        end
        table.insert(defenseInfoList, {hallId = hallId, hallMemberInfoList = memberList})
        isUpdate = true
    end
    if isUpdate then
        remote.consortiaWar:consortiaWarSetHallDefenseInfoRequest(defenseInfoList, function()
            app.tip:floatTip("更新阵容成功！")
        end)
    end
end

function QUIDialogConsortiaWarHallSetting:_onTriggerClose()
    app.sound:playSound("common_cancel")
    self:playEffectOut()
end

return QUIDialogConsortiaWarHallSetting