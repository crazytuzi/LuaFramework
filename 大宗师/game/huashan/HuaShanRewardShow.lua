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
-- 日期：14-12-24
--
local ZORDER = 100
local listViewDisH = 95
local data_item_item = require("data.data_item_item")
local data_lunjian_lunjian = require("data.data_lunjian_lunjian")

local Item = class("Item", function()
    return CCTableViewCell:new()
end)


function Item:getContentSize()
    return CCSizeMake(640, 200)
end

-- 更新奖励图标、名称、数量
function Item:updateItem(itemData)

    for i, v in ipairs(itemData.itemid) do
        local reward = self._rootnode["reward_" ..tostring(i)]
        reward:setVisible(true)

        local rewardIcon = self._rootnode["reward_icon_" ..tostring(i)]
        rewardIcon:removeAllChildrenWithCleanup(true)

        local num = itemData.num[i]
        if v == 2 then
            num = num * game.player.getLevel() + itemData.silver
        end
        printf("========== %d", v)
        ResMgr.refreshIcon({
            id = v,
            resType = ResMgr.getResType(itemData.type[i]),
            itemBg = rewardIcon,
            iconNum = num,
            isShowIconNum = (num ~= 1),
            numLblSize = 22,
            numLblColor = ccc3(0, 255, 0),
            numLblOutColor = ccc3(0, 0, 0)
        })

        if itemData.type[i] == 5 then
            self._rootnode[string.format("reward_canhun_%d", i)]:setVisible(true)
        else
            self._rootnode[string.format("reward_canhun_%d", i)]:setVisible(false)
        end

        -- 名称
        local nameKey = "reward_name_" .. tostring(i)
        local nameColor = ResMgr.getItemNameColor(v)

        local nameLbl = ui.newTTFLabelWithShadow({
            text = data_item_item[v].name,
            size = 20,
            color = nameColor,
            shadowColor = ccc3(0,0,0),
            font = FONTS_NAME.font_fzcy,
            align = ui.TEXT_ALIGN_LEFT
        })

        nameLbl:setPosition(-nameLbl:getContentSize().width/2, nameLbl:getContentSize().height/2)
        self._rootnode[nameKey]:removeAllChildren()
        self._rootnode[nameKey]:addChild(nameLbl)
    end

    -- 道具类型达不到4个时，剩余的道具框隐藏
    local count = #itemData.itemid
    while (count < 4) do
        self._rootnode["reward_" ..tostring(count + 1)]:setVisible(false)
        count = count + 1
    end
end


function Item:refreshItem(param)
    local itemData = param.itemData
    self._rootnode["index"]:setString(itemData.title)
    self:updateItem(itemData)
end


function Item:getIcon(index)
    return self._rootnode["reward_icon_" ..tostring(index)]
end

function Item:create(param)
    local viewSize = param.viewSize

    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBuilderReaderLoad("huashan/huashan_reward_item.ccbi", proxy, self._rootnode)
    node:setPosition(viewSize.width * 0.5, self._rootnode["itemBg"]:getContentSize().height * 0.5)
    self:addChild(node)

    self:refreshItem(param)
    return self
end

function Item:refresh(param)
    self:refreshItem(param)
end

local HuaShanRewardShow = class("HuaShanRewardShow", function ()
    return require("utility.ShadeLayer").new()
end)

-- 点击图标，显示道具详细信息
function HuaShanRewardShow:onInformation(param)

    local index = param.index
    local iconIdx = param.iconIndex

    local icon_data = data_lunjian_lunjian[index]
    printf("======== %d, %d", index, iconIdx)
    if icon_data then

        dump(data_item_item[icon_data.itemid[iconIdx]])
        local itemInfo = require("game.Huodong.ItemInformation").new({
            id = icon_data.itemid[iconIdx],
            type = icon_data.type[iconIdx],
            name = data_item_item[icon_data.itemid[iconIdx]].name,
            describe = icon_data.describe,
            endFunc = function()

            end
        })

        self:addChild(itemInfo, ZORDER)
    end

end


function HuaShanRewardShow:init()
    local boardWidth = self._rootnode["listView"]:getContentSize().width
    local boardHeight = self._rootnode["listView"]:getContentSize().height - listViewDisH

    -- 创建
    local function createFunc(index)

        local item = Item.new()
        return item:create({
            viewSize = CCSizeMake(boardWidth, boardHeight),
            itemData = data_lunjian_lunjian[index + 1]
        })
    end

    -- 刷新
    local function refreshFunc(cell, index)
        cell:refresh({
            itemData = data_lunjian_lunjian[index + 1]
        })
    end

    self._rootnode["touchNode"]:setTouchEnabled(true)
    local posX = 0
    local posY = 0
    self._rootnode["touchNode"]:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
        posX = event.x
        posY = event.y
    end)


    local cellContentSize = require("game.Huodong.kaifuReward.KaifuRewardCell").new():getContentSize()

    local tableView = require("utility.TableViewExt").new({
        size        = CCSizeMake(boardWidth, boardHeight),
        direction   = kCCScrollViewDirectionVertical,
        createFunc  = createFunc,
        refreshFunc = refreshFunc,
        cellNum   	= #data_lunjian_lunjian,
        cellSize    = cellContentSize,
        touchFunc = function(cell)
            local idx = cell:getIdx()
            for i = 1, 4 do
                local icon = cell:getIcon(i)
                local pos = icon:convertToNodeSpace(ccp(posX, posY))
                if CCRectMake(0, 0, icon:getContentSize().width, icon:getContentSize().height):containsPoint(pos) then
                    self:onInformation({
                        index = idx + 1,
                        iconIndex = i
                    })
                    break
                end
            end
        end
    })

    tableView:setPosition(0, 0)
    self._rootnode["listView"]:addChild(tableView)
end


function HuaShanRewardShow:ctor()
    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBuilderReaderLoad("reward/normal_reward_bg.ccbi", proxy, self._rootnode)
    local layer = tolua.cast(node, "CCLayer")
    layer:setPosition(display.width/2, display.height/2)
    self:addChild(layer)

    self._rootnode["titleLabel"]:setString("论剑奖励")

    self._rootnode["tag_close"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
        self:removeFromParentAndCleanup(true)
    end, CCControlEventTouchUpInside)

    self:init()
end

function HuaShanRewardShow:onExit( ... )
    CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return HuaShanRewardShow


