local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local GiftNode = Lplus.Extend(TabNode, "GiftNode")
local def = GiftNode.define
local GUIUtils = require("GUI.GUIUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local PresentData = require("Main.Present.data.PresentData")
local FriendData = require("Main.friend.FriendData")
local PresentUtility = require("Main.Present.PresentUtility")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local ItemSourceEnum = require("netio.protocol.mzm.gsp.item.ItemSourceEnum")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local PresentPanel = Lplus.ForwardDeclare("PresentPanel")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local FriendModule = require("Main.friend.FriendModule")
local FriendUtils = require("Main.friend.FriendUtils")
def.field("table").uiTbl = nil
def.field("table").itemList = nil
def.field("table").presentList = nil
def.field("table").selectList = nil
def.field(PresentData).data = nil
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
  self.data = PresentData.Instance()
  self.uiTbl = PresentUtility.FillPresentGiftUI(self.uiTbl, self.m_node)
  self.presentList = {}
  self.selectList = {}
  self:InitGifts()
end
def.method().InitGifts = function(self)
  self.itemList = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_FLOWER_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local flower = {}
    flower.id = DynamicRecord.GetIntValue(entry, "id")
    flower.addIntimacyNum = DynamicRecord.GetIntValue(entry, "addIntimacyNum")
    flower.have = ItemModule.Instance():GetItemCountById(flower.id)
    flower.count = ItemModule.Instance():GetItemCountById(flower.id)
    for k, v in pairs(self.selectList) do
      if v.id == flower.id then
        flower.count = flower.count - v.num
      end
    end
    table.insert(self.itemList, flower)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(self.itemList, function(left, right)
    return left.addIntimacyNum < right.addIntimacyNum
  end)
end
def.override().OnShow = function(self)
  self:FillItemsList(false)
  self:FillSelectList()
  self:UpdateFriendIntimacy()
  self:UpdateMessage()
end
def.method().UpdateMessage = function(self)
  self.uiTbl.Img_BgInput:GetComponent("UIInput"):set_characterLimit(0)
  self.uiTbl.Img_BgInput:GetComponent("UIInput"):set_value(textRes.Present[20])
end
def.method("boolean").FillItemsList = function(self, bOnlyUpdateNum)
  local list = self.itemList
  local uiList = self.uiTbl.Grid_Bag:GetComponent("UIList")
  uiList:set_itemCount(#list)
  uiList:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
  local itemsUI = uiList:get_children()
  for i = 1, #itemsUI do
    local itemUI = itemsUI[i]
    local itemInfo = list[i]
    self:FillItemInfo(itemUI, i, itemInfo, bOnlyUpdateNum)
  end
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
end
def.method("userdata", "number", "table", "boolean").FillItemInfo = function(self, itemUI, index, itemInfo, bOnlyUpdateNum)
  local itemBase = ItemUtils.GetItemBase(itemInfo.id)
  local Label_Num = itemUI:FindDirect(string.format("Label_Num_%d", index)):GetComponent("UILabel")
  if itemInfo.count == 0 then
    local str = string.format("[ff0000]%d[-]", itemInfo.count)
    Label_Num:set_text(str)
  else
    Label_Num:set_text(itemInfo.count)
  end
  itemUI:GetComponent("UIToggle"):set_value(false)
  if bOnlyUpdateNum then
    return
  end
  local Img_PinzhiBg = itemUI:FindDirect(string.format("Img_PinzhiBg_%d", index))
  local Texture_Icon = itemUI:FindDirect(string.format("Texture_Icon_%d", index)):GetComponent("UITexture")
  GUIUtils.FillIcon(Texture_Icon, itemBase.icon)
  Img_PinzhiBg:SetActive(false)
end
def.method().FillSelectList = function(self)
  local uiList = self.uiTbl.Grid_Present:GetComponent("UIList")
  uiList:set_itemCount(#self.selectList)
  uiList:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
  local presentsUI = uiList:get_children()
  for i = 1, #presentsUI do
    local presentUI = presentsUI[i]
    local presentInfo = self.selectList[i]
    self:FillPresentInfo(presentUI, i, presentInfo)
  end
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
end
def.method("userdata", "number", "table").FillPresentInfo = function(self, presentUI, index, presentInfo)
  local itemBase = ItemUtils.GetItemBase(presentInfo.id)
  local Img_PinzhiBg = presentUI:FindDirect(string.format("Img_PinzhiBg_%d", index))
  local Texture_Icon = presentUI:FindDirect(string.format("Texture_Icon_%d", index)):GetComponent("UITexture")
  local Label_Num = presentUI:FindDirect(string.format("Label_Num_%d", index)):GetComponent("UILabel")
  GUIUtils.FillIcon(Texture_Icon, itemBase.icon)
  Label_Num:set_text(presentInfo.num)
  Img_PinzhiBg:SetActive(false)
  local quality = itemBase.namecolor
  local uiSprite = presentUI:GetComponent("UISprite")
  uiSprite:set_spriteName(string.format("Cell_%02d", quality))
end
def.override().OnHide = function(self)
end
def.method().UpdateFriendIntimacy = function(self)
  local addIntimacyNum = 0
  for k, v in pairs(self.selectList) do
    addIntimacyNum = addIntimacyNum + v.addIntimacyNum * v.num
  end
  self.uiTbl.Label_Num:GetComponent("UILabel"):set_text(addIntimacyNum)
end
def.method("table").InsertToSelect = function(self, itemInfo)
  for k, v in pairs(self.selectList) do
    if v.id == itemInfo.id then
      v.num = v.num + 1
      return
    end
  end
  for k, v in pairs(self.selectList) do
    for m, n in pairs(self.itemList) do
      if v.id == n.id then
        n.count = n.have
      end
    end
  end
  self.selectList = {}
  local item = itemInfo
  item.num = 1
  table.insert(self.selectList, item)
end
def.method("table").RemoveFromSelect = function(self, itemInfo)
  for k, v in pairs(self.selectList) do
    if v.id == itemInfo.id then
      if v.num > 1 then
        v.num = v.num - 1
      else
        table.remove(self.selectList, k)
      end
      return
    end
  end
end
def.method("userdata").OnSelectItemClick = function(self, clickobj)
  local id = clickobj.name
  local index = tonumber(string.sub(id, #"Img_BgItem_" + 1, -1))
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local itemInfo = self.itemList[index]
  if 1 <= itemInfo.count then
    itemInfo.count = itemInfo.count - 1
    self:InsertToSelect(itemInfo)
    self:FillItemsList(true)
    self:FillSelectList()
    local itemBase = ItemUtils.GetItemBase(itemInfo.id)
    Toast(string.format(textRes.Present[1], itemBase.name))
  else
    local itemId = itemInfo.id
    local position = clickobj:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = clickobj:GetComponent("UISprite")
    ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, true)
  end
  self:UpdateFriendIntimacy()
end
def.method("number").ItemAdd = function(self, id)
  for k, v in pairs(self.itemList) do
    if v.id == id then
      v.count = v.count + 1
      return
    end
  end
end
def.method("number").OnSelectPresentClick = function(self, index)
  local selectInfo = self.selectList[index]
  self:ItemAdd(selectInfo.id)
  self:RemoveFromSelect(selectInfo)
  self:FillItemsList(true)
  self:FillSelectList()
  self:UpdateFriendIntimacy()
end
def.static("number", "table").NotFriendPresentCallback = function(i, tag)
  if 1 == i then
    local dlg = tag.id
    dlg:RequirePresentFlower()
  elseif 0 == i then
    return
  end
end
def.method().OnPresentClick = function(self)
  if #self.selectList <= 0 then
    Toast(textRes.Present[7])
    return
  end
  local roleId = PresentPanel.Instance().selectRoleId
  local bFriend = FriendModule.Instance():IsFriend(roleId)
  if bFriend == false then
    local tag = {id = self}
    CommonConfirmDlg.ShowConfirm("", textRes.Present[13], GiftNode.NotFriendPresentCallback, tag)
    return
  end
  self:RequirePresentFlower()
end
def.static("number", "table").MaxIntimacyPresentCallback = function(i, tag)
  if 1 == i then
    local dlg = tag.id
    dlg:RealPresentFlower()
  elseif 0 == i then
    return
  end
end
def.method().RequirePresentFlower = function(self)
  local roleId = PresentPanel.Instance().selectRoleId
  local friend = FriendModule.Instance():GetFriendInfo(roleId)
  local intimacyNum = 0
  if friend then
    intimacyNum = friend.relationValue
  end
  local maxIntimacyNum = FriendUtils.GetMaxAddQinMiDuByFlower()
  if intimacyNum >= maxIntimacyNum then
    local tag = {id = self}
    CommonConfirmDlg.ShowConfirm("", textRes.Present[14], GiftNode.MaxIntimacyPresentCallback, tag)
    return
  end
  self:RealPresentFlower()
end
def.method().RealPresentFlower = function(self)
  local message = self.uiTbl.Img_BgInput:GetComponent("UIInput"):get_value()
  if textRes.Present[20] == message or "" == message then
    message = textRes.Present[12]
  end
  if not self:CheckMessageAndToast(message) then
    return
  end
  local p = require("netio.protocol.mzm.gsp.item.CGiveFlowerReq").new(PresentPanel.Instance().selectRoleId, self.selectList[1].id, self.selectList[1].num, message)
  gmodule.network.sendProtocol(p)
end
def.method("string", "=>", "boolean").CheckMessageAndToast = function(self, message)
  local PresentNameValidator = require("Main.Present.PresentNameValidator")
  local NameValidator = require("Main.Common.NameValidator")
  local isValid, reason, _ = PresentNameValidator.Instance():IsValid(message)
  if isValid == false then
    if reason == NameValidator.InvalidReason.TooShort then
      Toast(textRes.Present[9])
      return false
    elseif reason == NameValidator.InvalidReason.TooLong then
      Toast(textRes.Present[10])
      return false
    elseif reason == NameValidator.InvalidReason.NotInSection then
      Toast(textRes.Present[11])
      return false
    end
  end
  if SensitiveWordsFilter.ContainsSensitiveWord(message) then
    Toast(textRes.Present[21])
    return false
  end
  return true
end
def.method().OnTipsClick = function(self)
  local tipsId = PresentUtility.GetPresentConsts("FLOAT_TIP")
  local GUIUtils = require("GUI.GUIUtils")
  GUIUtils.ShowHoverTip(tipsId, 0, 0)
end
def.method().OnBagInfoChanged = function(self)
  self.itemList = {}
  self:FillItemsList(false)
  self:InitGifts()
  self:FillItemsList(false)
end
def.method("userdata").FocusOnInput = function(self, clickobj)
  local input = clickobj:GetComponent("UIInput")
  input:set_isSelected(true)
end
def.override("string", "string").onTextChange = function(self, id, val)
  local PresentNameValidator = require("Main.Present.PresentNameValidator")
  local NameValidator = require("Main.Common.NameValidator")
  local input = self.uiTbl.Img_BgInput:GetComponent("UIInput")
  if input:get_isSelected() then
    local val = input:get_value()
    local isValid, reason, _ = PresentNameValidator.Instance():IsValid(val)
    if isValid == false then
      if reason == NameValidator.InvalidReason.TooShort then
        Toast(textRes.Present[9])
      elseif reason == NameValidator.InvalidReason.TooLong then
        Toast(textRes.Present[10])
        local real = PresentNameValidator.Instance():GetWordMaxVal(val)
        input:set_value(real)
      elseif reason == NameValidator.InvalidReason.NotInSection then
        Toast(textRes.Present[11])
      end
    end
  end
end
def.method("userdata").SucceedFlower = function(self, roleId)
  self.selectList = {}
  if roleId == PresentPanel.Instance().selectRoleId then
    self:FillSelectList()
    self:UpdateFriendIntimacy()
    self:UpdateMessage()
  end
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if string.sub(id, 1, #"Img_BgItem_") == "Img_BgItem_" then
    self:OnSelectItemClick(clickobj)
  elseif string.sub(id, 1, #"Img_Present_") == "Img_Present_" then
    local index = tonumber(string.sub(id, #"Img_Present_" + 1, -1))
    self:OnSelectPresentClick(index)
  elseif "Btn_FlowerPresent" == id then
    self:OnPresentClick()
  elseif "Btn_Tips" == id then
    self:OnTipsClick()
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_node.name
    })
  elseif "Label_Message" == id then
    self:FocusOnInput(clickobj)
  end
end
GiftNode.Commit()
return GiftNode
