local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local WatchMoonList = Lplus.Extend(ECPanelBase, "WatchMoonList")
local ECUIModel = require("Model.ECUIModel")
local GUIUtils = require("GUI.GUIUtils")
local instance
local def = WatchMoonList.define
def.static("=>", WatchMoonList).Instance = function(self)
  if instance == nil then
    instance = WatchMoonList()
  end
  return instance
end
def.const("table").WatchMoonState = {
  Available = 0,
  Unvailable = 1,
  Inviting = 2,
  Refuse = 3,
  Overtime = 4
}
def.static("table").ShowWatchMoonList = function(memberList)
  if memberList == nil then
    return
  end
  WatchMoonList.Instance().memberList = memberList
  if WatchMoonList.Instance():IsShow() then
    WatchMoonList.Instance():RefreshContent()
  else
    WatchMoonList.Instance():CreatePanel(RESPATH.PREFAB_WATCHMOON, 2)
    WatchMoonList.Instance():SetModal(true)
  end
end
def.static().CloseWatchMoonList = function()
  WatchMoonList.Instance():DestroyPanel()
end
def.field("table").memberList = nil
def.field("number").selectIndex = 0
def.field("table").watchMoonTimes = nil
def.field("table").watchMoonState = nil
def.field("table").model = nil
def.field("boolean").auto = false
def.field("number").autoIndex = 0
def.field("number").autoTimer = 0
def.override().OnCreate = function(self)
  self:RefreshContent()
  self:SetBtnLight()
  self:SetDescription()
end
def.override().OnDestroy = function(self)
  self:SelectIndex(0)
  self:StopAutoInvite()
end
def.override("boolean").OnShow = function(self, show)
  if show and self.model then
    self.model:Play(ActionName.Stand)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Auto" then
    if not self.auto then
      self:StartAutoInvite()
    else
      self:StopAutoInvite()
      Toast(textRes.WatchMoon[29])
    end
  elseif id == "Btn_Refresh" then
    if self.auto then
      Toast(textRes.WatchMoon[28])
      return
    end
    require("Main.activity.WatchMoon.WatchMoonMgr").Instance():ShowWatchMoonList()
  elseif id == "Btn_Invite" then
    if self.auto then
      Toast(textRes.WatchMoon[28])
      return
    end
    local info = self.memberList[self.selectIndex]
    if info then
      local roleId = info.roleId
      require("Main.activity.WatchMoon.WatchMoonMgr").Instance():SendWatchMoonRequest(roleId)
    else
      Toast(textRes.WatchMoon[13])
    end
  elseif string.sub(id, 1, 5) == "item_" then
    local index = tonumber(string.sub(id, 6))
    self:SelectIndex(index or 0)
  end
end
def.method().HandlSwitch = function(self)
  local autoBtn = self.m_panel:FindDirect("Img_Bg0/Btn_Auto")
  local open = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_AUTO_INVITE_WATCH_MOON)
  autoBtn:SetActive(open)
end
def.static("table").SGetWatchCountRes = function(p)
  local self = WatchMoonList.Instance()
  self.watchMoonTimes = {}
  self.watchMoonState = {}
  for k, v in pairs(p.roleid2state) do
    self.watchMoonTimes[k:tostring()] = v.count
    self.watchMoonState[k:tostring()] = v.canWatchMoon > 0 and WatchMoonList.WatchMoonState.Available or WatchMoonList.WatchMoonState.Unvailable
  end
  self:UpdateMemberTimes()
end
def.static("table").SQueryRoleModelInfoRes = function(p)
  local self = WatchMoonList.Instance()
  local info = self.memberList[self.selectIndex]
  if info then
    local curSelectRoleId = info.roleId
    if curSelectRoleId == p.roleid then
      self:UpdateModel(p.modelinfo)
    end
  else
    self:UpdateModel(nil)
  end
end
def.method().RefreshContent = function(self)
  self:UpdateMemberList()
  self:RequestWatchMoonTimes()
  self:SelectIndex(1)
end
def.method("number").SelectIndex = function(self, index)
  local info = self.memberList[index]
  if info then
    self.selectIndex = index
    local roleId = info.roleId
    self:RequetMemberModelInfo(roleId)
    local scroll = self.m_panel:FindDirect("Img_Bg0/Group_Left/Group_List/Scroll View")
    local listItem = scroll:FindDirect("List_Left/item_" .. index)
    listItem:GetComponent("UIToggle"):set_value(true)
    GUIUtils.DragToMakeVisible(scroll, listItem, false, 256)
  else
    self.selectIndex = 0
    local templateItem = self.m_panel:FindDirect("Img_Bg0/Group_Left/Group_List/Scroll View/List_Left/Group_List")
    local toggleGroup = templateItem:GetComponent("UIToggle"):get_group()
    local activeToggle = UIToggle.GetActiveToggle(toggleGroup)
    if activeToggle then
      activeToggle:set_value(false)
    end
    self:UpdateModel(nil)
  end
end
def.method().UpdateMemberList = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  if #self.memberList > 0 then
    local empty = self.m_panel:FindDirect("Img_Bg0/Group_Left/Group_Empty")
    empty:SetActive(false)
    local list = self.m_panel:FindDirect("Img_Bg0/Group_Left/Group_List/Scroll View/List_Left")
    list:SetActive(true)
    local listCom = list:GetComponent("UIList")
    listCom.itemCount = #self.memberList
    listCom:Resize()
    for i = 1, #self.memberList do
      local item = list:FindDirect(string.format("item_%d", i))
      if item then
        if i % 2 == 0 then
          item:FindDirect("Img_Bg1"):SetActive(false)
          item:FindDirect("Img_Bg2"):SetActive(true)
        else
          item:FindDirect("Img_Bg1"):SetActive(true)
          item:FindDirect("Img_Bg2"):SetActive(false)
        end
        local info = self.memberList[i]
        local nameLabel = item:FindDirect("Label_UserName"):GetComponent("UILabel")
        nameLabel:set_text(info.name)
        local levelLabel = item:FindDirect("Label_Level"):GetComponent("UILabel")
        levelLabel:set_text(tostring(info.level))
        local timesLabel = item:FindDirect("Label_Count"):GetComponent("UILabel")
        timesLabel:set_text("-")
        local stateLabel = item:FindDirect("Label_Auto"):GetComponent("UILabel")
        stateLabel:set_text("")
      end
    end
    self.m_msgHandler:Touch(list)
    GameUtil.AddGlobalTimer(0.01, true, function()
      if self.m_panel and not self.m_panel.isnil then
        self.m_panel:FindDirect("Img_Bg0/Group_Left/Group_List/Scroll View"):GetComponent("UIScrollView"):ResetPosition()
      end
    end)
  else
    local list = self.m_panel:FindDirect("Img_Bg0/Group_Left/Group_List/Scroll View/List_Left")
    local empty = self.m_panel:FindDirect("Img_Bg0/Group_Left/Group_Empty")
    list:SetActive(false)
    empty:SetActive(true)
  end
end
def.method().RequestWatchMoonTimes = function(self)
  local roleIdList = {}
  if #self.memberList > 0 then
    for i = 1, #self.memberList do
      table.insert(roleIdList, self.memberList[i].roleId)
    end
    local p = require("netio.protocol.mzm.gsp.watchmoon.CGetWatchCountReq").new(roleIdList)
    gmodule.network.sendProtocol(p)
  end
end
def.method().UpdateMemberTimes = function(self)
  local list = self.m_panel:FindDirect("Img_Bg0/Group_Left/Group_List/Scroll View/List_Left")
  for i = 1, #self.memberList do
    local item = list:FindDirect(string.format("item_%d", i))
    if item then
      local info = self.memberList[i]
      local times = self.watchMoonTimes and self.watchMoonTimes[info.roleId:tostring()]
      if times then
        local timesLabel = item:FindDirect("Label_Count"):GetComponent("UILabel")
        if times >= 0 then
          timesLabel:set_text(tostring(times))
        else
          timesLabel:set_text("-")
        end
      end
      local stateLabel = item:FindDirect("Label_Auto"):GetComponent("UILabel")
      stateLabel:set_text("")
    end
  end
end
def.method("userdata").RequetMemberModelInfo = function(self, roleId)
  if roleId then
    local p = require("netio.protocol.mzm.gsp.watchmoon.CQueryRoleModelInfoReq").new(roleId)
    gmodule.network.sendProtocol(p)
  end
end
def.method("table").UpdateModel = function(self, modelInfo)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  if self.model then
    self.model:Destroy()
    self.model = nil
  end
  if modelInfo then
    do
      local uiModel = self.m_panel:FindDirect("Img_Bg0/Model_Target"):GetComponent("UIModel")
      self.model = ECUIModel.new(modelInfo.modelid)
      self.model:AddOnLoadCallback("watchmoon", function()
        uiModel.modelGameObject = self.model.m_model
        if uiModel.mCanOverflow ~= nil then
          uiModel.mCanOverflow = true
          local camera = uiModel:get_modelCamera()
          camera:set_orthographic(true)
        end
      end)
      LoadModel(self.model, modelInfo, 0, 0, 180, false, false)
    end
  end
end
def.method().SetBtnLight = function(self)
  local watchMoonActivityInfo = require("Main.activity.ActivityInterface").Instance():GetActivityInfo(constant.CWatchmoonConsts.ACTIVITY_ID)
  if watchMoonActivityInfo and watchMoonActivityInfo.count and watchMoonActivityInfo.count > 0 then
  else
    local btn = self.m_panel:FindDirect("Img_Bg0/Btn_Invite")
    GUIUtils.SetLightEffect(btn, GUIUtils.Light.Square)
  end
end
def.method().SetDescription = function(self)
  local desc = self.m_panel:FindDirect("Img_Bg0/Model_Target/Label")
  local descLabel = desc:GetComponent("UILabel")
  descLabel:set_text(string.format(textRes.WatchMoon[12], constant.CWatchmoonConsts.MIN_LEVEL_FOR_COUPLE_FLY))
end
def.method("userdata", "number").SetWatchMoonState = function(self, roleId, state)
  if self.watchMoonState then
    self.watchMoonState[roleId:tostring()] = state
  end
  for k, v in ipairs(self.memberList) do
    if v.roleId == roleId then
      local list = self.m_panel:FindDirect("Img_Bg0/Group_Left/Group_List/Scroll View/List_Left")
      local item = list:FindDirect(string.format("item_%d", k))
      local stateLabel = item:FindDirect("Label_Auto"):GetComponent("UILabel")
      local stateStr = textRes.WatchMoon.WatchMoonState[state] or ""
      stateLabel:set_text(stateStr)
      return
    end
  end
end
def.method("userdata", "number").SetInviteResult = function(self, roleId, state)
  if self:IsShow() then
    self:SetWatchMoonState(roleId, state)
    if self.auto then
      GameUtil.RemoveGlobalTimer(self.autoTimer)
      if state == WatchMoonList.WatchMoonState.Inviting or state == WatchMoonList.WatchMoonState.Available then
      else
        local member = self.memberList[self.autoIndex]
        if member and member.roleId == roleId then
          GameUtil.AddGlobalTimer(1, true, function()
            if self:IsShow() and self.auto and not self:InviteOne() then
              self:StopAutoInvite()
              Toast(textRes.WatchMoon[27])
            end
          end)
        end
      end
    end
  end
end
def.method("number", "=>", "boolean").AutoInvite = function(self, index)
  local info = self.memberList[index]
  local roleId = info.roleId
  local ret = require("Main.activity.WatchMoon.WatchMoonMgr").Instance():SendWatchMoonRequest(roleId)
  if ret == 0 then
    GameUtil.RemoveGlobalTimer(self.autoTimer)
    self.autoTimer = GameUtil.AddGlobalTimer(constant.CWatchmoonConsts.DEFAULT_REFUSE_TIME * 2, true, function()
      if not self:InviteOne() then
        self:StopAutoInvite()
        Toast(textRes.WatchMoon[27])
      end
    end)
    return true
  elseif ret == -1 then
    return false
  elseif ret == 1 then
    self:SetInviteResult(roleId, WatchMoonList.WatchMoonState.Refuse)
    return true
  end
end
def.method("number", "=>", "number").AutoSelect = function(self, cur)
  local i = cur + 1
  local member = self.memberList[i]
  if member then
    return i
  else
    return 0
  end
end
def.method("=>", "boolean").InviteOne = function(self)
  self.autoIndex = self:AutoSelect(self.autoIndex)
  if self.autoIndex > 0 then
    self:SelectIndex(self.autoIndex)
    return self:AutoInvite(self.autoIndex)
  else
    return false
  end
end
def.method().StartAutoInvite = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_AUTO_INVITE_WATCH_MOON) then
    Toast(textRes.WatchMoon[30])
    return
  end
  if not self.auto then
    self:UpdateMemberList()
    self:UpdateMemberTimes()
    self.auto = true
    self.autoIndex = 0
    if not self:InviteOne() then
      self:StopAutoInvite()
    else
      Toast(textRes.WatchMoon[26])
      self:SetAutoBtn(true)
    end
  end
end
def.method().StopAutoInvite = function(self)
  if self:IsShow() and self.auto then
    self.auto = false
    GameUtil.RemoveGlobalTimer(self.autoTimer)
    self.autoIndex = 0
    self:SetAutoBtn(false)
  end
end
def.method("boolean").SetAutoBtn = function(self, auto)
  local autoBtn = self.m_panel:FindDirect("Img_Bg0/Btn_Auto/Label")
  if auto then
    autoBtn:GetComponent("UILabel"):set_text(textRes.WatchMoon[25])
  else
    autoBtn:GetComponent("UILabel"):set_text(textRes.WatchMoon[24])
  end
end
def.method("=>", "boolean").IsAuto = function(self)
  return self.auto
end
WatchMoonList.Commit()
return WatchMoonList
