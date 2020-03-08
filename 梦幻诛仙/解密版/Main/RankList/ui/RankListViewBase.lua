local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local RankListViewBase = Lplus.Class(CUR_CLASS_NAME)
local RankListPanel = Lplus.ForwardDeclare("RankListPanel")
local def = RankListViewBase.define
def.field(RankListPanel).m_base = nil
def.field("userdata").m_panel = nil
def.field("table").m_rankListData = nil
def.field("table").uiObjs = nil
def.virtual(RankListPanel, "userdata").Init = function(self, base, panel)
  self.m_base = base
  self.m_panel = panel
  self.uiObjs = base.uiObjs
end
def.method("table").SetRankListData = function(self, rankListData)
  self.m_rankListData = rankListData
end
def.virtual().Dispose = function(self)
end
def.virtual().UpdateView = function(self)
end
return RankListViewBase.Commit()
