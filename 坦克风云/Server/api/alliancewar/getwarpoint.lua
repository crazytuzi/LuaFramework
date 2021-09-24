-- 获取军团战积分，并结算
-- 留拍的情况
    -- 1、在确定双方军团参战之后（即发送成功邮件）再设置结算定时
    -- 2、双方报名成功后，如果有一方退出军团，结算定时会跑？？？
function api_alliancewar_getwarpoint(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            alliancewar = {}
        },
    }

    -- 军团战功能关闭
    if moduleIsEnabled('alliancewar') == 0 then
        response.ret = -4012
        return response
    end

    local uid = tonumber(request.uid)
    local positionId = tonumber(request.params.positionId) -- 战场    
    local cron = request.secret    -- 系统调用，计算定时值

    -- 如果noFirst不等于1，表示是第一次调用，检测一下有没有流拍，如果有流拍，则不需要继续走cron
    local noFirst = tonumber(request.params.noFirst)  

    -- 修复结算的标识
    local warId = tonumber(request.params.warId)    -- 战场id
    local repair = request.params.repair

    if positionId == nil then
        response.ret = -102
        return response
    end
    
    local mAllianceWar = require "model.alliancewar"

    -- 凌晨与当前时间
    local weets = getWeeTs()
    local ts = getClientTs()

    local warId = warId or mAllianceWar:getWarId(positionId)
    if not warId then
        response.ret = -4002
        return response
    end

    local overFlag = false    -- 结束标志

    local warOpenStatus = mAllianceWar:getWarOpenStatus(positionId,warId)
    if warOpenStatus ~= 0 then
         if warOpenStatus == -4011 then
            overFlag = true
        else
            response.ret = warOpenStatus
            return response
        end
    end
    
    if noFirst ~= 1 and cron then
        local queueInfo, code = M_alliance.getbattleflag{
            position=positionId,
            date=weets,
            warId=warId
        }        

        if not queueInfo then
            response.ret = 0
            response.msg = 'Success'
            response.data.alliancewar.isover = 1
            
            return response
        end

        if queueInfo.data and queueInfo.data[1] and queueInfo.data[2] then            
            mAllianceWar:sendMsg(1,{queueInfo.data[1],queueInfo.data[2],positionId})
        end
    end

    local allianceWarCfg = getConfig('allianceWarCfg')
    local placePoint,allPlaceInfo = mAllianceWar:getAllPlacePoint(positionId,(cron or overFlag))
    local positionPoint = mAllianceWar:getPositionPoints(positionId)

    local point = {0,0}  

    for k,v in pairs(point) do 
        point[k] = point[k] + (placePoint[k] or 0) + (positionPoint[k] or 0)

        if point[k] >= allianceWarCfg.winPointMax then
            overFlag = true
        end
    end

    -- 结算 -------------------------------------------------------------------------------

    if overFlag and commonLock(warId,"allianceWarlock") then
        -- 结算时检测结算状态
        local endStats,endCode = M_alliance.getbattlestatus{warId=warId,date=weets,position=positionId}
        if not endStats then
            response.ret = 0
            response.msg = 'Success'
            response.data.alliancewar.isover = 1

            return response
        end

        -- 结束时仍在据点中的玩家需要生成战报
        local allPlaceLog = mAllianceWar:getAllPlaceLog(positionId,allPlaceInfo,warId)
        local addlogRet,addlogCode = true,-1
        local addLog

        if type(allPlaceLog) == 'table' and next(allPlaceLog) then
            local logStr = json.encode(allPlaceLog)
            addlogRet, addlogCode = M_alliance.addbattlelog({method = 2,date=weets,data=logStr})
            addLog = "positionId:" .. positionId .. "| over :" .. logStr            
        else
            addLog = "positionId:" .. positionId .. "| over not log"        
        end

        -- 记下Log,数据丢失的时候用
        addLog = addLog .. '|repair:' .. (repair or 'not repair')
        mAllianceWar:writeLog(addLog)

        -- 报名队列信息（红蓝双方）
        local queueInfo,endBattleFlag

        -- 如果战报发送成功,结算
        -- addlogRet = true -- 有时候，军团那边已经把log加上了，但是返回数据时超时了，导致Lua这边认为没有加上，会反复执行
        if not addlogRet then
            mAllianceWar:writeLog({code=code,msg='addbattlelog faild',params={method = 2,date=weets,data=allPlaceLog}})
        end
        -- else
        if true then
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

            -- 结算时的配置
            local endCfg = {
                mvpDonate=allianceWarCfg.mvpDonate,
                winDonate=allianceWarCfg.winDonate,
                failDonate=allianceWarCfg.failDonate,
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

            if not endBattleRet then
                -- 失败的log
                local endBattleFailedLog = {
                    code=endBattleCode,
                    msg='endbattle faild',
                    params={
                        point=point,
                        position=positionId,
                        warId=warId,
                    },
                }

                mAllianceWar:writeLog(endBattleFailedLog)

                -- 如果结算失败，OverFlag为false，会继续给worker发送信息
                overFlag = false
            else
                -- 结算记个log
                local endBattleFailedLog = {
                    code=endBattleCode,
                    msg='endbattle OK',
                    params={
                        point=point,
                        position=positionId,
                        warId=warId,
                    },
                }

                mAllianceWar:writeLog(endBattleFailedLog)

                endBattleFlag = true
            end
        end

        -- 如果结算成功，清除所有缓存数据
        endBattleFlag = true  -- 只搞一次，军团那边有时候结算成功，但是卡住了，无返回
        if endBattleFlag then

            mAllianceWar:clearPosition(positionId,warId)

            -- push -------------------------------------------------
            local pushCmd = 'alliancewar.over.push'
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
                            if not repair then
                                regSendMsg(mid,pushCmd,pushData)
                            end
                        end
                    end
                end
            end
            -- push -------------------------------------------------

            -- param":["红色军团名字","蓝色军团名字","战场索引","获胜军团名字","资源增产Buff持续时间"]
            if queueInfo.data[1] and queueInfo.data[2] then
                if not mailFalg then
                    mAllianceWar:sendMsg(2,{queueInfo.data[1].name,queueInfo.data[2].name,positionId,(winInfo[1]==10 and queueInfo.data[1].name or queueInfo.data[2].name), 86400})
                end
            end
        end        
          
    end

    response.data.alliancewar.positionInfo = {}
    response.data.alliancewar.positionInfo.point = point

    -- 如果是系统调用(继续注册)
    if cron and not overFlag then
        local cronParams = {cmd = request.cmd,params={positionId=positionId,noFirst=1}}
        if setGameCron(cronParams,10) then
            response.ret = 0
            response.msg = 'Success'
        end
    else
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
