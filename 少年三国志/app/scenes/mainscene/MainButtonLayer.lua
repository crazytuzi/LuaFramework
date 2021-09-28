local FunctionLevelConst = require "app.const.FunctionLevelConst"
local CrossPVPConst = require("app.const.CrossPVPConst")

local MainButtonLayer = class("MainButtonLayer", UFCCSNormalLayer)

MainButtonLayer.BUTTON_TYPE = {
    TOP_BUTTON = 1,
    BOTTOM_BUTTON = 2,
    MORE_BUTTON = 3,
    SHOP_BUTTON = 4,
}

function MainButtonLayer.create()
    return MainButtonLayer.new("ui_layout/mainscene_MainBtns.json")
end

--每次进页面拉数据
function MainButtonLayer:enterSend()
    G_HandlersManager.wheelHandler:sendWheelInfo()
    G_HandlersManager.wheelHandler:sendWheelRankingList()
    G_HandlersManager.richHandler:sendRichInfo()
    G_HandlersManager.richHandler:sendRichRankingList()
    G_HandlersManager.trigramsHandler:sendGetTrigramsInfo()
    G_HandlersManager.trigramsHandler:sendGetRankList()
    G_HandlersManager.specialActivityHandler:sendGetSpecialHolidayActivity()
    G_HandlersManager.rCardHandler:sendRCardInfo()

    -- 限时抽将, 并且隔天了
    if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.THEME_DROP) then
        if G_Me.themeDropData:isAnotherDay() then
            G_HandlersManager.themeDropHandler:sendThemeDropZY()
        end
    end

    -- 神将、觉醒、战宠商店有免费刷新次数
    G_HandlersManager.secretShopHandler:sendLeftNumberReq()
    G_HandlersManager.awakenShopHandler:sendAwakenShopInfo()
    G_HandlersManager.crusadeHandler:sendShopInfo()
    
    if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.AWAKEN_MARK) then
        G_HandlersManager.awakenShopHandler:sendGetShopTag()
    end 

    -- 将灵
    if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.HERO_SOUL) then
        if G_Me.heroSoulData:isAnotherDay() then
            G_HandlersManager.heroSoulHandler:sendGetSoulInfo()
        end
    end
end

function MainButtonLayer:ctor(...)
    self.super.ctor(self, ...)
    self:adapterWithScreen()
    self._topPanel = self:getPanelByName("Panel_topBtns")
    self._bottomPanel = self:getPanelByName("Panel_btns")

    -- 更多按钮面板
    self.moreButtonLayer =  require("app.scenes.mainscene.MoreButtonLayer").create()
    self.moreButtonLayer:setVisible(false)
    self:addChild(self.moreButtonLayer, 2)
    self._morePanel = self.moreButtonLayer:getButtonPanel()

    -- 商店总按钮，展开可见各种商店入口
    self.shopsButtonLayer = require("app.scenes.mainscene.ShopsButtonLayer").create()
    self.shopsButtonLayer:setVisible(false)
    self:addChild(self.shopsButtonLayer, 2)
    self._shopsPanel = self.shopsButtonLayer:getButtonPanel()

    self:registerBtnClickEvent("Button_recharge",function()
        require("app.scenes.shop.recharge.RechargeLayer").show()
        end)
    self:showWidgetByName("Button_recharge",G_Setting:get("open_mainscene_recharge") == "1")

    self._rowMax = {5,6,5,3}
    self._tipPath = "tips_numb.png"
    self._tipNumPath = "ui/mainpage/bubble.png"
    self._diPath = "ui/mainpage/icon_bg_2.png"

    self._newPath = "ui/text/txt/dl_icon_new.png"

            --[[button 模板
            {
                btnName = "", -- 按钮名，不能重复
                iconPath = "ui/mainpage/icon-xxxx.png", -- 按钮图片路径
                txtPath = "ui/text/txt/sy_xxxx.png", -- 按钮下的文字的图片路径
                clickFunc = function ( ... ) 
                    -- 点击响应
                end,
                showCheck = function ( ... ) 
                    -- 是否显示按钮
                    return true
                end,
                needDetailTip = false, -- tip是否需要显示数字，例如邮件
                tipCheck = function ( ... )
                    -- 是否显示红点
                    return false
                end,
                eventList = {G_EVENTMSGID.EVNET_XXXX,},  --相关的需要处理显示的event
                baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下是2，默认填1
            }
            --]]

    --  底部的button,应该是固定不变的
    self._bottomList = {
            {
                    btnName = "Knight",
                    iconPath = "ui/mainpage/icon-wujiang.png",
                    txtPath = "ui/text/txt/sy_wujiang.png",
                    clickFunc = function ( ... )
                        uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroFosterScene").new())
                    end,
                    showCheck = function ( ... )
                        return true
                    end,
                    needDetailTip = false, -- tip是否需要显示数字，例如邮件
                    tipCheck = function ( ... )
                        return G_Me.bagData:CheckKnightFragmentCompose()
                    end,
                    eventList = {G_EVENTMSGID.EVNET_BAG_HAS_CHANGED},  --相关的需要处理显示的event
                    baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
            },
            {
                    btnName = "Equipment",
                    iconPath = "ui/mainpage/icon-zhuangbei.png",
                    txtPath = "ui/text/txt/sy_zhuangbei.png",
                    clickFunc = function ( ... )
                        uf_sceneManager:replaceScene(require("app.scenes.equipment.EquipmentMainScene").new())
                    end,
                    showCheck = function ( ... )
                        return true
                    end,
                    needDetailTip = false, -- tip是否需要显示数字，例如邮件
                    tipCheck = function ( ... )
                        return G_Me.bagData:CheckEquipmentFragmentCompose()
                    end,
                    eventList = {G_EVENTMSGID.EVNET_BAG_HAS_CHANGED},  --相关的需要处理显示的event
                    baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
            },
            {
                    btnName = "Treasure",
                    iconPath = "ui/mainpage/icon-jineng.png",
                    txtPath = "ui/text/txt/sy_baowu.png",
                    clickFunc = function ( ... )
                        uf_sceneManager:replaceScene(require("app.scenes.treasure.TreasureMainScene").new())
                    end,
                    showCheck = function ( ... )
                        return true
                    end,
                    needDetailTip = false, -- tip是否需要显示数字，例如邮件
                    tipCheck = function ( ... )
                        return false
                    end,
                    eventList = {},  --相关的需要处理显示的event
                    baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
            },
            {
                    btnName = "pet",
                    iconPath = "ui/mainpage/icon_zhanchong.png",
                    txtPath = "ui/text/txt/sy-zhanchong.png",
                    clickFunc = function ( ... )
                        if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.PET) then 
                            return
                        end

                        uf_sceneManager:replaceScene(require("app.scenes.pet.bag.PetBagMainScene").new())   
                    end,
                    showCheck = function ( ... )
                        return true
                    end,
                    needDetailTip = false, -- tip是否需要显示数字，例如邮件
                    tipCheck = function ( ... )
                        return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.PET) and G_Me.bagData.petData:couldCompound()
                    end,
                    eventList = {},  --相关的需要处理显示的event
                    baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
            },
            {
                    btnName = "Recycle",
                    iconPath = "ui/mainpage/icon-huishou.png",
                    txtPath = "ui/text/txt/sy_huishou.png",
                    clickFunc = function ( ... )
                        uf_sceneManager:replaceScene(require("app.scenes.recycle.RecycleScene").new())
                    end,
                    showCheck = function ( ... )
                        return true
                    end,
                    needDetailTip = false, -- tip是否需要显示数字，例如邮件
                    tipCheck = function ( ... )
                        return G_Me.bagData:hasKnightToRecycle() or G_Me.bagData:hasEquipmentToRecycle()
                    end,
                    eventList = {},  --相关的需要处理显示的event
                    baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
            },
            {
                    btnName = "More",
                    iconPath = "ui/mainpage/icon-gengduo.png",
                    txtPath = "ui/text/txt/sy_gengduo.png",
                    clickFunc = function ( ... )
                        self:_onMoreBtn()
                    end,
                    showCheck = function ( ... )
                        return true
                    end,
                    needDetailTip = false, -- tip是否需要显示数字，例如邮件
                    tipCheck = function ( ... )
                        local show = show or false
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
                        local hasHofPt =  G_Me.userData.hof_points>0 and G_moduleUnlock:isModuleUnlock(FunctionLevelConst.HALLOFFRAME_SCENE)
                        local themeDropTips = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.THEME_DROP) and (G_Me.themeDropData:hasFreeTimes() or G_Me.themeDropData:couldExtractKnight())
                        
                        local mxUnlock = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.MING_XING_MODULE) and G_Me.sanguozhiData:checkEnterSanguozhi()
                        local mxCount = G_Me.bagData:getSanguozhiFragmentCount()
                        require("app.cfg.main_growth_info")
                        local mxLastId = G_Me.sanguozhiData:getLastUsedId()
                        local mxLength = main_growth_info.getLength()
                        local mingxingTips = mxUnlock and mxCount > 0 and mxLastId ~= mxLength and mxCount >= main_growth_info.get(mxLastId+1).cost_num

                        local final = show or (count > 0) or hasActivity or hasTitleToActivate or hasHofPt or themeDropTips or mingxingTips

                        return final
                    end,
                    eventList = {G_EVENTMSGID.EVENT_MSG_DIRTY_FLAG_CHANGED,
                                            G_EVENTMSGID.EVENT_MAIL_NEW_COUNT,
                                            G_EVENTMSGID.EVENT_FRIENDS_INFO,
                                            G_EVENTMSGID.EVENT_FRIENDS_LIST,
                                            G_EVENTMSGID.EVENT_MAINSCENE_AWAKEN_SHOP_UPDATED,
                                            G_EVENTMSGID.EVENT_GIFT_MAIL_PROCESS,
                                            G_EVENTMSGID.EVENT_THEME_DROP_ENTER_MAIN_LAYER},  --相关的需要处理显示的event
                    baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
            },
            {
                    btnName = "union",
                    iconPath = "ui/mainpage/icon-banghui.png",
                    txtPath = "ui/text/txt/sy_banghui.png",
                    clickFunc = function ( ... )
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
                    end,
                    showCheck = function ( ... )
                        return true
                    end,
                    needDetailTip = false, -- tip是否需要显示数字，例如邮件
                    tipCheck = function ( ... )
                        return G_Me.legionData:hasNewCorpInfo()
                    end,
                    eventList = {G_EVENTMSGID.EVENT_CORP_FLAG_CAN_WORSHIP,
                                            G_EVENTMSGID.EVENT_CORP_FLAG_HAVE_WORSHIP_AWARD,
                                            G_EVENTMSGID.EVENT_CORP_FLAG_CAN_HIT_EGGS,
                                            G_EVENTMSGID.EVENT_CORP_FLAG_HAVE_APPLY,
                                            G_EVENTMSGID.EVENT_SHOP_INFO,},  --相关的需要处理显示的event
                    baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
            },
            {
                    btnName = "herosoul",
                    iconPath = "ui/mainpage/icon_jiangling.png",
                    txtPath = "ui/text/txt/sy-jiangling.png",
                    clickFunc = function()
                        uf_sceneManager:replaceScene(require("app.scenes.herosoul.HeroSoulScene").new())
                    end,
                    showCheck = function()
                        return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.HERO_SOUL)
                    end,
                    needDetailTip = false,
                    tipCheck = function()
                        return G_Me.heroSoulData:hasChartToActivate() or
                               G_Me.heroSoulData:hasAchievementToActivate() or
                               G_Me.heroSoulData:showSoulShopRedTips() or 
                               G_Me.heroSoulData:getFreeExtractCount() > 0 or 
                               G_Me.heroSoulData:getLeftDgnChallengeCount() > 0
                    end,
                    eventList = {G_EVENTMSGID.EVENT_HERO_SOUL_GET_SOUL_INFO},
                    baseRow = 1,
            }

    }
    --  顶部的button,位置会变化的
    self._topList = {
            {
                    btnName = "activity",
                    iconPath = "ui/mainpage/icon-huodong.png",
                    txtPath = "ui/text/txt/sy_huodong.png",
                    clickFunc = function ( ... )
                        uf_sceneManager:replaceScene(require("app.scenes.activity.ActivityMainScene").new())
                    end,
                    showCheck = function ( ... )
                        return true
                    end,
                    needDetailTip = false, -- tip是否需要显示数字，例如邮件
                    tipCheck = function ( ... )
                        return G_Me.activityData:hasActivityToJoin()
                    end,
                    eventList = {G_EVENTMSGID.EVENT_ACTIVITY_UPDATED,G_EVENTMSGID.EVENT_VIPDAILYINFO,G_EVENTMSGID.EVENT_VIPWEEKSHOPINFO},  --相关的需要处理显示的event
                    baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
            },
            {
                    btnName = "dailyTask",
                    iconPath = "ui/mainpage/icon-meirirenwu.png",
                    txtPath = "ui/text/txt/sy_meirirenwu.png",
                    clickFunc = function ( ... )
                        uf_sceneManager:replaceScene(require("app.scenes.dailytask.EverydayMainScene").new())
                    end,
                    showCheck = function ( ... )
                        return true
                    end,
                    needDetailTip = false, -- tip是否需要显示数字，例如邮件
                    tipCheck = function ( ... )
                        return G_Me.dailytaskData:hasNew() or G_Me.achievementData:hasNew()
                    end,
                    eventList = {G_EVENTMSGID.EVENT_DAILYTASK_GETDAILYMISSION,G_EVENTMSGID.EVENT_TARGET_INFO},  --相关的需要处理显示的event
                    baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
            },
            {
                    btnName = "Shops",
                    iconPath = "ui/mainpage/icon_shangdian.png",
                    txtPath = "ui/text/txt/sy_shangdian.png",
                    clickFunc = function ( ... )
                        if G_moduleUnlock:isModuleUnlock(require("app.const.FunctionLevelConst").SECRET_SHOP) then
                            self:_onShopsBtn()
                        else
                            G_MovingTip:showMovingTip(G_lang:get("LANG_GUANZHI_NOT_OPEN"))
                        end
                    end,
                    showCheck = function ( ... )   
                        return true
                    end,
                    needDetailTip = false, -- tip是否需要显示数字，例如邮件
                    tipCheck = function ( ... )
                        local final = false
                        local shouldShowSecretShop = G_Me.shopData:shouldShowSecretShop()
                        local shouldShowAwakenShop = G_Me.shopData:shouldShowAwakenShop()
                        local shouldShowPetShop = G_Me.shopData:shouldShowPetShop()
                        local shouldShowSoulShop = G_Me.heroSoulData:showSoulShopRedTips()

                        final = shouldShowSecretShop or shouldShowAwakenShop or shouldShowPetShop or shouldShowSoulShop

                        return final
                    end,
                    eventList = {G_EVENTMSGID.EVENT_MAINSCENE_SECRET_SHOP_UPDATED, 
                                 EVENT_SHOP_HAS_FREE_REFRESH_COUNT},  --相关的需要处理显示的event
                    baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
            },
            {
                    btnName = "fund",
                    iconPath = "ui/mainpage/icon-kaifujijin.png",
                    txtPath = "ui/text/txt/sy_kaifujijin.png",
                    clickFunc = function ( ... )
                        local index = G_Me.activityData:getFundIndex()
                        uf_sceneManager:replaceScene(require("app.scenes.activity.ActivityMainScene").new(index))
                    end,
                    showCheck = function ( ... )
                        return G_Me.fundData:needShow()
                    end,
                    needDetailTip = false, -- tip是否需要显示数字，例如邮件
                    tipCheck = function ( ... )
                        return G_Me.fundData:needTips()
                    end,
                    eventList = {G_EVENTMSGID.EVENT_FUND_INFO,G_EVENTMSGID.EVENT_FUND_USER_FUND},  --相关的需要处理显示的event
                    baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
            },
            {
                    btnName = "Day7",
                    iconPath = "ui/mainpage/icon_7day.png",
                    txtPath = "ui/text/txt/sy_qirihuodong.png",
                    clickFunc = function ( ... )
                        uf_sceneManager:replaceScene(require("app.scenes.day7.Day7Scene").new())
                    end,
                    showCheck = function ( ... )
                        return G_Me.days7ActivityData:isOpen()
                    end,
                    needDetailTip = false, -- tip是否需要显示数字，例如邮件
                    tipCheck = function ( ... )
                        return G_Me.days7ActivityData:isOpen() and G_Me.days7ActivityData:hasAwardActivity()
                    end,
                    eventList = {},  --相关的需要处理显示的event
                    baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
            },
            {
                    btnName = "TimePrivilege",
                    iconPath = "ui/mainpage/icon_xianshiyouhui.png",
                    txtPath = "ui/text/txt/sy_xianshiyouhui.png",
                    clickFunc = function ( ... )
                        if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.TIME_PRIVILEGE) == true then
                            uf_sceneManager:replaceScene(require("app.scenes.timeprivilege.TimePrivilegeMainScene").new())
                            return
                        end
                    end,
                    showCheck = function ( ... )
                        return G_Me.timePrivilegeData:isOpenFunction()
                    end,
                    needDetailTip = false, -- tip是否需要显示数字，例如邮件
                    tipCheck = function ( ... )
                        local showTips = false
                        if G_Me.timePrivilegeData:isOpenFunction() then
                            if not G_Me.timePrivilegeData:getEnterFunctionMark() or G_Me.timePrivilegeData:hasUnclaimedAward() or G_Me.timePrivilegeData:getGoodsRefreshedMark() then
                                showTips = true
                            end
                        end
                        return showTips
                    end,
                    eventList = {},  --相关的需要处理显示的event
                    baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
            },
            {
                    btnName = "SpecialActivity",
                    iconPath = "ui/mainpage/icon-huanqingjiajie.png",
                    txtPath = "ui/text/txt/huanqingjiajie.png",
                    -- txtPath = "ui/text/txt/sy_shuang11tehui.png",
                    clickFunc = function ( ... )
                        if G_Me.specialActivityData:isInActivityTime() then
                            uf_sceneManager:replaceScene(require("app.scenes.specialActivity.SpecialActivityScene").new())
                        else
                            G_MovingTip:showMovingTip(G_lang:get("LANG_SPECIAL_ACTIVITY_BUYTIME_AFTER"))
                            self:updateAll()
                        end
                    end,
                    showCheck = function ( ... )   
                        return G_Me.specialActivityData:isInActivityTime()
                    end,
                    needDetailTip = false, -- tip是否需要显示数字，例如邮件
                    tipCheck = function ( ... )
                        return G_Me.specialActivityData:needTips() or G_Me.specialActivityData:canShop()
                    end,
                    eventList = {G_EVENTMSGID.EVENT_GET_SPECIAL_HOLIDAY_ACTIVITY},  --相关的需要处理显示的event
                    baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
            },
            {
                    btnName = "giftmail",
                    iconPath = "ui/mainpage/icon-lingjiangzhongxin.png",
                    txtPath = "ui/text/txt/sy_lingjiangzhongxin.png",
                    clickFunc = function ( ... )
                         local giftMailLayer = require("app.scenes.giftmail.GiftMailLayer").create()
                        uf_sceneManager:getCurScene():addChild(giftMailLayer)
                         giftMailLayer:showAtCenter(true)
                    end,
                    showCheck = function ( ... )   
                        return G_Me.giftMailData:getNewMailCount() > 0
                    end,
                    needDetailTip = false, -- tip是否需要显示数字，例如邮件
                    tipCheck = function ( ... )
                        return true
                    end,
                    eventList = {G_EVENTMSGID.EVENT_GIFT_MAIL_NEW_COUNT},  --相关的需要处理显示的event
                    baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
            },
            {
                    btnName = "wheel",
                    iconPath = "ui/mainpage/icon-fujiatianxia.png",
                    txtPath = "ui/text/txt/sy_fujiatianxia.png",
                    clickFunc = function ( ... )
                         if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.FUMAIN) == true then
                             uf_sceneManager:replaceScene(require("app.scenes.dafuweng.FuMainScene").new())
                             return
                         end
                    end,
                    showCheck = function ( ... )   
                        return G_Me.wheelData:getState() < 3 or G_Me.richData:getState() < 3 or G_Me.trigramsData:getState() < 3 or G_Me.rCardData:isOpen()
                    end,
                    needDetailTip = false, -- tip是否需要显示数字，例如邮件
                    tipCheck = function ( ... )
                        local state = G_Me.richData:hasFinalAward() or G_Me.richData:hasAward() or G_Me.wheelData:hasFinalAward() 
                        					or G_Me.trigramsData:hasFinalAward()	
                        local state2 = G_Me.wheelData:getState() == 1 and (G_Me.wheelData:getFreeLeft(1)>0 or G_Me.wheelData:getFreeLeft(2)>0)
                        local state3 = G_Me.richData:getState() == 1 and G_Me.richData:getFreeLeft()>0
                        local trigramsState = G_Me.trigramsData:getState() == 1 and G_Me.trigramsData:getFreeLeft()>0
                        state = state or state2 or state3 or trigramsState
                        state = state and G_moduleUnlock:isModuleUnlock(FunctionLevelConst.FUMAIN)
                        return state
                    end,
                    eventList = {
                    				G_EVENTMSGID.EVENT_RICH_INFO,
                                    G_EVENTMSGID.EVENT_WHEEL_INFO,
                                    G_EVENTMSGID.EVENT_RICH_RANK,
                                    G_EVENTMSGID.EVENT_WHEEL_RANK,
                                    G_EVENTMSGID.EVENT_TRIGRAMS_UPDATE_INFO,
                                    G_EVENTMSGID.EVENT_TRIGRAMS_UPDATE_RANK,

                                },  --相关的需要处理显示的event
                    baseRow = 2,    --有的按钮要摆在指定行的，例如富甲天下
            },
            {
                    btnName = "rechargeMail",
                    iconPath = "ui/mainpage/icon-youjian.png",
                    txtPath = "ui/text/txt/sy_chongzhixiaoxi.png",
                    clickFunc = function ( ... )
                         uf_sceneManager:replaceScene(require("app.scenes.mail.MailScene").new(2))
                    end,
                    showCheck = function ( ... )   
                        return G_Me.mailData:getNewRechargeMailCount()>0
                    end,
                    needDetailTip = true, -- tip是否需要显示数字，例如邮件
                    tipCheck = function ( ... )
                        return G_Me.mailData:getNewRechargeMailCount()
                    end,
                    eventList = {G_EVENTMSGID.EVENT_MAIL_NEW_COUNT,},  --相关的需要处理显示的event
                    baseRow = 2,    --有的按钮要摆在指定行的，例如富甲天下
            },
            {
                    btnName = "Invite",
                    iconPath = "ui/crosswar/icon_yaoqinghan.png",
                    txtPath = "ui/text/txt/sy_yaoqinghan.png",
                    clickFunc = function ( ... )
                         layer = require("app.scenes.crosswar.CrossWarInviteLayer").create(true)
                         uf_sceneManager:getCurScene():addChild(layer)

                         G_Me.crossWarData:setClickedInvite(true)
                         self:updateAll()
                    end,
                    showCheck = function ( ... )   
                        local crossData = G_Me.crossWarData
                        local state = (not crossData:isScoreMatchEnd() and not crossData:isInChampionship()) or not crossData:isChampionshipEnabled() or not crossData:isQualify() or crossData:getQualifyType() == 0 or crossData:hasClickedInvite()
                        return not state
                    end,
                    needDetailTip = false, -- tip是否需要显示数字，例如邮件
                    tipCheck = function ( ... )
                        return false
                    end,
                    eventList = {G_EVENTMSGID.EVENT_MAIL_NEW_COUNT,},  --相关的需要处理显示的event
                    baseRow = 2,    --有的按钮要摆在指定行的，例如富甲天下
            },
            {
                    btnName = "GroupBuy",
                    iconPath = "ui/mainpage/icon-xianshituangou.png",
                    txtPath = "ui/text/txt/sy_xianshituangou.png",
                    clickFunc = function ( ... )
                        if G_Me.groupBuyData:isOpen() then
                            uf_sceneManager:replaceScene(require("app.scenes.groupbuy.GroupBuyScene").new())
                        else
                            G_MovingTip:showMovingTip(G_lang:get("LANG_GROUP_BUY_END_OVER"))
                        end
                    end,
                    showCheck = function ( ... )
                        return G_Me.groupBuyData:isMeetConditionsOfUse()
                    end,
                    needDetailTip = false, -- tip是否需要显示数字，例如邮件
                    tipCheck = function ( ... )
                        return G_Me.groupBuyData:isOpen() and G_Me.groupBuyData:isCanReward()
                    end,
                    eventList = {},  --相关的需要处理显示的event
                    baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
            },
            {
                    btnName = "rookieBuff",
                    iconPath = "ui/mainpage/icon_xinshouguanghuan.png",
                    txtPath = "ui/text/txt/sy_xinshouguanghuan.png",
                    clickFunc = function ( ... )
                        require("app.scenes.rookiebuff.RookieBuffMainLayer").show()
                    end,
                    showCheck = function ( ... )
                        return G_Me.rookieBuffData:showReward()
                    end,
                    needDetailTip = false, -- tip是否需要显示数字，例如邮件
                    tipCheck = function ( ... )
                        return G_Me.rookieBuffData:needTips()
                    end,
                    eventList = {G_EVENTMSGID.EVENT_ROOKIE_GET_INFO,G_EVENTMSGID.EVENT_ROOKIE_GET_REWARD},  --相关的需要处理显示的event
                    baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下

                    effectName = "effect_boss_tbtexiao",
            },
            {
                    btnName = "ex_dungeon",
                    iconPath = "ui/mainpage/icon-guoguanzhanjiang.png",
                    addIcon = "ui/text/txt/huodong_lan.png",
                    txtPath = "ui/text/txt/sy_guoguanzhanjiang.png",
                    clickFunc = function ( ... )
                        G_Loading:showLoading(function()
                            uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.expansiondungeon.ExpansionDungeonMainScene").new())
                        end)
                    end,
                    showCheck = function ( ... )
                        return G_Me.expansionDungeonData:isOpenFunction()
                    end,
                    needDetailTip = false, -- tip是否需要显示数字，例如邮件
                    tipCheck = function ( ... )
                        return G_Me.expansionDungeonData:hasAnyUnclaimedBox() or (G_Me.expansionDungeonData:getLoginMark() and not G_Me.expansionDungeonData:isTotalChapterGoodsSoldOut())
                    end,
                    eventList = {},  --相关的需要处理显示的event
                    baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
            },
            {
                    btnName = "crosspvp",
                    iconPath = "ui/play/icon-juezhanchibi.png",
                    addIcon = "ui/text/txt/weibaoming.png",
                    txtPath = "ui/text/txt/sy_juezhanchibi.png",
                    needDetailTip = false,
                    clickFunc = function()
                        local scenePack = G_GlobalFunc.sceneToPack("app.scenes.mainscene.MainScene")
                        require("app.scenes.crosspvp.CrossPVP").launch(scenePack)
                    end,
                    showCheck = function()
                        return false
                    end,
                    tipCheck = function()
                        return false
                    end,
                    eventList = {},
                    baseRow = 2,
            },
    }
    self._moreList = {
        {
                btnName = "Vip",
                iconPath = "ui/mainpage/icon-vip.png",
                txtPath = "ui/text/txt/sy_vip.png",
                clickFunc = function ( ... )
                    local p = require("app.scenes.vip.VipMainLayer").create()
                    G_Me.shopData:setVipEnter(true)
                    uf_sceneManager:getCurScene():addChild(p)
                end,
                showCheck = function ( ... )
                    return true
                end,
                needDetailTip = false, -- tip是否需要显示数字，例如邮件
                tipCheck = function ( ... )
                    return false
                end,
                eventList = {},  --相关的需要处理显示的event
                baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
        },
        {
                btnName = "HandBook",
                iconPath = "ui/mainpage/icon-tujian.png",
                txtPath = "ui/text/txt/sy_tujian.png",
                clickFunc = function ( ... )
                    local p = require("app.scenes.handbook.HandBookMainLayer").create()
                    uf_sceneManager:getCurScene():addChild(p)
                end,
                showCheck = function ( ... )
                    return true
                end,
                needDetailTip = false, -- tip是否需要显示数字，例如邮件
                tipCheck = function ( ... )
                    return false
                end,
                eventList = {},  --相关的需要处理显示的event
                baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
        },
        {
                btnName = "TipsInfo",
                iconPath = "ui/mainpage/icon_gonglue.png",
                txtPath = "ui/text/txt/sy_gonglue.png",
                clickFunc = function ( ... )
                    uf_sceneManager:replaceScene(require("app.scenes.tipsinfo.TipsInfoList2Scene").new())
                end,
                showCheck = function ( ... )
                    return true
                end,
                needDetailTip = false, -- tip是否需要显示数字，例如邮件
                tipCheck = function ( ... )
                    return false
                end,
                eventList = {},  --相关的需要处理显示的event
                baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
        },
        {
                btnName = "Cartoon",
                iconPath = "ui/mainpage/cartoon.png",
                txtPath = "ui/text/txt/qingmanhua.png",
                clickFunc = function ( ... )
                    if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.CARTOON_SHOW) then 
                        require("app.scenes.mainscene.ManhuaLayer").create()
                    end
                end,
                showCheck = function ( ... )
                    return (G_Setting:get("open_manhua") == "1")
                end,
                needDetailTip = false, -- tip是否需要显示数字，例如邮件
                tipCheck = function ( ... )
                    return false
                end,
                eventList = {},  --相关的需要处理显示的event
                baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
        },
        {
                btnName = "setting",
                iconPath = "ui/mainpage/icon-shezhi.png",
                txtPath = "ui/text/txt/sy_shezhi.png",
                clickFunc = function ( ... )
                    require("app.scenes.mainscene.SettingLayer").showSetting()
                    self:_closeMoreLayer()
                end,
                showCheck = function ( ... )
                    return true
                end,
                needDetailTip = false, -- tip是否需要显示数字，例如邮件
                tipCheck = function ( ... )
                    return false
                end,
                eventList = {},  --相关的需要处理显示的event
                baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
        },
        {
                btnName = "Chat",
                iconPath = "ui/mainpage/icon-liaotian.png",
                txtPath = "ui/text/txt/sy_liaotian.png",
                clickFunc = function ( ... )
                    if G_topLayer then 
                         G_topLayer:onChatClick()
                         self:_closeMoreLayer()
                     else
                        if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.CHAT) then 
                            return 
                        end
                    end
                end,
                showCheck = function ( ... )
                    return true
                end,
                needDetailTip = false, -- tip是否需要显示数字，例如邮件
                tipCheck = function ( ... )
                    return G_HandlersManager.chatHandler:hasMsgDirty()
                end,
                eventList = {G_EVENTMSGID.EVENT_MSG_DIRTY_FLAG_CHANGED},  --相关的需要处理显示的event
                baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
        },
        {
                btnName = "Mail",
                iconPath = "ui/mainpage/icon-youjian.png",
                txtPath = "ui/text/txt/sy_youjian.png",
                clickFunc = function ( ... )
                    uf_sceneManager:replaceScene(require("app.scenes.mail.MailScene").new())
                end,
                showCheck = function ( ... )
                    return true
                end,
                needDetailTip = true, -- tip是否需要显示数字，例如邮件
                tipCheck = function ( ... )
                    return G_Me.mailData:getNewMailCount()
                end,
                eventList = {G_EVENTMSGID.EVENT_MAIL_NEW_COUNT,},  --相关的需要处理显示的event
                baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
        },
        {
                btnName = "Friend",
                iconPath = "ui/mainpage/icon-haoyou.png",
                txtPath = "ui/text/txt/sy_haoyou.png",
                clickFunc = function ( ... )
                    uf_sceneManager:replaceScene(require("app.scenes.friend.FriendMainScene").new())
                end,
                showCheck = function ( ... )
                    return true
                end,
                needDetailTip = false, -- tip是否需要显示数字，例如邮件
                tipCheck = function ( ... )
                    return G_Me.friendData:hasNew()
                end,
                eventList = {G_EVENTMSGID.EVENT_FRIENDS_INFO,G_EVENTMSGID.EVENT_FRIENDS_LIST},  --相关的需要处理显示的event
                baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
        },
        {
                btnName = "HallOfFrame",
                iconPath = "ui/mainpage/icon-paihang.png",
                txtPath = "ui/text/txt/mingrentang.png",
                clickFunc = function ( ... )
                    if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.HALLOFFRAME_SCENE) then
                        uf_sceneManager:replaceScene(require("app.scenes.hallofframe.HallOfFrameScene").new())
                    end
                end,
                showCheck = function ( ... )
                    return true
                end,
                needDetailTip = false, -- tip是否需要显示数字，例如邮件
                tipCheck = function ( ... )
                    return G_Me.userData.hof_points>0 and G_moduleUnlock:isModuleUnlock(FunctionLevelConst.HALLOFFRAME_SCENE)
                end,
                eventList = {},  --相关的需要处理显示的event
                baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
        },
        {
                btnName = "mingxing",
                iconPath = "ui/mainpage/icon-sanguozhi.png",
                txtPath = "ui/text/txt/sy-sangouzhi.png",
                clickFunc = function ( ... )
                    if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.MING_XING_MODULE) then 
                        return
                    end
                    uf_sceneManager:replaceScene(require("app.scenes.sanguozhi.SanguozhiMainScene").new())
                end,
                showCheck = function ( ... )
                    return true
                end,
                needDetailTip = false, -- tip是否需要显示数字，例如邮件
                tipCheck = function ( ... )
                    local unlock = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.MING_XING_MODULE) and G_Me.sanguozhiData:checkEnterSanguozhi()
                    local count = G_Me.bagData:getSanguozhiFragmentCount()
                    require("app.cfg.main_growth_info")
                    local lastId = G_Me.sanguozhiData:getLastUsedId()
                    local length = main_growth_info.getLength()
                    return unlock and count > 0 and lastId ~= length and count >= main_growth_info.get(lastId+1).cost_num
                end,
                eventList = {},  --相关的需要处理显示的event
                baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
        },
        {
                btnName = "ThemeDrop",
                iconPath = "ui/mainpage/icon-jiangxing.png",
                txtPath = "ui/text/txt/jx-jiangxing.png",
                clickFunc = function ( ... )
                    uf_sceneManager:replaceScene(require("app.scenes.themedrop.ThemeDropMainScene").new(G_GlobalFunc.sceneToPack("app.scenes.mainscene.MainScene")))
                end,
                showCheck = function ( ... )
                    return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.THEME_DROP)
                end,
                needDetailTip = false, -- tip是否需要显示数字，例如邮件
                tipCheck = function ( ... )
                    return G_Me.themeDropData:hasFreeTimes() or G_Me.themeDropData:couldExtractKnight()
                end,
                eventList = {G_EVENTMSGID.EVENT_THEME_DROP_ENTER_MAIN_LAYER},  --相关的需要处理显示的event
                baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下

                --测试 需要显示new 标签的按钮需要加上这个方法
                --newCheck = function ( ... )
                    --return G_moduleUnlock:isNewModule(FunctionLevelConst.THEME_DROP)
                --end,
        },
        {
                btnName = "Title",
                iconPath = "ui/mainpage/icon-chenghao.png",
                txtPath = "ui/text/txt/sy_chenghao.png",
                clickFunc = function ( ... )
                    uf_sceneManager:replaceScene(require("app.scenes.title.TitleScene").new(0))
                end,
                showCheck = function ( ... )
                    return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.TITLE)
                end,
                needDetailTip = false, -- tip是否需要显示数字，例如邮件
                tipCheck = function ( ... )
                    return G_Me.bagData:hasTitleToActivate()
                end,
                eventList = {G_EVENTMSGID.EVENT_GIFT_MAIL_PROCESS},  --相关的需要处理显示的event
                baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
        },
        {
                btnName = "KnightTransform",
                iconPath = "ui/mainpage/icon-baguajing.png",
                txtPath = "ui/text/txt/baguajing.png",
                clickFunc = function ( ... )
                    uf_sceneManager:replaceScene(require("app.scenes.knighttransform.KnightTransformMainScene").new())
                end,
                showCheck = function ( ... )
                    return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.KNIGHT_TRANSFORM)
                end,
                needDetailTip = false, -- tip是否需要显示数字，例如邮件
                tipCheck = function ( ... )
                    return false
                end,
                eventList = {},  --相关的需要处理显示的event
                baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
        },
        {
                btnName = "PartnerHelp",
                iconPath = "ui/mainpage/icon-yuanjunzhuwei.png",
                txtPath = "ui/text/txt/sy-yuanjunzhuwei.png",
                clickFunc = function ( ... )
                    uf_sceneManager:replaceScene(require("app.scenes.hero.HeroScene").new(8, true))
                end,
                showCheck = function ( ... )
                    return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.KNIGHT_FRIEND_ZHUWEI)
                end,
                needDetailTip = false, -- tip是否需要显示数字，例如邮件
                tipCheck = function ( ... )
                    return false
                end,
                eventList = {},  --相关的需要处理显示的event
                baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
        },
        {
                btnName = "TreasureSmelt",
                iconPath = "ui/mainpage/icon-ronglian.png",
                txtPath = "ui/text/txt/sy-ronglian.png",
                clickFunc = function ( ... )
                    uf_sceneManager:replaceScene(require("app.scenes.treasure.TreasureComposeScene").new(nil,nil,nil,1,G_GlobalFunc.sceneToPack("app.scenes.mainscene.MainScene")))
                end,
                showCheck = function ( ... )
                    return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.TREASURE_SMELT)
                end,
                needDetailTip = false, -- tip是否需要显示数字，例如邮件
                tipCheck = function ( ... )
                    return false
                end,
                eventList = {},  --相关的需要处理显示的event
                baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
        },
        --[[{
                btnName = "KnightShop",
                iconPath = "ui/mainpage/icon-shenmishangdian.png",
                txtPath = "ui/text/txt/sy_shenmishangdian.png",
                clickFunc = function ( ... )
                    local FunctionLevelConst = require "app.const.FunctionLevelConst"
                    local result = G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.SECRET_SHOP)
                    if result then
                        uf_sceneManager:replaceScene(require("app.scenes.secretshop.SecretShopScene").new())
                                
                        -- 点击后隐藏按钮
                        self:updateAll()
                    end
                end,
                showCheck = function ( ... )
                    return true
                end,
                needDetailTip = false, -- tip是否需要显示数字，例如邮件
                tipCheck = function ( ... )
                    return false
                end,
                eventList = {},  --相关的需要处理显示的event
                baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
        },--]]
        --[[{
                btnName = "AwakenShop",
                iconPath = "ui/mainpage/icon-juexingshangdian.png",
                txtPath = "ui/text/txt/sy_juexingshangdian.png",
                clickFunc = function ( ... )
                    uf_sceneManager:replaceScene(require("app.scenes.awakenshop.AwakenShopScene").new())
                end,
                showCheck = function ( ... )
                    return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.AWAKEN)
                end,
                needDetailTip = false, -- tip是否需要显示数字，例如邮件
                tipCheck = function ( ... )
                    return G_Me.shopData:shouldShowAwakenShop()
                end,
                eventList = {},  --相关的需要处理显示的event
                baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
        },--]]
    }
    self._shopsList = {
        {
                btnName = "KnightShop",
                iconPath = "ui/mainpage/icon-shenmishangdian.png",
                txtPath = "ui/text/txt/sy_shenmishangdian.png",
                clickFunc = function ( ... )
                    local FunctionLevelConst = require "app.const.FunctionLevelConst"
                    local result = G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.SECRET_SHOP)
                    if result then
                        uf_sceneManager:replaceScene(require("app.scenes.secretshop.SecretShopScene").new())
                                
                        -- 点击后隐藏按钮
                        -- self:updateAll()
                    end
                end,
                showCheck = function ( ... )
                    return true
                end,
                needDetailTip = false, -- tip是否需要显示数字，例如邮件
                tipCheck = function ( ... )
                    return G_Me.shopData:shouldShowSecretShop() 
                end,
                eventList = {EVENT_SHOP_HAS_FREE_REFRESH_COUNT},  --相关的需要处理显示的event
                baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
        },
        {
                btnName = "AwakenShop",
                iconPath = "ui/mainpage/icon-juexingshangdian.png",
                txtPath = "ui/text/txt/sy_juexingshangdian.png",
                clickFunc = function ( ... )
                    uf_sceneManager:replaceScene(require("app.scenes.awakenshop.AwakenShopScene").new())
                end,
                showCheck = function ( ... )
                    return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.AWAKEN)
                end,
                needDetailTip = false, -- tip是否需要显示数字，例如邮件
                tipCheck = function ( ... )
                    return G_Me.shopData:shouldShowAwakenShop()
                end,
                eventList = {EVENT_SHOP_HAS_FREE_REFRESH_COUNT},  --相关的需要处理显示的event
                baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
        },
        {
                btnName = "PetShop",
                iconPath = "ui/mainpage/icon_zhanchongshangdian.png",
                txtPath = "ui/text/txt/sy_zhanchongshangdian.png",
                clickFunc = function ( ... )
                    uf_sceneManager:replaceScene(require("app.scenes.pet.shop.PetShopScene").new())
                end,
                showCheck = function ( ... )
                    return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.PET_SHOP)
                end,
                needDetailTip = false, -- tip是否需要显示数字，例如邮件
                tipCheck = function ( ... )
                    return G_Me.shopData:shouldShowPetShop()
                end,
                eventList = {EVENT_SHOP_HAS_FREE_REFRESH_COUNT},  --相关的需要处理显示的event
                baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
        },
        {
                btnName = "HeroSoulShop",
                iconPath = "ui/mainpage/icon_jianglingshangdian.png",
                txtPath = "ui/text/txt/jianglingshangdian.png",
                clickFunc = function ( ... )
                    local pack = G_GlobalFunc.sceneToPack("app.scenes.mainscene.MainScene")
                    uf_sceneManager:replaceScene(require("app.scenes.herosoul.HeroSoulShopScene").new(pack))
                end,
                showCheck = function ( ... )
                    return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.HERO_SOUL)
                end,
                needDetailTip = false, -- tip是否需要显示数字，例如邮件
                tipCheck = function ( ... )
                    return G_Me.heroSoulData:showSoulShopRedTips()
                end,
                eventList = {},  --相关的需要处理显示的event
                baseRow = 1,    --有的按钮要摆在指定行的，例如富甲天下
        },
    }
    
    self:initIcons()
    self:updateView(self._topList,self._topButtonList,MainButtonLayer.BUTTON_TYPE.TOP_BUTTON ,true)
    self:updateView(self._bottomList,self._bottomButtonList,MainButtonLayer.BUTTON_TYPE.BOTTOM_BUTTON ,true)
    self:updateView(self._moreList,self._moreButtonList,MainButtonLayer.BUTTON_TYPE.MORE_BUTTON ,true)
    self:updateView(self._shopsList,self._shopsButtonList,MainButtonLayer.BUTTON_TYPE.SHOP_BUTTON ,true)
end

function MainButtonLayer:onLayerEnter()
    self:registEvent(self._topList,function ( )
        self:updateView(self._topList,self._topButtonList,MainButtonLayer.BUTTON_TYPE.TOP_BUTTON,true)
    end)
    self:registEvent(self._bottomList,function ( )
        self:updateView(self._bottomList,self._bottomButtonList,MainButtonLayer.BUTTON_TYPE.BOTTOM_BUTTON,false)
    end)
    self:registEvent(self._moreList,function ( )
        self:updateView(self._moreList,self._moreButtonList,MainButtonLayer.BUTTON_TYPE.MORE_BUTTON,true)
    end)
    self:registEvent(self._shopsList,function ( )
        self:updateView(self._shopsList,self._shopsButtonList,MainButtonLayer.BUTTON_TYPE.SHOP_BUTTON,true)
    end)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TIME_PRIVILEGE_MAIN_SCENE_SHOW_ICON, self.updateAll, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_MAINSCENE_CLOSEMOREBTN,self._closeMoreLayer,self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_MAINSCENE_CLOSESHOPSBTN,self._closeShopsLayer,self)
    -- GlobalFunc.flyIntoScreenLR({self._bottomPanel,}, false, 0.15, 1, 50)

    self:enterSend()

    self:updateView(self._topList,self._topButtonList,MainButtonLayer.BUTTON_TYPE.TOP_BUTTON,true)
    self:updateView(self._bottomList,self._bottomButtonList,MainButtonLayer.BUTTON_TYPE.BOTTOM_BUTTON ,false)
    self:updateView(self._moreList,self._moreButtonList,MainButtonLayer.BUTTON_TYPE.MORE_BUTTON ,true)
    self:updateView(self._shopsList,self._shopsButtonList,MainButtonLayer.BUTTON_TYPE.SHOP_BUTTON ,true)

    -- 启动决战赤壁逻辑
    if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CROSS_PVP) then
        require("app.scenes.crosspvp.CrossPVP").launchWithoutScene(self)
    end
end

function MainButtonLayer:registEvent(list,callback)
    for key , value in pairs(list) do 
        if rawget(value, "eventList") then 
            for k, event in pairs(value.eventList) do 
                uf_eventManager:addEventListener(event, callback, self) 
            end
        end
    end
end

function MainButtonLayer:initIcons()
    self._topButtonList = {}
    self._bottomButtonList = {}
    self._moreButtonList = {}
    self._shopsButtonList = {}
    self:initIcon(self._topList,self._topButtonList,MainButtonLayer.BUTTON_TYPE.TOP_BUTTON)
    self:initIcon(self._bottomList,self._bottomButtonList,MainButtonLayer.BUTTON_TYPE.BOTTOM_BUTTON)
    self:initIcon(self._moreList,self._moreButtonList,MainButtonLayer.BUTTON_TYPE.MORE_BUTTON)
    self:initIcon(self._shopsList,self._shopsButtonList,MainButtonLayer.BUTTON_TYPE.SHOP_BUTTON)
end

--添加特效
function MainButtonLayer:_addEffect(_parent)
    if _parent then
        local EffectNode = require "app.common.effects.EffectNode"
        local eff = _parent:getNodeByTag(100)
        if not eff then
            eff = EffectNode.new("effect_boss_tbtexiao", function(event, frameIndex)
            end)
            eff:play()
            _parent:addNode(eff, 0, 100)
        end
    end
end

function MainButtonLayer:initIcon(list,buttonList,buttonType)
    for key , value in pairs(list) do 
        local info = {}
        info.value = value
        local button = Button:create()
        button:setName("Button_"..value.btnName)
        button:loadTextureNormal(value.iconPath)
        button:setTouchEnabled(true)

        if value.effectName then
            self:_addEffect(button)
        end

        local img = ImageView:create()
        img:loadTexture(value.txtPath)
        button:addChild(img)
        info.img = img
        local tipImg = ImageView:create()
        if value.needDetailTip then
            tipImg:loadTexture(self._tipNumPath)
            local tipTxt = GlobalFunc.createGameLabel("0", 22, Colors.darkColors.DESCRIPTION, nil)
            tipImg:addChild(tipTxt)
            info.tipTxt = tipTxt
        else
            tipImg:loadTexture(self._tipPath,UI_TEX_TYPE_PLIST)
        end
        button:addChild(tipImg)
        info.tipImg = tipImg

        if value.addIcon then
            local addIcon = ImageView:create()
            addIcon:loadTexture(value.addIcon)
            button:addChild(addIcon)
            addIcon:setPosition(ccp(-16,39))
            info.addIcon = addIcon
        end

        --new tag
        local newImg = ImageView:create()
        newImg:loadTexture(self._newPath)

        button:addChild(newImg,1)
        info.newImg = newImg
        newImg:setScale(0.6)

        if buttonType == MainButtonLayer.BUTTON_TYPE.TOP_BUTTON then
            img:setPosition(ccp(0,-30))
            if value.needDetailTip then
                tipImg:setPosition(ccp(28,31))
            else
                tipImg:setPosition(ccp(36,30))
            end
            newImg:setPosition(ccp(35,30))
            self._topPanel:addChild(button)
            info.button = button
            buttonList[value.btnName] = info
            self:registerBtnClickEvent("Button_"..value.btnName,value.clickFunc)
        elseif buttonType == MainButtonLayer.BUTTON_TYPE.BOTTOM_BUTTON then
            img:setPosition(ccp(0,-34))
            tipImg:setPosition(ccp(35,30))
            newImg:setPosition(ccp(35,30))

            if value.btnName == "More" then
                img:removeFromParent()
                tipImg:setPosition(ccp(35,20))               
            end

            self._bottomPanel:addChild(button)
            info.button = button
            buttonList[value.btnName] = info
            self:registerBtnClickEvent("Button_"..value.btnName,value.clickFunc)
        elseif buttonType == MainButtonLayer.BUTTON_TYPE.MORE_BUTTON then
            local diImg = ImageView:create()
            diImg:loadTexture(self._diPath)
            diImg:addChild(button)
            info.clickButton = button
            info.button = diImg
            img:setPosition(ccp(0,-32))
            tipImg:setPosition(ccp(40,40))
            newImg:setPosition(ccp(35,30))
            self._morePanel:addChild(diImg)
            buttonList[value.btnName] = info
            self.moreButtonLayer:registerBtnClickEvent("Button_"..value.btnName,value.clickFunc)
        elseif buttonType == MainButtonLayer.BUTTON_TYPE.SHOP_BUTTON then
            local diImg = ImageView:create()
            diImg:loadTexture(self._diPath)
            diImg:addChild(button)
            info.clickButton = button
            info.button = diImg
            img:setPosition(ccp(0,-32))
            tipImg:setPosition(ccp(40,40))
            newImg:setPosition(ccp(35,30))
            self._shopsPanel:addChild(diImg)
            buttonList[value.btnName] = info
            self.shopsButtonLayer:registerBtnClickEvent("Button_"..value.btnName,value.clickFunc)
        end
    end
end

function MainButtonLayer:updateView(list,buttonList,buttonType,needPos)
    local posList = nil
    if needPos then
        posList = self:calcPos(list,buttonList,buttonType)
        self:setPos(buttonList,buttonType,posList)
    end
    self:updateTips(list,buttonList)

    if buttonType == MainButtonLayer.BUTTON_TYPE.MORE_BUTTON and needPos and posList then
        self.moreButtonLayer:setBgHeight(#posList)
    end
    if buttonType == MainButtonLayer.BUTTON_TYPE.SHOP_BUTTON and needPos and posList then
        self.shopsButtonLayer:setBgWidth(posList[1])
        self.shopsButtonLayer:setBgHeight(#posList)
    end
end

function MainButtonLayer:updateAll()
    self:updateView(self._topList,self._topButtonList,MainButtonLayer.BUTTON_TYPE.TOP_BUTTON ,true)
    self:updateView(self._bottomList,self._bottomButtonList,MainButtonLayer.BUTTON_TYPE.BOTTOM_BUTTON ,false)
    self:updateView(self._moreList,self._moreButtonList,MainButtonLayer.BUTTON_TYPE.MORE_BUTTON ,true)
    self:updateView(self._shopsList,self._shopsButtonList,MainButtonLayer.BUTTON_TYPE.SHOP_BUTTON ,true)
end

function MainButtonLayer:calcPos(list,buttonList,buttonType)
    local pos = {}
    local calcRow = nil
    calcRow = function ( row )
        if pos[row] then
            if pos[row] >= self._rowMax[buttonType] then
                return calcRow(row+1)
            else
                pos[row] = pos[row] + 1
                return row,pos[row]
            end
        else
            pos[row] = 1
            return row,1
        end
    end
    for k , v in pairs(list) do 
        local row = v.baseRow
        local button = buttonList[v.btnName]
        if v.showCheck() then
            local finRow,finCol = calcRow(row)
            button.row = finRow
            button.col = finCol
            button.show = true
        else
            button.show = false
        end
    end
    return pos
end

function MainButtonLayer:setPos(buttonList,buttonType,posList)
    local leftPosX,leftPosY,offsetX,offsetY = 0,0,0,0
    local panelHeight = top and self._topPanel:getSize().height or self._bottomPanel:getSize().height
    if buttonType == MainButtonLayer.BUTTON_TYPE.TOP_BUTTON then
        leftPosX,leftPosY = 73,54
        offsetX,offsetY = 116,101
    elseif buttonType == MainButtonLayer.BUTTON_TYPE.BOTTOM_BUTTON then
        leftPosX,leftPosY = 60,15 --51-16 - 18
        offsetX,offsetY = 104,121 --125-4
    elseif buttonType == MainButtonLayer.BUTTON_TYPE.MORE_BUTTON then
        leftPosX,leftPosY = 70,65
        offsetX,offsetY = 115,106
    elseif buttonType == MainButtonLayer.BUTTON_TYPE.SHOP_BUTTON then
        leftPosX,leftPosY = 65,66
        offsetX,offsetY = 110,-106
    end
    for k , v in pairs(buttonList) do 
        v.button:setVisible(v.show)
        if v.show then
            local posx = leftPosX + offsetX*(v.col-1)
            local posy = leftPosY + offsetY*(v.row-1)
            if buttonType==MainButtonLayer.BUTTON_TYPE.TOP_BUTTON then
                posy = 170 - posy
            elseif buttonType==MainButtonLayer.BUTTON_TYPE.BOTTOM_BUTTON then
                posy = posy
                -- 这里更多按钮需要特殊处理一下，因为托盘需要和箭头分开
                if v.button:getName() == "Button_More" then
                    posy = posy + 10
                    local botImg = ImageView:create()
                    botImg:loadTexture("ui/mainpage/icon_bg_yangcheng.png")
                    botImg:setPositionXY(0, -40)

                    local txtImg = ImageView:create()
                    txtImg:loadTexture("ui/text/txt/sy_gengduo.png")
                    txtImg:setPositionXY(0, -43)

                    local arrowImg = ImageView:create()
                    arrowImg:loadTexture("ui/mainpage/icon-gengduo.png")
                    arrowImg:setTag(10)

                    v.button:addChild(botImg)
                    v.button:addChild(txtImg)
                    v.button:addChild(arrowImg)

                    v.button:loadTexturePressed("ui/mainpage/icon-gengduo.png")
                end
            elseif buttonType==MainButtonLayer.BUTTON_TYPE.MORE_BUTTON then
                posy = 53+105*#posList - posy
            elseif buttonType==MainButtonLayer.BUTTON_TYPE.SHOP_BUTTON then
                posy = posy
            end
            v.button:setPositionXY(posx,posy)
        end
    end
end

function MainButtonLayer:updateTips(list,buttonList)
    for k , v in pairs(list) do 
        local tipImg = buttonList[v.btnName].tipImg
        if v.needDetailTip then
            tipImg:setVisible(v.tipCheck()>0)
            buttonList[v.btnName].tipTxt:setText(v.tipCheck())
        else
            tipImg:setVisible(v.tipCheck())
        end

        local newImg = buttonList[v.btnName].newImg
        newImg:setVisible(false)
        if v.newCheck then
            newImg:setVisible(v.newCheck())
        end

        --new tag 显示优先级高于tipimg
        if newImg:isVisible() then
            tipImg:setVisible(false)
        end

    end
end

-- 决战赤壁按钮的状态变化
-- 这个接口会由CrossPVP来决定何时调用，不要在这里调用
function MainButtonLayer:updateCrossPVPTips()
    local btnInfo   = self._topButtonList["crosspvp"]
    local isCurShow = btnInfo.value.showCheck()
    local showBtn   = false
    local showTip   = false

    -- 根据不同赛段和玩家状态显示不同
    local course    = G_Me.crossPVPData:getCourse()
    if course == CrossPVPConst.COURSE_NONE or course == CrossPVPConst.COURSE_EXTRA then
        -- 比赛没开或已结束，不显示按钮
        showBtn = false
    elseif course == CrossPVPConst.COURSE_APPLY then
        -- 报名阶段，显示“已报名/未报名”，并且未报名时显示红点
        local isApplied = G_Me.crossPVPData:isApplied()
        local tagImg    = G_Path.getTextPath(isApplied and "jzcb_yibaoming.png" or "weibaoming.png")
        btnInfo.addIcon:loadTexture(tagImg)

        showBtn = true
        showTip = not isApplied
    elseif G_Me.crossPVPData:isBetting() then
        -- 正在投注阶段，显示“投注”，并且显示红点
        local tagImg = G_Path.getTextPath("touzhu.png")
        btnInfo.addIcon:loadTexture(tagImg)

        showBtn = true
        showTip = true
    elseif G_Me.crossPVPData:isInBattle() then
        -- 正在鼓舞和战斗阶段，（参赛的人或没参赛但有投注），显示“开战”和红点
        showBtn = G_Me.crossPVPData:isApplied() or G_Me.crossPVPData:hasBetStage()
        showTip = showBtn

        if showBtn then
            local tagImg = G_Path.getTextPath("kaizhan.png")
            btnInfo.addIcon:loadTexture(tagImg)
        end
    end

    if showBtn then
        -- 设置按钮下边的文字图
        local txtImgs = {"sy_juezhanchibi.png", "sy_haixuansai.png", "sy_fusai.png",
                        "sy_64qiangsai.png", "sy_16qiangsai.png", "sy_4qiangsai.png", "sy_juesai.png"}
        btnInfo.img:loadTexture(G_Path.getTextPath(txtImgs[course]))
    end

    btnInfo.tipImg:setVisible(showTip)
    btnInfo.value.showCheck = showBtn and function() return true end
                                       or function() return false end
    btnInfo.value.tipCheck  = showTip and function() return true end
                                       or function() return false end

    if isCurShow ~= showBtn then
        self:updateView(self._topList,self._topButtonList,MainButtonLayer.BUTTON_TYPE.TOP_BUTTON ,true)
    end
end

function MainButtonLayer:_onMoreBtn()
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
function MainButtonLayer:rotateMoreBtn(angle)
    local btn = self:getButtonByName("Button_More")
    if btn then
        local sprite = btn:getVirtualRenderer()
        sprite = tolua.cast(sprite, CCSPRITE)
        sprite:runAction(CCRotateTo:create(0.2,angle))

        local imgView = btn:getChildByTag(10)
        if imgView then
            imgView:runAction(CCRotateTo:create(0.2,angle))        
        end
    end
end


--@desc 关闭更多按钮页面
function MainButtonLayer:_closeMoreLayer()
    self:rotateMoreBtn(0)
    self.moreButtonLayer:hideMoreButton()
end

function MainButtonLayer:_onShopsBtn(  )
    local bg = self.shopsButtonLayer:getImageViewByName("ImageView_Bg")
    if not self.shopsButtonLayer:isVisible() then
        -- 获取商店按钮坐标
        local btnShops = self._topButtonList["Shops"]["button"]
        btnShops = tolua.cast(btnShops, "Button")
        local posX = btnShops:getPositionX()
        local posY = btnShops:getPositionY()
        -- 38 为位置调整参数
        posY = posY + self._topPanel:getPositionY() - 38

        -- 根据商店按钮左边来设置弹出层的位置
        bg:setPosition(ccp(posX, posY))

        bg:setScale(0)
        bg:runAction(CCScaleTo:create(0.2,1))
    end

    self.shopsButtonLayer:setVisible(not self.shopsButtonLayer:isVisible())
end

--@desc 关闭商店展开页面
function MainButtonLayer:_closeShopsLayer(  )
    self.shopsButtonLayer:hideShopsButton()
end

function MainButtonLayer:onLayerExit()
    require("app.scenes.crosspvp.CrossPVP").exit()

    self.super:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end

return MainButtonLayer

