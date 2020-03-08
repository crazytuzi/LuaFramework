local Lplus = require("Lplus")
local ECGUIMan = require("GUI.ECGUIMan")
local Vector = require("Types.Vector")
local ECPanelBase = require("GUI.ECPanelBase")
local LingQiFengYinPanel = Lplus.Extend(ECPanelBase, "LingQiFengYinPanel")
local def = LingQiFengYinPanel.define
local instance
local ItemUtils = require("Main.Item.ItemUtils")
local itemData = require("Main.Item.ItemData").Instance()
local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
local GUIUtils = require("GUI.GUIUtils")
local TaskInterface = require("Main.task.TaskInterface")
local taskInterfaceInstance = TaskInterface.Instance()
local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
local TaskConClassType = require("consts.mzm.gsp.task.confbean.TaskConClassType")
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
local ItemModule = require("Main.Item.ItemModule")
local MAX_FENGYIN_COUNT = 10
local OPEN_FENGYIN_EFFECT = 702020089
def.field("table").lingQiFengYinCostCfgs = nil
def.field("boolean").isOnEffect = false
def.field("number").selectIndex = -1
def.field("userdata").effectOne = nil
def.static("=>", LingQiFengYinPanel).Instance = function()
  if not instance then
    instance = LingQiFengYinPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.m_TrigGC = true
end
def.method().InitCfgs = function(self)
  if not self.lingQiFengYinCostCfgs then
    self.lingQiFengYinCostCfgs = {}
    local entries = DynamicData.GetTable(CFG_PATH.DATA_LINGQIFENGYIN_CFG)
    local count = DynamicDataTable.GetRecordsCount(entries)
    DynamicDataTable.FastGetRecordBegin(entries)
    for i = 0, count - 1 do
      local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
      local _levelMin = DynamicRecord.GetIntValue(entry, "minLevel")
      local _levelMax = DynamicRecord.GetIntValue(entry, "maxLevel")
      local _itemType = DynamicRecord.GetIntValue(entry, "moneyType")
      local _costNum = DynamicRecord.GetIntValue(entry, "cost")
      table.insert(self.lingQiFengYinCostCfgs, {
        levelMin = _levelMin,
        levelMax = _levelMax,
        itemType = _itemType,
        costNum = _costNum
      })
    end
    DynamicDataTable.FastGetRecordEnd(entries)
  end
end
def.method().ShowDlg = function(self)
  if self:IsShow() == false then
    self:CreatePanel(RESPATH.PREFAB_UI_LINGQIFENGYIN, 1)
    self:SetModal(true)
  else
    self:Fill()
  end
end
def.method().HideDlg = function(self)
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  self.effectOne = self.m_panel:FindDirect("Img_Bg0/Group_Items/Effect_One")
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_LingQiFengYin_InfoChange, LingQiFengYinPanel.OnInfoChangeRef)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_LingQiFengYin_End, LingQiFengYinPanel.OnActivityEnd)
  self:InitCfgs()
  self:Fill()
end
def.override().OnDestroy = function(self)
  self.isOnEffect = false
  self.selectIndex = -1
  self.effectOne = nil
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_LingQiFengYin_InfoChange, LingQiFengYinPanel.OnInfoChangeRef)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_LingQiFengYin_End, LingQiFengYinPanel.OnActivityEnd)
end
def.method().SetLeftTime = function(self)
  if self:IsShow() then
    local label_time = self.m_panel:FindDirect("Img_Bg0/Label_CountDown/Label_Num"):GetComponent("UILabel")
    if label_time ~= nil then
      local timeStr = ""
      local nowSec = GetServerTime()
      local remainSec = math.max(0, activityInterface._lingqifengyinEndTime - nowSec)
      local day = math.floor(remainSec / 86400)
      local hour = math.floor(remainSec % 86400 / 3600)
      local min = math.floor(remainSec % 3600 / 60)
      local sec = math.floor(remainSec % 60)
      if day > 0 then
        timeStr = string.format(textRes.Title[41], day, hour)
      elseif hour > 0 then
        timeStr = string.format(textRes.Title[9], hour, min)
      elseif min > 0 then
        timeStr = string.format(textRes.Title[7], min, sec)
      else
        timeStr = string.format(textRes.Title[8], sec)
      end
      label_time:set_text(timeStr)
    end
  end
end
def.static("table", "table").OnActivityEnd = function(p1, p2)
  if instance and instance:IsShow() then
    instance:HideDlg()
  end
end
def.static("table", "table").OnInfoChangeRef = function(p1, p2)
  if instance and instance:IsShow() then
    instance:Fill()
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    self:Fill()
  end
end
def.method().ShowOneEffect = function(self)
  local item = self.m_panel:FindDirect(string.format("Img_Bg0/Group_Items/Img_Item%d", self.selectIndex))
  if item and self.effectOne then
    self.effectOne.localPosition = item.localPosition
    self.effectOne:SetActive(true)
    GameUtil.AddGlobalTimer(0.6, true, function()
      if self:IsShow() and self.effectOne then
        self.effectOne:SetActive(false)
      end
    end)
  end
end
def.method().Fill = function(self)
  for i = 1, MAX_FENGYIN_COUNT do
    self:FillOneItem(i)
  end
  if self.selectIndex ~= -1 and self.selectIndex == activityInterface._lingqifengyinOpenIndex then
    self:ShowOneEffect()
    self.selectIndex = -1
  end
  self:FillTips()
  self:UpdateBtnState()
  self:SetLeftTime()
end
def.method().FillTips = function(self)
  local label_tip = self.m_panel:FindDirect("Img_Bg0/Label"):GetComponent("UILabel")
  label_tip:set_text(textRes.activity.LingQiFengYinText[26])
end
def.method("number").FillOneItem = function(self, i)
  local groupItems = self.m_panel:FindDirect("Img_Bg0/Group_Items")
  local item = groupItems:FindDirect(string.format("Img_Item%d", i))
  local MassExpInfo = require("netio.protocol.mzm.gsp.massexp.MassExpInfo")
  if item then
    if i <= constant.LingQiFengYinConsts.LINGQIFENGYIN_MAX_GRID then
      item:SetActive(true)
      local label_name = item:FindDirect("Label_Name"):GetComponent("UILabel")
      local btn_Add = item:FindDirect("Btn_Add")
      local img_opened = item:FindDirect("Img_Opened")
      if i > activityInterface._lingqifengyinOpenIndex and activityInterface._lingqifengyinStatus == MassExpInfo.STATUS_ACCEPTED then
        btn_Add:SetActive(true)
      else
        btn_Add:SetActive(false)
      end
      if i <= activityInterface._lingqifengyinOpenIndex then
        img_opened:SetActive(true)
      else
        img_opened:SetActive(false)
      end
      label_name:set_text(string.format(textRes.activity.LingQiFengYinText[6], i))
    else
      item:SetActive(false)
    end
  end
end
def.method().UpdateBtnState = function(self)
  local MassExpInfo = require("netio.protocol.mzm.gsp.massexp.MassExpInfo")
  local isCanOpenFengyin = activityInterface._lingqifengyinStatus == MassExpInfo.STATUS_ACCEPTED and activityInterface._lingqifengyinOpenIndex > 0
  local Btn_Get = self.m_panel:FindDirect("Img_Bg0/Btn_Get")
  if isCanOpenFengyin then
    GUIUtils.SetLightEffect(Btn_Get, GUIUtils.Light.Square)
  else
    GUIUtils.SetLightEffect(Btn_Get, GUIUtils.Light.None)
  end
end
def.method("number", "=>", "table").GetCostConfigByLv = function(self, _lv)
  if self.lingQiFengYinCostCfgs then
    for _, v in ipairs(self.lingQiFengYinCostCfgs) do
      if _lv >= v.levelMin and _lv <= v.levelMax then
        return v
      end
    end
  end
  return 0
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:HideDlg()
    return
  end
  if self.isOnEffect then
    return
  end
  if id == "Btn_Get" then
    self:OnOpenFengYin()
    return
  end
  if id == "Btn_Add" then
    local index = tonumber(obj.parent.name:sub(9, -1))
    warn("Fill LingXue" .. index)
    if index ~= -1 then
      LingQiFengYinPanel.OnIconClick(self, index)
    end
  end
end
def.method().OnOpenFengYin = function(self)
  local _index = activityInterface._lingqifengyinOpenIndex
  local MassExpInfo = require("netio.protocol.mzm.gsp.massexp.MassExpInfo")
  if activityInterface._lingqifengyinStatus == MassExpInfo.STATUS_INIT then
    Toast(textRes.activity.LingQiFengYinText[19])
    return
  elseif activityInterface._lingqifengyinStatus == MassExpInfo.STATUS_ACCEPTED and _index <= 0 then
    Toast(textRes.activity.LingQiFengYinText[20])
    return
  elseif activityInterface._lingqifengyinStatus == MassExpInfo.STATUS_END then
    Toast(textRes.activity.LingQiFengYinText[21])
    return
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm("", string.format(textRes.activity.LingQiFengYinText[5], _index, _index), LingQiFengYinPanel.SendOpenFengYinCallback, nil)
end
def.static("number", "table").SendOpenFengYinCallback = function(i, tag)
  if i == 1 then
    local effectPath
    effectPath = GetEffectRes(OPEN_FENGYIN_EFFECT)
    warn(effectPath.path)
    local fxName = "Openeffect"
    local GUIFxMan = require("Fx.GUIFxMan")
    GUIFxMan.Instance():Play(effectPath.path, fxName, 0, 0, 4, true)
    instance.isOnEffect = true
    if not effectPath or not effectPath.path or effectPath.path == "" then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.massexp.CGetAward").new())
    else
      instance:Fill()
      GameUtil.AddGlobalTimer(4, true, function()
        if instance:IsShow() then
          gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.massexp.CGetAward").new())
        end
      end)
    end
  end
end
def.method("number").OnIconClick = function(self, _index)
  if _index <= activityInterface._lingqifengyinOpenIndex then
    Toast(textRes.activity.LingQiFengYinText[10])
    return
  elseif _index > activityInterface._lingqifengyinOpenIndex + 1 then
    warn("Fill lingxue:" .. _index .. "," .. activityInterface._lingqifengyinOpenIndex)
    Toast(textRes.activity.LingQiFengYinText[25])
    return
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local tmpCostCfg = self:GetCostConfigByLv(heroProp.level)
  local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  if tmpCostCfg.itemType == MoneyType.GOLD then
    local gold = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
    if Int64.lt(gold, tmpCostCfg.costNum) then
      CommonConfirmDlg.ShowConfirm("", textRes.activity.LingQiFengYinText[1], LingQiFengYinPanel.BuyGoldCallback, nil)
      return
    end
  elseif tmpCostCfg.itemType == MoneyType.SILVER then
    local silver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
    if Int64.lt(silver, tmpCostCfg.costNum) then
      CommonConfirmDlg.ShowConfirm("", textRes.activity.LingQiFengYinText[2], LingQiFengYinPanel.BuySilverCallback, nil)
      return
    end
  end
  local _text = ""
  if tmpCostCfg.itemType == MoneyType.GOLD then
    _text = string.format(textRes.activity.LingQiFengYinText[3], tostring(tmpCostCfg.costNum))
  elseif tmpCostCfg.itemType == MoneyType.SILVER then
    _text = string.format(textRes.activity.LingQiFengYinText[4], tostring(tmpCostCfg.costNum))
  end
  CommonConfirmDlg.ShowConfirm("", _text, LingQiFengYinPanel.SendFillCallback, {index = _index})
end
def.static("number", "table").SendFillCallback = function(i, tag)
  if i == 1 then
    local _index = tag.index
    instance.selectIndex = _index
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.massexp.CFillGrid").new(_index))
  end
end
def.static("number", "table").BuyGoldCallback = function(i, tag)
  if i == 1 then
    GoToBuyGold(false)
  end
end
def.static("number", "table").BuySilverCallback = function(i, tag)
  if 1 == i then
    GoToBuySilver(false)
  end
end
LingQiFengYinPanel.Commit()
return LingQiFengYinPanel
