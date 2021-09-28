CNpcViewBase = class(".CNpcViewBase", CcsSubView)
function CNpcViewBase:ctor(npcId, npcFuncType, ...)
  CNpcViewBase.super.ctor(self, ...)
  self.m_NpcId = npcId
  self.m_NpcFuncType = npcFuncType
end
function CNpcViewBase:getNpcId()
  return self.m_NpcId
end
function CNpcViewBase:getNpcFuncType()
  return self.m_NpcFuncType
end
function CNpcViewBase:Clear()
  print("======>>> CNpcViewBase:Clear")
  if CMainUIScene.Ins then
    CMainUIScene.Ins:PopViewClosed(self)
  end
end
