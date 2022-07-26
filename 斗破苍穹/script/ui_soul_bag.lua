require"Lang"
UISoulBag = {}

local scrollView = nil
local _item = nil
local _tempObj = nil
local _tempItem = nil

local SCROLLVIEW_ITEM_SPACE = 0

local function freshItem(_Item, _obj)
    local btn_lock = ccui.Helper:seekNodeByName( _Item , "btn_lock" )
    local text_name = ccui.Helper:seekNodeByName( _Item , "text_name" )
    text_name:setString( DictFightSoul[ tostring( _obj.int[ "3" ] ) ].name )
    local text_quality = ccui.Helper:seekNodeByName( _Item , "text_quality" )
    text_quality:setString( DictFightSoulQuality[ tostring( _obj.int[ "4" ] ) ].name )
    local text_describe = ccui.Helper:seekNodeByName( _Item , "text_describe" )
    local proType , proValue , sellSilver = utils.getSoulPro( _obj.int[ "3" ] , _obj.int[ "5" ] )
    if proValue < 1 then
            text_describe:setString( DictFightProp[tostring( proType )].name.."+"..( proValue * 100 ).."%" )
        else
            text_describe:setString( DictFightProp[tostring( proType )].name.."+"..proValue )
        end
    --text_describe:setString( DictFightProp[tostring( DictFightSoulUpgradeProp[ tostring( _obj.int[ "3" ] ) ].fightPropId )].name.."+"..DictFightSoulUpgradeProp[ tostring( _obj.int[ "3" ] ) ].fightPropValue )
    local text_lv = ccui.Helper:seekNodeByName( _Item , "text_lv" )
    text_lv:setString( "LV.".._obj.int[ "5" ] )
    local text_for = ccui.Helper:seekNodeByName( _Item , "text_for" )
    if _obj.int[ "7" ] == 0 then
        text_for:setVisible( false )
    else
        text_for:setVisible( true )
    end
    local image_lock = ccui.Helper:seekNodeByName( _Item , "image_lock" )
    if _obj.int[ "6" ] == 0 then
        btn_lock:setTitleText( Lang.ui_soul_bag1 ) 
        image_lock:setVisible( false )
    else
        btn_lock:setTitleText( Lang.ui_soul_bag2 )
        image_lock:setVisible( true )
    end
end

local function netCallBack( data )
    freshItem( _tempItem , _tempObj )
end

local function sendData( type , _obj )
    local sendData = {} ;
    if type == 0 then--锁定
        sendData = {
            header = StaticMsgRule.lockFightSoul ,
            msgdata  = {
                int = {
                    instPlayerFightSoulId = _obj.int[ "1" ]
                }
            }
        }
    elseif type == 1 then--解锁
        sendData = {
            header = StaticMsgRule.unLockFightSoul ,
            msgdata  = {
                int = {
                    instPlayerFightSoulId = _obj.int[ "1" ]
                }
            }
       }
    end
    _tempObj = _obj
    UIManager.showLoading()
    netSendPackage( sendData , netCallBack )
end

local function setScrollViewItem(_Item, _obj)
    local btn_lock = ccui.Helper:seekNodeByName( _Item , "btn_lock" )
    local btn_lineup = ccui.Helper:seekNodeByName( _Item , "btn_lineup" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
             if sender == btn_lock then
                _tempItem = _Item
                if _obj.int[ "6" ] == 0 then
                    sendData( 0 , _obj )
                else 
                    sendData( 1 , _obj )
                end
             elseif sender == btn_lineup then
                UISoulUpgrade.setInfo( _obj )
                UIManager.pushScene( "ui_soul_upgrade" )
             end
         end
    end
    btn_lock:setPressedActionEnabled( true )
    btn_lock:addTouchEventListener( onEvent )
    btn_lineup:setPressedActionEnabled( true )
    btn_lineup:addTouchEventListener( onEvent )


    local text_name = ccui.Helper:seekNodeByName( _Item , "text_name" )
    text_name:setString( DictFightSoul[ tostring( _obj.int[ "3" ] ) ].name )
    local text_quality = ccui.Helper:seekNodeByName( _Item , "text_quality" )
  --  cclog("aa .. "..tostring( _obj.int[ "4" ] ))
    text_quality:setString( DictFightSoulQuality[ tostring( _obj.int[ "4" ] ) ].name )
    local text_describe = ccui.Helper:seekNodeByName( _Item , "text_describe" )
    local proType , proValue , sellSilver = utils.getSoulPro( _obj.int[ "3" ] , _obj.int[ "5" ] )
    if _obj.int[ "4" ] == 5 then
        text_describe:setString( Lang.ui_soul_bag3..sellSilver..Lang.ui_soul_bag4 )
        btn_lock:setVisible( false )
        btn_lineup:setVisible( false )
    elseif _obj.int[ "4" ] == 4 and DictFightSoul[ tostring( _obj.int[ "3" ] ) ].isExpFightSoul == 1 then
        text_describe:setString( Lang.ui_soul_bag5..DictFightSoul[ tostring( _obj.int[ "3" ] ) ].initExp..Lang.ui_soul_bag6)
        btn_lock:setVisible( false )
        btn_lineup:setVisible( false )
    else
        btn_lock:setVisible( true )
        btn_lineup:setVisible( true )
        if proValue < 1 then
            text_describe:setString( DictFightProp[tostring( proType )].name.."+"..( proValue * 100 ).."%" )
        else
            text_describe:setString( DictFightProp[tostring( proType )].name.."+"..proValue )
        end
    end
    local text_lv = ccui.Helper:seekNodeByName( _Item , "text_lv" )
    if _obj.int[ "5" ] == 10 then
        text_lv:setString( "LV.MAX" )
    else
        text_lv:setString( "LV.".._obj.int[ "5" ] )
    end
    local text_for = ccui.Helper:seekNodeByName( _Item , "text_for" )
    if _obj.int[ "7" ] == 0 then
        text_for:setVisible( false )
    else
        text_for:setVisible( true )
        local cardName = DictCard[tostring(net.InstPlayerCard[tostring( _obj.int[ "7" ])].int["3"])].name
        text_for:setString(Lang.ui_soul_bag7..cardName )
    end
    local image_lock = ccui.Helper:seekNodeByName( _Item , "image_lock" )
    if _obj.int[ "6" ] == 0 then
        btn_lock:setTitleText( Lang.ui_soul_bag8 ) 
        image_lock:setVisible( false )
    else
        btn_lock:setTitleText( Lang.ui_soul_bag9 )
        image_lock:setVisible( true )
    end
    local image_frame_soul = ccui.Helper:seekNodeByName( _Item , "image_frame_soul" )
    utils.ShowFightSoulQuality( image_frame_soul , _obj.int[ "4" ] , 1 )
    utils.changeNameColor( text_name , _obj.int[ "4" ] , dp.Quality.fightSoul )
    ActionManager.setSoulEffectAction( _obj.int[ "3" ] , image_frame_soul:getChildByName( "image_soul" ) )
    utils.addSoulParticle( image_frame_soul:getChildByName( "image_soul" ) , DictFightSoul[ tostring( _obj.int[ "3" ] )].effects , DictFightSoul[ tostring( _obj.int[ "3" ] )].fightSoulQualityId )
end

local function layoutScrollView(_listData, _initItemFunc)
    scrollView:removeAllChildren()
    scrollView:jumpToTop()
    local _innerHeight = 0
    for key, obj in pairs(_listData) do
        local scrollViewItem = _item:clone()
        _initItemFunc(scrollViewItem, obj)
       -- cclog("aa .. "..obj)
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
            childs[i]:setPosition(scrollView:getContentSize().width / 2, scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
        else
            childs[i]:setPosition(scrollView:getContentSize().width / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
        end
        prevChild = childs[i]
    end
    ActionManager.ScrollView_SplashAction(scrollView)
end

function UISoulBag.init()
	local btn_soul = ccui.Helper:seekNodeByName( UISoulBag.Widget , "btn_soul" )
    local btn_sell = ccui.Helper:seekNodeByName( UISoulBag.Widget , "btn_sell" )
   -- local btn_expansion = ccui.Helper:seekNodeByName( UISoulBag.Widget , "btn_expansion" )
    local btn_help = ccui.Helper:seekNodeByName( UISoulBag.Widget , "btn_help")
    local function onEndEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_soul then
                UIManager.showWidget( "ui_soul_get" )
            elseif sender == btn_sell then
                UISoulList.setType( UISoulList.type.SELL )
                UIManager.pushScene( "ui_soul_list" )
--            elseif sender == btn_expansion then
--                UISoulInstall.setType( UISoulInstall.type.LINEUP, 0 )
--                UIManager.pushScene( "ui_soul_install" )
             elseif sender == btn_help then
                UIAllianceHelp.show({titleName=Lang.ui_soul_bag10,type=8})
            end
        end
    end
    btn_soul:setPressedActionEnabled( true )
	btn_soul:addTouchEventListener( onEndEvent )
    btn_sell:setPressedActionEnabled( true )
    btn_sell:addTouchEventListener( onEndEvent )
    --btn_expansion:setPressedActionEnabled( true )
   -- btn_expansion:addTouchEventListener( onEndEvent )
    btn_help:setPressedActionEnabled( true )
    btn_help:addTouchEventListener( onEndEvent )

    scrollView = ccui.Helper:seekNodeByName( UISoulBag.Widget , "view_fire" )
    _item = scrollView:getChildByName( "image_base_soul" )
    _item:retain()
end

function UISoulBag.setup()
    local label_fight = ccui.Helper:seekNodeByName( UISoulBag.Widget , "label_fight" )
    label_fight:setString( tostring(utils.getFightValue()) )
    local text_gold_number = ccui.Helper:seekNodeByName( UISoulBag.Widget , "text_gold_number" )
    text_gold_number:setString( tostring(net.InstPlayer.int["5"]) )
    local text_silver_number = ccui.Helper:seekNodeByName( UISoulBag.Widget , "text_silver_number" )
    text_silver_number:setString( net.InstPlayer.string["6"] )

    local _soulData = {}
    if net.InstPlayerFightSoul then
        for key , value in pairs ( net.InstPlayerFightSoul ) do
            table.insert( _soulData , value )
        end
    end
    utils.quickSort( _soulData , function ( obj1 , obj2 )
        if obj1.int[ "7" ] == 0 and obj2.int[ "7" ] ~= 0 then
            return true
        elseif obj1.int[ "7" ] ~= 0 and obj2.int[ "7" ] == 0 then
            return false
        elseif obj1.int[ "5" ] < obj2.int[ "5" ] then
            return true
        elseif obj1.int[ "5" ] > obj2.int[ "5" ] then
            return false
        elseif obj1.int[ "4" ] > obj2.int[ "4" ] then
            return true
        elseif obj1.int[ "4" ] < obj2.int[ "4" ] then
            return false
        elseif obj1.int[ "3" ] > obj2.int[ "3" ] then
            return true
        else
            return false
        end
    end )
    --layoutScrollView(_soulData,setScrollViewItem)
    utils.updateScrollView( UISoulBag , scrollView , _item , _soulData , setScrollViewItem )

    local text_ceiling = ccui.Helper:seekNodeByName( UISoulBag.Widget , "text_ceiling" )
    text_ceiling:setString(Lang.ui_soul_bag11..#_soulData.."/"..DictSysConfig[tostring(StaticSysConfig.fightSoulBagUpLimit )].value)
end

function UISoulBag.free()
    _tempObj = nil
    _tempItem = nil
end
