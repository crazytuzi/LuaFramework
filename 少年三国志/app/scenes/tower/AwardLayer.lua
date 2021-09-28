require("app.cfg.tower_info")
require("app.cfg.item_info")
Path = require("app.setting.Path")
Goods = require("app.setting.Goods")
local AwardLayer = class("AwardLayer",UFCCSNormalLayer)

function AwardLayer:ctor(...)
    self.super.ctor(self, ...)
    self:adapterWithScreen()
    -- self._prizeLabel = self:getLabelByName("Label_Prize")

    self:getLabelByName("Label_32"):createStroke(Colors.strokeBrown, 1)

    self._nameLabels = {}
    for i=1,5 do
        self._nameLabels[#self._nameLabels+1] = self:getLabelByName(string.format("Label_Item%d", i))
    end
    
    self._imageViews = {}
    for i=1,5 do
        self._imageViews[#self._imageViews+1] = self:getImageViewByName(string.format("ImageView_Item%d", i))
    end
end

function AwardLayer:initWithFloor(floor)
    local ri =  tower_info.get(floor)
    if not ri then
        return
    end
    
    self:getLabelByName("Label_34271"):setText(G_lang:get("LANG_TOWER_MONEY"))
    self:getLabelByName("Label_34273"):setText(G_lang:get("LANG_TOWER_JIFEN"))
    self:getLabelByName("Label_yinliang"):setText(ri.coins)
    self:getLabelByName("Label_jifen"):setText(ri.tower_score)
    -- if ri.tower_score > 0 then
        -- self._prizeLabel:setText(string.format("银币 %d  闯关积分 %d", ri.coins, ri.tower_score))
    -- else
        -- self._prizeLabel:setText(string.format("银币 %d", ri.coins))
    -- end
    -- self._prizeLabel:createStroke(Colors.strokeBrown, 1)
    
    self._floor = floor
    local ti = tower_info.get(self._floor)
    if ti then
        for i=1,4 do
            if ti["type_"..i] ~= 0 then
                local g = Goods.convert(ti["type_"..i], ti["value_"..i])
                if g then
                    self._imageViews[i]:loadTexture(g.icon)
                    self._nameLabels[i]:setColor(Colors.getColor(g.quality))
                    self._nameLabels[i]:setText(g.name)
                    self._nameLabels[i]:createStroke(Colors.strokeBrown, 1)
                    self:getImageViewByName("Image_bottom"..i):setVisible(true)
                    self:getImageViewByName("ImageView_ItemBorder"..i):loadTexture(G_Path.getEquipColorImage(g.quality,g.type))
                    self:registerWidgetClickEvent("ImageView_ItemBorder"..i, function ( )
                        -- if param == TOUCH_EVENT_ENDED then -- 点击事件
                            -- print("click"..i.." "..ti["type_"..i].." "..ti["value_"..i])
                            require("app.scenes.common.dropinfo.DropInfo").show(ti["type_"..i], ti["value_"..i])  
                        -- end
                    end)
                end
            else
                self:getImageViewByName(string.format("ImageView_ItemBorder%d", i)):setVisible(false)
                self._imageViews[i]:setVisible(false)
                self:getImageViewByName("Image_bottom"..i):setVisible(false)
            end
        end
    end

    self:getImageViewByName("ImageView_ItemBorder5"):setVisible(false)
    self:getImageViewByName("Image_bottom5"):setVisible(false)
    self._imageViews[5]:setVisible(false)
end

return AwardLayer


    