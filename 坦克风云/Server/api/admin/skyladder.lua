--
-- desc:天梯榜积分
-- user:chenyunhe
--
local function api_admin_skyladder(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },  
    }

    function self.action_get(request)
        local response = self.response
        local tab = request.params.tab
        local zid = request.params.zid or 0

        if not table.contains({1,2},tab) then
            response.ret = -102
            return response
        end

        -- 天梯榜状态
        require "model.skyladder"
        local skyladder = model_skyladder()
        local base = skyladder.getBase() 

        local bid = tonumber(base.cubid) or 0
        if bid<=0 then
            response.ret = -102
            return response
        end
       
        local tables = {"skyladder_personinfo","skyladder_allianceinfo"}
        local db = getCrossDbo("skyladderserver")
        local tname = tables[tab]

        local list = db:getAllRows("select id,name,(point1+point2+point3+point4) as score from "..tname.." where zid=" .. zid.." and bid="..bid)
        if not list then
            list = {}
        end
      
        response.data.list = list
        response.ret = 0
        response.msg = 'Success'
        
        return response
    end 

    return self  
end

return api_admin_skyladder