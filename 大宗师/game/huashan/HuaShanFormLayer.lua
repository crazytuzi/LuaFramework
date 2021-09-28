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
-- 日期：14-10-16
--

local HuaShanFormLayer = class("", function()
    return require("utility.ShadeLayer").new()
end)

function HuaShanFormLayer:ctor(param)
    local _info = param.info
    local _heros = param.heros
    local _floor = param.floor
    local _index = param.index

    dump(param)

--    dump(_info)

    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBuilderReaderLoad("huashan/huashan_form_layer", proxy, self._rootnode)
    node:setPosition(display.cx, display.cy)
    self:addChild(node)

    self._rootnode["titleLabel"]:setString(string.format("论剑第%d层", _floor))

    self._rootnode["tag_close"]:addHandleOfControlEvent(function()
        self:removeSelf()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
    end, CCControlEventTouchUpInside)

    self._rootnode["enterBtn"]:addHandleOfControlEvent(function()
        if _index <= _floor then
            show_tip_label("当前层级已经挑战")
            return
        end

        if _floor == 0 or _floor == -1 or (_index == _floor + 1) then
            self._rootnode["enterBtn"]:setEnabled(false)
            self:performWithDelay(function()
                self._rootnode["enterBtn"]:setEnabled(true)
                push_scene(require("game.huashan.HuaShanSettingScene").new({
                    heros = _heros,
                    floor = _index
                }))
            end, 0.1)
        end

        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    end, CCControlEventTouchUpInside)

    self._rootnode["zdlLabel"]:setString(tostring(_info.combat))
    ResMgr.oppName = _info.name
    local heroNameLabel = ui.newTTFLabelWithOutline({
        text = _info.name,
        font = FONTS_NAME.font_fzcy,
        size = 20,
        color = NAME_COLOR[_info.cards[1].star or 3],
        outlineColor = ccc3(255,255,255),
        align = ui.TEXT_ALIGN_LEFT
    })
    self._rootnode["playerNameLabel"]:addChild(heroNameLabel)

    for i = 1, 6 do
        self._rootnode[string.format("headIcon_%d", i)]:setVisible(false)
    end


    for i = 1, 6 do
        if _info.cards[i] then
            local _baseInfo = ResMgr.getCardData(_info.cards[i].cardId)
            local name
            if _info.cards[i].cardId == 1 or _info.cards[i].cardId == 2 then
                name = _info.name
            else
                name = _baseInfo.name
            end

            local heroNameLabel = ui.newTTFLabelWithShadow({
                text = name,
                font = FONTS_NAME.font_fzcy,
                size = 18,
                color = NAME_COLOR[_info.cards[i].star],
                align = ui.TEXT_ALIGN_CENTER
            })
            self._rootnode[string.format("heroNameLabel_%d", _info.cards[i].pos)]:addChild(heroNameLabel)

            if _info.cards[i].cls > 0 then
                local clsLabel = ui.newTTFLabelWithShadow({
                    text = "+" .. tostring(_info.cards[i].cls),
                    font = FONTS_NAME.font_fzcy,
                    size = 18,
                    color = ccc3(0, 228,62),
                    align = ui.TEXT_ALIGN_CENTER,
                })
                heroNameLabel:setPosition(-clsLabel:getContentSize().width / 2, 0)
                clsLabel:setPosition(heroNameLabel:getContentSize().width / 2, 0)
                self._rootnode[string.format("heroNameLabel_%d", _info.cards[i].pos)]:addChild(clsLabel)
            end
--
            ResMgr.refreshIcon({
                id = _baseInfo.id,
                resType = ResMgr.HERO,
                cls = _info.cards[i].cls,
                itemBg = self._rootnode[string.format("iconSprite_%d", _info.cards[i].pos)]
            })
            local jobIcon = display.newSprite(string.format("#icon_frame_%d.png", _baseInfo.job))
            jobIcon:setPosition(15, 15)
            jobIcon:setScale(0.7)
            self._rootnode[string.format("iconSprite_%d", _info.cards[i].pos)]:addChild(jobIcon)

            local levelLabel = ui.newTTFLabelWithShadow({
                text = tostring(_info.cards[i].level),
                font = FONTS_NAME.font_fzcy,
                size = 20,
                align = ui.TEXT_ALIGN_RIGHT
            })
            levelLabel:setPosition(self._rootnode[string.format("iconSprite_%d", _info.cards[i].pos)]:getContentSize().width - 4, 13)
            self._rootnode[string.format("iconSprite_%d", _info.cards[i].pos)]:addChild(levelLabel)

            self._rootnode[string.format("headIcon_%d", _info.cards[i].pos)]:setVisible(true)
        end
    end

end

return HuaShanFormLayer

