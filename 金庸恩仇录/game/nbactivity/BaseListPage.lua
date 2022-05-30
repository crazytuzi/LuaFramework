local BaseListPage = class("BaseListPage", function(param)
  local node = display.newNode()
  node._listTable = nil
  node._listViewNode = param.listViewNode
  node._cellData = nil
  node.cellContentSize = nil
  return node
end)
function BaseListPage:createCell(index)
end
function BaseListPage:refreshCell(cell, index)
end
function BaseListPage:initList()
  if self._listTable ~= nil then
    self._listTable:removeFromParentAndCleanup(true)
  end
  local function createFunc(index)
    return self:createCell(index)
  end
  local function refreshFunc(cell, index)
    self:refreshCell(cell, index)
  end
  self._listTable = require("utility.TableViewExt").new({
    size = self._listViewSize,
    direction = kCCScrollViewDirectionVertical,
    createFunc = createFunc,
    refreshFunc = refreshFunc,
    cellNum = #self._cellData,
    cellSize = self.cellContentSize
  })
  self._listTable:setPosition(0, 0)
  self._listViewNode:addChild(self._listTable)
end
return BaseListPage
