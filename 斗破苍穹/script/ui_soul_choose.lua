UISoulChoose = {}
UISoulChoose.type = {
    UPDATE = 0 ,
    SELL = 1
}
local boxSilver = nil
local boxGreen = nil
local boxBlue = nil
local boxPurple = nil
local _type = nil
local _choosTable = nil
function UISoulChoose.init()
	local btn_sure = ccui.Helper:seekNodeByName( UISoulChoose.Widget , "btn_sure" )
    local btn_all = ccui.Helper:seekNodeByName( UISoulChoose.Widget , "btn_all" )
    local image_silver = ccui.Helper:seekNodeByName( UISoulChoose.Widget , "image_silver" )
    local image_green = ccui.Helper:seekNodeByName( UISoulChoose.Widget , "image_green" )
    local image_blue = ccui.Helper:seekNodeByName( UISoulChoose.Widget , "image_blue" )
    local image_purple = ccui.Helper:seekNodeByName( UISoulChoose.Widget , "image_purple" )
    boxGreen = image_green:getChildByName( "box_choose" )
    boxBlue = image_blue:getChildByName( "box_choose" )
    boxPurple = image_purple:getChildByName( "box_choose" )
    boxSilver = image_silver:getChildByName( "box_choose" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_sure then
                if #_choosTable > 0 then
                    utils.quickSort( _choosTable , function( obj1 , obj2 )
                        if obj1 < obj2 then
                            return true
                        else
                            return false
                        end
                    end)
                    if _type == UISoulChoose.type.UPDATE then
                        UISoulUpgrade.setChooseTable( _choosTable)
                    elseif _type == UISoulChoose.type.SELL then
                        UISoulList.setChooseTable( _choosTable )
                    end
                end
                UIManager.popScene()
            elseif sender == btn_all then
                boxGreen:setSelected( true )
                boxBlue:setSelected( true )
                boxPurple:setSelected( true )
                boxSilver:setSelected( true )
                _choosTable = { 5 , 4 , 3 , 2 }
            end
        end
    end
    btn_sure:setPressedActionEnabled( true )
    btn_sure:addTouchEventListener( onEvent )
    btn_all:setPressedActionEnabled( true )
    btn_all:addTouchEventListener( onEvent )

    local function onSelect( sender , eventType )
        if eventType == ccui.CheckBoxEventType.selected then
            if sender == boxSilver then
                table.insert( _choosTable , 5 )
            elseif sender == boxGreen then
                table.insert( _choosTable , 4 )
            elseif sender == boxBlue then
                table.insert( _choosTable , 3 )
            elseif sender == boxPurple then
                table.insert( _choosTable , 2 )
            end
        elseif eventType == ccui.CheckBoxEventType.unselected then
            local tag = 0
            if sender == boxSilver then
                tag = 5
            elseif sender == boxGreen then
                tag = 4
            elseif sender == boxBlue then
                tag = 3
            elseif sender == boxPurple then
                tag = 2
            end
            for key , value in pairs ( _choosTable ) do
                if value == tag then
                    table.remove( _choosTable , key )
                    break
                end
            end
        end
    end
    boxGreen:addEventListener( onSelect )
    boxBlue:addEventListener( onSelect )
    boxPurple:addEventListener( onSelect )
    boxSilver:addEventListener( onSelect )
end

function UISoulChoose.setup()
    local image_silver = ccui.Helper:seekNodeByName( UISoulChoose.Widget , "image_silver" )
    if _type == UISoulChoose.type.UPDATE then
         image_silver:setVisible( false )
    elseif _type == UISoulChoose.type.SELL then
         image_silver:setVisible( true )
    end
    boxGreen:setSelected( false )
    boxBlue:setSelected( false )
    boxPurple:setSelected( false )
    boxSilver:setSelected( false )
    _choosTable = {}
end

function UISoulChoose.setType( type )
    _type = type
end


function UISoulChoose.free()
    boxGreen = nil
    boxBlue = nil
    boxPurple = nil
    boxSilver = nil
    _type = nil
    _choosTable = nil
end