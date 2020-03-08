local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ECUIModel = require("Model.ECUIModel")
local HeroModule = require("Main.Hero.HeroModule")
local DyeingMgr = require("Main.Dyeing.DyeingMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local RolePartEnum = require("consts.mzm.gsp.occupation.confbean.RolePartEnum")
local WingInterface = require("Main.Wing.WingInterface")
local FashionData = require("Main.Fashion.FashionData")
local FashionUtils = require("Main.Fashion.FashionUtils")
local FashionDressConst = require("netio.protocol.mzm.gsp.fashiondress.FashionDressConst")
local OccupationEnum = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
local GenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
local DyeingPanel = Lplus.Extend(ECPanelBase, "DyeingPanel")
local def = DyeingPanel.define
def.field("boolean").m_ShowWing = false
def.field("table").m_ListData = nil
def.field("table").m_ItemData = nil
def.field("table").m_DyeOriIndex = nil
def.field("table").m_DyeIndex = nil
def.field("table").m_Model = nil
def.field("table").m_UIGO = nil
def.field("table").mapItemPrice = nil
local instance
def.static("=>", DyeingPanel).Instance = function()
  if not instance then
    instance = DyeingPanel()
  end
  return instance
end
def.static("table", "table").OnBagInfoSyncronized = function(params)
  if instance and instance.m_panel and not instance.m_panel.isnil then
    instance:UpdateRightBottomView(true)
  end
end
def.static("table", "table")._OnColorDataChanged = function(params, context)
  if instance and instance.m_panel and not instance.m_panel.isnil then
    instance:InitData()
    instance:Update()
  end
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_DYE_PANEL, GUILEVEL.MUTEX)
  self:SetModal(true)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:ResetModelAnimation()
    self:UpdateRightBottomView(true)
  end
end
def.override().OnCreate = function(self)
  self.mapItemPrice = {}
  self:InitUI()
  self:InitData()
  self:Update()
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, DyeingPanel.OnBagInfoSyncronized)
  Event.RegisterEvent(ModuleId.DYEING, gmodule.notifyId.Dyeing.UPDATE_COLOR_DATA, DyeingPanel._OnColorDataChanged)
  Event.RegisterEvent(ModuleId.DYEING, gmodule.notifyId.Dyeing.UPDATE_CLOSET, DyeingPanel._OnColorDataChanged)
end
def.override().OnDestroy = function(self)
  if self.m_Model then
    self.m_Model:Destroy()
  end
  self.m_ShowWing = false
  self.m_ListData = nil
  self.m_DyeIndex = nil
  self.m_ItemData = nil
  self.mapItemPrice = nil
  self.m_Model = nil
  self.m_UIGO = nil
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, DyeingPanel.OnBagInfoSyncronized)
  Event.UnregisterEvent(ModuleId.DYEING, gmodule.notifyId.Dyeing.UPDATE_COLOR_DATA, DyeingPanel._OnColorDataChanged)
  Event.UnregisterEvent(ModuleId.DYEING, gmodule.notifyId.Dyeing.UPDATE_CLOSET, DyeingPanel._OnColorDataChanged)
end
def.method().Settle = function(self)
  local check = false
  for _, v in pairs(DyeingMgr.PARTINDEX) do
    if self.m_DyeIndex[v] ~= self.m_DyeOriIndex[v] then
      check = true
    end
  end
  if not check then
    Toast(textRes.Dyeing[15])
    return
  end
  local bUseYB = self:IsUseYB()
  if DyeingMgr.IsUseYBFeatureOpen() and not bUseYB and not self:IsNeedItemsEnough() then
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm(textRes.Dyeing[31], textRes.Dyeing[32], function(select)
      if select == 1 then
        self.m_UIGO.BtnUseYB:GetComponent("UIToggle").value = true
        self:OnToggleUseYB(true)
      else
        self.m_UIGO.BtnUseYB:GetComponent("UIToggle").value = false
      end
    end, nil)
    return
  end
  local params = {}
  local mapNeedYB = self:GetPartNeedYB()
  for k, v in pairs(DyeingMgr.PARTINDEX) do
    local index = self.m_DyeIndex[v]
    local id = self.m_ListData[v][index] and self.m_ListData[v][index].id or 0
    local itemData = self.m_ItemData[v]
    if k == "HAIR" then
      params.hairid = id
      params.hairItemCfgId2useyuanbao = mapNeedYB[DyeingMgr.PARTINDEX.HAIR]
    elseif k == "CLOTH" then
      params.clothid = id
      params.clothItemCfgId2useyuanbao = mapNeedYB[DyeingMgr.PARTINDEX.CLOTH]
    end
  end
  params.fashionDressCfgId = FashionData.Instance().currentFashionId
  DyeingMgr.Settle(params)
end
def.method().OpenClosetPanel = function(self)
  Event.DispatchEvent(ModuleId.DYEING, gmodule.notifyId.Dyeing.BTN_OPEN_CLOSET_CLICK, nil)
end
def.method("boolean").ChangeModelScale = function(self, expand)
  DyeingMgr.ChangeModelScale(expand, self.m_Model)
end
def.method().ResetModelAnimation = function(self)
  if self.m_Model then
    self.m_Model:Play("Stand_c")
  end
end
def.method("number", "userdata").ChangeModelColor = function(self, partIndex, color)
  DyeingMgr.ChangeModelColor(partIndex, self.m_Model, color)
end
def.method("number", "number").OnChangeColor = function(self, partIndex, index)
  self.m_DyeIndex[partIndex] = index
  local item = self.m_ListData[partIndex][index]
  if item then
    local color = Color.Color(item.r / 255, item.g / 255, item.b / 255, item.a / 255)
    self:ChangeModelColor(partIndex, color)
    self:UpdatComsumeItemData(partIndex, item)
    self:UpdateRightBottomView(true)
  end
  self:UpdateRightTopView()
end
def.method("=>", "boolean").IsUseYB = function(self)
  return self.m_UIGO.BtnUseYB:GetComponent("UIToggle").value
end
def.method("boolean").OnToggleUseYB = function(self, bUseYB)
  if bUseYB then
    local function funcQuery(itemId)
      local itemId = itemId
      require("Main.Item.ItemConsumeHelper").Instance():GetItemYuanBaoPrice(itemId, function(price)
        self.mapItemPrice[itemId] = price
        for k, v in pairs(self.mapItemPrice) do
          if v == -1 then
            return
          end
        end
        self:UpdateRightBottomView(true)
      end)
    end
    for i = 1, 2 do
      local itemId = self.m_ItemData[DyeingMgr.PARTINDEX.CLOTH]["id" .. i]
      self.mapItemPrice[itemId] = -1
      funcQuery(itemId)
    end
  else
    for k, v in pairs(self.mapItemPrice) do
      self.mapItemPrice[k] = -1
    end
    self:UpdateRightBottomView(true)
  end
end
def.method().Revert = function(self)
  if self.m_Model then
    for k, v in pairs(DyeingMgr.PARTINDEX) do
      local index = self.m_DyeOriIndex[v]
      if index then
        self.m_DyeIndex[v] = index
      end
      local item = self.m_ListData[v][index]
      if item then
        local color = Color.Color(item.r / 255, item.g / 255, item.b / 255, item.a / 255)
        self:ChangeModelColor(v, color)
      end
    end
    self:UpdateRightTopView()
    self:UpdateRightBottomView(true)
  end
end
def.method().ChangeModelWing = function(self)
  self.m_ShowWing = not self.m_ShowWing
  if not self.m_ShowWing then
    self.m_Model:SetWing(0, 0)
  else
    local wingId, colorId = WingInterface.GetCurWingOutLookAndColorId()
    if wingId <= 0 then
      Toast(textRes.Dyeing[28])
      return
    end
    self.m_Model:SetWing(wingId, colorId)
  end
  self:UpdateBtnView()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Settle" then
    self:Settle()
  elseif id == "Btn_Minus" then
    self:ChangeModelScale(false)
  elseif id == "Btn_Add" then
    self:ChangeModelScale(true)
  elseif id == "Btn_Closet" then
    self:OpenClosetPanel()
  elseif id == "Btn_Revert" then
    self:Revert()
  elseif id == "Btn_YY" then
    self:ChangeModelWing()
  elseif id:find("HairColor") == 1 then
    local i, j = id:find("%a%d_%d")
    i = tonumber(id:sub(i + 1, i + 1))
    j = tonumber(id:sub(j, j))
    local index = (j - 1) * 6 + i
    self:OnChangeColor(2, index)
  elseif id:find("ClothColor") == 1 then
    local i, j = id:find("%a%d_%d")
    i = tonumber(id:sub(i + 1, i + 1))
    j = tonumber(id:sub(j, j))
    local index = (j - 1) * 6 + i
    self:OnChangeColor(1, index)
  elseif id:find("Item_Use") == 1 then
    local _, lastIndex = id:find("Item_Use")
    local index = tonumber(id:sub(lastIndex + 1, id:len()))
    local item = self.m_ItemData[1] or self.m_ItemData[2]
    local itemId = item[("id%d"):format(index)]
    local btnGO = self.m_UIGO[id]
    if not id or not btnGO then
      return
    end
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, btnGO, -1, true)
  elseif "Btn_YuanbaoUse" == id then
    local bUseYB = self:IsUseYB()
    if not bUseYB then
      self:OnToggleUseYB(false)
      return
    end
    if self:IsNeedItemsEnough() then
      Toast(textRes.Dyeing[34])
      self.m_UIGO.BtnUseYB:GetComponent("UIToggle").value = false
    else
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      CommonConfirmDlg.ShowConfirm(textRes.Dyeing[31], textRes.Dyeing[32], function(select)
        if select == 1 then
          self.m_UIGO.BtnUseYB:GetComponent("UIToggle").value = true
          self:OnToggleUseYB(true)
        else
          self.m_UIGO.BtnUseYB:GetComponent("UIToggle").value = false
        end
      end, nil)
    end
  end
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if id:find("Img_Bg0") == 1 then
    self.m_Model:SetDir(self.m_Model.m_ang - dx / 2)
  end
end
def.method("number", "number", "=>", "number").FindOrginIndex = function(self, partIndex, id)
  local listData = self.m_ListData[partIndex]
  local index = 0
  if listData then
    for k, v in pairs(listData) do
      if v.id == id then
        index = k
        break
      end
    end
  else
    warn("Can't find the OrginIndex", partIndex, id)
  end
  self.m_DyeOriIndex[partIndex] = index
  return index
end
def.method().InitData = function(self)
  self.m_ListData = {}
  self.m_ItemData = {}
  self.m_DyeIndex = {}
  self.m_DyeOriIndex = {}
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local menpai = heroProp.occupation
  local gender = heroProp.gender
  local currentFashionId = FashionData.Instance().currentFashionId
  local fashionDressDyeType = -1
  local currentFashionItem = FashionUtils.GetFashionItemDataById(currentFashionId)
  if currentFashionItem ~= nil then
    fashionDressDyeType = currentFashionItem.fashionDressDyeType
  end
  local function IsSameOccupation(occupationA, occupationB)
    return occupationA == occupationB or occupationA == OccupationEnum.ALL or occupationB == OccupationEnum.ALL
  end
  local function IsSameGender(genderA, genderB)
    return genderA == genderB or genderA == GenderEnum.ALL or genderB == GenderEnum.ALL
  end
  for _, v in pairs(DyeingMgr.PARTINDEX) do
    self.m_ListData[v] = {}
  end
  local listData = DyeingMgr.GetClothListData()
  local colorFormulas = DyeingMgr.GetAllColorFormula()
  for k, v in pairs(colorFormulas) do
    if v.part == RolePartEnum.ROLE_PART_HAIR and IsSameOccupation(v.menpai, menpai) and IsSameGender(v.gender, gender) and v.fashionDressTypeId == fashionDressDyeType then
      table.insert(self.m_ListData[DyeingMgr.PARTINDEX.HAIR], v)
    elseif v.part == RolePartEnum.ROLE_PART_CLOTH and IsSameOccupation(v.menpai, menpai) and IsSameGender(v.gender, gender) and v.fashionDressTypeId == fashionDressDyeType then
      table.insert(self.m_ListData[DyeingMgr.PARTINDEX.CLOTH], v)
    end
  end
  for _, v in pairs(DyeingMgr.PARTINDEX) do
    table.sort(self.m_ListData[v], function(l, r)
      return l.s < r.s
    end)
  end
  local curId = DyeingMgr.GetClothCurIndex()
  local ids = {
    CLOTH = listData[curId] and listData[curId].clothid or 0,
    HAIR = listData[curId] and listData[curId].hairid or 0
  }
  for k, v in pairs(DyeingMgr.PARTINDEX) do
    local ogrinIndex = self:FindOrginIndex(v, ids[k])
    self.m_DyeIndex[v] = ogrinIndex
    self:UpdatComsumeItemData(v, self.m_ListData[v][ogrinIndex])
  end
  local wingId = WingInterface.GetCurWingId()
  self.m_ShowWing = wingId > 0 and true or false
end
def.method("number", "table").UpdatComsumeItemData = function(self, type, item)
  if item == nil then
    return
  end
  local itemId1 = item.itemid1
  local itemCount1 = item.itemcount1
  local itemId2 = item.itemid2
  local itemCount2 = item.itemcount2
  if not self.m_ItemData[type] then
    self.m_ItemData[type] = {}
  end
  self.m_ItemData[type].id1 = itemId1
  self.m_ItemData[type].count1 = itemCount1
  self.m_ItemData[type].id2 = itemId2
  self.m_ItemData[type].count2 = itemCount2
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  for i = 1, 2 do
    local itemGO = self.m_panel:FindDirect(("Img_Bg0/Group_ItemUse/Item_Use%d"):format(i))
    self.m_UIGO[("Item_Use%d"):format(i)] = itemGO
    self.m_UIGO[("item%dTexture"):format(i)] = itemGO:FindDirect("Texture")
    self.m_UIGO[("item%dName"):format(i)] = itemGO:FindDirect("Label")
    self.m_UIGO[("item%dNum"):format(i)] = itemGO:FindDirect("Label/Label")
    GUIUtils.SetActive(itemGO, false)
  end
  self.m_UIGO.List2 = self.m_panel:FindDirect("Img_Bg0/Group_Right/Img_Hair/Scroll View/List_Color")
  self.m_UIGO.EmptyList2 = self.m_panel:FindDirect("Img_Bg0/Group_Right/Img_Hair/Label_Empty")
  self.m_UIGO.List1 = self.m_panel:FindDirect("Img_Bg0/Group_Right/Img_Cloth/Scroll View/List_Color")
  self.m_UIGO.EmptyList1 = self.m_panel:FindDirect("Img_Bg0/Group_Right/Img_Cloth/Label_Empty")
  self.m_UIGO.UIModel = self.m_panel:FindDirect("Img_Bg0/Group_Left/Model")
  self.m_UIGO.BtnLabel = self.m_panel:FindDirect("Img_Bg0/Group_Left/Btn_YY/Label")
  self.m_UIGO.FashionGroup = self.m_panel:FindDirect("Img_Bg0/Group_Left/Label_Fashion")
  self.m_UIGO.FashionLabel = self.m_UIGO.FashionGroup:FindDirect("Label")
  self.m_UIGO.BtnUseYB = self.m_panel:FindDirect("Img_Bg0/Group_ItemUse/Btn_YuanbaoUse")
  self.m_UIGO.BtnUseYB:GetComponent("UIToggle").value = false
  self.m_UIGO.BtnSettle = self.m_panel:FindDirect("Img_Bg0/Group_ItemUse/Btn_Settle")
  self.m_UIGO.LblSettle = self.m_UIGO.BtnSettle:FindDirect("Label_Settle")
  self.m_UIGO.BtnMakeUseYB = self.m_UIGO.BtnSettle:FindDirect("Group_MoneyMake")
  self.m_UIGO.BtnMakeUseYB:SetActive(false)
  self.m_UIGO.lblOwnTips = self.m_panel:FindDirect("Img_Bg0/Label_Tips")
  self.m_UIGO.lblOwnTips:SetActive(false)
end
def.method().UpdateUIModel = function(self)
  local uiModel = self.m_UIGO.UIModel:GetComponent("UIModel")
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  local function AfterModelLoad()
    self.m_Model:SetDir(180)
    self.m_Model:SetScale(1)
    self.m_Model:SetPos(0, 0)
    self:ResetModelAnimation()
    local m = self.m_Model.m_model
    uiModel.modelGameObject = m
    uiModel.mCanOverflow = true
    if not self.m_ShowWing then
      self.m_Model:SetWing(0, 0)
    else
      local wingId, colorId = WingInterface.GetCurWingOutLookAndColorId()
      self.m_Model:SetWing(wingId, colorId)
    end
  end
  if self.m_Model then
    self.m_Model:Destroy()
    self.m_Model = nil
  end
  local modelInfo = DyeingMgr.Instance():GetDyeShowModelInfo()
  self.m_Model = ECUIModel.new(modelInfo.modelid)
  self.m_Model.m_bUncache = true
  self.m_Model:AddOnLoadCallback("FashionPanel", AfterModelLoad)
  _G.LoadModel(self.m_Model, modelInfo, 0, 0, 180, false, false)
  local fashionData = FashionData.Instance()
  if fashionData.currentFashionId ~= FashionDressConst.NO_FASHION_DRESS then
    self.m_UIGO.FashionGroup:SetActive(true)
    local itemData = FashionUtils.GetFashionItemDataById(fashionData.currentFashionId)
    self.m_UIGO.FashionGroup:GetComponent("UILabel"):set_text(itemData.fashionDressName)
  else
    self.m_UIGO.FashionGroup:SetActive(false)
  end
end
def.method().UpdateRightTopView = function(self)
  local colorType = {"ClothColor", "HairColor"}
  for i = 1, 2 do
    local uiListEmpty = self.m_UIGO[("EmptyList%d"):format(i)]
    local uiListGO = self.m_UIGO[("List%d"):format(i)]
    local itemDatas = self.m_ListData[i]
    if #itemDatas == 0 then
      GUIUtils.SetActive(uiListEmpty, true)
      GUIUtils.SetText(uiListEmpty, textRes.Dyeing[29])
      GUIUtils.SetActive(uiListGO, false)
    else
      GUIUtils.SetActive(uiListEmpty, false)
      GUIUtils.SetActive(uiListGO, true)
      local itemCount = math.floor(#itemDatas / 7) + 1
      local remain = math.fmod(#itemDatas, 6)
      local listItems = GUIUtils.InitUIList(uiListGO, itemCount)
      self.m_msgHandler:Touch(uiListGO)
      for j = 1, itemCount do
        local itemGO = listItems[j]
        for k = 1, 6 do
          local itemData = itemDatas[(j - 1) * 6 + k]
          local goName = colorType[i] .. k .. "_" .. j
          local colorGO = itemGO:FindDirect(goName)
          local labelGO = itemGO:FindDirect(("%s%d_%d/Label_%d"):format(colorType[i], k, j, j))
          local selectGO = itemGO:FindDirect(("%s%d_%d/Group_%d/Img_Select_%d"):format(colorType[i], k, j, j, j))
          local spriteGO = itemGO:FindDirect(("%s%d_%d"):format(colorType[i], k, j))
          GUIUtils.SetActive(colorGO, itemData ~= nil)
          if itemData then
            GUIUtils.SetActive(labelGO, false)
            GUIUtils.SetActive(selectGO, (j - 1) * 6 + k == self.m_DyeIndex[i])
            local alpha = itemData.a / 255 * 2
            GUIUtils.SetColor(spriteGO, Color.Color(itemData.r / 255 * alpha, itemData.g / 255 * alpha, itemData.b / 255 * alpha, 1), GUIUtils.COTYPE.SPRITE)
          end
        end
      end
      GUIUtils.Reposition(uiListGO, GUIUtils.COTYPE.LIST, 0)
    end
  end
end
def.method("boolean").UpdateRightBottomView = function(self, flag)
  local itemDatas = self.m_ItemData
  local totalNeedYB = 0
  local bUseYB = self:IsUseYB()
  local bOwnCurrentDye = self:IsOwnCurrentDyeing()
  for i = 1, 2 do
    local itemGO = self.m_UIGO[("Item_Use%d"):format(i)]
    local iconGO = self.m_UIGO[("item%dTexture"):format(i)]
    local nameGO = self.m_UIGO[("item%dName"):format(i)]
    local numGO = self.m_UIGO[("item%dNum"):format(i)]
    local maxCount = 0
    local id = 0
    for k, v in pairs(itemDatas) do
      if self.m_DyeIndex[k] ~= self.m_DyeOriIndex[k] then
        maxCount = maxCount + v[("count%d"):format(i)]
      end
      id = v[("id%d"):format(i)]
    end
    local dyeData = DyeingMgr.GetCurClothData()
    local fashionData = FashionData.Instance()
    GUIUtils.SetActive(itemGO, flag and id ~= 0 and (self.m_DyeIndex[1] ~= self.m_DyeOriIndex[1] or self.m_DyeIndex[2] ~= self.m_DyeOriIndex[2]))
    if id ~= 0 then
      local itemBase = ItemUtils.GetItemBase(id)
      local curNum = ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, id)
      GUIUtils.SetTexture(iconGO, itemBase.icon)
      GUIUtils.SetText(nameGO, itemBase.name)
      if not (maxCount > curNum) or not Color.red then
      end
      GUIUtils.SetTextAndColor(numGO, ("%d/%d"):format(curNum, maxCount), (Color.Color(0.25098039215686274, 0.5411764705882353, 0.3254901960784314)))
    end
    itemGO:SetActive(not bOwnCurrentDye)
  end
  self.m_UIGO.BtnSettle:SetActive(not bOwnCurrentDye)
  self.m_UIGO.BtnMakeUseYB:SetActive(not bOwnCurrentDye)
  local bUseYBOpen = DyeingMgr.IsUseYBFeatureOpen()
  self.m_UIGO.BtnUseYB:SetActive(not bOwnCurrentDye and bUseYBOpen)
  self.m_UIGO.lblOwnTips:SetActive(bOwnCurrentDye)
  GUIUtils.SetText(self.m_UIGO.lblOwnTips, textRes.Dyeing[33])
  if not bOwnCurrentDye then
    self.m_UIGO.BtnMakeUseYB:SetActive(bUseYB)
    self.m_UIGO.LblSettle:SetActive(not bUseYB)
    if bUseYB then
      local lblYBNum = self.m_UIGO.BtnMakeUseYB:FindDirect("Label_MoneyMake")
      local _, totalNeedYB = self:GetPartNeedYB()
      GUIUtils.SetText(lblYBNum, totalNeedYB)
      self.m_UIGO.totalNeedYB = totalNeedYB
      if totalNeedYB < 1 then
        self.m_UIGO.BtnMakeUseYB:SetActive(false)
        self.m_UIGO.LblSettle:SetActive(true)
        self.m_UIGO.BtnUseYB:GetComponent("UIToggle").value = false
      end
    end
  end
end
def.method("=>", "table", "number").GetPartNeedYB = function(self)
  local retData = {}
  if not DyeingMgr.IsUseYBFeatureOpen() then
    return retData, 0
  end
  local iTotalYB = 0
  local hairItemData = self.m_ItemData[DyeingMgr.PARTINDEX.HAIR]
  local item1Id = hairItemData.id1
  local item2Id = hairItemData.id2
  local item1Price = self.mapItemPrice[item1Id]
  if not item1Price or not item1Price then
    item1Price = 0
  end
  local item2Price = self.mapItemPrice[item2Id]
  if not item2Price or not item2Price then
    item2Price = 0
  end
  local item1Num = ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, item1Id)
  local item2Num = ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, item2Id)
  local ConsumeOrder = DyeingMgr.ConsumeOrder
  for i = 1, #ConsumeOrder do
    local part = ConsumeOrder[i]
    if self.m_DyeIndex[part] ~= self.m_DyeOriIndex[part] then
      retData[part] = {}
      local itemData = self.m_ItemData[part]
      local pItem1Num = itemData.count1
      local pItem2Num = itemData.count2
      local diffItem = pItem1Num - item1Num
      if diffItem > 0 then
        retData[part][item1Id] = diffItem * item1Price
        iTotalYB = iTotalYB + retData[part][item1Id]
        item1Num = 0
      else
        item1Num = item1Num - pItem1Num
      end
      diffItem = pItem2Num - item2Num
      if diffItem > 0 then
        retData[part][item2Id] = diffItem * item2Price
        iTotalYB = iTotalYB + retData[part][item2Id]
        item2Num = 0
      else
        item2Num = item2Num - pItem2Num
      end
    end
  end
  return retData, iTotalYB
end
def.method("=>", "boolean").IsNeedItemsEnough = function(self)
  local hairItemData = self.m_ItemData[DyeingMgr.PARTINDEX.HAIR]
  local item1Id = hairItemData.id1
  local item2Id = hairItemData.id2
  local item1Price = self.mapItemPrice[item1Id]
  if not item1Price or not item1Price then
    item1Price = 0
  end
  local item2Price = self.mapItemPrice[item2Id]
  if not item2Price or not item2Price then
    item2Price = 0
  end
  local item1Num = ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, item1Id)
  local item2Num = ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, item2Id)
  local ConsumeOrder = DyeingMgr.ConsumeOrder
  for i = 1, #ConsumeOrder do
    local part = ConsumeOrder[i]
    if self.m_DyeIndex[part] ~= self.m_DyeOriIndex[part] then
      local itemData = self.m_ItemData[part]
      local pItem1Num = itemData.count1
      local pItem2Num = itemData.count2
      item1Num = item1Num - pItem1Num
      item2Num = item2Num - pItem2Num
      if item1Num < 0 or item2Num < 0 then
        return false
      end
    end
  end
  return true
end
def.method("=>", "boolean").IsOwnCurrentDyeing = function(self)
  local bList = {}
  local ownDyeList = DyeingMgr.GetClothListData()
  local part = DyeingMgr.PARTINDEX.HAIR
  local index = self.m_DyeIndex[part]
  local hairid = self.m_ListData[part][index] and self.m_ListData[part][index].id or 0
  part = DyeingMgr.PARTINDEX.CLOTH
  index = self.m_DyeIndex[part]
  local clothid = self.m_ListData[part][index] and self.m_ListData[part][index].id or 0
  return DyeingMgr.IsDyeingExist(hairid, clothid)
end
def.method().UpdateBtnView = function(self)
  local label = self.m_UIGO.BtnLabel
  GUIUtils.SetText(label, self.m_ShowWing and textRes.Dyeing[26] or textRes.Dyeing[27])
end
def.method().Update = function(self)
  self:UpdateUIModel()
  self:UpdateRightTopView()
  self:UpdateRightBottomView(true)
  self:UpdateBtnView()
end
return DyeingPanel.Commit()
