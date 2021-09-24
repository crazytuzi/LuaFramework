acXssd2019VoApi={
    secretCardNum = 0
}

function acXssd2019VoApi:getAcVo()
    return activityVoApi:getActivityVo("xssd2019")
end

function acXssd2019VoApi:isToday()
    local isToday=false
    local vo=self:getAcVo()
    if vo and vo.lastTime then
        isToday=G_isToday(vo.lastTime)
    end
    return isToday
end

function acXssd2019VoApi:canReward()
    local vo = self:getAcVo()
    if vo==nil or vo.activeCfg==nil then
        return false
    end
    local acStartFlag = activityVoApi:isStart(vo)
    if acStartFlag == false then
        return false
    end
    if self:tab1Reward() or self:tab2Reward() then
        return true
    end

    return false
end

function acXssd2019VoApi:isCanEnter( ... )
    local vo = self:getAcVo()
    if vo==nil or vo.activeCfg==nil then
        return false
    end
    if vo and vo.activeCfg then
        local playerLevel = playerVoApi:getPlayerLevel()
        local limitLevel = vo.activeCfg.Lv
        if playerLevel>=limitLevel then
            return true
        end
    end
    return false
end

function acXssd2019VoApi:enterLevel( ... )
    local vo = self:getAcVo()
    local limitLevel = 1
    if vo and vo.activeCfg then
        limitLevel = vo.activeCfg.Lv
    end
    return limitLevel
end

function acXssd2019VoApi:tab1Reward( )
    for i=1,3 do
        if self:allRewardState( i ) == 2 then
            return true
        end
    end
    local num = self:selfRewardNum()
    for idx=1,num do
        if self:selfRewardState( idx ) == 2 then
            return true
        end
    end
    local day , flagDay  = self:getToday(  )
    local flag,point = self:integralPointShow( curValue )
    if flagDay == 1 then
        if flag==2 and self:ifCanIntegralReward( ) then
            return true
        end
    end
    return false
end

function acXssd2019VoApi:tab2Reward( ... )
    local state1 = self:hasExternalReward()
    local state2 = self:hasNomalReward( )
    if state1 == 2 then
        return true
    end
    if state2 == 2 then
        return true
    end
    return false
end

function acXssd2019VoApi:tab3Reward( ... )
    local state1 = self:howToPayLeft()
    local state2 = self:howToPayRight()
    if state1 == 1 then
        return true
    end
    if state2 == 1 then
        return true
    end
    return false
end

--界面间的刷新
function acXssd2019VoApi:refreshFunc( tag )
    if tag == 1 then
        return true
    end
    return false
end

--奖章描述
function acXssd2019VoApi:getAcNameAndDesc()
    local itemData = {}
    itemData.name = getlocal("activity_xssd2019_coinName")
    itemData.desc = "activity_xssd2019_coinDesc"
    itemData.pic = "xssd2019_rewardIcon.png"
    itemData.bgname = "Icon_BG.png"
    return itemData
end

--跨天时间戳
function acXssd2019VoApi:getTime( ... )
    local vo = self:getAcVo()
    local timeStamp = base.serverTime
    if vo then
        timeStamp = vo.timeStamp
    end
    return timeStamp
end

function acXssd2019VoApi:setActiveName(name)
    self.name=name
end

--flag:是否在活动时间内 0 : 活动时间内 1：领奖时间 2：关闭
function acXssd2019VoApi:getToday(  )
    local day = 0
    local flag = 0
    local vo = self:getAcVo()
    local serverTimeZeroT = G_getWeeTs(base.serverTime)
    local startZeroT = G_getWeeTs(vo.st)
    if vo then
        local day = (serverTimeZeroT - startZeroT)/86400 + 1
        if day>vo.activeCfg.day then
            if day == vo.activeCfg.day+1 then
                flag = 1
            else 
                flag = 2
            end
            day = vo.activeCfg.day
        end
        return day,flag
    end
    return day,flag
end

--------------------------------------------------------   本服悬赏任务   --------------------------------------------------------
--本服倒计时
function acXssd2019VoApi:getTimeStr1( ... )
    local str = ""
    local vo = self:getAcVo()
    local today,flag = self:getToday()
    if vo and vo.activeCfg then
        local activeTime = vo.et-86400  - base.serverTime > 0 and G_formatActiveDate(vo.et -86400- base.serverTime) or nil
        if activeTime == nil or flag==1 or flag==2 then
            activeTime = getlocal("serverwarteam_all_end")
        end
        return getlocal("acCD") .. ":"..activeTime
    end
    return str
end

--判断昨天的奖励有没有全领取
function acXssd2019VoApi:ifPreAllReward( )
    local vo = self:getAcVo()
    local today,flag = self:getToday()
    if vo and vo.activeCfg and vo.allReward and vo.preDayRewardNum then
        --判断昨天的奖励有没有全领取
        if today>=2 then
            local preRewardTb
            local preRewardCfgNum
            if flag==0 then
                local day = "t"..(today-1)
                preRewardTb = vo.allReward[day]
                preRewardCfgNum = vo.activeCfg.task1[today-1].num
            else
                local day = "t"..today
                preRewardTb = vo.allReward[day]
                preRewardCfgNum = vo.activeCfg.task1[today].num
            end
            local num,num1 = 0,0
            for k,v in pairs(preRewardCfgNum) do
                if v<=vo.preDayRewardNum then
                    num = num+1
                end
            end
            if num>0 then
                if preRewardTb then
                    num1 = SizeOfTable(preRewardTb)
                end
                if num <= num1 then --昨日全部领取
                    return true
                else
                    return false
                end
            end
        end
    end
    return true
end

--本服悬赏任务描述
function acXssd2019VoApi:allRewardDes(  )
    local vo = self:getAcVo()
    local str = ""
    local num = 0
    local allRewardTb = {}
    local today,flag = self:getToday()
    local isLastDayUse = true
    if vo and vo.activeCfg and vo.preDayRewardNum then
        if flag==0 then --or flag==1 then
            if self:ifPreAllReward() then
                allRewardTb = vo.activeCfg.task1[today]
                num = vo.allRewardNum
                isLastDayUse = false
            else
                allRewardTb = vo.activeCfg.task1[today-1]
                num = vo.preDayRewardNum
            end
        else
            allRewardTb = vo.activeCfg.task1[today]
            num = vo.preDayRewardNum
        end
        -- local des = "activity_chunjiepansheng_"..allRewardTb.key.."_title"
        -- str = getlocal(des,{num,allRewardTb.num[3]})
        local isfull = num >= allRewardTb.num[3] and true or false
        local str1 = G_getTaskWithDescLb(allRewardTb.key,num,allRewardTb.num[3],isfull)  
        str = getlocal("activity_xssd2019_all")..str1

    end
    -- print("str in allRewardDes=====>>>>",isLastDayUse,str)
    return str, isLastDayUse
end

--本服悬赏任务配置
function acXssd2019VoApi:allRewardTb(useday)
    local vo = self:getAcVo()
    local str = ""
    local allRewardTb = {}
    local today,flag = self:getToday()
    today = useday or today
    if vo and vo.activeCfg then
        if flag==0 then
            if self:ifPreAllReward() then
                allRewardTb = vo.activeCfg.task1[today]
            else
                allRewardTb = vo.activeCfg.task1[today-1]
            end
        else
            allRewardTb = vo.activeCfg.task1[today]
        end
    end
    return allRewardTb
end

--本服悬赏任务展示第几天
function acXssd2019VoApi:taskDay( ... )
    local vo = self:getAcVo()
    if vo and vo.activeCfg then
        local allRewardKey = self:allRewardTb().key
        local rewardTb = vo.activeCfg.task1
        for k,v in pairs(rewardTb) do
            if v.key == allRewardKey then
                return k
            end
        end
    end
    return 0
end

--本服悬赏任务档位数字
function acXssd2019VoApi:allRewardNum( i )
    local vo = self:getAcVo()
    local str = ""
    local num = 0
    local allRewardTb = self:allRewardTb(   )
    if allRewardTb then
        num = allRewardTb.num[i]
    end
    return num
end

--本服悬赏奖励展示(配置)
function acXssd2019VoApi:allRewardShow( i ,day)
    local vo = self:getAcVo()
    local allReward1 = {}
    local allRewardTb = self:allRewardTb(day)
    if allRewardTb then        
        allReward1 = allRewardTb.reward1[i]
    end
    return allReward1
end

--奖励是否可领取
function acXssd2019VoApi:ifCanRewardAll( i )
    local vo = self:getAcVo()
    local today,flag = self:getToday()
    local num,numCfg = 0
    if vo and vo.activeCfg and vo.activeCfg.task1 then
        if flag==0  then
            if self:ifPreAllReward() then
                num = vo.allRewardNum
                numCfg = vo.activeCfg.task1[today] and vo.activeCfg.task1[today].num and vo.activeCfg.task1[today].num[i] or 999999999999
            else
                num = vo.preDayRewardNum
                numCfg = vo.activeCfg.task1[today - 1] and vo.activeCfg.task1[today - 1].num and vo.activeCfg.task1[today-1].num[i] or 999999999999
            end
        else
            num = vo.preDayRewardNum
            numCfg = vo.activeCfg.task1[today].num[i]
        end
        if num>=numCfg then
            return true
        end
    end
    return false
end

--奖励是否已领取
function acXssd2019VoApi:haveRewardAll( i )
    local vo = self:getAcVo()
    local today,flag = self:getToday()
    local dayStr = ""
    local haveRewardAllTb = {}
    if vo and vo.activeCfg then
        if flag==0 then
            if self:ifPreAllReward() then
                dayStr = "t"..today
            else
                dayStr = "t"..(today-1)
            end
        else
            dayStr = "t"..today
        end
        haveRewardAllTb = vo.allReward[dayStr]
        if haveRewardAllTb then
            for k,v in pairs(haveRewardAllTb) do
                if v == i then
                    return true
                end
            end
        end
    end
    return false
end

--本服悬赏任务状态   1：不可领取   2：可领取   3：已领取  4:过期
function acXssd2019VoApi:allRewardState( i )
    local ifCanRewardAll = self:ifCanRewardAll(i)
    local haveRewardAll = self:haveRewardAll(i)
    local today,flag = self:getToday()
    -- print("ifCanRewardAll----haveRewardAll--->>>>",ifCanRewardAll,haveRewardAll,flag)
    if flag ~= 2 then--活动时间内
        if ifCanRewardAll then
            if haveRewardAll then
                return 3
            else
                return 2
            end
        else
            return 1
        end
    else
        return 4
    end
end

--奖励领取闪光
function acXssd2019VoApi:rewardFlicker(parentBg1,parentBg2,i,scale)
    if parentBg1 and parentBg1:getChildByTag(10101) == nil and parentBg2 and parentBg2:getChildByTag(10101) == nil then
        local pzFrameName="xssd2019Flicker_1.png"
        local metalSp=CCSprite:createWithSpriteFrameName(pzFrameName)
        if scale then
            metalSp:setScale(2*scale)
        else
            metalSp:setScale(2)
        end
        local pzArr=CCArray:create()
        for kk=1,10 do
            local nameStr="xssd2019Flicker_"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            pzArr:addObject(frame)
        end
        local blendFunc = ccBlendFunc:new()
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        metalSp:setBlendFunc(blendFunc)

        local animation=CCAnimation:createWithSpriteFrames(pzArr)
        animation:setDelayPerUnit(0.1)
        local animate=CCAnimate:create(animation)
        metalSp:setAnchorPoint(ccp(0.5,0.5))
        metalSp:setPosition(ccp(parentBg1:getContentSize().width/2,parentBg1:getContentSize().height/2-3))
        metalSp:setTag(10101)
        -- if lnum==nil then
        --     lnum=5
        -- end

        local nameStr = "xssd2019Flicker_bg"..i..".png"
        local realLight = CCSprite:createWithSpriteFrameName(nameStr)
        realLight:setPosition(ccp(parentBg1:getContentSize().width/2,parentBg1:getContentSize().height/2-3))
        realLight:setBlendFunc(blendFunc)    
        parentBg2:addChild(realLight) 

        local fadeTo1 = CCFadeTo:create(0.5,255*0.5)
        local fadeTo2 = CCFadeTo:create(0.5,255)
        local fadeTo3 = CCFadeTo:create(0.5,255*0.5)
        -- local seq = CCSequence:createWithTwoActions(fadeTo1,fadeTo2)
        
        local acArr=CCArray:create()
        acArr:addObject(fadeTo1)
        acArr:addObject(fadeTo2)
        local seq=CCSequence:create(acArr)
        local repeatForever2=CCRepeatForever:create(seq)
        realLight:runAction(repeatForever2)

        parentBg1:addChild(metalSp)
        local repeatForever1=CCRepeatForever:create(animate)
        metalSp:runAction(repeatForever1)
        return metalSp,realLight

    end
end

--------------------------------------------------------   个人悬赏任务   --------------------------------------------------------
--个人倒计时
function acXssd2019VoApi:getTimeStr2( ... )
    local str = ""
    local vo = self:getAcVo()
    local today,flag = self:getToday()
    if vo and vo.activeCfg then
        
        local activeTime =G_getWeeTs(base.serverTime)+86400 - base.serverTime>0 and G_formatActiveDate(G_getWeeTs(base.serverTime)+86400 - base.serverTime) or nil

        if activeTime == nil or flag==1 or flag==2 then
            activeTime = getlocal("serverwarteam_all_end")
        end
        return getlocal("acCD") .. ":"..activeTime
    end
    return str
end

--个人悬赏任务个数
function acXssd2019VoApi:selfRewardNum(  )
    local vo = self:getAcVo()
    if vo and vo.activeCfg then
        return SizeOfTable(vo.activeCfg.task2)
    end
    return 0
end

--个人悬赏任务完成到第几档位
function acXssd2019VoApi:selfReward( idx )
    local vo = self:getAcVo()
    local num = 0
    if vo and vo.activeCfg then
        local taskName = "t"..(idx+1)
        local selfTaskNumTb = vo.activeCfg.task2[idx].num
        local selfReward = vo.selfReward[taskName]  -- 已完成多少
        if selfReward then
            for k,v in pairs(selfTaskNumTb) do
                if num<SizeOfTable(selfTaskNumTb) then
                    if selfReward>=v then
                        num = num+1
                    end
                end
            end
        end
    end
    return num
end

--个人悬赏任务可以展示第几档位
function acXssd2019VoApi:selfHaveReward( idx)
    local vo = self:getAcVo()
    if vo and vo.activeCfg and vo.selfHaveReward and vo.selfHaveReward["t"..idx] then
        local task2MaxNum = SizeOfTable(vo.activeCfg.task2[idx].num)
        local num = SizeOfTable(vo.selfHaveReward["t"..idx])
        if num > 0 then
            if vo.selfHaveReward["t"..idx][num] + 1 > task2MaxNum then
                return task2MaxNum
            else
                return vo.selfHaveReward["t"..idx][num] + 1
            end
        end
    end
    return 1
end

--个人悬赏任务描述(idx——第几个任务，i——该任务中的第几档)
function acXssd2019VoApi:selfRewardDes( idx )
    local vo = self:getAcVo()
    local realNum = self:selfHaveReward( idx )
    local str = "t"..(idx)
    local selfReward = vo.selfReward[str] or 0
    local str = ""
    if vo and vo.activeCfg then
        local selfTaskTb = vo.activeCfg.task2[idx]
        local isfull = selfReward >= selfTaskTb.num[realNum] and true or false
        local str1 = G_getTaskWithDescLb(selfTaskTb.key,selfReward,selfTaskTb.num[realNum],isfull)
        -- des = "activity_chunjiepansheng_"..selfTaskTb.key.."_title"
        -- str = getlocal(des,{selfReward,selfTaskTb.num[realNum]})
        str = getlocal("alliance_war_personal")..str1
    end
    return str
end

--个人悬赏任务积分（配置）(idx——第几个任务，i——该任务中的第几档)
function acXssd2019VoApi:selfRewardPoint( idx )
    local vo = self:getAcVo()
    local num = self:selfReward( idx )  --已完成数量
    local realNum = self:selfHaveReward( idx )  --正在展示的档位
    local point = 0
    if vo and vo.activeCfg then
        local selfTaskPointTb = vo.activeCfg.task2[idx].point
        point = selfTaskPointTb[realNum]
    end
    return point
end

--个人悬赏奖励展示(配置)(idx——第几个任务)
function acXssd2019VoApi:selfRewardShow( idx )
    local vo = self:getAcVo()
    local num = self:selfReward( idx )  --已完成数量
    local realNum = self:selfHaveReward( idx )  --正在展示的档位
    local selfRewardTb = ""
    if vo and vo.activeCfg then
        local selfTaskTb = vo.activeCfg.task2[idx]
        local selfKey = selfTaskTb.key
        selfRewardTb = vo.activeCfg.task2R[selfKey][realNum]
    end
    return selfRewardTb
end

--个人悬赏奖励任务的key
function acXssd2019VoApi:selfRewardTaskKey( idx )
    local vo = self:getAcVo()
    local selfKey
    if vo and vo.activeCfg then
        local selfTaskTb = vo.activeCfg.task2[idx+1]
        selfKey = selfTaskTb.key
    end
    return selfKey
end

--个人悬赏任务状态   1：不可领取   2：可领取   3：已领取  4:过期
function acXssd2019VoApi:selfRewardState( idx )
    local vo = self:getAcVo()
    local today,flag = self:getToday()
    local selfKey 
    if flag ~=2 then
        if vo and vo.activeCfg then
            local curIndex = self:selfHaveReward( idx)  --正在展示的档位

            --先判断是否已经领取
            if vo.selfHaveReward and vo.selfHaveReward["t"..idx] then
                for k, v in pairs(vo.selfHaveReward["t"..idx]) do
                    if v == curIndex then
                        return 3
                    end
                end
            end

            --判断是否可以领取
            local curNum = 0
            if vo.selfReward and vo.selfReward["t"..idx] then
                curNum = vo.selfReward["t"..idx]
            end
            local curMaxNum = 0
            if vo.activeCfg.task2[idx] then
                curMaxNum = (vo.activeCfg.task2[idx].num[curIndex] or 0)
            end
            if curNum >= curMaxNum then
                return 2
            end
        end
    else
        return 4
    end
    return 1
end

--任务跳转
function acXssd2019VoApi:taskJumpTo(taskKey)
    local typeName = taskKey
    typeName = typeName =="gba" and "gb" or typeName--heroM
    typeName = (typeName =="bc" or typeName == "gd") and "cn" or typeName
    typeName = (typeName =="ua" or typeName == "ta") and "armor" or typeName
    typeName = (typeName =="uh" or typeName == "th") and "heroM" or typeName
    typeName = typeName =="pr" and "tp" or typeName
    typeName = (typeName == "ac" or typeName == "ai" or typeName == "ai1" or typeName == "ai2") and "aiTroop" or typeName
    typeName = (typeName == "st" or typeName == "sj") and "emblemTroop" or typeName
    typeName = typeName == "zy" and "pp" or typeName
    typeName = typeName == "zt" and "tankfactory" or typeName
    local useIdx = nil
    if taskKey == "st" then
        useIdx = 2
    elseif taskKey == "sj" then
        useIdx = 1
    end
    G_goToDialog2(typeName, 4, true, useIdx)
end

--------------------------------------------------------   任务积分奖励   --------------------------------------------------------
--当前积分
function acXssd2019VoApi:integralPoint( )
    local vo = self:getAcVo()
    local integralPoint = 0
    local selfRewardTb = ""
    if vo then
        integralPoint = vo.integralPoint
    end
    return integralPoint
end

--积分奖励是否已领取
function acXssd2019VoApi:ifCanIntegralReward(   )
    local vo = self:getAcVo()
    if vo and vo.pointReward then
        if vo.pointReward ~=0 then
            return false
        end
    end
    return true
end

--滑动滑块上限
function acXssd2019VoApi:slidermax( ... )
    local vo = self:getAcVo()
    local max = 1
    if vo and vo.activeCfg then
        local task2P = vo.activeCfg.task2P
        for k,v in pairs(task2P) do
            if k==#task2P then
                max = v.point
            end
        end
    end
    return max
end


--滑动滑块展示的积分
function acXssd2019VoApi:integralPointShow( integral )
    local flag = 1 --积分未到领奖位置
    local curIntegralPoint = self:integralPoint()
    local integralPoint = curIntegralPoint
    local prePoint = 0
    if integral then
        integralPoint = integral
    end
    local vo = self:getAcVo()
    local selfTb = {}
    if vo and vo.activeCfg then
        selfTb = vo.activeCfg.task2P
        for k,v in pairs(selfTb) do
            if integralPoint<v.point then
                if k~=1 then
                    integralPoint = selfTb[k-1].point
                    if k>2 then
                        prePoint = selfTb[k-2].point
                    else
                        prePoint = 0
                    end

                    if curIntegralPoint<integralPoint then
                        flag = 1
                    else
                        flag = 2
                    end
                    break
                else
                    integralPoint = v.point
                    prePoint = 0
                    if curIntegralPoint<integralPoint then
                        flag = 0  --特殊情况，现有积分小于第一档
                    else
                        flag = 2
                    end
                    
                    break
                end
            else
                if k==SizeOfTable(selfTb) then
                    integralPoint = v.point
                    prePoint = selfTb[k-1].point
                end
                if curIntegralPoint<integralPoint then
                    flag = 1
                else
                    flag = 2
                end
            end
        end
    end
    return flag,integralPoint,prePoint
end

--滑动滑块展示的积分
function acXssd2019VoApi:integralPointShow2( integral )
    local flag1 = 1 --在哪种档位
    local flag2 = false  -- 能不能领取该奖励
    local curIntegralPoint = self:integralPoint()
    local integralPoint = curIntegralPoint
    local prePoint = 0
    if integral then
        integralPoint = integral
    end
    local vo = self:getAcVo()
    local selfTb = {}
    if vo and vo.activeCfg then
        selfTb = vo.activeCfg.task2P
        for k,v in pairs(selfTb) do
            if integralPoint<v.point then
                if k==1 then
                    integralPoint=selfTb[k+1].point
                    prePoint=v.point
                    flag1=1   -- 未到第一档位
                    flag2=false
                    break
                else
                    integralPoint=v.point
                    prePoint=selfTb[k-1].point
                    flag1=2   --正常档位状态
                    if curIntegralPoint>=prePoint and curIntegralPoint<integralPoint then
                        flag2 = true
                    else
                        flag2 = false
                    end
                    break
                end
            elseif k==SizeOfTable(selfTb) then
                integralPoint = v.point
                prePoint = v.point
                flag1 = 3 --超过最大档位
                if curIntegralPoint>=v.point then
                    flag2=true
                else
                    flag2=false
                end
                break

            end

        end
    end
    return integralPoint,prePoint,flag1,flag2
end

function acXssd2019VoApi:rewardPointFlag( integral )
    local pointFlag = 1 --积分未到领奖位置
    local curIntegralPoint = self:integralPoint()
    local flag,integralPoint,prePoint = self:integralPointShow2( integral )
    if flag ==1 then
        pointFlag =1
    elseif curIntegralPoint>=prePoint and curIntegralPoint<integralPoint then
        pointFlag=2
    else
        pointFlag=3
    end
    local selfTb = {}
    if vo and vo.activeCfg then
        selfTb = vo.activeCfg.task2P
        local tabNum = SizeOfTable(selfTb)
        if selfTb[tabNum].point <=curIntegralPoint then
            pointFlag=4
        end
    end
    return pointFlag

end

--发送的积分tid
-- function acXssd2019VoApi:sendPoint(  )
--     local vo = self:getAcVo()
--     local selfTb = {}
--     if vo then
--         local flag,integralPoint = self:integralPointShow()
--         selfTb = vo.activeCfg.task2P
--         for k,v in pairs(selfTb) do
--             if v.point == integralPoint then
--                 return k 
--             end
--         end
--     end
--     return 0
-- end


--滑动滑块展示的奖励
function acXssd2019VoApi:integralRewardShow( integral )
    local vo = self:getAcVo()
    local flag,integralPoint = self:integralPointShow(integral)
    local selfTb = {}
    local selfRewardTb = {}
    local max = self:slidermax()
    if vo and vo.activeCfg then
        selfTb = vo.activeCfg.task2P
        for k,v in pairs(selfTb) do
            if v.point==integralPoint then
                selfRewardTb = FormatItem(v.reward)
                if flag == 0 then
                    for i,j in pairs(selfRewardTb) do
                        j.num=0
                    end
                end
            end
        end
    end
    return selfRewardTb
end

--积分奖励领取的档位
function acXssd2019VoApi:integralLevel( ... )
    local vo = self:getAcVo()
    local integralPoint = acXssd2019VoApi:integralPoint( )
    if vo and vo.activeCfg then
        local task2P = vo.activeCfg.task2P
        for k,v in pairs(task2P) do
            if integralPoint<v.point then
                return k-1 
            elseif k==SizeOfTable(task2P) then
                if integralPoint>=v.point then
                    return k
                end
            end
        end
    end
    return 0
end

--后端返回奖励
function acXssd2019VoApi:recieveReward( ... )
    local vo = self:getAcVo()
    local task2PReward = {}
    if vo and vo.activeCfg then
        local integralLevel = self:integralLevel()
        if integralLevel>0 then
            task2PReward = vo.activeCfg.task2P[integralLevel].reward
        end
    end

    -- if vo and vo.activeCfg and vo.pointReward~=0  then
    --     task2PReward = vo.activeCfg.task2P[vo.pointReward].reward
    -- end
    return task2PReward
end

--------------------------------------------------------   红  包   --------------------------------------------------------
--密码红包领取上限（配置）
function acXssd2019VoApi:redEnvelopeLimit( ... )
    local vo = self:getAcVo()
    local limitNum = 0
    if vo and vo.activeCfg then
        limitNum = vo.activeCfg.limit
    end
    return limitNum
end

--概率
function acXssd2019VoApi:getProbability( ... )
    local vo = self:getAcVo()
    local getProbability = 0
    if vo and vo.activeCfg then
        getProbability = vo.activeCfg.weight[1]/vo.activeCfg.weight[2]
    end
    return getProbability*100
end

--红包发军团广播
function acXssd2019VoApi:chatCorpRedBag()--后台返回后 直接军团广播，
    local vo = self:getAcVo()
    local redid = playerVoApi:getUid()
    local paramTab={}
    paramTab.functionStr="acXssd2019WithRedBag"
    paramTab.addStr="activity_double11New_clickToGetRedBag"
    paramTab.redBagTb={redid =redid,sender=playerVoApi:getPlayerName(),redbuyedTs=base.serverTime}
    local chatKey1="activity_xssd2019_CorpChat"
    local message={key=chatKey1,param={playerVoApi:getPlayerName()}}
    chatVoApi:sendSystemMessage(message,paramTab,nil,3,playerVoApi:getPlayerAid()+1)
end

--有没有触发红包
function acXssd2019VoApi:canSendRedBag( ... )
    local flag = false
    local vo = self:getAcVo()
    if vo and vo.redid == 1 then
        flag = true
    end
    return flag
end

--红包ID
function acXssd2019VoApi:redBagId( ... )
    local vo = self:getAcVo()
    local redBagId = vo.redid
    return redBagId
end

function acXssd2019VoApi:redBagSceneGame()--充值之后概率弹板
    if playerVoApi:getPlayerAid() and playerVoApi:getPlayerAid() > 0 then
        self:chatCorpRedBag()
        local redDialog = smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("activity_xssd2019_tips1"),nil,950)
    else
        local sendRedBagFail = smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("personal_noAlliance"),nil,950)
    end
    
end

function acXssd2019VoApi:isHasTag(tag)
    local vo = self:getAcVo()
    for k,v in pairs(vo.receivedCorpRedBagTb) do
        if v.tag == tag then
            -- print("yes~~~~~~~tag---->>>>>",tag)
            return true
        end
    end
    return false
end

function acXssd2019VoApi:setRecBagTbTagNil(tag,idx)--idx: 通过军团红包板子清理图标tag tag:通过点击抢红包清理图标tag
    local vo = self:getAcVo()
    if vo and vo.receivedCorpRedBagTb and SizeOfTable(vo.receivedCorpRedBagTb) > 0 and idx then
        -- print("tag------vo.receivedCorpRedBagTb[idx].tag-->>",tag,vo.receivedCorpRedBagTb[idx].tag)
        vo.receivedCorpRedBagTb[idx].tag =nil
    elseif vo and vo.receivedCorpRedBagTb and SizeOfTable(vo.receivedCorpRedBagTb) > 0 and tag then
        for k,v in pairs(vo.receivedCorpRedBagTb) do
            if v.tag == tag then
                vo.receivedCorpRedBagTb[k].tag =nil
            end
        end
    end
end

function acXssd2019VoApi:showActionTip( parent,tag,ccPos)
    -- print("in showActionTip~~~~~~")
    local guangSp = CCSprite:createWithSpriteFrameName("equipShine.png")
    guangSp:setPosition(ccPos)
    guangSp:setScale(0.48)
    guangSp:setTag(tag)
    parent:addChild(guangSp,3)

    local iconFuzi = "friendBtn.png"
    if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
        iconFuzi = "bless_getword.png"
    end
    local fuzi = CCSprite:createWithSpriteFrameName(iconFuzi)
    fuzi:setPosition(ccPos)
    fuzi:setScale(0.45)
    fuzi:setTag(tag+1000)
    parent:addChild(fuzi,3)
    local time = 0.07
    local rotate1=CCRotateTo:create(time, 30)
    local rotate2=CCRotateTo:create(time, -30)
    local rotate3=CCRotateTo:create(time, 20)
    local rotate4=CCRotateTo:create(time, -20)
    local rotate5=CCRotateTo:create(time, 0)

    local delay=CCDelayTime:create(1)
    local acArr=CCArray:create()
    acArr:addObject(rotate1)
    acArr:addObject(rotate2)
    acArr:addObject(rotate3)
    acArr:addObject(rotate4)
    acArr:addObject(rotate5)
    acArr:addObject(delay)
    local seq=CCSequence:create(acArr)
    local repeatForever=CCRepeatForever:create(seq)
    fuzi:runAction(repeatForever)

    return guangSp,fuzi
end

function acXssd2019VoApi:setNewGetRecordInCorp(corpRedBagTb)--点击某一军团红包，获取红包相关信息
    local vo =self:getAcVo()
    if vo and corpRedBagTb then
        vo.corpRedBagRecordTb =corpRedBagTb
        vo.redBagRecordTb =nil
    end
end
function acXssd2019VoApi:setNewGetRecord(redBagTb)--点击某一红包，获取红包相关信息
    local vo =self:getAcVo()
    if vo and redBagTb then
        vo.redBagRecordTb =redBagTb
        vo.corpRedBagRecordTb =nil
    end
end

function acXssd2019VoApi:formatNewAllainceRedBagTb(newTb)
    local formatedTb = {}
    local vo = self:getAcVo()
    local newTbUseNum = SizeOfTable(newTb)
    if newTbUseNum > 0 then
        newTbUseNum = newTbUseNum + 1
    end
    for k,v in pairs(newTb) do
        formatedTb[newTbUseNum - k] = {redid =v[1],sender=v[2],redbuyedTs = v[3],redtype = 2, redmethod = v[4], redcount = v[5]}
        if not v[6] then
            acDouble11NewVoApi:setRedBagTagbaseIdx(newTbUseNum - k,true)
            formatedTb[newTbUseNum - k].tag = acDouble11NewVoApi:getRedBagTagbaseIdx() + 1019
        else
            formatedTb[newTbUseNum - k].tag = nil
        end
    end
    vo.receivedCorpRedBagTb = G_clone(formatedTb)
end

function acXssd2019VoApi:setReceivedCorpRedbagTb(corpRedBagTb )--corpRedBagTb 是单体  vo.receivedCorpRedBagTb 最多接收15个单体
    local vo = self:getAcVo()
    if vo and corpRedBagTb then
        if SizeOfTable(vo.receivedCorpRedBagTb) <15 then
            table.insert(vo.receivedCorpRedBagTb,corpRedBagTb)
        else
            local refreshTb = {}
            for i=2,15 do
                table.insert(refreshTb,vo.receivedCorpRedBagTb[i])
            end
            table.insert(refreshTb,corpRedBagTb)
            vo.receivedCorpRedBagTb = G_clone(refreshTb)
        end
        self:setIsNewCorpTbReceived(1)
    end
end

function acXssd2019VoApi:setIsNewCorpTbReceived(isNew)--设置是否有新的红包数据， 
    local vo = self:getAcVo()
    if vo and isNew then
        vo.isNewCorpTbReceived =isNew
    end
end
function acXssd2019VoApi:getIsNewCorpTbReceived( )
    local vo = self:getAcVo()
    if vo and vo.isNewCorpTbReceived then
        return vo.isNewCorpTbReceived
    end
    return 0
end

function acXssd2019VoApi:getRedBagTagbaseIdx()
    local vo = self:getAcVo()
    if vo and vo.redBagTagbaseIdx then
        return vo.redBagTagbaseIdx
    end
    return nil
end

--红包还有领取次数
function acXssd2019VoApi:canReceiveRedBag( ... )
    local vo =self:getAcVo()
    if vo and vo.secretState then
        if vo.secretState==0 then
            return true
        end
    end
    return false
end

function acXssd2019VoApi:getSecretState( )
    local vo = self:getAcVo()
    return vo.secretState or 0
end
function acXssd2019VoApi:setSecretStateToZero( )
    local vo = self:getAcVo()
    if vo then
        vo.secretState = 0
    end
end

function acXssd2019VoApi:getRedBag(redBagTag)--抢红包的接口
    local vo =self:getAcVo()
    local function getCallBack(fn,data )
        local ret,sData = base:checkServerData(data)
        if ret ==true and sData.data then
            if sData.data.xssd2019 then
                self:updateSpecialData(sData.data.xssd2019)
            end
            if sData.data.flag == 2 then--已领过
                self:setCurFlag(sData.data.flag)
                if redBagTag then
                    local dialog = smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("activity_xssd2019_tips3"),nil,950)
                    do return end
                else
                    self:showBlogDialog(sData.data.grablog)
                end
            elseif sData.data.flag == 1 then--领取成功：出动画
                self:setCurFlag(sData.data.flag)
                self:showGetRedBagAnimation( )
            elseif sData.data.flag == 4 then--红包领取记录
                self:setCurFlag(sData.data.flag)
                self:showBlogDialog(sData.data.grablog)
            else
                self:outTimeShowTip()
            end
        end
    end 
    if self:isCanEnter() then
        socketHelper:acXssd2019RedBag(vo.corpRedBagRecordTb.redid,getCallBack)
    else
        local dialog = smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("lv_not_enough"),nil,950)
    end
end

function acXssd2019VoApi:outTimeShowTip()-- 过期
    local dialog = smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("activity_xssd2019_redBagNotExist"),nil,950)
end

function acXssd2019VoApi:showGetRedBagAnimation( )--
    local function bgCallBack( ) end 
    local getRedBagBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),bgCallBack)
    getRedBagBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
    getRedBagBg:setPosition(getCenterPoint(sceneGame))
    getRedBagBg:setTouchPriority(-(10-1)*20-10)
    getRedBagBg:setOpacity(200)
    sceneGame:addChild(getRedBagBg,10);

    local function sureHandler()
         getRedBagBg:removeFromParentAndCleanup(true)

         local vo = self:getAcVo()
         local redDialog = smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("activity_xssd2019_tips2",{vo.corpRedBagRecordTb.sender}),nil,950)
    end


    local smallGetRedBagBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),sureHandler)
    smallGetRedBagBg:setContentSize(CCSizeMake(G_VisibleSizeWidth*0.24,G_VisibleSizeHeight*0.2))
    smallGetRedBagBg:setPosition(getCenterPoint(sceneGame))
    smallGetRedBagBg:setTouchPriority(-(10-1)*20-11)
    smallGetRedBagBg:setOpacity(0)
    getRedBagBg:addChild(smallGetRedBagBg,10);


    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",sureHandler,2,getlocal("ok"),25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(G_VisibleSizeWidth*0.5,80))
    sureMenu:setTouchPriority(-(10-1)*20-11);
    getRedBagBg:addChild(sureMenu)

    local guangSp = CCSprite:createWithSpriteFrameName("equipShine.png")
    guangSp:setPosition(getCenterPoint(getRedBagBg))
    guangSp:setScale(2.5)
    getRedBagBg:addChild(guangSp,1)

    local iconFuzi = "friendBtn.png"
    if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
        iconFuzi = "bless_getword.png"
    end
    local fuzi = CCSprite:createWithSpriteFrameName(iconFuzi)
    fuzi:setPosition(getCenterPoint(getRedBagBg))
    fuzi:setScale(2.2)
    getRedBagBg:addChild(fuzi,2)
    local time = 0.07
    local rotate1=CCRotateTo:create(time, 30)
    local rotate2=CCRotateTo:create(time, -30)
    local rotate3=CCRotateTo:create(time, 20)
    local rotate4=CCRotateTo:create(time, -20)
    local rotate5=CCRotateTo:create(time, 0)

    local delay=CCDelayTime:create(1)
    local acArr=CCArray:create()
    acArr:addObject(rotate1)
    acArr:addObject(rotate2)
    acArr:addObject(rotate3)
    acArr:addObject(rotate4)
    acArr:addObject(rotate5)
    acArr:addObject(delay)
    local seq=CCSequence:create(acArr)
    local repeatForever=CCRepeatForever:create(seq)
    fuzi:runAction(repeatForever)
end


function acXssd2019VoApi:setRedBagTagbaseIdx(idx,only)
    local vo = self:getAcVo()

    if vo and idx then
        if only then
            vo.redBagTagbaseIdx = idx
        else
            vo.redBagTagbaseIdx = vo.redBagTagbaseIdx +idx
        end
    end
end

function acXssd2019VoApi:setCurFlag(curFlag)
    local vo = self:getAcVo()
    if vo and curFlag then
        vo.curFlag = curFlag
    end
end

function acXssd2019VoApi:showBlogDialog(grablog)
    local vo =self:getAcVo()
    require "luascript/script/game/scene/gamedialog/activityAndNote/acXssd2019SmallDialog"
    local sender = vo.redBagRecordTb and vo.redBagRecordTb.sender or vo.corpRedBagRecordTb.sender
    local corpLimit = self:redEnvelopeLimit()
    local sd=acXssd2019SmallDialog:new(grablog,sender,corpLimit,"xssd2019")
    sd:init(10)
end

--------------------------------------------------------   抽   奖   --------------------------------------------------------
-- 活动中已抽奖总次数（后端返回）
function acXssd2019VoApi:lotterylreadyNum( )
    local vo = self:getAcVo()
    local lotterylreadyNum = 0
    if vo and vo.lotterylreadyNum then
        lotterylreadyNum = vo.lotterylreadyNum
    end
    return lotterylreadyNum
end

-- 每日金币抽奖次数
function acXssd2019VoApi:lotteryLimitNum( )
    local vo = self:getAcVo()
    local limitNum = 0
    if vo and vo.activeCfg then
        limitNum = vo.activeCfg.num
    end
    return limitNum
end

-- 可以几连抽
function acXssd2019VoApi:lotteryCount( )
    local vo = self:getAcVo()
    local count = 0
    if vo and vo.activeCfg then
        count = vo.activeCfg.count
    end
    return count
end

 --单次抽奖价格（前者为奖章数，后者为金币数）
function acXssd2019VoApi:lotteryCost( ... )
    local vo = self:getAcVo()
    local priceTb = {}
    if vo and vo.activeCfg then
        priceTb = vo.activeCfg.price
    end
    return priceTb
end

 --特殊次数奖励
function acXssd2019VoApi:specialLimit( ... )
    local vo = self:getAcVo()
    local specialLimit = 0
    if vo and vo.activeCfg then
        specialLimit = vo.activeCfg.sn
    end
    return specialLimit
end

--奖章数量
function acXssd2019VoApi:petalNum( ... )
    local vo = self:getAcVo()
    local petalNum = 0
    if vo then
        petalNum = vo.petalNum
    end
    return petalNum
end

--金币抽奖每日次数（后端）
function acXssd2019VoApi:goldLotteryNum( ... )
    local vo = self:getAcVo()
    local goldLotteryNum = 0
    if vo then
        goldLotteryNum = vo.goldLotteryNum
    end
    return goldLotteryNum
end
function acXssd2019VoApi:setGoldLotteryNumToZero( )
    local vo = self:getAcVo()
    if vo and vo.goldLotteryNum then
        vo.goldLotteryNum = 0
    end
end


--金币抽奖每日次数（配置）
function acXssd2019VoApi:goldLotteryNumCfg( ... )
    local vo = self:getAcVo()
    local goldLotteryNumCfg = 0
    if vo and vo.activeCfg then
        goldLotteryNumCfg = vo.activeCfg.num
    end
    return goldLotteryNumCfg
end

--金币抽奖有没有超次数
function acXssd2019VoApi:ifNumLimit( ... )
    local vo = self:getAcVo()
    local goldLotteryNumCfg = self:goldLotteryNumCfg()
    local goldLotteryNum = self:goldLotteryNum()
    if vo then
        if goldLotteryNum<goldLotteryNumCfg then
            return true
        end
    end
    return false
end

--是用奖章抽——1，还是金币抽——2,都不够——3,金币抽奖超次数——4 , 已结束--5
function acXssd2019VoApi:howToPayLeft( ... )
    local vo = self:getAcVo()
    local today,flag = self:getToday()
    local gold = playerVoApi:getGold()
    local petalNum = self:petalNum()
    local priceTb = self:lotteryCost()
    if priceTb then
        local num1 = priceTb[1]
        local num2 = priceTb[2]
        if flag~=2 then
            if petalNum>=num1 then
                return 1
            elseif self:ifNumLimit() then
                if gold>=num2 then
                    return 2
                else
                    return 4
                end
            else
                return 3
            end
        else
            return 5
        end
    end
    return 3
end

--是用奖章抽——1，还是金币抽——2,都不够——3,金币抽奖超次数——4 ，超过了8天——5
function acXssd2019VoApi:howToPayRight( ... )
    local vo = self:getAcVo()
    local today,flag = self:getToday()
    local gold = playerVoApi:getGold()
    local petalNum = self:petalNum()
    local priceTb = self:lotteryCost()
    local lotteryCount = self:lotteryCount( )
    if priceTb then
        if flag~=2 then
            local num1 = priceTb[1]
            local num2 = priceTb[2]
            if petalNum>=num1*lotteryCount then
                return 1
            elseif self:ifNumLimit() then
                if gold>=num2*lotteryCount then
                    return 2
                else
                    return 4
                end
            else
                return 3
            end
        else
            return 5
        end
    end
    return 3
end

-- 获取不重复的随机数
function acXssd2019VoApi:getRandom(num)
    if not num then
        num = 1
    end
    local resultArr = {}
    -- 9个抽奖位

    for i=1,num do
        local k = math.random(9-i+1)
        table.insert(resultArr,k)
    end
    for k,v in pairs(resultArr) do
        if k ~= #resultArr then
            if v == resultArr[k+1] then
                resultArr[k+1] = resultArr[k+1]+k 
                if resultArr[k+1]>9 then
                    resultArr[k+1] = resultArr[k+1]-k-1
                end
            end
        end
    end
    return resultArr
end

--箱特效
function acXssd2019VoApi:boxFlicker(parentBg,callback)
    if parentBg and parentBg:getChildByTag(10101) == nil then
        local pzFrameName="xssd2019_box_1.png"
        local metalSp=CCSprite:createWithSpriteFrameName(pzFrameName)
        metalSp:setScale(2)
        local pzArr=CCArray:create()
        for kk=1,9 do
            local nameStr="xssd2019_box_"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            pzArr:addObject(frame)
        end
        local blendFunc = ccBlendFunc:new()
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        metalSp:setBlendFunc(blendFunc)

        local animation=CCAnimation:createWithSpriteFrames(pzArr)
        animation:setDelayPerUnit(0.07)
        local animate=CCAnimate:create(animation)

        local acArr = CCArray:create()
        acArr:addObject(animate)
        acArr:addObject(CCCallFunc:create(callback))
        -- framePlayer:runAction(CCSequence:create(acArr))
        metalSp:setAnchorPoint(ccp(0.5,0.5))
        metalSp:setPosition(getCenterPoint(parentBg))
        metalSp:setTag(10101)

        parentBg:addChild(metalSp)
        local seq=CCSequence:create(acArr)
        metalSp:runAction(seq)
        return metalSp

    end
end

--框特效
function acXssd2019VoApi:frameFlicker(parentBg,callback)
    if parentBg and parentBg:getChildByTag(10101) == nil then
        local pzFrameName="xssd2019_kuang_1.png"
        local metalSp=CCSprite:createWithSpriteFrameName(pzFrameName)
        metalSp:setScale(2)
        local pzArr=CCArray:create()
        for kk=1,11 do
            local nameStr="xssd2019_kuang_"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            pzArr:addObject(frame)
        end
        local blendFunc = ccBlendFunc:new()
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        metalSp:setBlendFunc(blendFunc)

        local animation=CCAnimation:createWithSpriteFrames(pzArr)
        animation:setDelayPerUnit(0.07)
        local animate=CCAnimate:create(animation)

        local acArr = CCArray:create()
        acArr:addObject(animate)
        acArr:addObject(CCCallFunc:create(callback))
        -- framePlayer:runAction(CCSequence:create(acArr))
        metalSp:setAnchorPoint(ccp(0.5,0.5))
        metalSp:setPosition(getCenterPoint(parentBg))
        metalSp:setTag(10101)

        parentBg:addChild(metalSp)
        local seq=CCSequence:create(acArr)
        metalSp:runAction(seq)
        return metalSp

    end
end

--特殊奖励展示根据抽奖次数挪动个数
function acXssd2019VoApi:tableViewMoveNum(   )
    local externalRewardTb = self:externalRewardTb( )
    local alreadyNum = self:lotterylreadyNum()  -- 活动中抽奖次数总次数
    local cellNum = SizeOfTable(externalRewardTb)+1
    local finishNum = 0
    for k,v in pairs(externalRewardTb) do
        if v.time <= alreadyNum then
            finishNum = finishNum + 1
        end
    end
    if cellNum - finishNum < 5 then
        finishNum = cellNum - 5
    end
    return finishNum
end
--------------------------------------------------------   悬赏奖励   --------------------------------------------------------
--悬赏奖励倒计时
function acXssd2019VoApi:getTimeStr3( ... )
    local str = ""
    local vo = self:getAcVo()
    local today,flag = self:getToday()
    if vo and vo.activeCfg then
        local activeTime = vo.et - base.serverTime > 0 and G_formatActiveDate(vo.et - base.serverTime) or nil
        if activeTime == nil or flag==2 then
            activeTime = getlocal("serverwarteam_all_end")
        end
        return getlocal("acCD") .. ":"..activeTime
    end
    return str
end

--前面的特殊次数奖励配置
function acXssd2019VoApi:externalRewardTb( )
    local vo = self:getAcVo()
    local externalRewardTb = {}
    if vo and vo.activeCfg then
        externalRewardTb = vo.activeCfg.pool1
    end
    return externalRewardTb
end

--前面的特殊次数
function acXssd2019VoApi:externalRewardNum( i )
    local vo = self:getAcVo()
    local externalRewardNum = 0
    if vo and vo.activeCfg then
       local externalRewardTb = self:externalRewardTb( )
       externalRewardNum = externalRewardTb[i].time
    end
    return externalRewardNum
end

--前面的特殊次数奖励
function acXssd2019VoApi:externalReward( i )
    local vo = self:getAcVo()
    local externalReward = {}
    local externalRewardTb = self:externalRewardTb( )
    if vo and externalRewardTb then
       externalReward = externalRewardTb[i].reward
    end
    return externalReward
end

--后面的特殊次数奖励配置
function acXssd2019VoApi:externalRewardTb2( )
    local vo = self:getAcVo()
    local externalRewardTb = {}
    if vo and vo.activeCfg then
        externalRewardTb2 = vo.activeCfg.pool3
    end
    return externalRewardTb2
end

--后面的特殊次数
function acXssd2019VoApi:externalRewardNum2( i )
    local vo = self:getAcVo()
    local externalRewardNum2 = 0
    if vo and vo.activeCfg then
       local externalRewardTb2 = self:externalRewardTb2( )
       externalRewardNum2 = externalRewardTb2.time
    end
    return externalRewardNum2
end

--后面的特殊次数奖励
function acXssd2019VoApi:externalReward2( i )
    local vo = self:getAcVo()
    local externalReward2 = {}
    local externalRewardTb2 = self:externalRewardTb2( )
    if vo and externalRewardTb2 then
       externalReward2 = externalRewardTb2.reward
    end
    return externalReward2
end

--普通奖池奖励表
function acXssd2019VoApi:nomalPoolTb(  )
    local vo = self:getAcVo()
    local nomalPoolTb = {}
    if vo and vo.activeCfg then
       nomalPoolTb = vo.activeCfg.pool2
    end
    return FormatItem(nomalPoolTb,nil,true)
end

--------------------------------------------------------   密码破译   --------------------------------------------------------
--密码破译任务（配置）
function acXssd2019VoApi:secretTaskTb(  )
    local vo = self:getAcVo()
    local secretTaskTb = {}
    if vo and vo.activeCfg then
       secretTaskTb = vo.activeCfg.task3
    end
    return secretTaskTb
end

--密码破译任务数量（配置）
function acXssd2019VoApi:secretTaskNum(  )
    local vo = self:getAcVo()
    local secretTaskTb = self:secretTaskTb()
    return #secretTaskTb
end

--单个密码破译任务（配置）
function acXssd2019VoApi:secretTaskCfg( idx )
    local vo = self:getAcVo()
    local secretTaskTb = self:secretTaskTb()
    local secretTaskCfg = {}
    if secretTaskTb then
       secretTaskCfg = secretTaskTb[idx]
    end
    return secretTaskCfg.key,secretTaskCfg.num
end

--密码总个数（配置）
function acXssd2019VoApi:allSecretNumCfg(  )
    local vo = self:getAcVo()
    local allSecretNumCfg = 0
    if vo and vo.activeCfg then
       allSecretNumCfg = vo.activeCfg.keymax
    end
    return allSecretNumCfg
end

--神秘密码个数（配置）
function acXssd2019VoApi:secretNumCfg(  )
    local vo = self:getAcVo()
    local secretNumCfg = 0
    if vo and vo.activeCfg then
       secretNumCfg = vo.activeCfg.keyNum
    end
    return secretNumCfg
end

--破译奖励（配置）
function acXssd2019VoApi:secretRewardCfg( idx )
    local vo = self:getAcVo()
    local secretRewardCfg = {}
    if vo and vo.activeCfg then
       secretRewardCfg = vo.activeCfg.task3R1[idx].reward
    end
    return FormatItem(secretRewardCfg,nil,true)
end

--全部破译额外奖励（配置）
function acXssd2019VoApi:secretExternalCfg(  )
    local vo = self:getAcVo()
    local secretExternalCfg = {}
    if vo and vo.activeCfg then
       secretExternalCfg = vo.activeCfg.task3R2.reward
    end
    return FormatItem(secretExternalCfg,nil,true)
end

--神秘卡片数量
function acXssd2019VoApi:secretCardNum(  )
    local vo = self:getAcVo()
    local num = 0
    if vo and vo.secretCard and vo.secretCard["s"] then
        num = vo.secretCard["s"]
    end
    return num
end

--神秘卡片有没有全部领取到
function acXssd2019VoApi:haveAllsecretCard(  )
    local vo = self:getAcVo()
    local num = 0
    if vo and vo.secretCard and vo.secretCard["s"] and vo.activeCfg then
        num = vo.secretCard["s"]
        local cfgNum = vo.activeCfg.keyNum
        if cfgNum==num then
            return true
        end
    end
    return false
end

--普通卡片获取列表
function acXssd2019VoApi:nomalSecretCardTb(  )
    local vo = self:getAcVo()
    local nomalSecretCardTb = {}
    if vo and vo.secretCard and vo.secretCard["m"] then
        nomalSecretCardTb = vo.secretCard["m"]
    end
    return nomalSecretCardTb
end

--普通卡片该位置是否获取
function acXssd2019VoApi:haveCard( i )
    local vo = self:getAcVo()
    local nomalSecretCardTb = self:nomalSecretCardTb()
    if nomalSecretCardTb then
        for k,v in pairs(nomalSecretCardTb) do
            if v==i then
                return true
            end
        end
    end
    return false
end

--总共获得卡片的数量
function acXssd2019VoApi:cardNum( )
    local vo = self:getAcVo()
    local nomalSecretCardTb = self:nomalSecretCardTb()
    local num = self:secretCardNum()
    if nomalSecretCardTb then
        for k,v in pairs(nomalSecretCardTb) do
            num = num+1
        end
    end
    return num
end

--领取破译奖励列表
function acXssd2019VoApi:secretReward( ... )
    local vo = self:getAcVo()
    local secretReward = {}
    if vo and vo.secretReward then
        secretReward = vo.secretReward
    end
    return secretReward
end

--特殊奖励有没有领取  1：不可领取  2：可领取  3：已领取  4:已结束
function acXssd2019VoApi:hasExternalReward( )
    local vo = self:getAcVo()
    local today,flag = self:getToday()
    local allSecretNumCfg = self:allSecretNumCfg()
    local cardNum = self:cardNum()
    local secretReward = self:secretReward()
    if flag == 2 then
        return 4
    else
        if allSecretNumCfg~=0 then
            for k,v in pairs(secretReward) do
                if v == 0 then
                    return 3
                end
            end
            if allSecretNumCfg == cardNum then
                return 2
            end
        end
    end
    return 1
end

--普通奖励应该展示到第几个
function acXssd2019VoApi:canNomalShow( )
    local vo = self:getAcVo()
    -- local cardNum = self:cardNum()  --总共获得卡片的数量
    local secretReward = self:secretReward()
    local allSecretNumCfg = self:allSecretNumCfg()  --密码总个数（配置）
    local num = 0 --已经领取的数量
    for k,v in pairs(secretReward) do
        if v~=0 then
            num = num+1
        end
    end
    if num<allSecretNumCfg then
        return num+1
    end
    
    -- local num = 1
    -- for k,v in pairs(secretReward) do
    --     if v~=0 and num<allSecretNumCfg then
    --         num = num+1
    --     end
    -- end
    return num
end

--普通奖励有没有领取  1：不可领取  2：可领取  3：已领取  4:已结束
function acXssd2019VoApi:hasNomalReward( )
    local vo = self:getAcVo()
    local today,flag = self:getToday()
    local cardNum = self:cardNum()
    local secretReward = self:secretReward()
    local num = self:canNomalShow()
    -- print("cocococcooc",flag,cardNum,num)
    if flag == 2 then
        return 4
    else
        for k,v in pairs(secretReward) do
            if v == num then
                return 3
            end
        end
        if cardNum >= num then
            return 2
        end
        return 1
    end
end

--密码破译任务完成进度
function acXssd2019VoApi:secretTask( i )
    local vo = self:getAcVo()
    local str = "t"..i
    local alreadyNum = 0
    if vo and vo.secretTask and vo.secretTask[str] then
        alreadyNum = vo.secretTask[str]
    end
    return alreadyNum
end

--普通任务描述
function acXssd2019VoApi:nomalRewardDes( idx )
    local vo = self:getAcVo()
    local str = ""
    local key,num = self:secretTaskCfg(idx)
    local alreadyNum = self:secretTask(idx)
    local des
    if key and num then   
        local isfull = alreadyNum >= num and true or false
        str = G_getTaskWithDescLb(key,alreadyNum,num,isfull)   
    end
    return str
end

--普通任务是否破译
function acXssd2019VoApi:alreadySolution( idx )
    local vo = self:getAcVo()
    local key,num = self:secretTaskCfg(idx)
    local alreadyNum = self:secretTask(idx)
    if num then
        if alreadyNum>=num then
            return true
        end
    end
    return false
end

--------------------------------------------------------   发送后端请求   --------------------------------------------------------
--悬赏盛典本服、个人任务   1 本服奖励， 2 个人奖励， 3 任务积分奖励
function acXssd2019VoApi:socketXssd2019Task(act,tid,dw,refreshFunc)
    local function callBack(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
            local reward={}
            local rewardTb = {}
            if act == 1 then
                local day = self:getToday()
                -- print("day---dw---->>>",day,dw)
                rewardTb = self:allRewardShow( dw ,day )
            elseif act == 2 then
                rewardTb = self:selfRewardShow( tid )
            elseif act == 3 then
                rewardTb = self:recieveReward( )
            end
            if sData and sData.data and sData.data.xssd2019 then
                self:updateSpecialData(sData.data.xssd2019)
            end
            
            if rewardTb then
                local item=FormatItem(rewardTb)
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
    socketHelper:acXssd2019SocketTask(act,tid,dw,callBack)
end

--悬赏抽奖   pt : 1 奖章， 2 金币     num : 1 or 10
function acXssd2019VoApi:socketXssd2019Lottery(num,pt,refreshFunc)
    local function callBack(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
            if sData and sData.data and sData.data.xssd2019 then
                self:updateSpecialData(sData.data.xssd2019)
            end
            if pt == 2 then
                local lotteryCost = self:lotteryCost()
                playerVoApi:setGems(playerVoApi:getGems()-lotteryCost[2]*num)
            end

            local reward={}

            local hxReward
            if sData and sData.data and sData.data.reward then
                hxReward=self:getHexieReward()
                if hxReward then
                    hxReward.num=hxReward.num*num
                    table.insert(reward,1,hxReward)
                    G_addPlayerAward(hxReward.type,hxReward.key,hxReward.id,hxReward.num,nil,true)
                end
                for k,v in pairs(sData.data.reward) do
                    local item=FormatItem(v)
                    for i,j in pairs(item) do
                        table.insert(reward,j)
                        if v.type == "h" then
                            heroVoApi:addSoul(j.key,j.num)
                        else
                            G_addPlayerAward(j.type,j.key,j.id,j.num,nil,true)
                        end
                    end
                    
                end
            end
            if refreshFunc then
                refreshFunc(reward)
            end
        end
    end
    socketHelper:acXssd2019SocketLottery(num,pt,callBack)
end

function acXssd2019VoApi:getHexieReward()
    local acVo=self:getAcVo()
    if acVo and acVo.activeCfg then
        local hxcfg=acVo.activeCfg.hxcfg
        if hxcfg then
            return FormatItem(hxcfg.reward)[1]
        end
    end
    return nil
end

--格式化抽奖记录
function acXssd2019VoApi:formatLog(_data,addFlag)
    local lotteryLog={}
    for k,v in pairs(_data) do
        local data=v
        local num=data[1]
        -- if num==2 then
        --     num=10
        -- else
        --     num=1
        -- end
        local time=data[3] or base.serverTime
        local lcount=SizeOfTable(lotteryLog)
        if lcount>=30 then
            for i=30,lcount do
                table.remove(lotteryLog,i)
            end
        end

        -- local hxReward=self:getHexieReward()
        -- if hxReward then
        --     hxReward.num=hxReward.num*num
        --     table.insert(lotteryLog,1,hxReward)
        -- end

        for i,j in pairs(data[2]) do
            local rewardlist={}
            for k,v in pairs(j) do
                local reward=FormatItem(v,nil,true)
                table.insert(rewardlist,reward[1])
            end
            if SizeOfTable(rewardlist) > 0 then
                table.insert(lotteryLog,{num=num,reward=rewardlist,time=time,rewardType=i})
            end
        end
    end

    return lotteryLog
end

--悬赏抽奖日志
function acXssd2019VoApi:socketXssd2019GetLog( layerNum )
    local function callBack(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
            local _isShowTipsDialog=true
            if sData and sData.data and sData.data.xssd2019 then
                self:updateSpecialData(sData.data.xssd2019)
            end
            local reward={}
            if sData and sData.data and sData.data.log then
                local lotteryLog = self:formatLog(sData.data.log)
                if lotteryLog and SizeOfTable(lotteryLog)>0 then
                    local logList={}
                    for k,v in pairs(lotteryLog) do
                        local num,reward,time=v.num,v.reward,v.time
                        local title={getlocal("activity_fyss_lotteryLogDesc",{num})}
                        local content={{reward}}
                        if v.rewardType ~= "cr" then
                            title = {getlocal("activity_xssd2019_recordDes")}
                        end
                        local log={title=title,content=content,ts=time}
                        table.insert(logList,log)
                    end
                    local logNum=SizeOfTable(logList)
                    require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxSmallDialog"
                    acCjyxSmallDialog:showLogDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),{getlocal("activity_customLottery_RewardRecode"),G_ColorWhite},logList,false,layerNum+1,nil,true,30,true,true)
                    _isShowTipsDialog=nil
                end
            end
            if _isShowTipsDialog then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tccx_no_record"),30)
            end
        end
    end
    socketHelper:acXssd2019SocketGetLog(callBack)
end

--破译密码奖励   tid 奖励id  1 ~ 7  如果领取全部破译奖励 tid=0
function acXssd2019VoApi:socketXssd2019Decipher(tid,refreshFunc)
    local function callBack(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
            local rewardTb={}
            local reward={}
            if tid == 0 then
                rewardTb = self:secretExternalCfg(  )
            else
                rewardTb = self:secretRewardCfg( tid )
            end
            if sData and sData.data and sData.data.xssd2019 then
                self:updateSpecialData(sData.data.xssd2019)
            end
            
            if rewardTb then
                for k,v in pairs(rewardTb) do
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
    socketHelper:acXssd2019SocketDecipher(tid,callBack)
end

function acXssd2019VoApi:updateSpecialData(data)
    local vo = self:getAcVo()
    if vo then
        vo:updateSpecialData(data)
        activityVoApi:updateShowState(vo)
    end
end


function acXssd2019VoApi:addActivieIcon()
    spriteController:addPlist("public/activeCommonImage3.plist")
    spriteController:addTexture("public/activeCommonImage3.png")
end

function acXssd2019VoApi:removeActivieIcon()
    spriteController:removePlist("public/activeCommonImage3.plist")
    spriteController:removeTexture("public/activeCommonImage3.png")
end


function acXssd2019VoApi:getNewDataSocket(getNewData)
    local function callBack(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
            if sData and sData.data and sData.data.xssd2019 then
                self:updateSpecialData(sData.data.xssd2019)
            end
            if getNewData then
                getNewData()
            end
        end
    end
    socketHelper:acXssd2019GetData(callBack)
end
