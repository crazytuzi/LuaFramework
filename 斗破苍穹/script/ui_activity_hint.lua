require"Lang"
UIActivityHint = {}
local scrollView = nil
local listItem = nil
local SCROLLVIEW_ITEM_SPACE = 10
local isPop = nil
function getActivityThingTime( sname )
     local _time = {}
     if net.SysActivity then
        for key, obj in pairs(net.SysActivity) do
             if obj.int["8"] == 1 and obj.string["9"] == sname then 
                    local _startTime = obj.string["4"]
                    local _endTime = obj.string["5"]
                    local _curTime = utils.getCurrentTime()
                    if (_startTime == "" and _endTime == "") then
                        _time[ 1 ] = 0
                        _time[ 2 ] = 0
                        _time[ 3 ] = 0
                        return _time
                    elseif _startTime ~= "" and _endTime ~= "" and (utils.GetTimeByDate(_startTime) < _curTime and _curTime < utils.GetTimeByDate(_endTime)) then
                        _time[ 1 ] = utils.changeTimeFormat(_startTime)
                        _time[ 2 ] = utils.changeTimeFormat(_endTime)
                        _time[ 3 ] = 1
                        return _time
                    end
                    break
              end
        end
    end
    return nil
end
function getActivityThing( sname )
     local type = 0
     if net.SysActivity then
        for key, obj in pairs(net.SysActivity) do
            if obj.int["8"] == 1 and obj.string["9"] == sname then
                if 100 < obj.int["1"] and obj.int["1"] <= 200 then 
                    type = 2
                elseif obj.int["1"] > 0 and obj.int["1"] <= 100 then
                    type = 1
                elseif obj.int["1"] > 200 and obj.int["1"] <= 300 then
                    type = 3
                end
            end
        end
    end
    return type
end
local function setScrollViewItem(item, obj)
    item:getChildByName("text_info"):setString( obj.string["8"] )
    if obj.string["3"] and obj.string["3"] ~= "" then
        item:getChildByName("btn_activity"):loadTextureNormal("ui/"..obj.string["3"])
        item:getChildByName("btn_activity"):loadTexturePressed("ui/"..obj.string["3"])
        item:getChildByName("btn_activity"):loadTextureDisabled("ui/"..obj.string["3"])
    end
    local _btn = item:getChildByName("btn_activity")
    local sname = tostring( obj.string["6"] )
    local time = getActivityThingTime( tostring( obj.string["6"] ) )
    if time and time[ 3 ] == 1 then
         item:getChildByName("text_time"):setString( string.format(Lang.ui_activity_hint1, time[1][2], time[1][3], time[1][4] , time[2][2], time[2][3], time[2][4]) )
    else
        item:getChildByName("text_time"):setString("")
    end
    local function btnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
           -- cclog("进入页面")
            UIManager.popScene("ui_activity_hint")
            if sname == "barrier" then
                if UIFight.Widget and UIFight.Widget:getParent() then
                    return
                 end
                 local flag = (flag and flag or 2)                 
		         UIFight.setFlag(flag)
		         UIManager.showWidget("ui_notice", "ui_team_info","ui_fight","ui_menu")
            elseif sname == "money" then
                utils.checkGOLD( 1 )
            elseif sname == "buy" then              
                if not UIShop.Widget or not UIShop.Widget:getParent() then
		            UIManager.hideWidget("ui_team_info")
				    UIShop.reset(2)
				    UIShop.getShopList(1,true)
	            end
            elseif getActivityThing( sname ) == 2 then --限时活动
                UIManager.hideWidget("ui_team_info")
                UIManager.showWidget("ui_activity_time")
                UIActivityTime.jumpName( sname )
            elseif getActivityThing( sname ) == 1 then --精彩活动
                for key , value in pairs( UIActivityPanel.rechargeActivity ) do
                    if sname == value then
                        UIActivityPanel.setRechargeActivity( UIActivityPanel.rechargeActivity )
                        break
                    end
                end
                
                UIActivityPanel.scrollByName(sname,sname)
                UIManager.showWidget("ui_activity_panel")
            elseif getActivityThing( sname ) == 3 then --兑换
                UIManager.showWidget("ui_activity_exchange")
            end
        end
    end
    _btn:setPressedActionEnabled(true)
    _btn:addTouchEventListener(btnEvent)
end
local function layoutScrollView(_listData, _initItemFunc)
    scrollView:removeAllChildren()
    scrollView:jumpToTop()
    local _innerHeight = 0
    for key, obj in pairs(_listData) do
        local scrollViewItem = listItem:clone()
        _initItemFunc(scrollViewItem, obj)
        scrollView:addChild(scrollViewItem)
        _innerHeight = _innerHeight + scrollViewItem:getContentSize().height + SCROLLVIEW_ITEM_SPACE
    end
    _innerHeight = _innerHeight + SCROLLVIEW_ITEM_SPACE
    if _innerHeight < scrollView:getContentSize().height then
        _innerHeight = scrollView:getContentSize().height
    end
    scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width, _innerHeight))
    local childs = scrollView:getChildren()
    local prevChild = nil
    for i = 1, #childs do
        if i == 1 then
            childs[i]:setPosition(scrollView:getContentSize().width / 2, scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height - SCROLLVIEW_ITEM_SPACE)
        else
            childs[i]:setPosition( 0 , prevChild:getBottomBoundary() - childs[i]:getContentSize().height - SCROLLVIEW_ITEM_SPACE)
        end
        prevChild = childs[i]
    end
    ActionManager.ScrollView_SplashAction(scrollView)
end
function UIActivityHint.init()
    scrollView = ccui.Helper:seekNodeByName(UIActivityHint.Widget, "view")
    listItem = scrollView:getChildByName("panel"):clone()
    local btn_closed = ccui.Helper:seekNodeByName( UIActivityHint.Widget , "btn_colsed")
    local function btnEvent( sender , eventType)
        if eventType == ccui.TouchEventType.ended then
             if sender == btn_closed then
                UIManager.popScene("ui_activity_hint")
             end
        end
    end
    btn_closed:setPressedActionEnabled( true )
    btn_closed:addTouchEventListener( btnEvent )
end

function UIActivityHint.setup()
    if listItem:getReferenceCount() == 1 then
        listItem:retain()
    end
    scrollView:removeAllChildren()
	if net.DictActivityBanner then
       -- cclog("DictActivityBanner"..net.DictActivityBanner["1"].string["8"] )
        local _banner = {}
        for key , value in pairs ( net.DictActivityBanner ) do
            if value.string["3"] == "" then--无图片
              --  table.insert( _banner , value )
            elseif tonumber( value.int["4"] ) == 0 then --不在活动表里
                if tostring( value.string["6"] ) == "buy" and value.int["5"] > 0 then
                    if DictThing[tostring(value.int["5"])].isCanBuy == 1 then
                        table.insert( _banner , value )
                    end
                else
                    table.insert( _banner , value )
                end
            else
                local time = getActivityThingTime( tostring( value.string["6"] ) )--活动表里 要判断下时间
                if time then
                    table.insert( _banner , value )
                end
            end
        end
        if #_banner == 0 then
             isPop = 1
             return 
        end
        utils.quickSort( _banner , function ( obj1 , obj2 )
             if tonumber( obj1.string["7"] ) > tonumber( obj2.string["7"] ) then
                return true
             else
                return false 
             end
        end)
        if _banner then
            layoutScrollView(_banner, setScrollViewItem)
        end
    else 
        isPop = 1
    end
end
function UIActivityHint.onEnter()
    if isPop then
        UIManager.popScene("ui_activity_hint")
    end
end

function UIActivityHint.free( )
    isPop = nil
    scrollView:removeAllChildren()
end
