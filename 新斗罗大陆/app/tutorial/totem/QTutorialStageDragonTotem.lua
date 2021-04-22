--
-- Author: Your Name
-- Date: 2016-08-03 19:04:03
--
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageDragonTotem = class("QTutorialStageDragonTotem", QTutorialStage)
local QTutorialPhase01DragonTotem = import(".QTutorialPhase01DragonTotem")

function QTutorialStageDragonTotem:ctor(options)
	QTutorialStageDragonTotem.super.ctor(self)
	self._enableTouch = false
end

function QTutorialStageDragonTotem:_createTouchNode()
  	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageDragonTotem:_createPhases()
  table.insert(self._phases, QTutorialPhase01DragonTotem.new(self))

  self._phaseCount = table.nums(self._phases)
end

function QTutorialStageDragonTotem:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStageDragonTotem:disableTouch()
  self._enableTouch = false
  self._touchCallBack = nil
end

function QTutorialStageDragonTotem:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageDragonTotem._onTouch))
  QTutorialStageDragonTotem.super.start(self)
end

function QTutorialStageDragonTotem:ended() 
  if self._forceStop ~= true then
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:buildLayer()
    scheduler.performWithDelayGlobal(function()
      page:checkGuiad()
    end,0)
  end
	if self._touchNode ~= nil then
		self._touchNode:setTouchEnabled( false )
		self._touchNode:removeFromParent()
		self._touchNode = nil
	end
end

function QTutorialStageDragonTotem:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageDragonTotem

