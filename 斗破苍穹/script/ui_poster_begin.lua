UIPosterBegin = {}

function UIPosterBegin.init()
    local btn_closed = ccui.Helper:seekNodeByName( UIPosterBegin.Widget , "btn_closed")
    local vipLevel = net.InstPlayer.int["19"]
    local function btnEvent( sender , eventType)
        if eventType == ccui.TouchEventType.ended then
             if sender == btn_closed then
                if vipLevel == 0 then
                    UIManager.popScene("ui_poster_begin")
                    UIManager.pushScene("ui_poster_recharge")
                else
                    UIManager.popScene("ui_poster_begin")
                    UIManager.pushScene("ui_activity_hint")
                end
             end
        end
    end
    btn_closed:setPressedActionEnabled( true )
    btn_closed:addTouchEventListener( btnEvent )
end

function UIPosterBegin.setup()
 
end


function UIPosterBegin.free( )

end