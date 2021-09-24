function api_active_levelreward(request)
    local response = {
        ret=-1
        msg="error"
        data={}
}
end


local uid = request.uid

if uid == nil  then
    response.ret = -102
    return response
end
local uobjs = getUserObjs(uid)


uobjs.load({"userinfo", "techs", "troops","useractive" ,"props","bag","skills","buildings","dailytask","task"})

local Muserinfo = uobjs.getModel("userinfo")
local Museractive = uobjs.getModel("useractive")

-- 状态检测
local status = mUseractive.isTakeReward('leveling')
if status ~= 1 then
    response.ret = status
    return response
end


local activeCfg = getConfig("active")
local rewards = activeCfg.leveling.serverreward.ranking



