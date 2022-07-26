require"Lang"
UIShop = { }
local shopFlag = 1
local btnSelected = nil
local btnSelectedText = nil
local scrollView = nil
local listItem = nil
local buyProp = false
local buyCore = false
local propThing = { }
local gemThing = { }
scheduleId = nil
local recruitTime = {
    {
        hour = 0,
        min = 0,
        sec = 0,
    },
    {
        hour = 0,
        min = 0,
        sec = 0,
    },
    {
        hour = 0,
        min = 0,
        sec = 0,
    }
}
local timeLabel = {
    {
        time = nil,
        text = nil,
    },
    {
        time = nil,
        text = nil,
    },
    {
        time = nil,
        text = nil,
    },
}
local time1 = 0
local time3 = 0
UIShop.recruitGoldOnePrice = 0
UIShop.recruitDiamondOnePrice = 0
UIShop.recruitTenPrice = 0
UIShop.recruitFreeTime = 0      ----免费招募的次数
UIShop.recruitPurpleTimer = 0   --- 在购买几次可得紫卡
UIShop.recruitTypeId = 0
UIShop.diamondRecruitTypeId = 0
local Silver = { FREE = 0, TOKEN = 1 }
local ui_token = nil
local showShop = nil
local recruitEnabled = false
local image_recruit_silver = nil
local image_recruit_jewel = nil
local recruitTokenNum = 0
UIShop.disCount = 1
UIShop.recruitDiscount = 1

local function getShopFunc(pack)
    if pack.header == StaticMsgRule.getStoreData then
        UIShop.disCount = pack.msgdata.int["multipleExp"] / 100
        if UIMenu and UIMenu.Widget then
            UIMenu.refreshIcon()
        end
        cclog("disCount : " .. UIShop.disCount)

        if shopFlag == 2 then
            propThing = pack.msgdata.message
            buyProp = true
        elseif shopFlag == 3 then
            gemThing = pack.msgdata.message
            buyCore = true
        end
        if showShop then
            showShop = nil
            UIManager.showWidget("ui_shop")
        else
            if UIShop.Widget and UIShop.Widget:getParent() then
                UIShop.setup()
            end
        end
    elseif pack.header == StaticMsgRule.cardRecruit then
        recruitEnabled = true
        if UIShop.recruitTypeId == 1 then
            if UIShop.diamondRecruitTypeId == 1 then
                --- 招募令
                UIShopRecruitTen.setData(1, pack.msgdata.string["1"], 3)
            elseif UIShop.diamondRecruitTypeId == 0 then
                --- 白银免费招募
                UIShopRecruitTen.setData(1, pack.msgdata.string["1"], 1)
            else
                UIShopRecruitTen.setData(5, pack.msgdata.string["1"])
            end
        elseif UIShop.recruitTypeId == 3 then
            ----钻石招募
            if UIShop.diamondRecruitTypeId == 2 then
                --- 72小时
                UIShopRecruitTen.setData(1, pack.msgdata.string["1"], 4)
            elseif UIShop.diamondRecruitTypeId == 3 then
                --- 10人招募
                UIShopRecruitTen.setData(2, pack.msgdata.string["1"])
            elseif UIShop.diamondRecruitTypeId == 3 then
                -- 白银10连抽
                UIShopRecruitTen.setData(3, pack.msgdata.string["1"])
            end
        end
        UIShop.getShopRecruitInfo()
    elseif pack.header == StaticMsgRule.getRecruitInfo then
        UIShop.setRecruitData(pack)
    end

end
function UIShop.getShopRecruitInfo()
    if UIManager.loadingLayer == nil then
        UIManager.showLoading()
    end
    local data = {
        header = StaticMsgRule.getRecruitInfo,
    }
    netSendPackage(data, getShopFunc)
end
function UIShop.getShopList(_type, _showShop)
    showShop = _showShop
    UIManager.showLoading()
    local data = {
        header = StaticMsgRule.getStoreData,
        msgdata =
        {
            int =
            {
                type = _type,
            },
        }
    }
    netSendPackage(data, getShopFunc)
end
-- _diamondRecruitTypeId钻石招募类型, 1-招募令 2-普通招募 3-招募10次[非钻石招募传0,招募令传1]
-- _recruitTypeId招募类型Id 1-白银招募 2-黄金招募 3-钻石招募 [定死即可]
-- [1,0] [1,1][1,3] [2,0] [3,2] [3,3]
function UIShop.sendRecruitData(_recruitTypeId, _diamondRecruitTypeId)
    UIManager.showLoading()
    UIShop.recruitTypeId = _recruitTypeId
    UIShop.diamondRecruitTypeId = _diamondRecruitTypeId
    local data = nil
    if UIGuidePeople.guideStep == "5B3" then
        data = {
            header = StaticMsgRule.cardRecruit,
            msgdata =
            {
                int =
                {
                    recruitTypeId = _recruitTypeId,
                    diamondRecruitTypeId = _diamondRecruitTypeId,
                },
                string =
                {
                    step = "5B4"
                }
            }
        }
    else
        data = {
            header = StaticMsgRule.cardRecruit,
            msgdata =
            {
                int =
                {
                    recruitTypeId = _recruitTypeId,
                    diamondRecruitTypeId = _diamondRecruitTypeId,
                },
            }
        }
    end
    netSendPackage(data, getShopFunc)
end
local function compare(value1, value2)
    return value1.int["indexOrder"] > value2.int["indexOrder"]
end
local function selectedBtnChange(flag)
    local btn_recruit = ccui.Helper:seekNodeByName(UIShop.Widget, "btn_recruit")
    local btn_prop = ccui.Helper:seekNodeByName(UIShop.Widget, "btn_prop")
    local btn_gem = ccui.Helper:seekNodeByName(UIShop.Widget, "btn_gem")
    btnSelected:loadTextureNormal("ui/yh_btn01.png")
    btnSelectedText:setTextColor(cc.c4b(255, 255, 255, 255))
    if flag == 1 then
        btnSelected = btn_recruit
        btnSelectedText = btn_recruit:getChildByName("text_recruit")
        btn_recruit:loadTextureNormal("ui/yh_btn02.png")
        btn_recruit:getChildByName("text_recruit"):setTextColor(cc.c4b(51, 25, 4, 255))
    elseif flag == 2 then
        btnSelected = btn_prop
        btnSelectedText = btn_prop:getChildByName("text_prop")
        btn_prop:loadTextureNormal("ui/yh_btn02.png")
        btn_prop:getChildByName("text_prop"):setTextColor(cc.c4b(51, 25, 4, 255))
    elseif flag == 3 then
        btnSelected = btn_gem
        btnSelectedText = btn_gem:getChildByName("text_gem")
        btn_gem:loadTextureNormal("ui/yh_btn02.png")
        btn_gem:getChildByName("text_gem"):setTextColor(cc.c4b(51, 25, 4, 255))
    end
end
local function setScrollViewItem(flag, _Item, _obj)
    -- local image_gift_lv = ccui.Helper:seekNodeByName(_Item,"image_gift_lv")
    local image_base_price_yuan = ccui.Helper:seekNodeByName(_Item, "image_base_price_yuan")
    local image_gold_yuan = ccui.Helper:seekNodeByName(_Item, "image_gold_yuan")
    --  local image_base_price_xian = ccui.Helper:seekNodeByName(_Item,"image_base_price_xian")
    local text_quota = ccui.Helper:seekNodeByName(_Item, "text_quota")
    local ui_frame_prop = ccui.Helper:seekNodeByName(_Item, "image_frame_prop")
    local image = ccui.Helper:seekNodeByName(_Item, "image_prop")
    local name = ccui.Helper:seekNodeByName(_Item, "text_name_prop")
    local description = ccui.Helper:seekNodeByName(_Item, "text_prop_describe")
    local text_price_xian = _Item:getChildByName("text_price")
    local text_price = ccui.Helper:seekNodeByName(image_base_price_yuan, "text_price")
    local function BuyEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if _obj.int["canBuyNum"] ~= nil and _obj.int["canBuyNum"] == 0 then
                ---  -1表示可以无限购买
                UIManager.showToast(Lang.ui_shop1)
            elseif _obj.int["isBuy"] ~= nil and _obj.int["isBuy"] == 1 then
                -- 已购买 不能买了
                UIManager.showToast(Lang.ui_shop2)
            else
                UISellProp.setData(_obj, UIShop)
                UIManager.pushScene("ui_sell_prop")
            end
        end
    end
    local btn_buy = ccui.Helper:seekNodeByName(_Item, "btn_buy")
    btn_buy:setTitleColor(cc.c3b(255, 255, 255))
    btn_buy:addTouchEventListener(BuyEvent)
    local tableFieldId = _obj.int["thingId"]
    local qualityId = utils.addBorderImage(StaticTableType.DictThing, tableFieldId, ui_frame_prop)
    utils.changeNameColor(name, qualityId)

    local image_title = ui_frame_prop:getChildByName("image_title")
    if UIShop.disCount < 1 then
        image_title:setVisible(true)
        image_gold_yuan:setVisible(true)
        image_gold_yuan:getChildByName("text_gold_number"):setString(_obj.int["price"])
        if UIShop.disCount ~= 0.5 then
            image_title:getChildByName("text_title"):setString((UIShop.disCount * 10) .. Lang.ui_shop3)
        end
    else
        image_title:setVisible(false)
        image_gold_yuan:setVisible(false)
    end
    if flag == 2 then
        --     image_gift_lv:setVisible(false)
        --     image_gold_yuan:setVisible( false )
        image_base_price_yuan:setVisible(false)
        -- 道具没有原价
        local name_text = DictThing[tostring(tableFieldId)].name
        local smallUiId = DictThing[tostring(tableFieldId)].smallUiId
        local smallImage = DictUI[tostring(smallUiId)].fileName
        local description_text = DictThing[tostring(tableFieldId)].description
        if _obj.int["canBuyNum"] ~= -1 then
            text_quota:setVisible(true)
            text_quota:setString(string.format(Lang.ui_shop4, _obj.int["canBuyNum"]))
        else
            text_quota:setVisible(false)
        end
        image:loadTexture("image/" .. smallImage)
        if tableFieldId == 1013 then
            utils.addFrameParticle(image, true)
        end
        name:setString(name_text)
        description:setString(description_text)
        if tableFieldId == StaticThing.vigorPill or tableFieldId == StaticThing.energyPill then
            local _todayBuyPrice = 0
            local _todayBuyNum = _obj.int["todayBuyNum"] + 1
            local _extend = utils.stringSplit(DictThingExtend[tostring(tableFieldId)].extend, ";")
            for _k, _o in pairs(_extend) do
                local _tempO = utils.stringSplit(_o, "_")
                if _todayBuyNum >= tonumber(_tempO[1]) and _todayBuyNum <= tonumber(_tempO[2]) then
                    _todayBuyPrice = tonumber(_tempO[3])
                    break
                end
            end
            if UIShop.disCount < 1 then
                image_gold_yuan:getChildByName("text_gold_number"):setString(_todayBuyPrice)
                text_price_xian:setString(tostring(math.round(_todayBuyPrice * UIShop.disCount)))
            else
                text_price_xian:setString(tostring(_todayBuyPrice))
            end
        else
            text_price_xian:setString(math.round(_obj.int["price"] * UIShop.disCount))
        end
    elseif flag == 3 then
        --      image_gift_lv:setVisible(false)
        text_quota:setVisible(false)
        --   image_gold_yuan:setVisible(false)
        image_base_price_yuan:setVisible(false)
        -- 魔核也木有原价
        local name_text = DictThing[tostring(tableFieldId)].name
        local smallUiId = DictThing[tostring(tableFieldId)].smallUiId
        local smallImage = DictUI[tostring(smallUiId)].fileName
        local description_text = DictThing[tostring(tableFieldId)].description
        image:loadTexture("image/" .. smallImage)
        name:setString(name_text)
        description:setString(description_text)
        text_price_xian:setString(math.round(_obj.int["price"] * UIShop.disCount))
    end
end

local function updateTime()
    if time1 ~= 0 then
        time1 = time1 - 1
        recruitTime[1].hour = math.floor(time1 / 3600)
        recruitTime[1].min = math.floor(time1 % 3600 / 60)
        recruitTime[1].sec = time1 % 60
        timeLabel[1].time:setVisible(true)
        timeLabel[1].time:setString(string.format(Lang.ui_shop5, recruitTime[1].hour, recruitTime[1].min, recruitTime[1].sec))
        UIShopRecruitTen.time = time1
        image_recruit_silver:getChildByName("image_free"):setVisible(false)
        image_recruit_silver:getChildByName("image_hint"):setVisible(false)
        ui_token:setVisible(true)
        if UIShopRecruitJewel.Widget then
            local ui_image_token = ccui.Helper:seekNodeByName(UIShopRecruitJewel.Widget, "image_di_token")
            if UIShop.recruitFreeTime ~= 0 and recruitTokenNum ~= 0 then
                ui_image_token:getChildByName("image_good"):setVisible(true)
                --            ui_image_token:getChildByName("image_good"):getChildByName("text_cost"):setString("×" .. recruitTokenNum)
                --            ui_image_token:getChildByName("image_good"):getChildByName("text_cost"):setTextColor(cc.c4b(255,255,0,255))
                ui_image_token:getChildByName("image_hint"):setVisible(false)
                ui_image_token:getChildByName("text_gratis_countdown"):setVisible(false)
                utils.GrayWidget(ui_image_token:getChildByName("btn_recruit"), false)
                ui_image_token:getChildByName("btn_recruit"):setEnabled(true)
                UIShopRecruitJewel.silverRecruitType = Silver.TOKEN
            elseif UIShop.recruitFreeTime ~= 0 and recruitTokenNum == 0 then
                utils.GrayWidget(ui_image_token:getChildByName("btn_recruit"), true)
                ui_image_token:getChildByName("btn_recruit"):setEnabled(false)
                ui_image_token:getChildByName("image_hint"):setVisible(false)
                ui_image_token:getChildByName("image_good"):setVisible(true)
                --            ui_image_token:getChildByName("image_good"):getChildByName("text_cost"):setString("×" .. recruitTokenNum)
                --            ui_image_token:getChildByName("image_good"):getChildByName("text_cost"):setTextColor(cc.c4b(255,0,0,255))
                ui_image_token:getChildByName("text_gratis_countdown"):setVisible(true)
                ui_image_token:getChildByName("text_gratis_countdown"):setString(string.format(Lang.ui_shop6, recruitTime[1].hour, recruitTime[1].min, recruitTime[1].sec))
            end
        end
    else
        image_recruit_silver:getChildByName("image_hint"):setVisible(true)
        timeLabel[1].time:setVisible(false)
        if UIShop.recruitFreeTime ~= 0 then
            ui_token:setVisible(false)
            image_recruit_silver:getChildByName("image_free"):setVisible(true)
        else
            ui_token:setVisible(true)
            image_recruit_silver:getChildByName("image_free"):setVisible(false)
            image_recruit_silver:getChildByName("image_hint"):setVisible(false)
        end
        if UIShopRecruitJewel.Widget then
            local ui_image_token = ccui.Helper:seekNodeByName(UIShopRecruitJewel.Widget, "image_di_token")
            ui_image_token:getChildByName("text_gratis_countdown"):setVisible(false)
            if UIShop.recruitFreeTime ~= 0 then
                UIShopRecruitJewel.silverRecruitType = Silver.FREE
                ui_image_token:getChildByName("image_good"):setVisible(false)
                ui_image_token:getChildByName("image_hint"):setVisible(true)
                utils.GrayWidget(ui_image_token:getChildByName("btn_recruit"), false)
                ui_image_token:getChildByName("btn_recruit"):setEnabled(true)
            elseif UIShop.recruitFreeTime == 0 and recruitTokenNum ~= 0 then
                UIShopRecruitJewel.silverRecruitType = Silver.TOKEN
                utils.GrayWidget(ui_image_token:getChildByName("btn_recruit"), false)
                ui_image_token:getChildByName("btn_recruit"):setEnabled(true)
                ui_image_token:getChildByName("image_hint"):setVisible(false)
                ui_image_token:getChildByName("image_good"):setVisible(true)
                --            ui_image_token:getChildByName("image_good"):getChildByName("text_cost"):setString("×" .. recruitTokenNum)
                --            ui_image_token:getChildByName("image_good"):getChildByName("text_cost"):setTextColor(cc.c4b(255,255,0,255))
            elseif UIShop.recruitFreeTime == 0 and recruitTokenNum == 0 then
                utils.GrayWidget(ui_image_token:getChildByName("btn_recruit"), true)
                ui_image_token:getChildByName("btn_recruit"):setEnabled(false)
                ui_image_token:getChildByName("image_hint"):setVisible(false)
                ui_image_token:getChildByName("image_good"):setVisible(true)
                --            ui_image_token:getChildByName("image_good"):getChildByName("text_cost"):setString("×" .. recruitTokenNum)
                --            ui_image_token:getChildByName("image_good"):getChildByName("text_cost"):setTextColor(cc.c4b(255,0,0,255))
            end
        end
    end

    image_recruit_jewel:getChildByName("image_cheng"):setVisible(UIShop.recruitPurpleTimer == 0)

    if time3 ~= 0 then
        time3 = time3 - 1
        recruitTime[3].hour = math.floor(time3 / 3600)
        recruitTime[3].min = math.floor(time3 % 3600 / 60)
        recruitTime[3].sec = time3 % 60
        timeLabel[3].time:setString(string.format(Lang.ui_shop7, recruitTime[3].hour, recruitTime[3].min, recruitTime[3].sec))
        timeLabel[3].text:setVisible(true)
        timeLabel[3].time:setVisible(true)
        image_recruit_jewel:getChildByName("image_free"):setVisible(false)
        image_recruit_jewel:getChildByName("image_hint_1"):setVisible(false)
        if UIShopRecruitJewel.Widget then
            local ui_image_one = ccui.Helper:seekNodeByName(UIShopRecruitJewel.Widget, "image_di_one")
            ui_image_one:getChildByName("text_gratis_countdown"):setString(string.format(Lang.ui_shop8, recruitTime[3].hour, recruitTime[3].min, recruitTime[3].sec))
            ui_image_one:getChildByName("image_gold"):setVisible(true)
            UIShop.refreshRecruitIcon(ui_image_one:getChildByName("image_discount"))
            ui_image_one:getChildByName("image_hint"):setVisible(false)
            ui_image_one:getChildByName("text_gratis_countdown"):setVisible(true)
        end
    else
        timeLabel[3].text:setVisible(false)
        timeLabel[3].time:setVisible(false)
        image_recruit_jewel:getChildByName("image_free"):setVisible(true)
        image_recruit_jewel:getChildByName("image_hint_1"):setVisible(true)
        if UIShopRecruitJewel.Widget then
            local ui_image_one = ccui.Helper:seekNodeByName(UIShopRecruitJewel.Widget, "image_di_one")
            ui_image_one:getChildByName("image_gold"):setVisible(false)
            ui_image_one:getChildByName("image_discount"):setVisible(false)
            ui_image_one:getChildByName("image_hint"):setVisible(true)
            ui_image_one:getChildByName("text_gratis_countdown"):setVisible(false)
        end
    end
end

function UIShop.init()

    local image_base_title = ccui.Helper:seekNodeByName(UIShop.Widget, "image_base_title")
    local btn_recruit = image_base_title:getChildByName("btn_recruit")
    local btn_prop = image_base_title:getChildByName("btn_prop")
    local btn_gem = image_base_title:getChildByName("btn_gem")
    local btn_recharge = image_base_title:getChildByName("btn_recharge")
    local btn_preview = ccui.Helper:seekNodeByName(UIShop.Widget, "btn_preview")
    image_recruit_silver = ccui.Helper:seekNodeByName(UIShop.Widget, "image_recruit_silver")
    image_recruit_jewel = ccui.Helper:seekNodeByName(UIShop.Widget, "image_recruit_jewel")
    timeLabel[1].time = image_recruit_silver:getChildByName("text_gratis_countdown")
    timeLabel[1].text = image_recruit_silver:getChildByName("text_gratis_number")
    timeLabel[3].time = image_recruit_jewel:getChildByName("text_gratis_countdown")
    timeLabel[3].text = image_recruit_jewel:getChildByName("image_gold")
    ui_token = image_recruit_silver:getChildByName("image_good")
    scrollView = ccui.Helper:seekNodeByName(UIShop.Widget, "view_list_prop")
    listItem = scrollView:getChildByName("image_base_prop"):clone()
    if UIShop.recruitFreeTime ~= 0 then
        timeLabel[1].text:setString(Lang.ui_shop9 .. UIShop.recruitFreeTime .. Lang.ui_shop10)
    else
        timeLabel[1].text:setString(Lang.ui_shop11)
        timeLabel[1].time:setVisible(false)
        image_recruit_silver:getChildByName("image_free"):setVisible(false)
    end
    updateTime()
    local function btn_Event(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_recruit then
                if shopFlag == 1 then
                    return
                end
                shopFlag = 1
                selectedBtnChange(shopFlag)
                UIShop.setup()
            elseif sender == btn_prop then
                if shopFlag == 2 then
                    return
                end
                shopFlag = 2
                --              if buyProp == false then
                UIShop.getShopList(1)
                --              else
                --                  UIShop.setup()
                --              end
            elseif sender == btn_gem then
                if shopFlag == 3 then
                    return
                end
                shopFlag = 3
                if buyCore == false then
                    UIShop.getShopList(2)
                else
                    UIShop.setup()
                end
            elseif sender == btn_preview then
                -- 招募预览
                UIManager.pushScene("ui_shop_recruit_preview")
            elseif sender == image_recruit_silver then
                -- 白银招募
                UIShopRecruitJewel.setRecruitType(UIShopRecruitJewel.Type.SILVER)
                UIManager.pushScene("ui_shop_recruit_jewel")
            elseif sender == image_recruit_jewel then
                -- 钻石招募
                UIShopRecruitJewel.setRecruitType(UIShopRecruitJewel.Type.JEWEL)
                UIManager.pushScene("ui_shop_recruit_jewel")
            elseif sender == btn_recharge then
                -- 充值
                utils.checkGOLD(1)
            end
        end
    end
    btn_recruit:addTouchEventListener(btn_Event)
    btn_prop:addTouchEventListener(btn_Event)
    btn_gem:addTouchEventListener(btn_Event)
    btn_preview:addTouchEventListener(btn_Event)
    btn_recharge:addTouchEventListener(btn_Event)
    image_recruit_silver:addTouchEventListener(btn_Event)
    image_recruit_jewel:addTouchEventListener(btn_Event)
    btn_recruit:setPressedActionEnabled(true)
    btn_prop:setPressedActionEnabled(true)
    btn_gem:setPressedActionEnabled(true)
    btn_preview:setPressedActionEnabled(true)
    btn_recharge:setPressedActionEnabled(true)
    btnSelected = btn_recruit
    btnSelectedText = btn_recruit:getChildByName("text_recruit")
end

function UIShop.refreshRecruitIcon(image_discount)
    if not image_discount then return end
    if UIShop.recruitDiscount < 1 then
        image_discount:show():getChildByName("text_discount"):setString((UIShop.recruitDiscount * 10) .. Lang.ui_shop12)
    else
        image_discount:hide()
    end
end

function UIShop.setup()
    if scheduleId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleId)
        scheduleId = nil
    end
    scheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateTime, 1, false)
    if listItem:getReferenceCount() == 1 then
        listItem:retain()
    end
    local btn_preview = ccui.Helper:seekNodeByName(UIShop.Widget, "btn_preview")
    local image_base_title = ccui.Helper:seekNodeByName(UIShop.Widget, "image_base_title")
    local image_fight = image_base_title:getChildByName("image_fight")
    local ui_fightNum = image_fight:getChildByName("label_fight")
    -- 战力
    local image_gold = image_base_title:getChildByName("image_gold")
    local goldNum = image_gold:getChildByName("text_gold_number")
    -- 元宝
    local image_silver = image_base_title:getChildByName("image_silver")
    local silverNum = image_silver:getChildByName("text_silver_number")
    -- 铜钱
    ui_fightNum:setString(utils.getFightValue())
    if net.InstPlayer then
        goldNum:setString(tostring(net.InstPlayer.int["5"]))
        silverNum:setString(tostring(net.InstPlayer.string["6"]))
    end

    local image_discount = image_base_title:getChildByName("image_discount")
    UIShop.refreshRecruitIcon(image_discount)

    local image_discount = ccui.Helper:seekNodeByName(image_recruit_jewel, "image_discount")
    UIShop.refreshRecruitIcon(image_discount)
    local text_cost = ccui.Helper:seekNodeByName(image_recruit_jewel, "text_cost")
    text_cost:setString(tostring(UIShop.recruitDiamondOnePrice))

    if UIShop.recruitDiscount < 1 then
        image_discount:show():getChildByName("text_discount"):setString((UIShop.recruitDiscount * 10) .. Lang.ui_shop13)
    else
        image_discount:hide()
    end

    if UIShop.recruitFreeTime ~= 0 then
        timeLabel[1].text:setString(Lang.ui_shop14 .. UIShop.recruitFreeTime .. Lang.ui_shop15)
    else
        timeLabel[1].text:setString(Lang.ui_shop16)
        image_recruit_silver:getChildByName("image_free"):setVisible(false)
    end
    recruitTokenNum = 0
    if net.InstPlayerThing then
        for key, obj in pairs(net.InstPlayerThing) do
            if StaticThing.recruitSign == obj.int["3"] then
                recruitTokenNum = obj.int["5"]
                break
            end
        end
    end
    ui_token:getChildByName("image_good_hint"):setVisible(recruitTokenNum ~= 0)
    selectedBtnChange(shopFlag)
    scrollView:removeAllChildren()
    local ShopThing = { }
    local netThing = { }
    if shopFlag == 1 then
        scrollView:setVisible(false)
        btn_preview:setVisible(true)
        image_recruit_silver:setVisible(true)
        image_recruit_jewel:setVisible(true)
        UIGuidePeople.isGuide(image_recruit_jewel, UIShop)
    elseif shopFlag == 2 then
        netThing = propThing
        scrollView:setVisible(true)
        btn_preview:setVisible(false)
        image_recruit_silver:setVisible(false)
        image_recruit_jewel:setVisible(false)
    elseif shopFlag == 3 then
        netThing = gemThing
        scrollView:setVisible(true)
        btn_preview:setVisible(false)
        image_recruit_silver:setVisible(false)
        image_recruit_jewel:setVisible(false)
    end
    if netThing then
        for key, obj in pairs(netThing) do
            table.insert(ShopThing, obj)
        end
    end
    utils.quickSort(ShopThing, compare)
    if next(ShopThing) then
        utils.updateView(UIShop, scrollView, listItem, ShopThing, setScrollViewItem, shopFlag)
    else
        if UIShop.isFlush then
            UIShop.isFlush = nil
        end
    end
    if shopFlag == 1 and(not UIGuidePeople.guideFlag) then
        ActionManager.Shop_SplashAction(UIShop.Widget)
    end
end
function UIShop.reset(flag)
    shopFlag = flag
end

function UIShop.clearData()
    buyProp = false
    buyCore = false
    propThing = { }
    gemThing = { }
end

function UIShop.free()
    scrollView:removeAllChildren()
    if scheduleId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleId)
        scheduleId = nil
    end
end

function UIShop.setRecruitData(pack)
    local message = pack.msgdata.message
    UIShop.recruitFreeTime = message["1"].int["2"]
    UIShop.recruitDiamondOnePrice = message["3"].int["2"]
    UIShop.recruitTenPrice = message["3"].int["3"]
    UIShop.recruitPurpleTimer = message["3"].int["4"]
    time1 = math.floor(message["1"].long["1"] / 1000)
    --- 毫秒变成秒
    time3 = math.floor(message["3"].long["1"] / 1000)

    UIShop.recruitDiscount = (pack.msgdata.int["welfareInfo"] or 100) / 100

    if UIShop.recruitFreeTime == 0 then
        time1 = 0
    end
    UIShopRecruitTen.time = time1
    if UIShopRecruitTen.Widget and UIShopRecruitTen.Widget:getParent() then
        recruitEnabled = false
        UIShopRecruitTen.setup()
    else
        if recruitEnabled then
            recruitEnabled = false
            UIManager.hideWidget("ui_notice")
            UIManager.pushScene("ui_shop_recruit_ten", true)
        end
    end
    UIManager.flushWidget(UIShop)
    UIManager.flushWidget(UIShopRecruitJewel)
    UIMenu.showMenuDot(message)
end

function UIShop.setTimeInterval(intervalTime)
    local countDownTime1 = time1 - intervalTime
    local countDownTime3 = time3 - intervalTime
    if countDownTime1 > 0 then
        time1 = countDownTime1
        UIShopRecruitTen.time = countDownTime1
    else
        time1 = 0
        UIShopRecruitTen.time = 0
    end

    if countDownTime3 > 0 then
        time3 = countDownTime3
    else
        time3 = 0
    end
end
