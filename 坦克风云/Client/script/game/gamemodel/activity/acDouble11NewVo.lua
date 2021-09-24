acDouble11NewVo = activityVo:new()

function acDouble11NewVo:updateSpecialData(data)

	if data.version then
		self.version =data.version
	end
	
	if data.st then
		self.st =tonumber(data.st)
	end
	if data.et then
		self.et =tonumber(data.et)
	end
	if data.func then --tab表内 位置ID 与 相应的平台
		self.funcTb =data.func
	end

	if data.t then
		self.lastTime =data.t
	end
	if data.buyShop then--tab表内 打折购买信息
		self.buyShopTb =data.buyShop
	end
	if self.buyShopTb ==nil then
		self.buyShopTb ={}
	end
	if self.buyShopNumsTb ==nil then
		self.buyShopNumsTb ={}
	end
	if data.buyshop then --所有商店所有物品购买的次数
		self.buyShopNumsTb = data.buyshop 
	end
	-- if data.shop then
	-- 	self.shopPanicedNums =data.shop
	-- end
	if self.shopPanicedNums ==nil then
		self.shopPanicedNums ={}
	end

	if self.shopItemTb ==nil then
		self.shopItemTb ={}
	end

	if data.shopItems then --tab表内 抢购信息   --卖场列表（）：配件卖场，坦克卖场，将领卖场，经验书卖场，异星卖场，超级武器卖场,将领装备，攻击道具
		self.shopItemTb =data.shopItems
	end

	if data.timeShow then--tab表内 抢购开始时间 结束时间
		self.timeShowTb=data.timeShow
	end
	if data.refNum then --tab表内 按开始时间 循环抢购商店对应的ID位置
		self.loopIdTb=data.refNum
	end

	if self.switchTab ==nil then
		self.switchTab ={0,0,0,0,0,0,0,0}
	end

	if self.panicedTab==nil then --玩家当前时间内 已抢购的列表
		self.panicedTab={}
	end
	if data.qg then
		self.panicedTab=data.qg
	end
	if self.panicedNumsTab ==nil then
		self.panicedNumsTab={}
	end

	if self.scratchTb==nil then --刮奖Tab表
		self.scratchTb={}
	end
	if data.dg then
		self.scratchTb =data.dg
	end

	if data.dgems then --最近一次刮奖金币数量 
		self.lastScratchGold =data.dgems
	end
	if data.dgem then --dgem={'t10'=100}, -- 最近一次抽奖
		self.nearScratchGold = data.dgem
	end
	if self.nearScratchGold ==nil then
		self.nearScratchGold ={}
	end
	
	if self.scratchTimeTb ==nil then
		self.scratchTimeTb = {}
	end
	if data.gg then
		self.scratchTimeTb=data.gg
	end

	if self.iconTb ==nil then
		self.iconTb ={}
	end

	if self.endts ==nil then
		self.endts ={}
	end

	if self.chatSillValue ==nil then --广播的阀值 0 未开启 1 上架前预先广播 2 上架后已广播  只对自己广播
		self.chatSillValue =0
		local zeroTime=G_getWeeTs(base.serverTime)
		if math.floor(((base.serverTime - zeroTime)%3600)/60) <54 then
			self.chatSillValue =1 
		end
	end
	--------------------------------红包
	if self.sendRedidTb ==nil then
		self.sendRedidTb ={}
	end

	if self.redBagRecordTb ==nil then-----接收当前点击的红包的信息
		self.redBagRecordTb = {}
	end
	if self.corpRedBagRecordTb ==nil then--接收当前点击的军团红包的信息
		self.corpRedBagRecordTb ={}
	end
	if data.numLimit then--世界频道相关，抢红包记录最多条数
		self.numLimit =data.numLimit
	end
	if self.numLimit ==nil then
		self.numLimit =10
	end
-------军团红包相关信息
	
	if self.curFlag ==nil then--当前抢到红包返回的  目前只用2 4    flag =1 是抢红包成功   2 --已经领取过   3 -- 红包不存在  4 红包派发完了 
		self.curFlag =0
	end

	if data.pickNum then--军团红包可选数量
		self.pickNumTb =data.pickNum
	end
	if self.pickNumTb==nil then
		self.pickNumTb ={}
	end

	if data.pickMoney then----军团红包可选金额
		self.pickMoneyTb =data.pickMoney
	end
	if self.pickNumTb==nil then
		self.pickMoneyTb ={}
	end

	if data.discount then--军团红包折扣比例
		self.discount =data.discount
	end
	if self.discount ==nil then
		self.discount = 1
	end

	if data.lvLimit then
		self.sendCorpRedBagLvLimit =data.lvLimit
	end
	if self.sendCorpRedBagLvLimit ==nil then
		self.sendCorpRedBagLvLimit =30
	end

	if self.usePickNum==nil then --当前要发送的军团红包个数类型
		self.usePickNum =0
	end
	if self.usePickMoney ==nil then--当前要发送的军团红包平均的钱数类型
		self.usePickMoney =0 
	end

	if self.receivedCorpRedBagTb ==nil then
		self.receivedCorpRedBagTb ={}
	end
	if self.isNewCorpTbReceived ==nil then
		self.isNewCorpTbReceived = 0
	end

	if self.redBagTagbaseIdx ==nil then
		self.redBagTagbaseIdx = 0
	end

end