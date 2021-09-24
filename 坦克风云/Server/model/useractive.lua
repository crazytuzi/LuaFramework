function model_useractive(uid,data)
    -- the new instance
    local self = {
        uid= uid,
        info = {},
        updated_at=0,
    }

    local aftersave = {}
    -- userobjs 保存后 处理数据
    function self.saveAfter() 
        -- 更新跨服表数据
        if type(aftersave.gerrecall)=='table' and next(aftersave.gerrecall) then
            local respbody = gerrecallrequest(aftersave.gerrecall,3)
            respbody = json.decode(respbody)
         
            if respbody.ret ~= 0 then
                writeLog(json.encode(aftersave.gerrecall),'gerrecall_errorlog')
            end
        end

        if type(aftersave.morale)=='table' and next(aftersave.morale) then
            local bid = aftersave.morale.bid 
            local morale = aftersave.morale.morale 
            mOceanMatch = getModelObjs("oceanmatches",bid)
            if mOceanMatch then
                local ret, code = mOceanMatch.addMorale(morale)
                if not ret  then
                    writeLog(json.encode(aftersave.morale),'morale_errorlog')
                else
                    writeLog(json.encode(aftersave.morale),'morale_oklog')
                end

                mOceanMatch.save()
            end
        end

        aftersave = {}
    end

    -- private fields are implemented using locals
    -- they are faster than table access, and are truly private, so the code that uses your class can't get them
    -- local test = uid

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

        self.init()

        return true
    end

    function self.toArray(format)
        local data = {}
        if format then
            data = copyTable(self.info)
            local ts = getClientTs()

            for k,v in pairs(data) do
                if v.global then
                    self.solveData(k,v)
                end
                -- 10 是后台任务，前台不展示
                if tonumber(v.type) == 10 or v.et <= ts then
                    data[k] = nil

                    -- 20 是无论是否完成，都直接返给前台展示
                elseif v.c and v.c <0 and tonumber(v.type) ~= 20 and k ~= 'fbReward' then
                    data[k] = nil

                else
                    v.st = nil
                    v.et = nil
                end
                
                -- 国庆活动不返回服务器转盘对象
                if k == 'nationalDay' and type(data[k]) == 'table' then
                    data[k].spool = nil
                end
                -- 德国月卡 如果玩家开启领奖时间到当前时间大于设定领奖天数 就不传了
                if k == 'germancard' then
                    local germancard=activity_setopt(self.uid,'germancard',{num=0})
                    if not germancard then
                        data[k] = nil
                    end
                end
            end

            return data
        end

        for k,v in pairs (self) do
            if type(v)~="function" and k~= 'uid' and k~= 'updated_at' then
                data[k] = v
            end
        end

        return data
    end

    function self.getKeys()
        local data = {}
        for k,v in pairs (self) do
            if type(v)~="function" then
                table.insert(data,k)
            end
        end
        return data
    end

    ----------------------------------------------------------------

    -- 过期的活动数据，保存15天
    -- 15天内此活动重新开启的时候清掉数据

    -----------------------------------------------------------------

    function self.init()
        self.clearExpireActives()

        require 'model.active'
        local mActive = model_active()
        local actives = mActive.toArray(true)
        local activeCfg = getConfig("active")
        local ts = getClientTs()

        local uobjs = getUserObjs(self.uid)
        local mUserinfo = uobjs.getModel('userinfo')
        local checkFirstTime = 2015
        local nowYear = getDateByTimeZone(nil, '%Y')
        nowYear = tonumber(nowYear)
        --获取当前年份和2015年比较
        if mUserinfo.buygems > 0 and not self.info['firstRecharge'] and nowYear < checkFirstTime then
            actives.firstRecharge = nil
        end

        if type(actives) == 'table' then
            for k,v in pairs(actives) do
                activeCfg[k] = activeCfg[k] or getConfig("active/"..k)
                if activeCfg[k] then

                    if type(self.info[k]) ~= 'table' then
                        self.info[k] = {t=0,v=0,c=0}
                        if activeCfg[k].conditiongems and self.info[k].v==0 then
                            self.info[k].v = activeCfg[k].conditiongems
                        end

                        if activeCfg[k].multiSelectType then
                            if activeCfg[k][tonumber(v.cfg)].conditiongems and self.info[k].v==0 then
                                self.info[k].v = activeCfg[k][tonumber(v.cfg)].conditiongems
                            end
                        end
                    else
                        if self.info[k].st ~= tonumber(v.st) and self.info[k].et ~= tonumber(v.et) then
                            self.info[k] = {t=0,v=0,c=0}
                            if activeCfg[k].conditiongems and self.info[k].v==0 then
                                self.info[k].v = activeCfg[k].conditiongems
                            end
                            if activeCfg[k].multiSelectType then
                                if activeCfg[k][tonumber(v.cfg)].conditiongems and self.info[k].v==0 then
                                    self.info[k].v = activeCfg[k][tonumber(v.cfg)].conditiongems
                                end
                            end
                        end
                    end

                    -- 一个活动有多个配置文件 记录选择的配置文件的id
                    if activeCfg[k].multiSelectType then
                        -- 一个活动多个配置文件 配置变动初始化活动数据
                        if self.info[k].cfg and tonumber(self.info[k].cfg) ~= tonumber(v.cfg) then
                            self.info[k] = {t=0,v=0,c=0}
                            if activeCfg[k][tonumber(v.cfg)].conditiongems and self.info[k].v==0 then
                                self.info[k].v = activeCfg[k][tonumber(v.cfg)].conditiongems
                            end
                        end
                        self.info[k].cfg = tonumber(v.cfg)
                    end

                    -- 自定义版本重置数据(日本)
                    if k == 'customLottery' and self.info[k].st ~= tonumber(v.st) then
                        self.info[k] = {t=0,v=0,c=0}
                    end
                    self.info[k].type = tonumber(v.type) or 0
                    self.info[k].st = tonumber(v.st) or 0
                    self.info[k].et = tonumber(v.et) or 0

                    -- 如果配置文件里有完成条件，值置为完成条件
                    if activeCfg[k].condition and self.info[k].v==0 then
                        self.info[k].v = activeCfg[k].condition
                    end
                    if activeCfg[k].global then
                        self.info[k].global = true
                    end
                    
                    -- 属于绑定活动
                    local bindActive = getConfig('bindActive')
                    if bindActive[k] then
                        self.info[k].bd = 1
                    end
                end
            end

            for k,v in pairs(self.info) do
                local acfg =  activeCfg[k]
                if not actives[k] and v.et > ts then
                    v.et = getClientTs()
                end
                if(k=='baseLeveling' and v.c==0)then
                    --print('fuck')
                    local uobjs = getUserObjs(uid,true)
                    local mBuildings = uobjs.getModel('buildings',true)
                    local level=mBuildings.getLevel('b1')
                    --print(level)
                    self.info[k].c=level
                end
                if(k=='bindbaseLeveling' and v.c==0)then
                    --print('fuck')
                    local uobjs = getUserObjs(uid,true)
                    local mBuildings = uobjs.getModel('buildings',true)
                    local level=mBuildings.getLevel('b1')
                    --print(level)
                    self.info[k].c=level
                elseif k=='bindbaseLeveling' and not self.info[k].rp then
                    local mBuildings = uobjs.getModel('buildings',true)
                    local level=mBuildings.getLevel('b1')
                    --print(level)
                    self.info[k].c = level
                    self.info[k].rp = 1
                end
                if(k=='personalCheckPoint' and v.c==0)then
                    --print('fuck')
                    local uobjs = getUserObjs(uid,true)
                    local challenge = uobjs.getModel('challenge',true)
                    local star=challenge.star
                    --print(level)
                    self.info[k].t=star
                    if self.info[k].re == nil then
                        self.info[k].re = 0 
                    end
                    -- ptb:p(star)
                end
                if (k=='fightRank' and not self.info[k].rewardlog) then
                    if self.info[k].cfg==2 then
                        local reward = acfg[self.info[k].cfg].serverreward.allCanGet
                        self.info[k].rewardlog = {}--奖励记录
                        for k,v in pairs(reward) do
                            table.insert(self.info.fightRank.rewardlog,0)
                        end
                    end
                end
                if(k=='personalHonor' and v.c==0)then
                    --print('fuck')
                    local uobjs = getUserObjs(uid,true)
                    local mUserinfo = uobjs.getModel('userinfo',true)
                    local reputation=mUserinfo.reputation
                    --print(level)
                    self.info[k].t=reputation
                end
                if (k=='wanshengjiedazuozhan' and not self.info[k].m) then
                    self.info[k].m = acfg[self.info[k].cfg].serverreward.map
                    self.info[k].l = acfg[self.info[k].cfg].bossLife
                end
                if (k=='hundredactive') then
                    --百服活动全局数据更新
                    local freedata = getFreeData(k)
                    if type(freedata) == 'table' and type(freedata.info) == 'table' and 
                        freedata.info.st == v.st and freedata.info.res ~= v.v then
                        v.v = freedata.info.res
                    end
                end
            end
        end
    end

    -- 过期的活动
    function self.clearExpireActives()
        if type(self.info) == 'table' then
            local ts = getClientTs()
            local expireTs = ts - 1296000

            for k,v in pairs(self.info) do
                local et = tonumber(v.et) or 0
                if et > 0 and et < expireTs then
                    self.info[k] = nil
                end

                -- if et == 0 and v.ft < expireTs then
                --     self.info[k] = nil
                -- end
            end
        end
    end

    -- active set--------------------------------------------------------------------------------------------

    -- 检测活动
    -- atype 活动类型
    -- 1 道具类奖励活动（此类活动奖励需要手动领取）
    -- 2 经验,声望类奖励活动（此类活动，游戏中自动发放）
    -- 3 按当前累积值发放奖励（此类活动，按累积值折算出道具数据，然后手动领取）
    -- 4 首充活动 (首充活动，只有一次，手动领取)
    -- 5 其它杂活动，例：在活动时间段内，攻打野地掉落资源道具几率提高50%，金币军团捐献奖励翻倍，攻打关卡必掉荣誉勋章*2
    -- activeName
    function self.setActive(activeName,params)

        if type(self.info) == 'table' then
            local ts = getClientTs()

            if self.info[activeName] and self.info[activeName].c >= 0 and self.info[activeName].st < ts and self.info[activeName].et > ts then
                local activeCfg = getConfig("active")

                -- 首充活动 ---------------------------------------------
                if activeName == 'firstRecharge' and self.info[activeName].c == 0 then
                    self.info[activeName].c = self.info[activeName].c + params.num
                    if activeCfg[activeName].value~=nil  and  activeCfg[activeName].value>0 then
                        self.info[activeName].c =params.num*activeCfg[activeName].value
                    end
                    -- 德国首冲大于8400，取8400
                    if params.num > 8400 and getClientPlat() == 'ship_ger' then
                        local value = activeCfg[activeName].value or 1
                        self.info[activeName].c = 8400 * value
                    end 
                    local data = {[activeName] = self.info[activeName]}
                    regSendMsg(self.uid,'active.change',data)

                    return true
                end

                -- 打折活动 ----------------------------------------------
                if activeName == 'discount' then
                    if type(self.info[activeName].t) ~= 'table' then
                        self.info[activeName].t = {}
                    end

                    --活动由单份配置改为多份配置 cfg后台选择的配置编号
                    if self.info[activeName].cfg and activeCfg[activeName][self.info[activeName].cfg] then
                        activeCfg[activeName] = activeCfg[activeName][self.info[activeName].cfg]
                    end

                    -- 折扣值
                    local disN = activeCfg[activeName].props[params.pid]

                    -- 购买次数有限制
                    if disN and (self.info[activeName].t[params.pid] or 0) < activeCfg[activeName].maxCount[params.pid] then
                        local disGems = math.ceil(params.gems * disN)
                        if disGems > 0 then
                            self.info[activeName].t[params.pid] = (self.info[activeName].t[params.pid] or 0) + 1
                            return disGems
                        end
                    end

                    return nil
                end

                if activeName == 'fbReward' then
                    return self.fbReward(params.sid)
                end
                if activeName=='fightRank' then

                    return self.fightRank(activeName,params)
                end
                if activeName=='baseLeveling' then
                    return self.baseLeveling(params)
                end

                if activeName == 'luckUp' then
                    return self.luckUp(params.name,params.item,params.value)
                end

                if activeName == 'wheelFortune' or activeName == 'wheelFortune2' then
                    return self.wheelFortune(params.value,activeName)
                end
                --充值返利

                if activeName == 'rechargeRebate' then
                    return self.rechargeRebate(params.num)
                end
                -- 每日充值送奖励
                if activeName == 'dayRecharge' then
                    return self.dayRecharge(params.num)
                end
                -- 每日充值送配将奖励
                if activeName == 'dayRechargeForEquip' then
                    return self.dayRechargeForEquip(params.num)
                end
                --  军团升级活动加统计
                if activeName=='allianceLevel' then
                    return self.setallianceLevelStats('allianceLevel',params)
                end

                --个人关卡榜
                if activeName=='personalCheckPoint' then
                    return self.personalCheckPoint(activeName,params)
                end

                --个人荣誉榜
                if activeName=='personalHonor' then
                    return self.personalHonor(activeName,params)
                end

                --累计充值
                if activeName=='totalRecharge' then
                    return self.totalRecharge(params.num)
                end

                -- 水晶丰收
                if activeName == 'crystalHarvest' then
                    return self.crystalHarvest(params)
                end

                -- 巨兽再现
                if activeName == 'monsterComeback' then
                    return self.monsterComeback(params)
                end

                -- 老战友回归
                if activeName == 'oldUserReturn' then
                    return self.setOldUserReturn(params)
                end

                -- 军团收获日
                if activeName == 'harvestDay' then
                    return self.setHarvestDay(params)
                end

                -- vip特权宝箱活动
                if activeName == 'vipRight' then
                    return self.vipRight(params)
                end

                -- 前线军需活动
                if activeName == 'rechargeDouble' then
                    return self.rechargeDouble(params)
                end


                -- 基金活动
                if activeName == 'userFund' then
                    return self.userFund(params.num)
                end


                --  勤劳致富
                if activeName == 'hardGetRich' then
                    return self.hardGetRich(activeName,params)
                end


                -- 投资计划
                if activeName == 'investPlan' then
                    return self.InvestPlan(params.num)
                end

                --

                -- VIP总动员活动
                if activeName == 'vipAction' then
                    return self.VipAction(params.num)
                end

                --钢铁之心

                if activeName =='heartOfIron'  then
                    return self.heartOfIron(activeName,params)
                end

                --无限火力
                if activeName =='luckcard'  then
                    return self.luckcard(activeName,params)
                end

                if type(self[activeName]) == 'function' then
                    return self[activeName](activeName,params)
                end

                -- return self.activedefaultinfo(activeName,params)

            end
        end
    end

    -- vip狂欢
    function self.vipkh(aname,params)
        if params.num>0 then
            self.info[aname].gems = (self.info[aname].gems or 0) + params.num
        end
    end

    -- 幸运锦鲤
    function self.xyjl(aname,params)
        local activeCfg = self.getActiveConfig(aname)
        local weeTs = getWeeTs()

        if type(self.info[aname].task)~='table' or self.info[aname].t~=weeTs then
            self.info[aname].task = {}
            for k,v in pairs(activeCfg.serverreward.taskList) do
                table.insert(self.info[aname].task,0)
            end
            self.info[aname].td = 0 -- 当天累计充值钻石数
            self.info[aname].t = weeTs
        end

        self.info[aname].td = (self.info[aname].td or 0) + params.num
        self.info[aname].gems = (self.info[aname].gems or 0) + params.num
       
        for k,v in pairs(self.info[aname].task) do
            local tkcfg = activeCfg.serverreward.taskList[k]
            if self.info[aname].task[k]==0 then
                if tkcfg.type=='gb' then
                    if self.info[aname].td >= tkcfg.num then
                        self.info[aname].task[k] = 1
                    end
                elseif tkcfg.type=='gs' then
                    if params.num>=tkcfg.num then
                        self.info[aname].task[k] = 1
                    end
                end
            end
        end

    end

    -- 感恩节拼图
    function self.gejpt(aname,params)
        local activeCfg = self.getActiveConfig(aname)
        local weeTs = getWeeTs()
        
        if self.info[aname].t~=weeTs then
            self.info[aname].tk1 = {}
            for k,v in pairs(activeCfg.serverreward.taskList1) do
              table.insert(self.info[aname].tk1,{0,0,0}) --当前值 可领取次数  已领取次数    
            end

            self.info[aname].tk2 = {}
            for k,v in pairs(activeCfg.serverreward.taskList2) do
              table.insert(self.info[aname].tk2,{0,0,0}) --当前值 可领取次数  已领取次数    
            end

            self.info[aname].t = weeTs
        end
        -- 任务
        if params.act=='tk' then
            for i=1,2 do
                for k,v in pairs(activeCfg.serverreward['taskList'..i]) do
                    if v.type==params.type then
                        local n = 0
                        if params.type=='cj2' then
                            local res = {"r1","r2","r3","r4","gold"}
                            for rk,rv in pairs(params.num or {}) do
                                if table.contains(res,rk) then
                                    n = n + rv
                                end
                            end
                        elseif params.type=='fc' then
                            if params.p and params.p>0 then
                                n = params.num
                            end
                        else
                            n = params.num
                        end
                        if n<=0 then
                            return false
                        end
                        
                        if self.info[aname]['tk'..i][k][3]+self.info[aname]['tk'..i][k][2]<v.limit then
                            self.info[aname]['tk'..i][k][1] = self.info[aname]['tk'..i][k][1] + n
                            local num = math.floor(self.info[aname]['tk'..i][k][1]/v.num)
                            if num>0 then
                                local left = v.limit - self.info[aname]['tk'..i][k][3]- self.info[aname]['tk'..i][k][2]
                                local rn = num
                                if num>=left then
                                    rn = left
                                    self.info[aname]['tk'..i][k][1] = 0
                                else
                                    self.info[aname]['tk'..i][k][1] = self.info[aname]['tk'..i][k][1] - num*v.num
                                end
                                 
                                self.info[aname]['tk'..i][k][2] = self.info[aname]['tk'..i][k][2] + rn
                            end
                        end 
                        break  
                    end
                end
            end
        elseif params.act=='quit' then-- 退出军团
            -- 删除在军团交换记录中的id

        end

        
    end

    -- 节日花朵
    function self.jrhd(aname,params)
        local activeCfg = self.getActiveConfig(aname)
        local ts = getClientTs()
        if ts > tonumber(self.getAcet(aname, true)) then
            return false
        end

        if type(self.info[aname].task)~='table' then
            self.info[aname].task = {}
            for k,v in pairs(activeCfg.serverreward.taskList) do
                self.info[aname].task[k] = {1,0,0}
            end
        end

        -- 个人贡献积分
        if not self.info[aname].pscore then
            self.info[aname].pscore = 0
        end

        -- 任务
        if params.act=='tk' then
            if params.id=="jh" and params.pid~='r1' then return false end -- 采集异星晶尘
            if params.id=="yj" and params.color<3 then return false end -- 蓝色以上品质异星武器进阶
            for k,v in pairs(self.info[aname].task) do
                local tkcfg = activeCfg.serverreward.taskList[k][v[1]]
                if params.id==tkcfg.type then
                    self.info[aname].task[k][2] = self.info[aname].task[k][2] + params.num
                    break
                end
            end

        -- 退出 或者加入军团 涂色进度是否清理
        elseif params.act == 'join' then
            -- 玩家重新加入军团 需要同步当前军团奖励数据 防止玩家不停加军团领取奖励 
            local aAllianceActive = getModelObjs("allianceactive",params.id)
            if aAllianceActive then
                local activeObj = aAllianceActive.getActiveObj(aname)
                self.info[aname].pshare = activeObj.activeInfo.share or 0
            end  
         -- 当玩家退出军团
        elseif params.act=='quit' then
            if self.info[aname].pscore>0 then
                --扣除积分
                local aAllianceActive = getModelObjs("allianceactive",params.id)
                if aAllianceActive then
                    local activeObj = aAllianceActive.getActiveObj(aname)
                    activeObj:subPoint(self.info[aname].pscore)
                end
            end

            self.info[aname].pscore = 0

            return true
        end
    end

 -- 指挥官活动副本
    function self.badgechallenge(aname,params)
        if type(self.info[aname].challenge)~='table' then
            self.info[aname].challenge = {}
            for k,v in pairs(params.schallenge) do
                table.insert(self.info[aname].challenge,0) -- 下标对应关卡id 
            end
        end
    end
    
    -- 战机商店
    function self.zjsd(aname,params)
        local activeCfg = self.getActiveConfig(aname)
        if type(self.info[aname].tk)~='table' then
            self.info[aname].tk = {}
            for k,v in pairs(activeCfg.serverreward.taskList) do
                table.insert(self.info[aname].tk,{0,0})
            end
        end

        -- 根据获得飞机技能的品质 匹配任务类型
        local ztab = {[2]="z1",[3]="z2",[4]="z3",[5]="z4"}
        if params.type == 'add' then
            if ztab[params.id] then
                params.type=ztab[params.id]
            end
        end

        local ptab = {p4203="z5",p4204="z6",p4205="z7",p4206="z8"}
        -- 根据技能精要道具 匹配任务类型
        if params.type == 'jy' then
            if ptab[params.id] then
                params.type = ptab[params.id]
            end
        end

        -- 注 以下循环中不能使用break 因为有相同的任务类型
        for k,v in pairs(activeCfg.serverreward.taskList) do
            if params.type and params.num>0 and params.type == v.type then
                self.info[aname].tk[k][1] = (self.info[aname].tk[k][1] or 0) + params.num
                if self.info[aname].tk[k][1]>v.num then
                    self.info[aname].tk[k][1] = v.num
                end
            end
        end
    end

    -- 战机补给点
    function self.zjbjd(aname,params)
        local activeCfg = self.getActiveConfig(aname)
        if type(self.info[aname].tk)~='table' then
            self.info[aname].tk = {}
            for k,v in pairs(activeCfg.task) do
                table.insert(self.info[aname].tk,{0,0})
            end
        end

        if params.type == "xh" and params.id then
            local tp = {p4201="xh1",p4202="xh2"}
            params.type = tp[params.id]
        end

        -- 1.白 2.绿 3.蓝 4.紫 5.橙
        if params.type == 'fj' then
            if not table.contains({2,3},params.color) then
                return false
            end

            local color = {[2]="fj",[3]="fj1"}
            params.type = color[params.color]
        end

        for k,v in pairs(activeCfg.task) do
            if params.type and params.num>0 and params.type == v.key then
                self.info[aname].tk[k][1] = (self.info[aname].tk[k][1] or 0) + params.num
                if self.info[aname].tk[k][1]>v.needNum then
                    self.info[aname].tk[k][1] = v.needNum
                end
            end
        end
    end

    -- 无限火力2018
    function self.luckcard2018(aname,params)
        local activeCfg = self.getActiveConfig(aname)
        if table.contains(activeCfg.nextRequire,params.aid) then
            return activeCfg.value,activeCfg.nextRequire
        end
    end

     --VIP礼包
    function  self.VIPlb(aname,params)
        if params.num>0 then 
            self.info[aname].gems=(self.info[aname].gems or 0)+ params.num
        end
    end

     --马力全开
    function  self.mlqk(aname,params)
       
        local activeCfg = self.getActiveConfig(aname)
        -- 领取状态
        if type(self.info[aname].task) ~= 'table' then
            self.info[aname].task = {}  
            for key,val in pairs(activeCfg.serverreward.taskList) do
                table.insert(self.info[aname].task,{0,0,0,0})--[已经领取数量,已经完成数量,领取状态,进度]
            end
        end
        -- 任务tabl2
        -- if type(self.info[aname].tkname) ~= 'table' then
        --     self.info[aname].tkname = {}          
        -- end
        if params.act =='tk' then
            for k,v in pairs(activeCfg.taskid) do
                --判断是哪一种任务
                if params.type == v then 

                    --如果不是table则是消费充值和军演任务
                    if type(params.num) ~= 'table' then 
                        self.info[aname].task[k][4]=(self.info[aname].task[k][4] or 0)+ params.num   
                    end
                    --如果是table则是资源任务
                    if type(params.num) == 'table' then 
                        for k1,v1 in pairs(params.num) do
                            self.info[aname].task[k][4]=(self.info[aname].task[k][4] or 0)+ v1
                        end    
                    end
                    if self.info[aname].task[k][4] >0 then
                        --已到达任务数进行记录
                        for key,val in pairs(activeCfg.serverreward.taskList[k]) do
                            if self.info[aname].task[k][4]>= val["num"] then
                                self.info[aname].task[k][2]=key

                                if  self.info[aname].task[k][2] >self.info[aname].task[k][1] then
                                    self.info[aname].task[k][3]=1
                                end
                            end
                        end
                    end

                end
            end
            
        end
    end

    -- 国庆节2018
    function self.nationalday2018(aname,params)
        local activeCfg = self.getActiveConfig(aname)
        local ts = getClientTs()
        if ts > tonumber(self.getAcet(aname, true)) then
            return false
        end

        if type(self.info[aname].tk)~='table' then
            self.info[aname].tk = {}
            for k,v in pairs(activeCfg.serverreward.taskList) do
                self.info[aname].tk['d'..k] = {{},0,0}-- 当天的任务数据  进度奖励领取状态 进度
                for tk,tv in pairs(v) do
                     table.insert(self.info[aname].tk['d'..k][1],{0,0,0}) --当前进度 可领取 已领取
                end
            end
        end
       
        -- 任务
        if params.act == 'tk' then
            local currDay = math.floor(math.abs(ts-getWeeTs(self.info[aname].st))/(24*3600)) + 1
            local taskcfg = activeCfg.serverreward.taskList[currDay]
            if type(taskcfg)=='table' then
                for k,v in pairs(taskcfg) do
                    if v.type==params.type then
                        local n = 0
                        if params.type=='cj2' then
                            local res = {"r1","r2","r3","r4","gold"}
                            for rk,rv in pairs(params.num or {}) do
                                if table.contains(res,rk) then
                                    n = n + rv
                                end
                            end
                        elseif params.type=='fc' then
                            if params.p and params.p>0 then
                                n = params.num
                            end
                        else
                            n = params.num
                        end
                        if n<=0 then
                            return false
                        end
                        
                        if self.info[aname].tk['d'..currDay][1][k][3]+self.info[aname].tk['d'..currDay][1][k][2]<v.limit then
                            self.info[aname].tk['d'..currDay][1][k][1] = self.info[aname].tk['d'..currDay][1][k][1] + n
                            local num = math.floor(self.info[aname].tk['d'..currDay][1][k][1]/v.num)
                            if num>0 then
                                local left = v.limit - self.info[aname].tk['d'..currDay][1][k][3]- self.info[aname].tk['d'..currDay][1][k][2]
                                -- 每种任务做一个 任务进度增加1
                                if left == v.limit then
                                     -- 每天的任务进度
                                    self.info[aname].tk['d'..currDay][3] = self.info[aname].tk['d'..currDay][3] + 1
                                end
                                local rn = num
                                if num>=left then
                                    rn = left
                                    self.info[aname].tk['d'..currDay][1][k][1] = 0
                                else
                                    self.info[aname].tk['d'..currDay][1][k][1] = self.info[aname].tk['d'..currDay][1][k][1] - num*v.num
                                end
                                 
                                self.info[aname].tk['d'..currDay][1][k][2] = self.info[aname].tk['d'..currDay][1][k][2] + rn
                            end
                        end 
                        break  
                    end
                end
            end
        end

         -- 当玩家退出军团 清空祝福值
        if params.act=='quit' then
            if not self.info[aname].nd_a2 then
                self.info[aname].nd_a2 = 0
            end

            if self.info[aname].nd_a2>0 then
                --扣除军团总伤害
                local aAllianceActive = getModelObjs("allianceactive",params.aid)
                if aAllianceActive then
                    local activeObj = aAllianceActive.getActiveObj(aname)
                    activeObj:subPoint(self.info[aname].nd_a2)
                end
            end

            self.info[aname].nd_a2= 0
            return true
        end
    end

    -- 群蜂来袭2018
    function self.qflx2018(aname,params)
        local activeCfg = self.getActiveConfig(aname)
        return activeCfg.unlock or {}
    end

    -- 金秋祈福
    function self.jqqf(aname,params)
        local activeCfg = self.getActiveConfig(aname)
        if type(self.info[aname].ch)~='table' then
            self.info[aname].ch = {}
            for k,v in pairs(activeCfg.serverreward.giftList) do
                table.insert(self.info[aname].ch,{0,0}) -- 可领取 已领取
            end
        end

        if params.num>0 then
            local len = #activeCfg.serverreward.giftList
            local index = 0
            for i=len,1,-1 do
                if params.num >= activeCfg.serverreward.giftList[i].rechargeNum then
                    index = i
                    break
                end
            end

            if index>0 then
                local gcfg = activeCfg.serverreward.giftList[index]
                if type(gcfg)=='table' then
                    if self.info[aname].ch[index][2]<gcfg.limit then
                        local left = gcfg.limit - self.info[aname].ch[index][2]                 
                        if left>self.info[aname].ch[index][1] then
                            self.info[aname].ch[index][1] = self.info[aname].ch[index][1] + 1
                        end
                    end
                end
            end        
        end
    end

    -- 三周年-充值返利
    function self.sznczfl(aname,params)
        local activeCfg = self.getActiveConfig(aname)
        if not self.info[aname].cn then
            self.info[aname].cn = 0
        end

        if not self.info[aname].gems then
            self.info[aname].gems = 0
        end

        if params.num>0 then
            self.info[aname].cn = self.info[aname].cn + 1
            if self.info[aname].cn<=activeCfg.rebateNum then
                self.info[aname].gems = math.ceil(self.info[aname].gems + params.num*activeCfg.rebateRate)
            end
        end  
    end

    -- 三周年-冲破噩梦
    function self.cpem(aname,params)
        local ts = getClientTs()
        local uobjs = getUserObjs(self.uid)
        uobjs.load({"userinfo"})
        local mUserinfo = uobjs.getModel('userinfo')
        local aid = mUserinfo.alliance
        if ts > tonumber(self.getAcet(aname, true)) then
            return false
        end

        local reward = {}
        local weeTs = getWeeTs()
        local ts = getClientTs()
        local activeCfg = self.getActiveConfig(aname)
        local currDay = math.floor(math.abs(ts-getWeeTs(self.info[aname].st))/(24*3600)) + 1
        if type(self.info[aname].tk)~='table' or self.info[aname].t~=weeTs  then
            self.info[aname].tk = {}
            for k,v in pairs(activeCfg.serverreward.taskList) do
                local max = #v.limit
                local limit = currDay > max and v.limit[max] or v.limit[currDay]
                table.insert(self.info[aname].tk,{0,0,limit})-- 当前值 已领取次数 当天限制次数
            end
            self.info[aname].t=weeTs
        end

        -- 当玩家退出军团，玩家的弹药和个人伤害都将被清空
        if params.type=='quit' then
            if not self.info[aname].dm then
                self.info[aname].dm = 0
            end
            for i=1,4 do
                if self.info[aname]["cpem_a"..i] then
                    self.info[aname]["cpem_a"..i] = 0
                end
            end
          
            local redkey = "zid."..getZoneId().."."..aname.."ts"..self.info[aname].st..'aid_'..params.aid
            local redis = getRedis()
            local damlist = json.decode(redis:get(redkey))
            if type(damlist)~='table' or not next(damlist) then
                damlist = {}
            end
       
            local setflag = false
            for k,v in pairs(damlist) do
                if v[1]==self.uid then
                    table.remove(damlist,k)
                    setflag = true
                    break
                end
            end

            if setflag then
                redis:set(redkey,json.encode(damlist))
                redis:expireat(redkey,self.info[aname].et+86400)
            end

            --扣除军团总伤害
            local aAllianceActive = getModelObjs("allianceactive",params.aid)
            if aAllianceActive then
                local activeObj = aAllianceActive.getActiveObj(aname)
                activeObj:subPoint(self.info[aname].dm)
            end
            
            self.info[aname].dm = 0

            return false
        end

        for k,v in pairs(activeCfg.serverreward.taskList) do
            if params.type==v.type then
                local n = 0
                if params.type=='cj' then
                    local res = {"r1","r2","r3","r4","gold"}
                    for rk,rv in pairs(params.num or {}) do
                        if table.contains(res,rk) then
                            n = n + rv
                        end
                    end
                else
                    n = params.num
                end

                if self.info[aname].tk[k][2]<self.info[aname].tk[k][3] then
                    self.info[aname].tk[k][1] = self.info[aname].tk[k][1] + n
                    local num = math.floor(self.info[aname].tk[k][1]/v.num)
                     
                    if num>0 then
                        local rn = num
                        if self.info[aname].tk[k][2]+num>self.info[aname].tk[k][3] then
                            rn = self.info[aname].tk[k][3] - self.info[aname].tk[k][2]
                        end
                        self.info[aname].tk[k][1] = self.info[aname].tk[k][1] - num*v.num
                        self.info[aname].tk[k][2] = self.info[aname].tk[k][2] + rn

                        for i=1,rn do
                            setRandSeed()
                            local randval = rand(1,100)
                            if randval<v.rate*100 then
                                local re,rkey = getRewardByPool(activeCfg.serverreward[v.pool],1) 
                                for k,v in pairs(re) do
                                    for rk,rv in pairs(v) do                  
                                        self.info[aname][rk] = (self.info[aname][rk] or 0) + rv
                                        reward[rk] = (reward[rk] or 0) + rv
                                    end 
                                end
                            end   
                        end     
                    end
                end
                break
            end
        end

        return reward
    end

    -- 通用充值商店
    function self.tyczsd(aname,params)
        local activeCfg = self.getActiveConfig(aname)
        if not self.info[aname].tsq then
            self.info[aname].tsq = 0
        end

        if not self.info[aname].sq then
            self.info[aname].sq = 0
        end

        if not self.info[aname].gems then
            self.info[aname].gems = 0
        end

        self.info[aname].gems = self.info[aname].gems + params.num
        if self.info[aname].tsq < activeCfg.sellLimit then
            local leftgems =  self.info[aname].gems-self.info[aname].tsq*activeCfg.rechargeNum
            local num = math.floor(leftgems/activeCfg.rechargeNum)
           
            if num>0 then
                local diff = activeCfg.sellLimit-self.info[aname].tsq
                if num>diff then
                    num = diff
                end

                self.info[aname].sq = self.info[aname].sq + num
                self.info[aname].tsq = self.info[aname].tsq + num
            end
        end
    end

    -- 番茄大作战
    function self.fqdzz(aname,params)
        local weeTs = getWeeTs()
        local ts = getClientTs()
        local activeCfg = self.getActiveConfig(aname)
        local uobjs = getUserObjs(self.uid)
        uobjs.load({"userinfo"})
        local mUserinfo = uobjs.getModel('userinfo')
        if mUserinfo.alliance<=0 then
            return false
        end

        if ts > tonumber(self.getAcet(aname, true)) then
            return false
        end

        if not self.info[aname].tk then
            self.info[aname].tk = {}
            for k,v in pairs(activeCfg.serverreward.taskList) do
                table.insert(self.info[aname].tk,{0,0,0})-- 当前值 可领取次数 已领取次数
            end
        end

        -- 每日需要重置的任务
        if self.info[aname].t ~= weeTs then
            self.info[aname].t = weeTs
            for k,v in pairs(activeCfg.serverreward.taskList) do
                if v.refresh==1 then
                    self.info[aname].tk[k] = {0,0,0} -- 可领取次数 已领取次数 当前值
                end
            end
        end

        -- 任务
        if params.act == 'tk' then
            for k,v in pairs(activeCfg.serverreward.taskList) do
                if v.type == params.type then
                    local num = 0
                    if v.type=='gs' then
                        if params.num>=v.num then
                            num = 1
                        end
                    else
                        local n=0
                        if v.type=='cj'  then
                            local res = {"r1","r2","r3","r4","gold"}
                            for rk,rv in pairs(params.num or {}) do
                                if table.contains(res,rk) then
                                    n = n + rv
                                end
                            end
                        else
                            n = params.num
                        end

                        self.info[aname].tk[k][3] = self.info[aname].tk[k][3] + n
                        num = math.floor(self.info[aname].tk[k][3]/v.num)
                        if num>0 then
                            self.info[aname].tk[k][3] = self.info[aname].tk[k][3] - num*v.num
                        end
                    end
                  
                    if num>0 then
                        self.info[aname].tk[k][1] = self.info[aname].tk[k][1]+num
                        if v.limit>0 then
                            if self.info[aname].tk[k][1]+self.info[aname].tk[k][2]>v.limit then
                                local left = v.limit - self.info[aname].tk[k][2]
                                if self.info[aname].tk[k][1]>=left then
                                    self.info[aname].tk[k][1] = left   
                                end             
                            end
                        end
                    end           
                end
            end

        elseif params.act == 'join' then
            -- 玩家重新加入军团 需要同步当前军团奖励数据 防止玩家不停加军团领取奖励
            local aid = params.aid
            if aid>0 then
                local aAllianceActive = getModelObjs("allianceactive",aid)
                if aAllianceActive then
                    local activeObj = aAllianceActive.getActiveObj(aname)
                    self.info[aname].ur = copyTable(activeObj.activeInfo.reward or {})
                end
                self.info[aname].fqdzz_a1 = 0
            end
        elseif params.act=='quit' then
            self.info[aname].ur = {}-- 已领取军团奖励清空
            self.info[aname].fqdzz_a1 = 0
            -- self.info[aname].tk = {}
            -- for k,v in pairs(activeCfg.serverreward.taskList) do
            --     table.insert(self.info[aname].tk,{0,0,0})-- 当前值 可领取次数 已领取次数
            -- end
        end
    end

    -- 海域航线
    function self.hyhx(aname,params)
        local weeTs = getWeeTs()
        local activeCfg = self.getActiveConfig(aname)
        if not self.info[aname].tk then
            self.info[aname].tk = {}
            for k,v in pairs(activeCfg.serverreward.taskList) do
                table.insert(self.info[aname].tk,{0,0,0})--可领取次数 已领取次数 当前值
            end
        end

        if self.info[aname].t ~= weeTs then
            self.info[aname].t = weeTs
            for k,v in pairs(activeCfg.serverreward.taskList) do
                self.info[aname].tk[k] = {0,0,0} 
            end
        end
        
        -- 已领取军团宝箱
        if not self.info[aname].box then
            self.info[aname].box = {}
        end

        -- 个人击杀和进攻的箱子领取完要清空
        -- 击杀奖励
        if not self.info[aname].kill then
            self.info[aname].kill = {}
        end

        -- 进攻奖励
        if not self.info[aname].att then
            self.info[aname].att = {}
        end

        -- 打过的boss所在轮数
        if not self.info[aname].bn then
            self.info[aname].bn = 0
        end

        -- 打过的boss所在轮中的下标
        if not self.info[aname].bi then
            self.info[aname].bi = 0
        end
        if params.act== 'tk' then
            local index = 0
            for k,v in pairs(activeCfg.serverreward.taskList) do
                if params.type==v.type then
                    index = k
                    break
                end
            end

            if index==0 then
                return false
            end
            local tkcfg = activeCfg.serverreward.taskList[index]
            if type(tkcfg)~='table' then
                return false
            end

            self.info[aname].tk[index][3] = self.info[aname].tk[index][3] + params.num
            local num = math.floor(self.info[aname].tk[index][3]/tkcfg.num)
            if num>0 then
                self.info[aname].tk[index][3] = self.info[aname].tk[index][3] - num*tkcfg.num
            end

            if num>0 then
                self.info[aname].tk[index][1] = self.info[aname].tk[index][1]+num
                if tkcfg.limit>0 then
                    if self.info[aname].tk[index][1]+self.info[aname].tk[index][2]>tkcfg.limit then
                        local left = tkcfg.limit - self.info[aname].tk[index][2]
                        if self.info[aname].tk[index][1] >= left then
                            self.info[aname].tk[index][1] = left   
                        end             
                    end
                end
            end      
        elseif params.act == 'join' then
            -- 玩家重新加入军团 需要同步当前军团宝箱数据 防止玩家不停加军团领取宝箱奖励
            local aid = params.aid
            if aid>0 then
                local aAllianceActive = getModelObjs("allianceactive",aid)
                if aAllianceActive then
                    local activeObj = aAllianceActive.getActiveObj(aname)
                    self.info[aname].box = copyTable(activeObj.activeInfo.abox or {})
                end
            end
        end
    end

    -- 堆金积玉
    function self.djjy(aname,params)
        local activeCfg = self.getActiveConfig(aname)
        local ts = getClientTs()
        local st = self.info[aname].st
        if type(self.info[aname].ch)~='table' then
            self.info[aname].ch = {}--充值 
            self.info[aname].r = {} --领取记录
           
            for k,v in pairs(activeCfg.serverreward.taskList) do
                self.info[aname].ch[k] = 0
                self.info[aname].r[k] = {}
                for dk,dv in pairs(v) do
                    table.insert(self.info[aname].r[k],0)--0未领取 1已领取
                end
            end
        end

        local currDay = math.floor(math.abs(ts-getWeeTs(st))/(24*3600)) + 1;
        local day ='day'..currDay
        if self.info[aname].ch[day] then
            self.info[aname].ch[day] = (self.info[aname].ch[day] or 0) + params.num
        end
    end

    -- 军校优等生
    function self.jxyds(aname,params)
        if params.num>0 then
             self.info[aname].gem = (self.info[aname].gem or 0) + params.num
        end
    end

    -- 军火限购
    function self.jhxg(aname,params)
        local weeTs = getWeeTs()
        local activeCfg = self.getActiveConfig(aname)
        if not self.info[aname].en then
            self.info[aname].en = {0,0}
        end

        if not self.info[aname].ch then
            self.info[aname].ch = {0,0}
        end

        if self.info[aname].t ~= weeTs then
            self.info[aname].t = weeTs
            self.info[aname].en = {0,0}--总的值,已领取次数
        end
        if params.act == 'energy' then
            self.info[aname].en[1] = self.info[aname].en[1] + params.num
            if activeCfg.energyBack[3]>0 then
                local limit = activeCfg.energyBack[3]*activeCfg.energyBack[1]
                if self.info[aname].en[1]>=limit then
                    self.info[aname].en[1] = limit
                end
            end
        end

        if params.act == 'charge' then
            self.info[aname].ch[1] = self.info[aname].ch[1] + params.num
            if activeCfg.rechargeNum[3]>0 then
                local limit = activeCfg.rechargeNum[3]*activeCfg.rechargeNum[1]
                if self.info[aname].ch[1]>=limit then
                    self.info[aname].ch[1] = limit
                end
            end
        end
    end

    -- 宝石精研
    function self.bsjy(aname,params)  
        if params.act == 'rate' then
            local activeCfg = self.getActiveConfig(aname)
            return activeCfg.rateUp*100
        end
    end

    -- 残骸打捞 
    function self.chdl(aname,params)
        local activeCfg = self.getActiveConfig(aname)
        if params.aid then
            if table.contains(activeCfg.gaizao,params.aid) then
                return activeCfg.discount 
            end
        end
    end

    -- 飞机技能捕获计划
    function self.fjjnbhjh(aname,params)
        local activeCfg = self.getActiveConfig(aname)
        if type(self.info[aname].task) ~='table' then
            self.info[aname].task = {}        
            for k,v in pairs(activeCfg.serverreward.taskList) do
                table.insert(self.info[aname].task,{0,0})--当前完成数量  领取次数
            end
        end

        local tid = 0
        local tcolor = {up={c4=3,c5=4},dec={c2=1,c3=2}}
        --品质,1.白 2.绿 3.蓝 4.紫 5.橙
        if params.color<=0 then
            return false
        end
        if params.act == 'up' then
            if params.color == 4 or params.color == 5  then
                tid = tcolor['up']['c'..params.color]
                self.info[aname].task[tid][1] = self.info[aname].task[tid][1] + params.num   
            end
        elseif params.act == 'dec' then
            if params.color == 2 or params.color == 3 then
                tid = tcolor['dec']['c'..params.color]
                self.info[aname].task[tid][1] = self.info[aname].task[tid][1] + params.num 
            end
            self.info[aname].task[5][1] = self.info[aname].task[5][1] + params.num 
            self.info[aname].task[6][1] = self.info[aname].task[6][1] + params.num 
        end

        for k,v in pairs(activeCfg.serverreward.taskList) do
            if self.info[aname].task[k][1]>=v.num then
                self.info[aname].task[k][1] = v.num
            end
        end

    end

    --军团折扣商店
    function  self.jtzksd(aname,params)  
        local activeCfg = self.getActiveConfig(aname)
        if params.num>0 then 
            self.info[aname].gems=(self.info[aname].gems or 0)+ params.num
        end

        local aid = params.aid
        if aid > 0 then
            local aAllianceActive = getModelObjs("allianceactive",aid,false,true)  
            local activeObj = aAllianceActive.getActiveObj(aname):addPoint(params)    
        end
       
    end
    --  充值团购
    function  self.cztg(aname,params)  
        local activeCfg = self.getActiveConfig(aname)
        local activeInfo = self.info[aname]
        -- 时间
        local currDay = math.floor(math.abs(getClientTs()-self.info[aname].st)/(24*3600)) + 1;
        if not self.info[aname].time then
            self.info[aname].time = getWeeTs()
            self.info[aname].t=currDay
        end
        -- 隔天初始化个人数据
        if self.info[aname].time ~= getWeeTs() then
            self.info[aname].gems=0
            self.info[aname].t=self.info[aname].t+1
            self.info[aname].time = getWeeTs()
            for key,val in pairs(self.info[aname].atask) do
                for kk,vv in pairs(val) do
                    self.info[aname].atask[key][kk]=0
                end
            end
            for key,val in pairs(self.info[aname].stask) do
                for kk,vv in pairs(val) do
                    self.info[aname].stask[key][kk]=0
                end
            end
        end

        --加金币
        if params.num>0 then 
            self.info[aname].gems=(self.info[aname].gems or 0)+ params.num
        end
        
        -- 记录是否向服务器发送请求的标识
        if not self.info[aname].send then
            self.info[aname].send= 1
        end
        --1发送  2已发送
        if self.info[aname].send==1  then
            local senddata={
                zid=params.tzid,
                aid = currDay,
                acname=aname,
                st = self.info[aname].st,
                score = 1,
            }
    
            local r = require("lib.crossActivity").cztgNum(senddata)
            self.info[aname].send=2
        end

        --初始化军团任务
        if type(self.info[aname].atask) ~= 'table' then
            flag = true
            self.info[aname].atask = {}  
            for key,val in pairs(activeCfg.serverreward.list2[self.info[aname].t]) do
                table.insert(self.info[aname].atask,{})
                for kk,vv in pairs(activeCfg.serverreward.list2[self.info[aname].t][key]) do
                    table.insert(self.info[aname].atask[key],0)--012, 未,可,已领取
                end
            end
        end

        --初始化全服任务
        if type(self.info[aname].stask) ~= 'table' then
            flag = true
            self.info[aname].stask = {}  
            for key,val in pairs(activeCfg.serverreward.list1[self.info[aname].t]) do
                table.insert(self.info[aname].stask,{})
                for kk,vv in pairs(activeCfg.serverreward.list1[self.info[aname].t][key]) do
                    table.insert(self.info[aname].stask[key],0)--012, 未,可,已领取
                end
            end
        end
        --全服任务状态    
        for key,val in pairs(activeCfg.serverreward.list1[self.info[aname].t]) do

            for k1,v1 in pairs(val) do
                if  self.info[aname].gems>=v1.num and v1.type =='gb' and self.info[aname].stask[key][k1] ==0 then
                    self.info[aname].stask[key][k1]=1
                end
            end
        end 

        --军团任务状态
        local aid = params.aid
        if aid > 0 then
            local aAllianceActive = getModelObjs("allianceactive",aid,false,true)  
            local activeObj = aAllianceActive.getActiveObj(aname):addPoint(params)  
            for key,val in pairs(activeCfg.rechargeNum) do 
                
                for k1,v2 in pairs(activeCfg.serverreward.list2[self.info[aname].t][key]) do

                    if  activeObj.legion >=v2.num    and v2.type =='jt'  and self.info[aname].atask[key][k1]==0 then
                        self.info[aname].atask[key][k1]=1
                    end

                    if  self.info[aname].gems>=v2.num  and v2.type =='gb' and self.info[aname].atask[key][k1] ==0 then
                        self.info[aname].atask[key][k1]=1
                    end
                    
                end 
            end 
             
        end

    end

    -- 军团之光
    function self.jtzg(aname,params)
        local activeCfg = self.getActiveConfig(aname)
        local activeInfo = self.info[aname]

        if type(self.info[aname].charge) ~='table' then
            self.info[aname].charge = {}        
            for k,v in pairs(activeCfg.serverreward.rechargeNum) do
                table.insert(self.info[aname].charge,{0,0})
            end
        end

        if type(self.info[aname].ex)~='table' then
            self.info[aname].ex = {}
            for  k,v in pairs(activeCfg.serverreward.extraRechargeNum) do
                table.insert(self.info[aname].ex,{0,0})
            end      
        end

        -- 手电筒
        if not self.info[aname].jtzg_a1 then
            self.info[aname].jtzg_a1 = 0
        end

        -- 探照灯
        if not self.info[aname].jtzg_a2 then
            self.info[aname].jtzg_a2 = 0
        end

        if params.act=='charge' then
            local id = 0
            local len = #activeCfg.serverreward.extraRechargeNum
            for i=len,1,-1 do
                if params.num>=activeCfg.serverreward.extraRechargeNum[i] then
                    id = i
                    break
                end
            end
            if id>0 then
                self.info[aname].ex[id][1] = (self.info[aname].ex[id][1] or 0) + 1
            else
                local len = #activeCfg.serverreward.rechargeNum
                for i=len,1,-1 do
                    if params.num>=activeCfg.serverreward.rechargeNum[i] then
                        id = i
                        break
                    end
                end

                if id>0 then
                    self.info[aname].charge[id][1] = (self.info[aname].charge[id][1] or 0) + 1  
                end
            end
        elseif params.act == "quitAlliance" then
            local ts= getClientTs()
            if ts > tonumber(self.getAcet(aname, true)) then
                return false
            end
            
            if (activeInfo.jtzg_a2 or 0) > 0 then
                local aid = params.aid
                if aid > 0 then
                    local mAllianceActive = getModelObjs("allianceactive",aid,false,true)
                    if mAllianceActive then
                        mAllianceActive.getActiveObj(aname):subPoint(activeInfo.jtzg_a2)
                    end
                    activeInfo.jtzg_a2 = 0
                end   
            end
        end     
    end


    -- 限时充值
    function self.xscz(aname,params)
        local id = 0
        local activeCfg = self.getActiveConfig(aname)

        if type(self.info[aname].charge) ~='table' then
            self.info[aname].charge = {}        
            for k,v in pairs(activeCfg.serverreward.rechargeNum) do
                table.insert(self.info[aname].charge,{0,0})
            end
        end

        if type(self.info[aname].ex)~='table' then
            self.info[aname].ex = {}
	    if activeCfg.serverreward.extraRechargeNum then
	         for  k,v in pairs(activeCfg.serverreward.extraRechargeNum) do
		    table.insert(self.info[aname].ex,{0,0})
		 end
	    end
                 
        end
       
        if activeCfg.serverreward.extraRechargeNum then
	   local len = #activeCfg.serverreward.extraRechargeNum
	   for i=len,1,-1 do
	      if params.num>=activeCfg.serverreward.extraRechargeNum[i] then
		 id = i
		 break
	      end
	   end
	end
        
        if id>0 then
            if self.info[aname].ex[id][1]+self.info[aname].ex[id][2]<activeCfg.serverreward.extraBuyLimit[id] then
                self.info[aname].ex[id][1] = (self.info[aname].ex[id][1] or 0) + 1
            end
        else
            local len = #activeCfg.serverreward.rechargeNum
            for i=len,1,-1 do
                if params.num>=activeCfg.serverreward.rechargeNum[i] then
                    id = i
                    break
                end
            end

            if id>0 then
                if self.info[aname].charge[id][1]+self.info[aname].charge[id][2]<activeCfg.serverreward.buyLimit[id] then
                    self.info[aname].charge[id][1] = (self.info[aname].charge[id][1] or 0) + 1  
                end
            end
        end
    end

     -- 新橙配馈赠
    function self.cpkznew(aname,params)
        if aname==nil or params==nil then  return false end

        local activeCfg = self.getActiveConfig(aname)
        if type(self.info[aname].charge) ~='table' then--充值领取记录
            self.info[aname].charge = {}
            local items = table.length(activeCfg.serverreward.rechargeNum)
            for i=1,items do
                table.insert(self.info[aname].charge,0)
            end
        end

        if type(self.info[aname].cost) ~= 'table' then--消费领取记录
            self.info[aname].cost = {}
            local items = table.length(activeCfg.serverreward.consumeNum)
            for i=1,items do
                table.insert(self.info[aname].cost,0)
            end
        end

        if params.act == 'charge' then--充值
            self.info[aname].gem = (self.info[aname].gem or 0) + params.num
        elseif params.act == 'cost' then--消费
            self.info[aname].co = (self.info[aname].co or 0) + params.num
        end
    end

    -- 配件大回馈
    function self.pjdhk(aname,params)
        if params.act == 'charge' then
            self.info[aname].gem  = (self.info[aname].gem or 0) + params.num
        elseif params.act=='energy' then
            self.info[aname].energy = (self.info[aname].energy or 0) + params.num
        end
    end

    -- 远洋征战 加士气值
    function self.oceanmorale(aname,params)
        local activeCfg = self.getActiveConfig(aname)
        local morale = 0
         --采集x点资源=1点士气值
        if params.act =='res' then
            if type(params.num)~='table' then
                return false
            end
            local num = 0
            for k,v in pairs(params.num) do
                num = num + v
            end
            self.info[aname].res = (self.info[aname].res or 0) + num
            morale = math.floor(self.info[aname].res/activeCfg.collect)
            if morale>0 then
                self.info[aname].res =self.info[aname].res -  morale*activeCfg.collect
            end
        end

        --生产军舰对应积分
        if params.act =='proShip' then
            if params.num<=0 then
                return false
            end

            local cfg = getConfig('tank.' .. params.id)
            if type(cfg)~='table' then
                return false
            end
            local  lv = 'l'..cfg.level
            if activeCfg.roShip[lv] then
                morale = morale + activeCfg.roShip[lv]*params.num
            end
        end

        --消耗1点体力 获得x点士气值
        if params.act=='energy' then
            morale = activeCfg.costPower*params.num
        end

        local point = 0
        if params.act =='charge' then
            self.info[aname].gem = (self.info[aname].gem or 0) + params.num
             local nums = math.floor(self.info[aname].gem/activeCfg.recharge[1])
            if nums>0 then
                local moralecfg = getConfig("oceanExpedition.morale")
                self.info[aname].gem =self.info[aname].gem -  nums*activeCfg.recharge[1]
                morale = nums*activeCfg.recharge[2]*moralecfg.costFlowerMor

                point = nums*activeCfg.recharge[2]*moralecfg.costFlowerP
            end
        end

        if morale>0 then
            local uobjs = getUserObjs(self.uid)
            uobjs.load({'oceanexpedition'})
            local mOcean = uobjs.getModel('oceanexpedition')
            require "model.active"
            local mActive = model_active()
            local oceancfg = mActive.selfCfg('oceanmorale')
         
            aftersave.morale = {}
            aftersave.morale.bid = oceancfg.bid
            aftersave.morale.morale =(aftersave.morale.morale or 0) + morale
    
            mOcean.addmorale(morale)  
            if point>0 then
                mOcean.addFlowerScore(point)
            end

            if mOcean.apply_at==0 then
                mOcean.apply_at = getClientTs()
            end
        end

    end

    -- 德国召回
    function self.gerrecall(aname,params)
        -- 给活跃玩家创建召回码
        local function creatcode(senddata)
            local respbody = gerrecallrequest(senddata,1)
            respbody = json.decode(respbody)
       
            if type(respbody) ~= 'table' or respbody.ret ~=0  then
                writeLog(json.encode(senddata),'gerrecall_errorlog')
		return false
            end

            return respbody.data.code
        end

        local ts= getClientTs()
        local weeTs = getWeeTs()
        local activeCfg = self.getActiveConfig(aname)

        -- 活跃玩家活动期间充值
        if self.info[aname].u and self.info[aname].u==2 and params.act == 'charge' then
            self.info[aname].hyplayer.tc = (self.info[aname].hyplayer.tc or 0) + params.num
        end
        -- 只记录流失玩家的 然后同步到跨服表里
        if self.info[aname].u and self.info[aname].u==1 and params.act=='charge' then
            self.info[aname].lsplayer.gem = self.info[aname].lsplayer.gem + params.num
            -- 更新跨服上玩家的数据

            local data = {
                zid  = getZoneId(),
                uid  = self.uid,
                name = params.nickname,
                level = params.level,
                st   = self.info[aname].st,-- 活动开启时间
                gem  = self.info[aname].lsplayer.gem,-- 充值的钻石
            }
            if type(aftersave.gerrecall)~='table' then
                aftersave.gerrecall = {}
                aftersave.gerrecall = data
            else
                aftersave.gerrecall.gem = self.info[aname].lsplayer.gem
            end

        elseif params.act =='login' then
            -- 没有确定身份(流失/活跃)时,需要设置(1为流失2为活跃用户)
 
            if not self.info[aname].u then
                -- 新用户上次登录时间为0,与当前时间相减一定会超过配置的流失时间
                if params.lt < 1000 then params.lt = ts end
                local difftimes = ts - params.lt                           
                if difftimes >= (activeCfg.timeLimit * 86400) then
                    self.info[aname].u = 1 -- 流失玩家
                    local nld = math.floor(difftimes/86400)
                    self.info[aname].lsplayer = {
                        ch = {}, -- 充值奖励
                        lg = 0,--登陆奖励 0未领取 1已领取
                        sh = {},-- 商店购买记录
                        ratio = 1, -- 回归奖励系数
                        gem = 0, -- 充值钻石数
                        r = 0, -- 回归奖励下标
                        sid = 0,-- 商店Id
                        bind={},-- 绑定玩家的数据
                        bd = 0,-- 是否领取绑定奖励
                        bt = ts,-- 回归登陆时间
                        day = 0,-- 回归累计登陆了几天
                        nld = nld,-- 未登录天数
                    }
                    for k,v in pairs(activeCfg.serverreward.returnList) do
                        table.insert(self.info[aname].lsplayer.ch,0)
                    end
      
                    -- 商店
                    local lvindex = 0
                    for i=#activeCfg.levelGroup,1,-1 do
                        if params.level>=activeCfg.levelGroup[i] then
                            lvindex = i
                            break
                        end
                    end

                    self.info[aname].lsplayer.r = lvindex==0 and 1 or lvindex
                    local vipindex = 0
                    for i=#activeCfg.vipGroup,1,-1 do
                        if params.vip>=activeCfg.vipGroup[i] then
                            vipindex = i
                            break
                        end
                    end


                    -- 计算商店编号 按照（等级分组-1）*4+vip分组 取商店编号
                    local shid = (lvindex-1)*4 + vipindex
                    if shid<=0 then
                        shid = 1
                    end
                    if type(activeCfg.serverreward.shopList[shid])=='table' then
                        self.info[aname].lsplayer.sid= shid
                        for k,v in pairs(activeCfg.serverreward.shopList[shid].value) do
                            table.insert(self.info[aname].lsplayer.sh,0)
                        end
                    end
                        
                    -- 回归奖励系数
                    local days = math.floor(difftimes/86400)
                    local rindex = 0
                    for i=#activeCfg.timeGroup,1,-1 do
                        if days>=activeCfg.timeGroup[i] then
                            rindex = i
                            break
                        end
                    end
                    if rindex>0 then
                        self.info[aname].lsplayer.ratio = activeCfg.timeMul[rindex]
                    end
                else
                    self.info[aname].u = 2 -- 流活跃玩家
                    self.info[aname].hyplayer = {
                        h1 = {},-- 召回人数奖励
                        h2 = {},--召回充值奖励
                        us = {},-- 已经召回的玩家 uid 昵称 等级 服id
                        gem = 0,-- 召回玩家充值的钻石
                        tc = 0,-- 活动期间充值
                    }        
                    for k,v in pairs(activeCfg.serverreward.callList1) do
                        table.insert(self.info[aname].hyplayer.h1,0)
                    end
                
                    for k,v in pairs(activeCfg.serverreward.callList2) do
                        table.insert(self.info[aname].hyplayer.h2,0)
                    end
                end
            end
            -- 老玩家回归登陆天数统计
            if self.info[aname].u==1 then
                if getWeeTs(params.lt)~=getWeeTs() then
                    self.info[aname].lsplayer.day = (self.info[aname].lsplayer.day or 0) + 1
                end 
            end
        end

        -- 改名字
        if params.act=='rename' and self.info[aname].u==2 and self.info[aname].hyplayer.ic then
            local senddata = {
                zid  = getZoneId(),
                uid  = self.uid,
                name = params.nickname,-- 玩家的昵称
                updated_at = ts, 
                st = self.info[aname].st,
            }
            local re = gerrecallrequest(senddata,5)
        end

        -- 为活跃用户分配一个唯一的邀请码
        if self.info[aname].u == 2 and not self.info[aname].hyplayer.ic then
            local senddata = {
                zid  = getZoneId(),
                uid  = self.uid,
                name = params.nickname,-- 玩家的昵称
                updated_at = ts, 
                st = self.info[aname].st,
            }

            local code = creatcode(senddata)
            if code then self.info[aname].hyplayer.ic = code end
        end
    end

    -- 德国首冲条件礼包
    function self.sctjgift(aname,params)
        local ts = getClientTs()
        local activeCfg = self.getActiveConfig(aname)

        -- 只有登录的时候才会刷新礼包信息 
        if params.act == 'login' then
            -- 有未领取的 不刷新礼包 直到领取完再刷新至当前出现的礼包
            if self.info[aname].r and self.info[aname].r==1 then
                return false
            end

            if self.info[aname].r and self.info[aname].r==2 then
                self.info[aname].show = 0
                return false
            end

            local currDay = math.floor(math.abs(ts-getWeeTs(self.info[aname].st))/(24*3600)) + 1
            local gid = 0 -- 礼包编号
            for i=#activeCfg.openDays,1,-1 do
                if currDay>=activeCfg.openDays[i] then
                    gid = i
                    break
                end
            end
            if gid ==0 then
                self.info[aname].show = 0
                self.info[aname].r = 2
                return false
            end

            -- 判断宝箱 是否刷新
            if not self.info[aname].gid then
                self.info[aname].gid = gid -- 礼包id
                self.info[aname].ch = 0 -- 充值金额
                self.info[aname].ct = ts  
                self.info[aname].r = 0
                self.info[aname].show = 1 -- 告诉客户端 弹出活动面板
            else
                local gift = copyTable(activeCfg.serverreward.gift[gid])
                if type(gift)~='table' then
                    self.info[aname].show = 0
                    self.info[aname].r = 2
                else
                    -- 同一天不能出现两个 且大于当前的结束时间
                    if getWeeTs(ts)>getWeeTs(self.info[aname].ct+gift.lastTime) then
                        if gid>self.info[aname].gid then
                            self.info[aname].gid = gid -- 礼包id
                            self.info[aname].ch = 0 -- 充值金额
                            self.info[aname].ct = ts  
                            self.info[aname].r = 0
                            self.info[aname].show = 1 -- 告诉客户端 弹出活动面板
                        else
                            self.info[aname].show = 0
                            self.info[aname].r = 2
                        end     
                    end
                end
            end         
        elseif params.act =='charge' then
            if self.info[aname].gid>0  then
                local gift = copyTable(activeCfg.serverreward.gift[self.info[aname].gid])
                if type(self.info[aname].pt)~='table' then-- 达成礼包充值条件 充值的次数
                    self.info[aname].pt = {}
                end

                -- 记录充够时 当前礼包剩余时间
                if type(self.info[aname].lt)~='table' then
                    self.info[aname].lt = {}
                end

                if self.info[aname].r == 0 and ts>=self.info[aname].ct and ts<=self.info[aname].ct+gift.lastTime then
                    self.info[aname].pt['g'..self.info[aname].gid] = (self.info[aname].pt['g'..self.info[aname].gid] or 0) + 1
                    self.info[aname].ch = (self.info[aname].ch or 0) + params.num

                    if self.info[aname].ch >= gift.rechargeNum then
                        self.info[aname].r = 1
                        self.info[aname].lt['g'..self.info[aname].gid] = self.info[aname].ct + gift.lastTime - ts
                    end
                end

               
                if type(self.info[aname].rlog)~='table' then self.info[aname].rlog = {} end
            end

            self.info[aname].tc = (self.info[aname].tc or 0) + params.num -- 总充值金额
            if not self.info[aname].fc then
                self.info[aname].fc = params.num--首充钻石记录
            end

            if not self.info[aname].flag then
                self.info[aname].flag = 'sctjgifttongji'--用于后期统计是查询标识（只查充值过的玩家 减少查询量）
            end
            self.info[aname].ctimes = (self.info[aname].ctimes or 0) + 1 -- 总充值次数
             
        end
    end

    --团结之力
    function self.unitepower(aname,params)
        if params.aid<=0 then return false end
        self.initAct(aname)
        -- 玩家退出军团 需要清理 红包排行榜中相应玩家的数据
        if params.quit then
            local redis = getRedis()
            local alkey = "zid."..getZoneId()..aname..self.info[aname].st.."_a"..params.aid
            local adata = json.decode(redis:get(alkey))
            if type(adata)~='table' then
                adata = {}
            end
       
            if next(adata) then
                for k,v in pairs(adata) do
                    if v[1] == self.uid then
                        table.remove(adata,k)
                        redis:set(alkey,json.encode(adata))
                        redis:expireat(alkey,self.info[aname].et)
                        break
                    end
                end 
            end
        else
            -- 任务数据记录
            if type(self.info[aname].task[params.id]) == 'table' then
                if params.id==3 then -- 公海领地 采集 天然气和铀
                    if type(params.res)=='table' then
                        for k,v in pairs(params.res) do
                            if k=='r6' or k=='r7' then
                                params.num = params.num + tonumber(v)
                            end
                        end
                    end 
                end
                self.info[aname].task[params.id][1] = self.info[aname].task[params.id][1] + params.num
            end 

            return true
        end
    end
    -- 世界杯_一球成名
    function self.oneshot(aname,params)
        local reward = {}
        local ts = getClientTs()
        local id = params.id
        self.initAct(aname)
        local activeCfg = self.getActiveConfig(aname)

        -- 判断当天获取数量上限
        -- 当前是第几天 
        local currDay = math.floor(math.abs(ts-getWeeTs(self.info[aname].st))/(24*3600)) + 1
        if params.act == 'task' then
            local numlimit = activeCfg['numLimit'..id]  
            if type(numlimit) ~= 'table' then
                return reward
            end

            -- 如果取不到上限 用最后一个（数值同学的要求）
            local len = #numlimit
            local limit = numlimit[currDay] or numlimit[len]

            if self.info[aname].task[id] < limit then
                setRandSeed()
                local randval = rand(1,100)
      
                local rate = activeCfg.serverreward.getRate[id]*100
                if randval <= rate then
                    local num = activeCfg.serverreward.getNum[id]
                    local gtn = 0
                    for k,v in pairs(activeCfg.serverreward.candyGet) do
                        gtn = v*num
                        reward[k] = gtn
                    end
                    if not takeReward(self.uid,reward) then
                        return {}
                    end

                    self.info[aname].task[id] = self.info[aname].task[id] + gtn
                end
            end
        elseif params.act == 'cost' then
            self.info[aname].ch = self.info[aname].ch + params.num
        end

        if next(reward) then
            return formatReward(reward)
        end

        return reward
    end
    -- 累计充值(世界杯)
    function self.ljczsjb(aname,params)
        local activeCfg = self.getActiveConfig(aname)
        local ts= getClientTs()
        local st1 = self.info[aname].st
        local et1 = st1 + activeCfg.days[1]*86400
        local st2 = et1
        local et2 = st2 + activeCfg.days[2]*86400
        local st3 = et2
        local et3 = st3 + activeCfg.days[3]*86400       
        if type(self.info[aname].chargeInfo) ~='table' then
            self.info[aname].chargeInfo = {}
            local x = #activeCfg.days
            for i=1,x do
                table.insert(self.info[aname].chargeInfo,0)
            end
        end 
        if params.act == 'charge' then
            if ts >= st1 and ts < et1 then
                self.info[aname].chargeInfo[1] = self.info[aname].chargeInfo[1] + params.num
            end
            if ts >= st2 and ts < et2 then
                self.info[aname].chargeInfo[2] = self.info[aname].chargeInfo[2] + params.num
            end
            if ts >= st3 and ts < et3 then
                self.info[aname].chargeInfo[3] = self.info[aname].chargeInfo[3] + params.num
            end
        end
    end
    -- 累计天数充值(世界杯)
    function self.ljtscz(aname,params)
        local ts= getClientTs()
        local totalDay = math.ceil(math.abs(self.info[aname].et - self.info[aname].st)/(24*3600))
         -- 当前是第几天
        local currDay = math.floor(math.abs(ts-getWeeTs(self.info[aname].st))/(24*3600)) + 1
        local activeCfg = self.getActiveConfig(aname) 
        if type(self.info[aname].buynum) ~='table' then
            self.info[aname].buynum = {}
            for k,v in pairs(activeCfg.serverreward.shopList) do
                table.insert(self.info[aname].buynum,0)
            end
        end 
        if type(self.info[aname].dayInfo) ~='table' then
            self.info[aname].dayInfo = {}
            for i=1,totalDay do
                table.insert(self.info[aname].dayInfo,0)
            end
        end 
        if type(self.info[aname].giftlog) ~='table' then
            self.info[aname].giftlog = {}
            for i=1,totalDay do
                table.insert(self.info[aname].giftlog,0)
            end
        end 
        if self.info[aname].biglog == nil then
            self.info[aname].biglog = 0
        end
        if params.act == 'charge' then
            self.info[aname].dayInfo[currDay] = self.info[aname].dayInfo[currDay] + params.num
        end
    end
    -- 重金打造
    function self.zjdz(aname,params)
        local ts = getClientTs()
        local activeCfg = self.getActiveConfig(aname)
        if self.info[aname].nums == nil then
            self.info[aname].nums = 0 --可抽奖次数
        end
        if self.info[aname].sign == nil then
            self.info[aname].sign = 0 --单次
        end
        if self.info[aname].more == nil then
            self.info[aname].more = 0 --多次
        end
        -- 积分
        if self.info[aname].s == nil then
            self.info[aname].s = 0--积分
        end
        -- 总充值
        if self.info[aname].tc == nil then
            self.info[aname].tc = 0
        end

        local rechargeNum = activeCfg.rechargeNum
        local lotteryNum = activeCfg.lotteryNum      
        if params.act == 'charge' then
            if params.num >= rechargeNum[1] then
                self.info[aname].sign = self.info[aname].sign + lotteryNum[1]
            end
            self.info[aname].gems = (self.info[aname].gems or 0) + params.num
            if self.info[aname].gems >= rechargeNum[2] then
                local x = math.floor(self.info[aname].gems/rechargeNum[2])
                self.info[aname].more = self.info[aname].more + lotteryNum[2]*x
                self.info[aname].gems = self.info[aname].gems - rechargeNum[2]*x
            end 

            self.info[aname].tc = self.info[aname].tc + params.num
            -- 获得积分
            local gets = math.floor((self.info[aname].tc-self.info[aname].s*activeCfg.scoreMul)/activeCfg.scoreMul)
            if ts < self.getAcet(aname,true) and gets>0 then
                self.info[aname].s = self.info[aname].s + gets
                if self.info[aname].s>=activeCfg.rLimit then
                    local uobjs = getUserObjs(self.uid)
                    uobjs.load({"userinfo"})
                    local mUserinfo = uobjs.getModel('userinfo')
                    params = {
                          action = 3,
                          zoneid     = getZoneId(),
                          uid        = self.uid,
                          nickname   = mUserinfo.nickname,
                          st = tonumber(self.info[aname].st),
                          score = tonumber(self.info[aname].s),
                          updated_at = ts,
                          acname = aname..'_'..self.info[aname].cfg,
                    }
                    local ret = crossserverrank(params)
                    if not ret then
                       writeLog(json.encode(params),'zjdz_errlog')
                    end
                end
            end         
        end
    end
    --异星卡片
    function self.aliencard(aname,params)
        local activeCfg = self.getActiveConfig(aname)
        if params.act == 'up' then
            local res = {}
            local r = params.value
            local t = params.t
            local alienTree = activeCfg.alienTree
            local discount = activeCfg.discount
            local need = activeCfg.need
            local a
            for k,v in pairs(need) do
                if table.contains(v,t) then
                   a = k
                   break
                end
            end
            if not table.contains(alienTree,a) then
                return res
            end
            local pos = 0
            for k,v in pairs(alienTree) do
                if a== v then
                   pos = k
                   break
                end
            end
            local rate = discount[pos]
            for k,v in pairs(r) do
                r[k] = math.floor(v*rate)
            end
            return r
        end 
        local tank = {}
        if params.act == 'add' then
            if table.contains(activeCfg.nextRequire,params.aid) then
                return activeCfg.reform,activeCfg.nextRequire
            end
        end
        
    end

    -- 超装组件
    function self.czzj(aname,params)
        local activeCfg = self.getActiveConfig(aname)
        if type(self.info[aname].buynum) ~='table' then
            self.info[aname].buynum = {}
            for k,v in pairs(activeCfg.serverreward.shopList) do
                table.insert(self.info[aname].buynum,0)
            end
        end
        if params.act == 'charge' then
            self.info[aname].gems = (self.info[aname].gems or 0) + params.num
        end
    end
    -- 芯片装配
    function self.xpzp(aname,params)
        local activeCfg = self.getActiveConfig(aname)
        if self.info[aname].l == nil then
            self.info[aname].l = 0
        end
        if self.info[aname].buynum == nil then
            self.info[aname].buynum = 0
        end
        if self.info[aname].buycheck == nil then
            self.info[aname].buycheck = 0
        end
        local rechargeNum = activeCfg.rechargeNum
        local buyLimit = activeCfg.buyLimit
        if params.act == 'charge' then
            self.info[aname].gems = (self.info[aname].gems or 0) + params.num
            if self.info[aname].gems >= rechargeNum and self.info[aname].buycheck == 0 then
                self.info[aname].buycheck = 1
            end
        end
        local prop = activeCfg.serverreward.buyItem
        local value = activeCfg.value
        local tvalue = 0
        for k,v in pairs(prop) do
            prop = k:split('_')
            prop = prop[2]
        end
        -- ptb:e(self.info[aname])
        if params.pid then
            if prop~=params.pid then
               return false
            end
            if self.info[aname].buynum+params.num>buyLimit then
                return false
            end
            if self.info[aname].buycheck ~= 1 then
                return false
            end 
            tvalue = value*params.num
            if tvalue > 0 then
                self.info[aname].buynum = self.info[aname].buynum + params.num
                return tvalue
            end
        end
    end

    -- 全民劳动(2018 五一活动)
    function self.laborday(aname,params)
        local rate = nil
        self.initAct(aname)
        local activeCfg = self.getActiveConfig(aname)
        if params.act == 'task' then--任务完成值记录
            for k,v in pairs(activeCfg.serverreward.taskList) do
                local n = 0
                if v.type == params.t then
                    if v.type == 'cj' then
                        for _,rv in pairs(params.n) do
                            n = n + rv
                        end
                    else
                        n = params.n
                    end
                    self.info[aname].task[k][1] = (self.info[aname].task[k][1] or 0) + n
                end
            end
        elseif params.act == 'upRate' then -- 加速或者增加百分比
            --（1-世界矿点采集速度加成。2-内矿产出速度加成。3-副本经验获得加成。4-世界地图行军速度加成 5-稀土修船消耗减少比例）
            rate = activeCfg.upRate[params.n]
            writeLog('n='..params.n..'rate='..rate,'laborday')
        end

        return rate
    end

    -- 累计充值2018
    function self.concharge(aname,params)
        local activeCfg = self.getActiveConfig(aname)
        if type(self.info[aname].charge) ~='table' then
            self.info[aname].charge = {}
            local items = table.length(activeCfg.serverreward.rechargeNum)
            for i=1,items do
                table.insert(self.info[aname].charge,0)
            end
        end
        self.info[aname].gem = (self.info[aname].gem or 0) + params.num
        for k,v in pairs(activeCfg.serverreward.rechargeNum) do
            if self.info[aname].charge[k]==0 and self.info[aname].gem>=v then
                self.info[aname].charge[k]=1
            end
        end
    end
    --平稳降落
    function self.safeend(aname,params)
        local activeCfg = self.getActiveConfig(aname)
        local taskCfg=activeCfg.serverreward.taskList
        if type(self.info[aname].task) ~= 'table' then
            self.info[aname].task = {} --任务
            for k,v in pairs(activeCfg.serverreward.taskList) do
                self.info[aname].task[k] = {}
                self.info[aname].task[k].index = v[1].index
                self.info[aname].task[k].cur = 0 --当前数量
                self.info[aname].task[k].p = 1--进度 1,2,3
                self.info[aname].task[k].r = 0--0未完成、1可领取、2已领取
            end
        end
        local act = params.act
        local num = params.num
        self.info[aname].task[act].cur = self.info[aname].task[act].cur + num
        for k,v in pairs(self.info[aname].task) do
            local info=taskCfg[k][v.p]
            if v.r==0 then
                self.info[aname].task[k].con=info[1]
                if self.info[aname].task[k].cur>=info[1] then
                    self.info[aname].task[k].r=1
                end
            end
        end
        -- ptb:p(self.info[aname].task)
    end
    
    -- 钻石轮盘
    function self.gemwheel(aname,params)
        local ts= getClientTs()
        local weeTs = getWeeTs()
        -- 当天23:59时间戳
        local currTs = weeTs+86400-1
        local activeCfg = self.getActiveConfig(aname)
        if self.info[aname].nighttime == nil then
            self.info[aname].nighttime = 0
        end
        if self.info[aname].gems == nil then
            self.info[aname].gems = 0
        end
        if self.info[aname].num == nil then
            self.info[aname].num = 0
        end
        if self.info[aname].r == nil then
            self.info[aname].r = 0
        end
        if ts > self.info[aname].nighttime then
            self.info[aname].num = 0 --已经轮盘次数
            self.info[aname].nighttime = currTs
        end
        local numLimit = activeCfg.numLimit
        local rcLimit = activeCfg.rcLimit
        if params.act == 'charge' then
            self.info[aname].gems = self.info[aname].gems + params.num
            if self.info[aname].gems > rcLimit[2] then
                self.info[aname].gems = rcLimit[2]
            end
            if params.num >= rcLimit[1] then
               self.info[aname].r = 1
            end
        end
    end
    -- 召回付费礼包
    function self.recallpay(aname,params)
        local ts = getClientTs()
        local weeTs = getWeeTs()
        self.initAct(aname)
        local activeCfg = self.getActiveConfig(aname)

        local uobjs = getUserObjs(self.uid)
        uobjs.load({"userinfo"})
        local mUserinfo = uobjs.getModel('userinfo')

        if mUserinfo.level<activeCfg.levelLimit then
            return false
        end

        -- 匹配礼包
        local function matchgift()
            local checkList = copyTable(activeCfg.serverreward.checkList)
            local mHero      = uobjs.getModel('hero')
            local mSequip = uobjs.getModel('sequip')
            local mAweapon = uobjs.getModel('alienweapon')
            local mAccessory = uobjs.getModel('accessory')
            local mArmor = uobjs.getModel('armor')

            local aliencfg = getConfig("alienWeaponCfg.strengWeaponLimit")
            local alienmaxlv = #aliencfg

            local accecfg=getConfig("accessory.aCfg")

            local avoidgiftid = {}
            for k,v in pairs(checkList) do
                local flag = false
                if v.checkType==1 then  --1 将领品质 五星 hero[hid][3]
                    local n = 0
                    for h,hv in pairs(v.serverreward) do
                        if type(mHero.hero[hv])=='table' then
                            if mHero.hero[hv][3]>=5 then
                                n = n + 1
                            end
                        else
                            break
                        end
                    end
                    if n==#v.serverreward then
                        flag = true
                    end
                elseif v.checkType==2 then--2 超级装备 至少有相应一件  sequip[]
                    for s,sv in pairs(v.serverreward) do
                        if type(mSequip.sequip[sv])== 'table' then
                            flag = true
                            break
                        end
                    end
                elseif v.checkType==3 then--3 异星武器 进阶满  info[id][2]
                    local n = 0
                    for a,av in pairs(v.serverreward) do
                        if type(mAweapon.info[av])=='table' then
                            if tonumber(mAweapon.info[av][2]) >= alienmaxlv then
                                n = n + 1
                            end
                        else
                            break
                        end
                    end
                   
                    if n==#v.serverreward then
                        flag = true
                    end
                elseif v.checkType==4 then --4 配件 判断位置装备上的 品质达到要求
                    local n = 0
                    local pn = #v.para1*4
                    for i=1,4 do
                        if type(mAccessory.used['t'..i])=='table' then
                            for p,pv in pairs(v.para1) do
                                if type(mAccessory.used['t'..i]['p'..p])=='table' then
                                    local aid =mAccessory.used['t'..i]['p'..p][1]
                                    if accecfg[aid].quality>=v.para2 then
                                        n = n + 1
                                    end
                                end
                            end
                        end
                    end

                    if n == pn then
                        flag = true
                    end
                elseif v.checkType==5 then--5 方阵 判断位置装备上的 品质达到要求
                    local n = 0
                    local an = #v.para1*6

                    for i=1,6 do
                        if type(mArmor.used[i])=='table' and next(mArmor.used[i]) then
                            for _,p in pairs(v.para1) do
                                if type(mArmor.info[mArmor.used[i][p]])=='table' and next(mArmor.info[mArmor.used[i][p]]) then
                                    local arid = mArmor.info[mArmor.used[i][p]][1] or 0
                                    local armorCfg=getConfig('armorCfg.matrixList.'..arid)
                                    if type(armorCfg)=='table' then
                                        if armorCfg.quality>=v.para2 then
                                            n = n + 1
                                        end
                                    end  
                                end                               
                            end
                        end
                    end

                    if n==an then
                        flag = true
                    end
                end
                if flag then
                    table.merge(avoidgiftid,v.giftMatch)
                end
            end

            return avoidgiftid
        end
        
        -- 初始化礼包数据
        local function init()
	        local olddata = json.encode(self.info[aname])
            local cost = 0
            local db = getDbo()
            local result = db:getRow("select sum(`num`) as total from tradelog where userid = :userid and status = 1",{userid=self.uid})
            if type(result) == 'table' and next(result) then
               cost = tonumber(result.total)
            end
            
            -- 获取充值档位
            local chargeindex = 0
            local items = #activeCfg.rechargeNeed
            for i=items,1,-1 do
                if cost >= activeCfg.rechargeNeed[i] then
                    chargeindex = i
                    break
                end
            end

            if chargeindex == 0 then 
                self.info[aname].pop = 0-- 条件不满足 不要弹出礼包
                return false 
            end
            self.info[aname].ex = chargeindex --用于在第一个日期到期 累计额外时间
            -- 根据权重随机一个充值
            local newtb = {}
            for i=1,chargeindex do
                table.insert(newtb,activeCfg.rechargeRate[i])
            end
            
            local giftindex = randVal(newtb)
            self.info[aname].np = activeCfg.rechargeCut[giftindex]--获得礼包奖励需要充值
            -- 哪个奖励
            self.info[aname].g1 = giftindex -- 礼包下标
            self.info[aname].g2 = 0
            -- 需要根据检测的礼包id做筛选过滤
            local avoidgiftid = matchgift() 
            local giftpool = {}
            for k,v in pairs(activeCfg.serverreward.giftList[giftindex]) do
                if not table.contains(avoidgiftid,v.index) then
                    table.insert(giftpool,k)
                end
            end

            local oid = self.info[aname].g2
            local rd = rand(1,#giftpool)

            local newid = giftpool[rd]
            self.info[aname].g2 = newid
            if oid == newid then
                if #giftpool>=2 then
                    table.remove(giftpool,rd)

                    local nrd = rand(1,#giftpool)
                    self.info[aname].g2 = giftpool[nrd]
                end
               
            end
           
            -- 随机出现的日期
            local days = rand(activeCfg.recallTime[chargeindex][1],activeCfg.recallTime[chargeindex][2])
            self.info[aname].pt = weeTs+days*86400 -- 弹出时间
            self.info[aname].pop = 0 

            self.info[aname].ch = 0 --当天充值
            self.info[aname].cost = cost -- 总充值
            self.info[aname].r = 0 -- 当天是否已经领取 0未领取 1已领取
            self.info[aname].cr = 0
            self.info[aname].td = 0 -- 如果礼包出现 则记录出现当天的时间戳

            -- 容错
            if self.info[aname].g1 == 0 or self.info[aname].g2 == 0 then
                self.info[aname].g1 = 1
                self.info[aname].g2 = 1
                writeLog('召回付费礼包 奖励容错了'..self.uid..'giftindex='..giftindex..'pool'..json.encode(giftpool),'zhaohui') 
            end

	        local newdata = json.encode(self.info[aname])
            writeLog('召回付费礼包初始化'..self.uid..'-初始化时间-'..getClientTs()..'-olddata-'..olddata..'-newdata-'..newdata,'recallpay')


            return true
        end
         
        -- 检测是否有与充值返利有关的活动开启
        local function check()
            -- 如果含有充值返利的活动 不弹出
            require "model.active"
            local mActive = model_active()
            local actlist = mActive.getTitleList(mUserinfo.logindate,self.uid)
            if type(actlist)~='table' then
                actlist = {}
            end 

            if type(activeCfg.serverreward.avoidact)=='table' and next(activeCfg.serverreward.avoidact) then
                for k,v in pairs(actlist) do
                    if table.contains(activeCfg.serverreward.avoidact,k) then
                       
                        return true
                    end
                end
            end

            if self.info.firstRecharge and self.info.firstRecharge.c == 0 then
                return true
            end

            return false
        end
      
        if params.act == 'login' then
            -- 有未领取的 一直展示
            if self.info[aname].cr == 1 and self.info[aname].r==0 then
                self.info[aname].pop = 1 -- 是否弹出 
                return true
            end
            if self.info[aname].pt == 0 or self.info[aname].r == 1 then
                init()
            else            
                -- 时间大于等于弹出时间
                if weeTs >= self.info[aname].pt then
                    init()
                    --writeLog('弹出','zhaohui')
                    self.info[aname].pop = 1 
                    self.info[aname].td = weeTs
                    self.info[aname].ch = 0

                    local ex = self.info[aname].ex 
                    local adddays = rand(activeCfg.reBuyTime[ex][1],activeCfg.reBuyTime[ex][2])
                    self.info[aname].pt = weeTs + adddays * 86400     
                end   
            end
        
            if tonumber(self.info[aname].td) ~= weeTs then
                self.info[aname].pop = 0
            else
                self.info[aname].pop = 1
            end

            if check() then
                self.info[aname].pop = 0
            end
           
        elseif params.act == 'init' then -- 领取礼包之后需要重置
            init()
        else
            if self.info[aname].td~=weeTs then
                -- 有可领取的不能给重置
                if self.info[aname].cr==1 and self.info[aname].r ==1 or self.info[aname].cr==0 then
                    init()
                end
            else
                -- 到达指定时间那一天  才记录充值金额
                if not check() and self.info[aname].td == weeTs and self.info[aname].g2>0 then
                    self.info[aname].ch = self.info[aname].ch + params.num  
                    
                    if self.info[aname].ch >= self.info[aname].np then
                        self.info[aname].cr = 1 --可领取
                    end
                end 
            end    
        end

        return true
    end
    --百级开启
    function self.levelopen(aname,params)
        local ts= getClientTs()
        if ts > tonumber(self.getAcet(aname, true)) then
            return false
        end
        local activeCfg = self.getActiveConfig(aname)
        local uobjs = getUserObjs(self.uid)
        local mUserinfo = uobjs.getModel('userinfo')
        if mUserinfo.level>=activeCfg.levelLimit then
            if type(self.info[aname].task) ~= 'table' then
                self.info[aname].task = {} --任务
                for k,v in pairs(activeCfg.serverreward.taskList) do
                    local id =math.ceil((mUserinfo.level-activeCfg.levelLimit+1)/10)
                    local tmpid = #v
                    if id > tmpid then
                        id = tmpid
                    end
                    self.info[aname].task[k] = {}
                    self.info[aname].task[k].index = id --任务下标
                    self.info[aname].task[k].cur = 0 --当前数量
                    self.info[aname].task[k].cron = v[id][1]--完成条件
                    self.info[aname].task[k].r = 0--任务是否领奖
                end
                self.info[aname].levelopen_a1 = 0 --福利劵
                self.info[aname].welnum = 0 --福利领取次数
                self.info[aname].levelopen_a2 = 0 --积分
                self.info[aname].r = 0 --排行榜奖励
            end
            if params.act == 'f1' then
                if params.level > self.info[aname].task.f1.cron then
                    self.info[aname].task.f1.cur = self.info[aname].task.f1.cur + 1
                end
            elseif params.act == 'f2' then
                self.info[aname].task.f2.cur = self.info[aname].task.f2.cur + params.exp
            elseif params.act == 'f3' then
                if params.level > self.info[aname].task.f3.cron then
                    self.info[aname].task.f3.cur = self.info[aname].task.f3.cur + 1
                end
            elseif params.act == 'f4' then
                 if params.w==1 then
                    if params.defenderId > self.info[aname].task.f4.cron*16 then
                        self.info[aname].task.f4.cur = self.info[aname].task.f4.cur + 1
                    end
                end
            else
                if params.level > self.info[aname].task.f5.cron then
                    self.info[aname].task.f5.cur = self.info[aname].task.f5.cur + 1
                end
            end
        end
    end
    -- 圣帕特里克
    function self.dresshat(aname,params)
        local reward = {} 
        local activeCfg = self.getActiveConfig(aname)
        if type(self.info[aname].giftlog) ~= 'table' then
            self.info[aname].giftlog = {} --帽子奖励
            local items = table.length(activeCfg.supportNeed)
            for i = 1,items do
                table.insert(self.info[aname].giftlog,0)
            end           
            self.info[aname].gem = 0--累计充值
            self.info[aname].gn = 0 --累计充值领取奖励次数

            self.info[aname].dresshat_a1 = 0
            self.info[aname].dresshat_a2 = 0
            self.info[aname].dresshat_a3 = 0

            self.info[aname].s = 0--积分
            self.info[aname].c1 = 0--- 道具1使用的个数
            self.info[aname].c2 = 0
            self.info[aname].c3 = 0

            self.info[aname].shop = {}
            for _,v in pairs(activeCfg.serverreward.shopList) do
                table.insert(self.info[aname].shop,0)
            end
            self.info[aname].fb = 0 -- facebook分享奖励
        end
        if params.act == 'charge' then
            self.info[aname].gem = self.info[aname].gem + params.num
            self.info[aname].gn = math.floor(self.info[aname].gem/activeCfg.rechargeNum)
        else
            if params.w~=1 then
                return reward
            end
            setRandSeed()
            local randpool = activeCfg.serverreward.candyGet[params.act]
            local rewardcfg = activeCfg.serverreward.candyGet[1]
            -- 掉落活动道具
            for i=1,params.num do
                for k,v in pairs(randpool) do
                    local rd = rand(1,100)
                    if rd<=v then
                        self.info[aname][rewardcfg[k][1]] = (self.info[aname][rewardcfg[k][1]] or 0) + rewardcfg[k][2]
                        reward[rewardcfg[k][1]] = (reward[rewardcfg[k][1]] or 0) + rewardcfg[k][2]  
                    end
                end    
            end    
        end
        return reward
    end
    --击破壁垒
    function self.jpbl(aname,params)
        if params.pid then
            local activeCfg = self.getActiveConfig(aname)
            local prop = activeCfg.serverreward.exchangeItem[1]         
            propitems = prop:split('_')

            if propitems[2]==params.pid then
                return params.gems
            end
        end

        return nil
    end

    -- 德国月卡
    function self.germancard(aname,params)
        local ts = getClientTs()
        local weeTs = getWeeTs()
        self.initAct(aname)
        local activeCfg = self.getActiveConfig(aname)
        if self.info[aname]['ot'][1]>0 and self.info[aname]['ot'][2]>0 then
            -- 从开启到当前的天数是否
            local currDay1 = math.floor(math.abs(ts-getWeeTs(self.info[aname]['ot'][1]))/(24*3600)) + 1
            local currDay2 = math.floor(math.abs(ts-getWeeTs(self.info[aname]['ot'][2]))/(24*3600)) + 1
            if currDay1 > activeCfg.dayCount[1] and currDay2 > activeCfg.dayCount[2] then
                return false
            end
        end    

        -- 充值钻石
        if params.num>0 then
            self.info[aname].gem = self.info[aname].gem + params.num
        end

        return self.info[aname]
    end

     -- 勋章兑换
    function self.medal(aname,params)
        self.initAct(aname)
        local activeCfg = self.getActiveConfig(aname)
        local discountItem = activeCfg.discountItem
        local discount = activeCfg.discount
        local discountGem = 0
        if discountItem == params.pid then
           discountGem = math.floor(params.gems*discount)
        else
           discountGem = math.floor(params.gems)
        end
        return discountGem
    end

    -- 合服大战
    function self.hfdz(aname,params)
        self.initAct(aname)
        local act = params.act
        local activeCfg = self.getActiveConfig(aname)

        if act == 'quit' and params.aid> 0 then
            local ts= getClientTs()
            if ts > tonumber(self.getAcet(aname, true)) then
                return false
            end
            -- 退军团  清空个人积分  扣除相应军团积分 
            local oscore = self.info[aname].s or 0
            self.info[aname].s = 0

            local aid = params.aid
            if oscore > 0 then
                local redis = getRedis()
                local scorekey = "zid."..getZoneId().."."..aname.."ts"..self.info[aname].st..'score'
                local scorelist = json.decode(redis:get(scorekey))

                if type(scorelist) ~= 'table' or not next(scorelist) then
                    scorelist = {}
                end

                local setRet,code=M_alliance.getalliance{aid=aid}
                -- 如果解散了军团 需要将军团从排行榜中去除
                local flag = false
                if type(setRet['data']['alliance'])=='table' and not next(setRet['data']['alliance']) then
                    flag = true
                end

                for k,v in pairs(scorelist) do
                    if tonumber(v[1]) == aid then
                        if flag then
                            table.remove(scorelist,k)
                        else
                            v[3] = v[3] - oscore
                        end
                        break
                    end
                end

                local list = readRankfile(aname,self.info[aname].st)
                if type(list) == 'table' then
                    for k,v in pairs(list) do 
                        if tonumber(v[1]) == aid then
                            if flag then
                                table.remove(list,k)
                            else
                                v[3] = v[3] - oscore
                            end

                            break
                        end
                    end
                    local ranklist = json.encode(list)
                    writeActiveRankLog(ranklist,aname,self.info[aname].st) -- 排行榜记录日志
                end
       
                redis:set(scorekey,json.encode(scorelist))
                redis:expireat(scorekey,self.info[aname].et+86400)
            end
        end

        if params.num >0 then
            for k,v in pairs(activeCfg.serverreward.taskList[1]) do
                local total = v.num*v.limit
                if v.type==act and self.info[aname].task[k][1]<total then
                    self.info[aname].task[k][1] =  self.info[aname].task[k][1] + params.num
                    if self.info[aname].task[k][1]>total then
                        self.info[aname].task[k][1] = total
                    end          
                end
            end
        end
    end

    -- 岁末回馈
    function self.feedback(aname,params)
        local activeCfg = self.getActiveConfig(aname)
        if not self.info[aname].task then 
            self.info[aname].task = {}--领取状态
            for k,v in pairs(activeCfg.serverreward.taskList) do
                self.info[aname].task[k] = {}
                for key,val in pairs(v) do
                    local k1 = val.type
                    if k1 ~= 'gb' then
                        self.info[aname].task[k][k1] = {0,0}
                    else
                        table.insert(self.info[aname].task[k],{0,0})
                    end
                    
                end
            end  
        end
        if params.act == 'charge' then
            local num = tonumber(params.num)
            if num > 0 then
                for k,v in pairs(self.info[aname].task[2]) do
                    self.info[aname].task[2][k][1] = self.info[aname].task[2][k][1] + num
                end
                for k,v in pairs(self.info[aname].task[2]) do
                    local numCfg = activeCfg.serverreward.taskList[2][k].num
                    if self.info[aname].task[2][k][1]>numCfg then
                       self.info[aname].task[2][k][1] = numCfg
                    end
                end
            end 
        else
            local act = params.act
            local num = tonumber(params.num)
            if num < 1 then
                return false
            end
            self.info[aname].task[1][act][1] = (self.info[aname].task[1][act][1] or 0) + num
        end
    end

    -- 红包回馈
    function self.redbagback(aname,params)
        self.initAct(aname)
        -- 充值钻石
        if params.num>0 then
            self.info[aname].gem = self.info[aname].gem + params.num
        end
    end


    --  连续消费
    function self.lxxf(aname,params)
        if params.act == 'xf' then
            local gems = tonumber(params.n)
            local ts= getClientTs()
            local totalDay = math.ceil(math.abs(self.info[aname].et - self.info[aname].st)/(24*3600))
            if not self.info[aname].dayInfo then 
                self.info[aname].dayInfo = {}
                for i=1,totalDay do
                    table.insert(self.info[aname].dayInfo,0)
                end
            end
            if not self.info[aname].giftlog then 
                self.info[aname].giftlog = {}
                for i=1,totalDay do
                    table.insert(self.info[aname].giftlog,0)
                end
                table.insert(self.info[aname].giftlog,0)
            end
            if not self.info[aname].count then 
                self.info[aname].count = 0 
            end
             -- 当前是第几天
            local currDay = math.floor(math.abs(ts-getWeeTs(self.info[aname].st))/(24*3600)) + 1
            self.info[aname].dayInfo[currDay] = self.info[aname].dayInfo[currDay] + gems 
            -- ptb:e(self.info[aname].dayInfo)
        end
        return true
    end    
    -- 矩阵商店
    function self.armorshop(aname,params)
        local activeCfg = self.getActiveConfig(aname)
        if not self.info[aname].gem then
            self.info[aname].gem = 0--累计充值
            self.info[aname].dk = 0 --抵扣钻石
            self.info[aname].zk = 0 --折扣券
            self.info[aname].zkn = 0 -- 折扣券总数
        end

        self.info[aname].gem = self.info[aname].gem + params.num
        -- 抵扣钻石
        self.info[aname].dk = self.info[aname].dk + math.floor(params.num*activeCfg.backRate)--抵扣钻石

        if self.info[aname].zkn<3 then
            -- 抵扣券
            local num = math.floor(self.info[aname].gem/activeCfg.rechargeNum)
            if num > 0 then

                self.info[aname].gem = self.info[aname].gem - num*activeCfg.rechargeNum
                local addn = 0
                local oldn = self.info[aname].zkn
                self.info[aname].zkn =  self.info[aname].zkn + num
                if self.info[aname].zkn > activeCfg.discountLimit then
                    addn = activeCfg.discountLimit - oldn
                else
                    addn = num
                end

                self.info[aname].zk = self.info[aname].zk + addn
            end
        end
        

        return true
    end
    -- 跨年福袋
    function self.luckybag(aname,params)
        self.initAct(aname)
        local act = params.act
        local activeCfg = self.getActiveConfig(aname)
        local taskcfg = activeCfg.serverreward.taskList[act]

        if self.info[aname].task[act][2] >= taskcfg.limit then
            return false
        end

        -- act 1 每日任务 2 攻击玩家 3 累积消费 4 累积充值
        if act == 1 then
            -- 每日任务   
            self.info[aname].task[act][1] = 1
            self.info[aname].task[act][2] = self.info[aname].task[act][2] + 1
        elseif act == 2 then
            -- 攻打玩家
            self.info[aname].task[act][1] = self.info[aname].task[act][1] + params.n
            if self.info[aname].task[act][1] >= taskcfg.num then
                self.info[aname].task[act][1] = self.info[aname].task[act][1] - taskcfg.num
                self.info[aname].task[act][2] = self.info[aname].task[act][2] + 1
            end
        elseif act == 3 then
            -- 累积消费钻石
            local cost = self.info[aname].task[act][1] + params.n
            -- 可领取的次数
            local rn = math.floor(cost/taskcfg.num)
            if rn > 0  then
                self.info[aname].task[act][2] = self.info[aname].task[act][2] + rn
                if self.info[aname].task[act][2] > taskcfg.limit then
                    self.info[aname].task[act][2] = taskcfg.limit
                end

                self.info[aname].task[act][1] = cost - taskcfg.num*rn
            else
                self.info[aname].task[act][1] = cost
            end 
        elseif act == 4 then
            -- 累积充值
            local gem = self.info[aname].task[act][1] + params.n
            -- 可领取的次数
            local rn = math.floor(gem/taskcfg.num)
            if rn > 0  then
                self.info[aname].task[act][2] = self.info[aname].task[act][2] + rn
                if self.info[aname].task[act][2] > taskcfg.limit then
                    self.info[aname].task[act][2] = taskcfg.limit
                end
                self.info[aname].task[act][1] = gem - taskcfg.num*rn
            else
                self.info[aname].task[act][1] = gem
            end  
        end

        return true    
    end 
    -- 装扮圣诞树
    function self.dresstree(aname,params)
        local reward = {} 
        local activeCfg = self.getActiveConfig(aname)
        if type(self.info[aname].giftlog) ~= 'table' then
            self.info[aname].giftlog = {} --圣诞树奖励
            local items = table.length(activeCfg.supportNeed)
            for i = 1,items do
                table.insert(self.info[aname].giftlog,0)
            end
            table.insert(self.info[aname].giftlog,0)--最终大奖
           
            self.info[aname].gem = 0--累计充值
            self.info[aname].gn = 0 --累计充值领取奖励次数
            self.info[aname].single = 0 --单笔充值 可领取次数

            self.info[aname].dresstree_a1 = 0
            self.info[aname].dresstree_a2 = 0
            self.info[aname].dresstree_a3 = 0

            self.info[aname].s1 = 0--道具1对应获得积分
            self.info[aname].s2 = 0
            self.info[aname].s3 = 0

            self.info[aname].c1 = 0--- 道具1使用的个数
            self.info[aname].c2 = 0
            self.info[aname].c3 = 0

            self.info[aname].shop = {}
            for _,v in pairs(activeCfg.serverreward.shopList) do
                table.insert(self.info[aname].shop,0)
            end
            self.info[aname].fb = 0 -- facebook分享奖励
        end
        
        if params.act == 'charge' then
            self.info[aname].gem = self.info[aname].gem + params.num
            if params.num >= activeCfg.rechargeNum[1] then
                self.info[aname].single = self.info[aname].single + 1
            end
        else
            if params.w~=1 then
                return reward
            end

           -- --攻击基地获得概率  act =2
           --  {80,0,40},
           --  --攻击矿点获得概率 act =3
           --  {80,0,40},
           --  --攻打关卡         act =4
           --  {80,0,40},
           --  --攻打剧情关卡     act=5
           --  {100,0,80},
           --  --攻打装备探索关卡 act =6
           --  {100,0,80},
   
            setRandSeed()
            local randpool = activeCfg.serverreward.candyGet[params.act]
            local rewardcfg = activeCfg.serverreward.candyGet[1]

            -- 掉落活动道具
            for i=1,params.num do
                for k,v in pairs(randpool) do
                    local rd = rand(1,100)
                    if rd<=v then
                        self.info[aname][rewardcfg[k][1]] = (self.info[aname][rewardcfg[k][1]] or 0) + rewardcfg[k][2]
                        reward[rewardcfg[k][1]] = (reward[rewardcfg[k][1]] or 0) + rewardcfg[k][2]  
                    end
                end    
            end    
        end
        return reward
    end
    -- 感恩节2017
    function self.thanksgiving(aname,params)
        local resource = {}
        if params.act == 'charge' then
            if not self.info[aname].cost then
              self.info[aname].cost = 0 --累计充值的钻石
            end
            if not self.info[aname].more then
              self.info[aname].more = 0
            end
            self.info[aname].cost = self.info[aname].cost + params.num
            local activeCfg = self.getActiveConfig(aname)
            if params.num >= activeCfg.rechargeNum[1] then
                self.info[aname].single = (self.info[aname].single or 0) + 1
            end
            if self.info[aname].cost >= activeCfg.rechargeNum[2] then 
                self.info[aname].more = math.modf(self.info[aname].cost/activeCfg.rechargeNum[2])
            end
        else
            if params.w == 1 then 
               local index = tonumber(params.act)
               local rate = self.getActiveConfig(aname).serverreward.candyGet[index]
               local spprop = self.getActiveConfig(aname).serverreward.candyGet[1] 
               if params.num > 0 then
                  for i=1,params.num do
                     setRandSeed()
                     for i=1,3 do
                        local rd = rand(1,100)
                        if rd <= rate[i] then
                            self.info[aname][spprop[i][1]] = (self.info[aname][spprop[i][1]] or 0) + spprop[i][2]
                            resource[spprop[i][1]] = (resource[spprop[i][1]] or 0) + spprop[i][2]
                        end
                     end
                  end
               end
            end
        end
        return resource
    end     
    -- 德国七日狂欢 这里只记录任务完成值 
    -- 参数：v 、n
    function self.sevendays(aname,params)
        -- sd1 在第X天登录游戏  
        -- sd2 拥有X个5级建筑         
        -- sd3 角色等级达到X级  
        -- sd4 统率等级达到X级  
        -- sd5 拥有X个5级技能   
        -- sd6 拥有X个矩阵        
        -- sd7 拥有X艘战列舰    
        -- sd8 拥有X艘潜艇      
        -- sd9 拥有X艘护卫舰    
        -- sd10 拥有X艘航空母舰 
        -- sd11 关卡达到X星     
        -- sd13 拥有X个将领     
        -- sd16 攻打矿点X次
        -- sd19 攻打玩家X次
        -- sd22 消费钻石X
        -- sd25 拥有X个10级建筑
        -- sd26 拥有X个15级建筑
        -- sd27 拥有X个10级技能
        -- sd28 拥有X个15级技能
        -- sd21 拥有X个3级矩阵
        -- sd31 拥有X个5级矩阵
        -- sd32 拥有X个8级矩阵
        -- sd23 拥有X个5级配件
        -- sd33 拥有X个10级配件
        -- sd34 拥有X个15级配件
        -- sd24 军演排名达到X
        -- sd15 单次采集X资源 
        -- sd20 军团捐献X次
        -- sd17 补给线达到X星
        -- sd35 异星科技升级次数
        

        local activeCfg = self.getActiveConfig(aname)
        if not self.info[aname].task then
            self.info[aname].task = {}--领取状态
            self.info[aname].cur = {} -- 当前值
            for k,v in pairs(activeCfg.serverreward.taskList) do
                 self.info[aname].task[k] = {}
                for key,val in pairs(v) do
                    table.insert(self.info[aname].task[k],0) -- 0未领取 1可领取
                end
            end
            
            for k,v in pairs(activeCfg.serverreward.tasktype) do
                self.info[aname].cur[v] = 0 -- 任务对应当前完成值
            end   
        end

        local act = params.act
        -- sd1 在第X天登录游戏  num=1
        if act == 'sd1' then
            local ts= getClientTs()
            local currDay = math.floor(math.abs(ts-getWeeTs(self.info[aname].st))/(24*3600)) + 1
            if currDay > self.info[aname].cur[act] then
                self.info[aname].cur[act] = currDay
            end
            
        end

        --sd2 拥有X个5级建筑   
        --sd25 拥有X个10级建筑
        --sd26 拥有X个15级建筑
        if act == 'sd2' then
            local build5 = 0
            local build10 = 0
            local build15 = 0

            if type(params.v)=='table' then
                for i=1,51 do
                    if params.v['b'..i] and params.v['b'..i][2] then
                        if params.v['b'..i][2] >=5 then
                            build5 = build5 + 1
                        end

                        if params.v['b'..i][2] >=10 then
                            build10 = build10 + 1
                        end  

                        if params.v['b'..i][2] >=15 then
                            build15 = build15 + 1
                        end
                    end
                end
            end

            if build5 > self.info[aname].cur['sd2'] then
                self.info[aname].cur['sd2'] = build5
            end

            if build10 > self.info[aname].cur['sd25'] then
                self.info[aname].cur['sd25'] = build10
            end 

            if build15 > self.info[aname].cur['sd26'] then
                self.info[aname].cur['sd26'] = build15
            end
        end

         -- sd3 角色等级达到X级
         -- sd4 统率等级达到X级 
         -- sd11 关卡达到X星 
         --sd17 补给线达到X星    
        local containsact1 = {"sd3","sd4","sd11","sd17"}
        if table.contains(containsact1,act) then
            if params.n>self.info[aname].cur[act] then
                self.info[aname].cur[act] = params.n
            end     
        end

        --sd5 拥有X个5级技能   
        --sd27 拥有X个10级技能
        --sd28 拥有X个15级技能
        if act == 'sd5' then
            local sk5 = 0
            local sk10 = 0
            local sk15 = 0
            for i=101,112 do
                if params.v['s'..i] then
                    if params.v['s'..i]>=5 then
                        sk5 = sk5 + 1
                    end
                    if params.v['s'..i]>=10 then
                        sk10 = sk10 + 1
                    end
                    if params.v['s'..i]>=15 then
                        sk15 = sk15 + 1
                    end
                end

            end
            if sk5 > self.info[aname].cur['sd5'] then
                self.info[aname].cur['sd5'] = sk5
            end

            if sk10 > self.info[aname].cur['sd27'] then
                self.info[aname].cur['sd27'] = sk10
            end

            if sk15 > self.info[aname].cur['sd28']  then
                self.info[aname].cur['sd28'] = sk15
            end
        end
      

        --1：战列舰 2：潜艇 4：护卫舰 8：航母
        if params.act == 'addtank' and type(params.n)=='table' then

            local tankCfg = getConfig('tank')
            local zlj = 0
            local qt = 0
            local hwj = 0
            local hm = 0
      
            for k,v in pairs(params.n) do
                if tankCfg[k].type == 1 then
                    zlj = zlj + v
                elseif tankCfg[k].type == 2 then
                    qt  = qt + v
                elseif tankCfg[k].type == 4 then
                    hwj = hwj + v
                elseif tankCfg[k].type == 8 then
                    hm = hm + v
                end
            end

          
            -- sd7 拥有X艘战列舰   
            if zlj > self.info[aname].cur['sd7'] then
                self.info[aname].cur['sd7'] = zlj
            end
            --sd8 拥有X艘潜艇
            if qt > self.info[aname].cur['sd8'] then
                self.info[aname].cur['sd8'] = qt
            end
            -- sd9 拥有X艘护卫舰   
            if hwj > self.info[aname].cur['sd9'] then
                self.info[aname].cur['sd9'] = hwj
            end
            -- sd10 拥有X艘航空母舰 num=1 
            if hm > self.info[aname].cur['sd10'] then
                self.info[aname].cur['sd10'] = hm
            end
        end
        
        -- sd15 单次采集X资源   num=5
        if act == 'sd15' then
            if type(params.n)=='table' then
                for k,v in pairs(params.n) do
                    if v > self.info[aname].cur[act] then
                        self.info[aname].cur[act] = v
                    end
                end
            end
        end

        
        -- sd6 拥有X个矩阵 
  
        -- sd16 攻打矿点X次 
        -- sd19 攻打玩家X次 
        -- sd22 消耗钻石 
        -- sd20 军团捐献X次  
        -- sd35升级异星科技X次 

        local containsact2 = {"sd6","sd16","sd19","sd22","sd20","sd35"}
        if table.contains(containsact2,act) then
            self.info[aname].cur[act] = self.info[aname].cur[act] + params.n
        end

        --sd21 拥有X个3级矩阵
        --sd31 拥有X个5级矩阵
        --sd32 拥有X个8级矩阵
        if act == 'armorup' then
            local armor3 = 0
            local armor5 = 0
            local armor8 = 0

            if type(params.v)=='table' then
                for k,v in pairs(params.v) do
                    if v[2] >= 3 then
                        armor3 = armor3 + 1
                    end

                    if v[2] >= 5 then
                        armor5 = armor5 + 1
                    end

                      if v[2] >= 8 then
                        armor8 = armor8 + 1
                    end
                end
            end

            if armor3>self.info[aname].cur['sd21'] then
                self.info[aname].cur['sd21'] = armor3
            end

            if armor5>self.info[aname].cur['sd31'] then
                self.info[aname].cur['sd31'] = armor5
            end

            if armor8>self.info[aname].cur['sd32'] then
                self.info[aname].cur['sd32'] = armor8
            end
        end

        --sd23 拥有X个5级配件
        --sd33 拥有X个10级配件
        --sd34 拥有X个15级配件
        if act == 'accup' then
            local acc5 = 0
            local acc10 = 0
            local acc15 = 0

            if type(params.v)=='table' then
                for k,v in pairs(params.v) do
                    if v[2] >= 5 then
                        acc5 = acc5 + 1
                    end

                    if v[2] >= 10 then
                        acc10 = acc10 + 1
                    end

                      if v[2] >= 15 then
                        acc15 = acc15 + 1
                    end
                end
            end

            if type(params.n)=='table' then
                for k,v in pairs(params.n) do
                    for p,ac in pairs(v) do
                        if ac[2] >= 5 then
                            acc5 = acc5 + 1
                        end

                        if ac[2] >= 10 then
                            acc10 = acc10 + 1
                        end

                         if ac[2] >= 15 then
                            acc15 = acc15 + 1
                        end
                    end
                end
            end

            if acc5>self.info[aname].cur['sd23'] then
                self.info[aname].cur['sd23'] = acc5
            end
            if acc10>self.info[aname].cur['sd33'] then
                self.info[aname].cur['sd33'] = acc10
            end
            if acc15>self.info[aname].cur['sd34'] then
                self.info[aname].cur['sd34'] = acc15
            end

        end
        --sd24 军演排名达到X
        if act == 'sd24' then
            if self.info[aname].cur[act] ==0 then
                self.info[aname].cur[act] = params.v
            else
                if params.v < self.info[aname].cur[act] then
                    self.info[aname].cur[act] = params.v
                end
            end      
        end

    end

    -- 闪购商店
    function self.sgshop(aname,params)
        -- 消耗钻石
        if params.act == 'usegem' then
            if not self.info[aname].ugm then
                self.info[aname].ugm = 0
                self.info[aname].ubg1 = 0 -- 消费钻石第一档 已发红包数
                self.info[aname].ubg2 = 0 -- 消费钻石第二档 已发红包数
            end
            self.info[aname].ugm = self.info[aname].ugm + params.num
        elseif params.act == 'charge' then -- 充值钻石
            if not self.info[aname].charge then
                self.info[aname].charge = 0
                self.info[aname].cbg1 = 0 --充值钻石第一档 已发红包数
                self.info[aname].cbg2 = 0 --充值钻石第二档 已发红包数
            end
            self.info[aname].charge = self.info[aname].charge + params.num
        end
    end

    -- 双十一2018版
    function self.double112018(aname,params)
        -- 消耗钻石
        if params.act == 'usegem' then
            if not self.info[aname].ugm then
                self.info[aname].ugm = 0    -- 用户真实消耗的钻石数(不包含抵扣券的值)
                self.info[aname].ugm1 = 0 -- 用户消耗的钻石数(包含抵扣券的值)
                self.info[aname].agm = 0 -- 在当前军团消费的钻石数 
                self.info[aname].ubg1 = 0 -- 消费钻石第一档 已发红包数
                self.info[aname].ubg2 = 0 -- 消费钻石第二档 已发红包数
            end
            self.info[aname].ugm = self.info[aname].ugm + params.num
            self.info[aname].ugm1 = self.info[aname].ugm1 + params.num

            -- 抵扣值
            if params.rebateCost then
                self.info[aname].ugm1 = self.info[aname].ugm1 + params.rebateCost
            end
            
            -- 如果有军团
            local aid = getUserObjs(self.uid).getModel('userinfo').alliance
            local aPoint
            if aid > 0 then
                -- 军团总消耗也要算上抵扣值
                local p = params.num + (params.rebateCost or 0)
                self.info[aname].agm = (self.info[aname].agm or 0) + p

                local mAllianceActive = getModelObjs("allianceactive",aid,false,true)
                if mAllianceActive then
                    aPoint = mAllianceActive.getActiveObj(aname):addPoint(p)
                else
                    writeLog({msg="double112018.addPoint failed",aid=aid,params=p})
                end
            end

            return aPoint

        elseif params.act == 'charge' then -- 充值钻石
            if not self.info[aname].charge then
                self.info[aname].charge = 0
                self.info[aname].cbg1 = 0 --充值钻石第一档 已发红包数
                self.info[aname].cbg2 = 0 --充值钻石第二档 已发红包数
            end
            self.info[aname].charge = self.info[aname].charge + params.num
        elseif params.act == 'quit' then
            if not self.info[aname].agm then
                self.info[aname].agm = 0
            end

            if self.info[aname].agm > 0 then
                --扣除军团总伤害
                local aAllianceActive = getModelObjs("allianceactive",params.aid)
                if aAllianceActive then
                    local activeObj = aAllianceActive.getActiveObj(aname)
                    activeObj:subPoint(self.info[aname].agm)
                end
            end

            self.info[aname].agm = 0
            return true
        end
    end

    -- 万圣节狂欢
    function self.wsjkh(aname,params)
        local resource = {}
        if params.act == 'charge' then
            self.info[aname].gems=(self.info[aname].gems or 0)+params.num
            if not self.info[aname].cn then
                self.info[aname].cn = 0
            end
        elseif params.act == 'quit' and params.aid>0 then
            local ts= getClientTs()
            local lt = tonumber(self.getAcet(aname, true))
            if ts > lt  then
                return false
            end
            -- 退军团  清空个人积分  扣除相应军团积分 
            local oscore = self.info[aname].s or 0
            self.info[aname].s = 0

            local aid = params.aid
            if oscore > 0 then
                local redis = getRedis()
                local scorekey = "zid."..getZoneId().."."..aname.."ts"..self.info[aname].st..'score'
                local scorelist = json.decode(redis:get(scorekey))

                if type(scorelist) ~= 'table' or not next(scorelist) then
                    scorelist = {}
                end

                local setRet,code=M_alliance.getalliance{aid=aid}
                -- 如果解散了军团 需要将军团从排行榜中去除
                local flag = false
                if type(setRet['data']['alliance'])=='table' and not next(setRet['data']['alliance']) then
                    flag = true
                end
                
                for k,v in pairs(scorelist) do
                    if tonumber(v[1]) == aid then
                        if flag then
                            table.remove(scorelist,k)
                        else
                            v[3] = v[3] - oscore
                            v[4] = setRet['data']['alliance']['num']
                        end

                        break
                    end
                end

                local list = readRankfile(aname,self.info[aname].st)
                if type(list) == 'table' then
                    for k,v in pairs(list) do 
                        if tonumber(v[1]) == aid then
                            if flag then
                                table.remove(list,k)
                            else
                                v[3] = v[3] - oscore
                                v[4] = setRet['data']['alliance']['num']
                            end

                            break
                        end
                    end
                    local ranklist = json.encode(list)
                    writeActiveRankLog(ranklist,aname,self.info[aname].st) -- 排行榜记录日志
                end
       
                redis:set(scorekey,json.encode(scorelist))
                redis:expireat(scorekey,self.info[aname].et+86400)

                local redkey = "zid."..getZoneId().."."..aname.."ts"..self.info[aname].st.."_"..aid
                local ranklist = json.decode(redis:get(redkey))

                if type(ranklist) ~= 'table' or not next(ranklist) then
                    ranklist = {}
                end

                if flag then
                    ranklist = {}
                else
                    for i=#ranklist,1,-1 do
                        if type(ranklist[i]) == 'table' and ranklist[i][1] == self.uid then
                            table.remove(ranklist,i)
                        end
                    end
                end

              
                redis:set(redkey,json.encode(ranklist))
                redis:expireat(redkey,self.info[aname].et+86400)
            end

        else
            local activeCfg = self.getActiveConfig(aname)
            if type(self.info[aname].ngjl)~='table' then
                self.info[aname].ngjl={}--初始化
                -- 每个积分点领取状态
                for i=1,#activeCfg.supportNeed do
                    table.insert(self.info[aname].ngjl,0)
                end

                self.info[aname].wsjkh_a1 = 0 
                self.info[aname].wsjkh_a2 = 0 
                self.info[aname].wsjkh_a3 = 0 
                self.info[aname].wsjkh_a4 = 0 
            end
            -- 获取材料    
            -- candyGet={
            --     {{"wsjkh_a1",1},{"wsjkh_a2",1}},
            --     2 --攻击基地获得概率
            --     {20,20},
            --     3--攻击矿点获得概率
            --     {20,20},
            --     4--攻打海盗
            --     {10,30},
            --     5--攻打关卡
            --     {30,10},
            --     6--攻打剧情关卡
            --     {60,20},
            --     7--攻打装备探索关卡
            --     {60,20},
            -- },

            local containkeys = {2,3,4,5,6,7}
            if table.contains(containkeys,params.act) and params.w==1 then
                local rate = activeCfg.serverreward.candyGet[params.act]
                local newrate = {rate[1],rate[1]+rate[2]}
                local spprop = activeCfg.serverreward.candyGet[1]

                if params.num>0 then        
                    for i=1,params.num do
                        setRandSeed()
                        local rd=rand(1,100)
                       
                        for i=1,2 do
                            if rd<=newrate[i] then
                                self.info[aname][spprop[i][1]] = (self.info[aname][spprop[i][1]] or 0) + spprop[i][2]
                                resource[spprop[i][1]] = (resource[spprop[i][1]] or 0) + spprop[i][2]
                                break
                            end
                        end                    
                    end
                end
            end
        end

        return resource
    end

    -- 二周年
    function self.anniversary2(aname,params)
        local reward = {}
        local ts= getClientTs()
        local weeTs = getWeeTs()
        local activeCfg = self.getActiveConfig(aname)
        if params.act=='charge' then
            --1 连续充值 三天
            if self.info[aname].lx == nil  then
                self.info[aname].lx  = 0--连续充值次数
                self.info[aname].lt  = 0--上次充值时间
            end
   
            if self.info[aname].lx < activeCfg.rechargeDay then
                -- 今天充过就不加了
                if self.info[aname].lt ~= weeTs  then
                    local diff = weeTs-self.info[aname].lt
                    if diff ~= 86400 then
                        self.info[aname].lx  = 0--连续充值次数
                    end

                    self.info[aname].lx  = self.info[aname].lx + 1
                    self.info[aname].lt  = weeTs--上次充值时间
                end
            end

            -- 单笔充值
            if self.info[aname].sn ==nil then
                self.info[aname].sn = 0
            end
            if params.num>=activeCfg.rechargeNum[1] then
                self.info[aname].sn = self.info[aname].sn +1
            end

            -- 累计充值
            if self.info[aname].gem == nil then
                self.info[aname].gem  = 0
                self.info[aname].gn  = 0 --累计充值可领取次数
            end
            self.info[aname].gem =  self.info[aname].gem+params.num

            -- 流失用户充值才需要记录
            if self.info[aname].u == 1 then
                -- 活动期间首次充值记录下首充时间
                if not self.info[aname].rc then 
                    self.info[aname].rc = 0 
                end

                self.info[aname].rc = self.info[aname].rc + params.num
            end
        elseif table.contains({'pl','kd'},params.act) then
            local cardget = {}
            local index = 0
            setRandSeed()
            local rd=rand(1,100)

            -- 攻打玩家
            if params.act=='pl' then
                local newpool = {}
                local rate1 = activeCfg.serverreward.cardGet[2][1]
                table.insert(newpool,rate1)
                local rate2 = rate1 + activeCfg.serverreward.cardGet[2][2]
                 table.insert(newpool,rate2)

                for k,v in pairs(newpool) do
                    if rd <= v then
                        index = k
                        break
                    end 
                end
              
                if index>0 then
                    cardget = activeCfg.serverreward.cardGet[1][index]
                end 
         
            end

            -- -- 攻打矿点
            if params.act == "kd" then
                local newpool = {}
                local rate1 = activeCfg.serverreward.cardGet[3][1]
                table.insert(newpool,rate1)
                local rate2 = rate1 + activeCfg.serverreward.cardGet[3][2]
                table.insert(newpool,rate2)

                for k,v in pairs(newpool) do
                    if rd <= v then
                        index = k
                        break
                    end 
                end

                if index>0 then
                    cardget = activeCfg.serverreward.cardGet[1][index]
                end
            end

            if next(cardget) then
                reward[cardget[1]] = cardget[2]
                self.info[aname][cardget[1]] = (self.info[aname][cardget[1]] or 0) + cardget[2]
            end
        elseif params.act =='login' then
            -- 没有确定身份(流失/活跃)时,需要设置(1为流失2为活跃用户)
            if not self.info[aname].u then
                -- 新用户上次登录时间为0,与当前时间相减一定会超过配置的流失时间
                local ts = getClientTs()
                if params.lastLoginTs < 1000 then params.lastLoginTs = ts end

                if (ts - params.lastLoginTs) > (activeCfg.lastLogin * 86400) then
                    self.info[aname].u = 1 -- 流失玩家
                else
                    self.info[aname].u = 2 -- 流活跃玩家
                end
            end
        elseif params.act == 'useprop' then
            local propCfg = getConfig('prop')
            local pid = params.pid
            local cfg = propCfg[pid]
           
            for k,v in pairs(cfg.useGetActive[2]) do
                reward[v[1]] = v[2]*params.num
                self.info[aname][v[1]] = (self.info[aname][v[1]] or 0) + v[2]*params.num
            end
        end

        -- 为活跃用户分配一个唯一的邀请码
        if self.info[aname].u == 2 and not self.info[aname].ic then
            local code = getUserInviteCode(self.uid)
            if code then self.info[aname].ic = code end
        end

        return reward
    end

    -- 橙配馈赠
    function self.cpkz(aname,params)
        if aname==nil or params==nil then  return false end

        local activeCfg = self.getActiveConfig(aname)
        if type(self.info[aname].charge) ~='table' then
            self.info[aname].charge = {}
            local items = table.length(activeCfg.serverreward.rechargeNum)
            for i=1,items do
                table.insert(self.info[aname].charge,0)
            end
        end

        self.info[aname].gem = (self.info[aname].gem or 0) + params.num
        for k,v in pairs(activeCfg.serverreward.rechargeNum) do
            if self.info[aname].charge[k]==0 and self.info[aname].gem>=v then
                self.info[aname].charge[k]=1
            end
        end
    end

    -- 武器研发
    function self.wqyf(aname,params)
        if not self.info[aname].g then
            self.info[aname].g = 0
        end
        self.info[aname].g=(self.info[aname].g or 0)+params.num
    end

    -- 啤酒节
    function self.beerfestival(aname,params)
        local resource = {}
        if params.act =='charge' then
            self.info[aname].gems=(self.info[aname].gems or 0)+params.num
        else
            local activeCfg = self.getActiveConfig(aname)
            if type(self.info[aname].beer)~='table' then
                self.info[aname].beer={}--初始化
                --每层领取状态 层数默认为下标
                for i=1,#activeCfg.stages do
                    table.insert(self.info[aname].beer,{0,0})
                end

                self.info[aname].t1 = 0 -- 酒花
                self.info[aname].t2 = 0 -- 麦芽
                self.info[aname].f = 0 -- 最终大奖领取状态  0未领取 1已领取
                self.info[aname].fb = 0 -- facebook分享
            end
            -- 获取材料    
            -- Rate1={10,0},   --攻打关卡获得概率
            -- Rate2={10,0},   --补给线获得概率
            -- Rate3={15,0},   --装备探索获得概率
            -- Rate4={0,6},    --攻击基地获得概率
            -- Rate5={0,10},   --攻打海盗获得概率
            -- Rate6={0,10},   --攻打剧情关卡获得概率
            if table.contains({"Rate1","Rate2","Rate3","Rate4","Rate5","Rate6"},params.act) then
                local rate = activeCfg[params.act]
                for k,v in pairs(rate) do
                    if rate[k]>0 and params.num>0 then
                        for i=1,params.num do
                            setRandSeed()
                            local rd=rand(1,100)
                            if rd<=rate[k] then
                                self.info[aname]['t'..k] = (self.info[aname]['t'..k] or 0) + 1
                                resource['t'..k] = (resource['t'..k] or 0) + 1
                            end
                        end
                    end
                end

            end
        end

        return resource
    end

    -- 军团分享
    function self.allianceshare(aname,params)
        if aname==nil or params==nil or params.num<=0 then  return false end

        local ts= getClientTs()
        local activeCfg = self.getActiveConfig(aname)
        local max = #activeCfg.serverreward.cost

        local item = 0
        for i=max,1,-1 do
            if params.num>=activeCfg.serverreward.cost[i] then
                item = i
                break
            end
        end
        if item==0 then return false end

        if type(self.info[aname].charge)~='table' or not next(self.info[aname].charge) then
            self.info[aname].charge = {}
            for i=1,max do
                table.insert(self.info[aname].charge,0)
            end
        end

        if params.allianceId==nil or params.allianceId==0 then
             self.info[aname].charge[item] = self.info[aname].charge[item]+1
             return true
        end
        -- 创建礼包
        local flagid = params.allianceId.."_"..ts
        local redkey = "zid."..getZoneId().."."..aname.."ts"..self.info[aname].st.."_"..flagid
        local redis = getRedis()
        local gnum = activeCfg.serverreward.shareNum[item]
        redis:hset(redkey,'num',gnum)
        local info = {
            id = flagid,
            sender = self.uid,
            uname = params.username,
            allianceId =  params.allianceId,
            allianceName = params.allianceName,
            item = item,
            ulist = {},
            nu = gnum ,
            ts = ts,
        }
        local data = json.encode(info)
        redis:hset(redkey,'info',data)
        redis:expireat(redkey,ts+86400*5)-- 保留两天
        
        self.info[aname].charge[item] = self.info[aname].charge[item]+1

        local senddata = {ginfo = info}
        regSendMsg(self.uid,'allianceshare.gift',senddata)
    end

    -- 异星任务
    function self.alientask(aname,params)
        if aname==nil or params==nil then  return false end
        local activeCfg = self.getActiveConfig(aname)
        if type(self.info[aname].task)~='table' or not next(self.info[aname].task) then
            self.info[aname].task={}
            for k,v in pairs(activeCfg.serverreward.taskList) do
                --index任务下标  r:-0未完成、1可领取、2已领取 p 进度 1,2,3 cur：当前值 con:完成条件
                self.info[aname].task[k]={index=v[1].index,r=0,p=1,cur=0,con=v[1][1]}
            end
            self.info[aname].ea=0--可领取的任务额外奖励数
            self.info[aname].er=0--已领取的个数
        end

        local keys=table.keys(self.info[aname].task)
        if table.contains(keys,params.t) and params.w==1 then
            if self.info[aname].task[params.t].r==0 then
                if table.contains({'y1','y2','y3'},params.t) then
                    self.info[aname].task[params.t].cur=self.info[aname].task[params.t].cur+params.n
                else
                    if params.p==self.info[aname].task[params.t].con[1] then
                        self.info[aname].task[params.t].cur=self.info[aname].task[params.t].cur+params.n
                    end
                end
            end
        end

        -- 更新任务状态
        local taskCfg=activeCfg.serverreward.taskList
        for k,v in pairs(self.info[aname].task) do
            local info=taskCfg[k][v.p]
            if v.r==0 then
                -- 参数为一个
                if table.contains({'y1','y2','y3'},k) then
                    if self.info[aname].task[k].cur>=info[1][1] then
                        self.info[aname].task[k].r=1
                    end
                else--参数为两个
                   if self.info[aname].task[k].cur>=info[1][2] then
                        self.info[aname].task[k].r=1
                    end
                end

                --每种类型任务链都完成可以领取奖励数记录
                if self.info[aname].task[k].r==1 and not info.next then
                    self.info[aname].ea=(self.info[aname].ea or 0)+1
                end
            end
        end

    end

    --点亮铁塔
    function self.lighttower(aname,params)
        if params.act==nil then return true end
        local activeCfg = self.getActiveConfig(aname)
        local st = self.info[aname].st or 0
        local ts= getClientTs()
        local weeTs=getWeeTs()
        local currDay = math.floor(math.abs(ts-getWeeTs(st))/(24*3600)) + 1;

        if params.act=='charge' and currDay<=3 and params.num>0 then
            local chargeinfo=activeCfg.serverreward.recharge[currDay]
            if type(self.info[aname].sh)~='table' then
                self.info[aname].sh={}
                --充值
                self.info[aname].sh.c={g=0,r={0,0}}--g累计充值钻石 r[1]每日充值任意钻石  r[2]累计充值 0未领取 1 可领取 2已领取
            end

            if self.info[aname].t < weeTs then
              self.info[aname].t = weeTs
              --重置每日充值任务
                self.info[aname].sh.c={g=0,r={0,0}}
            end

            self.info[aname].sh.c.g=self.info[aname].sh.c.g+params.num
            -- 充值任意金额
            if  self.info[aname].sh.c.r[1]==0 then
                self.info[aname].sh.c.r[1]=1
            end
            --每日累计充值
            if self.info[aname].sh.c.r[2]==0 then
                if self.info[aname].sh.c.g>=chargeinfo[2][1] then
                    self.info[aname].sh.c.r[2]=1
                end
            end
        else
            if type(self.info[aname].tw)~='table' then return false end
            if params.act==self.info[aname].tw.tk.ty and self.info[aname].tw.tk.r==0 then
                self.info[aname].tw.tk.cu=(self.info[aname].tw.tk.cu or 0)+params.num
                -- 如果完成任务  则更新玩家个人的贡献值 和全服的贡献值
                if self.info[aname].tw.tk.cu>=self.info[aname].tw.tk.con then
                    self.info[aname].tw.tk.r=1
                end
            end
        end
    end

    -- 粽子作战
    function self.zongzizuozhan(aname,params)
        if not next(params) then
            return nil
        end
        if params.action=='log' then
            self.info[aname].bt=(self.info[aname].bt or 0) +params.num
            return true
        end

        local activeCfg = self.getActiveConfig(aname)
        local ma=activeCfg.getMaterial
       
        if type(self.info[aname].m)~='table' then
            self.info[aname].m={}
            for k,v in pairs(ma) do
                self.info[aname].m[v.get[1]]=0
            end
            self.info[aname].g=0--多余充值钻石
            self.info[aname].cg=0--多余消耗钻石
            self.info[aname].tg=0--总充值
            self.info[aname].tcg=0-- 总消耗
        end
        local gm=activeCfg.getMaterial[params.e]
        if params.e=='a' then --充值
           self.info[aname].g=(self.info[aname].g or 0) +params.num
           self.info[aname].tg=(self.info[aname].tg or 0)+params.num
           params.num=self.info[aname].g
        elseif params.e=='b' then --消耗
            self.info[aname].cg=(self.info[aname].cg or 0) + params.num
             self.info[aname].tcg=(self.info[aname].tcg or 0)+params.num
            params.num=self.info[aname].cg
        end

        local reward={}
        if params.num>=gm.num then
            local m=math.floor( params.num/gm.num)
            if params.e=='a' then
                self.info[aname].g=params.num%gm.num
            elseif params.e=='b' then
                self.info[aname].cg=params.num%gm.num
            end

            for i=1,m do
                setRandSeed()
                local rd=rand(1,10)
                if rd/10<=gm.rate then
                     self.info[aname].m[gm.get[1]]=(self.info[aname].m[gm.get[1]] or 0)+gm.get[2]
                     reward[aname..'_'..gm.get[1]]=(reward[aname..'_'..gm.get[1]] or 0)+gm.get[2]
                end                
            end
        end

        if params.e~='a' then -- 除充值 发推送
            local senddata = {zongzizuozhan= self.info[aname]}
            regSendMsg(params.u,'active.change',senddata)
        end
    
        return reward

    end



   -- 悬赏任务
   function self.xuanshangtask(aname,params)
        local function gettask(taskpool,probability)
            local randSeed = {}
            if type(probability) == 'table' then
                for k,v in pairs(probability) do
                    for i=1,v do
                        table.insert(randSeed,k)
                    end                
                end
            end

           local k = rand(1,#randSeed)
           return taskpool[randSeed[k]]
        end

        -- 每日重置
        local weeTs = getWeeTs()
        if self.info[aname].t < weeTs then
            self.info[aname].rn = 0
            self.info[aname].t = weeTs
        end   
        local activeCfg = self.getActiveConfig(aname)
        -- 初始化或重置
        if type(self.info[aname].tk)~='table' or params.t=='init'  then
           self.info[aname].tk={}--任务列表
           local temp={}
           local  i=1
           while i<= activeCfg.taskNum do  
               setRandSeed()
               key=gettask(activeCfg.randompool[1],activeCfg.randompool[2])
               local flag=table.contains(temp, key)
               if not flag then
                    setRandSeed()
                    local taskpool=activeCfg.randtaskpool[key]
                    local index=rand(1,#taskpool)
                    local taskid=taskpool[index]
                    local task={index=taskid,s=1,n=0}--index 任务编号，s领取状态 1未领取 2可领取 3已领取 n进度
                    self.info[aname].tk[key]=task
                    table.insert(temp,key)
                    i=i+1
               end
           end
           self.info[aname].f=0--当前任务完成个数
           --重置次数
           if params.t=='init' then
              self.info[aname].rn=(self.info[aname].rn or 0)+1
           end 
           self.info[aname].xsgold=self.info[aname].xsgold or 0--悬赏金 重置任务时 悬赏金不重置
        end

        if type(self.info[aname].shop)~='table' then
            self.info[aname].shop={}
            for k,v in pairs(activeCfg.serverreward.shopList) do
                local item={index=k,n=0}
                self.info[aname].shop['i'..k]=item
            end
        end
        -- 判断当前任务是否需要记录
        local tasktypes=table.keys(self.info[aname].tk)
        if table.contains(tasktypes,params.e) then
            local taskCfg = activeCfg.serverreward.tasklist[self.info[aname].tk[params.e].index]
            self.info[aname].tk[params.e].n=self.info[aname].tk[params.e].n+params.n
            if self.info[aname].tk[params.e].n>=taskCfg.num and self.info[aname].tk[params.e].s==1 then
                self.info[aname].tk[params.e].s=2
                self.info[aname].tk[params.e].n=taskCfg.num
            end
        end

        return self.info[aname]
   end

   --老玩家回归（德国）
   function self.userreturn(aname,params)
        if params.regdate>=self.info[aname].st then
            return true
        end

        local curtime=getClientTs()
        local lasttime=getWeeTs(params.logindate)
        local dif=math.ceil((curtime-lasttime)/86400)-1
        local activeCfg = self.getActiveConfig(aname)
        local viplimit = activeCfg.vipLimit  or 0

        if dif>=activeCfg.lastLogin and activeCfg.levelLimit<=params.level and params.vip>=viplimit then
            self.info[aname].c=1
            self.info[aname].t=params.logindate
        end

   end

   -- 猎杀潜航
   function self.silentHunter(aname,params)
       if params.action==nil then return true end

       if params.action=='charge' then
           if type(self.info[aname].charge)~='table' then
               self.info[aname].charge = {}
               self.info[aname].charge.g = 0 -- 累计充值钻石数
               self.info[aname].charge.t = 0 -- 领取奖励次数
           end
           self.info[aname].charge.g = self.info[aname].charge.g + params.num
       else
           -- 其他任务
           if type(self.info[aname].tk)~='table' then
               self.info[aname].tk = {}
           end

           -- 攻打矿点 判断是否有潜艇参与
           if params.action=='ps' then
               local tankCfg = getConfig('tank')
               local qtFlag =0
               if next(params.troops) then
                   for k,v in pairs(params.troops) do
                       if next(v) and tankCfg[v[1]].type==2 then
                           qtFlag=1
                           break
                       end
                   end
               end
               if qtFlag==0 then params.num=0 end
           elseif params.action=='at' and params.type~='t2' then --进行X次潜艇配件的强化
               params.num=0
           elseif  params.action=='rt' and params.type~=2 then --升级X次常规潜艇相关异星科技
               params.num=0
           end
           if params.num>0 then
               if type(self.info[aname].tk[params.action])~='table' then
                   self.info[aname].tk[params.action] = {}
                   self.info[aname].tk[params.action].n = 0
                   self.info[aname].tk[params.action].r = 0 -- 未完成 1 可领取 2 已领取
               end
               -- 拥有某种潜艇数量任务
               if params.action=='du' then
                   if params.num>self.info[aname].tk[params.action].n then
                       self.info[aname].tk[params.action].n =params.num
                   end
               else
                   self.info[aname].tk[params.action].n = self.info[aname].tk[params.action].n+params.num
               end

               -- 更新任务状态
               local activeCfg = self.getActiveConfig(aname)
               local taskCfg = activeCfg.taskList[params.action]
               if self.info[aname].tk[params.action].r <1 and self.info[aname].tk[params.action].n>=taskCfg.num then
                   self.info[aname].tk[params.action].r = 1
               end
           end
       end

       return true
   end
    
    -- 无限火力
    function self.luckcard(activeName,params)
        local ts=getClientTs()
        for k,v in  pairs (self.info)  do
            local acname=k
            acname = acname:split('_')
            acname=acname[1]
            if acname==activeName  and tonumber(v.et)>=ts  then
                local activeCfg = self.getActiveConfig(k)
                if table.contains(activeCfg.nextRequire,params.aid) then
                    return activeCfg.value,activeCfg.nextRequire
                end
            end
        end
    end

    -- 绑定类 限时商店活动
    function self.bindrestricted(aname, params)
        local activeCfg = getConfig("active")
        --活动由单份配置改为多份配置 cfg后台选择的配置编号
        if self.info[aname].cfg and activeCfg[aname][self.info[aname].cfg] then
            activeCfg[aname] = activeCfg[aname][self.info[aname].cfg]
        end
        
        local uobjs = getUserObjs(self.uid)
        local mUserinfo = uobjs.getModel('userinfo')
        
        -- 不在活动期间内
        local regDays =  ((getWeeTs() - getWeeTs(mUserinfo.regdate)) / 86400) + 1
        if regDays < activeCfg[aname].bindTime[1] or regDays > activeCfg[aname].bindTime[2] then
            return nil
        end 
        
        -- 需要重置
        if not tonumber(self.info[aname].t) or tonumber(self.info[aname].t) < getWeeTs() then
            self.info[aname].t = getWeeTs()
            self.info[aname].v = {}
        end

        -- 折扣值
        local disN = activeCfg[aname].props[params.pid]

        -- 购买次数有限制
        if disN and (self.info[aname].v[params.pid] or 0) < activeCfg[aname].maxCount[params.pid] then
            local disGems = math.ceil(params.gems * disN)
            if disGems > 0 then
                self.info[aname].v[params.pid] = (self.info[aname].v[params.pid] or 0) + 1
                return disGems
            end
        end

        return nil
    end
    
    --春节攀升计划活动
    function self.chunjiepansheng(aname, params)
        local activeCfg = self.getActiveConfig(aname)
        local ts = getClientTs()
        local weeTs = getWeeTs(ts)
        local send = 0
        local save = true
        local st = self.info[aname].st or 0
        local currDay = math.floor(math.abs(ts-getWeeTs(st))/(24*3600)) + 1;
    
        if not activeCfg.taskList or type(activeCfg.taskList) ~= 'table' or currDay > #activeCfg.taskList then
            writeLog('dayerror-currDay='..currDay..'-'..ts..'-'..self.uid..'-'..json.encode(params),'chunjiepansheng')
            return true
        end

        if params.action then
            local action = tostring(params.action)
            local haveTask = false
            
            -- 检测action是否在今天的任务列表中
            for i,v in pairs(activeCfg.taskList[currDay]) do
                if type(v) == 'table' and v[1] and v[1][1] and v[1][1] == action then
                    haveTask = true
                end
            end

            if haveTask then
                if not self.info[aname].day then
                    self.info[aname].day = {}
                end
                
                if not self.info[aname].day['d'..currDay] then
                    self.info[aname].day['d'..currDay] = {}
                end
                
                if not self.info[aname].day['d'..currDay].tk then
                    self.info[aname].day['d'..currDay].tk = {}
                end
                
                if not params.set then
                    self.info[aname].day['d'..currDay].tk[action] = (self.info[aname].day['d'..currDay].tk[action] or 0) + (params.num or 1)
                else
                    local actionSet = tonumber(params.set) or 0
                    if action == 'mc' then
                        -- 通过额外变量记录连胜状态
                        local mc = self.info[aname].day['d'..currDay].tk.mc or 0
                        local md = self.info[aname].day['d'..currDay].tk.md or 0
                        local tmp = math.floor(actionSet / 5)

                        if tmp > md then
                            mc = mc + (tmp - md)
                            md = tmp
                            
                            self.info[aname].day['d'..currDay].tk.mc = mc
                            self.info[aname].day['d'..currDay].tk.md = md
                        else
                            if tmp <= 0 then
                                self.info[aname].day['d'..currDay].tk.md = 0
                            end
                        end

                        -- 第一版 只记录最高连胜
                        -- if not self.info[aname].day['d'..currDay].tk[action] or self.info[aname].day['d'..currDay].tk[action] < actionSet then
                            -- self.info[aname].day['d'..currDay].tk[action] = actionSet
                        -- end
                    elseif action == 'we' then
                        if not self.info[aname].day['d'..currDay].tk[action] or (tonumber(self.info[aname].day['d'..currDay].tk[action]) or 0) < actionSet then
                            self.info[aname].day['d'..currDay].tk[action] = actionSet
                        else
                            writeLog('5-currDay='..currDay..'-'..ts..'-'..self.uid..'-'..json.encode(params),'chunjiepansheng')
                        end
                    else
                        self.info[aname].day['d'..currDay].tk[action] = actionSet
                    end
                end
                save = true
            else
                writeLog('notaskerror-currDay='..currDay..'-'..ts..'-'..self.uid..'-'..json.encode(params),'chunjiepansheng')
            end
        else
            writeLog('noactionerror-params='..json.encode(params)..'-'..self.uid,'chunjiepansheng')
        end
        
        if save then
            local data = {[aname] = self.info[aname]}
            regSendMsg(self.uid,'active.change',data)
        end
    end
    
    --获取年兽信息
     function self.getEvaInfo(activeName,bossCfg)
        local data={}
        local redis  = getRedis()
        local weet=self.info[activeName].st
        local bosskey= "zid."..getZoneId()..activeName..".diehp.ts."..weet
        local levelkey= "zid."..getZoneId()..activeName..".level.ts."..weet
        local landformkey= "zid."..getZoneId().."worldboss.landform.ts."..weet
        local killkey   = "zid."..getZoneId()..activeName..".kill"..weet
        local killtime   = "zid."..getZoneId()..activeName..".lastkill.ts"..weet
        local updatetime   = "zid."..getZoneId()..activeName..".lastupdate.ts"..weet
        -- 获取今天boss的等级
        local expiretime=self.getActiveCacheExpireTime(activeName)
        local ts = getClientTs()
        local level =tonumber(redis:get(levelkey))
        local lastkilltime =tonumber(redis:get(killtime)) or 0
        if level==nil  or  (lastkilltime>0 and ((ts-lastkilltime) > bossCfg.revivetime) )  then
            local killcount =tonumber(redis:get(killkey))
            if killcount ==nil then
                local killinfo =getFreeData(killkey)
                if killinfo==nil then
                    --setFreeData(killkey,0)
                    redis:set(killkey,0)
                    killcount=0
                else
                    if type(killinfo)=='table' and next(killinfo) then
                        killcount=tonumber(killinfo.info)
                        redis:set(killkey,killcount)
                    end
                end

            end
            level =bossCfg.level+killcount
            redis:set(levelkey,level)
            redis:del(killtime)
            redis:del(bosskey)   
            redis:expire(levelkey,expiretime)
            redis:del(landformkey)
        end
        local landform=tonumber(redis:get(landformkey))
        if landform==nil then
            setRandSeed()
            landform = rand(1,6)
            redis:set(landformkey,landform)
            redis:expire(landformkey,expiretime)
        end
        local diehp=tonumber(redis:get(bosskey)) or 0
        local tolhp=bossCfg.getEvaHp(level)
        if diehp>=tolhp and lastkilltime<=0 then
            lastkilltime=ts
            redis:set(killtime,ts)
            redis:expire(killtime,expiretime)
        end
        return {level,tolhp,diehp,landform,lastkilltime}
        
    end
    
    -- 干死boss的血量相加
    function self.addEvaHp(activeName,point)
        local weet=self.info[activeName].st
        local bosskey= "zid."..getZoneId()..activeName..".diehp.ts."..weet
        local redis  = getRedis()
        local hp=tonumber(redis:incrby(bosskey,point))
        redis:expireat(bosskey,self.info[activeName].et+172800)    
        return hp,hp-point

    end

    -- 干死boss 等级+1
    function self.killEva(activeName,item)
        local weet=self.info[activeName].st
        local ts = getClientTs()
        local killkey   = "zid."..getZoneId()..activeName..".kill"..weet
        local killtime   = "zid."..getZoneId()..activeName..".lastkill.ts"..weet
        local redis  = getRedis()
        local killcout =tonumber(redis:incr(killkey)) or 0
        getFreeData(killkey)
        setFreeData(killkey,killcout)
        redis:set(killtime,ts)
        redis:expireat(killtime,self.info[activeName].et+172800)
        redis:expireat(killkey,self.info[activeName].et+172800)

        local mailType = (tonumber(self.info[activeName].cfg) or 0) > 1 and 60 or 44
        local ret=MAIL:sentSysMail(ts,self.info[activeName].et ,mailType,json.encode({type=mailType}),1,2,item,1)     
        return true
    end

    function self.setMaxDieHpEva(activeName,hp)
        local weet=self.info[activeName].st
        local ts = getClientTs()
        local redis  = getRedis()
        local killhp   = "zid."..getZoneId()..activeName..".killMaxHp"..weet
        local maxhp =tonumber(redis:get(killhp))
        if maxhp==nil or maxhp<hp then
            redis:set(killhp,hp)
            redis:expireat(killhp,self.info[activeName].et+172800)
            return true
        end
        return false
    end

    function self.getMaxDieHpEva(activeName)
        local weet=self.info[activeName].st
        local ts = getClientTs()
        local redis  = getRedis()
        local killhp   = "zid."..getZoneId()..activeName..".killMaxHp"..weet
        local maxhp =tonumber(redis:get(killhp)) or 0
        return maxhp
    end
    
    --攻击boss
    function self.Evabattle(fleetInfo,aheros,boss,activeCfg,equip)
         --  初始化攻击方 
        local attactBossBuff=self.info.b
        local auobjs = getUserObjs(self.uid)         
        local attackFleet = auobjs.getModel('troops')
        local aSequip = auobjs.getModel('sequip')
        local aBadge = auobjs.getModel('badge')

        local aFleetInfo,aAccessory,aherosInfo = attackFleet.initFleetAttribute(fleetInfo,nil,{hero=aheros,attactBossBuff=attactBossBuff,landform=tonumber(boss[4]), equip=equip})

        local bossCfg = getConfig("active/newyeareva");
        local baseTroop = {{"a99998",1},{},{},{},{},{}}
        --techs,skills,propSlots,allianceSkills,battleType,params
        local bossFleetInfo = initTankAttribute(baseTroop,nil,nil,nil,nil,nil,{landform=tonumber(boss[4])})
        local bossActiveHp = boss[2]- boss[3] -- boss当前血量

        bossFleetInfo[1].anticrit = bossCfg.getEvaArmor(boss[1])
        bossFleetInfo[1].evade = bossCfg.getEvaDodge(boss[1])
        bossFleetInfo[1].armor = bossCfg.getEvaDefence(boss[1])
        bossFleetInfo[1].maxhp = bossActiveHp
        bossFleetInfo[1].hp = bossActiveHp
        bossFleetInfo[1].bossHp = boss[2]   -- 总血量
        bossFleetInfo[1].boss = 1

        local copyTable = copyTable
        for i=2,6 do
            bossFleetInfo[i] = copyTable(bossFleetInfo[1])
        end

        require "lib.battle"
        local report={}
        local deBossHp={}
        report.d,deBossHp = battle(aFleetInfo,bossFleetInfo,0,nil,{boss=true,diePaoTou=activeCfg.paotou,})
        report.t = {baseTroop,fleetInfo}
        report.h = {{},aherosInfo[1]}
        report.se = {0, aSequip.formEquip(equip)}
        report.badge = {{0,0,0,0,0,0}, aBadge.formBadge()} --徽章数据
        
        return  report,deBossHp
    end
    
    function self.yunshiyelian(activeName, params)
        local push = false
        local weeTs = getWeeTs()
        local lastTs = self.info[activeName].t or 0
        local activeCfg = self.getActiveConfig(activeName)
        
        -- 是否隔天刷新
        if weeTs > lastTs then
            local task = {}
            -- 随机任务
            for _,value in pairs(activeCfg.changedTask) do
                local tmp={value.key, 0}
                table.insert(task,tmp)
            end 
            
            self.info[activeName].tr = task
            self.info[activeName].f = 0
            self.info[activeName].t = weeTs
        end
        
        -- 获取任务配置
        local taskCfg
        for _,tvalue in pairs(activeCfg.changedTask) do
            if tvalue.key == params.action then
                taskCfg = tvalue
            end
        end
        
        -- 任务状态更新
        for k,v in pairs (self.info[activeName].tr) do
            local num=v[2] or 0
            if v[1] == params.action and num ~= -1 and num < taskCfg.needNum then
                push = true
                self.info[activeName].tr[k][2] = (self.info[activeName].tr[k][2] or 0) + (params.num or 1)
            end
        end
        
        -- 推送
        if push then
            local adata = {[activeName] = self.info[activeName]}
            regSendMsg(self.uid, 'active.change', adata)
        end
    end
    
    -- 全线突围
    function self.qxtw(activeName,params)
        local weeTs = getWeeTs()
        local lastTs = self.info[activeName].t or 0
        if weeTs > lastTs then
            self.info[activeName].t=weeTs
            self.info[activeName].c=0
            self.info[activeName].tk={}
            self.info[activeName].tr={}
        end
        
        local activeCfg = self.getActiveConfig(activeName)
        if activeCfg.dailyTask[params.action]~=nil then
            if (self.info[activeName].tk['t'..params.action] or 0)>=activeCfg.dailyTask[params.action].needNum then
                return true
            end
            self.info[activeName].tk['t'..params.action]=(self.info[activeName].tk['t'..params.action]or 0)+(params.num or 1)
            if self.info[activeName].tk['t'..params.action]>activeCfg.dailyTask[params.action].needNum then
                self.info[activeName].tk['t'..params.action]=activeCfg.dailyTask[params.action].needNum
            end
            local data = {[activeName] =self.info[activeName]}
            regSendMsg(self.uid,'active.change',data)
        end
        
    end
    
    -- 限时尖端配件活动
    function self.limitdiscount(aname, params)
        if type(self.info[aname].t) ~= 'table' then
            self.info[aname].t = {}
        end

        local activeCfg = self.getActiveConfig(aname)

        -- 折扣值
        local disN = activeCfg.props[params.pid]

        -- 购买次数有限制
        if disN and (self.info[aname].t[params.pid] or 0) < activeCfg.maxCount[params.pid] then
            local disGems = math.floor(params.onegem * disN) * params.num
            if disGems > 0 then
                self.info[aname].t[params.pid] = (self.info[aname].t[params.pid] or 0) + params.num
                return disGems
            end
        end

        return nil
    end
    
    -- 国庆节活动
    function self.nationalDay(activeName, params)
        local push = false
        local actCfg = self.getActiveConfig(activeName)
        local weeTs = getWeeTs()

        local uobjs = getUserObjs(self.uid)
        local mUserinfo = uobjs.getModel('userinfo')
        
        if 'challenge' == params.action then    -- 关卡掉落
            -- 验证玩家等级
            if mUserinfo.level < actCfg.equipOpenLevel then
                return params.reward
            end
        
            local dropCfg = actCfg.serverreward.drop
            
            setRandSeed()
            local rndNum = math.random(1, 100)
            local hitRnd = dropCfg.dropRate * 100
            -- 有掉落
            if rndNum <= hitRnd then
                local reward = {}
                local key = dropCfg.dropReward[1]
                local value = dropCfg.dropReward[2]
                reward[key] = reward[key] or 0
                reward[key] = reward[key] + (tonumber(value) or 0)
                
                -- 发奖励
                takeReward(self.uid, reward)
                reward = formatReward(reward)
                
                -- 结果合并
                if params.reward.p then
                    for k,v in pairs(reward.p) do
                        params.reward.p[k] = params.reward.p[k] or 0
                        params.reward.p[k] = params.reward.p[k] + v
                    end
                else 
                    params.reward.p = reward.p
                end
            end
            
            return params.reward
        else    -- 任务触发
            -- 验证玩家等级
            if mUserinfo.level < actCfg.equipOpenLevel then
                return 
            end
            
            -- 初始化数据 隔天刷新
            local flag = false
            if type(self.info[activeName].tk) ~= 'table' then -- 首次初始化
                flag = true
            elseif not tonumber(self.info[activeName].t) or tonumber(self.info[activeName].t) >= 1475164800 then -- 客户端未调初始化 || 当天不需要初始化
                if not tonumber(self.info[activeName].t1) or tonumber(self.info[activeName].t1) < weeTs then -- 隔天需要初始化
                    flag = true
                end
            end 

            if flag == true then
                local task = {}
                -- 随机任务
                for _,value in pairs(actCfg.task) do
                    local tmp={value.key, 0}
                    table.insert(task,tmp)
                end                             

                self.info[activeName].tk = task
                self.info[activeName].t1 = weeTs
            end

            -- 任务触发埋点
            if type(self.info[activeName].tk)=='table' then
                -- 获取任务配置
                local taskCfg
                for _,tvalue in pairs(actCfg.task) do
                    if tvalue.key == params.action then
                        taskCfg = tvalue
                    end
                end
                
                -- 任务状态更新
                for k,v in pairs (self.info[activeName].tk) do
                    local num=v[2] or 0
                    if v[1] == params.action and num ~= -1 and num < taskCfg.needNum then
                        push = true
                        self.info[activeName].tk[k][2] = (self.info[activeName].tk[k][2] or 0) + (params.num or 1)
                    end
                end
            end
        end
        
        -- 推送
        if push then
            local adata = {[activeName] = self.info[activeName]}
            regSendMsg(self.uid, 'active.change', adata)
        end
    end

    --不给糖就捣乱
    function self.halloween(activeName,params)
        --ptb:p(params)
        -- 充值
        local push=false
        local reward=nil
        if params.num~=nil and params.num>0 then
            local weeTs = getWeeTs()
            local ts=self.info[activeName].ts or 0
            if weeTs~=ts then
               self.info[activeName].dc=(self.info[activeName].dc or 0 )+1
            end
            self.info[activeName].ts=weeTs
            self.info[activeName].num=(self.info[activeName].num or 0 )+params.num
            push=true
        end
        
        if params.at~=nil or  params.ar~=nil then
            local cfg=self.getActiveConfig(activeName)
            setRandSeed()
            local rate=0
            if params.at~=nil then
                rate=cfg.atRate
            end
            if params.ar~=nil then
                rate=cfg.arRate
            end
            local seed = rand(1, 100)
            if seed <= rate then
                push=true
                if type(self.info[activeName].tg)~='table' then  self.info[activeName].tg={} end
                reward=getRewardByPool(cfg.serverreward.apool)
                for  k,v in pairs (reward) do
                    self.info[activeName].tg[k]=(self.info[activeName].tg[k] or 0)+v
                end
            end

        end

        if params.sw~=nil and  params.sw>=0 then
            push=true
            self.info[activeName].sw=(self.info[activeName].sw or 0 )+1
        end

        if push then
            local data = {[activeName] = self.info[activeName]}
            regSendMsg(self.uid,'active.change',data)
        end
        return reward
    end
    
    -- 累计消费活动
    function self.leijixiaofei(aname, params)
        local actinfo   = self.info[aname]
        local actCfg    = self.getActiveConfig(aname)
        local push      = false
        
        -- 初始化
        if not actinfo or type(actinfo) ~= 'table' or 0 == actinfo.c then
            actinfo.rn      = 0 -- 总消费值
            actinfo.rk      = 0 -- 排行榜奖励是否领取
            actinfo.r       = {} -- 普通档次奖励领取信息
            actinfo.c       = 1
        end
        
        -- 增加消费值
        if tonumber(params.value) and tonumber(params.value) > 0 then
            push = true
            -- 累计消费值
            actinfo.rn = actinfo.rn or 0
            actinfo.rn = actinfo.rn + tonumber(params.value)
            
            -- 如果达到进入排行榜的限制，则需要更新排行榜
            if (actinfo.rn or 0) >= actCfg.costLimit then
                setActiveRanking(uid, actinfo.rn, aname, actCfg.listLimit, actinfo.st, actinfo.et)
            end
        end
        
        self.info[aname] = actinfo

        -- 数据推送
        if push then
            local acdata = {[aname] = self.info[aname]}
            regSendMsg(self.uid, 'active.change', acdata)
        end
    end

    -- 中秋赏月
    function self.midautumn(activeName,params)
        local ts = getClientTs()
        local weeTs = getWeeTs()
        local last=self.info[activeName].t or 0
        local push=false
        if last<weeTs then
            self.info[activeName].v=0 --每天的充值金币
            self.info[activeName].c=0 --每天充值礼包礼包
            self.info[activeName].t=weeTs
            self.info[activeName].tk=nil
            self.info[activeName].r=nil
        end
        -- 充值金币
        local reward=nil
        if params.action=="gb" then
            push=true
            self.info[activeName].v=self.info[activeName].v+(params.num or 0)
        else
            if type(self.info[activeName].tk)=='table' then
                for k,v in pairs (self.info[activeName].tk) do
                    local num=v[4] or 0
                    if v[1]==params.action and num~=-1 and num<v[3] then
                        push=true
                        self.info[activeName].tk[k][4]=(self.info[activeName].tk[k][4] or 0) +(params.num or 1)
                    end
                end
            end
            -- --攻打叛军得奖励
            -- if params.action=='fa' and tonumber(params.pic)==100 then
            --     local activeCfg = self.getActiveConfig(activeName)
            --     setRandSeed()
            --     local seed = rand(1, 100)
            --     if seed<=activeCfg.getRatio then
            --         takeReward(uid,activeCfg.getProp[1])
            --         reward=activeCfg.getProp[2]
            --     end
            -- end
        end

        if push then
            local data = {[activeName] = self.info[activeName]}
            regSendMsg(self.uid,'active.change',data)
        end
        return reward
    end
    
    -- 开年大吉
    function self.openyear(activeName,params)
        local weeTs = getWeeTs()
        local lastTs = self.info[activeName].t or 0
        if weeTs > lastTs then
            self.info[activeName].dt ={}
            self.info[activeName].t=weeTs
            self.info[activeName].v=0
            self.info[activeName].c=0
            self.info[activeName].df={}
            self.info[activeName].rf={}
            self.info[activeName].f=0
            self.info[activeName].ff={}
        end

        if params.action=="gb" then
            self.info[activeName].v=self.info[activeName].v+params.num
        else
            if params.action=="we" then
                if params.set~=nil then
                    if self.info[activeName].dt[params.action] or 0<params.set then
                        self.info[activeName].dt[params.action]=params.set
                    end
                else
                    self.info[activeName].dt[params.action]=(self.info[activeName].dt[params.action] or 0) +(params.num or 1)
                end
            else
                self.info[activeName].dt[params.action]=(self.info[activeName].dt[params.action] or 0) +(params.num or 1)
            end
           
        end
        local data = {[activeName] = self.info[activeName]}
        regSendMsg(self.uid,'active.change',data)
    end
    
    -- 一周年周年庆活动
    function self.anniversary(activeName,params)
        local actCfg = self.getActiveConfig(activeName)
        local actinfo = self.info[activeName]

        -- 周年每日充值
        if 'charge' == params.action then
            if not actinfo or type(actinfo) ~= 'table' then
                actinfo = {}
            end
            -- 判断是否需要隔天重置
            local weeTs = getWeeTs()
            if not tonumber(actinfo.t) or tonumber(actinfo.t) < weeTs then
                actinfo.cnum = 0 -- 今日充值钻石数
                actinfo.cprz = 0 -- 重置充值奖励状态(0未达成 1可领取 2已领取)
                actinfo.t = weeTs -- 最后刷新时间
            end

            -- 添加充值额
            actinfo.cnum = (actinfo.cnum or 0) + params.gems
            if actinfo.cnum >= actCfg.costMoney[1].needNum and 1 > actinfo.cprz then
                actinfo.cprz = 1
            end

            local data = {[activeName] = self.info[activeName]}
            regSendMsg(self.uid,'active.change',data)
            
        -- 周年打关卡
        elseif 'level' == params.action or 'res' == params.action or 'player' == params.action then
            local key = params.action
            local dropCfg = actCfg.drop

            setRandSeed()
            local rndNum = math.random(1, 100)
            local hitRnd = dropCfg[key..'Drop'] * 100
            -- 有掉落
            if rndNum <= hitRnd then
                -- 随机一个掉落
                local reward = getRewardByPool(dropCfg[key..'Pool'])
                -- 发奖励
                takeReward(self.uid, reward)
                reward = formatReward(reward)

                params.reward = params.reward or {}
                -- 结果合并
                if params.reward.p then
                    for k,v in pairs(reward.p) do
                        params.reward.p[k] = params.reward.p[k] or 0
                        params.reward.p[k] = params.reward.p[k] + v
                    end
                else
                    params.reward.p = reward.p
                end
                
                -- 有掉落道具，设置掉落key
                if params.battle then
                    params.battle.receiveProps = true
                end
            end

            return params.reward
        end
    end
    
    
    -- 圣诞大作战（2015）
    function self.christmasfight(activeName,params)
        local activeCfg = self.getActiveConfig(activeName)
        -- 获取资源的速度加成
        if params.getRes~=nil and params.getRes==1  then
            return activeCfg.rIncr
        end
        -- 获取军功的加成值
        if params.getBrp~=nil and params.getBrp==1  then
            return activeCfg.bIncr
        end
        -- 算下恶魔值
        local point=0
        local rescount=0
        local method=0
        local send=false
        if params.addBrp~=nil and params.addBrp>1 then
            method=1
            rescount=params.addBrp
            point= math.floor(params.addBrp/activeCfg.addBp)
            if point>=activeCfg.ncBp then
                send=true
            end
        end
        
        if params.res and type(params.res) == 'table' then
            method=2
            local r=0
            for i,v in pairs(params.res) do
                r = r + v
            end
            point= math.floor(r/activeCfg.addRes)
            rescount=r
            if point>activeCfg.ncRes then
                send=true
            end
        end
   
        if point>0 then
            self.info[activeName].v=self.info[activeName].v+point
            if self.info[activeName].v>=activeCfg.aRankp then
                setActiveRanking(uid,self.info[activeName].v,activeName,activeCfg.rankNum,self.info[activeName].st,self.info[activeName].et)
            end
            
        end
        local flag,devil,send=self.getchristmasfight(activeName,point,activeCfg.maxPoint,activeCfg.addMin)
        local data = {[activeName] = self.info[activeName]}
        if flag==0  and send  then
            data['res']={method,rescount}
        end
        data['devil']=devil
        if send==1 then
            data['send']=send
        end
        regSendMsg(self.uid,'active.change',data)
    end

    -- 圣诞大作战 算积分
    function self.getchristmasfight(activeName,addpoint,maxpoint,tiemcd)
        local redis = getRedis()
        local ts   = getClientTs()
        local key = "z"..getZoneId()..".."..self.info[activeName].st..activeName.."devil"
        local keytime = "z"..getZoneId()..".."..self.info[activeName].st..activeName.."time"
        local keypoint = "z"..getZoneId()..".."..self.info[activeName].st..activeName.."point"
        local st=tonumber(self.info[activeName].st)
        local expireTime =self.getActiveCacheExpireTime(activeName)
        if  redis:get(key)==nil  or  tonumber(redis:get(key))<1 then
            local send=0
            local stats=0
            local point =tonumber(redis:get(keypoint)) or 0
            local time=0
            if point>=maxpoint then
                point=maxpoint
                stats=1 
                redis:incr(key)
            else
                local start=tonumber(redis:get(keytime)) or st
                time=start
                local timeadd=math.floor((ts-start)/tiemcd)

                if timeadd>0 then
                    addpoint=timeadd+addpoint
                end
                if addpoint>0 then
                    point =redis:incrby(keypoint,addpoint)
                    if point>=maxpoint then
                        send=1
                        local neepoint =redis:incrby(keypoint,-(point-maxpoint))
                        point=maxpoint
                        stats=1
                        redis:incr(key)
                        redis:expire(key,expireTime) 
                    else
                        if timeadd>0 then
                            local usetime=timeadd*tiemcd
                            local thistime=ts-(ts-(start+usetime))
                            redis:set(keytime,thistime)
                            time=thistime
                        end
                    end
                end
      
            end
            if stats==1 then
                redis:set(keytime,ts)
                time=ts
            end
            redis:expire(keytime,expireTime)  
            redis:expire(keypoint,expireTime) 
            
            return stats,{stats,point,time},send
        else
            local stats=1
            
            local count=tonumber(redis:get(keypoint))
            
            if count<=0 or count==nil then
                stats=0
                redis:del(key)
                if addpoint>0 then
                    redis:incrby(keypoint,addpoint)
                    redis:expire(keypoint,expireTime) 
                end
                redis:set(keytime,ts)
                redis:expire(keytime,expireTime) 
            else
                redis:set(keytime,ts)
            end
            redis:expire(keytime,expireTime)  
            return stats,{stats,count,tonumber(redis:get(keytime)) or 0 }
        end      


    end

    -- 圣诞大作战 减去积分
    function self.delchristmasfight(activeName,delpoint,maxpoint,tiemcd, send)
        local redis = getRedis()
        local ts   = getClientTs()
        local key = "z"..getZoneId()..".."..self.info[activeName].st..activeName.."devil"
        local keytime = "z"..getZoneId()..".."..self.info[activeName].st..activeName.."time"
        local keypoint = "z"..getZoneId()..".."..self.info[activeName].st..activeName.."point"
        local st=tonumber(self.info[activeName].st)
        local expireTime =self.getActiveCacheExpireTime(activeName)
        local count=-1
        local stats=0
        local point=0
        if  redis:get(key) ~=nil  then
            if not tonumber(send) or 0 == tonumber(send) then
                count =redis:incrby(keypoint,-delpoint)
            end
            stats=1
            point=count
            if count<0 then
                redis:del(key)
                redis:set(keytime,ts)
                redis:expire(keytime,expireTime) 
                stats=0
                point=0
            end
        end
        return count,{stats,point,ts}
    end


    -- 抽装折扣(超级装备)
    -- 根据抽取的类型返回相应的消耗配置信息
    -- @param string activeName 活动id
    -- @param table params 活动参数 (btype 1稀土抽 2钻石抽)
    -- @return table 活动的抽奖配置
    function self.superEquipOff(activeName, params)
        local actCfg = self.getActiveConfig(activeName) -- getConfig("active/"..activeName)
        local equipCfg = getConfig('superEquipCfg')

        local costCfg, orgCfg
        -- 稀土抽
        if 1 == params.btype then
            costCfg = actCfg.r5CostOff
            orgCfg = equipCfg.r5Cost
        -- 钻石抽
        elseif 2 == params.btype then
            costCfg = actCfg.goldCostOff
            orgCfg = equipCfg.goldCost
        elseif 3 == params.btype then
            costCfg = actCfg.r5CostOff5
            orgCfg = equipCfg.r5Cost
        elseif 4 == params.btype then
            costCfg = actCfg.goldCostOff5
            orgCfg = equipCfg.goldCost
        end

        -- 计算节省的稀土值或钻石值
        local function calDiscount(nowDc, next_cnt)
            -- 进行计算
            for _=1, params.cnt do
                local cost, org = costCfg[next_cnt], orgCfg[next_cnt]
                if not cost then cost = costCfg[ #costCfg ] end --折扣值
                if not org then org = orgCfg[#orgCfg] end -- 原价
                next_cnt = next_cnt + 1
                nowDc = nowDc + org - cost
            end

            return nowDc
        end

        -- 稀土值节省计算
        local function r5Discount()
            self.info[activeName].rv = self.info[activeName].rv or 0
            local dc,next_cnt = self.info[activeName].rv,params.ncnt

            -- 更新活动数据
            self.info[activeName].rnum = next_cnt + params.cnt - 1
            self.info[activeName].rv = calDiscount(dc, next_cnt)
        end

        -- 钻石值节省计算
        local function goldDiscount()
            self.info[activeName].gv = self.info[activeName].gv or 0
            local dc,next_cnt = self.info[activeName].gv,params.ncnt

            -- 更新活动数据
            self.info[activeName].gnum = next_cnt + params.cnt - 1
            self.info[activeName].gv = calDiscount(dc, next_cnt)
        end

        -- 处理器
        local subStageGenFuc = {
            ['1'] = r5Discount, -- 稀土1抽
            ['2'] = goldDiscount, -- 钻石1抽
            ['3'] = r5Discount, -- 稀土5抽
            ['4'] = goldDiscount, -- 钻石5抽
        }

        -- 数据凌晨重置
        local weeTs = getWeeTs()
        local lastTs = self.info[activeName].t or 0
        if weeTs > lastTs then
            self.info[activeName].rnum  = 0
            self.info[activeName].rv    = 0
            self.info[activeName].gnum  = 0
            self.info[activeName].gv    = 0
            self.info[activeName].t     = weeTs
        end

        -- 记录节省钻石和稀土数
        subStageGenFuc[tostring(params.btype)]()

        local data = {[activeName] = self.info[activeName]}
        regSendMsg(self.uid,'active.change',data)

        return costCfg
    end
    
    -- 在线送好礼
    function self.onlineReward(activeName,params)
        local actinfo = self.info[activeName]
        
        -- 时间参数存在
        if params.times and tonumber(params.times) then
            -- 查找最后一个进行累加
            if actinfo.v and 'table' == type(actinfo.v) then
                for _,v in pairs(actinfo.v) do
                    -- 找到第一个没有领奖的
                    if v[1] == 0 then
                        -- 增加在线时间
                        v[3] = v[3] or 0
                        v[3] = v[3] +  params.times
                        break
                    end
                end
            end
        end
    end

    -- 5.1丰收周
    function self.taibumperweek(activeName,params)
        local weeTs = getWeeTs()
        if params.rate~=nil and params.rate>=1 then
            local activeCfg = getConfig("active." .. activeName.."."..self.info[activeName].cfg)
            return activeCfg.value
        end
        if self.info[activeName].t~=weeTs then
            self.info[activeName].d={}
        end   
        local push=false
        if params.pay ~= nil and params.pay>0 then
            local pt =self.info[activeName].pt or 0 --上一次充值时间
            local pd =self.info[activeName].pd or 0 --累计充值天数 
            if type(self.info[activeName].pf)~="table" then  self.info[activeName].pf={}  end
            if pt ~=weeTs then
                self.info[activeName].pd= pd +1
                self.info[activeName].pt =weeTs
            end
            local day="d"..self.info[activeName].pd
            self.info[activeName].pf[day]=(self.info[activeName].pf[day] or 0)+params.pay
            push=true
        end

        if params.l ~= nil and params.l then
            self.info[activeName].d.l=1
            
        end
        
        if params.t~=nil  and params.t>0 then
            self.info[activeName].d.t=(self.info[activeName].d.t or 0)+params.t
            local flag =(self.info[activeName].d.rd or {})  or (self.info[activeName].d.rd.t or {})   
            if flag[1]==nil then
                push=true
            end
        end

        if params.res~=nil and next(params.res) then
            local activeCfg = getConfig("active." .. activeName.."."..self.info[activeName].cfg)
            for k,v in pairs(params.res) do
                if k==activeCfg.res then
                    self.info[activeName].d.r=(self.info[activeName].d.r or 0 )+v
                    local flag =(self.info[activeName].d.rd or {})  or (self.info[activeName].d.rd.r or {})   
                    if flag[1]==nil or flag[2]==nil then
                        push=true
                    end
                    break
                end
            end
        end
        self.info[activeName].t =weeTs 
        if push then
            local data = {[activeName] = self.info[activeName]}
            regSendMsg(self.uid,'active.change',data)
        end

    end

    function self.shuijinghuikui(aname, params)

        local gemsNum = tonumber(params.num) or 0
        local weelTs = getWeeTs()
        if self.info[aname].t < weelTs then
            self.info[aname].v = 0
            self.info[aname].v = self.info[aname].v + gemsNum
            self.info[aname].t = weelTs
        end
        if not self.info[aname].m then
            self.info[aname].m = 0
        end
        self.info[aname].m = self.info[aname].m + gemsNum
    end

    --许愿炉
    function self.xuyuanlu(aname, params)

        local weelTs = getWeeTs()
        if not self.info[aname].p then
            self.info[aname].p = 0
        end
        if not self.info[aname].m then
            self.info[aname].m = {{0,0,0},1,{0,0,0}}
        end
        if self.info[aname].t < weelTs then
            self.info[aname].m = {{0,0,0},1,{0,0,0}}
            self.info[aname].t = weelTs
        end

        local activeCfg = getConfig("active."..aname.."."..self.info[aname].cfg)
        --都满足就算了
        if self.info[aname].m[2] == 3
                and self.info[aname].m[3][1] == 1
                and self.info[aname].m[3][2] == 1
                and self.info[aname].m[3][3] == 1
        then
            return false
        end

        --关卡奖励
        if params.action == "challenge" then
            self.info[aname].m[1][1] = self.info[aname].m[1][1] + 1
        --采集资源
        elseif params.action == "getresource" then
            local res = params.res
            local r1 = tonumber(res.r1) or 0
            local r2 = tonumber(res.r2) or 0
            local r3 = tonumber(res.r3) or 0
            local r4 = tonumber(res.r4) or 0
            local gold = tonumber(res.gold) or 0
            local resource = r1 + r2 + r3 + r4 + gold
            resource = math.floor(resource)
            self.info[aname].m[1][2] = self.info[aname].m[1][2] + resource
        --使用水晶
        elseif params.action == "useGold" then
            local tmpGold = tonumber(params.gold)
            local gold = math.floor(tmpGold)
            self.info[aname].m[1][3] = self.info[aname].m[1][3] + gold
        end

        local roundTask = activeCfg.resourceTask[self.info[aname].m[2]]
        local refreshFlag = true
        local rewardTimes=0
        for i,v in pairs(roundTask) do
            if self.info[aname].m[1][i] > v then
                self.info[aname].m[1][i] = v
            end
            --是否刷新任务
            if self.info[aname].m[1][i] < v then
                refreshFlag = false
            end
            --领取次数奖励
            if self.info[aname].m[1][i] >= v and self.info[aname].m[3][i] == 0 then
                self.info[aname].m[3][i] = 1
                rewardTimes = rewardTimes + 1
            end
        end

        if self.info[aname].m[2] >= #activeCfg.resourceTask then
            self.info[aname].m[2] = #activeCfg.resourceTask
            refreshFlag = false
        end
        --刷新轮数
        if refreshFlag then
            self.info[aname].m[1] = {0,0,0}
            self.info[aname].m[2] = self.info[aname].m[2] + 1
            self.info[aname].m[3] = {0,0,0}
        end
        --次数加1推送给前台
        self.info[aname].p = self.info[aname].p + rewardTimes
        local data = {[aname] = self.info[aname]}
        regSendMsg(self.uid,'active.change',data)
        return true
    end

    --战争之路活动
    function self.battleRoad(aname, params)
        -- body
        local ts = getWeeTs()
        --初始化数据
        if not self.info[aname].t or self.info[aname].t ~= ts then
            self.info[aname].t = ts
            self.info[aname].c = 0
            self.info[aname].get = {}                      
        end

        self.info[aname].c = (self.info[aname].c or 0) + params.c --当天次数
        self.info[aname].v = (self.info[aname].v or 0) + params.c --总次数
        
        --推送
        local data = {[aname] = self.info[aname]}
        regSendMsg(self.uid,'active.change',data)

    end

    --连续充值送将领
    function self.songjiangling(aname, params)
        --当前时间
        local nowWeelTs = getWeeTs();
        local activeStTime = getWeeTs(self.info[aname].st)

        local getDay = function(nowWeelTs, activeStTime)
            local day = ((nowWeelTs - activeStTime)/86400) + 1
            if day > 7 or day < 1 then
                return false
            else
                return day
            end
        end
        local day = getDay(nowWeelTs, activeStTime)
        if not day then
            return false
        end
        if not self.info[aname].p then
            self.info[aname].p = {0,0,0,0,0,0,0}
        end
        if self.info[aname].p[day] == 2 then
            return false
        end
        self.info[aname].p[day] = 1
        return true
    end

    --元旦献礼活动
    function self.yuandanxianli(aname, params)

        if params.type == "addGem" then
            --当前时间
            local nowWeelTs = getWeeTs();
            local activeStTime = getWeeTs(self.info[aname].st)

            local getDay = function(nowWeelTs, activeStTime)
                local day = ((nowWeelTs - activeStTime)/86400) + 1
                if day > 7 or day < 1 then
                    return false
                else
                    return day
                end
            end
            local day = getDay(nowWeelTs, activeStTime)
            if not day then
                return false
            end
            if not self.info[aname].p then
                self.info[aname].p = {0,0,0,0,0,0,0}
            end
            if self.info[aname].p[day] == 2 then
                return false
            end
            self.info[aname].p[day] = 1

        elseif params.type == "rate" then

            local activeCfg = getConfig("active."..aname.."."..self.info[aname].cfg)
            local weelTs = getWeeTs()
            if not self.info[aname].q then
                self.info[aname].q = 0
            end
            if not self.info[aname].w then
                self.info[aname].w = 0
            end

            if self.info[aname].q < weelTs then
                self.info[aname].q = weelTs
                self.info[aname].w = 0
            end
            --验证次数
            if self.info[aname].w >= activeCfg.freeTime then
                return false
            end
            local rate = params.rate
            --增加次数限制
            self.info[aname].w = self.info[aname].w + 1
            return math.ceil(activeCfg.successUp * rate)
        end
        return false
    end

    --真情回馈活动
    function self.zhenqinghuikui(aname, params)
        local goldNum = params.num
        if not self.info[aname].p then
            self.info[aname].p = 0
        end

        if not self.info[aname].q then
            self.info[aname].q = 0
        end

        if not self.info[aname].k then
            self.info[aname].k = 0
        end

        local weelTs = getWeeTs()
        if self.info[aname].q < weelTs then
            self.info[aname].q = weelTs
            self.info[aname].v = 0
            self.info[aname].k = 0
            self.info[aname].p = 0
        end

        self.info[aname].p = self.info[aname].p + goldNum
        require "model.active"
        local mActive = model_active()
        --自定义配置文件
        local activeCfg = mActive.selfCfg(aname)
        local times = 0
        while self.info[aname].p >= activeCfg.goldNum do
            self.info[aname].p = self.info[aname].p - activeCfg.goldNum
            times = times + 1
        end
        self.info[aname].v = self.info[aname].v + times

    end

    --圣诞宝藏活动 缓存数据可能会丢失 修改数据一致
    function self.shengdanbaozang(aname, params)

        if type(self.info[aname].v) ~= "number" then
            self.info[aname].v = 0
        end

        local redis = getRedis()
        local activeCfg = getConfig("active."..aname.."."..self.info[aname].cfg)
        local redisKey = getActiveCacheKey(aname, "def", self.info[aname].st)
        local info = redis:hget(redisKey, self.uid)

        if (not info) and self.info[aname].v > 0 then
            self.info[aname].v = 0
        else
            info = json.decode(info)
            local countTimes = 0
            if type(info) == "table" and next(info[3]) then
                for i,v in pairs(info[3]) do
                    if #v >= 2 then
                        countTimes = countTimes + 1
                    end
                end
            end
            if countTimes ~= self.info[aname].v then
                self.info[aname].v = 0
                redis:hdel(redisKey, self.uid)
            end
        end
    end

    --圣诞狂欢活动
    function self.shengdankuanghuan(aname, params)

        local redis = getRedis()
        local activeCfg = getConfig("active." .. aname .. "."..self.info[aname].cfg)
        local treeWholeNum = 0
        if params.category == "addGem" then
            local num = params.num
            local payConfig = getConfig("pay")
            local countPay = #payConfig
            local rewardType = 0
            for i=1, countPay do
                if num >= payConfig[(countPay - i + 1)] then
                    rewardType = countPay - i + 1
                    break
                end
            end

            if rewardType ~= 0 then
                if type(self.info[aname].v) ~= 'table' then
                    self.info[aname].v = {0,0,0,0,0,0}
                end
                self.info[aname].v[rewardType] = self.info[aname].v[rewardType] + 1
            end


            local treeVate = activeCfg.goldVate
            local activeKey = getActiveCacheKey(aname, "def", self.info[aname].st)
            treeWholeNum = redis:incrby(activeKey, math.floor(num/treeVate))
            redis:expireat(activeKey, self.info[aname].et)

        elseif params.category == "resource" then

            local res = params.res
            local r1 = tonumber(res.r1) or 0
            local r2 = tonumber(res.r2) or 0
            local r3 = tonumber(res.r3) or 0
            local r4 = tonumber(res.r4) or 0
            local gold = tonumber(res.gold) or 0
            local resource = r1 + r2 + r3 + r4 + gold
            resource = math.floor(resource)

            local resourceKey = getActiveCacheKey(aname, "def.resource", self.info[aname].st)
            local activeKey = getActiveCacheKey(aname, "def", self.info[aname].st)
            local treeresource = redis:incrby(resourceKey, resource)
            treeresource = tonumber(treeresource) or 0
            local diffresourceNum = 0
            if treeresource >= activeCfg.resourceVate then
                diffresourceNum = math.floor(treeresource/activeCfg.resourceVate)
                redis:decrby(resourceKey, diffresourceNum * activeCfg.resourceVate)
            end
            treeWholeNum=redis:incrby(activeKey, diffresourceNum)
            redis:expireat(activeKey, self.info[aname].et)
            redis:expireat(resourceKey, self.info[aname].et)
        end

        writeLog(treeWholeNum, aname)
        treeWholeNum = tonumber(treeWholeNum) or 0
        local activeMsgKey = getActiveCacheKey(aname, "msg.def", self.info[aname].st)
        local info = redis:get(activeMsgKey)
        if not info then
            info = 0
        else
            info = tonumber(info) or 0
        end
        --判断发送聊天公告
        local sayFlag = false
        local needScore = 0
        if info < activeCfg.treeReward[1][1] then
            for i,v in pairs(activeCfg.treeReward) do
                if treeWholeNum >= v[1] and treeWholeNum >= info then
                    local tmpRecord = (i-1) >= 1 and (i-1) or 1
                    info = activeCfg.treeReward[tmpRecord][1]
                    sayFlag = true
                    needScore = v[1]
                    break
                end
            end
            redis:set(activeMsgKey, info)
            redis:expireat(activeMsgKey, self.info[aname].et)
        end
        --最高档次发公告
        if info == activeCfg.treeReward[1][1] and treeWholeNum >= activeCfg.treeReward[1][1] then
            sayFlag = true
            needScore = activeCfg.treeReward[1][1]
            redis:set(activeMsgKey, info + 1)
            redis:expireat(activeMsgKey, self.info[aname].et)
        end
        local chatSystemMessage="chatSystemMessage101"
        if self.info[aname].cfg==3 then
            chatSystemMessage="chatSystemMessage102"
        end
        if sayFlag then

            local msg = {
                sender = "",
                reciver = "",
                channel = 1,
                sendername = "",
                recivername = "",
                content = {
                    message={
                        key=chatSystemMessage,
                        param={
                            data=needScore,
                        },
                    },
                    ts = getClientTs(),
                    contentType = 3,
                    subType=4,
                    language="cn",
                },
                type = "chat",
            }
            sendMessage(msg)
        end
        return true
    end

    --百福大礼
    function self.baifudali(aname, params)

        local config = getConfig("active."..aname.."."..self.info[aname].cfg)
        if params.type == "repair" then
            return math.ceil(params.golds * config.repairVate)
        elseif params.type == "add" then
            self.info[aname].v = self.info[aname].v + tonumber(params.gems)
            return true
        end
        return false
    end

    --鸡动部队
    function self.jidongbudui(aname, params)
        local msg = {
            sender = "",
            reciver = "",
            channel = 1,
            sendername = "",
            recivername = "",
            content = {
                type = 100,
                ts = getClientTs(),
                contentType = 4,
                params = {
                    category = "",
                    data = params.index,
                },
            },
            type = "chat",
        }

        local config = getConfig("active."..aname.."."..self.info[aname].cfg)
        local level = tonumber(params.mlv) or 0
        local placeKey = getActiveCacheKey(aname, "def.place", self.info[aname].st)
        local placeindex = json.encode(params.index)
        --得到某个点是否有火鸡部队
        if params.setMapTroops then
            local vate = math.floor(level*0.8)
            setRandSeed()
            local seed = rand(1, 100)
            if seed <= vate then
                local redis = getRedis()
                redis:lrem(placeKey, 0, placeindex);
                redis:lpush(placeKey, placeindex)
                redis:expireat(placeKey, self.info[aname].et)
                msg.content.params.category = "add"
                sendMessage(msg)
                return {troop=config.serverreward.trType}
            end
            --得到对应的火鸡部队奖励
        elseif params.getReward then
            local troops = params.troops
            local getRewardFlag = false
            for i, v in pairs(troops) do
                if v[1] == config.serverreward.trChicken then
                    getRewardFlag = true
                    break
                end
            end
            if not getRewardFlag then
                return false
            end
            if not self.info[aname].mm then
                self.info[aname].mm = {mm_m1 = 0}
            end

            local redis = getRedis()
            redis:lrem(placeKey, 0, placeindex);
            redis:expireat(placeKey, self.info[aname].et)
            msg.content.params.category = "del"
            sendMessage(msg)
            local num = math.ceil(level/7)
            self.info[aname].mm.mm_m1 = self.info[aname].mm.mm_m1 + num
            local clientReward = {reward={}, acaward={}}
            clientReward.acaward = {jidongbudui_mm_m1 = num }
            local data = {[aname] = self.info[aname]}
            regSendMsg(self.uid,'active.change',data)
            return clientReward
        end
        return false
    end

    function self.calls(aname, params)
        self.info[aname].nt = 1
    end

    --月度将领
    function self.yuedujiangling(aname,params)
        local action = tonumber(params.action) or 0
        local num = tonumber(params.num) or 0
        local weeTs = getWeeTs()
        if self.info[aname].t < weeTs then
            self.info[aname].t = weeTs
            self.info[aname].flag = nil
            self.info[aname].record = nil
        end
        
        if not self.info[aname].record or type(self.info[aname].record) ~= 'table' then
            self.info[aname].record = {0,0}
        end
        
        if not self.info[aname].flag or type(self.info[aname].flag) ~= 'table' then
            self.info[aname].flag = {0,0}
        end

        self.info[aname].record[action] = self.info[aname].record[action] + num
        self.info[aname].t = weeTs
        self.info[aname].cost = nil
        
        local sendData = {
            [aname] = {
                record = self.info[aname].record,
                flag = self.info[aname].flag,
                t = self.info[aname].t
            }
        }
        regSendMsg(self.uid,'active.change',sendData)
                    
        return true
    end

    --摧枯拉朽活动
    function self.cuikulaxiu(aname, params)

        local point = tonumber(params.point) or 0
        if point == 0 then
            return false
        end

        local redis = getRedis()
        local redisKey = getActiveCacheKey(aname, "def", self.info[aname].st)
        local redisInfoKey = getActiveCacheKey(aname, "def.info", self.info[aname].st)
        local config = getConfig("active."..aname.."."..self.info[aname].cfg)
        local minPoint = config.minPoint
        self.info[aname].v = self.info[aname].v + point
        if minPoint <= self.info[aname].v then
            if redis:zrevrank(redisKey,self.uid) then
                redis:zincrby(redisKey, point, self.uid)
            else
                redis:zadd(redisKey, self.info[aname].v, self.uid)
            end
            local uobjs = getUserObjs(self.uid)
            local userinfo = uobjs.getModel("userinfo")
            redis:hset(redisInfoKey, self.uid, json.encode({userinfo.nickname, userinfo.level}))
            redis:expireat(redisInfoKey, self.info[aname].et)
            redis:expireat(redisKey, self.info[aname].et)
        end
        return true
    end

    --天天爱助威
    function self.dayCheer(aname, params)

        local weelTs = getWeeTs()
        if self.info[aname].t >= weelTs then
            return false
        end
        self.info[aname].v = self.info[aname].v + 1
        self.info[aname].t = weelTs
        return true
    end

    --国庆攻势活动
    function self.nationalCampaign(aname, params)
        local activeCfg = getConfig("active." .. aname )

        -- 增加经验值
        if params.action == 'getExp' then
            local exp = tonumber(params.exp)
            return math.ceil(exp * (activeCfg.expAdd/100))
        end
        -- 坦克损坏
        if params.action == 'getTank' then
            return math.ceil(params.repairNum * ((100-activeCfg.destoryRateDown)/100))
        end

        --得到可以用的俩种商品
        local getValidShop = function(activeStartTime, activeCfg, cacheKey, expireTime)
        --得到活动的开始时间
            local getStartTime = function(nowTime, activeStartTime, activeCfg)

                local hour = tonumber(os.date('%H', activeStartTime))
                local year = tonumber(os.date('%Y', activeStartTime))
                local month = tonumber(os.date('%m', activeStartTime))
                local minute = tonumber(os.date('%M', activeStartTime))
                local day = tonumber(os.date('%d', activeStartTime))
                local second = tonumber(os.date('%S', activeStartTime))
                local shopStartTime = 0
                if hour < activeCfg.refreshTime[#activeCfg.refreshTime] then
                    shopStartTime = activeCfg.refreshTime[1]
                    local tab = {year=year, month=month, day=day, hour=shopStartTime,min=0,sec=0,isdst=false}
                    shopStartTime = os.time(tab) - 24 * 60 * 60
                else
                    for _, v in pairs(activeCfg.refreshTime) do
                        if hour > v then
                            shopStartTime = v
                            break
                        end
                    end
                    local tab = {year=year, month=month, day=day, hour=shopStartTime,min=0,sec=0,isdst=false}
                    shopStartTime = os.time(tab)
                end
                return shopStartTime
            end

            local nowTime = getClientTs();
            local startTime = getStartTime(nowTime, activeStartTime, activeCfg);
            local vate = math.floor((nowTime - startTime) / (8 * 60 * 60))
            local refreshTime = startTime + (vate+1) * 8 * 60 * 60
            local randRes = {}
            local randSeed = {}
            local redis = getRedis();
            local data = redis:get(cacheKey)
            data = json.decode(data)
            data = type(data) == 'table' and data or {}
            local index = data['index'] or 0
            if (vate <= index and data['now']) or (vate==0 and data['now']) then
                return data['now'], index, startTime + (index+1) * 8 * 60 * 60
            end
            local getRand = function(use, nouse)
                setRandSeed()
                local seed = rand(1, #nouse)
                local reward = nouse[seed]
                table.insert(use, nouse[seed])
                table.remove(nouse, seed)
                if not next(nouse) then
                    nouse, use = use, nouse
                end
                return reward, use, nouse
            end
            local nouse, use = {}, {}
            if not next(data) then
                for i,_ in pairs(activeCfg.buy) do
                    nouse[i] = i
                end
                use = {}
            else
                nouse = data['nouse']
                use = data['use']
            end
            local rand1,use,nouse = getRand(use, nouse)
            local rand2,use,nouse = getRand(use, nouse)
            local shop = {rand1, rand2 }
            data = {now={rand1, rand2},nouse=nouse,use=use,index=vate}
            redis:set(cacheKey, json.encode(data))
            redis:expire(cacheKey,expireTime)
            return shop, vate, startTime + (data.index+1) * 8 * 60 * 60
        end

        local expireTime = self.getActiveCacheExpireTime(aname,172800)
        local cacheKey = getActiveCacheKey(aname,'def',self.info[aname].st)
        local shop, index, refreshTime = getValidShop(self.info[aname].st, activeCfg, cacheKey, expireTime)
        --返回随机的列表
        if params.action == 'getlist' then
            return {shop, index, refreshTime}
        end
        --购买物品折扣
        local disCount = 0
        local shopIndex = 0
        for _,v in pairs(shop) do
            if params.pid == activeCfg.buy[v]['gift'] then
                disCount = activeCfg.buy[v]['discount']
                shopIndex = v
                break
            end
        end
        if type(self.info[aname].v) ~= 'table' then
            self.info[aname].v = {}
        end
        local pid = params.pid
        local defaultData =  self.info[aname].v
        if not defaultData[pid] or defaultData[pid][2] ~= index then
            defaultData[pid] = {}
            defaultData[pid] = {0, index}
        end

        if disCount == 0 then
            return false
        end
        local buyNum = tonumber(params.info.num) or 1
        local checkNum = buyNum + defaultData[pid][1]
        if checkNum > activeCfg.buy[shopIndex]['num'] then
            return false
        end

        defaultData[pid] = {checkNum, index}
        self.info[aname].v = defaultData
        return math.ceil(params.gems * disCount * buyNum)
    end

    --备战巅峰活动
    function self.preparingPeak(aname, params)
        local gemsCost = params.gems
        local pid = params.pid
        local disCount = 0
        local limitNum = 0
        local buyNum = tonumber(params.info.num) or 1
        local activeCfg = getConfig("active." .. aname )
        for i,v in pairs(activeCfg.buy) do
            if v.gift == pid then
                disCount = v.discount
                limitNum = v.num
                break
            end
        end
        if limitNum == 0 or disCount == 0 then
            return false
        end
        if type(self.info[aname].v) ~= 'table' then
            self.info[aname].v = {}
        end
        if self.info[aname].t < getWeeTs() then
            self.info[aname].v = {}
        end

        if self.info[aname].v[pid] and self.info[aname].v[pid] >= limitNum then
            return false
        end

        if not self.info[aname].v[pid] then
            self.info[aname].v[pid] = 0
        end
        self.info[aname].v[pid] = self.info[aname].v[pid] + 1
        self.info[aname].t = getWeeTs()
        return math.ceil(gemsCost * disCount * buyNum)
    end

    --军备换代活动
    function self.armamentsUpdate1(aname, params)
        local cfg = getConfig("active." .. aname )
        return self._armamentsUp(aname, params, cfg)
    end

    function self.armamentsUpdate2(aname, params)
        local cfg = getConfig("active." .. aname )
        return self._armamentsUp(aname, params, cfg)
    end

    function self._armamentsUp(aname, params, cfg)
        local sCfg = cfg.serverreward
        --改装坦克增加倍数
        if params.type == 1 then

            local upgradeCfg = sCfg.upgrade
            if upgradeCfg['troops_' .. params.v.id] then
                params.v.nums = params.v.nums * upgradeCfg['troops_' .. params.v.id]
                return params.v
            end
            --掉落碎片增加
        elseif params.type == 2 then

            local ascVate = sCfg.ascVate
            for type, num in pairs(params.reward) do
                if ascVate[type] then
                    params.reward[type] = params.reward[type] * ascVate[type]
                end
            end
            return params.reward
        end
        return params.oldInfo
    end

    --冲级三重奏
    function self.leveling(aname, params)

        --检查是否是指挥中心
        if tonumber(params.buildType) ~= 7 then
            return params.oldInfo
        end

        local cfg = getConfig("active."..aname.."."..self.info[aname].cfg )

        --资源消耗
        if params.type == 1 then

            for type, num in pairs(params.use) do
                params.use[type] = math.ceil(num * cfg.desVate)
            end
            return params.use
            --时间减少
        elseif params.type == 2 then

            return math.ceil(params.iConsumeTime * cfg.desVate)
        end
        return params.oldInfo
    end

    --冲级三重奏
    function self.leveling2(aname, params)

        --检查是否是指挥中心
        if tonumber(params.buildType) ~= 7 then
            return params.oldInfo
        end

        local cfg = getConfig("active."..aname.."."..self.info[aname].cfg )
        if params.level < cfg.lvLim[1] or params.level >= cfg.lvLim[2] then
            return false
        end

        --资源消耗
        if params.type == 1 then

            for type, num in pairs(params.use) do
                params.use[type] = math.ceil(num * cfg.desVate)
            end
            return params.use
            --时间减少
        elseif params.type == 2 then

            return math.ceil(params.iConsumeTime * cfg.desVate)
        end
        return params.oldInfo
    end
    
    -- 充值红包活动
    function self.rechargeredbag(aname, params)
        -- 活动数据
        local actinfo   = self.info[aname]
        local actCfg    = self.getActiveConfig(aname)
        
        -- 隔天刷新数据
        local weeTs     = getWeeTs()
        if actinfo.t < weeTs then
            actinfo.t = weeTs
            actinfo.v = 0                       -- 充值值
            actinfo.rs = {}                     -- 领奖状态
            for i=1,#actCfg.reward.cost do
                actinfo.rs[i] = 0
            end
        end
        
        -- 增加今天充值的数量
        actinfo.v = actinfo.v + params.gems
        self.info[aname] = actinfo
    end

    --绑定型 连续充值活动
    function self.bindcontinueRecharge(aname, params)
        local deFaultData = {}
        local activeCfg = getConfig("active."..aname)
        for i=1,activeCfg.bindTime[2] do
            deFaultData[i] = 0
        end
        local gems = params.gems

        if self.info[aname].v and type(self.info[aname].v) == 'table' then
            deFaultData = self.info[aname].v
        end
        
        local uobjs = getUserObjs(self.uid)
        local mUserinfo = uobjs.getModel('userinfo')

        -- 获取注册天数
        local regDays =  ((getWeeTs() - getWeeTs(mUserinfo.regdate)) / 86400) + 1
        if regDays > activeCfg.bindTime[2] then
            return 
        end

        deFaultData[regDays] = deFaultData[regDays] or 0
        deFaultData[regDays] = deFaultData[regDays] + gems
        self.info[aname].v = deFaultData
    end

    --连续充值活动
    function self.continueRecharge(aname, params)
        --当前时间
        local nowWeelTs = getWeeTs();
        local activeEndTime = getWeeTs(self.info[aname].et)
        local deFaultData = {0,0,0,0,0,0,0 }
        local gems = params.gems

        if self.info[aname].v and type(self.info[aname].v) == 'table' then
            deFaultData = self.info[aname].v
        end

        local getDay = function(nowWeelTs, activeEndTime)
            local day = 7 - ((activeEndTime - nowWeelTs) / 86400)
            if day > 7 or day < 1 then
                return false
            else
                return day
            end
        end

        local day = getDay(nowWeelTs, activeEndTime)

        if not day then
            return
        end

        deFaultData[day] = deFaultData[day] + gems
        self.info[aname].v = deFaultData
    end

    --满载而归活动
    function self.rewardingBack(aname, params)
        local gems = params.gems
        local defaultData = 0
        if self.info[aname].v then
            defaultData = self.info[aname].v
        end
        defaultData = defaultData + gems
        self.info[aname].v = defaultData
    end

    --中秋活动（打关卡送礼盒）
    function self.autumnCarnival(aname, params)
        local defaultData = {}

        if self.info[aname].ls then
            defaultData = self.info[aname].ls
        end

        local level = params.level

        --local config = getConfig("active." .. aname )
        local config = getConfig("active."..aname.."."..self.info[aname].cfg)

        local randConfig = config.serverreward

        local checkHasSpice = function (level)
            local randSeed = 20 + math.floor(level/8)
            setRandSeed()
            local randCode = rand(1,100)
            return randCode <= randSeed and true or false
        end

        if checkHasSpice(level) then
            local reward = getRewardByPool(randConfig.pool)
            local clientReward = {reward={}, acaward={}}
            for goods, number in pairs(reward) do
                if not defaultData[goods] then
                    defaultData[goods] = number
                else
                    defaultData[goods] = defaultData[goods] + number
                end
                clientReward.acaward = {[goods] = number}
            end
            self.info[aname].ls = defaultData
            local data = {[aname] = self.info[aname]}
            regSendMsg(self.uid,'active.change',data)
            return clientReward
        end
        return false
    end

    --万圣节驱鬼大战
    function self.ghostWars(aname, params)

        local config = getConfig("active." .. aname )
        local randConfig = config.serverreward

        if params.type == 'getReward' then

            local level = params.level
            local clientReward = {reward={}, acaward={} }
            --转换为client
            local serverToClient = function(type)
                local tmpData = type:split("_")
                local tmpType = tmpData[2]
                local tmpPrefix = string.sub(type, 1, 1)
                if tmpPrefix == 't' then tmpPrefix = 'o' end
                if tmpPrefix == 'a' then tmpPrefix = 'e' end
                return tmpPrefix, tmpType
            end
            --是否可领奖
            local checkHasSpice = function (level, hasCfg)
                local randSeed = 0
                if level == nil then
                    return false
                end
                level = tonumber(level)
                for _, v in pairs(hasCfg) do
                    if level >= v[1] then
                        randSeed = v[2]
                        break
                    end
                end
                setRandSeed()
                local randCode = rand(1,100)
                return randCode <= randSeed and true or false
            end
            --获取奖励
            if checkHasSpice(level, randConfig.level) then
                local reward = getRewardByPool(randConfig.pool)
                for goods, number in pairs(reward) do
                    takeReward(uid, {[goods] = number})
                    local tmpPrefix, tmpType = serverToClient(goods)
                    table.insert(clientReward.reward, {type=tmpPrefix, name=tmpType, number=number})
                end
                return clientReward
            end
            return {}
        elseif params.type == 'decTime' then

            local timeCfg = config.collectspeedup
            return math.ceil(params.time * timeCfg)
        elseif params.type == 'addReputation' then

            local repCfg = config.pointup
            return math.floor(params.reputation * repCfg)
        end
        return false
    end

    --秘宝探寻活动
    function self.miBao(aname, params)

        local defaultData = {}

        if self.info[aname].ls then
            defaultData = self.info[aname].ls
        end

        local level = params.level

        local config = getConfig("active." .. aname )
        local randConfig = config.serverreward

        local checkHasSpice = function (level, hasCfg)
            local randSeed = 0
            if level == nil then
                return false
            end
            level = tonumber(level)
            for _, v in pairs(hasCfg) do
                if level >= v[1] then
                    randSeed = v[2]
                    break
                end
            end
            setRandSeed()
            local randCode = rand(1,100)
            return randCode <= randSeed and true or false
        end

        if checkHasSpice(level, randConfig.level) then
            local reward = getRewardByPool(randConfig.pool)
            local clientReward = {reward={}, acaward={}}
            for goods, number in pairs(reward) do
                if goods == 'props_p405' then
                    takeReward(uid, {[goods] = number})
                else
                    if not defaultData[goods] then
                        defaultData[goods] = number
                    else
                        defaultData[goods] = defaultData[goods] + number
                    end
                end
                if goods == 'props_p405' then
                    goods = 'p405'
                    table.insert(clientReward.reward, {type="p", name="p405", number=number})
                else
                    clientReward.acaward = {[goods] = number}
                end
            end
            self.info[aname].ls = defaultData
            local data = {[aname] = self.info[aname]}
            regSendMsg(self.uid,'active.change',data)
            return clientReward
        end
        return {}
    end

    -- 资金招募
    function self.fundsRecruit(aname, params)

        local defaultData = {
            lg = {0, 0, 0},
            gm = {0, 0, 0},
            gd = {0, 0, 0},
        }
        local freshFlag = params.fresh
        local weelTs = getWeeTs()
        local hasDataFlag = false

        if self.info[aname].ls then
            defaultData = self.info[aname].ls
            hasDataFlag = true
        end

        if params.name == 'login' then

            if defaultData.lg[3] < weelTs then
                defaultData.lg[1] = getClientTs()
                defaultData.lg[3] = weelTs
            end

            --重置物品捐献次数
            if defaultData.gd[3] < weelTs then
                defaultData.gd[3] = weelTs
                defaultData.gd[1] = 0
            end
            --重置金币捐献次数
            if defaultData.gm[3] < weelTs then
                defaultData.gm[3] = weelTs
                defaultData.gm[1] = 0
            end

        elseif params.name == 'join' or params.name == 'create'  or params.name == 'accept' then

            --检查用户是否参与过活动(用户退出军团又加入)
            if hasDataFlag then
                defaultData.lg[1] = getClientTs()
                if params.name == 'accept' then
                    defaultData.lg[3] = 0
                end
                defaultData.gm[1] = 0
                defaultData.gd[1] = 0
            end

        elseif params.name == 'donate' then
            --重置物品捐献次数
            if defaultData.gd[3] < weelTs then
                defaultData.gd[3] = weelTs
                defaultData.gd[1] = 0
            end
            --重置金币捐献次数
            if defaultData.gm[3] < weelTs then
                defaultData.gm[3] = weelTs
                defaultData.gm[1] = 0
            end
            --累加次数
            if params.type == 1 then
                defaultData.gd[1] = defaultData.gd[1] + 1
            else
                defaultData.gm[1] = defaultData.gm[1] + (params.donate_cnt or 1)
                defaultData.gd[1] = defaultData.gd[1] + (params.donate_cnt or 1)
            end
        end
        --更新数据
        self.info[aname].ls = defaultData
    end

    -- 有福同享
    function self.shareHappiness(aname,params)
        --[[
        if type(params)=='table' and next(params) then
            local num = params.num
            local name = params.nickname
            local aid = params.aid
            local activeCfg = getConfig("active." .. activeName)
            local reward={}
            local method = 0
            for k,v in pairs(activeCfg.serverreward) do
                if num>=v[2] then
                    method=k
                    reward=v[1]
                end
            end
            if next(reward) then
                local ts =getClientTs()
                if takeReward(self.uid,reward) then
                       if aid >0 then
                            local id = getActiveIncrementId(activeName..self.info[activeName].st,self.getActiveCacheExpireTime(activeName,172800))
                            local log = {id,method,self.uid,ts}
                            self.setlog(aid,log,activeName)
                       end
                end
            end

        end
        --]]
        --得到分享礼包的档次
        local getShareCode = function(num, shareConfig)

            local shareCode = 0
            if num == 0 then
                return shareCode
            end
            for i, v in pairs(shareConfig) do
                if num >= v[2] then
                    return i
                end
            end
            return shareCode
        end

        --添加礼包
        local addShareGift = function(shareCode, aid, aname, uid, uname, cacheKey, totalTime)

            if cacheKey == nil then
                return false
            end

            local cacheRedis = getRedis()
            local nowTime = getClientTs()
            local giftId = uid .. '.' .. nowTime
            local data = {
                cd = shareCode,
                --aid = aid, am = aname,
                uid = uid,
                um = uname,
                st = nowTime,
            }

            local flag = cacheRedis:hmset(cacheKey, giftId, json.encode(data))
            cacheRedis:expire(cacheKey, totalTime)
            if not flag then
                return false
            end
            return flag, giftId, data
        end

        --初始化数据
        local uid = self.uid
        local allianceId = params.allianceId
        local allianceName = params.allianceName
        local username = params.username
        local num = params.num
        local cacheKey
        if tonumber(allianceId) > 0 then
            cacheKey = getActiveAllianceCacheKey(aname, "def", allianceId, self.info[aname].st )
        end
        local lastGetRewardTime = self.info[aname].t
        --redis过期时间
        local totalTime = self.getActiveCacheExpireTime(aname,172800)
        local activeCfg =  getConfig("active." .. aname )
        local serverCfg = activeCfg.serverreward

        --得到分享的类型
        local shareCode = getShareCode(num, serverCfg);
        if shareCode ~= 0 then
            --增加军团礼包
            local flag, giftId, data = addShareGift(shareCode, allianceId, allianceName, uid, username, cacheKey, totalTime)
            if flag then
                local mems = M_alliance.getMemberList{uid=uid,aid=allianceId}
                if mems then
                    local cmd = 'active.shareHappiness.push'
                    for _,v in pairs( mems.data.members) do
                        local tmpUid = tonumber(v.uid)
                        if uid ~= tmpUid then
                            regSendMsg(tmpUid, cmd, data)
                        end
                    end
                end
            end
            --用户直接加礼包
            local totalReward = serverCfg[shareCode][1]
            --for i,v in pairs(totalReward) do print(i,v) end
            if not takeReward(uid, totalReward) then
                --记录添加背包失败的用户
                writeLog(uid, aname)
            end
        end
    end

    --军备竞赛  收集龙珠了啊
    function self.armsRace(activeName,params)

        if type(self.info[activeName].v) ~='table'  then  self.info[activeName].v={} end

        if type(params)=='table' and next(params) then
            for k,v in pairs(params) do
                local cuut =self.info[activeName].v[k] or 0
                self.info[activeName].v[k]=v+cuut
            end

            --给前台推送
            local data = {[activeName] = self.info[activeName]}
            regSendMsg(self.uid,'active.change',data)
        end
    end


    --设置领取的log

    function self.setlog(uid,log,activeName,len)

        local redis = getRedis()
        local key =''
        if self.info[activeName] then
            key = "z"..getZoneId()..".ac."..activeName..uid..".user."..self.info[activeName].st
        else
            key = "z"..getZoneId()..".ac."..activeName..uid..".user"
        end

        local data = redis:get(key)
        local result=json.decode(data)

        if type(result)~='table' then result={} end

        table.insert(result,log)

        local rankLength = #result
        local maxLenth = 50
        local delend = rankLength - maxLenth
        if len ~=true then
            if delend>0 then
                for i=1,delend do
                    table.remove(result,1)
                end
            end
        end
        local data = json.encode(result)
        local reuslt = redis:set(key,data)
        local expireTime = self.getActiveCacheExpireTime(activeName,172800)
        redis:expire(key,expireTime)
    end


    function self.getlog(uid,activeName)
        local redis = getRedis()
        local key =''
        if self.info[activeName] then
            key = "z"..getZoneId()..".ac."..activeName..uid..".user."..self.info[activeName].st
        else
            key = "z"..getZoneId()..".ac."..activeName..uid..".user"
        end
        local data = redis:get(key)
        local result=json.decode(data)
        return result

    end





    local function Log(logInfo,filename)
        local log = ""
        log = log .."uid=".. (logInfo.uid or ' ') .. "|"
        log = log .. "reward="..json.encode(logInfo.reward)

        filename = filename or 'gangtie'
        writeLog(log,filename)
    end
    -- 保存钢铁之心的数据
    function self.heartOfIron(activeName,params)
        -- body
        -- alevel 配件等级
        -- blevel 宅基地等级
        -- ulevel 玩家等级
        -- star   关卡星数
        -- acrd   领取军团分本的标识每次累加
        -- tech   科技等级
        -- a10003 坦克的类型id  每种的累加

        --检测注册时间


        local uobjs = getUserObjs(uid,true)
        local mUserinfo = uobjs.getModel('userinfo',true)
        local rsttime  = mUserinfo.regdate

        local ts =getClientTs()
        local firstweets = getWeeTs(rsttime+24*3600)
        --检测注册时间是都大余7天
        if  ts> (firstweets+7*86400) then
            return true
        end
        if type(self.info[activeName].v)~='table' then self.info[activeName].v={}   end
        local alevel = params.alevel
        if alevel ~=nil and alevel>0 then
            local day=self.info[activeName].v.alevel[2]
            if ts<firstweets+day*86400 then
                self.info[activeName].v.alevel[3]=alevel
            end
            return true
        end

        local blevel = params.blevel

        if blevel ~=nil and blevel>0 then
            local day=self.info[activeName].v.blevel[2]
            if ts<firstweets+day*86400 then
                self.info[activeName].v.blevel[3]=blevel
            end
            return true
        end

        local star   = params.star
        if star ~=nil and star>0 then
            local day=self.info[activeName].v.star[2]
            if ts<firstweets+day*86400 then
                self.info[activeName].v.star[3]=star
            end
            return true
        end



        local acrd   = params.acrd
        if acrd ~=nil and acrd>0 then
            local day=self.info[activeName].v.acrd[2]
            if ts<firstweets+day*86400 then
                self.info[activeName].v.acrd[3]=(self.info[activeName].v.acrd[3] or 0)+1
            end
            return true
        end


        local tech   = params.tech

        if tech ~=nil and tech>0 then
            local day=self.info[activeName].v.tech[2]
            if ts<firstweets+day*86400 then
                self.info[activeName].v.tech[3]=tech
            end
            return true
        end

        local ulevel = params.ulevel
        if ulevel ~=nil and ulevel>0 then
            local day=self.info[activeName].v.ulevel[2]
            if ts<firstweets+day*86400 then
                self.info[activeName].v.ulevel[3]=ulevel
            end
            return true
        end
        local day=self.info[activeName].v.troops[2]
        if ts>(firstweets+day*86400) or ts<(firstweets+day*86400-86400) then
            return true
        end

        if type (self.info[activeName].v.tank)~='table' then self.info[activeName].v.tank={} end
        local a10003 = params.a10003

        if a10003~=nil and a10003 >0 then
            local rc = (self.info[activeName].v.tank.a10003) or 0
            if rc<=a10003 then
                self.info[activeName].v.tank.a10003=a10003
            end
        end

        local a10013 = params.a10013
        if a10013~=nil and a10013 >0 then
            local rc = (self.info[activeName].v.tank.a10013) or 0
            if rc<=a10013 then
                self.info[activeName].v.tank.a10013=a10013
            end
        end
        local a10023 = params.a10023
        if a10023~=nil and a10023 >0 then
            local rc = (self.info[activeName].v.tank.a10023) or 0
            if rc<=a10023 then
                self.info[activeName].v.tank.a10023=a10023
            end
        end
        local a10033 = params.a10033
        if a10033~=nil and a10033 >0 then
            local rc = (self.info[activeName].v.tank.a10033) or 0
            if rc<=a10033 then
                self.info[activeName].v.tank.a10033=a10033
            end
        end
        local cuut =0

        if type(self.info[activeName].v.tank)=="table" then
            for k,v in pairs(self.info[activeName].v.tank) do
                cuut=cuut+tonumber(v)
            end

        end
        self.info[activeName].v.troops[3]=cuut
        local data = {[activeName] = self.info[activeName]}
        regSendMsg(self.uid,'active.change',data)
        return true;

    end


    -- 保存默认活动的数据
    function self.activedefaultinfo(activeName,params)
        self.info[activeName].v=params
    end


    function self.fbReward(sid)
        local  reward = {}
        if not sid then return reward end

        local activeCfg = getConfig("active")
        local pool = activeCfg.fbReward.serverreward.box

        setRandSeed()
        for _,v in ipairs(pool[sid]) do
            if rand(1,100) < v[2] then
                reward[v[1]] = (reward[v[1]] or 0) + v[3]
            end
        end

        return reward
    end

    --保存个人荣誉排行榜
    function  self.personalHonor(activeName,params)

        local score =params.score
        self.info[activeName].t=score
        setActiveRanking(self.uid,score,activeName,10,self.info[activeName].st)

    end

    --hardGetRich

    function self.hardGetRich(activeName,params)


        if type(self.info[activeName].res) ~='table' then  self.info[activeName].res={} end
        local r1 = params.r1
        local r2 = params.r2
        local r3 = params.r3
        local r4 = params.r4
        local gold = params.gold
        local getvalue = params.getvalue


        local function Log(logInfo,filename)
            local log = ""
            log = log .."uid=".. (logInfo.uid or ' ') .. "|"
            log = log .. "params="..json.encode(logInfo.params)

            filename = filename or 'hardGetRich'
            writeLog(log,filename)
        end
        --Log({uid=self.uid,params=params})
        if getvalue ~=nil and getvalue>0 then
            --local activeCfg = getConfig("active")
            local activeCfg = getConfig("active."..activeName.."."..self.info[activeName].cfg)

            local et = (self.getAcet('hardGetRich',true))

            return {activeCfg.condition,et}
        end

        if r1 ~=nil and r1>0 then 
            self.info[activeName].res.r1 =  (self.info[activeName].res.r1 or 0) +r1
            setActiveRanking(self.uid,self.info[activeName].res.r1,activeName..'r1',30,self.info[activeName].st)
        end
        if r2 ~=nil and r2>0 then
            self.info[activeName].res.r2 =  (self.info[activeName].res.r2 or 0) +r2
            setActiveRanking(self.uid,self.info[activeName].res.r2,activeName..'r2',30,self.info[activeName].st)
        end
        if r3 ~=nil and r3>0 then
            self.info[activeName].res.r3 =  (self.info[activeName].res.r3 or 0) +r3
            setActiveRanking(self.uid,self.info[activeName].res.r3,activeName..'r3',30,self.info[activeName].st)
        end
        if r4 ~=nil and r4>0 then
            self.info[activeName].res.r4 =  (self.info[activeName].res.r4 or 0) +r4
            setActiveRanking(self.uid,self.info[activeName].res.r4,activeName..'r4',30,self.info[activeName].st)
        end
        if gold ~=nil and gold>0 then
            self.info[activeName].res.gold =  (self.info[activeName].res.gold or 0) +gold
            setActiveRanking(self.uid,self.info[activeName].res.gold,activeName..'gold',30,self.info[activeName].st)
        end

    end

    function self.getpersonalHonor()

        local list = {}
        local result =getActiveRanking("personalHonor",self.info.personalHonor.st)
        if type(result) == "table" and next(result) then
            for k,v in pairs(result) do
                local item = {}
                if type(item) == "table" and next(result) then
                    item.uid = v[1]
                    item.rank = k
                    item.score = v[2]
                    table.insert(list,item)
                end
            end
        end
        return list
    end

    --保存个人关卡排行榜
    function self.personalCheckPoint(activeName,params)
        -- body
        local score =params.score
        self.info[activeName].t=score
        if self.info[activeName].re == nil then
            self.info[activeName].re = 0 
        end
        setActiveRanking(self.uid,score,activeName,10,self.info[activeName].st)

    end

    --排行榜进行修改
    function self.getRnklist(ranklist,activeName)

        local list = {}
        local redis = getRedis()
        local key = "z"..getZoneId()..".ac.rank."
        key=key..activeName
        local data = redis:get(key)
        local result=json.decode(data)
        -- ptb:p(ranklist)
        --ptb:p(result)
        if type(result)=='table' and next(result) then
            for k,v in pairs(ranklist)do
                --ptb:p(v)
                if type(result[k]) =='table' then

                    local uid = tonumber(v[1])
                    local score =tonumber(v[2])


                    local ouid = tonumber(result[k][1])
                    local oscore = tonumber(result[k][2])
                    if ouid~=uid and oscore==score then
                        -- print(uid)
                        --print(k)
                        list[k]=result[k]
                        local rank = 0
                        for i=tonumber(k),table.length(ranklist) do
                            if type(result[i])=='table' then
                                if tonumber(result[i][2])==score then
                                    --print(i)
                                    rank=i
                                end
                            end

                        end
                        if rank~=0 then
                            if type(ranklist[rank])=='table' then
                                list[rank]=ranklist[k]
                            end

                        end


                    else
                        if type(list[k]) ~='table' then
                            list[k]=v
                        end

                    end



                else
                    if type(list[k]) ~='table' then
                        list[k]=v
                    end
                end



            end




        else
            list=ranklist
        end
        --ptb:e(list)
        return list
    end

    --获取个人关卡排行榜
    function self.getpersonalCheckPoint()


        local result =getActiveRanking("personalCheckPoint",self.info.personalCheckPoint.st)
        local list = {}
        if type(result) == "table" and next(result) then
            for k,v in pairs(result) do
                local item = {}
                if type(item) == "table" and next(result) then
                    item.uid = v[1]
                    item.rank = k
                    item.score = v[2]
                    table.insert(list,item)
                end
            end
        end
        -- ptb:e(list)
        return list
    end



    --军团收获日、

    function self.setHarvestDay(params)
        local activeName = "harvestDay"
        -- body
        -- v 是存储参战次数
        -- t 存储排名前十的次数
        -- c 是存储胜利次数
        local key = "z"..getZoneId()..".ac.harvestDay"..self.info.harvestDay.st

        local alliance = params.alliance
        local num = params.num
        local activeName = "harvestDay"
        if num~=nil then
            self.info[activeName].v=self.info[activeName].v+1
        end

        if type(alliance)=="table" and next(alliance) then
            local redis = getRedis()
            local data = redis:get(key)
            local result=json.decode(data)
            if type(result)~="table" then  result={}  end
            for k,aid in pairs(alliance) do
                local naid =tostring("a"..aid)
                result[naid]=(result[naid] or 0) + 1
            end
            local data = json.encode(result)
            local reuslt = redis:set(key,data)
            local expireTime = self.getActiveCacheExpireTime(activeName,172800)
            redis:expire(key,expireTime)
        end
    end
    --军团收获日获取自己军团在活动期间排前十名的次数

    function self.getalliacerankcount(naid)
        -- body
        local key = "z"..getZoneId()..".ac.harvestDay"..self.info.harvestDay.st
        local redis = getRedis()
        local data = redis:get(key)
        local result=json.decode(data)
        local count = 0
        if type(result)=="table" then
            for aid,v in pairs(result) do
                if aid==naid then
                    count=v
                end
            end
        end

        return count
    end


    --保存活动中个人战力排行榜
    function self.fightRank(activeName,params)
        local score =params.score
        setActiveRanking(self.uid,score,activeName,30,self.info[activeName].st)
    end


    function self.baseLeveling(level)
        self.info.baseLeveling.c = level
        if(type(self.info.baseLeveling.t)~='table')then
            self.info.baseLeveling.t={}
        end
        --self.info.leveling.v = 0
    end
    
    function self.bindbaseLeveling(activeName,level)
        self.info.bindbaseLeveling.c = level
        if(type(self.info.bindbaseLeveling.t)~='table')then
            self.info.bindbaseLeveling.t={}
        end
        --self.info.leveling.v = 0
    end


    function self.getfightRank(pagestart,pageend,useruid)

        local list = {}
        local result =getActiveRanking("fightRank",self.info.fightRank.st)
        local mylist = {}
        local start = 0
        if(type(result)=='table')and next(result) then
            for k,v in pairs(result) do
                local item = {}
                if type(item) == "table" and next(result) then

                    local uid = tonumber(v[1])
                    if uid>0 then
                        local uobjs = getUserObjs(uid,true)
                        local userinfo = uobjs.getModel('userinfo')
                        if(uid==useruid) then


                            --mylist.uid =
                            table.insert(mylist,userinfo.uid)
                            table.insert(mylist,userinfo.nickname)
                            --table.insert(item,userinfo.level)
                            table.insert(mylist,start+k)
                            table.insert(mylist,v[2])
                            if(userinfo.alliance>0)then
                                table.insert(mylist,userinfo.alliancename)
                            end
                        end

                        if(k>=pagestart and k<=pageend) then

                            local item = {}

                            table.insert(item,userinfo.uid)
                            table.insert(item,userinfo.nickname)
                            --table.insert(item,userinfo.level)
                            table.insert(item,start+k)
                            table.insert(item,v[2])
                            if(userinfo.alliance>0)then
                                table.insert(item,userinfo.alliancename)
                            end
                            table.insert(list,item)
                        end
                    end
                end
            end
        end
        return list,mylist
    end

    function self.luckUp(name,item,value)
        local activeCfg = getConfig("active")
        local cfg = activeCfg.luckUp.data[name]
        if cfg then
            value = value + math.ceil(value * (cfg[item] or 0))
        end

        return value
    end

    function self.wheelFortune(cost,activeName)
        local weeTs = getWeeTs()
        if self.info[activeName].t ~= weeTs then
            self.info[activeName].t = weeTs
            self.info[activeName].c = 0
            self.info[activeName].un = 0
        end

        self.info[activeName].un = (self.info[activeName].un or 0) + cost

        local data = {[activeName] = self.info[activeName]}
        regSendMsg(self.uid,'active.change',data)
    end

    --七夕
    function self.qixi(activeName,params)
        --更新累计消费值
        self.info[activeName].v = (self.info[activeName].v or 0) + params.value
        --推送
        local data = {[activeName] = self.info[activeName]}
        regSendMsg(self.uid,'active.change',data)
    end

    --月度签到
    function self.monthlysign(activeName,params)
        --更新付费领奖
        local cfg = getActiveCfg(self.uid, activeName)  
        local starWeets = getWeeTs(self.info[activeName].st)
        local nowWeets = getWeeTs()
        local nDay = math.floor( (nowWeets - starWeets) / 86400 ) + 1
        if params.gems <= 0 then
            return false
        end

        -- 准备数据
        if type(self.info[activeName].p) ~= 'table' then
             self.info[activeName].p = {}
        end
        --已经领取过了
        if self.info[activeName].p[nDay] and self.info[activeName].p[nDay] ~= 0 then
            return false
        end 
        for i=1, nDay-1 do
            self.info[activeName].p[i] = self.info[activeName].p[i] or 0
        end
        self.info[activeName].p[nDay] = 2 -- 0 不能领 、2可以领 、 3已经领

        --推送
        local data = {[activeName] = self.info[activeName]}
        regSendMsg(self.uid,'active.change',data)
    end

    -- 月度签到统计
    function self.setmonthlysignStats( params )
        local activeName = "monthlysign"
        local stats,key = self.getStats( activeName, params.day )

        if type(stats) ~= 'table' then stats = {} end

        -- 统计每天免费领奖人数和付费领奖人数
        if params.action == 0 then
            stats["free"] = (stats["free"] or 0) + 1
        else
            stats["pay"] = (stats["pay"] or 0) + 1
        end

        local redis = getRedis()
        local ret = redis:hset(key, params.speedtype, json.encode(stats))
        local expireTime = self.getActiveCacheExpireTime(activeName)
        redis:expire(key,expireTime)

        return ret        


    end    

    function self.superEquipEvent(aname, params)
        if type(params)~='table' or not tonumber(params.color) or not tonumber(params.num) then
            return false
        end

        --装备进阶 
        self.info[aname].sv = self.info[aname].sv or {}

        for i=1, params.color do 
            self.info[aname].sv[i] =self.info[aname].sv[i] or 0
        end

        self.info[aname].sv[ params.color ] = self.info[aname].sv[ params.color ] + params.num

        -- 推送
        local data = {[aname] = self.info[aname]}
        regSendMsg(self.uid,'active.change',data)

        return true
    end

    -- 勇往直前活动
    function self.yongwangzhiqian(aname, params)
        local activeCfg = self.getActiveConfig(aname)
        local ts = getClientTs()
        local weeTs = getWeeTs()
        local send = 0
        
        if not self.info[aname].t or getWeeTs(self.info[aname].t) < weeTs then
            self.info[aname].t = weeTs
            self.info[aname].r = {}
        end
        
        -- 增加经验值
        if params.action == 'getExp' then
            local addExp = tonumber(params.exp)
            --最终经验=基础经验*(1+其他加成+本活动加成)
            return math.ceil(addExp * activeCfg.activeExp)
        end
        -- 水晶修理打折
        if params.action == 'getResDiscount' then
            return math.ceil(params.num * activeCfg.activeRes)
        end
        
        -- 关卡通过
        if params.action == 'pass' then
            if not self.info[aname].p then
                self.info[aname].p = {}
            end
            
            local sid = params.sid
            local win = params.win
            local passChallenge = activeCfg.passChallenge
            if win == 1 and passChallenge['s'..sid] then
                if not self.info[aname].p['s'..sid] then
                    self.info[aname].p['s'..sid] = {}
                end
                self.info[aname].p['s'..sid].n = (self.info[aname].p['s'..sid].n or 0) + 1
            end

            if not self.info[aname].r then
                self.info[aname].r = {}
            end
            
            self.info[aname].r.n = (self.info[aname].r.n or 0) + 1
            self.info[aname].t = ts
            send = 1
        end
        
        --扫荡
        if params.action == 'raid' then
            if not self.info[aname].p then
                self.info[aname].p = {}
            end
            
            local sid = params.sid
            local raidcnt = tonumber( params.raidcnt ) or 0
            local passcnt = tonumber(params.passcnt) or 0
            local passChallenge = activeCfg.passChallenge
            if passcnt >= 1 and passChallenge['s'..sid] then
                if not self.info[aname].p['s'..sid] then
                    self.info[aname].p['s'..sid] = {}
                end
                self.info[aname].p['s'..sid].n = (self.info[aname].p['s'..sid].n or 0) + passcnt
            end

            if not self.info[aname].r then
                self.info[aname].r = {}
            end
            
            self.info[aname].r.n = (self.info[aname].r.n or 0) + raidcnt
            self.info[aname].t = ts
            send = 1
        end

        if send == 1 then
            local data = {[aname] = self.info[aname]}
            regSendMsg(self.uid,'active.change',data)
        end
    end

    --百服活动
    function self.hundredactive(aname,params)
        local res = 0
        for k, v in pairs(params.res) do 
            res = res + tonumber(v)
        end
        --统计全局资源
        local freedata = getFreeData(aname)
        --检测初始化
        if type(freedata) ~= 'table' or type(freedata.info) ~= 'table' or
            freedata.info.st ~= self.info[aname].st then
            freedata = freedata or {}
            --{活动开始时间戳，资源总量}
            freedata.info = {st=self.info[aname].st,  res=0} 
        end 

        freedata.info.res = tonumber(freedata.info.res) + tonumber(res)
        setFreeData(aname, freedata.info)
        --推送
        local data = {[aname] = self.info[aname]}
        regSendMsg(self.uid,'active.change',data)
    end

    -- 百服活动统计
    function self.sethundredactiveStats( params )
        local activeName = "hundredactive"
        local stats,key = self.getStats( activeName, nil, 1 )

        if type(stats) ~= 'table' then stats = {} end
	
    	-- 统计该服购买各档次奖励的人数
    	params.idx = tonumber(params.idx)
    	if not params.idx then
    		return 
    	end
    	
    	if not stats[params.idx] then
    		for i=1, params.idx do
    			stats[i] = stats[i] or 0
    		end
    	end
    	stats[params.idx] = stats[params.idx] + 1
        local redis = getRedis()
        local ret = redis:set(key, json.encode(stats))
        local expireTime = self.getActiveCacheExpireTime(activeName)
        redis:expire(key,expireTime)

        return ret

    end

    --复活节彩蛋大搜寻
    function self.searchEasterEgg(aname,params)
        --彩蛋分别来
        local eggtype, eggcnt
        if params.egg1 and tonumber(params.egg1) > 0 then
            eggtype = "egg1"
            eggcnt = tonumber(params.egg1)
        elseif params.egg2 and tonumber(params.egg2) > 0  then
            eggtype = "egg2"
            eggcnt = tonumber(params.egg2)
        elseif params.egg3 and tonumber(params.egg3) > 0  then
            eggtype = "egg3"
            eggcnt = tonumber(params.egg3)
        else
            return false
        end

        local activeCfg = self.getActiveConfig(aname)
        local cfgRate = activeCfg[eggtype .. "Probability"] or 0
        --未命中
        local hitcnt = 0
        for i=1, eggcnt do
            if rand(1,100) <= (cfgRate*100) then
                hitcnt = hitcnt + 1 
            end
        end
        if hitcnt <= 0 then
            return false
        end

        self.info[aname][eggtype] = (self.info[aname][eggtype] or 0) + hitcnt
        --推送
        local data = {[aname] = self.info[aname]}
        regSendMsg(self.uid,'active.change',data)

        return {[eggtype]=hitcnt}
    end

    -- 复活节彩蛋大搜寻 统计
    function self.setsearchEasterEggStats( params )
        local activeName = "searchEasterEgg"
        -- 记录每档彩蛋兑换数量  
        local stats,key = self.getStats(activeName, nil , 1)
        params.idx = tonumber(params.idx)
        if not params.idx then
            return 
        end
        
        if not stats[params.idx] then
            for i=1, params.idx do
                stats[i] = stats[i] or 0
            end
        end
        stats[params.idx] = stats[params.idx] + 1
        local redis = getRedis()
        local ret = redis:set(key, json.encode(stats))
        local expireTime = self.getActiveCacheExpireTime(activeName)
        redis:expire(key,expireTime)

        return ret

    end

    --战争守护
    function self.attackedProtect(aname, params)
        -- body
        local activeCfg = self.getActiveConfig(aname)

        return activeCfg.surviveRate or 0
    end

    --复活节礼包
    function self.eastergift(aname,params)
        --充值奖励
        if not params and not tonumber(params.gems) then
            return 
        end
        self.info[aname].v = (self.info[aname].v or 0) + tonumber(params.gems)

        local push = false
        local activeCfg = self.getActiveConfig(aname)
        for k, v in pairs(activeCfg.serverreward) do
            if tonumber(self.info[aname].v) >= tonumber(v.rechange) and not self.info[aname]["r"..k] then
                self.info[aname]["r"..k] = 1 --可以领取
                push = true
            end 
        end

        if push then
            local data = {[aname] = self.info[aname]}
            regSendMsg(self.uid,'active.change',data)
        end

        return true
    end

    function self.totalRecharge(cost)
        self.info.totalRecharge.v = (self.info.totalRecharge.v or 0) + cost
        local activeCfg = getActiveCfg(self.uid, "totalRecharge")

        local currentGetNum = 1
        local currentCost = activeCfg.serverreward.cost[currentGetNum] or 0
        local gold = currentCost
        if self.info.totalRecharge.v >= gold then
            self.settotalRechargeStats({uid=self.uid})
        end

    end

    -- 绑定类 累计充值活动
    function self.bindTotalRecharge(aname,params)
        local uobjs = getUserObjs(self.uid)
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = getConfig("active."..aname)

        -- 不在活动期间内
        local regDays =  ((getWeeTs() - getWeeTs(mUserinfo.regdate)) / 86400) + 1
        if regDays < activeCfg.bindTime[1] or regDays > activeCfg.bindTime[2] then
            return
        end

        local cost = params.num
        
        self.info.bindTotalRecharge.v = (self.info.bindTotalRecharge.v or 0) + cost
    end


    --基金活动
    function self.userFund(cost)

        local st  = self.info.userFund.st
        local stweets  = getWeeTs(st)
        local activeCfg = getConfig("active.userFund."..self.info.userFund.cfg)
        local changeday = tonumber(activeCfg.chargeday)
        local ts = getClientTs()
        if ts > (stweets+changeday*86400) then
            return true
        end

        self.info.userFund.v = (self.info.userFund.v or 0) + cost
        local newcost  = self.info.userFund.v
        for k,v in pairs(activeCfg.cost) do
            if newcost>=v then
                self.info.userFund.t=k
            end
        end

    end

    --投资计划
    function self.InvestPlan(cost)
        local st  = self.info.investPlan.st
        local stweets  = getWeeTs(st)
        local activeCfg = getConfig("active.investPlan")
        local changeday = tonumber(activeCfg.chargeday)
        local ts = getClientTs()
        if ts > (stweets+changeday*86400) then
            return true
        end

        self.info.investPlan.v = (self.info.investPlan.v or 0) + cost
        local newcost  = self.info.investPlan.v
        for k,v in pairs(activeCfg.cost) do
            if newcost>=v then
                self.info.investPlan.t=k
            end
        end

    end

    --VIP总动员活动
    function self.VipAction(cost)

        local weeTs = getWeeTs()

        if self.info.vipAction.t ~= weeTs then
            self.info.vipAction.t = weeTs
            self.info.vipAction.v = 0
            self.info.vipAction.vc = {}
        end
        self.info.vipAction.v = (self.info.vipAction.v or 0) + cost
        self.info.vipAction.r = (self.info.vipAction.r or 0) + cost

    end

    -- 充值红包
    function self.rechargebag(activeName, params)
        -- 送红包对应慷慨值字段的后缀
        local bagTarge = {
            ['p3306'] = '',
            ['p3309'] = '1',
            ['p3311'] = '2',
        }
        
        local activeCfg = self.getActiveConfig(activeName)
        local point = activeCfg['point'..(bagTarge[params.pid] or '')]
        local push=false
        if params.gems~=nil and params.gems>0 then
            push=true
            self.info[activeName].v=self.info[activeName].v+params.gems
            local limit=self.info[activeName].v-activeCfg.limit
            if limit>0 then
                local count=math.floor(limit/activeCfg.need)
                local l=self.info[activeName].l or 0
                if count>l then
                    self.info[activeName].l=count
                end
            end
        end
        --送红包得慷慨值
        local acet = self.getAcet(activeName,true)
        local ts   = getClientTs()
        if acet>=ts and   params.send~=nil then
            self.info[activeName].c=self.info[activeName].c + math.floor(point * params.send)
            if self.info[activeName].c>=activeCfg.needPoint then
                setActiveRanking(uid,self.info[activeName].c,activeName,10,self.info[activeName].st,self.info[activeName].et)
            end
            push=true
        end
        if push then
            local data = {[activeName] = self.info[activeName]}
            regSendMsg(self.uid,'active.change',data)
        end
    end

    --充值回馈
    function self.rechargeFeedback(activeName, params)
        if not tonumber(params.gems) or tonumber(params.gems)<=0 then
            return 
        end

        local activeCfg = self.getActiveConfig(activeName)
        local addgems = math.floor( tonumber(params.gems) * activeCfg.rechargeRewardRadio )
        if not arrayIndex(activeCfg.rechargeCost, params.gems) then
            return 
        end
        local uobjs = getUserObjs(self.uid)
        local mUserinfo = uobjs.getModel('userinfo')
        local ret =mUserinfo.addResource({gems=addgems})

        if not ret then
            writeLog({uid=self.uid, gems=params.gems, extgems=addgems, ts=getClientTs()} , activeName)
        end
    end

    function self.rechargeRebate(cost)
        if self.info.rechargeRebate.c==0 then
            --日本平台自己配置
            if getClientPlat() == 'gNet_jp' then
                if not self.info.rechargeRebate.flag then
                    require "model.active"
                    local mActive = model_active()
                    --自定义配置文件
                    local activeCfg = mActive.selfCfg('rechargeRebate')
                    local addgems = math.ceil(activeCfg.serverreward.userinfo_gems*cost)
                    takeReward(self.uid, {userinfo_gems=addgems})
                    self.info.rechargeRebate.c=0
                    self.info.rechargeRebate.flag=addgems
                end
                return true
            end
            local aname = 'rechargeRebate'
            --其他平台
            --local activeCfg = getConfig("active.rechargeRebate") ---旧的取配置方法

            local activeCfg = getConfig("active.rechargeRebate."..self.info.rechargeRebate.cfg)--多版本
            local addgems = math.ceil(activeCfg.serverreward.userinfo_gems*cost)
            self.info.rechargeRebate.c=addgems
        end
    end

    --充值有礼
    function self.chongzhiyouli(aname, params)

        local cost = tonumber(params.num) or 0
        local weelTs = getWeeTs()
        if self.info[aname].t < weelTs then
            self.info[aname].v = 0
            self.info[aname].t = weelTs
        end

        if type(self.info[aname].v) ~= "number" then
            self.info[aname].v = 0
        end

        self.info[aname].v = self.info[aname].v + cost
        return true
    end

    --充值返利日本
    function self.customRechargeRebate(aname, params)
        --验证充值双倍活动
        local cost = params.num
        require "model.active"
        local mActive = model_active()
        --自定义配置文件
        local activeCfg = mActive.selfCfg('customRechargeRebate')
        local addgems = math.ceil(activeCfg.serverreward.userinfo_gems*cost)
        takeReward(self.uid, {userinfo_gems=addgems})
        return true
    end

    function self.dayRecharge(cost)
        local weeTs = getWeeTs()

        if self.info.dayRecharge.t ~= weeTs then
            self.info.dayRecharge.t = weeTs
            self.info.dayRecharge.c = 0
            self.info.dayRecharge.v = 0
        end

        self.info.dayRecharge.d = (self.info.dayRecharge.d or 0) + cost
        self.info.dayRecharge.v = (self.info.dayRecharge.v or 0) + cost
    end

    -- 绑定型 每日充值送礼
    function self.bindDayRecharge(activeName,params)
        local cost = params.num
        local weeTs = getWeeTs()
        
        local uobjs = getUserObjs(self.uid)
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = getConfig("active."..activeName)

        -- 不在活动期间内
        local regDays =  ((getWeeTs() - getWeeTs(mUserinfo.regdate)) / 86400) + 1
        if regDays < activeCfg.bindTime[1] or regDays > activeCfg.bindTime[2] then
            return
        end 
        

        if self.info.bindDayRecharge.t ~= weeTs then
            self.info.bindDayRecharge.t = weeTs
            self.info.bindDayRecharge.c = 0
            self.info.bindDayRecharge.v = 0
            self.info.bindDayRecharge.rs = {}
        end

        self.info.bindDayRecharge.d = (self.info.bindDayRecharge.d or 0) + cost
        self.info.bindDayRecharge.v = (self.info.bindDayRecharge.v or 0) + cost
    end

    --每日充值送配件
    function self.dayRechargeForEquip(cost)
        local weeTs = getWeeTs()

        if self.info.dayRechargeForEquip.t ~= weeTs then
            self.info.dayRechargeForEquip.t = weeTs
            self.info.dayRechargeForEquip.c = 0
            self.info.dayRechargeForEquip.v = 0
        end

        self.info.dayRechargeForEquip.d = (self.info.dayRechargeForEquip.d or 0) + cost
        self.info.dayRechargeForEquip.v = (self.info.dayRechargeForEquip.v or 0) + cost

    end

    -- 水晶丰收
    function self.crystalHarvest(params,activeName)
        activeName = activeName or "crystalHarvest"
        local activeCfg = getConfig("active." .. activeName)

        -- 道具限量出售
        if params.pid then
            if type(self.info[activeName].d) ~= 'table' then
                self.info[activeName].d = {}
            end

            -- 折扣值
            local disN = activeCfg.props[params.pid]

            -- 购买次数有限制
            if disN and (self.info[activeName].d[params.pid] or 0) < activeCfg.maxCount[params.pid] then
                local disGems = math.ceil(params.gems * disN)
                if disGems > 0 then
                    self.info[activeName].d[params.pid] = (self.info[activeName].d[params.pid] or 0) + 1
                    return disGems
                end
            end

            return nil
        end

        -- 水晶翻倍
        if params.name == 'updateResources' then
            return {activeCfg.baseGoldGrow,self.info[activeName].st,self.info[activeName].et}
        end
    end

    -- 巨兽再现
    function self.monsterComeback(params)
        local activeName = 'monsterComeback'

        if type(params.destroyTanks) == 'table' then
            local activeCfg = getConfig("active." .. activeName)
            local point = 0
            local tankCfg = getConfig('tank')
            for k,v in pairs(params.destroyTanks) do
                point = point + (tankCfg[k].tankPoint or 0) * v
            end

            self.info[activeName].point = (self.info[activeName].point or 0) + point

            local data = {monsterComeback = self.info[activeName]}
            regSendMsg(self.uid,'active.change',data)
        end
    end

    -- vip特权宝箱活动
    function self.vipRight(params)
        activeName = 'vipRight'

        local weeTs = getWeeTs()
        local activeCfg = getConfig("active." .. activeName)
        local pid = params.pid
        local vip = params.vip

        if activeCfg.serverreward[pid] then
            if type(self.info[activeName].d) ~= 'table' or (self.info[activeName].ts or 0) < weeTs  then
                self.info[activeName].d = {}
            end

            local canBuyNum =  activeCfg.serverreward[pid].num4Vip[(vip + 1)]

            if canBuyNum and canBuyNum > 0 then
                self.info[activeName].d[pid] = self.info[activeName].d[pid] or 0
                if self.info[activeName].d[pid] < canBuyNum then
                    if activeCfg.serverreward[pid].cost > 0 then
                        self.info[activeName].d[pid] = self.info[activeName].d[pid] + 1
                        self.info[activeName].ts = weeTs

                        local log = {uid=self.uid,pid=pid,cost=activeCfg.serverreward[pid].cost,totalNums=self.info[activeName].d[pid]}
                        writeLog(log,activeName)

                        return activeCfg.serverreward[pid].cost
                    end
                end
            end
        end
    end

    -- 前线军需活动
    function self.rechargeDouble(params)
        activeName = 'rechargeDouble'

        local cost = 0
        if getClientPlat() == 'efun_tw' then
            local payCfg = getConfig("pay")
            for k,v in pairs(payCfg) do
                if params.num >= v then
                    cost = v
                end
            end
        else
            cost = params.num
        end

        if cost > 0 and cost <= 10000 then
            if type(self.info[activeName].d) ~= 'table' then
                self.info[activeName].d = {}
            end

            local costKey = 'p' .. cost
            if not self.info[activeName].d[costKey] then
                self.info[activeName].d[costKey] = cost
            end
        end
    end

    --战备军需
    function self.rechargeFight(activeName,params)
        local cfg = self.getActiveConfig(activeName)
        self.info[activeName].c = self.info[activeName].c or 0 --可以领取的钻石
        self.info[activeName].v = self.info[activeName].v or 0 --已经领取的钻石
        if cfg.rechargeUppLimit <= self.info[activeName].c then
            return true
        end

        self.info[activeName].c = self.info[activeName].c + math.floor(params.num * cfg.rechargeRewardRadio)
        if self.info[activeName].c > cfg.rechargeUppLimit then
            self.info[activeName].c = cfg.rechargeUppLimit
        end

        local data = {[activeName] = self.info[activeName]}
        regSendMsg(self.uid,'active.change', data)

        --搜集统计
        self.setStats(activeName, params)        

    end

    function self.openGift(activeName,params)
        activeName = 'openGift'
        local activeCfg = getConfig("active." .. activeName)
        local shop = {}

        local cfg = self.getActiveCfgByCache(activeName)

        if not cfg then
            cfg = {}
            local pool = table.rand(copyTable(activeCfg.buy))
            for i=1,7 do
                table.insert(cfg,{pool[i*2-1].id,pool[i*2].id})
            end

            self.setActiveCfgToCache(activeName,cfg)
        end

        local day = math.floor((getWeeTs() - getWeeTs(self.info[activeName].st)) / 86400)
        if day < 0 then return false end

        day = day + 1

        if day <= 7 then

            for _,v in ipairs(cfg[day]) do
                table.insert(shop,activeCfg.buy[v])
            end
        else
            local d = day % 7
            if ( d == 0 and day > 0 ) then d = 7 end
            for _,v in ipairs(cfg[d]) do
                table.insert(shop,activeCfg.buy[v])
            end
        end

        -- 获取商品
        if params.getshop == 1 then
            return shop
        end

        local pid = params.pid
        local gems = params.gems
        -- local info = params.info

        if type(self.info[activeName].d) ~= 'table' then
            self.info[activeName].d = {}
        end

        -- 加上字串d或tostring一下，解决jsonencode的问题
        day = "d" .. day

        if type(self.info[activeName].d[day]) ~= 'table' then
            self.info[activeName].d[day] = {}
        end

        for _,v in ipairs(shop) do
            if v.gift == pid then
                if (self.info[activeName].d[day][pid] or 0 ) < v.num then
                    self.info[activeName].d[day][pid] = (self.info[activeName].d[day][pid] or 0) + 1
                    local cost = math.ceil(gems * v.discount)
                    local log = {
                        uid=self.uid,
                        pid=pid,
                        cost=cost,
                        totalNums=self.info[activeName].d[day].pid
                    }
                    writeLog(log,activeName)

                    return cost
                end
            end
        end
    end

    function self.wheelFortune4(activeName,params)
        if type(self.info[activeName].d) ~= 'table' then
            self.info[activeName].d = {}
        end

        --  重置数据
        local weeTs = getWeeTs()
        if params.reset or weeTs ~= self.info[activeName].t then
            self.info[activeName].d.n = 0 -- 每日抽奖次数
            self.info[activeName].d.fn = {} -- 每日免费次数
            self.info[activeName].t = weeTs -- 重置后的时间
            self.info[activeName].c = 0 -- 当天使用过的次数
            self.info[activeName].vip = 0 -- 为了统计vip用户（如果统计过了，则此值会大于0）
            self.info[activeName].d.feed = 0 -- 分享获得的抽奖次数

            -- 重置数据后直接返回
            if params.reset then return true end
        end

        -- 分享，增加一次抽奖机会
        if params.feed and self.info[activeName].d.feed == 0 then
            local n = 1 -- from config ?
            self.info[activeName].d.n = (self.info[activeName].d.n or 0) + n
            self.info[activeName].d.feed = n
        end

        -- 免费送次数（每天两次）
        if params.freeNum then
            local activeCfg = getConfig("active")
            local ts = getClientTs()
            for k,v in pairs(activeCfg[activeName].startTime) do
                if ( self.info[activeName].d.fn[k] or 0 ) < 1 then
                    local freeTimeStart = weeTs + (v[1] * 3600 + v[2] * 60)
                    local freeTimeEnd = freeTimeStart + activeCfg[activeName].durationTime
                    if ts >=  freeTimeStart and ts <= freeTimeEnd then
                        self.info[activeName].d.n = (self.info[activeName].d.n or 0) + 1
                        self.info[activeName].d.fn[k] = (self.info[activeName].d.fn[k] or 0) + 1
                        break
                    end
                end
            end
        end

        -- 充值，将额度折算成次数，余额保留
        -- un usenum
        if params.recharge and params.recharge > 0 then
            local activeCfg = getConfig("active")
            self.info[activeName].d.un = (self.info[activeName].d.un or 0) + params.recharge
            local un2num = math.floor(self.info[activeName].d.un / activeCfg[activeName].lotteryConsume)
            self.info[activeName].d.n = (self.info[activeName].d.n or 0) + un2num
            self.info[activeName].d.un = self.info[activeName].d.un - un2num * activeCfg[activeName].lotteryConsume
        end

        if params.setreport and params.uid and params.reward then
            local cKey = getActiveCacheKey(activeName,"report",self.info[activeName].st)
            local redis = getRedis()
            local ret = redis:rpush(cKey,json.encode{params.uid,params.reward,params.sort})
            local expireTime = self.getActiveCacheExpireTime(activeName)
            redis:expire(cKey,expireTime)

            return ret
        end

        if params.getreport then
            local report = {}

            local cKey = getActiveCacheKey(activeName,"report",self.info[activeName].st)
            local redis = getRedis()
            local result = redis:lrange(cKey,0,-1)

            if type (result) == "table" then
                for k,v in pairs(result) do
                    report[k] = json.decode(v) or v
                end
            end

            return report
        end

    end

    -- 愚人节2018活动
    function self.foolday2018(activeName,params)
        local activeInfo = self.info[activeName]
        local activeCfg = self.getActiveConfig(activeName)

        local ts= getClientTs()
        if ts > tonumber(self.getAcet(activeName, true)) then
            return false
        end

        -- 充值行为还会触发任务,这里取巧直接把act换一下
        if params.act == "charge" then
            if params.num > 0 then
                activeInfo.gem = (activeInfo.gem or 0) + params.num
            end

            params.act = "task"
            params.tp = "gb"
            params.num = params.num
        end

        if params.act == "task" then
            if type(activeInfo.task) == "table" and activeInfo.task.tp == params.tp and activeInfo.c < activeCfg.taskLimit then
                activeInfo.task.num = activeInfo.task.num + params.num
                local maxNum = activeCfg.taskList[activeInfo.task.id].num
                if activeInfo.task.num > maxNum then
                    activeInfo.task.num = maxNum
                end
            end

            -- 如果有军团,检测任务
            local aid = getUserObjs(self.uid).getModel('userinfo').alliance
            if aid > 0 then
                local mAllianceActive = getModelObjs("allianceactive",aid,false,true)
                if mAllianceActive then
                    mAllianceActive.getActiveObj(activeName):setTask(params)
                else
                    writeLog({msg="foolday2018.setTask error",aid=aid,params=params.point})
                end
            end
        elseif params.act == "newtask" then
            if activeInfo.c < activeCfg.taskLimit then
                local taskKey = getRewardByPool(activeCfg.randompool)[1]
                local id = activeCfg.randtaskpool[taskKey][1]
                activeInfo.task = {tp=taskKey,num=0,id=id}
            end
        elseif params.act == "clean" then
            activeInfo.task = nil -- 任务清空
            activeInfo.c = 0  -- activeCfg.taskLimit 每日任务数上限
            activeInfo.rn = 0 -- 刷新任务次数(收费)
            activeInfo.t = getClientTs()

            if activeInfo.rd then
                activeInfo.rd = bit32.band(activeInfo.rd, bit32.bnot(16))
            end
        elseif params.act == "takeReward" then
            if not activeInfo.items then 
                activeInfo.items = {}
            end

            -- params.reward[1] 第一位放的是活动相关的道具
            for k,v in pairs(params.reward) do
                activeInfo.items[k] = (activeInfo.items[k] or 0) + v
            end

            -- if params.rflag then
            --     activeInfo.rd =  bit32.bor((activeInfo.rd or 0),rflag)
            -- end
        elseif params.act == "addPoint" then
            params.point = math.floor(params.point)
            if params.point > 0 then
                activeInfo.p1 = (activeInfo.p1 or 0) + params.point -- 自己获得的总积分

                -- 如果有军团
                local mUserinfo = getUserObjs(self.uid).getModel('userinfo')
                local aid = mUserinfo.alliance
                if aid > 0 then
                    local mAllianceActive = getModelObjs("allianceactive",aid,false,true)
                    if mAllianceActive then
                        params.allianceName=mUserinfo.alliancename
                        return mAllianceActive.getActiveObj(activeName):addPoint(params)
                    else
                        writeLog({msg="foolday2018.addPoint error",aid=aid,point=params.point})
                    end
                end
            end
        elseif params.act == "quitAlliance" then
            if (activeInfo.p1 or 0) > 0 then
                local aid = params.aid
                if aid > 0 then
                    local mAllianceActive = getModelObjs("allianceactive",aid,false,true)
                    if mAllianceActive then
                        return mAllianceActive.getActiveObj(activeName):subPoint(activeInfo.p1)
                    end
                end

                activeInfo.p1 = 0
            end
        end
    end

    -- end active set--------------------------------------------------------------------------------------------

    -- activeName 活动名称
    function self.finish(activeName)
        local ts = getClientTs()
        local activeCfg = getConfig("active")

        -- 完成标志
        local flag = true

        if self.info[activeName] and (self.info[activeName].v > 0 and self.info[activeName].c >= self.info[activeName].v) then
            local reward = self.getActiveReward(activeName)

            -- 消费送礼（轮回）
            if self.info[activeName].type == 3 then
                if self.info[activeName].c > activeCfg[activeName].consume then
                    local count = math.floor(self.info[activeName].c/activeCfg[activeName].consume)
                    self.info[activeName].c = self.info[activeName].c - (activeCfg[activeName].consume * count)

                    for m,n in pairs(reward) do
                        reward[m] = count
                    end
                end
            else
                self.info[activeName].c = -self.info[activeName].c
            end

            -- 是否设置完成时间
            -- self.info[activeName].ft = ts
            if reward and next(reward) then
                flag = takeReward(self.uid,reward)
            end
        end

        return flag
    end

    function self.getActiveReward(activeName)
        local activeCfg = getConfig("active")
        local reward = {}

        if activeCfg[activeName] and type(activeCfg[activeName].serverreward) == 'table' then
            for k, v in pairs(activeCfg[activeName].serverreward) do
                if type(v) == "string" and (string.find(v,'@')) == 1  then
                    reward[k] = self.info[activeName][string.sub(v,2)] or 0
                else
                    reward[k] = v
                end
            end
        end

        return reward
    end

    -- 获到当前活动的状态
    -- -1984 活动已完成（c已经小于0了）
    -- -1985 活动未开始
    -- -1986 活动已过期
    -- rewardTs 是否预留领奖时间
    function self.getActiveStatus(activeName,rewardTs)
        rewardTs = rewardTs and 86400 or 0

        local ts = getClientTs()

        if not self.info[activeName] then
            return -1977
        end

        if self.info[activeName].c < 0 then
            return -1984
        end

        if self.info[activeName].st > ts then
            return -1985
        end

        if  self.info[activeName].et <= (ts + rewardTs) then
            return -1986
        end

        return 1
    end

    -- 是否可以领奖
    function self.isTakeReward(activeName)
        local status = self.getActiveStatus(activeName)
        if  status == 1  then
            local ts = getClientTs()

            if (self.info[activeName].et > ts and self.info[activeName].et - ts < 86400) then
                return status
            end

            status = -1978
        end

        return status
    end

    -- 获取活动统计数据，支持用hashtable存储的数据格式
    -- string activeName
    -- field 具体项
    -- return table
    function self.getStats(activeName,field,dataType)
        if not activeName then return {} end

        local key = "z"..getZoneId()..".ac.stats." .. tostring(activeName)
        local redis = getRedis()

        local result
        --缓存不用hash
        local settable = {

            baseLeveling=1,
            fightRank=1,
            allianceFight=1,
            allianceLevel=1,
            totalRecharge=1,
            totalRecharge2 = 1,
            rechargeRebate=1,
            allianceDonate=1,
            userFund =1,
            harvestDay=1,
            bindbaseLeveling=1,
        }


        if(settable[activeName]==1) or dataType == 1 then

            result=redis:get(key)
        else
            if field then
                result = redis:hget(key,tostring(field))
            else
                result = redis:hgetall(key)
            end

        end



        result = result and json.decode(result) or {}

        return result,key
    end

    -- 设置活动统计数据
    -- string activeName
    -- params 具体的参数
    -- return bool
    function self.setStats(activeName,params)
        if not activeName or not self.info[activeName] then return false end

        if activeName == 'wheelFortune' or activeName == 'wheelFortune2' or activeName == 'wheelFortune3' then
            return self.setWheelFortuneStats(params,activeName)
        end
        if activeName == 'baseLeveling' then
            return self.setbaseLevelingStats(params)
        end
        if activeName == 'bindbaseLeveling' then
            return self.setbindbaseLevelingStats(params)
        end
        if activeName == 'fightRank' then
            return self.setfightRankStats(params)
        end

        if activeName == 'dayRecharge' then
            return self.setDayRechargeStats(params)
        end
        if activeName == 'dayRechargeForEquip' then
            return self.setDayRechargeForEquipStats(params)
        end
        if activeName == 'totalRecharge' then
            return self.settotalRechargeStats(params)
        end
        if activeName == 'totalRecharge2' then
            return self.settotalRecharge2Stats(params)
        end
        if activeName == 'allianceFight' then
            return self.setallianceFightStats(params)
        end
        if activeName == 'allianceDonate' then
            return self.setallianceDonateStats(params)
        end
        if activeName == 'allianceLevel' then
            return self.setallianceLevelStats(params)
        end

        if activeName == 'discount' then
            return self.setDiscountStats(params)
        end
        if activeName == 'rechargeRebate' then
            return self.setRechargeRebateStats(params)
        end
        if activeName == 'harvestDay' then
            return self.setHarvestDayStats(params)
        end

        if activeName == 'userFund' then
            return self.setUserFundStats(params)
        end

        local funcName = "set".. activeName .."Stats"
        if type(self[funcName]) == 'function' then
            return self[funcName](params)
        end
        --return self.setdefaultAcstatse(activeName,params)
    end


    function self.setallianceDonateStats(params)

        local uid     = tonumber(params.uid)

        local stats,key = self.getStats('allianceDonate')
        if type(stats) ~= 'table' then stats = {} end
        -- print(uid)
        if  uid~=nil and uid > 0 then
            if type(stats.rmembers) ~='table' then  stats.rmembers={} end
            table.insert(stats.rmembers,uid)
        end

        --ptb:p(stats);
        local redis = getRedis()
        local ret = redis:set(key,json.encode(stats))
        local expireTime = self.getActiveCacheExpireTime("allianceDonate")
        redis:expire(key,expireTime)

        return ret


    end

    --members 前三个军团的战力前十的人远信息
    --rmember 领奖人员的id
    function self.setallianceFightStats(params)

        local members = params.members
        local uid     = tonumber(params.uid)

        local stats,key = self.getStats('allianceFight')

        --ptb:p(stats);
        if type(stats) ~= 'table' then stats = {} end

        if  type(members)=='table' then
            stats.members=members
        end
        -- print(uid)
        if  uid~=nil and uid > 0 then
            if type(stats.rmembers) ~='table' then  stats.rmembers={} end
            table.insert(stats.rmembers,uid)
        end

        --ptb:p(stats);
        local redis = getRedis()
        local ret = redis:set(key,json.encode(stats))
        local expireTime = self.getActiveCacheExpireTime("allianceFight")
        redis:expire(key,expireTime)

        return ret

    end


    -- 需要统计活动内军团捐献的金币数
    -- 每个成员领取奖励
    --stats.a  军团id=捐献所花的金币
    --stats.r  领取奖励的的id
    function self.setallianceLevelStats(params)
        local aid = params.aid
        local gold =params.gold

        local uid = params.uid

        local stats,key = self.getStats('allianceLevel')

        if type(stats) ~='table' then    stats={}   end

        local acet =  self.getAcet('allianceLevel',true)
        local time = getClientTs()

        if acet>=time then
            if aid~=nil and gold~=nil then
                if type(stats.a)~='table' then stats.a={} end
                stats.a['aid='..aid] = (stats.a['aid='..aid] or 0) + gold
            end

        end

        if uid~=nil and uid>0 then
            if type(stats.r)~='table' then  stats.r={} end
            table.insert(stats.r,uid)
        end

        local redis = getRedis()
        local ret = redis:set(key,json.encode(stats))
        local expireTime = self.getActiveCacheExpireTime("allianceLevel")
        redis:expire(key,expireTime)

        return ret
    end

    function self.setfightRankStats(params)
        local stats,key = self.getStats('fightRank')
        local  uid = params.uid
        local  rank  = params.rank
        if type(stats) ~= 'table' then stats = {} end
        stats['r'..rank] = (stats['r'..rank] or 0) + 1

        --ptb:p(stats)
        local redis = getRedis()
        local ret = redis:set(key,json.encode(stats))
        local expireTime = self.getActiveCacheExpireTime("fightRank")
        redis:expire(key,expireTime)

        return ret
    end
    
    --指挥中心冲级活动
    --lvl..等级  领取的总人数
    --vips       总人数中的vip
    function self.setbindbaseLevelingStats(params)

        local stats,key = self.getStats('bindbaseLeveling')
        local  uid = params.uid
        local vip  = params.vip
        local level =params.level


        if type(stats) ~= 'table' then stats = {} end
        stats['lvl'..level] = (stats['lvl'..level] or 0) + 1
        if vip>0 then
            if type(stats.vips) ~='table'  then  stats.vips={} end
            local flag=table.contains(stats.vips, uid)
            if(not flag)then
                table.insert(stats.vips,uid)
            end
        end
        --ptb:p(stats)
        local redis = getRedis()
        local ret = redis:set(key,json.encode(stats))
        local expireTime = self.getActiveCacheExpireTime("bindbaseLeveling")
        redis:expire(key,expireTime)

        return ret
    end


    --指挥中心冲级活动
    --lvl..等级  领取的总人数
    --vips       总人数中的vip
    function self.setbaseLevelingStats(params)

        local stats,key = self.getStats('baseLeveling')
        local  uid = params.uid
        local vip  = params.vip
        local level =params.level


        if type(stats) ~= 'table' then stats = {} end
        stats['lvl'..level] = (stats['lvl'..level] or 0) + 1
        if vip>0 then
            if type(stats.vips) ~='table'  then  stats.vips={} end
            local flag=table.contains(stats.vips, uid)
            if(not flag)then
                table.insert(stats.vips,uid)
            end
        end
        --ptb:p(stats)
        local redis = getRedis()
        local ret = redis:set(key,json.encode(stats))
        local expireTime = self.getActiveCacheExpireTime("baseLeveling")
        redis:expire(key,expireTime)

        return ret
    end


    --获取活动结束时间
    function self.getAcet(activeName,params)

        if not self.info[activeName] then
            return 0
        end
        params = params and 86400 or 0
        return self.info[activeName].et-params
        -- body
    end


    -- 设置命运转盘统计
    -- 每日参与抽奖的用户数
    --每日各项道具的产出总量
    -- 每日抽奖进行的总次数
    -- stats table
    -- stats.users 当日抽奖用户数
    -- stats.lotterys   当日总抽奖数
    -- stats.res 当日道具产出
    -- stats.vips vip充值人数
    -- stats.mLotterys 2次及以上抽奖人数
    function self.setWheelFortuneStats(params,activeName)
        activeName = activeName or 'wheelFortune'
        local weeTs = getWeeTs()
        local stats,key = self.getStats(activeName,weeTs)

        if type(stats) ~= 'table' then stats = {} end

        if params.lottery == 1 then
            -- 今日第一次充值，可计算出每日参与抽奖的用户数
            if (self.info[activeName].t or 0) ~= weeTs then
                stats.users = (stats.users or 0) + 1
            end

            -- 每日抽奖次数大于2次的用户
            if self.info[activeName].t == weets then
                stats.mLotterys = (stats.mLotterys or 0) + 1
            end

            -- 每日的vip人数
            if params.isvip == 1 then
                stats.vips = (stats.vips or 0) + 1
            end

            stats.lotterys = (stats.lotterys or 0) + 1
        end

        if type(params.res) == 'table' then
            if not stats.res then stats.res = {} end

            for k,v in pairs(params.res) do
                stats.res[k] = (stats.res[k] or 0) + v
            end
        end

        local redis = getRedis()
        local ret = redis:hset(key,tostring(weeTs),json.encode(stats))
        local expireTime = self.getActiveCacheExpireTime(activeName)
        redis:expire(key, expireTime)

        return ret
    end


    --基金统计

    function self.setUserFundStats(params)

        local r=params.reward
        local uid =params.user
        local stats,key = self.getStats('userFund')

        if type(stats) ~= 'table' then stats = {} end

        if r ~=nil and r>0 then

            --累计第一次领奖的用户计入统计
            if type(stats.reward)~='table' then   stats.reward={} end
            stats.reward['r'..r] = (stats.reward["r"..r] or 0) + 1
        end

        if uid~=nil and uid>0 then

            if type(stats.users) ~='table' then  stats.users={}  end
            local flag=table.contains(stats.users, uid)
            if(not flag)then
                table.insert(stats.users,uid)
            end
        end

        --ptb:e(stats)
        local redis = getRedis()
        local ret = redis:set(key,json.encode(stats))
        local expireTime = self.getActiveCacheExpireTime("userFund")
        redis:expire(key,expireTime)

        return ret
    end
    --大战前夕
    function self.totalRecharge2(aname, params)
        self.info.totalRecharge2.v = (self.info.totalRecharge2.v or 0) + params.num
        local activeCfg = getConfig("active.totalRecharge2."..tonumber(self.info.totalRecharge2.cfg))

        local currentGetNum = 1
        local currentCost = activeCfg.cost[currentGetNum] or 0
        local gold = currentCost
        if self.info.totalRecharge2.v >= gold then
            self.settotalRecharge2Stats({uid=self.uid})
        end
    end

    --卡夫卡的馈赠
    function self.kafkagift(aname,params)
        local cost = tonumber(params.gems) or 0
        local weeTs = getWeeTs()
        if self.info[aname].t < weeTs then
            self.info[aname].t = weeTs
            self.info[aname].v = 0
            self.info[aname].flag = nil
            self.info[aname].mark = nil
        end

        if type(self.info[aname].v) ~= "number" then
            self.info[aname].v = 0
        end

        self.info[aname].v = self.info[aname].v + cost
        
        local data = {[aname] = self.info[aname]}
        regSendMsg(self.uid,'active.change', data)
        
        return true
    end

    --累计消费的统计
    function self.settotalRecharge2Stats(params)

        local r=params.reward
        local uid =params.uid
        local stats,key = self.getStats('totalRecharge2')

        if type(stats) ~= 'table' then stats = {} end

        if r ~=nil and r>0 then

            --累计第一次领奖的用户计入统计
            if type(stats.reward)~='table' then   stats.reward={} end
            stats.reward[r] = (stats.reward[r] or 0) + 1
        end

        if uid~=nil and uid>0 then

            if type(stats.users) ~='table' then  stats.users={}  end
            local flag=table.contains(stats.users, uid)
            if(not flag)then
                table.insert(stats.users,uid)
            end
        end

        --ptb:e(stats)
        local redis = getRedis()
        local ret = redis:set(key,json.encode(stats))
        local expireTime = self.getActiveCacheExpireTime("totalRecharge2")
        redis:expire(key,expireTime)

        return ret
    end

    --累计消费的统计
    function self.settotalRechargeStats(params)

        local r=params.reward
        local uid =params.uid
        local stats,key = self.getStats('totalRecharge')

        if type(stats) ~= 'table' then stats = {} end

        if r ~=nil and r>0 then

            --累计第一次领奖的用户计入统计
            if type(stats.reward)~='table' then   stats.reward={} end
            stats.reward[r] = (tonumber(stats.reward[r]) or 0) + 1
        end

        if uid~=nil and uid>0 then

            if type(stats.users) ~='table' then  stats.users={}  end
            local flag=table.contains(stats.users, uid)
            if(not flag)then
                table.insert(stats.users,uid)
            end
        end

        --ptb:e(stats)
        local redis = getRedis()
        local ret = redis:set(key,json.encode(stats))
        local expireTime = self.getActiveCacheExpireTime("totalRecharge")
        redis:expire(key,expireTime)

        return ret
    end

    --设置军团收获日的活动统计

    function self.setHarvestDayStats(params)
        local stats,key = self.getStats('harvestDay')
        local win = params.win
        local point = params.point
        local join = params.join

        if type(stats) ~= 'table' then stats = {} end

        if win~=nil and win >1000000 then
            if type(stats.win)~="table" then  stats.win={}  end

            table.insert(stats.win,win)

        end
        if point~=nil and point>1 then
            if type(stats.point)~="table" then  stats.point={}  end
            stats.point["a"..point] = (stats.point["a"..point] or 0) + 1
        end
        if join~=nil and join>100000 then
            if type(stats.join)~="table" then  stats.join={}  end
            stats.join["u"..join] = (stats.join["u"..join] or 0) + 1
        end


        local redis = getRedis()
        local ret = redis:set(key,json.encode(stats))
        local expireTime = self.getActiveCacheExpireTime("harvestDay")
        redis:expire(key,expireTime)

        return ret
    end




    -- 每日消费活动统计
    -- 每日每项奖励的总领取人数
    function self.setDayRechargeStats(params)
        local activeName = "dayRecharge"
        local stats,key = self.getStats('dayRecharge',params.weeTs)

        if type(stats) ~= 'table' then stats = {} end

        -- 今日第一次领奖的用户计入统计
        stats[params.reward] = (stats[params.reward] or 0) + 1
        local redis = getRedis()
        local ret = redis:hset(key,tostring(params.weeTs),json.encode(stats))
        local expireTime = self.getActiveCacheExpireTime(activeName)
        redis:expire(key,expireTime)

        return ret
    end
    -- 每日消费送配件活动统计
    -- 每日每项奖励的总领取人数
    function self.setDayRechargeForEquipStats(params)
        local activeName = "dayRechargeForEquip"
        local stats,key = self.getStats('dayRechargeForEquip',params.weeTs)

        if type(stats) ~= 'table' then stats = {} end

        -- 今日第一次领奖的用户计入统计
        stats[params.reward] = (stats[params.reward] or 0) + 1
        local redis = getRedis()
        local ret = redis:hset(key,tostring(params.weeTs),json.encode(stats))
        local expireTime = self.getActiveCacheExpireTime(activeName)
        redis:expire(key,expireTime)

        return ret
    end

    -- 配件进化活动统计
    -- 每日每项奖励的总领取人数
    function self.setDayAccessoryEvolutionStats(params)
        local stats,key = self.getStats('accessoryEvolution',params.weeTs)

        if type(stats) ~= 'table' then stats = {} end

        -- 今日第一次领奖的用户计入统计
        stats[params.reward] = (stats[params.reward] or 0) + 1
        local redis = getRedis()
        local ret = redis:hset(key,tostring(params.weeTs),json.encode(stats))
        local expireTime = self.getActiveCacheExpireTime("accessoryEvolution")
        redis:expire(key,expireTime)

        return ret
    end


    -- 道具限时打折统计
    function self.setDiscountStats(params)
        local activeName = "discount"
        local weeTs = getWeeTs()
        local stats,key = self.getStats(activeName,weeTs)

        if type(stats) ~= 'table' then stats = {} end

        stats[params.pid] = (stats[params.pid] or 0) + 1

        local redis = getRedis()
        local ret = redis:hset(key,tostring(weeTs),json.encode(stats))
        local expireTime = self.getActiveCacheExpireTime(activeName)
        redis:expire(key,expireTime)

        return ret
    end

    --充值返利20%

    function self.setRechargeRebateStats(params)
        local activeName = "rechargeRebate"
        -- body
        local stats,key = self.getStats(activeName)

        if type(stats) ~= 'table' then stats = {} end

        -- 今日第一次领奖的用户计入统计
        table.insert(stats,params)
        --stats[] = params
        local redis = getRedis()
        local ret = redis:set(key,json.encode(stats))
        local expireTime = self.getActiveCacheExpireTime(activeName)
        redis:expire(key,expireTime)

        return ret
    end

    -- 删除活动的统计数据
    -- 上一次活动统计数据未过期的时候，又上了此活动
    function self.delActiveStats(activeName)

    end

    -- 删除活动的排行榜数据
    function self.delActiveRanking(activeName)
        if activeName == 'equipSearch' then
            return delEquipSearchRanking(self.info[activeName].st)
        end

        return -2
    end

    -- 设置活动信息
    function self.setActiveInFo(activeName,params,aid)
        local key = "z"..getZoneId()..".ac."..aid.."info"..tostring(activeName)..self.info[activeName].st
        local redis = getRedis()
        local result = redis:set(key,params)
        local expireTime = self.getActiveCacheExpireTime(activeName)
        redis:expire(key,expireTime)
        return result
    end

    function self.getActiveInFo(activeName,params)
        local key = "z"..getZoneId()..".ac."..params.."info"..tostring(activeName)..self.info[activeName].st
        local redis = getRedis()
        local num = redis:get(key) or 0
        return num
        -- body
    end

    function self.setOldUserReturn(params)
        local activeName = "oldUserReturn"
        local loginDate = params.logindate
        local level     = params.level
        local ts        = getClientTs()
        local activeCfg = getConfig("active")
        local oldtime   = activeCfg.oldUserReturn.serverreward.oldtime
        local minlevel  = activeCfg.oldUserReturn.serverreward.minlevel
        if  not self.info.oldUserReturn.n then
            if (ts - loginDate) >oldtime and level>=minlevel then
                self.info.oldUserReturn.n = 1
                self.info.oldUserReturn.l = level
                local redis = getRedis()
                local key = "z"..getZoneId()..".ac.rank.oldUserReturn"
                local ret = redis:incrby(key,1)
                local expireTime = self.getActiveCacheExpireTime(activeName)
                redis:expire(key,expireTime)
                writeLog(self.uid,'oldUserReturn')
            else
                self.info.oldUserReturn.n = 0
                self.info.oldUserReturn.l = level
            end

        end
        --self.info.oldUserReturn = nil
        return true
    end
    function self.getoldUserReturnTnum()
        local redis = getRedis()
        local key = "z"..getZoneId()..".ac.rank.oldUserReturn"
        local num = redis:get(key) or 0
        return num
    end
    function self.solveData(k,v)
        if k=='oldUserReturn' then
            local tnum = self.getoldUserReturnTnum() or 0
            v.tnum     = tnum
        end
    end




    ----门后有鬼
    function self.doorGhostRef()
        local activeCfg = getConfig("active.doorGhost."..self.info.doorGhost.cfg)
        local pool=activeCfg.serverreward.pool
        local pool = getRewardByPool(pool,true)
        local q = {}
        for k,v in pairs (pool) do
            for key,val in pairs(v) do
                if key=='gt_g1' then
                    q[k]=v
                else
                    q[k]=formatReward(v)
                end
            end
        end

        self.info.doorGhost.r={}
        self.info.doorGhost.info={}
        self.info.doorGhost.info.q=q
        self.info.doorGhost.info.h=pool

    end

    --引力失常，加速消费
    function self.speedupdisc(activeName, params )
        -- 新手引导期间不参加活动
        local uobjs = getUserObjs(self.uid)
        local mUserinfo = uobjs.getModel('userinfo')
        if mUserinfo.tutorial < 10 then
            return params.gems
        end

        -- 开启类型，总价，折扣价, 打折量
        local nDay = math.ceil( (getClientTs() - self.info[activeName].st) / 86400 )
        local cfg = getActiveCfg(self.uid, activeName)
        local nIdx = nil
        for k, v in pairs( cfg.order ) do
            if params.speedtype == v then
                nIdx = k
                break 
            end
        end        

        -- 没有开启
        if not nIdx or nIdx > nDay then
            return params.gems
        end

        local randcfg = cfg.speedup[params.speedtype]
        local nRand = rand( randcfg[1]*100, randcfg[2]*100 )/100
        local currGems = math.ceil( params.gems * nRand )

        self.info[activeName].gems = params.gems
        self.info[activeName].rand = nRand
        self.info[activeName].curr = currGems        

        local data = {[activeName] = self.info[activeName]}
        regSendMsg(self.uid,'active.change', data)

        --搜集统计
        params.nIdx = nIdx
        self.setStats(activeName, params)

        return currGems

    end

    --统计
    function self.setspeedupdiscStats ( params )
        -- body
        local activeName = "speedupdisc"
        local stats,key = self.getStats( activeName, params.speedtype )

        if type(stats) ~= 'table' then stats = {} end

        -- 统计total， discounttotal, usernumber
        stats["price"] = (stats["price"] or 0) + self.info[activeName].gems
        stats["curr"] = (stats["curr"] or 0) + self.info[activeName].curr
        if not self.info[activeName].s then
            self.info[activeName].s={}
        end
        if not self.info[activeName].s[params.nIdx] then
            self.info[activeName].s[params.nIdx] = 1
            stats["user"] = (stats["user"] or 0) + 1
        end

        local redis = getRedis()
        local ret = redis:hset(key, params.speedtype, json.encode(stats))
        local expireTime = self.getActiveCacheExpireTime(activeName)
        redis:expire(key,expireTime)

        return ret

    end

    -- 奔赵前线
    function self.benfuqianxian(activeName,params)
        local activeInfo = self.info[activeName]
        local activeCfg = self.getActiveConfig(activeName)

        if type(activeInfo.d) ~= 'table' then
            activeInfo.d = {}
        end

        if type(params.tasks) == 'table' then
            for k,v in pairs(params.tasks) do
                -- 当前任务完成值
                local oldTaskVal = activeInfo.d[k] or 0

                v = tonumber(v)

                if v > 0 and activeCfg.task[k] and oldTaskVal < activeCfg.task[k][1] then
                    -- 累加任务完成值
                    activeInfo.d[k] = oldTaskVal + v

                    -- 最高完成任务值不能超过配置上限
                    if activeInfo.d[k] > activeCfg.task[k][1] then
                        activeInfo.d[k] = activeCfg.task[k][1]
                    end

                    -- 本次实际累加的任务值
                    --local addTaskVal = activeInfo.d[k] - oldTaskVal

                    -- 本次实际获得的任务点数
                    --local pointVal = math.floor(addTaskVal * activeCfg.task[k][2])
                    -- 累加
                    local pointVal = math.floor(activeInfo.d[k] * activeCfg.task[k][2]) - 
                                    math.floor(oldTaskVal * activeCfg.task[k][2])

                    activeInfo.point = (activeInfo.point or 0) + pointVal

                    -- 推送消息
                    local pushData = {[activeName] = self.info[activeName]}
                    regSendMsg(self.uid,'active.change',pushData)
                end
            end
        end
    end
    
    -- 矩阵收集
    function self.armorCollect(activeName, params)
        local acfg = self.getActiveConfig(activeName)
        
        if not self.info[activeName].rw then
            self.info[activeName].rw = {}
            for i, v in pairs(acfg.serverreward) do
                self.info[activeName].rw[i] = {0,0} --{收集个数，领奖状态}
            end
        end

        local needPush = false
        for i, v in pairs(acfg.serverreward) do
            if tonumber(self.info[activeName].rw[i][2]) ~= 2 and params.quality == v.condition.color then
                self.info[activeName].rw[i][1] = self.info[activeName].rw[i][1] + 1
                if self.info[activeName].rw[i][1] >= v.condition.num then
                    self.info[activeName].rw[i][2] = 1
                end
                needPush = true
            end
        end

        if needPush then
            -- 推送消息
            local pushData = {[activeName] = self.info[activeName]}
            regSendMsg(self.uid,'active.change',pushData)
        end
    end

    -- 矩阵升级 
    function self.armorUp(activeName, params)
        local acfg = self.getActiveConfig(activeName)

        if not self.info[activeName].rw then
            self.info[activeName].rw = {}
            for i, v in pairs(acfg.serverreward) do
                self.info[activeName].rw[i] = {0,0} -- {升级数，领奖状态}
            end
        end

        local needPush = false
        for i, v in pairs(acfg.serverreward) do
            if tonumber(self.info[activeName].rw[i][2]) ~= 2 and params.quality == v.condition.color then
                self.info[activeName].rw[i][1] = self.info[activeName].rw[i][1] + params.level
                if self.info[activeName].rw[i][1] >= v.condition.lv then
                    self.info[activeName].rw[i][2] = 1
                end
                needPush = true
            end
        end

        if needPush then
            -- 推送消息
            local pushData = {[activeName] = self.info[activeName]}
            regSendMsg(self.uid,'active.change',pushData)
        end

    end

    -- 剧情战役强化
    function self.armorStreng(activeName, params)
        local acfg = self.getActiveConfig(activeName)

        if params.exp then
            return math.floor(params.exp * (1 + acfg.addexp))
        elseif params.count then
            return acfg.addNum + params.count
        end
    end

    -- 获取
    -- ----------------------------------------------------------------------------
    function self.getActiveDataFromCache(activeName,cName,datatype)
        cName = cName or "def"
        datatype = datatype or "string"

        if self.info[activeName] and self.info[activeName].st then
            local redis = getRedis()
            local cacheKey = getActiveCacheKey(activeName,cName,self.info[activeName].st)

            if datatype == "string" then
                return redis:get(cacheKey)
            end
        end
    end

    function self.setActiveDataToCache(activeName,data,cName,datatype)
        cName = cName or "def"
        datatype = datatype or "string"

        if data and self.info[activeName] and self.info[activeName].st then
            if data then
                local redis = getRedis()
                local cacheKey = getActiveCacheKey(activeName,cName,self.info[activeName].st)
                local setRet

                if datatype == "string" then
                    if type (data) == 'table' then
                        setRet = redis:set(cacheKey,json.encode(data))
                    else
                        setRet = redis:set(cacheKey,data)
                    end
                end

                local expireTime = self.getActiveCacheExpireTime(activeName)
                redis:expire(cacheKey,expireTime)

                return setRet
            end
        end

        return false
    end

    -- 将活动配置json串存入 缓存string
    -- prams table cfg
    function self.getActiveCfgByCache(activeName)
        local cfg =  self.getActiveDataFromCache(activeName,"cfg")

        return cfg and json.decode(cfg)
    end

    function self.setActiveCfgToCache(activeName,cfg)
        return self.setActiveDataToCache(activeName,cfg,"cfg")
    end
    -- end cfg of cache----------------------------------------------------------------------------

    -- 获取活动缓存时间
    -- 默认活动结束后五天
    function self.getActiveCacheExpireTime(activeName,expireTime)
        expireTime = expireTime or 432000

        if self.info[activeName] then
            local ts = getClientTs()

            local activeTs = (self.info[activeName].et or 0) - (ts or 0)
            if activeTs < 0 then activeTs = 0 end

            expireTime = expireTime + activeTs
        end

        return expireTime
    end


    --文件写入

    function self.setFileLog(logInfo,filename)
        local log = {}
        log =json.encode(logInfo)

        filename = filename or 'active'
        writeLog(log,filename)
    end
    --文件写入

    function self.getFileLog(filename)
        local log = {}
        log =json.encode(logInfo)

        filename = filename or 'active'
        writeLog(log,filename)
    end
    -- 将活动数据存入文件

    function self.setActiveInFoToFile(activeName,info,key)

    end

    -- 将活动数据从文件里读出来

    function self.setActiveInFoToFile(activeName,key)

    end

    function self.getActiveConfig(acname)
        local activeCfg = nil
        if self.info[acname].cfg then
            activeCfg = getConfig("active/" .. acname)[self.info[acname].cfg]
        else
            activeCfg = getConfig("active/" .. acname)
        end

        return activeCfg
    end

    -- 初始化活动数据（并非适用所有活动 调用时根据具体需要）
    function self.initAct(aname)
        local ts= getClientTs()
        local weeTs = getWeeTs()
        
        local flag = false -- 初始化的数据是否需要save
        if aname=='luckybag' then -- 跨年福袋
            -- 每日重置数据
            if self.info[aname].t ~= weeTs then
                flag = true
                self.info[aname].t = weeTs
            end
            -- 每日重置
            if type(self.info[aname].task) ~= 'table' or flag then
                self.info[aname].task = {} -- 任务奖励
                local activeCfg = self.getActiveConfig(aname)
                local items = #activeCfg.serverreward.taskList -- 此处需要读配置-----------------------------------------《《《《《
                for i = 1,items do
                    -- 当前值 已完成任务次数（小于等于当天总完成次数） 已领取次数
                    table.insert(self.info[aname].task,{0,0,0})
                end
            end
            
            if not self.info[aname].luckybag_a1 then
                self.info[aname].luckybag_a1 = 0
                self.info[aname].luckybag_a2 = 0
                self.info[aname].luckybag_a3 = 0
                self.info[aname].luck = 0 --幸运值  
                self.info[aname].lv = 1 -- 福袋等级
            end
        elseif aname=='redbagback' then -- 红包回馈
            -- 每日重置数据
            if self.info[aname].t ~= weeTs then
                flag = true
                self.info[aname].t = weeTs
            end

            if type(self.info[aname].gem1) ~= 'table' or flag then
                local activeCfg = self.getActiveConfig(aname)
                self.info[aname].gem1 = {}
                self.info[aname].gem2 = {}

                for i=1,2 do
                    if next(activeCfg.serverreward.redbag[i]) then
                        for k,v in pairs(activeCfg.serverreward.redbag[i]) do
                            table.insert(self.info[aname]['gem'..i],0)--已领取次数
                        end
                    end
                end
                self.info[aname].gem = 0
            end
        elseif aname=='hfdz' then -- 合服大战
            -- 每日重置数据
            if self.info[aname].t ~= weeTs then
                flag = true
                self.info[aname].t = weeTs
            end
            if type(self.info[aname].task) ~= 'table' or flag then
                local activeCfg = self.getActiveConfig(aname)
                self.info[aname].task = {} -- 任务奖励
                for k,v in pairs(activeCfg.serverreward.taskList[1]) do
                    table.insert(self.info[aname].task,{0,0}) -- 当前值
                end
                self.info[aname].bn = 0 
            end

            if not self.info[aname].s then
                self.info[aname].s = 0 ---- 积分
                self.info[aname].a1 = 0 ---- 军团积分大于n 领取状态
                self.info[aname].a2 = 0 ---- 排行榜 领取状态
                self.info[aname].bn = 0 
            end
          
        elseif aname == 'seadrill' then-- 海底勘探
            if type(self.info[aname].task) ~= 'table' then
                flag = true
                local activeCfg = self.getActiveConfig(aname)
                self.info[aname].task = {}
                for k,v in pairs(activeCfg.serverreward.taskList) do
                    table.insert(self.info[aname].task,0) -- 领取状态 0未领取 1已领取
                end

                self.info[aname].s1 = 0 -- 累计N次
                self.info[aname].s2 = 0 -- 连续N次
            end
        elseif aname == 'germancard' then -- 德国月卡
            if not self.info[aname].init then
                flag = true
                self.info[aname].init = 1 -- 是否初始化
                self.info[aname].gem = 0 -- 累计充值的钻石
                self.info[aname].ot = {0,0} -- 玩家开启领奖的时间 凌晨零点
                self.info[aname].n = {0,0}  -- 领取的次数
                self.info[aname].lt = {0,0} -- 上次领取时间         
            end
        elseif aname == 'jzxl' then -- 集中训练
            if type(self.info[aname].task) ~= 'table' then
                flag = true
                local activeCfg = self.getActiveConfig(aname)
                self.info[aname].task = {} -- 任务奖励
                for k,v in pairs(activeCfg.serverreward.taskList) do
                    table.insert(self.info[aname].task,0) -- 领取状态  0未领取 1已领取
                end

                -- 任务记录
                self.info[aname].jz1=0--射击
                self.info[aname].jz2=0--阵型
                self.info[aname].jz3=0--协作
                self.info[aname].jz4=0--总分
            end
        elseif aname == 'recallpay' then
            -- 出现礼包 已经充值金额
            if not self.info[aname].ch then
                self.info[aname].ch = 0
            end
            -- 总充值金额
            if not self.info[aname].cost then
                self.info[aname].cost = 0
            end
   
            -- 奖励是否已经领取
            if not self.info[aname].r then
                self.info[aname].r = 0  -- 1已领取 0 未领取
            end 

            if not self.info[aname].pop then
                self.info[aname].pop = 0 --0客户端不弹出 1弹出
            end

            if not self.info[aname].cr then
                self.info[aname].cr = 0 --可领取状态
            end

            if not self.info[aname].pt then
                self.info[aname].pt = 0 --出现时间
            end
            -- 出现当天的时间
            if not self.info[aname].td then
                self.info[aname].td = 0 --出现当天时间
            end
        elseif aname == 'laborday' then-- 全民劳动（2018 五一）
            -- 任务
            -- 积分兑换
            -- 商店
            local activeCfg = self.getActiveConfig(aname)
            if type(self.info[aname].task)~='table' then
                flag = true
                self.info[aname].task = {}
                for k,v in pairs(activeCfg.serverreward.taskList) do
                    table.insert(self.info[aname].task,{0,0})--总值 领取次数
                end
            end
            -- 积分
            if not self.info[aname].s then
                self.info[aname].s = 0 -- 做任务获得的积分
                flag = true
            end
            -- 商店
            if type(self.info[aname].shop)~='table' then
                self.info[aname].shop = {}
                for k,v in pairs(activeCfg.serverreward.shopList) do
                    table.insert(self.info[aname].shop,0)-- 购买次数
                end
                flag = true
            end 

            -- 积分兑换
            if type(self.info[aname].sr)~='table' then
                self.info[aname].sr = {}
                for _,v in pairs(activeCfg.supportNeed) do
                    table.insert(self.info[aname].sr,0) -- 0未领取 1已领取
                end
                flag = true
            end
        elseif aname == 'oneshot' then --世界杯-一球成名
            -- 初始化各任务每天获取的次数
            if type(self.info[aname].task)~='table' then
                self.info[aname].task = {0,0,0} ---固定的三个任务
                flag = true
            end

            -- 每日领取消费礼包数量
            if not self.info[aname].dg then
                flag = true
                self.info[aname].dg = 0 -- 当日获得
                self.info[aname].ch = 0 -- 每日消费钻石
            end

            if self.info[aname].t ~= weeTs then
                self.info[aname].t = weeTs
                self.info[aname].dg = 0
                self.info[aname].ch = 0
                self.info[aname].task = {0,0,0}
                flag = true
            end
        elseif aname == 'unitepower' then -- 团结之力
            local activeCfg = self.getActiveConfig(aname)
            -- 初始化各任务每天获取的次数
            if type(self.info[aname].task)~='table' then
                self.info[aname].task = {}
                for k,v in pairs(activeCfg.serverreward.taskList) do
                    table.insert(self.info[aname].task,{0,0})-- 当前值 已领取次数
                end
                self.info[aname].unitepower_a1 = 0 -- 个人积分
                self.info[aname].quan = 0  -- 代金券
                flag = true
            end
            -- 任务刷新
            if self.info[aname].t ~= weeTs then
                self.info[aname].t = weeTs
                for k,v in pairs(self.info[aname].task) do
                    self.info[aname].task[k] = {0,0}
                end
                flag = true
            end
            -- 军团积分阶段奖励
            if type(self.info[aname].sgift) ~= 'table' then
                self.info[aname].sgift = {}
                for k,v in pairs(activeCfg.scoreNeed1) do
                    table.insert(self.info[aname].sgift,0) -- 1 已领取
                end
                flag = true
            end

            -- 商店 限购
            if type(self.info[aname].shop) ~= 'table' then
                self.info[aname].shop = {}
                for k,v in pairs(activeCfg.scoreNeed2) do
                    local tmp = {}
                    for s,sv in pairs(activeCfg.serverreward['shopList'..k]) do
                        table.insert(tmp,0)
                    end
                    table.insert(self.info[aname].shop,tmp)
                end
                flag = true
            end
        end

        return flag
    end

    ------------------------------------------------------------------------------------------------------------------

    return self
end
