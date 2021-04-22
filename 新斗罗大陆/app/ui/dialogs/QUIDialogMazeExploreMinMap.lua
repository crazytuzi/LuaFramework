local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMazeExploreMinMap = class("QUIDialogMazeExploreMinMap", QUIDialog)
local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")

local QUIMazeExploreMapController = import("..controllers.QUIMazeExploreMapController")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QMazeExplore = import(".QMazeExplore")


local QUIDialogMazeExploreMap = import("..dialogs.QUIDialogMazeExploreMap")
local QUIWidgetMazeExploreLine = import("..widgets.QUIWidgetMazeExploreLine")

function QUIDialogMazeExploreMinMap:ctor(options)
	local ccbFile = "ccb/Dialog_MazeExplore_MinMap.ccbi"
	local callBacks = {
		-- {ccbCallbackName = "onTriggerRule", 				callback = handler(self, self._onTriggerRule)},
		-- {ccbCallbackName = "onTriggerRecord", 				callback = handler(self, self._onTriggerRecord)},
  --       {ccbCallbackName = "onTriggerStore",                callback = handler(self, self._onTriggerStore)},
		-- {ccbCallbackName = "onTriggerMinMap", 				callback = handler(self, self._onTriggerMinMap)},
	}
	QUIDialogMazeExploreMinMap.super.ctor(self,ccbFile,callBacks,options)

	CalculateUIBgSize(self._ccbOwner.node_bg_main , 1280)
	CalculateUIBgSize(self._ccbOwner.sp_bg )

	self._curMapData = options.curMapData
	self._curMapLineData = options.curMapLineData
	self._ccpGrid = options.ccpGrid
	self._ccpAll = options.ccpAll

	self._mSceneDis = {1,2,3}

    self._minScalX =  0.6
    self._minScalY =  0.6
    self._width = QUIMazeExploreMapController.PER_GRID_WIDTH * self._minScalX -- 36
    self._height = QUIMazeExploreMapController.PER_GRID_HEIGHT * self._minScalY -- 20
end

function QUIDialogMazeExploreMinMap:viewDidAppear()
	QUIDialogMazeExploreMinMap.super.viewDidAppear(self)
	self:_initMap()
    self:addBackEvent(true)
end

function QUIDialogMazeExploreMinMap:viewWillDisappear()
  	QUIDialogMazeExploreMinMap.super.viewWillDisappear(self)
    if self._moveEndScheduler then
        scheduler.unscheduleGlobal(self._moveEndScheduler)
        self._moveEndScheduler = nil
    end
    self:removeBackEvent()
end

function QUIDialogMazeExploreMinMap:_initMap()

    self._minGrids = {}
    self._minLines = {}
    self._minGridEvents = {}
    if not self._mazeExploreDataHandle then
        self._mazeExploreDataHandle = remote.activityRounds:getMazeExplore()
    end
    self:_drawMapByData(self._curMapData,QUIDialogMazeExploreMap.GRID_TYPE)
    self:_drawMapByData(self._curMapLineData,QUIDialogMazeExploreMap.LINE_TYPE)
    self:_updateMinMapCellByData({},QUIDialogMazeExploreMap.ROLE_TYPE)
	self:_madeTouchLayer()

	self:_updateMapContentPosition(self._ccpAll.x * self._minScalX ,self._ccpAll.y* self._minScalY )
	self:_updateMapLayerPosition(self._ccpGrid.x* self._minScalX ,self._ccpGrid.y* self._minScalY )

end

function QUIDialogMazeExploreMinMap:_drawMapByData(_pDatas , ctype)
	for i,v in pairs(_pDatas or {}) do
		self:_updateMinMapCellByData(v,ctype)
	end
end

function QUIDialogMazeExploreMinMap:_updateMinMapCellByData(_pData , ctype)


    if ctype == QUIDialogMazeExploreMap.GRID_TYPE then
        self:_createGrid(_pData)
        self:_createEvent(_pData)

    elseif ctype == QUIDialogMazeExploreMap.LINE_TYPE then
        self:_createLine(_pData)
    elseif ctype == QUIDialogMazeExploreMap.ROLE_TYPE then  --人物
        if self._role == nil then
            self._role = CCSprite:create()
            self._ccbOwner.node_role_layer:addChild(self._role)
            self._role:setPositionY(28)
            QSetDisplayFrameByPath(self._role, QResPath("mazeExplore_grid_sp")[9])
        end
    end
end


function QUIDialogMazeExploreMinMap:_createGrid(_pData)

    local cell = self._minGrids[_pData.id]
    if not self._minGrids[_pData.id] then
        cell = CCSprite:create()
        self._minGrids[_pData.id] = cell
        self._ccbOwner.node_bottom_layer:addChild(cell)
        cell:setPosition(ccp((_pData.gridX ) * self._width , (_pData.gridY ) * self._height ))
        cell:setScale(0.6)
    end
    local res = QResPath("mazeExplore_grid_sp")[1]
    if _pData.isNpc then
        res = QResPath("mazeExplore_grid_sp")[10]   
    elseif _pData.state ==  QUIMazeExploreMapController.GRID_TYPE.VISIBLE then
        res = QResPath("mazeExplore_grid_sp")[2]
    end
    QSetDisplayFrameByPath(cell, res)
end

function QUIDialogMazeExploreMinMap:_createEvent(_pData)
    local config = self._mazeExploreDataHandle:getMazeExploreConfigsById(_pData.id)
    local event_type = tonumber(config.event_type)

    if QUIMazeExploreMapController.GRID_TYPE.NULL_EVENT ~= _pData.state
     or event_type == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_ENDPOINT 
     or event_type == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIGHTHOUSE 
     then
        local cell = self._minGridEvents[_pData.id]
        if not self._minGridEvents[_pData.id] then
            cell = CCSprite:create()
            self._minGridEvents[_pData.id] = cell
            self._ccbOwner.node_top_layer:addChild(cell)
            cell:setPosition(ccp((_pData.gridX ) * self._width , (_pData.gridY ) * self._height + 8))
            cell:setScale(0.6)
        end
        local res = QResPath("mazeExplore_gridSprite")[1]
        if config then
            if  QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_NORMAL == event_type then
                cell:setVisible(false)
            elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_FIXAWARDS == event_type then
                res = QResPath("mazeExplore_gridSprite")[11]
            elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_RANDAWARDS == event_type then
                res = QResPath("mazeExplore_gridSprite")[11]
            elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_EVENTAWARDS == event_type then
                res = QResPath("mazeExplore_gridSprite")[25]
            elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_CHESTAWARDS == event_type then
                res = QResPath("mazeExplore_gridSprite")[10]
            elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_ACTORSPECK == event_type then
                res = QResPath("mazeExplore_gridSprite")[16]
            elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_TXTSPECK == event_type then
                res = QResPath("mazeExplore_gridSprite")[2]
            elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_PORTAL == event_type then
                res = QResPath("mazeExplore_gridSprite")[15]
            elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_SECRET_ONOFF == event_type then
                res = QResPath("mazeExplore_gridSprite")[6]
                    cell:setPositionY(cell:getPositionY() - 3 )
            elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_SECRET_BE == event_type then
                cell:setVisible(false)
            elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIGHTHOUSE == event_type then
                res = QResPath("mazeExplore_gridSprite")[5]
                cell:setPositionY(cell:getPositionY() + 13 )
            elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_ROCKS == event_type then
                res = QResPath("mazeExplore_gridSprite")[24]
                if _pData.state == QUIMazeExploreMapController.GRID_TYPE.VISIBLE then
                    res = QResPath("mazeExplore_gridSprite")[23]
                end
                cell:setPositionY(cell:getPositionY() - 8 )
            elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_SOLDIERS == event_type then
                res = QResPath("mazeExplore_gridSprite")[13]
                cell:setPositionY(cell:getPositionY() + 7 )
            elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_REMOVE == event_type then
                res = _pData.config.pic
            elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIFTS_BE == event_type then
                if _pData.isClose then
                    res = QResPath("mazeExplore_gridSprite")[4]
                    cell:setPositionY(cell:getPositionY() + 8 )
                else
                    res = QResPath("mazeExplore_gridSprite")[3]
                    cell:setPositionY(cell:getPositionY() - 7 )
                end
            elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIFTS_ONOFF == event_type then
                res = QResPath("mazeExplore_gridSprite")[6]
                    cell:setPositionY(cell:getPositionY() - 3 )
            elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_TOSTAB == event_type then
                res = QResPath("mazeExplore_gridSprite")[9]
                cell:setPositionY(cell:getPositionY() - 3 )
            elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_FINGERGAME == event_type then
                cell:setPositionY(cell:getPositionY() - 8 )
                res = QResPath("mazeExplore_gridSprite")[1]
            elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_DICE == event_type then
                res = QResPath("mazeExplore_gridSprite")[17]
            elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_BOSS == event_type then
                res = QResPath("mazeExplore_gridSprite")[22]
                if _pData.state == QUIMazeExploreMapController.GRID_TYPE.VISIBLE then
                    res = QResPath("mazeExplore_gridSprite")[21]
                end
                cell:setPositionY(cell:getPositionY() - 4 )
                cell:setPositionX(cell:getPositionX() - 4 )
            elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_ENDPOINT == event_type then
                res = QResPath("mazeExplore_gridSprite")[18]
                cell:setPositionY(cell:getPositionY() + 7 )
            elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_STARTPOINT == event_type then
                cell:setVisible(false)
            end
        end
        QSetDisplayFrameByPath(cell, res)
    end
end


function QUIDialogMazeExploreMinMap:_createLine(_pData)

        local cell = self._minLines[_pData.id]
        if not self._minLines[_pData.id] then
            cell = QUIWidgetMazeExploreLine.new()
            self._minLines[_pData.id] = cell
            self._ccbOwner.node_bottom_layer:addChild(cell)
            cell:initGLLayer()
        end
        cell:setInfo(_pData,0.6)
end


function QUIDialogMazeExploreMinMap:_madeTouchLayer()
    self._pageWidth = display.width
    self._pageHeight = display.height
    self._mapContent = self._ccbOwner.node_map

    self._touchLayer = QUIGestureRecognizer.new()
    self._touchLayer:setSlideRate(0.3)
    self._touchLayer:setAttachSlide(true)
    self._touchLayer:attachToNode(self._mapContent:getParent(), self._pageWidth, self._pageHeight, -self._pageWidth/2, -self._pageHeight/2, handler(self, self._onTouchEvent))

    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self._onTouchEvent))
    -- self._mapContent:setPosition(ccp(QUIDialogMazeExploreMap.MAP_CENTER_X,QUIDialogMazeExploreMap.MAP_CENTER_Y))
end


function QUIDialogMazeExploreMinMap:_updateMapContentPosition(posX,posY)
    if posX then
        self._mapContent:setPositionX(posX)
    end
    if posY then
        self._mapContent:setPositionY(posY)
    end
end

function QUIDialogMazeExploreMinMap:_updateMapLayerPosition(posX,posY)
    if posX then
        self._ccbOwner.node_top_layer:setPositionX(posX)
        self._ccbOwner.node_bottom_layer:setPositionX(posX)
    end
    if posY then
        self._ccbOwner.node_top_layer:setPositionY(posY)
        self._ccbOwner.node_bottom_layer:setPositionY(posY)
    end
end

function QUIDialogMazeExploreMinMap:_onTouchEvent(event)
    if event == nil or event.name == nil then
        return
    end

    --     print(event.name)
    -- if event.name == "began" then
    --     self._tmpX = event.x
    --     self._tmpY = event.y
    -- elseif event.name == "ended" then
    --     if math.abs(event.x - self._tmpX) <= 5 and math.abs(event.y - self._tmpY) <= 5 and not self._isMove  then
    --         if not self._isTouchScreen then
    --             -- self:_backClickHandler()
    --         end
    --     end
    --     self._isTouchScreen = false
    -- end

    -- if self._mapWidth <= self._pageWidth and self._mapHeight <= self._pageHeight then
    --     return 
    -- end
    if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
    elseif event.name == QUIGestureRecognizer.EVENT_SWIPE_GESTURE then
    elseif event.name == "began" then
        self._startX = event.x
        self._startY = event.y

        self._mapX = self._mapContent:getPositionX()
        self._mapY = self._mapContent:getPositionY()
    elseif event.name == "moved" then
        if math.abs(event.x - self._startX) > 5 then
            self._isMove = true
            local offsetX = self:_checkMapX(self._mapX + event.x - self._startX)
            self:_updateMapContentPosition(offsetX,nil)
        end

        if math.abs(event.y - self._startY) > 5 then
            self._isMove = true
            local offsetY = self:_checkMapY(self._mapY + event.y - self._startY)
            -- self._mapContent:setPositionY(offsetY)
            -- self._minmap_node:setPositionY(offsetY * self._minScalY + self._centerHeight)
            self:_updateMapContentPosition(nil,offsetY)
        end
    elseif event.name == "ended" then

        if self._moveEndScheduler then
            scheduler.unscheduleGlobal(self._moveEndScheduler)
            self._moveEndScheduler = nil
        end
        self._moveEndScheduler = scheduler.performWithDelayGlobal(self:safeHandler(function ()
                     self._isMove = false
                    end), 0.1)
    end
end


function QUIDialogMazeExploreMinMap:_checkMapX(x)
    -- if not x or x > (self._mapWidth - self._pageWidth)/2 then
    --     x = (self._mapWidth - self._pageWidth)/2
    -- elseif x < -(self._mapWidth - self._pageWidth)/2 then
    --     x = -(self._mapWidth - self._pageWidth)/2
    -- end
    return x
end

function QUIDialogMazeExploreMinMap:_checkMapY(y)
    -- if not y or y > (self._mapHeight - self._pageHeight)/2 then
    --     y = (self._mapHeight - self._pageHeight)/2
    -- elseif y < -(self._mapHeight - self._pageHeight)/2 then
    --     y = -(self._mapHeight - self._pageHeight)/2
    -- end

    return y
end

function QUIDialogMazeExploreMinMap:_backClickHandler()
    if  self._isMove then
        return
    end

    self:playEffectOut()
end

function QUIDialogMazeExploreMinMap:viewAnimationOutHandler()
    local callback = self._callback

    self:popSelf()

    if callback then
        callback(self._endBack)
    end
end

return QUIDialogMazeExploreMinMap