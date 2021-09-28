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
-- 日期：14-10-31
--

local HuaShanBattleScene = class("HuaShanBattleScene",function ()
    return display.newScene("HuaShanBattleScene")
end)

function HuaShanBattleScene:ctor(param)
    display.addSpriteFramesWithFile("ui/ui_battle.plist", "ui/ui_battle.png")

    game.runningScene = self
    local _data = param.data

    local _resultFunc = function(data)

        self:performWithDelay(function()
            display.replaceScene(require("game.huashan.HuaShanScene").new())
        end, 1)
    end

    local battleLayer = require("game.Battle.BattleLayer").new({
        fubenType = LUNJIAN,
        fubenId = 3,
        battleData = _data,
        resultFunc = _resultFunc,
    })
    self:addChild(battleLayer)
end

function HuaShanBattleScene:onEnter()
    game.runningScene = self
end

return HuaShanBattleScene


