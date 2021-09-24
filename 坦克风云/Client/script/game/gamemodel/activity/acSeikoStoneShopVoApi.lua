acSeikoStoneShopVoApi={
	shopList={}
}

function acSeikoStoneShopVoApi:getAcVo()
	if self.vo==nil then
		self.vo=activityVoApi:getActivityVo("seikoStoneShop")
	end
	return self.vo
end

--判断是否有任务奖励领取
function acSeikoStoneShopVoApi:canReward()
	return false
end

function acSeikoStoneShopVoApi:getTimeStr()
	local vo = self:getAcVo()
	local timeStr = activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acSeikoStoneShopVoApi:getShopList()
	return self.shopList
end

function acSeikoStoneShopVoApi:getBuyItem()
	local vo=self:getAcVo()
	if vo then
		return vo.buyItem
	end
	return nil
end

function acSeikoStoneShopVoApi:getBuyItemInfo()
	--获取精工石的信息
	local name,pic,desc,id,noUseIdx,eType,equipId,bgname=getItem("p481","p")
	return name,pic,desc,id,noUseIdx,eType,equipId,bgname
end

function acSeikoStoneShopVoApi:initShopList()
	local vo=self:getAcVo()
	if vo then
		self.shopList={}
		if vo.propsCfg and vo.exchangeData then
			for k,item in pairs(vo.propsCfg) do
				local bindHid=item[5] --该道具绑定的将领id，如果没有绑定奖励则为 ""
				if bindHid=="" or self:hasBindHero(bindHid)==true then
					local propItem={}
					propItem.itemId=tostring(k) --表示购买道具的位置
					propItem.reward=FormatItem(item[1],nil,true)[1] --购买道具的配置数据
					propItem.price=item[3] --道具的价格
					propItem.sortId=item[4] --道具的显示id
					propItem.maxCount=item[6] --最大兑换次数
					propItem.curCount=0 --当前剩余兑换次数
					if vo.exchangeData[k] then
						-- print("vo.exchangeData[k]=======",vo.exchangeData[k])
						propItem.curCount=vo.exchangeData[k]
						if propItem.curCount<0 then
							propItem.curCount=0
						end
					end
					table.insert(self.shopList,propItem)
				end
			end
		end

		self:sortShopList()
	end
end

function acSeikoStoneShopVoApi:hasBindHero(bindHid)
	local herolist=heroVoApi:getHeroList()
	for k,v in pairs(herolist) do
		-- print("v.hid======="..v.hid)
		-- print("bindHid======="..bindHid)
		if v.hid==bindHid then
			return true
		end
	end
	return false
end

function acSeikoStoneShopVoApi:updateData(data)
	local acVo = self:getAcVo()
	if acVo then
		acVo:updateSpecialData(data)
		self:updateShopListData()
	end
end

--根据后台同步来的数据来更新商店列表数据
function acSeikoStoneShopVoApi:updateShopListData()
	--更新任务进度
	local vo = self:getAcVo()
	if vo==nil then
		return
	end
	if self.shopList then
		for k,propItem in pairs(self.shopList) do
			if vo.exchangeData[propItem.itemId] then
				propItem.curCount=vo.exchangeData[propItem.itemId]
				if propItem.curCount<0 then
					propItem.curCount=0
				end
			end
		end	
		--更新完成后按照规则对商店列表排序
		self:sortShopList()
	end
end

function acSeikoStoneShopVoApi:sortShopList()
	if self.shopList==nil then
		return
	end
	G_dayin(self.shopList)
	local function sortFunc(prop1,prop2)
		local sortWeight1=(prop1.maxCount-prop1.curCount>0) and (10*prop1.sortId) or (100*prop1.sortId)
		local sortWeight2=(prop2.maxCount-prop2.curCount>0) and (10*prop2.sortId) or (100*prop2.sortId)

		return sortWeight1<sortWeight2
	end
	table.sort(self.shopList,sortFunc)
end

--玩家等级在22级及以上才能参加活动
function acSeikoStoneShopVoApi:isCanJoinActivity()
	local curLevel = playerVoApi:getPlayerLevel()
	local limitLv
	if(base.heroEquipOpenLv)then
		limitLv=base.heroEquipOpenLv
	else
		limitLv=30
	end
	if tonumber(curLevel) >= limitLv then
		return true,limitLv
	end
	return false,limitLv
end

--打开活动的板子
function acSeikoStoneShopVoApi:openSeikoStoneShopDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/activityAndNote/acSeikoStoneShopDialog"
    local td=acSeikoStoneShopDialog:new()
    local tbArr={}
    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("activity_seikostone_shop_title"),true,layerNum)
    sceneGame:addChild(dialog,layerNum)
end

function acSeikoStoneShopVoApi:isToday()
	local flag = false
	local vo=self:getAcVo()
	if vo then
		flag=G_isToday(vo.t)
	end
	return flag
end

function acSeikoStoneShopVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

function acSeikoStoneShopVoApi:clearAll()
	self.shopList={}
	self.vo=nil
end