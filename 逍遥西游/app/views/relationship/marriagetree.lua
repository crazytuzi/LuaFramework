marriageTreeItem = class("marriageTreeItem", CcsSubView)
function marriageTreeItem:ctor(info, changeDataFun)
  dump(info, "marriageTreeItem ctor() ")
  self.m_id = info.id
  self.m_target = info.target
  self.m_progress = info.progress
  self.leftime = info.lefttime
  self.m_changeDataFun = changeDataFun
  print("===================>>>>> info.timeoff ", info.timeoff)
  dump(info, " marriageTreeItem:ctor  ")
  if info.timeoff then
    self.leftime = math.floor(self.leftime - info.timeoff)
  end
  if self.leftime < 0 then
    self.leftime = 0
  end
  marriageTreeItem.super.ctor(self, "views/marriage_tree_item.csb", {isAutoCenter = true, opacityBg = 100})
  self:getUINode():setNodeEventEnabled(true)
  self:setTouchEnabled(false)
  self.bg_image = self:getNode("img_bg")
  self.txt_name_up = self:getNode("txt_name_up")
  self.txt_name_down = self:getNode("txt_name_down")
  self.txt_collect_ct = self:getNode("txt_collect_ct")
  self.txt_collect_tt = self:getNode("txt_collect_tt")
  self.txt_collect_ttnum = self:getNode("txt_collect_ttnum")
  self.txt_collect_ctnum = self:getNode("txt_collect_ctnum")
  local male = info.male or {}
  local female = info.female or {}
  self.m_mname = male.name
  self.m_fname = female.name
  self.m_mlv = {
    male.zs,
    male.lv
  }
  self.m_flv = {
    female.zs,
    female.lv
  }
  self.m_state = info.state or 0
  self:flushIteminfo(self.m_mname, self.m_fname, self.m_progress, self.m_target, self.leftime)
  self.timerHandler = scheduler.scheduleGlobal(handler(self, self.timetick), 1)
end
function marriageTreeItem:getItemID()
  return self.m_id
end
function marriageTreeItem:getNames()
  return {
    {
      name = self.m_mname,
      zslv = self.m_mlv
    },
    {
      name = self.m_fname,
      zslv = self.m_flv
    }
  }
end
function marriageTreeItem:flushIteminfo(name1, name2, collecttimes, target, restime)
  if name1 then
    self.m_mname = name1
    self.txt_name_up:setText(name1)
  end
  if name2 then
    self.m_fname = name2
    self.txt_name_down:setText(name2)
  end
  if collecttimes then
    self.m_progress = collecttimes
  end
  if target then
    self.m_target = target
  end
  if restime then
    self.leftime = restime
  end
  local h, m, s = self:convertTime(self.leftime)
  if self.m_state ~= 1 then
    self.txt_collect_ct:setText("已收集祝福")
    self.txt_collect_ctnum:setText(string.format("%d/%d", self.m_progress, self.m_target))
    self.txt_collect_ctnum:setVisible(true)
  else
    self.txt_collect_ct:setText("您已经祝福过他们了")
    self.txt_collect_ctnum:setVisible(false)
  end
  self.txt_collect_tt:setText("剩余时间")
  self.txt_collect_ttnum:setText(string.format("%02d:%02d:%02d", h, m, s))
end
function marriageTreeItem:convertTime(scend)
  if type(scend) ~= "number" or scend <= 0 then
    return 0, 0, 0
  end
  local h = math.floor(scend / 3600)
  local m = math.floor((scend - h * 3600) / 60)
  local s = scend - h * 3600 - m * 60
  return h, m, s
end
function marriageTreeItem:setTouchState(flag)
  if flag then
    self.bg_image:setColor(ccc3(200, 200, 200))
  else
    self.bg_image:setColor(ccc3(255, 255, 255))
  end
end
function marriageTreeItem:setFadeIn()
  local doact = function(obj)
    if obj then
      obj:setOpacity(0)
      obj:runAction(CCFadeIn:create(0.8))
    end
  end
  doact(self.bg_image)
  doact(self.txt_name_up)
  doact(self.txt_name_down)
  doact(self.txt_collect_ct)
  doact(self.txt_collect_tt)
end
function marriageTreeItem:timetick()
  if self.leftime and type(self.leftime) == "number" then
    if self.leftime > 0 then
      self.leftime = self.leftime - 1
      if self.txt_collect_ttnum then
        local h, m, s = self:convertTime(self.leftime)
        self.txt_collect_ttnum:setText(string.format("%02d:%02d:%02d", h, m, s))
      end
    else
      self.leftime = 0
    end
  else
    self.leftime = 0
  end
end
function marriageTreeItem:Clear()
  if self.timerHandler then
    scheduler.unscheduleGlobal(self.timerHandler)
    self.timerHandler = nil
  end
end
CMarriageTreeFrame = class("CMarriageTreeFrame", function()
  return Widget:create()
end)
function CMarriageTreeFrame:ctor(parent, param)
  param = param or {}
  local mWidth = param.mWidth or 720
  local mHeight = param.mHeight or 420
  self.m_parent = parent
  self.m_curPageItems = {}
  self.m_totalLines = param.lines or 2
  self.m_lineItemsNum = param.lineItemnum or 3
  self.m_itemSize = param.itemsize or CCSizeMake(240, 220)
  self.m_offSize = param.offsize or ccp(0, 0)
  self.m_CurrPageIndex = 1
  self.m_TotalPageNum = 1
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(mWidth, mHeight))
  self:setAnchorPoint(ccp(0, 0))
  self:setTouchEnabled(true)
  self:addTouchEventListener(function(touchObj, event)
    self:OnTouchEvent(touchObj, event)
  end)
  self:setNodeEventEnabled(true)
  local tl = CCLayerColor:create(ccc4(255, 0, 0, 0))
  self:addNode(tl)
  tl:setContentSize(CCSizeMake(mWidth, mHeight))
  local allpagedata = self.m_parent:getLocalData()
  if allpagedata then
    local datalen = #allpagedata
    self.m_TotalPageNum = math.ceil(datalen / (self.m_totalLines * self.m_lineItemsNum))
  end
  self:flushItem(1, false, true)
end
function CMarriageTreeFrame:getPageData(pageindex)
  if pageindex == nil then
    pageindex = self.m_CurrPageIndex
  end
  print("======================  getPageData  pageindex ", pageindex)
  if self.m_parent then
    local allpagedata = self.m_parent:getLocalData()
    dump(allpagedata, "1111111111111111 ")
    if allpagedata then
      local datalen = #allpagedata
      local result = {}
      local starindex = (pageindex - 1) * (self.m_totalLines * self.m_lineItemsNum) + 1
      for Index = starindex, starindex + self.m_totalLines * self.m_lineItemsNum - 1 do
        result[#result + 1] = allpagedata[Index]
      end
      dump(result, " 222222222222 result ")
      return result
    end
  end
  return {}
end
function CMarriageTreeFrame:flushItem(index, showAction, focus)
  if self.m_CurrPageIndex == index and focus ~= true then
    return
  end
  if index == nil then
    index = self.m_CurrPageIndex
  end
  self.m_CurrPageIndex = index
  local panSize = self:getSize()
  self.m_curPageItems = self.m_curPageItems or {}
  for k, v in pairs(self.m_curPageItems) do
    v:removeFromParentAndCleanup(true)
  end
  self.m_curPageItems = {}
  local curPageDade = self:getPageData(index)
  for line = 1, self.m_totalLines do
    for num = 1, self.m_lineItemsNum do
      local curindex = (line - 1) * self.m_lineItemsNum + num
      local curItemData = curPageDade[curindex]
      if curItemData ~= nil then
        print("===================>>>> m_passTime ", self.m_parent.m_passTime)
        curItemData.timeoff = self.m_parent.m_passTime
        local item = marriageTreeItem.new(curItemData, handler(self, self.itemClearChange))
        self:addChild(item:getUINode())
        local itemsize = item:getSize()
        self.m_itemSize = itemsize
        if self.m_offSize.x == 0 or self.m_offSize.y == 0 then
          if self.m_lineItemsNum == 1 then
            self.m_offSize.x = 0
          else
            self.m_offSize.x = (panSize.width - self.m_lineItemsNum * itemsize.width) / (self.m_lineItemsNum - 1)
          end
          if self.m_totalLines == 1 then
            self.m_offSize.y = (panSize.height - self.m_totalLines * itemsize.height) / (self.m_totalLines - 1)
          else
            self.m_offSize.y = 0
          end
          if self.m_offSize.x < 0 then
            self.m_offSize.x = 1
          end
          if 0 > self.m_offSize.y then
            self.m_offSize.y = 0
          end
        end
        item:setPosition(ccp((num - 1) * (self.m_itemSize.width + self.m_offSize.x), panSize.height - line * self.m_itemSize.height - (line - 1) * self.m_offSize.y))
        local px, py = item.getPosition()
        item.m_OriPosXY = ccp(px, py)
        self.m_curPageItems[#self.m_curPageItems + 1] = item
        if showAction == true then
          item:setFadeIn()
        end
      end
    end
  end
  if self.m_parent then
    self.m_parent:setRLBtnState(self.m_CurrPageIndex > 1, self.m_CurrPageIndex < self.m_TotalPageNum and 1 < self.m_TotalPageNum)
  end
end
function CMarriageTreeFrame:OnTouchEvent(touchObj, event)
  if event == TOUCH_EVENT_BEGAN then
    self.startPos = touchObj:getTouchStartPos()
    self.m_TouchBeganItem = self:checkTouchBeganPos(self.startPos)
    self.m_HasTouchMoved = false
    print("begain =====>>>>  ", self.startPos.x, self.startPos.y, self.m_TouchBeganItem == nil)
  elseif event == TOUCH_EVENT_MOVED then
    local startPos = touchObj:getTouchStartPos()
    local movePos = touchObj:getTouchMovePos()
    if not self.m_HasTouchMoved and math.abs(startPos.x - movePos.x) + math.abs(startPos.y - movePos.y) > 40 then
      self.m_HasTouchMoved = true
    end
    if self.m_HasTouchMoved then
      print(" move  =====>>>>  ", movePos.x - startPos.x)
      if self.m_TouchBeganItem then
        self.m_TouchBeganItem:setTouchState(false)
        self.m_TouchBeganItem = nil
      end
      self:DrugCurrPage(movePos.x - startPos.x)
    end
  elseif event == TOUCH_EVENT_ENDED or event == TOUCH_EVENT_CANCELED then
    if self.m_HasTouchMoved then
      if self.m_TouchBeganItem ~= nil then
        self.m_TouchBeganItem:setTouchState(false)
        self.m_TouchBeganItem = nil
      end
      local startPos = touchObj:getTouchStartPos()
      local endPos = touchObj:getTouchEndPos()
      self:DrugAtPos(startPos, endPos)
      print(" end   =====>>>>  ", startPos.x - endPos.x)
    else
      self:ClickAtPos()
    end
  end
end
function CMarriageTreeFrame:ClickAtPos()
  if self.m_TouchBeganItem == nil then
    return
  end
  local itemId = self.m_TouchBeganItem:getItemID()
  local persioninfo = self.m_TouchBeganItem:getNames()
  if persioninfo == nil then
    return
  end
  local male = persioninfo[1] or {}
  local female = persioninfo[2] or {}
  local nameColorm = NameColor_MainHero[male.zslv[1]] or ccc3(255, 255, 255)
  local nameColorf = NameColor_MainHero[female.zslv[1]] or ccc3(255, 255, 255)
  local confirmBoxDlg = CPopWarning.new({
    title = "提示",
    text = string.format("你确定给#<r:%d,g:%d,b:%d>%s#和#<r:%d,g:%d,b:%d>%s#送上祝福吗？（祝福成功可以获得奖励哟！）", nameColorm.r, nameColorm.g, nameColorm.b, male.name, nameColorf.r, nameColorf.g, nameColorf.b, female.name),
    confirmFunc = function()
      netsend.netmarry.blessMarry(itemId)
    end,
    cancelText = "只是看看",
    confirmText = "送上祝福"
  })
  self.m_TouchBeganItem = nil
  for _, item in pairs(self.m_curPageItems) do
    item:setTouchState(false)
  end
end
function CMarriageTreeFrame:checkTouchBeganPos(pos)
  local touchPos = self:convertToNodeSpace(ccp(pos.x, pos.y))
  for _, itemObj in pairs(self.m_curPageItems) do
    local x, y = itemObj:getPosition()
    if x <= touchPos.x and touchPos.x <= x + self.m_itemSize.width and y <= touchPos.y and touchPos.y <= y + self.m_itemSize.height then
      itemObj:setTouchState(true)
      return itemObj
    end
  end
  return nil
end
function CMarriageTreeFrame:DrugCurrPage(offx)
  for _, petObj in pairs(self.m_curPageItems) do
    local oriPosXY = petObj.m_OriPosXY
    local dx = offx / 30
    if dx < -7 then
      dx = -7
    elseif dx > 7 then
      dx = 7
    end
    petObj:setPosition(ccp(oriPosXY.x + dx, oriPosXY.y))
  end
end
function CMarriageTreeFrame:DrugAtPos(startPos, endPos)
  local offx = endPos.x - startPos.x
  if offx > 20 then
    if not self:ShowPrePackagePage() then
      self:BackToOriPosXY()
    end
  elseif offx < -20 then
    if not self:ShowNextPackagePage() then
      self:BackToOriPosXY()
    end
  else
    self:BackToOriPosXY()
  end
end
function CMarriageTreeFrame:BackToOriPosXY()
  for _, petObj in pairs(self.m_curPageItems) do
    local oriPosXY = petObj.m_OriPosXY
    petObj:stopAllActions()
    petObj:runAction(CCMoveTo:create(0.3, oriPosXY))
  end
end
function CMarriageTreeFrame:ShowPrePackagePage()
  if self.m_CurrPageIndex <= 1 then
    return false
  end
  self:flushItem(self.m_CurrPageIndex - 1, true)
  return true
end
function CMarriageTreeFrame:ShowNextPackagePage()
  if self.m_CurrPageIndex >= self.m_TotalPageNum then
    return false
  end
  self:flushItem(self.m_CurrPageIndex + 1, true)
  return true
end
function CMarriageTreeFrame:itemClearChange(param)
  print("=================>>>> itemClearChange ")
end
marriageTree = class("marriageTree", CcsSubView)
function marriageTree:ctor(mid)
  marriageTree.super.ctor(self, "views/marriage_tree.csb", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    bnt_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "bnt_close"
    },
    btn_write = {
      listener = handler(self, self.OnBtn_Write),
      variName = "btn_write"
    },
    btn_next = {
      listener = handler(self, self.OnBtn_NextPage),
      variName = "btn_next"
    },
    btn_pre = {
      listener = handler(self, self.OnBtn_PrePage),
      variName = "btn_pre"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_marryTreeInfo = {}
  self.m_cnt = 0
  self.m_cntAll = data_Variables.MarryBlessCnt
  local layer_content = self:getNode("layer_content")
  layer_content:setVisible(false)
  self.txt_todaytimes = self:getNode("txt_today_time")
  self.m_initId = mid
  netsend.netmarry.requestMarryTreeInfo(mid)
end
function marriageTree:setTodayTimes(haddone, total)
  haddone = haddone or 0
  total = total or 5
  local txt = string.format("%d/%d", haddone, total)
  local txt_counterNum = self:getNode("txt_today_time")
  txt_counterNum:setText(txt)
  local txt_tips1 = self:getNode("txt_tips_01")
  local txt_tips2 = self:getNode("txt_tips_02")
  local px, py = txt_tips1:getPosition()
  local csize = txt_counterNum:getContentSize()
  txt_counterNum:setPosition(ccp(px + 2, py))
  txt_tips2:setPosition(ccp(px + csize.width + 4, py))
end
function marriageTree:getLocalData()
  return self.m_marryTreeInfo
end
function marriageTree:OnBtn_Close()
  self:CloseSelf()
end
function marriageTree:OnBtn_Collect()
end
function marriageTree:OnBtn_Write()
  if g_HunyinMgr and g_HunyinMgr:isCollectBless() then
    local confirmBoxDlg = CPopWarning.new({
      title = "提示",
      text = string.format("发布快讯直接邀请其他玩家祝福，需要花费%d#<IR2>#。", data_Variables.MarryCollectBlessCostGold),
      confirmFunc = function()
        if g_LocalPlayer:getGold() >= data_Variables.MarryCollectBlessCostGold then
          netsend.netmarry.collectMarryTree()
        else
          ShowNotifyTips(string.format("元宝不足%d", data_Variables.MarryCollectBlessCostGold))
          ShowRechargeView({resType = RESTYPE_GOLD})
        end
      end,
      cancelText = "取消",
      confirmText = "确定"
    })
  else
    ShowNotifyTips("你没有收集祝福的任务。")
  end
end
function marriageTree:OnBtn_NextPage()
  if self.m_pageFramke then
    self.m_pageFramke:ShowNextPackagePage()
  end
end
function marriageTree:OnBtn_PrePage()
  if self.m_pageFramke then
    self.m_pageFramke:ShowPrePackagePage()
  end
end
function marriageTree:setRLBtnState(l, r)
  l = l or false
  r = r or false
  self.btn_next:setEnabled(r)
  self.btn_pre:setEnabled(l)
end
function marriageTree:flushMarryData(dataifo)
  dump(dataifo, "marriageTree:flushMarryData")
  if dataifo == nil or type(dataifo) ~= "table" then
    return
  end
  self.m_marryTreeInfo = self.m_marryTreeInfo or {}
  if dataifo.cnt then
    self.m_cnt = dataifo.cnt
    if self.m_cnt < 0 then
      self.m_cnt = 0
    end
  end
  local havedata = false
  for k, v in pairs(self.m_marryTreeInfo) do
    if v.id == dataifo.id then
      self.m_marryTreeInfo[k].lefttime = dataifo.lefttime
      self.m_marryTreeInfo[k].progress = dataifo.progress
      self.m_marryTreeInfo[k].state = dataifo.state
      havedata = true
      break
    end
  end
  if havedata then
    self:flushShow()
  else
    print("姻缘树  本地找不到该结婚任务的数据  dataifo.id = ", dataifo.id)
  end
end
function marriageTree:requestTreeData(cnt, list)
  dump(list, "marriageTree:requestTreeData")
  if cnt then
    self.m_cnt = cnt
    if self.m_cnt < 0 then
      self.m_cnt = 0
    end
  end
  if list then
    self.m_marryTreeInfo = {}
    self.m_marryTreeInfo = DeepCopyTable(list)
  end
  self.m_passTime = 0
  if self.m_counterHandler then
    scheduler.unscheduleGlobal(self.m_counterHandler)
    self.m_counterHandler = nil
  end
  self.m_counterHandler = scheduler.scheduleGlobal(function()
    if self.m_passTime == nil or type(self.m_passTime) ~= "number" then
      self.m_passTime = 0
    end
    self.m_passTime = self.m_passTime + 1
    if self.m_passTime > 86400 then
      self.m_passTime = 86400
    end
  end, 1)
  if self.m_pageFramke == nil then
    local layer_content = self:getNode("layer_content")
    layer_content:setVisible(false)
    local p = layer_content:getParent()
    local px, py = layer_content:getPosition()
    local csize = layer_content:getSize()
    self.m_pageFramke = CMarriageTreeFrame.new(self, {
      mWidth = csize.width,
      mHeight = csize.height
    })
    self.m_pageFramke:setPosition(ccp(px, py))
    p:addChild(self.m_pageFramke)
    self:setTodayTimes(0, 5)
  end
  self:flushShow()
  if self.m_marryTreeInfo == nil then
    self.m_marryTreeInfo = {}
  end
  for k, v in pairs(self.m_marryTreeInfo) do
    if v.id == self.m_initId and self.m_initId ~= nil then
      local male = v.male or {}
      local female = v.female or {}
      local nameColorm = NameColor_MainHero[male.zs] or ccc3(255, 255, 255)
      local nameColorf = NameColor_MainHero[female.zs] or ccc3(255, 255, 255)
      local confirmBoxDlg = CPopWarning.new({
        title = "提示",
        text = string.format("你确定给#<r:%d,g:%d,b:%d>%s#和#<r:%d,g:%d,b:%d>%s#送上祝福吗？（祝福成功可以获得奖励哟！）", nameColorm.r, nameColorm.g, nameColorm.b, male.name, nameColorf.r, nameColorf.g, nameColorf.b, female.name),
        confirmFunc = function()
          netsend.netmarry.blessMarry(self.m_initId)
          self.m_initId = nil
        end,
        cancelText = "只是看看",
        confirmText = "送上祝福"
      })
      break
    end
  end
end
function marriageTree:Clear()
  if self.m_counterHandler then
    scheduler.unscheduleGlobal(self.m_counterHandler)
    self.m_counterHandler = nil
  end
  if g_marryTreeView then
    g_marryTreeView = nil
  end
  self.m_initId = nil
end
function marriageTree:flushShow()
  self:setTodayTimes(self.m_cnt, self.m_cntAll)
  if self.m_pageFramke then
    self.m_pageFramke:flushItem(nil, false, true)
  end
end
function marriageTree:localItemChange(param)
  print(" *****************************  localItemChange  ")
  dump(param, "2222222222 ")
  if self and param then
    for k, v in pairs(self.m_marryTreeInfo) do
      if v.id == param.id then
        for sk, sv in pairs(param) do
          self.m_marryTreeInfo[k][sk] = sv
        end
        break
      end
    end
  end
end
function marriageTree:deleteOneItem(id)
  print("=============????  marriageTree:deleteOneItem ", id)
  for k, v in pairs(self.m_marryTreeInfo) do
    if v.id == id then
      table.remove(self.m_marryTreeInfo, k)
      break
    end
  end
  self:flushShow()
end
function openMarryTreeView(prid)
  if g_marryTreeView then
    g_marryTreeView = nil
  end
  g_marryTreeView = marriageTree.new(prid)
  getCurSceneView():addSubView({
    subView = g_marryTreeView,
    zOrder = MainUISceneZOrder.menuView
  })
end
