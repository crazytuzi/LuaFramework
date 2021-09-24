function model_userexpedition(uid,data)
        -- the new instance
    local self = {
        -- public fields go in the instance table
        uid= uid, 
        eid=1, --攻打的第几关
        point=0,
        info={}, -- 自己死的坦克，英雄,本关击杀的坦克，本关的坦克,本关的英雄
        binfo={}, -- 自己正在攻击关卡的属性
        reset=0 ,  --重置远征次数
        acount=0, -- 相同的关卡手动通关次数(达到一定次数后才能扫荡)
        reset_at=0,  --上一次充值时间
        updated_at=0,   -- 最近一次更新时间 
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




    -- 添加物品
   
    function self.addResource(column,num)
        if self[column]~=nil then
            self[column]=self[column]+num
            
        else
            self.point=self.point+num
        end
        regKfkLogs(self.uid,'expedition',{
                        addition={
                            {desc="远征积分添加",value=num},
                            {desc="远征积分添加前",value=self.point-num},
                            {desc="远征积分添加后",value=self.point},
                        },
                        }
                  
                )
        return true
    end

    -- 使用积分
    function self.usePoint(data)

        for k,v in pairs(data) do
            if self.point-v<0 then
                return false

            else
                self.point=self.point-v  
                regKfkLogs(self.uid,'expedition',{
                        addition={
                            {desc="远征积分使用",value=v},
                            {desc="远征积分使用前",value=self.point+v},
                            {desc="远征积分使用后",value=self.point},
                        },
                        }
                  
                )
            end
        end

        return true
    end

    -- 进攻
    function self.battle(attUid,fleetInfo,aheros, aEquip,plane)

        if aheros==nil then
            aheros={}
        end
        local auobjs = getUserObjs(attUid)
        local aUserinfo = auobjs.getModel('userinfo')
        local aHero = auobjs.getModel('hero')
        local aSequip = auobjs.getModel('sequip')
        
        -- 本次双方损失的坦克数量
        local lostShip = {
            attacker  = {},
            defenser = {},
        }

        local award,resource
        
        local mSequip = auobjs.getModel('sequip')
        local debuffvalue = mSequip.dySkillAttr(aEquip, 's101', 0) --关卡护盾 减少敌方伤害x%
        local buffvalue = mSequip.dySkillAttr(aEquip, 's102', 0) --关卡强击 我方伤害增加X%       
       
        --  初始化攻击方          
        local attackFleet = auobjs.getModel('troops')
        local aFleetInfo,aAccessory,aherosInfo,aplanevalue = attackFleet.initFleetAttribute(fleetInfo,0,{hero=aheros,equip=aEquip,equipskill={dmg=buffvalue, dmg_reduce=1-debuffvalue},plane=plane}) 
       
         -- 初始化防守方

        local defFleetInfo=copyTable(self.binfo)
        local FleetInfo=copyTable(fleetInfo)
        local dAccessory = self.info.acy or {0,{}}
        local dherosInfo = self.info.ahf or {{},0}    
        local dEquip = self.info.se or 0  
        local dFleetInfo =copyTable(self.info.at)
        local dplanevalue = self.info.planevalue or {}
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



        local bid = self.eid
        if type(self.info.kt)=='table' and next(self.info.kt) then
            
            for k,v in pairs(self.info.kt) do
                if v>0 then
                    defFleetInfo[k].num=defFleetInfo[k].num-v
                    if defFleetInfo[k].num <=0 then
                        defFleetInfo[k]={}
                        dFleetInfo[k]={}    
                    else
                       defFleetInfo[k].hp=defFleetInfo[k].maxhp*defFleetInfo[k].num
                       dFleetInfo[k][2]=defFleetInfo[k].num 
                    end
                end
            end
        end
        local dUserinfo = {nickname=self.info.user[1],pic=self.info.user[2],bpic=self.info.user[8],apic=self.info.user[9]}
        local dlvl = self.info.user[3]
        local defuid = self.info.user[5] or 0
       
         -- 双方装备对比
        --dAccessory
        --aAccessory
        require "lib.battle"
        
        local report, aInavlidFleet, dInvalidFleet,attSeq,seqPoint,aSurviveTroops,dSurviveTroops= {}
        -- 防守方先出手
        -- report.r==1 攻击者胜利 
        report.d, report.w, aInavlidFleet, dInvalidFleet,attSeq,seqPoint = battle(aFleetInfo,defFleetInfo)
        report.t = {dFleetInfo,fleetInfo}

        if attSeq == 1 then
            report.p = {{dUserinfo.nickname,dlvl,1,seqPoint[2],defuid},{aUserinfo.nickname,aUserinfo.level,0,seqPoint[1]},attUid}            
        else
            report.p = {{dUserinfo.nickname,dlvl,0,seqPoint[2],defuid},{aUserinfo.nickname,aUserinfo.level,1,seqPoint[1]},attUid}
        end

        report.h = {dherosInfo[1],aherosInfo[1]}

        report.se ={dEquip or 0, aSequip.formEquip(aEquip)}

        local aDmgInfo,dDmgInfo
        lostShip.attacker ,aSurviveTroops, aDmgInfo = self.damageTroops(attUid,fleetInfo,aInavlidFleet,aheros, aEquip)
        lostShip.defenser,dSurviveTroops, dDmgInfo = self.killTroops(defuid,dFleetInfo,dInvalidFleet)

        local reportParams = {
            -- 双方详细的战损信息
            dmginfo = {
                aDmgInfo,
                dDmgInfo
            },
            -- 双方的头像信息
            attackerPic = {aUserinfo.pic,aUserinfo.bpic,aUserinfo.apic},
            defenserPic = {dUserinfo.pic or "",dUserinfo.bpic or "",dUserinfo.apic or ""},
            userinfo = {
                {aUserinfo.showvip(),aUserinfo.fc,aUserinfo.level,aUserinfo.alliancename},
                {self.info.user[10] or 0,self.info.user[4],self.info.user[3],self.info.user[7]},
            },
            plane={aplanevalue,dplanevalue},
        }

        self.sendReport(attUid,defuid,dUserinfo.nickname,report,bid,dlvl,lostShip,1,report.w,{aAccessory,dAccessory,},{{aherosInfo[1],aherosInfo[2]},{dherosInfo[1],dherosInfo[2]}},tankinfo,{aSequip.formEquip(aEquip),dEquip},reportParams)
        --如果赢了 将自己的数据放到公共池中
        if report.w==1 then
            local fc =self.refreshExpFighting(self.uid,fleetInfo,aheros,aEquip,plane)
            local grade=getExpeditionGrade(fc)
            local aFleetInfo,aAccessory,aherosInfo,planevalue = self.initFleetAttribute(FleetInfo,0,{hero=aheros,equip=aEquip,plane=plane})
            require "model.expedition"
            local mExpedition = model_expedition()
            local data = {}
            data.uid=self.uid
            data.grade=grade
            local newheros={}
            if type(aheros)=='table' and next(aheros) then
                for k,v in pairs(aheros) do
                    if v~=0 then
                        local item =aHero.getAHero(v)
                        table.insert(newheros,item)
                    else
                        table.insert(newheros,{})
                    end
                end
            end
            data.info=json.encode({h=newheros,hf=aherosInfo,t=fleetInfo,ay=aAccessory,se=aSequip.formEquip(aEquip),planevalue=planevalue})
            data.binfo=json.encode(aFleetInfo)
            data.name=aUserinfo.nickname
            data.level=aUserinfo.level
            data.fc=fc
            data.pic=aUserinfo.pic--头像
            data.bpic=aUserinfo.bpic--头像框
            data.apic=aUserinfo.apic--挂件
            data.maxt=attackFleet.getMaxBattleTroops()
            data.aname=aUserinfo.alliancename
            data.vip=aUserinfo.showvip() 
            local ret =mExpedition.createExpedition(data)
            --超过最大关卡
            local eid = self.eid+1
            if self.eid+1>15 then
                self.info.win=1
            else
                --然后在初始化自己的下一关的关卡数据
                self.eid=eid
                self.getInFo(self.info.grade,eid)
            end 
            
        end
        
        return report
       

    end


     -- 初始化军队属性
    function self.initDefFleetAttribute(tanks,skills,techs,defAttUp)
        local inittanks = initTankAttribute(tanks,techs,skills,nil,nil,2,{acAttributeUp=defAttUp})
        return inittanks
    end
  

    ---------添加自己兵损失量 并加入自己死的信息中--------------
    function self.damageTroops(uid,fleetInfo,invalidFleetInfo,heros,equip,plane)
        local dietroops = {}
        local troops = {}

        -- 战报优化客户需要的数据格式：{tid-该位置参战数量-剩余数量，tid-该位置参战数量-剩余数量}
        local detailForClient = {}

        if type(self.info.dt)~='table' then  self.info.dt={}  end
        if type(self.info.dh)~='table' then  self.info.dh={}  end
        if type(self.info.dse)~='table' then self.info.dse={} end
        if type(self.info.dpe)~='table' then self.info.dpe={} end
        local dnum = 0
        for k,v in pairs(fleetInfo) do           
            if next(v) then
                ------损失坦克
                local dieNum = v[2] - invalidFleetInfo[k].num              
                local aid = v[1]
                self.info.dt[aid]= (self.info.dt[aid] or 0) + dieNum
                dietroops[aid]= (dietroops[aid] or 0) + dieNum
                
                if invalidFleetInfo[k].num > 0 then
                    table.insert(troops,{aid,invalidFleetInfo[k].num})
                else
                    if heros[k]~=nil and heros[k]~=0 then
                        table.insert(self.info.dh,heros[k])
                    end
                    table.insert(troops,{})
                    dnum = dnum + 1
                end

                detailForClient[k] = string.format("%s-%s-%s",v[1],v[2],dieNum)
            else
                table.insert(troops,{})
                dnum = dnum + 1
                detailForClient[k] = ""
            end
        end
                
        if equip and dnum == 6  then
            self.info.dse = self.info.dse or {}
            self.info.dse[equip] = (self.info.dse[equip] or 0) + 1
        end
        if plane and dnum == 6  then
            self.info.dpe = self.info.dpe or {}
            table.insert(self.info.dpe,plane)
        end

        return dietroops,troops,detailForClient
    end

    --  本关卡击杀的坦克
    function self.killTroops(uid,fleetInfo,invalidFleetInfo)
        local dietroops = {}
        local troops = {}

        -- 战报优化客户需要的数据格式：{tid-该位置参战数量-剩余数量，tid-该位置参战数量-剩余数量}
        local detailForClient = {}

        if type(self.info.kt)~='table' then  self.info.kt={}  end

        for k,v in pairs(fleetInfo) do           
            if next(v) then
                ------损失坦克
                local dieNum = v[2] - invalidFleetInfo[k].num                
                local aid = v[1]
                dietroops[aid]= (dietroops[aid] or 0) + dieNum
                
                self.info.kt[k]=(self.info.kt[k] or 0) + dieNum
                if invalidFleetInfo[k].num > 0 then
                    table.insert(troops,{aid,invalidFleetInfo[k].num})
                else
                    table.insert(troops,{})
                end

                detailForClient[k] = string.format("%s-%s-%s",v[1],v[2],dieNum)
            else
                self.info.kt[k]=(self.info.kt[k] or 0) + 0
                table.insert(troops,{})
                detailForClient[k] = ""
            end
        end
                
        return dietroops,troops,detailForClient
    end

    --获取奖励 
    function self.getReward(eid)
        local  reward ={}
        local  point  =0
        local cfg = getConfig("expeditionCfg.reward")
        
        local addreward =copyTable(cfg['s'..eid])
        --g*eid*  resource count
        local grade =self.info.grade
        if addreward.resource~=nil then
            for k,v in pairs(addreward.resource) do
                if addreward.rate.r~=nil and addreward.rate.r>0 then
                    reward[k]=v+(grade*addreward.rate.r)
                else
                    reward[k]=v
                end
                
            end
        end

        if addreward.point~=nil then 

            if addreward.rate.p~=nil and addreward.rate.p>0 then
                point=math.floor(addreward.point+(math.pow(grade,0.8) *addreward.rate.p))
            else
                point=addreward.point
            end
            
        end

        if addreward.pool ~=nil then
            if type(addreward.pool[4]=='table')  then
                for k,v in pairs(addreward.pool[2]) do
                    if addreward.pool[4][k]~=nil and addreward.pool[4][k]>0 then
                        addreward.pool[2][k]=v+addreward.pool[4][k]*grade
                    end
                end
            end
            addreward.pool[4]=nil
            local pool =addreward.pool
            local item =getRewardByPool(pool)
            reward=item
            
        end
        return reward,point
    end

    --self.sendReport(attUid,defuid,dUserinfo.nickname,report,bid,dlvl,lostShip,1,report.w,{aAccessory,dAccessory,},{{aherosInfo[1],aherosInfo[2]},{dherosInfo[1],dherosInfo[2]}})
    -- 发送战报
    function self.sendReport(uid,receiver,dfname,report,eid,dlvl,lostShip,type,isVictory,aey,heros,tankinfo,equip,reportParams)    
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
       battlelogLib:logExpeditionSent(uid,receiver,dfname,type,isVictory,eid,dlvl,log)        
    end

    --获取自己的关卡信息并设置
    function self.getInFo(mygrade,eid)
        local binfo  = {}
        local troops = {}
        local heros =  {}
        local herosInfo = {}
        local aAccessory= {} 
        local userinfo = {}
        local equip = nil
        require "model.expedition"
        local mExpedition = model_expedition()
        
        local expeditionCfg=getConfig("expeditionCfg")
        local maxCount=expeditionCfg.maxCount 
        local challenge =expeditionCfg.challenge
        local grade   =mygrade+expeditionCfg.expeditionid[eid]
        if grade<=0 then
            grade=1
        end
        local info =mExpedition.getExpeditions(grade,maxCount)
        local rate=0
        local attackgrade=0
        local count=0
        if not next(info )  then
            for i=grade-1,1,-1 do
                if grade<=0 then
                    break
                end
                rate=rate+1
                info =mExpedition.getExpeditions(i,maxCount)
                if info~=nil and next(info)then
                    break
                end
                count=count+1
                if count>=3 then
                    break
                end
            end

        end


        
        if not next(info) then
            local bid='s'..grade
            if challenge[bid]~=nil  then
                userinfo=challenge[bid].userinfo
                troops=challenge[bid].tank
                binfo=self.initDefFleetAttribute(challenge[bid].tank,challenge[bid].skill,{},challenge[bid].attributeUp)
            else
                local len=0
                for k,v in pairs(challenge) do
                    len=len+1
                end
                local rate =(grade-len)/20
                local bid  ='s'..len
                userinfo=copyTable(challenge[bid].userinfo)
                userinfo[4]=math.floor(userinfo[4]*math.pow(1.1,grade-len))
                troops=challenge[bid].tank
                local attributeUp =copyTable(challenge[bid].attributeUp)

                for k,v in pairs(attributeUp) do
                    if k=='armor' or k=='arp' then
                        attributeUp[k]=v+rate
                    else
                        attributeUp[k]=v*(1+rate)
                    end
                end


                binfo=self.initDefFleetAttribute(challenge[bid].tank,challenge[bid].skill,{},attributeUp)
            end   

        else
            -- 取出来是玩家的数据
            local len =#info 
            if len>maxCount then
                for i=1,len-maxCount do
                    table.remove(info,1)
                end    
                len=maxCount
            end
            setRandSeed()
            local randnum = rand(1,len)
            local user =info[randnum]
            user.info =(json.decode(user.info))
            local abinfo= (json.decode(user.binfo))
            binfo=copyTable(abinfo)
            local fc=tonumber(user.fc)
            if rate>0 then
                local rate=rate/20
                local fcrate =(rate*2)
                fc =math.floor(tonumber(user.fc)+tonumber(user.fc)*fcrate)
                for k,v in pairs(binfo) do
                    if next(v) then  
                        binfo[k]['dmg']=v.dmg+v.dmg*rate
                        binfo[k]['maxhp']=v.maxhp+v.maxhp*rate
                        binfo[k]['hp']=binfo[k]['maxhp']*v.num
                    end
                end
            end
            aAccessory=user.info.ay
            equip=user.info.se
            herosInfo=user.info.hf
            heros=user.info.h
            troops=user.info.t
            if fc<=0 then
                fc=tonumber(user.fc)
            end
            userinfo={user.name,tonumber(user.pic),tonumber(user.level),fc,tonumber(user.uid),tonumber(user.maxt),user.aname,user.bpic,user.apic,user.vip}
        end


        if not next(binfo) then
            return false
        end
        self.binfo=binfo
        self.info.at=troops

        if next(heros) then
            self.info.ah=heros
        else
            self.info.ah=nil
        end
        if next(herosInfo) then
            self.info.ahf=herosInfo
        else
            self.info.ahf=nil
        end
        if next(aAccessory) then
            self.info.acy=aAccessory
        else
            self.info.acy=nil
        end
        if next(userinfo) then
            self.info.user=userinfo
        end
        if equip then
            self.info.se=equip
        end
        self.info.kt=nil
        return true
    end


    --刷新自己的当前兵的战斗力
    function self.refreshExpFighting(uid,troops,heros,equip,plane)
        local tankCfg = getConfig('tank')
        local techCfg = getConfig('tech')
        local skillCfg = getConfig('skill.skillList')    
        local challengeBuffCfg  -- 军团关卡奖励的BUFF配置 
        local rankCfg = getConfig('rankCfg')

        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel('userinfo')
        local mTroop = uobjs.getModel('troops')
        local mTech = uobjs.getModel('techs')
        local mSkill = uobjs.getModel('skills')
        local mAlien = uobjs.getModel('alien')
        local mAccessory = uobjs.getModel('accessory')
        local mChallenge = uobjs.getModel('challenge')
        local mHero = uobjs.getModel('hero')

        local mSequip = uobjs.getModel('sequip')
        local mArmor  = uobjs.getModel('armor')
        local mPlane  = uobjs.getModel('plane')
        local planeValue=mPlane.getMaxBattlePlane()
         --装甲战斗力加成
        local armorPower=mArmor.getUsedArmorFighting()
        -- local maxNumByTeam = mTroop.getMaxBattleTroops( equip )
         --超级装备加成
        local equipcodeAttr = mSequip.getFightAttrSquip(equip)
        local pairs = pairs
        local totalFighting = 0    
        local teamNum = 6
        local techs = mTech.toArray(true)
        local skills = mSkill.toArray(true)
        local accessoryAttribute = mAccessory.getUsedAccessoryAttribute() --装备
        local challengeBuff = mChallenge.getChallengeBuff()   -- 关卡buff
        local rankAttribute = rankCfg.rank[mUserinfo.rank].attAdd   -- 军衔加成
        local acc2TankType = {t1=1,t2=2,t3=4,t4=8}
        local attribute2Code = {decritDmg=111,critDmg=110,anticrit=105,crit=104,accuracy=102,evade=103,crit=106,anticrit=107,dmg=100,maxhp=108,attack=100,hp=108,armor=201,arp=202}

        local allianceSkills
        local allianceSkillCfg
        -- 军团技能
        if mUserinfo.alliance and mUserinfo.alliance > 0 then
            local allAllianceSkills = M_alliance.getAllianceSkills{aid=mUserinfo.alliance}
            if type(allAllianceSkills) == 'table' then
                if allAllianceSkills.s11 or allAllianceSkills.s12 or allAllianceSkills.s13 or allAllianceSkills.s14 then
                    allianceSkills = {}
                    allianceSkills.s11 = allAllianceSkills.s11
                    allianceSkills.s12 = allAllianceSkills.s12
                    allianceSkills.s13 = allAllianceSkills.s13
                    allianceSkills.s14 = allAllianceSkills.s14
                    allianceSkillCfg = getConfig("allianceSkillCfg")
                end
            end
        end
  
        if type(troops) ~= 'table' then
            return 0
        end

        local getFightingByAid = function (aid) 
            local fighting=tankCfg[aid].Fighting
            local per = {}
            local tankType = tankCfg[aid].type

            for sid,skillLevel in pairs(skills) do
                if sid ~= 'queue' and skillLevel > 0 and table.contains(skillCfg[sid].skillBaseType,tankType) then
                    local attributeType = tonumber(skillCfg[sid].attributeType) or 0
                    if attributeType>0 then
                        per[attributeType] = (per[attributeType] or 1) +  (1 + skillCfg[sid].skillValue*skillLevel)/4
                    end
                end
            end
            
            -- 军团技能加成
            if type(allianceSkills) == 'table' and next(allianceSkills) then
                for sid,skillLevel in pairs(allianceSkills) do                
                    skillLevel = tonumber(skillLevel)
                    if skillLevel > 0 and table.contains(allianceSkillCfg[sid].skillBaseType,tankType) then
                        local attributeType = tonumber(allianceSkillCfg[sid].attributeType)      
                        per[attributeType] = (per[attributeType] or 1) +  (allianceSkillCfg[sid].value[skillLevel])/400
                    end
                end
            end

            for tid,techLevel in pairs(techs) do
                if tid ~= 'queue' and techCfg[tid].baseType == tankType then  
                    local attributeType = tonumber(techCfg[tid].attributeType)
                    per[attributeType] = (per[attributeType] or 1) +  (techCfg[tid].value[techLevel]/400)                
                end
            end

            -- 装备加成
            for accType,accessoryInfo in pairs(accessoryAttribute or {}) do
                if acc2TankType[accType] == tankType then         
                    for attribute,value in pairs(accessoryInfo) do                    
                        if attribute2Code[attribute] == 201 or attribute2Code[attribute] == 202 then                        
                            per[attribute2Code[attribute]] = (per[attribute2Code[attribute]] or 1) + (value/200)
                        else
                            per[attribute2Code[attribute]] = (per[attribute2Code[attribute]] or 1) + (value/4)   
                        end
                    end
                end
            end

            -- 军衔加成
            if rankAttribute then
                if rankAttribute[1] > 0 then
                    per[100] = (per[100] or 1) + (rankAttribute[1]/4)
                end

                if rankAttribute[2] > 0 then
                    per[108] = (per[108] or 1) + (rankAttribute[2]/4)
                end
            end
            
            -- 关卡buff加成
            for k,v in pairs(challengeBuff or {}) do 
                challengeBuffCfg = challengeBuffCfg or getConfig("challengeTech")
                local attributeType = challengeBuffCfg[k].attributeType     
                if attributeType then
                    per[attributeType] = (per[attributeType] or 1) +  (challengeBuffCfg[k].value[v])/4
                end
            end
            -- 异星科技加成
            local alienTechs = mAlien.getAttrValueByTank(aid)
            for k,v in pairs(alienTechs or {}) do
                -- 技能
                if type(k) == 'string' and #k == 1 then
                    local alienAbility = 'alien_'..k
                    per[alienAbility] = (per[alienAbility] or 1) + 0.2
                -- 暴击伤害和暴击伤害减少
                elseif k == 110 or k == 111 then
                    per[k] = (per[k] or 1) + v/5
                -- 加攻
                elseif k == 100 then
                    per[k] = (per[k] or 1) + v/tankCfg[aid].attack/4
                -- 加血
                elseif k == 108 then
                    per[k] = (per[k] or 1) + v/tankCfg[aid].life/4
                -- 其它
                elseif k~= 200 then
                    per[k] = (per[k] or 1) + v/400
                end
            end
            --军徽
            for k, v in pairs(equipcodeAttr) do
                if k == 110 or k == 111 then
                    v = v/5
                elseif k == 100 or k == 108 or k == 102 or k ==103 or k == 104 or k == 105 or k == 106 or k == 107 then
                    -- 如果是  生命 和 攻击 ， 命中，闪避，暴击，免暴 这六种属性 则 /4
                    v = v/4
                elseif k == 201 or k == 202   then
                    -- 如果是  击破 防护 ，  则 /200
                    v = v/200                
                end

                per[k] = (per[k] or 1) + v
            end



            local tPer = 1
            for k,v in pairs(per) do
                tPer = tPer * v
            end

            return fighting*tPer
        end

        local troopsFightingInfo = {}    

        

        local allFightings = {}
        for k,teamInfo in pairs(troops) do
            if type(teamInfo) == "table" and next(teamInfo) then
                local fighting = getFightingByAid(teamInfo[1])
                
                table.insert(allFightings,math.pow(teamInfo[2],0.7)*fighting)
            end
        end

        table.sort(allFightings,function(a,b)return (a> b) end)
        local heroPower ={}
        heroPower=mHero.getTheHerosValue(heros)
        table.sort(heroPower,function(a,b)return (a> b) end)
        for k,v in ipairs(allFightings) do
           
            -- 英雄加成
            if heroPower[k]~=nil then
                v = v + v*heroPower[k]/2000
            end
           
             -- 装甲加成
            if armorPower[k]~=nil and armorPower[k]>0 then
                v = v + v*armorPower[k]/2000
            end
            --飞机加成
            if planeValue>0 then
                v = v + v*planeValue/7000
            end

            totalFighting = totalFighting + v
            if k >= teamNum then break end
        end
        
        totalFighting = math.floor(totalFighting)
         

        return totalFighting
          
    end

    -- 刷新自己的商店

    function self.refreshShop(shopCfg,level)
        -- 如果开将领装备就要换商店
        local cfg={}
        if moduleIsEnabled('he') == 1 then
            local pool=shopCfg.Shopdminput
            for k,v in pairs (shopCfg.Shopdoutput) do
                if level>=v then
                    pool=k
                end 
            end
            cfg=copyTable(shopCfg['rewardPool'..pool])
        else
            cfg=copyTable(shopCfg.rewardPool) 
        end
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




    -- 把自己的赢的数据插入公共数据池中，但不算道具的加成
    function self.initFleetAttribute(fleetInfo,battleType,params)
        local uobjs = getUserObjs(self.uid)
        local mTroop = uobjs.getModel('troops')
        return mTroop.initFleetAttribute(fleetInfo,7,params)
    end

    return self

end