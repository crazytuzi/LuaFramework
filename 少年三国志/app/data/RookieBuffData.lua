--新手光环数据 
require("app.cfg.rookie_buff_info")
require("app.cfg.rookie_reward_info")


local RookieBuffData = class("RookieBuffData")


function RookieBuffData:ctor()

	self:_initBaseInfo()

end

function RookieBuffData:_initBaseInfo()
	
	self._data_ready = false
	self._create_day = 1  			--开服第几天注册
	self._get_award_ids = {}  		--已领取的id	
	self._award_list = {}  			--可可领奖列表	
	self._buff_info = nil  			--新手buff信息	

	self._isActive = false          --活动是否开启

end


function RookieBuffData:updateRookieInfo(data)

	if not data then return end
	
	--dump(data)

	self:_initBaseInfo()

	--从开服到注册时间的秒数
	self._create_day = rawget(data, "create_time") and math.ceil((data.create_time+1)/86400) or 1
	self._isActive = rawget(data, "active") and data.active or false

	--self._create_day = 2
	--self._isActive = false
	
	--print("---------------------create_day="..self._create_day)

    if rawget(data, "award_id") and data.award_id ~= nil then
        for i,v in ipairs(data.award_id) do
            self._get_award_ids[v] = v
        end
    end

    --初始化_buff_info
    self._buff_info = self:_initBuffInfo()

    if not self._buff_info then
    	return
    end

    --初始化_award_list
    self:_initAwardlist()

    self._data_ready = true

end

function RookieBuffData:updateAward(data)

	if not data or not rawget(data, "id") then return end

	local award_id = rawget(data, "id")

	if type(award_id) ~= "number" then return end

	self._get_award_ids[award_id] = award_id

end

------------------------

function RookieBuffData:getCreateDay()
	return self._create_day
end


function RookieBuffData:dataReady()
	return self._data_ready
end

function RookieBuffData:isActive()
	return self._isActive
end

function RookieBuffData:getBuffExpAdd( )
	if not self:checkInBuff() then
		return 0
	end
	return self._buff_info.buff
end

function RookieBuffData:getBuffExp( addExp )

	local buffExp = ""

	if not self:checkInBuff() then
		return buffExp
	end

	local exp = 0

	if addExp and type(addExp) == "number" and addExp > 0  and self._buff_info then
		exp = math.floor(self._buff_info.buff*addExp/100)
	end

	if exp > 0 then
		buffExp = G_lang:get("LANG_ROOKIE_BUFF_ADDEXP",{addExp=exp})
	end

	return buffExp
end


function RookieBuffData:_initBuffInfo()

	for i = 1, rookie_buff_info.getLength() do
		local buffInfo = rookie_buff_info.indexOf(i)
		if buffInfo and buffInfo.day == self._create_day then
			return buffInfo
		end
	end

	return nil

end


function RookieBuffData:getBuffInfo()
	return self._buff_info
end

function RookieBuffData:_initAwardlist()

	if self._buff_info then
		for i=1, rookie_reward_info.getLength() do   
        	local v = rookie_reward_info.indexOf(i)
        	--rookie_reward_info 表中的day字段对应rookie_buff_info表中的id
        	if v.day == self._buff_info.id then
            	self._award_list[#self._award_list+1]=v
        	end
   	 	end
   	end
   	--表顺序有问题，只能这样了
   	local sortA = function(a,b)
   	  if (a.id == 6 or b.id == 6) then
   	    local A = (a.id == 6) and 1 or 0
   	    local B = (b.id == 6) and 1 or 0
   	    return A > B
   	  end
   	  return a.id < b.id
   	end
   	table.sort(self._award_list,sortA)
end


function RookieBuffData:getAwardlist()
	return self._award_list
end


--是否显示领奖入口按钮
function RookieBuffData:showReward()
	
	if not self:isActive() then 
		return false
	end

	--不满足注册天数要求或者已领取所有奖励则不显示

	if not self._buff_info then 
		return false
	end

	if self:_hasGetAllAwards() and not self:checkInBuff() then
		return false
	end

	return true

end


function RookieBuffData:checkInBuff()
	
	if not self:isActive() or not self._buff_info then 
		return false
	end

	local last_user_level = G_moduleUnlock:getRealLastLevel()

	local open_level = self._buff_info.open_level
	local close_level = self._buff_info.close_level

	--刚升级达到buff加成下限要求  不在buff期
	if last_user_level > 0 and last_user_level < open_level and G_Me.userData.level >= open_level then 
		--print("---------------- levelup in rookiebuff")
		G_moduleUnlock:setRealLastLevel(0)  --扫荡时某次升级后需要充值lastlevel
		return false
	end

	--刚升级达到或超过buff加成上限  认为在buff期
	if last_user_level > 0 and last_user_level < close_level and G_Me.userData.level >= close_level then
		--print("---------------- levelup out rookiebuff")
		G_moduleUnlock:setRealLastLevel(0)  --扫荡时某次升级后需要充值lastlevel
		return true
	end

	--满足等级要求 包含上限
	return G_Me.userData.level >= open_level and 
			G_Me.userData.level <= close_level 
			
end

function RookieBuffData:canGetAward(_awardInfo)

	if not _awardInfo or type(_awardInfo) ~= "table" then
		return false
	end

	return not self._get_award_ids[_awardInfo.id] and _awardInfo.level <= G_Me.userData.level 
		
end

function RookieBuffData:hasGetAward(_awardInfo)

	if not _awardInfo or type(_awardInfo) ~= "table" then
		return false
	end

	return self._get_award_ids[_awardInfo.id] ~= nil 

end

function RookieBuffData:_hasGetAllAwards()

	if #self._get_award_ids > 0 and self._buff_info and #self._award_list > 0 then
	
		for k, v in pairs(self._award_list) do
        	if self._get_award_ids[v.id] == nil then
        		return false
        	end
    	end

    	return true
    end

    return false
end


function RookieBuffData:isAwardNotReached(_awardInfo)

	if not _awardInfo or type(_awardInfo) ~= "table" then
		return false
	end

	return not self._get_award_ids[_awardInfo.id] and _awardInfo.level > G_Me.userData.level 
	
end

--是否有未领取的奖励
function RookieBuffData:_canGetAnyAward()
	
	if self._buff_info and #self._award_list > 0 then
	
		for k, v in pairs(self._award_list) do
        	if self:canGetAward(v) then
        		return true
        	end
    	end
    end

	return false
end

--红点提示条件：可领取奖励
function RookieBuffData:needTips( ... )
	
	return self:_canGetAnyAward() 

end



return RookieBuffData
