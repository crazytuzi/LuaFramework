local Lplus = require("Lplus")
local GUIUtils = require("GUI.GUIUtils")
local EquipModule = Lplus.ForwardDeclare("EquipModule")
local PetData = Lplus.ForwardDeclare("PetData")
local PetSoulPos = require("consts.mzm.gsp.petsoul.confbean.PetSoulPos")
local PetAptConsts = require("netio.protocol.mzm.gsp.pet.PetAptConsts")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local PetSoulData = require("Main.Pet.soul.data.PetSoulData")
local PetSoulUtils = Lplus.Class("PetSoulUtils")
local def = PetSoulUtils.define
def.static("number", "=>", "number").GetPropAptType = function(propType)
  local result = -1
  if propType == PropertyType.MAX_HP then
    result = PetAptConsts.HP_APT
  elseif propType == PropertyType.PHYATK then
    result = PetAptConsts.PHYATK_APT
  elseif propType == PropertyType.PHYDEF then
    result = PetAptConsts.PHYDEF_APT
  elseif propType == PropertyType.MAGATK then
    result = PetAptConsts.MAGATK_APT
  elseif propType == PropertyType.MAGDEF then
    result = PetAptConsts.MAGDEF_APT
  elseif propType == PropertyType.SPEED then
    result = PetAptConsts.SPEED_APT
  end
  return result
end
def.static("number", "=>", "string").GetPropName = function(propType)
  local attrName = textRes.Pet.Soul.PropertyName[propType]
  if nil == attrName then
    attrName = EquipModule.GetAttriName(propType)
  end
  return attrName
end
def.static(PetData, "table", "=>", "string").GetActualAttrString = function(pet, prop)
  local result = ""
  if prop then
    local propValue = 0
    if prop.propValue then
      local PetUtility = require("Main.Pet.PetUtility")
      local RATIO_BISIC_PROP = PetUtility.Instance():GetPetConstants("RATIO_BISIC_PROP")
      RATIO_BISIC_PROP = RATIO_BISIC_PROP and RATIO_BISIC_PROP / 10000 or 0
      local CONST_APT = PetUtility.Instance():GetPetConstants("CONST_APT")
      CONST_APT = CONST_APT and CONST_APT / 10000 or 0
      local RATIO_APT = PetUtility.Instance():GetPetConstants("RATIO_APT")
      RATIO_APT = RATIO_APT and RATIO_APT / 10000 or 0
      local CONST_GROW = PetUtility.Instance():GetPetConstants("CONST_GROW")
      CONST_GROW = CONST_GROW and CONST_GROW / 10000 or 0
      local RATIO_GROW = PetUtility.Instance():GetPetConstants("RATIO_GROW")
      RATIO_GROW = RATIO_GROW and RATIO_GROW / 10000 or 0
      local growData = PetUtility.GetPetGrowValueViewData(pet)
      local curGrowApt = growData and growData.value or 0
      local petAptType = PetSoulUtils.GetPropAptType(prop.propType)
      local curPropApt = pet.petQuality:GetQuality(petAptType) or 0
      propValue = math.floor(prop.propValue * RATIO_BISIC_PROP + prop.propValue * math.max(curPropApt / 1000 - CONST_APT, 0) * RATIO_APT + prop.propValue * math.max(curGrowApt - CONST_GROW, 0) * RATIO_GROW)
    end
    result = PetSoulUtils._GetAttrString(prop.propType, propValue)
  end
  return result
end
def.static("table", "=>", "string").GetAttrString = function(prop)
  local result = ""
  if prop then
    result = PetSoulUtils._GetAttrString(prop.propType, prop.propValue or 0)
  end
  return result
end
def.static("number", "number", "=>", "string")._GetAttrString = function(propType, propValue)
  local result = "+"
  local attrName = PetSoulUtils.GetPropName(propType)
  if attrName then
    result = attrName .. result
  end
  if propType == PropertyType.PHY_CRT_VALUE or propType == PropertyType.MAG_CRT_VALUE then
    result = result .. string.format("%.1f%%", propValue / 100)
  else
    result = result .. propValue
  end
  return result
end
def.static(PetData, "userdata", "boolean").ShowPetSoul = function(pet, group, bActual)
  if nil == group then
    warn("[ERROR][PetSoulUtils:ShowPetSoul] group nil!")
    return
  end
  local soulPos2BtnMap = {}
  soulPos2BtnMap[PetSoulPos.POS_JING] = group:FindDirect("Btn_Sprites/Img_Icon01")
  soulPos2BtnMap[PetSoulPos.POS_QI] = group:FindDirect("Btn_Sprites/Img_Icon02")
  soulPos2BtnMap[PetSoulPos.POS_SHEN] = group:FindDirect("Btn_Sprites/Img_Icon03")
  local List_Attrs = group:FindDirect("List_Buff")
  local uiListAttrs = List_Attrs:GetComponent("UIList")
  local LabelNoProp = group:FindDirect("Label_Tips")
  local Title_List = group:FindDirect("Title_List")
  local Img_Bg_Buff = group:FindDirect("Img_Bg_Buff")
  if pet then
    local soulProp = pet and pet.soulProp
    PetSoulUtils.ShowSouls(soulProp, soulPos2BtnMap)
    local props = soulProp and soulProp:GetAllSoulProp()
    local propCount = props and #props or 0
    uiListAttrs.itemCount = propCount
    uiListAttrs:Resize()
    uiListAttrs:Reposition()
    if propCount > 0 then
      GUIUtils.SetActive(LabelNoProp, false)
      GUIUtils.SetActive(Title_List, true)
      GUIUtils.SetActive(Img_Bg_Buff, true)
      for i = 1, propCount do
        local listItem = uiListAttrs.children[i]
        local prop = props[i]
        local posLabel = listItem:FindDirect("Label_SpriteProperty")
        local posStr = string.format(textRes.Pet.Soul.SOUL_POS_ATTR_PREFIX, PetSoulUtils.GetPosName(prop.pos))
        GUIUtils.SetText(posLabel, posStr)
        local attrStr = ""
        if bActual then
          attrStr = PetSoulUtils.GetActualAttrString(pet, prop)
        else
          attrStr = PetSoulUtils.GetAttrString(prop)
        end
        local attrLabel = listItem:FindDirect("Label")
        GUIUtils.SetText(attrLabel, attrStr)
      end
    else
      GUIUtils.SetActive(LabelNoProp, true)
      GUIUtils.SetActive(Title_List, false)
      GUIUtils.SetActive(Img_Bg_Buff, false)
    end
  else
    PetSoulUtils.ShowSouls(nil, soulPos2BtnMap)
    uiListAttrs.itemCount = 0
    uiListAttrs:Resize()
    uiListAttrs:Reposition()
    GUIUtils.SetActive(LabelNoProp, false)
    GUIUtils.SetActive(Title_List, false)
    GUIUtils.SetActive(Img_Bg_Buff, false)
  end
end
def.static("number", "=>", "string").GetPosName = function(pos)
  local result = ""
  local posCfg = PetSoulData.Instance():GetPosCfg(pos)
  if posCfg then
    result = posCfg.name
  end
  return result
end
def.static("table", "table").ShowSouls = function(soulProp, soulPos2BtnMap)
  if nil == soulPos2BtnMap then
    warn("[ERROR][PetSoulUtils:ShowSouls] soulPos2BtnMap nil!")
    return
  end
  for pos, btn in pairs(soulPos2BtnMap) do
    local posCfg = PetSoulData.Instance():GetPosCfg(pos)
    GUIUtils.SetTexture(btn, posCfg and posCfg.img or 0)
    local soulInfo = soulProp and soulProp:GetSoulInfoByPos(pos)
    local labelLevel = btn:FindDirect("Label_Buff")
    local soulLevel = soulInfo and soulInfo.level or 0
    GUIUtils.SetText(labelLevel, "+" .. soulLevel)
  end
end
PetSoulUtils.Commit()
return PetSoulUtils
