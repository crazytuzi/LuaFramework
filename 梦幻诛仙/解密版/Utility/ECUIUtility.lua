local Lplus = require("Lplus")
local AtlasMan = require("GUI.AtlasMan")
local ElementData = require("Data.ElementData")
local ECPlayerSkillDesc = require("Skill.ECPlayerSkillDesc")
local Exptypes = require("Data.Exptypes")
local NPCServiceEvents = require("Event.NPCServiceEvents")
local ECGame = require("Main.ECGame")
local ECPanelBase = require("GUI.ECPanelBase")
local HtmlUtility = require("Utility.HtmlUtility")
local DynamicText = require("Utility.DynamicText")
local ECGUITools = require("GUI.ECGUITools")
local EC = require("Types.Vector3")
local GcCallbacks = require("Utility.GcCallbacks")
local ECUIUtility = Lplus.Class("ECUIUtility")
do
  local def = ECUIUtility.define
  local function GetEssenceName(tid, whatType)
    local data, datatype = ElementData.getEssence(tid)
    if data then
      if datatype == DT_EQUIPMENT_ESSENCE then
        return data.names[data.common_prop.quality]
      else
        return data.name
      end
    else
      return "unknown " .. whatType .. " tid(" .. tid .. ")"
    end
  end
  def.static("number", "=>", "string").FormatMonsterName = function(monsterTid)
    return GetEssenceName(monsterTid, "monster")
  end
  def.static("number", "=>", "string").FormatItemName = function(itemTid)
    return GetEssenceName(itemTid, "item")
  end
  def.static("userdata", "string").SetIcon = function(sprite, imagePath)
    ECGUITools.UpdateGridImage(imagePath, sprite)
  end
  def.static("userdata").ClearIcon = function(sprite, imagePath)
    sprite.atlas = nil
  end
  def.static("userdata", "number").SetIconByPathId = function(sprite, pathId)
    local imagePath = pathId == 0 and "" or datapath.GetPathByID(pathId)
    if imagePath ~= "" then
      ECUIUtility.SetIcon(sprite, imagePath)
    else
      ECUIUtility.ClearIcon(sprite)
    end
  end
  local DT_EQUIPMENT_ESSENCE = Exptypes.DATA_TYPE.DT_EQUIPMENT_ESSENCE
  def.static("number", "=>", "number").GetIvtrItemIconPathId = function(tid)
    local data, datatype = ElementData.getEssence(tid)
    if not data then
      return 0
    end
    if datatype == DT_EQUIPMENT_ESSENCE then
      return data.file_icons[data.common_prop.quality]
    else
      return data.common_prop.file_icon
    end
  end
  def.static("userdata", "number").SetIvtrItemIcon = function(sprite, ivtrItemID)
    if ivtrItemID ~= 0 then
      local iconPathId = ECUIUtility.GetIvtrItemIconPathId(ivtrItemID)
      ECUIUtility.SetIconByPathId(sprite, iconPathId)
    else
      ECUIUtility.ClearIcon(sprite)
    end
  end
  def.static("userdata", "number").SetSkillIcon = function(sprite, skillId)
    if skillId ~= 0 then
      local icon = ECPlayerSkillDesc.GetIcon(skillId)
      ECUIUtility.SetIconByPathId(sprite, icon)
    else
      ECUIUtility.ClearIcon(sprite)
    end
  end
  def.static("userdata", "number").SetSkillCooldownIcon = function(sprite, skillId)
    ECUIUtility.SetSkillIcon(sprite, skillId)
  end
  def.static("userdata", "number").SetSkillStatusIcon = function(sprite, statusId)
    if statusId ~= 0 then
      local descData = ECPlayerSkillDesc.GetStatusDescData(statusId)
      ECUIUtility.SetIconByPathId(sprite, descData.icon)
    else
      ECUIUtility.ClearIcon(sprite)
    end
  end
  def.static("number", "=>", "string").FormatTimeSpan_OneOrTwoFrac = function(timespanSec)
    return ECUIUtility.FormatTimeSpan_OneOrTwoFracWithOneDecimal(timespanSec, 0)
  end
  local formats = {
    601,
    602,
    603,
    604,
    0
  }
  local bIsSec = {
    false,
    false,
    false,
    true,
    false
  }
  def.static("number", "number", "=>", "string").FormatTimeSpan_OneOrTwoFracWithOneDecimal = function(timespanSec, msFraction)
    local values = {
      math.floor(timespanSec / 86400),
      math.floor(timespanSec % 86400 / 3600),
      math.floor(timespanSec % 3600 / 60),
      math.floor(timespanSec % 60),
      0
    }
    local format_fsec = 605
    for i = 1, #values do
      local valueOne = values[i]
      local valueTwo = values[i + 1]
      local formatOne = formats[i]
      local formatTwo = formats[i + 1]
      if valueOne > 0 or i + 2 > #values then
        if valueTwo == 0 then
          if bIsSec[i] and msFraction ~= 0 then
            return StringTable.Get(format_fsec):format(valueOne + msFraction / 1000)
          else
            return StringTable.Get(formatOne):format(valueOne)
          end
        else
          return StringTable.Get(formatOne):format(valueOne) .. StringTable.Get(formatTwo):format(valueTwo)
        end
      end
    end
    error("should not be here")
  end
  def.static(ECPanelBase).ClosePanelOnNPCServiceEnd = function(panel)
    ECGame.EventManager:addHandler(NPCServiceEvents.NPCServiceEndEvent, function(sender, event)
      panel:DestroyPanel()
    end)
  end
  local function refreshBindMoney(uilabel)
    if uilabel and not uilabel.isnil then
      local money = ECGame.Instance().m_HostPlayer.Package.NormalPack.BindMoney
      uilabel.text = ECGUITools.SetMoneyString(money)
    end
  end
  def.static("userdata", GcCallbacks).AutoRefreshBindMoney = function(uilabel, cleaner)
    refreshBindMoney(uilabel)
    local NotifyMoneyChange = require("Event.NotifyMoneyChange")
    ECGame.EventManager:addHandlerWithCleaner(NotifyMoneyChange, function(sender, event)
      if event.money_type == GP_MONEY_TYPE.GPMONEYTYPE_BIND then
        refreshBindMoney(uilabel)
      end
    end, cleaner)
  end
  def.static("string", "=>", "string").DynamicTextToNguiText = function(dynamicText)
    return HtmlUtility.HtmlToNguiText(DynamicText.compileWithGameInfo(dynamicText)())
  end
  def.static("string", "=>", "string").DynamicTextToPath = function(dynamicText)
    local str = DynamicText.compileWithGameInfo(dynamicText)()
    local path_id = tonumber(str)
    if path_id then
      return datapath.GetPathByID(path_id)
    else
      return str
    end
  end
  def.static("string", ECPanelBase, "userdata").AddSelfDestroyObject = function(filepath, panel, parentobj)
    GameUtil.AsyncLoad(filepath, function(ass)
      if not ass or panel == nil or parentobj == nil or panel.m_panel == nil then
      else
        local oldgo = parentobj:FindChild("selfdestoryobject")
        if oldgo then
          Object.Destory(oldgo)
        end
        local go = Object.Instantiate(ass, "GameObject")
        go.name = "selfdestoryobject"
        go.parent = parentobj
        go.localScale = EC.Vector3.one
        go.localPosition = EC.Vector3.zero
      end
    end)
  end
  def.static("string", ECPanelBase, "userdata", "string", "boolean").AddSelfDeActiveObject = function(filepath, panel, parentobj, name, singleton)
    GameUtil.AsyncLoad(filepath, function(ass)
      if not ass or panel == nil or parentobj == nil or panel.m_panel == nil then
      else
        local go
        if singleton then
          go = parentobj:FindChild(name)
        end
        if not go then
          go = Object.Instantiate(ass, "GameObject")
          go.parent = parentobj
          go.name = name
          go.localScale = EC.Vector3.one
          go.localPosition = EC.Vector3.zero
        end
        if go then
          go:SetActive(true)
        end
      end
    end)
  end
  def.static("string", "function", "function").PopupPanel = function(respath, onCreate, onClickObj)
    local Panel = Lplus.Extend(ECPanelBase)
    do
      local def = Panel.define
      def.override().OnCreate = function(self)
        if onCreate then
          onCreate(self)
        end
      end
      def.method("userdata").onClickObj = function(self, obj)
        if onClickObj then
          onClickObj(self, obj)
        end
      end
    end
    Panel.Commit()
    Panel():CreatePanel(respath)
  end
  def.static("string").PopupSimplePanel = function(respath)
    ECUIUtility.PopupPanel(respath, nil, function(self, obj)
      if obj.name == "Btn_Close" then
        self:DestroyPanel()
      end
    end)
  end
end
return ECUIUtility.Commit()
