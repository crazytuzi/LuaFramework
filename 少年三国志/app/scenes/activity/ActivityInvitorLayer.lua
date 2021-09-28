
local ActivityInvitorLayer = class("ActivityInvitorLayer",UFCCSNormalLayer)

require("app.cfg.spread_reward_info")
KnightPic = require("app.scenes.common.KnightPic")

function ActivityInvitorLayer.create(...)
    local layer = require("app.scenes.activity.ActivityInvitorLayer").new("ui_layout/activity_ActivityInvitorLayer.json", ...)
    return layer
end

function ActivityInvitorLayer:ctor(json,...)
    self.super.ctor(self, ...)

    self._heroPanel = self:getPanelByName("Panel_hero")
    self._scoreTitleLabel = self:getLabelByName("Label_scoreTitle")
    self._scoreValueLabel = self:getLabelByName("Label_scoreValue")
    self._contentLabel = self:getLabelByName("Label_content")
    self._txtNumLabel = self:getLabelByName("Label_txtNum")
    self._listPanel = self:getPanelByName("Panel_list")
    self._addButton = self:getButtonByName("Button_add")

    self._scoreValueLabel:createStroke(Colors.strokeBrown, 1)
    self._scoreTitleLabel:createStroke(Colors.strokeBrown, 1)
    self._txtNumLabel:createStroke(Colors.strokeBrown, 1)
    self._scoreTitleLabel:setText(G_lang:get("LANG_ACTIVITY_INVITOR_SCORETITLE"))
    self._contentLabel:setText(G_lang:get("LANG_ACTIVITY_INVITOR_CONTENT"))

    self:initHero()
    -- self:initScrollView()

    self:registerBtnClickEvent("Button_add", function()
        local gold = require("app.scenes.activity.ActivityInvitorGetScore").create()
        uf_sceneManager:getCurScene():addChild(gold)
    end)
    self:registerBtnClickEvent("Button_help", function()
        require("app.scenes.common.CommonHelpLayer").show({
            {title=G_lang:get("LANG_INVITOR_HELP_TITLE1"), content=G_lang:get("LANG_INVITOR_HELP_CONTENT1")},
            {title=G_lang:get("LANG_INVITOR_HELP_TITLE2"), content=G_lang:get("LANG_INVITOR_HELP_CONTENT2")},
            {title=G_lang:get("LANG_INVITOR_HELP_TITLE3"), content=G_lang:get("LANG_INVITOR_HELP_CONTENT3")},
            } )
    end)
    self:registerBtnClickEvent("Button_shop", function()
        require("app.const.ShopType")
        uf_sceneManager:pushScene(require("app.scenes.shop.score.ShopScoreScene").new(SCORE_TYPE.INVITOR,nil,nil,nil,
            GlobalFunc.sceneToPack("app.scenes.activity.ActivityMainScene", {G_Me.activityData:getInvitorIndex()})))
    end)
    self:registerBtnClickEvent("Button_tuiguang", function()
        local gold = require("app.scenes.activity.ActivityInvitorSure").create()
        uf_sceneManager:getCurScene():addChild(gold)
    end)
end

function ActivityInvitorLayer:onLayerEnter()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_INVITORDRAWLVLREWARD, self._onDrawReward, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_INVITORGETREWARDINFO, self._onGetInfo, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_INVITORDRAWSCOREREWARD, self._onGetScoreRsp, self)

end


function ActivityInvitorLayer:adapterLayer()
    self:adapterWidgetHeight("Panel_content","Panel_empty","",0,0)
    self:adapterWidgetHeight("Panel_list","Panel_top","",138,0)

    self:initScrollView()
end

function ActivityInvitorLayer:showPage()   
    G_HandlersManager.activityHandler:sendInvitorGetRewardInfo()
    self:updateView()
end

function ActivityInvitorLayer:_onGetScoreRsp( )
    self:updateView()
end

function ActivityInvitorLayer:updateView()   
    self:updateScore()
    self:updateScrollView()
end

function ActivityInvitorLayer:_onGetInfo(data)   
    self:updateView()
end

function ActivityInvitorLayer:_onDrawReward(data)   
    if data.ret == 1 then
        local info = spread_reward_info.get(data.rewardId)
        local award = {}
        for i = 1 , 4 do 
            if info["item_type"..i] > 0 then
                table.insert(award,#award+1,{type=info["item_type"..i],value=info["item_value"..i],size=info["item_size"..i]})
            end
        end
        local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(award)
        uf_notifyLayer:getModelNode():addChild(_layer,1000)
        self:updateView()
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, nil, false)
    end
end

function ActivityInvitorLayer:initScrollView()   
    if self._listView == nil then
        self._listView = CCSListViewEx:createWithPanel(self._listPanel, LISTVIEW_DIR_VERTICAL)
        self._listView:setSpaceBorder(0, 40)
        self._listView:setCreateCellHandler(function ( list, index)
            return require("app.scenes.activity.ActivityInvitorListCell").new(list, index)
        end)
        self._listView:setUpdateCellHandler(function ( list, index, cell)
            local data = G_Me.activityData.invitor.rewardList
            if  index < #data then
               cell:updateData(data[index+1]) 
            end
        end)
        self._listView:initChildWithDataLength( #G_Me.activityData.invitor.rewardList)
    end
end

function ActivityInvitorLayer:updateScrollView()   
    self._listView:refreshAllCell()
end

function ActivityInvitorLayer:initHero()   
    local resid = 12009
    self._heroPanel:removeAllChildrenWithCleanup(true)
    local hero = KnightPic.createKnightPic( resid, self._heroPanel, "hero",false)
    hero:setScale(0.7)
    -- local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
    -- self._bossEffect = EffectSingleMoving.run(hero, "smoving_idle", nil, {})
end

function ActivityInvitorLayer:updateScore()   
    self._scoreValueLabel:setText(G_Me.userData.invitor_score)

    self._txtNumLabel:setText(G_Me.activityData.invitor.totalNum)

    if G_Me.activityData.invitor.furScore > 0 then
        self._addButton:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeOut:create(1), CCFadeIn:create(1))))
    else
        transition.stopTarget(self._addButton)
        self._addButton:setOpacity(255)
    end
end

function ActivityInvitorLayer:updatePage()
    
end

function ActivityInvitorLayer:onLayerExit()
    -- if self._schedule then
    --     GlobalFunc.removeTimer(self._schedule)
    -- end
    uf_eventManager:removeListenerWithTarget(self)
    self.super:onLayerExit()
end

return ActivityInvitorLayer
