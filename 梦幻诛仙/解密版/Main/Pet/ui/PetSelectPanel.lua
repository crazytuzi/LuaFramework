local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetSelectPanel = Lplus.Extend(ECPanelBase, "PetSelectPanel")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local PetInterface = require("Main.Pet.Interface")
local PetUtility = require("Main.Pet.PetUtility")
local def = PetSelectPanel.define
def.field("table").petList = nil
def.field("string").title = ""
def.field("function").callback = nil
def.field("table").userParams = nil
def.field("number").selectedIndex = 0
def.field("table").uiObjs = nil
local instance
def.static("=>", PetSelectPanel).Instance = function()
  if instance == nil then
    instance = PetSelectPanel()
  end
  return instance
end
def.method("table", "string", "function", "table").ShowPanel = function(self, petList, title, callback, userParams)
  self.petList = petList
  self.title = title
  self.callback = callback
  self.userParams = userParams
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_GIVE_PET, 0)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.petList = nil
  self.title = ""
  self.callback = nil
  self.userParams = nil
  self.uiObjs = nil
  self.selectedIndex = 0
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.uiObjs.GridObj = self.uiObjs.Img_Bg:FindDirect("Img_Background/Scroll View/Grid")
  local template = self.uiObjs.GridObj:FindDirect("Img_Bg01")
  template.name = "Img_Bg_0"
  local Img_BgIcon = template:FindDirect("Img_BgIcon")
  local boxCollider = Img_BgIcon:GetComponent("BoxCollider")
  if boxCollider == nil then
    Img_BgIcon:AddComponent("BoxCollider")
  end
  Img_BgIcon:GetComponent("UIWidget"):set_autoResizeBoxCollider(true)
  Img_BgIcon:GetComponent("UIWidget"):ResizeCollider()
  template:SetActive(false)
  self.uiObjs.GridItemTemplate = template
  self.uiObjs.Label_Tips = self.uiObjs.Img_Bg:FindDirect("Label_Tips"):GetComponent("UILabel")
  self.uiObjs.Label_Tips.text = ""
  local Label_Title = self.uiObjs.Img_Bg:FindDirect("Img_BgTitle/Label_Title")
  local titleText = textRes.Pet[96]
  if self.title ~= "" then
    titleText = self.title
  end
  Label_Title:GetComponent("UILabel"):set_text(titleText)
end
def.method().UpdateUI = function(self)
  self:SetPetList(self.petList)
end
def.method("table").SetPetList = function(self, petList)
  local petCount = #petList
  self:ResizePetListGrid(petCount)
  local uiGrid = self.uiObjs.GridObj:FindDirect("UIGrid")
  for i, pet in ipairs(petList) do
    self:SetPetListItem(i, pet)
  end
end
def.method("number", "table").SetPetListItem = function(self, index, pet)
  local gridItem = self.uiObjs.GridObj:FindDirect("Img_Bg_" .. index)
  gridItem:FindDirect("Label_Name"):GetComponent("UILabel").text = pet.name
  local levelText = string.format(textRes.Common[3], pet.level)
  gridItem:FindDirect("Label_Lv"):GetComponent("UILabel").text = levelText
  local iconId = pet:GetHeadIconId()
  local Img_BgIcon = gridItem:FindDirect("Img_BgIcon")
  local Img_Icon = Img_BgIcon:FindDirect("Img_Icon")
  GUIUtils.SetTexture(Img_Icon, iconId)
  local spriteName = pet:GetHeadIconBGSpriteName()
  GUIUtils.SetSprite(Img_BgIcon, spriteName)
  local Label_PowerLv = gridItem:FindDirect("Label_PowerLv")
  local yaolicfg = pet:GetPetYaoLiCfg()
  GUIUtils.SetActive(Label_PowerLv, true)
  GUIUtils.SetText(Label_PowerLv, yaolicfg.encodeChar)
  local cfgData = pet:GetPetCfgData()
  gridItem:FindDirect("Labe_PetType"):GetComponent("UILabel").text = textRes.Pet.Type[cfgData.type]
  local Label_SkillNumber = gridItem:FindDirect("Label_SkillNumber")
  GUIUtils.SetActive(Label_SkillNumber, true)
  local skills = pet:GetSkillIdList()
  local skillCount = skills ~= nil and #skills or 0
  GUIUtils.SetText(Label_SkillNumber, string.format(textRes.Pet[185], skillCount))
end
def.method("number").ResizePetListGrid = function(self, count)
  local uiGrid = self.uiObjs.GridObj:GetComponent("UIGrid")
  local gridItemCount = uiGrid:GetChildListCount()
  if count > gridItemCount then
    for i = gridItemCount + 1, count do
      local gridItem = GameObject.Instantiate(self.uiObjs.GridItemTemplate)
      gridItem.name = "Img_Bg_" .. i
      gridItem.transform.parent = self.uiObjs.GridObj.transform
      gridItem.transform.localScale = Vector.Vector3.one
      gridItem:SetActive(true)
    end
  elseif count < gridItemCount then
    for i = gridItemCount, count + 1, -1 do
      local gridItem = self.uiObjs.GridObj:FindDirect("Img_Bg_" .. i)
      gridItem.transform.parent = nil
      GameObject.Destroy(gridItem)
    end
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
  uiGrid:Reposition()
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Img_BgIcon" then
    self:OnPetIconObjClicked(obj)
  else
    self:onClick(id)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif string.sub(id, 1, #"Img_Bg_") == "Img_Bg_" then
    local index = tonumber(string.sub(id, #"Img_Bg_" + 1, -1))
    self:OnPetListItemClicked(index)
  elseif id == "Btn_Confirm" then
    self:OnConfirmButtonClicked()
  end
end
def.method("number").OnPetListItemClicked = function(self, index)
  self.selectedIndex = index
  local pet = self.petList[index]
  local petCfg = pet:GetPetCfgData()
  local color = PetUtility.GetPetTypeColor(petCfg.type)
  local coloredPetName = string.format("[%s]%s[-]", color, pet.name)
  self.uiObjs.Label_Tips.text = string.format(textRes.SystemHandIn[2], coloredPetName)
end
def.method("userdata").OnPetIconObjClicked = function(self, obj)
  local parentObj = obj.transform.parent.gameObject
  local index = tonumber(string.sub(parentObj.name, #"Img_Bg_" + 1, -1))
  local pet = self.petList[index]
  require("Main.Pet.ui.PetInfoPanel").Instance():ShowPanel(pet)
end
def.method().OnConfirmButtonClicked = function(self)
  if #self.petList == 0 then
    Toast(textRes.Pet[98])
    return
  end
  if self.selectedIndex == 0 then
    Toast(textRes.Pet[97])
    return
  end
  if self.callback then
    local pet = self.petList[self.selectedIndex]
    self.callback(self.selectedIndex, pet, self.userParams)
  end
  self:DestroyPanel()
end
PetSelectPanel.Commit()
return PetSelectPanel
