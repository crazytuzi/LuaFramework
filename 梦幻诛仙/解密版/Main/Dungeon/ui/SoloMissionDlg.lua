local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SoloMissionDlg = Lplus.Extend(ECPanelBase, "SoloMissionDlg")
local DungeonUtils = require("Main.Dungeon.DungeonUtils")
local DungeonModule = require("Main.Dungeon.DungeonModule")
local GUIUtils = require("GUI.GUIUtils")
local MathHelper = require("Common.MathHelper")
local UIModelWrap = require("Model.UIModelWrap")
local def = SoloMissionDlg.define
local _instance
def.field("number").dungeonId = 0
def.field("number").processId = 0
def.field("number").canDo = 0
def.field("boolean").created = false
def.field("table").tmpProtocol = nil
def.field(UIModelWrap).modelWrap = nil
def.static("=>", SoloMissionDlg).Instance = function()
  if _instance == nil then
    _instance = SoloMissionDlg()
    _instance.m_TrigGC = true
  end
  return _instance
end
def.static("number", "number", "number").ShowMission = function(dungeonId, processId, canDo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.instance.SSingleInfoRes", SoloMissionDlg.onSingleInfoRes)
  local dlg = SoloMissionDlg.Instance()
  dlg:DestroyPanel()
  dlg.dungeonId = dungeonId
  dlg.processId = processId
  dlg.canDo = canDo
  dlg:CreatePanel(RESPATH.PREFAB_DUNGEON_MISSION, 2)
  dlg.tmpProtocol = nil
  dlg.created = false
  local singleMissionInfo = require("netio.protocol.mzm.gsp.instance.CSingleInfoReq").new(dungeonId, processId)
  gmodule.network.sendProtocol(singleMissionInfo)
end
def.static("table").onSingleInfoRes = function(p)
  if _instance and _instance.created then
    _instance:SetDynamicInfo(p)
  else
    _instance.tmpProtocol = p
  end
end
def.override().OnCreate = function(self)
  self:SetStaticInfo()
  self:HideDynamicInfo()
  self.created = true
  if self.tmpProtocol then
    _instance:SetDynamicInfo(self.tmpProtocol)
    self.tmpProtocol = nil
  end
end
def.override().OnDestroy = function(self)
  self.modelWrap:Destroy()
  self.modelWrap = nil
  self.created = false
  self.tmpProtocol = nil
end
def.method().SetStaticInfo = function(self)
  local missionCfg = DungeonUtils.GetOneSoloDungeonCfg(self.dungeonId, self.processId)
  if missionCfg ~= nil then
    local uiTexture = self.m_panel:FindDirect("Img_Bg/MonsterTexture")
    local uiModel = self.m_panel:FindDirect("Img_Bg/MonsterModel"):GetComponent("UIModel")
    uiModel:set_orthographic(true)
    if self.modelWrap then
      self.modelWarp:Destroy()
    end
    self.modelWrap = UIModelWrap.new(uiModel)
    local titleName = self.m_panel:FindDirect("Img_Bg/Label_GuanKaName"):GetComponent("UILabel")
    local desc = self.m_panel:FindDirect("Img_Bg/Label_GuanKaTips"):GetComponent("UILabel")
    local monsterCfg = DungeonUtils.GetDungeonMonsterCfg(missionCfg.monsterId)
    if monsterCfg and monsterCfg.halfIcon and monsterCfg.halfIcon > 0 then
      self:SetTexureOrModel(uiTexture, self.modelWrap, monsterCfg.halfIcon)
    end
    local bossFlag = self.m_panel:FindDirect("Img_Bg/Img_Boss")
    local MissionType = require("consts.mzm.gsp.instance.confbean.ProcessType")
    bossFlag:SetActive(missionCfg.type == MissionType.BOSS)
    titleName:set_text(string.format(textRes.Dungeon[2], MathHelper.Arabic2Chinese(self.processId), missionCfg.name))
    desc:set_text(missionCfg.desc)
    local fightBtn = self.m_panel:FindDirect("Img_Bg/Btn_Fight")
    local descLabel = self.m_panel:FindDirect("Img_Bg/Label_Bottom")
    if self.canDo == 1 then
      fightBtn:SetActive(false)
      descLabel:GetComponent("UILabel"):set_text(textRes.Dungeon[9])
    elseif self.canDo == 0 then
      fightBtn:SetActive(true)
      descLabel:SetActive(false)
    elseif self.canDo == -1 then
      fightBtn:SetActive(false)
      descLabel:SetActive(true)
      descLabel:GetComponent("UILabel"):set_text(textRes.Dungeon[31])
    elseif self.canDo == -2 then
      fightBtn:SetActive(false)
      descLabel:SetActive(true)
      descLabel:GetComponent("UILabel"):set_text(textRes.Dungeon[32])
    end
  end
end
def.method().HideDynamicInfo = function(self)
  local btnClean = self.m_panel:FindDirect("Img_Bg/Btn_Clean")
  local times = self.m_panel:FindDirect("Img_Bg/Group_Slider")
  btnClean:SetActive(false)
  times:SetActive(false)
  local bestInfo = self.m_panel:FindDirect("Img_Bg/Img_BgInfo/Group_1")
  bestInfo:SetActive(false)
  local myTime = self.m_panel:FindDirect("Img_Bg/Img_BgInfo/Group_2/Label_Time"):GetComponent("UILabel")
  myTime:set_text(textRes.Dungeon[3])
end
def.method("table").SetDynamicInfo = function(self, info)
  if self.m_panel == nil then
    return
  end
  local btnClean = self.m_panel:FindDirect("Img_Bg/Btn_Clean")
  local times = self.m_panel:FindDirect("Img_Bg/Group_Slider")
  local desc = self.m_panel:FindDirect("Img_Bg/Label_Bottom")
  local myTime = self.m_panel:FindDirect("Img_Bg/Img_BgInfo/Group_2/Label_Time"):GetComponent("UILabel")
  local second = info.second
  local successTimes = info.sucTimes
  local saodangTime = DungeonUtils.GetDungeonConst().SaoDangLimit
  local saodangItemId = DungeonUtils.GetDungeonConst().SaoDangQuanId
  if successTimes > 0 then
    myTime:set_text(string.format(textRes.Dungeon[4], second))
  else
    myTime:set_text(textRes.Dungeon[3])
  end
  btnClean:SetActive(false)
  times:SetActive(false)
  return
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
    self = nil
  elseif id == "Btn_Fight" then
    DungeonModule.Instance().soloMgr:FightMonster(self.dungeonId, self.processId)
    self:DestroyPanel()
    self = nil
  end
end
def.method("userdata", UIModelWrap, "number").SetTexureOrModel = function(self, texture, modelWrap, halfIconId)
  local iconRecord = DynamicData.GetRecord(CFG_PATH.DATA_ICONRES, halfIconId)
  if iconRecord == nil then
    print("Icon res get nil record for id: ", halfIconId)
    texture:SetActive(false)
    modelWrap:Destroy()
    return
  end
  local resourceType = iconRecord:GetIntValue("iconType")
  if resourceType == 1 then
    texture:SetActive(false)
    local resourcePath = iconRecord:GetStringValue("path")
    if resourcePath and resourcePath ~= "" then
      modelWrap:Load(resourcePath .. ".u3dext")
    else
      warn("Resource path is nil: " .. halfIconId)
    end
  else
    texture:SetActive(true)
    modelWrap:Destroy()
    local uiTexture = texture:GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, halfIconId)
  end
end
SoloMissionDlg.Commit()
return SoloMissionDlg
