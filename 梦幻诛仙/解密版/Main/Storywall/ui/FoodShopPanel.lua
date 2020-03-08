local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local FoodShopPanel = Lplus.Extend(ECPanelBase, "FoodShopPanel")
local StoryWallUtils = require("Main.Storywall.StoryWallUtils")
local ECUIModel = require("Model.ECUIModel")
local def = FoodShopPanel.define
local instance
def.field("table").uiTbl = nil
def.field("boolean").bWaitData = false
def.field("table").storys = nil
def.static("=>", FoodShopPanel).Instance = function()
  if not instance then
    instance = FoodShopPanel()
    instance.m_TrigGC = true
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self.bWaitData = true
  Event.RegisterEvent(ModuleId.STORYWALL, gmodule.notifyId.Storywall.StoryWallInfo, FoodShopPanel.OnStoryWallInfo)
  Event.RegisterEvent(ModuleId.STORYWALL, gmodule.notifyId.Storywall.StoryWallRefresh, FoodShopPanel.OnStoryWallRefresh)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.storywall.CGetStoryWallInfoReq").new())
end
def.override().OnCreate = function(self)
  self:InitUI()
end
def.override().OnDestroy = function(self)
  self.bWaitData = false
  Event.UnregisterEvent(ModuleId.STORYWALL, gmodule.notifyId.Storywall.StoryWallInfo, FoodShopPanel.OnStoryWallInfo)
  Event.UnregisterEvent(ModuleId.STORYWALL, gmodule.notifyId.Storywall.StoryWallRefresh, FoodShopPanel.OnStoryWallRefresh)
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow then
    self:UpdateUI()
  end
end
def.method().InitUI = function(self)
  if not self.uiTbl then
    self.uiTbl = {}
  end
  local uiTbl = self.uiTbl
  local StoryName = {}
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  for i = 1, constant.StoryWallConst.storycount do
    local Img_StoryBanner = Img_Bg0:FindDirect(("Img_StoryBanner_%d"):format(i))
    StoryName[i] = Img_StoryBanner:FindDirect("Label_StoryName"):GetComponent("UILabel")
  end
  uiTbl.StoryName = StoryName
end
def.method().UpdateUI = function(self)
  local uiStoryName = self.uiTbl.StoryName
  for i = 1, constant.StoryWallConst.storycount do
    local nameLabel = uiStoryName[i]
    if nameLabel and self.storys[i] then
      nameLabel:set_text(self.storys[i].name or "")
    else
      nameLabel:set_text("")
    end
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.sub(id, 1, #"Img_StoryBanner") == "Img_StoryBanner" then
    self:OnStoryBannerClick(clickobj)
  else
    warn("gangrace panel btn:", id)
  end
end
def.method("userdata").OnStoryBannerClick = function(self, clickobj)
  local index = tonumber(string.sub(clickobj.name, #"Img_StoryBanner_" + 1, -1))
  local story = self.storys[index]
  if story then
    require("Main.Storywall.ui.StoryWallPanel").Instance():ShowPanel(story)
  end
end
def.static("table", "table").OnStoryWallInfo = function(params, context)
  local p = params[1]
  local storys = {}
  local self = FoodShopPanel.Instance()
  for k, id in pairs(p.storyids) do
    local story = StoryWallUtils.GetStoryCfg(id)
    table.insert(storys, story)
  end
  self.storys = storys
  if self.bWaitData == true then
    self.bWaitData = false
    self:SetModal(true)
    self:CreatePanel(RESPATH.PREFAB_FOODSHOP, 1)
  elseif self.m_panel and not self.m_panel.isnil then
    self:UpdateUI()
  end
end
def.static("table", "table").OnStoryWallRefresh = function(params, context)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.storywall.CGetStoryWallInfoReq").new())
end
return FoodShopPanel.Commit()
