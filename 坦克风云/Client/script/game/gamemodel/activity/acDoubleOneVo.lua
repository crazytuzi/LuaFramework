acDoubleOneVo = activityVo:new()

function acDoubleOneVo:updateSpecialData(data)

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

	--------------------购买商店新增内容--------------------
	if data.refTime then--服务器刷新时间,即早上9点和晚上21点刷新2,3,4,5折商店
		self.refTime = data.refTime
	end
	if data.closeTime then--购买关闭时间(分钟)，抢购关闭时间=refTime-closeTime(即21点-5分钟=20:55）；
		self.closeTime = data.closeTime
	end
	if data.openTime then--开始购买时间(分钟)，开启抢购时间=refTime+openTime(即9点+5分钟=9:05）
		self.openTime = data.openTime
	end
	if data.spLimitNum then--2-4折商店每人限购数量
		self.spLimitNum = data.spLimitNum 
	end
    
    if data.refshop then
    	self.refShopTb = data.refshop
    end
    if not self.refShopTb then
    	self.refShopTb = {}
    end
    
    if data.bg then--自己商店购买的次数（目前只是2，3，4折扣商店有数据保存）
    	self.buyedTb = data.bg
    end

	------------------------ o v e r ----------------------

	if self.chatSillValue ==nil then --广播的阀值 0 未开启 1 上架前预先广播 2 上架后已广播  只对自己广播
		self.chatSillValue =0
		local zeroTime=G_getWeeTs(base.serverTime)
		if math.floor(((base.serverTime - zeroTime)%3600)/60) <54 then
			self.chatSillValue =1 
		end
	end
end