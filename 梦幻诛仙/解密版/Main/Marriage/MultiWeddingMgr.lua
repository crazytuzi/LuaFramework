local Lplus = require("Lplus")
local MultiWeddingMgr = Lplus.Class("MultiWeddingMgr")
local def = MultiWeddingMgr.define
local MassWeddingConst = require("netio.protocol.mzm.gsp.masswedding.MassWeddingConst")
local MarriageUtils = require("Main.Marriage.MarriageUtils")
local instance
def.static("=>", MultiWeddingMgr).Instance = function()
  if instance == nil then
    instance = MultiWeddingMgr()
  end
  return instance
end
def.field("number").stage = -1
def.field("boolean").blessed = false
def.field("table").supported = nil
def.field("boolean").weddingEnd = false
def.field("table").couples = nil
def.field("table").callbacks = nil
def.field("function").requestRobCallback = nil
def.field("userdata").requestRobId = nil
def.field("number").timer = 0
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.masswedding.SAttendMassWeddingErrorRes", MultiWeddingMgr.OnSAttendMassWeddingErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.masswedding.SMassWeddingSignUpInfo", MultiWeddingMgr.OnSMassWeddingSignUpInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.masswedding.SMassWeddingSignUpRes", MultiWeddingMgr.OnSMassWeddingSignUpRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.masswedding.SMassWeddingReSignUpRes", MultiWeddingMgr.OnSMassWeddingReSignUpRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.masswedding.SMassWeddingSignUpErrorRes", MultiWeddingMgr.OnSMassWeddingSignUpErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.masswedding.SMassWeddingReSignUpErrorRes", MultiWeddingMgr.OnSMassWeddingReSignUpErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.masswedding.SSynMassWeddingCloseEarlier", MultiWeddingMgr.OnSSynMassWeddingCloseEarlier)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.masswedding.SSynMassWeddingBeginning", MultiWeddingMgr.OnSSynMassWeddingBeginning)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.masswedding.SSynMassWeddingStage", MultiWeddingMgr.OnSSynMassWeddingStage)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.masswedding.SSynMassWeddingStageChange", MultiWeddingMgr.OnSSynMassWeddingStageChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.masswedding.SMassWeddingCouplesRes", MultiWeddingMgr.OnSMassWeddingCouplesRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.masswedding.SSynMessWeddingCeremony", MultiWeddingMgr.OnSSynMessWeddingCeremony)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.masswedding.SBlessCoupleRes", MultiWeddingMgr.OnSBlessCoupleRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.masswedding.SSynBeginRandomLuckyOne", MultiWeddingMgr.OnSSynBeginRandomLuckyOne)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.masswedding.SRandomLuckyBlesserRes", MultiWeddingMgr.OnSRandomLuckyBlesserRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.masswedding.SRandomLuckyBlesserErrorRes", MultiWeddingMgr.OnSRandomLuckyBlesserErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.masswedding.SNotifyLuckyBlesser", MultiWeddingMgr.OnSNotifyLuckyBlesser)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.masswedding.SSynClientRedGift", MultiWeddingMgr.OnSSynClientRedGift)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.masswedding.SBridalChamberRes", MultiWeddingMgr.OnSBridalChamberRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.masswedding.SBridalChamberErrorRes", MultiWeddingMgr.OnSBridalChamberErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.masswedding.SBridalChamberInfoRes", MultiWeddingMgr.OnSBridalChamberInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.masswedding.SBrocastLuckyBlesserToAll", MultiWeddingMgr.OnSBrocastLuckyBlesserToAll)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.masswedding.SMassWeddingPlayEndRes", MultiWeddingMgr.OnSMassWeddingPlayEndRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.masswedding.SSynMassWeddingNotifyMapRedGift", MultiWeddingMgr.OnSSynMassWeddingNotifyMapRedGift)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.masswedding.SMassWeddingRedGiftPreciousItemBrd", MultiWeddingMgr.OnSMassWeddingRedGiftPreciousItemBrd)
  Event.RegisterEventWithContext(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, MultiWeddingMgr.onActivityTodo, self)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, MultiWeddingMgr.OnActivityStart)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.BtnClickInChat, MultiWeddingMgr.OnClickChatBtn)
  Event.RegisterEventWithContext(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, MultiWeddingMgr.OnNpcService, self)
  Event.RegisterEventWithContext(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, MultiWeddingMgr.OnMapChange, self)
  self.callbacks = {}
end
def.method().Reset = function(self)
  self.stage = -1
  self.blessed = false
  self.supported = nil
  self.weddingEnd = false
  self.couples = nil
  self.callbacks = {}
  self.requestRobCallback = nil
  self.requestRobId = nil
  GameUtil.RemoveGlobalTimer(self.timer)
  self.timer = 0
end
def.method().GoToWeddingMap = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MASSWEDDING) then
    Toast(textRes.Marriage[113])
    return
  end
  local CAttendMassWedding = require("netio.protocol.mzm.gsp.masswedding.CAttendMassWedding").new()
  gmodule.network.sendProtocol(CAttendMassWedding)
end
def.method().LeaveWeddingMap = function(self)
  local CLeaveMassWedding = require("netio.protocol.mzm.gsp.masswedding.CLeaveMassWedding").new()
  gmodule.network.sendProtocol(CLeaveMassWedding)
end
def.method().RequestNewRank = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MASSWEDDING) then
    Toast(textRes.Marriage[113])
    return
  end
  local CMassWeddingSignUpInfo = require("netio.protocol.mzm.gsp.masswedding.CMassWeddingSignUpInfo").new()
  gmodule.network.sendProtocol(CMassWeddingSignUpInfo)
end
def.method("number").SignUp = function(self, price)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MASSWEDDING) then
    Toast(textRes.Marriage[113])
    return
  end
  if self.stage > MassWeddingConst.STAGE_SIGN_UP then
    Toast(textRes.Marriage[80])
    return
  end
  if price <= 0 then
    return
  end
  if not require("Main.Marriage.MarriageModule").Instance():CheckCanSignUpWedding() then
    return
  end
  local ItemModule = require("Main.Item.ItemModule")
  local gold = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
  local goldNum = gold:ToNumber()
  if price > goldNum then
    Toast(textRes.Marriage[104])
    return
  end
  local CMassWeddingSignUpReq = require("netio.protocol.mzm.gsp.masswedding.CMassWeddingSignUpReq").new(price)
  gmodule.network.sendProtocol(CMassWeddingSignUpReq)
end
def.method("number").AddPrice = function(self, price)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MASSWEDDING) then
    Toast(textRes.Marriage[113])
    return
  end
  if self.stage > MassWeddingConst.STAGE_SIGN_UP then
    Toast(textRes.Marriage[80])
    return
  end
  if price <= 0 then
    return
  end
  if not require("Main.Marriage.MarriageModule").Instance():CheckCanSignUpWedding() then
    return
  end
  local ItemModule = require("Main.Item.ItemModule")
  local gold = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
  local goldNum = gold:ToNumber()
  if price > goldNum then
    Toast(textRes.Marriage[104])
    return
  end
  local CMassWeddingReSignUpReq = require("netio.protocol.mzm.gsp.masswedding.CMassWeddingReSignUpReq").new(price)
  gmodule.network.sendProtocol(CMassWeddingReSignUpReq)
end
def.method("function").RequestAllCouples = function(self, cb)
  if cb == nil then
    return
  end
  if self.couples == nil then
    if self.stage <= MassWeddingConst.STAGE_SIGN_UP then
      cb(nil)
    else
      table.insert(self.callbacks, cb)
      local CMassWeddingCouplesReq = require("netio.protocol.mzm.gsp.masswedding.CMassWeddingCouplesReq").new()
      gmodule.network.sendProtocol(CMassWeddingCouplesReq)
    end
  else
    cb(self.couples)
  end
end
def.method("userdata", "string").SendBless = function(self, roleId, cnt)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MASSWEDDING) then
    Toast(textRes.Marriage[113])
    return
  end
  local blessContent = require("netio.Octets").rawFromString(cnt)
  local CBlessCoupleReq = require("netio.protocol.mzm.gsp.masswedding.CBlessCoupleReq").new(roleId, blessContent)
  gmodule.network.sendProtocol(CBlessCoupleReq)
end
def.method().DrawLuckyGuy = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MASSWEDDING) then
    Toast(textRes.Marriage[113])
    return
  end
  local CRandomLuckyBlesserReq = require("netio.protocol.mzm.gsp.masswedding.CRandomLuckyBlesserReq").new()
  gmodule.network.sendProtocol(CRandomLuckyBlesserReq)
end
def.method("number").GetNpcRedBag = function(self, cfgId)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MASSWEDDING) then
    Toast(textRes.Marriage[113])
    return
  end
  local CClientTakeRedGift = require("netio.protocol.mzm.gsp.masswedding.CClientTakeRedGift").new(cfgId)
  gmodule.network.sendProtocol(CClientTakeRedGift)
end
def.method("userdata").RobWomen = function(self, roleId)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MASSWEDDING) then
    Toast(textRes.Marriage[113])
    return
  end
  if self.stage > MassWeddingConst.STAGE_ROB_MARRIAGE then
    Toast(textRes.Marriage[116])
    return
  end
  local CBridalChamberReq = require("netio.protocol.mzm.gsp.masswedding.CBridalChamberReq").new(roleId)
  gmodule.network.sendProtocol(CBridalChamberReq)
end
def.method("userdata", "function").RequestRobNum = function(self, roleId, callback)
  self.requestRobId = roleId
  self.requestRobCallback = callback
  local CBridalChamberInfoReq = require("netio.protocol.mzm.gsp.masswedding.CBridalChamberInfoReq").new(roleId)
  gmodule.network.sendProtocol(CBridalChamberInfoReq)
end
def.method().ShowSendBless = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MASSWEDDING) then
    Toast(textRes.Marriage[113])
    return
  end
  self:RequestAllCouples(function(cps)
    if cps == nil then
      return
    end
    local title = textRes.Marriage[92]
    local desc = textRes.Marriage[93]
    local prefix = textRes.Marriage[94]
    local names = {}
    for k, v in ipairs(cps) do
      local name = string.format(textRes.Marriage[91], v.name1, v.name2)
      table.insert(names, name)
    end
    local presets = MarriageUtils.GetAllBless()
    require("Main.Marriage.ui.BlessDlg").ShowBlessDlg(title, desc, prefix, names, presets, function(cnt, sel)
      local cp = cps[sel]
      if cp and cnt then
        self:SendBless(cp.id1, cnt)
      end
    end)
  end)
end
def.method().ShowSelectRobWomen = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MASSWEDDING) then
    Toast(textRes.Marriage[113])
    return
  end
  self:RequestAllCouples(function(cps)
    if cps == nil then
      return
    end
    local cpsInfos = {}
    for k, v in ipairs(cps) do
      local info = {}
      info.man = v.name1
      info.women = v.name2
      info.id = k
      table.insert(cpsInfos, info)
    end
    require("Main.Marriage.ui.SelectCoupleDlg").ShowSelectCoupleDlg(cpsInfos, function(id)
      local info = cps[id]
      if info then
        self:ShowRobWomen(info.name1, info.name2, info.id1, info.id2)
      end
    end)
  end)
end
def.method().ShowSignUp = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MASSWEDDING) then
    Toast(textRes.Marriage[113])
    return
  end
  self:RequestNewRank()
end
def.method("string", "string", "userdata", "userdata").ShowRobWomen = function(self, name1, name2, roleId, roleId2)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MASSWEDDING) then
    Toast(textRes.Marriage[113])
    return
  end
  if self.stage == MassWeddingConst.STAGE_ROB_MARRIAGE then
    self:RequestRobNum(roleId, function(good, bad)
      local actStartTime = require("Main.activity.ActivityInterface").GetActivityBeginningTime(constant.CMassWeddingConsts.activityid)
      local endTime = actStartTime + (constant.CMassWeddingConsts.prepareMinute + constant.CMassWeddingConsts.marryMinute + constant.CMassWeddingConsts.robMarriageMinute) * 60
      require("Main.Marriage.ui.RobWomenDlg").Instance():ShowRobWomen(good, bad, endTime, name1, name2, textRes.Marriage[98], roleId, roleId2)
    end)
  else
    Toast(textRes.Marriage[116])
  end
end
def.method("userdata").CancelRobWomen = function(self, roleId)
  if roleId == nil then
    return
  end
  local CCloseBridalChamberInfoReq = require("netio.protocol.mzm.gsp.masswedding.CCloseBridalChamberInfoReq").new(roleId)
  gmodule.network.sendProtocol(CCloseBridalChamberInfoReq)
end
def.method("=>", "table").GetStepTable = function(self)
  local steps = {}
  local name0 = textRes.Marriage[107]
  local btn0 = self.stage > 0 and textRes.Marriage[109] or textRes.Marriage[108]
  local highLight0 = self.stage == MassWeddingConst.STAGE_SIGN_UP
  table.insert(steps, {
    name = name0,
    btn = btn0,
    id = 0,
    highLight = highLight0
  })
  local name1 = textRes.Marriage[66]
  local btn1 = self.blessed and textRes.Marriage[71] or textRes.Marriage[70]
  local highLight1 = self.stage > MassWeddingConst.STAGE_SIGN_UP and not self.blessed
  table.insert(steps, {
    name = name1,
    btn = btn1,
    id = 1,
    highLight = highLight1
  })
  local name2 = textRes.Marriage[67]
  local btn2 = textRes.Marriage[72]
  table.insert(steps, {
    name = name2,
    btn = btn2,
    id = 2,
    highLight = true
  })
  local name3 = textRes.Marriage[68]
  local btn3 = self.stage < MassWeddingConst.STAGE_ROB_MARRIAGE and textRes.Marriage[73] or self.stage > MassWeddingConst.STAGE_ROB_MARRIAGE and textRes.Marriage[74] or textRes.Marriage[72]
  local highLight3 = self.stage == MassWeddingConst.STAGE_ROB_MARRIAGE
  table.insert(steps, {
    name = name3,
    btn = btn3,
    id = 3,
    highLight = highLight3
  })
  local name4 = textRes.Marriage[69]
  local btn4 = self.stage < MassWeddingConst.STAGE_LOVE and textRes.Marriage[73] or textRes.Marriage[72]
  local highLight4 = self.stage == MassWeddingConst.STAGE_LOVE
  table.insert(steps, {
    name = name4,
    btn = btn4,
    id = 4,
    highLight = highLight4
  })
  return steps
end
def.method().UpdateStageUI = function(self)
  local steps = self:GetStepTable()
  local StepDlg = require("Main.Marriage.ui.StepDlg")
  if StepDlg.Instance():IsShow() then
    StepDlg.Instance():SetStep(steps)
  else
    local title = textRes.Marriage[65]
    StepDlg.Instance():ShowStepDlg(title, steps, constant.CMassWeddingConsts.massWeddingTips, MultiWeddingMgr.OnStepClick)
  end
end
def.method().SetWeddingTimer = function(self)
  if self.timer ~= 0 then
    GameUtil.RemoveGlobalTimer(self.timer)
    self.timer = 0
  end
  if self.stage < 1 then
    do
      local startTime = require("Main.activity.ActivityInterface").GetActivityBeginningTime(constant.CMassWeddingConsts.activityid)
      local marriageTime = startTime + constant.CMassWeddingConsts.prepareMinute * 60
      self.timer = GameUtil.AddGlobalTimer(1, false, function()
        local curTime = GetServerTime()
        local leftTime = marriageTime - curTime
        if leftTime > 0 then
          local minute = math.floor(leftTime / 60)
          local second = leftTime % 60
          local text
          if minute > 0 then
            text = string.format("%02d%s%02d%s", minute, textRes.Pitch[1], second, textRes.Pitch[2])
          else
            text = string.format("%02d%s", second, textRes.Pitch[2])
          end
          local desc = string.format(textRes.Marriage[111], text)
          require("GUI.ActivityAnnounce").Instance():SetDescText(desc)
        else
          GameUtil.RemoveGlobalTimer(self.timer)
          self.timer = 0
          require("GUI.ActivityAnnounce").Instance():SetDescText("")
        end
      end)
    end
  elseif self.stage == MassWeddingConst.STAGE_MARRY then
    if self.weddingEnd then
      do
        local startTime = require("Main.activity.ActivityInterface").GetActivityBeginningTime(constant.CMassWeddingConsts.activityid)
        local marriageTime = startTime + constant.CMassWeddingConsts.prepareMinute * 60 + constant.CMassWeddingConsts.marryMinute * 60
        self.timer = GameUtil.AddGlobalTimer(1, false, function()
          local curTime = GetServerTime()
          local leftTime = marriageTime - curTime
          if leftTime > 0 then
            local minute = math.floor(leftTime / 60)
            local second = leftTime % 60
            local text
            if minute > 0 then
              text = string.format("%02d%s%02d%s", minute, textRes.Pitch[1], second, textRes.Pitch[2])
            else
              text = string.format("%02d%s", second, textRes.Pitch[2])
            end
            local desc = string.format(textRes.Marriage[115], text)
            require("GUI.ActivityAnnounce").Instance():SetDescText(desc)
          else
            GameUtil.RemoveGlobalTimer(self.timer)
            self.timer = 0
            require("GUI.ActivityAnnounce").Instance():SetDescText("")
          end
        end)
      end
    end
  elseif self.stage == MassWeddingConst.STAGE_ROB_MARRIAGE then
    do
      local startTime = require("Main.activity.ActivityInterface").GetActivityBeginningTime(constant.CMassWeddingConsts.activityid)
      local marriageTime = startTime + constant.CMassWeddingConsts.prepareMinute * 60 + constant.CMassWeddingConsts.marryMinute * 60 + constant.CMassWeddingConsts.robMarriageMinute * 60
      self.timer = GameUtil.AddGlobalTimer(1, false, function()
        local curTime = GetServerTime()
        local leftTime = marriageTime - curTime
        if leftTime > 0 then
          local minute = math.floor(leftTime / 60)
          local second = leftTime % 60
          local text
          if minute > 0 then
            text = string.format("%02d%s%02d%s", minute, textRes.Pitch[1], second, textRes.Pitch[2])
          else
            text = string.format("%02d%s", second, textRes.Pitch[2])
          end
          local desc = string.format(textRes.Marriage[127], text)
          require("GUI.ActivityAnnounce").Instance():SetDescText(desc)
        else
          GameUtil.RemoveGlobalTimer(self.timer)
          self.timer = 0
          require("GUI.ActivityAnnounce").Instance():SetDescText("")
        end
      end)
    end
  elseif self.stage == MassWeddingConst.STAGE_LOVE then
    do
      local endTime = require("Main.activity.ActivityInterface").GetActivityEndingTime(constant.CMassWeddingConsts.activityid)
      self.timer = GameUtil.AddGlobalTimer(1, false, function()
        local curTime = GetServerTime()
        local leftTime = endTime - curTime
        if leftTime > 0 then
          local minute = math.floor(leftTime / 60)
          local second = leftTime % 60
          local text
          if minute > 0 then
            text = string.format("%02d%s%02d%s", minute, textRes.Pitch[1], second, textRes.Pitch[2])
          else
            text = string.format("%02d%s", second, textRes.Pitch[2])
          end
          local desc = string.format(textRes.Marriage[120], text)
          require("GUI.ActivityAnnounce").Instance():SetDescText(desc)
        else
          GameUtil.RemoveGlobalTimer(self.timer)
          self.timer = 0
          require("GUI.ActivityAnnounce").Instance():SetDescText("")
        end
      end)
    end
  end
end
def.method("userdata", "=>", "boolean").HasSupperted = function(self, roleId)
  if self.supported then
    if self.supported[roleId:tostring()] then
      return true
    else
      return false
    end
  else
    return false
  end
end
def.method().LiPaoEffect = function(self)
  local pubroleModule = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  local npcs = MarriageUtils.GetAllLiPaoNPC()
  for k, v in ipairs(npcs) do
    pubroleModule:PlayEffectAtNpc(v, constant.CMassWeddingConsts.effectid, 90)
  end
end
def.static("table").OnSAttendMassWeddingErrorRes = function(p)
  local str = string.format(textRes.Marriage.MassWeddingAttendError[p.result], unpack(p.args))
  if str then
    Toast(str)
  end
end
def.static("table").OnSMassWeddingSignUpInfo = function(p)
  local tipId = constant.CMassWeddingConsts.describeTips
  local rank = p.rank
  local price = p.myPrice
  local rankList = {}
  for k, v in pairs(p.signUpInfos) do
    local info = {}
    info.man = v.roleName1
    info.women = v.roleName2
    info.price = v.price
    table.insert(rankList, info)
  end
  local startTime = require("Main.activity.ActivityInterface").GetActivityBeginningTime(constant.CMassWeddingConsts.activityid)
  local marriageTime = startTime + constant.CMassWeddingConsts.prepareMinute * 60
  require("Main.Marriage.ui.RegisterMultiWeddingPanel").Instance():ShowRegister(tipId, rank, price, marriageTime, rankList)
end
def.static("table").OnSMassWeddingSignUpRes = function(p)
  local str = string.format(textRes.Marriage[117], p.myPrice)
  Toast(str)
end
def.static("table").OnSMassWeddingReSignUpRes = function(p)
  local str = string.format(textRes.Marriage[118], p.addPrice)
  Toast(str)
end
def.static("table").OnSMassWeddingSignUpErrorRes = function(p)
  local str = string.format(textRes.Marriage.MassWeddingSignUpError[p.result], unpack(p.args))
  if str then
    Toast(str)
  end
end
def.static("table").OnSMassWeddingReSignUpErrorRes = function(p)
  local str = string.format(textRes.Marriage.MassWeddingReSignUpError[p.result], unpack(p.args))
  if str then
    Toast(str)
  end
end
def.static("table").OnSSynMassWeddingCloseEarlier = function(p)
  Toast(textRes.Marriage[87])
end
def.static("table").OnSSynMassWeddingBeginning = function(p)
  require("GUI.CommonConfirmDlg").ShowCerternConfirm(textRes.Marriage[90], textRes.Marriage[88], textRes.Marriage[89], nil, nil)
end
def.static("table").OnSSynMassWeddingStage = function(p)
  local self = instance
  self.stage = p.stage
  self.supported = {}
  for k, v in pairs(p.supportSet) do
    self.supported[v:tostring()] = true
  end
  self.blessed = p.blessed > 0
  self.weddingEnd = 0 < p.massweddingPlayEnd
  self:UpdateStageUI()
  self:SetWeddingTimer()
  if self.stage == MassWeddingConst.STAGE_MARRY then
    if not self.blessed then
      self:ShowSendBless()
    end
  elseif self.stage == MassWeddingConst.STAGE_ROB_MARRIAGE and (self.supported == nil or not next(self.supported)) then
    self:ShowSelectRobWomen()
  end
end
def.static("table").OnSSynMassWeddingStageChange = function(p)
  local self = instance
  self.stage = p.stage
  self:UpdateStageUI()
  if self.stage == MassWeddingConst.STAGE_MARRY then
    if not self.blessed then
      self:ShowSendBless()
    end
  elseif self.stage == MassWeddingConst.STAGE_ROB_MARRIAGE then
    if self.supported == nil or not next(self.supported) then
      self:ShowSelectRobWomen()
    end
    self:SetWeddingTimer()
  elseif self.stage == MassWeddingConst.STAGE_LOVE then
    self:SetWeddingTimer()
  end
end
def.static("table").OnSMassWeddingCouplesRes = function(p)
  local self = instance
  self.couples = {}
  for k, v in ipairs(p.blessCouples) do
    local id1 = v.roleinfo1.roleid
    local name1 = v.roleinfo1.roleName
    local id2 = v.roleinfo2.roleid
    local name2 = v.roleinfo2.roleName
    table.insert(self.couples, {
      id1 = id1,
      name1 = name1,
      id2 = id2,
      name2 = name2
    })
  end
  if #self.couples == 0 then
    self.couples = nil
  end
  local callbacks = self.callbacks
  self.callbacks = {}
  for k, v in ipairs(callbacks) do
    v(self.couples)
  end
end
def.static("table").OnSBlessCoupleRes = function(p)
  instance.blessed = true
  Toast(textRes.Marriage[96])
  instance:UpdateStageUI()
end
def.static("table").OnSSynMessWeddingCeremony = function(p)
  local triggerType = p.triggerType
  local name1 = p.coupleInfo.roleinfo1.roleName
  local name2 = p.coupleInfo.roleinfo2.roleName
  local text = string.format(textRes.Marriage.MassWeddingHanhua[triggerType], name1, name2)
  if text then
    local str = string.format(text, name1, name2)
    require("GUI.ActivityAnnounce").Instance():ScrollOne(str)
  end
  instance:LiPaoEffect()
end
def.static("table").OnSSynBeginRandomLuckyOne = function(p)
  require("Main.Marriage.ui.DrawLucky").ShowDrawLucky(false, "")
end
def.static("table").OnSRandomLuckyBlesserRes = function(p)
  local name = p.roleInfo.roleName
  require("Main.Marriage.ui.DrawLucky").ShowDrawLucky(true, name)
end
def.static("table").OnSRandomLuckyBlesserErrorRes = function(p)
  if p.result == p.NOT_HAS_BLESSED_ROLE then
    Toast(textRes.Marriage[106])
  elseif p.result == p.ALREADY_BLESSED then
    Toast(textRes.Marriage[121])
  end
end
def.static("table").OnSNotifyLuckyBlesser = function(p)
  local name = p.roleInfo.roleName
  local tip = string.format(textRes.Marriage[97], name)
end
def.static("table").OnSSynClientRedGift = function(p)
  local self = instance
  local redCfg = MarriageUtils.GetNpcRedBagCfg(p.redgiftCfgid)
  if redCfg then
    require("Main.Marriage.ui.NpcSendMoney").ShowNpcSendMoney(redCfg.iconId, constant.CMassWeddingConsts.autoGetRedGiftSec, redCfg.content, function()
      self:GetNpcRedBag(redCfg.id)
    end)
  end
end
def.static("table").OnSBridalChamberRes = function(p)
  local supportRoleId = p.roleid
  if instance.supported == nil then
    instance.supported = {}
  end
  instance.supported[supportRoleId:tostring()] = true
  Toast(textRes.Marriage[99])
  instance:UpdateStageUI()
end
def.static("table").OnSBridalChamberErrorRes = function(p)
  local str = string.format(textRes.Marriage.MassWeddingRobError[p.result], unpack(p.args))
  if str then
    Toast(str)
  end
end
def.static("table").OnSBridalChamberInfoRes = function(p)
  if p.roleid == instance.requestRobId then
    if instance.requestRobCallback then
      instance.requestRobCallback(p.groom, p.bride)
    end
    instance.requestRobId = nil
    instance.requestRobCallback = nil
  else
    require("Main.Marriage.ui.RobWomenDlg").Instance():SetRobWomenNum(p.groom, p.bride, p.roleid)
  end
end
def.static("table").OnSBrocastLuckyBlesserToAll = function(p)
  local operName = p.operRoleInfo.roleName
  local luckyName = p.luckyRoleInfo.roleName
  local str = string.format(textRes.Marriage[114], luckyName)
  require("GUI.ActivityAnnounce").Instance():ScrollOne(str)
end
def.static("table").OnSMassWeddingPlayEndRes = function(p)
  instance.weddingEnd = true
  instance:SetWeddingTimer()
end
def.static("table").OnSSynMassWeddingNotifyMapRedGift = function(p)
  instance:LiPaoEffect()
end
def.static("table").OnSMassWeddingRedGiftPreciousItemBrd = function(p)
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local ItemUtils = require("Main.Item.ItemUtils")
  local name = p.roleName
  local itemMap = p.item2Num
  local strTable = {}
  for k, v in pairs(itemMap) do
    local itemBase = ItemUtils.GetItemBase(k)
    table.insert(strTable, string.format("<font color=#%s>%s\195\151%d&nbsp;</font>", HtmlHelper.NameColor[itemBase.namecolor], itemBase.name, v))
  end
  local str = string.format(textRes.Marriage[129], name, table.concat(strTable, ","))
  require("GUI.AnnouncementTip").Announce(str)
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.method("table").onActivityTodo = function(self, param)
  local activityId = param[1]
  if activityId == constant.CMassWeddingConsts.activityid then
    self:GoToWeddingMap()
  end
end
def.method("table").OnNpcService = function(self, param)
  local serviceId = param[1]
  local npcId = param[2]
  if serviceId == constant.CMassWeddingConsts.signUpServiceid then
    self:ShowSignUp()
  end
end
def.method("table").OnMapChange = function(self, param)
  local mapId = param[1]
  local oldMapId = param[2]
  if mapId == constant.CMassWeddingConsts.mapid then
    Event.DispatchEvent(ModuleId.MARRIAGE, gmodule.notifyId.Marriage.EnterMassWedding, nil)
    require("GUI.ActivityAnnounce").Instance():Setup(textRes.Marriage[90])
    local CommonActivityPanel = require("GUI.CommonActivityPanel")
    CommonActivityPanel.Instance():ShowActivityPanel(false, true, nil, nil, function()
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      local tag = {id = self}
      CommonConfirmDlg.ShowConfirm(textRes.Marriage[100], textRes.Marriage[101], function(sel)
        if sel == 1 then
          local teamData = require("Main.Team.TeamData")
          if teamData.Instance():HasTeam() then
            if teamData.Instance():MeIsCaptain() then
              self:LeaveWeddingMap()
            elseif teamData.Instance():GetStatus() == require("netio.protocol.mzm.gsp.team.TeamMember").ST_TMP_LEAVE then
              self:LeaveWeddingMap()
            else
              Toast(textRes.Marriage[119])
            end
          else
            self:LeaveWeddingMap()
          end
        end
      end, nil)
    end, nil, false, CommonActivityPanel.ActivityType.WEDDING)
    if gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole then
      gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole:SetState(RoleState.WEDDING)
    end
    require("Main.Chat.ScreenBulletMgr").Instance():SetupBullet()
    gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):SetForceVisibleNum(75)
  elseif oldMapId == constant.CMassWeddingConsts.mapid and mapId ~= constant.CMassWeddingConsts.mapid then
    self:Reset()
    Event.DispatchEvent(ModuleId.MARRIAGE, gmodule.notifyId.Marriage.LeaveMassWedding, nil)
    require("GUI.ActivityAnnounce").Instance():Uninstall()
    local StepDlg = require("Main.Marriage.ui.StepDlg")
    StepDlg.Instance():CloseStepDlg()
    local CommonActivityPanel = require("GUI.CommonActivityPanel")
    CommonActivityPanel.Instance():HidePanel(CommonActivityPanel.ActivityType.WEDDING)
    if gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole then
      gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole:RemoveState(RoleState.WEDDING)
    end
    require("Main.Chat.ScreenBulletMgr").Instance():UninstallBullet()
    require("Main.Marriage.ui.RegisterMultiWeddingPanel").Instance():DestroyPanel()
    require("Main.Marriage.ui.BlessDlg").Instance():DestroyPanel()
    require("Main.Marriage.ui.SelectCoupleDlg").Instance():DestroyPanel()
    require("Main.Marriage.ui.RobWomenDlg").Instance():DestroyPanel()
    gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):SetForceVisibleNum(-1)
  end
end
def.static("table", "table").OnActivityStart = function(p1, p2)
  local activityId = p1 and p1[1] or 0
  if activityId == constant.CMassWeddingConsts.activityid then
    local ChatModule = require("Main.Chat.ChatModule")
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    ChatModule.Instance():SendNoteMsg(textRes.Marriage[128], ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.WORLD)
  end
end
def.static("table", "table").OnClickChatBtn = function(p1, p2)
  local btnName = p1 and p1.id or ""
  if btnName == "wedding" then
    instance:GoToWeddingMap()
  end
end
def.static("number").OnStepClick = function(step)
  local self = instance
  if self.stage >= 0 then
    if step == 0 then
      if self.stage > 0 then
        Toast(textRes.Marriage[110])
      else
        Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
          constant.CMassWeddingConsts.waiterNpc
        })
      end
    elseif step == 1 then
      if self.stage > MassWeddingConst.STAGE_SIGN_UP then
        if self.blessed then
          Toast(textRes.Marriage[75])
        else
          self:ShowSendBless()
        end
      else
        Toast(textRes.Marriage[77])
      end
    elseif step == 2 then
      local minute = math.ceil(constant.CMassWeddingConsts.redGiftIntervalSec / 60)
      Toast(string.format(textRes.Marriage[76], minute))
    elseif step == 3 then
      if self.stage == MassWeddingConst.STAGE_ROB_MARRIAGE then
        self:ShowSelectRobWomen()
      elseif self.stage < MassWeddingConst.STAGE_ROB_MARRIAGE then
        Toast(textRes.Marriage[77])
      else
        Toast(textRes.Marriage[78])
      end
    elseif step == 4 then
      Toast(textRes.Marriage[79])
    end
  else
    local StepDlg = require("Main.Marriage.ui.StepDlg")
    StepDlg.Instance():CloseStepDlg()
  end
end
return MultiWeddingMgr.Commit()
