require "SDK"
UIShare = {}
local _data = nil
local function callBack( pack )
    UIManager.popScene()
    UIManager.flushWidget(UIActivityShare)
end
--分享成功后的回调
function UIShare.getResuilt()
    UIManager.showLoading()
    local _msgData = {
        header = StaticMsgRule.shareAndReceive, --协议号
        msgdata = {
            int = {
                id = tonumber( _data.id )
                }
        }
    }
    netSendPackage(_msgData, callBack)
end

function UIShare.init()
   btn_close = ccui.Helper:seekNodeByName(UIShare.Widget, "btn_close")
   btn_share = ccui.Helper:seekNodeByName(UIShare.Widget, "btn_share")

   btn_close:setPressedActionEnabled(true)
   btn_share:setPressedActionEnabled(true)
   local function btnEvent(sender,eventType)
       if eventType == ccui.TouchEventType.ended then
          if sender == btn_close then
             UIManager.popScene()
          elseif sender == btn_share then
             --cclog("分享到微信---------------------—— ")
            SDK.share( { name = _data.title ,description = _data.description} )

          end
       end
   end
   btn_share:addTouchEventListener(btnEvent)
   btn_close:addTouchEventListener(btnEvent)
end

function UIShare.setup()
   local text_condition = ccui.Helper:seekNodeByName(UIShare.Widget,"text_condition")
   local text_good_0 = ccui.Helper:seekNodeByName(UIShare.Widget,"text_good_0") 
   local text_name = ccui.Helper:seekNodeByName(UIShare.Widget,"text_name")
   text_condition:setString(_data.title) 
   text_good_0:setString(_data.description)
   text_name:setString(_data.count)
end

function UIShare.free()
    _data = nil
end

function UIShare.setData( data )
    _data = data
end
