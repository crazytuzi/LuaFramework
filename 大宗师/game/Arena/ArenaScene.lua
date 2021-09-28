--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-7-7
-- Time: 下午4:55
-- To change this template use File | Settings | File Templates.
--
local ArenaScene = class("ArenaScene", function()
    return require("game.BaseScene").new({
        contentFile = "arena/arena_bg.ccbi",
        subTopFile = "arena/arena_up_tab.ccbi",
        topFile = "public/top_frame_other.ccbi",
        isOther = true,
    })
end)








local OPENLAYER_ZORDER = 1001
local ARENA_VIEW = 1 
local RANK_VIEW  = 2 
local EXCHANGE_VIEW = 3 

function ArenaScene:onExit()
   -- PageMemoModel.saveOffset("Arena_list",self.arenaList)
    self:unregNotice()
    -- self.scheduler.unscheduleGlobal(self.timeData)
end

function ArenaScene:resetList()

end

function ArenaScene:sendArenaData()
    RequestHelper.getArenaData({
        callback = function(data)
        if string.len(data["0"]) > 0 then 
                CCMessageBox(data["0"], "Error") 
            else
                self.arenaData = data
                self:updateArenaView()
            end
        end
    })
end

function ArenaScene:sendRankReq()
    RequestHelper.getArenaRank({
        callback = function(data)
            self.rankData = data
            self:updateRankView()
        end
    })
end


function ArenaScene:sendExchangeReq()
    RequestHelper.exchange.getData({
        callback = function(data)
            dump(data)
            if string.len(data["0"]) > 0 then 
                CCMessageBox(data["0"], "Error") 
            else
                self:updateExchangeView(data) 
            end 
        end
        })
end


-- 物品兑换相关
function ArenaScene:updateExchangeView(data)
    self._rootnode["tag_normal_node"]:setVisible(false)
    self._rootnode["tag_exchange_node"]:setVisible(true) 
    self._rootnode["shengwang_node"]:setVisible(true)

    local listAry = data["1"] 

    self._itemDataList = {}
    local data_shop_jingjichang_shop_jingjichang = require("data.data_shop_jingjichang_shop_jingjichang") 
    for i, v in ipairs(listAry) do 
        local duihuanData = data_shop_jingjichang_shop_jingjichang[v.id]
        if duihuanData == nil then 
            dump("表里没有此id：" .. v.id) 
        end 

        local iconType = ResMgr.getResType(duihuanData.type) 
        local item 
        if iconType == ResMgr.HERO then 
            local data_card_card = require("data.data_card_card") 
            item = data_card_card[duihuanData.item]
        else
            local data_item_item = require("data.data_item_item")
            item = data_item_item[duihuanData.item]
        end 

        table.insert(self._itemDataList, {
            dataId = v.id, 
            id = duihuanData.item, 
            type = duihuanData.type, 
            num = duihuanData.num, 
            type1 = duihuanData.type1, 
            needLevel = duihuanData.level, 
            needReputation = duihuanData.price, 
            limitNum = v.num1, 
            had = v.had, 
            iconType = iconType, 
            name = item.name, 
            describe = item.describe or "", 
            }) 
    end 

    self:createExchangeView() 
end


function ArenaScene:createExchangeView()
    -- dump(self._itemDataList) 

    -- 点击图标，显示道具详细信息
    local function onInformation(cell) 
        local index = cell:getIdx() + 1 
        local icon_data = self._itemDataList[index]

        local itemInfo = require("game.Huodong.ItemInformation").new({
                        id = icon_data.id, 
                        type = icon_data.type, 
                        name = icon_data.name, 
                        describe = icon_data.describe
                        })

         self:addChild(itemInfo, OPENLAYER_ZORDER)
    end 

    local boardWidth = self._rootnode["listView"]:getContentSize().width
    local boardHeight = self._rootnode["listView"]:getContentSize().height - self._rootnode["tag_exchange_node"]:getContentSize().height 
    local listViewSize = CCSizeMake(boardWidth, boardHeight) 

    local function createFunc(index)
        local item = require("game.Arena.ArenaExchangeCell").new()
        return item:create({
            viewSize = listViewSize, 
            itemData = self._itemDataList[index + 1], 
            exchangeFunc = function(cell)
                self:exchangeFunc(cell)
            end, 
            informationFunc = function(cell)
                onInformation(cell)
            end 
        })
    end 

    local function refreshFunc(cell, index)
        -- dump(index)
        cell:refresh(self._itemDataList[index + 1]) 
    end

    self._exchangeItemList = require("utility.TableViewExt").new({
        size        = listViewSize, 
        direction   = kCCScrollViewDirectionVertical,
        createFunc  = createFunc,
        refreshFunc = refreshFunc,
        cellNum     = #self._itemDataList,
        cellSize    = require("game.Arena.ArenaExchangeCell").new():getContentSize(),


    })

    self.listView:removeAllChildren()
    self.listView:addChild(self._exchangeItemList) 
end


function ArenaScene:exchangeFunc(cell)
    local index = cell:getIdx() + 1 
    local itemData = self._itemDataList[index] 

    if game.player:getLevel() < itemData.needLevel then 
        show_tip_label("该物品需要人物等级达到" .. tostring(itemData.needLevel) .. "级才可兑换")
        cell:updateExchangeBtn(true) 
        return 
    end 

    -- 判断背包空间是否足，如否则提示扩展空间 
    local bagObj = {} 
    local function extendBag(data)
        -- 更新第一个背包，先判断当前拥有数量是否小于上限，若是则接着提示下一个背包类型需要扩展，否则更新cost和size 
        if bagObj[1].curCnt < data["1"] then 
            table.remove(bagObj, 1)
        else
            bagObj[1].cost = data["4"]
            bagObj[1].size = data["5"]
        end

        if #bagObj > 0 then 
            self:addChild(require("utility.LackBagSpaceLayer").new({
                bagObj = bagObj, 
                callback = function(data)
                    extendBag(data)
                end}), OPENLAYER_ZORDER) 
        end
    end 

    -- 确认兑换回调函数 
    local function confirmFunc(num)
        RequestHelper.exchange.exchange({
            id = itemData.dataId, 
            num = num, 
            callback = function(data)
                dump(data)
                if data["0"] ~= "" then 
                    dump(data["0"]) 
                else
                    -- 更新背包状态 
                    bagObj = data["2"]
                    if #bagObj > 0 then 
                        self:addChild(require("utility.LackBagSpaceLayer").new({
                            bagObj = bagObj, 
                            callback = function(data)
                                extendBag(data)
                            end}), OPENLAYER_ZORDER)
                    else  
                        -- 弹出购买的物品确认框
                        local cellDatas = {}
                        table.insert(cellDatas, itemData)
                        self:addChild(require("game.Huodong.rewardInfo.RewardInfoMsgBox").new({
                                cellDatas = cellDatas, 
                                num = num  
                            }), OPENLAYER_ZORDER)


                        -- 判断当前购买的物品，是否还可购买，若不是则删除，若可购买则更新数量 
                        -- 若今日不可购买，则兑换置为不可点击 
                        local bRemove = false 
                        local itemState = data["1"] 
                        local curHadNum = -1 
                        local curItemId = -1  
                        for i, v in ipairs(self._itemDataList) do 
                            if v.dataId == itemState.id then 
                                v.limitNum = itemState.num1 
                                v.had = itemState.had 
                                if v.type1 == 1 and v.limitNum == 0 then 
                                    bRemove = true 
                                    table.remove(self._itemDataList, i)
                                end 
                                
                                curItemId = v.id 
                                curHadNum = v.had 

                                break
                            end 
                        end 

                        if curItemId ~= -1 and curHadNum ~= -1 then 
                            for i, v in ipairs(self._itemDataList) do 
                                if v.id == curItemId then 
                                    v.had = curHadNum 
                                end 
                            end 
                        end 

                        -- 更新列表
                        if bRemove then 
                            self:createExchangeView() 
                        else 
                            cell:updateExchangeNum(itemState.num1, itemState.had)
                        end 

                        -- 更新声望数值 
                        self:updateReputation(data["3"]) 

                    end 
                end 
            end
        })    
    end

    self:addChild(require("game.Arena.ExchangeCountBox").new({
            reputation = self._reputation, 
            itemData = itemData, 
            listener = function(num)
                confirmFunc(num) 
            end, 
            closeFunc = function()
                cell:updateExchangeBtn(true) 
            end
        }), OPENLAYER_ZORDER) 
end


function ArenaScene:updateReputation(num)
    self._reputation = num 
    self._rootnode["shengwang_num"]:setString(self._reputation) 
    self._rootnode["shengwang_num_exc"]:setString(self._reputation) 
end


function ArenaScene:timeSchedule(param)
    self.restTime = param.time
    local timeLabel = param.label
    local callBack = param.callBack --时间执行完毕后的回调

    timeLabel:setString(format_time(self.restTime))

    local function update( dt )
        if  self.restTime <= 0 then
            -- self.scheduler.unscheduleGlobal(self.timeData)
            self.timeNode:stopAllActions()
            if self.restTime <= 0 then
                callBack()
            end
        else
            self.restTime = self.restTime - 1
            local timeStr = format_time(self.restTime)
            timeLabel:setString(timeStr)
            PostNotice(NoticeKey.ArenaRestTime, CCFloat:create(self.restTime))
        end
    end
    -- self.scheduler = require("framework.scheduler")
    -- if self.timeData ~= nil then
    --     self.scheduler.unscheduleGlobal(self.timeData)
    -- end
    -- self.timeData = self.scheduler.scheduleGlobal( update, 1, false )

    self.timeNode = display.newNode()
    self:addChild(self.timeNode)
    self.timeNode:schedule(update,1)
end

function ArenaScene:getValue(itemData)
    local itemValue = 0

    if itemData.acc == self.rankOneAcc then
        itemValue = itemValue + 10000000
    end

    if game.player:checkIsSelfByAcc(itemData.acc) then
        itemValue = itemValue + 100000
    end

    itemValue = itemValue + (1000000 - itemData.rank)

    return itemValue
end

function ArenaScene:arrangeList(list)
    self.rank = 0
    --将主角排在第二位    
    for i  =1 ,#list do
        if  game.player:checkIsSelfByAcc(list[i].acc) then
            self.rank = i
            break
        end 
    end

    if self.rank == 1 then
        self.rank = 2
    end
    self.rankMax = #list


    -- print("self.rank "..self.rank)
end


function ArenaScene:updateArenaView()
    self._rootnode["tag_normal_node"]:setVisible(true)
    self._rootnode["tag_exchange_node"]:setVisible(false)

    local arenaList = self.arenaData["1"]
    self:arrangeList(arenaList)
    --设定上面的数值栏
    local curRank = self.arenaData["2"]
    self.restTime = self.arenaData["4"]
    self.tType = self.arenaData["5"]
    -- self.restTiLiDanNum = self.arenaData["6"]--剩余的体力丹的数量
    -- self.buyData = self.arenaData["7"] --购买相关的数值

    --声望
    self:updateReputation(self.arenaData["3"])

    self._rootnode["rank_num"]:setString(curRank)
    self:timeSchedule({time = self.restTime,label = self._rootnode["rest_time"],callBack = function()
        print("time out")
        if self.tType == 1 then
            self.tType = 2
            --挑战结束倒计时
            self._rootnode["rest_type_name"]:setString("领奖倒计时：")
        else
            self.tType = 1
            --发奖结束倒计时
            self._rootnode["rest_type_name"]:setString("奖励发放中：")
        end
        PostNotice(NoticeKey.SwitchArenaTimeType)
    end})

    if self.tType == 1 then
        --发奖结束倒计时
        self._rootnode["rest_type_name"]:setString("奖励发放中：")
    else
        --挑战结束倒计时
        self._rootnode["rest_type_name"]:setString("领奖倒计时：")
    end

    local function resetFunc()
        self:sendArenaData()
    end

    local function notEnoughFunc()
        local layer = require("game.Arena.ArenaBuyMsgBox").new({updateListen = handler(self, ArenaScene.updateNaiLiLbl)})
        display.getRunningScene():addChild(layer,10000)
    end

    self._rootnode["time_node"]:setVisible(true)

    local boardWidth = self._rootnode["listView"]:getContentSize().width
    local boardHeight = self._rootnode["listView"]:getContentSize().height - self._rootnode["tag_normal_node"]:getContentSize().height 
    local lisetViewSize = CCSizeMake(boardWidth, boardHeight) 

    local function createFunc(idx)
        local item = require("game.Arena.ArenaCell").new()
        return item:create({
            id       = idx,
            viewSize = lisetViewSize, 
            listData = arenaList,
            restTime = self.restTime,
            resetFunc = resetFunc,
            timeType = self.tType,
            notEnoughFunc = notEnoughFunc 
        })
    end

    local function refreshFunc(cell, idx)
        cell:refresh(idx+1, self.restTime, self.tType)
    end
    local itemCellSize  = require("game.Arena.ArenaCell").new():getContentSize()

    self.arenaList = nil
    local itemList = require("utility.TableViewExt").new({
        size        = lisetViewSize, 
        direction   = kCCScrollViewDirectionVertical,
        createFunc  = createFunc,
        refreshFunc = refreshFunc,
        cellNum     = #arenaList,
        cellSize    = itemCellSize,
        scrollFunc  = function()
            PageMemoModel.saveOffset("Arena_list",self.arenaList)
        end 
    })

    self.arenaList = itemList
    --竞技场排序
    -- if self.rank == self.rankMax then
    --     itemList:setContentOffset(CCPoint(0, 0))
    -- else

    --     itemList:setContentOffset(CCPoint(0, -itemCellSize.height*(self.rankMax-self.rank - 1)))
    -- end
    self.listView:removeAllChildren()
    self.listView:addChild(itemList)
    if self.arenaList ~= nil then
        PageMemoModel.resetOffset("Arena_list",self.arenaList)
    end
end


function ArenaScene:updateNaiLiLbl()
    PostNotice(NoticeKey.CommonUpdate_Label_Naili)
    PostNotice(NoticeKey.CommonUpdate_Label_Tili)
end


function ArenaScene:updateRankView()
    self._rootnode["tag_normal_node"]:setVisible(true)
    self._rootnode["time_node"]:setVisible(false)
    self._rootnode["tag_exchange_node"]:setVisible(false) 
    local rankList = self.rankData["1"]

    local function createFormFunc(idx)
--        dump(rankList[idx + 1])
--        rankList[idx + 1].acc
--        push_scene(require("game.form.EnemyFormScene").new(1, rankList[idx + 1].acc))
        local layer = require("game.form.EnemyFormLayer").new(1, rankList[idx + 1].acc)
        layer:setPosition(0, 0)
--        layer:setScale(0.8)
        self:addChild(layer, 10000)
--        show_tip_label("你的等级不足")
    end 

    local boardWidth = self._rootnode["listView"]:getContentSize().width
    local boardHeight = self._rootnode["listView"]:getContentSize().height - self._rootnode["tag_normal_node"]:getContentSize().height 
    local lisetViewSize = CCSizeMake(boardWidth, boardHeight) 

    local function createFunc(idx)
        local item = require("game.Arena.ArenaRankCell").new()
        return item:create({
            id       = idx,
            viewSize = lisetViewSize,
            listData = rankList,
            createFormFunc = createFormFunc
        })
    end

    local function refreshFunc(cell, idx)
        cell:refresh(idx+1)
    end

    local itemList = require("utility.TableViewExt").new({
        size        = lisetViewSize, 
        direction   = kCCScrollViewDirectionVertical,
        createFunc  = createFunc,
        refreshFunc = refreshFunc,
        cellNum     = #rankList,
        cellSize    = require("game.Arena.ArenaRankCell").new():getContentSize(),

    })

    self.listView:removeAllChildren()
    self.listView:addChild(itemList)
end


function ArenaScene:ctor()
    ResMgr.removeBefLayer()
    
    local _bg = display.newSprite("ui_common/common_bg.png")
    local _bgW = display.width
    local _bgH = display.height - self._rootnode["bottomMenuNode"]:getContentSize().height - self._rootnode["topFrameNode"]:getContentSize().height
    _bg:setPosition(_bgW / 2, _bgH / 2 + self._rootnode["bottomMenuNode"]:getContentSize().height)

    _bg:setScaleX(_bgW / _bg:getContentSize().width)
    _bg:setScaleY(_bgH / _bg:getContentSize().height)
    self:addChild(_bg, 0)

    self.listView = self._rootnode["listView"]

    self._rootnode["backBtn"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        GameStateManager:ChangeState(GAME_STATE.STATE_HUODONG)
    end,
        CCControlEventTouchUpInside)

    self.viewType = 0

    local function onTabBtn(tag) 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian)) 
        for i = 1, 3 do
            if tag == i then
                self._rootnode["tab" ..tostring(i)]:selected()
                self._rootnode["btn" ..tostring(i)]:setZOrder(10) 
            else
                self._rootnode["tab" ..tostring(i)]:unselected()
                self._rootnode["btn" ..tostring(i)]:setZOrder(10 - i)  
            end
        end

        self.viewType = tag

        if ARENA_VIEW == tag then

            self:sendArenaData()
        elseif RANK_VIEW == tag then
             -- PageMemoModel.saveOffset("Arena_list",self.arenaList)
            self:sendRankReq()
        elseif EXCHANGE_VIEW == tag then 
             -- PageMemoModel.saveOffset("Arena_list",self.arenaList)
            self:sendExchangeReq() 
        end
    end
    --初始化选项卡
    local function initTab()
        for i = 1, 3 do
            self._rootnode["tab" ..tostring(i)]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onTabBtn)
        end 
    end
    initTab()

    onTabBtn(ARENA_VIEW)
end


function ArenaScene:onEnter()


    GameAudio.playMainmenuMusic(true)  
    game.runningScene = self 
    self:regNotice()
    PostNotice(NoticeKey.UNLOCK_BOTTOM)
    self:updateNaiLiLbl()

    -- 广播
    local broadcastBg = self._rootnode["broadcast_tag"]
    if broadcastBg ~= nil then
        if game.broadcast:getParent() ~= nil then 
            game.broadcast:removeFromParentAndCleanup(true)
        end
        broadcastBg:addChild(game.broadcast)
    end

    -- 是否开启新系统
    local levelData = game.player:getLevelUpData()
    if levelData.isLevelUp then
        local _, systemIds = OpenCheck.checkIsOpenNewFuncByLevel(levelData.beforeLevel, levelData.curLevel)
        -- dump(systemIds)
        game.player:updateLevelUpData({isLevelUp = false})
        local function createOpenLayer()
            if #systemIds > 0 then
                local systemId = systemIds[1]
                self:addChild(require("game.OpenSystem.OpenLayer").new({
                    systemId = systemId,
                    confirmFunc = function()
                        createOpenLayer() 
                    end 
                }), OPENLAYER_ZORDER)
                table.remove(systemIds, 1)
            end
        end
        createOpenLayer()
    end
end

return ArenaScene
