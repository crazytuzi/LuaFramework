local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local Vector3 = require("Types.Vector3").Vector3
local ChargeAndCostPanel = Lplus.Extend(ECPanelBase, "ChargeAndCostPanel")
local CustomActivityInterface = require("Main.CustomActivity.CustomActivityInterface")
local ActivityInterface = require("Main.activity.ActivityInterface")
local customActivityInterface = CustomActivityInterface.Instance()
local def = ChargeAndCostPanel.define
local instance
def.field("string").curTabName = ""
def.field("table").chargeCfgList = nil
def.field("table").accumCostList = nil
def.static("=>", ChargeAndCostPanel).Instance = function()
  if instance == nil then
    instance = ChargeAndCostPanel()
    instance:Init()
    instance.m_TrigGC = true
    instance.m_TryIncLoadSpeed = true
  end
  return instance
end
def.method().Init = function(self)
end
def.method("string").ShowPanel = function(self, tabName)
  if self:IsShow() then
    return
  end
  self.curTabName = tabName
  self:CreatePanel(RESPATH.PREFAB_PRIZE_LIMIT_RECHARE, 0)
end
def.override().OnCreate = function(self)
end
def.override().OnDestroy = function(self)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    Event.RegisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.LIMIT_CHARGE_INFO_CHANGE, ChargeAndCostPanel.OnLimitChargeInfoChange)
    Event.RegisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.LIMIT_ACCUM_COST_CHANGE, ChargeAndCostPanel.OnLimitCostInfoChange)
    if self.curTabName == "Tab_LimitRecharge" then
      self:setChargeList()
    elseif self.curTabName == "Tab_LimitCost" then
      self:setAccumCostList()
    end
  else
    Event.UnregisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.LIMIT_CHARGE_INFO_CHANGE, ChargeAndCostPanel.OnLimitChargeInfoChange)
    Event.UnregisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.LIMIT_ACCUM_COST_CHANGE, ChargeAndCostPanel.OnLimitCostInfoChange)
  end
end
def.static("table", "table").OnLimitChargeInfoChange = function(p1, p2)
  if instance.curTabName == "Tab_LimitRecharge" then
    instance:setChargeList()
  end
end
def.static("table", "table").OnLimitCostInfoChange = function(p1, p2)
  if instance.curTabName == "Tab_LimitCost" then
    instance:setAccumCostList()
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
  self.chargeCfgList = nil
  self.accumCostList = nil
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  local strs = string.split(id, "_")
  if id == "Btn_Close" then
    self:Hide()
  elseif strs[1] == "Btn" and strs[2] == "Get" then
    self:getAward(tonumber(strs[3]))
  elseif string.sub(id, 1, 10) == "Img_BgIcon" then
    local itemIdx = string.sub(id, 11, 11)
    local index = string.sub(id, 13)
    self:showAwardItemTip(tonumber(index), tonumber(itemIdx), clickObj)
  end
end
def.method("number", "=>", "table").getActivityCfgList = function(self, activityId)
  local chargeCfg = CustomActivityInterface.GetSaveAMTCfgByActivityId(activityId)
  if chargeCfg then
    local cfgList = {}
    local chargeInfo = customActivityInterface:getLimitChargeInfo()
    local totalRecharge = tonumber(ItemModule.Instance():GetYuanbao(ItemModule.CASH_SAVE_AMT):tostring())
    local saveAmt = totalRecharge - chargeInfo.base_save_amt
    for _, v in pairs(chargeCfg) do
      if saveAmt >= v.display_save_amt_cond then
        table.insert(cfgList, v)
      end
    end
    table.sort(cfgList, function(cfg1, cfg2)
      return cfg1.sortid < cfg2.sortid
    end)
    return cfgList
  end
  return nil
end
def.method("=>", "number").getSaveAmt = function(self)
  local chargeInfo = customActivityInterface:getLimitChargeInfo()
  local totalRecharge = tonumber(ItemModule.Instance():GetYuanbao(ItemModule.CASH_SAVE_AMT):tostring())
  local saveAmt = totalRecharge - chargeInfo.base_save_amt
  return saveAmt
end
def.method().setChargeList = function(self)
  local activityId = CustomActivityInterface.LIMIT_CHARGE_ACTIVITY_ID
  local chargeCfgList = self:getActivityCfgList(activityId)
  local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  local Label_Time = self.m_panel:FindDirect("Label_2/Label_Time")
  local Label_Tips = self.m_panel:FindDirect("Label_2/Label_Tips")
  local Label_1 = self.m_panel:FindDirect("Label_1")
  Label_1:GetComponent("UILabel"):set_text(textRes.customActivity[1])
  Label_Time:GetComponent("UILabel"):set_text(activityCfg.timeDes)
  Label_Tips:GetComponent("UILabel"):set_text(activityCfg.activityDes)
  local chargeInfo = customActivityInterface:getLimitChargeInfo()
  local saveAmt = self:getSaveAmt()
  local Label_Num = self.m_panel:FindDirect("Label_1/Label_Num")
  Label_Num:GetComponent("UILabel"):set_text(saveAmt)
  local List_Prize = self.m_panel:FindDirect("Group_GrowFund/Scroll View/List_Prize")
  local uilist = List_Prize:GetComponent("UIList")
  uilist.itemCount = #chargeCfgList
  uilist:Resize()
  local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  self.chargeCfgList = chargeCfgList
  for i, v in ipairs(chargeCfgList) do
    local Img_Bg = List_Prize:FindDirect(string.format("Img_Bg_%d", i))
    local Img_Get = Img_Bg:FindDirect("Img_Get_" .. i)
    local Btn_Get = Img_Bg:FindDirect("Btn_Get_" .. i)
    local Img_Red = Btn_Get:FindDirect("Img_Red_" .. i)
    local Label_titel = Img_Bg:FindDirect("Label_1_" .. i)
    local Label_2 = Img_Bg:FindDirect("Label_2_" .. i)
    local Label_Num = Img_Bg:FindDirect("Label_Num_" .. i)
    Label_2:GetComponent("UILabel"):set_text(textRes.customActivity[3])
    Label_titel:GetComponent("UILabel"):set_text(v.desc)
    Label_Num:GetComponent("UILabel"):set_text(saveAmt .. "/" .. v.saveAmt)
    if i <= chargeInfo.sortid then
      Img_Get:SetActive(true)
      Btn_Get:SetActive(false)
    else
      Img_Get:SetActive(false)
      Btn_Get:SetActive(true)
      local Btn_Label = Btn_Get:FindDirect("Label_" .. i)
      if saveAmt >= v.saveAmt then
        Img_Red:SetActive(true)
        Btn_Label:GetComponent("UILabel"):set_text(textRes.customActivity[7])
      else
        Img_Red:SetActive(false)
        Btn_Label:GetComponent("UILabel"):set_text(textRes.customActivity[6])
      end
    end
    local key = string.format("%d_%d_%d", v.award_id, occupation.ALL, gender.ALL)
    local awardcfg = ItemUtils.GetGiftAwardCfg(key)
    local Group_Icon = Img_Bg:FindDirect("Group_Icon_" .. i)
    for k = 1, 4 do
      local itemInfo = awardcfg.itemList[k]
      local Img_BgIcon = Group_Icon:FindDirect(string.format("Img_BgIcon%d_%d", k, i))
      if Img_BgIcon then
        if itemInfo then
          local Texture_Icon = Img_BgIcon:FindDirect("Texture_Icon_" .. i):GetComponent("UITexture")
          local Label_Num = Img_BgIcon:FindDirect("Label_Num_" .. i)
          local itemBase = ItemUtils.GetItemBase(itemInfo.itemId)
          GUIUtils.FillIcon(Texture_Icon, itemBase.icon)
          Label_Num:GetComponent("UILabel"):set_text(itemInfo.num)
        else
          Img_BgIcon:SetActive(false)
        end
      end
    end
  end
  local pos = List_Prize.transform.localPosition
  local pos = List_Prize.transform.localPosition
  local maxSortid = #chargeCfgList - 3
  if maxSortid > chargeInfo.sortid then
  else
  end
end
def.method("number").getAward = function(self, index)
  if self.curTabName == "Tab_LimitRecharge" then
    local chargeInfo = customActivityInterface:getLimitChargeInfo()
    local chargeCfg = self.chargeCfgList[index]
    local saveAmt = self:getSaveAmt()
    if saveAmt >= chargeCfg.saveAmt then
      if index == chargeInfo.sortid + 1 then
        local itemData = require("Main.Item.ItemData").Instance()
        local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
        if itemData:IsFull(BagInfo.BAG) then
          Toast(textRes.customActivity[8])
          return
        end
        local req = require("netio.protocol.mzm.gsp.qingfu.CGetSaveAmtActivityAward").new(CustomActivityInterface.LIMIT_CHARGE_ACTIVITY_ID, index)
        gmodule.network.sendProtocol(req)
      else
        Toast(textRes.customActivity[5])
      end
    else
      local MallPanel = require("Main.Mall.ui.MallPanel")
      require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Pay, 0, 0)
    end
  elseif self.curTabName == "Tab_LimitCost" then
    local activityId = CustomActivityInterface.LIMIT_COST_ACTIVITY_ID
    local costInfo = customActivityInterface:getAccumTotalCostInfo(activityId)
    if index == costInfo.sortid + 1 then
      local itemData = require("Main.Item.ItemData").Instance()
      local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
      if itemData:IsFull(BagInfo.BAG) then
        Toast(textRes.customActivity[8])
        return
      end
      local req = require("netio.protocol.mzm.gsp.qingfu.CGetAccumTotalCostActivityAward").new(activityId, index)
      gmodule.network.sendProtocol(req)
    else
      Toast(textRes.customActivity[5])
    end
  end
end
def.method("number", "number", "userdata").showAwardItemTip = function(self, idx, itemIdx, go)
  local itemId
  local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  if self.curTabName == "Tab_LimitRecharge" then
    local cfg = self.chargeCfgList[idx]
    local key = string.format("%d_%d_%d", cfg.award_id, occupation.ALL, gender.ALL)
    local awardcfg = ItemUtils.GetGiftAwardCfg(key)
    itemId = awardcfg.itemList[itemIdx].itemId
  elseif self.curTabName == "Tab_LimitCost" then
    local cfg = self.accumCostList[idx]
    local key = string.format("%d_%d_%d", cfg.award_id, occupation.ALL, gender.ALL)
    local awardcfg = ItemUtils.GetGiftAwardCfg(key)
    itemId = awardcfg.itemList[itemIdx].itemId
  end
  if itemId then
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, go, 0, true)
  end
end
def.method().setAccumCostList = function(self)
  local activityId = CustomActivityInterface.LIMIT_COST_ACTIVITY_ID
  local accumCostCfgs = CustomActivityInterface.GetAccumTotalCostAwardCfgByActivityId(activityId)
  local accumCostCfgList = {}
  local totalCost = tonumber(ItemModule.Instance():GetYuanbao(ItemModule.CASH_TOTAL_COST):tostring())
  local bindCost = tonumber(ItemModule.Instance():GetYuanbao(ItemModule.CASH_TOTAL_COST_BIND):tostring())
  local costInfo = customActivityInterface:getAccumTotalCostInfo(activityId)
  local curCostNum = totalCost + bindCost - costInfo.base_accum_total_cost
  for _, v in pairs(accumCostCfgs) do
    if curCostNum >= v.display_accum_total_cost_cond then
      table.insert(accumCostCfgList, v)
    end
  end
  table.sort(accumCostCfgList, function(cfg1, cfg2)
    return cfg1.sortid < cfg2.sortid
  end)
  local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  local Label_Time = self.m_panel:FindDirect("Label_2/Label_Time")
  local Label_Tips = self.m_panel:FindDirect("Label_2/Label_Tips")
  Label_Time:GetComponent("UILabel"):set_text(activityCfg.timeDes)
  Label_Tips:GetComponent("UILabel"):set_text(activityCfg.activityDes)
  local Label_1 = self.m_panel:FindDirect("Label_1")
  Label_1:GetComponent("UILabel"):set_text(textRes.customActivity[2])
  local Label_Num = self.m_panel:FindDirect("Label_1/Label_Num")
  Label_Num:GetComponent("UILabel"):set_text(curCostNum)
  local ScrollView = self.m_panel:FindDirect("Group_GrowFund/Scroll View")
  local List_Prize = ScrollView:FindDirect("List_Prize")
  local uilist = List_Prize:GetComponent("UIList")
  uilist.itemCount = #accumCostCfgList
  uilist:Resize()
  local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  self.accumCostList = accumCostCfgList
  for i, v in ipairs(accumCostCfgList) do
    local Img_Bg = List_Prize:FindDirect(string.format("Img_Bg_%d", i))
    local Img_Get = Img_Bg:FindDirect("Img_Get_" .. i)
    local Btn_Get = Img_Bg:FindDirect("Btn_Get_" .. i)
    local Img_Red = Btn_Get:FindDirect("Img_Red_" .. i)
    local Label_titel = Img_Bg:FindDirect("Label_1_" .. i)
    local Label_2 = Img_Bg:FindDirect("Label_2_" .. i)
    local Label_Num = Img_Bg:FindDirect("Label_Num_" .. i)
    Label_titel:GetComponent("UILabel"):set_text(v.desc)
    Label_Num:GetComponent("UILabel"):set_text(curCostNum .. "/" .. v.accum_total_cost_cond)
    Label_2:GetComponent("UILabel"):set_text(textRes.customActivity[4])
    if v.sortid <= costInfo.sortid then
      Img_Get:SetActive(true)
      Btn_Get:SetActive(false)
    else
      Img_Get:SetActive(false)
      Btn_Get:SetActive(true)
      if curCostNum >= v.accum_total_cost_cond then
        Img_Red:SetActive(true)
        Btn_Get:GetComponent("UIButton").isEnabled = true
      else
        Img_Red:SetActive(false)
        Btn_Get:GetComponent("UIButton").isEnabled = false
      end
    end
    local key = string.format("%d_%d_%d", v.award_id, occupation.ALL, gender.ALL)
    local awardcfg = ItemUtils.GetGiftAwardCfg(key)
    local Group_Icon = Img_Bg:FindDirect("Group_Icon_" .. i)
    for k = 1, 4 do
      local itemInfo = awardcfg.itemList[k]
      local Img_BgIcon = Group_Icon:FindDirect(string.format("Img_BgIcon%d_%d", k, i))
      if itemInfo then
        local Texture_Icon = Img_BgIcon:FindDirect("Texture_Icon_" .. i):GetComponent("UITexture")
        local Label_Num = Img_BgIcon:FindDirect("Label_Num_" .. i)
        local itemBase = ItemUtils.GetItemBase(itemInfo.itemId)
        GUIUtils.FillIcon(Texture_Icon, itemBase.icon)
        Label_Num:GetComponent("UILabel"):set_text(itemInfo.num)
      else
        Img_BgIcon:SetActive(false)
      end
    end
  end
  local pos = List_Prize.transform.localPosition
  local maxSortid = #accumCostCfgList - 3
  if maxSortid > costInfo.sortid then
  else
  end
end
return ChargeAndCostPanel.Commit()
