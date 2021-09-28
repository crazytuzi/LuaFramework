require("app.cfg.equipment_info")


local EquipmentConst = require("app.const.EquipmentConst")
local MergeEquipment = require("app.data.MergeEquipment")

local EquipmentListCell = class("EquipmentListCell",function()
    return CCSItemCellBase:create("ui_layout/equipment_EquipmentListCell.json")
end)

require("app.cfg.knight_info")
function EquipmentListCell:ctor()
    self._detailCallback = nil 
    self._equipment = nil
    self._isShowDetail = false
    self:setTouchEnabled(true)

    local label = self:getLabelByName("Label_attr02Value01")
    if label then 
        label:setSize(CCSizeMake(195, 35))
        label:setTextAreaSize(CCSizeMake(195, 35))
        label:setPositionXY(179,23)
    end

    self:registerBtnClickEvent("Button_showDetail", function ( widget )
        self:selectedCell(0, 1)
        if self._detailCallback ~= nil then
            self._detailCallback(self._equipment, true)
        end
        G_SoundManager:playSound(require("app.const.SoundConst").GameSound.LIST_UNFOLD)
        -- self._isShowDetail = true
        self:_updateDetailButton()
    end)
    self:registerBtnClickEvent("Button_hideDetail", function ( widget )
        if self._detailCallback ~= nil then
            self._detailCallback(self._equipment, false)
        end
        G_SoundManager:playSound(require("app.const.SoundConst").GameSound.LIST_UNFOLD)
        -- self._isShowDetail = false
        self:_updateDetailButton()
    end)    
    self:registerBtnClickEvent("Button_border", function ( widget )
        if self._equipment:isEquipment() then
          require("app.scenes.equipment.EquipmentInfo").showEquipmentInfo(self._equipment, 1)

        else
          require("app.scenes.treasure.TreasureInfo").showTreasureInfo(self._equipment, 1)

        end
    end)    

    
    --事件相关
    --uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_UPDATE_EQUIPMENT, self._onEquipmentChanged, self)
    --uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_UPDATE_TREASURE, self._onTreasureChanged, self)

    
end


function EquipmentListCell:setDetailCallback( func )
    self._detailCallback = func
end

function EquipmentListCell:_updateDetailButton( ... )
    self:showWidgetByName("Button_showDetail", not self._isShowDetail)
    self:showWidgetByName("Button_hideDetail", self._isShowDetail)
end

function EquipmentListCell:onDetailShow( show )
    self._isShowDetail = show or false
    self:_updateDetailButton()
end




-- function EquipmentListCell:_onEquipmentChanged(equipment)
--     if self._equipment == nil then
--         return
--     end
--     if self._equipment.id == equipment.id  and self._equipment.subtype == equipment.subtype then

--         --update current cell
--         self:updateCell(equipment, self._developeType)
--     end
-- end

-- function EquipmentListCell:_onTreasureChanged(treasure)
--     if self._equipment == nil then
--         return
--     end
--    if self._equipment.id == treasure.id  and self._equipment.subtype == treasure.subtype then

--        --update current cell
--        self:updateCell(treasure, self._developeType)
--    end
-- end

-- function EquipmentListCell:setSelectCallback(func)
--     self._selectCallback = func
-- end


-- function EquipmentListCell:setIconCallback(func)
--     self._clickIconCallback = func
-- end


function EquipmentListCell:updateData(equipment, isCurDetail)
    self._equipment = equipment

    self._isShowDetail = isCurDetail or false
    self:_updateDetailButton()

    local info = equipment:getInfo()

    --名字
    self:getLabelByName("Label_name"):createStroke(Colors.strokeBlack, 1)

    self:getLabelByName("Label_name"):setColor(Colors.qualityColors[info.quality])
    self:getLabelByName("Label_name"):setText(info.name)

    --类型
    -- self:getImageViewByName("ImageView_type"):loadTexture(equipment:getTypePic())
    self:getLabelByName("Label_type"):createStroke(Colors.strokeBlack, 1)
    self:getLabelByName("Label_type"):setColor(Colors.qualityColors[info.quality])
    self:getLabelByName("Label_type"):setText("【"..equipment:getTypeName().."】",true)

    --   --装备于
    local inLiueupId = equipment:getWearingKnightId()


    if inLiueupId > 0 then
        self:showWidgetByName("Label_lineupIn",true)
        
        local name = ""
        if G_Me.formationData:getMainKnightId() == inLiueupId then
            name = G_Me.userData.name
        else
            local knightId = G_Me.bagData.knightsData:getBaseIdByKnightId(inLiueupId)
            local knight = knight_info.get(knightId)
            name = knight.name
        end
        self:getLabelByName("Label_lineupIn"):setText(name)
    else
        self:showWidgetByName("Label_lineupIn",false)
    end
    
    --精炼X阶
    if equipment.refining_level > 0 then
        self:showWidgetByName("ImageView_jieshu",true)
        self:getLabelByName("Label_jieshu"):setText(G_lang:get("LANG_JING_LIAN", {level = equipment.refining_level}))
    else
        self:showWidgetByName("ImageView_jieshu",false)
    end

    
    --lv        
    self:getLabelByName("Label_level"):setText(G_lang:get("LANG_LEVEL_FORMAT_CHN", {levelValue = equipment.level}))

    
    --icon    
    
    self:getImageViewByName("ImageView_equipment_icon"):loadTexture(equipment:getIcon(),UI_TEX_TYPE_LOCAL)
    self:getButtonByName("Button_border"):loadTextureNormal(G_Path.getEquipColorImage(info.quality,G_Goods.TYPE_EQUIPMENT))
    self:getButtonByName("Button_border"):loadTexturePressed(G_Path.getEquipColorImage(info.quality,G_Goods.TYPE_EQUIPMENT))

    self:getImageViewByName("Image_iconbg"):loadTexture(G_Path.getEquipIconBack(info.quality))

    -- 升星等级
    local starLevel = equipment.star
    if starLevel and starLevel > 0 then
        self:showWidgetByName("Panel_stars_equip",true)
        for i = 1, EquipmentConst.Star_MAX_LEVEL do
            self:showWidgetByName(string.format("Image_start_%d_full", i), i <= starLevel)

        end

        local start_pos = {x = -47, y = -60}
        self:getPanelByName("Panel_stars_equip"):setPositionXY(start_pos.x + 9 * (EquipmentConst.Star_MAX_LEVEL - starLevel), start_pos.y)

    else
        self:showWidgetByName("Panel_stars_equip",false)
    end
     
     --属性名
     
    local attrs
    if equipment:isEquipment() then
        local strengthAttrs = equipment:getStrengthAttrs()
        local refineAttrs = equipment:getRefineAttrs()
        local starAttrs = equipment:getStarAttrs()

        attrs = MergeEquipment.getAllAttrs(strengthAttrs, refineAttrs, starAttrs)
    else
        attrs = equipment:getStrengthAttrs()
    end



     if #attrs == 1 then
         self:showWidgetByName("Panel_attr01", true)
         self:showWidgetByName("Panel_attr02", false)

         self:getLabelByName("Label_attr01Name01"):setText(attrs[1].typeString)
         self:getLabelByName("Label_attr01Value01"):setText( "+"  .. attrs[1].valueString)

     elseif #attrs ==2 then
         self:showWidgetByName("Panel_attr02", true)
         self:showWidgetByName("Panel_attr01", false)

         self:getLabelByName("Label_attr02Name01"):setText(attrs[1].typeString)
         self:getLabelByName("Label_attr02Value01"):setText( "+"  ..  attrs[1].valueString)

         self:getLabelByName("Label_attr02Name02"):setText(attrs[2].typeString)
         self:getLabelByName("Label_attr02Value02"):setText( "+"  ..  attrs[2].valueString)

     end


    
end

function EquipmentListCell:onLayerUnload()
    
    uf_eventManager:removeListenerWithTarget(self)

end


return EquipmentListCell
