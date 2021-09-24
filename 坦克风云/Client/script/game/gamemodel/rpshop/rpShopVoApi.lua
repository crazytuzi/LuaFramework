require "luascript/script/config/gameconfig/rpShopCfg"
rpShopVoApi=
{
	itemList={},			--军功商店所有的商品列表, 第一个元素是普通物品列表, 第二个元素是珍品列表, 列表中的每一个元素是一个rpShopItemVo
	dataExpireTime=0,		--信息过期时间
	recentOpenTime=nil,		--最新一次刷新物品后打开商店的时间
	personalBuy={},			--个人的购买信息
	personalBuyTs=0,		--个人的上次购买时间
	refreshTb=nil,
}

function rpShopVoApi:checkInitRefreshTimeTb()
	if(self.refreshTb==nil)then
		self.refreshTb={}
		local wday=G_getFormatWeekDay(base.serverTime)
		if(wday==6)then
			local zeroTime=G_getWeeTs(base.serverTime)
			self.refreshTb[1]=zeroTime
			for i=1,#rpShopCfg.reftime do
				table.insert(self.refreshTb,zeroTime + rpShopCfg.reftime[i]*3600)
			end
			for i=1,#rpShopCfg.reftime do
				table.insert(self.refreshTb,zeroTime + 86400 + rpShopCfg.reftime[i]*3600)
			end
			table.insert(self.refreshTb,zeroTime + 86400*2)
		elseif(wday==7)then
			local zeroTime=G_getWeeTs(base.serverTime) - 86400
			self.refreshTb[1]=zeroTime
			for i=1,#rpShopCfg.reftime do
				table.insert(self.refreshTb,zeroTime + rpShopCfg.reftime[i]*3600)
			end
			for i=1,#rpShopCfg.reftime do
				table.insert(self.refreshTb,zeroTime + 86400 + rpShopCfg.reftime[i]*3600)
			end
			table.insert(self.refreshTb,zeroTime + 86400*2)
		else
			local zeroTime=G_getWeeTs(base.serverTime) + (6 - wday)*86400
			self.refreshTb[1]=zeroTime
			for i=1,#rpShopCfg.reftime do
				table.insert(self.refreshTb,zeroTime + rpShopCfg.reftime[i]*3600)
			end
			for i=1,#rpShopCfg.reftime do
				table.insert(self.refreshTb,zeroTime + 86400 + rpShopCfg.reftime[i]*3600)
			end
			table.insert(self.refreshTb,zeroTime + 86400*2)
		end
	end
end

function rpShopVoApi:refresh(callback)
	self:checkInitRefreshTimeTb()
	require "luascript/script/game/gamemodel/rpshop/rpShopItemVo"
	if(base.serverTime>self.dataExpireTime)then
		local function onRequestEnd(fn,data)
			local ret,sData=base:checkServerData(data)
			if(ret==true)then
				self.itemList={{},{}}
				if(sData.data.creditshop)then
					for id,buyNum in pairs(sData.data.creditshop) do
						local itemVo=rpShopItemVo:new(id,buyNum)
						local type=self:getTypeByID(id)
						if(type=="i")then
							table.insert(self.itemList[1],itemVo)
						else
							table.insert(self.itemList[2],itemVo)
						end
					end
				end
				local function sortFunc(a,b)
					return a.cfg.index<b.cfg.index
				end
				table.sort(self.itemList[1],sortFunc)
				table.sort(self.itemList[2],sortFunc)
				local zeroTime=G_getWeeTs(base.serverTime)
				local length=#self.refreshTb
				for i=1,length do
					if(base.serverTime<self.refreshTb[i])then
						self.dataExpireTime=self.refreshTb[i]
						break
					end
				end
				--过期时间为5分钟或者商店的刷新时间, 哪个近用哪个
				if(self.dataExpireTime>base.serverTime+300)then
					self.dataExpireTime=base.serverTime+300
				end
				if(callback)then
					callback()
				end
			else
				if(sData.ret==-14000 or sData.ret==-14001)then
					self.dataExpireTime=base.serverTime + 86400*2
				end
			end
		end
		socketHelper:rpShopRefresh(onRequestEnd)
	else
		if(callback)then
			callback()
		end
	end
end

function rpShopVoApi:getSbItemList()
	return self.itemList[1]
end

function rpShopVoApi:getNbItemList()
	return self.itemList[2]
end

function rpShopVoApi:checkShopOpen()
	if(base.rpShopOpen==1)then
		return true
	end
	local date=G_getFormatWeekDay(base.serverTime)
	if(date==6 or date==7)then
		return true
	else
		return false    
	end
end

function rpShopVoApi:refreshSelfRecentOpenTime()
	self.recentOpenTime=base.serverTime
	local dataKey="rpShopOpenTime@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
	CCUserDefault:sharedUserDefault():setIntegerForKey(dataKey,self.recentOpenTime)
end

function rpShopVoApi:showShop(layerNum)
	if(self:checkShopOpen())then
		self:refreshSelfRecentOpenTime()
		-- require "luascript/script/game/scene/gamedialog/rpshop/rpShopDialog"
		-- local td=rpShopDialog:new()
		-- local tbArr={getlocal("normal"),getlocal("allianceShop_tab2")}
		-- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("rpshop_title"),true,layerNum)
		-- sceneGame:addChild(dialog,layerNum)
		local td = allShopVoApi:showAllPropDialog(layerNum,"feat")
		return td
	else
		-- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage14001"),30)
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("not_to_time"),30)
		do return end
	end
end

--检测在商店刷新了物品之后是否点击过商店, 用于显示new图标和转圈
--return: true or false
function rpShopVoApi:checkNoticed()
	self:checkInitRefreshTimeTb()
	if(self:checkShopOpen()==false)then
		return true
	end
	if(self.recentOpenTime==nil)then
		local dataKey="rpShopOpenTime@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
		self.recentOpenTime=CCUserDefault:sharedUserDefault():getIntegerForKey(dataKey)
	end
	local length=#self.refreshTb
	for i=1,length do
		if(base.serverTime>=self.refreshTb[i] and self.recentOpenTime<self.refreshTb[i])then
			return false
		end
	end
	return true
end

function rpShopVoApi:buyItem(id,callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if(ret==true)then
			local buyId
			local leftNum
			for k,v in pairs(sData.data) do
				buyId=k
				leftNum=v
				break
			end
			local type=self:getTypeByID(buyId)
			local refreshList
			local cfg
			if(type=="i")then
				refreshList=self.itemList[1]
				cfg=rpShopCfg.pShopItems
			else
				refreshList=self.itemList[2]
				cfg=rpShopCfg.aShopItems
			end
			for k,v in pairs(refreshList) do
				if(v.id==buyId)then
					v.buyNum=leftNum
					break
				end
			end
			if(buyId==nil or cfg[buyId]==nil)then
				self.dataExpireTime=0
				do return end
			end
			self.personalBuyTs=base.serverTime
			if(self.personalBuy[buyId])then
				self.personalBuy[buyId]=self.personalBuy[buyId]+1
			else
				self.personalBuy[buyId]=1
			end
			local price=cfg[buyId].price
			local gemPrice=cfg[buyId].gemprice or 0
			print("gemPricegemPrice",gemPrice)
			playerVoApi:setRpCoin(playerVoApi:getRpCoin() - price)
			playerVoApi:setGems(playerVoApi:getGems()-gemPrice)
			local rewardTb=FormatItem(cfg[buyId].reward)
			G_showRewardTip(rewardTb,true)
			for k,v in pairs(rewardTb) do
				G_addPlayerAward(v.type,v.key,v.id,v.num)
			end
			params={uid=playerVoApi:getUid(),itemId=buyId,num=leftNum}
			chatVoApi:sendUpdateMessage(14,params)
			if(callback)then
				callback()
			end
		else
			if(sData.ret==-14000 or sData.ret==-14001)then
				self.dataExpireTime=base.serverTime + 86400*2
			else
				self.dataExpireTime=0
			end
		end
	end
	socketHelper:rpShopBuy(id,onRequestEnd)
end

function rpShopVoApi:getTypeByID(id)
	local type=string.sub(id,1,1)
	return type
end

function rpShopVoApi:updatePersonalBuy(data)
	self:checkInitRefreshTimeTb()
	self.personalBuyTs=data.ts or 0
	if(data.ts)then
		local length=#self.refreshTb
		for i=1,length do
			if(data.ts<self.refreshTb[i] and base.serverTime>=self.refreshTb[i])then
				self.personalBuy={}
				return
			end
		end
	end
	if(data.b)then
		for k,v in pairs(data.b) do
			self.personalBuy[k]=tonumber(v)
		end
	end
end

function rpShopVoApi:pushMessage(data)
	if(base.serverTime>=self.dataExpireTime)then
		return
	end
	if(data.uid~=playerVoApi:getUid())then
		local itemId=data.itemId
		local buyNum=data.num
		local type=self:getTypeByID(itemId)
		local refreshList
		if(type=="i")then
			refreshList=self.itemList[1]
		else
			refreshList=self.itemList[2]
		end
		for k,v in pairs(refreshList) do
			if(v.id==itemId)then
				if(buyNum>v.buyNum)then
					v:update(buyNum)
					eventDispatcher:dispatchEvent("rpShop.refresh",v)
				end
				break
			end
		end
	end
end

function rpShopVoApi:getPersonalBuy(id)
	local length=#self.refreshTb
	for i=1,length do
		if(self.personalBuyTs<self.refreshTb[i] and base.serverTime>=self.refreshTb[i])then
			self.personalBuy={}
			break
		end
	end
	return self.personalBuy[id] or 0
end

function rpShopVoApi:getPersonalMaxBuy(id)
	local type=self:getTypeByID(id)
	if(type=="i")then --普通
		-- return math.max(math.floor(playerVoApi:getRank()*0.5 - 1),0)
		return math.max(math.floor(playerVoApi:getRank()*1 - 3),0)
	else --珍品
		-- return math.max(math.floor(playerVoApi:getRank()*0.225 - 0.5),0)
		return math.max(math.floor(playerVoApi:getRank()*0.7 - 4),0)
	end
end

function rpShopVoApi:clear()
	self.itemList={}
	self.dataExpireTime=0
	self.recentOpenTime=nil
	self.personalBuy={}
	self.personalBuyTs=0
	self.refreshTb=nil
end