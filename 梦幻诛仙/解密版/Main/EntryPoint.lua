local global = require("Utility.global")
local ECGame = require("Main.ECGame")
local EC = require("Types.Vector")
local ECModel = require("Model.ECModel")
local ECGUIMan = require("GUI.ECGUIMan")
local CG = require("CG.CG")
_G.LastErrorCode = 0
_G.LastGCTime = 0
_G.IsMutilFrameLoadMap = false
_G.terraintile_muitlLoadmap = {}
_G.CGPlay = false
_G.IsCamMoveMode = true
_G.guide_open = true
_G.IsLoadMap = false
_G.MapNodeCount = 0
_G.MapNodeMax = 0
_G.IsRecordNetIO = false
_G.IsReplayNetIO = false
local theGame = ECGame.Instance()
function _G.SetUserName(name, pwd, server, port)
  theGame:SetUserName(name, pwd, server, port)
end
function _G.SetCreateConsole(bCreateConsole)
  theGame:SetCreateConsole(bCreateConsole)
end
function _G.StartGame()
  print("StartGame")
  if _G.isDebugBuild then
    Debug.LogWarning("StartGame")
  end
  theGame:Start()
  if _G.isDebugBuild then
    Debug.LogWarning("StartGameEnd")
  end
end
function _G.StartCGEditor(id)
  theGame:Start()
  LoadMapAllByID(id)
end
function _G.ReleaseGame()
  print("ReleaseGame")
  theGame:Release()
end
function _G.TickGame(dt)
  theGame:Tick(dt)
end
function _G.LateTickGame(dt)
  theGame:LateTick(dt)
end
function _G.OnReturnFunction(bDown)
  if not bDown then
  end
end
function _G.GetGameDataSendFilter()
  return {}
end
_G.UI_SHADER1 = "3rd/NGUI/Resources/Shaders/Unlit-TransparentColored.shader.u3dext"
_G.UI_SHADER2 = "3rd/NGUI/Resources/Shaders/Mask/Unlit-Transparent_Colored_Mask.shader.u3dext"
function _G.GetDontReleaseResPath()
  return {
    "3rd/CacheBundleCSList.prefab.u3dext",
    _G.UI_SHADER1,
    _G.UI_SHADER2,
    "Arts/Fonts/Fangzheng.TTF.u3dext",
    _G.RESPATH.COMMONATLAS,
    _G.RESPATH.FUNCTION1_ATLAS,
    _G.RESPATH.EMOJIATLAS,
    "Arts/Image/Atlas/TrueColor/Main.prefab.u3dext",
    "Arts/Image/Atlas/TrueColor/CommonNew.prefab.u3dext",
    "Arts/Image/Atlas/Compressed/Main.prefab.u3dext",
    "Arts/Image/Atlas/Compressed/Icon.prefab.u3dext",
    "Arts/Image/Atlas/Compressed/Bag.prefab.u3dext",
    "Arts/Fonts/Atlas/FontsAtlas.prefab.u3dext",
    "Models/Characters/Commons/characterShadow.FBX.u3dext",
    "Models/Characters/Commons/Materials/characterShadow.mat.u3dext"
  }
end
function _G.GetForceSepFileResPath()
  return {}
end
function _G.OnApplicationPause(pauseStatus)
  theGame:Pause(pauseStatus)
  if pauseStatus then
    collectgarbage("collect")
    GameUtil.GC()
    if not _G.unload_unused_func_call then
      _G.unload_unused_func_call = true
      GameUtil.UnloadUnusedAssets(function()
        _G.unload_unused_func_call = false
      end)
    end
  end
  local sdktype = ClientCfg.GetSDKType()
  if sdktype == ClientCfg.SDKTYPE.MSDK then
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.TssSdkSetGameStatus(pauseStatus)
    ECMSDK.GSDKBackAndFront(pauseStatus)
    if _G.LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
      ECMSDK.RefreshWXToken()
    end
  elseif sdktype == ClientCfg.SDKTYPE.UNISDK then
    require("Main.Pay.PayModule").Instance():RefreshCoinInfo()
  end
end
local ECPlayer = require("Model.ECPlayer")
local FightModel = require("Main.Fight.FightModel")
local TouchListPanel = require("GUI.TouchListPanel")
local HomelandTouchController = require("Main.Homeland.HomelandTouchController")
local touch_begin_target
function _G.GetTouchedTarget(modelList)
  local target, first_target
  for i, v in pairs(modelList) do
    if v:is(FightModel) then
      target = v
      break
    elseif v:is(ECModel) and v.showModel then
      local modelType = v:tryget("m_roleType")
      if modelType and modelType == RoleType.NPC then
        target = v
        break
      elseif first_target == nil then
        first_target = v
      end
    end
  end
  if target == nil then
    target = first_target or modelList[1]
  end
  return target
end
function _G.GetEffectedTargets(modelList, includeNonModel)
  local effectedList = {}
  local targetList = {}
  local hideList = {}
  local highPriority = {}
  for k, v in pairs(modelList) do
    if v.clickPriority > 1 then
      highPriority[#highPriority + 1] = v
    end
    if v.clickPriority < 1 then
      table.insert(hideList, v)
    elseif includeNonModel or v:is(ECModel) and v.showModel then
      local target = v:tryget("owner") or v
      local key = tostring(target)
      if effectedList[key] == nil then
        effectedList[key] = target
        table.insert(targetList, v)
      end
    end
  end
  if #highPriority > 0 then
    return highPriority
  end
  if #targetList == 0 then
    targetList[1] = hideList[1]
  end
  return targetList
end
_G.show_touch_list = true
function _G.OnClickObjList(modelList)
  local targetList = GetEffectedTargets(modelList, false)
  if show_touch_list and #targetList > 1 then
    TouchListPanel.Instance():ShowPanel(targetList, function(target)
      if target then
        target:OnClick()
      end
    end)
  else
    local target = targetList[1]
    if target then
      target:OnClick()
    end
  end
end
function _G.OnLongTouchObjList(modelList)
  for k, v in pairs(modelList) do
    if v:is(HomelandTouchController) then
      v:ForceLongTouch()
      return
    end
  end
  local targetList = GetEffectedTargets(modelList, true)
  if show_touch_list and #targetList > 1 then
    TouchListPanel.Instance():ShowPanel(targetList, function(target)
      if target then
        target:OnLongTouch()
      end
    end)
  else
    local target = targetList[1]
    if target then
      target:OnLongTouch()
    end
  end
end
function _G.OnTouchObjListBegin(modelList)
  touch_begin_target = GetTouchedTarget(modelList)
  if touch_begin_target then
    touch_begin_target:OnTouchBegin()
  end
end
function _G.OnTouchObjListEnd(modelList)
  local target = GetTouchedTarget(modelList)
  if target then
    target:OnTouchEnd()
  end
  touch_begin_target = nil
end
function _G.OnTouchObjListMoving(modelList)
  for i, v in pairs(modelList) do
    if v ~= touch_begin_target then
      v:OnTouchEnd()
    end
  end
end
function _G.ProcessGameDataSend(cmd_type, br, dt)
  local S2CManager = require("S2C.S2CManager")
  S2CManager.OnReceiveS2CCommandData(cmd_type, br)
end
function _G.OnObjectMove(dt, who, x, y, z, flags, movedir, speed)
  if _G.pause_protocol then
    return
  end
  who = GetOldID(who)
  local world = ECGame.Instance().m_CurWorld
  local obj = world:FindObject(who)
  if obj then
    local pos = EC.Vector3.new(x, y, z)
    obj:OnMove(pos, flags, movedir, 0, speed / 256, movedir)
  end
end
function _G.OnObjectNotifyPropDelta(dt, who, info)
  if _G.pause_protocol then
    return
  end
  local NotifyPropEvent = require("Event.NotifyPropEvent")
  who = GetOldID(who)
  local world = ECGame.Instance().m_CurWorld
  local obj = world:FindObject(who)
  if obj then
    local ObjectData = obj.InfoData.ObjectData
    local count = #info
    for i = 1, count, 2 do
      ObjectData:SetData(info[i], info[i + 1])
    end
    local event = NotifyPropEvent()
    event.obj_id = who
    ECGame.EventManager:raiseEvent(nil, event)
  end
end
function _G.OnObjectPerformSkill(dt, info)
  if _G.pause_protocol then
    return
  end
  local theGame = ECGame.Instance()
  info.who = GetOldID(info.who)
  local tar = info.target_ids
  for i = 1, #tar do
    tar[i] = GetOldID(tar[i])
  end
  if info.perform_target_id ~= 0 then
    info.perform_target_id = GetOldID(info.perform_target_id)
  else
    info.perform_target_id = ""
  end
  local hp = theGame.m_HostPlayer
  if info.who == hp.ID then
    hp.NetHdl:OnCmd_ObjectPerformSkill(info)
  else
    local world = theGame.m_CurWorld
    local obj = world:FindObject(info.who)
    if obj ~= nil and obj.NetHdl ~= nil then
      obj.NetHdl:OnCmd_ObjectPerformSkill(info)
    end
  end
end
function _G.OnObjectBeAttacked(dt, info)
  if _G.pause_protocol then
    return
  end
  info.attacker_id = GetOldID(info.attacker_id)
  info.target_id = GetOldID(info.target_id)
  if info.has_dir then
    info.dir = DecompressDirH2(info.dir)
  end
  local world = ECGame.Instance().m_CurWorld
  local obj = world:FindObjectOrHost(info.target_id)
  if obj ~= nil and obj.NetHdl ~= nil and info.damage > 0 then
    obj.NetHdl:OnCmd_ObjectBeAttacked(info)
  end
end
function _G.OnObjectStopSession(dt, who, type, param, param2)
  if _G.pause_protocol then
    return
  end
  who = GetOldID(who)
  local theGame = ECGame.Instance()
  local hp = theGame.m_HostPlayer
  if who == hp.ID then
    hp.NetHdl:OnCmd_ObjectStopSession(type, param, param2)
  else
    local world = theGame.m_CurWorld
    local obj = world:FindObject(who)
    if obj ~= nil and obj.NetHdl ~= nil then
      obj.NetHdl:OnCmd_ObjectStopSession(type, param, param2)
    end
  end
end
function _G.OnObjectTurn(dt, who, flags, dir)
  if _G.pause_protocol then
    return
  end
  who = GetOldID(who)
  local theGame = ECGame.Instance()
  local obj = theGame.m_CurWorld:FindObjectOrHost(who)
  if obj ~= nil then
    obj:OnTurn(dir)
  end
end
function _G.OnDisConnect(event)
  local msg
  local errorcode = _G.LastErrorCode
  _G.LastErrorCode = 0
  local theGame = ECGame.Instance()
  theGame.m_Network:OnClose()
  local hp = theGame.m_HostPlayer
  if hp then
    hp.SkillHdl:LeaveAutoFightingState()
    if not hp:IsDead() then
      hp:FSMChangeToStandState()
    end
  end
  if event == 1 and theGame.m_Network and theGame.m_Network.account and theGame.m_Network.ConnectTimes < 5 then
    if Application.platform == RuntimePlatform.IPhonePlayer or Application.platform == RuntimePlatform.Android then
      msg = _G.ErrorInfoString[errorcode] or StringTable.Get(800)
    else
      msg = _G.ErrorInfoString[errorcode] or StringTable.Get(804)
    end
    MsgBox.ShowMsgBoxEx(nil, msg, StringTable.Get(801), MsgBox.MsgBoxType.MBBT_OK, function(sender, ret)
      local theGame = ECGame.Instance()
      theGame:ReConnect()
    end, nil, nil, Priority.disconnect, function(msgbox)
      msgbox.m_depthLayer = GUIDEPTH.TOPMOST
      msgbox:BringTop()
    end)
  else
    if Application.platform == RuntimePlatform.IPhonePlayer or Application.platform == RuntimePlatform.Android then
      msg = _G.ErrorInfoString[errorcode] or StringTable.Get(802)
    else
      msg = _G.ErrorInfoString[errorcode] or StringTable.Get(805)
    end
    MsgBox.ShowMsgBoxEx(nil, msg, StringTable.Get(801), MsgBox.MsgBoxType.MBBT_OK, function(sender, ret)
      theGame:halfrelease()
      theGame:Start()
    end, nil, nil, Priority.disconnect, function(msgbox)
      msgbox.m_depthLayer = GUIDEPTH.TOPMOST
      msgbox:BringTop()
    end)
  end
  local ECPanelWaitingConnect = require("GUI.ECPanelWaitingConnect")
  ECPanelWaitingConnect.Instance():ShowPanel(false)
  local ECChatManager = require("Chat.ECChatManager")
  ECChatManager.Instance():MsgDisconnect()
end
function _G.OnClickGround(pos)
  theGame:OnClickGround(pos.x, pos.y)
end
function _G.OnMoveGround(pos)
  theGame:OnMoveGround(pos.x, pos.y)
end
function _G.OnClickScreen(pos)
  theGame:OnClickScreen(pos.x, pos.y)
end
function _G.OnPostClickScreen(pos)
  theGame:OnPostClickScreen(pos.x, pos.y)
end
function _G.DebugString(str)
  return theGame:DebugString(str)
end
function _G.OnUnityLog(logType, str)
  theGame:OnUnityLog(logType, str)
end
function _G.OnKeyboard(k)
  theGame:OnKeyboard(k)
end
function _G.OnJoystickPress(press)
  theGame:OnJoystickPress(press)
end
function _G.OnZoomStarted()
  theGame:OnZoomStarted()
end
function _G.OnZoom(deltaDist)
  theGame:OnZoom(deltaDist)
end
function _G.OnZoomEnded(totalDist)
  theGame:OnZoomEnded(totalDist)
end
function _G.Drama_Init(dramaObj, identity)
  CG.Instance():Drama_Init(dramaObj, identity)
end
function _G.DramaEvent_Start(dataTable, eventType, dramaName, eventObj)
  CG.Instance():DramaEvent_Start(dataTable, eventType, dramaName, eventObj)
end
function _G.DramaEvent_Update(dataTable, eventType, dramaName, eventObj)
  CG.Instance():DramaEvent_Update(dataTable, eventType, dramaName, eventObj)
end
function _G.DramaEvent_Release(dataTable, eventType, dramaName, eventObj)
  CG.Instance():DramaEvent_Release(dataTable, eventType, dramaName, eventObj)
end
function _G.Drama_Finish(dramaName, dramaObj)
  CG.Instance():Drama_Finish(dramaName, dramaObj)
end
function _G.ToggleDebugConsole()
  local ECPanelDebugInput = require("GUI.ECPanelDebugInput")
  GameUtil.AddGlobalTimer(0, true, function()
    ECPanelDebugInput.Instance():ToggleShow()
  end)
  _G.enableLogError = true
end
function _G.SetGuideOpen(open)
  _G.guide_open = open
end
function _G.FormatFunctionInfo(f)
  local info = debug.getinfo(f, "S")
  return ("%s:%d"):format(tostring(info.source), tostring(info.linedefined))
end
function _G.TODO(msg)
  local showText = "TODO: " .. tostring(msg)
  print(showText)
  FlashTipMan.FlashTip(showText)
end
function _G.AddGlobalTimerWithCleaner(ttl, once, callback, cleaner)
  local timer = GameUtil.AddGlobalTimer(ttl, once, callback)
  cleaner:add(function()
    GameUtil.RemoveGlobalTimer(timer)
  end)
end
function _G.RaiseAudio()
  local ECDebugOption = require("Main.ECDebugOption")
  local factor = ECDebugOption.Instance().raisevolfactor
  return factor, 1, -1
end
function _G.OnMainCameraEndOp(bMove, bYaw, bPitch)
  local ECGame = require("Main.ECGame")
  local CameraEvents = require("Event.CameraEvents")
  ECGame.EventManager:raiseEvent(nil, CameraEvents.CameraManualOpEvent.new(bMove, bYaw, bPitch))
end
function _G.ParseAllRes()
  require("Utility.ParseAllRes")
  parse_all_res()
end
function _G.gc()
  warn("gc!")
  collectgarbage("collect")
  GameUtil.GC()
  GameUtil.UnloadUnusedAssets(function()
  end)
end
function _G.ReleaseAll()
  GameObject.Find("EntryPoint"):SetActive(false)
  GameUtil.ReleaseAll()
  Object.DestroyImmediate(GameObject.Find("UI Root(2D)"), true)
end
_G.GameProfiler = require("Utility.GameProfiler")
local sprite_map = {}
local sprite_id = 0
function _G.Sprite_Create(path)
  local ECSprite = require("Sprite.ECSprite")
  local sp = ECSprite.new()
  if not sp:Load(path) then
    return 0
  end
  sprite_id = sprite_id + 1
  sprite_map[sprite_id] = sp
  return sprite_id
end
function _G.Sprite_Release(id)
  local ECSprite = require("Sprite.ECSprite")
  local sp = sprite_map[id]
  if not sp then
    return
  end
  sprite_map[id] = nil
  sp:Release()
end
function _G.Sprite_SetPos(id, x, y)
  local sp = sprite_map[id]
  if not sp then
    error("Sprite_SetPos")
    return
  end
  sp:SetPos(x, y)
end
_G.terraintile_map = {}
local terraintile_id = 0
local ECTerrainTile = require("Sprite.ECTerrainTile")
function _G.TerrainTile_Create(path)
  local sp = ECTerrainTile.new()
  terraintile_id = terraintile_id + 1
  if _G.IsLoadMap then
    MapNodeCount = MapNodeCount + 1
  end
  _G.terraintile_map[terraintile_id] = sp
  sp:Load(path)
  return terraintile_id
end
function _G.TerrainTile_Release(id)
  local sp = _G.terraintile_map[id]
  if not sp then
    return
  end
  _G.terraintile_map[id] = nil
  sp:Release()
end
local terraintile_map = _G.terraintile_map
local ECTerrainTile_SetPos = ECTerrainTile.SetPos
function _G.TerrainTile_SetPos(id, x, y)
  local sp = terraintile_map[id]
  if not sp then
    error("TerrainTile_SetPos")
    return
  end
  ECTerrainTile_SetPos(sp, x, y)
end
local sprite_effectMap = {}
local sprite_effectId = 0
function _G.SpriteEffect_Create(path)
  local ECSpriteAnim = require("Sprite.ECSpriteAnimation")
  local sp = ECSpriteAnim.new()
  if not sp:AsyncLoadAnimFile(path) then
    return 0
  end
  sprite_effectId = sprite_effectId + 1
  sprite_effectMap[sprite_effectId] = sp
  return sprite_effectId
end
function _G.SpriteEffect_CreateParent(id)
  local ECSpriteAnim = require("Sprite.ECSpriteAnimation")
  local sp = ECSpriteAnim.new()
  sprite_effectId = sprite_effectId + 1
  sprite_effectMap[sprite_effectId] = sp
  local childSp = sprite_effectMap[id]
  if childSp ~= nil then
    childSp.mSpiteObj.transform.parent = sp.mChildObj.transform
    childSp:CreateStaticPicSprite()
  end
  return sprite_effectId
end
function _G.SpriteEffect_SetPos(id, x, y)
  local sp = sprite_effectMap[id]
  if not sp then
    print("SpriteEffect_SetPos")
    return
  end
  sp:SetPos(x, y)
end
function _G.SpriteEffect_SetAbsPos(id, x, y)
  local sp = sprite_effectMap[id]
  if not sp then
    print("SpriteEffect_SetAbsPos")
    return
  end
  sp:SetAbsPos(x, y)
end
function _G.SpriteEffect_AddRect(id, x, y, w, h, offx, offy)
  local sp = sprite_effectMap[id]
  if not sp then
    print("SpriteEffect_AddRect")
    return
  end
  sp:AddRectInfo(x, y, w, h, offx, offy)
end
function _G.SpriteEffect_UpdateSpriteList(id, sec, loop, frameCount, playMode, blendOp)
  local sp = sprite_effectMap[id]
  if not sp then
    print("SpriteEffect_UpdateSpriteList")
    return
  end
  sp:UpdateSpriteList(sec, loop, frameCount, playMode, blendOp)
end
function _G.SpriteEffect_SetColor(id, r, g, b, a)
  local sp = sprite_effectMap[id]
  if not sp then
    print("SpriteEffect_SetColor")
    return
  end
  sp:SetColor(r, g, b, a)
end
function _G.SpriteEffect_SetScale(id, x, y)
  local sp = sprite_effectMap[id]
  if not sp then
    print("SpriteEffect_SetScale")
    return
  end
  sp:SetScale(x, y)
end
function _G.SpriteEffect_SetChildScale(id, x, y, frame, endFrame, frameCount, startFrame)
  local sp = sprite_effectMap[id]
  if not sp then
    print("SpriteEffect_SetChildScale")
    return
  end
  sp:AddPathScale(x, y, frame, endFrame, frameCount, startFrame)
end
function _G.SpriteEffect_AddPath(id, x, y, frame, endFrame, frameCount, startFrame)
  local sp = sprite_effectMap[id]
  if not sp then
    print("SpriteEffect_AddPath")
    return
  end
  sp:AddPath(x, y, frame, endFrame, frameCount, startFrame)
end
function _G.SpriteEffect_RequireRes(id)
  local sp = sprite_effectMap[id]
  if not sp then
    print("SpriteEffect_AddPath")
    return
  end
  sp:SetEnable(true)
end
function _G.SpriteEffect_ReleaseRes(id)
  local sp = sprite_effectMap[id]
  if not sp then
    print("SpriteEffect_AddPath")
    return
  end
  sp:SetEnable(false)
end
function _G.SpriteEffect_BeginPath(id)
  local sp = sprite_effectMap[id]
  if not sp then
    print("SpriteEffect_BeginPath")
    return
  end
  sp:BeginPath()
end
function _G.SpriteEffect_AddAlphaPath(id, alpha, frame, endFrame, frameCount, startFrame)
  local sp = sprite_effectMap[id]
  if not sp then
    print("SpriteEffect_AddAlphaPath")
    return
  end
  sp:AddPathAlpha(alpha, frame, endFrame, frameCount, startFrame)
end
function _G.SpriteEffect_BeginAlphaPath(id)
  local sp = sprite_effectMap[id]
  if not sp then
    print("SpriteEffect_BeginAlphaPath")
    return
  end
  sp:BeginAlphaPath()
end
function _G.SpriteEffect_RotationZ(id, ang, frame, endFrame, frameCount, startFrame)
  local sp = sprite_effectMap[id]
  if not sp then
    print("SpriteEffect_RotationZ")
    return
  end
  sp:AddRotationPath(ang, frame, endFrame, frameCount, startFrame)
end
function _G.SpriteEffect_BeginScalePath(id)
  local sp = sprite_effectMap[id]
  if not sp then
    print("SpriteEffect_BeginAlphaPath")
    return
  end
  sp:BeginScalePath()
end
function _G.SpriteEffect_BeginRotationPath(id)
  local sp = sprite_effectMap[id]
  if not sp then
    print("SpriteEffect_BeginAlphaPath")
    return
  end
  sp:BeginRotationPath()
end
function _G.SpriteEffect_Release_all()
  warn("SpriteEffect_Release_all...")
  for k, v in pairs(sprite_effectMap) do
    v:Release()
    sprite_effectMap[k] = nil
  end
end
local sprite_effectMap = {}
local sprite_effectId = 0
function _G.MapEffect_RequireRes(x, y, effectType, resnames)
  sprite_effectId = sprite_effectId + 1
  local ECMapEffect = require("Sprite.ECMapEffect")
  local effect = ECMapEffect.new()
  sprite_effectMap[sprite_effectId] = effect
  effect:Init(x, y, effectType, resnames)
  return sprite_effectId
end
function _G.MapEffect_ReleaseRes(id)
  local effect = sprite_effectMap[id]
  if not effect then
    print("MapEffect_ReleaseRes error")
    return
  end
  effect:Release()
  sprite_effectMap[id] = nil
end
function _G.Camera_SetFocus(x, y)
  ECGame.Instance():SetCameraFocus(x, y)
end
function _G.GameCameraMove(x, y)
  Camera2D.SetFocus(x, world_height - y)
end
function _G.World_SetSize(w, h)
  _G.world_width = w
  _G.world_height = h
end
function _G.SetCameraOffsetPos(offx, offy, w, h)
  _G.world_offx = offx
  _G.world_offy = offy
  _G.screen_w = w
  _G.screen_h = h
end
function _G.ScreenTo3D(x, y)
  local pos = ScreenToMap2DPos(x, y)
  return Map2DPosTo3D(pos.x, pos.y)
end
local screen_pos = EC.Vector3.new(0, 0, 0)
function _G.ScreenToMap2DPos(x, y)
  screen_pos.x = x
  screen_pos.y = y
  return ECGame.Instance().m_2DWorldCam:ScreenToWorldPoint(screen_pos)
end
local _2d_to_3d_co = 1 / math.sin(cam_3d_rad)
local _3d_to_2d_tan = math.tan(cam_3d_rad)
function _G.Map2DPosTo3D(x, y)
  return EC.Vector3.new(x * cam_2d_to_3d_scale, 0, y * _2d_to_3d_co * cam_2d_to_3d_scale)
end
function _G.WorldPosToMap2D(pos_3d)
  return pos_3d.x / cam_2d_to_3d_scale, world_height - pos_3d.z / (_2d_to_3d_co * cam_2d_to_3d_scale)
end
function _G.WorldPosTo2D(pos_3d)
  return pos_3d.x / cam_2d_to_3d_scale, pos_3d.z / (_2d_to_3d_co * cam_2d_to_3d_scale)
end
function _G.Set2DPosTo3D(x, y, v)
  v.x = x * cam_2d_to_3d_scale
  v.y = 0
  v.z = y * _2d_to_3d_co * cam_2d_to_3d_scale
end
function _G.Calc3DYTo2DY(y)
  return y * _3d_to_2d_tan / cam_2d_to_3d_scale
end
function _G.WorldPosToScreen(x, y, z)
  local uiRoot = ECGUIMan.Instance().m_UIRoot
  return EC.Vector2.new(x / uiRoot.localScale.x, y / uiRoot.localScale.y)
end
function _G.WorldPosToNonStandardScreen(x, y, z)
  local uiRoot = ECGUIMan.Instance().m_UIRoot
  local ratio_x, ratio_y = 1, 1
  if ECGame.Instance().m_2DWorldCam.aspect > 1.49 then
    ratio_x = ECGame.Instance().m_2DWorldCam.aspect / 1.5
  else
    ratio_y = 1.5 / ECGame.Instance().m_2DWorldCam.aspect
  end
  return EC.Vector2.new(ratio_x * x / uiRoot.localScale.x, ratio_y * y / uiRoot.localScale.y)
end
function _G.ScreenPosToWorld(x, y)
  local uiRoot = ECGUIMan.Instance().m_UIRoot
  return EC.Vector3.new(x * uiRoot.localScale.x, y * uiRoot.localScale.y, 0)
end
local model_map = {}
local model_id = 0
function _G.Model_Load(path, x, y, ang)
  local model_record = {}
  local m = ECModel.new()
  model_record.model = m
  model_record.pos = {x = x, y = y}
  model_record.ang = ang
  model_record.valid = true
  model_id = model_id + 1
  warn("Model_Load Path =", path)
  model_record.model.m_node2d = GameObject.GameObject("node2d_" .. tostring(model_id))
  model_map[model_id] = model_record
  m:Load(path, function(ret)
    if ret and model_record.valid then
      local model = m.m_model
      model:SetLayer(ClientDef_Layer.Player)
      model.localPosition = Map2DPosTo3D(model_record.pos.x, world_height - model_record.pos.y)
      model.localRotation = Quaternion.Euler(EC.Vector3.new(0, model_record.ang, 0))
    end
  end)
  return model_id
end
function _G.Model_GetPlayer(id)
  return model_map[id]
end
function _G.Model_SetPos(id, x, y)
  local model_record = model_map[id]
  if not model_record then
    return
  end
  local model = model_record.model.m_model
  if model then
    model.localPosition = Map2DPosTo3D(x, world_height - y)
  else
    model_record.pos.x = x
    model_record.pos.y = y
  end
  model_record.model.m_node2d.localPosition = EC.Vector3.new(x, y, 0)
end
function _G.Model_SetDir(id, ang)
  local model_record = model_map[id]
  if not model_record then
    return
  end
  local model = model_record.model.m_model
  if model then
    model.localRotation = Quaternion.Euler(EC.Vector3.new(0, ang, 0))
  else
    model_record.ang = ang
  end
end
function _G.LoadMapAllByID(id)
  require("Main.Map.MapModule").Instance():LoadMap(id)
  print("loadMap " .. tostring(id))
end
function _G.HtmlToString(htmlTxt)
  local HtmlUtility = require("Utility.HtmlUtility")
  local txt = HtmlUtility.HtmlToNguiText(htmlTxt)
  return txt
end
function _G.Get_cam_3d_degree()
  return cam_3d_degree
end
function _G.Get_cam_2d_to_3d_scale()
  return cam_2d_to_3d_scale
end
function _G.AsyncLoadArray(arr, onfinish, ...)
  local ret = {}
  if #arr == 0 then
    onfinish(ret)
  end
  local count = 0
  local function _onload(i, obj)
    ret[i] = obj
    count = count + 1
    if count == #arr then
      onfinish(ret)
    end
  end
  for i = 1, #arr do
    GameUtil.AsyncLoad(arr[i], function(obj)
      _onload(i, obj)
    end, ...)
  end
end
function _G.WriteToFile(path, content)
  GameUtil.CreateDirectoryForFile(path)
  local fout = io.open(path, "wb")
  if fout then
    fout:write(content)
    fout:close()
    return true
  else
    return false
  end
end
function _G.test1()
  local ECMSDK = require("ProxySDK.ECMSDK")
  ECMSDK.SendTLogToServer(_G.TLOGTYPE.ADDQQFRIEND, {
    "fsZEILJFJDFL473UIFD",
    _G.GetMyRoleID():tostring(),
    12
  })
end
function _G.test2()
  local ECMSDK = require("ProxySDK.ECMSDK")
  ECMSDK.SendTLogToServer(_G.TLOGTYPE.WXGROUP, {
    Int64.new(34235):tostring(),
    "fregr",
    2
  })
end
function _G.ReportEvent(name, processid, isRealTime)
  local ECMSDK = require("ProxySDK.ECMSDK")
  ECMSDK.ReportEvent(name, processid, isRealTime)
end
function _G.SetLogLevel(level)
  if level and level >= 0 and level <= 5 then
    GameUtil.SetLogLevel(level)
  end
end
function _G.onMemoryWarning(level)
  if level == 80 or level == 10 or level == 15 then
    theGame:SyncGC()
    theGame:GCTLog("warn")
  end
end
