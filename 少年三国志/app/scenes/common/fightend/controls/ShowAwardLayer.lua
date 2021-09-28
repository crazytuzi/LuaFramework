


local ShowAwardLayer = class("ShowAwardLayer",UFCCSNormalLayer)


function ShowAwardLayer.create(...)
    return ShowAwardLayer.new("ui_layout/fightend_FightEndShowAward.json")
end

function ShowAwardLayer:ctor( ... )
	self.super.ctor(self, ...)
	-- self:getLabelByName("Label_title"):createStroke(Colors.strokeBrown,1)
 --    self:getLabelByName("Label_value"):createStroke(Colors.strokeBrown,1)
 --    self:getLabelByName("Label_title"):setText("")
 --    self:getLabelByName("Label_value"):setText("")
    self:getLabelByName("Label_title1"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_title2"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_value1"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_value2"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_active"):createStroke(Colors.strokeBrown,1)
    self:setClickSwallow(true)

end

function ShowAwardLayer:getContentSize( )
	return self:getPanelByName("Panel_container"):getContentSize()
	
end

function ShowAwardLayer:setEndCallback(endCallback)
    self._endCallback = endCallback


end



function ShowAwardLayer:setData(key, award)

    -- award={
    --   base_reward=data.least_award,
    --   extra_reward=data.extra_award,
    -- },
    self._award = award


    local goods = G_Goods.convert(self._award.type, self._award.value)

    self:getImageViewByName("ImageView_border"):loadTexture(G_Path.getEquipColorImage(goods.quality,goods.type))
    self:getImageViewByName("ImageView_icon"):loadTexture(goods.icon, UI_TEX_TYPE_LOCAL)
    self:getImageViewByName("Image_back"):loadTexture(G_Path.getEquipIconBack(goods.quality))

    -- self:getLabelByName("Label_name"):setColor(Colors.getColor(goods.quality))

    -- self:getLabelByName("Label_name"):createStroke(Colors.strokeBrown,1)

    -- if award.size > 1 then
    --     self:getLabelByName("Label_count"):setVisible(true)
    --     self:getLabelByName("Label_count"):setText('X' .. tostring(award.size))
    --     self:getLabelByName("Label_count"):createStroke(Colors.strokeBrown,1)
    -- else
    --     self:getLabelByName("Label_count"):setVisible(false)
    -- end

    self:getLabelByName("Label_title1"):setText(G_lang:get("LANG_FIGHTEND_AWARD_BASE"))
    self:getLabelByName("Label_title2"):setText(G_lang:get("LANG_FIGHTEND_AWARD_EXTRA"))

    self:getLabelByName("Label_value1"):setText(tostring(self._award.base_reward))
    -- self:getLabelByName("Label_value2"):setText(tostring(self._award.extra_reward.size))
    self:getLabelByName("Label_value2"):setText(0)
    self:showWidgetByName("Label_active",G_Me.activityData.custom:isDailyDungeonActive())


    local sum_title = self:getLabelByName("Label_sum_title")
    local sum_value = self:getLabelByName("Label_sum_value")
    sum_title:setText(G_lang:get("LANG_FIGHTEND_AWARD_SUM_TITLE"))
    sum_value:setText(tostring(self._award.extra_reward + self._award.base_reward ))
    --重新调整位置
    local sum_title_size = sum_title:getContentSize()
    local sum_value_size = sum_value:getContentSize()
    local width = sum_title_size.width + 10 + sum_value_size.width
    local panel = self:getPanelByName("Panel_total")
    local size = panel:getParent():getContentSize()
    panel:setPosition(ccp((size.width-width)/2,panel:getPositionY()))

    self:getPanelByName("Panel_total"):setVisible(false)

end


function ShowAwardLayer:play()
	-- self:_end()

    self._changer = require("app.scenes.common.NumberChanger").new( 0, self._award.extra_reward,
        function(value)
            self:getLabelByName("Label_value2"):setText(tostring(value))

        end, 
        function ( )

            self:callAfterFrameCount(8, function ( ... )
                --不播动画了
                self:getPanelByName("Panel_total"):setVisible(true)
                -- require("app.common.effects.EffectSingleMoving").run(self:getPanelByName("Panel_total"), "smoving_bounce", 
                --     function(event)   
                        self:_end()
                --     end
                -- )
            end)

            
        end
    )
    self._changer:play()
end


function ShowAwardLayer:_end()
    if self._changer ~= nil then
        self._changer:stop()
        self._changer = nil
    end
    
	if self._endCallback ~= nil then
		self._endCallback()
		self._endCallback = nil
	end
end
return ShowAwardLayer
