
local MonthFundMainLayer = class("MonthFundMainLayer",UFCCSNormalLayer)

require("app.cfg.month_fund_info")

local EffectNode = require "app.common.effects.EffectNode"

local MonthFundAwardItemNumPerLine = 5  --领奖列表每行显示奖励数目

local MonthFundTipColor = ccc3(102,0,0)

function MonthFundMainLayer.create(...)
    local layer = require("app.scenes.monthfund.MonthFundMainLayer").new("ui_layout/monthfund_MainLayer.json", ...)
    return layer
end

function MonthFundMainLayer:ctor(json,...)
    self.super.ctor(self, ...)

    self._awardId = 0
    self._awardList = nil
    self._awardListRefresh = false
    self._checkedIndex = 1
    self._showAround = {true,true}

    self:_initWidgets()
  
    self._schedule = G_GlobalFunc.addTimer(1, function()
        if self and self._refreshTimeCountDown then
            self:_refreshTimeCountDown()
        end
    end)

end

--购买阶段面板
function MonthFundMainLayer:_initPurchasePanel()
 
    self._purchasePanel = self:getPanelByName("Panel_purchaseStage")
    self._purchasePanel:setVisible(false)

    self._activatePanel = self:getPanelByName("Panel_activate")
    self._activatePanel:setVisible(false)

    self._noActivatePanel = self:getPanelByName("Panel_noActivate")
    self._noActivatePanel:setVisible(false)

    self._buyButton = self:getButtonByName("Button_buy")
    self._buyButton:setTouchEnabled(false)

    local effectNode = EffectNode.new("effect_around2")
    effectNode:setScale(1.6)
    effectNode:setPositionY(-3)
    effectNode:play()
    self._effectNode = effectNode
    self._buyButton:addNode(effectNode,100,100)

    self._activateButton = self:getButtonByName("Button_activate")
    self._activateButton:setTouchEnabled(false)

    self._viewAwardButton = self:getButtonByName("Button_viewAward")

    self._boughtImage = self:getImageViewByName("Image_yigoumai")
    self._boughtImage:setVisible(false)

    self:getLabelByName("Label_canBuy"):createStroke(MonthFundTipColor,2)

    self._openAwardLabel = self:getLabelByName("Label_openAward")
    self._openAwardLabel:createStroke(Colors.strokeBrown,1)
    self._openAwardLabel:setText("")

    self._openBuyTimerLabel = self:getLabelByName("Label_openBuyTimer")
    self._openBuyTimerLabel:createStroke(Colors.strokeBrown,1)
    self._openBuyTimerLabel:setText("")

    self._txtImg = self:getImageViewByName("Image_award")
    self._heroImg = self:getImageViewByName("Image_xiaozhushou")

end

--领奖阶段面板
function MonthFundMainLayer:_initAwardPanel()
   
    self._awardPanel = self:getPanelByName("Panel_awardStage")
    self._awardPanel:setVisible(false)

    self._awardListPanel = self:getPanelByName("Panel_awardList")
    --self._awardListPanel:setVisible(false)

    self._stopAwardLabel = self:getLabelByName("Label_stopAward")
    self._stopAwardLabel:createStroke(MonthFundTipColor,2)
    self._stopAwardLabel:setText("")

    

end


function MonthFundMainLayer:_initAwardList( ... )

    if self._awardListPanel == nil then
        return
    end

    if not self._awardList then 

        self._awardList = CCSListViewEx:createWithPanel(self._awardListPanel, LISTVIEW_DIR_VERTICAL)
        self._awardList:setCreateCellHandler(function ( list, index)
            return require("app.scenes.monthfund.MonthFundAwardItem").new(list, index)
        end)
        self._awardList:setUpdateCellHandler(function ( list, index, cell)
            --local count = month_fund_info.getLength()
            --if  index < count then
            if cell then
               cell:updateItem(index+1,self._checkedIndex,function (_id)
                    self._awardId = _id
               end) 
            end
        end)
        self._awardList:setSpaceBorder(0,100)
    end

    local count = month_fund_info.getLength()
    local itemSize = math.ceil(count/MonthFundAwardItemNumPerLine)

    self._awardList:reloadWithLength(itemSize)
end


function MonthFundMainLayer:_initWidgets()

    self:_initPurchasePanel()
    self:_initAwardPanel()

    self._tabs = require("app.common.tools.Tabs").new(2, self,self._checkedCallBack, self._uncheckedCallBack) 
    self._tabs:add("CheckBox_small", nil, "Label_small")
    self._tabs:add("CheckBox_normal", nil, "Label_normal")

    self:getWidgetByName("CheckBox_small"):setTouchEnabled(G_Me.monthFundData:hasOpen(1))
    self:getWidgetByName("CheckBox_normal"):setTouchEnabled(G_Me.monthFundData:hasOpen(2))

    self._tabs:checked(G_Me.monthFundData:hasOpen(1) and "CheckBox_small" or "CheckBox_normal")
    self._checkedIndex = G_Me.monthFundData:hasOpen(1) and 1 or 2

end

function MonthFundMainLayer:_checkedCallBack(btnName)
    if btnName == "CheckBox_small" then
        self._checkedIndex = 1
    elseif btnName == "CheckBox_normal" then
        self._checkedIndex = 2
    end
    self:updateView()
end

function MonthFundMainLayer:updateView()
    local imgUrl = {"ui/text/txt/yjj_lingqujiangli128.png","ui/text/txt/yjj_lingqujiangli.png"}
    local heroImgUrl = {"ui/activity/lipinma_caiwenji.png","ui/fund/daqiao.png"}
    self._txtImg:loadTexture(imgUrl[self._checkedIndex])
    self._heroImg:loadTexture(heroImgUrl[self._checkedIndex])

    if not G_Me.monthFundData:dataReady() then
        return
    end

    self._effectNode:setVisible(self._showAround[self._checkedIndex])

    --领奖阶段
    if G_Me.monthFundData:checkInAwardStage() then
        self:_updateAwardPanel()

    --购买阶段
    elseif G_Me.monthFundData:checkInBuyStage() then
        self:_updatePurchasePanel()
    --领奖过期
    elseif G_Me.monthFundData:getEndAwardCountDown() == 0 then
        if self._schedule then
            GlobalFunc.removeTimer(self._schedule)
            self._schedule = nil
        end
        
        self:_updateStopPurchasePanel()   
        self._openBuyTimerLabel:setText(G_lang:get("LANG_MONTH_FUND_STOP_AWARD"))

    --购买过期领奖未开始
    elseif G_Me.monthFundData:getEndBuyCountDown() == 0 then
        self:_updateNotOpenAwardPanel()   
    end

    if self._awardList then
        self._awardList:refreshAllCell()
    end
end

function MonthFundMainLayer:_uncheckedCallBack()
end

function MonthFundMainLayer:_initEvent()
    
    self:registerBtnClickEvent("Button_buy", function()

        --去掉按钮特效
        -- self._buyButton:removeAllNodes()
        self._showAround[self._checkedIndex] = false
        self._effectNode:setVisible(false)

        --双月卡是否激活
        if not G_Me.monthFundData:isActivate() then
            MessageBoxEx.showYesNoMessage(nil, G_lang:get("LANG_MONTH_FUND_GOTO_ACTIVATE"), nil , function() 
               uf_sceneManager:getCurScene():getMainLayer():showActivityPage("month_card",false)
            end, nil
            )
            return
        end

        if G_Me.monthFundData:hasBought(self._checkedIndex) then
            G_MovingTip:showMovingTip(G_lang:get("LANG_MONTH_FUND_HAS_BOUGHT"))
            return 
        end

        if G_Me.monthFundData:openBuy() then
            require("app.scenes.shop.recharge.RechargeLayer").show()
        else 
            G_MovingTip:showMovingTip(G_lang:get("LANG_MONTH_FUND_STOP_BUY"))
        end

    end)

    self:registerBtnClickEvent("Button_activate", function()
        uf_sceneManager:getCurScene():getMainLayer():showActivityPage("month_card",false)
    end)

    self:registerBtnClickEvent("Button_viewAward", function()
        require("app.scenes.monthfund.MonthFundAwardPreviewLayer").show(self._checkedIndex)
    end)

    self:registerBtnClickEvent("Button_help", function()
        require("app.scenes.common.CommonHelpLayer").show({
            {title=G_lang:get("LANG_MONTH_FUND_HELP_TITLE"), content=G_lang:get("LANG_MONTH_FUND_HELP_CONTENT")},
            } )
    end)

end

function MonthFundMainLayer:onLayerLoad(...)

    self:_initEvent()

    self:registerKeypadEvent(true)

end


function MonthFundMainLayer:onLayerEnter()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_MONTH_FUND_BASE_INFO, self._onGetMonthFundBaseInfo, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_MONTH_FUND_AWARD_INFO, self._onGetAwardInfo, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_MONTH_FUND_GET_AWARD, self._onGetAward, self)

    G_Me.monthFundData:initBaseInfo()
    G_HandlersManager.monthFundHandler:sendGetMonthFundBaseInfo()
  
end


function MonthFundMainLayer:onBackKeyEvent()
    uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
    return true
end

function MonthFundMainLayer:showPage()   
    

end


function MonthFundMainLayer:updatePage()
    
end


function MonthFundMainLayer:_refreshTimeCountDown()

    if not G_Me.monthFundData:dataReady() then
        return
    end

    --领奖阶段
    if G_Me.monthFundData:checkInAwardStage() then
        self:_updateAwardPanel()

        --优化购买阶段倒计时等待到领奖时间  无法立刻领取奖品的问题(需要重新进入活动界面)
        if self._awardList and self._awardListRefresh == false then
            G_HandlersManager.monthFundHandler:sendGetMonthFundAwardInfo()
            self._awardListRefresh = true
        end

    --购买阶段
    elseif G_Me.monthFundData:checkInBuyStage() then
        self:_updatePurchasePanel()
    --领奖过期
    elseif G_Me.monthFundData:getEndAwardCountDown() == 0 then
        if self._schedule then
            GlobalFunc.removeTimer(self._schedule)
            self._schedule = nil
        end
        
        self:_updateStopPurchasePanel()   
        self._openBuyTimerLabel:setText(G_lang:get("LANG_MONTH_FUND_STOP_AWARD"))

    --购买过期领奖未开始
    elseif G_Me.monthFundData:getEndBuyCountDown() == 0 then
        self:_updateNotOpenAwardPanel()   
    end
end

function MonthFundMainLayer:adapterLayer()
    self:adapterWidgetHeight("Panel_purchaseStage", "", "", 0, 0)
    self:adapterWidgetHeight("Panel_awardStage", "", "", 0, 0)

    -- self:adapterWidgetHeight("Panel_content1", "Panel_top1", "", 0, 0)
    -- self:adapterWidgetHeight("Panel_content2", "Panel_top2", "", 0, 0)

    self:_initAwardList()

end


function MonthFundMainLayer:onLayerExit()

    if self._schedule then
        GlobalFunc.removeTimer(self._schedule)
        self._schedule = nil
    end

    uf_eventManager:removeListenerWithTarget(self)
    self.super:onLayerExit()

end


function MonthFundMainLayer:_onGetMonthFundBaseInfo(data)

    if self._awardPanel ~= nil then
        self._awardPanel:setVisible(false)
    end

    if self._purchasePanel ~= nil then
        self._purchasePanel:setVisible(false)
    end

    --解决活动过期红点可能还在的问题
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, nil, false)

    if G_Me.monthFundData:dataReady() then

        if G_Me.monthFundData:checkInAwardStage() then
            G_HandlersManager.monthFundHandler:sendGetMonthFundAwardInfo()
        elseif G_Me.monthFundData:checkInBuyStage() then
            self:_updatePurchasePanel()
        else
            self:_updateNotOpenAwardPanel()   
        end
        --G_MovingTip:showMovingTip(G_lang:get("LANG_MONTH_FUND_ERROR_CONFIG"))
    --else
        --G_MovingTip:showMovingTip(G_lang:get("LANG_MONTH_FUND_ERROR_CONFIG"))
    else
        self:_updateStopPurchasePanel()
    end
    self:_updateTips()
end


function MonthFundMainLayer:_onGetAwardInfo(data)

    self:_updateAwardPanel()
    --self._awardListPanel:setVisible(true)
    self._awardList:refreshAllCell()
    
    self._awardListRefresh = true

    self:_updateTips()
end

function MonthFundMainLayer:_onGetAward(data)
   
    --更新单个cell更好
    self._awardList:refreshAllCell()
    self._awardListRefresh = true

    if self._awardId > 0 then
        local awardInfo = self._checkedIndex == 1 and month_fund_small_info.get(self._awardId) or month_fund_info.get(self._awardId)
        -- local awardInfo = month_fund_info.get(self._awardId)
        local awardData = {type=awardInfo.type ,value=awardInfo.value,size=awardInfo.size}
        local popLayer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create({awardData})
        uf_sceneManager:getCurScene():addChild(popLayer,1000)
        self._awardId = 0
    end

end

function MonthFundMainLayer:_updateNotOpenAwardPanel()
    self._awardPanel:setVisible(false)
    self._purchasePanel:setVisible(true)
    self._openBuyTimerLabel:setText(G_lang:get("LANG_MONTH_FUND_STOP_BUY"))
    self:getLabelByName("Label_canBuy"):setVisible(false)
    self._activatePanel:setVisible(false)
    self._noActivatePanel:setVisible(false)
    self._buyButton:setTouchEnabled(false)
    self:getImageViewByName("Image_buy"):showAsGray(true)
    self._buyButton:removeAllNodes()   

end

function MonthFundMainLayer:_updateStopPurchasePanel()

    self._awardPanel:setVisible(false)
    self._purchasePanel:setVisible(true)
    self._openBuyTimerLabel:setText(G_lang:get("LANG_MONTH_FUND_BUY_TIPS"))
    self:getLabelByName("Label_canBuy"):setVisible(false)
    self._openAwardLabel:setVisible(false)
    self._activatePanel:setVisible(false)
    self._noActivatePanel:setVisible(false)

end


function MonthFundMainLayer:_updatePurchasePanel()

    self._openBuyTimerLabel:setText(self:_getTimeString())

    self._awardPanel:setVisible(false)
    self._purchasePanel:setVisible(true)
    self._activatePanel:setVisible(false)
    self._noActivatePanel:setVisible(false)


    local award_time  = G_Me.monthFundData:getRewardStartTime()
    local award_date = G_ServerTime:getDateObject(award_time)
 
    local awardTimeString = G_lang:get("LANG_MONTH_FUND_AWARD_OPEN_FORMAT", 
        {year=award_date.year,month=award_date.month,day=award_date.day,hour=award_date.hour,min=award_date.min})
       
    self._openAwardLabel:setText(awardTimeString..G_lang:get("LANG_MONTH_FUND_AWARD_OPEN"))

    self._boughtImage:setVisible(false) 
    self._activateButton:setTouchEnabled(false)
    self._buyButton:setTouchEnabled(false)

    if G_Me.monthFundData:hasBought(self._checkedIndex) then
        self._activatePanel:setVisible(true)
        -- self._buyButton:removeAllNodes()
        self._buyButton:setVisible(false)
        self._boughtImage:setVisible(true)
    elseif G_Me.monthFundData:isActivate() then
        self._activatePanel:setVisible(true)
        self._buyButton:setTouchEnabled(true)
        self._buyButton:setVisible(true)
    else
        self._noActivatePanel:setVisible(true)
        self._activateButton:setTouchEnabled(true)
        self._buyButton:setVisible(true)
    end

end

function MonthFundMainLayer:_updateAwardPanel()
    self._stopAwardLabel:setText(self:_getTimeString())
    --self._awardList:refreshAllCell()
    self._purchasePanel:setVisible(false)
    self._awardPanel:setVisible(true)

    self:_updateTips()
end
function MonthFundMainLayer:_updateTips()
    self:getImageViewByName("Image_tips_small"):setVisible(G_Me.monthFundData:canGetAnyAward(1))
    self:getImageViewByName("Image_tips_normal"):setVisible(G_Me.monthFundData:canGetAnyAward(2))
end

function MonthFundMainLayer:_getTimeString()
    local timeStamp = 0
    local suffix = ""

    if G_Me.monthFundData:checkInBuyStage() then
        if G_Me.monthFundData:hasBought(self._checkedIndex) then
            --timeStamp = G_Me.monthFundData:getStartAwardCountDown()
            --suffix = G_lang:get("LANG_MONTH_FUND_OPEN_AWARD_TXT")
            return ""
        else
            timeStamp = G_Me.monthFundData:getEndBuyCountDown()
            suffix = G_lang:get("LANG_MONTH_FUND_CLOSE_BUY_TXT")
        end
        if timeStamp <= 0 then
            return G_lang:get("LANG_MONTH_FUND_STOP_BUY")
        end
    elseif G_Me.monthFundData:checkInAwardStage() then
        
        if not G_Me.monthFundData:hasBought(self._checkedIndex) then
            return G_lang:get("LANG_MONTH_FUND_BUY_TIPS")
        end

        local award_time  = G_Me.monthFundData:getRewardEndTime()
        local award_date = G_ServerTime:getDateObject(award_time)
 
        local awardTimeString = G_lang:get("LANG_MONTH_FUND_AWARD_CLOSE_FORMAT", 
            {year=award_date.year,month=award_date.month,day=award_date.day,hour=award_date.hour,min=award_date.min})

        return awardTimeString
    
    else
        return ""
    end
    
    local sec = timeStamp%60
    timeStamp = math.floor(timeStamp/60)
    local min = timeStamp%60
    timeStamp = math.floor(timeStamp/60)
    local hour = timeStamp%24
    timeStamp = math.floor(timeStamp/24)
    local day = timeStamp

    local timeString = ""

    if day > 0 then 
        timeString = timeString..G_lang:get("LANG_MONTH_FUND_LEFT_DAY",{num=day})
    end
    if hour > 0 then 
        timeString = timeString..G_lang:get("LANG_MONTH_FUND_LEFT_HOUR",{num=hour})
    end
    if min > 0 then 
        timeString = timeString..G_lang:get("LANG_MONTH_FUND_LEFT_MIN",{num=min})
    end
    if sec >0 then 
        timeString = timeString..G_lang:get("LANG_MONTH_FUND_LEFT_SEC",{num=sec})
    end

    return timeString..suffix
end

return MonthFundMainLayer
