-- 定时脚本执行保存下一幸运榜的的人

function api_military_update(request)
    local response = {
            ret=-1,
            msg='error',
            data = {userarena={}},
        }
    
    if moduleIsEnabled('military')  == 0 then
        response.ret = -10000
        return response
    end


    local rankey = request.params.rankey
    local redis = getRedis()


    local dndate = redis:get(rankey)
    local arenaNpcCfg = {}
    local dnlist= json.decode(dndate)
    --ptb:p(dnlist)
    if  type(dnlist[1])~='table' then
        
       
        local ranks=copyTab(dnlist)
        
        dnlist={}
        for  k,rank in pairs (ranks) do
              local  item  = {}
              local muid= tonumber( getArenaUidByRank(rank))
              if muid>1000000 then
                    local userinfo = mUserinfo
                    if muid~=uid then
                        local uobjs = getUserObjs(muid,true)
                        userinfo = uobjs.getModel('userinfo')
                    end
                    item={rank,muid,userinfo.nickname}
                    table.insert(dnlist,item) 
               else
                 if not next(arenaNpcCfg) then
                        arenaNpcCfg = getConfig('arenaNpcCfg')
                    end
                    local sid='s'..muid
                    if arenaNpcCfg[sid] then

                        item={rank,muid,arenaNpcCfg[sid].name}
                        table.insert(dnlist,item)
                    end

               end
             
        end
        

        
        local data = json.encode(dnlist)
        local reuslt = redis:set(rankey,data)
        redis:expire(rankey,432000)  
       
    end



    response.ret = 0
    response.msg = 'Success'
    return  response

end