CRebirthShow = class(".CRebirthShow", CcsSubView)
function CRebirthShow:ctor()
  CRebirthShow.super.ctor(self, "views/rebirth1.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_next = {
      listener = handler(self, self.OnBtn_Next),
      variName = "btn_next"
    },
    btn_cancel = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_cancel"
    },
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:SetData()
end
function CRebirthShow:SetData()
  local mainHero = g_LocalPlayer:getMainHero()
  local name = mainHero:getProperty(PROPERTY_NAME)
  self:getNode("txt_namestr"):setText(name)
  local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  local color = NameColor_MainHero[zs]
  if color == nil then
    color = ccc3(255, 255, 255)
  end
  self:getNode("txt_namestr"):setColor(color)
  local typeID = mainHero:getTypeId()
  local race = data_getRoleRace(typeID)
  local gender = data_getRoleGender(typeID)
  local raceText = Def_Role_Name[race] or ""
  self:getNode("txt_racestr"):setText(raceText)
  local shapeID = data_getRoleShape(typeID)
  local tempHead = createHeadIconByShape(shapeID)
  local x, y = self:getNode("pic_headiconbg_1"):getPosition()
  tempHead:setPosition(ccp(x, y + 8))
  self:addNode(tempHead, 2)
  local tempHead = createHeadIconByShape(shapeID)
  local x, y = self:getNode("pic_headiconbg_2"):getPosition()
  tempHead:setPosition(ccp(x, y + 8))
  self:addNode(tempHead, 2)
  self:getNode("txt_ggstr"):setText(tostring(mainHero:getProperty(PROPERTY_GenGu)))
  self:getNode("txt_lxstr"):setText(tostring(mainHero:getProperty(PROPERTY_Lingxing)))
  self:getNode("txt_llstr"):setText(tostring(mainHero:getProperty(PROPERTY_LiLiang)))
  self:getNode("txt_mjstr"):setText(tostring(mainHero:getProperty(PROPERTY_MinJie)))
  local txtDict = {
    "抗中毒     ",
    "抗昏睡     ",
    "抗混乱     ",
    "抗封印     ",
    "抗火系     ",
    "抗风系     ",
    "抗雷系     ",
    "抗水系     ",
    "物理吸收率 ",
    "生命修正   ",
    "速度修正   ",
    "法力修正   ",
    "抗虹吸     ",
    "抗遗忘     ",
    "抗哀嚎     ",
    "抗吸血     ",
    "速度修正   ",
    "反震率     ",
    "反震程度   ",
    "抗魂石     "
  }
  local w = self:getNode("list_cur"):getContentSize().width
  local curKxList = self:getNode("list_cur")
  local curRichText = "#<r:255,g:196,b:98,F:25>抗性修正#\n\n"
  for index, proName in ipairs({
    PROPERTY_ZSKZHONGDU,
    PROPERTY_ZSKHUNSHUI,
    PROPERTY_ZSKHUNLUAN,
    PROPERTY_ZSKFENGYIN,
    PROPERTY_ZSKHUO,
    PROPERTY_ZSKFENG,
    PROPERTY_ZSKLEI,
    PROPERTY_ZSKSHUI,
    PROPERTY_ZSPDEFEND,
    PROPERTY_ZSHP,
    PROPERTY_ZSSP,
    PROPERTY_ZSMP,
    PROPERTY_ZSKZHENSHE,
    PROPERTY_ZSKYIWANG,
    PROPERTY_ZSKAIHAO,
    PROPERTY_ZSKXIXUE,
    PROPERTY_ZSSPXIXUE,
    PROPERTY_ZSFANZHEN,
    PROPERTY_ZSFZCD,
    PROPERTY_ZSKNEIDAN
  }) do
    local value = mainHero:getProperty(proName)
    if value ~= 0 then
      local numStr = ""
      if value < 0 then
        numStr = "-"
      else
        numStr = "+"
      end
      value = math.abs(value)
      if proName == PROPERTY_ZSKNEIDAN or proName == PROPERTY_ZSKXIXUE then
        numStr = string.format("%s%d", numStr, value)
      else
        numStr = string.format("%s%s%%", numStr, Value2Str(value * 100, 1))
      end
      curRichText = curRichText .. string.format("%s  %s\n", txtDict[index], numStr)
    end
  end
  local curRichObj = CRichText.new({
    width = w,
    color = ccc3(79, 48, 26),
    fontSize = 22,
    align = CRichText_AlignType_Center
  })
  curRichObj:addRichText(curRichText)
  curKxList:pushBackCustomItem(curRichObj)
  local tempDict = {}
  if race == RACE_REN then
    if gender == HERO_MALE then
      tempDict[PROPERTY_ZSKHUNSHUI] = data_getRoleRebornValue(zs, 2)
      tempDict[PROPERTY_ZSKHUNLUAN] = data_getRoleRebornValue(zs, 3)
      tempDict[PROPERTY_ZSKFENGYIN] = data_getRoleRebornValue(zs, 4)
    else
      tempDict[PROPERTY_ZSKHUNSHUI] = data_getRoleRebornValue(zs, 2)
      tempDict[PROPERTY_ZSKZHONGDU] = data_getRoleRebornValue(zs, 1)
      tempDict[PROPERTY_ZSKFENGYIN] = data_getRoleRebornValue(zs, 4)
    end
  elseif race == RACE_MO then
    if gender == HERO_MALE then
      tempDict[PROPERTY_ZSHP] = data_getRoleRebornValue(zs, 10)
      tempDict[PROPERTY_ZSSP] = data_getRoleRebornValue(zs, 11)
      tempDict[PROPERTY_ZSMP] = data_getRoleRebornValue(zs, 12)
    else
      tempDict[PROPERTY_ZSHP] = data_getRoleRebornValue(zs, 10)
      tempDict[PROPERTY_ZSMP] = data_getRoleRebornValue(zs, 12)
      tempDict[PROPERTY_ZSPDEFEND] = data_getRoleRebornValue(zs, 9)
      tempDict[PROPERTY_ZSKZHENSHE] = data_getRoleRebornValue(zs, 13)
    end
  elseif race == RACE_XIAN then
    if gender == HERO_MALE then
      tempDict[PROPERTY_ZSKFENG] = data_getRoleRebornValue(zs, 6)
      tempDict[PROPERTY_ZSKSHUI] = data_getRoleRebornValue(zs, 8)
      tempDict[PROPERTY_ZSKLEI] = data_getRoleRebornValue(zs, 7)
    else
      tempDict[PROPERTY_ZSKHUO] = data_getRoleRebornValue(zs, 5)
      tempDict[PROPERTY_ZSKSHUI] = data_getRoleRebornValue(zs, 8)
      tempDict[PROPERTY_ZSKLEI] = data_getRoleRebornValue(zs, 7)
    end
  elseif race == RACE_GUI then
    if gender == HERO_MALE then
      tempDict[PROPERTY_ZSKXIXUE] = data_getRoleRebornValue(zs, 16)
      tempDict[PROPERTY_ZSSPXIXUE] = data_getRoleRebornValue(zs, 17)
      tempDict[PROPERTY_ZSKYIWANG] = data_getRoleRebornValue(zs, 14)
      tempDict[PROPERTY_ZSKAIHAO] = data_getRoleRebornValue(zs, 15)
    else
      tempDict[PROPERTY_ZSFANZHEN] = data_getRoleRebornValue(zs, 18)
      tempDict[PROPERTY_ZSFZCD] = data_getRoleRebornValue(zs, 19)
      tempDict[PROPERTY_ZSKNEIDAN] = data_getRoleRebornValue(zs, 20)
      tempDict[PROPERTY_ZSKYIWANG] = data_getRoleRebornValue(zs, 14)
      tempDict[PROPERTY_ZSKAIHAO] = data_getRoleRebornValue(zs, 15)
    end
  end
  local nextKxList = self:getNode("list_next")
  local nextRichText = "#<r:255,g:196,b:98,F:25>抗性修正#\n\n"
  for index, proName in ipairs({
    PROPERTY_ZSKZHONGDU,
    PROPERTY_ZSKHUNSHUI,
    PROPERTY_ZSKHUNLUAN,
    PROPERTY_ZSKFENGYIN,
    PROPERTY_ZSKHUO,
    PROPERTY_ZSKFENG,
    PROPERTY_ZSKLEI,
    PROPERTY_ZSKSHUI,
    PROPERTY_ZSPDEFEND,
    PROPERTY_ZSHP,
    PROPERTY_ZSSP,
    PROPERTY_ZSMP,
    PROPERTY_ZSKZHENSHE,
    PROPERTY_ZSKYIWANG,
    PROPERTY_ZSKAIHAO,
    PROPERTY_ZSKXIXUE,
    PROPERTY_ZSSPXIXUE,
    PROPERTY_ZSFANZHEN,
    PROPERTY_ZSFZCD,
    PROPERTY_ZSKNEIDAN
  }) do
    local value = mainHero:getProperty(proName) + (tempDict[proName] or 0)
    if value ~= 0 then
      local numStr = ""
      if value < 0 then
        numStr = "-"
      else
        numStr = "+"
      end
      value = math.abs(value)
      if proName == PROPERTY_ZSKNEIDAN or proName == PROPERTY_ZSKXIXUE then
        numStr = string.format("%s%d", numStr, value)
      else
        numStr = string.format("%s%s%%", numStr, Value2Str(value * 100, 1))
      end
      nextRichText = nextRichText .. string.format("%s  %s\n", txtDict[index], numStr)
    end
  end
  local nextRichObj = CRichText.new({
    width = w,
    color = ccc3(79, 48, 26),
    fontSize = 22,
    align = CRichText_AlignType_Center
  })
  nextRichObj:addRichText(nextRichText)
  nextKxList:pushBackCustomItem(nextRichObj)
end
function CRebirthShow:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CRebirthShow:OnBtn_Next(btnObj, touchType)
  self:CloseSelf()
  getCurSceneView():addSubView({
    subView = CRebirthSelectShow.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function CRebirthShow:Clear()
end
