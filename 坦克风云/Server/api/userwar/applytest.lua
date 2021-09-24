-- 测试报名异元战场

function api_userwar_applytest(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid   = request.uid
    local hero  = request.params.hero or {}
    local fleet = request.params.fleetinfo or {}
    local date  = getWeeTs()
    local ts = getClientTs()
    local userwarnew = require "model.userwarnew"
    local userWarCfg=getConfig("userWarCfg")
    local warId = userwarnew.getWarId()
    local opts = userwarnew.getWarOpenTs()
    
    if not  userwarnew.isEnable() then
        response.ret = -4002
        return response
    end
    local db = getDbo()
    local result = db:getRow("select * from userwar where bid="..warId)
    if type(result)=='table' then
        for i=1,300 do
            result['uid']=tonumber(997000100)+i
            result['name']=result['uid']
            local mapx,mapy = userwarnew.getPlace()
            local lid = mapx..'-'..mapy
            userwarnew.setLandUser(warId,lid,result['uid'])
            result['mapx']=mapx
            result['mapy']=mapy
            local ret=db:insert("userwar",result)
            userwarnew.setApplyNum(warId,1)
            print(ret)
        end
    end

    response.ret = 0        
    response.msg = 'Success'



    return response
end