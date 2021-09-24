-- 排行榜
function api_userwar_ranklist(request)
     local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid   = request.uid
    local status  =request.params.status or 0
    
    if moduleIsEnabled('userwar') == 0 then
        response.ret = -4012
        return response
    end

    local userwarnew = require "model.userwarnew"
    local bid =tonumber(userwarnew.getWarId())
    local opts = userwarnew.getWarOpenTs()

    if not  userwarnew.isEnable() then
        bid=bid-1
    end
    local ackey="userwar.rank"..bid.."status"..status    
    local data={}
    function setApiFuncRanking(uid,score,round,activeName,maxLenth)
        if not score or not activeName or not uid then
            return false
        end
        local redis = getRedis()
        local result
        local key = "z"..getZoneId()..".rank."..activeName
        local ts = getClientTs()

        local tmp={}
        if round>=1 then
            tmp={uid,round,score}
        else
            tmp={uid,score,ts}
        end
        if type(data) ~= 'table' then
            data = {tmp}
        else     
            local inRank = false

            for k,v in ipairs(data) do
                if type(v) == 'table' then
                    if v[1] == uid then
                        data[k] = tmp
                        inRank = true
                        break
                    end
                end
            end

            if not inRank then
                table.insert(data,tmp)
            end

            local rankLength = #data
            local maxLenth = maxLenth or  10
            local delStart = maxLenth + 1

            table.sort(data,function(a,b)
                    if type(a) == 'table' and type(b) == 'table' then

                        if round<=0 then
                            if tonumber(a[2]) > tonumber(b[2]) then
                                return true
                            elseif tonumber(a[2]) == tonumber(b[2]) then
                                return tonumber(a[3]) < tonumber(b[3])
                            end
                        else
                            if tonumber(a[2]) > tonumber(b[2]) then
                                return true
                            elseif tonumber(a[2]) == tonumber(b[2]) then
                                return tonumber(a[3]) > tonumber(b[3])
                            end
                        end
                    end
                end)

            if  rankLength > maxLenth then
                for i=delStart,rankLength do
                    table.remove(data,delStart)
                end
            end
        end
        local ranklist=json.encode(data)
        local result = redis:set(key,ranklist)
        redis:expire(key,432000)

        return ranklist
    end
    
    local ranklist = getFuncRanking(ackey)
    if ranklist==nil then
        local db = getDbo()
 
        local result={}
        if status==0 then
            result = db:getAllRows("select uid,round1,point1  from userwar where  round1>0  and bid=:bid  ",{bid=bid})    
        else
            result = db:getAllRows("select uid,point2  from userwar where  point2>0  and bid=:bid  ",{bid=bid})    
        end
        if  type(result)=='table' and next(result) then
            for k,v in pairs(result) do
                local round=0
                local score=0
                if status==0 then
                    round=tonumber(v.round1)
                    score=tonumber(v.point1)
                else
                    score=tonumber(v.point2)        
                end
                ranklist=setApiFuncRanking(v.uid,score,round,ackey,100)
            end
        end

    end



    local list={}
    if type(ranklist)=='table' and next(ranklist) then
        for k,v in pairs(ranklist) do
            local mid= tonumber(v[1])
            local muobjs = getUserObjs(mid,true)
            muobjs.load({"userinfo", "techs", "troops", "props","bag","skills","hero",'useractive',"alien"})
            local tmUserinfo = muobjs.getModel('userinfo')
            local tmp
            if status==0 then
                tmp={mid,tmUserinfo.nickname,tmUserinfo.fc,v[3],v[2]}
            else
                tmp={mid,tmUserinfo.nickname,tmUserinfo.fc,v[2]}
            end
            table.insert(list,tmp)
        end
    end

    response.ret = 0
    response.msg = 'Success'
    response.data.ranklist=list

    return response
end