function model_armor(uid,data)
    -- body
    local self = {
        uid=uid,
        info={},
        used={},
        free={},
        exp=0,
        count=getConfig("armorCfg.storeHouseNum"),
        buynum=0,
        props={},
        shopAt = 0, -- 最后一次商店兑换时间戳
        updated_at=0,
        
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

            regKfkLogs(self.uid,'armor',{
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



    --试用道具升级精炼等级
    function self.useProp(pid,nums)
        if type(self.props) == 'table'  then            
            local n = (tonumber(self.props[pid]) or 0) - tonumber(nums)
            --regActionLogs(self.uid,4,{action=5,item=pid,value=nums,params={c=n}})

            if n >= 0 then
                regKfkLogs(self.uid,'armor',{
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


    --获取是否能加装甲和碎片标示
    function self.getAddArmorFlag(anum)
        local flag = true
        local AMaxCount =self.count
        local Acount = self.getInfoCount()
        if Acount+anum> AMaxCount then
            flag=false
        end
        return flag
    end

    -- 获取背包装甲数量
    function self.getInfoCount()
        
        local count = 0
        if type(self.info)=='table' and next(self.info)then

             count=table.length(self.info)

        end
        if type(self.used)=="table" and next(self.used) then
            for k,v in pairs (self.used) do
                if  next(v) then
                    for ak,av  in pairs(v) do
                        if av~=0 then
                            count=count-1
                        end
                    end
                end
            end    
        end


       return count
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

    --删除背包中的装甲
    function self.delArmor(eid)
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
    --添加装甲 
    function self.addArmor(armor)  
        if  type(self.info)== 'table' then
            local iMaxCount =self.count
            local aCfg = getConfig("armorCfg.matrixList")
            if armor[1]==nil or type(aCfg[armor[1]]) ~='table' then
                return false
            end

            local iCurrCount = self.getInfoCount()
            local iAllCount = 1+iCurrCount
            local id = 0
            if (iAllCount) <= iMaxCount then
                  local eid = 'm'  
                  eid=eid..(self.getArmorIdKey()) 
                  id =eid
                  self.info[eid] = armor

                    regKfkLogs(self.uid,'armor',{
                            addition={
                                {desc="增加装甲",value=armor},
                                {desc="id",value=eid},
                            }
                        }
                    ) 

                    -- 矩阵收集活动
                    activity_setopt(self.uid,'armorCollect',{quality=aCfg[armor[1]].quality})

                    -- 德国七日狂欢
                    activity_setopt(self.uid,'sevendays',{act='sd6',v=0,n=1})
               
                  return true,id
            end

            return false,id
        end
    end

    --获取装甲在配置文件中的id
    function self.getArmorId(eid)
        local  id = nil
        local  access= nil
        if type(self.info[eid])=='table' then
            id=self.info[eid][1]
            access=self.info[eid]
        end
        return id,access
    end

    --生成装甲id
    function self.getArmorIdKey(n)
        n = n or 0
        local key = string.sub(os.time(),-6)
        local count = table.length(self.info) + n
        key = tonumber(key .. count) 
        local eid = 'a'..key
        if type(self.info[eid]) =='table' then
            n = n+1
            return self.getArmorIdKey(n)
        end
        return key
    end
    function self.getEqmtNums(eid)        
        return type(self.info) == 'table' and self.info[eid] or 0
    end


    --批量加装甲和碎片和零件和道具

    function self.addAllResource(add,count)
        local  flag = true
        local  result ={}
        local  addinfo   = {}
        if self[add]~=nil then
            self[add]=self[add]+count
            return flag
        else
            if type(add)~='table' then
                addinfo[tostring(add)]=tonumber(count)
            else
                addinfo=add
            end 
            if type(addinfo)=='table' and next(addinfo)then
                for key,val in pairs(addinfo)do
                    
                    local aret =string.find(key,'m')
                    
                    if aret ~=nil then
                        for i=1,tonumber(val) do
                            local ret,eid = self.addArmor({key,1})
                            if ret then
                                if type(result.info)~='table' then result.info={}end
                                result.info[eid]=self.info[eid]
                            else
                             return ret    
                            end
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
        end
        --ptb:e(result)
        return flag,result
    end

    -- 获取使用中的装备的属性
    function self.getUsedArmorAttribute()
        local attributes = {}        
        local att2name = {"attack","hp","accuracy","evade","crit","anticrit"}
        local cfg = getConfig("armorCfg")
        local techcfg=nil
        local armorCfg = cfg.matrixList    
        for k,v in pairs(self.used) do
            --local tankAttributes = {attack=0,hp=0,accuracy=0,evade=0,crit=0,anticrit=0}            
            local tankAttributes={attack=0,hp=0,accuracy=0,evade=0,crit=0,anticrit=0}
            local tmp={}
            for ak,av in pairs(v) do
                if av~=0  then
                    local pinfo=self.info[av]
                    for k,attType in ipairs(armorCfg[pinfo[1]].attType) do
                        local attType,attValue = tonumber(attType),0
                        tmp[armorCfg[pinfo[1]].quality] =(tmp[armorCfg[pinfo[1]].quality] or 0)+1
                        if cfg.attEffect[attType] == 1 then
                            attValue = (armorCfg[pinfo[1]].att[k] + armorCfg[pinfo[1]].lvGrow[k] * (pinfo[2]-1)  ) / 100
                        else
                            -- attEffect的只用到了1,注释掉，防止以后出现别的值后，下面的计算公式有问题
                            -- attValue = (armorCfg[pinfo[1]].att[k] + armorCfg[pinfo[1]].lvGrow[k] * (pinfo[2]-1) )/100 
                        end
                        
                        tankAttributes[att2name[attType]] =  (tankAttributes[att2name[attType]] or 0) + attValue 
                    end
                end
            end     
            --套装属性
            if next(tmp)  then
                local addrate=0
                for tk,tv in pairs(tmp) do
                    for k,v in pairs(cfg.matrixSuit) do
                        -- 颜色装甲
                        if tk==k then
                            for ac,av in pairs (v) do
                                if tv>=ac then 
                                    addrate=addrate+av
                                end
                            end
                        end
                    end
                end
                if addrate>0 then
                    for k,v in pairs (tankAttributes) do
                        tankAttributes[k]=v+addrate
                    end
                end
            end    
            attributes[k]=tankAttributes
        end
        return attributes
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
    function self.getUsedArmorFighting()
        local attributes = {}        
        local att2name = {"attack","hp","accuracy","evade","crit","anticrit"}
        local cfg = getConfig("armorCfg")
        local techcfg=nil
        local armorCfg = cfg.matrixList    
        local rate200={"accuracy","evade","crit","anticrit"}
        local rate100={"attack","hp"}
        for k,v in pairs(self.used) do
            local tankAttributes = {attack=0,hp=0,accuracy=0,evade=0,crit=0,anticrit=0}            
            --local tankAttributes={}
            local tmp={}
            for ak,av in pairs(v) do
                if av~=0  then
                    local pinfo=self.info[av]
                    for k,attType in ipairs(armorCfg[pinfo[1]].attType) do
                        local attType,attValue = tonumber(attType),0
                        tmp[armorCfg[pinfo[1]].quality] =(tmp[armorCfg[pinfo[1]].quality] or 0)+1
                        if cfg.attEffect[attType] == 1 then
                            attValue = (armorCfg[pinfo[1]].att[k] + armorCfg[pinfo[1]].lvGrow[k] * (pinfo[2]-1)  ) / 100
                        else
                            -- attValue = (armorCfg[pinfo[1]].att[k] + armorCfg[pinfo[1]].lvGrow[k] * (pinfo[2]-1) )/100 
                        end
                        
                        tankAttributes[att2name[attType]] =  (tankAttributes[att2name[attType]] or 0) + attValue 
                    end
                end
            end     
            --套装属性
            if next(tmp)  then
                local addrate=0
                for tk,tv in pairs(tmp) do
                    for k,v in pairs(cfg.matrixSuit) do
                        -- 颜色装甲
                        if tk==k then
                            for ac,av in pairs (v) do
                                if tv>=ac then 
                                    addrate=addrate+av
                                end
                            end
                        end
                    end
                end
                if addrate>0 then
                    for k,v in pairs (tankAttributes) do
                        tankAttributes[k]=v+addrate
                    end
                end
            end
            local power=0
            if next(tankAttributes) then
                for pk,pv in pairs (tankAttributes) do
                    if table.contains(rate200, pk) then
                        power=power+pv*200
                    end
                    if table.contains(rate100, pk) then
                        power=power+pv*100
                    end
                end
            end
            attributes[k]=power
        end
        return attributes
    end



    -- 检测装甲是不是最强的  
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

    -- 刷新免费抽奖次数

    function self.reffreecount(armorCfg)
        local ts = getClientTs()

        --free 数据结构修改 
        --free = {{普通抽奖}，{高级抽奖}，{普通首次抽奖标记(0/1)，高级抽奖次数(总累计值)} }
        if not next(self.free) then
            self.free={{},{},{0,0}}
        end
        for k,v in pairs (self.free) do
            if k > 2 then break end

            local maxcount=armorCfg['maxFreeNum'..k]
            local second =armorCfg['needFreeTime'..k]
            local time=v[1] or 0
            if (ts-time)>= second and (v[2] or 0)< maxcount then
                local tmpcount=math.floor((ts-time)/second)
                if tmpcount>0 then
                    if (v[2] or 0)+tmpcount>=maxcount then
                        v[2]=maxcount
                        v[1]=0
                    else
                        v[2]=(v[2] or 0) +tmpcount
                        v[1]=v[1]+tmpcount*second
                    end
                end
            end
        end

    end
    --设置时间
    function  self.reffreetime(method,maxcount)
        local ts = getClientTs()
        if self.free[method][2]<maxcount and  self.free[method][1]==0  then
            self.free[method][1]=ts
        end
    end

    -- 高级抽奖记录次数
    function self.incrAdvanceLotteryCnt(addCnt)
        if not next(self.free) then
            self.free={{},{},{0,0}}
        end
        -- {首次抽奖标记，高级抽奖次数}
        self.free[3][2] = (self.free[3][2] or 0) + (addCnt or 1) -- 高级抽奖次数

        return self.free[3][2]
    end


    -- 检测装甲是否在使用
    function self.checkUsed(mid,line)
        for k,v in pairs (self.used) do
            if  line~=k  and   next(v) then
                for ak,av  in pairs(v) do
                   if av==mid then
                       return true
                   end
                end
            end
        end
        return false
    end

    function self.addExp(exp)
        if exp > 0 then
            self.exp = self.exp + math.floor(exp)
        end
    end

    -- 使用经验
    function self.useExp(exp)
        if exp > 0 then
            exp = math.ceil(exp)
            if self.exp >= exp then
                self.exp = self.exp - exp
                return self.exp
            end
        end
    end

    function self.setShopAt()
        self.shopAt = os.time()
    end

    function self.checkShopCD()
        return os.time() > ( self.shopAt + getConfig("armorCfg").shopCD )
    end

    local function countUsedQuality(items)
        local tmp = {}
        local armorCfg = getConfig("armorCfg")
        for _,id in pairs(items) do
            if self.info[id] then
                local armorId = self.info[id][1]
                local quality = armorCfg.matrixList[armorId].quality
                tmp[quality] =(tmp[quality] or 0) + 1
            end
        end
        return tmp
    end

    -- 获取装甲等级清0，所需返回的经值值
    function self.getReturnExp(armorId)
        local addexp = 0
        if self.info[armorId] and next(self.info[armorId]) then
            local armorCfg = getConfig("armorCfg")
            local v = self.info[armorId]
            local maid=v[1]
            local lvl =v[2]
            local quality=armorCfg.matrixList[maid]['quality']
            local part=armorCfg.matrixList[maid]['part']
            for i=1,lvl do
                local needexp=armorCfg['upgradeResource'..quality][part][i]
                addexp=addexp+math.floor(needexp*armorCfg.resolveupgradeResource)
            end
        end
        return addexp
    end

    function self.getSetItemsTroopsAdd(items)
        local armorCfg = getConfig("armorCfg")
        local addrate=0
        local tmp = countUsedQuality(items)

        if next(tmp)  then
            for tk,tv in pairs(tmp) do
                for k,v in pairs(armorCfg.extraSuit) do
                    -- 颜色装甲
                    if tk==k then
                        for ac,av in pairs (v) do
                            if tv>=ac then 
                                addrate=addrate+av
                            end
                        end
                    end
                end
            end
        end

        return addrate
    end

    -- 获取套装加成值
    -- param table items 部位装备的所有装甲ID{"m47665018","m47665011" ... }
    function self.getSetItemsValue(items)
        local armorCfg = getConfig("armorCfg")
        local addrate=0
        local tmp = countUsedQuality(items)

        if next(tmp)  then
            for tk,tv in pairs(tmp) do
                for k,v in pairs(armorCfg.matrixSuit) do
                    -- 颜色装甲
                    if tk==k then
                        for ac,av in pairs (v) do
                            if tv>=ac then 
                                addrate=addrate+av
                            end
                        end
                    end
                end
            end
        end

        return addrate
    end

    --[[
        获取使用中的装甲总强度值
    ]]
    function self.getStrengthValue()
        local value = 0
        local armorCfg = getConfig("armorCfg")
        for _,v in pairs(self.used) do
            -- 套装属性加成
            local setItemsValue = self.getSetItemsValue(v)

            for _,id in pairs(v) do
                if id ~= 0 and self.info[id] then
                    local armorId = self.info[id][1]
                    local armorLv = self.info[id][2]

                    for k in ipairs(armorCfg.matrixList[armorId].attType) do
                        value = value + (armorCfg.matrixList[armorId].att[k] + armorCfg.matrixList[armorId].lvGrow[k] * (armorLv-1) ) * 18 * (1 + setItemsValue)
                    end
                end
            end
        end

        return value
    end

    -- 带兵量加成
    function self.getTroopsAdd()
        local value = 0
        for _,v in pairs(self.used) do
            value = value + self.getSetItemsTroopsAdd(v)
        end
        return value
    end

    --[[
        按品质统计数量
    ]]
    function self.usedQualityCount()
        local qualityCount = {0,0,0,0,0}
        local armorCfg = getConfig("armorCfg")
        for _,v in pairs(self.used) do
            for _,id in pairs(v) do
                if self.info[id] then
                    local armorId = self.info[id][1]
                    local quality = armorCfg.matrixList[armorId].quality
                    if qualityCount[quality] then
                        qualityCount[quality] = qualityCount[quality] + 1
                    end
                end
            end
        end
        return qualityCount
    end

    --[[
        邮件展示信息
    ]]
    function self.formatUsedInfoForBattle()
        return {self.getStrengthValue(),self.usedQualityCount()}
    end

    -- 获取成就数据
    -- ntype：1.数量 2.等级
    function self.getAchievementData(ntype,data)
        local num = 0
        local cfg = getConfig("armorCfg")
        local techcfg=nil
        local armorCfg = cfg.matrixList  
        for k,v in pairs(self.used) do
            for ak,av in pairs(v) do
                if av~=0 and self.info[av] and type(self.info[av])=="table" then
                    local pinfo=self.info[av]
                    if pinfo and pinfo[1] and armorCfg[pinfo[1]] then
                        if data.color and armorCfg[pinfo[1]].quality >= data.color then
                            if ntype == 1 then
                                num = num + 1
                            elseif ntype == 2 then
                                num = num + tonumber(pinfo[2] or 0)
                            end
                        end
                    end
                end
            end
        end
        return num
    end

    return self


end