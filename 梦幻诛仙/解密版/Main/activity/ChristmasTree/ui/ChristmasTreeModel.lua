local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local ECPlayer = require("Model.ECPlayer")
local ChristmasTreeModel = Lplus.Extend(ECPlayer, "ChristmasTreeModel")
local GUIUtils = require("GUI.GUIUtils")
local SGetStockingInfoSuccess = require("netio.protocol.mzm.gsp.christmasstocking.SGetStockingInfoSuccess")
local def = ChristmasTreeModel.define
def.const("number").DEFAULT_NAME_COLOR_ID = 701300007
def.field("string").roleName = ""
def.final("number", "=>", ChristmasTreeModel).new = function(cfgId)
  local obj = ChristmasTreeModel()
  obj.m_IsTouchable = true
  obj.m_create_node2d = true
  obj.defaultParentNode = gmodule.moduleMgr:GetModule(ModuleId.MAP).mapPlayerNodeRoot
  obj.defaultLayer = ClientDef_Layer.NPC
  obj:Init(cfgId)
  return obj
end
def.method("userdata", "string").SetRoleInfo = function(self, roleId, roleName)
  self.roleId = roleId
  self.roleName = roleName
  self:SetTitle(" ")
  local nameColor = _G.GetColorData(ChristmasTreeModel.DEFAULT_NAME_COLOR_ID)
  self:SetName(string.format(textRes.activity.ChristmasTree[4], roleName), nameColor)
end
def.method("table").SetStockStatusOnTree = function(self, status)
  if not self:IsLoaded() then
    return
  end
  local hasAward = false
  local stocksCount = 0
  for i = 1, constant.CChristmasStockingConsts.TREE_HANG_MAX_NUM do
    local stock = self.m_model:FindDirect(string.format("Ornament%02d", i))
    if status[i] == SGetStockingInfoSuccess.POSITION_STATE_EMPTY then
      GUIUtils.SetActive(stock, false)
    else
      stocksCount = stocksCount + 1
      GUIUtils.SetActive(stock, true)
    end
    if status[i] == SGetStockingInfoSuccess.POSITION_WITH_AWARD then
      hasAward = true
    end
  end
  local awardEffect = self.m_model:FindDirect("WuPinShiQu")
  GUIUtils.SetActive(awardEffect, hasAward)
  local nameColor = _G.GetColorData(ChristmasTreeModel.DEFAULT_NAME_COLOR_ID)
  self:SetName(string.format(textRes.activity.ChristmasTree[15], self.roleName, stocksCount, constant.CChristmasStockingConsts.TREE_HANG_MAX_NUM), nameColor)
end
def.override().OnClick = function(self)
  require("Main.activity.ChristmasTree.ChristmasTreeMgr").Instance():GetChristmasTreeInfo(self.roleId)
end
return ChristmasTreeModel.Commit()
