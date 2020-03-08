local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgUpdateSkill = Lplus.Extend(ECPanelBase, "DlgUpdateSkill")
local GUIUtils = require("GUI.GUIUtils")
local def = DlgUpdateSkill.define
local instance
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetUtility = require("Main.Pet.PetUtility")
local ChildrenDataMgr = require("Main.Children.ChildrenDataMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local Vector = require("Types.Vector3")
local SkillUtility = require("Main.Skill.SkillUtility")
def.field("userdata").childId = nil
def.field("number").skillIndex = 0
def.field("number").selectedSkillIdx = 1
def.field("number").selectedItemIndex = 0
def.field("table").itemList = nil
def.field("table").uiObjs = nil
def.static("=>", DlgUpdateSkill).Instance = function()
  if instance == nil then
    instance = DlgUpdateSkill()
  end
  return instance
end
def.method("userdata").ShowPanel = function(self, childId)
  if self.m_panel ~= nil then
    return
  end
  self.childId = childId
  self:CreatePanel(RESPATH.PREFAB_CHILD_SKILL_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:ShowSkillAndBag()
  self:ShowYouthChildScore()
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Img_BgPower = self.uiObjs.Img_Bg0:FindDirect("0")
  self.uiObjs.Img_Bg1 = self.uiObjs.Img_Bg0:FindDirect("Img_Bg1")
  self.uiObjs.Img_BgSkill = self.uiObjs.Img_Bg1:FindDirect("Img_BgSkill")
  self.uiObjs.Grid_ItemSkill = self.uiObjs.Img_BgSkill:FindDirect("Gride_ItemSkill")
  self.uiObjs.Group_Remember = self.uiObjs.Img_BgSkill:FindDirect("Group_Remember")
  self.uiObjs.Group_Remove = self.uiObjs.Img_BgSkill:FindDirect("Group_Remove")
  self.uiObjs.fxObj = self.m_panel:FindDirect("UI_Panel_PetSkill_ChongWuDaShu")
  self.uiObjs.Group_Bag = self.uiObjs.Img_Bg1:FindDirect("Group_Bag")
  self.uiObjs.Img_BgBag = self.uiObjs.Group_Bag:FindDirect("Img_Bg")
  self.uiObjs.List_Bag = self.uiObjs.Group_Bag:FindDirect("Scrollview_Bag/List_Bag")
  self.uiObjs.Btn_Learn = self.uiObjs.Group_Bag:FindDirect("Btn_Learn")
  self.uiObjs.Group_Empty = self.uiObjs.Img_Bg1:FindDirect("Group_Empty")
  self.uiObjs.GridItemTemplate = self.uiObjs.Grid_ItemSkill:FindDirect("Img_ItemSkill01")
  self.uiObjs.Group_Score = self.uiObjs.Img_Bg0:FindDirect("Group_Score")
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Common_Skill_Updated, DlgUpdateSkill.Refresh)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, DlgUpdateSkill.OnBagInfoSynchronized)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.CHILD_SCORE_CHANGE, DlgUpdateSkill.OnChildScoreChange)
end
def.override().OnDestroy = function(self)
  self.childId = nil
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Common_Skill_Updated, DlgUpdateSkill.Refresh)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, DlgUpdateSkill.OnBagInfoSynchronized)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.CHILD_SCORE_CHANGE, DlgUpdateSkill.OnChildScoreChange)
end
def.static("table", "table").Refresh = function(p1, p2)
  instance:UpdateSkillList()
end
def.static("table", "table").OnBagInfoSynchronized = function(p1, p2)
  instance:UpdateSkillBooks()
end
def.static("table", "table").OnChildScoreChange = function(p1, p2)
  instance:TweenYouthChildScore(p1)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Remove" then
    self:OnUnrememberButtonClick()
  elseif string.sub(id, 1, 13) == "Img_ItemSkill" then
    local index = tonumber(string.sub(id, -2, -1))
    self:OnSkillItemClick(index)
  elseif string.sub(id, 1, #"Img_Item_") == "Img_Item_" then
    local index = tonumber(string.sub(id, #"Img_Item_" + 1, -1))
    self:OnSkillBookItemClick(index)
  elseif id == "Btn_Channel" then
    self:OnRequirePetSkillBookSource()
  elseif id == "Btn_Learn" then
    self:OnLearnSkillButtonClicked()
  elseif id == "Btn_Promote" then
    self:OnPromoteButtonClicked()
  end
end
def.method().ShowSkillAndBag = function(self)
  self:UpdateSkillList()
  local grid = self.uiObjs.Grid_ItemSkill:GetComponent("UIGrid")
  local gridItemCount = grid:GetChildListCount()
  local gridChildList = grid:GetChildList()
  for i = 1, gridItemCount do
    gridChildList[i].gameObject:GetComponent("UIToggle"):set_value(i == 1)
  end
  self:UpdateSkillBooks()
  self.selectedSkillIdx = 1
end
def.method().UpdateSkillList = function(self)
  local child_data = ChildrenDataMgr.Instance():GetChildById(self.childId)
  if child_data == nil then
    return
  end
  local grid = self.uiObjs.Grid_ItemSkill:GetComponent("UIGrid")
  local skill_max_count = constant.CChildrenConsts.child_init_skill_pos_max + child_data.info.unLockSkillPosNum
  self:ResizeGrid(grid, skill_max_count)
  local gridChildList = grid:GetChildList()
  for i = 1, skill_max_count do
    local skillId = child_data.info.skillBookSkills[i]
    local objIndex = string.format("%02d", i)
    if skillId then
      local skillCfg = PetUtility.Instance():GetPetSkillCfg(skillId)
      local uiTexture = gridChildList[i].gameObject:FindDirect(string.format("Icon_ItemSkillIcon%02d", objIndex)):GetComponent("UITexture")
      GUIUtils.FillIcon(uiTexture, skillCfg.iconId)
      PetUtility.SetPetSkillBgColor(gridChildList[i].gameObject, skillId)
    else
      local uiTexture = gridChildList[i].gameObject:FindDirect(string.format("Icon_ItemSkillIcon%02d", objIndex)):GetComponent("UITexture")
      uiTexture.mainTexture = nil
    end
  end
end
def.method("userdata", "number").ResizeGrid = function(self, uiGrid, count)
  if uiGrid == nil then
    return
  end
  local gridItemCount = uiGrid:GetChildListCount()
  if count > gridItemCount then
    for i = gridItemCount + 1, count do
      local gridItem = GameObject.Instantiate(self.uiObjs.GridItemTemplate)
      gridItem.name = string.format("Img_ItemSkill%02d", i)
      gridItem:FindDirect("Icon_ItemSkillIcon01").name = string.format("Icon_ItemSkillIcon%02d", i)
      gridItem.transform.parent = self.uiObjs.Grid_ItemSkill.transform
      gridItem.transform.localScale = Vector.Vector3.one
      gridItem:SetActive(true)
    end
  elseif count < gridItemCount then
    for i = gridItemCount, count + 1, -1 do
      local gridItem = self.uiObjs.Grid_ItemSkill:FindDirect(string.format("Img_ItemSkill%02d", i))
      gridItem.transform.parent = nil
      GameObject.Destroy(gridItem)
    end
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
  uiGrid:Reposition()
end
def.method().UpdateSkillBooks = function(self)
  self.itemList = PetMgr.Instance():GetPetSkillBooks()
  if #self.itemList > 0 then
    if self.uiObjs.Group_Empty then
      self.uiObjs.Group_Empty:SetActive(false)
    end
    self.uiObjs.Group_Bag:SetActive(true)
    self:ShowPetSkillBookBag()
  else
    if self.uiObjs.Group_Empty then
      self.uiObjs.Group_Empty:SetActive(true)
    end
    self.uiObjs.Group_Bag:SetActive(false)
  end
end
def.method().ShowPetSkillBookBag = function(self)
  self:ResizeItemBag(#self.itemList)
  for i = 1, #self.itemList do
    self:SetItemBagItem(i)
  end
end
def.method("number").ResizeItemBag = function(self, count)
  local uiList = self.uiObjs.List_Bag:GetComponent("UIList")
  uiList.itemCount = count
  uiList:Resize()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("number").SetItemBagItem = function(self, index)
  local item = self.itemList[index]
  if item == nil then
    return
  end
  local itemPanel = self.uiObjs.List_Bag:FindDirect("Img_Item_" .. index)
  local itemNum = item.number
  if itemNum == 0 then
    itemNum = ""
  end
  GUIUtils.SetText(itemPanel:FindDirect("Label_Num_" .. index), itemNum)
  local bang = itemPanel:FindDirect("Img_Bang_" .. index)
  local zhuan = itemPanel:FindDirect("Img_Zhuan_" .. index)
  local rarity = itemPanel:FindDirect("Img_Xiyou_" .. index)
  local itemBase = ItemUtils.GetItemBase(item.id)
  if bang and zhuan then
    warn(">>>is rarity = " .. tostring(ItemUtils.IsRarity(item.id)), "| is bang = " .. tostring(ItemUtils.IsItemBind(item)), " isProprietary = " .. tostring(itemBase.isProprietary))
    if itemBase.isProprietary then
      bang:SetActive(false)
      zhuan:SetActive(true)
      GUIUtils.SetActive(rarity, false)
    elseif ItemUtils.IsItemBind(item) then
      bang:SetActive(true)
      zhuan:SetActive(false)
      GUIUtils.SetActive(rarity, false)
    elseif ItemUtils.IsRarity(item.id) then
      bang:SetActive(false)
      zhuan:SetActive(false)
      GUIUtils.SetActive(rarity, true)
    else
      bang:SetActive(false)
      zhuan:SetActive(false)
      GUIUtils.SetActive(rarity, false)
    end
  end
  local itemBase = ItemUtils.GetItemBase(item.id)
  local iconId = itemBase.icon
  local uiTexture = itemPanel:FindDirect("Icon_ItemIcon01_" .. index):GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, iconId)
end
def.method().ShowYouthChildScore = function(self)
  local ChildrenUtils = require("Main.Children.ChildrenUtils")
  local child_data = ChildrenDataMgr.Instance():GetChildById(self.childId)
  if child_data == nil then
    ChildrenUtils.SetYouthChildScore(self.uiObjs.Group_Score, 0)
  else
    ChildrenUtils.SetYouthChildScore(self.uiObjs.Group_Score, child_data:CalYouthChildScore())
  end
end
def.method("table").TweenYouthChildScore = function(self, params)
  if Int64.eq(self.childId, params.childId) then
    local ChildrenUtils = require("Main.Children.ChildrenUtils")
    ChildrenUtils.TweenYouthChildScore(self.uiObjs.Group_Score, params.preScore, params.nowScore)
  end
end
def.method().OnRequirePetSkillBookSource = function(self)
  self:ShowSkillBookSource()
end
def.method().OnLearnSkillButtonClicked = function(self)
  self:LearnSkillFromBook()
end
def.method().LearnSkillFromBook = function(self)
  local items = PetMgr.Instance():GetPetSkillBooks()
  if #items == 0 then
    Toast(textRes.Pet[102])
    return
  end
  if self.selectedItemIndex == 0 then
    Toast(textRes.Pet[101])
    return
  end
  local item = self.itemList[self.selectedItemIndex]
  if item == nil then
    return
  end
  self:UsePetSkillBook(item.itemKey)
end
def.method("number").UsePetSkillBook = function(self, itemKey)
  local child_data = ChildrenDataMgr.Instance():GetChildById(self.childId)
  local ItemModule = require("Main.Item.ItemModule")
  local skillBook = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.BAG, itemKey)
  if skillBook == nil then
    warn("skill bool not found for itemKey : ", itemKey)
    return
  end
  local skillBookCfg = PetUtility.GetPetSkillBookItemCfg(skillBook.id)
  local skillId = skillBookCfg.skillId
  local canStudySkillBook = true
  for i, id in ipairs(child_data.info.skillBookSkills) do
    if skillId == id then
      canStudySkillBook = false
      break
    end
  end
  if not canStudySkillBook then
    Toast(textRes.Children[3046])
    return
  end
  local function sendpro()
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.Children.CStudyCommonSkillReq").new(self.childId, itemKey, self.selectedSkillIdx - 1))
  end
  local curSkillId = child_data.info.skillBookSkills[self.selectedSkillIdx]
  if curSkillId then
    local curSkillCfg = SkillUtility.GetSkillCfg(curSkillId)
    local tarSkillCfg = SkillUtility.GetSkillCfg(skillBookCfg.skillId)
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm("", string.format(textRes.Children[3052], curSkillCfg.name, tarSkillCfg.name), function(id, tag)
      if id == 1 then
        sendpro()
      end
    end, nil)
  else
    sendpro()
  end
end
def.method().UnSelectSkillBook = function(self)
  local selectedItem = self.uiObjs.List_Bag:FindDirect("Img_Item_" .. self.selectedItemIndex)
  if selectedItem then
    selectedItem:GetComponent("UIToggle"):set_value(false)
  end
  self.selectedItemIndex = 0
end
def.method("userdata", "number").ShowItemTip = function(self, sourceObj, index)
  local item = self.itemList[index]
  if item == nil then
    return
  end
  local itemId = item.id
  local itemKey = item.itemKey
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = sourceObj:GetComponent("UIWidget")
  local tip = ItemTipsMgr.Instance():ShowTips(item, 0, itemKey, ItemTipsMgr.Source.Other, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
end
def.method().ShowSkillBookSource = function(self)
  local sourceObj = self.uiObjs.Group_Empty:FindDirect("Btn_Channel")
  local sourceItemId = PetMgr.SKILL_BOOK_SOURCE_ITEM_ID
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = sourceObj:GetComponent("UIWidget")
  local ItemAccessMgr = require("Main.Item.ItemAccessMgr")
  local tip = ItemAccessMgr.Instance():ShowSource(sourceItemId, 207, 153, 0, 0, 0)
end
def.method("number").OnSkillBookItemClick = function(self, index)
  local item = self.itemList[index]
  if item == nil then
    return
  end
  self:UnSelectSkillBook()
  self.selectedItemIndex = index
  local obj = self.uiObjs.List_Bag:FindDirect("Img_Item_" .. index)
  self:ShowItemTip(obj, index)
  GUIUtils.Toggle(obj, true)
end
def.method("number").OnSkillItemClick = function(self, index)
  self.selectedSkillIdx = index
  local child_data = ChildrenDataMgr.Instance():GetChildById(self.childId)
  local skillId = child_data.info.skillBookSkills[index]
  if skillId == nil then
    return
  end
  local sourceObj = self.uiObjs.Grid_ItemSkill:FindDirect(string.format("Img_ItemSkill%02d", index))
  local context = {
    skill = {id = skillId, isOwnSkill = true},
    needRemember = true
  }
  PetUtility.ShowPetSkillTipEx(skillId, 1, sourceObj, 0, context)
end
DlgUpdateSkill.Commit()
return DlgUpdateSkill
