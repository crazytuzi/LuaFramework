require"Lang"
UIFightTask = { }
-- 364 = 1500 - 1136 568 = 1136/2  1136屏幕高 1500 图高
local screenHeight = cc.Director:getInstance():getVisibleSize().height
local outScreenHeight = 0
local middleHeight = 0 
if screenHeight == 1136 then
    outScreenHeight = 364
    middleHeight = 568
elseif screenHeight == 960 then
    outScreenHeight = 540
    middleHeight = 480
end
local chapterId = nil
local Particle = { }
local image_basemap = nil
local Item = nil
local Type = nil
local basemapPercent = nil
local btn_trial = nil
local _isShowPosterDialog = nil
UIFightTask.stopTaskAni = nil -- 在意外获得界面显示的时候不播放动画，消失后才播放动画
-----------------用于从命宫跳转过来后，按返回键回到命宫界面--------------------------
UIFightTask.isFromMedicine = false

local function netCallbackFunc(pack)
    local things = nil
    if Type == 1 then
        local image_gold = ccui.Helper:seekNodeByName(UIFightTask.Widget, "image_gold")
        image_gold:loadTexture("ui/fb_bx_empty.png")
        things = utils.stringSplit(DictChapter[tostring(chapterId)].thingsOne, ";")
        if Particle[1] then
            Particle[1]:removeFromParent()
            Particle[1] = nil
        end
    elseif Type == 2 then
        local image_box_common = ccui.Helper:seekNodeByName(UIFightTask.Widget, "image_box_common")
        image_box_common:loadTexture("ui/fb_bx01_empty.png")
        things = utils.stringSplit(DictChapter[tostring(chapterId)].thingsTwo, ";")
        if Particle[2] then
            Particle[2]:removeFromParent()
            Particle[2] = nil
        end
    elseif Type == 3 then
        local image_box_special = ccui.Helper:seekNodeByName(UIFightTask.Widget, "image_box_special")
        image_box_special:loadTexture("ui/fb_bx02_empty.png")
        things = utils.stringSplit(DictChapter[tostring(chapterId)].thingsThree, ";")
        if Particle[3] then
            Particle[3]:removeFromParent()
            Particle[3] = nil
        end
    end
    Type = nil
    if things then
        UIAwardGet.setOperateType(UIAwardGet.operateType.award, things)
        UIManager.pushScene("ui_award_get")
    end
end
local function sendOpenBoxRequest(_instPlayerChapterId, _type)
    Type = _type
    local sendData = nil
    if UIGuidePeople.guideStep == "8B2" then
        sendData = {
            header = StaticMsgRule.chapterOpenBox,
            msgdata =
            {
                int =
                {
                    instPlayerChapterId = _instPlayerChapterId,
                    type = _type
                },
                string =
                {
                    step = "8B3"
                }
            }
        }
    else
        sendData = {
            header = StaticMsgRule.chapterOpenBox,
            msgdata =
            {
                int =
                {
                    instPlayerChapterId = _instPlayerChapterId,
                    type = _type
                }
            }
        }
    end
    UIManager.showLoading()
    netSendPackage(sendData, netCallbackFunc)
end

local function setScrollViewItem(_Item, obj, _isNewBarrier)
    local barrierId = nil
    local barrierLevel = nil
    local function TouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if not obj.name then
                local view_basemap = ccui.Helper:seekNodeByName(UIFightTask.Widget, "view_basemap")
                local basemapPosY = cc.p(view_basemap:getInnerContainer():getPosition()).y
                basemapPercent =(basemapPosY + outScreenHeight) / outScreenHeight * 100
            else
                basemapPercent = nil
            end
            local function FightChoose()
                --------------------临时解决方案--------------------
                local _tempIsNewBarrier = true
                if net.InstPlayerBarrier then
                    local _bId = obj.id and obj.id or obj.int["3"]
                    for _ipbKey, _ipbObj in pairs(net.InstPlayerBarrier) do
                        if _bId == _ipbObj.int["3"] then
                            _tempIsNewBarrier = false
                            break
                        end
                    end
                end
                if obj.name and _isNewBarrier and _tempIsNewBarrier then
                    --------------------临时解决方案--------------------
                    -- if obj.name then
                    UIGuidePeople.newBarrier = true
                else
                    UIGuidePeople.newBarrier = nil
                end
                if UIGuidePeople.guideStep and UIGuidePeople.guideStep ~= guideInfo["15B5"].step then
                    sender:retain()
                    local barrierLevelId = nil
                    for key, obj in pairs(DictBarrierLevel) do
                        if obj.barrierId == barrierId then
                            barrierLevelId = obj.id
                        end
                    end
                    local param = { }
                    param.barrierLevelId = barrierLevelId
                    param.chapterId = chapterId
                    param.barrierId = barrierId
                    if UIGuidePeople.guideStep and FightTaskData.FightData[chapterId] and FightTaskData.FightData[chapterId][barrierId] then
                        FightTaskData.FightData[chapterId][barrierId].record = nil
                        UIFightMain.setData(FightTaskData.FightData[chapterId][barrierId], param, dp.FightType.FIGHT_TASK.COMMON)
                        UIFightMain.loading()
                    else
                        utils.sendFightData(param, dp.FightType.FIGHT_TASK.COMMON)
                        UIFightMain.loading()
                        if barrierId == 9 then
                            UIFightTask.setShowPoster(true, barrierId)
                        end
                    end
                    if UIGuidePeople.guideStep == guideInfo["8B5"].step then
                        UIGuidePeople.guideStep = nil
                    end
                    cc.release(sender)
                else
                    UIFightTaskChoose.setData(obj)
                    UIManager.pushScene("ui_fight_task_choose")
                end
            end
            local taskStory = FightTaskInfo.getData(chapterId, barrierId)
            if obj.name ~= nil and taskStory ~= nil then
                --- 新关卡才会执行这个
                if taskStory["begin"] ~= nil and taskStory["begin"].flag == nil then
                    UIGuideInfo.PlayStory(taskStory, 1, "begin", FightChoose)
                else
                    FightChoose()
                end
            else
                FightChoose()
            end
        end
    end
    local image_boss_star = { }
    local image_base_di = _Item:getChildByName("image_base_di")
    local ui_name = image_base_di:getChildByName("text_noss_name")
    local ui_image_frame = _Item:getChildByName("image_frame_boss")
    image_boss_star[1] = _Item:getChildByName("image_boss_star1")
    image_boss_star[2] = _Item:getChildByName("image_boss_star2")
    image_boss_star[3] = _Item:getChildByName("image_boss_star3")
    local image_win = _Item:getChildByName("image_win")
    local ui_image = cc.Sprite:create()
    if obj.name ~= nil then
        --- 最后一条实例数据
        barrierId = obj.id
        barrierLevel = 0
    else
        barrierId = obj.int["3"]
        barrierLevel = obj.int["6"]
    end

    local cardId = DictBarrier[tostring(barrierId)].cardId
    local smallUiId = DictCard[tostring(cardId)].smallUiId
    local imageName = DictUI[tostring(smallUiId)].fileName
    local name = DictBarrier[tostring(barrierId)].name
    local barrierType = DictBarrier[tostring(barrierId)].type
    if barrierType == 1 then
        local pos1 = cc.p(image_base_di:getPosition())
        local pos2 = cc.p(image_boss_star[1]:getPosition())
        local pos3 = cc.p(image_boss_star[2]:getPosition())
        local pos4 = cc.p(image_boss_star[3]:getPosition())
        image_base_di:setPosition(cc.p(pos1.x, pos1.y - 10))
        image_boss_star[1]:setPosition(cc.p(pos2.x, pos2.y - 10))
        image_boss_star[2]:setPosition(cc.p(pos3.x, pos3.y - 10))
        image_boss_star[3]:setPosition(cc.p(pos4.x, pos4.y - 10))
        ui_image_frame:loadTexture("ui/task_frame_louluo.png")
    elseif barrierType == 2 then
        ui_image_frame:loadTexture("ui/task_frame_jingying.png")
    elseif barrierType == 3 then
        ui_image_frame:loadTexture("ui/task_frame_boss.png")
    end
    ui_image:setTexture("image/" .. imageName)
    ui_name:setString(name)
    local maxBarrierLevel = { level = 0 }
    for key, obj in pairs(DictBarrierLevel) do
        if obj.barrierId == barrierId then
            if obj.level > maxBarrierLevel.level then
                maxBarrierLevel = obj
            end
        end
    end
    local star1_x, star1_y = image_boss_star[1]:getPosition()
    local star2_x, star2_y = image_boss_star[2]:getPosition()
    image_win:setVisible(barrierLevel == 4)
    image_win:setLocalZOrder(1)
    for i = 1, 3 do
        if i <= barrierLevel then
            image_boss_star[i]:loadTexture("ui/fb_xing.png")
        else
            image_boss_star[i]:loadTexture("ui/fb_xing1.png")
        end
        if maxBarrierLevel.level == 1 then
            image_boss_star[1]:show():setPosition(cc.p(star1_x + 30, star1_y))
            image_boss_star[2]:setVisible(false)
            image_boss_star[3]:setVisible(false)
        elseif maxBarrierLevel.level == 2 then
            image_boss_star[1]:show():setPosition(cc.p(star1_x + 15, star1_y))
            image_boss_star[2]:show():setPosition(cc.p(star2_x + 15, star2_y))
            image_boss_star[3]:setVisible(false)
        end
    end
    ui_image_frame:addTouchEventListener(TouchEvent)
    local pMask = cc.Sprite:create("ui/task_black.png");
    local pRt = cc.ClippingNode:create()
    pRt:setStencil(pMask)
    pRt:setAlphaThreshold(0)
    _Item:addChild(pRt)
    pRt:addChild(ui_image)
    pRt:setPosition(_Item:getContentSize().width / 2, _Item:getContentSize().height / 2 + 15);
end
----是否领取-----
local function isGetAward(_type)
    local getThingTable = { }
    if net.InstPlayerChapter then
        for key, obj in pairs(net.InstPlayerChapter) do
            if obj.int["3"] == chapterId then
                if obj.string ~= nil then
                    if obj.string["7"] then
                        getThingTable = utils.stringSplit(obj.string["7"], ";")
                    end
                end
            end
        end
    end
    if next(getThingTable) then
        for key, obj in pairs(getThingTable) do
            if _type == tonumber(obj) then
                return true
            end
        end
    end
    return false
end
-----已获得星数----
local function haveGetStarNum()
    local barrierNum = 0
    if net.InstPlayerChapter then
        for key, obj in pairs(net.InstPlayerChapter) do
            if obj.int["3"] == chapterId then
                barrierNum = obj.int["5"]
                return barrierNum
            end
        end
    end
    return barrierNum
end
--- 宝箱物品信息--------
local function TaskGetThingDialog(type)
    local getFlag = isGetAward(type)
    local needStarNum = 0
    local things = { }
    local _things = { }
    if type == 1 then
        needStarNum = DictChapter[tostring(chapterId)].starOne
        _things = utils.stringSplit(DictChapter[tostring(chapterId)].thingsOne, ";")
    elseif type == 2 then
        needStarNum = DictChapter[tostring(chapterId)].starTwo
        _things = utils.stringSplit(DictChapter[tostring(chapterId)].thingsTwo, ";")
    elseif type == 3 then
        needStarNum = DictChapter[tostring(chapterId)].starThree
        _things = utils.stringSplit(DictChapter[tostring(chapterId)].thingsThree, ";")
    end
    for key, obj in pairs(_things) do
        things[#things + 1] = utils.stringSplit(obj, "_")
    end
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
    bg_image:retain()
    bg_image:setAnchorPoint(cc.p(0.5, 0.5))
    bg_image:setPreferredSize(cc.size(500, 380))
    bg_image:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2))
    local bgSize = bg_image:getPreferredSize()

    local title = ccui.Text:create()
    title:setString(Lang.ui_fight_task1)
    title:setFontName(dp.FONT)
    title:setFontSize(30)
    title:setTextColor(cc.c4b(255, 255, 0, 255))
    title:setPosition(cc.p(bgSize.width / 2, bgSize.height - title:getContentSize().height))
    bg_image:addChild(title, 3)
    local msgLabel = ccui.Text:create()
    msgLabel:setString(Lang.ui_fight_task2 .. needStarNum .. Lang.ui_fight_task3)
    msgLabel:setFontName(dp.FONT)
    msgLabel:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    msgLabel:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    msgLabel:setFontSize(26)
    msgLabel:setTextColor(cc.c4b(255, 255, 255, 255))
    msgLabel:setPosition(cc.p(bgSize.width / 2, bgSize.height - title:getContentSize().height * 3))
    bg_image:addChild(msgLabel, 3)

    for key, obj in pairs(things) do
        local node = cc.Node:create()
        local image_di = ccui.ImageView:create("ui/quality_small_blue.png")
        local image = ccui.ImageView:create()
        local description = ccui.Text:create()
        description:setFontSize(20)
        description:setFontName(dp.FONT)
        description:setAnchorPoint(cc.p(0.5, 1))
        image:setPosition(cc.p(image_di:getContentSize().width / 2, image_di:getContentSize().height / 2))
        image_di:addChild(image)
        image_di:setPosition(cc.p(0, 0))
        description:setPosition(cc.p(0, - image_di:getContentSize().height / 2 - 5))
        node:addChild(image_di)
        node:addChild(description)
        node:setPosition(cc.p(image_di:getContentSize().width * key - 30, bgSize.height * 0.5))
        bg_image:addChild(node, 3)
        local tableTypeId, tableFieldId, thingNum = obj[1], obj[2], obj[3]
        utils.addBorderImage(tableTypeId, tableFieldId, image_di)
        local text_number = ccui.ImageView:create("ui/tk_di_shuzi.png")
        local number = ccui.Text:create()
        number:setFontSize(26)
        number:setFontName(dp.FONT)
        number:setPosition(cc.p(text_number:getBoundingBox().width / 2, text_number:getBoundingBox().height / 2))
        text_number:setScale(0.7)
        text_number:setPosition(cc.p(image_di:getBoundingBox().width - text_number:getBoundingBox().width / 2,
        image_di:getBoundingBox().height - text_number:getBoundingBox().height / 2))
        local name, Icon = utils.getDropThing(tableTypeId, tableFieldId)
        image:loadTexture(Icon)
        description:setString(name)
        number:setString(thingNum)
        image_di:addChild(text_number)
        text_number:addChild(number)
    end
    local closeBtn = ccui.Button:create("ui/btn_x.png", "ui/btn_x.png")
    closeBtn:setPosition(cc.p(bgSize.width - closeBtn:getContentSize().width / 2, bgSize.height - closeBtn:getContentSize().height / 2))
    bg_image:addChild(closeBtn, 3)
    local sureBtn = ccui.Button:create("ui/tk_btn01.png", "ui/tk_btn01.png")
    sureBtn:setPressedActionEnabled(true)
    closeBtn:setPressedActionEnabled(true)
    sureBtn:setTitleFontSize(25)
    sureBtn:setTitleFontName(dp.FONT)
    local barrierNum = haveGetStarNum()
    if barrierNum >= needStarNum then
        sureBtn:setEnabled(true)
    else
        sureBtn:setEnabled(false)
        utils.GrayWidget(sureBtn, true)
    end
    sureBtn:setPosition(cc.p(bgSize.width / 2, sureBtn:getContentSize().height))
    bg_image:addChild(sureBtn, 3)
    if getFlag == true then
        sureBtn:setTitleText(Lang.ui_fight_task4)
        utils.GrayWidget(sureBtn, true)
        sureBtn:setEnabled(false)
    else
        sureBtn:setTitleText(Lang.ui_fight_task5)
    end
    local guide = nil
    local function btnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == sureBtn then
                if net.InstPlayerChapter then
                    for key, obj in pairs(net.InstPlayerChapter) do
                        if obj.int["3"] == chapterId then
                            sendOpenBoxRequest(obj.int["1"], type)
                        end
                    end
                end
            end
            UIManager.uiLayer:removeChild(bg_image, true)
            cc.release(bg_image)
            UIFightTask.Widget:setEnabled(true)
            if guide then
                UIManager.flushWidget(UIFightTask)
            end
        end
    end
    sureBtn:addTouchEventListener(btnEvent)
    closeBtn:addTouchEventListener(btnEvent)
    UIManager.uiLayer:addChild(bg_image, 99)
    UIFightTask.Widget:setEnabled(false)
    if UIGuidePeople.levelStep == guideInfo["20_8"].step then
        guide = true
        UIGuidePeople.isGuide(closeBtn, UIFightTask)
    else
        UIGuidePeople.isGuide(sureBtn, UIFightTask)
    end
end

function UIFightTask.init()
    local btn_back = ccui.Helper:seekNodeByName(UIFightTask.Widget, "btn_back")
    local btn_embattle = ccui.Helper:seekNodeByName(UIFightTask.Widget, "btn_embattle")
    local btn_rank = ccui.Helper:seekNodeByName(UIFightTask.Widget, "btn_rank")
    local btn_win = ccui.Helper:seekNodeByName(UIFightTask.Widget, "btn_win")
    btn_back:setPressedActionEnabled(true)
    btn_embattle:setPressedActionEnabled(true)
    btn_rank:setPressedActionEnabled(true)
    btn_win:setPressedActionEnabled(true)
    local image_gold = ccui.Helper:seekNodeByName(UIFightTask.Widget, "image_gold")
    local image_box_common = ccui.Helper:seekNodeByName(UIFightTask.Widget, "image_box_common")
    local image_box_special = ccui.Helper:seekNodeByName(UIFightTask.Widget, "image_box_special")
    -- 开服狂欢
    btn_trial = ccui.Button:create("ui/home_trial.png", "ui/home_trial.png")
    btn_trial:setPosition(cc.p(UIManager.screenSize.width - 60, UIManager.screenSize.height - 220))
    -- 创建粒子
    local particleTrial = cc.ParticleSystemQuad:create("particle/shouye_action_effect_slstar.plist")
    particleTrial:setPosition(cc.p(btn_trial:getContentSize().width / 2, btn_trial:getContentSize().height * 0.4))
    particleTrial:setScale(0.8)
    btn_trial:addChild(particleTrial)
    UIFightTask.Widget:addChild(btn_trial, 1)

    image_basemap = ccui.Helper:seekNodeByName(UIFightTask.Widget, "image_basemap")
    Item = image_basemap:getChildByName("image_shadow"):clone()
    local function TouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                if UIFightTask.isFromMedicine then
                    UIFightTask.isFromMedicine = false
                    basemapPercent = nil
                    UIManager.showWidget("ui_notice", "ui_lineup")
                    UIManager.showWidget("ui_menu")
                    UIManager.pushScene("ui_card_info")
                    local btn_medicine = ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_medicine")
                    btn_medicine:releaseUpEvent()
                    UIManager.pushScene("ui_medicine_alchemy")
                else
                    basemapPercent = nil
                    UIFight.jumpToChapterId = chapterId
                    UIManager.showScreen("ui_notice", "ui_team_info", "ui_fight", "ui_menu")
                    AudioEngine.playMusic("sound/bg_music.mp3", true)
                end
            elseif sender == btn_embattle then
                if net.InstPlayer.int["4"] >= DictFunctionOpen[ tostring( StaticFunctionOpen.partner ) ].level then
                    UIManager.pushScene("ui_lineup_embattle")
                else
                    UIManager.pushScene("ui_lineup_embattle_old")
                end
            elseif sender == btn_rank then
                UIManager.pushScene("ui_fight_rank")
            elseif sender == btn_win then
                UIActivityExchange.startBase = 5
                UIManager.showWidget("ui_activity_exchange")
                UIManager.showWidget("ui_menu")
            elseif sender == image_gold then
                TaskGetThingDialog(1)
            elseif sender == image_box_common then
                TaskGetThingDialog(2)
            elseif sender == image_box_special then
                TaskGetThingDialog(3)
            elseif sender == btn_trial then
                UIActivityTrial.show(true)
            end
        end
    end
    btn_trial:addTouchEventListener(TouchEvent)
    btn_back:addTouchEventListener(TouchEvent)
    btn_embattle:addTouchEventListener(TouchEvent)
    btn_rank:addTouchEventListener(TouchEvent)
    btn_win:addTouchEventListener(TouchEvent)
    image_gold:addTouchEventListener(TouchEvent)
    image_box_common:addTouchEventListener(TouchEvent)
    image_box_special:addTouchEventListener(TouchEvent)
    if net.InstPlayerBarrier then
        for key, obj in pairs(net.InstPlayerBarrier) do
            local _chapterId = obj.int["5"]
            local _barrierId = obj.int["3"]
            local taskStory = FightTaskInfo.getData(_chapterId, _barrierId)
            if taskStory ~= nil then
                if taskStory["ended"] and taskStory["ended"].flag == nil then
                    taskStory["ended"].flag = true
                end
                if taskStory["middle"] and taskStory["middle"].flag == nil then
                    taskStory["middle"].flag = true
                end
            end
        end
    end
end

local function scrollToPercentVertical(view_basemap, pos)
    if not basemapPercent then
        local Percent =(outScreenHeight + middleHeight - pos) / outScreenHeight * 100
        if Percent > 0 then
            view_basemap:scrollToPercentVertical(Percent, 0.00001, false);
        else
            view_basemap:scrollToTop(0.00001, false)
        end
    end
end

function UIFightTask.setBasemapPercent(_basemapPercent)
    basemapPercent = _basemapPercent
end
----显示宝箱信息---
local function showBoxInfo(image, image_star, image_num, starNum, _type, barrierNum)
    if starNum == 0 then
        image:setVisible(false)
        image_star:setVisible(false)
    else
        image:setVisible(true)
        image_star:setVisible(true)
        if barrierNum < starNum then
            local imageName =(_type == 1 and "fb_bx") or(_type == 2 and "fb_bx01") or(_type == 3 and "fb_bx02")
            image:loadTexture(string.format("ui/%s.png", imageName))
        else
            if isGetAward(_type) then
                local imageName =(_type == 1 and "fb_bx_empty") or(_type == 2 and "fb_bx01_empty") or(_type == 3 and "fb_bx02_empty")
                image:loadTexture(string.format("ui/%s.png", imageName))
            else
                local imageName =(_type == 1 and "fb_bx_full") or(_type == 2 and "fb_bx01_full") or(_type == 3 and "fb_bx02_full")
                image:loadTexture(string.format("ui/%s.png", imageName))
                if not Particle[_type] then
                    Particle[_type] = cc.ParticleSystemQuad:create("particle/ui_anim_effect27.plist")
                    Particle[_type]:setPosition(cc.p(image:getContentSize().width / 2, image:getContentSize().height / 2))
                    Particle[_type]:setScale(1.5)
                    image:addChild(Particle[_type])
                end
            end
        end
    end
    image_num:setString(starNum)
end
----新关卡动画
local function barrierTaskAnimal(barrierId, _Item)
    local cardId = DictBarrier[tostring(barrierId)].cardId
    local smallUiId = DictCard[tostring(cardId)].smallUiId
    local imageName = DictUI[tostring(smallUiId)].fileName
    local barrierType = DictBarrier[tostring(barrierId)].type
    local pMask = cc.Sprite:create("ui/task_black.png");
    local ui_image = cc.Sprite:create();
    local ui_frame = ccui.ImageView:create()
    ui_image:setTexture("image/" .. imageName)
    ui_frame:setAnchorPoint(cc.p(0.5, 0.9))
    if barrierType == 1 then
        ui_frame:loadTexture("ui/task_frame_louluo.png")
    elseif barrierType == 2 then
        ui_frame:loadTexture("ui/task_frame_jingying.png")
    elseif barrierType == 3 then
        ui_frame:loadTexture("ui/task_frame_boss.png")
    end

    local function callbackFunc_after(last_armature)
        last_armature:removeFromParent()
        local armature = ActionManager.getEffectAnimation(20)
        armature:setPosition(_Item:getPosition())
        image_basemap:addChild(armature)
        image_basemap:addChild(_Item)
        UIGuidePeople.isGuide(_Item:getChildByName("image_frame_boss"), UIFightTask)
        cc.release(_Item)
    end
    local armature = ActionManager.getUIAnimation(21, callbackFunc_after)

    local pRt = cc.ClippingNode:create()
    pRt:setStencil(pMask)
    pRt:setAlphaThreshold(0)
    pRt:addChild(ui_image)

    armature:getBone("image"):addDisplay(pRt, 0)
    armature:getBone("frame"):addDisplay(ui_frame, 0)
    armature:setPosition(_Item:getPosition())
    image_basemap:addChild(armature)
end

local function setBoxItem(key, obj)
    local pointX = DictBarrier[tostring(obj.id)].boxX
    local pointY = DictBarrier[tostring(obj.id)].boxY
    local subPosY = image_basemap:getContentSize().height - pointY
    ----策划是以图片左上角为原点
    local armature = ActionManager.getEffectAnimation(37)
    local function onTouchBegan(touch, event)
        local locationInNode = event:getCurrentTarget():convertToNodeSpace(touch:getLocation())
        local rect = cc.rect(-50, -50, 100, 100)
        if cc.rectContainsPoint(rect, locationInNode) then
            return true
        else
            return false
        end
    end
    local function onTouchMoved(touch, event)
    end
    local function onTouchEnded(touch, event)
        UIAwardGet.setOperateType(UIAwardGet.operateType.box, obj, UIFightTask)
        UIManager.pushScene("ui_award_get")
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    -- 创建一个触摸监听(单点触摸）
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = armature:getEventDispatcher()
    if not UIGuidePeople.guideStep and not UIGuidePeople.levelStep then
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, armature)
    end
    local barrierId = obj.id
    local instThing = nil
    if net.InstPlayerBarrier then
        for key, obj in pairs(net.InstPlayerBarrier) do
            if obj.int["5"] == chapterId and obj.int["3"] == barrierId then
                instThing = obj
                break
            end
        end
    end
    if instThing then
        if instThing.int["9"] == 1 then
            armature:getAnimation():playWithIndex(0)
        elseif instThing.int["9"] == 2 then
            armature:getAnimation():playWithIndex(2)
        end
    else
        armature:getAnimation():playWithIndex(1)
    end
    armature:setPosition(pointX, subPosY)
    image_basemap:addChild(armature, 1)
    obj.key = key
    armature:setName("box" .. key)
end

function UIFightTask.onEnter()
    if Item:getReferenceCount() == 1 then
        Item:retain()
    end
    if net.InstPlayer.registerTime and utils.getCurrentTime() > utils.GetTimeByDate(net.InstPlayer.registerTime) +(UIActivityTrial.ACTIVITY_DAY_COUNT * 24 * 60 * 60) then
        btn_trial:setVisible(false)
    end

    local view_basemap = ccui.Helper:seekNodeByName(UIFightTask.Widget, "view_basemap")
    view_basemap:setBounceEnabled(false)
    local backGroundPictureD = DictChapter[tostring(chapterId)].backGroundPictureD
    image_basemap:loadTexture("image/" .. backGroundPictureD)
    view_basemap:setInnerContainerSize(cc.size(image_basemap:getContentSize().width, image_basemap:getContentSize().height))

    image_basemap:setPosition(cc.p(0, 0))
    view_basemap:getInnerContainer():setPosition(cc.p(0, - outScreenHeight))
    if basemapPercent then
        view_basemap:scrollToPercentVertical(basemapPercent, 0.00001, false);
    else
        view_basemap:scrollToBottom(0.00001, false)
    end
    UIFightTask.free()
    local ui_Level = ccui.Helper:seekNodeByName(UIFightTask.Widget, "label_lv")
    local ui_bar_lv = ccui.Helper:seekNodeByName(UIFightTask.Widget, "bar_lv")
    local ui_barLvLabel = ui_bar_lv:getChildByName("text_lv")
    local ui_bar_strength = ccui.Helper:seekNodeByName(UIFightTask.Widget, "bar_strength")
    local ui_barStrengthLabel = ui_bar_strength:getChildByName("text_strength")
    local ui_task_name = ccui.Helper:seekNodeByName(UIFightTask.Widget, "text_task_name")
    local ui_getstar_number = ccui.Helper:seekNodeByName(UIFightTask.Widget, "text_get_number")
    local ui_bar_star = ccui.Helper:seekNodeByName(UIFightTask.Widget, "image_base_star")
    local image_gold = ui_bar_star:getChildByName("image_gold")
    local image_box_common = ui_bar_star:getChildByName("image_box_common")
    local image_box_special = ui_bar_star:getChildByName("image_box_special")
    local image_gold_star = ui_bar_star:getChildByName("image_gold_star")
    local image_box_common_star = ui_bar_star:getChildByName("image_box_common_star")
    local image_box_special_star = ui_bar_star:getChildByName("image_box_special_star")
    local image_gold_star_number = image_gold_star:getChildByName("image_gold_star_number")
    local image_box_common_star_number = image_box_common_star:getChildByName("image_box_common_star_number")
    local image_box_special_star_number = image_box_special_star:getChildByName("image_box_special_star_number")
    ui_bar_strength:setPercent(utils.getPercent(net.InstPlayer.int["8"], net.InstPlayer.int["9"]))
    ui_barStrengthLabel:setString(net.InstPlayer.int["8"] .. "/" .. net.InstPlayer.int["9"])
    ui_Level:setString(net.InstPlayer.int["4"])
    local InstPlayerNowLevel = net.InstPlayer.int["4"]
    local nowExp = net.InstPlayer.int["7"]
    local ExpNowLevelValue = 0
    if DictLevelProp[tostring(InstPlayerNowLevel)] ~= nil then
        ExpNowLevelValue = DictLevelProp[tostring(InstPlayerNowLevel)].fleetExp
    end
    ui_bar_lv:setPercent(utils.getPercent(nowExp, ExpNowLevelValue))
    ui_barLvLabel:setString(nowExp .. "/" .. ExpNowLevelValue)
    local name = DictChapter[tostring(chapterId)].name
    local starOne = DictChapter[tostring(chapterId)].starOne
    local starTwo = DictChapter[tostring(chapterId)].starTwo
    local starThree = DictChapter[tostring(chapterId)].starThree
    local starNum = DictChapter[tostring(chapterId)].starNum
    local barrierNum = haveGetStarNum()
    showBoxInfo(image_gold, image_gold_star, image_gold_star_number, starOne, 1, barrierNum)
    showBoxInfo(image_box_common, image_box_common_star, image_box_common_star_number, starTwo, 2, barrierNum)
    showBoxInfo(image_box_special, image_box_special_star, image_box_special_star_number, starThree, 3, barrierNum)
    ui_task_name:setString(name)
    ui_getstar_number:setString(barrierNum .. "/" .. starNum)
    local boxThing = { }
    for key, obj in pairs(DictBarrier) do
        if obj.chapterId == chapterId and obj.welfareBox ~= "" then
            table.insert(boxThing, obj)
        end
        utils.quickSort(boxThing, function(obj1, obj2)
            return obj1.id > obj2.id
        end )
    end

    local TaskThing = { }
    if net.InstPlayerBarrier then
        for key, obj in pairs(net.InstPlayerBarrier) do
            if obj.int["5"] == chapterId then
                table.insert(TaskThing, obj)
            end
        end
    end
    utils.quickSort(TaskThing, function(obj1, obj2)
        return obj1.int["3"] > obj2.int["3"]
    end )

    local maxBarrierId = 0
    local maxBarrierLevel = 0
    local spBatchNode = nil
    local space = 50
    if next(TaskThing) then
        spBatchNode = cc.Node:create()
        spBatchNode:setPosition(cc.p(0, 0))
        image_basemap:addChild(spBatchNode)
        for key, obj in pairs(TaskThing) do
            local _Item = Item:clone()
            setScrollViewItem(_Item, obj)
            local barrierId = obj.int["3"]
            if maxBarrierId < barrierId then
                maxBarrierId = barrierId
                maxBarrierLevel = obj.int["6"]
            end
            local pointX = DictBarrier[tostring(barrierId)].x
            local pointY = DictBarrier[tostring(barrierId)].y
            local subPosY = image_basemap:getContentSize().height - pointY
            ----策划是以图片左上角为原点
            _Item:setPosition(cc.p(pointX, subPosY))
            image_basemap:addChild(_Item, 1)
            local startP = cc.p(pointX, subPosY)
            local endP = nil
            if TaskThing[key + 1] then
                local _barrierId = TaskThing[key + 1].int["3"]
                local _pointX = DictBarrier[tostring(_barrierId)].x
                local _pointY = DictBarrier[tostring(_barrierId)].y
                local _subPosY = image_basemap:getContentSize().height - _pointY
                endP = cc.p(_pointX, _subPosY)
            end
            if startP and endP then
                local dis = cc.pGetDistance(startP, endP)
                local count = math.floor(dis / space)
                for i = 1, count - 1 do
                    local sp = cc.Sprite:create("ui/fb_dian.png");
                    sp:setPosition(cc.p(startP.x + i *(endP.x - startP.x) / count, startP.y + i *(endP.y - startP.y) / count));
                    spBatchNode:addChild(sp);
                end
            end
        end
    end
    cclog("maxBarrierId=" .. maxBarrierId)
    if next(boxThing) then
        for key, obj in pairs(boxThing) do
            setBoxItem(key, obj)
        end
    end
    if not UIFightTask.stopTaskAni then
        if maxBarrierId ~= 0 then
            if maxBarrierLevel ~= 0 then
                local lastBarrierId = DictBarrier[tostring(maxBarrierId)].barrierId
                if lastBarrierId == 0 then
                    --- 打完整个副本
                    if not basemapPercent then
                        view_basemap:scrollToTop(0.00001, false)
                    end
                    return
                end
                local lastBarrier = DictBarrier[tostring(lastBarrierId)]
                if lastBarrier.chapterId == chapterId then
                    --- 新关卡
                    local _Item = Item:clone()
                    setScrollViewItem(_Item, lastBarrier, true)
                    local pointX = DictBarrier[tostring(lastBarrierId)].x
                    local pointY = DictBarrier[tostring(lastBarrierId)].y
                    local subPosY = image_basemap:getContentSize().height - pointY
                    ----策划是以图片左上角为原点
                    _Item:setPosition(cc.p(pointX, subPosY))
                    local startP = nil
                    local endP = cc.p(pointX, subPosY)
                    if spBatchNode then
                        local _barrierId = TaskThing[#TaskThing].int["3"]
                        local _pointX = DictBarrier[tostring(_barrierId)].x
                        local _pointY = DictBarrier[tostring(_barrierId)].y
                        local _subPosY = image_basemap:getContentSize().height - _pointY
                        startP = cc.p(_pointX, _subPosY)
                    end
                    local tb_sp = { }
                    if startP and endP then
                        local dis = cc.pGetDistance(startP, endP)
                        local count = math.floor(dis / space)
                        for i = 1, count - 1 do
                            local sp = cc.Sprite:create("ui/fb_dian.png");
                            sp:setPosition(cc.p(startP.x + i *(endP.x - startP.x) / count, startP.y + i *(endP.y - startP.y) / count));
                            sp:setVisible(false)
                            spBatchNode:addChild(sp);
                            table.insert(tb_sp, i, sp)
                        end
                    end
                    scrollToPercentVertical(view_basemap, subPosY)
                    if UIGuidePeople.guideStep ~= guideInfo["2B1"].step and UIGuidePeople.guideStep ~= guideInfo["2B3"].step and UIGuidePeople.guideStep ~= guideInfo["6B1"].step and UIGuidePeople.levelStep ~= guideInfo["20_8"].step then
                        _Item:retain()
                        if next(tb_sp) then
                            local i = 0
                            local function startAnimal()
                                view_basemap:setTouchEnabled(false)
                                if i < #tb_sp then
                                    i = i + 1
                                    if tb_sp[i] then
                                        tb_sp[i]:setVisible(true)
                                        performWithDelay(tb_sp[i], startAnimal, 0.3)
                                    end
                                else
                                    view_basemap:setTouchEnabled(true)
                                    barrierTaskAnimal(lastBarrier.id, _Item)
                                end
                            end
                            startAnimal()
                        else
                            barrierTaskAnimal(lastBarrier.id, _Item)
                        end
                    else
                        --- 此处是为了屏蔽大箭头
                        UIFightTask.Widget:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create( function() UIGuidePeople.isGuide(nil, UIFightTask) end)))
                    end
                else
                    if not basemapPercent then
                        --- 打最后新关卡的时候
                        view_basemap:scrollToTop(0.00001, false)
                    end
                end
            end
        else
            --- 如果实例表没有数据 就从字典表里寻找最小的关卡id
            local DictMinBarrierId = 10000
            for key, obj in pairs(DictBarrier) do
                if obj.chapterId == chapterId then
                    if DictMinBarrierId > obj.id then
                        DictMinBarrierId = obj.id
                    end
                end
            end
            if DictMinBarrierId == 10000 then
                UIManager.showToast(Lang.ui_fight_task6)
                return
            end
            local lastBarrier = DictBarrier[tostring(DictMinBarrierId)]
            local _Item = Item:clone()
            setScrollViewItem(_Item, lastBarrier, true)
            local pointX = DictBarrier[tostring(DictMinBarrierId)].x
            local pointY = DictBarrier[tostring(DictMinBarrierId)].y
            local subPosY = image_basemap:getContentSize().height - pointY
            ----策划是以图片左上角为原点
            _Item:setPosition(cc.p(pointX, subPosY))
            scrollToPercentVertical(view_basemap, subPosY)
            _Item:retain()
            barrierTaskAnimal(lastBarrier.id, _Item)
        end
    end
    if not UIFightTask.isFlush then
        AudioEngine.playMusic("sound/commonfight2.mp3", true)
    end
    UIFightTask.isFlush = nil
    utils.addImageHint(UIActivityTrial.checkImageHint(0, true), btn_trial, 100, 20, 20)

    local btn_win = ccui.Helper:seekNodeByName(UIFightTask.Widget, "btn_win")
    utils.addImageHint(UIActivityExchange.checkPerfectVictoryImageHint(), btn_win, 100, 10, 15)

    if (not UIGuidePeople.guideStep) and UIGuidePeople.levelStep then
        UIGuidePeople.checkLevelGuide()
    end
end

function UIFightTask.showPosterDialog()
    local _isShow = cc.UserDefault:getInstance():getStringForKey(string.gsub(net.InstPlayer.string["2"], "@", "_") .. "isShowPosterDialog")
    if (_isShow == nil or _isShow == "") and UIFightTask._isShowPosterDialog then
        UIPoster.show()
        cc.UserDefault:getInstance():setStringForKey(string.gsub(net.InstPlayer.string["2"], "@", "_") .. "isShowPosterDialog", "1")
    end
    UIFightTask._isShowPosterDialog = nil
end

function UIFightTask.setShowPoster(_isShow, _barrierId)
    UIFightTask._isShowPosterDialog = _isShow
    local _isShow = cc.UserDefault:getInstance():getStringForKey(string.gsub(net.InstPlayer.string["2"], "@", "_") .. "isShowPosterDialog")
    if _isShow == "1" then
        UIFightTask._isShowPosterDialog = nil
    end

    if UIFightTask._isShowPosterDialog then
        for ipbKey, ipbObj in pairs(net.InstPlayerBarrier) do
            if tonumber(_barrierId) == ipbObj.int["3"] then
                UIFightTask._isShowPosterDialog = nil
                break
            end
        end
    end
    if UIFightTask._isShowPosterDialog then
        local instActivityObj = UIActivityCard.getMonthCardData(UIActivityCard.GOLD_MONTH_CARD)
        if instActivityObj then
            if instActivityObj.string["4"] == "" then
                UIFightTask._isShowPosterDialog = nil
            elseif not UIActivityPanel.isEndActivityByEndTime(instActivityObj.string["4"]) then
                UIFightTask._isShowPosterDialog = nil
            end
        end
    end
end

function UIFightTask.setChapterId(_chapterId)
    chapterId = _chapterId
end

function UIFightTask.free()
    image_basemap:removeAllChildren()
    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("ani/ui_anim/ui_anim20/ui_anim20.ExportJson")
    for i = 1, 3 do
        if Particle[i] and Particle[i]:getParent() then
            Particle[i]:removeFromParent()
            Particle[i] = nil
        end
    end
end

--- 根据提供的关卡id跳转到副本 并弹出相应的界面
function UIFightTask.showFightTaskChooseById(barrierId, isShowDialog)
    local chapterId = DictBarrier[tostring(barrierId)].chapterId
    local barrierData = nil
    if net.InstPlayerBarrier then
        for key, obj in pairs(net.InstPlayerBarrier) do
            if obj.int["5"] == chapterId and obj.int["3"] == barrierId then
                barrierData = obj
            end
        end
    end
    UIFightTask.setChapterId(chapterId)
    UIManager.showScreen("ui_fight_task")
    local pointY = DictBarrier[tostring(barrierId)].y
    local subPosY = image_basemap:getContentSize().height - pointY
    local view_basemap = ccui.Helper:seekNodeByName(UIFightTask.Widget, "view_basemap")
    scrollToPercentVertical(view_basemap, subPosY)
    if isShowDialog then
        if barrierData then
            UIFightTaskChoose.setData(barrierData)
        else
            barrierData = DictBarrier[tostring(barrierId)]
            UIFightTaskChoose.setData(barrierData)
        end
        UIManager.pushScene("ui_fight_task_choose")
    end
end
