local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GangMifangMakeDrugPanel = Lplus.Extend(ECPanelBase, "GangMifangMakeDrugPanel")
local def = GangMifangMakeDrugPanel.define
local instance
local GangUtility = require("Main.Gang.GangUtility")
local GangData = require("Main.Gang.data.GangData")
local ItemModule = require("Main.Item.ItemModule")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local LivingSkillData = require("Main.Skill.data.LivingSkillData")
local LivingSkillUtility = require("Main.Skill.LivingSkillUtility")
def.static("=>", GangMifangMakeDrugPanel).Instance = function(self)
  if nil == instance then
    instance = GangMifangMakeDrugPanel()
  end
  return instance
end
def.static().ShowGangDrugPanel = function()
  GangMifangMakeDrugPanel.Instance():SetModal(true)
  GangMifangMakeDrugPanel.Instance():CreatePanel(RESPATH.PREFAB_GANG_MAKE_DRUG_PANEL, 0)
end
def.override().OnCreate = function(self)
  self:UpdateInfo()
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_CHANGED, GangMifangMakeDrugPanel.OnEnergyChanged)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_SucceedUseMifang, GangMifangMakeDrugPanel.OnSucceedUseMifang)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_CloseMifang, GangMifangMakeDrugPanel.OnCloseMifang)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MifangTimesChanged, GangMifangMakeDrugPanel.OnMifangTimesChanged)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, GangMifangMakeDrugPanel.OnBagInfoSyncronized)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_CHANGED, GangMifangMakeDrugPanel.OnEnergyChanged)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_SucceedUseMifang, GangMifangMakeDrugPanel.OnSucceedUseMifang)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_CloseMifang, GangMifangMakeDrugPanel.OnCloseMifang)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MifangTimesChanged, GangMifangMakeDrugPanel.OnMifangTimesChanged)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, GangMifangMakeDrugPanel.OnBagInfoSyncronized)
end
def.static("table", "table").OnEnergyChanged = function(params, context)
  GangMifangMakeDrugPanel.Instance():UpdateEnergy()
end
def.static("table", "table").OnSucceedUseMifang = function(params, context)
  GangMifangMakeDrugPanel.Instance():UpdateSucceedIcon(params[1])
end
def.static("table", "table").OnCloseMifang = function(params, context)
  Toast(textRes.Gang[124])
  GangMifangMakeDrugPanel.Instance():Hide()
end
def.static("table", "table").OnMifangTimesChanged = function(params, context)
  GangMifangMakeDrugPanel.Instance():UpdateMakeTimes()
end
def.static("table", "table").OnBagInfoSyncronized = function(params, context)
  GangMifangMakeDrugPanel.Instance():UpdateNeedItemNum()
end
def.method().UpdateInfo = function(self)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Label_Name = Img_Bg0:FindDirect("Group_Preview/Label_Name"):GetComponent("UILabel")
  local cfgId = GangData.Instance():GetMifangCfgId()
  local mifangInfo = GangUtility.GetMifangInfo(cfgId)
  Label_Name:set_text(mifangInfo.miFangName)
  local itemList = GangData.Instance():GetMifangNeedItemList()
  local Group_Creat = Img_Bg0:FindDirect("Group_Creat")
  local itemBase1 = ItemUtils.GetItemBase(itemList[1])
  local Img_Item1 = Group_Creat:FindDirect("Img_Item1")
  local Icon_Item1 = Img_Item1:FindDirect("Icon_Item"):GetComponent("UITexture")
  local Label_Item1 = Img_Item1:FindDirect("Label_Item"):GetComponent("UILabel")
  GUIUtils.FillIcon(Icon_Item1, itemBase1.icon)
  Label_Item1:set_text(itemBase1.name)
  local itemBase2 = ItemUtils.GetItemBase(itemList[2])
  local Img_Item2 = Group_Creat:FindDirect("Img_Item2")
  local Icon_Item2 = Img_Item2:FindDirect("Icon_Item"):GetComponent("UITexture")
  local Label_Item2 = Img_Item2:FindDirect("Label_Item"):GetComponent("UILabel")
  GUIUtils.FillIcon(Icon_Item2, itemBase2.icon)
  Label_Item2:set_text(itemBase2.name)
  local itemBase3 = ItemUtils.GetItemBase(itemList[3])
  local Img_Item3 = Group_Creat:FindDirect("Img_Item3")
  local Icon_Item3 = Img_Item3:FindDirect("Icon_Item"):GetComponent("UITexture")
  local Label_Item3 = Img_Item3:FindDirect("Label_Item"):GetComponent("UILabel")
  GUIUtils.FillIcon(Icon_Item3, itemBase3.icon)
  Label_Item3:set_text(itemBase3.name)
  local itemBase4 = ItemUtils.GetItemBase(itemList[4])
  local Img_Item4 = Group_Creat:FindDirect("Img_Item4")
  local Icon_Item4 = Img_Item4:FindDirect("Icon_Item"):GetComponent("UITexture")
  local Label_Item4 = Img_Item4:FindDirect("Label_Item"):GetComponent("UILabel")
  GUIUtils.FillIcon(Icon_Item4, itemBase4.icon)
  Label_Item4:set_text(itemBase4.name)
  self:UpdateNeedItemNum()
  self:UpdateMakeTimes()
  self:UpdateRemainTime()
  self:UpdateEnergy()
end
def.method().UpdateNeedItemNum = function(self)
  local itemList = GangData.Instance():GetMifangNeedItemList()
  if not itemList or #itemList ~= 4 then
    return
  end
  local itemNumInbag = {}
  for i = 1, #itemList do
    local num = ItemModule.Instance():GetItemCountById(itemList[i])
    itemNumInbag[itemList[i]] = num
  end
  local Group_Creat = self.m_panel:FindDirect("Img_Bg0/Group_Creat")
  local MathHelper = require("Common.MathHelper")
  local num1 = itemNumInbag[itemList[1]]
  itemNumInbag[itemList[1]] = itemNumInbag[itemList[1]] - 1
  num1 = MathHelper.Clamp(num1, 0, 1)
  local Img_Item1 = Group_Creat:FindDirect("Img_Item1")
  local Label_Num1 = Img_Item1:FindDirect("Label_Num"):GetComponent("UILabel")
  Label_Num1:set_text(string.format("%d/%d", num1, 1))
  local textColor = Color.white
  if num1 < 1 then
    textColor = Color.red
  end
  Label_Num1:set_textColor(textColor)
  local num2 = itemNumInbag[itemList[2]]
  itemNumInbag[itemList[2]] = itemNumInbag[itemList[2]] - 1
  num2 = MathHelper.Clamp(num2, 0, 1)
  local Img_Item2 = Group_Creat:FindDirect("Img_Item2")
  local Label_Num2 = Img_Item2:FindDirect("Label_Num"):GetComponent("UILabel")
  Label_Num2:set_text(string.format("%d/%d", num2, 1))
  textColor = Color.white
  if num2 < 1 then
    textColor = Color.red
  end
  Label_Num2:set_textColor(textColor)
  local num3 = itemNumInbag[itemList[3]]
  itemNumInbag[itemList[3]] = itemNumInbag[itemList[3]] - 1
  num3 = MathHelper.Clamp(num3, 0, 1)
  local Img_Item3 = Group_Creat:FindDirect("Img_Item3")
  local Label_Num3 = Img_Item3:FindDirect("Label_Num"):GetComponent("UILabel")
  Label_Num3:set_text(string.format("%d/%d", num3, 1))
  textColor = Color.white
  if num3 < 1 then
    textColor = Color.red
  end
  Label_Num3:set_textColor(textColor)
  local num4 = itemNumInbag[itemList[4]]
  itemNumInbag[itemList[4]] = itemNumInbag[itemList[4]] - 1
  num4 = MathHelper.Clamp(num4, 0, 1)
  local Img_Item4 = Group_Creat:FindDirect("Img_Item4")
  local Label_Num4 = Img_Item4:FindDirect("Label_Num"):GetComponent("UILabel")
  Label_Num4:set_text(string.format("%d/%d", num4, 1))
  textColor = Color.white
  if num4 < 1 then
    textColor = Color.red
  end
  Label_Num4:set_textColor(textColor)
end
def.method().UpdateMakeTimes = function(self)
  local useTimes = GangData.Instance():GetMifangUseCount()
  local totalTimes = GangData.Instance():GetMifangTotalCount()
  local Group_Creat = self.m_panel:FindDirect("Img_Bg0/Group_Creat")
  local Label_Num = Group_Creat:FindDirect("Group_Times/Label_Num"):GetComponent("UILabel")
  Label_Num:set_text(string.format("%d/%d", useTimes, totalTimes))
end
def.method().UpdateRemainTime = function(self)
  local time = GangData.Instance():GetMifangEndTime() - GetServerTime()
  local minute = time / 60
  minute = math.ceil(Int64.ToNumber(minute))
  local Label_Time = self.m_panel:FindDirect("Label_Time"):GetComponent("UILabel")
  Label_Time:set_text(string.format(textRes.Gang[354], minute))
end
def.method().UpdateEnergy = function(self)
  local skillBagId = constant.GangMiFangConsts.GANGMIFANG_LIAYO_SKILL_BAG_ID
  local skillBag = LivingSkillData.Instance():GetSkillBagById(skillBagId)
  local costVigor = LivingSkillUtility.GetCostVigor(skillBagId, skillBag.level)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local Label_Num = self.m_panel:FindDirect("Label_Huoli/Label_Num"):GetComponent("UILabel")
  Label_Num:set_text(string.format("%d/%d", costVigor, heroProp.energy))
end
def.method("number").UpdateSucceedIcon = function(self, itemId)
  local itemBase = ItemUtils.GetItemBase(itemId)
  local Group_Creat = self.m_panel:FindDirect("Img_Bg0/Group_Creat")
  local Img_Item5 = Group_Creat:FindDirect("Img_Item5")
  local Icon_Item5 = Img_Item5:FindDirect("Icon_ItemCreatC"):GetComponent("UITexture")
  GUIUtils.FillIcon(Icon_Item5, itemBase.icon)
end
def.method().Hide = function(self)
  self:DestroyPanel()
  self = nil
end
def.method().OnMakeDrugClick = function(self)
  local skillBagId = constant.GangMiFangConsts.GANGMIFANG_LIAYO_SKILL_BAG_ID
  local skillBag = LivingSkillData.Instance():GetSkillBagById(skillBagId)
  local mifangCfgId = GangData.Instance():GetMifangCfgId()
  local mifangInfo = GangUtility.GetMifangInfo(mifangCfgId)
  local drugId = mifangInfo.generLifeSkillId
  local drugCfg = LivingSkillData.GetSkillBagInfo(drugId)
  local needSkillBagLevel = drugCfg.openLevel
  if needSkillBagLevel > skillBag.level then
    Toast(string.format(textRes.Skill[73], needSkillBagLevel))
    return
  end
  local costVigor = LivingSkillUtility.GetCostVigor(skillBagId, skillBag.level)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if costVigor > heroProp.energy then
    Toast(textRes.Gang[120])
    return
  end
  local itemList = GangData.Instance():GetMifangNeedItemList()
  for k, v in pairs(itemList) do
    local have = ItemModule.Instance():GetItemCountById(v)
    if have < 1 then
      Toast(textRes.Gang[121])
      return
    end
  end
  local data = GangData.Instance()
  local useTimes = data:GetMifangUseCount()
  local totalTimes = data:GetMifangTotalCount()
  if useTimes == totalTimes then
    Toast(textRes.Gang[129])
    return
  end
  local endTime = data:GetMifangEndTime()
  if endTime == nil then
    Toast(textRes.Gang[124])
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CUseMiFangReq").new())
end
def.method().OnTipsClick = function(self)
  local tipsId = constant.GangMiFangConsts.GANGMIFANG_MIFANG_TIPS
  local GUIUtils = require("GUI.GUIUtils")
  GUIUtils.ShowHoverTip(tipsId, 0, 0)
end
def.method("=>", "boolean").IsPanelShow = function(self)
  if self.m_panel then
    return self.m_panel:get_activeInHierarchy()
  else
    return false
  end
end
def.method().Update = function(self)
  self:UpdateRemainTime()
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_Close" == id then
    self:Hide()
  elseif "Modal" == id then
    self:Hide()
  elseif "Btn_Creat" == id then
    self:OnMakeDrugClick()
  elseif "Btn_Tips" == id then
    self:OnTipsClick()
  elseif string.sub(id, 1, #"Img_Item") == "Img_Item" then
    local index = tonumber(string.sub(id, #"Img_Item" + 1, -1))
    if index >= 1 and index <= 4 then
      local position = clickobj:get_position()
      local screenPos = WorldPosToScreen(position.x, position.y)
      local sprite = clickobj:GetComponent("UISprite")
      local itemList = GangData.Instance():GetMifangNeedItemList()
      local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
      ItemTipsMgr.Instance():ShowBasicTips(itemList[index], screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, true)
    end
  end
end
return GangMifangMakeDrugPanel.Commit()
