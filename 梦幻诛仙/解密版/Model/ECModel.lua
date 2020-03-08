local Lplus = require("Lplus")
local ECObject = require("Model.ECObject")
local EC = require("Types.Vector3")
local ECFxMan = require("Fx.ECFxMan")
local ECGUIMan = Lplus.ForwardDeclare("ECGUIMan")
local ECModel = Lplus.Extend(ECObject, "ECModel")
ECModel.alphaShaderList = {}
ECModel.dissolveShaderList = {}
ECModel.dissolveAnimatorCtrls = {}
ECModel.dissolvesTexture = {}
ECModel.ghostShaderList = {}
ECModel.lightRes = {}
local def = ECModel.define
local _unique_id = 0
local function get_unique_id()
  _unique_id = _unique_id + 1
  return _unique_id
end
_G.ecmodel_loaded_count = 0
local ecmodel_loaded_info_map = {}
function _G.PrintModelInfo()
  local l = {}
  for _, respath in pairs(ecmodel_loaded_info_map) do
    l[#l + 1] = respath
  end
  Debug.LogWarning("all loaded models, count = " .. #l)
  local filename = GameUtil.GetAssetsPath() .. "/modelinfo.csv"
  local f = io.open(filename, "w")
  local title = "all loaded models, count = " .. #l
  f:write(title)
  f:write("\n")
  for i = 1, #l do
    f:write(l[i])
    f:write([[


]])
  end
  f:close()
end
def.const("table").Name = {
  Body = "Body",
  Equip = "Equip",
  Hair = "Hair",
  Panda = "Panda"
}
def.field("number").mModelId = 0
def.field("userdata").m_asset = nil
def.field("userdata").m_model = nil
def.field("userdata").m_ani = nil
def.field("boolean").m_create_node2d = false
def.field("userdata").m_node2d = nil
def.field("number").m_status = ModelStatus.NONE
def.field("number").m_ang = 0
def.field("table").m_attachments = function()
  return {}
end
def.field("string").m_resName = ""
def.field("table").m_renderers = nil
def.field("boolean").m_visible = true
def.field("boolean").showModel = true
def.field("boolean").showPart = true
def.field("boolean").m_bUncache = false
def.field("table").srcShaders = nil
def.field("string").m_Name = ""
def.field("string").m_title = ""
def.field("string").m_showTitle = ""
def.field("userdata").showTitleColor = nil
def.field("userdata").m_titleColor = nil
def.field("boolean").m_isNameDepth = false
def.field("userdata").m_uiNameHandle = nil
def.field("number").nameOffset = default_name_offset
def.field("userdata").m_uiNameHandleCacheRoot = nil
def.field("userdata").m_uiDialogHandle = nil
def.field("userdata").m_uNameColor = nil
def.field("number").nameIcon = 0
def.field("userdata").m_talkPop = nil
def.field("number").m_talkTimer = 0
def.field("function").m_callWhenAnimFinished = nil
def.field("table").onLoadCallback = nil
def.field("boolean").m_IsAlpha = false
def.field("boolean").m_IsStone = false
def.field("boolean").m_IsTouchable = false
def.field("userdata").parentNode = nil
def.field("userdata").defaultParentNode = nil
def.field("number").defaultLayer = ClientDef_Layer.Player
def.field("number").aniTime = 0
def.field("table").m_color = nil
def.field("string").curAniName = ""
def.field("number").colorId = 0
def.field("table").m_originalColors = nil
def.field("userdata").mShadowObj = nil
def.field("table").mShadowScale = function()
  return EC.Vector3.one
end
def.field("dynamic")._UniqueId = nil
def.field("table").EquipStatus = nil
def.field("table").Equip_Effects = nil
def.field("table").original_equip_info = nil
def.field("table").costumeInfo = nil
local aniInfos = {}
local instantiate_count_per_frame = 1
local instantiate_count = 0
local on_load_time_limit = 0.015
_G.skip_cur_onload_frame = false
local loaded_result_list = {}
local t_vec = EC.Vector3.new()
def.final("number", "=>", ECModel).new = function(id)
  local obj = ECModel()
  obj:Init(id)
  return obj
end
def.virtual("number", "=>", "boolean").Init = function(self, id)
  self.mModelId = id
  if id < 0 then
    return false
  end
  if self.m_create_node2d then
    if self.m_node2d then
      Object.Destroy(self.m_node2d)
    end
    self.m_node2d = GameObject.GameObject("node2d_" .. tostring(id))
    self.m_node2d.parent = self.defaultParentNode
  end
  return true
end
def.virtual("=>", "string").GetName = function(self)
  return self.m_Name
end
def.virtual("string", "userdata").SetName = function(self, name, color)
  if name ~= nil and name ~= "" then
    self.m_Name = name
  end
  if color ~= nil then
    self.m_uNameColor = color
  end
  self:SetNamePanel()
  if self.m_uiNameHandle then
    if self.m_isNameDepth and self.m_uiNameHandle.layer == ClientDef_Layer.PateText then
      self:SetNameToDepth()
    elseif self.m_isNameDepth == false and self.m_uiNameHandle.layer == ClientDef_Layer.PateTextDepth then
      self:SetNameNoDepth()
    end
  end
end
def.method().SetNameToDepth = function(self)
  self.m_isNameDepth = true
  if self.m_uiNameHandle then
    self.m_uiNameHandle:SetActive(false)
    local go = ECGUIMan.Instance():_GetHudTopBoardGroupWithDepth()
    self.m_uiNameHandle.parent = go
    self.m_uiNameHandle:SetLayer(ClientDef_Layer.PateTextDepth)
    self.m_uiNameHandle:SetActive(true)
  end
end
def.method().SetNameNoDepth = function(self)
  self.m_isNameDepth = false
  if self.m_uiNameHandle then
    self.m_uiNameHandle:SetActive(false)
    local go = ECGUIMan.Instance():GetHudTopBoardRoot()
    self.m_uiNameHandle.parent = go
    self.m_uiNameHandle:SetLayer(ClientDef_Layer.PateText)
    self.m_uiNameHandle:SetActive(true)
  end
end
def.method("=>", "string").GetTitle = function(self)
  return self.m_title
end
def.virtual("string").SetTitle = function(self, title)
  self:SetTitleWithColor(title, nil)
end
def.virtual("string", "userdata").SetTitleWithColor = function(self, title, color)
  if title ~= nil then
    self.m_title = title
  end
  self.m_titleColor = color or GetColorData(701300008)
  self:SetNamePanel()
end
def.virtual("string", "userdata").SetShowTitle = function(self, title, showTitleColor)
  self.m_showTitle = title
  self.showTitleColor = showTitleColor
  self:SetNamePanel()
end
def.method().SetNamePanel = function(self)
  if not _G.IsNil(self.m_uiNameHandle) then
    self:ShowTitleContent()
    local nameLabel = self.m_uiNameHandle:FindDirect("Pate/Lab_Name")
    if self.m_showTitle == "" and self.m_title == "" then
      nameLabel.localPosition = t_vec:Assign(0, 0, -100)
    else
      nameLabel.localPosition = t_vec:Assign(0, -7400, -100)
    end
    local label = nameLabel:GetComponent("UILabel")
    label.text = self.m_Name
    label.color = self.m_uNameColor
    self:SetNameIcon(self.nameIcon)
  end
end
def.method("number").SetNameIcon = function(self, nameIcon)
  self.nameIcon = nameIcon
  if _G.IsNil(self.m_uiNameHandle) then
    return
  end
  local Texture_ShapeIcon = self.m_uiNameHandle:FindDirect("Pate/Lab_Name/Texture_ShapeIcon")
  if self.nameIcon > 0 then
    do
      local bundlePath = GetIconPath(self.nameIcon)
      if bundlePath == nil or bundlePath == "" then
        warn("[SetNamePanel]icon path is nil or empty for id: ", self.nameIcon)
        return
      end
      GameUtil.AsyncLoad(bundlePath, function(tex)
        if tex and not _G.IsNil(self.m_uiNameHandle) then
          local uiTexture = Texture_ShapeIcon:GetComponent("UITexture")
          uiTexture.mainTexture = tex
          Texture_ShapeIcon:SetActive(true)
        else
          warn(bundlePath .. " load fail")
        end
      end)
    end
  else
    Texture_ShapeIcon:SetActive(false)
  end
end
def.method().ShowTitleContent = function(self)
  local title = self.m_showTitle
  local titleColor = self.showTitleColor
  if title == nil or title == "" then
    title = self.m_title
    titleColor = self.m_titleColor
  end
  self.m_uiNameHandle:SetActive(self.m_visible)
  local titlePanel = self.m_uiNameHandle:FindDirect("Pate/Title")
  local label = titlePanel:FindDirect("Lab_Chengwei"):GetComponent("UILabel")
  label.text = title
  label.color = titleColor or GetColorData(701300008)
  titlePanel:FindDirect("Texture_Icon"):GetComponent("UIWidget"):UpdateAnchors()
end
def.virtual("string", "number").Talk = function(self, content, time)
  self:TalkWithCustomeBubble(content, time, _G.DefaultBubbleCfg.sceneResource, _G.DefaultBubbleCfg.arrowResource)
end
def.method().StopTalk = function(self)
  if self.m_talkPop and not self.m_talkPop.isnil then
    self.m_talkPop:SetActive(false)
  end
end
def.method("string", "number", "string", "string").TalkWithCustomeBubble = function(self, content, time, spriteName, arrowName)
  if self.m_model == nil or self.m_model.isnil or self.m_visible == false then
    return
  end
  local function doTalk()
    GameUtil.RemoveGlobalTimer(self.m_talkTimer)
    GameUtil.AddGlobalLateTimer(0, true, function()
      if self.m_talkPop == nil or self.m_talkPop.isnil then
        return
      end
      local imgTxt = self.m_talkPop:FindDirect("Container/Img_BgText")
      self:SetSprite(imgTxt, spriteName)
      local imgArrow = self.m_talkPop:FindDirect("Container/Img_Arrow")
      self:SetSprite(imgArrow, arrowName)
      self.m_talkPop:SetActive(self.m_visible)
      local html = self.m_talkPop:FindDirect("Container/Html_Text"):GetComponent("NGUIHTML")
      if html == nil then
        return
      end
      html:ForceHtmlText(StringToHtml(content))
      local container = self.m_talkPop:FindDirect("Container")
      container:GetComponent("UIWidget"):set_alpha(1)
      if time == 0 then
        time = 5
      end
      local tween = TweenAlpha.Begin(self.m_talkPop:FindDirect("Container"), 1, 0)
      tween:set_delay(time - 1)
      self.m_talkTimer = GameUtil.AddGlobalTimer(time, true, function()
        if self and self.m_talkPop and not self.m_talkPop.isnil then
          self.m_talkPop:SetActive(false)
        end
      end)
    end)
  end
  if self.m_talkPop == nil or _G.IsNil(self.m_talkPop) then
    local ECPate = require("GUI.ECPate")
    local pate = ECPate.new()
    pate:CreateTalkBoard(self, doTalk)
  else
    doTalk()
  end
end
def.method("userdata", "string").SetSprite = function(self, UISprite, spriteName)
  if _G.IsNil(UISprite) then
    warn("[ERROR: param UISprite is nil]")
    return
  end
  local comSprite = UISprite:GetComponent("UISprite")
  if comSprite == nil then
    warn("[ERROR:UISprite component is not exist]")
    return
  end
  _G.GameUtil.AsyncLoad(RESPATH.CHAT_BUBBLE_ATLAS, function(obj)
    if _G.IsNil(obj) or _G.IsNil(comSprite) then
      return
    end
    local atlas = obj:GetComponent("UIAtlas")
    comSprite:set_atlas(atlas)
    comSprite:set_spriteName(spriteName)
  end)
end
def.method().InitShadow = function(self)
  if self.mShadowObj == nil then
    self.mShadowObj = self.m_model:FindDirect("characterShadow")
    if self.mShadowObj then
      local scale = self.mShadowObj.transform.localScale
      self.mShadowScale = EC.Vector3.new(scale.x, scale.y, scale.z)
    end
  end
end
def.method("boolean").ShowShadow = function(self, show)
  self:InitShadow()
  if self.mShadowObj then
    self.mShadowObj:SetActive(show)
  end
end
local temprot = EC.Vector3.new(0, 0, 0)
def.virtual().OnLoadGameObject = function(self)
  if self.m_model == nil then
    return
  end
  if _G.isDebugBuild then
    GameUtil.BeginSamp("OnLoadGameObject ")
  end
  self:InitShadow()
  if self.m_node2d then
    local x, y, z = self.m_node2d:GetPosXYZ()
    Set2DPosTo3D(x, world_height - y, t_vec)
    self.m_model.localPosition = t_vec
  end
  temprot.y = self.m_ang
  self.m_model.localRotation = Quaternion.Euler(temprot)
  self:Play(ActionName.Stand)
  if self.m_color then
    self:SetModelColor(self.m_color)
  else
    self:SetColoration(nil)
  end
  if _G.isDebugBuild then
    GameUtil.EndSamp()
  end
end
def.method("string", "function").AddOnLoadCallback = function(self, funcName, func)
  if func == nil then
    return
  end
  if self.onLoadCallback == nil then
    self.onLoadCallback = {}
  end
  self.onLoadCallback[funcName] = func
end
def.method("string").RemoveOnLoadCallback = function(self, funcName)
  if self.onLoadCallback == nil then
    return
  end
  self.onLoadCallback[funcName] = nil
end
def.method("string", "function").AddOnLoadCallbackQueue = function(self, name, func)
  if func == nil then
    return
  end
  if self.onLoadCallback == nil then
    self.onLoadCallback = {}
  end
  local callbackNum = #self.onLoadCallback
  self.onLoadCallback[callbackNum + 1] = {name = name, func = func}
end
def.method("string").RemoveOnLoadCallbackQueue = function(self, name)
  if self.onLoadCallback == nil then
    return
  end
  local callbackNum = #self.onLoadCallback
  for i = callbackNum, 1, -1 do
    local call = self.onLoadCallback[i]
    if call.name == name then
      table.remove(self.onLoadCallback, i)
    end
  end
end
local t_pos = EC.Vector3.new()
def.method("string", "number", "number", "number", "boolean", "=>", "boolean").LoadModel2 = function(self, path, x, y, ang, inst_immediate)
  self.m_ang = ang
  self:Set2DPos(x, y)
  self:Load2(path, function(ret)
    if ret == nil then
      return
    end
    if _G.isDebugBuild then
      GameUtil.BeginSamp("LoadModel ")
    end
    self:OnLoadGameObject()
    if _G.isDebugBuild then
      GameUtil.EndSamp()
    end
  end, inst_immediate)
  return true
end
def.method("string", "number", "number", "number", "=>", "boolean").LoadModel = function(self, path, x, y, ang)
  return self:LoadModel2(path, x, y, ang, false)
end
def.method("number", "number", "number", "=>", "boolean").LoadCurrentModel = function(self, x, y, ang)
  if self.mModelId <= 0 then
    return false
  end
  local modelpath, modelColor = GetModelPath(self.mModelId)
  if modelpath then
    self.colorId = modelColor
    return self:LoadModel(modelpath, x, y, ang)
  else
    return false
  end
end
def.method("=>", "boolean").LoadCurrentModel2 = function(self)
  if self.mModelId <= 0 then
    return false
  end
  if self.m_model then
    self.m_model:Destroy()
    self.m_model = nil
  end
  local modelpath, modelColor = GetModelPath(self.mModelId)
  if modelpath then
    self.colorId = modelColor
    self:Load2(modelpath, function(ret)
      if ret == nil then
        return
      end
      if _G.isDebugBuild then
        GameUtil.BeginSamp("LoadModel ")
      end
      self:OnLoadGameObject()
      if _G.isDebugBuild then
        GameUtil.EndSamp()
      end
    end, false)
    return true
  else
    return false
  end
end
def.virtual("number", "number").SetPos = function(self, x, y)
  if self.m_node2d == nil then
    return
  end
  local model = self.m_model
  if model and not model.isnil then
    Set2DPosTo3D(x, world_height - y, t_pos)
    model.localPosition = t_pos
  end
  self.m_node2d.localPosition = t_pos:Assign(x, y, 0)
end
def.virtual("number", "number").Set2DPos = function(self, x, y)
  if self.m_node2d and not self.m_node2d.isnil then
    self.m_node2d.localPosition = t_pos:Assign(x, y, 0)
  end
end
def.method("=>", "table").GetPos = function(self)
  if self.m_node2d == nil then
    return nil
  end
  local x, y, z = self.m_node2d:GetPosXYZ()
  return {x = x, y = y}
end
def.virtual("=>", "table").Get3DPos = function(self)
  if self.m_model == nil then
    return nil
  end
  return self.m_model.localPosition
end
def.virtual("table").Set3DPos = function(self, pos)
  if self.m_model == nil or pos == nil then
    return
  end
  self.m_model.localPosition = pos
end
def.virtual("=>", "table").GetForward = function(self)
  if self.m_model == nil or self.m_model.isnil then
    return nil
  end
  return self.m_model.forward
end
def.virtual("table").SetForward = function(self, forward)
  if self.m_model == nil or self.m_model.isnil then
    return
  end
  self.m_model.forward = forward
end
def.virtual("=>", "number").GetDir = function(self)
  if self.m_model == nil or self.m_model.isnil then
    return 0
  end
  return self.m_model.localRotation.eulerAngles.y
end
local tempdir = EC.Vector3.new(0, 0, 0)
def.virtual("number").SetDir = function(self, ang)
  local model = self.m_model
  if model and not model.isnil then
    tempdir.y = ang
    model.localRotation = Quaternion.Euler(tempdir)
  end
  self.m_ang = ang
end
def.virtual("userdata").SetRotation = function(self, rotation)
  if self.m_model == nil or self.m_model.isnil or rotation == nil then
    return
  end
  self.m_model.localRotation = rotation
end
def.virtual("=>", "userdata").GetRotation = function(self)
  if self.m_model == nil or self.m_model.isnil then
    return nil
  end
  return self.m_model.localRotation
end
def.method("number").SetScale = function(self, scale)
  local model = self.m_model
  if model and not model.isnil then
    model.localScale = EC.Vector3.one * scale
  end
end
def.virtual("=>", "number").GetModelLength = function(self)
  if self.m_model == nil or self.m_model.isnil then
    return 0
  end
  local boxCollider = self.m_model:GetComponent("BoxCollider")
  if boxCollider then
    local size = boxCollider:get_size()
    return size.z / 2
  end
  return 0
end
def.virtual("number").Update = function(self, ticks)
  self:UpdateAnim(ticks)
end
def.method("number").UpdateAnim = function(self, ticks)
  if self.m_callWhenAnimFinished == nil then
    return
  end
  self.aniTime = self.aniTime - ticks
  if self.aniTime <= 0 then
    local cb = self.m_callWhenAnimFinished
    self.m_callWhenAnimFinished = nil
    self.curAniName = ""
    cb(self)
  end
end
def.static("boolean").UpdateLoadedResult = function(all)
  local count = #loaded_result_list
  if count == 0 then
    instantiate_count = 0
    return
  end
  if all then
    local cb = loaded_result_list[1]
    while cb do
      table.remove(loaded_result_list, 1)
      cb()
      cb = loaded_result_list[1]
    end
    loaded_result_list = {}
    instantiate_count = 0
  else
    if _G.skip_cur_onload_frame then
      _G.skip_cur_onload_frame = false
      instantiate_count = 0
      return
    end
    local starttime = Time.realtimeSinceStartup
    local cur_count = math.min(instantiate_count_per_frame, count)
    local cb = loaded_result_list[1]
    local called = 0
    while cb do
      table.remove(loaded_result_list, 1)
      called = called + 1
      cb()
      if cur_count > called then
        cb = loaded_result_list[1]
      else
        cb = nil
      end
      if Time.realtimeSinceStartup - starttime > on_load_time_limit and not _G.CGPlay then
        GameUtil.SkipCurrentLoadFrame()
        cur_count = called
        break
      end
    end
    instantiate_count = cur_count
  end
end
def.method("=>", "boolean").IsLoaded = function(self)
  if self.m_model == nil then
    return false
  end
  return true
end
def.method("=>", "boolean").IsObjLoaded = function(self)
  if self:IsLoaded() == false then
    return false
  end
  if self.m_status ~= ModelStatus.NORMAL then
    return false
  end
  return true
end
def.virtual("number").SetLayer = function(self, layer)
  self.defaultLayer = layer
  if self.m_model and not self.m_model.isnil then
    self.m_model:SetLayer(self.defaultLayer)
  end
end
def.method("userdata", "userdata", "function").OnModelLoadResult = function(self, model, asset, cb)
  if _G.isDebugBuild then
    GameUtil.BeginSamp("OnModelLoadResult")
  end
  local m = model
  m.localScale = Model_Default_Scale
  self.m_model = m
  self.m_asset = asset
  self.m_ani = m:GetComponentInChildren("Animation")
  if self.m_ani then
    self.m_ani.enabled = false
    self.m_ani.enabled = true
  end
  self.m_status = ModelStatus.NORMAL
  self.m_renderers = m:GetRenderersInChildren()
  self.original_equip_info = {}
  self:InitOriginalModelInfo()
  self.m_model:SetLayer(self.defaultLayer)
  self.srcShaders = {}
  local rs = self.m_renderers
  local shadowRenderIdx
  for i = 1, #rs do
    local render = rs[i]
    if render.gameObject.name == "characterShadow" then
      shadowRenderIdx = i
    else
      local srcMat = render:get_material()
      self.srcShaders[render.gameObject.name] = srcMat.shader
    end
  end
  if shadowRenderIdx then
    table.remove(self.m_renderers, shadowRenderIdx)
  end
  if self.parentNode == nil then
    self.parentNode = self.defaultParentNode
  end
  self:SetParentNode(self.parentNode)
  if not self.m_IsTouchable then
    local box = self.m_model:GetComponent("BoxCollider")
    if box then
      box.enabled = false
    end
  else
    GameUtil.AddECObjectComponent(self, self.m_model, false)
  end
  if _G.isDebugBuild then
    GameUtil.EndSamp()
  end
  self:SetVisible(self.m_visible)
  if not self.showModel then
    self:SetShowModel(self.showModel)
  end
  if cb then
    if _G.isDebugBuild then
      GameUtil.BeginSamp("cb " .. FormatFunctionInfo(cb))
      cb(self)
      GameUtil.EndSamp()
    else
      cb(self)
    end
  end
  self:DoOnLoadCallback()
end
def.method().DoOnLoadCallback = function(self)
  if self.onLoadCallback then
    local callbackNum = #self.onLoadCallback
    for i = 1, callbackNum do
      local func = self.onLoadCallback[i].func
      self.onLoadCallback[i] = nil
      if func then
        SafeCall(func)
      end
    end
    for k, v in pairs(self.onLoadCallback) do
      self.onLoadCallback[k] = nil
      SafeCall(v)
      if self.onLoadCallback == nil then
        return
      end
    end
  end
end
def.virtual("boolean").SetTouchable = function(self, v)
  self.m_IsTouchable = v
  if self.m_model == nil then
    return
  end
  local box = self.m_model:GetComponent("BoxCollider")
  if box then
    box.enabled = v
  end
  local comp = self.m_model:GetComponent("ECObjectComponent")
  if comp == nil and v == true then
    GameUtil.AddECObjectComponent(self, self.m_model, false)
  end
end
def.virtual("=>", "boolean").IsTouchable = function(self)
  return self.m_IsTouchable
end
def.method("string", "function").Load = function(self, resname, cb)
  self:Load2(resname, cb, false)
end
def.method("string", "function", "boolean").Load2 = function(self, resname, cb, inst_immediate)
  local UniqueId = get_unique_id()
  self._UniqueId = UniqueId
  local function loaded(obj)
    if UniqueId and UniqueId ~= self._UniqueId then
      ecmodel_loaded_info_map[UniqueId] = nil
      _G.ecmodel_loaded_count = _G.ecmodel_loaded_count - 1
      if cb then
        cb(nil)
      end
      return
    end
    if not obj or self.m_status == ModelStatus.DESTROY then
      self:RemoveLoadedInfo()
      if cb then
        cb(nil)
      end
      return
    end
    local function on_instantiate()
      if UniqueId and UniqueId ~= self._UniqueId then
        ecmodel_loaded_info_map[UniqueId] = nil
        _G.ecmodel_loaded_count = _G.ecmodel_loaded_count - 1
        if cb then
          cb(nil)
        end
        return
      end
      if self.m_status == ModelStatus.DESTROY then
        self:RemoveLoadedInfo()
        if cb then
          cb(nil)
        end
        return
      end
      self.m_resName = resname
      local m = Object.Instantiate(obj, "GameObject")
      self:OnModelLoadResult(m, obj, cb)
    end
    if inst_immediate then
      on_instantiate()
    else
      loaded_result_list[#loaded_result_list + 1] = on_instantiate
    end
  end
  if _G.isDebugBuild then
    ecmodel_loaded_info_map[UniqueId] = debug.traceback()
  else
    ecmodel_loaded_info_map[UniqueId] = resname
  end
  _G.ecmodel_loaded_count = _G.ecmodel_loaded_count + 1
  if aniInfos[resname] == nil then
    aniInfos[resname] = {}
  end
  local m, asset = GameUtil.FindResCache(resname)
  if m then
    local function on_load()
      if UniqueId and UniqueId ~= self._UniqueId then
        GameUtil.AddResCache(resname, m, asset)
        ecmodel_loaded_info_map[UniqueId] = nil
        _G.ecmodel_loaded_count = _G.ecmodel_loaded_count - 1
        if cb then
          cb(nil)
        end
        return
      end
      if self.m_status == ModelStatus.DESTROY then
        GameUtil.AddResCache(resname, m, asset)
        if cb then
          cb(nil)
        end
        return
      end
      m.localPosition = t_vec:Assign(asset:GetPosXYZ())
      m.localScale = Model_Default_Scale
      m.localRotation = asset.localRotation
      self.m_resName = resname
      self:OnModelLoadResult(m, asset, cb)
    end
    self.m_status = ModelStatus.LOADING
    loaded_result_list[#loaded_result_list + 1] = on_load
  else
    self.m_status = ModelStatus.LOADING
    GameUtil.AsyncLoad(resname, loaded, true, inst_immediate, false)
  end
end
def.method("table", "string").SetEquipLightEffect = function(self, bones, effpath)
  if bones == nil or effpath == "" then
    return
  end
  local function loaded(obj)
    if obj == nil then
      return
    end
    if self:IsDestroyed() then
      return
    end
    for _, v in pairs(bones) do
      local boneObj = self.m_model:FindDirect(v)
      if boneObj then
        local fx = ECFxMan.Instance():PlayAsChild(effpath, boneObj, EC.Vector3.zero, Quaternion.identity, -1, false, self.defaultLayer)
        if fx then
          fx:GetComponent("FxOne"):set_Stable(true)
          if self.Equip_Effects == nil then
            self.Equip_Effects = {}
          end
          self.Equip_Effects[v] = fx
        end
      end
    end
  end
  GameUtil.AsyncLoad(effpath, loaded)
end
def.method("table").RemoveEquipLightEffect = function(self, bones)
  if self.Equip_Effects == nil or bones == nil then
    return
  end
  for _, v in pairs(bones) do
    local fx = self.Equip_Effects[v]
    if fx and not fx.isnil then
      ECFxMan.Instance():Stop(fx)
    end
    self.Equip_Effects[v] = nil
  end
end
def.method("table", "boolean").ScaleEquipLightEffect = function(self, bones, isLarge)
  if self.Equip_Effects == nil or bones == nil then
    return
  end
  for _, v in pairs(bones) do
    local fx = self.Equip_Effects[v]
    if fx and not fx.isnil and fx.childCount > 0 then
      local effobj = fx:GetChild(0)
      if effobj then
        local largeObj = effobj:FindDirect("FX1.5")
        if largeObj then
          largeObj:SetActive(isLarge)
        end
        local smallObj = effobj:FindDirect("FX1.0")
        if smallObj then
          smallObj:SetActive(not isLarge)
        end
        if isLarge and largeObj and smallObj then
          for i = 1, largeObj.childCount do
            local child = largeObj:GetChild(i - 1)
            if i <= smallObj.childCount then
              child.localPosition = smallObj:GetChild(i - 1).localPosition
            end
          end
        end
      end
    end
  end
end
local _equip_load_serial_id = 0
def.method("string", "string", "boolean", "function").ChangeEquip = function(self, equip_obj_name, cfg_path, saveOriginal, callback)
  local path = GetEquipResPath(cfg_path)
  if path == nil or path == "" then
    warn("ChangeEquip, wrong cfg path: " .. cfg_path)
    return
  end
  _equip_load_serial_id = _equip_load_serial_id + 1
  local load_id = _equip_load_serial_id
  local respath = path.File
  local rescount = #respath
  if rescount > 1 then
    local function loaded(resarr)
      local model = self.m_model
      if self:IsDestroyed() or model == nil then
        self.EquipStatus = nil
        return
      end
      local es = self.EquipStatus
      if not es or not es[equip_obj_name] or es[equip_obj_name].loadId ~= load_id then
        return
      end
      local equip_obj = model:FindDirect(equip_obj_name)
      if not equip_obj then
        es[equip_obj_name] = nil
        return
      end
      local skinrenderold = equip_obj:GetComponent("SkinnedMeshRenderer")
      local srcMat = skinrenderold.material
      local equip_data = self.original_equip_info[equip_obj_name]
      if equip_data == nil then
        equip_data = {}
        equip_data.original_sharedMaterials = skinrenderold.sharedMaterials
        equip_data.original_sharedMesh = skinrenderold.sharedMesh
        equip_data.original_bones = skinrenderold.bones
        self.original_equip_info[equip_obj_name] = equip_data
      end
      local attachTbl = self:TempDetach()
      set_skinrender_bones(skinrenderold, self.m_model, path.Bones)
      self:RecoverTempDetach(attachTbl)
      local mats = {}
      for i = 2, rescount do
        mats[i - 1] = resarr[i]
        if srcMat and mats[i - 1] then
          mats[i - 1].shader = srcMat.shader
        end
      end
      skinrenderold.sharedMaterials = mats
      skinrenderold.sharedMesh = resarr[1]
      skinrenderold.enabled = true
      self:SetRenderEnable(self.showModel)
      if model.activeSelf then
        model:SetActive(false)
        model:SetActive(true)
        self:ResetAction()
      end
      skinrenderold:unbind()
      if callback then
        callback()
      end
    end
    local es = self.EquipStatus
    if not es then
      es = {}
      self.EquipStatus = es
    end
    es[equip_obj_name] = {loadId = load_id, saveOriginal = saveOriginal}
    AsyncLoadArray(respath, loaded)
  end
end
local _empty_list = {}
def.method("string", "boolean")._RemoveEquipInner = function(self, equip_obj_name, recoverOriginal)
  local equip_obj = self.m_model:FindDirect(equip_obj_name)
  if not equip_obj then
    return
  end
  local skinrenderold = equip_obj:GetComponent("SkinnedMeshRenderer")
  if recoverOriginal then
    local equip_data = self.original_equip_info[equip_obj_name]
    if equip_data then
      local shader = skinrenderold.material.shader
      skinrenderold.bones = equip_data.original_bones
      skinrenderold.materials = equip_data.original_sharedMaterials
      skinrenderold.sharedMesh = equip_data.original_sharedMesh
      skinrenderold.enabled = true
      skinrenderold.material.shader = shader
      local model = self.m_model
      if model.activeSelf then
        model:SetActive(false)
        model:SetActive(true)
        local curName = self.curAniName
        if curName and curName ~= "" then
          self:Play(curName)
        end
      end
    end
  else
    skinrenderold.bones = _empty_list
    skinrenderold.material = skinrenderold.sharedMaterial
    skinrenderold.sharedMesh = nil
    skinrenderold.enabled = false
    skinrenderold:unbind()
  end
end
def.method("string").RemoveEquip = function(self, equip_obj_name)
  local es = self.EquipStatus
  if not es or not es[equip_obj_name] then
    return
  end
  local model = self.m_model
  if self:IsDestroyed() or model == nil then
    self.EquipStatus = nil
    return
  end
  self:_RemoveEquipInner(equip_obj_name, es[equip_obj_name].saveOriginal)
  es[equip_obj_name] = nil
end
def.method()._RemoveAllEquips = function(self)
  local es = self.EquipStatus
  if es == nil then
    return
  end
  for k, v in pairs(es) do
    self:_RemoveEquipInner(k, v.saveOriginal)
  end
  self.EquipStatus = nil
  self.costumeInfo = nil
end
def.virtual().ResetAction = function(self)
  local curName = self.curAniName
  if curName and curName ~= "" then
    self:Play(curName)
  end
end
local S_LOADING = ModelStatus.LOADING
def.method("=>", "boolean").IsInLoading = function(self)
  return self.m_status == S_LOADING
end
local S_DESTROY = ModelStatus.DESTROY
def.method("=>", "boolean").IsDestroyed = function(self)
  return self.m_status == S_DESTROY
end
def.method("userdata", "string", "boolean").CloneFrom = function(self, src, resname, fromcache)
  local m
  if fromcache then
    m = GameUtil.FindResCache(resname)
    if m then
      m:SetActive(true)
      m.localPosition = src.localPosition
      m.localScale = src.localScale
      m.localRotation = src.localRotation
    else
      m = Object.Instantiate(src, "GameObject")
    end
  else
    m = Object.Instantiate(src, "GameObject")
  end
  self.m_model = m
  self.m_asset = GameUtil.CloneUserData(src)
  self.m_ani = m:GetComponentInChildren("Animation")
  self.m_status = ModelStatus.NORMAL
  self.m_resName = resname
  self.m_renderers = m:GetRenderersInChildren()
  self.m_visible = true
  if aniInfos[resname] == nil then
    aniInfos[resname] = {}
  end
end
def.method("=>", ECModel).Duplicate = function(self)
  if self.m_asset == nil or self.m_asset.isnil then
    return
  end
  local ret = ECModel.new(self.mModelId)
  local m = Object.Instantiate(self.m_asset, "GameObject")
  ret.m_model = m
  ret.m_asset = GameUtil.CloneUserData(self.m_asset)
  ret.m_ani = m:GetComponentInChildren("Animation")
  ret.m_status = ModelStatus.NORMAL
  ret.m_resName = self.m_resName
  ret.m_renderers = m:GetRenderersInChildren()
  ret.m_visible = true
  ret.showModel = true
  ret.m_ang = self.m_ang
  ret.m_model.localScale = m.localScale
  ret.m_Name = self.m_Name
  ret.m_title = self.m_title
  ret.m_showTitle = self.m_showTitle
  ret:InitOriginalModelInfo()
  ret.m_model:SetLayer(self.defaultLayer)
  ret.srcShaders = {}
  local rs = ret.m_renderers
  local shadowRenderIdx
  for i = 1, #rs do
    local render = rs[i]
    if render.gameObject.name == "characterShadow" then
      shadowRenderIdx = i
    else
      local srcMat = render:get_material()
      ret.srcShaders[render.gameObject.name] = srcMat.shader
    end
  end
  if shadowRenderIdx then
    table.remove(ret.m_renderers, shadowRenderIdx)
  end
  ret.parentNode = self.parentNode
  ret.defaultParentNode = self.defaultParentNode
  if self.m_node2d then
    ret.m_node2d = GameObject.GameObject("node2d_" .. tostring(self.mModelId))
  end
  if ret.parentNode then
    local tran = ret.parentNode.transform
    ret.m_model.transform.parent = tran
    if ret.m_node2d ~= nil then
      ret.m_node2d.transform.parent = tran
    end
  end
  if ret.m_node2d ~= nil then
    if not ret.m_IsTouchable then
      local box = ret.m_model:GetComponent("BoxCollider")
      if box then
        box.enabled = false
      end
    else
      GameUtil.AddECObjectComponent(ret, ret.m_model, false)
    end
  end
  return ret
end
def.method("boolean").ShowName = function(self, v)
  if self.m_uiNameHandle then
    self.m_uiNameHandle:SetActive(v)
    self.m_uiNameHandle:GetComponent("HUDFollowTarget"):SetVisible(v)
  end
end
def.virtual("boolean").SetVisible = function(self, visible)
  self.m_visible = visible
  if self.m_model == nil or self.m_model.isnil then
    return
  end
  self:ShowName(visible)
  self:SetActive(self.m_visible)
  for k, v in pairs(self.m_attachments) do
    if v[1] then
      v[1]:SetVisible(self.m_visible)
    end
  end
  if visible and self.m_ani then
    self.m_ani.enabled = false
    self.m_ani.enabled = true
  end
end
def.virtual("boolean").SetShowModel = function(self, val)
  self.showModel = val
  if self.m_model == nil or self.m_model.isnil then
    return
  end
  for _, att in pairs(self.m_attachments) do
    if att[1] then
      att[1]:SetActive(val)
    end
  end
  self:SetRenderEnable(val)
end
def.method("boolean").SetActive = function(self, active)
  local m = self.m_model
  if m and not m.isnil then
    m:SetActive(active)
  end
end
def.method("boolean").SetCanClick = function(self, visible)
  if self.m_model then
    local collider = self.m_model:GetComponent("BoxCollider")
    if collider then
      collider.enabled = visible
    end
  end
end
def.method("boolean").SetShowShadow = function(self, v)
  if self.m_model and not self.m_model.isnil then
    local shadow = self.m_model:FindDirect("characterShadow")
    if shadow then
      shadow:SetActive(v)
    end
  end
end
def.method("boolean").SetModelIsRender = function(self, isRender)
  if self.m_model and not self.m_model.isnil then
    local rs = self.m_renderers
    if not rs then
      return
    end
    for k, v in ipairs(rs) do
      if not v.isnil then
        v:set_enabled(isRender)
      end
    end
    local weapon = self.m_model:FindDirect("Weapon")
    if weapon then
      weapon:SetActive(isRender)
    end
  end
end
def.method("boolean").SetBoneIsRender = function(self, isRender)
  if self.m_model and not self.m_model.isnil then
    local root = self.m_model:FindDirect("Root")
    if root then
      root:SetActive(isRender)
    end
  end
end
def.method("number").SetRenderLayer = function(self, layer)
  local rs = self.m_renderers
  if not rs then
    return
  end
  for i = 1, #rs do
    rs[i].gameObject.layer = layer
  end
end
def.method("number", "number").SetRenderLayer2 = function(self, layer1, layer2)
  local m = self.m_model
  if not m then
    return
  end
  local rs = self.m_renderers
  for i = 1, #rs do
    local render = rs[i]
    local obj = render.gameObject
    if getmetatable(render).name == "SkinnedMeshRenderer" then
      obj.layer = layer1
    elseif Object.IsEq(m, obj) then
      obj.layer = layer1
    else
      obj.layer = layer2
    end
  end
end
def.method("boolean").SetRenderEnable = function(self, v)
  self:SetModelIsRender(v)
  self:SetBoneIsRender(v)
  self:SetShowShadow(v)
  if v and self.m_model and not self.m_model.isnil then
    local ani = self.m_model:GetComponent("Animation")
    if ani then
      ani.enabled = false
      ani.enabled = true
    end
  end
end
def.method("string", "=>", "boolean").HasBone = function(self, bone)
  if self.m_model == nil or self.m_model.isnil or bone == "" then
    return false
  end
  return self.m_model:FindChild(bone) ~= nil
end
def.method("string", "string", "table", "table", "=>", "boolean").CreateBone = function(self, boneName, parentName, offset, angle)
  if self.m_model == nil or self.m_model.isnil then
    return false
  end
  local parentObj
  if parentName == "" then
    parentObj = self.m_model
  else
    parentObj = self.m_model:FindChild(parentName)
  end
  if parentName == nil then
    return false
  end
  local obj = GameObject.GameObject(boneName)
  obj.parent = parentObj
  obj.localPosition = offset
  obj.localScale = EC.Vector3.one
  obj.localRotation = Quaternion.Euler(angle)
  return true
end
def.method("string", ECModel, "=>", "boolean").AttachModelToSelf = function(self, hp, ecModel)
  if not self.m_model or self.m_status ~= ModelStatus.NORMAL then
    warn("[ECModel AttachModel]target model is nil")
    return false
  end
  local obj = self:Detach(hp)
  if obj then
    obj:Destroy()
  end
  self:_realAttachModel(hp, ecModel, self.m_model, EC.Vector3.zero, EC.Vector3.zero)
  return true
end
def.method("string", ECModel, "string", "=>", "boolean").AttachModel = function(self, hp, ecModel, bone)
  if not self.m_model or self.m_status ~= ModelStatus.NORMAL then
    warn("[ECModel AttachModel]target model is nil")
    return false
  end
  local boneObj
  if bone and bone ~= "" then
    local attachTbl = self:TempDetach()
    boneObj = self.m_model:FindChild(bone)
    self:RecoverTempDetach(attachTbl)
  end
  if boneObj == nil then
    warn("[ECModel AttachModel]boneObj is nil : ", bone, ", path: ", self.m_resName)
    return false
  end
  local obj = self:Detach(hp)
  if obj and obj ~= ecModel then
    obj:Destroy()
  end
  self:_realAttachModel(hp, ecModel, boneObj, EC.Vector3.zero, EC.Vector3.zero)
  return true
end
def.method("string", "string", "string").ChangeAttach = function(self, srchp, dsthp, dstbone)
  return self:ChangeAttachEx(srchp, dsthp, dstbone, EC.Vector3.zero, EC.Vector3.zero)
end
def.method("string", "string", "string", "table", "table").ChangeAttachEx = function(self, srchp, dsthp, dstbone, lpos, angles)
  if not self.m_model or self.m_status ~= ModelStatus.NORMAL then
    warn("please load model firstly")
    return
  end
  local ecModel = self:GetAttach(srchp)
  self:Detach(srchp)
  self:AttachModelEx(dsthp, ecModel, dstbone, lpos, angles)
end
def.method("string", ECModel, "string", "table", "table").AttachModelEx = function(self, hp, ecModel, bone, lpos, angles)
  if not self.m_model or self.m_status ~= ModelStatus.NORMAL then
    warn("please load model firstly")
    return
  end
  local attachTbl = self:TempDetach()
  local boneObj = self.m_model:FindChild(bone)
  self:RecoverTempDetach(attachTbl)
  self:Detach(hp)
  self:_realAttachModel(hp, ecModel, boneObj, lpos, angles)
end
def.method("string", ECModel, "userdata", "table", "table")._realAttachModel = function(self, hp, ecModel, boneObj, lpos, angles)
  local m = ecModel.m_model
  if m == nil or m.isnil then
    return
  end
  self.m_attachments[hp] = {ecModel, boneObj}
  m.parent = boneObj
  ecModel.parentNode = boneObj
  m.localPosition = lpos
  if angles then
    m.localRotation = Quaternion.Euler(angles)
  end
  m.localScale = t_vec:Assign(self.m_asset:GetScaleXYZ())
end
def.method("string", "=>", "table").Detach = function(self, hp)
  local info = self.m_attachments[hp]
  if info then
    self.m_attachments[hp] = nil
    if info[1] and info[1].m_model and not info[1].m_model.isnil then
      info[1].m_model.parent = nil
      info[1].parentNode = nil
      return info[1]
    end
  end
  return nil
end
def.method("=>", "table").TempDetach = function(self)
  local detachTbl = {}
  for k, v in pairs(self.m_attachments) do
    local attchInfo = {}
    attchInfo.ecModel = v[1]
    attchInfo.boneObj = v[2]
    if attchInfo.ecModel.m_model and not attchInfo.ecModel.m_model.isnil then
      attchInfo.localPosition = attchInfo.ecModel.m_model.localPosition
      attchInfo.localRotation = attchInfo.ecModel.m_model.localRotation
      attchInfo.localScale = attchInfo.ecModel.m_model.localScale
      attchInfo.ecModel.m_model.parent = nil
    else
      attchInfo.localPosition = EC.Vector3.zero
      attchInfo.localRotation = EC.Vector3.one
      attchInfo.localScale = Quaternion.Euler(EC.Vector3.zero)
    end
    table.insert(detachTbl, attchInfo)
  end
  return detachTbl
end
def.method("table").RecoverTempDetach = function(self, attachTbl)
  for k, v in ipairs(attachTbl) do
    if v.ecModel.m_model and not v.ecModel.m_model.isnil then
      v.ecModel.m_model.parent = v.boneObj
      v.ecModel.m_model.localPosition = v.localPosition
      v.ecModel.m_model.localRotation = v.localRotation
      v.ecModel.m_model.localScale = v.localScale
    end
  end
end
def.method("string").DestroyChild = function(self, hp)
  local ecmodel = self:Detach(hp)
  if ecmodel then
    ecmodel:Destroy()
  end
end
def.method("string", "boolean").ActiveChild = function(self, name, active)
  local info = self.m_attachments[name]
  if info then
    info[1].m_model:SetActive(active)
  end
end
def.method("number").SetAnimCullingType = function(self, cullingType)
  if self.m_ani then
    self.m_ani:set_cullingType(cullingType)
  else
    warn("Set Culling Type Fail:", self.mModelId)
  end
end
def.static("string", "=>", "string").GetAnimExpLua = function(resname)
  if resname == "" then
    return ""
  end
  local len = string.len(resname)
  local find = 0
  for i = len, 1, -1 do
    local char = string.sub(resname, i, i)
    if char == "/" then
      find = i
      break
    end
  end
  if find > 0 then
    local ret = string.sub(resname, 1, find) .. "AnimExp.prefab.lua"
    return ret
  else
    return ""
  end
end
def.method("string", "string").PlayWithDefault = function(self, aniname, default)
  if not self:Play(aniname) then
    self:Play(default)
  end
end
def.virtual("string", "=>", "boolean").Play = function(self, aniname)
  local ani = self.m_ani
  if not ani then
    return false
  end
  if ani:get_isnil() then
    return false
  end
  local aniTime, aniPath = self:GetAniDuration(aniname)
  if aniTime > 0 then
    self.aniTime = aniTime
    self.curAniName = aniname
    if aniPath == "" then
      ani:Play_3(aniname, PlayMode.StopSameLayer)
    else
      local suc = self:LoadSepAnim(aniPath, aniname)
      if suc then
        ani:Play_3(aniname, PlayMode.StopSameLayer)
      end
    end
    return true
  else
    warn("animation not found for model: ", self.m_model.name, aniname)
    return false
  end
end
def.method("string", "number", "=>", "boolean").PlayAnimAtTime = function(self, aniname, normalizedTime)
  local ani = self.m_ani
  if not ani then
    return false
  end
  if ani:get_isnil() then
    return false
  end
  local aniTime, aniPath = self:GetAniDuration(aniname)
  if aniTime > 0 then
    self.aniTime = aniTime
    self.curAniName = aniname
    if aniPath == "" then
      local state = self.m_ani:State(aniname)
      if state then
        state.normalizedTime = normalizedTime
      end
      ani:Play_3(aniname, PlayMode.StopSameLayer)
    else
      local suc = self:LoadSepAnim(aniPath, aniname)
      if suc then
        local state = self.m_ani:State(aniname)
        if state then
          state.normalizedTime = normalizedTime
        end
        ani:Play_3(aniname, PlayMode.StopSameLayer)
      else
        return false
      end
    end
    return true
  else
    warn("animation not found for model: ", self.m_model.name, aniname)
    return false
  end
end
def.method("string", "=>", "boolean").IsPlaying = function(self, aniname)
  local ani = self.m_ani
  if ani == nil or ani:get_isnil() then
    return false
  end
  return ani:IsPlaying(aniname)
end
def.method().StopCurrentAnim = function(self)
  if self.curAniName == nil or self.curAniName == "" then
    return
  end
  self:StopAnim(self.curAniName)
end
def.method("string").StopAnim = function(self, aniname)
  local ani = self.m_ani
  if not ani then
    return false
  end
  if ani:get_isnil() then
    return
  end
  ani:Stop_2(aniname)
end
def.method().StopAnimAndCallback = function(self)
  if self.m_ani then
    if self.m_ani:get_isnil() then
      return
    end
    self.m_ani:Stop()
  end
  self.aniTime = 0
  self.m_callWhenAnimFinished = nil
end
def.method().CleanAnimCallback = function(self)
  self.aniTime = 0
  self.m_callWhenAnimFinished = nil
end
def.method("string", "=>", "boolean").HasAnimClip = function(self, aniname)
  if _G.IsNil(self.m_model) then
    return false
  end
  local ani = self.m_model:GetComponentInChildren("Animation")
  if _G.IsNil(ani) then
    return false
  end
  if ani:GetClip(aniname) ~= nil then
    return true
  else
    local expAnimTime, expAnimPath = self:GetSepAnimInfo(aniname)
    return expAnimTime > 0
  end
end
def.method("string", "=>", "number", "string").GetAniDuration = function(self, aniname)
  if self.m_resName == "" then
    return -1, ""
  end
  local duration = aniInfos[self.m_resName][aniname]
  local path = ""
  if not duration then
    if self.m_ani then
      local sep = aniInfos[self.m_resName].sep
      if sep and sep[aniname] then
        duration = sep[aniname].Length
        path = sep[aniname].Path
      else
        local state = self.m_ani:State(aniname)
        if state then
          duration = state.length
          aniInfos[self.m_resName][aniname] = duration > 0 and duration or nil
        elseif sep == nil then
          duration, path = self:GetSepAnimInfo(aniname)
        else
          duration = -1
        end
      end
    else
      duration = -1
      warn(self.m_Name, "'s animation is nil : ", aniname)
    end
  end
  return duration, path
end
def.method("boolean").PauseAnim = function(self, p)
  if self.curAniName == nil or self.curAniName == "" then
    return
  end
  local rec = self.m_ani:State(self.curAniName)
  if not rec then
    return
  end
  rec.speed = p and 0 or 1
end
def.method("string", "function", "=>", "boolean").PlayAnim = function(self, aniname, cb)
  if self:Play(aniname) then
    self.m_callWhenAnimFinished = cb
    return true
  end
  return false
end
def.method("userdata", "string").CheckRemoveSepClip = function(self, ani, aniname)
  local info = self.m_sepClipInfo
  if info and info.aniname ~= aniname then
    ani:RemoveClip(info.clip)
    self.m_sepClipInfo = nil
  end
end
def.method("string", "=>", "number", "string").GetSepAnimInfo = function(self, aniname)
  if self.m_resName == "" then
    return -1, ""
  end
  local sep = aniInfos[self.m_resName].sep
  if sep then
    local sepAnim = sep[aniname]
    if sepAnim then
      return sepAnim.Length, sepAnim.Path
    else
      return -1, ""
    end
  elseif sep == nil then
    local animExpPath = ECModel.GetAnimExpLua(self.m_resName)
    if animExpPath ~= "" then
      local sepFile = loadfile(animExpPath)
      if sepFile then
        local sepInfo = sepFile()
        aniInfos[self.m_resName].sep = sepInfo
        local sepAnim = sepInfo[aniname]
        if sepAnim then
          return sepAnim.Length, sepAnim.Path
        else
          return -1, ""
        end
      else
        aniInfos[self.m_resName].sep = false
        return -1, ""
      end
    else
      aniInfos[self.m_resName].sep = false
      return -1, ""
    end
  else
    return -1, ""
  end
end
def.method("string", "string", "=>", "boolean").LoadSepAnim = function(self, resname, aniname)
  local ani = self.m_ani
  if not ani or ani:get_isnil() then
    return false
  end
  if ani:GetClip(aniname) ~= nil then
    return true
  else
    local clip = GameUtil.SyncLoad(resname)
    if clip then
      ani:AddClip(clip, aniname)
      return true
    else
      return false
    end
  end
end
def.method().UnloadSepAnim = function(self)
  local ani = self.m_ani
  if not ani then
    return
  end
  if ani:get_isnil() then
    return
  end
  if self.m_resName == "" then
    return
  end
  local sep = aniInfos[self.m_resName].sep
  if sep then
    for k, v in pairs(sep) do
      local clip = ani:GetClip(k)
      if clip then
        ani:RemoveClip(clip)
      end
    end
  end
end
def.method("string").PlayQueued = function(self, aniname)
  local ani = self.m_ani
  if not ani then
    return
  end
  if ani:get_isnil() then
    return
  end
  local aniTime, aniPath = self:GetAniDuration(aniname)
  if aniTime > 0 then
    self.aniTime = aniTime
    self.curAniName = aniname
    if aniPath == "" then
      ani:PlayQueued(aniname, QueueMode.CompleteOthers, PlayMode.StopSameLayer)
    else
      local suc = self:LoadSepAnim(aniPath, aniname)
      if suc then
        ani:PlayQueued(aniname, QueueMode.CompleteOthers, PlayMode.StopSameLayer)
      end
    end
  end
end
def.virtual("string", "number").CrossFade = function(self, aniname, fade)
  local ani = self.m_ani
  if not ani then
    return
  end
  if ani:get_isnil() then
    return
  end
  local aniTime, aniPath = self:GetAniDuration(aniname)
  if aniTime > 0 then
    self.aniTime = aniTime
    self.curAniName = aniname
    if aniPath == "" then
      if fade == 0 then
        ani:Play_3(aniname, PlayMode.StopSameLayer)
      else
        ani:CrossFade(aniname, fade, PlayMode.StopSameLayer)
      end
    else
      local suc = self:LoadSepAnim(aniPath, aniname)
      if suc then
        if fade == 0 then
          ani:Play_3(aniname, PlayMode.StopSameLayer)
        else
          ani:CrossFade(aniname, fade, PlayMode.StopSameLayer)
        end
      end
    end
  end
end
def.method("string", "number").CrossFadeQueued = function(self, aniname, fadelength)
  local ani = self.m_ani
  if not ani then
    return
  end
  if ani:get_isnil() then
    return
  end
  local aniTime, aniPath = self:GetAniDuration(aniname)
  if aniTime > 0 then
    self.aniTime = aniTime
    self.curAniName = aniname
    if aniPath == "" then
      ani:CrossFadeQueued(aniname, fadelength, QueueMode.CompleteOthers, PlayMode.StopSameLayer)
    else
      local suc = self:LoadSepAnim(aniPath, aniname)
      if suc then
        ani:CrossFadeQueued(aniname, fadelength, QueueMode.CompleteOthers, PlayMode.StopSameLayer)
      end
    end
  end
end
def.method("string").Rewind = function(self, aniname)
  local ani = self.m_ani
  if not ani then
    return
  end
  if ani:get_isnil() then
    return
  end
  local aniTime, aniPath = self:GetAniDuration(aniname)
  if aniTime > 0 then
    self.aniTime = aniTime
    self.curAniName = aniname
    if aniPath == "" then
      ani:Rewind(aniname)
    else
      local suc = self:LoadSepAnim(aniPath, aniname)
      if suc then
        ani:Rewind(aniname)
      end
    end
  end
end
def.method().RemoveLoadedInfo = function(self)
  local UniqueId = self._UniqueId
  if UniqueId ~= nil then
    ecmodel_loaded_info_map[UniqueId] = nil
    _G.ecmodel_loaded_count = _G.ecmodel_loaded_count - 1
    self._UniqueId = nil
  end
end
def.virtual().Destroy = function(self)
  if self:IsDestroyed() then
    return
  end
  self.onLoadCallback = nil
  self:RemoveLoadedInfo()
  self:SetModelIsRender(true)
  self:SetBoneIsRender(true)
  self:SetBrightness(1)
  self:ResetShaders()
  local hps = {}
  for k, v in pairs(self.m_attachments) do
    table.insert(hps, k)
  end
  for _, hp in pairs(hps) do
    self:DestroyChild(hp)
  end
  self.m_status = ModelStatus.DESTROY
  self:UnloadSepAnim()
  if self.m_model and not self.m_model.isnil then
    if not self.showModel then
      self:SetShowModel(true)
    end
    self.m_model:SetActive(true)
    self:_RemoveAllEquips()
    self.original_equip_info = nil
    self.costumeInfo = nil
    if self.m_bUncache then
      Object.Destroy(self.m_model)
    else
      self:RestoreModelOriginalInfo()
      self:ClearModelOriginalInfoCatch()
      GameUtil.AddResCache(self.m_resName, self.m_model, self.m_asset)
      local component = self.m_model:GetComponent("ECObjectComponent")
      if component then
        Object.Destroy(component)
      end
    end
    self.m_renderers = nil
    self.m_model = nil
    self.m_resName = ""
    GameUtil.UnbindUserData(self.m_asset)
    self.m_asset = nil
  end
  if self.m_node2d then
    Object.Destroy(self.m_node2d)
    self.m_node2d = nil
  end
  self.m_originalColors = nil
  self.colorId = 0
  self.m_color = nil
  self.m_ani = nil
  self.mShadowObj = nil
  local ECPate = require("GUI.ECPate")
  if self.m_uiNameHandle then
    if self.m_uiNameHandle.layer ~= ClientDef_Layer.PateText then
      self:SetNameNoDepth()
    end
    if self.m_uiNameHandleCacheRoot then
      ECPate.AddToCache(self.m_uiNameHandle, self.m_uiNameHandleCacheRoot)
      self.m_uiNameHandleCacheRoot = nil
    else
      self.m_uiNameHandle:Destroy()
    end
    self.m_uiNameHandle = nil
  end
  if self.m_uiDialogHandle then
    self.m_uiDialogHandle:Destroy()
    self.m_uiDialogHandle = nil
  end
  if self.m_talkPop then
    self.m_talkPop.parent:Destroy()
    self.m_talkPop = nil
  end
end
def.method().ResumeOrgPosition = function(self)
  local model = self.m_model
  local asset = self.m_asset
  if model == nil or model.isnil then
    return
  end
  model.localScale = asset.localScale
  model.localPosition = asset.localPosition
  model.localRotation = asset.localRotation
end
def.method("string", "=>", ECModel).GetAttach = function(self, hp)
  local attachment = self.m_attachments[hp]
  if attachment then
    return attachment[1]
  end
  return nil
end
def.method("string", "=>", "userdata").GetRender = function(self, name)
  local rs = self.m_renderers
  for i = 1, #rs do
    local render = rs[i]
    if render.gameObject.name:find(name) then
      return render
    end
  end
  return nil
end
def.virtual("userdata").SetColor = function(self, col)
  local render = self:GetRender(ECModel.Name.Equip)
  if render == nil then
    return
  end
  local mat = render:get_material()
  if mat == nil then
    return
  end
  mat:SetColor("_Tint", col)
end
def.virtual("string", "string", "=>", "userdata").AttachEffectToBone = function(self, effectResPath, bone)
  if self.m_model == nil or self.m_model.isnil then
    return nil
  end
  local resname = effectResPath
  local position = EC.Vector3.zero
  local duration = -1
  local parent = self.m_model:FindChild(bone)
  local highres = false
  return ECFxMan.Instance():PlayAsChild(resname, parent, position, rotation, duration, highres, self.defaultLayer)
end
def.method("string", "=>", "userdata").OnClickEffect = function(self, effectPath)
  local model = self.m_model
  if model == nil or model.isnil then
    return nil
  end
  local effect = ECFxMan.Instance():PlayAsChild(effectPath, model, EC.Vector3.new(0, 0, 0), Quaternion.identity, -1, false, self.defaultLayer)
  return effect
end
def.virtual().OnClick = function(self)
end
def.virtual().OnLongTouch = function(self)
end
def.virtual().OnTouchBegin = function(self)
  self:SetBrightness(1.5)
end
def.virtual().OnTouchEnd = function(self)
  self:SetBrightness(1)
end
def.virtual("number").SetAlpha = function(self, val)
  local m = self.m_model
  if not m then
    return
  end
  if m.isnil then
    return
  end
  if self.m_IsAlpha == true then
    return
  end
  if self.m_IsStone then
    self:RecoverFromStone()
  else
    self:ResetShaders()
  end
  local rs = self.m_renderers
  for i = 1, #rs do
    local render = rs[i]
    if render ~= nil and not render.isnil then
      local srcMat = render.material
      if srcMat ~= nil then
        local newName = srcMat.shader.name
        local shaderName = "Hidden/" .. newName .. "_Transparent"
        local newShader = ECModel.alphaShaderList[shaderName]
        if newShader ~= nil then
          srcMat.shader = newShader
          srcMat:SetFloat("_Transparent", val)
        end
      end
    end
  end
  local weaponObj = self.m_model:FindDirect("Weapon")
  if weaponObj then
    local renders = weaponObj:GetRenderersInChildren()
    if renders then
      for _, r in pairs(renders) do
        local srcMat = r.material
        if srcMat then
          self.srcShaders[r.gameObject.name] = srcMat.shader
          local newName = srcMat.shader.name
          local shaderName = "Hidden/" .. newName .. "_Transparent"
          local newShader = ECModel.alphaShaderList[shaderName]
          if newShader then
            srcMat.shader = newShader
            srcMat:SetFloat("_Transparent", val)
          end
        end
      end
    end
  end
  self.m_IsAlpha = true
end
def.virtual("number").ChangeAlpha = function(self, val)
  local m = self.m_model
  if not m then
    return
  end
  if m.isnil then
    return
  end
  local rs = self.m_renderers
  for i = 1, #rs do
    local render = rs[i]
    if render ~= nil and not render.isnil then
      local srcMat = render.material
      if srcMat ~= nil then
        srcMat:SetFloat("_Transparent", val)
      end
    end
  end
  local weaponObj = self.m_model:FindDirect("Weapon")
  if weaponObj then
    local renders = weaponObj:GetRenderersInChildren()
    if renders then
      for _, r in pairs(renders) do
        local srcMat = r.material
        if srcMat then
          srcMat:SetFloat("_Transparent", val)
        end
      end
    end
  end
end
def.virtual().CloseAlpha = function(self)
  if self.m_IsAlpha == false then
    return
  end
  self:CloseAlphaBase()
end
def.method().CloseAlphaBase = function(self)
  if self.m_model == nil then
    return
  end
  if self.m_model.isnil then
    return
  end
  self:ResetShaders()
  local weaponObj = self.m_model:FindDirect("Weapon")
  if weaponObj then
    local renders = weaponObj:GetRenderersInChildren()
    if renders then
      for _, r in pairs(renders) do
        local shader = self.srcShaders[r.gameObject.name]
        if shader then
          r.material.shader = shader
        end
      end
    end
  end
  self.m_IsAlpha = false
end
def.method().TurnToStone = function(self)
  if self.m_model == nil or self.m_model.isnil then
    return
  end
  if self.m_IsStone then
    return
  end
  if self.m_IsAlpha then
    self:CloseAlpha()
  else
    self:ResetShaders()
  end
  local rs = self.m_renderers
  for i = 1, #rs do
    local render = rs[i]
    if render ~= nil and not render.isnil then
      local srcMat = render.material
      if srcMat ~= nil then
        local oldName = srcMat.shader.name
        local shaderName = "Hidden/" .. oldName .. "_Grey"
        local newShader = ECModel.alphaShaderList[shaderName]
        if newShader ~= nil then
          srcMat.shader = newShader
        end
      end
    end
  end
  self.m_IsStone = true
end
def.method().RecoverFromStone = function(self)
  if self.m_model == nil then
    return
  end
  if self.m_model.isnil then
    return
  end
  self.m_IsStone = false
  self:ResetShaders()
end
def.method("number").SetBrightness = function(self, val)
  local m = self.m_model
  if not m then
    return
  end
  if m.isnil then
    return
  end
  local rs = self.m_renderers
  for i = 1, #rs do
    local render = rs[i]
    if render ~= nil and not render.isnil then
      local srcMat = render.material
      if srcMat ~= nil then
        srcMat:SetFloat("_Lighten", val)
      end
    end
  end
end
def.method("table", "=>", "table").GetColoration = function(self, colorcfg)
  if colorcfg == nil then
    if self.colorId <= 0 then
      return nil
    end
    colorcfg = GetModelColorCfg(self.colorId)
  end
  if colorcfg == nil then
    return nil
  end
  local colorInfo = {}
  colorInfo.hair = colorcfg and colorcfg.partNum > 1 and Color.Color(colorcfg.part1_r / 255, colorcfg.part1_g / 255, colorcfg.part1_b / 255, colorcfg.part1_a / 255)
  colorInfo.clothes = colorcfg and Color.Color(colorcfg.part2_r / 255, colorcfg.part2_g / 255, colorcfg.part2_b / 255, colorcfg.part2_a / 255)
  colorInfo.other = colorcfg and colorcfg.partNum > 2 and Color.Color(colorcfg.part3_r / 255, colorcfg.part3_g / 255, colorcfg.part3_b / 255, colorcfg.part3_a / 255)
  return colorInfo
end
def.method("table").SetColoration = function(self, colorcfg)
  self.m_color = self:GetColoration(colorcfg)
  self:SetModelColor(self.m_color)
end
def.method("table").SetModelColor = function(self, colorInfo)
  self.m_color = colorInfo
  if self.m_model == nil or self.m_model.isnil then
    return
  end
  local defaultColor = Color.Color(1, 1, 1, 0.5)
  local defaultColorInfo = self:GetColoration(nil) or {}
  for k, v in pairs(self.m_renderers) do
    if not v.isnil then
      local originalColor = self.m_originalColors[v.gameObject.name]
      if originalColor then
        defaultColor = originalColor
      end
      if v.gameObject.name == ECModel.Name.Hair then
        v.material:SetColor("_Tint", colorInfo and colorInfo.hair or defaultColorInfo.hair or defaultColor)
      elseif v.gameObject.name == ECModel.Name.Panda then
        v.material:SetColor("_Tint", colorInfo and (colorInfo.other or colorInfo.clothes) or defaultColorInfo.clothes or defaultColor)
      elseif v.gameObject.name ~= ECModel.Name.Body then
        v.material:SetColor("_Tint", colorInfo and colorInfo.clothes or defaultColorInfo.clothes or defaultColor)
      end
    end
  end
end
def.method().ResetShaders = function(self)
  if self.m_model == nil or self.srcShaders == nil then
    return
  end
  if self.m_model.isnil then
    return
  end
  local rs = self.m_renderers
  for i = 1, #rs do
    local render = rs[i]
    if render and not render.isnil then
      local shader = self.srcShaders[render.gameObject.name]
      if shader then
        render.material.shader = shader
      end
    end
  end
end
def.method("=>", "number").GetBoxHeight = function(self)
  if self.m_model == nil then
    return 0
  end
  if self.m_model.isnil then
    return 0
  end
  local bc = self.m_model:GetComponent("BoxCollider")
  if bc then
    return bc.size.y
  end
  return 0
end
def.virtual().SetPate = function(self)
end
def.method("userdata").SetParentNode = function(self, parent)
  if parent and parent.isnil then
    return
  end
  self.parentNode = parent
  if self.m_model and not self.m_model.isnil then
    self.m_model.parent = parent
  end
end
def.method("userdata").SetDefaultParentNode = function(self, parent)
  if parent and parent.isnil then
    return
  end
  self.defaultParentNode = parent
  if self.m_node2d then
    self.m_node2d.parent = parent
  end
end
def.method().InitOriginalModelInfo = function(self)
  self:InitOriginalColors()
end
def.method().InitOriginalColors = function(self)
  if self.m_originalColors ~= nil then
    return
  end
  self.m_originalColors = {}
  for _, v in pairs(self.m_renderers) do
    local mat = v.material
    if mat:HasProperty("_Tint") then
      self.m_originalColors[v.gameObject.name] = mat:GetColor("_Tint")
    end
  end
end
def.method().RestoreModelOriginalInfo = function(self)
  if self.m_renderers == nil then
    return
  end
  if self.m_originalColors == nil then
    return
  end
  for k, v in pairs(self.m_renderers) do
    if not v.isnil then
      local originalColor = self.m_originalColors[v.gameObject.name]
      if originalColor then
        v.material:SetColor("_Tint", originalColor)
      end
    end
  end
end
def.method().ClearModelOriginalInfoCatch = function(self)
  self.m_originalColors = nil
  if self.mShadowObj and not self.mShadowObj.isnil then
    self.mShadowObj:SetActive(true)
    self.mShadowObj.localPosition = EC.Vector3.zero
    self.mShadowObj.localScale = self.mShadowScale
  end
end
def.virtual().SetStance = function(self)
  self:Play(ActionName.Stand)
end
ECModel.Commit()
return ECModel
