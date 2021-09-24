-- 在本地中执行多人逻辑lua API
do
    print("\n\n------------lua cmd:",os.time(),tostring(arg[1]),"----------\n")

    if #arg >= 2 then
        package.path = arg[2] .. "/../?.lua;" .. package.path

        -- override
        function sendMsgByUid() end

        require "dispatch"

        local request=json.decode(arg[1])
        local secret = request.secret
        local zoneid = request.zoneid

        local getRankingCmd = json.encode{
            cmd="boss.book.rankingList",
            zoneid=zoneid,
            secret=secret,
        }

        local result = dispatch(getRankingCmd)
        result=json.decode(tostring(result))

        ptb:p(result)

        if type(result) == "table" and result.data and result.data.ranklist then
            local takeRewardCmd={
                uid=nil,
                cmd="boss.reward",
                params={
                    rank=0,
                    autoAttack=1,
                },
                zoneid=zoneid,
                secret=secret,
            }

            local uids = {}
            local function takeReward(uid,rank)
                if uid and uid > 0 and not uids[uid] then
                    uids[uid]=true
                    takeRewardCmd.uid=uid
                    takeRewardCmd.params.rank = rank or 0
                    return dispatch(json.encode(takeRewardCmd))
                end
            end

            for k,v in pairs(result.data.ranklist) do
                if type(v) == "table" and v[1] then
                    local ret = takeReward(tonumber(v[1]),k)
                    -- print(ret)
                end
            end
        end
    else
        print("params invalid")
    end
end