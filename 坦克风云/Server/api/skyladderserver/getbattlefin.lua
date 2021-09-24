-- 读取该bid大战是否已结算
function api_skyladderserver_getbattlefin(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local cubid = tonumber(request.params.cubid)
    local btype = tonumber(request.params.btype)
    local battleid = request.params.battleid

    if not cubid or not btype or not battleid then
        response.ret = -102
        return response
    end

    require "model.skyladderserver"
    local skyladderserver = model_skyladderserver()
    local base = skyladderserver.getStatus()
    local bid
    if btype == 1 then
        bid = battleid..'_1'
    elseif btype == 5 then
        bid = 'b'..battleid
    else
        bid = 'b'..battleid
    end
    local have = skyladderserver.getUpdataStatus('account.'..btype,cubid,bid)
    
    if not have and btype == 2 then
        bid = 'b'..battleid..1
        have = skyladderserver.getUpdataStatus('account.'..btype,cubid,bid)
    end
    
    response.ret = 0
    response.msg = 'Success'
    response.data.status = have

    return response
end