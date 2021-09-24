heroAdjutantVoApi = {
    adjutantTb = {}, --已激活的将领副官数据
    adjutantStoreTb = {}, --副官仓库数据
}

function heroAdjutantVoApi:clear()
    self.adjutantTb = {}
    self.adjutantStoreTb = {}
end

function heroAdjutantVoApi:getAdjutantCfg()
    local adjutantCfg = G_requireLua("config/gameconfig/adjutant")
    return adjutantCfg
end

function heroAdjutantVoApi:getOpenLv()
    local adjutantCfg = self:getAdjutantCfg()
    if adjutantCfg and adjutantCfg.openLv then
        return adjutantCfg.openLv
    end
    return 0
end

function heroAdjutantVoApi:isOpen()
    if base.adjSwitch == 1 and playerVoApi:getPlayerLevel() >= self:getOpenLv() then
        return true
    end
    return false
end

function heroAdjutantVoApi:initData(data)
    if data then
        if data.adjutant then
            self.adjutantTb = {}
            for k, v in pairs(data.adjutant) do
                self.adjutantTb[k] = {}
                for kk, vv in pairs(v) do
                    local adjId, adjLv
                    if type(vv[3]) == "table" then
                        for kkk, vvv in pairs(vv[3]) do
                            adjId = kkk
                            adjLv = vvv
                        end
                    end
                    self.adjutantTb[k][kk] = {--k:将领id，kk:副官槽位索引
                        vv[1], --激活状态
                        vv[2], --消耗经验
                        adjId, --装配的副官id
                        adjLv, --装配的副官等级
                    }
                end
            end
        end
        if data.alladj then
            self.adjutantStoreTb = {}
            for k, v in pairs(data.alladj) do
                table.insert(self.adjutantStoreTb, {
                    k, --副官id
                    v --副官数量
                })
            end
        end
    end
end

function heroAdjutantVoApi:getAdjutantCfgData(adjId)
    if adjId == nil then
        return
    end
    local adjutantCfg = self:getAdjutantCfg()
    local adjCfgData = adjutantCfg.adjutantList[adjId]
    return adjCfgData
end

--获取副官数据
--@ hid : 将领ID
function heroAdjutantVoApi:getAdjutant(hid)
    if self.adjutantTb then
        return self.adjutantTb[hid]
    end
end

--获取副官仓库数据
function heroAdjutantVoApi:getAdjutantStoreTb()
    if self.adjutantStoreTb then
        local function sortFunc(a, b)
            local acfg, bcfg = self:getAdjutantCfgData(a[1]), self:getAdjutantCfgData(b[1])
            local aw = acfg.order * 10000 + (100 - tonumber(RemoveFirstChar(a[1]))) * 100
            local bw = bcfg.order * 10000 + (100 - tonumber(RemoveFirstChar(b[1]))) * 100
            if aw < bw then
                return true
            end
            return false
        end
        table.sort(self.adjutantStoreTb, sortFunc)
        return self.adjutantStoreTb
    end
end

--获取可装配的副官数据
function heroAdjutantVoApi:getAdjutantCanEquipData(heroVo)
    local storeTb = self:getAdjutantStoreTb()
    if storeTb then
        local adjTb = {}
        for k, v in pairs(storeTb) do
            if self:isEquip(heroVo.hid, v[1]) == false then
                local adjCfgData = self:getAdjutantCfgData(v[1])
                if heroVo.productOrder >= adjCfgData.heroStarLv then
                    table.insert(adjTb, v)
                end
            end
        end
        local function sortFunc(a, b)
            local acfg, bcfg = self:getAdjutantCfgData(a[1]), self:getAdjutantCfgData(b[1])
            local aw = acfg.order * 10000 + (100 - tonumber(RemoveFirstChar(a[1]))) * 100
            local bw = bcfg.order * 10000 + (100 - tonumber(RemoveFirstChar(b[1]))) * 100
            if aw < bw then
                return true
            end
            return false
        end
        table.sort(adjTb, sortFunc)
        return adjTb
    end
end

--获取可更换的副官数据（更换备选区数据）
function heroAdjutantVoApi:getAdjutantCanChangeData(heroVo, adjLv)
    local storeTb = self:getAdjutantStoreTb()
    if storeTb then
        local adjTb = {}
        for k, v in pairs(storeTb) do
            if self:isEquip(heroVo.hid, v[1]) == false then
                local adjCfgData = self:getAdjutantCfgData(v[1])
                if heroVo.productOrder >= adjCfgData.heroStarLv and adjCfgData.lvMax >= adjLv then
                    table.insert(adjTb, v)
                end
            end
        end
        local function sortFunc(a, b)
            local acfg, bcfg = self:getAdjutantCfgData(a[1]), self:getAdjutantCfgData(b[1])
            local aw = acfg.order * 10000 + (100 - tonumber(RemoveFirstChar(a[1]))) * 100
            local bw = bcfg.order * 10000 + (100 - tonumber(RemoveFirstChar(b[1]))) * 100
            if aw < bw then
                return true
            end
            return false
        end
        table.sort(adjTb, sortFunc)
        return adjTb
    end
end

--获取激活副官槽位消耗的材料
function heroAdjutantVoApi:getActiveCostAdjutants()
    if self.adjutantStoreTb then
        local storeTb = G_clone(self.adjutantStoreTb)
        local function sortFunc(a, b)
            local acfg, bcfg = self:getAdjutantCfgData(a[1]), self:getAdjutantCfgData(b[1])
            local aw = acfg.order * 10000 + (100 - tonumber(RemoveFirstChar(a[1]))) * 100
            local bw = bcfg.order * 10000 + (100 - tonumber(RemoveFirstChar(b[1]))) * 100
            if aw > bw then
                return true
            end
            return false
        end
        table.sort(storeTb, sortFunc)
        return storeTb
    end
    return {}
end

--判断adjId的副官是否已经装配
function heroAdjutantVoApi:isEquip(hid, adjId)
    local adjData = self:getAdjutant(hid)
    if adjData then
        for k, v in pairs(adjData) do
            if adjId == v[3] then
                return true
            end
        end
    end
    return false
end

--判断将领副官的adjPoint槽位是否激活
function heroAdjutantVoApi:isActivate(hid, adjPoint)
    local adjData = self:getAdjutant(hid)
    if adjData and adjData[adjPoint] then
        return (adjData[adjPoint][1] == 1)
    end
    return false
end

--判断该将领是否可以装配副官
function heroAdjutantVoApi:isCanEquipAdjutant(heroVo)
    if heroVo then
        return (heroVo.productOrder >= 3)
    end
    return false
end

--激活副官接口
--@ hid:将领id， adjPoint:要激活的副官槽位索引， costProps:激活所消耗的道具[道具id=数量,...]
function heroAdjutantVoApi:requestActivate(callback, hid, adjPoint, costProps)
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                if sData.data.hero then
                    self:initData(sData.data.hero)
                end
                if callback then
                    callback()
                end
            end
        end
    end
    socketHelper:adjActivate(socketCallback, hid, adjPoint, costProps)
end

--装配或替换副官接口
--@ hid:将领id， adjPoint:要装备或替换的副官槽位索引， adjId:要装配或替换的副官id
function heroAdjutantVoApi:requestEquip(callback, hid, adjPoint, adjId)
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                if sData.data.hero then
                    self:initData(sData.data.hero)
                end
                if callback then
                    callback()
                end
            end
        end
    end
    socketHelper:adjEquip(socketCallback, hid, adjPoint, adjId)
end

--升级副官接口
--@ hid:将领id， adjPoint:要升级的副官槽位索引
function heroAdjutantVoApi:requestUpgrade(callback, hid, adjPoint)
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                if sData.data.hero then
                    self:initData(sData.data.hero)
                end
                if callback then
                    callback()
                end
            end
        end
    end
    socketHelper:adjUpgrade(socketCallback, hid, adjPoint)
end

--显示副官操作界面
function heroAdjutantVoApi:showAdjutantInfoDialog(layerNum, heroVo, parent)
    require "luascript/script/game/scene/gamedialog/heroDialog/heroAdjutantInfoDialog"
    local td = heroAdjutantInfoDialog:new(layerNum, heroVo, parent)
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), {}, nil, nil, getlocal("heroAdjutant_title"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end

--显示副官仓库界面
function heroAdjutantVoApi:showAdjutantStoreDialog(layerNum, showType, heroVo, adjPoint)
    require "luascript/script/game/scene/gamedialog/heroDialog/heroAdjutantStoreDialog"
    local td = heroAdjutantStoreDialog:new(layerNum, showType, heroVo, adjPoint)
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), {}, nil, nil, getlocal("accessory_title_3"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end

--显示副官更换界面
function heroAdjutantVoApi:showAdjutantChangeDialog(layerNum, heroVo, adjPoint)
    require "luascript/script/game/scene/gamedialog/heroDialog/heroAdjutantChangeDialog"
    local td = heroAdjutantChangeDialog:new(layerNum, heroVo, adjPoint)
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), {}, nil, nil, getlocal("armorMatrix_change"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end

--显示副官详情(小弹板)
function heroAdjutantVoApi:showInfoSmallDialog(layerNum, params)
    require "luascript/script/game/scene/gamedialog/heroDialog/heroAdjutantSmallDialog"
    heroAdjutantSmallDialog:showInfoDialog(layerNum, getlocal("heroAdjutant_detailsText"), params)
end

--显示副官激活(小弹板)
function heroAdjutantVoApi:showActivateSmallDialog(layerNum, params)
    require "luascript/script/game/scene/gamedialog/heroDialog/heroAdjutantSmallDialog"
    heroAdjutantSmallDialog:showActivateDialog(layerNum, getlocal("activation"), params)
end

--显示副官激活的批量操作(小弹板)
function heroAdjutantVoApi:showBatchActivateSmallDialog(layerNum, params)
    require "luascript/script/game/scene/gamedialog/heroDialog/heroAdjutantSmallDialog"
    heroAdjutantSmallDialog:showBatchActivateDialog(layerNum, getlocal("heroAdjutant_batchOperation"), params)
end

--显示副官升级(小弹板)
function heroAdjutantVoApi:showUpgradeSmallDialog(layerNum, params)
    require "luascript/script/game/scene/gamedialog/heroDialog/heroAdjutantSmallDialog"
    heroAdjutantSmallDialog:showUpgradeDialog(layerNum, getlocal("upgradeBuild"), params)
end

--显示副官额外属性(小弹板)
function heroAdjutantVoApi:showExtraPropertySmallDialog(layerNum, params)
    require "luascript/script/game/scene/gamedialog/heroDialog/heroAdjutantSmallDialog"
    heroAdjutantSmallDialog:showExtraPropertyDialog(layerNum, getlocal("heroAdjutant_extraEffect"), params)
end

function heroAdjutantVoApi:getAdjutantIcon(adjId, isActivate, bigBgFlag, callback, isShowLens, adjPoint)
    local iconBgImage, iconBigBgImage = "adj_iconBg_lock.png", "adj_bigBg_lock.png"
    local adjName, iconImage, quality, stateSp, levelBgImage
    if adjId then
        local adjCfgData = self:getAdjutantCfgData(adjId)
        adjName = adjCfgData.name
        iconImage = adjCfgData.icon
        quality = adjCfgData.quality
        if quality == 2 then
            iconBgImage = "adj_iconBg_green.png"
            iconBigBgImage = "adj_bigBg_green.png"
            levelBgImage = "adj_levelBg_green.png"
        elseif quality == 3 then
            iconBgImage = "adj_iconBg_blue.png"
            iconBigBgImage = "adj_bigBg_blue.png"
            levelBgImage = "adj_levelBg_blue.png"
        elseif quality == 4 then
            iconBgImage = "adj_iconBg_purple.png"
            iconBigBgImage = "adj_bigBg_purple.png"
            levelBgImage = "adj_levelBg_purple.png"
        elseif quality == 5 then
            iconBgImage = "adj_iconBg_orange.png"
            iconBigBgImage = "adj_bigBg_orange.png"
            levelBgImage = "adj_levelBg_orange.png"
        end
    else
        if isActivate == true then
            stateSp = CCSprite:createWithSpriteFrameName("adj_plus.png")
            stateSp:setColor(ccc3(246, 173, 46))
        else
            stateSp = CCSprite:createWithSpriteFrameName("aitroops_lock.png")
        end
        stateSp:setTag(502)
    end
    
    local iconBg = LuaCCSprite:createWithSpriteFrameName(iconBgImage, function(...) if callback then callback(...) end end)
    if iconImage then
        local icon = CCSprite:createWithSpriteFrameName(iconImage)
        icon:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2)
        iconBg:addChild(icon)
        if isShowLens == true then
            local lensSp = CCSprite:createWithSpriteFrameName("datebaseShow2.png")
            lensSp:setScale(1.5)
            lensSp:setAnchorPoint(ccp(1, 0))
            lensSp:setPosition(iconBg:getContentSize().width - 10, 10)
            iconBg:addChild(lensSp)
        end
    end
    if adjPoint then
        local cornerMark = CCSprite:createWithSpriteFrameName("adj_icon_cornerMark.png")
        cornerMark:setAnchorPoint(ccp(0, 1))
        cornerMark:setPosition(0, iconBg:getContentSize().height)
        cornerMark:setColor(self:getAdjutantQualityColor(quality))
        iconBg:addChild(cornerMark)
        local pointLb = GetTTFLabel(tostring(adjPoint), 30, true)
        pointLb:setAnchorPoint(ccp(0, 1))
        pointLb:setPosition(20, cornerMark:getContentSize().height - 15)
        pointLb:setColor(G_ColorBlack)
        pointLb:setOpacity(160)
        cornerMark:addChild(pointLb)
    end

    if bigBgFlag == true then
        local iconBigBg = LuaCCSprite:createWithSpriteFrameName(iconBigBgImage, function(...) if callback then callback(...) end end)
        iconBg:setAnchorPoint(ccp(0.5, 1))
        iconBg:setPosition(iconBigBg:getContentSize().width / 2, iconBigBg:getContentSize().height - 20)
        iconBigBg:addChild(iconBg)
        if stateSp then
            stateSp:setPosition(iconBg:getPositionX(), iconBg:getPositionY() - iconBg:getContentSize().height / 2)
            iconBigBg:addChild(stateSp)
        end
        if adjName then
            local nameLb = GetTTFLabel(getlocal(adjName), 30, true)
            nameLb:setPosition(iconBigBg:getContentSize().width / 2, 75)
            iconBigBg:addChild(nameLb)
        end
        if levelBgImage then
            local levelBg = CCSprite:createWithSpriteFrameName(levelBgImage)
            levelBg:setAnchorPoint(ccp(1, 0))
            levelBg:setPosition(iconBigBg:getContentSize().width + 10, 10)
            iconBigBg:addChild(levelBg)
            levelBg:setTag(501)
        end
        return iconBigBg
    else
        if stateSp then
            stateSp:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2)
            iconBg:addChild(stateSp)
        end
    end

    return iconBg
end

function heroAdjutantVoApi:setAdjLevel(adjIcon, adjId, adjCurLv)
    if tolua.cast(adjIcon, "CCSprite") then
        local levelBg = tolua.cast(adjIcon:getChildByTag(501), "CCSprite")
        if adjCurLv and levelBg then
            local adjCfgData = self:getAdjutantCfgData(adjId)
            local levelLb = GetTTFLabel(getlocal("fightLevel", {adjCurLv}) .. "/" .. getlocal("fightLevel", {adjCfgData.lvMax}), 30, true)
            levelLb:setAnchorPoint(ccp(1, 0.5))
            levelLb:setPosition(levelBg:getContentSize().width - 25, levelBg:getContentSize().height / 2)
            levelBg:addChild(levelLb)
        end
    end
end

function heroAdjutantVoApi:getAdjutantQualityColor(quality)
    if quality == 2 then --绿
        return ccc3(178, 255, 191)
    elseif quality == 3 then --蓝
        return ccc3(178, 237, 255)
    elseif quality == 4 then --紫
        return ccc3(211, 161, 251)
    elseif quality == 5 then --橙
        return ccc3(237, 162, 65)
    end
    return ccc3(218, 217, 214) --灰
end

function heroAdjutantVoApi:getAdjutantName(adjId)
    if adjId == nil then
        return
    end
    local adjutantCfg = self:getAdjutantCfg()
    local adjCfgData = adjutantCfg.adjutantList[adjId]
    return adjCfgData.name
end

function heroAdjutantVoApi:getAdjutantImage(adjId)
    if adjId == nil then
        return
    end
    local adjutantCfg = self:getAdjutantCfg()
    local adjCfgData = adjutantCfg.adjutantList[adjId]
    return adjCfgData.icon
end

function heroAdjutantVoApi:getAdjutantDesc(adjId, adjLv)
    if adjId == nil then
        return
    end
    local adjutantCfg = self:getAdjutantCfg()
    local adjCfgData = adjutantCfg.adjutantList[adjId]
    return getlocal(adjCfgData.desc, {self:getAdjutantProperty(adjId, adjLv) .. "%"})
end

function heroAdjutantVoApi:getAdjutantProperty(adjId, adjLv)
    if adjId == nil then
        return
    end
    local adjutantCfg = self:getAdjutantCfg()
    local adjCfgData = adjutantCfg.adjutantList[adjId]
    if adjCfgData.attValuePerLv[adjLv or 1] == nil then
        return "0%"
    end
    return (adjCfgData.attValuePerLv[adjLv or 1] .. "%")
end

--获取副官属性显示的文字颜色
function heroAdjutantVoApi:getAdjutantDescColor(adjId, colorType)
    if adjId == nil then
        return {}
    end
    local adjutantCfg = self:getAdjutantCfg()
    local cfg = adjutantCfg.adjutantList[adjId]
    
    local colorTb = {}
    local propertyColor = G_ColorWhite --属性显示的主颜色
    if colorType == 1 then
        propertyColor = G_ColorGreen
    elseif colorType == 2 then
        propertyColor = G_ColorRed
    end
    local id = tonumber(RemoveFirstChar(adjId))
    local wzArr = Split(getlocal(cfg.desc, {}), "<rayimg>")
    local num = #wzArr
    for k = 1, num do
        if k % 2 == 0 then
            table.insert(colorTb, propertyColor)
        else
            table.insert(colorTb, G_ColorWhite)
        end
    end
    
    return colorTb
end

--获取副官的数量
function heroAdjutantVoApi:getAdjutantNum(adjId)
    if self.adjutantStoreTb then
        for k, v in pairs(self.adjutantStoreTb) do
            if v[1] == adjId then
                return v[2]
            end
        end
    end
    return 0
end

--获取副官升级消耗的物品 flag:是否越级
function heroAdjutantVoApi:getAdjutantUpgradeItem(adjId, adjLv, flag)
    if adjId == nil then
        return
    end
    local adjutantCfg = self:getAdjutantCfg()
    local adjCfgData = adjutantCfg.adjutantList[adjId]
    local itemTb
    if flag == true then
        itemTb = {}
        for i = 1, adjLv do
            local upgradeNeed = adjCfgData.upgradeNeed[i]
            if upgradeNeed then
                for k, v in pairs(upgradeNeed) do
                    if itemTb[k] == nil then
                        itemTb[k] = {}
                    end
                    for m, n in pairs(v) do
                        itemTb[k][m] = (itemTb[k][m] or 0) + n
                    end
                end
            end
        end
    else
        itemTb = adjCfgData.upgradeNeed[adjLv + 1]
    end
    if itemTb then
        return FormatItem(itemTb)
    end
end

--获取副官兑换消耗的物品 flag:是否越级
function heroAdjutantVoApi:getAdjutantExchangeItem(adjId, adjLv, flag)
    if adjId == nil then
        return
    end
    local adjutantCfg = self:getAdjutantCfg()
    local adjCfgData = adjutantCfg.adjutantList[adjId]
    local itemTb
    if flag == true then
        itemTb = {}
        for i = 1, adjLv do
            local exchangeNeed = adjCfgData.exchangeNeed[i]
            if exchangeNeed then
                for k, v in pairs(exchangeNeed) do
                    if itemTb[k] == nil then
                        itemTb[k] = {}
                    end
                    for m, n in pairs(v) do
                        itemTb[k][m] = (itemTb[k][m] or 0) + n
                    end
                end
            end
        end
    else
        itemTb = adjCfgData.exchangeNeed[adjLv + 1]
    end
    local costCfg = adjutantCfg.exchangeCost
    local gemsCost = costCfg[adjCfgData.quality - 1] or 0
    if itemTb then
        return FormatItem(itemTb), gemsCost
    end
end

--获取将领副官升级到当前等级所需的副官数量
function heroAdjutantVoApi:getAdjutantTotalNum(adjId, adjLv)
    if adjId ==nil then
        return
    end
    local adjutantCfg = self:getAdjutantCfg()
    local adjCfgData = adjutantCfg.adjutantList[adjId]
    local num = 0
    for i=1,adjLv  do
        local upgradeNeed = adjCfgData.upgradeNeed[i]
        local upgradeNeedTb = FormatItem(upgradeNeed)
        for k,v in pairs(upgradeNeedTb) do
            if v.type == "aj" and v.eType == "j" then
                num = num+v.num
            end
        end
    end
    return num
end

--获取返还原将领副官的比率（{品质,等级,比例}--A替换B，A的品质满足{品质}，B的等级≥{等级}，则返还B的比例={比例}）
function heroAdjutantVoApi:returnAdjutantRate( ... )
    local adjutantCfg = self:getAdjutantCfg()
    local adjCfgData = adjutantCfg.exchangeRule
    return adjCfgData[1],adjCfgData[2],adjCfgData[3]
end


--获取将领副官的总等级
function heroAdjutantVoApi:getAdjutantTotalLevel(hid)
    local adjTotalLv = 0
    local adjData = self:getAdjutant(hid)
    if adjData then
        for k, v in pairs(adjData) do
            local adjCurLv = v[4] or 0
            adjTotalLv = adjTotalLv + adjCurLv
        end
    end
    return adjTotalLv
end

function heroAdjutantVoApi:getPropertyCfg(propName, value)
    local propertyCfg = {
        atk = {icon = "attributeARP.png", name = getlocal("dmg") .. (value and ("+" .. value .. "%") or ""), sort = 1}, --增加伤害
        hlp = {icon = "attributeArmor.png", name = getlocal("hlp") .. (value and ("+" .. value .. "%") or ""), sort = 1}, --减少伤害
        hit = {icon = "skill_01.png", name = getlocal("sample_skill_name_101") .. (value and ("+" .. value .. "%") or ""), sort = 1}, --命中
        eva = {icon = "skill_02.png", name = getlocal("sample_skill_name_102") .. (value and ("+" .. value .. "%") or ""), sort = 1}, --闪避
        cri = {icon = "skill_03.png", name = getlocal("sample_skill_name_103") .. (value and ("+" .. value .. "%") or ""), sort = 1}, --暴击
        res = {icon = "skill_04.png", name = getlocal("sample_skill_name_104") .. (value and ("+" .. value .. "%") or ""), sort = 1}, --抗暴
        first = {icon = "positiveHead.png", name = getlocal("firstValue") .. (value and ("+" .. value) or ""), sort = 100}, --先手值
        exploit = {name = getlocal("heroAdjutant_extraProperty1", {value}), sort = 101}, --将领功勋技能等级上限提升
        skill = {name = getlocal("heroAdjutant_extraProperty2", {value}), sort = 102}, --将领常规技能等级上限提升
    }
    return propertyCfg[propName]
end

--获取副官额外属性
--propType 1=增加属性值，2=将领功勋技能等级上限提升5级，3=将领常规技能等级上限提升5级
function heroAdjutantVoApi:getExtraProperty(hid, propType)
    local adjTotalLv = self:getAdjutantTotalLevel(hid)
    local adjCfg = self:getAdjutantCfg()
    local tempTb = {}
    for k, v in pairs(adjCfg.chainEffectList) do
        if adjTotalLv >= v.totalLv then
            if v.type == 1 and v.type == (propType or 1) then
                for m, n in pairs(v.value) do
                    tempTb[m] = (tempTb[m] or 0) + n
                end
            elseif v.type == 2 and v.type == (propType or 2) then
                tempTb["exploit"] = (tempTb["exploit"] or 0) + v.value
            elseif v.type == 3 and v.type == (propType or 3) then
                tempTb["skill"] = (tempTb["skill"] or 0) + v.value
            end
        end
    end
    local propTb = {}
    for key, value in pairs(tempTb) do
        table.insert(propTb, {key = key, value = value, sort = self:getPropertyCfg(key).sort})
    end
    table.sort(propTb, function(a, b) return a.sort < b.sort end)
    return propTb, tempTb
end

--发送升级公告
function heroAdjutantVoApi:sendUpgradeMessage(hid, adjPoint)
    local function sendOnceUpgradeMsg(adjData)
        -- if adjData[adjPoint] then
        --     local adjId, adjCurLv = adjData[adjPoint][3], adjData[adjPoint][4] or 1
        --     if (adjId and adjCurLv == self:getAdjutantCfgData(adjId).lvMax) then
        --         local params = {
        --             playerVoApi:getPlayerName(),
        --             getlocal(heroListCfg[hid].heroName),
        --             getlocal(self:getAdjutantName(adjId)),
        --         }
        --         chatVoApi:sendSystemMessage(getlocal("heroAdjutant_upgradeSysMsg1", params))
        --     end
        -- end
    end
    local adjData = self:getAdjutant(hid)
    if adjData then
        if SizeOfTable(adjData) < 4 then
            sendOnceUpgradeMsg(adjData)
        else
            local isSend = true
            for k, v in pairs(adjData) do
                local adjId, adjCurLv = v[3], v[4] or 1
                if not (adjId and adjCurLv == self:getAdjutantCfgData(adjId).lvMax) then
                    isSend = false
                    break
                end
            end
            if isSend == true then
                -- local params = {
                --     playerVoApi:getPlayerName(),
                --     getlocal(heroListCfg[hid].heroName),
                -- }
                -- chatVoApi:sendSystemMessage(getlocal("heroAdjutant_upgradeSysMsg2", params))
            else
                sendOnceUpgradeMsg(adjData)
            end
        end
    end
end

--解析获取将领副官的数据
--heroStr将领的数据串格式为 "h21-1-6-1,j3,3,2,j2,2,3,j9,1,4,j10,1"
function heroAdjutantVoApi:decodeAdjutant(heroStr)
    local adjutantTb = {}
    local heroArr = Split(heroStr, "-")
    if heroArr and #heroArr >= 4 then
        local adjutantStr = heroArr[4]
        local adjutantArr = Split(adjutantStr, ",")
        local adjutantCount = math.floor(#adjutantArr / 3)
        for k = 1, adjutantCount do
            local ajtIdx = tonumber(adjutantArr[(k - 1) * 3 + 1]) --副官位置
            local heroAjt = {}
            for j = 2, 3 do
                --heroAjt[1]：副官id，heroAjt[2]：副官等级
                heroAjt[j - 1] = j ~= 2 and tonumber(adjutantArr[(k - 1) * 3 + j]) or tostring(adjutantArr[(k - 1) * 3 + j])
            end
            adjutantTb[ajtIdx] = heroAjt
        end
    end
    return adjutantTb
end

function heroAdjutantVoApi:encodeAdjutant(hid)
    local ajtStr
    local adjutantTb = self:getAdjutant(hid) or {}
    for k, v in pairs(adjutantTb) do
        if v and v[3] and v[4] then
            local str = k..","..v[3] .. ","..v[4]
            ajtStr = ajtStr == nil and str or ajtStr..","..str
        end
    end
    return ajtStr
end

function heroAdjutantVoApi:getAdjutantMaxTotalValue(heroVo)
    if not self:isCanEquipAdjutant(heroVo) then
        return 0, 0
    end
    local adjutantCfg = self:getAdjutantCfg()
    local canQuipNum = 0
    for k, v in pairs(adjutantCfg.needHeroStar) do
        if heroVo.productOrder >= v then
            canQuipNum = canQuipNum + 1
        end
    end
    local tempTb = {}
    for k, v in pairs(adjutantCfg.adjutantList) do
        if heroVo.productOrder >= v.heroStarLv then
            table.insert(tempTb, v)
        end
    end
    table.sort(tempTb, function(a, b) return a.quality > b.quality end)
    local maxLevel, maxQuality, canEquipMaxQuality = 0, 0, 0
    for i = 1, canQuipNum do
        if tempTb[i] then
            maxLevel = maxLevel + tempTb[i].lvMax
            maxQuality = maxQuality + tempTb[i].quality
            if canEquipMaxQuality < tempTb[i].quality then
                canEquipMaxQuality = tempTb[i].quality
            end
        end
    end
    return maxLevel, maxQuality, canEquipMaxQuality
end
