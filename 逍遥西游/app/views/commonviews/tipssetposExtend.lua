tipssetposExtend = {}
function tipssetposExtend.extend(object, posPara)
  local x = posPara.x or 0
  local y = posPara.y or 0
  local w = posPara.w or 0
  local h = posPara.h or 0
  local off = 5
  x = x - off
  y = y - off
  w = w + off * 2
  h = h + off * 2
  local dirList = posPara.dirList or {}
  for i = 1, 8 do
    dirList[#dirList + 1] = i - 1
  end
  local zOrder = posPara.zOrder or MainUISceneZOrder.popDetailView
  local viewSize = object:getViewSize()
  local viewWorldPos = ccp(x - viewSize.width, y - viewSize.height / 2)
  for _, dir in ipairs(dirList) do
    if dir == TipsShow_Left_Dir then
      if 0 <= x - viewSize.width then
        viewWorldPos = ccp(x - viewSize.width, y + h / 2 - viewSize.height / 2)
        if 0 > viewWorldPos.y then
          viewWorldPos.y = 0
        end
        if viewWorldPos.y + viewSize.height > display.height then
          viewWorldPos.y = display.height - viewSize.height
        end
        break
      end
    elseif dir == TipsShow_Right_Dir then
      if x + w + viewSize.width <= display.width then
        viewWorldPos = ccp(x + w, y + h / 2 - viewSize.height / 2)
        if 0 > viewWorldPos.y then
          viewWorldPos.y = 0
        end
        if viewWorldPos.y + viewSize.height > display.height then
          viewWorldPos.y = display.height - viewSize.height
        end
        break
      end
    elseif dir == TipsShow_Up_Dir then
      if y + h + viewSize.height <= display.height then
        viewWorldPos = ccp(x + w / 2 - viewSize.width / 2, y + h)
        if viewWorldPos.x < 0 then
          viewWorldPos.x = 0
        end
        if viewWorldPos.x + viewSize.width > display.width then
          viewWorldPos.x = display.width - viewSize.width
        end
        break
      end
    elseif dir == TipsShow_Down_Dir then
      if 0 <= y - viewSize.height then
        viewWorldPos = ccp(x + w / 2 - viewSize.width / 2, y - viewSize.height)
        if viewWorldPos.x < 0 then
          viewWorldPos.x = 0
        end
        if viewWorldPos.x + viewSize.width > display.width then
          viewWorldPos.x = display.width - viewSize.width
        end
        break
      end
    elseif dir == TipsShow_LeftTop_Dir then
      if 0 <= x - viewSize.width and y + h + viewSize.height <= display.height then
        viewWorldPos = ccp(x - viewSize.width, y + h)
        break
      end
    elseif dir == TipsShow_RightTop_Dir then
      if x + w + viewSize.width <= display.width and y + h + viewSize.height <= display.height then
        viewWorldPos = ccp(x + w, y + h)
        break
      end
    elseif dir == TipsShow_LeftDown_Dir then
      if 0 <= x - viewSize.width and 0 <= y - viewSize.height then
        viewWorldPos = ccp(x - viewSize.width, y - viewSize.height)
        break
      end
    elseif dir == TipsShow_RightDown_Dir and x + w + viewSize.width <= display.width and 0 <= y - viewSize.height then
      viewWorldPos = ccp(x + w, y - viewSize.height)
      break
    end
  end
  local viewPos = getCurSceneView():convertToNodeSpace(viewWorldPos)
  object:setPosition(viewPos)
  getCurSceneView():addSubView({subView = object, zOrder = zOrder})
end
