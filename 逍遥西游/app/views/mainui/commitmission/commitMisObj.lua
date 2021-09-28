FUN_TYPE_MISSION = 1
ComitMisObj = class("ComitMisObj", CcsSubView)
function ComitMisObj:ctor(param)
  ComitMisObj.super.ctor(self, "views/commitobject.csb")
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {2}
    },
    btn_commit = {
      listener = handler(self, self.OnBtn_Commit),
      variName = "btn_commit",
      param = {2}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  param = param or {}
  self.m_mid = param.mid or 90003
  self.m_commitListener = param.commitlistener
  self.m_funtype = param.funtype or FUN_TYPE_MISSION
  self.m_ly_itemSource = self:getNode("lay_up")
  self.m_ly_itemCommit = self:getNode("lay_down")
  self.m_ly_itemSource:setVisible(false)
  self.m_ly_itemCommit:setVisible(false)
  self.m_hadSecectItems = {}
  self:setCollectNum(0, 5)
  self:flushItemSource()
  self:flushItemDestination()
end
function ComitMisObj:getMissionItems(missionId)
  if g_MissionMgr then
    local dataTable, missionKind = g_MissionMgr:getMissionData(missionId)
    local missionPro, curParam = g_MissionMgr:getMissionProgress(missionId)
    curParam = curParam or {}
    local dst = g_MissionMgr:getDstData(dataTable, missionPro)
    if dst then
      local result = {}
      local objList = dst.param or {}
      for i, obj in ipairs(objList) do
        local objId, sum = obj[1], obj[2]
        local curNum = 0
        for idx, objListTemp in ipairs(curParam) do
          if objListTemp[1] == objId then
            curNum = objListTemp[2]
            result[objId] = {curnum = curNum, sumnum = sum}
          end
        end
      end
      return result
    end
    dump(curParam, "  ComitMisObj:getMissionItems  ")
  end
end
function ComitMisObj:setCollectNum(cur, total)
  cur = cur or 0
  total = total or 5
  if self.m_collectNum == nil then
    self.m_collectNum = self:getNode("txt_title_commit")
  end
  self.m_collectNum:setText(string.format("递交道具（%d/%d）", cur, total))
end
function ComitMisObj:judgeItemType(objId, misobjid)
  local showBigType = false
  if GetItemTypeByItemTypeId(objId) == ITEM_LARGE_TYPE_LIFEITEM then
    local itemta = GetItemDataByItemTypeId(misobjid)
    local itemtb = GetItemDataByItemTypeId(objId)
    local itematype = GetLifeSkillItemType(misobjid)
    local itembtype = GetLifeSkillItemType(objId)
    if itematype == itembtype and itemta ~= nil and itemtb ~= nil and itemtb[objId].MainCategoryId == itemta[misobjid].MainCategoryId then
      if itematype == LIFESKILL_PRODUCE_RUNE then
        if itemtb[objId].MainCategoryId == 5 then
          showBigType = false
        elseif itemtb[objId].MainCategoryId == 1 or itemtb[objId].MainCategoryId == 2 or itemtb[objId].MainCategoryId == 3 or itemtb[objId].MainCategoryId == 4 or itemtb[objId].MainCategoryId == 6 then
          showBigType = true
        end
      elseif itematype == LIFESKILL_PRODUCE_FOOD then
        if itemtb[objId].MainCategoryId == 2 or itemtb[objId].MainCategoryId == 3 or itemtb[objId].MainCategoryId == 4 or itemtb[objId].MainCategoryId == 5 then
          showBigType = true
        elseif itemtb[objId].MainCategoryId == 1 then
          showBigType = false
        end
      else
        showBigType = false
      end
    end
  end
  return showBigType
end
function ComitMisObj:selectShowItem(itemObj)
  local realNum = itemObj:getProperty(ITEM_PRO_NUM)
  local itemId = itemObj:getObjId()
  local typeid = itemObj:getTypeId()
  local missionitems = self:getMissionItems(self.m_mid) or {}
  self.m_hadSecectItems = self.m_hadSecectItems or {}
  local secectnum = self.m_hadSecectItems[itemId] or 0
  print("=============>>>>> typeid  ", typeid)
  dump(missionitems)
  local dresult = false
  for k, v in pairs(missionitems) do
    local isBigtype = self:judgeItemType(typeid, k)
    if isBigtype or missionitems[typeid] ~= nil then
      dresult = true
      break
    end
  end
  if realNum and realNum - secectnum > 0 and dresult then
    return true
  end
  return false
end
function ComitMisObj:setShowNum(itemObj)
  local realNum = itemObj:getProperty(ITEM_PRO_NUM) or 0
  local itemType = itemObj:getTypeId()
  local itemId = itemObj:getObjId()
  self.m_hadSecectItems = self.m_hadSecectItems or {}
  local secectnum = self.m_hadSecectItems[itemId] or 0
  print(" realNum = ", realNum, "  secectnum= ", secectnum)
  dump(self.m_hadSecectItems, "  ComitMisObj:setShowNum ")
  if realNum < secectnum then
    return 0
  end
  return realNum - secectnum
end
function ComitMisObj:flushItemDestination()
  if self.m_itemDstFrame then
    self.m_itemDstFrame:removeFromParentAndCleanup(true)
    self.m_itemDstFrame = nil
  end
  local param = {
    itemSize = CCSize(85, 85),
    pageLines = 1,
    oneLineNum = 3,
    xySpace = ccp(1, 1),
    pageIconOffY = -10
  }
  self.m_itemDstFrame = CPackageFrame.new(ITEM_PACKAGE_TYPE_ALL, handler(self, self.clickDstItem), nil, param, handler(self, self.selectDstItem), handler(self, self.setDstShowNum), nil, nil, nil, nil, nil, nil)
  local px, py = self.m_ly_itemCommit:getPosition()
  local parent = self.m_ly_itemCommit:getParent()
  local zod = self.m_ly_itemCommit:getZOrder()
  parent:addChild(self.m_itemDstFrame, zod)
  self.m_itemDstFrame:setPosition(ccp(px, py))
  local total = 0
  self.m_hadSecectItems = self.m_hadSecectItems or {}
  local missionItems = self:getMissionItems(self.m_mid) or {}
  for itemid, numinfo in pairs(missionItems) do
    total = total + numinfo.sumnum
  end
  local counter = 0
  for k, v in pairs(self.m_hadSecectItems) do
    counter = counter + v
  end
  self:setCollectNum(counter, total)
end
function ComitMisObj:selectDstItem(itemObj)
  local realNum = itemObj:getProperty(ITEM_PRO_NUM)
  local itemId = itemObj:getObjId()
  local itemType = itemObj:getTypeId()
  self.m_hadSecectItems = self.m_hadSecectItems or {}
  local secectnum = self.m_hadSecectItems[itemId] or 0
  if secectnum > 0 then
    return true
  end
  return false
end
function ComitMisObj:setDstShowNum(itemObj)
  local itemType = itemObj:getTypeId()
  local itemId = itemObj:getObjId()
  self.m_hadSecectItems = self.m_hadSecectItems or {}
  local secectnum = self.m_hadSecectItems[itemId] or 0
  return secectnum
end
function ComitMisObj:clickDstItem(itemObjId)
  local packageItemIns = g_LocalPlayer:GetOneItem(itemObjId)
  self.m_hadSecectItems = self.m_hadSecectItems or {}
  local secectnum = self.m_hadSecectItems[itemObjId] or 0
  if secectnum <= 0 then
    self:flushItemDestination()
    if self.m_itemDstFrame then
      self.m_itemDstFrame:JumpToItemPage(itemObjId, false)
    end
    return
  end
  local params = {
    itemID = itemObjId,
    txt_RightBtn = "移除",
    txt_LeftBtn = "取消",
    txt_numTitle = "移除数量",
    RightBtnTips = "选择数量少于1",
    maxNum = secectnum,
    initNum = 1,
    needClose = 3,
    listener_RightBtn = handler(self, self.removeList),
    listener_LeftBtn = function()
      if self.m_itemDstFrame then
        self.m_itemDstFrame:ClearSelectItem()
      end
    end
  }
  ShowAddItemsView(params)
end
function ComitMisObj:removeList(itemObjId, num)
  local packageItemIns = g_LocalPlayer:GetOneItem(itemObjId)
  local typeId = packageItemIns:getTypeId()
  self.m_hadSecectItems = self.m_hadSecectItems or {}
  local hadsecect = self.m_hadSecectItems[itemObjId] or 0
  if hadsecect == nil or hadsecect <= 0 or num > hadsecect then
    self.m_hadSecectItems[itemObjId] = 0
  else
    self.m_hadSecectItems[itemObjId] = hadsecect - num
  end
  self:flushItemSource()
  self:flushItemDestination()
  if self.m_itemDstFrame then
    self.m_itemDstFrame:JumpToItemPage(itemObjId, false)
  end
  if self.m_itemSourceFrame then
    self.m_itemSourceFrame:JumpToItemPage(itemObjId, false)
  end
end
function ComitMisObj:flushItemSource()
  if self.m_itemSourceFrame then
    self.m_itemSourceFrame:removeFromParentAndCleanup(true)
    self.m_itemSourceFrame = nil
  end
  local param = {
    itemSize = CCSize(85, 85),
    pageLines = 3,
    oneLineNum = 3,
    xySpace = ccp(1, 1),
    pageIconOffY = -12
  }
  self.m_itemSourceFrame = CPackageFrame.new(ITEM_PACKAGE_TYPE_ALL, handler(self, self.clickItem), nil, param, handler(self, self.selectShowItem), handler(self, self.setShowNum), nil, nil, nil, nil, nil, nil)
  local px, py = self.m_ly_itemSource:getPosition()
  local parent = self.m_ly_itemSource:getParent()
  local zod = self.m_ly_itemSource:getZOrder()
  parent:addChild(self.m_itemSourceFrame, zod)
  self.m_itemSourceFrame:setPosition(ccp(px, py))
end
function ComitMisObj:clickItem(itemObjId)
  local packageItemIns = g_LocalPlayer:GetOneItem(itemObjId)
  local typeid = packageItemIns:getTypeId()
  local missionitems = self:getMissionItems(self.m_mid) or {}
  local itemtb = missionitems[packageItemIns:getTypeId()] or {}
  local max = itemtb.sumnum or 0
  self.m_hadSecectItems = self.m_hadSecectItems or {}
  local comitnum = not self.m_hadSecectItems[itemObjId] and 0
  local dresult = false
  bigtypeitem = {}
  local bigsum = 0
  for k, v in pairs(missionitems) do
    local isBigtype = self:judgeItemType(typeid, k)
    if isBigtype then
      dresult = true
      bigsum = bigsum + v.sumnum
      bigtypeitem[#bigtypeitem + 1] = k
    end
  end
  print("=====>>>>>  itemObjId= ", typeid, "    ", dresult, bigsum)
  dump(bigtypeitem)
  local limitnum = max - comitnum
  if dresult then
    local totalCommitnum = 0
    for _, bitemid in pairs(bigtypeitem) do
      for itemid, num in pairs(self.m_hadSecectItems) do
        local tempItemIns = g_LocalPlayer:GetOneItem(itemid)
        local temptypeid = packageItemIns:getTypeId()
        local isBigtype = self:judgeItemType(bitemid, temptypeid)
        print(itemid, " <<=====>>", itemid, isBigtype)
        if isBigtype then
          totalCommitnum = totalCommitnum + num
        end
      end
    end
    print(" ****************    totalCommitnum", totalCommitnum)
    local realNum = packageItemIns:getProperty(ITEM_PRO_NUM)
    for rk, rv in pairs(self.m_hadSecectItems) do
      if rk == itemObjId then
        realNum = realNum - rv
      end
    end
    bigsum = bigsum - totalCommitnum
    limitnum = math.min(bigsum, realNum)
  else
    limitnum = max - comitnum
  end
  print("=====>>>>>  limitnum= ", limitnum, "    ", dresult)
  if limitnum <= 0 then
    ShowNotifyTips("你所选的道具已满足任务需求，请递交")
    self:flushItemSource()
    if self.m_itemSourceFrame then
      self.m_itemSourceFrame:JumpToItemPage(itemObjId, false)
    end
    return
  end
  local params = {
    itemID = itemObjId,
    txt_RightBtn = "选择",
    txt_LeftBtn = "取消",
    txt_numTitle = "选择数量",
    RightBtnTips = "选择数量少于1",
    maxNum = limitnum,
    initNum = 1,
    needClose = 3,
    listener_RightBtn = handler(self, self.addToCommitList),
    listener_LeftBtn = function()
      if self.m_itemSourceFrame then
        self.m_itemSourceFrame:ClearSelectItem()
      end
    end
  }
  ShowAddItemsView(params)
end
function ComitMisObj:addToCommitList(itemObjId, num)
  local packageItemIns = g_LocalPlayer:GetOneItem(itemObjId)
  local typeId = packageItemIns:getTypeId()
  self.m_hadSecectItems = self.m_hadSecectItems or {}
  local hadsecect = self.m_hadSecectItems[itemObjId] or 0
  if hadsecect == nil or hadsecect <= 0 then
    self.m_hadSecectItems[itemObjId] = num
  else
    self.m_hadSecectItems[itemObjId] = hadsecect + num
  end
  self:flushItemSource()
  self:flushItemDestination()
  if self.m_itemDstFrame then
    self.m_itemDstFrame:JumpToItemPage(itemObjId, false)
  end
  if self.m_itemSourceFrame then
    self.m_itemSourceFrame:JumpToItemPage(itemObjId, false)
  end
end
function ComitMisObj:OnBtn_Commit()
  local total = 0
  self.m_hadSecectItems = self.m_hadSecectItems or {}
  local missionItems = self:getMissionItems(self.m_mid) or {}
  for itemid, numinfo in pairs(missionItems) do
    total = total + numinfo.sumnum
  end
  local counter = 0
  for k, v in pairs(self.m_hadSecectItems) do
    counter = counter + v
  end
  print("23333333333333333333333333333333  ", counter, total)
  dump(self.m_hadSecectItems)
  if total > counter then
    ShowNotifyTips(string.format("你所选的数量不足任务需求#<R,>%d#,无法完成任务", total))
    return
  end
  if self.m_commitListener then
    local commitresult = {}
    for k, v in pairs(self.m_hadSecectItems) do
      if k and v > 0 then
        commitresult[#commitresult + 1] = {itemid = k, num = v}
      end
    end
    self.m_commitListener(commitresult)
  end
  self:CloseSelf()
end
function ComitMisObj:OnBtn_Close()
  self:CloseSelf()
end
function ComitMisObj:Clear()
end
function OpenMissionCommitView(param)
  getCurSceneView():addSubView({
    subView = ComitMisObj.new(param),
    zOrder = MainUISceneZOrder.menuView
  })
end
