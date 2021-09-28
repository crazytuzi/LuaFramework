local guideFuncs = {
  [102] = function()
    getCurSceneView():addSubView({
      subView = CHuobanShow.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  end,
  [104] = function()
    getCurSceneView():addSubView({
      subView = CSkillShow.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  end,
  [106] = function()
    getCurSceneView():addSubView({
      subView = CZuoqiShow.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  end,
  [107] = function()
    ShowBattlePvpDlg()
  end,
  [110] = function()
    local view = settingDlg.new()
    getCurSceneView():addSubView({
      subView = view,
      zOrder = MainUISceneZOrder.menuView
    })
    view:ShowSetPoint()
  end,
  [111] = function()
    getCurSceneView():addSubView({
      subView = CZuoqiShow.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  end,
  [112] = function()
    local hId = g_LocalPlayer:getMainHeroId()
    local itemId
    local heroObj = g_LocalPlayer:getObjById(hId)
    if heroObj then
      for _, tempPos in ipairs({
        ITEM_DEF_EQPT_POS_WUQI,
        ITEM_DEF_EQPT_POS_TOUKUI,
        ITEM_DEF_EQPT_POS_YIFU,
        ITEM_DEF_EQPT_POS_XIEZI,
        ITEM_DEF_EQPT_POS_XIANGLIAN,
        ITEM_DEF_EQPT_POS_YAODAI,
        ITEM_DEF_EQPT_POS_GUANJIAN,
        ITEM_DEF_EQPT_POS_CHIBANG,
        ITEM_DEF_EQPT_POS_MIANJU,
        ITEM_DEF_EQPT_POS_PIFENG
      }) do
        local itemObj = heroObj:GetEqptByPos(tempPos)
        if itemObj then
          if largeType == ITEM_LARGE_TYPE_SENIOREQPT then
            if lv < ITEM_LARGE_TYPE_SENIOREQPT_MaxLv then
              itemId = itemObj:getObjId()
              break
            end
          elseif largeType == ITEM_LARGE_TYPE_XIANQI and lv < ITEM_LARGE_TYPE_XIANQI_MaxLv then
            itemId = itemObj:getObjId()
            break
          end
        end
      end
    end
    getCurSceneView():addSubView({
      subView = CMainRoleView.new(),
      zOrder = MainUISceneZOrder.menuView
    })
    if itemId ~= nil then
      getCurSceneView():addSubView({
        subView = CZhuangbeiShow.new({
          InitItemId = itemId,
          InitRoleId = hId,
          InitUpgradeType = Eqpt_Upgrade_CreateType
        }),
        zOrder = MainUISceneZOrder.menuView
      })
    end
  end,
  [113] = function()
    local hId = g_LocalPlayer:getMainHeroId()
    local itemId
    local heroObj = g_LocalPlayer:getObjById(hId)
    if heroObj then
      for _, tempPos in ipairs({
        ITEM_DEF_EQPT_POS_WUQI,
        ITEM_DEF_EQPT_POS_TOUKUI,
        ITEM_DEF_EQPT_POS_YIFU,
        ITEM_DEF_EQPT_POS_XIEZI,
        ITEM_DEF_EQPT_POS_XIANGLIAN,
        ITEM_DEF_EQPT_POS_YAODAI,
        ITEM_DEF_EQPT_POS_GUANJIAN,
        ITEM_DEF_EQPT_POS_CHIBANG,
        ITEM_DEF_EQPT_POS_MIANJU,
        ITEM_DEF_EQPT_POS_PIFENG
      }) do
        local itemObj = heroObj:GetEqptByPos(tempPos)
        if itemObj then
          local largeType = itemObj:getType()
          if largeType == ITEM_LARGE_TYPE_SENIOREQPT or largeType == ITEM_LARGE_TYPE_XIANQI or largeType == ITEM_LARGE_TYPE_EQPT then
            itemId = itemObj:getObjId()
            break
          end
        end
      end
    end
    getCurSceneView():addSubView({
      subView = CMainRoleView.new(),
      zOrder = MainUISceneZOrder.menuView
    })
    if itemId ~= nil then
      getCurSceneView():addSubView({
        subView = CZhuangbeiShow.new({
          InitItemId = itemId,
          InitRoleId = hId,
          InitUpgradeType = Eqpt_Upgrade_LianhuaType
        }),
        zOrder = MainUISceneZOrder.menuView
      })
    end
  end,
  [114] = function()
    getCurSceneView():addSubView({
      subView = CPetList.new(PetShow_InitShow_TuJianView),
      zOrder = MainUISceneZOrder.menuView
    })
  end,
  [115] = function()
    getCurSceneView():addSubView({
      subView = CHuobanShow.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  end,
  [116] = function()
    getCurSceneView():addSubView({
      subView = CCreateZhuangbei.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  end,
  [117] = function()
    local hId = g_LocalPlayer:getMainHeroId()
    local itemId
    local heroObj = g_LocalPlayer:getObjById(hId)
    if heroObj then
      for _, tempPos in ipairs({
        ITEM_DEF_EQPT_POS_WUQI,
        ITEM_DEF_EQPT_POS_TOUKUI,
        ITEM_DEF_EQPT_POS_YIFU,
        ITEM_DEF_EQPT_POS_XIEZI,
        ITEM_DEF_EQPT_POS_XIANGLIAN,
        ITEM_DEF_EQPT_POS_YAODAI,
        ITEM_DEF_EQPT_POS_GUANJIAN,
        ITEM_DEF_EQPT_POS_CHIBANG,
        ITEM_DEF_EQPT_POS_MIANJU,
        ITEM_DEF_EQPT_POS_PIFENG
      }) do
        local itemObj = heroObj:GetEqptByPos(tempPos)
        if itemObj then
          local holeNum = itemObj:getProperty(ITME_PRO_EQPT_HOLENUM)
          local bsNum = itemObj:getProperty(ITME_PRO_EQPT_BAOSHINUM)
          if holeNum ~= nil and bsNum ~= nil and holeNum > bsNum then
            itemId = itemObj:getObjId()
            break
          end
        end
      end
    end
    getCurSceneView():addSubView({
      subView = CMainRoleView.new(),
      zOrder = MainUISceneZOrder.menuView
    })
    if itemId ~= nil then
      getCurSceneView():addSubView({
        subView = CZhuangbeiShow.new({
          InitItemId = itemId,
          InitRoleId = hId,
          InitUpgradeType = Eqpt_Upgrade_QianghuaType
        }),
        zOrder = MainUISceneZOrder.menuView
      })
    end
  end,
  [119] = function()
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Shaofa)
    if openFlag == false then
      if noOpenType == OPEN_FUNC_Type_Gray then
        ShowNotifyTips(tips)
      end
      return
    end
    getCurSceneView():addSubView({
      subView = CSkillShow.new({InitSkillShow = SkillShow_LifeView}),
      zOrder = MainUISceneZOrder.menuView
    })
  end
}
function MissionGuideFuncStart(guideId)
  local npcId
  local guideData = data_GuideDef[guideId]
  if guideData and guideData.traceType == 1 then
    npcId = guideData.traceParam
  end
  if npcId ~= nil then
    npcId = g_MissionMgr:convertNpcId(npcId)
    g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
      if isSucceed then
        CMainUIScene.Ins:ShowNormalNpcViewById(npcId)
      end
    end)
  else
    local npcfunc = guideFuncs[guideId]
    local t = type(npcfunc)
    if npcfunc == nil then
      printLog("ERROR", "指引[%d]还没有实现!!", npcTypeId)
      return false
    elseif t == "function" then
      npcfunc()
    end
  end
  return true
end
