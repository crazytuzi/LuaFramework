require"Lang"
UIFieldHint = {}
local _itemIndex = nil
local _enchantmentData = nil
function UIFieldHint.init()
    local btn_close = ccui.Helper:seekNodeByName( UIFieldHint.Widget , "btn_close" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            UIManager.popScene()
        end
    end
    UIFieldHint.Widget:addTouchEventListener( onEvent )
    btn_close:setPressedActionEnabled( true )
    btn_close:addTouchEventListener( onEvent )
end
function UIFieldHint.setup()
    local image_frame_card = ccui.Helper:seekNodeByName( UIFieldHint.Widget , "image_frame_card" )
    local instId = tonumber( _enchantmentData[ #_enchantmentData ] )
    if instId == 0 then
        image_frame_card:getChildByName( "image_card" ):setVisible( false )
    else
        image_frame_card:getChildByName( "image_card" ):setVisible( true )
        local instData = net.InstPlayerCard[ tostring(instId) ]
        local qualityImg = utils.getQualityImage(dp.Quality.card, instData.int["4"], dp.QualityImageType.small)
        image_frame_card:loadTexture( qualityImg )
        local instCardData = net.InstPlayerCard[tostring(instId)]
        local isAwake = instCardData.int["18"] --是否已觉醒 0-未觉醒 1-觉醒
        image_frame_card:getChildByName( "image_card" ):loadTexture("image/" .. DictUI[tostring( isAwake == 1 and DictCard[ tostring( instData.int["3"] ) ].awakeSmallUiId or DictCard[ tostring( instData.int["3"] ) ].smallUiId ) ].fileName ) 
    end
    local conditionData = utils.stringSplit( DictEnchantment[ tostring( _itemIndex ) ].addition , ";" )
    local title = { Lang.ui_field_hint1 , Lang.ui_field_hint2 , Lang.ui_field_hint3 }
    local conditionName = { Lang.ui_field_hint4 , Lang.ui_field_hint5 , Lang.ui_field_hint6 }
    for i = 1 , 3 do
        local text_field = ccui.Helper:seekNodeByName( UIFieldHint.Widget , "text_field"..i )
        local text_condition = ccui.Helper:seekNodeByName( UIFieldHint.Widget , "text_condition"..i )
        if i <= #conditionData then
            local obj = utils.stringSplit( conditionData[ i ] , "_" )
            text_field:setVisible( true )
            text_condition:setVisible( true )
            text_field:setString( title[ i ] .. "：" .. DictFightProp[ tostring( obj[ 1 ] ) ].name .. "+" .. ( obj[ 2 ] * 100 ) .. "%" )
            local conditionIndex1 = tonumber( obj[ 3 ] )
            local conditionIndex2 = tonumber( obj[ 4 ] )
            local condition1 = ""
            local condition2 = ""
            local cardData = {}
            local comCount = 0
            if conditionIndex1 == 0 then
                condition1 = Lang.ui_field_hint7
                cardData[ #cardData + 1 ] = _enchantmentData[ #_enchantmentData ]
                comCount = 1
            elseif conditionIndex1 == #_enchantmentData then
                condition1 = Lang.ui_field_hint8
                cardData = _enchantmentData
                comCount = conditionIndex1
            else
                condition1 = Lang.ui_field_hint9 .. conditionIndex1 .. Lang.ui_field_hint10
                cardData = _enchantmentData
                comCount = conditionIndex1
            end
            local isEnough = false
            if conditionIndex2 == 1 then
                condition2 = obj[ 5 ] .. Lang.ui_field_hint11
                local aa = 0
                for key ,value in pairs( cardData ) do
                    if tonumber( value ) > 0 and net.InstPlayerCard[ tostring( value ) ].int[ "9" ] >= tonumber( obj[ 5 ] ) then
                        aa = aa + 1
                    end
                end
                if aa >= comCount then
                    isEnough = true
                else
                    isEnough = false
                end
            elseif conditionIndex2 == 2 then
                condition2 = DictTitleDetail[ tostring( obj[ 5 ] ) ].description
                local aa = 0
                for key ,value in pairs( cardData ) do
                    if tonumber( value ) > 0 and net.InstPlayerCard[ tostring( value ) ].int[ "6" ] >= tonumber( obj[ 5 ] ) then
                        aa = aa + 1
                    end
                end
                if aa >= comCount then
                    isEnough = true
                else
                    isEnough = false
                end
            elseif conditionIndex2 == 3 then
                if tonumber( obj[ 6 ] ) == 0 then
                    condition2 = DictQuality[ tostring( obj[ 5 ] ) ].name 
                else
                    condition2 = obj[ 6 ] .. Lang.ui_field_hint12 .. DictQuality[ tostring( obj[ 5 ] ) ].name 
                end
                local aa = 0
                for key ,value in pairs( cardData ) do
                    if tonumber( value ) > 0 and net.InstPlayerCard[ tostring( value ) ].int[ "4" ] == tonumber( obj[ 5 ] ) and net.InstPlayerCard[ tostring( value ) ].int[ "5" ] > tonumber( obj[ 6 ] ) then
                        aa = aa + 1
                    elseif tonumber( value ) > 0 and net.InstPlayerCard[ tostring( value ) ].int[ "4" ] > tonumber( obj[ 5 ] ) then
                        aa = aa + 1
                    end
                end
                if aa >= comCount then
                    isEnough = true
                else
                    isEnough = false
                end
            end
            text_condition:setString( Lang.ui_field_hint13 .. condition1 .. Lang.ui_field_hint14 .. conditionName[ conditionIndex2 ] .. Lang.ui_field_hint15 .. condition2 )
            if isEnough then
                text_field:setTextColor( cc.c3b( 255 , 0 , 0 ) )
                text_condition:setTextColor( cc.c3b( 255 , 0 , 0 ) )
            else
                text_field:setTextColor( cc.c3b( 255 , 255 , 255 ) )
                text_condition:setTextColor( cc.c3b( 255 , 255 , 255 ) )
            end
        else
            text_field:setVisible( false )
            text_condition:setVisible( false )
        end
    end
end
function UIFieldHint.free()
    _itemIndex = nil
end
function UIFieldHint.setData( params )
    _itemIndex = params.index
    _enchantmentData = utils.stringSplit( params.data , ";" )
end
