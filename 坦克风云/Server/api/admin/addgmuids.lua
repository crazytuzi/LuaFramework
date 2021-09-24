--添加gmuid 
--liming
function api_admin_addgmuids(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local zoneid = request.zoneid
    local uids = request.params.uids
    local method = tonumber(request.params.method)
    -- 要入库操作
    local data=getFreeData("GM-chat")
    local chat={}

    if data==nil then
        chat={}
    else
       chat=data.info
       if type(chat)~="table" then
            chat={}
       end   
    end

    if type(uids)=='table' and  next(uids) then
        if method==1 then --添加聊天gm人员的uid
            for k,v in pairs(uids) do
                if not table.contains(chat, v) then
                    local uobjs = getUserObjs(v,true)
                    local mUserinfo = uobjs.getModel('userinfo')

                    if not string.find(mUserinfo.nickname,"GM") then
                        local name = "GM-"..mUserinfo.nickname
                        -- ptb:e(name)
                        renameGM(v,name)
                           table.insert(chat,v)
                            local msg = {
                                    sender = "",
                                    reciver = "",
                                    channel = 1,
                                    sendername = "",
                                    recivername = "",
                                    content = {
                                        type = 50,
                                        ts = getClientTs(),
                                        contentType = 4,
                                        params = {
                                            uid = v,
                                        },
                                    },
                                    type = "chat",
                                }
                            sendMessage(msg)
                    end
                end
            end
        elseif method==2 then  --删除人员
            for k,v in pairs(uids) do
                for uk,uid in pairs (chat) do
                    if tonumber(uid)==tonumber(v) then
                        local uobjs = getUserObjs(v,true)
                        local mUserinfo = uobjs.getModel('userinfo')
                        local tmpname = string.split(mUserinfo.nickname,"-")
                        local name = tmpname[#tmpname]
                           renameGM(v,name)
                           table.remove(chat,uk)
                           local msg = {
                                    sender = "",
                                    reciver = "",
                                    channel = 1,
                                    sendername = "",
                                    recivername = "",
                                    content = {
                                        type = 51,
                                        ts = getClientTs(),
                                        contentType = 4,
                                        params = {
                                            uid = v,
                                        },
                                    },
                                    type = "chat",
                                }
                            sendMessage(msg)
                    end
                end
            end
        end
        setFreeData("GM-chat",json.encode(chat))
    end
    if method==3 then
        local user={}
        for k,uid  in pairs(chat) do
            local uobjs = getUserObjs(uid,true)
            local mUserinfo = uobjs.getModel('userinfo')
            table.insert(user,{uid,mUserinfo.nickname})
        end
        response.data.user=user
    end
    local key="z"..getZoneId()..".free.GM-chat"
    local redis = getRedis()
    redis:del(key)
    response.ret = 0        
    response.msg = 'Success'
    return response

end