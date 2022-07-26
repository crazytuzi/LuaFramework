HomePageController={}
--[[解决homePage的点击吞噬问题]]
-- create by xzli
--[[
	使用方法
	local hpc = HomePageController:create( _target )
	hpc:init()
	hpc:setButtonCallBack(_callback)
	hpc:setPageCallBack(_callback)
	hpc:addPage(_page)
	hpc:addButtons(_btns)

	说明
	currentPageIndex 从0开始
]]

--常量
local HomePageContainerZOrder = 0
local HomePagePanelZOrder = 5
local HomePageControllerPageEventType = {
  Turning = 0, --正在转向中状态
}

local HomeButtonZoomScale = 0.1
local HomeButtonActionTimeStep = 0.2
local HomeButtonActionTag = 998

local HomeScrollTimeStep = 0.2
local HomeScrollMinOffSet = 3
local HomeScrollPageThreshold = 0.3


--变量
local target = nil --管理目标
local buttons = {}	--管理的所有按钮
local turningCallback = nil -- 滑动页面callback
local btnsCallback = nil -- 点击按钮callback
local pageContainer = nil -- 页容器
local touchPanel = nil	-- 点击收集器
local touchBeganPos = nil	-- 开始点击position
local touchBeganButton = nil -- 开始点击处的button
local pageSize = nil	--单页size
local currentPageIndex = 0	-- 当前页号
local pageList = {}	-- 页面容器
local primitButtonScaleX = 1 -- 按钮原始X轴缩放比例
local primitButtonScaleY = 1 -- 按钮原始y轴缩放比例
local panel_main = nil	-- 福利按钮相关panel
local imageBox = nil	-- 福利按钮二级页面
local imageBoxButtons = {} -- 福利二级页面按钮集合
local pageButtons = {} -- 页面上的按钮
local liftImage = nil -- 向左滑动提示图片
local rightImage = nil -- 向右滑动提示图片

local isTouchEnabled = true
local scheduleId = 0



--检测touche(（)点）,是否在node内
local function containsTouchLocation(touch,node)
	if not node then
		return false
	end
	if not node:isVisible() then
		return false
	end
	local bb=node:getBoundingBox();
	local rect = cc.rect(0, 0, bb.width, bb.height)
	local glpos = touch:getLocation()
	local nodeTouchPos=node:convertToNodeSpace(glpos)
	local res = (0 < nodeTouchPos.x and rect.width >nodeTouchPos.x and 0 < nodeTouchPos.y and rect.height > nodeTouchPos.y)
	return res
end

local function getOnTouchButton(touch)
    cclog("------------------ getOnTouchButton -------------------------")
    -- 先遍历 不移动的UIbuttons
	for k,v in pairs(buttons) do    
        -- cclog(v:getName())
		if containsTouchLocation(touch,v) then
			return v
		end
	end
	-- 再便利页面上的建筑
	for k,v in pairs(pageButtons) do
		if containsTouchLocation(touch,v) then
			return v
		end
	end
	return nil
end

local function getOnTouchImageBoxButton( touch )
	-- body
	 cclog("------------------ getOnTouchImageBoxButtons -------------------------")
	for k,v in pairs(imageBoxButtons) do    
        -- cclog(v:getName())
		if containsTouchLocation(touch,v) then
			return v
		end
	end
	return nil
end

local function onTurning(index)
	-- body
	if turningCallback then
		turningCallback(index)
	end
end

local function onBtnCallBack(dt)
	-- cclog("onBtnCallBack")
	if btnsCallback then
        -- cclog("callback")
		btnsCallback(touchBeganButton, ccui.TouchEventType.ended)
	end
end

---------------------------------------------  onTouch ---------------------------------------------
local function onTouchBegan( touch ,envent )
	-- body
	if not isTouchEnabled then
		return true
	end
	touchBeganTime = os.time()
	touchBeganPos = touch:getLocation()
	touchBeganButton = nil

	-- 判断当前福利按钮的二级菜单是否展示
	if imageBox:isVisible() then
		touchBeganButton = getOnTouchImageBoxButton(touch)
		if not touchBeganButton then
			panel_main:setVisible(false)
			imageBox:setVisible(false)
		end
	else
		touchBeganButton = getOnTouchButton(touch)
	end

	if touchBeganButton then
        cclog("touchBeganButton name is : " .. touchBeganButton:getName())
       	primitButtonScaleX = touchBeganButton:getScaleX()
       	primitButtonScaleY = touchBeganButton:getScaleY()
		local action = cc.RepeatForever:create( cc.Sequence:create(cc.ScaleTo:create(HomeButtonActionTimeStep,primitButtonScaleX+HomeButtonZoomScale),cc.ScaleTo:create(HomeButtonActionTimeStep,primitButtonScaleX)))
		action:setTag(HomeButtonActionTag)
		touchBeganButton:runAction(action)
	end
	return true
end

local function onTouchMoved( touch ,envent )
	-- body
	if not isTouchEnabled then
		return
	end

	local move_pos = touch:getLocation()
	local offset = touch:getDelta()
	if math.abs(offset.x) > HomeScrollMinOffSet then
		-- 滑动
        cclog("touch move offset x = " .. offset.x)
		local posx,posy = pageContainer:getPosition()
		local movePosX = posx + offset.x
		if movePosX >=0 then 
			movePosX = 0
		end
		if movePosX <= -(pageSize.width-1)*(#pageList -1) then
			movePosX = -(pageSize.width-1)*(#pageList -1)
		end
		pageContainer:setPosition(movePosX , posy)
		if touchBeganButton then
			if imageBox:isVisible() then
				panel_main:setVisible(false)
				imageBox:setVisible(false)
			end
			touchBeganButton:stopActionByTag(HomeButtonActionTag)
			touchBeganButton:setScale(primitButtonScaleX,primitButtonScaleY)
		end
	else
		-- 点击
	end
end

local function onTouchEnded( touch ,envent )
	-- body
	if not isTouchEnabled then
		return
	end
	local endPos = touch:getLocation()
	local finalOffsetX = touchBeganPos.x - endPos.x
	if math.abs(finalOffsetX) > pageSize.width * HomeScrollPageThreshold then
		-- 滑动
		if finalOffsetX > 0 then
			-- 向左
			local pageIndex = currentPageIndex+1
			HomePageController.scrollToPage(self,pageIndex)

		else
			-- 向右
			local pageIndex = currentPageIndex-1
			HomePageController.scrollToPage(self,pageIndex)

		end
		-- 处理福利二级页面
		if imageBox:isVisible() then
				panel_main:setVisible(false)
				imageBox:setVisible(false)
		end
		-- 处理福利按钮
		if touchBeganButton then
			touchBeganButton:stopActionByTag(HomeButtonActionTag)
			touchBeganButton:setScale(primitButtonScaleX,primitButtonScaleY)
			primitButtonScaleX = 1
			primitButtonScaleY = 1
			touchBeganButton = nil
		end
	else
		-- 点击
		if containsTouchLocation(touch,touchBeganButton) then
            cclog("-------------- touch ended ----------------")
			if touchBeganButton then
                -- cclog(touchBeganButton:getName())
				touchBeganButton:stopActionByTag(HomeButtonActionTag)
				touchBeganButton:setScale(primitButtonScaleX,primitButtonScaleY)
				onBtnCallBack()
			end
		else
			if touchBeganButton then
				touchBeganButton:stopActionByTag(HomeButtonActionTag)
				touchBeganButton:setScale(primitButtonScaleX,primitButtonScaleY)
			end
		end
		-- 还原
		touchBeganButton = nil
		primitButtonScaleX = 1
		primitButtonScaleY = 1
		HomePageController.scrollToPageNow(self,currentPageIndex)
	end
	-- 防止连续点击
	isTouchEnabled = false
end

local count = 0

-- target homepage 
-- buttons allbuttons
function HomePageController:create( _target  )
	-- body
	cclog("HomePageController:create count ="..count)
	if count > 0 then
		error("HomePageController:create() once")
	end
	count = count + 1
	target = _target
 	return HomePageController
end

function HomePageController:init()
	-- body
	for k,v in pairs(buttons) do
		v:setTouchEnabled(false)
	end

	touchPanel = ccui.Layout:create()
	touchPanel:setContentSize(target:getContentSize())
	target:addChild(touchPanel,HomePagePanelZOrder)

	pageSize = target:getContentSize()
	pageContainer = ccui.Layout:create()
	pageContainer:setContentSize(target:getContentSize())
	target:addChild(pageContainer,HomePageContainerZOrder)

	-- 处理福利按钮
	panel_main = ccui.Helper:seekNodeByName(UIHomePage.Widget, "panel")
	imageBox = panel_main:getChildByName("image_gift")
end

function HomePageController:addPage( page )
	table.insert(pageList,page)
	page:setPosition((#pageList-1)*(pageSize.width-1),0)
	pageContainer:addChild(page)
end

function HomePageController:addButtons(_buttons)
	if _buttons then
		for k,v in pairs(_buttons) do
			table.insert(buttons,v)
			v:setTouchEnabled(false)
		end
	end
end

function HomePageController:addPageButtons(_pageButtons)
	if _pageButtons then
		for k,v in pairs(_pageButtons) do
			table.insert(pageButtons,v)
			v:setTouchEnabled(false)
		end
	end
end

function HomePageController:addImageBoxButtons( _imBtns )
	-- body
	if _imBtns then
		for k,v in pairs(_imBtns) do
			table.insert(imageBoxButtons,v)
			v:setTouchEnabled(false)
		end
	end
end

function HomePageController:setButtonsCallBack(_btnsCallback)
    cclog("------------------ setButtonsCallBack -----------------------")
	btnsCallback = _btnsCallback
end

function HomePageController:setPageCallBack(_turningCallback)
    cclog("-------------------------HomePageController:setPageCallBack---------------------------------")
	turningCallback = _turningCallback
end

function HomePageController:getCurrentPageIndex()
	-- body
	return currentPageIndex
end

function HomePageController:getPage(index)
	-- body
	return pageList[index+1]
end

function HomePageController:getCurrentPage()
	-- body
	return pageList[currentPageIndex+1]
end

function HomePageController:scrollToPage(index)
	if #pageList == 0 then
		error("pageList count must > 0")
	end
	-- 修正 index 取值范围 无需求不做循环逻辑
	if index > #pageList-1 then
		index = #pageList-1
	end
	if index < 0 then
		index = 0
	end
	currentPageIndex = index
	local posx,posy = pageContainer:getPosition()
	local scrollFinalPosX = -(pageSize.width-1)*index
	local function actionDown( )
		HomePageController:refreshImage()
		onTurning(currentPageIndex)
	end
	local action = cc.Sequence:create( cc.MoveTo:create(HomeScrollTimeStep , cc.p(scrollFinalPosX,posy)) ,cc.CallFunc:create(actionDown))
	pageContainer:runAction(action)
end

function HomePageController:scrollToPageNow(index)
	cclog("------------------------- scrollToPageNow -----------------------")
	cclog("index = " .. index)
	if #pageList == 0 then
		error("pageList count must > 0")
	end
	-- 修正 index 取值范围 无需求不做循环逻辑
	if index > #pageList-1 then
		index = #pageList-1
	end
	if index < 0 then
		index = 0
	end
	local posx,posy = pageContainer:getPosition()
	local scrollFinalPosX = -(pageSize.width-1)*index
	pageContainer:setPosition(scrollFinalPosX,posy)
	currentPageIndex = index
	HomePageController:refreshImage()
	return currentPageIndex
end

function HomePageController:getAllButtons()
	local res = {}
	for k,v in pairs(buttons) do
		table.insert(res,v)
	end
	for k,v in pairs(pageButtons) do
		table.insert(res,v)
	end
	for k,v in pairs(imageBoxButtons) do
		table.insert(res,v)
	end
	return res
end

function HomePageController:refreshImage()
	if liftImage then
		liftImage:setVisible(currentPageIndex ~= 0)
	end
	if rightImage then
		rightImage:setVisible(currentPageIndex ~= #pageList-1)
	end
end

function HomePageController:setLiftOrRightImage(image,isLift)
	if isLift then 
		liftImage = image
	else
		rightImage = image
	end
	local t = 1
	local sa = cc.ScaleTo:create(t,0.8)
	local sa2 = cc.ScaleTo:create(t,1)
	local fa = cc.FadeOut:create(t)
	local fa2 = cc.FadeIn:create(t)
	local spawn = cc.Spawn:create(sa,fa)
	local spawn2 = cc.Spawn:create(sa2,fa2)
	local seq= cc.Sequence:create(spawn,spawn2)
	local action = cc.RepeatForever:create(seq)
	image:runAction(action)
	HomePageController:refreshImage()
end

function HomePageController:setup()
	-- 注册侦听事件
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = touchPanel:getEventDispatcher()
	eventDispatcher:removeEventListenersForTarget(touchPanel)
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, touchPanel)
	
	isTouchEnabled = true
	-- 防止同一帧内连续点击
	local function update( dt )
		-- cclog("HomePageController isTouchEnabled = ".. tostring(isTouchEnabled))
		isTouchEnabled = true
	end
	scheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0, false)
	-- 恢复页面位置
	HomePageController:scrollToPageNow(currentPageIndex)
end

function HomePageController:free()
	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleId)
	local eventDispatcher = touchPanel:getEventDispatcher()
	eventDispatcher:removeEventListenersForTarget(touchPanel)
	isTouchEnabled = false
	scheduleId = 0
end

-- 這方法就沒用過
function HomePageController:distory()
	-- 移除
	error("HomePageController:distory never use")
	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleId)
	local eventDispatcher = touchPanel:getEventDispatcher()
	eventDispatcher:removeEventListenersForTarget(touchPanel)
	pageContainer:removeFromParent(true)
	touchPanel:removeFromParent(true)
	-- 移除
	target = nil --管理目标
	buttons = {}	--管理的所有按钮
	turningCallback = nil -- 滑动页面callback
	btnsCallback = nil -- 点击按钮callback
	pageContainer = nil -- 页容器
	touchPanel = nil	-- 点击收集器
	touchBeganPos = nil	-- 开始点击position
	touchBeganButton = nil -- 开始点击处的button
	pageSize = nil	--单页size
	currentPageIndex = 0	-- 当前页号
	pageList = {}	-- 页面容器
	primitButtonScaleX = 1 -- 按钮原始X轴缩放比例
	primitButtonScaleY = 1 -- 按钮原始y轴缩放比例
	panel_main = nil	-- 福利按钮相关panel
	imageBox = nil	-- 福利按钮二级页面
	imageBoxButtons = {} -- 福利二级页面按钮集合
	pageButtons = {} -- 页面上的按钮
	isTouchEnabled = true
	scheduleId = 0
	liftImage = nil
	rightImage = nil
end
