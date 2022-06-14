local redEnvelopeData = class("redEnvelopeData")

redEnvelopeData.SHAKE_ENUM = {}
redEnvelopeData.SHAKE_ENUM.SHAKING = 1 ---开始摇动
redEnvelopeData.SHAKE_ENUM.INVALID = 0 ---默认


function redEnvelopeData:ctor()
	 self.num = 0     ----已经摇奖的次数
	 self.addShakeCount = 0  -- 分享的计数器
	 self.RankList= {}	
	 self.money = 0   ---当前的钱
	 self.allMoney = 0 --总奖金
	 self.shakeStatus = redEnvelopeData.SHAKE_ENUM.INVALID 
end 	

function redEnvelopeData:setNum(num)
	 self.num = num
end
---已经摇奖的次数
function redEnvelopeData:getNum()
	 return self.num
end

-- 分享的计数器

function redEnvelopeData:setAddShakeCount(num)
		 self.addShakeCount = num
end
function redEnvelopeData:getAddShakeCount()
	 return self.addShakeCount 
end
---开放等级
function redEnvelopeData:isOpenLevel()
		 	
	local level = dataManager.playerData:getLevel()
	local configlevel = dataConfig.configs.ConfigConfig[0].redEnvelopeLevelLimit  
	
	return level >= configlevel
 
	--[[
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					textInfo = "国王等级"..configlevel.."级，开放抢红包活动" });
					
	]]--				
end 

--- 开放日期
function redEnvelopeData:isOpenDay()
		 local time  = os.date("!*t", dataManager.getServerTime() - dataManager.timezone * 60 * 60)		
 
		 local beginDay =    dataConfig.configs.ConfigConfig[0].redEnvelopeOpenTime 
			   beginDay = string.split(beginDay, "-");
		 local endDay = dataConfig.configs.ConfigConfig[0].redEnvelopeCloseTime
			   endDay = string.split(endDay, "-");
		
		if( tonumber (beginDay[1])  <= time.year and tonumber (beginDay[2])  <= time.month and tonumber (beginDay[3]) <= time.day  )	then
			if(tonumber (endDay[1]) >= time.year and tonumber (endDay[2])  >= time.month and tonumber (endDay[3]) >= time.day  )	then
				return true
			end
			return false
		end
		return false
end

--活动过期，界面功能保留3天，留给玩家兑换时间，有相应界面提示，过期界面消失。
function redEnvelopeData:isUICloseDay()
		 local time  =  dataManager.getServerTime() - dataManager.timezone * 60 * 60 		
		 local endDay = dataConfig.configs.ConfigConfig[0].redEnvelopeCloseTime
			   endDay = string.split(endDay, "-");
		local endDay = os.time{year= tonumber (endDay[1]), month=tonumber (endDay[2]), day = tonumber (endDay[3]), hour=0,min = 0,sec = 0} 
		return time - endDay >= 3 * 24 * 60 *60
end

 

function redEnvelopeData:getOpenDay()
	local beginDay =   dataConfig.configs.ConfigConfig[0].redEnvelopeOpenTime 
		  beginDay = string.split(beginDay, "-");
	local endDay =   dataConfig.configs.ConfigConfig[0].redEnvelopeCloseTime
	      endDay = string.split(endDay, "-");
	local text = "活动时间："..beginDay[1].."/"..beginDay[2].."/"..beginDay[3].."-"..endDay[1].."/"..endDay[2].."/"..endDay[3]	 
	return 	text
end

function redEnvelopeData:getTotalMoney()
		return  self.allMoney   
end	
function redEnvelopeData:getNowGetMoney()
		return self.money  
end	

function redEnvelopeData:isOpenTime()
	  	
	local time  = os.date("!*t", dataManager.getServerTime() - dataManager.timezone * 60 * 60)
	 
		for i,v in ipairs (dataConfig.configs.redEnvelopeConfig) do
				local beginTime = v.openTime
				local endTime = v.closeTime
				local _i,_j = string.find(beginTime, ":")
				local i,j = string.find(endTime, ":")	
				
				local ehour = tonumber( string.sub(endTime,1,i-1)	)	
				local emin = tonumber(string.sub(endTime,j+1,-1))
					
				local bhour = tonumber( string.sub(beginTime,1,_i-1)	)	
				local bmin = tonumber(string.sub(beginTime,_j+1,-1))
				
				local num = time.hour*60 + time.min
				
				if(num >=  (bhour*60 + bmin)  and  num < (ehour*60 + emin)  )then
					 return true,i
				end
		end	 
	 
	return false
end


function redEnvelopeData:getMaxNum()
	  	 local res,index = self:isOpenTime()
		 if(res)then
			if(self.addShakeCount == 0)then
				return dataConfig.configs.redEnvelopeConfig[index].lotteryNum
			elseif(self.addShakeCount <= dataConfig.configs.redEnvelopeConfig[index].lotteryAddNum )then	
				return dataConfig.configs.redEnvelopeConfig[index].lotteryNum  + self.addShakeCount
			else
				return dataConfig.configs.redEnvelopeConfig[index].lotteryNum
			end
		 end
		return 0 
end

function redEnvelopeData:hasShakeNum()
	    return  self:getNum() <  self:getMaxNum()
end


function redEnvelopeData:getCanShakeNum()
	     local  num = self:getMaxNum() - self:getNum()  
		 return num;
end

function redEnvelopeData:shareToWeiXin()
		 --- 调用微信的分享接口

	local shellInterface = GameClient.CGame:Instance():getShellInterface();
	if shellInterface then
		
		local shareInfo = {
			['title'] = "风暴战争",
			['desc'] = "风暴战争--第一策略手游",
			['url'] = "war.laohu.com",		
		}
		
		shareInfo = json.encode(shareInfo);
		
		shellInterface:onShareToWeiXin(shareInfo);
	end

end

 
--手机摇一摇调用接口


function  redEnvelopeData_onshakeToClient()
		 dataManager.redEnvelopeData.shakeStatus = dataManager.redEnvelopeData.shakeStatus or  redEnvelopeData.SHAKE_ENUM.INVALID
		 if(dataManager.redEnvelopeData.shakeStatus == redEnvelopeData.SHAKE_ENUM.INVALID )then
				
		  elseif(dataManager.redEnvelopeData.shakeStatus == redEnvelopeData.SHAKE_ENUM.SHAKING )then
				return  false	
		  end		

		 if(not dataManager.redEnvelopeData:isOpenLevel()) then
				eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
							messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
							textInfo = "国王等级"..configlevel.."级，开放抢红包活动" });
			return false
		  end
		
		 if(not dataManager.redEnvelopeData:isOpenDay()) then
				eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
							messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
							textInfo = "没到开放日期" });
		
			return false
		  end
		
		 if(not dataManager.redEnvelopeData:isOpenTime()) then
				eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
							messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
							textInfo = "没到开放时间" });
		
			return false
		  end
		
		 if(not dataManager.redEnvelopeData:hasShakeNum()) then
				eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
							messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
							textInfo = "次数不足" });
			return false
		  end
		  dataManager.redEnvelopeData.shakeStatus = redEnvelopeData.SHAKE_ENUM.SHAKING 
		  dataManager.redEnvelopeData:sendAskShake() 
end

 

--分享成功回调
function  onshareToWeiXinSucess()
		 ---分享成功发送服务器 ---请求加次数 
		sendAskShake(enum.SHAKE_TYPE.SHAKE_TYPE_SHARE)
end
---提现
function  redEnvelopeData:askTiXian(count)
		  sendAskShake(enum.SHAKE_TYPE.SHAKE_TYPE_AGIOTAGE)
end

---请求排行榜
function  redEnvelopeData:sendAskShakeRank()
		   sendAskShake(enum.SHAKE_TYPE.SHAKE_TYPE_RANK)
end
---摇一摇结果
function  redEnvelopeData:sendAskShake()
		  sendAskShake(enum.SHAKE_TYPE.SHAKE_TYPE_SHAKE)
end
 
---
function  redEnvelopeData:rankInfo(rankInfo)
	self.RankList = {}	
	for i,v in ipairs (rankInfo)do
		local player = {}
		player.id = v['id']  
		player.icon = v['icon'] 
		player.money = v['money']
		player.playerName = v['playerName']  
		table.insert(self.RankList,player)
	end		
end
function  redEnvelopeData:SyncShakeInfoHandler(shakeCount, addShakeCount, shakeMoney, redEnvelopMoney )
	
		if(type(shakeMoney) == "userdata")then
			shakeMoney = shakeMoney:GetInt()
		end
 
		if(type(redEnvelopMoney) == "userdata")then
			redEnvelopMoney = redEnvelopMoney:GetInt()
		end
	
	
		 if(self.shakeStatus == redEnvelopeData.SHAKE_ENUM.SHAKING )then
			self.shakeStatus =  redEnvelopeData.SHAKE_ENUM.INVALID 
			eventManager.dispatchEvent({name = global_event.REDENVELOPERESULT_SHOW, money = (shakeMoney - self.money) })
		 end
		  self:setNum(shakeCount)	
	 	  self:setAddShakeCount(addShakeCount)	
		  self.money = shakeMoney
		  self.allMoney = redEnvelopMoney
		 eventManager.dispatchEvent({name = global_event.REDENVELOPE_UPDATE })
end
 
return redEnvelopeData