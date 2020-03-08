local Lplus = require("Lplus")
local MountsPanelNodeBase = require("Main.Mounts.ui.MountsPanelNodeBase")
local ECPanelBase = require("GUI.ECPanelBase")
local BattleNode = Lplus.Extend(MountsPanelNodeBase, "BattleNode")
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local Vector3 = require("Types.Vector3").Vector3
local MountsUtils = require("Main.Mounts.MountsUtils")
local MountsMgr = require("Main.Mounts.mgr.MountsMgr")
local MountsUIModel = require("Main.Mounts.MountsUIModel")
local MountsConst = require("netio.protocol.mzm.gsp.mounts.MountsConst")
local MountsTypeEnum = require("consts.mzm.gsp.mounts.confbean.MountsTypeEnum")
local def = BattleNode.define
def.const("table").ModelScale = {
  0.9,
  0.8,
  0.8,
  1,
  1
}
def.field("table").uiObjs = nil
def.field("table").uiModels = nil
def.field("number").clickCellId = 0
def.field("table").preBattleMountsMap = nil
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  MountsPanelNodeBase.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:InitUI()
  self:SetBattleMounts()
  Event.RegisterEventWithContext(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsBattleStatusChange, BattleNode.OnMountsBattleStatusChange, self)
end
def.override().OnHide = function(self)
  self:Clear()
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsBattleStatusChange, BattleNode.OnMountsBattleStatusChange)
end
def.method().Clear = function(self)
  self.uiObjs = nil
  if self.uiModels ~= nil then
    for cell, model in pairs(self.uiModels) do
      model:Destroy()
    end
    self.uiModels = nil
  end
  self.clickCellId = 0
  self.preBattleMountsMap = nil
end
def.method().InitUI = function(self)
  if not self.m_node or self.m_node.isnil then
    return
  end
  self.uiModels = {}
  self.uiObjs = {}
  self.uiObjs.Group_SetRiding = self.m_node:FindDirect("Group_SetRiding")
  GUIUtils.SetActive(self.uiObjs.Group_SetRiding, false)
end
def.method().SetBattleMounts = function(self)
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
  local heroProp = HeroPropMgr.heroProp
  if heroProp == nil then
    return
  end
  local battleMounts = MountsMgr.Instance():GetBattleMountsMap()
  for i = 1, constant.CMountsConsts.maxBattleMounts do
    do
      local mountsObj = self.m_node:FindDirect("Img_Riding_" .. i)
      GUIUtils.SetActive(mountsObj:FindDirect("Btn_Minus"), false)
      local Img_Type = mountsObj:FindDirect("Img_Type")
      local Img_HeadIcon = mountsObj:FindDirect("Img_HeadIcon")
      local Label = mountsObj:FindDirect("Label")
      if battleMounts[i] == nil then
        mountsObj:GetComponent("UISprite"):set_enabled(true)
        GUIUtils.SetActive(Img_Type, false)
        if self.uiModels ~= nil and self.uiModels[i] ~= nil then
          self.uiModels[i]:Destroy()
          self.uiModels[i] = nil
        end
        local unlockLevel = MountsUtils.GetCellUnlockLevel(i)
        if unlockLevel <= heroProp.level then
          GUIUtils.SetText(Label, textRes.Mounts[19])
        else
          GUIUtils.SetText(Label, string.format(textRes.Mounts[20], unlockLevel))
        end
      else
        mountsObj:GetComponent("UISprite"):set_enabled(false)
        local mounts = MountsMgr.Instance():GetMountsById(battleMounts[i].mounts_id)
        if self.uiModels ~= nil then
          if self.uiModels[i] ~= nil and self.preBattleMountsMap ~= nil and not Int64.eq(self.preBattleMountsMap[i].mounts_id, battleMounts[i].mounts_id) then
            self.uiModels[i]:Destroy()
            self.uiModels[i] = nil
          end
          if self.uiModels[i] == nil then
            local uiModel = Img_HeadIcon:GetComponent("UIModel")
            self.uiModels[i] = MountsUtils.LoadMountsModel(uiModel, mounts.mounts_cfg_id, mounts.current_ornament_rank, mounts.color_id, function()
              if self.uiModels ~= nil and self.uiModels[i] ~= nil then
                self.uiModels[i]:SetDir(-135)
                self.uiModels[i]:SetScale(BattleNode.ModelScale[i])
              end
            end)
          end
        end
        local mountsCfg = MountsUtils.GetMountsCfgById(mounts.mounts_cfg_id)
        GUIUtils.SetActive(Img_Type, true)
        GUIUtils.SetSprite(Img_Type, textRes.Mounts.MountsTypeSprite[mountsCfg.mountsType])
        if battleMounts[i].is_chief_battle_mounts == MountsConst.YES_CHIEF_BATTLE_MOUNTS then
          GUIUtils.SetText(Label, textRes.Mounts[12])
        else
          GUIUtils.SetText(Label, textRes.Mounts[13])
        end
      end
    end
  end
  self.preBattleMountsMap = battleMounts
end
def.override("userdata").ChooseMounts = function(self, mountsId)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if not self.isShow then
    return
  end
  local mounts = MountsMgr.Instance():GetMountsById(mountsId)
  if mounts == nil then
    return
  end
  local mountsCfg = MountsUtils.GetMountsCfgById(mounts.mounts_cfg_id)
  if mountsCfg.mountsType == MountsTypeEnum.APPEARANCE_TYPE then
    Toast(textRes.Mounts[66])
    return
  end
  MountsPanelNodeBase.ChooseMounts(self, mountsId)
  if MountsMgr.Instance():IsMountsBattle(mountsId) then
    Toast(textRes.Mounts[17])
  elseif not MountsMgr.Instance():HasSameTypeBattleMounts(mountsId) then
    MountsMgr.Instance():MountsBattle(mountsId)
  else
    Toast(textRes.Mounts[23])
  end
end
def.override().NoMounts = function(self)
  if not self.isShow then
    return
  end
  MountsPanelNodeBase.NoMounts(self)
end
def.method("number", "userdata").ClickMountCell = function(self, cell, cellSource)
  local battleMounts = MountsMgr.Instance():GetBattleMountsMap()
  if battleMounts[cell] == nil then
    Toast(textRes.Mounts[14])
  else
    self.clickCellId = cell
    GUIUtils.SetActive(self.uiObjs.Group_SetRiding, true)
    local position = cellSource.position
    local screenPos = WorldPosToScreen(position.x, position.y)
    local widget = self.uiObjs.Group_SetRiding:FindDirect("Img_Bg2"):GetComponent("UIWidget")
    self.uiObjs.Group_SetRiding:set_localPosition(Vector3.new(screenPos.x - widget.width * 0.35, screenPos.y + widget.height * 0.35, 0))
  end
end
def.method().CancelBattleMounts = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if self.clickCellId > 0 then
    MountsMgr.Instance():MountsUnBattle(self.clickCellId)
  end
end
def.method().SetMountsMainBattle = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if self.clickCellId > 0 then
    if self.preBattleMountsMap ~= nil and self.preBattleMountsMap[self.clickCellId] ~= nil and self.preBattleMountsMap[self.clickCellId].is_chief_battle_mounts == MountsConst.YES_CHIEF_BATTLE_MOUNTS then
      Toast(textRes.Mounts[87])
    else
      MountsMgr.Instance():SetMountsMainBattle(self.clickCellId)
    end
  end
end
def.method().SetMountsSecondBattle = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if self.clickCellId > 0 then
    if self.preBattleMountsMap ~= nil and self.preBattleMountsMap[self.clickCellId] ~= nil and self.preBattleMountsMap[self.clickCellId].is_chief_battle_mounts == MountsConst.NO_CHIEF_BATTLE_MOUNTS then
      Toast(textRes.Mounts[88])
    else
      MountsMgr.Instance():SetMountsSecondBattle(self.clickCellId)
    end
  end
end
def.override("userdata").onClickObj = function(self, clickObj)
  GUIUtils.SetActive(self.uiObjs.Group_SetRiding, false)
  local id = clickObj.name
  if id == "Img_HeadIcon" then
    local parent = clickObj.transform.parent.gameObject
    if parent ~= nil then
      id = parent.name
    end
  end
  if string.find(id, "Img_Riding_") then
    local cell = tonumber(string.sub(id, #"Img_Riding_" + 1))
    if cell ~= nil then
      self:ClickMountCell(cell, clickObj)
    end
  elseif id == "Btn_Cancel" then
    self:CancelBattleMounts()
  elseif id == "Btn_SetAsMain" then
    self:SetMountsMainBattle()
  else
    if id == "Btn_SetAsVice" then
      self:SetMountsSecondBattle()
    else
    end
  end
end
def.static("table", "table").OnMountsBattleStatusChange = function(context, params)
  local self = context
  if self ~= nil then
    self:SetBattleMounts()
  end
end
BattleNode.Commit()
return BattleNode
