local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TeenMainPanel = Lplus.Extend(ECPanelBase, "TeenMainPanel")
local ChildrenDataMgr = require("Main.Children.ChildrenDataMgr")
local TeenData = require("Main.Children.data.TeenData")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local PropType = require("consts.mzm.gsp.children.confbean.InterestType")
local ChildrenOperation = require("Main.Children.ui.ChildrenOperation")
local ChildPhase = require("consts.mzm.gsp.children.confbean.ChildPhase")
local Child = require("Main.Children.Child")
local GUIUtils = require("GUI.GUIUtils")
local def = TeenMainPanel.define
local instance
def.static("=>", TeenMainPanel).Instance = function()
  if instance == nil then
    instance = TeenMainPanel()
  end
  return instance
end
def.field("userdata").childId = nil
def.field("number").timer = 0
def.field(ChildrenOperation).childOpe = nil
def.field(Child).childModel = nil
def.field("boolean").isDrag = false
def.method("userdata").ShowTeenGrow = function(self, cid)
  local teenData = ChildrenDataMgr.Instance():GetChildById(cid)
  if teenData and teenData:IsTeen() then
    local dlg = TeenMainPanel.Instance()
    dlg.childId = cid
    if dlg:IsShow() then
      dlg:UpdateUI(teenData)
    else
      dlg:CreatePanel(RESPATH.PREFAB_TEEN_GROW, 1)
      dlg:SetModal(true)
    end
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.CHILDREN, gmodule.notifyId.Children.Name_Update, TeenMainPanel.OnNameChange, self)
  Event.RegisterEventWithContext(ModuleId.CHILDREN, gmodule.notifyId.Children.Teen_Youth, TeenMainPanel.OnChildPromote, self)
  Event.RegisterEventWithContext(ModuleId.CHILDREN, gmodule.notifyId.Children.Interest_Update, TeenMainPanel.OnInterestChange, self)
  Event.RegisterEventWithContext(ModuleId.CHILDREN, gmodule.notifyId.Children.Course_Update, TeenMainPanel.OnCourseChange, self)
  Event.RegisterEventWithContext(ModuleId.CHILDREN, gmodule.notifyId.Children.Child_Update, TeenMainPanel.OnChildUpdate, self)
  Event.RegisterEventWithContext(ModuleId.CHILDREN, gmodule.notifyId.Children.Fashion_Change, TeenMainPanel.OnChildrenFashionChange, self)
  self.childOpe = ChildrenOperation.CreateNew(self.m_panel:FindDirect("Img_Bg0/Group_Left/Group_Menu/Group_ChooseType"), self.childId)
  self:UpdateUI(nil)
end
def.override().OnDestroy = function(self)
  GameUtil.RemoveGlobalTimer(self.timer)
  self.childId = nil
  self.childOpe:Destroy()
  self.childOpe = nil
  if self.childModel ~= nil then
    self.childModel:DestroyModel()
    self.childModel = nil
  end
  self.isDrag = false
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Name_Update, TeenMainPanel.OnNameChange)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Teen_Youth, TeenMainPanel.OnChildPromote)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Interest_Update, TeenMainPanel.OnInterestChange)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Course_Update, TeenMainPanel.OnCourseChange)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Child_Update, TeenMainPanel.OnChildUpdate)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Fashion_Change, TeenMainPanel.OnChildrenFashionChange)
end
def.override("boolean").OnShow = function(self, show)
  if show and self.childModel then
    self.childModel:Stand()
  end
end
def.method("table").OnChildUpdate = function(self, param)
  if self.childId then
    local teenData = ChildrenDataMgr.Instance():GetChildById(self.childId)
    if teenData == nil or not teenData:IsTeen() then
      self:DestroyPanel()
    end
  end
end
def.method("table").OnNameChange = function(self, param)
  local childId = param[1]
  if self.childId == childId then
    self:UpdateName(nil)
  end
end
def.method("table").OnChildPromote = function(self, param)
  local childId = param[1]
  if self.childId == childId then
    self:DestroyPanel()
  end
end
def.method("table").OnInterestChange = function(self, param)
  local childId = param[1]
  if self.childId == childId then
    self:UpdateInterest(nil)
    self:UpdateProps(nil)
  end
end
def.method("table").OnCourseChange = function(self, param)
  local childId = param[1]
  if self.childId == childId then
    self:UpdateProps(nil)
    self:UpdateCurCourse(nil)
  end
end
def.method("table").OnChildrenFashionChange = function(self, params)
  local childId = params[1]
  local phase = params[2]
  if self.childId == childId and ChildPhase.CHILD == phase then
    self:UpdateModel(nil)
  end
end
def.method("=>", TeenData).GetData = function(self)
  if self.childId then
    local teenData = ChildrenDataMgr.Instance():GetChildById(self.childId)
    if teenData and teenData:IsTeen() then
      return teenData
    else
      return nil
    end
  else
    return nil
  end
end
def.method(TeenData).UpdateUI = function(self, teenData)
  if teenData == nil then
    teenData = self:GetData()
  end
  if teenData == nil then
    return
  end
  self:UpdateName(teenData)
  self:UpdateChildTurnCardClassType()
  self:UpdateModel(teenData)
  self:UpdateInterest(teenData)
  self:UpdateProps(teenData)
  self:UpdateCurCourse(teenData)
end
def.method(TeenData).UpdateName = function(self, teenData)
  if teenData == nil then
    teenData = self:GetData()
  end
  if teenData == nil then
    return
  end
  local nameLbl = self.m_panel:FindDirect("Img_Bg0/Group_Left/Group_Menu/Img_Bg/Label_Current")
  local name = teenData:GetName()
  nameLbl:GetComponent("UILabel"):set_text(name)
end
def.method().UpdateChildTurnCardClassType = function(self)
  local Img_Tpye = self.m_panel:FindDirect("Img_Bg0/Group_Left/Img_Tpye")
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHANGE_MODEL_CARD) then
    GUIUtils.SetTexture(Img_Tpye, 0)
  else
    local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
    local classCfg = TurnedCardUtils.GetCardClassCfg(constant.CChildrenConsts.cardClassType)
    GUIUtils.SetTexture(Img_Tpye, classCfg.smallIconId)
  end
end
def.method(TeenData).UpdateModel = function(self, teenData)
  if teenData == nil then
    teenData = self:GetData()
  end
  if teenData == nil then
    return
  end
  if self.childModel ~= nil then
    self.childModel:DestroyModel()
  end
  local fashion = teenData:GetFashionByPhase(teenData:GetStatus())
  self.childModel = Child.CreateWithFashion(teenData:GetModelCfgId(), fashion and fashion.fashionId or 0)
  local uiModel = self.m_panel:FindDirect("Img_Bg0/Group_Left/Model_Baby"):GetComponent("UIModel")
  self.childModel:LoadUIModel(nil, function()
    uiModel.modelGameObject = self.childModel.model.m_model
    if uiModel.mCanOverflow ~= nil then
      uiModel.mCanOverflow = true
      local camera = uiModel:get_modelCamera()
      camera:set_orthographic(true)
    end
  end)
end
def.method(TeenData).UpdateInterest = function(self, teenData)
  if teenData == nil then
    teenData = self:GetData()
  end
  if teenData == nil then
    return
  end
  local propStr = textRes.Children[0]
  if 0 < teenData:GetInterest() then
    local interestProp = teenData:GetInterestProps()
    propStr = ChildrenUtils.PropsToString(interestProp, "\n")
  end
  local propLbl = self.m_panel:FindDirect("Img_Bg0/Group_Left/Label_ZhuaZhou/Label_Name")
  propLbl:GetComponent("UILabel"):set_text(propStr)
end
def.method(TeenData).UpdateProps = function(self, teenData)
  if teenData == nil then
    teenData = self:GetData()
  end
  if teenData == nil then
    return
  end
  local courseProp = teenData:GetCourseProps()
  local interestProp = teenData:GetInterestProps()
  local sliderGroup = self.m_panel:FindDirect("Img_Bg0/Group_Right/Group_State")
  self:FillSlider(sliderGroup:FindDirect("Slider01_DeYu"), PropType.MORALS, courseProp[PropType.MORALS] or 0, interestProp[PropType.MORALS] or 0)
  self:FillSlider(sliderGroup:FindDirect("Slider02_ZhiYu"), PropType.INTELLIGENCE, courseProp[PropType.INTELLIGENCE] or 0, interestProp[PropType.INTELLIGENCE] or 0)
  self:FillSlider(sliderGroup:FindDirect("Slider03_TiYu"), PropType.PHYSICAL, courseProp[PropType.PHYSICAL] or 0, interestProp[PropType.PHYSICAL] or 0)
  self:FillSlider(sliderGroup:FindDirect("Slider04_MeiYu"), PropType.AESTHETIC, courseProp[PropType.AESTHETIC] or 0, interestProp[PropType.AESTHETIC] or 0)
  self:FillSlider(sliderGroup:FindDirect("Slider05_LaoYu"), PropType.MANUAL, courseProp[PropType.MANUAL] or 0, interestProp[PropType.MANUAL] or 0)
  self:FillSlider(sliderGroup:FindDirect("Slider06_YinYu"), PropType.MUSIC, courseProp[PropType.MUSIC] or 0, interestProp[PropType.MUSIC] or 0)
end
def.method("userdata", "number", "number", "number").FillSlider = function(self, slider, prop, value, addValue)
  local propCfg = ChildrenUtils.GetPropCfg(prop)
  local nameLbl = slider:FindDirect("Label_Name")
  nameLbl:GetComponent("UILabel"):set_text(propCfg.name)
  local nameSpr = slider:FindDirect("Img_Char")
  nameSpr:GetComponent("UISprite"):set_spriteName(textRes.Children.PropSpriteName[prop])
  local numberLbl = slider:FindDirect("Label_Slider")
  local numberStr
  if value > propCfg.limit then
    value = propCfg.limit or value
  end
  if addValue > 0 then
    numberStr = string.format("%d(+%d)/%d", value, addValue, propCfg.limit)
  else
    numberStr = string.format("%d/%d", value, propCfg.limit)
  end
  numberLbl:GetComponent("UILabel"):set_text(numberStr)
  slider:GetComponent("UISlider").value = (value + addValue) / propCfg.limit
end
local Second2Text = function(sec)
  if not (sec >= 0) or not sec then
    sec = 0
  end
  local hour = math.floor(sec / 3600)
  local minute = math.floor(sec % 3600 / 60)
  local second = sec % 60
  local text
  if hour > 0 then
    text = string.format("%02d%s%02d%s", hour, textRes.Common.Hour, minute, textRes.Common.Minute)
  elseif minute > 0 then
    text = string.format("%02d%s%02d%s", minute, textRes.Common.Minute, second, textRes.Common.Second)
  elseif second > 0 then
    text = string.format("%02d%s", second, textRes.Common.Second)
  else
    text = textRes.Children[2001]
  end
  return text
end
def.method("userdata", "userdata", "number", "number").FillCourseBar = function(self, slider, yuanbao, startTime, totalTime)
  if slider ~= nil and not slider.isnil and yuanbao ~= nil and not yuanbao.isnil then
    local curTime = GetServerTime()
    slider:GetComponent("UISlider").value = (curTime - startTime) / totalTime
    local leftTime = startTime + totalTime - curTime
    local text = Second2Text(leftTime)
    local leftTimeLbl = slider:FindDirect("Label_Slider")
    leftTimeLbl:GetComponent("UILabel"):set_text(string.format(textRes.Children[2002], text))
    local leftMinuteMoney = math.ceil(leftTime / 60) * constant.CChildHoodConst.YUAN_BAO_PER_MINUTE
    yuanbao:GetComponent("UILabel"):set_text(tostring(leftMinuteMoney))
  end
end
def.method(TeenData).UpdateCurCourse = function(self, teenData)
  if teenData == nil then
    teenData = self:GetData()
  end
  if teenData == nil then
    return
  end
  local curCourse = teenData:GetCurCourse()
  local todayTimes = teenData:GetTodayTimes()
  local courseGroup = self.m_panel:FindDirect("Img_Bg0/Group_Right/Img_Operate")
  local todayTimesLbl = courseGroup:FindDirect("Label_Num")
  todayTimesLbl:GetComponent("UILabel"):set_text(string.format(textRes.Children[2000], todayTimes))
  local hasGroup = courseGroup:FindDirect("Group_StateCan")
  local noGroup = courseGroup:FindDirect("Group_StateCant")
  if curCourse then
    hasGroup:SetActive(true)
    noGroup:SetActive(false)
    GameUtil.RemoveGlobalTimer(self.timer)
    do
      local courseCfg = ChildrenUtils.GetCourseCfg(curCourse.courseType)
      if courseCfg then
        local courseLbl = hasGroup:FindDirect("Slider_Prograss/Label_Name")
        courseLbl:GetComponent("UILabel"):set_text(courseCfg.name)
      end
      local slider = hasGroup:FindDirect("Slider_Prograss")
      local yuanbao = hasGroup:FindDirect("Img_Cost/Label_Cost")
      self:FillCourseBar(slider, yuanbao, curCourse.startSecond, courseCfg.studyTime * 60)
      self.timer = GameUtil.AddGlobalTimer(1, false, function()
        self:FillCourseBar(slider, yuanbao, curCourse.startSecond, courseCfg.studyTime * 60)
      end)
    end
  else
    hasGroup:SetActive(false)
    noGroup:SetActive(true)
    GameUtil.RemoveGlobalTimer(self.timer)
  end
  local btnCourse = self.m_panel:FindDirect("Img_Bg0/Group_Right/Btn_Train")
  local btnGrow = self.m_panel:FindDirect("Img_Bg0/Group_Right/Btn_GrowUp")
  if teenData:GetTotalCourseNum() >= constant.CChildHoodConst.TOTAL_NUM then
    btnCourse:SetActive(false)
    btnGrow:SetActive(true)
  else
    btnCourse:SetActive(true)
    btnGrow:SetActive(false)
  end
end
def.method("string", "boolean").onPress = function(self, id, state)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_ZhuaZhou" then
    require("Main.Children.ui.TeenInterestPanel").Instance():ShowChooseInterest(self.childId)
  elseif id == "Btn_Finish" then
    local data = self:GetData()
    if data then
      local courseInfo = data:GetCurCourse()
      if courseInfo then
        do
          local courseCfg = ChildrenUtils.GetCourseCfg(courseInfo.courseType)
          local curTime = GetServerTime()
          local leftTime = courseInfo.startSecond + courseCfg.studyTime * 60 - curTime
          local leftMinuteMoney = math.ceil(leftTime / 60) * constant.CChildHoodConst.YUAN_BAO_PER_MINUTE
          local CommonConfirm = require("GUI.CommonConfirmDlg")
          CommonConfirm.ShowConfirm(textRes.Children[2015], string.format(textRes.Children[2024], leftMinuteMoney), function(selection, tag)
            if selection == 1 then
              local count = require("Main.Item.ItemModule").Instance():GetAllYuanBao()
              if count < Int64.new(leftMinuteMoney) then
                Toast(textRes.Children[2016])
                GotoBuyYuanbao()
                return
              end
              require("Main.Children.mgr.TeenMgr").Instance():SpeedCourse(self.childId)
            end
          end, nil)
        end
      end
    end
  elseif self.childOpe and self.childOpe:onClick(id) then
  elseif id == "Btn_Cancel" then
    local CommonConfirm = require("GUI.CommonConfirmDlg")
    CommonConfirm.ShowConfirm(textRes.Children[2015], textRes.Children[2025], function(selection, tag)
      if selection == 1 then
        require("Main.Children.mgr.TeenMgr").Instance():CancelCourse(self.childId)
      end
    end, nil)
  elseif id == "Btn_Preview" then
    require("Main.Children.ui.TeenPreviewPanel").Instance():ShowPreview(self.childId)
  elseif id == "Btn_Train" then
    require("Main.Children.ui.TeenCoursePanel").Instance():ShowLearnCourse(self.childId)
  elseif id == "Btn_GrowUp" then
    require("Main.Children.mgr.TeenMgr").Instance():SelectGrowToYouth(self.childId)
  end
end
def.method("string", "boolean").onToggle = function(self, id, active)
  if id == "Img_Bg" and self.childOpe then
    if active then
      self.childOpe:Show(nil)
    else
      self.childOpe:Hide()
    end
  end
end
def.method("string").onDragStart = function(self, id)
  if id == "Model_Baby" then
    self.isDrag = true
  end
end
def.method("string").onDragEnd = function(self, id)
  self.isDrag = false
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.isDrag == true and self.childModel then
    self.childModel:SetDir(self.childModel:GetDir() - dx / 2)
  end
end
return TeenMainPanel.Commit()
