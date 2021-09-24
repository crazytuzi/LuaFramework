--
-- desc:玩家任务
-- user:chenyunhe
--
local function api_admin_tasks(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
    }

    function self.action_add(request)
        local response = self.response
        local uid = request.uid
        local tid = request.params.tid

        if not uid or not tid then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"task"})
        local mTask = uobjs.getModel('task')
        local cfg = getConfig("task")

        if not cfg[tid] then
            response.ret = -120
            return response
        end

        mTask.unlock(tid,cfg)
        if uobjs.save() then
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
            response.msg = 'Fail'
        end
       
        return response
    end 

   
    return self  
end

return api_admin_tasks