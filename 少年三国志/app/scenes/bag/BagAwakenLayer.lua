-- BagAwakenLayer

local function _updateLabel(target, name, params)
    
    local label = target:getLabelByName(name)
    if params.stroke ~= nil then
        label:createStroke(params.stroke, 1)
    end
    
    if params.color ~= nil then
        label:setColor(params.color)
    end
    
    if params.text ~= nil then
        label:setText(params.text)
    end
    
    if params.visible ~= nil then
        label:setVisible(params.visible)
    end
end

local function _updateImageView(target, name, params)
    
    local img = target:getImageViewByName(name)
    if params.texture ~= nil then
        img:loadTexture(params.texture, params.texType or UI_TEX_TYPE_LOCAL)
    end
    
    if params.visible ~= nil then
        img:setVisible(params.visible)
    end
    
end

require "app.cfg.item_awaken_info"

local MAX_BAG_AWAKEN_ITEM_NUM = 999

local HeroAwakenItemDetailLayer = require "app.scenes.herofoster.HeroAwakenItemDetailLayer"

local BagAwakenLayer = class("BagAwakenLayer", UFCCSNormalLayer)

function BagAwakenLayer.create(...)
    return BagAwakenLayer.new("ui_layout/bag_BagAwakenLayer.json", ...)
end

function BagAwakenLayer:ctor(...)
    
    BagAwakenLayer.super.ctor(self, ...)
    
--    local items = {
--        {id=1, num=0},
--        {id=2, num=100},
--        {id=3, num=2000},
--        {id=4, num=100},
--        {id=5, num=100},
--    }
    
    self._awakenItemData = {container = {}}
    
    self._awakenItemData.at = function(index)
        return self._awakenItemData.container[index]
    end
    
    self._awakenItemData.count = function()
        return #self._awakenItemData.container
    end
    
    self._awakenItemData.add = function(data)
        self._awakenItemData.container[#self._awakenItemData.container+1] = data
    end
    
    self._awakenItemData.mod = function(data)
        for i=1, #self._awakenItemData.container do
            if self._awakenItemData.container[i].id == data.id then
                self._awakenItemData.container[i] = data
                break
            end
        end
    end
    
    self._awakenItemData.sort = function(func)
        table.sort(self._awakenItemData.container, func)
    end
    
    self._awakenItemData.clear = function()
        self._awakenItemData.container = {}
    end
    
    self._awakenItemData.pack = function()
        return clone(self._awakenItemData.container)
    end

end

function BagAwakenLayer:onLayerEnter()
    
    -- 出售成功通知
    uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_SELL_RESULT, function(_, message)
        if message.ret == NetMsg_ERROR.RET_OK then
            if self._data then
                local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create({self._data})
                uf_notifyLayer:getModelNode():addChild(_layer)
                self._data = nil
            end
        end
    end, self)
    
    -- 包裹变化推送通知
    uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, function(_, bagType)
        if bagType == require("app.const.BagConst").CHANGE_TYPE.AWAKEN_ITEM then
            self:updateView()
        end
    end, self)
    
end

function BagAwakenLayer:onLayerExit()
    
    uf_eventManager:removeListenerWithTarget(self)
    
end

function BagAwakenLayer:updateView()
        
    self._awakenItemData:clear()
        
    -- 添加至本地的数据，因为表现和数据的存储本身并不一致
    local awakenItems = G_Me.bagData.awakenList:getList()
    
    for k, item in pairs(awakenItems) do
        local itemInfo = item_awaken_info.get(item.id)
        assert(itemInfo, "Could not find the item awaken info with id: "..item.id)
        
        if item.num >= MAX_BAG_AWAKEN_ITEM_NUM then
            local _item = clone(item)
            repeat
                self._awakenItemData.add{id=_item.id, num=math.min(MAX_BAG_AWAKEN_ITEM_NUM, _item.num), quality=itemInfo.quality}
                _item.num = _item.num - math.min(_item.num, MAX_BAG_AWAKEN_ITEM_NUM)
            until _item.num == 0
        else
            self._awakenItemData.add{id=item.id, num=item.num, quality=itemInfo.quality}
        end
    end
    
    self._awakenItemData.sort(function(a, b)
        return a.quality > b.quality
    end)
    
    -- 先移除所有的node
    local rootWidget = self:getRootWidget()
    rootWidget:removeAllNodes()
    
    -- 如果没有数据
    if self._awakenItemData.count() == 0 then
        
        -- 这里直接把创建好的EmptyLayer直接塞到self里
        local layer = require("app.scenes.common.EmptyLayer").createWithPanel(
            require("app.const.EmptyLayerConst").AWAKENITEM, rootWidget)
        
        -- 手动适配屏幕中心
        layer:setPositionY((display.height - 853) / 2)
        
    end
    
    if not self._listView then
        
        -- 创建列表
        local panel = self:getPanelByName("Panel_listview")

        local listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
        self._listView = listView
        
        listView:setCreateCellHandler(function()
            return CCSItemCellBase:create("ui_layout/bag_BagAwakenItem.json")
        end)
        
        listView:setUpdateCellHandler(function(list, index, cell)
            
            local item = self._awakenItemData.at(index+1)
            
            if item then
                
                local itemInfo = item_awaken_info.get(item.id)
                assert(itemInfo, "Could not find the awaken item with id: "..tostring(item.id))
                
                -- 描述
                _updateLabel(cell, "Label_desc", {text=itemInfo.comment, color=Colors.lightColors.DESCRIPTION})
                -- 名称
                _updateLabel(cell, "Label_name", {text=itemInfo.name, color=Colors.qualityColors[itemInfo.quality], stroke=Colors.strokeBlack})
                -- 数量
                _updateLabel(cell, "Label_itemNumTag", {text=G_lang:get("LANG_BAG_ITEM_NUM")})
                _updateLabel(cell, "Label_itemNum", {text=item.num})
                -- icon
                _updateImageView(cell, "ImageView_item", {texture=itemInfo.icon, texType=UI_TEX_TYPE_LOCAL})
                -- bg
                _updateImageView(cell, "ImageView_item_bg", {texture=G_Path.getEquipIconBack(itemInfo.quality), texType=UI_TEX_TYPE_PLIST})
                -- frame
                local frame = cell:getButtonByName("Button_item")
                frame:loadTextureNormal(G_Path.getEquipColorImage(itemInfo.quality))
                frame:loadTexturePressed(G_Path.getEquipColorImage(itemInfo.quality))
                
                cell:registerBtnClickEvent("Button_item", function()
--                    require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_AWAKEN_ITEM, item.id)
                    -- local layer = HeroAwakenItemDetailLayer.create(item.id, HeroAwakenItemDetailLayer.STATE_CERTAIN)
                    -- uf_sceneManager:getCurScene():addChild(layer)
                    require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_AWAKEN_ITEM, item.id, nil)
                end)
                
                cell:registerBtnClickEvent("Button_sell", function()
                    
                    local BagAwakenItemSellDetailLayer = require "app.scenes.bag.BagAwakenItemSellDetailLayer"
                    local layer = BagAwakenItemSellDetailLayer.create(
                        G_Goods.convert(G_Goods.TYPE_AWAKEN_ITEM, item.id, item.num), 
                        itemInfo.price_type, 
                        itemInfo.price, 
                        function(count, layer)
                            self._data = {type=G_Goods.TYPE_SHENHUN, size=itemInfo.price * count}
                            G_HandlersManager.bagHandler:sendSellMsg{{mode=G_Goods.TYPE_AWAKEN_ITEM, value=item.id, size=count}}
                            layer:animationToClose()                            
                        end)
                    uf_sceneManager:getCurScene():addChild(layer)
                    
                end)
                
            end
            
        end)
        
        listView:setSpaceBorder(0, 100)
        listView:initChildWithDataLength(self._awakenItemData:count(), 0.2)
    
    else
        
        self._listView:reloadWithLength(self._awakenItemData:count(), self._listView:getShowStart())
        
    end
    
end


return BagAwakenLayer
	
