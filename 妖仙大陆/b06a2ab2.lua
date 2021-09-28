local VipUtil = {}
local Util = nil
function VipUtil.setUtil(_util)
    Util = _util
end

function VipUtil.getVipLv()
    return DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.VIP)
end

function VipUtil.getValue(key, vipLv)
    vipLv = vipLv or VipUtil.getVipLv()
    if vipLv == 0 then return 0 end

    local staticVo = GlobalHooks.DB.Find("Vip", vipLv)
    return staticVo[key]
end



function VipUtil.vipLvByFunc(key, value)
    value = value or 0
    local vips = GlobalHooks.DB.Find("Vip", {})
    table.sort(vips, function(a, b) return a.VipLevel < b.VipLevel end)
    for i,v in ipairs(vips) do
        if not v[key] then return 0 end
        if type(v[key]) == "number" then
            if value <= v[key] then return i end
        elseif type(v[key]) == "string" then
            if not string.empty(v[key]) then return i end
        end
    end
    return 0
end

function VipUtil.checkUseVipCard(code, okCb)
    local vipLv = VipUtil.getVipLv()
    
    
    if vipLv == 0 then
        okCb()
        return
    end

    local item = GlobalHooks.DB.Find("Items", code)
    
    if item.Par > vipLv then
        GameAlertManager.Instance:ShowAlertDialog(
            AlertDialog.PRIORITY_NORMAL, 
            Util.GetText(TextConfig.Type.VIP,"VipUseVipCardTips", vipLv, item.Par),
            Util.GetText(TextConfig.Type.VIP, "use"),
            Util.GetText(TextConfig.Type.VIP, "cancel"),
            nil,
            function() okCb() end,
            nil
        )
        return
    end

    okCb()

    
    
    
end



return VipUtil
