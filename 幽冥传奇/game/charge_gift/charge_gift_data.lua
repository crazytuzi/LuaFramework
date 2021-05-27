--------------------------------------------------------
-- 充值大礼包
--------------------------------------------------------

ChargeGiftData = ChargeGiftData or BaseClass()

ChargeGiftData.DAILY_GIFT_BAG_DATA_CHANGE = "daily_gift_bag_data_change"

function ChargeGiftData:__init()
	if ChargeGiftData.Instance then
		ErrorLog("[ChargeGiftData]:Attempt to create singleton twice!")
	end
	ChargeGiftData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.daily_gift_bag_data = {} -- 礼包数据
    for i = 1, #EveryDayGiftBagConfig.GradeGift do
	    self.daily_gift_bag_data[i] = {
		    grade = 0,
		    buy_num = 0,
		    get_num = 0,
		}
    end

end

function ChargeGiftData:__delete()
	ChargeGiftData.Instance = nil
end

----------设置----------
--------------------------------------
-- 每日礼包
--------------------------------------
function ChargeGiftData:SetDailyGiftBagDataChange(protocol)
	self.daily_gift_bag_data[protocol.grade].buy_num = protocol.buy_num
	self.daily_gift_bag_data[protocol.grade].get_num = protocol.get_num

	self:DispatchEvent(ChargeGiftData.DAILY_GIFT_BAG_DATA_CHANGE, protocol.grade)
	RemindManager.Instance:DoRemindDelayTime(RemindName.DailyGiftBag)
	GameCondMgr.Instance:CheckCondType(GameCondType.IsChargeGiftOpen)
end

function ChargeGiftData:SetDailyGiftBagData(protocol)
	for i,v in ipairs(protocol.data_list) do
		self.daily_gift_bag_data[v.grade].buy_num = v.buy_num
		self.daily_gift_bag_data[v.grade].get_num = v.get_num

		self:DispatchEvent(ChargeGiftData.DAILY_GIFT_BAG_DATA_CHANGE, v.grade)
		GameCondMgr.Instance:CheckCondType(GameCondType.IsChargeGiftOpen)
	end

	RemindManager.Instance:DoRemindDelayTime(RemindName.DailyGiftBag)	
end

function ChargeGiftData:GetDailyGiftBagData()
	return self.daily_gift_bag_data
end

-- 获取提醒显示索引 0不显示红点, 1显示红点
function ChargeGiftData.GetDailyGiftBagRemind()
	local index = 0
	local data = ChargeGiftData.Instance.daily_gift_bag_data
	local cfg = EveryDayGiftBagConfig.GradeGift
	local bool
	for i,v in ipairs(data) do
		bool = v.buy_num >= cfg[i].buylimit and v.get_num < cfg[i].buylimit
		index = bool and 1 or index
	end

	return index
end

function ChargeGiftData.GetDailyGiftBagCfg()
	local cfg = EveryDayGiftBagConfig.GradeGift
	local agent_id = GLOBAL_CONFIG.package_info.config.agent_id -- 渠道ID
	local list = {}
	for i,v in ipairs(cfg) do
		if v.agent_id[agent_id] == nil then -- 判断是否屏蔽该档位.
			list[#list + 1] = v
		end
	end

	return list
end

-- 获取当前显示档次
function ChargeGiftData:GetGiftGrade()
	local index = 1
	local cfg = EveryDayGiftBagConfig.GradeGift
	for k, v in pairs(self.daily_gift_bag_data) do
		if v.buy_num == 0 or (v.buy_num >= cfg[k].buylimit and v.get_num < cfg[k].buylimit) then
			index = k
			break
		end
	end
	index = index >= #cfg and #cfg or index

	return index
end

-- 主界面图标显示
function ChargeGiftData.GetIconOpen()
	local data = ChargeGiftData.Instance:GetDailyGiftBagData()
	local cfg = EveryDayGiftBagConfig.GradeGift
	local vis = data[#cfg].get_num >= cfg[#cfg].buylimit 

	return vis
end
--------------------
