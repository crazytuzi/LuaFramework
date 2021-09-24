--
--GM后台推送接口
--
function api_admin_pushMsg(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local self = {}
    --今天未上线的用户推送
    function self.pushMsgByOnline(content)
        -- body
        return M_push.adminPushMsg({admin=1, content=content})
    end

    --等级筛选推送
    function self.pushMsgByLevel(level, content)
        -- body
        if not level then return false end
        return M_push.adminPushMsg({level=level, content=content})
    end
    
    --------------------main------------------------
    local action =  tonumber(request.params.action)
    local level = tonumber(request.params.level)
    local content = request.params.content

    local execRet, code
    if action==1 then
       execRet, code = self.pushMsgByOnline(content)
    elseif action==2 then
        execRet, code = self.pushMsgByLevel(level, content)
    end

    if execRet then
        response.ret = 0
        response.data["count"] = execRet.data["nCount"]
        response.msg = "success"
    end

    return response
end
