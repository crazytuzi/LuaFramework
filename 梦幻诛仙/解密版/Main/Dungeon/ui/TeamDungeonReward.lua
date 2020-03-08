local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TeamDungeonReward = Lplus.Extend(ECPanelBase, "TeamDungeonReward")
local DungeonUtils = require("Main.Dungeon.DungeonUtils")
local DungeonModule = require("Main.Dungeon.DungeonModule")
local GUIUtils = require("GUI.GUIUtils")
local MathHelper = require("Common.MathHelper")
local def = TeamDungeonReward.define
local _instance
def.field("number").WAITTIME = 15
def.field("userdata").uuid = nil
def.field("number").showItemId = 0
def.field("table").roles = nil
def.field("table").id2role = nil
def.field("number").allTimer = 0
def.field("number").tickTimer = 0
def.field("number").rollTimer = 0
def.field("number").protectTimer = 0
def.field("boolean").finish = true
def.field("number").rollRes = 0
def.static("=>", TeamDungeonReward).Instance = function()
  if _instance == nil then
    _instance = TeamDungeonReward()
    _instance.WAITTIME = DungeonUtils.GetDungeonConst().RollTime
  end
  return _instance
end
def.static("userdata", "number", "table").ShowReward = function(uuid, itemId, roles)
  local dlg = TeamDungeonReward.Instance()
  dlg.uuid = uuid
  dlg.showItemId = itemId
  dlg.roles = roles
  dlg.rollRes = 0
  if dlg.m_panel then
    dlg:Init()
  else
    dlg:CreatePanel(RESPATH.PREFAB_DUNGEON_AWRAD, 1)
    dlg:SetModal(true)
  end
  dlg.finish = false
end
def.override().OnCreate = function(self)
  self:Init()
end
def.override().OnDestroy = function(self)
  if self.allTimer ~= 0 then
    local DungeonModule = require("Main.Dungeon.DungeonModule")
    local RollType = require("netio.protocol.mzm.gsp.instance.CGetOrRefuseItemReq")
    DungeonModule.Instance().teamMgr:RollItem(self.uuid, self.showItemId, RollType.GET)
  end
  GameUtil.RemoveGlobalTimer(self.allTimer)
  self.allTimer = 0
  GameUtil.RemoveGlobalTimer(self.tickTimer)
  self.tickTimer = 0
  GameUtil.RemoveGlobalTimer(self.rollTimer)
  self.rollTimer = 0
  GameUtil.RemoveGlobalTimer(self.protectTimer)
  self.protectTimer = 0
  self.finish = true
end
def.method().Init = function(self)
  self:SetItem()
  self:SetSlider()
  self:SetRoles()
  self:SetBtnInit()
  self:SetDefaultOperation()
end
def.method().SetItem = function(self)
  if self.showItemId > 0 then
    local itemBase = require("Main.Item.ItemUtils").GetItemBase(self.showItemId)
    local itemTex = self.m_panel:FindDirect("Img_Bg/Img_ItemBg/Img_ItemIcon/Texture_Icon"):GetComponent("UITexture")
    GUIUtils.FillIcon(itemTex, itemBase.icon)
    local itemName = self.m_panel:FindDirect("Img_Bg/Img_ItemBg/Label_ItemNum"):GetComponent("UILabel")
    itemName:set_text(itemBase.name)
  end
end
def.method().SetSlider = function(self)
  local note = self.m_panel:FindDirect("Img_Bg/Img_Slider/Label_Time"):GetComponent("UILabel")
  local second = self.WAITTIME
  note:set_text(string.format(textRes.Dungeon[36], second))
  self.tickTimer = GameUtil.AddGlobalTimer(1, false, function()
    if second > 0 then
      second = second - 1
      if second > 3 then
        note:set_text(string.format(textRes.Dungeon[36], second))
      else
        note:set_text(string.format(textRes.Dungeon[37], second))
      end
    else
      GameUtil.RemoveGlobalTimer(self.tickTimer)
      self.tickTimer = 0
    end
  end)
end
def.method().SetRoles = function(self)
  self.id2role = {}
  local roleRoot = self.m_panel:FindDirect("Img_Bg/Group_TeamMember")
  for i = 1, 5 do
    local roleData = self.roles[i]
    local role = roleRoot:FindDirect(string.format("Member%d", i))
    if roleData == nil then
      role:SetActive(false)
    else
      role:SetActive(true)
      local name = role:FindDirect("Label_Name"):GetComponent("UILabel")
      name:set_text(roleData.roleName)
      local head = role:FindDirect("Img_Head")
      SetAvatarIcon(head, roleData.avatarid)
      SetAvatarFrameIcon(role, roleData.avatar_frame_id)
      local occupationSpriteName = GUIUtils.GetOccupationSmallIcon(roleData.occupation)
      local occupationSprite = role:FindDirect("Img_School"):GetComponent("UISprite")
      occupationSprite:set_spriteName(occupationSpriteName)
      local genderSprite = role:FindDirect("Img_Sex"):GetComponent("UISprite")
      genderSprite:set_spriteName(GUIUtils.GetGenderSprite(roleData.gender))
      local gray = role:FindDirect("Img_Gray")
      gray:SetActive(false)
      local stateLabel = role:FindDirect("Label_State"):GetComponent("UILabel")
      stateLabel:set_text("")
      self.id2role[roleData.roleid:tostring()] = role
    end
  end
end
def.method().SetBtnInit = function(self)
  local need = self.m_panel:FindDirect("Img_Bg/Group_Need")
  local giveup = self.m_panel:FindDirect("Img_Bg/Group_GiveUp")
  local btns = self.m_panel:FindDirect("Img_Bg/Group_Btn")
  need:SetActive(false)
  giveup:SetActive(false)
  btns:SetActive(true)
end
def.method("table").SetRoleRes = function(self, rollRes)
  local uuid = rollRes.awardUuid
  if self.uuid == uuid then
    local role = self.id2role[rollRes.roleid:tostring()]
    local code = rollRes.code
    local stateLabel = role:FindDirect("Label_State"):GetComponent("UILabel")
    if code >= 0 then
      stateLabel:set_text(code)
    else
      stateLabel:set_text(textRes.Dungeon[13])
      role:FindDirect("Img_Gray"):SetActive(true)
    end
    if require("Main.Hero.HeroModule").Instance().roleId == rollRes.roleid then
      self.m_panel:FindDirect("Img_Bg/Group_Btn"):SetActive(false)
      if code >= 0 then
        self.rollRes = code
      else
        self.m_panel:FindDirect("Img_Bg/Group_GiveUp"):SetActive(true)
      end
    end
  end
end
def.method("table").SetFinalRes = function(self, res)
  if res.awardUuid == self.uuid then
    local role = self.id2role[res.roleid:tostring()]
    require("Fx.GUIFxMan").Instance():PlayAsChild(role, RESPATH.QUESTION_AWARD, 0, 0, -1, false)
  end
  GameUtil.RemoveGlobalTimer(self.allTimer)
  self.allTimer = 0
  GameUtil.RemoveGlobalTimer(self.tickTimer)
  self.tickTimer = 0
  GameUtil.AddGlobalTimer(2, true, function()
    GameUtil.RemoveGlobalTimer(self.rollTimer)
    self.rollTimer = 0
    self:DestroyPanel()
  end)
end
def.method().SetDefaultOperation = function(self)
  self.allTimer = GameUtil.AddGlobalTimer(self.WAITTIME, true, function()
    if self.m_panel and not self.m_panel.isnil then
      self:onClick("Btn_Need")
    end
  end)
  self.protectTimer = GameUtil.AddGlobalTimer(self.WAITTIME + 8, true, function()
    self:DestroyPanel()
  end)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Need" then
    GameUtil.RemoveGlobalTimer(self.allTimer)
    self.allTimer = 0
    self.m_panel:FindDirect("Img_Bg/Group_Btn"):SetActive(false)
    do
      local need = self.m_panel:FindDirect("Img_Bg/Group_Need")
      need:SetActive(true)
      local rollRes = need:FindDirect("Label_Num"):GetComponent("UILabel")
      self.rollTimer = GameUtil.AddGlobalTimer(0.1, false, function()
        if self.rollRes > 0 then
          rollRes:set_text(tostring(self.rollRes))
          GameUtil.RemoveGlobalTimer(self.rollTimer)
          self.rollTimer = 0
        else
          local roll = math.random(100)
          rollRes:set_text(roll)
        end
      end)
      GameUtil.AddGlobalTimer(1, true, function()
        local DungeonModule = require("Main.Dungeon.DungeonModule")
        local RollType = require("netio.protocol.mzm.gsp.instance.CGetOrRefuseItemReq")
        DungeonModule.Instance().teamMgr:RollItem(self.uuid, self.showItemId, RollType.GET)
      end)
    end
  elseif id == "Btn_GiveUp" then
    GameUtil.RemoveGlobalTimer(self.allTimer)
    self.allTimer = 0
    local DungeonModule = require("Main.Dungeon.DungeonModule")
    local RollType = require("netio.protocol.mzm.gsp.instance.CGetOrRefuseItemReq")
    DungeonModule.Instance().teamMgr:RollItem(self.uuid, self.showItemId, RollType.REFUSE)
  elseif id == "Img_ItemIcon" then
    local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
    local source = self.m_panel:FindDirect("Img_Bg/Img_ItemBg/" .. id)
    local position = source:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local widget = source:GetComponent("UIWidget")
    ItemTipsMgr.Instance():ShowBasicTips(self.showItemId, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0, false)
  end
end
TeamDungeonReward.Commit()
return TeamDungeonReward
