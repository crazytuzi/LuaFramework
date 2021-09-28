CPaoShangNPCList = class("CPaoShangNPCList", CcsSubView)
function CPaoShangNPCList:ctor(param)
  CPaoShangNPCList.super.ctor(self, "views/monstername_view.json", {opacityBg = 0, clickOutSideToClose = true})
  self:initNPCNameitem()
  self:setViewPosition()
  self:getUINode():setAnchorPoint(ccp(0, 0))
end
function CPaoShangNPCList:ListEventListener(item, index, listObj, status)
  if status == LISTVIEW_ONSELECTEDITEM_START then
    soundManager.playSound("xiyou/sound/clickbutton_1.wav")
  elseif status == LISTVIEW_ONSELECTEDITEM_END then
  end
end
function CPaoShangNPCList:initNPCNameitem()
  self.m_NPCNameList = self:getNode("monster_nameList")
  self.m_NPCNameList:addTouchItemListenerListView(handler(self, self.ListSelector), handler(self, self.ListEventListener))
  local npcNameList = {}
  npcNameList = data_Org_PaoShangTask[1].NpcList
  if #npcNameList > 0 then
    for index, npcId in pairs(npcNameList) do
      local NPCInfon = data_NpcInfo[npcId]
      local item = CPaoShangNPCItme.new({
        index = index,
        name_txt = NPCInfon.name
      })
      item.npcId = npcId
      self.m_NPCNameList:pushBackCustomItem(item)
    end
  end
end
function CPaoShangNPCList:ListSelector(item, index, listObj)
  local npcId = item.npcId
  if npcId ~= nil then
    g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
      if isSucceed and CMainUIScene.Ins then
        CMainUIScene.Ins:ShowNormalNpcViewById(npcId)
      end
    end)
    scheduler.performWithDelayGlobal(handler(self, self.CloseSelf), 0.05)
  end
end
function CPaoShangNPCList:setViewPosition()
  local mainMenuMissionList = g_CMainMenuHandler:getMisssionListPos()
  local x, y = mainMenuMissionList:getPosition()
  local wpos = mainMenuMissionList:getParent():convertToWorldSpace(ccp(x, y))
  local size = mainMenuMissionList:getContentSize()
  local m_size = self:getContentSize()
  self:setPosition(ccp(wpos.x - m_size.width - 5, wpos.y))
end
function CPaoShangNPCList:Clear()
  self.m_NPCNameList = nil
  self:removeFromParent()
end
CPaoShangNPCItme = class("CPaoShangNPCItme", function()
  local widget = Widget:create()
  widget:setAnchorPoint(ccp(0, 0))
  widget:ignoreContentAdaptWithSize(false)
  return widget
end)
function CPaoShangNPCItme:ctor(param)
  local index = param.index
  local name_txt = param.name_txt
  local btnCallback = param.btnlCallback
  local btn = BDsubButton.new("views/common/bg/bg1073.png", btnCallback, name_txt)
  local btnsize = btn:getContentSize()
  self:setSize(CCSizeMake(btnsize.width, btnsize.height))
  self:addChild(btn)
end
function CPaoShangNPCItme:Clear()
end
