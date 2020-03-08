local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local QixiGame = Lplus.Extend(ECPanelBase, "QixiGame")
local def = QixiGame.define
local dlg
local GUIUtils = require("GUI.GUIUtils")
local EC = require("Types.Vector3")
local QixiModule = require("Main.Qixi.QixiModule")
def.field("table").uiObjs = nil
def.field("number").time = 0
def.field("number").timerId = 0
def.field("table").flyingBirds = nil
def.field("number").updateTimerId = 0
def.const("table").CAGE_STATE = {
  ACTIVE = 1,
  OPEN = 2,
  CLOSE = 3
}
def.static("=>", QixiGame).Instance = function()
  if dlg == nil then
    dlg = QixiGame()
  end
  return dlg
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_QIXI_GAME, 0)
end
def.override().OnCreate = function(self)
  self.uiObjs = {}
  self.uiObjs.cage = self.m_panel:FindDirect("Img_Bg0/Cages")
  self.uiObjs.cages = {}
  for i = 1, 6 do
    self.uiObjs.cages[i] = self.uiObjs.cage:FindDirect("Btn_Cage" .. i)
  end
  self.uiObjs.Label_CountDown = self.m_panel:FindDirect("Img_Bg0/Label_CountDown")
  self.uiObjs.Label_CountDown:SetActive(false)
  self.uiObjs.bird_1 = self.m_panel:FindDirect("Img_Bg0/Img_Bird")
  self.uiObjs.bird_1:SetActive(false)
  local grid = self.m_panel:FindDirect("Img_Bg0/GameCounts/Grid")
  self.uiObjs.label_fail = grid:FindDirect("Label_Fail/Label_Num_Fail")
  self.uiObjs.label_success = grid:FindDirect("Label_Success/Label_Num_Success")
  self.uiObjs.label_left = grid:FindDirect("Label_Remain/Label_Num_Remain")
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  if self.time > 0 then
    self.uiObjs.Label_CountDown:SetActive(true)
    self:SetLabel()
    self:UpdateCount()
  end
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self:StopCountDown()
  self:StopFlying()
end
def.method().Hide = function(self)
  self:StopFlying()
  self:DestroyPanel()
end
def.method("string").onClick = function(self, id)
  if string.find(id, "Btn_Cage") == 1 then
    local gamedata = QixiModule.Instance().gamedata
    if gamedata == nil or gamedata.highLightMap == nil then
      return
    end
    local idx = tonumber(string.sub(id, -1, -1))
    local team = math.floor((idx - 1) / QixiModule.CAGE_NUM)
    if team + 1 ~= gamedata.myteam then
      return
    end
    local real_idx = idx - team * QixiModule.CAGE_NUM
    local highlight_idx = gamedata.highLightMap[team + 1]
    if real_idx ~= highlight_idx then
      return
    end
    local pro = require("netio.protocol.mzm.gsp.chinesevalentine.CChineseValentineClickReq").new(real_idx)
    gmodule.network.sendProtocol(pro)
    self:SetCageState(idx, QixiGame.CAGE_STATE.OPEN)
  end
end
def.method().Prepare = function(self)
  self:StopFlying()
  if self.uiObjs then
    for i = 1, #self.uiObjs.cages do
      self:SetCageState(i, QixiGame.CAGE_STATE.CLOSE)
    end
  end
  self:UpdateCount()
  self:StartCountDown()
end
def.method().ShowHighLightCage = function(self)
  local gamedata = gmodule.moduleMgr:GetModule(ModuleId.QIXI).gamedata
  if gamedata and gamedata.highLightMap then
    local idx = gamedata.highLightMap[gamedata.myteam]
    self:SetCageState((gamedata.myteam - 1) * QixiModule.CAGE_NUM + idx, QixiGame.CAGE_STATE.ACTIVE)
  end
end
def.method().StartCountDown = function(self)
  self.time = 3
  local cfg = gmodule.moduleMgr:GetModule(ModuleId.QIXI).gamecfg
  if cfg then
    self.time = cfg.prepareTime
  end
  if self.timerId == 0 then
    self.timerId = GameUtil.AddGlobalTimer(1, false, QixiGame.UpdateCountDown)
  end
  if self.uiObjs then
    self.uiObjs.Label_CountDown:SetActive(true)
  end
  self:SetLabel()
end
def.method().StopCountDown = function(self)
  if self.timerId > 0 then
    GameUtil.RemoveGlobalTimer(self.timerId)
    self.timerId = 0
  end
  if self.uiObjs then
    self.uiObjs.Label_CountDown:SetActive(false)
  end
  self.time = 0
end
def.static().UpdateCountDown = function()
  dlg.time = dlg.time - 1
  if dlg.time < 0 then
    dlg.time = 0
  end
  dlg:SetLabel()
  if dlg.time == 0 then
    dlg:StopCountDown()
  end
end
def.method().SetLabel = function(self)
  if self.uiObjs then
    self.uiObjs.Label_CountDown:GetComponent("UILabel").text = tostring(self.time)
  end
end
local oppo_dir = EC.Vector3.new(-1, 1, 1)
def.method("number", "number").FlyBird = function(self, from, to)
  if self.uiObjs == nil then
    return
  end
  local cage_from = self.uiObjs.cages[from]
  local cage_to = self.uiObjs.cages[to]
  if cage_from == nil or cage_to == nil then
    return
  end
  if self.flyingBirds == nil then
    self.flyingBirds = {}
  end
  local pos = cage_to:FindDirect("Pos_BirdFly").position
  local target_pos = self.uiObjs.cage:InverseTransformPoint(pos)
  local bird = self.flyingBirds[1]
  if bird == nil then
    bird = self.uiObjs.bird_1
    self.flyingBirds[1] = bird
  else
    bird = Object.Instantiate(self.uiObjs.bird_1, "GameObject")
    self.flyingBirds[2] = bird
  end
  bird:SetActive(true)
  bird.parent = self.uiObjs.cage
  pos = cage_from:FindDirect("Pos_BirdFly").position
  local from_pos = self.uiObjs.cage:InverseTransformPoint(pos)
  bird.localPosition = from_pos
  if from <= QixiModule.CAGE_NUM then
    bird.localScale = oppo_dir
  else
    bird.localScale = EC.Vector3.one
  end
  local effdata = _G.GetEffectRes(702020213)
  require("Fx.GUIFxMan").Instance():PlayAsChild(bird, effdata.path, 0, 0, 3, false)
  TweenPosition.Begin(bird, 3, target_pos)
  if self.updateTimerId == 0 then
    self.updateTimerId = GameUtil.AddGlobalTimer(0, false, QixiGame.Update)
  end
end
def.static().Update = function()
  if dlg == nil then
    return
  end
  local self = dlg
  if self.flyingBirds == nil then
    return
  end
  local bird1 = self.flyingBirds[1]
  local bird2 = self.flyingBirds[2]
  if _G.IsNil(bird1) or _G.IsNil(bird2) then
    return
  end
  local bird1_to = bird1:GetComponent("TweenPosition"):get_to()
  local bird2_to = bird2:GetComponent("TweenPosition"):get_to()
  local vec1 = bird1_to - bird1.localPosition
  local vec2 = bird2.localPosition - bird1.localPosition
  if math.abs(bird1.localPosition.x - bird2.localPosition.x) < 10 and 10 > math.abs(bird1.localPosition.y - bird2.localPosition.y) or math.abs(vec1:Angle(vec2)) > 90 then
    dlg:StopFlying()
  end
end
def.method().StopFlying = function(self)
  if self.flyingBirds == nil then
    return
  end
  local pos1, pos2
  if self.flyingBirds[1] then
    local bird = self.flyingBirds[1]
    if not _G.IsNil(bird) then
      pos1 = bird.position
      bird:SetActive(false)
    end
    self.flyingBirds[1] = nil
  end
  if self.flyingBirds[2] then
    local bird = self.flyingBirds[2]
    if not _G.IsNil(bird) then
      pos2 = bird.position
      bird:Destroy()
    end
    self.flyingBirds[2] = nil
  end
  local cfg = gmodule.moduleMgr:GetModule(ModuleId.QIXI).gamecfg
  if cfg and pos1 and pos2 then
    local effdata = _G.GetEffectRes(cfg.birdsCollisionEffectId)
    local pos = (pos1 + pos2) / 2
    local guifxman = require("Fx.GUIFxMan").Instance()
    local screen_pos = guifxman.fxroot:InverseTransformPoint(pos)
    guifxman:Play(effdata.path, "", screen_pos.x, screen_pos.y, -1, false)
  end
  if self.updateTimerId > 0 then
    GameUtil.RemoveGlobalTimer(self.updateTimerId)
    self.updateTimerId = 0
  end
end
def.method("boolean").ShowResult = function(self, isSuccess)
  local cfg = gmodule.moduleMgr:GetModule(ModuleId.QIXI).gamecfg
  if cfg then
    local effid = cfg.failEffectId
    if isSuccess then
      effid = cfg.successEffectId
    end
    local effdata = _G.GetEffectRes(effid)
    require("Fx.GUIFxMan").Instance():Play(effdata.path, "", 0, 0, -1, false)
  end
  self:UpdateCount()
end
def.method("number").RemoveHighLightCage = function(self, idx)
  if self.uiObjs == nil then
    return
  end
  local cage = self.uiObjs.cages[idx]
  if cage then
    local highlight = cage:FindDirect("Cage_Ready")
    if highlight and highlight.activeSelf then
      highlight:SetActive(false)
      cage:FindDirect("Cage_Open"):SetActive(true)
    end
  end
end
def.method("number", "number").SetCageState = function(self, idx, state)
  if self.uiObjs == nil then
    return
  end
  local cage = self.uiObjs.cages[idx]
  if cage then
    cage:FindDirect("Cage_Ready"):SetActive(state == QixiGame.CAGE_STATE.ACTIVE)
    cage:FindDirect("Cage_Open"):SetActive(state == QixiGame.CAGE_STATE.OPEN)
    cage:FindDirect("Cage_Close"):SetActive(state == QixiGame.CAGE_STATE.CLOSE)
  end
end
def.method().UpdateCount = function(self)
  if self.uiObjs == nil then
    return
  end
  local m = gmodule.moduleMgr:GetModule(ModuleId.QIXI)
  if m.gamedata == nil then
    return
  end
  self.uiObjs.label_fail:GetComponent("UILabel").text = tostring(m.gamedata.wrongCount)
  self.uiObjs.label_success:GetComponent("UILabel").text = tostring(m.gamedata.rightCount)
  self.uiObjs.label_left:GetComponent("UILabel").text = tostring(m.gamecfg.roundMax - m.gamedata.curRound)
end
QixiGame.Commit()
return QixiGame
