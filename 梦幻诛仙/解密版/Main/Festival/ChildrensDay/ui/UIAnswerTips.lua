local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIAnswerTips = Lplus.Extend(ECPanelBase, "UIAnswerTips")
local instance
local def = UIAnswerTips.define
local GUIUtils = require("GUI.GUIUtils")
def.field("table")._roles = nil
def.field("table")._answer = nil
def.field("userdata")._drawer = nil
def.static("=>", UIAnswerTips).Instance = function()
  if instance == nil then
    instance = UIAnswerTips()
  end
  return instance
end
def.override().OnCreate = function(self)
  self:UpdateContent()
end
def.override().OnDestroy = function(self)
  for i = 1, #self._roles do
    local roleInfo = self._roles[i]
    roleInfo.result = false
  end
  self._roles = nil
  self._answer = nil
  self._drawer = nil
end
def.method("table", "table", "userdata").ShowPanel = function(self, roles, tblAnswer, drawer)
  if self:IsLoaded() then
    return
  end
  self._roles = roles
  self._answer = tblAnswer
  self._drawer = drawer
  self:CreatePanel(RESPATH.PREFAB_ANSWER_TIP, 1)
  self:SetModal(true)
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
end
def.method().UpdateContent = function(self)
  local lblAnswer = self.m_panel:FindDirect("Img_Bg0/Group_Answer/Label_Answer")
  local ctrlUIList = self.m_panel:FindDirect("Img_Bg0/Group_Player/List")
  if self._roles ~= nil then
    local arrAnswerRight = self:CountAnswer()
    local uiList = GUIUtils.InitUIList(ctrlUIList, #arrAnswerRight)
    for i = 1, #arrAnswerRight do
      local ctrlRole = uiList[i]
      local roleInfo = arrAnswerRight[i]
      local lblName = ctrlRole:FindDirect(("Label_Name_%d"):format(i))
      local texHead = ctrlRole:FindDirect(("Img_Icon_%d"):format(i))
      local imgRight = ctrlRole:FindDirect(("Label_State1_%d"):format(i))
      local imgError = ctrlRole:FindDirect(("Label_State2_%d"):format(i))
      GUIUtils.SetText(lblName, roleInfo.roleName)
      if _G.SetAvatarIcon == nil then
        GUIUtils.SetSprite(texHead, GUIUtils.GetHeadSpriteName(roleInfo.occupation, roleInfo.gender))
      else
        _G.SetAvatarIcon(texHead, roleInfo.avatarId)
      end
      local uiSprite = ctrlRole:GetComponent("UISprite")
      local w, h = uiSprite.width, uiSprite.height
      local depth = uiSprite.depth
      GameObject.DestroyImmediate(uiSprite)
      local uiTex = ctrlRole:AddComponent("UITexture")
      uiTex.width, uiTex.height = w + 23, h + 23
      uiTex.depth = depth
      _G.SetAvatarFrameIcon(ctrlRole, roleInfo.avatarFrameId)
      if roleInfo.result ~= nil and roleInfo.result then
        imgRight:SetActive(true)
        imgError:SetActive(false)
      else
        imgRight:SetActive(false)
        imgError:SetActive(true)
      end
    end
  else
    GUIUtils.InitUIList(ctrlUIList, 0)
  end
  if self._answer ~= nil then
    GUIUtils.SetText(lblAnswer, self._answer[1])
  else
    GUIUtils.SetText(lblAnswer, "")
  end
end
def.method("=>", "table").CountAnswer = function(self)
  local ret = {}
  for i = 1, #self._roles do
    local roleInfo = self._roles[i]
    if roleInfo ~= nil and roleInfo.roleid ~= self._drawer then
      table.insert(ret, roleInfo)
    end
  end
  return ret
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:HidePanel()
  end
end
return UIAnswerTips.Commit()
