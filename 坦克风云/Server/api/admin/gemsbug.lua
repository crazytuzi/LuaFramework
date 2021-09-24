--建筑自动升级
function api_admin_gemsbug(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local userids = 
"| 2023686 |   6 |   50400 |"..
"| 2025805 |  36 |  302400 |"..
"| 2025955 |   8 |   67200 |"..
"| 2028500 |  32 |  268800 |"..
"| 2031466 |  14 |  117600 |"..
"| 2031960 |  27 |  226800 |"..
"| 2032014 |   9 |   75600 |"..
"| 2032504 |  10 |   84000 |"

    local uidTb = userids:split('|')
    ptb:p(uidTb)    

    --找到玩家，扣掉金币
    for k, vUid in pairs(uidTb) do 
        vUid = tonumber(vUid) or 0
        local zid = request.zoneid
        
        --
        if  math.floor( vUid/1000000 ) == zid then
            local uobjs = getUserObjs(vUid)
            uobjs.load({"userinfo"})
            if uobjs then
                local mUserinfo = uobjs.getModel('userinfo') 
                local nDeduct = uidTb[k+2] - (50 * uidTb[k+1])
                old_gems = mUserinfo.gems
                --扣掉钻石
                mUserinfo.gems = mUserinfo.gems - nDeduct
                if mUserinfo.gems < 0 then mUserinfo.gems = 0 end

                --重算 vip
                local old_vip = mUserinfo.vip
                mUserinfo.buygems = mUserinfo.buygems - nDeduct
                if mUserinfo.buygems < 460 then
                    mUserinfo.vippoint = 0 
                else 
                    if mUserinfo.vippoint > 1000 then
                        mUserinfo.vippoint = 1000
                    end
                end
                mUserinfo.vip = mUserinfo.updateVipLevel()
                if uobjs.save() then
                    print(vUid.. '  => gems  old - ' .. old_gems .. " new -  " .. mUserinfo.gems)
                    writeLog("|" .. vUid .. ' | ' .. old_gems .. " | " .. mUserinfo.gems .. "|", "gemsbug")
                    print('         --> vip  old : ' .. old_vip .. " new : " .. mUserinfo.vip)
                    writeLog("|" .. vUid .. ' | ' .. old_vip .. " | " .. mUserinfo.vip .. "|", "vipbug")
                    writeLog("|" .. vUid .. ' | ' .. mUserinfo.nickname, 'id2name')
                end

            end --change data  30366

        end        

    end 

    response.ret = 1

    return response
end
