
local RichMoney = class("RichMoney", UFCCSModelLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

function RichMoney:ctor(...)
    self.super.ctor(self,...)
    self:showAtCenter(true)
    self._baseHeight = 83

    self._showNumList = {1,1,1,1,1}
    for i = 1 , 5 do 
        self:getLabelBMFontByName("BitmapLabel_"..i.."_"..1):setText(0)
    end
end

function RichMoney.create(money,...)
    local layer = RichMoney.new("ui_layout/dafuweng_Money.json",require("app.setting.Colors").modelColor,...) 
    layer:delayShow(money)
    return layer
end

function RichMoney:delayShow( money )
    self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.5),CCCallFunc:create(function()
        self:showMoney(money)
        G_SoundManager:playSound(require("app.const.SoundConst").GameSound.SCROLL_NUMBER_LONG)
    end)))
end

function RichMoney:showMoney(money)
    self._money = money
    self._endCount = 0
    local temp = money
    for i = 1 , 5 do 
        local num = temp%10
        temp = math.floor(temp/10)
        self:rollOne(6-i,num+i*10,1)
    end
end

function RichMoney:rollOne(index, num,curNum )
    local time = 0.05
    local cur = self._showNumList[index]
    local item1 = self:getLabelBMFontByName("BitmapLabel_"..index.."_"..cur)
    local item2 = self:getLabelBMFontByName("BitmapLabel_"..index.."_"..3-cur)
    item2:setText(curNum%10)
    item2:runAction(CCMoveBy:create(time,ccp(0,self._baseHeight)))
    item1:runAction(CCSequence:createWithTwoActions(CCMoveBy:create(time,ccp(0,self._baseHeight)),CCCallFunc:create(function()
        local posx,posy = item1:getPosition()
        item1:setPositionXY(posx,posy-self._baseHeight*2)
        self._showNumList[index] = 3 - self._showNumList[index]
        if curNum < num then
            self:rollOne(index,num,curNum+1)
        else
            self:showEnd()
        end
    end)))
end

function RichMoney:showEnd( )
    self._endCount = self._endCount + 1
    if self._endCount == 5 then
        self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.5),CCCallFunc:create(function()
            local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create({{type=1,value=1,size=self._money}})
            uf_sceneManager:getCurScene():addChild(_layer)
            self:close()
        end)))
    end
end

function RichMoney:onLayerEnter()
    self:closeAtReturn(true)
    EffectSingleMoving.run(self, "smoving_bounce")
end

function RichMoney:onLayerExit( ... )
    uf_eventManager:removeListenerWithTarget(self)
end

return RichMoney

