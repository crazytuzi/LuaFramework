-- 异星武器
function model_alienweapon(uid,data)
    local self = {
        uid = uid,
        info={aw1={0,0} }, -- 武器 [1] 武器等级 [2] 技能等级（强化等级）
        used={}, --装配的
        fragment={}, --碎片
        props={}, --道具
        trade={}, -- 护航出战信息
        tinfo={}, --  护航信息
        sinfo={}, -- 海域探索
        jewelinfo1={}, -- 1-9级宝石
        jewelinfo2={}, -- 10级宝石
        jewelused={}, -- 镶嵌的宝石
        crystal=0, -- 宝石结晶
        stive=0,-- 宝石粉尘
        exp=0, -- 武器经验池
        y1=0, -- 分解掉的碎片资源
        tflag=0, -- 正在护航标志
        updated_at = 0,
    }

    function self.bind(data)
        if type(data) ~= 'table' then
            return false
        end
        
        for k,v in pairs (self) do
            local vType = type(v)
            if vType~="function" then
                if data[k] == nil then return false end
                if vType == 'number' then
                    self[k] = tonumber(data[k]) or data[k]
                else
                    self[k] = data[k]
                end
            end
        end

        return true
    end

    function self.toArray(format)
        local avoidkeys = {"jewelinfo1","jewelinfo2","jewelused","crystal","stive"}
        local data = {}
        for k,v in pairs (self) do
            if type(v)~="function" and k~= 'uid' and k~= 'updated_at' then              
                if format then
                    if not table.contains(avoidkeys,k) then
                        if type(v) == 'table'  then
                            data[k] = v
                        elseif v~='' then
                            data[k] = v
                        end
                    end
                else
                    data[k] = v
                end
            end
        end

        return data
    end

    -- 获得武器
    function self.addWeapon(wid, params)
        --异星武器没有数量概念
        local cfg = getConfig("alienWeaponCfg")
        if not wid or not cfg.weaponList[wid] then return false end
        if self.isGetWeapon(wid) then 
            -- 直接转换成碎片
            local propCfg = cfg.levelStreng[cfg.weaponList[wid].color]
            local fid = cfg.weaponList[wid].fragment
            if not self.addFragment(fid, cfg.fragmentList[fid].cost) then
                return false
            end
            return true
        end

        -- [武器id] = {武器等级，强化等级}
        self.info[wid] = params or {0, 0}
        return true
    end

    -- 存在该武器
    function self.isGetWeapon(wid)
        return type(self.info[wid]) == 'table'
    end

    -- 分解装备
    function self.resolveWeapon(wid)
        if not wid or type(self.info[wid]) ~= 'table' then
            return false
        end

        local lvl = self.info[wid][1]
        local strenlvl = self.info[wid][2]

        local cfg = getConfig('alienWeaponCfg')
        local allexp = 0
        --升级经验
        local expCfg =cfg.levelupexp[cfg.weaponList[wid].color]
        for i=1, lvl do
            allexp = allexp + expCfg[i]
        end

        --强化消耗
        local consume = {}
        local propCfg = cfg.levelStreng[cfg.weaponList[wid].color]
        local fid = cfg.weaponList[wid].fragment
        for i=1, strenlvl do
            consume[fid] = (consume[fid] or 0) + propCfg[i].af
            for k, v in pairs(cfg.weaponList[wid].stuff) do
                consume[v] = (consume[v] or 0) + propCfg[i].stuff[k]
            end
        end
        -- 武器合成消耗
        consume[fid] = (consume[fid] or 0) + cfg.fragmentList[fid].cost

        -- 加道具
        local rw = {}
        for k, v in pairs(consume) do
            rw["aweapon_" .. k] = math.floor(v * cfg.returnProportion)
        end
        -- 加经验
        if allexp > 0 then
            rw['aweapon_exp'] = math.floor(allexp * cfg.returnProportion)
        end
        
        if not takeReward(self.uid, rw) then
            return false
        end

        -- 删除武器
        self.info[wid] = nil

        -- 日志
        regKfkLogs(self.uid,'item',{
                item_id=wid,
                item_op_cnt=-1,
                item_before_op_cnt= 1,
                item_after_op_cnt= 0,
                item_pos='异星武器',
                flags={'item_id'},
                merge={'item_op_cnt'},
                rewrite={'item_after_op_cnt'},
                addition={
                    {desc="等级",lv=lvl},
                    {desc="强化等级",slv=strenlvl},
                    {desc="返还奖励",r={prop=consume, exp=allexp}},
                },
            }
        )

        return {prop=consume, exp=allexp}
    end

    -- 装配武器
    function self.usedWeapon(wlist)
        if type(wlist) == 'table' and #wlist<=6 then
            self.used = wlist
            -- 初始化宝石孔
            for k,v in pairs(wlist) do
                if v~='' and v~='0' and v~=0 and not self.jewelused[v]  then
                    self.jewelused[v] = {0,0,0}
                end
            end

            -- 成就
            updatePersonAchievement(self.uid,{'a5'})
            return true
        end

        return false
     end 

    -- 升级武器
    function self.levelupWeapon(wid, addlvl)
        -- body
        addlvl = tonumber(addlvl) or 0
        if not wid or not self.info[wid] then return false end
        if addlvl <= 0 then return false end

        self.info[wid][1] = self.info[wid][1] + addlvl
        return true
    end

    -- 强化武器
    function self.strengthenWeapon(wid, addlvl )
        -- body
        addlvl = tonumber(addlvl) or 0
        if not wid or not self.info[wid] then return false end
        if addlvl <= 0 then return false end

        self.info[wid][2] = self.info[wid][2] + addlvl
        return true
    end

    -- 获得碎片
    function self.addFragment(fid, num)
        -- body
        if not fid or not tonumber(num) then return false end
        local bfnum = self.fragment[fid] or 0

        self.fragment[fid] = (self.fragment[fid] or 0) + tonumber(num)
        -- 日志
        regKfkLogs(self.uid,'item',{
                item_id=fid,
                item_op_cnt=num,
                item_before_op_cnt= bfnum,
                item_after_op_cnt= self.fragment[fid],
                item_pos='异星武器',
                flags={'item_id'},
                merge={'item_op_cnt'},
                rewrite={'item_after_op_cnt'},
                addition={
                },
            }
        )
        return true
    end

    -- 消耗碎片
    function self.useFragment(fid, num)
        -- body
        if not fid or not self.fragment[fid] then return false end
        if not tonumber(num) or self.fragment[fid] < tonumber(num) then return false end
        local bfnum = self.fragment[fid]

        self.fragment[fid] = self.fragment[fid] - tonumber(num)
        if self.fragment[fid] == 0 then
            self.fragment[fid] = nil
        end
        -- 日志
        regKfkLogs(self.uid,'item',{
                item_id=fid,
                item_op_cnt=-num,
                item_before_op_cnt= bfnum,
                item_after_op_cnt= self.fragment[fid] or 0,
                item_pos='异星武器',
                flags={'item_id'},
                merge={'item_op_cnt'},
                rewrite={'item_after_op_cnt'},
                addition={
                },
            }
        )
        
        return true
    end

    -- 获得材料道具
    function self.addProp(pid, num)
        -- body
        if not pid or not tonumber(num) then return false end
        local bfnum = self.props[pid] or 0
        self.props[pid] = (self.props[pid] or 0) + tonumber(num)
        -- 日志
        regKfkLogs(self.uid,'item',{
                item_id=pid,
                item_op_cnt=num,
                item_before_op_cnt= bfnum,
                item_after_op_cnt= self.props[pid] or 0,
                item_pos='异星武器',
                flags={'item_id'},
                merge={'item_op_cnt'},
                rewrite={'item_after_op_cnt'},
                addition={
                },
            }
        )

        return true
    end

    -- 消耗材料道具
    function self.useProp(pid, num)
        -- body
        if not pid or not self.props[pid] then return false end
        if not tonumber(num) or self.props[pid] < tonumber(num) then return false end
        local bfnum = self.props[pid]
        self.props[pid] = self.props[pid] - tonumber(num)

        if self.props[pid] == 0 then
            self.props[pid] = nil
        end
        -- 日志
        regKfkLogs(self.uid,'item',{
                item_id=pid,
                item_op_cnt=-num,
                item_before_op_cnt= bfnum,
                item_after_op_cnt= self.props[pid] or 0,
                item_pos='异星武器',
                flags={'item_id'},
                merge={'item_op_cnt'},
                rewrite={'item_after_op_cnt'},
                addition={
                },
            }
        )
        return true
    end

    function self.useProps(pidTab)
        -- body
        if type(pidTab) == 'table' and next(pidTab) then
            for k, v in pairs( pidTab ) do
                if not self.useProp(k, v) then
                    return false
                end
            end

            return true
        end

        return false
    end

    -- 更新经验值
    function self.changeExp(addexp)
        local exp = self.exp + tonumber(addexp) or 0
        if exp>=0 and exp ~= self.exp then
            self.exp = exp

            return true
        end
        return false
    end

    -- 更新碎片资源值 y1
    function self.changey1(addy1)
        local y1 = self.y1 + tonumber(addy1) or 0
        if y1>=0 and y1 ~= self.y1 then
            self.y1 = y1

            return true
        end
        return false
    end

    -- 属性加成
    function self.weaponAttr()
        -- body
        if type(self.used) ~= 'table' or not next(self.used) then
            return {{}, {}, {}, {}, {}, {}}
        end
        
        local cfg = copyTab( getConfig('alienWeaponCfg') )
        local attr = {} -- 6个部位的加成分别计算 {{dmg=0.1, maxhp=0.2},{},{},{},{},{}}
        for k, wid in pairs(self.used) do
            if wid ~= 0 and self.info[wid] then
                local per = cfg.weaponList[wid].attUp
                local lvl =  self.info[wid][1]
                local strenlvl = self.info[wid][2]

                local lvlAttrCfg = cfg.attLevelUp[cfg.weaponList[wid].color] -- 和武器颜色相关
                local strenAtrrCfg = cfg.attStrengLevel[cfg.weaponList[wid].color]
                for attname, attvalue in pairs(per) do --只计算基础属性有的
                    per[attname] = per[attname] + (lvlAttrCfg[attname] or 0) * lvl -- 等级属性加成
                    per[attname] = per[attname] + (strenAtrrCfg[attname] or 0) * strenlvl -- 强化属性加成
                end

                if moduleIsEnabled('jewelsys') == 1 then
                    -- 宝石增加的属性 start
                    local jatt,resonance = self.jewelAtt(wid)  
                    -- 先处理宝石增加的共振效果
                    for key,val in pairs(per) do
                        per[key] = per[key] * (1+resonance)
                    end
 
                    -- 增加宝石基础属性
                    for key,val in pairs(jatt) do
                        per[key] = (per[key] or 0) + val
                    end
                    -- 宝石增加的属性 end
                end

                attr[k] = per
            else
                attr[k] = {}
            end
        end

        return attr
    end

    -- 战斗力加成
    function self.getWeaponFight()
        local attr = self.weaponAttr()
        local powers = {}
        for _, v in pairs( attr ) do
            if next(v) then
                local pow = 0 -- power比例折算特殊处理
                for k, _v in pairs(v) do
                    if k == 'maxhp' or k == 'dmg' then
                        _v = _v * 200
                    elseif k == 'accuracy' or k == 'evade' or k == 'crit' or k =='anticrit' then
                        _v = _v * 800
                    elseif k == 'arp' or k == 'armor' then
                        _v = _v * 1
                    elseif k == 'critDmg' or k == 'decritDmg' then -- 爆伤/减爆伤
                        _v = _v * 1200
                    end

                    pow = pow + _v
                end

                table.insert(powers, pow)
            else
                table.insert(powers, 0)
            end
        end
        return powers
    end

    -- 战斗技能属性(战斗用)
    function self.getWeaponSkill()
        if type(self.used) ~= 'table' or not next(self.used) then
            return {{}, {}, {}, {}, {}, {}}
        end

        local cfg = getConfig("alienWeaponCfg")
        local skill = {}
        for k, wid in pairs(self.used) do
            if wid ~= 0 and self.info[wid] then
                skill[k] = {}
                local sid = cfg.weaponList[wid].skill
                if sid then -- 武器有技能
                    local skillcfg = cfg.skillList[sid]
                    local strenlvl = self.info[wid][2] + 1 -- 强化等级就是技能等级
                    -- 宝石开关 
                    if moduleIsEnabled('jewelsys') == 1 then
                        strenlvl = strenlvl + self.jewelskilllv(wid)
                    end
                    
                    if skillcfg.attType then -- 是战斗技能
                        skill[k] = {
                            type = skillcfg.type, -- 技能类别
                            effect = skillcfg.effectType, -- 生效类别(1 对自己单体有效，2对敌方单体有效，3特殊处理, 4对敌方群体有效, 5对自身群体有效 )
                            attr=skillcfg.attType, -- 技能属性 number or table
                            param = skillcfg.value[strenlvl], -- 技能参数 number or table
                        }
                    end
                end
            end
        end

        return skill
    end

    -- 获取指定技能的属性值(非战斗用)
    function self.getWeaponSkillById(sid)
        if type(self.used) ~= 'table' or not next(self.used) then
            return {}
        end

        local cfg = getConfig("alienWeaponCfg")
        local ret = {}
        for k, wid in pairs(self.used) do
            if wid ~= 0 and self.info[wid] then
                local tmp_sid = cfg.weaponList[wid].skill
                if sid == tmp_sid then
                    local skillcfg = cfg.skillList[sid]
                    local strenlvl = self.info[wid][2] + 1 -- 强化等级就是技能等级
                    ret[k] = skillcfg.value[strenlvl]
                end
            end
        end

        return ret
    end

    -- 自动修复技能 tanks 总量 repRate 待修复比例
    function self.autoRepair(tanks, repRate)
        local skill = self.getWeaponSkillById("as14") -- [战斗位置]=技能值

        local repair = {}
        if next(skill) then
            for k, v in pairs(skill) do
                if tanks[k] and next(tanks[k]) then
                    local tankid = tanks[k][1]
                    local num = tanks[k][2]
                    repair[tankid] = (repair[tankid] or 0) + math.ceil(num * v * repRate)
                end
            end
        end

        return repair
    end

    -- 自动修复
    function self.autoRepairByPos(nIdx, num)
        local skill = self.getWeaponSkillById("as14") -- [战斗位置]=技能值

        if skill[nIdx] then
            return math.ceil(skill[nIdx] * num)
        end

        return 0
    end

    --贸易护航------------------------------------------------------------
    --刷新护航列表
    function self.refTradelist()
        local cfg = getConfig('alienWeaponTradingCfg')

        --初始化任务列表
        if not next(self.trade) then
            for i=1, cfg.tradeMaxNum do
                self.trade[i] = {tid=0} -- { tid 任务id}
            end
        end

        -- 刷新任务列表
        for k, v in pairs(self.trade) do
            if not v.st then -- 没做护航任务都可以刷
               v.tid = self.randTrade()
               -- 随机奖励
               v.r = getRewardByPool(cfg.tradereward[tonumber(v.tid)].pool)
               v.cr = formatReward(v.r)
            end
        end

        return true
    end

    -- 检测队列
    function self.checkSlot(slot)
        return type(self.trade[slot]) == 'table' and not self.trade[slot].st
    end

    -- 租用队列费用
    function self.getCurrSlotFee()
        local cfg = getConfig('alienWeaponTradingCfg')
        local idx = 1
        for k, v in pairs(self.trade) do
            if v.st then -- 有任务
                idx = idx + 1
            end
        end

        return cfg.tradeNumCost[idx]
    end

    -- 检测任务完成
    function self.checkTaskOver(slot)
        return type(self.trade[slot]) == 'table' and self.trade[slot].et and self.trade[slot].et - getClientTs() < 10
    end

    -- 随机一个任务
    function self.randTrade()
        local cfg = getConfig('alienWeaponTradingCfg')
        local task = getRewardByPool(cfg.tradepool) -- 复用奖励池算法：格式 [2]=1 => [品质]= 站位符
        local tid = table.keys(task)
        return tonumber(tid[1])
    end

    -- 护航舰队返航(正常完成 和放弃任务 都可以)
    function self.fleetback(slot)
        if type(self.trade[slot]) ~= 'table' then
            return false
        end

        if not self.trade[slot].st or not self.trade[slot].orgtroops then -- 没有任务 ?
            return false
        end

        -- 返还 所有原始部队
        local uobjs = getUserObjs(self.uid)
        local mTroop = uobjs.getModel('troops')
        for m,n in pairs(self.trade[slot].orgtroops) do
            if n[1] and n[2] then
                mTroop.incrTanks(n[1],n[2])
            end
        end
        self.updateRobInfo(slot, true)

        -- 返回的时候要清除数据
        self.trade[slot].orgtroops = nil -- 总舰队
        self.trade[slot].troops = nil -- 当前舰队信息
        self.trade[slot].st = nil --开始时间
        self.trade[slot].et = nil --结束时间 
        self.trade[slot].rate = nil -- 倍率
        self.trade[slot].rob = nil -- 被抢了
        self.trade[slot].rname=nil -- 抢劫者
        self.trade[slot].tid = self.randTrade() -- 随机一个任务

        local tid = tonumber(self.trade[slot].tid)
        local cfg = getConfig('alienWeaponTradingCfg')
        self.trade[slot].r = getRewardByPool(cfg.tradereward[tid].pool)  --奖励
        self.trade[slot].cr = formatReward( self.trade[slot].r ) -- 客户端奖励

        cronId = 'aweapon' .. slot
        local uobjs = getUserObjs(self.uid)
        local mHero  = uobjs.getModel('hero')
        mHero.releaseHero('a',cronId)

        local mSequip = uobjs.getModel('sequip')
        mSequip.releaseEquip('a',cronId)

        local mPlane = uobjs.getModel('plane')
        mPlane.releasePlane('a',cronId)

        return true
    end

    -- 增加护航次数
    function self.incrAttacknum()
        local cfg = getConfig('alienWeaponTradingCfg')
        if not self.checkreset() or cfg.taskNum < self.tinfo.attacknum then
            return false
        end

        self.tinfo.attacknum = self.tinfo.attacknum + 1
        return true
    end

    -- 增加掠夺次数
    function self.incrRobnum()
        local cfg = getConfig('alienWeaponTradingCfg')
        local freeNum = cfg.freeNum

        local uobjs = getUserObjs(self.uid)
        local mUserinfo = uobjs.getModel('userinfo')
        self.checkreset()
        self.tinfo.robnum[1] = self.tinfo.robnum[1] - 1
        if self.tinfo.robnum[1] >= 0 then
            return true
        end

        if self.tinfo.robnum[2] > cfg.vip4RobNum[mUserinfo.vip+1] then
            return false
        end

        self.tinfo.robnum[2] = self.tinfo.robnum[2] + 1
        local gemCost = cfg.robNumCost[ self.tinfo.robnum[2] ]
        if not mUserinfo.useGem(gemCost) then
            return false
        end
        self.tinfo.robnum[1] = self.tinfo.robnum[1] + cfg.addAttackNum

        regActionLogs(uid,1,{action=143,item="robnum",value=gemCost,params={}})

        return true
    end

    -- 增加刷新任务列表次数
    function self.incrAttackListnum()
        local cfg = getConfig('alienWeaponTradingCfg')
        if not self.checkreset() or #cfg.cost < self.tinfo.lsnum then
            return false
        end

        self.tinfo.lsnum = self.tinfo.lsnum + 1
        return true        
    end

    -- 增加刷新抢夺列表次数
    function self.incrRobListnum()
        self.checkreset()  
        self.tinfo.rlsnum = self.tinfo.rlsnum + 1
        return true    
    end

    -- 护航检测重置
    function self.checkreset()
        local cfg = getConfig('alienWeaponTradingCfg')

        local weeTs = getWeeTs()
        if not self.tinfo.reset or self.tinfo.reset < weeTs then
            self.tinfo.robnum={cfg.freeNum, 0} -- {剩余掠夺次数， 购买次数}
            self.tinfo.attacknum=0 -- 护航次数
            self.tinfo.lsnum=0 -- 刷新护航列表次数
            self.tinfo.rlsnum=0 -- 刷新抢夺列表次数
            self.tinfo.reset=weeTs -- 重置时间
        end
        return true
    end

    -- 更新可掠夺uid, 为了查找可掠夺玩家做的标记值
    function self.updateRobInfo(tid, isDel, robName)
        local globalkey = 'z' .. getZoneId() .. ".aweapon.roblistuid"
        local redis = getRedis()
        local ts = getClientTs()

        -- 被抢, 正常结束, 放弃任务都要删掉缓存
        if not isDel then
            local ret = redis:zadd(globalkey, self.trade[tid].et, self.uid .. '_' .. tid) --缓存标记
            self.tflag = 1 
            -- writeLog({'add', ret=ret, self.uid .. '_' .. tid}, 'aweapon')
        else
            local ret = redis:zrem(globalkey, self.uid .. '_' .. tid)
            self.tflag = 0
            for k, v in pairs(self.trade) do
                if self.trade[k].et and self.trade[k].et - ts > 10 and self.trade[k].rob == 0 then
                    self.tflag = 1
                    break
                end
            end
            --被抢了
            if robName then
                self.trade[tid].rname = robName
                self.trade[tid].rob = 1

                -- 特殊处理 并发情况下，删掉缓存后还未保存数据库，getUserLib函数会从数据库刷新回来
                local aweaponkey = 'z' .. getZoneId() .. ".aweapon.roblistuid." .. self.uid .. '_' .. tid
                redis:set(aweaponkey, 100)
                redis:expire(aweaponkey, 3)
            end
            -- writeLog({'del',uid=self.uid, slot=tid , trade=self.trade[tid], ret=ret, self.uid .. '_' .. tid}, 'aweapon')
        end

    end

    -- 获取可掠夺uid
    function self.getUserLib()
        local globalkey = 'z' .. getZoneId() .. ".aweapon.roblistuid"
        local redis = getRedis()
        local ts = getClientTs()

        local list = redis:zrangebyscore(globalkey, ts, "+inf",'withscores')
        if not list or not next(list) then
            local db = getDbo()
            local result = db:getAllRows("select uid, trade from alienweapon WHERE tflag>0")
            list = {}
            for k, v in pairs(result) do
                v.trade = json.decode(v.trade) 
                for m, n in pairs(v.trade) do
                    -- 防并发处理
                    local aweaponkey = 'z' .. getZoneId() .. ".aweapon.roblistuid." .. v.uid .. '_' .. tostring(m)
                    local lock = redis:get(aweaponkey)
                    if tonumber(lock) ~= 100 and n.et and n.et - ts >10 and n.rob ~= 1 then -- 护航没有过期 没有被抢
                        local ret = redis:zadd(globalkey, n.et, v.uid .. '_' .. tostring(m))
                        table.insert(list, v.uid .. '_' .. tostring(m))
                    end
                end               
            end
        else
            local tmp = {}
            for k, v in pairs(list) do
                if type(v) == 'table' then
                    tmp[k] = v[1]
                end
            end
            list = tmp
        end

        -- 库列表排除自己
        local tmp = {}
        for k, v in pairs(list) do
            if not string.find(v, self.uid) then
                table.insert(tmp, v)
            end
        end
        list = tmp

        return list
    end

    -- 刷新可掠夺列表
    function self.refRoblist()
        local cfg = getConfig("alienWeaponTradingCfg")

        local ret = {}
        local list = self.getUserLib() -- 玩家库
        local len = math.ceil( #list / 10 )
        len = len > cfg.roblen and cfg.roblen or len --长度上限配置

        list = table.rand(list) -- 随机打乱
        for k, v in pairs(list) do --直接取前len条
            if k > len then
                break
            end
            table.insert(ret, v)
        end
        if len >= cfg.roblen then
            -- 抢夺列表, 存起来
            self.tinfo.rls = ret            
            return ret
        end

        len = cfg.roblen - len -- 还差的部分用NPC来补充

        local cfg = getConfig('alienWeaponTradingCfg')
        local uobjs = getUserObjs(self.uid)
        local mUserinfo = uobjs.getModel('userinfo')

        -- NPC库
        local lvl = math.floor(mUserinfo.level/10)*10
        local npc = self.getNpcLib(lvl)

        npc =table.rand(npc) -- 随机打乱
        for k, v in pairs(npc) do -- 直接取前len条
            if k > len  then
                break
            end
            table.insert(ret, v)
        end

        -- 抢夺列表, 存起来
        self.tinfo.rls = table.rand(ret)

        return ret
    end

    -- 更新掠夺列表
    function self.updateRoblist(nidx, isNpc)
        if not isNpc then
            local list = self.getUserLib() -- 玩家库
            -- 排除自己有的对象
            for k, v in pairs(self.tinfo.rls) do
                if k ~= nidx and not string.find(v, "npc") then
                    for m, n in pairs(list) do
                        if n == v then
                            table.remove(list, m) -- 移除自己有的对象
                        end
                    end
                end
            end

            if next(list) then
                local _rand = rand(1, #list )
                self.tinfo.rls[nidx] = list[_rand]
                return true
            end
        end

        local uobjs = getUserObjs(self.uid)
        local mUserinfo = uobjs.getModel('userinfo')
        -- NPC库
        local lvl = math.floor(mUserinfo.level/10)*10
        local npcLib = self.getNpcLib(lvl)

        -- 排除自己有的对象
        for k, v in pairs(self.tinfo.rls) do
            if string.find(v, "npc") then
                for m, n in pairs(npcLib) do
                    if n == v then
                        table.remove(npcLib, m) -- 移除自己有的对象
                    end
                end
            end
        end

        local _rand = rand(1, #npcLib)
        self.tinfo.rls[nidx] = npcLib[_rand]
        return true
    end

    -- NPC库
    function self.getNpcLib(level)
        local db = getDbo()
        local result = db:getAllRows("select id from alienweaponpc where level = :level",{level=level})
        -- 从数据库取
        if type(result) == 'table' and next(result) then
            local npc = {}
            for k, v in pairs(result) do
                table.insert(npc, 'npc_' .. v.id)
            end            
            return npc
        end

        -- 需要初始化数据库
        local cfg = getConfig('alienWeaponTradingCfg')
        setRandSeed()
        local maxnum = 0 -- 总数
        for k,v in pairs(cfg.addNpcPool) do
            maxnum = maxnum + v
        end

        result= {}
        for i=1, cfg.npcLen do
            local _rand = rand(1, maxnum)
            local slot = nil
            for k, v in pairs(cfg.addNpcPool) do
                if _rand > v then
                    _rand = _rand - v
                else
                    slot = k --找到品质索引
                    break
                end
            end

            -- 带出的奖励信息
            local reward = getRewardByPool( cfg.tradereward[slot].pool )
            -- for k, v in pairs(cfg.tradereward[slot].base) do
            --     reward[k] = (reward[k] or 0) + v
            -- end

            -- 随机一个范围战力
            setRandSeed()
            local rate = rand(-10, 10) / 100
            local fc = math.floor( cfg.troops[level][slot].fight * (1 + rate) )
            local npcdata = { troops= cfg.troops[level][slot].tank, -- 当前部队
                            level=level, -- NPC档次 对应配置的位置信息
                            slot=slot, -- 位置
                            sr = reward, -- 服务端奖励
                            cr = formatReward(reward), -- 客户端奖励
                            fc = fc, -- 战力

                }
            local ret = db:insert('alienweaponpc',npcdata)
            if ret then
                npcdata.id = db.conn:getlastautoid()
                table.insert(result, 'npc_' .. npcdata.id)
            end
        end

        return result
    end

    -- 可掠夺对象
    function self.checkCanRob(targetid)
        local idx = nil
        for k, v in pairs(self.tinfo.rls) do
            if targetid == v then
                idx = k
                break
            end
        end
        if not idx then
            return false
        end

        local target = targetid:split("_")
        if target[1] ~= 'npc' then
            local tuid = tonumber(target[1])
            local slot = tonumber(target[2])

            local dobjs = getUserObjs(tuid)
            local dAweapon = dobjs.getModel("alienweapon")
            if not dAweapon.trade[slot].st or dAweapon.trade[slot].rob == 1 then -- 被抢了
                return false
            end
        end

        return idx
    end

    -- 贸易抢劫战斗
    function self.battle(targetid, targetIdx, fleetInfo,hero,equip)
        local target = targetid:split("_")
        -- npc
        if target[1] == 'npc' then
            return self.battlenpc(target[2], targetIdx, fleetInfo,hero,equip)
        end

        local tuid = tonumber(target[1])
        local slot = tonumber(target[2]) 

        --抢夺玩家
        local uobjs = getUserObjs(self.uid)
        local aUserinfo = uobjs.getModel('userinfo')        
        local aTroops = uobjs.getModel('troops')
        local aSequip = uobjs.getModel('sequip')
        local aBadge = uobjs.getModel('badge')  
        local aBadgeVal = aBadge.formBadge()    
        local aFleetInfo,aAccessory,aherosInfo,aplanevalue = aTroops.initFleetAttribute(fleetInfo,6,{hero=hero, equip=equip,})

        local cronId = "aweapon" .. slot -- cronId 是写死的规则
        local dobjs = getUserObjs(tuid)
        local dUserinfo = dobjs.getModel('userinfo')
        local dTroops = dobjs.getModel('troops')
        local dHero = dobjs.getModel('hero')
        local dHeros = dHero.getAttackHeros('a', cronId)
        local dEquip = dobjs.getModel("sequip") 
        local dEquipid = dEquip.getEquipFleet('a',cronId)
        local dAweapon = dobjs.getModel("alienweapon")
        local dtroopsFleet = dAweapon.trade[slot].troops
        local dPlaneModel = dobjs.getModel('plane')
        local dPlane = dPlaneModel.getPlaneFleet('a',cronId)
        local dBadge = dobjs.getModel('badge')  
        local dBadgeVal = dBadge.formBadge()
        local dFleetInfo,dAccessory,dherosInfo,dplanevalue = dTroops.initFleetAttribute(dtroopsFleet,6,{hero=dHeros, equip=dEquipid,plane=dPlane,})
        
        require "lib.battle"

        -- 战斗
        local report = {}
        report.d, report.r, aInavlidFleet, dInvalidFleet, attSeq, seqPoint = battle(aFleetInfo,dFleetInfo)
        report.t = {dtroopsFleet,fleetInfo}
        if attSeq == 1 then
            report.p = {{dUserinfo.nickname,dUserinfo.level,1,seqPoint[2]},{aUserinfo.nickname,aUserinfo.level,0, seqPoint[1]}}            
        else
            report.p = {{dUserinfo.nickname,dUserinfo.level,0,seqPoint[2]},{aUserinfo.nickname,aUserinfo.level,1,seqPoint[1]}}
        end
        report.h = {dherosInfo[1],aherosInfo[1]}
        report.se ={dEquip.formEquip(dEquipid), aSequip.formEquip(equip)}
        report.badge ={dBadgeVal, aBadgeVal}

        -- 本次双方损失的坦克数量
        local lostShip = {
            attacker  = {},
            defenser = {},
        }
        local aSurviveTroops, dSurviveTroops, aDmgInfo, dDmgInfo
        lostShip.attacker ,aSurviveTroops, aDmgInfo = self.damageTroops(fleetInfo,aInavlidFleet)
        lostShip.defenser,dSurviveTroops, dDmgInfo = self.damageTroops(dtroopsFleet,dInvalidFleet)

        local isWin = report.r == -1 and 0 or report.r
        -- 记录当前战损部队
        local reward = self.updateUidInfo(tuid, dSurviveTroops, isWin, slot, aUserinfo.nickname)
        -- 发奖励(先扣奖励，再发奖励)
        reward = self.takeRewardRob(isWin, reward, tonumber(dAweapon.trade[slot].tid), nil, targetIdx)
        report.r = formatReward(reward)

        --记录战斗报告
        -- 双方总坦克对比
        local dtankinfo={}
        if type(dtroopsFleet) == 'table' then
            for k,v in pairs(dtroopsFleet) do
                if type(v)=='table' and next(v) then
                    dtankinfo[v[1]]  =(dtankinfo[v[1]] or 0) +v[2]
                end
            end
        end
        local atankinfo={}
        for k,v in pairs(fleetInfo) do
            if type(v)=='table' and next(v) then
                atankinfo[v[1]]  =(atankinfo[v[1]] or 0) +v[2]
            end
        end        
        local log = {
            report = report,
            lostShip=lostShip,
            tank={d=dtroopsFleet, a=fleetInfo},
            aey={aAccessory, dAccessory},
            hh={{aherosInfo[1],aherosInfo[2]}, {dherosInfo[1],dherosInfo[2]}},
            se={aSequip.formEquip(equip), dEquip.formEquip(dEquipid)},
            plane={aplanevalue,dplanevalue},
            badge={aBadgeVal,dBadgeVal},

            -- 使用的装甲矩阵信息
            armor = {
                uobjs.getModel('armor').formatUsedInfoForBattle(),
                dobjs.getModel('armor').formatUsedInfoForBattle()
            },
            -- 使用的异星武器信息
            alienWeapon = {
                uobjs.getModel('alienweapon').formatUsedInfoForBattle(),
                dobjs.getModel('alienweapon').formatUsedInfoForBattle()
            },
            -- 双方详细的战损信息
            dmginfo = {
                aDmgInfo,
                dDmgInfo
            },
            -- 双方的头像信息
            attackerPic = {aUserinfo.pic,aUserinfo.bpic,aUserinfo.apic},
            defenserPic = {dUserinfo.pic,dUserinfo.bpic,dUserinfo.apic},
            -- 双方基础信息
            userinfo = {
                {aUserinfo.showvip(),aUserinfo.fc,aUserinfo.level,aUserinfo.alliancename},
                {dUserinfo.showvip(),dUserinfo.fc,dUserinfo.level,dUserinfo.alliancename},
            }
        }        

        self.sendReport(self.uid, log, 1, dUserinfo.nickname, isWin) -- 掠夺
        self.sendReport(tuid, log, 2, aUserinfo.nickname, isWin==1 and 0 or 1) -- 护航

       
        -- 异星任务:抢夺{1}色船{2}次
        activity_setopt(self.uid,'alientask',{t='y5',n=1,p=dAweapon.trade[slot].tid,w=isWin})

        -- 跨服战资比拼
        zzbpupdate(self.uid,{t='f13',n=1,id=tonumber(dAweapon.trade[slot].tid)})


  

        return report, isWin, dobjs
    end

    -- 抢劫NPC
    function self.battlenpc(npcid, targetIdx, fleetInfo,hero,equip)
        local uobjs = getUserObjs(self.uid)
        local aUserinfo = uobjs.getModel('userinfo')        
        local aTroops = uobjs.getModel('troops')   
        local aSequip = uobjs.getModel('sequip')  
        local aBadge = uobjs.getModel('badge')
        local aBadgeVal = aBadge.formBadge()
        local aFleetInfo,aAccessory,aherosInfo = aTroops.initFleetAttribute(fleetInfo,6,{hero=hero, equip=equip,})
        
        local npcdata = getDbo():getRow('select * from alienweaponpc where id=:id', {id=npcid})
        local cfg = getConfig('alienWeaponTradingCfg')
        if not npcdata then
            return false
        end
        -- NPC 数据初始化
        npcdata.troops = json.decode(npcdata.troops)
        npcdata.sr = json.decode(npcdata.sr)
        npcdata.level = tonumber(npcdata.level)
        npcdata.slot = tonumber(npcdata.slot)
        local troopcfg = cfg.troops[npcdata.level][npcdata.slot]
        local dFleetInfo = initTankAttribute(npcdata.troops, nil, troopcfg.skills, nil, nil, 0, { acAttributeUp = troopcfg.attributeUp, attrUpFlag = true })

        require "lib.battle"
        local report = {}
        report.d, report.r, aInavlidFleet, dInvalidFleet, attSeq, seqPoint = battle(aFleetInfo,dFleetInfo)
        report.t = {npcdata.troops, fleetInfo}
        if attSeq == 1 then
            report.p = {{'npc_' .. npcdata.id,npcdata.level,1,seqPoint[2]},{aUserinfo.nickname,aUserinfo.level,0, seqPoint[1]}}            
        else
            report.p = {{'npc_' .. npcdata.id,npcdata.level,0,seqPoint[2]},{aUserinfo.nickname,aUserinfo.level,1,seqPoint[1]}}
        end
        report.h = {{},aherosInfo[1]}
        report.se ={0, aSequip.formEquip(equip)}
        report.badge ={{0,0,0,0,0,0},aBadgeVal}

        -- 本次双方损失的坦克数量
        local lostShip = {
            attacker  = {},
            defenser = {},
        }
        local aSurviveTroops, dSurviveTroops, aDmgInfo, dDmgInfo
        lostShip.attacker ,aSurviveTroops, aDmgInfo = self.damageTroops(fleetInfo,aInavlidFleet)
        lostShip.defenser,dSurviveTroops, dDmgInfo = self.damageTroops(npcdata.troops,dInvalidFleet)

        local isWin = report.r == -1 and 0 or report.r
        -- 记录当前战损部队
        local reward = self.updateNpcInfo(npcid, npcdata.level, npcdata.sr, dSurviveTroops, isWin)
        -- 发奖励(先扣奖励，再奖励)
        reward = self.takeRewardRob(isWin, reward, npcdata.slot, true, targetIdx)
        report.r = formatReward(reward)

        --记录战斗报告
        -- 双方总坦克对比
        local dtankinfo={}
        if type(npcdata.troops) == 'table' then
            for k,v in pairs(npcdata.troops) do
                if type(v)=='table' and next(v) then
                    dtankinfo[v[1]]  =(dtankinfo[v[1]] or 0) +v[2]
                end
            end
        end
        local atankinfo={}
        for k,v in pairs(fleetInfo) do
            if type(v)=='table' and next(v) then
                atankinfo[v[1]]  =(atankinfo[v[1]] or 0) +v[2]
            end
        end        
        local log = {
            report = report,
            lostShip=lostShip,
            tank={d=npcdata.troops, a=fleetInfo},
            aey={aAccessory, {}},
            hh={{aherosInfo[1],aherosInfo[2]},{{}, 0}},
            se={aSequip.formEquip(equip), 0},
            badge={aBadgeVal,{0,0,0,0,0,0}},

            -- 使用的装甲矩阵信息
            armor = {
                uobjs.getModel('armor').formatUsedInfoForBattle(),
                {}
            },
            -- 使用的异星武器信息
            alienWeapon = {
                uobjs.getModel('alienweapon').formatUsedInfoForBattle(),
                {}
            },
            -- 双方详细的战损信息
            dmginfo = {
                aDmgInfo,
                dDmgInfo
            },
            -- 双方的头像信息
            attackerPic = {aUserinfo.pic,aUserinfo.bpic,aUserinfo.apic},
            defenserPic = {'npc_' .. npcdata.id,"",""},
            -- 双方基础信息
            userinfo = {
                {aUserinfo.showvip(),aUserinfo.fc,aUserinfo.level,aUserinfo.alliancename},
                {0,tonumber(npcdata.fc),tonumber(npcdata.level),""},
            }
        }
        self.sendReport(self.uid, log, 1, 'npc_' .. npcid, isWin) -- 掠夺报告
     

        -- 异星任务:抢夺{1}色船{2}次
        activity_setopt(self.uid,'alientask',{t='y5',n=1,p=tonumber(npcdata.slot),w=isWin})
        
         -- 跨服战资比拼
        zzbpupdate(self.uid,{t='f13',n=1,id=tonumber(npcdata.slot)})
       
        return report, isWin, nil
    end

    -- 战损统计
    function self.damageTroops(fleetInfo,invalidFleetInfo)
        local dietroops = {}
        local troops = {}

        -- 战报优化客户需要的数据格式：{tid-该位置参战数量-剩余数量，tid-该位置参战数量-剩余数量}
        local detailForClient = {}

        for k,v in pairs(fleetInfo) do           
            if next(v) and v[2] >= 0 then
                local aid = v[1]
                table.insert(troops,{aid,invalidFleetInfo[k].num or 0})
                
                local dieNum = v[2] - (invalidFleetInfo[k].num or 0)  -- 损失坦克
                
                if dieNum > 0 then
                    dietroops[aid]= (dietroops[aid] or 0) + dieNum
                end             

                detailForClient[k] = string.format("%s-%s-%s",v[1],v[2],dieNum)   
            else
                table.insert(troops,{})
                detailForClient[k] = ""
            end
        end

        return dietroops,troops,detailForClient
    end

    -- 更新目标当前护航信息
    function self.updateUidInfo(tuid, curTroops, isRob, slot, robName)
        local dobjs = getUserObjs(tuid)
        local dAweapon = dobjs.getModel("alienweapon")
        dAweapon.trade[slot].troops = curTroops or {}
        dAweapon.trade[slot].rob = isRob -- 0未被成功抢夺，1被抢夺了(也就是对方战斗胜利)
        --被抢了之后要扣除奖励
        local reward = {}
        if isRob == 1 then
            for k, v in pairs(dAweapon.trade[slot].r) do
                reward[k] = math.ceil(v/2) -- 这部分奖励是给攻击者的
                dAweapon.trade[slot].r[k] = v - reward[k] -- 自己的
            end
            dAweapon.trade[slot].cr = formatReward(dAweapon.trade[slot].r)

            -- 被抢了从抢夺列表移除
            dAweapon.updateRobInfo(slot, true, robName)
            -- -- 被抢了推送给玩家
            -- regSendMsg(uid,"push.aweapon",{id = slot})
        end

        return reward
    end

    -- 更新NPC护航信息到数据库
    function self.updateNpcInfo(npcid, level, srvReward, curTroops, isRob)
        local npcdata = nil

        if isRob == 1 then --被抢了重新初始化
            local cfg = getConfig('alienWeaponTradingCfg')
            setRandSeed()
            local maxnum = 0 -- 总数
            for k,v in pairs(cfg.addNpcPool) do
                maxnum = maxnum + v
            end

            local _rand = rand(1, maxnum)
            local slot = nil
            for k, v in pairs(cfg.addNpcPool) do
                if _rand > v then
                    _rand = _rand - v
                else
                    slot = tonumber(k) --找到品质索引
                    break
                end
            end

            -- 带出的奖励信息
            reward = getRewardByPool( cfg.tradereward[slot].pool )
            -- for k, v in pairs(cfg.tradereward[slot].base) do
            --     reward[k] = (reward[k] or 0) + v
            -- end

            -- 随机一个范围战力
            setRandSeed()
            local rate = rand(-10, 10) / 100
            local fc = math.floor( cfg.troops[level][slot].fight * (1 + rate) )
            npcdata = { troops= cfg.troops[level][slot].tank, -- 当前部队
                            slot=slot, -- 位置
                            sr = reward, -- 服务端奖励
                            cr = formatReward(reward), -- 客户端奖励
                            fc = fc,
                }

            -- 赢了NPC 分一半奖励
            for k, v in pairs(srvReward) do
                srvReward[k] = math.floor(v/2)
            end
        else -- 只更新当前部队数
            npcdata ={
                troops = curTroops,
            }
        end

        if npcdata then
            writeLog({id =npcid, d= npcdata}, 'dAweapon')
            getDbo():update('alienweaponpc', npcdata, 'id='..npcid)
        end
        return srvReward
    end

    -- 抢夺后发奖
    function self.takeRewardRob(isWin, reward, tid, isNpc, nidx)
        local cfg = getConfig('alienWeaponTradingCfg')
        if isWin == 1 then 
            for k, v in pairs(cfg.tradereward[tid].base) do 
                reward[k] = (reward[k] or 0) + 1 -- 抢一个道具
            end

            -- 赢了刷新自己的抢夺列表
            self.updateRoblist(nidx, isNpc)
        else -- 失败了 安慰奖
            reward = getRewardByPool(cfg.loserPool)
        end

        if not takeReward(self.uid, reward) then -- 配置的奖励不应该发失败 ???
            writeLog({self.uid, reward=reward, msg='battle takeReward fail !'}, 'aweaponerr')
        end
        return reward
    end 

    -- 抢夺战报 log_type (2 护航报告，1 抢夺报告)
    function self.sendReport(userid, report, log_type, dfname, isWin)
       local battlelogLib=require "lib.battlelog"
       battlelogLib:logAweaponSent(userid, report, log_type, isWin, dfname)
    end

    -- 神秘海域 ------------------------------------
    -- 进入海域， 章节，难度
    function self.seaEnter(chapter, ntype)
        if type(self.sinfo.sea) == 'table' then
            return false
        end

        self.sinfo.sea = {
            type=ntype, -- 海域难度
            chap=chapter, -- 海域章节
            l={0,0,0,0,0,0}, -- 海域关卡详细信息 (0未探索，1探索正常，2探索发现boss)
            boss=0, --发现boss (1 发现未击败，2 发现击败)
        }

        return true
    end

    -- 退出当前海域
    function self.seaExit()
        -- body
        if type(self.sinfo.sea) == 'table' then
            self.sinfo.sea = nil
            return true
        end
        return false
    end

    -- 检测解锁当前关卡id
    function self.checkUnlock(cid)
        return cid <= (self.sinfo.unlock or 1)
    end

    --检测通关海域
    function self.checkPassSea(lvlCheck)
        if type(self.sinfo.sea) ~= 'table' then return false end
        if self.sinfo.sea.boss ~= 2 then return false end

        for k, v in pairs(self.sinfo.sea.l) do
            if v<=0 then
                return false
            end
        end

        local cfg = getConfig("alienWeaponSecretSeaCfg")
        -- 记录最高关卡打的次数
        local currCid = (self.sinfo.sea.chap -1) * cfg.difficult + self.sinfo.sea.type
        self.sinfo.unlock = self.sinfo.unlock or 1

        if currCid == self.sinfo.unlock then
            if not self.sinfo.psea or self.sinfo.psea[1] < currCid then
                self.sinfo.psea = {currCid, 0}
            end
            self.sinfo.psea[2] = self.sinfo.psea[2] + 1 -- 通过一次

            -- 解锁新BOSS(玩家等级限制 and 最后关卡 )
            if lvlCheck then
                local cfg = getConfig('alienWeaponSecretSeaCfg')
                local chap1 = math.ceil( (self.sinfo.unlock + 1) / cfg.difficult ) -- 当前章节
                local chap = math.ceil( (self.sinfo.unlock) / cfg.difficult ) -- 当前章节
                -- 等级限制 and 通过次数限制
                if chap1 <= cfg.maxChapter and lvlCheck >= cfg.unlockLevel[chap1] and self.sinfo.psea[2] >= cfg.unlockAttackNum[chap] then
                    self.sinfo.unlock = self.sinfo.unlock + 1
                    self.sinfo.psea = nil
                end 
            end

        end

        return true
    end

    -- 海域boss
    function self.battleSea(fleetInfo,hero,equip)
        local uobjs = getUserObjs(self.uid)
        local aUserinfo = uobjs.getModel('userinfo')        
        local aTroops = uobjs.getModel('troops') 
        local aSequip = uobjs.getModel('sequip')        
        local aBadge = uobjs.getModel('badge')        
        local aFleetInfo,aAccessory,aherosInfo = aTroops.initFleetAttribute(fleetInfo,6,{hero=hero, equip=equip,})
        
        -- boss 数据
        local cfg = getConfig('alienWeaponSecretSeaCfg')
        local npcdata = copyTab(cfg.troops[tonumber(self.sinfo.sea.chap)][tonumber(self.sinfo.sea.type)] )-- NPC[章节][难度]
        npcdata.id = self.sinfo.sea.chap .. '_' .. self.sinfo.sea.type
        npcdata.level = self.sinfo.sea.type

        local dFleetInfo = initTankAttribute(npcdata.tank, nil, npcdata.skills, nil, nil, 0, {acAttributeUp = npcdata.attributeUp, attrUpFlag = true })

        require "lib.battle"
        local report = {}
        report.d, report.r, aInavlidFleet, dInvalidFleet, attSeq, seqPoint = battle(aFleetInfo,dFleetInfo)
        report.t = {npcdata.tank, fleetInfo}
        if attSeq == 1 then
            report.p = {{npcdata.id,npcdata.level,1,seqPoint[2]},{aUserinfo.nickname,aUserinfo.level,0, seqPoint[1]}}            
        else
            report.p = {{npcdata.id,npcdata.level,0,seqPoint[2]},{aUserinfo.nickname,aUserinfo.level,1,seqPoint[1]}}
        end
        report.h = {{},aherosInfo[1]}
        report.se ={0, aSequip.formEquip(equip)}
        report.badge ={{0,0,0,0,0,0}, aBadge.formBadge()}

        local dietroops = self.damageTroops(fleetInfo,aInavlidFleet)
        -- 扣掉战损tank
        for k, v in pairs(dietroops) do
            local dieNum = math.ceil(v * cfg.loseFight)
            if dieNum > 0 and not aTroops.consumeTanks(k,dieNum) then
                return false
            end
        end

        if type(dietroops)=='table' and next(dietroops) then
                --writeLog('海域探索兵种损耗uid='..self.uid..'npcid='..npcdata.id..'npclv='..npcdata.level..'损耗='..json.encode(dietroops),'dietroops')
                regKfkLogs(self.uid,'tankChange',{
                    addition={
                        {desc="npc编号", value=npcdata.id},
                        {desc="npc等级",value=npcdata.level},
                        {desc="兵种损耗",value=dietroops},
                    }
                }
            ) 
        end

        local isWin = report.r
        if isWin == 1 and self.sinfo.sea.boss == 1 then
            -- 二次授勋海域探索中攻打第7关及以上关卡15次
            uobjs.getModel('hero').refreshFeat("t14",hero,tonumber(self.sinfo.sea.chap))

            self.sinfo.sea.boss = 2 --击败boss标记
            local reward = cfg.bossReward[tonumber(self.sinfo.sea.chap)][tonumber(self.sinfo.sea.type)]
            reward = getRewardByPool(reward)
            local normal = cfg.exp.normal[tonumber(self.sinfo.sea.type)][tonumber(self.sinfo.sea.chap)]
            reward['aweapon_exp'] = math.floor( cfg.exp.expBoss * normal)
            if not takeReward(self.uid, reward) then
                return false
            end
            report.r = formatReward(reward)
        end

        return report, isWin
    end

    -- 1-9级宝石60*10 1000  "j60":999,
    -- 10级宝石 90*30 3000 "j9999":"j60",1000
    -- 装配 18*20 500 "aw1":"j100","j100","j100"

    -- 添加宝石   id编号,num数量
    function self.addjewel(id,num)
        local ret = 0
        local idtab = {}

        local jewelCfg = getConfig("alienjewel")
        if type(jewelCfg['main'][id]) ~= 'table' then
            ret = -102
            return ret,idtab
        end

        if jewelCfg['main'][id].level < 10 then
            if type(self.jewelinfo1)~='table' then
                self.jewelinfo1 = {}
            end
            self.jewelinfo1[id] = (self.jewelinfo1[id] or 0) + num
            idtab[id] = (idtab[id] or 0) + num
        else
            if self.getJewel2Count()+num > jewelCfg['others'].tenLimit then
                ret = -26011
                return ret,idtab
            end

            if type(self.jewelinfo2)~='table' then
                self.jewelinfo2 = {}
            end

            local jewelinfoLen = table.length(self.jewelinfo2)
            for i=1,num do
                local newkey = self.getJewelId(jewelinfoLen)
                self.jewelinfo2[newkey] = {id,0,0}-- 配置编号 技能编号 额外值
                self.succinct(newkey,true) -- 十级宝石初始会执行以下洗练
                idtab[newkey] = 1
                jewelinfoLen = jewelinfoLen + 1
            end
        end

        regKfkLogs(self.uid,'alienjewel',{
                addition={
                    {desc="增加宝石",value=num},
                    {desc="id",value=id},
                }
            }
        ) 

        return ret,idtab   
    end

    -- 消耗宝石
    function self.costjewel(jid,num)
        num = math.floor(num)
        if num<=0 then return false end

        -- 使用的宝石
        local used = self.usedjewel()
        local subj = string.sub(jid,1,1)

        -- 十级宝石
        if subj == 't' then
            if num>1 or type(self.jewelinfo2[jid])~='table' then 
                return false 
            end

            if self.jewelinfo2[jid]-(used[jid] or 0)<num then 
                return false 
            end
            
            self.jewelinfo2[jid] = nil
        else
            if not self.jewelinfo1[jid] then
                return false
            end

            if self.jewelinfo1[jid]-(used[jid] or 0)<num then 
                return false 
            end
            
            self.jewelinfo1[jid] = self.jewelinfo1[jid] - num
        end

        regKfkLogs(uid,'alienjewel',{
                addition={
                    {desc="宝石消耗",value={id=jid,n=num}},
                }
            }
        ) 

        return true
    end

    -- 获取10级宝石的id
    function self.getJewelId(jewelinfoLen)
        jewelinfoLen = jewelinfoLen or 1
        local key = string.sub(os.time(),-3)
        local jid = 't'..key
        if type(self.jewelinfo2[jid]) =='table' then
            jid = jid .. jewelinfoLen   
            jewelinfoLen = jewelinfoLen + 1
            if self.jewelinfo2[jid] then
                return self.getJewelId(jewelinfoLen)    
            end
        end
        return jid,jewelinfoLen
    end

    -- 获取当前10级宝石的数量
    function self.getJewel2Count()
        return table.length(self.jewelinfo2)
    end

    -- 获取宝石配置
    function self.getjewelCfg(jid)
        local jewelCfg = getConfig("alienjewel")
        local jewelid =self.getJewelidCfg(jid)
        local jcfg = jewelCfg['main'][jewelid]

        return jcfg
    end

    -- 获取宝石配置的编号(不是系统生成的那个)
    function self.getJewelidCfg(jid)
        local subj = string.sub(jid,1,1)
        -- 十级宝石
        if subj == 't' then
            return self.jewelinfo2[jid][1]
        end

        return jid
    end

    -- 装配宝石
    -- 参数 wid 异星武器编号  jid 宝石编号
    function self.setJewel(wid,jid)
        local ret = 0
        if self.jewelused == '' or self.jewelused == nil then
             self.jewelused={}
        end

        local jewelCfg = getConfig("alienjewel")
        local wcfg = jewelCfg['fit'][wid] 
        local jcfg = self.getjewelCfg(jid)

        if type(wcfg)~='table' or type(jcfg)~='table' then
            ret = -102
            return ret
        end

        -- 判断当前宝石装配位置
        local position = 0
        for k,v in pairs(wcfg.color) do
            if v == jcfg.color then
               position = k
               break
            end
        end

        if position == 0 then
            ret = -26001
            return ret
        end

        -- 武器宝石孔是否解锁
        if not self.info[wid] then 
            ret = -26002
            return ret 
        end
        -- 未解锁
        if self.info[wid][1] < wcfg.unlock[position] then
            ret = -26003
            return ret 
        end

        -- 镶嵌的宝石等级需要的异星武器等级是否满足
        if self.info[wid][1] < jewelCfg.others.levelLimit[jcfg.level] then
            ret = -26009
            return ret
        end

        -- 没有初始化过的数据
        if type(self.jewelused[wid])~='table' then
            self.jewelused[wid] = {0,0,0}
        end

        self.jewelused[wid][position] = jid

        -- 成就
        updatePersonAchievement(self.uid,{'a6'})

        return ret
    end

    -- 卸下宝石 
    function self.deJewel(wid,jid)
        local jewelCfg = getConfig("alienjewel")
        local wcfg = jewelCfg['fit'][wid]
        local jcfg = self.getjewelCfg(jid)
        if type(wcfg)~='table' or type(jcfg)~='table' then
            return false
        end

        if not self.jewelused[wid] then
            return false
        end

        if self.jewelused == '' or self.jewelused == nil then
             return false
        end

        -- 判断当前宝石镶嵌在武器上的位置
        local position = 0
        for k,v in pairs(wcfg.color) do
            if v == jcfg.color then
               position = k
               break
            end
        end

        if position == 0 then
            return false
        end

        self.jewelused[wid][position] = 0

        return true
    end

    -- 一键卸下宝石
    function self.easydeJewel(wid)
        if type(self.jewelused)~='table' then
            self.jewelused = {}
        end

        self.jewelused[wid] = {0,0,0}
        return true
    end

    -- 已装备的宝石 {编号:数量}
    function self.usedjewel()
        local jewel = {}
        if type(self.jewelused)~='table' then
            self.jewelused = {}
        end

        for k,v in pairs(self.jewelused) do
            if type(v)=='table' then
                for i=1,3 do
                    if v[i]~=0 then
                        jewel[v[i]] = (jewel[v[i]] or 0) + 1
                    end
                end
            end   
        end

        return jewel
    end

    -- 增加宝石粉尘
    function self.addstive(num)
        self.stive = self.stive + num

        return true
    end

    -- 减少粉尘
    function self.usestive(num)
        if self.stive < num then
            return false
        end

        self.stive = self.stive -num
        return true
    end

    -- 增加宝石结晶
    function self.addcrystal(num)
        self.crystal = self.crystal + num

        return true
    end

    -- 减少结晶
    function self.usecrystal(num)
        if self.crystal < num then
            return false
        end

        self.crystal = self.crystal - num
        return true
    end

    -- 宝石洗练 jid 宝石id  flag:true开始加宝石直接赋值  false 不赋值
    function self.succinct(jid,flag)    
        local jewelCfg = getConfig("alienjewel")
        local jcfg = self.getjewelCfg(jid)
        if type(jcfg)~='table' then
            return false
        end

        local pool = {}
        local items = table.length(jewelCfg.skill)
        for i=1,items do
            table.insert(pool,jewelCfg.skill['s'..i]['weight'][jcfg.color])
        end

        local realsid = ''
        local realskval = 0

        local succinctVal = {} -- 本次洗练的值
        local clientTab = {}-- 给客户端做的数据
        for i=1,5 do
            local index = randVal(pool)
            local skillcfg = jewelCfg.skill['s'..index]
            local skval = 0
            local sid = ''
          
            if skillcfg.skilltype == 2 then
                skval = skillcfg.initiate
                sid = 's'..index
            else
                setRandSeed()
                local rdval = 0
                for i=1,skillcfg.steps do
                    local rd=rand(skillcfg.value[1],skillcfg.value[2])
                    rdval = rdval + rd -- 达到指定的次数 随机到哪个就是哪个
                    if rd < skillcfg.value[3] then
                        break
                    end
                    
                end

                skval = skillcfg.initiate + rdval/1000
                if skval > 1 then
                    skval = math.floor(skval)
                end
                sid = 's'..index
            end
         
            table.insert(clientTab,{[sid]=skval})

            if i==1 then
                realsid = sid
                realskval = skval
            end
 
        end

        if flag then
            self.jewelinfo2[jid][2] = realsid
            self.jewelinfo2[jid][3] = realskval 
        end

        succinctVal.s = realsid
        succinctVal.v = realskval

        local redis = getRedis()
        local redkey = "zid."..getZoneId()..'_succinctVal_'..self.uid
        redis:set(redkey,json.encode(succinctVal))
        redis:expire(redkey,86400)

        return clientTab
    end

    -- 判断异星武器上是否有装配宝石
    function self.checkEquipJewel(wid)
        if not self.jewelused then return false end
        if type(self.jewelused[wid])=='table' then
            for _,v in pairs(self.jewelused[wid]) do
                if v ~=0 and v ~= '' then
                    return true
                end
            end
        end

        return false
    end

    -- 格式化返给客户端宝石数据
    function self.formjeweldata()
        local formdata = {}
        formdata.jewelused = self.jewelused
        formdata.jewelinfo1 = {}
        for k,v in pairs(self.jewelinfo1) do
            if tonumber(v)>0 then
                formdata.jewelinfo1[k] = v
            end
        end
        formdata.jewelinfo2 = self.jewelinfo2
        formdata.stive = self.stive
        formdata.crystal = self.crystal

        return formdata
    end

     -- 一键装配
    function self.easyset(wid)
        local ret = 0
        local flag = false-- 是否需要刷新战斗力
        if type(self.jewelused)~='table'  then
             self.jewelused={}
        end

        local cfg = getConfig('alienjewel')
        -- 先把当前武器上的宝石卸下来
        self.easydeJewel(wid)
        local usedjewel = self.usedjewel()
        
        local usedkeys = table.keys(usedjewel)
        local alljewel = {}
        for k,v in pairs(self.jewelinfo2) do
            if not table.contains(usedkeys,k) then
                alljewel[k] = 1-- 10级宝石每个都是单独的
            end 
        end

        for k,v in pairs(self.jewelinfo1) do
            alljewel[k] = v - (usedjewel[k] or 0)
            if alljewel[k]<0 then
                ret=-102
                return ret,flag
            end
        end


        if self.info[wid][1]>0 then
            local wcfg = cfg['fit'][wid]
            if type(wcfg) ~= 'table' then
                ret = -102
                return ret,flag
            end
            local knum = #wcfg.color
            local jcfg = {}
            -- 武器孔
            for p=1,knum do
                for k,v in pairs(alljewel) do
                    if v > 0 then
                        -- 获取该宝石配置
                        local jcfg = self.getjewelCfg(k)
                        -- 判断该颜色的宝石能否装配到当前宝石孔上
                        if wcfg.color[p] == jcfg.color then
                            -- 武器宝石孔是否解锁
                            if self.info[wid][1] >= wcfg.unlock[p] then
                                -- 镶嵌的宝石等级需要的异星武器等级是否满足
                                if self.info[wid][1] >= cfg.others.levelLimit[jcfg.level] then
                                    if self.jewelused[wid] then
                                        -- 还未镶嵌上
                                        if self.jewelused[wid][p] == 0 or self.jewelused[wid][p] == '' then
                                            self.jewelused[wid][p] = k
                                            alljewel[k] = alljewel[k]-1 
                                            flag = true

                                        else
                                            --已镶嵌上
                                            -- 下一个宝石跟当前镶嵌的宝石做对比 执行替换
                                            local curid = self.jewelused[wid][p]
                                            local curjewelcfg = self.getjewelCfg(curid)
                                            if jcfg.level > curjewelcfg.level then
                                                self.jewelused[wid][p] = k
                                                alljewel[k] = alljewel[k]-1 --新的数量减掉
                                                alljewel[curid] = alljewel[curid]+1 --换下来的要加回去 换下来的低于10级
                                                flag = true
                                            end
                                        end  
                                    else
                                        self.jewelused[wid] = {0,0,0}
                                        self.jewelused[wid][p] = k
                                        alljewel[k] = alljewel[k]-1
                                        flag = true
                                    end  
                                end    
                            end
                        end
                    end
                end
            end
        end    
     
        updatePersonAchievement(self.uid,{'a6'})
        return ret,flag

    end


    -- 宝石增加属性
    -- att 宝石增加的属性  resonance 宝石共振增加的百分比
    function self.jewelAtt(wid)
        local pluscfg = getConfig('alienjewel.others.plus')
        local att = {}-- 宝石的属性
        local resonance = 0 -- 共振属性
        local lowestLV = 0 -- 宝石中最低等级
        local num = 0 -- 镶嵌宝石的数量
        -- 镶嵌在武器上的宝石
        if self.jewelused[wid] then
            local skillcfg = getConfig('alienjewel.skill')
            for k,v in pairs(self.jewelused[wid]) do
                if v~=0 and v ~= '' then
                    local cfg = self.getjewelCfg(v)
                    if type(cfg)=='table' and next(cfg) then
                        for key,val in pairs(cfg.attUp) do
                            att[key] = (att[key] or 0) + val
                        end

                        -- 十级宝石额外属性 单独处理
                        if cfg.level == 10 then
                            -- type=2是加技能等级的 不计算
                            local scfg = skillcfg[self.jewelinfo2[v][2]]
                            if type(scfg)=='table' and scfg.skilltype == 1 then
                                 att[scfg.attr] = (att[scfg.attr] or 0) + self.jewelinfo2[v][3]
                            end         
                        end

                        num = num + 1
                        if lowestLV == 0 then
                            lowestLV = cfg.level
                        end
                        if cfg.level < lowestLV then
                            lowestLV = cfg.level
                        end  
                    end
                end         
            end
        end

        if num == 3 and lowestLV>0 then
            resonance = pluscfg[lowestLV] or 0
        end

        return att,resonance
    end

    -- 武器装配宝石 增加的技能等级
    function self.jewelskilllv(wid)
        local addlv = 0 
        if self.jewelused[wid] then
            local skillcfg = getConfig('alienjewel.skill')
            for k,v in pairs(self.jewelused[wid]) do
                if v~=0 and v~='' then
                    local cfg = self.getjewelCfg(v)
                    if type(cfg)=='table' and next(cfg) then
                        -- 十级宝石额外属性 单独处理
                        if cfg.level == 10 then
                            local scfg = skillcfg[self.jewelinfo2[v][2]]
                            if scfg.skilltype == 2 then
                                addlv = addlv + 1
                            end         
                        end
                    end
                end         
            end
        end

        return addlv
    end

    -- 玩家登陆获取宝石数据(只是装配上的 其他的不要)
    function self.getlogindata()
        local data = {}
        data.jewelinfo1 = {}
        data.jewelinfo2 = {}
        data.jewelused = {}
        if not self.used then
            return data
        end

        for k,v in pairs(self.used) do
            if v~=0 and v~='' and v~='0' then
                if self.jewelused[v] then
                    local flag = false
                    for _,j in pairs(self.jewelused[v])  do
                        local subj = string.sub(j,1,1)
                        -- 十级宝石
                        if subj == 't' then
                            flag = true
                            data.jewelinfo2[j] = self.jewelinfo2[j]
                        elseif subj == 'j' then
                            flag = true
                            data.jewelinfo1[j] = (data.jewelinfo1[j] or 0) + 1
                        end
                    end
                    if flag then
                        data.jewelused[v] = self.jewelused[v]
                    end

                end
            end
        end

        return data

    end


    --[[
        获取使用中的装甲总强度值
    ]]
    function self.getStrengthValue()
        local value = 0
        local armorCfg = getConfig("alienWeaponCfg")
        for _,v in pairs(self.used) do
            value = value + self.getWeaponStrong(v)
        end


        return value
    end

    --得到某武器的强度
    function self.getWeaponStrong(wID)
        local strong = 0
        if self.info[wID] then
            local alienWeaponCfg = getConfig("alienWeaponCfg")
            local weaponCfg = alienWeaponCfg.weaponList[wID]
            local value
            for k,v in pairs(weaponCfg.attUp) do
                if k == "arp" or k == "armor" then
                    value = 1
                elseif k == "dmg" or k == "maxhp" then
                    value = 200
                else
                    value = 800
                end
                
                local lvAdd = alienWeaponCfg.attLevelUp[weaponCfg.color][k]
                local sLvAdd = alienWeaponCfg.attStrengLevel[weaponCfg.color][k]
                local finalAdd = v + self.info[wID][1] * lvAdd + self.info[wID][2] * sLvAdd

                strong = strong + finalAdd * value
            end
        end

        return math.ceil(strong)
    end

    --[[
        邮件展示信息
    ]]
    function self.formatUsedInfoForBattle()
        return {self.getStrengthValue(),self.used,self.jewelreport()}
    end

    
    function self.jewelreport()
        if moduleIsEnabled("jewelsys") ~= 1 then
            return {}
        end
        local data = {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}}
        if type(self.used)~='table' or type(self.jewelused)~='table' then
            return data
        end

        local cfg = getConfig('alienjewel.main')
        for k,v in pairs(self.used) do
            if string.find(v,'aw') then
                if self.jewelused[v] then
                    for p,j in pairs(self.jewelused[v])  do
                        local jid = self.getJewelidCfg(j)
                        if type(cfg[jid])=='table' then
                             data[k][p] = cfg[jid].color
                        end
                    end
                end
            end
        end

        return data
    end

    -- 按品质统计已装配的武器的总等级
    -- used: ["aw1",0,0,0,0,0]
    local function countEquippedWeaponLvByQuality(color)
        local lv = 0
        local cfg = getConfig("alienWeaponCfg").weaponList

        for _,weaponId in pairs(self.used) do
            if self.info[weaponId] and cfg[weaponId].color == color then
                lv = lv + (self.info[weaponId][1] or 0)
            end
        end

        return lv
    end

    -- 计算已镶嵌的宝石总等级
    local function countInlaidJewelLv()
        local lv = 0
        local cfg = getConfig("alienjewel").main

        -- 最大等级为10级的宝石比较特殊,是需要单独升上去的，所以ID是取不到配置的，直接默认为10
        local maxJewelLv = 10
        
        for _,jewels in pairs(self.jewelused) do
            if type(jewels) == "table" then
                for _,jewelId in pairs(jewels) do
                    if jewelId ~= 0 then
                        lv = lv + (cfg[jewelId] and cfg[jewelId].level or maxJewelLv)
                    end
                end
            end
        end

        return lv
    end

    -- 获取成就数据
    -- ntype：1.数量 2.等级
    function self.getAchievementData(ntype,data,subType)
        -- 已装备的异星武器宝石总等级达到80级（）
        if subType == "c" then
            return countInlaidJewelLv()

        -- 已装备的橙色异星武器总等级达到80级(橙色color=5)
        else
            return countEquippedWeaponLvByQuality(5)
        end
    end

    --------------------------------------------------------------    
    return self
end    
