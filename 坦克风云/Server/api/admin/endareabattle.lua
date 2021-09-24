function api_admin_endareabattle(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local fileName = "/opt/tankserver/service/tank-gameserver/log/endAreaBattle" .. getZoneId() .. "20160906.log"
    print(fileName);
    local f = io.open(fileName, "r")

    local data=nil
    if f then
    data=f:read("*a")
    print(data)
    data=data:split("|")
    data= json.decode(data[2])
    else
        return response
    end


    local mydata = {}
    for k, v in pairs( data ) do
        if k == 'content' or k == 'aslave' then
            mydata[k] = json.decode( v )
        else
            mydata[k] = v
        end
    end

    -- ptb:p(mydata)
    writeLog( mydata, 'repairareawar')

    local data = mydata
    if type(data)~='table' or not next(data) then
        response.ret=-102
        return response
    end

        local redis = getRedis()
        local weets = getWeeTs()
        local key = "z"..getZoneId()..".areaEndBattle."..weets
        local refret=redis:del(key)

    local ret=M_alliance.endareabattle(data)

    if ret then
        response.ret = 0
        response.msg = 'Success'
    end

    return response

end
