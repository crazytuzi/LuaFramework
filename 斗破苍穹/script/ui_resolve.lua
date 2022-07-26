require"Lang"
UIResolve = { }

UIResolve.operateType = {
    resolve = "resolve",
    rinne = "rinne",
}

--轮回预览标识位
UIResolve.RinnePreviewFlag = {
    card = 1, --卡牌轮回
    equip = 2 --装备轮回
}

local _rinnePreviewFlag = nil
local _operateType = nil
local InstPlayerCardObj = nil
local img_resolve_add = { }
local resolveAni = { }

local rinneAni = nil

local cost_number = nil
local instResolveId = nil -- 服务器返回的id

local addEquip = {
    -- 判断是否有蓝色以上装备
    flag = false,
    info = { }
}  --  要分解的装备

local addCard = {
    -- 判断是否有蓝色以上卡牌
    flag = false,
    info = { }
}  -- 要分解的卡牌

local addMagic = {
    flag = false,
    info = { }
} --要分解的功法/法宝

local addFire = {
    flag = false,
    info = { }
} -- 要分解的异火

local addFlag = nil  -- 添加物品的标志位
local _getThing = nil -- 分解后得到的物品
local _getSoulThing = nil -- 分解轮回后得到的斗魂
local ui_image_card_add = nil
local ui_image_card_big = nil
local ui_image_base_name = nil
local ui_rinneEquipIcon = nil
local Item = nil
local scrollView = nil
local Item1 = nil
local scrollView1 = nil

-- 先比较装备的品质 其次在比较等级
local function compareEquip(value1, value2)
    if DictEquipment[tostring(value1.int["4"])].equipQualityId < DictEquipment[tostring(value2.int["4"])].equipQualityId then
        return false
    elseif DictEquipment[tostring(value1.int["4"])].equipQualityId > DictEquipment[tostring(value2.int["4"])].equipQualityId then
        return true
    else
        if value1.int["5"] <= value2.int["5"] then
            return false
        else
            return true
        end
    end

end 

-- 先比较卡牌的品质 其次在比较等级
local function compareCard(value1, value2)
    if value1.int["4"] < value2.int["4"] then
        return false
    elseif value1.int["4"] > value2.int["4"] then
        return true
    else
        if value1.int["9"] <= value2.int["9"] then
            return false
        else
            return true
        end
    end
end

--
local function compareMagic(value1, value2)

end

-- 先比较异火潜力 之后比较等级
local function compareFire(value1, value2)
    if DictFire[tostring(value1.int["3"])].potential < DictFire[tostring(value2.int["3"])].potential then
        return false
    elseif DictFire[tostring(value1.int["3"])].potential > DictFire[tostring(value2.int["3"])].potential then
        return true
    else
        if value1.int["4"] <= value2.int["4"] then
            return false
        else
            return true
        end
    end

end

local function autoAddEquip()
    local pEquip = false
    local function isInlay(_instEquipId)
        if net.InstEquipGem then
            for key, obj in pairs(net.InstEquipGem) do
                if _instEquipId == obj.int["3"] then
                    if obj.int["4"] ~= 0 then
                        -- 物品Id 0表示未镶嵌宝石
                        return true
                    end
                end
            end
        end
    end

    local Equip = { }
    addEquip.info = { }
    if net.InstPlayerEquip then
        for key, obj in pairs(net.InstPlayerEquip) do
            if obj.int["6"] == 0 and not isInlay(obj.int["1"]) then
                if DictEquipment[tostring(obj.int["4"])].equipQualityId < StaticQuality.purple then
                    table.insert(Equip, obj)
                else
                    pEquip = true
                end
            end
        end
        utils.quickSort(Equip, compareEquip)
        local var = nil
        if #Equip > 5 then
            var = 5
        else
            var = #Equip
        end
        for i = 1, var, 1 do
            table.insert(addEquip.info, Equip[i])
        end
    end
    return pEquip
end

local function autoAddCard()
    local pCard = false
    local Card = { }
    addCard.info = { }
    if net.InstPlayerCard then
        for key, obj in pairs(net.InstPlayerCard) do
            if obj.int["10"] == 0 and obj.int["15"] == 0 and obj.int["4"] >= StaticQuality.green and obj.int["4"] ~= StaticQuality.red then
                -- 不在阵 不锁定 ,红卡不能分解
                if obj.int["4"] < StaticQuality.purple then
                    if UIGuidePeople.levelStep then
                        if obj.int["10"] == 0 and obj.int["3"] == 53 and #Card == 0 then
                            table.insert(Card, obj)
                        end
                    else
                        if obj.int["3"] ~= 88 then
                            -- 不添加萧炎
                            table.insert(Card, obj)
                        end
                    end
                else
                    pCard = true
                end
            end
        end
        utils.quickSort(Card, compareCard)

        local var = nil
        if #Card > 5 then
            var = 5
        else
            var = #Card
        end
        for i = 1, var, 1 do
            table.insert(addCard.info, Card[i])
        end
    end
    return pCard
end

local function autoAddMagic()
    local pMagic = false
    local Magic = {}
    addMagic.info = {}
    if net.InstPlayerMagic then
        for key, obj in pairs(net.InstPlayerMagic) do
            if obj.int["8"] == 0 and DictMagic[tostring(obj.int["3"])].value1 ~= "3" then --不在阵，非金片，银片
                if obj.int["5"] == StaticMagicQuality.DJ then --紫色(地阶)
                    table.insert(Magic, obj)
                else
                    pMagic = true
                end
            end
        end
--        utils.quickSort(Magic, compareMagic)
        local var = nil
        if #Magic > 5 then
            var = 5
        else
            var = #Magic
        end
        for i = 1, var, 1 do
            table.insert(addMagic.info, Magic[i])
        end
    end
    return pMagic
end

local function autoAddFire()
    local Fire = { }
    addFire.info = { }
    if net.InstPlayerFire then
        for key, obj in pairs(net.InstPlayerFire) do
            if obj.int["7"] == 0 and DictFire[tostring(obj.int["3"])].type == 1 then
                table.insert(Fire, obj)
            end
        end
        utils.quickSort(Fire, compareFire)

        local var = nil
        if #Fire > 5 then
            var = 5
        else
            var = #Fire
        end
        for i = 1, var, 1 do
            table.insert(addFire.info, Fire[i])
        end
    end
end

local function getThingFunc(data)
    local getThingImage = { }
    local getThingImageName = { }
    local getThingNumber = { }
    local getThingFrame = { }
    local getThingWidget = nil
    local tempScrollView = nil
    local tempItem = nil
    if _operateType == UIResolve.operateType.rinne then
        getThingWidget = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_base_samsara")
        ccui.Helper:seekNodeByName(UIResolve.Widget, "image_base_resolve"):setVisible(false)
        tempScrollView = scrollView
        tempItem = Item
    elseif _operateType == UIResolve.operateType.resolve then
        getThingWidget = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_base_resolve")
        ccui.Helper:seekNodeByName(UIResolve.Widget, "image_base_samsara"):setVisible(false)
        tempScrollView = scrollView1
        tempItem = Item1
    end
    tempScrollView:removeAllChildren()
    tempScrollView:jumpToLeft()
    if not data then
        for i = 1, 5 do
            local scrollViewItem = tempItem:clone()
            tempScrollView:addChild(scrollViewItem)
            scrollViewItem:setPosition(cc.p((tempItem:getContentSize().width + 5) * i + 9 - tempItem:getContentSize().width / 2, tempItem:getPositionY()))
            ccui.Helper:seekNodeByName(scrollViewItem, "image_get_good1"):setVisible(false)
            ccui.Helper:seekNodeByName(scrollViewItem, "text_good_name1"):setVisible(false)
            ccui.Helper:seekNodeByName(scrollViewItem, "text_number1"):setVisible(false)
            if _operateType == UIResolve.operateType.resolve then
                img_resolve_add[i]:setVisible(false)
                resolveAni[i]:setVisible(true)
            end
        end
        if _operateType == UIResolve.operateType.rinne then
            ui_image_card_add:setVisible(false)
            ui_rinneEquipIcon:setVisible(false)
            rinneAni:setVisible(true)
        end
    end
    getThingWidget:setVisible(true)

    if data ~= nil then
        local _getThingStr = nil
        local _getSoulThingStr = nil
        if _operateType == UIResolve.operateType.rinne then
            _getThingStr = data.msgdata.string.things
            _getSoulThingStr = data.msgdata.string.fightSoulList
        elseif _operateType == UIResolve.operateType.resolve then
            instResolveId = data.msgdata.int["1"]
            _getThingStr = data.msgdata.string["2"]
            _getSoulThingStr = data.msgdata.string["3"]
        end
        _getThing = utils.stringSplit(_getThingStr, ";")
        _getSoulThing = { }
        if _getSoulThingStr then
            _getSoulThing = utils.stringSplit(_getSoulThingStr, ";")
        end
        local ItemWidth = tempItem:getContentSize().width
        ItemWidth =(ItemWidth + 5) *(#_getThing + #_getSoulThing) + 5

        if ItemWidth < tempScrollView:getContentSize().width then
            ItemWidth = tempScrollView:getContentSize().width
        end
        tempScrollView:setInnerContainerSize(cc.size(ItemWidth, tempScrollView:getContentSize().height))

        for key, value in pairs(_getThing) do

            local scrollViewItem = tempItem:clone()
            tempScrollView:addChild(scrollViewItem)
            scrollViewItem:setPosition(cc.p((tempItem:getContentSize().width + 5) * key - tempItem:getContentSize().width / 2 + 9, tempItem:getPositionY()))
            getThingImage[key] = ccui.Helper:seekNodeByName(scrollViewItem, "image_get_good1")
            getThingImageName[key] = ccui.Helper:seekNodeByName(scrollViewItem, "text_good_name1")
            getThingNumber[key] = ccui.Helper:seekNodeByName(scrollViewItem, "text_number1")
            getThingFrame[key] = ccui.Helper:seekNodeByName(scrollViewItem, "image_frame_get_good1")

            local num = utils.stringSplit(value, "_")
            local name, image, _description = utils.getDropThing(num[1], num[2])

            local function show(Enable)
                if Enable then
                    local visibleSize = cc.Director:getInstance():getVisibleSize()
                    local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
                    bg_image:setAnchorPoint(cc.p(0.5, 0.5))
                    bg_image:setPreferredSize(cc.size(480, 150))
                    bg_image:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2 - 30))

                    local node = cc.Node:create()
                    local image_di = cc.Scale9Sprite:create("ui/quality_small_purple.png")
                    local image = ccui.ImageView:create(image)

                    local description = ccui.Text:create()
                    local height = math.floor(utils.utf8len(_description) -1) / 18 + 1
                    description:setTextAreaSize(cc.size(360, height * 25))
                    description:setFontSize(20)
                    description:setFontName(dp.FONT)
                    description:setAnchorPoint(cc.p(0, 0.5))
                    description:setString(_description)
                    description:setPosition(cc.p(image_di:getContentSize().width / 4 + 10, image_di:getPositionY() - image:getPositionY()))

                    image:setPosition(cc.p(image_di:getContentSize().width / 2, image_di:getContentSize().height / 2))
                    image_di:addChild(image)
                    image_di:setPosition(cc.p(0, 0))
                    image_di:setScale(0.5)
                    node:addChild(image_di)
                    node:addChild(description)
                    node:setPosition(cc.p(image_di:getContentSize().width / 2, bg_image:getPreferredSize().height / 2))
                    bg_image:addChild(node, 3)
                    UIResolve.Widget:addChild(bg_image, 100, 100)
                else
                    if UIResolve.Widget:getChildByTag(100) then
                        UIResolve.Widget:removeChildByTag(100)
                    end
                end
            end
            local function showEvent(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    show(false)
                elseif eventType == ccui.TouchEventType.began then
                    show(true)
                else
                    show(false)
                end
            end
            getThingImage[key]:loadTexture(image)
            getThingImageName[key]:setString(name)
            getThingNumber[key]:setString(tostring(num[3]))
            getThingImage[key]:setVisible(true)
            getThingImageName[key]:setVisible(true)
            getThingNumber[key]:setVisible(true)
            if tonumber(num[1]) == StaticTableType.DictCard then
                local dictData = DictCard[tostring(num[2])]
                local qualityId = dictData.qualityId
                local borderImage = utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.small)
                getThingFrame[key]:loadTexture(borderImage)
            elseif tonumber(num[1]) == StaticTableType.DictEquipment then
                local dictData = DictEquipment[tostring(num[2])]
                local qualityId = dictData.equipQualityId
                local borderImage = utils.getQualityImage(dp.Quality.equip, qualityId, dp.QualityImageType.small)
                getThingFrame[key]:loadTexture(borderImage)
            end
           -- getThingFrame[key]:setTouchEnabled(true)
           -- getThingFrame[key]:addTouchEventListener(showEvent)
            utils.showThingsInfo( getThingFrame[key] , num[1], num[2] )
        end
        for key, value in pairs(_getSoulThing) do
            local index = key + #_getThing
            local scrollViewItem = tempItem:clone()
            tempScrollView:addChild(scrollViewItem)
            scrollViewItem:setPosition(cc.p((tempItem:getContentSize().width + 5) *(index) - tempItem:getContentSize().width / 2 + 9, tempItem:getPositionY()))
            getThingImage[index] = ccui.Helper:seekNodeByName(scrollViewItem, "image_get_good1")
            getThingImageName[index] = ccui.Helper:seekNodeByName(scrollViewItem, "text_good_name1")
            getThingNumber[index] = ccui.Helper:seekNodeByName(scrollViewItem, "text_number1")
            getThingFrame[index] = ccui.Helper:seekNodeByName(scrollViewItem, "image_frame_get_good1")

            local num = 1
            local soulData = net.InstPlayerFightSoul[tostring(value)]
            local name = DictFightSoul[tostring(soulData.int["3"])].name
            local imageName = DictFightSoul[tostring(soulData.int["3"])].effects
            local qualityId = DictFightSoul[tostring(soulData.int["3"])].fightSoulQualityId
            local proType, proValue, sell = utils.getSoulPro(soulData.int["3"], soulData.int["5"])
            local _description = ""
            if proValue < 1 then
                _description = Lang.ui_resolve1 .. "+" ..(proValue * 100) .. "%" .. DictFightProp[tostring(proType)].name
            else
                _description = Lang.ui_resolve2 .. "+" .. proValue .. DictFightProp[tostring(proType)].name
            end

            local function show(Enable)
                if Enable then
                    local visibleSize = cc.Director:getInstance():getVisibleSize()
                    local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
                    bg_image:setAnchorPoint(cc.p(0.5, 0.5))
                    bg_image:setPreferredSize(cc.size(480, 150))
                    bg_image:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2 - 30))

                    local node = cc.Node:create()
                    local image_di = cc.Scale9Sprite:create("ui/quality_small_purple.png")
                    local image = ccui.ImageView:create()
                    utils.addSoulParticle(image, imageName,qualityId)
                    local description = ccui.Text:create()
                    local height = math.floor(utils.utf8len(_description) -1) / 18 + 1
                    description:setTextAreaSize(cc.size(360, height * 25))
                    description:setFontSize(20)
                    description:setFontName(dp.FONT)
                    description:setAnchorPoint(cc.p(0, 0.5))
                    description:setString(_description)
                    description:setPosition(cc.p(image_di:getContentSize().width / 4 + 10, image_di:getPositionY() - image:getPositionY()))

                    image:setPosition(cc.p(image_di:getContentSize().width / 2, image_di:getContentSize().height / 2))
                    image_di:addChild(image)
                    image_di:setPosition(cc.p(0, 0))
                    image_di:setScale(0.5)
                    node:addChild(image_di)
                    node:addChild(description)
                    node:setPosition(cc.p(image_di:getContentSize().width / 2, bg_image:getPreferredSize().height / 2))
                    bg_image:addChild(node, 3)
                    UIResolve.Widget:addChild(bg_image, 100, 100)
                else
                    if UIResolve.Widget:getChildByTag(100) then
                        UIResolve.Widget:removeChildByTag(100)
                    end
                end
            end
            local function showEvent(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    show(false)
                elseif eventType == ccui.TouchEventType.began then
                    show(true)
                elseif eventType == ccui.TouchEventType.canceled then
                    show(false)
                else
                   -- show(false)
                end
            end
            getThingImage[index]:setVisible(false)
            utils.addSoulParticle(getThingImage[index]:getParent(), imageName,qualityId)
            getThingImageName[index]:setString(name)
            getThingNumber[index]:setString(tostring(num))
            -- getThingImage[index]:setVisible(true)
            getThingImageName[index]:setVisible(true)
            getThingNumber[index]:setVisible(true)

            utils.ShowFightSoulQuality(getThingFrame[index], soulData.int["4"], 1)

            getThingFrame[index]:setTouchEnabled(true)
            getThingFrame[index]:addTouchEventListener(showEvent)
        end
    end
end
local function btn_replaceAddFunc()
    for i = 1, 5, 1 do
        local temp = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_resolve_good" .. i)
        --       local container = img_resolve_add[i]:getChildByName("image_fire")
        --       container:removeAllChildren()
        img_resolve_add[i]:loadTexture("ui/low_small_white.png")
        temp:loadTexture("ui/frame_tianjia.png")
        if not temp:isVisible() then
            -- resolveAni[ i ]:setVisible( false )
            temp:setVisible(false)
        end
    end
end
local function netReViewCallback(data)
    local resolveNeedCopper = 0
    if addFlag == 1 then
        for i = 1, #addEquip.info do
            if addEquip.flag == false and DictEquipment[tostring(addEquip.info[i].int["4"])].equipQualityId > StaticEquip_Quality.green then
                addEquip.flag = true
            end
            local smallUiId = DictEquipment[tostring(addEquip.info[i].int["4"])].smallUiId
            local smallImage = DictUI[tostring(smallUiId)].fileName
            local temp = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_resolve_good" .. i)
            -- local container = img_resolve_add[i]:getChildByName("image_fire")
            -- container:setVisible(false)
            local qualityId = DictEquipment[tostring(addEquip.info[i].int["4"])].equipQualityId
            local borderImage = utils.getQualityImage(dp.Quality.equip, qualityId, dp.QualityImageType.small)
            temp:setVisible(true)
            temp:loadTexture("image/" .. smallImage)
            img_resolve_add[i]:setVisible(true)
            img_resolve_add[i]:loadTexture(borderImage)
            resolveAni[i]:setVisible(false)
            resolveNeedCopper = resolveNeedCopper + DictEquipQuality[tostring(qualityId)].resolveNeedCopper
        end
        local length = #addEquip.info > 0 and #addEquip.info + 1 or 1
        for i = length, 5 do
            img_resolve_add[i]:setVisible(false)
            resolveAni[i]:setVisible(true)
        end
    elseif addFlag == 2 then
        for i = 1, #addCard.info do
            if addCard.flag == false and addCard.info[i].int["4"] > StaticQuality.blue then
                addCard.flag = true
            end
            local smallUiId = DictCard[tostring(addCard.info[i].int["3"])].smallUiId
            local smallImage = DictUI[tostring(smallUiId)].fileName
            local temp = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_resolve_good" .. i)
            local qualityId = addCard.info[i].int["4"]
            local borderImage = utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.small)
            -- local container = img_resolve_add[i]:getChildByName("image_fire")
            -- container:setVisible(false)
            temp:setVisible(true)
            img_resolve_add[i]:setVisible(true)
            resolveAni[i]:setVisible(false)
            img_resolve_add[i]:loadTexture(borderImage)
            temp:loadTexture("image/" .. smallImage)

            resolveNeedCopper = resolveNeedCopper + DictQuality[tostring(qualityId)].resolveNeedCopper
        end
        local length = #addCard.info > 0 and #addCard.info + 1 or 1
        for i = length, 5 do
            img_resolve_add[i]:setVisible(false)
            resolveAni[i]:setVisible(true)
        end
        UIGuidePeople.isGuide(nil, UIResolve)
    elseif addFlag == 4 then
        for i = 1, #addMagic.info do
            local smallUiId = DictMagic[tostring(addMagic.info[i].int["3"])].smallUiId
            local smallImage = DictUI[tostring(smallUiId)].fileName
            local temp = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_resolve_good" .. i)
            local qualityId = addMagic.info[i].int["5"]
            local borderImage = utils.getQualityImage(dp.Quality.gongFa, qualityId, dp.QualityImageType.small)
            temp:setVisible(true)
            img_resolve_add[i]:setVisible(true)
            resolveAni[i]:setVisible(false)
            img_resolve_add[i]:loadTexture(borderImage)
            temp:loadTexture("image/" .. smallImage)
--            resolveNeedCopper = resolveNeedCopper + DictMagicQuality[tostring(qualityId)] 待定
        end
        local length = #addMagic.info > 0 and #addMagic.info + 1 or 1
        for i = length, 5 do
            img_resolve_add[i]:setVisible(false)
            resolveAni[i]:setVisible(true)
        end
        --    elseif  addFlag == 3 then
        --        for i=1,#addFire.info do
        --          local dictFireId = addFire.info[i].int["3"] --异火字典ID
        --          local dictFireData = DictFire[tostring(dictFireId)] --异火字典表数据
        --          local fireType = dictFireData.type --异火类型 1-异火 2-兽火
        --           local temp =btn_resolve_add[i]:getChildByName("image_resolve_good" .. i)
        --           local container = btn_resolve_add[i]:getChildByName("image_fire")
        --           container:setVisible(true)
        --           btn_resolve_add[i]:loadTextureNormal(utils.getQualityImage(dp.Quality.fire, fireType,dp.QualityImageType.small))
        --           temp:setVisible(false)
        --           ActionManager.setFireEffectAction(dictFireId, container)
        --           local pilstFiles = utils.stringSplit(dictFireData.plists, ";")
        --           for key, obj in pairs(pilstFiles) do
        --            local particle = cc.ParticleSystemQuad:create("particle/" .. obj)
        --            particle:setPosition(cc.p(container:getContentSize().width / 2, container:getContentSize().height / 2))
        --            container:addChild(particle, 1)
        --           end
        --           local potentialId = DictFire[tostring(addFire.info[i].int["4"])].potential
        --           resolveNeedCopper = resolveNeedCopper + DictSysConfig[tostring(StaticSysConfig.resolveFireCopper)].value --异火消耗的铜钱先定死 以后改
        --        end
    end
    getThingFunc(data)
    cclog("addEquip.info number=" .. #addEquip.info)
    cost_number:setString(string.format("%s", resolveNeedCopper))
end
local function getThingShow(_name, _image, _number, _borderImage)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
    bg_image:retain()
    bg_image:setAnchorPoint(cc.p(0.5, 0.5))

--    if #_name == 4 then
--        bg_image:setPreferredSize(cc.size(600, 400))
--    elseif #_name == 5 then
--        bg_image:setPreferredSize(cc.size(650, 400))
--    else
        bg_image:setPreferredSize(cc.size(500, 400))
--    end
    bg_image:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2 - 30))
    local label = ccui.Text:create()
    label:setTextAreaSize(cc.size(180, 30))
    label:setFontSize(30)
    label:setFontName(dp.FONT)
    local textStr = Lang.ui_resolve3
    label:setString(textStr)
    label:setTextColor(cc.c4b(255, 255, 0, 255))
    label:setPosition(cc.p(bg_image:getPreferredSize().width / 2, bg_image:getPreferredSize().height - 50))
    bg_image:addChild(label, 3)

--    local node_di = cc.Node:create()
    local node_di = ccui.ScrollView:create()
    local line = #_name + 1
    local width = bg_image:getPreferredSize().width
    local _scrollViewHeight = 0
    local _svInnerWidth = 0
    local space = 10
    for key, obj in pairs(_name) do
        local node = cc.Node:create()
        local name = ccui.Text:create()
        name:setFontSize(24)
        name:setFontName(dp.FONT)
        name:setString(tostring(obj))

        local image_di = ccui.ImageView:create(_borderImage[key])
        local number_di = ccui.ImageView:create("ui/di_name.png")
        local number_text = ccui.Text:create()
        number_text:setFontSize(24)
        number_text:setFontName(dp.FONT)
        local image = ccui.ImageView:create()
        local a, b = string.find(_image[key], ".plist")
        if not a then
            image:loadTexture(_image[key])
        else
            utils.addSoulParticle(image, _image[key])
        end
        number_text:setAnchorPoint(1, 0)
        number_text:setString(tostring(_number[key]))
        number_text:setPosition(cc.p(image_di:getPositionX() + image_di:getContentSize().width / 2 - 10, image_di:getPositionY() - image_di:getContentSize().height / 2 + 4))

        image:setPosition(cc.p(image_di:getContentSize().width / 2, image_di:getContentSize().height / 2))
        image_di:addChild(image)
        number_di:addChild(name)
        node:addChild(image_di)
        node:addChild(number_di)
        node:addChild(number_text)
        name:setPosition(cc.p(number_di:getContentSize().width / 2, number_di:getContentSize().height / 2))
        number_di:setPosition(cc.p(0, - image_di:getContentSize().height / 2 - number_di:getContentSize().height / 2))
        node_di:addChild(node)
--        node:setPosition(cc.p(width * key / line - bg_image:getPreferredSize().width / 2, 0))
        node:setContentSize(cc.size(image_di:getContentSize().width, image_di:getContentSize().height + number_di:getContentSize().height + 35))
        if node:getContentSize().height > _scrollViewHeight then
            _scrollViewHeight = node:getContentSize().height
        end
        _svInnerWidth = _svInnerWidth + node:getContentSize().width + space
    end
    node_di:setContentSize(cc.size(bg_image:getPreferredSize().width - 50, _scrollViewHeight))
    if _svInnerWidth < node_di:getContentSize().width then
        _svInnerWidth = node_di:getContentSize().width
    end
    node_di:setInnerContainerSize(cc.size(_svInnerWidth, _scrollViewHeight))
    node_di:setPosition(cc.p((bg_image:getPreferredSize().width - node_di:getContentSize().width) / 2, (bg_image:getPreferredSize().height - node_di:getContentSize().height) / 2 + 20))
    node_di:setDirection(ccui.ScrollViewDir.horizontal)
    node_di:setTouchEnabled(true)
    local childs = node_di:getChildren()
	local prevChild = nil
	for i = 1, #childs do
		if prevChild then
			childs[i]:setPosition(cc.p(prevChild:getPositionX() + prevChild:getContentSize().width / 2 + childs[i]:getContentSize().width / 2 + space, node_di:getContentSize().height / 2))
		else
			childs[i]:setPosition(cc.p(childs[i]:getContentSize().width / 2 + space, node_di:getContentSize().height / 2))
		end
		prevChild = childs[i]
	end

    bg_image:addChild(node_di, 3)
    local but_ok = ccui.Button:create("ui/tk_btn01.png")
    but_ok:setTitleText(Lang.ui_resolve4)
    but_ok:setTitleColor(cc.c3b(255, 255, 255))
    but_ok:setTitleFontSize(24)
    but_ok:setTitleFontName(dp.FONT)
    but_ok:setPosition(cc.p(bg_image:getPreferredSize().width / 2, 70))
    local function btnTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == but_ok then
                UIResolve.Widget:removeChildByTag(100)
                cc.release(bg_image)
                UIResolve.Widget:setEnabled(true)
                UIMenu.Widget:setEnabled(true)
                UIGuidePeople.isGuide(nil, UIMenu)
            end
        end
    end
    but_ok:addTouchEventListener(btnTouchEvent)
    but_ok:setPressedActionEnabled(true)
    bg_image:addChild(but_ok, 3)
    UIResolve.Widget:addChild(bg_image, 100, 100)
    UIResolve.Widget:setEnabled(false)
    UIMenu.Widget:setEnabled(false)
    UIGuidePeople.isGuide(but_ok, UIResolve)
end
local function netResolvedCallback(data)
    UIResolve.setup()
    if UIResolve.Widget:getChildByTag(100) ~= nil then
        UIResolve.Widget:removeChildByTag(100)
        UIResolve.Widget:setEnabled(true)
        UIMenu.Widget:setEnabled(true)
    end
    if _getThing ~= nil then
        local name_table = { }
        local image_table = { }
        local num_table = { }
        local borderImage_table = { };
        for key, value in pairs(_getThing) do
            local num = utils.stringSplit(value, "_")
            local name, image = utils.getDropThing(num[1], num[2])
            table.insert(name_table, name)
            table.insert(image_table, image)
            table.insert(num_table, num[3])
            if tonumber(num[1]) == StaticTableType.DictCard then
                local dictData = DictCard[tostring(num[2])]
                local qualityId = dictData.qualityId
                local borderImage = utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.small)
                table.insert(borderImage_table, borderImage)
            elseif tonumber(num[1]) == StaticTableType.DictEquipment then
                local dictData = DictEquipment[tostring(num[2])]
                local qualityId = dictData.equipQualityId
                local borderImage = utils.getQualityImage(dp.Quality.equip, qualityId, dp.QualityImageType.small)
                table.insert(borderImage_table, borderImage)
            else

                table.insert(borderImage_table, "ui/quality_small_purple.png")
            end
        end
        for key, value in pairs(_getSoulThing) do
            local num = 1
            local soulData = net.InstPlayerFightSoul[tostring(value)]
            local name = DictFightSoul[tostring(soulData.int["3"])].name
            local image = DictFightSoul[tostring(soulData.int["3"])].effects
            table.insert(name_table, name)
            table.insert(image_table, image)
            table.insert(num_table, num)
            local borderImage = utils.getSoulBorderImage(soulData.int["4"], 1)
            table.insert(borderImage_table, borderImage)
        end
        getThingShow(name_table, image_table, num_table, borderImage_table)
    end
end


local function netRinneiCallback(pack)
    if pack.header == StaticMsgRule.restoreCardView then
        ui_rinneEquipIcon:setVisible(false)
        local instPlayerCardId = InstPlayerCardObj.int["1"]
        local ui_text_name = ui_image_base_name:getChildByName("text_name")
        local _name = DictCard[tostring(InstPlayerCardObj.int["3"])].name
        local bigUiId = DictCard[tostring(InstPlayerCardObj.int["3"])].bigUiId
        local bigImage = DictUI[tostring(bigUiId)].fileName
        ui_image_card_big:loadTexture("image/" .. bigImage)
        ui_text_name:setString(_name)
        ui_image_card_big:setVisible(true)
        rinneAni:setVisible(false)
        ui_image_base_name:setVisible(true)
        ui_image_card_add:setVisible(true)
        getThingFunc(pack)
        local qualityId = InstPlayerCardObj.int["4"]
        local starLevelId = InstPlayerCardObj.int["5"]
        local goldValue = 0
        ccui.Helper:seekNodeByName(UIResolve.Widget, "image_frame_card"):loadTexture(utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.middle))
        for key, obj in pairs(DictRestore) do
            if obj.qualityId == qualityId and obj.starLevelId == starLevelId then
                goldValue = obj.gold
            end
        end
        cost_number:setString(string.format("%s", goldValue))
    elseif pack.header == StaticMsgRule.restoreEquipView then
        ui_image_card_add:setVisible(false)
        local instEquipData = InstPlayerCardObj
        local equipTypeId = instEquipData.int["3"] --装备类型ID
	    local dictEquipId = instEquipData.int["4"] --装备字典ID
        local dictEquipData = DictEquipment[tostring(dictEquipId)]
	    local equipAdvanceId = instEquipData.int["8"] --装备进阶字典ID

        --装备进阶字典表
	    local dictEquipAdvanceData = (equipAdvanceId >= 1000) and DictEquipAdvancered[tostring(equipAdvanceId)] or DictEquipAdvance[tostring(equipAdvanceId)]
            
        ccui.Helper:seekNodeByName(ui_rinneEquipIcon, "text_name"):setString(dictEquipData.name)
        ui_rinneEquipIcon:loadTexture("image/" .. DictUI[tostring(equipAdvanceId >= 1000 and dictEquipData.RedbigUiId or dictEquipData.bigUiId)].fileName)
        for i = 1, 5 do
		    local ui_starImg = ui_rinneEquipIcon:getChildByName("image_star" .. i)
		    if equipAdvanceId ~= 0 and dictEquipAdvanceData.starLevel >= i then
			    ui_starImg:loadTexture("ui/star01.png")
		    else
			    ui_starImg:loadTexture("ui/star02.png")
		    end
		    if i > 3 and dictEquipData.equipQualityId == StaticEquip_Quality.blue then
			    ui_starImg:setVisible(false)
		    else
			    ui_starImg:setVisible(true)
		    end
	    end
        rinneAni:setVisible(false)
        ui_rinneEquipIcon:setVisible(true)
        cost_number:setString(string.format("%s", pack.msgdata.int.gold))
        getThingFunc(pack)
    elseif pack.header == StaticMsgRule.restoreCard or pack.header == StaticMsgRule.restoreEquip then
        _rinnePreviewFlag = nil
        InstPlayerCardObj = nil
        UIResolve.setup()
        UITeamInfo.setup()
        if _getThing ~= nil then
            local name_table = { }
            local image_table = { }
            local num_table = { }
            local borderImage_table = { }
            for key, value in pairs(_getThing) do
                local num = utils.stringSplit(value, "_")
                local name, image = utils.getDropThing(num[1], num[2])
                table.insert(name_table, name)
                table.insert(image_table, image)
                table.insert(num_table, num[3])
                if tonumber(num[1]) == StaticTableType.DictCard then
                    local dictData = DictCard[tostring(num[2])]
                    local qualityId = dictData.qualityId
                    local borderImage = utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.small)
                    table.insert(borderImage_table, borderImage)
                elseif tonumber(num[1]) == StaticTableType.DictEquipment then
                    local dictData = DictEquipment[tostring(num[2])]
                    local qualityId = dictData.equipQualityId
                    local borderImage = utils.getQualityImage(dp.Quality.equip, qualityId, dp.QualityImageType.small)
                    table.insert(borderImage_table, borderImage)
                else

                    table.insert(borderImage_table, "ui/quality_small_purple.png")
                end
            end
            for key, value in pairs(_getSoulThing) do
                local num = 1
                local soulData = net.InstPlayerFightSoul[tostring(value)]
                local name = DictFightSoul[tostring(soulData.int["3"])].name
                local image = DictFightSoul[tostring(soulData.int["3"])].effects
                table.insert(name_table, name)
                table.insert(image_table, image)
                table.insert(num_table, num)
                local borderImage = utils.getSoulBorderImage(soulData.int["4"], 1)
                table.insert(borderImage_table, borderImage)
            end
            getThingShow(name_table, image_table, num_table, borderImage_table)
        end
    end
end

local function sendReViewdData(_resolveType, _resolveList)
    UIManager.showLoading()
    local data = {
        header = StaticMsgRule.preViewResolve,
        msgdata =
        {
            int =
            {
                resolveType = _resolveType,
            },
            string =
            {
                resolveList = _resolveList,
            }
        }
    }
    netSendPackage(data, netReViewCallback)
end

local function sendResolvedData(_instResolveId)
    UIManager.showLoading()
    local data = nil
    if UIGuidePeople.levelStep == "12_3" then
        data = {
            header = StaticMsgRule.makeSureResolve,
            msgdata =
            {
                int =
                {
                    instResolveId = _instResolveId,
                },
                string =
                {
                    step = "12_4"
                }
            }
        }
    else
        data = {
            header = StaticMsgRule.makeSureResolve,
            msgdata =
            {
                int =
                {
                    instResolveId = _instResolveId,
                }
            }
        }
    end
    netSendPackage(data, netResolvedCallback)
end

local function senRinneData(_header, _instPlayerCardId)
    UIManager.showLoading()
    local data = {
        header = _header,
        msgdata =
        {
            int =
            {
                instPlayerCardId = _instPlayerCardId,
            }
        }
    }
    netSendPackage(data, netRinneiCallback)
end

local function addFunction(flag)
    btn_replaceAddFunc()
    local resolveList = ""
    if flag == 1 then
        addEquip.flag = false
        local pEquip = autoAddEquip()
        for i = 1, #addEquip.info do
            resolveList = resolveList .. addEquip.info[i].int["1"] .. ";"
        end
        if resolveList == "" then
            if pEquip then
                UIManager.showToast(Lang.ui_resolve5)
            else
                UIManager.showToast(Lang.ui_resolve6)
            end
            UIResolve.Resolveclear()
            if UIGuidePeople.levelStep then
                UIGuidePeople.levelStep = nil
            end
        else
            sendReViewdData(addFlag, resolveList)
        end

    elseif flag == 2 then
        addCard.flag = false
        local pCard = autoAddCard()
        for i = 1, #addCard.info do
            resolveList = resolveList .. addCard.info[i].int["1"] .. ";"
        end
        if resolveList == "" then
            if pCard then
                UIManager.showToast(Lang.ui_resolve7)
            else
                UIManager.showToast(Lang.ui_resolve8)
            end
            UIResolve.Resolveclear()
        else
            sendReViewdData(addFlag, resolveList)
        end
    elseif flag == 4 then
        addMagic.flag = false
        local pMagic = autoAddMagic()
        for i = 1, #addMagic.info do
            resolveList = resolveList .. addMagic.info[i].int["1"] .. ";"
        end
        if resolveList == "" then
            if pMagic then
                UIManager.showToast(Lang.ui_resolve9)
            else
                UIManager.showToast(Lang.ui_resolve10)
            end
            UIResolve.Resolveclear()
        else
            sendReViewdData(addFlag, resolveList)
        end
        --      elseif flag == 3 then
        --          autoAddFire()
        --          for i=1,#addFire.info do
        --             resolveList= resolveList .. addFire.info[i].int["1"] ..";"
        --          end
        --          if resolveList == "" then
        --            UIResolve.Resolveclear()
        --            UIManager.showToast("没有物品可添加！")
        --          else
        --            sendReViewdData(addFlag,resolveList)
        --          end
    end
    cclog("resolveList=" .. resolveList)
end

local function btn_resolveFunc()
    if instResolveId ~= nil then
        cclog("instResolveId =" .. instResolveId)
    end
    if addFlag == 1 and next(addEquip.info) then
        if addEquip.flag then
            local textStr = Lang.ui_resolve11
            utils.PromptDialog(sendResolvedData, textStr, instResolveId)
        else
            sendResolvedData(instResolveId)
        end
    elseif addFlag == 2 and next(addCard.info) then
        if not UIGuidePeople.levelStep then
            if addCard.flag then
                local textStr = Lang.ui_resolve12
                utils.PromptDialog(sendResolvedData, textStr, instResolveId)
            else
                sendResolvedData(instResolveId)
            end
        else
            sendResolvedData(instResolveId)
        end
    elseif addFlag == 4 and next(addMagic.info) then
        sendResolvedData(instResolveId)
    else
        UIManager.showToast(Lang.ui_resolve13)
        return;
    end
end

function UIResolve.Resolveclear()
    if _operateType == UIResolve.operateType.resolve then
        btn_replaceAddFunc()
        addFlag = nil
        addEquip.info = { }
        addCard.info = { }
        addMagic.info = { }
    elseif _operateType == UIResolve.operateType.rinne then
        ui_image_card_add:setVisible(true)
        ui_image_card_big:setVisible(false)
        ui_image_base_name:setVisible(false)
        ui_rinneEquipIcon:setVisible(false)
    end

    getThingFunc()
    cost_number:setString(string.format("%s", "0"))
end

function UIResolve.init()
    local ui_image_base_tab = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_base_tab")
    local ui_image_base_resolve_info = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_base_samsara")
    local ui_image_cost_gold = ui_image_base_tab:getChildByName("image_cost_gold")
    cost_number = ui_image_cost_gold:getChildByName("text_cost_number")
    cost_number:setString(string.format(cost_number:getString(), 0))
    local ui_image_base_title = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_base_title")
    local btn_resolve_up = ui_image_base_title:getChildByName("btn_resolve")
    local btn_rinne_up = ui_image_base_title:getChildByName("btn_rinne")
    local ui_image_base_resolve = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_base_resolve")
    -- getThingFunc()
    local function btnaddEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if addFlag == 1 then
                UIResolve_list.resolve(addFlag, addEquip.info)
                for key, value in pairs(addEquip.info) do
                    cclog("addEquip.info[" .. key .. "]=" .. addEquip.info[key].int["4"])
                end
            elseif addFlag == 2 then
                UIResolve_list.resolve(addFlag, addCard.info)
                for key, value in pairs(addCard.info) do
                    cclog("addCard.info[" .. key .. "]=" .. addCard.info[key].int["3"])
                end
            elseif addFlag == 4 then
                UIResolve_list.resolve(addFlag, addMagic.info)
                for key, value in pairs(addMagic.info) do
                    cclog("addMagic.info[" .. key .. "]=" .. addMagic.info[key].int["3"])
                end
            else
                UIResolve_list.resolve(nil, { })
            end
            UIResolve_list.setOperateType(UIResolve.operateType.resolve)
            UIManager.pushScene("ui_resolve_list")
        end
    end
    for i = 1, 5, 1 do
        img_resolve_add[i] = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_frame_good" .. i)
        img_resolve_add[i]:addTouchEventListener(btnaddEvent)
        local temp = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_resolve_good" .. i)
        -- temp:setVisible( false )
        resolveAni[i] = ActionManager.getEffectAnimation(38, nil, 0)

        resolveAni[i]:setPosition(img_resolve_add[i]:getPositionX(), img_resolve_add[i]:getPositionY())
        img_resolve_add[i]:getParent():addChild(resolveAni[i], img_resolve_add[i]:getLocalZOrder() + temp:getLocalZOrder())
    end

    local btn_add_equipment = ccui.Helper:seekNodeByName(UIResolve.Widget, "btn_equipment")
    local btn_add_card = ccui.Helper:seekNodeByName(UIResolve.Widget, "btn_card")
    local btn_add_treasure = ccui.Helper:seekNodeByName(UIResolve.Widget, "btn_treasure")
    local btn_shop = ccui.Helper:seekNodeByName(UIResolve.Widget, "btn_shop")
    -- zy
    local btn_heijiaoyu = ccui.Helper:seekNodeByName(UIResolve.Widget, "btn_heijiaoyu")
    local image_di1 = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_di")
    local ui_image_base_title = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_base_title")
    local text_hint = ui_image_base_title:getChildByName("text_hint")
    local image_hunyuan = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_hunyuan")
    local image_stone = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_stone")
    local image_treasure = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_treasure")
    -- local btn_add_fire =ccui.Helper:seekNodeByName(UIResolve.Widget,"btn_add_fire")
    local btn_resolve = ui_image_base_tab:getChildByName("btn_resolve")
    ui_image_card_add = ui_image_base_resolve_info:getChildByName("image_frame_card")
    -- ui_image_card_add:setVisible(false)
    ui_image_card_big = ui_image_card_add:getChildByName("image_card")
    ui_rinneEquipIcon = ui_image_base_resolve_info:getChildByName("image_good")
    rinneAni = ActionManager.getEffectAnimation(39, nil, 0)
    rinneAni:setPosition(ui_image_card_add:getPositionX(), ui_image_card_add:getPositionY() -80)
    ui_image_card_add:getParent():addChild(rinneAni, ui_image_card_add:getLocalZOrder())
    ui_image_base_name = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_base_name")
    btn_add_equipment:setPressedActionEnabled(true)
    btn_add_card:setPressedActionEnabled(true)
    btn_add_treasure:setPressedActionEnabled(true)
    btn_resolve:setPressedActionEnabled(true)
    btn_resolve_up:setPressedActionEnabled(true)
    btn_rinne_up:setPressedActionEnabled(true)
    btn_shop:setPressedActionEnabled(true)
    -- zy
    btn_heijiaoyu:setPressedActionEnabled(true)

    local function btnTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_add_equipment then
                --- 添加装备
                addFlag = 1
                addFunction(addFlag)
            elseif sender == btn_add_card then
                --- 添加卡牌
                addFlag = 2
                addFunction(addFlag)
            elseif sender == btn_add_treasure then
                --- 添加法宝
                addFlag = 4
                addFunction(addFlag)
            elseif sender == btn_shop then
                -- zy 神装商店
                UIManager.pushScene("ui_tower_shop")
                -- elseif sender == btn_add_fire then---添加异火
                --     addFlag = 3
                --     addFunction(addFlag)
            elseif sender == btn_heijiaoyu then
                -- zy 神秘商店
                UIActivityPanel.scrollByName("hJYStore", "hJYStore")
                UIManager.showWidget("ui_activity_panel")

            elseif sender == btn_resolve then
                --- 分解或轮回
                if _operateType == UIResolve.operateType.resolve then
                    btn_resolveFunc()
                elseif _operateType == UIResolve.operateType.rinne then
                    if InstPlayerCardObj ~= nil then
                        if _rinnePreviewFlag == UIResolve.RinnePreviewFlag.equip then
                            UIManager.showLoading()
                            local data = {
                                header = StaticMsgRule.restoreEquip,
                                msgdata =
                                {
                                    int =
                                    {
                                        equipId = InstPlayerCardObj.int["1"],
                                    }
                                }
                            }
                            netSendPackage(data, netRinneiCallback)
                        elseif _rinnePreviewFlag == UIResolve.RinnePreviewFlag.card then
                            senRinneData(StaticMsgRule.restoreCard, InstPlayerCardObj.int["1"])
                        end
                    else
                        UIManager.showToast(Lang.ui_resolve14)
                    end
                end

            elseif sender == btn_resolve_up then
                --- 分解选项
                if _operateType == UIResolve.operateType.resolve then
                    return
                end
                InstPlayerCardObj = nil
                _operateType = UIResolve.operateType.resolve
                btn_resolve_up:loadTextureNormal("ui/yh_btn02.png")
                btn_resolve_up:getChildByName("text_resolve"):setTextColor(cc.c3b(51, 25, 4))
                btn_rinne_up:loadTextureNormal("ui/yh_btn01.png")
                btn_rinne_up:getChildByName("text_rinne"):setTextColor(cc.c3b(255, 255, 255))
                ui_image_card_add:setVisible(false)
                ui_image_card_big:setVisible(false)
                ui_image_base_name:setVisible(false)
                -- zy
                btn_heijiaoyu:setVisible(true)

                btn_shop:setVisible(true)
                image_di1:setVisible(true)
                text_hint:setVisible(true)
                image_hunyuan:setVisible(true)
                image_stone:setVisible(true)
                image_treasure:setVisible(true)
                btn_resolve:setTitleText(Lang.ui_resolve15)
                ui_image_cost_gold:loadTexture("ui/yin.png")
                getThingFunc()
                for i = 1, 5, 1 do
                    img_resolve_add[i]:setVisible(true)
                    resolveAni[i]:setVisible(true)
                    local temp = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_resolve_good" .. i)
                    temp:setVisible(false)
                end
                UIResolve.setup()
            elseif sender == btn_rinne_up then
                --- 轮回选项
                if _operateType == UIResolve.operateType.rinne then
                    return
                end
                _getThing = nil
                _getSoulThing = nil
                instResolveId = nil
                _operateType = UIResolve.operateType.rinne
                btn_rinne_up:loadTextureNormal("ui/yh_btn02.png")
                btn_rinne_up:getChildByName("text_rinne"):setTextColor(cc.c3b(51, 25, 4))
                btn_resolve_up:loadTextureNormal("ui/yh_btn01.png")
                btn_resolve_up:getChildByName("text_resolve"):setTextColor(cc.c3b(255, 255, 255))
                ui_image_card_add:setVisible(false)
                ui_image_card_big:loadTexture("ui/frame_tianjia.png")
                ui_image_card_big:setVisible(false)

                -- zy
                btn_heijiaoyu:setVisible(false)

                btn_shop:setVisible(false)

                image_di1:setVisible(false)
                text_hint:setVisible(false)
                image_hunyuan:setVisible(false)
                image_stone:setVisible(false)
                image_treasure:setVisible(false)
                -- rinneAni:setVisible( true )
                ui_image_base_name:setVisible(false)
                btn_resolve:setTitleText(Lang.ui_resolve16)
                ui_image_cost_gold:loadTexture("ui/jin.png")
                getThingFunc()
                for i = 1, 5, 1 do
                    img_resolve_add[i]:setVisible(false)
                end
                rinneAni:setVisible(true)
                UIResolve.setup()
            elseif sender == ui_image_card_add or sender == ui_image_card_big or sender == ui_image_base_resolve_info then
                --- 轮回添加
                UIResolve_list.setOperateType(UIResolve.operateType.rinne)
                UIManager.pushScene("ui_resolve_list")
            end
        end
    end
    btn_add_equipment:addTouchEventListener(btnTouchEvent)
    btn_add_card:addTouchEventListener(btnTouchEvent)
    btn_add_treasure:addTouchEventListener(btnTouchEvent)
    btn_shop:addTouchEventListener(btnTouchEvent)
    -- zy
    btn_heijiaoyu:addTouchEventListener(btnTouchEvent)
    btn_resolve:addTouchEventListener(btnTouchEvent)
    btn_resolve_up:addTouchEventListener(btnTouchEvent)
    btn_rinne_up:addTouchEventListener(btnTouchEvent)
    ui_image_card_add:setTouchEnabled(true)
    ui_image_card_add:addTouchEventListener(btnTouchEvent)
    ui_image_card_big:setTouchEnabled(true)
    ui_image_card_big:addTouchEventListener(btnTouchEvent)
    ui_image_base_resolve_info:setTouchEnabled(true)
    ui_image_base_resolve_info:addTouchEventListener(btnTouchEvent)
    ui_image_base_resolve:addTouchEventListener(btnaddEvent)
    ui_image_base_resolve:setTouchEnabled(true)
    scrollView = ccui.Helper:seekNodeByName(ccui.Helper:seekNodeByName(UIResolve.Widget, "image_base_samsara"), "view_good")
    Item = scrollView:getChildByName("image_frame_get_good1"):clone()
    scrollView1 = ccui.Helper:seekNodeByName(ccui.Helper:seekNodeByName(UIResolve.Widget, "image_base_resolve"), "view_good")
    Item1 = scrollView1:getChildByName("image_frame_get_good1"):clone()
end

function UIResolve.setup()
    UIGuidePeople.isGuide(nil, UIResolve)
    if Item:getReferenceCount() == 1 then
        Item:retain()
    end
    if Item1:getReferenceCount() == 1 then
        Item1:retain()
    end
    local hunNumText = ccui.Helper:seekNodeByName(UIResolve.Widget, "text_hunyuan_number")
    hunNumText:setString(utils.getThingCount(StaticThing.soulSource))
    local stoneNumText = ccui.Helper:seekNodeByName(UIResolve.Widget, "text_stone_number")
    stoneNumText:setString(tostring(net.InstPlayer.int["21"]))
    local treasureNumText = ccui.Helper:seekNodeByName(UIResolve.Widget, "text_treasure_number")
    treasureNumText:setString(tostring(utils.getThingCount(StaticThing.thing302)))
    if _operateType == nil then
        _operateType = UIResolve.operateType.resolve
        local ui_image_base_title = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_base_title")
        local btn_resolve_up = ui_image_base_title:getChildByName("btn_resolve")
        local btn_rinne_up = ui_image_base_title:getChildByName("btn_rinne")
        local ui_image_base_tab = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_base_tab")
        local ui_image_cost_gold = ui_image_base_tab:getChildByName("image_cost_gold")
        local ui_imageFight = ccui.Helper:seekNodeByName(ui_image_base_title, "label_fight")
        ui_imageFight:setString(utils.getFightValue())
        ui_image_cost_gold:loadTexture("ui/yin.png")
        btn_resolve_up:loadTextureNormal("ui/yh_btn02.png")
        btn_resolve_up:getChildByName("text_resolve"):setTextColor(cc.c3b(51, 25, 4))
        btn_rinne_up:loadTextureNormal("ui/yh_btn01.png")
        btn_rinne_up:getChildByName("text_rinne"):setTextColor(cc.c3b(255, 255, 255))
        ui_image_card_add:setVisible(false)
        rinneAni:setVisible(false)
        ui_image_card_big:setVisible(false)
        ui_image_base_name:setVisible(false)
        ui_image_base_tab:getChildByName("btn_resolve"):setTitleText(Lang.ui_resolve17)
        getThingFunc()
        for i = 1, 5, 1 do
            img_resolve_add[i]:setVisible(true)
            local temp = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_resolve_good" .. i)
            temp:setVisible(false)
        end
        local btn_heijiaoyu = ccui.Helper:seekNodeByName(UIResolve.Widget, "btn_heijiaoyu")
        local btn_shop = ccui.Helper:seekNodeByName(UIResolve.Widget, "btn_shop")
        local image_di1 = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_di")
        local ui_image_base_title = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_base_title")
        local text_hint = ui_image_base_title:getChildByName("text_hint")
        local image_hunyuan = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_hunyuan")
        local image_stone = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_stone")
        local image_treasure = ccui.Helper:seekNodeByName(UIResolve.Widget, "image_treasure")
        btn_heijiaoyu:setVisible(true)
        btn_shop:setVisible(true)
        image_di1:setVisible(true)
        text_hint:setVisible(true)
        image_hunyuan:setVisible(true)
        image_stone:setVisible(true)
        image_treasure:setVisible(true)
    end
    local gold_number = ccui.Helper:seekNodeByName(UIResolve.Widget, "text_gold_number")
    local silver_number = ccui.Helper:seekNodeByName(UIResolve.Widget, "text_silver_number")
    gold_number:setString(tostring(net.InstPlayer.int["5"]))
    silver_number:setString(net.InstPlayer.string["6"])
    UIResolve.Resolveclear()
end

function UIResolve.manualAdd(flag, resolveThing)
    if resolveThing ~= nil then
        addFlag = flag
    else
        addFlag = nil
        getThingFunc()
        addEquip.info = { }
        addCard.info = { }
        addMagic.info = { }
    end
    btn_replaceAddFunc()
    local resolveNeedCopper = 0
    cost_number:setString(string.format("%s", resolveNeedCopper))
    local resolveList = ""
    if addFlag == 1 then
        addEquip.flag = false
        addEquip.info = resolveThing
        utils.quickSort(addEquip.info, compareEquip)
        for i = 1, #addEquip.info do
            resolveList = resolveList .. addEquip.info[i].int["1"] .. ";"
        end
        sendReViewdData(addFlag, resolveList)
    elseif addFlag == 2 then
        addCard.flag = false
        addCard.info = resolveThing
        utils.quickSort(addCard.info, compareCard)
        for i = 1, #addCard.info do
            resolveList = resolveList .. addCard.info[i].int["1"] .. ";"
        end
        sendReViewdData(addFlag, resolveList)
    elseif addFlag == 4 then
        addMagic.flag = false
        addMagic.info = resolveThing
        utils.quickSort(addMagic.info, compareMagic)
        for i = 1, #addMagic.info do
            resolveList = resolveList .. addMagic.info[i].int["1"] .. ";"
        end
        sendReViewdData(addFlag, resolveList)
    end
    cclog("resolveList=" .. resolveList)
end


function UIResolve.setRinneData(_InstPlayerCardObj, _previewFlag)
    if _InstPlayerCardObj == nil then
        UIResolve.setup()
        return
    end
    InstPlayerCardObj = _InstPlayerCardObj
    local instPlayerCardId = InstPlayerCardObj.int["1"]
    _rinnePreviewFlag = _previewFlag
    if _rinnePreviewFlag == UIResolve.RinnePreviewFlag.equip then
        UIManager.showLoading()
        local data = {
            header = StaticMsgRule.restoreEquipView,
            msgdata =
            {
                int =
                {
                    equipId = instPlayerCardId,
                }
            }
        }
        netSendPackage(data, netRinneiCallback)
    elseif _rinnePreviewFlag == UIResolve.RinnePreviewFlag.card then
        senRinneData(StaticMsgRule.restoreCardView, instPlayerCardId)
    end
end

function UIResolve.setOperateType(operateType)
    _operateType = operateType
end

function UIResolve.free()
    _getThing = nil
    _getSoulThing = nil
    InstPlayerCardObj = nil
    _rinnePreviewFlag = nil
    instResolveId = nil
    _operateType = nil
end
