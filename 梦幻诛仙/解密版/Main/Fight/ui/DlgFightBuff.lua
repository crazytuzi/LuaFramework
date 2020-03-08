local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgFightBuff = Lplus.Extend(ECPanelBase, "DlgFightBuff")
local GameUnitType = require("consts/mzm/gsp/common/confbean/GameUnitType")
local GUIUtils = require("GUI.GUIUtils")
local CmdType = require("consts.mzm.gsp.fight.confbean.CommandType")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
local def = DlgFightBuff.define
local dlg
def.field("number").unitId = 0
def.field("table").buffs = nil
def.field("boolean").showCmd = false
def.field("table").fightMgr = nil
def.static("=>", DlgFightBuff).Instance = function()
  if dlg == nil then
    dlg = DlgFightBuff()
  end
  return dlg
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, DlgFightBuff.OnCloseSecondLevelUI)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.UPDATE_COMMAND, DlgFightBuff.UpdateCommand)
end
def.method("number", "table").ShowDlg = function(self, unitId, fightMgr)
  self.unitId = unitId
  self.fightMgr = fightMgr
  if self:IsShow() then
    self:ShowBuffs()
    return
  end
  self:CreatePanel(RESPATH.DLG_FIGHT_BUFF, 0)
  self:SetOutTouchDisappear()
end
def.override().OnDestroy = function(self)
  self.unitId = 0
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, DlgFightBuff.OnCloseSecondLevelUI)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.UPDATE_COMMAND, DlgFightBuff.UpdateCommand)
end
def.static("table", "table").OnCloseSecondLevelUI = function()
  dlg:Hide()
end
def.static("table", "table").UpdateCommand = function()
  dlg:ShowCommands()
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:ShowBuffs()
  local teamData = require("Main.Team.TeamData").Instance()
  self.showCmd = not self.fightMgr:IsObserverMode()
  self.m_panel:FindDirect("Img_Bg0/Group_Bottom/Btn_ZhiHui"):SetActive(self.showCmd)
  self.m_panel:FindDirect("Img_Bg0/Group_Bottom/Btn_Setting"):SetActive(self.showCmd)
  self.m_panel:FindDirect("Group_ZhiHui"):SetActive(self.showCmd)
  self:ShowCommands()
end
def.method().Hide = function(self)
  self:DestroyPanel()
  self.unitId = 0
  self.buffs = nil
end
def.method("string").onClick = function(self, id)
  if id == "Btn_ZhiHui" then
    local cmdPanel = self.m_panel:FindDirect("Group_ZhiHui")
    self.showCmd = not self.showCmd
    cmdPanel:SetActive(self.showCmd)
    if cmdPanel.activeSelf then
      self:ShowCommands()
    end
  elseif id == "Btn_Setting" then
    require("Main.Fight.ui.DlgSetCommand").Instance():ShowDlg()
  elseif string.find(id, "Btn_ZhiHui") then
    local idx = tonumber(string.sub(id, string.len("Btn_ZhiHui") + 1))
    self:DoCommand(idx)
  elseif id == "Btn_Clean" then
    self:DoCommand(-1)
  end
end
def.method().ShowBuffs = function(self)
  local unit = self.fightMgr:GetFightUnit(self.unitId)
  if unit == nil then
    warn("[DlgFightBuff]unit is nil")
    return
  end
  self.m_panel:FindDirect("Img_BgName/Label_Name"):GetComponent("UILabel").text = unit.name
  self.m_panel:FindDirect("Img_BgName/Label_Lv"):GetComponent("UILabel").text = tostring(unit.level)
  self.m_panel:FindDirect("Label_Type"):GetComponent("UILabel").text = textRes.Common[100 + unit.fightUnitType]
  local hpgroup = self.m_panel:FindDirect("Img_BgName/Group_MPHP")
  local showHpInfo = unit.fightUnitType == GameUnitType.FELLOW and unit.team == self.fightMgr.myTeam or self.fightMgr:IsMyUnit(unit.id)
  hpgroup:SetActive(showHpInfo)
  if showHpInfo then
    hpgroup:FindDirect("Label_MP"):GetComponent("UILabel").text = unit.hp .. "/" .. unit.hpmax
    hpgroup:FindDirect("Label_HP"):GetComponent("UILabel").text = unit.mp .. "/" .. unit.mpmax
  end
  local formationInfo = self.fightMgr.teams[unit.team].formationInfo
  local formationPanel = self.m_panel:FindDirect("Img_Bg0/Group_Bottom/Group_ZhenFaOn")
  local formationEnable = unit.pos >= 6 and unit.pos <= 10
  formationPanel:SetActive(formationInfo ~= nil and formationEnable)
  local FIGHT_TYPE = require("netio.protocol.mzm.gsp.fight.Fight")
  local label_off = formationInfo == nil and self.fightMgr.fightType ~= FIGHT_TYPE.TYPE_PETCVC
  self.m_panel:FindDirect("Img_Bg0/Group_Bottom/Label_ZhenFaOff"):SetActive(label_off)
  if formationInfo and formationEnable then
    formationPanel:FindDirect("Label1"):GetComponent("UILabel").text = formationInfo.name
    local power = 8 - unit.pos
    local flag = 0
    if power < 0 then
      power = math.abs(power)
      flag = 1
    end
    local formationPos = math.pow(2, power) + flag
    formationPanel:FindDirect("Label2"):GetComponent("UILabel").text = tostring(formationPos)
    local eff = formationInfo.Effect[formationPos]
    formationPanel:FindDirect("Label4"):GetComponent("UILabel").text = eff and eff.desc or ""
  end
  if 0 < unit.attr_class then
    local classTypeCfg = TurnedCardUtils.GetCardClassCfg(unit.attr_class)
    self.m_panel:FindDirect("Img_BgName/Label_Class"):GetComponent("UILabel").text = classTypeCfg.className
  else
    self.m_panel:FindDirect("Img_BgName/Label_Class"):GetComponent("UILabel").text = ""
  end
  local menpaiIcon = self.m_panel:FindDirect("Img_BgName/Img_School")
  if 0 <= unit.menpai then
    menpaiIcon:GetComponent("UISprite").spriteName = GUIUtils.GetOccupationSmallIcon(unit.menpai)
    menpaiIcon:SetActive(true)
  elseif unit.fightUnitType == GameUnitType.PET then
    menpaiIcon:GetComponent("UISprite").spriteName = "Img_SkillCH1"
    menpaiIcon:SetActive(true)
  else
    menpaiIcon:SetActive(false)
  end
  local FightUtils = require("Main.Fight.FightUtils")
  local me = self.fightMgr:GetMyHero()
  local Img_ShapeShift = self.m_panel:FindDirect("Img_Bg0/Scroll View_Buff/Img_ShapeShift")
  local listPanel = self.m_panel:FindDirect("Img_Bg0/Scroll View_Buff/List_Buff")
  local isOpen = _G.IsFeatureOpen(Feature.TYPE_CLASS_RESTRICTION)
  local shapeShiftCardInfo
  local heroProp = require("Main.Hero.Interface"):GetBasicHeroProp()
  if heroProp.level >= constant.CChangeModelCardConsts.OPEN_LEVEL then
    shapeShiftCardInfo = unit:GetShapeShiftCardInfo()
  end
  if shapeShiftCardInfo and 0 < shapeShiftCardInfo.cardId then
    local change_cfg = TurnedCardUtils.GetChangeModelCardCfg(shapeShiftCardInfo.cardId)
    local shape_icon = Img_ShapeShift:FindDirect("Img_BgIcon01/Img_Icon01")
    GUIUtils.FillIcon(shape_icon:GetComponent("UITexture"), change_cfg.iconId)
    local class_name = Img_ShapeShift:FindDirect("Img_BgTitle01/Label_Title01")
    class_name:GetComponent("UILabel").text = change_cfg.cardName
    local classTypeCfg = TurnedCardUtils.GetCardClassCfg(change_cfg.classType)
    local class_desc
    if isOpen and me then
      local overcome_desc = FightUtils.GetOvercomeDesc(me, unit)
      class_desc = string.format("%s(%s)", classTypeCfg.className, overcome_desc)
    end
    Img_ShapeShift:FindDirect("Label_State"):GetComponent("UILabel").text = class_desc or classTypeCfg.className
    local prop_desc = ""
    local card_level_cfg = TurnedCardUtils.GetCardLevelCfg(shapeShiftCardInfo.cardId)
    local level_info = card_level_cfg.cardLevels[shapeShiftCardInfo.level]
    for _, prop in pairs(level_info.propertys) do
      local propertyCfg = _G.GetCommonPropNameCfg(prop.propType)
      if propertyCfg then
        prop_desc = prop_desc .. propertyCfg.propName
        prop_desc = string.format("%s+%d ", prop_desc, prop.value)
      end
    end
    Img_ShapeShift:FindDirect("Label_Att"):GetComponent("UILabel").text = prop_desc
  else
    Img_ShapeShift:SetActive(false)
    local pos = listPanel.localPosition
    pos.y = 154
    listPanel.localPosition = pos
  end
  local uiList = listPanel:GetComponent("UIList")
  if unit.status == nil or unit.status.buffs == nil then
    uiList.itemCount = 0
    uiList:Resize()
    return
  end
  self.buffs = {}
  for k, v in pairs(unit.status.buffs) do
    local buff = v
    if 0 < buff.buffid then
      local buffEffectCfg = FightUtils.GetEffectGroupCfg(buff.buffid)
      if buffEffectCfg and 0 < buffEffectCfg.buffEffectId then
        local buffCfg = FightUtils.GetEffectStatusCfg(buffEffectCfg.buffEffectId)
        buffCfg.round = buff.round
        buffCfg.typeName = self:GetTypeName(buffEffectCfg.effectgrouptype)
        if buffCfg.isShow then
          table.insert(self.buffs, buffCfg)
        end
      end
    end
  end
  uiList.itemCount = #self.buffs
  uiList:Resize()
  for i = 1, #self.buffs do
    local buffPanel = listPanel:FindDirect("Img_BgBuff01_" .. i)
    local icon_ui = buffPanel:FindDirect("Img_BgIcon01_" .. i .. "/Img_Icon01_" .. i):GetComponent("UITexture")
    GUIUtils.FillIcon(icon_ui, self.buffs[i].icon)
    buffPanel:FindDirect("Label_Discribe_" .. i):GetComponent("UILabel").text = self.buffs[i].desc
    buffPanel:FindDirect("Label_TimeNum_" .. i):GetComponent("UILabel").text = tostring(self.buffs[i].round)
    buffPanel:FindDirect("Img_BgTitle01_" .. i .. "/Label_Title01_" .. i):GetComponent("UILabel").text = self.buffs[i].name
    buffPanel:FindDirect("Img_BgTitle01_" .. i .. "/Label_Title02_" .. i):GetComponent("UILabel").text = self.buffs[i].typeName
  end
end
def.method("number", "=>", "string").GetTypeName = function(self, t)
  local EffectStatusType = require("consts.mzm.gsp.skill.confbean.EffectStatusType")
  if t == EffectStatusType.NEGATIVE then
    return textRes.Buff[101]
  elseif t == EffectStatusType.POSITIVE then
    return textRes.Buff[100]
  elseif t == EffectStatusType.SEAL then
    return textRes.Buff[102]
  elseif t == EffectStatusType.POISON then
    return textRes.Buff[103]
  else
    return ""
  end
end
def.method().ShowCommands = function(self)
  if self.m_panel == nil or not self.showCmd then
    return
  end
  local unit = self.fightMgr:GetFightUnit(self.unitId)
  if unit == nil or unit.fightUnitType == 0 then
    Debug.LogWarning(string.format("unit(%s) is nil or fightUnitType undefined ", tostring(unit and unit.name)))
    self:Hide()
    return
  end
  local me = self.fightMgr:GetMyHero()
  if me == nil then
    return
  end
  local cmdType
  if unit.team == me.team then
    cmdType = CmdType.FRIEND
  else
    cmdType = CmdType.ENERMY
  end
  if self.fightMgr.commandItems == nil then
    return
  end
  local commandItems = self.fightMgr.commandItems[cmdType]
  if commandItems == nil then
    return
  end
  local btn
  local cmdNum = #commandItems
  for i = 1, 6 do
    btn = self.m_panel:FindDirect("Group_ZhiHui/Grid/Btn_ZhiHui" .. i)
    if btn then
      if i <= cmdNum then
        btn:FindDirect("Label"):GetComponent("UILabel").text = commandItems[i].name
      else
        btn:FindDirect("Label"):GetComponent("UILabel").text = textRes.Fight[42]
      end
    end
  end
end
def.method("number").DoCommand = function(self, idx)
  local unit = self.fightMgr:GetFightUnit(self.unitId)
  if unit == nil or unit.fightUnitType == 0 then
    return
  end
  local me = self.fightMgr:GetMyHero()
  if me == nil then
    return
  end
  if idx < 0 then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.fight.CRemCommandReq").new(unit.id))
    return
  end
  local cmdType
  if unit.team == me.team then
    cmdType = CmdType.FRIEND
  else
    cmdType = CmdType.ENERMY
  end
  local commandItems = self.fightMgr.commandItems[cmdType]
  local cmd = commandItems[idx]
  if cmd == nil then
    require("Main.Fight.ui.DlgSetCommand").Instance():ShowDlg()
  else
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.fight.CCommandReq").new(cmdType, cmd.name, unit.id))
    require("Main.Fight.ui.DlgFight").Instance():GoBack()
  end
  self:Hide()
end
DlgFightBuff.Commit()
return DlgFightBuff
