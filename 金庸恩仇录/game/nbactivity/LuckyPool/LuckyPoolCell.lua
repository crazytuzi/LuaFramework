local LuckyPoolCell = class("LuckyPoolCell", function()
  return CCTableViewCell:new()
end)
function LuckyPoolCell:getContentSize()
  local proxy = CCBProxy:create()
  local rootNode = {}
  local node = CCBuilderReaderLoad("nbhuodong/lucky_pool_rank_item.ccbi", proxy, rootNode)
  local size = rootNode.itemBg:getContentSize()
  self:addChild(node)
  node:removeSelf()
  return size
end
function LuckyPoolCell:refreshItem(param)
  if self.ListTable ~= nil then
    self.ListTable:removeFromParentAndCleanup(true)
  end
  local index = param.id + 1
  local name = param.cellData.name
  local point = param.cellData.point
  self.cellData = param.cellData.itemData
  dump(self.cellData)
  self._rootnode.label_title_2:setString(tostring(index))
  self._rootnode.label_title_4:setString(tostring(name))
  self._rootnode.label_title_6:setString(tostring(point))
  local nodeTable = {
    self._rootnode.label_title_1,
    self._rootnode.label_title_2,
    self._rootnode.label_title_3,
    self._rootnode.label_title_4
  }
  alignNodesOneByAll(nodeTable, 5)
  local nodeTable = {
    self._rootnode.label_title_5,
    self._rootnode.label_title_6
  }
  alignNodesOneByAll(nodeTable)
  local listView = self._rootnode.reward_list
  local listViewSize = listView:getContentSize()
  local boardWidth = listViewSize.width
  local boardHeight = listViewSize.height
  local function createFunc(index)
    local itemCell = require("game.shop.Chongzhi.ChongzhiRewardItem").new()
    return itemCell:create({
      id = index,
      itemData = self.cellData[index + 1]
    })
  end
  local function refreshFunc(cell, index)
    cell:refresh({
      itemData = self.cellData[index + 1]
    })
  end
  local cellContentSize = require("game.shop.Chongzhi.ChongzhiRewardItem").new():getContentSize()
  self.ListTable = require("utility.TableViewExt").new({
    size = CCSizeMake(boardWidth, boardHeight),
    direction = kCCScrollViewDirectionHorizontal,
    createFunc = createFunc,
    refreshFunc = refreshFunc,
    cellNum = #self.cellData,
    cellSize = cellContentSize,
    touchFunc = function(cell)
      if self._curInfoIndex ~= -1 then
        return
      end
      local idx = cell:getIdx() + 1
      self._curInfoIndex = idx
      local itemData = self.cellData[idx]
      local itemInfo = require("game.Huodong.ItemInformation").new({
        id = itemData.id,
        type = itemData.type,
        name = itemData.name,
        describe = itemData.describe,
        endFunc = function()
          self._curInfoIndex = -1
        end
      })
      CCDirector:sharedDirector():getRunningScene():addChild(itemInfo, 100000)
    end
  })
  self.ListTable:setPosition(0, 0)
  listView:addChild(self.ListTable)
end
function LuckyPoolCell:create(param)
  self._curInfoIndex = -1
  self.viewSize = param.viewSize
  local rewardListener = param.rewardListener
  local proxy = CCBProxy:create()
  self._rootnode = {}
  local node = CCBuilderReaderLoad("nbhuodong/lucky_pool_rank_item.ccbi", proxy, self._rootnode)
  self:addChild(node)
  self:refreshItem(param)
  return self
end
function LuckyPoolCell:refresh(param)
  self:refreshItem(param)
end
return LuckyPoolCell
