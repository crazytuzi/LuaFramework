--
--                   _ooOoo_
--                  o8888888o
--                  88" . "88
--                  (| -_- |)
--                  O\  =  /O
--               ____/`---'\____
--             .'  \\|     |//  `.
--            /  \\|||  :  |||//  \
--           /  _||||| -:- |||||-  \
--           |   | \\\  -  /// |   |
--           | \_|  ''\---/''  |   |
--           \  .-\__  `-`  ___/-. /
--         ___`. .'  /--.--\  `. . __
--      ."" '<  `.___\_<|>_/___.'  >'"".
--     | | :  `- \`.;`\ _ /`;.`/ - ` : | |
--     \  \ `-.   \_ __\ /__ _/   .-` /  /
--======`-.____`-.___\_____/___.-`____.-'======
--                   `=---='
--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
--                 Buddha bless
--
-- 日期：14-8-29
--
local Get10CardLayer = class("Get10CardLayer", function ()
    return require("utility.ShadeLayer").new()
end)

function Get10CardLayer:ctor(isOneFree, times, listener)
    local proxy = CCBProxy:create()
    local subNode = {}
    local submenu = CCBuilderReaderLoad("shop/shop_zhaojiang.ccbi", proxy, subNode)
    submenu:setPosition(display.width/2, display.height/2)
    self:addChild(submenu, 10)

    if isOneFree ~= nil and isOneFree == true then 
        subNode["leftCost"]:setVisible(false)
        subNode["leftFree_lbl"]:setVisible(true)
    else
        subNode["leftCost"]:setVisible(true)
        subNode["leftFree_lbl"]:setVisible(false)
    end


    -- close button
    subNode["tag_close"]:addHandleOfControlEvent(function(eventName,sender)
GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        sender:runAction(transition.sequence({
            CCCallFunc:create(function()
                self:removeSelf()
            end)
        }))
    end,
        CCControlEventTouchUpInside)

    -- left times
--    local leftTimesLabel = subNode["tag_left_times"]
    local textLabel = ui.newBMFontLabel({
            text = "",
            font = FONTS_NAME.font_zhaojiang,
            x = subNode["tag_left_times"]:getContentSize().width/2,
            y = subNode["tag_left_times"]:getContentSize().height/2
        })
    textLabel:setScale(0.9)
    subNode["tag_left_times"]:addChild(textLabel)
    
    
    if times > 0 then
        textLabel:setString(tostring(string.format("再招 %d 次后,下次招募必得", times)))
    else
        textLabel:setString("             下次招募必得")
    end



    subNode["tag_zhaojiang_1"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT,function()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if listener then
            listener(1)
        end
        self:removeSelf()
    end)


    subNode["tag_zhaojiang_10"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if listener then
            listener(10)
        end
        self:removeSelf()
    end,
        CCControlEventTouchUpInside)
end

return Get10CardLayer

