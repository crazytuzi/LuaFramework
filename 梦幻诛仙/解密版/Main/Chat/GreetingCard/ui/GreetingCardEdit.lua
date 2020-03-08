local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GreetingCardEdit = Lplus.Extend(ECPanelBase, "GreetingCardEdit")
local EC = require("Types.Vector3")
local ChatInputDlg = require("Main.Chat.ui.ChatInputDlg")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local Vector = require("Types.Vector")
local MathHelper = require("Common.MathHelper")
local def = GreetingCardEdit.define
local instance
def.static("=>", GreetingCardEdit).Instance = function()
  if instance == nil then
    instance = GreetingCardEdit()
  end
  return instance
end
def.field("function").callback = nil
def.field("table").cfg = nil
def.field("number").card = 1
def.field("userdata").cardGo = nil
def.field("string").currentPath = ""
def.field("number").emojiPage = 12
def.static("table", "function").ShowGreetingCardEdit = function(cfg, cb)
  if cfg == nil then
    return
  end
  local self = GreetingCardEdit.Instance()
  self.cfg = cfg
  self.callback = cb
  self.currentPath = ""
  self.cardGo = nil
  self.card = 1
  self:CreatePanel(RESPATH.PREFAB_GREETING_CARD_EDIT, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  ChatInputDlg.Instance():Load()
  self:SetDesc()
  self:UpdateTemplate()
  self:SelectCard(self.card)
  local emoji = self.m_panel:FindDirect("Img_Bg0/Panel_Emoji")
  emoji:SetActive(false)
end
def.method().SetDesc = function(self)
  local descLbl = self.m_panel:FindDirect("Img_Bg0/Label_Tips")
  descLbl:GetComponent("UILabel"):set_text(self.cfg.desc or "")
end
def.method().ToggleEmoji = function(self)
  local emojiGO = self.m_panel:FindDirect("Img_Bg0/Panel_Emoji")
  if emojiGO:get_activeInHierarchy() then
    emojiGO:SetActive(false)
    local pages = self.m_panel:FindDirect("Img_Bg0/Panel_Emoji/Group_Emoji/Group_01/Scroll View01/Grid_Page01")
    while pages:get_childCount() > 1 do
      Object.DestroyImmediate(pages:GetChild(pages:get_childCount() - 1))
    end
    local emojiGrid01 = self.m_panel:FindDirect("Img_Bg0/Panel_Emoji/Group_Emoji/Group_01/Scroll View01/Grid_Page01/Page01/Grid_01")
    while emojiGrid01:get_childCount() > 1 do
      Object.DestroyImmediate(emojiGrid01:GetChild(emojiGrid01:get_childCount() - 1))
    end
  else
    self:SetEmoji()
  end
end
def.method().SetEmoji = function(self)
  if not ChatInputDlg.Instance().loaded then
    ChatInputDlg.Instance():Load()
    return
  end
  local emojiPanel = self.m_panel:FindDirect("Img_Bg0/Panel_Emoji")
  emojiPanel:SetActive(true)
  local pages = self.m_panel:FindDirect("Img_Bg0/Panel_Emoji/Group_Emoji/Group_01/Scroll View01/Grid_Page01")
  while pages:get_childCount() > 1 do
    Object.DestroyImmediate(pages:GetChild(pages:get_childCount() - 1))
  end
  local emojiGrid01 = self.m_panel:FindDirect("Img_Bg0/Panel_Emoji/Group_Emoji/Group_01/Scroll View01/Grid_Page01/Page01/Grid_01")
  while emojiGrid01:get_childCount() > 1 do
    Object.DestroyImmediate(emojiGrid01:GetChild(emojiGrid01:get_childCount() - 1))
  end
  emojiGrid01:GetChild(0):SetActive(false)
  local pageCount = math.ceil(ChatInputDlg.Instance().emojiCount / self.emojiPage)
  local emojiGroup = self.m_panel:FindDirect("Img_Bg0/Panel_Emoji/Group_Emoji/Group_01/Scroll View01/Grid_Page01")
  local emojiPageTemplate = self.m_panel:FindDirect("Img_Bg0/Panel_Emoji/Group_Emoji/Group_01/Scroll View01/Grid_Page01/Page01")
  for i = 2, pageCount do
    local emojiPage = Object.Instantiate(emojiPageTemplate)
    emojiPage.name = string.format("Page%02d", i)
    emojiPage.parent = emojiGroup
    emojiPage:set_localScale(Vector.Vector3.one)
  end
  emojiGroup:GetComponent("UIGrid"):Reposition()
  local emojiTemplate = self.m_panel:FindDirect("Img_Bg0/Panel_Emoji/Group_Emoji/Group_01/Scroll View01/Grid_Page01/Page01/Grid_01/emoji")
  local curIndex = 1
  for k, v in ipairs(ChatInputDlg.Instance().emojis) do
    local emoji = Object.Instantiate(emojiTemplate)
    emoji.name = string.format("emoji_%s", v)
    local page = math.ceil(curIndex / self.emojiPage)
    emoji.parent = emojiGroup:FindDirect(string.format("Page%02d/Grid_01", page))
    emoji:set_localScale(Vector.Vector3.one)
    local spriteAni = emoji:GetComponent("UISpriteAnimation")
    spriteAni:set_namePrefix(v)
    spriteAni:set_framesPerSecond(5)
    emoji:SetActive(true)
    curIndex = curIndex + 1
  end
  for i = 1, pageCount do
    local page = emojiGroup:FindDirect(string.format("Page%02d/Grid_01", i))
    page:GetComponent("UIGrid"):Reposition()
  end
  self:resetPoints(pageCount)
  self.m_msgHandler:Touch(emojiPanel)
end
def.method("number").resetPoints = function(self, pageCount)
  local points = self.m_panel:FindDirect("Img_Bg0/Panel_Emoji/Group_Emoji/Group_01/Img_Bg1/Grid_Pages")
  while points:get_childCount() > 1 do
    Object.DestroyImmediate(points:GetChild(points:get_childCount() - 1))
  end
  local pointtemplate = points:FindDirect("Img_Pages00")
  pointtemplate:SetActive(false)
  for i = 1, pageCount do
    local point = Object.Instantiate(pointtemplate)
    point.name = string.format("Img_Pages%02d", i)
    point.parent = points
    point:set_localScale(Vector.Vector3.one)
    point:SetActive(true)
    if i == 1 then
      point:GetComponent("UIToggle"):set_value(true)
    end
  end
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if points and not points.isnil then
      points:GetComponent("UIGrid"):Reposition()
    end
  end)
end
def.method().UpdateTemplate = function(self)
  local count = #self.cfg.words
  local list = self.m_panel:FindDirect("Img_Bg0/Group_Ext/List_Content")
  local listCmp = list:GetComponent("UIList")
  listCmp:set_itemCount(count)
  listCmp:Resize()
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local nameLbl = uiGo:FindDirect(string.format("Content_Name_%d", i))
    local name = textRes.Chat[84] .. MathHelper.Arabic2Chinese(i)
    nameLbl:GetComponent("UILabel"):set_text(name)
    self.m_msgHandler:Touch(uiGo)
  end
  local count = #self.cfg.cards
  local list = self.m_panel:FindDirect("Img_Bg0/Group_Card/List_Card")
  local listCmp = list:GetComponent("UIList")
  listCmp:set_itemCount(count)
  listCmp:Resize()
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local nameLbl = uiGo:FindDirect(string.format("Card_Name_%d", i))
    local name = textRes.Chat[85] .. MathHelper.Arabic2Chinese(i)
    nameLbl:GetComponent("UILabel"):set_text(name)
    self.m_msgHandler:Touch(uiGo)
  end
end
def.method("number").SelectCard = function(self, select)
  self:DestroyCard()
  local cardUIPath = self.cfg.cards[select]
  if not cardUIPath then
    return
  end
  local name = self.cfg.names[select]
  if not name then
    return
  end
  local function onLoad(obj)
    if self.m_panel and not self.m_panel.isnil and obj and cardUIPath == self.currentPath then
      local cardGo = Object.Instantiate(obj)
      self.cardGo = cardGo
      local root = self.m_panel:FindDirect("Img_Bg0/Group_EffectPreview/Point_Card")
      self.cardGo.parent = root
      local panelDepth = self.m_panel:GetComponent("UIPanel"):get_depth()
      self.cardGo:GetComponent("UIPanel"):set_depth(panelDepth + 1)
      self.cardGo.localScale = EC.Vector3.new(0.82, 0.82, 1)
      self.cardGo.localPosition = EC.Vector3.zero
      self:UpdateCard()
    end
  end
  self.currentPath = cardUIPath
  self.card = select
  GameUtil.AsyncLoad(self:makePath(self.currentPath), onLoad)
  local nameLbl = self.m_panel:FindDirect("Img_Bg0/Group_EffectPreview/Label_Select")
  nameLbl:GetComponent("UILabel"):set_text(string.format(textRes.Chat[86], name))
end
def.method("string", "=>", "string").makePath = function(self, prefabName)
  return string.format("Arts/Prefab/%s.prefab.u3dext", prefabName)
end
def.method("number").SelectWord = function(self, select)
  local cardWrod = self.cfg.words[select]
  if not cardWrod then
    return
  end
  self:SetInput(cardWrod)
  self:UpdateCard()
end
local emojiMap = {}
def.method("string").SetInput = function(self, content)
  local input = self.m_panel:FindDirect("Img_Bg0/Group_ChatInput/Img_BgInput")
  input:GetComponent("UIInput"):set_value(content)
end
def.method("=>", "string").GetInput = function(self)
  local input = self.m_panel:FindDirect("Img_Bg0/Group_ChatInput/Img_BgInput")
  local text = input:GetComponent("UIInput"):get_value()
  local hasInfoPackStr = string.gsub(text, "[\001-\a]", function(str)
    local infoStr = emojiMap[str:byte(1)]
    if infoStr then
      return infoStr
    else
      return ""
    end
  end)
  hasInfoPackStr = HtmlHelper.ConvertHtmlKeyWord(hasInfoPackStr)
  return hasInfoPackStr
end
def.method("string").AddEmoji = function(self, emojiName)
  local name = string.format("#%s", emojiName)
  local cipher = string.format("{e:%s}", emojiName)
  local input = self.m_panel:FindDirect("Img_Bg0/Group_ChatInput/Img_BgInput")
  local code = input:GetComponent("UIInput"):Insert(name, true)
  if code > 0 then
    emojiMap[code] = cipher
    self:UpdateCard()
  else
    Toast(textRes.Chat[30])
  end
end
def.method().DestroyCard = function(self)
  if self.cardGo and not self.cardGo.isnil then
    Object.Destroy(self.cardGo)
  end
  self.cardGo = nil
end
def.method().UpdateCard = function(self)
  if self.cardGo and not self.cardGo.isnil then
    local colorLbl = self.cardGo:FindDirect("Img_Bg0/Label_Color")
    local lblCmp = colorLbl:GetComponent("UILabel")
    local color = lblCmp:get_textColor()
    local r = color:get_r() * 256
    local g = color:get_g() * 256
    local b = color:get_b() * 256
    local colorStr = string.format("#%02x%02x%02x", r, g, b)
    local word = self.cardGo:FindDirect("Img_Bg0/Label_Content")
    local text = self:GetInput()
    text = HtmlHelper.ConvertEmoji(text)
    word:GetComponent("NGUIHTML"):ForceHtmlText(string.format("<p align=left valign=middle linespacing=10><font color=%s size=22>%s</font></p>", colorStr, text))
  end
end
def.override().OnDestroy = function(self)
  self:DestroyCard()
  self.callback = nil
  self.cfg = nil
  self.card = 1
  self.currentPath = ""
  emojiMap = {}
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Look" then
    self:ToggleEmoji()
  elseif string.sub(id, 1, 8) == "Content_" then
    local index = tonumber(string.sub(id, 9))
    if index then
      self:SelectWord(index)
    end
  elseif string.sub(id, 1, 5) == "Card_" then
    local index = tonumber(string.sub(id, 6))
    if index then
      self:SelectCard(index)
    end
  elseif id == "Btn_Send" then
    do
      local function send(channel)
        local text = self:GetInput()
        if text and text ~= "" then
          if SensitiveWordsFilter.ContainsSensitiveWord(text) then
            Toast(textRes.Chat[79])
          else
            if self.callback then
              self.callback(text, self.card, channel)
            end
            self:DestroyPanel()
          end
        else
          Toast(textRes.Chat[80])
        end
      end
      local btn = self.m_panel:FindDirect("Img_Bg0/Btn_Send")
      if btn == nil then
        return
      end
      local position = btn:get_position()
      local screenPos = WorldPosToScreen(position.x, position.y)
      local sprite = btn:GetComponent("UISprite")
      local pos = {
        auto = true,
        sourceX = screenPos.x,
        sourceY = screenPos.y,
        sourceW = sprite:get_width(),
        sourceH = sprite:get_height(),
        prefer = -1
      }
      local btns = {
        {
          name = textRes.Chat[82]
        },
        {
          name = textRes.Chat[83]
        }
      }
      require("GUI.ButtonGroupPanel").ShowPanel(btns, pos, function(index)
        if index == 1 then
          if require("Main.Gang.GangModule").Instance():HasGang() then
            send(require("Main.Chat.ChatMsgData").Channel.FACTION)
          else
            Toast(textRes.Chat[61])
          end
        elseif index == 2 then
          send(require("Main.Chat.ChatMsgData").Channel.WORLD)
        end
      end)
    end
  elseif string.sub(id, 1, 6) == "emoji_" then
    local emojiName = string.sub(id, 7)
    self:AddEmoji(emojiName)
  elseif id == "Btn_Clear" then
    self:SetInput("")
  end
end
def.method("string", "string").onTextChange = function(self, id, val)
  if id == "Img_BgInput" then
    self:UpdateCard()
  end
end
def.method("string", "userdata", "number", "table").onSpringFinish = function(self, id, scrollView, type, position)
  if self.m_panel == nil or self.m_panel.isnil or type ~= 0 then
    return
  end
  local centerOnChild = scrollView:GetChild(0):GetComponent("UICenterOnChild")
  if centerOnChild then
    local conterObject = centerOnChild:get_centeredObject()
    local index = tonumber(string.sub(conterObject.name, -2, -1))
    local toggleObj = self.m_panel:FindDirect(string.format("Img_Bg0/Panel_Emoji/Group_Emoji/Group_01/Img_Bg1/Grid_Pages/Img_Pages%02d", index))
    if toggleObj ~= nil then
      local pointToggle = toggleObj:GetComponent("UIToggle")
      if pointToggle ~= nil then
        pointToggle:set_value(true)
      end
    end
  end
end
return GreetingCardEdit.Commit()
