--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-7-7
-- Time: 下午4:55
-- To change this template use File | Settings | File Templates.
--
local EquipListScene = class("EquipListScene", function()

    return require("game.BaseScene").new({
        contentFile = "equip/equip_list_bg.ccbi",
        subTopFile = "equip/equip_up_tab.ccbi"
    })
end)



local data_item_item = require("data.data_item_item")

local MAX_ZORDER = 100000

local TAB_TAG = {
    XIAKE = 1,
    SOUL = 2
}

local COMMON_VIEW = 1
local SALE_VIEW = 2

local LISTVIEW_TAG = 100

function EquipListScene:SendReq()
    RequestHelper.getEquipList({
        callback = function(data)
            if #data["0"] > 0 then
                show_tip_label(#data["0"])
            else
                self._cost = {data["4"], data["5"]}
                self:init(data)
            end

        end})

end

function EquipListScene:resetPos()
    local xiedai = self._rootnode["xiedai"]
    local curNum = self._rootnode["curNum"]
    local sign  = self._rootnode["sign"]
    local maxNum = self._rootnode["maxNum"]
    curNum:setPosition(xiedai:getPositionX()+xiedai:getContentSize().width,xiedai:getPositionY())
    sign:setPosition(curNum:getPositionX()+curNum:getContentSize().width,xiedai:getPositionY())
    maxNum:setPosition(sign:getPositionX()+sign:getContentSize().width,xiedai:getPositionY())
end

function EquipListScene:setCurNum(num)
    self._rootnode["curNum"]:setString(num)
    self:resetPos()
end

function EquipListScene:setMaxNum(num)
    self._rootnode["maxNum"]:setString(num)
    self:resetPos()
end

function EquipListScene:onSaleView()
    --清理table
    self.sellTable = {}

    self.sellIndex = {}
    self.viewType = SALE_VIEW
    --隐藏上面的 侠魂 残魂 选项卡
    self._rootnode["tab1"]:setVisible(false)
    self._rootnode["tab2"]:setVisible(false)
    --隐藏扩展出售按钮
    self._rootnode["expandBtn"]:setVisible(false)
    self._rootnode["sellBtn"]:setVisible(false)

    --显示按星级按钮
    self._rootnode["sellStarBtn"]:setVisible(true)

    --显示返回按钮
    self._rootnode["backBtn"]:setVisible(true)

    -- 显示出售标题
    self._rootnode["sell_title"]:setVisible(true)

    --显示下面的出售数量和价格的下边框
    --self._downNode["sell_bottom_frame"]
    self.sellFrame:setVisible(true)
    --
    self._rootnode["numTag"]:setVisible(false)

    --隐藏下面的常用场景切换下边框
    self._rootnode["bottomNode"]:setVisible(false)

    self.isAllowScroll = false
    --更新sale的list
    self.equipSellTable:resetCellNum(#self.sellList)
    self.isAllowScroll = true


    self.equipSellTable:setVisible(true)
    self.equipTable:setVisible(false)

    self.sellMoney = 0


    --清理下面的出售数量和钱的选项卡
    self.sellFrame:setRightNum(0)
    self.sellFrame:setLeftNum(0)



end

function EquipListScene:onCommonView()
    self.viewType =  COMMON_VIEW
    --显示上面的 侠魂 残魂 选项卡
    self._rootnode["tab1"]:setVisible(true)
    self._rootnode["tab2"]:setVisible(true)

    --显示扩展出售按钮
    self._rootnode["expandBtn"]:setVisible(true)
    self._rootnode["sellBtn"]:setVisible(true)

    --隐藏按星级按钮
    self._rootnode["sellStarBtn"]:setVisible(false)

    --隐藏返回按钮
    self._rootnode["backBtn"]:setVisible(false)

    -- 隐藏出售标题
    self._rootnode["sell_title"]:setVisible(false)

    --隐藏下面的出售数量和价格的下边框
    -- self._downNode["sell_bottom_frame"]:
    self.sellFrame:setVisible(false)
    self._rootnode["numTag"]:setVisible(true)
    --显示下面常用的场景切换框
    self._rootnode["bottomNode"]:setVisible(true)


    --更新common的list
    self.equipTable:resetCellNum(#self.commonList)


    self.equipSellTable:setVisible(false)
    self.equipTable:setVisible(true)
end

function EquipListScene:getSellMoney()
    local curMoney = 0
    local num = 0
    for k, v in pairs(self.sellIndex) do
        if self.sellIndex[k] then
            num = num + 1
            curMoney = curMoney + self.sellList[k]["silver"]
        end
    end
    self.sellFrame:setRightNum(curMoney)
    self.sellFrame:setLeftNum(num)
end



function EquipListScene:init(data)

    self.sellTable = {}

    local list  = data["1"]
    self.nameList = data["6"]
    -- dump(list)
    self.commonList = list or {}

    -- dump(self.commonList[1])

    EquipModel.sort(self.commonList)

    self.sellList = {}

    --过滤一下 将可以出售的留下

    for i = 1, #self.commonList do
        local isSale = data_item_item[self.commonList[i]["resId"]]["sale"]
        
        if isSale ~= nil and isSale ~= 0 then  --列表中规定可以出售的
            if self.commonList[i]["pos"] == 0 then --
                self.sellList[#self.sellList + 1 ] = self.commonList[i]

            end
        end
    end
    local maxEquipNum = data["3"]
    self:setMaxNum(maxEquipNum)
    local sellBtn = self._rootnode["sellBtn"]
    local extendBtn =self._rootnode["expandBtn"]

    local boardBg = self._rootnode["heroListBg"]
    -- boardBg:setContentSize(CCSizeMake(display.width,display.height))
    local function quickChoseFunc(selTable)
        for i = 1, #selTable do
            if selTable[i] then
                for j = 1, #self.sellList do
                    if self.sellList[j]["star"] == i then --
                        self.sellIndex[j] = true
                        local isExist = false
                        for k = 1,#self.sellTable do
                            if self.sellTable[k] == self.sellList[j]["_id"] then
                                isExist = true
                                break
                            end
                        end
                        if isExist ~= true then
                            self.sellTable[#self.sellTable + 1] = self.sellList[j]["_id"]
                        end
                    end
                end
            end
        end

        self:getSellMoney()
        self.equipSellTable:resetCellNum(#self.sellList)

    end

    --按星级出售界面
    if self._bInit ~= true then
        self._rootnode["sellStarBtn"]:addHandleOfControlEvent(function(eventName,sender)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
            self._rootnode["sellStarBtn"]:setEnabled(false)
            ResMgr.delayFunc(0.5,function()
                self._rootnode["sellStarBtn"]:setEnabled(true)
                end,self)
            
            local heroQuickSel = require("game.Equip.EquipV2.EquipQuickChose").new(quickChoseFunc)
            display:getRunningScene():addChild(heroQuickSel,10)
        end,CCControlEventTouchUpInside)
    end

    --

    local numTag = self._rootnode["numTag"]
    numTag:setZOrder(20)


    if self._bInit ~= true then
        self._rootnode["sellBtn"]:addHandleOfControlEvent(function(eventName,sender)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
            self:onSaleView()
        end ,CCControlEventTouchUpInside)

        self._rootnode["backBtn"]:addHandleOfControlEvent(function(eventName,sender)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
            self:onCommonView()
        end,
        CCControlEventTouchUpInside)
    end

    local function updateLabel()
        self._rootnode["goldLabel"]:setString(game.player:getGold())
        self._rootnode["silverLabel"]:setString(game.player:getSilver())
    end

    local function extend( ... )
        RequestHelper.extendBag({
            type = 1,
            callback = function(data)
            dump(data)
                if (#data["0"] == 0) then

                    local bagCountMax = data["1"]
                    local costGold    = data["2"]
                    local curGold     = data["3"]
                    self._cost[1] = data["4"]
                    self._cost[2] = data["5"]
                    game.player:setBagCountMax(bagCountMax)
                    game.player:setGold(curGold)
                    updateLabel()
                    self:setMaxNum(bagCountMax)
                    -- show_tip_label("装备背包上限提升至"..bagCountMax)
                    ResMgr.showErr(500014)


                    PostNotice(NoticeKey.MainMenuScene_Update)
                else
                    CCMessageBox(data["0"], "Error")
                end
            end
        })
    end

    if self._bInit ~= true then
        self._rootnode["expandBtn"]:addHandleOfControlEvent(function(eventName,sender)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
            if self._cost[1] ~= -1 then
                local box = require("utility.CostTipMsgBox").new({
                    tip = string.format("开启%d个位置吗？", self._cost[2]),
                    listener = function()
                        if(game.player.m_gold >= self._cost[1]) then
                            extend()
                        else
                            -- show_tip_label("元宝不足")
                            ResMgr.showErr(400004)
                        end
                    end,
                    cost = self._cost[1],
                })
                game.runningScene:addChild(box, 1001)
            else
                -- show_tip_label("已经达到最大扩展空间")
                ResMgr.showErr(500012)
            end

        end,CCControlEventTouchUpInside)
    end

    updateLabel()

    -------
    local function updateDebriList ()
        --发送请求
        RequestHelper.getEquipDebrisList({
            callback = function(listData)
                if #listData["0"] > 0 then
                    show_tip_label(listData["0"])
                    return
                end
                self.scrollLayerNode:removeAllChildren()
                local debrisList = listData["1"]
                -- dump("fdfdd")

                local function createCollectLayer(levelInfo)
                    local collectLayer = require("game.Hero.CollectLayer").new(levelInfo,ResMgr.EQUIP)
                    -- collectLayer:setPosition(display.width/2,display.height/2)
                    self:addChild(collectLayer,103)
                end

                local function hechengLayer(hechengData)

                    RequestHelper.sendHeChengEquipRes({
                        callback = function(listData)
                            dump(listData)
                        if listData["5"] == true then
                            ResMgr.showMsg(3)
                        else
                            if string.len(listData["0"]) > 0 then
                                CCMessageBox(listData["0"], "Tip")
                            else
                                local isFull = listData["3"] or false

                                if not isFull then
                                    self.upDebrisFunc()
                                    local tip = require("utility.NormalBanner").new({tipContext="装备合成成功"})
                                    tip:setPosition(display.width/2,display.height/2)
                                    self:addChild(tip, MAX_ZORDER)

                                else
                                    local bagObj = listData["4"]

                                    -- 判断背包空间是否足，如否则提示扩展空间
                                    local function extendBag(data)
                                        -- 更新背包最大数量
                                        self:setMaxNum(checkint(self._rootnode["maxNum"]:getString()) + bagObj[1].size)

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
                                                end}), MAX_ZORDER)
                                        else
                                            isFull = false
                                        end
                                    end

                                    if isFull then
                                        self:addChild(require("utility.LackBagSpaceLayer").new({
                                            bagObj = bagObj,
                                            callback = function(data)
                                                extendBag(data)
                                            end}), MAX_ZORDER)
                                    end
                                end
                            end
                        end
                        end,
                        id = hechengData.id,
                        num = hechengData.num
                    })
                end

                local function createFunc(idx)
                    local item = require("game.Equip.EquipV2.EquipDebrisCellVTwo").new()
                    return item:create({
                        id       = idx,
                        -- viewSize = CCSizeMake(boardBg:getContentSize().width, boardBg:getContentSize().height*0.95),
                        viewSize = CCSizeMake(self:getContentSize().width , self:getContentSize().height*0.95),
                        -- itemId = debrisList[1]["itemId"],
                        createDiaoLuoLayer = createCollectLayer,
                        hechengFunc = hechengLayer,
                        -- curNum = debrisList[1]["itemCnt"],
                        listData = debrisList
                    })
                end

                local function refreshFunc(cell, idx)
                    cell:refresh(idx+1)
                end

                self.itemList = nil
                self.itemList = require("utility.TableViewExt").new({
                    size        = CCSizeMake(self.listView:getContentSize().width,  self.listView:getContentSize().height),-- numBg:getContentSize().height - 20),
                    direction   = kCCScrollViewDirectionVertical,
                    createFunc  = createFunc,
                    refreshFunc = refreshFunc,
                    cellNum   = #debrisList,
                    cellSize    = require("game.Equip.EquipV2.EquipDebrisCellVTwo").new():getContentSize(),
                    scrollFunc = function()
                        -- PageMemoModel.saveOffset("equipDebirs",self.itemList)
                    end
                })

                -- PageMemoModel.resetOffset("equipDebirs",self.itemList)

                self:setCurNum(#debrisList)

                self.scrollLayerNode:addChild(self.itemList)

            end})
    end
    ---------


    self.upDebrisFunc = updateDebriList

    self.sellMoney = 0
    local function changeSoldMoney(num)
--        if self.sellMoney+num >= 0 then
--            self.sellMoney = self.sellMoney + num
--
--            self.sellFrame:setRightNum(self.sellMoney)
--        end
        self:getSellMoney()

    end

    local  function addSellItemFunc(itemId,index)
        self.sellIndex[index] = true
        self.sellTable[#self.sellTable + 1] = itemId
        self.sellFrame:setLeftNum(#self.sellTable)

    end

    local function removeSellItemFunc(itemId,index)
        self.sellIndex[index] = false

        for i = 1,#self.sellTable do
            if self.sellTable[i] == itemId then
                table.remove(self.sellTable,i)
            end
        end

        self.sellFrame:setLeftNum(#self.sellTable)
    end

    local function clearSellData()
        for i = 1,#self.sellTable do
            for j = 1,#self.sellList do
                if self.sellTable[i] == self.sellList[j]["_id"] then
                    table.remove(self.sellList,j)
                    break
                end
            end
        end

        for i = 1,#self.sellTable do
            for j = 1,#self.commonList do
                if self.sellTable[i] == self.commonList[j]["_id"] then
                    table.remove(self.commonList,j)
                    break
                end
            end
        end
        self.sellMoney = 0
        self.sellTable = {}
        self.sellIndex = {}
        self.equipTable:resetCellNum(#self.commonList,false,false)

        self.equipSellTable:resetCellNum(#self.sellList,false,false)
        self.sellFrame:setRightNum(0)
        self.sellFrame:setLeftNum(0)

        self:setCurNum(#self.commonList)

    end

    local function sellFunc()
        local sellStr = ""
        if #self.sellTable == 0 then

            -- show_tip_label("请选择要出售的装备")
            ResMgr.showErr(500011)
        else
            for i =1,#self.sellTable do
                if #sellStr ~= 0 then
                    sellStr = sellStr..","..self.sellTable[i]
                else
                    sellStr = sellStr..self.sellTable[i]
                end
            end

            RequestHelper.sendSellEquipRes({
                callback = function(data)
                    dump(data)
                    if #data["0"] > 0 then
                        show_tip_label(data["0"])
                    else
                        game.player.m_silver=data["1"][2]
                        show_tip_label("出售成功,获得"..data["1"][1].."银币")
                        self._rootnode["silverLabel"]:setString(data["1"][2])
                        PostNotice(NoticeKey.MainMenuScene_Update)
                    end
                    clearSellData()
                end,
                ids = sellStr
            })
        end
    end
    self.sellFunc = sellFunc


    --    选项卡切换
    local function onTabBtn(tag)
        if self.firstTab == nil then
            self.firstTab = false
        else
            if self.tabId ~= tag then
                GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian)) 
            end
        end
        if TAB_TAG.XIAKE == tag then
           if self.tabId == 2 then
                self.tabId = 1
                self:SendReq()
            end

            self._rootnode["left"]:setZOrder(10)
            self._rootnode["right"]:setZOrder(9)
            sellBtn:setVisible(true)
            extendBtn:setVisible(true)
            self._rootnode["numTag"]:setVisible(true)

            local function createXiLianLayer(indexId)
--                local XiLianLayer = require("game.Equip.EquipXiLianLayer").new({
--                    _id = indexId,
--                    listData = self.commonList,
--                    removeListener = function() self:reloadBroadcast() end
--                })
--                self:addChild(XiLianLayer,103)
                local layer = require("game.Equip.FormEquipXiLianLayer").new({
                    info = self.commonList[indexId + 1],
                    listener = function()
                        local cell = self.equipTable:cellAtIndex(indexId)

                        cell:refresh(indexId, self.viewType, self.commonList[indexId + 1])
                    end
                })
                game.runningScene:addChild(layer, 103)
            end

            local function createQiangHuaLayer(indexId)

                local layer = require("game.Equip.FormEquipQHLayer").new({
                    info = self.commonList[indexId + 1],
                    listener = function(isQiangHua)
                        local cell = self.equipTable:cellAtIndex(indexId)
                         EquipModel.sort(self.commonList)
                         if isQianghua == true then
                             self.equipTable:resetCellNum(#self.commonList,false,false)
                        else
                            self.equipTable:resetCellNum(#self.commonList)
                        end
                        -- cell:refresh(indexId, self.viewType, self.commonList[indexId + 1])
                        -- dump(self.commonList[indexId + 1])
                        -- self.isQianghua

                        
                    end
                })
                game.runningScene:addChild(layer, 103)
            end

            local function createEquipInfoLayer(index)

                if self.viewType ==  COMMON_VIEW then
                    local layer = require("game.Equip.CommonEquipInfoLayer").new({
                        info = self.commonList[index+1],
                        listener = function()
                            local cell = self.equipTable:cellAtIndex(index)
                            cell:refresh(index, self.viewType, self.sellIndex[index + 1])
                        end
                    }, 2)
                    game.runningScene:addChild(layer, 10)
                else

                    local cellData = self.sellList[index + 1]


                    local itemInfo = require("game.Huodong.ItemInformation").new({
                        id = cellData.resId,
                        type = 1                       
                        })

                     display.getRunningScene():addChild(itemInfo, 100000)
                end



            end
            local function createFunc(idx)
                local item = require("game.Equip.EquipV2.EquipListCellVTwo").new()
                return item:create({
                    id       = idx,
                    viewSize = CCSizeMake(self:getContentSize().width, self:getContentSize().height*0.95),
                    listData = self.commonList,
                    nameData = self.nameList,
                    saleData = self.sellList,
                    viewType = self.viewType,
                    choseTable = self.sellTable,
                    changeSoldMoney =changeSoldMoney,
                    addSellItem =addSellItemFunc,
                    removeSellItem =  removeSellItemFunc,
                    createXiLianListenr=createXiLianLayer,
                    createQiangHuaListener = createQiangHuaLayer,
                    createEquipInfoLayer = createEquipInfoLayer
                })

            end

            local function refreshFunc(cell, idx)
                cell:refresh(idx,COMMON_VIEW,self.sellIndex[idx + 1])
            end



            self.equipTable = nil
            self.equipTable = require("utility.TableViewExt").new({
                size        = CCSizeMake(self:getContentSize().width, self.getCenterHeightWithSubTop()),-- numBg:getContentSize().height - 20),
                direction   = kCCScrollViewDirectionVertical,
                createFunc  = createFunc,
                refreshFunc = refreshFunc,
                cellNum   = #list,
                cellSize    = require("game.Equip.EquipV2.EquipListCellVTwo").new():getContentSize(),
                scrollFunc  = function()
                    PageMemoModel.saveOffset("equipTable",self.equipTable)
                end
            })
            PageMemoModel.resetOffset("equipTable",self.equipTable)

            local function refreshSellFunc(cell, idx)
                cell:refresh(idx,SALE_VIEW,self.sellIndex[idx + 1])
            end

            self.equipSellTable = nil 
            self.equipSellTable = require("utility.TableViewExt").new({
                size        = CCSizeMake(self:getContentSize().width, self.getCenterHeightWithSubTop()),-- numBg:getContentSize().height - 20),
                direction   = kCCScrollViewDirectionVertical,
                createFunc  = createFunc,
                refreshFunc = refreshSellFunc,
                cellNum   = #self.sellList,
                cellSize    = require("game.Equip.EquipV2.EquipListCellVTwo").new():getContentSize(),
                scrollFunc  = function()
                    PageMemoModel.saveOffset("equipSellTable",self.equipTable)
                end
            })

            PageMemoModel.resetOffset("equipSellTable",self.equipTable)

            self:setCurNum(#list)
            self.scrollLayerNode:removeAllChildren()
            self.scrollLayerNode:addChild(self.equipTable)
            self.scrollLayerNode:addChild(self.equipSellTable)
            self.equipSellTable:setVisible(false)


        elseif TAB_TAG.SOUL == tag then
            self._rootnode["left"]:setZOrder(9)
            self._rootnode["right"]:setZOrder(10)
            self._rootnode["numTag"]:setVisible(false)
            sellBtn:setVisible(false)
            extendBtn:setVisible(false)
            local function createCollectLayer(itemId)
                print("coooollllll")
                local collectLayer = require("game.Hero.CollectLayer").new(itemId,ResMgr.ITEM)
                -- collectLayer:setPosition(display.width/2,display.height/2)
                self:addChild(collectLayer,103)
            end

            self.tabId = 2
            extendBtn:setVisible(false)
            sellBtn:setVisible(false)
            updateDebriList()
        else
            assert(false, "EquipListScene onTabBtn Tag Error!")
        end
        self._currentTab = tag

        for i = 1, 2 do
            if tag == i then
                self._rootnode["tab" ..tostring(i)]:selected()
            else
                self._rootnode["tab" ..tostring(i)]:unselected()
            end
        end
    end

    --初始化选项卡
    local function initTab()
        for i = 1, 2 do
            self._rootnode["tab" ..tostring(i)]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onTabBtn)
        end
        self._rootnode["tab1"]:selected()
    end
    if self._bInit ~= true then
        initTab()
    end

    onTabBtn(self._currentTab)
    self:onCommonView()

    self._bInit = true
end

function EquipListScene:ctor(tag)
    ResMgr.removeBefLayer()
    if tag == nil or tag < 0 or tag > 2 then
        self._currentTab = TAB_TAG.XIAKE
    else
        self._currentTab = tag
    end
    -- self:setNodeEventEnabled(true)
--
--    display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
--    display.addSpriteFramesWithFile("ui/ui_main_menu.plist", "ui/ui_main_menu.png")
    self.viewType = COMMON_VIEW

    --初始化下边框

    local iconSprite = display.newSprite("#mm_silver.png", x, y, params)

    self.sellFunc = nil
    self.sellFrame = require("utility.SellFrame").new({
        leftTitle = "已选择物品:",
        rightTitle = "总计出售",
        icon = iconSprite,
        sellFunc = function()
        -- local confirmMsgBox = require("utility.MsgBox").new({content = })
        -- display:getRunningScene():addChild(confirmMsgBox,9999)

            self.sellFunc()
        end
    })
    self:addChild(self.sellFrame,1)

    self.listView = self._rootnode["listView"]

    self.baseNode = display.newNode()
    self.listView:addChild(self.baseNode)
    self.scrollLayerNode = display.newNode()
    self.baseNode:addChild(self.scrollLayerNode)


    self.commonList  = {}
    self.sellList = {}
    self.sellIndex ={}
    self.bExit = false
    self.equipTable = nil
    self:SendReq()

end


function EquipListScene:onEnter()
    
    game.runningScene = self
    if self.bExit then
        self:reloadBroadcast()
    end
    self.bExit = false
    self:regNotice()
    PostNotice(NoticeKey.UNLOCK_BOTTOM)
end

function EquipListScene:onExit()
    PageMemoModel.clear("equipDebirs")
    PageMemoModel.clear("equipTable")
    PageMemoModel.clear("equipSellTable")



    HeroSettingModel.cardIndex = 0
    self.bExit = true
    self:unregNotice()
end

-- 重新加载广播
function EquipListScene:reloadBroadcast()
    local broadcastBg = self._rootnode["broadcast_tag"]
    if game.broadcast:getParent() ~= nil then
        game.broadcast:removeFromParentAndCleanup(true)
    end
    broadcastBg:addChild(game.broadcast)
end

return EquipListScene
