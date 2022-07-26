require"Lang"
UIActivityRun = {}
function UIActivityRun.init()
    local btn_join = ccui.Helper:seekNodeByName( UIActivityRun.Widget , "btn_join" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_join then
                if net.InstUnionMember and net.InstUnionMember.int["2"] ~= 0 then
--                    UIManager.hideWidget("ui_activity_time")
--                    UIManager.hideWidget("ui_menu")
--                    UIManager.showWidget("ui_alliance_run")
                    netSendPackage( { header = StaticMsgRule.sendTurtleOpen , msgdata = {} } , function ( pack )
                                local openState = pack.msgdata.int.isOpen
                                if openState == 0 then
                                    UIManager.showToast( Lang.ui_activity_run1 )
                                else
                                    UIManager.hideWidget("ui_activity_time")
                                    UIManager.hideWidget("ui_menu")
                                    UIManager.showWidget("ui_alliance_run")
                                end
                            end )  
                else
                    UIManager.showToast(Lang.ui_activity_run2)
                end
                
            end
        end
    end
    btn_join:setPressedActionEnabled( true )
    btn_join:addTouchEventListener( onEvent )
end
function UIActivityRun.setup()

end
function UIActivityRun.free()

end
