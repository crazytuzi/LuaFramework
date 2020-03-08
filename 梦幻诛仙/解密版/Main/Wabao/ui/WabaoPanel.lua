local Lplus = require("Lplus")
local WabaoModule = Lplus.ForwardDeclare("WabaoModule")
local ECPanelBase = require("GUI.ECPanelBase")
local MathHelper = require("Common.MathHelper")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ECSoundMan = require("Sound.ECSoundMan")
local RewardItem = require("netio.protocol.mzm.gsp.baotu.RewardItem")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local WabaoPanel = Lplus.Extend(ECPanelBase, "WabaoPanel")
local def = WabaoPanel.define
def.static("table").ShowWabaoReward = function(awardList)
  local ItemModule = require("Main.Item.ItemModule")
  ItemModule.Instance():BlockItemGetEffect(true)
  PersonalHelper.Block(true)
  require("GUI.AnnouncementTip").Block(true)
  require("Main.Item.ui.EasyUseDlg").Block(true)
  local rewardPanel = WabaoPanel()
  rewardPanel.awardList = awardList
  rewardPanel.index = -1
  rewardPanel.slowDownIndex = -1
  rewardPanel.timer = 0
  rewardPanel.jumpCount = 0
  rewardPanel.jumpInterval = 0.1
  rewardPanel:CreatePanel(RESPATH.WABAO_PANEL, 1)
  rewardPanel:SetModal(true)
  rewardPanel.m_TrigGC = true
end
def.const("string").WABAOKEY = "WABAO"
def.const("number").GUIDETIME = 3
def.const("string").ROUNDEFFECT = RESPATH.SOUND_ROUND
def.const("number").AWARDCOUNT = 20
def.const("number").WAITTIME = 50
def.const("number").SLOWINTERVAL = 0.1
def.const("number").LASTSPEED = 1
def.field("table").awardList = nil
def.field("number").index = -1
def.field("number").slowDownIndex = -1
def.field("number").timer = 0
def.field("number").jumpCount = 0
def.field("boolean").readyToStop = false
def.field("number").jumpInterval = 0.1
def.field("table").guide = nil
def.override().OnCreate = function(self)
  self:UpdateInfo()
  local guide = false
  local PlayerPref = require("Main.Common.LuaPlayerPrefs")
  if PlayerPref.HasRoleKey(WabaoPanel.WABAOKEY) then
    local wabaoTime = PlayerPref.GetRoleInt(WabaoPanel.WABAOKEY)
    if wabaoTime < WabaoPanel.GUIDETIME then
      guide = true
      PlayerPref.SetRoleInt(WabaoPanel.WABAOKEY, wabaoTime + 1)
      PlayerPref.Save()
    end
  else
    guide = true
    PlayerPref.SetRoleInt(WabaoPanel.WABAOKEY, 1)
    PlayerPref.Save()
  end
  if not guide then
    return
  end
  GameUtil.AddGlobalTimer(0.1, true, function()
    local CommonGuideTip = require("GUI.CommonGuideTip")
    if self.guide then
      self.guide:HideDlg()
    end
    if self.m_panel and not self.m_panel.isnil then
      local close = self.m_panel:FindDirect("Img_Bg1/Btn_Close")
      if close then
        self.guide = CommonGuideTip.ShowGuideTip(textRes.Wabao[16], close, CommonGuideTip.StyleEnum.LEFT)
      end
    end
  end)
end
def.override().OnDestroy = function(self)
  local ItemModule = require("Main.Item.ItemModule")
  GameUtil.RemoveGlobalTimer(self.timer)
  self.timer = 0
  ItemModule.Instance():BlockItemGetEffect(false)
  PersonalHelper.Block(false)
  require("GUI.AnnouncementTip").Block(false)
  require("Main.Item.ui.EasyUseDlg").Block(false)
  WabaoModule.Instance():WabaoFinish()
  WabaoModule.Instance():TryToWabao()
  GameUtil.AddGlobalLateTimer(0.1, true, function()
    require("GUI.ECGUIMan").Instance():NotifyDisappear("")
  end)
  Event.DispatchEvent(ModuleId.DYEING, gmodule.notifyId.Dyeing.CLOSET_PANEL_CLOSE, nil)
  if self.guide and self.guide then
    self.guide:HideDlg()
  end
  self = nil
end
def.override("boolean").OnShow = function(self, show)
  if show == false then
    return
  end
  self.timer = GameUtil.AddGlobalTimer(self.jumpInterval, false, function()
    if self.m_panel == nil then
      GameUtil.RemoveGlobalTimer(self.timer)
      self.timer = 0
      return
    end
    local lightIndex = self.jumpCount % WabaoPanel.AWARDCOUNT + 1
    local toggleIcon = self.m_panel:FindDirect(string.format("Img_Bg1/Img_Bg2/Grid_Item/Item_%02d", lightIndex))
    local toggle = toggleIcon:GetComponent("UIToggle")
    require("Fx.GUIFxMan").Instance():PlayAsChild(toggleIcon:FindDirect("Img_Icon"), RESPATH.WABAO_EFFECT, 0, 0, -1, false)
    ECSoundMan.Instance():Play2DInterruptSound(WabaoPanel.ROUNDEFFECT)
    if self.readyToStop == false and self.jumpCount >= WabaoPanel.WAITTIME then
      self.readyToStop = true
    end
    if self.readyToStop and lightIndex == self.slowDownIndex then
      self:SlowDown()
    end
    self.jumpCount = self.jumpCount + 1
  end)
end
def.method().SlowDown = function(self)
  GameUtil.RemoveGlobalTimer(self.timer)
  self:JumpReduce()
end
def.method().JumpReduce = function(self)
  self.jumpInterval = self.jumpInterval + WabaoPanel.SLOWINTERVAL
  self.timer = GameUtil.AddGlobalTimer(self.jumpInterval, true, function()
    if self.m_panel == nil then
      GameUtil.RemoveGlobalTimer(self.timer)
      self.timer = 0
      return
    end
    local grid = self.m_panel:FindDirect("Img_Bg1/Img_Bg2/Grid_Item")
    local lightIndex = self.jumpCount % WabaoPanel.AWARDCOUNT + 1
    local toggleIcon = grid:FindDirect(string.format("Item_%02d", lightIndex))
    local toggle = toggleIcon:GetComponent("UIToggle")
    require("Fx.GUIFxMan").Instance():PlayAsChild(toggleIcon:FindDirect("Img_Icon"), RESPATH.WABAO_EFFECT, 0, 0, -1, false)
    ECSoundMan.Instance():Play2DInterruptSound(WabaoPanel.ROUNDEFFECT)
    if self.jumpInterval < WabaoPanel.LASTSPEED - 0.01 then
      self:JumpReduce()
    else
      toggleIcon:FindDirect("Img_Select"):SetActive(true)
      toggle:set_value(true)
      self:close()
    end
    self.jumpCount = self.jumpCount + 1
  end)
end
def.method().close = function(self)
  self.timer = GameUtil.AddGlobalTimer(3, true, function()
    self:DestroyPanel()
  end)
end
def.method().UpdateInfo = function(self)
  if self.awardList == nil or #self.awardList ~= WabaoPanel.AWARDCOUNT then
    print("awardList Wrong!")
    self:DestroyPanel()
    return
  end
  MathHelper.ShuffleTable(self.awardList, 2)
  self.index = math.random(WabaoPanel.AWARDCOUNT)
  local slowTime = (WabaoPanel.LASTSPEED - self.jumpInterval) / WabaoPanel.SLOWINTERVAL
  local slowDownPos = self.index - slowTime
  self.slowDownIndex = slowDownPos > 0 and slowDownPos or slowDownPos + WabaoPanel.AWARDCOUNT
  local grid = self.m_panel:FindDirect("Img_Bg1/Img_Bg2/Grid_Item")
  for i = self.index, WabaoPanel.AWARDCOUNT do
    local item = grid:FindDirect(string.format("Item_%02d", i))
    local info = self.awardList[i - self.index + 1]
    self:SetItem(item, info)
  end
  for i = 1, self.index - 1 do
    local item = grid:FindDirect(string.format("Item_%02d", i))
    local info = self.awardList[WabaoPanel.AWARDCOUNT - self.index + 1 + i]
    self:SetItem(item, info)
  end
end
def.method("userdata", "table").SetItem = function(self, item, info)
  local itemName = item:FindDirect("Label_Name")
  local otherGroup = item:FindDirect("Group_Name")
  local otherName = otherGroup:FindDirect("Label")
  local otherIcon = otherGroup:FindDirect("Texture")
  local icon = item:FindDirect("Img_Icon")
  local iconNum = item:FindDirect("Label_Num")
  item:FindDirect("Img_Select"):SetActive(false)
  local type = info.rewardType
  if type == RewardItem.TYPE_ITEM then
    local itemId = info.paramMap[RewardItem.PARAM_ITEM_ID]
    local num = info.paramMap[RewardItem.PARAM_ITEM_NUM]
    local itemBase = ItemUtils.GetItemBase(itemId)
    itemName:SetActive(true)
    itemName:GetComponent("UILabel"):set_text(string.format("[%s]%s[-]", require("Main.Chat.HtmlHelper").NameColor[itemBase.namecolor], itemBase.name))
    otherGroup:SetActive(false)
    if num > 1 then
      iconNum:SetActive(true)
      iconNum:GetComponent("UILabel"):set_text(num)
    else
      iconNum:SetActive(false)
    end
    GUIUtils.FillIcon(icon:GetComponent("UITexture"), itemBase.icon)
  elseif type == RewardItem.TYPE_ROLE_EXP then
    local exp = info.paramMap[RewardItem.PARAM_EXP]
    itemName:SetActive(false)
    iconNum:SetActive(false)
    otherGroup:SetActive(true)
    otherIcon:GetComponent("UISprite"):set_spriteName("Img_ExpRole")
    otherName:GetComponent("UILabel"):set_text(exp)
    GUIUtils.FillIcon(icon:GetComponent("UITexture"), GUIUtils.GetIconIdRoleExp())
  elseif type == RewardItem.TYPE_PET_EXP then
    local exp = info.paramMap[RewardItem.PARAM_EXP]
    itemName:SetActive(false)
    iconNum:SetActive(false)
    otherGroup:SetActive(true)
    otherIcon:GetComponent("UISprite"):set_spriteName("Img_ExpPet")
    otherName:GetComponent("UILabel"):set_text(exp)
    GUIUtils.FillIcon(icon:GetComponent("UITexture"), GUIUtils.GetIconIdPetExp())
  elseif type == RewardItem.TYPE_XIULIAN_EXP then
    local exp = info.paramMap[RewardItem.PARAM_EXP]
    itemName:SetActive(false)
    iconNum:SetActive(false)
    otherGroup:SetActive(true)
    otherIcon:GetComponent("UISprite"):set_spriteName("")
    otherName:GetComponent("UILabel"):set_text(exp)
    GUIUtils.FillIcon(icon:GetComponent("UITexture"), GUIUtils.GetIconIdXiulianExp())
  elseif type == RewardItem.TYPE_SILVER then
    local money = info.paramMap[RewardItem.PARAM_MONEY]
    itemName:SetActive(false)
    iconNum:SetActive(false)
    otherGroup:SetActive(true)
    otherIcon:GetComponent("UISprite"):set_spriteName("Icon_Sliver")
    otherName:GetComponent("UILabel"):set_text(money)
    GUIUtils.FillIcon(icon:GetComponent("UITexture"), GUIUtils.GetIconIdSilver())
  elseif type == RewardItem.TYPE_GOLD then
    local money = info.paramMap[RewardItem.PARAM_MONEY]
    itemName:SetActive(false)
    iconNum:SetActive(false)
    otherGroup:SetActive(true)
    otherIcon:GetComponent("UISprite"):set_spriteName("Icon_Gold")
    otherName:GetComponent("UILabel"):set_text(money)
    GUIUtils.FillIcon(icon:GetComponent("UITexture"), GUIUtils.GetIconIdGold())
  elseif type == RewardItem.TYPE_BANGGONG then
    local money = info.paramMap[RewardItem.PARAM_MONEY]
    itemName:SetActive(false)
    iconNum:SetActive(false)
    otherGroup:SetActive(true)
    otherIcon:GetComponent("UISprite"):set_spriteName("")
    otherName:GetComponent("UILabel"):set_text(money)
    GUIUtils.FillIcon(icon:GetComponent("UITexture"), GUIUtils.GetIconIdBanggong())
  elseif type == RewardItem.TYPE_CONTROLLER then
    local ctlId = info.paramMap[RewardItem.PARAM_OCNTROLLER_ID]
    local ctlCfg = WabaoModule.Instance():GetControllerCfg(ctlId)
    if ctlCfg then
      itemName:SetActive(true)
      itemName:GetComponent("UILabel"):set_text(ctlCfg.name)
      otherGroup:SetActive(false)
      iconNum:SetActive(false)
      GUIUtils.FillIcon(icon:GetComponent("UITexture"), ctlCfg.iconId)
    end
  elseif type == RewardItem.TYPE_YUANBAO then
    local money = info.paramMap[RewardItem.PARAM_MONEY]
    itemName:SetActive(false)
    iconNum:SetActive(false)
    otherGroup:SetActive(true)
    otherIcon:GetComponent("UISprite"):set_spriteName("Img_Money")
    otherName:GetComponent("UILabel"):set_text(money)
    GUIUtils.FillIcon(icon:GetComponent("UITexture"), GUIUtils.GetIconIdYuanbao())
  end
end
def.method("string").onClick = function(self, id)
  if id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Use" then
    self.readyToStop = true
    self.m_panel:FindDirect("Btn_Use"):GetComponent("UIButton"):set_isEnabled(false)
  elseif string.find(id, "Item_") then
    local index = tonumber(string.sub(id, 6))
    local info
    if index >= self.index then
      info = self.awardList[index - self.index + 1]
    else
      info = self.awardList[WabaoPanel.AWARDCOUNT - self.index + 1 + index]
    end
    local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
    local source = self.m_panel:FindDirect("Img_Bg1/Img_Bg2/Grid_Item/" .. id)
    local position = source:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local widget = source:GetComponent("UIWidget")
    if info.rewardType == RewardItem.TYPE_ITEM then
      local itemId = info.paramMap[RewardItem.PARAM_ITEM_ID]
      ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0, false)
    elseif info.rewardType == RewardItem.TYPE_ROLE_EXP then
      local exp = info.paramMap[RewardItem.PARAM_EXP]
      local iconId = GUIUtils.GetIconIdRoleExp()
      local title = exp .. textRes.BaoTu[10]
      local type = textRes.BaoTu[10]
      local desc = textRes.BaoTu[11]
      ItemTipsMgr.Instance():ShowCustomTip(title, iconId, type, desc, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
    elseif info.rewardType == RewardItem.TYPE_PET_EXP then
      local exp = info.paramMap[RewardItem.PARAM_EXP]
      local iconId = GUIUtils.GetIconIdPetExp()
      local title = exp .. textRes.BaoTu[12]
      local type = textRes.BaoTu[12]
      local desc = textRes.BaoTu[13]
      ItemTipsMgr.Instance():ShowCustomTip(title, iconId, type, desc, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
    elseif info.rewardType == RewardItem.TYPE_XIULIAN_EXP then
      local exp = info.paramMap[RewardItem.PARAM_EXP]
      local iconId = GUIUtils.GetIconIdXiulianExp()
      local title = exp .. textRes.BaoTu[18]
      local type = textRes.BaoTu[18]
      local desc = textRes.BaoTu[19]
      ItemTipsMgr.Instance():ShowCustomTip(title, iconId, type, desc, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
    elseif info.rewardType == RewardItem.TYPE_SILVER then
      local money = info.paramMap[RewardItem.PARAM_MONEY]
      local iconId = GUIUtils.GetIconIdSilver()
      local title = money .. textRes.BaoTu[16]
      local type = textRes.BaoTu[16]
      local desc = textRes.BaoTu[17]
      ItemTipsMgr.Instance():ShowCustomTip(title, iconId, type, desc, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
    elseif info.rewardType == RewardItem.TYPE_BANGGONG then
      local money = info.paramMap[RewardItem.PARAM_MONEY]
      local iconId = GUIUtils.GetIconIdBanggong()
      local title = money .. textRes.BaoTu[26]
      local type = textRes.BaoTu[26]
      local desc = textRes.BaoTu[27]
      ItemTipsMgr.Instance():ShowCustomTip(title, iconId, type, desc, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
    elseif info.rewardType == RewardItem.TYPE_CONTROLLER then
      local ctlId = info.paramMap[RewardItem.PARAM_OCNTROLLER_ID]
      local ctlCfg = WabaoModule.Instance():GetControllerCfg(ctlId)
      if ctlCfg then
        local iconId = ctlCfg.iconId
        local title = ctlCfg.name
        local type = ctlCfg.name
        local desc = ctlCfg.desc
        ItemTipsMgr.Instance():ShowCustomTip(title, iconId, type, desc, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
      end
    elseif info.rewardType == RewardItem.TYPE_YUANBAO then
      local money = info.paramMap[RewardItem.PARAM_MONEY]
      local iconId = GUIUtils.GetIconIdYuanbao()
      local title = money .. textRes.BaoTu[20]
      local type = textRes.BaoTu[20]
      local desc = textRes.BaoTu[21]
      ItemTipsMgr.Instance():ShowCustomTip(title, iconId, type, desc, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
    elseif info.rewardType == RewardItem.TYPE_GOLD then
      local money = info.paramMap[RewardItem.PARAM_MONEY]
      local iconId = GUIUtils.GetIconIdGold()
      local title = money .. textRes.BaoTu[14]
      local type = textRes.BaoTu[14]
      local desc = textRes.BaoTu[15]
      ItemTipsMgr.Instance():ShowCustomTip(title, iconId, type, desc, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
    end
  end
end
WabaoPanel.Commit()
return WabaoPanel
