local QEReplayViewer = class("QEReplayViewer", function()
    return display.newScene("QEReplayViewer")
end)

local QESkeletonViewer = import(".QESkeletonViewer")
local QBattleScene = import("...scenes.QBattleScene")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("...ui.QUIViewController")
local QSkeletonViewController = import("...controllers.QSkeletonViewController")
local QFileCache = import("...utils.QFileCache")
local QBattleDialogAgainstRecord = import("...ui.battle.QBattleDialogAgainstRecord")

function QEReplayViewer:ctor(options)
	-- background
	self:addChild(CCLayerColor:create(ccc4(128, 128, 128, 255), display.width, display.height))

	-- coordinate axis
	-- self._axisNode = CCNode:create()
	-- self:addChild(self._axisNode)
	-- local horizontalLine = CCDrawNode:create()
	-- horizontalLine:drawLine({-display.cx, 0}, {display.cx, 0})
	-- self._axisNode:addChild(horizontalLine)
	-- local verticalLine = CCDrawNode:create()
	-- verticalLine:drawLine({0, -display.cy}, {0, display.height})
	-- self._axisNode:addChild(verticalLine)

	-- self._skeletonRoot = CCNode:create()
	-- self:addChild(self._skeletonRoot)
	-- self._skeletonRoot:setScale(UI_DESIGN_WIDTH / BATTLE_SCREEN_WIDTH)

	-- self._infomationNode = CCNode:create()
	-- self:addChild(self._infomationNode)
	-- self._infomationNode:setPosition(0, display.height)

	-- self._menu = CCMenu:create()
	-- self:addChild(self._menu)
	-- self._menu:setPosition(0, display.height)

	app.tutorial._runingStage = nil

    local menu = CCMenu:create()
    self:addChild(menu, 1)
    local button = CCMenuItemFont:create("暂停")
    button:setPosition(0 - 500, 300)
    button:setEnabled(true)
    button:registerScriptTapHandler(function()
    	self:disableSlowMotion()
    	app.battle:pause()

    	local curModalDialog = nil
        curModalDialog = QBattleDialogAgainstRecord.new({},{}) 
    end)
    menu:addChild(button)
    local button = CCMenuItemFont:create("步进")
    button:setPosition(0 - 425, 300)
    button:setEnabled(true)
    button:registerScriptTapHandler(function()
    	self:disableSlowMotion()
		app.battle:resume()
		scheduler.performWithDelayGlobal(function()
			app.battle:pause()
		end, 0)
    end)
    menu:addChild(button)
    local button = CCMenuItemFont:create("继续")
    button:setPosition(0 - 350, 300)
    button:setEnabled(true)
    button:registerScriptTapHandler(function()
    	self:disableSlowMotion()
    	app.battle:resume()
    end)
    menu:addChild(button)
    local button = CCMenuItemFont:create("慢速")
    button:setPosition(0 - 275, 300)
    button:setEnabled(true)
    button:registerScriptTapHandler(function()
    	self:toggleSlowMotion()
    end)
    menu:addChild(button)
end

function QEReplayViewer:disableSlowMotion()
	if self._slowIndex ~= nil and self._slowIndex > 0 and self._slowHandler then
		self._slowIndex = 0
		self._slowHandler.destroy()
		self._slowHandler = nil
	end
end

function QEReplayViewer:toggleSlowMotion()
	if self._slowMax == nil then
		self._slowMax = 2
	end
	if self._slowIndex == nil then
		self._slowIndex = 0
	end

	self._slowIndex = (self._slowIndex + 1) % self._slowMax
	if self._slowIndex > 0 and self._slowHandler == nil then
	    local obj = {}
    	local function pause()	
			if obj._ended then
				return
			end	

    		scheduler.performWithDelayGlobal(function()
    			if obj._ended then
    				return
    			end
    			app.battle:pause()
    			obj.resume()
    		end, 0)
    	end
    	local function resume()		
			if obj._ended then
				return
			end
			
			local sharedScheduler = CCDirector:sharedDirector():getScheduler()
			local count = math.pow(2, self._slowIndex - 1)
		    local handle 
		    handle = sharedScheduler:scheduleScriptFunc(function()
		    	count = count - 1
		    	if count == 0 then
		        	sharedScheduler:unscheduleScriptEntry(handle)
	    			if obj._ended then
	    				return
	    			end
	    			app.battle:resume()
	    			obj.pause()
		    	end
		    end, 0, false)
    	end
    	obj = {pause = pause, resume = resume}
    	obj.pause()
	    obj.destroy = function()
	    	obj._ended = true
	    	app.battle:resume()
	   	end
	    self._slowHandler = obj
	elseif self._slowIndex == 0 and self._slowHandler ~= nil then
		self._slowHandler.destroy()
		self._slowHandler = nil
	end
end

function QEReplayViewer:cleanup()
	self:endBattle()
end

function QEReplayViewer:onReceiveData(message)
	if message == nil then
		return
	end

	self._message = message
	self:replayBattle()
end

function QEReplayViewer:endBattle()
	if app.grid then
    	app.grid:pauseMoving()
    end
    if app.scene then
    	app.scene:setBattleEnded(true)
	    app.scene:removeFromParentAndCleanup(true)
	    app.scene = nil
    end
end

function QEReplayViewer:replayBattle()
	local record = app:getBattleRecord()
	if not record then
		return
	end

	local config = record.dungeonConfig
	config.isEditor = true
	config.isReplay = true
	config.replayTimeSlices = record.recordTimeSlices
	config.replayRandomSeed = record.recordRandomSeed

    local scene = QBattleScene.new(config)
    self:addChild(scene)
end

return QEReplayViewer