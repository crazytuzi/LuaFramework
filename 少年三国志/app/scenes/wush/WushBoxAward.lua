
local WushBoxAward = class("WushBoxAward", UFCCSModelLayer)
require("app.cfg.dead_battle_info")
require("app.cfg.dead_battle_award_info")
Goods = require("app.setting.Goods")

function WushBoxAward:ctor(jsonFile)
    self.super.ctor(self, jsonFile)
    self:showAtCenter(true)
    self:enableAudioEffectByName("Button_close", false)
    self:enableLabelStroke("Label_desc1", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_star", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_desc2", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_floor", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_desc3", Colors.strokeBrown, 1 )
    self:showTextWithLabel("Label_desc1", G_lang:get("LANG_WUSH_AWARD_LABEL1"))
    self:showTextWithLabel("Label_desc2", G_lang:get("LANG_WUSH_AWARD_LABEL2"))
    self:showTextWithLabel("Label_desc3", G_lang:get("LANG_WUSH_AWARD_LABEL3"))
    self:showTextWithLabel("Label_desc4", G_lang:get("LANG_WUSH_AWARD_LABEL4"))

    self:registerBtnClickEvent("Button_close", function()
        self:animationToClose()
                local soundConst = require("app.const.SoundConst")
                G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    end)
end

function WushBoxAward:onLayerEnter( )
    self:closeAtReturn(true)
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
end


function WushBoxAward:init(floor)
    -- self:getLabelByName("Label_star"):setText(G_Me.wushData:getStarCur())

    local ceng = math.floor((floor-1)/3)
    self:getLabelByName("Label_star"):setText(G_Me.wushData:calcCurStar(ceng*3+1,floor-1))
    local str = G_lang:get("LANG_WUSH_GUANG",{floormin=(ceng*3+1),floormax=(ceng*3+3)})
    self:getLabelByName("Label_floor"):setText(str)
    self:initAward(ceng*3+3,1)
    self:initAward(ceng*3+3,2)
    self:initAward(ceng*3+3,3)
end

function WushBoxAward:initAward(floor, index )
    local info = dead_battle_info.get(floor)
    local star = info["type_star_"..index]
    -- local awardInfo = dead_battle_award_info.get(info["type_award_"..index])

    self:getLabelByName("Label_starnum"..index):setText(star)

    -- local award = {}
    -- for i = 1 , 3 do 
    --     if awardInfo["type_"..i] > 0 then
    --         table.insert(award,#award+1,{type=awardInfo["type_"..i],value=awardInfo["value_"..i],size=awardInfo["size_"..i]})
    --     end
    -- end
    local award = G_Me.wushData:getAwardById(info["type_award_"..index])
    local panel = self:getPanelByName("Panel_awardPanel"..index)
    panel:removeAllChildrenWithCleanup(true)
    GlobalFunc.createIconInPanel({panel=self:getPanelByName("Panel_awardPanel"..index),award=award,click=true,left=true})
    -- for i=1,2 do
    --     if award["type_"..i] ~= 0 then
    --         local g = Goods.convert(award["type_"..i], award["value_"..i])
    --         if g then
    --             self:getImageViewByName("ico"..index.."_"..i):loadTexture(g.icon)
    --             local labelName = self:getLabelByName("bounsname"..index.."_"..i)
    --             labelName:setColor(Colors.getColor(g.quality))
    --             labelName:setText(g.name)
    --             labelName:createStroke(Colors.strokeBrown, 1)
    --             self:getImageViewByName("bouns"..index.."_"..i):loadTexture(G_Path.getEquipColorImage(g.quality,g.type))
    --             self:getLabelByName("bounsnum"..index.."_"..i):setText("×"..award["size_"..i])
    --             self:getLabelByName("bounsnum"..index.."_"..i):createStroke(Colors.strokeBrown, 1)
    --             self:regisgerWidgetTouchEvent("ImageView_bouns"..index..i, function ( widget, param )
    --                 if param == TOUCH_EVENT_ENDED then -- 点击事件
    --                     require("app.scenes.common.dropinfo.DropInfo").show(award["type_"..i], award["value_"..i])  
    --                 end
    --             end)
    --         end
    --     else
    --         self:getImageViewByName("ImageView_bouns"..index.."_"..i):setVisible(false)
    --     end
    -- end
end

function WushBoxAward:onLayerExit()
    self.super:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end

function WushBoxAward:onLayerUnload( ... )

end

return WushBoxAward
