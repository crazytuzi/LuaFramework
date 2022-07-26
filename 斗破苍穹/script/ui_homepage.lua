require"Lang"
require "ui_talk_fly"
require "HomePageController"

UIHomePage = {
    btn_time_RedPoint = true-- btn_time的红点
}
local button_Pos = { }
local button_Pos_Fuli = { }
local temp_Pos = { }
UIHomePage.ScheduleId = nil
UIHomePage.countDownTime = nil
UIHomePage.flag = false  -- 这个标志位为了游戏注销后复位用
UIHomePage.zOrder = { BUTTON = 4, CLOUD = 3, PARTICLE = 2, OTHER = 1 }
UIHomePage.btnTimeHintFlag = false
local moreTag = 0       -- 标记更多按钮的状态，0为收起，1为展开
local isAction = false  -- 标记更多按钮是否正在动画中
local isShowFuli = true -- 标记是否显示福利弹框，避免福利弹框内的按钮都隐藏时显示空弹框
UIHomePage.accessCount = 0
UIHomePage.limitHeroFlag = true
UIHomePage.luckyFlag = false
UIHomePage.qmflFlag = false
UIHomePage.costAllFlag = false
-- xzli add
local homePageController = nil
UIHomePage.controller = homePageController
local panel_christmas = nil

local onceId = 0
local lscache = nil

---------------------zy 月卡显示红点提示-------------------------------
function UIHomePage.getMonthCardData(type)
    local instActivityObj = nil
    if net.InstActivity then
        for key, obj in pairs(net.InstActivity) do
            local activity = net.SysActivity[tostring(obj.int["3"])]
            if activity.string["9"] == "monthCard" and obj.int["6"] == type then
                instActivityObj = obj
                return instActivityObj
            end
        end
    end
    return nil
end
function UIHomePage.isShowMonthCardHint()
    local isShowHint = false
    local types = { UIActivityCard.SILVER_MONTH_CARD, UIActivityCard.GOLD_MONTH_CARD }
    for i = 1, #types do
        local instActivityObj = UIHomePage.getMonthCardData(types[i])
        if instActivityObj then
            if instActivityObj.string["4"] == "" then
                isShowHint = false
                return
            elseif instActivityObj.string["4"] ~= "" and UIActivityPanel.isEndActivityByEndTime(instActivityObj.string["4"]) then
                isShowHint = false
                return
            end

            local recentGetTime = instActivityObj.string["7"]
            local endDay = utils.changeTimeFormat(instActivityObj.string["4"])[3]
            local getDay = nil
            if recentGetTime ~= nil and recentGetTime ~= "" then
                getDay = utils.changeTimeFormat(recentGetTime)[3]
            end
            local remainDay = 0
            local _curTime = utils.getCurrentTime()
            local _date = os.date("*t", _curTime)
            local function isleapyear(y)
                return(y % 4 == 0 and y % 100 or y % 400 == 0)
            end
            local md = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
            if isleapyear(_date.year) then
                md[2] = 29
            end
            if endDay - dp.loginDay > 0 then
                remainDay = endDay - dp.loginDay
            elseif endDay - dp.loginDay == 0 then
                remainDay = 30
            else
                remainDay = md[_date.month] - dp.loginDay + endDay
            end

            if getDay and tonumber(getDay) == tonumber(dp.loginDay) then
                isShowHint = false
            else
                isShowHint = true
            end
        else
            isShowHint = false
        end
        if isShowHint then
            break
        end
    end
    return isShowHint
end
---------------------------------------
function UIHomePage.stopSchedule()
    if UIHomePage.ScheduleId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(UIHomePage.ScheduleId)
        UIHomePage.ScheduleId = nil
        UIHomePage.countDownTime = nil;
        local btn_award = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_award")
        btn_award:getChildByName("image_hint"):setVisible(true)
        btn_award:getChildByName("image_base_time"):setVisible(false)
        if UIAwardOnLine.Widget ~= nil then
            local btn_prize = ccui.Helper:seekNodeByName(UIAwardOnLine.Widget, "btn_prize")
            utils.GrayWidget(btn_prize, false)
            btn_prize:setEnabled(true)
        end
    end
end
function UIHomePage.updateTime()
    if UIHomePage.countDownTime ~= 0 then
        UIHomePage.countDownTime = UIHomePage.countDownTime - 1
        local hour = math.floor(UIHomePage.countDownTime / 3600)
        local min = math.floor(UIHomePage.countDownTime % 3600 / 60)
        local sec = UIHomePage.countDownTime % 60
        local btn_award = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_award")
        local base_time = btn_award:getChildByName("image_base_time")
        btn_award:getChildByName("image_hint"):setVisible(false)
        base_time:setVisible(true)
        base_time:getChildByName("text_time"):setString(string.format("%02d:%02d:%02d", hour, min, sec))
        if UIAwardOnLine.Widget ~= nil then
            local text_countdown = ccui.Helper:seekNodeByName(UIAwardOnLine.Widget, "text_countdown")
            text_countdown:setString(string.format(Lang.ui_homepage1, hour, min, sec))

        end
    else
        UIHomePage.stopSchedule()
    end
end
-- xzli todo
function UIHomePage.hideMore()
    -- local btn_more = ccui.Helper:seekNodeByName(UIHomePage.Widget, "image_more")
    -- -- 更多按钮
    -- local panel_main = ccui.Helper:seekNodeByName(UIHomePage.Widget, "panel")
    -- -- 弹框
    -- if btn_more and panel_main then
    --     if moreTag == 1 then
    --         local action = cc.RotateBy:create(0.3, -180)
    --         local btn_more_arrow = btn_more:getChildByName("image_more_arrow")
    --         btn_more_arrow:runAction(action)
    --         panel_main:setVisible(false)
    --         panel_main:getChildByName("image_more_info"):setVisible(false)
    --         moreTag = 0
    --     elseif panel_main:getChildByName("image_gift"):isVisible() then
    --         panel_main:setVisible(false)
    --         panel_main:getChildByName("image_gift"):setVisible(false)
    --     end
    -- end
end

function UIHomePage.init()
    UIHomePage.Widget:getChildByName("image_time"):setVisible(false)
    UITalkFly.create()
    ---------------TEST 快速升级---------------
    if not dp.RELEASE then
        local quickUpgrade = ccui.Text:create()
        quickUpgrade:setString(Lang.ui_homepage2)
        quickUpgrade:setFontName(dp.FONT)
        quickUpgrade:setFontSize(30)
    quickUpgrade:setTextColor(cc.c3b(255, 255, 0))
        quickUpgrade:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
        UIHomePage.Widget:addChild(quickUpgrade, 10000)
        quickUpgrade:setTouchEnabled(true)
        quickUpgrade:addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                UIManager.showLoading()
                local function flush()
                    UIManager.flushWidget(UITeamInfo)
                    UIGuidePeople.levelGuideTrigger()
                end
                netSendPackage( { header = StaticMsgRule.quickUpgrade, msgdata = { } }, flush)
            end
        end )
    end
    ---------------TEST 快速升级---------------

    -- xzli todo
        -- 加载子页面
    UIHomePage.Widget:setTouchEnabled(false)
    local function loadPageCsb(index)
        local node = cc.CSLoader:createNode("ui/ui_homepage_"..index..".csb"):getChildren()[1]
        node:setContentSize(display.size)
        ccui.Helper:doLayout(node)
        node:retain()
        node:removeSelf()
        return node
    end
    cclog("---------- UIHomePage init create HomePageController ----------")
    homePageController = HomePageController:create( UIHomePage.Widget )--todo more
    UIHomePage.controller = homePageController
    homePageController:init()
    for i=1,3 do
        local page = loadPageCsb(i)
        local btns = {}
        if i==1 then
            local l_panel_jjc = ccui.Helper:seekNodeByName(page, "panel_jjc") --竞技场
            local l_panel_chengjiu = ccui.Helper:seekNodeByName(page, "panel_chengjiu") --成就
            local l_panel_bath = ccui.Helper:seekNodeByName(page,"panel_bath") -- 温泉
            local l_panel_fuben = ccui.Helper:seekNodeByName(page,"panel_fuben") --副本
            local l_panel_alliance = ccui.Helper:seekNodeByName(page,"panel_alliance") -- 联盟
            btns = {l_panel_jjc,l_panel_chengjiu,l_panel_bath,l_panel_fuben,l_panel_alliance}
        elseif i==2 then
            local l_panel_kuang = ccui.Helper:seekNodeByName(page,"panel_kuang")  --资源矿
            local l_panel_hundian = ccui.Helper:seekNodeByName(page,"panel_hundian") --魂殿
            local l_panel_tower = ccui.Helper:seekNodeByName(page,"panel_tower")  -- 天焚炼气塔
            local l_panel_relic = ccui.Helper:seekNodeByName(page,"panel_relic")  --远古遗迹
            local l_panel_store = ccui.Helper:seekNodeByName(page,"panel_store") -- 神秘商店
            btns = {l_panel_kuang,l_panel_hundian,l_panel_tower,l_panel_relic,l_panel_store}
        elseif i==3 then
            local l_panel_wing = ccui.Helper:seekNodeByName(page,"panel_wing")--神羽溶洞
            local l_panel_danta = ccui.Helper:seekNodeByName(page,"panel_danta") -- 丹塔
            local l_panel_star = ccui.Helper:seekNodeByName(page,"panel_star")--观星
            local l_panel_resolve = ccui.Helper:seekNodeByName(page,"panel_resolve")--异火神坛
            local l_panel_3v3 = ccui.Helper:seekNodeByName(page,"panel_3v3")--3v3
            btns = {l_panel_wing,l_panel_danta,l_panel_star,l_panel_resolve,l_panel_3v3}
        end
        homePageController:addPage(page)
        homePageController:addPageButtons(btns)
    end

    local btn_recharge = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_recharge")
    -- 充值按钮
    -- local btn_task = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_task")
    -- 每日任务按钮
    local btn_sign = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_sign")
    -- 签到礼包按钮
    local btn_activity = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_activity")
    -- 活动按钮
    local btn_lv = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_lv")
    -- 等级礼包按钮
    local btn_gift = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_gift")
    -- 开服礼包按钮
    local btn_award = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_award")
    -- 在线奖励按钮
    local btn_work = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_work")
    -- 节日登录礼包
    local btn_prize = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_prize")
    -- 领奖中心按钮
    local btn_equipment = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_equipment")
    -- 装备背包按钮
    local btn_card = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_card")
    -- 卡牌按钮
    local btn_gongfa = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_gongfa")
    -- 功法按钮
    local btn_soul = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_soul")
    -- 斗魂
    -- local btn_wing = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_wing")
    -- -- 神羽
    -- btn_wing:getChildByName("image_hint"):setVisible(false)
    local btn_set = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_set")
    -- 设置按钮
    -- local btn_email = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_email")
    -- 邮件
    local btn_ranking = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_ranking")
    -- 排行榜
    local btn_trial = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_trial")
    -- 试炼日
    -- local btn_talk = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_talk")
    -- 聊天
    local btn_resolve = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_resolve")
    -- 分解
    -- local btn_more = ccui.Helper:seekNodeByName(UIHomePage.Widget, "image_more")
    -- 更多按钮
    local btn_time = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_time")
    -- 限时特惠
    local btn_change = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_change")
    -- 无敌兑换
    local btn_fuli = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_fuli")
    -- 福利
    local btn_purchase = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_purchase")
    -- 超值团购
    local btn_limit = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_limit")
    --充值
    local btn_welfare_recharge = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_welfare_recharge")
    -- 充值福利
    -- local btn_star = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_star")
    -- 占星

    local panel_main = ccui.Helper:seekNodeByName(UIHomePage.Widget, "panel")
    -- 首页弹框
    local panel_resolve = ccui.Helper:seekNodeByName(UIHomePage.Widget, "panel_resolve")
    -- 异火
    local panel_relic = ccui.Helper:seekNodeByName(UIHomePage.Widget, "panel_relic")
    -- 远古遗迹
    local panel_tower = ccui.Helper:seekNodeByName(UIHomePage.Widget, "panel_tower")
    -- 天焚炼气塔
    local panel_jjc = ccui.Helper:seekNodeByName(UIHomePage.Widget, "panel_jjc")
    -- 竞技场
    local panel_alliance = ccui.Helper:seekNodeByName(UIHomePage.Widget, "panel_alliance")
    -- 联盟
--[[ xzli todo
    btn_recharge:setPressedActionEnabled(true)
    -- btn_task:setPressedActionEnabled(true)
    btn_sign:setPressedActionEnabled(true)
    btn_activity:setPressedActionEnabled(true)
    btn_lv:setPressedActionEnabled(true)
    btn_gift:setPressedActionEnabled(true)
    btn_work:setPressedActionEnabled(true)
    btn_award:setPressedActionEnabled(true)
    btn_prize:setPressedActionEnabled(true)
    -- btn_email:setPressedActionEnabled(true)
    btn_ranking:setPressedActionEnabled(true)
    btn_trial:setPressedActionEnabled(true)
    btn_welfare_recharge:setPressedActionEnabled(true)
    btn_equipment:setPressedActionEnabled(true)
    btn_card:setPressedActionEnabled(true)
    btn_gongfa:setPressedActionEnabled(true)
    btn_soul:setPressedActionEnabled(true)
    -- btn_wing:setPressedActionEnabled(true)
    btn_set:setPressedActionEnabled(true)
    -- btn_talk:setPressedActionEnabled(true)
    btn_resolve:setPressedActionEnabled(true)
    -- btn_more:setTouchEnabled(true)
    btn_time:setPressedActionEnabled(true)
    btn_change:setPressedActionEnabled(true)
    btn_fuli:setPressedActionEnabled(true)
    btn_purchase:setPressedActionEnabled(true)
    btn_limit:setPressedActionEnabled(true)
    -- btn_star:setPressedActionEnabled(true)
]]
    btn_recharge:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    -- btn_task:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    btn_sign:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    btn_activity:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    btn_lv:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    btn_gift:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    btn_work:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    btn_award:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    btn_prize:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    -- btn_email:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    btn_ranking:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    btn_trial:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    btn_welfare_recharge:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    btn_equipment:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    btn_card:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    btn_gongfa:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    btn_soul:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    -- btn_wing:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    btn_set:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    -- btn_talk:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    btn_resolve:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    -- btn_more:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    btn_time:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    btn_change:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    btn_fuli:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    btn_purchase:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    btn_limit:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    -- btn_star:setLocalZOrder(UIHomePage.zOrder.BUTTON)
--[[
-- xzli did it
    panel_resolve:setTouchEnabled(true)
    panel_relic:setTouchEnabled(true)
    panel_tower:setTouchEnabled(true)
    panel_jjc:setTouchEnabled(true)
    panel_alliance:setTouchEnabled(true)
    panel_main:setTouchEnabled(true)
]]
    panel_resolve:setLocalZOrder(UIHomePage.zOrder.OTHER)
    panel_relic:setLocalZOrder(UIHomePage.zOrder.OTHER)
    panel_tower:setLocalZOrder(UIHomePage.zOrder.OTHER)
    panel_jjc:setLocalZOrder(UIHomePage.zOrder.OTHER)
    panel_alliance:setLocalZOrder(UIHomePage.zOrder.OTHER)
    panel_main:setLocalZOrder(UIHomePage.zOrder.BUTTON)


    -- 创建粒子
    local particleTrial = cc.ParticleSystemQuad:create("particle/shouye_action_effect_slstar.plist")
    particleTrial:setPosition(cc.p(btn_trial:getContentSize().width / 2, btn_trial:getContentSize().height * 0.4))
    particleTrial:setScale(0.8)
    btn_trial:addChild(particleTrial)

    local particleResolve = cc.ParticleSystemQuad:create("particle/shouye_action_effect_fire_1.plist")
    particleResolve:setPosition(cc.p(75, 65))
    particleResolve:setScale(0.6)
    panel_resolve:addChild(particleResolve, UIHomePage.zOrder.PARTICLE)

    local particleTower = cc.ParticleSystemQuad:create("particle/shouye_action_effect_star_1.plist")
    particleTower:setPosition(cc.p(130, 95))
    particleTower:setScale(0.5)
    panel_tower:addChild(particleTower, UIHomePage.zOrder.PARTICLE)

    local particleAlliance = cc.ParticleSystemQuad:create("particle/shouye_action_effect_taohua_1.plist")
    particleAlliance:setPosition(cc.p(195, 210))
    particleAlliance:setScale(0.9)
    panel_alliance:addChild(particleAlliance, UIHomePage.zOrder.PARTICLE)

    local particleAllianceTwo = cc.ParticleSystemQuad:create("particle/shouye_action_effect_taohua_1.plist")
    particleAllianceTwo:setPosition(cc.p(20, 130))
    panel_alliance:addChild(particleAllianceTwo, UIHomePage.zOrder.PARTICLE)

    local rechargePosX, rechargePosY = btn_recharge:getPosition()
    local rechargePox = cc.p(rechargePosX, rechargePosY)

    local particleRecharge = cc.ParticleSystemQuad:create("particle/shouye_action_effect_star_2.plist")
    particleRecharge:setPosition(rechargePox)
    UIHomePage.Widget:addChild(particleRecharge, UIHomePage.zOrder.BUTTON + 1)

    local purchasePosX, purchasePosY = btn_purchase:getPosition()
    local particlePurchase = cc.ParticleSystemQuad:create("particle/shouye_action_effect_star_2.plist")
    particlePurchase:setPosition(cc.p(purchasePosX, purchasePosY))
    particlePurchase:setName("ui_particlePurchase")
    UIHomePage.Widget:addChild(particlePurchase, UIHomePage.zOrder.BUTTON + 1)

    local limitPosX, limitPosY = btn_limit:getPosition()
    local particleLimit = cc.ParticleSystemQuad:create("particle/shouye_action_effect_star_2.plist")
    particleLimit:setPosition(cc.p(limitPosX, limitPosY))
    particleLimit:setName("ui_particleLimit")
    UIHomePage.Widget:addChild(particleLimit, UIHomePage.zOrder.BUTTON + 1)

    local rechargeBg = cc.Sprite:create("image/shouye_recharge_bg.png")
    rechargeBg:setPosition(rechargePox)
    UIHomePage.Widget:addChild(rechargeBg, UIHomePage.zOrder.BUTTON - 1)
    rechargeBg:runAction(cc.RepeatForever:create(cc.RotateBy:create(2.6, 360)))
    -- 创建天焚炼气塔的动画
    local animPath = "ani/ui_anim_shou/"
    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath .. "ui_anim_shou.ExportJson")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath .. "ui_anim_shou.ExportJson")
    local animation = ccs.Armature:create("ui_anim_shou")
    animation:getAnimation():play("shou01")
    local aniX, aniY = panel_tower:getPosition()
    animation:setPosition(cc.p(aniX + 123, aniY + 116))
    UIHomePage.Widget:addChild(animation, UIHomePage.zOrder.PARTICLE)

    local function createPaoPao()
        -- zy
        local node = cc.Node:create()
        local image = ccui.ImageView:create("ui/ui_zhaoren.png")
        node:addChild(image)
        node:setName("paopao")
        node:setPosition(cc.p(250, 190))
        panel_alliance:addChild(node, UIHomePage.zOrder.BUTTON)
    end

    local function createFirePaoPao()
        local node = cc.Node:create()
        local image = ccui.ImageView:create("ui/ui_firezhaoren.png")
        node:addChild(image)
        node:setName("firepaopao")
        node:setPosition(cc.p(120, 130))
        panel_resolve:addChild(node, UIHomePage.zOrder.BUTTON)
    end

    --飘花
    local function createFlowerParticle()
        local node = cc.Node:create()
        local flower = cc.ParticleSystemQuad:create("particle/flower/sy_huaban_1.plist")
        node:addChild(flower)
        node:setName("flower")
        node:setPosition(cc.p(UIManager.screenSize.width / 2 , UIManager.screenSize.height - 50 ))
        node:setVisible( false )
        UIHomePage.Widget:addChild(node, 100000 )
    end
    -- 创建首页云朵
    local function createCloud()
        local cloudW = 500
        local cloudH = 328
        local maxY = UIManager.screenSize.height - cloudH / 2.0
        local minY = cloudH / 2.0
        local function getParam()
            local y = math.random(minY, maxY)
            local scale =(UIManager.screenSize.height - y) / UIManager.screenSize.height * 1.5
            if scale < 0.5 then
                scale = 0.5
            elseif scale > 1.5 then
                scale = 1.5
            end
            local actiontime =(UIManager.screenSize.height - y) / UIManager.screenSize.height * 50
            if actiontime < 20 then
                actiontime = 20
            elseif actiontime > 40 then
                actiontime = 40
            end
            return y, scale, actiontime
        end
        local function callBack(actionBody)
            actionBody:stopAllActions()
            local callBackY, callBackScale, callBackTime = getParam()
            actionBody:setPosition(cc.p(- cloudW / 2, callBackY))
            actionBody:setScale(callBackScale)
            actionBody:setOpacity(255)
            local action = cc.Sequence:create(cc.DelayTime:create(math.random(1, 3)), cc.Spawn:create(cc.MoveBy:create(callBackTime, cc.p(UIManager.screenSize.width, 0)),
            cc.Sequence:create(cc.DelayTime:create(callBackTime / 3 * 2.0), cc.FadeTo:create(callBackTime / 3.0, 0), cc.CallFunc:create(callBack))), cc.CallFunc:create(callBack))
            actionBody:runAction(action)
        end
        local function createAction(delayTime, time)
            local action = cc.Sequence:create(cc.DelayTime:create(delayTime), cc.Spawn:create(cc.MoveBy:create(time, cc.p(UIManager.screenSize.width, 0)),
            cc.Sequence:create(cc.DelayTime:create(time / 3 * 2.0), cc.FadeTo:create(time / 3.0, 0), cc.CallFunc:create(callBack))), cc.CallFunc:create(callBack))
            return action
        end
        local cloudTable = { cloud1 = nil, cloud2 = nil, cloud3 = nil }
        cloudTable.cloud1 = cc.Sprite:create("image/ui_home_cloud.png")
        cloudTable.cloud2 = cc.Sprite:create("image/ui_home_cloud.png")
        cloudTable.cloud3 = cc.Sprite:create("image/ui_home_cloud.png")
        local cloudY1, scale1, time1 = getParam()
        cloudTable.cloud1:setPosition(cc.p(- cloudW / 2 + 100, cloudY1))
        cloudTable.cloud1:setScale(scale1)
        cloudTable.cloud1:runAction(createAction(0, time1))
        UIHomePage.Widget:addChild(cloudTable.cloud1, UIHomePage.zOrder.CLOUD)
        local cloudY2, scale2, time2 = getParam()
        cloudTable.cloud2:setPosition(cc.p(- cloudW / 2 + 50, cloudY2))
        cloudTable.cloud2:setScale(scale2)
        cloudTable.cloud2:runAction(createAction(1, time2))
        UIHomePage.Widget:addChild(cloudTable.cloud2, UIHomePage.zOrder.CLOUD)
        local cloudY3, scale3, time3 = getParam()
        cloudTable.cloud3:setPosition(cc.p(- cloudW / 2 + 50, cloudY3))
        cloudTable.cloud3:setScale(scale3)
        cloudTable.cloud3:runAction(createAction(2, time3))
        UIHomePage.Widget:addChild(cloudTable.cloud3, UIHomePage.zOrder.CLOUD)
    end
    local function createChristmas()
        local cPage = homePageController:getPage(0)
        panel_christmas = ccui.Layout:create()
        local animPath = "ani/ui_anim/ui_anim" .. 61 .. "/"
        ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath .. "ui_anim" .. 61 .. ".ExportJson")
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath .. "ui_anim" .. 61 .. ".ExportJson")
        local animation = ccs.Armature:create("ui_anim" .. 61)
        animation:getAnimation():play("ui_anim61")
        panel_christmas:setAnchorPoint(cc.p(0.5, 0.5))
        panel_christmas:setContentSize(cc.size(130, 200))
        animation:setPosition(cc.p(panel_christmas:getContentSize().width / 2 - 30, panel_christmas:getContentSize().height / 2 - 30))
        panel_christmas:addChild(animation)
--        local effect = cc.ParticleSystemQuad:create("particle/christmas/ui_qingrenjie_hua.plist")
--        effect:setPositionType(cc.POSITION_TYPE_RELATIVE)
--        effect:setPosition(cc.p(node:getContentSize().width / 2, node:getContentSize().height / 2 - 20))
--        node:addChild(effect)

	--[[
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("ani/ui_anim/sy_qiqiu/sy_qiqiu.ExportJson")
        local animation = ccs.Armature:create("sy_qiqiu")
        animation:getAnimation():playWithIndex( 0 )
        node:setAnchorPoint(cc.p(0.5, 0.5))
        animation:setPosition(cc.p(node:getContentSize().width / 2, node:getContentSize().height / 2 - 20))
        node:addChild(animation)
	--]]

        panel_christmas:setName("christmasTree")
        panel_christmas:setPosition(cc.p(cPage:getContentSize().width / 2 + 40, cPage:getContentSize().height / 2 ))
        -- UIHomePage.Widget:addChild(node, UIHomePage.zOrder.BUTTON)
        cPage:addChild(panel_christmas)
        

        local particle1 = cc.ParticleSystemQuad:create("particle/snow/ui_anim_snow_1.plist")
        -- particle1:setPositionType(cc.POSITION_TYPE_RELATIVE)
        particle1:setScale(1.2)
        particle1:setName("christmasSnow")
        particle1:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height - 120))
        -- UIHomePage.Widget:addChild(particle1, UIHomePage.zOrder.BUTTON)
        cPage:addChild(particle1)

        --        particle1 = cc.ParticleSystemQuad:create("particle/snow/ui_anim_snow_2.plist" )
        --        --particle1:setPositionType(cc.POSITION_TYPE_RELATIVE)
        --        particle1:setPosition( cc.p( UIManager.screenSize.width / 2 , UIManager.screenSize.height * 3 / 4 ) )
        --        UIHomePage.Widget:addChild(particle1 , UIHomePage.zOrder.BUTTON)

        --        particle1 = cc.ParticleSystemQuad:create("particle/snow/ui_anim_snow_3.plist" )
        --        --particle1:setPositionType(cc.POSITION_TYPE_RELATIVE)
        --        particle1:setPosition( cc.p( UIManager.screenSize.width / 2 , UIManager.screenSize.height / 4 ) )
        --        UIHomePage.Widget:addChild(particle1 , UIHomePage.zOrder.BUTTON)

        local function onEventChristmas(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if sender == node then
                    UIManager.hideWidget("ui_team_info")
                    UIManager.showWidget("ui_activity_time")
                    UIActivityTime.jumpName("Christmas")
                end
            end
        end
        -- node:setTouchEnabled(true)
        -- node:addTouchEventListener(onEventChristmas)
        homePageController:addPageButtons({panel_christmas})
    end
    -- 创建云朵
    createCloud()
    createPaoPao()
    createFirePaoPao()
    createChristmas()
    createFlowerParticle()

    btn_purchase:runAction(cc.RepeatForever:create(cc.Sequence:create(
    --        cc.Spawn:create(  ),
    cc.DelayTime:create(3),
    cc.RotateTo:create(0.1, 5),
    cc.RotateTo:create(0.1, -5),
    cc.RotateTo:create(0.1, 5),
    cc.RotateTo:create(0.1, -5),
    cc.RotateTo:create(0.1, 5),
    cc.RotateTo:create(0.1, -5),
    cc.RotateTo:create(0.1, 0)
    )))

    btn_limit:runAction(cc.RepeatForever:create(cc.Sequence:create(
    --        cc.Spawn:create(  ),
    cc.DelayTime:create(2),
    cc.RotateTo:create(0.1, 5),
    cc.RotateTo:create(0.1, -5),
    cc.RotateTo:create(0.1, 5),
    cc.RotateTo:create(0.1, -5),
    cc.RotateTo:create(0.1, 5),
    cc.RotateTo:create(0.1, -5),
    cc.RotateTo:create(0.1, 0)
    )))

    -- xzli todo flag 
    local function btnTouchEvent(sender, eventType)
        cclog("----------------------ui_homepage btnTouchEvent------------------------------")
        if eventType == ccui.TouchEventType.ended then
            cclog("eventType == ccui.TouchEventType.ended")
            AudioEngine.playEffect("sound/button.mp3")
            if sender == btn_recharge then
                utils.checkGOLD(1)
            -- elseif sender == btn_more then
            --     if not isAction then
            --         cclog("isAction=true   moreTag=" .. moreTag)
            --         isAction = true
            --         if moreTag == 0 then
            --             local action = cc.Sequence:create(cc.RotateBy:create(0.3, 180), cc.CallFunc:create( function()
            --                 panel_main:setVisible(true)
            --                 panel_main:getChildByName("image_more_info"):setVisible(true)
            --                 isAction = false
            --             end ))
            --             local btn_more_arrow = btn_more:getChildByName("image_more_arrow")
            --             btn_more_arrow:runAction(action)
            --             moreTag = 1
            --         elseif moreTag == 1 then
            --             local action = cc.Sequence:create(cc.RotateBy:create(0.3, -180), cc.CallFunc:create( function()
            --                 isAction = false
            --             end ))
            --             local btn_more_arrow = btn_more:getChildByName("image_more_arrow")
            --             btn_more_arrow:runAction(action)
            --             panel_main:setVisible(false)
            --             panel_main:getChildByName("image_more_info"):setVisible(false)
            --             moreTag = 0
            --         end
            --     end
            elseif sender == panel_christmas then
                    UIManager.hideWidget("ui_team_info")
                    UIManager.showWidget("ui_activity_time")
                    UIActivityTime.jumpName("Christmas")
            elseif sender == btn_fuli then
                if isShowFuli then
                    panel_main:setVisible(true)
                    panel_main:getChildByName("image_gift"):setVisible(true)
                end
                if UIGuidePeople.guideStep == "7B1" then
                    UIGuidePeople.isGuide(btn_lv, UIHomePage)
                elseif UIGuidePeople.guideStep == "25B1" then
                    UIGuidePeople.isGuide(btn_sign, UIHomePage)
                elseif UIGuidePeople.levelStep == "10_1" then
                    UIGuidePeople.isGuide(btn_lv, UIHomePage)
                end
            elseif sender == btn_purchase then
                UIActivityPurchaseManager.show()
            elseif sender == btn_limit then
                UIActivityLimit.show()
            elseif sender == btn_lv then
                UIAwardGift.setOperateType(UIAwardGift.OperateType.lv)
                panel_main:setVisible(false)
                panel_main:getChildByName("image_gift"):setVisible(false)
            elseif sender == btn_gift then
                UIAwardGift.setOperateType(UIAwardGift.OperateType.gift)
                panel_main:setVisible(false)
                panel_main:getChildByName("image_gift"):setVisible(false)
            elseif sender == btn_prize then
                UIAwardGift.setOperateType(UIAwardGift.OperateType.prize)
            elseif sender == btn_work then
                UIAwardWork.show()
                panel_main:setVisible(false)
                panel_main:getChildByName("image_gift"):setVisible(false)
            elseif sender == btn_sign then
                UIManager.pushScene("ui_award_sign")
                panel_main:setVisible(false)
                panel_main:getChildByName("image_gift"):setVisible(false)
            elseif sender == btn_award then
                UIManager.pushScene("ui_award_online")
                panel_main:setVisible(false)
                panel_main:getChildByName("image_gift"):setVisible(false)
            elseif sender == btn_time then
                UIActivityTime.show()
            -- elseif sender == btn_task then
            --     UIManager.pushScene("ui_task_day")
            --     -- elseif sender == btn_beruty then
            --     -- 	UIManager.hideWidget("ui_team_info")
            --     -- 	UIManager.showWidget("ui_beauty")
            elseif sender == btn_set then
                UIManager.pushScene("ui_settings")
            elseif sender == btn_equipment then
                local openLv = DictFunctionOpen[tostring(StaticFunctionOpen.equipment)].level
                if net.InstPlayer.int["4"] < openLv then
                    UIManager.showToast(Lang.ui_homepage3 .. openLv .. Lang.ui_homepage4)
                    return
                end
                UIManager.showWidget("ui_team_info", "ui_bag_equipment")
            elseif sender == btn_card then
                UIManager.showWidget("ui_team_info", "ui_bag_card")
            elseif sender == btn_soul then
                local openLv = DictFunctionOpen[tostring(StaticFunctionOpen.fight)].level
                local lootOpen = false
                if net.InstPlayerBarrier then
                    for key, obj in pairs(net.InstPlayerBarrier) do
                        if obj.int["3"] == openLv then
                            lootOpen = true
                            break;
                        end
                    end
                end
                if lootOpen then
                    UIManager.hideWidget("ui_team_info")
                    UIManager.showWidget("ui_soul_get")
                else
                    UIManager.showToast(Lang.ui_homepage5 .. DictBarrier[tostring(openLv)].name)
                    return
                end
            -- elseif sender == btn_wing then
            --     if net.InstPlayer.int["4"] < DictFunctionOpen[tostring(StaticFunctionOpen.wing)].level then
            --         UIManager.showToast(Lang.ui_homepage6 .. DictFunctionOpen[tostring(StaticFunctionOpen.wing)].level .. Lang.ui_homepage7)
            --     else
            --         UIManager.showWidget("ui_team_info", "ui_bag_wing")
            --     end
            elseif sender == btn_gongfa then
                UIManager.showWidget("ui_team_info", "ui_bag_gongfa")
            -- elseif sender == btn_star then
            --     local level = net.InstPlayer.int["4"]
            --     if level < DictHoldStarGrade["1"].openLevel then
            --         UIManager.showToast(Lang.ui_homepage8 .. DictHoldStarGrade["1"].openLevel .. Lang.ui_homepage9)
            --     else
            --         UIManager.hideWidget("ui_team_info")
            --         UIManager.showWidget("ui_star")
            --     end
            elseif sender == btn_activity then
                UIManager.showLoading()
                netSendPackage( {
                    header = StaticMsgRule.specialDropView, msgdata = {}
                } , function(_msgData)
                    UIActivityPanel.dropAwardActivity = utils.stringSplit(_msgData.msgdata.string["1"], "|") --序号_开始时间_结束时间|...
                    UIManager.showWidget("ui_activity_panel")
                end )
            -- xzli did it 添加新ui的点击事件
            elseif sender and sender:getName() == "panel_bath" then
                UIActivityPanel.scrollByName("wash", "wash")
                UIManager.showWidget("ui_activity_panel")
            elseif sender and sender:getName() == "panel_chengjiu" then
                UIActivityPanel.scrollByName("achievement","achievement")
                UIManager.showWidget("ui_activity_panel")
            elseif sender and sender:getName() == "panel_fuben" then
                UIMenu.onFight()
            elseif sender and sender:getName() == "panel_store" then
                if net.InstPlayer.int["4"] < DictFunctionOpen[tostring(StaticFunctionOpen.hJYStoreLevel)].level then
                    UIManager.showToast(Lang.ui_homepage6 .. DictFunctionOpen[tostring(StaticFunctionOpen.hJYStoreLevel)].level .. Lang.ui_homepage7)
                else
                    UIActivityPanel.scrollByName("hJYStore","hJYStore")
                    UIManager.showWidget("ui_activity_panel")
                end
            elseif sender and sender:getName() == "panel_hundian" then
                if net.InstPlayer.int["4"] < DictFunctionOpen[tostring(StaticFunctionOpen.worldBoss)].level then
                    UIManager.showToast(Lang.ui_homepage6 .. DictFunctionOpen[tostring(StaticFunctionOpen.worldBoss)].level .. Lang.ui_homepage7)
                else
                    -- UIMenu.onActivity()
                    UIMenu.hideAll()
                    UIManager.showWidget("ui_boss","ui_menu")
                end
            elseif sender and sender:getName() == "panel_kuang" then 
                if net.InstPlayer.int["4"] < DictFunctionOpen[tostring(StaticFunctionOpen.mine)].level then
                    UIManager.showToast(Lang.ui_homepage6 .. DictFunctionOpen[tostring(StaticFunctionOpen.mine)].level .. Lang.ui_homepage7)
                else
                    -- UIMenu.onActivity()
                    UIMenu.hideAll()
                    UIManager.showWidget("ui_ore")
                end
            elseif sender and sender:getName() == "panel_wing" then
                if net.InstPlayer.int["4"] < DictFunctionOpen[tostring(StaticFunctionOpen.wing)].level then
                    UIManager.showToast(Lang.ui_homepage6 .. DictFunctionOpen[tostring(StaticFunctionOpen.wing)].level .. Lang.ui_homepage7)
                else
                    UIManager.showWidget("ui_team_info", "ui_bag_wing")
                end
            elseif sender and sender:getName() == "panel_danta" then
                if net.InstPlayer.int["4"] < DictFunctionOpen[tostring(StaticFunctionOpen.danta)].level then
                    UIManager.showToast(Lang.ui_homepage6 .. DictFunctionOpen[tostring(StaticFunctionOpen.danta)].level .. Lang.ui_homepage7)
                else
                    -- UIMenu.onActivity()
                    UIMenu.hideAll()
                    UIManager.showWidget("ui_pilltower","ui_menu")
                end
            elseif sender and sender:getName() == "panel_star" then
                local level = net.InstPlayer.int["4"]
                if level < DictHoldStarGrade["1"].openLevel then
                    UIManager.showToast(Lang.ui_homepage8 .. DictHoldStarGrade["1"].openLevel .. Lang.ui_homepage9)
                else
                    UIMenu.hideAll()
                    UIManager.showWidget("ui_star","ui_menu")
                end
            elseif sender and sender:getName() == "panel_3v3" then
                if net.InstPlayer.int["4"] < DictFunctionOpen[tostring(StaticFunctionOpen.pk3v3)].level then
                    UIManager.showToast(Lang.ui_homepage6 .. DictFunctionOpen[tostring(StaticFunctionOpen.pk3v3)].level .. Lang.ui_homepage7)
                else
                    -- UIMenu.onActivity()      
                    UIMenu.hideAll()
                    UIManager.showWidget("ui_game")
                end
            -- elseif sender == btn_email then
            --     UIActivityPanel.scrollByName("mail", "mail")
            --     UIManager.showWidget("ui_activity_panel")
            --     if btn_email:getChildByName("image_hint"):isVisible() then
            --         btn_email:getChildByName("image_hint"):setVisible(false)
            --     end
            elseif sender == btn_ranking then
                UIActivityPanel.scrollByName("rank", "rank")
                UIManager.showWidget("ui_activity_panel")
            elseif sender == btn_trial then
                UIActivityTrial.show()
            elseif sender == btn_welfare_recharge then
                UIActivityPanel.setRechargeActivity(UIActivityPanel.rechargeActivity)
                UIManager.showWidget("ui_activity_panel")
            elseif sender == btn_change then
                UIManager.hideWidget("ui_team_info")
                UIManager.showWidget("ui_activity_exchange")
                panel_main:setVisible(false)
                panel_main:getChildByName("image_gift"):setVisible(false)
            -- elseif sender == btn_talk then
            --     UIManager.pushScene("ui_talk")
            elseif sender == panel_jjc then
                local openLv = DictFunctionOpen[tostring(StaticFunctionOpen.area)].level
                if net.InstPlayer.int["4"] < openLv then
                    UIManager.showToast(Lang.ui_homepage10 .. openLv .. Lang.ui_homepage11)
                    return
                end
                UIArena.comFromMain = true
                UIManager.hideWidget("ui_team_info")
                UIManager.showWidget("ui_arena")
                UIArena.isFromMain = true
            elseif sender == panel_relic then
                local lootOpen = false
                if net.InstPlayerBarrier then
                    for key, obj in pairs(net.InstPlayerBarrier) do
                        if obj.int["3"] == 20 then
                            -- 17关开启
                            lootOpen = true
                            break;
                        end
                    end
                end
                if lootOpen then
                    UIManager.hideWidget("ui_team_info")
                    UILoot.isFromMain = true
                    UILoot.show(1, 1)
                else
                    UIManager.showToast(Lang.ui_homepage12)
                    return
                end
            elseif sender == btn_resolve then
                local openLv = DictFunctionOpen[tostring(StaticFunctionOpen.resolve)].level
                if net.InstPlayer.int["4"] < openLv then
                    UIManager.showToast(Lang.ui_homepage13 .. openLv .. Lang.ui_homepage14)
                    return
                end
                UIManager.hideWidget("ui_team_info")
                UIManager.showWidget("ui_resolve")
            elseif sender == panel_resolve then
                UIFire.show()
            elseif sender == panel_tower then
                local openLv = DictFunctionOpen[tostring(StaticFunctionOpen.tower)].level
                if net.InstPlayer.int["4"] < openLv then
                    UIManager.showToast(Lang.ui_homepage15 .. openLv .. Lang.ui_homepage16)
                    return
                end
                UIManager.hideWidget("ui_team_info")
                UIManager.showWidget("ui_tower_test")
            elseif sender == panel_alliance then
                local openLv = DictFunctionOpen[tostring(StaticFunctionOpen.union)].level
                if net.InstPlayer.int["4"] < openLv then
                    UIManager.showToast(Lang.ui_homepage17 .. openLv .. Lang.ui_homepage18)
                    return
                end
                UIAlliance.show()
            elseif sender == panel_main then
                if panel_main:getChildByName("image_more_info"):isVisible() then
                    if not isAction then
                        isAction = true
                        local action = cc.Sequence:create(cc.RotateBy:create(0.3, -180), cc.CallFunc:create( function()
                            isAction = false
                        end ))
                        -- local btn_more_arrow = btn_more:getChildByName("image_more_arrow")
                        -- btn_more_arrow:runAction(action)
                        panel_main:setVisible(false)
                        panel_main:getChildByName("image_more_info"):setVisible(false)
                        moreTag = 0
                    end
                elseif panel_main:getChildByName("image_gift"):isVisible() then
                    panel_main:setVisible(false)
                    panel_main:getChildByName("image_gift"):setVisible(false)
                    local signFlag = btn_sign:isVisible() and btn_sign:getChildByName("image_hint"):isVisible()
                    local lvFlag = btn_lv:isVisible() and btn_lv:getChildByName("image_hint"):isVisible()
                    local giftFlag = btn_gift:isVisible() and btn_gift:getChildByName("image_hint"):isVisible()
                    local awardFlag = btn_award:isVisible() and btn_award:getChildByName("image_hint"):isVisible()
                    local changeFlag = btn_change:isVisible() and btn_change:getChildByName("image_hint"):isVisible()
                    local workFlag = btn_work:isVisible() and btn_work:getChildByName("image_hint"):isVisible()
                    if signFlag or lvFlag or giftFlag or awardFlag or changeFlag or workFlag then
                        btn_fuli:getChildByName("image_hint"):setVisible(true)
                    else
                        btn_fuli:getChildByName("image_hint"):setVisible(false)
                    end
                end
            end
        end
    end

    ------------------------------ xzli --------------------------------------
     -- 页面滑动通知
    local function onPageTurning( index )
       -- none thing todo
    end
    --组装页面
    local notmoveBtns = {btn_beruty,btn_card,btn_equipment,btn_soul,btn_resolve,btn_recharge,
                        btn_activity,btn_fuli,btn_time,btn_welfare_recharge,btn_trial,btn_prize,btn_purchase,
                        btn_limit,btn_buy,btn_shouchong,btn_ranking,btn_gongfa,btn_set}
    homePageController:addButtons(notmoveBtns)
    homePageController:setButtonsCallBack(btnTouchEvent)
    homePageController:setPageCallBack(onPageTurning)
   
    ----------------------------------------------------------------------------------------
    --[[
    -- btn_email:addTouchEventListener(btnTouchEvent)
    btn_trial:addTouchEventListener(btnTouchEvent)
    btn_welfare_recharge:addTouchEventListener(btnTouchEvent)
    btn_ranking:addTouchEventListener(btnTouchEvent)
    btn_recharge:addTouchEventListener(btnTouchEvent)
    -- btn_task:addTouchEventListener(btnTouchEvent)
    btn_sign:addTouchEventListener(btnTouchEvent)
    btn_activity:addTouchEventListener(btnTouchEvent)
    btn_lv:addTouchEventListener(btnTouchEvent)
    btn_gift:addTouchEventListener(btnTouchEvent)
    btn_work:addTouchEventListener(btnTouchEvent)
    btn_award:addTouchEventListener(btnTouchEvent)
    btn_prize:addTouchEventListener(btnTouchEvent)
    btn_equipment:addTouchEventListener(btnTouchEvent)
    btn_card:addTouchEventListener(btnTouchEvent)
    btn_gongfa:addTouchEventListener(btnTouchEvent)
    btn_soul:addTouchEventListener(btnTouchEvent)
    -- btn_wing:addTouchEventListener(btnTouchEvent)
    btn_set:addTouchEventListener(btnTouchEvent)
    -- btn_talk:addTouchEventListener(btnTouchEvent)
    btn_resolve:addTouchEventListener(btnTouchEvent)
    -- btn_more:addTouchEventListener(btnTouchEvent)
    btn_time:addTouchEventListener(btnTouchEvent)
    btn_change:addTouchEventListener(btnTouchEvent)
    btn_fuli:addTouchEventListener(btnTouchEvent)
    btn_purchase:addTouchEventListener(btnTouchEvent)
    btn_limit:addTouchEventListener(btnTouchEvent)
    -- btn_star:addTouchEventListener(btnTouchEvent)

    panel_resolve:addTouchEventListener(btnTouchEvent)
    panel_relic:addTouchEventListener(btnTouchEvent)
    panel_tower:addTouchEventListener(btnTouchEvent)
    panel_jjc:addTouchEventListener(btnTouchEvent)
    panel_alliance:addTouchEventListener(btnTouchEvent)
    panel_main:addTouchEventListener(btnTouchEvent)
    ]]

    local _button = { }
    -- xzli did
    -- table.insert(_button, btn_activity)
    -- table.insert(_button, btn_fuli)
    -- table.insert(_button, btn_time)
    -- table.insert(_button, btn_welfare_recharge)
    -- table.insert(_button, btn_trial)
    -- table.insert(_button, btn_prize)
    table.insert(_button, btn_purchase)
    table.insert(_button, btn_limit)
    table.insert(_button, btn_trial)
    table.insert(_button, btn_prize)

    for key, obj in pairs(_button) do
        button_Pos[key] = {}
        button_Pos[key].x, button_Pos[key].y = obj:getPosition()
    end

    local _fuliBtn = { }
    table.insert(_fuliBtn, btn_sign)
    table.insert(_fuliBtn, btn_lv)
    table.insert(_fuliBtn, btn_gift)
    table.insert(_fuliBtn, btn_award)
    table.insert(_fuliBtn, btn_change)
    table.insert(_fuliBtn, btn_work)
    for key, obj in pairs(_fuliBtn) do
        button_Pos_Fuli[key] = { }
        button_Pos_Fuli[key].x, button_Pos_Fuli[key].y = obj:getPosition()
    end
    --xzli addbuttons
    homePageController:addImageBoxButtons(_fuliBtn)

    -- xzli lift and right
    local lift = ccui.Helper:seekNodeByName(UIHomePage.Widget, "light")
    local right = ccui.Helper:seekNodeByName(UIHomePage.Widget,"right")
    homePageController:setLiftOrRightImage(lift,true)
    homePageController:setLiftOrRightImage(right,false)
    lift:setLocalZOrder(UIHomePage.zOrder.BUTTON)
    right:setLocalZOrder(UIHomePage.zOrder.BUTTON)

    -- temp_Pos.leftX, temp_Pos.leftY = btn_prize:getPosition()
    -- temp_Pos.rightX, temp_Pos.rightY = btn_task:getPosition()

    local abs = homePageController:getAllButtons()
    for k,btn in pairs(abs) do
        btn:addTouchEventListener(btnTouchEvent)
    end
end

function UIHomePage.fireShow()
    if UIHomePage.Widget then
        local panel_resolve = ccui.Helper:seekNodeByName(UIHomePage.Widget, "panel_resolve")
        -- 异火
        if net.isShowFireTip then
            panel_resolve:getChildByName("firepaopao"):setVisible(true)
        else
            panel_resolve:getChildByName("firepaopao"):setVisible(false)
        end
    end
end

function UIHomePage.setup()
    ---------------------------xzli------------------------------
    homePageController:setup()
    
    if UIHomePage.accessCount <= 1 then
        UIHomePage.accessCount = UIHomePage.accessCount + 1
    end
    if not UITalkFly.layer then
        UITalkFly.create()
    end

    UIGuidePeople.isGuide(nil, UIHomePage)
    local btn_recharge = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_recharge")
    -- 充值按钮
    -- local btn_task = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_task")
    -- 每日任务按钮
    local btn_sign = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_sign")
    -- 签到礼包按钮
    local btn_activity = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_activity")
    -- 活动按钮
    local btn_lv = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_lv")
    -- 等级礼包按钮
    local btn_gift = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_gift")
    -- 开服礼包按钮
    local btn_award = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_award")
    -- 在线奖励按钮
    local btn_work = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_work")
    -- 节日登录礼包
    local btn_prize = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_prize")
    -- 领奖中心按钮
    local btn_equipment = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_equipment")
    -- 装备背包按钮
    local btn_card = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_card")
    -- 卡牌按钮
    local btn_gongfa = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_gongfa")
    -- 功法按钮
    local btn_soul = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_soul")
    -- 斗魂
    local btn_set = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_set")
    -- 设置按钮
    -- local btn_email = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_email")
    -- 邮件
    local btn_ranking = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_ranking")
    -- 排行榜
    local btn_trial = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_trial")
    -- 试炼日
    -- local btn_talk = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_talk")
    -- 聊天
    local btn_resolve = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_resolve")
    -- 分解
    -- local btn_more = ccui.Helper:seekNodeByName(UIHomePage.Widget, "image_more")
    -- 更多
    local image_more = ccui.Helper:seekNodeByName(UIHomePage.Widget, "image_more_info")
    -- 更多弹框
    local btn_time = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_time")
    -- 限时特惠
    local btn_change = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_change")
    -- 无敌兑换
    local btn_fuli = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_fuli")
    -- 福利
    local btn_purchase = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_purchase")
    -- 超值团购
    local btn_limit = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_limit")
    -- 充值
    local panel_main = ccui.Helper:seekNodeByName(UIHomePage.Widget, "panel")
    -- 首页弹框
    local btn_welfare_recharge = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_welfare_recharge")
    -- 充值福利
    local panel_alliance = ccui.Helper:seekNodeByName(UIHomePage.Widget, "panel_alliance")
    -- 联盟
    -- local btn_star = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_star")

    btn_resolve:getChildByName("image_hint"):setVisible(false)
    -- btn_star:getChildByName("image_hint"):setVisible(UIStar.checkImageHint())

    if net.InstPlayer.int["4"] >= 25 then
        -- zy 联盟招人
        if net.InstUnionMember and net.InstUnionMember.int["2"] ~= 0 then
            panel_alliance:getChildByName("paopao"):setVisible(false)
        else
            panel_alliance:getChildByName("paopao"):setVisible(true)
        end
    else
        panel_alliance:getChildByName("paopao"):setVisible(false)
    end
    
    UIHomePage.fireShow()

    local _button = { }
    -- xzli did
    -- table.insert(_button, btn_activity)
    -- table.insert(_button, btn_fuli)
    -- table.insert(_button, btn_time)
    -- table.insert(_button, btn_welfare_recharge)
    -- table.insert(_button, btn_trial)
    -- table.insert(_button, btn_prize)
    table.insert(_button, btn_purchase)
    table.insert(_button, btn_limit)
    table.insert(_button, btn_trial)
    table.insert(_button, btn_prize)
    local _fuliBtn = { }
    table.insert(_fuliBtn, btn_sign)
    table.insert(_fuliBtn, btn_lv)
    table.insert(_fuliBtn, btn_gift)
    table.insert(_fuliBtn, btn_award)
    table.insert(_fuliBtn, btn_change)
    table.insert(_fuliBtn, btn_work)
    -------------s----------------------------
    -- cclog("isShowMonthCardHint 月卡===== ")
    -- cclog( isShowMonthCardHint())
    if UIHomePage.isShowMonthCardHint() or UIActivityVip.checkImageHint() then
        btn_welfare_recharge:getChildByName("image_hint"):setVisible(true)
    else
        btn_welfare_recharge:getChildByName("image_hint"):setVisible(false)
        UIActivityRecharge.checkImageHint( function(showHint)
            if UIHomePage.Widget and showHint then
                btn_welfare_recharge:getChildByName("image_hint"):setVisible(true)
            end
        end )
        UIActivityVipWelfare.checkImageHint( function(showHint)
            if UIHomePage.Widget and showHint then
                btn_welfare_recharge:getChildByName("image_hint"):setVisible(true)
            end
        end )
    end
    -------------充值--------------------------------
    -- local state = UIGiftVip.getState()
    -- if state then
    -- 	btn_recharge:getChildByName("image_hint"):setVisible(true)
    -- else
    btn_recharge:getChildByName("image_hint"):setVisible(false)
    -- end
    ----精彩活动-----------------------------------
    local ActivityThings = UIActivityPanel.getActivityThing()
    if #ActivityThings == 0 then
        btn_activity:setVisible(false)
    else
        btn_activity:setVisible(true)
        local result = UIActivityBath.checkImageHint() or UIActivitySuccess.checkImageHint() or UIActivityFoundation.checkImageHint(btn_activity, true)
        local flashSaleFlag = false
        for key, obj in pairs(ActivityThings) do
            if obj.string["9"] == "lucky" then
                if UIHomePage.accessCount == 1 then
                    UIHomePage.luckyFlag = true
                end
            elseif obj.string["9"] == "SaveConsume" then
                if not result then
                    -- 如果不需要判断累计消耗就不去判断避免联网
                    UIActivityCostAll.checkImageHint(btn_activity, true)
                end
            elseif obj.string["9"] == "flashSale" then
                flashSaleFlag = UIActivityBuy.checkImageHint()
            elseif obj.string["9"] == "hJYStore" then
                flashSaleFlag = UIActivityHJY.checkImageHint()
            end
        end
        if result or UIHomePage.luckyFlag or flashSaleFlag or UIHomePage.costAllFlag then
            btn_activity:getChildByName("image_hint"):setVisible(true)
        else
            btn_activity:getChildByName("image_hint"):setVisible(false)
        end
    end
    ------每日任务------------------------------
    local signInOpen = false
    if net.InstPlayerBarrier then
        for key, obj in pairs(net.InstPlayerBarrier) do
            if obj.int["5"] == 3 and obj.int["3"] == 25 then
                --- 第三章节最后一个关卡打完才开启
                signInOpen = true
            end
        end
    end
    if net.InstPlayerDailyTask and signInOpen then
        -- btn_task:setVisible(true)
        local level = net.InstPlayer.int["4"]
        local flag = false
        for key, obj in pairs(net.InstPlayerDailyTask) do
            if obj.int["3"] < 1000 then
                local dictObj = DictDailyTask[tostring(obj.int["3"])]
                local taskLevel = 0
                if dictObj.functionOpenId == 40 then
                    taskLevel = 40
                else
                    taskLevel = DictFunctionOpen[tostring(dictObj.functionOpenId)].level
                end
                local totalTimes = dictObj.times
                local rewardTimes = obj.int["4"]
                if level >= taskLevel and obj.int["5"] == 0 and rewardTimes >= totalTimes then
                    flag = true
                end
            end
        end
        if flag then
            -- btn_task:getChildByName("image_hint"):setVisible(true)
        else
            -- btn_task:getChildByName("image_hint"):setVisible(false)
        end
    else
        -- btn_task:setVisible(false)
    end
    --------------------在线奖励---------------------------------------
    if net.InstActivityOnlineRewards and UIHomePage.flag == false then
        UIHomePage.flag = true
        local InstData = nil
        for key, obj in pairs(net.InstActivityOnlineRewards) do
            InstData = obj
        end
        if InstData.int["4"] ~= 0 then
            if UIHomePage.ScheduleId ~= nil then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(UIHomePage.ScheduleId)
            end
            btn_award:setVisible(true)
            btn_award:getChildByName("image_hint"):setVisible(false)
            UIHomePage.countDownTime = math.ceil(InstData.int["4"] / 1000)
            local ui_timeText = btn_award:getChildByName("image_base_time"):getChildByName("text_time")
            local hour = math.floor(UIHomePage.countDownTime / 3600)
            local min = math.floor(UIHomePage.countDownTime % 3600 / 60)
            local sec = UIHomePage.countDownTime % 60
            ui_timeText:setString(string.format("%02d:%02d:%02d", hour, min, sec))
            UIHomePage.ScheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(UIHomePage.updateTime, 1, false)
        else
            btn_award:setVisible(false)
        end
    elseif net.InstActivityOnlineRewards == nil and UIHomePage.flag == false then
        btn_award:setVisible(false)
    end
    --- 开服礼包 ------------
    if net.InstActivityOpenServiceBag then
        local InstData = nil
        for key, obj in pairs(net.InstActivityOpenServiceBag) do
            InstData = obj
        end
        if InstData.int["3"] == 0 and InstData.string["4"] == "" then
            btn_gift:setVisible(false)
        elseif InstData.int["3"] == 7 and InstData.string["4"] == "" then
            btn_gift:setVisible(false)
        else
            btn_gift:setVisible(true)
            if InstData.string["4"] ~= "" then
                btn_gift:getChildByName("image_hint"):setVisible(true)
            else
                btn_gift:getChildByName("image_hint"):setVisible(false)
            end
        end
    else
        btn_gift:setVisible(false)
    end

    ---$$$$$$$ 劳动节登录礼包 $$$$$$$---
    btn_work:setVisible(false)
    if net.SysActivity then
        for key, obj in pairs(net.SysActivity) do
            if obj.string["9"] == "RepeatLogin" and obj.int["8"] == 1 then
                local _startTime = obj.string["4"]
                local _endTime = obj.string["5"]
                local _curTime = utils.getCurrentTime()
                if (_startTime == "" and _endTime == "") or (utils.GetTimeByDate(_startTime) < _curTime and _curTime < utils.GetTimeByDate(_endTime)) then
                    UIHomePage.setBtnWorkPoint(false)
                    btn_work:setVisible(true)
                    netSendPackage({header=StaticMsgRule.openSevenDayLoginPanel, msgdata={}}, function(_msgData)
                        local _loginDayCount = _msgData.msgdata.int.allCount --总登陆天数
                        local _allInfo = _msgData.msgdata.string.allInfo --天数|奖励|状态(0可以领取 1是领取过)#天数|奖励|状态(0可以领取 1是领取过)
                        for key, obj in pairs(utils.stringSplit(_allInfo, "#")) do
                            local _tempData = utils.stringSplit(obj, "|")--天数|奖励|状态(0可以领取 1是领取过)
                            local _day = tonumber(_tempData[1])
                            local _state = tonumber(_tempData[3]) --0可以领取 1是领取过
                            if _state == 0 and _day <= _loginDayCount then
                                UIHomePage.setBtnWorkPoint(true)
                                break
                            end
                        end
                    end)
                end
                break
            end
        end
    end
    ---$$$$$$$ 劳动节登录礼包 $$$$$$$---

    --------等级礼包 --------------------
    local InstLevel = net.InstPlayer.int["4"]
    local number = 0
    --- 达到等级可以领取的礼包数
    local totalNumber = 0
    -- 礼包总数
    for key, obj in pairs(DictActivityLevelBag) do
        totalNumber = totalNumber + 1
        if InstLevel >= obj.id then
            number = number + 1
        end
    end
    if net.InstActivityLevelBag then
        local InstData = nil
        for key, obj in pairs(net.InstActivityLevelBag) do
            InstData = obj
        end
        if InstData.string["3"] ~= "" then
            local GetDatas = utils.stringSplit(InstData.string["3"], ";")
            --- 已经领取的
            if #GetDatas ~= totalNumber then
                btn_lv:setVisible(true)
                local num = number - #GetDatas
                if num ~= 0 then
                    btn_lv:getChildByName("image_hint"):setVisible(true)
                else
                    btn_lv:getChildByName("image_hint"):setVisible(false)
                end
            else
                btn_lv:setVisible(false)
            end
        else
            if number == 0 then
                btn_lv:getChildByName("image_hint"):setVisible(false)
            else
                btn_lv:getChildByName("image_hint"):setVisible(true)
            end
        end
    else
        if number == 0 then
            btn_lv:getChildByName("image_hint"):setVisible(false)
        else
            btn_lv:getChildByName("image_hint"):setVisible(true)
        end
    end
    --------------试炼日---------------
    if net.InstPlayer.registerTime and utils.getCurrentTime() > utils.GetTimeByDate(net.InstPlayer.registerTime) +(UIActivityTrial.ACTIVITY_DAY_COUNT * 24 * 60 * 60) then
        btn_trial:setVisible(false)
    end
    if btn_trial:isVisible() then
        UIActivityTrial.hintFlag = false
        btn_trial:getChildByName("image_hint"):setVisible(UIActivityTrial.checkImageHint(0, true))
    end
    --------------试炼日---------------
    ------------------英雄--------------------------
    utils.addImageHint(UIBagCard.checkImageHint(), btn_card, 100, 0, 0)
    ------------------------------------------------
    --------------------装备----------------------------
    utils.addImageHint(UIBagEquipment.checkImageHint(), btn_equipment, 100, 0, 0)
    ------------------------------------------------
    --------------------神羽------------------------
    -- local btn_wing = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_wing")
    -- -- 神羽 xzli todo
    -- utils.addImageHint(UIBagWing.checkImageHint(), btn_wing, 100, 0, 0)
    --------------签到礼包--------------------------
    if signInOpen then
        btn_sign:setVisible(true)
        for key, obj in pairs(net.SysActivity) do
            if obj.string["9"] == "signIn" then
                if obj.int["7"] == 0 and obj.string["4"] == "" and obj.string["5"] == "" then
                    btn_sign:setVisible(false)
                else
                    if obj.string["4"] ~= "" and obj.string["5"] ~= "" then
                        local startTime = utils.GetTimeByDate(obj.string["4"])
                        local endTime = utils.GetTimeByDate(obj.string["5"])
                        local currentTime = utils.getCurrentTime()
                        if startTime > currentTime and currentTime > endTime then
                            btn_sign:setVisible(false)
                        end
                    end
                end
                break
            end
        end
        if net.InstActivitySignIn then
            local instData = nil
            for key, obj in pairs(net.InstActivitySignIn) do
                instData = obj
            end
            local tableTime = utils.changeTimeFormat(instData.string["8"])
            -- updateTime
            if tonumber(tableTime[3]) == dp.loginDay then
                btn_sign:getChildByName("image_hint"):setVisible(false)
            else
                btn_sign:getChildByName("image_hint"):setVisible(true)
            end
        end
    else
        btn_sign:setVisible(false)
    end
    ------------领奖中心------
    local awardNumber = 0
    if net.InstPlayerAward then
        for key, obj in pairs(net.InstPlayerAward) do
            awardNumber = awardNumber + 1
        end
        btn_prize:setVisible(true)
    end
    if awardNumber == 0 then
        btn_prize:setVisible(false)
    end

    -------------------超值团购----------------------
    btn_purchase:setVisible(false)
    if net.SysActivity then
        UIHomePage.time = 0
        for key, obj in pairs(net.SysActivity) do
            if obj.string["9"] == "groupon" then
                local _startTime = obj.string["4"]
                local _endTime = obj.string["5"]
                local _currentTime = utils.getCurrentTime()
                if _startTime and _endTime and _startTime ~= "" and _endTime ~= "" and utils.GetTimeByDate(_startTime) <= _currentTime and _currentTime <= utils.GetTimeByDate(_endTime) then
                    btn_purchase:setVisible(true)
                else
                    if UIHomePage.Widget:getChildByName("ui_particlePurchase") then
                        UIHomePage.Widget:getChildByName("ui_particlePurchase"):removeFromParent()
                    end
                end
                break
            end
        end
    end

    -------------------充值----------------------
    btn_limit:setVisible(false)
    if UIHomePage.actLimitRecInfo then
        --id | 活动类型(1-任意金额,2-单笔充值,3-累计充值) | 道具信息 | 开始时间 | 结束时间 | 充值金额数 | 状态(0-不可领取,1-可领取,2-已领取) 
        local tempData = utils.stringSplit(UIHomePage.actLimitRecInfo, "|")
        local _startTime = tempData[4]
        local _endTime = tempData[5]
        local _currentTime = utils.getCurrentTime()
        if _startTime and _endTime and _startTime ~= "" and _endTime ~= "" and utils.GetTimeByDate(_startTime) <= _currentTime and _currentTime <= utils.GetTimeByDate(_endTime) then
            if not btn_purchase:isVisible() then
                btn_limit:setPositionX(btn_purchase:getPositionX())
                if UIHomePage.Widget:getChildByName("ui_particleLimit") then
                    UIHomePage.Widget:getChildByName("ui_particleLimit"):setPositionX(btn_purchase:getPositionX())
                end
            end
            if tonumber(tempData[7]) == 1 then
                UIHomePage.setBtnLimitPoint(true)
            else
                UIHomePage.setBtnLimitPoint(false)
            end
            btn_limit:setVisible(true)
        else
            if UIHomePage.Widget:getChildByName("ui_particleLimit") then
                UIHomePage.Widget:getChildByName("ui_particleLimit"):removeFromParent()
            end
        end
    end

    -------------------圣诞狂欢----------------------

    -- UIHomePage.Widget:getChildByName("christmasTree"):setVisible(false)
    -- UIHomePage.Widget:getChildByName("christmasSnow"):setVisible(false)
    panel_christmas:setVisible(false)
    ccui.Helper:seekNodeByName(UIHomePage.Widget,"christmasSnow"):setVisible(false)

    if net.SysActivity then
        for key, obj in pairs(net.SysActivity) do
            if obj.string["9"] == "Christmas" then
                local _startTime = obj.string["4"]
                local _endTime = obj.string["5"]
                local _currentTime = utils.getCurrentTime()
                if _startTime and _endTime and _startTime ~= "" and _endTime ~= "" and utils.GetTimeByDate(_startTime) <= _currentTime and _currentTime <= utils.GetTimeByDate(_endTime) then
                    panel_christmas:setVisible(true)
--                      UIHomePage.Widget:getChildByName("christmasSnow"):setVisible( true ) --废弃无用
--                     ccui.Helper:seekNodeByName(UIHomePage.Widget,"christmasSnow"):setVisible(true)
--                       AudioEngine.playMusic("sound/chirstmasHome.mp3", true)
--                                        for key , value in pairs( CustomDictWorldBoss ) do
--                                            CustomDictWorldBoss[key].cardId = 2001
--                                        end
                     -- 以上代码为开启下雪效果
                end
                break
            end
        end
    end

    -------------聊天----------------
    -- btn_talk:getChildByName("image_hint"):setVisible(false)

    ----------首冲礼包--------
    -- local isGetFirstRechargeGift = 1
    --    if isGetFirstRechargeGift == 0 then
    --    	btn_shouchong:setVisible(true)
    --    	if net.InstPlayer.int["19"] > 0 then
    --    		btn_shouchong:getChildByName("image_hint"):setVisible(true)
    --    	else
    --    		btn_shouchong:getChildByName("image_hint"):setVisible(false)
    --    	end
    --    else
    --    	btn_shouchong:setVisible(false)
    --    end
    ----------邮件---------------
    -- xzli todo 
    -- btn_email:setVisible(true)

    -- if UIHomePage.yj then
    --     btn_email:getChildByName("image_hint"):setVisible(true)
    -- else
    --     btn_email:getChildByName("image_hint"):setVisible(false)
    -- end
    -- if UIHomePage.tk then
    --     btn_talk:getChildByName("image_hint"):setVisible(true)
    -- else
    --     btn_talk:getChildByName("image_hint"):setVisible(false)
    -- end
    -- -------------更多--------------
    -- if btn_talk:getChildByName("image_hint"):isVisible() or btn_email:getChildByName("image_hint"):isVisible() then
    --     btn_more:getChildByName("image_hint"):setVisible(true)
    -- else
    --     btn_more:getChildByName("image_hint"):setVisible(false)
    -- end
    -- xzli todo btn_more

    ---------限时抢购---------------
    -- if not UIActivityBuy.isActivityEnd() then
    --  	btn_buy:setVisible(true)
    -- else
    --  	btn_buy:setVisible(false)
    -- end
    ----------排列按钮位置------------------------
    local buttons = { }
    for key, obj in pairs(_button) do
        if obj:isVisible() then
            table.insert(buttons, obj)
        end
    end
    for key, obj in pairs(buttons) do
        obj:setPosition(cc.p(button_Pos[key].x, button_Pos[key].y))
    end
    local fuliButtons = { }
    local btnCount = 0
    local btnWidth = 0
    local contentSizeWidth = 631
    local contentSizeHeight = 185
    -- 计算因为隐藏按钮而需要减少的宽度
    for key, obj in pairs(_fuliBtn) do
        if obj:isVisible() then
            table.insert(fuliButtons, obj)
        else
            btnCount = btnCount + 1
            local before = _fuliBtn[key - 1]
            if before then
                btnWidth = btnWidth + button_Pos_Fuli[key].x - button_Pos_Fuli[key - 1].x
            else
                local after = _fuliBtn[key + 1]
                if after then
                    btnWidth = button_Pos_Fuli[key + 1].x - button_Pos_Fuli[key].x
                end
            end
        end
    end
    for key, obj in pairs(fuliButtons) do
        obj:setPosition(cc.p(button_Pos_Fuli[key].x, button_Pos_Fuli[key].y))
    end
    local fuliBox = panel_main:getChildByName("image_gift")
    fuliBox:setContentSize(contentSizeWidth - btnWidth, contentSizeHeight)
    if btnCount >= 5 then
        isShowFuli = false
    else
        isShowFuli = true
    end
    -- if not btn_task:isVisible() then
    -- 	btn_prize:setPosition(cc.p(temp_Pos.rightX,temp_Pos.rightY))
    -- 	btn_task:setPosition(cc.p(temp_Pos.leftX,temp_Pos.rightY))
    -- else
    -- 	btn_prize:setPosition(cc.p(temp_Pos.leftX,temp_Pos.rightY))
    -- btn_task:setPosition(cc.p(temp_Pos.rightX, temp_Pos.rightY))
    -- end

    -----------------美人系统-------------------
    local btn_beruty = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_beruty")
    -- 美人系统按钮
    if btn_beruty:isVisible() then
        btn_beruty:getChildByName("image_hint"):setVisible(UIBeauty.isShowHint())
    end
    -----------------美人系统-------------------

    -----------------限时特惠-------------------
    local timeActivity = UIActivityTime.getActivityThing()
    local timeResult = false
    for key, obj in pairs(timeActivity) do
        if obj.sname == "grabTheHour" then
            timeResult = timeResult or UIActivityGrabTheHour.checkImageHint()
        elseif obj.sname == "LimitTimeHero" then
            if not timeResult then
                timeResult = timeResult or UIAactivityLimitTimeHero.checkImageHint()
            end
        end
    end
    btn_time:getChildByName("image_hint"):setVisible(timeResult)

    -----------------限时特惠-------------------

    -----------------无敌兑换-------------------
    if UIActivityExchange.checkImageHint() then
        btn_change:getChildByName("image_hint"):setVisible(true)
    else
        btn_change:getChildByName("image_hint"):setVisible(false)
    end
    -----------------无敌兑换-------------------

    ----------------福利----------------------
    local signFlag = btn_sign:isVisible() and btn_sign:getChildByName("image_hint"):isVisible()
    local lvFlag = btn_lv:isVisible() and btn_lv:getChildByName("image_hint"):isVisible()
    local giftFlag = btn_gift:isVisible() and btn_gift:getChildByName("image_hint"):isVisible()
    local awardFlag = btn_award:isVisible() and btn_award:getChildByName("image_hint"):isVisible()
    local changeFlag = btn_change:isVisible() and btn_change:getChildByName("image_hint"):isVisible()
    local workFlag = btn_work:isVisible() and btn_work:getChildByName("image_hint"):isVisible()
    if signFlag or lvFlag or giftFlag or awardFlag or changeFlag then
        btn_fuli:getChildByName("image_hint"):setVisible(true)
    else
        btn_fuli:getChildByName("image_hint"):setVisible(false)
    end
    ---------------福利-----------------------

    ------------------------------- 引导 ----------------------------------
    if  UIGuidePeople.guideStep == guideInfo["20B1"].step then
        UIGuidePeople.isGuide(ccui.Helper:seekNodeByName(UIHomePage.Widget,"panel_relic"),UIHomePage)
    end
    -- if  UIGuidePeople.levelStep == guideInfo["28_1"].step then
    --     homePageController:scrollToPageNow(1)
    --     UIGuidePeople.isGuide(ccui.Helper:seekNodeByName(UIHomePage.Widget,"panel_tower"),UIHomePage)
    -- else
    -- if  UIGuidePeople.guideStep == guideInfo["20B1"].step then
        -- homePageController:scrollToPageNow(1)
        -- UIGuidePeople.isGuide(ccui.Helper:seekNodeByName(UIHomePage.Widget,"panel_relic"),UIHomePage)
    -- end
    -- elseif  UIGuidePeople.levelStep == guideInfo["11_1"].step then
    --     homePageController:scrollToPageNow(0)
    --     UIGuidePeople.isGuide(ccui.Helper:seekNodeByName(UIHomePage.Widget,"panel_jjc"),UIHomePage)
    -- elseif UIGuidePeople.levelStep == guideInfo["32_1"].step then
    --     homePageController:scrollToPageNow(2)
    --     UIGuidePeople.isGuide(ccui.Helper:seekNodeByName(UIHomePage.Widget,"panel_danta"),UIHomePage)
    -- elseif UIGuidePeople.levelStep == guideInfo["22_1"].step then
    --     homePageController:scrollToPageNow(1)
    --     UIGuidePeople.isGuide(ccui.Helper:seekNodeByName(UIHomePage.Widget,"panel_kuang"),UIHomePage)
    -- end
    ------------------------------- 引导 ----------------------------------
end

function UIHomePage.setBtnWorkPoint(_visible)
    local btn_work = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_work")
    btn_work:getChildByName("image_hint"):setVisible(_visible)
end

function UIHomePage.setBtnLimitPoint(_visible)
    local btn_limit = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_limit")
    btn_limit:getChildByName("image_hint"):setVisible(_visible)
end

-- function UIHomePage.setBtnTimePoint(_visible)
-- -----------------限时特惠-------------------
-- if UIHomePage.Widget and UIHomePage.Widget:getParent() then
-- 	local btn_time = ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_time")
-- 	btn_time:getChildByName("image_hint"):setVisible(_visible)
-- end
-- UIHomePage.btn_time_RedPoint = _visible
-- -----------------限时特惠-------------------
-- end

local _closeServerCountdownTime = 0
local closeServerCountdownTimeFunc = nil
closeServerCountdownTimeFunc = function()
    _closeServerCountdownTime = _closeServerCountdownTime - 1
    if _closeServerCountdownTime < 0 then
        _closeServerCountdownTime = 0
    end
    if UIHomePage.Widget then
        local image_time = UIHomePage.Widget:getChildByName("image_time")
        local minute = math.floor(_closeServerCountdownTime / 60 % 60) --分
	    local second = math.floor(_closeServerCountdownTime % 60) --秒
        image_time:getChildByName("text_time"):setString(string.format("%02d:%02d", minute, second))
        if _closeServerCountdownTime == 0 then
            dp.removeTimerListener(countdownTimeFunc)
            image_time:setVisible(false)
        end
    end
end

function UIHomePage.free()
    cclog("---------------------------- UIHomePage.free() ---------------------------------------")
    AudioEngine.playMusic("sound/bg_music.mp3", true)
    homePageController:free()
end

function UIHomePage.updateTimer(interval)
    if _closeServerCountdownTime then
        _closeServerCountdownTime = _closeServerCountdownTime - interval
        if _closeServerCountdownTime < 0 then
            _closeServerCountdownTime = 0
        end
    end
end

function UIHomePage.showCloseServerDialog(_second)
    _closeServerCountdownTime = _second
    dp.addTimerListener(closeServerCountdownTimeFunc)
    if UIHomePage.Widget then
        UIHomePage.Widget:getChildByName("image_time"):setVisible(true)
    end
end

function UIHomePage.showFlower()
    if UIHomePage.Widget and UIHomePage.Widget:getParent() then
        local effect = UIHomePage.Widget:getChildByName( "flower" )
        if effect:isVisible() then
            effect:stopAllActions()
            effect:runAction( cc.Sequence:create( cc.DelayTime:create( 5 ) , cc.Hide:create() ) )
        else
            effect:setVisible( true )
            effect:runAction( cc.Sequence:create( cc.DelayTime:create( 5 ) , cc.Hide:create() ) )
        end
    end
end
