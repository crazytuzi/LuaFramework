function model_userarena(uid,data)
        -- the new instance
    local self = {
        -- public fields go in the instance table
        uid= uid, 
        ranking=0, --排名
        ranked =0, --上一次领奖的排名
        ranked_at=0,--上一次排名的时间
        victory=0, --连胜次数
        score=0,  -- 攻打获得的积分
        point=0,  --能在商店购买的积分
        info={},  --商店及购买记录
        troops={}, --设置部队镜像
        attack_at=0, --上一次攻击时间
        attack_count=0, -- 今天攻打的次数
        attack_num=5,   -- 今天可攻打次数
        buy_num=0,      -- 购买可攻击次数
        ref_num=0,      -- 刷新列表次数
        cdtime_at =0,   -- cd时间
        reward_at =0,   -- 领奖时间
        updated_at=0,   -- 最近一次更新时间 
    }
    -- body



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
                elseif vType == 'table' and type(data[k]) ~= 'table' then                    
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
                        -- if type(v) == 'table'  then
                        --     if next(v) then data[k] = v end
                        -- elseif v ~= 0 and v~= '0' and v~='' then
                            data[k] = v
                        --end
                    else
                        data[k] = v
                    end
                end
            end

        return data
    end


    function self.addResource(column,num)


        regKfkLogs(self.uid,'userarena',{
                        addition={
                            {desc="军演竞技勋章添加",value=num},
                            {desc="军演竞技勋章添加前",value=self.point},
                            {desc="军演竞技勋章添加后",value=self.point+num},
                        },
                        }
                  
                )
     
        if self[column]~=nil then
            self[column]=self[column]+num
        else
            self.point=self.point+num
        end
        return true
    end

    function self.getlist(myrank,ref)


        if ref or type(self.info.alist)~='table' then
            self.info.alist=self.getAttackList(myrank)
        end 

        if not next(self.info.alist) then
            self.info.alist=self.getAttackList(myrank)
        end

        local list={}
        local arenaNpcCfg={}
        for k,r  in pairs (self.info.alist) do
            local muid=tonumber(getArenaUidByRank(r))
            if muid>1000000 then
                    local uobjs = getUserObjs(muid,true)
                    userinfo = uobjs.getModel('userinfo')
                    local item={r,muid,userinfo.nickname,userinfo.level,userinfo.fc,userinfo.pic,userinfo.bpic,userinfo.apic}
                    table.insert(list,item) 
               else

                    if not next(arenaNpcCfg) then
                        arenaNpcCfg = getConfig('arenaNpcCfg')
                    end
                    if muid==0 then
                        if(i<=tonumber(getMaxArenaRank())) then
                            muid=450
                        end
                    end
                    local sid='s'..muid
                    if arenaNpcCfg[sid] then

                        local item={r,muid,arenaNpcCfg[sid].name,arenaNpcCfg[sid].level,arenaNpcCfg[sid].Fighting}
                        table.insert(list,item)
                    end

               end
        end
        return list
    end

    function self.getAttackList(myrank)
        local list={}
        local arenaCfg = getConfig('arenaCfg')
        if myrank<=5 then
            --小于取前四
            local tmp={}
            for i=1,6 do
              if i>myrank  then
                local newrank=self.getRandRank(myrank+1,myrank+1+arenaCfg.behindRival,tmp)
                table.insert(tmp,newrank)
              else
                if myrank~=i then
                    table.insert(list,i)
                end
              end
            end

            if next(tmp) then
                table.sort( tmp )
                for k,v in pairs (tmp) do
                    table.insert(list,v)
                end
            end
        
        elseif myrank>=arenaCfg.frontLimit then
            local tmp={}
            for i=1,arenaCfg.frontRivalNum do
                local left=myrank-math.ceil(myrank*arenaCfg.frontRate[i][1])
                local right=myrank-math.ceil(myrank*arenaCfg.frontRate[i][2])
                local newrank=self.getRandRank(left,right,tmp)
                table.insert(tmp,newrank)
            end
            if next(tmp) then
                table.sort( tmp )
                for k,v in pairs (tmp) do
                    table.insert(list,v)
                end
            end
            --table.insert(list,myrank)

            local newrank=self.getRandRank(myrank+1,myrank+1+arenaCfg.behindRival,{})
            table.insert(list,newrank)            
        else
            local start=0
            local tmp={}
            for i=1,arenaCfg.frontRivalNum do
                local new=myrank-arenaCfg.frontRival
                if new<=0 then new =1 end
                local newrank=self.getRandRank(new,myrank-1,tmp)
                table.insert(tmp,newrank)
            end  
            if next(tmp) then
                table.sort( tmp )
                for k,v in pairs (tmp) do
                    table.insert(list,v)
                end
            end
            --table.insert(list,myrank)

            local newrank=self.getRandRank(myrank+1,myrank+1+arenaCfg.behindRival,{})
            table.insert(list,newrank)
        end
        return list
    end

    -- 后去随机排名
    function self.getRandRank(start,endtd,tmp)
        setRandSeed()
        local randnum = rand(start, endtd)
        local flag=table.contains(tmp, randnum)
        if not flag then
            return randnum
        else

            return self.getRandRank(start,endtd,tmp)
        end


    end

    -- 使用积分
    function self.usePoint(data)

        for k,v in pairs(data) do
            if self.point-v<0 then
                return false

            else
                local old=self.point
                self.point=self.point-v  
                regKfkLogs(self.uid,'userarena',{
                        addition={
                            {desc="军演竞技勋章使用",value=num},
                            {desc="军演竞技勋章使用前",value=old},
                            {desc="军演竞技勋章使用后",value=self.point},
                        },
                        }
                    )
            end
        end

        return true
    end

    --  生成排名 

    function self.getArenaRank()
        local maxrankKey = "z"..getZoneId().."_userarenarank"
        local redis = getRedis()
        local ranking = tonumber(redis:incr(maxrankKey)) or 0
        
        local rank =450
        if ranking > rank then
            return ranking
        else
            local db = getDbo()
            local result = db:getRow("select max(ranking) as ranking from userarena")
            if result then
                local ranking = tonumber(result.ranking) or 0
                if  ranking < rank then
                    ranking =  rank
                end
                    redis:set(maxrankKey,ranking)
                    ranking = tonumber(redis:incr(maxrankKey)) 
                return ranking
            end
        end
        return 0   

    end


        -- 修复错误的排名
    function self.repairRank(rank,duid)
            
        local db = getDbo()

        local result = db:getAllRows("select uid,ranking from userarena WHERE ranking="..rank)
        if type(result) == "table" and next(result) then
            -- 排名有重复需要干掉一个
            if #result >1 then
               for k,v in pairs(result) do
                   if tonumber(v.uid)~= duid then
                        if db:query("update userarena set ranking = 0 where uid="..tonumber(v.uid)) then
                            writeLog('info -------'..json.encode(v),'repairarena')
                        end   
                   end
               end
            end
        end
    
    end
   


    -- 攻击玩家
    function self.battle(attUid,fleetInfo,defuid,dFleetInfo,aranking,dranking)
            
        local auobjs = getUserObjs(attUid)
        local aUserinfo = auobjs.getModel('userinfo')
        local aHero = auobjs.getModel('hero')         
        local aheros = aHero.getAttackHeros('m',1)
        local aSequip = auobjs.getModel('sequip')
        local aSequipid =aSequip.getEquipFleet('m',1) 
        local aPlane = auobjs.getModel('plane')
        local aPlaneid = aPlane.getPlaneFleet('m',1)

        local duobjs = getUserObjs(defuid)
        local dUserinfo = duobjs.getModel('userinfo') 
        local defackFleet = duobjs.getModel('troops')
        local dmHero       = duobjs.getModel('hero')
        local dheros = dmHero.getAttackHeros('m',1)
        local dSequip = duobjs.getModel('sequip')
        local dSequipid =dSequip.getEquipFleet('m',1) 
        local dPlane      = duobjs.getModel('plane')
        local dPlaneid    = dPlane.getPlaneFleet('m',1)

        local dFleetInfo = dFleetInfo      
        local totalDefendTanks = 0
        
        if type(dFleetInfo) == 'table' then
            for k,v in pairs(dFleetInfo) do
                if type(v)=='table' and next(v) then
                    totalDefendTanks = totalDefendTanks + v[2]
                end
            end
        end

        -- 本次双方损失的坦克数量
        local lostShip = {
            attacker  = {},
            defenser = {},
        }

        local award,resource
        
        -- 初始化防守方
        local defFleetInfo,dAccessory,dherosInfo,dPlanevalue = defackFleet.initFleetAttribute(dFleetInfo,11,{hero=dheros,equip=dSequipid,plane=dPlaneid})
        
        --  初始化攻击方          
        local attackFleet = auobjs.getModel('troops')
        local aFleetInfo,aAccessory,aherosInfo,aPlanevalue = attackFleet.initFleetAttribute(fleetInfo,11,{hero=aheros,equip=aSequipid,plane=aPlaneid})

        -- 双方装备对比
        --dAccessory
        --aAccessory

        -- 无防守舰队，直接胜利
        local arank = 0
        local drank = 0
        -- 双方总坦克对比
        local dtankinfo={}
        if type(dFleetInfo) == 'table' then
            for k,v in pairs(dFleetInfo) do
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
        local tankinfo={a=atankinfo,d=dtankinfo}

        local reportParams = {
            -- 使用的装甲矩阵信息
            armor = {
                auobjs.getModel('armor').formatUsedInfoForBattle(),
                duobjs.getModel('armor').formatUsedInfoForBattle()
            },
            -- 使用的异星武器信息
            alienWeapon = {
                auobjs.getModel('alienweapon').formatUsedInfoForBattle(),
                duobjs.getModel('alienweapon').formatUsedInfoForBattle()
            },
            -- 双方的头像信息
            attackerPic = {aUserinfo.pic,aUserinfo.bpic,aUserinfo.apic},
            defenserPic = {dUserinfo.pic,dUserinfo.bpic,dUserinfo.apic},

            -- 双方基础信息
            userinfo = {
                {aUserinfo.showvip(),aUserinfo.fc,aUserinfo.level,aUserinfo.alliancename},
                {dUserinfo.showvip(),dUserinfo.fc,dUserinfo.level,dUserinfo.alliancename},
            },
            plane={aPlanevalue,dPlanevalue},
        }

        if totalDefendTanks < 1 then
            
            if aranking-dranking>0 then
                arank=aranking-dranking
            end
            if dranking-aranking<0 then
                drank=dranking-aranking
            end

            local aDmgInfo = {}
            for k,v in pairs(fleetInfo) do
                if type(v)=='table' and next(v) then
                    aDmgInfo[k] = string.format("%s-%s-%s",v[1],v[2],0)
                else
                    aDmgInfo[k] = ""
                end
            end

            reportParams.dmginfo = {
                aDmgInfo,
                {}
            }

            self.sendReport(attUid,defuid,dUserinfo.nickname,nil,lostShip,1,1,{aAccessory,dAccessory},arank,{{aherosInfo[1],aherosInfo[2]},{dherosInfo[1],dherosInfo[2]}},tankinfo, {aSequipid,dSequipid},reportParams)
            self.sendReport(defuid,attUid,aUserinfo.nickname,nil,lostShip,2,0,{aAccessory,dAccessory},drank,{{aherosInfo[1],aherosInfo[2]},{dherosInfo[1],dherosInfo[2]}},tankinfo, {aSequipid,dSequipid},reportParams)

            return 1,nil
        end
                
        require "lib.battle"
        
        local report, aInavlidFleet, dInvalidFleet,attSeq,seqPoint,aSurviveTroops,dSurviveTroops= {}
        -- 防守方先出手
        -- report.r==1 攻击者胜利 
        report.d, report.w, aInavlidFleet, dInvalidFleet,attSeq,seqPoint = battle(aFleetInfo,defFleetInfo)
        report.t = {dFleetInfo,fleetInfo}

        if attSeq == 1 then
            report.p = {{dUserinfo.nickname,dUserinfo.level,1,seqPoint[2]},{aUserinfo.nickname,aUserinfo.level,0,seqPoint[1]}}            
        else
            report.p = {{dUserinfo.nickname,dUserinfo.level,0,seqPoint[2]},{aUserinfo.nickname,aUserinfo.level,1,seqPoint[1]}}
        end

        report.h = {dherosInfo[1],aherosInfo[1]}
        report.se = {dSequipid, aSequipid}

        local aDmgInfo,dDmgInfo
        lostShip.attacker ,aSurviveTroops, aDmgInfo = self.damageTroops(attUid,fleetInfo,aInavlidFleet)
        lostShip.defenser,dSurviveTroops, dDmgInfo = self.damageTroops(defenser,dFleetInfo,dInvalidFleet,false,true)

        reportParams.dmginfo = {
            aDmgInfo,
            dDmgInfo
        }

        -- 战斗胜利，奖励 ，防守方先出手，若防守方失败，则表示此次攻打胜利
        if report.w == 1 then     
            
            if aranking-dranking>0 then
                arank=aranking-dranking
            end
            if dranking-aranking<0 then
                drank=dranking-aranking
            end
            self.sendReport(attUid,defuid,dUserinfo.nickname,report,lostShip,1,1,{aAccessory,dAccessory,},arank,{{aherosInfo[1],aherosInfo[2]},{dherosInfo[1],dherosInfo[2]}},tankinfo,{aSequip.formEquip(aSequipid),dSequip.formEquip(dSequipid)},reportParams)
            self.sendReport(defuid,attUid,aUserinfo.nickname,report,lostShip,2,0,{aAccessory,dAccessory,},drank,{{aherosInfo[1],aherosInfo[2]},{dherosInfo[1],dherosInfo[2]}},tankinfo,{aSequip.formEquip(aSequipid),dSequip.formEquip(dSequipid)},reportParams)

            return 1,report

        else
             --TODO  战报
            self.sendReport(attUid,defuid,dUserinfo.nickname,report,lostShip,1,0,{aAccessory,dAccessory,},0,{{aherosInfo[1],aherosInfo[2]},{dherosInfo[1],dherosInfo[2]}},tankinfo,{aSequipid,dSequipid},reportParams)
            self.sendReport(defuid,attUid,aUserinfo.nickname,report,lostShip,2,1,{aAccessory,dAccessory,},0,{{aherosInfo[1],aherosInfo[2]},{dherosInfo[1],dherosInfo[2]}},tankinfo,{aSequipid,dSequipid},reportParams)

            return 0,report

        end

       

    end


     --发送战报
    --uid      
    --receiver  对方id
    --dfname    对方的名字 
    --report    战报
    --lostShip 双方损失战船
    --type 类型：1攻击 2被攻击
    --isVictory  是否胜利
    --aey        双方配件
    -- local lostShip={
    --         attacker ={{a10001=12},{},{}},
    --         defenser={{name="sample_ship_name_c1",num="20"},{name="sample_ship_name_b2",num="20"}}

    -- aey table  装备对比 {攻方装备情况，防守方装备情况}
   
    function self.sendReport(uid,receiver,dfname,report,lostShip,type,isVictory,aey,rank,heros,tankinfo,equip,reportParams)    
        local log = {
            report = report,
            lostShip=lostShip,
            tank=tankinfo,
            aey     =aey,
            hh    =heros,
            se =equip,
        }

        if reportParams then
            for k,v in pairs(reportParams) do
                log[k] = v
            end
        end
        
       local battlelogLib=require "lib.battlelog"
       battlelogLib:logSent(uid,receiver,dfname,type,isVictory,log,rank)        
    end

    --   刷新商店

    function self.refreshShop(shopCfg,level)
        -- 如果开将领装备就要换商店
        local cfg={}
        local pool=shopCfg.Shopdminput
        for k,v in pairs (shopCfg.Shopdoutput) do
            if level>=v then
                pool=k
            end 
        end
        cfg=copyTable(shopCfg['rewardPool'..pool])

        local Rewardoutput =shopCfg.Rewardoutput
        local group =#Rewardoutput
        self.info.shop={}
        for k,v in pairs(Rewardoutput) do
            if type (cfg[k])=='table' and next(cfg[k]) then
                local ret=self.getGradeShop(1,k,cfg[k],v,group,cfg[k],0)
                if not ret then
                    return false
                end
            end    
        end
        return true
    end


    --刷新n挡的商店
    -- grade 奖池中的几档
    -- pool  配置文件的几档的奖励池
    -- num   该奖池要出的奖励数量
    function self.getGradeShop(method,grade,pool,num,group,oldpool,cuut,reward,tmppool)

        reward =reward or {}
        local tmppool  = tmppool  or {}
        if method ==1 then
            tmppool=copyTable(pool)
        end
        if not next (pool) then
            return false
        end

        --info.rd 是自己是商店刷出来的记录n组
        if type (self.info.rd)~='table' then
            self.info.rd={}
            for i=1,group do
                self.info.rd[i]={}
            end
        end

        local delete =0
        if next(self.info.rd[grade])  then
            pool =copyTable(tmppool)
            for k,v in pairs(self.info.rd[grade]) do
                local p = k:split('p')
                p =tonumber(p[2])
                if pool[2][p]==nil or  pool[2][p] <= v then
                    --要清空整个概率的道具
                    pool[2][p]=0
                    delete=delete+1
                else
                    pool[2][p]=v
                end  
            end
            if #oldpool[2]==delete then
                pool =copyTable(tmppool)
                self.info.rd[grade]={}
            end 
        end 

        local result =getRewardByPool(pool)

        if next(result) then
            --记录一下哪个档次出来的物品
            for k,v in pairs(result) do
               local items=self.getPropKey(k,v,oldpool,grade)
               table.insert(self.info.shop,items)
               cuut=cuut+1
            end
            
        end

        if cuut>=num then
            return true
        else
            return self.getGradeShop(0,grade,pool,num,group,oldpool,cuut,reward,tmppool)
        end


    end

        -- 获取这个道具在数据池的key
    function self.getPropKey(id,num,pool,grade)
        
        local item = {}
        local p= 0
                --ptb:p(pool)
        for k,v in pairs(pool[3]) do
            if next(v) then
                if v[1]==id and v[2]==num then
                     item={v[1],v[2],v[3]}
                     p=k
                     local key ="p"..k
                     --(self.info.kt[k] or 0) + dieNum
                     self.info.rd[grade][key]=(self.info.rd[grade][key] or 0) + 1
                     break   
                end
            end
        end
        return item,p

        --ptb:e(pool)
    end

    --  攻击npc 
     -------------- 关卡战斗
    -- sid 关卡id
    -- fleetInfo 军队属性
    function self.battlenpc(uid,fleetInfo,defFleetInfo,challengeCfg,propsConsume,aranking,dranking)
        local defSkill = challengeCfg.skill
        local defTech = challengeCfg.tech
        local defAllianceTech = challengeCfg.alliance_tech
        local defAttUp = challengeCfg.attributeUp
        local defLevel = challengeCfg.level -- 关卡等级
        local defName = challengeCfg.name -- 关卡名称

        local uobjs = getUserObjs(uid)
        local aUserinfo = uobjs.getModel('userinfo')
        local attackFleet = uobjs.getModel('troops')
        local ahero = uobjs.getModel('hero')
        local aHeros = ahero.getAttackHeros('m',1)
        local aSequip = uobjs.getModel('sequip')
        local aSequipid = aSequip.getEquipFleet('m',1)
        local aPlane = uobjs.getModel('plane')
        local aPlaneid = aPlane.getPlaneFleet('m',1)
        
        local aFleetInfo,aAccessory,aherosInfo,aPlanevalue = attackFleet.initFleetAttribute(fleetInfo, 11,{hero=aHeros,equip=aSequipid,plane=aPlaneid})  
        local dFleetInfo = self.initDefFleetAttribute(defFleetInfo,defSkill,defTech,defAttUp,defAllianceTech)
    
        require "lib.battle"
        
        local report,aInavlidFleet, dInvalidFleet,aSurviveTroops,dSurviveTroops= {}        
        local isWin = -1
         -- 本次双方损失的坦克数量
        local lostShip = {
            attacker  = {},
            defenser = {},
        }

         -- 双方总坦克对比
        local dtankinfo={}
        if type(defFleetInfo) == 'table' then
            for k,v in pairs(defFleetInfo) do
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
        local tankinfo={a=atankinfo,d=dtankinfo}
        report.d, report.w, aInavlidFleet, dInvalidFleet = battle(aFleetInfo,dFleetInfo)
        report.t = {defFleetInfo,fleetInfo}
        report.h = {{},aherosInfo[1]}
        report.se = {0, aSequipid}
        report.p = {{defName,defLevel,0},{aUserinfo.nickname,aUserinfo.level,1}}

        local aDmgInfo,dDmgInfo
        lostShip.attacker ,aSurviveTroops, aDmgInfo = self.damageTroops(uid,fleetInfo,aInavlidFleet)
        lostShip.defenser,dSurviveTroops, dDmgInfo = self.damageTroops(0,defFleetInfo,dInvalidFleet)

        local rank = 0
        if report.w ==1 and aranking-dranking>0 then
            rank=aranking-dranking
        end

        local reportParams = {
            -- 使用的装甲矩阵信息
            armor = {
                uobjs.getModel('armor').formatUsedInfoForBattle(),
                {},
            },
            -- 使用的异星武器信息
            alienWeapon = {
                uobjs.getModel('alienweapon').formatUsedInfoForBattle(),
                {},
            },
            -- 双方详细的战损信息
            dmginfo = {
                aDmgInfo,
                dDmgInfo
            },
            -- 双方的头像信息
            attackerPic = {aUserinfo.pic,aUserinfo.bpic,aUserinfo.apic},
            defenserPic = {},
            -- 双方信息
            userinfo = {
                {aUserinfo.showvip(),aUserinfo.fc,aUserinfo.level,aUserinfo.alliancename},
                {}
            },
            plane={aPlanevalue,{}},
        }

        self.sendReport(uid,defName,defName,report,lostShip,1,report.w,{aAccessory,{}},rank,{{aherosInfo[1],aherosInfo[2]},{{},0}},tankinfo,{aSequipid,0},reportParams)
        return report,report.w
    end

    -- 初始化军队属性
    function self.initDefFleetAttribute(tanks,skills,techs,defAttUp)
        local inittanks = initTankAttribute(tanks,techs,skills,nil,nil,2,{acAttributeUp=defAttUp})
        return inittanks
    end

    ---------兵损失量--------------
    function self.damageTroops(uid,fleetInfo,invalidFleetInfo)
        local dietroops = {}
        local troops = {}

        -- 战报优化客户需要的数据格式：{tid-该位置参战数量-剩余数量，tid-该位置参战数量-剩余数量}
        local detailForClient = {}

        for k,v in pairs(fleetInfo) do           
            if next(v) then
                ------损失坦克
                local dieNum = v[2] - invalidFleetInfo[k].num                
                local aid = v[1]
                dietroops[aid]= (dietroops[aid] or 0) + dieNum
                
                if invalidFleetInfo[k].num > 0 then
                    table.insert(troops,{aid,invalidFleetInfo[k].num})
                else
                    table.insert(troops,{})
                end
                detailForClient[k] = string.format("%s-%s-%s",v[1],v[2],dieNum)
            else
                table.insert(troops,{})
                detailForClient[k] = ""
            end
        end
                
        return dietroops,troops,detailForClient
    end



    ----------获取最近一次领奖时间和下一次领奖时间------
    function self.getRewardTime(ts)
        ts = ts or getClientTs()
        --ts时间是周几
        local weekday=tonumber(getDateByTimeZone(ts,"%w"))
        if weekday==0 then
            weekday=7
        end
        local uptime=0
        local dntime = 0
        local arenaCfg = getConfig('arenaCfg')
        local weeTs = getWeeTs()
        local rewardTime = arenaCfg.rewardTime
        local flag =false
        local losttime = 0

        for k,v in pairs(rewardTime)  do
           
            if v>=weekday then

                    if  weekday==v then

                        flag=true
                        local key = k-1
                        if rewardTime[key] then
                             uptime = weeTs
                         else
                             uptime = weeTs
                        end
                       
                        local key = k+1
                        if rewardTime[key] then
                            dntime = weeTs+((rewardTime[key]-weekday)*86400)
                        else
                            dntime = weeTs+86400+((v-weekday)*86400)
                        end

                        break

                    else
                       
                        flag=true
                        local key = k-1
                        if rewardTime[key] then
                             uptime = weeTs-((weekday-rewardTime[key])*86400)
                         else
                             uptime = weeTs
                        end
                       
      
                        local key = k
                       
                        if rewardTime[key] then
                            
                            dntime = weeTs+((rewardTime[key]-weekday)*86400)
                        else
                            dntime = weeTs+86400+((v-weekday)*86400)
                        end
                       
                        break
                    end
                
            end
            losttime=weeTs+86400+(v-weekday)*86400
        end

        if flag==false then
               dntime =weeTs+86400+rewardTime[1]*86400
               uptime =losttime
        end

        return {uptime,dntime}
    end



    return self

end