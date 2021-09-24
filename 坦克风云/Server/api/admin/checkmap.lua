--登陆统计
function api_admin_checkmap(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local self = {}
    function self.checkAll(isUpdate)
        local ts = getClientTs() - 12*30*86400
        local result = getDbo():getAllRows("select uid, mapx, mapy, nickname, fc, rank, protect, pic, alliancename from userinfo where logindate>:ts and mapx>0 and mapy>0", {ts=ts})
        
        local mMap = require "lib.map"

        local ret = {}
        for _, mUserinfo in pairs(result) do            
            local mid = getMidByPos(mUserinfo.mapx,mUserinfo.mapy)
            local landInfo = mMap:getMapById(mid)
            
            local p = {}
            if landInfo.rank ~= mUserinfo.rank  then
                p.rank =mUserinfo.rank
                print('rank' ,mUserinfo.uid, mUserinfo.rank, landInfo.rank)
            end
            if landInfo.protect ~= mUserinfo.protect  then
                p.protect =mUserinfo.protect
                print('protect', mUserinfo.uid, mUserinfo.protect, landInfo.protect)
            end
            if landInfo.pic ~= mUserinfo.pic  then
                -- p.pic =mUserinfo.pic
                -- print('pic', mUserinfo.uid, mUserinfo.pic, landInfo.pic)
            end
            if landInfo.alliance ~= mUserinfo.alliancename  then
                p.alliance =mUserinfo.alliancename
                print('aname' ,mUserinfo.uid, mUserinfo.alliancename, landInfo.alliance)
            end

            if next(p) then
                if 1 == isUpdate then
                    if mMap:update(mid,p) then
                        p.mid =mid
                        table.insert(ret, p)
                    end
                else
                    p.mid = mid
                    table.insert(ret, p)
                end
            end

        end        

        return ret
    end

    local update = request.params.update
    response.data.result = self.checkAll(update)
    response.data.cnt = #response.data.result
    response.msg = 'Success'
    response.ret = 0

    return response
end
