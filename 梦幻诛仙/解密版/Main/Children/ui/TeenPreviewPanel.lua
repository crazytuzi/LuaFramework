local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TeenPreviewPanel = Lplus.Extend(ECPanelBase, "TeenPreviewPanel")
local ChildrenDataMgr = require("Main.Children.ChildrenDataMgr")
local TeenData = require("Main.Children.data.TeenData")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local PropType = require("consts.mzm.gsp.children.confbean.InterestType")
local CourseType = require("consts.mzm.gsp.children.confbean.CourseType")
local def = TeenPreviewPanel.define
local instance
def.static("=>", TeenPreviewPanel).Instance = function()
  if instance == nil then
    instance = TeenPreviewPanel()
  end
  return instance
end
def.field(TeenData).tempTeenData = nil
def.field("table").aptitudeMap = nil
def.method("userdata").ShowPreview = function(self, cid)
  local teenData
  if cid then
    teenData = ChildrenDataMgr.Instance():GetChildById(cid)
    if teenData and not teenData:IsTeen() then
      teenData = nil
    end
  end
  local dlg = TeenPreviewPanel.Instance()
  dlg.tempTeenData = TeenData.New()
  TeenData.Copy(teenData, dlg.tempTeenData)
  if not dlg:IsShow() then
    dlg:CreatePanel(RESPATH.PREFAB_TEEN_PREIVEW, 2)
    dlg:SetModal(true)
  end
end
def.override().OnCreate = function(self)
  self.aptitudeMap = ChildrenUtils.LoadAptitudeData()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.aptitudeMap = nil
end
def.method().UpdateUI = function(self)
  self:UpdateCourse()
  self:UpdateProp()
  self:UpdateAptitude()
  self:UpdateTimes()
end
def.method("userdata", "number").FillCourse = function(self, uiGo, courseType)
  if uiGo == nil then
    return
  end
  local courseCfg = ChildrenUtils.GetCourseCfg(courseType)
  uiGo:GetComponent("UILabel"):set_text(courseCfg.name)
  local courseInfo = self.tempTeenData:GetCourseInfo(courseType)
  local num = courseInfo and courseInfo.num or 0
  local timesLbl = uiGo:FindDirect("Group_Point/Img_JDPlan_BgNum/Label_JDPlan_Num")
  timesLbl:GetComponent("UILabel"):set_text(tostring(num))
end
def.method().UpdateCourse = function(self)
  local group = self.m_panel:FindDirect("Img_Bg0/Group_Left/Group_Plan")
  self:FillCourse(group:FindDirect("Label_JianShu"), CourseType.JIAN_SHU)
  self:FillCourse(group:FindDirect("Label_LaoZuo"), CourseType.LAO_ZUO)
  self:FillCourse(group:FindDirect("Label_ShiGe"), CourseType.SHI_GE)
  self:FillCourse(group:FindDirect("Label_QiShe"), CourseType.QI_SHE)
  self:FillCourse(group:FindDirect("Label_DanQing"), CourseType.DAN_QING)
  self:FillCourse(group:FindDirect("Label_QingYi"), CourseType.QIN_YI)
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
def.method().UpdateProp = function(self)
  local courseProp = self.tempTeenData:GetCourseProps()
  local interestProp = self.tempTeenData:GetInterestProps()
  local propGroup = self.m_panel:FindDirect("Img_Bg0/Group_Right/Group_State")
  self:FillSlider(propGroup:FindDirect("Slider_DeYu"), PropType.MORALS, courseProp[PropType.MORALS] or 0, interestProp[PropType.MORALS] or 0)
  self:FillSlider(propGroup:FindDirect("Slider_ZhiYu"), PropType.INTELLIGENCE, courseProp[PropType.INTELLIGENCE] or 0, interestProp[PropType.INTELLIGENCE] or 0)
  self:FillSlider(propGroup:FindDirect("Slider_TiYu"), PropType.PHYSICAL, courseProp[PropType.PHYSICAL] or 0, interestProp[PropType.PHYSICAL] or 0)
  self:FillSlider(propGroup:FindDirect("Slider_MeiYu"), PropType.AESTHETIC, courseProp[PropType.AESTHETIC] or 0, interestProp[PropType.AESTHETIC] or 0)
  self:FillSlider(propGroup:FindDirect("Slider_LaoYu"), PropType.MANUAL, courseProp[PropType.MANUAL] or 0, interestProp[PropType.MANUAL] or 0)
  self:FillSlider(propGroup:FindDirect("Slider_YinYu"), PropType.MUSIC, courseProp[PropType.MUSIC] or 0, interestProp[PropType.MUSIC] or 0)
end
def.method("=>", "table").GetAptitude = function(self)
  local props = self.tempTeenData:GetAllProps()
  for _, v in pairs(PropType) do
    if v > 0 and props[v] == nil then
      props[v] = 0
    end
  end
  local aptitudes = {}
  for k, v in pairs(props) do
    if self.aptitudeMap[k] then
      local aptitude = self.aptitudeMap[k][v]
      if aptitude then
        for k, v in ipairs(aptitude) do
          if aptitudes[v.aptitude] == nil then
            aptitudes[v.aptitude] = {
              v.min,
              v.max
            }
          else
            aptitudes[v.aptitude] = {
              aptitudes[v.aptitude][1] + v.min,
              aptitudes[v.aptitude][2] + v.max
            }
          end
        end
      else
        warn("Bad aptitude switch", k, v)
      end
    else
      warn("Bad aptitude switch", k, v)
    end
  end
  return aptitudes
end
def.method().UpdateAptitude = function(self)
  local aptitudes = self:GetAptitude()
  local group = self.m_panel:FindDirect("Img_Bg0/Group_Right/Group_Range")
  for i = 1, 6 do
    local lbl = group:FindDirect(string.format("Label_%02d", i))
    local aptitude = aptitudes[i]
    if aptitude then
      local num = lbl:FindDirect("Label_Num")
      num:GetComponent("UILabel"):set_text(string.format("%d~%d", aptitude[1], aptitude[2]))
    else
      local num = lbl:FindDirect("Label_Num")
      num:GetComponent("UILabel"):set_text(string.format("%d~%d", 0, 0))
    end
  end
end
def.method().UpdateTimes = function(self)
  local totalTimes = constant.CChildHoodConst.TOTAL_NUM
  local useTimes = self.tempTeenData:GetTotalCourseNum()
  local numLbl = self.m_panel:FindDirect("Img_Bg0/Group_Left/Label_Num")
  numLbl:GetComponent("UILabel"):set_text(string.format("%d/%d", useTimes, totalTimes))
end
def.method("number").AddCourse = function(self, courseType)
  local courseInfo = self.tempTeenData:GetCourseInfo(courseType)
  local num = 1
  num = not courseInfo or courseInfo.num + 1 > constant.CChildHoodConst.TOTAL_NUM and constant.CChildHoodConst.TOTAL_NUM or courseInfo.num + 1
  self.tempTeenData:SetCourseInfo(courseType, num, 0)
end
def.method("number").MinusCourse = function(self, courseType)
  local courseInfo = self.tempTeenData:GetCourseInfo(courseType)
  local num = 0
  num = not courseInfo or 0 < courseInfo.num - 1 and courseInfo.num - 1 or 0
  self.tempTeenData:SetCourseInfo(courseType, num, 0)
end
def.method("number", "=>", "boolean").CanAdd = function(self, courseType)
  local useTimes = self.tempTeenData:GetTotalCourseNum()
  if useTimes + 1 > constant.CChildHoodConst.TOTAL_NUM then
    Toast(textRes.Children[2027])
    return false
  end
  local courseCfg = ChildrenUtils.GetCourseCfg(courseType)
  local allFull = true
  local props = self.tempTeenData:GetCourseProps()
  for k, v in pairs(courseCfg.props) do
    local propCfg = ChildrenUtils.GetPropCfg(v.prop)
    if (props[v.prop] or 0) < propCfg.limit then
      allFull = false
    end
  end
  if allFull then
    Toast(string.format(textRes.Children[2026], courseCfg.name))
    return false
  end
  return true
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Recommend" then
    do
      local allRecommend = ChildrenUtils.GetAllOccupationRecommend()
      local rcmd = {}
      for _, v in ipairs(allRecommend) do
        table.insert(rcmd, v.name)
      end
      table.insert(rcmd, textRes.Children[2040])
      require("Main.Children.ui.SelectOne").ShowSelectOne(textRes.Children[2006], rcmd, function(select)
        local recommend = allRecommend[select]
        if recommend then
          local recommendCfg = ChildrenUtils.GetOneOccupationRecommond(recommend.id)
          self.tempTeenData:ClearAllCourse()
          for _, v in ipairs(recommendCfg.courses) do
            self.tempTeenData:SetCourseInfo(v.course, v.value, 0)
          end
          self:UpdateUI()
        else
          require("Main.Grow.ui.GrowGuidePanel").Instance():ShowDlgEx(3, {targetBaodianNode = 10, subTargetBaodianNode = 5})
        end
      end)
    end
  elseif id == "Btn_Reset" then
    self.tempTeenData:ClearAllCourse()
    self:UpdateUI()
  elseif id == "Btn_Add_JianShu" then
    if self:CanAdd(CourseType.JIAN_SHU) then
      self:AddCourse(CourseType.JIAN_SHU)
      self:UpdateUI()
    end
  elseif id == "Btn_Minus_JianShu" then
    self:MinusCourse(CourseType.JIAN_SHU)
    self:UpdateUI()
  elseif id == "Btn_Add_LaoZuo" then
    if self:CanAdd(CourseType.LAO_ZUO) then
      self:AddCourse(CourseType.LAO_ZUO)
      self:UpdateUI()
    end
  elseif id == "Btn_Minus_LaoZuo" then
    self:MinusCourse(CourseType.LAO_ZUO)
    self:UpdateUI()
  elseif id == "Btn_Add_ShiGe" then
    if self:CanAdd(CourseType.SHI_GE) then
      self:AddCourse(CourseType.SHI_GE)
      self:UpdateUI()
    end
  elseif id == "Btn_Minus_ShiGe" then
    self:MinusCourse(CourseType.SHI_GE)
    self:UpdateUI()
  elseif id == "Btn_Add_QiShe" then
    if self:CanAdd(CourseType.QI_SHE) then
      self:AddCourse(CourseType.QI_SHE)
      self:UpdateUI()
    end
  elseif id == "Btn_Minus_QiShe" then
    self:MinusCourse(CourseType.QI_SHE)
    self:UpdateUI()
  elseif id == "Btn_Add_DanQing" then
    if self:CanAdd(CourseType.DAN_QING) then
      self:AddCourse(CourseType.DAN_QING)
      self:UpdateUI()
    end
  elseif id == "Btn_Minus_DanQing" then
    self:MinusCourse(CourseType.DAN_QING)
    self:UpdateUI()
  elseif id == "Btn_Add_QingYi" then
    if self:CanAdd(CourseType.QIN_YI) then
      self:AddCourse(CourseType.QIN_YI)
      self:UpdateUI()
    end
  elseif id == "Btn_Minus_QingYi" then
    self:MinusCourse(CourseType.QIN_YI)
    self:UpdateUI()
  elseif id == "Btn_Help" then
    local tipsId = constant.CChildHoodConst.UI_SCHEME_TIPS
    require("GUI.GUIUtils").ShowHoverTip(tipsId, 0, 0)
  end
end
return TeenPreviewPanel.Commit()
