local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local ECPanelBase = require("GUI.ECPanelBase")
local ECGame = Lplus.ForwardDeclare("ECGame")
local NotifyClick = require("Event.NotifyClick")
require("Common.ECMsgBox")
local ECMsgBox = Lplus.Extend(ECPanelBase, "ECMsgBox")
do
  local ECMsgBoxMan = Lplus.ForwardDeclare("ECMsgBoxMan")
  local def = ECMsgBox.define
  def.field("string").content = ""
  def.field("string").title = ""
  def.field("function").clickcall = nil
  def.field("function").timercall = nil
  def.field("table").sender = nil
  def.field("number").m_okRet = MsgBox.MsgBoxRetT.MBRT_OK
  def.field("number").m_cancelRet = MsgBox.MsgBoxRetT.MBRT_CANCEL
  def.field("number").msgboxID = 1
  def.field("boolean").TimerStarted = false
  def.field("number").TimerID = 0
  def.field("number").LifeTime = 0
  def.field("number").ttl = 0
  def.field("number").nType = MsgBox.MsgBoxType.MBBT_OKCANCEL
  def.field("function")._after_open_call = nil
  def.field("function").opencall = nil
  def.field("number").mPriority = Priority.normal
  local _uniqueID = 1
  local function uniqueId()
    local r = _uniqueID
    _uniqueID = _uniqueID + 1
    return r
  end
  def.static("number", "=>", ECMsgBox).new = function(priority)
    local obj = ECMsgBox()
    obj.m_depthLayer = GUIDEPTH.TOP
    obj.msgboxID = uniqueId()
    obj.mPriority = priority
    return obj
  end
  def.method().Toggle = function(self)
    if self.m_panel then
      self:DestroyPanel()
    else
      self:CreatePanel(RESPATH.Panel_PopUp)
    end
  end
  def.method("function").ShowMsgEx = function(self, _callback)
    self._after_open_call = _callback
    if self.m_panel then
      if self._after_open_call then
        self._after_open_call(self)
        self._after_open_call = nil
      end
      if self.m_panel.activeSelf then
        self:UpdateUI()
      else
        self:StopTimer()
      end
    else
    end
  end
  def.method().HideBox = function(self)
    if self.m_panel then
      self.m_panel:SetActive(false)
      self:StopTimer()
    end
  end
  def.method("string").SetText = function(self, text)
    if not self.m_panel then
      return
    end
    self.content = text
    local NameO = self.m_panel:FindChild("Txt_Name1")
    NameO:GetComponent("UILabel").text = self.content
  end
  def.method("string").SetOkText = function(self, text)
    if not self.m_panel then
      return
    end
    self.m_panel:FindChild("Btn_Approve"):FindChild("Label"):GetComponent("UILabel").text = text
  end
  def.method("string").SetYesText = function(self, text)
    if not self.m_panel then
      return
    end
    self.m_panel:FindChild("Btn_Approve"):FindChild("Label"):GetComponent("UILabel").text = text
  end
  def.method("string").SetCancleText = function(self, text)
    if not self.m_panel then
      return
    end
    self.m_panel:FindChild("Btn_Refuse"):FindChild("Label"):GetComponent("UILabel").text = text
  end
  def.method("string").SetNoText = function(self, text)
    if not self.m_panel then
      return
    end
    self.m_panel:FindChild("Btn_Refuse"):FindChild("Label"):GetComponent("UILabel").text = text
  end
  local OnOtherPanelClick = function(self)
    local function func(sender, event)
      if bit.band(self.nType, MsgBox.MsgBoxType.MBT_AUTOCLOSE) > 0 and self.m_panel and self.m_panel.name ~= event.who then
        self:DestroyPanel()
      end
    end
    return func
  end
  def.override().OnCreate = function(self)
    ECGame.EventManager:addHandler(NotifyClick, OnOtherPanelClick(self))
    if self._after_open_call then
      self._after_open_call(self)
      self._after_open_call = nil
    end
    if self.opencall then
      self.opencall(self)
    end
    if self.m_panel.activeSelf then
      self:UpdateUI()
    else
      self:StopTimer()
    end
  end
  def.override().OnDestroy = function(self)
    self.content = ""
    self.clickcall = nil
    self.timercall = nil
    self.sender = nil
    self._after_open_call = nil
    self.opencall = nil
    self.LifeTime = 0
    self.ttl = 0
    self:StopTimer()
    ECGame.EventManager:removeHandler(NotifyClick, OnOtherPanelClick(self))
    ECMsgBoxMan.Instance():RemoveBoxById(self.msgboxID)
    ECMsgBoxMan.Instance():ToggleNext()
  end
  def.method().UpdateUI = function(self)
    local panel = self.m_panel
    if not panel then
      return
    end
    local nType = self.nType
    local info_icon = bit.band(nType, MsgBox.MsgBoxType.MBT_INFO) > 0
    local ok_icon = 0 < bit.band(nType, MsgBox.MsgBoxType.MBT_OK)
    local warn_icon = 0 < bit.band(nType, MsgBox.MsgBoxType.MBT_WARN)
    local isShowCancel = 0 < bit.band(nType, MsgBox.MsgBoxType.MBBT_CANCEL)
    local isShowOk = 0 < bit.band(nType, MsgBox.MsgBoxType.MBBT_OK)
    local isShowCheckBox = 0 < bit.band(nType, MsgBox.MsgBoxType.MBBT_CHECKBOX)
    local isShowYes = 0 < bit.band(nType, MsgBox.MsgBoxType.MBBT_YES)
    local isShowNo = 0 < bit.band(nType, MsgBox.MsgBoxType.MBBT_NO)
    panel:FindChild("Btn_Refuse"):SetActive(isShowCancel or isShowNo)
    panel:FindChild("Btn_Approve"):SetActive(isShowOk or isShowYes)
    if isShowCancel then
      panel:FindChild("Btn_Refuse"):FindChild("Label"):GetComponent("UILabel").text = StringTable.Get(2095)
    end
    if isShowOk then
      panel:FindChild("Btn_Approve"):FindChild("Label"):GetComponent("UILabel").text = StringTable.Get(2094)
    end
    if isShowNo then
      panel:FindChild("Btn_Refuse"):FindChild("Label"):GetComponent("UILabel").text = StringTable.Get(2093)
    end
    if isShowYes then
      panel:FindChild("Btn_Approve"):FindChild("Label"):GetComponent("UILabel").text = StringTable.Get(2092)
    end
    panel:FindChild("BtnGroup"):GetComponent("UIBoundsAnchor").enabled = true
    if isShowCheckBox then
    end
    local NameO = panel:FindChild("Txt_Name1")
    NameO:GetComponent("UILabel").text = self.content
    self.m_okRet = MsgBox.MsgBoxRetT.MBRT_OK
    self.m_cancelRet = MsgBox.MsgBoxRetT.MBRT_CANCEL
    if self.opencall then
      self.opencall(self)
    end
    self:StartTimer()
  end
  def.method().UpdateTimer = function(self)
    self.LifeTime = self.LifeTime - 1
    if self.LifeTime < 0 then
      local isOverTimeType = 0 < bit.band(self.nType, MsgBox.MsgBoxType.MBT_OVERTIME)
      if not isOverTimeType then
        self:DestroyPanel()
      else
        self.m_okRet = MsgBox.MsgBoxRetT.MBRT_OVERTIME
      end
    elseif self.timercall then
      self.timercall(self)
    end
  end
  def.method().StartTimer = function(self)
    if self.TimerStarted or self.LifeTime <= 0 then
      return
    end
    self.TimerStarted = true
    self.TimerID = GameUtil.AddGlobalTimer(1, false, function()
      if self.TimerStarted then
        self:UpdateTimer()
      end
    end)
  end
  def.method().StopTimer = function(self)
    if not self.TimerStarted then
      return
    end
    if self.TimerID ~= 0 then
      GameUtil.RemoveGlobalTimer(self.TimerID)
      self.TimerID = 0
    end
    self.TimerStarted = false
  end
  def.method("string").onClick = function(self, id)
    if string.find(id, "Btn_Approve") == 1 then
      self:onOk()
    elseif string.find(id, "Btn_Refuse") == 1 then
      self:onCancle()
    end
  end
  def.method().onOk = function(self)
    local retval = self.m_okRet
    local callback = self.clickcall
    local sender = self.sender
    self:DestroyPanel()
    if callback then
      callback(sender, retval)
    end
  end
  def.method().onCancle = function(self)
    local retval = self.m_cancelRet
    local callback = self.clickcall
    local sender = self.sender
    self:DestroyPanel()
    if callback then
      callback(sender, retval)
    end
  end
end
ECMsgBox.Commit()
local m_Instance
local ECMsgBoxMan = Lplus.Class("ECMsgBoxMan")
do
  local def = ECMsgBoxMan.define
  def.const("table").ECMsgBox = ECMsgBox
  def.field("table").boxList = BLANK_TABLE_INIT
  def.field("number").boxId = 0
  def.static("=>", ECMsgBoxMan).Instance = function()
    if m_Instance == nil then
      m_Instance = ECMsgBoxMan()
    end
    return m_Instance
  end
  def.method("number", "=>", ECMsgBox).NewMsgBox = function(self, priority)
    return ECMsgBox.new(priority)
  end
  def.method("table", "string", "string", "number", "function", "number", "function", "number", "function", "=>", ECMsgBox).ShowMsgBox = function(self, sender, lpszText, lpszCaption, nType, _clickcall, ttl, _timercall, priority, _opencall)
    local box = self:ExistBox(sender, lpszText, lpszCaption, nType, _clickcall, ttl, _timercall, priority, _opencall)
    if not box then
      box = self:NewMsgBox(priority)
      if lpszText then
        box.content = lpszText
      end
      if lpszCaption then
        box.title = lpszCaption
      end
      if nType then
        box.nType = nType
      end
      box.sender = sender
      box.clickcall = _clickcall
      box.timercall = _timercall
      box.LifeTime = ttl
      box.ttl = ttl
      box.opencall = _opencall
      self.boxList[#self.boxList + 1] = box
    end
    local showbox = self:FindNextBox2Show()
    showbox:ShowMsgEx(function(thebox)
      thebox:Show(true)
      self.boxId = thebox.msgboxID
      self:HideExcept(thebox.msgboxID)
    end)
    return box
  end
  def.method("table", "string", "string", "number", "function", "number", "function", "number", "function", "=>", ECMsgBox).ExistBox = function(self, sender, lpszText, lpszCaption, nType, _clickcall, ttl, _timercall, priority, _opencall)
    for _, box in pairs(self.boxList) do
      if box.content == lpszText and box.title == lpszCaption and box.nType == nType and box.sender == sender and box.clickcall == _clickcall and box.timercall == _timercall and box.ttl == ttl and box.opencall == _opencall and box.mPriority == priority then
        warn("existbox id:" .. box.msgboxID)
        return box
      end
    end
    return nil
  end
  def.method("table", "string", "string", "number", "function", "number", "function", "number", "function", "=>", ECMsgBox).ShowMsgBoxEx = function(self, sender, lpszText, lpszCaption, nType, _clickcall, ttl, _timercall, priority, _opencall)
    local box = self:ExistBoxEx(sender, lpszText, lpszCaption, nType, _clickcall, ttl, _timercall, priority, _opencall)
    if not box then
      box = self:NewMsgBox(priority)
      if lpszText then
        box.content = lpszText
      end
      if lpszCaption then
        box.title = lpszCaption
      end
      if nType then
        box.nType = nType
      end
      box.sender = sender
      box.clickcall = _clickcall
      box.timercall = _timercall
      box.LifeTime = ttl
      box.ttl = ttl
      box.opencall = _opencall
      self.boxList[#self.boxList + 1] = box
    end
    local showbox = self:FindNextBox2Show()
    showbox:ShowMsgEx(function(thebox)
      thebox:Show(true)
      self.boxId = thebox.msgboxID
      self:HideExcept(thebox.msgboxID)
    end)
    return box
  end
  def.method("table", "string", "string", "number", "function", "number", "function", "number", "function", "=>", ECMsgBox).ExistBoxEx = function(self, sender, lpszText, lpszCaption, nType, _clickcall, ttl, _timercall, priority, _opencall)
    for _, box in pairs(self.boxList) do
      if box.content == lpszText and box.title == lpszCaption and box.nType == nType and box.sender == sender and box.ttl == ttl and box.mPriority == priority then
        warn("existbox id:" .. box.msgboxID)
        return box
      end
    end
    return nil
  end
  def.method("number").RemoveBoxById = function(self, id)
    local _, pos = self:FindBox(id)
    if pos > 0 then
      table.remove(self.boxList, pos)
    end
  end
  def.method("number", "=>", ECMsgBox, "number").FindBox = function(self, id)
    for k, v in pairs(self.boxList) do
      if v.msgboxID == id then
        return v, k
      end
    end
    return nil, 0
  end
  def.method("=>", ECMsgBox).FindNextBox2Show = function(self)
    if #self.boxList == 0 then
      return nil
    else
      local index = 1
      local max = self.boxList[1].mPriority
      for i = 2, #self.boxList do
        if max < self.boxList[i].mPriority then
          max = self.boxList[i].mPriority
          index = i
        end
      end
      return self.boxList[index]
    end
  end
  def.method().ToggleNext = function(self)
    local showbox = self:FindNextBox2Show()
    if showbox then
      showbox:ShowMsgEx(function(thebox)
        thebox:Show(true)
        self.boxId = thebox.msgboxID
        self:HideExcept(thebox.msgboxID)
      end)
    end
  end
  def.method().RemoveAll = function(self)
    for i = 1, #self.boxList do
      local box = self.boxList[i]
      if box then
        box:DestroyPanel()
      end
    end
    self.boxList = {}
  end
  def.method("=>", "boolean").IsMsgBoxShowed = function(self)
    if #self.boxList == 0 then
      return false
    else
      local box = self:CurMsgBox()
      if box and box:IsShow() then
        return true
      end
      return false
    end
  end
  def.method("=>", ECMsgBox).CurMsgBox = function(self)
    local box, _ = self:FindBox(self.boxId)
    return box
  end
  def.method("number").HideExcept = function(self, id)
    for k, v in pairs(self.boxList) do
      if v.msgboxID ~= id then
        v:HideBox()
      end
    end
  end
  def.method("number").HideAll = function(self, id)
    for k, v in pairs(self.boxList) do
      v:HideBox()
    end
  end
  def.method("=>", "boolean").BringTop = function(self)
    local box = self:CurMsgBox()
    if nil == box then
      return false
    end
    box:BringTop()
    return true
  end
  def.method(ECPanelBase, "=>", "boolean").BringBelow = function(self, panel)
    local box = self:CurMsgBox()
    if nil == box or box.m_panel == nil then
      return false
    end
    return true
  end
  def.method("number", "=>", "boolean").BringToDepth = function(self, depth)
    local box = self:CurMsgBox()
    if nil == box or box.m_panel == nil then
      return false
    end
    local depth = box.m_panel:BringUIPanelTopDepth(depth)
    return true
  end
  def.method().Test = function(self)
    MsgBox.ShowMsgBox(nil, "\228\184\142\230\156\141\229\138\161\229\153\168\232\191\158\230\142\165\229\183\178\230\150\173\229\188\128", "\230\150\173\231\186\191\230\143\144\231\164\186", MsgBox.MsgBoxType.MBBT_OK, function(box, ret)
    end)
    MsgBox.ShowMsgBox(nil, "\228\184\142\230\156\141\229\138\161\229\153\168\232\191\158\230\142\165\229\183\178\230\150\173\229\188\128", "\230\150\173\231\186\191\230\143\144\231\164\186", MsgBox.MsgBoxType.MBBT_OK, function(box, ret)
    end)
  end
end
ECMsgBoxMan.Commit()
return ECMsgBoxMan
