local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIScores = Lplus.Extend(ECPanelBase, "UIScores")
local instance
local def = UIScores.define
local GUIUtils = require("GUI.GUIUtils")
def.field("table")._tblScores = nil
def.static("=>", UIScores).Instance = function()
  if instance == nil then
    instance = UIScores()
  end
  return instance
end
def.override().OnCreate = function(self)
  self:UpdateScoreList()
end
def.override().OnDestroy = function(self)
  self._tblScores = nil
end
def.method().UpdateScoreList = function(self)
  if self._tblScores == nil then
    return
  end
  table.sort(self._tblScores, function(a, b)
    return (a.integral or 0) > (b.integral or 0)
  end)
  local ctrlUIList = self.m_panel:FindDirect("Img_Bg0/Group_Player/List_Rank")
  local uiList = GUIUtils.InitUIList(ctrlUIList, #self._tblScores)
  local preRank = 1
  for i = 1, #self._tblScores do
    local item = uiList[i]
    local lblrank = item:FindDirect(("Label_1_%d"):format(i))
    local lblName = item:FindDirect(("Label_2_%d"):format(i))
    local lblScore = item:FindDirect(("Label_3_%d"):format(i))
    local imgRank1 = item:FindDirect(("Img_MingCi1_%d"):format(i))
    local imgRank2 = item:FindDirect(("Img_MingCi2_%d"):format(i))
    local imgRank3 = item:FindDirect(("Img_MingCi3_%d"):format(i))
    local scoreVal = self._tblScores[i]
    local rankVal = 0
    if i ~= 1 then
      local preMemIntegral = self._tblScores[i - 1].integral
      if scoreVal.integral == preMemIntegral then
        rankVal = preRank
      else
        rankVal = i
      end
    else
      rankVal = 1
    end
    preRank = rankVal
    for j = 1, 3 do
      if j == rankVal then
        item:FindDirect(("Img_MingCi%d_%d"):format(j, i)):SetActive(true)
      else
        item:FindDirect(("Img_MingCi%d_%d"):format(j, i)):SetActive(false)
      end
    end
    if rankVal >= 4 then
      lblrank:SetActive(true)
      GUIUtils.SetText(lblrank, rankVal)
    else
      lblrank:SetActive(false)
    end
    GUIUtils.SetText(lblName, scoreVal.roleName)
    GUIUtils.SetText(lblScore, scoreVal.integral or 0)
  end
end
def.method("table").ShowPanel = function(self, scores)
  self._tblScores = scores
  if self:IsLoaded() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_SCORE_LIST, 1)
  self:SetModal(true)
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:HidePanel()
  end
end
return UIScores.Commit()
