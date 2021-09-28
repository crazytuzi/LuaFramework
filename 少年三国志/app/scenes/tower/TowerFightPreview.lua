require("app.cfg.tower_info")
local AwardConst = require("app.const.AwardConst")
local TowerFightPreviewLayer = class("TowerFightPreviewLayer", UFCCSModelLayer)

function TowerFightPreviewLayer:ctor(jsonFile)
    self.super.ctor(self, jsonFile)
    self:showAtCenter(true)
    self:registerBtnClickEvent("closebtn", function()
        self:close()
    end)
    self:registerBtnClickEvent("Button_BuZhen", function()
        require("app.scenes.hero.HerobuZhengLayer").showBuZhengLayer()
    end)
    
    self:registerBtnClickEvent("Button_Challenge", handler(self, self._onStartFight))

end

function TowerFightPreviewLayer:onLayerEnter( )
    self:closeAtReturn(true)
end

function TowerFightPreviewLayer:initWithFloor(towerLayer, floorId, isboss)
    self._towerLayer = towerLayer
    self._floor = floorId
    self._tinfo = tower_info.get(floorId)
    self._timesLeft = towerLayer:getCurTryLeft()
    self._timesTotal = towerLayer:getMaxTry()

    if self._timesLeft == 0 then 
        self:getLabelByName("Label_times"):setColor(Colors.lightColors.TIPS_01)
    else 
        self:getLabelByName("Label_times"):setColor(Colors.lightColors.DESCRIPTION)
    end

    self:getLabelByName("Label_Name"):setText(G_lang:get("LANG_TOWER_CENGSHU",{floor = floorId}))
    self:getLabelByName("Label_Name"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_tiaojian"):setText(G_lang:get("LANG_TOWER_TIAOJIAN"))
    self:getLabelByName("Label_tiaojian"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_txt"):setText(self._tinfo.success_directions)
    self:getLabelByName("Label_Desc"):setText(self._tinfo.talk)
    self:getLabelByName("Label_ChallengeTimes"):setText(G_lang:get("LANG_TOWER_CISHUSHENGYU1"))
    self:getLabelByName("Label_times"):setText(G_lang:get("LANG_TOWER_CISHUSHENGYU2",
        {left = self._timesLeft,total = self._timesTotal}))


    local head = require("app.scenes.common.KnightPic").getHalfNode(self._tinfo.monster_image,0, true)
    self:getPanelByName("Panel_4"):addNode(head)
    head:setScale(0.7)
    head:setPositionX(self:getPanelByName("Panel_4"):getContentSize().width*0.5)
    head:setPositionY(self:getPanelByName("Panel_4"):getContentSize().height*0.5)

    if isboss then 
        self:_initAwardBoss(floorId)
    else 
        self:_initAwardNormal(floorId)
    end
    
    -- self._panelAward = self:getPanelByName("Panel_AwardContainer")
    -- local p = require("app.scenes.tower.AwardLayer").new("ui_layout/tower_AwardPreview.json")
    -- p:initWithFloor(self._floor)
    -- p:setPosition(ccp(0,0))
    -- self._panelAward:addNode(p)
    
end

function TowerFightPreviewLayer:_initAwardNormal(floor)
    local ti =  tower_info.get(floor)
    self:getLabelByName("Label_Prize"):setText(G_lang:get("LANG_TOWER_MONEY"))
    self:getLabelByName("Label_Prize2"):setText(G_lang:get("LANG_TOWER_ZHANGONG"))
    -- self:getLabelByName("Label_Prize"):createStroke(Colors.strokeBrown, 1)
    -- self:getLabelByName("Label_Prize2"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_2566"):setText(G_lang:get("LANG_TOWER_JIANGLI"))
    self:getLabelByName("Label_2566"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_prizeValue1"):setText(ti.coins)
    self:getLabelByName("Label_prizeValue2"):setText(ti.tower_score)
    -- self:getLabelByName("Label_prizeValue1"):createStroke(Colors.strokeBrown, 1)
    -- self:getLabelByName("Label_prizeValue2"):createStroke(Colors.strokeBrown, 1)
end

function TowerFightPreviewLayer:_initAwardBoss(floor)

    local ti = tower_info.get(self._floor)
    if ti then
        self:getLabelByName("Label_Exp"):setText(G_lang:get("LANG_TOWER_MONEY"))
        self:getLabelByName("Label_Sliver"):setText(G_lang:get("LANG_TOWER_ZHANGONG"))
        self:getLabelByName("Label_ExperienceValue"):setText(ti.coins)
        self:getLabelByName("Label_SilverValue"):setText(ti.tower_score)
        self:getLabelByName("Label_MaybeGet"):setText(G_lang:get("LANG_TOWER_MAYBE"))
        self:getLabelByName("Label_31"):createStroke(Colors.strokeBrown, 1)
        for i=1,4 do
            if ti["type_"..i] ~= 0 then
                local g = Goods.convert(ti["type_"..i], ti["value_"..i])
                if g then
                    self:getImageViewByName("ico"..i):loadTexture(g.icon)
                    local labelName = self:getLabelByName("bounsname"..i)
                    labelName:setColor(Colors.getColor(g.quality))
                    labelName:setText(g.name)
                    labelName:createStroke(Colors.strokeBrown, 1)
                    self:getImageViewByName("bouns"..i):loadTexture(G_Path.getEquipColorImage(g.quality,g.type))
                    self:getLabelByName("bounsnum"..i):setVisible(false)
                    self:regisgerWidgetTouchEvent("ImageView_bouns"..i, function ( widget, param )
                        if param == TOUCH_EVENT_ENDED then -- 点击事件
                            require("app.scenes.common.dropinfo.DropInfo").show(ti["type_"..i], ti["value_"..i])  
                        end
                    end)
                end
            else
                self:getImageViewByName("ImageView_bouns"..i):setVisible(false)
            end
        end
    end

    self:getImageViewByName("ImageView_bouns5"):setVisible(false)
end

function TowerFightPreviewLayer:_onStartFight()
    if self._timesLeft == 0 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_TOWER_CISHUYONGWAN"))
        return
    end
    __Log("-------------tower start----------")
    self:close()
    G_HandlersManager.towerHandler:sendTowerChallenge(self._towerLayer:getSelectedBuffId())
end

function TowerFightPreviewLayer:onLayerExit()
    self.super:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end

function TowerFightPreviewLayer:onLayerUnload( ... )
    __Log("-------------tower fightpreview unload----------")
end

return TowerFightPreviewLayer
