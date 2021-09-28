CMonsterOpenView = class(".CMonsterOpenView", CcsSubView)
function CMonsterOpenView:ctor(monsterTypeId, monsterType, clickListener, name, retime, lilianFlag, missionId)
  CMonsterOpenView.super.ctor(self, "views/npc_normal.json")
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_MonsterTypeId = monsterTypeId
  self.m_MonsterType = monsterType
  self.m_MissionId = missionId
  self.m_ClickListen = clickListener
  self.m_Retime = retime
  self.m_LiLianFlag = lilianFlag
  local pic_bg = self:getNode("pic_bg")
  local size = pic_bg:getContentSize()
  self:setPosition(ccp(15, (display.height - size.height) / 2))
  self:enableCloseWhenTouchOutsideBySize(pic_bg:getCascadeBoundingBox())
  self.m_TouchStartItem = nil
  self.btn_list = self:getNode("btn_list")
  self.btn_list:addTouchItemListenerListView(handler(self, self.ListSelector), handler(self, self.ListEventListener))
  local shape, _name = data_getRoleShapeAndName(monsterTypeId)
  if name == nil then
    name = _name
  end
  self:getNode("txt_name"):setText(name)
  self:setHead(shape)
  self:TalkRubbish()
  self:LoadFunction()
end
function CMonsterOpenView:TalkRubbish()
  local talkId
  if self.m_MonsterType == MapMonsterType_Zhuagui then
    talkId = 3000
  elseif self.m_MonsterType == MapMonsterType_Precious then
    talkId = 5000
  elseif self.m_MonsterType == MapMonsterType_xingxiu then
    talkId = 2101
  end
  if talkId == nil then
    talkId = self.m_MonsterTypeId
    return
  end
  local talkStrTable = data_NpcRubbish[talkId] or {}
  local l = #talkStrTable
  if l <= 0 then
    return
  end
  local str = talkStrTable[math.random(1, l)]
  print("====>> str:\n", str)
  local layer_des = self:getNode("layer_des")
  layer_des:setEnabled(false)
  local size = layer_des:getSize()
  local txt = RichText.new({
    width = size.width,
    verticalSpace = 0,
    color = ccc3(78, 47, 20),
    font = KANG_TTF_FONT,
    fontSize = 20
  })
  if self.m_Retime ~= nil and type(self.m_Retime) == "number" then
    local systime = os.time()
    print("*******************   ", self.m_Retime - os.time())
    self.m_Retime = self.m_Retime - os.time()
    if 0 >= self.m_Retime then
      self.m_Retime = 0
    end
    local ret = self.m_Retime
    if ret <= 60 then
      ret = "#<R,>剩余" .. tostring(ret) .. "秒#"
    else
      local min, sec = math.modf(self.m_Retime / 60)
      if min < 60 and min > 0 then
        ret = "#<R,>剩余" .. tostring(min) .. "分钟#"
      else
      end
    end
    ret = ret or "00000000000"
    str = str .. "\n" .. ret
  end
  txt:addRichText(str)
  self:addChild(txt, 11)
  local txtSize = txt:getRichTextSize()
  local x, y = layer_des:getPosition()
  print("====x, y =", x, y)
  txt:setPosition(ccp(x, y + size.height - txtSize.height))
end
function CMonsterOpenView:LoadFunction()
  local name
  if self.m_MonsterType == MapMonsterType_Zhuagui then
    name = "超度鬼魂"
  elseif self.m_MonsterType == MapMonsterType_Precious or self.m_MonsterType == MapMonsterType_Mission or self.m_MonsterType == MapMonsterType_GuanKa then
    name = "进入战斗"
  elseif self.m_MonsterType == MapMonsterType_AnZhan then
    name = "进入战斗"
  elseif self.m_MonsterType == MapMonsterType_xingxiu then
    name = "我要向你挑战"
  elseif self.m_MonsterType == MapMonsterType_shituchangan then
    name = "我要向你挑战"
  elseif self.m_MonsterType == MapMonsterType_TiandiQiShu then
    name = "进入战斗"
  end
  local item = FunctionItem.new(name, funcId, self.m_MonsterType)
  self.btn_list:pushBackCustomItem(item)
  local itemSize = item:getSize()
  local dh = itemSize.height / 2
  local s = self.btn_list:getSize()
  if self.m_MonsterType == MapMonsterType_xingxiu then
    local item2 = FunctionItem.new("我只是路过", funcId, self.m_MonsterType)
    self.btn_list:pushBackCustomItem(item2)
  elseif self.m_MonsterType == MapMonsterType_shituchangan then
    local item2 = FunctionItem.new("我只是路过", funcId, self.m_MonsterType)
    self.btn_list:pushBackCustomItem(item2)
  elseif self.m_MonsterType == MapMonsterType_GuanKa then
    local item2 = FunctionItem.new("帮派求助", funcId, self.m_MonsterType)
    self.btn_list:pushBackCustomItem(item2)
  elseif self.m_MonsterType == MapMonsterType_Precious then
    local item2 = FunctionItem.new("帮派求助", funcId, self.m_MonsterType)
    self.btn_list:pushBackCustomItem(item2)
  elseif self.m_MonsterType == MapMonsterType_Mission and self:IsZhuanGui() then
    local item2 = FunctionItem.new("帮派求助", funcId, self.m_MonsterType)
    self.btn_list:pushBackCustomItem(item2)
  elseif self.m_LiLianFlag == true then
    local item2 = FunctionItem.new("帮派求助", funcId, self.m_MonsterType)
    self.btn_list:pushBackCustomItem(item2)
  end
  self.btn_list:setSize(CCSize(s.width, s.height - dh))
end
function CMonsterOpenView:IsZhuanGui()
  if self.m_MonsterTypeId == 55000 or self.m_MonsterTypeId == 55001 or self.m_MonsterTypeId == 55002 or self.m_MonsterTypeId == 55003 or self.m_MonsterTypeId == 55006 or self.m_MonsterTypeId == 55100 or self.m_MonsterTypeId == 55101 or self.m_MonsterTypeId == 55102 or self.m_MonsterTypeId == 55103 or self.m_MonsterTypeId == 55106 or self.m_MonsterTypeId == 55200 or self.m_MonsterTypeId == 55201 or self.m_MonsterTypeId == 55202 or self.m_MonsterTypeId == 55203 or self.m_MonsterTypeId == 55206 then
    return true
  else
    return false
  end
end
function CMonsterOpenView:setHead(shapeId)
  local layer_head = self:getNode("layer_head")
  local x, y = layer_head:getPosition()
  local size = layer_head:getContentSize()
  layer_head:setEnabled(false)
  local pngPath = data_getBigHeadPathByShape(shapeId)
  local sharedFileUtils = CCFileUtils:sharedFileUtils()
  if sharedFileUtils:isFileExist(sharedFileUtils:fullPathForFilename(pngPath)) == false then
    pngPath = "xiyou/head/head11001_big.png"
  end
  local headImg = display.newSprite(pngPath)
  headImg:setAnchorPoint(ccp(0.5, 0))
  self:addNode(headImg, 20)
  headImg:setPosition(ccp(x + size.width / 2, y))
end
function CMonsterOpenView:ListSelector(item, index, listObj)
  self:FuncClick(item, index)
end
function CMonsterOpenView:ListEventListener(item, index, listObj, status)
  if status == LISTVIEW_ONSELECTEDITEM_START then
    item:setItemTouchedStatus(true)
    self.m_TouchStartItem = item
  elseif status == LISTVIEW_ONSELECTEDITEM_END and self.m_TouchStartItem then
    item:setItemTouchedStatus(false)
    self.m_TouchStartItem = nil
  end
end
function CMonsterOpenView:FuncClick(item, index)
  if self.m_MonsterType == MapMonsterType_xingxiu and index == 1 then
  elseif self.m_MonsterType == MapMonsterType_shituchangan and index == 1 then
  elseif self.m_MonsterType == MapMonsterType_GuanKa and index == 1 then
    netsend.netteam.requestBangPaiHelp(1)
  elseif self.m_MonsterType == MapMonsterType_Precious and index == 1 then
    netsend.netteam.requestBangPaiHelp(3)
  elseif self.m_LiLianFlag == true and index == 1 then
    netsend.netteam.requestBangPaiHelp(2)
  elseif self:IsZhuanGui() and index == 1 then
    if self.m_MissionId ~= nil then
      netsend.netteam.requestBangPaiHelp(self.m_MissionId)
    elseif self.m_ClickListen then
      self.m_ClickListen()
    end
  elseif self.m_ClickListen then
    self.m_ClickListen()
  end
  scheduler.performWithDelayGlobal(function()
    self:CloseSelf()
  end, 0.01)
end
function CMonsterOpenView:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function CMonsterOpenView:Clear()
  CMonsterOpenView.super.Clear(self)
  self.m_ClickListen = nil
end
