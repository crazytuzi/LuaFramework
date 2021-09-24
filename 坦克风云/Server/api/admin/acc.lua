--建筑自动升级
function api_admin_acc(request)
    local response = {
        ret=-1,
        msg='error',
        data = {uids={}},
    }
    local hit = {"a67", "a71", "a75", "a79", "a83", "a87", "a91", "a95"}
    local self = {}
    function self.in_arry( keyAcc )
        -- body
        for k, value in pairs(hit) do
            if keyAcc == value then
                return true
            end
        end

        return false
    end

    local db = getDbo()        
    uids = db:getAllRows("select uid from userinfo where buygems>150 and vip>0")

    local retUid = {}
    for k, v in pairs(uids) do 

        local uobjs = getUserObjs(tonumber(v.uid))
        uobjs.load({"accessory"})
        local mAcc = uobjs.getModel('accessory')

        for key, vAcc in pairs(mAcc.info) do 
            if self.in_arry(vAcc[1]) then
                table.insert(retUid, v.uid)
                break
            end
        end

        for key, vAcc in pairs(mAcc.used) do
            for tk, tv in pairs(vAcc) do 
                if self.in_arry(tv[1]) then
                    table.insert(retUid, v.uid)
                    break
                end
            end

        end

    end        

    response.data.uids = retUid
    response.data.count = #retUid
    response.ret = 1

    return response
end
