UIPosterRecharge = { }


function UIPosterRecharge.init()
    local panel_jian = ccui.Helper:seekNodeByName( UIPosterRecharge.Widget , "panel_jian")
    local panel_lingyu = ccui.Helper:seekNodeByName( UIPosterRecharge.Widget , "panel_lingyu")
    local panel_mingjia = ccui.Helper:seekNodeByName( UIPosterRecharge.Widget , "panel_mingjia")
    local panel_guan = ccui.Helper:seekNodeByName( UIPosterRecharge.Widget , "panel_guan")
    local btn_closed = ccui.Helper:seekNodeByName( UIPosterRecharge.Widget , "btn_closed")    
    utils.addFrameParticle( panel_jian ,true ,1.5 ) 
    utils.addFrameParticle( panel_lingyu ,true ,1.5 )  
    utils.addFrameParticle( panel_mingjia ,true ,1.5 )  
    utils.addFrameParticle( panel_guan ,true ,1.5 )            
    local function btnEvent( sender , eventType)
        if eventType == ccui.TouchEventType.ended then
             if sender == btn_closed then
                UIManager.popScene("ui_poster_recharge")
                UIManager.pushScene("ui_activity_hint")
             end
        end
    end
    btn_closed:setPressedActionEnabled( true )
    btn_closed:addTouchEventListener( btnEvent )
end

function UIPosterRecharge.setup()
   
end

function UIPosterRecharge.free()

end
