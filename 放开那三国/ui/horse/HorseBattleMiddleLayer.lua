module("HorseBattleMiddleLayer", package.seeall)
local _bgLayer = nil

function init( ... )
	-- body
	_bgLayer = nil
end

function onTouchesHandler( eventType, x, y )
    return true
end

function onNodeEvent( event )
    if ( event == "enter" ) then
        _bgLayer:registerScriptTouchHandler(onTouchesHandler,false,-5431,true)
        _bgLayer:setTouchEnabled(true)
    elseif ( event == "exit" ) then
        _bgLayer:unregisterScriptTouchHandler()
    end
end

function createLayer( ... )
	-- body
	init()
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,190))
	_bgLayer:registerScriptHandler(onNodeEvent)
	return _bgLayer
end

function closeLayer( ... )
	-- body
	if(_bgLayer~=nil)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil		
	end
end