


local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMazeExploreMap = class("QUIDialogMazeExploreMap", QUIDialog)
local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")

local QUIWidgetMazeExploreGrid = import("..widgets.QUIWidgetMazeExploreGrid")
local QUIWidgetMazeExploreLine = import("..widgets.QUIWidgetMazeExploreLine")
local QUIWidgetMazeExploreRole = import("..widgets.QUIWidgetMazeExploreRole")
local QUIMazeExploreMapController = import("..controllers.QUIMazeExploreMapController")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QMazeExplore = import(".QMazeExplore")

QUIDialogMazeExploreMap.OFFSIDE_NUM = 2


QUIDialogMazeExploreMap.MAP_CENTER_X = 0
QUIDialogMazeExploreMap.MAP_CENTER_Y = 0



QUIDialogMazeExploreMap.GRID_TYPE = 1
QUIDialogMazeExploreMap.LINE_TYPE = 2
QUIDialogMazeExploreMap.ROLE_TYPE = 3


function QUIDialogMazeExploreMap:ctor(options)
	local ccbFile = "ccb/Dialog_MazeExplore_Map.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerRule", 				callback = handler(self, self._onTriggerRule)},
		{ccbCallbackName = "onTriggerExploreRecord", 		callback = handler(self, self._onTriggerExploreRecord)},
        {ccbCallbackName = "onTriggerMemoryAward",          callback = handler(self, self._onTriggerMemoryAward)},
        {ccbCallbackName = "onTriggerAwardPreview",         callback = handler(self, self._onTriggerAwardPreview)},
		{ccbCallbackName = "onTriggerMinMap", 				callback = handler(self, self._onTriggerMinMap)},
	}
	QUIDialogMazeExploreMap.super.ctor(self,ccbFile,callBacks,options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.setManyUIVisible then page:setManyUIVisible() end
	if page.setScalingVisible then page:setScalingVisible(false) end

    self._mazeExploreDataHandle = remote.activityRounds:getMazeExplore()
    local power = self._mazeExploreDataHandle:getMazeExplorePowers()
    if page.topBar then page.topBar:showMazeExplore(power) end
        
    CalculateUIBgSize(self._ccbOwner.node_bg_main , 1280)
    -- CalculateUIBgSize(self._ccbOwner.node_bg , 1280)
 --    AdaptationUIBgSize(self._ccbOwner.sp_bg)
	-- AdaptationUIBgSize(self._ccbOwner.sp_bg_cover)
    
    q.setButtonEnableShadow(self._ccbOwner.btn_record)
    q.setButtonEnableShadow(self._ccbOwner.btn_memoryAward)

	self.info = options.info

    self._minScalX =  36 / QUIMazeExploreMapController.PER_GRID_WIDTH 
    self._minScalY =  20 / QUIMazeExploreMapController.PER_GRID_HEIGHT 

end

function QUIDialogMazeExploreMap:viewDidAppear()
	QUIDialogMazeExploreMap.super.viewDidAppear(self)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIMazeExploreMapController.MAP_GRID_UPDATE_UPDATE, self.updateMap, self)
	self:addBackEvent(true)
    self._activityRoundsProxy = cc.EventProxy.new(remote.activityRounds)
    self._activityRoundsProxy:addEventListener(remote.activityRounds.MAZE_EXPLORE_UPDATE, handler(self, self.onEventUpdate))
    self._activityRoundsProxy:addEventListener(QMazeExplore.CONTINUE_WALK, handler(self, self.onEventContinueWalk))
    self._activityRoundsProxy:addEventListener(QMazeExplore.PLAY_EFFECT, handler(self, self.onEventPlayEffect))

    QNotificationCenter.sharedNotificationCenter():addEventListener(QMazeExplore.GRID_EVENT_USE_PORTAL_SVR , self.onEventPortal, self)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)

    app:getUserOperateRecord():setRecordByType("MAZE_EXPLORE_CLICK_"..(self._mazeExploreDataHandle.activityId or "activityId")..(self.info.chapterId or 0),true)

    self:checkRedTips()
    self:_initMinMap()
    self:_madeTouchLayer()
    self:_initMap()
    -- self:_checkIsFirstEnterMap()

end

function QUIDialogMazeExploreMap:viewWillDisappear()
  	QUIDialogMazeExploreMap.super.viewWillDisappear(self)
	self:removeBackEvent()
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIMazeExploreMapController.MAP_GRID_UPDATE_UPDATE, self.updateMap, self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QMazeExplore.GRID_EVENT_USE_PORTAL_SVR , self.onEventPortal, self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)

    if self._activityRoundsProxy ~= nil then 
        self._activityRoundsProxy:removeAllEventListeners()
        self._activityRoundsProxy = nil
    end

    if self._moveEndScheduler then
        scheduler.unscheduleGlobal(self._moveEndScheduler)
        self._moveEndScheduler = nil
    end

    if self._mapController then
        self._mapController:disappear()
    end
end

function QUIDialogMazeExploreMap:exitFromBattleHandler(event)
    self._mapController:_updateBossInfo()
    self:_updateMapByData()
    self:_updateProgress()
end

function QUIDialogMazeExploreMap:onEventUpdate(event)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if self._mazeExploreDataHandle then
        local power = self._mazeExploreDataHandle:getMazeExplorePowers()
        if page.topBar then page.topBar:showMazeExplore(power) end
    end
    if self._mazeExploreDataHandle.isOpen == false then
        app.tip:floatTip("魂师大人，当前活动已结束")
        self:popSelf()
        return
    end    
    self:checkRedTips()
end

function QUIDialogMazeExploreMap:checkRedTips( )
    local b = self._mazeExploreDataHandle:checkMemoryAwardTips()
    self._ccbOwner.sp_memoryAward_tips:setVisible(b)
end

function QUIDialogMazeExploreMap:onEventContinueWalk(event)
    self:_updateRoleMove()
end

function QUIDialogMazeExploreMap:updateMap(event)
    self:_updateMapByData()
    self:_updateProgress()
    self:checkNeedPlayMoveAction()
    -- self:_updateRoleMove()
end

function QUIDialogMazeExploreMap:onEventPlayEffect( event )
    app.sound:playSound("map_fireworks")
    local ccbFile = "ccb/Widget_MazeExplore_Boom.ccbi"
    local proxy = CCBProxy:create()
    local aniCcbOwner = {}
    local aniCcbView = CCBuilderReaderLoad(ccbFile, proxy, aniCcbOwner)
    self._ccbOwner.node_cloud:removeAllChildren()
    self._ccbOwner.node_cloud:addChild(aniCcbView)
    self._cloudManager = tolua.cast(aniCcbView:getUserObject(), "CCBAnimationManager")
    self._cloudManager:runAnimationsForSequenceNamed("close")
    self._cloudManager:connectScriptHandler(function(str)
            if str == "close" then
                self._mazeExploreDataHandle:moveToFindPosEvent(event.gridInfo)
            end
        end)    
end
--初始化场景
function QUIDialogMazeExploreMap:_initMap()
    self:_resetPathList()

	self._mapController = QUIMazeExploreMapController.new(self.info.chapterId)

    self._mapWidth = 0
    self._mapHeight = 0

	self._mapWidth = self._mapController:getMaxWidth()
	self._mapHeight = self._mapController:getMaxHeight()


	self._grids = {}
	self._gridEvents = {}
	self._lines = {}

    self:_updateMapByData(true)
	self._mGridVec2d = self._mapController:getMyGridPos() -- ccp(0, 0) 玩家所在地格位置信息 int型参数
	self:_updateMapCellByData({},QUIDialogMazeExploreMap.ROLE_TYPE) -- 初始化生成人物	可能主要添加数据info  包括人物skin的id 或者config
    self:_updateMinMapCellByData({},QUIDialogMazeExploreMap.ROLE_TYPE)
	--初始化玩家位置 根据玩家地格信息转化成坐标
	local rolePosition = ccp(- self._mGridVec2d[1] * QUIMazeExploreMapController.PER_GRID_WIDTH ,- self._mGridVec2d[2] * QUIMazeExploreMapController.PER_GRID_HEIGHT )
    self:_updateMapLayerPosition(rolePosition.x,rolePosition.y)

    self:_initBackgroundSprite()

    self:_updateProgress()
end

function QUIDialogMazeExploreMap:_initMinMap()

    self._minGrids = {}
    self._minLines = {}
    self._centerWidth = self._ccbOwner.sp_mimap:getContentSize().width * 0.9 * 0.5
    self._centerHeight = self._ccbOwner.sp_mimap:getContentSize().height * 0.9 * 0.5

    self._clipContent = CCNode:create() --裁剪区域的
    local centerNode = CCNode:create()
    self._clipContent:addChild(centerNode)   
    centerNode:setPositionX(self._centerWidth)
    centerNode:setPositionY(self._centerHeight)

    self._minmap_node = CCNode:create()
    centerNode:addChild(self._minmap_node)   

    self._minmap_gridNode = CCNode:create()
    self._minmap_node:addChild(self._minmap_gridNode)       
    self._minmap_roleNode = CCNode:create()
    self._minmap_node:addChild(self._minmap_roleNode)   

    -- local layerColor = CCLayerColor:create(ccc4(0,0,0,255), self._ccbOwner.sp_mimap:getContentSize().width, self._ccbOwner.sp_mimap:getContentSize().height)
    local layerColor = CCLayerColor:create(ccc4(0,0,0,255), self._centerWidth * 2 , self._centerHeight * 2)
    local ccclippingNode = CCClippingNode:create()
    ccclippingNode:setPositionX(self._ccbOwner.sp_mimap:getPositionX() - self._centerWidth )
    ccclippingNode:setPositionY(self._ccbOwner.sp_mimap:getPositionY() - self._centerHeight )
    ccclippingNode:setStencil(layerColor)
    ccclippingNode:addChild(self._clipContent)
    self._ccbOwner.node_minmap:addChild(ccclippingNode)   

end

function QUIDialogMazeExploreMap:_initBackgroundSprite()

    -- self._bgSpTbl= {}
    -- self._bgSpTbl[1]= {}
    -- self._bgSpTbl[2]= {}
    -- self._bgSpTbl[3]= {}
    local nodeNameTbl = {"near","mid","far"}
    local nodeNamePosY = {-120,0,0}
    for i=1,3 do
        for k=1,7 do
            -- print(QResPath("mazeExplore_bg_sp")[i])
            local sprite = CCSprite:create()
            QSetDisplayFrameByPath(sprite, QResPath("mazeExplore_bg_sp")[i])
            local height = sprite:getContentSize().height
            local width = sprite:getContentSize().width - 50
            self._ccbOwner["node_"..nodeNameTbl[i]]:addChild(sprite)
            sprite:setPositionX((k-2) * width )
            sprite:setPositionY( height * 0.5 + nodeNamePosY[i])
            -- local data = {sprite = sprite ,width = width  }
            -- table.insert(self._bgSpTbl[i],)
        end
    end
end


function QUIDialogMazeExploreMap:_checkIsFirstEnterMap()
    if self._mapController:getIsFirstEnterMap() then
       local targetGrid = self._mapController:getEndGridPos()
        local sprite = CCSprite:create()
        QSetDisplayFrameByPath(sprite, QResPath("mazeExplore_grid_sp")[1])
        local position = ccp(targetGrid[1] * QUIMazeExploreMapController.PER_GRID_WIDTH , targetGrid[2] * QUIMazeExploreMapController.PER_GRID_HEIGHT )
        sprite:setPosition(position)
        self._ccbOwner.node_bottom_layer:addChild(sprite)
        local callback = CCCallFunc:create(function () 
            sprite:removeFromParentAndCleanup(true)
        end)
        local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCDelayTime:create(1.5))
        actionArrayIn:addObject(callback)
        local ccsequence = CCSequence:create(actionArrayIn)
        sprite:runAction(ccsequence) 


        self:_moveCameraToGrid(targetGrid[1],targetGrid[2] , 0 ,nil,0.5)
        self._mazeExploreDataHandle:setFirstEnterChapter(self.info.chapterId)
    end
end


function QUIDialogMazeExploreMap:_updateMapByData(isInit)
    local curMapData = self._mapController:getUpdateMapData()   --{id = 1 , gridX = 0 , gridY = 0  , state }
    local curMapLineData = self._mapController:getUpdateMapLineData()   --{gridX = 0 , gridY = 0 , ctype = 1 ,lines = {17,18}}
    self:_drawMapByData(curMapData,QUIDialogMazeExploreMap.GRID_TYPE , isInit)
    self:_drawMapByData(curMapLineData,QUIDialogMazeExploreMap.LINE_TYPE,isInit)
end


function QUIDialogMazeExploreMap:_drawMapByData(_pDatas , ctype , isInit)
	for i,v in pairs(_pDatas or {}) do
        self:_updateMapCellByData(v,ctype, isInit)
		self:_updateMinMapCellByData(v,ctype, isInit)
	end
end

function QUIDialogMazeExploreMap:checkNeedPlayMoveAction()

    local coord = self._mapController:getMyMoveGrid()
    if coord then
        local callback2 = CCCallFunc:create(function () 
            QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIMazeExploreMapController.MAP_GRID_EVENT_SECRET_BE_SHOW})   
        end)

        self:_moveCameraToGrid(coord[1],coord[2] , nil ,nil,1.5 , callback2)
        self._mapController:setMyMoveGridToNull()
    end

end


--node_map 
--node_bottom_layer、node_top_layer、node_role_layer
function QUIDialogMazeExploreMap:_updateMapCellByData(_pData , ctype, isInit)
	if ctype == QUIDialogMazeExploreMap.GRID_TYPE then
		local cell = self._grids[_pData.id]
		if not self._grids[_pData.id] then
			cell = QUIWidgetMazeExploreGrid.new()
			self._grids[_pData.id] = cell
			self._ccbOwner.node_bottom_layer:addChild(cell)
		end
		cell:setInfo(_pData, isInit)
		-- 事件层可以根据 地格的状态来刷新创建。如果地格事件已经失效可以不进行创建或者直接删除
        local neeDelete= self:_checkNeedDeleteByData(_pData)
        if QUIMazeExploreMapController.GRID_TYPE.NULL_EVENT == _pData.state and neeDelete then
            cell  = self._gridEvents[_pData.id]
            if cell then
                cell:playDisappearActionAndRemoveSelf()
            end
        else
            cell  = self._gridEvents[_pData.id]
            if not self._gridEvents[_pData.id] then
                cell = QUIWidgetMazeExploreGrid.new()
             if _pData.config.event_type == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_SOLDIERS 
                or _pData.config.event_type == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIGHTHOUSE 
                -- or _pData.config.event_type == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_BOSS 
                then
                self._ccbOwner.node_top_layer:addChild(cell)
            else
                self._ccbOwner.node_mid_layer:addChild(cell)
            end

                self._gridEvents[_pData.id] = cell
            end
            cell:setEventInfo(_pData , isInit)            
        end
	elseif ctype == QUIDialogMazeExploreMap.LINE_TYPE then
		local cell = self._lines[_pData.id]
		if not self._lines[_pData.id] then
			cell = QUIWidgetMazeExploreLine.new()
			self._lines[_pData.id] = cell
			self._ccbOwner.node_bottom_layer:addChild(cell)
		end
		cell:setInfo(_pData , 1, isInit)
	elseif ctype == QUIDialogMazeExploreMap.ROLE_TYPE then	--人物
		if self._role == nil then
			self._role = QUIWidgetMazeExploreRole.new()
			self._ccbOwner.node_role_layer:addChild(self._role)
		end
		self._role:setInfo(_pData)
	end

end


function QUIDialogMazeExploreMap:_checkNeedDeleteByData(_pData)
    if _pData.config  then
        local event_type = tonumber( _pData.config.event_type)
        if QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_ENDPOINT == event_type or QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIGHTHOUSE == event_type then
            return false
        end
    end
    return true
end

function QUIDialogMazeExploreMap:_updateMinMapCellByData(_pData , ctype, isInit)

    local width = QUIMazeExploreMapController.PER_GRID_WIDTH * self._minScalX -- 36
    local height = QUIMazeExploreMapController.PER_GRID_HEIGHT * self._minScalY -- 20
    -- print("width    `"..width)
    -- print("height    `"..height)
    -- print("_minScalX    `"..self._minScalX)
    -- print("_minScalY    `"..self._minScalY)
    -- self._minGrids = {}
    -- self._minLines = {}
    if ctype == QUIDialogMazeExploreMap.GRID_TYPE then
        local cell = self._minGrids[_pData.id]
        if not self._minGrids[_pData.id] then
            cell = CCSprite:create()
            self._minGrids[_pData.id] = cell
            self._minmap_gridNode:addChild(cell)
            cell:setPosition(ccp((_pData.gridX ) * width , (_pData.gridY ) * height ))
        end
        local res = QResPath("mazeExplore_grid_sp")[5]
        if _pData.state ==  QUIMazeExploreMapController.GRID_TYPE.VISIBLE then
            res = QResPath("mazeExplore_grid_sp")[6]
        elseif _pData.isNpc then
            res = QResPath("mazeExplore_grid_sp")[12]               
        end
        QSetDisplayFrameByPath(cell, res)
    elseif ctype == QUIDialogMazeExploreMap.LINE_TYPE then
        local cell = self._minLines[_pData.id]
        if not self._minLines[_pData.id] then
            cell = CCSprite:create()
            self._minLines[_pData.id] = cell
            self._minmap_gridNode:addChild(cell)
            cell:setPosition(ccp((_pData.gridX - 0.5) * width , (_pData.gridY - 0.5) * height ))    
            local number = tonumber(_pData.gridX) + tonumber(_pData.gridY) 
            if number % 2 ~= 0 then --右上
                cell:setScaleX(1)
            else    --右下
                cell:setScaleX(-1)
            end
        end
        local res = QResPath("mazeExplore_grid_sp")[7]
        if _pData.state ==  QUIMazeExploreMapController.GRID_TYPE.VISIBLE then
            res = QResPath("mazeExplore_grid_sp")[8]
        elseif _pData.isNpc then
            res = QResPath("mazeExplore_grid_sp")[13]            
        end
        QSetDisplayFrameByPath(cell, res)
    elseif ctype == QUIDialogMazeExploreMap.ROLE_TYPE then  --人物
        if self._minrole == nil then
            self._minrole = CCSprite:create()
            self._minmap_roleNode:addChild(self._minrole)
            self._minrole:setScale(0.5)
            self._minrole:setPositionY(12)
            QSetDisplayFrameByPath(self._minrole, QResPath("mazeExplore_grid_sp")[9])
        end
    end
end

function QUIDialogMazeExploreMap:_updateProgress()
    local progress = self._mapController:getCurProgress()
    local scale = progress/100 
    scale = scale >1 and 1 or scale
    print("scale "..scale)
    self._ccbOwner.sp_progress_bar:setScaleX(scale)
    scale = math.floor(scale * 100)
    self._ccbOwner.tf_progress:setString(tostring(scale).."%")
end


--移动地图  正常的node_map位移需要判断边缘的拖拽 三景也会跟着变化
function QUIDialogMazeExploreMap:_updateMapPosition(gridVec2d)

end

--角色移动	移动地图 +  角色的反向移动 
--只移动node_bottom_layer、node_top_layer两层 并记录2层的位移距离
function QUIDialogMazeExploreMap:_updateRolePosition(gridVec2d)

end

-- 地图初始化，相对于屏幕是上下左右居中摆放（这一点不能变，重要）
function QUIDialogMazeExploreMap:_madeTouchLayer()
    self._pageWidth = display.width
    self._pageHeight = display.height
    self._mapContent = self._ccbOwner.node_map

    self._mapContent:retain()
    self._mapContent:removeFromParentAndCleanup(false)
    local posNode = CCNode:create()
    posNode:addChild(self._mapContent)
    self._mapContent:release()

    local layerColor = CCLayerColor:create(ccc4(0,0,0,255), self._pageWidth , self._pageHeight * 0.85)
    local ccclippingNode = CCClippingNode:create()
    ccclippingNode:setPositionX(- self._pageWidth * 0.5 )
    ccclippingNode:setPositionY(- self._pageHeight * 0.5 )
    -- ccclippingNode:setPositionY(self._ccbOwner.sp_mimap:getPositionY() - self._centerHeight )
    ccclippingNode:setStencil(layerColor)
    ccclippingNode:addChild(posNode)
    self._ccbOwner.node_clip:addChild(ccclippingNode)  
    posNode:setPositionX(self._pageWidth * 0.5)
    posNode:setPositionY(self._pageHeight * 0.45)
    
    self._touchLayer = QUIGestureRecognizer.new()
    self._touchLayer:setSlideRate(0.3)
    self._touchLayer:setAttachSlide(true)
    self._touchLayer:attachToNode(self._mapContent:getParent(), self._pageWidth, self._pageHeight, -self._pageWidth/2, -self._pageHeight/2, handler(self, self._onTouchEvent))

    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self._onTouchEvent))
    self:_updateMapContentPosition(QUIDialogMazeExploreMap.MAP_CENTER_X,QUIDialogMazeExploreMap.MAP_CENTER_Y)
    -- self._mapContent:setPosition(ccp(QUIDialogMazeExploreMap.MAP_CENTER_X,QUIDialogMazeExploreMap.MAP_CENTER_Y))


end


function QUIDialogMazeExploreMap:_onTouchEvent(event)
    if event == nil or event.name == nil then
        return
    end
    if self._isAutoMove then return end


    if event.name == "began" then
        self._tmpX = event.x
        self._tmpY = event.y
    elseif event.name == "ended" then
        if math.abs(event.x - self._tmpX) <= 5 and math.abs(event.y - self._tmpY) <= 5 then
            if not self._isTouchScreen then
                if not self:_isOnTriggerGrid(event.x, event.y) then -- 不是点击地格
                end
            end
        end
        self._isTouchScreen = false
    end

    if self._mapWidth <= self._pageWidth and self._mapHeight <= self._pageHeight then
        return 
    end
    if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
    elseif event.name == QUIGestureRecognizer.EVENT_SWIPE_GESTURE then
    elseif event.name == "began" then
        self:_removeAction()
        self._startX = event.x
        self._startY = event.y

        self._mapX = self._mapContent:getPositionX()
        self._mapY = self._mapContent:getPositionY()
    elseif event.name == "moved" then
        if math.abs(event.x - self._startX) > 5 then
            self._isMove = true
            local offsetX = self:_checkMapX(self._mapX + event.x - self._startX)
            -- self._mapContent:setPositionX(offsetX)
            -- self._minmap_node:setPositionX(offsetX * self._minScalX + self._centerWidth)
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
                    end), 10)
    end
end


function QUIDialogMazeExploreMap:_checkMapX(x)
    -- if not x or x > (self._mapWidth - self._pageWidth)/2 then
    --     x = (self._mapWidth - self._pageWidth)/2
    -- elseif x < -(self._mapWidth - self._pageWidth)/2 then
    --     x = -(self._mapWidth - self._pageWidth)/2
    -- end
    local offsideX = self._ccbOwner.node_grid_layer:getPositionX()

    local lMax =  - offsideX
    local rMax = - self._mapWidth  - offsideX
    -- print(lMax)
    -- print(rMax)
    x = math.min(lMax ,x)
    x = math.max(rMax ,x)

    return x
end

function QUIDialogMazeExploreMap:_checkMapY(y)
    -- if not y or y > (self._mapHeight - self._pageHeight)/2 then
    --     y = (self._mapHeight - self._pageHeight)/2
    -- elseif y < -(self._mapHeight - self._pageHeight)/2 then
    --     y = -(self._mapHeight - self._pageHeight)/2
    -- end
    local offsideY = self._ccbOwner.node_grid_layer:getPositionY()
    local lMax =   - offsideY
    local rMax = - self._mapHeight   - offsideY
    -- print(lMax)
    -- print(rMax)

    y = math.min(lMax ,y)
    y = math.max(rMax ,y)
    return y
end

function QUIDialogMazeExploreMap:_resetPathList()
    self._rolePaths = {}
    self._rolePathCount = 0
    self._rolePathIndex = 1
end


function QUIDialogMazeExploreMap:_addRoleMovePath(gridTbl)
    -- rolePosition = self._mapContent:convertToNodeSpace(rolePosition)
    table.insert( self._rolePaths, gridTbl )
    self._rolePathCount = self._rolePathCount + 1
end

function QUIDialogMazeExploreMap:_removeRoleMoveTopPath()

    while true do
        if self._rolePaths[self._rolePathIndex] then
            self._rolePathIndex = self._rolePathIndex + 1
            break
        end

        if self._rolePathIndex > self._rolePathCount then
            self:_resetPathList()
            break
        end

        self._rolePathIndex = self._rolePathIndex + 1
    end
end


function QUIDialogMazeExploreMap:_updateRoleMove()
    if self._isAutoMove then return end

    self:_removeAction()
    if not q.isEmpty(self._rolePaths) and self._rolePaths[self._rolePathIndex] then
        local data = self._rolePaths[self._rolePathIndex]
        local movementState = self._mapController:updateRolePositionAndHandleEvent(data)    
        if QUIMazeExploreMapController.MOVEMENT_STATE.MOVEMENT_STATE_CAN_NOT_WALK_NEXT ~= movementState then
            local rolePosition = ccp(- data[1] * QUIMazeExploreMapController.PER_GRID_WIDTH ,- data[2] * QUIMazeExploreMapController.PER_GRID_HEIGHT )
            self:_autoRoleMove(rolePosition , movementState)
            return 
        else
            self:_resetPathList()
            self._isAutoMove = false
        end
    end

    self:_playRoleStopWalk()
  
end

function QUIDialogMazeExploreMap:_playRoleStopWalk()
    self._role:stopActorWalk()
    if self._jumpCoord then
        -- print( "_updateRoleMove6")
        -- QPrintTable(self._jumpCoord )
        -- print( QMazeExplore.GRID_EVENT_USE_PORTAL)
        self:_addRoleMovePath(clone(self._jumpCoord))
        self:_resetMapPosition()
        QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QMazeExplore.GRID_EVENT_USE_PORTAL , config = config })
        self._jumpCoord = nil
    end

end


function QUIDialogMazeExploreMap:_updateRoleEvent()
    self._mapController:handleGridEventAfterMove()    
    self:_resetPathList()
    self._isAutoMove = false
    self:_playRoleStopWalk()
end


function QUIDialogMazeExploreMap:_autoRoleMove(position,movementState)
    self._isAutoMove = true

    -- local isLeft = position.x > self._ccbOwner.node_top_layer:getPositionX()
    local isLeft = position.x > self._ccbOwner.node_grid_layer:getPositionX()
    self._role:setActorWalk(isLeft)

   local callback = CCCallFunc:create(function () 
        self._isAutoMove = false
        self:_removeRoleMoveTopPath()
        if movementState == QUIMazeExploreMapController.MOVEMENT_STATE.MOVEMENT_STATE_DAULT then
            self:_updateRoleMove()
        else
            self:_updateRoleEvent()
        end
    end)
    -- local offsideX = position.x - self._ccbOwner.node_top_layer:getPositionX()
    -- local offsideY = position.y - self._ccbOwner.node_top_layer:getPositionY()

    local offsideX = position.x - self._ccbOwner.node_grid_layer:getPositionX()
    local offsideY = position.y - self._ccbOwner.node_grid_layer:getPositionY()    
    self:_handlePlayBgMoveAction(QUIMazeExploreMapController.MOVE_PACE_DUR,offsideX,offsideY)
    self:_playMoveAction(QUIMazeExploreMapController.MOVE_PACE_DUR , position , self._ccbOwner.node_top_layer ,nil)
    self:_playMoveAction(QUIMazeExploreMapController.MOVE_PACE_DUR , position , self._ccbOwner.node_grid_layer ,callback)
    -- self:_playMoveAction(QUIMazeExploreMapController.MOVE_PACE_DUR , position , self._ccbOwner.node_top_layer ,callback)
    -- self:_playMoveAction(QUIMazeExploreMapController.MOVE_PACE_DUR , position , self._ccbOwner.node_bottom_layer ,nil)
    self:_playMoveAction(QUIMazeExploreMapController.MOVE_PACE_DUR , ccp(position.x * self._minScalX,position.y* self._minScalY) ,self._minmap_gridNode ,nil)

    -- local actionArrayIn = CCArray:create()
    -- local curveMove = CCMoveTo:create(QUIMazeExploreMapController.MOVE_PACE_DUR, position)
    -- -- local speed = CCEaseExponentialOut:create(curveMove)
    -- actionArrayIn:addObject(curveMove)
    -- actionArrayIn:addObject()
    -- local ccsequence = CCSequence:create(actionArrayIn)
    -- self._ccbOwner.node_top_layer:runAction(ccsequence)
    -- self._ccbOwner.node_bottom_layer:runAction(CCMoveTo:create(QUIMazeExploreMapController.MOVE_PACE_DUR, position))

end

function QUIDialogMazeExploreMap:_removeAction()
     self._ccbOwner.node_top_layer:stopAllActions()
     self._ccbOwner.node_mid_layer:stopAllActions()
     self._ccbOwner.node_bottom_layer:stopAllActions()
     self._ccbOwner.node_grid_layer:stopAllActions()
     self._minmap_gridNode:stopAllActions()
end

--镜头移动函数
function QUIDialogMazeExploreMap:_moveCameraToGrid(gridX,gridY ,durGo,durBack ,delay , callback2)
    self._isAutoMove = true
    local curPosition = qccp(self._mapContent:getPositionX(),self._mapContent:getPositionY())
    local gridPosition = qccp(gridX * QUIMazeExploreMapController.PER_GRID_WIDTH , gridY * QUIMazeExploreMapController.PER_GRID_HEIGHT )
    -- local rolePosition = qccp(self._ccbOwner.node_top_layer:getPositionX(),self._ccbOwner.node_top_layer:getPositionY())
    local rolePosition = qccp(self._ccbOwner.node_grid_layer:getPositionX(),self._ccbOwner.node_grid_layer:getPositionY())
    local center = qccp(QUIDialogMazeExploreMap.MAP_CENTER_X,QUIDialogMazeExploreMap.MAP_CENTER_Y) 
    local targetPosition =  ccp(  center.x- rolePosition.x - gridPosition.x ,   center.y -  rolePosition.y - gridPosition.y)
    local dur = q.distOf2Points(curPosition,targetPosition)/ 1000

    if dur <= 0 then
        self._isAutoMove = false
        return
    end
    local callback = CCCallFunc:create(function () 
        self._isAutoMove = false
        self:_playMoveAction(durBack or dur, ccp(curPosition.x ,curPosition.y ) ,self._mapContent ,nil)
    end)

    self:_playMoveAction(durGo or dur,targetPosition ,self._mapContent ,callback , delay , callback2)
end


function QUIDialogMazeExploreMap:_resetMapPosition()

    local dur = q.distOf2Points(qccp(self._mapContent:getPositionX(),self._mapContent:getPositionY())
         , qccp(QUIDialogMazeExploreMap.MAP_CENTER_X,QUIDialogMazeExploreMap.MAP_CENTER_Y) )/ 1000
    if dur <= 0 then
        self:_updateRoleMove()
        return
    end
    dur = 0.5
    local callback = CCCallFunc:create(function () 
        self:_updateRoleMove()
    end)
    self:_playMoveAction(dur , ccp(QUIDialogMazeExploreMap.MAP_CENTER_X,QUIDialogMazeExploreMap.MAP_CENTER_Y) ,self._mapContent ,callback)
    self:_playMoveAction(dur , ccp(QUIDialogMazeExploreMap.MAP_CENTER_X * self._minScalX,QUIDialogMazeExploreMap.MAP_CENTER_Y * self._minScalY) ,self._minmap_node ,nil)
    local offsideX = QUIDialogMazeExploreMap.MAP_CENTER_X - self._mapContent:getPositionX()
    local offsideY = QUIDialogMazeExploreMap.MAP_CENTER_Y - self._mapContent:getPositionY()
    self:_handlePlayBgMoveAction(dur,offsideX,offsideY)
   
end


function QUIDialogMazeExploreMap:_playMoveAction(dur ,ccp1 , actNode ,callback , delay ,callback2 )
    actNode:stopAllActions()
    local curveMove = CCMoveTo:create(dur, ccp1)
    if callback then
        local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(curveMove)
        if callback2 then
        actionArrayIn:addObject(callback2)
        end
        if delay then
        actionArrayIn:addObject(CCDelayTime:create(delay))
        end
        actionArrayIn:addObject(callback)
        local ccsequence = CCSequence:create(actionArrayIn)
        actNode:runAction(ccsequence)
    else
        actNode:runAction(curveMove)
    end
end

function QUIDialogMazeExploreMap:_handlePlayBgMoveAction(dur ,offsideX,offsideY )
    local nodeNameTbl = {"near","mid","far"}
    local dampingXTbl = {0.4,0.24,0.1}
    local dampingYTbl = {0.03,0.1,0.01}
    offsideX = tonumber(offsideX)
    offsideY = tonumber(offsideY)
    -- print("offsideX "..offsideX)
    -- print("offsideY "..offsideY)
    for i,v in ipairs(nodeNameTbl) do
        local node  = self._ccbOwner["node_"..v]
        local posx =  tonumber(offsideX * dampingXTbl[i])
        local posy = tonumber(offsideY * dampingYTbl[i])
    -- print("posx "..posx)
    -- print("posy "..posy)
        posx = posx+ node:getPositionX()
        posy = posy+ node:getPositionY()
    -- print("posx "..posx)
    -- print("posy "..posy)
        node:stopAllActions()
        node:runAction(CCMoveTo:create(dur, ccp(posx,posy)))
    end
end



function QUIDialogMazeExploreMap:_updateMapContentPosition(posX,posY)

    if posX then
        local offside = posX - self._mapContent:getPositionX()
        self:_updateBackgroundPosition(offside,nil)
        self._mapContent:setPositionX(posX)
        self._minmap_node:setPositionX(posX * self._minScalX)
    end
    if posY then
        local offside = posY - self._mapContent:getPositionY()
        self:_updateBackgroundPosition(nil,offside)
        self._mapContent:setPositionY(posY)
        self._minmap_node:setPositionY(posY * self._minScalY)
    end
end

function QUIDialogMazeExploreMap:_updateMapLayerPosition(posX,posY)
    if posX then

        -- self._ccbOwner.node_top_layer:setPositionX(posX)
        -- self._ccbOwner.node_bottom_layer:setPositionX(posX)
        self._ccbOwner.node_grid_layer:setPositionX(posX)
        self._ccbOwner.node_top_layer:setPositionX(posX)
        self._minmap_gridNode:setPositionX(posX * self._minScalX )
    end
    if posY then

        -- self._ccbOwner.node_top_layer:setPositionY(posY)
        -- self._ccbOwner.node_bottom_layer:setPositionY(posY)
        self._ccbOwner.node_grid_layer:setPositionY(posY)
        self._ccbOwner.node_top_layer:setPositionY(posY)
        self._minmap_gridNode:setPositionY(posY * self._minScalY )
    end


end


function QUIDialogMazeExploreMap:_updateBackgroundPosition(offsideX,offsideY)
    local nodeNameTbl = {"near","mid","far"}
    local dampingXTbl = {0.4,0.24,0.1}
    local dampingYTbl = {0.03,0.1,0.01}
    if offsideX then
        for i,v in ipairs(dampingXTbl) do
            local node  = self._ccbOwner["node_"..nodeNameTbl[i]]
            node:setPositionX(node:getPositionX() +  offsideX * v)
        end
    end
    if offsideY then
        for i,v in ipairs(dampingYTbl) do
            local node  = self._ccbOwner["node_"..nodeNameTbl[i]]
            node:setPositionY(node:getPositionY() +  offsideY * v)
        end
    end
end


--判断是否点击地格
function QUIDialogMazeExploreMap:_isOnTriggerGrid(x, y)
    local rolePosition = self._mapContent:convertToNodeSpace(ccp(x, y))

    -- local gridX = math.floor(((rolePosition.x - self._ccbOwner.node_top_layer:getPositionX()) /  QUIMazeExploreMapController.PER_GRID_WIDTH) + 0.5)
    -- local gridY = math.floor(((rolePosition.y - self._ccbOwner.node_top_layer:getPositionY()) /  QUIMazeExploreMapController.PER_GRID_HEIGHT) + 0.5)
    local gridX = math.floor(((rolePosition.x - self._ccbOwner.node_grid_layer:getPositionX()) /  QUIMazeExploreMapController.PER_GRID_WIDTH) + 0.5)
    local gridY = math.floor(((rolePosition.y - self._ccbOwner.node_grid_layer:getPositionY()) /  QUIMazeExploreMapController.PER_GRID_HEIGHT) + 0.5)

    -- print("=====================================")
    -- print("gridX    :   "..gridX)
    -- print("gridY    :   "..gridY)

    local isGrid , pathTbl = self._mapController:checkIsGrid(gridX,gridY)   
    if isGrid then
        -- self:_moveCameraToGrid(gridX,gridY)
        for i,v in ipairs(pathTbl) do
            local paths = string.split(v, "|")
            self:_addRoleMovePath(paths)
        end
        self:_resetMapPosition()
        return true
    end
    return false
end

function QUIDialogMazeExploreMap:onEventPortal(event)
    local config = event.config
    if not config then return end 

    local coord = self._mapController:getPortalEnd(config)   
    if coord then
        self._jumpCoord = coord
        QPrintTable(self._jumpCoord)
    end
end

function QUIDialogMazeExploreMap:_onTriggerRule(e)
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMazeExploreRule"})
end

function QUIDialogMazeExploreMap:_onTriggerExploreRecord(e)
    app.sound:playSound("common_small") 
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMazeExploreRecord"})
end

function QUIDialogMazeExploreMap:_onTriggerMemoryAward(e)
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMazeExploreMemoryAwards"})
end

function QUIDialogMazeExploreMap:_onTriggerAwardPreview(e)
    app.sound:playSound("common_small") 
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMazeExploreAwardPreview",options = {chapterId = self.info.chapterId}})    
end

function QUIDialogMazeExploreMap:_onTriggerMinMap(e)
    print("====================_onTriggerMinMap========================")
    local curMapData = self._mapController:getMapData()   --{id = 1 , gridX = 0 , gridY = 0  , state }
    local curMapLineData = self._mapController:getMapLineData()   --{gridX = 0 , gridY = 0 , ctype = 1 ,lines = {17,18}}

    -- local ccpGrid = qccp(self._ccbOwner.node_top_layer:getPositionX(),self._ccbOwner.node_top_layer:getPositionY())
    local ccpGrid = qccp(self._ccbOwner.node_grid_layer:getPositionX(),self._ccbOwner.node_grid_layer:getPositionY())
    local ccpAll = qccp(self._mapContent:getPositionX(),self._mapContent:getPositionY())
    -- QPrintTable(ccpGrid)
    -- QPrintTable(ccpAll)
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMazeExploreMinMap"
        ,options ={curMapData = curMapData ,curMapLineData = curMapLineData ,ccpGrid = ccpGrid ,ccpAll = ccpAll }})
end


return QUIDialogMazeExploreMap