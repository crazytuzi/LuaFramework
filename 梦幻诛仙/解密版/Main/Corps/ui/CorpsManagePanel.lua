local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CorpsManagePanel = Lplus.Extend(ECPanelBase, "CorpsManagePanel")
local CorpsDuty = require("consts.mzm.gsp.corps.confbean.CorpsDuty")
local GUIUtils = require("GUI.GUIUtils")
local CorpsModule = Lplus.ForwardDeclare("CorpsModule")
local ECUIModel = require("Model.ECUIModel")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local CrossBattleActivityStage = require("netio.protocol.mzm.gsp.crossbattle.crossBattleActivityStage")
local def = CorpsManagePanel.define
def.field("userdata").selectRoleId = nil
def.field("table").members = nil
def.field("table").models = nil
def.field("table").uiModels = nil
def.field("number").updateTimer = 0
local instance
def.static("=>", CorpsManagePanel).Instance = function()
  if instance == nil then
    instance = CorpsManagePanel()
  end
  return instance
end
def.static().ShowCorpsManage = function()
  if CorpsModule.Instance():GetData() == nil then
    return
  end
  local dlg = CorpsManagePanel.Instance()
  dlg:CreatePanel(RESPATH.PREFAB_CORPS_MANAGE, 1)
  dlg:SetModal(true)
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.CORPS, gmodule.notifyId.Corps.CorpsChange, CorpsManagePanel.OnCorpsChange, self)
  Event.RegisterEventWithContext(ModuleId.CORPS, gmodule.notifyId.Corps.MemberChange, CorpsManagePanel.OnMemberChange, self)
  Event.RegisterEventWithContext(ModuleId.CORPS, gmodule.notifyId.Corps.MemberOnlineChange, CorpsManagePanel.OnMemberOnlineChange, self)
  Event.RegisterEventWithContext(ModuleId.CORPS, gmodule.notifyId.Corps.MemberInfoChange, CorpsManagePanel.OnMemberInfoChange, self)
  Event.RegisterEventWithContext(ModuleId.CORPS, gmodule.notifyId.Corps.MemberModelChange, CorpsManagePanel.OnMemberModelChange, self)
  Event.RegisterEventWithContext(ModuleId.CORPS, gmodule.notifyId.Corps.CorpsLeaderChange, CorpsManagePanel.OnCorpsLeaderChange, self)
  Event.RegisterEventWithContext(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Apply_SUCCESS, CorpsManagePanel.OnCrossBattleChange, self)
  Event.RegisterEventWithContext(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Cancel_Apply_SUCCESS, CorpsManagePanel.OnCrossBattleChange, self)
  self:UpdateMemberList(true)
  self:UpdateBtn()
  self.updateTimer = GameUtil.AddGlobalTimer(0, false, function()
    if self.uiModels then
      for k, v in pairs(self.uiModels) do
        if not v.isnil then
          v:Invalidate(true)
        end
      end
    end
    if self.models then
      for k, v in pairs(self.models) do
        if not v:IsPlaying(ActionName.Stand) then
          v:Play(ActionName.Stand)
        end
      end
    end
  end)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CORPS, gmodule.notifyId.Corps.CorpsChange, CorpsManagePanel.OnCorpsChange)
  Event.UnregisterEvent(ModuleId.CORPS, gmodule.notifyId.Corps.MemberChange, CorpsManagePanel.OnMemberChange)
  Event.UnregisterEvent(ModuleId.CORPS, gmodule.notifyId.Corps.MemberOnlineChange, CorpsManagePanel.OnMemberOnlineChange)
  Event.UnregisterEvent(ModuleId.CORPS, gmodule.notifyId.Corps.MemberInfoChange, CorpsManagePanel.OnMemberInfoChange)
  Event.UnregisterEvent(ModuleId.CORPS, gmodule.notifyId.Corps.MemberModelChange, CorpsManagePanel.OnMemberModelChange)
  Event.UnregisterEvent(ModuleId.CORPS, gmodule.notifyId.Corps.CorpsLeaderChange, CorpsManagePanel.OnCorpsLeaderChange)
  Event.UnregisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Apply_SUCCESS, CorpsManagePanel.OnCrossBattleChange)
  Event.UnregisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Cancel_Apply_SUCCESS, CorpsManagePanel.OnCrossBattleChange)
  self:ClearModels()
  self.selectRoleId = nil
  self.members = nil
  self.uiModels = nil
  GameUtil.RemoveGlobalTimer(self.updateTimer)
  self.updateTimer = 0
end
def.method().ClearModels = function(self)
  if self.models then
    for k, v in pairs(self.models) do
      v:Destroy()
    end
  end
  self.models = nil
end
def.method("table").OnCrossBattleChange = function(self, param)
  self:UpdateMemberList(false)
end
def.method("table").OnCorpsChange = function(self, param)
  self:DestroyPanel()
end
def.method("table").OnMemberChange = function(self, param)
  self:ClearModels()
  self:UpdateMemberList(true)
  for k, v in ipairs(self.members) do
    if self.selectRoleId == v.roleId then
      return
    end
  end
  self.selectRoleId = nil
end
def.method("table").OnMemberOnlineChange = function(self, param)
  self:UpdateMemberList(false)
end
def.method("table").OnMemberInfoChange = function(self, param)
  local roleId = param.roleId
  local index = self:GetMemberIndex(roleId)
  local memberInfo = CorpsModule.Instance():GetData():GetMemberInfoByRoleId(roleId)
  if index > 0 and memberInfo then
    self.members[index] = memberInfo
    local uiGo = self.m_panel:FindDirect("Group_Team/ScrollList/List/Group_Mate_" .. index)
    self:FillMemberBaseInfo(uiGo, memberInfo, index)
  end
end
def.method("table").OnMemberModelChange = function(self, param)
  local roleId = param.roleId
  local index = self:GetMemberIndex(roleId)
  local memberInfo = CorpsModule.Instance():GetData():GetMemberInfoByRoleId(roleId)
  warn("OnMemberModelChange", index, roleId, memberInfo)
  if index > 0 and memberInfo then
    self.members[index] = memberInfo
    local uiGo = self.m_panel:FindDirect("Group_Team/ScrollList/List/Group_Mate_" .. index)
    self:FillMemberModelInfo(uiGo, memberInfo, index, true)
  end
end
def.method("table").OnCorpsLeaderChange = function(self, param)
  self:UpdateMemberList(false)
  self:UpdateBtn()
end
def.method("userdata", "=>", "number").GetMemberIndex = function(self, roleId)
  if self.members then
    for k, v in ipairs(self.members) do
      if v.roleId == roleId then
        return k
      end
    end
    return 0
  else
    return 0
  end
end
def.method("boolean").UpdateMemberList = function(self, deleteModel)
  self.members = CorpsModule.Instance():GetMembersData() or {}
  local scroll = self.m_panel:FindDirect("Group_Team/ScrollList")
  local list = scroll:FindDirect("List")
  local listCmp = list:GetComponent("UIList")
  local count = #self.members
  if #self.members < constant.CorpsConsts.CAPACITY then
    count = count + 1
  end
  listCmp:set_itemCount(count)
  listCmp:Resize()
  self.uiModels = {}
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiModel = items[i]:FindDirect(string.format("Group_Model_%d/Model_%d", i, i)):GetComponent("UIModel")
    table.insert(self.uiModels, uiModel)
    if i <= #self.members then
      local uiGo = items[i]
      local memberInfo = self.members[i]
      self:FillMemberInfo(uiGo, memberInfo, i, deleteModel)
      self.m_msgHandler:Touch(uiGo)
    else
      local uiGo = items[i]
      self:FillAdd(uiGo, i)
      self.m_msgHandler:Touch(uiGo)
    end
  end
end
def.method("userdata", "table", "number", "boolean").FillMemberInfo = function(self, uiGo, memberInfo, index, deleteModel)
  uiGo:FindDirect(string.format("Group_Add_%d", index)):SetActive(false)
  uiGo:FindDirect(string.format("Group_Model_%d", index)):SetActive(true)
  self:FillMemberBaseInfo(uiGo, memberInfo, index)
  self:FillMemberModelInfo(uiGo, memberInfo, index, deleteModel)
end
def.method("userdata", "table", "number").FillMemberBaseInfo = function(self, uiGo, memberInfo, index)
  local bg = uiGo:FindDirect(string.format("Img_Bg1_%d", index))
  if self.selectRoleId == memberInfo.roleId then
    bg:GetComponent("UISprite"):set_spriteName("Img_BgTeamS")
  else
    bg:GetComponent("UISprite"):set_spriteName("Img_BgTeamModel")
  end
  local Group_Model = uiGo:FindDirect(string.format("Group_Model_%d", index))
  uiGo:FindDirect(string.format("Group_Add_%d", index)):SetActive(false)
  local name = Group_Model:FindDirect(string.format("Label_Name_%d", index))
  name:GetComponent("UILabel"):set_text(memberInfo.name)
  local camp = Group_Model:FindDirect(string.format("Img_School_%d", index))
  camp:GetComponent("UISprite"):set_spriteName(GUIUtils.GetOccupationSmallIcon(memberInfo.occupationId))
  local genderSpr = Group_Model:FindDirect(string.format("Img_Sex_%d", index))
  genderSpr:GetComponent("UISprite"):set_spriteName(GUIUtils.GetGenderSprite(memberInfo.gender))
  local lv = Group_Model:FindDirect(string.format("Label_Lv_%d", index))
  lv:GetComponent("UILabel"):set_text(tostring(memberInfo.level))
  local mfv = Group_Model:FindDirect(string.format("Label_MFV_%d", index))
  mfv:GetComponent("UILabel"):set_text(tostring(memberInfo.mfv))
  if memberInfo.duty == CorpsDuty.CAPTAIN then
    Group_Model:FindDirect(string.format("Img_Leader_%d", index)):SetActive(true)
  else
    Group_Model:FindDirect(string.format("Img_Leader_%d", index)):SetActive(false)
  end
  local offlineSign = Group_Model:FindDirect(string.format("Img_LiXian_%d", index))
  if memberInfo.offlineTime > 0 then
    offlineSign:SetActive(true)
  else
    offlineSign:SetActive(false)
  end
  local apply = CrossBattleInterface.Instance():isApplyCrossBattle() and CrossBattleInterface.Instance():getCurCrossBattleStage() == CrossBattleActivityStage.STAGE_REGISTER
  local competitionSign = uiGo:FindDirect(string.format("Img_Sign_%d", index))
  competitionSign:SetActive(apply)
end
def.method("userdata", "table", "number", "boolean").FillMemberModelInfo = function(self, uiGo, memberInfo, index, deleteModel)
  if self.models == nil then
    self.models = {}
  end
  if deleteModel and self.models[memberInfo.roleId:tostring()] then
    local model = self.models[memberInfo.roleId:tostring()]
    model:Destroy()
    self.models[memberInfo.roleId:tostring()] = nil
  end
  local uiModel = uiGo:FindDirect(string.format("Group_Model_%d/Model_%d", index, index)):GetComponent("UIModel")
  local modelInfo = memberInfo.model
  local model = self.models[memberInfo.roleId:tostring()]
  local function setModel()
    if self.m_panel == nil or self.m_panel.isnil or uiModel.isnil then
      model:Destroy()
      model = nil
      return
    end
    model:SetAnimCullingType(0)
    uiModel.modelGameObject = model.m_model
    if uiModel.mCanOverflow ~= nil then
      local camera = uiModel:get_modelCamera()
      camera:set_orthographic(true)
    end
    if 0 < memberInfo.offlineTime then
      model:SetAlpha(0.55)
    else
      model:CloseAlpha()
    end
    GameUtil.AddGlobalTimer(0.1, true, function()
      model:Play(ActionName.Stand)
    end)
  end
  if not model or model.m_status == ModelStatus.DESTROY or model.m_status == ModelStatus.NONE then
    model = ECUIModel.new(modelInfo.modelid)
    self.models[memberInfo.roleId:tostring()] = model
    model:AddOnLoadCallback("corps", setModel)
    LoadModel(model, modelInfo, 0, 0, 180, false, false)
  elseif model:IsInLoading() then
    model:AddOnLoadCallback("corps", setModel)
  else
    setModel()
  end
end
def.method("userdata", "number").FillAdd = function(self, uiGo, index)
  local bg = uiGo:FindDirect(string.format("Img_Bg1_%d", index))
  bg:GetComponent("UISprite"):set_spriteName("Img_BgTeamModel")
  uiGo:FindDirect(string.format("Group_Add_%d", index)):SetActive(true)
  uiGo:FindDirect(string.format("Group_Model_%d", index)):SetActive(false)
  local competitionSign = uiGo:FindDirect(string.format("Img_Sign_%d", index))
  competitionSign:SetActive(false)
end
def.method("number").SelectMember = function(self, index)
  local memberInfo = self.members and self.members[index]
  if memberInfo then
    if self.selectRoleId ~= memberInfo.roleId then
      self.selectRoleId = memberInfo.roleId
      self:UpdateSelect()
    end
  else
    local roles = require("Main.friend.FriendModule").Instance():GetFriends()
    local friendIds = {}
    for i = 1, #roles do
      local role = roles[i]
      table.insert(friendIds, role.roleId)
    end
    CorpsModule.Instance():RequestPlayersCorpsInfo(friendIds, function(infos)
      require("Main.Corps.ui.CorpsInvite").ShowInvite(function(roleId, lv, occupationId, online)
        return lv >= constant.CorpsConsts.MIN_LEVEL and online and not CorpsModule.Instance():IsInMyCorps(roleId) and not infos[roleId:tostring()]
      end, function(roleId, lv)
        CorpsModule.Instance():InviteToCorps(roleId, lv)
      end)
    end)
  end
end
def.method("number", "table").ClickMember = function(self, index, pos)
  local memberInfo = self.members and self.members[index]
  if memberInfo then
    if memberInfo.roleId == GetMyRoleID() then
      return
    end
    do
      local btns = {}
      local callbacks = {}
      table.insert(btns, {
        name = textRes.Corps[77]
      })
      table.insert(callbacks, function()
        local ChatModule = require("Main.Chat.ChatModule")
        ChatModule.Instance():StartPrivateChat3(memberInfo.roleId, memberInfo.name, memberInfo.level, memberInfo.occupationId, memberInfo.gender, memberInfo.avatarId, memberInfo.avatarFrameId)
      end)
      local TeamData = require("Main.Team.TeamData")
      if not TeamData.Instance():HasTeam() or not TeamData.Instance():IsTeamMember(memberInfo.roleId) then
        table.insert(btns, {
          name = textRes.Corps[79]
        })
        table.insert(callbacks, function()
          gmodule.moduleMgr:GetModule(ModuleId.TEAM):TeamInvite(memberInfo.roleId)
        end)
      end
      local FriendModule = require("Main.friend.FriendModule")
      local isFriend = FriendModule.Instance():IsFriend(memberInfo.roleId)
      if not isFriend then
        table.insert(btns, {
          name = textRes.Corps[78]
        })
        table.insert(callbacks, function()
          FriendModule.AddFriendOrDeleteFriend(memberInfo.roleId, memberInfo.name)
        end)
      end
      require("GUI.ButtonGroupPanel").ShowPanelWithTitle(btns, memberInfo.name, pos, function(index)
        local func = callbacks[index]
        if func then
          func()
        end
      end)
    end
  end
end
def.method().UpdateSelect = function(self)
  local scroll = self.m_panel:FindDirect("Group_Team/ScrollList")
  local list = scroll:FindDirect("List")
  local listCmp = list:GetComponent("UIList")
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local memberInfo = self.members[i]
    local bg = uiGo:FindDirect(string.format("Img_Bg1_%d", i))
    if memberInfo and memberInfo.roleId == self.selectRoleId then
      bg:GetComponent("UISprite"):set_spriteName("Img_BgTeamS")
    else
      bg:GetComponent("UISprite"):set_spriteName("Img_BgTeamModel")
    end
  end
end
def.method().UpdateBtn = function(self)
  local isLeader = CorpsModule.Instance():GetData():IsLeader(GetMyRoleID())
  local Btn_Change = self.m_panel:FindDirect("Group_Btn/Btn_Change")
  local Btn_Kick = self.m_panel:FindDirect("Group_Btn/Btn_Kick")
  local Btn_Exit = self.m_panel:FindDirect("Group_Btn/Btn_Exit")
  if isLeader then
    Btn_Change:SetActive(true)
    Btn_Kick:SetActive(true)
    Btn_Exit:SetActive(false)
  else
    Btn_Change:SetActive(false)
    Btn_Kick:SetActive(false)
    Btn_Exit:SetActive(true)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Edit" then
    local corpsData = CorpsModule.Instance():GetData()
    require("Main.Corps.ui.ChangeCorpsInfo").ShowChange(corpsData:GetName(), corpsData:GetDeclaration(), corpsData:GetBadgeId(), corpsData:IsLeader(GetMyRoleID()))
  elseif id == "Btn_History" then
    CorpsModule.Instance():ShowMyCorpsHistory()
  elseif id == "Btn_Change" then
    if self.selectRoleId then
      CorpsModule.Instance():ChangeCorpsLeader(self.selectRoleId)
    else
      Toast(textRes.Corps[52])
    end
  elseif id == "Btn_Kick" then
    if self.selectRoleId then
      CorpsModule.Instance():FireMember(self.selectRoleId)
    else
      Toast(textRes.Corps[53])
    end
  elseif id == "Btn_Exit" then
    require("Main.Corps.CorpsModule").Instance():LeaveCorps()
  elseif string.sub(id, 1, 8) == "Img_Bg1_" then
    local index = tonumber(string.sub(id, 9))
    if index then
      self:SelectMember(index)
      self:ClickMember(index, {
        auto = false,
        x = 0,
        y = 0
      })
    end
  end
end
return CorpsManagePanel.Commit()
