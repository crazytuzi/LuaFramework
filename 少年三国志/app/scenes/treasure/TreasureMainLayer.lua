--±¦ÎïÁÐ±í

--local equipmentItem = require("app.scenes.equipment.cell.EquipmentListCell")

--local TreasureItem = require("app.scenes.treasureCulture.TreasureItem")
local TreasureMainLayer = class("TreasureMainLayer",UFCCSNormalLayer)
local EquipmentConst = require("app.const.EquipmentConst")

function TreasureMainLayer.create(scenePack, ...)
    return TreasureMainLayer.new("ui_layout/treasure_TreasureMainLayer.json", nil, scenePack, ...)
end

function TreasureMainLayer:ctor(json, arg2, scenePack, ...)
    
    self._equipment = nil
    self._listLayer = nil 
    self._listFragmentLayer = nil 
    self.super.ctor(self, ...)
    self._tabs = require("app.common.tools.Tabs").new(2, self,self._checkedCallBack, self._uncheckedCallBack) 
    
    G_GlobalFunc.savePack(self, scenePack)

    -- self:getLabelByName("Label_num"):createStroke(Colors.strokeBrown,1)
    self:registerBtnClickEvent("Button_return", function()
        local scenePack = G_GlobalFunc.createPackScene(self)
        if scenePack then
            uf_sceneManager:replaceScene(scenePack)
        else
            uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
        end

    end)
    self:registerBtnClickEvent("Button_sell", function()
         uf_sceneManager:replaceScene(require("app.scenes.bag.BagSellScene").new(G_Goods.TYPE_TREASURE))

    end)
    self:_createStroke()
end

function TreasureMainLayer:onLayerLoad(...)
    self:registerKeypadEvent(true)
end
function TreasureMainLayer:onBackKeyEvent()
    local scenePack = G_GlobalFunc.createPackScene(self)
    if scenePack then
        uf_sceneManager:replaceScene(scenePack)
    else
        uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
    end
    return true
end

function TreasureMainLayer:onLayerEnter()
    self:getImageViewByName("Image_Sell_Result"):loadTexture("ui/bag/icon_yinliang_sell.png", UI_TEX_TYPE_LOCAL)
    
    local tab = self._tabs:getCurrentTabName()
    self:_refreshNumLabel()
    -- if tab ~= "" then
    --     print("onLayerEnter " .. tab)
    --     if btnName == "CheckBox_list" then
    --         self._listLayer:onLayerEnter()
    --     elseif btnName == "CheckBox_list_fragment" then
            
    --     end
    -- end
end

function TreasureMainLayer:_initTabs()
    self._tabs:add("CheckBox_list", "","Label_3577") --delay load
    self._tabs:add("CheckBox_list_fragment", "")  -- delay load

    self._tabs:checked("CheckBox_list")
end


function TreasureMainLayer:_checkedCallBack(btnName)
    if btnName == "CheckBox_list" then
        local num = G_Me.bagData.treasureList:getCount()
        self:_refreshNumLabel()
        if num == 0 then
            self:_resetZeroLayer()
        else
            self:_resetListView()
        end
    end
end


function TreasureMainLayer:_createStroke()
    self:getLabelByName("Label_num"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_num_2"):createStroke(Colors.strokeBrown,1)
end

function TreasureMainLayer:_refreshNumLabel()
    local label = self:getLabelByName("Label_num")
    local label2 = self:getLabelByName("Label_num_2")
    -- ["LANG_BAG_ITEM_NUM"]
    local maxNum = G_Me.bagData:getMaxTreasureNum()
    local num = G_Me.bagData.treasureList:getCount()
    local text = string.format("%s/%s",num,maxNum)
    label:setText(G_lang:get("LANG_BAG_ITEM_NUM"))
    label2:setText(text)
    if num >= maxNum then
        label2:setColor(Colors.uiColors.RED)
    else
        label2:setColor(Colors.uiColors.WHITE)
    end
end


function TreasureMainLayer:_resetListView()
    if self._listLayer == nil then
        self._listLayer = require("app.scenes.treasure.main.TreasureListLayer").create()
        self:getPanelByName("Panel_content"):addNode(self._listLayer)
        self._tabs:updateTab("CheckBox_list", self._listLayer)
        local size = self:getPanelByName("Panel_content"):getContentSize()
        self._listLayer:adapterWithSize(CCSizeMake(size.width, size.height))
        self._listLayer:updateView()
    end 



end

function TreasureMainLayer:_resetZeroLayer()
    if self._zeroLayer == nil then
        -- self._zeroLayer = CCSNormalLayer:create("ui_layout/treasure_TreasureZeroLayer.json")
        -- self:getPanelByName("Panel_content"):addNode(self._zeroLayer)
        -- local size = self:getPanelByName("Panel_content"):getContentSize()
        -- self._zeroLayer:adapterWithSize(CCSizeMake(size.width, size.height))
        -- self._zeroLayer:registerWidgetTouchEvent("Label_duobao",function(widget,_type)
        --     if _type == TOUCH_EVENT_ENDED then
        --         local FunctionLevelConst = require("app.const.FunctionLevelConst")
        --         if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.TREASURE_COMPOSE) == true then
        --                 uf_sceneManager:replaceScene(require("app.scenes.treasure.TreasureComposeScene").new(_, _, _, _,
        --                     GlobalFunc.sceneToPack("app.scenes.treasure.TreasureMainScene")))
        --             return
        --         end
        --     end
        --     end)
        self._zeroLayer = require("app.scenes.common.EmptyLayer").createWithPanel(
            require("app.const.EmptyLayerConst").TREASURE,self:getPanelByName("Panel_content"))
        -- self._zeroLayer = require("app.scenes.common.EmptyLayer").create(require("app.const.EmptyLayerConst").TREASURE)
        -- local size = self:getPanelByName("Panel_content"):getContentSize()
        -- self._zeroLayer:adapterWithSize(CCSizeMake(size.width, size.height))
        -- self:getPanelByName("Panel_content"):addNode(self._zeroLayer)
    end 
end


function TreasureMainLayer:adapterLayer()

    self:adapterWidgetHeight("Panel_content", "Panel_checkbox", "", 14, 0)
    -- self:adapterWidgetHeight("Panel_bg", "Panel_checkbox", "", 0, 0)

    if self._tabs:getCurrentTabName() == "" then
       self:_initTabs() 
    end
    
end


function TreasureMainLayer:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
    self.super:onLayerExit()
end

return TreasureMainLayer
