require"Lang"
UIActivityStrongerPreview = { }
local _scrollView
local scrollViewItem
function UIActivityStrongerPreview.init()
    local btn_closed = ccui.Helper:seekNodeByName(UIActivityStrongerPreview.Widget, "btn_closed")
    local btn_close = ccui.Helper:seekNodeByName(UIActivityStrongerPreview.Widget, "btn_close")
    local function btnEvent( sender , eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_closed or sender == btn_close then
                 UIManager.popScene()
            end
        end
    end
    btn_closed:setPressedActionEnabled( true )
    btn_close:setPressedActionEnabled( true )
    btn_closed:addTouchEventListener( btnEvent )
    btn_close:addTouchEventListener( btnEvent )
    _scrollView = ccui.Helper:seekNodeByName(UIActivityStrongerPreview.Widget, "view_award_lv")
    scrollViewItem = _scrollView:getChildByName("image_base_gift")
    scrollViewItem:setAnchorPoint(cc.p(0.5,0.5))
    scrollViewItem:retain()

end

local function setScrollViewItem(item, data)
    ccui.Helper:seekNodeByName(item,"image_base_hint"):getChildByName("text_lv"):setString(Lang.ui_activity_Stronger_preview1 ..data.id.. Lang.ui_activity_Stronger_preview2) 
    local reward = utils.stringSplit(data.rewards , ";")
    for i = 1 , 4 do
        local image_frame_good = ccui.Helper:seekNodeByName(item,"image_frame_good"..i)
        if i <= #reward then
            image_frame_good:setVisible(true);
            local thing = utils.getItemProp(reward[i])
            image_frame_good:getChildByName("text_name"):setString(thing.name)
            image_frame_good:getChildByName("text_number"):setString("x"..thing.count)
            image_frame_good:getChildByName("image_good"):loadTexture(thing.smallIcon)
            image_frame_good:loadTexture(thing.frameIcon)
        else
            image_frame_good:setVisible(false);
        end
    end
end

function UIActivityStrongerPreview.setup()
    local rankAward = {}
    for key, obj in pairs(DictArenaStrongMan) do
	    rankAward[#rankAward+1] = obj
    end
    utils.quickSort(rankAward, function(obj1, obj2) if obj1.id > obj2.id then return true end end)
    _scrollView:removeAllChildren()
    utils.updateScrollView(UIActivityStrongerPreview, _scrollView, scrollViewItem, rankAward, setScrollViewItem, { space = 8 })

end


function UIActivityStrongerPreview.free()


end
