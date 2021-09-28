require "Core.Module.Pattern.Proxy"

EndlessTryProxy = Proxy:New();
local endlessinfo
local configs
local useProducting
function EndlessTryProxy:OnRegister()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.EndlessTryInfo, EndlessTryProxy._OnEndlessTryInfo)
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.EndlessTryTeamInfo, EndlessTryProxy._OnGetTeamInsprieInfo)
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.EndlessTryBuy, EndlessTryProxy._OnEndlessTryBuy)
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Use_Product, EndlessTryProxy._OnUse_Product)
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.UseProudctBuff, EndlessTryProxy._OnUse_Product)
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.BuyMallItem, EndlessTryProxy._OnBuyMallItem)
end
function EndlessTryProxy:OnRemove()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.EndlessTryInfo, EndlessTryProxy._OnEndlessTryInfo)
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.EndlessTryTeamInfo, EndlessTryProxy._OnGetTeamInsprieInfo)
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.EndlessTryBuy, EndlessTryProxy._OnEndlessTryBuy)
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Use_Product, EndlessTryProxy._OnUse_Product)
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.UseProudctBuff, EndlessTryProxy._OnUse_Product)
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.BuyMallItem, EndlessTryProxy._OnBuyMallItem)
end

--1：金币2：仙玉
function EndlessTryProxy.EndlessTryBuy(t)
    if t == 2 then
        local cost = EndlessTryProxy.GetJadeCost()
        local buyfunc = function()
	        SocketClientLua.Get_ins():SendMessage(CmdType.EndlessTryBuy,{ t = t });
        end
        MsgUtils.UseBDGoldConfirm2(cost, self, "common/actionBuy" , { num = cost, pn = LanguageMgr.Get("EndlessTry/Insprie") }, buyfunc, nil, nil)
        return
    end
	SocketClientLua.Get_ins():SendMessage(CmdType.EndlessTryBuy,{ t = t });
end
function EndlessTryProxy.UseExp(id, sid, na, cost)
	local pb_item = BackpackDataManager.GetProductBySpid(id)
    if pb_item ~= nil then
        ProductTipProxy.TryUseProduct(pb_item, 1)
    else
        local buyfunc = function()
	        SocketClientLua.Get_ins():SendMessage(CmdType.UseProudctBuff,{ id = id });
            --MallProxy.SendBuyMallItem(sid, 1)
            --EndlessTryProxy._id = id
            --EndlessTryProxy._sid = sid
            --EndlessTryProxy._na = na
        end
        --local cost = MallManager.GetStoreById(sid).original_price
        MsgUtils.UseBDGoldConfirm(cost, self, "common/bgoldBuy"
            , { num = cost, pn = na }, buyfunc, nil, nil)
    end
    useProducting = true
end
function EndlessTryProxy._OnBuyMallItem(cmd, data)
    if not EndlessTryProxy._id then return end
	if data.errCode then return end
    EndlessTryProxy.UseExp(EndlessTryProxy._id, EndlessTryProxy._sid, EndlessTryProxy._na)
    EndlessTryProxy._id = nil
end
function EndlessTryProxy.GetEndlessInfo()
    --Warning("GetEndlessInfo")
	SocketClientLua.Get_ins():SendMessage(CmdType.EndlessTryInfo);
end
function EndlessTryProxy.GetTeamInsprieInfo()
	SocketClientLua.Get_ins():SendMessage(CmdType.EndlessTryTeamInfo);
end

function EndlessTryProxy.CanInsprie()
	return not endlessinfo or endlessinfo.env < 100
end
function EndlessTryProxy.GetGoldLimitTime()
    local m = EndlessTryProxy.GetGoldMaxTime()
    --Warning(tostring(m) .. tostring(endlessinfo))
	return endlessinfo and m - endlessinfo.tt or m
end
function EndlessTryProxy.GetGoldTime()
	return endlessinfo and endlessinfo.tt or 0
end
function EndlessTryProxy.GetGoldMaxTime()
	return config.money_limit
end
function EndlessTryProxy.GetGoldCost()
	return config.monet_cost
end
function EndlessTryProxy.GetJadeCost()
	return config.gold_cost
end
function EndlessTryProxy.GetInsprieProductId()
	return config.encourage_buff
end
function EndlessTryProxy.GetExpProductIds()
	return config.exp_item
end
function EndlessTryProxy.InitConfig()
	if not configs then
        configs = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_ENDLESSTRY)
        config = configs[1]
    end
end


function EndlessTryProxy._OnEndlessTryBuyExp(cmd, data)
	if data.errCode then return end
    MessageManager.Dispatch(EndlessTryNotes, EndlessTryNotes.ENDLESS_CHANGE_INFO, data)
end
function EndlessTryProxy._OnEndlessTryBuy(cmd, data)
	if data.errCode then return end
    MsgUtils.ShowTips(EndlessTryProxy.CanInsprie()
        and "EndlessTry/InsprieTips" or "EndlessTry/InsprieTips")
    endlessinfo = data
    MessageManager.Dispatch(EndlessTryNotes, EndlessTryNotes.ENDLESS_CHANGE_INFO, data)
end
function EndlessTryProxy._OnEndlessTryInfo(cmd, data)
	if data.errCode then return end
    endlessinfo = data
    MessageManager.Dispatch(EndlessTryNotes, EndlessTryNotes.ENDLESS_CHANGE_INFO, data)
end
function EndlessTryProxy._OnGetTeamInsprieInfo(cmd, data)
	if data.errCode then return end
    MessageManager.Dispatch(EndlessTryNotes, EndlessTryNotes.ENDLESS_CHANGE_TEAM_INFO, data)
end
function EndlessTryProxy._OnUse_Product(cmd, data)
    if not useProducting then return end
    useProducting = false
	if data.errCode then return end
    MsgUtils.ShowTips("EndlessTry/insprieOk")
    EndlessTryProxy.GetEndlessInfo()
end