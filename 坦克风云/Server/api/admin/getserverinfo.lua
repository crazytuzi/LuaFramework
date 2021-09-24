function api_admin_getserverinfo(request)
      local response = {
            ret=-1,
            msg='error',
            data = {},
        }

    local s = tostring(request.params.model)
    local db = getDbo()
    local result={}
    local lvl = request.params.lvl
    local c   = tonumber(request.params.count) or 200 
    local filed = request.params.filed
    local  st =tonumber(request.params.st)
    local  et =tonumber(request.params.et)
    local resdate=tonumber(request.params.resdate) or 0
    local method =request.params.type
    local plat=request.params.plat
    local day=request.params.day 
    if s == 'buildings' then
        result = db:getAllRows("select count(tb.blv) as c ,tb.blv  from (select     substring_index(substring_index(b1,',',-1),']',1)  as blv   from buildings ) as tb where blv>=:lvl  group by tb.blv ;",{lvl=lvl})
    elseif s =='userinfo' then
        if filed=='mc' then
          
          if plat~=nil  then
            result = db:getAllRows("SELECT count( uid ) as c , vip as blv FROM userinfo WHERE mc != '{}' and vip >=:lvl and email like '%"..plat.."%' GROUP BY vip",{lvl=lvl})
          else
            result = db:getAllRows("SELECT count( uid ) as c , vip as blv FROM userinfo WHERE mc != '{}' and vip >=:lvl GROUP BY vip",{lvl=lvl})
          end
          
        elseif filed=='gems' then
           
            
            local tmp =0
            if plat~=nil  then
                result = db:getAllRows("SELECT uid as c ,gems as blv FROM userinfo where email  like '%"..plat.."%'  GROUP BY gems DESC limit "..c)
               tmp= db:getRow("SELECT sum(gems) as gems FROM userinfo" )
            else
               result = db:getAllRows("SELECT uid as c ,gems as blv FROM userinfo  GROUP BY gems DESC limit "..c)
               tmp= db:getRow("SELECT sum(gems) as gems FROM userinfo" )
            end
            
            response.data.gems=tmp.gems

        elseif filed=='level' and method~=1   then
            local minlevel=request.params.minlevel
            local maxlevel=request.params.maxlevel
            if plat~=nil  then
                result = db:getAllRows("select count(*) as c,"..filed.." as blv from userinfo where "..filed..">=:minlevel  and "..filed.."<=:maxlevel   and logindate>=:st and logindate<=:et  and regdate>=:resdate  and email like '%"..plat.."%' group by "..filed ,{minlevel=minlevel,maxlevel=maxlevel,st=st,et=et,resdate=resdate})
            else
                result = db:getAllRows("select count(*) as c,"..filed.." as blv from userinfo where "..filed..">=:minlevel  and "..filed.."<=:maxlevel   and logindate>=:st and logindate<=:et  and regdate>=:resdate group by "..filed ,{minlevel=minlevel,maxlevel=maxlevel,st=st,et=et,resdate=resdate})
            end
            
            
        elseif filed=='rank'   then 
            local rank=request.params.rank
            if plat~=nil  then
                result = db:getAllRows("select count(*) as c,"..filed.." as blv from userinfo where "..filed..">=:rank  and logindate>=:st and logindate<=:et  and regdate>=:resdate and email like '%"..plat.."%'  group by "..filed ,{rank=rank,st=st,et=et,resdate=resdate})
            else
                result = db:getAllRows("select count(*) as c,"..filed.." as blv from userinfo where "..filed..">=:rank  and logindate>=:st and logindate<=:et  and regdate>=:resdate   group by "..filed ,{rank=rank,st=st,et=et,resdate=resdate})
            end
            
        else
            if plat~=nil  then
                result = db:getAllRows("select count(*) as c,"..filed.." as blv from userinfo where "..filed..">=:lvl  and email like '%"..plat.."%' group by "..filed ,{lvl=lvl})
            else
                result = db:getAllRows("select count(*) as c,"..filed.." as blv from userinfo where "..filed..">=:lvl  group by "..filed ,{lvl=lvl})
                if result and day~=nil and day>0 and filed=="vip" then
                    local logindata=getClientTs()-day*86400
                    for uk,vv in pairs(result) do
                        local vip=vv.blv 
                        local tmp=db:getRow("SELECT count(uid) as count  FROM userinfo   where   vip=:vip and logindate<=:logindata",{logindata=logindata,vip=vip} )
                        result[uk]['o']=0
                        if tmp then
                            result[uk]['o']=tonumber(tmp.count)
                        end
                    end
                end
            end

        end


    elseif s=='boss' then
        local redis = getRedis()
        local weet =st or  getWeeTs()
        local levelkey= "zid."..getZoneId().."worldboss.level.ts."..weet
        local killtime   = "zid."..getZoneId().."worldboss.lastkill.ts"
        local userkillkey= "zid."..getZoneId().."worldboss.userkill.ts."..weet
        result['blevel']=redis:get(levelkey)
        result['kiilltime']=redis:get(killtime)
        result['rank']=redis:get(userkillkey)
    end 

    response.data.result = result
    response.ret = 0
    response.msg = 'Success'
    
    return response

end