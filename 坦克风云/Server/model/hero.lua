function model_hero(uid,data)
    local self = {
        uid=uid,
        hero={}, --英雄
        soul={}, --英魂
        info={}, --抽取数据
        exp=0,  -- 新的升级exp
        stats={},--各种英雄的状态 -- a 攻击  d 防守  m 军演  l 军团战  
        feat={}, -- 正在接受的授勋任务的英雄
        finfo={}, -- 所有英雄领悟属性
        hfeats={}, -- 所有英雄
        anneal={}, -- 将领试炼
        updated_at=0,
    }



        local meta = {
            __index = function(tb, key)
                    return rawget(tb,tostring(key)) or rawget(tb,'h'..key) or 0
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
        -- 检测领取授勋任务将领信息
        self.checkfeat()

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

        -- 为兼容前端代码，将领升级特殊处理
        if format and moduleIsEnabled('bs') ~= 1 then
            data['exp'] = nil
        end

        return data
    end

    --添加英雄
    --id  英雄id
    --p   英雄的品阶  
    function self.addhero(hid,p)
        
        local heroCfg = getConfig('heroListCfg.'..hid)
        if type (heroCfg)~='table' then    return false  end
        --真实将领没开，试图添加
        if moduleIsEnabled('truehero') == 0 and tonumber( string.sub(hid, 2, string.len(hid))) > 100 then return false end

        if type(self.hero[hid])=='table' and  next(self.hero[hid]) then

            --后期修改
            local Hcfg = getConfig('heroCfg')
            -- 新英雄的拼接
            local oldp=self.hero[hid][3]
            if self.hero[hid][3]<p then
                self.updatehero(hid,p-1)
                if p>=5 then
                    self.hero[hid][3]=5
                    if self.hero[hid][5]==nil then
                        local newskill=self.rankSkillHero(hid,1)
                        self.hero[hid][5]=newskill[1]
                    end
                    -- 二次授勋
                    if p==6 then
                        self.hero[hid][3]=6
                        if type(self.hero[hid][7])~="table"  then self.hero[hid][7]={} end
                        local newskill=self.rankSkillHero(hid,1)
                        if self.hero[hid][6]==nil then
                            self.hero[hid][6]=0
                        end
                        if self.hero[hid][7][1]==nil then
                            table.insert(self.hero[hid][7],newskill[1])
                        end
                    end
                end
                -- 要减等级
                self.hero[hid][1]=self.hero[hid][1]-((p-oldp)*10)
                if self.hero[hid][1]<1 then
                    self.hero[hid][1]=1
                end
                self.updateherolevel(hid,self.hero[hid][1],self.hero[hid][3])
                p=oldp
            end
            local count=math.floor(Hcfg.fusion[p]/2)
            local sid=heroCfg.fusionId
            local ret,flag=self.addsoul(sid,count)
            return ret,flag
        end
        -- 英雄的等级,英雄的等级点数,英雄的品阶，英雄的技能 ,后续的是授勋技能
        local hero = {1,0,0,{}}
        
        if next(heroCfg.skills) then
            for k,v in pairs(heroCfg.skills) do
                --print(v[1])
                hero[4][v[1]]=0
                if (k<=p) then
                    hero[4][v[1]]=1
                end
            end

        end
        hero[3]=p
        self.hero[hid]=hero
        if p>=5 then
            hero[3]=5
            if hero[5]==nil then
                local newskill=self.rankSkillHero(hid,1)
                hero[5]=newskill[1]
            end
            
            -- 二次授勋
            if p==6 then
                self.hero[hid][3]=6
                if type(self.hero[hid][7])~="table"  then self.hero[hid][7]={} end
                local newskill=self.rankSkillHero(hid,1)
                if self.hero[hid][6]==nil then
                    self.hero[hid][6]=0
                end
                if self.hero[hid][7][1]==nil then
                    table.insert(self.hero[hid][7],newskill[1])
                end
            end
        end
        
        return true
    end


    --修改英雄的品阶

    function self.updatehero(hid,p,throuhHeroLevel)
        
        if type (self.hero[hid])~='table' then
            return false
        end
        -- 英雄的等级,英雄的等级点数,英雄的品阶，英雄的技能
       
        local heroCfg = getConfig('heroListCfg.'..hid)
        for i=self.hero[hid][3],p do
            if next(heroCfg.throuh[i]) then
                
                if heroCfg.throuh[i]~=nil and heroCfg.throuh[i].skill~=nil then
                    if self.hero[hid][4][heroCfg.throuh[i].skill]==nil then
                        self.hero[hid][4][heroCfg.throuh[i].skill]=1
                    end
                    if self.hero[hid][4][heroCfg.throuh[i].skill]==0 then
                        self.hero[hid][4][heroCfg.throuh[i].skill]=1
                    end
                    self.hero[hid][3]=i+1
                    if throuhHeroLevel~=nil and type(throuhHeroLevel)=='table' then
                        self.updateherolevel(hid,throuhHeroLevel[i],i+1)
                    end
                    
                end
            end

        end
        
        return true

    end

    -- 修改授勋后的等级
    function self.updateheroThrouh(hid,p,throuhHeroLevel)
        -- body
        if type (self.hero[hid])~='table' then
            return false
        end
        self.hero[hid][3]=p+1
        self.updateherolevel(hid,throuhHeroLevel[p],p+1)
        return true
    end

    function self.rankSkillHero(hid,count,ption)
        local heroCfg =getConfig('heroSkillCfg')
        local skill={}
        local newskill={}
        local orandomType=nil
        if type(self.hero[hid][7])==nil or ption==nil  then
            orandomType=3
        end
        for k,v in pairs(heroCfg) do
            if v.randomType~=0  and v.randomType~=orandomType then
                local flag=true
                if self.hero[hid]~=nil then
                    for k1,v1 in pairs(self.hero[hid][4]) do   
                        if k1==k then
                            flag=false
                        end
                    end

                    -- 不是一次授勋 判断一次授勋技能
                    if ption then
                        -- 一次授勋的技能
                        if type(self.hero[hid][5])=='table' then
                            for k2,v2 in pairs(self.hero[hid][5]) do
                                if k2==k then
                                    flag=false
                                end
                            end
                        end
                    end
                    -- 不是二次授勋 判断二次授勋技能
                    if ption~=2 then
                        -- 二次授勋
                        if type(self.hero[hid][7])=='table' then
                            for k3,v3 in pairs(self.hero[hid][7]) do
                                if type(v3)=="table" then
                                    for sk,sv in pairs (v3) do
                                        if sk==k then
                                            flag=false
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if flag then
                    table.insert(skill,k)
                end
            end
        end
         -- 随机种子
        setRandSeed()
        local randnum = rand(1,100)
        for i=1,count do
            local key =rand(1,#skill)
            local sid=skill[key]
            -- 等级不对  需要找策划
            local level=self.getFeatLvel(hid,heroCfg[sid]['randomType'])
            local tmp={[sid]=level}
            table.insert(newskill,tmp)
            table.remove(skill,key)
        end
        
        return newskill
    end

    -- 授勋的等级
    function self.getFeatLvel(hid,randomType)
        local skillLevelLimit =getConfig('heroListCfg.'..hid..".skillLevelLimit")
        local aptitude =getConfig("heroFeatCfg.aptitude")
        --randomType =1  是拿着权重来分等级的   ＝2 是随机取等级
        local featcount=self.hero[hid][6] or  0
        
        local featlevel=0
        local level=1

        if featcount>0 then
            for k,v in pairs(aptitude) do
                if featcount>=v then
                    featlevel=k-1
                end
            end
        end

        local maxLevel=skillLevelLimit-10+featlevel
        setRandSeed()
        if randomType==2 then
              -- 随机种子
            level=rand(1,maxLevel)
        else
            local randarr={}
            local tal=0
            for i=1,maxLevel do
                tal=tal+maxLevel+1-i
                table.insert(randarr,tal)
            end
            local randnum=tonumber(rand(1,tal))
            for k,v in pairs(randarr) do
                if randnum>tonumber(v) and randnum<=randarr[k+1] then
                    level=k+1
                end
            end
            
        end
        return level
       
    end


    -- 修改英雄的等级
    function self.updateherolevel(hid,level,p)
        self.hero[hid][1]=level
        local heroCfg=getConfig('heroCfg')
        self.hero[hid][2]=heroCfg.levelUP[p][level]+1
    end

    --添加英魂
    function self.addsoul(sid,nums)
        nums = math.floor(tonumber(nums) or 0)
        local soulToHero=getConfig('heroCfg.soulToHero')
        local hid=soulToHero[sid]
        if hid~=nil and self.hero[hid]  then
            --授勋过就加道具
            if self.hero[hid][5]~=nil then
                local itemid=getConfig('heroCfg.getSkillItem')
                local uobjs = getUserObjs(self.uid)
                local mBag = uobjs.getModel('bag')
                local newcount=tonumber(self.soul[sid]) or 0 
                self.soul[sid]=0
                nums=newcount+nums
                regKfkLogs(self.uid,'item',{
                addition={
                    {desc="将领魂魄转换铁十字勋章",value=nums},
                    {desc="将领id",value=hid},
                   
                        }
                    }
                )
                local ret= mBag.add(itemid,nums)
                if  ret then
                    return true,1
                end
                return false
            end 


        end
        if nums > 0 and type(self.soul)== 'table' then
            
            local iCurrCount = tonumber(self.soul[sid]) or 0
            local iAllCount = nums + iCurrCount

            self.soul[sid]= iAllCount
            self.refreshFeat("t1",sid,nums)
            
            regKfkLogs(self.uid,'item',{
                    item_id=sid,
                    item_op_cnt=nums,
                    item_before_op_cnt=iCurrCount,
                    item_after_op_cnt=iAllCount,
                    item_pos='英魂',
                    flags={'item_id'},
                    merge={'item_op_cnt'},
                    rewrite={'item_after_op_cnt'},
                    addition={
                    },
                }
            )
            
            return true
        end
        
        -- body
        return false
    end



    -- 使用N种英魂
    function self.usemoresoul(data)
        local flag = true
        if type(data)=='table'  and next(data) then

            for k,v  in pairs (data) do
               local ret= self.usesoul(k,v)
               if not ret then
                    flag=false
                    break
               end
            end
        end   
        return flag
        
    end

    -- 删除英雄

    function self.deleteHero(hid)
        self.repairHerosStats(hid)
        if type (self.hero[hid]) ~='table' then
            return false
        end
        self.hero[hid]=nil
        return true
    end

    -- 使用英魂
    function self.usesoul(sid,nums)
        sid =tostring(sid)
        if type(self.soul)=='table'  then     
            local n = (tonumber(self.soul[sid]) or 0) - tonumber(nums)
            --regActionLogs(self.uid,4,{action=5,item=pid,value=nums,params={c=n}})
          
            if  n >= 0 then
                self.soul[sid] = n  
                if n==0 then
                    self.soul[sid] = nil
                end              

                return true
            end 
        end  

        return false

    end

    -- 设置英魂数

    function self.setSoulById(sid,nums)
        if nums<=0 then
            self.soul[sid] = nil
        else
            self.soul[sid] = nums
            self.refreshFeat('t1',sid,nums)
        end
        return true
    end
    -- 升级英雄 +点数 英雄有可能升级有可能点数不够
    function self.upgradeheropoint(hid,point,maxpoint,userlevel)
        if type (self.hero[hid]) ~='table' then
            return false
        end

        self.hero[hid][2]=self.hero[hid][2]+ point
        if self.hero[hid][2]>maxpoint then
            self.hero[hid][2]=maxpoint
        end
        local level = self.hero[hid][1]
        local p = self.hero[hid][3]
        local heroCfg = getConfig('heroCfg')
        if self.hero[hid][2]>heroCfg.levelUP[p][level] and (heroCfg.levelUP[p][level])~=nil then
            for k,v in pairs (heroCfg.levelUP[p]) do

                if self.hero[hid][2] > v then
                    if  heroCfg.levelUP[p][k+1] ~=nil then
                        self.hero[hid][1]=k
                        if self.hero[hid][1]>userlevel then
                            self.hero[hid][1]=userlevel
                            self.updateherolevel(hid,userlevel,self.hero[hid][3])
                        end
                    end
                end
            end
        end
        return true,self.hero[hid][1]
    end




    -- 检测英雄
    function self.checkFleetHeroStats(hero)
        -- check hero
        local tmp = {}
        if type(hero)=='table' and next(hero) then
            local len =#hero
            if len<6 then
                return false
            end
            local hcount=0
            --[[
                hero = {
                    'h1',
                    'h2',
                    'h3',
                    'h4',
                    'h5',
                    'h6',
                }
            ]]
            for k,v in pairs(hero) do
                if v~=0 then 
                    if type(self.hero[v])~='table' then
                        return false
                    end
                    local ret =self.checkHeroStats(v) -- true 可出战
                    if not ret then
                        return false
                    end
                    tmp[v] =(tmp[v] or 0) +1
                end
                if hero[k]==0 then
                    hcount=hcount+1
                end
            end
            if hcount>=6 then
                hero={}
            end

        end

        if next(tmp)  then
            for k,v in pairs(tmp) do
                if v >1 then
                    return false
                end
            end

        end
        -- check end
        return hero
    end
    -- 升级英雄的技能
    function self.upgradeheroskilllevel(hid,sid,level)
        if type (self.hero[hid]) ~='table' then
            return false
        end
        if self.hero[hid][4][sid]==nil then
            return false
        end
        self.hero[hid][4][sid]=level
        return true
    end


    --设置英雄
    function self.addHeroFleet(attack,hero,id)
        if type(hero)~='table' then
            return false
        end
        if not next(hero) then
            return false
        end
        if type (self.stats[attack])~='table' then  self.stats[attack]={} end
        self.stats[attack][id]=hero
        return true
    end
    --检测英雄是否存在
    function self.checkHero(hid)
        if type (self.hero[hid]) ~='table' then
            return false
        end
        return true
    end


    --获取单个英雄
    function self.getAHero(hid)
        -- body
        local hero={}
        if type(self.hero[hid])=='table' and next(self.hero[hid]) then
            hero={hid,self.hero[hid][1],self.hero[hid][3]}
        end

        return hero
    end

    -- 释放英雄 

    function self.releaseHero(attack,id)
        if type (self.stats[attack])=='table' then 
            if type(self.stats[attack][id])=='table' then 
                self.stats[attack][id]=nil
            end
        end
    end
    --获取军团战的英雄

    function self.getAllianceHero()
        local hero ={}
        if type (self.stats['l'])=='table' and next(self.stats['l']) then 
            hero=self.stats['l'][1]
        end
        return hero
    end


    --检测英雄状态 true 可出战
    function self.checkHeroStats(hid)
       local flag =true 
       local uobjs = getUserObjs(self.uid)
       local mTroop= uobjs.getModel('troops')
       if type (self.stats)=='table' then
            for k,v in pairs(self.stats) do
                -- 军演不检测英雄
                --ptb:p(k)
                if k =='a' and next(v) then
                    -- v = {["h39","h4","h29","h31","h21","h22"]}
                    for k1,v1 in pairs(v) do
                        --检测队列还存在吗 ？
                        local check =true
                        
                        if check then
                            -- v1 = ["h39","h4","h29","h31","h21","h22"]
                            for k2,v2 in pairs(v1) do
                                if v2==hid then
                                    flag=false
                                    return flag
                                end
                            end
                        end
                    end
                end
            end
       end

       return flag

    end
    -- 加多个将领
    function self.addMoreHero(hid,p,num)
        local flag = false
        if num>0 then
            for i=1,num do
                flag=self.addhero(hid,p)
            end
        end

        return flag
    end  

    -- 添加英雄或者添加英魂

    function self.addHeroResource(hero,num)  
        local flag = false
        local aret =string.find(hero,'h')
        if aret ~=nil then
            --num 是品阶
            flag=self.addhero(hero,num)
       
        end

        local sret =string.find(hero,'s')
        if sret ~=nil then
            flag = self.addsoul(hero,tonumber(num))
        end   

        return flag
    end
    

    --英雄的加成
    function self.getAttackHeros(attack,id)
        local heros = {}
        if type(self.stats[attack])~='table' then
            return heros
        end 
        if type(self.stats[attack][id])=='table' and next(self.stats[attack][id]) then
            if attack=='d' then
                for k,v in pairs(self.stats[attack][id]) do
                    local ret= self.checkHeroStats(v)
                    heros[k]=v
                    if not ret then
                        heros[k]=0
                    end
                end
                return heros
            end
            heros = self.stats[attack][id]
        end
        return heros
    end

    --英雄的加成
    function self.getAttHerosAttribute(heros)
        local Attr={}
        local Heros = {}
        local value = 0
        if type(heros)=='table' and next(heros) then
            for k,v in pairs(heros) do 
                if v~=0 then
                    local attrs,hero=self.getHeroAttribute(v)
                    Attr[k]=attrs
                    Heros[k]=hero
                else
                    Attr[k]={}
                    Heros[k]=""
                end

            end 

        end
        if next (Heros) then
            for i=#Heros,1,-1 do
                if Heros[i]=="" then
                    table.remove(Heros,i)
                else
                    break
                end
            end

        end
        value=self.getHerosValue(heros)
        return Attr,Heros,value
    end



    -- 英雄的加成

    function self.getHeroAttribute(hid)

        if type(self.hero[hid]) ~='table' then
            return {}
        end
        local heroCfg =getConfig('heroListCfg.'..hid)
        
        -- 英雄的等级,英雄的等级点数,英雄的品阶，英雄的技能
        
        local lvl =self.hero[hid][1]
        local p   =self.hero[hid][3]
        --atk={20,0.1}, -- 增加伤害
        -- hlp={20,0.1}, -- 减少伤害
        -- hit={1,0.1}, -- 命中
        -- eva={1,0.1}, --闪避
        -- cri={1,0.1}, -- 暴击
        -- res={1,0.1}, -- 免暴
        -- atk 提高造成伤害  影响方式 在最终结果上乘法     value = value * ( 1 + add ）
        -- hlp 减少所受伤害  影响方式 在最终结果上除法     value = value / ( 1 + add ）
        -- hit 提高 命中率   影响方式 在最终结果上加法     value = value + add
        -- eva 提高 闪避率   影响方式 在最终结果上加法     value = value + add
        -- cri 提高 暴击率   影响方式 在最终结果上加法     value = value + add
        -- res 提高 免暴率   影响方式 在最终结果上加法     value = value + add

        local Attrs={'atk','hlp','hit','eva','cri','res','first','antifirst'}
        local Attr={}
        Attr['a']={}
        for k,v in pairs(Attrs) do
            if heroCfg.heroAtt[v]~=nil then
                local reaction =heroCfg.heroAtt[v]
                Attr['a'][k]=p*reaction[1]+lvl*reaction[2]
            else
                Attr['a'][k]=0
            end
            
        end
        Attr['s'] ={}
        for k1,v1 in pairs(self.hero[hid][4]) do
            if v1 >0 then
                table.insert(Attr['s'],{k1,v1})
            end
        end
        if type(self.hero[hid][5])=='table' and next(self.hero[hid][5]) then
            for k2,v2 in pairs(self.hero[hid][5]) do
                if v2>0 then
                    table.insert(Attr['s'],{k2,v2})
                end
            end
        end
        -- 二次授勋后以后n次授勋都可以了！
        if type(self.hero[hid][7])=='table' and next(self.hero[hid][7]) then
            for k3,v3 in pairs(self.hero[hid][7]) do
                if type(v3)=="table" then
                    for sk,sv in pairs (v3) do
                        table.insert(Attr['s'],{sk,sv})
                    end
                end
            end
        end
        -- 将领装备-----------------------
        if moduleIsEnabled('he') == 1 then
            local uobjs = getUserObjs(self.uid)  
            local mEquip = uobjs.getModel('equip')
            local equipCfg = getConfig('equipCfg')
            local eattrs={}
            for i=1,6 do
                local sid='e'..i
                local upgrade=equipCfg[hid][sid].upgrade.att
                local grow=equipCfg[hid][sid].grow.att
                local awaken=equipCfg[hid][sid].awaken.att
                --ptb:p(equipCfg[hid][sid].awaken)
                local qlevel=1
                local plevel=1
                local alevel=0
                if type(mEquip.info[hid])=='table' and type(mEquip.info[hid][sid])=='table' then
                    qlevel=mEquip.info[hid][sid][1]
                    plevel=mEquip.info[hid][sid][2]
                    alevel=mEquip.info[hid][sid][3]
                    --[[if alevel>0 then
                        local skill=equipCfg[hid][sid].awaken.skill
                        if type(skill)=='table' then
                            for sk,sv in pairs (skill) do
                                for k,v in pairs (Attr['s']) do
                                    if v[1]==sk then
                                        v[1]=sv
                                    end
                                end
                            end
                        end
                    end]]
                end

                for k,v in pairs (grow)  do
                    eattrs[k]=(eattrs[k] or 0) +v*qlevel
                end 
                for k,v in pairs (upgrade)  do
                    eattrs[k]=(eattrs[k] or 0) +v*plevel
                end 
                for k,v in pairs (awaken)  do
                    eattrs[k]=(eattrs[k] or 0) +v*alevel
                end 
            end

            if next(eattrs) then
                for k,v in pairs(Attrs) do
                    if eattrs[v]~=nil then
                        Attr['a'][k]=Attr['a'][k] +eattrs[v]
                    end
                
                end
            end
            
        end

        return Attr,table.concat({hid,lvl,p},"-")

    end

    -- 英雄的强度值
    function self.getHerosValue(heros)
        local value =0
        
        for k,v in pairs(heros) do
            if type(self.hero[v]) =='table' then
                value=value+self.getHeroValue(v)
            end
        end
        return value
    end

    --
    -- 获取所有英雄的强度值
    function self.getAllHeroPower()
       local Power={}
       if type(self.hero)=='table' and next(self.hero) then
            for k,v in pairs(self.hero) do
                local power =self.getHeroValue(k)
                table.insert(Power,power)
            end
       end  
       return Power 
    end


    function self.getTheHerosValue(heros)
        if type(heros)~='table'  or  not next(heros) then
            return {}
        end 
        local values = {}
        for k,v in pairs(heros) do
            if v==0 then
                values[k]=0
            else
                values[k]=self.getHeroValue(v)
            end
           
        end
        return values
    end

    function self.updateheroskill(hid,eskill)
        if type(eskill)=='table' and type(self.hero[hid][4])=='table' then
            for sk,sv in pairs (eskill) do
                for k,v in pairs (self.hero[hid][4]) do
                    if sk==k then
                        self.hero[hid][4][sv]=v
                        self.hero[hid][4][k]=nil
                    end
                end
            end
         end
    end

    function self.getHeroValue(hid)
        local heroCfg =getConfig('heroListCfg.'..hid)
        
        -- 英雄的等级,英雄的等级点数,英雄的品阶，英雄的技能
        
        local lvl =self.hero[hid][1]
        local p   =self.hero[hid][3]
        local Attr=0
        for k,v in pairs(heroCfg.heroAtt) do
            Attr=Attr+p*v[1]+lvl*v[2]
        end
        Attr=Attr*10
        local skill={}
        for k1,v1 in pairs(self.hero[hid][4]) do
            if v1 >0 then
                skill[k1]=v1
                --local skillCfg =getConfig('heroSkillCfg.'..k1)
                --Attr=Attr+(tonumber(skillCfg.skillPower)*v1)
            end
        end
        if type(self.hero[hid][5])=='table' then
            for k2,v2 in pairs(self.hero[hid][5]) do
                if v2 >0 then
                    skill[k2]=v2
                    --local skillCfg =getConfig('heroSkillCfg.'..k2)
                    --Attr=Attr+(tonumber(skillCfg.skillPower)*v2)
                end
            end
            
        end
        -- 二次授勋的技能可以支持N次以后的
        if type(self.hero[hid][7])=='table' then
            for k3,v3 in pairs(self.hero[hid][7]) do
                if type(v3)=="table" then
                    for sk,sv in pairs (v3) do
                        skill[sk]=sv
                    end
                    --local skillCfg =getConfig('heroSkillCfg.'..k2)
                    --Attr=Attr+(tonumber(skillCfg.skillPower)*v2)
                end
            end
            
        end


          -- 将领装备-----------------------
        if moduleIsEnabled('he') == 1 then
            local uobjs = getUserObjs(self.uid)  
            local mEquip = uobjs.getModel('equip')
            local equipCfg = getConfig('equipCfg')
            local eattrs={}
            for i=1,6 do
                local sid='e'..i
                local upgrade=equipCfg[hid][sid].upgrade.att
                local grow=equipCfg[hid][sid].grow.att
                local awaken=equipCfg[hid][sid].awaken.att
                --ptb:p(equipCfg[hid][sid].awaken)
                local qlevel=1
                local plevel=1
                local alevel=0
                if type(mEquip.info[hid])=='table' and type(mEquip.info[hid][sid])=='table' then
                    qlevel=mEquip.info[hid][sid][1]
                    plevel=mEquip.info[hid][sid][2]
                    alevel=mEquip.info[hid][sid][3]
                    --[[if alevel>0 then
                        local eskill=equipCfg[hid][sid].awaken.skill 
                        if type(eskill)=='table' and next(skill) then
                            for sk,sv in pairs (eskill) do
                                for k,v in pairs (skill) do
                                    if sk==k then
                                        skill[sv]=v
                                        skill[k]=nil
                                    end
                                end
                            end
                        end
                    end]]
                end

                for k,v in pairs (grow)  do
                    eattrs[k]=(eattrs[k] or 0) +v*qlevel
                end 
                for k,v in pairs (upgrade)  do
                    eattrs[k]=(eattrs[k] or 0) +v*plevel
                end 
                for k,v in pairs (awaken)  do
                    eattrs[k]=(eattrs[k] or 0) +v*alevel
                end 
            end

            if next(eattrs) then
                local point=0
                for k,v in pairs(eattrs)  do
                    if k=='first' and  k=='antifirst'  then
                        point=point+v*4.5
                    else
                        point=point+v*10
                    end
                end
                Attr=Attr+point
            end


        end

        for sk2,sv2 in pairs(skill) do
                if sv2 >0 then
                    local skillCfg =getConfig('heroSkillCfg.'..sk2)
                    Attr=Attr+(tonumber(skillCfg.skillPower)*sv2)
                end
        end
        
        return Attr
    end

    -- 刷新当前授勋将领的任务
    function self.refreshCurrentFeat(tid,count)
        if type(self.feat)=='table' and self.feat[1] then
            return self.refreshFeat(tid,{self.feat[1]},count)
        end
    end

    -- 将领授勋刷新任务
    ----授勋任务( t1收集魂魄; t2携带该将领在16章及以后的关卡中获胜; t3携带此将领竞技场胜利n次; t4携带此将领击杀军团副本BOSS; t5携带此将领获得n军功 t6攻打n次补给线（包含扫荡）; t7通过远征军关卡n次 )
    function self.refreshFeat(tid,params,count,push)
        -- body
        if type(self.feat)~='table' or not next(self.feat) then
            return true
        end

        -- 如果tid等于nil 就是刷新收集英魂的任务检测一下当前英魂数
        local hid  =self.feat[1]
        if self.hero[hid]==nil then
            self.repairHerosStats(hid)
            self.feat={}
            return true
        end
        local heroFeatCfg = getConfig('heroFeatCfg')
        local fusionLimit =heroFeatCfg.fusionLimit
        local p      =self.hero[hid][3]
        local apcount=self.hero[hid][6] or 0
        local cfgkey =p-fusionLimit+1
        local task   = heroFeatCfg.heroQuest[hid][cfgkey][self.feat[2]]
        if params==0  then
             --魂魄收集
            if tid=="t1" then
                if task[3]~=nil then
                    self.feat[3]=(self.soul[task[3]]) or 0
                end
            end
            if tid=="t9" then  --将领资质收集
                self.feat[3]=self.heroQualLevel(apcount,heroFeatCfg.aptitude)
            end
            
            -- 检测是否参加异元战场  --只要没完全死亡并且没有结束就算一次完成
            if tid=="t11" then
                local cobjs = getCacheObjs(self.uid,false,'apply')
                local mUserwar = cobjs.getModel('userwar')
                local roundMax=getConfig("userWarCfg.roundMax")
                if mUserwar.apply_at>getWeeTs() and mUserwar.status<2 and (mUserwar.round1+mUserwar.round2)<roundMax then
                    self.feat[3]=1
                end
                
            end
            -- 检测是否参加军团战  只要没有结束 并且设置部队算一次
            if tid=="t12" then
                local uobjs = getUserObjs(self.uid)
                uobjs.load({"userinfo","hero","troops","areacrossinfo","useralliancewar"})
                local mUseralliancewar    = uobjs.getModel('useralliancewar') 
                local mUserinfo = uobjs.getModel('userinfo')
                if mUserinfo.alliance > 0 and mUseralliancewar.buff_at>getWeeTs() then
                    local mAllianceWar = require "model.alliancewarnew"
                    if not mAllianceWar.getOverBattleFlag(mUseralliancewar.bid) then
                        self.feat[3]=1
                    end
                end
            end
        end
        local hid  =self.feat[1]
        local push =push or false
        if task[1]==tid and params~=0 then
            -- 收集魂魄
            if tid=="t1" then
                if task[3]==params then
                    self.feat[3]=self.feat[3]+count
                    push=true
                end
            end
            -- t2携带该将领在16章及以后的关卡中获胜 params={'h1','h2'}
            -- t3携带此将领竞技场胜利n次;
            -- t4携带此将领击杀军团副本BOSS 
            -- t5携带此将领获得n军功
            -- t10:携带此将领攻打叛军X次 
            -- t13:携带此将领占领富矿X次
            -- t14:携带攻打60层以后神秘组织X次
            if tid=="t2" or tid=="t3" or tid=="t4" or tid=="t5" or tid=="t10"  or tid=="t13" or tid=="t14" then
                if type(params)=="table" and next(params) then
                    for k,v in pairs (params) do
                        if hid==v then
                            if tid=="t5" then
                                self.feat[3]=self.feat[3]+count
                                push=true
                            else
                                if task[3]==nil  or task[3]<=count then
                                    self.feat[3]=self.feat[3]+1
                                    push=true
                                end
                            end
                            break
                        end
                    end
                end
                
            end
            -- t6攻打n次补给线（包含扫荡）
            -- t7通过远征军关卡n次 
            -- t11:参与X次异元战场
            if tid=="t6" or tid=="t7" or tid=="t11" or tid=="t12" then
                self.feat[3]=self.feat[3]+count
                push=true
            end
            --t9:技能资质达到S 
            if tid=="t9" and hid==params then
                local qualLevel=self.heroQualLevel(apcount,heroFeatCfg.aptitude)
                if qualLevel>self.feat[3] then
                    self.feat[3]=qualLevel
                    push=true
                end
            end


        end
        --完成任务自动接受下一个
        if self.feat[3]>=task[2] then
            local newtask=heroFeatCfg.heroQuest[hid][cfgkey][self.feat[2]+1]
            if newtask~=nil then
                self.feat[2]=self.feat[2]+1
                self.feat[3]=0
                push=true
                if newtask[1]=="t12" or newtask[1]=="t11" then
                    return self.refreshFeat(newtask[1],0,0,push)
                end
            end
        end
        if push then
            regSendMsg(self.uid,"hero.feat",self.feat)
        end
    end

    function self.heroQualLevel(count,aptitude)
        local lvl=1
        if count<=0 then
            return lvl
        end
        for k,v in pairs(aptitude) do
            if count>=v then
                lvl=k
            end
        end
        return lvl
    end

    function self.changeExp(exp)
        local tmpexp=self.exp+math.floor( exp )
        if tmpexp >= 0 then
            self.exp = tmpexp
            return true
        end
        return false
    end

    -- 将领试炼获取任务列表
    function self.refreshAnnealList()
        local cfg = getConfig("heroAnnealCfg")

        -- 组建随机库{{0,0,0,0,100},{1,1,1,1,1,1},{"h1","h1"}}
        local taskPool = {{}, {}, {}}
        --随机任务个数
        for i=1, cfg.task.tasknum-1 do
            table.insert(taskPool[1], 0)
        end
        table.insert(taskPool[1], 100)

        local basepool = copyTable( cfg.task.basePool )
        for k, hidTab in pairs( cfg.task.advancePool[2] ) do --所有的将领库
            if type(self.hero[hidTab[1]]) == 'table' then
                table.insert(basepool[1], cfg.task.advancePool[1][k] )
                table.insert(basepool[2], cfg.task.advancePool[2][k] )
            end
        end

        local tmp = {{}, {}} --每个将领按照颜色分配任务
        for k, v in pairs( basepool[2] ) do
            for i, quality in pairs( cfg.task.quality[1] ) do
                table.insert(tmp[1], basepool[1][k] * cfg.task.quality[2][i] ) -- 权重
                table.insert(tmp[2], basepool[2][k][1] .. '_' .. quality) -- 任务id
            end
        end
        taskPool[2] = tmp[1]
        taskPool[3] = tmp[2]

        local task = getRewardByPool(taskPool)
        self.anneal.l = table.values(task) -- 任务列表

        return true
    end

    -- 更新任务信息
    function self.updateAnnealTask(killFlag, hp)
        if type(self.anneal.t) ~= 'table' then
            return false
        end

        if killFlag == 1 then
            self.anneal.t.stat = 2
        end
        self.anneal.t.hp = hp<0 and 0 or hp
    end

    -- 更新日志
    function self.updateAnnealLog(attName, rate, flag)
        local battlelogLib=require "lib.battlelog"
        local cfg = getConfig("heroAnnealCfg")
        local expireTs = self.anneal.t and self.anneal.t.expireTs or 0 
        local startTs = expireTs - cfg.survivalTime -- 过期时间 - 存活时间 = 任务开始时间 heroanneal初始化expireTs
        if startTs <= 0 then return false end

        battlelogLib:annealLogSend(self.uid, {attName, string.format("%0.4f", rate), getClientTs(), flag}, startTs, expireTs)
    end

    -- 增加友善值
    function self.addAnnealFly(addFly, overflow)
        addFly = math.floor(tonumber(addFly) or 0) 
        local weeTs = getWeeTs()
        if overflow and type(self.anneal.tfly) == 'table' and self.anneal.tfly[1] >= weeTs and (self.anneal.tfly[2] + addFly) > overflow then
            addFly = overflow - self.anneal.tfly[2]
        end
        if addFly > 0 then
            self.anneal.fly = (self.anneal.fly or 0) + addFly -- 增加友善度
            if overflow then -- 每天上限控制
                self.anneal.tfly = self.anneal.tfly or {0,0}
                if self.anneal.tfly[1] >= weeTs then -- 今天的累计               
                    self.anneal.tfly[2] = self.anneal.tfly[2] + addFly
                else -- 今天第一次清空
                    self.anneal.tfly[1] = weeTs
                    self.anneal.tfly[2] = addFly
                end
            end
        end

        return addFly
    end
    
    -- 获取日志
    function self.getAnnealLog()
        local battlelogLib=require "lib.battlelog"
        local cfg = getConfig("heroAnnealCfg")
        local startTs = (self.anneal.t and self.anneal.t.expireTs or 0 ) - cfg.survivalTime
        if startTs <= 0 then
            return {}
        end

        return battlelogLib:annealLogGet(self.uid, startTs)
    end

    -- 将领重生 将领星数不重置
    -- 参数 hid 将领编号 action 1 预览返还数据 2 直接重生
    -- 钻石等于：等级差×1+全部技能等级差×0.2+装备等级差×1+全部进阶等级差×2+全部精工等级差×2+保底20
    function self.rebirth(hid,action)
        local ret=1
        local r={}
      
        -- 判断将领是否存在
        if not self.checkHero(hid) then
            ret=-11002
            return ret,r
        end
        -- 判断将领是否在出征状态
        if not self.checkHeroStats(hid) then
            ret=-11030
            return ret,r
        end

        -- 检测将领是否在接受授勋任务
        if type(self.feat) =='table' and self.feat[1]==hid then
            ret = -11021
            return ret,r
        end

        --[[
        分解条件为：
        不在出征状
        将领等级不为1
        将领技能全部不为1
        将领装备等级全部不为1
        将领装备品质全部不为初始
        将领装备星级全部不为0
        ]]

        --hero  info  local hero = {1,0,0,{}}
        --1等级 2等级经验点数 3 品阶 4技能 5授勋技能 
        local flag=false
        -- 将领等级默认为1
        if self.hero[hid][1]>1 then flag=true end
        -- 将领技能 默认为1级
        if type(self.hero[hid][4])=='table' then
            for k,v in pairs(self.hero[hid][4]) do
                if v>1 then
                    flag=true
                    break
                end
            end
        end

        local uobjs = getUserObjs(self.uid)
        local mEquip= uobjs.getModel('equip')
        --装备 info hid  
        --1 等级 2 品阶 3星数 if type(mEquip.info[hid][pid])~='table' then mEquip.info[hid][pid]={1,1,0}  end
        if type(mEquip.info[hid])=='table' then 
            for k,v in pairs(mEquip.info[hid]) do
                if v[1]>1 or v[2]>1 or v[3]>0 then
                    flag=true
                    break
                end
            end
        end
     
        --条件判断
        if flag==false then
            ret=-30002
            return ret,r
        end

        local heroCfg = getConfig('heroListCfg.'..hid)
    
        local levediff=0
        -- 返还经物品
        local reward ={}--返回物品
        local heroexp=0
        -- 1.将领等级返还经验
        if self.hero[hid][1]>1 then
            heroexp=self.hero[hid][2]
            self.hero[hid][1]=1 --等级
            self.hero[hid][2]=0 --经验
            levediff=self.hero[hid][1]-1
        end

        -- 2.将领突破 不重置
        -- if self.hero[hid][3]>1 then
        --     local herolistCfg = getConfig('heroListCfg.'..hid)
            
        --     local ThrouhCfg=herolistCfg.throuh
        --     local thrnum=self.hero[hid][3]-1
        --     for i=1,thrnum do
        --         local tprops=ThrouhCfg[i].props
        --         local tsouls=ThrouhCfg[i].soul
        --         if type(tprops)=='table' and next(tprops) then
        --             for pk,pv in pairs(tprops) do
        --                 reward['props_'..pk]=(reward['props_'..pk] or 0)+pv
        --             end
        --         end

        --         if type(tsouls)=='table' and next(tsouls) then
        --             for sk,sv in pairs(tsouls) do
        --                 reward['hero_'..sk]=(reward['hero'..sk] or 0)+sv
        --             end
        --         end
        --     end
        --     self.hero[hid][3]=1------------------------------------------重置将领品质
        --     self.hero[hid][5]=nil------------------------------------------重置授勋技能
        -- end

       
        -- 3.技能升级消耗物品
        local skilllvdiff=0
        if type(self.hero[hid][4])=='table' then
            for k,v in pairs(self.hero[hid][4]) do
                if v>1 then
                    local heroSkillCfg=getConfig('heroSkillCfg.'..k)
                    local sklv=v-1
                    skilllvdiff=skilllvdiff+sklv
                    for i=1,sklv do
                        local props =heroSkillCfg.breach[i].props
                        for pk,pv in pairs(props) do
                            reward['props_'..pk]=(reward['props_'..pk] or 0)+pv
                        end
                    end

                end
            end
            -- 重置技能(装备精工的时候 将领的第一个技能编号会改变...需要重新读配置赋值)
            if next(heroCfg.skills) and type(self.hero[hid][4])=='table' then
                self.hero[hid][4]={}
                for k,v in pairs(heroCfg.skills) do
                   self.hero[hid][4][v[1]]=0
                   if k<=self.hero[hid][3] then
                       self.hero[hid][4][v[1]]=1
                   end
                end
            end
        end

        -- 4装备强化返还经验
        -- 5装备升品质
        -- 6装备升星
        --e1 配枪、军帽、军服、军靴消耗的经验
        --e2 挑战勋章经验
        --e3 战术书 经验
        local e={e1=0,e2=0,e3=0}
        local mpoint=0--竞技勋章
        local npoint=0--远征积分
        local eqlvdiff=0
        local eqjjdiff=0
        local eqstardiff=0
        if type(mEquip.info[hid])=='table' then 
            local equipCfg = getConfig('equipCfg')
            for k,v in pairs(mEquip.info[hid]) do
                --等级
                if v[1]>1 then
                    local elv=v[1]-1
                    eqlvdiff=eqlvdiff+elv
                    for i=1,elv do
                        for fk,fv in pairs(equipCfg[hid][k].grow.cost[i].f) do
                            e[fk]=e[fk]+fv
                        end
                    end
                end
                --品阶b
                if v[2]>1 then
                    local pj=v[2]-1
                    eqjjdiff=eqjjdiff+pj
                    for i=1,pj do
                        if k=='e5' then
                            --m 竞技勋章
                            --mUserarena.usePoint(resource.m)
                            for mk,mv in pairs(equipCfg[hid][k].upgrade.cost[i].m) do
                              mpoint=mpoint+mv
                            end     
                        elseif k=='e6' then
                            --n 远征积分
                            --mUserExpedition.usePoint(resource.n) 
                            for nk,nv in pairs(equipCfg[hid][k].upgrade.cost[i].n) do
                              npoint=npoint+nv
                            end
                        else
                            for pk,pv in pairs(equipCfg[hid][k].upgrade.cost[i].p) do
                                reward['props_'..pk]=(reward['props_'..pk] or 0)+pv
                            end
                        end
                    end
                end

                -- 星数
                if v[3]>0 then
                    local star=v[3]
                    eqstardiff=eqstardiff+star
                    for i=1,star do
                        for sk,sv in pairs(equipCfg[hid][k].awaken.cost[i].p) do
                          reward['props_'..sk]=(reward['props_'..sk] or 0)+sv
                        end                           
                    end
                end

                mEquip.info[hid][k]={1,1,0}
            end
        end

        -- ptb:p('返还将领经验='..heroexp)
        -- ptb:p('返还的道具、将魂')
        -- ptb:p(reward)
        -- ptb:p('返还的装备经验')
        -- ptb:p(e)
        -- ptb:p('返还的竞技勋章'..mpoint)
        -- ptb:p('返还的远征积分'..npoint)

        --计算需要消耗的钻石
        -- 钻石等于：等级差×1+全部技能等级差×0.2+装备等级差×1+全部进阶等级差×2+全部精工等级差×2+保底20
        local costGems=math.ceil(levediff+skilllvdiff*0.2+eqlvdiff+eqjjdiff*2+eqstardiff*2)
        local herorebirthCfg = getConfig('herorebirth')

        if costGems<herorebirthCfg.cost[1] then
            costGems=herorebirthCfg.cost[1]
        elseif costGems>herorebirthCfg.cost[2] then
            costGems=herorebirthCfg.cost[2]
        end
        
        -- 返还比例
        local ratio=herorebirthCfg.returnRate
        --需要替换的道具
        local specialItem=herorebirthCfg.serverreward.specialItem
        local r={}
        local newreward={}
        local zh=false
         
        if next(reward) and type(specialItem)=='table' and next(specialItem) then
            for k,v in pairs(reward) do
                for sk,sv in pairs(specialItem[1]) do
                    if k==sv[1] then
                        newreward[specialItem[2][sk][1]]=math.ceil(v*specialItem[2][sk][2]*ratio)
                    else
                        newreward[k]=math.ceil(v*ratio)
                    end
                end
            end
            zh=true
        end
        local clientprop={}
        if zh then
            for k,v in pairs(newreward) do
                table.insert(clientprop,formatReward({[k]=v}))
            end
        else
             for k,v in pairs(reward) do
                table.insert(clientprop,formatReward({[k]=v}))
            end
        end
     
        r.props=clientprop
        r.heroexp=math.ceil(heroexp*ratio)
        r.e1=math.ceil(e.e1*ratio)
        r.e2=math.ceil(e.e2*ratio)
        r.e3=math.ceil(e.e3*ratio)
        r.point1=math.ceil(mpoint*ratio)
        r.point2=math.ceil(npoint*ratio)
        r.costGems=costGems        

        -- 返还数据处理
        if action==2 then
            if not self.changeExp(r.heroexp) then
                ret=-403
                return ret,r
            end
          
            if zh then
                if not takeReward(uid,newreward) then
                    ret=-403
                    return ret,r
                end                
            else
                if not takeReward(uid,reward) then
                    ret=-403
                    return ret,r
                end            
            end
            for i=1,3 do
                mEquip.addResource('e'..i,r['e'..i])
            end
      

            local uobjs = getUserObjs(self.uid)
            if r.point1>0 then
                local mUserarena = uobjs.getModel('userarena')                
                mUserarena.addResource('point',r.point1)
            end

            if r.point2>0 then
                 local mUserExpedition = uobjs.getModel('userexpedition')
                 mUserExpedition.addResource('point',r.point2)
            end
        end

        return ret,r
    end

    -- 检测正在授勋的将领数据是否正确
    function self.checkfeat()
        if type(self.feat)=='table' and next(self.feat) then
            local hid = self.feat[1]
            if not self.hero[hid] then
                self.feat = {}
		return true
            end

            local heroFeatCfg = getConfig('heroFeatCfg')
            local levelLimit  = heroFeatCfg.levelLimit
            local fusionLimit = heroFeatCfg.fusionLimit
            local heroQuest   = heroFeatCfg.heroQuest
            if self.hero[hid][1]<levelLimit then
                self.feat = {}
            end
            if self.hero[hid][3]<fusionLimit then
                self.feat = {}
            end
            if heroQuest[hid]==nil or type(heroQuest[hid])~='table' then
               self.feat = {}
            end
        end
    end

    -- 删除将领去掉将领的状态
    function self.repairHerosStats(hid)
        if type(self.stats)=='table' then
            for k,v in pairs(self.stats) do
                if next(v) then
                    for k1,v1 in pairs (v) do
                        local del=0
                        for k2,v2 in pairs (v1) do
                            if v2==hid then
                                self.stats[k][k1][k2]=0 
                            end
                        end
                    end
                end
            end
        end    
    end

    return self
end
