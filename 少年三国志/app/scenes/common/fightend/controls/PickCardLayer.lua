
local PickCardLayer = class("PickCardLayer",UFCCSNormalLayer)
local EffectNode= require "app.common.effects.EffectNode"

local PickCardCell = require "app.scenes.common.fightend.controls.PickCardCell"

function PickCardLayer.create(...)
    return PickCardLayer.new("ui_layout/fightend_FightEndPickCardLayer.json")
end


function PickCardLayer:getContentSize( )
    return self:getRootWidget():getContentSize()
    
end

function PickCardLayer:setEndCallback(endCallback)
    self._endCallback = endCallback
end


function PickCardLayer:ctor(... )
    --创建3个卡牌
    self.super.ctor(self, ...)
    self._cards = {}
    self._picks = nil
    self._notPickedCards = {}
    self._endCallback = nil
    self:setClickSwallow(true)
    local notPickCardFinish = false
    local  notPickRevertCallback = function() 
        if notPickCardFinish == false then
            notPickCardFinish = true 
            --结束
            local goods = G_Goods.convert(self._picks[1].type, self._picks[1].value, self._picks[1].size)
            local name = goods.name
            if self._picks[1].type == G_Goods.TYPE_MONEY or self._picks[1].type == G_Goods.TYPE_GOLD then
                name = goods.size .. goods.name
            end
           
            local labelTips01 = self:getLabelByName("Label_tips01")
            local labelTips02 = self:getLabelByName("Label_tips02")
            labelTips01:createStroke(Colors.strokeBrown,1)
            labelTips02:createStroke(Colors.strokeBrown,1)
            --改成富文本格式
            -- self:getLabelByName("Label_tip"):setText(G_lang:get("LANG_FIGHTEND_GETPICK", {name = name}))
            self:showWidgetByName("Label_tip",false)
            self:showWidgetByName("Panel_tips",true)
            labelTips01:setText(G_lang:get("LANG_FIGHTEND_GETPICK"))
            labelTips02:setText(name)
            labelTips02:setColor(Colors.qualityColors[goods.quality])

            --调整位置居中
            local panel = self:getPanelByName("Panel_tips")
            if g_target == kTargetWinRT or g_target == kTargetWP8 then
                local param = labelTips02:getLayoutParameter(LAYOUT_PARAMETER_RELATIVE)
                if param then 
                    local margin = param:getMargin()
                    margin:setMargin(margin:getLeft() + 8, margin:getTop(), margin:getRight(), margin:getBottom())
                    param:setMargin(margin)
                    if panel then 
                        panel:requestDoLayout()
                    end        
                end
            end
            -- 4是2个文本的间距
            local width = labelTips01:getContentSize().width + labelTips02:getContentSize().width + 4

            panel:setPosition(ccp(display.cx - width/2,panel:getPositionY()))

            self:_end()
        end
    end
    
    local pickRevertCallback = function() 
        for j=1, #self._notPickedCards do
             self._notPickedCards[j]:startRevert(notPickRevertCallback)
        end
    end


    --local hlayout = require("app.common.layout.HLayout").new(self:getPanelByName("Panel_cards"), 30, "center")

    for i=1,3 do
        local startPick = function() 
            if self._playBackEffect == nil  then
                --说明现在不是翻牌阶段, 不要处理点击
                return
            end
            --print("select " .. i)
            --1. 给选中卡牌赋值, 然后给其他2张卡牌也赋值,    
            --2. 翻转选中卡牌, 旋转超过90度后,隐藏背面
            self:_stopPlayBack()

            self._notPickedCards = {}
            for j=1,#self._cards do
                if j ~= i then
                    table.insert(self._notPickedCards, self._cards[j])
        
                end
            end



            for j=1, #self._notPickedCards do
                 self._notPickedCards[j]:updateData(self._picks[j+1])
            end

            self._cards[i]:updateData(self._picks[1])
            self._cards[i]:setSelected(true)
            self._cards[i]:startRevert(pickRevertCallback)
            
        end
        local card = PickCardCell.new(self:getPanelByName("Panel_card_" .. i), self,  "_" .. i, startPick )
       -- hlayout:add(card)
        table.insert(self._cards, card)
        -- if IS_HEXIE_VERSION then 
        --     local bgImg = self:getImageViewByName("ImageView_back_"..i)
        --     if bgImg then 
        --         bgImg:loadTexture("ui/fightend/kapai_fan_hexie.png")
        --     end
        -- end
    end

end


-- function PickCardLayer:setEndCallback(endCallback)
--     self._endCallback = endCallback

   
-- end

--播放背面动画
function PickCardLayer:playAtBack( )
    local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
    local start = 1

    local playfunc 

    playfunc = function(event) 
         if event == "finish" then 
             start = start + 1
             if start > #self._cards then
                start = 1
            end
            self._playBackEffect = EffectSingleMoving.run(self._cards[start]:getWidget(), "smoving_pick", playfunc)
         end 
    end

    self._playBackEffect = EffectSingleMoving.run(self._cards[start]:getWidget(), "smoving_pick", playfunc)
end

function PickCardLayer:_stopPlayBack( )
    if self._playBackEffect then
        self._playBackEffect:stop()
        self._playBackEffect = nil
    end

    for i=1,#self._cards do
        self._cards[i]:getWidget():setScale(1)
    end
end

function PickCardLayer:setPicks( picks )
    self._picks = picks
end



function PickCardLayer:_end()
	self:_stopPlayBack()
    self:setTouchEnabled(false)
	if self._endCallback ~= nil then
		self._endCallback()
		self._endCallback = nil
	end
end

return PickCardLayer
