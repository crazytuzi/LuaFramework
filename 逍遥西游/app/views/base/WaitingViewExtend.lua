WaitingViewExtend = {}
function WaitingViewExtend.extend(object)
  function object:ShowWaitingView(isSwallowsTouchs, delayShow)
    if object.TopView_ ~= nil then
      return
    end
    if isSwallowsTouchs == nil then
      isSwallowsTouchs = true
    end
    local director = CCDirector:sharedDirector()
    local winSize = director:getWinSize()
    local layerC = CCLayerColor:create(ccc4(0, 0, 0, 0))
    object:addNode(layerC, MainUISceneZOrder.swallowMessage)
    local screenCenterPos = object:convertToNodeSpaceAR(CCPoint(0, 0))
    layerC:setPosition(screenCenterPos.x, screenCenterPos.y)
    local loadingSprite = CreateALoadingSprite()
    layerC:addChild(loadingSprite)
    local size = layerC:getContentSize()
    loadingSprite:setPosition(size.width / 2, size.height / 2)
    if delayShow ~= nil and delayShow > 0 then
      loadingSprite:setVisible(false)
      loadingSprite:runAction(transition.sequence({
        CCDelayTime:create(delayShow),
        CCShow:create()
      }))
    end
    if isSwallowsTouchs then
      local touch = function(event, x, y)
        return true
      end
      layerC:addNodeEventListener(cc.NODE_TOUCH_EVENT, touch)
      layerC:setTouchEnabled(true)
      layerC:setTouchSwallowEnabled(true)
    end
    object.TopView_ = layerC
  end
  function object.HideWaitingView()
    if object.TopView_ then
      object.TopView_:removeFromParent()
    end
    object.TopView_ = nil
  end
  function object.ShowFullWaitingView(txt, isSwallowsTouchs)
    isSwallowsTouchs = isSwallowsTouchs or true
    local director = CCDirector:sharedDirector()
    local layerC = CCLayerColor:create(ccc4(0, 0, 0, 180))
    local screenCenterPos = object:convertToNodeSpaceAR(CCPoint(0, 0))
    layerC:setPosition(screenCenterPos.x, screenCenterPos.y)
    object:addChild(layerC, getMaxZ(object) + 1)
    object.TopFullView_ = layerC
    if isSwallowsTouchs then
      local touch = function(event, x, y)
        return true
      end
      layerC:addNodeEventListener(cc.NODE_TOUCH_EVENT, touch)
      layerC:setTouchEnabled(true)
      layerTouch:setTouchSwallowEnabled(true)
    end
    local size = layerC:getContentSize()
    local loadingSprite = CreateALoadingSprite()
    layerC:addChild(loadingSprite)
    loadingSprite:setPosition(size.width / 2, size.height / 2)
    object:setFullWaitingViewLabel(txt)
    return object.TopFullView_
  end
  function object.setFullWaitingViewLabel(txt)
    if txt then
      if object.FullWaitingViewLabel_ == nil then
        local size = object.TopFullView_:getContentSize()
        local FullWaitingViewLabel_ = ui.newTTFFullWaitingViewLabel_({
          text = txt,
          size = 35,
          font = ITEM_NUM_FONT,
          color = ccc3(255, 255, 255),
          dimensions = CCSize(size.width * 3 / 4, 0),
          align = ui.TEXT_ALIGN_CENTER
        })
        object.TopFullView_:addChild(FullWaitingViewLabel_)
        FullWaitingViewLabel_:setPosition(size.width / 2, size.height / 2 - FullWaitingViewLabel_:getContentSize().height / 2 - 70)
        object.FullWaitingViewLabel_ = FullWaitingViewLabel_
      else
        object.FullWaitingViewLabel_:setString(txt)
      end
    end
  end
  function object.HideFullView()
    if object.TopFullView_ then
      object.TopFullView_:removeSelf()
      object.TopFullView_ = nil
      object.FullWaitingViewLabel_ = nil
    end
  end
end
