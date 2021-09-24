--[[
    服内区域战，贡献列表
]]
function api_areawar_donatelist(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            areaWarserver={
                donateList={},
            },
        },
    }

    local uid = tonumber(request.uid)
    local aid = request.params.aid or 'all'
    local page = request.params.page or 1
    local over = request.params.over

    if  uid == nil then
        response.ret = -102
        return response
    end

    local mAreaWar = require "model.areawar"
    mAreaWar.construct()
    local bid = mAreaWar.getAreaWarId()
    
    local list = {}
    local donateList = mAreaWar.getUserDonate(bid)

    aid = tostring(aid)
    if donateList[aid] then
        local item = {}
        for k,v in pairs(donateList[aid]) do
            local uid = tonumber(k) or 0
            if uid > 0 then
                table.insert(item,{uid,v})
            end
        end

        table.sort(item,function(a,b) 
            if tonumber(a[2]) == tonumber(b[2]) then
                return tonumber(a[1]) < tonumber(b[1])
            else
                return tonumber(a[2]) > tonumber(b[2])
            end
        end)

        list = item
    end

    local myrank = 0
    for k,v in pairs(list) do
        if tonumber(v[1]) == uid then
            myrank = k
            break
        end 
    end

    local rtnList = {}
    local pagelimit = 20
    page = (page - 1) * pagelimit
    for i=1,pagelimit do
        local index = page+i
        if list[index] then
            table.insert(rtnList,list[index])
        end
    end

    for k,v in pairs(rtnList) do
        local uobjs = getUserObjs(v[1],true)
        local userinfo = uobjs.getModel('userinfo')
        rtnList[k][1]=userinfo.nickname
        rtnList[k][3]=userinfo.fc
    end 

    local myrows = {}
    if myrank > 0 then
        myrows=list[myrank]
        local uid = tonumber(myrows[1])
        if uid and #myrows == 2 then
            local uobjs = getUserObjs(uid,true)
            local userinfo = uobjs.getModel('userinfo')
            myrows[1]=userinfo.nickname
            myrows[3]=userinfo.fc
        end
        response.data.areaWarserver.myrank = myrank
        response.data.areaWarserver.myrows = myrows
    end
    
    response.data.areaWarserver.donateRows = #list
    response.data.areaWarserver.donateList = rtnList

    response.ret = 0
    response.msg = 'Success'

    return response
end
