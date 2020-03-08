local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgAction = Lplus.Extend(ECPanelBase, "DlgAction")
local def = DlgAction.define
local dlg
local PlayType = require("consts.mzm.gsp.expression.confbean.PlayType")
local Vector = require("Types.Vector")
local ROLE_SERVER_STATUS = require("netio.protocol.mzm.gsp.status.StatusEnum")
local MultiActionNode = require("Main.DoubleInteraction.ui.DoubleInteractionNode")
local NodeIds = {SingleAction = 1, MultiAction = 2}
local NodeDefines = {
  [NodeIds.SingleAction] = {
    tabName = "Tap_Single",
    rootName = "Group_Btn_Single"
  },
  [NodeIds.MultiAction] = {
    tabName = "Tap_Multi",
    rootName = "Group_Btn_Multi",
    node = MultiActionNode
  }
}
def.field("table").actionMap = nil
def.field("number").x = 0
def.field("number").y = 0
def.field("number").iCurNode = NodeIds.SingleAction
def.field("number").iLastOpenNode = NodeIds.SingleAction
def.field("number").loopTimer = 0
def.field("table").pos = nil
def.field("table").actionEffect = nil
def.static("=>", DlgAction).Instance = function()
  if dlg == nil then
    dlg = DlgAction()
    dlg.actionEffect = {}
    gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SExpressionPlayRes", DlgAction.OnRoleDoAction)
    gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SNotifyExpressionPlayByUseItem", DlgAction.OnSNotifyExpressionPlayByUseItem)
  end
  return dlg
end
def.method().ShowDlg = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_ACTION, 1)
  self:SetOutTouchDisappear()
end
def.method("table").ShowDlgAtPos = function(self, pos)
  self:ShowDlg()
  self:SetDlgPos(pos)
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  local bHideTabs = true
  for nodeId, nodeDef in pairs(NodeDefines) do
    if nodeId ~= NodeIds.SingleAction then
      if nodeDef.node.Instance():IsOpen() then
        bHideTabs = false
      else
        self.iLastOpenNode = NodeIds.SingleAction
      end
    end
  end
  if bHideTabs then
    for nodeId, nodeDef in pairs(NodeDefines) do
      local tab = self.m_panel:FindDirect("Img_Bg0/" .. nodeDef.tabName)
      tab:SetActive(false)
    end
  end
  self:UpdateDlgPos()
end
def.override().OnDestroy = function(self)
  self.pos = nil
  self.iLastOpenNode = self.iCurNode
  self.iCurNode = NodeIds.SingleAction
  MultiActionNode.Instance():OnHide()
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:ShowActions()
end
def.method("table").SetDlgPos = function(self, pos)
  self.pos = pos
  if self.m_panel then
    self:UpdateDlgPos()
  end
end
def.method().UpdateDlgPos = function(self)
  local pos = self.pos
  if pos == nil then
    return
  end
  local tipFrame = self.m_panel:FindDirect("Img_Bg0")
  local uiRect = tipFrame:GetComponent("UIRect")
  uiRect:SetAnchor(nil)
  if pos.auto then
    local tipWidth = tipFrame:GetComponent("UISprite"):get_width()
    local tipHeight = tipFrame:GetComponent("UISprite"):get_height()
    local MathHelper = require("Common.MathHelper")
    local computeTipsAutoPosition = MathHelper.ComputeTipsAutoPosition
    if pos.tipType == "y" then
      computeTipsAutoPosition = MathHelper.ComputeTipsAutoPositionY
    end
    local targetX, targetY = computeTipsAutoPosition(pos.sourceX, pos.sourceY, pos.sourceW, pos.sourceH, tipWidth, tipHeight, pos.prefer)
    tipFrame:set_localPosition(Vector.Vector3.new(targetX, targetY, 0))
  elseif pos then
    tipFrame.localPosition = Vector.Vector3.new(pos.x, pos.y, 0)
  end
end
def.method().ShowActions = function(self)
  local gridPanel = self.m_panel:FindDirect("Img_Bg0/Group_Btn_Single/Scroll View/Grid")
  local uiList = gridPanel:GetComponent("UIList")
  if self.actionMap == nil then
    self:GetAllActionCfg()
  end
  if self.actionMap.size == 0 then
    uiList.itemCount = 0
    uiList:Resize()
    return
  end
  uiList.itemCount = self.actionMap.size
  uiList:Resize()
  local i = 1
  for i = 1, self.actionMap.size do
    if self.actionMap[i] then
      local btn = gridPanel:FindDirect("Btn_Action_" .. i)
      btn:FindDirect("Label_" .. i):GetComponent("UILabel").text = self.actionMap[i].name
    end
  end
  for nodeId, nodeDef in pairs(NodeDefines) do
    local group = self.m_panel:FindDirect("Img_Bg0/" .. nodeDef.rootName)
    group:SetActive(nodeId == self.iCurNode)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
  self:SwithchTo(self.iLastOpenNode)
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if self.iCurNode == NodeIds.MultiAction and MultiActionNode.Instance():onClickObj(clickobj) then
    self:Hide()
    return
  end
  if id == "Tap_Single" then
    self:SwithchTo(NodeIds.SingleAction)
  elseif id == "Tap_Multi" then
    self:SwithchTo(NodeIds.MultiAction)
  elseif string.find(id, "Btn_Action_") then
    self:Hide()
    if require("Main.Fight.FightMgr").Instance().isInFight then
      Toast(textRes.Chat.Action[1])
      return
    end
    local me = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
    if _G.IsInServerStatus(me, ROLE_SERVER_STATUS.STATUS_BALL_BATTLE_IN_GAME_MAP) then
      Toast(textRes.activity[409])
      return
    end
    local pubMgr = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
    if me:IsInState(RoleState.ESCORT) or me:IsInState(RoleState.BEHUG) or me:IsInState(RoleState.HUG) or pubMgr:IsInWedding() then
      Toast(textRes.Chat.Action[2])
      return
    end
    if pubMgr:IsInFollowState(me.roleId) and me.movePath then
      return
    end
    local idx = tonumber(string.sub(id, string.len("Btn_Action_") + 1))
    self:PlayAction(idx)
  end
end
def.method("number").SwithchTo = function(self, nodeId)
  if nodeId ~= self.iCurNode then
    for kNodeId, nodeDef in pairs(NodeDefines) do
      local group = self.m_panel:FindDirect("Img_Bg0/" .. nodeDef.rootName)
      if kNodeId == nodeId then
        group:SetActive(true)
        self.m_panel:FindDirect("Img_Bg0/" .. nodeDef.tabName):GetComponent("UIToggle").value = true
      else
        self.m_panel:FindDirect("Img_Bg0/" .. nodeDef.tabName):GetComponent("UIToggle").value = false
        group:SetActive(false)
      end
    end
    if nodeId == NodeIds.SingleAction then
      MultiActionNode.Instance():OnHide()
    elseif nodeId == NodeIds.MultiAction then
      MultiActionNode.Instance():OnShow(self.m_panel)
    end
    self.iCurNode = nodeId
  end
end
def.method("number").PlayAction = function(self, actionId)
  if self.actionMap == nil then
    self:GetAllActionCfg()
  end
  if self.actionMap == nil then
    return
  end
  local action = self.actionMap[actionId]
  if action then
    gmodule.moduleMgr:GetModule(ModuleId.HERO):StopPatroling()
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.map.CExpressionPlayReq").new(action.id))
    self:PlayRoleAction(gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole, actionId)
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.PLAYED_ACTION, {action})
  end
end
def.method("=>", "table").GetAllActionCfg = function(self)
  local entries = DynamicData.GetTable("data/cfg/mzm.gsp.expression.confbean.CExpressionCfg.bny")
  DynamicDataTable.SetCache(entries, true)
  local size = DynamicDataTable.GetRecordsCount(entries)
  self.actionMap = {}
  self.actionMap.size = size
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, size - 1 do
    local action = {}
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    action.id = record:GetIntValue("actionId")
    action.actionName = record:GetStringValue("actionName")
    action.name = record:GetStringValue("showName")
    action.playType = record:GetIntValue("playType")
    action.effectId = record:GetIntValue("effectId")
    action.boneName = record:GetStringValue("boneName")
    action.hideWeapon = record:GetCharValue("hideWeapon") ~= 0
    self.actionMap[action.id] = action
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return self.actionMap
end
def.static("table").OnRoleDoAction = function(p)
  local role = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRole(p.roleid)
  if role == nil then
    return
  end
  dlg:PlayRoleAction(role, p.actionEnum)
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.MAP_ROLE_PLAY_SINGLE_ACTION, {
    roleId = p.roleid
  })
end
def.method("table", "number", "=>", "boolean").HasAction = function(self, role, actionId)
  if self.actionMap == nil then
    self:GetAllActionCfg()
  end
  local action = self.actionMap[actionId]
  if action == nil then
    return false
  end
  local action_name = action.actionName
  return role:HasAnimClip(action_name)
end
def.method("table", "number").PlayRoleAction = function(self, role, actionId)
  if self.actionMap == nil then
    self:GetAllActionCfg()
  end
  local action = self.actionMap[actionId]
  if action == nil then
    return
  end
  role.idleTime = -2
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  role:EndInteraction()
  if role == heroModule.myRole then
    heroModule:Stop()
  else
    role:Stop()
  end
  if role:IsOnMount() then
    role:LeaveMount()
  end
  self:Stop()
  self:StopActionEffect(role)
  role:PlayAnim(ActionName.Stand, nil)
  role:ShowWeapon(not action.hideWeapon)
  if action.playType == PlayType.NORMAL_AFTER_PLAY then
    role:SetStance()
    do
      local effpath
      if action.effectId > 0 then
        local effres = _G.GetEffectRes(action.effectId)
        if effres then
          effpath = effres.path
          role:StopChildEffect(effres.path)
          self.actionEffect[role.roleId:tostring()] = effres
          role:AddChildEffect(effres.path, BODY_PART.BONE, action.boneName, 0)
        end
      end
      role:PlayWithBackUp(action.actionName, function()
        if effpath then
          role:StopChildEffect(effpath)
        end
        if role:IsInState(RoleState.FLY) then
          role:ResetFly()
        else
          role:SetStance()
          role:ReturnMount()
        end
        role.idleTime = -1
        role:ShowWeapon(true)
        role:HideBackup()
      end)
    end
  elseif action.playType == PlayType.PAUSE_AFTER_PLAY then
    role:SetStance()
    do
      local effpath
      if action.effectId > 0 then
        local effres = _G.GetEffectRes(action.effectId)
        if effres then
          effpath = effres.path
          role:StopChildEffect(effres.path)
          self.actionEffect[role.roleId:tostring()] = effres
          role:AddChildEffect(effres.path, BODY_PART.BONE, action.boneName, 0)
        end
      end
      role:PlayWithBackUp(action.actionName, function()
        if effpath then
          role:StopChildEffect(effpath)
        end
        role.idleTime = -1
        role:ShowWeapon(true)
      end)
    end
  elseif action.playType == PlayType.CIRCLE then
    do
      local function LoopPlay()
        self.loopTimer = 0
        if role.movePathComp and role.movePathComp.enabled then
          return
        end
        if role:IsInState(RoleState.PASSENGER) then
          local master = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetPassengerMaster(role)
          if master and master.movePath and 0 < #master.movePath then
            return
          end
        end
        role:PlayAnim(ActionName.Stand, nil)
        role:PlayWithBackUp(action.actionName, function()
          local timerId = GameUtil.AddGlobalLateTimer(0.01, true, LoopPlay)
          if role == heroModule.myRole then
            self.loopTimer = timerId
          end
        end)
        if 0 < action.effectId then
          local effres = _G.GetEffectRes(action.effectId)
          if effres then
            role:StopChildEffect(effres.path)
            self.actionEffect[role.roleId:tostring()] = effres
            role:AddChildEffect(effres.path, BODY_PART.BONE, action.boneName, 0)
          end
        end
      end
      LoopPlay()
    end
  end
end
def.static("table").OnSNotifyExpressionPlayByUseItem = function(p)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PLAY_EXPRESSION_CFG, p.item_cfgid)
  if record then
    local action = record:GetIntValue("expressionAction")
    local tip = record:GetStringValue("tips")
    if action then
      local pubMgr = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
      local roles = pubMgr:GetRolesWithinPos({
        x = p.x,
        y = p.y
      })
      for k, v in pairs(roles) do
        if v and not v:IsMoving() and not v:IsInState(RoleState.HUG) and not v:IsInState(RoleState.BEHUG) then
          dlg:PlayRoleAction(v, action)
        end
      end
    end
    if tip then
      local ChatModule = require("Main.Chat.ChatModule")
      local ChatMsgData = require("Main.Chat.ChatMsgData")
      local msg = string.format(tip, p.rolename)
      ChatModule.Instance():SendNoteMsg(msg, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.CURRENT)
      if p.roleid:eq(gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()) then
        local itemBase = require("Main.Item.ItemUtils").GetItemBase(p.item_cfgid)
        if itemBase then
          Toast(string.format(textRes.Item[36], itemBase.name))
        end
      end
    end
  end
end
def.method().Stop = function(self)
  if self.loopTimer > 0 then
    GameUtil.RemoveGlobalTimer(self.loopTimer)
    self.loopTimer = 0
  end
end
def.method("table").StopActionEffect = function(self, role)
  if role == nil or role.roleId == nil then
    return
  end
  local eff = self.actionEffect and self.actionEffect[role.roleId:tostring()]
  if eff then
    role:StopChildEffect(eff.path)
    self.actionEffect[role.roleId:tostring()] = nil
  end
end
DlgAction.Commit()
return DlgAction
