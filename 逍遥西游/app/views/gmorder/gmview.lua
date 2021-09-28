local GmView = class("GmView", CcsSubView)
function GmView:ctor()
  GmView.super.ctor(self, "views/gmorder.json", {isAutoCenter = true, opacityBg = 150})
  local btnBatchListener = {
    btn_go = {
      listener = handler(self, self.Btn_Go),
      variName = "btn_go"
    },
    btn_history = {
      listener = handler(self, self.Btn_History),
      variName = "btn_history"
    },
    layer_historybg = {
      listener = handler(self, self.ClickHistoryBg),
      variName = "layer_historybg"
    },
    btn_back = {
      listener = handler(self, self.OnBtn_Back),
      variName = "btn_back",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_GmInput = self:getNode("input_gm")
  self.list_history = self:getNode("list_history")
  local pos_txt = self:getNode("pos_txt")
  local x, y = pos_txt:getPosition()
  local size = pos_txt:getContentSize()
  local rect = display.newClippingRegionNode(CCRect(0, 0, size.width, size.height))
  rect:setPosition(ccp(x, y))
  self.m_UINode:addNode(rect, 10)
  self.layer_historybg:setEnabled(false)
  self.m_GmInput:setText("")
  TextFieldOpenCloseExtend.extend(self.m_GmInput)
  self.m_TxtInfo = CCLabelTTF:create("", "Arial", 30, CCSize(size.width, 0), ui.TEXT_ALIGN_LEFT, ui.TEXT_VALIGN_CENTER)
  pos_txt:addNode(self.m_TxtInfo)
  self.m_TxtInfo:setPosition(ccp(size.width / 2, size.height / 2))
  self.m_BgSize = size
  self.m_Pos = self.m_TxtInfo:getPosition()
  self.m_InfoString = ""
  self:addInfoString("进入GM命令界面...\n")
  self.m_HistoryRecord = {}
  self:LoadRecordData()
  self.list_history:addTouchItemListenerListView(function(item, index, listObj)
    print("=======>>", item, index, listObj)
    local d = self.m_HistoryRecord[index + 1]
    if d then
      self.m_GmInput:setText(d[1])
      self:ClickHistoryBg()
    end
  end)
end
function GmView:UpdateInfoString()
  self.m_TxtInfo:setString(self.m_InfoString)
  local size = self.m_TxtInfo:getContentSize()
  local dh = size.height - self.m_BgSize.height
  self.m_TxtInfo:setPosition(ccp(self.m_BgSize.width / 2, self.m_BgSize.height - size.height / 2))
end
function GmView:addInfoString(strTxt)
  local l = string.len(self.m_InfoString)
  if l > 1000 then
    local idx = 1000
    self.m_InfoString = string.sub(self.m_InfoString, 1, idx)
    while true do
      if not (idx > 0) or string.sub(self.m_InfoString, idx, idx) == "\n" then
        break
      end
      idx = idx - 1
    end
    self.m_InfoString = string.sub(self.m_InfoString, 1, idx - 1)
  end
  self.m_InfoString = os.date("[%H:%M:%S]", os.time()) .. strTxt .. self.m_InfoString
  self:UpdateInfoString()
end
function GmView:Btn_Go(obj, t)
  local strOrder = self.m_GmInput:getStringValue()
  if type(strOrder) ~= "string" or string.len(strOrder) == 0 then
    self:addInfoString("输入正确的GM指令\n")
    return
  end
  if strOrder == "ranse" then
    self:CloseSelf()
    getCurSceneView():addSubView({
      subView = ChangeColorViewTest.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  elseif strOrder == "testtip" then
    self:CloseSelf()
    g_MessageMgr:testHelpTip()
  elseif strOrder == "huache" then
    local huocheIns = CreateMarryHuaCheObj()
    if huocheIns then
      huocheIns:test()
    end
  else
    self.m_GmInput:setText("")
    netsend.gm.order(strOrder)
    self:addInfoString(string.format("发送:%s\n", strOrder))
    self:AddRecord(strOrder, os.date("[%H:%M:%S]", os.time()))
  end
end
function GmView:Btn_History(obj, t)
  print("=====>>>>>Btn_History:", obj, t, self.layer_historybg:isEnabled())
  if self.layer_historybg:isEnabled() == false then
    self:ReloadHistory()
    self.m_GmInput:setTouchEnabled(false)
  end
end
function GmView:ClickHistoryBg(obj, t)
  self.layer_historybg:setEnabled(false)
  self.m_GmInput:setTouchEnabled(true)
end
function GmView:AddRecord(recordTxt, t)
  table.insert(self.m_HistoryRecord, 1, {recordTxt, t})
  local l = #self.m_HistoryRecord
  if l > 100 then
    for i = 101, l do
      self.m_HistoryRecord[i] = nil
    end
  end
  self:SaveRecordData()
end
function GmView:SaveRecordData()
  local cryptoD = crypto.encodeBase64(crypto.encryptXXTEA(json.encode(self.m_HistoryRecord), "-ca$5*3|"))
  setConfigData("mgorders", cryptoD)
end
function GmView:LoadRecordData()
  local cryptoD = getConfigByName("mgorders")
  if cryptoD then
    cryptoD = crypto.decodeBase64(cryptoD)
    local ds = crypto.decryptXXTEA(cryptoD, "-ca$5*3|")
    if type(ds) == "string" then
      local d = json.decode(ds)
      if type(d) == "table" then
        self.m_HistoryRecord = d
      end
    end
  end
end
function GmView:_additem(itemtxt, idx)
  if idx == nil then
    idx = 0
  end
  local txt = Label:create()
  txt:setFontSize(40)
  txt:setText(itemtxt)
  txt:setColor(ccc3(255, 0, 0))
  txt:setTouchEnabled(true)
  txt:setTextAreaSize(CCSize(self.m_BgSize.width, 0))
  txt:setSize(CCSize(self.m_BgSize.width, self.m_BgSize.height))
  self.list_history:insertCustomItem(txt, idx)
end
function GmView:ReloadHistory()
  print("==>>ReloadHistory")
  self.layer_historybg:setEnabled(true)
  self.layer_historybg:setVisible(true)
  self.list_history:removeAllItems()
  for i, v in ipairs(self.m_HistoryRecord) do
    self:_additem(string.format("%s%s", v[2], v[1]), i - 1)
  end
end
function GmView:OnBtn_Back(btnObj, touchType)
  self:CloseSelf()
end
function GmView:Clear()
  self.m_GmInput:CloseTheKeyBoard()
  self.m_GmInput:ClearTextFieldExtend()
end
return GmView
