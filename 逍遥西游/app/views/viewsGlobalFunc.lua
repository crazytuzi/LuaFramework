local _HadSetPath = {}
local function _setLoadingPath(path)
  if _HadSetPath[path] == nil then
    local texture = CCTextureCache:sharedTextureCache():addImage(path)
    if texture then
      texture:retain()
      _HadSetPath[path] = 1
    end
  end
end
local LOADINGTIME = 0
function CreateALoadingSprite(loadingPath)
  loadingPath = loadingPath or "xiyou/pic/pic_loading_circle.png"
  loadingBgPath = "xiyou/pic/pic_loading_bg.png"
  _setLoadingPath(loadingPath)
  _setLoadingPath(loadingBgPath)
  local loadingBg = display.newSprite(loadingBgPath)
  local loadingSprite = display.newSprite(loadingPath)
  loadingSprite:setRotation(LOADINGTIME)
  loadingSprite:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
    LOADINGTIME = (LOADINGTIME + 360 * dt) % 360
    loadingSprite:setRotation(LOADINGTIME)
  end)
  loadingSprite:scheduleUpdate()
  loadingBg:addChild(loadingSprite)
  local bgSize = loadingBg:getContentSize()
  loadingSprite:setPosition(ccp(bgSize.width / 2, bgSize.height / 2))
  return loadingBg
end
function getMaxZ(node)
  if node == nil then
    print("[ERROR node == nil]")
    return 0
  else
    local children = node:getChildren()
    if children == nil then
      print("[ERROR children == nil]")
      return 0
    else
      local maxZ = 0
      for i = 0, children:count() - 1 do
        local n = children:objectAtIndex(i)
        if n.getZOrder ~= nil then
          local z = n:getZOrder()
          if maxZ < z then
            maxZ = z
          end
        end
      end
      return maxZ
    end
  end
end
function CreateFullScreenBlackColorBg()
  opacity = opacity or 150
  local layerC = CCLayerColor:create(ccc4(0, 0, 0, opacity))
  return layerC
end
function CreateFullSwallowLayer(showLoading)
  tempClickWidget = Widget:create()
  tempClickWidget:ignoreContentAdaptWithSize(false)
  tempClickWidget:setSize(CCSize(display.width, display.height))
  tempClickWidget:setTouchEnabled(true)
  tempClickWidget:setAnchorPoint(ccp(0, 0))
  tempClickWidget:addTouchEventListener(function()
  end)
  getCurSceneView():addSubView({
    subView = tempClickWidget,
    zOrder = MainUISceneZOrder.swallowMessage
  })
  if showLoading then
    local loadingSprite = CreateALoadingSprite()
    tempClickWidget:addNode(loadingSprite, 1)
    loadingSprite:setPosition(ccp(display.width / 2, display.height / 2))
  end
  return tempClickWidget
end
function AutoLimitObjSize(obj, maxWith, maxHeight)
  local size = obj:getContentSize()
  local s = 1
  if maxWith ~= nil and maxWith < size.width then
    s = maxWith / size.width
  end
  if maxHeight ~= nil and maxHeight < size.height then
    local tmp_s = maxHeight / size.height
    if s > tmp_s then
      s = tmp_s
    end
  end
  obj:setScale(s)
end
function ShowCutScreenAni()
  if g_FubenHandler then
    g_FubenHandler:readyToCutScreen()
  end
  setAllNodesClippingType(LAYOUT_CLIPPING_SCISSOR)
  local size = CCDirector:sharedDirector():getWinSize()
  local pScreen = CCRenderTexture:create(size.width, size.height, kCCTexture2DPixelFormat_RGBA8888)
  local pCurNode
  local mapIns = g_MapMgr:getMapViewIns()
  if mapIns and mapIns:isVisible() then
    pCurNode = mapIns
  else
    pCurNode = CCDirector:sharedDirector():getRunningScene()
  end
  pScreen:begin()
  pCurNode:visit()
  pScreen:endToLua()
  setAllNodesClippingType(LAYOUT_CLIPPING_STENCIL)
  if g_FubenHandler then
    g_FubenHandler:recoverAfterCutScreen()
  end
  local rectScreen = CCRectMake(0, 0, size.width, size.height)
  local spriteScreen = CCSprite:createWithTexture(pScreen:getSprite():getTexture(), rectScreen)
  spriteScreen:setAnchorPoint(ccp(0, 0))
  spriteScreen:setPosition(ccp(0, 0))
  spriteScreen:setFlipY(true)
  g_MostTopLayer:addChild(spriteScreen, TopLayerZ_CutScreen)
  spriteScreen:runAction(transition.sequence({
    CCFadeOut:create(0.3),
    CCCallFunc:create(function()
      spriteScreen:removeFromParentAndCleanup(true)
    end)
  }))
end
