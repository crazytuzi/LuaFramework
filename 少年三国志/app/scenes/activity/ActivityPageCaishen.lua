require("app.cfg.activity_money_info")
local EffectNode = require "app.common.effects.EffectNode"
local ActivityPageCaishen = class("ActivityPageWine", UFCCSNormalLayer )
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"


ActivityPageCaishen.MAX_CAISHEN_COUNT = 6

function ActivityPageCaishen.create(...)
    return ActivityPageCaishen.new("ui_layout/activity_ActivityCaishen.json")
end


function ActivityPageCaishen:onLayerEnter()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ACTIVITY_DATA_CAISHEN_UPDATED, self._onCaishenUpdated, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ACTIVITY_FINISH_CAISHEN, self._onCaishenFinish, self) 

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, self.updatePage, self) 

    self._timer = GlobalFunc.addTimer(1, 
        function() 
        
            self:updateCountdown()
            -- self:_updateButtion()
        end
    )
    self:_setPanziEffect()

end

function ActivityPageCaishen:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)

    if self._timer then
        GlobalFunc.removeTimer(self._timer )
        self._timer =nil

    end

    if self._emiter then
        self._emiter:removeFromParentAndCleanup(true)
        self._emiter = nil
    end
end

function ActivityPageCaishen:ctor(...)
    self.super.ctor(self, ...)
    -- self:getLabelByName( "Label_title3"):setText(G_lang:get("LANG_ACTIVITY_CAISHEN_TITLE3"))
    self._panziEffectList = {}

    self:getLabelByName( "Label_title5"):setText(G_lang:get("LANG_ACTIVITY_CAISHEN_TITLE5"))
    self:getLabelByName( "Label_title5_2"):setText(G_lang:get("LANG_ACTIVITY_CAISHEN_TITLE5_2"))
    --气泡文字
    self._tipsLabel = self:getLabelByName("Label_tips")
    -- self:getLabelByName("Label_title3"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_title5"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_title5_2"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_jubaopen"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_next_countdown"):createStroke(Colors.strokeBrown,1)

    self:getLabelByName("Label_has"):createStroke(Colors.strokeBrown,1)
    self:attachImageTextForBtn("Button_go","Image_go")

    self:registerBtnClickEvent("Button_go",function()
       if G_Me.activityData.caishen:isActivate() then
           self:_startCaishen()
       end
    end)
    self:registerBtnClickEvent("Button_panzi",function()
        local total_count = G_Me.activityData.caishen.total_count
        if total_count > 0 and total_count <= ActivityPageCaishen.MAX_CAISHEN_COUNT then
            require("app.scenes.activity.CaiShenDialog").show()
        end
        end)

    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        local bgImage = self:getImageViewByName("Image_1")
        self._bgEffect01 = EffectNode.new("effect_cs", function(event, frameIndex)
                    end)  
        self._bgEffect01:setPosition(ccp(0,0))
        bgImage:addNode(self._bgEffect01)
        self._bgEffect01:play()
        self._bgEffect02 = EffectNode.new("effect_star_cs", function(event, frameIndex)
                    end)  
        self._bgEffect02:setPosition(ccp(0,0))
        bgImage:addNode(self._bgEffect02)
        self._bgEffect02:play()
    end
end

function ActivityPageCaishen:adapterLayer()
    
end

function ActivityPageCaishen:updateCountdown()
    --倒计时
    local txt = G_ServerTime:getLeftSecondsString(G_Me.activityData.caishen.next_time)
    if txt == '-' or txt == "00:00:00" then
        txt = ""
    end
    self:getLabelByName( "Label_next_countdown"):setText(txt)

    if G_Me.activityData.caishen.today_count >= 3 then
        self:getLabelByName( "Label_next_countdown"):setVisible(false)
    else
        self:getLabelByName( "Label_next_countdown"):setVisible(true)
    end
    
end

function ActivityPageCaishen:_showQiPao()
    if G_Me.activityData.caishen.total_count == 7 then
        return
    end
    self:getImageViewByName("Image_qipao"):setScale(1)
    self:_createRichText()
    self:showWidgetByName("Image_qipao",true)
    if G_Me.activityData.caishen.total_count ~= 6 then
        -- self._sayEffect = EffectSingleMoving.run(self:getImageViewByName('Image_qipao'), "smoving_say", function(event) 
        --     self:showWidgetByName("Image_qipao",false)
        -- end, {position=true})
        GlobalFunc.sayAction(self:getImageViewByName('Image_qipao'),true)
    end 
end

function ActivityPageCaishen:_createRichText()
    if self._richText == nil then
        local tipsLabel = self:getLabelByName("Label_tips")
        local size = tipsLabel:getContentSize()
        self._richText = CCSRichText:create(size.width+50, size.height+50)
        self._richText:setFontSize(tipsLabel:getFontSize())
        self._richText:setFontName(tipsLabel:getFontName())
        local x,y = tipsLabel:getPosition()
        tipsLabel:setVisible(false)
        self._richText:setPosition(ccp(x+10,y+10))
        self:getImageViewByName("Image_qipao"):addChild(self._richText)
    end
    self._richText:clearRichElement()
    local record = G_Me.activityData.caishen:getCaiShenRecord()
    if not record then
        return
    end

    local total_count = G_Me.activityData.caishen.total_count
    local text = nil
    if total_count == ActivityPageCaishen.MAX_CAISHEN_COUNT then
        text = G_lang:get("LANG_CAISHEN_QIPAO_TIPS_LING_QU",{money=G_GlobalFunc.ConvertNumToCharacter3(record.total_reward)})
    else
        local leftTime = ActivityPageCaishen.MAX_CAISHEN_COUNT-total_count
        if leftTime > 0 then
            text = G_lang:get("LANG_CAISHEN_QIPAO_TIPS_NORMAL",{money=G_GlobalFunc.ConvertNumToCharacter3(record.total_reward),times=leftTime})
        end
    end
    if text then
        self._richText:appendXmlContent(text)
        self._richText:reloadData()
    end
end


function ActivityPageCaishen:_createJuBaoPenRichText()
    local tipsLabel = self:getLabelByName("Label_jubaopen")
    local text = nil
    local total_count = G_Me.activityData.caishen.total_count
    local record = G_Me.activityData.caishen:getCaiShenRecord()
    if record and total_count > 0 and total_count <= ActivityPageCaishen.MAX_CAISHEN_COUNT then
        tipsLabel:setVisible(true)
        if total_count == ActivityPageCaishen.MAX_CAISHEN_COUNT then
            text = G_lang:get("LANG_CAISHEN_JU_BAO_PENG_WEN_ZI02",{money=G_GlobalFunc.ConvertNumToCharacter3(record.total_reward)})
        else
            local leftTime = ActivityPageCaishen.MAX_CAISHEN_COUNT-total_count
            text = G_lang:get("LANG_CAISHEN_JU_BAO_PENG_WEN_ZI01",{money=G_GlobalFunc.ConvertNumToCharacter3(record.total_reward),times=leftTime})
        end
        tipsLabel:setText(text)
    else
        tipsLabel:setVisible(false)
    end
end


function ActivityPageCaishen:_clearPanziEffect()
    if self._panziEffectList ~= nil and #self._panziEffectList > 0 then
        for i,v in ipairs(self._panziEffectList) do
            v:removeFromParentAndCleanup(true)
        end
        self._panziEffect = {}
    end
end
function ActivityPageCaishen:_setPanziEffect()
    self:_createJuBaoPenRichText()
    local total_count = G_Me.activityData.caishen.total_count
    if self._panziEffectList ~= nil and #self._panziEffectList == 0 then
       self:_clearPanziEffect()
        self._panziEffectList = {}
    end
    if total_count >= (ActivityPageCaishen.MAX_CAISHEN_COUNT + 1) or total_count <= 0 then
        self:_clearPanziEffect()
        return
    end
    for i=1,total_count do
        local effect = EffectNode.new(string.format("effect_coin_%d_cs",i), function(event, frameIndex)
                    end)  
        effect:setPosition(ccp(0,0))
        self:getImageViewByName("Image_1"):addNode(effect)
        effect:play()
        table.insert(self._panziEffectList,effect)
    end 
end

function ActivityPageCaishen:_isFinshed()   
    local total = ActivityPageCaishen.MAX_CAISHEN_COUNT + 1
    local total_count = G_Me.activityData.caishen.total_count

    if total_count == total  then
        return true
    end


    return false

end

function ActivityPageCaishen:_startCaishen()   
    G_HandlersManager.activityHandler:sendWorship()   
end


function ActivityPageCaishen:updatePage()
    local record = G_Me.activityData.caishen:getCaiShenRecord()
    local all_reward = 0
    if record then
        all_reward = record.total_reward
    end

    -- 最后一次领奖返回的是7
    local today_count = G_Me.activityData.caishen.today_count>3 and 3 or G_Me.activityData.caishen.today_count
    self:getLabelByName( "Label_has"):setText(today_count .. "/3")
    --倒计时
    self:updateCountdown()
    --按钮
    self:_updateButton()
end

function ActivityPageCaishen:showPage()   
    G_HandlersManager.activityHandler:sendMrGuanInfo()   
end

function ActivityPageCaishen:_updateButton()   
    self:getButtonByName("Button_go"):setTouchEnabled(G_Me.activityData.caishen:isActivate())
    local total_count = G_Me.activityData.caishen.total_count
    if total_count == 0 or total_count == (ActivityPageCaishen.MAX_CAISHEN_COUNT + 1) then
        self:getButtonByName("Button_panzi"):setTouchEnabled(false)
    else
        self:getButtonByName("Button_panzi"):setTouchEnabled(true)
    end
end

function ActivityPageCaishen:_onCaishenUpdated()  
    local total_count = G_Me.activityData.caishen.total_count
    if total_count > 0 then
        self:callAfterFrameCount(2, function ( ... ) 
            if self and self._showQiPao then
                self:_showQiPao()
            end
        end)
    end  
   self:updatePage()
end

function ActivityPageCaishen:_onCaishenFinish(award)   
        local total_count = G_Me.activityData.caishen.total_count
        local total = ActivityPageCaishen.MAX_CAISHEN_COUNT + 1
        if total == total_count or total_count == 0 then
            -- self:callAfterFrameCount(10, function ( ... ) 
            --     G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_CAISHEN_OK_1", {money=record.single_reward}), {    movingStyle = "moving_texttip4_slow"})
            --     self:_setPanziEffect()
            -- end)

            -- local awards = {}
            -- if record.total_reward > 0 then 
            --     table.insert(awards, #awards + 1, {type=G_Goods.TYPE_MONEY, value=0, size = record.total_reward})
            -- end
            -- if record.type > 0 and record.size > 0 then 
            --     table.insert(awards, #awards + 1, {type=record.type, value=record.value, size = record.size_show})
            -- end
            local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(award, function ( ... )
            end)
            if self and self._setPanziEffect then
                 self:_setPanziEffect()
             end
            self:addChild(_layer)
        else
            self._emiter = CCParticleSystemQuad:create("particles/coin.plist")
            self._emiter:setPosition(ccp(display.cx, display.size.height-240))
            self:addChild(self._emiter)
            -- self:callAfterFrameCount(10, function ( ... ) 
            --     G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_CAISHEN_OK", {money1=record.single_reward,money2=record.total_reward}), {    movingStyle = "moving_texttip4_slow"})
            --     if self and self._setPanziEffect then
            --         self:_setPanziEffect()
            --     end
            -- end)
            -- local awards = {}
            -- if record.total_reward > 0 then 
            --     table.insert(awards, #awards + 1, {type=G_Goods.TYPE_MONEY, value=0, size = record.single_reward})
            -- end
            -- if record.type > 0 and record.size > 0 then 
            --     table.insert(awards, #awards + 1, {type=record.type, value=record.value, size = record.size})
            -- end
            local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(award, function ( ... )
                
            end)
            if self and self._setPanziEffect then
                 self:_setPanziEffect()
            end
            self:addChild(_layer)
        end
end

return ActivityPageCaishen

