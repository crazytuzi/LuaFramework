transactionData = class("transactionData")

function transactionData:ctor()

	self.transactionTable = {};

end

function transactionData:addTransaction( jsonData )

	local tableInfo = json.decode(jsonData);
	dump(tableInfo);
	-- 

	self.transactionTable[tableInfo.transaction] = 
	{
		["receipt"] = tableInfo.receipt,
		["productID"] = tableInfo.productID,
	}

	self:saveToFile();

	self:askServerVerify();
end

function transactionData:initFromFile()
	-- body
	local jsonData = fio.readIni("transaction", "receipt", "{}", "config.cfg");

	print(jsonData);
	
	--self.transactionTable = json.decode(jsonData);
	local transctionData = json.decode(jsonData);

	for k,v in pairs(transctionData) do
		self.transactionTable[k] = v;
	end

	print("initFromFile");
	dump(self.transactionTable);

end

function transactionData:saveToFile()
	-- body
	local jsonData = json.encode(self.transactionTable);

	fio.writeIni("transaction", "receipt", jsonData, "config.cfg");
end

function transactionData:getRechargeIDByProductionID(productID)
	-- body
	for k,v in pairs(dataConfig.configs.rechargeConfig) do
		
		if v.iosid == productID then
			return k;
		end
	end
end

function transactionData:askServerVerify()
	-- body

	for k,v in pairs(self.transactionTable) do
		
		local rechargeID = self:getRechargeIDByProductionID(v.productID);
		sendAskVerifyReceipt(rechargeID, v.receipt);
	end
end

function  transactionData:onVerifyResult(verifyResult, transaction_id)
	-- body
	print("onVerifyResult")
	print(verifyResult);
	print(transaction_id);

	if verifyResult == enum.VERIFY_RESULT_TYPE.VERIFY_RESULT_TYPE_SUCCESS then
		

		for k,v in pairs(self.transactionTable) do
			if transaction_id == k then
				v = nil;
				break;
			end
		end

		self:saveToFile();
	else

		print("verifyResult  failed");

	end

end