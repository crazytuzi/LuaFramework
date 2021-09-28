CZuoqiSkillHeadItem = class("CZuoqiSkillHeadItem", function()
  return Widget:create()
end)
function CZuoqiSkillHeadItem:ctor(zqId, zqTypeId, clickHandler, size)
  self:setNodeEventEnabled(true)
  self.m_ZuoQiId = zqId
  self.m_ZqTypeId = zqTypeId
  self.m_ClickHandler = clickHandler
  self.m_IsSelected = nil
  if zqTypeId == ZUOQITYPE_EMPTY6ZUOQI then
    self.m_HeadIcon = createWidgetFrameHeadIconByRoleTypeID(zqTypeId, nil, nil, ccp(0, -5), "views/common/btn/btn_add_2.png")
  else
    self.m_HeadIcon = createWidgetFrameHeadIconByRoleTypeID(zqTypeId)
  end
  self:addChild(self.m_HeadIcon)
  self.m_TouchNode = clickwidget.create(size.width, size.height, 0.5, 0.5, function(touchNode, event)
    self:TouchOnObj(event)
  end)
  self:addChild(self.m_TouchNode)
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(size.width, size.height))
  self:setScale(0.8)
  self:SetSelected(false, false)
end
function CZuoqiSkillHeadItem:getId()
  return self.m_ZuoQiId
end
function CZuoqiSkillHeadItem:TouchOnObj(event)
  if event == TOUCH_EVENT_BEGAN then
    self:SetTouchState(true)
    self.m_IsTouchMoved = false
  elseif event == TOUCH_EVENT_MOVED then
    if not self.m_IsTouchMoved then
      local startPos = self.m_TouchNode:getTouchStartPos()
      local movePos = self.m_TouchNode:getTouchMovePos()
      if math.abs(startPos.x - movePos.x) + math.abs(startPos.y - movePos.y) > 20 then
        self.m_IsTouchMoved = true
        self:SetTouchState(false)
      end
    end
  elseif event == TOUCH_EVENT_ENDED or event == TOUCH_EVENT_CANCELED then
    if not self.m_IsTouchMoved then
      self:OnClicked()
    end
    self:SetTouchState(false)
  end
end
function CZuoqiSkillHeadItem:SetTouchState(iTouch, scaleAction)
  if iTouch then
    if scaleAction ~= false then
      self:stopAllActions()
      self:runAction(CCScaleTo:create(0.15, 1))
    else
      self:setScale(1)
    end
  elseif scaleAction ~= false then
    if not self.m_IsSelected then
      self:stopAllActions()
      self:runAction(CCScaleTo:create(0.15, 0.8))
    end
  else
    self:setScale(0.8)
  end
end
function CZuoqiSkillHeadItem:SetSelected(iSel, scaleAction)
  if self.m_IsSelected == iSel then
    return
  end
  self.m_IsSelected = iSel
  if iSel then
    if self.m_SelectedIcon == nil then
      self.m_SelectedIcon = display.newSprite("views/rolelist/pic_role_selected.png")
      self:addNode(self.m_SelectedIcon, 10)
    end
    self.m_SelectedIcon:setVisible(true)
    self.m_HeadIcon._BgIcon:setOpacity(255)
    self.m_HeadIcon._HeadIcon:setOpacity(255)
    self:SetTouchState(true, scaleAction)
  else
    if self.m_SelectedIcon ~= nil then
      self.m_SelectedIcon:setVisible(false)
    end
    self.m_HeadIcon._BgIcon:setOpacity(150)
    self.m_HeadIcon._HeadIcon:setOpacity(150)
    self:SetTouchState(false, scaleAction)
  end
end
function CZuoqiSkillHeadItem:OnClicked()
  if self.m_ClickHandler then
    self.m_ClickHandler(self:getId())
  end
end
function CZuoqiSkillHeadItem:onCleanup()
  self.m_ClickHandler = nil
end
local CZuoqiSkillItem = class(".CZuoqiSkillItem", CcsSubView)
function CZuoqiSkillItem:ctor(skillId, skillName, skillAttr, listener)
  CZuoqiSkillItem.super.ctor(self, "views/zuoqi_skill_listitem.json")
  self.m_SkillId = skillId
  self.m_SkillAttr = skillAttr
  self.m_Listener = listener
  local btnBatchListener = {
    btn_detail = {
      listener = handler(self, self.OnBtn_Detail),
      variName = "btn_detail"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:getNode("txt_skillname"):setText(skillName)
end
function CZuoqiSkillItem:OnBtn_Detail(btnObj, touchType)
  if self.m_Listener then
    self.m_Listener(self.m_SkillId)
  end
end
function CZuoqiSkillItem:GetItemSkillId()
  return self.m_SkillId
end
function CZuoqiSkillItem:SetState(hasStudy)
  if hasStudy then
    self:getNode("txt_state"):setText("(已学)")
  else
    self:getNode("txt_state"):setText(string.format("(%s)", self.m_SkillAttr))
  end
end
function CZuoqiSkillItem:setSelected(isel)
  self.btn_detail:setTouchEnabled(not isel)
  self.btn_detail:setBright(not isel)
end
function CZuoqiSkillItem:Clear()
  self.m_Listener = nil
end
CZuoqiSkill = class(".CZuoqiSkill", CcsSubView)
function CZuoqiSkill:ctor(para)
  local curZuoqiId = para.curZqId
  local curSkillId = para.curSkillId
  CZuoqiSkill.super.ctor(self, "views/zuoqi_skill.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_study = {
      listener = handler(self, self.OnBtn_StudySkill),
      variName = "btn_study"
    },
    btn_forget = {
      listener = handler(self, self.OnBtn_ChangeSkill),
      variName = "btn_forget"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.pagebase = self:getNode("pagebase")
  self.pageskill = self:getNode("pageskill")
  self.skilllist = self:getNode("skilllist")
  self.title_skill = self:getNode("title_skill")
  self.skilldesc = self:getNode("skilldesc")
  self.skillfunc = self:getNode("skillfunc")
  self.skilltip = self:getNode("skilltip")
  self:getNode("text_cost"):setText(string.format("%d", data_Variables.ZuoqiLearnSkillCostCoin or 200000))
  self:InitSkillView()
  self.m_CurSelSkill = curSkillId or 1
  self.m_SkillItems = {}
  self:LoadAllZuoqi(curZuoqiId)
  self:UpdateSkillList()
  self:ListenMessage(MsgID_PlayerInfo)
end
function CZuoqiSkill:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_ZuoqiUpdate then
    local param = arg[1]
    local myZuoqi = self.m_ZuoqiHeadList[self.m_CurChooseZuoQi]
    local zqId = myZuoqi:getId()
    if zqId == param.zuoqiId then
      local proTable = param.pro
      if proTable[PROPERTY_ZUOQI_SKILLLIST] ~= nil then
        self:SelectZuoqi(zqId)
      end
    end
  end
end
function CZuoqiSkill:LoadAllZuoqi(curZuoqiId)
  self.m_ZuoqiHeadList = {}
  local myZuoqiList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_ZUOQI)
  local _sortZQFunc = function(a, b)
    local zqIns_a = g_LocalPlayer:getObjById(a)
    local zqIns_b = g_LocalPlayer:getObjById(b)
    if zqIns_a == nil then
      return false
    elseif zqIns_b == nil then
      return true
    else
      local typeId_a = zqIns_a:getTypeId()
      local typeId_b = zqIns_b:getTypeId()
      if typeId_a ~= typeId_b then
        return typeId_a < typeId_b
      else
        return a < b
      end
    end
  end
  table.sort(myZuoqiList, _sortZQFunc)
  local firstZq, curZQId
  for index = 1, 6 do
    local zqpos = self:getNode(string.format("zqpos_%d", index))
    zqpos:setVisible(false)
    local zqId = myZuoqiList[index]
    if zqId ~= nil then
      local zqIns = g_LocalPlayer:getObjById(zqId)
      local parent = zqpos:getParent()
      local zOrder = zqpos:getZOrder()
      local x, y = zqpos:getPosition()
      local size = zqpos:getContentSize()
      local zqTypeId = zqIns:getTypeId()
      local zqItem = CZuoqiSkillHeadItem.new(zqId, zqTypeId, handler(self, self.SelectZuoqi), size)
      zqItem:setPosition(ccp(x + size.width / 2, y + size.height / 2))
      parent:addChild(zqItem)
      self.m_ZuoqiHeadList[zqId] = zqItem
      if curZuoqiId == zqId then
        curZQId = curZuoqiId
      end
      if firstZq == nil then
        firstZq = zqId
      end
    end
  end
  if curZQId ~= nil then
    self:SelectZuoqi(curZQId, false)
  elseif firstZq ~= nil then
    self:SelectZuoqi(firstZq, false)
  end
end
function CZuoqiSkill:UpdateSkillList()
  self.skilllist:removeAllItems()
  self.m_SkillItems = {}
  local zuoqi = self:GetCurrZuoqiIns()
  if zuoqi == nil then
    return
  end
  local learnSkill = {}
  local learnNum = 0
  local skillList = zuoqi:getProperty(PROPERTY_ZUOQI_SKILLLIST)
  if skillList ~= 0 then
    for _, skillId in pairs(skillList) do
      learnSkill[skillId] = true
      learnNum = learnNum + 1
    end
  end
  for skillId, _ in pairs(learnSkill) do
    local skillData = data_ZuoqiSkill[skillId]
    if skillData then
      local skillItem = CZuoqiSkillItem.new(skillId, skillData.name, skillData.attr, handler(self, self.OnClickSkill))
      self.skilllist:pushBackCustomItem(skillItem.getUINode())
      self.m_SkillItems[skillId] = skillItem
    end
  end
  if learnNum < 2 then
    for skillId, skillData in ipairs(data_ZuoqiSkill) do
      if learnSkill[skillId] ~= true then
        local skillData = data_ZuoqiSkill[skillId]
        if skillData then
          local skillItem = CZuoqiSkillItem.new(skillId, skillData.name, skillData.attr, handler(self, self.OnClickSkill))
          self.skilllist:pushBackCustomItem(skillItem.getUINode())
          self.m_SkillItems[skillId] = skillItem
        end
      end
    end
  end
  for skillId, skillItem in pairs(self.m_SkillItems) do
    skillItem:SetState(learnSkill[skillId] == true)
  end
  self:updateSkillBtnState()
  self.skilllist:sizeChangedForShowMoreTips()
end
function CZuoqiSkill:SelectZuoqi(zqId, scaleAction)
  if scaleAction == nil then
    scaleAction = true
  end
  local existFlag = false
  for zid, head in pairs(self.m_ZuoqiHeadList) do
    head:SetSelected(zid == zqId, scaleAction)
    if zid == zqId then
      existFlag = true
    end
  end
  if not existFlag then
    print("------>>坐骑异常！找不到需要选中的坐骑", zqId)
    for zid, head in pairs(self.m_ZuoqiHeadList) do
      head:SetSelected(zid == self.m_CurChooseZuoQi, scaleAction)
    end
    return
  end
  self.m_CurChooseZuoQi = zqId
  local showSkillId = 1
  local zuoqi = self:GetCurrZuoqiIns()
  if zuoqi ~= nil then
    local learnSkill = {}
    local learnNum = 0
    local skillList = zuoqi:getProperty(PROPERTY_ZUOQI_SKILLLIST)
    if skillList ~= 0 then
      for _, skillId in pairs(skillList) do
        showSkillId = skillId
        break
      end
    end
  end
  self.m_CurSelSkill = showSkillId
  self:ReflushBaseInfo()
  self:ReloadSkillView()
end
function CZuoqiSkill:ReflushBaseInfo()
  local zuoqi = self:GetCurrZuoqiIns()
  if zuoqi == nil then
    return
  end
  self:UpdateSkillList()
end
function CZuoqiSkill:GetCurrZuoqiIns()
  local zqHead = self.m_ZuoqiHeadList[self.m_CurChooseZuoQi]
  local zqId = zqHead:getId()
  return g_LocalPlayer:getObjById(zqId)
end
function CZuoqiSkill:InitSkillView()
end
function CZuoqiSkill:ReloadSkillView()
  local zqHead = self.m_ZuoqiHeadList[self.m_CurChooseZuoQi]
  local zqId = zqHead:getId()
  local skillData = data_ZuoqiSkill[self.m_CurSelSkill]
  self.title_skill:setText(skillData.name)
  self.skilldesc:setText(skillData.desc)
  self.skilltip:setText(skillData.tip)
  local desc = ""
  local info = g_LocalPlayer:getZQSkillData(zqId, self.m_CurSelSkill)
  for _, proName in ipairs(ZQSKILL_ADDPRO_DESC_ORDERDICT) do
    local value = info[proName]
    local tableKey = ZQ_ROLEPRO_2_SKILL[proName]
    local skillTable = data_ZuoqiSkill[self.m_CurSelSkill]
    if value ~= nil and skillTable and tableKey and skillTable[tableKey] and skillTable[tableKey] > 0 then
      local d = ZQSKILL_ADDPRO_DESC_DICT[proName] or ""
      if proName == PROPERTY_KXIXUE then
        desc = string.format("%s%s%d\n", desc, d, math.abs(value))
      else
        desc = string.format("%s%s%s%%\n", desc, d, Value2Str(math.abs(value) * 100, 1))
      end
    end
  end
  self.skillfunc:setText(desc)
  local hasStudy = false
  local zuoqi = self:GetCurrZuoqiIns()
  local skillList = zuoqi:getProperty(PROPERTY_ZUOQI_SKILLLIST)
  if type(skillList) == "table" then
    for _, skillId in pairs(skillList) do
      if skillId == self.m_CurSelSkill then
        hasStudy = true
        break
      end
    end
  end
  if hasStudy then
    self:ShowStudyBtn(false)
  else
    self:ShowStudyBtn(true)
  end
end
function CZuoqiSkill:ShowStudyBtn(ishow)
  for _, ctrname in pairs({
    "title_cost",
    "cost_bg",
    "text_cost",
    "icon_coin"
  }) do
    self:getNode(ctrname):setVisible(ishow)
  end
  self.btn_study:setVisible(ishow)
  self.btn_study:setTouchEnabled(ishow)
  self.btn_forget:setVisible(not ishow)
  self.btn_forget:setTouchEnabled(not ishow)
  self:getNode("tippoint10"):setVisible(false)
  self:getNode("changetips"):setVisible(false)
end
function CZuoqiSkill:updateSkillBtnState()
  for skillId, obj in pairs(self.m_SkillItems) do
    obj:setSelected(skillId == self.m_CurSelSkill)
  end
end
function CZuoqiSkill:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CZuoqiSkill:OnClickSkill(skillId)
  if self.m_CurSelSkill == skillId then
    return
  end
  self.m_CurSelSkill = skillId
  self:updateSkillBtnState()
  self:ReloadSkillView()
end
function CZuoqiSkill:OnBtn_StudySkill(btnObj, touchType)
  local zuoqi = self:GetCurrZuoqiIns()
  local skillNumLimit = CalculateZuoqiSkillNumLimit()
  local skillNum = 0
  local skillList = zuoqi:getProperty(PROPERTY_ZUOQI_SKILLLIST)
  if skillList == 0 then
    skillList = {}
  end
  skillNum = #skillList
  if skillNumLimit <= skillNum then
    local tempPop = CPopWarning.new({
      title = "提示",
      text = string.format("该坐骑已学会了%d个技能，只能更换技能", skillNum),
      confirmText = "知道了"
    })
    tempPop:OnlyShowConfirmBtn()
    tempPop:ShowCloseBtn(false)
    return
  end
  local zqHead = self.m_ZuoqiHeadList[self.m_CurChooseZuoQi]
  local zqId = zqHead:getId()
  self.m_RecordZuoqiSkillInfo = {
    zqId,
    DeepCopyTable(skillList)
  }
  netsend.netbaseptc.requestZuoqiLearnSkill(zqId, self.m_CurSelSkill)
end
function CZuoqiSkill:CheckExistNewSkill(zqId)
  if self.m_RecordZuoqiSkillInfo == nil then
    return
  end
  if self.m_RecordZuoqiSkillInfo[1] == zqId then
    local oldSkillList = self.m_RecordZuoqiSkillInfo[2]
    local zuoqi = g_LocalPlayer:getObjById(zqId)
    local skillList = zuoqi:getProperty(PROPERTY_ZUOQI_SKILLLIST)
    local newSkillId
    for _, skillId in pairs(skillList) do
      local iNew = true
      for _, sId in pairs(oldSkillList) do
        if skillId == sId then
          iNew = false
          break
        end
      end
      if iNew then
        newSkillId = skillId
        break
      end
    end
    if newSkillId ~= nil then
      local tempPop = CPopWarning.new({
        title = "提示",
        text = string.format("该坐骑学会了 %s", data_getZuoqiSkillName(newSkillId)),
        confirmText = "知道了"
      })
      tempPop:OnlyShowConfirmBtn()
      tempPop:ShowCloseBtn(false)
    end
  end
end
function CZuoqiSkill:OnBtn_ChangeSkill(btnObj, touchType)
  local zqHead = self.m_ZuoqiHeadList[self.m_CurChooseZuoQi]
  local zqId = zqHead:getId()
  ShowZuoqiChangeSkillDlg(zqId, self.m_CurSelSkill)
end
function CZuoqiSkill:Clear()
end
function ShowZuoqiSkillDlg(zqId)
  local myZuoqiList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_ZUOQI)
  if #myZuoqiList <= 0 then
    ShowNotifyTips("等你有坐骑了再来找我吧")
  else
    local para = {}
    local viewObj = CZuoqiSkill.new(para)
    getCurSceneView():addSubView({
      subView = viewObj,
      zOrder = MainUISceneZOrder.popView
    })
    if zqId ~= nil then
      viewObj:SelectZuoqi(zqId)
    end
  end
end
