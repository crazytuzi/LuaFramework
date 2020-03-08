local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MenpaiStarResult = Lplus.Extend(ECPanelBase, "MenpaiStarResult")
local MenpaiStarModule = Lplus.ForwardDeclare("MenpaiStarModule")
local GUIUtils = require("GUI.GUIUtils")
local def = MenpaiStarResult.define
local instance
def.static("=>", MenpaiStarResult).Instance = function()
  if instance == nil then
    instance = MenpaiStarResult()
  end
  return instance
end
def.field("table").list = nil
def.static("table").ShowMenpaiStarResult = function(list)
  if list == nil then
    return
  end
  self.list = list
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PERFAB_MENPAISTAR_STAR, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:UpdateList()
end
def.method("userdata", "table", "number").FillItem = function(self, uiGo, info, index)
  local bgName = string.format("Img_BgList%d", index % 2 + 1)
  local bgSprite = uiGo:FindDirect(string.format("Img_Bg1_%d", index))
  bgSprite:GetComponent("UISprite"):set_text(bgName)
  local nameLbl = uiGo:FindDirect(string.format("Label_1_%d", index))
  nameLbl:GetComponent("UILabel"):set_text(info.name)
  local pointLbl = uiGo:FindDirect(string.format("Label_2_%d", index))
  pointLbl:GetComponent("UILabel"):set_text(info.point)
  local menpaiSpr = uiGo:FindDirect(string.format("Img_Camp_%d", index))
  local menpaiSpriteName = GUIUtils.GetOccupationSmallIcon(info.menpai)
  menpaiSpr:GetComponent("UISprite"):set_SpriteName(menpaiSpriteName)
end
def.method().UpdateList = function(self)
  local count = self.list and #self.list or 0
  local list = self.m_panel:FindDirect("Img_Bg0/Group_RankList/Group_List")
  local listCmp = list:GetComponent("UIList")
  listCmp:set_itemCount(count)
  listCmp:Resize()
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if not listCmp.isnil then
      listCmp:Reposition()
    end
  end)
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local info = self.list[i]
    self:FillItem(uiGo, info, i)
    self.m_msgHandler:Touch(uiGo)
  end
end
def.override().OnDestroy = function(self)
  self.list = nil
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  end
end
return MenpaiStarResult.Commit()
