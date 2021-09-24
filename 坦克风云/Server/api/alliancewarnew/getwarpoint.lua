-- 获取军团战积分，并结算
-- 留拍的情况
    -- 1、在确定双方军团参战之后（即发送成功邮件）再设置结算定时
    -- 2、双方报名成功后，如果有一方退出军团，结算定时会跑？？？
function api_alliancewarnew_getwarpoint(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            alliancewar = {}
        },
    }

    -- 军团战功能关闭
    if moduleIsEnabled('alliancewarnew') == 0 then
        response.ret = -4012
        return response
    end

    local positionId = tonumber(request.params.positionId) -- 战场

    if positionId == nil then
        response.ret = -102
        return response
    end
    
    local mAllianceWar = require "model.alliancewarnew"
    local warId = mAllianceWar.getWarId(positionId)

    -- 已经结算
    if mAllianceWar.getOverBattleFlag(warId) then
        response.ret = 0
        response.msg = 'Success'
        response.data.isover = "getOverBattleFlag true"
        return response
    end

    -- 凌晨与当前时间
    local weets = getWeeTs()
    local ts = getClientTs()
    local allianceWarCfg = getConfig('allianceWar2Cfg')

    local overFlag = false    -- 结束标志

    local warOpenStatus = mAllianceWar.getWarOpenStatus(positionId,warId)
    if warOpenStatus ~= 0 then
         if warOpenStatus == -4011 then
            overFlag = true
        else
            response.ret = warOpenStatus
            return response
        end
    end
    
    -- 战斗开始时需要检测是否流拍,并发公告
    if mAllianceWar.isStart(warId) ~= 1 then
        local queueInfo, code = M_alliance.getbattleflag{
            position=positionId,
            date=weets,
            warId=warId,
            alliancewar=1,
        }

        mAllianceWar.writeLog({
            ret=queueInfo or "not queueInfo",
            code=code or "not code",
            msg='M_alliance.getbattleflag',
        })

        local isStart = true
        if not queueInfo then
            isStart = -1
        elseif table.length(queueInfo.data) == 1 then
            isStart = false
            mAllianceWar.sendWinReward(queueInfo.data[1].aid,warId,positionId,0)

            local cityType = allianceWarCfg.city[positionId].type

            -- 结算时的配置
            local endCfg = {
                mvpDonate=allianceWarCfg.mvpDonate,
                winDonate=allianceWarCfg.winDonate,
                failDonate=allianceWarCfg.failDonate,
                winExp=allianceWarCfg.winExp[cityType],
                failExp=allianceWarCfg.failExp[cityType],
            }

            local endBattleParams = {
                point=json.encode({1,0}),
                position=positionId,
                warId=warId,
                config=json.encode(endCfg),
                buffDonate=json.encode({}),
                date=weets,
            }

            -- 发送结算请求
            local endBattleRet,endBattleCode = M_alliance.endbattle(endBattleParams)

            local endbattleLog = {
                ret=endBattleRet,
                code=endBattleCode,
                msg='M_alliance.endbattle',
                params=endBattleParams,
            }

            mAllianceWar.writeLog(endbattleLog)
        
			-- 16.9.28号优化(奖励发放单拎出来走另一个接口)
        	M_alliance.endbattleuser(endBattleParams)

            -- 所有成员发邮件
            if queueInfo.data[1] and type(queueInfo.data[1].members) == 'table' then
                --[[
                    胜利 11
                    我方军团名 aName
                    战斗结束时间 et
                    战斗区id   positionId
                ]]
                local content = {
                    type=10,                            
                    et = ts,
                    posId=positionId,
                    aName = queueInfo.data[1].name,
                    alliancewarnew=1,
                }

                for _,n in pairs(queueInfo.data[1].members) do
                    local mid = tonumber(n.uid)
                    if mid then
                        MAIL:mailSent(mid,1,mid,'',n.name,10,content,1,0)
                    end
                end
            end
        end

        if not isStart then
            mAllianceWar.setOverBattleFlag(warId)
            if type(queueInfo) == 'table' then
            	mAllianceWar.sendMsg(4,{positionId,queueInfo.data[1].name,86400})
            else
                mAllianceWar.writeLog({"queueinfo is nil ... ", positionId, warId,os.time()})
            end

            response.ret = 0
            response.msg = 'Success'
            response.data.alliancewar.isover = 1
            return response
        end

        if isStart == -1 then
            mAllianceWar.delStartFlag(warId)
            return response
        end

        if queueInfo.data and queueInfo.data[1] and queueInfo.data[2] then            
            mAllianceWar.sendMsg(1,{queueInfo.data[1].name,queueInfo.data[2].name,positionId})
        end
    end

    local placePoint,allPlaceInfo = mAllianceWar.getAllPlacePoint(positionId,warId)
    local positionPoint = mAllianceWar.getPositionPoints(warId)

    local point = {0,0}  

    for k,v in pairs(point) do 
        point[k] = point[k] + (placePoint[k] or 0) + (positionPoint[k] or 0)

        if point[k] >= allianceWarCfg.winPointMax then
            overFlag = true
        end
    end

    -- test
    mAllianceWar.writeLog({warId,overFlag,point,os.time()})

    -- 结算 -------------------------------------------------------------------------------

    local lockFlag 
    if overFlag then 
        lockFlag = commonLock(warId,"allianceWarlock")
        mAllianceWar.writeLog({"commonLock",warId,lockFlag})
    end

    if overFlag and lockFlag then
        -- 结算时检测结算状态
        local endStats,endCode = M_alliance.getbattlestatus{warId=warId,date=weets,position=positionId}
        mAllianceWar.writeLog({"M_alliance.getbattlestatus",warId,endStats,endCode})

        if not endStats then
            response.ret = 0
            response.msg = 'Success'
            response.data.alliancewar.isover = 1
            response.endStats = endStats
            response.endCode = endCode
            return response
        end

        -- 结束时仍在据点中的玩家需要生成战报
        local allPlaceLog = mAllianceWar.getAllPlaceLog(positionId,allPlaceInfo,warId)
        local addlogRet,addlogCode = true,-1
        local addLog = {"M_alliance.addbattlelog:",positionId}

        if type(allPlaceLog) == 'table' and next(allPlaceLog) then
            local logStr = json.encode(allPlaceLog)
            addlogRet, addlogCode = M_alliance.addbattlelog({method=2,date=weets,data=logStr})
            addLog[3] = allPlaceLog
            addLog[4] = addlogRet
            addLog[5] = addlogCode      
        end

        -- 结算仍在据点中的玩家log
        mAllianceWar.writeLog(addLog)

        -- 报名队列信息（红蓝双方）
        local queueInfo,endBattleFlag

        -- 没有判断addlogRet是否为true,有可能军团那边执行慢,返回数据超时,lua这边反复执行会有问题

        queueInfo = M_alliance.getwarmembers{position=positionId,date=weets} 

        -- buff 对应的 donate
        local buffDonate = {}
        for k,v in pairs(queueInfo.data or {}) do
            if type(v.members) == 'table' then
                for _,n in pairs(v.members) do
                    local mid = tonumber(n.uid)
                    if mid then                            
                        local memUobjs = getUserObjs(mid,true)
                        local memUserAllianceWar = memUobjs.getModel('useralliancewar')
                        for bid,blv in pairs (memUserAllianceWar.getBattleBuff() or {}) do
                            if blv > 0 then
                                local buffUid = tostring(n.uid)
                                buffDonate[buffUid] = (buffDonate[buffUid] or 0) + allianceWarCfg.buffSkill[bid].donate * blv
                            end
                        end                            
                    end
                end
            end
        end

        local cityType = allianceWarCfg.city[positionId].type

        -- 结算时的配置
        local endCfg = {
            mvpDonate=allianceWarCfg.mvpDonate,
            winDonate=allianceWarCfg.winDonate,
            failDonate=allianceWarCfg.failDonate,
            winExp=allianceWarCfg.winExp[cityType],
            failExp=allianceWarCfg.failExp[cityType],
        }

        local endBattleParams = {
            point=json.encode(point),
            position=positionId,
            warId=warId,
            config=json.encode(endCfg),
            buffDonate=json.encode(buffDonate),
            date=weets,
        }

        -- 发送结算请求
        local endBattleRet,endBattleCode = M_alliance.endbattle(endBattleParams)  
        if tonumber(endBattleCode) == -9527 then
            response.ret = 0
            response.msg = 'Success'
            response.data.alliancewar.isover = 1
            return response
        end

        local endbattleLog = {
            ret=endBattleRet,
            code=endBattleCode,
            msg='M_alliance.endbattle',
            params={
                point=point,
                position=positionId,
                warId=warId,
            },
        }

        local redMvp,blueMvp = "",""

        if type(endBattleRet) == 'table' and type(endBattleRet.data) == 'table' then
            redMvp = endBattleRet.data.redMvp or ""
            blueMvp = endBattleRet.data.blueMvp or ""
        end

        mAllianceWar.writeLog(endbattleLog)

        -- 16.9.28号优化(奖励发放单拎出来走另一个接口)
        M_alliance.endbattleuser(endBattleParams)

        -- 如果结算成功,发邮件,推公告,只搞一次，军团结算慢,有可能无返回，这里写死直接结算
        -- if endBattleRet then endBattleFlag = true end
        endBattleFlag = true  

        if endBattleFlag then
            if point[1] >= point[2] then
                if queueInfo.data[1] and queueInfo.data[1].aid then
                    mAllianceWar.sendWinReward(queueInfo.data[1].aid,warId,positionId,1)
                end
            else
                if queueInfo.data[2] and queueInfo.data[2].aid then
                    mAllianceWar.sendWinReward(queueInfo.data[2].aid,warId,positionId,1)
                end
            end

            mAllianceWar.sendTaskReward(warId,positionId)
            mAllianceWar.setOverBattleFlag(warId)

            -- push -------------------------------------------------
            local pushCmd = 'alliancewarnew.over.push'
            local pushData = {}

            -- 胜利信息，value值是邮件的标题类型
            local winInfo = {}
            winInfo[1] = point[1] >= point[2] and 10 or 11
            winInfo[2] = winInfo[1] == 10 and 11 or 10
            local mailFalg=false
            for label,v in pairs(queueInfo.data or {} ) do
                if queueInfo.data[2]~=nil then
                    if not next(queueInfo.data[2].members) then
                        mailFalg=true
                    end
                else
                    mailFalg=true
                end 
                if queueInfo.data[1]~=nil then
                    if not next(queueInfo.data[1].members) then
                        mailFalg=true
                    end
                else
                    mailFalg=true
                end
                if type(v.members) == 'table' then
                    for _,n in pairs(v.members) do
                        local mid = tonumber(n.uid)
                            if mid then
                            -- mail ------------
                            --[[
                                胜利 10
                                失败 11
                                我方军团名 aName
                                地方军团名 eName
                                战斗结束时间 et
                                战斗区id   positionId
                            ]]
                            
                            local content = {
                                type=winInfo[label],                            
                                et = ts,
                                posId=positionId,
                                alliancewarnew=1,
                            }

                            content.aName = queueInfo.data[label].name
                            if label == 1 then
                                content.eName = queueInfo.data[2].name 
                            else
                                content.eName = queueInfo.data[1].name 
                            end                
                            
                            --mailSent(uid,sender,receiver,mail_from,mail_to,subject,content,mail_type,isRead)
                            if mailFalg then
                                MAIL:mailSent(mid,1,mid,'',n.name,34,{type=34},1,0)
                            else
                                MAIL:mailSent(mid,1,mid,'',n.name,winInfo[label],content,1,0)
                            end
                            
                            -- push ---------
                            regSendMsg(mid,pushCmd,pushData)
                        end
                    end
                end
            end
            -- push -------------------------------------------------

            -- 结算公告,param":["红色军团名字","蓝色军团名字","战场索引","获胜军团名字","资源增产Buff持续时间"]
            if queueInfo.data[1] and queueInfo.data[2] then
                if not mailFalg then
                    mAllianceWar.sendMsg(2,{queueInfo.data[1].name,queueInfo.data[2].name,positionId,(winInfo[1]==10 and queueInfo.data[1].name or queueInfo.data[2].name), 86400,redMvp,blueMvp})
                end
            end
        end
          
    end

    -- push -------------------------------------------------
    local pushCmd = 'alliancewarnew.battle.push'
    local pushData = {
        alliancewar = {
            positionInfo = {point=point}
        }
    }

    local allUsers = mAllianceWar.getAllianceWarUsers(warId)
    if type(allUsers) == 'table' then
        for _,uid in pairs(allUsers) do
            local mid = tonumber(uid)
            regSendMsg(mid,pushCmd,pushData)
        end
    end
    -- push -------------------------------------------------

    response.ret = 0
    response.msg = 'Success'
    
    return response
end

