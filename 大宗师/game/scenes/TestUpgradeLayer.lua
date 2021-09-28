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
-- 日期：14-8-23
--

local TestUpgradeLayer = class("TestUpgradeLayer", function()
    return require("utility.ShadeLayer").new()
end)

function TestUpgradeLayer:ctor()

    local proxy = CCBProxy:create()
    local rootnode = {}
    local node = CCBuilderReaderLoad("public/testupdate.ccbi", proxy, rootnode)
    node:setPosition(display.cx, display.cy)
    self:addChild(node)



    rootnode["tag_close"]:addHandleOfControlEvent(function()
        self:removeSelf()
    end, CCControlEventTouchUpInside)

    rootnode["testMusic"]:addHandleOfControlEvent(function()
        GameAudio.playSound(ResMgr.getSFX("u_testmusic"))
    end, CCControlEventTouchUpInside)

    rootnode["testAnim"]:addHandleOfControlEvent(function()
        local path = "testanim/yanlong/yanlong.ExportJson"
        CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo(path)
        CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(path)
        local tempArma = CCArmature:create("yanlong")
        tempArma:getAnimation():setFrameEventCallFunc(function(bone,evt,originFrameIndex,currentFrameIndex) --setMovementEventCallFunc(function(armatureBack,movementType,movementID)

        end)
        tempArma:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)

        end)

        tempArma:getAnimation():playWithIndex(0)
        rootnode["animNode"]:addChild(tempArma)
    end, CCControlEventTouchUpInside)

    rootnode["testRes"]:addHandleOfControlEvent(function()
        local sprite = display.newSprite("testanim/bixiejiandian1.png")
        rootnode["spriteNode"]:addChild(sprite)
    end, CCControlEventTouchUpInside)

end

return TestUpgradeLayer


