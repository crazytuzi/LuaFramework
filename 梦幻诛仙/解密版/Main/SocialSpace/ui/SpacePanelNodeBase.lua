local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local SpacePanelNodeBase = Lplus.Class(CUR_CLASS_NAME)
local ECPanelBase = require("GUI.ECPanelBase")
local def = SpacePanelNodeBase.define
local SocialSpaceUtils = import("..SocialSpaceUtils")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
def.field(ECPanelBase).m_base = nil
def.field("userdata").m_panel = nil
def.field("userdata").m_node = nil
def.field("boolean").isShow = false
def.field("number").nodeId = 0
def.field("number").sort = 0
def.field("userdata").m_ownerId = Zero_Int64_Init
def.field("number").m_ownerServerId = 0
def.field("string").m_ownerName = ""
def.field("number").m_charLimit = 0
def.field("number").m_lastCharNum = 0
def.field("table").m_texMapFilePath = nil
def.field("boolean").m_needReset = false
def.field("table").m_msgList = BLANK_TABLE_INIT
def.virtual("=>", "boolean").IsOpen = function(self)
  return true
end
def.virtual("=>", "boolean").IsNodeShow = function(self)
  if self.m_base and self.m_base:IsLoaded() then
    return self.isShow
  end
  return false
end
def.method(ECPanelBase, "userdata", "table").Create = function(self, base, node, params)
  self.m_base = base
  self.m_panel = self.m_base.m_panel
  self.m_node = node
  if params then
    self.nodeId = params.nodeId or 0
    self.sort = params.sort or 0
  end
  self.m_ownerId = base.m_ownerId
  self.m_ownerServerId = base.m_ownerServerId
  self.m_ownerName = base.m_ownerName
  self:OnCreate()
end
def.virtual().OnCreate = function(self)
end
def.method().Destroy = function(self)
  if self.m_base == nil then
    return
  end
  self:OnDestroy()
  self.m_base = nil
  self.m_panel = nil
  self.m_node = nil
  self.m_ownerId = nil
end
def.virtual().OnDestroy = function(self)
end
def.method().Show = function(self)
  self.m_node:SetActive(true)
  self.isShow = true
  self:OnShow()
end
def.virtual().OnShow = function(self)
end
def.method().Hide = function(self)
  self.m_node:SetActive(false)
  self.isShow = false
  self:OnHide()
end
def.virtual().OnHide = function(self)
end
def.virtual("userdata").onClickObj = function(self, obj)
end
def.virtual("string", "userdata").onSubmit = function(self, id, ctrl)
end
def.virtual("userdata", "boolean").onPressObj = function(self, obj, state)
end
def.virtual("string").onDragStart = function(self, id)
end
def.virtual("string", "number", "number").onDrag = function(self, id, dx, dy)
end
def.virtual("string").onDragEnd = function(self, id, go)
end
def.virtual("string", "string").onTextChange = function(self, id, text)
  if id == "Img_BgInput" then
    local charNum = _G.Strlen(text)
    if self.m_charLimit ~= 0 and charNum == self.m_charLimit and self.m_lastCharNum == self.m_charLimit then
      Toast(textRes.Common[82]:format(self.m_charLimit))
    end
    self.m_lastCharNum = charNum
  end
end
def.method("boolean").AppendNextPageMsg = function(self, bCheckCoolTime)
  print("AppendNextPageMsg")
  self:RefreshMsg(true, bCheckCoolTime)
end
def.method().CheckHasNewMsg = function(self)
  print("CheckHasNewMsg")
  self:RefreshMsg(false, true)
end
def.virtual("boolean", "boolean").RefreshMsg = function(self, bGetEarlyMsg, bCheckCoolTime)
end
def.method("userdata", "varlist", "=>", "userdata", "userdata").GetCurDealMsgID = function(self, sender, level)
  level = level or 5
  for i = 1, level do
    if sender == nil then
      return nil, nil
    end
    local _, _, ID = sender.name:find("message_(%d+)")
    if ID then
      return Int64.ParseString(ID), sender
    end
    sender = sender.parent
  end
  return nil, nil
end
def.method("userdata").RemoveMsgByMsgID = function(self, ID)
  if not self:IsNodeShow() then
    return
  end
  local Table_Message = self.m_UIGOs.Table_Message
  local itemUI = Table_Message:FindDirect(string.format("message_%s", ID:tostring()))
  if not _G.IsNil(itemUI) then
    local childCount = Table_Message:get_childCount() - 1
    local siblingIndex = itemUI.transform:GetSiblingIndex()
    local focusSiblingIndex
    if siblingIndex == childCount then
      focusSiblingIndex = siblingIndex - 1
    else
      focusSiblingIndex = siblingIndex + 1
    end
    local focusItemUI
    if focusSiblingIndex > 0 then
      focusItemUI = Table_Message:GetChild(focusSiblingIndex)
    else
      self.m_UIGOs.UIScrollView_Message:GetComponent("UIScrollView"):ResetPosition()
    end
    itemUI.parent = nil
    itemUI:Destroy()
    self:RepositionMsgTable(focusItemUI, true)
  end
  for i, msg in ipairs(self.m_msgList) do
    if ID == msg.ID then
      table.remove(self.m_msgList, i)
      break
    end
  end
end
def.virtual().PlayNoMoreMsgAni = function(self)
  TODO("PlayNoMoreMsgAni")
end
def.method("userdata").OnClickRoleLink = function(self, sender)
  local roleId = Int64.ParseString(sender.name:split("_")[3])
  local labelText = GUIUtils.GetUILabelTxt(sender)
  local roleName = labelText:sub(2, -2)
  local serverId = self.m_spaceMan:GetRoleServerId(roleId)
  self.m_spaceMan:ShowPlayerMenu(sender, roleId, roleName, 0, serverId)
end
def.method("userdata", "string").SetHtmlText = function(self, html, content)
  local prev = html:get_html()
  if prev == content then
    return
  end
  html:ForceHtmlText(content)
end
def.method("userdata", "string", "varlist").FillTextureFromLocalPath = function(self, Texture, filePath, onTextureFilled)
  if _G.IsNil(Texture) then
    return
  end
  local instanceId = Texture:GetInstanceID()
  self.m_texMapFilePath = self.m_texMapFilePath or {}
  if self.m_texMapFilePath[instanceId] ~= filePath then
    self.m_texMapFilePath[instanceId] = filePath
    if filePath ~= "" then
      GUIUtils.FillTextureFromLocalPath(Texture, filePath, onTextureFilled)
    else
      GUIUtils.SetTexture(Texture, 0)
      if onTextureFilled then
        onTextureFilled(nil)
      end
    end
  else
    local uiTexture = Texture:GetComponent("UITexture")
    if onTextureFilled then
      onTextureFilled(uiTexture.mainTexture)
    end
  end
end
def.method("boolean").SetNeedReset = function(self, needReset)
  self.m_needReset = needReset
end
return SpacePanelNodeBase.Commit()
