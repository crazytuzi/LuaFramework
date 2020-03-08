local Lplus = require("Lplus")
local TeenMgr = Lplus.Class("TeenMgr")
local ChildrenDataMgr = require("Main.Children.ChildrenDataMgr")
local ItemModule = require("Main.Item.ItemModule")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local PropType = require("consts.mzm.gsp.children.confbean.InterestType")
local def = TeenMgr.define
local instance
def.static("=>", TeenMgr).Instance = function()
  if instance == nil then
    instance = TeenMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SChooseInterestSuccess", TeenMgr.OnSChooseInterestSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SChooseInterestFailed", TeenMgr.OnSChooseInterestFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SLearnCourseSuccess", TeenMgr.OnSLearnCourseSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SLearnCourseFailed", TeenMgr.OnSLearnCourseFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SyncCourseInfo", TeenMgr.OnSyncCourseInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SFinishCourseSuccess", TeenMgr.OnSFinishCourseSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SFinishCourseFailed", TeenMgr.OnSFinishCourseFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SEndCourseSuccess", TeenMgr.OnSEndCourseSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SEndCourseFailed", TeenMgr.OnSEndCourseFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SCancelCourseSuccess", TeenMgr.OnSCancelCourseSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SChildhoodToAdultSuccess", TeenMgr.OnSChildhoodToAdultSuccess)
  Event.RegisterEventWithContext(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, TeenMgr.OnNewDay, self)
end
def.method().Reset = function()
end
def.static("table").OnSChooseInterestSuccess = function(p)
  local dataMgr = ChildrenDataMgr.Instance()
  local teenData = dataMgr:GetChildById(p.childid)
  if teenData and teenData:IsTeen() then
    teenData:SetInterest(p.draw_lots_cfgid)
    Toast(string.format(textRes.Children[2011], teenData:GetName()))
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Interest_Update, {
      p.childid
    })
    local effectId = constant.CChildHoodConst.CHOOSE_EFFECT_ID
    if effectId > 0 then
      local effectCfg = GetEffectRes(effectId)
      if effectCfg then
        require("Fx.GUIFxMan").Instance():PlayLayer(effectCfg.path, "Interest", 0, 0, 1, 1, -1, false)
      end
    end
  end
end
def.static("table").OnSChooseInterestFailed = function(p)
  warn("OnSChooseInterestFailed", p.retcode)
  local tipStr = textRes.Children.ChooseInterestFailed[p.retcode]
  if tipStr then
    Toast(tipStr)
  end
end
def.static("table").OnSLearnCourseSuccess = function(p)
  local dataMgr = ChildrenDataMgr.Instance()
  local teenData = dataMgr:GetChildById(p.childid)
  if teenData and teenData:IsTeen() then
    teenData:SetCurCourse(p.course_info)
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Course_Update, {
      p.childid
    })
    local courseCfg = ChildrenUtils.GetCourseCfg(p.course_info.course_type)
    local childName = teenData:GetName()
    local tipStr = string.format(textRes.Children[2019], childName, courseCfg.name)
    Toast(tipStr)
  end
end
def.static("table").OnSLearnCourseFailed = function(p)
  warn("OnSLearnCourseFailed", p.retcode)
  local tipStr = textRes.Children.LearnCourseFailed[p.retcode]
  if tipStr then
    Toast(tipStr)
  end
end
def.static("table").OnSyncCourseInfo = function(p)
  local dataMgr = ChildrenDataMgr.Instance()
  local teenData = dataMgr:GetChildById(p.childid)
  if teenData and teenData:IsTeen() then
    teenData:AddCourseInfo(p.study_effect_info.course_type, p.study_effect_info.is_crit > 0)
    teenData:ClearCurCourse()
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Course_Update, {
      p.childid
    })
    TeenMgr.Instance():TellCourseDone(p.childid, p.study_effect_info.course_type, true)
  end
end
def.static("table").OnSFinishCourseSuccess = function(p)
  local dataMgr = ChildrenDataMgr.Instance()
  local teenData = dataMgr:GetChildById(p.childid)
  if teenData and teenData:IsTeen() then
    teenData:AddCourseInfo(p.study_effect_info.course_type, p.study_effect_info.is_crit > 0)
    teenData:ClearCurCourse()
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Course_Update, {
      p.childid
    })
    TeenMgr.Instance():TellCourseDone(p.childid, p.study_effect_info.course_type, false)
  end
end
def.static("table").OnSFinishCourseFailed = function(p)
  warn("OnSFinishCourseFailed", p.retcode)
  local tipStr = textRes.Children.FinishCourseFailed[p.retcode]
  if tipStr then
    Toast(tipStr)
  end
end
def.static("table").OnSEndCourseSuccess = function(p)
  local dataMgr = ChildrenDataMgr.Instance()
  local teenData = dataMgr:GetChildById(p.childid)
  if teenData and teenData:IsTeen() then
    teenData:AddCourseInfo(p.study_effect_info.course_type, p.study_effect_info.is_crit > 0)
    teenData:ClearCurCourse()
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Course_Update, {
      p.childid
    })
    TeenMgr.Instance():TellCourseDone(p.childid, p.study_effect_info.course_type, true)
  end
end
def.static("table").OnSEndCourseFailed = function(p)
  warn("OnSEndCourseFailed", p.retcode)
  local tipStr = textRes.Children.EndCourseFailed[p.retcode]
  if tipStr then
    Toast(tipStr)
  end
end
def.static("table").OnSCancelCourseSuccess = function(p)
  local dataMgr = ChildrenDataMgr.Instance()
  local teenData = dataMgr:GetChildById(p.childid)
  if teenData and teenData:IsTeen() then
    teenData:ClearCurCourse()
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Course_Update, {
      p.childid
    })
  end
end
def.static("table").OnSChildhoodToAdultSuccess = function(p)
  local childid = p.child_info.child_id
  local child = ChildrenDataMgr.Instance():GetChildById(childid)
  if child == nil then
    return
  end
  local childName = child:GetName()
  Toast(string.format(textRes.Children[2037], childName))
  ChildrenDataMgr.Instance():AddChild(childid, p.child_info)
  Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Teen_Youth, {
    p.child_info.child_id
  })
  local effectId = constant.CChildHoodConst.GROW_UP_EFFECT_ID
  if effectId > 0 then
    local effectCfg = GetEffectRes(effectId)
    if effectCfg then
      require("Fx.GUIFxMan").Instance():PlayLayer(effectCfg.path, "Interest", 0, 0, 1, 1, -1, false)
    end
  end
end
def.method("table").OnNewDay = function(self, param)
  local ChildPhase = require("consts.mzm.gsp.children.confbean.ChildPhase")
  local children = ChildrenDataMgr.Instance():GetChildrenByStatus(ChildPhase.CHILD)
  for k, v in ipairs(children) do
    v:SetTodayTimes(0)
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Course_Update, {
      v:GetId()
    })
  end
end
def.method("userdata", "number", "boolean").TellCourseDone = function(self, cid, courseType, sayHello)
  local teenData = ChildrenDataMgr.Instance():GetChildById(cid)
  local courseCfg = ChildrenUtils.GetCourseCfg(courseType)
  if teenData and courseCfg then
    local childName = teenData:GetName()
    local tipStr = string.format(textRes.Children[2020], childName, courseCfg.name)
    Toast(tipStr)
    if sayHello then
      require("Main.Children.ChildrenModule").Instance():ShowChildSayHello(cid, require("consts.mzm.gsp.children.confbean.ChildFamilyLoveTipsEnum").CHILD_STUDY_FINISH)
    end
  end
end
def.method("userdata").ChooseInterest = function(self, cid)
  if not require("Main.Children.ChildrenInterface").CheckChildhoodPhaseOpenAndToast() then
    return
  end
  local teenData = ChildrenDataMgr.Instance():GetChildById(cid)
  if teenData and teenData:IsTeen() then
    if teenData:GetInterest() > 0 then
      local CommonConfirm = require("GUI.CommonConfirmDlg")
      CommonConfirm.ShowConfirm(textRes.Children[2007], string.format(textRes.Children[2008], constant.CChildHoodConst.RESET_INTEREST_COST), function(selection, tag)
        if selection == 1 then
          local count = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
          if count < Int64.new(constant.CChildHoodConst.RESET_INTEREST_COST) then
            Toast(textRes.Children[2009])
            GoToBuyGold()
            return
          end
          gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.children.CChooseInterest").new(cid, teenData:GetInterest()))
        end
      end, nil)
    else
      local CommonConfirm = require("GUI.CommonConfirmDlg")
      CommonConfirm.ShowConfirm(textRes.Children[2007], textRes.Children[2010], function(selection, tag)
        if selection == 1 then
          gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.children.CChooseInterest").new(cid, teenData:GetInterest()))
        end
      end, nil)
    end
  end
end
def.method("userdata", "number", "=>", "boolean").JudgeLearnCourseLimit = function(self, cid, courseType)
  local teenData = ChildrenDataMgr.Instance():GetChildById(cid)
  if teenData then
    if teenData:GetInterest() <= 0 then
      Toast(textRes.Children[2034])
      return false
    end
    local curCourse = teenData:GetCurCourse()
    if curCourse then
      local courseCfg = ChildrenUtils.GetCourseCfg(curCourse.courseType)
      Toast(string.format(textRes.Children[2039], teenData:GetName(), courseCfg.name))
      return false
    end
    local todayTimes = teenData:GetTodayTimes()
    if todayTimes >= constant.CChildHoodConst.DAILY_NUM then
      Toast(string.format(textRes.Children[2021], teenData:GetName()))
      return false
    end
    local allTimes = teenData:GetTotalCourseNum()
    if allTimes >= constant.CChildHoodConst.TOTAL_NUM then
      Toast(string.format(textRes.Children[2022], teenData:GetName()))
      return false
    end
    local courseCfg = ChildrenUtils.GetCourseCfg(courseType)
    local allFull = true
    local props = teenData:GetCourseProps()
    for k, v in pairs(courseCfg.props) do
      local propCfg = ChildrenUtils.GetPropCfg(v.prop)
      if (props[v.prop] or 0) < propCfg.limit then
        allFull = false
      end
    end
    if allFull then
      Toast(string.format(textRes.Children[2023], courseCfg.name, teenData:GetName()))
      return false
    end
    return true
  end
  return false
end
def.method("userdata", "number").StudyCourse = function(self, cid, courseType)
  if not require("Main.Children.ChildrenInterface").CheckChildhoodPhaseOpenAndToast() then
    return
  end
  if self:JudgeLearnCourseLimit(cid, courseType) then
    require("Main.Children.ui.TeenCoursePanel").Instance():DestroyPanel()
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.children.CLearnCourse").new(cid, courseType))
  end
end
def.method("userdata", "number").BuyCourse = function(self, cid, courseType)
  if not require("Main.Children.ChildrenInterface").CheckChildhoodPhaseOpenAndToast() then
    return
  end
  if self:JudgeLearnCourseLimit(cid, courseType) then
    local ItemModule = require("Main.Item.ItemModule")
    local myYuanbao = ItemModule.Instance():GetAllYuanBao()
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.children.CFinishCourse").new(cid, courseType, myYuanbao))
  end
end
def.method("userdata").SpeedCourse = function(self, cid)
  if not require("Main.Children.ChildrenInterface").CheckChildhoodPhaseOpenAndToast() then
    return
  end
  local ItemModule = require("Main.Item.ItemModule")
  local myYuanbao = ItemModule.Instance():GetAllYuanBao()
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.children.CEndCourse").new(cid, myYuanbao))
end
def.method("userdata").CancelCourse = function(self, cid)
  if not require("Main.Children.ChildrenInterface").CheckChildhoodPhaseOpenAndToast() then
    return
  end
  local ItemModule = require("Main.Item.ItemModule")
  local myYuanbao = ItemModule.Instance():GetAllYuanBao()
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.children.CCancelCourse").new(cid))
end
def.method("userdata").SelectGrowToYouth = function(self, cid)
  local ChildPhase = require("consts.mzm.gsp.children.confbean.ChildPhase")
  local child = ChildrenDataMgr.Instance():GetChildById(cid)
  if child == nil then
    return
  end
  local look1, look2 = ChildrenUtils.SelectChildren(ChildPhase.YOUTH, child:GetGender())
  if look1 > 0 and look2 > 0 then
    require("Main.Children.ui.ChooseYouthLook").ShowChooseYouthLook(look1, look2, function(sel)
      local cfgId = sel
      self:GrowToYouth(cid, cfgId)
    end)
  elseif look1 > 0 then
    self:GrowToYouth(cid, look1)
  end
end
def.method("userdata", "number").GrowToYouth = function(self, cid, cfgId)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_ADULT) then
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.children.CChildhoodToAdult").new(cid, cfgId))
end
TeenMgr.Commit()
return TeenMgr
