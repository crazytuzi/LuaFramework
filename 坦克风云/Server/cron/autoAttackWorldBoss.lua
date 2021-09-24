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

        local getQueueCmd = json.encode{
            cmd="boss.book.getQueue",
            zoneid=zoneid,
            secret=secret,
        }

        local result = dispatch(getQueueCmd)
        result=json.decode(tostring(result))

        if type(result) == "table" and result.data and result.data.queue then
            local attackBossCmd={
                uid=nil,
                cmd="boss.battle",
                params={
                    autoAttack=1,
                    reborn=0,
                },
                zoneid=zoneid,
                secret=secret,
            }

            local uids = {}
            local function autoAttack(uid)
                if uid and uid > 0 and not uids[uid] then
                    uids[uid]=true
                    attackBossCmd.uid=uid
                    return dispatch(json.encode(attackBossCmd))
                end
            end

            for k,v in pairs(result.data.queue) do
                local ret = autoAttack(tonumber(k))
                -- print(ret)
            end
        end
    else
        print("params invalid")
    end
end
