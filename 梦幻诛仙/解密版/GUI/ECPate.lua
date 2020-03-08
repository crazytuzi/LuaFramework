local Lplus = require("Lplus")
local ECGUIMan = Lplus.ForwardDeclare("ECGUIMan")
local EC = require("Types.Vector3")
local ECFxMan = require("Fx.ECFxMan")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECHostPlayer = Lplus.ForwardDeclare("ECHostPlayer")
require("Common.ECClientDef")
local ECModel = require("Model.ECModel")
local FightModel = require("Main.Fight.FightModel")
local ECPlayer = require("Model.ECPlayer")
local GUIUtils = require("GUI.GUIUtils")
local _TopHpPatePrefab, _PlayerTopPatePrefab, _MinePatePrefab, _FightSelectPrefab, _FightCmdPrefab, _FightBuffPrefab, _TalkPrefab, _TopButton, _BallCooldownPrefab
local _EnablePate = true
local _TopHpPateCache, _PlayerTopPateCache, _MinePateCache, _FightSelectCache, _TalkCache, _FightCmdCache, _FightBuffCache, _TopButtonCache, _BallCooldownCache
local uiButtomLayer = -100
local uiTopLayer = -100000
local t_vec = EC.Vector3.new()
local ECPate = Lplus.Class("ECPate")
local def = ECPate.define
def.field("userdata").m_pate = nil
def.field("userdata").m_follow = nil
def.field("boolean").m_touchable = false
def.field("table").m_fxList = function()
  return {}
end
def.static("=>", ECPate).new = function()
  local obj = ECPate()
  if _TopHpPateCache == nil then
    ECPate.Setup()
  end
  return obj
end
def.static("function").LoadPatePrefab = function(onFinish)
  AsyncLoadArray({
    RESPATH.PateTopHp,
    RESPATH.PatePlayerTopPlate,
    RESPATH.PateMine,
    RESPATH.FIGHT_SELECT,
    RESPATH.PateTalk,
    RESPATH.PateCommand,
    RESPATH.PateBuff,
    RESPATH.PateBtn,
    RESPATH.PateBallCooldown
  }, function(assetArr)
    _TopHpPatePrefab = assetArr[1]
    _PlayerTopPatePrefab = assetArr[2]
    _MinePatePrefab = assetArr[3]
    _FightSelectPrefab = assetArr[4]
    _TalkPrefab = assetArr[5]
    _FightCmdPrefab = assetArr[6]
    _FightBuffPrefab = assetArr[7]
    _TopButton = assetArr[8]
    _BallCooldownPrefab = assetArr[9]
    if onFinish then
      onFinish()
    end
  end)
end
def.static("boolean").Enable = function(enable)
  _EnablePate = enable
end
def.static().Setup = function()
  _TopHpPateCache = GameObject.GameObject("TopHpPateCache")
  _TopHpPateCache:SetActive(false)
  _PlayerTopPateCache = GameObject.GameObject("PlayerTopPateCache")
  _PlayerTopPateCache:SetActive(false)
  _MinePateCache = GameObject.GameObject("MinePateCache")
  _MinePateCache:SetActive(false)
  _FightSelectCache = GameObject.GameObject("FightSelectCache")
  _FightSelectCache:SetActive(false)
  _TalkCache = GameObject.GameObject("TalkCache")
  _TalkCache:SetActive(false)
  _FightCmdCache = GameObject.GameObject("FightSelectCache")
  _FightCmdCache:SetActive(false)
  _FightBuffCache = GameObject.GameObject("FightBuffCache")
  _FightBuffCache:SetActive(false)
  _TopButtonCache = GameObject.GameObject("TopButtonCache")
  _TopButtonCache:SetActive(false)
  _BallCooldownCache = GameObject.GameObject("BallCooldownCache")
  _BallCooldownCache:SetActive(false)
end
def.method("userdata", "userdata", "userdata", "number", "=>", "userdata")._CreateFromCacheByHp = function(self, obj, cache, prefab, offsetH)
  local pate = Object.Instantiate(prefab, "GameObject")
  pate.name = "Pate"
  pate:SetLayer(ClientDef_Layer.PateTextDepth)
  self.m_pate = pate
  self:_AttachTargetByHp(obj, offsetH)
  self.m_pate:SetActive(false)
  local curpate = self.m_pate
  return pate
end
def.method("userdata", "userdata", "userdata", "number", "=>", "userdata")._CreateFromCache = function(self, obj, cache, prefab, offsetH)
  local pate
  if cache and cache.childCount > 0 then
    local hud = cache:GetChild(0)
    hud.name = obj.name
    local follow = hud:GetComponent("HUDFollowTarget")
    follow.target = obj.transform
    follow.offset = t_vec:Assign(0, offsetH, 0)
    self.m_follow = follow
    hud.parent = ECGUIMan.Instance():GetHudTopBoardRoot()
    pate = hud:FindDirect("Pate")
    hud:SetActive(true)
    self.m_pate = pate
  else
    pate = Object.Instantiate(prefab, "GameObject")
    pate.name = "Pate"
    self.m_pate = pate
    self:_AttachTarget(obj, offsetH)
  end
  self.m_pate:SetActive(false)
  local curpate = self.m_pate
  return pate
end
def.static("userdata", "number").ResetPosition = function(pate, offsetH)
  if pate == nil then
    return
  end
  local follow = pate:GetComponent("HUDFollowTarget")
  if follow then
    follow.offset = t_vec:Assign(0, offsetH, 0)
  end
end
def.method(ECModel).ResetParent = function(self, parent)
  if parent == nil or parent.m_model == nil or parent.m_model.isnil then
    return
  end
  local follow = self.m_follow
  if follow then
    follow.target = parent.m_model.transform
  end
end
def.virtual("=>", "userdata").GetCacheRoot = function(self)
  return nil
end
def.virtual().Release = function(self)
  self:SetFxStatusList(nil)
  if self.m_pate then
    local hud = self.m_pate.parent
    hud.parent = self:GetCacheRoot()
    self.m_follow.target = nil
    self.m_follow = nil
    self.m_pate = nil
  end
end
def.static("userdata", "userdata").AddToCache = function(hud, cacheroot)
  local follow = hud:GetComponent("HUDFollowTarget")
  follow.target = nil
  follow.node2DTm = nil
  hud.parent = cacheroot
end
def.method("userdata", "number")._AttachTargetByHp = function(self, target, offsetH)
  local hud = ECGUIMan.Instance():CreateHudByHp(target.name)
  local follow = hud:AddComponent("HUDFollowTarget")
  follow.target = target.transform
  follow.offset = t_vec:Assign(0, offsetH, 0)
  self.m_pate.parent = hud
  self.m_pate.localPosition = EC.Vector3.zero
  self.m_pate.localScale = EC.Vector3.one
  hud:SetLayer(ClientDef_Layer.PateTextDepth)
  hud:SetActive(true)
  self.m_follow = follow
end
def.method("userdata", "number")._AttachTarget = function(self, target, offsetH)
  local hud = ECGUIMan.Instance():CreateHud(target.name)
  local follow = hud:AddComponent("HUDFollowTarget")
  follow.target = target.transform
  follow.offset = t_vec:Assign(0, offsetH, 0)
  self.m_pate.parent = hud
  self.m_pate.localPosition = EC.Vector3.zero
  self.m_pate.localScale = EC.Vector3.one
  hud:SetLayer(ClientDef_Layer.PateText)
  hud:SetActive(true)
  self.m_follow = follow
end
def.method("boolean").SetVisible = function(self, visible)
  self.m_follow.enableAll = visible
end
def.method("boolean", "function").SetTouchable = function(self, touch, cb)
  self.m_touchable = touch
  if self.m_pate ~= nil and not self.m_pate.isnil then
    if touch then
      local msgHandler = self.m_pate:GetComponent("GUIMsgHandler")
      msgHandler = msgHandler or self.m_pate:AddComponent("GUIMsgHandler")
      local msgt = {onClick = cb}
      msgHandler:SetMsgTable(msgt, self)
      msgHandler:Touch(self.m_pate)
    else
      local msgHandler = self.m_pate:GetComponent("GUIMsgHandler")
      if msgHandler then
        Object.Destroy(self.m_pate)
      end
    end
  end
end
def.method("table", "=>", "boolean").SetFxStatusList = function(self, fxPathList)
  if not self.m_pate then
    return
  end
  local FxMan = ECFxMan.Instance()
  for i = #self.m_fxList, 1, -1 do
    if not self.m_fxList[i].isnil then
      FxMan:Stop(self.m_fxList[i])
    end
    self.m_fxList[i] = nil
  end
  if fxPathList == nil then
    return true
  end
  local pate = self.m_pate
  local fxStatusList = pate:FindDirect("Fx_StatusList")
  if fxStatusList == nil then
    warn("Can not find Fx_StatusList in ECPate")
    return false
  end
  local localpos = EC.Vector3.new(0, 0, 0)
  local localrot = Quaternion.identity
  local listComponent = fxStatusList:GetComponent("UIList")
  local count = #fxPathList
  listComponent.itemCount = count
  listComponent:Resize()
  local fxItems = listComponent.children
  for i = 1, count do
    if fxPathList[i] then
      local fxControl = fxItems[i]:FindChild("fx")
      local fx = FxMan:PlayAsChild(fxPathList[i], fxControl, EC.Vector3.new(0, 0, 0), Quaternion.identity, -1, false, -1)
      if fx then
        fx:GetComponent("FxOne").Stable = true
        fx:SetLayer(ClientDef_Layer.PateText)
        self.m_fxList[#self.m_fxList + 1] = fx
      end
    end
  end
  fxStatusList:GetComponent("UIAnchor").enabled = true
  fxStatusList:GetComponent("UIList").repositionNow = true
  return true
end
def.method("userdata", "number", "=>", "userdata", "number").GetPateAttachObj = function(self, obj, offsetH)
  local attachObj = obj:FindDirect("name_on_horse")
  attachObj = attachObj or obj:FindDirect("name")
  if attachObj then
    return attachObj, 0
  end
  return obj, offsetH
end
local t_pos = EC.Vector3.new(0, 0, 0)
local t_scale = EC.Vector3.new(200, 200, 200)
local topLayer_pos = EC.Vector3.new(0, 0, uiTopLayer)
def.method(ECModel).CreateNameBoard = function(self, ecModel)
  local function doCreate()
    local attachObj, offsetH = ecModel.m_model, ecModel.nameOffset
    if attachObj == nil or attachObj:get_isnil() then
      return
    end
    local pate = self:_CreateFromCache(attachObj, _MinePateCache, _MinePatePrefab, offsetH)
    local titlePanel = pate:FindDirect("Title")
    titlePanel.localScale = t_scale
    t_pos.z = uiButtomLayer
    titlePanel.localPosition = t_pos
    local nameLabel = pate:FindDirect("Lab_Name")
    nameLabel.localScale = t_scale
    pate:SetActive(ecModel.m_visible and ecModel.showPart)
    ecModel.m_uiNameHandle = self.m_pate.parent
    ecModel.m_uiNameHandleCacheRoot = _MinePateCache
    ecModel:SetName(ecModel.m_Name, ecModel.m_uNameColor)
    self.m_follow.offsetScale = false
  end
  if _MinePatePrefab then
    doCreate()
  else
    ECPate.LoadPatePrefab(doCreate)
  end
end
def.method(ECModel).CreateNameBoardByCgEditor = function(self, ecModel)
  local function doCreate()
    local attachObj, offsetH = ecModel.m_model, -20
    if attachObj == nil or attachObj:get_isnil() then
      return
    end
    local pate = self:_CreateFromCache(attachObj, _MinePateCache, _MinePatePrefab, offsetH)
    self.m_follow.node2DTm = ecModel.m_node2d.transform
    local titlePanel = pate:FindDirect("Title")
    titlePanel.localScale = t_scale
    local nameLabel = pate:FindDirect("Lab_Name")
    nameLabel.localScale = t_scale
    nameLabel.localPosition = topLayer_pos
    pate:SetActive(ecModel.m_visible)
    ecModel.m_uiNameHandle = self.m_pate.parent
    ecModel.m_uiNameHandleCacheRoot = _MinePateCache
    ecModel:SetName(ecModel.m_Name, ecModel.m_uNameColor)
    local hud = self.m_pate.parent:GetComponent("HUDFollowTarget")
    hud.offsetScale = false
  end
  if _MinePatePrefab then
    doCreate()
  else
    ECPate.LoadPatePrefab(doCreate)
  end
end
def.method(ECModel, "string", "number", "string", "number", "number").CreateUIBoard = function(self, ecModel, resName, offsetH, txt, endTime, uiType)
  local function doCreate(obj)
    local attachObj, _offsetH = ecModel.m_model, offsetH
    if attachObj == nil or attachObj:get_isnil() then
      return
    end
    local pate = self:_CreateFromCache(attachObj, nil, obj, _offsetH)
    if self.m_follow.isnil or ecModel.m_node2d.isnil then
      return
    end
    self.m_follow.node2DTm = ecModel.m_node2d.transform
    local titleLabel = pate:FindDirect("Label")
    local dialogCom = pate:GetComponent("DialogLabel")
    if dialogCom ~= nil then
      dialogCom:SetType(uiType)
      dialogCom:SetText(txt)
      dialogCom:SetEndTime(endTime)
    end
    pate:SetActive(ecModel.m_visible)
    pate.localScale = t_scale
    pate.localPosition = topLayer_pos
    if uiType == 3 then
      ecModel.m_uiNameHandle = self.m_pate.parent
    else
      if ecModel.m_uiDialogHandle ~= nil then
        ecModel.m_uiDialogHandle:Destroy()
        ecModel.m_uiDialogHandle = nil
      end
      ecModel.m_uiDialogHandle = self.m_pate.parent
    end
  end
  GameUtil.AsyncLoad(resName, doCreate)
end
local pate_scale = EC.Vector3.new(300, 300, 1)
def.method(FightModel).CreateHpBoard = function(self, fightmodel)
  local function doCreate()
    local attachObj = fightmodel.m_model
    local offsetH = fightmodel:GetBoxHeight()
    if offsetH == 0 then
      offsetH = 2.4
    else
      offsetH = offsetH * attachObj.localScale.x + 0.4
    end
    if attachObj == nil or attachObj:get_isnil() then
      return
    end
    local pate = self:_CreateFromCacheByHp(attachObj, _TopHpPateCache, _TopHpPatePrefab, offsetH)
    local slider = pate:FindChild("Prog_HP"):GetComponent("UISlider")
    pate:FindDirect("Prog_MP"):SetActive(false)
    pate.localScale = pate_scale
    pate.localPosition = topLayer_pos
    pate:SetLayer(ClientDef_Layer.PateTextDepth)
    slider.value = 1
    pate:SetActive(true)
    local hud = self.m_pate.parent:GetComponent("HUDFollowTarget")
    hud.offsetScale = false
    fightmodel.m_uiHpHandle = self.m_pate.parent
    fightmodel:SetHp(fightmodel.hp)
  end
  if _TopHpPatePrefab then
    doCreate()
  else
    ECPate.LoadPatePrefab(doCreate)
  end
end
def.method("table", "function").CreateTopBoard = function(self, player, cb)
  local function doCreate()
    local attachObj = player.m_model
    if attachObj == nil or attachObj:get_isnil() then
      return
    end
    local offsetH = 2
    local pate = self:_CreateFromCache(attachObj, _PlayerTopPateCache, _PlayerTopPatePrefab, offsetH)
    pate.localScale = pate_scale
    pate.localPosition = topLayer_pos
    pate:SetActive(true)
    pate:FindDirect("Img_Chengwei"):GetComponent("UITexture").mainTexture = nil
    pate:FindDirect("Label_Info"):GetComponent("UILabel").text = ""
    player.m_topIcon = self.m_pate.parent
    player.m_topIcon:SetActive(player.m_visible and player.showModel and player.showPart)
    player.m_topIconCacheRoot = _PlayerTopPateCache
    player:SetPate()
    player:SetTitleIcon(player.titleIcon)
    player:SetFlagIcon(player.flagIcon)
    if cb then
      cb()
    end
  end
  if _PlayerTopPatePrefab then
    doCreate()
  else
    ECPate.LoadPatePrefab(doCreate)
  end
end
def.method(FightModel).CreateSelectBoard = function(self, fightmodel)
  local function doCreate()
    local attachObj, offsetH = fightmodel.m_model, 0.4
    if attachObj == nil or attachObj:get_isnil() then
      return
    end
    local pate = self:_CreateFromCache(attachObj, _FightSelectCache, _FightSelectPrefab, offsetH)
    pate:FindDirect("Img_Sign"):SetActive(false)
    pate.localScale = pate_scale
    pate.localPosition = topLayer_pos
    pate:SetActive(true)
    local hud = self.m_pate.parent:GetComponent("HUDFollowTarget")
    hud.offsetScale = false
    fightmodel.m_selectIcon = self.m_pate.parent
  end
  if _FightSelectPrefab then
    doCreate()
  else
    ECPate.LoadPatePrefab(doCreate)
  end
end
def.method(FightModel).CreateCommandBoard = function(self, fightmodel)
  local function doCreate()
    local attachObj, offsetH = fightmodel.m_model, 0.64
    if attachObj == nil or attachObj:get_isnil() then
      return
    end
    local pate = self:_CreateFromCache(attachObj, _FightCmdCache, _FightCmdPrefab, offsetH)
    pate.localScale = pate_scale
    pate.localPosition = topLayer_pos
    pate:FindDirect("Label_ZhiHui"):SetActive(false)
    pate:SetActive(true)
    local hud = self.m_pate.parent:GetComponent("HUDFollowTarget")
    hud.offsetScale = false
    fightmodel.m_commandPanel = self.m_pate.parent
  end
  if _FightCmdPrefab then
    doCreate()
  else
    ECPate.LoadPatePrefab(doCreate)
  end
end
def.method(ECModel, "function").CreateTalkBoard = function(self, model, cb)
  local function doCreate()
    local attachObj = model.m_model
    local offsetH = model:GetBoxHeight()
    if offsetH == 0 then
      offsetH = 2
    else
      offsetH = offsetH * attachObj.localScale.x
    end
    if attachObj == nil or attachObj:get_isnil() then
      return
    end
    local attachObj, offsetH = model.m_model, offsetH
    if attachObj == nil or attachObj:get_isnil() then
      return
    end
    local pate
    if PlayerIsInFight() == true then
      pate = self:_CreateFromCacheByHp(attachObj, _TalkCache, _TalkPrefab, offsetH)
    else
      pate = self:_CreateFromCache(attachObj, _TalkCache, _TalkPrefab, offsetH)
    end
    pate.localScale = pate_scale
    pate.localPosition = topLayer_pos
    pate:SetActive(model.m_visible and model.showModel)
    model.m_talkPop = self.m_pate
    cb()
  end
  if _TalkPrefab then
    doCreate()
  else
    ECPate.LoadPatePrefab(doCreate)
  end
end
def.method(FightModel).CreateFightBuffBoard = function(self, fightmodel)
  local function doCreate()
    local attachObj, offsetH = fightmodel.m_model, -0.8
    if attachObj == nil or attachObj:get_isnil() then
      return
    end
    local pate = self:_CreateFromCache(attachObj, _FightBuffCache, _FightBuffPrefab, offsetH)
    pate.localScale = pate_scale
    pate.localPosition = topLayer_pos
    pate:SetActive(true)
    local hud = self.m_pate.parent:GetComponent("HUDFollowTarget")
    hud.offsetScale = false
    fightmodel.m_buffPanel = self.m_pate.parent
  end
  if _FightBuffPrefab then
    doCreate()
  else
    ECPate.LoadPatePrefab(doCreate)
  end
end
def.method("table", "number", "string").CreateTopButton = function(self, player, icon, btnName)
  local function doCreate()
    local attachObj = player.m_model
    if attachObj == nil or attachObj:get_isnil() then
      return
    end
    local offsetH = 2
    local pate = self:_CreateFromCache(attachObj, _TopButtonCache, _TopButton, offsetH)
    pate.localScale = pate_scale
    pate.localPosition = topLayer_pos
    pate:SetActive(player.m_visible and player.showModel and player.showPart)
    player.m_topButton = pate
    local btn = pate:FindDirect("Sprite")
    GUIUtils.FillIcon(btn:GetComponent("UITexture"), icon)
    warn("CreateTopButton", icon)
    btn.name = btnName
    self:SetTouchable(true, function(panel, id)
      player:OnTopButtonClick(id)
    end)
  end
  if _TopButton then
    doCreate()
  else
    ECPate.LoadPatePrefab(doCreate)
  end
end
def.method("table", "number", "number").CreateBallCooldown = function(self, player)
  local function doCreate()
    local attachObj = player.m_model
    if attachObj == nil or attachObj:get_isnil() then
      return
    end
    local offsetH = 0.95
    local pate = self:_CreateFromCache(attachObj, _BallCooldownCache, _BallCooldownPrefab, offsetH)
    pate.localScale = pate_scale
    pate.localPosition = topLayer_pos
    pate:SetActive(player.m_visible and player.showModel and player.showPart)
    player.m_ballCooldownPate = pate
    player:UpdateBallCooldownPate()
  end
  if _BallCooldownPrefab then
    doCreate()
  else
    ECPate.LoadPatePrefab(doCreate)
  end
end
ECPate.Commit()
return ECPate
