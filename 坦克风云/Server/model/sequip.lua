function model_sequip(uid,data)
    local self = {
        uid=uid,
        sequip={}, --装备属性
        info={}, -- 抽取的数据
        stats={}, -- 出战状态 -- a 攻击  d 防守  m 军演  l 军团战
        smaster = {m1={"e901",{0,0,0},{},{0,{}},0,{}},},-- 装备大师
        sshop = {}, -- 装备大师商店
        xtimes = {t=0,x1=0,x2=0,x3=0},-- 每日洗练次数  三种洗练每日次数
        etypes = {},-- 进阶紫色 和橙色品质的装备 各自etype2的次数  指定次数必给etype1类型的
        gtimes = {},-- 洗练一定会提升强度的次数 {x1:[0,0],x2:[0,0]}
        updated_at=0,
    }

    local meta = {
        __index = function(tb, key)
                return rawget(tb,tostring(key)) or rawget(tb,'e'..key) or 0
        end 
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
        local data = {}
            for k,v in pairs (self) do
                if type(v)~="function" and k~= 'uid' and k~= 'updated_at' then              
                    if format then
                        data[k] = v
                    else
                        data[k] = v
                    end
                end
            end

        return data
    end

    -- 装备获取
    function self.addEquip(eid, num)
        num = tonumber(num) or 1

        local equipcfg = getConfig("superEquipListCfg.equipListCfg."..eid)
        if type (equipcfg) ~= 'table' then return false  end 
        -- 加装备大师
        if equipcfg.master==1 then
            return self.addMater(eid,num)
        end

        -- if self.count() > 150 then return false end
        local nums = 0
        if not self.sequip[eid] then
            self.sequip[eid] = {num}
        else
            nums = tonumber(self.sequip[eid][1])
            self.sequip[eid][1] = tonumber(self.sequip[eid][1]) + tonumber(num)
        end

        self.updateSkill(eid) --更新装置技能 存起来
        self.updateMaxStrongEquip(eid) -- 更新最强装备 刷战力

        -- 成就数据
        if equipcfg.color and equipcfg.color >= 5 then
            updatePersonAchievement(uid,{'a3','a4'})
        end

        regKfkLogs(self.uid,'item',{
                item_id=eid,
                item_op_cnt=num,
                item_before_op_cnt= nums,
                item_after_op_cnt= self.sequip[eid] and self.sequip[eid][1] or 0,
                item_pos='超级装备增加',
                flags={'item_id'},
                merge={'item_op_cnt'},
                rewrite={'item_after_op_cnt'},
                addition={
                },
            }
        )
        -- 战资比拼
        zzbpupdate(self.uid,{t='f10',n=num,id=eid})

        return true
    end

    -- 装备消耗
    function self.consumeEquip(eid, num)
        if not tonumber(num) or not self.sequip[eid] then
            -- print(eid, num, 'not id consume error' )
            return false
        end

        local nums = self.sequip[eid][1]
        num = math.floor(math.abs(num))
        if self.getValidEquip(eid) < num then -- 只有家里的才能消耗
            -- print(self.sequip[eid][1], num, 'num consume error')
            return false
        end
        self.sequip[eid][1] = tonumber(self.sequip[eid][1]) - num
        if self.sequip[eid][1] == 0 then
            self.sequip[eid] = nil

            self.updateMaxStrongEquip() -- 刷新最强装备
            self.updateSkill(eid, true)  -- 刷新装置技能
        end

        regKfkLogs(self.uid,'item',{
                item_id=eid,
                item_op_cnt=-num,
                item_before_op_cnt= nums,
                item_after_op_cnt= self.sequip[eid] and self.sequip[eid][1] or 0,
                item_pos='超级装备消耗',
                flags={'item_id'},
                merge={'item_op_cnt'},
                rewrite={'item_after_op_cnt'},
                addition={
                },
            }
        )

        return true
    end

    -- 装备进阶
    function self.upgradeEquip(color, num)
        local ret, reward = self.addRandEquip(color, num)
        if ret then
            self.updateMaxStrongEquip()
        end
        return ret, reward
    end

    -- 装备升级
    function self.levelupEquip(eid, num)
        return self.addEquip(eid, num)
    end

    -- 装备分解
    function self.resolveEquip(eid, num)
        num = tonumber(num) or 1
        if not self.consumeEquip(eid, num) then
            return false, -1911
        end

        local equipcfg = getConfig('superEquipListCfg.equipListCfg.' .. eid)
        if not equipcfg then
            return false, -404
        end
        local items = copyTab(equipcfg.deCompose)
        local ret = {}
        --ptb:p(items)
        local uobjs = getUserObjs(self.uid)
        local mBag = uobjs.getModel('bag')
        for k, v in pairs( items ) do
            ret[k] = (ret[k] or 0) + v*num
            if not mBag.add(k, v*num) then
                return false, -403
            end
        end

        return true, ret
    end

    -- 装备属性 
    function self.sequipAttr(eid, troopsAdd) 
        local  attr = {}
        -- 判断是不是装备大师或者镜像
        local ismirror,midkey = self.checkmirror(eid)
        if ismirror then
            attr = self.getMasterAtt(midkey,ismirror)
        elseif eid and string.sub(eid,1,1)=='m'  then
            attr = self.getMasterAtt(eid)
        else
            local equipcfg = getConfig('superEquipListCfg.equipListCfg.' .. eid)
            if not equipcfg then
                return 0
            end

            attr = copyTab( equipcfg.attUp )
        end
        
        if troopsAdd then
            return attr.troopsAdd or 0
        end

        return attr
    end

    -- 装备技能 (带上超级装备 生效)
    -- function self.sequipSkill(eid)
    --     local cfg = getConfig("superEquipListCfg.equipListCfg." .. eid)
    --     if not cfg or cfg.etype ~= 1 then return false end

    --     local skillcfg = getConfig("superEquipListCfg.skillCfg." .. cfg.skill[1])
    --     if not skillcfg then return false end

    --     -- {类型，值}
    --     return  { cfg.skill[1], skillcfg.value[ cfg.skill[2] ] }

    -- end

    --出征的 动态技能
    -- eid 携带的装备  sid 查找的技能  def 技能默认值
    function self.dySkillAttr(eid, sid, def)
        if not eid or not sid then return def end

        local add = {}
        local ismirror,midkey = self.checkmirror(eid)
        if ismirror then
            -- 装备没开就不生效
            if moduleIsEnabled('smaster') == 0 then
                return def
            end
            local master = self.mirrormaster(midkey) 
            return self.checkmasterskill(master,sid,def)

        -- 装备大师上面可装备三个超级装备 每个装备的技能都要检测
        elseif eid and string.sub(eid,1,1)=='m' then
            -- 装备没开就不生效
            if moduleIsEnabled('smaster') == 0 then
                return def
            end

            if type(self.smaster[eid])~='table' then return def end
            return self.checkmasterskill(self.smaster[eid],sid,def)
        else
            local cfg = getConfig("superEquipListCfg.equipListCfg." .. eid)
            if not cfg or type(cfg.skill) ~= 'table' then return def end

            local skillcfg = getConfig("superEquipListCfg.skillCfg." .. cfg.skill[1])
            if tostring("s" .. skillcfg.stype) ~= sid then return def end

            add = copyTab( skillcfg["value" .. cfg.skill[2] ] )
            if not add then return def end

            if table.length( add ) == 1 then
                add = add[1]
            else
                tankError('sequip cfg error')
            end
        end
   
        return add
    end
    
    -- 装备大师上装备技能触发值检测（逻辑类似超级装备）
    function self.checkmasterskill(master,sid,def)
        local add = {}
        if type(master)~='table' then return def end
        for k,v in pairs(master[2] or {}) do
            if v~=0 then
                local cfg = getConfig("superEquipListCfg.equipListCfg." ..v)
                if type(cfg)=='table' and type(cfg.skill)=='table' then
                    local skillcfg = getConfig("superEquipListCfg.skillCfg." .. cfg.skill[1])
                    if tostring("s" .. skillcfg.stype) == sid then
                        add = copyTab( skillcfg["value" .. cfg.skill[2] ] )
                        if add and table.length( add ) == 1 then
                            add = add[1]
                            return add
                        else
                            tankError('sequipskill '..sid..'cfg error')
                            return def
                        end
                    end
                end
            end
        end
        
        return def
    end

    -- 装置的 静态技能
    function self.skillAttr(sid, def)
        if type( self.info.s ) ~= 'table' then return def end

        return self.info.s[ sid ] or def
    end

    -- 更新装置技能最大值 （超级装置 放在家里 生效，存起来）
    function self.updateSkill(eid, isref)
        local cfg = getConfig("superEquipListCfg.equipListCfg." .. eid)
        if not cfg or cfg.etype ~= 2 then return false end

        if isref then
            return self.refreshSkill()
        end

        local skillcfg = getConfig("superEquipListCfg.skillCfg." .. cfg.skill[1])
        local sid = 's' .. skillcfg.stype -- 技能id  用stype 
        local value = copyTab( skillcfg["value" .. cfg.skill[2]] )
        if table.length(value) == 1 then -- 技能数值都用1号位
            value = value[1]
        else
            tankError('func updateskill sequip cfg error') -- 配置错误要及时更新
        end

        self.info.s = self.info.s or {}

        local gemsid = 's305'
        -- 首次得到钻石合成器后不发
        if sid == gemsid and not self.info.s[ sid ] then
            self.info.gems = {getClientTs(), 0}
        end

        if not self.info.s[ sid ] or ( self.info.s[ sid ] < value ) then
            self.info.s[ sid ] = value
        end

        return true
    end

    -- 装置技能刷新，分解装备后技能会消失
    function self.refreshSkill( )
        local cfg = getConfig("superEquipListCfg.equipListCfg")
        local skillcfg = getConfig("superEquipListCfg.skillCfg")
        local gemsid = 's305'
        local gemsflag = false

        --将所有装置技能刷新
        local ret = {}
        for eid, v in pairs( self.sequip ) do
            if cfg[eid].etype == 2  then
                local sid, lvl = cfg[eid].skill[1], cfg[eid].skill[2]
                local value = skillcfg[sid]['value' .. lvl][1]

                local typeid = "s" .. skillcfg[sid].stype -- stype 才是技能唯一标识
                if not ret[typeid]  then
                    ret[typeid] = value 
                elseif ret[typeid] < value then
                    ret[typeid] = value 
                end

                if typeid == gemsid then
                    gemsflag = true
                end
            end
        end

        if not gemsflag and self.info.gems then -- 产钻石技能 需要额外处理
            self.info.gems = nil
        end
        self.info.s = ret
    end

    --钻石合成器
    function self.checkAndAward()
        local redis = getRedis()
        local key = "global.sequip.sysgems." .. getWeeTs()
        -- 增加缓存标记 防止save()失败 而发邮件奖励
        local result = redis:hget(key, self.uid)
        if tonumber(result) and tonumber(result) == 1 then --发过了
            return false
        end

        local sid = 's305'        
        if type( self.info.s ) ~= 'table' or not self.info.s[sid]  then -- 没有该技能
            return false 
        end

        if not self.info.gems or self.info.gems[1] > getWeeTs() then --发过了
            return false
        end

        local num = math.floor( (getWeeTs() - getWeeTs( self.info.gems[1] ) ) /86400 )
        local addGems = self.info.s[sid] * num -- 获得钻石数
        local m = {
            subject = 55,
            content={type=55, gems=addGems},
        }
        local item={
            h={
                userinfo_gems=addGems,
            },
            q={
                u={
                    {gems=addGems},
                }
            },
            f={0},
        }

        local ret = MAIL:mailSent(self.uid,1,self.uid,'','', m.subject, m.content,1,0, 1, item)
        if ret then
            if not redis:hset(key, self.uid, 1) then
                writeLog({'set sequip add gems to redis fail ... ', uid=self.uid,  gems=addGems }, 'error')
            else
                redis:expire(key, getWeeTs() + 86400)
            end
        end

        self.info.gems = {getClientTs(), addGems}

        return true
    end

    function self.update(olvl)
        -- body
        self.checkAndAward()

        if olvl then --登陆的时候后端返回 开放等级
            return getConfig("superEquipCfg.equipOpenLevel")
        end

        return true
    end

    function self.checkAttackStats()
        if type(self.stats.a) == "table" and next(self.stats.a) then
            local uobjs = getUserObjs(self.uid)
            local mTroop = uobjs.getModel('troops')
            for k in pairs(self.stats.a) do
                if string.find(k, "c") == 1 then
                    if not mTroop.getFleetByCron(k) then
                        self.releaseEquip('a',k)
                    end
                end
            end
        end
    end

    -- 设置状态 id
    function self.addEquipFleet(attack, id, eid)
        -- writeLog({'addEquipFleet -->', attack, id, eid}, 'sequip')
        if not eid or not self.checkFleetEquipStats(eid) then return false end
        
        local ismirror,midkey = self.checkmirror(eid)
        if ismirror then
            -- 如果是大师镜像 不处理
        elseif string.sub(eid,1,1)=='m' then
            local realeid = self.smaster[eid][1]
            local cfg = getConfig("superEquipListCfg.equipListCfg." .. realeid)
            if not cfg or cfg.etype ~= 1 then return false end
        else
            -- 装备才能带出去
            local cfg = getConfig("superEquipListCfg.equipListCfg." .. eid)
            if not cfg or cfg.etype ~= 1 then return false end
        end
        
        self.stats[attack] = self.stats[attack] or {}
        self.stats[attack][id] = eid
        return true
    end

    --获取出战的超级装备 id
    function self.getEquipFleet(attack, id)
        if type(self.stats[attack]) == 'table' then
            if attack == 'd' and not self.checkFleetEquipStats( self.stats[attack][id] ) then
                return 0
            end
            return self.stats[attack][id] or 0
        end

        return 0
    end

    --单个超级装备能带出去
    function self.checkFleetEquipStats(eid, extList)
        local num = 0    
        local ismirror,midkey = self.checkmirror(eid)
        -- 大师镜像判断
        if ismirror then
            if type(self.smaster[midkey[12]])~='table' then return false end
            num = 1
        elseif eid and string.sub(eid,1,1)=='m' then
            -- 此处需要判断是不是装备大师 
            if type(self.smaster[eid])~='table' then
                return false
            end
            num = 1 -- 每个装备大师是惟一的  有各自的属性
        else
            -- 这是正常装备的
            if type(self.sequip[eid]) ~= 'table' then 
                return false
            end

            num = self.sequip[eid][1]

            -- 检测装配在装备大师上的数量
            local sn = self.settedEquipNum(eid)
            num = num - sn
        end
    
        if type(self.stats.a) == 'table' then
            for k, v in pairs(self.stats.a) do
                if v == eid then
                    num = num - 1
                end
            end
        end

        --有额外的装备需要扣掉
        if extList and type(extList) == 'table' then
            for k, v in pairs( extList ) do
                if k == eid then
                    num = num - tonumber(v)
                end
            end
        end

        return num > 0
    end

    -- 多个超级装备能带出
    -- 防止镜像带出多个，检测列表； 镜像派出去不影响已经设置的装备 需要检测的eid
    function self.checkEquipStats(elist, check_eid)
        if type(elist) ~= 'table' then return false end

        local eids = {}
        for k, eid in pairs(elist) do
            if tostring(eid) ~= '0' then --默认值忽略
                eids[eid] = (eids[eid] or 0) + 1
            end
        end
        
        -- 装备大师每个都是单独的
        if check_eid and string.sub(check_eid,1,1)=='m' then
            if type(self.smaster[check_eid])~='table' then return false end
        else
            --扣除带出去的装备 e1 2 - 1 = 1  e2   
            local sequip = copyTab( self.sequip )
            if type(sequip[check_eid]) ~= 'table' then return false end
            if eids[check_eid] > sequip[check_eid][1]  then
                return false
            end
        end
      
        return true
    end

    -- 释放 出战装备
    function self.releaseEquip(attack,id)
        if type (self.stats[attack])=='table' then 
            if self.stats[attack][id] then 
                self.stats[attack][id]=nil
            end

            --战败而归 加个推送
            if attack == 'a' then
                regSendMsg(self.uid,'msg.sequip', {sequip = {stats = self.stats } })
            end
        end
    end

    -- 随机获取 color阶装备
    function self.addRandEquip(color, num)
        num = tonumber(num) or 1
        local equipcfg = getConfig('superEquipCfg.upgrade')

        if not equipcfg.pool[color] then
            return false
        end

        if not self.etypes.c4 then
            self.etypes.c4 = {0,0}-- {上次抽到的,当前次数}
        end

        if not self.etypes.c5 then
            self.etypes.c5 = {0,0}
        end
        local specical = {'c4','c5'}
        local cid = 'c'..color
        local retaward = {}
        for i=1, num do
            local result
            if table.contains(specical,cid) then
                -- 大于配置次数 必定给etype=1的
                local ekey
                if self.etypes[cid][2]>=equipcfg.advanceGet then
                    result = getRewardByPool( equipcfg.battlePool[cid])
                    ekey = self.getrkey(result)
                else
                    result = getRewardByPool(equipcfg.pool[color])
                    ekey = self.getrkey(result)  
                    if ekey[2]==self.etypes[cid][1] then
                        for n=1,3 do
                            result = getRewardByPool(equipcfg.pool[color])
                            ekey = self.getrkey(result)
                            -- 随机出不同的 就跳出 3次之后还是相同的 随机到哪个用哪个
                            if ekey[2]~=self.etypes[cid][1] then
                                break
                            end
                        end
                    end
                end

                local eid = ekey[2]
                -- 其他每次都不相同
                local cfg = getConfig("superEquipListCfg.equipListCfg." .. eid)
                if cfg.etype==1 then
                    self.etypes[cid][2]=0
                else
                    self.etypes[cid][2] = self.etypes[cid][2] + 1
                end

                self.etypes[cid][1]=eid
            else
                result = getRewardByPool( equipcfg.pool[color] )
            end
            
            if not takeReward(self.uid, result) then
                return false
            end

            for k, v in pairs( result ) do
                retaward[k] = (retaward[k] or 0 ) + v
            end
        end

        return true, retaward
    end

    -- 获取抽奖结果的key
    function self.getrkey(result)
        local ekey
        for re,rv in pairs(result) do
            ekey = re:split('_')
        end
        return ekey
    end

    -- 战斗力
    function self.getFightAttr()
        -- body
        local equipcfg = getConfig("superEquipListCfg.equipListCfg")
        local maxeid = self.maxstrong()

        local attr = {}
        -- 如果是个装备大师 需要特殊处理
        if string.sub(maxeid,1,1) == 'm' then
            attr = self.getMasterAtt(maxeid)
        else
            if equipcfg[maxeid] and equipcfg[maxeid].attUp then 
                attr = equipcfg[maxeid].attUp
            end
        end

        local attr2code = getConfig("common.attributeStrForCode")
        local codeattr = {}
        for k, v in pairs( attr ) do
            if attr2code[k] then
                codeattr[ attr2code[k] ] = v
            end
        end

        return codeattr
    end

    -- 战斗力
    function self.getFightAttrSquip(maxeid)
        -- body
        local equipcfg = getConfig("superEquipListCfg.equipListCfg")
 
        local attr = {}
        -- 如果是个装备大师 需要特殊处理
        if maxeid and string.sub(maxeid,1,1) == 'm' then
            attr = self.getMasterAtt(maxeid)
        else
            if equipcfg[maxeid] and equipcfg[maxeid].attUp then 
                attr = equipcfg[maxeid].attUp
            end
        end

        local attr2code = getConfig("common.attributeStrForCode")
        local codeattr = {}
        for k, v in pairs( attr ) do
            if attr2code[k] then
                codeattr[ attr2code[k] ] = v
            end
        end

        return codeattr
    end

    -- 最强装备 可加可减
    function self.updateMaxStrongEquip( eid )
        local equipcfg = getConfig("superEquipListCfg.equipListCfg")
        eid = nil -- 用于刷新暗强度
        local cur_eid = self.info.strong
        local max_eid = nil
        if not eid then -- 分解装备后 刷新
            for k, v in pairs(self.sequip) do 
                if equipcfg[k].etype==1 and (not max_eid or equipcfg[max_eid].anqiangdu < equipcfg[k].anqiangdu) then
                    max_eid = k
                end 
            end
        elseif equipcfg[eid].etype == 1 then -- 获得装备刷新
            if not cur_eid then
                max_eid = eid  -- 第一个装备
            elseif equipcfg[cur_eid].anqiangdu < equipcfg[eid].anqiangdu then
                max_eid = eid -- 更强的
            else
                max_eid = cur_eid -- 还是原来的
            end
        end

        if moduleIsEnabled('smaster') == 1 then
            -- 获取最强的装备大师
            local mid,qd = self.getStrongMaster()
            if mid then
                if max_eid then
                    if equipcfg[max_eid].anqiangdu<qd then
                        max_eid = mid
                    end
                else
                    max_eid = mid
                end
            end
        end

        self.info.strong = max_eid
        return true
    end

    -- 获取最强装备
    function self.maxstrong()
        return self.info.strong or 0
    end

    -- 装备个数
    function self.count()
        -- body
        local cnt = 0
        if type(self.sequip) == 'table' then
            for k, v in pairs(self.sequip) do
                cnt = cnt + v[1]
            end
        end

        return cnt
    end

    --放在家里可以直接使用个数
    function self.getValidEquip(eid)
     
        local num = 0
        if eid and string.sub(eid,1,1)=='m' then
      
            if type(self.smaster[eid])~='table' then
                return false
            end
            num = 1 -- 每个装备大师是惟一的  有各自的属性
        else
            if type(self.sequip[eid]) ~= 'table' then 
                return 0
            end

            num = self.sequip[eid][1]
            -- 检测装配在装备大师上的数量
            local sn = self.settedEquipNum(eid)
            num = num - sn
        end

        if type(self.stats.a) == 'table' then
            for k, v in pairs(self.stats.a) do
                if v == eid then
                    num = num - 1
                end
            end
        end

        return num
    end

    -- 添加装备大师 
    function self.addMater(mid,num)
        local ret = true
        local idtab = {}
        -- 数量上限判断
        local mcount = table.length(self.smaster)
        local beforen = mcount
        local max = getConfig('sequipMaster.main.ownLimit')
        -- 上限需要取配置
        if mcount+num>max then
            ret = false
            return ret,idtab
        end
        for i=1,num do
            local newkey = self.getMasterId(masterlen)
            
            self.smaster[newkey] = {mid,{0,0,0},{},{0,{}},0,{}}-- 配置编号  装配的装备 洗练加成 未保存的洗练值 洗练强度 洗练消耗
            table.insert(idtab,newkey)
            mcount = mcount + 1
        end

        regKfkLogs(self.uid,'item',{
                item_id=mid,
                item_op_cnt=num,
                item_before_op_cnt= beforen,
                item_after_op_cnt= mcount,
                item_pos='超级装备大师增加',
                flags={'item_id'},
                merge={'item_op_cnt'},
                rewrite={'item_after_op_cnt'},
                addition={
                },
            }
        )
        return ret,idtab   
    end
 
    -- 服务器创建装备大师的id
    function self.getMasterId(masterlen)
        masterlen = masterlen or 1
        local key = string.sub(os.time(),-3)
        local mid = 'm'..key
        if type(self.smaster[mid]) =='table' then
            mid = mid .. masterlen   
            masterlen = masterlen + 1
            if self.smaster[mid] then
                return self.getMasterId(masterlen)    
            end
        end
        return mid,masterlen
    end

    -- 检测装备大师上能否装配超级装备
    -- mid装备大师id
    -- eid 超级武器id
    -- p装配位置
    function self.checkSetMsequip(mid,eid,p)
        -- 装备大师上不能再装备装备大师
        if eid and string.sub(eid,1,1) == 'm' then
            return false
        end
        -- 有没有空闲的装备
        if self.getValidEquip(eid)<=0 then
            return false
        end

        if type(self.smaster[mid])~='table' then
            return false
        end

        local skillflag = false -- 有没有相同的技能
        local pflag = false -- 有没有位置
        local sTypePool = {}
        local ecfg = getConfig('superEquipListCfg.equipListCfg.'..eid)
  
        
        if type(ecfg)~='table' then return false end
        if ecfg.master == 1 then return false end

        -- 有没有空闲的位置
        -- 检测 已装配的是否有相同或者相同技能类型的装备
        for k,v in pairs(self.smaster[mid][2]) do
            if v ~= 0 then
                local equipcfg = getConfig('superEquipListCfg.equipListCfg.'..v)
                if type(equipcfg.skill) == 'table' then
                    local skill = equipcfg.skill
                    local skillcfg = getConfig('superEquipListCfg.skillCfg.'..skill[1])
                    table.insert(sTypePool,skillcfg.stype)
                end
              
            end
        end

        if type(ecfg.skill)=='table' then
            local eskillcfg = getConfig('superEquipListCfg.skillCfg.'..ecfg.skill[1])
            if table.contains(sTypePool,eskillcfg.stype) then
                return false
            end

        end

        -- 需要根据历史洗练最高强度值判断是否解锁
        local unlockPlace = getConfig('sequipMaster.main.unlockPlace')
        if self.smaster[mid][5]<unlockPlace[p] then
            return false 
        end
     
        if (tonumber(self.smaster[mid][2][p]) or 0) == 0 then
            return true
        end

        return false
    end

    -- 装备大师上装配装备
    function self.setMsequip(mid,eid,p)
        if not self.checkSetMsequip(mid,eid,p) then
            return false
        end 

        -- 待定 此处是否将装配在大师上的 超级装备在 sequip库中减1 
        -- 防止在 类似跨服战中 同一个超级装备可以在多个大师中装配

        self.smaster[mid][2][p] = eid 
        return true
    end

    -- 卸下装备大师上的装备
    function self.unsetMsequip(mid,p)
        if type(self.smaster[mid])~='table' then
            return false
        end

        self.smaster[mid][2][p]=0
        return true
    end

    -- 超级装备/装备大师还原(升级过的橙色超级装备、紫色超级装备、洗练过的装备大师)
    function self.reset(id)
        local ts = getClientTs()
        -- 个人跨服战期间不能还原
        require "model.serverbattle"
        local mServerbattle = model_serverbattle()
        --1 个人战
        --缓存跨服战的基本信息
        local mMatchinfo, code = mServerbattle.getRoundInfo(1)
        if code == 0 and next(mMatchinfo) then
            if ts>=tonumber(mMatchinfo.st) and ts<=tonumber(mMatchinfo.et) then
                return false,-27010
            end
        end

        if moduleIsEnabled('smaster') == 0 then
            return false,-180
        end
        if moduleIsEnabled('ser') == 0 then
           return false,-180
        end

        -- 判断是否是超级装备还是装备大师
        local reward = {} -- 返回消耗
        local restoreRate = getConfig('sequipMaster.main.restoreRate')-- 返回比例
        -- 装备大师
        if string.sub(id,1,1)=='m' then
            return false,-180-- 大师不给还原
            -- if type(self.smaster[id]) ~= 'table' then return false end
            -- --if not self.checkmaster(id) then return false end
            -- if self.smaster[id][5]<=0 then return false end

            -- local sCfg = getConfig('sequipMaster.refine')
            -- local oricost = {}
            -- for k,v in pairs(self.smaster[id][6]) do
            --     local xcfg = sCfg[k].cost
            --     for xk,xv in pairs(xcfg) do
            --         oricost[xk] = (oricost[xk] or 0) + xv*v
            --     end
            -- end

            -- for k,v in pairs(oricost) do
            --     reward[k] = math.ceil(v*restoreRate)
            -- end
        
            -- -- 重置属性
            -- self.smaster[id][2] = {0,0,0} -- 卸下已装备的武器
            -- self.smaster[id][3] = {} -- 洗练属性清理
            -- self.smaster[id][4] = {0,{}} -- 上一次洗练的类型 上一次洗练值
            -- self.smaster[id][5] = 0  -- 强度
            -- self.smaster[id][6] = {} -- 洗练消耗
        else -- 超级装备
            local orireward = {}
            local ecfg = getConfig('superEquipListCfg.equipListCfg.'..id)
            if type(ecfg) ~= 'table' then
                return false
            end
            if ecfg.color < 4 or ecfg.lv == 0 then
                return false
            end

            local ekey = id:split('_')
            local lv = ecfg.lv - 1
            for i=0,lv do
                local tmpid = ekey[1]
                if i > 0 then
                    tmpid = tmpid..'_'..i
                end

                local upcost = getConfig('superEquipListCfg.equipListCfg.'..tmpid..'.upCost')
                for k,v in pairs(upcost) do
                    local rkey = 'props_'..k
                    orireward[rkey] = (orireward[rkey] or 0) + v 
                end
            end

            for k,v in pairs(orireward) do
                reward[k] = math.ceil(v*restoreRate)
            end

            if not self.consumeEquip(id,1) then
                return false, -1911
            end

            self.addEquip(ekey[1])
        end

        return true,reward
    end

    -- 装备大师是否派出了
    function self.checkmaster(mid)
        if self.info.strong and self.info.strong == mid then
            return false
        end

        return true
    end

    --还原价格（需要花费的钻石）（大师：还原方法：记录三种精炼保存的次数（包括自动），按比例返还材料。紫色、橙色：还原方法：升过级的还原成未升级的，按比例返还材料）
    function self.resetCost(id)
        local restoreCost = getConfig('sequipMaster.main.restoreCost')-- 返回比例
        if id and string.sub(id,1,1)=='m' then
            return restoreCost[1]
        else
            local ecfg = getConfig('superEquipListCfg.equipListCfg.'..id)
            if ecfg.color == 4 then
                return restoreCost[2]
            elseif ecfg.color == 5 then
                return restoreCost[3]
            end
        end

        return false
    end


    -- 洗练 mid:洗练的大师id  x：洗练类型
    -- 注：洗练值是替换上次的 不累加
    function self.succinctValue(mid,x)
        local ret = 0
        if type(self.smaster[mid]) ~= 'table' then
            return -102
        end

        self.smaster[mid][4] = {0,{}} -- 将上次洗练出来的值清空  第一位洗练类型 上一次的洗练值
        --强度差=强度-当前强度。
        --minUp和maxUp限制强度差，强度差不满足当前分组的区间需要重新随机（防止卡死，随机次数最大5次）。

        local sCfg = getConfig('sequipMaster.refine.'..x)
        if self.checkSuMax(mid,sCfg) then
            return -27016 
        end

        -- 当前强度值 maxhp=1.8,dmg=1.8,accuracy=0.8,evade=0.8,crit=0.8,anticrit=0.8
        local strength = self.getStrength(self.smaster[mid][3])
         -- 初始化保底次数
        self.sucrand(x,sCfg,strength)
               
        -- 强度区间
        local len = #sCfg.strPart
        local sid = 0
        for i=len,1,-1 do
            if strength>=sCfg.strPart[i] then
                sid = i
                break
            end
        end

        if sid == 0  then
           return -102
        end
        -- 随机 洗练属性
        local  final = {}
        local difstren = 0 -- 强度差
        for re=1,5 do
            local tmp = {}
            for k,v in pairs(sCfg.maxAtt) do
                local cur = self.smaster[mid][3][k] or 0
                
                -- 计算当前属性下标
                local slen = #sCfg[k..'_s']
                local atid = 0
                for s=slen,1,-1 do
                    if cur>= sCfg[k..'_s'][s] then
                        atid = s
                        break
                    end
                end
 
                local r = (rand(1,10)/10)*(cur-cur*sCfg[k..'_b'][atid]+sCfg[k..'_f'][atid])+cur*sCfg[k..'_b'][atid]
                tmp[k] = tonumber(string.format("%.3f",r))
            end      
            -- 结果强度 
            local rstrength =  self.getStrength(tmp)
            difstren = rstrength - strength
        
            final = tmp
            if sCfg.minUp[sid]<=difstren and difstren<=sCfg.maxUp[sid] then
                break
            end
        end

        -- 保底机制
        local finalstren = self.getStrength(final)
        if finalstren<=strength then
            self.gtimes[x][2] = self.gtimes[x][2] + 1
            if self.gtimes[x][2]>= self.gtimes[x][1] then
                setRandSeed()
                local tmpstren = 0
                for i=1,5 do
                    local att = {}
                    for k,v in pairs(sCfg.maxAtt) do
                        local cur = self.smaster[mid][3][k] or 0
                        cur = (cur * 1000 + rand(v*sCfg.gAttRate[1]*1000,v*sCfg.gAttRate[2]*1000))/1000     
                        att[k] = tonumber(string.format("%.3f",cur))
                    end 

                    tmpstren = self.getStrength(att)
                    final = att
                    if tmpstren-finalstren>sCfg.gLimit then
                        final = att
                        break
                    end
                end 
                
                --writeLog('大师洗练保底机制触发:uid='..self.uid..'gtimes='..json.encode(self.gtimes), 'smaster')
                self.sucrand(x,sCfg,tmpstren,true)
            end
        else
            self.gtimes[x][2] = 0
        end

        self.smaster[mid][4][1] = x
        self.smaster[mid][4][2] = final -- 保留本次的洗练值

        local cret,costgem = self.succinctCost(sCfg)
        if cret~=0 then
            return cret,{},0
        end
        -- 更新个类型洗练每日的执行次数
        self.xtimes[x] = (self.xtimes[x] or 0) + 1
   
        local maxAtt = sCfg.maxAtt -- x1 x2 x3公用各属性上限值
        for k,v in pairs(maxAtt) do
            if final[k] and final[k]>v then
                final[k] = v
            end
        end

        return ret,final,costgem
    end

    -- 随机洗练保底次数
    function self.sucrand(x,cfg,strength,flag)
        if type(self.gtimes)~='table' then
            self.gtimes = {}
        end

        if not self.gtimes[x] or flag then
            self.gtimes[x] = {0,0}-- 保底提升强度的次数  未提升的次数
        end

        if self.gtimes[x][1]<=0 then
            setRandSeed()
            local times=100 
            if strength>=cfg.gDown then
                times = rand(cfg.gDownTime[1],cfg.gDownTime[2])
            else
                times = rand(cfg.gTime[1],cfg.gTime[2])
            end
             
            self.gtimes[x][1]=times
        end
    end


    -- 装备大师洗练消耗
    function self.succinctCost(costCfg)
        local gem = 0
        local ret = 0
        local uobjs = getUserObjs(self.uid)
        uobjs.load({"userinfo","bag"})
        local mUserinfo = uobjs.getModel('userinfo')
        local mBag = uobjs.getModel('bag')

        for k,v in pairs(costCfg.cost) do
            local cinfo = k:split('_')
            if cinfo[1] == 'userinfo' and cinfo[2] =='gems' then
                if not mUserinfo.useGem(v) then
                    ret = -27018
                    return ret,gem
                end
                gem = v
            elseif cinfo[1] == 'props' then
                 if not mBag.use(cinfo[2],v) then
                    ret = -27018
                    return ret,gem
                 end
            else
                -- 新类型 需要处理
                ret = - 27018
                return ret,gem
            end
        end

        return ret,gem

    end

    -- 保存洗练值 mid:装备大师的id  
    function self.upsuccinct(mid)
        if type(self.smaster[mid]) ~= 'table' then
            return false
        end

        local x = self.smaster[mid][4][1]
        local xCfg = getConfig('sequipMaster.refine.'..x)

        if type(xCfg) ~= 'table' then return false end
        local maxAtt = xCfg.maxAtt -- x1 x2 x3公用各属性上限值
        for k,v in pairs(self.smaster[mid][4][2]) do
            -- 不存在的属性
            if not maxAtt[k] then
                return false
            end

            -- 不能超过最大值
            self.smaster[mid][3][k] = v
            if self.smaster[mid][3][k]>maxAtt[k] then
                self.smaster[mid][3][k] = maxAtt[k]
            elseif self.smaster[mid][3][k]<0 then
                self.smaster[mid][3][k] = 0
            end
        end

        -- 更新历史最高强度值
        local newstrength = self.getStrength(self.smaster[mid][3])
        if newstrength>self.smaster[mid][5] then
            self.smaster[mid][5] = math.ceil(newstrength)
        end
     
        -- 记录只有保存时 消耗的物品
        self.recordCost(mid,x)
        
        -- 清理上次洗练的值
        self.smaster[mid][4] = {0,{}}



        return true
    end

    -- 计算装备大师洗练强度  att 各属性构成的table
    -- 强度=(hp+dmg+crit+anticrit)*200+sum(剩下两种)*550
    function self.getStrength(att)
        local strength = ((att.hp or 0) + (att.dmg or 0)+ (att.crit or 0)+(att.anticrit or 0))*200 + ((att.accuracy or 0)+(att.evade or 0))*550

        --return math.ceil(strength)
        return strength
    end

    -- 记录各精炼保存次数
    function self.recordCost(mid,x)   
        self.smaster[mid][6][x] = (self.smaster[mid][6][x] or 0) + 1
    end

    -- 检测装备大师各属性是否达到最大值
    function self.checkSuMax(mid,cfg)
        if not next(self.smaster[mid][3]) then
            return false
        end

        for k,v in pairs(self.smaster[mid][3]) do
            local cur = tonumber(v) or 0
            if cur==0 or cur < tonumber(cfg.maxAtt[k]) then
                return false
            end
        end


        return true
    end

    --装备大师属性
    function self.masteratt(master)
        local att = {}
        for k,v in pairs(master[3]) do
            att[k] = (att[k] or 0 ) + v
        end

        local equipcfg = getConfig("superEquipListCfg.equipListCfg."..master[1])
        for k,v in pairs(equipcfg.attUp) do
            att[k] = (att[k] or 0 )+v
        end
 
        -- 如果装备了其他的超级装备 需要累加计算
        -- 根据位置 按照一定百分比继承属性
        local placeGet = getConfig('sequipMaster.main.placeGet')
        local colornum = {}
        for k,v in pairs(master[2]) do
            if v~=0 and v~='0' then
                local scfg = getConfig("superEquipListCfg.equipListCfg."..v)
                if type(scfg)=='table' then
                    local rate = placeGet[k]-- 根据位置 取继承属性加成比例
                    for sk,sv in pairs(scfg.attUp) do
                        att[sk] = (att[sk] or 0 )+sv*rate
                    end
                    colornum['c'..scfg.color] = (colornum['c'..scfg.color] or 0) + 1
                end
            end
        end

        -- 三个位置装配的额外加成
        if next(colornum) then
            local colorUp = getConfig('sequipMaster.colorUp')
            for k,v in pairs(colorUp) do
                local cid = 'c'..v.colorNeed
                if colornum[cid] and colornum[cid]>=v.numNeed then
                    for ak,val in pairs(v.attUp) do
                        att[ak] = (att[ak] or 0) + val
                    end
                end
            end
        end  

        --洗练强度解锁卡槽增加的属性值
        local sUnlock = getConfig('sequipMaster.sUnlock')
        for k,v in pairs(sUnlock) do
            if master[5]>=v.strNeed then
                if v.troopsAdd then
                    att['troopsAdd'] = (att['troopsAdd'] or 0)+v.troopsAdd      
                end

                if v.first then
                     att['first'] = (att['first'] or 0)+v.first
                end
            end
        end   

        local finalatt = {}
        for k,v in pairs(att) do
            if k == 'troopsAdd' or k=='first' then--带兵量/先手值
                finalatt[k] = math.ceil(v)
            else
                finalatt[k] = tonumber(string.format("%.3f",v))
            end
        end

        return finalatt
    end

    -- 装备大师的基础属性 = 自身基础属性+洗练+继承其他装备属性（装配的）
    -- mid大师id  
    -- ismirror  是否是镜像数据
    function self.getMasterAtt(mid,ismirror)
        local att = {}
        if moduleIsEnabled('smaster') == 0 then
           return att
        end

        local smaster = {}
        if ismirror then
            smaster = self.mirrormaster(mid)
        else
            smaster = copyTable(self.smaster[mid])
        end
        if type(smaster)~='table' or not next(smaster) then
            return att
        end
        att = self.masteratt(smaster)

        return att
    end

    -- 格式化镜像装备大师
    function self.mirrormaster(mirror)
        if type(mirror)~='table' then
            return {}
        end
        -- 该格式是固定的  装备大师配置id  位置1装备 位置2装备 位置3装备 'hp','dmg','accuracy','evade','crit','anticrit'
        --newid = self.smaster[eid][1]..'-'..(self.smaster[eid][2][1] or 0)..'-'..(self.smaster[eid][2][2] or 0)..'-'..(self.smaster[eid][2][3] or 0)..'-'..(tonumber(self.smaster[eid][5]) or  0)..'-'..(att['hp'] or 0)..'-'..(att['dmg'] or 0)..'-'..(att['accuracy'] or 0)..'-'..(att['evade'])..'-'..(att['crit'] or 0)..'-'..(att['anticrit'] or 0)
        local master = {
            mirror[1],-- 大师id
            {(mirror[2] or 0),(mirror[3] or 0),(mirror[4] or 0)},--三个位置上的装备
            {---------------------------------当前洗练属性
                hp=tonumber(mirror[6]) or 0,
                dmg=tonumber(mirror[7]) or 0,
                accuracy=tonumber(mirror[8]) or 0,
                evade=tonumber(mirror[9]) or 0,
                crit=tonumber(mirror[10]) or 0,
                anticrit=tonumber(mirror[11]) or 0,
            },
            {0,{}},-------------------------当天各个洗练的次数
            tonumber(mirror[5]) or 0,------历史最高洗练强度
            {}-----保存洗练的次数 还原用的
        }

        return master   
    end

    -- 计算装备大师强度用的
    function self.getev(mid)
        local attType = {'hp','dmg','accuracy','evade','crit','anticrit'}
        local colornum = {}
        local att = {}
        
        if type(self.smaster[mid])~='table' then return 1 end
        for k,v in pairs(self.smaster[mid][2]) do
            if v~=0 and v~='0' then
                local scfg = getConfig("superEquipListCfg.equipListCfg."..v)
                if type(scfg)=='table' then
                    colornum['c'..scfg.color] = (colornum['c'..scfg.color] or 0) + 1
                end
            end
        end

         -- 三个位置装配的额外加成
        if next(colornum) then
            local colorUp = getConfig('sequipMaster.colorUp')
            for k,v in pairs(colorUp) do
                local cid = 'c'..v.colorNeed
                if colornum[cid] and colornum[cid]>=v.numNeed then
                    for ak,val in pairs(v.attUp) do
                        if table.contains(attType,ak) then
                            att[ak] = (att[ak] or 0) + val
                        end
                    end
                end
            end
        end

        --local a = {hp=1.62,dmg=1.62,accuracy=1.32,evade=1.32,crit=1.62,anticrit=1.62}

        if next(self.smaster[mid][3]) then
            for k,v in pairs(self.smaster[mid][3]) do
                att[k] = (att[k] or 0) + v
            end
        end

        local r = 1
        if next(att) then
            for k,v in pairs(att) do
                r = r * (v/4+1)
            end
        end

        return r

    end

    -- 获取强度最高的装备大师
    function self.getStrongMaster()
        local mid = nil
        local fqd = 0
        local placeGet = getConfig('sequipMaster.main.placeGet')
        --（（（原暗强度/10000）-1）*继承比例+1），连乘
        for k,v in pairs(self.smaster) do
            local ecfg = getConfig("superEquipListCfg.equipListCfg."..v[1])
         
            local anqiangdu = ((ecfg.anqiangdu/10000)-1)+1
            anqiangdu = anqiangdu * self.getev(k)
            for s,sv in pairs(v[2]) do
                if sv ~= 0 then
                    local secfg = getConfig("superEquipListCfg.equipListCfg."..sv)
                    local sq = ((secfg.anqiangdu/10000)-1)*placeGet[s]+1             
                    anqiangdu = anqiangdu * sq
                end
            end
            anqiangdu = anqiangdu * 10000
            if not mid or fqd < anqiangdu then
               mid = k
               fqd = anqiangdu
            end
        end

        return mid,fqd
    end

    -- 装配在装备大师上某个超级装备的数量
    function self.settedEquipNum(eid)
        local num = 0
        if type(self.smaster)~='table' or not next(self.smaster) then return num end
        for k,v in pairs(self.smaster) do
            for s,sv in pairs(v[2]) do
                if sv == eid then
                    num = num + 1
                end
            end
        end

        return num
    end

    -- 装备大师在战报中或者邮件战报里的格式
    function self.formEquip(eid)
        if not eid then return 0 end

        local newid = eid
        if eid and string.sub(eid,1,1) == 'm' then
            if type(self.smaster[eid])~='table' then return 0 end
            --local att = self.getMasterAtt(eid)
            -- 该格式是固定的  装备大师配置id  位置1装备 位置2装备 位置3装备 'hp','dmg','accuracy','evade','crit','anticrit'
            --newid = self.smaster[eid][1]..'-'..(self.smaster[eid][2][1] or 0)..'-'..(self.smaster[eid][2][2] or 0)..'-'..(self.smaster[eid][2][3] or 0)..'-'..(tonumber(self.smaster[eid][5]) or  0)..'-'..(att['hp'] or 0)..'-'..(att['dmg'] or 0)..'-'..(att['accuracy'] or 0)..'-'..(att['evade'])..'-'..(att['crit'] or 0)..'-'..(att['anticrit'] or 0)
            newid = self.smaster[eid][1]..'-'..(self.smaster[eid][2][1] or 0)..'-'..(self.smaster[eid][2][2] or 0)..'-'..(self.smaster[eid][2][3] or 0)..'-'..(tonumber(self.smaster[eid][5]) or  0)..'-'..(self.smaster[eid][3]['hp'] or 0)..'-'..(self.smaster[eid][3]['dmg'] or 0)..'-'..(self.smaster[eid][3]['accuracy'] or 0)..'-'..(self.smaster[eid][3]['evade'] or 0)..'-'..(self.smaster[eid][3]['crit'] or 0)..'-'..(self.smaster[eid][3]['anticrit'] or 0)..'-'..eid
        end

        return newid
    end

    -- 计算某个装备大师的强度
    function self.masterStrength(mid)
        local qd = 0
        local placeGet = getConfig('sequipMaster.main.placeGet')

        --（（（原暗强度/10000）-1）*继承比例+1），连乘
        local ecfg = getConfig("superEquipListCfg.equipListCfg."..self.smaster[mid][1])
        local qd = ((ecfg.anqiangdu/10000)-1)+1
        for s,sv in pairs(self.smaster[mid][2]) do
            if sv ~= 0 then
                local secfg = getConfig("superEquipListCfg.equipListCfg."..sv)
                local sq = ((secfg.anqiangdu/10000)-1)*placeGet[s]+1             
                qd = qd * sq
            end
        end
        qd = qd * 10000

        return math.ceil(qd)
    end

    -- 装备大师是否派出了
    function self.checkmasterout(mid)
        if type(self.stats.a) == 'table' then
            for k, v in pairs(self.stats.a) do
                if v == mid then
                    return true
                end
            end
        end

        return false
    end

    -- 检测是不是装备大师镜像id
    function self.checkmirror(id)
        local flag = false
        local midkey = tostring(id):split('-')
        if #midkey>2 then
            flag = true
            return flag,midkey
        end

        return flag,id
    end

    -- 跨服战装备判断 start
    -- 检测当前部队携带的超级装备是否在其他部队中
    function self.checkkuafu1(bequip,line,eid)
        local ret = 0
        for k,v in pairs(bequip) do
            if v~=0 and v~='0' and k~=line then
                local flag,id=self.checkmirror(v)
                if flag then
                    for i=2,4 do
                        if id[i] and id[i]~=0 and id[i]~='0' then
                            if id[i] == eid then
                                ret = 1
                                return ret
                            end
                        end
                    end
                    -- 大师就在这里面检索
                    if type(self.smaster[id[12]])~='table' then
                        ret = -1
                        return ret
                    end
                 
                    if eid == id[12] then
                        ret = 1
                        return ret
                    end
                else
                    if v == eid then
                        ret = 1
                        return ret
                    end
                end
            end
        end

        return ret
    end

    -- 镜像部队带出的超级装备 不能超出可使用数量
    -- equip 派出的超级装备 {e1=1,e2=1,e3=1}
    function self.checkkuafu(bequip,line,eid)
        if type(bequip)~='table' or not next(bequip) then return true end
        if self.checkkuafu1(bequip,line,eid)==0 then
            return true
        end

        local s = {} -- 装配在部队大师上的超级装备数量
        local single = {} -- 单纯装在部队上的超级装备
        local m = {} -- 装备大师的数量
        local a = {} -- 已派出的
        if type(self.stats.a) == 'table' then
            a = self.stats.a
        end 

        local oriequip = copyTable(self.sequip)
        if type(bequip)=='table'  and next(bequip) then
            for k,v in pairs(bequip) do
               if v~=0 and v~='0' then
                    local flag,id=self.checkmirror(v)
                    if flag then
                        for i=2,4 do
                            if id[i] and id[i]~=0 and id[i]~='0' then
                                s[id[i]] = (s[id[i]] or 0) + 1
                            end
                        end
                        -- 大师就在这里面检索
                        if type(self.smaster[id[12]])~='table' then
                            return false
                        end
                        -- 已经派出的
                        if table.contains(a,id[12]) then
                            return false
                        end
                        if m[id[12]] then -- 相同的装备大师被派出在多个部队中 是不允许的
                            return false
                        end
                        m[id[12]] = 1
                    else
                        single[v] = (single[v] or 0) + 1-- 直接配置了超级装备
                    end
               end
            end
        end 
        -- ptb:p(equip)
        -- ptb:p('派出的')
        -- ptb:p(self.stats.a)

        -- 扣除派出的超级装备
        if type(self.stats.a) == 'table' then
            for k, v in pairs(self.stats.a) do
                if oriequip[v] then
                    oriequip[v][1] = oriequip[v][1] - 1
                end
            end
        end

        -- 在原大师中把部队中的大师剔除 并统计出剔除后 装配的装备总数
        local smaster = copyTable(self.smaster)
        if next(m) then
            for k,v in pairs(m) do
                smaster[k] = nil
            end    
        end

        local setteds = self.allsetsequip(smaster)
        -- 把剔除的镜像大师上面的装备 和单独的带的装备给补回来
        if next(s) then
            for k,v in pairs(s) do
                setteds[k] = (setteds[k] or 0) + v
            end
        end

        if next(single) then
            for k,v in pairs(single) do
                setteds[k] = (setteds[k] or 0) + v
            end
        end   

        -- ptb:p(setteds)
        for k,v in pairs(setteds) do
            if oriequip[k] then 
                -- 数量超出了玩家拥有的
                if oriequip[k][1]<v then 
                    --ptb:p('k='..k..'v='..v)
                    return false 
                end
            else
                --ptb:p('k='..k)
                return false
            end
        end

        return true
    end

    -- 跨服战装备判断 end

    -- 装备在大师上所有的超级装备
    function self.allsetsequip(masters)
        local s = {}
        for k,v in pairs(masters or {}) do
            if type(v)=='table' then
                for sk,sv in pairs(v[2]) do
                    if sv~=0 and sv~='0' then
                        s[sv] = (s[sv] or 0) +1
                    end
                end
            end
        end

        return s
    end 

    -- 获取成就数据
    -- ntype：1.数量(不同种类) 2.等级(不同种类)
    function self.getAchievementData(ntype,data)
        local num = 0
        local equipcfg = getConfig("superEquipListCfg.equipListCfg")
        for k,v in pairs(self.sequip) do
            if equipcfg[k] then
                local isAdd = true
                if data.color then
                    if equipcfg[k].color and equipcfg[k].color >= data.color then
                    else
                        isAdd = false
                    end
                end
                if data.level then
                    if equipcfg[k].lv and equipcfg[k].lv >= data.level then
                    else
                        isAdd = false
                    end
                end
                if isAdd then
                    num = num + 1
                end
            end 
        end
        return num
    end


    return self
end
