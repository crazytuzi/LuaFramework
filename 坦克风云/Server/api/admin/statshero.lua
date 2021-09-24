--建筑自动升级
function api_admin_statshero(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local self = {}
    function self.search()
        local db = getDbo()        
        local result = db:getAllRows("select userinfo.uid uid, hero from hero LEFT JOIN userinfo on hero.uid=userinfo.uid where level>3 and tutorial>=10")

        if not result then
            return false
        end

        local alluids = {}
        for k, v in pairs(result) do
            v.hero = json.decode(v.hero)
            for kk, vv in pairs(v.hero) do
                if vv[3] and vv[3] >=4 then
                    table.insert(alluids, v.uid)
                    break
                end
            end

        end

        return alluids
    end

    local retUid = self.search()

    response.data.uids = retUid
    response.data.count = #retUid
    response.ret = 0

    return response
end
