acGeneralRecallVoApi ={
	bindList=nil,
	task=nil, --活跃玩家的任务数据
	inviteCode=nil, --从分享聊天中发过来的绑定码
	refreshFlag=false,
}

function  acGeneralRecallVoApi:getAcVo( )
	return activityVoApi:getActivityVo("djrecall")
end

function acGeneralRecallVoApi:canReward()
	local playertype = self:getPlayerType()
	local needVipOrPeople= playertype == 1 and self:getNeedVipTb( ) or self:getNeedPeopleTb()
	for k,v in pairs(needVipOrPeople) do
		if self:getReceivedState(k) == 2 then
			return true
		end
	end
	if playertype == 1 then
		if self:getGiftList() ==nil or SizeOfTable(self:getGiftList()) > 0 then
			return true
		end
	end
	return self:isTaskhasNewReward()
	
end

function acGeneralRecallVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end
function acGeneralRecallVoApi:updateLastTime(newTime)
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = newTime
	end
end

function acGeneralRecallVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end
-----------------活跃玩家
-- "sid": "i1", -- 物品标识
-- "num": 2,  -- 赠送数量
-- "tuid": 7000093, -- 接收人
-- "method": 1, -- 是否使用金币代替物品(1|0)
-- "gems": 100 -- 本次赠送消耗的金币数(前后端对此值做校验,在最后的时候做向上取整)
function acGeneralRecallVoApi:getLastToSend( )--送礼最终确认数据，【1】sid [2] num [3] tuid [4] method [5] gems
	local vo = self:getAcVo()
	if vo and vo.lastToSend then
		return vo.lastToSend
	end
	return {}
end
function acGeneralRecallVoApi:setLastToSend( lastToSend)
	local vo = self:getAcVo()
	if vo and lastToSend then
		vo.lastToSend = lastToSend
	elseif lastToSend ==nil then
		vo.lastToSend = {}
	end
end



function acGeneralRecallVoApi:SureToSendNow(payProp)
	local lastToSend = self:getLastToSend()

	local function callBack(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("donate_blessword_success"),28)
			self:setLastToSend()
			self:cleanSendingData()
			--donate_blessword_success
			-- print("payProp----->",payProp)
			if sData.data and sData.data.djrecall then
				self:updateData(sData.data.djrecall)
				local ds = sData.data.djrecall.ds
				local newT = sData.data.djrecall.t 
				if ds then
					self:setHandselNum(ds)
				end
				if newT then
					self:updateLastTime(newT)
				end

			end
		    if sData and sData.data and sData.data.accessory and accessoryVoApi then
	           	accessoryVoApi:onRefreshData(sData.data.accessory)
            end
			 playerVoApi:setGems(playerVoApi:getGems()-lastToSend[5]) 
		end
	end
    local params={sid=lastToSend[1],num=lastToSend[2],tuid=lastToSend[3],method=lastToSend[4],gems=lastToSend[5]}
	socketHelper:activeGeneralRecall("active.djrecall.send",params,callBack)
end

function acGeneralRecallVoApi:getInviteCode( )
	local vo = self:getAcVo()
	if vo and vo.inviteCode then
		return vo.inviteCode
	end
	return nil
end

function acGeneralRecallVoApi:getNeedPeopleTb( )
	local vo = self:getAcVo()
	if vo and vo.needPeopleTb then
		return vo.needPeopleTb
	end
	return {}
end

function acGeneralRecallVoApi:getClickCurSid(idx,choosePage)
	local vo = self:getAcVo()
	if vo and vo.donateReward then
		local gData = vo.donateReward
		local nowpage = 1
		local nowIdx = 0
		for k,v in pairs(gData) do
			if choosePage > nowpage then
				nowpage = nowpage+1
				nowIdx =nowIdx + SizeOfTable(v)
			end
		end
		return nowIdx + idx
	end
	-- print("error~~~~ in getClickCurSid")
	return 1
end

function acGeneralRecallVoApi:getDonateReward(choosePage)
	local vo=self:getAcVo()
	local gFormatTb={}
	if vo and vo.donateReward then
		local gData=vo.donateReward[choosePage]
		for k,v in pairs(gData) do
			-- table.insert(gFormatTb,FormatItem(v.reward,true,true)[1])
			gFormatTb[v.index] = FormatItem(v.reward,true,true)[1]
		end
		return vo.donateReward[choosePage],gFormatTb
	end
	return {}
end

--获取玩家已经赠送的数量
function acGeneralRecallVoApi:getDonated()
	local vo=self:getAcVo()
	if vo and vo.s then
		return vo.s
	end
	return {}
end

--当前可以捐献的最大上限
function acGeneralRecallVoApi:getCurMaxDonate(pageId,donateId)
	local rewardTb=self:getDonateReward(pageId)
	local donateTb=self:getDonated()
	local donate=donateTb[donateId]
	local max=0
	if rewardTb and rewardTb[donateId] and rewardTb[donateId].maxNum then
		local limit=rewardTb[donateId].maxNum
		if donate==nil then
			max=limit
		else
			max=tonumber(limit)-tonumber(donate)
			if max<0 then
				max=0
			end
		end
	end
	return max
end

--获取是否可以赠送状态 1：可以增送 2：捐献次数已达上限 3：暂无绑定好友 4：无好友可以赠送
function acGeneralRecallVoApi:getDonateState()
	local vo=self:getAcVo()
	if vo and vo.handselNum and vo.handselLimit then
		if tonumber(vo.handselNum)>=tonumber(vo.handselLimit) then
			return 2
		end
		if vo.addRecallNum==nil or vo.addRecallNum==0 then
			return 3
		end
        if vo.dsu and vo.addRecallNum and tonumber(vo.dsu)>=SizeOfTable(vo.addRecallNum) then
        	return 4
        end
	end
	return 1
end

function acGeneralRecallVoApi:getLast(curSid)
	local vo = self:getAcVo()
	local gData = {}
	local gFormatTb = {}
	if vo and vo.donateReward then
		for k,v in pairs(vo.donateReward) do
			for i,j in pairs(v) do
				-- print("i----->",i)
				if i == curSid then
					gData = v
					gFormatTb = FormatItem(gData[i].reward,true,true)[1]
					return gData,gFormatTb
				end
			end
		end

	end
end

function acGeneralRecallVoApi:getAddRecallNum( )--绑定的流失玩家数量
	local vo = self:getAcVo()
	if vo and vo.addRecallNum then
		return vo.addRecallNum
	end
	return 0
end

function acGeneralRecallVoApi:setAddRecallNum( bn)
	local vo = self:getAcVo()
	if vo and bn then
		vo.addRecallNum = bn
	end
end

function acGeneralRecallVoApi:setPayPropKey(payKey)
	local vo = self:getAcVo()
	if vo and payKey then
		vo.payPropKey = payKey
	else
		vo.payPropKey =""
	end
end
function acGeneralRecallVoApi:GetPayPropKey()
	local vo = self:getAcVo()
	if vo and vo.payPropKey then
		return vo.payPropKey
	end
end

function acGeneralRecallVoApi:getLastChatTime( )--上一次发送验证码的时间戳
	local vo = self:getAcVo()
	if vo and vo.lastChatTime then
		return vo.lastChatTime
	end
	return 0
end

function acGeneralRecallVoApi:setLastChatTime( lastChatTime)
	local vo = self:getAcVo()
	if vo and lastChatTime then
		vo.lastChatTime = lastChatTime
	end
end

function acGeneralRecallVoApi:getHandselLimit( )--每天赠送的次数上限
	local vo = self:getAcVo()
	if vo and vo.handselLimit then
		return vo.handselLimit
	end
	return 5
end

function acGeneralRecallVoApi:getHandselNum( )--每天赠送的次数
	local vo = self:getAcVo()
	if vo and vo.handselNum then
		return vo.handselNum
	end
	return 0
end

function acGeneralRecallVoApi:setHandselNum( handselNum)
	local vo = self:getAcVo()
	if vo and handselNum then
		vo.handselNum = handselNum
	end
end

function acGeneralRecallVoApi:getCurSid( )--玩家要送的当前礼物的SID，如果点击右上角关闭板子则清空SID
	local vo = self:getAcVo()
	if vo and vo.curSid then
		return vo.curSid
	end
	return 0
end

function acGeneralRecallVoApi:setCurSid( curSid)
	local vo = self:getAcVo()
	if vo and curSid then
		vo.curSid = curSid
	elseif curSid ==nil then
		vo.curSid =0
	end
end

function acGeneralRecallVoApi:getCurGiftNum( )--玩家要送的当前礼物的数量，如果点击右上角关闭板子则清空
	local vo = self:getAcVo()
	if vo and vo.curGiftNum then
		return vo.curGiftNum
	end
	return 0
end

function acGeneralRecallVoApi:setCurGiftNum( curGiftNum)
	local vo = self:getAcVo()
	if vo and curGiftNum then
		vo.curGiftNum = curGiftNum
	elseif curGiftNum ==nil then
		vo.curGiftNum =0
	end
end

function acGeneralRecallVoApi:getNeedCurPayProp( )--玩家要送的当前礼物的数量，如果点击右上角关闭板子则清空
	local vo = self:getAcVo()
	if vo and vo.needCurPayProp then

		local payKey = self:GetPayPropKey()
		local nowHas = 0
		if vo.needCurPayProp > 0 then
			if payKey =="e" then
		        nowHas = accessoryVoApi:getShopPropNum()["p"..vo.needCurPayProp]
		    elseif payKey =="o" then
		        nowHas = tankVoApi:getAvailableTankCount(vo.needCurPayProp)
		    elseif payKey =="p" then
		        nowHas = bagVoApi:getItemNumId(vo.needCurPayProp)
		    end
		end
		return vo.needCurPayProp,vo.needCurPayPropNum,nowHas
	end
	return 0
end

function acGeneralRecallVoApi:setNeedCurPayProp(payProp,layerNum,size,singleNum)
	local vo = self:getAcVo()
	if vo and payProp then
		vo.needCurPayProp = tonumber(RemoveFirstChar(payProp.key))
		vo.needCurPayPropNum = payProp.num
		if singleNum then
			vo.needCurPayPropNum =payProp.num*singleNum
			vo.singleNum =singleNum
		end
		return G_getItemIcon(payProp,size,true,layerNum)
	elseif vo.needCurPayProp ==nil or vo.needCurPayProp ==0 then
		vo.needCurPayProp =0
		vo.needCurPayPropNum = 0
		vo.singleNum =0
	end
end

function acGeneralRecallVoApi:setSingleNum(singleNum)
	local vo = self:getAcVo()
	if vo and singleNum and singleNum > 0 then
		vo.singleNum = singleNum
	elseif singleNum ==nil then
		vo.singleNum =0
	end
end
function acGeneralRecallVoApi:getSingleNum( )
	local vo = self:getAcVo()
	if vo and vo.singleNum then
		return vo.singleNum
	end
	return 0
end

-- function acGeneralRecallVoApi:setSingleNum(singleNum)
-- 	local vo = self:getAcVo()
-- 	if vo and singleNum and singleNum > 0 then
-- 		vo.singleNum = singleNum
-- 	elseif singleNum ==nil then
-- 		vo.singleNum =0
-- 	end
-- end
-- function acGeneralRecallVoApi:getSingleNum( )
-- 	local vo = self:getAcVo()
-- 	if vo and vo.singleNum then
-- 		return vo.singleNum
-- 	end
-- 	return 0
-- end

function acGeneralRecallVoApi:setCurPayGems(curPayGem)
	local vo = self:getAcVo()
	if vo and curPayGem and curPayGem > 0 then
		vo.curPayGem = curPayGem
	elseif curPayGem ==nil then
		vo.curPayGem =0
	end
end
function acGeneralRecallVoApi:getCurPayGems( )
	local vo = self:getAcVo()
	if vo and vo.curPayGem then
		return vo.curPayGem
	end
	return 0
end

function acGeneralRecallVoApi:getIsNeedGem( )--玩家要送的当前礼物是否需要消费金币（0：NO 1：YES 2:用道具） curPayGem:具体金币数量
	local vo = self:getAcVo()
	if vo and vo.isNeedGem then
		return vo.isNeedGem
	end
	return 0
end

function acGeneralRecallVoApi:setIsNeedGem(isNeedGem)
	local vo = self:getAcVo()
	if vo and isNeedGem then
		vo.isNeedGem = isNeedGem
		-- print("in setIsNeedGem---->",vo.isNeedGem,isNeedGem)
	elseif isNeedGem ==nil then
		vo.isNeedGem =0
	end
end

function acGeneralRecallVoApi:getMyFriend( )----玩家选择的战友:7000093
	local vo = self:getAcVo()
	if vo and vo.myFriend then
		return vo.myFriend,vo.myFriendName
	end
	return 0
end

function acGeneralRecallVoApi:setMyFriend( myFriend,name)
	local vo = self:getAcVo()
	if vo and myFriend then
		vo.myFriend = myFriend
		vo.myFriendName = name
	elseif myFriend ==nil then
		vo.myFriend =0
		vo.myFriendName =""
	end
end

function acGeneralRecallVoApi:getFixGiftType( )
	local vo = self:getAcVo()
	if vo then
		return vo.isFixGift
	end
	return false
end
function acGeneralRecallVoApi:setFixGiftType(fixType)
	local vo = self:getAcVo()
	if vo and fixType then
		vo.isFixGift = fixType
	elseif fixType ==nil then
		vo.isFixGift =false
	end
end

function acGeneralRecallVoApi:cleanSendingData( )
	self:setFixGiftType()
    self:setCurSid()
    self:setPayPropKey()
    self:setCurGiftNum()
    self:setIsNeedGem()
    self:setNeedCurPayProp()
    self:setSingleNum()
    self:setCurPayGems()
end


-----------------流失玩家使用

function acGeneralRecallVoApi:getNeedVipTb( )
	local vo = self:getAcVo()
	if vo and vo.needVipTb then
		return vo.needVipTb
	end
end

function acGeneralRecallVoApi:setBd(bd)
	local vo = self:getAcVo()
	if vo and bd then
		vo.bd =bd
	end
end

function acGeneralRecallVoApi:getOldPlayerBD( )--目前只用于流失玩家的绑定信息
	local vo = self:getAcVo()
	if vo and vo.bd and SizeOfTable(vo.bd) >0  then
		if self:getPlayerType() == 1 and vo.bd[4] ==nil then
			return vo.bd[1]
		end
		return vo.bd
	end
	return nil
end

------
function acGeneralRecallVoApi:getPlayerType( )
	local vo = self:getAcVo()
	if vo and vo.playertype then
		-- print("vo.playertype----->",vo.playertype)
		return vo.playertype
	end
	-- print("error~~~~~!!!!!@@@@@@###### in getPlayerType",vo.playertype)
	return nil
end

------------------------------------------------------------------
----------------------------第一个面板相关信息------------------------
------------------------------------------------------------------
function acGeneralRecallVoApi:getVipReward( )
	local vo = self:getAcVo()
	if vo and vo.vipReward then
		return vo.vipReward
	end
	return nil
end
function acGeneralRecallVoApi:getBindReward( )
	local vo = self:getAcVo()
	if vo and vo.bindReward then
		return vo.bindReward
	end
	return nil
end

function acGeneralRecallVoApi:getBindList()
	local bindList={}
	local ptype=self:getPlayerType()
	if ptype==1 then
		bindList=self:getOldPlayerBD()
	else
		if self.bindList then
			bindList=self.bindList
		end
	end
	return bindList
end

function acGeneralRecallVoApi:addBindPlayer(player)
	if self.bindList==nil then
		self.bindList={}
	end
	if player then
		table.insert(self.bindList,player)
		local vo=self:getAcVo()
		if vo then
			if vo.addRecallNum==nil then
				vo.addRecallNum=1
			else
				vo.addRecallNum=vo.addRecallNum+1
			end
			self.refreshFlag=true
		end
		self:sortBindList()
	end
end

function acGeneralRecallVoApi:sortBindList()
	local ptype=self:getPlayerType()
	if ptype==2 and self.bindList then
		local sortBindList = {}
		for k,v in pairs(self.bindList) do
			table.insert(sortBindList,v)
		end
		if SizeOfTable(self.bindList) > 0 then
			local function sortFunc( a,b )
				return  a[7] > b[7]
			end
			table.sort(sortBindList,sortFunc)
		end
		self.bindList = sortBindList
	end
end

function acGeneralRecallVoApi:showBindListDialog(layerNum)
	local function sureCallback()
	end
	local bindList=acGeneralRecallVoApi:getBindList()
    local td=acGeneralRecallSmallDialog:new()
    td:init(4,sureCallback,nil,layerNum,getlocal("bindRecord"),nil,nil,nil,nil,bindList)
end

function acGeneralRecallVoApi:showSelectFriendDialog(layerNum,sureCallback,cancleCallback)
	-- local function sureCallback()
	-- end
    local td=acGeneralRecallSmallDialog:new()
    td:init(2,sureCallback,cancleCallback,layerNum,getlocal("chooseComrade"),nil,nil,nil,nil,self.bindList)
end

--是否已经赠送了该战友
function acGeneralRecallVoApi:isGifted(uid)
	local vo=self:getAcVo()
	if vo and vo.dsu then
		for k,v in pairs(vo.dsu) do
			if tostring(v)==tostring(uid) then
				return true
			end
		end
	end
	return false
end

function acGeneralRecallVoApi:cleanDsu( )
	local vo = self:getAcVo()
	if vo and vo.dsu then
		vo.dsu ={}
	end
end

function acGeneralRecallVoApi:getShowReward( )--返回宝箱奖励相关数据
	local playertype = self:getPlayerType()
	if playertype == 1 then
		return self:getVipReward()
	elseif playertype ==2 then
		return self:getBindReward()
	end
end
--显示宝箱内容
function acGeneralRecallVoApi:showRewardKu(title,layerNum,reward,desStr,titleColor)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acOpenyearSmallDialog"

    local height=540
    local tvHeight=250
    local rewardTb=FormatItem(reward[1],nil,true)
    if SizeOfTable(rewardTb)<5 then
    	height=height-125
    	tvHeight=125
    end
    acOpenyearSmallDialog:showOpenyearRewardDialog("TankInforPanel.png",CCSizeMake(550,height),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),true,layerNum+1,reward,title,desStr,tvHeight,titleColor)
end

-- 1 未完成 2 可领取 3 已领取
function acGeneralRecallVoApi:getReceivedState(id)
	local vo = self:getAcVo()
	if vo and vo.receivedRewardTb then
		for k,v in pairs(vo.receivedRewardTb) do
			if v ==id then
				return 3
			end
		end
	end
	local ptype=self:getPlayerType()
	if ptype==1 then --流失玩家
		local needVip = self:getNeedVipTb()---只能用于流失玩家
		if playerVoApi:getVipLevel() >= needVip[id] and self:getOldPlayerBD() then
			return 2
		end
	elseif ptype==2 then --活跃玩家
		local needPeopleTb=self:getNeedPeopleTb()
		local needPeople=needPeopleTb[id] or 10000
		local recallNum=self:getAddRecallNum()
		if recallNum>=needPeople then
			return 2
		end
	end

	return 1
end

function acGeneralRecallVoApi:setReceivedReward( receTb )--设置宝箱领取的最新记录
	local vo = self:getAcVo()
	if vo and receTb then
		vo.receivedRewardTb = receTb
	end
end

function acGeneralRecallVoApi:socketGeneralRecall(cmd,params,callBack,rewardlist,score)
	local function dataHandler(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData and sData.data then
				if sData.data.djrecall then
					self:updateData(sData.data.djrecall)
					if sData.data.djrecall.br then
						self:setReceivedReward(sData.data.djrecall.br)
					end
				end
				if cmd~="active.djrecall.gift2" then
					if rewardlist then
						for k,v in pairs(rewardlist) do
							G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
						end
						if rewardlist then
		                	G_showRewardTip(rewardlist)
		                end
					end
				end
				if cmd=="active.djrecall.bindList" then --玩家绑定的好友列表
					local list=sData.data.list
					if list then
						self.bindList=list
						self:sortBindList()
					end
				elseif cmd=="active.djrecall.giftList" then
				elseif cmd=="active.djrecall.gift1" then --领取单个赠送礼物
	                if params.gid then
	                	self:deleteGift(params.gid) --删除已经领取的礼物
	                end
                	local total
	     			local used
	     			if sData.data.v then
	     				total=sData.data.v
	     			end
	     			if sData.data.d then
	     				used=sData.data.d
	     			end
	     			self:setScore(total,used)
				elseif cmd=="active.djrecall.gift2" then --领取所有的赠送礼物
					if rewardlist then
						local showlist={}
						for k,list in pairs(rewardlist) do
							for kk,v in pairs(list) do
								G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
								table.insert(showlist,v)
							end
						end
						G_showRewardTip(showlist)
					end
	     			self:deleteAllGift()
					if callBack then
						callBack()
					end
	     			local total
	     			local used
	     			if sData.data.v then
	     				total=sData.data.v
	     			end
	     			if sData.data.d then
	     				used=sData.data.d
	     			end
	     			self:setScore(total,used)
				elseif cmd=="active.djrecall.task" then --获取活跃玩家的任务数据
					self.task=sData.data.task or {}
				end
				if score then
					self:addScore(score)
				end
				if cmd~="active.djrecall.gift2" then
					if callBack then
						callBack(rewardlist)
					end
				end
			end
		end
	end
	socketHelper:activeGeneralRecall(cmd,params,dataHandler)
end

function acGeneralRecallVoApi:showRewardDialog(rewardlist,layerNum,fqNum)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"    
	local titleStr=getlocal("activity_wheelFortune4_reward")
	local content={}
	for k,v in pairs(rewardlist) do
		table.insert(content,{award=v})                        
	end
	local rewardPromptStr=nil
	-- if fqNum and fqNum~=0 then
	-- 	rewardPromptStr=getlocal("activity_openyear_fetFQNum_des",{fqNum})
	-- end
	acMingjiangpeiyangSmallDialog:showGetRewardItemsDialog("TankInforPanel.png",CCSizeMake(550,560),CCRect(130,50,1,1),titleStr,rewardPromptStr,nil,content,false,layerNum+1,nil,getlocal("confirm"),nil,nil,nil,nil,true,false)
end
------------------------------------------------------------------
----------------------------第二个面板相关信息------------------------
------------------------------------------------------------------
function acGeneralRecallVoApi:isTaskhasNewReward( )
	local vo=self:getAcVo()
	local taskIndexTb={}
	local tasklist=self:getDailyTaskCfg()
	if tasklist then
		local num=SizeOfTable(tasklist)
		for i=1,num do
			local index=i
			local taskId="t" .. i
			local isFinished =self:getTaskState(taskId)
			if isFinished then
				return true
			end
		end
	end
	return false
end

function acGeneralRecallVoApi:getTaskIndexTb()
	local vo=self:getAcVo()
	local taskIndexTb={}
	local tasklist=self:getDailyTaskCfg()
	if tasklist then
		local num=SizeOfTable(tasklist)
		for i=1,num do
			local index=i
			local taskId="t" .. i
			local isFinished,isAllGet=self:getTaskState(taskId)
			if isFinished==true and isAllGet==false then
				index=index+100
			elseif isFinished==false and isAllGet==false then
				index=index+1000
			elseif isAllGet==true then
				index=index+10000
			end
			table.insert(taskIndexTb,{index=index,taskId=taskId})
		end
	end
	local function sortFunc(a,b)
		return a.index<b.index
	end
	table.sort(taskIndexTb,sortFunc)
	return taskIndexTb
end

function acGeneralRecallVoApi:getDailyTaskCfg()--取到 日常任务的相关数据
	local vo=self:getAcVo()
	local ptype=self:getPlayerType()
	local tasklist={}
	if vo and vo.task1 and vo.task2 then
		if ptype==2 then
			tasklist=vo.task2
		else
			tasklist=vo.task1
		end
	end
	return tasklist
end

function acGeneralRecallVoApi:getDailyTaskData()
	local vo=self:getAcVo()
	local ptype=self:getPlayerType()
	local taskTb={} --当前任务进度
	local numTb={} --任务奖励领取次数
	if vo then
		if ptype==2 then
			taskTb=self.task or {}
		else
			if vo and vo.task then
				taskTb=vo.task
			end
		end
	end
	numTb=vo.tf or {}
	return taskTb,numTb
end

--获取任务的状态（任务是否完成，任务奖励是否全部领取）
function acGeneralRecallVoApi:getTaskState(tid)
	local taskTb,numTb=self:getDailyTaskData()
	local tasklist=self:getDailyTaskCfg()
	local taskCfg=tasklist[tid]
	local isFinished=false --是否完成
	local isAllGet=false --是否已经领取所有奖励
	if taskCfg then
		local cur=taskTb[tid] or 0
		local num=numTb[tid] or 0
		local needNum=1000
		if type(taskCfg.needNum)=="table" then
			needNum=taskCfg.needNum[1]
		else
			needNum=taskCfg.needNum
		end
		if math.floor(cur/needNum)>num then
			isFinished=true
		end
		if num>=taskCfg.limit then
			isAllGet=true
		end
	end
	return isFinished,isAllGet
end

function acGeneralRecallVoApi:goToTaskDialog(tid,layerNum)
	local key
	if tid=="t1" then --充值
		key="gb"
	elseif tid=="t2" or tid=="t4" then --世界地图
		key="pe"
	elseif tid=="t3" then --关卡
		key="cn"
	end
	-- print("key,tid",key,tid)
	if key then
		G_goToDialog(key,layerNum,true)
	end
end

function acGeneralRecallVoApi:getTaskDescKey(tid)
	local vo=self:getAcVo()
	local ptype=self:getPlayerType()
	local key=""
	if ptype==2 then
		local tasklist=self:getDailyTaskCfg()
		local taskCfg=tasklist[tid]
		if taskCfg and taskCfg.type and taskCfg.type==2 then
			key="activity_generalRecall_getVipPlayer2"
		else
			key="activity_generalRecall_getVipPlayer"
		end
	else
		key="activity_generalRecall_lb_"..tid
	end
	return key
end

function acGeneralRecallVoApi:getCurScore( )
	local vo=self:getAcVo()
	local score=0
	if vo and vo.score then
		local usedNum=vo.d or 0
		-- print("vo.score,usedNum----->",vo.score,usedNum)
		score=tonumber(vo.score)-tonumber(usedNum)
		if score<0 then
			score=0
		end
	end
	return score
end

function acGeneralRecallVoApi:setScore(total,used)
	local vo=self:getAcVo()
	if vo then
		if total then
			vo.score=total
		end
		if used then
			vo.d=used
		end
	end	
end

function acGeneralRecallVoApi:addScore(score)
	local vo=self:getAcVo()
	if vo then
		vo.score=score
	end
end

function acGeneralRecallVoApi:getExchangeCfg() --任务兑换配置信息
	local vo=self:getAcVo()
	local ptype=self:getPlayerType()
	if vo and vo.exchange and vo.exchange[ptype] then
		local exchangeCfg=vo.exchange[ptype]
		local reward=FormatItem(exchangeCfg.r,nil,true)

		return reward[1],exchangeCfg.need,exchangeCfg.limit--need 任务需要的点数，limit 任务能领取的最多次数
	end
	return nil
end

function acGeneralRecallVoApi:getCurExchange()
	local vo=self:getAcVo()
	if vo and vo.ex then
		return vo.ex
	end
	return 0
end

function acGeneralRecallVoApi:getGiftList()
	local vo=self:getAcVo()
	if vo and vo.g then
		return vo.g
	end
	return {}
end

function acGeneralRecallVoApi:getAllGiftRewardAndCost()
	local rewardlist={}
	local totalCost=0
	local giftlist=self:getGiftList()
	for k,gift in pairs(giftlist) do
		local sid=gift[1]
		local reward,cost=self:getGiftRewardAndCost(k,sid)
		table.insert(rewardlist,reward)
		totalCost=totalCost+cost
	end

	return rewardlist,totalCost
end
function acGeneralRecallVoApi:getGiftRewardAndCost(gid,sid)
	-- print("gid,sid",gid,sid)
	local vo=self:getAcVo()
	local cost=0
	local reward={}
	if vo and vo.donateReward and vo.g then
		local gift=vo.g[gid]
		if gift then
			local num=gift[2] or 0
			for k,v in pairs(vo.donateReward) do
				local cfg=v[sid]
				if cfg then
					-- print("sid,num",sid,num)
					reward=FormatItem(cfg.reward,nil,true)
					reward[1].num=num
					cost=cfg.usedonate*num
					do break end
				end
			end
		end
	end
	-- return {num=53,index=0,id=10006,desc="sample_ship_des_a6",bgname="",name="虎王坦克",type="o",key="a10006",eType="",pic="TankLv6.png"}
	return reward,cost
end

function acGeneralRecallVoApi:deleteGift(gid)
	local vo=self:getAcVo()
	if vo and vo.g then
		table.remove(vo.g,gid)
	end
end

function acGeneralRecallVoApi:deleteAllGift()
	local vo=self:getAcVo()
	if vo and vo.g then
		vo.g={}
	end
end

function acGeneralRecallVoApi:getLimitDay()
	local vo=self:getAcVo()
	if vo and vo.data and vo.data.limitDay then
		return vo.data.limitDay
	end
	return 10
end

function acGeneralRecallVoApi:setInviteCode(code)
	self.inviteCode=code
end

function acGeneralRecallVoApi:getReceiveInviteCode()
	return self.inviteCode
end

function acGeneralRecallVoApi:setRefreshFlag(flag)
	self.refreshFlag=flag
end

function acGeneralRecallVoApi:getRefreshFlag()
	return self.refreshFlag
end

--配件信息得单独拉取数据
function acGeneralRecallVoApi:getAllAccessory(callback)
 	accessoryVoApi:refreshData(callback)
end

function acGeneralRecallVoApi:clearAll()
	self.bindList=nil
	self.task=nil
	self.inviteCode=nil
	self.refreshFlag=false
end