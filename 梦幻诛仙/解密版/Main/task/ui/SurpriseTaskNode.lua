local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local SurpriseTaskNode = Lplus.Extend(TabNode, "SurpriseTaskNode")
local SurpriseTaskMgr = require("Main.task.SurpriseTaskMgr")
local def = SurpriseTaskNode.define
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:setSurpriseTaskList()
end
def.override().OnHide = function(self)
  local surpriseTaskMgr = SurpriseTaskMgr.Instance()
  if surpriseTaskMgr:isOwnNewSurpriseGraph() then
    surpriseTaskMgr:clearNewGraph()
    local p = require("netio.protocol.mzm.gsp.task.CActiveNewSurpriseGraphRep").new()
    gmodule.network.sendProtocol(p)
  end
end
def.method("=>", "boolean").isOpen = function(self)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if not _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_SHOW_SURPRISE_CLUE) then
    return false
  end
  return true
end
def.method("=>", "boolean").isNotify = function(self)
  return SurpriseTaskMgr.Instance():isOwnNewSurpriseGraph()
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("-------SurpriseTaskNode onClick:", id)
end
def.method().setSurpriseTaskList = function(self)
  local surpriseTaskMgr = SurpriseTaskMgr.Instance()
  local surpriseTaskList = surpriseTaskMgr:getCurSurpriseTaskList()
  local function comp(cfg1, cfg2)
    local num1 = surpriseTaskMgr:getFinishSurpriseTaskNum(cfg1.graphId)
    local num2 = surpriseTaskMgr:getFinishSurpriseTaskNum(cfg2.graphId)
    local isFinish1 = num1 >= cfg1.finishCount
    local isFinish2 = num2 >= cfg2.finishCount
    if isFinish1 == isFinish2 then
      if cfg1.needServerLevel == cfg2.needServerLevel then
        if cfg1.needServerLevelTime == cfg2.needServerLevelTime then
          return cfg1.graphId > cfg2.graphId
        else
          return cfg1.needServerLevelTime > cfg2.needServerLevelTime
        end
      else
        return cfg1.needServerLevel > cfg2.needServerLevel
      end
    else
      if isFinish1 then
        return false
      end
      if isFinish2 then
        return true
      end
    end
  end
  table.sort(surpriseTaskList, comp)
  local List = self.m_node:FindDirect("Group_List/Group_List/Scrolllist/List")
  local uiList = List:GetComponent("UIList")
  uiList.itemCount = #surpriseTaskList
  uiList:Resize()
  for i, v in ipairs(surpriseTaskList) do
    local item = List:FindDirect("item_" .. i)
    local Img_Bg1 = item:FindDirect("Img_Bg1")
    local Img_Bg2 = item:FindDirect("Img_Bg2")
    if i % 2 == 0 then
      Img_Bg1:SetActive(false)
      Img_Bg2:SetActive(true)
    else
      Img_Bg1:SetActive(true)
      Img_Bg2:SetActive(false)
    end
    local Label_Clue = item:FindDirect("Label_Clue")
    local Label_Reward = item:FindDirect("Label_Reward")
    local Img_Finish = item:FindDirect("Img_Finish")
    local Label_Level = item:FindDirect("Label_Level")
    local Img_Red = item:FindDirect("Img_Red")
    Label_Clue:GetComponent("UILabel"):set_text(v.clue)
    Label_Reward:GetComponent("UILabel"):set_text(v.titleDes)
    Label_Level:GetComponent("UILabel"):set_text(v.joinLevel)
    if surpriseTaskMgr:getFinishSurpriseTaskNum(v.graphId) >= v.finishCount then
      Img_Finish:SetActive(true)
    else
      Img_Finish:SetActive(false)
    end
    if Img_Red then
      if surpriseTaskMgr:isNewSurpriseGraph(v.graphId) then
        Img_Red:SetActive(true)
      else
        Img_Red:SetActive(false)
      end
    end
  end
end
return SurpriseTaskNode.Commit()
