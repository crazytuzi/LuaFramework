-- 火线名将的10条记录
function api_active_huoxianmingjianggailog(request)
    local aname = 'huoxianmingjianggai'

    local response = {
        ret=0,
        msg='Success',
        data = {
            [aname] = {},
        },
    }

    local uid = request.uid


    if uid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","hero",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mHero = uobjs.getModel('hero')

    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end


    local redis =getRedis()
    local redkey ="zid."..getZoneId().."huoxianmingjianggai."..mUseractive.info[aname].st.."uid."..uid
    local data =redis:get(redkey)
    data =json.decode(data)

    if type(data)=='table' then
        for k,v in pairs(data) do
            v[1]=formatReward(v[1])
            data[k]=v
        end

        response.data.log=data
    end 


    return response

end