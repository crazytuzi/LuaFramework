function model_accessory(uid,data)
    -- body
    local self = {
        uid=uid,
        info={},
        used={},
        m_level=1,
        m_exp=0,
        sinfo={},
        succ_at=0,
        fragment={},
        gt=0,--每日大师洗练次数
        hig=0,--每日高级洗练次数
        com=0,--每日基础洗练次数
        lt=0,--上次金币洗练的时间
        updated_at=0,
        props={},
    }



    local meta = {
            __index = function(tb, key)
                    return rawget(tb,tostring(key)) or rawget(tb,'a'..key) or 0
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


    function self.useAccessory(eid)
        if type(self.info) == 'table' and type (self.info[eid])=='table' and next(self.info[eid]) then            
                self.info[tostring(eid)] = nil
                return true
            
            end     
        return false
    end


    --使用配件坦克类型，配件，配件位置
    function self.addUsed(tanktype,accessory,position)
        local Ttype = 't'
        Ttype=Ttype..tanktype
        local Ptype = 'p'
        Ptype=Ptype..position

        --print(Ptype)
        --print(Ttype)
        local eid = 0
        if type(self.used) =='table' then
            if type(self.used[Ttype])~='table' then  self.used[Ttype]={} end

            --ptb:e(self.used[Ttype][Ptype])
            if type(self.used[Ttype][Ptype]) =='table' and next(self.used[Ttype][Ptype]) then
                -- "fuck"
                if self.used[Ttype][Ptype][5]==1 then
                    return false
                end
                local ret,id=self.addAccessory(self.used[Ttype][Ptype])
                eid=id
            end

            self.used[Ttype][Ptype]=accessory
            return true,eid
        end

         return false,eid

       
    end

    --获取试用中的配件 具体到哪种坦克和配件位置
    function self.getUsedAccessory(Ttype,Ptype)
        local acessory = {}
        local  Ttype =tostring(Ttype)
        local  Ptype =tostring(Ptype)
        if type(self.used) =='table' then
            if type(self.used[Ttype])=='table' then
                if type(self.used[Ttype][Ptype]) =='table' then 
                    acessory =self.used[Ttype][Ptype]  
                    end
            end
        end

        return acessory
        
    end
    --移除使用中的配件
    function self.removeUsedAccessory(Ttype,Ptype)
        local acessory = {}
        local  Ttype =tostring(Ttype)
        local  Ptype =tostring(Ptype)
        local  eid= 0
        if type(self.used) =='table' then
            if type(self.used[Ttype])=='table' then
                if type(self.used[Ttype][Ptype]) =='table' then
                        local ret,id=self.addAccessory(self.used[Ttype][Ptype])
                        eid=id 
                        acessory=self.used[Ttype][Ptype]
                        self.used[Ttype][Ptype]=nil
                        if not next(self.used[Ttype]) then
                            self.used[Ttype]=nil    
                        end
                    end
            end
        end

        return eid,acessory
        
    end


    --删除使用中的配件
     function self.delUsedAccessory(Ttype,Ptype)
        local acessory = {}
        local  Ttype =tostring(Ttype)
        local  Ptype =tostring(Ptype)
        local  eid= 0
        if type(self.used) =='table' then
            if type(self.used[Ttype])=='table' then
                if type(self.used[Ttype][Ptype]) =='table' then
                        self.used[Ttype][Ptype]=nil
                        if not next(self.used[Ttype]) then
                            self.used[Ttype]=nil    
                        end
                    end
            end
        end
 
    end

        --修改使用中的配件的强化等级和精炼等级
    function self.updateInFoAccessoryLevel(eid,level,refineLv) 

        
        local  eid =tostring(eid)
        local  level  = tonumber(level)
        local  refineLv  = tonumber(refineLv)
        local useAccessory = {}
        local ret = false
        if type(self.info) =='table' then

            if type(self.info[eid])=='table' then

                self.info[eid][2]=level
                if refineLv>0 then 
                     self.info[eid][3]=refineLv
                end
                ret=true
                useAccessory= self.info[eid]
                end     

        end

        return ret,useAccessory
    end
    --修改使用中的配件的强化等级和精炼等级
    function self.updateUsedAccessoryLevel(Ttype,Ptype,level,refineLv,succ,tech) 

        local  Ttype =tostring(Ttype)
        local  Ptype =tostring(Ptype)
        local  level  = tonumber(level)
        local  refineLv  = tonumber(refineLv)
        local  useAccessory = {}
        local  ret = false
        if type(self.used) =='table' then

            if type(self.used[Ttype])=='table' then
             
                if type(self.used[Ttype][Ptype]) =='table' then 
                    
                    self.used[Ttype][Ptype][2]=level
                    if refineLv>0 then 
                        self.used[Ttype][Ptype][3]=refineLv
                    end
                    if type(succ)=="table" and next(succ) and #succ==4 then
                        self.used[Ttype][Ptype][4]=succ
                    end
                    if type(tech)=="table" and next(tech) and #tech==2 and self.used[Ttype][Ptype][5]==1 then
                        self.used[Ttype][Ptype][6]=tech
                    end
                    ret=true
                    useAccessory= self.used[Ttype][Ptype]
                    end
            end
        end

        return ret,useAccessory
    end



    --修改背包中的配件的等级


    function self.updateAccessory(eid,accessory) 

         if  type(self.info)== 'table' then
            if type(self.info[eid]) =='table' then
                if type(accessory)=='table' then
                    accessory[2]= tonumber(accessory[2])
                    accessory[3]= tonumber(accessory[3])
                    self.info[eid]=accessory
                    return true
                end
                
            end

         end
         return false;
    end


    --添加某种碎片
    function self.addFragment(fid,nums)
        nums = math.floor(tonumber(nums) or 0)
       
        if nums > 0 and type(self.fragment)== 'table' then
             -- 配置文件
            --local cfg = getConfig('prop.' .. pid) 

            local iMaxCount = getConfig("accessory.fCapacity")
            local  count= self.getFragmentCount()
            if count>iMaxCount and self.fragment[fid]==nil  then
                return false
            end
            local aCfg = getConfig("accessory.fragmentCfg")
            --ptb:e(aCfg[accessory[1]])
            if  type(aCfg[fid]) ~='table' then
                --print('1111111111')
                return false
            end
            local iCurrCount = tonumber(self.fragment[fid]) or 0
            local iAllCount = nums + iCurrCount

            
           
            self.fragment[fid] = iAllCount

            regKfkLogs(self.uid,'accessory',{
                    item_id=fid,
                    item_op_cnt=nums,
                    item_before_op_cnt=iCurrCount,
                    item_after_op_cnt=iAllCount,
                    item_pos='碎片',
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
    end

    --减少碎片数量
    function self.useFragment(fid,nums)
        fid =tostring(fid)
        if type(self.fragment)=='table'  then  
            --ptb:p(self.fragment[fid])
            --print(tonumber(nums))          
            local n = (tonumber(self.fragment[fid]) or 0) - tonumber(nums)
            --regActionLogs(self.uid,4,{action=5,item=pid,value=nums,params={c=n}})
          
            if n>=0 then
                regKfkLogs(self.uid,'accessory',{
                        item_id=fid,
                        item_op_cnt=-nums,
                        item_before_op_cnt=self.fragment[fid],
                        item_after_op_cnt=n,
                        item_pos='碎片',
                        flags={'item_id'},
                        merge={'item_op_cnt'},
                        rewrite={'item_after_op_cnt'},
                        addition={
                        },
                    }
                )
            end

            if  n > 0 then
                self.fragment[fid] = n                
                return true
            elseif n == 0 then
                self.fragment[fid] = nil
                return true
            end 
        end  

        return false
    end


    --获取某种配件数量
    function self.getFragment(fid)
        local count = 0
        if type(self.fragment) == 'table' and self.fragment[fid] then            
            count=self.fragment[fid]
        end  
        return count
    end

    --添加单种道具
    function self.addProp(pid,nums)
        -- body
         nums = math.floor(tonumber(nums) or 0)
        
        if nums > 0 and type(self.props)== 'table' then
             -- 配置文件
            --local cfg = getConfig('prop.' .. pid) 

            --local iMaxCount = getConfig("accessory.fCapacity")
            local iCurrCount = tonumber(self.props[pid]) or 0
            local iAllCount = nums + iCurrCount

            regKfkLogs(self.uid,'accessory',{
                    item_id=pid,
                    item_op_cnt=nums,
                    item_before_op_cnt=iCurrCount,
                    item_after_op_cnt=iAllCount,
                    item_pos='材料',
                    flags={'item_id'},
                    merge={'item_op_cnt'},
                    rewrite={'item_after_op_cnt'},
                    addition={
                    },
                }
            )
                         
            self.props[pid] = iAllCount
            
           

            return true
        end

        return false

    end


    --admin修改材料

    function  self.setProp(pid,nums)

        nums =tonumber(nums)
        if type(self.props) == 'table'  then 
            if nums<=0 then
                self.props[pid]=nil

            else

                 self.props[pid]=nums
            end
       -- if 

       end

    end


    function self.setFragment(fid,nums)
        nums =tonumber(nums)
        if type(self.fragment) == 'table'  then 
            if nums<=0 then
                self.fragment[fid]=nil

            else

                 self.fragment[fid]=nums
            end
       -- if 

       end
        -- body
    end

    --试用道具升级精炼等级
    function self.useProp(pid,nums)
        if type(self.props) == 'table'  then            
            local n = (tonumber(self.props[pid]) or 0) - tonumber(nums)
            --regActionLogs(self.uid,4,{action=5,item=pid,value=nums,params={c=n}})

            if n >= 0 then
                regKfkLogs(self.uid,'accessory',{
                        item_id=pid,
                        item_op_cnt=-nums,
                        item_before_op_cnt=self.props[pid],
                        item_after_op_cnt=n,
                        item_pos='材料',
                        flags={'item_id'},
                        merge={'item_op_cnt'},
                        rewrite={'item_after_op_cnt'},
                        addition={
                        },
                    }
                )
            end

            if  n > 0 then
                self.props[tostring(pid)] = n                
                return true
            elseif n == 0 then
                self.props[tostring(pid)] = nil
                return true
            end 
        end  

        return false
    end


    -- 使用多个道具

    function self.useProps(props)
        for k,v in pairs (props) do
            local ret =self.useProp(k,v)
            if not ret then
                return false
            end
        end

        return true
    end


    --获取是否能加配件和碎片标示
    function self.getAddAccessoryFlag(anum,fnum)
        local flag = true
        local FMaxCount = getConfig("accessory.fCapacity")
        local Fcount = self.getFragmentCount()
        local AMaxCount = getConfig("accessory.aCapacity")
        local Acount = self.getInfoCount()
        if Fcount+fnum>FMaxCount then
            flag=false
        end

        if Acount+anum> AMaxCount then
            flag=false
        end
        return flag
    end

    -- 获取背包配件数量
    function self.getInfoCount()
        
        local count = 0
        if type(self.info)=='table' and next(self.info)then

             count=table.length(self.info)

        end

       return count
    end
    --获取不同碎片所占的位置数
    function self.getFragmentCount()
        
        local count = 0
        if type(self.fragment)=='table' and next(self.fragment)then

            count=table.length(self.fragment)
        end

       return count
    end


    -- 获取配件和碎片剩余位置数

    function self.getAandFCount()
        local FMaxCount = getConfig("accessory.fCapacity")
        local AMaxCount = getConfig("accessory.aCapacity")
        -- print(FMaxCount)
        -- print(AMaxCount)
        -- body
        FMaxCount =FMaxCount-table.length(self.fragment)
        AMaxCount =AMaxCount-table.length(self.info)  
        return AMaxCount,FMaxCount
    end

    --批量添加道具
    function self.addProps(props)

        if type(props) =='table' then

            for k,v in pairs(props)do
                self.addProp(k,v)
            end
            return true
        end
        -- body
        return false
    end

    --删除背包中的配件
    function self.delAccessory(eid)
        -- body
        if type(self.info)=='table' then

            if type(self.info[eid])=='table' and next(self.info[eid]) then

                self.info[eid]=nil
                return true
            end
        end
        return false
    end
    --获取某种道具数量
    function self.getPropCount(pid)
        local count = 0
        if type(self.props) == 'table' and self.props[pid] then            
            count=self.props[pid]
        end  
        return count
    end
    --添加配件 
    function self.addAccessory(accessory)
        --nums = math.floor(tonumber(nums) or 0)
        
        if  type(self.info)== 'table' then
             -- 配置文件
            --local cfg = getConfig("accessory.aCapacity")
            --ptb:p(cfg)
            local iMaxCount = getConfig("accessory.aCapacity")
            local aCfg = getConfig("accessory.aCfg")
            --ptb:e(aCfg[accessory[1]])
            if accessory[1]==nil or type(aCfg[accessory[1]]) ~='table' then
                --print('1111111111')
                return false
            end

            local iCurrCount = self.getInfoCount()
            local iAllCount = 1+iCurrCount
            local id = 0
            if (iAllCount) <= iMaxCount then
                  local eid = 'a'  
                  eid=eid..(self.getAccessoryIdKey()) 
                  id =eid
                  self.info[eid] = accessory

                    regKfkLogs(uid,'accessory',{
                            addition={
                                {desc="增加配件",value=accessory},
                                {desc="id",value=eid},
                            }
                        }
                    ) 

                  -- stats ---------------------------------------
                  regStats('accessory_daily',{item= 'produceAnum.' .. (accessory[1] or ''),num=1})
                  -- stats ---------------------------------------

                  return true,id
            end

            return false,id
        end
    end

    --获取配件在配置文件中的id
    function self.getAccessoryId(eid)
        local  id = nil
        local  access= nil
        if type(self.info[eid])=='table' then
            id=self.info[eid][1]
            access=self.info[eid]
        end
        return id,access
    end

    --生成配件id
    function self.getAccessoryIdKey()
        local key = string.sub(os.time(),-6)
        local count = table.length(self.info)
        key = tonumber(key .. count)
        local eid = 'a'..key
        if type(self.info[eid]) =='table' then
            self.getAccessoryIdKey()
        end
        return key
    end
    function self.getEqmtNums(eid)        
        return type(self.info) == 'table' and self.info[eid] or 0
    end


    --批量加配件和碎片和零件和道具

    function self.addAllResource(add,count)
        local  flag = true
        local  result ={}
        local  addinfo   = {}
        if type(add)~='table' then
            addinfo[tostring(add)]=tonumber(count)
        else
            addinfo=add
        end 
       -- ptb:p(addinfo)
        if type(addinfo)=='table' and next(addinfo)then
            for key,val in pairs(addinfo)do
                
                local aret =string.find(key,'a')
                
                if aret ~=nil then
                    for i=1,tonumber(val) do
                        local ret,eid = self.addAccessory({key,0,0})
                        if ret then
                            if type(result.info)~='table' then result.info={}end
                            result.info[eid]=self.info[eid]
                        else
                         return ret        
                        end
                    end
                end

                local fret =string.find(key,'f')
                if fret ~=nil then
                    local  ret = self.addFragment(key,tonumber(val))
                    if ret then
                        if type(result.fragment)~='table' then result.fragment={}end
                        result.fragment[key]=val
                    else 
                     return ret        
                    end

                end

                local pret = string.find(key,'p')
                if pret~=nil then
                    local  ret = self.addProp(key,tonumber(val))
                    if ret then
                        if type(result.props)~='table' then result.props={}end
                        result.props[key]=val
                    else
                     return ret    
                    end
                end

            end

        end

        --ptb:e(result)
        return flag,result
    end

    -- 获取使用中的装备的属性
    function self.getUsedAccessoryAttribute()
        local attributes = {}        
        local att2name = {"attack","hp","armor","arp"}
        local att4name = {"attack","hp","arp","armor"}
        local cfg = getConfig("accessory")
        local techcfg=nil
        local accessoryCfg = cfg.aCfg
        local bounsAtt=getConfig("succinctCfg.bounsAtt")
        local addtankAttributes={}
        local askill={}
        local att3name = {attack=100,hp=108,armor=201,arp=202}
        local addname = {[211]=211,[212]=212,[213]=213,[214]=214,[221]=221,
        [222]=222,[223]=223,[224]=224,
        }
        local addname1 = {[102]="accuracy",
        [103]="evade",[104]="crit",[105]="anticrit",[110]="critDmg",[111]="decritDmg"
        }
        for k,v in pairs(self.used) do
            local tankAttributes = {attack=0,hp=0,armor=0,arp=0}            
            local tankaddbutes={}
            local techpoint={}
            for pname,pinfo in pairs(v) do
                -- local aid,enhancedLv,refineLv = pinfo[1],pinfo[2],pinfo[3] -- id,强化等级，精炼等级
                local succ={}  
                if pinfo[1] and accessoryCfg[pinfo[1]] then
                    if pinfo[4]~=nil then succ=pinfo[4] end
                    -- attType:配件是哪种效果  1:attack 2:hp 3:armor 4:arp
                    local addvalue={}
                    for k,attType in ipairs(accessoryCfg[pinfo[1]].attType) do
                        local attType,attValue = tonumber(attType),0

                        if cfg.attEffect[attType] == 1 then
                            attValue = (accessoryCfg[pinfo[1]].att[k] + accessoryCfg[pinfo[1]].lvGrow[k] * pinfo[2] + accessoryCfg[pinfo[1]].rankGrow[k] * pinfo[3] ) / 100
                        else
                            attValue = accessoryCfg[pinfo[1]].att[k] + accessoryCfg[pinfo[1]].lvGrow[k] * pinfo[2]  + accessoryCfg[pinfo[1]].rankGrow[k] * pinfo[3]
                        end
                        
                        tankAttributes[att2name[attType]] =  tankAttributes[att2name[attType]] + attValue

                        if succ[attType]~=nil then
                            tankAttributes[att4name[attType]]=tankAttributes[att4name[attType]] + tonumber(succ[attType])
                            table.insert(addvalue,attType)
                        end    
                end
                -- 绑定加成
                if pinfo[5]==1 then
                    for k,attType in ipairs(accessoryCfg[pinfo[1]].btype or {}) do
                        if cfg.attEffect[attType] == 1 then
                            attValue = (accessoryCfg[pinfo[1]].bValue[k]  ) / 100
                        else
                            attValue = accessoryCfg[pinfo[1]].bValue[k]
                        end
                        tankAttributes[att2name[attType]] =  tankAttributes[att2name[attType]] + attValue
                    end
                end
                -- 科技加成
                if type(pinfo[6])=='table' and next(pinfo[6]) then
                    if techcfg==nil then
                        techcfg=getConfig("accessorytech")
                    end
                    local t=k
                    local sid=pinfo[6][1]
                    local level=pinfo[6][2]

                    local techconfig=techcfg.tankType[t][sid].ability[level]
                    techpoint[sid]=(techpoint[sid] or 0)+(techconfig.addTechValue or 0)
                    for sk,attType in ipairs(techconfig.attType or {}) do
                        if cfg.attEffect[attType] == 1 then
                            attValue = (techconfig.value[sk]  ) / 100
                        else
                            attValue = techconfig.value[sk]
                        end
                        tankAttributes[att2name[attType]] =  tankAttributes[att2name[attType]] + attValue
                    end
                    
                end

                -- 洗练剩余的加成
                if next(succ) then
                        local refineId=accessoryCfg[pinfo[1]].refineId
                        for ak,av in pairs(succ) do
                            local flag=table.contains(addvalue,ak)
                            if not flag then
                                tankAttributes[att4name[ak]]=tankAttributes[att4name[ak]] + tonumber(succ[ak])
                            end
                            -- 大于n值 额外的加成
                            if refineId >0 then
                                for rk,rv in pairs (bounsAtt[refineId]) do
                                    if rv[1][att3name[att4name[ak]]]~=nil then
                                        if av >= rv[1][att3name[att4name[ak]]] then
                                            for addk,addv in pairs(rv[2]) do
                                                local addtype =addname[addk]
                                                if addtype~=nil then
                                                    tankaddbutes[tostring(addtype)]=(tankaddbutes[tostring(addtype)] or 0) +addv
                                                end 
                                                local addtype =addname1[addk]
                                                if addtype~=nil then
                                                    tankAttributes[tostring(addtype)]=(tankAttributes[tostring(addtype)] or 0) +addv
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end   
                end
                
               
            end      
             -- 科技以后的附加技能
             -- -- TEST
             -- techpoint={200,200,200,200}
            if next(techpoint) then
                for tk,tv in pairs (techpoint) do
                    local level=0
                    for lk,lv in pairs(techcfg.lvNeed) do
                        if tv>=lv then
                            level=lk
                        end
                    end
                    if level>0 then
                        if type(askill[k])~='table' then askill[k]={} end
                        local aid =techcfg.techSkill[k][tk]
                        if aid~=nil then
                            askill[k][techcfg.techSkill[k][tk]]=level
                        end
                    end
                end

            end     
            attributes[k] = tankAttributes
            if next(tankaddbutes) then
                addtankAttributes[k]=tankaddbutes
            end
            
        end
        
        for k,v in pairs(attributes) do
            if v.decritDmg~=nil  then
                attributes[k].decritDmg=v.decritDmg/100
            end

            if  v.critDmg~=nil then
                attributes[k].critDmg=v.critDmg/100
            end
        end
        return attributes,addtankAttributes,askill
    end

    
    -- 获取使用中的装备的战力分值
    -- 装备对应战力分值
    -- p1 部位
    -- p1.1 强化对应的四种品质基础值
    -- p1.2 精炼对应的四种品质基础值
    -- 公式 (1+强化等级) * 装备强化系数 + 精炼等级 * 装备精炼系数
    -- fightingValue = {
    --     p1 = {{8,10,12,14},{60,80,100,120}},
    --     p2 = {{8,10,12,14},{60,80,100,120}},
    --     p3 = {{12,15,18,21},{90,120,150,180}},
    --     p4 = {{12,15,18,21},{90,120,150,180}},
    -- }
    function self.getUsedAccessoryFighting()
        local cfg = getConfig("accessory")
        local accessoryCfg = cfg.aCfg
        local fightValueCfg = cfg.fightingValue
        local fightingValue = 0
        local qualityCount = {0,0,0,0}
        -- 红色配件开关
        if moduleIsEnabled('ra') == 1 then
            table.insert(qualityCount,0)
        end
        for k,v in pairs(self.used) do
            for pname,pinfo in pairs(v) do
                local quality = tonumber(accessoryCfg[pinfo[1]].quality)
                if quality and qualityCount[quality] then   
                    qualityCount[quality] = (qualityCount[quality] or 0) + 1

                    fightingValue = fightingValue + (1 + pinfo[2]) * fightValueCfg[pname][1][quality] + pinfo[3] * fightValueCfg[pname][2][quality]
                end
                if type(pinfo[4])=="table"  and next(pinfo[4]) then
                    local rpoint=0
                    for k,v in pairs(pinfo[4]) do
                        if k>2 then
                            rpoint=rpoint+v*20
                        else
                            rpoint=rpoint+v*800
                        end
                    end
                    fightingValue=fightingValue+math.floor(rpoint)
                end
                if pinfo[5]==1 then
                    fightingValue=fightingValue+fightValueCfg[pname][3]
                end 
            end
        end
        
        return {fightingValue, qualityCount}
    end

    --setmetatable(self.info, meta)

    -- 工程师加经验升级
    function self.addexp(addexp,engineerExp,engineerLvLimit)
        self.m_exp=self.m_exp+addexp
        local maxlevel=#engineerExp
        if self.m_exp> engineerExp[maxlevel] then
            self.m_exp=engineerExp[maxlevel]
        end
        if (self.m_exp>engineerExp[self.m_level+1]) then
            for k,v in pairs(engineerExp) do
                if self.m_exp>=v then
                    self.m_level=k
                end
            end
        end
        if self.m_level>engineerLvLimit then
            self.m_level=engineerLvLimit
            self.m_exp=engineerExp[self.m_level+1]
        end
    end

    -- 检测配件是不是最强的  
    function self.checkaccessory(accessoryconfig,acfg,qlevel,glevel)
        local flag=false
        if type(self.info)=='table'  and next(self.info) then
            for k,v in pairs (acfg) do
                if v.tankID==accessoryconfig.tankID  and  v.part==accessoryconfig.part  and v.quality>=accessoryconfig.quality  then
                    for ak,av in pairs (self.info) do
                        if av[1]==v.aid then
                            if acfg[av[1]].quality>accessoryconfig.quality then
                                return true
                            else
                                if (av[2]+av[3]*10)>(qlevel+glevel*10) then
                                    return true
                                end
                            end

                        end
                    end
                end
            end
        end    
        return flag
    end

    return self


end