--超级秒杀的数据vo
acSuperShopVo=activityVo:new()
function acSuperShopVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.recharge=0
	nc.lastRefreshTs=0		--最近一次刷新数据的时间戳
	nc.version=1
	nc.shopCfg=nil			--根据开关修正之后，实际显示的商品列表
	nc.shopIndexCfg=nil		--根据开关修正之后，实际显示的商品列表对应原来商品列表的位置
	nc.openTime=nil
	nc.buyRecord1=nil
	nc.buyRecord2=nil
	nc.shopNumTb1={}
	nc.shopNumTb2={}
	nc.shopEndTb1={}
	nc.shopEndTb2={}
	nc.rechargeLimit=0
	return nc
end

function acSuperShopVo:init(type)
	self.type=type
	self.canRewardFlag = false -- 是否有可领取的奖励
	self.stateChanged = false  -- 可领取奖励状态是否发生了改变
	self.over = false -- 是否活动结束（不是活动时间到，是活动的所有操作完成导致的）
	self.hasData=false --useractive里是否返回了该活动的用户数据

	self.initCfg=false --activelist里是否返回了该活动的用户数据,配置数据
	self.isShow=1		--是否显示面板，默认1是显示

	self:initRefresh()
	if(self.paymentListener==nil)then
		local function listener(event,data)
			if(data.num)then
				if(self.lastRefreshTs==nil or self.lastRefreshTs<G_getWeeTs(base.serverTime))then
					self.recharge=tonumber(data.num)
				else
					self.recharge=self.recharge + tonumber(data.num)
				end
				self.lastRefreshTs=base.serverTime
			end
		end
		self.paymentListener=listener
	end
	if(eventDispatcher:hasEventHandler("user.pay",self.paymentListener)==false)then
		eventDispatcher:addEventListener("user.pay",self.paymentListener)
	end
end

function acSuperShopVo:updateSpecialData(data)
	if data.st then
		self.st=tonumber(data.st)
	end
	if data.et then
		self.et=tonumber(data.et)
	end
	if(data.v)then
		self.recharge=tonumber(data.v)
	end
	if(data.t)then
		self.lastRefreshTs=tonumber(data.t)
	end
	if(data.basicShop)then
		self.shopNumTb1=data.basicShop
	end
	if(data.specialShop)then
		self.shopNumTb2=data.specialShop
	end
	if(data.bendts)then
		self.shopEndTb1=data.bendts
	end
	if(data.sendts)then
		self.shopEndTb2=data.sendts
	end
	if(data.qg)then
		self.buyRecord1=data.qg
	end
	if(data.gg)then
		self.buyRecord2=data.gg
	end
	if(data._activeCfg)then
		local cfg=data._activeCfg
		if cfg.version then
			self.version=tonumber(cfg.version)
		end
		if(cfg.recharge)then
			self.recharge=tonumber(cfg.recharge)
		end
		if(cfg.refNum)then
			self.refNum=cfg.refNum
		end
		if(cfg.ticketCost)then
			self.rechargeLimit=tonumber(cfg.ticketCost)
		end
		if(cfg.func)then
			self.funcTb=cfg.func
			if(self.shopCfg==nil)then
				self.shopCfg={}
				self.shopCfg.basicShop={}
				self.shopCfg.specialShop={}
				self.shopIndexCfg={}
				self.shopIndexCfg.basicShop={}
				self.shopIndexCfg.specialShop={}
				for k,v in pairs(self.funcTb) do
					if(v==0 or v=="0")then
						table.insert(self.shopCfg.basicShop,activityCfg.cjms[self.version].basicShop[k])
						table.insert(self.shopCfg.specialShop,activityCfg.cjms[self.version].specialShop[k])
						table.insert(self.shopIndexCfg.basicShop,tonumber(k))
						table.insert(self.shopIndexCfg.specialShop,tonumber(k))
					elseif((v=="ec" and base.ifAccessoryOpen==1) or 
						(v=="alien" and base.alien==1) or 
						(v=="sw" and base.ifSuperWeaponOpen==1) or
						(v=="hero" and base.heroSwitch==1) or
						(v=="he" and base.he==1) or 
						(v=="sequip" and base.emblemSwitch==1) or
						(v=="plane" and base.plane==1) or 
						(v=="armor" and base.armor==1))then
						table.insert(self.shopCfg.basicShop,activityCfg.cjms[self.version].basicShop[k])
						table.insert(self.shopCfg.specialShop,activityCfg.cjms[self.version].specialShop[k])
						table.insert(self.shopIndexCfg.basicShop,tonumber(k))
						table.insert(self.shopIndexCfg.specialShop,tonumber(k))
					end
				end
				if(self.openTime and self.openTime[2])then
					self.openTime[2]=math.min(self.openTime[2],self.openTime[1] + #(self.shopCfg.basicShop))
				end
			end
		end
		if(cfg.timeShow and self.openTime==nil)then
			self.openTime={tonumber(cfg.timeShow[1]),tonumber(cfg.timeShow[2])}
			if(self.shopCfg)then
				self.openTime[2]=math.min(self.openTime[2],self.openTime[1] + #(self.shopCfg.basicShop))
			end
		end
	end
end
