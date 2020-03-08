local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local OperationXiuLianExp = Lplus.Extend(OperationBase, "OperationXiuLianExp")
local def = OperationXiuLianExp.define
def.field("number").source = 0
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  self.source = source
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if itemBase.itemType == ItemType.XIULIAN_EXP_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local ItemUtils = require("Main.Item.ItemUtils")
  local ItemModule = require("Main.Item.ItemModule")
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  local itemBase = ItemUtils.GetItemBase(item.id)
  if ItemUtils.CheckItemUseCondition(itemBase) == false then
    return true
  end
  local skillBagId
  if self.source ~= ItemTipsMgr.Source.Other then
    local ExerciseSkillMgr = require("Main.Skill.ExerciseSkillMgr")
    skillBagId = ExerciseSkillMgr.Instance():GetDefaultSkillBagId()
  else
    skillBagId = context.skillBagId
  end
  self:UseXiuLianItem(skillBagId, itemKey)
  return false
end
def.override("number", "number", "userdata", "table", "=>", "boolean").OperateAll = function(self, bagId, itemKey, m_panel, context)
  local skillBagId
  if self.source ~= ItemTipsMgr.Source.Other then
    local ExerciseSkillMgr = require("Main.Skill.ExerciseSkillMgr")
    skillBagId = ExerciseSkillMgr.Instance():GetDefaultSkillBagId()
  elseif context then
    skillBagId = context.skillBagId
  end
  if skillBagId == nil then
    return true
  end
  local ItemModule = require("Main.Item.ItemModule")
  local ItemUtils = require("Main.Item.ItemUtils")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  local itemBase = ItemUtils.GetItemBase(item.id)
  local askStr = string.format(textRes.Item[8323], HtmlHelper.NameColor[itemBase.namecolor], itemBase.name)
  local dlg = CommonConfirmDlg.ShowConfirm(textRes.Item[8324], askStr, function(selection, tag)
    if selection == 1 then
      local ExerciseSkillMgr = require("Main.Skill.ExerciseSkillMgr")
      if ExerciseSkillMgr.Instance():UseXiuLianItemReq(skillBagId, itemKey, true) == ExerciseSkillMgr.CResult.ReachMaxLevel then
        Toast(textRes.Skill[14])
      end
    end
  end, nil)
  dlg:rename(m_panel.name)
  return true
end
def.method().OpenXiuLianSkillPanel = function(self)
  local SkillModule = require("Main.Skill.SkillModule")
  Event.DispatchEvent(ModuleId.SKILL, gmodule.notifyId.Skill.REQ_OPEN_SKILL_PANEL, {
    SkillModule.SkillFuncType.Exercise
  })
end
def.method("number", "number").UseXiuLianItem = function(self, skillBagId, itemKey)
  local ExerciseSkillMgr = require("Main.Skill.ExerciseSkillMgr")
  local result = ExerciseSkillMgr.Instance():UseXiuLianItemReq(skillBagId, itemKey, false)
  if result == ExerciseSkillMgr.CResult.ReachMaxLevel then
    Toast(textRes.Skill[14])
  elseif result == ExerciseSkillMgr.CResult.DefaultSkillNotExist then
    Toast(textRes.Skill[20])
  end
end
OperationXiuLianExp.Commit()
return OperationXiuLianExp
