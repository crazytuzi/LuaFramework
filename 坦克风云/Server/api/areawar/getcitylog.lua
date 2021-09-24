-- 获取王城的记录

function api_areawar_getcitylog(request)
    local response = {
        ret=0,
        msg='Success',
        data = {},
    }
    local list=getAreaWarCity()
    response.data.list=list
    return response
end