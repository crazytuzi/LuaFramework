-- 获取事件

function api_skyladder_gethistory(request)
    -- body
    local response = {
        ret=0,
        msg='Success',
        data = {},
    }

    if moduleIsEnabled('ladder') == 0 then
        response.ret = -19000
        return response
    end
    
    local uid = request.uid
    local page = tonumber(request.params.page) or 1
	local limit = tonumber(request.params.limit) or 20
	local start = (page - 1) * limit
    
    if uid == nil then
        response.ret = -102
        response.msg = 'params invalid'
        return response
    end

    -- 天梯榜状态
    require "model.skyladder"
    local skyladder = model_skyladder()
    local data,count=skyladder.getAllHistory(start,limit)
    
    local list = {p={},a={}}

    if data and type(data) == 'table' then
        for i,v in pairs(data) do
            if type(v.info) ~= 'table' then
                v.info = json.decode(v.info) or {}
            end
            
            local itemP = {
                id = v.id,
                bid = v.bid,
                t = v.updated_at
            }
            
            local itemA = {
                id = v.id,
                bid = v.bid,
                t = v.updated_at
            }
            
            if v.info.p and type(v.info.p) == 'table' and next(v.info.p) then
                itemP.info = v.info.p
                table.insert(list.p,itemP)
            end
            
            if v.info.a and type(v.info.a) == 'table' and next(v.info.a) then
                itemA.info = v.info.a
                table.insert(list.a,itemA)
            end

        end
    end
    
    
    response.data.ladder = {list=list,count=count,page=page} 
    return response

end