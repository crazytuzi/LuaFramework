-- 获取排行榜
-- 先取缓存然后读数据库如果在没有就去npc读吧
function api_military_ranklist(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            userarena={},
        },
    }
    -- 军事演习功能关闭
    
    if moduleIsEnabled('military')  == 0 then
        response.ret = -10000
        return response
    end
    local arenaNpcCfg = {}
    local list = {}
    local ranklist =getArenaRanking()
    local len=#ranklist
    if not next(ranklist) or len<100 then
        -- 去数据库找找前100名
        ranklist=getArenaRankingtoMysql()
        arenaNpcCfg = getConfig('arenaNpcCfg')
        if not next(ranklist) then
            local start =0
            for k,v in pairs(arenaNpcCfg) do
                start=start+1
                setArenaRanking(start,start)  
        end

        --如果没有去npc找100凑数
        ranklist =getArenaRanking()
        end

    end
    local len=#ranklist
    if len<100 then
        for i=1,100 do
            local flag = true
            if next(ranklist) then
                for k,v in pairs(ranklist) do
                    if tonumber(v[2])==i then
                        flag=false
                    end
                end
            end
           
            if(flag) then
                setArenaRanking(i,i) 
            end
        end
        ranklist =getArenaRanking()
    end

    for i=1,100 do

        local item = {}
        if type (ranklist[i])=="table" then 
             local uid =ranklist[i][1]
             if uid ==nil then
                uid =tonumber(i)
             else
                uid =tonumber(ranklist[i][1])
             end
             if uid >1000000 then
                local uobjs = getUserObjs(uid,true)
                local userinfo = uobjs.getModel('userinfo')
                item={uid,userinfo.nickname,userinfo.level,userinfo.fc}
                table.insert(list,item)
             else
                if not next(arenaNpcCfg) then
                    arenaNpcCfg = getConfig('arenaNpcCfg')
                end


                local sid='s'..i
                item={uid,arenaNpcCfg[sid].name,arenaNpcCfg[sid].level,arenaNpcCfg[sid].Fighting}
                table.insert(list,item)
             end
        else
            if not next(arenaNpcCfg) then
                    arenaNpcCfg = getConfig('arenaNpcCfg')
            end
            local sid='s'..i
            item={i,arenaNpcCfg[sid].name,arenaNpcCfg[sid].level,arenaNpcCfg[sid].Fighting} 
            table.insert(list,item)
        end 

    end
    --ptb:e(ranklist)
    
    response.ret=0
    response.msg = 'Success'
    response.data.userarena.ranklist=list

    return  response
end