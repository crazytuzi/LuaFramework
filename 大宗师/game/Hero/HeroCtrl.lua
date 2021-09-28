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
-- 日期：15-1-30
--

HeroCtrl = {}


function HeroCtrl.request(objId, callback)
    RequestHelper.hero.info({
        cid = objId,
        callback = function(data)
            callback(data)
        end
    })
end

function HeroCtrl.createInfoLayer(objId, index, refreshFunc, changeFunc)

    HeroCtrl.request(objId, function(heroInfo)
        local layer = require("game.Hero.HeroInfoLayer2").new({
            info = heroInfo,
            index = index,
            refreshHero = refreshFunc,
            changeHero = changeFunc
        }, 1)

        game.runningScene:addChild(layer, 100)
    end)

end


return HeroCtrl

