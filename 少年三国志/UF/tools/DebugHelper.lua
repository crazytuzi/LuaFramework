--DebugHelper.lua


DebugHelper = {}

DebugHelper._defaultTag = "default"
DebugHelper._errorTag = "ERROR"
DebugHelper._enableSceneMonitor = false
DebugHelper._sceneMonitor = nil
DebugHelper._tagTable = {DebugHelper._defaultTag, DebugHelper._errorTag}

function DebugHelper.setDefaultTag( tag )
 	if type(tag) == "string" then 
		DebugHelper._tagTable = {DebugHelper._defaultTag, DebugHelper._errorTag, tag}
	elseif type(tag) == "table" then
    DebugHelper._tagTable = {}
    for _, value in pairs(tag) do
      table.insert(DebugHelper._tagTable, table.getn(DebugHelper._tagTable) + 1, value)
    end
    table.insert(DebugHelper._tagTable, table.getn(DebugHelper._tagTable) + 1, DebugHelper._defaultTag)
    table.insert(DebugHelper._tagTable, table.getn(DebugHelper._tagTable) + 1, DebugHelper._errorTag)
	end
end

function DebugHelper.enableSceneMontor( enable )
  enable = enable or false
  if (DebugHelper._enableSceneMonitor and enable) or 
     (not DebugHelper._enableSceneMonitor and not enable) then 
     return 
   end

  DebugHelper._enableSceneMonitor = enable
  if enable then
    DebugHelper._sceneMonitor = UFCCSSceneMonitor.new()
  else
    DebugHelper._sceneMonitor:unInitMonitor()
    DebugHelper._sceneMonitor = nil
  end
end

function __Log(cls, ...) 
  if device.environment == "device" then 
    return nil
  end
  
  __LogTag(DebugHelper._defaultTag, cls, ...)
end

function __LogTag( tag, cls, ... )
  if device.environment == "device" then 
    return nil
  end

  if DEBUG and DEBUG ~= 1 then 
    return 
  end

  local tagName = tag
  if type(tagName) ~= "string" then
    tagName = DebugHelper._defaultTag
  end

  local validTag = false
  for i, value in pairs(DebugHelper._tagTable) do 
    if value == tagName then 
      validTag = true
      break
    end
  end

  if validTag == false then 
    return 
  end 

  echo("["..tagName.."] " .. string.format(tostring(cls), ...))
end

function __LogError( cls, ... )
  __LogTag(DebugHelper._errorTag, cls, ...)
end

function __Error(cls, ... )
  echoError(cls, ...)
end

function __PrintTable( t )
  for key, value in pairs(t) do 
    __Log("key[%s], value[%s]", key, value)
    if type(value) == "table" then
      __PrintTable(value)
    end
  end
end

function __DumpTextureRef(  )
  __Log("----dump texture-----")
    CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
  __Log("")
end

function boolToInt( v )
  if type(v) ~= "boolean" then
    __Log("type is %s", type(v))
    return 0
  end

  if v == true then
    return 1
  else
    return 0
  end
end

function __show_debug_panel_( ... )
--if SHOW_DEBUG_PANEL == 1 then
    local debugPanel = CCSNormalLayer:create()
    debugPanel:setClickSwallow(true)
    uf_notifyLayer:getDebugNode():addChild(debugPanel, 1, 1000)
    local size = CCEGLView:sharedOpenGLView():getFrameSize()
    if CONFIG_SCREEN_WIDTH ~= nil and CONFIG_SCREEN_HEIGHT ~= nil then
      size = CCSizeMake(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT)
    end

    local hideMenu = function (  )
        debugPanel._menu1:setVisible(false)
        debugPanel._btnDebug:setVisible(true)
    end

    local showMenu = function (  )
        debugPanel._menu1:setVisible(true)
        debugPanel._btnDebug:setVisible(false)
    end

    debugPanel._menu1 = Layout:create()
    debugPanel._menu1:setAnchorPoint(ccp(0, 1))
    debugPanel._menu1:ignoreContentAdaptWithSize(false)
    debugPanel._menu1:setSize(size)
    debugPanel._menu1:setPosition(ccp(0, size.height))
    debugPanel._menu1:setVisible(false)
    debugPanel:addWidget(debugPanel._menu1)

    local backPanel = Layout:create()
    backPanel:setBackGroundColorType(LAYOUT_COLOR_GRADIENT)
    backPanel:setBackGroundColor(ccc3(0, 0, 0), ccc3(200, 200, 200))
    backPanel:setBackGroundColorOpacity(200)
    backPanel:setSize(CCSizeMake(size.width, 50))
    backPanel:setAnchorPoint(ccp(0.5, 0.5));
    backPanel:setPosition(ccp(0, -50));
    debugPanel._menu1:addChild(backPanel)

    local btnAni = Button:create()
    btnAni:setTitleFontSize(25)
    btnAni:setTitleColor(ccc3(0, 255, 0))
    btnAni:ignoreContentAdaptWithSize(false)
    btnAni:setSize(CCSizeMake(120, 40))
    btnAni:setPosition(ccp(80, -25))
    btnAni:setTouchEnabled(true)
    btnAni:setName("btnAni")
    btnAni:setTitleText("Animation")
    debugPanel._menu1:addChild(btnAni)
    debugPanel:registerBtnClickEvent("btnAni", function ( widget, param )
        AnimationHelper:showAnimationHelper()
        hideMenu()
    end)

    local btnTex = Button:create()
    btnTex:setTitleFontSize(25)
    btnTex:setTitleColor(ccc3(0, 255, 0))
    btnTex:ignoreContentAdaptWithSize(false)
    btnTex:setSize(CCSizeMake(120, 40))
    btnTex:setPosition(ccp(200, -25))
    btnTex:setTouchEnabled(true)
    btnTex:setName("btnTex")
    btnTex:setTitleText("Texture")
    debugPanel._menu1:addChild(btnTex)
    debugPanel:registerBtnClickEvent("btnTex", function ( widget, param )
        TextureManger:getInstance():showTextureWatcher(true)
        hideMenu()
    end)

    local btnHide = Button:create()
    btnHide:setTitleFontSize(25)
    btnHide:setTitleColor(ccc3(255, 0, 0))
    btnHide:ignoreContentAdaptWithSize(false)
    btnHide:setSize(CCSizeMake(120, 40))
    btnHide:setPosition(ccp(300, -25))
    btnHide:setTouchEnabled(true)
    btnHide:setName("btnHide")
    btnHide:setTitleText("Hide")
    debugPanel._menu1:addChild(btnHide)
    debugPanel:registerBtnClickEvent("btnHide", function ( widget, param )
        hideMenu()
    end)

    local showWidgetRectBtn = Button:create()
    showWidgetRectBtn:setTitleFontSize(18)
    showWidgetRectBtn:setTitleColor(ccc3(255, 255, 0))
    showWidgetRectBtn:ignoreContentAdaptWithSize(false)
    showWidgetRectBtn:setSize(CCSizeMake(120, 40))
    showWidgetRectBtn:setPosition(ccp(570, -25))
    showWidgetRectBtn:setTouchEnabled(true)
    showWidgetRectBtn:setName("widgetRect")
    showWidgetRectBtn:setTitleText(Widget.s_showControlRect and "HideWidgetRect" or "ShowWidgetRect")
    debugPanel._menu1:addChild(showWidgetRectBtn)
    debugPanel:registerBtnClickEvent("widgetRect", function ( widget, param )
        Widget:setShowControlRect(not Widget.s_showControlRect)
        showWidgetRectBtn:setTitleText(Widget.s_showControlRect and "HideWidgetRect" or "ShowWidgetRect")
    end)

    local showWidgetRectBtn = Button:create()
    showWidgetRectBtn:setTitleFontSize(18)
    showWidgetRectBtn:setTitleColor(ccc3(255, 255, 0))
    showWidgetRectBtn:ignoreContentAdaptWithSize(false)
    showWidgetRectBtn:setSize(CCSizeMake(120, 40))
    showWidgetRectBtn:setPosition(ccp(420, -25))
    showWidgetRectBtn:setTouchEnabled(true)
    showWidgetRectBtn:setName("SceneMonitor")
    showWidgetRectBtn:setTitleText((DebugHelper._sceneMonitor and DebugHelper._sceneMonitor:isVisible()) and "HideSceneMonitor" or "ShowSceneMonitor")
    debugPanel._menu1:addChild(showWidgetRectBtn)
    debugPanel:registerBtnClickEvent("SceneMonitor", function ( widget, param )
        if not DebugHelper._enableSceneMonitor then 
          print("DebugHelper._enableSceneMonitor is false, call DebugHelper.enableSceneMontor first!")
          return 
        end

        local visible = false
        if DebugHelper._sceneMonitor then 
            visible = not DebugHelper._sceneMonitor:isVisible()
            DebugHelper._sceneMonitor:showMonitor( visible )
        end

        showWidgetRectBtn:setTitleText(visible and "HideSceneMonitor" or "ShowSceneMonitor")
    end)

    debugPanel._btnDebug = Button:create()
    debugPanel._btnDebug:setTitleFontSize(15)
    debugPanel._btnDebug:setTitleColor(ccc3(255, 0, 0))
    debugPanel._btnDebug:ignoreContentAdaptWithSize(false)
    debugPanel._btnDebug:setSize(CCSizeMake(120, 40))
    debugPanel._btnDebug:setPosition(ccp(25, size.height - 15))
    debugPanel._btnDebug:setTouchEnabled(true)
    debugPanel._btnDebug:setName("btnDebug")
    debugPanel._btnDebug:setTitleText("Debug")
    debugPanel:addWidget(debugPanel._btnDebug)
    debugPanel:registerBtnClickEvent("btnDebug", function ( widget, param )
      __Log("debug clicked!")
        showMenu()
    end)

end
