local Lplus = require("Lplus")
local FabaoTabNode = require("Main.Fabao.ui.FabaoTabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local FabaoData = require("Main.Fabao.data.FabaoData")
local FabaoModule = Lplus.ForwardDeclare("FabaoModule")
local ItemUtils = require("Main.Item.ItemUtils")
local FabaoUtils = require("Main.Fabao.FabaoUtils")
local FabaoXQNode = Lplus.Extend(FabaoTabNode, "FabaoXQNode")
local def = FabaoXQNode.define
local TypeId = {
  Btn_Gold = 1,
  Btn_Wood = 2,
  Btn_Water = 3,
  Btn_Fire = 4,
  Btn_Dust = 5,
  Btn_Wind = 6
}
def.field("table").m_UIObjs = nil
def.field("number").m_CurType = 0
def.field("number").m_CurSlot = 0
def.field("table").m_CurLingjingInBag = nil
def.field("table").m_CurTypeNames = nil
def.field("boolean").m_IsFirstShow = true
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  FabaoTabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:InitData()
  self:InitUI()
  self:Update()
end
def.override().OnHide = function(self)
  self.m_UIObjs = nil
  self.m_CurLingjingInBag = nil
  self.m_CurTypeNames = nil
  self.m_IsFirstShow = true
end
def.override("=>", "boolean").HasSubNode = function(self)
  return false
end
def.method().InitData = function(self)
  if 0 == self.m_CurType then
    self.m_CurType = TypeId.Btn_Gold
  end
  if 0 == self.m_CurSlot then
    self.m_CurSlot = 1
  end
  if self.m_Params then
    self.m_Params = nil
  end
  self.m_IsFirstShow = true
end
def.method().InitUI = function(self)
  if nil == self.m_UIObjs then
    self.m_UIObjs = {}
  end
  self.m_UIObjs.LeftFabaoList = self.m_panel:FindDirect("Img_Bg1/Group_List")
  self.m_UIObjs.LeftFabaoList:SetActive(false)
  self.m_UIObjs.TypeGroup = {}
  self.m_UIObjs.TypeGroup[1] = self.m_node:FindDirect("Group_Xiangxing/Btn_Gold")
  self.m_UIObjs.TypeGroup[2] = self.m_node:FindDirect("Group_Xiangxing/Btn_Wood")
  self.m_UIObjs.TypeGroup[3] = self.m_node:FindDirect("Group_Xiangxing/Btn_Water")
  self.m_UIObjs.TypeGroup[4] = self.m_node:FindDirect("Group_Xiangxing/Btn_Fire")
  self.m_UIObjs.TypeGroup[5] = self.m_node:FindDirect("Group_Xiangxing/Btn_Dust")
  self.m_UIObjs.TypeGroup[6] = self.m_node:FindDirect("Group_Xiangxing/Btn_Wind")
  self.m_UIObjs.SlotGroup = {}
  self.m_UIObjs.SlotGroup[1] = self.m_node:FindDirect("Group_Slot/Img_Slot_1")
  self.m_UIObjs.SlotGroup[2] = self.m_node:FindDirect("Group_Slot/Img_Slot_2")
  self.m_UIObjs.SlotGroup[3] = self.m_node:FindDirect("Group_Slot/Img_Slot_3")
  self.m_UIObjs.LongJingListView = self.m_node:FindDirect("Group_Bag/Img_BgBag/Scroll View/Table_BugList")
  self.m_UIObjs.DressOffBtn = self.m_node:FindDirect("Btn_DressOff")
end
def.method().UpdateData = function(self)
  self.m_CurTypeNames = FabaoUtils.GetSpecialTypeLongjingTypeName(self.m_CurType)
  self.m_CurLingjingInBag = FabaoModule.Instance():GetSpecialLongjingInBag(self.m_CurType)
end
def.method().Update = function(self)
  self:UpdateData()
  self:UpdateLeftView()
  self:UpdateRightView()
end
def.method().UpdateLeftView = function(self)
  local allLongjing = FabaoData.Instance():GetAllLongJingData()
  local longjingInBag = FabaoModule.Instance():GetAllLongjingInBag()
  local longjingBtn = self.m_UIObjs.TypeGroup[1]
  for k, v in pairs(TypeId) do
    longjingBtn = self.m_UIObjs.TypeGroup[v]
    if longjingBtn and not longjingBtn.isnil then
      if self.m_CurType == v then
        longjingBtn:GetComponent("UIToggle").value = true
      end
      local longjingOftype = longjingInBag[v]
      local haveTypeLongjing = longjingOftype and #longjingOftype or 0
      local isFull, _ = FabaoData.Instance():IsLongjingFullOnType(v)
      local canLevelUpOnType = FabaoModule.Instance():CanLevelUpOnLongjingType(v)
      if not isFull and haveTypeLongjing > 0 or canLevelUpOnType then
        longjingBtn:FindDirect("Img_Red"):SetActive(true)
      else
        longjingBtn:FindDirect("Img_Red"):SetActive(false)
      end
    end
  end
  local isEmpty = FabaoData.Instance():IsLongjingEmptyOnType(self.m_CurType)
  if not isEmpty then
    local longjingInfo = allLongjing[self.m_CurType]
    for i = 1, 3 do
      local bgSprite = self.m_UIObjs.SlotGroup[i]:GetComponent("UISprite")
      local texture = self.m_UIObjs.SlotGroup[i]:FindDirect("Img_SlotIcon"):GetComponent("UITexture")
      local arrowImg = self.m_UIObjs.SlotGroup[i]:FindDirect("Img_Arrow")
      local info = longjingInfo[i]
      if info then
        local longjingId = info.id
        local longjingItemBase = ItemUtils.GetItemBase(longjingId)
        local longjingBase = ItemUtils.GetLongJingItem(longjingId)
        bgSprite:set_spriteName(string.format("Cell_%02d", longjingItemBase.namecolor))
        GUIUtils.FillIcon(texture, longjingItemBase.icon)
        local FabaoModule = require("Main.Fabao.FabaoModule")
        warn("longjing can levelUp ~~~ ", FabaoModule.Instance():CanLongJingLevelUp(longjingId))
        if FabaoModule.Instance():CanLongJingLevelUp(longjingId) then
          arrowImg:SetActive(true)
        else
          arrowImg:SetActive(false)
        end
      else
        arrowImg:SetActive(false)
        bgSprite:set_spriteName("Cell_00")
        texture.mainTexture = nil
      end
    end
    self.m_UIObjs.DressOffBtn:SetActive(true)
  else
    for i = 1, 3 do
      local bgSprite = self.m_UIObjs.SlotGroup[i]:GetComponent("UISprite")
      local texture = self.m_UIObjs.SlotGroup[i]:FindDirect("Img_SlotIcon"):GetComponent("UITexture")
      local arrowImg = self.m_UIObjs.SlotGroup[i]:FindDirect("Img_Arrow")
      bgSprite:set_spriteName("Cell_00")
      texture.mainTexture = nil
      arrowImg:SetActive(false)
    end
    self.m_UIObjs.DressOffBtn:SetActive(false)
  end
end
def.method().UpdateRightView = function(self)
  local typeNum = 0
  if self.m_CurTypeNames then
    typeNum = #self.m_CurTypeNames
  end
  local typeItems = GUIUtils.InitUIList(self.m_UIObjs.LongJingListView, typeNum, false)
  for i = 1, typeNum do
    local typeItemObj = typeItems[i]
    local typeTitleObj = typeItemObj:FindDirect(string.format("Img_BgBuyList_%d", i))
    local typeNameLabel = typeTitleObj:FindDirect(string.format("Label_%d", i))
    local typeName = self.m_CurTypeNames[i]
    typeNameLabel:GetComponent("UILabel"):set_text(typeName)
    local subListView = typeItemObj:FindDirect(string.format("tween_%d", i))
    subListView:SetActive(true)
    local longjingNum = 0
    if self.m_CurLingjingInBag and self.m_CurLingjingInBag[typeName] then
      longjingNum = #self.m_CurLingjingInBag[typeName]
    end
    local longjingItems = GUIUtils.InitUIList(subListView, longjingNum + 1, false)
    for j = 1, longjingNum + 1 do
      local longjingItemObj = longjingItems[j]
      local nameLabel = longjingItemObj:FindDirect(string.format("Label_Name_%d_%d", i, j))
      local attrLabel = longjingItemObj:FindDirect(string.format("Label_Attribute_%d_%d", i, j))
      local bgSprite = longjingItemObj:FindDirect(string.format("Group_Icon_%d_%d/Icon_BgEquip01_%d_%d", i, j, i, j))
      local levelLabel = bgSprite:FindDirect(string.format("Label_%d_%d", i, j))
      local texture = longjingItemObj:FindDirect(string.format("Group_Icon_%d_%d/Icon_Equip01_%d_%d", i, j, i, j))
      local addImg = longjingItemObj:FindDirect(string.format("Group_Icon_%d_%d/Img_Add_%d_%d", i, j, i, j))
      if j > 1 then
        local longjingdata = self.m_CurLingjingInBag[typeName][j - 1]
        longjingItemObj.name = string.format("LongJingItem_%d", longjingdata.key)
        if longjingdata then
          addImg:SetActive(false)
          nameLabel:GetComponent("UILabel"):set_text(longjingdata.longjingName)
          levelLabel:GetComponent("UILabel"):set_text(tostring(longjingdata.number))
          if longjingdata.longjingProIds[1] then
            local attrName = FabaoUtils.GetFabaoProName(longjingdata.longjingProIds[1])
            local attrStr = string.format("%s +%d", attrName, longjingdata.longjingProValues[1])
            attrLabel:GetComponent("UILabel"):set_text(attrStr)
            attrLabel:SetActive(true)
          else
            attrLabel:GetComponent("UILabel"):set_text("")
          end
          bgSprite:GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", longjingdata.longjingNameColor))
          GUIUtils.FillIcon(texture:GetComponent("UITexture"), longjingdata.longjingIconId)
        end
      else
        longjingItemObj.name = string.format("AddLongJing_%d", j)
        addImg:SetActive(true)
        nameLabel:GetComponent("UILabel"):set_text(textRes.Fabao[44])
        levelLabel:GetComponent("UILabel"):set_text("")
        attrLabel:GetComponent("UILabel"):set_text("")
        bgSprite:GetComponent("UISprite"):set_spriteName("Cell_00")
        texture:GetComponent("UITexture").mainTexture = nil
      end
    end
    typeTitleObj:GetComponent("UIPlayTween").enabled = false
    if self.m_IsFirstShow then
      subListView:SetActive(false)
    end
  end
  self.m_IsFirstShow = false
  self.m_base.m_msgHandler:Touch(self.m_UIObjs.LongJingListView)
  GUIUtils.Reposition(self.m_UIObjs.LongJingListView, "UIList", 0.01)
  local Vector = require("Types.Vector")
  self.m_UIObjs.LongJingListView.transform:set_localPosition(Vector.Vector3.new(-89, 210, 0))
end
def.method().RepostionLongjingList = function(self)
  self:Update()
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if string.find(id, "Img_BgBuyList_") then
    self:OnClickStretchLongJingList(clickObj)
  elseif "Btn_HeCheng" == id then
    self:OnClickHeChengBtn()
  elseif "Btn_DressOff" == id then
    self:OnClickDressOffAll()
  elseif string.find(id, "LongJingItem_") then
    self:OnClickLongjingItem(clickObj)
  elseif string.find(id, "AddLongJing_") then
    self:OnClickAddLongjingItem(clickObj)
  elseif string.find(id, "Img_Add_") then
    self:OnClickAddLongjingItem(clickObj.parent.parent)
  elseif string.find(id, "Img_Slot_") then
    self:OnClickMountLongjingItem(clickObj)
  elseif "Group_Xiangxing" == clickObj.parent.name then
    self:OnClickXiangXingBtn(clickObj)
  end
end
def.method("userdata").OnClickXiangXingBtn = function(self, clickObj)
  local name = clickObj.name
  local fabaoType = TypeId[name]
  if nil == fabaoType then
    return
  end
  if fabaoType == self.m_CurType then
    return
  end
  self.m_CurType = fabaoType
  self.m_IsFirstShow = true
  self:UpdateData()
  self:UpdateLeftView()
  self:UpdateRightView()
end
def.method("userdata").OnClickMountLongjingItem = function(self, clickObj)
  local name = clickObj.name
  local strs = string.split(name, "_")
  local pos = tonumber(strs[3])
  local longjingInfo = FabaoData.Instance():GetLongJingByTypeAndPos(self.m_CurType, pos)
  if longjingInfo then
    local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
    ItemTipsMgr.Instance():ShowLongJingSpecialTips(longjingInfo, self.m_CurType, pos, false, 0, 0, 0, 0, 0, false)
  else
    Toast(textRes.Fabao[89])
  end
end
def.method("userdata").OnClickAddLongjingItem = function(self, clickObj)
  local topName = clickObj.parent.parent.name
  local strs = string.split(topName, "_")
  local index = tonumber(strs[3])
  local typeName = self.m_CurTypeNames[index]
  if typeName then
    local longjingCfg = FabaoUtils.GetLongjingIdByTypeName(typeName)
    if longjingCfg and #longjingCfg > 0 then
      local id = longjingCfg[1].id
      if id then
        self:ShowGetItemTips(clickObj, "UIWidget", id)
      end
    end
  end
end
def.method("userdata").OnClickLongjingItem = function(self, clickObj)
  local name = clickObj.name
  local strs = string.split(name, "_")
  local key = tonumber(strs[2])
  local fabaoType = self.m_CurType
  local isFull, pos = FabaoData.Instance():IsLongjingFullOnType(fabaoType)
  if isFull then
    Toast(textRes.Fabao[88])
    return
  end
  FabaoModule.RequestLongjingMount(key, pos)
end
def.method().OnClickDressOffAll = function(self)
  local isEmpty = FabaoData.Instance():IsLongjingEmptyOnType(self.m_CurType)
  warn("longjing is empty ", isEmpty, self.m_CurType)
  if isEmpty then
    return
  end
  FabaoModule.RequestUnMountAllLongjing(self.m_CurType)
end
def.method().OnClickHeChengBtn = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local LongJingCombinePanel = require("Main.Fabao.ui.LongJingCombinePanel")
  LongJingCombinePanel.Instance():ShowPanel()
end
def.method("userdata").OnClickStretchLongJingList = function(self, clickObj)
  local strs = string.split(clickObj.name, "_")
  local index = tonumber(strs[3])
  local subListView = clickObj.parent:FindDirect(string.format("tween_%d", index))
  if subListView and not subListView.isnil then
    if subListView:get_activeInHierarchy() then
      subListView:SetActive(false)
    else
      subListView:SetActive(true)
    end
  end
  GUIUtils.Reposition(self.m_UIObjs.LongJingListView, "UIList", 0.01)
end
def.method("userdata", "string", "number").ShowGetItemTips = function(self, obj, comName, itemid)
  local position = obj.position
  local screenPosition = WorldPosToScreen(position.x, position.y)
  local sprite = obj:GetComponent(comName)
  local width = sprite:get_width()
  local height = sprite:get_height()
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  ItemTipsMgr.Instance():ShowBasicTips(itemid, screenPosition.x, screenPosition.y, width, height, 0, true)
end
def.method("number", "number").OnLongjingMountSucc = function(self, itemid, pos)
  local fxObj = self.m_node:FindDirect(string.format("Group_Slot/Img_Slot_%d/Img_SlotIcon", pos))
  if fxObj and not fxObj.isnil then
    require("Fx.GUIFxMan").Instance():PlayAsChild(fxObj, RESPATH.PANEL_FABAO_XQ_EFFECT, 0, 0, -1, false)
  end
end
FabaoXQNode.Commit()
return FabaoXQNode
