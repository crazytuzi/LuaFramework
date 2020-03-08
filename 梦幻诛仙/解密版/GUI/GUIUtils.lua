local GUIUtils = {}
local Vector = require("Types.Vector")
GUIUtils.Corner = {
  UpperLeft = 1,
  UpperRight = 2,
  LowerLeft = 3,
  LowerRight = 4
}
local texture_protector = {}
function GUIUtils.FillIcon(uiTexture, iconId, onFilled)
  if uiTexture == nil then
    warn("uiTexture is nil in FillIcon")
    return
  end
  local bundlePath = GetIconPath(iconId)
  if bundlePath == "" then
    uiTexture.mainTexture = nil
    return
  end
  local protectName = uiTexture:GetInstanceID()
  if protectName then
    texture_protector[protectName] = bundlePath
  end
  GameUtil.AsyncLoad(bundlePath, function(ass)
    if protectName then
      if texture_protector[protectName] ~= bundlePath then
        return
      end
      texture_protector[protectName] = nil
    end
    if uiTexture.isnil then
      return
    end
    if ass and ass.bytes then
      local tex2d = Texture2D.Texture2D(0, 0, TextureFormat.RGBA32, false)
      local ret = tex2d:LoadImage(ass.bytes)
      if not ret then
        print("LoadImage for png error")
      end
      uiTexture.mainTexture = tex2d
    elseif ass then
      local typename = getmetatable(ass).name
      if typename == "Texture2D" then
        uiTexture.mainTexture = ass
      else
        uiTexture.mainTexture = nil
        warn("Bad type set to uiTexture, type:" .. typename .. ",path:" .. bundlePath)
      end
    else
      uiTexture.mainTexture = nil
      warn(bundlePath .. "load fail")
    end
    if onFilled then
      onFilled(uiTexture)
    end
  end)
end
local sprite_protector = {}
function GUIUtils.FillSprite(uiSprite, iconId, onFilled)
  if uiSprite == nil then
    warn("uiSprite is nil in FillSprite")
    return
  end
  local bundlePath, spriteName = _G.GetSpritePath(iconId)
  if bundlePath == "" then
    uiSprite.spriteName = "__nil"
    return
  end
  local protectName = uiSprite:GetInstanceID()
  if protectName then
    sprite_protector[protectName] = bundlePath
  end
  GameUtil.AsyncLoad(bundlePath, function(ass)
    if protectName then
      if sprite_protector[protectName] ~= bundlePath then
        return
      end
      sprite_protector[protectName] = nil
    end
    if uiSprite.isnil then
      return
    end
    if ass then
      local typename = getmetatable(ass).name
      if typename == "GameObject" then
        local atlas = ass:GetComponent("UIAtlas")
        if atlas then
          uiSprite:set_atlas(atlas)
          uiSprite:set_spriteName(spriteName)
        else
          warn("Bad prefab set to UISprite, iconId:%d, path:%s", iconId, bundlePath)
        end
      else
        string.format("Bad type set to UISprite, iconId:%d, type:%s, path:%s", iconId, typename, bundlePath)
      end
    else
      uiSprite.spriteName = "__nil"
      warn(bundlePath .. "load fail")
    end
    if onFilled then
      onFilled(uiSprite)
    end
  end)
end
function GUIUtils.LoadTextureFromPath(imgPath, width, height, cb)
  GameUtil.LoadTexture(imgPath, function(ret, imgPath, bytes)
    if ret then
      local tex2d = Texture2D.Texture2D(width, height, TextureFormat.RGB24, false)
      local ret = tex2d:LoadImage(bytes)
      if cb then
        cb(ret, tex2d)
      end
    end
  end)
end
function GUIUtils.FillTextureFromURL(go, url, cb, mutiCB)
  local function fillTexCB(ret, tex2d)
    if not ret then
      warn("FillTextureFromURL error:", url)
    end
    if not go or go.isnil then
      return
    end
    local co = go:GetComponent("UITexture")
    if not co then
      warn("FillTextureFromURL component not exist", go.name)
      return
    end
    co.mainTexture = tex2d
    if cb then
      cb(tex2d)
    end
  end
  local function LoadTextureFromPath(imgPath)
    local fileType = FindFormatString(url, "[.](%w+)")
    if fileType == "gif" then
      GameUtil.gifConvertPng(imgPath)
    end
    GUIUtils.LoadTextureFromPath(imgPath, 0, 0, fillTexCB)
  end
  _G.DownLoadDataFromURL(url, LoadTextureFromPath, mutiCB)
end
function GUIUtils.FillTextureFromLocalPath(go, localPath, cb)
  local fileType = FindFormatString(localPath, "[.](%w+)")
  if fileType == "gif" then
    GameUtil.gifConvertPng(localPath)
  end
  GUIUtils.LoadTextureFromPath(localPath, 0, 0, function(ret, tex2d)
    if not ret then
      warn("FillTextureFromLocalPath error:", localPath)
    end
    if _G.IsNil(go) then
      return
    end
    local co = go:GetComponent("UITexture")
    if not co then
      warn("FillTextureFromLocalPath component not exist", go.name)
      return
    end
    co.mainTexture = tex2d
    if cb then
      cb(co)
    end
  end)
end
GUIUtils.Effect = {
  Normal = 1,
  Gray = 2,
  Circular = 3
}
function GUIUtils.SetTextureEffect(uiTexture, effect)
  local shader = uiTexture:get_shader()
  local oldMat = uiTexture:get_material()
  if effect == GUIUtils.Effect.Normal then
    local newMat = Material.Material(shader)
    if oldMat then
      newMat:CopyPropertiesFromMaterial(oldMat)
    end
    newMat:DisableKeyword("Grey_On")
    uiTexture:set_material(newMat)
  elseif effect == GUIUtils.Effect.Gray then
    local newMat = Material.Material(shader)
    if oldMat then
      newMat:CopyPropertiesFromMaterial(oldMat)
    end
    newMat:EnableKeyword("Grey_On")
    uiTexture:set_material(newMat)
  elseif effect == GUIUtils.Effect.Circular then
    GUIUtils.SetCircularEffect(uiTexture)
  end
end
function GUIUtils.SetCircularEffect(uiTexture)
  local bundlePath = RESPATH.CIRCULAR_MASK_MATERIAL
  GameUtil.AsyncLoad(bundlePath, function(asset)
    if asset == nil then
      return
    end
    local newMat = Object.Instantiate(asset, "GameObject")
    if not uiTexture.isnil then
      uiTexture:set_material(newMat)
    end
  end)
end
GUIUtils.Light = {
  None = 0,
  Square = 1,
  Round = 2
}
function GUIUtils.SetLightEffect(go, light)
  if go == nil or go.isnil then
    return
  end
  local lightName = "lighteffect"
  local GUIFxMan = require("Fx.GUIFxMan")
  local Vector = require("Types.Vector")
  if light == GUIUtils.Light.Square then
    local lighteffect = go:FindDirect(lightName)
    if lighteffect then
      return
    end
    local widget = go:GetComponent("UIWidget")
    local w = widget:get_width()
    local h = widget:get_height()
    local xScale = w / 64
    local yScale = h / 64
    GUIFxMan.Instance():PlayAsChildLayer(go, RESPATH.BTN_LIGHT_SQUARE, lightName, 0, 0, xScale, yScale, -1, false)
  elseif light == GUIUtils.Light.Round then
    local lighteffect = go:FindDirect(lightName)
    if lighteffect then
      return
    end
    local widget = go:GetComponent("UIWidget")
    local w = widget:get_width()
    local h = widget:get_height()
    local radius = math.min(w, h)
    local scale = radius / 64
    local fx = GUIFxMan.Instance():PlayAsChildLayer(go, RESPATH.BTN_LIGHT_ROUND, lightName, 0, 0, scale, scale, -1, false)
  else
    local lighteffect = go:FindDirect(lightName)
    if lighteffect then
      Object.Destroy(lighteffect)
    end
  end
end
function GUIUtils.GetHeadSpriteName(Occupation, gender)
  return string.format("%d-%d", Occupation, gender)
end
function GUIUtils.GetHeadSpriteNameNoBound(Occupation, gender)
  return string.format("%d-%d", Occupation, gender + 5)
end
function GUIUtils.GetOccupationSmallIcon(Occupation)
  return string.format("%d-8", Occupation)
end
function GUIUtils.GetOccupationArtisticText(Occupation)
  return string.format("%d-8", Occupation)
end
function GUIUtils.DyeText(str, color)
  return string.format("[%s]%s[-]", color, str)
end
function GUIUtils.GetSexIcon(gender)
  gender = tonumber(gender)
  if gender == 1 then
    return "Img_nan"
  elseif gender == 2 then
    return "Img_nv"
  else
    return ""
  end
end
function GUIUtils.GetHeroHalfBodyID(occupation, gender)
  local occupationCfg = _G.GetOccupationCfg(occupation, gender)
  local modelId = occupationCfg.modelId
  local cfg = require("Main.Pubrole.PubroleInterface").GetModelCfg(modelId)
  return cfg.halfBodyIconId
end
function GUIUtils.GetHeroHalfBodyPath(occupation, gender)
  local iconId = GUIUtils.GetHeroHalfBodyID(occupation, gender)
  local cfg = _G.GetHalfBodyCfg(iconId)
  return cfg.path
end
function GUIUtils.ShowHoverTip(tipId, x, y)
  local x = x or 0
  local y = y or 0
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(tipId)
  local tmpPosition = {x = x, y = y}
  local CommonDescDlg = require("GUI.CommonUITipsDlg")
  CommonDescDlg.ShowCommonTip(tipContent, tmpPosition)
end
function GUIUtils.ShowHoverScrollTip(tipId, x, y)
  local x = x or 0
  local y = y or 0
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(tipId)
  local tmpPosition = {x = x, y = y}
  local CommonUIScrollTip = require("GUI.CommonUIScrollTip")
  CommonUIScrollTip.ShowCommonTip(tipContent, tmpPosition)
end
function GUIUtils.ShowHoverSmallTip(tipId, params)
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(tipId)
  local x, y, w, h, prefer = 0, 0, 0, 0, nil
  if params and params.sourceObj then
    local sourceObj = params.sourceObj
    local position = sourceObj:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    x, y = screenPos.x, screenPos.y
    local widget = sourceObj:GetComponent("UIWidget")
    if widget then
      w, h = widget:get_width(), widget:get_height()
    end
  end
  local prefer = params and params.prefer or 0
  local CommonUISmallTip = require("GUI.CommonUISmallTip")
  CommonUISmallTip.Instance():ShowTip(tipContent, x, y, w, h, prefer)
end
local template
function GUIUtils.BindClickableWidget(srcobj, cwName)
  if cwName == nil then
    cwName = srcobj.name .. "_Clickable"
  end
  local clickableWidget = srcobj:FindDirect(cwName)
  if clickableWidget then
    return clickableWidget
  end
  local function InitTemplate()
    if template == nil then
      local clickableWidget = GameObject.GameObject("ClickableWidget")
      local uiWidget = clickableWidget:AddComponent("UIWidget")
      uiWidget.autoResizeBoxCollider = true
      clickableWidget:AddComponent("BoxCollider")
      clickableWidget:SetActive(false)
      clickableWidget.layer = _G.ClientDef_Layer.UI
      template = clickableWidget
    end
  end
  local Vector = require("Types.Vector")
  InitTemplate()
  local clickableWidget = GameObject.Instantiate(template)
  clickableWidget:SetActive(true)
  local uiWidget = clickableWidget:GetComponent("UIWidget")
  local parentUIWidget = srcobj:GetComponent("UIWidget")
  uiWidget.width, uiWidget.height = parentUIWidget.width, parentUIWidget.height
  uiWidget.depth = parentUIWidget.depth - 1
  uiWidget:ResizeCollider()
  clickableWidget.transform.parent = srcobj.transform
  clickableWidget.transform.localPosition = Vector.Vector3.zero
  clickableWidget.transform.localScale = Vector.Vector3.one
  clickableWidget.name = cwName
  return clickableWidget
end
function GUIUtils.GetIconIdRoleExp()
  return 7001
end
function GUIUtils.GetIconIdPetExp()
  return 7002
end
function GUIUtils.GetIconIdXiulianExp()
  return 7003
end
function GUIUtils.GetIconIdSilver()
  return 7008
end
function GUIUtils.GetIconIdGold()
  return 7007
end
function GUIUtils.GetIconIdBanggong()
  return 7004
end
function GUIUtils.GetIconIdYuanbao()
  return 7006
end
function GUIUtils.GetIconIdByCurrencyType(type)
  local CurrencyType = require("consts.mzm.gsp.common.confbean.CurrencyType")
  if type == CurrencyType.YUAN_BAO then
    return GUIUtils.GetIconIdYuanbao()
  elseif type == CurrencyType.GOLD then
    return GUIUtils.GetIconIdGold()
  elseif type == CurrencyType.SILVER then
    return GUIUtils.GetIconIdSilver()
  elseif type == CurrencyType.BANG_GONG then
    return GUIUtils.GetIconIdBanggong()
  else
    return 0
  end
end
GUIUtils.COTYPE = {
  TABEL = "UITable",
  GRID = "UIGrid",
  LIST = "UIList",
  SPRITE = "UISprite",
  SLIDER = "UISlider",
  LABEL = "UILabel",
  TEXTURE = "UITexture",
  PROGRESS = "UIProgressBar",
  Tweener = "UITweener"
}
local CheckGO = function(go)
  if not go or go.isnil then
    warn("GameObject not exist", debug.traceback())
    return false
  end
  return go.activeSelf
end
function GUIUtils.FindDirect(parentGO, goName)
  if parentGO and not parentGO.isnil then
    return parentGO:FindDirect(goName)
  end
end
function GUIUtils.SetActive(go, flag)
  if go and not go.isnil then
    go:SetActive(flag)
  end
end
function GUIUtils.SetColor(go, color, type)
  if not CheckGO(go) then
    return
  end
  local co = go:GetComponent(type)
  if co then
    co.color = color
  else
    warn(("%s doesn't have sprite component: %s"):format(go.name, type))
  end
end
function GUIUtils.SetTextColor(go, color, type)
  if not CheckGO(go) then
    return
  end
  local co = go:GetComponent(type)
  if co then
    co.textColor = color
  else
    warn(("%s doesn't have sprite component: %s"):format(go.name, type))
  end
end
function GUIUtils.SetText(go, text)
  if not CheckGO(go) then
    return
  end
  local co = go:GetComponent("UILabel")
  if co then
    co.text = text
  else
    warn(("%s doesn't have label component: "):format(go.name))
  end
end
function GUIUtils.SetTextAndColor(go, text, color, type)
  if not CheckGO(go) then
    return
  end
  type = type or GUIUtils.COTYPE.LABEL
  GUIUtils.SetText(go, text)
  GUIUtils.SetTextColor(go, color, type)
end
function GUIUtils.SetTexture(go, id, onFilled)
  if not CheckGO(go) then
    return
  end
  local co = go:GetComponent("UITexture")
  if co and id == 0 then
    co.mainTexture = nil
    return
  end
  GUIUtils.FillIcon(co, id, onFilled)
end
function GUIUtils.Toggle(go, flag)
  if not CheckGO(go) then
    return
  end
  local co = go:GetComponent("UIToggle")
  if co then
    co.value = flag
  else
    warn(("%s doesn't have toggle component: "):format(go.name))
  end
end
function GUIUtils.IsToggle(go)
  if not CheckGO(go) then
    return
  end
  local co = go:GetComponent("UIToggle")
  if co then
    return co.value
  else
    warn(("%s doesn't have toggle component: "):format(go.name))
  end
end
function GUIUtils.SetProgress(go, type, progress)
  if not CheckGO(go) then
    return
  end
  local co = go:GetComponent(type)
  if co then
    co.value = progress
  else
    warn(("%s doesn't have slider component: "):format(go.name))
  end
end
function GUIUtils.InitUIList(go, count, rename)
  if not CheckGO(go) then
    return
  end
  local uiList = go:GetComponent("UIList")
  uiList.renameControl = not rename
  uiList.itemCount = count
  uiList:Resize()
  return uiList.children
end
function GUIUtils.SetSprite(go, spriteName, isSnap)
  if not CheckGO(go) then
    return
  end
  local isSnap = isSnap or false
  local co = go:GetComponent("UISprite")
  if co then
    co.spriteName = spriteName
    if isSnap then
      co:MakePixelPerfect()
    end
  else
    warn(("%s doesn't have sprite component: "):format(go.name))
  end
end
function GUIUtils.Reposition(go, type, delay)
  if not CheckGO(go) then
    return
  end
  local co = go:GetComponent(type)
  if co then
    if not delay then
      co:Reposition()
    else
      GameUtil.AddGlobalLateTimer(delay, true, function()
        if CheckGO(go) and co then
          co:Reposition()
        end
      end)
    end
  else
    warn(("%s doesn't have reposition component: %s"):format(go.name, GUIUtils.COTYPE[type]))
  end
end
function GUIUtils.ResetPosition(go, delay)
  if not CheckGO(go) then
    return
  end
  local co = go:GetComponent("UIScrollView")
  if co then
    if not delay then
      co:ResetPosition()
    else
      GameUtil.AddGlobalLateTimer(delay, true, function()
        if CheckGO(go) and co then
          co:ResetPosition()
        end
      end)
    end
  else
    warn(("%s doesn't have UIScrollView component"):format(go.name))
  end
end
function GUIUtils.DragToMakeVisible(go, itemGO, delay, strength)
  if not CheckGO(go) then
    return
  end
  local co = go:GetComponent("UIScrollView")
  if co then
    if not delay then
      co:DragToMakeVisible(itemGO.transform, strength)
    else
      GameUtil.AddGlobalLateTimer(delay, true, function()
        if CheckGO(go) and co and itemGO then
          co:DragToMakeVisible(itemGO.transform, strength)
        end
      end)
    end
  else
    warn(("%s doesn't have UIScrollView component"):format(go.name))
  end
end
function GUIUtils.SetStarView(go, count)
  if not CheckGO(go) then
    return
  end
  GUIUtils.InitUIList(go, count)
end
function GUIUtils.SetCollider(go, flag)
  if not CheckGO(go) then
    return
  end
  local co = go:GetComponent("BoxCollider")
  if co then
    co.enabled = flag
  end
end
function GUIUtils.GetUILabelTxt(go)
  if not CheckGO(go) then
    return nil
  end
  local co = go:GetComponent("UILabel")
  if co then
    return co.text
  end
  return nil
end
function GUIUtils.SetUIInputValue(go, value)
  if not CheckGO(go) then
    return
  end
  local co = go:GetComponent("UIInput")
  if co then
    co.value = value
  else
    warn(("%s doesn't have input component: "):format(go.name))
  end
end
function GUIUtils.GetUIInputValue(go)
  if not CheckGO(go) then
    return nil
  end
  local co = go:GetComponent("UIInput")
  if co then
    return co.value
  end
  return nil
end
function GUIUtils.SetParent(go, parentGO)
  if not CheckGO(go) then
    return
  end
  if not CheckGO(parentGO) then
    return
  end
  go:set_parent(parentGO)
end
function GUIUtils.ResetTransform(go)
  if not CheckGO(go) then
    return
  end
  go:set_localScale(Vector.Vector3.one)
  go:set_localPosition(Vector.Vector3.zero)
  go:set_localRotation(Quaternion.identity)
end
function GUIUtils.SetParentAndResetTransform(go, parentGO)
  GUIUtils.SetParent(go, parentGO)
  GUIUtils.ResetTransform(go)
end
function GUIUtils.FormatCountTime(deadLineTime)
  local curTime = GetServerTime()
  local remain = deadLineTime - curTime
  local timeStr = ""
  if remain >= 0 then
    if remain >= 86400 then
      local tmp = 86400
      local day, left = math.modf(remain / tmp)
      timeStr = timeStr .. string.format("%d%s", day, textRes.Common.Day) .. ":"
      remain = left * 24 * 60 * 60
    end
    if remain >= 3600 then
      local tmp = 3600
      local hour, left = math.modf(remain / tmp)
      timeStr = timeStr .. string.format("%02d", hour) .. ":"
      remain = left * 60 * 60
    end
    if remain >= 60 then
      local tmp = 60
      local minute, left = math.modf(remain / tmp)
      timeStr = timeStr .. string.format("%02d", minute)
      remain = left * 60
    else
      timeStr = timeStr .. "00"
    end
  end
  return timeStr
end
function GUIUtils.PassTimeDesc(timeStamp)
  local timeStr = textRes.Common[230]
  local curTime = GetServerTime()
  local diff = curTime - timeStamp
  if diff >= 0 then
    local hours = math.floor(diff / 3600)
    if hours >= 24 and hours <= 720 then
      local days = math.floor(hours / 24)
      timeStr = textRes.Common[231]:format(days)
    elseif hours > 720 then
      timeStr = textRes.Common[231]:format(30)
    elseif hours > 0 then
      timeStr = textRes.Common[232]:format(hours)
    end
  else
    warn("PassTimeDesc Wrong  TimeStamp")
  end
  return timeStr
end
local panelLightEffectMap = {}
function GUIUtils.AddLightEffectToPanel(uiPath, light, removeEventName)
  local sPos = string.find(uiPath, "/")
  local panelname = ""
  if sPos then
    panelname = string.sub(uiPath, 1, sPos - 1)
  end
  removeEventName = removeEventName or "onClick"
  local ECGUIMan = require("GUI.ECGUIMan")
  local uiRoot = ECGUIMan.Instance().m_UIRoot
  local retryTimer = 0
  local retryTimes = 0
  retryTimer = GameUtil.AddGlobalTimer(0.5, false, function()
    local go = uiRoot:FindDirect(uiPath)
    retryTimes = retryTimes + 1
    if go and not go.isnil then
      do
        local msgHandler = go:GetComponent("UIEventToLua")
        msgHandler = msgHandler or go:AddComponent("UIEventToLua")
        if msgHandler then
          local msgt = {
            [removeEventName] = function(_, id)
              if string.find(uiPath, id) then
                GUIUtils.SetLightEffect(go, GUIUtils.Light.None)
                if not msgHandler.isnil then
                  GameObject.Destroy(msgHandler)
                end
                if panelname and panelLightEffectMap[panelname] then
                  panelLightEffectMap[panelname][uiPath] = nil
                end
              end
            end
          }
          msgHandler:SetMsgTable(msgt, {})
        end
        GUIUtils.SetLightEffect(go, light)
        GameUtil.RemoveGlobalTimer(retryTimer)
        if panelname then
          panelLightEffectMap[panelname] = panelLightEffectMap[panelname] or {}
          panelLightEffectMap[panelname][uiPath] = go
        end
      end
    elseif retryTimes > 10 then
      warn(string.format("Auto add light effect timeout, can't find ui path: %s", uiPath))
      GameUtil.RemoveGlobalTimer(retryTimer)
    end
  end)
end
function GUIUtils.RemoveLightEffectAtPanel(panelname)
  if panelname == nil then
    return
  end
  local effects = panelLightEffectMap[panelname]
  if effects == nil then
    return
  end
  for k, go in pairs(effects) do
    if not go.isnil then
      local msgHandler = go:GetComponent("UIEventToLua")
      if msgHandler then
        GameObject.Destroy(msgHandler)
      end
      GUIUtils.SetLightEffect(go, GUIUtils.Light.None)
    end
    effects[k] = nil
  end
end
function GUIUtils.AddLightEffectToObj(uiGo, light, removeEvents)
  if uiGo and not uiGo.isnil then
    do
      local msgHandler = uiGo:GetComponent("UIEventToLua")
      msgHandler = msgHandler or uiGo:AddComponent("UIEventToLua")
      if msgHandler then
        local msgt = {}
        local function eventDo(_, id)
          if not uiGo.isnil then
            GUIUtils.SetLightEffect(uiGo, GUIUtils.Light.None)
            if not msgHandler.isnil then
              GameObject.Destroy(msgHandler)
            end
          end
        end
        for _, v in ipairs(removeEvents) do
          msgt[v] = eventDo
        end
        msgHandler:SetMsgTable(msgt, {})
      end
      GUIUtils.SetLightEffect(uiGo, light)
    end
  end
end
function GUIUtils.RemoveLightEffectAtObj(uiGo)
  if uiGo and not uiGo.isnil then
    local msgHandler = uiGo:GetComponent("UIEventToLua")
    if msgHandler then
      GameObject.Destroy(msgHandler)
    end
    GUIUtils.SetLightEffect(go, GUIUtils.Light.None)
  end
end
function GUIUtils.FixBoldFontStyle(go)
  if go == nil or go.isnil then
    return
  end
  local uiLabels = go:GetComponentsInChildren("UILabel")
  if uiLabels == nil then
    return
  end
  for i, label in ipairs(uiLabels) do
    if label.fontStyle == FontStyle.Bold or label.fontStyle == FontStyle.BoldAndItalic then
      label:set_supportEncoding(true)
      label:set_text(string.format("[b]%s[/b]", label:get_text()))
      label.fontStyle = label.fontStyle - FontStyle.Bold
    end
  end
end
function GUIUtils.CoolDownButton(go, time)
  GUIUtils.SetCollider(go, false)
  GameUtil.AddGlobalTimer(time, true, function()
    GUIUtils.SetCollider(go, true)
    local uiButton = go:GetComponent("UIButton")
    if uiButton then
      uiButton:SetState(0, true)
    end
  end)
end
function GUIUtils.EnableButton(go, isEnabled)
  if go == nil then
    return
  end
  local uiButton = go:GetComponent("UIButton")
  if uiButton then
    uiButton.isEnabled = isEnabled
  else
    warn("GameObject<%s> does not have component<%s>", go.name, "UIButton")
  end
end
function GUIUtils.RestrictUIWidgetInScreen(go)
  local pos = GUIUtils.CalcUIWidgetInScreenPos(go)
  if pos == nil then
    return
  end
  go.position = pos
end
function GUIUtils.CalcUIWidgetInScreenPos(go)
  if go == nil or go.isnil then
    return nil
  end
  local uiWidget = go:GetComponent("UIWidget")
  if uiWidget == nil then
    warn("GameObject<%s> does not have component<%s>", go.name, "UIWidget")
    return nil
  end
  local GUIMan = require("GUI.ECGUIMan")
  local screenHeight = GUIMan.Instance().m_uiRootCom:get_activeHeight()
  local screenWidth = screenHeight / Screen.height * Screen.width
  local top = screenHeight / 2
  local bottom = -top
  local left = -screenWidth / 2
  local right = -left
  local worldCenter = uiWidget.worldCenter
  local worldPosition = go.position
  local centerpos = _G.WorldPosToScreen(worldCenter.x, worldCenter.y, worldCenter.z)
  local pos = _G.WorldPosToScreen(worldPosition.x, worldPosition.y, worldPosition.z)
  local offset = {
    x = pos.x - centerpos.x,
    y = pos.y - centerpos.y
  }
  local width = uiWidget.width
  local height = uiWidget.height
  local newPos = {}
  newPos.y = math.min(top - height / 2, centerpos.y)
  newPos.y = math.max(bottom + height / 2, newPos.y)
  newPos.y = newPos.y + offset.y
  newPos.x = math.min(right - width / 2, centerpos.x)
  newPos.x = math.max(left + width / 2, newPos.x)
  newPos.x = newPos.x + offset.x
  local newWorldPos = _G.ScreenPosToWorld(newPos.x, newPos.y)
  return newWorldPos
end
function GUIUtils.GetItemCellSpriteName(namecolor)
  return string.format("Cell_%02d", namecolor)
end
function GUIUtils.SetItemCellSprite(sprite, namecolor)
  GUIUtils.SetSprite(sprite, GUIUtils.GetItemCellSpriteName(namecolor))
end
function GUIUtils.AddBoxCollider(go, autoResize)
  if go == nil then
    return
  end
  if autoResize == nil then
    autoResize = true
  end
  if autoResize == nil or not autoResize then
    autoResize = true
  end
  local boxCollider = go:GetComponent("BoxCollider")
  if boxCollider == nil then
    boxCollider = go:AddComponent("BoxCollider")
    local uiWidget = go:GetComponent("UIWidget")
    if uiWidget and autoResize then
      uiWidget.autoResizeBoxCollider = true
      uiWidget:ResizeCollider()
    end
  end
  return boxCollider
end
local cur_ver_string = GameUtil.GetProgramCurrentVersionInfo()
local cur_ver = tonumber(cur_ver_string)
function GUIUtils.CheckUIInput(input)
  if cur_ver ~= 105 then
    return true
  end
  local val = input.value
  if not val or val == "" then
    return true
  end
  local oldinput = UIInput.selection
  UIInput.selection = input
  local sstart = input.selectionStart
  local send = input.selectionEnd
  local slen = Strlen(val)
  UIInput.selection = oldinput
  if sstart < 0 or sstart > slen then
    return false
  end
  if send < 0 or send > slen then
    return false
  end
  return true
end
function GUIUtils.ConvertTexture2DAssets(ass)
  local tex2d
  if ass and ass.bytes then
    tex2d = Texture2D.Texture2D(0, 0, TextureFormat.RGBA32, false)
    local ret = tex2d:LoadImage(ass.bytes)
    if not ret then
      warn("LoadImage for png error")
    end
  elseif ass then
    local typename = getmetatable(ass).name
    if typename == "Texture2D" then
      tex2d = ass
    else
      warn(string.format("ConvertTexture2DAssets failed ass(%s) not a 'TextAsset' nor a 'Texture2D'", typename))
    end
  end
  return tex2d
end
function GUIUtils.ResizeGrid(gridGO, size, prefixName)
  local uiGrid = gridGO:GetComponent(GUIUtils.COTYPE.GRID)
  local childCount = gridGO.childCount
  if childCount == 0 then
    warn(string.format("There is no chilren under gridGO(%s)", gridGO.name))
    return
  end
  local template = gridGO:GetChild(0)
  if template.name ~= "_template" then
    template.name = "_template"
    template:SetActive(false)
  end
  local actualChildCount = childCount - 1
  if size > actualChildCount then
    for i = actualChildCount + 1, size do
      local go = GameObject.Instantiate(template)
      go:SetActive(true)
      go.parent = gridGO
      go.localScale = Vector.Vector3.one
      go.localPosition = Vector.Vector3.zero
    end
  elseif size < actualChildCount then
    for i = actualChildCount, size + 1, -1 do
      local go = gridGO:GetChild(i)
      GameObject.Destroy(go)
    end
  end
  for i = 1, size do
    local go = gridGO:GetChild(i)
    go.name = string.format("%s%d", prefixName, i)
  end
  uiGrid.hideInactive = true
  uiGrid:Reposition()
end
function GUIUtils.SampleTweener(uiTweener, factor, enable, isFinished)
  if not CheckGO(uiTweener.gameObject) then
    return
  end
  enable = enable or false
  isFinished = isFinished or false
  uiTweener:set_enabled(enable)
  uiTweener:set_tweenFactor(factor)
  uiTweener:Sample(factor, isFinished)
end
function GUIUtils.GetGenderSprite(gender)
  if gender == 1 then
    return "Img_nan"
  elseif gender == 2 then
    return "Img_nv"
  else
    return ""
  end
end
function GUIUtils.GetMoneySprite(moneyType)
  if moneyType == 1 then
    return "Img_Money"
  elseif moneyType == 2 then
    return "Icon_Gold"
  elseif moneyType == 3 then
    return "Icon_Sliver"
  elseif moneyType == 4 then
    return "Img_Bang"
  elseif moneyType == 5 then
    return "Img_JinDing"
  else
    return ""
  end
end
function GUIUtils.TileTextureToWidget(uiTexture)
  local widgetW, widgetH = uiTexture:get_width(), uiTexture:get_height()
  local mainTexture = uiTexture:get_mainTexture()
  local texW, texH = mainTexture:get_width(), mainTexture:get_height()
  local widgetAspectRatio = widgetW / widgetH
  local texAspectRatio = texW / texH
  local x, y, width, height
  if widgetAspectRatio > texAspectRatio then
    local sizeRatio = texAspectRatio / widgetAspectRatio
    x = 0
    y = (1 - sizeRatio) / 2
    width = 1
    height = sizeRatio
  elseif widgetAspectRatio < texAspectRatio then
    local sizeRatio = widgetAspectRatio / texAspectRatio
    x = (1 - sizeRatio) / 2
    y = 0
    width = sizeRatio
    height = 1
  else
    x, y, width, height = 0, 0, 1, 1
  end
  local Rect = require("Types.Rect").Rect
  local uvRect = Rect.new(x, y, width, height)
  uiTexture:set_uvRect(uvRect)
end
function GUIUtils.ScaleToNoBorder(go, designAspect)
  if _G.IsNil(go) then
    return false
  end
  local screenAspect = Screen.width / Screen.height
  if designAspect < screenAspect then
    local scaleRatio = screenAspect / designAspect
    go.localScale = Vector.Vector3.new(scaleRatio, scaleRatio, 1)
    return true
  else
    return false
  end
end
local _statusTags
function GUIUtils.SetExchangeItemStatus(stateGroup, itemId)
  if stateGroup == nil then
    _statusTags = nil
    return
  end
  local ExchangeInterface = require("Main.Exchange.ExchangeInterface")
  local itemStatus = ExchangeInterface.Instance():GetExchangeItemStatus(itemId)
  if _statusTags == nil then
    local ExchangeItemStatus = require("Main.Exchange.ExchangeItemStatus")
    _statusTags = {
      [ExchangeItemStatus.OwnUniqueItem] = "Img_Have",
      [ExchangeItemStatus.OwnFullItem] = "Img_LvMax"
    }
  end
  local statusTag = _statusTags[itemStatus]
  local itemCount = stateGroup:get_childCount()
  for i = 0, itemCount - 1 do
    local imgGO = stateGroup:GetChild(i)
    imgGO:SetActive(imgGO.name == statusTag)
  end
end
function GUIUtils.SetClampedTextWithPostfix(uiLabel, content, postfix, postfixWidth)
  if _G.IsNil(uiLabel) then
    return nil
  end
  local Overflow_ClampContent = 1
  uiLabel:set_overflowMethod(Overflow_ClampContent)
  uiLabel:set_text(content)
  local pivotOffset = uiLabel:get_pivotOffset()
  local rightMostPos = Vector.Vector2.new(uiLabel.width * (1 - pivotOffset.x), 0)
  local index = uiLabel:GetCharacterIndexAtLocalPosition(rightMostPos)
  local charNum = _G.Strlen(content)
  if index < charNum then
    postfix = postfix or "..."
    postfixWidth = postfixWidth or 1
    content = _G.StrSub(content, 1, index - postfixWidth)
    content = content .. postfix
    uiLabel:set_text(content)
  end
  return content
end
function GUIUtils.FillRoleServerInfo(groupRoot, roleId, allServer)
  local show = true
  if not allServer and _G.IsInIhisServer(roleId) then
    show = false
  end
  local zoneId = _G.GetRoleZoneId(roleId)
  GUIUtils.FillServerInfo(groupRoot, show, zoneId)
end
function GUIUtils.FillServerInfo(groupRoot, show, zoneId)
  if _G.IsNil(groupRoot) then
    return
  end
  groupRoot:SetActive(show)
  if not show then
    return
  end
  local serverListMgr = require("Main.Login.ServerListMgr").Instance()
  local serverCfg = serverListMgr:GetServerCfg(zoneId)
  if serverCfg == nil then
    warn("FillServerInfo::unknow server " .. zoneId)
  end
  local targetGroupName, displayName
  if serverCfg then
    local _, _, serverShortName = serverCfg.name:find(textRes.Common.ServerShortNamePattern)
    serverShortName = serverShortName or serverCfg.name
    if serverListMgr:IsServerSupportMultiPlatform(zoneId) then
      if serverListMgr:IsServerOnlySupportAuth(zoneId, "qq") then
        targetGroupName = "Group_Server06"
      elseif serverListMgr:IsServerOnlySupportAuth(zoneId, "wechat") then
        targetGroupName = "Group_Server05"
      end
      displayName = textRes.Common.HuTong .. serverShortName
    elseif serverListMgr:IsServerOnlySupportPlatform(zoneId, Platform.android) then
      if serverListMgr:IsServerOnlySupportAuth(zoneId, "qq") then
        targetGroupName = "Group_Server01"
      elseif serverListMgr:IsServerOnlySupportAuth(zoneId, "wechat") then
        targetGroupName = "Group_Server02"
      end
      displayName = textRes.Common.Android .. serverShortName
    elseif serverListMgr:IsServerOnlySupportPlatform(zoneId, Platform.ios) then
      if serverListMgr:IsServerOnlySupportAuth(zoneId, "qq") then
        targetGroupName = "Group_Server03"
      elseif serverListMgr:IsServerOnlySupportAuth(zoneId, "wechat") then
        targetGroupName = "Group_Server04"
      elseif serverListMgr:IsServerOnlySupportAuth(zoneId, "guest") then
        targetGroupName = "Group_Server07"
      end
      displayName = textRes.Common.iOS .. serverShortName
    end
    if targetGroupName == nil then
      targetGroupName = "Group_Server07"
      displayName = displayName or serverShortName
    end
  end
  local childCount = groupRoot:get_childCount()
  local targetGroup
  for i = 0, childCount - 1 do
    local subGroup = groupRoot:GetChild(i)
    if targetGroupName and targetGroupName == subGroup.name then
      subGroup:SetActive(true)
      targetGroup = subGroup
    else
      subGroup:SetActive(false)
    end
  end
  if targetGroup then
    local Label_Server = targetGroup:FindDirect("Label_Server")
    GUIUtils.SetText(Label_Server, displayName)
  end
end
function GUIUtils.RepositionTable(go, params)
  if _G.IsNil(go) then
    return
  end
  local startCorner = params and params.startCorner or GUIUtils.Corner.UpperLeft
  if startCorner == GUIUtils.Corner.UpperLeft then
    local uiTable = go:GetComponent("UITable")
    if uiTable then
      uiTable:Reposition()
      return
    end
  end
  GUIUtils.RepositionTableCutomized(go, params)
end
function GUIUtils.RepositionTableCutomized(go, params)
  if _G.IsNil(go) then
    return
  end
  local function repositionInner(...)
    params = params or {}
    local startCorner = params.startCorner or GUIUtils.Corner.UpperLeft
    local col = params.col or 0
    local hideInactive = params.hideInactive == nil and true or params.hideInactive
    local padding = params.padding or Vector.Vector3.zero
    local sorting = params.sorting
    local children = {}
    local childCount = go:get_childCount()
    for i = 0, childCount - 1 do
      local child = go:GetChild(i)
      if hideInactive and child:get_activeSelf() then
        table.insert(children, child)
      end
    end
    if #children == 0 then
      return
    end
    if sorting and type(sorting) == "function" then
      table.sort(children, sorting)
    end
    local considerInactive = not hideInactive
    local limitRows = {}
    local boundsList = {}
    local curRow = 1
    for i, child in ipairs(children) do
      curRow = col == 0 and 1 or math.floor((i - 1) / col) + 1
      if not limitRows[curRow] then
        local limitRow = {height = 0}
      end
      limitRows[curRow] = limitRow
      local trans = child.transform
      local bounds = NGUIMath.CalculateRelativeWidgetBounds2t1b(trans, trans, considerInactive)
      local size = bounds:get_size()
      limitRow.height = math.max(limitRow.height, size.y)
      boundsList[i] = bounds
    end
    local dirX = 1
    if startCorner == GUIUtils.Corner.UpperRight or startCorner == GUIUtils.Corner.LowerRight then
      dirX = -1
    end
    local dirY = -1
    if startCorner == GUIUtils.Corner.LowerLeft or startCorner == GUIUtils.Corner.LowerRight then
      dirY = 1
    end
    local offsetX = 0
    local offsetY = 0
    local curCol = 1
    local curRow = 1
    for i, child in ipairs(children) do
      local pos = Vector.Vector3.new(0, 0, 0)
      local bounds = boundsList[i]
      local limitRow = limitRows[curRow]
      local extents = bounds:get_extents()
      local center = bounds:get_center()
      pos.x = offsetX + dirX * extents.x - center.x
      offsetX = offsetX + dirX * (extents.x * 2 + padding.x * 2)
      pos.y = offsetY + dirY * (limitRow.height / 2) - center.y
      child.localPosition = pos
      curCol = curCol + 1
      if col > 0 and col < curCol then
        offsetX = 0
        offsetY = offsetY + dirY * (limitRow.height + padding.y * 2)
        curCol = 1
        curRow = curRow + 1
      end
    end
  end
  if go:get_activeInHierarchy() then
    repositionInner()
  else
    GameUtil.AddGlobalTimer(0, true, function()
      if _G.IsNil(go) then
        return
      end
      if go:get_activeInHierarchy() then
        repositionInner()
      else
        warn(string.format("RepositionTableCutomized failed: %s not active in hierarchy", go.name))
      end
    end)
  end
end
local UILABEL_SUPPORT_SHIFT_COLOR_VERSION = 123
function GUIUtils.IsLabelSupoortShiftColor()
  local DeviceUtility = require("Utility.DeviceUtility")
  local version = DeviceUtility.GetProgramCurrentVersion()
  return version >= UILABEL_SUPPORT_SHIFT_COLOR_VERSION
end
return GUIUtils
