local Lplus = require("Lplus")
local PuzzleMgr = Lplus.Class("PuzzleMgr")
local def = PuzzleMgr.define
local instance
def.static("=>", PuzzleMgr).Instance = function()
  if instance == nil then
    instance = PuzzleMgr()
  end
  return instance
end
def.const("table").PUZZLE = {
  1,
  2,
  3,
  4,
  5
}
def.field("number").curPuzzle = 0
def.field("table").cacheProtocol = nil
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.paraselene.SStartJigsawRes", PuzzleMgr.onStart)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.paraselene.SJigsawStateRes", PuzzleMgr.onResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.paraselene.SJigsawFinishRes", PuzzleMgr.onFinish)
end
def.method().ReleaseCacheProtocol = function(self)
  if self.cacheProtocol then
    PuzzleMgr.onStart(self.cacheProtocol)
    self.cacheProtocol = nil
  end
end
def.method().Reset = function(self)
  self.curPuzzle = 0
end
def.method().Success = function(self)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.paraselene.CJigsawSuccess").new())
end
def.method().Fail = function(self)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.paraselene.CJigsawFail").new())
end
def.static("table").onResult = function(p)
  local res = p.rescode
  if res == p.SUCCESS then
    Toast(textRes.Question[26])
  elseif res == p.TIME_OUT then
    Toast(textRes.Question[27])
  elseif res == p.FAIL then
    Toast(textRes.Question[25])
  end
end
def.static("table").onStart = function(p)
  if not require("Main.Login.LoginModule").Instance().isEnteredWorld then
    instance.cacheProtocol = p
    return
  end
  if instance.curPuzzle == 0 then
    local endTime = Int64.ToNumber(p.endtime)
    local time = endTime - GetServerTime()
    local index = math.random(#PuzzleMgr.PUZZLE)
    PuzzleMgr.Instance().curPuzzle = PuzzleMgr.PUZZLE[index]
    require("Main.PhantomCave.ui.PuzzlePanel").ShowPuzzle(time, PuzzleMgr.Instance().curPuzzle)
  end
end
def.static("table").onFinish = function(p)
  if instance.curPuzzle ~= 0 then
    instance.curPuzzle = 0
    require("Main.PhantomCave.ui.PuzzlePanel").Close()
  end
end
PuzzleMgr.Commit()
return PuzzleMgr
