function testKeyBoard()
  local parentNode = CCScene:create()
  display.replaceScene(parentNode)
  local bg = display.newColorLayer(ccc4(180, 180, 180, 255))
  parentNode:addChild(bg, -1)
  local param = {
    size = CCSize(250, 40)
  }
  local editBox = CEditBoxEx.new(param)
  bg:addChild(editBox, 1)
  editBox:setPosition(ccp(300, 300))
  local btn = display.newSprite("views/common/btn/btn_add.png")
  bg:addChild(btn, 1)
  btn:setPosition(ccp(600, 320))
  bg:setTouchEnabled(true)
  bg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
    local name = event.name
    if name == "began" then
      btn:setScale(1.1)
      local x, y = event.x, event.y
      local bx, by = btn:getPosition()
      local size = btn:getContentSize()
      if x >= bx - size.width / 2 and x <= bx + size.width / 2 and y >= by - size.height / 2 and y <= by + size.height / 2 then
        clickListener(editBox)
      end
      return true
    elseif name == "ended" then
      btn:setScale(1)
    end
  end)
end
function clickListener(editBox)
  print("--->>clickListener")
end
