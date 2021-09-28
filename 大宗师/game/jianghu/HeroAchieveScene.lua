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
-- 日期：14-10-5
--
local data_starachieve_starachieve = require("data.data_starachieve_starachieve")
local Item = class("Item", function()
    return CCTableViewCell:new()
end)

function Item:getContentSize()
    return CCSizeMake(display.width, 150)
end

function Item:create(param)
    local _viewSize = param.viewSize
    --    local _itemData = param.itemData

    local proxy = CCBProxy:create()
    self._rootnode = {}
    self._bg = CCBuilderReaderLoad("jianghulu/jianghulu_chengjiu_item.ccbi", proxy, self._rootnode)
    self._bg:setPosition(_viewSize.width / 2, 0)
    self:addChild(self._bg)

    self:refresh(param)
    return self
end

function Item:refresh(param)
    local _itemData = param.itemData
    local _stars     = param.stars or 0
    local _idx       = param.idx
    if _itemData.good <= _stars then
        self._rootnode["nameLabel_1"]:setString(_itemData.name)
        self._rootnode["targetLabel_1"]:setString(_itemData.condition)
        self._rootnode["tagetNumLabel_1"]:setString(tostring(_itemData.good))
        self._rootnode["effectLabel_1"]:setString(_itemData.effect)
        self._rootnode["item_1"]:setVisible(true)
        self._rootnode["item_2"]:setVisible(false)



        self._rootnode["iconBg"]:setDisplayFrame(display.newSpriteFrame(string.format("icon_frame_bg_%d.png", _itemData.quality)))
        self._rootnode["iconBoard"]:setDisplayFrame(display.newSpriteFrame(string.format("icon_frame_board_%d.png", _itemData.quality)))
    else
        self._rootnode["nameLabel_2"]:setString(_itemData.name)
        self._rootnode["targetLabel_2"]:setString(_itemData.condition)
        self._rootnode["tagetNumLabel_2"]:setString(tostring(_itemData.good))
        self._rootnode["effectLabel_2"]:setString(_itemData.effect)
        self._rootnode["item_2"]:setVisible(true)
        self._rootnode["item_1"]:setVisible(false)
        self._rootnode["expLabel"]:setString(string.format("%d/%d", _stars, _itemData.good))

        local origin = self._rootnode["expBar"]:getTextureRect().origin
        local size = self._rootnode["barBg"]:getTextureRect().size
        self._rootnode["expBar"]:setTextureRect(CCRectMake(origin.x, origin.y, size.width * (_stars / _itemData.good), size.height))
    end
end

local HeroAchieveScene = class("HeroAchieveScene", function()
    return require("game.BaseSceneExt").new({
        contentFile = "jianghulu/jianghulu_chengjiu_scene.ccbi",
        bottomFile  = "jianghulu/jianghulu_chengjiu_bottom.ccbi",
        topFile     = "jianghulu/jianghulu_chengjiu_top.ccbi"
    })
end)

function HeroAchieveScene:ctor(stars)
    self._stars = stars or 0

    local _bg = display.newSprite("ui_common/common_bg.png")
    local _bgW = display.width
    local _bgH = display.height - self._rootnode["bottomMenuNode"]:getContentSize().height - self._rootnode["topFrameNode"]:getContentSize().height
    _bg:setPosition(_bgW / 2, _bgH / 2 + self._rootnode["bottomMenuNode"]:getContentSize().height)

    _bg:setScaleX(_bgW / _bg:getContentSize().width)
    _bg:setScaleY(_bgH / _bg:getContentSize().height)
    self:addChild(_bg, 0)

    self._rootnode["backBtn"]:addHandleOfControlEvent(function()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        pop_scene()
    end, CCControlEventTouchUpInside)

    self._itemsData = {}
    for k, v in ipairs(data_starachieve_starachieve) do
        table.insert(self._itemsData, v)
    end

    self:refresh()
end

function HeroAchieveScene:refresh()
    self._scrollView = require("utility.TableViewExt").new({
        size        = CCSizeMake(self._rootnode["scrollListView"]:getContentSize().width, self._rootnode["scrollListView"]:getContentSize().height - 17),
        direction   = kCCScrollViewDirectionVertical,
        createFunc  = function(idx)
            idx = idx + 1

            return Item.new():create({
                viewSize = self._rootnode["scrollListView"]:getContentSize(),
                idx      = idx,
                itemData = self._itemsData[idx],
                stars    = self._stars
            })
        end,
        refreshFunc = function(cell, idx)
            idx = idx + 1
            cell:refresh({
                idx = idx,
                itemData = self._itemsData[idx],
                stars    = self._stars
            })
        end,
        cellNum   = #self._itemsData,
        cellSize  = Item.new():getContentSize(),
        touchFunc = function(cell)

        end
    })
    self._scrollView:setPosition(0, 10)
    self._rootnode["scrollListView"]:addChild(self._scrollView)
end

return HeroAchieveScene

