local GuideMgrExtend = {}
function GuideMgrExtend.extend(object)
  function object:GuideInit()
    self.m_GuideAni = nil
    self.m_GuideAniBaseObjIns = nil
    self.m_UpdateGuideAniPosSave = nil
    self.m_LastGuideMissionInfo = nil
    self.m_CurGuideMissionInfo = nil
    self.m_CurGuideMissionId = nil
    self.m_IsShowCurGuide = false
    self.m_DeleteHandler = nil
    self.m_DelayShowTimeHandler = nil
    self.m_GuideData_Mission = DeepCopyTable(GuideData_Mission)
    self.m_AllRegisterClassObjForGuide = {}
    self.m_AllRegisterClassObjForGuideWithParam = {}
    self.m_IsMapLoadFlagForGuideMgr = false
    self.m_IsHideGuideAniForMapLoading = false
    self.m_TouchDetectForGuideMgr = nil
    self.m_TouchDetectForGuideMgrType = nil
    self.m_IsTouchBeganInSize = false
    self.m_ScheduleHandle = scheduler.scheduleGlobal(function()
      if g_TouchEvent then
        g_TouchEvent:registerGlobalTouchEvent(self, handler(self, self.TouchEventForGuideMgr))
        if self.m_ScheduleHandle then
          scheduler.unscheduleGlobal(self.m_ScheduleHandle)
          self.m_ScheduleHandle = nil
        end
      end
    end, 0.1)
    self.m_UpdateHandler = scheduler.scheduleUpdateGlobal(handler(self, self.updateFrameForGuideMgr))
    self.m_UpdateGuideAniTime = 0.2
    self.m_UpdateGuideAniTimer = self.m_UpdateGuideAniTime
    self.m_UpdateGuideAniHidedTimer = 0.5
    self.m_SaveHideBaseObjForGuide = {}
    self.m_touchEventCoverLayer = nil
  end
  function object:changeWarGuide()
    local temp = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
    local mainHeroIns = g_LocalPlayer:getMainHero()
    if #temp > 0 and mainHeroIns ~= nil then
      local mainHeroPetId = mainHeroIns:getProperty(PROPERTY_PETID)
      if mainHeroPetId > 0 then
        local petObj = g_LocalPlayer:getObjById(mainHeroPetId)
        if self.m_GuideData_Mission[10003].isfinished ~= true and petObj ~= nil then
          local data_table = data_Pet[petObj:getTypeId()]
          if data_table ~= nil and data_table.skills ~= nil and data_table.skills[1] ~= nil and data_table.skills[1] ~= 0 then
            self.m_GuideData_Mission[10003] = DeepCopyTable(GuideData_Pet)
          else
            self.m_GuideData_Mission[10003] = DeepCopyTable(GuideData_Pet_2)
          end
        end
      end
    end
  end
  function object:intGuideData()
    local temp = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
    if #temp > 0 then
      self:changeWarGuide()
      local mitem = self.m_GuideData_Mission[10010]
      if mitem ~= nil then
        self.m_GuideData_Mission[10010].isFinished = true
        for k, v in pairs(mitem) do
          if v and type(v) == "table" then
            self.m_GuideData_Mission[10010][k].guided = true
          end
        end
      end
    end
    local temp = g_LocalPlayer:getAllRoleIds(LOGICTYPE_HERO) or {}
    if #temp > 1 then
      local mitem = self.m_GuideData_Mission[10017]
      if mitem ~= nil then
        self.m_GuideData_Mission[10017].isFinished = true
        for k, v in pairs(mitem) do
          if v and type(v) == "table" then
            self.m_GuideData_Mission[10017][k].guided = true
          end
        end
      end
    end
    dump(self.m_GuideData_Mission)
    object:flushCurGuideShow()
  end
  function object:addTouchEventCoverLayer(targetObj)
    if targetObj == nil then
      return
    end
    if self.m_touchEventCoverLayer then
      self.m_touchEventCoverLayer:removeSelf()
    end
    self.m_touchEventCoverLayer = CCLayerColor:create(ccc4(255, 0, 0, 180))
    self.m_touchEventCoverLayer:setContentSize(CCSizeMake(display.width, display.height))
  end
  function object:ClearGuideExtend()
    self:delGuideAni()
    if g_TouchEvent then
      g_TouchEvent:unRegisterGlobalTouchEvent(self)
    end
    if self.m_UpdateHandler then
      scheduler.unscheduleGlobal(self.m_UpdateHandler)
      self.m_UpdateHandler = nil
    end
    if self.m_ScheduleHandle ~= nil then
      scheduler.unscheduleGlobal(self.m_ScheduleHandle)
      self.m_ScheduleHandle = nil
    end
  end
  function object:MapLoadMessageForGuide(msgSID, ...)
    if msgSID == MsgID_MapLoading_WillLoad then
      self.m_IsMapLoadFlagForGuideMgr = true
      self:detectGuideHideForMapLoading()
    elseif msgSID == MsgID_MapLoading_Finished then
      self.m_IsMapLoadFlagForGuideMgr = false
      scheduler.performWithDelayGlobal(function()
        self:detectGuideShowForMapLoading()
      end, 0.1)
    end
  end
  function object:updateFrameForGuideMgr(dt)
    if self.m_CurGuideMissionId ~= nil then
      self.m_UpdateGuideAniTimer = self.m_UpdateGuideAniTimer - dt
      if self.m_UpdateGuideAniTimer <= 0 then
        self.m_UpdateGuideAniTimer = self.m_UpdateGuideAniTime
        if self.m_IsShowCurGuide == true and self.m_GuideAniBaseObjIns ~= nil and self.m_GuideAni ~= nil then
          local isHide = self:isAniObjHide(self.m_GuideAniBaseObjIns, self.m_GuideAniBaseObjIns.__guide_parent_className)
          if isHide == false then
            local x, y = self.m_UpdateGuideAniPosSave[1], self.m_UpdateGuideAniPosSave[2]
            local p1 = self.m_GuideAniBaseObjIns:convertToWorldSpaceAR(cc.p(0, 0))
            local ax, ay = self.m_GuideAni:getPosition()
            local cs = self.m_GuideAniBaseObjIns:getContentSize()
            if self.m_txtani then
              self.m_txtani:setPosition(cc.p(ax + p1.x - x, ay + p1.y - y))
            end
            self.m_GuideAni:setPosition(cc.p(ax + p1.x - x, ay + p1.y - y))
            self.m_UpdateGuideAniPosSave = {
              p1.x,
              p1.y
            }
            if self.m_GuideAniBaseObjIns.__guide_parent_className == "CMissionItemInMainView" and g_CMainMenuHandler ~= nil and g_CMainMenuHandler.list_mission ~= nil then
              local imem
              for k = 0, g_CMainMenuHandler.list_mission:getCount() do
                imem = g_CMainMenuHandler.list_mission:getItem(k)
                if imem ~= nil and imem.m_MissionId == self.m_CurGuideMissionId then
                  break
                end
              end
              if imem and GuideData_Mission[imem.m_MissionId] ~= nil then
                local mpos = g_CMainMenuHandler.list_mission:convertToWorldSpaceAR(cc.p(0, 0))
                local msize = g_CMainMenuHandler.list_mission:getSize()
                local misize = self.m_GuideAni:getContentSize()
                if mpos.y + msize.height > ay + p1.y - y + misize.height / 2 and ay + p1.y - y - misize.height / 2 > mpos.y then
                  self.m_GuideAni:setVisible(true)
                  if self.m_txtani then
                    self.m_txtani:setVisible(true)
                  end
                else
                  self.m_GuideAni:setVisible(false)
                  if self.m_txtani then
                    self.m_txtani:setVisible(false)
                  end
                end
              end
            end
          elseif self.m_CurGuideMissionInfo then
            local mid = self.m_CurGuideMissionInfo[1]
            local idx = self.m_CurGuideMissionInfo[2]
            local data = self:getGuideDataWithMission(mid, idx)
            if data then
              local className = data.param.className
              local d = self.m_SaveHideBaseObjForGuide[className]
              if d == nil then
                d = {}
                self.m_SaveHideBaseObjForGuide[className] = d
              end
              d[#d + 1] = {
                self.m_GuideAniBaseObjIns
              }
            end
            self:flushCurGuideShow()
          end
        elseif self.m_IsShowCurGuide == false then
          self:flushCurGuideShow()
        end
      end
      self.m_UpdateGuideAniHidedTimer = self.m_UpdateGuideAniHidedTimer - dt
      if 0 >= self.m_UpdateGuideAniHidedTimer then
        self.m_UpdateGuideAniHidedTimer = 0.5
        for k, objInses in pairs(self.m_SaveHideBaseObjForGuide) do
          for i, objIns in ipairs(objInses) do
            if self:isAniObjHide(objIns, k) == false then
              self:flushCurGuideShow()
              break
            end
          end
        end
      end
    end
  end
  function object:isAniObjHide(aniObj, className)
    if aniObj == nil then
      return false
    end
    if className == "CMainMenu" and g_CMainMenuHandler and g_CMainMenuHandler.m_IsNewBtnAction then
      return true
    end
    if aniObj.isEnabled and false == aniObj:isEnabled() then
      return true
    end
    if aniObj.isVisible then
      if false == aniObj:isVisible() then
        return true
      end
      local p = aniObj:getParent()
      while true do
        if not p or p.isVisible == nil then
          break
        end
        if p:isVisible() == false then
          return true
        end
        p = p:getParent()
      end
    end
    return false
  end
  function object:TouchEventForGuideMgr(name, x, y, prevX, prevY)
    if self.m_TouchDetectForGuideMgrType == nil or self.m_TouchDetectForGuideMgr == nil then
      self.m_IsTouchBeganInSize = false
      return
    end
    local function isTouchInSize()
      local lx, by, rx, ty
      if self.m_TouchDetectForGuideMgrType == 1 then
        lx, by, rx, ty = unpack(self.m_TouchDetectForGuideMgr, 1, 4)
      else
        local anchorPoint = self.m_TouchDetectForGuideMgr:getAnchorPoint()
        local size
        if self.m_TouchDetectForGuideMgr.getSize then
          size = self.m_TouchDetectForGuideMgr:getSize()
        else
          size = self.m_TouchDetectForGuideMgr:getContentSize()
        end
        local p = self.m_TouchDetectForGuideMgr:convertToWorldSpaceAR(cc.p(0, 0))
        local px = p.x
        local py = p.y
        local ax = anchorPoint.x
        local ay = anchorPoint.y
        lx, by, rx, ty = px - ax * size.width, py - ay * size.height, px + (1 - ax) * size.width, py + (1 - ay) * size.height
      end
      if lx <= x and rx >= x and by <= y and ty >= y then
        return true
      end
      return false
    end
    if name == "began" then
      self.m_IsTouchBeganInSize = isTouchInSize()
    elseif name == "ended" then
      if self.m_IsTouchBeganInSize == true and isTouchInSize() then
        self:dealWithGuideFunc()
        self:hadTouchInZoneForGuideMgr()
      end
      self.m_IsTouchBeganInSize = false
    end
  end
  function object:setTouchDetectPoses(paramType, param)
    if paramType == nil then
      self.m_TouchDetectForGuideMgrType = nil
      self.m_TouchDetectForGuideMgr = nil
    else
      self.m_TouchDetectForGuideMgrType = paramType
      self.m_TouchDetectForGuideMgr = param
    end
  end
  function object:hadTouchInZoneForGuideMgr()
    if self.m_CurGuideMissionInfo then
      dump(self.m_CurGuideMissionInfo)
      self:delLastGuideMission(self.m_CurGuideMissionInfo[1], self.m_CurGuideMissionInfo[2], true)
      self:flushCurGuideShow()
    end
  end
  function object:registerClassObj(classObj, className, param, verifyParam)
    if className == nil then
      className = classObj.__cname
    end
    local allMids = {}
    local idx = 0
    if className ~= nil then
      local mids = GuideData_ClassName[className]
      if mids then
        for i, mid in ipairs(mids) do
          local datas = self.m_GuideData_Mission[mid]
          if datas ~= nil then
            for i, data in ipairs(datas) do
              if data.param.className == className then
                local isReg = false
                if data.param.verifyParam == nil or data.param.verifyParam == verifyParam then
                  if data.param.needMissionId == nil then
                    self.m_AllRegisterClassObjForGuide[className] = classObj
                    isReg = true
                  elseif data.param.needMissionId == param then
                    local d = self.m_AllRegisterClassObjForGuideWithParam[param]
                    if d == nil then
                      self.m_AllRegisterClassObjForGuideWithParam[param] = {}
                      d = self.m_AllRegisterClassObjForGuideWithParam[param]
                    end
                    d[className] = classObj
                    isReg = true
                  end
                end
                allMids[mid] = 1
                idx = idx + 1
              end
            end
          end
        end
      end
    end
    scheduler.performWithDelayGlobal(function()
      if idx > 0 then
        self:flushCurGuideShow()
      end
      if self.m_IsShowCurGuide == false then
        self:showCurGuide()
      end
    end, 0.01)
  end
  function object:unRegisterClassObj(classObj, className, missionId)
    if className == nil then
      className = classObj.__cname
    end
    local isDel = false
    if missionId and self.m_AllRegisterClassObjForGuideWithParam[missionId] and self.m_AllRegisterClassObjForGuideWithParam[missionId][className] then
      self.m_AllRegisterClassObjForGuideWithParam[missionId][className] = nil
      if self.m_CurGuideMissionInfo and self.m_CurGuideMissionInfo[1] == missionId then
        isDel = true
      end
    elseif self.m_AllRegisterClassObjForGuide[className] then
      self.m_AllRegisterClassObjForGuide[className] = nil
      isDel = true
    end
    if isDel then
      self.m_SaveHideBaseObjForGuide[className] = nil
      if self.m_CurGuideMissionInfo then
        local mid = self.m_CurGuideMissionInfo[1]
        local idx = self.m_CurGuideMissionInfo[2]
        local datas = self.m_GuideData_Mission[mid] or {}
        local data = datas[idx]
        if data and data.param.className == className then
          dump(self.m_CurGuideMissionInfo)
          self:delLastGuideMission(mid, idx)
          self.tempGuideInfo = {}
          self:flushCurGuideShow()
        end
      end
    end
  end
  function object:getRegisterClassObj(className, missionId)
    if missionId and self.m_AllRegisterClassObjForGuideWithParam[missionId] and self.m_AllRegisterClassObjForGuideWithParam[missionId][className] then
      return self.m_AllRegisterClassObjForGuideWithParam[missionId][className]
    end
    return self.m_AllRegisterClassObjForGuide[className]
  end
  function object:flushGuideForMissionStart()
    self.m_CurGuideMissionId = nil
  end
  function object:flushGuideForMission(missionId, pro)
    local guideDatas = self.m_GuideData_Mission[missionId]
    if guideDatas == nil or guideDatas.isFinished == true then
      if guideDatas then
      end
      return
    end
    if missionId == 70010 and pro == 1 then
      if guideDatas then
        guideDatas.isFinished = true
      end
      return
    end
    if self.m_CurGuideMissionInfo ~= nil and GuideData_Mission[missionId] == nil and missionId > self.m_CurGuideMissionInfo[1] then
      dump(self.m_CurGuideMissionInfo, "for returned ")
      return
    end
    if GuideData_Mission[missionId] == nil or self.m_CurGuideMissionId ~= nil and missionId > self.m_CurGuideMissionId then
      return
    end
    self.m_CurGuideMissionId = missionId
  end
  function object:flushGuideForMissionEnd()
    self:flushCurGuideShow()
  end
  function object:flushCurGuideShow()
    if self.m_CurGuideMissionId == nil then
      self:HideGuideAni()
      self:setTouchDetectPoses(nil)
      return
    end
    local guideDatas = self.m_GuideData_Mission[self.m_CurGuideMissionId]
    if guideDatas == nil or guideDatas.isFinished == true then
      self.m_CurGuideMissionId = nil
      return
    end
    self.m_LastGuideMissionInfo = self.m_CurGuideMissionInfo
    self.m_CurGuideMissionInfo = nil
    self.m_SaveHideBaseObjForGuide = {}
    local pro = self:getMissionProgress(self.m_CurGuideMissionId)
    for curIdx, guideData in ipairs(guideDatas) do
      local className = guideData.param.className
      local hideObjs
      local guideType = guideData.guideType
      local guideBaseObj = self:getRegisterClassObj(className, guideData.param.needMissionId)
      if pro == guideData.param.pro and guideBaseObj ~= nil and (guideData.showOnce ~= true or guideData.guided ~= true) then
        local isContinue = false
        if self.m_CurGuideMissionId == 70020 and className == "CZhuangbeiShow" and guideBaseObj.m_UpgradeType ~= Eqpt_Upgrade_LianhuaType or self.m_CurGuideMissionId == 70021 and className == "CZhuangbeiShow" and guideBaseObj.m_UpgradeType ~= Eqpt_Upgrade_CreateType then
          isContinue = true
        end
        if className == "CQuickUseBoard" then
          local itemType, itemTypeId = guideBaseObj:getTypeItemid()
          if guideData.itemKind ~= itemType or itemType ~= ITEM_LARGE_TYPE_EQPT and itemTypeId ~= guideData.itemKindId then
            isContinue = true
          end
        end
        if self.m_CurGuideMissionId == 10010 and className == ".CPetList" and guideBaseObj.btn_war and guideBaseObj.btn_war._isWar then
          isContinue = true
          object:delLastGuideMission(10010, curIdx, true)
        end
        if isContinue ~= true then
          local objName = self:getGuideDataObjName(guideData.param.objName)
          if guideType == GuideType_PointObj and guideBaseObj[objName] and self:isAniObjHide(guideBaseObj[objName], className) == true then
            if hideObjs == nil then
              hideObjs = {}
              self.m_SaveHideBaseObjForGuide[className] = hideObjs
            end
            hideObjs[#hideObjs + 1] = guideBaseObj[objName]
          else
            local isRenew = true
            if self.m_CurGuideMissionInfo ~= nil then
              isRenew = false
              local lastmId, lastIdx = self.m_CurGuideMissionInfo[1], self.m_CurGuideMissionInfo[2]
              local newPriority = guideData.priority or -1
              local lastPriority
              local lastData = self:getGuideDataWithMission(lastmId, lastIdx) or {}
              lastPriority = lastData.priority
              if lastPriority == nil then
                lastPriority = -1
              end
              if (newPriority > lastPriority or newPriority == lastPriority and curIdx > lastIdx) and (guideData.guided ~= true or lastData.guided == true) then
                isRenew = true
              end
            end
            if isRenew then
              self.m_CurGuideMissionInfo = {
                self.m_CurGuideMissionId,
                curIdx
              }
              printLog("GuideMgrExtend", "刷新当前需要指引的进度:%s,%s", self.m_CurGuideMissionId, curIdx)
            end
          end
        end
      end
      if guideData.guided ~= true and guideData.mustShow == true then
        break
      end
    end
    if isListEqual(self.m_CurGuideMissionInfo, self.m_LastGuideMissionInfo) == false and self.m_LastGuideMissionInfo then
      dump(self.m_CurGuideMissionInfo)
      self:delLastGuideMission(self.m_LastGuideMissionInfo[1], self.m_LastGuideMissionInfo[2])
    end
    if self.m_IsShowCurGuide == false and self.m_CurGuideMissionInfo ~= nil then
      self.m_IsShowCurGuide = false
      self:showCurGuide()
    end
  end
  function object:delLastGuideMission(missionId, idx, isTouch)
    dump(self.m_CurGuideMissionInfo, "self.m_CurGuideMissionInfo")
    print("删除老的指引:", missionId, idx, isTouch)
    self.m_IsShowCurGuide = false
    local data, guideData = self:getGuideDataWithMission(missionId, idx)
    if data and guideData then
      if data.completeType ~= 1 or isTouch then
        data.guided = true
      end
      if guideData.finishAfterAllShow == true then
        local isAllFinished = true
        for i, _data in ipairs(guideData) do
          if _data.guided ~= true then
            isAllFinished = false
            break
          end
        end
        if isAllFinished then
          guideData.isFinished = true
        end
      end
    end
    self:HideGuideAni()
    self:setTouchDetectPoses(nil)
  end
  function object:showCurGuide()
    if self.m_CurGuideMissionInfo then
      local data = self:getGuideDataWithMission(self.m_CurGuideMissionInfo[1], self.m_CurGuideMissionInfo[2])
      if data then
        data.mid = self.m_CurGuideMissionInfo[1]
        local guideType = data.guideType
        local completeType = data.completeType
        local className = data.param.className
        local dir = data.param.dir
        local delayShowTime = data.delayShowTime
        local viewObj = self:getRegisterClassObj(className, self.m_CurGuideMissionInfo[1])
        local sx, sy
        local x = 0
        local y = 0
        local aniDir, objsize
        if guideType == GuideType_PointObj then
          local objName = self:getGuideDataObjName(data.param.objName)
          if viewObj then
            local objIns = viewObj[objName]
            if objIns == nil and viewObj.getNode then
              objIns = viewObj:getNode(objName)
            end
            if objIns and dir ~= nil then
              if data.aniType == GuideAnimitionTyPe_Ret then
                local size
                if objIns.getSize then
                  size = objIns:getSize()
                else
                  size = objIns:getContentSize()
                end
                objsize = {
                  size.width,
                  size.height
                }
                local anchorPoint = objIns:getAnchorPoint()
                local p = objIns:convertToWorldSpaceAR(cc.p(0, 0))
                x = p.x
                y = p.y
              else
                objsize = {100, 100}
                local p = objIns:convertToWorldSpaceAR(cc.p(0, 0))
                x, y = p.x, p.y
              end
              sx = x
              sy = y
              objIns.__guide_parent_className = className
              self.m_GuideAniBaseObjIns = objIns
              self.m_UpdateGuideAniPosSave = {x, y}
              self.m_UpdateGuideAniTimer = 0
              local anchorPoint = objIns:getAnchorPoint()
              local size
              if objIns.getSize then
                size = objIns:getSize()
              else
                size = objIns:getContentSize()
              end
              if dir == Guide_Dir_Right then
                aniDir = Guide_Dir_Left
              elseif dir == Guide_Dir_Left then
                aniDir = Guide_Dir_Right
              elseif dir == Guide_Dir_Down then
                aniDir = Guide_Dir_Up
              elseif dir == Guide_Dir_Up then
                aniDir = Guide_Dir_Down
              end
              if completeType == 1 then
                self:setTouchDetectPoses(2, objIns)
              else
                self:setTouchDetectPoses(nil)
                elseif guideType == GuideType_PointScene then
                  self.m_GuideAniBaseObjIns = nil
                  local pos = data.param.pos
                  aniDir = dir
                  local posType = type(pos)
                  if posType == "table" and #pos == 2 then
                    sx = pos[1]
                    sy = pos[2]
                  elseif posType == "function" then
                    p = pos()
                    if p then
                      sx = p[1]
                      sy = p[2]
                    end
                  end
                  if completeType == 1 then
                    self:setTouchDetectPoses(1, {
                      0,
                      0,
                      display.width,
                      display.height
                    })
                  else
                    self:setTouchDetectPoses(nil)
                  end
                  objsize = {88, 88}
                end
              end
            end
          else
          end
        if sx ~= nil and sy ~= nil and aniDir ~= nil then
          local deltaPos = data.deltaPos
          if type(deltaPos) == "table" and #deltaPos == 2 then
            sx = sx + deltaPos[1]
            sy = sy + deltaPos[2]
          end
          data.objSize = objsize
          self:setGuideArrowPosAndDir(viewObj, cc.p(sx, sy), aniDir, delayShowTime, data)
          self.m_IsShowCurGuide = true
        end
      end
    end
  end
  function object:flushUI(curData)
    if curData == nil or curData.param == nil then
      return
    end
    local needClose = {
      "CSkillShow",
      "CMainRoleView",
      "CZhuangbeiShow",
      "CShowLifeSkillDetail_pet",
      "CZuoqiShow",
      "CCreateZhuangbei",
      "CHuobanShow",
      "CNewPetAnimation",
      "CPetListDisplay",
      "selectHeroSkill"
    }
    if curData.param.className == "CMissionItemInMainView" and CMainUIScene.Ins then
      for k, v in pairs(needClose) do
        local oldView = CMainUIScene.Ins:getSubViewInSceneByClassName(v)
        if oldView ~= nil then
          oldView:CloseSelf()
        end
      end
    end
  end
  function object:getGuideDataWithMission(missionId, idx)
    local data = self.m_GuideData_Mission[missionId]
    if data then
      return data[idx], data
    end
    return nil
  end
  function object:getGuideDataObjName(objName)
    if type(objName) == "function" then
      return objName()
    else
      return objName
    end
  end
  function object:getGuideAni()
    return self.m_GuideAni
  end
  function object:setGuideArrowPosAndDir(viewObj, pos, dir, delayShowTime, param)
    local sceneNode = getCurSceneView()
    if sceneNode.m_UINode then
      sceneNode = sceneNode.m_UINode
    end
    local p = viewObj
    local addToNode, addToZOrder
    while p do
      if p == sceneNode then
        addToNode = p
        break
      end
      if p.getZOrder then
        addToZOrder = p:getZOrder()
      else
        addToZOrder = 0
      end
      p = p:getParent()
    end
    if addToNode == nil then
      return nil
    end
    if addToZOrder == nil then
      addToZOrder = 0
    end
    if self.m_GuideAni or self.m_txtani then
      self:delGuideAni()
    end
    self.m_GuideAni = GuideArrowAni.new(param)
    self.m_GuideAni:setAnchorPoint(ccp(0, 0))
    local hastext = param.txtparam ~= nil
    if hastext then
      self.m_txtani = self:getTextAni(param)
      self.m_txtani:setPosition(pos)
    end
    local mpos = g_CMainMenuHandler.list_mission:convertToWorldSpaceAR(cc.p(0, 0))
    if addToNode.m_UINode then
      addToNode.m_UINode:addNode(self.m_GuideAni, addToZOrder)
      if hastext and self.m_txtani then
        addToNode.m_UINode:addNode(self.m_txtani, addToZOrder)
      end
    else
      addToNode:addNode(self.m_GuideAni, addToZOrder)
      if hastext and self.m_txtani then
        addToNode:addNode(self.m_txtani, addToZOrder)
      end
    end
    self.eventLayer = self:getEventCoverLayer(param)
    getCurSceneView():addSubView({
      subView = self.eventLayer,
      zOrder = MainUISceneZOrder.GuideSwallowMessage
    })
    self.m_GuideAni:setPosition(pos)
    self.m_GuideAni:setDir(dir)
    if delayShowTime and delayShowTime > 0 then
      if self.m_txtani then
        self.m_txtani:setVisible(false)
      end
      self.m_GuideAni:setVisible(false)
      self.m_DelayShowTimeHandler = scheduler.performWithDelayGlobal(function()
        if self.m_GuideAni then
          self.m_GuideAni:setVisible(true)
          if self.m_txtani then
            self.m_txtani:setVisible(true)
          end
        end
        self:detectGuideHideForMapLoading()
      end, delayShowTime)
    else
      self.m_GuideAni:setVisible(true)
      if self.m_txtani then
        self.m_txtani:setVisible(true)
      end
      self:detectGuideHideForMapLoading()
    end
  end
  function object:getTextAni(param)
    param = param or {}
    local conf = param.txtparam or {}
    local txt = conf.txt or ""
    local align = conf.txtalign or Guide_Dir_Left
    conf.reOffset = conf.reOffset or 0
    if not param.objSize then
      local objsize = {120, 120}
    end
    local offsetx = -1
    local offsetw = 5
    local offseth = 5
    local pofx = conf.ofx or 0
    local pofy = conf.ofy or 0
    local label = CCLabelTTF:create(txt, ITEM_NUM_FONT, 20)
    label:setAnchorPoint(ccp(0.5, 0.5))
    local csize = label:getContentSize()
    local bg = display.newScale9Sprite("views/common/bg/bg_tips_scale_s.png", 4, 4, CCSize(10, 10))
    bg:addChild(label)
    local lbcsize = label:getContentSize()
    local px, py = lbcsize.width + offsetw * 2, lbcsize.height + offseth * 2
    bg:setContentSize(CCSizeMake(px, py))
    label:setPosition(ccp(px * 0.5, py * 0.5))
    local pointer = display.newSprite("views/pic/pic_arrow_right.png")
    local pcs = pointer:getContentSize()
    pcs = CCSizeMake(pcs.width, pcs.height)
    if align == Guide_Dir_Right then
      bg:setAnchorPoint(ccp(0, 0.5))
      bg:setPosition(ccp(offsetx + pcs.width + objsize[1] * 0.5 + pofx, pofy + conf.reOffset))
      pointer:setAnchorPoint(ccp(1, 0.5))
      pointer:setPosition(pcs.width + objsize[1] * 0.5 + pofx, pofy)
      pointer:flipX(true)
    elseif align == Guide_Dir_Up then
      bg:setAnchorPoint(ccp(0.5, 0))
      bg:setPosition(ccp(pofx + conf.reOffset, pofy + offsetx + pcs.height + objsize[2] * 0.5))
      pointer:setAnchorPoint(ccp(0, 0.5))
      pointer:setRotation(90)
      pointer:setPosition(pofx, pofy + pcs.height + objsize[2] * 0.5)
    elseif align == Guide_Dir_Left then
      bg:setAnchorPoint(ccp(1, 0.5))
      bg:setPosition(ccp(pofx - offsetx - pcs.width - objsize[1] * 0.5, pofy + conf.reOffset))
      pointer:setAnchorPoint(ccp(0, 0.5))
      pointer:setPosition(pofx - pcs.width - objsize[1] * 0.5, pofy)
    elseif align == Guide_Dir_Down then
      bg:setAnchorPoint(ccp(0.5, 1))
      bg:setPosition(ccp(pofx + conf.reOffset, pofy - offsetx - pcs.height - objsize[2] * 0.5))
      pointer:setAnchorPoint(ccp(0, 0.5))
      pointer:setRotation(-90)
      pointer:setPosition(pofx, pofy - pcs.height - objsize[2] * 0.5)
    end
    local rootnode = CCNode:create()
    rootnode:addChild(bg)
    rootnode:addChild(pointer)
    return rootnode
  end
  function object:delGuideAni()
    self.m_GuideAniBaseObjIns = nil
    if self.m_GuideAni then
      self.m_GuideAni:removeSelf()
      self.m_GuideAni = nil
    end
    if self.m_txtani then
      self.m_txtani:removeSelf()
      self.m_txtani = nil
    end
    if self.eventLayer then
      self.eventLayer:removeFromParentAndCleanup(true)
      self.eventLayer = nil
    end
  end
  function object:HideGuideAni()
    self:delGuideAni()
  end
  function object:detectGuideHideForMapLoading()
    if self.m_IsMapLoadFlagForGuideMgr and self.m_GuideAni and self.m_GuideAni:isVisible() == true then
      self.m_IsHideGuideAniForMapLoading = true
      self.m_GuideAni:setVisible(false)
      if self.m_txtani then
        self.m_txtani:setVisible(false)
      end
    end
  end
  function object:detectGuideShowForMapLoading()
    if self.m_IsHideGuideAniForMapLoading == true then
      if self.m_GuideAni then
        self.m_GuideAni:setVisible(true)
      end
      if self.m_txtani then
        self.m_txtani:setVisible(true)
      end
      self.m_IsHideGuideAniForMapLoading = false
    end
  end
  function object:getEventCoverLayer(data)
    if data == nil then
      return
    end
    return CGuideSwallowMessage.new(data)
  end
  function object:dealWithGuideFunc()
    if self.eventLayer then
      self.eventLayer:dealWithGuideFunc()
    end
  end
  object:GuideInit()
end
return GuideMgrExtend
