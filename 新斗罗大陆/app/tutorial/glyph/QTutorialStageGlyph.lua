-- @Author: xurui
-- @Date:   2016-09-06 18:42:34
-- @Last Modified by:   xurui
-- @Last Modified time: 2016-09-06 18:44:38
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageGlyph = class("QTutorialStageGlyph", QTutorialStage)
local QTutorialPhase01Glyph = import(".QTutorialPhase01Glyph")

function QTutorialStageGlyph:ctor(options)
	QTutorialStageGlyph.super.ctor(self)
	self._enableTouch = false
end

function QTutorialStageGlyph:_createTouchNode()
  	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.tutorialNode:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageGlyph:_createPhases()
  table.insert(self._phases, QTutorialPhase01Glyph.new(self))

  self._phaseCount = table.nums(self._phases)
end

function QTutorialStageGlyph:enableTouch(func)
  self._enableTouch = true
  self._touchCallBack = func
end

function QTutorialStageGlyph:disableTouch()
  self._enableTouch = false
  self._touchCallBack = nil
end

function QTutorialStageGlyph:start()
  self:_createTouchNode()
  self._touchNode:setTouchEnabled(true)
  self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageGlyph._onTouch))
  QTutorialStageGlyph.super.start(self)
end

function QTutorialStageGlyph:ended() 
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

function QTutorialStageGlyph:_onTouch(event)
  if self._enableTouch == true and self._touchCallBack ~= nil then
    return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

return QTutorialStageGlyph

