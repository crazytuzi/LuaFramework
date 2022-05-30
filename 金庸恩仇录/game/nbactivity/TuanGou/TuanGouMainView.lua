local data_item_item = require("data.data_item_item")
local TuanGouMainView = class("TuanGouMainView", function()
  return display.newLayer("TuanGouMainView")
end)
local MAXZORDER = 1111
local ShopType = {
  commonType = 1,
  supperType = 2,
  vipType = 3
}
local MenuItem = {
  {
    type = ShopType.commonType,
    name = "btn_common"
  },
  {
    type = ShopType.supperType,
    name = "btn_supper"
  },
  {
    type = ShopType.vipType,
    name = "btn_vip"
  }
}
function TuanGouMainView:clear()
  self.showTuanGouMainView = false
end
function TuanGouMainView:changePageByType(type)
  self._type = type
  self.isCanBuy = self.paystatus ~= 0
  for i = 101, 103 do
    self._rootnode.bottom_panel:removeChildByTag(i)
  end
  local dis_01 = ui.newTTFLabelWithOutline({
    text = common:getLanguageString("@VIPdjdd"),
    size = 26,
    color = FONT_COLOR.YELLOW,
    outlineColor = ccc3(0, 0, 0),
    font = FONTS_NAME.font_fzcy,
    align = ui.TEXT_ALIGN_LEFT
  })
  dis_01:setPosition(cc.p(20, 80))
  self._rootnode.bottom_panel:addChild(dis_01, 1, 101)
  dis_01:setColor(self.isCanBuy and FONT_COLOR.YELLOW or FONT_COLOR.GRAY)
  local datanum = get_table_len(self.data[tostring(self._type)])
  local function buycall(param, buyType)
    if not self.showTuanGouMainView then
      return
    end
    local buyType = param[2]
    local productId = tonumber(param[3])
    local count = param[4]
    local pos = -1
    for k, v in ipairs(self.data[tostring(buyType)]) do
      if v.id == productId then
        pos = k
        break
      end
    end
    if pos == -1 then
      return
    end
    self.data[tostring(buyType)][pos].lastNum = count
    if buyType == self._type then
      local newdata = self.data[tostring(buyType)][pos]
      self.ListTable:reloadCell(pos - 1, {
        itemData = newdata,
        isCanBuy = self.isCanBuy,
        buytype = buyType
      })
    end
  end
  local function createFunc(index)
    local v = self.data[tostring(self._type)][index + 1]
    local item = require("game.nbactivity.TuanGou.TuanGouItemView").new({
      itemData = v,
      isCanBuy = self.isCanBuy,
      buytype = self._type,
      callback = buycall
    })
    return item
  end
  local function refreshFunc(cell, index)
    local v = self.data[tostring(self._type)][index + 1]
    cell:refresh({
      itemData = v,
      isCanBuy = self.isCanBuy,
      buytype = self._type
    })
  end
  local touchFunc = function(cell)
  end
  if self.ListTable then
    self.ListTable:resetCellNum(datanum)
    self.ListTable:reloadData()
  else
    self.ListTable = require("utility.TableViewExt").new({
      size = CCSizeMake(593, 310),
      touchFunc = touchFunc,
      createFunc = createFunc,
      refreshFunc = refreshFunc,
      cellNum = datanum,
      cellSize = CCSizeMake(130, 310)
    })
    self.ListTable:setPosition(-16, -40)
    self._goodsPanel:addChild(self.ListTable)
  end
  for k, v in ipairs(MenuItem) do
    if self._type == v.type then
      self._rootnode[v.name]:selected()
    else
      self._rootnode[v.name]:unselected()
    end
  end
end
function TuanGouMainView:setTimeStr(param)
  local viewSize = param.size
  self._actLabel = ui.newTTFLabelWithOutline({
    text = "2012-10-10 20:23:20至2012-10-10 20:23:20",
    size = 23,
    color = ccc3(0, 254, 60),
    outlineColor = ccc3(0, 0, 0),
    align = ui.TEXT_ALIGN_CENTE,
    font = FONTS_NAME.font_fzcy
  })
  self._actLabel:setString(self._start .. common:getLanguageString("@DateTo") .. self._end)
  self._actLabel:setPosition(viewSize.width * 0.15, viewSize.height - 30)
  self:addChild(self._actLabel)
end
function TuanGouMainView:ctor(param)
  self.showTuanGouMainView = true
  local function func()
    self:setTimeStr(param)
    self:changePageByType(ShopType.commonType)
  end
  local viewSize = param.size
  local proxy = CCBProxy:create()
  self._rootnode = {}
  local node = CCBuilderReaderLoad("nbhuodong/tuangou_layer.ccbi", proxy, self._rootnode, self, viewSize)
  node:setPosition(cc.p(display.width / 2, 0))
  self:addChild(node)
  self._goodsPanel = self._rootnode.goodsPanel
  self:getBaseData(func)
  self._rootnode.btn_common:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, function(event)
    self:changePageByType(ShopType.commonType)
  end)
  self._rootnode.btn_supper:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, function(event)
    self:changePageByType(ShopType.supperType)
  end)
  self._rootnode.btn_vip:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, function(event)
    self:changePageByType(ShopType.vipType)
  end)
  self._rootnode.btn_charge:addHandleOfControlEvent(function(eventName, sender)
    local chongzhiLayer = require("game.shop.Chongzhi.ChongzhiLayer").new()
    game.runningScene:addChild(chongzhiLayer, MAXZORDER)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
  end, CCControlEventTouchUpInside)
end
function TuanGouMainView:timeFormat(timeAll)
  local basehour = 3600
  local basemin = 60
  local hour = math.floor(timeAll / basehour)
  local time = timeAll - hour * basehour
  local min = math.floor(time / basemin)
  local time = time - basemin * min
  local sec = math.floor(time)
  if hour < 10 then
    hour = "0" .. hour or hour
  end
  if min < 10 then
    min = "0" .. min or min
  end
  if sec < 10 then
    sec = "0" .. sec or sec
  end
  local nowTimeStr = hour .. common:getLanguageString("@Hour") .. min .. common:getLanguageString("@Minute") .. sec .. common:getLanguageString("@Sec")
  return nowTimeStr
end
function TuanGouMainView:getBaseData(func)
  local function init(data)
    if not self.showTuanGouMainView then
      return
    end
    self.data = data.activityGropBuyMap
    self.paystatus = data.paystatus
    self._start = data.startTime
    self._end = data.endTime
    func()
  end
  RequestHelper.tuanGouSystem.getBaseInfo({
    callback = function(data)
      if not self.showTuanGouMainView then
        return
      end
      if data["0"] ~= "" then
        dump(data["0"])
      else
        dump(data.rtnObj)
        init(data.rtnObj)
      end
    end
  })
end
return TuanGouMainView
