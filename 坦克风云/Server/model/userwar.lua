function model_userwar(uid,data)
    -- the new instance
    local self = {
        uid= uid,
        bid= "", -- 战斗bid
        name="",
        level=0,
        point=0, -- 商店积分
        point1=0, --生存积分
        point2=0, -- 亡者积分
        status=0, -- 玩家状态
        mapx=0,
        mapy=0,
        energy=30, -- 行动力
        round1=0, --生者回合
        round2=0, --亡者回合
        buff={},  -- buff
        info={},  -- 前端的部队和将领
        binfo={},  --设置的部队的信息
        troops={},
        hide={}, -- 躲猫猫记录
        support1=0, --补充行动力
        support2=0, --补充部队
        support3=0, --清除异常状态
        pointlog={}, -- 积分log 
        bcount={},
        apply_at = 0, -- 报名时间
        updated_at=0,
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
        if format then
            for k,v in pairs (self) do
                if type(v)~="function" and k~= 'updated_at' and k~= 'binfo' and k~= 'upgradeinfo' then
                    data[k] = v
                end
            end
        else
            for k,v in pairs (self) do
                if type(v)~="function" and k~= 'updated_at' then
                    data[k] = v
                end
            end
        end

        return data
    end
    
    
    function self.toPush()
        local sms = {
            uid = self.uid,
            energy = self.energy,
            status = self.status,
            point = self.point,
            point1 = self.point1,
            point2 = self.point2,
            round1 = self.round1,
            round2 = self.round2,
            info = self.info,
            troops = self.troops,
            buff = self.buff,
            support1 = self.support1,
            support2 = self.support2,
            support3 = self.support3,
            bcount = self.bcount,
            mapx = self.mapx,
            mapy = self.mapy,
        }
        return sms
    end


      -- 重置所有
    function self.reset()
        local userWarCfg=getConfig("userWarCfg")
        self.energy = userWarCfg.energyMax
        self.status = 0
        self.point1 = 0
        self.point2 = 0
        self.round1 = 0
        self.round2 = 0
        self.place = 0
        self.info = {}
        self.troops = {}
        self.binfo = {}
        self.hide = {}
        self.buff={}
        self.support1=0
        self.support2=0
        self.support3=0
        self.bcount={}
    end
    
    --  增加积分
    --  action 2.战场生存3.战斗胜利4.探索发现5.最终奖励
    --  round 第几回合
    function self.addpoint(point,action,round,Num)
        local action=action or 1
        if type(self.pointlog)~="table" then self.pointlog={}  end
        if not self.pointlog['rc'] then
            self.pointlog['rc'] = {}
        end
        if not self.pointlog['rc'] then
            self.pointlog['rc'] = {}
        end
        table.insert(self.pointlog['rc'],{getClientTs(),action,point,round} )
        local Num=Num or 50
        if #self.pointlog['rc']>Num then
            for i=1,#self.pointlog['rc']-Num do
                    table.remove(self.pointlog['rc'],1)
            end
        end
        --self.point=self.point+point
        return true
    end   

        --使用积分
    function self.usePoint(point, tId, limitNum, rewardType, Num)
        --消费积分
       
        if self.point < point then
            return false,-20014
        end
        self.point = self.point - point
        if type(self.pointlog)~="table" then self.pointlog={}  end
        --验证购买数量

        local buy_at= self.pointlog['bt'] or 0 
        local weeTs = getWeeTs()
        if buy_at<weeTs then
            self.pointlog['lm']={}
            self.pointlog['bt']=weeTs
        end
        if not self.pointlog['lm'] then
            self.pointlog['lm'] = {}
        end
        if not self.pointlog['lm'][tId] then
            self.pointlog['lm'][tId] = 0
        end

        if self.pointlog['lm'][tId] >= limitNum then
            
            return false,-20015
        end
        self.pointlog['lm'][tId] = self.pointlog['lm'][tId] + 1
        --记录消费信息
        if not self.pointlog['rc'] then
            self.pointlog['rc'] = {}
        end
        if not self.pointlog['rc'] then
            self.pointlog['rc']= {}
        end
        table.insert(self.pointlog['rc'], {getClientTs(),1,tId})
        if #self.pointlog['rc']>Num then
            for i=1,#self.pointlog['rc']-Num do
                    table.remove(self.pointlog['rc'],1)
            end
        end
        return true
    end
    
    -- 消耗
    function self.cost(list,mUserinfo)
        if type(list) ~= 'table' then
            -- 记log
            return false
        end
        
        local flag = false
        local result = false
        
        for i,v in pairs(list) do
            if i == 'energy' then
                result = self.useEnergy(v)
            elseif i == 'gems' then
                result = mUserinfo.useGem(v)
                local action = getRequestCmd()[1] or 'cost' 
                regActionLogs(uid,1,{action=122,item="",value=v,params={action=action}})
            end
            
            if not result then
                return false,i
            end
        end
        
        return true,'sucess'
    end
    
    -- 增加行动力
    function self.addEnergy(num)
        local num = num or 1
        local energyMax = getConfig("userWarCfg.energyMax") or 0
        self.energy = self.energy + num
        
        if self.energy > energyMax then
            self.energy = energyMax
        end
        flag = true
        
        return flag
    end
    
    -- 使用行动力
    function self.useEnergy(num)
        local num = num or 1
        local flag = false
        
        if self.energy >= num then
            self.energy = self.energy - num
            flag = true
        end
        
        return flag
    end
    
    -- 补给 行动力
    function self.support_energy(num)
        local num = num or 1
        local energyMax = getConfig("userWarCfg.energyMax") or 0
        self.energy = self.energy + num
        
        if self.energy > energyMax then
            self.energy = energyMax
        end
        
        self.support1 = self.support1 + 1

        return true
    end

    -- 补给 补充部队
    function self.support_addTroops(binfo)
        self.troops = {}
        self.support2 = self.support2 + 1
        return true
    end

    -- 补给 消除异常状态
    function self.support_clearStatus()
        -- 遍历配置 取出异常状态标识
        self.buff.del = nil
        self.support3 = self.support3 + 1
        return true
    end
    
    -- 躲猫猫 隐藏自己
    function self.action_hide(round)
        if type(self.hide) ~= 'table' then
            self.hide = {}
        end
        
        local flag = false
        if not self.hide['h'.. round] then
            self.hide['h'.. round] = getClientTs()
            flag = true
        end
        
        return flag
    end
    
    function self.addBuff(btype,name,val)
        if type(self.buff) ~= 'table' then
            self.buff = {}
        end
        
        if not self.buff[btype] then
            self.buff[btype] = {}
        end
        
        local val = tonumber(val) or 0
        if self.buff[btype][name] then
            self.buff[btype][name] = self.buff[btype][name] + val
        else
            self.buff[btype][name] = val
        end
        
        return true
    end
    
    -- 设置状态
    function self.setDie(round,x,y)
        local userWarCfg=getConfig("userWarCfg")
        self.status=self.status+1
        if self.status > 2 then
            self.status = 2
        end
        self.energy=userWarCfg.energyMax
        self.buff={}
        self.troops = {}
        
        if self.status == 1 then
            self.round1 = round - 1
            self.point1=tonumber(self.point1)+self.round1*userWarCfg.survivalPoint
            self.point=self.point+self.round1*userWarCfg.survivalPoint
            self.addpoint(self.round1*userWarCfg.survivalPoint,2,tonumber(self.round1))
        end
        if x and y then
            self.mapx=x
            self.mapy=y
        end
        
        return self.status
    end
    
    function self.addPointDirect(status,point,action,round,Num)
        --writeLog(uid..'addPointDirect-st:'..json.encode({status,point,action,round,Num}),'addPointDirect')
        local status = status == 0 and 1 or 2
        local action=action or 1
        --writeLog('addPointDirect-pointlog:'..json.encode({pointlog=pointlog}),'addPointDirect')
        if type(self.pointlog)~="table" then 
            if type(self.pointlog) == 'string' then
                self.pointlog = json.decode(self.pointlog) or {}
            else
                self.pointlog={}  
            end
        end
        if not self.pointlog['rc'] then
            self.pointlog['rc'] = {}
        end
        if not self.pointlog['rc'] then
            self.pointlog['rc'] = {}
        end
        table.insert(self.pointlog['rc'],{getClientTs(),action,point,round} )
        local Num=Num or 50
        if #self.pointlog['rc']>Num then
            for i=1,#self.pointlog['rc']-Num do
                table.remove(self.pointlog['rc'],1)
            end
        end
        
        self.point=self.point+point
        --writeLog('addPointDirect-point:'..point,'addPointDirect')
        self['point'..status] = (self['point'..status] or 0) + point
        --writeLog(uid..'addPointDirect-et'..json.encode({self.point,self['point1'],self['point2']}),'addPointDirect')
        return true
    end
    
    function self.getApply()
        local ts = getClientTs()
        local flag = false
        
        if getWeeTs(self.apply_at) == getWeeTs(ts) then
            flag = true
        end
        
        return flag
    end
    
    function self.setCount(bid,action,num)
        --writeLog('bcount start:'..self.uid..','..json.encode({bid,action,num}),'bcount')
        if not self.bcount then
            self.bcount = {}
        end
        --writeLog('bcount mid:'..self.uid..','..json.encode(self.bcount),'bcount')
        if type(self.bcount) == 'string' then
            self.bcount = json.decode(self.bcount) or {}
        end
        --writeLog('bcount mid:'..self.uid..','..json.encode(self.bcount),'bcount')
        local num = num or 1
        
        if self.bcount[action] then
            self.bcount[action] = self.bcount[action] + num
        else
            self.bcount[action] = num
        end
        --writeLog('bcount end:'..self.uid..','..json.encode(self.bcount),'bcount')
        return true
    end
    
    return self
end   