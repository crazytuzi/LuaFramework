local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Bandit = Lplus.Extend(ECPanelBase, "Bandit")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local NumberScroll = require("Main.AllLotto.ui.NumberScroll")
local AllLottoUtils = require("Main.AllLotto.AllLottoUtils")
local def = Bandit.define
local instance
def.static("=>", Bandit).Instance = function()
  if instance == nil then
    instance = Bandit()
    instance.m_ChangeLayerOnShow = true
  end
  return instance
end
def.field("userdata").m_code = nil
def.field("table").m_scrollNumbers = nil
def.field("number").m_activityId = 0
def.field("number").m_turn = 0
def.field("table").m_roleInfo = nil
def.field("function").m_endCallback = nil
def.field("number").m_timer = 0
def.static("userdata", "number", "number", "table", "function").ShowResult = function(code, activityId, turn, roleInfo, cb)
  local self = Bandit.Instance()
  if self:IsShow() then
    self:DestroyPanel()
  end
  self.m_code = code
  self.m_activityId = activityId
  self.m_turn = turn
  self.m_roleInfo = roleInfo
  self.m_endCallback = cb
  self:CreatePanel(RESPATH.PREFAB_ALLLOTTO_ANNO, 0)
end
def.override().OnCreate = function(self)
  self:UpdateItem()
  self:HideLuckyGuy()
  self:InitScroll()
end
def.override("boolean").OnShow = function(self, show)
end
def.override().OnDestroy = function(self)
  GameUtil.RemoveGlobalTimer(self.m_timer)
  self.m_timer = 0
  if self.m_scrollNumbers then
    for k, v in pairs(self.m_scrollNumbers) do
      v:Destroy()
    end
    self.m_scrollNumbers = nil
  end
  self.m_code = nil
  self.m_activityId = 0
  self.m_turn = 0
  self.m_roleInfo = nil
  self.m_endCallback = nil
end
def.method().UpdateItem = function(self)
  local turnCfg = AllLottoUtils.GetAllLottoTurnCfg(self.m_activityId, self.m_turn)
  if turnCfg then
    local items = ItemUtils.GetAwardItems(turnCfg.awardId)
    if items and items[1] then
      local itemBase = ItemUtils.GetItemBase(items[1].itemId)
      if itemBase then
        local iconBg = self.m_panel:FindDirect("Img_Bg/Group_Content/Img_ItemGet")
        local icon = iconBg:FindDirect("Img_Icon")
        iconBg:GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", itemBase.namecolor))
        GUIUtils.FillIcon(icon:GetComponent("UITexture"), itemBase.icon)
      end
    end
  end
end
def.method().HideLuckyGuy = function(self)
  local roleInfoUI = self.m_panel:FindDirect("Img_Bg/Group_Content/Group_Info")
  roleInfoUI:SetActive(false)
  local effect = self.m_panel:FindDirect("Img_Bg/Group_Content/Point_Effect")
  effect:SetActive(true)
end
def.method().ShowLuckGuy = function(self)
  local roleInfoUI = self.m_panel:FindDirect("Img_Bg/Group_Content/Group_Info")
  roleInfoUI:SetActive(true)
  local effect = self.m_panel:FindDirect("Img_Bg/Group_Content/Point_Effect")
  effect:SetActive(false)
  if self.m_roleInfo == nil then
    return
  end
  local headFrame = roleInfoUI:FindDirect("Img_BgIconGroup")
  local head = headFrame:FindDirect("Texture_IconGroup")
  local lv = roleInfoUI:FindDirect("Label_Lv")
  local nameLbl = roleInfoUI:FindDirect("Label_CharactorName")
  local serverNameLbl = roleInfoUI:FindDirect("Label_ServerName")
  local occupation = roleInfoUI:FindDirect("Img_SchoolIcon")
  local gender = roleInfoUI:FindDirect("Img_Sex")
  SetAvatarIcon(head, self.m_roleInfo.avatarid)
  SetAvatarFrameIcon(headFrame, self.m_roleInfo.avatar_frameid)
  lv:GetComponent("UILabel"):set_text(tostring(self.m_roleInfo.level))
  nameLbl:GetComponent("UILabel"):set_text(GetStringFromOcts(self.m_roleInfo.role_name) or "")
  local serverName = ""
  local serverInfo = GetRoleServerInfo(self.m_roleInfo.roleid)
  if serverInfo then
    serverName = serverInfo.name
  end
  serverNameLbl:GetComponent("UILabel"):set_text(serverName)
  occupation:GetComponent("UISprite"):set_spriteName(GUIUtils.GetOccupationSmallIcon(self.m_roleInfo.occupation))
  gender:GetComponent("UISprite"):set_spriteName(GUIUtils.GetGenderSprite(self.m_roleInfo.gender))
end
def.method().InitScroll = function(self)
  self.m_scrollNumbers = {}
  local idGroup = self.m_panel:FindDirect("Img_Bg/Group_Content/Group_Id/Scrollview_Id/Grid")
  for i = 0, 9 do
    local uiGo = idGroup:FindDirect(string.format("Group_Id_%d", i))
    self.m_scrollNumbers[i] = NumberScroll.New(uiGo)
  end
  GameUtil.AddGlobalTimer(1, true, function()
    if self.m_panel and not self.m_panel.isnil then
      self:Begin()
    end
  end)
  GameUtil.AddGlobalTimer(5, true, function()
    if self.m_panel and not self.m_panel.isnil then
      self:End()
    end
  end)
end
def.method().Begin = function(self)
  for i = 0, 9 do
    GameUtil.AddGlobalTimer((9 - i) * 0.1, true, function()
      if self.m_panel and not self.m_panel.isnil then
        self.m_scrollNumbers[i]:Begin()
      end
    end)
  end
end
def.method().End = function(self)
  local codeStr = tostring(self.m_code or 0)
  local endCount = 0
  local function scrollEnd()
    endCount = endCount + 1
    if endCount >= 10 then
      self:ShowLuckGuy()
      if self.m_endCallback then
        self.m_endCallback(true)
        self.m_endCallback = nil
      end
      self.m_timer = GameUtil.AddGlobalTimer(8, true, function()
        self:DestroyPanel()
      end)
    end
  end
  local reverseCodeStr = string.reverse(codeStr)
  for i = 0, 9 do
    do
      local idStr = string.sub(reverseCodeStr, i + 1, i + 1)
      local id = idStr and tonumber(idStr) or 0
      local pos = 9 - i
      local delay = pos * 1.1
      GameUtil.AddGlobalTimer(delay, true, function()
        if self.m_panel and not self.m_panel.isnil then
          self.m_scrollNumbers[i]:End(id, scrollEnd)
        end
      end)
    end
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    if self.m_endCallback then
      self.m_endCallback(false)
      self.m_endCallback = nil
    end
    self:DestroyPanel()
  elseif id == "Img_ItemGet" then
    local turnCfg = AllLottoUtils.GetAllLottoTurnCfg(self.m_activityId, self.m_turn)
    if turnCfg then
      local items = ItemUtils.GetAwardItems(turnCfg.awardId)
      if items and items[1] then
        local itemId = items[1].itemId
        local icon = self.m_panel:FindDirect("Img_Bg/Group_Content/Img_ItemGet")
        require("Main.Item.ItemTipsMgr").Instance():ShowBasicTipsWithGO(itemId, icon, 0, false)
      end
    end
  end
end
Bandit.Commit()
return Bandit
