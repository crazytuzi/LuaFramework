require "Core.Module.Pattern.Proxy"

MallProxy = Proxy:New();
local curSelectKind = 1
local json = require "cjson"
function MallProxy:OnRegister()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetMallItemInfo, MallProxy.GetMallItemInfoCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.BuyMallItem, MallProxy.BuyMallItemCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetChargeOrderId, MallProxy.GetChargeOrderIdCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ChargeSuccess, MallProxy.ChargeSuccessCallBack);
	
end

function MallProxy:OnRemove()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetMallItemInfo, MallProxy.GetMallItemInfoCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.BuyMallItem, MallProxy.BuyMallItemCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetChargeOrderId, MallProxy.GetChargeOrderIdCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ChargeSuccess, MallProxy.ChargeSuccessCallBack);
end

-- <-- 16:13:53.274, 0x1802, 25, {"sn":-1,"num":1,"id":62,t,k}
function MallProxy.BuyMallItemCallBack(cmd, data)
	if(data and data.errCode == nil) then
		local item = MallManager.GetItemInfoById(data.t, data.k, data.id)
		
		if not item then return end
		item.sn = data.sn
		if(data.sn ~= - 1) then
			ModuleManager.SendNotification(MallNotes.UPDATE_MALLPANEL)
		end
		UISoundManager.PlayUISound(UISoundManager.ui_gold)
		ModuleManager.SendNotification(MallNotes.UPDATE_MALLITEMINFO)
	end
end

function MallProxy.GetMallItemInfoCallBack(cmd, data)
	if(data and data.errCode == nil) then
		MallManager.SetItemDatas(data)
		
		ModuleManager.SendNotification(MallNotes.UPDATE_MALLPANEL)
		
	end
end

function MallProxy.SendGetMallItem(t, k)
	local data = MallManager.GetItemDatas(t, k)
	if(k) then
		MallProxy.SetMallKind(k)
	end
	if(data == nil or table.getCount(data) == 0) then
		SocketClientLua.Get_ins():SendMessage(CmdType.GetMallItemInfo, {t = t, k = k});
	else
		ModuleManager.SendNotification(MallNotes.UPDATE_MALLPANEL)
	end
end

function MallProxy.GetMallKind()
	return curSelectKind
end

function MallProxy.SetMallKind(k)
	curSelectKind = k
end


function MallProxy.SendBuyMallItem(id, num)
	SocketClientLua.Get_ins():SendMessage(CmdType.BuyMallItem, {id = id, num = num});
end

local successCallBack = {}
function MallProxy.SendCharge(id, callBack)
	if(callBack ~= nil) then
		successCallBack[id] = function() callBack(id) end
	end
	
	local chargeData = {}
	chargeData.rid = id
	chargeData.token = LoginHttp.GetSdkToken()
	chargeData.ver = LogHelp.instance.app_ver
	chargeData.sdkVer = SDKHelper.instance:GetSDKVersionCode()
	local userId = SDKHelper.instance:GetUserId()
	if(userId == "") then
		userId = "0"
	end
	chargeData.userID = userId
	SocketClientLua.Get_ins():SendMessage(CmdType.GetChargeOrderId, chargeData);	
end

-- return
-- orderId：奥飞订单号
-- cpOrderId：游戏方订单号
-- extension：json字符串
function MallProxy.GetChargeOrderIdCallBack(cmd, data)
	
	if(data and data.errCode == nil) then
		local payData = {}
		local chargeConfig = VIPManager.GetChargeConfigById(data.rid)
		local hero = HeroController.GetInstance().info
		local server = LoginManager.GetCurrentServer()
		payData.cpOrderId = data.cpOrderId
		payData.extension = data.extension
		payData.orderId = data.orderId
		payData.itemId = data.crid
		payData.coin = chargeConfig.gold
		payData.price = chargeConfig.rmb
		payData.itemName = chargeConfig.product_name
		payData.itemDes = chargeConfig.gold_des
		payData.roleId = PlayerManager.playerId
		payData.level = hero.level
		payData.name = hero.name
		payData.serverId = server.id
		payData.serverName = server.name
		payData.vip = tostring(VIPManager.GetSelfVIPLevel())
		local jsonData = json.encode(payData)
        --回调改成充值成功发货后由1b05回调CallSuccessCallBack
		SDKHelper.instance:Pay(jsonData, nil, nil)
	end
end

function MallProxy.SendBuyVipCard(id, cost, na)
	local buyfunc = function()
		SocketClientLua.Get_ins():SendMessage(CmdType.VipBuy, {id = id})
	end
	--local cost = MallManager.GetStoreById(sid).original_price
	MsgUtils.UseGoldConfirm(cost, self, "common/goldBuy"
	, {num = cost, pn = na}, buyfunc, nil, nil)
end

function MallProxy.SendChargeSuccess(orderId, token,rid)
	log("发送sdk充值成功回掉")
	SocketClientLua.Get_ins():SendMessage(CmdType.ChargeSuccess, {orderId = orderId, token = token,rid = rid}); 
end

function MallProxy.ChargeSuccessCallBack(cmd, data)
	if(data and data.errCode == nil) then
		
		
	end
end

--发货成功回掉
function MallProxy.CallSuccessCallBack(data)	
	if(data) then
		for k, v in ipairs(data) do
			if(successCallBack and successCallBack[v.rid]) then
				successCallBack[v.rid]()
			end
		end
		
	end
end
