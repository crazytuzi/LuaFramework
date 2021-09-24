function api_admin_setserverbattle(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    
    
    require "model.serverbattle"
    local battleinfo = request.params
    local mServerbattle = model_serverbattle()
    local sevCfg={}
    if battleinfo.type==1 then
        sevCfg=getConfig("serverWarPersonalCfg")
    else
        sevCfg=getConfig("serverWarTeamCfg")
    end

    if battleinfo.type==3 then
        sevCfg=getConfig("worldWarCfg")
    end
    
   
    local ret = false

    
    -- type =1  是个人的 
    -- type =2  是军团跨服战
    -- type =3  是世界大战
    -- type =5  区域跨服战
    -- type =6  远洋征战

    -- 检测这个服有没有开启跨服战
    local info =mServerbattle.getserverbattlecfg(battleinfo.type)
    

    --修改旧的跨服战信息
    if battleinfo.id~=nil and battleinfo.id>0 then

        
        local oldbattleinfo = mServerbattle.serverbattlecfgByid(battleinfo.id)
        --ptb:e(oldbattleinfo)

        if next(oldbattleinfo) then

            --轮次和原来不一样了
            if battleinfo.round ~=tonumber(oldbattleinfo.round) then
                local round=(battleinfo.round-tonumber(oldbattleinfo.round))
                et=tonumber(oldbattleinfo.et)+(sevCfg.durationtime+tonumber(oldbattleinfo.gap))*round*24*3600
                battleinfo.et=et
            end

        else
            response.data.error ="id error"
            return response
        end
        --ptb:e(battleinfo)    
        ret = mServerbattle.setserverbattlecfg(battleinfo.id,battleinfo)

    else

         
        if next(info) then
            --正在有跨服战
            response.data.error="have server battle"
            return response
        end
        local st = tonumber(battleinfo.st)
        local gap=  tonumber(battleinfo.gap)
        local durationtime=sevCfg.durationtime
        local preparetime=sevCfg.preparetime
        local battleTime=sevCfg.battleTime
        local shoppingtime=sevCfg.shoppingtime
        local startBattleTs=sevCfg.startBattleTs
        local ts = getClientTs()
        --local weeTs = getWeeTs()

        if battleinfo.round <=0 then
            return response
        end
       
        
        -- 世界大战的发布
        local weeTs = getWeeTs(st)
        local et =weeTs
        if battleinfo.type==3 then
            et =et+((sevCfg.signuptime+sevCfg.pmatchdays+sevCfg.battletime+sevCfg.shoppingtime)*24*3600) 
            battleinfo.et = tonumber(et)
            battleinfo.st = weeTs
            ret = mServerbattle.createserverbattlecfg(battleinfo)
            if ret then 
                response.ret = 0
                response.msg = 'Success'
            end
            return response
        end





        
        if battleinfo.type==2 then
            et =et+((durationtime+gap+sevCfg.signuptime)*battleinfo.round-1)*24*3600+(preparetime*(battleinfo.round)*24*3600) 
        else
            et =et+(durationtime+gap)*battleinfo.round*24*3600+(preparetime*(battleinfo.round-1)*24*3600) 
        end
        local start =weeTs+(preparetime)*24*3600
        local count = 0
        local cronParams = {cmd ="cross.finalist",params={count=count,type=battleinfo.type}} 
        if battleinfo.type==2 then
            cronParams = {cmd ="across.finalist",params={count=count,type=battleinfo.type}}
        end
        local flag =true
        if not(setGameCron(cronParams,start-ts)) then
           
            local ret =setGameCron(cronParams,start-ts)
            if not ret then
                flag=false
                writeLog('finalist...1 setWrok error','setWrokerror')
                error("finalist...1 setWrok error")
            end
        end
        local winParams = {cmd ="cross.winmail",params={},} 
        if battleinfo.type==2 then
            winParams = {cmd ="across.winmail",params={count=count,type=battleinfo.type}}
        end

        local wintime=0
        if battleinfo.type==1 then
            wintime=start+battleTime*3+(durationtime-shoppingtime-1)*3600*24
            wintime=wintime+startBattleTs[1][1]*3600+startBattleTs[1][2]*60
            
            if not(setGameCron(winParams,wintime-ts)) then
                local ret=setGameCron(winParams,wintime-ts)
                if not ret then
                    flag=false
                    writeLog('awinParams...1 setWrok error','setwinerror')
                    error("winParams 1 setWrok error")
                end
            end
        end

        for i=1,battleinfo.round-1 do
            local time=start+(durationtime+gap+preparetime)*i*24*3600
            if battleinfo.type==2 then
                time=start+(durationtime+gap+preparetime+sevCfg.signuptime)*i*24*3600
            end
            --print(time)
            if not(setGameCron(cronParams,time-ts)) then
                local ret=setGameCron(cronParams,time-ts)
                if not ret then
                    writeLog("afinalist..."..(i+1).." setWrok error",'setWrokerror')
                    error("afinalist..."..(i+1).." setWrok error")
                end
            end
            -- 定时发邮件
            if battleinfo.type==1 then
                wintime=wintime+(durationtime+gap+preparetime)*i*24*3600
                if not(setGameCron(winParams,wintime-ts)) then
                    local ret=setGameCron(winParams,wintime-ts)
                    if not ret then
                        flag=false
                        error("winParams..."..(i+1).." setWrok error")
                    end
                end
            end
        end

        if not flag then
            response.data.error="set  work  error "
            return response
        end
        battleinfo.et = tonumber(et)
        battleinfo.st = weeTs
        ret = mServerbattle.createserverbattlecfg(battleinfo)
    end
    if ret then 

        
        require "model.matches"
        local mMatches = model_matches()
        mMatches.clearCache()
        response.ret = 0
        response.msg = 'Success'
    end
    return response

end