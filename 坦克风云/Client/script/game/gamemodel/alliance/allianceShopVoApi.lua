require "luascript/script/game/gamemodel/alliance/allianceShopVo"
require "luascript/script/config/gameconfig/allianceShopCfg"
allianceShopVoApi=
{
	data=allianceShopVo:new(),
	dialog=nil
}

function allianceShopVoApi:showShopDialog(layerNum,closeCallback)
	-- require "luascript/script/game/scene/gamedialog/allianceDialog/allianceShopDialog"
	-- local td=allianceShopDialog:new()
	-- local tbArr={getlocal("allianceShop_tab1"),getlocal("allianceShop_tab2")}
	-- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("allianceShop_title"),true,layerNum)
	-- self.dialog=td
	-- sceneGame:addChild(dialog,layerNum)

	local td = allShopVoApi:showAllPropDialog(layerNum,"army",closeCallback)
end

--异步获取个人商店的数据
--param callback: 回调函数
function allianceShopVoApi:getPShopData(callback)
	if(self.data==nil)then
		self.data=allianceShopVo:new()
	end
	local zeroTime=G_getWeeTs(base.serverTime)
	if(self.data.updatePTs>=zeroTime)then
		callback(self.data.pShopStatus)
	else
		local function onRequestEnd(fn,data)
			local ret,sData=base:checkServerData(data)
			if(ret==true)then
				self.data:initPersonalData(sData.data.alliancegetshop)
				if(callback~=nil)then
					callback(self.data.pShopStatus)
				end
			end
		end
		socketHelper:allianceShopGetData(1,onRequestEnd)
	end
end

--异步获取全军团珍品的数据
--param callback: 回调函数
function allianceShopVoApi:getAShopData(callback)
	if(self.data==nil)then
		self.data=allianceShopVo:new()
	end
	local zeroTime=G_getWeeTs(base.serverTime)
	--将刷新时间配置中的时分配置转换成时间戳
	local refreshTsTb={}
	for k,v in pairs(allianceShopCfg.aShopRefreshTime) do
		refreshTsTb[k]=zeroTime+v[1]*3600+v[2]*60
	end
	local length=#refreshTsTb
	local recentRefreshTs
	--如果当前时间比最后一个刷新点还大，那就取最后一个刷新点
	if(base.serverTime>=refreshTsTb[length])then
		recentRefreshTs=refreshTsTb[length]
	else
		for i=1,length-1 do
			if(refreshTsTb[i]<=base.serverTime and refreshTsTb[i+1]>base.serverTime)then
				recentRefreshTs=refreshTsTb[i]
				break
			end
		end
	end
	if(false)then
		callback(self.data.aShopStatus)
	else
		local function onRequestEnd(fn,data)
			local ret,sData=base:checkServerData(data)
			if(ret==true)then
				self.data:initAllianceData(sData.data.alliancegetshop)
				if(callback~=nil)then
					callback(self.data.aShopStatus)
				end
			end
		end
		socketHelper:allianceShopGetData(2,onRequestEnd)
	end
end

--获取商店下次刷新的时间戳
--param type: 1为获取个人商店下次刷新的时间戳, 2为获取军团珍品刷新的时间戳
--return 一个时间戳
function allianceShopVoApi:getNextRefreshTime(type)
	local zeroTime=G_getWeeTs(base.serverTime)
	if(type==1)then
		return zeroTime+86400
	else
		--将刷新时间配置中的时分配置转换成时间戳
		local refreshTsTb={}
		for k,v in pairs(allianceShopCfg.aShopRefreshTime) do
			refreshTsTb[k]=zeroTime+v[1]*3600+v[2]*60
		end
		local length=#refreshTsTb
		--如果当前时间比最后一个刷新点还大，那就返回明天的第一个时间点
		if(base.serverTime>=refreshTsTb[length])then
			return refreshTsTb[1]+86400
		else
			for i=1,length-1 do
				if(refreshTsTb[i]<=base.serverTime and refreshTsTb[i+1]>base.serverTime)then
					return refreshTsTb[i+1]
				end
			end
		end
	end
end

--从军团商店购买物品
--param type: 类型, 1是购买个人商店中的物品, 2是购买全军团珍品中的物品
--param id: 要购买的商品的ID  e.g.: "i1"
--param index: 因为军团珍品有可能刷出两件相同的商品来，所以需要另外一个字段来区分一下
--param callback: 购买成功之后的回调函数
function allianceShopVoApi:buyItem(type,id,index,callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if(ret==true)then
			self.data:buyItemSuccess(type,id,index)
			local cfg
			if(type==1)then
				cfg=allianceShopCfg.pShopItems[id]
			else
				cfg=allianceShopCfg.aShopItems[id]
			end
			local useDonate=allianceMemberVoApi:getUseDonate(playerVoApi:getUid())
			useDonate=useDonate+cfg.price
			allianceMemberVoApi:setUseDonate(playerVoApi:getUid(),useDonate)
            allianceVoApi:apointRefreshData(3)
			local award=FormatItem(cfg.reward) or {}
			for k,v in pairs(award) do
				G_addPlayerAward(v.type,v.key,v.id,v.num,false,true)
			end
			G_showRewardTip(award)
			if(callback)then
				callback()
			end
		else
			if(type==1)then
				self.data.updatePTs=0
			elseif(type==2)then
				self.data.updateATs=0
			end
		end
	end
	socketHelper:allianceShopBuyItem(type,id,index,onRequestEnd)
end

--有军团内的其他成员购买了商品, 后台推来的消息
function allianceShopVoApi:otherPlayerBuyItem(id,index)
	if(self.data and self.data.aShopStatus)then
		for k,v in pairs(self.data.aShopStatus) do
			if(v.id==id and v.index==index)then
				v.aNum=v.aNum+1
				break
			end
		end
	end
	if(self.dialog)then
		self.dialog:refresh()
	end
end

function allianceShopVoApi:clear()
	self.data=nil
	self.dialog=nil
end