local BagSellLayer = class("BagSellLayer",UFCCSNormalLayer)
local KnightSellItem = require("app.scenes.bag.BagKnightSellItem")
local EquipmentSellItem = require("app.scenes.bag.BagEquipmentSellItem")
local TreasureSellItem = require("app.scenes.bag.BagTreasureSellItem")
local EquipmentFragmentSellItem = require("app.scenes.bag.BagEquipmentFragmentSellItem")

local Award = require("app.const.AwardConst")
require("app.const.AwardConst")
function BagSellLayer.create(sellType, sellFragmentType, scenePack, ...)
    return BagSellLayer.new("ui_layout/bag_BagSellLayer.json", sellType, sellFragmentType, scenePack)
end
require("app.cfg.knight_advance_info")
require("app.cfg.knight_info")
require("app.cfg.equipment_info")
require("app.cfg.treasure_info")

--[[
    sellType = G_Goods.TYPE_KNIGHT              武将
    sellType = G_Goods.TYPE_EQUIPMENT           装备
    sellType = G_Goods.TYPE_TREASURE            宝物
    sellType = G_Goods.TYPE_FRAGMENT            装备/武将碎片    
]]

BagSellLayer.KNIGHT_FRAGMENT = 1
BagSellLayer.EQUIPMENT_FRAGMENT = 2

-- 返回到武将/装备列表
BagSellLayer.RETURN_TO_EQUIP_KNIGHT_LIST = 1
-- 从出售界面返回到碎片列表
BagSellLayer.RETURN_TO_FRAG_LIST = 2
-- 物品品质
BagSellLayer.GOODS_QUALITY_WHITE  = 1
BagSellLayer.GOODS_QUALITY_GREEN  = 2
BagSellLayer.GOODS_QUALITY_BLUE   = 3
BagSellLayer.GOODS_QUALITY_PURPLE = 4
BagSellLayer.GOODS_QUALITY_ORANGE = 5


function BagSellLayer:ctor(json, sellType, sellFragmentType, scenePack, ...)
    --出售类型
    self._listData = {}

    --代售列表
    self._forSellListData = {}
    self._sellType = sellType
    self._sellFragmentType = sellFragmentType
    G_GlobalFunc.savePack(self, scenePack)
    self._sellResultTypeString = ""

    self.super.ctor(self,json,...)
    self:_initListData()
    self:_initWidgets()
    --第一进来,刷新底部按钮
    self:_refreshBottomLabels()
    self:_initEvent()
    self:_createStroke()
end


function BagSellLayer:_initEvent()
    self:registerBtnClickEvent("Button_back",function()
         self:onBackKeyEvent()
    end)
    
    self:registerBtnClickEvent("Button_sell",function()
        self:_sellEvent()
    end)

    self:registerBtnClickEvent("Button_selectByQuality",function()
        -- test protocal
        -- local fragmentIdList = {}
        -- table.insert(fragmentIdList, 50002)
        -- dump(fragmentIdList)
        -- G_HandlersManager.bagHandler:sendSellFragmentMsg(fragmentIdList)

        self:_pinjiSell()
    end)
end

function BagSellLayer:_createStroke()
    self:getLabelByName("Label_selectedCountTag"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_selectedCount"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_sellTag"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_money"):createStroke(Colors.strokeBrown,1)
end


--加载数据
function BagSellLayer:_initListData()
    if self._sellType == G_Goods.TYPE_KNIGHT then
        self._listData = G_Me.bagData:getKnightSellList()
    elseif self._sellType == G_Goods.TYPE_EQUIPMENT then
        self._listData = G_Me.bagData:getEquipmentSellList()
    elseif self._sellType == G_Goods.TYPE_TREASURE then
        self._listData = G_Me.bagData:getTreasureSellList()
    elseif self._sellType == G_Goods.TYPE_FRAGMENT then 
        if self._sellFragmentType and type(self._sellFragmentType) == "number" then
            local BagConst = require("app.const.BagConst")
            if self._sellFragmentType == BagSellLayer.KNIGHT_FRAGMENT then
                -- 武将碎片
                self._listData = G_Me.bagData:getFragmentListForSell(BagConst.FRAGMENT_TYPE_KNIGHT)
            elseif self._sellFragmentType == BagSellLayer.EQUIPMENT_FRAGMENT then
                -- 装备碎片
                self._listData = G_Me.bagData:getFragmentListForSell(BagConst.FRAGMENT_TYPE_EQUIPMENT)
            end
        end
    end
end

function BagSellLayer:_initWidgets()
    local titleImg = self:getImageViewByName("Image_title")
    if self._sellType == G_Goods.TYPE_KNIGHT then
        titleImg:loadTexture(G_Path.getTabTxt("xuanzewujiang.png"),UI_TEX_TYPE_LOCAL)
    elseif self._sellType == G_Goods.TYPE_EQUIPMENT then
        titleImg:loadTexture(G_Path.getTabTxt("xuanzezhuangbei.png"),UI_TEX_TYPE_LOCAL)
    elseif self._sellType == G_Goods.TYPE_TREASURE then
        titleImg:loadTexture(G_Path.getTabTxt("xuanzebaowu.png"),UI_TEX_TYPE_LOCAL)
    elseif self._sellType == G_Goods.TYPE_FRAGMENT then
        titleImg:loadTexture(G_Path.getTabTxt("xuanzesuipian.png"),UI_TEX_TYPE_LOCAL)
    end
    --[[
        无出售的物品
    ]]
    if self._listData == nil or #self._listData == 0 then
        if self._sellType == G_Goods.TYPE_KNIGHT then
            G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_SELL_KNIGHT_NUM_ZERO"))
        elseif self._sellType == G_Goods.TYPE_EQUIPMENT then
            G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_SELL_EQUIPMENT_NUM_ZERO"))
        elseif self._sellType == G_Goods.TYPE_TREASURE then
            G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_SELL_TREASURE_NUM_ZERO"))
        elseif self._sellType == G_Goods.TYPE_FRAGMENT then
            G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_SELL_FRAGMENT_NUM_ZERO"))
        end
        return
    end
end

function BagSellLayer:adapterLayer()
    self:adapterWidgetHeight("Panel_listview","Panel_topbar","Panel_bottom",0,0)
    self:_initListView()
end

--出售结果
function BagSellLayer:_revBagSellResult(data)
    if data.ret == 1 then
        self._forSellListData = {}
        G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_SELL_SUCCESS",{num=self._totalMoney, result_type=self._sellResultTypeString}))
        self:_initListData()
        self:_refreshBottomLabels()
        self._listview:reloadWithLength(#self._listData,self._listview:getShowStart())
    end
end

function BagSellLayer:_initListView()
    --knight
    if self._listview == nil then
        local panel = self:getPanelByName("Panel_listview")
        self._listview = CCSListViewEx:createWithPanel(panel,LISTVIEW_DIR_VERTICAL)
        self._listview:setCreateCellHandler(function ()
                if self._sellType == G_Goods.TYPE_KNIGHT then
                    return KnightSellItem.new()
                elseif self._sellType == G_Goods.TYPE_EQUIPMENT then
                    return EquipmentSellItem.new()
                elseif self._sellType == G_Goods.TYPE_TREASURE then
                    return TreasureSellItem.new()
                elseif self._sellType == G_Goods.TYPE_FRAGMENT then
                    return EquipmentFragmentSellItem.new()
                end
            end)
        self._listview:setUpdateCellHandler(function ( list, index, cell)
            local data = self._listData[index+1]
            cell:updateCell(data) 
            cell:setCheckBoxEvent(function(isChecked)
                --刷新底部按钮
                data["checked"] = isChecked
                if isChecked == true then
                    self._forSellListData[data.id] = data
                else
                    self._forSellListData[data.id] = nil
                end
                self:_refreshBottomLabels()
            end)
            cell:setCheckInfoFunc(function()
                if data == nil then
                    return
                end
                if self._sellType == G_Goods.TYPE_FRAGMENT then
                    GlobalFunc.showBaseInfo(G_Goods.TYPE_FRAGMENT, data.id) 
                else               
                    require("app.scenes.common.dropinfo.DropInfo").show(self._sellType, data.base_id)
                end
                end)
        end)
        self._listview:setClickCellHandler(function (  list, index, cell )
            local data = self._listData[index+1]
            local propInfo = nil
            local potential = 0
            if self._sellType == G_Goods.TYPE_KNIGHT then
                propInfo = knight_info.get(data["base_id"])
                if propInfo then
                    potential = propInfo.potential
                end
            elseif self._sellType == G_Goods.TYPE_EQUIPMENT then
                propInfo = equipment_info.get(data["base_id"])
                if propInfo then
                    potential = propInfo.potentiality
                end
            end
            -- 宝物暂时不需要这个限制
            if potential >= 20 then
                G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_SELL_QUALITY_ABOVE_5_CANNOT_SELL"))
                return
            end

            cell:setSelectedHandler()
        end)
        self._listview:setSpaceBorder(0,20)
    end
    self._listview:reloadWithLength(#self._listData,self._listview:getShowStart())
end

--刷新底部文字
function BagSellLayer:_refreshBottomLabels()
    local selectedLabel = self:getLabelByName("Label_selectedCount")
    local totalMoneyLabel = self:getLabelByName("Label_money")
    local sellResultIcon = self:getImageViewByName("Image_Sell_Result_Icon")
    if not self._forSellListData then
        self._totalMoney = 0
        totalMoneyLabel:setText(0)
        -- selectedLabel:setText(G_lang:get("LANG_BAG_SELL_SELECTED_COUNT",{count=0}))
        selectedLabel:setText(0)
        return
    end

    local selectCount = 0
    self._totalMoney = 0
    for i,v in pairs(self._forSellListData) do
        if self._sellType == G_Goods.TYPE_FRAGMENT then
            -- 碎片出售为同一种碎片一起出售
            selectCount = selectCount + v.num
            self._totalMoney = self._totalMoney + v["money"] * v.num
        else
            selectCount = selectCount + 1
            self._totalMoney = self._totalMoney + v["money"]
        end
    end

    totalMoneyLabel:setText(self._totalMoney)
    selectedLabel:setText(G_lang:get("LANG_BAG_SELL_SELECTED_COUNT",{count=selectCount}))
    selectedLabel:setText(selectCount)

    if self._sellType == G_Goods.TYPE_FRAGMENT then
        if self._sellFragmentType == BagSellLayer.KNIGHT_FRAGMENT then
            sellResultIcon:loadTexture("icon_mini_hunyu.png", UI_TEX_TYPE_PLIST)
        elseif self._sellFragmentType == BagSellLayer.EQUIPMENT_FRAGMENT then
            sellResultIcon:loadTexture("icon_mini_patajifen.png", UI_TEX_TYPE_PLIST)
        end
    end
end

function BagSellLayer:_sellEvent()
    if self._listData == nil or #self._listData == 0 then
        if self._sellType == G_Goods.TYPE_KNIGHT then
            G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_SELL_KNIGHT_NUM_ZERO"))
        elseif self._sellType == G_Goods.TYPE_EQUIPMENT then
            G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_SELL_EQUIPMENT_NUM_ZERO"))
        elseif self._sellType == G_Goods.TYPE_TREASURE then
            G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_SELL_TREASURE_NUM_ZERO"))
        elseif self._sellType == G_Goods.TYPE_FRAGMENT then
            G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_SELL_FRAGMENT_NUM_ZERO"))
        end
        return
    end

    -- 出售的类型名
    local sellTypeString = ""
    -- 出售返还物品类型
    if self._sellType == G_Goods.TYPE_KNIGHT then
        sellTypeString = G_lang:get("LANG_KNIGHT")
        self._sellResultTypeString = G_lang:get("LANG_SILVER")
    elseif self._sellType == G_Goods.TYPE_EQUIPMENT then
        sellTypeString = G_lang:get("LANG_EQUIPMENT")
        self._sellResultTypeString = G_lang:get("LANG_SILVER")
    elseif self._sellType == G_Goods.TYPE_TREASURE then
        sellTypeString = G_lang:get("LANG_TREASURE")
        self._sellResultTypeString = G_lang:get("LANG_SILVER")
    elseif self._sellType == G_Goods.TYPE_FRAGMENT then
        sellTypeString = G_lang:get("LANG_FRAGMENT")
        if self._sellFragmentType == BagSellLayer.KNIGHT_FRAGMENT then
            self._sellResultTypeString = G_lang:get("LANG_GOODS_JIANG_HUN")
        elseif self._sellFragmentType == BagSellLayer.EQUIPMENT_FRAGMENT then
            self._sellResultTypeString = G_lang:get("LANG_GOODS_ZHAN_GONG")
        end
    end
    local callbck = function()
        local selectCount = 0
        local finalSell = {}
        local fragmentIdList = {}
        for i,v in pairs(self._forSellListData) do
            -- 如果出售碎片
            if self._sellType == G_Goods.TYPE_FRAGMENT then
                selectCount = selectCount + v.num
                fragmentIdList[#fragmentIdList + 1] = v.id
            else
                selectCount = selectCount + 1
                finalSell[#finalSell+1] = {mode=self._sellType,value=v.id,size=1}
            end
        end

        if selectCount == 0 then
            G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_SELL_SELECTED_NULL"))
            return
        end
        local str = G_lang:get("LANG_BAG_SELL_TIPS",{num=selectCount,type=sellTypeString,money=self._totalMoney,result_type=self._sellResultTypeString})
        MessageBoxEx.showYesNoMessage(nil,str,false,function()
            if self._sellType == G_Goods.TYPE_FRAGMENT then
                G_HandlersManager.bagHandler:sendSellFragmentMsg(fragmentIdList)
            else
                G_HandlersManager.bagHandler:sendSellMsg(finalSell)
            end
        end,nil)
    end
    --先判断是否含有紫将和突破
    if self._sellType == G_Goods.TYPE_KNIGHT then
        local hasZiJiang,hasJinJie = self:checkZiJiangAndJinJie()
        local jinjieFunc = function() 
            if hasJinJie == true then
                MessageBoxEx.showSellTip(nil,G_lang:get("LANG_BAG_KNIGHT_SELL_TIPS_02"),
                    function ( ... )
                        callbck()
                    end,
                    function()
                        uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.recycle.RecycleScene").new(nil, nil, 
                        1, 0, GlobalFunc.sceneToPack("app.scenes.bag.BagSellScene", {G_Goods.TYPE_KNIGHT})))
                    end,nil)
            else
                callbck()
            end
        end
        if hasZiJiang == true then
            -- MessageBoxEx.showYesNoMessage( title, content, sysMsg, yes_handler, no_handler, target )
            MessageBoxEx.showSellTip(nil,G_lang:get("LANG_BAG_KNIGHT_SELL_TIPS_01"),
                function ( ... )
                    jinjieFunc()
                end,
                function()
                    uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.recycle.RecycleScene").new(nil, nil, 
                        1, 0, GlobalFunc.sceneToPack("app.scenes.bag.BagSellScene", {G_Goods.TYPE_KNIGHT})))
                end,nil)
        else
            jinjieFunc()
        end
    elseif self._sellType == G_Goods.TYPE_EQUIPMENT then
        MessageBoxEx.showSellTip(nil,G_lang:get("LANG_BAG_EQUIPMENT_SELL_TIPS_01"),
            function ( ... )
                callbck()
            end,
            function()
                uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.recycle.RecycleScene").new(nil, nil, 
                        2, 0, GlobalFunc.sceneToPack("app.scenes.bag.BagSellScene", {G_Goods.TYPE_EQUIPMENT})))
            end,nil)
    elseif self._sellType == G_Goods.TYPE_FRAGMENT then
        -- 判断是否有橙色及以上碎片
        local hasOrangeFragment = self:_checkHasOrangeFragment()
        if hasOrangeFragment then
            MessageBoxEx.showSellTip(nil,G_lang:get("LANG_BAG_FRAGMENT_SELL_TIPS"),
                    function ( ... )
                        callbck()
                    end,
                    nil,
                    nil)
        else
            callbck()
        end
    else
        callbck()
    end
    
end

function BagSellLayer:checkZiJiangAndJinJie()
    local hasZiJiang = false
    local hasJinJie = false
    for i,v in pairs(self._forSellListData) do
        local knight = knight_info.get(v.base_id)
        if knight ~= nil then
            if knight.quality >= 4 then
                hasZiJiang = true
            end
            if knight.advanced_level > 0 then
                hasJinJie = true
            end
        end
    end
    return hasZiJiang,hasJinJie
end

-- 判断待售列表中是否有紫色及以上品级的碎片
function BagSellLayer:_checkHasOrangeFragment(  )
    require("app.cfg.fragment_info")
    local hasOrangeFragment = false

    for i, v in pairs(self._forSellListData) do
        local fragmentInfo = fragment_info.get(v.id)
        if fragmentInfo.quality >= 5 then
            hasOrangeFragment = true
        end
    end

    return hasOrangeFragment
end

function BagSellLayer:_pinjiSell()
    --物品类型  武将,装备,宝物
    local __type = ""
    if self._sellType == G_Goods.TYPE_KNIGHT then
        __type = G_lang:get("LANG_KNIGHT")
    elseif self._sellType == G_Goods.TYPE_EQUIPMENT then
       __type = G_lang:get("LANG_EQUIPMENT")
    elseif self._sellType == G_Goods.TYPE_TREASURE then
        __type = G_lang:get("LANG_TREASURE")
    elseif self._sellType == G_Goods.TYPE_FRAGMENT then
        __type = G_lang:get("LANG_FRAGMENT")
    end
    --先判断是否有道具
    if self._listData == nil or #self._listData == 0 then
        if self._sellType == G_Goods.TYPE_KNIGHT then
            G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_SELL_KNIGHT_NUM_ZERO"))
        elseif self._sellType == G_Goods.TYPE_EQUIPMENT then
            G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_SELL_EQUIPMENT_NUM_ZERO"))
        elseif self._sellType == G_Goods.TYPE_TREASURE then
            G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_SELL_TREASURE_NUM_ZERO"))
        elseif self._sellType == G_Goods.TYPE_FRAGMENT then 
            G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_SELL_FRAGMENT_NUM_ZERO"))
        end
        return
    end

    --先判断是否有低品质的道具,因为是排好序的,品质最低的排在第一位
    if self._sellType == G_Goods.TYPE_FRAGMENT then
        if self:_getBaseInfo(self._listData[1]).quality > BagSellLayer.GOODS_QUALITY_PURPLE then
            -- 碎片紫色可以批量选
            G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_SELL_NO_LOWER_QUALITY_FRAGMENT",{name=__type}))
            return
        end        
    else
        if self:_getBaseInfo(self._listData[1]).quality > BagSellLayer.GOODS_QUALITY_BLUE then
            G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_SELL_NO_LOWER_QUALITY",{name=__type}))
            return
        end 
    end

    local baiFunc = function(isChecked)
        if not self:isExistByQuality(BagSellLayer.GOODS_QUALITY_WHITE) then
            G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_SELL_NO_THIS_QUALITY",{name=__type}))
            return false
        end
        if isChecked == true then
            return self:_addToSellQueueByQuality(BagSellLayer.GOODS_QUALITY_WHITE)
        else
            return self:_removeFromQueueByQuality(BagSellLayer.GOODS_QUALITY_WHITE)
        end
    end
    local lvFunc = function(isChecked)
        if not self:isExistByQuality(BagSellLayer.GOODS_QUALITY_GREEN) then
            G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_SELL_NO_THIS_QUALITY",{name=__type}))
            return false
        end
        if isChecked == true then
            return self:_addToSellQueueByQuality(BagSellLayer.GOODS_QUALITY_GREEN)
        else
            return self:_removeFromQueueByQuality(BagSellLayer.GOODS_QUALITY_GREEN)
        end
    end
    local lanFunc = function(isChecked)
        if not self:isExistByQuality(BagSellLayer.GOODS_QUALITY_BLUE) then
            G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_SELL_NO_THIS_QUALITY",{name=__type}))
            return false
        end
        if isChecked == true then
            return self:_addToSellQueueByQuality(BagSellLayer.GOODS_QUALITY_BLUE)
        else
            return self:_removeFromQueueByQuality(BagSellLayer.GOODS_QUALITY_BLUE)
        end
    end
    local ziFunc = function(isChecked)
        if not self:isExistByQuality(BagSellLayer.GOODS_QUALITY_PURPLE) then
            G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_SELL_NO_THIS_QUALITY",{name=__type}))
            return false
        end
        if isChecked == true then
            return self:_addToSellQueueByQuality(BagSellLayer.GOODS_QUALITY_PURPLE)
        else
            return self:_removeFromQueueByQuality(BagSellLayer.GOODS_QUALITY_PURPLE)
        end
    end
    local layer = require("app.scenes.bag.BagYiJianLayer").create(baiFunc,lvFunc,lanFunc,ziFunc,self._sellType)
    uf_sceneManager:getCurScene():addChild(layer)
end

function BagSellLayer:_addToSellQueueByQuality(quality)
    if self._listData == nil or #self._listData == 0 then
        return false
    end
    for i,v in ipairs(self._listData) do
        if self:_getBaseInfo(v).quality == quality then
            if self._forSellListData[v.id] == nil then
                self._forSellListData[v.id] = v
                v["checked"] = true
            end
        end
    end
    self._listview:refreshAllCell()
    self:_refreshBottomLabels()
    return true
end

function BagSellLayer:_removeFromQueueByQuality(quality)
    if self._forSellListData == nil then
        return false
    end
    for i,v in pairs(self._forSellListData) do
        if self:_getBaseInfo(v).quality == quality then
            v["checked"] = false
            self._forSellListData[v.id] = nil
        end
    end
    self._listview:refreshAllCell()
    self:_refreshBottomLabels()
    return false
end

function BagSellLayer:isExistByQuality(quality)
    for i,v in ipairs(self._listData) do
        if self:_getBaseInfo(v).quality == quality then
            return true
        end
    end
    return false
end

function BagSellLayer:onLayerEnter( ... )
    self:registerKeypadEvent(true)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, self._revBagChanged, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_SELL_RESULT, self._revBagSellResult, self) 
end
function BagSellLayer:onBackKeyEvent()

    if self._sellType == G_Goods.TYPE_KNIGHT then
        local scenePack = G_GlobalFunc.createPackScene(self)
        if scenePack then
            uf_sceneManager:replaceScene(scenePack)
        else
            uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroFosterScene").new(BagSellLayer.RETURN_TO_EQUIP_KNIGHT_LIST))
        end
    elseif self._sellType == G_Goods.TYPE_EQUIPMENT then
        local scenePack = G_GlobalFunc.createPackScene(self)
        if scenePack then
            uf_sceneManager:replaceScene(scenePack)
        else
            uf_sceneManager:replaceScene(require("app.scenes.equipment.EquipmentMainScene").new(BagSellLayer.RETURN_TO_EQUIP_KNIGHT_LIST))
        end
    elseif self._sellType == G_Goods.TYPE_TREASURE then
        local scenePack = G_GlobalFunc.createPackScene(self)
        if scenePack then
            uf_sceneManager:replaceScene(scenePack)
        else
            uf_sceneManager:replaceScene(require("app.scenes.treasure.TreasureMainScene").new())
        end
    elseif self._sellType == G_Goods.TYPE_FRAGMENT then
        if self._sellFragmentType == BagSellLayer.KNIGHT_FRAGMENT then
            -- 武将碎片
            uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroFosterScene").new(BagSellLayer.RETURN_TO_FRAG_LIST))
        elseif self._sellFragmentType == BagSellLayer.EQUIPMENT_FRAGMENT then
            -- 装备碎片
            uf_sceneManager:replaceScene(require("app.scenes.equipment.EquipmentMainScene").new(BagSellLayer.RETURN_TO_FRAG_LIST))
        end
    end
    return true
end
function BagSellLayer:onLayerExit( ... )
    uf_eventManager:removeListenerWithTarget(self)
end

--背包数据发生变化,如 商品出售了
function BagSellLayer:_revBagChanged()
end

function BagSellLayer:_getBaseInfo(data)
    if self._sellType == G_Goods.TYPE_FRAGMENT then
        require("app.cfg.fragment_info")
        local fragmentInfo = fragment_info.get(data.id)
        return fragmentInfo
    elseif self._sellType == G_Goods.TYPE_KNIGHT then
        local knight = knight_info.get(data.base_id)
        return knight
    else
        return data:getInfo()
    end
end

return BagSellLayer

