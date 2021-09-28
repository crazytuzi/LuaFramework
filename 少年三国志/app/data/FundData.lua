-- 
require("app.cfg.fund_coin_info")
require("app.cfg.fund_number_info")

local FundData = class("FundData")

function FundData:ctor()
	self._start_time = 0
	self._buy_count = 0
	self._open_time = 0
	self._buy = 0
	self._coinList = {}
	self._numberList = {}
	self._infoReady = false
	self._userReady = false
	self:_init()
end

function FundData:_init()
	for i = 1, fund_coin_info.getLength() do
		local temp = {id = fund_coin_info.indexOf(i).id , status = 2}
		table.insert(self._coinList,#self._coinList+1,temp)
	end
	for i = 1, fund_number_info.getLength() do
		local temp = {id = fund_number_info.indexOf(i).id , status = 2}
		table.insert(self._numberList,#self._numberList+1,temp)
	end
end

function FundData:updateInfo(data)
	self._start_time = data.start_time
	self._buy_count = data.buy_count
	self._open_time = data.open_time
	self._infoReady = true
	for i = 1, #self._numberList do
		if fund_number_info.indexOf(i).buy_number <= self._buy_count and self._numberList[i].status == 2 then
			self._numberList[i].status = 1
		end
	end
end

function FundData:getBuyNum()
	return self._buy_count
end

function FundData:getStartTime()
	return self._start_time
end

function FundData:needShow()
	local st1 = self:getCountDown() > 0
	local st2 = G_Setting:get("open_fund") == "1"
	return st1 and st2 and not self:emptyAward()
end

function FundData:needTips()
	return self:hasNew1() or self:hasNew2()
end

function FundData:emptyAward()
	for i = 1, #self._coinList do
		if self._coinList[i].status ~= 3 then
			return false
		end
	end
	for i = 1, #self._numberList do
		if self._numberList[i].status ~= 3 then
			return false
		end
	end
	return true
end

function FundData:getCountDown()
	local t1 = G_Me.fundData:getStartTime() + 7*24*60*60
	local t2 = G_ServerTime:getTime()
	return t1 - t2
end

function FundData:dataReady()
	self:refreshData()
	return self._infoReady and self._userReady
end

function FundData:refreshData()
	for i = 1, #self._numberList do
		if fund_number_info.indexOf(i).buy_number <= self._buy_count and self._numberList[i].status == 2 then
			self._numberList[i].status = 1
		end
	end
	if not self._buy then 
		for i = 1, #self._coinList do
			self._coinList[i].status = 2
		end
	else
		for i = 1, #self._coinList do
			if self._coinList[i].status ~= 3 then
				if fund_coin_info.indexOf(i).level <= G_Me.userData.level then
					self._coinList[i].status = 1
				else
					self._coinList[i].status = 2
				end
			end
		end
	end
end

function FundData:updateUserInfo(data)
	self:setBuy(data.buy)
	self:updateCoinList(data.award)
	self:updateNumberList(data.weal)
	self._userReady = true
end

function FundData:setBuy(buy)
	self._buy = buy
	if not self._buy then 
		for i = 1, #self._coinList do
			self._coinList[i].status = 2
		end
	else
		for i = 1, #self._coinList do
			if fund_coin_info.indexOf(i).level <= G_Me.userData.level then
				self._coinList[i].status = 1
			else
				self._coinList[i].status = 2
			end
		end
	end
end

function FundData:getBuy()
	return self._buy
end

function FundData:getGotGold()
	local gotGold = 0
	for k,v in pairs(self._coinList) do
		if v.status == 3 then
			gotGold = gotGold + fund_coin_info.get(v.id).coin_number
		end
	end
	return gotGold
end

function FundData:getGoldCanGet()
	local gotGold = 0
	for k,v in pairs(self._coinList) do
		if v.status ~= 3 then
			gotGold = gotGold + fund_coin_info.get(v.id).coin_number
		end
	end
	return gotGold
end

function FundData:updateCoinList(data)
	for i = 1,#data do 
		self._coinList[data[i]].status = 3
	end
end

function FundData:updateNumberList(data)
	for i = 1,#data do 
		self._numberList[data[i]].status = 3
	end
end

function FundData:getCoinList()
	return self._coinList
end

function FundData:getNumberList()
	return self._numberList
end

function FundData:hasNew1()
	local st = false
	for i = 1, #self._coinList do
		if self._coinList[i].status == 1 then
			st = true
		end
	end
	-- local canBuy = G_Me.userData.vip >= 2 and not self._buy
	-- return st or canBuy
	return st
end

function FundData:hasNew2()
	for i = 1, #self._numberList do
		if self._numberList[i].status == 1 then
			return true
		end
	end
	return false
end

return FundData
