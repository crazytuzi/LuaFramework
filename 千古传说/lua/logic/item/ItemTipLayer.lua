

local ItemTipLayer = class("ItemTipLayer", BaseLayer)

function ItemTipLayer:ctor(data)
    self.super.ctor(self, data)
    self:init("lua.uiconfig_mango_new.common.ItemTipLayer")
end

function ItemTipLayer:loadData(data)

    self.itemID = data[1]
    self.itemType = data[2] -- 1物品 2卡牌
    self.itemNum = data[3]

    local itemBgImg = TFDirector:getChildByPath(self, "itemImg")
    local itemIcon = TFDirector:getChildByPath(self, "itemIcon")
    local qualityImg = TFDirector:getChildByPath(self, "qualityImg")
    local nameLabel = TFDirector:getChildByPath(self, "nameLabel")
    local descLabel = TFDirector:getChildByPath(self, "descLabel")
    local attrLabel = TFDirector:getChildByPath(self, "attrLabel")
    local btn_info = TFDirector:getChildByPath(self, "btn_info")
    self.attrLabel = attrLabel
    attrLabel:setVisible(false)
    btn_info:setVisible(false)
    
    if self.itemType == 1 then
        local itemData = ItemData:objectByID(self.itemID)
        if itemData ~= nil then
            itemBgImg:setTexture(GetBackgroundForGoods(itemData))
            itemIcon:setTexture(itemData:GetPath())
            qualityImg:setTexture(GetFontByQuality(itemData.quality))
            nameLabel:setText(itemData.name)
            descLabel:setText(itemData.details)

            local equipData = EquipmentTemplateData:objectByID(self.itemID)
            if equipData ~= nil then
                local baseAttr = equipData:getAttribute()
                for i=1,(EnumAttributeType.Max-1) do
                    if baseAttr[i] ~= nil then
                        local grow = equipData.growth_factor
                        grow = grow/100
                        local str = AttributeTypeStr[i].."+"..math.floor(baseAttr[i]*grow)
                        attrLabel:setVisible(true)
                        attrLabel:setText(str)
                        break
                    end
                end
            else
                local str = localizable.ItemTipLayer_have_txt..BagManager:getItemNumById(self.itemID)
                attrLabel:setVisible(true)
                attrLabel:setText(str)
            end

            if itemData.type == EnumGameItemType.Soul and itemData.kind == 1  then
                btn_info:setVisible(true)
                btn_info:addMEListener(TFWIDGET_CLICK,audioClickfun(function()  CommonManager:openIllustrationRole(itemData.usable); end))
            end
        end
    elseif self.itemType == 2 then
        local cardData = RoleData:objectByID(self.itemID)
        if cardData ~= nil then
            itemBgImg:setTexture(GetColorIconByQuality(cardData.quality))
            itemIcon:setTexture(cardData:getIconPath())
            qualityImg:setTexture(GetFontByQuality(cardData.quality))
            nameLabel:setText(cardData.name)
            descLabel:setText(cardData.description)

            -- if ProtagonistData:IsMainPlayer( self.itemID ) == false then
            --     btn_info:setVisible(true)
            --     btn_info:addMEListener(TFWIDGET_CLICK,audioClickfun(function()  CommonManager:openIllustrationRole(self.itemID); end))
            -- end
        end
    else
        local data = BaseDataManager:getReward({type = self.itemType})

        if data ~= nil then
            itemBgImg:setTexture(GetColorIconByQuality(data.quality))
            itemIcon:setTexture(data.path)
            nameLabel:setText(data.name)
            descLabel:setText(data.desc)
            qualityImg:setVisible(false)

            if self.itemNum ~= nil then
                attrLabel:setVisible(true)
                --attrLabel:setText("获得数量:"..self.itemNum)
                attrLabel:setText(stringUtils.format(localizable.common_count, self.itemNum))
            end
        end
    end

    Public:addPieceImg(itemIcon,{type = self.itemType,itemid = self.itemID}); 
end

function ItemTipLayer:setTipText(text)
    self.attrLabel:setVisible(true)
    self.attrLabel:setText(text)
end

function ItemTipLayer:initUI(ui)
	self.super.initUI(self,ui)
    self.ui = ui

end

function ItemTipLayer:registerEvents(ui)
    self.super.registerEvents(self)
    self.ui:addMEListener(TFWIDGET_CLICK, audioClickfun(function()  AlertManager:close(AlertManager.TWEEN_1); end))
end
function ItemTipLayer:removeEvents()
    self.super.removeEvents(self)
    self.ui:removeMEListener(TFWIDGET_CLICK)
end


return ItemTipLayer
