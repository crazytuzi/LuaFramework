--
-- 流失统计
-- guohaojie
-- 
local function api_admin_getlossinfo(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
    }
    -- 发布
    function self.action_set(request)
        local response = self.response
        if type(request.params)~='table' then
            response.ret = -102
            return response
        end

        local day =request.params.day
        local  st =request.params.st
        local page = request.params.page

        local begin = 100*(page-1)
        local num =100
        if st < 0 or day < 0  or page< 0 then
            response.ret = -102
            return response
        end

        local  ts= getClientTs() - day*24*60*60    --当前时间
       
        local level =request.params.level

        local db = getDbo()
        local loss = {}
        local loginfo = {}
        local buyinfo = {}
        for i=1,12 do
            local vv = i
            local res = db:getAllRows("select  count(case when vip= :v then vip else null end) as vnum,count(case when vip= :v and buyts< :t then vip else null end) as vlost , count(case when buygems >0 then buygems else null end) as bnum , count(case when buygems >0 and logindate < :t then buygems else null end) as blost from userinfo  where logindate <:t and vip=:v  and level >= :startl and level <= :endl",{v=vv,t=ts,startl=level[1],endl=level[2]})           
                table.insert(loss,res)
            local lg = db:getAllRows("select uid,nickname,level,vip,buyts,logindate from userinfo where logindate <:t and vip=:v  and level >= :startl and level <= :endl limit :pg , :n",{v=vv,t=ts,startl=level[1],endl=level[2],pg=begin,n=num})
            if lg~=false and next(lg)  then
                table.insert(loginfo,lg)
            end
            local by = db:getAllRows("select uid,nickname,level,vip,buyts,logindate from userinfo where buyts <:t and buygems >0 and vip=:v and level >= :startl and level <= :endl limit :pg , :n",{v=vv,t=ts,startl=level[1],endl=level[2],pg=begin,n=num})
            if by~=false and next(by) then
                table.insert(loginfo,by)
            end
        end
        local result = {}
        result.loss=loss
        result.lg=loginfo
        -- result.by=buyinfo

        if result ~=nil then
            ret =true
        end


        if ret then 
            response.data =result
            response.ret = 0
            response.msg = 'Success'
        end
        return response

    end

    
   
    return self
end

return api_admin_getlossinfo