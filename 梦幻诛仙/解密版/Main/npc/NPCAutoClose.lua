local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local NPCAutoClose = Lplus.Class("NPCAutoClose")
local def = NPCAutoClose.define
local instance
def.static("=>", NPCAutoClose).Instance = function()
  if instance == nil then
    instance = NPCAutoClose()
    instance:Init()
  end
  return instance
end
def.field("number")._pointX = 0
def.field("number")._pointY = 0
def.field("number")._mapID = 0
def.field("number")._timerID = -1
def.field(ECPanelBase)._mapID = 0
def.method().Init = function(self)
end
def.method(ECPanelBase, "number").SetFrameByNPCID = function(self, frame, npcID)
  local NPCInterface = require("Main.npc.NPCInterface")
  local npcCfg = NPCInterface.GetNPCCfg(npcID)
  local HeroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local heroPos = HeroModule.myRole:GetPos()
  if npcCfg == nil then
    self._pointX = heroPos.x
    self._pointY = heroPos.y
    local MapModule = gmodule.moduleMgr:GetModule(ModuleId.MAP)
    self._mapID = MapModule:GetMapId()
  else
    self._pointX = npcCfg.x
    self._pointY = npcCfg.y
    local pubroleModule = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
    local theNPC = pubroleModule:GetNpc(npcID)
    if theNPC ~= nil then
      local npcPos = theNPC:GetPos()
      self._pointX = npcPos.x
      self._pointY = npcPos.y
    end
    self._mapID = npcCfg.mapId
  end
  self:_SetFrame(frame)
end
def.method(ECPanelBase, "number").SetFrameByMonsterInstID = function(self, frame, monsterInstID)
  local pos = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetMonsterPos(monsterInstID)
  if pos == nil then
    return
  end
  local MapModule = gmodule.moduleMgr:GetModule(ModuleId.MAP)
  self._mapID = MapModule:GetMapId()
  self._pointX = pos.x
  self._pointY = pos.y
  self:_SetFrame(frame)
end
def.method(ECPanelBase, "number", "number").SetFrameByPoint = function(self, frame, x, y)
  local MapModule = gmodule.moduleMgr:GetModule(ModuleId.MAP)
  self._mapID = MapModule:GetMapId()
  self._pointX = x
  self._pointY = y
  self:_SetFrame(frame)
end
def.method().HideCurrNPCDlg = function(self)
  if self._frame ~= nil then
    local frame = self._frame
    self._frame = nil
    if self._frame.m_panel then
      self._frame:DestroyPanel()
    end
  end
  self._mapID = 0
  self._pointX = 0
  self._pointY = 0
end
def.method()._SetFrame = function(self, frame)
  self._frame = frame
  if self._timerID < 0 then
    self._timerID = GameUtil.AddGlobalTimer(1, true, NPCAutoClose._OnTimer)
  end
end
def.static()._OnTimer = function()
  self = instance
  self._timerID = -1
  if self._frame:IsShow() == false then
    return
  end
  local HeroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local heroPos = HeroModule.myRole:GetPos()
  local MapModule = gmodule.moduleMgr:GetModule(ModuleId.MAP)
  local mapID = MapModule:GetMapId()
  if mapID ~= self._mapID then
    self:HideCurrNPCDlg()
    return
  end
  local xx = (x - self._pointX) * (x - self._pointX)
  local yy = (y - self._pointY) * (y - self._pointY)
  local xxyy = xx + yy
  if xxyy > 32768 then
    self:HideCurrNPCDlg()
    return
  end
  self._timerID = GameUtil.AddGlobalTimer(1, true, NPCAutoClose._OnTimer)
end
return NPCAutoClose
