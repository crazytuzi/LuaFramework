local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local AvatarFrameNode = Lplus.Extend(TabNode, "AvatarFrameNode")
local AvatarInterface = require("Main.Avatar.AvatarInterface")
local AvatarFrameMgr = require("Main.Avatar.AvatarFrameMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local def = AvatarFrameNode.define
def.field("number").selectedFrameId = 0
def.field("number").curSelectedIdx = 0
def.field("table").curFrameList = nil
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
  self.selectedFrameId = base.selectedAvatarFrameId
end
def.override().OnShow = function(self)
  self.m_base:setCurAvatarInfo()
  self:setAvatarFrameList()
  self:setFrameInfo()
end
def.override().OnHide = function(self)
  self.selectedFrameId = 0
  self.curSelectedIdx = 0
end
def.method().resetAvatarFrameInfo = function(self)
  self:setAvatarFrameList()
  self:setFrameInfo()
end
def.method("=>", "boolean").IsOpen = function()
  return AvatarFrameMgr.Instance():IsOpen()
end
def.method("=>", "boolean").IsHaveNotifyMessage = function()
  return AvatarFrameMgr.Instance():IsHaveNotifyMessage()
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  local strs = string.split(id, "_")
  if id == "Btn_Change" then
    self:unlockAvatarFrame(true)
  elseif id == "Btn_Dress" then
    local curFrameId = AvatarFrameMgr.Instance():getCurAvatarFrameId()
    if self.selectedFrameId == curFrameId then
      Toast(textRes.Avatar[105])
      return
    end
    local p = require("netio.protocol.mzm.gsp.avatar.CSetAvatarFrameReq").new(self.selectedFrameId)
    gmodule.network.sendProtocol(p)
  elseif id == "Btn_Rollover" then
    self:unlockAvatarFrame(false)
  elseif id == "Bg_Item" then
    local frameCfg = AvatarFrameMgr.GetAvatarFrameCfg(self.selectedFrameId)
    if frameCfg then
      ItemTipsMgr.Instance():ShowBasicTipsWithGO(frameCfg.unlockItemId, clickObj, 0, false)
    end
  elseif strs[1] == "Img" and strs[2] == "Bg" and strs[3] == "BgHead" then
    local idx = tonumber(strs[4])
    if idx then
      local cfg = self.curFrameList[idx]
      if cfg == nil then
        clickObj:GetComponent("UIToggle").value = false
        local BgHeadList = self.m_node:FindDirect("Group_BgHead/List_BgHead/ScrollView_BgHead/BgHeadList")
        local Img_Bg_BgHead = BgHeadList:FindDirect("Img_Bg_BgHead_" .. self.curSelectedIdx)
        if Img_Bg_BgHead then
          Img_Bg_BgHead:GetComponent("UIToggle").value = true
        end
        return
      end
      local Img_Select = clickObj:FindDirect("Img_Select_" .. idx)
      Img_Select:SetActive(true)
      self.selectedFrameId = cfg.id
      self.curSelectedIdx = idx
      self:setFrameInfo()
      local Img_New = clickObj:FindDirect("Img_New_" .. idx)
      if Img_New then
        AvatarFrameMgr.Instance():removeNewAvatarFrameId(self.selectedFrameId)
        Img_New:SetActive(false)
      end
    end
  end
end
def.method("boolean").unlockAvatarFrame = function(self, isUnlock)
  local frameCfg = AvatarFrameMgr.GetAvatarFrameCfg(self.selectedFrameId)
  if frameCfg == nil then
    return
  end
  local ownNum = ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, frameCfg.unlockItemId)
  if ownNum >= 1 then
    do
      local items = ItemModule.Instance():GetItemsByItemID(ItemModule.BAG, frameCfg.unlockItemId)
      local uuid
      local function callback(id)
        if id == 1 then
          local p = require("netio.protocol.mzm.gsp.avatar.CUseAvatarFrameUnlockItemReq").new(uuid)
          gmodule.network.sendProtocol(p)
        end
      end
      for i, v in pairs(items) do
        local strs
        local itemBase = ItemUtils.GetItemBase(v.id)
        if isUnlock then
          strs = string.format(textRes.Avatar[100], itemBase.name, frameCfg.name)
        else
          local frameItemCfg = AvatarFrameMgr.GetAvatarFrameItemCfg(v.id)
          strs = string.format(textRes.Avatar[101], itemBase.name, frameCfg.name, frameItemCfg.duration)
        end
        uuid = v.uuid[1]
        CommonConfirmDlg.ShowConfirm("", strs, callback, {})
        return
      end
    end
  else
    Toast(textRes.Avatar[12])
  end
end
def.method().setAvatarFrameList = function(self)
  local frameList = AvatarFrameMgr.GetAllAvatarCfgList()
  self.curFrameList = frameList
  local num = 0
  if #frameList <= constant.CAvatarFrameConsts.INITIAL_DISPLAY_NUM then
    num = constant.CAvatarFrameConsts.INITIAL_DISPLAY_NUM
  else
    num = math.ceil(#frameList / 3) * 3
  end
  local BgHeadList = self.m_node:FindDirect("Group_BgHead/List_BgHead/ScrollView_BgHead/BgHeadList")
  local uiList = BgHeadList:GetComponent("UIList")
  uiList.itemCount = num
  uiList:Resize()
  local avatarFrameMgr = AvatarFrameMgr.Instance()
  local curFrameId = avatarFrameMgr:getCurAvatarFrameId()
  if self.selectedFrameId == 0 then
    self.selectedFrameId = curFrameId
  end
  for i = 1, num do
    local v = frameList[i]
    local Img_Bg_BgHead = BgHeadList:FindDirect("Img_Bg_BgHead_" .. i)
    local Icon_Bg = Img_Bg_BgHead:FindDirect("Icon_Bg_" .. i)
    local Img_Select = Img_Bg_BgHead:FindDirect("Img_Select_" .. i)
    local Label_Try = Img_Select:FindDirect("Label_Try_" .. i)
    local Img_New = Img_Bg_BgHead:FindDirect("Img_New_" .. i)
    local Img_Lock = Img_Bg_BgHead:FindDirect("Img_Lock_" .. i)
    local Label_Chuan = Img_Bg_BgHead:FindDirect("Label_Chuan_" .. i)
    if v then
      local icon_texture = Icon_Bg:GetComponent("UITexture")
      GUIUtils.FillIcon(icon_texture, v.avatarFrameId)
      local uitoggle = Img_Bg_BgHead:GetComponent("UIToggle")
      if self.selectedFrameId == v.id then
        Img_Select:SetActive(true)
        uitoggle.value = true
        self.curSelectedIdx = i
      else
        Img_Select:SetActive(false)
        uitoggle.value = false
      end
      if curFrameId == v.id then
        Label_Try:SetActive(false)
        Label_Chuan:SetActive(true)
      else
        Label_Try:SetActive(true)
        Label_Chuan:SetActive(false)
      end
      if avatarFrameMgr:isUnlockAvatarFrame(v.id) then
        Img_Lock:SetActive(false)
        GUIUtils.SetTextureEffect(icon_texture, GUIUtils.Effect.Normal)
      else
        Img_Lock:SetActive(true)
        GUIUtils.SetTextureEffect(icon_texture, GUIUtils.Effect.Gray)
      end
      if avatarFrameMgr:isNewAvatarFrame(v.id) then
        Img_New:SetActive(true)
      else
        Img_New:SetActive(false)
      end
    else
      Icon_Bg:SetActive(false)
      Img_Select:SetActive(false)
      Img_New:SetActive(false)
      Img_Lock:SetActive(false)
      Label_Chuan:SetActive(false)
    end
  end
end
def.method().setFrameInfo = function(self)
  local frameCfg = AvatarFrameMgr.GetAvatarFrameCfg(self.selectedFrameId)
  if frameCfg then
    local avatarFrameMgr = AvatarFrameMgr.Instance()
    local Icon_BgHead = self.m_panel:FindDirect("Img_Bg0/Img_BgCharacter/Icon_BgHead")
    GUIUtils.FillIcon(Icon_BgHead:GetComponent("UITexture"), frameCfg.avatarFrameId)
    local Group_Operatipn = self.m_node:FindDirect("Group_Operatipn")
    local Label_1 = Group_Operatipn:FindDirect("Item_Get/Label_1")
    local Label_2 = Group_Operatipn:FindDirect("Item_Time/Label_2")
    Label_1:GetComponent("UILabel"):set_text(frameCfg.description)
    Label_2:GetComponent("UILabel"):set_text(frameCfg.name)
    local Label_time = Group_Operatipn:FindDirect("Item_Attribute/Label_1")
    Label_time:GetComponent("UILabel"):set_text(avatarFrameMgr:getLeftTimeStr(frameCfg.id))
    local Group_Item = Group_Operatipn:FindDirect("Group_Item")
    local Group_Btn1 = Group_Operatipn:FindDirect("Group_Btn1")
    local Group_Btn2 = Group_Operatipn:FindDirect("Group_Btn2")
    local curFrameId = avatarFrameMgr:getCurAvatarFrameId()
    local unlockItemId = frameCfg.unlockItemId
    if avatarFrameMgr:isUnlockAvatarFrame(frameCfg.id) then
      Group_Item:SetActive(false)
      local FrameItemCfg = AvatarFrameMgr.GetAvatarFrameItemCfg(unlockItemId)
      if FrameItemCfg.duration > 0 then
        Group_Btn1:SetActive(true)
        Group_Btn2:SetActive(false)
      else
        Group_Btn1:SetActive(false)
        Group_Btn2:SetActive(true)
      end
    else
      Group_Item:SetActive(true)
      Group_Btn1:SetActive(false)
      Group_Btn2:SetActive(false)
      local Label_Name = Group_Item:FindDirect("Label_Name")
      local Label_Num = Group_Item:FindDirect("Label_Num")
      local Img_Icon = Group_Item:FindDirect("Bg_Item/Img_Icon")
      local itemBase = ItemUtils.GetItemBase(unlockItemId)
      GUIUtils.FillIcon(Img_Icon:GetComponent("UITexture"), itemBase.icon)
      Label_Name:GetComponent("UILabel"):set_text(itemBase.name)
      local ownNum = ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, frameCfg.unlockItemId)
      Label_Num:GetComponent("UILabel"):set_text(ownNum .. "/" .. 1)
    end
  else
  end
end
return AvatarFrameNode.Commit()
