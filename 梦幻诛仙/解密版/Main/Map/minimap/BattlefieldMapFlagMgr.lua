local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BattlefieldMapMgrBase = import(".BattlefieldMapMgrBase")
local BattlefieldMapFlagMgr = Lplus.Extend(BattlefieldMapMgrBase, MODULE_NAME)
local CTFFeature = require("Main.CaptureTheFlag.mgr.CTFFeature")
local MiniMapPanel = Lplus.ForwardDeclare("MiniMapPanel")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local CaptureTheFlagUtils = require("Main.CaptureTheFlag.CaptureTheFlagUtils")
local BattleFieldMgr = require("Main.CaptureTheFlag.mgr.BattleFieldMgr")
local PlayType = require("consts.mzm.gsp.singlebattle.confbean.PlayType")
local def = BattlefieldMapFlagMgr.define
def.field("table").m_flagGOs = nil
def.field("table").m_towerPos = nil
def.override().OnCreate = function(self)
  self:LoadAll()
  Event.RegisterEventWithContext(ModuleId.CTF, gmodule.notifyId.CTF.TowerStateChange, BattlefieldMapFlagMgr.OnTowerStateChange, self)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CTF, gmodule.notifyId.CTF.TowerStateChange, BattlefieldMapFlagMgr.OnTowerStateChange)
  self.m_flagGOs = nil
end
def.method().LoadAll = function(self)
  self:Prepare(function(ret)
    if ret == false then
      return
    end
    self:AsyncCreateTemplateGO(function(templateGO)
      self.m_flagGOs = {}
      local allFlagInfos = self:GetAllFlagInfo()
      for i, v in ipairs(allFlagInfos) do
        local go = GameObject.Instantiate(templateGO)
        go.name = "battlefield_flag_" .. i
        self.m_miniMap:AddUnitToMap(go, {
          x = v.cfg.positionX,
          y = v.cfg.positionY
        })
        table.insert(self.m_flagGOs, go)
      end
      GameObject.Destroy(templateGO)
      self:UpdateAllFlags()
    end)
  end)
end
def.method("function").Prepare = function(self, callback)
  GameUtil.AsyncLoad(RESPATH.PREFAB_MINI_MAP_BATTLEFIELD_TOWERS, function(obj)
    if obj == nil then
      return
    end
    if self.m_miniMap == nil then
      return
    end
    self:SetTowerTemplatePos(obj)
    callback(true)
  end)
end
def.method("userdata").SetTowerTemplatePos = function(self, obj)
  self.m_towerPos = {}
  local cfgId = BattleFieldMgr.Instance():GetCfgId()
  local battleCfg = CaptureTheFlagUtils.GetBattleCfg(cfgId)
  local playLib = CaptureTheFlagUtils.GetBattlePlays(battleCfg.playLibId)
  local playCfgId = playLib[PlayType.GRAB_FLAG]
  local templateGO = obj:FindDirect("Class_" .. playCfgId)
  if templateGO == nil then
    warn(string.format("No Tower position template for playCfgId=%d", playCfgId))
    return
  end
  local childCount = templateGO.childCount
  for i = 0, childCount - 1 do
    local towerGO = templateGO:GetChild(i)
    local towerCfgId = tonumber(towerGO.name:split("_")[2])
    if towerCfgId then
      self.m_towerPos[towerCfgId] = towerGO.localPosition
    end
  end
end
def.method().UpdateAllFlags = function(self)
  if self.m_flagGOs == nil then
    return
  end
  local allFlagInfos = self:GetAllFlagInfo()
  for i, v in ipairs(allFlagInfos) do
    local go = self.m_flagGOs[i]
    self:SetFlagGOInfo(go, v)
  end
end
def.method("userdata", "table").SetFlagGOInfo = function(self, go, flagInfo)
  if go == nil then
    Debug.LogError(debug.traceback())
    return
  end
  local Img_Name = go:FindDirect("Img_Name")
  local spriteName = "nil1"
  if flagInfo.campId ~= 0 then
    local campCfg = CaptureTheFlagUtils.GetCampCfg(flagInfo.campId)
    if campCfg then
      spriteName = campCfg.campNameIcon
    else
      spriteName = "nil2"
    end
  end
  GUIUtils.SetSprite(Img_Name, spriteName, true)
  Img_Name.localScale = Vector.Vector3.new(0.6, 0.6, 1)
  local towerCfg = flagInfo.cfg
  local towerEffectCfg = towerCfg.camps[flagInfo.campId] or towerCfg.defaultPositionMapCfg
  local iconId
  if towerEffectCfg then
    iconId = towerEffectCfg.miniMapIcon
  else
    Debug.LogError(string.format("No towerEffectCfg for campId = %d", flagInfo.campId))
  end
  local Label_Name = go:FindDirect("Label_Name")
  local towerName = towerCfg.positionName
  GUIUtils.SetText(Label_Name, string.format("[b]%s[/b]", towerName))
  local bundlePath = GetIconPath(iconId)
  if bundlePath ~= "" then
    GameUtil.AsyncLoad(bundlePath, function(ass)
      if go.isnil then
        return
      end
      local tex2d = GUIUtils.ConvertTexture2DAssets(ass)
      if tex2d then
        local uiTexture = go:GetComponent("UITexture")
        uiTexture:set_mainTexture(tex2d)
        uiTexture:MakePixelPerfect()
        local padding = 5
        local offsetY = tex2d.height / 2 + padding
        Img_Name.localPosition = Vector.Vector3.new(0, offsetY, 0)
        local padding2 = 5
        local offsetY2 = -(tex2d.height / 2 + padding2)
        Label_Name.localPosition = Vector.Vector3.new(0, offsetY2, 0)
      end
    end)
  end
  local templatePos = self.m_towerPos[flagInfo.id]
  if templatePos then
    go.localPosition = templatePos
  end
end
def.method("function").AsyncCreateTemplateGO = function(self, callback)
  local go = GameObject.GameObject("MapFlag_Template")
  go:SetLayer(ClientDef_Layer.UI)
  local uiTexture = go:AddComponent("UITexture")
  uiTexture.width = 50
  uiTexture.height = 50
  uiTexture.depth = MiniMapPanel.Depths.bf_flag_img
  go.parent = self.m_miniMap.m_panel
  go.localScale = Vector.Vector3.one
  local Img_Name = GameObject.GameObject("Img_Name")
  Img_Name:SetLayer(ClientDef_Layer.UI)
  Img_Name.parent = go
  local uiSprite = Img_Name:AddComponent("UISprite")
  Img_Name.localPosition = Vector.Vector3.new(0, 40, 0)
  Img_Name.localScale = Vector.Vector3.one
  uiSprite.depth = MiniMapPanel.Depths.bf_flag_name
  local templateLabel = self.m_miniMap.uiObjs.Label_NPC:GetComponent("UILabel")
  local Label_Name = GameObject.GameObject("Label_Name")
  Label_Name:SetLayer(ClientDef_Layer.UI)
  Label_Name.parent = go
  Label_Name.localPosition = Vector.Vector3.new(0, -40, 0)
  Label_Name.localScale = Vector.Vector3.one
  local uiLabel = Label_Name:AddComponent("UILabel")
  uiLabel.depth = MiniMapPanel.Depths.bf_flag_name
  uiLabel.trueTypeFont = templateLabel.trueTypeFont
  uiLabel.overflowMethod = templateLabel.overflowMethod
  uiLabel.fontSize = 16
  uiLabel.effectStyle = Effect.Outline
  uiLabel.effectColor = Color.black
  uiLabel.textColor = Color.Color(1, 0.82, 0.29, 1)
  uiLabel.supportEncoding = true
  GameUtil.AsyncLoad(RESPATH.BATTLEFIELD_ATLAS, function(obj)
    if obj == nil then
      return
    end
    local atlas = obj:GetComponent("UIAtlas")
    if uiSprite == nil or uiSprite.isnil then
      return
    end
    uiSprite:set_atlas(atlas)
    callback(go)
  end)
end
def.method("=>", "table").GetAllFlagInfo = function(self)
  return CTFFeature.Instance():GetAllFlagInfo()
end
def.method("table").OnTowerStateChange = function(self, params)
  self:UpdateAllFlags()
end
return BattlefieldMapFlagMgr.Commit()
