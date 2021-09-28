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

display.addSpriteFramesWithFile("ui_icon_frame.plist", "ui_icon_frame.png")
local IconObj = class("IconObj", function()
    return display.newNode()
end)

function IconObj:ctor(param)
    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBuilderReaderLoad("public/public_icon.ccbi", proxy, self._rootnode)
    node:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
    self:addChild(node, 1)

    self:setContentSize(node:getContentSize())
    self:setAnchorPoint(0.5, 0.5)

    self.levelLabel = ui.newTTFLabelWithShadow({
        text = "",
        font = FONTS_NAME.font_fzcy,
        size = 18,
    })
    self._rootnode["lvLabel"]:addChild(self.levelLabel)

    self.nameLabel = ui.newTTFLabelWithShadow({
        text = "",
        font = FONTS_NAME.font_fzcy,
        size = 20,
        align = ui.TEXT_ALIGN_CENTER
    })
    self._rootnode["heroNameLabel"]:addChild(self.nameLabel)

    self.clsLabel = ui.newTTFLabelWithShadow({
        text = "",
        font = FONTS_NAME.font_haibao,
        size = 18,
        color = ccc3(0, 228,62),
        align = ui.TEXT_ALIGN_CENTER,
    })
    self._rootnode["heroNameLabel"]:addChild(self.clsLabel)

    self:refresh(param)
end


function IconObj:setState(a)
    if a == 1 then
        self._rootnode["maskSprite"]:setVisible(true)
        self._rootnode["tipLabel"]:setString("已上阵")
        self._rootnode["tipLabel"]:setColor(ccc3(0, 228, 62))
    elseif a == 0 then
        self._rootnode["maskSprite"]:setVisible(true)
        self._rootnode["tipLabel"]:setString("已阵亡")
        self._rootnode["tipLabel"]:setColor(ccc3(255, 62, 0))
    elseif a == 3 then 
        self._rootnode["maskSprite"]:setVisible(true)
        self._rootnode["tipLabel"]:setString("已参战")
        self._rootnode["tipLabel"]:setColor(ccc3(255, 62, 0))
    else
        self._rootnode["maskSprite"]:setVisible(false)
    end
end


function IconObj:refresh(param)

    local id = param.id
    if id then
        local card
        if type(id) == "number" then
            card = ResMgr.getCardData(id)
        elseif type(id) == "table" then
            card = id
        end
        if card then
            local cls = param.cls or 0
            local path = "hero/icon/" .. card["arr_icon"][cls + 1]..".png"
            local star = card["star"][cls + 1]
            self._rootnode["bgSprite"]:setDisplayFrame(display.newSpriteFrame(string.format("icon_frame_bg_%d.png", star)))
            self._rootnode["iconSprite"]:setDisplayFrame(display.newSprite(path):getDisplayFrame())
            self._rootnode["boardSprite"]:setDisplayFrame(display.newSpriteFrame(string.format("icon_frame_board_%d.png", star)))
            local name = card.name
            if id == 1 or id == 2 then
                name = game.player:getPlayerName()
            end

            self.nameLabel:setString(name)
            self.nameLabel:setColor(NAME_COLOR[star])
            self._rootnode["jobSprite"]:setDisplayFrame(display.newSpriteFrame(string.format("icon_frame_%s.png", card.job)))

            self.levelLabel:setString(tostring(param.level or 20))
            self.levelLabel:setPosition(-self.levelLabel:getContentSize().width / 2 + 5, 0)

            if cls > 0 then
                self.clsLabel:setString("+" .. tostring(cls))
                self.nameLabel:setPosition(-self.clsLabel:getContentSize().width / 2, 0)
                self.clsLabel:setPosition(self.nameLabel:getContentSize().width / 2, 0)
            else
                self.clsLabel:setString("")
            end
            
            local redBar = self._rootnode["redBar"]
            if param.hp then
                redBar:setVisible(true)  
                local greenBar = self._rootnode["greenBar"]

                if param.hp[1] == 0 then
                    param.state = 0
                end

                local rect = redBar:getTextureRect().size
                greenBar:setTextureRect(CCRectMake(greenBar:getTextureRect().origin.x, greenBar:getTextureRect().origin.y, rect.width * (param.hp[1] / param.hp[2]), rect.height))
            else
                redBar:setVisible(false) 
            end
        end
    end
    self:setState(param.state)

end

return IconObj

