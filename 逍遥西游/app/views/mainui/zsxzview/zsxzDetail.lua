function ShowZSXZDetail()
  getCurSceneView():addSubView({
    subView = CZSXZDetail.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function GetZSXZText(zsTypeID, zsNum)
  if ZHUANSHENG_ADD_VALUEDICT[zsTypeID] == nil then
    return ""
  end
  local txtDict = {
    "抗中毒",
    "抗昏睡",
    "抗混乱",
    "抗封印",
    "抗火系",
    "抗风系",
    "抗雷系",
    "抗水系",
    "物理吸收率",
    "生命修正",
    "速度修正",
    "法力修正",
    "抗虹吸",
    "抗遗忘",
    "抗哀嚎",
    "抗吸血",
    "速度修正",
    "反震率",
    "反震程度",
    "抗魂石"
  }
  local text = ""
  local moreThan4Flag = #ZHUANSHENG_ADD_VALUEDICT[zsTypeID] > 4
  for index, tData in ipairs(ZHUANSHENG_ADD_VALUEDICT[zsTypeID]) do
    local eNum = tData[2]
    local showType = tData[3]
    local num = data_getRoleRebornValue(zsNum - 1, eNum)
    local numStr = string.format("%.1f%%", Value2Str(math.abs(num) * 100, 1))
    if ZHUANSHENG_ADD_PROName_DICT[eNum] == PROPERTY_ZSKXIXUE or ZHUANSHENG_ADD_PROName_DICT[eNum] == PROPERTY_ZSKNEIDAN then
      numStr = string.format("%d", math.abs(num))
    end
    if num < 0 then
      numStr = string.format("-%s", numStr)
    else
      numStr = string.format("+%s", numStr)
    end
    if index % 2 == 1 then
      text = string.format("%s%s#<W> %s#", text, txtDict[eNum], numStr)
    elseif index == 4 and moreThan4Flag == false then
      text = string.format("%s   %s#<W> %s#", text, txtDict[eNum], numStr)
    else
      text = string.format("%s   %s#<W> %s#\n", text, txtDict[eNum], numStr)
    end
  end
  return text
end
CZSXZDetail = class("CZSXZDetail", CcsSubView)
function CZSXZDetail:ctor(para)
  CZSXZDetail.super.ctor(self, "views/zsxz_detail.json", {isAutoCenter = true, opacityBg = 0})
  local btnBatchListener = {
    btn_zsxz = {
      listener = handler(self, self.OnBtn_ZSXZ),
      variName = "btn_zsxz"
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
function CZSXZDetail:SetData()
  for i = 1, 4 do
    local richTextObjName = string.format("m_RichText%d", i)
    local size = self:getNode(string.format("tips_pos_%d", i)):getContentSize()
    self[richTextObjName] = CRichText.new({
      width = size.width,
      fontSize = 19,
      color = ccc3(255, 196, 98),
      align = CRichText_AlignType_Left
    })
    self:addChild(self[richTextObjName])
  end
  local curZs = g_LocalPlayer:getObjProperty(1, PROPERTY_ZHUANSHENG)
  for i = 1, 4 do
    local text = ""
    local zsText = ""
    if i == 1 then
      zsText = "一转修正"
    elseif i == 2 then
      zsText = "二转修正"
    elseif i == 3 then
      zsText = "三转修正"
    elseif i == 4 then
      zsText = "四转修正"
    end
    if i <= curZs then
      local zsData = g_LocalPlayer:getObjProperty(1, PROPERTY_ZSNUMLIST)
      if zsData == nil or zsData == 0 then
        zsData = {}
      end
      local zsTempData = zsData[i] or {}
      local zsTypeID = zsTempData[1] or 0
      text = GetZSXZText(zsTypeID, i)
      local tempNameList = {
        [MALE_REN_ZS_INDEX] = "(男人)",
        [FEMALE_REN_ZS_INDEX] = "(女人)",
        [MALE_XIAN_ZS_INDEX] = "(男仙)",
        [FEMALE_XIAN_ZS_INDEX] = "(女仙)",
        [MALE_MO_ZS_INDEX] = "(男魔)",
        [FEMALE_MO_ZS_INDEX] = "(女魔)",
        [MALE_GUI_ZS_INDEX] = "(男鬼)",
        [FEMALE_GUI_ZS_INDEX] = "(女鬼)"
      }
      zsText = string.format("%s%s", zsText, tempNameList[zsTypeID] or "")
    else
      text = string.format("#<IRP>##<r:94,g:211,b:207>还没经历%d转，没有转生修正#", i)
    end
    self:getNode(string.format("txt_zs_%d", i)):setText(zsText)
    local richTextObjName = string.format("m_RichText%d", i)
    local tempRichText = self[richTextObjName]
    tempRichText:addRichText(text)
    local h = tempRichText:getContentSize().height
    local x, y = self:getNode(string.format("tips_pos_%d", i)):getPosition()
    local size = self:getNode(string.format("tips_pos_%d", i)):getContentSize()
    tempRichText:setPosition(ccp(x, y + size.height - h))
  end
end
function CZSXZDetail:OnBtn_ZSXZ(obj, t)
  local curZs = g_LocalPlayer:getObjProperty(1, PROPERTY_ZHUANSHENG)
  if curZs <= 0 then
    ShowNotifyTips("还没经历1转，没有转生修正可以转换")
  else
    if g_SettingDlg then
      g_SettingDlg:CloseSelf()
    end
    self:CloseSelf()
    do
      local npcID = 90008
      g_MapMgr:AutoRouteToNpc(npcID, function(isSucceed)
        if isSucceed and CMainUIScene.Ins then
          CMainUIScene.Ins:ShowNormalNpcViewById(npcID)
        end
      end)
    end
  end
end
function CZSXZDetail:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function CZSXZDetail:Clear()
end
