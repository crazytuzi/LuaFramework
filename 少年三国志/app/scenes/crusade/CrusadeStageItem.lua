
require("app.cfg.battlefield_info")

local CrusadeStageItem = class("CrusadeStageItem")


function CrusadeStageItem:ctor(index, widget)

    self._widget = widget or nil
    self._index  = index or 1
    self._arrow = nil

    if self._widget then
        self._lableStage = self._widget:getChildByName("Label_Stage")
        self._lableStageNum = self._widget:getChildByName("Label_StageNum")

        self._lableStage = tolua.cast(self._lableStage,"Label")
        self._lableStageNum = tolua.cast(self._lableStageNum,"Label")

        if self._index ~= battlefield_info.getLength() then
            self._arrow = self._widget:getChildByName("Image_Arrow")
            self._arrow = tolua.cast(self._arrow,"ImageView")
        end

        self._lableStage:createStroke(Colors.strokeBrown, 1)
        self._lableStageNum:createStroke(Colors.strokeBrown, 1)
        self._lableStage:setText(G_lang:get("LANG_CRUSADE_GATE_NUM",{num=GlobalFunc.numberToChinese(index)}))
    end

end

--更改纹理和相关文本颜色
function CrusadeStageItem:updateState()

    if self._widget then


        --未开启
        if self._index > G_Me.crusadeData:getCurStage() then
            self._widget:loadTexture("ui/crusade/bg_guanka_lock.png")
            self._lableStage:setColor(Colors.darkColors.DESCRIPTION)
            self._lableStageNum:setColor(Colors.darkColors.DESCRIPTION)

            if self._arrow then
                self._arrow:showAsGray(true)
            end
        --当前关卡
        elseif self._index == G_Me.crusadeData:getCurStage() and not G_Me.crusadeData:hasPassStage() then
            self._widget:loadTexture("ui/crusade/bg_guanka_now.png")     
            self._lableStage:setColor(Colors.darkColors.TITLE_01)
            self._lableStageNum:setColor(Colors.darkColors.TITLE_01)
            if self._arrow then
                self._arrow:showAsGray(true)
            end
        else
            self._widget:loadTexture("ui/crusade/bg_guanka_normal.png")
            self._lableStage:setColor(Colors.darkColors.TITLE_01)
            self._lableStageNum:setColor(Colors.darkColors.TITLE_01)
            if self._arrow then
                self._arrow:showAsGray(false)
            end
        end
    end
end

function CrusadeStageItem:setVisible(visible)
    
    if self._widget then
        self._widget:setVisible(visible)
    end

end


return CrusadeStageItem


