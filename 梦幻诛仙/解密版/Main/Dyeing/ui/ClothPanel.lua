local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local HeroModule = require("Main.Hero.HeroModule")
local ECUIModel = require("Model.ECUIModel")
local DyeingMgr = require("Main.Dyeing.DyeingMgr")
local DyeData = require("Main.Dyeing.data.DyeData")
local ItemModule = require("Main.Item.ItemModule")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local WingInterface = require("Main.Wing.WingInterface")
local FashionUtils = require("Main.Fashion.FashionUtils")
local FashionData = require("Main.Fashion.FashionData")
local FashionDressConst = require("netio.protocol.mzm.gsp.fashiondress.FashionDressConst")
local ClothPanel = Lplus.Extend(ECPanelBase, "ClothPanel")
local def = ClothPanel.define
def.field("boolean").m_ShowWing = false
def.field("number").m_MaxCount = 0
def.field("number").m_CurIndex = 0
def.field("number").m_CurId = 0
def.field("table").m_ListData = nil
def.field("table").m_Model = nil
def.field("table").m_UIGO = nil
local instance
def.static("=>", ClothPanel).Instance = function()
  if not instance then
    instance = ClothPanel()
  end
  return instance
end
def.static("table", "table").OnAddCloth = function(p1, p2)
  if instance and instance.m_panel and not instance.m_panel.isnil then
    instance:UpdateData()
    instance:Update()
  end
end
def.static("table", "table").OnColorDataChanged = function(params, context)
  if instance and instance.m_panel and not instance.m_panel.isnil then
    instance:UpdateData()
    instance:Update()
  end
end
def.method().ShowPanel = function(self)
  local count = DyeingMgr.GetClothCurCount()
  if count == 0 then
    Toast(textRes.Dyeing[21])
    return
  end
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_DYE_CLOSET_PANEL, GUILEVEL.MUTEX)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:InitData()
  self:UpdateData()
  self:Update()
  Event.RegisterEvent(ModuleId.DYEING, gmodule.notifyId.Dyeing.UPDATE_CLOSET, ClothPanel.OnAddCloth)
  Event.RegisterEvent(ModuleId.DYEING, gmodule.notifyId.Dyeing.UPDATE_COLOR_DATA, ClothPanel.OnColorDataChanged)
end
def.override().OnDestroy = function(self)
  if self.m_Model then
    self.m_Model:Destroy()
  end
  self.m_MaxCount = 0
  self.m_CurIndex = 0
  self.m_CurId = 0
  self.m_ListData = nil
  self.m_Model = nil
  self.m_UIGO = nil
  Event.UnregisterEvent(ModuleId.DYEING, gmodule.notifyId.Dyeing.UPDATE_CLOSET, ClothPanel.OnAddCloth)
  Event.UnregisterEvent(ModuleId.DYEING, gmodule.notifyId.Dyeing.UPDATE_COLOR_DATA, ClothPanel.OnColorDataChanged)
end
def.method().Delete = function(self)
  if self.m_CurIndex == 0 or not self.m_ListData[self.m_CurIndex] then
    return
  end
  CommonConfirmDlg.ShowConfirmCoundDown(textRes.Dyeing[14], textRes.Dyeing[11], textRes.Dyeing[12], textRes.Dyeing[13], 0, 0, function(selection, tag)
    if selection == 1 then
      local params = {}
      params.colorid = self.m_ListData[self.m_CurIndex].colorid
      DyeingMgr.Delete(params)
    end
  end, nil)
end
def.method().Replace = function(self)
  if self.m_CurIndex <= 0 or not self.m_ListData[self.m_CurIndex] then
    return
  end
  local params = {}
  params.colorid = self.m_ListData[self.m_CurIndex].colorid
  DyeingMgr.Replace(params)
end
def.method("boolean").ChangeModelScale = function(self, expand)
  DyeingMgr.ChangeModelScale(expand, self.m_Model)
end
def.method().ChangeModelColor = function(self)
  local index = self.m_CurIndex == 0 and self.m_CurId or self.m_CurIndex
  local dyeColor = self.m_ListData[index]
  if not dyeColor then
    warn(index, "ChangeModelColor")
    return
  end
  for _, v in pairs(DyeingMgr.PARTINDEX) do
    local colorId = dyeColor[("color%d"):format(v)]
    local color = DyeingMgr.GetColorFormula(colorId)
    DyeingMgr.ChangeModelColor(v, self.m_Model, color)
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
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Btn_Close" then
    Event.DispatchEvent(ModuleId.DYEING, gmodule.notifyId.Dyeing.CLOSET_PANEL_CLOSE, nil)
    self:DestroyPanel()
  elseif id == "Btn_Minus" then
    self:ChangeModelScale(false)
  elseif id == "Btn_Add" then
    self:ChangeModelScale(true)
  elseif id == "Btn_Delete" then
    self:Delete()
  elseif id == "Btn_Replace" then
    self:Replace()
  elseif id == "Btn_YY" then
    self:ChangeModelWing()
  elseif id:find("Img_BgItem_") == 1 then
    local _, lastIndex = id:find("Img_BgItem_")
    local index = tonumber(id:sub(lastIndex + 1, id:len()))
    self.m_CurIndex = index
    self:ChangeModelColor()
  end
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if id:find("Img_Bg") == 1 then
    self.m_Model:SetDir(self.m_Model.m_ang - dx / 2)
  end
end
def.method().UpdateData = function(self)
  self.m_ListData = {}
  local listData = DyeingMgr.GetClothListData()
  local curId = DyeingMgr.GetClothCurIndex()
  local index = 0
  for k, v in pairs(listData) do
    index = index + 1
    self.m_ListData[index] = {}
    self.m_ListData[index].colorid = v.colorid
    self.m_ListData[index].color1 = v.clothid
    self.m_ListData[index].color2 = v.hairid
    self.m_ListData[index].fashionDressCfgId = v.fashionDressCfgId
  end
  self.m_CurId = curId
  self.m_CurIndex = curId
  self.m_MaxCount = DyeingMgr.GetClothMaxCount()
end
def.method().InitData = function(self)
  local wingId = WingInterface.GetCurWingId()
  self.m_ShowWing = wingId > 0 and true or false
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  self.m_UIGO.ItemList = self.m_panel:FindDirect("Img_Bg/Group_Left/Scroll View/ItemList")
  self.m_UIGO.UIModel = self.m_panel:FindDirect("Img_Bg/Group_Right/Model")
  self.m_UIGO.Label_Num = self.m_panel:FindDirect("Img_Bg/Group_Left/Img_ClothNum/Label_Num")
  self.m_UIGO.BtnLabel = self.m_panel:FindDirect("Img_Bg/Group_Right/Btn_YY/Label")
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
    local m = self.m_Model.m_model
    uiModel.modelGameObject = m
    uiModel.mCanOverflow = true
    FashionUtils.SetFashion(self.m_Model, FashionData.Instance().currentFashionId)
  end
  if not self.m_Model then
    local modelInfo = DyeingMgr.Instance():GetDyeShowModelInfo()
    self.m_Model = ECUIModel.new(modelInfo.modelid)
    self.m_Model.m_bUncache = true
    self.m_Model:AddOnLoadCallback("FashionPanel", AfterModelLoad)
    _G.LoadModel(self.m_Model, modelInfo, 0, 0, 180, false, false)
  else
    AfterModelLoad()
  end
end
def.method().UpdataLeftView = function(self)
  local spriteNames = {
    "Img_DyeNow",
    "Img_DyeDefault"
  }
  local uiListGO = self.m_UIGO.ItemList
  local itemCount = #self.m_ListData
  local listItems = GUIUtils.InitUIList(uiListGO, itemCount)
  self.m_msgHandler:Touch(uiListGO)
  for i = 1, itemCount do
    local itemGO = listItems[i]
    local itemData = self.m_ListData[i]
    local numGO = itemGO:FindDirect(("Label_Num_%d"):format(i))
    local markGO = itemGO:FindDirect(("Img_Mark_%d"):format(i))
    local color1GO = itemGO:FindDirect(("Img_HairColor_%d"):format(i))
    local name1GO = itemGO:FindDirect(("Img_HairColor_%d/Label_%d"):format(i, i))
    local color2GO = itemGO:FindDirect(("Img_CloColor_%d"):format(i))
    local name2GO = itemGO:FindDirect(("Img_CloColor_%d/Label_%d"):format(i, i))
    local groupFashion = itemGO:FindDirect(("Group_Fashion_%d"):format(i))
    local fashionLabelNum = groupFashion:FindDirect(("Label_Num_%d"):format(i))
    local fashionLaelName = groupFashion:FindDirect(("Label_Name_%d"):format(i))
    local imgFashion = itemGO:FindDirect(("Img_Fashion_%d"):format(i))
    local cfg1 = DyeData.GetColorFormula(itemData.color1)
    if cfg1 == nil then
      GUIUtils.SetActive(color1GO, false)
    else
      GUIUtils.SetActive(color1GO, true)
      local alpha = cfg1.a / 255 * 2
      local color1 = Color.Color(cfg1.r / 255 * alpha, cfg1.g / 255 * alpha, cfg1.b / 255 * alpha, 1)
      GUIUtils.SetColor(color1GO, color1, GUIUtils.COTYPE.SPRITE)
    end
    local cfg2 = DyeData.GetColorFormula(itemData.color2)
    if cfg2 == nil then
      GUIUtils.SetActive(color2GO, false)
    else
      GUIUtils.SetActive(color2GO, true)
      local alpha = cfg2.a / 255 * 2
      local color2 = Color.Color(cfg2.r / 255 * alpha, cfg2.g / 255 * alpha, cfg2.b / 255 * alpha, 1)
      GUIUtils.SetColor(color2GO, color2, GUIUtils.COTYPE.SPRITE)
    end
    local spriteIndex = i == 1 and self.m_CurId ~= 1 and 2 or 1
    GUIUtils.Toggle(itemGO, self.m_CurIndex == 0 and i == self.m_CurId or i == self.m_CurIndex)
    GUIUtils.SetActive(markGO, i == 1 or i == self.m_CurId)
    GUIUtils.SetSprite(markGO, spriteNames[spriteIndex])
    GUIUtils.SetActive(name1GO, false)
    GUIUtils.SetActive(name2GO, false)
    if itemData.fashionDressCfgId ~= FashionDressConst.NO_FASHION_DRESS then
      local fashionData = FashionUtils.GetFashionItemDataById(itemData.fashionDressCfgId)
      groupFashion:SetActive(true)
      imgFashion:SetActive(true)
      numGO:SetActive(false)
      GUIUtils.SetText(fashionLabelNum, ("%d%s"):format(i, textRes.Dyeing[10]))
      GUIUtils.SetText(fashionLaelName, fashionData.fashionDressName)
    else
      numGO:SetActive(true)
      groupFashion:SetActive(false)
      imgFashion:SetActive(false)
      GUIUtils.SetText(numGO, ("%d%s"):format(i, textRes.Dyeing[10]))
    end
  end
  GUIUtils.Reposition(uiListGO, GUIUtils.COTYPE.LIST, 0)
  local numGO = self.m_UIGO.Label_Num
  GUIUtils.SetText(numGO, ("%d/%d"):format(itemCount, self.m_MaxCount))
end
def.method().UpdateBtnView = function(self)
  local label = self.m_UIGO.BtnLabel
  GUIUtils.SetText(label, self.m_ShowWing and textRes.Dyeing[26] or textRes.Dyeing[27])
end
def.method().Update = function(self)
  self:UpdateUIModel()
  self:UpdataLeftView()
  self:UpdateBtnView()
end
return ClothPanel.Commit()
