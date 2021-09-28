require("app.const.ShopType")
local funLevelConst = require("app.const.FunctionLevelConst")


local FunctionLevelConst = require("app.const.FunctionLevelConst")
local MainScene = class("MainScene", UFCCSBaseScene)
local EffectNode = require "app.common.effects.EffectNode"

function MainScene:ctor( json, func, param1, param2, ...)
    self.super.ctor(self, json, func, param1, param2, ...)

    if patchMe and patchMe("main", self) then return end  

    self._hasWheelCall = false

    self._rootLayer = UFCCSNormalLayer.new("ui_layout/mainscene_MainScene.json")
    self:addUILayerComponent("RootLayer",self._rootLayer,true)    

    self._layer = UFCCSNormalLayer.new("ui_layout/mainscene_MainBtns.json")
    self:addUILayerComponent("MainLayer",self._layer,true)
    
    -- 更多按钮面板
    self.moreButtonLayer =  require("app.scenes.mainscene.MoreButtonLayer").create()
    self.moreButtonLayer:setVisible(false)
    self._layer:addChild(self.moreButtonLayer, 2)
    
    local open_manhua = (G_Setting:get("open_manhua") == "1")
    if not open_manhua then 
        self.moreButtonLayer:showWidgetByName("ImageView_Cartoon", false)
--        self.moreButtonLayer:showWidgetByName("ImageView_6586_0_0", false)
    end
    --self._layer:registerBtnClickEvent("jingjichang", handler(self, self._onArena))
   -- self._layer:registerBtnClickEvent("chengjiu", handler(self, self._onTower))   

    
    -- more layer btns
    --self._layer:registerBtnClickEvent("Button_moshen", handler(self, self._onMoShen))
    self.moreButtonLayer:registerBtnClickEvent("Button_Chat",handler(self, self.onChat))
    self.moreButtonLayer:registerBtnClickEvent("Button_Mail", handler(self, self._onMail))
    self.moreButtonLayer:registerBtnClickEvent("Button_Friend", handler(self, self._onFriend))
    self.moreButtonLayer:registerBtnClickEvent("Button_Vip", handler(self, self._onVip))
    --self.moreButtonLayer:registerBtnClickEvent("Button_union", handler(self, self._onUnion))
    self.moreButtonLayer:registerBtnClickEvent("Button_HandBook", handler(self, self._onHandBook))
    --self.moreButtonLayer:registerBtnClickEvent("Button_Fragment", handler(self, self._onFragment))
    --self.moreButtonLayer:registerBtnClickEvent("Button_Recycle", handler(self, self._onRecycle))
    self.moreButtonLayer:registerBtnClickEvent("Button_KnightShop", handler(self, self._onSecretShop))
    self.moreButtonLayer:registerBtnClickEvent("Button_setting", handler(self, self._onSetting))
    self.moreButtonLayer:registerBtnClickEvent("Button_TipsInfo", handler(self, self._onTipsInfo))
    self.moreButtonLayer:registerBtnClickEvent("Button_HallOfFrame", handler(self, self._onHallOfFrame))
    self.moreButtonLayer:registerBtnClickEvent("Button_Cartoon", handler(self, self._onCartoonClick))
    self.moreButtonLayer:getRootWidget():setName("moreButtonLayer")
    
    -- 觉醒
    self.moreButtonLayer:registerBtnClickEvent("Button_AwakenShop", handler(self, self._onAwakenShopClick))
    -- 称号系统
    self.moreButtonLayer:registerBtnClickEvent("Button_Title", handler(self, self._onTitleClick))
    -- 武将变身
    self.moreButtonLayer:registerBtnClickEvent("Button_KnightTransform", handler(self, self._onKnightTransformClick))
    
    -- top bar btns
    self._layer:registerBtnClickEvent("Button_activity", handler(self, self._onActivity))
    self._layer:registerBtnClickEvent("Button_day_task", handler(self, self._onDayTask))
    self._layer:registerBtnClickEvent("Button_SecretShop", handler(self, self._onSecretShop))
    self._layer:registerBtnClickEvent("Button_giftmail",handler(self, self._onButtonGiftMail))
	self._layer:registerBtnClickEvent("Button_Day7",handler(self, self._onButtonDay7))
	self._layer:registerBtnClickEvent("Button_fund",handler(self, self._onButtonFund))   
    self._layer:registerBtnClickEvent("Button_wheel",handler(self, self._onButtonWheel))   
    self._layer:registerBtnClickEvent("Button_union", handler(self, self._onUnion))     
    self._layer:registerBtnClickEvent("Button_rechargeMail", handler(self, self._onRechargeMail))
    self._layer:registerBtnClickEvent("Button_TimePrivilege",handler(self, self._onButtonTimePrivilege))
    self._layer:registerBtnClickEvent("Button_Invite", handler(self, self._onButtonInvite))
    self._layer:getRootWidget():setName("_layer")
    -- bottom btns
    --self.moreButtonLayer:registerBtnClickEvent("Button_Activity", handler(self, self._onActivity))
    self._layer:registerBtnClickEvent("Button_More", handler(self, self._onMoreBtn))
    --self._layer:registerBtnClickEvent("Button_Packbag", handler(self, self.onBag))
    self._layer:registerBtnClickEvent("Button_Knight", handler(self, self._onKnight))
    self._layer:registerBtnClickEvent("Button_Equipment", handler(self, self._onEquipment))
    self._layer:registerBtnClickEvent("Button_Treasure", handler(self, self._onTreasure))
    self._layer:registerBtnClickEvent("Button_mingxing", handler(self, self._onMingXing))
    self._layer:registerBtnClickEvent("Button_Recycle", handler(self, self._onRecycle))
    self._layer:registerBtnClickEvent("Button_recharge",function()
        require("app.scenes.shop.recharge.RechargeLayer").show()
        end)
    self._layer:showWidgetByName("Button_recharge",G_Setting:get("open_mainscene_recharge") == "1")

    --self._layer:registerScrollViewEvent("ScrollView_Button",handler(self, self.onScrollViewButtonEvent))
    --self._layer:registerScrollViewEvent("ScrollView_Knight",handler(self, self.onScrollViewKnightEvent))
    --self._layer:registerScrollViewEvent("ScrollView_Knight",handler(self, self.onScrollViewKnightEvent))
    
    --self._layer:showWidgetByName("Panel_16", false)
    -- function setBMFontText(name,txt)
    --     local _label = self._layer:getLabelBMFontByName(name)
    --     if _label then _label:setText(txt) end
    -- end
    
    --新邮件冒泡
    self._newMailBubble = self.moreButtonLayer:getImageViewByName("ImageView_newMailBubble")
    self._newMailTxt = self.moreButtonLayer:getLabelByName("Label_newMailTxt_0")
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_MAIL_NEW_COUNT, handler(self, self._onNewMailCount), self)
    --self:_updateNewMailCount()

    self._newRechargeMailBubble = self._layer:getImageViewByName("ImageView_newRechargeMailBubble")
    self._newRechargeMailTxt = self._layer:getLabelByName("Label_newRechargeMailTxt_0")
 
    --领奖中心
    self._newGiftMailButtion = self._layer:getButtonByName("Button_giftmail")
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GIFT_MAIL_NEW_COUNT, handler(self, self._onNewGiftMailCount), self)
    --self:_updateNewGiftMailCount()
    
    --名人堂红点
    self.moreButtonLayer:getImageViewByName("Image_Tips_HallOfFrame"):setVisible(G_Me.userData.hof_points>0 and G_moduleUnlock:isModuleUnlock(funLevelConst.HALLOFFRAME_SCENE))
    
    local img = self._rootLayer:getImageViewByName("ImageView_Circle")
    if img then
        local plate = require("app.scenes.mainscene.KnightTurnplateLayer").new()    
        plate:getRootWidget():setName("plate")
        plate:init(img:getContentSize(), param1 and true or false)
        img:addNode(plate)      

    end
    
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_MAINSCENE_CLOSEMOREBTN,self._closeMoreLayer,self)


    -- GlobalFunc.flyIntoScreenLR({self._layer:getWidgetByName("Button_Knight"), 
    --         self._layer:getWidgetByName("Button_Equipment"), 
    --         self._layer:getWidgetByName("Button_Treasure"), 
    --         self._layer:getWidgetByName("Button_Recycle"), 
    --         self._layer:getWidgetByName("Button_More")}, false, 0.15, 3, 50)



    -- local effectCloud = EffectNode.new("effect_cloud" )
    -- self._layer:getPanelByName("Panel_effect"):addNode(effectCloud)
    -- effectCloud:play()

    --武将和装备碎片变化的消息
    uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED,self._onBagChange,self)
    
    local bg = self._rootLayer:getImageViewByName("ImageView_bg")
    if bg then 
        bg:loadTexture(G_GlobalFunc.isNowDaily() and "ui/background/back_mainbt.png" or "ui/background/back_mainhy.png")
    end
end

function MainScene:_onMoreBtn()
    local bg = self.moreButtonLayer:getImageViewByName("ImageView_Bg")
    if not self.moreButtonLayer:isVisible() then
        self:rotateMoreBtn(180)
        bg:setScale(0)
        bg:runAction(CCScaleTo:create(0.2,1))
    end

    self.moreButtonLayer:setVisible(not self.moreButtonLayer:isVisible())
end


--@desc 旋转更多按钮
--@param angle 旋转角度
function MainScene:rotateMoreBtn(angle)
    local btn = self._layer:getButtonByName("Button_More")
    if btn then
        local sprite = btn:getVirtualRenderer()
        sprite = tolua.cast(sprite, CCSPRITE)
        sprite:runAction(CCRotateTo:create(0.2,angle))
    end
end


--@desc 关闭更多按钮页面
function MainScene:_closeMoreLayer()
    self:rotateMoreBtn(0)
    self.moreButtonLayer:hideMoreButton()
end

--@desc 收到包裹变化消息,检查下是否有显示
function MainScene:_onBagChange(_type,_)
    local BagConst = require("app.const.BagConst")
    if _type == BagConst.CHANGE_TYPE.FRAGMENT then
        if self and self._checkFragmentComposeable then
            self:_checkFragmentComposeable()
        end
    elseif _type == BagConst.CHANGE_TYPE.PROP then
        if self and self._checkMingXingEnabled then
            self:_checkMingXingEnabled() 
        end
    end
end

function MainScene:_openDefaultModel( ... )
    -- if self._defaultModel == "chat" then 
    --     if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.CHAT) then 
    --         return 
    --     end
    --     require("app.scenes.chat.ChatLayer").new("ui_layout/ChatPanel_MainPanel.json", Colors.modelColor, self._defaultParam1, self._defaultParam2)
    -- end
end

function MainScene:onSceneEnter()
    --保证主场景肯定有网络连接
    G_NetworkManager:checkConnection()
    
    G_Notice:clear()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_NOTICE, handler(self, self._recvNotice), self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_MSG_DIRTY_FLAG_CHANGED, self._onReceiveChatFlagChange, self)

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, self._onUpdatedActivityButton, self) 
   uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_INFO, self._onUpdatedFriendButton, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_LIST, self._onUpdatedFriendButton, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DAILYTASK_GETDAILYMISSION, self._onUpdatedDaytaskButton, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TARGET_INFO, self._onUpdatedTargetInfo, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FLUSH_ACTIVITY_INFO, self._onFlushActivityInfo, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FUND_INFO, self._updateTopBtns, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FUND_USER_FUND, self._onUpdatedFundButton, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_MAINSCENE_SECRET_SHOP_UPDATED, self._onUpdatedSecretShopButton, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_MAINSCENE_AWAKEN_SHOP_UPDATED, self._onUpdatedAwakenShopButton, self) 
    
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_FLAG_CAN_WORSHIP, self._updateUnionFlag, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_FLAG_HAVE_WORSHIP_AWARD, self._updateUnionFlag, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_FLAG_CAN_HIT_EGGS, self._updateUnionFlag, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_FLAG_HAVE_APPLY, self._updateUnionFlag, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_INFO, self._updateUnionFlag, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RICH_INFO, self._updateTopBtns, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WHEEL_INFO, self._updateTopBtns, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RICH_RANK, self._updateTopBtns, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WHEEL_RANK, self._updateTopBtns, self)

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TIME_PRIVILEGE_GET_OPEN_SERVER_SUCC, self._onGetServerOpenTimeSucc, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TIME_PRIVILEGE_MAIN_SCENE_SHOW_ICON, self._updateTopBtns, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_INVITATION, self._updateTopBtns, self)

    -- -- 如果从奖励邮件中收到称号激活道具。。。（是否有这个需求？）
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GIFT_MAIL_PROCESS, self._onUpdateTitleButton, self)
    

    G_SoundManager:playSound(require("app.const.SoundConst").GameSound.UI_SLIDER)
    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.MAIN)
    
    self._roleInfo = G_commonLayerModel:getMainRoleInfoLayer()
    self._speedBar = G_commonLayerModel:getSpeedbarLayer()

    self:addUILayerComponent("RoleInfoUI",self._roleInfo,true)
    self:addUILayerComponent("SpeedBar", self._speedBar,true)
    
    self:adapterLayerHeight(self._rootLayer,self._roleInfo,self._speedBar, 0,0)
    self:adapterLayerHeight(self._layer,self._roleInfo,self._speedBar, 0,0)

    GlobalFunc.flyIntoScreenLR({self._roleInfo}, true, 0.2, 2, 100)

    self._noticeLayer = require("app.scenes.notice.NoticeLayer").create()
    self:addChild(self._noticeLayer)

    self._speedBar:backMain()

    if G_GlobalFunc.isNowDaily() then 
        self:_startPlaySunshine(3)
    end

    self:_checkFragmentComposeable()
    self:_onUpdatedFriendButton()
    self:_onUpdatedActivityButton()
    self:_onUpdatedDaytaskButton()
    self:_checkMingXingEnabled()
    self:_onUpdatedFundButton()

    --self._layer:callAfterFrameCount(1, function ( ... )
        self:_updateUnionFlag()   
    --end)    

    -- 神秘商店
    self._secretBtn = self._layer:getButtonByName("Button_SecretShop")
    -- 默认不可见
    self._secretBtn:setVisible(false)
    
    -- vip动画
    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        local vipLabel = self._roleInfo:getLabelAtlasByName("LabelAtlas_VIP")
        if vipLabel then
            if not self._vipShine then
                self._vipShine = EffectNode.new("effect_vipshine", function(event, frameIndex) end)
                vipLabel:addNode(self._vipShine,1)
                self._vipShine:play()
            end
        end
    end

  
    self:_onUpdatedSecretShopButton()
    self:_onUpdatedAwakenShopButton()
    self:_onUpdateTitleButton()
    
    self:_updateNewMailCount()
    --self:_updateNewGiftMailCount()

    self:_updateTopBtns()
    --self:_onUpdateDays7Btn()
    --self:_onUpdateFundBtn()

    --进主界面拉数据，否则无法判断活动开启
    G_HandlersManager.wheelHandler:sendWheelInfo()
    G_HandlersManager.richHandler:sendRichInfo()

    GlobalFunc.flyIntoScreenLR({self._layer:getWidgetByName("Button_union"),
        self._layer:getWidgetByName("Button_Knight"), 
            self._layer:getWidgetByName("Button_Equipment"), 
            self._layer:getWidgetByName("Button_Treasure"), 
            self._layer:getWidgetByName("Button_mingxing"), 
            self._layer:getWidgetByName("Button_Recycle"), 
            self._layer:getWidgetByName("Button_recharge"),
            self._layer:getWidgetByName("Button_More")}, false, 0.15, 3, 50)

    --local effectCloud = EffectNode.new("effect_cloud" )
    --self._layer:getPanelByName("Panel_effect"):addNode(effectCloud)
    --effectCloud:play()

    if not G_topLayer and G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CHAT) then 
        G_topLayer = require("app.scenes.mainscene.TopLayer").create()

        if G_GuideMgr and G_GuideMgr:isCurrentGuiding() then 
            G_topLayer:_onGuideStart()
        end
    end

    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        G_GlobalFunc.showDayEffect(G_Path.DAY_NIGHT_EFFECT.MAIN_SCENE, self._rootLayer:getPanelByName("Panel_effect"))
    end

    self:_onReceiveChatFlagChange(G_HandlersManager.chatHandler:hasMsgDirty())
    
    -- 是否有武将/装备可回收
    self._layer:showWidgetByName("Image_recycle_tip", G_Me.bagData:hasKnightToRecycle() or G_Me.bagData:hasEquipmentToRecycle())
    
   
    -- 精英暴动
    local FunctionLevelConst = require("app.const.FunctionLevelConst")
    local unlockFlag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.HARD_DUNGEON_RIOT)
    if unlockFlag then
        if G_Me.hardDungeonData:isNeedRequestRiotChapterList() then
            -- 精英暴动拉取数据
            G_HandlersManager.hardDungeonHandler:sendGetRiotChapterList()
        end
    end
    
end


function MainScene:_onUpdatedSecretShopButton()
    print("dipatch _onUpdatedSecretShopButton")

    local FunctionLevelConst = require "app.const.FunctionLevelConst"
    local result = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.SECRET_SHOP)
    if result then
    
        if G_Me.shopData:shouldShowSecretShop() then
            self._secretBtn:setVisible(true)
            --self:_updateSecretShopButton()
            self:_updateTopBtns()
        end

    end    
end

function MainScene:_onUpdatedAwakenShopButton()
    print("dipatch _onUpdatedAwakenShopButton")

    local FunctionLevelConst = require "app.const.FunctionLevelConst"
    local result = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.AWAKEN)
    if result then
        self.moreButtonLayer:getImageViewByName("Image_awakenshop_tip"):setVisible(G_Me.shopData:shouldShowAwakenShop())
    end    

    self:_showNewTips()
end

function MainScene:_onUpdateTitleButton( ... )
    local FunctionLevelConst = require "app.const.FunctionLevelConst"
    local result = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.TITLE)
    if result then
        self.moreButtonLayer:getImageViewByName("Image_Title_Tip"):setVisible(G_Me.bagData:hasTitleToActivate())
        self:_showNewTips()
    end 
end
 
function MainScene:_onReceiveChatFlagChange( isDirty )
    if self.moreButtonLayer then 
        self.moreButtonLayer:callAfterFrameCount(1, function ( ... )
            -- self._layer:showWidgetByName("Image_tip_new", isDirty)
            self:_showNewTips()
            self.moreButtonLayer:showChatMsgDirtyFlag(isDirty)
        end)
    end
end

function MainScene:_showNewTips(show)
    show = show or false
    local newChatMsg = G_HandlersManager.chatHandler:hasMsgDirty()
    if newChatMsg then
        local storage = require("app.storage.storage")
        local info = storage.load(storage.path("setting.data"))
        local showFloatBtn = (info and info.show_chat_enable and info.show_chat_enable == 1)
        newChatMsg = not showFloatBtn
    end

    show = newChatMsg or show
    local count = G_Me.mailData:getNewMailCount()
    local hasActivity = G_Me.friendData:hasNew()
    local hasTitleToActivate = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.TITLE) and G_Me.bagData:hasTitleToActivate()
    local isAwakenNew = G_Me.shopData:shouldShowAwakenShop()
    local hasHofPt =  G_Me.userData.hof_points>0 and G_moduleUnlock:isModuleUnlock(funLevelConst.HALLOFFRAME_SCENE)
    local final = show or (count > 0) or hasActivity or hasTitleToActivate or isAwakenNew or hasHofPt
    --local hasNewCorp = show or G_Me.legionData:hasNewCorpInfo()
    self._layer:showWidgetByName("Image_tip_new", final)
end

-- 新的notice
function MainScene:_recvNotice()
    if self._noticeLayer == nil then
        return
    end

    if self._noticeLayer:isVisible() == false then
        self._noticeLayer:setVisible(true)
        self._noticeLayer:startMove()
    end
end

function MainScene:_checkFragmentComposeable()
    --检查是否有碎片可合成
    self._layer:showWidgetByName("Image_knightFragmentNum", G_Me.bagData:CheckKnightFragmentCompose())
    self._layer:showWidgetByName("Image_equipmentFragment", G_Me.bagData:CheckEquipmentFragmentCompose())
end


--检查三国志命星是否可点亮
function MainScene:_checkMingXingEnabled()
    if not G_moduleUnlock:isModuleUnlock(FunctionLevelConst.MING_XING_MODULE) then 
        self._layer:showWidgetByName("Image_mingxingTips",false)
        return
    end

    if G_Me.sanguozhiData:checkEnterSanguozhi() ==true then
        local count = G_Me.bagData:getSanguozhiFragmentCount()
        if count == 0 then
            self._layer:showWidgetByName("Image_mingxingTips",false)
            return
        end
        require("app.cfg.main_growth_info")
        local lastId = G_Me.sanguozhiData:getLastUsedId()
        local length = main_growth_info.getLength()
        if lastId == length then
            --已经全部点亮了
            self._layer:showWidgetByName("Image_mingxingTips",false)
            return
        end
        local data = main_growth_info.get(lastId+1)
        if count >= data.cost_num then
            self._layer:showWidgetByName("Image_mingxingTips",true)
            return
        end
    else
        self._layer:showWidgetByName("Image_mingxingTips",false)
    end

end

function MainScene:_startPlaySunshine(nextPlayTime)  
    if not require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        return 
    end      

    self:_removeSunshineTimer()
    self._sunshineTimter = GlobalFunc.addTimer(nextPlayTime, function() 
        self:_removeSunshineTimer()

        if self._effectSun == nil then
            self._effectSun =EffectNode.new("effect_sunshine", function(event) 
                if event == "finish" then
                    self._effectSun:stop()
                    self:_startPlaySunshine( math.random(0, 1)*20+10)
                end
            end)
            self._rootLayer:getPanelByName("Panel_effect"):addNode(self._effectSun)
        end

      
        self._effectSun:play()  
    end)

end

function MainScene:_removeSunshineTimer()
    if self._sunshineTimter ~= nil then
        GlobalFunc.removeTimer(self._sunshineTimter)
        self._sunshineTimter = nil 
    end 

end

function MainScene:onSceneExit(...)
    if self._vipShine then
        self._vipShine:removeFromParentAndCleanup(true)
    end
    uf_eventManager:removeListenerWithTarget(self)

    self:_removeSunshineTimer()

    self:removeComponent(SCENE_COMPONENT_GUI, "Notice")
    self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

function MainScene:onSceneUnload(...)
end

function MainScene:onScrollViewButtonEvent(widget,_type)
    if _type == SCROLLVIEW_EVENT_SCROLL_TO_RIGHT then
        self.btnLeftArrow:setVisible(true)
        self.btnRightArrow:setVisible(false)
    elseif _type == SCROLLVIEW_EVENT_SCROLL_TO_LEFT then
        self.btnRightArrow:setVisible(true)
        self.btnLeftArrow:setVisible(false)
    end
end

function MainScene:onScrollViewKnightEvent(widget,_type)
    if _type == SCROLLVIEW_EVENT_SCROLL_TO_RIGHT then
        self.KnightArrow:setVisible(false)
    elseif _type == SCROLLVIEW_EVENT_SCROLL_TO_LEFT then
        self.KnightArrow:setVisible(true)
    end
end

-- 武将
function MainScene:_onKnight(widget)

    uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroFosterScene").new())
end


-- 装备
function MainScene:_onEquipment(widget)


   uf_sceneManager:replaceScene(require("app.scenes.equipment.EquipmentMainScene").new())
end

-- 宝物
function MainScene:_onTreasure(widget)
    uf_sceneManager:replaceScene(require("app.scenes.treasure.TreasureMainScene").new())

end


function MainScene:_onFragment(widget)
   __LogTag(TAG,"技能")
   uf_sceneManager:replaceScene(require("app.scenes.fragment.FragmentScene").new())
end

-- 圣骑
function MainScene:_onHorse(widget)
   G_HandlersManager.battleHandler:sendBattleTest()
   uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECEIVE_BATTLE, self.onSettingCallBack, self)
end

-- setting
function MainScene:_onSetting( ... )
    require("app.scenes.mainscene.SettingLayer").showSetting()
    self:_closeMoreLayer()
end

-- 图鉴
function MainScene:_onHandBook(widget)
   local p = require("app.scenes.handbook.HandBookMainLayer").create()
   uf_sceneManager:getCurScene():addChild(p)
end

--魔神
function MainScene:_onMoShen(widget)
    __LogTag(TAG,"魔神")
    uf_sceneManager:replaceScene(require("app.scenes.moshen.MoShenScene").new())
end

-- 帮会
function MainScene:_onUnion(widget)
    if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.LEGION) then 
        return
    end

    local _enterCorp = function ( ... )
        if G_Me.legionData:hasCorp() then
            uf_sceneManager:replaceScene(require("app.scenes.legion.LegionScene").new())   
        else
            uf_sceneManager:replaceScene(require("app.scenes.legion.LegionListScene").new())   
        end    
    end

    if G_Me.legionData:hasCorp() then
        _enterCorp()
    else
        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_DETAIL, function ( ... )
            _enterCorp()
        end, self)
        G_HandlersManager.legionHandler:sendGetCorpDetail()
    end    
end

function MainScene:_onVip( ... )
    local p = require("app.scenes.vip.VipMainLayer").create()
    G_Me.shopData:setVipEnter(true)
    uf_sceneManager:getCurScene():addChild(p)
end

--每日任务
function MainScene:_onDayTask( ... )
    -- G_MovingTip:showMovingTip(G_lang:get("LANG_PLAY_LOCK"))
    -- local p = require("app.scenes.dailytask.DailytaskMainLayer").create(self)
    -- uf_sceneManager:getCurScene():addChild(p)
    uf_sceneManager:replaceScene(require("app.scenes.dailytask.EverydayMainScene").new())
end

-- 活动
function MainScene:_onActivity(widget)
    -- if 1 then 
    --     return G_MovingTip:showMovingTip(G_lang:get("LANG_GUANZHI_NOT_OPEN_TIP"))
    -- end
    uf_sceneManager:replaceScene(require("app.scenes.activity.ActivityMainScene").new())
end

-- 神秘商店
function MainScene:_onSecretShop(widget)

    local FunctionLevelConst = require "app.const.FunctionLevelConst"
    local result = G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.SECRET_SHOP)
    if result then
        uf_sceneManager:replaceScene(require("app.scenes.secretshop.SecretShopScene").new())
                
        -- 点击后隐藏按钮
        widget:setVisible(false)
    end
end

function MainScene:onChat(widget)
    if G_topLayer then 
         G_topLayer:onChatClick()
         self:_closeMoreLayer()
     else
        if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.CHAT) then 
            return 
        end
    end

    -- if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.CHAT) then 
    --     return 
    -- end

    -- local defaultChannel = 1
    -- local arr = G_HandlersManager.chatHandler:getNewMsgChannel() or {}
    -- if #arr > 0 then 
    --     defaultChannel = arr[1] or 1
    -- end
    -- local layer = require("app.scenes.chat.ChatLayer").new("ui_layout/ChatPanel_MainPanel.json", Colors.modelColor, defaultChannel)
    -- self:_closeMoreLayer()
end


function MainScene:_onFriend(widget)
     -- if 1 then 
     --     return G_MovingTip:showMovingTip(G_lang:get("LANG_GUANZHI_NOT_OPEN_TIP"))
     -- end
   print("on friend")
   -- self:addChild(require("app.scenes.friend.FriendListLayer").new("ui_layout/friend_FriendListLayer.json"))
   uf_sceneManager:replaceScene(require("app.scenes.friend.FriendMainScene").new())
end

function MainScene:_onTower(widget)
   print("on tower")
   uf_sceneManager:replaceScene(require("app.scenes.wush.WushScene").new())
end

function MainScene:_onArena(widget)
    if G_Me.userData.level < 30 then
        MessageBoxEx.showOkMessage("提醒", "该功能30级开启")
        return 
    end
    uf_sceneManager:replaceScene(require("app.scenes.arena.ArenaScene").new("layout/ArenaScene02.json"))
end


function MainScene:_onMail(widget)
    --require("app.scenes.mail.MailListLayer").showMailListLayer(self)
    uf_sceneManager:replaceScene(require("app.scenes.mail.MailScene").new())
end

function MainScene:_onRechargeMail(widget)
    uf_sceneManager:replaceScene(require("app.scenes.mail.MailScene").new(2))
end

function MainScene:onSetting(widget)

end

-- 回收
function MainScene:_onRecycle(widget)
    uf_sceneManager:replaceScene(require("app.scenes.recycle.RecycleScene").new())
--    G_HandlersManager.battleHandler:sendBattleTest()
--    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECEIVE_BATTLE, self.onSettingCallBack, self)
end

-- @desc 攻略
function MainScene:_onTipsInfo()
    uf_sceneManager:replaceScene(require("app.scenes.tipsinfo.TipsInfoList2Scene").new())
end


--命星
function MainScene:_onMingXing( )
    if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.MING_XING_MODULE) then 
        return
    end
    uf_sceneManager:replaceScene(require("app.scenes.sanguozhi.SanguozhiMainScene").new())
end

function MainScene:_KnightShop( ... )
    -- body
end

function MainScene:onSettingCallBack(message)
    uf_sceneManager:pushScene(require("app.scenes.battle.BattleScene").new({["msg"] = message}))
end

function MainScene:_onNewMailCount()
    if self and self._updateNewMailCount then
        self:_updateNewMailCount()
        self:_updateTopBtns()
    end
end

function MainScene:_updateNewMailCount()
    local count = G_Me.mailData:getNewMailCount()
    if count == 0 then
        self._newMailBubble:setVisible(false)
    else
        self._newMailBubble:setVisible(true)
        self._newMailTxt:setText(tostring(count))
    end
    self._newRechargeMailTxt:setText(tostring(G_Me.mailData:getNewRechargeMailCount()))
    self:_showNewTips()
end

function MainScene:_onNewGiftMailCount()
    self:_updateTopBtns()
    --self:_updateNewGiftMailCount()
    
    -- self:_updateSecretShopButton()

    -- self:_onUpdateDays7Btn()

    -- self:_onUpdateFundBtn()
end

function MainScene:_updateUnionFlag( ... )
    __Log("hasNewCorp:%d", G_Me.legionData:hasNewCorpInfo() and 1 or 0)
    if self._layer then
        self._layer:showWidgetByName("Image_tip_union", G_Me.legionData:hasNewCorpInfo())
    end

   -- self:_showNewTips()
end

function MainScene:_updateTopBtns( ... )
    local btn = self._layer:getButtonByName("Button_day_task")
    if not btn then 
        return 
    end

    local posx, posy = btn:getPosition()
    posx = posx + 7
    local size = btn:getSize()
    if self:_onUpdateFundBtn() then 
        btn = self._layer:getButtonByName("Button_fund")
        if btn then 
            posx, posy = btn:getPosition()
            posx = posx + 11
            size = btn:getSize()
        end
    end

    if self:_onUpdateDays7Btn(posx, posy, size) then 
        btn = self._layer:getButtonByName("Button_Day7")
        if btn then 
            posx, posy = btn:getPosition()
            posx = posx + 11
            size = btn:getSize()
        end
    end

    if self:_onUpdateTimePrivilege(posx, posy, size) then 
        btn = self._layer:getButtonByName("Button_TimePrivilege")
        if btn then 
            posx, posy = btn:getPosition()
            posx = posx + 11
            size = btn:getSize()
        end
    end


    if self:_updateSecretShopButton(posx, posy, size) then
        if self._secretBtn then 
            posx, posy = self._secretBtn:getPosition()
            posx = posx + 11
            size = self._secretBtn:getSize()
        end
    end

    self:_updateNewGiftMailCount(posx, posy, size)

    btn = self._layer:getButtonByName("Button_wheel")
    local posx2 = 0
    local posy2 = 0
    posx2, posy2 = btn:getPosition()
    posx2 = 7
    if self:_onUpdateWheelBtn() then 
        btn = self._layer:getButtonByName("Button_wheel")
        if btn then 
            -- posx2, posy2 = btn:getPosition()
            size = btn:getSize()
            posx2 = posx2 + size.width + 11
        end
    end

    if self:_updateNewRechargeMailCount(posx2, posy2) then
        btn = self._layer:getButtonByName("Button_rechargeMail")
        if btn then 
            size = btn:getSize()
            posx2 = posx2 + size.width + 11
        end
    end

    if self:_onUpdateInviteBtn(posx2, posy2, size) then
        btn = self._layer:getButtonByName("Button_Invite")
        if btn then
            size = btn:getSize()
            posx2 = posx2 + size.width + 11
        end
    end
end

function MainScene:_onUpdateDays7Btn( posx, posy, size )
    if not G_Me.days7ActivityData:isOpen() then 
        self._layer:showWidgetByName("Button_Day7", false)
        return false
    end

    self._layer:showWidgetByName("Button_Day7", true)
    local widget = self._layer:getWidgetByName("Button_Day7")
    if widget then 
        local widgetSize = widget:getSize()
--        __Log("Button_Day7:width:=%d", widgetSize.width)
        widget:setPositionXY(posx + size.width/2 + widgetSize.width/2, posy)
    end

    self._layer:showWidgetByName("Image_day7", G_Me.days7ActivityData:isOpen() and G_Me.days7ActivityData:hasAwardActivity())

    return true
end

function MainScene:_onUpdateTimePrivilege( posx, posy, size )
    if not G_Me.timePrivilegeData:isOpenFunction() then 
        self._layer:showWidgetByName("Button_TimePrivilege", false)
        return false
    end

    self._layer:showWidgetByName("Button_TimePrivilege", true)
    local widget = self._layer:getWidgetByName("Button_TimePrivilege")
    if widget then 
        local widgetSize = widget:getSize()
        widget:setPositionXY(posx + size.width/2 + widgetSize.width/2, posy)
    end

    local showTips = false
    if G_Me.timePrivilegeData:isOpenFunction() then
        if G_Me.timePrivilegeData:hasPrivilegeRecharge() or G_Me.timePrivilegeData:hasUnclaimedAward() or G_Me.timePrivilegeData:getGoodsRefreshedMark() then
            showTips = true
        end
    end
    self._layer:showWidgetByName("Image_TimePrivilege", showTips)

    return true
end


function MainScene:_updateNewRechargeMailCount( posx, posy )
    if G_Me.mailData:getNewRechargeMailCount() <= 0 then 
        self._layer:showWidgetByName("Button_rechargeMail", false)
        return false
    end

    self._layer:showWidgetByName("Button_rechargeMail", true)
    local widget = self._layer:getWidgetByName("Button_rechargeMail")
    if widget then 
        local widgetSize = widget:getSize()
--        __Log("Button_Day7:width:=%d", widgetSize.width)
        widget:setPositionXY(posx + widgetSize.width/2, posy)
    end
    return true
end

function MainScene:_onUpdateFundBtn(  )
    local widget = self._layer:getWidgetByName("Button_fund")
    if G_Me.fundData:needShow() then
        widget:setVisible(true)
        return true
    else
        widget:setVisible(false)
        return false
    end

    -- local Day7Buttion = self._layer:getButtonByName("Button_Day7")
    -- local posx, posy = Day7Buttion:getPosition()
    
    -- local size = Day7Buttion:getSize()
    -- posx = posx + size.width + 5
    -- if widget then 
    --     widget:setPositionXY(posx, posy)
    --    -- widget:setVisible(false)
    -- end
end

function MainScene:_onUpdateWheelBtn(  )
    local state = G_Me.richData:hasFinalAward() or G_Me.richData:hasAward() or G_Me.wheelData:hasFinalAward() 
    state = state or (G_Me.richData:getCurQuanNum()>0 and (G_Me.wheelData:getState() == 1 or G_Me.richData:getState() == 1))
    self._layer:showWidgetByName("Image_wheelTip", state)
    local state = G_Me.wheelData:getState() < 3 or G_Me.richData:getState() < 3
    self._layer:getWidgetByName("Button_wheel"):setVisible(state)
    return state
    -- G_Me.wheelData:initState()
    -- local widget = self._layer:getWidgetByName("Button_wheel")
    -- if G_Me.wheelData:getState() < 3 then
    --     if self._hasWheelCall == false then
    --         self._hasWheelCall = true
    --         self._layer:callAfterDelayTime(G_Me.wheelData:getTimeLeft(), nil, function ( ... )
    --             if G_SceneObserver:getSceneName() == "MainScene" then
    --                 self._hasWheelCall = false
    --                 self:_updateTopBtns()
    --             end
    --         end)
    --     end
    --     widget:setVisible(true)
    --     return true
    -- else
    --     if self._hasWheelCall == false then
    --         self._hasWheelCall = true
    --         self._layer:callAfterDelayTime(G_Me.wheelData:getTimeLeft(), nil, function ( ... )
    --             if G_SceneObserver:getSceneName() == "MainScene" then
    --                 self._hasWheelCall = false
    --                 self:_updateTopBtns()
    --             end
    --         end)
    --     end
    --     widget:setVisible(false)
    --     return false
    -- end
end

function MainScene:_onUpdateInviteBtn(posx, posy, size)
    local crossData = G_Me.crossWarData
    if (not crossData:isScoreMatchEnd() and not crossData:isInChampionship()) or not crossData:isChampionshipEnabled() or not crossData:isQualify() or crossData:getQualifyType() == 0 or crossData:hasClickedInvite() then
        self._layer:showWidgetByName("Button_Invite", false)
        return false
    end

    self._layer:showWidgetByName("Button_Invite", true)
    local widget = self._layer:getWidgetByName("Button_Invite")
    if widget then 
        widget:setPositionXY(posx + size.width/2, posy)
    end

    return true
end

function MainScene:_onFlushActivityInfo( ... )
    self:_updateTopBtns()
end

function MainScene:_updateSecretShopButton(posx, posy, size)
    
    if not self._secretBtn or not self._secretBtn:isVisible() then 
        return false
    end
    
    if self._secretBtn then 
        local widgetSize = self._secretBtn:getSize()
        self._secretBtn:setPositionXY(posx + size.width/2 + widgetSize.width/2, posy)
    end
    return true
    -- local btnGift = self._layer:getButtonByName("Button_giftmail")

    -- -- 此时神秘商店可见，并且需要判断当前的位置，如果有领奖中心，则位置不变，否则位置置于领奖中心的位置
    -- if not btnGift:isVisible() then
    --     -- 此时位置需要变化, 去领奖中心按钮位置
    --     self._secretBtn:setPositionX((btnGift:getPosition()))
    -- else
    --     -- 移动位置
    --     self._secretBtn:setPositionX(btnGift:getPosition() + 100)
    -- end

end

function MainScene:_updateNewGiftMailCount(posx, posy, size)
   local count = G_Me.giftMailData:getNewMailCount()
   if count == 0 then
       self._newGiftMailButtion:setVisible(false)
       return false
   end

   self._newGiftMailButtion:setVisible(true)
   local widgetSize = self._newGiftMailButtion:getSize()
   self._newGiftMailButtion:setPositionXY(posx + size.width/2 + widgetSize.width/2, posy)

   return true
end

--@desc 排行榜
function MainScene:_onHallOfFrame()
    if G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.HALLOFFRAME_SCENE) then
        uf_sceneManager:replaceScene(require("app.scenes.hallofframe.HallOfFrameScene").new())
    end
end

function MainScene:_onCartoonClick( ... )
    if G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.CARTOON_SHOW) then 
        require("app.scenes.mainscene.ManhuaLayer").create()
    end
end

--点击了领奖中心按钮
function MainScene:_onButtonGiftMail()

    local giftMailLayer = require("app.scenes.giftmail.GiftMailLayer").create()
   -- uf_notifyLayer:getModelNode():addChild(giftMailLayer)
   uf_sceneManager:getCurScene():addChild(giftMailLayer)
    giftMailLayer:showAtCenter(true)

end

function MainScene:_onButtonDay7( ... )
    uf_sceneManager:replaceScene(require("app.scenes.day7.Day7Scene").new())
end

function MainScene:_onButtonFund()

    -- uf_sceneManager:replaceScene(require("app.scenes.fund.FundMainScene").new())
    local index = G_Me.activityData:getFundIndex()
    uf_sceneManager:replaceScene(require("app.scenes.activity.ActivityMainScene").new(index))

end

function MainScene:_onButtonWheel()

    -- uf_sceneManager:replaceScene(require("app.scenes.wheel.WheelScene").new())
    if G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.FUMAIN) == true then
        uf_sceneManager:replaceScene(require("app.scenes.dafuweng.FuMainScene").new())
        return
    end
    
end

function MainScene:_onButtonTimePrivilege()
    if G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.TIME_PRIVILEGE) == true then
        uf_sceneManager:replaceScene(require("app.scenes.timeprivilege.TimePrivilegeMainScene").new())
        return
    end
end

function MainScene:_onButtonInvite()
    layer = require("app.scenes.crosswar.CrossWarInviteLayer").create(true)
    uf_sceneManager:getCurScene():addChild(layer)

    G_Me.crossWarData:setClickedInvite(true)
    self:_updateTopBtns()
end

function MainScene:_onUpdatedFriendButton()
    --更新按钮的小红点
    local hasActivity = G_Me.friendData:hasNew()

   self.moreButtonLayer:getImageViewByName("Image_friendTip"):setVisible(hasActivity)

   self:_showNewTips()
end

function MainScene:_onUpdatedActivityButton()
    --更新按钮的小红点
    local hasActivity = G_Me.activityData:hasActivityToJoin()

    self._layer:getImageViewByName("Image_activityTip"):setVisible(hasActivity)

   
end

function MainScene:_onUpdatedDaytaskButton()
    --更新按钮的小红点
    local hasActivity = G_Me.dailytaskData:hasNew()
    
    local taskTip = self._layer:getImageViewByName("Image_daytaskTip")
    taskTip:setVisible(hasActivity or G_Me.achievementData:hasNew())

   
end

function MainScene:_onUpdatedFundButton()

    local fundTip = self._layer:getImageViewByName("Image_fundTip")
    fundTip:setVisible(G_Me.fundData:needTips() )

end

function MainScene:_onUpdatedTargetInfo()
    
    local taskTip = self._layer:getImageViewByName("Image_daytaskTip")
    taskTip:setVisible(G_Me.achievementData:hasNew() or G_Me.dailytaskData:hasNew())

end

-- 觉醒商店
function MainScene:_onAwakenShopClick()
    
    uf_sceneManager:replaceScene(require("app.scenes.awakenshop.AwakenShopScene").new())
        
end

function MainScene:_onTitleClick( ... )
    uf_sceneManager:replaceScene(require("app.scenes.title.TitleScene").new(0))
end

-- 限时优惠
function MainScene:_onGetServerOpenTimeSucc()
    if G_Me.timePrivilegeData:isOpenFunction() then
        G_HandlersManager.timePrivilegeHandler:sendShopTimeRewardInfo()
        G_HandlersManager.timePrivilegeHandler:sendShopTimeInfo()
    end
end

-- 武将变身
function MainScene:_onKnightTransformClick()
    uf_sceneManager:replaceScene(require("app.scenes.knighttransform.KnightTransformMainScene").new())
end

return MainScene


