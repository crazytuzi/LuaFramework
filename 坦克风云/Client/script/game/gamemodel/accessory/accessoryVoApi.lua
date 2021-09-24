accessoryVoApi =
{
    fbag = nil, --碎片背包,格式{fVo,fVo,fVo}
    abag = nil, --配件背包,格式{aVo,aVo,aVo}
    equip = nil, --坦克的装备配件信息,格式{t1={p1=aVo,p2=aVo,p3=aVo},t2={},t3={},t4={}}
    props = {}, --所有道具的数目
    shopProps = {p8 = 0, p9 = 0, p10 = 0}, --用户商店兑换的道具
    unusedNum = 0, --可穿但是未穿的配件数目
    unUsedAccessory = nil, --可穿但是未穿的配件table
    unusedNeedRefresh = false, --已有却没穿的配件信息需要刷新
    dataNeedRefresh = true, --数据发生错误或者未初始化,需要彻底刷新
    
    ecVo = nil, --关卡vo
    flag = -1, --是否请求数据标示
    abagLeftNum = 0,
    fbagLeftNum = 0,
    ecNum = 0,
    isInitEC = nil,
    guideStep = nil,
    succinct_level = 1,
    succinct_exp = 0,
    succ_at = 0,
    supply_lineFlag = false,
    dilatationNum = nil, --背包扩容次数,格式{配件背包次数,碎片背包次数}
}

function accessoryVoApi:getSuccinct_level()
    return self.succinct_level
end
function accessoryVoApi:getSuccinct_exp()
    return self.succinct_exp
end

function accessoryVoApi:setSuccinct_level(level)
    self.succinct_level = level
end
function accessoryVoApi:setSuccinct_exp(exp)
    self.succinct_exp = exp
end

function accessoryVoApi:setSucc_at(succ_at)
    self.succ_at = succ_at
end

function accessoryVoApi:getSucc_at()
    return self.succ_at
end

function accessoryVoApi:setSupply_lineFlag(flag)
    self.supply_lineFlag = flag
end

function accessoryVoApi:getSupply_lineFlag()
    return self.supply_lineFlag
end

function accessoryVoApi:checkFree()
    local free
    if G_isToday(self.succ_at) == false then
        free = true
    else
        free = false
    end
    if free == true and self.succinct_level >= succinctCfg.privilege_2 and playerVoApi:getPlayerLevel() >= 50 then
        return true
    end
    return false
end

function accessoryVoApi:updateSuccinctData(data)
    if data.m_exp then
        self.succinct_exp = data.m_exp
    end
    if data.m_level then
        self.succinct_level = data.m_level
    end
    
    for tid, tank in pairs(data.used) do
        for part, acc in pairs(tank) do
            self.equip[tid][part].succinct = acc[4]
        end
    end
    eventDispatcher:dispatchEvent("accessory.data.refresh", {type = {4}})
end

function accessoryVoApi:clear()
    if self.fbag then
        for k, v in pairs(self.fbag) do
            self.fbag[k] = nil
        end
    end
    self.fbag = nil
    if self.abag then
        for k, v in pairs(self.abag) do
            self.abag[k] = nil
        end
    end
    self.abag = nil
    if self.equip then
        for k, v in pairs(self.equip) do
            self.equip[k] = nil
        end
    end
    self.equip = nil
    
    self.props = {}
    self.unusedNum = 0
    self.unusedNeedRefresh = false
    self.dataNeedRefresh = true
    
    self.ecVo = nil
    self.flag = -1
    self.abagLeftNum = 0
    self.fbagLeftNum = 0
    self.ecNum = 0
    self.isInitEC = nil
    self.guideStep = nil
    self.dilatationNum = nil
end

function accessoryVoApi:updateAccData(data, callback)
    if data and data.data and data.data.accessory then
        self:onRefreshData(data.data.accessory)
        if(callback ~= nil)then
            callback()
        end
        if data.data.accessory.m_exp then
            self.succinct_exp = data.data.accessory.m_exp
        end
        if data.data.accessory.m_level then
            self.succinct_level = data.data.accessory.m_level
        end
    end
end

--从后台获取所有配件的信息
function accessoryVoApi:refreshData(callback)
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            self:updateAccData(sData, callback)
            -- if sData and sData.data and sData.data.accessory then
            -- self:onRefreshData(sData.data.accessory)
            -- if(callback~=nil)then
            -- callback()
            -- end
            -- if sData.data.accessory.m_exp then
            -- self.succinct_exp=sData.data.accessory.m_exp
            -- end
            -- if sData.data.accessory.m_level then
            -- self.succinct_level=sData.data.accessory.m_level
            -- end
            -- end
        end
    end
    socketHelper:getAllAccesory(onRequestEnd)
end

--只刷新装备的数据(战力引导页面使用)
function accessoryVoApi:refreshEquipData(data)
    if data then
        self.equip = {t1 = {}, t2 = {}, t3 = {}, t4 = {}}
        for tid, tank in pairs(data) do
            for part, acc in pairs(tank) do
                local aVo = accessoryVo:new()
                aVo:initWithData(acc)
                self.equip[tid][part] = aVo
            end
        end
    end
end

function accessoryVoApi:updateDilatationNum(data)
    if data and data.accessory and data.accessory.enum then
        self.dilatationNum = data.accessory.enum
    end
end

function accessoryVoApi:onRefreshData(data)
    self.dataNeedRefresh = false
    self.fbag = {}
    self.abag = {}
    self.equip = {t1 = {}, t2 = {}, t3 = {}, t4 = {}}
    self.props = {}
    local allBag = data
    if allBag ~= nil then
        if allBag.enum then
            self.dilatationNum = allBag.enum
        end
        if allBag.m_exp then
            self.succinct_exp = allBag.m_exp
        end
        if allBag.m_level then
            self.succinct_level = allBag.m_level
        end
        if(allBag.fragment ~= nil)then
            for k, v in pairs(allBag.fragment) do
                local fVo = accessoryFragmentVo:new()
                fVo:initWithData({id = k, num = v})
                table.insert(self.fbag, fVo)
            end
        end
        if(allBag.props ~= nil)then
            for k, v in pairs(allBag.props) do
                self.props[k] = tonumber(v)
            end
        end
        if(allBag.used ~= nil)then
            for tid, tank in pairs(allBag.used) do
                for part, acc in pairs(tank) do
                    local aVo = accessoryVo:new()
                    aVo:initWithData(acc)
                    self.equip[tid][part] = aVo
                end
            end
        end
        self.unUsedAccessory = {}
        self.unusedNum = 0
        if(allBag.info ~= nil)then
            for k, v in pairs(allBag.info) do
                local aVo = accessoryVo:new()
                aVo:initWithData(v)
                aVo.id = k
                table.insert(self.abag, aVo)
                
                local tankID = "t"..aVo:getConfigData("tankID")
                local partID = "p"..aVo:getConfigData("part")
                if(self.equip[tankID] == nil or self.equip[tankID][partID] == nil)then
                    if(self.unUsedAccessory[tankID] == nil)then
                        self.unUsedAccessory[tankID] = {}
                    end
                    if(self.unUsedAccessory[tankID][partID] == nil)then
                        if(self.unusedNum == nil)then
                            self.unusedNum = 1
                        else
                            self.unusedNum = self.unusedNum + 1
                        end
                        self.unUsedAccessory[tankID][partID] = aVo
                    end
                end
            end
        end
        self.unusedNeedRefresh = true
        self:sort()
    end
    return true
end

function accessoryVoApi:sort(type)
    local function sortFuncA(a, b)
        if(a:getConfigData("quality") == b:getConfigData("quality"))then
            if(a.rank == b.rank)then
                if(a.lv == b.lv)then
                    return tonumber(a:getConfigData("tankID")) < tonumber(b:getConfigData("tankID"))
                else
                    return a.lv > b.lv
                end
            else
                return a.rank > b.rank
            end
        else
            return tonumber(a:getConfigData("quality")) > tonumber(b:getConfigData("quality"))
        end
    end
    if(type == nil or type == 1)then
        table.sort(self.abag, sortFuncA)
    end
    local function sortFuncF(a, b)
        if(a.id == "f0")then
            return true
        elseif(b.id == "f0")then
            return false
        end
        if(a:getConfigData("quality") == b:getConfigData("quality"))then
            local aCfgA = accessoryCfg.aCfg[a:getConfigData("output")]
            local aCfgB = accessoryCfg.aCfg[b:getConfigData("output")]
            if(aCfgA.tankID == aCfgB.tankID)then
                return tonumber(aCfgA.part) < tonumber(aCfgB.part)
            else
                return tonumber(aCfgA.tankID) < tonumber(aCfgB.tankID)
            end
        else
            return tonumber(a:getConfigData("quality")) > tonumber(b:getConfigData("quality"))
        end
    end
    if(type == nil or type == 2)then
        table.sort(self.fbag, sortFuncF)
    end
end

--弹出配件面板
--param parent: 面板的parent
--param layerNum: 面板的层
function accessoryVoApi:showAccessoryDialog(parent, layerNum, subIdx)
    local function callback()
        require "luascript/script/game/scene/gamedialog/accessory/accessoryDialog"
        local td = accessoryDialog:new()
        local tbArr = {getlocal("accessory_title_1"), getlocal("accessory_title_3")}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("accessory"), true, layerNum)
        parent:addChild(dialog, layerNum)
        if subIdx then
            local delayT = CCDelayTime:create(0.5)
            local arr = CCArray:create()
            local function ccfun()
                td:tabClick(subIdx)
                td:tabClickColor(subIdx)
            end
            local callback = CCCallFunc:create(ccfun)
            arr:addObject(delayT)
            arr:addObject(callback)
            local seq = CCSequence:create(arr)
            dialog:runAction(seq)
        end
    end
    if(self.dataNeedRefresh == true)then
        self:refreshData(callback)
    else
        callback()
    end
end

--弹出补给线面板
function accessoryVoApi:showSupplyDialog(layerNum)
    local function callback()
        accessoryVoApi:setSupply_lineFlag(true)
        require "luascript/script/game/scene/gamedialog/accessory/accessorySupplyDialog"
        local td = accessorySupplyDialog:new()
        local tbArr = {}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("accessory_title_2"), true, layerNum)
        sceneGame:addChild(dialog, layerNum)
    end
    if(self.dataNeedRefresh == true)then
        self:refreshData(callback)
    else
        callback()
    end
end

--弹出配件信息小面板
--param layerNum: 显示层次
--param type: 1是配件, 2是碎片, 3是道具
--param data: 数据
--param parent: 父UI
--param tankID: 坦克ID
--param partID: 部位ID
--param canSell: 是否可以出售
function accessoryVoApi:showSmallDialog(layerNum, type, data, parent, tankID, partID, canSell)
    require "luascript/script/game/scene/gamedialog/accessory/accessorySmallDialog"
    local smallDialog = accessorySmallDialog:new()
    smallDialog:init(layerNum, type, data, parent, tankID, partID, canSell)
    return smallDialog
end

--弹出配件操作面板
--只有穿着的配件弹出该面板
--param layerNum: 显示层次
--param tankID,partID: 装备位置
function accessoryVoApi:showOprateDialog(layerNum, tankID, partID)
    require "luascript/script/game/scene/gamedialog/accessory/accessoryOperateDialog"
    local td = accessoryOperateDialog:new(tankID, partID)
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), {}, nil, nil, getlocal("accessory"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end

--弹出配件分解面板
--param layerNum: 显示层次
--param type: 1是配件, 2是碎片
--param voData: 数据
--param parent: 父UI
function accessoryVoApi:showDecomposeDialog(layerNum, type, voData, parent)
    require "luascript/script/game/scene/gamedialog/accessory/accessoryDecomposeDialog"
    local smallDialog = accessoryDecomposeDialog:new()
    smallDialog:init(layerNum, type, voData, parent)
    return smallDialog
end

--批量分解的面板
--param type: 1是配件, 2是碎片
function accessoryVoApi:showBulkSaleDialog(type, layerNum)
    require "luascript/script/game/scene/gamedialog/accessory/accessoryBulkSaleDialog"
    local smallDialog = accessoryBulkSaleDialog:new(type)
    smallDialog:init(layerNum)
    return smallDialog
end

function accessoryVoApi:showBatchSmallDialog(layerNum, titleStr, batchData)
    require "luascript/script/game/scene/gamedialog/accessory/accessoryBatchSmallDialog"
    local smallDialog = accessoryBatchSmallDialog:new(type)
    smallDialog:init(layerNum, titleStr, batchData)
    return smallDialog
end

--显示来源面板
--param type: 1是配件, 2是碎片, 3是道具
--param id: 数据的ID
function accessoryVoApi:showSourceDialog(type, id, layerNum)
    require "luascript/script/game/scene/gamedialog/accessory/accessorySourceDialog"
    local smallDialog = accessorySourceDialog:new(type, id)
    smallDialog:init(layerNum)
    return smallDialog
end

--显示突破面板
--param fvo: 要突破的碎片数据
function accessoryVoApi:showEvolutionDialog(tankID, partID, layerNum)
    require "luascript/script/game/scene/gamedialog/accessory/accessoryEvolutionDialog"
    local smallDialog = accessoryEvolutionDialog:new(tankID, partID)
    smallDialog:init(layerNum)
    return smallDialog
end
--显示突破提示小面板
function accessoryVoApi:showEvolutionTipsDialog(layerNum, subTitle, content)
    require "luascript/script/game/scene/gamedialog/accessory/accessoryEvolutionTipsDialog"
    local smallDialog = accessoryEvolutionTipsDialog:new()
    smallDialog:init(layerNum, subTitle, content)
    return smallDialog
end

--显示升级购买水晶小面板
function accessoryVoApi:showUpgradeBuyResDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/accessory/accessoryUpgradeBuyResDialog"
    local smallDialog = accessoryUpgradeBuyResDialog:new()
    smallDialog:init(layerNum, subTitle, content)
    return smallDialog
end

--强化改造精炼科技的面板
function accessoryVoApi:showEquipDialog(tankID, partID, layerNum, defaultTab)
    require "luascript/script/game/scene/gamedialog/accessory/accessoryEquipDialog"
    require "luascript/script/game/scene/gamedialog/accessory/accessoryEquipDialogTabUpgrade"
    require "luascript/script/game/scene/gamedialog/accessory/accessoryEquipDialogTabSmelt"
    require "luascript/script/game/scene/gamedialog/accessory/accessoryEquipDialogTabPurify"
    require "luascript/script/game/scene/gamedialog/accessory/accessoryEquipDialogTabTech"
    local td = accessoryEquipDialog:new(tankID, partID, defaultTab)
    local tbArr = {getlocal("upgrade"), getlocal("smelt")}
    local data = accessoryVoApi:getAccessoryByPart(tankID, partID)
    if(accessoryVoApi:succinctIsOpen() and data:getConfigData("quality") > 2)then
        table.insert(tbArr, getlocal("purifying"))
    end
    if(data.bind == 1 and playerVoApi:getPlayerLevel() >= 50 and data:getConfigData("quality") > 3 and base.accessoryTech == 1)then
        table.insert(tbArr, getlocal("alliance_skill"))
    end
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("accessory"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end

--配件绑定的小面板
function accessoryVoApi:showBindSmallDialog(tankID, partID, layerNum)
    require "luascript/script/game/scene/gamedialog/accessory/accessoryBindSmallDialog"
    local sd = accessoryBindSmallDialog:new(tankID, partID)
    sd:init(layerNum)
    return sd
end

--检查是否可以强化
--param tankID partID: 配件装配的部位
--param paramAvo: 如果强化的是背包中配件, 就要传这个aVo进来
--return 0: 可以强化(count可以连续强化次数); 1: 配件不存在; 2: 资源不足; 3: 玩家等级不足; 4:达到强化上限
function accessoryVoApi:checkCanUpgrade(tankID, partID, paramAvo, level)
    local aVo
    if(tankID ~= nil and partID ~= nil)then
        if(self.equip ~= nil and self.equip["t"..tankID] ~= nil)then
            aVo = self.equip["t"..tankID]["p"..partID]
        end
    else
        aVo = paramAvo
    end
    if(aVo == nil)then
        return 1
    end
    local lv = aVo.lv
    if level then
        lv = level
    end
    local has = playerVoApi:getGold()
    local part = tonumber(aVo:getConfigData("part"))
    local need = accessoryCfg["upgradeResource"..aVo:getConfigData("quality")][part][lv + 1]
    local maxLv = playerVoApi:getMaxLvByKey("roleMaxLevel")
    local upperLimitTb = accessoryVoApi:getPromoteUpperLimitTb(aVo.type, aVo.promoteLv)
    if upperLimitTb and upperLimitTb[1] then
        maxLv = maxLv + upperLimitTb[1]
    end
    if(need == nil or aVo.lv >= maxLv)then
        return 4
    end
    local needGold = need.gold
    need = need.gold
    if(has < need)then
        return 2
    end
    has = playerVoApi:getPlayerLevel()
    if has == playerVoApi:getMaxLvByKey("roleMaxLevel") and upperLimitTb and upperLimitTb[1] then --如果已经达到角色最大等级
        has = has + upperLimitTb[1]
    end
    need = lv + 1
    if(has < need)then
        return 3
    end
    return 0, needGold
end
--可以连续强化的次数
function accessoryVoApi:canUpgradeNum(tankID, partID, paramAvo, isAlwaysSuccess, isMulti)
    local count, costRes = 0, 0
    local aVo
    if(tankID ~= nil and partID ~= nil)then
        if(self.equip ~= nil and self.equip["t"..tankID] ~= nil)then
            aVo = self.equip["t"..tankID]["p"..partID]
        end
    else
        aVo = paramAvo
    end
    if(aVo == nil)then
        do return count end
    end
    local lv = aVo.lv
    -- local costNum=0
    local strengthenNum = accessoryCfg.maxStrengthenNum
    if isMulti == true then
    else
        strengthenNum = 1
    end
    for i = 1, strengthenNum do
        local canUpgrade, needGold = self:checkCanUpgrade(tankID, partID, paramAvo, lv)
        if canUpgrade and canUpgrade == 0 then
            if isAlwaysSuccess == true then
                local firstNum, costPropNum, costPropTb = self:successNeedPropNum(tankID, partID, paramAvo, isAlwaysSuccess, isMulti)
                if costPropTb and costPropTb[i] then
                    local tmpCost = costRes
                    if needGold then
                        tmpCost = costRes + needGold
                    end
                    if playerVoApi:getGold() >= tmpCost then
                        count = count + 1
                        costRes = tmpCost
                    else
                        break
                    end
                else
                    break
                end
            else
                local tmpCost = costRes
                if needGold then
                    tmpCost = costRes + needGold
                end
                if playerVoApi:getGold() >= tmpCost then
                    count = count + 1
                    costRes = tmpCost
                else
                    break
                end
            end
        else
            break
        end
        lv = lv + 1
    end
    return count, costRes
end

--检查是否可以精炼
--param tankID partID: 配件装配的部位
--param paramAvo: 如果是精炼背包里面的配件，就传这个参数
--return 0: 可以精炼; 1: 配件不存在; 21:道具1不足; 22: 道具2不足; 23: 道具3不足; 24: 道具4不足; 3: 达到等级上限
function accessoryVoApi:checkCanSmelt(tankID, partID, paramAvo)
    local aVo
    if(tankID ~= nil and partID ~= nil)then
        if(self.equip ~= nil and self.equip["t"..tankID] ~= nil)then
            aVo = self.equip["t"..tankID]["p"..partID]
        end
    else
        aVo = paramAvo
    end
    if(aVo == nil)then
        return 1
    end
    local maxRank = self:getSmeltMaxRank(aVo:getConfigData("quality"))
    local upperLimitTb = accessoryVoApi:getPromoteUpperLimitTb(aVo.type, aVo.promoteLv)
    if upperLimitTb and upperLimitTb[2] then
        maxRank = maxRank + upperLimitTb[2]
    end
    if(aVo.rank >= maxRank)then
        return 3
    end
    local rank = aVo.rank
    local needTb = accessoryCfg["smeltPropNum"..aVo:getConfigData("quality")][rank + 1]
    for i = 1, 4 do
        local has = self.props["p"..i] or 0
        local needNum = needTb["p"..i]
        if(has < needNum)then
            return 20 + i
        end
    end
    return 0
end

--检查配件是否可以被穿上
--param aVo: 配件的vo
--return true or false
function accessoryVoApi:checkCanWare(aVo)
    if(aVo == nil)then
        return false
    end
    local type = aVo.type
    local part = accessoryCfg.aCfg[type].part
    if(part > accessoryCfg.unLockPart)then
        return false
    end
    local needLv = accessoryCfg.partUnlockLv[tonumber(part)]
    if(playerVoApi:getPlayerLevel() < needLv)then
        return false
    end
    return true
end

--检查配件位是否解锁
function accessoryVoApi:checkPartUnlock(partID)
    if(partID ~= nil and partID > accessoryCfg.unLockPart)then
        return false
    end
    local unlockLv = tonumber(accessoryCfg.partUnlockLv[partID])
    if(unlockLv == nil)then
        return false
    else
        if(playerVoApi:getPlayerLevel() < unlockLv)then
            return false
        else
            return true
        end
    end
end

--获取配件背包格数
function accessoryVoApi:getABagGrid()
    local gridNum = accessoryCfg.aCapacity
    if self.dilatationNum and tonumber(self.dilatationNum[1]) then
        gridNum = gridNum + tonumber(self.dilatationNum[1]) * accessoryCfg.increments
    end
    return gridNum
end

--获取碎片背包格数
function accessoryVoApi:getFBagGrid()
    local gridNum = accessoryCfg.fCapacity
    if self.dilatationNum and tonumber(self.dilatationNum[2]) then
        gridNum = gridNum + tonumber(self.dilatationNum[2]) * accessoryCfg.increments
    end
    return gridNum
end

--获取配件背包剩余空格数
function accessoryVoApi:getABagLeftGrid()
    if self.abag ~= nil then
        local used = 0
        for k, v in pairs(self.abag) do
            if v ~= nil then
                used = used + 1
            end
        end
        return self:getABagGrid() - used
    else
        return 0
    end
end

--获取碎片背包剩余空格数
function accessoryVoApi:getFBagLeftGrid()
    if self.fbag ~= nil then
        local used = 0
        for k, v in pairs(self.fbag) do
            if(v ~= nil and v.num > 0)then
                used = used + 1
            end
        end
        return self:getFBagGrid() - used
        -- else
        -- return self.fbagLeftNum
    end
end

--获取背包扩容消耗的金币数
--bagIdx : 背包页签的索引 1-配件背包,2-碎片背包
function accessoryVoApi:getBagDilatationCostNum(bagIdx)
    local num = 0
    if self.dilatationNum and tonumber(self.dilatationNum[bagIdx]) then
        num = tonumber(self.dilatationNum[bagIdx])
    end
    if accessoryCfg.cCost and accessoryCfg.cCost[num + 1] then
        return accessoryCfg.cCost[num + 1]
    end
end

--获取强化的成功率
--param tankID,partID: 如果是强化穿在身上的配件，那么传这两个字段; amletNum: 使用强化符的数目, 如果要获取默认值的话只要传0即可; paramAvo: 如果是强化背包里面配件, 直接传Vo进来
--return 强化的成功率(x100)
function accessoryVoApi:getUpgradeProbability(tankID, partID, amuletNum, paramAvo, level)
    local aVo
    if(tankID ~= nil and partID ~= nil)then
        if(self.equip ~= nil and self.equip["t"..tankID] ~= nil)then
            aVo = self.equip["t"..tankID]["p"..partID]
        end
    else
        aVo = paramAvo
    end
    if(aVo == nil)then
        return 0
    end
    local lv = aVo.lv
    if level then
        lv = level
    end
    local cfgValue = accessoryCfg["upgradeProbability"..aVo:getConfigData("quality")][lv + 1]
    if(cfgValue == nil)then
        return 0
    end
    if(amuletNum == nil)then
        amuletNum = 0
    end
    local amuletAdd = amuletNum * accessoryCfg.amuletProbality
    local result = cfgValue + amuletAdd
    
    if(result > 100)then
        result = 100
    end
    return result
end

--获取精炼所需要的保级符的数目
--param paramAvo: 直接传数据accessoryVo进来
--return 所需保级符的数目
function accessoryVoApi:getSmeltAmuletNum(paramAvo)
    local aVo = paramAvo
    local rank = aVo.rank
    local cfgTb = accessoryCfg["smeltPropNum"..aVo:getConfigData("quality")][rank + 1]
    if(cfgTb == nil)then
        return 0
    end
    local cfgNum = tonumber(cfgTb["p5"])
    return cfgNum
end

--获取精炼需要的四种道具的数目
--param paramAvo: 直接传数据accessoryVo进来
--return 一个table,table的四个元素是四种道具的数目
function accessoryVoApi:getSmeltPropNum(paramAvo)
    local aVo = paramAvo
    local rank = aVo.rank
    local cfgTb = accessoryCfg["smeltPropNum"..aVo:getConfigData("quality")][rank + 1]
    if(cfgTb == nil)then
        cfgTb = {p1 = 0, p2 = 0, p3 = 0, p4 = 0, p5 = 0}
    end
    return cfgTb
end

--获取更换或者升级配件的时候需要的道具数目
--param paramAvo: 要进行操作的配件
--param techID: 要进行操作的科技，如果该ID等于配件当前科技的ID，那么就是升级，否则的话就是更换
--return 一个table,经过FormatItem之后的各个道具
function accessoryVoApi:getTechChangeProp(paramAvo, techID)
    local lv
    if(paramAvo.techLv == nil)then
        lv = 1
    elseif(paramAvo.techID ~= techID or paramAvo:techLvMax())then
        lv = paramAvo.techLv
    else
        lv = paramAvo.techLv + 1
    end
    local tankID = "t"..paramAvo:getConfigData("tankID")
    local partID = paramAvo:getConfigData("part")
    local costCfg = accessorytechCfg.tankType[tankID][techID].cost[partID][lv]
    local result = {}
    for key, tb in pairs(costCfg) do
        if(key == "props" or key == "fragment")then
            if(result["e"])then
                for id, num in pairs(tb) do
                    result["e"][id] = num
                end
            else
                result["e"] = tb
            end
        elseif(key == "p")then
            result["p"] = tb
        end
    end
    result = FormatItem(result)
    return result
end

--根据配件ID获取配件数据
function accessoryVoApi:getAccessoryByID(id)
    local aVo = nil
    if(self.abag ~= nil)then
        for k, v in pairs(self.abag) do
            if v.id == id then
                aVo = v
                break
            end
        end
    end
    return aVo
end

function accessoryVoApi:getAccessoryIconImage(type)
    local part = accessoryCfg.aCfg[type]["part"]
    local tank = accessoryCfg.aCfg[type]["tankID"]
    local iconSP = "tank"..tank.."accessory_"..part..".png"
    local iconBg
    local quality = accessoryCfg.aCfg[type]["quality"]
    if(quality == 1)then
        iconBg = "greenBg.png"
    elseif(quality == 2)then
        iconBg = "blueBg.png"
    elseif(quality == 3)then
        iconBg = "purpleBg.png"
    elseif(quality == 4)then
        iconBg = "orangeBg.png"
    elseif(quality == 5)then
        iconBg = "redBg.png"
    end
    return iconSP, iconBg
end

--获取配件的图标
--param type: 配件的配置ID; iconWidth: 图标里面的配件的尺寸; bgWidth: 整个图标的尺寸; callback: 点击事件
function accessoryVoApi:getAccessoryIcon(type, iconWidth, bgWidth, callback)
    local part = accessoryCfg.aCfg[type]["part"]
    local tank = accessoryCfg.aCfg[type]["tankID"]
    local iconSP = "tank"..tank.."accessory_"..part..".png"
    local iconBg
    local quality = accessoryCfg.aCfg[type]["quality"]
    if(quality == 1)then
        iconBg = "greenBg.png"
    elseif(quality == 2)then
        iconBg = "blueBg.png"
    elseif(quality == 3)then
        iconBg = "purpleBg.png"
    elseif(quality == 4)then
        iconBg = "orangeBg.png"
    elseif(quality == 5)then
        iconBg = "redBg.png"
    end
    local icon = GetBgIcon(iconSP, callback, iconBg, iconWidth, bgWidth)
    if(quality == 5)then
        -- local lightning1,lightning2
        local function lightningRun(...)
            if icon then
                -- if lightning1 then
                -- lightning1:removeFromParentAndCleanup(true)
                -- lightning1=nil
                -- end
                -- if lightning2 then
                -- lightning2:removeFromParentAndCleanup(true)
                -- lightning2=nil
                -- end
                local showTb = {}
                local sizeTb = {1, 2, 3, 4}
                local lightNum = math.random(1, 2)
                for i = 1, lightNum do
                    local tbNum = SizeOfTable(sizeTb)
                    local sideIndex = math.random(1, tbNum)
                    local value = sizeTb[sideIndex]
                    table.insert(showTb, value)
                    table.remove(sizeTb, sideIndex)
                end
                for k, v in pairs(showTb) do
                    local index = v
                    -- print("index",index)
                    local lightning = CCParticleSystemQuad:create("public/aclightning.plist")
                    local px, py
                    if index == 1 then
                        px, py = icon:getContentSize().width / 2, icon:getContentSize().height - 10
                        lightning:setRotation(90)
                    elseif index == 2 then
                        px, py = icon:getContentSize().width - 10, icon:getContentSize().height / 2
                    elseif index == 3 then
                        px, py = icon:getContentSize().width / 2, 10
                        lightning:setRotation(90)
                    elseif index == 4 then
                        px, py = 10, icon:getContentSize().height / 2
                    end
                    -- lightning.positionType=kCCPositionTypeFree
                    -- lightning.positionType=kCCPositionTypeRelative
                    lightning.positionType = kCCPositionTypeGrouped
                    lightning:setPosition(ccp(px, py))
                    lightning:setAutoRemoveOnFinish(true) --自动移除
                    icon:addChild(lightning, 2)
                    -- if k==1 then
                    -- lightning1=lightning
                    -- else
                    -- lightning2=lightning
                    -- end
                end
            end
        end
        local actionFunc = CCCallFunc:create(lightningRun)
        local delay = CCDelayTime:create(0.4)
        local acArr = CCArray:create()
        acArr:addObject(delay)
        acArr:addObject(actionFunc)
        local seq = CCSequence:create(acArr)
        local repeatForever = CCRepeatForever:create(seq)
        icon:runAction(repeatForever)
    end
    return icon
end

--获取碎片的图标
--param fVo: 碎片的配置ID; iconWidth: 图标里面的碎片的尺寸; bgWidth: 整个图标的尺寸; callback: 点击事件
function accessoryVoApi:getFragmentIcon(type, iconWidth, bgWidth, callback)
    local output = accessoryCfg.fragmentCfg[type]["output"]
    local iconSP
    if(output == "")then
        iconSP = "accessoryFragment0.png"
        local icon
        if callback ~= nil then
            icon = LuaCCSprite:createWithSpriteFrameName(iconSP, callback)
        else
            icon = CCSprite:createWithSpriteFrameName(iconSP)
        end
        icon:setScale(bgWidth / icon:getContentSize().width)
        return icon
    else
        local aCfg = accessoryCfg.aCfg[output]
        local tank = aCfg.tankID
        local part = aCfg.part
        iconSP = "tank"..tank.."accessory_"..part..".png"
    end
    local iconBg = "fragmentBg"..accessoryCfg.fragmentCfg[type]["quality"] .. ".png"
    local icon = GetBgIcon(iconSP, callback, iconBg, iconWidth, bgWidth)
    return icon
end

function accessoryVoApi:getFragmentIconImage(type)
    local output = accessoryCfg.fragmentCfg[type]["output"]
    local iconBg = "fragmentBg"..accessoryCfg.fragmentCfg[type]["quality"] .. ".png"
    if(output == "")then
        return "accessoryFragment0.png", iconBg
    else
        local aCfg = accessoryCfg.aCfg[output]
        local tank = aCfg.tankID
        local part = aCfg.part
        return "tank"..tank.."accessory_"..part..".png", iconBg
    end
end

--根据碎片ID获取碎片数据
function accessoryVoApi:getFragmentByID(id)
    local fVo = nil
    if(self.fbag ~= nil)then
        for k, v in pairs(self.fbag) do
            if v.id == id then
                fVo = v
                break
            end
        end
    end
    return fVo
end

function accessoryVoApi:getAccessoryBag()
    return self.abag
end

function accessoryVoApi:getFragmentBag()
    return self.fbag
end

--获取某个坦克的某个部位上的配件
--param tankID: 哪种坦克(1~4); partID: 哪个部位(1~8)
function accessoryVoApi:getAccessoryByPart(tankID, partID)
    if(self.equip ~= nil and self.equip["t"..tankID] ~= nil)then
        return self.equip["t"..tankID]["p"..partID]
    end
    return nil
end

--获取某个坦克装备的配件信息
--param tankID: 哪种坦克(1~4)
function accessoryVoApi:getTankAccessories(tankID)
    if(self.equip ~= nil)then
        return self.equip["t"..tankID]
    end
    return nil
end

--获取分解的产物
--param type: 1是分解配件, 2是分解碎片
--param vo: 碎片的vo或者配件的vo
--return 一个table, 4个元素是五种产物的数目, 一个数字, 是分解出来的水晶的数目
function accessoryVoApi:getSellItem(type, vo)
    local result = {p1 = 0, p2 = 0, p3 = 0, p4 = 0, p8 = 0, p9 = 0, p10 = 0}
    local resource = 0
    local quality = vo:getConfigData("quality")
    if(type == 1)then
        for i = 1, vo.lv do
            local upgradeResource = accessoryCfg["upgradeResource"..quality][tonumber(vo:getConfigData("part"))][i].gold
            resource = resource + upgradeResource
        end
        resource = resource * accessoryCfg.resolveupgradeResource
        for i = 1, vo.rank do
            local upgradeProp = accessoryCfg["smeltPropNum"..quality][i]
            for j = 1, 4 do
                result["p"..j] = result["p"..j] + upgradeProp["p"..j]
            end
        end
        for i = 1, 4 do
            result["p"..i] = result["p"..i] * accessoryCfg.resolveRefineResource
        end
        result["p4"] = result["p4"] + accessoryCfg.resolveAccessoryProp["part"..vo:getConfigData("part")][tonumber(quality)]
        if(base.ecshop == 1)then
            for i = 8, 10 do
                local propNum = accessoryCfg.resolveAccessoryCrystalsProp["part"..vo:getConfigData("part")][tonumber(quality)]["p"..i]
                if(propNum)then
                    result["p"..i] = result["p"..i] + propNum
                end
            end
        end
    elseif(type == 2)then
        result["p4"] = accessoryCfg.resolveFragmentProp[tonumber(quality)] * vo.num
        if(base.ecshop == 1)then
            for i = 8, 10 do
                local propNum = accessoryCfg.resolveFragmentCrystalsProp["part"..vo:getConfigData("part")][tonumber(quality)]["p"..i]
                if(propNum)then
                    result["p"..i] = result["p"..i] + propNum * vo.num
                end
            end
        end
    end
    return result, resource
end

--获取突破返还的道具
--param vo: 要突破的配件vo
--return 一个table, 4个元素是五种产物的数目, 一个数字, 是分解出来的水晶的数目
function accessoryVoApi:getEvolutionReturn(vo)
    local result = {p1 = 0, p2 = 0, p3 = 0, p4 = 0}
    local resource = 0
    local quality = vo:getConfigData("quality")
    for i = 1, vo.lv do
        local upgradeResource = accessoryCfg["upgradeResource"..quality][tonumber(vo:getConfigData("part"))][i].gold
        resource = resource + upgradeResource
    end
    resource = resource * accessoryCfg.resolveupgradeResource
    for i = 1, vo.rank do
        local upgradeProp = accessoryCfg["smeltPropNum"..quality][i]
        for j = 1, 4 do
            result["p"..j] = result["p"..j] + upgradeProp["p"..j]
        end
    end
    for i = 1, 4 do
        result["p"..i] = result["p"..i] * accessoryCfg.resolveRefineResource
    end
    result["p4"] = result["p4"] + accessoryCfg.resolveAccessoryProp["part"..vo:getConfigData("part")][tonumber(quality)]
    return result, resource
end

--获取万能碎片的数目
function accessoryVoApi:getMultiFragmentNum()
    if(self.fbag == nil)then
        return 0
    end
    for k, v in pairs(self.fbag) do
        if(v.id == "f0")then
            return v.num
        end
    end
    return 0
end

-- 配件新手引导到了第几步
-- 0是未开始引导
function accessoryVoApi:getGuideStep()
    if(self.guideStep == nil)then
        local dataKey = "accessoryGuide@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID)
        local localData = CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
        if(localData ~= nil and localData ~= "")then
            self.guideStep = tonumber(localData)
        else
            self.guideStep = 0
        end
    end
    return self.guideStep
end

--设置配件新手引导的步数
function accessoryVoApi:setGuideStep(step)
    self.guideStep = step
    local dataKey = "accessoryGuide@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID)
    CCUserDefault:sharedUserDefault():setStringForKey(dataKey, step)
    CCUserDefault:sharedUserDefault():flush()
end

function accessoryVoApi:addFragment(id, num)
    local fVo = self:getFragmentByID(id)
    if(fVo ~= nil and fVo.num > 0)then
        fVo.num = fVo.num + num
    else
        local leftGrid = self:getFBagLeftGrid()
        if(leftGrid == nil or leftGrid <= 0)then
            return false
        else
            
        end
    end
    return true
end

--强化
--param tankID & partID: 强化穿在身上的配件, 坦克ID和部位确定要强化的配件ID; amuletNum: 使用的强化符数量
--param paramAvo: 强化背包里的配件, 要传这个字段
function accessoryVoApi:upgrade(tankID, partID, paramAvo, amuletNum, callback, count)
    self.upgradeTankID = tankID
    self.upgradePartID = partID
    self.upgradeAvo = paramAvo
    self.upgradeCallback = callback
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret ~= true)then
            self.dataNeedRefresh = true
            do return end
        end
        local aVo
        if(self.upgradeTankID ~= nil)then
            aVo = self.equip["t"..self.upgradeTankID]["p"..self.upgradePartID]
        else
            aVo = self.upgradeAvo
        end
        local oldLv = aVo.lv
        local newLv = oldLv
        
        if sData.data.accessory ~= nil then
            if sData.data.accessory.m_exp then
                self.succinct_exp = sData.data.accessory.m_exp
            end
            if sData.data.accessory.m_level then
                self.succinct_level = sData.data.accessory.m_level
            end
        end
        if(sData.data.accessory ~= nil and sData.data.accessory.used ~= nil)then
            for tid, tank in pairs(sData.data.accessory.used) do
                for part, acc in pairs(tank) do
                    if tid == "t"..self.upgradeTankID and part == "p"..self.upgradePartID then
                        newLv = tonumber(acc[2])
                        self.equip["t"..self.upgradeTankID]["p"..self.upgradePartID].lv = newLv
                    end
                end
            end
        end
        local eventData = {}
        if(self.upgradeAvo ~= nil and sData.data.accessory ~= nil and sData.data.accessory.info ~= nil and sData.data.accessory.info[self.upgradeAvo.id] ~= nil)then
            newLv = tonumber(sData.data.accessory.info[self.upgradeAvo.id][2])
            self.upgradeAvo.lv = newLv
            self:sort(1)
            table.insert(eventData, 1)
        end
        local result
        local quality = aVo:getConfigData("quality")
        if(newLv > oldLv)then
            table.insert(eventData, 4)
            result = true
            --发送刷屏消息
            -- if(quality == 3 or quality == 4 or quality == 5)then
            --     if newLv >= 20 then
            --         local noticeLv = 0
            --         if (newLv - oldLv) > 1 then
            --             if math.floor(newLv / 10) - math.floor(oldLv / 10) > 0 then
            --                 noticeLv = math.floor(newLv / 10) * 10
            --             end
            --         else
            --             if(newLv % 10 == 0)then
            --                 noticeLv = newLv
            --             end
            --         end
            --         if(noticeLv and noticeLv > 0)then
            --             local noticeLv = newLv - (newLv % 10)
            --             local fullname = {key = "accessory_quality_"..quality, param = {key = aVo:getConfigData("name"), param = {}}}
            --             local message = {key = "accessory_chat_msg_2", param = {playerVoApi:getPlayerName(), fullname, noticeLv}}
            --             chatVoApi:sendSystemMessage(message)
            --         end
            --     end
            -- end
        else
            result = false
        end
        local needResource = accessoryCfg["upgradeResource"..quality][tonumber(aVo:getConfigData("part"))][oldLv + 1].gold
        local userResource = playerVoApi:getGold()
        local usedResource = 0
        if sData and sData.data and sData.data.report and SizeOfTable(sData.data.report) > 0 then
            for k, v in pairs(sData.data.report) do
                if v and SizeOfTable(v) > 0 then
                    local isVictory = v[1] or 0
                    local costTb = v[2] or {}
                    local needRes = 0
                    if costTb and costTb.gold then
                        needRes = costTb.gold or 0
                    end
                    local propNum = v[3] or 0
                    local returnTb = v[4] or {}
                    local returnRes = 0
                    if returnTb and returnTb.gold then
                        returnRes = returnTb.gold or 0
                    end
                    userResource = userResource - (needRes - returnRes)
                end
            end
        elseif(result)then
            userResource = userResource - needResource
        else
            if(activityVoApi:checkActivityEffective("accessoryEvolution"))then
                local version = 1
                if acAccessoryUpgradeVoApi then
                    version = acAccessoryUpgradeVoApi:getVersion()
                end
                usedResource = needResource * (accessoryCfg.upgradeFailReturnResource - activityCfg.accessoryEvolution[version].serverreward.moneyDecrease)
                userResource = userResource - usedResource
            else
                usedResource = needResource * accessoryCfg.upgradeFailReturnResource
                userResource = userResource - usedResource
            end
        end
        playerVoApi:setValue("gold", userResource)
        if(sData.data.accessory.props ~= nil)then
            self.props = {}
            for k, v in pairs(sData.data.accessory.props) do
                self.props[k] = tonumber(v)
            end
            table.insert(eventData, 3)
        end
        G_dayin(eventData)
        eventDispatcher:dispatchEvent("accessory.data.refresh", {type = eventData})
        if(self.upgradeCallback ~= nil)then
            self.upgradeCallback(result, sData, oldLv, needResource - usedResource)
            self.upgradeCallback = nil
        end
        self.upgradeTankID = nil
        self.upgradePartID = nil
        self.upgradeAvo = nil
    end
    if count and count > 0 then
        if(tankID ~= nil)then
            socketHelper:accessoryBatchupgrade("t"..tankID, "p"..partID, nil, amuletNum, count, onRequestEnd)
        else --暂时没有 背包里的配件强化
            socketHelper:accessoryBatchupgrade(nil, nil, paramAvo.id, amuletNum, count, onRequestEnd)
        end
    else
        if(tankID ~= nil)then
            socketHelper:upgradeAccessory("t"..tankID, "p"..partID, nil, amuletNum, onRequestEnd)
        else
            socketHelper:upgradeAccessory(nil, nil, paramAvo.id, amuletNum, onRequestEnd)
        end
    end
end

--精炼
--param tankID & partID: 只能精炼穿在身上的配件, 坦克ID和部位确定要强化的配件ID; isUseAmulet: 是否使用保级符, true or false
--param paramAvo: 如果是强化背包里面的配件, 就把vo传进来
function accessoryVoApi:smelt(tankID, partID, paramAvo, isUseAmulet, callback)
    self.smeltTankID = tankID
    self.smeltPartID = partID
    self.smeltAvo = paramAvo
    self.smeltCallback = callback
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret ~= true)then
            self.dataNeedRefresh = true
            do return end
        end
        if sData.data.accessory ~= nil then
            if sData.data.accessory.m_exp then
                self.succinct_exp = sData.data.accessory.m_exp
            end
            if sData.data.accessory.m_level then
                self.succinct_level = sData.data.accessory.m_level
            end
        end
        if(sData.data.accessory.used ~= nil)then
            for tid, tank in pairs(sData.data.accessory.used) do
                for part, acc in pairs(tank) do
                    self.equip[tid][part].lv = acc[2]
                    self.equip[tid][part].rank = acc[3]
                end
            end
        end
        local eventData = {}
        if(sData.data.accessory.info ~= nil and self.smeltAvo ~= nil)then
            self.smeltAvo.rank = tonumber(sData.data.accessory.info[self.smeltAvo.id][3])
            self.smeltAvo.lv = tonumber(sData.data.accessory.info[self.smeltAvo.id][2])
            self:sort(1)
            table.insert(eventData, 1)
        end
        if(sData.data.accessory.props ~= nil)then
            self.props = {}
            for k, v in pairs(sData.data.accessory.props) do
                self.props[k] = tonumber(v)
            end
            table.insert(eventData, 3)
        end
        --发送刷屏消息
        -- local aVo
        -- if(self.smeltAvo ~= nil)then
        --     aVo = self.smeltAvo
        -- else
        --     aVo = self.equip["t"..self.smeltTankID]["p"..self.smeltPartID]
        -- end
        -- local quality = aVo:getConfigData("quality")
        -- if(quality == 3 or quality == 4 or quality == 5)then
        --     if(aVo.rank > 2)then
        --         if(aVo ~= nil)then
        --             -- local fullname=getlocal("accessory_quality_"..quality,{getlocal(aVo:getConfigData("name"))})
        --             --chatVoApi:sendSystemMessage(getlocal("accessory_chat_msg_3",{playerVoApi:getPlayerName(),fullname,aVo.rank}))
        --             local fullname = {key = "accessory_quality_"..quality, param = {key = aVo:getConfigData("name"), param = {}}}
        --             local message = {key = "accessory_chat_msg_3", param = {playerVoApi:getPlayerName(), fullname, aVo.rank}}
        --             chatVoApi:sendSystemMessage(message)
        --         end
        --     end
        -- end
        table.insert(eventData, 4)
        eventDispatcher:dispatchEvent("accessory.data.refresh", {type = eventData})
        if(self.smeltCallback ~= nil)then
            self.smeltCallback(nil, sData.data.retProp)
            self.smeltCallback = nil
        end
        self.smeltTankID = nil
        self.smeltPartID = nil
        self.smeltAvo = nil
    end
    if(tankID ~= nil)then
        socketHelper:smeltAccesory("t"..tankID, "p"..partID, nil, isUseAmulet, onRequestEnd)
    else
        socketHelper:smeltAccesory(nil, nil, paramAvo.id, isUseAmulet, onRequestEnd)
    end
end

--碎片合成配件
--param id: 要合成的碎片的id
--param useMulti: 是否使用万能碎片,true or false
function accessoryVoApi:compose(id, useMulti, callback)
    self.composeCallback = callback
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret ~= true or sData.data.accessory == nil or sData.data.accessory.info == nil)then
            self.dataNeedRefresh = true
            do return end
        end
        if(self.unUsedAccessory == nil)then
            self.unUsedAccessory = {}
        end
        if sData.data.accessory ~= nil then
            if sData.data.accessory.m_exp then
                self.succinct_exp = sData.data.accessory.m_exp
            end
            if sData.data.accessory.m_level then
                self.succinct_level = sData.data.accessory.m_level
            end
        end
        local equipRefreshFlag = false
        for k, v in pairs(sData.data.accessory.info) do
            local aVo = accessoryVo:new()
            aVo:initWithData(v)
            aVo.id = k
            table.insert(self.abag, aVo)
            
            local tankID = "t"..aVo:getConfigData("tankID")
            local partID = "p"..aVo:getConfigData("part")
            if(self.equip[tankID] == nil or self.equip[tankID][partID] == nil)then
                self.unusedNeedRefresh = true
                if(self.unUsedAccessory[tankID] == nil)then
                    self.unUsedAccessory[tankID] = {}
                end
                if(self.unUsedAccessory[tankID][partID] == nil)then
                    if(self.unusedNum == nil)then
                        self.unusedNum = 1
                    else
                        self.unusedNum = self.unusedNum + 1
                    end
                    self.unUsedAccessory[tankID][partID] = aVo
                    equipRefreshFlag = true
                end
            end
            --发送刷屏消息
            -- local quality = aVo:getConfigData("quality")
            -- if(quality == 3 or quality == 4 or quality == 5)then
            --     -- local fullname=getlocal("accessory_quality_"..quality,{getlocal(aVo:getConfigData("name"))})
            --     --chatVoApi:sendSystemMessage(getlocal("accessory_chat_msg_1",{playerVoApi:getPlayerName(),fullname}))
            --     local fullname = {key = "accessory_quality_"..quality, param = {key = aVo:getConfigData("name"), param = {}}}
            --     local message = {key = "accessory_chat_msg_1", param = {playerVoApi:getPlayerName(), fullname}}
            --     chatVoApi:sendSystemMessage(message)
            -- end
        end
        local eventData = {}
        if(equipRefreshFlag)then
            table.insert(eventData, 4)
        end
        if(sData.data.accessory.fragment ~= nil)then
            self.fbag = nil
            self.fbag = {}
            for k, v in pairs(sData.data.accessory.fragment) do
                local fVo = accessoryFragmentVo:new()
                fVo:initWithData({id = k, num = v})
                table.insert(self.fbag, fVo)
            end
        end
        self:sort()
        table.insert(eventData, 1)
        table.insert(eventData, 2)
        eventDispatcher:dispatchEvent("accessory.data.refresh", {type = eventData})
        if(self.composeCallback ~= nil)then
            self.composeCallback()
            self.composeCallback = nil
        end
    end
    socketHelper:composeAccessory(id, useMulti, onRequestEnd)
end

--出售配件
--param type: 1是单个出售, 2是批量出售
--param param: type=1的时候是配件ID, eg: a8668064; type=2的时候是一个品质table, eg: {1,2}
function accessoryVoApi:sellAccessory(type, param, callback)
    self.sellAccessoryCallback = callback
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret ~= true or sData.data.accessory == nil)then
            self.dataNeedRefresh = true
            do return end
        end
        if sData.data.accessory ~= nil then
            if sData.data.accessory.m_exp then
                self.succinct_exp = sData.data.accessory.m_exp
            end
            if sData.data.accessory.m_level then
                self.succinct_level = sData.data.accessory.m_level
            end
        end
        local award = FormatItem(sData.data.reward) or {}
        for k, v in pairs(award) do
            G_addPlayerAward(v.type, v.key, v.id, v.num)
        end
        
        self.unUsedAccessory = {}
        self.unusedNum = 0
        self.unusedNeedRefresh = true
        local eventData = {}
        if(sData.data.accessory.info ~= nil)then
            self.abag = nil
            self.abag = {}
            for k, v in pairs(sData.data.accessory.info) do
                local aVo = accessoryVo:new()
                aVo:initWithData(v)
                aVo.id = k
                table.insert(self.abag, aVo)
                
                local tankID = "t"..aVo:getConfigData("tankID")
                local partID = "p"..aVo:getConfigData("part")
                if(self.equip[tankID] == nil or self.equip[tankID][partID] == nil)then
                    if(self.unUsedAccessory[tankID] == nil)then
                        self.unUsedAccessory[tankID] = {}
                    end
                    if(self.unUsedAccessory[tankID][partID] == nil)then
                        self.unusedNum = self.unusedNum + 1
                        self.unUsedAccessory[tankID][partID] = aVo
                    end
                end
            end
            self:sort(1)
            table.insert(eventData, 1)
        end
        table.insert(eventData, 4)
        local getReward = {}
        if(sData.data.reward ~= nil and sData.data.reward.u ~= nil and sData.data.reward.u.gold ~= nil)then
            getReward.resource = sData.data.reward.u.gold
        end
        local oldProps = {}
        for k, v in pairs(self.props) do
            oldProps[k] = v
        end
        if(sData.data.accessory.props ~= nil)then
            self.props = {}
            for k, v in pairs(sData.data.accessory.props) do
                self.props[k] = tonumber(v)
            end
            table.insert(eventData, 3)
        end
        for k, v in pairs(self.props) do
            if(oldProps[k] ~= nil)then
                local add = v - oldProps[k]
                if(add > 0)then
                    getReward[k] = add
                end
            else
                getReward[k] = v
            end
        end
        eventDispatcher:dispatchEvent("accessory.data.refresh", {type = eventData})
        if(self.sellAccessoryCallback ~= nil)then
            self.sellAccessoryCallback(getReward)
            self.sellAccessoryCallback = nil
        end
    end
    socketHelper:sellAccessory(type, param, onRequestEnd)
end

--出售碎片
--param type: 1是单个出售, 2是批量出售
--param param: type=1的时候是碎片ID, eg: f1; type=2的时候是一个品质table, eg: {1,2}
function accessoryVoApi:sellFragment(type, param, callback)
    self.sellFragmentCallback = callback
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret ~= true or sData.data.accessory == nil)then
            self.dataNeedRefresh = true
            do return end
        end
        if sData.data.accessory ~= nil then
            if sData.data.accessory.m_exp then
                self.succinct_exp = sData.data.accessory.m_exp
            end
            if sData.data.accessory.m_level then
                self.succinct_level = sData.data.accessory.m_level
            end
        end
        local eventData = {}
        if(sData.data.accessory.fragment ~= nil)then
            self.fbag = nil
            self.fbag = {}
            for k, v in pairs(sData.data.accessory.fragment) do
                local fVo = accessoryFragmentVo:new()
                fVo:initWithData({id = k, num = v})
                table.insert(self.fbag, fVo)
            end
            self:sort(2)
            table.insert(eventData, 2)
        end
        local oldProps = {}
        for k, v in pairs(self.props) do
            oldProps[k] = v
        end
        if(sData.data.accessory.props ~= nil)then
            self.props = {}
            for k, v in pairs(sData.data.accessory.props) do
                self.props[k] = tonumber(v)
            end
            table.insert(eventData, 3)
        end
        local getReward = {}
        for k, v in pairs(self.props) do
            if(oldProps[k] ~= nil)then
                local add = v - oldProps[k]
                if(add > 0)then
                    getReward[k] = add
                end
            else
                getReward[k] = v
            end
        end
        eventDispatcher:dispatchEvent("accessory.data.refresh", {type = eventData})
        if(self.sellFragmentCallback ~= nil)then
            self.sellFragmentCallback(getReward)
            self.sellFragmentCallback = nil
        end
    end
    socketHelper:sellAccessoryFragment(type, param, onRequestEnd)
end

--穿配件
--param id: 要穿的配件ID; callback: 回调函数
function accessoryVoApi:ware(id, callback)
    self.wareCallback = callback
    self.wareItemID = id
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret ~= true)then
            self.dataNeedRefresh = true
            do return end
        end
        local wareItem
        for k, v in pairs(self.abag) do
            if(v.id == self.wareItemID)then
                wareItem = v
                table.remove(self.abag, k)
                break
            end
        end
        
        if sData.data.accessory ~= nil then
            if sData.data.accessory.m_exp then
                self.succinct_exp = sData.data.accessory.m_exp
            end
            if sData.data.accessory.m_level then
                self.succinct_level = sData.data.accessory.m_level
            end
        end
        --如果有返回数据里面有info, 那说明是替换穿着的配件, 否则就是穿上配件, 这时候需要把未穿戴的配件数目减1
        if(sData.data.accessory.info ~= nil)then
            for k, v in pairs(sData.data.accessory.info) do
                local aVo = accessoryVo:new()
                aVo:initWithData(v)
                aVo.id = k
                table.insert(self.abag, aVo)
            end
        else
            if(wareItem ~= nil)then
                local tankID = "t"..wareItem:getConfigData("tankID")
                local partID = "p"..wareItem:getConfigData("part")
                if(self.unUsedAccessory ~= nil and self.unUsedAccessory[tankID] ~= nil and self.unUsedAccessory[tankID][partID] ~= nil)then
                    self.unUsedAccessory[tankID][partID] = nil
                end
            end
            if(self.unusedNum ~= nil and self.unusedNum > 0)then
                self.unusedNum = self.unusedNum - 1
            end
            self.unusedNeedRefresh = true
        end
        if(sData.data.accessory.used ~= nil)then
            self.equip = {t1 = {}, t2 = {}, t3 = {}, t4 = {}}
            for tid, tank in pairs(sData.data.accessory.used) do
                self.equip[tid] = {}
                for part, acc in pairs(tank) do
                    local aVo = accessoryVo:new()
                    aVo:initWithData(acc)
                    self.equip[tid][part] = aVo
                end
            end
        end
        if(sData.data.newfc ~= nil)then
            playerVoApi:setValue("fc", tonumber(sData.data.newfc))
        end
        self:sort(1)
        eventDispatcher:dispatchEvent("accessory.data.refresh", {type = {1, 4}})
        if(self.wareCallback ~= nil)then
            self.wareCallback(sData.data)
            self.wareCallback = nil
        end
    end
    socketHelper:wareAccessory(id, onRequestEnd)
end

--脱配件
function accessoryVoApi:takeOff(tank, part, callback)
    self.takeoffCallback = callback
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret ~= true)then
            self.dataNeedRefresh = true
            do return end
        end
        
        if sData.data.accessory ~= nil then
            if sData.data.accessory.m_exp then
                self.succinct_exp = sData.data.accessory.m_exp
            end
            if sData.data.accessory.m_level then
                self.succinct_level = sData.data.accessory.m_level
            end
        end
        if(sData.data.accessory.info ~= nil)then
            for k, v in pairs(sData.data.accessory.info) do
                local aVo = accessoryVo:new()
                aVo:initWithData(v)
                aVo.id = k
                table.insert(self.abag, aVo)
                if(self.unusedNum ~= nil)then
                    self.unusedNum = self.unusedNum + 1
                else
                    self.unusedNum = 1
                end
                local tankID = "t"..aVo:getConfigData("tankID")
                local partID = "p"..aVo:getConfigData("part")
                if(self.unUsedAccessory == nil)then
                    self.unUsedAccessory = {}
                end
                if(self.unUsedAccessory[tankID] == nil)then
                    self.unUsedAccessory[tankID] = {}
                end
                if(self.unUsedAccessory[tankID][partID] == nil)then
                    self.unUsedAccessory[tankID][partID] = aVo
                end
            end
            self.unusedNeedRefresh = true
        end
        self.equip["t"..tank]["p"..part] = nil
        self:sort(1)
        eventDispatcher:dispatchEvent("accessory.data.refresh", {type = {1, 4}})
        if(self.takeoffCallback ~= nil)then
            self.takeoffCallback(data)
            self.takeoffCallback = nil
        end
    end
    socketHelper:takeoffAccessory("t"..tank, "p"..part, onRequestEnd)
end

--绑定
--param tankID,partID: 只能绑定装备的配件, 参数是配件的位置
--param callback: 绑定回调
function accessoryVoApi:bind(tankID, partID, callback)
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret ~= true)then
            self.dataNeedRefresh = true
            do return end
        end
        if(sData.data.accessory.used ~= nil)then
            self.equip = {t1 = {}, t2 = {}, t3 = {}, t4 = {}}
            for tid, tank in pairs(sData.data.accessory.used) do
                self.equip[tid] = {}
                for part, acc in pairs(tank) do
                    local aVo = accessoryVo:new()
                    aVo:initWithData(acc)
                    self.equip[tid][part] = aVo
                end
            end
            eventDispatcher:dispatchEvent("accessory.data.refresh", {type = {4}})
        end
        if(callback)then
            callback()
        end
    end
    socketHelper:accessoryBind("t"..tankID, "p"..partID, onRequestEnd)
end

--获得某种坦克身上的四种属性加成值
--param tankID: 1,2,4,8
--return {100,100,2000,2000}
function accessoryVoApi:getTankAttAdd(tankID)
    local accessoryTankID
    local result = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    if(tankID == 4 or tankID == "4")then
        accessoryTankID = 3
    elseif(tankID == 8 or tankID == "8")then
        accessoryTankID = 4
    else
        accessoryTankID = tankID
    end
    if(self.equip ~= nil and self.equip["t"..accessoryTankID] ~= nil)then
        for k, v in pairs(self.equip["t"..accessoryTankID]) do
            local att = v:getAttWithSuccinct()
            for k1, v1 in pairs(att) do
                result[k1] = result[k1] + v1
            end
        end
    end
    return result
end

--添加新配件, 碎片或者道具
--param data: 与list接口的格式相同, 有info, fragment和prop, 不过全都是差量
function accessoryVoApi:addNewData(data)
    --如果数据需要刷新，那么就只发送刷屏消息，不做其他操作
    if(self.dataNeedRefresh)then
        if(data.fragment ~= nil)then
            for k, v in pairs(data.fragment) do
                local fVo = accessoryFragmentVo:new()
                fVo:initWithData({id = k, num = v})
                --发送刷屏消息
                -- local quality = fVo:getConfigData("quality")
                -- if(quality == 3 or quality == 4 or quality == 5)then
                --     -- local fullname=getlocal("accessory_quality_"..quality,{getlocal(fVo:getConfigData("name"))})
                --     -- chatVoApi:sendSystemMessage(getlocal("accessory_chat_msg_1",{playerVoApi:getPlayerName(),fullname}))
                --     local fullname = {key = "accessory_quality_"..quality, param = {key = fVo:getConfigData("name"), param = {}}}
                --     local message = {key = "accessory_chat_msg_1", param = {playerVoApi:getPlayerName(), fullname}}
                --     chatVoApi:sendSystemMessage(message)
                -- end
                fVo = nil
            end
        end
        if(data.info ~= nil)then
            for k, v in pairs(data.info) do
                local aVo = accessoryVo:new()
                aVo:initWithData(v)
                aVo.id = k
                --发送刷屏消息
                -- local quality = aVo:getConfigData("quality")
                -- if(quality == 3 or quality == 4 or quality == 5)then
                --     -- local fullname=getlocal("accessory_quality_"..quality,{getlocal(aVo:getConfigData("name"))})
                --     -- chatVoApi:sendSystemMessage(getlocal("accessory_chat_msg_1",{playerVoApi:getPlayerName(),fullname}))
                --     local fullname = {key = "accessory_quality_"..quality, param = {key = aVo:getConfigData("name"), param = {}}}
                --     local message = {key = "accessory_chat_msg_1", param = {playerVoApi:getPlayerName(), fullname}}
                --     chatVoApi:sendSystemMessage(message)
                -- end
            end
        end
        do return end
    end
    local eventData = {}
    if(data.fragment ~= nil and self.fbag ~= nil)then
        for k, v in pairs(data.fragment) do
            local has = false
            for k1, v1 in pairs(self.fbag) do
                if(v1.id == k)then
                    v1.num = v1.num + v
                    has = true
                    --发送刷屏消息
                    -- local quality = v1:getConfigData("quality")
                    -- if(quality == 3 or quality == 4 or quality == 5)then
                    --     -- local fullname=getlocal("accessory_quality_"..quality,{getlocal(v1:getConfigData("name"))})
                    --     -- chatVoApi:sendSystemMessage(getlocal("accessory_chat_msg_1",{playerVoApi:getPlayerName(),fullname}))
                    --     local fullname = {key = "accessory_quality_"..quality, param = {key = v1:getConfigData("name"), param = {}}}
                    --     local message = {key = "accessory_chat_msg_1", param = {playerVoApi:getPlayerName(), fullname}}
                    --     chatVoApi:sendSystemMessage(message)
                        
                    -- end
                    break
                end
            end
            if(has == false)then
                local fVo = accessoryFragmentVo:new()
                fVo:initWithData({id = k, num = v})
                table.insert(self.fbag, fVo)
                --发送刷屏消息
                -- local quality = fVo:getConfigData("quality")
                -- if(quality == 3 or quality == 4 or quality == 5)then
                --     -- local fullname=getlocal("accessory_quality_"..quality,{getlocal(fVo:getConfigData("name"))})
                --     -- chatVoApi:sendSystemMessage(getlocal("accessory_chat_msg_1",{playerVoApi:getPlayerName(),fullname}))
                --     local fullname = {key = "accessory_quality_"..quality, param = {key = fVo:getConfigData("name"), param = {}}}
                --     local message = {key = "accessory_chat_msg_1", param = {playerVoApi:getPlayerName(), fullname}}
                --     chatVoApi:sendSystemMessage(message)
                -- end
            end
        end
        self:sort(2)
        table.insert(eventData, 2)
    end
    if(data.props ~= nil and self.props ~= nil)then
        for k, v in pairs(data.props) do
            if(self.props[k] == nil)then
                self.props[k] = 0
            end
            self.props[k] = self.props[k] + tonumber(v)
        end
        table.insert(eventData, 3)
    end
    if(self.unUsedAccessory == nil)then
        self.unUsedAccessory = {}
    end
    if(data.info ~= nil and self.abag ~= nil)then
        local equipRefreshFlag = false
        for k, v in pairs(data.info) do
            local aVo = accessoryVo:new()
            aVo:initWithData(v)
            aVo.id = k
            table.insert(self.abag, aVo)
            local tankID = "t"..aVo:getConfigData("tankID")
            local partID = "p"..aVo:getConfigData("part")
            if(self.equip[tankID] == nil or self.equip[tankID][partID] == nil)then
                self.unusedNeedRefresh = true
                if(self.unUsedAccessory[tankID] == nil)then
                    self.unUsedAccessory[tankID] = {}
                end
                if(self.unUsedAccessory[tankID][partID] == nil)then
                    self.unusedNeedRefresh = true
                    equipRefreshFlag = true
                    if(self.unusedNum == nil)then
                        self.unusedNum = 1
                    else
                        self.unusedNum = self.unusedNum + 1
                    end
                    self.unUsedAccessory[tankID][partID] = aVo
                end
            end
            
            --发送刷屏消息
            -- local quality = aVo:getConfigData("quality")
            -- if(quality == 3 or quality == 4 or quality == 5)then
            --     -- local fullname=getlocal("accessory_quality_"..quality,{getlocal(aVo:getConfigData("name"))})
            --     -- chatVoApi:sendSystemMessage(getlocal("accessory_chat_msg_1",{playerVoApi:getPlayerName(),fullname}))
            --     local fullname = {key = "accessory_quality_"..quality, param = {key = aVo:getConfigData("name"), param = {}}}
            --     local message = {key = "accessory_chat_msg_1", param = {playerVoApi:getPlayerName(), fullname}}
            --     chatVoApi:sendSystemMessage(message)
            -- end
        end
        if(equipRefreshFlag)then
            table.insert(eventData, 4)
        end
        self:sort(1)
        table.insert(eventData, 4)
        eventDispatcher:dispatchEvent("accessory.data.refresh", {type = eventData})
    end
end

--是否有强化5级或以上的配件，钢铁之心活动用
function accessoryVoApi:getAccessoryMaxLevel()
    local maxLevel = 0
    if self.abag then
        for k, v in pairs(self.abag) do
            if v and v.lv then
                if maxLevel < v.lv then
                    maxLevel = v.lv
                end
            end
        end
    end
    if self.equip then
        for k, v in pairs(self.equip) do
            if v then
                for m, n in pairs(v) do
                    if n and n.lv then
                        if maxLevel < n.lv then
                            maxLevel = n.lv
                        end
                    end
                end
            end
        end
    end
    return maxLevel
end

--精英关卡数据
--精英关卡配置
function accessoryVoApi:getEChallengeCfg()
    local echallengeCfg = {}
    local ecMaxUnlock = playerVoApi:getMaxLvByKey("unlockEliteChallenge")
    if ecMaxUnlock and tonumber(ecMaxUnlock) then
        for k, v in pairs(eliteChallengeCfg) do
            if k == "challenge" then
                for m, n in pairs(v) do
                    local id = (tonumber(m) or tonumber(RemoveFirstChar(m)))
                    if id <= tonumber(ecMaxUnlock) then
                        if echallengeCfg[k] == nil then
                            echallengeCfg[k] = {}
                        end
                        echallengeCfg[k][m] = n
                    end
                end
            else
                echallengeCfg[k] = v
            end
        end
    else
        echallengeCfg = eliteChallengeCfg
    end
    return echallengeCfg
end
--关卡详细配置
function accessoryVoApi:getECCfg()
    local echallengeCfg = self:getEChallengeCfg()
    return echallengeCfg.challenge
end

function accessoryVoApi:getFlag()
    return self.flag
end
function accessoryVoApi:setFlag(flag)
    self.flag = flag
end

function accessoryVoApi:getAbagLeftNum()
    return self.abagLeftNum
end
function accessoryVoApi:setAbagLeftNum(abagLeftNum)
    if abagLeftNum then
        self.abagLeftNum = abagLeftNum
    else
        self.abagLeftNum = self.abagLeftNum - 1
        if self.abagLeftNum <= 0 then
            self.abagLeftNum = 0
        end
    end
end
function accessoryVoApi:getFbagLeftNum()
    return self.fbagLeftNum
end
function accessoryVoApi:setFbagLeftNum(fbagLeftNum)
    if fbagLeftNum then
        self.fbagLeftNum = fbagLeftNum
    else
        self.fbagLeftNum = self.fbagLeftNum - 1
        if self.fbagLeftNum <= 0 then
            self.fbagLeftNum = 0
        end
    end
end

--配件背包是否已满
function accessoryVoApi:isAbagFull(count, accessoryId)
    local leftNum = self:getAbagLeftNum()
    if leftNum < count then
        return true, leftNum
    end
    return false, leftNum
end
--配件碎片背包是否已满
function accessoryVoApi:isFbagFull(count, fragmentId)
    local leftNum = self:getFbagLeftNum()
    if fragmentId then
        local fVo = self:getFragmentByID(fragmentId)
        if fVo then
            return false, leftNum
        end
    end
    if leftNum < count then
        return true, leftNum
    end
    return false, leftNum
end

function accessoryVoApi:getECVo()
    if self.ecVo == nil then
        self.ecVo = eliteChallengeVo:new()
        self.ecVo:updateData({})
    end
    return self.ecVo
end

--初始化关卡
function accessoryVoApi:formatECData(data)
    if data then
        if data.echallenge then
            if self.ecVo == nil then
                self.ecVo = eliteChallengeVo:new()
            end
            self.ecVo:updateData(data.echallenge)
            self.isInitEC = true
        end
        if data.space then
            self.abagLeftNum = data.space[1] or 0
            self.fbagLeftNum = data.space[2] or 0
        end
    end
end

--今日是否重置过
function accessoryVoApi:isToday()
    local ecVo = self:getECVo()
    if ecVo then
        local lastTs = ecVo.lastResetTime or 0 --上一次重置时间
        return G_isToday(lastTs)
    end
    return true
end

--今日最大重置次数
function accessoryVoApi:getResetMaxNum()
    local cfg = self:getEChallengeCfg()
    local resetTab = cfg.resetNum
    local vipLevel = playerVoApi:getVipLevel()
    local maxResetNum = resetTab[vipLevel + 1]
    return maxResetNum
end

--今日已经重置次数
function accessoryVoApi:getUsedResetNum()
    local ecVo = self:getECVo()
    local usedResetNum = ecVo.resetnum or 0 --已重置次数
    local lastTs = ecVo.lastResetTime or 0 --上一次重置时间
    if G_isToday(lastTs) == false then
        usedResetNum = 0
    end
    return usedResetNum
end
--今日剩余重置次数
function accessoryVoApi:getLeftResetNum()
    local usedResetNum = self:getUsedResetNum() --已重置次数
    local maxResetNum = self:getResetMaxNum()
    local resetNum = maxResetNum - usedResetNum
    return resetNum
end

--是否能攻打关卡
function accessoryVoApi:isUnlock(id)
    if id then
        local ecCfg = self:getECCfg()
        local needLv = ecCfg["s"..id].unlockLv
        local playerLv = playerVoApi:getPlayerLevel()
        local ecVo = self:getECVo()
        if playerLv >= needLv then
            local completeId = SizeOfTable(ecVo.info) --之前已经打通关的关卡id
            local unlockId = completeId + 1
            if unlockId > SizeOfTable(ecCfg) then
                unlockId = SizeOfTable(ecCfg)
            end
            if unlockId >= id then
                return true
            end
        end
    end
    return false
end
--第一次扫荡需要消耗能量,能量是否足够
function accessoryVoApi:energyIsEnough()
    local usedResetNum = self:getUsedResetNum()
    local energy = playerVoApi:getEnergy()
    if usedResetNum == 0 then
        if energy > 0 then
            return true
        end
    else
        return true
    end
    return false
end
--已经击杀的关卡
function accessoryVoApi:getDailykill()
    local ecVo = self:getECVo()
    local dailykill = {}
    local lastTs = ecVo.lastResetTime or 0 --上一次重置时间
    if G_isToday(lastTs) == true then
        dailykill = ecVo.dailykill or {}
    end
    return dailykill
end
--是否已经击杀关卡
function accessoryVoApi:isKill(id)
    local isKill = false
    if id then
        local dailykill = accessoryVoApi:getDailykill()
        for k, v in pairs(dailykill) do
            local key = (tonumber(k) or tonumber(RemoveFirstChar(k)))
            if key and key == tonumber(id) and tonumber(v) == 1 then
                isKill = true
            end
        end
    end
    return isKill
end
--是否能攻打关卡 0：可以，1：能量不足，2：仓库不足，3：关卡已经被击杀，4：关卡未解锁，5.没有数据id
function accessoryVoApi:canAttack(id)
    local canAttack = 5
    if id then
        canAttack = 0
        local ecVo = self:getECVo()
        local isKill = self:isKill(id)
        local isUnlock = self:isUnlock(id)
        if isUnlock == false then
            canAttack = 4
        elseif isKill == true then
            canAttack = 3
        elseif self:bagIsFull(id) == false then
            canAttack = 2
        elseif self:energyIsEnough() == false then
            canAttack = 1
        end
    end
    return canAttack
end

function accessoryVoApi:setECNum(ecNum)
    self.ecNum = ecNum
end
--可以攻击的关卡数量
function accessoryVoApi:getLeftECNum()
    local ecCfg = accessoryVoApi:getECCfg()
    local leftNum = 0
    if self.isInitEC == true then
        local dailykill = accessoryVoApi:getDailykill()
        for k, v in pairs(ecCfg) do
            local id = (tonumber(k) or tonumber(RemoveFirstChar(k)))
            if dailykill and dailykill[k] and dailykill[k] == 1 then
            else
                if self:isUnlock(id) then
                    leftNum = leftNum + 1
                end
            end
        end
        if leftNum > SizeOfTable(ecCfg) then
            leftNum = SizeOfTable(ecCfg)
        end
    else
        leftNum = self.ecNum
    end
    return leftNum
end
--未通关的3星关卡
function accessoryVoApi:getLeft3Star()
    local left3Star = {}
    local ecVo = self:getECVo()
    local dailykill = accessoryVoApi:getDailykill()
    for k, v in pairs(ecVo.info) do
        if v and v == 3 then
            if dailykill and dailykill["s"..k] and dailykill["s"..k] == 1 then
            else
                table.insert(left3Star, k)
            end
        end
    end
    return left3Star
end
--是否能扫荡关卡 0：可以，1：vip等级不够，2：没有剩余的3星关卡，3：仓库不足，4：能量不足
function accessoryVoApi:canRaid()
    local canRaid = 0
    local needVipLevel = 0
    local vipPrivilegeSwitch = base.vipPrivilegeSwitch or {}
    local vipRelatedCfg = playerCfg.vipRelatedCfg or {}
    local raidEliteChallenge = vipRelatedCfg.raidEliteChallenge or {}
    --精英副本扫荡
    if vipPrivilegeSwitch and vipPrivilegeSwitch.vec == 1 and raidEliteChallenge and raidEliteChallenge[1] then
        -- local cfg=accessoryVoApi:getEChallengeCfg()
        local vipLevel = playerVoApi:getVipLevel()
        local left3Star = self:getLeft3Star()
        needVipLevel = raidEliteChallenge[1] or 0
        if vipLevel < needVipLevel then
            canRaid = 1
        elseif SizeOfTable(left3Star) <= 0 then
            canRaid = 2
        elseif self:bagIsFull() == false then
            canRaid = 3
        elseif self:energyIsEnough() == false then
            canRaid = 4
        end
    else
        canRaid = 5
    end
    return canRaid, needVipLevel
end
--判断仓库空间是否足够
function accessoryVoApi:bagIsFull(id)
    local cfg = accessoryVoApi:getECCfg()
    local leftABagNum = self:getABagLeftGrid()
    local leftFBagNum = self:getFBagLeftGrid()
    local aDropMaxNum = 0
    local fDropTypeMaxNum = 0
    if id then--攻击，某一关卡
        local ecCfg = cfg["s"..id]
        if ecCfg then
            aDropMaxNum = ecCfg.aDropMaxNum
            fDropTypeMaxNum = ecCfg.fDropTypeMaxNum
        end
        if (leftABagNum and leftABagNum - aDropMaxNum < 0) or (leftFBagNum and leftFBagNum - fDropTypeMaxNum < 0) then
            return false
        end
    else --扫荡
        local left3Star = self:getLeft3Star()
        for k, v in pairs(left3Star) do
            local ecCfg = cfg["s"..v]
            if ecCfg then
                aDropMaxNum = ecCfg.aDropMaxNum
                fDropTypeMaxNum = ecCfg.fDropTypeMaxNum
            end
            if (leftABagNum and leftABagNum - aDropMaxNum < 0) or (leftFBagNum and leftFBagNum - fDropTypeMaxNum < 0) then
                return false
            end
        end
    end
    return true
end
--关卡是否掉落碎片 1:蓝色 2:蓝色和紫色
function accessoryVoApi:dropFragment(id)
    if id >= 12 then
        return 2
    elseif id >= 7 then
        return 1
    end
    return 0
end
--重置关卡数据
function accessoryVoApi:resetData(lastTime)
    local ecVo = self:getECVo()
    ecVo.dailykill = {}
    ecVo.resetnum = ecVo.resetnum + 1
    if lastTime then
        ecVo.lastResetTime = lastTime
    else
        ecVo.lastResetTime = base.serverTime
    end
end
--隔日重置关卡数据
function accessoryVoApi:resetECData()
    local ecVo = self:getECVo()
    ecVo.dailykill = {}
    ecVo.resetnum = 0
    ecVo.lastResetTime = base.serverTime
end
--攻击关卡更新数据
function accessoryVoApi:attackUpdate(id, star)
    if id and star then
        local ecVo = self:getECVo()
        if ecVo.info then
            if ecVo.info[id] == nil or (ecVo.info[id] and ecVo.info[id] < star) then
                if (ecVo.info[id] and ecVo.info[id] < star) then
                    local diffStar = star - ecVo.info[id]
                    ecVo.totalStar = ecVo.totalStar + diffStar
                end
                ecVo.info[id] = star
            end
        end
        ecVo.dailykill["s"..id] = 1
    end
end
--扫荡关卡更新数据
function accessoryVoApi:raidUpdate(raidReward)
    local left3Star = self:getLeft3Star()
    local ecVo = self:getECVo()
    local usedResetNum = self:getUsedResetNum()
    local energy = playerVoApi:getEnergy()
    
    local raidNum = 0
    if raidReward then
        raidNum = SizeOfTable(raidReward)
    end
    local isFull = false
    local eIsEnough = true
    local rewardTab = {}
    for k, v in pairs(raidReward) do
        local key = (tonumber(k) or tonumber(RemoveFirstChar(k)))
        if tonumber(v) and tonumber(v) < 0 then
            isFull = true
            raidNum = raidNum - 1
        else
            if v and type(v) == "table" then
                local awardTab = FormatItem(v)
                if awardTab and SizeOfTable(awardTab) > 0 then
                    for m, n in pairs(awardTab) do
                        G_addPlayerAward(n.type, n.key, n.id, n.num)
                    end
                end
                table.insert(rewardTab, {id = key, awardTab = awardTab})
                ecVo.dailykill[k] = 1
            end
        end
    end
    local function sortAsc(a, b)
        if a and b and a.id and b.id then
            return a.id < b.id
        end
    end
    table.sort(rewardTab, sortAsc)
    if usedResetNum == 0 then
        if energy > 0 then
            if energy >= raidNum then
                playerVoApi:setValue("energy", energy - raidNum)
                if energy == raidNum and raidNum < SizeOfTable(left3Star) then
                    eIsEnough = false
                end
            else
                playerVoApi:setValue("energy", 0)
            end
            if(playerVoApi:getPlayerEnergycd() == 0)then
                playerVoApi:setValue("energycd", raidNum * 1800)
            end
        end
    end
    return rewardTab, eIsEnough, isFull
end

--关卡掉落描述
function accessoryVoApi:eChallengeTipStr(ecId)
    local ecCfg = self:getECCfg()
    local propbonus = ecCfg["s"..ecId].propbonus
    local dropData = propbonus[3]
    
    local aData = {{}, {}, {}, {}}
    local fData = {{}, {}, {}, {}}
    local pData = {}
    
    for k, v in pairs(dropData) do
        if v and v[1] then
            local id = Split(v[1], "_")[2]
            if id then
                local eType = string.sub(id, 1, 1)
                if eType then
                    if eType == "a" then
                        local aCfg = accessoryCfg.aCfg[id]
                        local quality = tonumber(aCfg.quality)
                        local tankType = tonumber(aCfg.tankID)
                        aData[quality][tankType] = tankType
                    elseif eType == "f" then
                        local fCfg = accessoryCfg.fragmentCfg[id]
                        local quality = tonumber(fCfg.quality)
                        local output = fCfg.output
                        if output and output ~= "" then
                            local aCfg = accessoryCfg.aCfg[output]
                            local tankType = tonumber(aCfg.tankID)
                            fData[quality][tankType] = tankType
                        end
                    elseif eType == "p" then
                        local pid = (tonumber(id) or tonumber(RemoveFirstChar(id)))
                        pData[pid] = id
                    end
                end
                
            end
            
        end
    end
    local tipStrData = {fData, aData, pData}
    return tipStrData
end

--根据品阶获得颜色
function accessoryVoApi:getColorByQuality(quality)
    local color = G_ColorWhite
    if quality then
        if tonumber(quality) == 1 then
            color = G_ColorGreen
        elseif tonumber(quality) == 2 then
            color = G_ColorBlue
        elseif tonumber(quality) == 3 then
            color = G_ColorPurple
        elseif tonumber(quality) == 4 then
            color = G_ColorOrange
        elseif tonumber(quality) == 5 then
            color = G_ColorRed
        end
    end
    return color
end

--获取用户所拥有的所有材料道具的数目
function accessoryVoApi:getPropNums()
    for pid, cfg in pairs(accessoryCfg.propCfg) do
        if(self.props[pid] == nil)then
            self.props[pid] = 0
        end
    end
    return self.props
end

--获取强化符的数目
function accessoryVoApi:getUpgradeProp()
    return self.props["p6"] or 0
end

--获取拥有的精炼保级符的数目
function accessoryVoApi:getSmeltProp()
    return self.props["p5"] or 0
end

--获取熔炼核心的数目
function accessoryVoApi:getEvolutionProp()
    return self.props["p7"] or 0
end

--获取用户所拥有的用于商店兑换道具的数目
--return 一个table, table的key是道具的id, value是数目
function accessoryVoApi:getShopPropNum()
    local shopProps = {}
    for i = 8, 10 do
        local pid = "p"..i
        if(self.props[pid])then
            shopProps[pid] = self.props[pid]
        else
            shopProps[pid] = 0
        end
    end
    return shopProps
end

-- 改变晶体的值
function accessoryVoApi:setShopPropNum(propNum)
    self.props.p8 = propNum[1]
    self.props.p9 = propNum[2]
    self.props.p10 = propNum[3]
    eventDispatcher:dispatchEvent("accessory.data.refresh", {type = {3}})
end

--vip 强化成功几率增加
function accessoryVoApi:getVipUpgradeAddRate()
    local addRate = 0
    local vipPrivilegeSwitch = base.vipPrivilegeSwitch
    if vipPrivilegeSwitch and vipPrivilegeSwitch.vea == 1 and playerCfg.vipForEquipStrengthenRate then
        local vipLevel = playerVoApi:getVipLevel()
        addRate = playerCfg.vipForEquipStrengthenRate[vipLevel + 1]
    end
    --三周活动七重福利所加的buff
    local threeYearAdd = 0
    if acThreeYearVoApi then
        threeYearAdd = acThreeYearVoApi:getBuffAdded(4)
    end
    local pjgxAdd = 0
    if acPjgxVoApi then
        pjgxAdd = acPjgxVoApi:addBuffScuess("pjgx")
    end
    addRate = addRate + threeYearAdd + pjgxAdd
    return addRate
end

--根据等级获取该等级解锁到第几号配件位
--param lv: 玩家的等级
--return 一个数字, 玩家解锁到的最大配件位 (0~8, 0表示没有一个配件位都没有解锁)
function accessoryVoApi:getUnlockPartByLv(lv)
    local partLength = #accessoryCfg.partUnlockLv
    local partID
    for i = 1, partLength do
        if(accessoryCfg.partUnlockLv[i] > lv)then
            partID = i - 1
            break
        end
    end
    if(partID == nil)then
        partID = partLength
    end
    return partID
end

--获取当前版本开放的科技个数
function accessoryVoApi:getUnlockTechNum()
    return 4
end

--科技技能能达到的最大等级
function accessoryVoApi:getTechSkillMaxLv()
    return tonumber(playerVoApi:getMaxLvByKey("unlockAccTechSkillLv"))
end

--科技能达到的最大等级
function accessoryVoApi:getTechMaxLv()
    return tonumber(playerVoApi:getMaxLvByKey("unlockAccTechUpgradeLv"))
end

--配件突破
--param tankID,partID: 要突破的配件部位
function accessoryVoApi:evolution(tankID, partID, callback, stayLv)
    local costGems = 0
    local aVo1
    if(tankID ~= nil and partID ~= nil)then
        if(self.equip ~= nil and self.equip["t"..tankID] ~= nil)then
            aVo1 = self.equip["t"..tankID]["p"..partID]
            if stayLv and stayLv == 1 then
                costGems = self:stayLvCostGems(aVo1.rank) or 0
            end
        end
    end
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret ~= true or sData.data.accessory == nil)then
            self.dataNeedRefresh = true
            do return end
        end
        if costGems and costGems > 0 then
            playerVoApi:setGems(playerVoApi:getGems() - costGems)
        end
        if sData.data.accessory ~= nil then
            if sData.data.accessory.m_exp then
                self.succinct_exp = sData.data.accessory.m_exp
            end
            if sData.data.accessory.m_level then
                self.succinct_level = sData.data.accessory.m_level
            end
        end
        if(sData.data.accessory.props ~= nil)then
            self.props = {}
            for k, v in pairs(sData.data.accessory.props) do
                self.props[k] = tonumber(v)
            end
        end
        if(sData.data.accessory.fragment ~= nil)then
            self.fbag = nil
            self.fbag = {}
            for k, v in pairs(sData.data.accessory.fragment) do
                local fVo = accessoryFragmentVo:new()
                fVo:initWithData({id = k, num = v})
                table.insert(self.fbag, fVo)
            end
            self:sort(2)
        end
        if(sData.data.accessory.used ~= nil)then
            self.equip = {t1 = {}, t2 = {}, t3 = {}, t4 = {}}
            for tid, tank in pairs(sData.data.accessory.used) do
                for part, acc in pairs(tank) do
                    local aVo = accessoryVo:new()
                    aVo:initWithData(acc)
                    self.equip[tid][part] = aVo
                end
            end
        end
        if(sData.data.reward)then
            local reward = FormatItem(sData.data.reward)
            for k, v in pairs(reward) do
                G_addPlayerAward(v.type, v.key, v.id, v.num)
            end
        end
        eventDispatcher:dispatchEvent("accessory.data.refresh", {type = {2, 3, 4}})
        if(callback ~= nil)then
            callback()
        end
    end
    socketHelper:acessoryEvolution("t"..tankID, "p"..partID, onRequestEnd, stayLv)
end

--配件商店兑换
--param id: 要兑换的商品ID
function accessoryVoApi:buy(id,callback,num)
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret ~= true or sData.data.accessory == nil)then
            self.dataNeedRefresh = true
            do return end
        end
        if sData.data.accessory ~= nil then
            if sData.data.accessory.m_exp then
                self.succinct_exp = sData.data.accessory.m_exp
            end
            if sData.data.accessory.m_level then
                self.succinct_level = sData.data.accessory.m_level
            end
        end
        local eventData = {}
        if(sData.data.accessory.info ~= nil)then
            self.abag = nil
            self.abag = {}
            for k, v in pairs(sData.data.accessory.info) do
                local aVo = accessoryVo:new()
                aVo:initWithData(v)
                aVo.id = k
                table.insert(self.abag, aVo)
                
                local tankID = "t"..aVo:getConfigData("tankID")
                local partID = "p"..aVo:getConfigData("part")
                if(self.equip[tankID] == nil or self.equip[tankID][partID] == nil)then
                    if(self.unUsedAccessory[tankID] == nil)then
                        self.unUsedAccessory[tankID] = {}
                    end
                    if(self.unUsedAccessory[tankID][partID] == nil)then
                        self.unusedNum = self.unusedNum + 1
                        self.unUsedAccessory[tankID][partID] = aVo
                    end
                end
            end
            self:sort(1)
            table.insert(eventData, 1)
        end
        if(sData.data.accessory.fragment ~= nil)then
            self.fbag = nil
            self.fbag = {}
            for k, v in pairs(sData.data.accessory.fragment) do
                local fVo = accessoryFragmentVo:new()
                fVo:initWithData({id = k, num = v})
                table.insert(self.fbag, fVo)
            end
            self:sort(2)
            table.insert(eventData, 2)
        end
        if(sData.data.accessory.props ~= nil)then
            self.props = {}
            for k, v in pairs(sData.data.accessory.props) do
                self.props[k] = tonumber(v)
            end
            table.insert(eventData, 3)
        end
        local costGems = accessoryCfg.shopItems[id].gems
        playerVoApi:setGems(playerVoApi:getGems() - costGems*num)
        --兑换的是高品质的玩意, 发聊天刷屏
        -- local rewardTb = FormatItem(accessoryCfg.shopItems[id].reward)
        -- for k, v in pairs(rewardTb) do
        --     if(v.type == "e")then
        --         if(v.eType == "a")then
        --             if(accessoryCfg.aCfg[v.id].quality > 2)then
        --                 local fullname = {key = "accessory_quality_"..accessoryCfg.aCfg[v.id].quality, param = {key = accessoryCfg.aCfg[v.id].name, param = {}}}
        --                 local message = {key = "accessory_chat_msg_1", param = {playerVoApi:getPlayerName(), fullname}}
        --                 chatVoApi:sendSystemMessage(message)
        --             end
        --         elseif(v.eType == "f")then
        --             if(accessoryCfg.fragmentCfg[v.id].quality > 2)then
        --                 local fullname = {key = "accessory_quality_"..accessoryCfg.fragmentCfg[v.id].quality, param = {key = accessoryCfg.fragmentCfg[v.id].name, param = {}}}
        --                 local message = {key = "accessory_chat_msg_1", param = {playerVoApi:getPlayerName(), fullname}}
        --                 chatVoApi:sendSystemMessage(message)
        --             end
        --         end
        --     end
        -- end
        eventDispatcher:dispatchEvent("accessory.data.refresh", {type = eventData})
        if(callback ~= nil)then
            callback()
        end
    end
    socketHelper:accessoryBuy(id,onRequestEnd,num)
end

--碎片批量合成
function accessoryVoApi:bulkCompose(callback)
    local leftGrid = self:getABagLeftGrid()
    if(leftGrid <= 0)then
        return 1;
    end
    local idTb = {};
    for k, fVo in pairs(self.fbag) do
        if(fVo:getConfigData("quality") < 4 and fVo.num >= fVo:getConfigData("composeNum"))then
            local composeNum = math.floor(fVo.num / fVo:getConfigData("composeNum"))
            for i = 1, composeNum do
                table.insert(idTb, fVo.id);
            end
        end
    end
    local length = #idTb
    if(length == 0)then
        return 2;
    end
    if(length > leftGrid)then
        local tmp = {}
        for i = 1, leftGrid do
            tmp[i] = idTb[i]
        end
        idTb = tmp
    end
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret ~= true or sData.data.accessory == nil or sData.data.accessory.info == nil)then
            self.dataNeedRefresh = true
            do return end
        end
        if sData.data.accessory ~= nil then
            if sData.data.accessory.m_exp then
                self.succinct_exp = sData.data.accessory.m_exp
            end
            if sData.data.accessory.m_level then
                self.succinct_level = sData.data.accessory.m_level
            end
        end
        if(self.unUsedAccessory == nil)then
            self.unUsedAccessory = {}
        end
        local equipRefreshFlag = false
        for k, v in pairs(sData.data.accessory.info) do
            local aVo = accessoryVo:new()
            aVo:initWithData(v)
            aVo.id = k
            table.insert(self.abag, aVo)
            
            local tankID = "t"..aVo:getConfigData("tankID")
            local partID = "p"..aVo:getConfigData("part")
            if(self.equip[tankID] == nil or self.equip[tankID][partID] == nil)then
                self.unusedNeedRefresh = true
                if(self.unUsedAccessory[tankID] == nil)then
                    self.unUsedAccessory[tankID] = {}
                end
                if(self.unUsedAccessory[tankID][partID] == nil)then
                    if(self.unusedNum == nil)then
                        self.unusedNum = 1
                    else
                        self.unusedNum = self.unusedNum + 1
                    end
                    self.unUsedAccessory[tankID][partID] = aVo
                    equipRefreshFlag = true
                end
            end
            --发送刷屏消息
            -- local quality = aVo:getConfigData("quality")
            -- if(quality == 3 or quality == 4 or quality == 5)then
            --     local fullname = {key = "accessory_quality_"..quality, param = {key = aVo:getConfigData("name"), param = {}}}
            --     local message = {key = "accessory_chat_msg_1", param = {playerVoApi:getPlayerName(), fullname}}
            --     chatVoApi:sendSystemMessage(message)
            -- end
        end
        local eventData = {}
        if(equipRefreshFlag)then
            table.insert(eventData, 4)
        end
        if(sData.data.accessory.fragment ~= nil)then
            self.fbag = nil
            self.fbag = {}
            for k, v in pairs(sData.data.accessory.fragment) do
                local fVo = accessoryFragmentVo:new()
                fVo:initWithData({id = k, num = v})
                table.insert(self.fbag, fVo)
            end
        end
        self:sort()
        table.insert(eventData, 1)
        table.insert(eventData, 2)
        eventDispatcher:dispatchEvent("accessory.data.refresh", {type = eventData})
        if(callback)then
            callback()
        end
    end
    socketHelper:accessoryBulkCompose(idTb, onRequestEnd)
    return 0
end

--科技升级
--param tankID,partID: 进行升级操作的配件部位
--param techID: 要升级哪个科技
function accessoryVoApi:techUpgrade(tankID, partID, techID, callback)
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret ~= true or sData.data.accessory == nil)then
            self.dataNeedRefresh = true
            do return end
        end
        local aVo = accessoryVoApi:getAccessoryByPart(tankID, partID)
        local props = accessoryVoApi:getTechChangeProp(aVo, techID)
        for k, v in pairs(props) do
            if(v.type == "p")then
                local id = (tonumber(v.key) or tonumber(RemoveFirstChar(v.key)))
                bagVoApi:useItemNumId(id, v.num)
            end
        end
        local eventData = {}
        if(sData.data.accessory.used ~= nil)then
            self.equip = {t1 = {}, t2 = {}, t3 = {}, t4 = {}}
            for tid, tank in pairs(sData.data.accessory.used) do
                self.equip[tid] = {}
                for part, acc in pairs(tank) do
                    local aVo = accessoryVo:new()
                    aVo:initWithData(acc)
                    self.equip[tid][part] = aVo
                end
            end
            table.insert(eventData, 4)
        end
        if(sData.data.accessory.fragment ~= nil)then
            self.fbag = nil
            self.fbag = {}
            for k, v in pairs(sData.data.accessory.fragment) do
                local fVo = accessoryFragmentVo:new()
                fVo:initWithData({id = k, num = v})
                table.insert(self.fbag, fVo)
            end
            table.insert(eventData, 2)
        end
        if(sData.data.accessory.props ~= nil)then
            self.props = {}
            for k, v in pairs(sData.data.accessory.props) do
                self.props[k] = tonumber(v)
            end
            table.insert(eventData, 3)
        end
        eventDispatcher:dispatchEvent("accessory.data.refresh", {type = eventData})
        if(callback)then
            callback()
        end
    end
    socketHelper:acessoryTechUpgrade("t"..tankID, "p"..partID, techID, onRequestEnd)
end

--科技更换
--param tankID,partID: 进行更换操作的配件部位
--param techID: 要更换到哪个科技
function accessoryVoApi:techChange(tankID, partID, techID, callback)
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret ~= true or sData.data.accessory == nil)then
            self.dataNeedRefresh = true
            do return end
        end
        local aVo = accessoryVoApi:getAccessoryByPart(tankID, partID)
        local props = accessoryVoApi:getTechChangeProp(aVo, techID)
        for k, v in pairs(props) do
            if(v.type == "p")then
                local id = (tonumber(v.key) or tonumber(RemoveFirstChar(v.key)))
                bagVoApi:useItemNumId(id, v.num)
            end
        end
        local eventData = {}
        if(sData.data.accessory.used ~= nil)then
            self.equip = {t1 = {}, t2 = {}, t3 = {}, t4 = {}}
            for tid, tank in pairs(sData.data.accessory.used) do
                self.equip[tid] = {}
                for part, acc in pairs(tank) do
                    local aVo = accessoryVo:new()
                    aVo:initWithData(acc)
                    self.equip[tid][part] = aVo
                end
            end
            table.insert(eventData, 4)
        end
        if(sData.data.accessory.fragment ~= nil)then
            self.fbag = nil
            self.fbag = {}
            for k, v in pairs(sData.data.accessory.fragment) do
                local fVo = accessoryFragmentVo:new()
                fVo:initWithData({id = k, num = v})
                table.insert(self.fbag, fVo)
            end
            table.insert(eventData, 2)
        end
        if(sData.data.accessory.props ~= nil)then
            self.props = {}
            for k, v in pairs(sData.data.accessory.props) do
                self.props[k] = tonumber(v)
            end
            table.insert(eventData, 3)
        end
        eventDispatcher:dispatchEvent("accessory.data.refresh", {type = eventData})
        if(callback)then
            callback()
        end
    end
    socketHelper:acessoryTechChange("t"..tankID, "p"..partID, techID, onRequestEnd)
end

function accessoryVoApi:succinctIsOpen()
    if accessoryCfg.unLockPart == 8 and base.alien == 1 and playerVoApi:getPlayerLevel() >= 50 and base.succinct == 1 then
        return true
    end
    return false
end

function accessoryVoApi:switchIsOpen()
    if accessoryCfg.unLockPart == 8 and base.alien == 1 and base.succinct == 1 then
        return true
    end
    return false
end

-- 检查某一配件的数量（身上和背包）
function accessoryVoApi:checkAccesoryNum(type)
    local num = 0
    for k, v in pairs(self.abag) do
        if tostring(v.type) == tostring(type) then
            num = num + 1
        end
    end
    for k, v in pairs(self.equip) do
        for kk, vv in pairs(v) do
            if tostring(vv.type) == tostring(type) then
                num = num + 1
            end
        end
    end
    return num
end

-- 选择赠送好友配件页面
function accessoryVoApi:showSelectAccessoryDialog(layerNum, selectFriendTb)
    
    local function callback()
        
        require "luascript/script/game/scene/gamedialog/activityAndNote/acSendAccessorySmallDialog"
        local sd = acSendAccessorySmallDialog:new(layerNum + 1, selectFriendTb)
        local dialog = sd:init()
        -- dialog:setPosition(G_VisibleSizeWidth/2, G_VisibleSizeHeight/2)
        -- sceneGame:addChild(dialog,layerNum + 1)
        
    end
    if(self.dataNeedRefresh == true)then
        self:refreshData(callback)
    else
        callback()
    end
end

function accessoryVoApi:sendAccessory(fuid, id, callback)
    self.sendAccessoryCallback = callback
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret ~= true or sData.data.accessory == nil)then
            self.dataNeedRefresh = true
            do return end
        end
        if sData.data.accessory ~= nil then
            if sData.data.accessory.m_exp then
                self.succinct_exp = sData.data.accessory.m_exp
            end
            if sData.data.accessory.m_level then
                self.succinct_level = sData.data.accessory.m_level
            end
        end
        local award = FormatItem(sData.data.reward) or {}
        for k, v in pairs(award) do
            G_addPlayerAward(v.type, v.key, v.id, v.num)
        end
        
        self.unUsedAccessory = {}
        self.unusedNum = 0
        self.unusedNeedRefresh = true
        local eventData = {}
        if(sData.data.accessory.info ~= nil)then
            self.abag = nil
            self.abag = {}
            for k, v in pairs(sData.data.accessory.info) do
                local aVo = accessoryVo:new()
                aVo:initWithData(v)
                aVo.id = k
                table.insert(self.abag, aVo)
                
                local tankID = "t"..aVo:getConfigData("tankID")
                local partID = "p"..aVo:getConfigData("part")
                if(self.equip[tankID] == nil or self.equip[tankID][partID] == nil)then
                    if(self.unUsedAccessory[tankID] == nil)then
                        self.unUsedAccessory[tankID] = {}
                    end
                    if(self.unUsedAccessory[tankID][partID] == nil)then
                        self.unusedNum = self.unusedNum + 1
                        self.unUsedAccessory[tankID][partID] = aVo
                    end
                end
            end
            self:sort(1)
            table.insert(eventData, 1)
        end
        table.insert(eventData, 4)
        local getReward = {}
        if(sData.data.reward ~= nil and sData.data.reward.u ~= nil and sData.data.reward.u.gold ~= nil)then
            getReward.resource = sData.data.reward.u.gold
        end
        local oldProps = {}
        for pid, num in pairs(self.props) do
            oldProps[pid] = num
        end
        if(sData.data.accessory.props ~= nil)then
            self.props = {}
            for k, v in pairs(sData.data.accessory.props) do
                self.props[k] = tonumber(v)
            end
            table.insert(eventData, 3)
        end
        for k, v in pairs(self.props) do
            if(oldProps[k] ~= nil)then
                local add = v - oldProps[k]
                if(add > 0)then
                    getReward[k] = add
                end
            else
                getReward[k] = v
            end
        end
        eventDispatcher:dispatchEvent("accessory.data.refresh", {type = eventData})
        if(self.sendAccessoryCallback ~= nil)then
            self.sendAccessoryCallback(getReward)
            self.sendAccessoryCallback = nil
        end
    end
    socketHelper:acPeijianhuzengSendAccessory(fuid, id, onRequestEnd)
end

-- 得到配件，无强化，改造等级
function accessoryVoApi:getAccesoryWithoutJiagong()
    local aData = self:getAccessoryBag()
    local sbData = {}
    local qualityTb = accessoryCfg.qualityTb
    if aData == nil then
        aData = {}
    end
    local num = SizeOfTable(aData)
    for i = 1, num do
        local aVo = aData[i]
        local flag
        if aVo.lv > 0 or aVo.rank > 0 then
            flag = false
        else
            flag = true
        end
        if flag then
            local gsadd = aVo:getGsAdd()
            if gsadd ~= 0 then
                flag = false
            end
        end
        if flag then
            local quality = aVo:getConfigData("quality")
            for k, v in pairs(qualityTb) do
                if quality == v then
                    table.insert(sbData, aVo)
                    break
                end
            end
        end
    end
    return sbData
end

--配件道具合成新道具
--param pid: 道具ID
--param count: 要合成的数目
function accessoryVoApi:composeProp(pid, count, callback)
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data and sData.data.accessory then
                if(sData.data.accessory.props ~= nil)then
                    self.props = {}
                    for k, v in pairs(sData.data.accessory.props) do
                        self.props[k] = tonumber(v)
                    end
                    eventDispatcher:dispatchEvent("accessory.data.refresh", {type = {3}})
                end
                if(callback ~= nil)then
                    callback()
                end
            end
        end
    end
    socketHelper:accessoryComposeProp(count, onRequestEnd)
end

--检测某个部位的配件是否可以绑定
--param partID,tankID: 部位
--return 0: 可以绑定
--return 1: 该部位没有配件
--return 2: 不是紫色以上的配件不能绑定
--return 3: 背包中有品质更高或者更强的配件（更强的概念：同品质下判断改造等级，同改造下判断强化等级）
--return 4: 该位置的配件已经绑定了
--return 5: 功能没开
function accessoryVoApi:checkCanBind(tankID, partID)
    if(base.accessoryBind ~= 1)then
        return 5
    end
    local tankID = "t"..tankID
    local partID = "p"..partID
    if(self.equip[tankID] == nil or self.equip[tankID][partID] == nil)then
        return 1
    end
    local aVo = self.equip[tankID][partID]
    --紫色或以上配件可以绑定
    if(aVo:getConfigData("quality") < 3)then
        return 2
    end
    for k, v in pairs(self.abag) do
        if(v:getConfigData("tankID") == tankID and v:getConfigData("part") == partID)then
            if(v:getConfigData("quality") > aVo:getConfigData("quality"))then
                return 3
            elseif(v:getConfigData("quality") == aVo:getConfigData("quality") and v:getGS() > aVo:getGS())then
                return 3
            end
        end
    end
    if(aVo.bind == 1)then
        return 4
    end
    return 0
end

-- 配件强化是否满级
function accessoryVoApi:strengIsFull()
    local maxLv = math.min(#(accessoryCfg.upgradeProbability5), playerVoApi:getMaxLvByKey("roleMaxLevel"))
    for i = 1, 4 do
        for j = 1, accessoryCfg.unLockPart do
            local subVo = accessoryVoApi:getAccessoryByPart(i, j)
            if subVo == nil or subVo.lv < maxLv then
                return false
            end
        end
    end
    return true
end

function accessoryVoApi:showRaidsRewardSmallDialog(bgSrc, size, fullRect, inRect, title, content, istouch, isuseami, layerNum, callBackHandler, isOneByOne, upgradeTanks, showStrTb, endRaidStrTb, isAccStreng)
    require "luascript/script/game/scene/gamedialog/warDialog/raidsRewardSmallDialog"
    local dialog = raidsRewardSmallDialog:new()
    dialog:init(bgSrc, size, fullRect, inRect, title, content, istouch, isuseami, layerNum, callBackHandler, isOneByOne, upgradeTanks, showStrTb, endRaidStrTb, isAccStreng)
    return dialog
end

--强化100%需要消耗工具箱数量
--isAlwaysSuccess 是否勾选100%概率,firstNum 一次的数量,costPropNum 连续强化总数量
--isMulti 是否勾选连续强化；选择连续强化时，count 连续强化次数
function accessoryVoApi:successNeedPropNum(tankID, partID, paramAvo, isAlwaysSuccess, isMulti, count, isTip)
    local firstNum, costPropNum, costPropTb = 0, 0, {}
    local aVo
    if(tankID ~= nil and partID ~= nil)then
        if(self.equip ~= nil and self.equip["t"..tankID] ~= nil)then
            aVo = self.equip["t"..tankID]["p"..partID]
        end
    else
        aVo = paramAvo
    end
    if aVo then
        local lv = aVo.lv
        local has = playerVoApi:getGold()
        local part = tonumber(aVo:getConfigData("part"))
        local need = accessoryCfg["upgradeResource"..aVo:getConfigData("quality")][part][lv + 1]
        local roleMaxLevel = playerVoApi:getMaxLvByKey("roleMaxLevel")
        local upperLimitTb = accessoryVoApi:getPromoteUpperLimitTb(aVo.type, aVo.promoteLv)
        if upperLimitTb and upperLimitTb[1] then
            roleMaxLevel = roleMaxLevel + upperLimitTb[1]
        end
        if(need == nil or aVo.lv >= roleMaxLevel)then
            if isTip == true then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("alliance_lvmax"), 30)
            end
        else
            local addRate = self:getVipUpgradeAddRate()
            local basePercent = self:getUpgradeProbability(tankID, partID, 0, paramAvo)
            local addPercent = basePercent * addRate
            
            local moPrivilegeFlag, moPrivilegeValue
            if militaryOrdersVoApi then
                moPrivilegeFlag, moPrivilegeValue = militaryOrdersVoApi:isUnlockByPrivilegeId(5)
            end
            if moPrivilegeFlag == true and moPrivilegeValue then
                addPercent = addPercent + math.ceil(moPrivilegeValue * 100)
            end

            local acAddPerNum, acAccessStreng = 0, 0
            local vo = activityVoApi:getActivityVo("yuandanxianli")
            if vo and activityVoApi:isStart(vo) == true then
                if acYuandanxianliVoApi:isCanStreng() then
                    local maxNum = acYuandanxianliVoApi:getAccessFreeTime()
                    local useNum = acYuandanxianliVoApi:getCurStreng()
                    acAddPerNum = maxNum - useNum
                    acAccessStreng = acYuandanxianliVoApi:getAccessStreng()
                end
            end
            --元旦献礼
            local acAddPercent = 0
            if acAddPerNum and acAddPerNum > 0 and acAccessStreng and acAccessStreng > 0 then
                acAddPercent = basePercent * acAccessStreng
                -- acAddPerNum=acAddPerNum-1
            end
            if isMulti == true then
                if isAlwaysSuccess == true then
                else
                    do return firstNum, costPropNum, costPropTb end
                end
            else
                if isAlwaysSuccess == true then
                    if((basePercent + addPercent + acAddPercent) >= 100)then
                        if isTip == true then
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("accessory_upgradePercent100"), 30)
                        end
                        do return firstNum, costPropNum, costPropTb end
                    end
                end
            end
            
            -- if((basePercent+addPercent)<100)then
            local lv1 = aVo.lv
            -- local acAddPerNum,acAccessStreng=0,0
            -- local vo = activityVoApi:getActivityVo("yuandanxianli")
            -- if vo and activityVoApi:isStart(vo)== true then
            -- if acYuandanxianliVoApi:isCanStreng() then
            -- local maxNum=acYuandanxianliVoApi:getAccessFreeTime()
            -- local useNum=acYuandanxianliVoApi:getCurStreng()
            -- acAddPerNum=maxNum-useNum
            -- acAccessStreng=acYuandanxianliVoApi:getAccessStreng()
            -- end
            -- end
            
            local strengthenNum = accessoryCfg.maxStrengthenNum
            if isMulti == true then
                if count then
                    strengthenNum = count or 0
                end
            else
                strengthenNum = 1
            end
            if strengthenNum > 0 then
                for i = 1, strengthenNum do
                    if lv1 >= roleMaxLevel then
                        break
                    else
                        local curLvBasePercent = self:getUpgradeProbability(tankID, partID, 0, paramAvo, lv1)
                        -- local tmp=math.ceil((100-curLvBasePercent)/accessoryCfg.amuletProbality)
                        --元旦献礼
                        local percent = curLvBasePercent
                        if acAddPerNum and acAddPerNum > 0 and acAccessStreng and acAccessStreng > 0 then
                            percent = percent + math.ceil(curLvBasePercent * acAccessStreng)
                            acAddPerNum = acAddPerNum - 1
                        end
                        --vip
                        if addRate > 0 then
                            percent = percent + curLvBasePercent * addRate
                            -- tmp=math.ceil((100-percent)/accessoryCfg.amuletProbality)
                        end
                        local moPrivilegeFlag, moPrivilegeValue
                        if militaryOrdersVoApi then
                            moPrivilegeFlag, moPrivilegeValue = militaryOrdersVoApi:isUnlockByPrivilegeId(5)
                        end
                        if moPrivilegeFlag == true and moPrivilegeValue then
                            percent = percent + math.ceil(moPrivilegeValue * 100)
                        end

                        if percent > 100 then
                            percent = 100
                        end
                        tmp = math.ceil((100 - percent) / accessoryCfg.amuletProbality)
                        if isAlwaysSuccess == true then
                            if(costPropNum + tmp > self:getUpgradeProp())then
                                -- costPropNum=costPropNum+self:getUpgradeProp()
                                break
                            else
                                costPropNum = costPropNum + tmp
                                table.insert(costPropTb, tmp)
                            end
                        else
                            if i == 1 then
                                costPropNum = costPropNum + tmp
                                firstNum = costPropNum
                            else
                                costPropNum = costPropNum + firstNum
                            end
                            if costPropNum > self:getUpgradeProp() then
                                costPropNum = self:getUpgradeProp()
                                table.insert(costPropTb, firstNum - (costPropNum - self:getUpgradeProp()))
                            else
                                table.insert(costPropTb, firstNum)
                            end
                        end
                    end
                    if i == 1 then
                        firstNum = costPropNum
                        -- if isAlwaysSuccess==true then
                        -- else
                        -- costPropTb={firstNum}
                        -- end
                    end
                    lv1 = lv1 + 1
                end
            end
            
            -- if isTip==true then
            -- if firstNum<=0 then
            -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_upgrade_success_err1"),30)
            -- end
            -- end
            
            if isTip == true then
                local isFullPercent, isNotEnough = false, false
                -- print("self:getUpgradeProp()",self:getUpgradeProp())
                -- print("firstNum,costPropNum",firstNum,costPropNum)
                -- print("isMulti,isAlwaysSuccess",isMulti,isAlwaysSuccess)
                if self:getUpgradeProp() > 0 then
                    if isMulti == true then
                        if isAlwaysSuccess == true and costPropNum <= 0 then
                            if(lv1 > aVo.lv)then
                                isFullPercent = true
                            else
                                isNotEnough = true
                            end
                        end
                    else
                        -- print("firstNum",firstNum)
                        if firstNum <= 0 then
                            if isAlwaysSuccess == true then
                                isNotEnough = true
                            else
                                isFullPercent = true
                            end
                        end
                    end
                else
                    isNotEnough = true
                end
                -- print("isFullPercent,isNotEnough",isFullPercent,isNotEnough)
                if isNotEnough == true then
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("accessory_upgrade_success_err1"), 30)
                elseif isFullPercent == true then
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("accessory_upgradePercent100"), 30)
                end
            end
            -- else
            -- if isTip==true then
            -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_upgradePercent100"),30)
            -- end
            -- end
            if isMulti == true then
            else
                if firstNum > 0 then
                    costPropTb = {firstNum}
                end
            end
        end
    end
    return firstNum, costPropNum, costPropTb
end

--配件获取精炼的最大等级
function accessoryVoApi:getSmeltMaxRank(quality)
    local maxRank = 0
    local maxRankCfg = accessoryCfg.smeltMaxRank
    if maxRankCfg and type(maxRankCfg) == "table" and quality and maxRankCfg[quality] then
        maxRank = tonumber(maxRankCfg[quality]) or 0
    elseif maxRankCfg and (type(maxRankCfg) == "number" or type(maxRankCfg) == "string") then
        maxRank = tonumber(maxRankCfg) or 0
    end
    return maxRank
end

--配件橙色突破成红色时，保留改造等级需要花费金币
function accessoryVoApi:stayLvCostGems(rank)
    local costGems = 0
    if accessoryCfg.smeltMoney and rank and rank > 0 and accessoryCfg.smeltMoney[rank] then
        costGems = accessoryCfg.smeltMoney[rank] or 0
    end
    return costGems
end

-- 检查某一配件，相同部位，其品阶相同或更高的配件数量（身上和背包）
function accessoryVoApi:checkHigherQualityNum(type)
    local num = 0
    if type and accessoryCfg.aCfg and accessoryCfg.aCfg[type] then
        local accCfg = accessoryCfg.aCfg[type]
        local tankID = "t"..accCfg.tankID
        local partID = "p"..accCfg.part
        local quality = accCfg.quality
        for k, v in pairs(self.abag) do
            local tankID1 = "t"..v:getConfigData("tankID")
            local partID1 = "p"..v:getConfigData("part")
            local quality1 = v:getConfigData("quality")
            if tankID1 == tankID and partID1 == partID and tonumber(quality1) >= tonumber(quality) then
                num = num + 1
            end
        end
        for k, v in pairs(self.equip) do
            for kk, vv in pairs(v) do
                local tankID2 = "t"..vv:getConfigData("tankID")
                local partID2 = "p"..vv:getConfigData("part")
                local quality2 = vv:getConfigData("quality")
                if tankID2 == tankID and partID2 == partID and tonumber(quality2) >= tonumber(quality) then
                    num = num + 1
                end
            end
        end
    end
    return num
end

--是否能突破到5阶红色配件
function accessoryVoApi:isUpgradeQualityRed()
    if base.accessoryBind == 1 and base.redAcc == 1 then
        return true
    else
        return false
    end
end

-- 配件改造是否满级
function accessoryVoApi:rankIsFull()
    for i = 1, 4 do
        for j = 1, accessoryCfg.unLockPart do
            local subVo = accessoryVoApi:getAccessoryByPart(i, j)
            if subVo == nil then
                return false
            end
            local smeltMaxRank = accessoryVoApi:getSmeltMaxRank(subVo:getConfigData("quality"))
            if subVo.rank < smeltMaxRank then
                return false
            end
        end
    end
    return true
    
end

--关卡扫荡选择页面
function accessoryVoApi:showRaidSelectDialog(layerNum, callback)
    require "luascript/script/game/scene/gamedialog/accessory/supplyRaidSelectSmallDialog"
    supplyRaidSelectSmallDialog:showSelectWipeDialog(layerNum, callback)
end

function accessoryVoApi:getLastSelectRaidList()
    local raid = CCUserDefault:sharedUserDefault():getStringForKey("supply.raidsave"..playerVoApi:getUid())
    if raid ~= "" then
        return G_Json.decode(raid)
    end
    return {}
end

function accessoryVoApi:saveSelectRaidList(raidList)
    if raidList and SizeOfTable(raidList) == 0 then
        do return end
    end
    local raid = G_Json.encode(raidList)
    CCUserDefault:sharedUserDefault():setStringForKey("supply.raidsave"..playerVoApi:getUid(), raid)
    CCUserDefault:sharedUserDefault():flush()
end

--获取关卡掉落
function accessoryVoApi:getEChallengeDropStr(ecid)
    local str, colorTb = "", {G_ColorWhite}
    local ecCfg = self:getECCfg()
    local propbonus = ecCfg["s"..ecid].propbonus
    local dropData = propbonus[3]
    local atb, ftb = {}, {}
    for k, v in pairs(dropData) do
        if v and v[1] then
            local id = Split(v[1], "_")[2]
            if id then
                local eType = string.sub(id, 1, 1)
                if eType then
                    if eType == "a" then
                        local aCfg = accessoryCfg.aCfg[id]
                        local quality = tonumber(aCfg.quality)
                        if atb[quality] == nil then
                            atb[quality] = 1
                        end
                    elseif eType == "f" then
                        local fCfg = accessoryCfg.fragmentCfg[id]
                        local quality = tonumber(fCfg.quality)
                        if ftb[quality] == nil then
                            ftb[quality] = 1
                        end
                    end
                end
            end
        end
    end
    for k = 5, 1, -1 do
        if atb[k] == 1 or ftb[k] == 1 then
            if str ~= "" then
                str = str..","
                table.insert(colorTb, G_ColorWhite)
            end
            local color = accessoryVoApi:getColorByQuality(k)
            table.insert(colorTb, color)
        end
        -- print(k, atb[k], ftb[k])
        if atb[k] == 1 then
            str = str.."<rayimg>"..getlocal("elite_challenge_accessory_"..k, {""}) .. "<rayimg>"
        end
        if ftb[k] == 1 then
            str = str.."<rayimg>"..getlocal("elite_challenge_fragment_"..k, {""}) .. "<rayimg>"
        end
    end
    return str, colorTb
end

-- 拿到当前红配 橙配 数量，配件总战力
function accessoryVoApi:getCurUsedData(initOverBack)
    local function callback()
        local allAccessoryPowers = self:getAllAccessoryPower()
        local orgA_num,redA_num = self:getCurAccessoryType()
        if initOverBack then
            initOverBack(redA_num,orgA_num,allAccessoryPowers)
        else
           return redA_num,orgA_num,allAccessoryPowers 
        end
    end 

    if self.dataNeedRefresh == true then
        self:refreshData(callback)
    else
        callback()
    end
end
---计算当前装配的 橙配 和 红配的 数量
function accessoryVoApi:getCurAccessoryType()
    -- id,eType
    local orgA_num,redA_num = 0,0
    for k,v in pairs(self.equip) do
        for m,n in pairs(v) do
            for kk,vv in pairs(n) do
                if kk == "type" then -- a128 > 全是红配 ; 4的倍数 全是橙配
                    local accessoryID = tonumber(RemoveFirstChar(vv))
                    if accessoryID < 129 and accessoryID % 4 == 0 then
                        orgA_num = orgA_num + 1
                    elseif accessoryID > 128 then
                        redA_num = redA_num + 1
                    end
                end
            end
        end
    end
    return orgA_num,redA_num
end
--拿到配件总战力
function accessoryVoApi:getAllAccessoryPower()
    local powers = 0
    for i=1,4 do
        local equips = self:getTankAccessories(i)   
        if equips then
            for k,v in pairs(equips) do
                if v then
                    powers = powers+v:getGS()+v:getGsAdd() 
                end
            end
        end
    end
    return powers
end

--显示配件晋升小弹板
function accessoryVoApi:showPromoteSmallDialog(layerNum, tankID, partID)
    require "luascript/script/game/scene/gamedialog/accessory/accessoryPromoteSmallDialog"
    accessoryPromoteSmallDialog:showPromote(layerNum, getlocal("promotion"), tankID, partID)
end

--获取红配晋升配置
function accessoryVoApi:getPromoteCfg()
    return G_requireLua("config/gameconfig/accessoryPlus")
end

--获取红配晋升消耗的道具
function accessoryVoApi:getPromoteCostItems(accessoryId, promoteLv)
    local promoteCfg = self:getPromoteCfg()
    if promoteCfg and promoteCfg[promoteLv] and promoteCfg[promoteLv][accessoryId] then
        local curLvCfg = promoteCfg[promoteLv][accessoryId]
        local costItem = FormatItem(curLvCfg.cost, nil, true)
        local costOrangeFragment = self:getPromoteCostOrangeFragment(accessoryId, promoteLv)
        if costOrangeFragment then
            local newAddCostItem = FormatItem({e = {[costOrangeFragment.fid] = costOrangeFragment.num}})
            if newAddCostItem then
                if costItem == nil then
                    costItem = {}
                end
                table.insert(costItem, newAddCostItem[1])
            end
        end
        local fid
        for k, v in pairs(accessoryCfg.fragmentCfg) do
            if v.output == accessoryId then
                fid = v.fid
                break
            end
        end
        if fid then
            local newAddCostItem = FormatItem({e = {[fid] = curLvCfg.needOwn}})
            if newAddCostItem then
                if costItem == nil then
                    costItem = {}
                end
                table.insert(costItem, newAddCostItem[1])
            end
        end
        return costItem
    end
end

--获取红配晋升的强度值
function accessoryVoApi:getPromoteStrength(accessoryId, promoteLv)
    local strength = 0
    local promoteCfg = self:getPromoteCfg()
    if promoteCfg then
        for lv = 1, promoteLv do
            if promoteCfg[lv] and promoteCfg[lv][accessoryId] then
                local curLvCfg = promoteCfg[lv][accessoryId]
                strength = strength + curLvCfg.strength
            end
        end
    end
    return strength
end

--获取红配晋升的属性值
function accessoryVoApi:getPromoteAttrTb(accessoryId, promoteLv)
    local attrTb = {}
    local promoteCfg = self:getPromoteCfg()
    for lv = 0, promoteLv do
        if promoteCfg and promoteCfg[(lv == 0) and 1 or lv] and promoteCfg[(lv == 0) and 1 or lv][accessoryId] then
            local curLvCfg = promoteCfg[(lv == 0) and 1 or lv][accessoryId]
            for i, attrType in pairs(curLvCfg.attType) do
                if lv == 0 then
                    attrTb[attrType] = 0
                else
                    attrTb[attrType] = (attrTb[attrType] or 0) + curLvCfg.att[i]
                end
            end
        end
    end
    return attrTb
end

--获取红配晋升的属性增加值
function accessoryVoApi:getPromoteAddAttrTb(accessoryId, promoteLv)
    local attrTb = {}
    local promoteCfg = self:getPromoteCfg()
    if promoteCfg and promoteCfg[promoteLv] and promoteCfg[promoteLv][accessoryId] then
        local curLvCfg = promoteCfg[promoteLv][accessoryId]
        for i, attrType in pairs(curLvCfg.attType) do
            attrTb[attrType] = curLvCfg.att[i]
        end
    end
    return attrTb
end

--获取红配晋升的上限值
--return : { 强化等级上限，改造等级上限，精炼等级上限 }
function accessoryVoApi:getPromoteUpperLimitTb(accessoryId, promoteLv)
    if promoteLv == 0 then
        -- return { 0, 0, 0 }
        return { 0, 0 } --精炼等级上限  已去掉了
    end
    local promoteCfg = self:getPromoteCfg()
    if promoteCfg and promoteCfg[promoteLv] and promoteCfg[promoteLv][accessoryId] then
        local curLvCfg = promoteCfg[promoteLv][accessoryId]
        return { curLvCfg.lvUp, curLvCfg.rankUp, curLvCfg.refineUp }
    end
end

--获取红配晋升消耗自身红配碎片的数量
function accessoryVoApi:getPromoteCostFragmentNum(accessoryId, promoteLv)
    local promoteCfg = self:getPromoteCfg()
    if promoteCfg and promoteCfg[promoteLv] and promoteCfg[promoteLv][accessoryId] then
        local fid
        for k, v in pairs(accessoryCfg.fragmentCfg) do
            if v.output == accessoryId then
                fid = v.fid
                break
            end
        end
        return (promoteCfg[promoteLv][accessoryId].needOwn or 0), fid
    end
    return 0
end

--获取红配晋升消耗通用红配碎片的数量
function accessoryVoApi:getPromoteCostGlobalFragmentNum(accessoryId, promoteLv)
    local promoteCfg = self:getPromoteCfg()
    if promoteCfg and promoteCfg[promoteLv] and promoteCfg[promoteLv][accessoryId] then
        return (promoteCfg[promoteLv][accessoryId].needOther or 0)
    end
    return 0
end

--获取红配晋升消耗橙色碎片
function accessoryVoApi:getPromoteCostOrangeFragment(accessoryId, promoteLv)
    local promoteCfg = self:getPromoteCfg()
    if promoteCfg and promoteCfg[promoteLv] and promoteCfg[promoteLv][accessoryId] then
        return { fid = promoteCfg[promoteLv][accessoryId].orangeId, num = promoteCfg[promoteLv][accessoryId].needOrange }
    end
end

--根据pId获取配件道具数量
function accessoryVoApi:getPropNumsById(pId)
    if self.props then
        return (self.props[pId] or 0)
    end
    return 0
end

--红配晋升接口
--@tankType<int> : 坦克类型
--@posIndex<int> : 位置索引
--@fid<string> : 碎片id
function accessoryVoApi:requestPromote(callback, tankType, posIndex, fid)
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data and sData.data.accessory then
                if(sData.data.accessory.props ~= nil)then
                    self.props = {}
                    for k, v in pairs(sData.data.accessory.props) do
                        self.props[k] = tonumber(v)
                    end
                end
                if(sData.data.accessory.fragment ~= nil)then
                    self.fbag = nil
                    self.fbag = {}
                    for k, v in pairs(sData.data.accessory.fragment) do
                        local fVo = accessoryFragmentVo:new()
                        fVo:initWithData({id = k, num = v})
                        table.insert(self.fbag, fVo)
                    end
                    self:sort(2)
                end
                if(sData.data.accessory.used ~= nil)then
                    self.equip = {t1 = {}, t2 = {}, t3 = {}, t4 = {}}
                    for tid, tank in pairs(sData.data.accessory.used) do
                        for part, acc in pairs(tank) do
                            local aVo = accessoryVo:new()
                            aVo:initWithData(acc)
                            self.equip[tid][part] = aVo
                        end
                    end
                end
                if type(callback) == "function" then
                    callback()
                end
                eventDispatcher:dispatchEvent("accessory.data.refresh", {type={4}})
            end
        end
    end
    socketHelper:accessoryPromote(socketCallback, tankType, posIndex, fid)
end
