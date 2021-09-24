--超级秒杀的voapi
acSuperShopVoApi={noticeDayTs1=0,noticeDayTs2=0}

function acSuperShopVoApi:setActiveName(name)
	self.name=name
end

function acSuperShopVoApi:getActiveName()
	return self.name or "cjms"
end

function acSuperShopVoApi:getAcVo()
	return activityVoApi:getActivityVo("cjms")
end

function acSuperShopVoApi:canReward()
	return false
end

function acSuperShopVoApi:getVersion( )
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1
end

function acSuperShopVoApi:getCfg()
	local version=activityVoApi:getVersion()
	local cfg=activityCfg.cjms[version]
	return cfg
end

--获取当前商店的状态
--return 0: 没到点，还没开
--return n: 第n个商店的展示阶段
--return -1: 今天的商店已经结束
function acSuperShopVoApi:getShopStatus()
	local vo=acSuperShopVoApi:getAcVo()
	if(vo==nil)then
		return 0
	end
	local curHour=math.floor((base.serverTime - G_getWeeTs(base.serverTime))/3600)
	if(curHour<vo.openTime[1])then
		return 0
	elseif(curHour>=vo.openTime[2])then
		return -1
	else
		return curHour - vo.openTime[1] + 1
	end
end

--获取当前的商品列表
--param type: 0是SB商店，1是NB商店
--return: basicShop或者specialShop中的某一组
function acSuperShopVoApi:getCurShopList(type)
	local vo=acSuperShopVoApi:getAcVo()
	if(vo==nil or vo.shopCfg==nil)then
		return {}
	end
	local shopCfg
	if(type==0)then
		shopCfg=vo.shopCfg.basicShop
	else
		shopCfg=vo.shopCfg.specialShop
	end
	if(shopCfg==nil)then
		return {}
	end
	local curStatus=acSuperShopVoApi:getShopStatus()
	if(curStatus==0)then
		curStatus=1
	elseif(curStatus==-1)then
		curStatus=#shopCfg
	end
	return shopCfg[curStatus] or {}
end

--获取当前商品列表的标题和图标
--param type: 0是SB商店，1是NB商店
--return: 商店的名称
--return: 商店的图标
function acSuperShopVoApi:getCurShopTitleAndPic(type)
	local vo=acSuperShopVoApi:getAcVo()
	if(vo==nil or vo.shopCfg==nil)then
		return "",nil
	end
	local curStatus=acSuperShopVoApi:getShopStatus()
	local shopIndexCfg
	if(type==0)then
		shopIndexCfg=vo.shopIndexCfg.basicShop
	else
		shopIndexCfg=vo.shopIndexCfg.specialShop
	end
	local shopIndex
	if(curStatus==0)then
		shopIndex=shopIndexCfg[1]
	elseif(curStatus==-1)then
		shopIndex=shopIndexCfg[#shopIndexCfg]
	else
		shopIndex=shopIndexCfg[curStatus]
	end
	if(shopIndex==1)then
		return getlocal("activity_double11_shopName_1"),CCSprite:createWithSpriteFrameName("double11_pic_1.png")
	elseif(shopIndex==2)then
		return getlocal("activity_double11_shopName_2"),CCSprite:createWithSpriteFrameName("double11_pic_2.png")
	elseif(shopIndex==3)then 
		return getlocal("activity_double11_shopName_3"),CCSprite:createWithSpriteFrameName("double11_pic_3.png")
	elseif(shopIndex==4)then 
		return getlocal("activity_double11_shopName_4"),CCSprite:createWithSpriteFrameName("double11_pic_4.png")
	elseif(shopIndex==5)then
		return getlocal("activity_double11_shopName_5"),CCSprite:createWithSpriteFrameName("double11_pic_5.png")
	elseif(shopIndex==6)then
		return getlocal("activity_double11_shopName_6"),CCSprite:createWithSpriteFrameName("double11_pic_6.png")
	elseif(shopIndex==7)then
		return getlocal("activity_double11_shopName_7"),CCSprite:createWithSpriteFrameName("double11_pic_7.png")
	elseif(shopIndex==8)then
		return getlocal("activity_double11_shopName_8"),CCSprite:createWithSpriteFrameName("double11_pic_8.png")
	elseif(shopIndex==9)then
		return getlocal("activity_cjms_shopEmblem"),CCSprite:createWithSpriteFrameName("acIconEmblem.png")
	elseif(shopIndex==10)then
		return getlocal("plane_sub_title2"),CCSprite:createWithSpriteFrameName("acIconPlane.png")
	elseif(shopIndex==11)then
		return getlocal("armorMatrix"),CCSprite:createWithSpriteFrameName("armorMatrix_1.png")
	else
		return 1,CCSprite:createWithSpriteFrameName("IconGold.png")
	end
end

--当前是否是今日最后一轮
function acSuperShopVoApi:isLastShop()
	local vo=acSuperShopVoApi:getAcVo()
	if(vo==nil or vo.shopCfg==nil)then
		return false
	end
	local shopCfg
	if(type==0)then
		shopCfg=vo.shopCfg.basicShop
	else
		shopCfg=vo.shopCfg.specialShop
	end
	if(shopCfg==nil)then
		return false
	end
	local curStatus=acSuperShopVoApi:getShopStatus()
	if(curStatus==#shopCfg)then
		return true
	end
	return false
end

--获取下一次的商品列表
--param type: 0是SB商店，1是NB商店
--return: basicShop或者specialShop中的某一组
function acSuperShopVoApi:getNextShopList(type)
	local vo=acSuperShopVoApi:getAcVo()
	if(vo==nil or vo.shopCfg==nil)then
		return {}
	end
	local shopCfg
	if(type==0)then
		shopCfg=vo.shopCfg.basicShop
	else
		shopCfg=vo.shopCfg.specialShop
	end
	if(shopCfg==nil)then
		return {}
	end
	local curStatus=acSuperShopVoApi:getShopStatus()
	local nextIndex
	if(curStatus==0)then
		nextIndex=2
	elseif(curStatus==#shopCfg or curStatus==-1)then
		return {}
	else
		nextIndex=curStatus + 1
	end
	return shopCfg[nextIndex] or {}
end

--获取下一次商品列表的标题和图标
--param type: 0是SB商店，1是NB商店
--return: 商店的名称
--return: 商店的图标
function acSuperShopVoApi:getNextShopTitleAndPic(type)
	local vo=acSuperShopVoApi:getAcVo()
	if(vo==nil or vo.shopCfg==nil)then
		return "",nil
	end
	local curStatus=acSuperShopVoApi:getShopStatus()
	local shopIndexCfg
	if(type==0)then
		shopIndexCfg=vo.shopIndexCfg.basicShop
	else
		shopIndexCfg=vo.shopIndexCfg.specialShop
	end
	local nextIndex
	if(curStatus==0)then
		nextIndex=2
	elseif(curStatus==#shopIndexCfg or curStatus==-1)then
		local sp=CCSprite:createWithSpriteFrameName("double11_pic_1.png")
		sp:setVisible(false)
		return getlocal("alliance_info_content"),sp
	else
		nextIndex=curStatus + 1
	end
	local shopIndex=shopIndexCfg[nextIndex]
	if(shopIndex==1)then
		return getlocal("activity_double11_shopName_1"),CCSprite:createWithSpriteFrameName("double11_pic_1.png")
	elseif(shopIndex==2)then
		return getlocal("activity_double11_shopName_2"),CCSprite:createWithSpriteFrameName("double11_pic_2.png")
	elseif(shopIndex==3)then 
		return getlocal("activity_double11_shopName_3"),CCSprite:createWithSpriteFrameName("double11_pic_3.png")
	elseif(shopIndex==4)then 
		return getlocal("activity_double11_shopName_4"),CCSprite:createWithSpriteFrameName("double11_pic_4.png")
	elseif(shopIndex==5)then
		return getlocal("activity_double11_shopName_5"),CCSprite:createWithSpriteFrameName("double11_pic_5.png")
	elseif(shopIndex==6)then
		return getlocal("activity_double11_shopName_6"),CCSprite:createWithSpriteFrameName("double11_pic_6.png")
	elseif(shopIndex==7)then
		return getlocal("activity_double11_shopName_7"),CCSprite:createWithSpriteFrameName("double11_pic_7.png")
	elseif(shopIndex==8)then
		return getlocal("activity_double11_shopName_8"),CCSprite:createWithSpriteFrameName("double11_pic_8.png")
	elseif(shopIndex==9)then
		return getlocal("activity_cjms_shopEmblem"),CCSprite:createWithSpriteFrameName("acIconEmblem.png")
	elseif(shopIndex==10)then
		return getlocal("plane_sub_title2"),CCSprite:createWithSpriteFrameName("acIconPlane.png")
	elseif(shopIndex==11)then
		return getlocal("armorMatrix"),CCSprite:createWithSpriteFrameName("armorMatrix_1.png")
	else
		return 1,CCSprite:createWithSpriteFrameName("IconGold.png")
	end
end

--获取下次刷新商店的时间戳
function acSuperShopVoApi:getRefreshTime()
	local vo=acSuperShopVoApi:getAcVo()
	if(vo==nil)then
		return base.serverTime + 86400
	end
	local zeroTime=G_getWeeTs(base.serverTime)
	local curHour=math.floor((base.serverTime - zeroTime)/3600)
	if(curHour<vo.openTime[1])then
		return zeroTime + vo.openTime[1]*3600
	elseif(curHour>vo.openTime[2])then
		return zeroTime + 86400
	else
		return zeroTime + (curHour + 1)*3600
	end
end

function acSuperShopVoApi:getTodayRecharge()
	local vo=acSuperShopVoApi:getAcVo()
	if(vo==nil or vo.lastRefreshTs==nil or vo.recharge==nil)then
		return 0
	end
	if(vo.lastRefreshTs<G_getWeeTs(base.serverTime))then
		return 0
	else
		return vo.recharge
	end
end

--获取某个商品的剩余数量
--param type: 0是SB商店，1是NB商店
--param id: 商品ID
function acSuperShopVoApi:getLeftNum(type,id)
	local vo=acSuperShopVoApi:getAcVo()
	if(vo==nil)then
		return 0
	end
	local buyNum
	if(vo["shopNumTb"..(type + 1)] and vo["shopNumTb"..(type + 1)][id])then
		buyNum=tonumber(vo["shopNumTb"..(type + 1)][id])
	else
		buyNum=0
	end
	local cfg=acSuperShopVoApi:getCurShopList(type)
	if(cfg==nil or cfg[id]==nil)then
		return 0
	end
	local totalNum=tonumber(cfg[id].bn)
	return math.max(totalNum - buyNum,0)
end

--检测某个商品是否可以买
--param type: 0是SB商店，1是NB商店
--param id: 商品ID
--return 0: 可以买
--return 1: 已经卖光
--return 2: 不在时间内
--return 3: 充值额度不足
--return 4: 同一个商品在活动期间只能抢购一次
function acSuperShopVoApi:checkCanBuy(type,id)
	local curStatus=acSuperShopVoApi:getShopStatus()
	if(curStatus<=0)then
		return 2
	end
	local shopList=acSuperShopVoApi:getCurShopList(type)
	if(shopList[id]==nil)then
		return 2
	end
	local vo=acSuperShopVoApi:getAcVo()
	if(vo==nil)then
		return 2
	end
	if(type==1 and vo.rechargeLimit and acSuperShopVoApi:getTodayRecharge()<vo.rechargeLimit)then
		return 3
	end
	local zeroTime=G_getWeeTs(base.serverTime)
	local curHour=math.floor((base.serverTime - zeroTime)/3600)
	if(vo.lastRefreshTs and vo.lastRefreshTs>=zeroTime)then
		if(vo["buyRecord"..tostring(type + 1)] and vo["buyRecord"..tostring(type + 1)]["t"..curHour])then
			for k,v in pairs(vo["buyRecord"..tostring(type + 1)]["t"..curHour]) do
				if(v==id)then
					return 4
				end
			end
		end
	end
	local leftNum=acSuperShopVoApi:getLeftNum(type,id)
	if(leftNum<=0)then
		return 1
	end
	return 0
end

--充值数够不够开放特殊商店
--return: true or false
function acSuperShopVoApi:checkRechargeEnabled()
	local vo=acSuperShopVoApi:getAcVo()
	if(vo==nil or vo.rechargeLimit==nil)then
		return false
	end
	local todayRecharge=acSuperShopVoApi:getTodayRecharge()
	if(todayRecharge>=vo.rechargeLimit)then
		return true
	else
		return false
	end
end

function acSuperShopVoApi:requestShop(callback)
	local vo=acSuperShopVoApi:getAcVo()
	if(vo==nil or vo.shopCfg==nil)then
		do return end
	end
	local shopIndexCfg
	if(type==0)then
		shopIndexCfg=vo.shopIndexCfg.basicShop
	else
		shopIndexCfg=vo.shopIndexCfg.specialShop
	end
	if(shopIndexCfg==nil)then
		do return end
	end
	local curStatus=acSuperShopVoApi:getShopStatus()
	if(curStatus<=0)then
		curStatus=1
	end
	local curHour=math.floor((base.serverTime - G_getWeeTs(base.serverTime))/3600)
	local shopIndex=shopIndexCfg[curStatus]
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			local vo=acSuperShopVoApi:getAcVo()
			if(vo==nil)then
				do return end
			end
			vo:updateSpecialData(sData.data)
			if(sData.data.cjms)then
				vo:updateSpecialData(sData.data.cjms)
			end
			if(callback)then
				callback()
			end
		end
	end
	socketHelper:acSuperShopGet(curHour,shopIndex,onRequestEnd)
end

function acSuperShopVoApi:buy(shopType,sid,callback)
	local vo=acSuperShopVoApi:getAcVo()
	if(vo==nil or vo.shopCfg==nil)then
		do return end
	end
	local shopIndexCfg
	if(shopType==0)then
		shopIndexCfg=vo.shopIndexCfg.basicShop
	else
		shopIndexCfg=vo.shopIndexCfg.specialShop
	end
	if(shopIndexCfg==nil)then
		do return end
	end
	local curStatus=acSuperShopVoApi:getShopStatus()
	if(curStatus<=0)then
		curStatus=1
	end
	local curHour=math.floor((base.serverTime - G_getWeeTs(base.serverTime))/3600)
	local shopIndex=shopIndexCfg[curStatus]
	local itemCfg=acSuperShopVoApi:getCurShopList(shopType - 1)[sid]
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			local vo=acSuperShopVoApi:getAcVo()
			if(vo==nil)then
				do return end
			end
			local price
			vo:updateSpecialData(sData.data)
			if(sData.data.cjms)then
				vo:updateSpecialData(sData.data.cjms)
			end
			if(itemCfg)then
				playerVoApi:setGems(playerVoApi:getGems() - itemCfg.g)
				local reward=FormatItem(itemCfg.r)
				for k,v in pairs(reward) do
					G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),false,true)
				end
				local rewardCfg=FormatItem(itemCfg.r)
				local msg=getlocal("activity_double11_showAllBody",{playerVoApi:getPlayerName(),getlocal("activity_cjms_title"),rewardCfg[1].name})
				chatVoApi:sendSystemMessage(msg)
			end
			if(callback)then
				callback(true)
			end
		else
			if(callback)then
				callback(false)
			end
		end
	end
	socketHelper:acSuperShopBuy(shopType,sid,curHour,shopIndex,onRequestEnd)
end

function acSuperShopVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage1.plist")
    spriteController:addTexture("public/activeCommonImage1.png")
end

function acSuperShopVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage1.plist")
    spriteController:removeTexture("public/activeCommonImage1.png")
end

function acSuperShopVoApi:tick()
	local zeroTime=G_getWeeTs(base.serverTime)
	local vo=acSuperShopVoApi:getAcVo()
	if(vo and vo.openTime and vo.openTime[1])then
		local todayStartTime=zeroTime + vo.openTime[1]*3600
		if(acSuperShopVoApi.noticeDayTs1==nil or acSuperShopVoApi.noticeDayTs1<zeroTime)then
			if(base.serverTime>=todayStartTime - 320 and base.serverTime<=todayStartTime - 280)then
				local paramTab={}
				paramTab.functionStr="cjms"
				paramTab.addStr="goTo_see_see"
				local params={subType=4,contentType=3,message={key="double11_willSell_chatSystemMessage",param={getlocal("activity_cjms_title"),5}},ts=base.serverTime,paramTab=paramTab}
				chatVoApi:addChat(1,0,"",0,"",params,base.serverTime)
				acSuperShopVoApi.noticeDayTs1=base.serverTime
			end
		end
		if(acSuperShopVoApi.noticeDayTs2==nil or acSuperShopVoApi.noticeDayTs2<zeroTime)then
			if(base.serverTime>=todayStartTime - 6 and base.serverTime<=todayStartTime + 6)then
				local paramTab={}
				paramTab.functionStr="cjms"
				paramTab.addStr="goTo_see_see"
				local params={subType=4,contentType=3,message={key="double11_SellNow_chatSystemMessage",param={getlocal("activity_cjms_title")}},ts=base.serverTime,paramTab=paramTab}
				chatVoApi:addChat(1,0,"",0,"",params,base.serverTime)
				acSuperShopVoApi.noticeDayTs2=base.serverTime
			end
		end
	end
end

function acSuperShopVoApi:clearAll()
	local vo=acSuperShopVoApi:getAcVo()
	if(vo and vo.paymentListener)then
		if(eventDispatcher:hasEventHandler("user.pay",vo.paymentListener)==true)then
			eventDispatcher:removeEventListener("user.pay",vo.paymentListener)
		end
	end
end