acMjcsVoApi={}

function acMjcsVoApi:getAcVo()
    return activityVoApi:getActivityVo("mjcs")
end

function acMjcsVoApi:canReward()
    local vo = self:getAcVo()
    if vo==nil or vo.activeCfg==nil or vo.loginDay==nil then
        return false
    end
    if self:tab1Reward() then
        return true
    end
    if  self:tab2Reward() then
        return true
    end
    return false
end

function acMjcsVoApi:isCanEnter( ... )
    local vo = self:getAcVo()
    if vo==nil or vo.activeCfg==nil then
        return false
    end
    if vo then
        local playerLevel = playerVoApi:getPlayerLevel()
        local limitLevel = vo.activeCfg.levelLimit
        if playerLevel>=limitLevel then
            return true
        end
    end
    return false
end

function acMjcsVoApi:tab1Reward( ... )
    if self:ifLoginTodayReward() or self:ifCanReceive()==2 then
        return true
    end
    return false
end

function acMjcsVoApi:tab2Reward( ... )
    local num = self:taskListNum()
    local finishSituation,receiveSituation = 0,0
    for i=1,num do
        finishSituation,receiveSituation = self:taskFinishSituation( i )
        if finishSituation==1 and receiveSituation==0 then
            return true
        end
    end
    return false
end

--获取后端任务完成情况,finishSituation-完成状态，receiveSituation-领取状态
function acMjcsVoApi:taskFinishSituation( idx )
    local vo = self:getAcVo()
    local finishList = {}
    local finishSituation,receiveSituation = 0,0
    if vo and vo.task and vo.task[idx] then
        finishSituation = vo.task[idx][1] or 0
        receiveSituation = vo.task[idx][2] or 0
    end
    return finishSituation,receiveSituation
end

function acMjcsVoApi:setActiveName(name)
    self.name=name
end

function acMjcsVoApi:getTimeStr( ... )
    local str = ""
    local vo = self:getAcVo()
    if vo then
        local activeTime = vo.et - base.serverTime > 0 and G_formatActiveDate(vo.et - base.serverTime) or nil
        if activeTime == nil then
            activeTime = getlocal("serverwarteam_all_end")
        end
        return getlocal("activityCountdown") .. ":"..activeTime
    end
    return str
end

--登录奖励列表
function acMjcsVoApi:loginReward( day )
    local rewardlist={}
    local vo = self:getAcVo()
    if vo then
        local rewardTb = vo.activeCfg.reward.landReward[day].reward 
        rewardlist = FormatItem(rewardTb,n)
    end
    return rewardlist
end

--累计登录天数
function acMjcsVoApi:loginDay( ... )
    local vo = self:getAcVo()
    local day = 1
    local cfgLoginNum = 0 --配置中的登录天数
    if vo then
        local rewardTb = vo.activeCfg.reward.landReward
        cfgLoginNum=SizeOfTable(rewardTb)
    end
    if vo and vo.loginDay[1] then
        day = vo.loginDay[1]
    end
    if cfgLoginNum<day then
        day=cfgLoginNum
    end
    return day
end

--累计登录领取奖励状态,判断奖励是否可领
function acMjcsVoApi:ifLoginTodayReward( ... )
    local vo = self:getAcVo()
    local cfgLoginNum = 0 --配置中的登录天数
    local day = 1
    if vo then
        local rewardTb = vo.activeCfg.reward.landReward
        cfgLoginNum=SizeOfTable(rewardTb)
    end
    if vo and vo.loginDay[1] then
        day = vo.loginDay[1]
    end
    if day>cfgLoginNum then
        day=cfgLoginNum
    end
    if vo then
        if cfgLoginNum>=day then
            if vo.loginDay[2]==0 then
                return true
            end
        end
    end
    return false
end

--获取配置中累计登录的奖励天数，判断是否明日还有奖励
function acMjcsVoApi:ifTomorrowLoginReward()
    local rewardlist={}
    local vo = self:getAcVo()
    local cfgLoginNum = 0 --配置中的登录天数
    local loginDay = self:loginDay() --累计登录天数
    if vo then
        local rewardTb = vo.activeCfg.reward.landReward
        cfgLoginNum=SizeOfTable(rewardTb)
    end
    if loginDay<cfgLoginNum then
        return true
    end
    return false
end

--跨天登录奖励处理
function acMjcsVoApi:loginDaySpan( ... )
    local vo = self:getAcVo()
    local loginDay = self:loginDay()
    local cfgLoginNum = 0 --配置中的登录天数
    if vo then
        local rewardTb = vo.activeCfg.reward.landReward
        cfgLoginNum=SizeOfTable(rewardTb)
    end
    if vo then
        if loginDay<cfgLoginNum then
            vo.loginDay[1]=loginDay+1
            vo.loginDay[2]=0
            vo.loginDay[3]=base.serverTime
        end
    end
end

--充值奖励
function acMjcsVoApi:payRewardList( ... )
    local rewardlist={}
    local diamond = " "
    local count = 0
    local vo = self:getAcVo()
    if vo then
        local rewardTb = vo.activeCfg.reward.payReward[1].reward
        rewardlist = FormatItem(rewardTb)
        diamond = vo.activeCfg.reward.payReward[1].diamond
        count = vo.activeCfg.reward.payReward[1].count
    end
    return rewardlist,diamond,count
end

--获取充值奖励领取的剩余次数
function acMjcsVoApi:payRewardNum( ... )
    local rewardlist,diamond,count = self:payRewardList()
    local num = 0
    local cn = 0
    local vo = self:getAcVo()
    if vo then
        cn = vo.receiptsNum --后端已领取
        if cn>count then
            cn=count
        end
        num = count-cn --还能领取多少次
    end
    return cn,num
end

--已充值金额
function acMjcsVoApi:haveRecharge( ... )
    local vo = self:getAcVo()
    local v = 0
    if vo and vo.recharge then
        v=vo.recharge
    end
    return v
end

--充值是否可领取
function acMjcsVoApi:ifCanReceive( ... )
    local rewardlist,diamond,count = self:payRewardList()
    local cn,num = self:payRewardNum()
    local haveRecharge = self:haveRecharge()
    local canRewardNum = math.floor(haveRecharge/diamond)  --实际能领取的次数
    local situation = canRewardNum-cn
    local judge = 0 --不可领取
    if cn==count then
        judge=1  --没有领取机会
    elseif situation>0 then
        judge=2 --可领取
    end
    return judge
end

--充值未领取次数
function acMjcsVoApi:canReceiveNum( ... )
    local rewardlist,diamond,count = self:payRewardList()
    local cn,num = self:payRewardNum()
    local haveRecharge = self:haveRecharge()
    local canRewardNum = math.floor(haveRecharge/diamond)-cn  --实际能领取的次数
    if canRewardNum>num then
        canRewardNum=num
    end
    local situation = canRewardNum
    return situation
end

--下方金币购买项的配置
function acMjcsVoApi:shopSell( idx )
    local vo = self:getAcVo()
    local shopSellList = ""
    local commodityCost = ""
    local commodityCount = 0
    local commodityList = vo.activeCfg.reward.shop
    if vo and commodityList then
        local commodityTb = commodityList[idx].item
        shopSellList = FormatItem(commodityTb)
        commodityCost = commodityList[idx].cost
        commodityCount = commodityList[idx].count      
    end
    return shopSellList,commodityCost,commodityCount
end

--下方金币购买项的数量（配置里的）
function acMjcsVoApi:shopSellNum( ... )
    local vo = self:getAcVo()
    local commodityNum = 0
    local commodityList = vo.activeCfg.reward.shop
    if vo and commodityList then
         commodityNum = SizeOfTable(commodityList)
    end
    return commodityNum
end

--后端返回的购买数量
function acMjcsVoApi:purchaseQuantity( idx )
    local vo = self:getAcVo()
    local purchaseNum = 0  --后端返回的已购买的数量
    local str = "i"..idx
    if vo then
        if vo.buyFromShop[str] ~=nil then
            purchaseNum = vo.buyFromShop[str]
        end
    end
    return purchaseNum
end

--判断购买是否达到上限
function acMjcsVoApi:shopIsFinish( idx )
    local vo = self:getAcVo()
    local purchaseNum = self:purchaseQuantity(idx)  --后端返回的已购买的数量
    local shopSellList,commodityCost,commodityCount = self:shopSell(idx) --配置里的限购数量
    if purchaseNum<commodityCount then
        return true
    end
    return false
end

--限购数量描述（配置加后端返回）
function acMjcsVoApi:limitedPurchaseQuantityDes( idx )
    local vo = self:getAcVo()
    local purchaseNum = self:purchaseQuantity(idx)  --后端返回的已购买的数量
    local shopSellList,commodityCost,commodityCount = self:shopSell(idx) --配置里的限购数量
    local str = "i"..idx
    return getlocal("activity_mjcs_tab1_des4",{purchaseNum,commodityCount})
end

function acMjcsVoApi:getSortTaskList()
    local vo = self:getAcVo()
    if vo and vo.activeCfg and vo.activeCfg.reward.taskList then
        local taskList = G_clone(vo.activeCfg.reward.taskList)
        local function sortFunc(a,b)
           local w1 = self:taskIsFinish(a.id)*1000+a.id
           local w2 = self:taskIsFinish(b.id)*1000+b.id
           if w1<w2 then
            return true
           end
           return false
        end
        table.sort( taskList, sortFunc )
        return taskList
    end
    return {}
end

--tab2任务列表,taskRwardList-奖励列表，tasktype-任务类型，taskLimit-任务，starClass-将领星级
function acMjcsVoApi:taskList( idx )
    local vo = self:getAcVo()
    local taskRwardList = { }
    local tasktype,starClass,taskLimit = " "

    if vo and vo.activeCfg.reward.taskList then
        local taskList = vo.activeCfg.reward.taskList
        tasktype = taskList[idx].type
        taskLimit = taskList[idx].d1
        taskRwardList = FormatItem(taskList[idx].reward,nil,true)
        if tasktype==1 then
            starClass = taskList[idx].d2
        end
    end
    return taskRwardList,taskLimit,tasktype,starClass
end

--tab2任务列表数量
function acMjcsVoApi:taskListNum( ... )
    local vo = self:getAcVo()
    local num = 0
    if vo and vo.activeCfg.reward.taskList then
        local taskList = vo.activeCfg.reward.taskList
        num = SizeOfTable(taskList)
    end
    return num
end

--获取后端消费金额
function acMjcsVoApi:getCost( ... )
    local vo = self:getAcVo()
    local cost = 0
    if vo then
        if vo.cost==nil then
            cost=0
        else
            cost = vo.cost
        end
    end
    return cost
end

--tab2任务描述
function acMjcsVoApi:taskListDes( idx )
    local str = " "
    local taskRwardList,taskLimit,tasktype,starClass = self:taskList(idx)
    local finishSituation,receiveSituation = self:taskFinishSituation( idx )
    local cost = self:getCost()
    local recharge = self:haveRecharge()
    if tasktype==1 then
        if starClass ==1 then
            str = getlocal("activity_mjcs_tab2_des1",{heroVoApi:getHeroName(taskLimit),finishSituation})
        else
            str = getlocal("activity_mjcs_tab2_des2",{starClass,heroVoApi:getHeroName(taskLimit),finishSituation})
        end
    elseif tasktype==2 then
        str = getlocal("activity_mjcs_tab2_des3",{taskLimit,recharge,taskLimit})
    else
        str = getlocal("activity_mjcs_tab2_des4",{taskLimit,cost,taskLimit})
    end
    return str
end

--tab2任务完成与否
function acMjcsVoApi:taskIsFinish( idx )
    local taskRwardList,taskLimit,tasktype,starClass = self:taskList(idx)
    local finishSituation,receiveSituation = self:taskFinishSituation( idx )
    local judge 
    if finishSituation==0 then
        judge=1  --未完成
    else
        if receiveSituation==0 then
            judge=0  --完成未领取
        else
            judge=2  --已领取
        end
    end
    return judge
end


function acMjcsVoApi:updateSpecialData(data)
    local vo = self:getAcVo()
    if vo then
        vo:updateSpecialData(data)
        activityVoApi:updateShowState(vo)
    end
end

function acMjcsVoApi:socketMjcsTask(action,refreshFunc,tid)
    local function callBack(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
            if sData and sData.data and sData.data.mjcs then
                self:updateSpecialData(sData.data.mjcs)
            end
            local reward={}
            if sData and sData.data and sData.data.reward then
                local item=FormatItem(sData.data.reward)
                for k,v in pairs(item) do
                    table.insert(reward,v)
                    if v.type == "h" then
                        heroVoApi:addSoul(v.key,v.num)
                    else
                        G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                    end
                end
            end
            if refreshFunc then
                refreshFunc(reward)
            end
        end
    end
    socketHelper:acMjcsSocketTask(action,callBack,tid)
end

function acMjcsVoApi:socketMjcsBuy(refreshFunc,tid,num)
    local function callBack(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
            if sData and sData.data and sData.data.mjcs then
                self:updateSpecialData(sData.data.mjcs)
            end
            local reward={}
            if sData and sData.data and sData.data.reward then
                local item=FormatItem(sData.data.reward)
                for k,v in pairs(item) do
                    table.insert(reward,v)
                    if v.type == "h" then
                        heroVoApi:addSoul(v.key,v.num)
                    else
                        G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                    end
                end
            end
            if refreshFunc then
                refreshFunc(reward)
            end
        end
    end
    socketHelper:acMjcsSocketBuy(callBack,tid,num)
end

function acMjcsVoApi:showHeroInfo(hid,layerNum)
    local skills = {}
    for k,v in pairs(heroListCfg[hid].skills) do
        skills[v[1]]=1
    end
    local vo = heroVo:new()
    vo:initWithData(hid,{80,0,6,skills})
    heroVoApi:showHeroInfoSmallDialog(vo,true,true,layerNum)
end

function acMjcsVoApi:getToday(  )
    local day = 0
    local vo = self:getAcVo()
    if vo then
        local day = math.ceil((vo.loginDay[3]-vo.st)/86400)
        return day
    end
    return day
end

function acMjcsVoApi:checkIsToday()
    local vo = self:getAcVo()
    if vo and vo.loginDay[3] and vo.loginDay[3]>0 and G_isToday(vo.loginDay[3])==false then
        return true
    end
    return false
end

function acMjcsVoApi:isEnd()
    local vo=self:getAcVo()
    if vo and base.serverTime<vo.et then
        return false
    end
    return true
end

function acMjcsVoApi:getVersion()
    local vo = self:getAcVo()
    if vo and vo.activeCfg.version then
        return vo.activeCfg.version
    end
    return 1
end

function acMjcsVoApi:addActivieIcon()
    spriteController:addPlist("public/activeCommonImage3.plist")
    spriteController:addTexture("public/activeCommonImage3.png")
end

function acMjcsVoApi:removeActivieIcon()
    spriteController:removePlist("public/activeCommonImage3.plist")
    spriteController:removeTexture("public/activeCommonImage3.png")
end

