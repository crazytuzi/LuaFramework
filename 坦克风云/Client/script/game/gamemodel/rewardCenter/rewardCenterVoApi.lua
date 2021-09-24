require "luascript/script/game/gamemodel/rewardCenter/rewardCenterVo"

rewardCenterVoApi={
	allRewardVOs={},--所有的奖励的列表
	newNum = 0, -- x新的奖励数量,假如目前一个都没有的情况下，后台推送回来后，根据这个值来显示按钮
	totalNum=0, --总的奖励数，用来判断当前页面领取完了，是否要关闭面板
	isMore=false,--是否还有更多的奖励
	maxNum=10,--每页最多显示多少条
	rtime=0,--需要重新请求的时间戳
}

function rewardCenterVoApi:formatData(data)
	if data then
		if data.total then
			self.totalNum=tonumber(data.total)
		end
		if data.rtime then
			self.rtime=data.rtime
		end
		if data.list then 
			self.allRewardVOs={}
			for k,v in pairs(data.list) do
				local rewardVO = rewardCenterVo:new()
				if G_curPlatName()=="0" then
					rewardVO:initWithData(v,(SizeOfTable(self.allRewardVOs)+1))
				else
					rewardVO:initWithData(v)
				end
				table.insert(self.allRewardVOs,rewardVO)
				-- if self.allRewardVOs[rewardVO.id]==nil then
				-- 	self.allRewardVOs[tostring(rewardVO.id)]=rewardVO
				-- end
			end
			--新发放的奖励放置在最后
			-- local sortTb=function(a,b)
		 --        return a.st<b.st
		 --    end
		 --    table.sort(self.allRewardVOs,sortTb)
			self.newNum = 0
		end
		self:updateData()
	end
end

function rewardCenterVoApi:getIsMore( ... )
	return self.isMore
end

function rewardCenterVoApi:isHasReward()
	if SizeOfTable(self.allRewardVOs)>0 then
		return true
	end
	return false
end

function rewardCenterVoApi:updateData( ... )
	if self.totalNum>SizeOfTable(self.allRewardVOs) then
		self.isMore=true
	else
		self.isMore=false	
	end
end

function rewardCenterVoApi:deleteRewardItemById(id)
	for k,v in pairs(self.allRewardVOs) do
		if v and v.id == id then
			self.allRewardVOs[k]=nil
			self.totalNum=self.totalNum-1
		end
	end	
	self:updateData()
end

function rewardCenterVoApi:deleteSuccessAllRewardItem(ids)
	for k,v in pairs(ids) do
		for kk,vv in pairs(self.allRewardVOs) do
			if vv and vv.id and vv.id == v then
				local reward = FormatItem(vv.reward)
				-- for kkk,vvv in pairs(reward) do
				-- 	G_addPlayerAward(vvv.type, vvv.key, vvv.id,tonumber(vvv.num), nil, true)
				-- end
				self.allRewardVOs[kk]=nil
				self.totalNum=self.totalNum-1
			end
		end


		-- if self.allRewardVOs[v]~=nil then
		-- 	local rewardVO=self.allRewardVOs[v]
		-- 	local reward = FormatItem(rewardVO.reward)
		-- 	for k,v in pairs(reward) do
		-- 		G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num), nil, true)
		-- 	end
		-- 	self.allRewardVOs[k]=nil
		-- 	self.totalNum=self.totalNum-1
		-- end
	end	
	self:updateData()
end

function rewardCenterVoApi:deleteFailAllRewardItem(ids)
	for k,v in pairs(ids) do
		if self.allRewardVOs[v]~=nil then
			local rewardVO=self.allRewardVOs[v]
			rewardVO:setFlag(3)
		end
	end
end

-- 关闭面板的时候，删掉所有的过期的奖励
function rewardCenterVoApi:deleteAllExpireRewardItems()
	for k,v in pairs(self.allRewardVOs) do
		if v and (v.flag == 3 or v:isExpire()==true) then
			self.allRewardVOs[k]=nil
			self.totalNum=self.totalNum-1
		end
	end
end

function rewardCenterVoApi:getRewardListById(id)
	for k,v in pairs(self.allRewardVOs) do
		if v and v.id == id then
			return v.reward
		end
	end
	return nil
end

function rewardCenterVoApi:getPointInListById(id)
	for k,v in pairs(self.allRewardVOs) do
		if v and v.id == id and v.info then
			if v.info.point then
				if v.title == "hljb" then
					if acHljbVoApi and acHljbVoApi.addPoint then
                        acHljbVoApi:addPoint(tonumber(v.info.point))
                    end
				end
			end
		end
	end
end

function rewardCenterVoApi:getRewardVoByIndex(idx)
	local index = 0
	for k,v in pairs(self.allRewardVOs) do
		if index == idx then
			return v
		end
		index=index+1
	end
	return nil
end

function rewardCenterVoApi:getTotalRewarNum( ... )
	return self.totalNum
end
-- 每页最多显示多少条
function rewardCenterVoApi:getMaxNum( ... )
	return self.maxNum
end

-- 最大页数
function rewardCenterVoApi:getMaxPage()
	
	local pagenum = math.ceil(self.totalNum/self.maxNum)
	return pagenum
end

function rewardCenterVoApi:getRewardVoList()
	return self.allRewardVOs
end

-- 是否显示奖励按钮
function rewardCenterVoApi:isShowRewardBtn()
	-- do return true end
	if self.newNum>0 then
		return true
	end
	if self.totalNum<=0 then
		return false
	end
	if SizeOfTable(self.allRewardVOs)>0 then
		for k,v in pairs(self.allRewardVOs) do
			if v and v.flag==1 then
				return true
			end
		end
	end
	if self.totalNum>0 then
		return true
	end
	return false
end
-- 更新新的奖励数目
function rewardCenterVoApi:setNewNum(num)
	self.newNum=num
end

function rewardCenterVoApi:setRtime(rtime)
	self.rtime=rtime
end

function rewardCenterVoApi:getNewNum()
	return tonumber(self.newNum)
end
-- 所有可以领奖的id
function rewardCenterVoApi:getAllRewardId()
	local allId = {}
	if self.allRewardVOs and SizeOfTable(self.allRewardVOs)>0 then
		for k,v in pairs(self.allRewardVOs) do
			if v then 
				table.insert(allId,v.id)
			end
		end
	end
	return allId
end

-- 清除数据
function rewardCenterVoApi:clear()
	if self.allRewardItems~=nil then
        for k,v in pairs(self.allRewardItems) do
            self.allRewardItems[k]=nil
        end
        self.allRewardItems=nil
    end
	self.allRewardItems={}
	self.newNum=0
	self.isMore=false
end