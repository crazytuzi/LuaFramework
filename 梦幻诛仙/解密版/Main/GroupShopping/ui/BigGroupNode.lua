local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local BigGroupNode = Lplus.Extend(TabNode, "BigGroupNode")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local GroupShoppingUtils = require("Main.GroupShopping.GroupShoppingUtils")
local def = BigGroupNode.define
def.field("number").m_curPage = 0
def.field("table").m_goodsData = nil
def.field("number").m_curCfgId = 0
def.field("number").m_timer = 0
def.field("table").m_info = nil
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.method().InitGoodsData = function(self)
  self.m_goodsData = require("Main.GroupShopping.GroupShoppingModule").Instance():GetAllCfgBigGroup()
  local find = false
  for k, v in ipairs(self.m_goodsData) do
    if v == self.m_curCfgId then
      find = k
      break
    end
  end
  if find then
    self.m_curPage = math.floor((find - 1) / constant.CGroupShoppingConsts.BIG_GROUP_SHOPPING_PAGE_SIZE)
  else
    self.m_curPage = 0
    self.m_curCfgId = self.m_goodsData[self.m_curPage * constant.CGroupShoppingConsts.BIG_GROUP_SHOPPING_PAGE_SIZE + 1] or 0
  end
end
def.method("table").SetSwitchParams = function(self, params)
  local cfgId = params and params.cfgId
  if cfgId and self.m_goodsData then
    for k, v in ipairs(self.m_goodsData) do
      if cfgId == v then
        self.m_curCfgId = cfgId
        self.m_curPage = math.floor((k - 1) / constant.CGroupShoppingConsts.BIG_GROUP_SHOPPING_PAGE_SIZE)
        self:UpdatePage()
        self:UpdateItemList()
        self:UpdateContent()
        break
      end
    end
  end
end
def.override().OnShow = function(self)
  Event.RegisterEventWithContext(ModuleId.GROUP_SHOPPING, gmodule.notifyId.GroupShopping.BuyCountChange, BigGroupNode.OnBuyCountChange, self)
  Event.RegisterEventWithContext(ModuleId.GROUP_SHOPPING, gmodule.notifyId.GroupShopping.NeedRefreshData, BigGroupNode.OnUpdate, self)
  self:InitGoodsData()
  self:UpdatePage()
  self:UpdateItemList()
  self:UpdateContent()
end
def.method("table").OnBuyCountChange = function(self, params)
  local cfgId = params.cfgId
  if cfgId == self.m_curCfgId then
    self:UpdateContent()
  end
end
def.method("table").OnUpdate = function(self, params)
  local cfgId = params.cfgId
  if cfgId == self.m_curCfgId then
    self:UpdateContent()
  end
end
def.method().UpdatePage = function(self)
  local lbl = self.m_node:FindDirect("Group_Page/Img_BgPage/Label_Page")
  local fullPage = math.ceil(#self.m_goodsData / constant.CGroupShoppingConsts.BIG_GROUP_SHOPPING_PAGE_SIZE)
  if fullPage == 0 then
    fullPage = 1 or fullPage
  end
  lbl:GetComponent("UILabel"):set_text(string.format("%d/%d", self.m_curPage + 1, fullPage))
end
def.method().UpdateItemList = function(self)
  local list = self.m_node:FindDirect("List_Item")
  local listCmp = list:GetComponent("UIList")
  local count = #self.m_goodsData - self.m_curPage * constant.CGroupShoppingConsts.BIG_GROUP_SHOPPING_PAGE_SIZE >= constant.CGroupShoppingConsts.BIG_GROUP_SHOPPING_PAGE_SIZE and constant.CGroupShoppingConsts.BIG_GROUP_SHOPPING_PAGE_SIZE or #self.m_goodsData - self.m_curPage * constant.CGroupShoppingConsts.BIG_GROUP_SHOPPING_PAGE_SIZE
  listCmp:set_itemCount(count)
  listCmp:Resize()
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    self:FillGoods(uiGo, self.m_goodsData[self.m_curPage * constant.CGroupShoppingConsts.BIG_GROUP_SHOPPING_PAGE_SIZE + i], i)
    self.m_base.m_msgHandler:Touch(uiGo)
  end
end
def.method("userdata", "number", "number").FillGoods = function(self, uiGo, cfgId, index)
  local cfg = GroupShoppingUtils.GetBigGroupCfg(cfgId)
  if cfg then
    local itemBase = ItemUtils.GetItemBase(cfg.itemId)
    if itemBase then
      local nameLbl = uiGo:FindDirect(string.format("Label_Name_%d", index))
      local iconBg = uiGo:FindDirect(string.format("Img_BgIcon_%d", index))
      local icon = uiGo:FindDirect(string.format("Img_BgIcon_%d/Img_Icon_%d", index, index))
      local originPrice = uiGo:FindDirect(string.format("Group_OriPrice_%d/Label_Price_%d", index, index))
      local groupPrice = uiGo:FindDirect(string.format("Group_CurPrice_%d/Label_Price_%d", index, index))
      local mark = uiGo:FindDirect(string.format("Sprite_%d", index))
      nameLbl:GetComponent("UILabel"):set_text(itemBase.name)
      iconBg:GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", itemBase.namecolor))
      GUIUtils.FillIcon(icon:GetComponent("UITexture"), itemBase.icon)
      originPrice:GetComponent("UILabel"):set_text(tostring(cfg.originalPrice))
      groupPrice:GetComponent("UILabel"):set_text(tostring(cfg.groupPrice))
      local isBuy = require("Main.GroupShopping.GroupShoppingModule").Instance():IsInBigGroup(cfg.id)
      if isBuy then
        mark:SetActive(true)
      else
        mark:SetActive(false)
      end
      if cfg.id == self.m_curCfgId then
        uiGo:GetComponent("UIToggle").value = true
      end
    end
  end
end
local minSec = 60
local hourSec = 60 * minSec
local daySec = 24 * hourSec
local function sec2str(sec)
  local day = math.floor(sec / daySec)
  local hour = math.floor((sec - day * daySec) / hourSec)
  local min = math.floor((sec - day * daySec - hour * hourSec) / minSec)
  local second = sec - day * daySec - hour * hourSec - min * minSec
  local timeTbl = {}
  if day > 0 then
    table.insert(timeTbl, day .. textRes.Common.Day)
  end
  if hour > 0 or #timeTbl > 0 then
    table.insert(timeTbl, hour .. textRes.Common.Hour)
  end
  if min > 0 or #timeTbl > 0 then
    table.insert(timeTbl, min .. textRes.Common.Minute)
  end
  table.insert(timeTbl, second .. textRes.Common.Second)
  return table.concat(timeTbl)
end
def.method().UpdateContent = function(self)
  if self.m_curCfgId > 0 then
    self.m_node:FindDirect("Group_Info"):SetActive(false)
    require("Main.GroupShopping.GroupShoppingModule").Instance():RequestCfgDetailInfo(self.m_curCfgId, function(info)
      if self.m_node and not self.m_node.isnil and info.cfgId == self.m_curCfgId then
        self.m_info = info
        GameUtil.RemoveGlobalTimer(self.m_timer)
        self.m_timer = 0
        self.m_node:FindDirect("Group_Info"):SetActive(true)
        local cfg = GroupShoppingUtils.GetBigGroupCfg(info.cfgId)
        if cfg then
          local itemBase = ItemUtils.GetItemBase(cfg.itemId)
          if itemBase then
            local startTime = self.m_node:FindDirect("Group_Info/Group_Top/Group_Time/Label_StartTime")
            local endTime = self.m_node:FindDirect("Group_Info/Group_Top/Group_Time/Label_EndTime")
            local left = self.m_node:FindDirect("Group_Info/Group_Top/Group_Base/Group_Rest/Label_Num")
            local limit = self.m_node:FindDirect("Group_Info/Group_Top/Group_Base/Group_Num/Label_Num")
            local groupPrice = self.m_node:FindDirect("Group_Info/Group_Option/Group_Option01/Group_SalePrice/Label_SalePrice")
            local needNum = self.m_node:FindDirect("Group_Info/Group_Option/Group_Option01/Group_People/Label_GroupNum")
            local haveNum = self.m_node:FindDirect("Group_Info/Group_Option/Group_Option01/Group_CurPeople/Label_GroupNum")
            local buyPrice = self.m_node:FindDirect("Group_Info/Group_Option/Group_Option02/Group_SalePrice/Label_SalePrice")
            local name = self.m_node:FindDirect("Group_Info/Group_Item/Label_Name")
            local typeName = self.m_node:FindDirect("Group_Info/Group_Item/Label_Type")
            local desc = self.m_node:FindDirect("Group_Info/Group_Item/Label_Content")
            name:GetComponent("UILabel"):set_text(itemBase.name)
            typeName:GetComponent("UILabel"):set_text(itemBase.itemTypeName)
            desc:GetComponent("UILabel"):set_text(require("Main.Chat.HtmlHelper").RemoveHtmlTag(itemBase.desc))
            local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
            local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
            local timeCfg = TimeCfgUtils.GetTimeLimitCommonCfg(cfg.timeLimitCfgId)
            if timeCfg then
              do
                local startStr = string.format(textRes.Common[17], timeCfg.startYear, timeCfg.startMonth, timeCfg.startDay, timeCfg.startHour, timeCfg.startMinute)
                startTime:GetComponent("UILabel"):set_text(startStr)
                local startSecond = AbsoluteTimer.GetServerTimeByDate(timeCfg.startYear, timeCfg.startMonth, timeCfg.startDay, timeCfg.startHour, timeCfg.startMinute, 0)
                local endSecond = AbsoluteTimer.GetServerTimeByDate(timeCfg.endYear, timeCfg.endMonth, timeCfg.endDay, timeCfg.endHour, timeCfg.endMinute, 0)
                local curTime = GetServerTime()
                if startSecond > curTime then
                  local lastSecond = endSecond - startSecond
                  local lastStr = sec2str(lastSecond)
                  endTime:GetComponent("UILabel"):set_text(lastStr)
                elseif endSecond < curTime then
                  endTime:GetComponent("UILabel"):set_text(textRes.GroupShopping[6])
                else
                  do
                    local lastSecond = endSecond - curTime
                    local lastStr = sec2str(lastSecond)
                    local endTimeLbl = endTime:GetComponent("UILabel")
                    endTimeLbl:set_text(string.format(textRes.GroupShopping[8], lastStr))
                    self.m_timer = GameUtil.AddGlobalTimer(1, false, function()
                      if endTimeLbl.isnil then
                        GameUtil.RemoveGlobalTimer(self.m_timer)
                        self.m_timer = 0
                        return
                      end
                      local lastSecond = endSecond - GetServerTime()
                      if lastSecond < 0 then
                        GameUtil.RemoveGlobalTimer(self.m_timer)
                        self.m_timer = 0
                        endTimeLbl:set_text(textRes.GroupShopping[6])
                      else
                        local lastStr = sec2str(lastSecond)
                        endTimeLbl:set_text(string.format(textRes.GroupShopping[8], lastStr))
                      end
                    end)
                  end
                end
              end
            end
            left:GetComponent("UILabel"):set_text(0 <= info.remain and tostring(info.remain) or textRes.GroupShopping[5])
            if 0 < cfg.maxBuyNum then
              limit:GetComponent("UILabel"):set_text(string.format("%d/%d", info.buyCount, cfg.maxBuyNum))
            else
              limit:GetComponent("UILabel"):set_text(textRes.GroupShopping[5])
            end
            groupPrice:GetComponent("UILabel"):set_text(tostring(cfg.groupPrice))
            needNum:GetComponent("UILabel"):set_text(tostring(cfg.groupSize))
            haveNum:GetComponent("UILabel"):set_text(tostring(info.memberNum))
            buyPrice:GetComponent("UILabel"):set_text(tostring(cfg.singlePrice))
          end
        end
      end
    end)
  else
    GameUtil.RemoveGlobalTimer(self.m_timer)
    self.m_timer = 0
    self.m_node:FindDirect("Group_Info"):SetActive(false)
  end
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.GROUP_SHOPPING, gmodule.notifyId.GroupShopping.BuyCountChange, BigGroupNode.OnBuyCountChange)
  Event.UnregisterEvent(ModuleId.GROUP_SHOPPING, gmodule.notifyId.GroupShopping.NeedRefreshData, BigGroupNode.OnUpdate)
  self.m_goodsData = nil
  GameUtil.RemoveGlobalTimer(self.m_timer)
  self.m_timer = 0
  self.m_info = nil
end
def.override("string").onClick = function(self, id)
  if id == "Btn_Join" then
    if self.m_info and self.m_info.cfgId == self.m_curCfgId then
      local open = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GROUP_SHOPPING_BIG_GROUP)
      if not open then
        Toast(textRes.GroupShopping[31])
        return
      end
      require("Main.GroupShopping.GroupShoppingModule").Instance():JoinGroupBuy(self.m_info.groupId, self.m_curCfgId, self.m_info.buyCount, self.m_info.remain)
    end
  elseif id == "Btn_Buy" then
    if self.m_info and self.m_info.cfgId == self.m_curCfgId then
      local open = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GROUP_SHOPPING_BIG_SINGLE)
      if not open then
        Toast(textRes.GroupShopping[31])
        return
      end
      require("Main.GroupShopping.GroupShoppingModule").Instance():PriceBuy(self.m_curCfgId, self.m_info.buyCount)
    end
  elseif id == "Btn_Next" then
    if (self.m_curPage + 1) * constant.CGroupShoppingConsts.BIG_GROUP_SHOPPING_PAGE_SIZE < #self.m_goodsData then
      self.m_curPage = self.m_curPage + 1
      self.m_curCfgId = self.m_goodsData[self.m_curPage * constant.CGroupShoppingConsts.BIG_GROUP_SHOPPING_PAGE_SIZE + 1] or 0
      self:UpdatePage()
      self:UpdateItemList()
      self:UpdateContent()
    end
  elseif id == "Btn_Back" then
    if self.m_curPage > 0 then
      self.m_curPage = self.m_curPage - 1
      self.m_curCfgId = self.m_goodsData[self.m_curPage * constant.CGroupShoppingConsts.BIG_GROUP_SHOPPING_PAGE_SIZE + 1] or 0
      self:UpdatePage()
      self:UpdateItemList()
      self:UpdateContent()
    end
  elseif string.sub(id, 1, 11) == "Group_Item_" then
    local index = tonumber(string.sub(id, 12))
    if index then
      local cfgId = self.m_goodsData[self.m_curPage * constant.CGroupShoppingConsts.BIG_GROUP_SHOPPING_PAGE_SIZE + index]
      if not require("Main.GroupShopping.GroupShoppingModule").Instance():IsBan(cfgId) then
        self.m_curCfgId = cfgId
        self:UpdateContent()
      else
        Toast(textRes.GroupShopping[35])
        self:UpdateItemList()
      end
    end
  end
end
BigGroupNode.Commit()
return BigGroupNode
