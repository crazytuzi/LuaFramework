acAnniversaryBlessVoApi={
	donateWordkey=nil, --捐赠时记录选择的福字的key
	myWords={}, --记录玩家当前五福的数据，key值和拥有个数
	recordList={}, --记录玩家赠送五福的记录
	needRefreshRecord=true,--赠送记录刷新标记
	needRefreshWords=false, --玩家拥有五福数据刷新标记
	shopBuyCount=0 --当前玩家购买道具的次数
}

function acAnniversaryBlessVoApi:getAcVo()
	if self.vo==nil then
		self.vo=activityVoApi:getActivityVo("anniversaryBless")
	end
	return self.vo
end

--判断是否有任务奖励领取
function acAnniversaryBlessVoApi:canReward()
	local tid,cur,max,rewardCfg,hasReceived=acAnniversaryBlessVoApi:getTaskData()
	if cur==max and hasReceived and hasReceived==false then
		return true
	end
	return false
end

--获取福字的id配置信息
function acAnniversaryBlessVoApi:getWordCfg()
	local vo = self:getAcVo()
	if vo then
		return vo.word
	end
	return nil
end

--初始化玩家当前所拥有的五福数据
function acAnniversaryBlessVoApi:initWords()
	local vo = self:getAcVo()
	if vo then
		self.myWords={}
		for k,v in pairs(vo.wordCfg) do
			local word={}
			word.key=v
			word.count=0
			if vo.words and vo.words[v] then
				-- print("key====="..v.."  count======="..vo.words[v])
				word.count=vo.words[v]
			end
			table.insert(self.myWords,word)
		end
	end
end

function acAnniversaryBlessVoApi:updateWords()
	local vo = self:getAcVo()
	if vo then
		if self.myWords and SizeOfTable(self.myWords)>0 then
			for k,word in pairs(self.myWords) do
				if vo.words then
					if vo.words[word.key] then
						-- print("key====="..word.key.."  count======="..vo.words[word.key])
						word.count=vo.words[word.key]
					else
						word.count=0
					end
				end
			end
		end
	end
end

function acAnniversaryBlessVoApi:getWordsData()
	if self.myWords and SizeOfTable(self.myWords)==0 then
		self:initWords()
	end
	return self.myWords
end

function acAnniversaryBlessVoApi:getWordIconName(wordKey)
	local id = RemoveFirstChar(wordKey)
	return "blessword_c"..id..".png"
end

function acAnniversaryBlessVoApi:getWordName(wordKey)
	local id = RemoveFirstChar(wordKey)
	return getlocal("bless_word_c"..id)
end

--判断玩家是否已经达到了使用捐赠好友功能的等级
function acAnniversaryBlessVoApi:isReachDonateLv()
	local vo = self:getAcVo()
	if vo then
		local curLevel = playerVoApi:getPlayerLevel()
		if curLevel>=vo.donateLv then
			return true
		end
	end
	return false
end

function acAnniversaryBlessVoApi:getDonateLv()
	local vo = self:getAcVo()
	if vo then
		return vo.donateLv
	end
	return 30
end

function acAnniversaryBlessVoApi:getRecordList()
	local vo = self:getAcVo()
	if vo then
		self.recordList=vo.record
		--按照赠送时间排序
		local function sortFunc(r1,r2)
			return r1[4]<r2[4]
		end
		table.sort(self.recordList,sortFunc)
	end

	return self.recordList
end

function acAnniversaryBlessVoApi:getRecordTimeStr(time)
	local date=G_getDataTimeStr(time)
	return date
end

function acAnniversaryBlessVoApi:getInviteRewards()
	local vo = self:getAcVo()
	if vo then
		return vo.report
	end
	return nil
end

function acAnniversaryBlessVoApi:openGameFriendsDialog(layerNum)
	local function showFriendsDialog()
		require "luascript/script/game/scene/gamedialog/activityAndNote/acAnniversaryBlessFriendDialog"
	  	local td=acAnniversaryBlessFriendDialog:new()
	    local tbArr={}
	    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("activity_anniversaryBless_donate"),false,layerNum)
	    sceneGame:addChild(dialog,layerNum)
	end
	local function callback(fn,data)
	    local ret,sData=base:checkServerData(data)
      	if ret==true then
			showFriendsDialog()
    	end
	end

	local friendTb=friendMailVoApi:getFriendTb()
	if #friendTb==0 then
		socketHelper:friendsList(callback)
	else
		showFriendsDialog()
	end 
end

function acAnniversaryBlessVoApi:setRefreshRecordFlag(flag)
	self.needRefreshRecord=flag
end

function acAnniversaryBlessVoApi:isRefreshWords()
	return self.needRefreshWords
end

function acAnniversaryBlessVoApi:setRefreshWordsFlag(flag)
	self.needRefreshWords=flag
end

--判断今天的邀请奖励是否已经领取
function acAnniversaryBlessVoApi:isCanReceiveInviteReward()
	local vo=self:getAcVo()
	local flag=false
	local state=1--表示当前领取奖励的状态（0表示可以领取，1表示邀请好友数量不足，2表示已经领取了奖励）
	if vo then
		local inviteCount=self:getInviteCount()
		local num=self:getInviteCfg()
		if vo.get==nil and inviteCount>=num then
			flag=true
			state=0
		elseif inviteCount<num then
			flag=false
			state=1
		elseif vo.get then
			flag=false
			state=2
		end
	end
	return flag,state
end

--在活动结束前5分钟就不能再赠送好友福字了
function acAnniversaryBlessVoApi:isCanDonateFriend()
	local vo=self:getAcVo()
	if vo and base.serverTime<(vo.et-24*3600-5*60) then
		return true
	end
	return false
end

function acAnniversaryBlessVoApi:setDonateWordKey(wordKey)
	self.donateWordkey=wordKey
end

function acAnniversaryBlessVoApi:getDonateWordKey()
	return self.donateWordkey
end

function acAnniversaryBlessVoApi:clearDonateWordKey()
	self.donateWordkey=nil
end

function acAnniversaryBlessVoApi:getInviteCount()
	local vo=self:getAcVo()
	if vo then
		return vo.inviteCount
	end
	return 0
end

function acAnniversaryBlessVoApi:openRecordDialog(layerNum,parent)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acAnniversaryBlessReocrdDialog"
	local title = getlocal("bless_donate_record")	
	if self.needRefreshRecord==true then
		local function recordCallBack(fn,data)
	        local ret,sData=base:checkServerData(data)
	        if ret==true then
	        	local acVo=self:getAcVo()
	        	if acVo then
	            	acVo:updateSpecialData(sData.data)
	            	acVo:updateSpecialData(sData.data.anniversaryBless)
	        	end
	        	local dialog=acAnniversaryBlessReocrdDialog:new()
				local layer=dialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,title,true,layerNum)
	        	sceneGame:addChild(layer,layerNum)
	        	self.needRefreshRecord=false
	        end
		end
		socketHelper:syncRecordList(recordCallBack)
	else
    	local dialog=acAnniversaryBlessReocrdDialog:new()
		local layer=dialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,title,true,layerNum)
    	sceneGame:addChild(layer,layerNum)
	end
end

function acAnniversaryBlessVoApi:isToday()
	local flag = false
	local vo=self:getAcVo()
	if vo then
		flag=G_isToday(vo.t)
	end
	return flag
end

-- 是否是领奖时间
function acAnniversaryBlessVoApi:acIsStop()
	local vo=self:getAcVo()
	if vo and base.serverTime<(vo.et-24*3600) then
		return false
	end
	return true
end

function acAnniversaryBlessVoApi:getInviteCfg()
	local num=0
	local wordNum=0
	local vo = self:getAcVo()
	if vo then
		if vo.invite and vo.invite[1] and vo.invite[2] then
			num=vo.invite[1]
			wordNum=vo.invite[2]
		end
	end
	return num,wordNum
end

--判断玩家自己是不是已经集齐五福
function acAnniversaryBlessVoApi:isCollectFull()
	local isFull=false
	local num=0
	for k,word in pairs(self.myWords) do
		if word.count>0 then
			num=num+1
		end
	end
	if num==5 then
		isFull=true
	end
	return isFull
end

--获取当前已经集满五福的人数
function acAnniversaryBlessVoApi:getPlayerCountFulled()
	local finishNum=0
	local vo = self:getAcVo()
	if vo then
		if vo.finishNum then
			finishNum=vo.finishNum
		end
	end
	return finishNum
end

--当前已集齐五福的玩家个数发生变化时调用
function acAnniversaryBlessVoApi:pushMessage(params)
	local vo = self:getAcVo()
	if vo then
		vo.finishNum=params.finishNum
		if params.uid then
			if tonumber(playerVoApi:getUid())==tonumber(params.uid) then
				self:setRefreshRecordFlag(true)
			end
		end
	end
	eventDispatcher:dispatchEvent("anniversaryBless.fullCollectedChanged",nil)
	-- print("anniversaryBless.fullCollectedChanged")
end

--获取每个服玩家分的总钱数
function acAnniversaryBlessVoApi:getTotalGem()
	local gemCount=0
	local vo = self:getAcVo()
	if vo then
		gemCount=vo.totalGem
	end

	return gemCount
end

--获取第二个页签活动的任务配置
function acAnniversaryBlessVoApi:getTaskData()
	local tid="t1"
	local cur=0 --当前完成次数
	local max=0 --要完成的次数
	local rewardCfg={}
	local hasReceived=false
	local vo = self:getAcVo()
	if vo then
		if vo.taskCfg and vo.taskCfg[tid] and vo.taskCfg[tid][1] and vo.taskCfg[tid][2] then
			-- print("vo.taskData[tid]==",vo.taskData[tid])
			-- G_dayin(vo.taskData)
			if vo.taskData and vo.taskData[tid] then
				-- print("vo.taskData[tid]=======",vo.taskData[tid])
				if type(vo.taskData[tid])=="number" then --如果是数字，说明该任务还没有领取奖励，如果是字母说明已经领取
					cur=vo.taskData[tid]
				else
					cur=vo.taskCfg[tid][1]
					hasReceived=true
				end
			end
			max=vo.taskCfg[tid][1]
			rewardCfg=vo.taskCfg[tid][2]
		end
	end
	return tid,cur,max,rewardCfg,hasReceived
end

function acAnniversaryBlessVoApi:getShopData()
	local pid=0
	local cur=self.shopBuyCount
	local max=0
	local oldPrice=0
	local newPrice=0
	local vo = self:getAcVo()
	if vo then
		if vo.shop then
			for k,v in pairs(vo.shop) do
				pid=k
				max=v[1]
				oldPrice=v[2]
				newPrice=v[3]
				if self.shopBuyCount==0 and vo.buyData and vo.buyData[pid] then
					self.shopBuyCount=vo.buyData[pid]
					cur=self.shopBuyCount
				end
				break
			end
		end
	end
	return pid,cur,max,oldPrice,newPrice
end

function acAnniversaryBlessVoApi:updateShopBuyCount()
	local pid,cur,max,oldPrice,newPrice = self:getShopData()
	if self.shopBuyCount<max then
		self.shopBuyCount=self.shopBuyCount+1
	end
end

function acAnniversaryBlessVoApi:updateData(data)
	local acVo = self:getAcVo()
	if acVo then
		acVo:updateSpecialData(data)
		self:updateWords()
	end
end

--玩家等级在22级及以上才能参加活动
function acAnniversaryBlessVoApi:isCanJoinActivity()
	local curLevel = playerVoApi:getPlayerLevel()
	if tonumber(curLevel) >= 30 then
		return true,30
	end
	return false,30
end

function acAnniversaryBlessVoApi:isGemsEnough(cost)
	local isEnough = false
	if playerVoApi then
		local curGems = playerVoApi:getGems()
		if curGems >= tonumber(cost) then
			isEnough = true
		end
	end
	return isEnough
end

function acAnniversaryBlessVoApi:getTimeStr()
	local str = ""
	local vo=self:getAcVo()
	if vo then
		local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt-86400)
		str=getlocal("activity_timeLabel")..":"..timeStr
	end

	return str
end

function acAnniversaryBlessVoApi:getRewardTimeStr()
	local str = ""
	local vo = self:getAcVo()
	if vo then
		local rewardTimeStr = activityVoApi:getActivityRewardTimeStr(vo.acEt-86400,60,86400)
		str = getlocal("recRewardTime")..":"..rewardTimeStr
	end
	return str
end

function acAnniversaryBlessVoApi:resetAc()
	local vo = self:getAcVo()
	if vo then
		vo.taskData={}
		vo.buyData={}
		self.shopBuyCount=0
		donateWordkey=nil
		needRefreshRecord=true
		needRefreshWords=false
	end
end

function acAnniversaryBlessVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

function acAnniversaryBlessVoApi:clearAll()
	self.donateWordkey=nil --捐赠时记录选择的福字的key
	self.myWords={} --记录玩家当前五福的数据，key值和拥有个数
	self.recordList={} --记录玩家赠送五福的记录
	self.needRefreshRecord=true--赠送记录刷新标记
	self.needRefreshWords=false --玩家拥有五福数据刷新标记
	self.shopBuyCount=0 --当前玩家购买道具的次数
	self.vo=nil
end