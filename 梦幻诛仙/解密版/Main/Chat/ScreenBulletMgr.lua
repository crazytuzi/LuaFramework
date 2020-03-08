local Lplus = require("Lplus")
local ScreenBulletMgr = Lplus.Class("ScreenBulletMgr")
local def = ScreenBulletMgr.define
local ChatConsts = require("netio.protocol.mzm.gsp.chat.ChatConsts")
local ScreenBullet = require("Main.Chat.ui.ScreenBullet")
local ChatMsgBuilder = require("Main.Chat.ChatMsgBuilder")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local instance
def.static("=>", ScreenBulletMgr).Instance = function()
  if instance == nil then
    instance = ScreenBulletMgr()
  end
  return instance
end
def.field("number").levelLimit = 0
def.field("number").timeLag = 0
def.field("number").energyConsume = 0
def.field("number").lastTime = 0
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SChatInAllMap", ScreenBulletMgr.OnMapBullet)
  local ChannelType = require("consts.mzm.gsp.chat.confbean.ChannelType")
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHANEL_CFG, ChannelType.CHANNEL_ALL_MAP)
  if record then
    self.levelLimit = record:GetIntValue("levelMin")
    self.timeLag = record:GetIntValue("timeLag")
    self.energyConsume = record:GetIntValue("energyConsume")
    self.lastTime = 0
  end
end
def.method("string", "=>", "boolean").SendMapBullet = function(self, cnt)
  local leftTime = os.time() - self.lastTime - self.timeLag
  if leftTime <= 0 then
    Toast(string.format(textRes.Chat[18], leftTime == 0 and 1 or 0 - leftTime))
    return false
  end
  local level = require("Main.Hero.Interface").GetBasicHeroProp().level
  if level < self.levelLimit then
    Toast(string.format(textRes.Chat[17], self.levelLimit))
    return false
  end
  local myVigorNum = require("Main.Hero.Interface").GetHeroProp().energy or 0
  if myVigorNum < self.energyConsume then
    Toast(textRes.Chat.error[23])
    return false
  end
  local mapId = gmodule.moduleMgr:GetModule(ModuleId.MAP).currentMapId
  local contentType = ChatConsts.CONTENT_BULLET
  local chatContent = require("netio.Octets").rawFromString(cnt)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CChatInAllMapReq").new(mapId, contentType, chatContent))
  self.lastTime = os.time()
  return true
end
def.static("table").OnMapBullet = function(p)
  if ScreenBullet.IsSetup() then
    warn("OnMapBullet", p.content.contentType, p.map_cfg_id, p.content.roleName)
    if p.content.contentType ~= ChatConsts.CONTENT_BULLET then
      return
    end
    local mapId = gmodule.moduleMgr:GetModule(ModuleId.MAP).currentMapId
    if mapId ~= p.map_cfg_id then
      return
    end
    local content = ChatMsgBuilder.Unmarshal(p.content.content)
    content = ChatMsgBuilder.CustomFilter(content)
    local html = HtmlHelper.ConvertInfoPack(content)
    if p.content.roleId == GetMyRoleID() then
      html = string.format("<font color=#c485a7>%s</font>", html)
    end
    ScreenBullet.AddBullet(html)
  end
end
def.method().SetupBullet = function(self)
  if not ScreenBullet.IsSetup() then
    ScreenBullet.Setup()
  end
  require("Main.Chat.ui.ScreenBulletInput").ShowScreenBulletInput()
end
def.method().UninstallBullet = function(self)
  if ScreenBullet.IsSetup() then
    ScreenBullet.Uninstall()
  end
  require("Main.Chat.ui.ScreenBulletInput").CloseScreenBulletInput()
end
ScreenBulletMgr.Commit()
return ScreenBulletMgr
