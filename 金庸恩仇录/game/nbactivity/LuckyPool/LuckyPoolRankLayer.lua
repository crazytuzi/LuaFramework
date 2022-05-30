local LuckyPoolRankLayer = class("LuckyPoolRankLayer", function()
  return require("utility.ShadeLayer").new()
end)
local listViewDisH = 95
local data_lucky_jiangli_lucky_jiangli = require("data.data_lucky_jiangli_lucky_jiangli")
function LuckyPoolRankLayer:ctor(param)
  local proxy = CCBProxy:create()
  self._rootnode = {}
  local node = CCBuilderReaderLoad("nbhuodong/lucky_pool_rank_layer.ccbi", proxy, self._rootnode)
  self:addChild(node)
  node:setPosition(display.cx, display.cy)
  self._rootnode.tag_close:addHandleOfControlEvent(function()
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
    self:removeSelf()
  end, CCControlEventTouchDown)
  self._rootnode.titleLabel:setString(common:getLanguageString("@LuckyList"))
  local function func()
    self:initView()
  end
  self:getBaseData(func)
end
function LuckyPoolRankLayer:initView()
  local data_item_item = require("data.data_item_item")
  self.rankList = self._data.ranks
  self.rank = self._data.rank
  self.point = self._data.point
  self._rootnode.label_lucky_num:setString(tostring(self.point))
  self._rootnode.label_rank_num:setString(tostring(self.rank))
  self._rootnode.label_rank_num:setColor(ccc3(0, 220, 27))
  local nodeTable = {
    self._rootnode.MyPlace,
    self._rootnode.label_rank_num
  }
  alignNodesOneByAll(nodeTable)
  local nodeTable = {
    self._rootnode.MyPionts,
    self._rootnode.label_lucky_num
  }
  alignNodesOneByAll(nodeTable)
  self.cellDatas = {}
  for i, v in ipairs(self.rankList) do
    local jiangliData = data_lucky_jiangli_lucky_jiangli[i]
    local itemData = {}
    local j = 1
    for k, v in pairs(jiangliData.rewardIds) do
      local iconItem = ResMgr.getRefreshIconItem(v, jiangliData.rewardTypes[j])
      iconItem.num = jiangliData.rewardNums[j] or 0
      j = j + 1
      table.insert(itemData, iconItem)
    end
    table.insert(self.cellDatas, {
      name = v.name,
      point = v.point,
      itemData = itemData
    })
  end
  local boardWidth = self._rootnode.listView:getContentSize().width
  local boardHeight = self._rootnode.listView:getContentSize().height
  local function createFunc(index)
    local item = require("game.nbactivity.LuckyPool.LuckyPoolCell").new()
    return item:create({
      id = index,
      cellData = self.cellDatas[index + 1]
    })
  end
  local function refreshFunc(cell, index)
    cell:refresh({
      id = index,
      cellData = self.cellDatas[index + 1]
    })
  end
  local cellContentSize = require("game.nbactivity.LuckyPool.LuckyPoolCell").new():getContentSize()
  self._rootnode.touchNode:setTouchEnabled(true)
  local posX = 0
  local posY = 0
  self._rootnode.touchNode:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
    posX = event.x
    posY = event.y
  end)
  self.ListTable = require("utility.TableViewExt").new({
    size = CCSizeMake(boardWidth, boardHeight),
    direction = kCCScrollViewDirectionVertical,
    createFunc = createFunc,
    refreshFunc = refreshFunc,
    cellNum = #self.cellDatas,
    cellSize = cellContentSize
  })
  self.ListTable:setPosition(0, 0)
  self._rootnode.listView:addChild(self.ListTable)
end
function LuckyPoolRankLayer:getBaseData(func)
  local function init(data)
    self._data = data
    func()
  end
  self:getBaseInfo({
    callback = function(data)
      dump(data)
      if data["0"] ~= "" then
        dump(data["0"])
      else
        init(data.rtnObj)
      end
    end
  })
end
function LuckyPoolRankLayer:getBaseInfo(param)
  local _callback = param.callback
  local msg = {m = "activity", a = "luckRank"}
  RequestHelper.request(msg, _callback, param.errback)
end
return LuckyPoolRankLayer
