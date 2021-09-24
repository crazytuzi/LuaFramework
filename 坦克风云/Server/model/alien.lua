-- 异星科技
function model_alien(uid,data)
    local self = {
        uid = uid,
        info={},
        used ={},
        used1= {},
        prop={},
        pinfo={},
        shop={}, --商店信息
        mine_at=0,
        m_count=0,
        updated_at = 0,
    }
    
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

        if type(self.info) ~= "table" then self.info = {} end
        if type(self.used) ~= "table" then self.used = {} end
        if type(self.prop) ~= "table" then self.prop = {} end
        if type(self.pinfo) ~= "table" then self.pinfo = {} end
        if type(self.used1) ~= "table" then self.used1 = {} end
        if type(self.shop) ~= 'table' then self.shop = {} end

        return true
    end

    function self.toArray(format)
        local data = {}
        for k,v in pairs (self) do
            if type(v)~="function" and k~= 'uid' and k~= 'updated_at' then              
                if format then
                    if type(v) == 'table'  then
                        data[k] = v
                        -- if next(v) then data[k] = v end
                    elseif v ~= 0 and v~= '0' and v~='' then
                        data[k] = v
                    end
                else
                    data[k] = v
                end
            end
        end

        return data
    end

 

    -- 修改技能等级
    function self.upgradeLevel(sid)
        self.info[sid] = self.info[sid] and (self.info[sid]+1) or 1

        local alienTechCfg = getConfig("alienTechCfg.talent." .. sid)
        if alienTechCfg[14] then -- 刷新科技树属性
            self.refreshTechTreeAttr( alienTechCfg[14] )
        end
        return true
    end

    --  添加所有的技能
    function self.addALLTechs()
        local alienTechCfg = getConfig("alienTechCfg.talent")
        for k,v in pairs(alienTechCfg) do
            self.upgradeLevel(k)
            -- if v[3]==2 then
            --     self.useTech(v[5][1],k)
            --     self.info[k]=1
            -- end
        end
    end

    -- 异星矿场设置采集数量
    function self.setMineCount(count)
        -- body
        if count>0 then
            local ts    = getClientTs()
            local weeTs = getWeeTs()
            if self.mine_at<weeTs then
                self.m_count=0
            end
            self.m_count=self.m_count+count
            self.mine_at=ts
        end
    end

    -- 获取排行榜


    -- 坦克装配技能
    -- function self.updateTankAlien(tank,oid,nid)
    --     local flag =false
    --     if self.used then
    --         for k,v in pairs (self.used) do
    --             if v==oid then
    --                 self.used[k]=nid
    --                 flag=true
    --                 break
    --             end
    --         end
    --     end
    --     return flag
    -- end


    -- 获取一组科技的总等级
    function self.getMoreTechLevel(techs)
        local level = 0
        if type(techs)=='table' and next(techs) then
             for k,v in pairs(techs) do
                level=level+ (self.info[v] or 0)
             end
        end
 
        return level
    end

    -- 检测技能的等级
    function self.checkTechLevel(techs)
        local flag =true   
        for k,v in pairs(techs) do
            local level =self.info[k] or 0
            if level<v then
                flag=false
                break
            end
        end
        return flag
    end

    --使用固定类技能
    -- function self.useTech(tank,sid)
    --     if type(self.used[tank])~='table' then  self.used[tank]={} end

    --     local flag=table.contains(self.used[tank], sid)
    --     if not flag then
    --         table.insert(self.used[tank],sid)
    --     end
            
    -- end
    
    -- 获取坦克现有已解锁解最大位置 （去除固定类的）
    -- function self.getOpenSolt(tank,alienCfg,tankCfg)
    --     local len=0
    --     local fixed=0
    --     if type(self.used[tank])~='table' then self.used[tank]={} end
    --     len =#self.used[tank]
    --     for k,v in pairs(self.used[tank]) do
    --             -- 是固定类的-1
    --             if v ~=0 then
    --                 if alienCfg[v][3]==2 then
    --                     fixed=fixed+1
    --                     len=len-1
    --                 end
    --             end
    --         end
    --     if len<tankCfg.alienSlot[1] then
    --         len=tankCfg.alienSlot[1]
    --     end
    --     return len+fixed,len
    -- end

    -- 获取坦克现有多少个解锁位置 (去除固定类的）
    -- function self.getUnlockOpenSolt(tank,alienCfg,tankCfg)
    --     local len=0
    --     local fixed=0
    --     if type(self.used[tank])~='table' then self.used[tank]={} end

    --     len =#self.used[tank]
    --     if len>0 then
    --         for k,v in pairs(self.used[tank]) do
    --             -- 是固定类的-1
    --             if v ~=0 then
    --                 if alienCfg[v][3]==2 then
    --                     fixed=fixed+1
    --                     len=len-1
    --                 end
    --             end
    --         end
    --     end
    --     if len<tankCfg.alienSlot[1] then
    --         len=tankCfg.alienSlot[1]
    --     end
    --     return len,fixed
    -- end


    -- 检测该坦克是否已经装了该科技
    -- function self.checkTalentType(tank,talentType,alienCfg,p)
    --     local flag=true
    --     if type(self.used[tank])=='table' and next(self.used[tank]) then
    --         for k,v in pairs(self.used[tank]) do
    --             if v~=0  then 
    --                 if alienCfg[v][4]==talentType and k~=p then
    --                     flag=false
    --                 end
    --             end
    --         end
    --     end

    --     return flag
    -- end


    -- 使用科技到坦克身上
    -- function self.updateUsed(tank,sid,p,slen)
    --     if type(self.used[tank]) ~='table' then  self.used[tank]={} end
    --     local len =#self.used[tank]
    --     if slen> len then
    --         for i=1,slen-len do
    --             table.insert(self.used[tank],0)
    --         end
    --     end
    --     self.used[tank][p]=sid
    --     return true
    -- end

    -- 科技自动生效在tank上
    function self.autoUpdateUsed(tank, sid)
        if type(self.used[tank]) ~='table' then self.used[tank]={} end
        local flag=table.contains(self.used[tank], sid)
        if not flag then
            table.insert(self.used[tank],sid)
        end
        return true
    end

    function self.autoAppendTech(sid)
        local alienCfg=getConfig("alienTechCfg.talent." .. sid)
        if not alienCfg then return false end

        if type( alienCfg[5] ) == 'string' then
            self.autoUpdateUsed(alienCfg[5], sid)
        elseif type( alienCfg[5] ) == 'table' then
            for k, v in pairs( alienCfg[5] ) do
                self.autoUpdateUsed(v, sid)
            end
        end

        return true
    end

    -- 购买卡槽
    -- function self.addTankSolt(tank,tlen,nlen)
    --     if type(self.used[tank]) ~='table' then  self.used[tank]={} end
    --     local len=#self.used[tank]
    --     if len < tlen then
    --         for i=1,tlen-len do
    --             table.insert(self.used[tank],0)
    --         end
    --     end
    --     return true
    -- end

    --  获取坦克固定类的加速时间
    function self.getTankSpeedTime(tank)
        local time =0
        local alienCfg=getConfig("alienTechCfg.talent")
        if type (self.used[tank])=='table' and next(self.used[tank]) then
            -- 是固定类的
            for k,v in pairs(self.used[tank]) do
                if v ~=0 and v~=-1 then
                    if alienCfg[v][3]==2 then
                        local level = self.info[v] or 0
                        if level >0 then
                            for k,v in pairs(alienCfg[v][9][level]) do
                                -- 生产或者改造的时候减少的时间
                                if k==200 then
                                    time=time+v
                                end
                            end
                        end
                        
                    end
                end
            end
        end
        return time
      end  

    function self.getAttrValueByTank(tankId)
        local addValue = {}
        local alienTechCfg = getConfig("alienTechCfg")
        local alienCfg= alienTechCfg.talent
        local resetAttrName = {[102]='accuracy',[103]='evade',[104]='crit',[105]='anticrit',[110]='critDmg',[111]='decritDmg',}

        if self.used[tankId] then
            for _,tech in ipairs(self.used[tankId]) do
                if tech ~=0 and tech~=-1 and alienCfg[tech] and alienCfg[tech][9][self.info[tech]] then
                    for attrName,attrVal in pairs(alienCfg[tech][9][self.info[tech]]) do
                        if resetAttrName[attrName] then
                            addValue[attrName] = attrVal/100
                        else
                            addValue[attrName] = attrVal
                        end
                    end
                end
            end
        end
        
        -- 新增科技树属性
        local addValue1 = {}
        if self.used1[tankId] then
            for id, levelTab in pairs( self.used1[tankId] ) do
                for _, level in pairs( levelTab ) do
                    id = tonumber(id)
                    if alienTechCfg.subtree[id].attr[level] then
                        for attrName,attrVal in pairs(alienTechCfg.subtree[id].attr[level]) do
                            if resetAttrName[attrName] then
                                addValue1[attrName] = (addValue1[attrName] or 0) + attrVal/100
                            else
                                addValue1[attrName] = (addValue1[attrName] or 0) + attrVal
                            end
                        end                    
                    end
                end
            end
        end

        return addValue, addValue1
    end

    function self.getAttrValueByTroops(troops)
        local addValue, addValue1 = {}, {}

        for k,v in pairs(troops) do
            if v[1] then
                if not addValue[v[1]] then addValue[v[1]] = {} end
                local tmpAttValue, tmpAttValue1 = self.getAttrValueByTank(v[1])
                for attrName,attrVal in pairs(tmpAttValue) do
                    addValue[v[1]][attrName] = attrVal
                end

                if not addValue1[v[1]] then addValue1[v[1]] = {} end
                for attrName,attrVal in pairs(tmpAttValue1) do
                    addValue1[v[1]][attrName] = attrVal
                end
            end
        end
        
        return addValue, addValue1
    end

     --添加单种道具
    function self.addProp(pid,nums)
        -- body
        nums = math.floor(tonumber(nums) or 0)
        
        if nums > 0 and type(self.prop)== 'table' then
             -- 配置文件
            --local cfg = getConfig('prop.' .. pid) 

            --local iMaxCount = getConfig("accessory.fCapacity")

            local iCurrCount = tonumber(self.prop[pid]) or 0
            local iAllCount = nums + iCurrCount

                         
            self.prop[pid] = iAllCount
            
            
            if type(self.pinfo)~='table' then  self.pinfo={} end

            local piCurrCount = tonumber(self.pinfo[pid]) or 0
            local piAllCount = nums + piCurrCount
            self.pinfo[pid]=piAllCount
            return true
        end

        return false

    end

    --添加单种道具
    function self.addMineProp(pid,nums)
        -- body
        nums = math.floor(tonumber(nums) or 0)
        
        if nums > 0 and type(self.prop)== 'table' then
             -- 配置文件
            --local cfg = getConfig('prop.' .. pid) 

            --local iMaxCount = getConfig("accessory.fCapacity")

            local iCurrCount = tonumber(self.prop[pid]) or 0
            local iAllCount = nums + iCurrCount

                         
            self.prop[pid] = iAllCount
            
            return true
        end

        return false

    end

    -- 获取今天加了多少粉尘
    function self.getDayadd(pid)
        local piCurrCount = tonumber(self.pinfo[pid]) or 0
        local ts=self.pinfo['ts'] or 0
        local weeTs = getWeeTs()
        if ts~=weeTs then
            self.pinfo={}
            self.pinfo['ts']=weeTs
            piCurrCount=0
        end
        return piCurrCount
        -- body
    end


    --使用道具升级精炼等级
    function self.useProp(pid,nums)
        if type(self.prop) == 'table'  then            
            local n = (tonumber(self.prop[pid]) or 0) - tonumber(nums)
            --regActionLogs(self.uid,4,{action=5,item=pid,value=nums,params={c=n}})
            if  n > 0 then
                self.prop[tostring(pid)] = n                
                return true
            elseif n == 0 then
                self.prop[tostring(pid)] = nil
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

    -- 科技树技能 
    function self.refreshTechTreeAttr(subtreeid)
        -- 科技子树中的总点数
        local alienTechCfg = getConfig("alienTechCfg")
        local allpoint = 0 --该科技树总点数
        for _, v in pairs( alienTechCfg.subtree[ subtreeid ].tech ) do 
            if self.info[v] and tonumber(self.info[v]) > 0 then
                allpoint = allpoint + tonumber(self.info[v])
            end
        end

        local level = 0 --获取属性等级
        for k, v in pairs( alienTechCfg.subtree[ subtreeid ].point ) do  
            if allpoint >= v then
                level = k
            else
                break
            end 
        end

        -- 对生效的tank 存起来
        if level > 0 then
            for _, tankId in pairs( alienTechCfg.subtree[ subtreeid ].desc[level] ) do
                self.used1[tankId] = self.used1[tankId] or {}
                if type(self.used1[tankId][ tostring(subtreeid)]) ~= 'table' then
                    self.used1[tankId][ tostring(subtreeid)] = {}
                end
                if not arrayIndex( self.used1[tankId][tostring(subtreeid)], level ) then
                    table.insert(self.used1[tankId][tostring(subtreeid)], level)
                end

            end
        end

    end

    -- 商店刷新处理（定时刷新 ，手动刷新）
    function self.refreshAlienShop()
        local uobjs = getUserObjs(self.uid)
        local mUserinfo = uobjs.getModel('userinfo')

        local alienShopCfg = getConfig("alienShopCfg")
        local rewardCfg = nil -- 找到对应的奖池
        for k, v in pairs( alienShopCfg.reward ) do 
            if mUserinfo.level <= v.level then 
                rewardCfg = v
                self.shop.ver = k
                break
            end
        end
        if not rewardCfg then -- 超过上限取最后一档
            rewardCfg = alienShopCfg.reward[ #alienShopCfg.reward ]
            self.shop.ver = #alienShopCfg.reward
        end

        setRandSeed()

        -- 两种翻倍规则， lucky优先，其次普通翻倍
        local rateIdx, luckIdx
        if self.shop.lucky and self.shop.lucky >= alienShopCfg.luckylimit then
            luckIdx = rand(1, #alienShopCfg.luckyShelf) -- pro2
        else
            rateIdx = rand(1, #alienShopCfg.allShelfs) --随机一个会翻倍的格子 pro1
        end

        local result = {}
        local lucky = 0
        for k, shelf in pairs( alienShopCfg.allShelfs ) do
            if type(rewardCfg[shelf]) == 'table' then
                local rewardV, rewardKey = getRewardByPool( rewardCfg[shelf].pool )
               
                local rate = 1  -- 翻倍检测 两种情况
                if luckIdx and alienShopCfg.luckyShelf[luckIdx] == shelf then
                    rate = alienShopCfg.pro2 -- luck翻倍
                    self.shop.lucky = nil -- luck值清空
                elseif rateIdx and k == rateIdx then
                    --概率命中
                    local iskick = false
                    if self.shop.pro1 and self.shop.pro1 >= alienShopCfg.reNum then
                        iskick = true -- 前3次未命中直接命中
                    else
                        iskick = rand(1, 100) < (alienShopCfg.probability * 100) --概率翻倍
                    end

                    if iskick then
                        rate = alienShopCfg.pro1 -- 刷新次数翻倍
                        self.shop.pro1=nil
                    else
                        -- 未翻倍
                        self.shop.pro1 = (self.shop.pro1 or 0) + 1 --记录刷新次数
                    end
                end

                local slot = 0
                if type(rewardKey) == 'table' and #rewardKey == 1 then
                    slot = rewardKey[1]
                else
                    error({msg='alien shop cfg err'})
                end

                local tmp = { 
                    r=slot, --奖励索引
                    rate=rate, -- 翻倍比例
                    s=0, -- 购买状态
                }

                lucky = lucky + rewardCfg[shelf].luckyValue[slot]
                table.insert(result, tmp)
            end

        end

        -- 刷新道具表
        self.shop.list = result
        self.shop.lucky = (self.shop.lucky or 0) + lucky

        return true
    end

    -- 定时刷新道具列表
    function self.checkShopRef( )
        -- 上次刷新时间
        local ts = getClientTs()
        if not self.shop.ts then
            self.shop.ts = ts
            return self.refreshAlienShop()
        end

        local weeTs = getWeeTs()
        local alienShopCfg = getConfig("alienShopCfg")
        local refts = {} --每天刷新的时间点
        for k, v in pairs( alienShopCfg.refreshTime ) do 
            table.insert(refts,  weeTs + v[1]*3600 + v[2]*60 )
        end

        local isRef = false
        local lastTs, nowTs = self.shop.ts, ts -- 上次刷新时间， 当前时间
        local idx = nil
        for k, v in pairs( refts ) do
            if k == 1 and lastTs < v then --上一个周期的直接刷新
                isRef = true
                break
            end 

            if lastTs < v then -- 上次刷新的时间段
                idx = k 
                break
            end   
        end

        if not isRef and idx then
            if nowTs > refts[idx] then -- 当前时间到了下一个时间段
                isRef = true
            end 
        end

        if isRef == true then
            self.shop.ts = ts
            return self.refreshAlienShop()
        end

        return false
    end
    
    -- 获取某个大类下 当前升级科技的最大subtreeid
    function self.getMaxSubtreeId(item)

        local alienTechCfg = getConfig("alienTechCfg")
        if type(alienTechCfg.tree[item]['subtreeId']) ~= 'table' then
            return 0
        end
        local len = #alienTechCfg.tree[item]['subtreeId']
        for i=len,1,-1 do
            local subtreeid = alienTechCfg.tree[item]['subtreeId'][i]
            for _, v in pairs( alienTechCfg.subtree[subtreeid].tech ) do 
                if self.info[v] and tonumber(self.info[v]) > 0 then
                    -- 只要有点数 就是当前最大的
                    if tonumber(self.info[v])>0 then
                        return subtreeid
                    end
                end
            end
        end

        return 0
    end

    --------------------------------------------------------------
    
    return self
end    
