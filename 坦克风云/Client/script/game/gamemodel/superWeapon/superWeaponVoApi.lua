require "luascript/script/game/gamemodel/superWeapon/swCrystalVo"
--超级武器的api
superWeaponVoApi =
{
    initFlag = false, --是否经过初始化
    weaponList = {}, --拥有的超级武器列表
    fragmentList = {}, --拥有的碎片列表
    equipList = {}, --已经装备上的武器列表
    propList = {}, --道具列表
    swChallenge = {}, --关卡数据
    cRankData = {}, --关卡排行榜
    crystalVoList = {}, --结晶数据
    expertList = {}, --购买的专家次数
    robList = {}, --抢夺列表
    reportList = {}, --抢夺战报列表
    flag = -1, --抢夺战报是否初始化
    totalNum = 0, --抢夺战报总数量
    unreadNum = 0, --抢夺战报未读数量
    maxNum = 50, --抢夺战报最大数量
    energy = 0, --当前体力值
    energyUpdateTime = 0, --上次更新体力时间
    energyBuyNum = 0, --体力购买次数
    lastBuyTime = 0, --上一次购买体力时间
    protectTime = 0, --免战结束时间
    fragmentFlag = -1, --碎片是否变化标示
    allCrystalVoList = {}, --所有结晶VO,不做数据计算，{c1:vo}
    refreshNum = 0, --刷新次数
    lastFreeRefreshTime = 0, --上次免费刷新时间
    lastBuyRefreshTime = 0, --上次金币购买刷新时间
    showRaidFinishData = nil, --扫荡数据，完成后显示
    hasCallback = nil, --扫荡完成后是否能请求后端
    addPerPropData = nil, --c200晶体数据，提高融合概率
    protectPropData = nil, --c201晶体数据，融合失败时保护已有晶体不降级
    showTips = nil, --是否显示过tips
    continuousExp = false, --连续探索
    exploreTb = {}, --探索返回的物品列表
    exploreFlag = 0, --探索flag ：0 未探索，1 已结束
}

-------------------以下打开面板-------------------
--主面板，列表,selectedIndex默认打开第几个面板
function superWeaponVoApi:showMainDialog(layerNum, selectedIndex, addCallback)
    require "luascript/script/game/scene/gamedialog/superWeaponDialog/superWeaponDialog"
    local function onGetChallenge()
        local td = superWeaponDialog:new(layerNum, selectedIndex)
        local tbArr = {}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("sample_build_name_102"), true, layerNum)
        sceneGame:addChild(dialog, layerNum)
        
        if addCallback then
            addCallback()
        end
    end
    local function onInitEnd()
        superWeaponVoApi:initChallenge(onGetChallenge)
    end
    superWeaponVoApi:init(onInitEnd)
end
--超级武器面板
function superWeaponVoApi:showSuperWeaponDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/superWeaponDialog/superWeaponInfoDialog"
    local td = superWeaponInfoDialog:new()
    local tbArr = {getlocal("super_weapon_rebuild"), getlocal("accessory_ware"), getlocal("sample_build_name_10")}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("super_weapon_title_1"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end
--超级武器详情面板
function superWeaponVoApi:showWeaponDetailDialog(weaponID, layerNum)
    require "luascript/script/game/scene/gamedialog/superWeaponDialog/superWeaponDetailSmallDialog"
    local sd = superWeaponDetailSmallDialog:new(weaponID)
    sd:init(layerNum)
end
--超级武器进阶成功的面板
function superWeaponVoApi:showLvUpDialog(weaponID, layerNum, propNum)
    require "luascript/script/game/scene/gamedialog/superWeaponDialog/superWeaponLvupSmallDialog"
    local sd = superWeaponLvupSmallDialog:new(weaponID, propNum)
    sd:init(layerNum)
end
--神秘组织面板
function superWeaponVoApi:showChallengeDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/superWeaponDialog/superWeaponChallengeDialog"
    local td = superWeaponChallengeDialog:new()
    local tbArr = {}
    local dialog = td:init("TankInforPanel.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(130, 50, 1, 1), tbArr, nil, nil, "", true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end
--抢夺面板
--param tab: 打开面板的时候要打开哪个tab
--param weaponID: 打开面板的时候选中哪个武器
function superWeaponVoApi:showRobDialog(layerNum, tab, weaponID)
    require "luascript/script/game/scene/gamedialog/superWeaponDialog/superWeaponRobDialog"
    local td = superWeaponRobDialog:new(tab, weaponID)
    local tbArr = {getlocal("super_weapon_rob_weapon"), getlocal("local_war_npc_name")}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("super_weapon_title_3"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end
--能量结晶面板
--param tab: 打开面板的时候要打开哪个tab
--param weaponID: 打开面板的时候选中哪个武器
function superWeaponVoApi:showEnergyCrystalDialog(layerNum, tab, weaponID)
    require "luascript/script/game/scene/gamedialog/superWeaponDialog/energyCrystalDialog"
    local td = energyCrystalDialog:new(tab, weaponID)
    local tbArr = {getlocal("crystal_mosaic_title"), getlocal("crystal_merge_title")}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("super_weapon_title_4"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end
--关卡奖励预览面板
function superWeaponVoApi:showCRewardListDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/superWeaponDialog/superWeaponCRewardListDialog"
    local td = superWeaponCRewardListDialog:new()
    local tbArr = {}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("super_weapon_challenge_reward_preview"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end
--关卡排行面板
function superWeaponVoApi:showCRankDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/superWeaponDialog/superWeaponCRankDialog"
    local td = superWeaponCRankDialog:new()
    local tbArr = {}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("mainRank"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end
--抢夺碎片玩家列表面板
function superWeaponVoApi:showRobListDialog(fid, layerNum)
    require "luascript/script/game/scene/gamedialog/superWeaponDialog/superWeaponRobListDialog"
    local td = superWeaponRobListDialog:new(fid)
    local tbArr = {}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("super_weapon_title_3"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end
--连续探索面板
function superWeaponVoApi:showContinuousExploreDialog(fid, layerNum, level)
    require "luascript/script/game/scene/gamedialog/superWeaponDialog/superWeaponContinuousExploreDialog"
    local td = superWeaponContinuousExploreDialog:new(fid, level)
    local tbArr = {}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("excavate"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end
--关卡额外奖励详情面板，swId：关卡id，type：1.信息，2.领奖
function superWeaponVoApi:showChallengeRewardSmallDialog(swId, type, layerNum)
    require "luascript/script/game/scene/gamedialog/superWeaponDialog/challengeRewardSmallDialog"
    local sd = challengeRewardSmallDialog:new(swId, type)
    sd:init(layerNum)
end
--关卡扫荡到几层面板
function superWeaponVoApi:showChallengeRaidSmallDialog(layerNum, callback)
    require "luascript/script/game/scene/gamedialog/superWeaponDialog/challengeRaidSmallDialog"
    local sd = challengeRaidSmallDialog:new()
    sd:init(layerNum, callback)
end
--抢夺确认和碎片信息面板 fragmentId：碎片id type：1.抢夺，2.信息
function superWeaponVoApi:showFragmentRobSmallDialog(fragmentId, type, layerNum)
    require "luascript/script/game/scene/gamedialog/superWeaponDialog/fragmentRobSmallDialog"
    local sd = fragmentRobSmallDialog:new(fragmentId, type)
    sd:init(layerNum)
end
--战报面板
function superWeaponVoApi:showRobReportDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/superWeaponDialog/superWeaponRobReportDialog"
    local td = superWeaponRobReportDialog:new()
    local tbArr = {}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("fight_content_fight_title"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end
--免战面板
function superWeaponVoApi:showRobProtectSmallDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/superWeaponDialog/robProtectSmallDialog"
    local sd = robProtectSmallDialog:new()
    sd:init(layerNum)
end
--加体力面板
function superWeaponVoApi:showRobAddEnergySmallDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/superWeaponDialog/robAddEnergySmallDialog"
    local sd = robAddEnergySmallDialog:new()
    sd:init(layerNum)
end
--加合成概率道具面板
function superWeaponVoApi:showAddPropSmallDialog(layerNum, propMaxNum, callback, specialFlag)
    require "luascript/script/game/scene/gamedialog/superWeaponDialog/addPropSmallDialog"
    local sd = addPropSmallDialog:new()
    sd:init(layerNum, propMaxNum, callback, specialFlag)
end
-------------------以上打开面板-------------------

-------------------以下接口-------------------

function superWeaponVoApi:init(callback)
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if(sData.data.weapon)then
                self:formatData(sData.data.weapon)
            end
            if(sData.data.weaponroblog)then
                local weaponroblog = sData.data.weaponroblog
                if weaponroblog.maxrows then
                    self:setTotalNum(tonumber(weaponroblog.maxrows) or 0)
                end
                if weaponroblog.unread then
                    self:setUnreadNum(tonumber(weaponroblog.unread) or 0)
                end
            end
            if(callback)then
                callback()
            end
        end
    end
    socketHelper:getWeaponInfo(onRequestEnd)
end

function superWeaponVoApi:formatData(data)
    if data then
        self.initFlag = true
        local infoEventFlag = false
        -- 使用的武器数据
        if data.used then
            self.equipList = data.used
            infoEventFlag = true
        end
        
        -- 强化材料
        if data.props then
            self.propList = {}
            for k, v in pairs(data.props) do
                self.propList[k] = tonumber(v)
            end
            infoEventFlag = true
        end
        
        -- 碎片
        if data.fragment then
            self.fragmentList = {}
            for k, v in pairs(data.fragment) do
                self.fragmentList[k] = tonumber(v)
            end
        end
        
        -- 武器信息
        if data.info then
            for k, v in pairs(data.info) do
                if(self.weaponList[k])then
                    self.weaponList[k]:initWithData(v)
                else
                    local weaponVo = superWeaponVo:new(k)
                    weaponVo:initWithData(v)
                    self.weaponList[k] = weaponVo
                end
            end
            infoEventFlag = true
        end
        
        -- 购买的专家次数
        if data.master then
            self.expertList = {}
            for k, v in pairs(data.master) do
                self.expertList[k] = tonumber(v)
            end
            infoEventFlag = true
        end
        
        -- 结晶
        if self.addPerPropData == nil then
            local vo = swCrystalVo:new()
            vo:initWithData("c200", 0)
            self.addPerPropData = vo
        end
        if self.protectPropData == nil then
            local vo = swCrystalVo:new()
            vo:initWithData("c201", 0)
            self.protectPropData = vo
        end
        if data.crystal then
            self.crystalVoList = {}
            self.addPerPropData = nil
            local vo = swCrystalVo:new()
            vo:initWithData("c200", 0)
            self.addPerPropData = vo
            self.protectPropData = nil
            local vo = swCrystalVo:new()
            vo:initWithData("c201", 0)
            self.protectPropData = vo
            for k, v in pairs(data.crystal) do
                if k == "c200" then
                    self.addPerPropData.num = tonumber(v)
                elseif k == "c201" then
                    self.protectPropData.num = tonumber(v)
                else
                    local vo = swCrystalVo:new()
                    vo:initWithData(k, tonumber(v))
                    table.insert(self.crystalVoList, vo)
                    if(self.allCrystalVoList[k] == nil)then
                        local temVO = swCrystalVo:new()
                        temVO:initWithData(k, 1)
                        self.allCrystalVoList[k] = temVO
                    end
                end
            end
        end
        
        --体力值
        if data.energy then
            self.energy = tonumber(data.energy) or 0
        end
        --上次更新体力时间
        if data.energytime then
            self.energyUpdateTime = tonumber(data.energytime) or 0
        end
        --体力购买次数
        if data.energybuy then
            self.energyBuyNum = tonumber(data.energybuy) or 0
        end
        --上次购买体力时间
        if data.lastbuyenergy then
            self.lastBuyTime = tonumber(data.lastbuyenergy) or 0
        end
        --剩余保护时间
        if data.protect then
            self.protectTime = tonumber(data.protect) or 0
        end
        --防守部队
        if data.defender then
            for k, v in pairs(data.defender) do
                if v and v[1] and v[2] then
                    local tid = (tonumber(v[1]) or tonumber(RemoveFirstChar(v[1])))
                    local num = tonumber(v[2])
                    tankVoApi:setTanksByType(20, k, tid, num)
                end
            end
        end
        --刷新次数
        if data.refnum then
            self.refreshNum = tonumber(data.refnum) or 0
        end
        --上次免费刷新时间
        if data.lastfreeref then
            self.lastFreeRefreshTime = tonumber(data.lastfreeref) or 0
        end
        --上次金币购买刷新时间
        if data.lastbuyref then
            self.lastBuyRefreshTime = tonumber(data.lastbuyref) or 0
        end
        
        if(infoEventFlag)then
            eventDispatcher:dispatchEvent("superweapon.data.info")
        end
    end
end

function superWeaponVoApi:getAddPerPropData()
    if self.addPerPropData == nil then
        local vo = swCrystalVo:new()
        vo:initWithData("c200", 0)
        self.addPerPropData = vo
    end
    return self.addPerPropData
end

function superWeaponVoApi:getProtetPropData()
    if self.protectPropData == nil then
        local vo = swCrystalVo:new()
        vo:initWithData("c201", 0)
        self.protectPropData = vo
    end
    return self.protectPropData
end

--关卡数据初始化
function superWeaponVoApi:initChallenge(callback)
    local challenge = self:getSWChallenge()
    if challenge == nil or SizeOfTable(challenge) == 0 then
        local function getSWChallengeCallback(fn, data)
            local ret, sData = base:checkServerData(data)
            if ret == true then
                if sData.data and sData.data.swchallenge then
                    self:setSWChallenge(sData.data.swchallenge)
                end
                if callback then
                    callback()
                end
            end
        end
        socketHelper:weaponGetSWChallenge(getSWChallengeCallback)
    else
        if callback then
            callback()
        end
    end
end
--关卡重置
function superWeaponVoApi:resetChallenge(free, callback)
    local function buyRestnumCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData.data and sData.data.swchallenge then
                self:setSWChallenge(sData.data.swchallenge)
            end
            if callback then
                callback()
            end
        end
    end
    socketHelper:weaponBuyRestnum(free, buyRestnumCallback)
end
--扫荡关卡
function superWeaponVoApi:raidChallenge(target, callback)
    local function weaponAutoBattleCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            local moPrivilegeFlag
            if militaryOrdersVoApi then
                moPrivilegeFlag = militaryOrdersVoApi:isUnlockByPrivilegeId(2)
            end
            if sData.data and sData.data.swchallenge then
                self:setSWChallenge(sData.data.swchallenge)
                if moPrivilegeFlag == true then
                    local cVo = self:getSWChallenge()
                    local floorNum, costTime
                    if cVo then
                        floorNum = cVo.raidEndIndex - cVo.raidStartIndex + 1
                        costTime = floorNum * swChallengeCfg.raidTime
                    end
                    self:setShowRaidFinishData({costTime = costTime, floorNum = floorNum})
                    self.hasCallback = nil
                end
            end
            if callback then
                callback(moPrivilegeFlag)
            end
            if moPrivilegeFlag == true then
                if stewardTabTwo and stewardTabTwo.refreshSelf then
                    stewardTabTwo:refreshSelf()
                end
            end
        end
    end
    socketHelper:weaponAutoBattle(target, weaponAutoBattleCallback)
end
--扫荡关卡结束
function superWeaponVoApi:raidChallengeFinish(usegems, callback, isEnter)
    local cVo = self:getSWChallenge()
    local floorNum, costTime
    if cVo then
        floorNum = cVo.raidEndIndex - cVo.raidStartIndex + 1
        costTime = floorNum * swChallengeCfg.raidTime
    end
    local function finautoBattleCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if isEnter == true and sData.ret == -17037 then
            if callback then
                callback()
            end
        elseif ret == true then
            if sData.data and sData.data.swchallenge then
                self:setSWChallenge(sData.data.swchallenge)
                self:setShowRaidFinishData({costTime = costTime, floorNum = floorNum})
                self.hasCallback = nil
            end
            if callback then
                callback()
            end
            if stewardTabTwo and stewardTabTwo.refreshSelf then
                stewardTabTwo:refreshSelf()
            end
        end
    end
    socketHelper:weaponFinautoBattle(usegems, finautoBattleCallback)
end
--关卡排行榜
function superWeaponVoApi:getSWChallengeRank(page, callback)
    local function getRankCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            require "luascript/script/game/gamemodel/superWeapon/cRankVo"
            if page == 1 then
                self:clearCRankData()
            end
            if self.cRankData == nil then
                self.cRankData = {}
            end
            self.cRankData.isMore = false
            if self.cRankData.selfRank == nil or SizeOfTable(self.cRankData.selfRank) == 0 then
                local value
                local rvo = cRankVo:new()
                rvo:initWithData(playerVoApi:getUid(), playerVoApi:getPlayerName(), playerVoApi:getPlayerLevel(), "100+", value)
                self.cRankData.selfRank = rvo
            end
            if sData.data and sData.data.myranking ~= nil then
                self.cRankData.selfRank = nil
                local selfRank = sData.data.myranking
                local rvo = cRankVo:new()
                local rank = selfRank[4] or 0
                if rank <= 0 then
                    rank = "100+"
                end
                rvo:initWithData(selfRank[1], selfRank[2], selfRank[3], rank, selfRank[5])
                self.cRankData.selfRank = rvo
            end
            if sData.data and sData.data.ranking ~= nil then
                local rankData = sData.data.ranking
                if self.cRankData.rankData == nil then
                    self.cRankData.rankData = {}
                end
                local num = 0
                for k, v in pairs(rankData) do
                    local vo = cRankVo:new()
                    vo:initWithData(v[1], v[2], v[3], v[4], v[5])
                    table.insert(self.cRankData.rankData, vo)
                    num = num + 1
                end
                local function sortAsc(a, b)
                    return a.rank < b.rank
                end
                table.sort(self.cRankData.rankData, sortAsc)
                
                if self.cRankData.page == nil then
                    self.cRankData.page = 1
                else
                    self.cRankData.page = self.cRankData.page + 1
                end
                if self.cRankData.page < 5 and num >= 20 then
                    self.cRankData.isMore = true
                end
            end
            if callback then
                callback()
            end
        end
    end
    socketHelper:weaponGetswchallengerank(page, getRankCallback)
end

-- 通过id获取结晶vo，
function superWeaponVoApi:getCrystalVoByCid(cid)
    if self.allCrystalVoList[cid] then
        return self.allCrystalVoList[cid]
    else
        local temVO = swCrystalVo:new()
        temVO:initWithData(cid, 1)
        self.allCrystalVoList[cid] = temVO
        return temVO
    end
    return nil
end
--装备超级武器
--param equipTb: 六个位置的武器id, eg: {"w1","w2",0,0,"w3","w4}
function superWeaponVoApi:wareEquip(equipTb, callback)
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret == true)then
            if(sData.data and sData.data.weapon)then
                self:formatData(sData.data.weapon)
            end
            if(callback)then
                callback()
            end
        end
    end
    socketHelper:weaponWareEquip(equipTb, onRequestEnd)
end

--购买专家
--param type: 1 or 2, 购买哪个专家
--param num: 购买多少次
function superWeaponVoApi:buyExpert(type, num, callback)
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret == true)then
            if(sData.data and sData.data.weapon)then
                self:formatData(sData.data.weapon)
            end
            if(callback)then
                callback()
            end
        end
    end
    socketHelper:weaponBuyExpert(type, num, onRequestEnd)
end

--强化重构
--param weaponID: 要强化的武器ID
--param att: 要强化的属性
--param type: 普通重构还是自动重构
function superWeaponVoApi:rebuild(weaponID, att, type, callback)
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret == true)then
            if(sData.data and sData.data.weapon)then
                self:formatData(sData.data.weapon)
            end
            local upgradeProcess = {}
            if(sData.data.flag)then
                upgradeProcess = sData.data.flag
            end
            if(callback)then
                callback(upgradeProcess)
            end
        end
    end
    socketHelper:weaponRebuild(weaponID, att, type, onRequestEnd)
end
--合成超级武器
function superWeaponVoApi:makeSuperWeapon(wid, callback)
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret == true)then
            if(sData.data and sData.data.weapon)then
                self:formatData(sData.data.weapon)
            end
            local propNum = 0
            if(sData.data and sData.data.pcount)then
                propNum = tonumber(sData.data.pcount)
            end
            if(callback)then
                callback(propNum)
            end
        end
    end
    socketHelper:weaponCompose(wid, onRequestEnd)
end

--升级超级武器
function superWeaponVoApi:upgradeSuperWeapon(wid, costProp, callback)
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret == true)then
            if(sData.data and sData.data.weapon)then
                self:formatData(sData.data.weapon)
            end
            local propNum = 0
            if(sData.data and sData.data.pcount)then
                propNum = tonumber(sData.data.pcount)
            end
            if costProp and costProp.num > 0 then --如果需要消耗道具来进阶的话，扣除一下道具
                bagVoApi:useItemNumId(costProp.id, costProp.num)
            end
            if(callback)then
                callback(propNum)
            end
        end
    end
    socketHelper:weaponUpgrade(wid, (costProp == nil or costProp.num == 0) and false or true, onRequestEnd)
end
-- 超级武器抢夺列表,fid:碎片id,
-- usegems:是否金币刷新，true是，false不是
-- free:是否用户手动免费刷新，true是，false不是
function superWeaponVoApi:weaponGetRoblist(fid, usegems, free, callback)
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret == true)then
            if(sData.data.weapon)then
                self:formatData(sData.data.weapon)
            end
            if sData.data and sData.data.roblist and sData.data.roblist.list then
                require "luascript/script/game/gamemodel/superWeapon/robPlayerVo"
                local swId = superWeaponCfg.fragmentCfg[fid].output
                local weaponVo = self:getWeaponByID(swId)
                local level = 0
                if weaponVo and weaponVo.lv then
                    level = weaponVo.lv
                end
                self.robList = {}
                local list = sData.data.roblist.list
                for k, v in pairs(list) do
                    if v then
                        local rVo = robPlayerVo:new()
                        rVo:initWithData(v, level)
                        table.insert(self.robList, rVo)
                    end
                end
            end
            if(callback)then
                callback()
            end
        end
    end
    socketHelper:weaponGetroblist(fid, usegems, free, onRequestEnd)
end
--连续探索
function superWeaponVoApi:weaponGetExploreList(fid, auto, getExploreListCallback)--auto:0未开启 1 开启
    
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret == true)then
            if sData.data then
                if sData.data.weapon then
                    self:formatData(sData.data.weapon)
                end
                if sData.data.pn then
                    local propTb = FormatItem(sData.data.pn[1])
                    local item = propTb[1]
                    local pid = (tonumber(item.key) or tonumber(RemoveFirstChar(item.key)))
                    local propNum = bagVoApi:getItemNumId(pid)
                    if propNum > item.num then
                        bagVoApi:useItemNumId(pid, propNum - item.num)
                    end
                end
                
                if sData.data.exp then
                    self.exploreTb = sData.data.exp
                    
                    for k, v in pairs(self.exploreTb) do
                        if v.addount and v.addount > 0 then
                            do break end
                        end
                        if v.gf then
                            self:setFragmentNum(v.gf, 1)
                            do break end
                        end
                    end
                end
                if sData.data.accessory then
                    accessoryVoApi:onRefreshData(sData.data.accessory)
                end
            end
            if getExploreListCallback then
                getExploreListCallback()
            end
        end
    end
    socketHelper:weaponGetExplorelist(fid, auto, onRequestEnd)
end
-- 超级武器金币购买免战
function superWeaponVoApi:weaponBuyProtect(callback)
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret == true)then
            if(sData.data.weapon)then
                self:formatData(sData.data.weapon)
            end
            if(callback)then
                callback()
            end
        end
    end
    socketHelper:weaponBuyprotect(onRequestEnd)
end
-- 超级武器金币购买体力
function superWeaponVoApi:weaponBuyEnergy(callback)
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret == true)then
            if(sData.data.weapon)then
                self:formatData(sData.data.weapon)
            end
            if(callback)then
                callback()
            end
        end
    end
    socketHelper:weaponBuyenergy(onRequestEnd)
end
-------------------以上接口-------------------
-- 结晶的最高等级
function superWeaponVoApi:getCrystalMaxLevel()
    if superWeaponCfg and superWeaponCfg.maxCLv then
        return superWeaponCfg.maxCLv
    end
    return 1
end

-- 获取套装属性，wid:超级武器id
function superWeaponVoApi:getSuitList(wid)
    local suitCfg = superWeaponCfg.crystalSuitRateClient
    local result = {}
    local perKey = ""
    local maxLv = 5
    local maxNum = 3--总孔数
    local ifHasSuitEffect = false--是否有套装效果
    local ifHasSkillEffect = false--是否有技能套装效果
    local bufNumTb = {}--
    for k, v in pairs(suitCfg) do
        local tb = {}
        -- if tb[k]==nil then
        local conditionStr = ""
        local num = 0
        if wid == nil or wid == "" or self:getWeaponList()[wid] == nil or (self:getWeaponList()[wid] and SizeOfTable(self:getWeaponList()[wid].slots) <= 0) then
            conditionStr = "("..num.."/"..maxNum..")"
        else
            
            for m, n in pairs(self:getWeaponList()[wid].slots) do
                local crystalVO = self:getCrystalVoByCid(n)
                if crystalVO and crystalVO:getLevel() >= tonumber(k) then
                    num = num + 1
                end
            end
            if num >= maxNum then
                conditionStr = "("..getlocal("activation") .. ")"
                tb["titleColor"] = G_ColorYellowPro
                print("----dmj----conditionStr:"..conditionStr)
                ifHasSuitEffect = true
                if k >= 5 then
                    ifHasSkillEffect = true
                end
                if k ~= 5 then
                    for m, n in pairs(v) do
                        bufNumTb[m] = n
                    end
                end
            else
                conditionStr = "("..num.."/"..maxNum..")"
            end
        end
        local title = getlocal("crystal_suit_title", {k})..conditionStr..":"
        tb["title"] = title
        tb["desc"] = {}
        tb["level"] = k
        -- end
        for kk, vv in pairs(v) do
            local msg = ""
            if tonumber(kk) == 1 then
                msg = getlocal("property_superweapon")
            else
                if kk == "first" or kk == "antifirst" then
                    local pkey = buffKeyMatchCodeCfg[kk]
                    msg = getlocal(buffEffectCfg[pkey].name)
                else
                    msg = getlocal(buffEffectCfg[kk].name)
                end
            end
            if (tonumber(kk) and (tonumber(kk) > 200 or tonumber(kk) == 1)) or kk == "antifirst" then
                msg = msg..":+"..vv
            else
                if kk == "first" then
                    local addtext = getlocal("arena_numAdd")
                    local ours = getlocal("plat_war_our")
                    msg = addtext..ours..msg..":+"..vv
                else
                    msg = msg..":+" .. (tonumber(vv) * 100) .. "%"
                end
            end
            table.insert(tb["desc"], msg)
        end
        table.insert(result, tb)
        local function funcA(a, b)
            if a and b and a.level and b.level then
                return a.level < b.level
            end
        end
        table.sort(result, funcA)
    end
    return result, ifHasSuitEffect, ifHasSkillEffect, bufNumTb
end

-- 计算结晶的成功率,两个结晶的id
-- 成功率=（材料价值*亏损系数-失败收益）/(成功收益-失败收益）
function superWeaponVoApi:getMergePrecent(cid1, cid2, propNum)
    local precent = 0--百分比
    local crystalItem1 = superWeaponCfg.crystalCfg[cid1]
    local crystalItem2 = superWeaponCfg.crystalCfg[cid2]
    local crystalLevel1 = crystalItem1.lvl
    local crystalLevel2 = crystalItem2.lvl
    local propMaxNum = 0
    local basePrecent, addPrecent = 0, 0 --基础概率，道具额外加的概率
    local mergeLv = math.max(crystalLevel1, crystalLevel2) + 1
    if mergeLv and superWeaponCfg and superWeaponCfg.maxCLv and mergeLv > superWeaponCfg.maxCLv then
        mergeLv = superWeaponCfg.maxCLv
    end
    if crystalLevel1 == 1 and crystalLevel2 == 1 then
        precent = 1
        basePrecent = 1
    else
        local crystalRate = superWeaponCfg.crystalRate
        local rate = 0.85--亏损系数
        local curValue = crystalRate[crystalLevel1] + crystalRate[crystalLevel2]
        local failValue = 0
        local successValue = 0
        if crystalLevel1 >= crystalLevel2 then
            failValue = crystalRate[crystalLevel1 - 1]
            successValue = crystalRate[crystalLevel1 + 1]
        else
            failValue = crystalRate[crystalLevel2 - 1]
            successValue = crystalRate[crystalLevel2 + 1]
        end
        basePrecent = (curValue * rate - failValue) / (successValue - failValue)
        if superWeaponCfg and superWeaponCfg.addcrystalRate and superWeaponCfg.addcrystalRate.c200 and superWeaponCfg.addcrystalRate.c200.att then
            local addPer = superWeaponCfg.addcrystalRate.c200.att
            propMaxNum = math.ceil((1 - basePrecent) / addPer)
            if propNum then
                addPrecent = propNum * addPer
            end
        end
        precent = basePrecent + addPrecent
        if precent > 1 then
            precent = 1
        end
        precent = math.ceil(precent * 1000) / 1000
    end
    local precentLocalName = ""--百分比对应的文字描述，极高，一般等
    local color = G_ColorWhite
    if precent < 0.2 then
        precentLocalName = getlocal("merge_precent_name5")
        color = G_ColorRed
    elseif precent < 0.4 then
        precentLocalName = getlocal("merge_precent_name4")
        color = G_ColorRed
    elseif precent < 0.6 then
        precentLocalName = getlocal("merge_precent_name3")
        color = G_ColorYellowPro
    elseif precent < 0.8 then
        precentLocalName = getlocal("merge_precent_name2")
        color = G_ColorGreen
    else
        precentLocalName = getlocal("merge_precent_name1")
        color = G_ColorGreen
    end
    return precent, precentLocalName, basePrecent, addPrecent, color, propMaxNum, mergeLv
end

--根据id获取超级武器的superWeaponVo
function superWeaponVoApi:getWeaponByID(id)
    return self.weaponList[id]
end
--拥有的超级武器列表
function superWeaponVoApi:getWeaponList()
    return self.weaponList
end
--购买的专家次数
function superWeaponVoApi:getExpertList()
    return self.expertList
end
--拥有的道具
function superWeaponVoApi:getPropList()
    return self.propList
end

--拥有的碎片列表
function superWeaponVoApi:getFragmentList()
    return self.fragmentList
end

--拥有的碎片列表
function superWeaponVoApi:getFragmentNum(fragmentId)
    local num = 0
    if fragmentId then
        local fList = self:getFragmentList()
        for k, v in pairs(fList) do
            if k == fragmentId then
                num = tonumber(v)
            end
        end
    end
    return num
end

--设置碎片数量，为0则为nil
function superWeaponVoApi:setFragmentNum(fragmentId, num)
    if fragmentId and num and tonumber(num) then
        local leftNum = tonumber(num)
        for k, v in pairs(self.fragmentList) do
            if k == fragmentId then
                self.fragmentList[k] = leftNum
            end
        end
    end
end

--已经装备上的武器列表
function superWeaponVoApi:getEquipList()
    return self.equipList
end

-- 获取结晶icon
function superWeaponVoApi:getCrystalIcon(cid, clickHandler)
    local crystalVo = self:getCrystalVoByCid(cid)
    if crystalVo then
        return crystalVo:getIconSp(clickHandler)
    end
end
--获取碎片的图片 fid:碎片id
function superWeaponVoApi:getFragmentIcon(fid, clickHandler, isGray)
    if fid and superWeaponCfg.fragmentCfg and superWeaponCfg.fragmentCfg[fid] then
        local cfg = superWeaponCfg.fragmentCfg[fid]
        if cfg then
            if cfg.icon and cfg.output and superWeaponCfg.weaponCfg[cfg.output] then
                local quality = superWeaponCfg.weaponCfg[cfg.output].quality
                local function callback()
                    if clickHandler then
                        clickHandler()
                    end
                end
                local bgSp
                if quality == 2 then
                    bgSp = LuaCCSprite:createWithSpriteFrameName("PurpleBox.png", callback)
                else
                    bgSp = LuaCCSprite:createWithSpriteFrameName("BlueBox.png", callback)
                end
                local fragmentSp
                if isGray == true then
                    local graySp
                    if quality == 2 then
                        graySp = GraySprite:createWithSpriteFrameName("PurpleBox.png")
                    else
                        graySp = GraySprite:createWithSpriteFrameName("BlueBox.png")
                    end
                    graySp:setPosition(getCenterPoint(bgSp))
                    bgSp:addChild(graySp)
                    fragmentSp = GraySprite:createWithSpriteFrameName(cfg.icon)
                else
                    fragmentSp = CCSprite:createWithSpriteFrameName(cfg.icon)
                end
                fragmentSp:setPosition(getCenterPoint(bgSp))
                bgSp:addChild(fragmentSp, 1)
                return bgSp
            end
        end
    end
    
end

-- 获取所有的结晶数据
function superWeaponVoApi:getAllEnergycrastal()
    local function sortFunc(a, b)
        if a and b and a:getLevel() and b:getLevel() and a:getLevel() == b:getLevel() then
            if a and b then
                return a:getSortId() > b:getSortId()
            end
        else
            return a:getLevel() > b:getLevel()
        end
    end
    table.sort(self.crystalVoList, sortFunc)
    return self.crystalVoList
end

function superWeaponVoApi:getSWChallengeMaxFloor()
    local challenge = self:getSWChallenge()
    local maxFloor
    if(challenge)then
        maxFloor = challenge.maxClearPos or 0
    else
        maxFloor = 0
    end
    
    return maxFloor
end

--获取玩家解锁的宝石槽位
--return 0或1或2或3...解锁了几个宝石槽
function superWeaponVoApi:getUnlockSlot()
    local challenge = self:getSWChallenge()
    local maxFloor
    if(challenge)then
        maxFloor = challenge.maxClearPos or 0
    else
        maxFloor = 0
    end
    local slots = 0
    for k, v in pairs(superWeaponCfg.unlockCrystal) do
        if(maxFloor >= v)then
            slots = slots + 1
        end
    end
    return slots
end

-- 根据类别获取某一类的结晶
function superWeaponVoApi:getEnergycrystalByType(rtype)
    local list = {}
    for k, v in pairs(self.crystalVoList) do
        if v and v:getColorType() == rtype then
            table.insert(list, v)
        end
    end
    local function sortFunc(a, b)
        if a and b and a:getLevel() and b:getLevel() and a:getLevel() == b:getLevel() then
            if a and b then
                return a:getSortId() > b:getSortId()
            end
        else
            return a:getLevel() > b:getLevel()
        end
    end
    table.sort(list, sortFunc)
    return list
end

-- 获取一键合成数据
function superWeaponVoApi:getMergeAllListByType(rtype)
    local maxLevel = 4--最高可以升级到5
    local list = {}
    -- local newlist = {}
    for k, v in pairs(self.crystalVoList) do
        if v and v:getColorType() == rtype and v:getLevel() <= maxLevel and v.num > 1 then
            local num = v.num
            if num % 2 ~= 0 then
                num = num - 1
            end
            if list[tostring(v:getLevel())] == nil then
                list[tostring(v:getLevel())] = {}
                list[tostring(v:getLevel())][v.id] = {level = v:getLevel(), num = num, name = v:getLocalName()}
            else
                list[tostring(v:getLevel())][v.id] = {level = v:getLevel(), num = num, name = v:getLocalName()}
            end
        end
    end
    -- local function funcA(a,b)
    -- if a and b and a.level and b.level then
    -- return a.level<b.level
    -- end
    -- end
    return list
end

function superWeaponVoApi:getFragmentNameAndDesc(fid)
    local nameStr, descStr = "", ""
    if fid and superWeaponCfg and superWeaponCfg.fragmentCfg and superWeaponCfg.fragmentCfg[fid] and superWeaponCfg.fragmentCfg[fid].pos then
        local pos = superWeaponCfg.fragmentCfg[fid].pos
        local id = (tonumber(fid) or tonumber(RemoveFirstChar(fid)))
        if id then
            if id <= 20 then
                local index = math.ceil(id / 5)
                nameStr = getlocal("superWeapon_fragment_name_"..index, {pos})
                descStr = getlocal("superWeapon_fragment_desc_"..index, {pos})
            else
                local index = math.ceil((id - 20) / 6) + (20 / 5)
                nameStr = getlocal("superWeapon_fragment_name_"..index, {pos})
                descStr = getlocal("superWeapon_fragment_desc_"..index, {pos})
            end
        end
    end
    return nameStr, descStr
end

-------------------以下神秘组织关卡-------------------
function superWeaponVoApi:setSWChallenge(cData)
    require "luascript/script/game/gamemodel/superWeapon/swChallengeVo"
    local cVo = swChallengeVo:new()
    cVo:initWithData(cData)
    self.swChallenge = cVo
end
function superWeaponVoApi:getSWChallenge()
    return self.swChallenge
end

--今日最大重置次数
function superWeaponVoApi:getResetMaxNum()
    local resetTab = swChallengeCfg.resetNum
    local vipLevel = playerVoApi:getVipLevel()
    local maxResetNum = resetTab[vipLevel + 1]
    local freeNum = swChallengeCfg.freeResetNum
    local maxNum = maxResetNum + freeNum
    return maxNum
end
--今日剩余重置次数
function superWeaponVoApi:getLeftResetNum()
    local leftNum = 0
    local maxNum = self:getResetMaxNum()
    local cVo = self:getSWChallenge()
    local lastRestTime = cVo.lastRestTime
    if G_isToday(lastRestTime) == false then
        leftNum = maxNum
    else
        leftNum = maxNum - cVo.resetNum
    end
    return leftNum
end
--今日本次重置消耗金币数
function superWeaponVoApi:getResetCost()
    local costGems = 0
    local freeNum = swChallengeCfg.freeResetNum
    local cVo = self:getSWChallenge()
    local lastRestTime = cVo.lastRestTime
    if(lastRestTime == nil)then
        costGems = nil
    elseif G_isToday(lastRestTime) == false then
        costGems = 0
    else
        if freeNum - cVo.resetNum > 0 then
            costGems = 0
        elseif cVo.resetNum > 0 then
            costGems = swChallengeCfg.resetGems[cVo.resetNum - freeNum + 1]
        end
    end
    return costGems
end
--今日挑战次数用尽时，根据vip等级，可额外购买的次数
function superWeaponVoApi:getBuyMaxNum()
    local buyTab = swChallengeCfg.challengeBuyNum
    local vipLevel = playerVoApi:getVipLevel()
    local maxBuyNum = buyTab[vipLevel + 1]
    return maxBuyNum
end

--加速扫荡需要消耗的金币，time：剩余时间
function superWeaponVoApi:raidSpeedUpCost(time)
    return math.ceil(time / 60) * swChallengeCfg.raidSpeed
end

--index:第几层
function superWeaponVoApi:getClearConditionStr(index)
    local str = getlocal("super_weapon_challenge_condition_killAll")
    if index and swChallengeCfg.list[index] then
        local cfg = swChallengeCfg.list[index]
        if cfg and cfg.condition then
            for k, v in pairs(cfg.condition) do
                if type(v) == "table" then
                    if k == "myUseType" then
                        local parms = {}
                        for m, n in pairs(v) do
                            local tTypeStr = ""
                            local tType = tonumber(n[1])
                            if tType == 1 then
                                tTypeStr = getlocal("tanke")
                            elseif tType == 2 then
                                tTypeStr = getlocal("jianjiche")
                            elseif tType == 4 then
                                tTypeStr = getlocal("zixinghuopao")
                            elseif tType == 8 then
                                tTypeStr = getlocal("huojianche")
                            end
                            table.insert(parms, tonumber(n[2]))
                            table.insert(parms, tTypeStr)
                        end
                        str = getlocal("super_weapon_challenge_condition_"..k, parms)
                    end
                else
                    local num = tonumber(v)
                    if k == "myDieNum" then
                        num = num * 100
                    end
                    str = getlocal("super_weapon_challenge_condition_"..k, {num})
                end
            end
        end
    end
    return str
end

--扫荡剩余时间
function superWeaponVoApi:getRaidLeftTime()
    local leftTime = 0
    local cVo = self:getSWChallenge()
    if cVo and cVo.raidEndTime then
        if cVo.raidEndTime > 0 and base.serverTime < cVo.raidEndTime then
            leftTime = cVo.raidEndTime - base.serverTime
        end
    end
    return leftTime
end

function superWeaponVoApi:getSWChallengeName(swId)
    local nameStr = ""
    if swId then
        -- nameStr=getlocal("superWeapon_challenge_name",{swId})
        nameStr = getlocal("super_weapon_challenge_floors", {swId})
    end
    return nameStr
end

function superWeaponVoApi:clearCRankData()
    for k, v in pairs(self.cRankData) do
        self.cRankData[k] = nil
    end
    self.cRankData = {}
end
function superWeaponVoApi:getCRankData()
    return self.cRankData
end

function superWeaponVoApi:getRaidFloor()
    local curFloor, leftFloor = 0, 0
    local cVo = self:getSWChallenge()
    local leftTime = self:getRaidLeftTime()
    if cVo and leftTime and leftTime > 0 then
        leftFloor = math.ceil(leftTime / swChallengeCfg.raidTime)
        curFloor = cVo.raidEndIndex - leftFloor + 1
    end
    return curFloor, leftFloor
end
-------------------以上神秘组织关卡-------------------

-------------------以下抢夺部分-------------------
-- 抢夺列表
function superWeaponVoApi:getRobList()
    return self.robList
end

-- 根据概率获取文字
function superWeaponVoApi:getRateStr(rate)
    local str = ""
    local color = G_ColorWhite
    local rateCfg = weaponrobCfg.rate
    if rate < rateCfg[1] then
        str = getlocal("super_weapon_rob_success_rate_1")
        color = G_ColorGreen
    elseif rate < rateCfg[2] then
        str = getlocal("super_weapon_rob_success_rate_2")
        color = G_ColorBlue
    elseif rate <= rateCfg[3] then
        str = getlocal("super_weapon_rob_success_rate_3")
        color = G_ColorPurple
    end
    return str, color
end

function superWeaponVoApi:getEnergy()
    return self.energy
end
function superWeaponVoApi:setEnergy(energy)
    self.energy = energy
end
function superWeaponVoApi:getEnergyUpdateTime()
    return self.energyUpdateTime
end
function superWeaponVoApi:setEnergyUpdateTime(energyUpdateTime)
    self.energyUpdateTime = energyUpdateTime
end
function superWeaponVoApi:getEnergyBuyNum()
    local lastBuyTime = self:getLastBuyTime()
    if G_isToday(lastBuyTime) == false then
        self.energyBuyNum = 0
    end
    return self.energyBuyNum
end
function superWeaponVoApi:setEnergyBuyNum(energyBuyNum)
    self.energyBuyNum = energyBuyNum
end
function superWeaponVoApi:getLastBuyTime()
    return self.lastBuyTime
end
function superWeaponVoApi:setLastBuyTime(lastBuyTime)
    self.lastBuyTime = lastBuyTime
end
function superWeaponVoApi:getProtectTime()
    return self.protectTime
end
function superWeaponVoApi:setProtectTime(protectTime)
    self.protectTime = protectTime
end
function superWeaponVoApi:getFragmentFlag()
    return self.fragmentFlag
end
function superWeaponVoApi:setFragmentFlag(fragmentFlag)
    self.fragmentFlag = fragmentFlag
end
function superWeaponVoApi:getRefreshNum()
    local lastBuyRefreshTime = self:getLastBuyRefreshTime()
    if G_isToday(lastBuyRefreshTime) == false then
        self.refreshNum = 0
    end
    return self.refreshNum
end
function superWeaponVoApi:setRefreshNum(refreshNum)
    self.refreshNum = refreshNum
end
function superWeaponVoApi:getLastFreeRefreshTime()
    return self.lastFreeRefreshTime
end
function superWeaponVoApi:setLastFreeRefreshTime(lastFreeRefreshTime)
    self.lastFreeRefreshTime = lastFreeRefreshTime
end
function superWeaponVoApi:getLastBuyRefreshTime()
    return self.lastBuyRefreshTime
end
function superWeaponVoApi:setLastBuyRefreshTime(lastBuyRefreshTime)
    self.lastBuyRefreshTime = lastBuyRefreshTime
end

function superWeaponVoApi:freeRefreshLeftTime()
    local freeCd = weaponrobCfg.refreshRobListFreeCd
    local lastTime = self:getLastFreeRefreshTime()
    local leftTime = freeCd - (base.serverTime - lastTime)
    if leftTime < 0 then
        leftTime = 0
    end
    return leftTime
end

function superWeaponVoApi:getBuyRefreshCost()
    local num = self:getRefreshNum()
    local refCfg = weaponrobCfg.refreshRobListGems
    local costGems = refCfg[1]
    if num then
        if num + 1 > SizeOfTable(refCfg) then
            costGems = refCfg[SizeOfTable(refCfg)]
        else
            costGems = refCfg[num + 1]
        end
    end
    return costGems
end

function superWeaponVoApi:setCurEnergy(fsync)
    local energyNum = self:getEnergy()
    local maxNum = weaponrobCfg.energyMax
    local nextCd = 0
    local energy = 0
    local perTime = superWeaponVoApi:getEnergyRecoveryTime()
    local lastUpdateTime = self:getEnergyUpdateTime()
    if lastUpdateTime > 0 then
        local passTime = base.serverTime - lastUpdateTime
        local addEnergy = math.floor(passTime / perTime)
        nextCd = ((perTime - passTime) % perTime)
        energy = energyNum + addEnergy
        if addEnergy > 0 and fsync == true then
            local up_at = base.serverTime + addEnergy * perTime
            superWeaponVoApi:setEnergyUpdateTime(up_at)
            superWeaponVoApi:setEnergy(math.min(energy, maxNum))
        end
    else
        energy = energyNum
        nextCd = 0
    end
    if energy >= maxNum then
        if energyNum >= maxNum then
            energy = energyNum
        else
            energy = maxNum
        end
        nextCd = 0
    end
    return energy, nextCd
end

--获取恢复
function superWeaponVoApi:getEnergyRecoveryTime()
    local rate = planeRefitVoApi:getSkvByType(61)
    return math.floor(weaponrobCfg.energyRecovery * (1 - rate))
end

function superWeaponVoApi:getMaxBuyNum()
    local buyNumTab = weaponrobCfg.energyGemsBuyNum
    local vipLevel = playerVoApi:getVipLevel()
    local maxBuyNum = buyNumTab[vipLevel + 1]
    return maxBuyNum
end
function superWeaponVoApi:getEnergyGemsBuyCost()
    local costGems = weaponrobCfg.energyGemsBuyCost[1]
    local energyBuyNum = self:getEnergyBuyNum()
    if energyBuyNum then
        if energyBuyNum + 1 > SizeOfTable(weaponrobCfg.energyGemsBuyCost) then
            costGems = weaponrobCfg.energyGemsBuyCost[SizeOfTable(weaponrobCfg.energyGemsBuyCost)]
        else
            costGems = weaponrobCfg.energyGemsBuyCost[energyBuyNum + 1]
        end
    end
    return costGems
end
--是否在和平时段
function superWeaponVoApi:checkInPeaceTime()
    local systemProtectTime = weaponrobCfg.systemStop
    local dayTime = base.serverTime - G_getWeeTs(base.serverTime)
    if systemProtectTime and systemProtectTime[1] and systemProtectTime[2] and dayTime >= systemProtectTime[1] and dayTime <= systemProtectTime[2] then
        return true
    end
    return false
end

function superWeaponVoApi:getMaxNum()
    return self.maxNum
end

function superWeaponVoApi:getFlag()
    return self.flag
end
function superWeaponVoApi:setFlag(flag)
    self.flag = flag
end

function superWeaponVoApi:getTotalNum()
    return self.totalNum
end
function superWeaponVoApi:setTotalNum(totalNum)
    self.totalNum = totalNum
end
function superWeaponVoApi:getUnreadNum()
    return self.unreadNum
end
function superWeaponVoApi:setUnreadNum(unreadNum)
    self.unreadNum = unreadNum
end

function superWeaponVoApi:getReportList()
    if self.reportList == nil then
        self.reportList = {}
    end
    return self.reportList
end

function superWeaponVoApi:clearReportList()
    self.reportList = {}
end

function superWeaponVoApi:getNum()
    local num = 0
    local list = self:getReportList()
    if list then
        num = SizeOfTable(list)
    end
    return num
end

function superWeaponVoApi:getReport(rid)
    local list = self:getReportList()
    if list then
        for k, v in pairs(list) do
            if v.rid == rid then
                return v
            end
        end
    end
    return nil
end

function superWeaponVoApi:isNPC(uid)
    if type(uid) == "number" and uid <= 10 then
        return true
    end
    return false
end

function superWeaponVoApi:addReport(data, isAddReport)
    if data then
        require "luascript/script/game/gamemodel/superWeapon/robReportVo"
        for k, v in pairs(data) do
            if k == "maxrows" then
                if v and tonumber(v) then
                    self:setTotalNum(tonumber(v) or 0)
                end
            elseif k == "unread" then
                if v and tonumber(v) then
                    self:setUnreadNum(tonumber(v) or 0)
                end
            elseif isAddReport ~= false then
                local rid = tonumber(v.eid)
                local uid = playerVoApi:getUid()
                local name = playerVoApi:getPlayerName()
                local enemyId = tonumber(v.receiver) or 0
                local enemyName = v.receivername or ""
                if self:isNPC(enemyId) == true then
                    enemyName = getlocal("super_weapon_rob_npc_name_"..enemyId)
                end
                local time = tonumber(v.ts) or 0
                local isVictory = tonumber(v.isvictory) or 0
                local robSuccess = tonumber(v.rob) or 0
                local isRead = tonumber(v.isRead) or 0
                local robInfo = v.robinfo
                local wid
                local wLevel = 0
                local fid
                local elementNum
                if type(robInfo) == "string" then
                    local infoTb = Split(robInfo, "-")
                    wid = infoTb[1]
                    wLevel = tonumber(infoTb[2]) or 0
                    fid = infoTb[3]
                    elementNum = infoTb[4] or 0
                end
                local isHas = false
                for m, n in pairs(self.reportList) do
                    if n and n.rid == rid then
                        isHas = true
                    end
                end
                if isHas == false then
                    local vo = robReportVo:new()
                    vo:initWithData(rid, tonumber(v.type), uid, name, enemyId, enemyName, time, isRead, isVictory, robSuccess, wid, wLevel, fid, nil, elementNum)
                    table.insert(self.reportList, vo)
                end
            end
        end
        if self.reportList and SizeOfTable(self.reportList) > 0 then
            local function sortAsc(a, b)
                if a and b and a.rid and b.rid then
                    return a.rid > b.rid
                end
            end
            table.sort(self.reportList, sortAsc)
        end
        local maxNum = self:getMaxNum()
        local totalNum = self:getTotalNum()
        if totalNum > maxNum then
            self:setTotalNum(maxNum)
        end
        local unreadNum = self:getUnreadNum()
        if unreadNum > maxNum then
            self:setUnreadNum(unreadNum)
        end
        while self:getNum() > maxNum do
            table.remove(self.reportList, self:getNum())
        end
        return vo
    end
    return nil
end

-- 单独请求report
function superWeaponVoApi:addReportHeroAccesoryAndLostship(rid, content)
    local report = {}
    if content then
        if content.report then
            report = content.report
        end
    end
    local list = self:getReportList()
    if list then
        for k, v in pairs(list) do
            if v.rid == rid then
                v.report = report or {}
                v.initReport = true
            end
        end
    end
end

function superWeaponVoApi:hasMore()
    if self.totalNum > 0 then
        if self.totalNum > self:getNum() then
            return true
        end
    end
    return false
end

function superWeaponVoApi:setIsRead(rid)
    if self.reportList then
        for k, v in pairs(self.reportList) do
            if tostring(rid) == tostring(v.rid) then
                if v.isRead == 0 then
                    v.isRead = 1
                    
                    local unreadNum = self:getUnreadNum()
                    unreadNum = unreadNum - 1
                    if unreadNum < 0 then
                        unreadNum = 0
                    end
                    self:setUnreadNum(unreadNum)
                end
            end
        end
    end
end

function superWeaponVoApi:getMinAndMaxRid()
    local minrid, maxrid = 0, 0
    local num = self:getNum()
    local list = self:getReportList()
    if list and self:getNum() > 0 then
        minrid, maxrid = list[num].rid, list[1].rid
    end
    return minrid, maxrid
end

-------------------以上抢夺部分-------------------

function superWeaponVoApi:tick()
    local cVo = self:getSWChallenge()
    if cVo and cVo.raidStartIndex and cVo.raidEndTime then
        -- if cVo.raidStartIndex>0 and cVo.raidEndTime>0 and base.serverTime<cVo.raidEndTime and base.serverTime>cVo.raidStartIndex then
        -- local passTime=base.serverTime-cVo.raidStartIndex
        -- local addFloors=math.floor(passTime/swChallengeCfg.raidTime)
        -- self.swChallenge.curClearPos=self.swChallenge.curClearPos+addFloors
        -- else
        -- print("cVo.raidEndTime====>>>>>",cVo.raidEndTime)
        if (base.serverTime - cVo.raidEndTime >= 0) and (base.serverTime - cVo.raidEndTime < 5) then
            local function finishCallback()
            end
            if self.hasCallback == nil then
                self:raidChallengeFinish(false, finishCallback)
                self.hasCallback = 0
            end
            
        elseif cVo.raidEndTime > 0 and base.serverTime - cVo.raidEndTime > 5 and cVo.hasCallback == nil then
            local _maxPos = tonumber(cVo.maxClearPos) or 0
            local _curPos = tonumber(cVo.curClearPos) or 0
            if _curPos == 0 and cVo.resetNum > 0 then
                cVo.hasCallback = 0
                -- print("=====超级武器神秘组织 后台回到游戏 调用结束端口=====")
                self:raidChallengeFinish(false, function() end)
            end
        end
    end
    if(self.initFlag == false)then
        local function onInitEnd()
            superWeaponVoApi:initChallenge(onGetChallenge)
        end
        superWeaponVoApi:init(onInitEnd)
    end
end

-- 判断是否可以掠夺玩家
function superWeaponVoApi:isCanPlunder()
    for k, v in pairs(superWeaponCfg.weaponCfg) do
        local vo = self:getWeaponByID(k)
        if vo == nil or vo.lv < superWeaponCfg.maxLv then
            return false
        end
    end
    return true
end

function superWeaponVoApi:getShowRaidFinishData()
    return self.showRaidFinishData
end
function superWeaponVoApi:setShowRaidFinishData(showRaidFinishData)
    self.showRaidFinishData = showRaidFinishData
end

function superWeaponVoApi:getWeaponColorByQuality(wid)
    local wData = superWeaponCfg.weaponCfg[wid]
    if wData then
        if wData.quality then
            if wData.quality == 1 then
                return G_ColorBlue
            elseif wData.quality == 2 then
                return G_ColorPurple
            else
                return G_ColorPurple
            end
        else
            return G_ColorBlue
        end
    end
    return G_ColorBlue
end

--判断超级武器掠夺功能是否开启
function superWeaponVoApi:isWeaponRobUnlock()
    local playerLv = playerVoApi:getPlayerLevel()
    if playerLv < base.superWeaponOpenLv then
        return false
    else
        local challengeVo = self:getSWChallenge()
        if challengeVo and challengeVo.maxClearPos then
            if(tonumber(challengeVo.maxClearPos) > 0)then
                return true
            end
        end
    end
    return false
end

function superWeaponVoApi:showFinalChallengeDialog(layerNum)
    local function initChallengeCallback()
        local cVo = self:getSWChallenge()
        if cVo then
            if cVo.raidEndTime > 0 and base.serverTime > cVo.raidEndTime then
                local function finishCallback()
                    self:showChallengeDialog(layerNum)
                end
                self:raidChallengeFinish(false, finishCallback, true)
            else
                self:showChallengeDialog(layerNum)
            end
        end
    end
    self:initChallenge(initChallengeCallback)
end

function superWeaponVoApi:getShowTips()
    return self.showRaidFinishData
end
function superWeaponVoApi:setShowTips(showTips)
    self.showTips = showTips
end

--有些玩家的超级武器已经满级，但是因为各种原因可能还有碎片没有转化为纳米原件，所以做一个检测修复
function superWeaponVoApi:fixMaxFragment(callback)
    local tmpTb = {}
    for fragmenID, num in pairs(superWeaponVoApi:getFragmentList()) do
        local fragmentCfg = superWeaponCfg.fragmentCfg[fragmenID]
        if(fragmentCfg and num > 0)then
            local outputID = fragmentCfg.output
            if(tmpTb[outputID] == nil)then
                local weaponVo = superWeaponVoApi:getWeaponByID(outputID)
                if(weaponVo and weaponVo.lv >= superWeaponCfg.maxLv)then
                    tmpTb[outputID] = 1
                    self.fragmentList[fragmenID] = 0
                end
            else
                self.fragmentList[fragmenID] = 0
            end
        end
    end
    local fixTb = {}
    for weaponID, v in pairs(tmpTb) do
        table.insert(fixTb, weaponID)
    end
    if(#fixTb > 0)then
        local function onRequestEnd(fn, data)
            local ret, sData = base:checkServerData(data)
            if ret == true then
                if(sData.data.weapon)then
                    self:formatData(sData.data.weapon)
                end
                if(callback)then
                    callback()
                end
            end
        end
        socketHelper:superWeaponFix(fixTb, onRequestEnd)
    else
        if(callback)then
            callback()
        end
    end
end

function superWeaponVoApi:setContinuousExp(newSet)
    if newSet then
        self.continuousExp = newSet
    end
end
function superWeaponVoApi:getContinuousExp()
    return self.continuousExp
end
function superWeaponVoApi:getAwardListAndUsePropList()
    local awardList, usePropList = {}, {}
    local newGf = {}
    for k, v in pairs(self.exploreTb) do
        if v.res then
            local formatTb = FormatItem(v.res)
            for m, n in pairs(formatTb) do
                G_addPlayerAward(n.type, n.key, n.id, n.num)
            end
            awardList[k] = formatTb
        end
        if v.addount and v.addount > 0 then
            newGf = {addount = v.addount}
        elseif v.gf then
            newGf = {gf = v.gf}
        end
        if v.p > 0 then
            usePropList[k] = {p = v.p}
        end
        if v.g > 0 then
            usePropList[k] = {g = v.g}
        end
    end
    return awardList, usePropList, SizeOfTable(newGf) > 0 and newGf or nil
end

--exploreFlag
function superWeaponVoApi:getExploreFlag()
    return self.exploreFlag
end
function superWeaponVoApi:setExploreFlag(newFlag)
    self.exploreFlag = newFlag
end

-- 通过id获取结晶数量
function superWeaponVoApi:getCrystalNumByCid(cid)
    if self.crystalVoList then
        for k, v in pairs(self.crystalVoList) do
            if tostring(v.id) == tostring(cid) then
                return v.num
            end
        end
    end
    return 0
end

--拿到装配的超级武器 总等级 和结晶的 总等级
function superWeaponVoApi:getWeaponAndCrystalLevels()
    local weaponLv, crystalLv = 0, 0
    -- if self.weaponList and self.equipList then
    -- for idx,usedKey in pairs(self.equipList) do
    -- for k,v in pairs(self.weaponList) do
    -- if usedKey == k then
    -- for m,n in pairs(v) do
    -- if m == "lv" then
    -- weaponLv = weaponLv + n
    -- end
    -- end
    -- end
    -- end
    -- end
    -- end
    if self.weaponList then
        for k, v in pairs(self.weaponList) do
            for m, n in pairs(v) do
                if m == "slots" then
                    for kk, vv in pairs(n) do
                        local crystalItem = superWeaponCfg.crystalCfg[vv]
                        local crystalLevel = crystalItem.lvl
                        crystalLv = crystalLv + crystalLevel
                    end
                elseif m == "lv" then
                    weaponLv = weaponLv + n
                end
            end
        end
    end
    
    return weaponLv, crystalLv
end

function superWeaponVoApi:showSecondConfirm(layerNum, istouch, isuseami, titleStr, contentDes, isCheck, callback1, callback2, cancelCallback, desInfo, addStrTb, btn1, btn2, closeFlag, spicalTb)
    require "luascript/script/game/scene/gamedialog/swExploreSmallDialog"
    return swExploreSmallDialog:showListProp(layerNum, istouch, isuseami, titleStr, contentDes, isCheck, callback1, callback2, cancelCallback, desInfo, addStrTb, btn1, btn2, closeFlag, spicalTb)
end
function superWeaponVoApi:getBlueprintItem(fid, level, iconSize, bgSize)
    local fName, fDesc = self:getFragmentNameAndDesc(fid)
    local nameStr = getlocal("fightLevel", {level})..fName
    local blueprintItem = {}
    blueprintItem.num = 1
    blueprintItem.name = fName
    blueprintItem.desc = fDesc
    blueprintItem.icon = self:getFragmentIcon(fid, function() end)
    blueprintItem.iconBg = "Icon_BG.png"
    blueprintItem.iconSize = iconSize or 95
    blueprintItem.bgSize = bgSize or 90
    blueprintItem.universal = true
    blueprintItem.hasIcon = true
    blueprintItem.noLocal = true
    return blueprintItem
end
function superWeaponVoApi:clear()
    self.continuousExp = false
    self.initFlag = false
    self.weaponList = {}
    self.fragmentList = {}
    self.equipList = {}
    self.swChallenge = {}
    self:clearCRankData()
    self.robList = {}
    self.flag = -1
    self.totalNum = 0
    self.unreadNum = 0
    self.maxNum = 50
    self.energy = 0
    self.energyBuyNum = 0
    self.lastBuyTime = 0
    self.protectTime = 0
    self.fragmentFlag = -1
    self.refreshNum = 0
    self.lastFreeRefreshTime = 0
    self.lastBuyRefreshTime = 0
    self.reportList = {}
    self.showRaidFinishData = nil
    self.hasCallback = nil
    self.addPerPropData = nil
    self.protectPropData = nil
    self.showTips = nil
    self.exploreTb = nil
end
