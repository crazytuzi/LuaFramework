local ItemModule = require("Main.Item.ItemModule")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local DungeonModule = require("Main.Dungeon.DungeonModule")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local EC = require("Types.Vector3")
local ItemUtils = require("Main.Item.ItemUtils")
local FeijianType = require("consts.mzm.gsp.feijian.confbean.FeiJianType")
local AircraftData = require("Main.Aircraft.data.AircraftData")
local ModuleBase = require("Main.module.ModuleBase")
require("Main.module.ModuleId")
local Lplus = require("Lplus")
local ECPlayer = Lplus.ForwardDeclare("ECPlayer")
local FlyModule = Lplus.Extend(ModuleBase, "FlyModule")
local def = FlyModule.define
local _instance
local feijianCache = {}
def.const("string").FlyUpAnimation = "AirSwords_Up_c"
def.const("string").FlyIdleAnimation = "AirSwords_Idle_c"
def.const("string").FlyDownAnimation = "AirSwords_Down_c"
def.const("string").FlyIdleHugAnimation = "AirSwords_Idle01_c"
def.const("string").FlyTag = "FlySword"
def.const("string").YunCai = "YunCai"
def.const("number").FlyLimit = 4
def.const("number").AssDistance = 192
def.const("number").JumpInterval = 0.4
def.const("number").JumpDuration = 1.167
def.const("string").MASTERKEY = "MATER"
def.field("number").cloudTimer = 0
def.field("string").cloudOwner = ""
def.field("boolean").isInCoupleFly = false
def.field("table").confirmDlg = nil
def.static("=>", FlyModule).Instance = function()
  if _instance == nil then
    _instance = FlyModule()
    _instance.m_moduleId = ModuleId.FLY
  end
  return _instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.couple.SInviteRideRes", FlyModule.onInviteRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.couple.SReceiveRideInviteRes", FlyModule.onReveiveCoupleFly)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.couple.SCommonRideRes", FlyModule.onInviteSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.couple.SRefuseCommonRideRes", FlyModule.onInviteFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.couple.SLeaveRideRes", FlyModule.onLeave)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.couple.SCoupleNormalRet", FlyModule.onNormalRes)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, FlyModule.onEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, FlyModule.onLeaveFight)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, FlyModule.onEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, FlyModule.onLeaveWorld)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_FLY_CLICK, FlyModule.onFlyBtn)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  ModuleBase.Init(self)
  local defaultFeijianId = constant.CFeijianConsts.DEFAULT_FEIJIANID
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FEIJIAN_CFG, defaultFeijianId)
  if record then
    local tbl = {}
    tbl.modelId = record:GetIntValue("modelId")
    tbl.velocity = record:GetIntValue("velocity")
    tbl.effectId = record:GetIntValue("effectId")
    tbl.modelPath = GetModelPath(tbl.modelId)
    local effectCfg = GetEffectRes(tbl.effectId)
    tbl.effectPath = effectCfg and effectCfg.path or nil
    tbl.feijianType = record:GetIntValue("feijianType")
    feijianCache[0] = tbl
  else
    error("Fail to Init Fly Module, Default Feijian Id wrong!")
  end
end
def.override().OnReset = function(self)
  self.cloudTimer = 0
  self.cloudOwner = ""
  self.isInCoupleFly = false
  self.confirmDlg = nil
end
def.static("table").onInviteRes = function(p)
  local ret = p.ret
  local str = textRes.Fly.CoupleFlyRes[ret]
  if str then
    Toast(str)
  end
end
def.static("table").onNormalRes = function(p)
  local ret = p.ret
  local str = textRes.Fly.Error[ret]
  if str then
    Toast(str)
  end
end
def.static("table").onReveiveCoupleFly = function(p)
  local sessionId = p.sessionid
  local inviteRoleId = p.inviteRoleid
  local inviteRoleName = p.inviteRoleName
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  _instance.confirmDlg = CommonConfirmDlg.ShowConfirmCoundDown(textRes.Fly[2], string.format(textRes.Fly[1], inviteRoleName), "", "", 0, constant.CCoupleFlyConsts.defaultRefuseTime, function(select)
    local CRefuseOrAgreeRideInviteReq = require("netio.protocol.mzm.gsp.couple.CRefuseOrAgreeRideInviteReq")
    local choice = CRefuseOrAgreeRideInviteReq.REFUSE
    if select == 1 then
      choice = CRefuseOrAgreeRideInviteReq.AGREE
    elseif select == 0 then
      choice = CRefuseOrAgreeRideInviteReq.REFUSE
    end
    local reply = CRefuseOrAgreeRideInviteReq.new(sessionId, choice)
    gmodule.network.sendProtocol(reply)
    _instance.confirmDlg = nil
  end, nil)
end
def.static("table").onInviteSuccess = function(p)
  _instance.isInCoupleFly = true
  Event.DispatchEvent(ModuleId.FLY, gmodule.notifyId.Fly.Hero_Double_Fly_Change, nil)
end
def.static("table").onInviteFail = function(p)
  _instance.isInCoupleFly = false
  local refuseRoleId = p.refuseRoleid
  local refuseRoleName = p.refuseRoleName
  Toast(string.format(textRes.Fly[3], refuseRoleName))
end
def.static("table").onLeave = function(p)
  _instance.isInCoupleFly = false
  Event.DispatchEvent(ModuleId.FLY, gmodule.notifyId.Fly.Hero_Double_Fly_Change, nil)
  Toast(textRes.Fly[4])
end
def.method("userdata").InviteCoupleFly = function(self, otherRoleId)
  local invite = require("netio.protocol.mzm.gsp.couple.CInviteRideReq").new(otherRoleId)
  gmodule.network.sendProtocol(invite)
end
def.method().LeaveCoupleFly = function(self)
  local leave = require("netio.protocol.mzm.gsp.couple.CLeaveRideReq").new(otherRoleId)
  gmodule.network.sendProtocol(leave)
end
def.static("table", "table").onEnterWorld = function(p1, p2)
end
def.static("table", "table").onLeaveWorld = function(p1, p2)
  local ECGame = require("Main.ECGame")
  ECGame.Instance():ResetGroundLayer()
  local cloudCam = ECGame.Instance().m_cloudCam
  local yuncai1 = cloudCam:FindDirect(FlyModule.YunCai .. "1")
  cloudCam:SetActive(false)
  if yuncai1 ~= nil then
    yuncai1:SetActive(false)
  end
  ECGame.Instance().m_Fly3DCam:SetActive(true)
end
def.static("table", "table").onEnterFight = function(p, c)
  local ECGame = require("Main.ECGame")
  ECGame.Instance().m_Fly3DCam:SetActive(false)
end
def.static("table", "table").onLeaveFight = function(p, c)
  local ECGame = require("Main.ECGame")
  ECGame.Instance().m_Fly3DCam:SetActive(true)
end
def.static("table", "table").onFlyBtn = function(p1, p2)
  local myRole = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if myRole then
    if myRole:IsInState(RoleState.HUG) or myRole:IsInState(RoleState.BEHUG) then
      _instance:LeaveCoupleFly()
    elseif myRole:IsInState(RoleState.FLY) then
      gmodule.moduleMgr:GetModule(ModuleId.HERO):FlyDown()
    else
      gmodule.moduleMgr:GetModule(ModuleId.HERO):FlyUp()
    end
  end
end
def.method("=>", "boolean", "boolean").HasAirCraft = function(self)
  local aircraftCfg = require("Main.Aircraft.AircraftInterface").GetCurAircraftCfg()
  if aircraftCfg == nil then
    return false, false
  else
    return true, aircraftCfg.feijianType == FeijianType.BODY_SIT or aircraftCfg.feijianType == FeijianType.BODY_STAND
  end
end
def.method("=>", "number").CanFly = function(self)
  local onAircraft = require("Main.Aircraft.AircraftInterface").IsMountingAircraft()
  if not onAircraft then
    return 0
  end
  local HeroModule = require("Main.Hero.HeroModule")
  local role = HeroModule.Instance().myRole
  if role == nil or role.movePath == nil then
    return 0
  end
  if DungeonModule.Instance().State ~= DungeonModule.DungeonState.OUT then
    return 0
  end
  local flyState = role and role:IsInState(RoleState.FLY)
  if flyState then
    if role.flyState == ECPlayer.FlyState.Flight then
      return -1
    else
      return 1
    end
  else
    local curX = role.m_node2d.localPosition.x
    local curY = role.m_node2d.localPosition.y
    local lastPoint = role.movePath[#role.movePath]
    local tarX, tarY = lastPoint.x, lastPoint.y
    local speed = 420
    local distanceLimit = FlyModule.Instance():DistanceEnough(curX, curY, tarX, tarY, speed)
    if not distanceLimit then
      return 0
    else
      return 1
    end
  end
end
def.method().TryFly = function(self)
  if self:CanFly() == 1 then
    gmodule.moduleMgr:GetModule(ModuleId.HERO):ContinueFly()
  end
end
def.method().ToggleFly = function(self)
  if self:CanFly() == 1 then
    gmodule.moduleMgr:GetModule(ModuleId.HERO):ContinueFly()
  elseif self:CanFly() == -1 then
    gmodule.moduleMgr:GetModule(ModuleId.HERO):Land()
  end
end
def.method().Fly = function(self)
  gmodule.moduleMgr:GetModule(ModuleId.HERO):ContinueFly()
end
def.method("userdata", "number")._flow = function(self, cloud, k)
  local cloudCtrl = cloud:GetComponent("CloudController")
  cloudCtrl.k = k
end
def.method("number", "string").FlowCloud = function(self, factor, lock)
  local ECGame = require("Main.ECGame")
  if lock == "fly" and ECGame.Instance().m_isInFight then
    return
  end
  local cloudCam = ECGame.Instance().m_cloudCam
  local yuncai1 = cloudCam:FindDirect(FlyModule.YunCai .. "1")
  if yuncai1 == nil then
    return
  else
    if self.cloudTimer ~= 0 then
      GameUtil.RemoveGlobalTimer(self.cloudTimer)
      self.cloudTimer = 0
    end
    self.cloudOwner = lock
    if cloudCam:get_activeSelf() then
      cloudCam:SetActive(true)
      yuncai1:SetActive(true)
      AlphaGameObjectTween.TweenGameObjectAlpha(yuncai1, -1, 1, 1)
    else
      cloudCam:SetActive(true)
      yuncai1:SetActive(true)
      AlphaGameObjectTween.TweenGameObjectAlpha(yuncai1, 0, 1, 1)
    end
    self:_flow(yuncai1, factor)
  end
end
def.method("string").StopCloud = function(self, key)
  if key == self.cloudOwner or key == FlyModule.MASTERKEY then
    do
      local ECGame = require("Main.ECGame")
      local cloudCam = ECGame.Instance().m_cloudCam
      local yuncai1 = cloudCam:FindDirect(FlyModule.YunCai .. "1")
      if yuncai1 ~= nil then
        AlphaGameObjectTween.TweenGameObjectAlpha(yuncai1, 1, 0, 1)
        if self.cloudTimer ~= 0 then
          GameUtil.RemoveGlobalTimer(self.cloudTimer)
          self.cloudTimer = 0
        end
        self.cloudTimer = GameUtil.AddGlobalTimer(1, true, function()
          if self.cloudOwner == key then
            cloudCam:SetActive(false)
            yuncai1:SetActive(false)
          end
        end)
      end
    end
  else
    print("Cloud is not " .. key .. "'s , stop cloud fail")
  end
end
def.method("number", "number", "number", "number", "number", "=>", "boolean").DistanceEnough = function(self, curX, curY, tarX, tarY, speed)
  local disX = tarX - curX
  local disY = tarY - curY
  local needTime = math.sqrt(disX * disX + disY * disY) / speed
  return needTime >= FlyModule.FlyLimit
end
def.method("number", "=>", "table").GetFeijianCfgByFeijianId = function(self, id)
  local cfg = AircraftData.Instance():GetAircraftCfg(id)
  return cfg or AircraftData.Instance():GetAircraftCfg(constant.CFeijianConsts.DEFAULT_FEIJIANID)
end
def.method("number", "number", "table", "=>", "table").GetFlyStrategy = function(self, feijianItemId, colorId, role)
  local FeijianType = require("consts.mzm.gsp.feijian.confbean.FeiJianType")
  local feijianCfg = self:GetFeijianCfgByFeijianId(feijianItemId)
  local strategy
  if feijianCfg then
    if feijianCfg.feijianType == FeijianType.FOOT then
      strategy = require("Main.Fly.FlyStrategy.StandFly")()
    elseif feijianCfg.feijianType == FeijianType.RIDE then
      strategy = require("Main.Fly.FlyStrategy.SitFly")()
    elseif feijianCfg.feijianType == FeijianType.BODY_SIT then
      strategy = require("Main.Fly.FlyStrategy.TransformFly")()
    elseif feijianCfg.feijianType == FeijianType.BODY_STAND then
      strategy = require("Main.Fly.FlyStrategy.TransformFly")()
      strategy.behuggedAnimation = FlyModule.FlyIdleAnimation
    else
      strategy = require("Main.Fly.FlyStrategy.StrategyBase")()
    end
    if strategy then
      strategy:SetFeijianId(feijianItemId)
      strategy:SetColorId(colorId)
      strategy:SetCfg(feijianCfg)
      strategy:SetRole(role)
    end
  end
  return strategy
end
def.method("table", "table", "=>", "number").IsDistanceProper = function(self, a, b)
  local near = 128
  local far = 160
  local diffX, diffY = a.x - b.x, a.y - b.y
  local ab = math.sqrt(diffX * diffX + diffY * diffY)
  if far < ab then
    return 1
  elseif near > ab then
    return -1
  else
    return 0
  end
end
FlyModule.Commit()
return FlyModule
