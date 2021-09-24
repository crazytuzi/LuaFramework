tankSkinVoApi = {
    tankGroupTb = nil, --拥有皮肤的坦克组
    skinList = nil, --当前投放的皮肤列表（应该是当前自身拥有的）
    usedList = nil, --当前正在使用的皮肤列表
    shopList = nil, --商店数据
    warTankSkinList = nil, --各个大战坦克皮肤数据，key是大战的类型
    tempSkinList = nil, --大战坦克皮肤的临时数据
    tickets = nil, --从道具表中筛选出的所有坦克涂装折扣券列表
}

function tankSkinVoApi:clear()
    self.tankGroupTb = nil
    self.skinList = nil
    self.usedList = nil
    self.warTankSkinList = nil
    self.tempSkinList = nil
    self.tickets = nil
end

function tankSkinVoApi:formatData(data)
    if data.info then
        self.skinList = {}
        for k, v in pairs(data.info) do
            local vo = tankSkinVo:new()
            vo:initSkin(k, v)
            self.skinList[k] = vo
        end
    end
    if data.used then --used里只存放普通坦克使用的皮肤，精英和普通的使用同一套皮肤，则需要自己转换一下
        self.usedList = data.used
    end
    if data.shop then --商店购买数据
        self.shopList = data.shop
    end
end

function tankSkinVoApi:getCurSkinListNum()--返回当前拥有的皮肤数量
    if self.skinList then
        return SizeOfTable(self.skinList)
    end
    return 0
end

function tankSkinVoApi:formatTankGroup()
    if self.tankGroupTb then
        do return end
    end
    self.tankGroupTb = {[1] = {}, [2] = {}, [4] = {}, [8] = {}}
    for k, v in pairs(tankSkinCfg.tankList) do
        local tankId = tonumber(RemoveFirstChar(k))
        local tankType = tonumber(tankCfg[tankId].type)
        table.insert(self.tankGroupTb[tankType], tankId)
    end
    --坦克等级越高，坦克id越大的排在前面
    local function sortTank(t1, t2)
        local tw1 = tankCfg[t1].tankLevel * 100000 + tonumber(t1)
        local tw2 = tankCfg[t2].tankLevel * 100000 + tonumber(t2)
        if tw1 > tw2 then
            return true
        end
        return false
    end
    for k, tankList in pairs(self.tankGroupTb) do
        table.sort(tankList, sortTank)
    end
end

function tankSkinVoApi:skinDataHandler(data, callback, cmd)
    if data == nil then
        do return end
    end
    local ret, sData = base:checkServerData(data)
    if ret == true then
        if sData.data and sData.data.tankskin then
            self:formatData(sData.data.tankskin)
        end
        if callback then
            callback()
        end
    end
end

--获取涂装数据
function tankSkinVoApi:tankSkinGet(callback)
    if base.tskinSwitch == 0 then
        if callback then
            callback()
        end
        do return end
    end
    local function handler(fn, data)
        self:skinDataHandler(data, callback)
    end
    socketHelper:tankSkinGet(handler)
end

--使用和卸载涂装
function tankSkinVoApi:useTankSkin(stype, skinId, callback)
    local function handler(fn, data)
        self:skinDataHandler(data, callback)
    end
    socketHelper:useTankSkin(stype, skinId, handler)
end

--升级涂装
function tankSkinVoApi:upgradeTankSkin(skinId, callback)
    local function handler(fn, data)
        self:skinDataHandler(data, callback)
    end
    socketHelper:upgradeTankSkin(skinId, handler)
end

function tankSkinVoApi:getTankGroup()
    if self.tankGroupTb == nil then
        self:formatTankGroup()
    end
    return self.tankGroupTb
end

function tankSkinVoApi:getSkinList()
    return self.skinList or {}
end

function tankSkinVoApi:getSkinById(skinId)
    local skinList = self:getSkinList()
    return skinList[skinId]
end

function tankSkinVoApi:getUsedList()
    return self.usedList or {}
end

--该皮肤是否在使用中
function tankSkinVoApi:isHasUsed(tankId, skinId)
    if tankId == nil or skinId == nil then
        do return false end
    end
    local usedList = self:getUsedList()
    local tid = tonumber(tankId) and "a"..tankId or tankId
    if usedList[tid] and usedList[tid] == skinId then
        local skinVo = self:getSkinById(skinId)
        if skinVo and skinVo.et and skinVo.et > 0 and base.serverTime >= skinVo.et then --该皮肤已经过期
            return false
        end
        return true
    end
    return false
end

--是否拥有该皮肤
function tankSkinVoApi:isSkinOwned(skinId)
    local skinList = self:getSkinList()
    if skinList and skinList[skinId] then
        local skinVo = skinList[skinId]
        if skinVo.et and skinVo.et > 0 and base.serverTime >= skinVo.et then --该皮肤已经过期
            return false
        end
        return true
    end
    return false
end

--判断一个皮肤是否已达到最高等级
function tankSkinVoApi:isSkinMaxLv(skinId)
    local skinList = self:getSkinList()
    local skin = skinList[skinId]
    local cfg = tankSkinCfg.skinCfg[skinId]
    if skin and cfg then
        if skin.lv >= cfg.lvMax then
            return true
        end
        return false
    end
    return true
end

--获取指定的坦克的皮肤列表
function tankSkinVoApi:getSkinListByTankId(tankId)
    local tid = tonumber(tankId) and "a"..tankId or tankId
    return tankSkinCfg.tankList[tid] or {}
end

function tankSkinVoApi:getSkinPic(skinId)
    return "tskin_"..skinId..".png"
end

function tankSkinVoApi:getSkinNameStr(skinId, onlyTankNameFlag)
    local cfg = tankSkinCfg.skinCfg[skinId]
    if cfg and cfg.tankId then
        local tid = tonumber(RemoveFirstChar(cfg.tankId))
        if tankCfg[tid] then
            if onlyTankNameFlag == true then
                return getlocal(tankCfg[tid].name)
            else
                return getlocal("tankSkin_nameStr", {getlocal(tankCfg[tid].name), getlocal("tankSkin_nametype"..cfg.skinType)})
            end
        end
    end
    return ""
end

function tankSkinVoApi:getTankSkinIconPic(skinId)
    return "tskin_iconpic_"..skinId..".png"
end

--皮肤配置成道具格式的话，取名称时需要判断是否投放该皮肤（商店使用）
function tankSkinVoApi:getSkinNameStrForPropShow(skinId)
    if self:isSkinOpen(skinId) == true then
        return self:getSkinNameStr(skinId)
    else
        return self:getSkinNameStr(skinId, true)
    end
end

--判断指定皮肤是否投放
function tankSkinVoApi:isSkinOpen(skinId)
    if tankSkinCfg.skinCfg[skinId] and tonumber(tankSkinCfg.skinCfg[skinId].isOpen) == 1 then
        return true
    end
    return false
end

--获取指定塔克的正在装扮的皮肤(精英坦克和普通坦克使用同一套皮肤)
function tankSkinVoApi:getEquipSkinByTankId(tankId)
    if base.tskinSwitch == 0 then
        do return nil end
    end
    local tid = self:convertTankId(tankId)
    local usedList = self:getUsedList()
    return usedList[tid]
end

function tankSkinVoApi:getUpgradeSkinCost(skinId)
    local propId = tankSkinCfg.upgradeCostItem
    local skinVo = self:getSkinById(skinId)
    local lv = skinVo and skinVo.lv or 1
    local upgradeCostTb = tankSkinCfg.skinCfg[skinId].upgradeCost
    local num = upgradeCostTb[lv] or upgradeCostTb[SizeOfTable(upgradeCostTb)]
    return propId, num
end

--判断指定坦克是否开放了皮肤功能
function tankSkinVoApi:isTankSkinOpen(tankId)
    if base.tskinSwitch == 0 then
        do return false end
    end
    local tid = self:convertTankId(tankId)
    if tankSkinCfg.tankList[tid] then
        return true
    end
    return false
end

--获取坦克所拥有皮肤的属性加成
function tankSkinVoApi:getAttributeByTankId(tankId)
    if base.tskinSwitch == 0 then
        do return {} end
    end
    local attributeTb = {}
    local tid = self:convertTankId(tankId)
    local skinTb = tankSkinCfg.tankList[tid]
    if skinTb then
        for k, skinId in pairs(skinTb) do
            if self:isSkinOwned(skinId) == true then
                local attriTb = self:getAttributeBySkinId(skinId)
                for attriKey, v in pairs(attriTb) do
                    attributeTb[attriKey] = (attributeTb[attriKey] or 0) + v
                end
            end
        end
    end
    return attributeTb
end

--获取皮肤的属性加成
function tankSkinVoApi:getAttributeBySkinId(skinId, lv)
    if base.tskinSwitch == 0 then
        do return {} end
    end
    local attriTb = {}
    local cfg = tankSkinCfg.skinCfg[skinId]
    local skinVo = self:getSkinById(skinId)
    local skinLv = 1
    if lv ~= nil then
        skinLv = lv
    elseif skinVo then
        skinLv = skinVo.lv
    end
    for k, v in pairs(cfg.attType) do
        if v == "antifirst" or v == "first" then
            attriTb[v] = tonumber(cfg.value[k][skinLv] or 0)
        else
            attriTb[v] = tonumber(cfg.value[k][skinLv] or 0) * 100
        end
    end
    if cfg.restrain and cfg.restrain > 0 then --克制关系
        attriTb["restrain"] = tonumber(cfg.restrainValue[skinLv] or 0) * 100
    end
    
    return attriTb
end

function tankSkinVoApi:getAttributeNameStr(key, value)
    if key == "restrain" then
        local nameTb = {[1] = "tanke", [2] = "jianjiche", [4] = "zixinghuopao", [8] = "huojianche"}
        local tankType = tonumber(value) --如果是克制关系的话，value代表克制的坦克类型
        -- return getlocal("help4_t2")..getlocal(nameTb[tonumber(tankType)])
        return getlocal("tankSkin_restrain_str", {getlocal(nameTb[tonumber(tankType)])})
    else
        local buff = buffEffectCfg[buffKeyMatchCodeCfg[key]]
        return getlocal(buff.name)
    end
end

function tankSkinVoApi:showTankSkinDialog(tankId, layerNum)
    if base.tskinSwitch == 0 then
        do return end
    end
    local function realShow()
        require "luascript/script/game/scene/tank/tankSkinDialog"
        local td = tankSkinDialog:new(tankId)
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), {}, nil, nil, getlocal("tankSkin_title"), true, layerNum)
        sceneGame:addChild(dialog, layerNum)
    end
    self:tankSkinGet(realShow)
end

--显示皮肤的属性总览
function tankSkinVoApi:showSkinAttributeOverview(skinId, layerNum)
    require "luascript/script/game/scene/tank/tankSkinSmallDialog"
    tankSkinSmallDialog:showSkinAttributeOverviewDialog(skinId, layerNum)
end

--检测哪些战斗类型需要同步坦克皮肤数据,不需要同步的战斗不需要保存部队的皮肤数据
--@7，8，9： 跨服个人战  10：跨服军团战
--@12：世界boss设置部队
--@13，14，15：世界争霸
--@17，18： 区域争夺战
--@21，22，23：全球纷争
--@24，25，26，27，28，29：群雄争霸
--@30：夕兽降临活动设置部队
--@31，32：新版军团战
--@33：异元战场
--@35，36：领土争夺战
--@38，39：军团锦标赛
function tankSkinVoApi:checkBattleType(btype)
    if btype == 7 or btype == 8 or btype == 9 or btype == 10 or btype == 13 or btype == 14 or btype == 15 or btype == 17 or btype == 18 or btype == 21 or btype == 22 or btype == 23 or btype == 24 or btype == 25 or btype == 26 or btype == 27 or btype == 28 or btype == 29 or btype == 31 or btype == 32 or btype == 39 then
        return true
    end
    return false
end

--设置各个大战坦克皮肤数据
--btype：战斗部队类型 31，32：军团战
function tankSkinVoApi:setTankSkinListByBattleType(btype, tskin)
    if self:checkBattleType(btype) == false then
        do return end
    end
    if self.warTankSkinList == nil then
        self.warTankSkinList = {}
    end
    self.warTankSkinList[tonumber(btype)] = tskin
end

--获取各个大战坦克皮肤数据
function tankSkinVoApi:getTankSkinListByBattleType(btype)
    if self.warTankSkinList and self.warTankSkinList[tonumber(btype)] then
        return self.warTankSkinList[tonumber(btype)]
    end
    return {}
end

function tankSkinVoApi:clearTankSkinListByBattleType(btype)
    if self.warTankSkinList and self.warTankSkinList[tonumber(btype)] then
        self.warTankSkinList[tonumber(btype)] = nil
    end
end

function tankSkinVoApi:setTempTankSkinList(btype, tskin, tankTb)
    if self.tempSkinList == nil then
        self.tempSkinList = {}
    end
    self.tempSkinList[tonumber(btype)] = tskin
    if tankTb and type(tankTb) == "table" then
        local skinList = self.tempSkinList[tonumber(btype)] or {}
        for k, v in pairs(tankTb) do
            if v[1] and v[2] then
                local tankId = self:convertTankId(v[1])
                if skinList[tankId] == nil then
                    local skinId = self:getEquipSkinByTankId(tankId)
                    if self.tempSkinList[tonumber(btype)] == nil then
                        self.tempSkinList[tonumber(btype)] = {}
                    end
                    self.tempSkinList[tonumber(btype)][tankId] = skinId
                end
            end
        end
    end
end

function tankSkinVoApi:getTempTankSkinList(btype)
    if self.tempSkinList and self.tempSkinList[tonumber(btype)] then
        return self.tempSkinList[tonumber(btype)]
    end
    return {}
end

function tankSkinVoApi:updateTempTankSkinToLatest(btype, tankId)
    if tankId == nil or btype == nil then
        do return end
    end
    if self.tempSkinList == nil then
        self.tempSkinList = {}
    end
    if self.tempSkinList[tonumber(btype)] == nil then
        self.tempSkinList[tonumber(btype)] = {}
    end
    local skinId = self:getTroopsSkinByTankId(tankId, btype)
    local tid = self:convertTankId(tankId)
    self.tempSkinList[tonumber(btype)][tid] = skinId
end

function tankSkinVoApi:clearTempTankSkinList(btype)
    if self.tempSkinList and self.tempSkinList[tonumber(btype)] then
        self.tempSkinList[tonumber(btype)] = nil
    end
end

function tankSkinVoApi:getTroopsSkinByTankId(tankId, btype)
    if tankId == nil then
        do return end
    end
    local skinId
    if btype == 35 or btype == 36 then --领土争夺战特殊处理
        skinId = ltzdzFightApi:getSkinIdByTankId(tankId)
    else
        skinId = self:getEquipSkinByTankId(tankId)
    end
    return skinId
end

function tankSkinVoApi:returnTankData(curTankId, curSkinId)
    require "luascript/script/game/scene/tank/tankShowData"
    local aId = "a"..curTankId
    local battleStr = tankShowData[aId]
    local report = G_Json.decode(battleStr)
    local isAttacker = true
    local data = {data = {report = report}, isAttacker = isAttacker, isReport = true}
    local skinTb = {{}, {}}
    local tTb = data.data.report.t
    for k, v in pairs(tTb[2]) do
        if v[1] and v[1] == aId then
            skinTb[1]["p"..k] = curSkinId
        end
    end
    for k, v in pairs(tTb[1]) do
        if v[1] and v[1] == aId then
            skinTb[2]["p"..k] = curSkinId
        end
    end
    data.data.report.d.sk = skinTb
    return data or nil
end

function tankSkinVoApi:getShopData()
    return self.shopList or {}
end

--获取商店数据
function tankSkinVoApi:getShopList()
    local shopList = {}
    local shopData = self:getShopData()
    --status：3可购买，2已购买完成，1暂未开放
    for k, v in pairs(tankSkinCfg.shopList) do
        local status = 3
        if v.isSell == 0 then
            status = 1
        else
            if v.bn > 0 and v.bn <= (shopData[k] or 0) then
                status = 2
            else
                status = 3
            end
        end
        table.insert(shopList, {id = k, status = status, num = (shopData[k] or 0), bn = v.bn, stype = v.type, price = v.price, reward = FormatItem(v.reward)[1], desc = v.desc})
    end
    function sort(s1, s2)
        if s1 and s2 then
            local cfg1, cfg2 = tankSkinCfg.shopList[s1.id], tankSkinCfg.shopList[s2.id]
            local w1 = s1.status * 10000 + cfg1.order
            local w2 = s2.status * 10000 + cfg2.order
            if w1 > w2 then
                return true
            end
        end
        return false
    end
    table.sort(shopList, sort)
    return shopList
end

function tankSkinVoApi:getSkinIconSp(skinId, callback)
    local tankId = tankSkinCfg.skinCfg[skinId].tankId
    return tankVoApi:getTankIconSp(tankId, skinId, callback)
end

--获取涂装克制的显示图标(图标取的飞机技能的克制关系的资源)
function tankSkinVoApi:getSkinRestrainIconSp(tankId, restrain)
    local rtype = restrain or self:getTankSkinRestrainType(tankId)
    local pic
    if rtype == 1 then
        pic = "plane_skill_icon_s10.png"
    elseif rtype == 2 then
        pic = "plane_skill_icon_s11.png"
    elseif rtype == 4 then
        pic = "plane_skill_icon_s12.png"
    elseif rtype == 8 then
        pic = "plane_skill_icon_s9.png"
    end
    if pic then
        local iconBg = CCSprite:createWithSpriteFrameName("Icon_BG.png")
        local icon = CCSprite:create("public/plane/icon/"..pic)
        icon:setScale((iconBg:getContentSize().width - 4) / icon:getContentSize().width)
        icon:setPosition(getCenterPoint(iconBg))
        iconBg:addChild(icon)
        return iconBg
    end
    return nil
end

--获取坦克涂装的克制类型（一种坦克只有一种克制关系，出现多种说明配置或者设计有问题）
function tankSkinVoApi:getTankSkinRestrainType(tankId)
    local tid = tonumber(tankId) and "a"..tankId or tankId
    if tankSkinCfg.tankList[tid] then
        for k, v in pairs(tankSkinCfg.tankList[tid]) do
            local cfg = tankSkinCfg.skinCfg[v]
            if cfg.restrain and cfg.restrain > 0 then
                return cfg.restrain
            end
        end
    end
    return 0
end

--判断涂装对应的坦克是否拥有
function tankSkinVoApi:isTankOwnedBySkinId(skinId)
    if tankSkinCfg.skinCfg[skinId] then
        local tankId = tonumber(RemoveFirstChar(tankSkinCfg.skinCfg[skinId].tankId))
        local num = tankVoApi:getTankCountByItemId(tankId)
        if num == 0 then
            num = tankVoApi:getTankCountByItemId(tankId + 40000) --如果没有普通坦克，那看对应精英坦克有没有
        end
        if num > 0 then
            return true, tankId
        end
        return false, tankId
    end
    return false, nil
end

--将精英坦克id转成普通坦克id，因为皮肤数据只存普通坦克id
function tankSkinVoApi:convertTankId(tankId)
    local tid = tonumber(tankId) and tonumber(tankId) or tonumber(RemoveFirstChar(tankId))
    local customTankId = "a"..G_pickedList(tid)
    return customTankId
end

--坦克涂装加外边框
function tankSkinVoApi:getTankSkinIconSp(skinId, callback)
    local function handler()
        if callback then
            callback()
        end
    end
    local iconBg = LuaCCSprite:createWithSpriteFrameName("tskin_bg1.png", handler)
    local iconSp = CCSprite:createWithSpriteFrameName(self:getTankSkinIconPic(skinId))
    iconSp:setPosition(getCenterPoint(iconBg))
    iconSp:setScale((iconBg:getContentSize().width - 16) / iconSp:getContentSize().width)
    iconBg:addChild(iconSp)
    return iconBg
end

--折扣券图标
function tankSkinVoApi:getSkinDiscountTicketIconSp(pid, callback)
    local discfg = propCfg[pid].tskinDiscount
    local skinId, discount = discfg[1], discfg[2]

    local icon = self:getTankSkinIconSp(skinId, callback)

    local discountSp = CCSprite:createWithSpriteFrameName("disticket.png")
    discountSp:setPosition(ccp(icon:getContentSize().width - discountSp:getContentSize().width / 2,icon:getContentSize().height - discountSp:getContentSize().height / 2 + 20))
    icon:addChild(discountSp)

    local saleRate = tonumber(string.format("%.2f",discount))
    -- 折扣券文字
    local saleLabel = GetTTFLabel((saleRate * 100).."%", 24, true)
    -- saleLabel:setAnchorPoint(ccp(0, 0.5))
    saleLabel:setPosition(ccp(44, discountSp:getContentSize().height - 42))
    discountSp:addChild(saleLabel)

    return icon
end

--获取折扣力度最大的道具
function tankSkinVoApi:getBestDiscountTicket(skinId)
    if skinId == nil then
        do return nil, nil end
    end
    if self.tickets == nil then
        self.tickets = {}
        for k,v in pairs(propCfg) do
            if v.tskinDiscount then
                if self.tickets[v.tskinDiscount[1]] == nil then
                    self.tickets[v.tskinDiscount[1]] = {}
                end
                table.insert(self.tickets[v.tskinDiscount[1]],k)
            end
        end
    end
    local discount, num, pid = 1, 0, nil
    local propList = self.tickets[skinId] or {}
    for k,v in pairs(propList) do
        num = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(v)))
        if num and num > 0 and propCfg[v].tskinDiscount[2] < discount then
            discount = propCfg[v].tskinDiscount[2]
            pid = v
        end
    end
    return pid, discount
end
