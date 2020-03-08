local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MarrySkill = Lplus.Extend(ECPanelBase, "MarrySkill")
local GUIUtils = require("GUI.GUIUtils")
local def = MarrySkill.define
def.field("table").data = nil
def.field("number").select = 1
def.static("table").ShowMarrySkills = function(info)
  if info == nil then
    return
  end
  local dlg = MarrySkill()
  dlg.data = info
  dlg.select = 1
  dlg:CreatePanel(RESPATH.PREFAB_MARRY_SKILLS, 1)
  dlg:SetModal(true)
end
def.override().OnCreate = function(self)
  self:UpdateList()
  self:UpdateContent()
  self:UpdateBtn()
end
def.override().OnDestroy = function(self)
end
def.method().UpdateList = function(self)
  local list = self.m_panel:FindDirect("Img_Bg0/Group_Skill/Img_BgList/Scroll View_List/List_Skill")
  local uiList = list:GetComponent("UIList")
  uiList:set_itemCount(#self.data)
  uiList:Resize()
  for i = 1, #self.data do
    local skillItem = list:FindDirect(string.format("Img_BgSkillGroup_%d", i))
    local uiTex = skillItem:FindDirect(string.format("Img_BgIconGroup_%d/Texture_IconGroup_%d", i, i)):GetComponent("UITexture")
    GUIUtils.FillIcon(uiTex, self.data[i].icon)
    local skillLabel = skillItem:FindDirect(string.format("Label_Skill_%d", i)):GetComponent("UILabel")
    skillLabel:set_text(self.data[i].name)
    if i == self.select then
      local toggle = skillItem:GetComponent("UIToggle")
      toggle:set_value(true)
    end
  end
  self.m_msgHandler:Touch(list)
end
def.method().UpdateContent = function(self)
  local info = self.data[self.select]
  if info then
    local detail = self.m_panel:FindDirect("Img_Bg0/Group_Skill/Group_SkillName")
    local detailName = detail:FindDirect("Label_Name")
    local detailDesc = detail:FindDirect("Label_Describe")
    detailName:GetComponent("UILabel"):set_text(info.name)
    detailDesc:GetComponent("UILabel"):set_text(info.desc)
  end
end
def.method().UpdateBtn = function(self)
  local isMarried = require("Main.Marriage.MarriageInterface").IsMarried()
  local btn = self.m_panel:FindDirect("Img_Bg0/Group_Skill/Btn_GoTo")
  btn:SetActive(not isMarried)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_GoTo" then
    local moonfather = constant.CMarriageConsts.marriageNPC
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {moonfather})
  end
end
def.method("string", "boolean").onToggle = function(self, id, active)
  if string.sub(id, 1, 17) == "Img_BgSkillGroup_" and active then
    local index = tonumber(string.sub(id, 18))
    self.select = index
    self:UpdateContent()
  end
end
MarrySkill.Commit()
return MarrySkill
