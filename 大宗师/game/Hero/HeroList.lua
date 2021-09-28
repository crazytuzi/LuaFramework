--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-7-7
-- Time: 下午4:55
-- To change this template use File | Settings | File Templates.
--
local HeroList = class("HeroList", function()

    return require("game.BaseScene").new({
        contentFile = "hero/hero_list_bg.ccbi",
        subTopFile = "hero/hero_up_tab.ccbi"
    })
end)




local TAB_TAG = {
    XIAKE = 1,
    SOUL = 2
}

local COMMON_VIEW = 1
local SALE_VIEW = 2

local LISTVIEW_TAG = 100
function HeroList:SendReq()
    RequestHelper.getHeroList({
        callback = function(data)
            self._cost = {data["4"], data["5"]}
            self:init(data)
            if(offset ~= nil) then
                -- self.heroTable:setContentOffset(offset)
            end
        end})
    
end

function HeroList:resetPos()
    local xiedai = self._rootnode["xiedai"]
    local curNum = self._rootnode["curNum"]
    local sign  = self._rootnode["sign"]
    local maxNum = self._rootnode["maxNum"]
    curNum:setPosition(xiedai:getPositionX()+xiedai:getContentSize().width,xiedai:getPositionY())
    sign:setPosition(curNum:getPositionX()+curNum:getContentSize().width,xiedai:getPositionY())
    maxNum:setPosition(sign:getPositionX()+sign:getContentSize().width,xiedai:getPositionY())
end

function HeroList:setCurNum(num)
    self._rootnode["curNum"]:setString(num)
    self:resetPos()
end

function HeroList:setMaxNum(num)
    self._rootnode["maxNum"]:setString(num)
    self:resetPos()
end

function HeroList:onSaleView()
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

    --显示侠客出售标题
    self._rootnode["sell_title"]:setVisible(true)

    --显示下面的出售数量和价格的下边框
    --self._downNode["sell_bottom_frame"]
    self.sellFrame:setVisible(true)
    --
    self._rootnode["numTag"]:setVisible(false)

    --隐藏下面的常用场景切换下边框
    self._rootnode["bottomNode"]:setVisible(false)
      --更新sale的list
    self:refreshSellAbleList()

    self.sellMoney = 0


    --清理下面的出售数量和钱的选项卡
    self.sellFrame:setRightNum(0)
    self.sellFrame:setLeftNum(0)
end

function HeroList:onCommonView()
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

    --隐藏侠客出售标题
    self._rootnode["sell_title"]:setVisible(false)

    --隐藏下面的出售数量和价格的下边框
    -- self._downNode["sell_bottom_frame"]:
    self.sellFrame:setVisible(false)
    self._rootnode["numTag"]:setVisible(true)
    --显示下面常用的场景切换框
    self._rootnode["bottomNode"]:setVisible(true)

    --更新common的list
    self:refreshCommonList()
end

function HeroList:refreshCommonList()
    self.commonList = HeroModel.totalTable

    self.heroTable:setVisible(true)
    self.sellHeroTable:setVisible(false)

    if self.heroDebrisList ~= nil then
        self.heroDebrisList:setVisible(false)
    end
    self.heroTable:resetListByNumChange(#self.commonList)

end

function HeroList:refreshSellAbleList()
    self.heroTable:setVisible(false)
    self.sellHeroTable:setVisible(true)
    if self.heroDebrisList ~= nil then
        self.heroDebrisList:setVisible(false)
    end

    self.sellList = HeroModel.getSellAbleTable()


    self.sellHeroTable:resetCellNum(#self.sellList,false,false)

  

    -- if self.isFirstSellList == nil then
    --     self.isFirstSellList = false
    -- else
        -- PageMemoModel.resetOffset("sellherolist",self.sellHeroTable)
    -- end
end



function HeroList:init(data)
    self.sellTable = {}

     HeroModel.setHeroTable(data["1"])
    

    self.sellList = HeroModel.getSellAbleTable()  -- {}

    -- self.heroDebrisList = nil 

    local maxHeroNum = data["3"]
    self:setMaxNum(maxHeroNum)
    local sellBtn = self._rootnode["sellBtn"]
   

    local boardBg = self._rootnode["heroListBg"]
    -- boardBg:setContentSize(CCSizeMake(display.width,display.height))


    

    local numTag = self._rootnode["numTag"]


    -- self.baseNode = display.newNode()

    numTag:setZOrder(20)



    self._rootnode["sellBtn"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        self:onSaleView()        
    end,CCControlEventTouchUpInside)
    self._rootnode["backBtn"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        self:onCommonView()
    end,
    CCControlEventTouchUpInside)

    
    

    self:updateLabel()

    --更新碎片list
    local function updateDebriList ()
        --发送请求
        RequestHelper.getHeroDebrisList({
            callback = function(listData)

                local debrisList = listData["1"]
                HeroModel.debrisData = debrisList
 
                local function createCollectLayer(debrisId)

                    local collectLayer = require("game.Hero.CollectLayer").new(debrisId)
                    self:addChild(collectLayer,103)
                end

                local function hechengLayer(hechengData)
                    RequestHelper.sendHeChengHeroRes({
                        callback = function(listData)
  
                            if listData["5"] == true then
                                ResMgr.showMsg(2)
                            else


                                if string.len(listData["0"]) > 0 then 
                                    CCMessageBox(listData["0"], "Tip") 
                                else
                                    local isFull = listData["3"] or false 

                                    if not isFull then 
                                        self.upDebrisFunc()
                                        show_tip_label("侠客合成成功") 
                                        
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
                    local item = require("game.Hero.HeroDebrisCell").new()

                    return item:create({
                        id       = idx,
                        viewSize = CCSizeMake(boardBg:getContentSize().width, boardBg:getContentSize().height*0.95),
                        -- itemId = debrisList[1]["itemId"],
                        createDiaoLuoLayer = createCollectLayer,
                        hechengFunc = hechengLayer,
                        -- curNum = debrisList[1]["itemCnt"],
                        -- listData = HeroModel.debrisData
                    })
                end

                local function refreshFunc(cell, idx)
                    cell:refresh(idx+1)
                end



                if self.isFirstDebrisList == nil then
                    self.isFirstDebrisList = false

                    self.heroDebrisList = nil
                    local itemList = require("utility.TableViewExt").new({
                        size        =   self._rootnode["heroListBg"]:getContentSize(), --CCSizeMake(boardBg:getContentSize().width, self.getCenterHeightWithSubTop()),-- numBg:getContentSize().height - 20),
                        direction   = kCCScrollViewDirectionVertical,
                        createFunc  = createFunc,
                        refreshFunc = refreshFunc,
                        cellNum     = #HeroModel.debrisData,
                        cellSize    = require("game.Hero.HeroDebrisCell").new():getContentSize(),
                        scrollFunc  = function ()
                            
                                -- PageMemoModel.saveOffset("hero_debris_list",self.heroDebrisList)

                        end
                    })
                    self.heroDebrisList = itemList


                    -- PageMemoModel.saveOffset("hero_debris_list",self.heroDebrisList)
                    -- PageMemoModel.resetOffset("hero_debris_list",self.heroDebrisList)
                    self.scrollLayerNode:addChild(itemList)
                else
                    self.heroDebrisList:resetCellNum(#HeroModel.debrisData,false,false)

                end

                -- PageMemoModel.resetOffset("hero_debris_list",self.heroDebrisList)

                self:setCurNum(#debrisList)
                -- self.scrollLayerNode:removeAllChildren()
                -- print("heheheheeheheheh")
                self.heroTable:setVisible(false)
                self.heroDebrisList:setVisible(true)
                self.sellHeroTable:setVisible(false)
                

            end})
    end
    self.upDebrisFunc = updateDebriList

    self.sellMoney = 0
    local function changeSoldMoney(num)
        if self.sellMoney+num >= 0 then 
            self.sellMoney = self.sellMoney + num
            
            self.sellFrame:setRightNum(self.sellMoney)
        end
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


        self.sellList = HeroModel.getSellAbleTable()
 
        for i = 1,#self.sellTable do
            for j = 1,#self.commonList do
                if self.sellTable[i] == self.commonList[j]["_id"] then
                    table.remove(self.commonList,j)
                    break
                end                
            end
        end


        HeroModel.totalTable = self.commonList


        self.sellList = HeroModel.getSellAbleTable()

        self.sellIndex = {}
        self:refreshSellAbleList()
        self.sellMoney = 0
        self.sellTable = {}
        

        self.sellFrame:setRightNum(0)
        self.sellFrame:setLeftNum(0)

        self:setCurNum(#self.commonList)
        
    end

    local function sellFunc()
        local sellStr = ""
        if #self.sellTable == 0 then
            -- show_tip_label("请至少选择一个要出售的侠客")
            ResMgr.showErr(200023)
           

        else
            for i =1,#self.sellTable do
                if #sellStr ~= 0 then
                    sellStr = sellStr..","..self.sellTable[i]
                else
                    sellStr = sellStr..self.sellTable[i]
                end
            end


            RequestHelper.sendSellCardRes({
                callback = function(data)

                    clearSellData()
                    
                    show_tip_label("出售成功,获得"..data["1"][1].."银币")
                    

--                    dump(data)
                    game.player.m_silver=data["1"][2]
                    self._rootnode["silverLabel"]:setString(data["1"][2])
                    
                    PostNotice(NoticeKey.MainMenuScene_Update)
                    PostNotice(NoticeKey.CommonUpdate_Label_Silver)

                end,
                ids = sellStr
            })
        end
    end
    self.sellFunc = sellFunc


    --    选项卡切换
    local function onTabBtn(tag)
        if self.firstTabBtn ~= nil then
             if self.tabId ~= tag then
                GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian)) 
            end
          
        else
            self.firstTabBtn = false
        end

        if TAB_TAG.XIAKE == tag then

            if self.tabId == 2 then
                self.tabId = 1
                self:SendReq()
            end

            self._rootnode["left"]:setZOrder(10)
            self._rootnode["right"]:setZOrder(9)
            sellBtn:setVisible(true)
            self.extendBtn:setVisible(true)
            self._rootnode["numTag"]:setVisible(true)

            local function updateTableFunc()
                self.heroTable:resetCellNum(#HeroModel.totalTable,false,false)

            end

            local function resetList()
                 self.heroTable:resetCellNum(#HeroModel.totalTable)
                 self.sellHeroTable:resetCellNum(#self.sellList)
                 self:setCurNum(#HeroModel.totalTable)
               
            end

            

            local function createJinjieLayer(objId,index, closeListener)
                local offset = self.heroTable:getContentOffset()
                local beginNum = self.heroTable:getCellNum()
                local jinJieLayer = require("game.Hero.HeroJinJie").new(
                    {
                        incomeType = 1,
                        listInfo = 
                            {id = objId,
                            updateTableFunc = updateTableFunc,
                            listData = HeroModel.totalTable,
                            cellIndex = index,
                            heroTable = self.heroTable,
                            resetList = resetList,
                            upNumFunc = function(num) self:setCurNum(num)end
                            }, 
                        removeListener = function()
                            --更新common的list
                            -- self:refreshCommonList()
                            resetList()

                            if closeListener then
                                closeListener()
                            end
                            local endNum = self.heroTable:getCellNum()


                            local offHeight = require("game.Hero.HeroListCell").new():getContentSize().height
                            offset.y = offset.y + offHeight * (beginNum - endNum)
                            self.heroTable:setContentOffset(offset)
                            self:SendReq()
                            self:reloadBroadcast()
                            
                        end
                    })


                game.runningScene:addChild(jinJieLayer,1000)
            end

            local function createQiangHuaLayer(objId,index, closeListener)
                local offset = self.heroTable:getContentOffset()
                local beginNum = self.heroTable:getCellNum()
                local qianghuaLayer = require("game.Hero.HeroQiangHuaLayer").new({
                    id = objId,
                    listData = HeroModel.totalTable,
                    visibleBg = boardBg,
                    tableView = self.heroTable,
                    index = index,
                    -- listData = HeroModel.totalTable,
                    resetList = resetList,
                    upNumFunc = function(num) self:setCurNum(num)end,
                    removeListener = function(isQiangHua)
                        self:reloadBroadcast()
                        if closeListener then
                            closeListener()
                        end

                        -- 强化 消耗herolist we need recalc the herolist num and offset Y
                        local endNum = self.heroTable:getCellNum()
                        local offHeight = require("game.Hero.HeroListCell").new():getContentSize().height
                        offset.y = offset.y + offHeight * (beginNum - endNum)
                        self.isQiangHua = isQiangHua
                        print("dumdddd")
                        dump(self.isQiangHua)
                        self:SendReq(offset)
                        self:reloadBroadcast()
                        if isQiangHua == true then
                            self.heroTable:setContentOffset(offset)
                        end

                    end
                })
                game.runningScene:addChild(qianghuaLayer,1000)
            end

            local function onHeroInfoLayer(index)
                if self.viewType == SALE_VIEW then
                    local cellData = self.sellList[index]

                    local itemInfo = require("game.Huodong.ItemInformation").new({
                        id = cellData.resId,
                        type = 8                       
                        })

                 display.getRunningScene():addChild(itemInfo, 100000)

                else
                    local offset = self.heroTable:getContentOffset()                    
                    local layer = require("game.Hero.HeroInfoLayer").new({
                        info = {
                            resId = HeroModel.totalTable[index].resId,
                            levelLimit = 8888,
                            objId = HeroModel.totalTable[index]._id
                        },
                        cellIndex = index,
                        createJinjieLayer = createJinjieLayer,
                        createQiangHuaLayer = createQiangHuaLayer,
                        removeListener = function()
                            self.heroTable:reloadData()
                            self.heroTable:setContentOffset(offset)
                        end
                    }, 2)
                    game.runningScene:addChild(layer, 1000)
                end
            end

            local function createFunc(idx)
                local item = require("game.Hero.HeroListCell").new()
                return item:create({
                    id       = idx,
                    viewSize = CCSizeMake(self:getContentSize().width, self:getContentSize().height*0.95),
                    listData = HeroModel.totalTable,
                    saleData = self.sellList,
                    viewType = self.viewType,
                    choseTable = self.sellTable,
                    changeSoldMoney =changeSoldMoney,
                    addSellItem =addSellItemFunc,
                    removeSellItem =  removeSellItemFunc,
                    createJinjieListenr=createJinjieLayer,
                    createQiangHuaListener = createQiangHuaLayer,
                    onHeadIcon = onHeroInfoLayer
                })


            end

            local function refreshFunc(cell, idx)
                cell:refresh(idx,COMMON_VIEW,self.sellIndex[idx + 1])
            end
           
           -- 



            local function refreshSellFunc(cell, idx)
                cell:refresh(idx,SALE_VIEW,self.sellIndex[idx + 1])
            end
            self.sellList = HeroModel.getSellAbleTable()
            -- 

            if self.isFirstInitHeroTable == nil then
                self.isFirstInitHeroTable =false

                self.heroTable     = nil
                self.sellHeroTable = nil

                self.heroTable = require("utility.TableViewExt").new({
                    size        = self._rootnode["heroListBg"]:getContentSize(), --CCSizeMake(self:getContentSize().width, self.getCenterHeightWithSubTop()),-- numBg:getContentSize().height - 20),
                    direction   = kCCScrollViewDirectionVertical,
                    createFunc  = createFunc,
                    refreshFunc = refreshFunc,
                    cellNum   = #HeroModel.totalTable,
                    cellSize    = require("game.Hero.HeroListCell").new():getContentSize(),
                    scrollFunc = function()     

                        -- PageMemoModel.saveOffset("herolist",self.heroTable) 
                                          
                    end
                })

                self.sellHeroTable = require("utility.TableViewExt").new({
                    size        = self._rootnode["heroListBg"]:getContentSize(), --CCSizeMake(self:getContentSize().width, self.getCenterHeightWithSubTop()),-- numBg:getContentSize().height - 20),
                    direction   = kCCScrollViewDirectionVertical,
                    createFunc  = createFunc,
                    refreshFunc = refreshSellFunc,
                    cellNum   = #self.sellList,
                    cellSize    = require("game.Hero.HeroListCell").new():getContentSize(),
                    scrollFunc = function()
                        -- PageMemoModel.saveOffset("sellherolist",self.sellHeroTable)
                    end
                })


                -- PageMemoModel.resetOffset("herolist",self.heroTable) 
                -- PageMemoModel.resetOffset("sellherolist",self.sellHeroTable)

                self.scrollLayerNode:addChild(self.heroTable)
                self.scrollLayerNode:addChild(self.sellHeroTable)
                self.sellHeroTable:setVisible(false)
            else
                if self.isQiangHua == true then
                    -- self.isQiangHua = false
                    self.heroTable:resetCellNum(#HeroModel.totalTable,false,false)
                else
                    self.heroTable:resetCellNum(#HeroModel.totalTable)
                end
                self.sellHeroTable:resetCellNum(#self.sellList)
            end




            local cell = self.heroTable:cellAtIndex(0)
            if cell ~= nil then
                self.jinjieBtn = cell:getJinjieBtn()
                self.headBtn = cell:getHeadIcon()
            end
            
            
            -- self.heroTable:getcell

            self:setCurNum(#HeroModel.totalTable)
            -- self.scrollLayerNode:removeAllChildren()



        elseif TAB_TAG.SOUL == tag then
           
            self._rootnode["left"]:setZOrder(9)
            self._rootnode["right"]:setZOrder(100)
            self._rootnode["numTag"]:setVisible(false)
            sellBtn:setVisible(false)
            self.extendBtn:setVisible(false)
            local function createCollectLayer()
                local collectLayer = require("game.Hero.CollectLayer").new()
                -- collectLayer:setPosition(display.width/2,display.height/2)
                self:addChild(collectLayer,103)
            end

            self.tabId = 2
            self.extendBtn:setVisible(false)
            sellBtn:setVisible(false)


            updateDebriList()
            
        else
            assert(false, "HeroList onTabBtn Tag Error!")
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
    if self.isFirst == nil then
        self.isFirst = true
        initTab()
    end
    onTabBtn(self._currentTab)
    self:onCommonView()

    -- dump("initTab  onCommonView")

    TutoMgr.addBtn("herolist_zhujue_jinjie_btn",self.jinjieBtn)
    TutoMgr.addBtn("herolist_zhujue_head_btn",self.headBtn)
    TutoMgr.active()
end

function HeroList:ctor(tag)
    game.runningScene = self


    ResMgr.createBefTutoMask(self)
    
    -- local layer = display.newColorLayer(ccc4(100, 0, 0, 100))
    -- layer:setTouchEnabled(true)
    -- self:addChild(layer)

    if tag == nil or tag < 0 or tag > 2 then 
        self._currentTab = TAB_TAG.XIAKE
    else
        self._currentTab = tag 
    end

    self:setNodeEventEnabled(true)
    display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
    display.addSpriteFramesWithFile("ui/ui_main_menu.plist", "ui/ui_main_menu.png")
    self.viewType = COMMON_VIEW

    --初始化下边框
    
    local iconSprite = display.newSprite("#mm_silver.png")

    self.sellFunc = nil
    self.sellFrame = require("utility.SellFrame").new({
        leftTitle = "已选择侠客:",
        rightTitle = "总计出售",
        icon = iconSprite,
        sellFunc = function()
            -- local confirmMsgBox = require("utility.MsgBox").new({content = })
            -- display:getRunningScene():addChild(confirmMsgBox,9999)
            
            self.sellFunc()
        end
        })
    self:addChild(self.sellFrame,1)
    

    self.extendBtn =self._rootnode["expandBtn"]
    local function extend( ... )
        RequestHelper.extendBag({
            type = 8,
            callback = function(data)
--                dump(data)
               
                if (string.len(data["0"]) == 0) then

                    local bagCountMax = data["1"]
                    local costGold    = data["2"]
                    local curGold     = data["3"]
                    game.player:setBagCountMax(bagCountMax)
                    game.player:setGold(curGold)
                    self:updateLabel()
                    self:setMaxNum(bagCountMax)

                    self._cost[1] = data["4"]
                    self._cost[2] = data["5"]

                    -- show_tip_label("卡牌上限提升至"..bagCountMax)
                    ResMgr.showErr(200025)
   

                    PostNotice(NoticeKey.MainMenuScene_Update)
                else
                    CCMessageBox(data["0"], "Error")
                end
             
            end
        })
    end
    self._rootnode["expandBtn"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if self._cost[1] ~= -1 then          

            local layer = require("utility.CostTipMsgBox").new({
                tip = string.format("开启%d个位置吗？", self._cost[2]),
                listener = function()
                    if(game.player.m_gold >= self._cost[1]) then
                        extend()
                    else
                        -- show_tip_label("元宝不足")
                        ResMgr.showErr(2300007)
                    end
                end,
                cost = self._cost[1],
            })


            self:addChild(layer, 100)
        else
            -- show_tip_label("已经达到最大扩展空间")
            ResMgr.showErr(200024)
        end

    end,CCControlEventTouchUpInside)

      local function quickChoseFunc(selTable)

        for i = 1, #selTable do
            if selTable[i] == true then
                for j = 1,#self.sellList do
                    if self.sellList[j]["star"] == i then --
                        --判断是否已经在sellTable里
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
        local num = 0
        local curMoney = 0

        for k,v in pairs(self.sellIndex) do
            if v == true then
                num = num + 1
                curMoney = curMoney + ResMgr.getCardData(self.sellList[k]["resId"])["price"]
            end
        end




        self.sellFrame:setRightNum(curMoney)
        self.sellFrame:setLeftNum(num)
        self.sellHeroTable:resetCellNum(#self.sellList,false,false)

    end





    --按星级出售界面
    self._rootnode["sellStarBtn"]:addHandleOfControlEvent(function(eventName,sender)
         self._rootnode["sellStarBtn"]:setEnabled(false)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
         local small = CCScaleTo:create(0.1, 0.8)
         local bigger = CCScaleTo:create(0.1, 1)
         self._rootnode["sellStarBtn"]:runAction(transition.sequence({small,bigger}))
        
        local heroQuickSel = require("game.Hero.HeroQuickChose").new(quickChoseFunc,function() 
            self._rootnode["sellStarBtn"]:setEnabled(true)
         end)
        display:getRunningScene():addChild(heroQuickSel,10)
    end,CCControlEventTouchUpInside)

    --
    self.listView = self._rootnode["listView"]
    -- self.listView:removeAllChildren()
    self.scrollLayerNode = display.newNode()
    self.listView:addChild(self.scrollLayerNode)

    self.commonList  = {}
    self.sellList = {}
    self.sellIndex ={}
    self:SendReq()
    self._bExit = false


end

-- 重新加载广播
function HeroList:reloadBroadcast()
    local broadcastBg = self._rootnode["broadcast_tag"] 

        if game.broadcast:getParent() ~= nil then 
            game.broadcast:removeFromParentAndCleanup(true)
        end
        broadcastBg:addChild(game.broadcast)
end

function HeroList:updateLabel()
    self._rootnode["goldLabel"]:setString(game.player:getGold())
    self._rootnode["silverLabel"]:setString(game.player:getSilver())
end



function HeroList:onEnter()
    game.runningScene = self
    self:regNotice()


    -- 广播
    if self._bExit then
        self._bExit = false
        self:reloadBroadcast()
    end
    TutoMgr.addBtn("herolist_zhujue_jinjie_btn",self.jinjieBtn)
    TutoMgr.addBtn("herolist_zhujue_head_btn",self.headBtn)
    -- if self.jinjieBtn ~= nil then
    --     TutoMgr.active()
    -- end
    TutoMgr.addBtn("zhujiemian_btn_shouye",self._rootnode["mainSceneBtn"]) --zhujiemian_btn_shouye
    TutoMgr.addBtn("zhujiemian_btn_zhenrong",self._rootnode["formSettingBtn"]) --zhujiemian_btn_zhenrong
     -- CCMessageBox("", "bef")
    TutoMgr.addBtn("zhenrong_btn_fuben",self._rootnode["battleBtn"]) --zhenrong_btn_fuben

    TutoMgr.addBtn("zhujiemian_btn_huodong",self._rootnode["activityBtn"]) --zhujiemian_btn_huodong
    TutoMgr.addBtn("zhujiemian_btn_beibao",self._rootnode["bagBtn"]) --zhujiemian_btn_beibao
    TutoMgr.addBtn("zhujiemian_btn_shangcheng",self._rootnode["shopBtn"]) --zhujiemian_btn_shangcheng
    print("herolistononon")

    if self.isActive ~= nil then
        ResMgr.createBefTutoMask(self)
        TutoMgr.active()
    else
        self.isActive = true
    end
end


function HeroList:onExit()
    self._bExit = true
    self:unregNotice()


    TutoMgr.removeBtn("herolist_zhujue_jinjie_btn")
    TutoMgr.removeBtn("herolist_zhujue_head_btn")
    TutoMgr.removeBtn("zhujiemian_btn_shouye") --zhujiemian_btn_shouye
    TutoMgr.removeBtn("zhujiemian_btn_zhenrong") --zhujiemian_btn_zhenrong
    TutoMgr.removeBtn("zhenrong_btn_fuben") --zhenrong_btn_fuben
    TutoMgr.removeBtn("zhujiemian_btn_huodong") --zhujiemian_btn_huodong
    TutoMgr.removeBtn("zhujiemian_btn_beibao") --zhujiemian_btn_beibao
    TutoMgr.removeBtn("zhujiemian_btn_shangcheng") --zhujiemian_btn_shangcheng
end



return HeroList
