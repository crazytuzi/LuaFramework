-- desc: 将领装备
-- user: liming
local function api_admin_generalequip(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
    }
    -- 查看玩家将领装备信息
    function self.action_view(request)
        local response = self.response
        local uid = tonumber(request.uid) or userGetUidByNickname(self.nickname) or 0
        if uid < 1 then
            response.ret = -102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","equip"})
        local mEquip = uobjs.getModel('equip')
        response.data.equip = mEquip.toArray(true) or {}
        response.ret = 0
        response.msg = 'success'
        return response
    end

    -- 修改e1,e2,e3
    function self.action_alertexp(request)
        local response = self.response
        local uid = tonumber(request.uid) or userGetUidByNickname(self.nickname) or 0
        local e1 = request.params.e1
        local e2 = request.params.e2
        local e3 = request.params.e3
        if uid < 1  then
            response.ret = -102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"equip"})
        local mEquip = uobjs.getModel('equip')
        mEquip.e1 = mEquip.e1 + e1
        mEquip.e2 = mEquip.e2 + e2
        mEquip.e3 = mEquip.e3 + e3

        if mEquip.e1<0 then
            mEquip.e1 = 0
        end

        if mEquip.e2<0 then
            mEquip.e2 = 0
        end

        if mEquip.e3<0 then
            mEquip.e3 = 0
        end

        if not uobjs.save() then
            response.ret = -1
            return response
        end
   
        response.msg = 'success'
        response.ret = 0
        return response
    end

    --修改将领等级
    function self.action_alertlv(request)
        local response = self.response
        local uid = tonumber(request.uid) or userGetUidByNickname(self.nickname) or 0
        local h = request.params.h
        if uid < 1  then
            response.ret = -102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"equip"})
        local mEquip = uobjs.getModel('equip')
        local info = mEquip.info
        for k,v in pairs(h) do
            for k1,v1 in pairs(info) do
                if k == k1 then
                    info[k] = v
                end
            end
        end
        -- ptb:e(info)
        

        if not uobjs.save() then
            response.ret = -1
            return response
        end
   
        response.msg = 'success'
        response.ret = 0
        return response
    end

    return self
end

return api_admin_generalequip
