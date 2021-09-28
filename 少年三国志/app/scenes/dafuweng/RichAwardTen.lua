
local RichAwardTen = class("RichAwardTen", UFCCSModelLayer)
require("app.cfg.wheel_info")
require("app.cfg.richman_info")
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

function RichAwardTen:ctor(...)
    self.super.ctor(self,...)
    self:showAtCenter(true)

    self._listPanel = self:getPanelByName("Panel_list")
    self._scrollView = self:getScrollViewByName("ScrollView_list")

    self:enableAudioEffectByName("Button_get", false)
    self:setText()
    self:registerBtnClickEvent("Button_get", function()
        if self._callback then
            self._callback()
        end
        self:animationToClose()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    end)
end

function RichAwardTen.create(award,stepList,score,callback,...)
    local layer = RichAwardTen.new("ui_layout/dafuweng_TenAward.json",require("app.setting.Colors").modelColor,...) 
    layer:setAward(award,stepList,score)
    layer:setCallBack(callback)
    return layer
end

function RichAwardTen:onLayerEnter()
    EffectSingleMoving.run(self, "smoving_bounce")
end

function RichAwardTen:setCallBack(callback)
    self._callback = callback
end

function RichAwardTen:setText()
        local label = self:getLabelByName("Label_desc")
        label:setVisible(false)
        if label then 
            local size = label:getSize()
            local pos = ccp(label:getPosition())
            self._inputRichText = CCSRichText:create(size.width, size.height)
            self._inputRichText:setFontSize(label:getFontSize())
            self._inputRichText:setFontName(label:getFontName())
            local color = label:getColor()
            self._defaultColor = ccc3(color.r, color.g, color.b)
            self._inputRichText:setColor(self._defaultColor)
            self._inputRichText:setShowTextFromTop(true)
            self._inputRichText:setPosition(pos)
        end
        local backImg = self:getWidgetByName("Image_back")
        if backImg then 
            backImg:addChild(self._inputRichText)
        end
end

function RichAwardTen:_updateRichText( txt )
    if self._inputRichText then 
        self._inputRichText:clearRichElement()
        self._inputRichText:appendContent(txt, self._defaultColor)
        self._inputRichText:reloadData()
    end
end

function RichAwardTen:_calcAward(award,stepList,score)
    local data = {}
    local temp = {}
    for i = 1 , #award do 
        if award[i].type > 0 then
            local tempKey = award[i].type*1000+award[i].value
            if rawget(temp,tempKey) then
                temp[tempKey].size = temp[tempKey].size + award[i].size
            else
                local info = richman_info.get((stepList[i]-1)%35+1)
                temp[tempKey] = {size=award[i].size,show=(info.icon_effect==1)}
            end
        end
    end
    for k , v in pairs(temp) do 
        table.insert(data,#data+1,{type=math.floor(k/1000),value=k%1000,size=v.size,light=v.show})
    end
    -- table.insert(data,#data+1,{type=24,value=1,size=score})
    return data
end

function RichAwardTen:setAward(award,stepList,score)
    self:_updateRichText(G_lang:get("LANG_FU_AWARDGOT",{score=score}))
    local data = self:_calcAward(award,stepList,score)
    local count = #data
    local height = math.floor((count-1)/4)+1
    height = height * 155 + (height-1)*10
    local size = self._scrollView:getContentSize()
    if height > size.height then
        self._scrollView:setInnerContainerSize(CCSizeMake(size.width,height))
        self._listPanel:setSize(CCSizeMake(size.width,height))
        self._listPanel:setPositionXY(0,0)
        self._scrollView:setTouchEnabled(true)
    else
        self._scrollView:setInnerContainerSize(CCSizeMake(size.width,size.height))
        self._listPanel:setSize(CCSizeMake(size.width,height))
        self._listPanel:setPositionXY(0,size.height-height)
        self._scrollView:setTouchEnabled(false)
    end
    GlobalFunc.createIconInPanel({panel=self._listPanel,award=data,click=true,name=true,offset=5,maxX=4})
end


return RichAwardTen

