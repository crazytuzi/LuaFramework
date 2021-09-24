local function api_troop_msgpush(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }

    function self.action_invade(request)
        local response = self.response

        if request.params.uid then
            local msg = {data={},cmd="msg.event"}
            msg.data.event = request.params.event
            sendMsgByUid(request.params.uid,json.encode(msg))
        end

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    return self
end

return api_troop_msgpush