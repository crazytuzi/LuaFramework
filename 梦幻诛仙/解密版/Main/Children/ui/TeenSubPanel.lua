local Lplus = require("Lplus")
local SubPanel = require("Main.Children.ui.SubPanel")
local TeenSubPanel = Lplus.Extend(SubPanel, "TeenSubPanel")
local TeenData = require("Main.Children.data.TeenData")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local PropType = require("consts.mzm.gsp.children.confbean.InterestType")
local ChildrenOperation = require("Main.Children.ui.ChildrenOperation")
local ChildPhase = require("consts.mzm.gsp.children.confbean.ChildPhase")
local Child = require("Main.Children.Child")
local GUIUtils = require("GUI.GUIUtils")
local def = TeenSubPanel.define
def.field("number").timer = 0
def.field(ChildrenOperation).childOpe = nil
def.field(Child).childModel = nil
def.field("boolean").isDrag = false
def.field("table").data = nil
def.override().Hide = function(self)
  if self.m_node and not self.m_node.isnil then
    self.m_node:SetActive(false)
    self:Clear()
  end
end
def.override("table").Show = function(self, data)
  if self.m_node and not self.m_node.isnil then
    Event.RegisterEventWithContext(ModuleId.CHILDREN, gmodule.notifyId.Children.Name_Update, TeenSubPanel.OnNameChange, self)
    Event.RegisterEventWithContext(ModuleId.CHILDREN, gmodule.notifyId.Children.Course_Update, TeenSubPanel.OnCourseChange, self)
    Event.RegisterEventWithContext(ModuleId.CHILDREN, gmodule.notifyId.Children.Fashion_Change, TeenSubPanel.OnChildrenFashionChange, self)
    self.data = data
    self.m_node:SetActive(true)
    self.m_node:FindDirect("Group_Menu/Img_Bg"):GetComponent("UIToggleEx").value = false
    self.childOpe = ChildrenOperation.CreateNew(self.m_node:FindDirect("Group_Menu/Group_ChooseType"), data:GetId())
    self:SetModel(data)
    self:SetName(data)
    self:SetChildTurnCardClassType()
    self:SetProp(data)
    self:SetCourse(data)
  end
end
def.method().Clear = function(self)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Name_Update, TeenSubPanel.OnNameChange)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Course_Update, TeenSubPanel.OnCourseChange)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Fashion_Change, TeenSubPanel.OnChildrenFashionChange)
  GameUtil.RemoveGlobalTimer(self.timer)
  if self.childModel ~= nil then
    self.childModel:DestroyModel()
    self.childModel = nil
  end
  self.isDrag = false
  self.data = nil
end
def.method("table").OnNameChange = function(self, param)
  local childId = param[1]
  if self.data:GetId() == childId then
    self:SetName(self.data)
  end
end
def.method("table").OnCourseChange = function(self, param)
  local childId = param[1]
  if self.data:GetId() == childId then
    self:SetProp(self.data)
    self:SetCourse(self.data)
  end
end
def.method("table").OnChildrenFashionChange = function(self, params)
  local childId = params[1]
  local phase = params[2]
  if self.data:GetId() == childId and ChildPhase.CHILD == phase then
    self:SetModel(self.data)
  end
end
def.override().Destroy = function(self)
  self:Clear()
end
def.method(TeenData).SetModel = function(self, data)
  if self.childModel ~= nil then
    self.childModel:DestroyModel()
  end
  local fashion = data:GetFashionByPhase(data:GetStatus())
  self.childModel = Child.CreateWithFashion(data:GetModelCfgId(), fashion and fashion.fashionId or 0)
  local uiModel = self.m_node:FindDirect("Model_Baby"):GetComponent("UIModel")
  self.childModel:LoadUIModel(nil, function()
    uiModel.modelGameObject = self.childModel.model.m_model
    if uiModel.mCanOverflow ~= nil then
      uiModel.mCanOverflow = true
      local camera = uiModel:get_modelCamera()
      camera:set_orthographic(true)
    end
  end)
end
def.method(TeenData).SetName = function(self, data)
  if data == nil then
    return
  end
  local nameLbl = self.m_node:FindDirect("Group_Menu/Img_Bg/Label_Current")
  nameLbl:GetComponent("UILabel"):set_text(data:GetName())
end
def.method().SetChildTurnCardClassType = function(self)
  local Img_Tpye = self.m_node:FindDirect("Img_Tpye")
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHANGE_MODEL_CARD) then
    GUIUtils.SetTexture(Img_Tpye, 0)
  else
    local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
    local classCfg = TurnedCardUtils.GetCardClassCfg(constant.CChildrenConsts.cardClassType)
    GUIUtils.SetTexture(Img_Tpye, classCfg.smallIconId)
  end
end
def.method("userdata", "number", "number", "number").FillSlider = function(self, slider, prop, value, addValue)
  local propCfg = ChildrenUtils.GetPropCfg(prop)
  local nameLbl = slider:FindDirect("Label_Name")
  local numberLbl = slider:FindDirect("Label_Slider")
  nameLbl:GetComponent("UILabel"):set_text(propCfg.name)
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
def.method(TeenData).SetProp = function(self, data)
  if data == nil then
    return
  end
  local courseProp = data:GetCourseProps()
  local interestProp = data:GetInterestProps()
  local sliderGroup = self.m_node:FindDirect("Group_State")
  self:FillSlider(sliderGroup:FindDirect("Slider01_DeYu"), PropType.MORALS, courseProp[PropType.MORALS] or 0, interestProp[PropType.MORALS] or 0)
  self:FillSlider(sliderGroup:FindDirect("Slider02_TiYu"), PropType.PHYSICAL, courseProp[PropType.PHYSICAL] or 0, interestProp[PropType.PHYSICAL] or 0)
  self:FillSlider(sliderGroup:FindDirect("Slider03_MeiYu"), PropType.AESTHETIC, courseProp[PropType.AESTHETIC] or 0, interestProp[PropType.AESTHETIC] or 0)
  self:FillSlider(sliderGroup:FindDirect("Slider04_ZhiYu"), PropType.INTELLIGENCE, courseProp[PropType.INTELLIGENCE] or 0, interestProp[PropType.INTELLIGENCE] or 0)
  self:FillSlider(sliderGroup:FindDirect("Slider05_LaoYu"), PropType.MANUAL, courseProp[PropType.MANUAL] or 0, interestProp[PropType.MANUAL] or 0)
  self:FillSlider(sliderGroup:FindDirect("Slider06_YinYu"), PropType.MUSIC, courseProp[PropType.MUSIC] or 0, interestProp[PropType.MUSIC] or 0)
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
  end
end
def.virtual(TeenData).SetCourse = function(self, data)
  if data == nil then
    return
  end
  local curCourse = data:GetCurCourse()
  local todayTimes = data:GetTodayTimes()
  local courseGroup = self.m_node:FindDirect("Img_Operate")
  local todayTimesLbl = courseGroup:FindDirect("Label_Num")
  todayTimesLbl:GetComponent("UILabel"):set_text(string.format(textRes.Children[2000], todayTimes))
  local hasGroup = courseGroup:FindDirect("Group_StateCan")
  local noGroup = courseGroup:FindDirect("Group_StateCant")
  if curCourse then
    hasGroup:SetActive(true)
    noGroup:SetActive(false)
    hasGroup:FindDirect("Btn_Cancel"):SetActive(false)
    hasGroup:FindDirect("Img_Cost"):SetActive(false)
    hasGroup:FindDirect("Btn_Finish"):SetActive(false)
    GameUtil.RemoveGlobalTimer(self.timer)
    do
      local courseCfg = ChildrenUtils.GetCourseCfg(curCourse.courseType)
      if courseCfg then
        local courseLbl = hasGroup:FindDirect("Slider_DeYu_Prograss/Label_Name")
        courseLbl:GetComponent("UILabel"):set_text(courseCfg.name)
      end
      local slider = hasGroup:FindDirect("Slider_DeYu_Prograss")
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
end
def.override("string", "=>", "boolean").onClick = function(self, id)
  if self:IsShow() then
    if self.childOpe and self.childOpe:onClick(id) then
      return true
    end
    return false
  else
    return false
  end
end
def.override("string", "boolean", "=>", "boolean").onToggle = function(self, id, active)
  if self:IsShow() then
    if id == "Img_Bg" then
      if self.childOpe then
        if active then
          self.childOpe:Show(nil)
        else
          self.childOpe:Hide()
        end
      end
      return true
    end
    return false
  else
    return false
  end
end
def.override("string", "=>", "boolean").onDragStart = function(self, id)
  if self:IsShow() then
    if id == "Model_Baby" then
      self.isDrag = true
      return true
    end
    return false
  else
    return false
  end
end
def.override("string", "=>", "boolean").onDragEnd = function(self, id)
  if self:IsShow() then
    if self.isDrag then
      self.isDrag = false
      return true
    end
    return false
  else
    return false
  end
end
def.override("string", "number", "number", "=>", "boolean").onDrag = function(self, id, dx, dy)
  if self:IsShow() then
    if self.isDrag == true and self.childModel then
      self.childModel:SetDir(self.childModel:GetDir() - dx / 2)
      return true
    end
    return false
  else
    return false
  end
end
TeenSubPanel.Commit()
return TeenSubPanel
