local noticeSaveDir = device.writablePath .. "notice/"
local noticeSavePath = noticeSaveDir .. "notice"
local titleMark = "<title>"
function _saveLoginNoticeCache(issue, title, notice)
  if issue == nil or notice == nil then
    print("------->>公告期数或者内容为空，不进行缓存", issue, notice)
    return
  end
  title = title or ""
  local saveStr = title .. titleMark .. notice
  print("------->>准备缓存游戏公告", issue)
  os.mkdir(noticeSaveDir)
  io.writefile(noticeSavePath, json.encode(saveStr), "wb")
  setConfigData("lastNoticeIssue", tostring(issue), true)
  print("------->>准备缓存游戏公告成功!", issue)
end
function _getLoginNoticeCache()
  local dataStr
  local file = io.open(noticeSavePath, "rb")
  if file then
    dataStr = file:read("*a")
    io.close(file)
  else
    return nil, nil
  end
  if dataStr == nil then
    return nil, nil
  else
    dataStr = json.decode(dataStr)
    local tIdx = string.find(dataStr, titleMark)
    if tIdx == nil then
      return nil, dataStr
    elseif tIdx <= 1 then
      local title
      local notice = string.sub(dataStr, tIdx + string.len(titleMark))
      return title, notice
    else
      local title = string.sub(dataStr, 1, tIdx - 1)
      local notice = string.sub(dataStr, tIdx + string.len(titleMark))
      return title, notice
    end
  end
end
function _checkShowNoticeFlag(issue)
  local hour = tonumber(os.date("%H"))
  local curTime = os.time()
  if hour < 5 then
    curTime = curTime - 86400
  end
  local data = os.date("*t", curTime)
  local year = data.year
  local month = data.month
  local day = data.day
  local autoNotice = false
  local lastNoticeIssue = getConfigByName("lastNoticeIssue")
  local lastNoticeDate = getConfigByName("lastNoticeDate")
  local notNoticeAgain = getConfigByName("notNoticeAgain")
  if lastNoticeDate == nil or notNoticeAgain == nil or lastNoticeIssue == nil then
    print("=========>>>>本地没有公告的缓存信息，需要强制显示", lastNoticeDate, notNoticeAgain, lastNoticeIssue)
    autoNotice = true
    notNoticeAgain = 0
  else
    lastNoticeIssue = tonumber(lastNoticeIssue)
    lastNoticeDate = tonumber(lastNoticeDate)
    notNoticeAgain = tonumber(notNoticeAgain)
    if lastNoticeIssue ~= issue then
      print("=========>>>>本地公告和服务器的期数不一致，需要强制显示", lastNoticeIssue, issue, type(lastNoticeIssue), type(issue))
      autoNotice = true
      notNoticeAgain = 0
    else
      local date_l = os.date("*t", lastNoticeDate)
      local year_l = date_l.year
      local month_l = date_l.month
      local day_l = date_l.day
      if year_l ~= year or month_l ~= month or day_l ~= day then
        autoNotice = true
        notNoticeAgain = 0
        print("=========>>>>公告内容不是同一天的，需要强制显示")
      elseif notNoticeAgain ~= 1 then
        autoNotice = true
        print("=========>>>>公告内容是同一天的，开启了重复显示")
      else
        print("=========>>>>公告内容是同一天的，不再显示")
      end
    end
  end
  return autoNotice, notNoticeAgain
end
function ShowLoginNoticeInLoginDlg(issue, title, notice)
  if notice == nil then
    return
  end
  local autoNotice, notNoticeAgain = _checkShowNoticeFlag(issue)
  if autoNotice and g_LoginNoticeIns == nil then
    getCurSceneView():addSubView({
      subView = CLoginNotice.new(issue, title, notice, {notAgain = notNoticeAgain}),
      zOrder = 99999
    })
  end
end
function ShowLoginNoticeInGame()
  local issue = getConfigByName("lastNoticeIssue") or 0
  issue = tonumber(issue)
  local title, notice = _getLoginNoticeCache()
  notice = notice or ""
  getCurSceneView():addSubView({
    subView = CLoginNotice.new(issue, title, notice, nil),
    zOrder = MainUISceneZOrder.menuView
  })
  netsend.netbaseptc.checkLoginNotice(issue)
end
CLoginNotice = class("CLoginNotice", CcsSubView)
g_LoginNoticeIns = nil
function CLoginNotice:ctor(issue, title, notice, param)
  CLoginNotice.super.ctor(self, "views/loginnotice.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  local btnBatchListener = {
    btn_ok = {
      listener = handler(self, self.OnBtn_Ok),
      variName = "btn_ok"
    },
    btn_select = {
      listener = handler(self, self.OnBtn_Select),
      variName = "btn_select"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_Issue = issue
  self.img_select = self:getNode("img_select")
  self.titleTxt = self:getNode("title")
  self.listcontent = self:getNode("listcontent")
  self:setContent(title, notice)
  self:setVisible(false)
  if g_LoginNoticeIns ~= nil then
    g_LoginNoticeIns:CloseSelf()
    g_LoginNoticeIns = nil
  end
  g_LoginNoticeIns = self
  local notNoticeAgain = 0
  if param == nil then
    local _, notAgain = _checkShowNoticeFlag(issue)
    notNoticeAgain = notAgain
  elseif type(param) == "table" then
    local notAgain = param.notNoticeAgain
    if notAgain ~= nil then
      notNoticeAgain = notAgain
    end
  end
  if notNoticeAgain == 1 then
    self.img_select:setVisible(true)
  else
    self.img_select:setVisible(false)
  end
end
function CLoginNotice:onEnterEvent()
  self:setVisible(true)
  self.bg = self:getNode("bg")
  local x, y = self.bg:getPosition()
  self.bg:setPosition(ccp(x, y + 100))
  local act1 = CCMoveTo:create(0.3, ccp(x, y))
  self.bg:runAction(CCEaseOut:create(act1, 3))
end
function CLoginNotice:setContent(title, notice)
  if title == nil then
    title = "公告"
  end
  self.titleTxt:setText(title)
  self.listcontent:removeAllItems()
  local size = self.listcontent:getContentSize()
  local noticeBox = CRichText.new({
    width = size.width,
    color = ccc3(238, 238, 238),
    fontSize = 20,
    align = CRichText_AlignType_Left
  })
  notice = notice or ""
  noticeBox:addRichText(notice)
  self.listcontent:pushBackCustomItem(noticeBox)
end
function CLoginNotice:loadLoginNotice(issue, title, notice)
  self.m_Issue = issue
  self:setContent(title, notice)
end
function CLoginNotice:OnBtn_Ok()
  self:CloseSelf()
end
function CLoginNotice:OnBtn_Select()
  local v = self.img_select:isVisible()
  self.img_select:setVisible(not v)
end
function CLoginNotice:Clear()
  if g_LoginNoticeIns == self then
    g_LoginNoticeIns = nil
  end
  local hour = tonumber(os.date("%H"))
  local curTime = os.time()
  if hour < 5 then
    curTime = curTime - 86400
  end
  local notNoticeAgain = 0
  if self.img_select:isVisible() then
    notNoticeAgain = 1
  end
  setConfigData("notNoticeAgain", tostring(notNoticeAgain), false)
  setConfigData("lastNoticeDate", tostring(curTime), true)
end
