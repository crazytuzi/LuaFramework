require"Lang"
UIShopRecruitTen = { }
local flag = nil --- 1 代表1次  2 代表10次
local tag = nil
local userData = nil
local _isActivityRecruit = nil -- 是否活动招募
local ui_image_frame = { }
local ui_butLeft = nil
local ui_butRight = nil
local oneInstCardId = nil
local tenInstCardId = { }
UIShopRecruitTen.time = 0
local recruitTokenNum = 0
local scheduleId = nil

local function updateTime()
    if UIShopRecruitTen.time ~= 0 then
        local hour = math.floor(UIShopRecruitTen.time / 3600)
        local min = math.floor(UIShopRecruitTen.time % 3600 / 60)
        local sec = UIShopRecruitTen.time % 60
        ui_butRight:setTitleText(string.format("%02d:%02d:%02d", hour, min, sec))
        ui_butRight:getChildByName("text_down"):setVisible(true)
    else
        ui_butRight:setTitleText(Lang.ui_shop_recruit_ten1)
        ui_butRight:getChildByName("text_down"):setVisible(false)
    end
end

function UIShopRecruitTen.init()
    local btn_exit = ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "btn_exit")
    ui_butLeft = ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "btn_continue_one")
    ui_butRight = ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "btn_continue_ten")
    local animationLayer = ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "animationLayer")
    local function ButEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_exit then
                if _isActivityRecruit then
                    UIAactivityLimitTimeHero.setup()
                end
                animationLayer:removeAllChildren()
                UIManager.popAllScene()
                UIGuidePeople.isGuide(nil, UIShopRecruitTen)
                UIManager.showWidget("ui_notice")
            elseif sender == ui_butLeft then
                if flag == 1 then
                    -- 查看人物
                    UICardInfo.setUIParam(UIShopRecruitTen, tonumber(oneInstCardId))
                    -- 卡牌信息
                    UIManager.pushScene("ui_card_info")
                elseif flag == 5 then
                    local recruitTokenNum = 0
                    if net.InstPlayerThing then
                        for key, obj in pairs(net.InstPlayerThing) do
                            if StaticThing.recruitSign == obj.int["3"] then
                                recruitTokenNum = obj.int["5"]
                                break
                            end
                        end
                    end
                    if recruitTokenNum <= 0 then
                        UIManager.showToast(Lang.ui_shop_recruit_ten2)
                        return
                    end
                    animationLayer:removeAllChildren()
                    -- 继续招募1次
                    UIShop.sendRecruitData(1, 1)
                else
                    if UIShop.recruitDiamondOnePrice > net.InstPlayer.int["5"] then
                        UIManager.showToast(Lang.ui_shop_recruit_ten3)
                        return
                    end
                    animationLayer:removeAllChildren()
                    -- 继续招募1次
                    UIShop.sendRecruitData(3, 2)
                end
            elseif sender == ui_butRight then
                if flag == 1 then
                    -- 继续招募1次
                    if tag == 1 then
                        --- 免费招募得等冷却时间
                        if UIShopRecruitTen.time == 0 then
                            animationLayer:removeAllChildren()
                            UIShop.sendRecruitData(1, 0)
                        else
                            UIManager.showToast(Lang.ui_shop_recruit_ten4)
                        end
                    elseif tag == 3 then
                        --- 招募令招募
                        if recruitTokenNum <= 0 then
                            UIManager.showToast(Lang.ui_shop_recruit_ten5)
                            return
                        end
                        animationLayer:removeAllChildren()
                        if recruitTokenNum > 0 then
                            UIShop.sendRecruitData(1, 1)
                        end
                    elseif tag == 4 then
                        --- 72小时招募
                        if UIShop.recruitDiamondOnePrice > net.InstPlayer.int["5"] then
                            UIManager.showToast(Lang.ui_shop_recruit_ten6)
                            return
                        end
                        animationLayer:removeAllChildren()
                        UIShop.sendRecruitData(3, 2)
                    end
                elseif flag == 5 then
                    -- 招募令招募10次
                    local recruitTokenNum = 0
                    if net.InstPlayerThing then
                        for key, obj in pairs(net.InstPlayerThing) do
                            if StaticThing.recruitSign == obj.int["3"] then
                                recruitTokenNum = obj.int["5"]
                                break
                            end
                        end
                    end
                    if recruitTokenNum < 10 then
                        UIManager.showToast(Lang.ui_shop_recruit_ten7)
                        return
                    end
                    animationLayer:removeAllChildren()
                    for i = 1, #ui_image_frame do
                        ui_image_frame[i]:setVisible(false)
                    end
                    UIShop.sendRecruitData(1, 3)
                    sender:setEnabled(false)
                else
                    -- 继续招募10次
                    if UIShop.recruitTenPrice > net.InstPlayer.int["5"] then
                        UIManager.showToast(Lang.ui_shop_recruit_ten8)
                        return
                    end
                    animationLayer:removeAllChildren()
                    for i = 1, #ui_image_frame do
                        ui_image_frame[i]:setVisible(false)
                    end
                    UIShop.sendRecruitData(3, 3)
                    sender:setEnabled(false)
                end
            end
        end
    end
    btn_exit:setPressedActionEnabled(true)
    ui_butLeft:setPressedActionEnabled(true)
    ui_butRight:setPressedActionEnabled(true)
    btn_exit:addTouchEventListener(ButEvent)
    ui_butLeft:addTouchEventListener(ButEvent)
    ui_butRight:addTouchEventListener(ButEvent)
    for i = 1, 10 do
        ui_image_frame[i] = ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "image_frame_card" .. i)
    end
end

local function showInfo(_flag)
    local animationLayer = ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "animationLayer")
    if _flag == 1 then
        for i = 1, #ui_image_frame do
            ui_image_frame[i]:setVisible(false)
        end
        ui_butLeft:setTitleText(Lang.ui_shop_recruit_ten9)
        ui_butLeft:getChildByName("image_gold_cost_one"):setVisible(false)
        ui_butLeft:getChildByName("image_discount"):setVisible(false)
        local ui_image_base_name = ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "image_base_name")
        local ui_name = ui_image_base_name:getChildByName("text_name")

        if oneInstCardId then
            local cardId = net.InstPlayerCard[tostring(oneInstCardId)].int["3"]
            local cardData = DictCard[tostring(cardId)]
            local image = "image/" .. DictUI[tostring(cardData.bigUiId)].fileName
            local level = DictStarLevel[tostring(cardData.starLevelId)].level
            local qualityId = net.InstPlayerCard[tostring(oneInstCardId)].int["4"]
            local borderImage = utils.getQualityImage(dp.Quality.card, cardData.qualityId, dp.QualityImageType.middle)
            ui_name:setString(cardData.name)
            local animationFiles = cardData.animationFiles
            local param = { }
            table.insert(param, image)
            table.insert(param, borderImage)
            if animationFiles ~= "" then
                table.insert(param, animationFiles)
            end
            local function callbackFunc_after()
                if not UIGuidePeople.guideFlag then
                    UIShopRecruitTen.Widget:setEnabled(true)
                end
                local rightImage = ui_butRight:getChildByName("image_gold_cost")
                local text_down = ui_butRight:getChildByName("text_down")
                local image_discount = ui_butRight:getChildByName("image_discount")
                local rightPrice = rightImage:getChildByName("text_gold_cost_ten")
                local text_hint = ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "text_hint")
                local ui_image_base_name = ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "image_base_name")
                rightImage:loadTexture("ui/jin.png")
                if flag == 1 and tag == 1 then
                    if scheduleId then
                        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleId)
                    end
                    ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "btn_exit"):setVisible(true)
                    ui_butLeft:setVisible(true)
                    if UIShop.recruitFreeTime ~= 0 then
                        ui_butRight:setVisible(true)
                        scheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateTime, 1, false)
                    else
                        ui_butRight:setVisible(false)
                    end
                    text_hint:setVisible(false)
                    ui_image_base_name:setVisible(true)
                    rightImage:setVisible(false)
                    image_discount:setVisible(false)
                    updateTime()
                elseif flag == 1 and tag == 3 then
                    ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "btn_exit"):setVisible(true)
                    ui_butLeft:setVisible(true)
                    ui_butRight:setVisible(true)
                    text_down:setVisible(false)
                    ui_butRight:setTitleText(Lang.ui_shop_recruit_ten10)
                    text_hint:setVisible(false)
                    image_discount:setVisible(false)
                    recruitTokenNum = 0
                    if net.InstPlayerThing then
                        for key, obj in pairs(net.InstPlayerThing) do
                            if StaticThing.recruitSign == obj.int["3"] then
                                recruitTokenNum = obj.int["5"]
                                break
                            end
                        end
                    end
                    rightImage:loadTexture("ui/zml.png")
                    rightImage:setVisible(true)
                    rightPrice:setString("× " .. recruitTokenNum)
                    ui_image_base_name:setVisible(true)
                elseif flag == 1 and tag == 4 then
                    ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "btn_exit"):setVisible(true)
                    ui_butLeft:setVisible(true)
                    ui_butRight:setVisible(true)
                    text_down:setVisible(false)
                    ui_butRight:setTitleText(Lang.ui_shop_recruit_ten11)
                    text_hint:setVisible(true)
                    rightImage:setVisible(true)
                    rightPrice:setString("× " .. UIShop.recruitDiamondOnePrice)
                    ui_image_base_name:setVisible(true)
                    UIShop.refreshRecruitIcon(image_discount)
                    UIGuidePeople.isGuide(nil, UIShopRecruitTen)
                elseif flag == 1 and _isActivityRecruit then
                    ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "btn_exit"):setVisible(true)
                    ui_butLeft:setVisible(true)
                    ui_image_base_name:setVisible(true)
                end
            end
            local armature = ActionManager.getUIAnimation(10, callbackFunc_after)
            local card = ccs.Skin:create(param[1])
            local border = ccs.Skin:create(param[2])

            local animation, animation_Name
            if param[3] then
                animation, animation_Name = ActionManager.getCardAnimation(param[3])
            else
                animation, animation_Name = ActionManager.getCardBreatheAnimation(param[1])
            end
            armature:getBone("hero02"):addDisplay(animation, 0)
            armature:getBone("hero02"):setPositionY(20)
            armature:getBone("hero"):addDisplay(card, 0)
            armature:getBone("pai"):addDisplay(border, 0)
            armature:getAnimation():play("ui_anim2_1")
            armature:setPosition(cc.p(320, 373))
            animationLayer:addChild(armature)
        end
    else
        local position = { }
        for i = 1, #ui_image_frame do
            position[i] = cc.p(ui_image_frame[i]:getPosition())
        end
        ui_butLeft:setTitleText(Lang.ui_shop_recruit_ten12)
        ui_butLeft:getChildByName("image_gold_cost_one"):setVisible(true)
        UIShop.refreshRecruitIcon(ui_butLeft:getChildByName("image_discount"))
        ui_butRight:setTitleText(Lang.ui_shop_recruit_ten13)
        local armature = ActionManager.getUIAnimation(10)
        armature:getAnimation():play("ui_anim2_2")
        armature:setPosition(cc.p(320, 373))
        animationLayer:addChild(armature)
        if tenInstCardId then
            local function callbackFunc_after(bone, evt, originFrameIndex, currentFrameIndex)
                if evt == "recruit" then
                    for key, obj in pairs(tenInstCardId) do
                        --- 显示卡牌信息
                        local function showImageInfo(sender, eventType)
                            if eventType == ccui.TouchEventType.ended then
                                UICardInfo.setUIParam(UIShopRecruitTen, tonumber(obj))
                                -- 卡牌信息
                                UIManager.pushScene("ui_card_info")
                            end
                        end
                        local ui_name = ccui.Helper:seekNodeByName(ui_image_frame[key], "text_name_card" .. key)
                        local ui_image = ui_image_frame[key]:getChildByName("image_card" .. key)
                        local cardId = net.InstPlayerCard[tostring(obj)].int["3"]
                        local cardData = DictCard[tostring(cardId)]
                        local image = "image/" .. DictUI[tostring(cardData.smallUiId)].fileName
                        ui_name:setString(cardData.name)
                        local borderImage = utils.getQualityImage(dp.Quality.card, cardData.qualityId, dp.QualityImageType.small)
                        ui_image_frame[key]:loadTexture(borderImage)
                        ui_image:loadTexture(image)
                        ui_image_frame[key]:addTouchEventListener(showImageInfo)
                        ui_image_frame[key]:setScale(0.01)
                        ui_image_frame[key]:setPosition(cc.p(320, 373))
                    end
                    local i = 1
                    local time = 0.3
                    local function itemAction()
                        ui_image_frame[i]:setVisible(true)
                        local spawn = cc.Spawn:create(cc.MoveTo:create(time, position[i]),
                        cc.RotateBy:create(time, 360), cc.ScaleTo:create(time, 1))
                        ui_image_frame[i]:setRotation(0)
                        ui_image_frame[i]:runAction(spawn)
                        if i < 10 then
                            i = i + 1
                            performWithDelay(ui_image_frame[i], itemAction, time)
                        elseif i == 10 then
                            local function callback()
                                if _isActivityRecruit then
                                    ui_butLeft:setVisible(false)
                                    ui_butRight:setVisible(false)
                                else
                                    ui_butRight:setEnabled(true)
                                    ui_butLeft:setEnabled(true)
                                end
                                ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "btn_exit"):setEnabled(true)
                            end
                            performWithDelay(ui_image_frame[i], callback, 1)
                        end
                    end
                    performWithDelay(ui_image_frame[i], itemAction, 0)
                end
            end
            local function compare(value1, value2)
                local cardData1 = DictCard[tostring(net.InstPlayerCard[tostring(value1)].int["3"])]
                local cardData2 = DictCard[tostring(net.InstPlayerCard[tostring(value2)].int["3"])]
                return cardData1.qualityId < cardData2.qualityId
            end
            utils.quickSort(tenInstCardId, compare)
            local armature = ActionManager.getUIAnimation(27)
            armature:getAnimation():setFrameEventCallFunc(callbackFunc_after)
            armature:getAnimation():setSpeedScale(0.9)
            armature:setPosition(cc.p(320, 385))
            animationLayer:addChild(armature)
        end
    end
end

function UIShopRecruitTen.setup()
    local left_image_discount = ccui.Helper:seekNodeByName(ui_butLeft, "image_discount")
    UIShop.refreshRecruitIcon(left_image_discount)

    right_image_discount = ccui.Helper:seekNodeByName(ui_butRight, "image_discount")
    UIShop.refreshRecruitIcon(right_image_discount)

    local text_hint = ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "text_hint")
    ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "btn_exit"):setVisible(false)
    ui_butRight:setVisible(false)
    ui_butLeft:setVisible(false)
    text_hint:setVisible(false)
    ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "image_base_name"):setVisible(false)
    showInfo(flag)
    local rightImage = ui_butRight:getChildByName("image_gold_cost")
    local rightPrice = rightImage:getChildByName("text_gold_cost_ten")
    local leftImage = ui_butLeft:getChildByName("image_gold_cost_one")
    local leftPrice = leftImage:getChildByName("text_gold_cost")

    leftPrice:setString(tostring(UIShop.recruitDiamondOnePrice))
    rightPrice:setString(tostring(UIShop.recruitTenPrice))

    if _isActivityRecruit then
        if flag == 2 then
            ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "image_base_name"):setVisible(false)
            ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "btn_exit"):setVisible(true)
            ui_butLeft:setVisible(false)
            ui_butRight:setVisible(false)
            ui_butRight:setEnabled(false)
            ui_butLeft:setEnabled(false)
            ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "btn_exit"):setEnabled(false)
            ui_butRight:getChildByName("text_down"):setVisible(false)
            text_hint:setVisible(false)
            ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "image_base_name"):setVisible(false)
        elseif userData.recruitNum and userData.recruitNum >= 0 then
            local _num = userData.recruitNum
            if _num == 0 then _num = 9 elseif _num == 1 then _num = 0 else _num = _num - 1 end
            if _num ~= 0 then
                text_hint:setString(Lang.ui_shop_recruit_ten14 .. _num .. Lang.ui_shop_recruit_ten15)
            else
                text_hint:setString(Lang.ui_shop_recruit_ten16)
            end
            text_hint:setVisible(true)
        end
    else
        if flag ~= 5 then
            if UIShop.recruitPurpleTimer ~= 0 then
                text_hint:setString(Lang.ui_shop_recruit_ten17 .. UIShop.recruitPurpleTimer .. Lang.ui_shop_recruit_ten18)
            else
                text_hint:setString(Lang.ui_shop_recruit_ten19)
            end
        end
        local ui_image_base_name = ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "image_base_name")
        rightImage:loadTexture("ui/jin.png")
        if flag == 2 then
            ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "btn_exit"):setVisible(true)
            ui_butLeft:setVisible(true)
            ui_butRight:setVisible(true)
            ui_butRight:setEnabled(false)
            ui_butLeft:setEnabled(false)
            ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "btn_exit"):setEnabled(false)
            ui_butRight:getChildByName("text_down"):setVisible(false)
            text_hint:setVisible(false)
            leftPrice:setString(tostring(UIShop.recruitDiamondOnePrice))
            rightPrice:setString(tostring(UIShop.recruitTenPrice))
            ui_image_base_name:setVisible(false)
            UIShop.refreshRecruitIcon(left_image_discount)
            UIShop.refreshRecruitIcon(right_image_discount)
        elseif flag == 5 then
            ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "btn_exit"):setVisible(true)
            ui_butLeft:setVisible(true)
            ui_butRight:setVisible(true)
            ui_butRight:setEnabled(false)
            ui_butLeft:setEnabled(false)
            ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "btn_exit"):setEnabled(false)
            ui_butRight:getChildByName("text_down"):setVisible(false)
            text_hint:setVisible(false)
            ui_image_base_name:setVisible(false)
            rightImage:loadTexture("ui/zml.png")
            leftImage:loadTexture("ui/zml.png")
            rightPrice:setString("× 10")
            leftPrice:setString("× 1")
            left_image_discount:setVisible(false)
            right_image_discount:setVisible(false)
        end
    end
end
-----此方法从UIShop界面传来
-- _flag 用于区分是抽一次 还是抽10次 当然从UIshop界面只能传1
-- _tag用于区分是白银招募抽取 还是黄金招募抽取 是招募令抽取 还是72小时抽取 招募令10连抽  分别为1,2,3,4,5
-- _data是卡牌数据
function UIShopRecruitTen.setData(_flag, _data, _tag)
    flag = _flag
    if _flag == 1 then
        oneInstCardId = _data
    elseif _flag == 2 then
        tenInstCardId = utils.stringSplit(_data, ";")
    elseif _flag == 3 then
        tenInstCardId = utils.stringSplit(_data, ";")
    elseif _flag == 5 then
        tenInstCardId = utils.stringSplit(_data, ";")
    end
    tag = _tag
end

function UIShopRecruitTen.show(_tableParams)
    userData = _tableParams
    _isActivityRecruit = true
    local _instCardIds = utils.stringSplit(userData.recruitData, ";")
    if #_instCardIds > 1 then
        flag = 2
        tenInstCardId = _instCardIds
    else
        flag = 1
        oneInstCardId = userData.recruitData
    end
    tag = nil
    UIManager.hideWidget("ui_notice")
    UIManager.pushScene("ui_shop_recruit_ten", true)
end

function UIShopRecruitTen.free()
    ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "animationLayer"):removeAllChildren()
    for i = 1, #ui_image_frame do
        ui_image_frame[i]:setVisible(false)
    end
    oneInstCardId = nil
    tenInstCardId = nil
    if scheduleId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleId)
        scheduleId = nil
    end
    userData = nil
    _isActivityRecruit = nil
end
