local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local AvatarNode = Lplus.Extend(TabNode, "AvatarNode")
local AvatarInterface = require("Main.Avatar.AvatarInterface")
local avatarInterface = AvatarInterface.Instance()
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = AvatarNode.define
def.field("table").avatarList = nil
def.field("number").selectedIdx = 0
def.field("number").selectedItemId = 0
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
  self.selectedItemId = base.selectedItemId
end
def.override().OnShow = function(self)
  self.m_base:setCurAvatarInfo()
  self:setAvatarList()
  self:setAvatarInfo()
end
def.override().OnHide = function(self)
  self.selectedIdx = 0
  self.selectedItemId = 0
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  local strs = string.split(id, "_")
  if id == "Toggle" then
    local uiToggle = clickObj:GetComponent("UIToggle")
    warn("------uiToggle value:", uiToggle.value)
    if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_AVATAR) then
      Toast(textRes.Avatar[1])
      return
    end
    if uiToggle.value then
      local avatarCfg = self.avatarList[self.selectedIdx]
      local p = require("netio.protocol.mzm.gsp.avatar.CActivateAvatarReq").new(avatarCfg.id)
      gmodule.network.sendProtocol(p)
    else
      local p = require("netio.protocol.mzm.gsp.avatar.CActivateAvatarReq").new(0)
      gmodule.network.sendProtocol(p)
    end
  elseif id == "Btn_Dress" then
    local avatarCfg = self.avatarList[self.selectedIdx]
    if avatarCfg then
      if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_AVATAR) then
        Toast(textRes.Avatar[1])
        return
      end
      local curAvatarId = avatarInterface:getCurAvatarId()
      if avatarCfg.id == curAvatarId then
        Toast(string.format(textRes.Avatar[13], avatarCfg.name))
        return
      end
      local p = require("netio.protocol.mzm.gsp.avatar.CSetAvatarReq").new(avatarCfg.id)
      gmodule.network.sendProtocol(p)
      warn("--------CSetAvatarReq:", avatarCfg.id)
    end
  elseif id == "Btn_Change" or id == "Btn_Rollover" then
    local avatarCfg = self.avatarList[self.selectedIdx]
    if avatarCfg == nil then
      return
    end
    local curAvatarId = avatarInterface:getCurAvatarId()
    local ownNum = self:getUnlockItemIdNum(avatarCfg.id)
    if ownNum >= 1 then
      if avatarInterface:isUnlockAvatarId(avatarCfg.id) then
        local info = avatarInterface:getUnlockAvatarInfo(avatarCfg.id)
        if info and info.expire_time:eq(Int64.new(0)) then
          Toast(textRes.Avatar[25])
          return
        end
      end
      local AvatarItemUsePanel = require("Main.Avatar.ui.AvatarItemUsePanel")
      AvatarItemUsePanel.Instance():ShowPanel(avatarCfg.id)
    else
      Toast(textRes.Avatar[24])
    end
  elseif id == "Btn_Effect" then
    local AvatarEffectPanel = require("Main.Avatar.ui.AvatarEffectPanel")
    AvatarEffectPanel.Instance():ShowPanel()
  elseif id == "Bg_Item" then
    local avatarCfg = self.avatarList[self.selectedIdx]
    local CommonUsePanel = require("GUI.CommonUsePanel")
    local unlockItemCfg = AvatarInterface.GetAvatar2UnlockItemCfg(avatarCfg.id)
    local comp = function(cfg1, cfg2)
      if cfg1.duration == 0 then
        return false
      end
      if cfg2.duration == 0 then
        return true
      end
      return cfg1.duration < cfg2.duration
    end
    table.sort(unlockItemCfg.items, comp)
    local itemIdList = {}
    for i, v in ipairs(unlockItemCfg.items) do
      table.insert(itemIdList, v.itemId)
    end
    ItemTipsMgr.Instance():ShowMutilItemBasicTipsEx(itemIdList, {
      x = 0,
      y = 0,
      vAlign = "center"
    }, false)
  elseif strs[1] == "Img" and strs[2] == "BgHead" then
    local idx = tonumber(strs[3])
    if idx and idx ~= self.selectedIdx then
      local avatarCfg = self.avatarList[idx]
      if avatarCfg then
        avatarInterface:removeNewAvatarId(avatarCfg.id)
      end
      local HeadList = self.m_node:FindDirect("Group_Head/List_Head/Scroll View/HeadList")
      local Img_BgHead = HeadList:FindDirect("Img_BgHead_" .. self.selectedIdx)
      if Img_BgHead then
        local Img_Select = Img_BgHead:FindDirect("Img_Select_" .. self.selectedIdx)
        Img_Select:SetActive(false)
      end
      Img_BgHead = HeadList:FindDirect("Img_BgHead_" .. idx)
      if Img_BgHead then
        local Img_New = Img_BgHead:FindDirect("Img_New_" .. idx)
        Img_New:SetActive(false)
        local Img_Select = Img_BgHead:FindDirect("Img_Select_" .. idx)
        Img_Select:SetActive(true)
      end
      self.selectedItemId = 0
      self.selectedIdx = idx
      self:setAvatarInfo()
    end
  end
end
def.method("=>", "boolean").IsOpen = function()
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_AVATAR) then
    return false
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local curLevel = 0
  if heroProp then
    curLevel = heroProp.level
  end
  if curLevel < constant.CAvatarConsts.OPEN_LEVEL then
    return false
  end
  return true
end
def.method("=>", "boolean").IsHaveNotifyMessage = function()
  return avatarInterface:isHaveNewAvatar()
end
def.method().setAvatarList = function(self)
  local avatarList = AvatarInterface.GetAllAvatarCfgList()
  self.avatarList = avatarList
  local HeadList = self.m_node:FindDirect("Group_Head/List_Head/Scroll View/HeadList")
  local uiList = HeadList:GetComponent("UIList")
  uiList.itemCount = #avatarList
  uiList:Resize()
  local curAvatarId = avatarInterface:getCurAvatarId()
  self.selectedIdx = 0
  for i, v in ipairs(avatarList) do
    if 0 < self.selectedItemId then
      if self.selectedItemId == v.unlockItemId then
        self.selectedIdx = i
      end
    elseif v.id == curAvatarId then
      self.selectedIdx = i
    end
    local Img_BgHead = HeadList:FindDirect("Img_BgHead_" .. i)
    local Icon_Head = Img_BgHead:FindDirect("Icon_Head_" .. i)
    local Img_Select = Img_BgHead:FindDirect("Img_Select_" .. i)
    local Img_New = Img_BgHead:FindDirect("Img_New_" .. i)
    local Img_Chuan = Img_BgHead:FindDirect("Img_Chuan_" .. i)
    local Img_Lock = Img_BgHead:FindDirect("Img_Lock_" .. i)
    local icon_texture = Icon_Head:GetComponent("UITexture")
    GUIUtils.FillIcon(icon_texture, v.avatarId)
    Img_Chuan:SetActive(curAvatarId == v.id)
    Img_Select:SetActive(self.selectedIdx == i)
    if avatarInterface:isUnlockAvatarId(v.id) then
      Img_Lock:SetActive(false)
      GUIUtils.SetTextureEffect(icon_texture, GUIUtils.Effect.Normal)
    else
      Img_Lock:SetActive(true)
      GUIUtils.SetTextureEffect(icon_texture, GUIUtils.Effect.Gray)
    end
    Img_New:SetActive(avatarInterface:isNewGetAvatar(v.id))
  end
  self.selectedItemId = 0
end
def.method().setAvatarInfo = function(self)
  local Group_Operatipn = self.m_node:FindDirect("Group_Operatipn")
  local Label_Des = Group_Operatipn:FindDirect("Item_Get/Label_1")
  local Label_Attr = Group_Operatipn:FindDirect("Item_Attribute/Label_1")
  local Toggle = Group_Operatipn:FindDirect("Item_Attribute/Toggle")
  local Btn_Change = Group_Operatipn:FindDirect("Group_Item/Btn_Change")
  local uiToggle = Toggle:GetComponent("UIToggle")
  local avatarCfg = self.avatarList[self.selectedIdx]
  local Label_Time = Group_Operatipn:FindDirect("Item_Time/Label_1")
  local Group_Item = Group_Operatipn:FindDirect("Group_Item")
  local Group_Btn1 = Group_Operatipn:FindDirect("Group_Btn1")
  local Group_Btn2 = Group_Operatipn:FindDirect("Group_Btn2")
  local Label_2 = Group_Operatipn:FindDirect("Item_Time/Label_2")
  if avatarCfg then
    Label_Des:GetComponent("UILabel"):set_text(avatarCfg.description)
    Label_2:GetComponent("UILabel"):set_text(avatarCfg.name)
    uiToggle.value = avatarInterface.curAttrAvatarId == avatarCfg.id
    local Icon_Head = self.m_panel:FindDirect("Img_Bg0/Img_BgCharacter/Icon_Head")
    GUIUtils.FillIcon(Icon_Head:GetComponent("UITexture"), avatarCfg.avatarId)
    local desc = {}
    for i, v in pairs(avatarCfg.attrs) do
      local propertyCfg = _G.GetCommonPropNameCfg(i)
      if propertyCfg ~= nil then
        table.insert(desc, string.format("%s + %d", propertyCfg.propName, v))
      end
    end
    if #desc > 0 then
      GUIUtils.SetText(Label_Attr, table.concat(desc, "\227\128\129"))
    else
      GUIUtils.SetText(Label_Attr, textRes.Avatar[7])
    end
    if avatarInterface:isUnlockAvatarId(avatarCfg.id) then
      if avatarInterface:isOwnAttrAvatarId(avatarCfg.id) then
        Toggle:SetActive(true)
      else
        Toggle:SetActive(false)
      end
      if avatarInterface:getCurAvatarId() == avatarCfg.id then
        Btn_Change:SetActive(false)
      else
        Btn_Change:SetActive(true)
      end
      Group_Item:SetActive(false)
      local info = avatarInterface:getUnlockAvatarInfo(avatarCfg.id)
      if info and info.expire_time:gt(Int64.new(0)) then
        Group_Btn1:SetActive(true)
        Group_Btn2:SetActive(false)
      else
        Group_Btn2:SetActive(true)
        Group_Btn1:SetActive(false)
      end
    else
      Toggle:SetActive(false)
      Group_Btn1:SetActive(false)
      Group_Btn2:SetActive(false)
      local ownNum = self:getUnlockItemIdNum(avatarCfg.id)
      Group_Item:SetActive(true)
      Btn_Change:SetActive(true)
      local Img_Icon = Group_Item:FindDirect("Bg_Item/Img_Icon")
      local icon_texture = Img_Icon:GetComponent("UITexture")
      GUIUtils.FillIcon(icon_texture, avatarCfg.avatarId)
      local Label_Name = Group_Item:FindDirect("Label_Name")
      local Label_Num = Group_Item:FindDirect("Label_Num")
      Label_Name:GetComponent("UILabel"):set_text(avatarCfg.name)
      Label_Num:GetComponent("UILabel"):set_text(ownNum .. "/" .. 1)
    end
    Label_Time:GetComponent("UILabel"):set_text(avatarInterface:getLeftTimeStr(avatarCfg.id))
  else
    Label_Des:GetComponent("UILabel"):set_text("")
    Label_Attr:GetComponent("UILabel"):set_text(textRes.Avatar[7])
    Label_Time:GetComponent("UILabel"):set_text("")
    Label_2:GetComponent("UILabel"):set_text("")
    uiToggle.value = false
    Group_Item:SetActive(false)
    Group_Btn1:SetActive(false)
    Group_Btn2:SetActive(false)
  end
end
def.method("number", "=>", "number").getUnlockItemIdNum = function(self, avatarId)
  return avatarInterface:getUnlockItemIdNum(avatarId)
end
return AvatarNode.Commit()
