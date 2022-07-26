UIAllianceMysteriesTotal = {}
local _data = nil
function UIAllianceMysteriesTotal.init()
    local btn_closed = ccui.Helper:seekNodeByName( UIAllianceMysteriesTotal.Widget , "btn_closed" )
    local btn_out = ccui.Helper:seekNodeByName( UIAllianceMysteriesTotal.Widget , "btn_out" )
    local btn_contribute = ccui.Helper:seekNodeByName( UIAllianceMysteriesTotal.Widget , "btn_contribute" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_closed then
                UIManager.popScene()
            elseif sender == btn_out then
                UIManager.popScene()
                UIAllianceMysteries.back()
            elseif sender == btn_contribute then
                UIManager.popScene()
                UIAllianceHall.show()
            end
        end
    end
    btn_closed:setPressedActionEnabled( true )
    btn_closed:addTouchEventListener( onEvent )
    btn_out:setPressedActionEnabled( true )
    btn_out:addTouchEventListener( onEvent )
    btn_contribute:setPressedActionEnabled( true )
    btn_contribute:addTouchEventListener( onEvent )
end
function UIAllianceMysteriesTotal.setup()
    local image_alliance = ccui.Helper:seekNodeByName( UIAllianceMysteriesTotal.Widget , "image_alliance" ) --贡献
    image_alliance:getChildByName("text_number"):setString("×".._data.alliance)
    local image_tree = ccui.Helper:seekNodeByName( UIAllianceMysteriesTotal.Widget , "image_tree" ) --木材
    image_tree:getChildByName("text_number"):setString("×".._data.tree)
    local image_stone = ccui.Helper:seekNodeByName( UIAllianceMysteriesTotal.Widget , "image_stone" )--石头
    image_stone:getChildByName("text_number"):setString("×".._data.stone)
    local image_iron = ccui.Helper:seekNodeByName( UIAllianceMysteriesTotal.Widget , "image_iron" )--铁
    image_iron:getChildByName("text_number"):setString("×".._data.iron)
    local image_gold = ccui.Helper:seekNodeByName( UIAllianceMysteriesTotal.Widget , "image_gold")--金
    image_gold:getChildByName("text_number"):setString("×".._data.gold)
end
function UIAllianceMysteriesTotal.free()
    _data = nil
end
function UIAllianceMysteriesTotal.setData( data )
    _data = data
end