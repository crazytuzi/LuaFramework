function api_admin_getzzbp(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    require "model.zzbp"
    local zzbp = model_zzbp()
    local  flag,cfg = zzbp.check()

    local db = getDbo()
    local result = db:getRow("select sum(`score`) as total from zzbpuser")
    local sscore = 0
    if type(result) =='table' then
        sscore = result.total
    end 

    local firstserver = getzzbpfirstserver(cfg)
    local zzbpdata = {
        groupid = tonumber(cfg.groupid),
        zones = json.decode(cfg.zones),
        st = tonumber(cfg.st),
        et = tonumber(cfg.et),
        fserver = firstserver.zid,
        sscore = tonumber(sscore) or 0
    }

    response.ret = 0
    response.msg = 'success'
    response.data.zzbp = zzbpdata 

    return response

end