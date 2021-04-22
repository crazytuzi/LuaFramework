--
-- Author: qinyuanji
-- Date: 2015-07-27 17:14:49
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUnion = class("QUIDialogUnion", QUIDialog)

local QScrollView = import("...views.QScrollView")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetUnionFound = import("..widgets.QUIWidgetUnionFound")

local QUIWidgetUnionBar = import("..widgets.QUIWidgetUnionBar")

local QUIWidgetUnionSearch = import("..widgets.QUIWidgetUnionSearch")
local QUIWidgetSocietyUnionJoin = import("..widgets.QUIWidgetSocietyUnionJoin")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIViewController = import("..QUIViewController")

local QListView = import("...views.QListView")

QUIDialogUnion.SHOW_COUNT = 100 --推荐宗门只向服务器请求前100个宗门

function QUIDialogUnion:ctor(options)
	-- local ccbFile = "ccb/Dialog_society_union.ccbi"
    local ccbFile = "ccb/Dialog_society_joinunion.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerJoin", callback = handler(self, self._onTriggerJoin)},
		{ccbCallbackName = "onTriggerFound", callback = handler(self, self._onTriggerFound)},
		{ccbCallbackName = "onTriggerSearch", callback = handler(self, self._onTriggerSearch)},
        {ccbCallbackName = "onTriggerOnekey", callback = handler(self, self._onTriggerOnekey)},
	}
	QUIDialogUnion.super.ctor(self,ccbFile,callBacks,options)

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setAllUIVisible(false)
    page.topBar:showWithUnionNormal()
    page:setScalingVisible(false)

    local currentButton = self:getOptions().initButton or "onTriggerJoin"

    q.setButtonEnableShadow(self._ccbOwner.btn_oneKey)
    q.setButtonEnableShadow(self._ccbOwner.btn_creat)
    q.setButtonEnableShadow(self._ccbOwner.btn_search)

    self._ccbOwner.sp_logo:setVisible(false)
    self._ccbOwner.node_right_center:setVisible(false)
    self._ccbOwner.frame_tf_title:setString("宗 门")

    self._isExit  = true
    self._data = {} 
    self._headIndex = 1
    -- by Kumo 出现这个界面的时候，说明玩家没有宗门，这时候，初始化养龙任务相关缓存数据
    remote.dragon:resetDragonTaskData()

    self:_onTriggerJoin()

    self:initListView()
    -- if currentButton == "onTriggerJoin" then
    --     self:_onTriggerJoin()
    -- elseif  currentButton == "onTriggerFound" then
    --     self:_onTriggerFound()
    -- elseif  currentButton == "onTriggerSearch" then
    --     self:_onTriggerSearch()
    -- end
end

function QUIDialogUnion:handleJoinUnion( )
    -- body
    remote.union:unionOpenRequest(function (data)

        if next(data.consortia) then
            app.tip:floatTip("恭喜您，加入宗门成功！") 
            remote.union:resetSocietyDungeonData()
            app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyUnionMain", options = {info = data.consortia}})
        end
    end)
end
function QUIDialogUnion:viewDidAppear()
    QUIDialogUnion.super.viewDidAppear(self)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.UNION_CONSORTIA_APPLY_RATIFY, QUIDialogUnion.handleJoinUnion, self)

    self:addBackEvent(false)

    self:setJoinCDTime()
end

-- function QUIDialogUnion:viewAnimationInHandler()
--    self._ccbOwner[self:getOptions().initButton or "onTriggerJoin"]()
-- end

function QUIDialogUnion:viewWillDisappear()
    QUIDialogUnion.super.viewWillDisappear(self)

    QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.UNION_CONSORTIA_APPLY_RATIFY, QUIDialogUnion.handleJoinUnion, self)

    self:removeBackEvent()
end

-- function QUIDialogUnion:onTriggerClose()
--     app.sound:playSound("common_close")
--     self:playEffectOut()
-- end

-- function QUIDialogUnion:viewAnimationOutHandler()
--     app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
-- end


function QUIDialogUnion:setJoinCDTime( )
    if remote.user.userConsortia.leave_at and remote.user.userConsortia.leave_at >0 then        
        if self._timeScheduler then
            scheduler.unscheduleGlobal(self._timeScheduler)
            self._timeScheduler = nil
        end
        local joinCD = db:getConfigurationValue("ENTER_SOCIETY") * 60 
        local endTime = remote.user.userConsortia.leave_at/1000 + joinCD
        local timeFunc = function ( )
            local lastTime = endTime - q.serverTime() 
            if self:safeCheck() then
                if lastTime > 0 then
                    local timeStr = q.timeToDayHourMinute(lastTime)
                    self._ccbOwner.tf_endtime:setString("加入宗门冷却时间："..timeStr)
                    self._ccbOwner.tf_endtime:setColor(COLORS.N)
                else 
                    if self._timeScheduler then
                        scheduler.unscheduleGlobal(self._timeScheduler)
                        self._timeScheduler = nil
                    end
                    self._ccbOwner.tf_endtime:setString("")
                end
            end
        end

        self._timeScheduler = scheduler.scheduleGlobal(timeFunc, 1)
        timeFunc()        
    end
end

function QUIDialogUnion:_onTriggerJoin(e)
    if e ~= nil then
        app.sound:playSound("common_switch")
    end
    if self._currentButton ~= "onTriggerJoin" then
        self._currentButton = "onTriggerJoin"

        if self._currentWidget then
            self._currentWidget:removeFromParentAndCleanup(true)
            self._currentWidget = nil
        end
       
        remote.union:unionRecommendListRequest(1,QUIDialogUnion.SHOW_COUNT,function (data)
            if self._appear then 
                -- if self._currentButton ~= "onTriggerJoin" then
                --     return
                -- end
                if data.consortiaRecommendList and data.consortiaRecommendList.totalConsortiaCount ~= 0 then
                    -- local client = QUIWidgetSocietyUnionJoin.new({parent = self})
                    -- self._ccbOwner.clientNode:addChild(client)
                    -- client:setInfo(data.consortiaRecommendList,1)
                    self._data = data.consortiaRecommendList.consortiaList or {}
                    -- self._currentWidget = client
                    self:initListView()
                else
                    self._ccbOwner.sp_logo:setVisible(true)
                end
            end    
        end)
    end
end

function QUIDialogUnion:initListView()
    -- body
    if not self._listView then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                -- body
                local isCacheNode = true
                local item = list:getItemFromCache()
                if not item then
                    item = QUIWidgetUnionBar.new()
                    isCacheNode = false
                end
                item:setInfo(self._data[index])
                info.item = item
                info.size = item:getContentSize()

                list:registerBtnHandler(index,"btn_join", "_onTriggerJoin", nil, true)
                list:registerBtnHandler(index,"cancelJoinBtn", "_onTriggerCancelJoin" )
                list:registerBtnHandler(index,"infoBtn", "_onTriggerInfo",1 )
                return isCacheNode
            end,
            totalNumber = #self._data,
            enableShadow = false,
            curOriginOffset = -5,
            curOffset = 5,
            headIndex = self._headIndex or 1,
            spaceY = 0,
            contentOffsetX = 1,
        }  
        self._listView = QListView.new(self._ccbOwner.itemList,cfg)
    else    
        self._listView:reload({totalNumber = #self._data,headIndex = self._headIndex or 1})
    end
end


function QUIDialogUnion:_onTriggerFound(e)
    if e ~= nil then
        app.sound:playSound("common_switch")
    end
    -- if self._currentButton ~= "onTriggerFound" then
    --     if self._currentWidget then
    --         self._currentWidget:removeFromParentAndCleanup(true)
    --         self._currentWidget = nil
    --     end

    --     local widget = QUIWidgetUnionFound.new()
    --     self._ccbOwner.clientNode:addChild(widget)

    --     self._currentWidget = widget
    --     self._currentButton = "onTriggerFound"
    -- end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogCreateUnion"})    
end

function QUIDialogUnion:_onTriggerSearch(e)
    if e ~= nil then
        app.sound:playSound("common_switch")
    end
    -- if self._currentButton ~= "onTriggerSearch" then
    --     if self._currentWidget then
    --         self._currentWidget:removeFromParentAndCleanup(true)
    --         self._currentWidget = nil
    --     end
    
    --     local widget = QUIWidgetUnionSearch.new()
    --     self._ccbOwner.clientNode:addChild(widget)

    --     self._currentWidget = widget
    --     self._currentButton = "onTriggerSearch"
    -- end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSearchUnion",options={}}) 

end

--describe：
function QUIDialogUnion:_onTriggerOnekey(event)
    if event ~= nil then app.sound:playSound("common_common") end

    if not remote.user:checkJoinUnionCdAndTips() then return end

    remote.union:unionOneKeyEnterRequest(function ( data )
        -- body
        app.tip:floatTip("恭喜您，加入宗门成功！") 
        remote.union:resetSocietyDungeonData()
        if self:safeCheck() then
            self:onTriggerBackHandler()
        end
        if data.consortia then
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyUnionMain", options = {info = data.consortia}})
        end
    end)
end

function QUIDialogUnion:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

-- function QUIDialogUnion:onTriggerHomeHandler(tag)
--     app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
-- end



return QUIDialogUnion
