--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 
-- @DateTime:    2019-06-27 19:33:24
-- *******************************
EliteSummonModel = EliteSummonModel or BaseClass()

function EliteSummonModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function EliteSummonModel:config()
	self.drop_data = {}
	for i=1,2 do
		self.drop_data[i] = {}
	end
end
-----------------------------
--打开时物品的位置、购买按钮的状态
function EliteSummonModel:setGoodsItemPos(data)
	self.goods_item = {}
	self.get_button_status = {}
	for i,v in pairs(data) do
		self.goods_item[v.type] = v
		self.get_button_status[v.type] = v.flag
	end
end
function EliteSummonModel:getGoodsItemPos(index)
	if self.goods_item and self.goods_item[index] then
		return self.goods_item[index]
	end
	return nil
end
--基础数据
function EliteSummonModel:setPineBaseData(data)
	-- 计算刷新次数
	self.refresh_count = {}
	self.refresh_count[1] = data.ref_1
	self.refresh_count[2] = data.ref_2
	--是否打开状态
	self.presage_status = {}
	self.presage_status[1] = data.status_1 or 0 --幸运松果
	self.presage_status[2] = data.status_2 or 0 --豪华松果
	--购买次数
	self.buycount_data = {}
	self.buycount_data[1] = data.buy_1 or 0 --幸运松果
	self.buycount_data[2] = data.buy_2 or 0 --豪华松果
end
--获取松果状态
function EliteSummonModel:getIsStatus(index)
	if self.presage_status and self.presage_status[index] then
		return self.presage_status[index]
	end
	return 0
end
--松果状态刷新
function EliteSummonModel:updataPresageStatus(data)
	if self.presage_status[data.type] then
		self.presage_status[data.type] = 1
	end
end
--获取购买次数
function EliteSummonModel:getbuyCount(index)
	if self.buycount_data and self.buycount_data[index] then
		return self.buycount_data[index]
	end
	return 0
end
--更新购买次数
function EliteSummonModel:updataBuyData(data)
	if self.buycount_data[data.type1] then
		self.buycount_data[data.type1] = data.ref_count
	end
end
--立即获得活动按钮状态
function EliteSummonModel:updataPromptGetBtnStatus(data)	
	if self.get_button_status and self.get_button_status[data.type] then
		self.get_button_status[data.type] = data.flag
	end
end
--获取刷新次数
function EliteSummonModel:getReFreshCount(index)
	if self.refresh_count and self.refresh_count[index] then
		return self.refresh_count[index]
	end
	return 0
end
--刷新剥开松果的数据
function EliteSummonModel:updataOpenPeelPineData(data)
	self:updataPromptGetBtnStatus(data)
	if self.refresh_count and self.refresh_count[data.type1] then
		self.refresh_count[data.type1] = data.ref_count
	end
	if self.goods_item[data.type1] then
		self.goods_item[data.type1].rand_lists = data.rand_lists
		self.goods_item[data.type1].count = data.count
	end
end
--判断获得按钮是否可以
function EliteSummonModel:getGetButtonStatus(index)
	if self.get_button_status and self.get_button_status[index] then
		return self.get_button_status[index]
	end
	return 0
end
--掉落展示
function EliteSummonModel:setDropData(index)
	local data = Config.HolidayPredictData.data_magnificat_list
	if data and data[index] then
		local list = {}
		for i,v in pairs(data[index]) do
			table.insert(self.drop_data[index], v)
		end
	end
	return {}
end
function EliteSummonModel:getDropData(index)
	if self.drop_data and self.drop_data[index] then
		return self.drop_data[index]
	end
	return {}
end

--活动是否存在ID
function EliteSummonModel:isHolidayHasID(id)
	local status = false
	local config = Config.RecruitHolidayEliteData.data_action
	if config then
		for i,v in pairs(config) do
			if id == v.camp_id then
				status = true
				break
			end
		end
	end
	return status
end

function EliteSummonModel:setSelectSummonData(data)
	self.select_summon_data = data
end

function EliteSummonModel:getSelectSummonData()
	return self.select_summon_data
end

--自选召唤活动是否存在ID
function EliteSummonModel:isHolidayLuckyHasID(id)
	local status = false
	local config = Config.RecruitHolidayLuckyData.data_action
	if config then
		for i,v in pairs(config) do
			if id == v.camp_id then
				status = true
				break
			end
		end
	end
	return status
end

function EliteSummonModel:getSummonBg()
	local res = "timesummon_bg"
	if self.select_summon_data and Config.RecruitHolidayLuckyData.data_wish[self.select_summon_data.camp_id] then
		for k,v in pairs(Config.RecruitHolidayLuckyData.data_wish[self.select_summon_data.camp_id]) do
			if k == self.select_summon_data.lucky_bid then
				res = v.bg
				break
			end
		end
	end
	return res
end

function EliteSummonModel:__delete()
end