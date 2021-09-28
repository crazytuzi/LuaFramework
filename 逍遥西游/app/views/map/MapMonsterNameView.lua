CMapMonsterNameView = class("CMapMonsterNameView", CcsSubView)
function CMapMonsterNameView:ctor(param)
  CMapMonsterNameView.super.ctor(self, "views/monstername_view.json", {opacityBg = 0, clickOutSideToClose = true})
  local touchX = param.x
  local touchY = param.y
  self.m_MonsterList = param.monsterList or {}
  self.m_callBack = param.callback
  self:initMosterNameitem()
  self:setViewPosition(touchX, touchY, monsterSize)
end
function CMapMonsterNameView:ListEventListener(item, index, listObj, status)
  if status == LISTVIEW_ONSELECTEDITEM_START then
  elseif status == LISTVIEW_ONSELECTEDITEM_END then
  end
end
function CMapMonsterNameView:initMosterNameitem()
  self.m_MosterNameList = self:getNode("monster_nameList")
  self.m_MosterNameList:addTouchItemListenerListView(handler(self, self.ListSelector), handler(self, self.ListEventListener))
  self.m_itmeObjList = {}
  if #self.m_MonsterList > 0 then
    for index, MosterObj in pairs(self.m_MonsterList) do
      local typeId = MosterObj:getMonsterTypeId()
      local shapeId, name = data_getRoleShapeAndName(typeId)
      local item = CMapMonsterNameItem.new({index = index, name_txt = name})
      item.MosterObj = MosterObj
      self.m_itmeObjList[#self.m_itmeObjList + 1] = item
      self.m_MosterNameList:pushBackCustomItem(item)
    end
  end
end
function CMapMonsterNameView:ListSelector(item, index, listObj)
  if self.m_callBack ~= nil and item.MosterObj ~= nil then
    self.m_callBack(item.MosterObj)
    scheduler.performWithDelayGlobal(handler(self, self.CloseSelf), 0.05)
  end
end
function CMapMonsterNameView:setViewPosition(x, y)
  local size = self:getContentSize()
  if x <= display.width / 2 and y <= display.height / 2 then
    self:setPosition(ccp(x + 30, y - 10))
  elseif x <= display.width / 2 and y >= display.height / 2 then
    self:setPosition(ccp(x + 30, y - 2 * size.height / 3))
  elseif x >= display.width / 2 and y >= display.height / 2 then
    self:setPosition(ccp(x - size.width - 30, y - 2 * size.height / 3))
  elseif x >= display.width / 2 and y <= display.height / 2 then
    self:setPosition(ccp(x - size.width - 40, y))
  end
end
function CMapMonsterNameView:Clear()
  self.m_itmeObjList = nil
  self.m_MonsterList = nil
  self:removeFromParent()
end
CMapMonsterNameItem = class("CMapMonsterNameItem", function()
  local widget = Widget:create()
  widget:setAnchorPoint(ccp(0, 0))
  widget:ignoreContentAdaptWithSize(false)
  return widget
end)
function CMapMonsterNameItem:ctor(param)
  local index = param.index
  local name_txt = param.name_txt
  local btnCallback = param.btnlCallback
  local btn = BDsubButton.new("views/common/bg/bg1073.png", btnCallback, name_txt)
  local btnsize = btn:getContentSize()
  self:setSize(CCSizeMake(btnsize.width, btnsize.height))
  self:addChild(btn)
end
function CMapMonsterNameItem:Clear()
end
