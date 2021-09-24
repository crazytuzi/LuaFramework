-- 飞机系统
function model_plane(uid,data)
    local self = {
        uid = uid,
        level = 0,-- 飞机建筑等级
        sinfo={},
        info={},
        plane={},
        stats={},
        updated_at = 0,
    }

    local privates = {
        _options = {}
    }
    
    local function itemId4Kfk(sid)
        return "plane_" .. tostring(sid) 
    end

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

    function self.setBringPlaneId(pid)
        privates._options["bringPlaneId"] = pid or "not"
    end

    function self.getBringPlaneId(check)
        if check then
            if privates._options["bringPlaneId"] ~= "not" then
                return privates._options["bringPlaneId"]
            end
        else
            return privates._options["bringPlaneId"]
        end
    end

    -- 飞机技能获取
    function self.addPlaneSkill(sid, num)
        num = tonumber(num) or 1
        local cfg = getConfig("planeGrowCfg.grow."..sid)
        if type (cfg) ~= 'table' then return false  end 

        -- if self.count() > 150 then return false end
        local nums = 0
        if not self.sinfo[sid] then
            self.sinfo[sid] = num
        else
            nums = tonumber(self.sinfo[sid])
            self.sinfo[sid] = tonumber(self.sinfo[sid]) + tonumber(num)
        end
        --平稳降落
        local lv = cfg.lv or 0
        local cfg2 = getConfig("planeCfg.skillCfg."..sid)
        local skillType = cfg2.skillType 
        if lv==0 and (skillType==3 or skillType==4) then
            activity_setopt(self.uid,'safeend',{act='m4',num=num})
        end

        -- 战机商店
        activity_setopt(self.uid,'zjsd',{type="add",id=tonumber(cfg.color),num=num})
        
        regKfkLogs(self.uid,'item',{
                item_id=itemId4Kfk(sid),
                item_op_cnt=num,
                item_before_op_cnt= nums,
                item_after_op_cnt= self.sinfo[sid] or 0,
                item_pos='飞机技能增加',
                flags={'item_id'},
                merge={'item_op_cnt'},
                rewrite={'item_after_op_cnt'},
                addition={
                },
            }
        )

        return true
    end
    --  -- 装置技能刷新，分解装备后技能会消失
    -- function self.refreshSkill( )
    --     local cfg = getConfig("superEquipListCfg.equipListCfg")
    --     local skillcfg = getConfig("superEquipListCfg.skillCfg")
    --     local gemsid = 's305'
    --     local gemsflag = false

    --     --将所有装置技能刷新
    --     local ret = {}
    --     for sid, v in pairs( self.plane ) do
    --         if cfg[sid].etype == 2  then
    --             local sid, lvl = cfg[sid].skill[1], cfg[sid].skill[2]
    --             local value = skillcfg[sid]['value' .. lvl][1]

    --             local typsid = "s" .. skillcfg[sid].stype -- stype 才是技能唯一标识
    --             if not ret[typsid]  then
    --                 ret[typsid] = value 
    --             elseif ret[typsid] < value then
    --                 ret[typsid] = value 
    --             end

    --             if typsid == gemsid then
    --                 gemsflag = true
    --             end
    --         end
    --     end

    --     if not gemsflag and self.info.gems then -- 产钻石技能 需要额外处理
    --         self.info.gems = nil
    --     end
    --     self.info.s = ret
    -- end

    -- 检测技能 专属技能，是否匹配飞机；非专属技能返回true
    function self.checkExSkill(sid,line)
        if not self.plane[line] or not self.plane[line][1] then
            return false,-102
        end
        local cfg=getConfig('planeGrowCfg.grow.'..sid)
        if not cfg then
            return false,-102
        end
        local exSkill=cfg.exSkill
        local planeId=self.plane[line][1]
        if exSkill and exSkill~=planeId then
            return false,-12105
        end
        return true,0
    end

    -- 检测飞机是否装配有同一类型的技能；pos 要装的位置不需检测(替换技能时)
    function self.checkSkillGroup(sid,line,pos)
        if not self.plane[line] or not self.plane[line][1] then
            return false,-102
        end
        local growCfg=getConfig('planeGrowCfg.grow')
        local skillCfg=getConfig('planeCfg.skillCfg.'..sid)
        if not growCfg[sid] or not skillCfg then
            return false,-102
        end
        local cfg=growCfg[sid]
        local skillGroup=cfg.skillGroup
        local stype
        local skillType=skillCfg.skillType
        if skillType<3 then
            stype=2
        else
            stype=1
        end
        local sIdx=stype+1
        if self.plane[line][sIdx] then
            local skill=self.plane[line][sIdx]
            for sk,sv in pairs(skill) do
                if sk~=pos and sv and sv~=0 and growCfg[sv] then
                    local sGroup=growCfg[sv].skillGroup
                    if skillGroup and sGroup and skillGroup==sGroup then
                        return false,-12104
                    end
                end
            end
        end
        return true,0
    end

    --[[
        飞机技能槽是否已解锁

        param int line 第几个解锁的飞机
        param int sIdx 2是主动技能,3是被动技能
        param int pos 放置的位置
        return bool
    ]]
    function self.skillPosIsUnlock(line,sIdx,pos)
        if line and pos and self.plane[line] and self.plane[line][1] then
            local planeCfg = getConfig("planeCfg")
            if planeCfg.plane[self.plane[line][1]] then
                local cfgId 
                if sIdx == 2 and pos == 1 then
                    cfgId = 1
                elseif sIdx == 3 then
                    cfgId = pos + 1
                end

                if planeCfg.plane[self.plane[line][1]].unlockLevel[cfgId] then
                    return self.level >= planeCfg.plane[self.plane[line][1]].unlockLevel[cfgId]
                end
            end
        end
    end

    function self.checkCanUse(sid,line,pos)
        if sid and line and pos then
            local usableNum=self.getUsableNum(sid)
            if usableNum and usableNum>0 then
                local ret,code=self.checkExSkill(sid,line)
                if ret==false then
                    return ret,code
                end
                ret,code=self.checkSkillGroup(sid,line,pos)
                if ret==false then
                    return ret,code
                end
                return true,0
            else
                return false,-12103
            end
        end
        return false,-102
    end

    -- 技能一键分解
    function self.resolveAll( clist )
        local retaward = {}
        local retcnt=0
        local growCfg=getConfig('planeGrowCfg.grow')
        for sid, v in pairs( self.sinfo ) do
            local color = growCfg[sid].color
            if table.contains(clist, color) then
                local cnt = self.getUsableNum(sid)
                if cnt > 0 then
                    retcnt=retcnt+cnt
                    local ret, code = self.resolveSkill(sid, cnt)
                    if not ret then
                        return false, code
                    end
                    for m, n in pairs( code ) do
                        retaward[m] = (retaward[m] or 0) + n
                    end
                end
            end
        end
        return true, retaward,retcnt
    end

    -- 随机获取 color阶技能 actskill合成时消耗的技能是否都是主动技能 决定随机池子
    function self.addRandSkill(color, num,actskill)
        num = tonumber(num) or 1
        local cfg = getConfig('planeGetCfg.upgrade')
        
        if not cfg.pool[color] then
            return false
        end
        --color 品质,1.白 2.绿 3.蓝 4.紫 5.橙
        local retaward = {}
        for i=1, num do
            local result = {}
            if actskill then
                result = getRewardByPool( cfg.pool2[color] )
            else
                result = getRewardByPool( cfg.pool[color] )
            end
           
            if not takeReward(self.uid, result) then
                return false
            end

            for k, v in pairs( result ) do
                retaward[k] = (retaward[k] or 0 ) + v
            end
        end
        --平稳降落
        --获得蓝色技能
        if color==3 then
            activity_setopt(self.uid,'safeend',{act='m2',num=num})
        end
        --获得紫色技能
        if color==4 then
            activity_setopt(self.uid,'safeend',{act='m3',num=num})
        end

        return true, retaward
    end

    -- 技能分解
    function self.resolveSkill(sid, num)
        num = tonumber(num) or 1
        if not self.consumeSkill(sid, num) then
            return false, -12103
        end

        local cfg = getConfig('planeGrowCfg.grow.' .. sid)
        if not cfg then
            return false, -102
        end
        local items = copyTab(cfg.deCompose)
        local ret = {}
        local uobjs = getUserObjs(self.uid)
        local mBag = uobjs.getModel('bag')
        for k, v in pairs( items ) do
            ret[k] = (ret[k] or 0) + v*num
            if not mBag.add(k, v*num) then
                return false, -403
            end
        end
        --飞机技能捕获计划
        activity_setopt(self.uid,'fjjnbhjh',{act='dec',color=cfg.color,num=1})

        -- 战机补给点 
        activity_setopt(self.uid,'zjbjd',{type='fj',color=cfg.color,num=num})

        return true, ret
    end

    -- 装备消耗
    function self.consumeSkill(sid, num)
        if not tonumber(num) or not self.sinfo[sid] then
            return false
        end

        local nums = self.sinfo[sid]
        num = math.floor(math.abs(num))
        if self.getUsableNum(sid) < num then
            return false
        end
        self.sinfo[sid] = tonumber(self.sinfo[sid]) - num
        if self.sinfo[sid] == 0 then
            self.sinfo[sid] = nil
        end

        regKfkLogs(self.uid,'item',{
                item_id=itemId4Kfk(sid),
                item_op_cnt=-num,
                item_before_op_cnt= nums,
                item_after_op_cnt= self.sinfo[sid] or 0,
                item_pos='技能消耗',
                flags={'item_id'},
                merge={'item_op_cnt'},
                rewrite={'item_after_op_cnt'},
                addition={
                },
            }
        )

        return true
    end


    -- 设置状态 id
    function self.addEquipFleet(attack, id, sid)
        -- writeLog({'addEquipFleet -->', attack, id, sid}, 'plane')
        if not sid or not self.checkFleetEquipStats(sid) then return false end

        -- 装备才能带出去
        local cfg = getConfig("superEquipListCfg.equipListCfg." .. sid)
        if not cfg or cfg.etype ~= 1 then return false end

        self.stats[attack] = self.stats[attack] or {}
        self.stats[attack][id] = sid
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
    function self.checkFleetEquipStats(sid, extList)
        if type(self.plane[sid]) ~= 'table' then 
            return false
        end

        local num = self.plane[sid][1]
        if type(self.stats.a) == 'table' then
            for k, v in pairs(self.stats.a) do
                if v == sid then
                    num = num - 1
                end
            end
        end

        --有额外的装备需要扣掉
        if extList and type(extList) == 'table' then
            for k, v in pairs( extList ) do
                if k == sid then
                    num = num - tonumber(v)
                end
            end
        end

        return num > 0
    end

     -- 释放 出战飞机
    function self.releaseEquip(attack,id)
        if type (self.stats[attack])=='table' then 
            if self.stats[attack][id] then 
                self.stats[attack][id]=nil
            end

            --战败而归 加个推送
            if attack == 'a' then
                regSendMsg(self.uid,'msg.plane', {plane = {stats = self.stats } })
            end
        end
    end

    -- 装备升级
    function self.levelupEquip(sid, num)
        return self.addPlaneSkill(sid, num)
    end
    --更换飞机中的技能
    function self.changePlaneSkill(osid,nsid,pid)
        if type(self.plane[pid]) ~= 'table' then 
            return false
        end
        
        -- 主动技能
        for ak,av in pairs (self.plane[pid][2]) do
            if av==osid then
                self.plane[pid][2][ak]=nsid
                return true
            end
        end
            -- 被动技能
        for ak,av in pairs (self.plane[pid][3]) do
            if av==osid then
                self.plane[pid][3][ak]=nsid
                return true
            end
        end
      

        return false
    end

    -- 获取装备数量(排除参战)
    function self.getUsableNum(eid,pid)
        local n = 0 
        if pid and self.plane[pid] then
                -- 主动技能
            for ak,av in pairs (self.plane[pid][2]) do
                if av==eid then
                    n=1
                    return n
                end
            end
                -- 被动技能
            for ak,av in pairs (self.plane[pid][3]) do
                if av==eid then
                    n=1
                    return n
                end
            end
            return n
        end
       
        if self.sinfo[eid] then
            n = self.sinfo[eid]
        end
        return n
    end
    -- 算一个飞机的强度值  
    function self.getPlanePoint(pid)
        local point=0
        if self.plane[pid] then
            local planeCfg=getConfig('planeCfg.plane')
            local planeGrowCfg=getConfig('planeGrowCfg.grow')
            local planeid=self.plane[pid][1]
            local planelevel = self.getPlaneLevel()
            local strength = 0
            if planelevel>0 then
                strength = planeCfg[planeid]['strength'][planelevel]
            end
            point=point+strength
            
            --主动
            for k,v in pairs (self.plane[pid][2]) do
                if planeGrowCfg[v] then
                    point=point+planeGrowCfg[v].skillStrength
                end
            end
            --被动
            for k,v in pairs (self.plane[pid][3]) do
                if planeGrowCfg[v] then
                    point=point+planeGrowCfg[v].skillStrength
                end
            end

        end
        return point
    end

    -- 获取最强飞机解锁的id
    function self.getMaxPlanePoint()
        local pid=0
        local point=0
        for k,v in pairs(self.plane) do
            local newpoint=self.getPlanePoint(k)
            if newpoint>point then
                point=newpoint
            end
        end
        return point
    end
    -- 获取打仗技能
    function self.getSkillAttrs(pid)
        local planeId=nil
        local skill=nil
        if self.plane[pid] then
            local planeGrowCfg=getConfig('planeGrowCfg.grow')
            planeId=self.plane[pid][1]
            skill={}
            for k,v in pairs (self.plane[pid][2]) do
                if planeGrowCfg[v] then
                    table.insert(skill,v)
                end
            end
            --被动
            for k,v in pairs (self.plane[pid][3]) do
                if planeGrowCfg[v] then
                    table.insert(skill,v)
                end
            end

        end
        return planeId,skill

    end

    --释放飞机
    function self.checkAttackStats()
        local ret=false
        if type(self.stats.a) == "table" and next(self.stats.a) then
            local uobjs = getUserObjs(self.uid)
            local mTroop = uobjs.getModel('troops')
            for k in pairs(self.stats.a) do
                if string.find(k, "c") == 1 then
                    if not mTroop.getFleetByCron(k) then
                        self.releaseEquip('a',k)
                        ret=true
                    end
                end
            end
        end

        return ret
    end

    --检测飞机是否能带出去
    function self.checkFleetPlaneStats(pid,list)
       
        if type(self.stats.a) == 'table' then
            for k, v in pairs(self.stats.a) do
                if v == pid then
                    return false
                end
            end
        end
        --远征检测已经挂了的飞机
        if type(list)=="table" and next(list) then
            if table.contains(list, pid) then
                return false
            end
        end

        return true
    end

    -- 设置状态 id
    function self.addPlaneFleet(attack, id, pid)
        if not pid or not self.checkFleetPlaneStats(pid)  then return false end
        self.stats[attack] = self.stats[attack] or {}
        self.stats[attack][id] = pid
        return true
    end

    --获取出战的飞机 id
    function self.getPlaneFleet(attack, id)
        if type(self.stats[attack]) == 'table' then
            if attack == 'd' and not self.checkFleetPlaneStats( self.stats[attack][id] ) then
                return 0
            end
            return self.stats[attack][id] or 0
        end

        return 0
    end

        -- 多个超级装备能带出
    -- 防止镜像带出多个，检测列表； 镜像派出去不影响已经设置的装备 需要检测的eid
    function self.checkPlaneStats(list, check_pid,line)
        if type(list) ~= 'table' then return false end

        local list = {}
        for k, eid in pairs(list) do
            if eid ~=0  and  k~=line then --默认值忽略
                if eid==check_pid then
                    return false
                end
            end
        end
        return true
    end

        -- 释放 出战飞
    function self.releasePlane(attack,id)
        if type (self.stats[attack])=='table' then 
            if self.stats[attack][id] then 
                self.stats[attack][id]=nil
            end

            --战败而归 加个推送
            if attack == 'a' then
                regSendMsg(self.uid,'msg.plane', {plane = {stats = self.stats } })
            end
        end
    end

    -- 算最大战斗力
    function self.getMaxBattlePlane(pid)
        local point=0
        if pid==nil then
            point=self.getMaxPlanePoint()
        else
            point=self.getPlanePoint(pid)
        end
        
        return point
    end   

    -- 分别算飞机的和技能的强度值
    function self.getPlaneAttr()
        local ppoint=0
        local spoint=0
        if self.plane[pid] then
            local planeCfg=getConfig('planeCfg.plane')
            local planeGrowCfg=getConfig('planeGrowCfg.grow')
            local planeid=self.plane[pid][1]
            local planelevel = self.getPlaneLevel()
            local strength = 0
            if planelevel>0 then
                strength = planeCfg[planeid]['strength'][planelevel]
            end
            ppoint=ppoint+strength
            --主动
            for k,v in pairs (self.plane[pid][2]) do
                if planeGrowCfg[v] then
                    spoint=spoint+planeGrowCfg[v].skillStrength
                end
            end
            --被动
            for k,v in pairs (self.plane[pid][3]) do
                if planeGrowCfg[v] then
                    spoint=spoint+planeGrowCfg[v].skillStrength
                end
            end

        end
        return ppoint,spoint
    end

    -- 已经解锁的飞机
    function self.unlockplane()
        if type(self.plane)~='table' then
            self.plane = {}
        end

        local unlock = {}
        for k,v in pairs(self.plane) do
            if v and v[1] then
                table.insert(unlock,v[1])
            end
        end

        return unlock
    end

    -- 建筑升级 解锁飞机
    -- 建筑等级level
    function self.setunlock(level)
        local planeCfg = getConfig('planeCfg')
        local unlock = self.unlockplane()

        for i=1,#planeCfg.openLevel do
            local pid = 'p'..i
            if level>=planeCfg.openLevel[i] and not table.contains(unlock,pid)  then
               table.insert(self.plane,{pid,{},{}})
            end
        end
    end

    -- 更新分级建筑等级
    function self.setLevel(level)
        self.level = level
        self.setunlock(level)
    end

    -- 获取飞机建筑等级
    function self.getPlaneLevel()
        return self.level
    end
    

    return self
end