local Lplus = require("Lplus")
local ChessMgr = Lplus.Class("ChessMgr")
local ECGame = Lplus.ForwardDeclare("ECGame")
require("Main.Fight.FightConst")
local ECFxMan = require("Fx.ECFxMan")
local def = ChessMgr.define
local EC = require("Types.Vector")
local instance
local SoundData = require("Sound.SoundData")
local SystemSettingModule = require("Main.SystemSetting.SystemSettingModule")
local GUIMan = require("GUI.ECGUIMan")
local ChessPiece = require("Main.Chess.ChessPiece")
local ChessUtils = require("Main.Chess.ChessUtils")
local ChessCell = require("Main.Chess.ChessCell")
local SSynChessInfo = require("netio.protocol.mzm.gsp.chess.SSynChessInfo")
local mainCamObj, tipResume
local CHESS_CAMERA_NAME = "Chess"
def.field("userdata").chessSceneNode = nil
def.field("userdata").chess_board = nil
def.field("table").pieces = nil
def.field("boolean").isInGame = false
def.field("userdata").chessBoardCam = nil
def.field(ChessPiece).curSelect = nil
def.field("table").gameCfg = nil
def.field("number").currentPlayer = 0
def.field("table").rivalInfo = nil
def.field("number").curRound = 0
def.field("table").cells = nil
def.field("table").grids = nil
def.field("number").maxIndex = 0
def.field("number").minIndex = 0
def.field("number").my_side = 0
def.field("userdata").end_effect = nil
def.field("table").guideInfo = nil
def.field("boolean").isMoving = false
def.static("=>", ChessMgr).Instance = function()
  if instance == nil then
    instance = ChessMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chess.SSynChessInfo", ChessMgr.OnSSynChessInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chess.SNotifyChessTurnOver", ChessMgr.OnSNotifyChessTurnOver)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chess.SChessTurnOverFailRep", ChessMgr.OnSChessTurnOverFailRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chess.SChessGameOver", ChessMgr.OnSChessGameOver)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chess.SChessMoveFailRep", ChessMgr.OnSChessMoveFailRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chess.SJoinChessFailRep", ChessMgr.OnSJoinChessFailRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chess.SNotifyRoundChange", ChessMgr.OnSNotifyRoundChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chess.SNotifyRoundTimeOut", ChessMgr.OnSNotifyRoundTimeOut)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chess.SNotifyCurrentPlayerChange", ChessMgr.OnSNotifyCurrentPlayerChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chess.SNotifyChessMove", ChessMgr.OnSNotifyChessMove)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, ChessMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, ChessMgr.OnEnterWorld)
  Event.RegisterEvent(ModuleId.CHESS, gmodule.notifyId.CHESS.CLICK_PIECE, ChessMgr.OnClickPiece)
  Event.RegisterEvent(ModuleId.CHESS, gmodule.notifyId.CHESS.CLICK_CELL, ChessMgr.OnClickCell)
end
def.static("table").OnSSynChessInfo = function(p)
  require("Main.Chess.ui.DlgChessActivity").Instance():Hide()
  instance.gameCfg = ChessUtils.GetChessGameCfg(p.cfg_id)
  instance.rivalInfo = {}
  instance.rivalInfo.id = p.enemy_id
  instance.rivalInfo.name = p.enemy_name
  instance.rivalInfo.occupation = p.enemy_occupation
  instance.rivalInfo.gender = p.enemy_gender
  instance.rivalInfo.level = p.enemy_level
  instance.rivalInfo.avatar = p.enemy_avatar
  instance.my_side = p.self_side
  instance.currentPlayer = p.current_player
  instance.maxIndex, instance.minIndex = ChessUtils.GetMaxMinChessPieceIndex()
  instance.curRound = p.round
  instance.curSelect = nil
  local serverTime = _G.GetServerTime()
  local left_time = p.round_start_time / 1000 + instance.gameCfg.roundTimeLimit - serverTime
  require("Main.Chess.ui.DlgChessMain").Instance():ShowDlg(left_time:ToNumber())
  instance:StartGame()
  instance.grids = ChessUtils.GetChessBoardCfg(1)
  for i = 1, #p.chess_piece_infos do
    local info = p.chess_piece_infos[i]
    local row, col = instance:GetCellRowCol(info.chess_cell_index)
    local grid = instance.grids[bit.lshift(row, 16) + col]
    local piece = instance:CreateChessPiece(info.chess_cell_index, info.chess_piece_index, grid.x, grid.y, info.owner)
    instance.pieces[info.chess_cell_index] = piece
    piece.isTurnedOver = info.chess_piece_index > 0
    piece.row = row
    piece.col = col
  end
  if instance.curRound == 1 then
    instance:ShowGuide(1, textRes.activity.Chess[50], 702020205)
  elseif instance.curRound == 2 then
    instance:ShowGuide(2, textRes.activity.Chess[51], 0)
  end
  instance.isMoving = false
end
def.static("table").OnSChessGameOver = function(p)
  if p.reason == p.WIPE_OUT_ALL then
    if p.result == p.WIN then
      Toast(textRes.activity.Chess[6])
    elseif p.result == p.LOSE then
      Toast(textRes.activity.Chess[7])
    end
  elseif p.reason == p.SURRENDER then
    if p.result == p.WIN then
      Toast(textRes.activity.Chess[41])
    elseif p.result == p.LOSE then
      Toast(textRes.activity.Chess[42])
    end
  elseif p.reason == p.TIME_UP_DRAW then
    Toast(textRes.activity.Chess[8])
  elseif p.reason == p.QUANTITY_COMPARE then
    if p.result == p.WIN then
      Toast(textRes.activity.Chess[10])
    elseif p.result == p.LOSE then
      Toast(textRes.activity.Chess[11])
    elseif p.result == p.DRAW then
      Toast(textRes.activity.Chess[12])
    end
  elseif p.reason == p.NO_OPERATE_LOSE then
    if p.result == p.WIN then
      Toast(textRes.activity.Chess[13])
    elseif p.result == p.LOSE then
      Toast(textRes.activity.Chess[14])
    end
  end
  local effId = 0
  if p.result == p.WIN then
    effId = instance.gameCfg.winEffect
  elseif p.result == p.LOSE then
    effId = instance.gameCfg.loseEffect
  elseif p.result == p.DRAW then
    effId = instance.gameCfg.drawEffect
  end
  if effId > 0 then
    local effRes = GetEffectRes(effId)
    if effRes then
      local name = tostring(effId)
      instance.end_effect = require("Fx.GUIFxMan").Instance():Play(effRes.path, name, 0, 0, -1, false)
    end
  end
  GameUtil.AddGlobalTimer(3, true, function()
    if instance.isInGame then
      instance:EndGame()
    end
  end)
end
local ChessScenePos = EC.Vector3.new(-10000, 0, 0)
local ChessSceneCamPos = EC.Vector3.new(-1000, -1000, -100)
def.method().StartGame = function(self)
  if self.isInGame then
    return
  end
  self.isInGame = true
  require("ProxySDK.ECApollo").DestroyVoipGuidPanel()
  Event.DispatchEvent(ModuleId.CHESS, gmodule.notifyId.CHESS.EnterChess, nil)
  local oldTimeLimit = 0.015
  GameUtil.SetLoadTimeLimit(0)
  Application.set_targetFrameRate(60)
  GameUtil.AddGlobalTimer(4, true, function()
    GameUtil.SetLoadTimeLimit(0.015)
    local cur_rate = Application.get_targetFrameRate()
    if cur_rate == 60 then
      Application.set_targetFrameRate(_G.max_frame_rate)
    end
  end)
  if self.chessSceneNode == nil then
    self.chessSceneNode = GameObject.GameObject("ChessNodeRoot")
    self.chessSceneNode.localPosition = ChessScenePos
  end
  if self.pieces then
    for k, v in pairs(self.pieces) do
      if v and v.model then
        v:Destroy()
      end
      self.pieces[k] = nil
    end
  end
  self.pieces = {}
  local game = ECGame.Instance()
  game:TakeCamera(CHESS_CAMERA_NAME)
  Timer:RegisterIrregularTimeListener(ChessMgr.Update, self)
  mainCamObj = Object.Instantiate(game.m_Main3DCam, "GameObject")
  game.m_Main3DCam:SetActive(false)
  game.m_Fly3DCam:SetActive(false)
  mainCamObj:SetActive(true)
  game.m_cloudCam:SetActive(false)
  local main_cam = mainCamObj:GetComponent("Camera")
  CommonCamera.game3DCamera = main_cam
  main_cam.clearFlags = CameraClearFlags.Depth
  main_cam:set_cullingMask(get_cull_mask(ClientDef_Layer.NPC) + get_cull_mask(ClientDef_Layer.Player))
  main_cam.orthographicSize = main_cam.orthographicSize
  HUDFollowTarget.gameCamera = main_cam
  ECPateTextComponent.gameCamera = main_cam
  mainCamObj.parent = self.chessSceneNode
  ChessCell.Scale = main_cam.orthographicSize * 4
  local guiMan = GUIMan.Instance()
  local bgId = 0
  if self.chessBoardCam == nil then
    local camobj = GameObject.GameObject("ChessBoardCam")
    local cam = camobj:AddComponent("Camera")
    cam.clearFlags = CameraClearFlags.Depth
    cam.orthographic = true
    cam.orthographicSize = game.m_2DWorldCam.orthographicSize
    cam.nearClipPlane = -500
    cam.farClipPlane = 500
    cam.depth = CameraDepth.BATTLEMAP
    cam:set_cullingMask(get_cull_mask(ClientDef_Layer.Fight))
    camobj.localPosition = EC.Vector3.new(-10000, 0, -10000)
    self.chessBoardCam = camobj
  end
  self:LoadChessBoard(self.gameCfg.chessBoardBg)
  self:SetToGroundMode()
  guiMan.m_hudCameraGo.localPosition = ChessSceneCamPos
  mainCamObj.localPosition = EC.Vector3.zero - mainCamObj.forward * 15
end
local fightBgRotation = Quaternion.Euler(EC.Vector3.new(0, 180, 0))
def.method("number").LoadChessBoard = function(self, bgId)
  local respath = GetIconPath(bgId)
  if respath == nil or respath == "" then
    return
  end
  GameUtil.AsyncLoad(respath, function(obj)
    if not self.isInGame then
      return
    end
    if self.chess_board == nil then
      self.chess_board = Object.Instantiate(obj, "GameObject")
      self.chess_board:SetLayer(ClientDef_Layer.Fight)
      self.chess_board.name = "Sprite_ChessBoard"
      self.chess_board.transform.parent = nil
      self.chess_board.localPosition = EC.Vector3.new(-10000, 0, -9600)
      local orthographicSize = ECGame.Instance().m_2DWorldCam:GetComponent("Camera").orthographicSize
      self.chess_board.localScale = EC.Vector3.one * orthographicSize * 4
      self.chess_board.localRotation = fightBgRotation
    end
    ECGame.Instance().m_2DWorldCamObj:SetActive(false)
  end, true, true, true)
end
def.method("number", "=>", "table").GetRoundData = function(self, roundnum)
  if self.record == nil or self.record.rounds == nil then
    return nil
  end
  return self.record.rounds[roundnum]
end
def.method().EndGame = function(self)
  if not self.isInGame then
    return
  end
  self.isInGame = false
  Timer:RemoveIrregularTimeListener(ChessMgr.Update)
  self:HideGuide()
  self:RemoveAllPieces()
  self:RemoveAllCells()
  self.grids = nil
  self.rivalInfo = nil
  if self.chess_board then
    self.chess_board:Destroy()
  end
  self.chess_board = nil
  ECFxMan.Instance():ResetLODLevel()
  if self.end_effect then
    require("Fx.GUIFxMan").Instance():RemoveFx(self.end_effect)
    self.end_effect = nil
  end
  if instance.chessBoardCam then
    instance.chessBoardCam:Destroy()
    instance.chessBoardCam = nil
  end
  mainCamObj:Destroy()
  local game = ECGame.Instance()
  game:ReleaseCamera(CHESS_CAMERA_NAME)
  mainCamObj = game.m_Main3DCam
  game.m_2DWorldCamObj:SetActive(true)
  mainCamObj:SetActive(true)
  game.m_Fly3DCam:SetActive(true)
  local ECSoundMan = require("Sound.ECSoundMan")
  ECSoundMan.Instance():StopBackgroundMusic(1)
  local cam = mainCamObj:GetComponent("Camera")
  CommonCamera.game3DCamera = cam
  GUIMan.Instance().m_hudCamera.clearFlags = CameraClearFlags.Nothing
  Event.DispatchEvent(ModuleId.MAP, gmodule.notifyId.Map.ENABLE_MUSIC, {true, false})
  HUDFollowTarget.gameCamera = game.m_Main3DCamComponent
  ECPateTextComponent.gameCamera = game.m_Main3DCamComponent
  game:SyncGC()
  require("Main.Chess.ui.DlgChessMain").Instance():Hide()
  Event.DispatchEvent(ModuleId.CHESS, gmodule.notifyId.CHESS.LeaveChess, nil)
end
def.method().RemoveAllPieces = function(self)
  if self.pieces then
    for k, v in pairs(self.pieces) do
      v:Destroy()
      self.pieces[k] = nil
    end
    self.pieces = nil
  end
end
def.method().RemoveAllCells = function(self)
  if self.cells then
    for k, v in pairs(self.cells) do
      v:Destroy()
      self.cells[k] = nil
    end
    self.cells = nil
  end
end
def.method("number", "number", "number", "number", "number", "=>", ChessPiece).CreateChessPiece = function(self, idx, index, x, y, owner)
  local modelId = 0
  local name
  local model_color = 0
  local angle = 120
  if owner == 0 then
    model_color = 0
    angle = 180
  elseif owner == SSynChessInfo.SIDE_RED then
    model_color = instance.gameCfg.redModelColorId
  elseif owner == SSynChessInfo.SIDE_BLUE then
    model_color = instance.gameCfg.blueModelColorId
  end
  local namecolor = GetColorData(701300000)
  if owner == SSynChessInfo.SIDE_RED then
    namecolor = GetColorData(self.gameCfg.redNameColorId)
  elseif owner == SSynChessInfo.SIDE_BLUE then
    namecolor = GetColorData(self.gameCfg.blueNameColorId)
  end
  local scale = 1
  if index > 0 then
    local pieceCfg = ChessUtils.GetChessPieceCfg(index)
    if pieceCfg == nil then
      return
    end
    name = pieceCfg.name
    modelId = pieceCfg.modelId
    scale = pieceCfg.modelScale
  else
    modelId = self.gameCfg.modelIdBeforeTurnOver
    name = self.gameCfg.nameBeforeTurnOver
  end
  local piece = ChessPiece.new(index, modelId, name, namecolor)
  piece.owner = owner
  piece.scale = scale
  piece:SetDefaultParentNode(self.chessSceneNode)
  local modelpath, modelcolor = GetModelPath(modelId)
  if modelpath == nil or modelpath == "" then
    return nil
  end
  piece.mModelId = modelId
  if model_color > 0 then
    piece.colorId = model_color
    piece:SetColoration(nil)
  end
  piece:LoadModel2(modelpath, x, y, angle, false)
  return piece
end
def.method("number", "number", "=>", ChessCell).CreateChessCell = function(self, row, col)
  local cell = ChessCell.new(row, col)
  cell:SetDefaultParentNode(self.chessSceneNode)
  local modelpath, modelcolor = GetModelPath(cell.mModelId)
  if modelpath == nil or modelpath == "" then
    return nil
  end
  local x, y = self:GetCellPos(row, col)
  cell:LoadModel2(modelpath, x, y, 0, false)
  return cell
end
def.static("table", "table").OnClickCell = function(p1, p2)
  if instance.isMoving then
    Toast(textRes.activity.Chess[9])
    return
  end
  local row = p1 and p1[1]
  local col = p1 and p1[2]
  local idx = instance:GetCellIdx(row, col)
  local piece = instance:GetChessPiece(idx)
  if piece then
    return
  end
  if instance.curSelect then
    instance:RequestMovePiece(instance.curSelect, row, col)
  end
end
def.static("table", "table").OnClickPiece = function(p1, p2)
  if instance.isMoving then
    Toast(textRes.activity.Chess[9])
    return
  end
  local row = p1 and p1[1]
  local col = p1 and p1[2]
  local idx = instance:GetCellIdx(row, col)
  local piece = instance:GetChessPiece(idx)
  if piece == nil then
    warn("piece not found: ", row, col)
    return
  end
  if not instance:IsMyTurn() then
    Toast(textRes.activity.Chess[2])
    return
  end
  if instance.curSelect == nil then
    if piece.isTurnedOver then
      if piece.owner == instance.my_side then
        instance.curSelect = piece
        instance:ShowMoveRange(true)
      end
    else
      instance:RequestTurnOverPiece(piece.row, piece.col)
      require("Main.Chess.ui.DlgChessMain").Instance():StopCountDown()
    end
  elseif piece ~= instance.curSelect then
    if piece.isTurnedOver then
      if piece.owner == instance.my_side then
        instance.curSelect = piece
        instance:ShowMoveRange(true)
      elseif math.abs(instance.curSelect.row - row) + math.abs(instance.curSelect.col - col) == 1 then
        instance:ShowMoveRange(false)
        local select_piece = instance.curSelect
        instance.curSelect = nil
        instance:RequestMovePiece(select_piece, row, col)
      else
        Toast(textRes.activity.Chess[16])
      end
    else
      local target_pos = piece:GetPos()
      instance.curSelect:LookAtPos(target_pos.x, target_pos.y)
      instance:ShowMoveRange(false)
      local select_piece = instance.curSelect
      instance.curSelect = nil
      instance:RequestMovePiece(select_piece, row, col)
    end
  else
    instance:ShowMoveRange(false)
    instance.curSelect = nil
  end
end
def.method("number", "number").RequestTurnOverPiece = function(self, row, col)
  local dlgmain = require("Main.Chess.ui.DlgChessMain").Instance()
  dlgmain:StopCountDown()
  self:HideGuide()
  local pro = require("netio.protocol.mzm.gsp.chess.CChessTurnOverReq").new()
  pro.cell_index = self:GetCellIdx(row, col)
  gmodule.network.sendProtocol(pro)
end
def.method(ChessPiece, "number", "number").RequestMovePiece = function(self, piece, row, col)
  local dlgmain = require("Main.Chess.ui.DlgChessMain").Instance()
  dlgmain:StopCountDown()
  self:HideGuide()
  local pro = require("netio.protocol.mzm.gsp.chess.CChessMoveReq").new()
  pro.from_cell_index = self:GetCellIdx(piece.row, piece.col)
  pro.to_cell_index = self:GetCellIdx(row, col)
  gmodule.network.sendProtocol(pro)
end
def.method("number", "number", "=>", ChessPiece).GetChessPieceAt = function(self, row, col)
  local idx = self:GetCellIdx(row, col)
  return self:GetChessPiece(idx)
end
def.method("number", "=>", ChessPiece).GetChessPiece = function(self, idx)
  return self.pieces and self.pieces[idx]
end
def.method("number", "number").RemoveChessPieceAt = function(self, row, col)
  local idx = self:GetCellIdx(row, col)
  return self:RemoveChessPiece(idx)
end
def.method("number").RemoveChessPiece = function(self, idx)
  if self.pieces == nil then
    return
  end
  local piece = self.pieces[idx]
  if piece then
    piece:Destroy()
  end
  self.pieces[idx] = nil
end
def.method("number", "number", "number", "number").MoveChessPiece = function(self, from_row, from_col, to_row, to_col)
  if self.pieces == nil then
    return
  end
  local from_idx = self:GetCellIdx(from_row, from_col)
  local piece = self.pieces[from_idx]
  if piece then
    local to_idx = self:GetCellIdx(to_row, to_col)
    self.pieces[from_idx] = nil
    self.pieces[to_idx] = piece
    piece.row = to_row
    piece.col = to_col
  end
end
def.method("number", "number", "=>", "number").GetCellIdx = function(self, row, col)
  return (row - 1) * self.gameCfg.chessBoardMaxColumn + col
end
def.method("number", "number", "=>", "number", "number").GetCellPos = function(self, row, col)
  local idx = (row - 1) * self.gameCfg.chessBoardMaxColumn + col
  local cfg = self.grids[bit.lshift(row, 16) + col]
  if cfg == nil then
    return -1, -1
  end
  return cfg.x, cfg.y
end
def.method("number").Update = function(self, tick)
  tick = tick * Time.timeScale
  for _, v in pairs(self.pieces) do
    v:Update(tick)
  end
end
def.static("table", "table").OnModelLoaded = function(p1, p2)
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
  if instance.isInGame then
    ECGame.Instance().m_Main3DCam:SetActive(false)
  end
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  if instance.isInGame then
    instance:EndGame()
  end
end
def.method("=>", "number").GetCurrentRoundNum = function(self)
  return self.curRound
end
def.static("table", "table").OnPauseGame = function()
  warn("game paused")
end
def.static("table", "table").OnResumeGame = function()
  warn("game resumed")
end
def.method().SetToGroundMode = function(self)
  local game = ECGame.Instance()
  game:_ResetGroundLayer()
  if game.m_cloudCam then
    local cam = game.m_cloudCam:GetComponent("Camera")
    cam.depth = CameraDepth.CLOUD_UP
  end
  require("Main.Fly.FlyModule").Instance():StopCloud("fight")
end
def.method("string", "table", "userdata", "=>", "userdata").PlayEffect = function(self, resName, localpos, rotation)
  local pos = localpos + ChessScenePos
  return require("Fx.ECFxMan").Instance():Play(resName, pos, rotation, -1, false, ClientDef_Layer.NPC)
end
def.method("number").PlaySoundEffect = function(self, soundid)
end
def.static("table").OnSChessMoveFailRep = function(p)
  if p.error_code == p.NOT_IN_CHESS_GAME then
    Toast(textRes.activity.Chess[1])
  elseif p.error_code == p.NOT_SELF_ROUND then
    Toast(textRes.activity.Chess[2])
  elseif p.error_code == p.MOVE_FROM_CELL_NOT_EXIST then
    Toast(textRes.activity.Chess[21])
  elseif p.error_code == p.MOVE_FROM_CELL_EMPTY then
    Toast(textRes.activity.Chess[22])
  elseif p.error_code == p.MOVE_FROM_CELL_IS_ENEMY then
    Toast(textRes.activity.Chess[23])
  elseif p.error_code == p.MOVE_FROM_CELL_NOT_VISIBLE then
    Toast(textRes.activity.Chess[24])
  elseif p.error_code == p.MOVE_TO_CELL_NOT_EXIST then
    Toast(textRes.activity.Chess[25])
  elseif p.error_code == p.MOVE_TO_CELL_UNREACHABLE then
    Toast(textRes.activity.Chess[26])
  elseif p.error_code == p.MOVE_TO_CELL_NOT_ENEMY then
    Toast(textRes.activity.Chess[27])
  elseif p.error_code == p.MOVE_TO_CELL_ENEMY_TOO_STRONG then
    Toast(textRes.activity.Chess[28])
  elseif p.error_code == p.OPERATE_TOO_FAST then
    Toast(textRes.activity.Chess[9])
  end
end
def.static("table").OnSChessTurnOverFailRep = function(p)
  if p.error_code == p.NOT_IN_CHESS_GAME then
    Toast(textRes.activity.Chess[1])
  elseif p.error_code == p.NOT_SELF_ROUND then
    Toast(textRes.activity.Chess[2])
  elseif p.error_code == p.TURN_OVER_CELL_NOT_EXIST then
    Toast(textRes.activity.Chess[3])
  elseif p.error_code == p.TURN_OVER_CELL_EMPTY then
    Toast(textRes.activity.Chess[4])
  elseif p.error_code == p.TURN_OVER_CHESS_ALREADY_VISIBLE then
    Toast(textRes.activity.Chess[5])
  elseif p.error_code == p.OPERATE_TOO_FAST then
    Toast(textRes.activity.Chess[9])
  end
end
def.static("table").OnSJoinChessFailRep = function(p)
  if p.error_code == p.MEMBER_COUNT_ERROR then
    Toast(textRes.activity.Chess[31])
  elseif p.error_code == p.MEMBER_LEVEL_NOT_ENOUGH then
    Toast(textRes.activity.Chess[32])
  elseif p.error_code == p.ACTIVITY_CLOSED then
    Toast(textRes.activity.Chess[33])
  elseif p.error_code == p.TEAM_NOT_EXIST then
    Toast(textRes.activity.Chess[34])
  elseif p.error_code == p.IS_NOT_LEADER then
    Toast(textRes.activity.Chess[35])
  elseif p.error_code == p.TEAM_MEMBER_STATE_ERROR then
    Toast(textRes.activity.Chess[36])
  elseif p.error_code == p.TEAM_CHANGED then
    Toast(textRes.activity.Chess[37])
  elseif p.error_code == p.TEAM_MEMBER_AlREADY_IN_GAME then
    Toast(textRes.activity.Chess[38])
  end
end
def.method(ChessPiece, ChessPiece).AttackTarget = function(self, src, target)
  if src == nil or target == nil then
    return
  end
  local target_pos = target:GetPos()
  src:LookAtPos(target_pos.x, target_pos.y)
  if src.index == self.maxIndex and target.index == self.minIndex or src.index <= target.index and target.index - src.index < self.maxIndex - self.minIndex then
    src:PlayAnim(self.gameCfg.attackActionName, function(model)
      if not self.isInGame then
        return
      end
      src:Play(ActionName.Stand)
    end)
    do
      local function attackEnd(model)
        if not self.isInGame then
          return
        end
        local target_row, target_col = target.row, target.col
        self:RemoveChessPieceAt(target.row, target.col)
        self:MoveChessPiece(src.row, src.col, target_row, target_col)
        self:MoveChessPieceToPos(src, target_pos.x, target_pos.y)
        self.isMoving = false
      end
      GameUtil.AddGlobalTimer(0.5, true, function()
        if not self.isInGame then
          return
        end
        if target:IsInLoading() then
          attackEnd(nil)
        else
          target:PlayAnim(self.gameCfg.deathActionName, attackEnd)
        end
      end)
    end
  else
    target:FaceToTarget(src)
    target:PlayAnim(self.gameCfg.attackActionName, function(model)
      if not self.isInGame then
        return
      end
      target:Play(ActionName.Stand)
      src:PlayAnim(self.gameCfg.deathActionName, function(model)
        if not self.isInGame then
          return
        end
        self:RemoveChessPieceAt(src.row, src.col)
        self.isMoving = false
      end)
    end)
  end
end
def.static("table").OnSNotifyChessTurnOver = function(p)
  instance:TurnOverPiece(p.cell_piece_info)
end
local turn_over_effect_rotation = Quaternion.Euler(EC.Vector3.new(0, 180, 0))
def.method("table").TurnOverPiece = function(self, pieceInfo)
  local piece = instance:GetChessPiece(pieceInfo.chess_cell_index)
  if piece == nil then
    Debug.LogWarning(string.format("OnSNotifyChessTurnOver: piece not found: %d", pieceInfo.chess_cell_index))
    return
  end
  local pos = piece:GetPos()
  local res = _G.GetEffectRes(instance.gameCfg.turnOverEffect)
  instance:PlayEffect(res.path, Map2DPosTo3D(pos.x, pos.y), turn_over_effect_rotation)
  piece.owner = pieceInfo.owner
  local name_color = GetColorData(701300000)
  if piece.owner == SSynChessInfo.SIDE_RED then
    piece.colorId = instance.gameCfg.redModelColorId
    name_color = GetColorData(self.gameCfg.redNameColorId)
  elseif piece.owner == SSynChessInfo.SIDE_BLUE then
    piece.colorId = instance.gameCfg.blueModelColorId
    name_color = GetColorData(self.gameCfg.blueNameColorId)
  end
  piece:SetColoration(nil)
  piece:TurnOver(pieceInfo.chess_piece_index)
  piece:SetName("", name_color)
end
def.method("boolean").ShowMoveRange = function(self, isShow)
  local piece = self.curSelect
  if piece == nil then
    return
  end
  if isShow then
    if self.cells == nil then
      self.cells = {}
    end
    self:CheckAndShowCell(1, piece.row + 1, piece.col)
    self:CheckAndShowCell(2, piece.row, piece.col + 1)
    self:CheckAndShowCell(3, piece.row - 1, piece.col)
    self:CheckAndShowCell(4, piece.row, piece.col - 1)
  else
    self:RemoveAllCells()
  end
end
def.method("number", "number", "number").CheckAndShowCell = function(self, idx, row, col)
  local cell = self.cells[idx]
  if self:CheckCellValid(row, col) then
    if cell == nil then
      cell = self:CreateChessCell(row, col)
      self.cells[idx] = cell
    else
      cell:SetPos(row, col)
    end
  elseif cell then
    cell:Destroy()
    self.cells[idx] = nil
  end
end
def.static("table").OnSNotifyRoundChange = function(p)
  instance.curRound = p.round
  require("Main.Chess.ui.DlgChessMain").Instance():NextRound()
end
def.static("table").OnSNotifyRoundTimeOut = function(p)
  require("Main.Chess.ui.DlgChessMain").Instance():StopCountDown()
end
def.static("table").OnSNotifyCurrentPlayerChange = function(p)
  instance.currentPlayer = p.current_player
  instance:RemoveAllCells()
  instance:HideGuide()
  instance.curSelect = nil
  require("Main.Chess.ui.DlgChessMain").Instance():NextRound()
  if instance.curRound == 1 then
    instance:ShowGuide(1, textRes.activity.Chess[50], 702020205)
  elseif instance.curRound == 2 then
    instance:ShowGuide(2, textRes.activity.Chess[51], 0)
  end
end
def.method("=>", "boolean").IsMyTurn = function(self)
  return instance.currentPlayer == instance.my_side
end
def.static("table").OnSNotifyChessMove = function(p)
  local piece = instance:GetChessPiece(p.from_cell_index)
  if piece == nil then
    Debug.LogWarning(string.format("[OnSNotifyChessMove]chess piece is nil: %d", p.from_cell_index))
    return
  end
  instance.isMoving = true
  local target_row, target_col = instance:GetCellRowCol(p.to_cell_piece_info.chess_cell_index)
  local target_x, target_y = instance:GetCellPos(target_row, target_col)
  piece:LookAtPos(target_x, target_y)
  if p.to_cell_piece_info.chess_piece_index == 0 then
    instance:MoveChessPiece(piece.row, piece.col, target_row, target_col)
    instance:MoveChessPieceToPos(piece, target_x, target_y)
    instance.isMoving = false
  else
    do
      local target = instance:GetChessPiece(p.to_cell_piece_info.chess_cell_index)
      if not target.isTurnedOver then
        instance:TurnOverPiece(p.to_cell_piece_info)
        if piece.owner ~= target.owner then
          GameUtil.AddGlobalTimer(1, true, function()
            if not instance.isInGame then
              return
            end
            instance:AttackTarget(piece, target)
          end)
        else
          instance.isMoving = false
        end
      else
        instance:AttackTarget(piece, target)
      end
    end
  end
end
def.method("number", "=>", "number", "number").GetCellRowCol = function(self, cellidx)
  local row = math.floor(cellidx / instance.gameCfg.chessBoardMaxColumn) + 1
  local col = cellidx % instance.gameCfg.chessBoardMaxColumn
  if col == 0 then
    row = row - 1
    col = instance.gameCfg.chessBoardMaxColumn
  end
  return row, col
end
def.method("number", "number", "=>", "boolean").CheckCellValid = function(self, row, col)
  return row >= 1 and row <= self.gameCfg.chessBoardMaxRow and col >= 1 and col <= self.gameCfg.chessBoardMaxColumn
end
def.method(ChessPiece, "number", "number").MoveChessPieceToPos = function(self, piece, x, y)
  if piece then
    if piece:IsInLoading() then
      piece:SetPos(x, y)
    else
      piece:Play(self.gameCfg.moveActionName)
      piece:MoveTo(x, y, function()
        piece:Play(ActionName.Stand)
      end)
    end
  end
end
def.method().Surrender = function(self)
  if self.curRound < self.gameCfg.surrenderRoundCount then
    Toast(string.format(textRes.activity.Chess[30], self.gameCfg.surrenderRoundCount))
    return
  end
  require("GUI.CommonConfirmDlg").ShowConfirm("", textRes.activity.Chess[15], function(i, tag)
    if i == 1 then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chess.CSurrenderReq").new())
    end
  end, nil)
end
def.method("number", "string", "number").ShowGuide = function(self, step, tipstr, effId)
  if self.currentPlayer == self.my_side then
    if self.guideInfo and self.guideInfo.step == step then
      return
    end
    self.guideInfo = {}
    self.guideInfo.step = step
    do
      local piece = self:GetChessPieceAt(2 * self.my_side, 2 * self.my_side)
      if piece then
        local function AddGuideEffect()
          if self.guideInfo == nil then
            return
          end
          if effId <= 0 then
            return
          end
          local eff = _G.GetEffectRes(effId)
          local guide_eff_pos = EC.Vector3.new(0, 0.8, 0)
          local fx = require("Fx.ECFxMan").Instance():PlayAsChild(eff.path, piece.m_model, guide_eff_pos, Quaternion.identity, -1, false, ClientDef_Layer.NPC)
          self.guideInfo.fx = fx
        end
        if piece:IsInLoading() then
          piece:AddOnLoadCallback("chess_piece_guide_effect", AddGuideEffect)
        else
          AddGuideEffect()
        end
      end
      require("Main.Chess.ui.DlgChessMain").Instance():ShowGuidTip(tipstr)
    end
  end
end
def.method().HideGuide = function(self)
  if self.guideInfo then
    if self.guideInfo.fx then
      require("Fx.ECFxMan").Instance():Stop(self.guideInfo.fx)
    end
    self.guideInfo = nil
  end
  require("Main.Chess.ui.DlgChessMain").Instance():StopGuidTip()
end
ChessMgr.Commit()
return ChessMgr
