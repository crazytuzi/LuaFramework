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
-- 日期：14-10-15
--

local PosHero = class("PosHero", function()
    return display.newNode()
end)

function PosHero:ctor(param)
    local _info = param.info
    local _index = param.index or 1
    local _listener = param.listener

    local proxy = CCBProxy:create()
    self._rootnode = {}

--    dump(_info)

    local node = CCBuilderReaderLoad("huashan/huashan_hero_pos", proxy, self._rootnode)
    self:addChild(node)

    if _info and _info.cards then

        local randomIndex = math.random(1, #_info.cards)
        for k, v in ipairs(_info.cards) do
            if v.id == _info.showId then
                randomIndex = k
                break
            end
        end

        local randomHero = _info.cards[randomIndex]
        local hero = ResMgr.getCardData(randomHero.cardId)
        local path = ResMgr.getMidImage(hero["arr_image"][randomHero.cls + 1], ResMgr.HERO)
        local sprite = display.newSprite(path)
        if sprite then
            self._rootnode["imageSprite"]:setDisplayFrame(sprite:getDisplayFrame())
        else
            CCMesssageBox("缺少：" .. hero["arr_image"][1], "error")
        end
        self._rootnode["touchNode"]:setTouchEnabled(true)
        self._rootnode["touchNode"]:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)

            if event.name == "began" then
                if _listener then
                    self._rootnode["touchNode"]:setTouchEnabled(false)
                    _listener(_index)

                    self:performWithDelay(function()
                        self._rootnode["touchNode"]:setTouchEnabled(true)
                    end, 1)
                end
            end
        end)
    end

    self.floorName = ui.newTTFLabelWithShadow({
        text = "",
        font = FONTS_NAME.font_fzcy,
        size = 18,
        align = ui.TEXT_ALIGN_LEFT,
        color = ccc3(254, 249, 0)
    })
    self.floorName:setString(string.format("%d层", _index))
    self._rootnode["floorLabel"]:addChild(self.floorName)
end

function PosHero:failFlag()
    self._rootnode["flagSprite"]:setDisplayFrame(display.newSpriteFrame("huashan_board_0.png"))
end

function PosHero:showSelfHero(info)

    self.floorName:removeSelf()
    self.floorName = ui.newTTFLabelWithShadow({
        text = "",
        font = FONTS_NAME.font_fzcy,
        size = 20,
        align = ui.TEXT_ALIGN_LEFT,
        color = ccc3(254, 255, 255)
    })
    self.floorName:setPositionY(-2)
    self.floorName:setString(game.player:getPlayerName())
    self.floorName:setColor(NAME_COLOR[info.star or 4])
    self._rootnode["floorLabel"]:addChild(self.floorName)

    self._rootnode["flagSprite"]:setDisplayFrame(display.newSpriteFrame("huashan_name_bg.png"))

    dump(info)
    local hero = safe_call(c_func(ResMgr.getCardData, info.cardId)) or data_card_card[game.player.m_gender]
    dump(info)
    local path = ResMgr.getMidImage(hero["arr_image"][info.cls + 1], ResMgr.HERO)
    local sprite = display.newSprite(path)
    self._rootnode["imageSprite"]:setDisplayFrame(sprite:getDisplayFrame())
end

function PosHero:showTmpSelf(info)
    local hero = ResMgr.getCardData(info.cardId)
    local path = ResMgr.getMidImage(hero["arr_image"][info.cls + 1], ResMgr.HERO)
    local sprite = display.newSprite(path)
    local imageSprite = self._rootnode["imageSprite"]
    imageSprite:addChild(sprite)
    sprite:setPosition(imageSprite:getContentSize().width / 2, imageSprite:getContentSize().height / 2)

    sprite:runAction(transition.sequence({
        CCFadeOut:create(0.8),
        CCRemoveSelf:create()
    }))
end

function PosHero:playAnim(info, tagetPos, callback)

    local hero = ResMgr.getCardData(info.cardId)
    local path = ResMgr.getMidImage(hero["arr_image"][info.cls + 1], ResMgr.HERO)
    local sprite = display.newSprite(path)
    local imageSprite = self._rootnode["imageSprite"]
    imageSprite:addChild(sprite)
    sprite:setPosition(imageSprite:getContentSize().width / 2, imageSprite:getContentSize().height / 2)

    sprite:runAction(transition.sequence({
        CCMoveBy:create(1, tagetPos),
        CCRemoveSelf:create(),
        CCCallFunc:create(function()
            if callback then
                callback()
            end
        end)
    }))

end

return PosHero

