-- ALTER TABLE `alliance_members` ADD COLUMN `auth` TINYINT NOT NULL DEFAULT '0' COMMENT '权限' AFTER `oc`;

local function api_alliance_set(request)
    local self = {
        response = {
            ret = -1,
            msg = 'error',
            data = {},
        },
    }
    
    function self.getRules()
        return {
            -- required 表示参数是必需的,必需放在table的第1位
            -- _uid 表示取request.uid 而不是request.params.uid
            ["*"] = {
                _uid = { "required" }
            },

            ["action_setAuth"] = {
                aid = { "required","number" },
                memuid = { "required","number" },
                auth = { "required","number" },
                value = { "required","number" },
            },
            
        }
    end
    
    function self.before(request)
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        if uobjs.getModel('userinfo').alliance <= 0 then
            response.ret = -8023
            return response
        end
    end
        
    function self.action_setAuth(request)
        local response = self.response
        local aid = tonumber(request.params.aid)
        local memuid = tonumber(request.params.memuid)
        local auth = tonumber(request.params.auth)
        local value = tonumber(request.params.value) or 0

        local uid = request.uid
        if uid == nil or aid == nil or auth == nil then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel('userinfo')

        if mUserinfo.alliance ~= aid then
            response.ret = -8023
            return response
        end

        local execRet, code = M_alliance.setMemberAuth{uid=uid,auth=auth,mid=memuid,value=value}
        if not execRet then
            response.ret = code
            return response
        end

        -- push -------------------------------------------------
        regSendMsg(memuid,'alliance.memupdate',{
            alliance = {
                alliance={
                    members = {
                        {uid=memuid,auth=value}
                    }
                }
            }
        })
        -- push -------------------------------------------------
        
        response.ret = 0
        response.msg = 'Success'
        
        return response
    end

    return self
end

return api_alliance_set	