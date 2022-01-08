--[[
******元宝不足（首冲）*******

    -- by King
    -- 2015/10/05
]]
local BuyCoinLayer = class("BuyCoinLayer", BaseLayer)

CREATE_SCENE_FUN(BuyCoinLayer)
CREATE_PANEL_FUN(BuyCoinLayer)



local BuyCoinData = require("lua.table.t_s_buy_coin")

function BuyCoinLayer:ctor(data)
    self.super.ctor(self,data)

    self:init("lua.uiconfig_mango_new.shop.BuyTongbi")
end

function BuyCoinLayer:initUI(ui)
    self.super.initUI(self,ui)

    self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close')
    self.img_TopArea    = TFDirector:getChildByPath(ui, 'img_background')
    self.img_BottomArea = TFDirector:getChildByPath(ui, 'img_result')

    self.img_quality_bg = TFDirector:getChildByPath(ui, 'img_quality_bg')
    self.img_icon       = TFDirector:getChildByPath(ui, 'img_icon')
    self.txt_name       = TFDirector:getChildByPath(ui, 'txt_name')


    self.btn_buy          = TFDirector:getChildByPath(ui, 'Btn_buy')
    self.btn_buymany          = TFDirector:getChildByPath(ui, 'Btn_buy3')

    self.txt_yuanbaonum   = TFDirector:getChildByPath(ui, 'txt_yuanbao')
    self.txt_tongbinum    = TFDirector:getChildByPath(ui, 'txt_tongbi')
    -- 购买铜币剩余总次数
    self.txt_remaining_num= TFDirector:getChildByPath(ui, 'txt_time')
    -- self.img_price1     = TFDirector:getChildByPath(ui, 'img_price1')
    -- self.img_price2     = TFDirector:getChildByPath(ui, 'img_price2')
    self.txt_times     = TFDirector:getChildByPath(ui, 'txt_buytimes')

    self.txt_result    = TFDirector:getChildByPath(ui, 'txt_result')
    self.panel_history = TFDirector:getChildByPath(ui, 'panel_history')
    -- BuyTongbiCell
    -- self.panel_resultcell = TFDirector:getChildByPath(ui, 'Panel_resultcell')
    -- self.panel_resultcell:setVisible(false)

    self.bIsShowBottomArea = false

    self.usedTimes  = 2
    self.timeCountStep  = 0

    self.resultList = MEMapArray:new()

    -- local haveBuyTime   = 1

    -- local info = BuyCoinData:objectByID(self.usedTimes)

    -- if info == nil then
    --   return
    -- end
    -- self.timeCountStep = info.step_index

    -- local needSycee = info.sycee
    -- local totalTimes = 0
    -- for v in BuyCoinData:iterator() do
    --     if v.sycee == needSycee then
    --         totalTimes = totalTimes + 1
    --     end
    -- end

    -- self.totalStepTimes = totalTimes

     MallManager:resetBuyCoin()
end

function BuyCoinLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI()
    self:refreshUI()
end

function BuyCoinLayer:refreshBaseUI()

end

function BuyCoinLayer:refreshUI()
    if not self.isShow then
        return
    end

    -- if self.bIsShowBottomArea == false then
    --   self:setTopMiddle()
    --   self.img_BottomArea:setVisible(false)
    -- else
    --   -- setTopMiddle
    -- end

    self:drawTopArea()
end


function BuyCoinLayer:removeUI()
    self.super.removeUI(self)
end


function BuyCoinLayer.onPayClickHandle(sender)
    local self = sender.logic
    PayManager:showPayHomeLayer(AlertManager.NONE)
    -- AlertManager:closeLayer(self)
end

function BuyCoinLayer.onVipClickHandle(sender)
   local self = sender.logic
   PayManager:showVipLayer(AlertManager.NONE)
   AlertManager:closeLayer(self)
end

function BuyCoinLayer.onclikFirstPayReward(sender)
   local self = sender.logic

   PayManager:requestFirstChargeReward()
   AlertManager:closeLayer(self)
end

--注册事件
function BuyCoinLayer:registerEvents()
   self.super.registerEvents(self)

   ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
   -- ADD_ALERT_CLOSE_LISTENER(self,self.btn_cancel)
   --  self.btn_close:setClickAreaLength(100)

   self.btn_buy.logic=self
   self.btn_buy:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.OnClickBuyOnce),1)

   self.btn_buymany.logic=self
   self.btn_buymany:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.OnClickBuyMore),1)

    self.updateBuyCoinResult = function(event)
      if self.showBuyCoinResult == nil then
        -- self.ui:runAnimation("Action0",1)
        self.showBuyCoinResult = true
      end 
      play_lingqu()
      self:refreshUI()
    end

    TFDirector:addMEGlobalListener(MallManager.BuyCoinCallBackEvent, self.updateBuyCoinResult);

   -- self.btn_get.logic=self
   -- self.btn_get:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onclikFirstPayReward),1)
end

function BuyCoinLayer:removeEvents()
    self.super.removeEvents(self)
    
    TFDirector:removeMEGlobalListener(MallManager.BuyCoinCallBackEvent, self.updateBuyCoinResult)
    self.updateBuyCoinResult = nil
end

function BuyCoinLayer:drawTopArea()

  -- -- EnumDropType.COIN
  --   local coinInfo = BaseDataManager:getReward({type = EnumDropType.COIN})
  --   local path = GetColorIconByQuality(coinInfo.quality)
  --   self.img_quality_bg:setTexture(path)
  --   self.img_icon:setTexture(coinInfo.path)
  --   self.txt_name:setText(coinInfo.name)

    -- local txt_price1    = TFDirector:getChildByPath(self.img_price1, 'txt_price')
    -- local txt_price2    = TFDirector:getChildByPath(self.img_price2, 'txt_price')
    self.usedTimes = MallManager.buyCoinNum

    self.leveaTimes = 0
    -- 剩余总次数
    local CurVip        = MainPlayer:getVipLevel()
    local curVipInfo    = VipData:getVipItemByTypeAndVip(3000, CurVip)
    if curVipInfo then
      local totalTimes = curVipInfo.benefit_value
      self.leveaTimes = totalTimes - self.usedTimes
      if self.leveaTimes < 0 then
        self.leveaTimes = 0
      end

      self.txt_remaining_num:setText(self.leveaTimes)

      print("当前vip可以购买的总次数：", totalTimes)
      print("已购买的总次数：", self.usedTimes)
      print("剩余总次数：", self.leveaTimes)
    end


    local info = BuyCoinData:objectByID(self.usedTimes + 1)
    if info == nil then
      return
    end

    local needSycee = info.sycee
    local totalTimes = 0
    for v in BuyCoinData:iterator() do
        if v.sycee == needSycee then
            totalTimes = totalTimes + 1
        end
    end
    self.totalStepTimes = totalTimes

    print("info.step_index = ", info.step_index)
    self.timeCountStep = totalTimes + 1 - info.step_index
    self.needPerCost = info.sycee

    self.txt_yuanbaonum:setText(info.sycee)
    self.txt_tongbinum:setText(info.coin)


    print("当前档次可以购买的总次数：", totalTimes)
    print("当前剩余购买的总次数：", self.timeCountStep)
    self.StepLeveaTimes = self.timeCountStep
    if self.StepLeveaTimes > self.leveaTimes then
    	self.StepLeveaTimes = self.leveaTimes
    end

    print("实际剩余购买的总次数：", self.StepLeveaTimes)
    self.txt_times:setText(self.StepLeveaTimes)

    self:drawBottomArea()
end

function BuyCoinLayer:drawBottomArea()
  -- self.txt_result:setText("131313")
  if self.resultTableView ~= nil then
    self.resultTableView:reloadData()
    self.resultTableView:setScrollToBegin(false)
    return
  end

  local  resultTableView =  TFTableView:create()
  local tableviewSize = self.panel_history:getContentSize()
  print("tableviewSize = ", tableviewSize)
  resultTableView:setTableViewSize(tableviewSize)
  resultTableView:setDirection(TFTableView.TFSCROLLVERTICAL)
  resultTableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
  -- resultTableView:setPosition(self.panel_history:getPosition())
  -- resultTableView:setPosition(ccp(0,-50))
  self.resultTableView = resultTableView
  self.resultTableView.logic = self

  resultTableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
  resultTableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
  resultTableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
  resultTableView:reloadData()

  -- self.panel_history:getParent():addChild(self.resultTableView,1)
  self.panel_history:addChild(self.resultTableView,1)
end



function BuyCoinLayer.numberOfCellsInTableView(table)
    -- local self  = table.logic
    -- local num   = self.resultList:length()

    return MallManager.buyCoinResultList:length()
end

function BuyCoinLayer.cellSizeForTable(table,idx)
    return 50, 638
end

function BuyCoinLayer.tableCellAtIndex(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        -- node = require('lua.logic.activity.operation.exchangeCell')
        node = createUIByLuaNew("lua.uiconfig_mango_new.shop.BuyTongbiCell")
     

        node:setPosition(ccp(0, 0))
        cell:addChild(node)
        node:setTag(617)
        node.logic = self
    end

    node = cell:getChildByTag(617)
    node.index = idx + 1
    self:drawResultCell(node)
    -- node:setVisible(true)
    return cell
end

function BuyCoinLayer:drawResultCell(node)
  local self   = node.logic
  local index  = node.index

  local result = MallManager.buyCoinResultList:objectAt(index)

  print("result = ", result)

    --  required int32 consume = 1;       //消耗的元宝数量
  -- required int32 coin=2;         //获得铜币数量
  -- required int32 mutil=3;          //倍数

-- txt_baoji

  local txt_baoji  = TFDirector:getChildByPath(node, 'txt_baoji')
  local txt_out   = TFDirector:getChildByPath(node, 'txt_tongbi')
  local txt_int   = TFDirector:getChildByPath(node, 'txt_yuanbao')
  
  local nBaoji = result.mutil + 1

  if nBaoji <= 1 then
    txt_baoji:setVisible(false)
  else
    txt_baoji:setVisible(true)
  end

  txt_int:setText(result.consume)
  --txt_baoji:setText("暴击x"..nBaoji)
  txt_baoji:setText(stringUtils.format(localizable.buyCoinLayer_crit,nBaoji))
  txt_out:setText(result.coin)
end

function BuyCoinLayer.OnClickBuyOnce(sender)
  local self = sender.logic

  -- self:openBottomArea()

    local benefit_value = 0
    local CurVip        = MainPlayer:getVipLevel()

    if self.leveaTimes <= 0 then
      --toastMessage("没有购买次数了")
      toastMessage(localizable.common_not_buy_times)
      return
    end

    if MainPlayer:isEnoughSycee(self.needPerCost, true) then
      MallManager:BuyCoin(1)
    end
end

function BuyCoinLayer.OnClickBuyMore(sender)
  local self = sender.logic

  -- self:openBottomArea()

    local benefit_value = 0
    local CurVip        = MainPlayer:getVipLevel()

    if self.leveaTimes <= 0 then
      --toastMessage("没有购买次数了")
      toastMessage(localizable.common_not_buy_times)
      return
    end
    local moreTimes = self.StepLeveaTimes

    if moreTimes > self.leveaTimes then
      moreTimes = self.leveaTimes
    end



    if MainPlayer:isEnoughSycee( moreTimes *  self.needPerCost, true) then
      MallManager:BuyCoin(moreTimes)
    end

end



return BuyCoinLayer
