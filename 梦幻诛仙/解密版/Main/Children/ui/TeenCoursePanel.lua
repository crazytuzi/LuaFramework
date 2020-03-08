local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TeenCoursePanel = Lplus.Extend(ECPanelBase, "TeenCoursePanel")
local ChildrenDataMgr = require("Main.Children.ChildrenDataMgr")
local TeenData = require("Main.Children.data.TeenData")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local PropType = require("consts.mzm.gsp.children.confbean.InterestType")
local CourseType = require("consts.mzm.gsp.children.confbean.CourseType")
local def = TeenCoursePanel.define
local instance
def.static("=>", TeenCoursePanel).Instance = function()
  if instance == nil then
    instance = TeenCoursePanel()
  end
  return instance
end
def.field("userdata").childId = nil
def.field("number").curSelect = 0
def.method("userdata").ShowLearnCourse = function(self, cid)
  local teenData = ChildrenDataMgr.Instance():GetChildById(cid)
  if teenData and teenData:IsTeen() then
    local dlg = TeenCoursePanel.Instance()
    dlg.childId = cid
    dlg.curSelect = CourseType.JIAN_SHU
    if dlg:IsShow() then
      dlg:UpdateUI(teenData)
    else
      dlg:CreatePanel(RESPATH.PREFAB_TEEN_LEARN_COURSE, 2)
      dlg:SetModal(true)
    end
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.CHILDREN, gmodule.notifyId.Children.Name_Update, TeenCoursePanel.OnNameChange, self)
  Event.RegisterEventWithContext(ModuleId.CHILDREN, gmodule.notifyId.Children.Course_Update, TeenCoursePanel.OnCourseChange, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, TeenCoursePanel.OnCurrencyChanged, self)
  Event.RegisterEventWithContext(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_CHANGED, TeenCoursePanel.OnCurrencyChanged, self)
  self:UpdateUI(nil)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Name_Update, TeenCoursePanel.OnNameChange)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Course_Update, TeenCoursePanel.OnCourseChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, TeenCoursePanel.OnCurrencyChanged)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_CHANGED, TeenCoursePanel.OnCurrencyChanged)
  self.childId = nil
end
def.method("table").OnCourseChange = function(self, param)
  local childId = param[1]
  if self.childId == childId then
    self:UpdateProp(nil)
    self:UpdateSelect(nil, self.curSelect)
  end
end
def.method("table").OnNameChange = function(self, param)
  local childId = param[1]
  if self.childId == childId then
    self:UpdateName(nil)
  end
end
def.method("table").OnCurrencyChanged = function(self, param)
  self:UpdateMoneyInfo()
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
  self:UpdateProp(teenData)
  self:UpdateMoneyInfo()
  self:UpdateSelect(teenData, self.curSelect)
end
def.method(TeenData).UpdateName = function(self, teenData)
  if teenData == nil then
    teenData = self:GetData()
  end
  if teenData == nil then
    return
  end
  local name = teenData:GetName()
  local nameLbl = self.m_panel:FindDirect("Img_Bg0/Group_Left/Label_Title")
  nameLbl:GetComponent("UILabel"):set_text(name)
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
def.method(TeenData).UpdateProp = function(self, teenData)
  if teenData == nil then
    teenData = self:GetData()
  end
  if teenData == nil then
    return
  end
  local courseProp = teenData:GetCourseProps()
  local interestProp = teenData:GetInterestProps()
  local propGroup = self.m_panel:FindDirect("Img_Bg0/Group_Left/Group_State")
  self:FillSlider(propGroup:FindDirect("Slider_DeYu"), PropType.MORALS, courseProp[PropType.MORALS] or 0, interestProp[PropType.MORALS] or 0)
  self:FillSlider(propGroup:FindDirect("Slider_ZhiYu"), PropType.INTELLIGENCE, courseProp[PropType.INTELLIGENCE] or 0, interestProp[PropType.INTELLIGENCE] or 0)
  self:FillSlider(propGroup:FindDirect("Slider_TiYu"), PropType.PHYSICAL, courseProp[PropType.PHYSICAL] or 0, interestProp[PropType.PHYSICAL] or 0)
  self:FillSlider(propGroup:FindDirect("Slider_MeiYu"), PropType.AESTHETIC, courseProp[PropType.AESTHETIC] or 0, interestProp[PropType.AESTHETIC] or 0)
  self:FillSlider(propGroup:FindDirect("Slider_LaoYu"), PropType.MANUAL, courseProp[PropType.MANUAL] or 0, interestProp[PropType.MANUAL] or 0)
  self:FillSlider(propGroup:FindDirect("Slider_YinYu"), PropType.MUSIC, courseProp[PropType.MUSIC] or 0, interestProp[PropType.MUSIC] or 0)
end
def.method("userdata", "number").FillBtn = function(self, uiGo, courseType)
  if uiGo == nil then
    return
  end
  local nameLbl = uiGo:FindDirect("Label_Name")
  local courseCfg = ChildrenUtils.GetCourseCfg(courseType)
  nameLbl:GetComponent("UILabel"):set_text(courseCfg.name)
  if courseType == self.curSelect then
    uiGo:GetComponent("UIToggle").value = true
  else
    uiGo:GetComponent("UIToggle").value = false
  end
end
def.method(TeenData, "number").UpdateSelect = function(self, teenData, course)
  self.curSelect = course
  if teenData == nil then
    teenData = self:GetData()
  end
  if teenData == nil then
    return
  end
  local toggleGroup = self.m_panel:FindDirect("Img_Bg0/Group_Right/Group_Btn")
  self:FillBtn(toggleGroup:FindDirect("Btn_JianShu"), CourseType.JIAN_SHU)
  self:FillBtn(toggleGroup:FindDirect("Btn_LaoZuo"), CourseType.LAO_ZUO)
  self:FillBtn(toggleGroup:FindDirect("Btn_ShiGe"), CourseType.SHI_GE)
  self:FillBtn(toggleGroup:FindDirect("Btn_QiShe"), CourseType.QI_SHE)
  self:FillBtn(toggleGroup:FindDirect("Btn_DanQing"), CourseType.DAN_QING)
  self:FillBtn(toggleGroup:FindDirect("Btn_QinYi"), CourseType.QIN_YI)
  self:UpdateDetail(teenData, self.curSelect)
end
local Minute2Text = function(minute)
  if not (minute >= 0) or not minute then
    minute = 0
  end
  local hour = math.floor(minute / 60)
  local minute = minute % 60
  local text
  if hour > 0 then
    text = string.format("%02d%s%02d%s", hour, textRes.Common.Hour, minute, textRes.Common.Minute)
  else
    text = string.format("%02d%s", minute, textRes.Common.Minute)
  end
  return text
end
def.method(TeenData, "number").UpdateDetail = function(self, teenData, course)
  if teenData == nil then
    teenData = self:GetData()
  end
  if teenData == nil then
    return
  end
  local descLbl = self.m_panel:FindDirect("Img_Bg0/Group_Right/Label_Details")
  local detailGroup = self.m_panel:FindDirect("Img_Bg0/Group_Right/Group_Result")
  local courseCfg = ChildrenUtils.GetCourseCfg(course)
  if courseCfg then
    descLbl:SetActive(true)
    detailGroup:SetActive(true)
    local courseInfo = teenData:GetCourseInfo(course)
    descLbl:GetComponent("UILabel"):set_text(courseCfg.desc)
    local timesLbl = detailGroup:FindDirect("Label01_Group/Label02")
    local times = courseInfo and courseInfo.num or 0
    timesLbl:GetComponent("UILabel"):set_text(string.format(textRes.Children[2003], times))
    local effectLbl = detailGroup:FindDirect("Label02_Group/Label02")
    local prop = {}
    for _, v in ipairs(courseCfg.props) do
      prop[v.prop] = v.value
    end
    local propStr = ChildrenUtils.PropsToString(prop, " ")
    effectLbl:GetComponent("UILabel"):set_text(propStr)
    local costLbl = detailGroup:FindDirect("Label04_Group/Label02")
    local costVigor = courseCfg.vigorCost
    local moneyName = textRes.Item.MoneyName[courseCfg.moneyCostType]
    local moneyNum = courseCfg.moneyCostNum
    local costStr = string.format(textRes.Children[2004], costVigor, moneyName, moneyNum)
    costLbl:GetComponent("UILabel"):set_text(costStr)
    local hourLbl = detailGroup:FindDirect("Label05_Group/Label01")
    local text = textRes.Children[2005] .. Minute2Text(courseCfg.studyTime)
    hourLbl:GetComponent("UILabel"):set_text(text)
  else
    descLbl:SetActive(false)
    detailGroup:SetActive(false)
  end
end
def.method().UpdateMoneyInfo = function(self)
  local ItemModule = require("Main.Item.ItemModule")
  local myMoney = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
  local myHeroProp = require("Main.Hero.Interface").GetHeroProp()
  local cur = myHeroProp.energy
  local max = myHeroProp:GetMaxEnergy()
  local vigorLbl = self.m_panel:FindDirect("Img_Bg0/Group_CurInfo/Label_ActNum")
  vigorLbl:GetComponent("UILabel"):set_text(string.format("%d/%d", cur, max))
  local moneyLbl = self.m_panel:FindDirect("Img_Bg0/Group_CurInfo/Label_MoneyNum")
  moneyLbl:GetComponent("UILabel"):set_text(myMoney:tostring())
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Start" then
    if self.curSelect > 0 then
      do
        local teenData = ChildrenDataMgr.Instance():GetChildById(self.childId)
        local courseCfg = ChildrenUtils.GetCourseCfg(self.curSelect)
        if teenData and courseCfg then
          local CommonConfirm = require("GUI.CommonConfirmDlg")
          local str = string.format(textRes.Children[2012], teenData:GetName(), courseCfg.name, Minute2Text(courseCfg.studyTime), courseCfg.studyTime * constant.CChildHoodConst.YUAN_BAO_PER_MINUTE)
          local dlg = CommonConfirm.ShowConfirmCoundDown(textRes.Children[2015], str, textRes.Children[2014], textRes.Children[2013], 0, 0, function(selection, tag)
            if selection < 0 then
              return
            end
            local ItemModule = require("Main.Item.ItemModule")
            local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
            local moneyType
            if courseCfg.moneyCostType == MoneyType.GOLD then
              moneyType = ItemModule.MONEY_TYPE_GOLD
            elseif courseCfg.moneyCostType == MoneyType.SILVER then
              moneyType = ItemModule.MONEY_TYPE_SILVER
            end
            if moneyType == nil then
              return
            end
            local count = ItemModule.Instance():GetMoney(moneyType)
            if count < Int64.new(courseCfg.moneyCostNum) then
              Toast(string.format(textRes.Children[2017], textRes.Item.MoneyName[courseCfg.moneyCostType]))
              if moneyType == ItemModule.MONEY_TYPE_GOLD then
                GoToBuyGold()
              elseif moneyType == ItemModule.MONEY_TYPE_SILVER then
                GoToBuySilver()
              end
              return
            end
            local myHeroProp = require("Main.Hero.Interface").GetHeroProp()
            if courseCfg.vigorCost > myHeroProp.energy then
              Toast(textRes.Children[2018])
              return
            end
            if selection == 1 then
              require("Main.Children.mgr.TeenMgr").Instance():StudyCourse(self.childId, self.curSelect)
            elseif selection == 0 then
              local count = ItemModule.Instance():GetAllYuanBao()
              if count < Int64.new(courseCfg.studyTime * constant.CChildHoodConst.YUAN_BAO_PER_MINUTE) then
                Toast(textRes.Children[2016])
                GotoBuyYuanbao()
                return
              end
              require("Main.Children.mgr.TeenMgr").Instance():BuyCourse(self.childId, self.curSelect)
            end
          end, nil)
          dlg:ShowCloseBtn()
        end
      end
    end
  elseif id == "Btn_JianShu" then
    self:UpdateSelect(nil, CourseType.JIAN_SHU)
  elseif id == "Btn_LaoZuo" then
    self:UpdateSelect(nil, CourseType.LAO_ZUO)
  elseif id == "Btn_ShiGe" then
    self:UpdateSelect(nil, CourseType.SHI_GE)
  elseif id == "Btn_QiShe" then
    self:UpdateSelect(nil, CourseType.QI_SHE)
  elseif id == "Btn_DanQing" then
    self:UpdateSelect(nil, CourseType.DAN_QING)
  elseif id == "Btn_QinYi" then
    self:UpdateSelect(nil, CourseType.QIN_YI)
  elseif id == "Btn_Help" then
    local tipsId = constant.CChildHoodConst.UI_INTEREST_TIPS
    require("GUI.GUIUtils").ShowHoverTip(tipsId, 0, 0)
  end
end
return TeenCoursePanel.Commit()
