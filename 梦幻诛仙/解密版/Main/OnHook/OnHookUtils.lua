local Lplus = require("Lplus")
local OnHookUtils = Lplus.Class("OnHookUtils")
local def = OnHookUtils.define
def.static("string", "userdata").FillIcon = function(iconId, uiSprite)
  local atlas = OnHookUtils.GetAtlasName()
  GameUtil.AsyncLoad(atlas, function(obj)
    local atlas = obj:GetComponent("UIAtlas")
    uiSprite:set_atlas(atlas)
    uiSprite:set_spriteName(iconId)
  end)
end
def.static("=>", "string").GetAtlasName = function()
  return RESPATH.COMMONATLAS
end
def.static("=>", "number").GetReceivePoolMaxNum = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DOUBLE_POINT_CONST_CFG, "REST_POINT_MAX_NUM")
  local receivePoolMaxNum = DynamicRecord.GetIntValue(record, "value")
  return receivePoolMaxNum
end
def.static("=>", "number").GetReceiveOnceMaxNum = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DOUBLE_POINT_CONST_CFG, "ONCE_GET_MAX_NUM")
  local receiveOnceMaxNum = DynamicRecord.GetIntValue(record, "value")
  return receiveOnceMaxNum
end
def.static("=>", "number").GetFrozenOnceCostNum = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DOUBLE_POINT_CONST_CFG, "FROZEN_DEC_NUM")
  local frozenOnceCostNum = DynamicRecord.GetIntValue(record, "value")
  return frozenOnceCostNum
end
def.static("=>", "number").GetFrozenMinNumForTip = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DOUBLE_POINT_CONST_CFG, "MIN_NUM_FOR_BOUND_TIP")
  local frozenMinNumForTip = DynamicRecord.GetIntValue(record, "value")
  return frozenMinNumForTip
end
def.static("=>", "number").GetDoublePointTipsId = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DOUBLE_POINT_CONST_CFG, "TIPS")
  local val = DynamicRecord.GetIntValue(record, "value")
  return val
end
def.static("=>", "number").GetCarryMaxNum = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DOUBLE_POINT_CONST_CFG, "ROLE_CARRY_MAX_NUM")
  local val = DynamicRecord.GetIntValue(record, "value")
  return val
end
def.static("=>", "number").GetDoublePointItemId = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DOUBLE_POINT_CONST_CFG, "doublePointItem")
  local val = DynamicRecord.GetIntValue(record, "value")
  return val
end
def.static("userdata", "table", "=>", "table").FillUIFromPrefab = function(panel, uiTbl)
  local Img_Bg0 = panel:FindDirect("Img_Bg0")
  local Group_List = Img_Bg0:FindDirect("Group_List")
  local Group_Point = Img_Bg0:FindDirect("Group_Point")
  local Scroll_View = Group_List:FindDirect("Scroll_View")
  local Grid_List = Scroll_View:FindDirect("Grid_List")
  local Img_BgMap01 = Grid_List:FindDirect("Img_BgMap01")
  local Group_Frezze = Group_Point:FindDirect("Group_Frezze")
  local Label_FreezeNum = Group_Frezze:FindDirect("Img_BgFreezeNum/Label_FreezeNum")
  local Group_Double = Group_Point:FindDirect("Group_Double")
  local Label_DoubleNum = Group_Double:FindDirect("Img_BgDoubleNum/Label_DoubleNum")
  uiTbl.Scroll_View = Scroll_View
  uiTbl.Grid_List = Grid_List
  uiTbl.Img_BgMap01 = Img_BgMap01
  uiTbl.Group_Frezze = Group_Frezze
  uiTbl.Label_FreezeNum = Label_FreezeNum
  uiTbl.Label_DoubleNum = Label_DoubleNum
  local Img_BgSence = panel:FindDirect("Img_BgSence")
  local Texture_Map = Img_BgSence:FindDirect("Texture_Map")
  local Label_MapTitle = Texture_Map:FindDirect("Label_MapTitle")
  local Grid_Monster = Texture_Map:FindDirect("Grid_Monster")
  uiTbl.Texture_Map = Texture_Map
  uiTbl.Label_MapTitle = Label_MapTitle
  uiTbl.Grid_Monster = Grid_Monster
  local Img_BgSkill = panel:FindDirect("Img_BgSkill")
  local Label_Get = Img_BgSkill:FindDirect("Label_Get")
  local Btn_Switch = Label_Get:FindDirect("Btn_Switch")
  local Img_BgSkillHero = Img_BgSkill:FindDirect("Img_BgSkillHero")
  local Icon_SkillHero = Img_BgSkillHero:FindDirect("Icon_SkillHero")
  local Img_BgSkillPet = Img_BgSkill:FindDirect("Img_BgSkillPet")
  local Icon_SkillPet = Img_BgSkillPet:FindDirect("Icon_SkillPet")
  uiTbl.Btn_Switch = Btn_Switch
  uiTbl.Img_BgSkillHero = Img_BgSkillHero
  uiTbl.Img_BgSkillPet = Img_BgSkillPet
  uiTbl.Icon_SkillHero = Icon_SkillHero
  uiTbl.Icon_SkillPet = Icon_SkillPet
  local Group_Btns = panel:FindDirect("Group_Btns")
  local Btn_Onhook = Group_Btns:FindDirect("Btn_Onhook")
  local Label_Onhook = Btn_Onhook:FindDirect("Label_Onhook")
  local Btn_Off = Group_Btns:FindDirect("Btn_Off")
  uiTbl.Label_Onhook = Label_Onhook
  uiTbl.Btn_Off = Btn_Off
  return uiTbl
end
def.static("number", "string", "=>", "number").GetAniTimeByModId = function(modId, aniName)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MOD_ATTACK_MAGIC_TIME, modId)
  if record == nil then
    return 0
  else
    return record:GetFloatValue(aniName)
  end
end
def.static("number", "=>", "number").GetDoublePoint = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DOUBLE_POINT_CFG, itemId)
  if record == nil then
    return 0
  else
    return record:GetIntValue("addPointNum")
  end
end
OnHookUtils.Commit()
return OnHookUtils
