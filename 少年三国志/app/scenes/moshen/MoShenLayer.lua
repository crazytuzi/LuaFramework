local MoShenLayer = class("MoShenLayer",UFCCSNormalLayer)
local EffectNode = require "app.common.effects.EffectNode"
local FunctionLevelConst = require("app.const.FunctionLevelConst")
require("app.cfg.knight_info")
function MoShenLayer.create(scenePack, ...)
    local layer = MoShenLayer.new("ui_layout/moshen_MoShenLayer.json", nil, scenePack, ... )
    return layer
end

--适配写在这里
function MoShenLayer:adapterLayer()
    self:adapterWidgetHeight("Panel_bg","Panel_head","",0,0)
    self:adapterWidgetHeight("Panel_zero","Panel_head","",0,0)
end

function MoShenLayer:ctor(jsonFile, func, scenePack, autoShowAward, ...)
    self._isFirstTimerEnter = true
    self._autoShowAward = autoShowAward

    --获取到的叛军列表
    self._rebelList = {}
    self._rebelListIndex = {}

    self._mPageView = nil
    self.super.ctor(self, jsonFile, func, scenePack, ...)
    self:_initWidgets()
    self:_initPageView()
    self:_createStroke()
    self:_initBtnEvent()

    G_GlobalFunc.savePack(self, scenePack)

    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        --添加特效
        local bgImage = self:getImageViewByName("ImageView_bg")
        self._bgEffect01 = EffectNode.new("effect_pj", function(event, frameIndex)
                    end)  
        self._bgEffect01:setPosition(ccp(0,0))
        bgImage:addNode(self._bgEffect01)
        self._bgEffect01:play()
        self._bgEffect02 = EffectNode.new("effect_sunshine_pj", function(event, frameIndex)
                    end)  
        self._bgEffect02:setPosition(ccp(0,0))
        bgImage:addNode(self._bgEffect02)
        self._bgEffect02:play()
    end
end


function MoShenLayer:_initWidgets()
    self:getImageViewByName("Image_16"):loadTexture("ui/text/txt/panjunqinru.png")

    self.gongxunRankLabel = self:getLabelByName("Label_gongxunRank")
    self.shanghaiRankLabel = self:getLabelByName("Label_shanghaiRank")
    self.gongxunLabel = self:getLabelByName("Label_gongxunValue")

    local btnRebelBoss = self:getButtonByName("Button_RebelBoss")
    btnRebelBoss:setVisible(G_moduleUnlock:canPreviewModule(FunctionLevelConst.REBEL_BOSS))

    local tInitInfo = G_Me.moshenData:getInitializeInfo()
    -- 叛军Boss开始阶段，才显示特效
    if tInitInfo._nState == 1 then
        self:_addEffect(btnRebelBoss)
    end
    

    if not G_moduleUnlock:isModuleUnlock(FunctionLevelConst.REBEL_BOSS) then
        self:showWidgetByName("Image_RebelBossTip", false)
    else
        local hasAward = false
        local hasChallengeTime = false
        for i=1, 3 do
            if G_Me.moshenData:hasRebelBossAward(i) then
                hasAward = true
                break
            end
        end
        if G_Me.moshenData:hasRebelBossChallengeTime() then
            hasChallengeTime = true
        end
        if hasAward or hasChallengeTime then
            self:showWidgetByName("Image_RebelBossTip", true)
        else
            self:showWidgetByName("Image_RebelBossTip", false)
        end
    end


end

function MoShenLayer:_initPageView()
    if self._mPageView == nil then
        local MoShenPageViewItem = require("app.scenes.moshen.MoShenPageViewItem")
        local panel = self:getPanelByName("Panel_pageview")
        self._mPageView = CCSNewPageViewEx:createWithLayout(panel)
        self._mPageView:setPageCreateHandler(function ( page, index )
            return MoShenPageViewItem.new()
        end)
        self._mPageView:setPageTurnHandler(function ( page, index, cell )
        end)
        self._mPageView:setPageUpdateHandler(function ( page, index, cell )
            local _t = {
                self._rebelList[index*3+1],
                self._rebelList[index*3+2],
                self._rebelList[index*3+3],
            }
            cell:update(_t)
        end)
    end
end

function MoShenLayer:_createStroke()
    self.gongxunRankLabel:createStroke(Colors.strokeBrown,1)
    self.shanghaiRankLabel:createStroke(Colors.strokeBrown,1)
    self.gongxunLabel:createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_gongxunRankTag"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_shanghaiRankTag"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_gongxunTag"):createStroke(Colors.strokeBrown,1)
end


function MoShenLayer:_initBtnEvent()
    
    --排行榜
    self:registerBtnClickEvent("Button_rank",function()
        local layer = require("app.scenes.moshen.MoShenRankingList").create(G_Me.moshenData:getGongXunRank(),G_Me.moshenData:getHarmRank())
        uf_sceneManager:getCurScene():addChild(layer)
    end)
    --功勋奖励
    self:registerBtnClickEvent("Button_award",function()
        local layer = require("app.scenes.moshen.MoShenGongXunAward").create()
       uf_sceneManager:getCurScene():addChild(layer)
    end)
    
    --帮助
    self:registerBtnClickEvent("Button_help",function()
        local layer = require("app.scenes.moshen.MoShenDescriptionDialog").create()
        uf_sceneManager:getCurScene():addChild(layer)
    end)
    
    --邀请好友
    self:registerBtnClickEvent("Button_friend",function()
        local sug = require("app.scenes.friend.FriendSugListLayer").create()   
        uf_sceneManager:getCurScene():addChild(sug)
    end)
    
    self:registerBtnClickEvent("Button_shop",function()
        --积分商店
        require("app.const.ShopType")
        uf_sceneManager:pushScene(require("app.scenes.shop.score.ShopScoreScene").new(SCORE_TYPE.MO_SHEN))
    end)
    self:registerBtnClickEvent("Button_back",function()
        self:onBackKeyEvent()
    end)

    self:registerWidgetClickEvent("Image_qipao",function()
        uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.dungeon.DungeonMainScene").new())
        end)

    
    -- 世界Boss
    self:registerBtnClickEvent("Button_RebelBoss", function()
        local FunctionLevelConst = require("app.const.FunctionLevelConst")
        if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.REBEL_BOSS) then
            uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.moshen.rebelboss.RebelBossMainScene").new())
        end
    end)

end


--更新个人信息面板
function MoShenLayer:_updateMePanel()
--[[
    if G_Me.moshenData:getGongXunRank() ~= nil and G_Me.moshenData:getGongXunRank() ~= 0 then
        self.gongxunRankLabel:setText(G_Me.moshenData:getGongXunRank())
    else
        self.gongxunRankLabel:setText(G_lang:get("LANG_NOT_IN_RANKING_LIST"))
    end

    if G_Me.moshenData:getHarmRank() ~= nil and G_Me.moshenData:getHarmRank() ~= 0 then
        self.shanghaiRankLabel:setText(G_Me.moshenData:getHarmRank())
    else
        self.shanghaiRankLabel:setText(G_lang:get("LANG_NOT_IN_RANKING_LIST"))
    end

    self.gongxunLabel:setText(G_Me.moshenData:getGongXun())
    ]]
    if not G_Me.moshenData:checkEnterAward() then
        G_Me.moshenData:setLastGongXunRank(G_Me.moshenData:getGongXunRank())
        G_Me.moshenData:setLastHarmRank(G_Me.moshenData:getHarmRank())
    end
    
    -- 今日累计功勋
    local szGongXunRank = ""
    if G_Me.moshenData:getGongXunRank() ~= nil and G_Me.moshenData:getGongXunRank() ~= 0 then
        local nRank = G_Me.moshenData:getGongXunRank()
        szGongXunRank = G_lang:get("LANG_MOSHEN_LEVEL", {num=nRank})    
    else
        szGongXunRank = G_lang:get("LANG_NOT_IN_RANKING_LIST")
    end
    local nGongXun = G_GlobalFunc.ConvertNumToCharacter(G_Me.moshenData:getGongXun())
    local szGongXun = nGongXun .. "(" .. szGongXunRank .. ")"
    self.gongxunRankLabel:setText(szGongXun)

    -- 今日最高伤害
    local szHurtRank = ""
    if G_Me.moshenData:getHarmRank() ~= nil and G_Me.moshenData:getHarmRank() ~= 0 then
        local nRank = G_Me.moshenData:getHarmRank()
        szHurtRank = G_lang:get("LANG_MOSHEN_LEVEL", {num=nRank})
    else
        szHurtRank = G_lang:get("LANG_NOT_IN_RANKING_LIST")
    end
    local nHarm = G_GlobalFunc.ConvertNumToCharacter(G_Me.moshenData:getMaxHarm())
    local szHurt = nHarm .. "(" .. szHurtRank .. ")"
    self.shanghaiRankLabel:setText(szHurt)

    -- 战功
    self.gongxunLabel:setText(G_Me.userData.medal)
end

function MoShenLayer:_addRefreshTimer()
    if self._timerHandler ~= nil then
        G_GlobalFunc.removeTimer(self._timerHandler)
        self._timerHandler = nil
    end

    self._timerHandler = G_GlobalFunc.addTimer(3, function()
        if not G_NetworkManager:isConnected() then
            return
        end
        self:_sendRefreshRebelShow()
    end)
end

function MoShenLayer:_sendRefreshRebelShow()
    if self._rebelList == nil or #self._rebelList == 0 then
        return
    end
    local index = self._mPageView:getCurPageIndex()
    local last_att_id = {}
    local ids = {}
    self._last_att_id = {}
    for i=1,3 do
        local rebel = self._rebelList[index*3+i]
        if rebel ~= nil then
            table.insert(ids,rebel.user_id)
            table.insert(last_att_id,rebel.last_att_index)
        end
    end

    G_HandlersManager.moshenHandler:sendRefreshRebelShow(ids,last_att_id)
end

--[[一下是消息处理函数]]

function MoShenLayer:_onRefreshRebelShow(data)
    --data内部比对是否有被击杀的boss
    local tempList = {}
    if data.rebels ~= nil and #data.rebels ~= 0 then
        for i,v in ipairs(data.rebels) do
            -- self._rebelList[#self._rebelList+1] = v
            for k,rebel in ipairs(self._rebelList) do
                if v.user_id == rebel.user_id then
                    self._rebelList[k] = v
                    self._rebelListIndex[v.user_id] = v
                end
            end
            tempList[v.user_id] = v
        end
    end

    if data.rebel_ids ~= nil and #data.rebel_ids ~= 0 then
        for i,v in ipairs(data.rebel_ids) do
            if tempList[v] ~= nil then
                self._rebelListIndex[v].status = 0
            else
                --被击杀了
                self._rebelListIndex[v].status = 1
                self._rebelListIndex[v].hp = 0
            end
        end
    end

    if data.infos ~= nil and #data.infos ~= 0 then
        for i,v in ipairs(data.infos)do
            --暂时播放
            -- text, fonstSize, clr
            if v.name ~= G_Me.userData.name then
                -- local text = v.name .. "伤害:" .. v.harm
                local text = G_lang:get("LANG_MOSHEN_HARM_VALUE",{name=v.name,value=v.harm})
                G_flyAttribute.doAddRichtext(text,22,Colors.uiColors.GREEN)
            end
        end
        G_flyAttribute.play()
    end


    --刷新当前page boss状态
    if self and self._onRefreshRebel then
        self:_onRefreshRebel()
    end
    if self and self._addRefreshTimer then
        self:_addRefreshTimer()
    end
end
--进入此界面
function MoShenLayer:_enterRebelUIMsg(data)
    self:_updateMePanel()
end

--刷新个人信息面板
function MoShenLayer:_refreshRebel(data)
    if data.ret == 1 then
        self._rebelList = {}
        self._rebelListIndex = {}
        for i,v in ipairs(data.rebels) do
            if v.public == true or v.user_id == G_Me.userData.id then
                -- 如果发现者是自己，则把该叛军放在第一位，否则就按顺序放在队尾
                if v.user_id == G_Me.userData.id then
                    table.insert(self._rebelList, 1, v)
                else
                    self._rebelList[#self._rebelList+1] = v
                end

                -- #status: 0 - 正常状态; 1 - 被击杀; 2 - 逃跑
                v["status"] = 0
                self._rebelListIndex[v.user_id] = v 
            end 
        end

        local count = math.ceil(#self._rebelList/3)
        if count == nil or count == 0 then
            -- G_MovingTip:showMovingTip(G_lang:get("LANG_MOSHEN_NO_REBELS"))
            self:showWidgetByName("Panel_zero",true)
            local appstoreVersion = (G_Setting:get("appstore_version") == "1")
            local GlobalConst = require("app.const.GlobalConst")
            local knight = nil
            if appstoreVersion or IS_HEXIE_VERSION  then 
                knight = knight_info.get(GlobalConst.CAI_WEN_JI_HE_XIE_ID)
            else
                knight = knight_info.get(GlobalConst.CAI_WEN_JI_ID)
            end
            if knight then
                local heroPanel = self:getPanelByName("Panel_caiwenji")
                local KnightPic = require("app.scenes.common.KnightPic")
                KnightPic.createKnightPic( knight.res_id, heroPanel, "caiwenji",true )
                heroPanel:setScale(0.5)
                if self._smovingEffect == nil then
                    local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
                    self._smovingEffect = EffectSingleMoving.run(heroPanel, "smoving_idle", nil, {})
                end
            end

            self:showWidgetByName("Panel_bg",false)
            return
        else
            self:showWidgetByName("Panel_zero",false)
            self:showWidgetByName("Panel_bg",true)
        end 
        if self._mPageView ~= nil then
            self._mPageView:showPageWithCount(count or 0)
        end
        self:_sendRefreshRebelShow()
    end
end

--在此刷新红点
function MoShenLayer:_onRefreshTips()
    self:showWidgetByName("Image_tips",G_Me.moshenData:checkAwardSignEnabled())
end

--在这里刷新boss状态
function MoShenLayer:_onRefreshRebel()
    local index = self._mPageView:getCurPageIndex()
    local cell = self._mPageView:getPage(index)
    if cell ~= nil then
        local _t = {
            self._rebelList[index*3+1],
            self._rebelList[index*3+2],
            self._rebelList[index*3+3],
        }
        cell:update(_t)
    end
end


function MoShenLayer:onLayerLoad(...)
    self:registerKeypadEvent(true)
end

function MoShenLayer:onBackKeyEvent(...)
    local packScene = G_GlobalFunc.createPackScene(self)
    if packScene then 
       uf_sceneManager:replaceScene(packScene)
    else
       GlobalFunc.popSceneWithDefault("app.scenes.mainscene.PlayingScene")
    end

    return true
end

function MoShenLayer:onLayerEnter()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_MOSHEN_ENTER_REBEL_UI, self._enterRebelUIMsg, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_MOSHEN_REFRESH_REBEL, self._refreshRebel, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_MOSHEN_REFRESH_STATUS, self._onRefreshRebel, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_MOSHEN_REFRESH_REBEL_SHOW, self._onRefreshRebelShow, self)

    --下面2条协议是为了监听是否有奖励领取
    uf_eventManager:addEventListener(EventMsgID.EVENT_MOSHEN_GET_EXPLOIT_AWARD_TYPE, self._onRefreshTips, self)
    uf_eventManager:addEventListener(EventMsgID.EVENT_MOSHEN_GET_EXPLOIT_AWARD, self._onRefreshTips, self)
    if self._isFirstTimerEnter == true then
        self._isFirstTimerEnter = false
        G_HandlersManager.moshenHandler:sendEnterRebelUI()
        G_HandlersManager.moshenHandler:sendRefreshRebel()
    end
    self:_addRefreshTimer()
    --为了红点机制
    if not G_Me.moshenData:checkEnterAward() then
        G_HandlersManager.moshenHandler:sendGetExploitAwardType() 
    else
        self:_onRefreshTips()
    end 

    if self._autoShowAward then
        uf_funcCallHelper:callNextFrame(function()
            local layer = require("app.scenes.moshen.MoShenGongXunAward").create()
            uf_sceneManager:getCurScene():addChild(layer)
        end, self)

        self._autoShowAward = false
    end
end
function MoShenLayer:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
    if self._timerHandler ~= nil then
        G_GlobalFunc.removeTimer(self._timerHandler)
    end
end

function MoShenLayer:_addEffect(tParent)
    assert(tParent)
    local EffectNode = require "app.common.effects.EffectNode"
    local eff = tParent:getNodeByTag(33)
    if not eff then
        eff = EffectNode.new("effect_boss_tbtexiao", function(event, frameIndex)
  
        end)
        eff:play()
        tParent:addNode(eff, 0, 33)
    end
end
return MoShenLayer
	
