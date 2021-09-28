--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-7-28
-- Time: 下午9:28
-- To change this template use File | Settings | File Templates.
--

require("game.Bag.BagCtrl")
local data_item_item = require("data.data_item_item")
local BagScene = class("ItemChooseScene", function()
    return require("game.BaseScene").new({
        contentFile = "public/window_content_scene.ccbi",
        subTopFile = "bag/bag_tab_view.ccbi",
        bgImage    = "ui_common/common_bg.png",
        imageFromBottom = true
    })
end)

--
local MAX_ZODER = 10000

local VIEW_TYPE = {
    BAG_ITEM  = 1,
    BAG_SKILL = 2
}

local Item = {
    [VIEW_TYPE.BAG_ITEM] = require("game.Bag.BagItem"),
    [VIEW_TYPE.BAG_SKILL] = require("game.Bag.SkillItem")
}

local RequestInfo = require("network.RequestInfo")

function BagScene:onTab(tag)

    for i = 1, 2 do
        if tag == i then
            self._rootnode["tab" .. i]:selected()
            self._curView = VIEW_TYPE.BAG_ITEM

            self._rootnode["tab" .. i]:setZOrder(1)
        else
            self._rootnode["tab" .. i]:unselected()
            self._curView = VIEW_TYPE.BAG_SKILL
            self._rootnode["tab" .. i]:setZOrder(0)
        end
    end
    self._curView = tag
    self._showType = 1

    if self._updateSKill then
        self:requestSkillList(function()
            self:updateBageItem()
        end)
    else
        self:updateBageItem()
    end
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian))
end

function BagScene:ctor(tag)
    ResMgr.removeBefLayer()

    if tag == nil or type(tag) ~= "number" or tag < 0 or tag > 2 then
        self._curView = VIEW_TYPE.BAG_ITEM
    else
        self._curView = tag 
    end

    local proxy = CCBProxy:create()

--  数量标签
    local node = CCBuilderReaderLoad("public/item_num_view.ccbi", proxy, self._rootnode)
    node:setPosition(display.cx, self:getBottomHeight())
    self:addChild(node, 3)

--  底部标签
    node = CCBuilderReaderLoad("bag/bag_bottom_frame.ccbi", proxy, self._rootnode)
    node:setPosition(display.cx, 0)
    self:addChild(node, 4)

    local function onTabBtn(tag)
        self:onTab(tag)
    end

    self._rootnode["saleInfoView"]:setVisible(false)
    self._rootnode["bottomNode"]:setVisible(true)

    if self._curView == VIEW_TYPE.BAG_ITEM then  
        self._rootnode["tab1"]:selected()
        self._rootnode["tab1"]:setZOrder(1)
        self._rootnode["tab2"]:setZOrder(0)
    else 
        self._rootnode["tab2"]:selected()
        self._rootnode["tab2"]:setZOrder(1)
        self._rootnode["tab1"]:setZOrder(0)
    end

    self._rootnode["tab1"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onTabBtn)
    self._rootnode["tab2"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onTabBtn)

--  扩展按钮
    self._rootnode["extendBtn"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, function()

        if self._cost[self._curView][1] ~= -1 then
            self._rootnode["extendBtn"]:setEnabled(false)

            local box = require("utility.CostTipMsgBox").new({
                tip = string.format("开启%d个位置吗？", self._cost[self._curView][2]),
                cancelListener = function()
                    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
                    self._rootnode["extendBtn"]:setEnabled(true)
                end,
                listener = function()
                    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
                    self._rootnode["extendBtn"]:setEnabled(true)

                    if(game.player:getGold() >= self._cost[self._curView][1]) then
                        if self._curView == VIEW_TYPE.BAG_ITEM then
                            self:extend(BAG_TYPE.daoju)
                        else
                            self:extend(BAG_TYPE.wuxue)
                        end

                    else
                        show_tip_label(data_error_error[400004].prompt) 
                    end
                end,
                cost = self._cost[self._curView][1],
            })
            self:addChild(box, 100)
        else
            show_tip_label(data_error_error[300018].prompt)
        end
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    end)

--  卖出按钮
    self._rootnode["sellBtn"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, function()

        self:onSaleView()
        self._rootnode["saleView"]:setVisible(true)
        self._rootnode["useView"]:setVisible(false)
        self._rootnode["numTagNode"]:setVisible(false)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    end)

--  返回按钮
    self._rootnode["returnBtn"]:addHandleOfControlEvent(function()

        self:onUseView()
        self._rootnode["saleView"]:setVisible(false)
        self._rootnode["useView"]:setVisible(true)
        self._rootnode["numTagNode"]:setVisible(true)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
    end, CCControlEventTouchDown)

    local function onConfirmSell()
        local ids = {}
        for k, v in pairs(self._chooseItems) do
            if v == true then
                if self._curView == VIEW_TYPE.BAG_ITEM then
                    table.insert(ids, self._canSaleItems[k].itemId)
                elseif self._curView == VIEW_TYPE.BAG_SKILL then
                    table.insert(ids, self._canSaleItems[k]._id)
                end
            end
        end

        if #ids == 0 then
            local tipContext
            if self._curView == VIEW_TYPE.BAG_ITEM then
                tipContext = "请至少选择一个要出售的道具"
            elseif self._curView == VIEW_TYPE.BAG_SKILL then
                tipContext = "请至少选择一个要出售的武学"
            end
            show_tip_label(tipContext)
            return
        end

        if self._curView == VIEW_TYPE.BAG_ITEM then
            RequestHelper.sell({
                ids = ids,
                callback = function(data)
                    if string.len(data["0"])  > 0 then

                    else
                        --                    data["1"] --获得银币
                        --                    data["2"] --总银币
                        show_tip_label(string.format("恭喜获得银币%d", data["1"]))
                        game.player:setSilver(data["2"])
                        PostNotice(NoticeKey.CommonUpdate_Label_Silver)
                        self:updateList()
                    end
                end
            })
        elseif self._curView == VIEW_TYPE.BAG_SKILL then
            local req = RequestInfo.new({
                modulename = "skill",
                funcname = "sell",
                param = {
                    ids = ids
                },
                oklistener = function(data)
                    show_tip_label(string.format("恭喜获得银币%d", data["1"]))
                    game.player:setSilver(data["2"])
                    PostNotice(NoticeKey.CommonUpdate_Label_Silver)
                    self:updateList()
                end
            })
            RequestHelperV2.request(req)
        end
    end

--  确认卖出按钮
    self._rootnode["confirSellBtn"]:addHandleOfControlEvent(function()
        onConfirmSell()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    end, CCControlEventTouchDown)

    self._item = {} --数据表
    self._cap = {}  --容量
    self._cost = {} --扩展花费 金币/格子
end

function BagScene:extend(extType)
    RequestHelper.extendBag({
        callback = function(data)
            dump(data)
            if string.len(data["0"])  > 0 then
                CCMessageBox(data["0"], "Error")
            else
                local bagCountMax = data["1"]
                --local costGold    = data["2"]
                local curGold     = data["3"]
                if extType == 4 then
                    self._cost[VIEW_TYPE.BAG_SKILL][1] = data["4"]
                    self._cost[VIEW_TYPE.BAG_SKILL][2] = data["5"]
                    self._cap[VIEW_TYPE.BAG_SKILL][2] = bagCountMax
                elseif extType == 7 then
                    self._cost[VIEW_TYPE.BAG_ITEM][1] = data["4"]
                    self._cost[VIEW_TYPE.BAG_ITEM][2] = data["5"]
                    self._cap[VIEW_TYPE.BAG_ITEM][2] = bagCountMax
                end

                self._rootnode["maxNumLabel"]:setString(self._cap[self._curView][2] or 0)

                game.player:setGold(curGold)

                PostNotice(NoticeKey.CommonUpdate_Label_Gold)
            end
        end,
        type = tostring(extType)
    })
end

function BagScene:requestSkillList(callback)
    self._updateSKill = false
    RequestHelper.getKongFuList({
        callback = function(data)
            if #data["0"] > 0 then
                show_tip_label(data["0"])
            else
                game.player:setSkills(data["1"])
                -- dump(data["1"])
                self._item[VIEW_TYPE.BAG_SKILL] = game.player:getSkills()
                self._cap[VIEW_TYPE.BAG_SKILL] = {data["2"], data["3"] }
                self._cost[VIEW_TYPE.BAG_SKILL] = {data["4"], data["5"] }
                callback()
            end
        end
    })
end


function BagScene:request()
    local reqs = {}

    local function listSortFunc(lh, rh)
        if lh.cid > 0 and rh.cid == 0 then
            return true
        elseif (data_item_item[lh.resId].pos ~= 101 and data_item_item[lh.resId].pos ~= 102) and
                (data_item_item[rh.resId].pos == 101 or data_item_item[rh.resId].pos == 102) then
            return true
        else
            return false
        end
    end

    --请求内外功
    table.insert(reqs, RequestInfo.new({
        modulename = "skill",
        funcname = "list",
        param = {},
        oklistener = function(data)
            for k, v in pairs(data) do
                if k ~= "1" then
                    -- printf("%s, %s", k, tostring(v) )
                end
            end
            game.player:setSkills(data["1"])
            -- dump(data["1"])
            self._item[VIEW_TYPE.BAG_SKILL] = game.player:getSkills()
            self._cap[VIEW_TYPE.BAG_SKILL] = {data["2"], data["3"] }
            self._cost[VIEW_TYPE.BAG_SKILL] = {data["4"], data["5"]}
        end
    }))

    table.insert(reqs, RequestInfo.new({
        modulename = "packet",
        funcname   = "list",
        param      = {},
        oklistener = function(data)

            self._item[VIEW_TYPE.BAG_ITEM] = data["1"]
            self._cap[VIEW_TYPE.BAG_ITEM] = {data["2"], data["3"] }
            self._cost[VIEW_TYPE.BAG_ITEM] = {data["4"], data["5"]}
        end
    }))

    RequestHelperV2.request2(reqs, function()
        self:updateBageItem()
    end)
end

function BagScene:removeItem(id)
    for k, v in ipairs(self._item[self._curView]) do
        if self._curView == VIEW_TYPE.BAG_ITEM then
            if v.itemId == id then
                table.remove(self._item[self._curView], k)
                break
            end
        elseif self._curView == VIEW_TYPE.BAG_SKILL then
            if v._id == id then
                table.remove(self._item[self._curView], k)
                break
            end
        end
    end

    for k, v in ipairs(self._canSaleItems) do
        if self._curView == VIEW_TYPE.BAG_ITEM then
            if v.itemId == id then
                table.remove(self._canSaleItems, k)
                break
            end
        elseif self._curView == VIEW_TYPE.BAG_SKILL then
            if v._id == id then
                table.remove(self._canSaleItems, k)
                break
            end
        end
    end
end

--    卖出成功更新列表
function BagScene:updateList()
    local ids = {}
    for k, v in pairs(self._chooseItems) do
        if v == true then
            if self._curView == VIEW_TYPE.BAG_ITEM then
                table.insert(ids, self._canSaleItems[k].itemId)
            elseif self._curView == VIEW_TYPE.BAG_SKILL then
                table.insert(ids, self._canSaleItems[k]._id)
            end
        end
    end

    for _, v in pairs(ids) do
        self:removeItem(v)
    end

    self._chooseNum = 0
    self._saleMoney = 0

    self._rootnode["selectedLabel"]:setString(tostring(self._chooseNum))
    self._rootnode["costMaxLabel"]:setString(tostring(self._saleMoney))
    self._cap[self._curView][1] = #self._item[self._curView]
    self._rootnode["curNumLabel"]:setString(tostring(self._cap[self._curView][1]))

    self._chooseItems = {}
    self._bagItemList:resetCellNum(#self._canSaleItems,false,false)
end

function BagScene:getSaleItems()
    if self._canSaleItems then
        for i = 1, #self._canSaleItems do
            table.remove(self._canSaleItems, 1)
        end
    else
        self._canSaleItems  = {}
    end

--    table.sort(self._item[self._curView], function(item1, item2)
--        return item1.itemId < item2.itemId
--    end)

    for _, v in ipairs(self._item[self._curView]) do

        if self._curView == VIEW_TYPE.BAG_ITEM then
            if data_item_item[v.itemId].sale == 1 then
                table.insert(self._canSaleItems, v)
            end
        elseif self._curView == VIEW_TYPE.BAG_SKILL then

            if data_item_item[v.resId].sale == 1 and v.pos == 0 then
                table.insert(self._canSaleItems, v)
            end
        end
    end
end

function BagScene:bagFull(info)
    local cleanupFunc = nil
    if info[1].type == BAG_TYPE.wuxue then
        cleanupFunc = function(data)
            self:onTab(VIEW_TYPE.BAG_SKILL)
        end
    end

    self:addChild(require("utility.LackBagSpaceLayer").new({
        bagObj = info,
        cleanup = cleanupFunc
    }), 100)
end

function BagScene:showReward(items)
    local itemData = {}
    local msg = "恭喜您获得："
    
    for k, v in ipairs(items) do
        local itemInfo = data_item_item[v.id]
        
        -- 侠客
        if( v.t == 8) then
            local data_card_card = require("data.data_card_card")
            itemInfo = data_card_card[v.id]
        end

        if v.t ~= nil and v.t == 0 then
            msg = msg .. tostring(v.n) .. " "
            msg = msg .. itemInfo.name
        else
            local iconType = ResMgr.getResType(v.t) or ResMgr.ITEM
            table.insert(itemData, {
                id = v.id,
                type = itemInfo.type,
                name = itemInfo.name,
                describe = itemInfo.describe,
                iconType = iconType,
                num = v.n or 0
            })
            if itemInfo.type == BAG_TYPE.wuxue then
                self._updateSKill = true
            end
        end
    end
    if #itemData > 0 then
        -- 弹出得到奖励提示框
        local title = "恭喜您获得如下奖励"
        --                            local index = cell:getIdx() + 1
        local msgBox = require("game.Huodong.RewardMsgBox").new({
            title = title,
            cellDatas = itemData
        })
        self:addChild(msgBox, MAX_ZODER)

    elseif #items > 0 then
        show_tip_label(msg)
    end
end

function BagScene:onUse(item, cnt)
--    local a = self._item[self._curView][cell:getIdx() + 1]

    RequestHelper.useItem({
        callback = function(data)

            if #data["0"] > 0 then
                CCMessageBox(data["0"], "Tip")
            else
                if data["5"] then
                    self:bagFull(data["6"])
                    return
                end

                --更新列表
                if #data["1"] ~= #self._item[self._curView] then
                    self._item[self._curView] = data["1"]
                    self._bagItemList:resetCellNum(#self._item[self._curView],false,false)
                else
                    self._item[self._curView] = data["1"]
                    self._bagItemList:resetCellNum(#self._item[self._curView], true,false)
                end

                --跟新售出列表
                self:getSaleItems()

                --获得物品
                local items = data["2"]

                if(type(items) == "table") then
                    self:showReward(items)
                end

                self._cap[self._curView][1] = #data["1"]
                self._rootnode["curNumLabel"]:setString(tostring(self._cap[self._curView][1]))

                --                  银币和金币
                if data["3"] ~= game.player:getGold() then
                    game.player:setGold(data["3"])
                    PostNotice(NoticeKey.CommonUpdate_Label_Gold)
                end

                if data["4"] ~= game.player:getSilver() then
                    game.player:setSilver(data["4"])
                    PostNotice(NoticeKey.CommonUpdate_Label_Silver)
                end
            end
            --更新玩家信息
            RequestHelper.getBaseInfo({
                callback = function ( data )
                    local basedata = data["1"]
                    local param = {silver=basedata.silver,gold=basedata.gold,lv=basedata.level,zhanli=basedata.attack, vip=basedata.vip}
                    param.exp = basedata.exp[1]
                    param.maxExp = basedata.exp[2]
                    param.naili = basedata.resisVal[1]
                    param.maxNaili = basedata.resisVal[2]

                    param.tili = basedata.physVal[1]
                    param.maxTili = basedata.physVal[2]

                    game.player:updateMainMenu(param)
                    local checkAry = data["2"]
                    game.player:updateNotification(checkAry)

                end})

        end,
        id = item.itemId,
        num = cnt
    })
end

function BagScene:onBtn(cell, tag)
    -- GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
    -- 道具使用
    local function onUse()
        local itemData = self._item[self._curView][cell:getIdx() + 1]
        local baseInfo = data_item_item[itemData.itemId]

        if baseInfo.level > game.player:getLevel() then
            show_tip_label("您的等级不足")
            return
        else
            if baseInfo.type == 11 and baseInfo.bag == 7 then
                GameStateManager:ChangeState(GAME_STATE.STATE_JIANGHULU)

            else
                local expend = {}
                if baseInfo.expend then
                    expend.id = baseInfo.expend[1]
                    expend.num = 0
                    for k, v in ipairs(self._item[self._curView]) do
                        if v.itemId == baseInfo.expend[1] then
                            expend.num = v.itemCnt
                        end
                    end
                end

                if (itemData.itemCnt == 1 and ( (expend.num and expend.num > 1) or expend.num == nil) ) then
                    self:onUse(itemData, 1)
                elseif itemData.itemCnt == 1 and expend.num and expend.num == 0 then
                    show_tip_label(string.format("%s数量不足", data_item_item[expend.id].name))
                else
                    local useCountBox = require("game.Bag.UseCountBox").new({
                        name = baseInfo.name,
                        havenum = itemData.itemCnt,
                        expend  = expend,
                        listener = function(num)
                            self:onUse(itemData, num)
                        end
                    })
                    game.runningScene:addChild(useCountBox, 1000)
                end
            end

        end
    end

    local function getSkillInfo(callback)
        RequestHelper.sendKongFuQiangHuaRes({
            callback = function(data)
                if #data["0"] > 0 then
                    show_tip_label(data["0"] .. ",请重试... ...")
                else
                    if callback then
                        callback(data)
                    end
                end
            end,
            op = 1,
            cids = self._item[self._curView][cell:getIdx() + 1]._id
        })
    end
--
    --装备强化
    local function onQiangHu()

        if self._item[self._curView][cell:getIdx() + 1].level >= 30 then
            show_tip_label("武学已经达到最大强化等级")
            return
        end

        local req = RequestInfo.new({
            modulename = "skill",
            funcname   = "qianghua",
            param      = {
                op = 1,
                cids = self._item[self._curView][cell:getIdx() + 1]._id
            },
            oklistener = function(data)
                -- dump(data)
                data["1"]._id = self._item[self._curView][cell:getIdx() + 1]._id
                local layer = require("game.skill.SkillQiangHuaLayer").new({
                    info = data["1"],
                    callback = function()
                        for k, v in pairs(self._item[self._curView]) do
                            if v._id == data["1"]._id then
                                v.curExp = data["1"].exp
                                v.level = data["1"].lv
                                v.baseRate = data["1"].baseRate
                                break
                            end
                        end
                        self:getSaleItems()
                        self._cap[self._curView][1] = #self._item[self._curView]
                        self._rootnode["curNumLabel"]:setString(self._cap[self._curView][1] or 0)
                        self._bagItemList:resetCellNum(#self._item[self._curView],false,false)
                    end
                })
                self:addChild(layer, 10)
                game.player:setSilver(data["2"])
            end
        })
        RequestHelperV2.request(req)
    end

    --装备精炼
    local function onJingLian()
        print("=======")
--        local layer = require("game.skill.SkillRefineLayer").new({
----            info = data["2"],
----            bAllow = data["1"],
----            next = {idx = data["3"], val = data["4"]},
----            objs = data["5"],
----            cost = data["6"],
--            callback = function()
--                self._bagItemList:resetCellNum(#self._item[self._curView],false,false)
--            end
--        })
--        game.runningScene:addChild(layer, 100, 100)
        local req = RequestInfo.new({
            modulename = "skill",
            funcname   = "refine",
            param      = {
                op = 1,
                id = self._item[self._curView][cell:getIdx() + 1]._id
            },
            oklistener = function(data)
                dump(data)
                dump(self._item[self._curView][cell:getIdx() + 1])

                data.rtnObj._id = self._item[self._curView][cell:getIdx() + 1]._id
                data.rtnObj.resId = self._item[self._curView][cell:getIdx() + 1].resId
                data.rtnObj.num = 7

                local layer = require("game.skill.SkillRefineLayer").new({
                    info = data.rtnObj,
                    callback = function()
                        self._bagItemList:resetCellNum(#self._item[self._curView],false,false)
                    end
                })
                game.runningScene:addChild(layer, 100)
            end
        })

        RequestHelperV2.request(req)
    end

    local function onInfo()
        local a = self._item[self._curView][cell:getIdx() + 1]

        local infoLayer
        if self._curView == VIEW_TYPE.BAG_ITEM then

            local item = data_item_item[a.itemId]
            infoLayer = require("game.Huodong.ItemInformation").new({
                id = a.itemId,
                type = item.type,
                name = item.name,
                describe = item.describe,
                endFunc = function()

                end
            })

        elseif self._curView == VIEW_TYPE.BAG_SKILL then
            infoLayer = require("game.skill.BaseSkillInfoLayer").new({
                index = self._index,
                subIndex = tag,
                info = a,
                listener = function()
                    self._cap[self._curView][1] = #self._item[self._curView]
                    self._rootnode["curNumLabel"]:setString(self._cap[self._curView][1] or 0)
                    self:getSaleItems()
                    self._bagItemList:resetCellNum(#self._item[self._curView],false,false)
                end
            })
        end
        if infoLayer then
            self:addChild(infoLayer, 10)
        end
    end

    if self._curView == VIEW_TYPE.BAG_ITEM then
        if tag == 1 then
            onUse()
        elseif tag == 2 then
            onInfo()
        end
    elseif self._curView == VIEW_TYPE.BAG_SKILL then
        if tag == 1 then
            onQiangHu()
        elseif tag == 2 then
            onJingLian()
        elseif tag == 3 then
            if self._showType == 1 then
                onInfo()
            end
        end
    end
end

function BagScene:updateBageItem()
    self._canSaleItems  = {}
    self._rootnode["maxNumLabel"]:setString(self._cap[self._curView][2] or 0)
    self._rootnode["curNumLabel"]:setString(self._cap[self._curView][1] or 0)
    self:getSaleItems()


    self._showType = 1
    local function createFunc(idx)
        local item = Item[self._curView].new()
        idx = idx + 1
        if self._showType == 1 then
            return item:create({
                itemData = self._item[self._curView][idx],
                viewSize = self._rootnode["listView"]:getContentSize(),
                idx      = idx,
                itemType = self._showType,
                useListener = handler(self, BagScene.onBtn),
                bChoose  = self._chooseItems[idx],
            })
        else
            return item:create({
                itemData = self._canSaleItems[idx],
                viewSize = self._rootnode["listView"]:getContentSize(),
                idx      = idx,
                itemType = self._showType,
                bChoose  = self._chooseItems[idx],

            })
        end
    end

    self._chooseItems = {}
    local function refreshFunc(cell, idx)
        idx = idx + 1
        if self._showType == 1 then
            cell:refresh({
                itemData = self._item[self._curView][idx],
                itemType = self._showType,
                bChoose  = self._chooseItems[idx],
                idx      = idx
            })
        else

            cell:refresh({
                itemData = self._canSaleItems[idx],
                itemType = self._showType,
                bChoose  = self._chooseItems[idx],
                idx      = idx
            })
        end
    end

    --触摸
    self._chooseNum = 0
    self._saleMoney = 0

    local function onTouchCell(cell)
        if self._showType == 1 then
            return
        end

        local idx = cell:getIdx() + 1
        local count
        local money

        if self._curView == VIEW_TYPE.BAG_ITEM then
            count = self._canSaleItems[idx].itemCnt
            money = data_item_item[self._canSaleItems[idx].itemId].price
        elseif self._curView == VIEW_TYPE.BAG_SKILL then
            count = 1
--            money = data_item_item[self._canSaleItems[idx].resId].price
            local data_kongfu_kongfu = require("data.data_kongfu_kongfu")
            local silver = (data_kongfu_kongfu[self._canSaleItems[idx].level + 1].sumexp[self._canSaleItems[idx].star] + self._canSaleItems[idx].curExp) * 5 * (self._canSaleItems[idx].star - 1)
            silver = silver + data_item_item[self._canSaleItems[idx].resId].price
            money = silver
        end

        if (self._chooseItems[idx]) then
            self._chooseItems[idx] = false
--            self._chooseNum = self._chooseNum - count
            self._chooseNum = self._chooseNum - 1
            self._saleMoney = self._saleMoney - money * count

        else
            self._chooseItems[idx] = true
--            self._chooseNum = self._chooseNum + count
            self._chooseNum = self._chooseNum + 1
            self._saleMoney = self._saleMoney + money * count
        end

        cell:touch(self._chooseItems[idx])
        self._rootnode["selectedLabel"]:setString(tostring(self._chooseNum))
        self._rootnode["costMaxLabel"]:setString(tostring(self._saleMoney))
    end

    if self._bagItemList then
        self._bagItemList:removeSelf()
    end

    --物品列表
    self._bagItemList = require("utility.TableViewExt").new({
        size        = self._rootnode["listView"]:getContentSize(),
        direction   = kCCScrollViewDirectionVertical,
        createFunc  = createFunc,
        refreshFunc = refreshFunc,
        cellNum   = #self._item[self._curView],
        cellSize    = Item[self._curView].new():getContentSize(),
        touchFunc = onTouchCell
    })

    self._bagItemList:setPosition(0, 0)
    self._rootnode["listView"]:addChild(self._bagItemList)

    self._rootnode["selectedLabel"]:setString(tostring(self._chooseNum))
    self._rootnode["costMaxLabel"]:setString(tostring(self._saleMoney))
end

function BagScene:onSaleView()
    self._showType = 2
    self._chooseItems = {}
    self:updateList()
--    self._bagItemList:resetCellNum(#self._canSaleItems)

    self._rootnode["saleInfoView"]:setVisible(true)
    self._rootnode["bottomNode"]:setVisible(false)
end

function BagScene:onUseView()

    self._showType = 1
    self._bagItemList:resetCellNum(#self._item[self._curView],false,false)

    self._rootnode["saleInfoView"]:setVisible(false)
    self._rootnode["bottomNode"]:setVisible(true)
end

function BagScene:onEnter()
    game.runningScene = self
    self:regNotice()
    if self._bExit then
        local broadcastBg = self._rootnode["broadcast_tag"] 
        if game.broadcast:getParent() ~= nil then 
            game.broadcast:removeFromParentAndCleanup(true)
        end
        broadcastBg:addChild(game.broadcast)
    end

    if self._bExit then
        self._bagItemList:resetCellNum(#self._item[self._curView],false,false)
        self._bExit = false
    end
    PostNotice(NoticeKey.UNLOCK_BOTTOM)
end


function BagScene:initdata( data1, data2 )
    --请求内外功
    game.player:setSkills(data1["1"])
    -- dump(data["1"])
    self._item[VIEW_TYPE.BAG_SKILL] = game.player:getSkills()
    self._cap[VIEW_TYPE.BAG_SKILL] = {data1["2"], data1["3"] }
    self._cost[VIEW_TYPE.BAG_SKILL] = {data1["4"], data1["5"]}

    -- bagitem
    self._item[VIEW_TYPE.BAG_ITEM] = data2["1"]
    self._cap[VIEW_TYPE.BAG_ITEM] = {data2["2"], data2["3"] }
    self._cost[VIEW_TYPE.BAG_ITEM] = {data2["4"], data2["5"]}


    self:updateBageItem()

end

function BagScene:onEnterTransitionFinish()
    -- self:request()
--    self:updateBageItem()
--    BagCtrl.request(function()
--        for _, v in pairs(VIEW_TYPE) do
--            self._item[v] = BagCtrl.get(v, "list")
--            self._cap[v] = {BagCtrl.get(v, "size").num, BagCtrl.get(v, "size").max }
--            self._cost[v] = {BagCtrl.get(v, "cost").num, BagCtrl.get(v, "cost").max }
--        end
--        self:updateBageItem()
--    end)
end

function BagScene:onExit()
    self:unregNotice()

    self._bExit = true
    CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return BagScene



