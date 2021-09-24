function api_admin_areabattledata(request)
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
        if k == 'aid' or k == 'donateList' then
            mydata[k] = v
        end
    end

    response.ret = 0
    response.msg = 'Success'
    response.data.d = mydata

    return response

end
