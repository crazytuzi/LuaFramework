
local WheelTopAward = class("WheelTopAward", UFCCSModelLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local FuCommon = require("app.scenes.dafuweng.FuCommon")

function WheelTopAward:ctor(json,color,mode,...)
    self.super.ctor(self,json,color,...)
    self._mode = mode
    self:showAtCenter(true)
    self:setClickClose(true)
    self._id = 1

    self:registerWidgetClickEvent("Button_get", function ( ... )
        if self._mode == FuCommon.WHEEL_PRIZE_TYPE then
            if G_Me.wheelData:getState() == FuCommon.STATE_AWARD then
                G_HandlersManager.wheelHandler:sendWheelReward()
                self:animationToClose()
            else
                G_MovingTip:showMovingTip(G_lang:get("LANG_WHEEL_END"))
            end
        elseif self._mode == FuCommon.RICH_PRIZE_TYPE then
            if G_Me.richData:getState() == FuCommon.STATE_AWARD then
                G_HandlersManager.richHandler:sendRichReward(0,0)
                self:animationToClose()
            else
                G_MovingTip:showMovingTip(G_lang:get("LANG_FU_TIMEOUT2"))
            end
        elseif self._mode == FuCommon.TRIGRAMS_PRIZE_TYPE then
            if G_Me.trigramsData:getState() == FuCommon.STATE_AWARD then
                G_HandlersManager.trigramsHandler:sendGetReward()
                self:animationToClose()
            else
                G_MovingTip:showMovingTip(G_lang:get("LANG_TRIGRAMS_END"))
            end
        end
    end)
end

function WheelTopAward.create(mode,...)
    local id = 1
    if mode == FuCommon.WHEEL_PRIZE_TYPE then
        id = G_Me.wheelData.score >= G_Me.wheelData.jyRankScore and 2 or 1 
    elseif mode == FuCommon.RICH_PRIZE_TYPE then
        id = G_Me.richData.score >= G_Me.richData.jyRankScore and 2 or 1
    elseif mode == FuCommon.TRIGRAMS_PRIZE_TYPE then
        id = G_Me.trigramsData.score >= G_Me.trigramsData.jyRankScore and 2 or 1 
    end
    local layer = WheelTopAward.new("ui_layout/wheel_PaiHangAward"..3-id..".json",require("app.setting.Colors").modelColor,mode,...) 
    layer:setId(id)
    return layer
end

function WheelTopAward:setId(id)
    self._id = id
    local myRank 
    if self._mode == FuCommon.WHEEL_PRIZE_TYPE then
        myRank = G_Me.wheelData:getMyRank()
    elseif self._mode == FuCommon.RICH_PRIZE_TYPE then
        myRank = G_Me.richData:getMyRank()
    elseif self._mode == FuCommon.TRIGRAMS_PRIZE_TYPE then
        myRank = G_Me.trigramsData:getMyRank()
    end

    for i = 1 , id do 
        self:getLabelByName("Label_txt"..i):setText(G_lang:get("LANG_WHEEL_RANKAWARD"..i,{rank=myRank}))
        local info
        if self._mode == FuCommon.WHEEL_PRIZE_TYPE then
            info = G_Me.wheelData:getAward(myRank,i)
        elseif self._mode == FuCommon.RICH_PRIZE_TYPE then
            info = G_Me.richData:getAward(myRank,i)
        elseif self._mode == FuCommon.TRIGRAMS_PRIZE_TYPE then
            info = G_Me.trigramsData:getAward(myRank,i)
        end

        for k = 1 , 3 do 
            if info["type_"..k] > 0 then
                local g = G_Goods.convert(info["type_"..k], info["value_"..k])
                self:getImageViewByName("Image_icon"..i.."_"..k):loadTexture(g.icon)
                self:getImageViewByName("Image_ball"..i.."_"..k):loadTexture(G_Path.getEquipIconBack(g.quality))
                self:getLabelByName("Label_num"..i.."_"..k):setText("x"..info["size_"..k])
                self:getLabelByName("Label_num"..i.."_"..k):createStroke(Colors.strokeBrown, 1)
                self:getLabelByName("Label_name"..i.."_"..k):setText(g.name)
                self:getLabelByName("Label_name"..i.."_"..k):setColor(Colors.qualityColors[g.quality])
                self:getLabelByName("Label_name"..i.."_"..k):createStroke(Colors.strokeBrown, 1)
                self:getButtonByName("Button_border"..i.."_"..k):loadTextureNormal(G_Path.getEquipColorImage(g.quality))
                self:regisgerWidgetTouchEvent("Button_border"..i.."_"..k, function ( widget, param )
                    if param == TOUCH_EVENT_ENDED then -- 点击事件
                        require("app.scenes.common.dropinfo.DropInfo").show(info["type_"..k], info["value_"..k])  
                    end
                end)
                self:getImageViewByName("Image_board"..i.."_"..k):setVisible(true)
            else
                self:getImageViewByName("Image_board"..i.."_"..k):setVisible(false)
            end
        end
    end

    if id == 1 then
        self:getLabelByName("Label_txt2"):setText((G_lang:get("LANG_WHEEL_RANKAWARD3")))
        self:getLabelByName("Label_txt2"):createStroke(Colors.strokeBrown, 1)
    end
end

function WheelTopAward:onLayerEnter()
    self:closeAtReturn(true)
    EffectSingleMoving.run(self, "smoving_bounce")
end

function WheelTopAward:_onWheelInfoRsp(data)

end

return WheelTopAward

