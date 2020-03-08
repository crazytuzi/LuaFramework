local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ChristmasTreeData = Lplus.Class(CUR_CLASS_NAME)
local def = ChristmasTreeData.define
local SGetStockingInfoSuccess = require("netio.protocol.mzm.gsp.christmasstocking.SGetStockingInfoSuccess")
def.field("userdata").roleId = nil
def.field("string").roleName = ""
def.field("table").operationHistory = nil
def.field("table").positionState = nil
def.field("number").selfHangNum = 0
def.method("table").RawSet = function(self, p)
  self.roleId = p.target_role_id
  self.roleName = _G.GetStringFromOcts(p.target_role_name)
  self.operationHistory = p.historys
  self.positionState = p.position_state
  self.selfHangNum = p.self_hang_num
end
def.method("=>", "userdata").GetRoleId = function(self)
  return self.roleId
end
def.method("=>", "string").GetRoleName = function(self)
  return self.roleName
end
def.method("=>", "table").GetOperationHistory = function(self)
  return self.operationHistory
end
def.method("table").AddOperationHistory = function(self, operation)
  if self.operationHistory == nil then
    return
  end
  table.insert(self.operationHistory, operation)
end
def.method("number", "=>", "boolean").IsEmpytyPosition = function(self, pos)
  if self.positionState == nil then
    return true
  end
  return self.positionState[pos] == SGetStockingInfoSuccess.POSITION_STATE_EMPTY
end
def.method("number", "=>", "boolean").IsAwardPosition = function(self, pos)
  if self.positionState == nil then
    return true
  end
  return self.positionState[pos] == SGetStockingInfoSuccess.POSITION_WITH_AWARD
end
def.method("number", "=>", "boolean").IsHangingPosition = function(self, pos)
  if self.positionState == nil then
    return false
  end
  return self.positionState[pos] == SGetStockingInfoSuccess.POSITION_HANGING
end
def.method("number").MarkPosAsHanging = function(self, pos)
  if self.positionState == nil then
    return
  end
  self.positionState[pos] = SGetStockingInfoSuccess.POSITION_HANGING
end
def.method("number").MarkPosAsEmpty = function(self, pos)
  if self.positionState == nil then
    return
  end
  self.positionState[pos] = SGetStockingInfoSuccess.POSITION_STATE_EMPTY
end
def.method("=>", "number").GetSelfHangNum = function(self)
  return self.selfHangNum
end
def.method().AddSelfHangNum = function(self)
  self.selfHangNum = self.selfHangNum + 1
end
def.method("=>", "boolean").IsFullHangNumOnTree = function(self)
  return self.selfHangNum >= constant.CChristmasStockingConsts.ROLE_HANG_ON_ONE_TREE_MAX_NUM
end
def.method().NewDayToUpdateAward = function(self)
  if self.positionState == nil then
    return
  end
  for i = 1, constant.CChristmasStockingConsts.TREE_HANG_MAX_NUM do
    if self.positionState[i] == SGetStockingInfoSuccess.POSITION_HANGING then
      self.positionState[i] = SGetStockingInfoSuccess.POSITION_WITH_AWARD
    end
  end
end
def.method("=>", "boolean").IsMyChristmasTree = function(self)
  if self.roleId == nil then
    return false
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if not heroProp then
    return false
  end
  return Int64.eq(heroProp.id, self.roleId)
end
return ChristmasTreeData.Commit()
