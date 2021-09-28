g_MostTopLayer = display.newNode()
CCDirector:sharedDirector():setNotificationNode(g_MostTopLayer)
function onEnter_MostTopLayer()
  g_MostTopLayer:onEnterLua()
  g_MostTopLayer:onEnterTransitionDidFinishLua()
end
function onExit_MostTopLayer()
  g_MostTopLayer:onExitTransitionDidStartLua()
  g_MostTopLayer:onExitLua()
end
function addNodeToTopLayer(node, z)
  z = z or 0
  g_MostTopLayer:addChild(node, z)
end
onEnter_MostTopLayer()
TopLayerZ_GuideArrow = 90
TopLayerZ_LevelUpAni = 105
TopLayerZ_NotifyMsg = 100
TopLayerZ_NotifyAwardMsg = 101
TopLayerZ_NotifyMissionCmp = 102
TopLayerZ_VoiceRecognize = 105
TopLayerZ_WaitingView_Small = 110
TopLayerZ_WaitingView_Big = 110
TopLayerZ_CutScreen = 9999
