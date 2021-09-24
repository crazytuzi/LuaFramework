function api_admin_test(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
        uid = 0,
    }

    self.nickname = request.nickname or 0
    self.uid = tonumber(request.uid) or userGetUidByNickname(self.nickname) or 0
    self.action = tonumber(request.action)
    self.request = request

    if self.uid < 1 or self.request == nil then
        self.response.ret = -102
        return response
    end

    -- 获取用户数据
    if self.action == 1003 then
        local uobjs = getUserObjs(self.uid)
        mUserinfo = uobjs.getModel('userinfo')
        mUserinfo.flags = {            
            event = {},            
            daily_award = 0,
            daily_lottery = {d1={ts=0,num=0},d2={ts=0,num=0}},
            daily_honors = 0,
            daily_buy_energy={ts=0,num=0},
            newuser_7d_award = {0,0,0,0,0,0,0},
            feeds_award = {ts=0,num=0},
        }

        if uobjs.save() then
            self.response.ret=0
            self.response.msg="Success"
        end
    end

    return self.response
end
