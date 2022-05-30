require("data.data_error_error")
local data_vip_qiandao = require("data.data_qiandao_haohua_haohua")
local data_item_item = require("data.data_item_item")
local data_card_card = require("data.data_card_card")
local MAX_ZORDER = 1111
local VipQiandaoLayer = class("VipQiandaoLayer", function()
  return require("utility.ShadeLayer").new()
end)
function VipQiandaoLayer:getInfomation()
  if self._withData == false or self._state == 1 then
    RequestHelper.vipqiandao.vipqiandaoStatus({
      callback = function(data)
        dump(data)
        if data["0"] ~= "" then
          dump(data["0"])
        else
          self:initData(data.rtnObj)
        end
      end
    })
  end
end
function VipQiandaoLayer:getReward()
  RequestHelper.vipqiandao.getReward({
    callback = function(data)
      dump(data)
      if data["0"] ~= "" then
        CCMessageBox(data["0"], "Error")
      else
        local rtnObj = data.rtnObj
        self:updataBtnState(3)
        local _count = #rtnObj
        local _data = {}
        if _count > 0 then
          for i = 1, _count do
            local type = rtnObj[i].t
            local num = rtnObj[i].n
            local itemId = rtnObj[i].id
            local iconType = ResMgr.getResType(type)
            local itemData
            if iconType == ResMgr.HERO then
              itemData = data_card_card[itemId]
            else
              if iconType == ResMgr.ITEM or iconType == ResMgr.EQUIP then
                itemData = data_item_item[itemId]
              else
              end
            end
            table.insert(_data, {
              id = itemId,
              name = itemData.name,
              num = num,
              type = type,
              iconType = iconType
            })
          end
          local title = common:getLanguageString("@GetRewards")
          local msgBox = require("game.Huodong.RewardMsgBox").new({title = title, cellDatas = _data})
          game.runningScene:addChild(msgBox, MAX_ZORDER)
        end
      end
    end
  })
end
function VipQiandaoLayer:ctor(param)
  self._curInfoIndex = -1
  self._state = -1
  self._withData = false
  local viewSize = param.viewSize
  local proxy = CCBProxy:create()
  self._rootnode = {}
  local node = CCBuilderReaderLoad("nbhuodong/vip_qiandao.ccbi", proxy, self._rootnode, self, viewSize)
  self:addChild(node)
  local bgSprite = display.newSprite("ui/jpg_bg/diaoyu_bg.jpg")
  bgSprite = bgSprite or display.newSprite("ui/jpg_bg/vip_qiandao_bg.jpg")
  self._rootnode.qiandao_bg:setDisplayFrame(bgSprite:getDisplayFrame())
  self._rootnode.qiandao_bg:setPosition(viewSize.width / 2, viewSize.height / 2)
  self:initItemLoc()
  self:updataBtnState(self._state)
  self:getInfomation()
end
function VipQiandaoLayer:updataBtnState(state)
  if state == 1 then
    self._rootnode.rewardBtn:setVisible(false)
    self._rootnode.tag_has_get:setVisible(false)
    self._rootnode.buyBtn:setVisible(true)
  elseif state == 2 then
    self._rootnode.buyBtn:setVisible(false)
    self._rootnode.tag_has_get:setVisible(false)
    self._rootnode.rewardBtn:setVisible(true)
  elseif state == 3 then
    self._rootnode.buyBtn:setVisible(false)
    self._rootnode.rewardBtn:setVisible(false)
    self._rootnode.tag_has_get:setVisible(true)
  else
    self._rootnode.buyBtn:setVisible(false)
    self._rootnode.rewardBtn:setVisible(false)
    self._rootnode.tag_has_get:setVisible(false)
  end
end
function VipQiandaoLayer:initData(data)
  self._state = data.state
  self:updataBtnState(self._state)
  if self._withData then
    return
  end
  self._rootnode.buyBtn:addHandleOfControlEvent(function(eventName, sender)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    local chongzhiLayer = require("game.shop.Chongzhi.ChongzhiLayer").new()
    chongzhiLayer:chongzhiCallBack(function()
      self:getInfomation()
    end)
    game.runningScene:addChild(chongzhiLayer, MAX_ZORDER)
  end, CCControlEventTouchUpInside)
  self._rootnode.rewardBtn:addHandleOfControlEvent(function(eventName, sender)
    self._rootnode.rewardBtn:setEnabled(false)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    self:getReward()
  end, CCControlEventTouchUpInside)
  local level = data.level
  local state = data.state
  self._rewardDatas = {}
  for k = 1, #data_vip_qiandao do
    local v = data_vip_qiandao[k]
    local min = v.grade_section
    local max = 1000
    if data_vip_qiandao[k + 1] then
      max = data_vip_qiandao[k + 1].grade_section - 1
    end
    if level <= max and level >= min then
      for i = 1, v.num do
        local type = v.arr_type[i]
        local num = v.arr_num[i]
        local itemId = v.arr_item[i]
        local iconType = ResMgr.getResType(type)
        local itemData
        if iconType == ResMgr.HERO then
          itemData = data_card_card[itemId]
        elseif iconType == ResMgr.ITEM or iconType == ResMgr.EQUIP then
          itemData = data_item_item[itemId]
        else
          ResMgr.showAlert(itemId, "qiandao_haohua表，vip签到赠送物品的数据不对index:" .. i)
        end
        table.insert(self._rewardDatas, {
          id = itemId,
          name = itemData.name,
          num = num,
          type = type,
          iconType = iconType
        })
      end
      break
    end
  end
  self._withData = true
  self:initRewardDataShow()
  self:initItemClickEnable()
end
function VipQiandaoLayer:initItemLoc()
  self.rewardItemLoc = {y = 70}
  self.rewardItemLoc[1] = {270}
  self.rewardItemLoc[2] = {200, 335}
  self.rewardItemLoc[3] = {
    132,
    265.5,
    400
  }
  self.rewardItemLoc[4] = {
    65,
    200,
    335,
    470
  }
  self.rewardItemLoc[5] = {
    45,
    156,
    267,
    378,
    490
  }
end
function VipQiandaoLayer:initItemClickEnable()
  for i = 1, #self._rewardDatas do
    do
      local data = self._rewardDatas[i]
      addTouchListener(self._rootnode["reward_" .. i], function(sender, eventType)
        if eventType == EventType.began then
          local itemInfo = require("game.Huodong.ItemInformation").new({
            id = data.id,
            type = data.type,
            name = data_item_item[data.id].name,
            describe = data_item_item[data.id].dis
          })
          CCDirector:sharedDirector():getRunningScene():addChild(itemInfo, 1000, 1111)
        end
      end)
    end
  end
end
function VipQiandaoLayer:initRewardDataShow()
  local rewardLen = #self._rewardDatas
  local pos = self.rewardItemLoc[rewardLen]
  for i = 1, 5 do
    if i <= rewardLen then
      local itemData = self._rewardDatas[i]
      self:initItemData(i, itemData)
      self._rootnode["reward_" .. i]:setVisible(true)
      self._rootnode["reward_" .. i]:setPosition(pos[i], self.rewardItemLoc.y)
    else
      self._rootnode["reward_" .. i]:setVisible(false)
    end
  end
end
function VipQiandaoLayer:initItemData(index, data)
  local itemData = data
  local rewardIcon = self._rootnode["reward_icon_" .. index]
  rewardIcon:removeAllChildrenWithCleanup(true)
  ResMgr.refreshItemWithTagNumName({
    id = itemData.id,
    itemBg = rewardIcon,
    resType = itemData.iconType,
    isShowIconNum = false,
    itemNum = itemData.num,
    itemType = itemData.type,
    cls = 0
  })
end
return VipQiandaoLayer
