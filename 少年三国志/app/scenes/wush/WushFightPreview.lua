require("app.cfg.dead_battle_info")

local WushFightPreview = class("WushFightPreview", UFCCSModelLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

function WushFightPreview:ctor(jsonFile)
    self.super.ctor(self, jsonFile)
    self:showAtCenter(true)
    -- self:setClickClose(true)
    -- self:registerTouchEvent(false,true,0)

    self:registerBtnClickEvent("Button_BuZhen", function()
        require("app.scenes.hero.HerobuZhengLayer").showBuZhengLayer()
    end)
    
    self:registerBtnClickEvent("Button_fight1", function()
        self:_onStartFight(0)
    end)
    self:registerBtnClickEvent("Button_fight2", function()
        self:_onStartFight(1)
    end)
    self:registerBtnClickEvent("Button_fight3", function()
        self:_onStartFight(2)
    end)
    self:registerBtnClickEvent("Button_close", function()
        self:onBackKeyEvent()
    end)

end

function WushFightPreview:onLayerEnter( )
    -- self:closeAtReturn(true)
    self:registerKeypadEvent(true, false)
end

function WushFightPreview:onBackKeyEvent( ... )
    self._callback()
    self:close()
    return true
end

function WushFightPreview:initWithFloor(floorId,callback)
    self._floorId = floorId
    self._callback = callback
    local info = dead_battle_info.get(floorId)
    self._tinfo = info
    self._knight =KnightPic.createKnightPic( info.monster_image, self:getPanelByName("Panel_hero"), "wush_floor_"..floorId )
    local name = self:getLabelByName("Label_name")
    name:setText(info.name.." "..info.name2)
    name:createStroke(Colors.strokeBrown, 2)
    local desc = self:getLabelByName("Label_talk")
    desc:setText(info.talk)
    -- desc:createStroke(Colors.strokeBrown, 1)

    -- local title1 = self:getLabelByName("Label_title1")
    -- title1:setText(G_lang:get("LANG_WUSH_TIAOJIAN"))
    -- title1:createStroke(Colors.strokeBrown, 2)
    local title2 = self:getLabelByName("Label_title2")
    title2:setText(G_lang:get("LANG_WUSH_NANDU"))
    title2:createStroke(Colors.strokeBrown, 2)

    self:getLabelByName("Label_tiaojian"):setText(G_lang:get("LANG_WUSH_TIAOJIAN")..":"..info.success_directions)
    self:_initButton(1)
    self:_initButton(2)
    self:_initButton(3)

    -- EffectSingleMoving.run(self:getImageViewByName("Image_kongbai"), "smoving_wait", nil , {position = true} )
end

function WushFightPreview:_initButton(index)
    local info = self._tinfo
    self:getLabelByName("Label_star"..index):setText(index)
    self:getLabelByName("Label_moneyname"..index):setText(G_lang:get("LANG_WUSH_MONEY").."：")
    self:getLabelByName("Label_scorename"..index):setText(G_lang:get("LANG_WUSH_SCORE").."：")
    self:getLabelByName("Label_money"..index):setText(info["coins_"..index]*0.8)
    self:getLabelByName("Label_score"..index):setText(info["tower_score_"..index]*0.8*(G_Me.activityData.custom:isWushActive() and 2 or 1) )
    -- self:getLabelByName("Label_sug"..index):setText(G_lang:get("LANG_WUSH_SUG")..info["monster_fight_"..index])
    self:getLabelByName("Label_sug"..index):setText(G_lang:get("LANG_WUSH_SUG")..self:_sugNum(info["monster_fight_"..index]))
    -- self:getLabelByName("Label_sug"..index):createStroke(Colors.strokeBrown, 1)
end

function WushFightPreview:_sugNum(num)
    local des = num
    if num >= 100000 then
        des = math.floor(num/10000).."万"
    end
    return des
end

function WushFightPreview:_onStartFight(index)
    self:close()
    self._callback()
    G_HandlersManager.wushHandler:sendWushChallenge(index,false,true)
    -- G_Me.wushData:battleWin(3)
end

function WushFightPreview:onLayerExit()
    self.super:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end

function WushFightPreview:onLayerUnload( ... )

end

-- function WushFightPreview:onClickClose( ... )
--     self._callback()
--     self:close()
--     return true
-- end

return WushFightPreview
