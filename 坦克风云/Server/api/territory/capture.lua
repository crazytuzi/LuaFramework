--
-- desc:捕获系统：
-- 玩法介绍：
-- 主要玩法，拥有领地的军团，统计击杀海盗部队的数量，由数量产生排名，获得不同奖励；（可做成一组活动）
-- 排行榜：
-- 军团击杀量排行：
-- 军团内个人击杀量排行：
--  参与限制：
-- 已军团为单位发布的活动，拥有军团领地的军团才可参与；
-- 以每天7天为一周期，统计前6天的击杀数量，第7天结算奖励；
-- 为领地仓库增加资源，个人获得公海币；
-- 军团奖励组成：
-- 全体奖励：凡当日发展值达到xx的玩家，可获得全体奖励，所有人奖励数量相同；
-- 奖励发放，每7天的6-22开放领奖，于该界面领取，过时未领，即不可领取；
--
function api_territory_capture(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local aid = request.params.aid
    local uid = request.uid

    if aid == nil or not uid then
        response.ret = -1988
        response.msg = 'params invalid'
        return response
    end    
  
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mAterritory = getModelObjs("aterritory",aid)

    if mUserinfo.alliance==0 or mUserinfo.alliance ~= aid then
        response.ret = - 102
        return response
    end

    local mAterritory = getModelObjs("aterritory",aid)
    response.list = mAterritory.killlist()
    response.ret = 0
    response.msg = 'Success'


    return response
end




