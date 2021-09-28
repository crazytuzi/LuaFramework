local PomeloUtil = {}

function PomeloUtil.wrapRequest(pomeloRequest, successCb, failCb, ...)
    local function responese(ex, sjson)
        if ex then
            if failCb then failCb() end
        else
            successCb(sjson:ToData())
        end
    end
    local args = {...}
    table.insert(args, responese)
    table.insert(args, XmdsNetManage.PackExtData.New(true, true, failCb))
    pomeloRequest(unpack(args))
end

return PomeloUtil
