local MapTelepotorItem = class("MapTelepotorItem", function()
  local widget = Widget:create()
  widget:setAnchorPoint(ccp(0, 0))
  widget:ignoreContentAdaptWithSize(false)
  return widget
end)
function MapTelepotorItem:ctor(itemTxt, size, itemMapInfo)
  self:setTouchEnabled(true)
  self:setNodeEventEnabled(true)
  local s = CCSize(size.width, 40)
  self:setSize(s)
  self.m_MapInfo = itemMapInfo
  local txt = CRichText.new({
    width = s.width,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = 30,
    color = ccc3(58, 34, 5),
    align = CRichText_AlignType_Center
  })
  self:addChild(txt)
  txt:addRichText(itemTxt)
  local txtSize = txt:getRichTextSize()
  txt:setPosition(ccp(0, (s.height - txtSize.height) / 2))
end
function MapTelepotorItem:getMapInfo()
  return self.m_MapInfo
end
CTestWorldMap = class("TestWorldMap", CcsSubView)
function CTestWorldMap:ctor()
  CTestWorldMap.super.ctor(self, "views/test_world_map.json")
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.list_map = self:getNode("list_map")
  self.list_map:addTouchItemListenerListView(function(item, index, listObj)
    self:ChooseItem(item, index, listObj)
  end)
  self.m_MapInfo = {}
  local lSize = self.list_map:getContentSize()
  for mapId, mapInfo in pairs(data_MapInfo) do
    local name = mapInfo.name
    for tId, tInfo in pairs(data_MapTeleporter) do
      local itemMapInfo
      if tInfo.tomap == mapId then
        local pos = tInfo.toPos[1]
        local itemMapInfo = {
          mapId,
          pos[1],
          pos[2]
        }
        local item = MapTelepotorItem.new(string.format("%s[%d,%d]", name, pos[1], pos[2]), lSize, itemMapInfo)
        self.list_map:pushBackCustomItem(item)
      end
    end
  end
end
function CTestWorldMap:ChooseItem(item, index, listObj)
  local mapInfo = item:getMapInfo()
  g_MapMgr:AutoRoute(mapInfo[1], {
    mapInfo[2],
    mapInfo[3]
  })
  scheduler.performWithDelayGlobal(function()
    self:CloseSelf()
  end, 0.1)
end
function CTestWorldMap:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
