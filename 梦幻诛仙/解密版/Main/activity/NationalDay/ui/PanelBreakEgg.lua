local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local NationalDayData = require("Main.activity.NationalDay.data.NationalDayData")
local ItemUtils = require("Main.Item.ItemUtils")
local PanelBreakEgg = Lplus.Extend(ECPanelBase, "PanelBreakEgg")
local def = PanelBreakEgg.define
local instance
def.static("=>", PanelBreakEgg).Instance = function()
  if instance == nil then
    instance = PanelBreakEgg()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.field("table")._openMap = nil
def.static().ShowPanel = function()
  if PanelBreakEgg.Instance():IsShow() then
    PanelBreakEgg.Instance():UpdateUI()
    return
  end
  instance:CreatePanel(RESPATH.PREFAB_ACTIVITY_NATIONAL_DAY_BREAK_EGG, -1)
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Group_Item = self.m_panel:FindDirect("Img_Bg0/Group_Item")
  self._uiObjs.effect = self._uiObjs.Group_Item:FindDirect("Effect")
  self._uiObjs.items = {}
  for i = 1, 6 do
    local item = self._uiObjs.Group_Item:FindDirect("Item_0" .. i)
    self._uiObjs.items[i] = item
    item:FindDirect("Group_Close"):SetActive(true)
    item:FindDirect("Group_Open"):SetActive(false)
    item:FindDirect("Label_Player"):GetComponent("UILabel"):set_text(textRes.activity.NationalDay[11])
  end
  self._uiObjs.InviteBtn = self.m_panel:FindDirect("Img_Bg0/Btn_Hit")
  self._uiObjs.InviteBtnLabel = self._uiObjs.InviteBtn:FindDirect("Label_Name")
  self._uiObjs.Label_Tips = self.m_panel:FindDirect("Img_Bg0/Label_Tips")
  self._uiObjs.roleList = self.m_panel:FindDirect("Img_Bg0/Group_List/List")
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:UpdateUI()
    local activityCfg = require("Main.activity.ActivityInterface").GetActivityCfgById(constant.CNationalHolidayConst.BREAK_EGG_ID)
    local time_label = self.m_panel:FindDirect("Img_Bg0/Group_Time/Label_Time")
    time_label:GetComponent("UILabel"):set_text(activityCfg.timeDes)
  end
end
def.method().UpdateUI = function(self)
  if self._uiObjs == nil then
    return
  end
  local uiList = self._uiObjs.roleList:GetComponent("UIList")
  local roles = NationalDayData.Instance():GetBreakEggRolelist()
  if roles then
    local num = table.nums(roles)
    uiList.itemCount = num
    uiList:Resize()
    local key, roledata
    for i = 1, num do
      local rolePanel = self._uiObjs.roleList:FindDirect("item_" .. i)
      if rolePanel then
        key, roledata = next(roles, key)
        local frame = rolePanel:FindDirect("Img_BgIconGroup")
        local headIcon = frame:FindDirect("Texture_IconGroup")
        _G.SetAvatarFrameIcon(frame, roledata.avatarFrameid)
        _G.SetAvatarIcon(headIcon, roledata.avatarId)
        GUIUtils.SetText(rolePanel:FindDirect("Label_Name"), roledata.roleName)
      end
    end
  end
  self:ShowResult()
  self:SetInviteBtnText(textRes.activity.NationalDay[7])
  self:ChangePhase()
  self:SetInviteEnable(not gmodule.moduleMgr:GetModule(ModuleId.NATIONAL_DAY):IsInSession())
end
def.override().OnDestroy = function(self)
  self._uiObjs = nil
  self._openMap = nil
end
def.method("string").onClick = function(self, id)
  if string.find(id, "Item_0") == 1 then
    local idx = tonumber(string.sub(id, -1, -1))
    if self._openMap and self._openMap[idx] then
      local itemId = self._openMap[idx]
      local anchorGO = self._uiObjs.items[idx]
      ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, anchorGO, 0, false)
      return
    end
    local phase = NationalDayData.Instance():GetBreakEggPhase()
    if phase ~= NationalDayData.BREAK_EGG_PHASE.PERFORM then
      Toast(textRes.activity.NationalDay[10])
      return
    end
    if NationalDayData.Instance():HasDone() then
      Toast(textRes.activity.NationalDay[13])
      return
    end
    self:BreakEgg(idx)
  elseif id == "Bth_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Hit" then
    local pro = require("netio.protocol.mzm.gsp.breakegg.CBreakEggInviteReq").new(constant.CNationalHolidayConst.BREAK_EGG_ID)
    gmodule.network.sendProtocol(pro)
    self:SetInviteEnable(false)
  elseif id == "Btn_Help" then
    local cfg = require("Main.activity.NationalDay.NationalDayUtils").GetBreakEggCfg(constant.CNationalHolidayConst.BREAK_EGG_ID)
    _G.ShowCommonCenterTip(cfg.tipsId)
  end
end
def.method("number").UpdateTime = function(self, left_time)
  if self._uiObjs == nil then
    return
  end
  local phase = NationalDayData.Instance():GetBreakEggPhase()
  if phase == NationalDayData.BREAK_EGG_PHASE.PERFORM then
    local txt = string.format(textRes.activity.NationalDay[9], left_time)
    GUIUtils.SetText(self._uiObjs.Label_Tips, txt)
  elseif phase == NationalDayData.BREAK_EGG_PHASE.PERFORM then
    GUIUtils.SetText(self._uiObjs.Label_Tips, textRes.activity.NationalDay[24])
  else
    local isInviter = NationalDayData.Instance():GetIsInviter()
    if left_time <= 0 then
      if isInviter then
        self:SetInviteEnable(true)
        self:SetInviteBtnText(textRes.activity.NationalDay[7])
      end
    elseif isInviter then
      self:SetInviteBtnText(string.format(textRes.activity.NationalDay[8], left_time))
    else
      GUIUtils.SetText(self._uiObjs.Label_Tips, string.format(textRes.activity.NationalDay[20], left_time))
    end
  end
end
def.method("boolean").SetInviteEnable = function(self, enable)
  if self._uiObjs then
    self._uiObjs.InviteBtn:GetComponent("UIButton"):set_isEnabled(enable)
  end
end
def.method("string").SetInviteBtnText = function(self, txt)
  if self._uiObjs then
    GUIUtils.SetText(self._uiObjs.InviteBtnLabel, txt)
  end
end
def.method().ChangePhase = function(self)
  if self._uiObjs then
    local phase = NationalDayData.Instance():GetBreakEggPhase()
    local isInviter = NationalDayData.Instance():GetIsInviter()
    self._uiObjs.InviteBtn:SetActive(isInviter and phase ~= NationalDayData.BREAK_EGG_PHASE.PERFORM and phase ~= NationalDayData.BREAK_EGG_PHASE.PRE_PERFORM)
    GUIUtils.SetText(self._uiObjs.Label_Tips, "")
    self._uiObjs.Label_Tips:SetActive(phase == NationalDayData.BREAK_EGG_PHASE.PERFORM or phase == NationalDayData.BREAK_EGG_PHASE.PRE_PERFORM or not isInviter)
    if phase == NationalDayData.BREAK_EGG_PHASE.PRE_PERFORM then
      GUIUtils.SetText(self._uiObjs.Label_Tips, textRes.activity.NationalDay[24])
      local cfg = require("Main.activity.NationalDay.NationalDayUtils").GetBreakEggCfg(constant.CNationalHolidayConst.BREAK_EGG_ID)
      local effRes = GetEffectRes(cfg.beginEffectId)
      if effRes then
        local name = tostring(cfg.beginEffectId)
        require("Fx.GUIFxMan").Instance():Play(effRes.path, name, 0, 0, -1, false)
      end
    end
  end
end
def.method("number").BreakEgg = function(self, idx)
  local session = gmodule.moduleMgr:GetModule(ModuleId.NATIONAL_DAY).break_egg_session
  if session == nil then
    return
  end
  self._uiObjs.effect:SetActive(false)
  self._uiObjs.effect.localPosition = self._uiObjs.items[idx].localPosition
  self._uiObjs.effect:SetActive(true)
  local pro = require("netio.protocol.mzm.gsp.breakegg.CBreakEggReq").new()
  pro.activity_id = constant.CNationalHolidayConst.BREAK_EGG_ID
  pro.inviter_id = session.inviter
  pro.index = idx - 1
  gmodule.network.sendProtocol(pro)
  GameUtil.AddGlobalTimer(0.5, true, function()
    if self._uiObjs == nil then
      return
    end
    local cfg = require("Main.activity.NationalDay.NationalDayUtils").GetBreakEggCfg(constant.CNationalHolidayConst.BREAK_EGG_ID)
    local effRes = GetEffectRes(cfg.breakEffectId)
    if effRes then
      require("Fx.GUIFxMan").Instance():PlayAsChild(self._uiObjs.items[idx], effRes.path, 0, 0, -1, false)
    end
  end)
end
def.method().ShowResult = function(self)
  if self._uiObjs == nil then
    return
  end
  local result = NationalDayData.Instance():GetBreakEggResult()
  if result == nil then
    return
  end
  for idx, v in pairs(result) do
    if self._openMap == nil or self._openMap[idx] == nil then
      local item = self._uiObjs.items[idx]
      if v.role_id:gt(0) then
        local roledata = NationalDayData.Instance():GetBreakEggRole(v.role_id)
        item:FindDirect("Label_Player"):GetComponent("UILabel"):set_text(string.format("[00ff00]%s[-]", roledata.roleName))
      end
      for itemId, num in pairs(v.itemId2num) do
        local itemBase = ItemUtils.GetItemBase(itemId)
        local itemIcon = item:FindDirect("Group_Open/Texture")
        local uiTexture = itemIcon:GetComponent("UITexture")
        GUIUtils.FillIcon(uiTexture, itemBase.icon)
        if self._openMap == nil then
          self._openMap = {}
        end
        self._openMap[idx] = itemId
      end
      item:FindDirect("Group_Close"):SetActive(false)
      item:FindDirect("Group_Open"):SetActive(true)
      item:FindDirect("Img_Sign"):SetActive(false)
    end
  end
end
def.method("table").ShowGetItem = function(self, itemList)
  if self._uiObjs == nil then
    return
  end
  local itemsStr = ""
  for i = 1, #itemList do
    local itemId = itemList[i]
    local itemBase = ItemUtils.GetItemBase(itemId)
    if itemBase then
      local HtmlHelper = require("Main.Chat.HtmlHelper")
      local color = HtmlHelper.NameColor[itemBase.namecolor]
      local itemName = itemBase.name
      if color then
        itemName = string.format("[%s]%s[-]", color, itemBase.name)
      end
      if i > 1 then
        itemsStr = itemsStr .. ", "
      end
      itemsStr = itemsStr .. itemName
    end
  end
  local tipstr
  local isInviter = NationalDayData.Instance():GetIsInviter()
  if isInviter then
    tipstr = string.format(textRes.activity.NationalDay[18], itemsStr)
  else
    local session = gmodule.moduleMgr:GetModule(ModuleId.NATIONAL_DAY).break_egg_session
    local inviter = session and session.inviter
    local roledata = NationalDayData.Instance():GetBreakEggRole(inviter)
    tipstr = string.format(textRes.activity.NationalDay[25], roledata.roleName, itemsStr)
  end
  GUIUtils.SetText(self._uiObjs.Label_Tips, tipstr)
end
PanelBreakEgg.Commit()
return PanelBreakEgg
