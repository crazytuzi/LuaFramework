function api_admin_rebellist(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local action = request.params.action or 0
    local mRebel = loadModel("model.rebelforces")

    if action == 0 then

        local list = {}
        local page = request.params.page or 1
        local pageRows = 50
        local limit = (page - 1) * pageRows
        
        local sql = string.format("select id,x,y,protect,level from map where type = 7 and protect > '%s' limit %s,%s",getClientTs(),limit,pageRows)

        local db = getDbo()
        local result = db:getAllRows(sql)
        response.data.rebelMap = result
        response.data.hasNext = #result == pageRows and 1 or 0

    elseif action == 1 then
        local exp = tonumber(request.params.exp) or 0
        mRebel.setWorldExp(exp)
    end
    
    response.data.rebelExp = mRebel.getWorldExp()

    response.ret = 0
    response.msg = 'Success'

    return response
end