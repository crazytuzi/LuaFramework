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
-- 日期：14-10-4
--

local HeroShowScene = class("HeroShowScene", function()
    return require("game.BaseSceneExt").new({
        contentFile = "jianghulu/jianghulu_xiake_scene.ccbi",
        bottomFile  = "jianghulu/jianghulu_xiake_bottom.ccbi",
        topFile     = "jianghulu/jianghulu_xiake_top.ccbi"
    })
end)

local HEROTYPE = {
    HAOJIE = 1,
    GAOSHO = 2,
    XINXIU = 3
}

function HeroShowScene:ctor(param)
    self._listData = param.listData
    self._viewType = param.viewType or HEROTYPE.HAOJIE
    self._listener = param.listener

    local _stars   = param.stars or 0

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

    self._rootnode["allLoveLabel"]:setString(tostring(_stars))
    local function onTabBtn(tag)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian)) 
        for i = 1, 3 do
            if tag == i then
                self._rootnode["tab" ..tostring(i)]:selected()
                self._rootnode["tab" ..tostring(i)]:setZOrder(4)
            else
                self._rootnode["tab" ..tostring(i)]:unselected()
                self._rootnode["tab" ..tostring(i)]:setZOrder(3 - i)
            end
        end
        self._viewType = tag

--        self:refresh()
        self._scrollView:resetCellNum(#self._listData[self._viewType])
    end

    --初始化选项卡
    local function initTab()
        for i = 1, 3 do
            self._rootnode["tab" ..tostring(i)]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onTabBtn)
        end
    end

    initTab()
    self:refresh()
    onTabBtn(self._viewType)
end

function HeroShowScene:refresh()

    self._rootnode["touchNode"]:setTouchEnabled(true)
    local posX = 0
    local posY = 0
    self._rootnode["touchNode"]:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
--        dump(event)
        posX = event.x
        posY = event.y
    end)

    self._scrollView = require("utility.TableViewExt").new({
        size        = CCSizeMake(self._rootnode["scrollListView"]:getContentSize().width, self._rootnode["scrollListView"]:getContentSize().height - 17),
        direction   = kCCScrollViewDirectionVertical,
        createFunc  = function(idx)
            idx = idx + 1
            local item = require("game.jianghu.HeroShowItem").new()
            return item:create({
                viewSize = self._rootnode["scrollListView"]:getContentSize(),
                idx      = idx,
                itemData = self._listData[self._viewType][idx],
            })
        end,
        refreshFunc = function(cell, idx)
            idx = idx + 1
            cell:refresh({
                idx = idx,
                itemData = self._listData[self._viewType][idx],
            })
        end,
        cellNum   = #self._listData[self._viewType],
        cellSize  = require("game.jianghu.HeroShowItem").new():getContentSize(),
        touchFunc = function(cell)
--            printf("Hello world %d", cell:getIdx())
            local idx = cell:getIdx() + 1
            local pos = cell:convertToNodeSpace(ccp(posX, posY))
            local sz = cell:getContentSize()
            local i = 0
            if pos.x > sz.width * (4 / 5) and pos.x < sz.width then
                i = 5
            elseif pos.x > sz.width * (3 / 5)  then
                i = 4
            elseif pos.x > sz.width * (2 / 5)  then
                i = 3
            elseif pos.x > sz.width * (1 / 5) then
                i = 2
            elseif pos.x > 0 then
                i = 1
            end

            if i >= 1 and i <= 5 then
                if self._listData[self._viewType][idx] and self._listData[self._viewType][idx][i] then
--                    dump(self._listData[self._viewType][idx][i])
                    if self._listener then
                        self._listener(self._viewType, self._listData[self._viewType][idx][i].resId, {row = idx, col = i})
                        pop_scene()
                    end
                end
            end
        end
    })
    self._scrollView:setPosition(0, 10)
    self._rootnode["scrollListView"]:addChild(self._scrollView)
end

return HeroShowScene

