local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ChatInputDlg = Lplus.Extend(ECPanelBase, "ChatInputDlg")
local def = ChatInputDlg.define
local GUIUtils = require("GUI.GUIUtils")
local ChatModule = Lplus.ForwardDeclare("ChatModule")
local Vector = require("Types.Vector")
local MainUIChat = require("Main.MainUI.ui.MainUIChat")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local MathHelper = require("Common.MathHelper")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local PetInterface = require("Main.Pet.Interface")
local PetUtility = require("Main.Pet.PetUtility")
local PubroleInterface = require("Main.Pubrole.PubroleInterface")
local ChatMemo = require("Main.Chat.ChatMemo")
local WingInterface = require("Main.Wing.WingInterface")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local FashionData = require("Main.Fashion.FashionData")
local FashionUtils = require("Main.Fashion.FashionUtils")
local ChildrenInterface = require("Main.Children.ChildrenInterface")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local AtUtils = require("Main.Chat.At.AtUtils")
local ChatInputMgr = require("Main.Chat.ChatInputMgr")
local AircraftInterface = require("Main.Aircraft.AircraftInterface")
local TurnedCardInterface = require("Main.TurnedCard.TurnedCardInterface")
local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
local ItemData = require("Main.Item.ItemData")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local instance
def.const("table").Type = {Chat = 1, Main = 2}
def.const("table").StateConst = {
  Emoji = 1,
  Mood = 2,
  Inventory = 3,
  Pet = 4,
  Task = 5,
  History = 6,
  Fabao = 7,
  ChatAt = 8,
  RedGift = 9,
  ChengWei = 10,
  Touxian = 11,
  Mounts = 12,
  Children = 13,
  TurnedCard = 14
}
def.field("boolean").loaded = false
def.field("table").emojis = nil
def.field("table").emojisMap = nil
def.field("number").emojiCount = 0
def.field("number").emojiPage = 21
def.field("table").moods = nil
def.field("number").moodsCount = 0
def.field("number").moodPage = 16
def.field("number").itemPage = 24
def.field("number").petPage = 4
def.field("number").taskPage = 8
def.field("number").historyPage = 16
def.field("number").mountsPage = 4
def.field("number").memberPage = 4
def.field("table").memberList = nil
def.field("number").curPage = 1
def.field("table").hostInput = nil
def.field("number").turnedCardPage = 24
def.field("table").turnedCardList = nil
def.static("=>", ChatInputDlg).Instance = function()
  if instance == nil then
    instance = ChatInputDlg()
  end
  return instance
end
def.method("string", "=>", "boolean").CheckEmoji = function(self, e)
  if not self.loaded then
    self:Load()
  end
  if self.emojisMap and self.emojisMap[e] then
    return true
  else
    return false
  end
end
def.method().Load = function(self)
  self.emojis = {}
  self.emojisMap = {}
  GameUtil.AsyncLoad(RESPATH.EMOJIATLAS, function(obj)
    local atlas = obj:GetComponent("UIAtlas")
    local emojis = atlas:get_spriteList()
    for k, v in ipairs(emojis) do
      local spriteName = v:get_name()
      local i, j = string.find(spriteName, "_")
      local prefix = string.sub(spriteName, 1, i - 1)
      if not self.emojisMap[prefix] then
        table.insert(self.emojis, prefix)
        self.emojisMap[prefix] = true
      end
    end
    table.sort(self.emojis, function(a, b)
      return a < b
    end)
    self.emojiCount = #self.emojis
  end)
  self.moods = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MOOD_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local id = entry:GetIntValue("id")
    local name = entry:GetStringValue("name")
    self.moods[id] = name
    self.moodsCount = self.moodsCount + 1
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  self.loaded = true
end
def.static("table").ShowChatInputDlg = function(host)
  local ChatInputDlg = ChatInputDlg.Instance()
  if not ChatInputDlg.loaded then
    ChatInputDlg:Load()
  end
  ChatInputDlg.hostInput = host
  ChatInputDlg:CreatePanel(RESPATH.CHATINPUT_PANEL, 0)
  ChatInputDlg:SetOutTouchDisappear()
end
def.override().OnCreate = function(self)
  self:SetLeftMenuGrid()
  self:SetAnchor()
  self:SetMood()
  self:SetEmoji()
  self:TouchGameObject(self.m_panel, self.m_parent)
  self.m_bCanMoveBackward = true
end
def.override().OnDestroy = function(self)
  self.memberList = nil
end
def.method().SetLeftMenuGrid = function(self)
  local menuTypes = ChatInputDlg.StateConst
  local gridGroup = self.m_panel:FindDirect("Img_Key0/Group_TabList/Scrollview_Tab/Group_Tab")
  for k, v in pairs(menuTypes) do
    local tabNode = gridGroup:FindDirect(string.format("Tab_%02d", v))
    if tabNode and not tabNode.isnil then
      local canOpen = ChatInputMgr.Instance():CanOpenSpecifyInput(v) and self:IsHostNeededMenu(v)
      tabNode:SetActive(canOpen)
    end
  end
  local uiGrid = gridGroup:GetComponent("UIGrid")
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if uiGrid and not uiGrid.isnil then
      uiGrid:Reposition()
    end
  end)
end
def.method().SetAnchor = function(self)
  local screenHeight = require("GUI.ECGUIMan").Instance().m_uiRootCom:get_activeHeight()
  local screenWidth = screenHeight / Screen.height * Screen.width
  local img = self.m_panel:FindDirect("Img_Key0")
  local imgSprite = img:GetComponent("UISprite")
  local w = imgSprite:get_width()
  local h = imgSprite:get_height()
end
def.method().SetMood = function(self)
  local moodGrid = self.m_panel:FindDirect("Img_Key0/Group_02/Scroll View02/Grid_Page02/Page01/Grid_02")
  while moodGrid:get_childCount() > 1 do
    Object.DestroyImmediate(moodGrid:GetChild(moodGrid:get_childCount() - 1))
  end
  moodGrid:GetChild(0):SetActive(false)
  local pageCount = math.ceil(self.moodsCount / self.moodPage)
  local moodGroup = self.m_panel:FindDirect("Img_Key0/Group_02/Scroll View02/Grid_Page02")
  local moodPageTemplate = moodGroup:FindDirect("Page01")
  for i = 2, pageCount do
    local moodPage = Object.Instantiate(moodPageTemplate)
    moodPage.name = string.format("Page%02d", i)
    moodPage.parent = moodGroup
    moodPage:set_localScale(Vector.Vector3.one)
  end
  moodGroup:GetComponent("UIGrid"):Reposition()
  local moodTemplate = self.m_panel:FindDirect("Img_Key0/Group_02/Scroll View02/Grid_Page02/Page01/Grid_02/mood")
  local curIndex = 1
  for k, v in pairs(self.moods) do
    local mood = Object.Instantiate(moodTemplate)
    mood.name = string.format("mood_%s", k)
    local page = math.ceil(curIndex / self.moodPage)
    mood.parent = moodGroup:FindDirect(string.format("Page%02d/Grid_02", page))
    mood:set_localScale(Vector.Vector3.one)
    mood:FindDirect("Label"):GetComponent("UILabel"):set_text(v)
    mood:SetActive(true)
    curIndex = curIndex + 1
  end
  for i = 1, pageCount do
    local page = moodGroup:FindDirect(string.format("Page%02d/Grid_02", i))
    page:GetComponent("UIGrid"):Reposition()
  end
  local group = self.m_panel:FindDirect("Img_Key0/Group_02")
  group:SetActive(true)
  self:TouchGameObject(self.m_panel, self.m_parent)
  group:SetActive(false)
end
def.method().SetEmoji = function(self)
  local emojiGrid01 = self.m_panel:FindDirect("Img_Key0/Group_01/Scroll View01/Grid_Page01/Page01/Grid_01")
  while emojiGrid01:get_childCount() > 1 do
    Object.DestroyImmediate(emojiGrid01:GetChild(emojiGrid01:get_childCount() - 1))
  end
  emojiGrid01:GetChild(0):SetActive(false)
  local pageCount = math.ceil(self.emojiCount / self.emojiPage)
  local emojiGroup = self.m_panel:FindDirect("Img_Key0/Group_01/Scroll View01/Grid_Page01")
  local emojiPageTemplate = self.m_panel:FindDirect("Img_Key0/Group_01/Scroll View01/Grid_Page01/Page01")
  for i = 2, pageCount do
    local emojiPage = Object.Instantiate(emojiPageTemplate)
    emojiPage.name = string.format("Page%02d", i)
    emojiPage.parent = emojiGroup
    emojiPage:set_localScale(Vector.Vector3.one)
  end
  emojiGroup:GetComponent("UIGrid"):Reposition()
  local emojiTemplate = self.m_panel:FindDirect("Img_Key0/Group_01/Scroll View01/Grid_Page01/Page01/Grid_01/emoji")
  local curIndex = 1
  for k, v in ipairs(self.emojis) do
    local emoji = Object.Instantiate(emojiTemplate)
    emoji.name = string.format("emoji_%s", v)
    local page = math.ceil(curIndex / self.emojiPage)
    emoji.parent = emojiGroup:FindDirect(string.format("Page%02d/Grid_01", page))
    emoji:set_localScale(Vector.Vector3.one)
    local spriteAni = emoji:GetComponent("UISpriteAnimation")
    spriteAni:set_namePrefix(v)
    spriteAni:set_framesPerSecond(5)
    emoji:SetActive(true)
    curIndex = curIndex + 1
  end
  for i = 1, pageCount do
    local page = emojiGroup:FindDirect(string.format("Page%02d/Grid_01", i))
    page:GetComponent("UIGrid"):Reposition()
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().ClearInventory = function(self)
  local pages = self.m_panel:FindDirect("Img_Key0/Group_03/Scroll View03/Grid_Page03")
  while pages:get_childCount() > 1 do
    Object.DestroyImmediate(pages:GetChild(pages:get_childCount() - 1))
  end
  local grid = self.m_panel:FindDirect("Img_Key0/Group_03/Scroll View03/Grid_Page03/Page01/Grid_03")
  while grid:get_childCount() > 1 do
    Object.DestroyImmediate(grid:GetChild(grid:get_childCount() - 1))
  end
end
def.method().SetInventory = function(self)
  self:ClearInventory()
  local preViewLabel = self.m_panel:FindDirect("Img_Key0/Group_03/Img_BgTips03/Label_Tips03")
  preViewLabel:GetComponent("UILabel"):set_text(textRes.Chat[55])
  local equips = ItemModule.Instance():GetItemsByBagId(ItemModule.EQUIPBAG)
  local equipCount = MathHelper.CountTable(equips)
  local items = ItemModule.Instance():GetItemsByBagId(ItemModule.BAG)
  local itemCount = MathHelper.CountTable(items)
  local treasureItems = ItemModule.Instance():GetItemsByBagId(ItemModule.TREASURE_BAG)
  local treasureItemsCount = MathHelper.CountTable(treasureItems)
  local wingCount = WingInterface.GetCurWingItemId() > 0 and 1 or 0
  local fashionCount = FashionData.Instance():IsEquipFashion() and 1 or 0
  local aircraftCount = 0 < AircraftInterface.GetCurAircraftItemId() and 1 or 0
  local jewels = ItemModule.Instance():GetItemsByBagId(ItemModule.GOD_WEAPON_JEWEL_BAG)
  local jewelsCount = MathHelper.CountTable(jewels)
  local pageCount = math.ceil((equipCount + itemCount + wingCount + fashionCount + jewelsCount + aircraftCount + treasureItemsCount) / self.itemPage)
  self.curPage = pageCount
  local itemGroup = self.m_panel:FindDirect("Img_Key0/Group_03/Scroll View03/Grid_Page03")
  local itemPageTemplate = itemGroup:FindDirect("Page01")
  itemPageTemplate:FindDirect("Grid_03/item"):SetActive(false)
  for i = 2, pageCount do
    local itemPage = Object.Instantiate(itemPageTemplate)
    itemPage.name = string.format("Page%02d", i)
    itemPage.parent = itemGroup
    itemPage:set_localScale(Vector.Vector3.one)
  end
  itemGroup:GetComponent("UIGrid"):Reposition()
  local itemTemplate = itemPageTemplate:FindDirect("Grid_03/item")
  itemTemplate:SetActive(false)
  local curIndex = 1
  for k, v in pairs(equips) do
    local item = Object.Instantiate(itemTemplate)
    local page = math.ceil(curIndex / self.itemPage)
    item.name = string.format("equip_%d_%d", page, k)
    item.parent = itemGroup:FindDirect(string.format("Page%02d/Grid_03", page))
    item:set_localScale(Vector.Vector3.one)
    local itemBase = ItemUtils.GetItemBase(v.id)
    item:FindDirect("Label"):SetActive(false)
    item:FindDirect("Img_Sign"):SetActive(true)
    local uiTexture = item:FindDirect("Img_Icon"):GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, itemBase.icon)
    curIndex = curIndex + 1
    local frameName = ItemUtils.GetItemFrame(v, itemBase)
    item:GetComponent("UISprite"):set_spriteName(frameName)
    item:SetActive(true)
  end
  local fakeId = WingInterface.GetCurWingItemId()
  if fakeId > 0 then
    local item = Object.Instantiate(itemTemplate)
    local page = math.ceil(curIndex / self.itemPage)
    item.name = string.format("wing_%d", page)
    item.parent = itemGroup:FindDirect(string.format("Page%02d/Grid_03", page))
    item:set_localScale(Vector.Vector3.one)
    local itemBase = ItemUtils.GetItemBase(fakeId)
    item:FindDirect("Label"):SetActive(false)
    item:FindDirect("Img_Sign"):SetActive(true)
    local uiTexture = item:FindDirect("Img_Icon"):GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, itemBase.icon)
    curIndex = curIndex + 1
    item:SetActive(true)
  end
  local curAircraftItemId = AircraftInterface.GetCurAircraftItemId()
  if curAircraftItemId > 0 then
    local item = Object.Instantiate(itemTemplate)
    local page = math.ceil(curIndex / self.itemPage)
    item.name = string.format("aircraft_%d", page)
    item.parent = itemGroup:FindDirect(string.format("Page%02d/Grid_03", page))
    item:set_localScale(Vector.Vector3.one)
    local itemBase = ItemUtils.GetItemBase(curAircraftItemId)
    item:FindDirect("Label"):SetActive(false)
    item:FindDirect("Img_Sign"):SetActive(true)
    local uiTexture = item:FindDirect("Img_Icon"):GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, itemBase.icon)
    curIndex = curIndex + 1
    item:SetActive(true)
  end
  if FashionData.Instance():IsEquipFashion() then
    local fashionCfgId = FashionData.Instance().currentFashionId
    local item = Object.Instantiate(itemTemplate)
    item.name = string.format("fashion_%d", fashionCfgId)
    local page = math.ceil(curIndex / self.itemPage)
    item.parent = itemGroup:FindDirect(string.format("Page%02d/Grid_03", page))
    item:set_localScale(Vector.Vector3.one)
    local fashionItem = FashionUtils.GetFashionItemDataById(fashionCfgId)
    item:FindDirect("Label"):SetActive(false)
    item:FindDirect("Img_Sign"):SetActive(true)
    local uiTexture = item:FindDirect("Img_Icon"):GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, fashionItem.iconId)
    curIndex = curIndex + 1
    item:SetActive(true)
  end
  for k, v in pairs(items) do
    local item = Object.Instantiate(itemTemplate)
    local page = math.ceil(curIndex / self.itemPage)
    item.name = string.format("item_%d_%d", page, k)
    item.parent = itemGroup:FindDirect(string.format("Page%02d/Grid_03", page))
    item:set_localScale(Vector.Vector3.one)
    local itemBase = ItemUtils.GetItemBase(v.id)
    item:FindDirect("Label"):GetComponent("UILabel"):set_text(tostring(v.number))
    item:FindDirect("Img_Sign"):SetActive(false)
    local uiTexture = item:FindDirect("Img_Icon"):GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, itemBase.icon)
    curIndex = curIndex + 1
    local frameName = ItemUtils.GetItemFrame(v, itemBase)
    item:GetComponent("UISprite"):set_spriteName(frameName)
    item:SetActive(true)
  end
  for k, v in pairs(treasureItems) do
    local item = Object.Instantiate(itemTemplate)
    local page = math.ceil(curIndex / self.itemPage)
    item.name = string.format("treasure_%d_%d", page, k)
    item.parent = itemGroup:FindDirect(string.format("Page%02d/Grid_03", page))
    item:set_localScale(Vector.Vector3.one)
    local itemBase = ItemUtils.GetItemBase(v.id)
    item:FindDirect("Label"):GetComponent("UILabel"):set_text(tostring(v.number))
    item:FindDirect("Img_Sign"):SetActive(false)
    local uiTexture = item:FindDirect("Img_Icon"):GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, itemBase.icon)
    curIndex = curIndex + 1
    local frameName = ItemUtils.GetItemFrame(v, itemBase)
    item:GetComponent("UISprite"):set_spriteName(frameName)
    item:SetActive(true)
  end
  for k, v in pairs(jewels) do
    local item = Object.Instantiate(itemTemplate)
    local page = math.ceil(curIndex / self.itemPage)
    item.name = string.format("jewel_%d_%d", page, k)
    item.parent = itemGroup:FindDirect(string.format("Page%02d/Grid_03", page))
    item:set_localScale(Vector.Vector3.one)
    local itemBase = ItemUtils.GetItemBase(v.id)
    item:FindDirect("Label"):GetComponent("UILabel"):set_text(tostring(v.number))
    item:FindDirect("Img_Sign"):SetActive(false)
    local uiTexture = item:FindDirect("Img_Icon"):GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, itemBase.icon)
    curIndex = curIndex + 1
    local frameName = ItemUtils.GetItemFrame(v, itemBase)
    item:GetComponent("UISprite"):set_spriteName(frameName)
    item:SetActive(true)
  end
  for i = 1, pageCount do
    local page = itemGroup:FindDirect(string.format("Page%02d/Grid_03", i))
    page:GetComponent("UIGrid"):Reposition()
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().SetFabao = function(self)
  self:ClearInventory()
  local preViewLabel = self.m_panel:FindDirect("Img_Key0/Group_03/Img_BgTips03/Label_Tips03")
  preViewLabel:GetComponent("UILabel"):set_text(textRes.Chat[56])
  local allFabao = ChatInputMgr.Instance():GetAllFabao()
  local fabaoCount = MathHelper.CountTable(allFabao)
  local allLingQi = require("Main.FabaoSpirit.FabaoSpiritInterface").GetOwnedLQBasicInfos()
  local lingQiCount = MathHelper.CountTable(allLingQi)
  local pageCount = math.ceil((fabaoCount + lingQiCount) / self.itemPage)
  self.curPage = pageCount
  local itemGroup = self.m_panel:FindDirect("Img_Key0/Group_03/Scroll View03/Grid_Page03")
  local itemPageTemplate = itemGroup:FindDirect("Page01")
  itemPageTemplate:FindDirect("Grid_03/item"):SetActive(false)
  for i = 2, pageCount do
    local itemPage = Object.Instantiate(itemPageTemplate)
    itemPage.name = string.format("Page%02d", i)
    itemPage.parent = itemGroup
    itemPage:set_localScale(Vector.Vector3.one)
  end
  itemGroup:GetComponent("UIGrid"):Reposition()
  local itemTemplate = itemPageTemplate:FindDirect("Grid_03/item")
  itemTemplate:SetActive(false)
  local curIndex = 1
  for k, v in pairs(allFabao) do
    local fabaoItem = GameObject.Instantiate(itemTemplate)
    local pageIndex = math.ceil(curIndex / self.itemPage)
    if v.key == -1 then
      local fabaoBase = ItemUtils.GetFabaoItem(v.itemInfo.id)
      fabaoItem.name = string.format("fabao_equiped_%d_%d", pageIndex, fabaoBase.fabaoType)
    else
      fabaoItem.name = string.format("fabao_bag_%d_%d", pageIndex, v.key)
    end
    fabaoItem.parent = itemGroup:FindDirect(string.format("Page%02d/Grid_03", pageIndex))
    fabaoItem:set_localScale(Vector.Vector3.one)
    local fabaoItemBase = ItemUtils.GetItemBase(v.itemInfo.id)
    local equipImg = fabaoItem:FindDirect("Img_Sign")
    if v.key == -1 then
      equipImg:SetActive(true)
    else
      equipImg:SetActive(false)
    end
    fabaoItem:FindDirect("Label"):SetActive(false)
    local uiTexture = fabaoItem:FindDirect("Img_Icon"):GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, fabaoItemBase.icon)
    local bgSprite = fabaoItem:GetComponent("UISprite")
    bgSprite:set_spriteName(string.format("Cell_%02d", fabaoItemBase.namecolor))
    curIndex = curIndex + 1
    fabaoItem:SetActive(true)
  end
  local equipClassId = require("Main.FabaoSpirit.FabaoSpiritModule").GetEquipedLQClsId()
  for k, v in pairs(allLingQi) do
    local lingQiItem = GameObject.Instantiate(itemTemplate)
    local pageIndex = math.ceil(curIndex / self.itemPage)
    lingQiItem.name = string.format("fabao_lingqi_%d_%d", pageIndex, v.classId)
    lingQiItem.parent = itemGroup:FindDirect(string.format("Page%02d/Grid_03", pageIndex))
    lingQiItem:set_localScale(Vector.Vector3.one)
    if equipClassId == v.classId then
      lingQiItem:FindDirect("Img_Sign"):SetActive(true)
    else
      lingQiItem:FindDirect("Img_Sign"):SetActive(false)
    end
    lingQiItem:FindDirect("Label"):SetActive(false)
    local uiTexture = lingQiItem:FindDirect("Img_Icon"):GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, v.icon)
    local itemBase = ItemUtils.GetItemBase(v.itemId)
    local bgSprite = lingQiItem:GetComponent("UISprite")
    if itemBase then
      bgSprite:set_spriteName(string.format("Cell_%02d", itemBase.namecolor))
    end
    curIndex = curIndex + 1
    lingQiItem:SetActive(true)
  end
  for i = 1, pageCount do
    local page = itemGroup:FindDirect(string.format("Page%02d/Grid_03", i))
    page:GetComponent("UIGrid"):Reposition()
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().ClearPet = function(self)
  local pages = self.m_panel:FindDirect("Img_Key0/Group_04/Scroll View04/Grid_Page04")
  while pages:get_childCount() > 1 do
    Object.DestroyImmediate(pages:GetChild(pages:get_childCount() - 1))
  end
  local grid = self.m_panel:FindDirect("Img_Key0/Group_04/Scroll View04/Grid_Page04/Page01/Grid_04")
  while grid:get_childCount() > 1 do
    Object.DestroyImmediate(grid:GetChild(grid:get_childCount() - 1))
  end
end
def.method().SetPet = function(self)
  self:ClearPet()
  local petList = PetInterface.GetPetList()
  local petNum = PetInterface.GetPetNum()
  local pageCount = math.ceil(petNum / self.petPage)
  self.curPage = pageCount
  local petGroup = self.m_panel:FindDirect("Img_Key0/Group_04/Scroll View04/Grid_Page04")
  local petPageTemplate = petGroup:FindDirect("Page01")
  petPageTemplate:FindDirect("Grid_04/pet"):SetActive(false)
  for i = 2, pageCount do
    local petPage = Object.Instantiate(petPageTemplate)
    petPage.name = string.format("Page%02d", i)
    petPage.parent = petGroup
    petPage:set_localScale(Vector.Vector3.one)
  end
  petGroup:GetComponent("UIGrid"):Reposition()
  local petTemplate = petPageTemplate:FindDirect("Grid_04/pet")
  petTemplate:SetActive(false)
  local curIndex = 1
  for k, v in pairs(petList) do
    local pet = Object.Instantiate(petTemplate)
    local page = math.ceil(curIndex / self.petPage)
    pet.name = string.format("pet_%s", k)
    pet.parent = petGroup:FindDirect(string.format("Page%02d/Grid_04", page))
    pet:set_localScale(Vector.Vector3.one)
    pet:FindDirect("Img_Sign"):SetActive(v.isFighting)
    pet:FindDirect("Label_Name"):GetComponent("UILabel"):set_text(v.name)
    pet:FindDirect("Label_Lv"):GetComponent("UILabel"):set_text(string.format("%d%s", v.level, textRes.Chat[58]))
    pet:FindDirect("Label_PinFen"):GetComponent("UILabel"):set_text(string.format("%s%d", textRes.Chat[57], v:GetYaoLi()))
    local Img_BgIcon = pet:FindDirect("Img_BgIcon")
    local uiTexture = Img_BgIcon:FindDirect("Img_Icon"):GetComponent("UITexture")
    local iconId = PubroleInterface.GetModelCfg(v:GetPetCfgData().modelId).headerIconId
    GUIUtils.FillIcon(uiTexture, iconId)
    local spriteName = v:GetHeadIconBGSpriteName()
    GUIUtils.SetSprite(Img_BgIcon, spriteName)
    curIndex = curIndex + 1
    pet:SetActive(true)
  end
  for i = 1, pageCount do
    local page = petGroup:FindDirect(string.format("Page%02d/Grid_04", i))
    page:GetComponent("UIGrid"):Reposition()
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().ClearTask = function(self)
  local pages = self.m_panel:FindDirect("Img_Key0/Group_05/Scroll View05/Grid_Page05")
  while pages:get_childCount() > 1 do
    Object.DestroyImmediate(pages:GetChild(pages:get_childCount() - 1))
  end
  local grid = self.m_panel:FindDirect("Img_Key0/Group_05/Scroll View05/Grid_Page05/Page01/Grid_05")
  while grid:get_childCount() > 1 do
    Object.DestroyImmediate(grid:GetChild(grid:get_childCount() - 1))
  end
end
def.method().SetTask = function(self)
  self:ClearTask()
  local TaskInterface = require("Main.task.TaskInterface")
  local taskList = TaskInterface.Instance():GetAllTasks()
  local taskCount = #taskList
  local pageCount = math.ceil(taskCount / self.taskPage)
  self.curPage = pageCount
  local taskGroup = self.m_panel:FindDirect("Img_Key0/Group_05/Scroll View05/Grid_Page05")
  local taskPageTemplate = taskGroup:FindDirect("Page01")
  taskPageTemplate:FindDirect("Grid_05/task"):SetActive(false)
  for i = 2, pageCount do
    local taskPage = Object.Instantiate(taskPageTemplate)
    taskPage.name = string.format("Page%02d", i)
    taskPage.parent = taskGroup
    taskPage:set_localScale(Vector.Vector3.one)
  end
  taskGroup:GetComponent("UIGrid"):Reposition()
  local taskTemplate = taskPageTemplate:FindDirect("Grid_05/task")
  taskTemplate:SetActive(false)
  local curIndex = 1
  for k, v in pairs(taskList) do
    local task = Object.Instantiate(taskTemplate)
    local page = math.ceil(curIndex / self.taskPage)
    local id = v.taskID
    task.name = string.format("task_%d_%d", page, id)
    task.parent = taskGroup:FindDirect(string.format("Page%02d/Grid_05", page))
    task:set_localScale(Vector.Vector3.one)
    task:FindDirect("Label"):GetComponent("UILabel"):set_text(v.dispName)
    curIndex = curIndex + 1
    task:SetActive(true)
  end
  for i = 1, pageCount do
    local page = taskGroup:FindDirect(string.format("Page%02d/Grid_05", i))
    page:GetComponent("UIGrid"):Reposition()
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().ClearHistory = function(self)
  local pages = self.m_panel:FindDirect("Img_Key0/Group_06/Scroll View06/Grid_Page06")
  while pages:get_childCount() > 1 do
    Object.DestroyImmediate(pages:GetChild(pages:get_childCount() - 1))
  end
  local grid = self.m_panel:FindDirect("Img_Key0/Group_06/Scroll View06/Grid_Page06/Page01/Grid_06")
  while grid:get_childCount() > 1 do
    Object.DestroyImmediate(grid:GetChild(grid:get_childCount() - 1))
  end
end
def.method().SetHistory = function(self)
  self:ClearHistory()
  local historyList = ChatMemo.Instance():GetMemos()
  local historyCount = #historyList
  local pageCount = math.ceil(historyCount / self.historyPage)
  self.curPage = pageCount
  local historyGroup = self.m_panel:FindDirect("Img_Key0/Group_06/Scroll View06/Grid_Page06")
  local historyPageTemplate = historyGroup:FindDirect("Page01")
  historyPageTemplate:FindDirect("Grid_06/history"):SetActive(false)
  for i = 2, pageCount do
    local historyPage = Object.Instantiate(historyPageTemplate)
    historyPage.name = string.format("Page%02d", i)
    historyPage.parent = historyGroup
    historyPage:set_localScale(Vector.Vector3.one)
  end
  historyGroup:GetComponent("UIGrid"):Reposition()
  local historyTemplate = historyPageTemplate:FindDirect("Grid_06/history")
  historyTemplate:SetActive(false)
  local curIndex = 1
  for k, v in pairs(historyList) do
    local history = Object.Instantiate(historyTemplate)
    local page = math.ceil(curIndex / self.historyPage)
    history.name = string.format("history_%d", k)
    history.parent = historyGroup:FindDirect(string.format("Page%02d/Grid_06", page))
    history:set_localScale(Vector.Vector3.one)
    self.m_msgHandler:Touch(history)
    history:FindDirect("Label"):GetComponent("NGUIHTML"):ForceHtmlText(HtmlHelper.ConvertHistory(v))
    curIndex = curIndex + 1
    history:SetActive(true)
  end
  for i = 1, pageCount do
    local page = historyGroup:FindDirect(string.format("Page%02d/Grid_06", i))
    page:GetComponent("UIGrid"):Reposition()
  end
end
def.method().ClearChengwei = function(self)
  local pages = self.m_panel:FindDirect("Img_Key0/Group_10/Scroll View05/Grid_Page05")
  while pages:get_childCount() > 1 do
    Object.DestroyImmediate(pages:GetChild(pages:get_childCount() - 1))
  end
  local grid = self.m_panel:FindDirect("Img_Key0/Group_10/Scroll View05/Grid_Page05/Page01/Grid_05")
  while grid:get_childCount() > 1 do
    Object.DestroyImmediate(grid:GetChild(grid:get_childCount() - 1))
  end
end
def.method().SetChengwei = function(self)
  self:ClearChengwei()
  local TitleInterface = require("Main.title.TitleInterface")
  local ownAppellations = TitleInterface.Instance():GetOwnAppellations()
  local appellationCount = #ownAppellations
  local pageCount = math.ceil(appellationCount / self.taskPage)
  self.curPage = pageCount
  local appellationGroup = self.m_panel:FindDirect("Img_Key0/Group_10/Scroll View05/Grid_Page05")
  local appellationPageTemplate = appellationGroup:FindDirect("Page01")
  appellationPageTemplate:FindDirect("Grid_05/task"):SetActive(false)
  for i = 2, pageCount do
    local appllationPage = Object.Instantiate(appellationPageTemplate)
    appllationPage.name = string.format("Page%02d", i)
    appllationPage.parent = appellationGroup
    appllationPage:set_localScale(Vector.Vector3.one)
  end
  appellationGroup:GetComponent("UIGrid"):Reposition()
  local appellationTemplate = appellationPageTemplate:FindDirect("Grid_05/task")
  appellationTemplate:SetActive(false)
  local curIndex = 1
  for k, v in pairs(ownAppellations) do
    local appellation = Object.Instantiate(appellationTemplate)
    local page = math.ceil(curIndex / self.taskPage)
    appellation.name = string.format("chengwei_%d", v)
    appellation.parent = appellationGroup:FindDirect(string.format("Page%02d/Grid_05", page))
    appellation:set_localScale(Vector.Vector3.one)
    local appArgs = TitleInterface.Instance():GetAppellationArgs(v)
    local chengweiStr = TitleInterface.GetAppellationCfg(v).appellationName
    if appArgs ~= nil then
      chengweiStr = string.format(chengweiStr, unpack(appArgs))
    end
    appellation:FindDirect("Label"):GetComponent("UILabel"):set_text(chengweiStr)
    curIndex = curIndex + 1
    appellation:SetActive(true)
  end
  for i = 1, pageCount do
    local page = appellationGroup:FindDirect(string.format("Page%02d/Grid_05", i))
    page:GetComponent("UIGrid"):Reposition()
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().ClearTouxian = function(self)
  local pages = self.m_panel:FindDirect("Img_Key0/Group_11/Scroll View05/Grid_Page05")
  while pages:get_childCount() > 1 do
    Object.DestroyImmediate(pages:GetChild(pages:get_childCount() - 1))
  end
  local grid = self.m_panel:FindDirect("Img_Key0/Group_11/Scroll View05/Grid_Page05/Page01/Grid_05")
  while grid:get_childCount() > 1 do
    Object.DestroyImmediate(grid:GetChild(grid:get_childCount() - 1))
  end
end
def.method().SetTouxian = function(self)
  self:ClearTouxian()
  local TitleInterface = require("Main.title.TitleInterface")
  local ownTitles = TitleInterface.Instance():GetOwnTitles()
  local titleCount = #ownTitles
  local pageCount = math.ceil(titleCount / self.taskPage)
  self.curPage = pageCount
  local titleGroup = self.m_panel:FindDirect("Img_Key0/Group_11/Scroll View05/Grid_Page05")
  local titlePageTemplate = titleGroup:FindDirect("Page01")
  titlePageTemplate:FindDirect("Grid_05/task"):SetActive(false)
  for i = 2, pageCount do
    local titlePage = Object.Instantiate(titlePageTemplate)
    titlePage.name = string.format("Page%02d", i)
    titlePage.parent = titleGroup
    titlePage:set_localScale(Vector.Vector3.one)
  end
  titleGroup:GetComponent("UIGrid"):Reposition()
  local titleTemplate = titlePageTemplate:FindDirect("Grid_05/task")
  titleTemplate:SetActive(false)
  local curIndex = 1
  for k, v in pairs(ownTitles) do
    local title = Object.Instantiate(titleTemplate)
    local page = math.ceil(curIndex / self.taskPage)
    title.name = string.format("touxian_%d", v)
    title.parent = titleGroup:FindDirect(string.format("Page%02d/Grid_05", page))
    title:set_localScale(Vector.Vector3.one)
    title:FindDirect("Label"):GetComponent("UILabel"):set_text(TitleInterface.GetTitleCfg(v).titleName)
    curIndex = curIndex + 1
    title:SetActive(true)
  end
  for i = 1, pageCount do
    local page = titleGroup:FindDirect(string.format("Page%02d/Grid_05", i))
    page:GetComponent("UIGrid"):Reposition()
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().ClearMounts = function(self)
  local pages = self.m_panel:FindDirect("Img_Key0/Group_12/Scroll View04/Grid_Page04")
  while pages:get_childCount() > 1 do
    Object.DestroyImmediate(pages:GetChild(pages:get_childCount() - 1))
  end
  local grid = self.m_panel:FindDirect("Img_Key0/Group_12/Scroll View04/Grid_Page04/Page01/Grid_04")
  while grid:get_childCount() > 1 do
    Object.DestroyImmediate(grid:GetChild(grid:get_childCount() - 1))
  end
end
def.method().SetMounts = function(self)
  self:ClearMounts()
  local MountsMgr = require("Main.Mounts.mgr.MountsMgr")
  local MountsUtils = require("Main.Mounts.MountsUtils")
  local mountsList = MountsMgr.Instance():GetSortedMountsList()
  local mountsCount = #mountsList
  local pageCount = math.ceil(mountsCount / self.mountsPage)
  self.curPage = pageCount
  local mountsGroup = self.m_panel:FindDirect("Img_Key0/Group_12/Scroll View04/Grid_Page04")
  local mountsPageTemplate = mountsGroup:FindDirect("Page01")
  mountsPageTemplate:FindDirect("Grid_04/pet"):SetActive(false)
  for i = 2, pageCount do
    local mountsPage = Object.Instantiate(mountsPageTemplate)
    mountsPage.name = string.format("Page%02d", i)
    mountsPage.parent = mountsGroup
    mountsPage:set_localScale(Vector.Vector3.one)
  end
  mountsGroup:GetComponent("UIGrid"):Reposition()
  local mountsTemplate = mountsPageTemplate:FindDirect("Grid_04/pet")
  mountsTemplate:SetActive(false)
  local curIndex = 1
  for idx, mountsData in pairs(mountsList) do
    local mounts = Object.Instantiate(mountsTemplate)
    local page = math.ceil(curIndex / self.mountsPage)
    mounts.name = string.format("mounts_%s", mountsData.mounts_id:tostring())
    mounts.parent = mountsGroup:FindDirect(string.format("Page%02d/Grid_04", page))
    mounts:set_localScale(Vector.Vector3.one)
    local mountsCfg = MountsUtils.GetMountsCfgById(mountsData.mounts_cfg_id)
    local Img_Icon = mounts:FindDirect("Img_BgIcon/Img_Icon")
    local Label_Name = mounts:FindDirect("Label_Name")
    local Label_Lv = mounts:FindDirect("Label_Lv")
    local Label_PinFen = mounts:FindDirect("Label_PinFen")
    if mountsCfg == nil then
      GUIUtils.FillIcon(Img_Icon:GetComponent("UITexture"), 0)
      GUIUtils.SetText(Label_Name, textRes.Mounts[116])
      GUIUtils.SetText(Label_Lv, "")
      GUIUtils.SetText(Label_PinFen, "")
    else
      GUIUtils.FillIcon(Img_Icon:GetComponent("UITexture"), mountsCfg.mountsIconId)
      GUIUtils.SetText(Label_Name, mountsCfg.mountsName)
      GUIUtils.SetText(Label_Lv, string.format(textRes.Mounts[1], mountsData.mounts_rank))
      GUIUtils.SetText(Label_PinFen, string.format(textRes.Mounts[117], MountsMgr.Instance():GetMountsScore(mountsData.mounts_id)))
    end
    curIndex = curIndex + 1
    mounts:SetActive(true)
  end
  for i = 1, pageCount do
    local page = mountsGroup:FindDirect(string.format("Page%02d/Grid_04", i))
    page:GetComponent("UIGrid"):Reposition()
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().ClearChildren = function(self)
  local pages = self.m_panel:FindDirect("Img_Key0/Group_13/Scroll View04/Grid_Page04")
  while pages:get_childCount() > 1 do
    Object.DestroyImmediate(pages:GetChild(pages:get_childCount() - 1))
  end
  local grid = self.m_panel:FindDirect("Img_Key0/Group_13/Scroll View04/Grid_Page04/Page01/Grid_04")
  while grid:get_childCount() > 1 do
    Object.DestroyImmediate(grid:GetChild(grid:get_childCount() - 1))
  end
end
def.method().SetChildren = function(self)
  self:ClearChildren()
  local childrenList = ChildrenInterface.GetAllBagChildren()
  local childrenNum = #childrenList
  local pageCount = math.ceil(childrenNum / self.petPage)
  self.curPage = pageCount
  local chiilrenGroup = self.m_panel:FindDirect("Img_Key0/Group_13/Scroll View04/Grid_Page04")
  local childrenPageTemplate = chiilrenGroup:FindDirect("Page01")
  childrenPageTemplate:FindDirect("Grid_04/Child"):SetActive(false)
  for i = 2, pageCount do
    local childPage = Object.Instantiate(childrenPageTemplate)
    childPage.name = string.format("Page%02d", i)
    childPage.parent = chiilrenGroup
    childPage:set_localScale(Vector.Vector3.one)
  end
  chiilrenGroup:GetComponent("UIGrid"):Reposition()
  local childTemplate = childrenPageTemplate:FindDirect("Grid_04/Child")
  childTemplate:SetActive(false)
  local curIndex = 1
  for k, v in pairs(childrenList) do
    local child = Object.Instantiate(childTemplate)
    local page = math.ceil(curIndex / self.petPage)
    child.name = string.format("child_%s", v:tostring())
    child.parent = chiilrenGroup:FindDirect(string.format("Page%02d/Grid_04", page))
    child:set_localScale(Vector.Vector3.one)
    local childInfo = ChildrenInterface.GetChildById(v)
    child:FindDirect("Img_Sign"):SetActive(false)
    child:FindDirect("Label_Name"):GetComponent("UILabel"):set_text(childInfo:GetName())
    child:FindDirect("Label_Date"):GetComponent("UILabel"):set_text(textRes.Children.PeriodName[childInfo:GetStatus()])
    local tex = child:FindDirect("Img_BgIcon/Img_Icon"):GetComponent("UITexture")
    GUIUtils.FillIcon(tex, ChildrenUtils.GetChildHeadIcon(childInfo:GetCurModelId()))
    curIndex = curIndex + 1
    child:SetActive(true)
  end
  for i = 1, pageCount do
    local page = chiilrenGroup:FindDirect(string.format("Page%02d/Grid_04", i))
    page:GetComponent("UIGrid"):Reposition()
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().resetPoints = function(self)
  local points = self.m_panel:FindDirect("Img_Key0/Img_Bg1/Grid_Pages")
  while points:get_childCount() > 1 do
    Object.DestroyImmediate(points:GetChild(points:get_childCount() - 1))
  end
  local pointtemplate = points:FindDirect("Img_Pages00")
  pointtemplate:SetActive(false)
  for i = 1, self.curPage do
    local point = Object.Instantiate(pointtemplate)
    point.name = string.format("Img_Pages%02d", i)
    point.parent = points
    point:set_localScale(Vector.Vector3.one)
    point:SetActive(true)
    if i == 1 then
      point:GetComponent("UIToggle"):set_value(true)
    end
  end
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if points and not points.isnil then
      points:GetComponent("UIGrid"):Reposition()
    end
  end)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Back" then
    self:DestroyPanel()
  elseif id == "Btn_Backspace" then
    self.hostInput:BackSpaceContent()
  elseif id == "Btn_Send" then
    self.hostInput:SubmitContent()
    self:DestroyPanel()
  elseif id == "Btn_Change" then
    self:DestroyPanel()
    self.hostInput:FocusOnInput()
  elseif id == "Btn_Space" then
    self.hostInput:AddContent(" ")
  elseif string.find(id, "emoji_") then
    local emojiName = string.sub(id, 7)
    self.hostInput:AddInfoPack(string.format("#%s", emojiName), string.format("{e:%s}", emojiName))
  elseif string.find(id, "mood_") then
    local moodid = tonumber(string.sub(id, 6))
    local record = DynamicData.GetRecord(CFG_PATH.DATA_MOOD_CFG, moodid)
    local moodStr = record:GetStringValue("content")
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    local myName = heroProp.name
    moodStr = string.gsub(moodStr, "%$N", myName)
    local atTxtId = record:GetIntValue("atChatTextFaceId")
    local content = self.hostInput.input:get_value()
    local infoPack = ""
    local WordsEmojMgr = require("Main.Chat.WordsEmoj.WordsEmojMgr")
    if string.find(content, "@") then
      infoPack = WordsEmojMgr.MakeFakeInfoPack(content)
    else
      infoPack = self.hostInput:GetInfoPack(content)
      warn("infoPack", infoPack)
    end
    local wordsEmoj = WordsEmojMgr.CheckReplace(infoPack, atTxtId)
    if wordsEmoj == "" then
      self.hostInput:SendContent(moodStr, true)
    else
      self.hostInput:SendContent(wordsEmoj, true)
    end
  elseif string.find(id, "item_") then
    local HeroModule = require("Main.Hero.HeroModule")
    local itemKey = tonumber(string.sub(id, 8))
    local itemInfo = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.BAG, itemKey)
    local itemBase = ItemUtils.GetItemBase(itemInfo.id)
    local uuid = itemInfo.uuid[1]
    local EquipUtils = require("Main.Equip.EquipUtils")
    local dynamicColor = EquipUtils.GetEquipDynamicColor(itemInfo, nil, itemBase)
    local name = ItemUtils.GetItemName(itemInfo, itemBase)
    local cnt = string.format("{i:%s,%d,%d,%s,%s}", name, itemInfo.number, dynamicColor, HeroModule.Instance().roleId:tostring(), uuid:tostring())
    self.hostInput:AddInfoPack(string.format("[%s]", name), cnt)
  elseif string.find(id, "treasure_") then
    local HeroModule = require("Main.Hero.HeroModule")
    local itemKey = tonumber(string.sub(id, 12))
    local itemInfo = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.TREASURE_BAG, itemKey)
    local itemBase = ItemUtils.GetItemBase(itemInfo.id)
    local uuid = itemInfo.uuid[1]
    local EquipUtils = require("Main.Equip.EquipUtils")
    local dynamicColor = EquipUtils.GetEquipDynamicColor(itemInfo, nil, itemBase)
    local name = ItemUtils.GetItemName(itemInfo, itemBase)
    local cnt = string.format("{i:%s,%d,%d,%s,%s}", name, itemInfo.number, dynamicColor, HeroModule.Instance().roleId:tostring(), uuid:tostring())
    self.hostInput:AddInfoPack(string.format("[%s]", name), cnt)
  elseif string.find(id, "jewel_") then
    local HeroModule = require("Main.Hero.HeroModule")
    local itemKey = tonumber(string.sub(id, 9))
    local itemInfo = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.GOD_WEAPON_JEWEL_BAG, itemKey)
    local itemBase = ItemUtils.GetItemBase(itemInfo.id)
    local uuid = itemInfo.uuid[1]
    local EquipUtils = require("Main.Equip.EquipUtils")
    local dynamicColor = EquipUtils.GetEquipDynamicColor(itemInfo, nil, itemBase)
    local name = ItemUtils.GetItemName(itemInfo, itemBase)
    local cnt = string.format("{i:%s,%d,%d,%s,%s}", name, itemInfo.number, dynamicColor, HeroModule.Instance().roleId:tostring(), uuid:tostring())
    self.hostInput:AddInfoPack(string.format("[%s]", name), cnt)
  elseif string.find(id, "fabao_") then
    local HeroModule = require("Main.Hero.HeroModule")
    if string.find(id, "equiped_") then
      local fabaoType = tonumber(string.sub(id, 17))
      local fabaoData = require("Main.Fabao.data.FabaoData").Instance():GetFabaoByType(fabaoType)
      local fabaoItemBase = ItemUtils.GetItemBase(fabaoData.id)
      local fabaoUuid = fabaoData.uuid[1]
      local EquipUtils = require("Main.Equip.EquipUtils")
      local dynamicColor = EquipUtils.GetEquipDynamicColor(fabaoData, nil, fabaoItemBase)
      local cnt = string.format("{fb:%s,%d,%d,%s,%s}", fabaoItemBase.name, 1, dynamicColor, HeroModule.Instance().roleId:tostring(), fabaoUuid:tostring())
      self.hostInput:AddInfoPack(string.format("[%s]", fabaoItemBase.name), cnt)
    elseif string.find(id, "bag_") then
      local key = tonumber(string.sub(id, 13))
      local itemInfo = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.FABAOBAG, key)
      local itemBase = ItemUtils.GetItemBase(itemInfo.id)
      local uuid = itemInfo.uuid[1]
      local EquipUtils = require("Main.Equip.EquipUtils")
      local dynamicColor = EquipUtils.GetEquipDynamicColor(itemInfo, nil, itemBase)
      local cnt = string.format("{fb:%s,%d,%d,%s,%s}", itemBase.name, itemInfo.number, dynamicColor, HeroModule.Instance().roleId:tostring(), uuid:tostring())
      self.hostInput:AddInfoPack(string.format("[%s]", itemBase.name), cnt)
    elseif string.find(id, "lingqi_") then
      local key = tonumber(string.sub(id, 16))
      local lingqi = require("Main.FabaoSpirit.FabaoSpiritInterface").GetOwnLQBasicInfoByClsId(key)
      if lingqi then
        local itemBase = ItemUtils.GetItemBase(lingqi.itemId)
        if itemBase then
          local cnt = string.format("{fbs:%s,%d,%d,%s}", lingqi.name, key, itemBase.namecolor, HeroModule.Instance().roleId:tostring())
          self.hostInput:AddInfoPack(string.format("[%s]", lingqi.name), cnt)
        end
      end
    end
  elseif string.find(id, "equip_") then
    local HeroModule = require("Main.Hero.HeroModule")
    local itemKey = tonumber(string.sub(id, 9))
    local itemInfo = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.EQUIPBAG, itemKey)
    local itemBase = ItemUtils.GetItemBase(itemInfo.id)
    local EquipUtils = require("Main.Equip.EquipUtils")
    local dynamicColor = EquipUtils.GetEquipDynamicColor(itemInfo, nil, itemBase)
    local uuid = itemInfo.uuid[1]
    local name = ItemUtils.GetItemName(itemInfo, itemBase)
    local cnt = string.format("{i:%s,%d,%d,%s,%s}", name, itemInfo.number, dynamicColor, HeroModule.Instance().roleId:tostring(), uuid:tostring())
    self.hostInput:AddInfoPack(string.format("[%s]", name), cnt)
  elseif string.find(id, "wing_") then
    local HeroModule = require("Main.Hero.HeroModule")
    local fakeId = WingInterface.GetCurWingItemId()
    if fakeId > 0 then
      local wingId = WingInterface.GetCurWingId()
      local itemBase = ItemUtils.GetItemBase(fakeId)
      local cnt = string.format("{w:%s,%d,%d,%s}", itemBase.name, itemBase.namecolor, wingId, HeroModule.Instance().roleId:tostring())
      self.hostInput:AddInfoPack(string.format("[%s]", itemBase.name), cnt)
    end
  elseif string.find(id, "aircraft_") then
    local HeroModule = require("Main.Hero.HeroModule")
    local curAircraftItemId = AircraftInterface.GetCurAircraftItemId()
    if curAircraftItemId > 0 then
      local aircraftId = AircraftInterface.GetCurAircraftId()
      local itemBase = ItemUtils.GetItemBase(curAircraftItemId)
      local cnt = string.format("{a:%s,%d,%d,%s}", itemBase.name, itemBase.namecolor, aircraftId, HeroModule.Instance().roleId:tostring())
      self.hostInput:AddInfoPack(string.format("[%s]", itemBase.name), cnt)
    end
  elseif string.find(id, "pet_") then
    local HeroModule = require("Main.Hero.HeroModule")
    local petId = Int64.new(string.sub(id, 5))
    local petData = PetInterface.GetPet(petId)
    local yaolicfg = petData:GetPetYaoLiCfg()
    local petCfg = petData:GetPetCfgData()
    local cnt = string.format("{p:%s,%s,%s,%s,%s}", petData:GetPetCfgData().templateName, HeroModule.Instance().roleId:tostring(), petId:tostring(), yaolicfg.encodeChar, petCfg.type)
    self.hostInput:AddInfoPack(string.format("[%s]", petData:GetPetCfgData().templateName), cnt)
  elseif string.find(id, "task_") then
    local page = tonumber(string.sub(id, 6, 6))
    local taskId = tonumber(string.sub(id, 8))
    local source = self.m_panel:FindDirect(string.format("Img_Key0/Group_05/Scroll View05/Grid_Page05/Page%02d/Grid_05/%s", page, id))
    local taskName = source:FindDirect("Label"):GetComponent("UILabel"):get_text()
    local cnt = string.format("{t:%s,%d}", taskName, taskId)
    self.hostInput:AddInfoPack(string.format("[%s]", taskName), cnt)
  elseif string.find(id, "history_") then
    local index = tonumber(string.sub(id, 9))
    local cnt = ChatMemo.Instance():GetMemo(index)
    self.hostInput:SendContent(cnt, false)
  elseif string.find(id, "chengwei_") then
    local chengweiId = tonumber(string.sub(id, 10))
    local TitleInterface = require("Main.title.TitleInterface")
    local appArgs = TitleInterface.Instance():GetAppellationArgs(chengweiId)
    local chengweiName = TitleInterface.GetAppellationCfg(chengweiId).appellationName
    if appArgs ~= nil then
      chengweiName = string.format(chengweiName, unpack(appArgs))
    end
    local cnt = string.format("{chengwei:%s,%d}", chengweiName, chengweiId)
    self.hostInput:AddInfoPack(string.format("[%s]", chengweiName), cnt)
  elseif string.find(id, "touxian_") then
    local touxianId = tonumber(string.sub(id, 9))
    local TitleInterface = require("Main.title.TitleInterface")
    local touxianName = TitleInterface.GetTitleCfg(touxianId).titleName
    local cnt = string.format("{touxian:%s,%d}", touxianName, touxianId)
    self.hostInput:AddInfoPack(string.format("[%s]", touxianName), cnt)
  elseif id == "Tab_09" then
    warn("onclick tab redgift ~~~~~~~~~~ ")
    ChatInputMgr.Instance():OpenRedGiftPanel()
    self:DestroyPanel()
  elseif string.find(id, "fashion_") == 1 then
    local cfgId = tonumber(string.sub(id, 9))
    local fashionItem = FashionUtils.GetFashionItemDataById(cfgId)
    local cnt = string.format("{f:%s,%d}", fashionItem.fashionDressName, fashionItem.fashionDressType)
    self.hostInput:AddInfoPack(string.format("[%s]", fashionItem.fashionDressName), cnt)
  elseif string.find(id, "mounts_") then
    local mountsId = string.sub(id, #"mounts_" + 1)
    if mountsId ~= nil then
      local MountsMgr = require("Main.Mounts.mgr.MountsMgr")
      local MountsUtils = require("Main.Mounts.MountsUtils")
      local HeroModule = require("Main.Hero.HeroModule")
      local mounts = MountsMgr.Instance():GetMountsById(Int64.new(mountsId))
      if mounts ~= nil then
        local mountsCfg = MountsUtils.GetMountsCfgById(mounts.mounts_cfg_id)
        if mountsCfg ~= nil then
          local cnt = string.format("{mounts:%s,%s,%s}", mountsCfg.mountsName, HeroModule.Instance().roleId:tostring(), mountsId)
          self.hostInput:AddInfoPack(string.format("[%s]", mountsCfg.mountsName), cnt)
        end
      end
    end
  elseif string.find(id, "child_") then
    local childId = Int64.new(string.sub(id, #"child_" + 1))
    if childId ~= nil then
      local childInfo = ChildrenInterface.GetChildById(childId)
      if childInfo then
        local name = childInfo:GetName()
        self.hostInput:AddInfoPack(string.format("[%s]", name), string.format("{child:%s,%s}", name, childId:tostring()))
      end
    end
  elseif string.find(id, "member_") then
    local idx = tonumber(string.sub(id, #"member_" + 1))
    if idx and idx > 0 then
      local memberInfo = self.memberList and self.memberList[idx]
      if memberInfo then
        local name = memberInfo.name
        self.hostInput:AddInfoPack(string.format("@%s", name), memberInfo:GetInfoPack())
      else
        warn("[ERROR][ChatInputDlg:onClick] memberInfo nil at idx:", idx)
      end
    end
  elseif string.find(id, "TurnedCard") then
    local idx = tonumber(string.sub(id, #"TurnedCard" + 1))
    if idx and idx > 0 then
      local info = self.turnedCardList and self.turnedCardList[idx]
      if info.isItem then
        local item = info.info
        local itemBase = ItemUtils.GetItemBase(item.id)
        local level, cfgId = self:getLevelAndCfgId(info)
        local cnt = string.format("{TurnedCard:%s,%s,%s}", cfgId, itemBase.name, level)
        self.hostInput:AddInfoPack(string.format("[%s]", itemBase.name), cnt)
      else
        local turnedCard = info.info
        local cfgId = turnedCard:getCardCfgId()
        local level = turnedCard:getCardLevel()
        local cardName = TurnedCardUtils.GetTurnedCardDisPlayName(cfgId, level)
        local cnt = string.format("{TurnedCard:%s,%s,%s}", cfgId, cardName, level)
        self.hostInput:AddInfoPack(string.format("[%s]", cardName), cnt)
      end
    end
  end
end
def.method("string", "boolean").onPress = function(self, id, press)
end
def.method("string").onLongPress = function(self, id)
  print("LongPress:", id)
  if string.find(id, "mood_") then
    local moodid = tonumber(string.sub(id, 6))
    local record = DynamicData.GetRecord(CFG_PATH.DATA_MOOD_CFG, moodid)
    local moodStr = record:GetStringValue("content")
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    local myName = heroProp.name
    moodStr = string.gsub(moodStr, "%$N", myName)
    require("GUI.CommonUITipsDlg").ShowCommonTip(moodStr, {x = 64, y = 80})
  elseif string.find(id, "item_") then
    local page = tonumber(string.sub(id, 6, 6))
    local index = tonumber(string.sub(id, 8))
    local itemInfo = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.BAG, index)
    local source = self.m_panel:FindDirect(string.format("Img_Key0/Group_03/Scroll View03/Grid_Page03/Page%02d/Grid_03/%s", page, id))
    local position = source:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = source:GetComponent("UISprite")
    ItemTipsMgr.Instance():ShowTips(itemInfo, ItemModule.BAG, index, ItemTipsMgr.Source.Other, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0)
  elseif string.find(id, "treasure_") then
    local page = tonumber(string.sub(id, 10, 10))
    local index = tonumber(string.sub(id, 12))
    local itemInfo = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.TREASURE_BAG, index)
    local source = self.m_panel:FindDirect(string.format("Img_Key0/Group_03/Scroll View03/Grid_Page03/Page%02d/Grid_03/%s", page, id))
    local position = source:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = source:GetComponent("UISprite")
    ItemTipsMgr.Instance():ShowTips(itemInfo, ItemModule.BAG, index, ItemTipsMgr.Source.Other, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0)
  elseif string.find(id, "fabao_") then
    if string.find(id, "equiped_") then
      local pageIndex = tonumber(string.sub(id, 15, 15))
      local fabaoType = tonumber(string.sub(id, 17))
      local fabaoItemInfo = require("Main.Fabao.data.FabaoData").Instance():GetFabaoByType(fabaoType)
      local itemObj = self.m_panel:FindDirect(string.format("Img_Key0/Group_03/Scroll View03/Grid_Page03/Page%02d/Grid_03/%s", pageIndex, id))
      if fabaoItemInfo and itemObj then
        local position = itemObj:get_position()
        local screenPos = WorldPosToScreen(position.x, position.y)
        local sprite = itemObj:GetComponent("UISprite")
        local itemBase = ItemUtils.GetItemBase(fabaoItemInfo.id)
        ItemTipsMgr.Instance():ShowFabaoWearTips(fabaoItemInfo, itemBase, ItemTipsMgr.Source.Other, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, false)
      end
    elseif string.find(id, "bag_") then
      local pageIndex = tonumber(string.sub(id, 11, 11))
      local key = tonumber(string.sub(id, 13))
      local itemInfo = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.BAG, key)
      if itemInfo then
        local source = self.m_panel:FindDirect(string.format("Img_Key0/Group_03/Scroll View03/Grid_Page03/Page%02d/Grid_03/%s", pageIndex, id))
        local position = source:get_position()
        local screenPos = WorldPosToScreen(position.x, position.y)
        local sprite = source:GetComponent("UISprite")
        ItemTipsMgr.Instance():ShowTips(itemInfo, ItemModule.BAG, key, ItemTipsMgr.Source.Other, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0)
      end
    elseif string.find(id, "lingqi_") then
      local classId = tonumber(string.sub(id, 16))
      if classId then
        require("Main.FabaoSpirit.FabaoSpiritInterface").ShowSelfLQTips(classId)
      end
    end
  elseif string.find(id, "equip_") then
    local page = tonumber(string.sub(id, 7, 7))
    local index = tonumber(string.sub(id, 9))
    local itemInfo = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.EQUIPBAG, index)
    local source = self.m_panel:FindDirect(string.format("Img_Key0/Group_03/Scroll View03/Grid_Page03/Page%02d/Grid_03/%s", page, id))
    local position = source:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = source:GetComponent("UISprite")
    ItemTipsMgr.Instance():ShowTips(itemInfo, ItemModule.EQUIPBAG, index, ItemTipsMgr.Source.Other, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0)
  elseif string.find(id, "jewel_") then
    local page = tonumber(string.sub(id, 7, 7))
    local index = tonumber(string.sub(id, 9))
    local itemInfo = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.GOD_WEAPON_JEWEL_BAG, index)
    local source = self.m_panel:FindDirect(string.format("Img_Key0/Group_03/Scroll View03/Grid_Page03/Page%02d/Grid_03/%s", page, id))
    local position = source:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = source:GetComponent("UISprite")
    ItemTipsMgr.Instance():ShowTips(itemInfo, ItemModule.GOD_WEAPON_JEWEL_BAG, index, ItemTipsMgr.Source.Other, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0)
  elseif string.find(id, "wing_") then
    WingInterface.CheckMyWing()
  elseif string.find(id, "aircraft_") then
    AircraftInterface.CheckChatAircraft(_G.GetMyRoleID(), AircraftInterface.GetCurAircraftId())
  elseif string.find(id, "task_") then
    local page = tonumber(string.sub(id, 6, 6))
    local index = tonumber(string.sub(id, 8))
    local TaskTips = require("Main.task.ui.TaskTips")
    TaskTips.Instance():ShowDlg(index)
  elseif string.find(id, "pet_") then
    local index = Int64.new(string.sub(id, 5))
    local petData = PetInterface.GetPet(index)
    require("Main.Pet.ui.PetInfoPanel").Instance():ShowPanel(petData)
  elseif string.find(id, "fashion_") == 1 then
    local cfgId = tonumber(string.sub(id, 9))
    require("Main.Fashion.ui.FashionPanel").Instance():ShowFashionPanelWithCfgId(cfgId)
  elseif string.find(id, "chengwei_") then
    local chengweiId = tonumber(string.sub(id, 10))
    local TitleInterface = require("Main.title.TitleInterface")
    local appArgs = TitleInterface.Instance():GetAppellationArgs(chengweiId)
    local chengweiName = TitleInterface.GetAppellationCfg(chengweiId).appellationName
    if appArgs ~= nil then
      chengweiName = string.format(chengweiName, unpack(appArgs))
    end
    require("Main.title.TitleMgr").ShowChengweiTips(chengweiId, chengweiName)
  elseif string.find(id, "touxian_") then
    local touxianId = tonumber(string.sub(id, 9))
    local TitleInterface = require("Main.title.TitleInterface")
    local touxianName = TitleInterface.GetTitleCfg(touxianId).titleName
    require("Main.title.TitleMgr").ShowTouxianTips(touxianId, touxianName)
  elseif string.find(id, "mounts_") then
    local mountsId = tonumber(string.sub(id, #"mounts_" + 1))
    require("Main.Mounts.MountsModule").ShowSelfMountsInfoById(Int64.new(mountsId))
  elseif string.find(id, "TurnedCard") then
    local idx = tonumber(string.sub(id, #"TurnedCard" + 1))
    if idx then
      local page = math.ceil(idx / self.turnedCardPage)
      local source = self.m_panel:FindDirect(string.format("Img_Key0/Group_14/Scroll View03/Grid_Page03/Page%02d/Grid_03/%s", page, id))
      local position = source:get_position()
      local screenPos = WorldPosToScreen(position.x, position.y)
      local sprite = source:GetComponent("UISprite")
      local info = self.turnedCardList and self.turnedCardList[idx]
      local itemId = 0
      if info.isItem then
        itemId = info.info.id
      else
        local turnedCard = info.info
        local cfgId = turnedCard:getCardCfgId()
        local level = turnedCard:getCardLevel()
        itemId = TurnedCardUtils.GetUnlockItemId(cfgId, level)
      end
      if itemId > 0 then
        ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, false)
      end
    end
  end
end
def.method("string", "boolean").onToggle = function(self, id, active)
  if active then
    if id == "Tab_01" then
      if self.m_panel and not self.m_panel.isnil then
        self.m_panel:FindDirect("Img_Key0/Group_01"):SetActive(true)
      end
      self.curPage = math.ceil(self.emojiCount / self.emojiPage)
      local emojiGroup = self.m_panel:FindDirect("Img_Key0/Group_01/Scroll View01/Grid_Page01")
      emojiGroup:GetComponent("UIGrid"):Reposition()
      for i = 1, self.curPage do
        local page = emojiGroup:FindDirect(string.format("Page%02d/Grid_01", i))
        page:GetComponent("UIGrid"):Reposition()
      end
      self:resetPoints()
      GameUtil.AddGlobalLateTimer(0, true, function()
        if self.m_panel and not self.m_panel.isnil then
          self.m_panel:FindDirect("Img_Key0/Group_01/Scroll View01"):GetComponent("UIScrollView"):ResetPosition()
        end
      end)
    elseif id == "Tab_02" then
      if self.m_panel and not self.m_panel.isnil then
        self.m_panel:FindDirect("Img_Key0/Group_02"):SetActive(true)
      end
      self.curPage = math.ceil(self.moodsCount / self.moodPage)
      local moodGroup = self.m_panel:FindDirect("Img_Key0/Group_02/Scroll View02/Grid_Page02")
      moodGroup:GetComponent("UIGrid"):Reposition()
      for i = 1, self.curPage do
        local page = moodGroup:FindDirect(string.format("Page%02d/Grid_02", i))
        page:GetComponent("UIGrid"):Reposition()
      end
      self:resetPoints()
      GameUtil.AddGlobalLateTimer(0, true, function()
        self.m_panel:FindDirect("Img_Key0/Group_02/Scroll View02"):GetComponent("UIScrollView"):ResetPosition()
      end)
    elseif id == "Tab_03" then
      if self.m_panel and not self.m_panel.isnil then
        self.m_panel:FindDirect("Img_Key0/Group_03"):SetActive(true)
      end
      self:SetInventory()
      self:resetPoints()
      GameUtil.AddGlobalLateTimer(0, true, function()
        self.m_panel:FindDirect("Img_Key0/Group_03/Scroll View03"):GetComponent("UIScrollView"):ResetPosition()
      end)
    elseif id == "Tab_04" then
      if self.m_panel and not self.m_panel.isnil then
        self.m_panel:FindDirect("Img_Key0/Group_04"):SetActive(true)
      end
      self:SetPet()
      self:resetPoints()
      GameUtil.AddGlobalLateTimer(0, true, function()
        self.m_panel:FindDirect("Img_Key0/Group_04/Scroll View04"):GetComponent("UIScrollView"):ResetPosition()
      end)
    elseif id == "Tab_05" then
      if self.m_panel and not self.m_panel.isnil then
        self.m_panel:FindDirect("Img_Key0/Group_05"):SetActive(true)
      end
      self:SetTask()
      self:resetPoints()
      GameUtil.AddGlobalLateTimer(0, true, function()
        self.m_panel:FindDirect("Img_Key0/Group_05/Scroll View05"):GetComponent("UIScrollView"):ResetPosition()
      end)
    elseif id == "Tab_06" then
      if self.m_panel and not self.m_panel.isnil then
        self.m_panel:FindDirect("Img_Key0/Group_06"):SetActive(true)
      end
      self:SetHistory()
      self:resetPoints()
      GameUtil.AddGlobalLateTimer(0, true, function()
        self.m_panel:FindDirect("Img_Key0/Group_06/Scroll View06"):GetComponent("UIScrollView"):ResetPosition()
      end)
    elseif id == "Tab_07" then
      if self.m_panel and not self.m_panel.isnil then
        self.m_panel:FindDirect("Img_Key0/Group_03"):SetActive(true)
      end
      self:SetFabao()
      self:resetPoints()
      GameUtil.AddGlobalLateTimer(0, true, function()
        self.m_panel:FindDirect("Img_Key0/Group_03/Scroll View03"):GetComponent("UIScrollView"):ResetPosition()
      end)
    elseif id == "Tab_10" then
      if self.m_panel and not self.m_panel.isnil then
        self.m_panel:FindDirect("Img_Key0/Group_10"):SetActive(true)
      end
      self:SetChengwei()
      self:resetPoints()
      GameUtil.AddGlobalLateTimer(0, true, function()
        self.m_panel:FindDirect("Img_Key0/Group_10/Scroll View05"):GetComponent("UIScrollView"):ResetPosition()
      end)
    elseif id == "Tab_11" then
      if self.m_panel and not self.m_panel.isnil then
        self.m_panel:FindDirect("Img_Key0/Group_11"):SetActive(true)
      end
      self:SetTouxian()
      self:resetPoints()
      GameUtil.AddGlobalLateTimer(0, true, function()
        self.m_panel:FindDirect("Img_Key0/Group_11/Scroll View05"):GetComponent("UIScrollView"):ResetPosition()
      end)
    elseif id == "Tab_12" then
      if self.m_panel and not self.m_panel.isnil then
        self.m_panel:FindDirect("Img_Key0/Group_12"):SetActive(true)
      end
      self:SetMounts()
      self:resetPoints()
      GameUtil.AddGlobalLateTimer(0, true, function()
        self.m_panel:FindDirect("Img_Key0/Group_12/Scroll View04"):GetComponent("UIScrollView"):ResetPosition()
      end)
    elseif id == "Tab_13" then
      if self.m_panel and not self.m_panel.isnil then
        self.m_panel:FindDirect("Img_Key0/Group_13"):SetActive(true)
      end
      self:SetChildren()
      self:resetPoints()
      GameUtil.AddGlobalLateTimer(0, true, function()
        self.m_panel:FindDirect("Img_Key0/Group_13/Scroll View04"):GetComponent("UIScrollView"):ResetPosition()
      end)
    elseif id == "Tab_08" then
      if self.m_panel and not self.m_panel.isnil then
        self.m_panel:FindDirect("Img_Key0/Group_08"):SetActive(true)
      end
      self:SetMembers()
      self:resetPoints()
      GameUtil.AddGlobalLateTimer(0, true, function()
        self.m_panel:FindDirect("Img_Key0/Group_08/Scroll View"):GetComponent("UIScrollView"):ResetPosition()
      end)
    elseif id == "Tab_14" then
      if not _G.IsNil(self.m_panel) then
        self.m_panel:FindDirect("Img_Key0/Group_14"):SetActive(true)
      end
      self:SetTurnedCards()
      self:resetPoints()
      GameUtil.AddGlobalLateTimer(0, true, function()
        self.m_panel:FindDirect("Img_Key0/Group_14/Scroll View03"):GetComponent("UIScrollView"):ResetPosition()
      end)
    end
  else
  end
end
def.method("string", "userdata", "number", "table").onSpringFinish = function(self, id, scrollView, type, position)
  if self.m_panel == nil then
    return
  end
  if scrollView:get_childCount() > 0 then
    local centerOnChild = scrollView:GetChild(0):GetComponent("UICenterOnChild")
    if centerOnChild then
      local conterObject = centerOnChild:get_centeredObject()
      local index = tonumber(string.sub(conterObject.name, -2, -1))
      if index then
        local toggleObj = self.m_panel:FindDirect(string.format("Img_Key0/Img_Bg1/Grid_Pages/Img_Pages%02d", index))
        if toggleObj ~= nil then
          local pointToggle = toggleObj:GetComponent("UIToggle")
          if pointToggle ~= nil then
            pointToggle:set_value(true)
          end
        end
      end
    end
  end
end
def.method("number", "=>", "boolean").IsHostNeededMenu = function(self, menuType)
  if self.hostInput == nil then
    return true
  end
  if Lplus.is(self.hostInput, Lplus.Object) and self.hostInput:tryget("IsNeededMenu") and not self.hostInput:IsNeededMenu(menuType) then
    return false
  end
  return true
end
def.method().SetMembers = function(self)
  self:ClearMembers()
  self.memberList = AtUtils.GetChannelMemberList()
  local memberNum = self.memberList and #self.memberList or 0
  local pageCount = math.ceil(memberNum / self.memberPage)
  self.curPage = pageCount
  local membersGroup = self.m_panel:FindDirect("Img_Key0/Group_08/Scroll View/Grid_Page")
  local membersPageTemplate = membersGroup:FindDirect("Page")
  membersPageTemplate:SetActive(false)
  for i = 1, pageCount do
    local memberPage = Object.Instantiate(membersPageTemplate)
    memberPage:SetActive(true)
    memberPage.name = string.format("Page%02d", i)
    memberPage.parent = membersGroup
    memberPage:set_localScale(Vector.Vector3.one)
    local memberTemplate = memberPage:FindDirect("Grid/PlayerInfor")
    memberTemplate:SetActive(false)
  end
  membersGroup:GetComponent("UIGrid"):Reposition()
  local memberTemplate = membersPageTemplate:FindDirect("Grid/PlayerInfor")
  memberTemplate:SetActive(false)
  for idx, chatMember in ipairs(self.memberList) do
    local memberObj = Object.Instantiate(memberTemplate)
    local page = math.ceil(idx / self.memberPage)
    memberObj.name = string.format("member_%d", idx)
    memberObj.parent = membersGroup:FindDirect(string.format("Page%02d/Grid", page))
    memberObj:set_localScale(Vector.Vector3.one)
    self:ShowMember(idx, memberObj, chatMember)
    memberObj:SetActive(true)
  end
  for i = 1, pageCount do
    local page = membersGroup:FindDirect(string.format("Page%02d/Grid", i))
    page:GetComponent("UIGrid"):Reposition()
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("number", "userdata", "table").ShowMember = function(self, idx, memberObj, memberInfo)
  if nil == memberObj then
    warn("[ERROR][ChatInputDlg:ShowMember] memberObj nil at idx:", idx)
    return
  end
  if nil == memberInfo then
    warn("[ERROR][ChatInputDlg:ShowMember] memberInfo nil at idx:", idx)
    GUIUtils.SetActive(memberObj, false)
    return
  end
  local headTexture = memberObj:FindDirect("Img_HeadBg/Texture")
  _G.SetAvatarIcon(headTexture, memberInfo.avatarId)
  local Img_AvatarFrame = memberObj:FindDirect("Img_HeadBg/Img_AvatarFrame")
  _G.SetAvatarFrameIcon(Img_AvatarFrame, memberInfo.avatarFrameId)
  local Label_Name = memberObj:FindDirect("Label_Name")
  GUIUtils.SetText(Label_Name, memberInfo.name)
  local Label_Zhiwei = memberObj:FindDirect("Label_Zhiwei")
  GUIUtils.SetText(Label_Zhiwei, memberInfo:GetDutyName())
  local Img_Sex = memberObj:FindDirect("Img_Sex")
  GUIUtils.SetSprite(Img_Sex, GUIUtils.GetSexIcon(memberInfo.gender))
  local Label_Level = memberObj:FindDirect("Label_Level")
  GUIUtils.SetText(Label_Level, memberInfo.level)
  local Img_Class = memberObj:FindDirect("Img_Class")
  GUIUtils.SetSprite(Img_Class, GUIUtils.GetOccupationSmallIcon(memberInfo.occupationId))
end
def.method().ClearMembers = function(self)
  self.memberList = nil
  local pages = self.m_panel:FindDirect("Img_Key0/Group_08/Scroll View/Grid_Page")
  while pages:get_childCount() > 1 do
    Object.DestroyImmediate(pages:GetChild(pages:get_childCount() - 1))
  end
  local grid = self.m_panel:FindDirect("Img_Key0/Group_08/Scroll View/Grid_Page/Page/Grid")
  while grid:get_childCount() > 1 do
    Object.DestroyImmediate(grid:GetChild(grid:get_childCount() - 1))
  end
end
def.method("number", "=>", "table").getCardCfgByItemId = function(self, itemId)
  local itemBase = ItemUtils.GetItemBase(itemId)
  local cardCfg
  if itemBase.itemType == ItemType.CHANGE_MODEL_CARD_ITEM then
    local cardItemCfg = TurnedCardUtils.GetChangeModelCardItemCfg(itemId)
    if cardItemCfg then
      cardCfg = TurnedCardUtils.GetChangeModelCardCfg(cardItemCfg.cardCfgId)
    end
  elseif itemBase.itemType == ItemType.CHANGE_MODEL_CARD_FRAGMENT then
    local cardFragmentCfg = TurnedCardUtils.GetChangeModelCardFragmentCfg(itemId)
    if cardFragmentCfg then
      cardCfg = TurnedCardUtils.GetChangeModelCardCfg(cardFragmentCfg.cardCfgId)
    end
  end
  return cardCfg
end
def.method("table", "=>", "number", "number").getLevelAndCfgId = function(self, t)
  if t.isItem then
    local itemId = t.info.id
    local itemBase = ItemUtils.GetItemBase(itemId)
    if itemBase.itemType == ItemType.CHANGE_MODEL_CARD_ITEM then
      local cardItemCfg = TurnedCardUtils.GetChangeModelCardItemCfg(itemId)
      if cardItemCfg then
        return cardItemCfg.cardLevel, itemId
      end
    elseif itemBase.itemType == ItemType.CHANGE_MODEL_CARD_FRAGMENT then
      local cardFragmentCfg = TurnedCardUtils.GetChangeModelCardFragmentCfg(itemId)
      if cardFragmentCfg then
        return cardFragmentCfg.cardLevel, itemId
      end
    end
    warn("!!!!!!!getLevel not cardItem or not cardFragment:", itemId)
    return 1, itemId
  end
  local turnedCard = t.info
  local level = turnedCard:getCardLevel()
  local id = turnedCard:getCardCfgId()
  return level, id
end
def.method("=>", "table").getSortTurnedCardList = function(self)
  local turnedCardList = {}
  local cardList = TurnedCardInterface.Instance():getAllTurnedCards()
  if cardList then
    for i, v in pairs(cardList) do
      local t = {isItem = false, info = v}
      table.insert(turnedCardList, t)
    end
  end
  local items = ItemData.Instance():GetBag(ItemModule.CHANGE_MODEL_CARD_BAG)
  if items then
    for i, v in pairs(items) do
      local t = {isItem = true, info = v}
      table.insert(turnedCardList, t)
    end
  end
  local function comp(t1, t2)
    local level1, id1 = self:getLevelAndCfgId(t1)
    local level2, id2 = self:getLevelAndCfgId(t2)
    if level1 == level2 then
      return id1 > id2
    else
      return level1 > level2
    end
  end
  table.sort(turnedCardList, comp)
  return turnedCardList
end
def.method().SetTurnedCards = function(self)
  self:ClearTurnedCards()
  local turnedCardList = self:getSortTurnedCardList()
  self.turnedCardList = turnedCardList
  local turnedCardListNum = #turnedCardList
  local TurnedCardGroup = self.m_panel:FindDirect("Img_Key0/Group_14/Scroll View03/Grid_Page03")
  local TurnedCardPageTemplate = TurnedCardGroup:FindDirect("Page01")
  TurnedCardPageTemplate:SetActive(true)
  TurnedCardPageTemplate:FindDirect("Grid_03/item"):SetActive(false)
  local turnedCardInterface = TurnedCardInterface.Instance()
  local pageCount = math.ceil(turnedCardListNum / self.turnedCardPage)
  self.curPage = pageCount
  for i = 2, pageCount do
    local turnedCardPage = Object.Instantiate(TurnedCardPageTemplate)
    turnedCardPage.name = string.format("Page%02d", i)
    turnedCardPage.parent = TurnedCardGroup
    turnedCardPage:set_localScale(Vector.Vector3.one)
    turnedCardPage:SetActive(true)
  end
  TurnedCardGroup:GetComponent("UIGrid"):Reposition()
  local turnedCardTemplate = TurnedCardPageTemplate:FindDirect("Grid_03/item")
  turnedCardTemplate:SetActive(false)
  for i, v in ipairs(turnedCardList) do
    local TurnedCard = Object.Instantiate(turnedCardTemplate)
    TurnedCard:SetActive(true)
    local page = math.ceil(i / self.turnedCardPage)
    TurnedCard.name = string.format("TurnedCard%d", i)
    TurnedCard.parent = TurnedCardGroup:FindDirect(string.format("Page%02d/Grid_03", page))
    TurnedCard:set_localScale(Vector.Vector3.one)
    local Icon = TurnedCard:FindDirect("Icon")
    local Label_PowerLv = TurnedCard:FindDirect("Label_PowerLv")
    local Img_Tpye = TurnedCard:FindDirect("Img_Tpye")
    if v.isItem then
      local itemInfo = v.info
      local cardCfg = self:getCardCfgByItemId(itemInfo.id)
      local itemBase = ItemUtils.GetItemBase(itemInfo.id)
      GUIUtils.SetSprite(TurnedCard, ItemUtils.GetItemFrame(itemInfo, itemBase))
      GUIUtils.FillIcon(Icon:GetComponent("UITexture"), itemBase.icon)
      if cardCfg then
        Img_Tpye:SetActive(true)
        local classCfg = TurnedCardUtils.GetCardClassCfg(cardCfg.classType)
        GUIUtils.FillIcon(Img_Tpye:GetComponent("UITexture"), classCfg.smallIconId)
        Label_PowerLv:GetComponent("UILabel"):set_text(turnedCardInterface:getTurnedCardQualityStr(cardCfg.quality))
      end
    else
      local curCard = v.info
      local info = curCard:getCardInfo()
      if info then
        local level = curCard:getCardLevel()
        TurnedCard:GetComponent("UISprite"):set_spriteName(TurnedCardUtils.TurnedCardLevelFrame[level])
        local cardCfg = TurnedCardUtils.GetChangeModelCardCfg(info.card_cfg_id)
        GUIUtils.FillIcon(Icon:GetComponent("UITexture"), cardCfg.iconId)
        local classCfg = TurnedCardUtils.GetCardClassCfg(cardCfg.classType)
        GUIUtils.FillIcon(Img_Tpye:GetComponent("UITexture"), classCfg.smallIconId)
        Label_PowerLv:GetComponent("UILabel"):set_text(turnedCardInterface:getTurnedCardQualityStr(cardCfg.quality))
      end
    end
  end
  for i = 1, pageCount do
    local page = TurnedCardGroup:FindDirect(string.format("Page%02d/Grid_03", i))
    page:GetComponent("UIGrid"):Reposition()
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
  local Label_Tips03 = self.m_panel:FindDirect("Img_Key0/Group_14/Img_BgTips03/Label_Tips03")
  Label_Tips03:GetComponent("UILabel"):set_text(textRes.Chat[93])
end
def.method().ClearTurnedCards = function(self)
  self.turnedCardList = nil
  local pages = self.m_panel:FindDirect("Img_Key0/Group_14/Scroll View03/Grid_Page03")
  while pages:get_childCount() > 1 do
    Object.DestroyImmediate(pages:GetChild(pages:get_childCount() - 1))
  end
  local grid = self.m_panel:FindDirect("Img_Key0/Group_14/Scroll View03/Grid_Page03/Page01/Grid_03")
  while grid:get_childCount() > 1 do
    Object.DestroyImmediate(grid:GetChild(grid:get_childCount() - 1))
  end
end
ChatInputDlg.Commit()
return ChatInputDlg
