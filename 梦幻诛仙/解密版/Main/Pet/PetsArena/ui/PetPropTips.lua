local FILE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetsPropTips = Lplus.Extend(ECPanelBase, FILE_NAME)
local Cls = PetsPropTips
local def = Cls.define
local instance
local Vector = require("Types.Vector")
local MathHelper = require("Common.MathHelper")
local GUIUtils = require("GUI.GUIUtils")
def.field("table")._position = nil
def.field("userdata")._petId = nil
def.field("table")._petInfo = nil
def.field("table")._uiGOs = nil
def.field("table")._extraInfo = nil
def.static("=>", Cls).Instance = function()
  if instance == nil then
    instance = Cls()
  end
  return instance
end
def.method().initUI = function(self)
  local PetTeamData = require("Main.PetTeam.data.PetTeamData")
  local PetUtility = require("Main.Pet.PetUtility")
  local PetMgr = require("Main.Pet.mgr.PetMgr")
  if self._petId == nil then
    self:DestroyPanel()
    return
  end
  local extraInfo = self._extraInfo or {}
  local txt = textRes.Pet.PetsArena[22]
  self._uiGOs.lblPingUnknown:SetActive(false)
  if extraInfo.rank and extraInfo.rank <= constant.CPetArenaConst.TOP_NUM_HIDE_ALL then
    GUIUtils.SetText(self._uiGOs.lblSkillName, txt)
    GUIUtils.SetText(self._uiGOs.lblRating, false)
    self._uiGOs.lblPingUnknown:SetActive(true)
    GUIUtils.SetText(self._uiGOs.lblPingUnknown, txt)
    GUIUtils.SetText(self._uiGOs.lblLv, txt)
    GUIUtils.SetText(self._uiGOs.lblScore, txt)
    return
  end
  local petSkillId = 0
  local petInfo
  if extraInfo.bIsRobotPet then
    petSkillId = 0
    petInfo = self._extraInfo.robotPetData
  else
    petSkillId = PetTeamData.Instance():GetPetSkill(self._petId)
    if extraInfo.petInfo then
      petInfo = extraInfo.petInfo
    else
      petInfo = PetMgr.Instance():GetPet(self._petId)
    end
  end
  local skillCfg = PetUtility.Instance():GetPetSkillCfg(petSkillId) or {}
  if skillCfg.name ~= nil and skillCfg.name ~= "" then
    GUIUtils.SetText(self._uiGOs.lblSkillName, skillCfg.name)
  else
    GUIUtils.SetText(self._uiGOs.lblSkillName, textRes.Pet.PetsArena[27])
  end
  if extraInfo.rank and extraInfo.rank <= constant.CPetArenaConst.TOP_NUM_HIDE_PART then
    self._uiGOs.lblRating:SetActive(false)
    self._uiGOs.lblPingUnknown:SetActive(true)
    GUIUtils.SetText(self._uiGOs.lblPingUnknown, txt)
    GUIUtils.SetText(self._uiGOs.lblLv, txt)
    GUIUtils.SetText(self._uiGOs.lblScore, txt)
    return
  end
  self._uiGOs.lblLv:SetActive(petInfo ~= nil)
  self._uiGOs.lblRating:SetActive(petInfo ~= nil)
  self._uiGOs.lblScore:SetActive(petInfo ~= nil)
  if petInfo == nil then
    warn("[ERROR:] Don't own the pet, pet id =", self._petId:tostring())
    return
  else
    local yaolicfg = petInfo:GetPetYaoLiCfg()
    local encodeChar = yaolicfg.encodeChar
    GUIUtils.SetText(self._uiGOs.lblRating, encodeChar)
    GUIUtils.SetText(self._uiGOs.lblLv, petInfo.level)
    GUIUtils.SetText(self._uiGOs.lblScore, petInfo:GetYaoLi())
  end
end
def.override().OnCreate = function(self)
  self._uiGOs = {}
  local uiGOs = self._uiGOs
  uiGOs.lblLv = self.m_panel:FindDirect("Img_Bg/Group_Info/Label_LevelNum")
  uiGOs.lblRating = self.m_panel:FindDirect("Img_Bg/Group_Info/Label_PingNum")
  uiGOs.lblPingUnknown = self.m_panel:FindDirect("Img_Bg/Group_Info/Label_PingUnknown")
  uiGOs.lblScore = self.m_panel:FindDirect("Img_Bg/Group_Info/Label_FightNum")
  uiGOs.lblSkillName = self.m_panel:FindDirect("Img_Bg/Group_Info/Label_SkillNum")
  uiGOs.lblSkill = self.m_panel:FindDirect("Img_Bg/Group_Info/Label_SkillName")
  uiGOs.lblSkill:SetActive(false)
  uiGOs.lblSkillName:SetActive(false)
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if self.m_panel == nil then
      return
    end
    local tipsFrame = self.m_panel:FindDirect("Img_Bg")
    if tipsFrame == nil then
      return
    end
    if self._position.auto then
      local bg = tipsFrame:GetComponent("UISprite")
      local computeTipsAutoPosition = MathHelper.ComputeTipsAutoPosition
      local x, y = computeTipsAutoPosition(self._position.sourceX, self._position.sourceY, self._position.sourceW, self._position.sourceH, bg:get_width(), bg:get_height(), self._position.prefer)
      tipsFrame:set_localPosition(Vector.Vector3.new(x, y + bg:get_height() / 2, 0))
    end
  end)
end
def.override().OnDestroy = function(self)
  self._position = nil
  self._petId = nil
  self._petInfo = nil
  self._uiGOs = nil
  self._extraInfo = nil
end
def.override("boolean").OnShow = function(self, bShow)
  if bShow then
    self:initUI()
  end
end
def.static("number", "number", "number", "number", "number", "userdata", "table", "=>", PetsPropTips).ShowPetsTipsWithPos = function(src_x, src_y, width, height, prefer, petId, extraInfo)
  local pos = {
    auto = true,
    sourceX = src_x,
    sourceY = src_y,
    sourceW = width,
    sourceH = height,
    prefer = prefer
  }
  local tips = PetsPropTips()
  tips._position = pos
  tips._extraInfo = extraInfo
  tips._petId = petId
  tips:CreatePanel(RESPATH.PREFAB_PROP_TIPS, 2)
  tips:SetOutTouchDisappear()
  return tips
end
def.static("userdata", "number", "userdata", "table", "=>", PetsPropTips).ShowPetsTipsWithGO = function(go, prefer, petId, extraInfo)
  if go == nil then
    return nil
  end
  local position = go.position
  local screenPos = _G.WorldPosToScreen(position.x, position.y)
  local widget = go:GetComponent("UIWidget")
  if not widget then
    warn("[ERROR] There is no UIWidget component in :" .. go.name)
    return nil
  end
  return Cls.ShowPetsTipsWithPos(screenPos.x, screenPos.y, widget.width, widget.height, prefer, petId, extraInfo)
end
def.method("userdata").onClickObj = function(self, clickObj)
end
return Cls.Commit()
