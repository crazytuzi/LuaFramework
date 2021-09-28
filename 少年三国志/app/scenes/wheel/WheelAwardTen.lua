
local WheelAwardTen = class("WheelAwardTen", UFCCSModelLayer)
require("app.cfg.wheel_info")
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

function WheelAwardTen:ctor(...)
    self.super.ctor(self,...)
    self:showAtCenter(true)

    self:enableAudioEffectByName("Button_close", false)

    self:registerBtnClickEvent("Button_close", function()
        if self._callback then
            self._callback()
        end
        self:animationToClose()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    end)

    self:registerBtnClickEvent("Button_again", function ( ... )
        if G_Me.wheelData:getState() == 1 then
            local cost = G_Me.wheelData:getPrice(10,self._id)
            if G_Me.userData.gold >= cost then
                G_HandlersManager.wheelHandler:sendPlayWheel(self._id,10)
            else
                require("app.scenes.shop.GoldNotEnoughDialog").show()
            end
        else
            G_MovingTip:showMovingTip(G_lang:get("LANG_WHEEL_END"))
        end
        if self._callback then
            self._callback()
        end
        self:animationToClose()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    end)
end

function WheelAwardTen.create(id,award,money,score,callback,...)
    local layer = WheelAwardTen.new("ui_layout/wheel_Award.json",require("app.setting.Colors").modelColor,...) 
    layer:setAward(id,award,money,score)
    layer:setCallBack(callback)
    return layer
end

function WheelAwardTen:onLayerEnter()
    EffectSingleMoving.run(self, "smoving_bounce")
end

function WheelAwardTen:setCallBack(callback)
    self._callback = callback
end

function WheelAwardTen:_calcSameAward(award)
    local data = {}
    local temp = {}
    for i = 1 , #award do 
        if award[i].type > 0 then
            local tempKey = award[i].type*1000+award[i].value
            if rawget(temp,tempKey) then
                temp[tempKey] = temp[tempKey] + award[i].size
            else
                temp[tempKey] = award[i].size
            end
        end
    end
    for k , v in pairs(temp) do 
        table.insert(data,#data+1,{type=math.floor(k/1000),value=k%1000,size=v})
    end
    return data
end

function WheelAwardTen:_calcAward(id,award,money)
    local data = {}
    -- local temp = {}
    local info = wheel_info.get(id)
    -- for k,v in pairs(award) do 
    --     if temp[v] then
    --         temp[v] = temp[v] + 1
    --     else
    --         temp[v] = 1
    --     end
    -- end
    
    for k,v in pairs(award) do 
        if v < 8 then
            -- local _type = info["type_"..k]
            -- local _value = info["value_"..k]
            -- local _size = info["size_"..k]
            -- local award1 = {type=_type,value=_value,size=_size*v}
            local _type = info["type_"..v]
            local _value = info["value_"..v]
            local _size = info["size_"..v]
            local award1 = {type=_type,value=_value,size=_size}
            table.insert(data,#data+1,award1)
        end
    end
    local data = self:_calcSameAward(data)

    local myMoney = 0 
    for k, v in pairs(money) do 
        myMoney = myMoney + v
    end
    if myMoney > 0 then
        local moneyAward = {type=G_Goods.TYPE_GOLD,value=0,size=myMoney}
        table.insert(data,#data+1,moneyAward)
    end

    return data
end

function WheelAwardTen:setAward(id,award,money,score)
    self._id = id
    local data = self:_calcAward(id,award,money)
    table.insert(data,#data+1,score)
    local index = 0
    for k,v in pairs(data) do 
        index = index + 1
        local g = G_Goods.convert(v.type, v.value)
        self:getImageViewByName("Image_item"..index):setVisible(true)
        self:getImageViewByName("Image_icon"..index):loadTexture(g.icon)
        self:getImageViewByName("Image_ball"..index):loadTexture(G_Path.getEquipIconBack(g.quality))
        self:getLabelByName("Label_num"..index):setText("x"..GlobalFunc.ConvertNumToCharacter3(v.size))
        self:getLabelByName("Label_num"..index):createStroke(Colors.strokeBrown, 1)
        self:getButtonByName("Button_board"..index):loadTextureNormal(G_Path.getEquipColorImage(g.quality))
        self:getLabelByName("Label_name"..index):createStroke(Colors.strokeBrown, 1)
        self:getLabelByName("Label_name"..index):setText(g.name)
        self:getLabelByName("Label_name"..index):setColor(Colors.qualityColors[g.quality])
    end
    for i = index+1, 8 do 
        self:getImageViewByName("Image_item"..i):setVisible(false)
    end
end


return WheelAwardTen

