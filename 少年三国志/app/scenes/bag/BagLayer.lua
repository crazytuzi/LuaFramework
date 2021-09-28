local BagLayer = class ("BagLayer", UFCCSNormalLayer)
local BagPropItem = require("app.scenes.bag.BagPropItem")
require("app.cfg.role_info")
require("app.cfg.item_info")
require("app.cfg.basic_figure_info")
require("app.cfg.item_box_info")
local BagConst = require("app.const.BagConst")
local ItemConst = require("app.const.ItemConst")
local CheckFunc = require("app.scenes.common.CheckFunc")
local FunctionLevelConst = require "app.const.FunctionLevelConst"

BagLayer.roseId = 0  --通过patch修改这个值

function BagLayer.create(selectedIndex,packScene)   
    return BagLayer.new("ui_layout/bag_Baglayer.json",selectedIndex,packScene) 
end


function BagLayer:ctor(json,selectedIndex,packScene,...)
    self._checkType = selectedIndex or 1
    --道具
    self._listView = nil

    self._juexingLayer = nil
    self._isMultiUse = false

    --self._packScene = packScene
    GlobalFunc.savePack(self, packScene)

    self.super.ctor(self,...)
    self:_initWidgets()
end

function BagLayer:_initWidgets()
    self:registerWidgetTouchEvent("Label_toShop",function(widget,_type)
        if  _type == TOUCH_EVENT_ENDED then
            uf_sceneManager:replaceScene(require("app.scenes.shop.ShopScene").new(nil,nil,-1))
        end
        end)
    self:registerBtnClickEvent("Button_tujian",function()
        --点击图鉴
        local layer = require("app.scenes.bag.BagAwakenItemHandBookLayer").create()
        uf_sceneManager:getCurScene():addChild(layer)
    end)

    self:registerBtnClickEvent("Button_Item_Compose", function (  )
        uf_sceneManager:replaceScene(require("app.scenes.bag.itemcompose.ItemComposeScene").new(nil, nil, 11, nil, 
                                                        GlobalFunc.sceneToPack("app.scenes.bag.BagScene", {})))
    end)

    --[[
    self:registerBtnClickEvent("Button_back",function()
            local packScene = G_GlobalFunc.createPackScene(self)
            if not packScene then 
                packScene = require("app.scenes.mainscene.MainScene").new()
            end
            uf_sceneManager:replaceScene(packScene)
        end)
    ]]
end

function BagLayer:_initListView()
    if self._listView ~= nil then
        return
    end
    local panel = self:getPanelByName("Panel_listview")    
    self._listView = CCSListViewEx:createWithPanel(panel,LISTVIEW_DIR_VERTICAL)
    self._listView:setCreateCellHandler(function(list,index)
        local item = BagPropItem.new()       
        return item
    end)
    self:registerListViewEvent("Panel_listview", function ( ... )
            -- this function is used for new user guide, you shouldn't care it
        end)
    
    local propList = G_Me.bagData.propList:getList()
    self._listView:setUpdateCellHandler(function(list,index,cell)
        local prop = propList[index+1]
        cell:updateCell(prop)
        cell:setUseBtnClickEvent(function()
            local item = item_info.get(prop.id)
            __LogTag(TAG,"使用道具")
            --G_HandlersManager.bagHandler:sendUseItemInfo(propList[index+1].id)
            self:_useItem(prop.id, prop.num)
            
        end)
        cell:setMultiUseBtnClickEvent(function (  )
            local item = item_info.get(prop.id)
            __LogTag(TAG,"使用道具")
            --G_HandlersManager.bagHandler:sendUseItemInfo(propList[index+1].id)
            self:_useItem(prop.id, prop.num, true)
        end)
        cell:setCheckItemInfoFunc(function() 
            local item = item_info.get(prop.id)
            if item.item_type == 1 then
                require("app.cfg.drop_info")
                local drop_info = drop_info.get(item.item_value)
                if drop_info ~= nil and drop_info.big_type == 1 then 
                  --礼包类型，并且所有的均掉落
                  if item.id == 42 then
                      --名将魂珠
                      require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_ITEM, prop.id) 
                  else
                      local layer = require("app.scenes.shop.ShopGiftReviewDialog").create(item)
                      uf_sceneManager:getCurScene():addChild(layer)
                  end
                else
                    require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_ITEM, prop.id) 
                end
            else 
                require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_ITEM, prop.id) 
            end
        end)
    end)
    self._tabs:updateTab("CheckBox_item", self._listView)
    self._listView:setSpaceBorder(0,100)
    self._listView:initChildWithDataLength(#propList,0.2)
end

--[[
    使用消耗类的道具即 item.use_type == 1
    1-礼包类(按钮使用)
    2-武将升星石
    3-三国志碎片
    4-武将光环石
    5-武将培养石
    6-装备精炼石
    7-技能书
    8-体力恢复类（pvp值）(按钮使用)
    9-精力恢复类（pve值）(按钮使用)
    10-招募令
    11.精炼石
    12.刷新令
    13.免战牌
    14. 宝物精炼石
    15.技能卷轴
    16.出征令恢复（叛军值）（按钮使用）
    17.纯描述类道具
    18.时装精华
    19.任务道具
    20.觉醒道具
    21.n选1道具(item_box_info)
    22.时装箱子(item_choose_info)
    23.幸运色子
    24.称号道具
]]
function BagLayer:_useItem(itemId, propNum, isMultiUse)
    local item = item_info.get(itemId)
    if not item then
        return
    end

    self._isMultiUse = isMultiUse

    if item.item_type == 1 then   --使用礼包
        if isMultiUse then
            local CheckFunc = require("app.scenes.common.CheckFunc")
            local scenePack = G_GlobalFunc.sceneToPack("app.scenes.bag.BagScene", {})
            if CheckFunc.checkBeforeUseItem(itemId, scenePack) then
                __Log("[BagLayer:_useItem] CheckFunc.checkBeforeUseItem(item_id)")
                return
            end
            require("app.scenes.bag.BagDropMultiUseLayer").show(itemId, propNum)
        else
            G_HandlersManager.bagHandler:sendUseItemInfo(itemId)
        end
    elseif item.item_type == 2 then   --去突破
        uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroFosterScene").new())
    elseif item.item_type == 3 then  --三国志
        local FunctionLevelConst = require("app.const.FunctionLevelConst")
        if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.MING_XING_MODULE) then 
            return
        end
        uf_sceneManager:replaceScene(require("app.scenes.sanguozhi.SanguozhiMainScene").new())
    elseif item.item_type == 4 then --武将光环石
        uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroFosterScene").new())
    elseif item.item_type == 5 then --武将培养石
        uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroFosterScene").new())
    elseif item.item_type == 6 then --装备精炼
        --uf_sceneManager:replaceScene(require("app.scenes.equipment.EquipmentMainScene").new())
    elseif item.item_type == 7 then --技能书
        return
    elseif item.item_type == 8 then  --体力
        local max_limit = basic_figure_info.get(1).max_limit
        if G_Me.userData.vit+item.item_value > max_limit then
            --预判体力是否超出上限了
            G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_VIT_IS_FULL"))
            return
        end  
        require("app.scenes.bag.BagUseItemMultiTimesLayer").show(true, propNum, item, G_Me.userData.vit, max_limit)
        -- G_HandlersManager.bagHandler:sendUseItemInfo(itemId)
    elseif item.item_type == 9 then  --精力
        local max_limit = basic_figure_info.get(2).max_limit
        if G_Me.userData.spirit+item.item_value > max_limit then
            --预判精力是否超出上限了
            G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_SPIRIT_IS_FULL"))
            return
        end            
        require("app.scenes.bag.BagUseItemMultiTimesLayer").show(true, propNum, item, G_Me.userData.spirit, max_limit)
        -- G_HandlersManager.bagHandler:sendUseItemInfo(itemId)
    elseif item.item_type == 10 then
        if itemId == ItemConst.ITEM_ID.LIANG_JIANG_LING then   --良将令
            local layer = require("app.scenes.shop.ShopDropGoodKnightLayer").new()
            uf_sceneManager:getCurScene():addChild(layer)
        elseif itemId == ItemConst.ITEM_ID.SHEN_JIANG_LING then --神将令
            local layer = require("app.scenes.shop.ShopDropGodlyKnightLayer").new()
            uf_sceneManager:getCurScene():addChild(layer)
        end
    elseif item.item_type == 11 then --装备精炼
        uf_sceneManager:replaceScene(require("app.scenes.equipment.EquipmentMainScene").new())
    elseif item.item_type == 12 then --刷新令
        uf_sceneManager:replaceScene(require("app.scenes.secretshop.SecretShopScene").new(nil, nil, nil, nil, GlobalFunc.sceneToPack("app.scenes.bag.BagScene")))
    elseif item.item_type == 13 then --免战
        local leftTime = G_ServerTime:getLeftSeconds(G_Me.userData.forbid_battle_time)
        if leftTime > 0 then
            --处于免战状态
            local _format = G_ServerTime:getLeftSecondsString(G_Me.userData.forbid_battle_time)
            MessageBoxEx.showYesNoMessage(nil,G_lang:get("LANG_MIANZHAN_ZHONG",{time=_format}),false,function()
                G_HandlersManager.bagHandler:sendUseItemInfo(itemId)
            end,nil,self)
            return
        else
            G_HandlersManager.bagHandler:sendUseItemInfo(itemId)
        end
    elseif item.item_type == 14 then --宝物精炼石
        uf_sceneManager:replaceScene(require("app.scenes.treasure.TreasureMainScene").new())
    elseif item.item_type == 15 then  --技能卷轴
        return
    elseif item.item_type == 16 then  --出征令
        local max_limit = basic_figure_info.get(3).max_limit
        if G_Me.userData.battle_token+item.item_value > max_limit then
            --预判精力是否超出上限了
            G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_CHUZHENGLING_IS_FULL"))
            return
        end  
        require("app.scenes.bag.BagUseItemMultiTimesLayer").show(true, propNum, item, G_Me.userData.battle_token, max_limit)
        -- G_HandlersManager.bagHandler:sendUseItemInfo(itemId)
    elseif item.item_type == 17 then --纯描述类道具
        return
    elseif item.item_type == 18 then --时装精华
        return
    elseif item.item_type == 19 then --任务道具/活动道具
        if item.destroy_time > 0 then
            --判断时间是否过期
            local leftSeconds = G_ServerTime:getLeftSeconds(item.destroy_time)
            if leftSeconds <= 0 then
                G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_ITEM_IS_TIME_OUT",{name=item.name}))
                return
            end
            uf_sceneManager:replaceScene(require("app.scenes.activity.ActivityMainScene").new())
        else
            G_HandlersManager.bagHandler:sendUseItemInfo(itemId)
        end
    elseif item.item_type == 20 then --觉醒道具
        uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroFosterScene").new())
    elseif item.item_type == 21 then --n选1道具(item_box_info)
        local item_box = item_box_info.get(item.item_value)
        if item_box then
            
            -- 需要进行批量使用的
            __Log("[BagLayer:_useItem] batch_type = %d", item.batch_type)
            local CheckFunc = require("app.scenes.common.CheckFunc")
            local scenePack = G_GlobalFunc.sceneToPack("app.scenes.bag.BagScene", {})

            local goods = G_Goods.convert(item_box.choice_type_1, item_box.choice_value_1)
            
            if item.batch_type == 1 then
                local maxLimit = 0
                local currNum = 0

                if goods.type == G_Goods.TYPE_EQUIPMENT then
                    -- 装备
                    maxLimit = G_Me.bagData:getMaxEquipmentNumByLevel(G_Me.userData.level)
                    currNum = G_Me.bagData.equipmentList:getCount()
                    if CheckFunc.checkEquipmentFull(scenePack) then
                        return
                    end

                elseif goods.type == G_Goods.TYPE_KNIGHT then
                    -- 武将
                    maxLimit = G_Me.bagData:getMaxKnightNumByLevel(G_Me.userData.level)
                    currNum = G_Me.bagData.knightsData:getKnightCount()
                    if CheckFunc.checkKnightFull(scenePack) then
                        return
                    end
                elseif goods.type == G_Goods.TYPE_TREASURE then
                    -- 宝物
                    maxLimit = G_Me.bagData:getMaxTreasureNum()
                    currNum = G_Me.bagData.treasureList:getCount()
                    if CheckFunc.checkTreasureFull(scenePack) then
                        return
                    end
                else
                    -- 不需要做数量的检查
                end

                require("app.scenes.bag.BagUseItemMultiTimesNChooseOneLayer").show(itemId, item_box, maxLimit, currNum, propNum)
            else
                require("app.scenes.sanguozhi.SanguozhiSelectAwardLayer").showForUseItem(item_box, function(index)
                    G_HandlersManager.bagHandler:sendUseItemInfo(itemId,index)
                end)
            end
        end
    elseif item.item_type == 22 then --.时装箱子(item_choose_info)
        G_HandlersManager.bagHandler:sendUseItemInfo(itemId)
    elseif item.item_type == 23 then --幸运色子
        if G_Me.richData:getState() == 1 or G_Me.richData:getState() == 2 then
            uf_sceneManager:replaceScene(require("app.scenes.dafuweng.RichScene").new())
        else
            G_MovingTip:showMovingTip(G_lang:get("LANG_DAYS7_HAVE_FNINISHED"))
        end
    elseif item.item_type == 24 then --称号道具
        local FunctionLevelConst = require("app.const.FunctionLevelConst")
        if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.TITLE) then 
            return
        end
        uf_sceneManager:replaceScene(require("app.scenes.title.TitleScene").new(item.item_value))
    elseif item.item_type == 26 then -- 宠物口粮
        if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.PET) then 
            return
        end
        uf_sceneManager:replaceScene(require("app.scenes.pet.bag.PetBagMainScene").new())
    elseif item.item_type == 27 then -- 宠物神炼石
        if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.PET) then 
            return
        end
        uf_sceneManager:replaceScene(require("app.scenes.pet.bag.PetBagMainScene").new())
    elseif item.item_type == 28 then -- 宠物升星丹
        if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.PET) then 
            return
        end
        uf_sceneManager:replaceScene(require("app.scenes.pet.bag.PetBagMainScene").new())
    elseif item.item_type == 29 then -- 奇门八卦挂盘
        if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.TRIGRAMS) then 
            return
        end
        --活动结束了
        if G_Me.trigramsData:isClose() then
            G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_ITEM_IS_OVER"))
            return
        end
        uf_sceneManager:replaceScene(require("app.scenes.shop.score.ShopScoreScene").new(SCORE_TYPE.TRIGRAMS, nil, nil, nil, 
            GlobalFunc.sceneToPack("app.scenes.bag.BagScene", {})))
    elseif item.item_type == 30 then -- 化神丹
        uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroFosterScene").new())
    elseif item.item_type == 31 then -- 换装！！！
        G_HandlersManager.bagHandler:sendUseItemInfo(itemId)
    else
        return
    end
end

--[[
    连接至其他模块
    1. 可使用；按钮：使用
    2. 去突破；按钮：去突破；
    3. 去精练；按钮：去精练；
    4. 去洗练；按钮：去洗练；
    5. 去武将光环；按钮：去光环；（这块以后要改，现在也没有这个系统）
    6. 连接至神秘商店；按钮：神秘商店；
    7. 链接至宝物精练；按钮：宝物精练
    8. 打开抽将；按钮：去抽卡
    9. 浮动提示【暂未开启该功能】
    10.三国志系统,去命星
]]


function BagLayer:getRoseIndex()
    local typeList = G_Me.activityData:getTypeList()
    if BagLayer.roseId == 0 then
        return 0
    end
    local index = 0
    for i,activity in pairs(typeList)do
        index = index + 1
        --if string.match(activity.id,"lingqu") or string.match(activity.id,"xianshi") or string.match(activity.id,"wupinduihuan") or string.match(activity.id,"chongzhi") then
        if G_Me.activityData.isGmActivity(activity) then
            local data = activity.data
            if data then
                if BagLayer.roseId == data.act_id then
                    return index 
                end
            end
        end 
    end
    return 0
end

--接收背包信息
function BagLayer:_getBagItems(data)
    if data.ret == 1 then
        for i,v in ipairs(data.items) do
            self._bagItems[#self._bagItems+1] = v
        end
        --刷新列表   
    else
    end
end

--接收使用道具消息
--[[
    item_type = 1 为礼包，提示文字需要组装
]]
function BagLayer:_useBagItem(data)
    if data.ret == 1 then
        local item = item_info.get(data.id)
        if item ~= nil then
            if rawget(data,"awards") then
                -- 已有弹出界面
                if item.item_type == 1 and self._isMultiUse then
                    return
                end
                local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(data.awards)
                uf_notifyLayer:getModelNode():addChild(_layer)
            else
                -- 如果是征讨令则特殊处理一下，在BagUseItemMultiTimesLayer.lua中
                if item.id ~= 36 then
                    G_MovingTip:showMovingTip(item.tips)
                end
            end
        end
    end
end

--接收包裹变化消息
function BagLayer:_bagDataChange(_,data)
    --这里接收的肯定只有一个item变化了
    if data ~= nil and data.item ~= nil then
        local count = G_Me.bagData.propList:getCount()
        if count == 0 then
            self:showWidgetByName("Panel_listview",false)
            self:showWidgetByName("Panel_null",true)
        end
        if rawget(data.item, "update_items") ~= nil then
            self._listView:refreshAllCell()
        elseif rawget(data.item, "delete_items") ~= nil or rawget(data.item, "insert_items") ~= nil then
            self._listView:reloadWithLength(G_Me.bagData.propList:getCount(),self._listView:getShowStart());
        end
    end

end

function BagLayer:adapterLayer()
    -- self:adapterWidgetHeight("Panel_alllist", "Panel_checkbox", "", 0, 0)
    
end

function BagLayer:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end
function BagLayer:onLayerEnter()
    self:adapterWidgetHeight("Panel_listview","Panel_topbar","",40,0)
    self:adapterWidgetHeight("Panel_listview_juexing","Panel_topbar","",40,0)
    self:adapterWidgetHeight("Panel_null","Panel_topbar","",40,-54)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENGT_BAG_ITEMS, self._getBagItems, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_USE_ITEM, self._useBagItem, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, self._bagDataChange, self)
    --良品抽卡结果
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_DROP_GOOD_KNIGHT, self._getDropGoodKnightResult, self) 
    --极品抽卡结果
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_DROP_GODLY_KNIGHT, self._getDropGodlyKnightResult, self)
    self._tabs = require("app.common.tools.Tabs").new(2, self,self._checkedCallBack, self._uncheckedCallBack) 
    self._tabs:add("CheckBox_item", self._listView, "Label_item")
    self._tabs:add("CheckBox_juexing", self._juexingLayer, "Label_juexing")
    
    self:getCheckBoxByName("CheckBox_juexing"):setTouchEnabled(G_moduleUnlock:isModuleUnlock(FunctionLevelConst.AWAKEN))

    self:showWidgetByName("Button_Item_Compose", G_moduleUnlock:isModuleUnlock(FunctionLevelConst.ITEM_COMPOSE))
    
    self._tabs:checked(self._checkType == 1 and "CheckBox_item" or "CheckBox_juexing")
end

--良品抽卡结果,
function BagLayer:_getDropGoodKnightResult(data)
    --加上CD时间
    local isJiPin = false
    if data.ret == 1 then
        if #data.knight_base_id > 1 then
            self:_showDropTenKnights(20000, data.knight_base_id)
        else
            self:_showOneKnightDrop(1,data.knight_base_id[1])
        end
    end
end

--极品抽卡结果
function BagLayer:_getDropGodlyKnightResult(data)
    --加上CD时间
    if data.ret == 1 then
        if #data.knight_base_id > 1 then
            self:_showDropTenKnights(100000, data.knight_base_id)
        else
            self:_showOneKnightDrop(2,data.knight_base_id[1])
        end
    end
end


function BagLayer:_showOneKnightDrop(_type,knightId)
    local OneKnightDrop = require("app.scenes.shop.animation.OneKnightDrop")
        OneKnightDrop.show(_type, knightId, function(again, type)  
            if again then
                if type == 1 then   --良品
                    require("app.scenes.shop.ShopTools").sendGoodKnightDrop()
                else  --极品
                    require("app.scenes.shop.ShopTools").sendGodlyKnightDrop()
                end
            end

        end)
end

function BagLayer:_showDropTenKnights(buyMoneyNumm, knights)
    local ManyKnightDrop = require "app.scenes.shop.animation.ManyKnightDrop"
    ManyKnightDrop.show(buyMoneyNum, knights)
end

--[[
    self._juexingLayer = require("app.scenes.bag.BagJueXingLayer").create()
    self:getPanelByName("Panel_listview_juexing"):addNode(self._juexingLayer)
    self._tabs:updateTab("CheckBox_juexing", self._juexingLayer)
    local size = self:getPanelByName("Panel_listview_juexing"):getContentSize()
    self._juexingLayer:adapterWithSize(CCSizeMake(size.width, size.height))
    self._juexingLayer:updateView()
]]
function BagLayer:_initJueXingListView()
    if self._juexingLayer == nil then
        self._juexingLayer = require("app.scenes.bag.BagAwakenLayer").create()
        self:getPanelByName("Panel_listview_juexing"):addNode(self._juexingLayer)
        self._tabs:updateTab("CheckBox_juexing", self._juexingLayer)
        local size = self:getPanelByName("Panel_listview_juexing"):getContentSize()
        self._juexingLayer:adapterWithSize(CCSizeMake(size.width, size.height))
        self._juexingLayer:updateView()
    end
end


function BagLayer:_checkedCallBack(btnName)
    if btnName == "CheckBox_item" then
        self:_initListView()
        local count = G_Me.bagData.propList:getCount()
        if count == 0 then
            self:showWidgetByName("Panel_listview",false)
            self:showWidgetByName("Panel_null",true)
        else
            self:showWidgetByName("Panel_listview",true)
            self:showWidgetByName("Panel_null",false)
        end
        self:showWidgetByName("Button_tujian",false)
        self:showWidgetByName("Button_Item_Compose", G_moduleUnlock:isModuleUnlock(FunctionLevelConst.ITEM_COMPOSE))
        --self:showWidgetByName("Button_back",false)
    elseif btnName == "CheckBox_juexing" then
        self:_initJueXingListView()
        self:showWidgetByName("Panel_null",false)
        self:showWidgetByName("Button_tujian",true)
        self:showWidgetByName("Button_Item_Compose", false)
        --self:showWidgetByName("Button_back",true)
    end
end


return BagLayer
