function OrderHandler( rechargeID, orderID )

	local payInfo = "";
		
	local config = dataConfig.configs.rechargeConfig[rechargeID];
	
	local serverlist, alllist = dataManager.loginData:getServerlist();
	
	local data = alllist[dataManager.loginData:getServerId()];
	
	if config and data then
		payInfo = {
			['productPrice'] = config.rmb, -- ·Ö
			['productName'] = config.name,
			['gameServerId'] = data.serverid,
			['extInfo'] = config.id,
			['roleId'] = 1,
			['productCount'] = 1,
			['orderID'] = orderID,
			['exchangeRate'] = 100,
			['iosid'] = config.iosid,
		};
		
		payInfo = json.encode(payInfo);
		
	end
	
	print(payInfo);
	
	local shellInterface = GameClient.CGame:Instance():getShellInterface();
	if shellInterface then
		shellInterface:payWithInfo(payInfo);
	end
	
end
