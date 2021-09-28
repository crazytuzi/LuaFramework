local MoShenInfoDialog = class("MoShenInfoDialog",UFCCSModelLayer)
local moShenConst = require("app.const.MoShenConst")
require("app.cfg.rebel_info")
require("app.const.ShopType")
require("app.cfg.rebel_special_event_info")
--注意添加json文件
--[[
    rebel 叛军
]]
function MoShenInfoDialog.show(rebel)
    local layer = MoShenInfoDialog.new("ui_layout/moshen_MoShenInfoDialog.json",Colors.modelColor,rebel)
    uf_sceneManager:getCurScene():addChild(layer)
    -- return layer
end

--适配写在这里
function MoShenInfoDialog:adapterLayer()
    
end


function MoShenInfoDialog:ctor(json,color,rebel,...)
    self._isFirstTime = true
    self._rebel = rebel

    --全力一击是否处于出征令减半状态
    self._isHalfActivity = false 
    self._localRebel = rebel_info.get(self._rebel.id) 
    self.super.ctor(self,...)
    self:showAtCenter(true)
    if not G_Me.shopData:checkEnterScoreShop() then
        G_HandlersManager.shopHandler:sendShopInfo(SHOP_TYPE_SCORE)
    end
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_MOSHEN_PUBLIC_REBEL, self._getPublicRebel, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_MOSHEN_ATTACK_REBEL, self._getAttackRebel, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_ITEM_BUY_RESULT, self._getBuyResult, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECV_ROLE_INFO, self._getRoleInfo, self)
    self:_initButtonEvent()
    self:_initWidgets()
    self:_setWidgets()
    self:_createStrokes()
    self:_onRefreshEscapeTime()
    self:_addEscapeTimer()
end

function MoShenInfoDialog:_initWidgets()
    self._nameLabel = self:getLabelByName("Label_name")
    self._levelLabel = self:getLabelByName("Label_level")
    self._chuzhenlingCountLabel = self:getLabelByName("Label_chuzhenglingCount")
    self._bloodLabel = self:getLabelByName("Label_blood")
    self._bloodLoadingBar = self:getLoadingBarByName("ProgressBar_blood")
    self.statusLabel = self:getLabelByName("Label_status")
end

function MoShenInfoDialog:_setWidgets()
    if self._rebel ~= nil then
        self._chuzhenlingCountLabel:setText(G_Me.userData.battle_token .. "/" .. self:_getMaxBattleToken())
        self._nameLabel:setColor(Colors.qualityColors[self._localRebel.quality])
        self._nameLabel:setText(self._localRebel.name)
        self._levelLabel:setText(self._rebel.level .. G_lang:get("LANG_FIGHTEND_GONGXI_AFTER"))
        self._bloodLabel:setText(G_GlobalFunc.ConvertNumToCharacter(self._rebel.hp) .. "/" .. G_GlobalFunc.ConvertNumToCharacter(self._rebel.max_hp))
        self._escapeTimeLabel = self:getLabelByName("Label_escapeTime")
        local panel = self:getPanelByName("Panel_knight")
        -- function KnightPic.createKnightPic( resId, parentWidget, name, hasShadow )
        self.bossImage = require("app.scenes.common.KnightPic").createKnightPic(self._localRebel.res_id,panel,nil,true)
        self.bossImage:setScale(0.8)
        self._bloodLoadingBar:setPercent(self:_getBossBloodPercent())
        self:_refreshBossStatus()
        if self._bossEffect == nil then
            local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
            self._bossEffect = EffectSingleMoving.run(panel, "smoving_idle", nil, {})
        end
    end



    -- self:getLabelByName("Label_tips01"):setText(G_lang:get("LANG_MOSHEN_TIPS01"))
    -- self:getLabelByName("Label_tips02"):setText(G_lang:get("LANG_MOSHEN_TIPS02"))
    -- self:getLabelByName("Label_tips03"):setText(G_lang:get("LANG_MOSHEN_TIPS03"))
end

function MoShenInfoDialog:_refreshBossStatus()
    --判断是否已被击杀
    if self._rebel.hp <= 0 then
        self.statusLabel:setVisible(true)
        self.statusLabel:setText(G_lang:get("LANG_MOSHEN_BOSS_STATUS_KILLED"))
        self.bossImage:showAsGray(true);
        self:showWidgetByName("Panel_time",false)
        if self._bossEffect ~= nil then
            self._bossEffect:stop()
            self._bossEffect = nil
        end
    else
        --判断是否已逃走
        local endTime = self._rebel["end"]
        endTime = G_ServerTime:getLeftSeconds(endTime)
        if endTime < 0 then
            self.statusLabel:setVisible(true)
            self.statusLabel:setText(G_lang:get("LANG_MOSHEN_BOSS_STATUS_ESCAPE"))
            self:showWidgetByName("Panel_time",false)
            self.bossImage:showAsGray(true);
            if self._bossEffect ~= nil then
                self._bossEffect:stop()
                self._bossEffect = nil
            end
        else
            self.statusLabel:setVisible(false)
            self.bossImage:showAsGray(false)
        end
    end
end

function MoShenInfoDialog:isBossKilled()
    if self._rebel == nil then
        return true
    end
    return self._rebel.hp <= 0
end

function MoShenInfoDialog:isBossEscape()
    if self._rebel == nil then
        return true
    end
    --判断是否已逃走
    local endTime = self._rebel["end"]
    endTime = G_ServerTime:getLeftSeconds(endTime)
    if endTime < 0 then
       return true
    else
        return false
    end
end


function MoShenInfoDialog:_createStrokes()
    self._nameLabel:createStroke(Colors.strokeBrown,2)
    self._levelLabel:createStroke(Colors.strokeBrown,2)
    self._bloodLabel:createStroke(Colors.strokeBrown,2)
    self.statusLabel:createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_xiaohaoNormalTag"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_xiaohaoNormal"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_xiaohaoTag"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_xiaohao"):createStroke(Colors.strokeBrown,1)
end

--开始计算逃走倒计时时间
function MoShenInfoDialog:_addEscapeTimer()
    self._timerHandler = G_GlobalFunc.addTimer(1, function()
        self:_onRefreshEscapeTime()
        self:_refreshBossStatus()
    end)
end

function MoShenInfoDialog:_onRefreshEscapeTime()
    if self._rebel ~= nil then
        local endTime = self._rebel["end"]
        if endTime == nil then
            return
        end
        endTime = G_ServerTime:getLeftSecondsString(endTime)
        self._escapeTimeLabel:setText(endTime)
    end
    self:_checkTime()
end

function MoShenInfoDialog:_initButtonEvent()
    self:registerBtnClickEvent("Button_close",function()
        self:animationToClose()
    end)
    self:registerBtnClickEvent("Button_buy",function()
        self:_toBuy()
    end)
    
    --普通攻击
    self:registerBtnClickEvent("Button_putong",function()
        --判断是否已被击杀
        if self:isBossKilled() then 
            G_MovingTip:showMovingTip(G_lang:get("LANG_MOSHEN_BOSS_IS_KILLED"))
            return
        end

        --判断叛军是否已经逃走
        if self:isBossEscape() then
            G_MovingTip:showMovingTip(G_lang:get("LANG_MOSHEN_BOSS_IS_ESCAPE"))
            return
        end

        --判断出征令数量
        if G_Me.userData.battle_token == 0 then
            self:_toBuy()
            return
        end

        G_HandlersManager.moshenHandler:sendAttackRebel(self._rebel.user_id,moShenConst.ATTACK_REBEL.NORMAL)
    end)
    
    --全力一击
    self:registerBtnClickEvent("Button_quanli",function()
        --判断是否已被击杀
        if self:isBossKilled() then
            G_MovingTip:showMovingTip(G_lang:get("LANG_MOSHEN_BOSS_IS_KILLED"))
            return
        end

        --判断叛军是否已经逃走
        if self:isBossEscape() then
            G_MovingTip:showMovingTip(G_lang:get("LANG_MOSHEN_BOSS_IS_ESCAPE"))
            return
        end

        --判断出征令数量 ,处于减半状态
        if self._isHalfActivity == true then
            if G_Me.userData.battle_token < 1 then
                self:_toBuy()
                return
            end 
        else
            if G_Me.userData.battle_token < 2 then
                self:_toBuy()
                return
            end
        end
        G_HandlersManager.moshenHandler:sendAttackRebel(self._rebel.user_id,moShenConst.ATTACK_REBEL.SPECIAL)
    end)
    self:registerBtnClickEvent("Button_buzhen",function()
        G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BUTTON_SHORT)
        require("app.scenes.hero.HerobuZhengLayer").showBuZhengLayer()
        end)
end

--购买出征令
function MoShenInfoDialog:_toBuy()
    -- local ShopVipConst = require("app.const.ShopVipConst")
    -- local layer = require("app.scenes.common.PurchaseScoreDialog").show(ShopVipConst.CHU_ZHENG_LING)
    G_GlobalFunc.showPurchasePowerDialog(3)
end

function MoShenInfoDialog:_getBossBloodPercent()
    if self._rebel == nil then 
        return 0
    end
    local result =  self._rebel.hp/self._rebel.max_hp*100 
    return result-result%1
end

function MoShenInfoDialog:_getMaxBattleToken()
    require("app.cfg.basic_figure_info")
    require("app.const.FigureType")
    local count = basic_figure_info.get(TYPE_CHUZHENG).time_limit
    return count
end


function  MoShenInfoDialog:_getRoleInfo( ... )
    -- body
    self._chuzhenlingCountLabel:setText(G_Me.userData.battle_token .. "/" .. self:_getMaxBattleToken())
end

--获取攻击boss的结果消息
function MoShenInfoDialog:_getAttackRebel(data)
    
    if data.ret == 1 then
        self._rebel.hp = self._rebel.hp -data.harm
        if self._rebel.hp <= 0 then
            self._rebel.hp = 0
            self._rebel["status"] = 1
        end
        local battleConst = require("app.const.BattleConst")
        --攻击倍数
        local _attack_multiple = 0
        if data.mode == moShenConst.ATTACK_REBEL.NORMAL then
            _attack_multiple = moShenConst.ATTACK_MULTIPLE.NORMAL
        else
            _attack_multiple = moShenConst.ATTACK_MULTIPLE.SPECIAL
        end
        G_Loading:showLoading(function ( ... )
            if self==nil or self._rebel == nil or self._rebel.level == nil or data == nil then
                return
            end
            --创建战斗场景
            self.scene = require("app.scenes.moshen.MoShenBattleScene").new(self._rebel.level,data.report,data.mode,_attack_multiple,function()
                self:_showAward(data)
                end, data.harm, data.exploit)
            uf_sceneManager:pushScene(self.scene)
        end, 
        function ( ... )
            if self and self.scene ~= nil and self.scene.play ~= nil then
                self.scene:play()
            end
            --开始播放战斗
        end)

    end
end

--购买结果处理
function MoShenInfoDialog:_getBuyResult(data)
    if data.ret == 1 then 
        G_MovingTip:showMovingTip(G_lang:get("LANG_BUY_SUCCESS"))
    end
end

function MoShenInfoDialog:_getPublicRebel(data)
    if data.ret == 1 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_MOSHEN_SHARE_SUCCESS"))
    end
end

function MoShenInfoDialog:_showAward(data)
    local FightEnd = require("app.scenes.common.fightend.FightEnd")
    local picks = nil
    local zhangong = data.award.size
    local t = 
    {
        damage=data.harm,
        gongxun=data.exploit,
        zhangong = zhangong,
        gongxunRank = G_Me.moshenData:getGongXunRank(),
        lastGongxunRank = G_Me.moshenData:getLastGongXunRank(),
        harmRank = G_Me.moshenData:getHarmRank(),
        lastHarmRank = G_Me.moshenData:getLastHarmRank()
    }
    G_Me.moshenData:setLastGongXunRank(G_Me.moshenData:getGongXunRank())
    G_Me.moshenData:setLastHarmRank(G_Me.moshenData:getHarmRank())
    FightEnd.show(FightEnd.TYPE_MOSHEN,true,t,function()
        uf_sceneManager:popScene()

        if data.public == true then

            MessageBoxEx.showYesNoMessage( nil, G_lang:get("LANG_MOSHEN_INVITE_FRIENDS"), false, function()
                G_HandlersManager.moshenHandler:sendPublicRebel() 
                end, nil, self )
        end 
        --抛出消息,通知moshenLayer刷新
        self._bloodLabel:setText(G_GlobalFunc.ConvertNumToCharacter(self._rebel.hp) .. "/" .. G_GlobalFunc.ConvertNumToCharacter(self._rebel.max_hp))
        self._bloodLoadingBar:setPercent(self:_getBossBloodPercent())
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_MOSHEN_REFRESH_STATUS, nil, false)
        end)
end

function MoShenInfoDialog:_removeEscapeTimer()
    if self._timerHandler ~= nil then
        G_GlobalFunc.removeTimer(self._timerHandler)
    end
end

--检查时间
function MoShenInfoDialog:_checkTime()
    -- local len = rebel_special_event_info.getLength()
    local tips01Label = self:getLabelByName("Label_tips01")
    local time01Label = self:getLabelByName("Label_time01")
    local isActivity,inTime,_time,tips = self:_getEventTimeAndBuff(1)
    if isActivity then --先判断征讨令活动中
        if G_Me.activityData.custom:isZhengtaoActive() then
            self._isHalfActivity = true
            time01Label:setText(G_lang:get("LANG_MOSHEN_BUFF_ACTIVITY"))
            self:getImageViewByName("Image_left"):loadTexture("ui/moshen/kaiqi_bg.png")
            time01Label:setColor(Colors.lightColors.TIPS_01)
            tips01Label:setColor(Colors.lightColors.TIPS_01)
            self:getLabelByName("Label_tips01")
            self:getLabelByName("Label_xiaohao"):setText("1")
        elseif inTime then
            self._isHalfActivity = true
            time01Label:setText(_time)
            self:getImageViewByName("Image_left"):loadTexture("ui/moshen/kaiqi_bg.png")
            time01Label:setColor(Colors.lightColors.TIPS_01)
            tips01Label:setColor(Colors.lightColors.TIPS_01)
            self:getLabelByName("Label_xiaohao"):setText("1")
        else
            time01Label:setText(_time)
            self:getImageViewByName("Image_left"):loadTexture("ui/moshen/weikaiqi_bg.png")
            time01Label:setColor(Colors.lightColors.DESCRIPTION)
            tips01Label:setColor(Colors.lightColors.DESCRIPTION)
            self:getLabelByName("Label_xiaohao"):setText("2")
        end
    end
    local tips02Label = self:getLabelByName("Label_tips02")
    local time02Label = self:getLabelByName("Label_time02")
    isActivity,inTime,_time,tips = self:_getEventTimeAndBuff(3)
    if isActivity then --先判断功勋翻倍活动中
        if G_Me.activityData.custom:isGongxunActive() then
            time02Label:setText(G_lang:get("LANG_MOSHEN_BUFF_ACTIVITY"))
            self:getImageViewByName("Image_right"):loadTexture("ui/moshen/kaiqi_bg.png")
            time02Label:setColor(Colors.lightColors.TIPS_01)
            tips02Label:setColor(Colors.lightColors.TIPS_01)
        elseif inTime then
            time02Label:setText(_time)
            self:getImageViewByName("Image_right"):loadTexture("ui/moshen/kaiqi_bg.png")
            time02Label:setColor(Colors.lightColors.TIPS_01)
            tips02Label:setColor(Colors.lightColors.TIPS_01)
        else
            time02Label:setText(_time)
            self:getImageViewByName("Image_right"):loadTexture("ui/moshen/weikaiqi_bg.png")
            time02Label:setColor(Colors.lightColors.DESCRIPTION)
            tips02Label:setColor(Colors.lightColors.DESCRIPTION)
        end
    end
end

function MoShenInfoDialog:_getEventTimeAndBuff(_id)
    local hour,minute,second = G_ServerTime:getCurrentHHMMSS()
    local seconds = hour*3600+minute*60+second

    local event = rebel_special_event_info.get(_id)
    local startHour = math.floor(event.open/3600)
    local startMin = math.floor((event.open - startHour*3600)/60)
    local endHour = math.floor(event.end_time/3600)
    local endMin = math.floor((event.end_time - endHour*3600)/60)

    local isActivity = event.open ~= event.end_time   --活动是否有效
    local inTime = seconds >= event.open and seconds <= event.end_time
    return isActivity,inTime,string.format("%02d:%02d-%02d:%02d",startHour,startMin,endHour,endMin),event.directions
end




function MoShenInfoDialog:onLayerUnload()
    uf_eventManager:removeListenerWithTarget(self)
    self:_removeEscapeTimer()
end

function MoShenInfoDialog:onLayerEnter()
    if self._isFirstTime == true then
        self._isFirstTime = false
        require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    end
    self:closeAtReturn(true)
end

return MoShenInfoDialog

