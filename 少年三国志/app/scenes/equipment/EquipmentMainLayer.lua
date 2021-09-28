

--local equipmentItem = require("app.scenes.equipment.cell.EquipmentListCell")

--local TreasureItem = require("app.scenes.treasureCulture.TreasureItem")
local EquipmentMainLayer = class("EquipmentMainLayer",UFCCSNormalLayer)
local EquipmentConst = require("app.const.EquipmentConst")

EquipmentMainLayer.CHECK_EQUIPMENT = 1
EquipmentMainLayer.CHECK_FRAGMENT  = 2

-- 与 BagSellLayer 中对应
EquipmentMainLayer.SELL_FRAGMENT = 2

function EquipmentMainLayer.create(...)
    return require("app.scenes.equipment.EquipmentMainLayer").new("ui_layout/equipment_EquipmentMainLayer.json", ...)
end

--[[
    self._checkType 选中类型
    self._checkType = 1选中装备
    self._checkType = 2 选中碎片
]]
function EquipmentMainLayer:ctor(json,checkType,curEquipId,...)
    self._checkType = checkType and checkType or EquipmentMainLayer.CHECK_EQUIPMENT
    self._curEquipId = curEquipId and curEquipId or 0

    self._equipment = nil
    self._listLayer = nil 
    self._listFragmentLayer = nil 
    self.super.ctor(self, ...)
    -- self:getLabelByName("Label_num"):createStroke(Colors.strokeBrown,1)
    self._tabs = require("app.common.tools.Tabs").new(2, self,self._checkedCallBack, self._uncheckedCallBack) 
    self:registerBtnClickEvent("Button_return", function()
         uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
    end)
    self:registerBtnClickEvent("Button_sell", function()
        self:_sellBtnClicked()
    end)
    --检查是否有碎片可以合成
    self:_checkFragmentComposeable()
    self:_createStroke()
end

function EquipmentMainLayer:_sellBtnClicked(  )
    if self._checkType == EquipmentMainLayer.CHECK_EQUIPMENT then
        uf_sceneManager:replaceScene(require("app.scenes.bag.BagSellScene").new(G_Goods.TYPE_EQUIPMENT))
    elseif self._checkType == EquipmentMainLayer.CHECK_FRAGMENT then
        local BagConst = require("app.const.BagConst")
        local listData = G_Me.bagData:getFragmentListForSell(BagConst.FRAGMENT_TYPE_EQUIPMENT)
        if listData and #listData > 0 then
            uf_sceneManager:replaceScene(require("app.scenes.bag.BagSellScene").new(G_Goods.TYPE_FRAGMENT, EquipmentMainLayer.SELL_FRAGMENT))
        else
            G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_SELL_FRAGMENT_NUM_ZERO"))
        end
    else
        assert("known type")
    end
end

function EquipmentMainLayer:onLayerEnter()
    self:_refreshNumLabel()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, self._onBagChange, self)
end
function EquipmentMainLayer:onLayerLoad(...)
    self:registerKeypadEvent(true)
end
function EquipmentMainLayer:onBackKeyEvent()
    uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
    return true
end

function EquipmentMainLayer:_initTabs()
    self._tabs:add("CheckBox_list", "", "Label_zhuangbei1") --delay load
    self._tabs:add("CheckBox_list_fragment", "", "Label_suipian1")  -- delay load
    
    -- self:addCheckNodeWithStatus("CheckBox_list", "Label_zhuangbei1", true)
    -- self:addCheckNodeWithStatus("CheckBox_list", "Label_zhuangbei2", false)

    -- self:addCheckNodeWithStatus("CheckBox_list_fragment", "Label_suipian1", true)
    -- self:addCheckNodeWithStatus("CheckBox_list_fragment", "Label_suipian2", false)

    self._tabs:checked(self._checkType == EquipmentMainLayer.CHECK_EQUIPMENT and "CheckBox_list" or "CheckBox_list_fragment")
end




function EquipmentMainLayer:_checkedCallBack(btnName)
    if btnName == "CheckBox_list" then
        self._checkType = EquipmentMainLayer.CHECK_EQUIPMENT
        self:showWidgetByName("Panel_num",true)
        self:showWidgetByName("Button_sell",true)
        local equipmetNum = G_Me.bagData.equipmentList:getCount()
        if equipmetNum == 0 then
            self:_showEquipmentZeroLayer()
        else
            self:_resetListView()
        end
        self:getImageViewByName("Image_Sell_Result"):loadTexture("ui/bag/icon_yinliang_sell.png", UI_TEX_TYPE_LOCAL)
    elseif btnName == "CheckBox_list_fragment" then
        self._checkType = EquipmentMainLayer.CHECK_FRAGMENT
        local list = G_Me.bagData:getEquipmentFragmentList()
        self:showWidgetByName("Panel_num",false)
        self:showWidgetByName("Button_sell",true)
        if list == nil or #list == 0 then
            self:_showEquipmentFragmentZeroLayer()
        else
            self:_resetFragmentListView()
        end 
        self:getImageViewByName("Image_Sell_Result"):loadTexture("ui/bag/icon_weiming_sell.png", UI_TEX_TYPE_LOCAL)
    end
end

function EquipmentMainLayer:_showEquipmentZeroLayer()
    self:_resetEquipmentZeroLayer()

    if self._listLayer ~= nil then
        self._listLayer:setVisible(false)
    end
    if self._equipmentFragmentZeroLayer ~= nil then
        self._equipmentFragmentZeroLayer:setVisible(false)
    end
    if self._equipmentZeroLayer ~= nil then
        self._equipmentZeroLayer:setVisible(true)
    end
    if self._listFragmentLayer ~= nil then
        self._listFragmentLayer:setVisible(false)
    end
end

function EquipmentMainLayer:_showEquipmentFragmentZeroLayer()
    self:_resetEquipmentFragmentZeroLayer()

    if self._listLayer ~= nil then
        self._listLayer:setVisible(false)
    end
    if self._equipmentFragmentZeroLayer ~= nil then
        self._equipmentFragmentZeroLayer:setVisible(true)
    end
    if self._equipmentZeroLayer ~= nil then
        self._equipmentZeroLayer:setVisible(false)
    end
    if self._listFragmentLayer ~= nil then
        self._listFragmentLayer:setVisible(false)
    end
end


function EquipmentMainLayer:_createStroke()
    self:getLabelByName("Label_num"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_num_2"):createStroke(Colors.strokeBrown,1)
end

function EquipmentMainLayer:_refreshNumLabel()
    local label = self:getLabelByName("Label_num")
    local label2 = self:getLabelByName("Label_num_2")
    -- ["LANG_BAG_ITEM_NUM"]
    local maxNum = G_Me.bagData:getMaxEquipmentNumByLevel(G_Me.userData.level)
    local num = G_Me.bagData.equipmentList:getCount()
    local text = string.format("%s/%s",num,maxNum)
    label:setText(G_lang:get("LANG_BAG_ITEM_NUM"))
    label2:setText(text)
    if num >= maxNum then
        label2:setColor(Colors.uiColors.RED)
    else
        label2:setColor(Colors.uiColors.WHITE)
    end
end


function EquipmentMainLayer:_onBagChange(_type)
    __LogTag("wkj","-----------------------_onBagChange type = %s",_type)
    local BagConst = require("app.const.BagConst")
    if _type == BagConst.CHANGE_TYPE.EQUIPMENT then
        self:_refreshNumLabel()
        if self._listLayer ~= nil then
            self._listLayer:updateView()
        end 
    elseif _type == BagConst.CHANGE_TYPE.FRAGMENT then
        self:_checkFragmentComposeable()
    end 


    --[[
        检查是否为空了
    ]]
    if self._tabs:getCurrentTabName() == "CheckBox_list_fragment" then
        local list = G_Me.bagData:getEquipmentFragmentList()
        if list == nil or #list == 0 then
            self:_showEquipmentFragmentZeroLayer()
        end
    elseif self._tabs:getCurrentTabName() == "CheckBox_list" then
        local equipmetNum = G_Me.bagData.equipmentList:getCount()
        if equipmetNum == 0 then
            self:_showEquipmentZeroLayer()
        end
    end

end
function EquipmentMainLayer:_resetListView()
    if self._equipmentFragmentZeroLayer ~= nil then
        self._equipmentFragmentZeroLayer:setVisible(false)
    end
    if self._equipmentZeroLayer ~= nil then
        self._equipmentZeroLayer:setVisible(false)
    end
    if self._listLayer == nil then
        self._listLayer = require("app.scenes.equipment.main.EquipmentListLayer").create()
        self:getPanelByName("Panel_content"):addNode(self._listLayer)
        self._tabs:updateTab("CheckBox_list", self._listLayer)
        local size = self:getPanelByName("Panel_content"):getContentSize()
        self._listLayer:adapterWithSize(CCSizeMake(size.width, size.height))
        self._listLayer:updateView()
    end 
end


function EquipmentMainLayer:_resetFragmentListView()
    if self._equipmentFragmentZeroLayer ~= nil then
        self._equipmentFragmentZeroLayer:setVisible(false)
    end
    if self._equipmentZeroLayer ~= nil then
        self._equipmentZeroLayer:setVisible(false)
    end
    if self._listFragmentLayer == nil then

        self._listFragmentLayer = require("app.scenes.equipment.main.EquipmentListFragmentLayer").create()
        self:getPanelByName("Panel_content"):addNode(self._listFragmentLayer)
        self._tabs:updateTab("CheckBox_list_fragment", self._listFragmentLayer)
        local size = self:getPanelByName("Panel_content"):getContentSize()
        self._listFragmentLayer:adapterWithSize(CCSizeMake(size.width, size.height))
        self._listFragmentLayer:updateView(self._curEquipId)
    end 
end

function EquipmentMainLayer:_resetEquipmentZeroLayer()
    if self._equipmentZeroLayer == nil then
        -- self._equipmentZeroLayer = CCSNormalLayer:create("ui_layout/equipment_EquipmentZeroLayer.json")
        -- self._equipmentZeroLayer:registerWidgetTouchEvent("Label_chuangguan02",function(widget,_type) 
        --     if  _type == TOUCH_EVENT_ENDED then
        --         local FunctionLevelConst = require "app.const.FunctionLevelConst"
        --         if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.TOWER_SCENE) == true then
        --                 local s = require("app.scenes.wush.WushScene").new(_, _, _, _,
        --                     GlobalFunc.sceneToPack("app.scenes.equipment.EquipmentMainScene", {1}))
        --                 s:setDisplayEffect(false)
        --                 -- self._speedBar:setSelectBtn()
        --                 uf_sceneManager:replaceScene(s)
        --                 return
        --             end
        --     end
        --     end)
        -- self._equipmentZeroLayer:registerWidgetTouchEvent("Label_zhandou02",function(widget,_type) 
        --     if  _type == TOUCH_EVENT_ENDED then
        --         uf_sceneManager:replaceScene(require("app.scenes.dungeon.DungeonMainScene").new())
        --     end
        --     end)

        -- self:getPanelByName("Panel_content"):addNode(self._equipmentZeroLayer)
        -- local size = self:getPanelByName("Panel_content"):getContentSize()
        -- self._equipmentZeroLayer:adapterWithSize(CCSizeMake(size.width, size.height))
        -- self._equipmentZeroLayer:registerWidgetTouchEvent("Label_zhandou",function(width,_typeValue)
        --     if  _type == TOUCH_EVENT_ENDED then
        --         uf_sceneManager:replaceScene(require("app.scenes.shop.ShopScene").new())
        --     end
        --     end)
        -- self._equipmentZeroLayer:registerWidgetTouchEvent("Label_chuangguan",function(width,_typeValue)
        --     if  _type == TOUCH_EVENT_ENDED then
        --         uf_sceneManager:replaceScene(require("app.scenes.shop.ShopScene").new())
        --     end
        --     end)
        self._equipmentZeroLayer = require("app.scenes.common.EmptyLayer").createWithPanel(
            require("app.const.EmptyLayerConst").EQUIPMENT,self:getPanelByName("Panel_content"))
    end 
end

function EquipmentMainLayer:_resetEquipmentFragmentZeroLayer()
    if self._equipmentFragmentZeroLayer == nil then
        -- self._equipmentFragmentZeroLayer = CCSNormalLayer:create("ui_layout/equipment_EquipmentFragmentZeroLayer.json")
        -- self._equipmentFragmentZeroLayer:registerWidgetTouchEvent("Label_chuangguan",function(widget,_type) 
        --     if  _type == TOUCH_EVENT_ENDED then
        --         local FunctionLevelConst = require "app.const.FunctionLevelConst"
        --         if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.TOWER_SCENE) == true then
        --                 local s = require("app.scenes.wush.WushScene").new(_, _, _, _,
        --                     GlobalFunc.sceneToPack("app.scenes.equipment.EquipmentMainScene", {2}))
        --                 s:setDisplayEffect(false)
        --                 -- self._speedBar:setSelectBtn()
        --                 uf_sceneManager:replaceScene(s)
        --                 return
        --             end
        --     end
        --     end)
        -- self:getPanelByName("Panel_content"):addNode(self._equipmentFragmentZeroLayer)
        -- local size = self:getPanelByName("Panel_content"):getContentSize()
        -- self._equipmentFragmentZeroLayer:adapterWithSize(CCSizeMake(size.width, size.height))
        self._equipmentFragmentZeroLayer = require("app.scenes.common.EmptyLayer").createWithPanel(
            require("app.const.EmptyLayerConst").EQUIPMENTSP,self:getPanelByName("Panel_content"))
    end 
end

--检查是否有碎片可合成
function EquipmentMainLayer:_checkFragmentComposeable()
    self:showWidgetByName("Image_composeTips", G_Me.bagData:CheckEquipmentFragmentCompose())
end


function EquipmentMainLayer:adapterLayer()

    self:adapterWidgetHeight("Panel_content", "Panel_checkbox", "", 14, 0)
    -- self:adapterWidgetHeight("Panel_bg", "Panel_checkbox", "", 0, 0)

    if self._tabs:getCurrentTabName() == "" then
       self:_initTabs() 
    end
    
end


function EquipmentMainLayer:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
    self.super:onLayerExit()
end


return EquipmentMainLayer
