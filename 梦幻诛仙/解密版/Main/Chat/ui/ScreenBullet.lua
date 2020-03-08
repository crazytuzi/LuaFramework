local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ScreenBullet = Lplus.Extend(ECPanelBase, "ScreenBullet")
local EC = require("Types.Vector")
local GUIMan = require("GUI.ECGUIMan")
local def = ScreenBullet.define
local instance
def.field("number").maxInScreen = 32
def.field("number").beginY = 16
def.field("number").fontSize = 32
def.field("number").lineSpace = 16
def.field("number").lines = 10
def.field("number").k1 = -16
def.field("number").k2 = 8000
def.field("number").k3 = 128
def.field("number").liveTime = 6000
def.field("userdata").cache = nil
def.field("userdata").template = nil
def.field("table").curBulletData = nil
def.field("table").nameTable = nil
def.field("table").waitQueue = nil
def.static("=>", ScreenBullet).Instance = function()
  if instance == nil then
    instance = ScreenBullet()
    instance:SetDepth(6)
  end
  return instance
end
def.static().Setup = function()
  ScreenBullet.Instance():CreatePanel(RESPATH.PREFAB_DANMU, 0)
end
def.static().Uninstall = function()
  ScreenBullet.Instance():DestroyPanel()
end
def.static("=>", "boolean").IsSetup = function()
  return ScreenBullet.Instance():IsShow()
end
def.static("string").AddBullet = function(cnt)
  if ScreenBullet.Instance():IsShow() then
    ScreenBullet.Instance():_AddBullet(cnt)
  end
end
def.override().OnCreate = function(self)
  self.cache = self.m_panel:FindDirect("Cache")
  self.template = self.cache:FindDirect("Html")
  local htmlCmp = self.template:GetComponent("NGUIHTML")
  htmlCmp:set_maxLineWidth(self.fontSize * 128)
  self:SetData()
end
def.method().SetData = function(self)
  self.curBulletData = {}
  local tick = GameUtil.GetTickCount()
  for i = 1, self.lines do
    self.curBulletData[i] = {startTime = 0, length = 0}
  end
  self.nameTable = {}
  for i = 1, self.maxInScreen do
    self.nameTable[i] = true
  end
  self.waitQueue = {}
end
def.method("=>", "string").GetName = function(self)
  for k, v in pairs(self.nameTable) do
    if v then
      self.nameTable[k] = false
      return tostring(k)
    end
  end
  return ""
end
def.method("number").GiveName = function(self, nameId)
  self.nameTable[nameId] = true
end
def.override().OnDestroy = function(self)
end
def.method("string")._AddBullet = function(self, cnt)
  local name = self:GetName()
  if name == "" then
    table.insert(self.waitQueue, cnt)
    return
  end
  local selectLine = self:SelectLine()
  local bullet = self:GetOneObject()
  local htmlStr = self:ConvertHtml(cnt)
  bullet.name = "bullet_" .. name
  bullet.parent = self.m_panel
  bullet.localScale = EC.Vector3.one
  self.m_msgHandler:Touch(bullet)
  local label = bullet:GetComponent("NGUIHTML")
  label:ForceHtmlText(htmlStr)
  local curTick = GameUtil.GetTickCount()
  local lastBullet = self.curBulletData[selectLine]
  local screenHeight = GUIMan.Instance().m_uiRootCom:get_activeHeight()
  local screenWidth = screenHeight / Screen.height * Screen.width
  local y = screenHeight / 2 - self.beginY - (self.fontSize + self.lineSpace) * (selectLine - 1)
  local bulletLength = label:TotalWidth() + self.fontSize * 2
  local tailInTime = self.liveTime / (screenWidth + lastBullet.length) * lastBullet.length + lastBullet.startTime
  local lastTime = curTick - tailInTime
  local headOutTime = self.liveTime / (screenWidth + bulletLength) * screenWidth
  local earlyTime = curTick + headOutTime - lastBullet.startTime - self.liveTime
  if earlyTime >= 0 and lastTime >= 0 then
    local curPosition = EC.Vector3.new(screenWidth / 2, y, 0)
    local destPosition = EC.Vector3.new(-screenWidth / 2 - bulletLength, y, 0)
    local tweenPosition = bullet:GetComponent("TweenPosition")
    tweenPosition.duration = self.liveTime / 1000
    tweenPosition:set_from(curPosition)
    tweenPosition:set_to(destPosition)
    tweenPosition:ResetToBeginning()
    tweenPosition:PlayForward()
    self.curBulletData[selectLine] = {startTime = curTick, length = bulletLength}
  else
    local speed = (screenWidth + bulletLength) / self.liveTime
    local minTime = math.min(earlyTime, lastTime)
    local backDistance = minTime * speed
    local curPosition = EC.Vector3.new(screenWidth / 2 - backDistance, y, 0)
    local destPosition = EC.Vector3.new(-screenWidth / 2 - bulletLength, y, 0)
    local tweenPosition = bullet:GetComponent("TweenPosition")
    tweenPosition.duration = (self.liveTime - minTime) / 1000
    tweenPosition:set_from(curPosition)
    tweenPosition:set_to(destPosition)
    tweenPosition:ResetToBeginning()
    tweenPosition:PlayForward()
    self.curBulletData[selectLine] = {
      startTime = curTick - minTime,
      length = bulletLength
    }
  end
end
def.method().CheckWaitQueue = function(self)
  if #self.waitQueue > 0 then
    local cnt = table.remove(self.waitQueue, 1)
    self:_AddBullet(cnt)
  end
end
def.method("string", "=>", "string").ConvertHtml = function(self, cnt)
  return string.format("<font color=#FFF8A0 size=%d><effect name='outline' color=#000000>%s</effect></font>", self.fontSize, cnt)
end
def.method("=>", "number").SelectLine = function(self)
  local scoreStr = ""
  local curTick = GameUtil.GetTickCount()
  local selectLine = 1
  local minScore = (curTick - self.curBulletData[1].startTime) * self.k1 + self.curBulletData[1].length * self.k3 + 1 * self.k2
  scoreStr = scoreStr .. minScore
  for i = 2, self.lines do
    local score = (curTick - self.curBulletData[i].startTime) * self.k1 + self.curBulletData[i].length * self.k3 + i * self.k2
    scoreStr = scoreStr .. " | " .. score
    if minScore > score then
      minScore = score
      selectLine = i
    end
  end
  warn("SelectLine:", scoreStr)
  return selectLine
end
def.method("=>", "userdata").GetOneObject = function(self)
  if self.cache.childCount > 1 then
    local bullet = self.cache:GetChild(self.cache.childCount - 1)
    return bullet
  end
  local go = Object.Instantiate(self.template)
  return go
end
def.method("string").onClick = function(self, id)
end
def.method("string", "userdata").onSubmit = function(self, id, ctrl)
end
def.method("string", "string").onTweenerFinish = function(self, id, tweenId)
  if string.sub(id, 1, 7) == "bullet_" then
    local index = tonumber(string.sub(id, 8))
    local go = self.m_panel:FindDirect(id)
    if go then
      go.parent = self.cache
      self:GiveName(index)
      self:CheckWaitQueue()
    end
  end
end
def.static("number", "number").Test = function(freq, num)
  local presetText = {
    "2333",
    "23333333333333333333333",
    "66666",
    "666666666666666666666666666",
    "+1s",
    "\230\178\161\230\156\137\230\162\166\229\185\187\232\175\155\228\187\153\231\142\169\230\136\145\232\166\129\230\173\187\228\186\134",
    "\228\189\160\228\184\186\228\187\128\228\185\136\232\191\153\228\185\136\231\134\159\231\187\131\229\149\138~",
    "\228\184\141\232\166\129\230\128\130,\229\176\177\230\152\175\229\185\178",
    "\232\182\129\231\157\128\230\178\161\228\186\186,\229\129\183\229\129\183\230\137\191\229\140\133\230\162\166\229\185\187\232\175\155\228\187\153",
    "\229\137\141\230\150\185\233\171\152\232\131\189\233\162\132\232\173\166\229\137\141\230\150\185\233\171\152\232\131\189\233\162\132\232\173\166\229\137\141\230\150\185\233\171\152\232\131\189\233\162\132\232\173\166",
    "\229\188\185\229\185\149\230\138\164\228\189\147",
    "\228\184\141\231\159\165\233\129\147\228\184\186\228\187\128\228\185\136,\230\137\139\233\135\140\229\164\154\229\135\186\228\186\134\230\177\189\230\178\185\229\146\140\231\129\171\230\138\138~",
    "FFFFFFFFFFFFFFFFFFFFFFFFFF",
    "\229\166\136\229\166\136\233\151\174\230\136\145\228\184\186\228\187\128\228\185\136\232\183\170\231\157\128\231\156\139\232\167\134\233\162\145",
    "\230\136\145\232\166\129\231\157\128\231\161\172\229\184\129\230\156\137\228\189\149\231\148\168",
    "\229\143\140\230\137\139\230\137\147\229\173\151,\228\187\165\231\164\186\230\184\133\231\153\189",
    "\231\165\157\229\144\145\229\168\129\229\146\140\229\164\167\230\179\162\230\179\162\231\153\190\229\185\180\229\165\189\229\144\136,\229\141\131\229\185\180\230\136\144\231\178\190,\228\184\135\229\185\180\230\136\144\231\165\158"
  }
  local count = 0
  ScreenBullet.Setup()
  local timer
  timer = GameUtil.AddGlobalTimer(1 / freq, false, function()
    local r = math.random(#presetText)
    local text = presetText[r]
    ScreenBullet.AddBullet(text)
    count = count + 1
    if count > num then
      GameUtil.RemoveGlobalTimer(timer)
      GameUtil.AddGlobalTimer(instance.liveTime * 2, true, function()
        ScreenBullet.Uninstall()
      end)
    end
  end)
end
ScreenBullet.Commit()
return ScreenBullet
