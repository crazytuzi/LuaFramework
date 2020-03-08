local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DragonBaoKuResultPanel = Lplus.Extend(ECPanelBase, "DragonBaoKuResultPanel")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local DragonBaoKuMgr = require("Main.activity.DragonBaoKu.DragonBaoKuMgr")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local def = DragonBaoKuResultPanel.define
local instance
def.field("table").awardItemInfoList = nil
def.static("=>", DragonBaoKuResultPanel).Instance = function()
  if instance == nil then
    instance = DragonBaoKuResultPanel()
  end
  return instance
end
def.method("table").ShowPanel = function(self, awardItemInfoList)
  if self:IsShow() then
    return
  end
  self.awardItemInfoList = awardItemInfoList
  self:CreatePanel(RESPATH.PREFAB_RANDOM_PRIZE_GET_DRAGON_BAO_KU, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.ACTIVITY_DRAGON_BAOKU_LOTTERY_INFO, DragonBaoKuResultPanel.OnLotteryInfo)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.ACTIVITY_DRAGON_BAOKU_LOTTERY_INFO, DragonBaoKuResultPanel.OnLotteryInfo)
end
def.static("table", "table").OnLotteryInfo = function(p1, p2)
  if instance and not _G.IsNil(instance.m_panel) then
    instance.awardItemInfoList = p1.awardInfo
    instance:refreshItemInfo()
  end
end
def.override("boolean").OnShow = function(self, b)
  if b then
    self:refreshItemInfo()
  else
    require("Main.activity.DragonBaoKu.ui.DragonBaoKuPanel").Instance():clearSelectedState()
  end
end
def.method().refreshItemInfo = function(self)
  self:setItemInfo()
  local req = require("netio.protocol.mzm.gsp.drawcarnival.CDrawAwardFinishReq").new()
  gmodule.network.sendProtocol(req)
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("-------DragonBaoKuResultPanel clickObj:", id)
  local strs = string.split(id, "_")
  if id == "Btn_Conform" then
    self:Hide()
  elseif id == "Btn_BuyAgain" then
    local pName = clickObj.parent.name
    local dragonBaoKuPanel = require("Main.activity.DragonBaoKu.ui.DragonBaoKuPanel").Instance()
    if pName == "Group_One" then
      dragonBaoKuPanel:sendDrawReq(1)
    elseif pName == "Group_Ten" then
      dragonBaoKuPanel:sendDrawReq(10)
    end
  elseif id == "Texture_Icon" then
    local Img_BgIcon = clickObj.parent
    local group = Img_BgIcon.parent
    local groupName = group.name
    local pName = group.parent.name
    local strs = string.split(pName, "_")
    local gstrs = string.split(groupName, "_")
    local idx
    if pName == "Group_One" then
      idx = 1
    elseif strs[1] == "item" then
      idx = tonumber(strs[2])
    end
    local groupIdx = tonumber(string.sub(Img_BgIcon.name, #"Img_BgIcon" + 1))
    if idx and groupIdx then
      local awardInfo = self.awardItemInfoList[idx]
      local infos = awardInfo.draw_award_info_list[groupIdx]
      for itemId, num in pairs(infos.item_cfg_id2count) do
        ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, clickObj, 0, false)
        return
      end
    end
  end
end
def.method().setItemInfo = function(self)
  local Group_Ten = self.m_panel:FindDirect("Img_Bg0/Group_Ten")
  local Group_One = self.m_panel:FindDirect("Img_Bg0/Group_One")
  local dragonBaoKuPanel = require("Main.activity.DragonBaoKu.ui.DragonBaoKuPanel").Instance()
  local passTypeCfg = DragonBaoKuMgr.GetDrawCarnivalPassTypeCfg(dragonBaoKuPanel.passType)
  if #self.awardItemInfoList > 1 then
    Group_One:SetActive(false)
    Group_Ten:SetActive(true)
    self:setTenItemInfo()
    if passTypeCfg then
      local Icon_Exchange = Group_Ten:FindDirect("Btn_BuyAgain/Icon_Exchange")
      GUIUtils.FillIcon(Icon_Exchange:GetComponent("UITexture"), passTypeCfg.icon)
    end
    local Effect_Ten = Group_Ten:FindDirect("Effect_Ten")
    Effect_Ten:SetActive(false)
    Effect_Ten:SetActive(true)
  else
    Group_One:SetActive(true)
    Group_Ten:SetActive(false)
    self:setOneItemInfo()
    local Btn_BuyAgain = Group_One:FindDirect("Btn_BuyAgain")
    local Img_Icon = Btn_BuyAgain:FindDirect("Img_Icon")
    local Icon_Exchange = Btn_BuyAgain:FindDirect("Icon_Exchange")
    local Label_Num = Btn_BuyAgain:FindDirect("Label_Num")
    Img_Icon:SetActive(false)
    Icon_Exchange:SetActive(true)
    if passTypeCfg then
      GUIUtils.FillIcon(Icon_Exchange:GetComponent("UITexture"), passTypeCfg.icon)
      Label_Num:GetComponent("UILabel"):set_text(1)
    end
    local Effect_One = Group_One:FindDirect("Effect_One")
    Effect_One:SetActive(false)
    Effect_One:SetActive(true)
  end
end
def.method().setOneItemInfo = function(self)
  local Group_One = self.m_panel:FindDirect("Img_Bg0/Group_One")
  for i, v in ipairs(self.awardItemInfoList) do
    self:setItemGroupInfo(Group_One, v)
  end
end
def.method().setTenItemInfo = function(self)
  local Group_Ten = self.m_panel:FindDirect("Img_Bg0/Group_Ten")
  local Container = Group_Ten:FindDirect("Container")
  local uiList = Container:GetComponent("UIList")
  uiList.itemCount = #self.awardItemInfoList
  uiList:Resize()
  for i, v in ipairs(self.awardItemInfoList) do
    local item = Container:FindDirect("item_" .. i)
    self:setItemGroupInfo(item, v)
  end
end
def.method("userdata", "table").setItemGroupInfo = function(self, obj, awrdInfo)
  local num = #awrdInfo.draw_award_info_list
  for i = 1, 3 do
    local Group = obj:FindDirect("Group_" .. i)
    if i == num then
      Group:SetActive(true)
      for n, infos in ipairs(awrdInfo.draw_award_info_list) do
        local Img_BgIcon = Group:FindDirect("Img_BgIcon" .. n)
        local Label = Img_BgIcon:FindDirect("Img_Num/Label")
        Label:GetComponent("UILabel"):set_text(infos.index + 1)
        for itemId, num in pairs(infos.item_cfg_id2count) do
          local Texture_Icon = Img_BgIcon:FindDirect("Texture_Icon")
          local itemBase = ItemUtils.GetItemBase(itemId)
          GUIUtils.FillIcon(Texture_Icon:GetComponent("UITexture"), itemBase.icon)
          local Label_Num = Img_BgIcon:FindDirect("Label_Num")
          Label_Num:GetComponent("UILabel"):set_text(num)
          local Label_Name = Img_BgIcon:FindDirect("Label_Name")
          local color = HtmlHelper.NameColor[itemBase.namecolor]
          if color then
            local itemName = string.format("[%s]%s[-]", color, itemBase.name)
            Label_Name:GetComponent("UILabel"):set_text(itemName)
          else
            Label_Name:GetComponent("UILabel"):set_text(itemBase.name)
          end
          Img_BgIcon:GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", itemBase.namecolor))
        end
      end
    else
      Group:SetActive(false)
    end
  end
end
return DragonBaoKuResultPanel.Commit()
