local FILE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetsFomationTips = Lplus.Extend(ECPanelBase, FILE_NAME)
local Cls = PetsFomationTips
local def = Cls.define
local instance
local PetsArenaUtils = require("Main.Pet.PetsArena.PetsArenaUtils")
local Vector = require("Types.Vector")
local MathHelper = require("Common.MathHelper")
local GUIUtils = require("GUI.GUIUtils")
def.field("table")._position = nil
def.field("table")._fomationInfo = nil
def.field("table")._uiGOs = nil
def.field("table")._petTeamInfo = nil
def.field("table")._extraInfo = nil
def.method().initUI = function(self)
  PetsArenaUtils.ShowFormationAtts(self._petTeamInfo, self._uiGOs.groupAttrs, self._uiGOs.lblFormationName, self._extraInfo)
end
def.override().OnCreate = function(self)
  self._uiGOs = {}
  local uiGOs = self._uiGOs
  uiGOs.lblFormationName = self.m_panel:FindDirect("Img_Bg/Group_Name/Label_Name")
  uiGOs.groupAttrs = {}
  for i = 1, constant.CPetFightConsts.MAX_POSITION_NUMBER do
    table.insert(uiGOs.groupAttrs, self.m_panel:FindDirect("Img_Bg/Grid_Att/Group_Att0" .. i))
  end
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
      tipsFrame:set_localPosition(Vector.Vector3.new(x, y, 0))
    end
  end)
end
def.override().OnDestroy = function(self)
  self._fomationInfo = nil
  self._position = nil
  self._uiGOs = nil
  self._petTeamInfo = nil
  self._extraInfo = nil
end
def.override("boolean").OnShow = function(self, bShow)
  if bShow then
    self:initUI()
  end
end
def.static("number", "number", "number", "number", "number", "table", "table", "=>", PetsFomationTips).ShowPetsFormationTipsWithPos = function(src_x, src_y, width, height, prefer, petTeamInfo, extraInfo)
  local pos = {
    auto = true,
    sourceX = src_x,
    sourceY = src_y,
    sourceW = width,
    sourceH = height,
    prefer = prefer
  }
  local tips = PetsFomationTips()
  tips._position = pos
  tips._petTeamInfo = petTeamInfo
  tips._extraInfo = extraInfo
  tips:CreatePanel(RESPATH.PREFAB_FOMATION_TIPS, 2)
  tips:SetOutTouchDisappear()
  return tips
end
def.static("userdata", "number", "table", "table", "=>", PetsFomationTips).ShowPetsTipsWithGO = function(go, prefer, petTeamInfo, extraInfo)
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
  return Cls.ShowPetsFormationTipsWithPos(screenPos.x, screenPos.y, widget.width, widget.height, prefer, petTeamInfo, extraInfo)
end
def.method("userdata").onClickObj = function(self, clickObj)
end
return Cls.Commit()
