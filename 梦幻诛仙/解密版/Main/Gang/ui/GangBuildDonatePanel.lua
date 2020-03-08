local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GangBuildDonatePanel = Lplus.Extend(ECPanelBase, "GangBuildDonatePanel")
local def = GangBuildDonatePanel.define
local instance
local GangUtility = require("Main.Gang.GangUtility")
local ItemModule = require("Main.Item.ItemModule")
local GangBuildingEnum = require("netio.protocol.mzm.gsp.gang.GangBuildingEnum")
local GangData = require("Main.Gang.data.GangData")
def.field("number").type = 0
def.field("table").donateList = nil
def.static("=>", GangBuildDonatePanel).Instance = function(self)
  if nil == instance then
    instance = GangBuildDonatePanel()
  end
  return instance
end
def.static("number").ShowDonateBuildPanel = function(type)
  GangBuildDonatePanel.Instance().type = type
  GangBuildDonatePanel.Instance():SetModal(true)
  GangBuildDonatePanel.Instance():CreatePanel(RESPATH.PREFAB_DONATE_GANG_PANEL, 0)
end
def.override().OnCreate = function(self)
  self:InitDonateInfo()
  self:UpdateInfo()
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartBuildGang, GangBuildDonatePanel.OnStartBuildGang)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartWingGang, GangBuildDonatePanel.OnStartWingGang)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartCoffersGang, GangBuildDonatePanel.OnStartCoffersGang)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartPharmacyGang, GangBuildDonatePanel.OnStartPharmacyGang)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartWarehouseGang, GangBuildDonatePanel.OnStartWarehouseGang)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, GangBuildDonatePanel.OnSilverMoneyChanged)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartBuildGang, GangBuildDonatePanel.OnStartBuildGang)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartWingGang, GangBuildDonatePanel.OnStartWingGang)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartCoffersGang, GangBuildDonatePanel.OnStartCoffersGang)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartPharmacyGang, GangBuildDonatePanel.OnStartPharmacyGang)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartWarehouseGang, GangBuildDonatePanel.OnStartWarehouseGang)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, GangBuildDonatePanel.OnSilverMoneyChanged)
end
def.static("table", "table").OnSilverMoneyChanged = function(self, params, context)
  local self = instance
  self:UpdateSilver()
end
def.method().InitDonateInfo = function(self)
  self.donateList = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_GANG_BUILD_DONATE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local donate = {}
    donate.id = DynamicRecord.GetIntValue(entry, "id")
    donate.donateSilver = DynamicRecord.GetIntValue(entry, "donateSilver")
    donate.redeemBangGong = DynamicRecord.GetIntValue(entry, "redeemBangGong")
    donate.removeLevelUpM = DynamicRecord.GetIntValue(entry, "removeLevelUpM")
    table.insert(self.donateList, donate)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method().UpdateInfo = function(self)
  self:UpdateProgress()
  self:UpdateBasic()
  self:UpdateSilver()
end
def.method().UpdateSilver = function(self)
  local Group_HaveMoney = self.m_panel:FindDirect("Img_Bg/Group_HaveMoney")
  local Label_HaveMoney = Group_HaveMoney:FindDirect("Label_HaveMoney"):GetComponent("UILabel")
  Label_HaveMoney:set_text(Int64.tostring(ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)))
end
def.method().UpdateProgress = function(self)
  local Group_Progress = self.m_panel:FindDirect("Img_Bg/Group_Progress")
  local gangInfo = GangData.Instance():GetGangBasicInfo()
  if self.type == GangBuildingEnum.XIANGFANG then
    if gangInfo.wingEndTime <= 0 then
      Group_Progress:SetActive(false)
    else
      Group_Progress:SetActive(true)
      local wingTbl = GangUtility.GetWingGangBasicCfg(gangInfo.wingLevel)
      self:FillProgress(gangInfo.wingEndTime, wingTbl.levelUpNeedTimeM * 60)
    end
  elseif self.type == GangBuildingEnum.JINKU then
    if 0 >= gangInfo.coffersEndTime then
      Group_Progress:SetActive(false)
    else
      Group_Progress:SetActive(true)
      local coffersTbl = GangUtility.GetCoffersGangBasicCfg(gangInfo.coffersLevel)
      self:FillProgress(gangInfo.coffersEndTime, coffersTbl.levelUpNeedTimeM * 60)
    end
  elseif self.type == GangBuildingEnum.YAODIAN then
    if 0 >= gangInfo.pharmacyEndTime then
      Group_Progress:SetActive(false)
    else
      Group_Progress:SetActive(true)
      local pharmacyTbl = GangUtility.GetPharmacyGangBasicCfg(gangInfo.pharmacyLevel)
      self:FillProgress(gangInfo.pharmacyEndTime, pharmacyTbl.levelUpNeedTimeM * 60)
    end
  elseif self.type == GangBuildingEnum.CANGKU then
    if 0 >= gangInfo.warehouseEndTime then
      Group_Progress:SetActive(false)
    else
      Group_Progress:SetActive(true)
      local warehouseTbl = GangUtility.GetWarehouseGangBasicCfg(gangInfo.warehouseLevel)
      self:FillProgress(gangInfo.warehouseEndTime, warehouseTbl.levelUpNeedTimeM * 60)
    end
  elseif self.type == GangBuildingEnum.GANG then
    if 0 >= gangInfo.buildEndTime then
      Group_Progress:SetActive(false)
    else
      Group_Progress:SetActive(true)
      local gangTbl = GangUtility.GetGangCfg(gangInfo.level)
      self:FillProgress(gangInfo.buildEndTime, gangTbl.levelUpNeedTimeM * 60)
    end
  elseif self.type == GangBuildingEnum.SHUYUAN then
    if 0 >= gangInfo.bookEndTime then
      Group_Progress:SetActive(false)
    else
      Group_Progress:SetActive(true)
      local gangTbl = GangUtility.GetBookGangBasicCfg(gangInfo.bookLevel)
      self:FillProgress(gangInfo.bookEndTime, gangTbl.levelUpNeedTimeM * 60)
    end
  end
end
def.method("number", "number").FillProgress = function(self, buildEndTime, time)
  local Group_Progress = self.m_panel:FindDirect("Img_Bg/Group_Progress")
  local remain = buildEndTime - GetServerTime()
  local rate1 = remain / time
  local timeStr = GangUtility.GetTimeStr(remain)
  local Img_Slide1 = Group_Progress:FindDirect("Img_Slide1")
  Img_Slide1:GetComponent("UISlider"):set_sliderValue(rate1)
  Img_Slide1:FindDirect("Label"):GetComponent("UILabel"):set_text(timeStr)
end
def.method().UpdateBasic = function(self)
  local Group_Progress = self.m_panel:FindDirect("Img_Bg/Group_Progress")
  local Label_Name = Group_Progress:FindDirect("Label"):GetComponent("UILabel")
  Label_Name:set_text(textRes.Gang.BuildType[self.type])
  local donateAmount = #self.donateList
  local List_Donate = self.m_panel:FindDirect("Img_Bg/Grid"):GetComponent("UIList")
  List_Donate:set_itemCount(donateAmount)
  List_Donate:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not List_Donate.isnil then
      List_Donate:Reposition()
    end
  end)
  local donates = List_Donate:get_children()
  for i = 1, donateAmount do
    local donateUI = donates[i]
    local donateInfo = self.donateList[i]
    self:FillDonateDetial(donateUI, i, donateInfo)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("userdata", "number", "table").FillDonateDetial = function(self, ui, index, donateInfo)
  local Img_BgNum1 = ui:FindDirect(string.format("Img_BgNum1_%d", index))
  local Label_Num1 = Img_BgNum1:FindDirect(string.format("Label_Num_%d", index)):GetComponent("UILabel")
  local Label_Time = ui:FindDirect(string.format("Label_Time_%d", index)):GetComponent("UILabel")
  local Label3 = ui:FindDirect(string.format("Label3_%d", index))
  local Label_Num3 = Label3:FindDirect(string.format("Label_Num_%d", index)):GetComponent("UILabel")
  Label_Num1:set_text(donateInfo.donateSilver)
  Label_Time:set_text(string.format(textRes.Gang[286], donateInfo.removeLevelUpM))
  Label_Num3:set_text(donateInfo.redeemBangGong)
end
def.method().Hide = function(self)
  self:DestroyPanel()
  self = nil
end
def.static("table", "table").OnStartBuildGang = function(params, tbl)
  if GangBuildDonatePanel.Instance().type == GangBuildingEnum.GANG then
    GangBuildDonatePanel.Instance():UpdateProgress()
  end
end
def.static("table", "table").OnStartWingGang = function(params, tbl)
  if GangBuildDonatePanel.Instance().type == GangBuildingEnum.XIANGFANG then
    GangBuildDonatePanel.Instance():UpdateProgress()
  end
end
def.static("table", "table").OnStartCoffersGang = function(params, tbl)
  if GangBuildDonatePanel.Instance().type == GangBuildingEnum.JINKU then
    GangBuildDonatePanel.Instance():UpdateProgress()
  end
end
def.static("table", "table").OnStartPharmacyGang = function(params, tbl)
  if GangBuildDonatePanel.Instance().type == GangBuildingEnum.YAODIAN then
    GangBuildDonatePanel.Instance():UpdateProgress()
  end
end
def.static("table", "table").OnStartWarehouseGang = function(params, tbl)
  if GangBuildDonatePanel.Instance().type == GangBuildingEnum.CANGKU then
    GangBuildDonatePanel.Instance():UpdateProgress()
  end
end
def.method("=>", "boolean").IsPanelShow = function(self)
  if self.m_panel then
    return self.m_panel:get_activeInHierarchy()
  else
    return false
  end
end
def.method().Update = function(self)
  self:UpdateProgress()
end
def.method("number").OnDonateClick = function(self, index)
  local donateInfo = self.donateList[index]
  local need = donateInfo.donateSilver
  local have = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
  if Int64.lt(have, need) then
    Toast(textRes.Gang[102])
  else
    local gangInfo = GangData.Instance():GetGangBasicInfo()
    if self.type == GangBuildingEnum.JINKU and gangInfo.coffersEndTime <= 0 then
      Toast(textRes.Gang[32])
      return
    elseif self.type == GangBuildingEnum.XIANGFANG and 0 >= gangInfo.wingEndTime then
      Toast(textRes.Gang[32])
      return
    elseif self.type == GangBuildingEnum.YAODIAN and 0 >= gangInfo.pharmacyEndTime then
      Toast(textRes.Gang[32])
      return
    elseif self.type == GangBuildingEnum.CANGKU and 0 >= gangInfo.warehouseEndTime then
      Toast(textRes.Gang[32])
      return
    elseif self.type == GangBuildingEnum.GANG and 0 >= gangInfo.buildEndTime then
      Toast(textRes.Gang[32])
      return
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CBuildingLevelUpDonateReq").new(self.type, donateInfo.id))
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_Close" == id then
    self:Hide()
  elseif "Modal" == id then
    self:Hide()
  elseif string.sub(id, 1, #"Btn_Donate1_") == "Btn_Donate1_" then
    local index = tonumber(string.sub(id, #"Btn_Donate1_" + 1, -1))
    self:OnDonateClick(index)
  end
end
return GangBuildDonatePanel.Commit()
