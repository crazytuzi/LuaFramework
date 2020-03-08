local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIChildrensDay = Lplus.Extend(ECPanelBase, "UIChildrensDay")
local ChatPart = require("Main.Festival.ChildrensDay.ui.ChatPart")
local PaintPart = require("Main.Festival.ChildrensDay.ui.PaintPart")
local GUIUtils = require("GUI.GUIUtils")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ChildrensDayUtils = require("Main.Festival.ChildrensDay.ChildrensDayUtils")
local ChildrensDayMgr = require("Main.Festival.ChildrensDay.ChildrensDayMgr")
local ECGUIMan = require("GUI.ECGUIMan")
local def = UIChildrensDay.define
local instance
def.field("table")._paintPart = nil
def.field("table")._chatPart = nil
def.field("table")._roles = nil
def.field("table")._uiGOs = nil
def.field("userdata")._curDrawerRoleId = nil
def.field("number")._timestamp = 0
def.field("table")._questionCfgData = nil
def.field("table")._rules = nil
def.field("number")._leftTime = 0
def.field("number")._timer = 0
def.field("userdata")._clickedHeadCtrl = nil
def.field("boolean")._bUIReady = false
def.field("boolean")._bHistoryDataReady = false
def.static("=>", UIChildrensDay).Instance = function()
  if instance == nil then
    instance = UIChildrensDay()
  end
  return instance
end
def.override().OnCreate = function(self)
  self._uiGOs = {}
  self._chatPart = ChatPart.Instance()
  self._paintPart = PaintPart.Instance()
  self._rules = ChildrensDayUtils.GetGameRulesByActId(ChildrensDayMgr.GetActId(), true)
  Event.RegisterEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.ROUND_FINISH, UIChildrensDay.OnRoundFinish)
  Event.RegisterEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.CLOSE_PANEL, UIChildrensDay.OnClosePanel)
  self:InitUI()
  if ChildrensDayMgr.IsReconnect() then
    self._bUIReady = true
    if self._bHistoryDataReady then
      ChildrensDayMgr.SendPullHistoryInfoReq()
    end
  else
    self._paintPart:SynLineData2Server()
  end
end
def.override("boolean").OnShow = function(self, s)
  if s then
    self:UpdateRoleList()
  end
end
def.method().ToShow = function(self)
  self._bHistoryDataReady = true
  if ChildrensDayMgr.IsReconnect() and self._bUIReady then
    ChildrensDayMgr.SendPullHistoryInfoReq()
  end
end
def.method().InitUI = function(self)
  self._paintPart:OnCreate(self.m_panel, self:IsMyTurn())
  self._chatPart:OnCreate(self.m_panel, self._roles)
  local lblHint_1 = self.m_panel:FindDirect("Img_Bg0/Img_BgPrint/Group_Tips/Label_Tips1")
  local lblHint_2 = self.m_panel:FindDirect("Img_Bg0/Img_BgPrint/Group_Tips/Label_Tips2")
  local ctrlCanvasHint = self.m_panel:FindDirect("Img_Bg0/Img_BgPrint/Group_Tips/Sprite")
  lblHint_1:SetActive(false)
  lblHint_2:SetActive(false)
  self._uiGOs.lblHint_1 = lblHint_1
  self._uiGOs.lblHint_2 = lblHint_2
  self._uiGOs.ctrlCanvasHint = ctrlCanvasHint
  local panel_TeamBtn = self.m_panel:FindDirect("Img_Bg0/Group_Head/Panel_TeamBtn")
  panel_TeamBtn:SetActive(true)
  self._uiGOs.tipHead = panel_TeamBtn:FindDirect("Table_TeamBtn")
  self._uiGOs.tipHead:SetActive(false)
  local groupTime = self.m_panel:FindDirect("Img_Bg0/Img_BgPrint/Group_Time")
  local lblCDRed = groupTime:FindDirect("Label_TimeLeftR")
  local lblCDGreen = groupTime:FindDirect("Label_TimeLeftG")
  lblCDRed:SetActive(false)
  lblCDGreen:SetActive(false)
  self._uiGOs.lblCDRed = lblCDRed
  self._uiGOs.lblCDGreen = lblCDGreen
  self._uiGOs.btnGroup = self.m_panel:FindDirect("Group_Btn")
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self:Clear()
  Event.UnregisterEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.ROUND_FINISH, UIChildrensDay.OnRoundFinish)
  Event.UnregisterEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.CLOSE_PANEL, UIChildrensDay.OnClosePanel)
end
def.method().Clear = function(self)
  self._paintPart:OnDestroy()
  self._chatPart:OnDestroy()
  self._paintPart = nil
  self._chatPart = nil
  self._roles = nil
  self._uiGOs = nil
  self._curDrawerRoleId = nil
  self._timestamp = 0
  self._questionCfgData = nil
  _G.Timer:RemoveIrregularTimeListener(self.OnUpdate)
  _G.GameUtil.RemoveGlobalTimer(self._timer)
  self._timer = 0
  self._bUIReady = false
  self._bHistoryDataReady = false
end
def.method("table", "userdata", "number", "number").ShowPanel = function(self, roles, curDrawerId, timestamp, QuestionId)
  if self:IsLoaded() then
    return
  end
  self._roles = roles
  self._questionCfgData = ChildrensDayUtils.GetQAContentById(QuestionId)
  self._curDrawerRoleId = curDrawerId
  self:CreatePanel(RESPATH.PREFAB_DRAWBOARD, 1)
  self:SetModal(true)
  self._timestamp = timestamp
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("id = " .. id)
  self._uiGOs.tipHead:SetActive(false)
  if id == "Btn_Close" then
    CommonConfirmDlg.ShowConfirm("", textRes.Festival.ChildrensDay[12], function(select)
      if select == 1 then
        self:HidePanel()
      end
    end, nil)
  elseif string.find(id, "Img_Head_%d") ~= nil then
    local idx = tonumber(string.sub(id, string.find(id, "%d")))
    warn("idx = " .. idx)
    self._clickedHeadCtrl = clickObj
    local roleInfo = self._roles[idx]
    UIChildrensDay.OnSGetRoleInfoRes(roleInfo)
  elseif self._chatPart:onClick(id) then
  elseif self._paintPart:onClick(id) then
  end
end
def.method("string", "userdata").onSubmit = function(self, id, ctrl)
  self._chatPart:onSubmit(id, ctrl)
end
def.method().UpdateUI = function(self)
  _G.Timer:RemoveIrregularTimeListener(self.OnUpdate)
  self:UpdateRoleList()
  local lblHint = self._uiGOs.lblHint_2
  local lblQuestion = self._uiGOs.lblHint_1
  local timeDiff = _G.GetServerTime() - self._timestamp
  local bNeedStartCD = true
  if timeDiff > self._rules.startCDTime then
    timeDiff = timeDiff - self._rules.startCDTime
    bNeedStartCD = false
  end
  self._leftTime = self._rules.startCDTime - math.floor(timeDiff)
  warn(">>>>UpdateUI _leftTime =" .. self._leftTime)
  if self:IsMyTurn() then
    lblQuestion:SetActive(true)
    lblHint:SetActive(false)
    GUIUtils.SetText(lblQuestion, self._questionCfgData.title)
    self._paintPart:SetImgHintVisible(true)
    self._uiGOs.btnGroup:SetActive(true)
    self._chatPart:EnableChat(false)
  else
    lblQuestion:SetActive(false)
    lblHint:SetActive(true)
    GUIUtils.SetText(lblHint, textRes.Festival.ChildrensDay[13] .. self._questionCfgData.reminder)
    self._uiGOs.btnGroup:SetActive(false)
    self._paintPart:SetImgHintVisible(false)
    self._chatPart:EnableChat(true)
  end
  if bNeedStartCD then
    self._uiGOs.lblCDGreen:SetActive(false)
    self._uiGOs.lblCDRed:SetActive(true)
    GUIUtils.SetText(self._uiGOs.lblCDRed, math.floor(self._leftTime))
    self._timer = _G.GameUtil.AddGlobalTimer(1, false, function()
      if self._uiGOs == nil then
        return
      end
      self._leftTime = self._leftTime - 1
      GUIUtils.SetText(self._uiGOs.lblCDRed, math.floor(self._leftTime))
      if self._leftTime <= 0 then
        _G.GameUtil.RemoveGlobalTimer(self._timer)
        self._timer = 0
        self._leftTime = self._rules.RoundTime
        warn(">>>RoundTime = " .. self._leftTime)
        _G.Timer:RegisterIrregularTimeListener(self.OnUpdate, self)
      end
    end)
  else
    self._leftTime = self._rules.RoundTime - timeDiff
    warn(">>>RoundTime = " .. self._leftTime)
    _G.Timer:RegisterIrregularTimeListener(self.OnUpdate, self)
  end
end
def.method().UpdateRoleList = function(self)
  local ctrlList = self.m_panel:FindDirect("Img_Bg0/Group_Head/List")
  if self._roles ~= nil then
    local uiList = GUIUtils.InitUIList(ctrlList, #self._roles)
    self._uiGOs.uiRoleList = uiList
    for i = 1, #self._roles do
      local ctrlRole = uiList[i]
      local ctrlImgRoot = ctrlRole:FindDirect(("Img_Head_%d"):format(i))
      local imgHead = ctrlImgRoot:FindDirect(("Img_Icon_%d"):format(i))
      local lblState = ctrlRole:FindDirect(("Label_State_%d"):format(i))
      local lblName = ctrlImgRoot:FindDirect(("Label_Name_%d"):format(i))
      local lblScore = ctrlImgRoot:FindDirect(("Label_Score_%d"):format(i))
      local lblLv = ctrlImgRoot:FindDirect(("Label_Lv_%d"):format(i))
      local roleInfo = self._roles[i]
      if _G.SetAvatarIcon == nil then
        GUIUtils.SetSprite(imgHead, GUIUtils.GetHeadSpriteName(roleInfo.occupation, roleInfo.gender))
      else
        _G.SetAvatarIcon(imgHead, roleInfo.avatarId)
      end
      local uiSprite = ctrlImgRoot:GetComponent("UISprite")
      if uiSprite then
        local w, h = uiSprite.width, uiSprite.height
        local depth = uiSprite.depth
        GameObject.DestroyImmediate(uiSprite)
        local uiTex = ctrlImgRoot:AddComponent("UITexture")
        uiTex.width, uiTex.height = w + 20, h + 20
        uiTex.depth = depth
        _G.SetAvatarFrameIcon(ctrlImgRoot, roleInfo.avatarFrameId)
      end
      if roleInfo.state == nil or roleInfo.state == 0 then
        GUIUtils.SetActive(lblState, false)
      else
        GUIUtils.SetActive(lblState, true)
      end
      GUIUtils.SetText(lblName, roleInfo.name)
      GUIUtils.SetText(lblScore, roleInfo.integral or 0)
      GUIUtils.SetText(lblLv, roleInfo.level or 0)
    end
  else
    local uiList = GUIUtils.InitUIList(ctrlList, 0)
    self._uiGOs.uiRoleList = uiList
  end
end
def.method("userdata", "number", "number").UpdateRoleState = function(self, roleId, QuestionId, timestamp)
  if self._roles == nil then
    return
  end
  for i = 1, #self._roles do
    local roleInfo = self._roles[i]
    if roleInfo.roleid == roleId then
      roleInfo.state = 1
    else
      roleInfo.state = 0
    end
  end
  self._curDrawerRoleId = roleId
  self._questionCfgData = ChildrensDayUtils.GetQAContentById(QuestionId)
  self._timestamp = timestamp
  self:UpdateUI()
  if self._paintPart then
    self._paintPart:UpdateDrawer(self:IsMyTurn())
  end
end
def.method("number").OnUpdate = function(self, dt)
  if self.m_panel then
    self._leftTime = self._leftTime - dt
    if self._leftTime <= 0 then
      _G.Timer:RemoveIrregularTimeListener(self.OnUpdate)
      self._uiGOs.lblCDGreen:SetActive(false)
      self._uiGOs.lblCDRed:SetActive(false)
      return
    end
    self._uiGOs.lblCDGreen:SetActive(true)
    self._uiGOs.lblCDRed:SetActive(false)
    local str = textRes.Festival.ChildrensDay[20]:format(math.floor(self._leftTime))
    GUIUtils.SetText(self._uiGOs.lblCDGreen, str)
  end
end
def.method("=>", "boolean").IsMyTurn = function(self)
  return self._curDrawerRoleId == require("Main.Hero.HeroModule").Instance().roleId
end
def.static("table", "table").OnRoundFinish = function(p, c)
  local self = UIChildrensDay.Instance()
  if not self:IsLoaded() then
    return
  end
  local UIAnswerTips = require("Main.Festival.ChildrensDay.ui.UIAnswerTips")
  local uiDlg = UIAnswerTips.Instance()
  local answer = p[1]
  uiDlg:ShowPanel(self._roles, {answer}, self._curDrawerRoleId)
end
def.static("table", "table").OnClosePanel = function(p, c)
end
def.static("table").OnSGetRoleInfoRes = function(p)
  local roleInfo = p
  local self = UIChildrensDay.Instance()
  if not self:IsLoaded() then
    return
  end
  self._uiGOs.tipHead:SetActive(true)
  local ctrlRoot = self._uiGOs.tipHead:FindDirect("Img_Head")
  local imgHead = ctrlRoot:FindDirect("Img_Icon")
  local lblName = ctrlRoot:FindDirect("Label_Name")
  local lblLv = ctrlRoot:FindDirect("Label_Lv")
  GUIUtils.SetText(lblName, roleInfo.roleName)
  GUIUtils.SetText(lblLv, roleInfo.level)
  if _G.SetAvatarIcon == nil then
    GUIUtils.SetSprite(imgHead, GUIUtils.GetHeadSpriteName(roleInfo.occupation, roleInfo.gender))
  else
    _G.SetAvatarIcon(imgHead, roleInfo.avatarId)
  end
  local uiSprite = ctrlRoot:GetComponent("UISprite")
  if uiSprite then
    local w, h = uiSprite.width, uiSprite.height
    local depth = uiSprite.depth
    GameObject.DestroyImmediate(uiSprite)
    local uiTex = ctrlRoot:AddComponent("UITexture")
    uiTex.width, uiTex.height = w + 20, h + 20
    uiTex.depth = depth
  end
  _G.SetAvatarFrameIcon(ctrlRoot, roleInfo.avatarFrameId)
end
return UIChildrensDay.Commit()
