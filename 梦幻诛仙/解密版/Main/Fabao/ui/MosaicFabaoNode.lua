local Lplus = require("Lplus")
local Vector = require("Types.Vector")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local MallModule = require("Main.Mall.MallModule")
local MallPanel = require("Main.Mall.ui.MallPanel")
local FabaoMgr = require("Main.Fabao.FabaoMgr")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local FabaoPanelNodeBase = require("Main.Fabao.ui.FabaoPanelNodeBase")
local EquipModule = require("Main.Equip.EquipModule")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local SkillUtility = require("Main.Skill.SkillUtility")
local Formulation = require("Main.Common.Formulation")
local SkillMgr = require("Main.Skill.SkillMgr")
local FabaoUtils = require("Main.Fabao.FabaoUtils")
local MosaicFabaoNode = Lplus.Extend(FabaoPanelNodeBase, "MosaicFabaoNode")
local def = MosaicFabaoNode.define
def.const("number").MAXNUM = FabaoMgr.GetFabaoConstant("FABAO_MAX_HOLE")
def.field("boolean").m_Toggle = true
def.field("number").m_HoleCount = 0
def.field("number").m_CurSlot = 0
def.field("number").m_ItemTypeNum = 0
def.field("number").m_CurLJType = 1
def.field("table").m_ListData = nil
def.field("table").m_ListDataEx = nil
def.field("table").m_ListSlotGO = nil
def.field("table").m_ClickGO = nil
def.field("table").m_DynamicData = nil
local instance
def.static("=>", MosaicFabaoNode).Instance = function()
  if not instance then
    instance = MosaicFabaoNode()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  FabaoPanelNodeBase.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:Update()
  self:Reposition()
  Event.RegisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.MOUNT_SUCCESS, MosaicFabaoNode.OnMountSuccess)
  Event.RegisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.UNMOUNT_SUCCESS, MosaicFabaoNode.OnUnMountSuccess)
end
def.override().OnHide = function(self)
  self:Clear()
  Event.UnregisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.MOUNT_SUCCESS, MosaicFabaoNode.OnMountSuccess)
  Event.UnregisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.UNMOUNT_SUCCESS, MosaicFabaoNode.OnUnMountSuccess)
end
def.override().InitUI = function(self)
  FabaoPanelNodeBase.InitUI(self)
  self.m_UIGO = {}
  self.m_UIGO.ScorllView = self.m_node:FindDirect("Group_Bag/Img_BgBag/Scroll View")
  self.m_UIGO.Table_BugList = self.m_node:FindDirect("Group_Bag/Img_BgBag/Scroll View/Table_BugList")
  self.m_UIGO.Grid_List = self.m_node:FindDirect("Grid_List")
  self.m_UIGO.Label_Effect = self.m_node:FindDirect("Label_Title/Label_Effect")
end
def.override().Clear = function(self)
  self.m_Toggle = true
  self.m_HoleCount = 0
  self.m_CurSlot = 0
  self.m_ItemTypeNum = 0
  self.m_DynamicData = nil
  self.m_ListData = nil
  self.m_ListDataEx = nil
  self.m_ListSlotGO = nil
  self.m_ClickGO = nil
  FabaoPanelNodeBase.Clear(self)
end
def.override("=>", "boolean").IsUnlock = function(self)
  return true
end
def.method().CombineLongJing = function(self)
  Event.DispatchEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.BTN_COMBINE_CLICK, nil)
end
def.method().CombineWiki = function(self)
  Event.DispatchEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.BTN_WIKI_CLICK, nil)
end
def.method().GetLongJing = function(self)
  Event.DispatchEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.LJINFO_GET_BTN, nil)
end
def.method("=>", "number").FindProperSlot = function(self)
  if not self.m_ListSlotGO then
    return -1
  end
  local ljItem = self.m_ListSlotGO[self.m_CurSlot + 1]
  if ljItem then
    return self.m_CurSlot
  end
  for k, v in pairs(self.m_ListSlotGO) do
    if v then
      return k - 1
    end
  end
  return -1
end
def.method("userdata").Mount = function(self, longjingid)
  local slot = self:FindProperSlot()
  if slot == -1 then
    Toast(textRes.Fabao[57])
    return
  end
  self.m_CurSlot = slot
  local params = {}
  params.longjingid = longjingid
  params.fabaobagid = self.m_Item.bagType
  params.fabaoitemid = self.m_DynamicData.itemKey
  params.pos = slot
  FabaoMgr.Mount(params)
  if _G.PlayerIsInFight() then
    Toast(textRes.Fabao[56])
  end
end
def.method().UnMount = function(self)
  local params = {}
  params.bagid = self.m_Item.bagType
  params.fabaoid = self.m_DynamicData.itemKey
  params.pos = self.m_CurSlot
  FabaoMgr.UnMount(params)
  if _G.PlayerIsInFight() then
    Toast(textRes.Fabao[56])
  end
end
def.override("string").onClick = function(self, id)
  if id == "Btn_Get" then
    self:GetLongJing()
  elseif id == "Btn_HeCheng" then
    self:CombineLongJing()
  elseif id == "Btn_ZuHeDaQuan" then
    self:CombineWiki()
  elseif id:find("Img_BgBuyList_") == 1 then
    local uiListGO = self.m_UIGO.Table_BugList
    GUIUtils.Reposition(uiListGO, GUIUtils.COTYPE.LIST, 0.05)
    local _, lastIndex = id:find("Img_BgBuyList_")
    local index = tonumber(id:sub(lastIndex + 1, id:len()))
    if self.m_ListDataEx[index] and #self.m_ListDataEx[index] == 0 then
      Toast(textRes.Fabao[28])
    end
  elseif id:find("Btn_Delete_") == 1 then
    local _, lastIndex = id:find("Btn_Delete_")
    local index = tonumber(id:sub(lastIndex + 1, id:len()))
    self.m_CurSlot = index - 1
    self:UnMount()
  elseif id:find("Group_ListSlot1_") == 1 then
    local _, lastIndex = id:find("Group_ListSlot1_")
    local index = tonumber(id:sub(lastIndex + 1, id:len()))
    if index > self.m_HoleCount then
      Toast(textRes.Fabao[34])
      return
    end
    local uiListGO = self.m_UIGO.Grid_List
    GUIUtils.Toggle(uiListGO:FindDirect(id), true)
    self.m_CurSlot = index - 1
  elseif id:find("Group_LJItem_") == 1 then
    local index = 0
    local temp = {}
    for v in id:gmatch("%d+") do
      index = index + 1
      temp[index] = tonumber(v)
    end
    local longjingid = self.m_ListDataEx[temp[1]][temp[2]]
    self.m_CurLJType = temp[1]
    if temp[2] ~= 1 then
      self:Mount(longjingid)
    else
      local btnGO = self.m_ClickGO[temp[1]][temp[2]]
      if not longjingid or not btnGO then
        return
      end
      ItemTipsMgr.Instance():ShowBasicTipsWithGO(longjingid, btnGO, -1, true)
    end
  end
end
def.static("table", "table").OnMountSuccess = function(params)
  local go = instance.m_ListSlotGO[instance.m_CurSlot + 1]
  if go and not go.isnil then
    require("Fx.GUIFxMan").Instance():PlayAsChild(go, RESPATH.PANEL_FABAO_XQ_EFFECT, 0, 0, -1, false)
  end
  warn("OnMountSuccess", params.groupid)
  instance.m_Toggle = false
  if params.groupid ~= 0 then
  end
end
def.static("table", "table").OnUnMountSuccess = function(params)
  warn("OnUnMountSuccess", params.groupid)
  instance.m_Toggle = false
  if params.groupid == 0 then
  end
end
def.override("table").UpdateItem = function(self, item)
  FabaoPanelNodeBase.UpdateItem(self, item)
end
def.method().UpdateData = function(self)
  if not self.m_Item then
    return
  end
  self.m_DynamicData = ItemModule.Instance():GetItemByBagIdAndItemKey(self.m_Item.bagType, self.m_Item.data.dynamicData.itemKey)
  self.m_HoleCount = self.m_DynamicData.extraMap[ItemXStoreType.FABAO_HOLE_COUNT]
  self:UpdateListData()
end
def.method().UpdateListData = function(self)
  local items = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, ItemType.FABAO_LONGJING_ITEM)
  local itemDatas = FabaoMgr.GetAllLongJingItems()
  local temp = {}
  for k, v in pairs(itemDatas) do
    local cfg = ItemUtils.GetLongJingItem(v)
    temp[cfg.attrId] = {}
    temp[cfg.attrId].id = cfg.id
  end
  for k, v in pairs(items) do
    local cfg = ItemUtils.GetLongJingItem(v.id)
    if not temp[cfg.attrId][cfg.id] then
      temp[cfg.attrId][cfg.id] = {}
      temp[cfg.attrId][cfg.id].id = cfg.id
      temp[cfg.attrId][cfg.id].uuid = v.uuid[1]
      temp[cfg.attrId][cfg.id].totalNum = v.number
    else
      temp[cfg.attrId][cfg.id].totalNum = temp[cfg.attrId][cfg.id].totalNum + v.number
    end
  end
  self.m_ListDataEx = {}
  self.m_ClickGO = {}
  self.m_ListData = temp
  self.m_ItemTypeNum = #itemDatas
end
def.method().Reposition = function(self)
  local uiListGO = self.m_UIGO.Table_BugList
  local scrollViewGO = self.m_UIGO.ScorllView
  GUIUtils.Reposition(uiListGO, GUIUtils.COTYPE.LIST, 0)
end
def.method().UpdateTopMiddleView = function(self)
  local effectGO = self.m_UIGO.Label_Effect
  local combineID = self.m_DynamicData.extraMap[ItemXStoreType.FABAO_LJ_GROUP_ID]
  local desc = FabaoUtils.GetLongJingGroupAttrDesc(combineID)
  if desc == "" then
    desc = textRes.Fabao[45]
  end
  GUIUtils.SetText(effectGO, desc)
end
def.method().UpdateBottomMiddleView = function(self)
  self.m_ListSlotGO = {}
  local longJingFristIndex = ItemXStoreType.FABAO_LONGJING_ID_1 - 1
  local uiListGO = self.m_UIGO.Grid_List
  local itemCount = MosaicFabaoNode.MAXNUM
  local listItems = GUIUtils.InitUIList(uiListGO, itemCount)
  self.m_base.m_msgHandler:Touch(uiListGO)
  for i = 1, itemCount do
    local itemGO = listItems[i]
    local nameGO = itemGO:FindDirect(("Label_Name_%d"):format(i))
    local btnGO = itemGO:FindDirect(("Btn_Delete_%d"):format(i))
    local attiGO = itemGO:FindDirect(("Label_Attribute_%d"):format(i))
    local iconGO = itemGO:FindDirect(("Group_Icon_%d/Icon_Equip01_%d"):format(i, i))
    local addGO = itemGO:FindDirect(("Group_Icon_%d/Img_Add_%d"):format(i, i))
    local lockGO = itemGO:FindDirect(("Group_Icon_%d/Img_Lock_%d"):format(i, i))
    local groupStarGO = itemGO:FindDirect(("Group_Star_%d/List_Star_%d"):format(i, i))
    local selectGO = itemGO:FindDirect(("Img_Select_%d"):format(i))
    local name = ""
    local attri = ""
    local longJingId = self.m_DynamicData.extraMap[longJingFristIndex + i]
    if i <= self.m_HoleCount then
      if longJingId > 0 then
        local itemBase = ItemUtils.GetItemBase(longJingId)
        name = ("%s"):format(itemBase.name)
        attri = FabaoUtils.GetLongJingAttrDesc(longJingId)
        GUIUtils.SetTexture(iconGO, itemBase.icon)
        self.m_ListSlotGO[i] = nil
      else
        name = textRes.Fabao[8]
        self.m_ListSlotGO[i] = iconGO
      end
      GUIUtils.Toggle(itemGO, i == self.m_CurSlot + 1)
    else
      name = textRes.Fabao[9]
    end
    GUIUtils.SetActive(attiGO, i <= self.m_HoleCount and longJingId ~= 0)
    GUIUtils.SetActive(selectGO, i <= self.m_HoleCount)
    GUIUtils.SetActive(btnGO, i <= self.m_HoleCount and longJingId ~= 0)
    GUIUtils.SetActive(addGO, i <= self.m_HoleCount and longJingId == 0)
    GUIUtils.SetActive(lockGO, i > self.m_HoleCount)
    GUIUtils.SetActive(groupStarGO, i > self.m_HoleCount)
    GUIUtils.SetText(nameGO, name)
    GUIUtils.SetText(attiGO, attri)
    GUIUtils.InitUIList(groupStarGO, 2 <= i - 2 and i - 2 or 1)
    GUIUtils.Reposition(groupStarGO, GUIUtils.COTYPE.LIST, 0)
  end
  GUIUtils.Reposition(uiListGO, GUIUtils.COTYPE.LIST, 0)
end
def.method("number", "table").UpdateListInternal = function(self, index, itemData)
  local count = 0
  local itemDatas = {}
  for k, v in pairs(itemData) do
    if type(v) == "table" then
      count = count + 1
      itemDatas[count] = v
    end
  end
  table.sort(itemDatas, function(l, r)
    local lCfg = ItemUtils.GetLongJingItem(l.id)
    local rCfg = ItemUtils.GetLongJingItem(r.id)
    return lCfg.lv > rCfg.lv
  end)
  local uiListGO = self.m_node:FindDirect(("Group_Bag/Img_BgBag/Scroll View/Table_BugList/Tab_1_%d/tween_%d"):format(index, index))
  GUIUtils.SetActive(uiListGO, true)
  local listItems = GUIUtils.InitUIList(uiListGO, count + 1)
  self.m_base.m_msgHandler:Touch(uiListGO)
  for i = 1, count + 1 do
    local itemGO = listItems[i]
    local nameGO = itemGO:FindDirect(("Label_Name_%d_%d"):format(index, i))
    local attriGO = itemGO:FindDirect(("Label_Attribute_%d_%d"):format(index, i))
    local lconGO = itemGO:FindDirect(("Group_Icon_%d_%d/Icon_Equip01_%d_%d"):format(index, i, index, i))
    local labelGO = itemGO:FindDirect(("Group_Icon_%d_%d/Icon_BgEquip01_%d_%d/Label_%d_%d"):format(index, i, index, i, index, i))
    local addGO = itemGO:FindDirect(("Group_Icon_%d_%d/Img_Add_%d_%d"):format(index, i, index, i))
    if i > 1 then
      local itemData = itemDatas[i - 1]
      if itemData then
        local itemBase = ItemUtils.GetItemBase(itemData.id)
        local desc = FabaoUtils.GetLongJingAttrDesc(itemData.id)
        self.m_ListDataEx[index][i] = itemData.uuid
        GUIUtils.SetText(nameGO, ("%s"):format(itemBase.name))
        GUIUtils.SetActive(attriGO, true)
        GUIUtils.SetText(attriGO, desc)
        GUIUtils.SetText(labelGO, tostring(itemData.totalNum))
        GUIUtils.SetTexture(lconGO, itemBase.icon)
        GUIUtils.SetActive(addGO, false)
      end
    else
      GUIUtils.SetActive(addGO, true)
      GUIUtils.SetActive(labelGO, false)
      GUIUtils.SetActive(attriGO, false)
      GUIUtils.SetText(nameGO, textRes.Fabao[44])
      GUIUtils.SetCollider(addGO, false)
      self.m_ListDataEx[index][i] = itemData.id
      self.m_ClickGO[index][i] = itemGO
    end
  end
  GUIUtils.Reposition(uiListGO, GUIUtils.COTYPE.LIST, 0.1)
end
def.method().UpdateRightView = function(self)
  local uiListGO = self.m_UIGO.Table_BugList
  local scrollViewGO = self.m_UIGO.ScorllView
  local itemCount = self.m_ItemTypeNum
  local listItems = GUIUtils.InitUIList(uiListGO, itemCount)
  self.m_base.m_msgHandler:Touch(uiListGO)
  local index = 0
  for k, v in pairs(self.m_ListData) do
    index = index + 1
    local itemGO = listItems[index]
    local imgBgGO = itemGO:FindDirect(("Img_BgBuyList_%d"):format(index))
    local tweenGO = itemGO:FindDirect(("tween_%d"):format(index))
    local labelGO = itemGO:FindDirect(("Img_BgBuyList_%d/Label_%d"):format(index, index))
    local itemBase = ItemUtils.GetItemBase(v.id)
    self.m_ListDataEx[index] = {}
    self.m_ClickGO[index] = {}
    GUIUtils.SetText(labelGO, StrSub(itemBase.name, 3, 5))
    GUIUtils.Toggle(imgBgGO, index == self.m_CurLJType)
    self:UpdateListInternal(index, v)
    GUIUtils.SetActive(tweenGO, not self.m_Toggle)
  end
  GUIUtils.DragToMakeVisible(scrollViewGO, listItems[self.m_CurLJType], 0.2, 20)
end
def.method().Update = function(self)
  self:UpdateData()
  self:UpdateBottomMiddleView()
  self:UpdateTopMiddleView()
  self:UpdateRightView()
end
def.method().OnClickLeftFaBaoItem = function(self)
end
return MosaicFabaoNode.Commit()
