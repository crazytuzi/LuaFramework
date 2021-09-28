CcsUIConfig = {}
local sharedFileUtils = CCFileUtils:sharedFileUtils()
function CcsUIConfig.load(object, uifilePath)
  if g_GUIReader == nil then
    g_GUIReader = GUIReader:shareReader()
  end
  if uifilePath then
    local uiNode
    if uifilePath == "Widget" then
      uiNode = Widget:create()
      uiNode:setAnchorPoint(ccp(0, 0))
      uiNode:ignoreContentAdaptWithSize(false)
      uiNode:setSize(CCSize(display.width, display.height))
      uiNode:setContentSize(CCSize(display.width, display.height))
    else
      local csbFile = uifilePath
      if string.sub(csbFile, -5, -1) == ".json" then
        csbFile = string.sub(csbFile, 1, -6) .. ".csb"
      end
      if sharedFileUtils:isFileExist(sharedFileUtils:fullPathForFilename(csbFile)) then
        uiNode = g_GUIReader:widgetFromBinaryFile(csbFile)
        printLog("CcsUIConfig", "加载二进制文件:%s", csbFile)
      end
      if uiNode == nil then
        uiNode = g_GUIReader:widgetFromJsonFile(uifilePath)
      end
      if uiNode == nil then
        printLog("CcsUIConfig", "打开cocostudio ui配置表出错:%s", uifilePath)
        return
      end
    end
    object.m_UINode = uiNode
  end
  object.m_ButtonGruop = {
    gId = 0,
    group = {}
  }
  function object:getNode(nodeName)
    if object.m_UINode then
      return UIHelper:seekWidgetByName(object.m_UINode, nodeName)
    end
    return nil
  end
  function object:getUIGroup()
    return object.m_UIGroup
  end
  function object:getUINode()
    return object.m_UINode
  end
  function object:adjustClickSize(btn, clickW, clickH, force)
    if btn then
      local bSize = btn:getSize()
      if force == true or clickW > bSize.width and clickH > bSize.height then
        btn:ignoreContentAdaptWithSize(false)
        btn:setSize(CCSize(clickW, clickH))
      end
    end
  end
  function object:addBtnListener(btnName, listener, downSoundEffect, upSoundEffect)
    local btn = object:getNode(btnName)
    if btn and listener then
      if downSoundEffect == nil then
        downSoundEffect = 1
      end
      if upSoundEffect == nil then
        upSoundEffect = 0
      end
      btn:setTouchEnabled(true)
      btn:addTouchEventListener(function(touchObj, t)
        if t == TOUCH_EVENT_BEGAN then
          if downSoundEffect ~= 0 then
            soundManager.playSound(string.format("xiyou/sound/clickbutton_%d.wav", downSoundEffect))
          end
        elseif t == TOUCH_EVENT_ENDED then
          if btn._groupBtn_Id ~= nil then
            object:setGroupBtnSelected(btn)
          end
          if listener then
            if btn.getParent then
              if btn:getParent() ~= nil then
                listener(touchObj, t)
              end
            else
              listener(touchObj, t)
            end
          end
          if upSoundEffect ~= 0 then
            soundManager.playSound(string.format("xiyou/sound/clickbutton_%d.wav", upSoundEffect))
          end
        end
      end)
      object:adjustClickSize(btn, 50, 50)
      if btn.getTitleRender then
        local adjustDatas = Button_Title_Txt_Pos_Adjust[self.__cname]
        if adjustDatas then
          local pos = adjustDatas[btnName]
          if pos then
            btn:setTitleDeltaPos(pos[1], pos[2])
          end
        end
      end
    else
    end
    return btn
  end
  function object:addBatchBtnListener(btnListener)
    for btnName, p in pairs(btnListener) do
      local listener = p.listener
      local variName = p.variName
      local extParam = p.param or {}
      local btn = object:addBtnListener(btnName, listener, unpack(extParam))
      if variName then
        object[variName] = btn
      end
    end
  end
  function object:addBtnSigleSelectGroup(btns, defaultBtn)
    if btns == nil or #btns == 0 then
      return
    end
    local newId = object.m_ButtonGruop.gId
    if newId == nil then
      newId = 0
    end
    newId = newId + 1
    object.m_ButtonGruop.gId = newId
    local group = object.m_ButtonGruop.group
    if group == nil then
      group = {}
      object.m_ButtonGruop.group = group
    end
    local newGroup = {}
    group[newId] = newGroup
    for i, btnInfo in ipairs(btns) do
      local btnIns = btnInfo[1]
      local unSelectedPath = btnInfo[2]
      local selectedColor = btnInfo[3]
      local unselectOff = btnInfo[4]
      local normalPath = btnIns:getNormalFile()
      if unSelectedPath == nil then
        local resPath
        local sidx, eidx = string.find(normalPath, "res/")
        if sidx ~= nil and eidx ~= nil then
          resPath = string.sub(normalPath, eidx + 1)
        else
          resPath = normalPath
        end
        unSelectedPath = resPath
        local l = #unSelectedPath
        if string.sub(unSelectedPath, l - 3) == ".png" then
          unSelectedPath = string.sub(unSelectedPath, 1, l - 4) .. "_unselect.png"
        else
          unSelectedPath = string.sub(unSelectedPath, 1, l - 6) .. "_unselect.plist"
        end
      end
      btnIns._groupBtn_Id = newId
      btnIns._groupBtn_normalPath = normalPath
      if unSelectedPath == nil then
        printLog("CcsUIConfig", "unSelectedPath == nil")
        unSelectedPath = normalPath
      else
        unSelectedPath = sharedFileUtils:fullPathForFilename(unSelectedPath)
        if sharedFileUtils:isFileExist(unSelectedPath) == false then
          unSelectedPath = normalPath
          printLog("CcsUIConfig", "unSelectedPath[%s]not Exist", unSelectedPath)
        end
      end
      btnIns._groupBtn_unSelectedPath = unSelectedPath
      if unselectOff ~= nil then
        btnIns._groupBtn_unSelectedPath_off = unselectOff
        local bx, by = btnIns:getPosition()
        btnIns._groupBtn_InitPos = ccp(bx, by)
      end
      if selectedColor then
        btnIns._groupBtn_selectedColor = selectedColor
        local c = btnIns:getTitleSaveColor()
        btnIns._groupBtn_unSelectedColor = ccc3(c.r, c.g, c.b)
      end
      print("btnIns:getTitleSaveColor():", btnIns:getTitleSaveColor())
      if i == 1 and defaultBtn == nil then
        defaultBtn = btnIns
      end
      newGroup[#newGroup + 1] = btnIns
    end
    self:setGroupBtnSelected(defaultBtn)
    return newId
  end
  function object:setGroupBtnSelected(btnIns)
    if object.m_ButtonGruop == nil or object.m_ButtonGruop.group == nil then
      printLog("ERROR", "按钮组对象为空")
      return
    end
    local gId = btnIns._groupBtn_Id
    local groupBtns = object.m_ButtonGruop.group[gId]
    for i, btn in ipairs(groupBtns) do
      local p, c
      if btn == btnIns then
        p = btn._groupBtn_normalPath
        c = btn._groupBtn_selectedColor
        if btn._groupBtn_unSelectedPath_off ~= nil then
          btn:setPosition(ccp(btn._groupBtn_InitPos.x, btn._groupBtn_InitPos.y))
        end
        btn:enableTitleTxtBold(true)
      else
        p = btn._groupBtn_unSelectedPath
        c = btn._groupBtn_unSelectedColor
        if btn._groupBtn_unSelectedPath_off ~= nil then
          btn:setPosition(ccp(btn._groupBtn_InitPos.x + btnIns._groupBtn_unSelectedPath_off.x, btn._groupBtn_InitPos.y + btnIns._groupBtn_unSelectedPath_off.y))
        end
        btn:enableTitleTxtBold(false)
      end
      if c then
        btn:setTitleColor(c)
      end
      if p ~= nil and p ~= btn:getNormalFile() then
        local l = #p
        if string.sub(p, l - 3) == ".png" then
          btn:loadTextureNormal(p, UI_TEX_TYPE_LOCAL)
        else
          btn:loadTextureNormal(p, UI_TEX_TYPE_PLIST)
        end
      end
    end
  end
  function object:setGroupAllNotSelected(btnIns)
    if object.m_ButtonGruop == nil or object.m_ButtonGruop.group == nil then
      printLog("ERROR", "按钮组对象为空")
      return
    end
    local gId = btnIns._groupBtn_Id
    local groupBtns = object.m_ButtonGruop.group[gId]
    for i, btn in ipairs(groupBtns) do
      local p = btn._groupBtn_unSelectedPath
      local c = btn._groupBtn_unSelectedColor
      if c then
        btn:setTitleColor(c)
      end
      if p ~= nil and p ~= btn:getNormalFile() then
        local l = #p
        if string.sub(p, l - 3) == ".png" then
          btn:loadTextureNormal(p, UI_TEX_TYPE_LOCAL)
        else
          btn:loadTextureNormal(p, UI_TEX_TYPE_PLIST)
        end
      end
      btn:enableTitleTxtBold(false)
    end
  end
  function object:setGroupBtnPosition(btnIns, pos)
    btnIns:setPosition(ccp(pos.x, pos.y))
    btnIns._groupBtn_InitPos = ccp(pos.x, pos.y)
  end
end
