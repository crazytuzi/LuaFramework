


local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMagicHerbQuickRefine = class("QUIWidgetMagicHerbQuickRefine", QUIWidget)
local QRichText = import("...utils.QRichText")
local QActorProp = import("...models.QActorProp")

 QUIWidgetMagicHerbQuickRefine.EVENT_CLICK_ATTR_SELECT = "EVENT_CLICK_ATTR_SELECT"

 local SMALL_OFFSIDE = 240


function QUIWidgetMagicHerbQuickRefine:ctor(options)
  local ccbFile = "ccb/Widget_MagicHerb_Quick_Refine.ccbi"
  local callBacks = {
      {ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
    }
  QUIWidgetMagicHerbQuickRefine.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetMagicHerbQuickRefine:onEnter()
end

function QUIWidgetMagicHerbQuickRefine:onExit()
end

function QUIWidgetMagicHerbQuickRefine:setInfo(info , chooseIndex , posIdx , small)
	self._info = info 
	self._chooseIndex = chooseIndex 

  self._posIdx = posIdx 
  self._propOffside = 200
  self._ccbOwner.sp_bg:setVisible(true)
  self._ccbOwner.sp_bg_small:setVisible(false)
  self._ccbOwner.node_select_spar:setPositionX(424)
  self._width = self._ccbOwner.cellSize:getContentSize().width

  if small then
    self._ccbOwner.sp_bg:setVisible(false)
    self._ccbOwner.sp_bg_small:setVisible(true)
    self._ccbOwner.node_select_spar:setPositionX(664)
    self._propOffside = 210
    self._width = self._width + SMALL_OFFSIDE
  end

	for i,v in ipairs(info) do
        local nowPropTf = QRichText.new(nil, nil, {lineSpacing = 10})
        nowPropTf:setAnchorPoint(ccp(0, 0.5))
        nowPropTf:setPositionX( (i - 1) * self._propOffside)
        self._ccbOwner.node_attr:addChild(nowPropTf)
        nowPropTf:setString({v})
	end

	self._ccbOwner.sp_select:setVisible(false)
end

function QUIWidgetMagicHerbQuickRefine:setSelectState(selectIndex)
	self._ccbOwner.sp_select:setVisible(self._chooseIndex == selectIndex)
end


function QUIWidgetMagicHerbQuickRefine:playAction()
  	local dur = 0.15
   	makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_main ,0,0)
   local num1,num2=math.modf((self._posIdx - 1)/2)
   	num1 = num1 + 1
    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(num1 * dur))
    arr:addObject(CCCallFunc:create(function()
   		makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_main ,dur,255)
    end))
	self._ccbOwner.node_main:runAction(CCSequence:create(arr))
end

function QUIWidgetMagicHerbQuickRefine:getContentSize()
	return CCSize(self._width, 62)
end

function QUIWidgetMagicHerbQuickRefine:_onTriggerSelect()
		self:dispatchEvent({name = QUIWidgetMagicHerbQuickRefine.EVENT_CLICK_ATTR_SELECT, chooseIndex = self._chooseIndex})
end

return QUIWidgetMagicHerbQuickRefine