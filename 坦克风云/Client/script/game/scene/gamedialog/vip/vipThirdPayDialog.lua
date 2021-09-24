--部分平台需求（德国等），第三方支付的面板
vipThirdPayDialog = commonDialog:new()

function vipThirdPayDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function vipThirdPayDialog:resetTab()
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2 - 35))
    self.panelLineBg:setContentSize(CCSizeMake(620, G_VisibleSizeHeight - 100))
end

function vipThirdPayDialog:initTableView()
    self:initRechargeCfg()
    local function callback(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callback)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(G_VisibleSizeWidth - 20, G_VisibleSizeHeight - 230), nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(10, 120)
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(80)
    
    local btnScale, priority = 0.8, -(self.layerNum - 1) * 20 - 4
    local function onRecharge()
        PlayEffect(audioCfg.mouseClick)
        self:rechargeHandler()
    end
    local rechargeItem, rechargeBtn = G_createBotton(self.bgLayer, ccp(0, 0), {getlocal("paymentwall"), 24}, "creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", onRecharge, 1, priority)
    rechargeItem:setScale(btnScale)
    rechargeBtn:setPosition(G_VisibleSizeWidth / 2, 60)
    
    if G_curPlatName() == "androidsevenga" or G_curPlatName() == "11" or G_curPlatName() == "0" then
        --德国新增Paypal支付
        local function paypal()
            self:paypal()
        end
        local paypalBtn, paypalMenu = G_createBotton(self.bgLayer, ccp(G_VisibleSizeWidth / 2 + 120, rechargeBtn:getPositionY()), {getlocal("paypal"), 24}, "creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", paypal, 1, priority)
        paypalBtn:setScale(btnScale)
        rechargeBtn:setPositionX(G_VisibleSizeWidth / 2 - 120)
    end
end

function vipThirdPayDialog:initRechargeCfg()
    --德国movga支付分语言特殊处理，调用底层获取语言
    if(G_curPlatName() == "11"or G_curPlatName() == "androidsevenga" or G_curPlatName() == "0")then
        local tmpTb = {}
        tmpTb["action"] = "customAction"
        tmpTb["parms"] = {}
        tmpTb["parms"]["value"] = "getCurrency"
        local cjson = G_Json.encode(tmpTb)
        self.moneyName = G_accessCPlusFunction(cjson)
        if(self.moneyName ~= "EUR" and self.moneyName ~= "CHF")then
            self.moneyName = "EUR"
        end
        local tmpTb = {}
        tmpTb["action"] = "customAction"
        tmpTb["parms"] = {}
        tmpTb["parms"]["value"] = "getLocal"
        local cjson = G_Json.encode(tmpTb)
        self.countryName = G_accessCPlusFunction(cjson)
        if(self.countryName == "" or self.countryName == nil)then
            self.countryName = G_country
        end
    else
        self.moneyName = GetMoneyName()
        self.countryName = G_country
    end
    self.storeCfg = platCfg.platCfgStoreCfg3[G_curPlatName()]
    self.cellNum = #(self.storeCfg.gold)
    local hotSellCfg = playerCfg.recharge.hotSell
    self.rechargeIndex = tonumber(hotSellCfg[1])
end

function vipThirdPayDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return self.cellNum
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(G_VisibleSizeWidth - 20, 120)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        local cellHeight = 100
        local rect = CCRect(0, 0, 50, 50)
        local capInSet = CCRect(20, 20, 10, 10)
        local curRechargeIndex = self.cellNum - idx
        local function cellClick(hd, fn, index1)
            if self.tv and self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                PlayEffect(audioCfg.mouseClick)
                self.rechargeIndex = curRechargeIndex
                local recordPoint = self.tv:getRecordPoint()
                self.tv:reloadData()
                self.tv:recoverToRecordPoint(recordPoint)
            end
        end
        local vipRechargeSprie
        if self.rechargeIndex == curRechargeIndex then
            vipRechargeSprie = LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBgSelect.png", CCRect(20, 20, 10, 10), cellClick)
        else
            vipRechargeSprie = LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png", CCRect(20, 20, 10, 10), cellClick)
        end
        vipRechargeSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40, 110))
        vipRechargeSprie:setAnchorPoint(ccp(0, 0))
        vipRechargeSprie:setPosition(ccp(10, 10))
        vipRechargeSprie:setIsSallow(false)
        vipRechargeSprie:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        cell:addChild(vipRechargeSprie)
        
        local checkBg = CCSprite:createWithSpriteFrameName("rechargeSelectBtnBg.png")
        checkBg:setAnchorPoint(ccp(0, 0.5))
        checkBg:setPosition(ccp(15, cellHeight / 2))
        vipRechargeSprie:addChild(checkBg, 1)
        
        local mType = self.storeCfg["moneyType"][self.moneyName]
        local mPrice = self.storeCfg["money"][self.moneyName][idx + 1]
        local priceStr = getlocal("buyGemsPrice", {mType, mPrice})
        if G_curPlatName() == "13" or G_curPlatName() == "androidzsykonaver" or G_curPlatName() == "androidzsykoolleh" or G_curPlatName() == "androidzsykotstore" or G_curPlatName() == "androidzhongshouyouko" or G_isKakao() or G_curPlatName() == "59" or G_curPlatName() == "androidcmge" then
            priceStr = getlocal("buyGemsPrice", {mPrice, mType})
        end
        local buyGemsPrice = GetTTFLabel(priceStr, 28)
        buyGemsPrice:setAnchorPoint(ccp(1, 0.5))
        buyGemsPrice:setPosition(ccp(self.bgLayer:getContentSize().width - 60, cellHeight / 2))
        vipRechargeSprie:addChild(buyGemsPrice, 1)
        buyGemsPrice:setColor(G_ColorGreen)
        
        local buyGemsNumber = self.storeCfg["gold"][idx + 1]
        local isShowDouble = false
        if acFirstRechargeVoApi then
            isShowDouble = acFirstRechargeVoApi:isShowFirstDouble(buyGemsNumber)
        end
        --德国第三方支付不参与首充
        if(G_curPlatName() == "11" or G_curPlatName() == "androidsevenga" or G_curPlatName() == "0")then
            isShowDouble = false
        end
        -- if isShowDouble==false and self.storeCfg["goldPreferential"][idx + 1]~="" then
        -- local buyGemsDiscount=GetTTFLabel(getlocal("buyGemsDiscount",{self.storeCfg["goldPreferential"][idx + 1]}),28)
        -- buyGemsDiscount:setAnchorPoint(ccp(1,1))
        -- buyGemsDiscount:setPosition(ccp(G_VisibleSizeWidth - 60,35))
        -- buyGemsDiscount:setColor(G_ColorYellowPro)
        -- if platCfg.platCfgStoreShowDisCount[G_curPlatName()]==nil then
        -- vipRechargeSprie:addChild(buyGemsDiscount,1)
        -- end
        -- end
        if self.rechargeIndex == curRechargeIndex then
            local checkIcon = CCSprite:createWithSpriteFrameName("rechargeSelectBtn.png")
            checkIcon:setPosition(getCenterPoint(checkBg))
            checkBg:addChild(checkIcon, 1)
            buyGemsPrice:setColor(G_ColorWhite)
            if buyGemsDiscount ~= nil then
                buyGemsDiscount:setColor(G_ColorWhite)
            end
        end
        local buyGemsNum = GetBMLabel(buyGemsNumber, G_GoldFontSrc, 30)
        buyGemsNum:setAnchorPoint(ccp(0, 0.5))
        vipRechargeSprie:addChild(buyGemsNum, 1)
        local imageStrName = "iconGoldNew"..curRechargeIndex..".png"
        local gemIcon = CCSprite:createWithSpriteFrameName(imageStrName)
        if gemIcon then
            gemIcon:setPosition(ccp(130, cellHeight / 2))
            vipRechargeSprie:addChild(gemIcon, 1)
        end
        buyGemsNum:setPosition(ccp(190, cellHeight / 2 - 5))
        local bgScale = 0.9
        if isShowDouble == true then
            local dNumSp = CCSprite:createWithSpriteFrameName("double_num.png")
            dNumSp:setAnchorPoint(ccp(0, 0.5))
            dNumSp:setPosition(ccp(buyGemsNum:getPositionX() + buyGemsNum:getContentSize().width - 5, cellHeight / 2 - 15))
            vipRechargeSprie:addChild(dNumSp, 1)
            local redBg = CCSprite:createWithSpriteFrameName("BgHot.png")
            redBg:setAnchorPoint(ccp(1, 1))
            redBg:setPosition(ccp(G_VisibleSizeWidth - 10, cellHeight + 12))
            redBg:setScale(bgScale)
            vipRechargeSprie:addChild(redBg)
            local dsPos = ccp(redBg:getContentSize().width * 0.66, redBg:getContentSize().height * 0.5)
            if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() == "tw" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() == "ja" then
                dsPos = getCenterPoint(redBg)
            end
            local doubleStr = GetTTFLabel(getlocal("first_recharge_double"), 25)
            doubleStr:setPosition(dsPos)
            doubleStr:setScale(1 / bgScale)
            redBg:addChild(doubleStr, 1)
        end
        local VipNeedGoldCFG, nowRechargeGold, playerGetedGold
        nowRechargeGold = tonumber(self.storeCfg["gold"][idx + 1])
        playerGetedGold = tonumber(playerVoApi:getBuygems())
        VipNeedGoldCFG = Split(G_getPlatVipCfg(), ",")
        local vipIdx = 1 --vip等级计数
        for k, v in pairs(VipNeedGoldCFG) do
            local num = tonumber(v)
            if nowRechargeGold + playerGetedGold < num then
                vipIdx = vipIdx - 1
                break
            end
            vipIdx = vipIdx + 1
        end
        if vipIdx > 0 and vipIdx < tonumber(playerVoApi:getMaxLvByKey("maxVip")) and vipIdx > playerVoApi:getVipLevel() then
            local nextVipIcon = CCSprite:createWithSpriteFrameName("Vip"..vipIdx..".png")
            nextVipIcon:setAnchorPoint(ccp(1, 0.5))
            nextVipIcon:setPosition(ccp(vipRechargeSprie:getContentSize().width - 10, cellHeight - 8))
            vipRechargeSprie:addChild(nextVipIcon, 50)
            nextVipIcon:setScale(0.8)
            local vipUpIcon = CCSprite:createWithSpriteFrameName("upIcon.png")
            vipUpIcon:setAnchorPoint(ccp(1, 0.5))
            vipUpIcon:setPosition(ccp(vipRechargeSprie:getContentSize().width - nextVipIcon:getContentSize().width * 0.7 - 15, cellHeight - 13))
            vipRechargeSprie:addChild(vipUpIcon, 50)
            vipUpIcon:setRotation(15)
        end
        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded" then
    end
end

function vipThirdPayDialog:rechargeHandler()
    if(self.rechargeIndex == nil or self.cellNum == nil)then
        do return end
    end
    local selectIndex = self.cellNum + 1 - self.rechargeIndex
    if(self.storeCfg.gold[selectIndex] == nil)then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage120"), 28)
        do return end
    end
    if(G_curPlatName() == "11" or G_curPlatName() == "androidsevenga" or G_curPlatName() == "0")then
        local tmpTb = {}
        tmpTb["action"] = "openUrl"
        tmpTb["parms"] = {}
        local platID = G_getUserPlatID()
        local index = string.find(platID, "_")
        if(index)then
            platID = string.sub(platID, index + 1)
        end
        local mPrice = tostring(self.storeCfg["money"][self.moneyName][tonumber(selectIndex)])
        local goldNum = self.storeCfg["gold"][tonumber(selectIndex)]
        local orderID = playerVoApi:getUid() .. "_"..base.curZoneID.."_ios_"..playerVoApi:getPlayerLevel() .. "_"..playerVoApi:getVipLevel() .. "_"..base.serverTime.."_"..platID.."_"..self.rechargeIndex.."_0_"..mPrice
        local productID, url
        if(G_curPlatName() == "11")then
            productID = "tksvg_gold_"..tostring(self.rechargeIndex + 10)
            url = "http://tank-ger-web01.raysns.com/tank_rayapi/index.php/tank_rayapi/iosmovga3thpayBegin?game_server_id="..base.curZoneID.."&game_user_id="..playerVoApi:getUid() .. "&game_user_name="..playerVoApi:getPlayerName() .. "&mobile=1&country="..string.upper(self.countryName) .. "&currency="..self.moneyName.."&amount="..mPrice.."&game_coin_amout="..goldNum.."&product_id="..productID.."&platform_user_id="..platID.."&game_orderid="..orderID
        else
            productID = "tk_gold_"..tostring(self.rechargeIndex + 10)
            url = "http://tank-ger-web01.raysns.com/tank_rayapi/index.php/tank_rayapi/androidmovga3thpayBegin?game_server_id="..base.curZoneID.."&game_user_id="..playerVoApi:getUid() .. "&game_user_name="..playerVoApi:getPlayerName() .. "&mobile=1&country="..string.upper(self.countryName) .. "&currency="..self.moneyName.."&amount="..mPrice.."&game_coin_amout="..goldNum.."&product_id="..productID.."&platform_user_id="..platID.."&game_orderid="..orderID
        end
        tmpTb["parms"]["url"] = url
        local cjson = G_Json.encode(tmpTb)
        G_accessCPlusFunction(cjson)
    end
end

function vipThirdPayDialog:getCountry()
    local tmpTb = {}
    tmpTb["action"] = "customAction"
    tmpTb["parms"] = {}
    tmpTb["parms"]["value"] = "getLocal"
    local cjson = G_Json.encode(tmpTb)
    local country = G_accessCPlusFunction(cjson)
    if(country == "" or country == nil)then
        country = G_country
    end
    return country
end

--德国新增Paypal支付
function vipThirdPayDialog:paypal()
    local url
    if(G_curPlatName() == "0")then
        url = "https://test.playeclub.com/api/payPal/index" --测试地址
    elseif G_curPlatName() == "androidsevenga" or G_curPlatName() == "11" then
        url = "https://api.playeclub.com/api/payPal/index" --正式地址
        -- if tonumber(base.curZoneID) == 1000 then
        --     url = "https://test.playeclub.com/api/payPal/index" --测试地址
        -- end
    end
    
    -- POST传参，包含以下：
    -- app_id          接入Movga SDK时配置文件中的app_id， 超级舰队传10008
    -- channel_id      接入MovgaSDK时配置文件中的channel_id，android是1，iOS是2
    -- server_id       分服id
    -- user_id         玩家在该分服的角色id
    -- country 用户所属国家，两位标准国际代码
    -- product_id  产品id，欧洲版：第三方档位tk_gold_11~tk_gold_18
    -- platform_user_id    即Movga平台的user_id
    -- game_extra  透传字段
    local productID = "tk_gold_" .. tostring(self.rechargeIndex + 10)
    local channel_id = 1
    if G_isIOS() == true then
        channel_id = 2
        productID = "tksvg_gold_"..tostring(self.rechargeIndex + 10)
    end
    local params = "app_id=10008&channel_id="..channel_id
    local platID = G_getUserPlatID()
    local index = string.find(platID, "_")
    if(index)then
        platID = string.sub(platID, index + 1)
    end
    local game_extra = playerVoApi:getUid() .. "_"..base.curZoneID.."_"..channel_id.."_"..playerVoApi:getPlayerLevel() .. "_"..playerVoApi:getVipLevel() .. "_"..base.serverTime
    params = params.."&server_id="..base.curZoneID.."&user_id="..playerVoApi:getUid() .. "&country="..string.upper(self:getCountry()) .. "&product_id="..productID.."&platform_user_id="..platID.."&game_extra="..game_extra
    -- url = url .. params
    -- print("url,params=====>>", url, params)
    local function requestHandler(data)
        if data and data ~= "" then
            local rd = G_Json.decode(data)
            if rd and rd.status == 0 then
                G_dayin(rd)
                local payWebUrl = rd.data
                local rtb = {}
                rtb["action"] = "openUrl"
                rtb["parms"] = {url = payWebUrl}
                local cjson = G_Json.encode(rtb)
                G_accessCPlusFunction(cjson)
            end
        end
        base:cancleWait()    
    end
    G_sendHttpAsynRequest(url, params, requestHandler, 2)
    base:setWait()
end
