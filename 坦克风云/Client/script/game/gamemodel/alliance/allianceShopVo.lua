allianceShopVo={}
function allianceShopVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.updatePTs=0			--上次刷新个人数据的时间, a timestamp
	self.updateATs=0			--上次刷新个人数据的时间, a timestamp
	self.pShopStatus=nil		--个人道具页中每种道具的购买次数, format: {"i1":5,"i2":6,"i3":0}
	self.aShopStatus=nil		--全军团珍品中每种道具的购买次数以及该成员在全军团珍品中的购买情况, format: {["i1",2,1,1],["i2",3,0,2],["i3",0,0,3]}, 每个元素是一个数组，数组的第一个元素是物品的ID，第二个元素是该物品全军团一共购买了几个，第三个元素是该用户购买了几个，第四个元素是一个位置，因为军团商店中有可能刷出两件同样的东西来，所以需要这样的格式

	--test data
	-- self.updatePTs=9999999999
	-- self.updateATs=9999999999
	-- self.pShopStatus={i5=1}
	-- self.aShopStatus={{id="i11",aNum=3,pNum=1,index=1},{id="i12",aNum=2,pNum=0,index=2},{id="i13",aNum=5,pNum=3,index=3}}
	--test end

	return nc
end

function allianceShopVo:initPersonalData(data)
	self.updatePTs=base.serverTime
	self.pShopStatus={}
	if(data)then
		for k,v in pairs(data) do
			self.pShopStatus[k]=tonumber(v)
		end
	end
end

--data format: {["i1",2,1,1],["i2",3,0,2],["i3",0,0,3]}
function allianceShopVo:initAllianceData(data)
	self.updateATs=base.serverTime
	self.aShopStatus={}
	if(data)then
		for k,v in pairs(data) do
			if(v and v[1])then
				self.aShopStatus[k]={}
				self.aShopStatus[k].id=v[1]
				if(v[2])then
					self.aShopStatus[k].aNum=tonumber(v[2])
				else
					self.aShopStatus[k].aNum=0
				end
				if(v[3])then
					self.aShopStatus[k].pNum=tonumber(v[3])
				else
					self.aShopStatus[k].pNum=0
				end
				if(v[4])then
					self.aShopStatus[k].index=tonumber(v[4])
				else
					self.aShopStatus[k].index=0
				end
			end
		end
	end
end

function allianceShopVo:buyItemSuccess(type,id,index)
	if(type==1 and self.pShopStatus)then
		if(self.pShopStatus[id])then
			self.pShopStatus[id]=self.pShopStatus[id]+1
		else
			self.pShopStatus[id]=1
		end
	elseif(type==2 and self.aShopStatus)then
		for k,v in pairs(self.aShopStatus) do
			if(v.id==id and v.index==index)then
				v.aNum=v.aNum+1
				v.pNum=v.pNum+1
				break
			end
		end
	end
end