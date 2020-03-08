local FILE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIPetsArenaReady = Lplus.Extend(ECPanelBase, FILE_NAME)
local Cls = UIPetsArenaReady
local def = Cls.define
local instance
local txtConst = textRes.Pet.PetsArena
local const = constant.CPetArenaConst
local GUIUtils = require("GUI.GUIUtils")
local PetsArenaUtils = require("Main.Pet.PetsArena.PetsArenaUtils")
local PetsArenaMgr = require("Main.Pet.PetsArena.PetsArenaMgr")
local PetTeamData = require("Main.PetTeam.data.PetTeamData")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
def.field("table")._uiGOs = nil
def.field("table")._uiStatus = nil
def.field("table")._opponentInfo = nil
def.field("table")._myPet2ModelMap = nil
def.field("table")._tarPet2ModelMap = nil
def.field("table")._tarDefenseTeam = nil
def.field("table")._mapTarPetsInfo = nil
def.static("=>", Cls).Instance = function()
  if instance == nil then
    instance = Cls()
  end
  return instance
end
def.method().initUI = function(self)
  self:onShowDropdownList(false)
  local avatarInterface = require("Main.Avatar.AvatarInterface").Instance()
  local uiGOs = self._uiGOs
  _G.SetAvatarIcon(uiGOs.rImgAvatar, avatarInterface:getCurAvatarId() or 0)
  _G.SetAvatarFrameIcon(uiGOs.rImgAvatarFrame, avatarInterface:getCurAvatarFrameId() or 0)
  GUIUtils.SetText(uiGOs.rLblLv, _G.GetHeroProp().level)
end
def.method().initTeamDropdownList = function(self)
  local teamCount = PetsArenaMgr.MAX_TEAM
  self:resizeGridItem(teamCount)
  for i = 1, teamCount do
    local gridItem = self._uiGOs.uiGrid:FindDirect("Btn_Type_" .. i)
    local lblName = gridItem:FindDirect("Label_Name")
    GUIUtils.SetText(lblName, textRes.Pet.PetsArena[4]:format(i))
  end
  self._uiStatus.bDropDownInit = true
end
local Vector = require("Types.Vector3")
def.method("number").resizeGridItem = function(self, gridCount)
  local scrollView = self._uiGOs.pnlDropDown:FindDirect("Group_ChooseType")
  local ctrlGrid = scrollView:FindDirect("Grid")
  self._uiGOs.uiGrid = ctrlGrid
  local comUIGrid = ctrlGrid:GetComponent("UIGrid")
  local gridItemCount = comUIGrid:GetChildListCount()
  if gridCount > gridItemCount then
    for i = gridItemCount + 1, gridCount do
      local gridItem = GameObject.Instantiate(self._uiGOs.gridItemTemplate)
      gridItem.name = "Btn_Type_" .. i
      gridItem.transform.parent = ctrlGrid.transform
      gridItem.transform.localScale = Vector.Vector3.one
      gridItem:SetActive(true)
    end
  elseif gridCount < gridItemCount then
    for i = gridItemCount, gridCount + 1, -1 do
      local gridItem = ctrlGrid:FindDirect("Btn_Type_" .. i)
      if not _G.IsNil(gridItem) then
        gridItem.transform.parent = nil
        GameObject.Destroy(gridItem)
      end
    end
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
  comUIGrid:Reposition()
end
def.method().showOpponentsTeam = function(self)
  self:clearPetModelMap(self._tarPet2ModelMap)
  self._tarPet2ModelMap = {}
  local uiGOs = self._uiGOs
  local modelId = 0
  local bHideFormation = self._opponentInfo.rank <= const.TOP_NUM_HIDE_FORMATION
  if bHideFormation then
    modelId = const.DEFAULT_PET_MODEL_ID
  end
  PetsArenaUtils.ShowTeam(self, self._tarDefenseTeam, uiGOs.tarFormation, uiGOs.lblTarPetTeamScore, self._tarPet2ModelMap, modelId, Cls.GetTarPetInfo, {bIsOpponent = true})
  if self._opponentInfo.rank <= const.TOP_NUM_HIDE_SCORE then
    GUIUtils.SetText(uiGOs.lblTarPetTeamScore, txtConst[22])
  end
  PetsArenaUtils.showFormationInfo(nil, self._tarDefenseTeam, uiGOs.texTarFormation, uiGOs.tarFormation)
  if bHideFormation then
    GUIUtils.SetTexture(uiGOs.texTarFormation, const.FORMATION_UNKONW_ICON)
  end
  local info = self._opponentInfo
  GUIUtils.SetText(uiGOs.lLblLv, info.level or txtConst[1])
  if info.name then
    local Vector = require("Types.Vector")
    if info.roleid:eq(0) then
      GUIUtils.SetTexture(uiGOs.lImgAvatar, const.ROBOT_ICON)
      uiGOs.lImgAvatar.transform.localScale = Vector.Vector3.new(-1, 1, 1)
    else
      uiGOs.lImgAvatar.transform.localScale = Vector.Vector3.new(1, 1, 1)
      _G.SetAvatarIcon(uiGOs.lImgAvatar, info.avatar or 0)
      _G.SetAvatarFrameIcon(uiGOs.lImgAvatarFrame, info.avatar_frame or 0)
    end
  else
    GUIUtils.SetText(lblName, info.name and _G.GetStringFromOcts(info.name) or txtConst[1])
  end
end
def.method().showSelfPetTeam = function(self)
  self:clearPetModelMap(self._myPet2ModelMap)
  self._myPet2ModelMap = {}
  local uiGOs = self._uiGOs
  local teamInfo = PetTeamData.Instance():GetTeamInfo(self._uiStatus.selTeamIdx)
  PetsArenaUtils.ShowTeam(self, teamInfo, uiGOs.myformation, uiGOs.lblSelfPetTeamScore, self._myPet2ModelMap, 0, function(petId)
    return require("Main.Pet.mgr.PetMgr").Instance():GetPet(petId)
  end, nil)
  local formationCfg
  if teamInfo == nil then
    formationCfg = PetTeamData.Instance():GetFormationCfg(constant.CPetFightConsts.DEFAULT_FORMATION_ID)
  end
  PetsArenaUtils.showFormationInfo(formationCfg, teamInfo, uiGOs.texSelfFormation, uiGOs.myformation)
end
def.method().eventsRegister = function(self)
  Event.RegisterEventWithContext(ModuleId.PET, gmodule.notifyId.Pet.GET_TARGET_PETTEAM_OK, Cls.OnGetTargetDefenseTeam, self)
  Event.RegisterEventWithContext(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_TEAM_INFO_CHANGE, Cls.OnPetTeamInfoChg, self)
  Event.RegisterEventWithContext(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_PET_BATTLE, Cls.OnEnterPetFight, self)
  Event.RegisterEventWithContext(ModuleId.PET, gmodule.notifyId.Pet.PETARENA_RANK_CHANGE, Cls.OnPetArenaRankChg, self)
  Event.RegisterEventWithContext(ModuleId.PET, gmodule.notifyId.Pet.OPPONENTS_INFO_CHANGE, Cls.OnOpponentsInfoChg, self)
end
def.method().eventsUnregister = function(self)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.GET_TARGET_PETTEAM_OK, Cls.OnGetTargetDefenseTeam)
  Event.UnregisterEvent(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_TEAM_INFO_CHANGE, Cls.OnPetTeamInfoChg)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_PET_BATTLE, Cls.OnEnterPetFight)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PETARENA_RANK_CHANGE, Cls.OnPetArenaRankChg)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.OPPONENTS_INFO_CHANGE, Cls.OnOpponentsInfoChg)
end
def.override().OnCreate = function(self)
  local opponentInfo = self._opponentInfo
  PetsArenaMgr.GetProtocol().CGetPetDefenseTeam(opponentInfo.roleid, opponentInfo.rank, self._uiStatus.serial or 0)
  self._uiGOs = {}
  local uiGOs = self._uiGOs
  self._uiStatus = self._uiStatus or {}
  self._uiStatus.selTeamIdx = 1
  self._uiStatus.bDropDownInit = false
  self._uiStatus.bSelfTeamDirty = false
  self._uiStatus.bRobot = false
  local modelsRoot = self.m_panel:FindDirect("Img_Bg/Group_Right/Group_Front")
  uiGOs.myformation = {}
  for i = 1, PetsArenaMgr.MAX_MODEL do
    table.insert(uiGOs.myformation, modelsRoot:FindDirect("RGroup_Site_" .. i))
  end
  uiGOs.lblSelfPetTeamScore = self.m_panel:FindDirect("Img_Bg/Group_Right/Group_Info/Label_TeamNum")
  uiGOs.texTarFormation = self.m_panel:FindDirect("Img_Bg/Group_Left/Group_FomationEdit/Texture_FomationL")
  uiGOs.lblTarRoleName = self.m_panel:FindDirect("Img_Bg/Group_Left/Group_TeamName/Label_Name")
  local name = ""
  if self._opponentInfo.roleid:eq(0) then
    name = const.ROBOT_NAME
  else
    name = _G.GetStringFromOcts(self._opponentInfo.name)
  end
  GUIUtils.SetText(uiGOs.lblTarRoleName, name)
  modelsRoot = self.m_panel:FindDirect("Img_Bg/Group_Left/Group_Front")
  uiGOs.tarFormation = {}
  for i = 1, PetsArenaMgr.MAX_MODEL do
    table.insert(uiGOs.tarFormation, modelsRoot:FindDirect("LGroup_Site_" .. i))
  end
  uiGOs.lblTarPetTeamScore = self.m_panel:FindDirect("Img_Bg/Group_Left/Group_Info/Label_TeamNum")
  uiGOs.texSelfFormation = self.m_panel:FindDirect("Img_Bg/Group_Right/Group_FomationEdit/Texture_FomationR")
  local imgHeadRoot = self.m_panel:FindDirect("Img_Bg/Group_Right/Img_BgCharacterR")
  uiGOs.rImgAvatar = imgHeadRoot:FindDirect("Icon_Head")
  uiGOs.rImgAvatarFrame = imgHeadRoot:FindDirect("Icon_BgHead")
  uiGOs.rLblLv = imgHeadRoot:FindDirect("Label_Lv")
  imgHeadRoot = self.m_panel:FindDirect("Img_Bg/Group_Left/Img_BgCharacterL")
  uiGOs.lImgAvatar = imgHeadRoot:FindDirect("Icon_Head")
  uiGOs.lImgAvatarFrame = imgHeadRoot:FindDirect("Icon_BgHead")
  uiGOs.lLblLv = imgHeadRoot:FindDirect("Label_Lv")
  uiGOs.btnTeamChoose = self.m_panel:FindDirect("Img_Bg/Group_Right/Btn_TeamChoose")
  uiGOs.pnlDropDown = self.m_panel:FindDirect("Img_Bg/Group_Right/Btn_TeamChoose/Group_Zone")
  local template = uiGOs.pnlDropDown:FindDirect("Group_ChooseType/Grid/Btn_Type")
  template.name = "Btn_Type_0"
  template:SetActive(false)
  uiGOs.gridItemTemplate = template
  self:eventsRegister()
  self:initUI()
end
def.override().OnDestroy = function(self)
  self._uiGOs = nil
  self._uiStatus = nil
  self._opponentInfo = nil
  self:clearPetModelMap(self._myPet2ModelMap)
  self._myPet2ModelMap = nil
  self:clearPetModelMap(self._tarPet2ModelMap)
  self._tarPet2ModelMap = nil
  self._tarDefenseTeam = nil
  self:eventsUnregister()
end
def.override("boolean").OnShow = function(self, bShow)
  if not bShow then
    return
  end
  self:showSelfPetTeam()
  if self._tarPet2ModelMap then
    self:showOpponentsTeam()
  end
end
def.method("table", "table").ShowPanel = function(self, opponentInfo, extraInfo)
  if self:IsShow() then
    return
  end
  if opponentInfo == nil then
    warn("[ERROR] Params opponent info is nil")
    return
  end
  self._uiStatus = {}
  self._uiStatus.serial = extraInfo.serial
  self._opponentInfo = opponentInfo
  self:CreatePanel(RESPATH.PREFAB_PETS_ARENA_READY, 1)
  self:SetModal(true)
end
def.method("table").updatePetsTeam = function(self, teamInfo)
end
def.method("table").clearPetModelMap = function(self, pet2ModelMap)
  if pet2ModelMap == nil then
    return
  end
  for key, model in pairs(pet2ModelMap) do
    model:Destroy()
    model = nil
  end
end
local PetData = require("Main.Pet.data.PetData")
local RobotPetData = require("Main.Pet.PetsArena.data.RobotPetData")
def.method("table", "boolean").SetPetsList = function(self, petTable, bRobot)
  self._uiStatus.bRobot = bRobot
  self._mapTarPetsInfo = {}
  if bRobot then
    local PetInterface = require("Main.Pet.Interface")
    for petid, robot in pairs(petTable) do
      local robotPetData = RobotPetData()
      robotPetData:RawSet(robot)
      self._mapTarPetsInfo[tostring(petid)] = robotPetData
    end
  else
    for k, pet in pairs(petTable) do
      local petData = PetData()
      petData:RawSet(pet)
      self._mapTarPetsInfo[tostring(petData.id)] = petData
    end
  end
end
def.static("userdata", "=>", "table", "boolean").GetTarPetInfo = function(petId)
  if instance._mapTarPetsInfo then
    return instance._mapTarPetsInfo[petId:tostring()], instance._uiStatus.bRobot
  else
    return nil, false
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  local bShowDropdown = false
  if "Btn_Start" == id then
    self:onClickStartFight()
  elseif "Btn_ChangePet" == id then
    self:onClickChangeTeam()
  elseif "Btn_TeamChoose" == id then
    bShowDropdown = clickObj:GetComponent("UIToggleEx").value
  elseif "Btn_Close" == id then
    self:DestroyPanel()
  elseif "Texture_FomationL" == id then
    if self._opponentInfo.rank > const.TOP_NUM_HIDE_FORMATION then
      self:showFormationTips(clickObj, self._tarDefenseTeam, {
        formationLv = self._opponentInfo.formationLv
      })
    end
  elseif "Texture_FomationR" == id then
    local teamInfo = PetTeamData.Instance():GetTeamInfo(self._uiStatus.selTeamIdx)
    self:showFormationTips(clickObj, teamInfo, nil)
  elseif string.find(id, "Btn_Type_") then
    local strs = string.split(id, "_")
    local idx = tonumber(strs[3])
    self._uiStatus.selTeamIdx = idx
    self:showSelfPetTeam()
  elseif string.find(id, "RGroup_Site_") then
    local idx = tonumber(string.split(id, "_")[3])
    self:onClickPetModel(idx, clickObj)
  elseif string.find(id, "LGroup_Site_") then
    local idx = tonumber(string.split(id, "_")[3])
    self:onClickOpponentUIModel(idx, clickObj)
  end
  self:onShowDropdownList(bShowDropdown)
end
def.method().onClickStartFight = function(self)
  local myFightTeam = PetTeamData.Instance():GetTeamInfo(self._uiStatus.selTeamIdx)
  local countPets = myFightTeam and myFightTeam:GetPetCount() or 0
  warn("self._uiStatus.serial", self._uiStatus.serial)
  if countPets > 0 then
    do
      local tarTeamInfo = self._opponentInfo
      if countPets < 5 then
        CommonConfirmDlg.ShowConfirm(txtConst[24], txtConst[25], function(select)
          if select ~= 1 then
            return
          end
          PetsArenaMgr.GetProtocol().CSendStartPetsFight(tarTeamInfo.roleid, tarTeamInfo.rank, myFightTeam.teamIdx, self._uiStatus.serial)
        end, nil)
      else
        PetsArenaMgr.GetProtocol().CSendStartPetsFight(tarTeamInfo.roleid, tarTeamInfo.rank, myFightTeam.teamIdx, self._uiStatus.serial)
      end
    end
  else
    Toast(txtConst[29])
  end
end
def.method().onClickChangeTeam = function(self)
  require("Main.PetTeam.ui.PetTeamPanel").ShowPanel()
end
def.method("number", "userdata").onClickPetModel = function(self, idx, clickObj)
  local myFightTeam = PetTeamData.Instance():GetTeamInfo(self._uiStatus.selTeamIdx)
  PetsArenaUtils.ShowNormalPetTips(myFightTeam, idx, clickObj, nil)
end
def.method("number", "userdata").onClickOpponentUIModel = function(self, idx, clickObj)
  if self._uiStatus.bRobot then
    PetsArenaUtils.ShowRobotPetTips(self._tarDefenseTeam, idx, self._mapTarPetsInfo, clickObj, {
      rank = self._opponentInfo.rank
    })
  else
    local opponentTeamInfo = self._tarDefenseTeam
    PetsArenaUtils.ShowNormalPetTips(opponentTeamInfo, idx, clickObj, {
      rank = self._opponentInfo.rank,
      mapPetsInfo = self._mapTarPetsInfo
    })
  end
end
def.method("boolean").onShowDropdownList = function(self, bShow)
  if self._uiGOs == nil then
    return
  end
  self._uiGOs.pnlDropDown:SetActive(bShow)
  self._uiGOs.btnTeamChoose:GetComponent("UIToggleEx").value = bShow
  local i = self._uiStatus.selTeamIdx
  GUIUtils.SetText(self._uiGOs.btnTeamChoose:FindDirect("Label_Btn"), textRes.Pet.PetsArena[4]:format(i))
  if bShow and not self._uiStatus.bDropDownInit then
    self:initTeamDropdownList()
  end
end
def.method("userdata", "table", "table").showFormationTips = function(self, clickObj, teamInfo, extraInfo)
  if teamInfo == nil then
    return
  end
  require("Main.Pet.PetsArena.ui.PetsFomationTips").ShowPetsTipsWithGO(clickObj, 0, teamInfo, extraInfo)
end
def.method("table").OnGetTargetDefenseTeam = function(self, p)
  self._opponentInfo.rank = p.rank
  self._opponentInfo.formationLv = p.team_info.formation_level
  local teamInfo = p.team_info
  local PetTeamInfo = require("Main.PetTeam.data.PetTeamInfo")
  local pos2PetMap = {}
  for pos, petInfo in pairs(teamInfo.position_infos) do
    pos2PetMap[pos] = petInfo.petid
  end
  self._tarDefenseTeam = PetTeamInfo.New(0, teamInfo.formation, pos2PetMap)
  if p.target_roleid:eq(0) then
    self:SetPetsList(teamInfo.robot_infos, true)
  else
    self:SetPetsList(teamInfo.pet_infos, false)
  end
  self:showOpponentsTeam()
end
def.method("table").OnPetTeamInfoChg = function(self, p)
  if self:IsShow() then
    self:showSelfPetTeam()
  else
    self._uiStatus.bSelfTeamDirty = p.teamIdx == self._uiStatus.selTeamIdx
  end
end
def.method("table").OnEnterPetFight = function(self, p)
  self:DestroyPanel()
end
def.method("table").OnPetArenaRankChg = function(self, p)
  self:DestroyPanel()
end
def.method("table").OnOpponentsInfoChg = function(self, p)
  self:DestroyPanel()
end
return Cls.Commit()
