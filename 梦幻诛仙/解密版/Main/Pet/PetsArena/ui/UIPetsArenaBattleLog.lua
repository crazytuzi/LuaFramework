local FILE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIPetsArenaBattleLog = Lplus.Extend(ECPanelBase, FILE_NAME)
local Cls = UIPetsArenaBattleLog
local def = Cls.define
local instance
local txtConst = textRes.Pet.PetsArena
local GUIUtils = require("GUI.GUIUtils")
def.field("table")._uiGOs = nil
def.field("table")._uiStatus = nil
def.field("table")._fightRecords = nil
def.static("=>", Cls).Instance = function()
  if instance == nil then
    instance = Cls()
  end
  return instance
end
def.method().initUI = function(self)
  local uiList = self.m_panel:FindDirect("Img_Bg0/Group_List/Scrollview/List")
  local records = self._fightRecords or {}
  local countFight = #records
  local ctrlUIList = GUIUtils.InitUIList(uiList, countFight)
  for i = 1, countFight do
    self:fillRecordInfo(ctrlUIList[i], records[i], i)
  end
end
def.method("userdata", "table", "number").fillRecordInfo = function(self, ctrl, info, idx)
  local imgWin = ctrl:FindDirect("Img_Win_" .. idx)
  local imgLose = ctrl:FindDirect("Img_Lose_" .. idx)
  local groupPlayer = ctrl:FindDirect("Group_Player_" .. idx)
  local imgOccup = groupPlayer:FindDirect("Img_MenPai_" .. idx)
  local imgSex = groupPlayer:FindDirect("Img_Sex_" .. idx)
  local lblName = groupPlayer:FindDirect("Label_Name_" .. idx)
  local lblTime = groupPlayer:FindDirect("Label_Time_" .. idx)
  local headRoot = groupPlayer:FindDirect("Img_BgCharacter_" .. idx)
  local imgAvatar = headRoot:FindDirect("Icon_Head_" .. idx)
  local imgAvatarFrame = headRoot:FindDirect("Icon_BgHead_" .. idx)
  imgWin:SetActive(info.is_win == 1)
  imgLose:SetActive(info.is_win ~= 1)
  GUIUtils.SetSprite(imgOccup, GUIUtils.GetOccupationSmallIcon(info.occupation or 0))
  GUIUtils.SetSprite(imgSex, GUIUtils.GetSexIcon(info.gender))
  local name = ""
  local Vector = require("Types.Vector")
  if info.roleid:eq(0) then
    imgAvatar.transform.localScale = Vector.Vector3.new(-1, 1, 1)
    GUIUtils.SetTexture(imgAvatar, constant.CPetArenaConst.ROBOT_ICON)
    name = constant.CPetArenaConst.ROBOT_NAME
  else
    imgAvatar.transform.localScale = Vector.Vector3.new(1, 1, 1)
    _G.SetAvatarIcon(imgAvatar, info.avatar or 0)
    name = _G.GetStringFromOcts(info.name)
  end
  GUIUtils.SetText(lblName, name)
  GUIUtils.SetText(lblTime, self:formatTime(info.fight_time))
  imgAvatar:SetActive(info.avatar ~= nil)
  imgAvatarFrame:SetActive(info.avatar_frame ~= nil)
  _G.SetAvatarFrameIcon(imgAvatarFrame, info.avatar_frame or 0)
  local groupRank = ctrl:FindDirect("Group_MingCi_" .. idx)
  local lblRank = groupRank:FindDirect("Label_MingCi_" .. idx)
  local imgLvUp = groupRank:FindDirect("Img_MingCiUp_" .. idx)
  local imgLvDown = groupRank:FindDirect("Img_MingCiDown_" .. idx)
  if info.new_rank == -1 then
    info.new_rank = constant.CPetArenaConst.ROBOT_NUM + 1
  end
  if info.old_rank == -1 then
    info.old_rank = constant.CPetArenaConst.ROBOT_NUM + 1
  end
  if info.new_rank - info.old_rank == 0 then
    lblRank:SetActive(false)
  else
    lblRank:SetActive(true)
    GUIUtils.SetText(lblRank, math.abs(info.new_rank - info.old_rank))
  end
  imgLvUp:SetActive(info.new_rank < info.old_rank)
  imgLvDown:SetActive(info.new_rank > info.old_rank)
end
def.override().OnCreate = function(self)
  self._uiGOs = {}
  local uiGOs = self._uiGOs
  Event.RegisterEventWithContext(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_PET_BATTLE, Cls.OnEnterPetFight, self)
  Event.RegisterEventWithContext(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_PET_BATTLE, Cls.OnLeavePetFight, self)
end
def.override().OnDestroy = function(self)
  self._uiGOs = nil
  self._uiStatus = nil
  self._fightRecords = nil
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_PET_BATTLE, Cls.OnEnterPetFight)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_PET_BATTLE, Cls.OnLeavePetFight)
end
def.override("boolean").OnShow = function(self, bShow)
  if bShow then
    self:initUI()
  end
end
def.method("table").ShowPanel = function(self, records)
  if self:IsShow() then
    return
  end
  self._fightRecords = records
  self:CreatePanel(RESPATH.PREFAB_PETS_BATTLE_LOG, 0)
  self:SetModal(true)
end
def.method("number", "=>", "string").formatTime = function(self, timeStamp)
  local timeStr = textRes.Common[230]
  local curTime = GetServerTime()
  local diff = curTime - timeStamp
  if diff >= 0 then
    local hours = math.floor(diff / 3600)
    local min = math.floor(diff % 3600 / 60)
    if hours >= 24 and hours <= 720 then
      local days = math.floor(hours / 24)
      timeStr = textRes.Common[231]:format(days)
    elseif hours > 720 then
      timeStr = textRes.Common[231]:format(30)
    elseif hours > 0 then
      timeStr = textRes.Common[232]:format(hours)
    elseif min > 0 then
      timeStr = txtConst[30]:format(min)
    end
  else
    warn("PassTimeDesc Wrong  TimeStamp")
  end
  return timeStr
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if "Btn_Close" == id then
    self:DestroyPanel()
  elseif string.find(id, "Btn_Video_") then
    local strs = string.split(id, "_")
    local idx = tonumber(strs[3])
    self:onClickFightVideo(idx)
  end
end
def.method("number").onClickFightVideo = function(self, idx)
  local fightInfo = self._fightRecords[idx]
  require("Main.Pet.PetsArena.PetsArenaMgr").GetProtocol().CSendWatchVideoReq(fightInfo.recordid)
end
def.method("table").OnEnterPetFight = function(self, p)
  self:Show(false)
end
def.method("table").OnLeavePetFight = function(self, p)
  self:Show(true)
end
return Cls.Commit()
