OpenSerVeGiftData = OpenSerVeGiftData or BaseClass()

-- 事件监听
OpenSerVeGiftData.TabbarChange = "TabbarChange"						--超值礼包主界面 右侧tabbar改变 与开服天数有关 
OpenSerVeGiftData.TeHuiGitfInfoChange = "TeHuiGitfInfoChange"		--特惠礼包 购买后刷新
OpenSerVeGiftData.LimTimeGitfInfoChange = "LimTimeGitfInfoChange"	--限时礼包 购买后刷新
OpenSerVeGiftData.MERGE_SERVER_DISCOUNT_INFO_CHANGE = "merge_server_discount_info_change" -- 合服特惠信息改变

function OpenSerVeGiftData:__init()
	if OpenSerVeGiftData.Instance then
		ErrorLog("[OpenSerVeGiftData] attempt to create singleton twice!")
		return
	end
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	OpenSerVeGiftData.Instance = self

	--限时礼包
	self.QG_gift_type = 1	--限时礼包类型
	self.limtime_gitf_Info = {}		--限时礼包信息

	--特惠礼包
	self.gift_type = 1	--当前礼包类型
	self.gift_level = 1	--当前礼包档次
	self.tehui_gitf_Info = {}
	self.fashion_award_list = {} --时装礼包奖励列表缓存

	-- 合服特惠
	self.merge_server_info = {}
	-- 合服特惠购买次数初始化成0
	for i = 1, #CombinePreferentialGiftCfg.giftCfg do
		self.merge_server_info[i] = {}
		for j = 1, #CombinePreferentialGiftCfg.giftCfg[i].GiftLevels do
			self.merge_server_info[i][j] = 0
		end
	end

	GlobalEventSystem:Bind(OtherEventType.OPEN_DAY_CHANGE, BindTool.Bind(self.OnOpenServerDayChange, self))
	GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind1(self.PassDayCallBack, self))
end

function OpenSerVeGiftData:__delete()
	self.limtime_gitf_Info = nil
	self.tehui_gitf_Info = nil
	self.fashion_award_list = nil
end

--开服天数是否超过期限天数 
--p1 = {1} 是否是开服第一天; p2 = {1, 3} 是否在第一天到第三天内
local function is_over_day(days)
	local open_day = OtherData.Instance:GetOpenServerDays()
	if open_day > 0 and open_day >= days[1] and (days[2] and open_day <= days[2] or open_day == days[1]) then
		return false
	end
	return true
end

function OpenSerVeGiftData:OnOpenServerDayChange()
	if not is_over_day(self:GetLimitGiftCfg().OpenTime) or not is_over_day(self:GetTeHuiGitfCfg().SpecialOfferOpenTime) then
		OpenSerVeGiftCtrl.SendTHInfoReq()
		OpenSerVeGiftData.Instance:SendQGInfo()
	end
end

function OpenSerVeGiftData:PassDayCallBack()
	if not is_over_day(self:GetLimitGiftCfg().OpenTime) or not is_over_day(self:GetTeHuiGitfCfg().SpecialOfferOpenTime) then
		OpenSerVeGiftCtrl.SendTHInfoReq()
		OpenSerVeGiftData.Instance:SendQGInfo()
	end
end

--根据配置生成tabbar列表
function OpenSerVeGiftData:MianUIIconIsShow()
	return not is_over_day(self:GetLimitGiftCfg().OpenTime) or not is_over_day(self:GetTeHuiGitfCfg().SpecialOfferOpenTime)
end

--根据配置生成tabbar列表
function OpenSerVeGiftData:GetTabVisList()
	local list = {}

	for i,v in ipairs(self:GetTabNameList()) do
		if v.tag == "SaleGift" then
			--特惠礼包
			list[i] = not is_over_day(self:GetTeHuiGitfCfg().SpecialOfferOpenTime) and self:GetTHNextCanBuyIdx() ~= nil
		elseif v.tag == "LimitTimeBuy" then
			--限时礼包
			if not is_over_day(self:GetLimitGiftCfg().OpenTime) then
				list[i] = not is_over_day(self:GetLimitGiftCfg().giftCfg[v.id].openSvrDays)
			else
				list[i] = false
			end
		end
	end

	return list
end

--根据配置生成tabbar列表
function OpenSerVeGiftData:GetTabNameList()
	if nil == self.tabbar_name_list then
		self.tabbar_name_list = {}
		--特惠礼包
		table.insert(self.tabbar_name_list, {name = "特惠礼包", tag = "SaleGift"})

		--限时礼包
		for i,v in ipairs(self:GetLimitGiftCfg().giftCfg) do
			table.insert(self.tabbar_name_list, {name = v.giftName, id = v.id, tag = "LimitTimeBuy"})
		end
	end

	return self.tabbar_name_list
end




---------------------------------
--特惠礼包

----获取数据
--获取配置
function OpenSerVeGiftData:GetTeHuiGitfListByCfg()
	return self:GetTeHuiGitfCfg().SpecialOffer
end

function OpenSerVeGiftData:GetTeHuiGitfTypeAndLevelCfg()
	if nil == self:GetTeHuiGitfCfg().SpecialOffer[self.gift_type] then 
		ErrorLog("不存在的礼包类型")
	elseif nil == self:GetTeHuiGitfCfg().SpecialOffer[self.gift_type].GiftLevels[self.gift_level] then
		ErrorLog("不存在的礼包档次" .. self.gift_level)
	end

	return self:GetTeHuiGitfCfg().SpecialOffer[self.gift_type].GiftLevels[self.gift_level]
end

function OpenSerVeGiftData:GetTeHuiGitfCfg()
	if nil == PreferentialGiftCfg then
		ConfigManager.Instance:GetConfig("scripts/config/server/config/activityconfig/OpenServer/PreferentialGiftCfg")
	end
	return PreferentialGiftCfg
end

--获取下级礼包档次等级
function OpenSerVeGiftData:GetTHNextCanBuyIdx()
	for i,v in ipairs(self.tehui_gitf_Info) do
		for _, v2 in ipairs(v) do
			if v2 == 0 then
				return i
			end
		end
	end
end

--获取当前礼包档次等级
function OpenSerVeGiftData:GetTeHuiGiftType()
	return self.gift_type
end

--获取当前礼包档次等级
function OpenSerVeGiftData:GetTeHuiGiftLevel()
	if not self:GetTeHuiGiftCanBuyLevel() then
		return self:GetGiftMaxLevel()
	else
		return self:GetTeHuiGiftCanBuyLevel() - 1
	end

	return not self:GetTeHuiGiftCanBuyLevel() and self:GetGiftMaxLevel() or self:GetTeHuiGiftCanBuyLevel() - 1
end

--根据类型取礼包档次 类型根据礼包配置id
function OpenSerVeGiftData:GetTeHuiGiftCanBuyLevel()
	if nil == self.tehui_gitf_Info[self.gift_type] then return 1 end
	for i,v in ipairs(self.tehui_gitf_Info[self.gift_type]) do
		if v == 0 then return i end
	end
end

function OpenSerVeGiftData:GetGiftMaxLevel()
	return #self:GetTeHuiGitfCfg().SpecialOffer[self.gift_type].GiftLevels
end

--根据礼包类型 礼包档次 获取购买所需元宝
function OpenSerVeGiftData:GetBuyNeedGold()
	return self:GetTeHuiGitfTypeAndLevelCfg().money.count
end

--根据礼包类型 礼包档次 获取奖励配置
function OpenSerVeGiftData:GetAwardItemList()
	local por = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX) 

	if self.gift_type == 1 then 	--时装区分性别
		if nil == self.fashion_award_list[self.gift_level] then
			local list = {}
			local idx = 1
			for i,v in ipairs(self:GetTeHuiGitfTypeAndLevelCfg().award[por]) do
				if v.sex == - 1 or v.sex == sex then
					list[idx] = v
					idx = idx + 1
				end
			end
			self.fashion_award_list[self.gift_level] = list
		end
		return self.fashion_award_list[self.gift_level]
	end
	return self:GetTeHuiGitfTypeAndLevelCfg().award[por]
end

--请求购买
function OpenSerVeGiftData:SendTHBuyReq()
	OpenSerVeGiftCtrl.SendTHBuyReq(self.gift_type, self.gift_level)
end

----设置数据
function OpenSerVeGiftData:SetGiftType(gift_type)
	self.gift_type = gift_type
	self.gift_level = self:GetTeHuiGiftCanBuyLevel() or self:GetGiftMaxLevel()
end

function OpenSerVeGiftData:SetTeHuiInfo(...)
	if select(1, ...) == nil then return end

	if type(select(1, ...)) == "table" then
		--保存礼包信息
		self.tehui_gitf_Info = select(1, ...)
	else
		--购买成功设置			礼包类型		礼包档次     设置为1则已购买
		self.tehui_gitf_Info[select(1, ...)][select(2, ...)] = 1
		self:SetGiftType(select(1, ...))
	end

	self:DispatchEvent(OpenSerVeGiftData.TabbarChange)
	self:DispatchEvent(OpenSerVeGiftData.TeHuiGitfInfoChange)
end





--------------------------------------
--限时礼包
--获取限时礼包配置

function OpenSerVeGiftData:GetSpareTime()
	local s_time = 24 * 60 * 60 
	local end_day = self:GetLimitGiftCfg().giftCfg[self.QG_gift_type].openSvrDays[2] or self:GetLimitGiftCfg().giftCfg[self.QG_gift_type].openSvrDays[1]
	local spare_day = end_day - OtherData.Instance:GetOpenServerDays() + 1
	s_time = 24 * 60 * 60 * spare_day - (TimeCtrl.Instance:GetServerTime() + 8 * 60 * 60) % (24 * 60 * 60)

	return s_time
end

--获取生成的tabbar列表中对应idx 所需的配置
function OpenSerVeGiftData:GetLimitGiftList()
	local list = {}
	for i,v in ipairs(self:GetLimitGiftCfg().giftCfg[self.QG_gift_type].GiftLevels) do
		list[i] = v
		list[i].idx = i
	end

	table.sort(list, function (a, b)
		--判断剩余可购买次数 大于零 往上排
		if a.buyTms - self:GetBuyNumByIdx(a.idx) == 0
		and b.buyTms - self:GetBuyNumByIdx(b.idx) == 0 then
			return a.idx < b.idx
		elseif a.buyTms - self:GetBuyNumByIdx(a.idx) > 0
		and b.buyTms - self:GetBuyNumByIdx(b.idx) > 0 then
			return a.idx < b.idx
		else
			return a.buyTms - self:GetBuyNumByIdx(a.idx) > b.buyTms - self:GetBuyNumByIdx(b.idx)
		end
	end)

	return list
end

function OpenSerVeGiftData:GetQiangGouInfo(type)
	if nil == self.limtime_gitf_Info[type] then
		self.limtime_gitf_Info[type] = {0, 0, 0, 0}
	end
	return self.limtime_gitf_Info[type]
end

function OpenSerVeGiftData:GetLimitGiftCfg()
	if nil == SuperPreferentialGiftCfg then
		ConfigManager.Instance:GetConfig("scripts/config/server/config/activityconfig/OpenServer/SuperPreferentialGiftCfg")
	end
	return SuperPreferentialGiftCfg
end

--根据礼包类型 档次 获取下级可购买礼包
function OpenSerVeGiftData:GetNextCanBuyIdx()
	for i,v in ipairs(self:GetLimitGiftList()) do
		if self:GetCanBuyNumByIdx(v.idx) > 0 then
			return i
		end
	end
	return 0
end

--根据礼包类型 档次 获取可购次数
function OpenSerVeGiftData:GetCanBuyNumByIdx(idx)
	return self:GetLimitGiftCfg().giftCfg[self.QG_gift_type].GiftLevels[idx].buyTms - self.limtime_gitf_Info[self.QG_gift_type][idx] or 0
end

--根据礼包类型 档次 获取已购次数
function OpenSerVeGiftData:GetBuyNumByIdx(idx)
	if nil == self.limtime_gitf_Info[self.QG_gift_type] or 
	 nil == self.limtime_gitf_Info[self.QG_gift_type][idx] then
		return 0
	end
	return self.limtime_gitf_Info[self.QG_gift_type][idx] or 0
end

--设置数据
function OpenSerVeGiftData:SetTabbarIdx(idx)
	--选择限时礼包时 刷新礼包类型
	if self.tabbar_name_list[idx].id then
		self.QG_gift_type = self.tabbar_name_list[idx].id
	end
end

function OpenSerVeGiftData:SetQiangGouInfo(...)
	if select(1, ...) == nil then return end

	if type(select(1, ...)) == "table" then
		--保存礼包信息		所有礼包的购买次数信息-剩余购买次数
		self.limtime_gitf_Info = select(1, ...)
	else
		--购买成功设置			礼包类型		礼包档次     设置为1则已购买
		self.limtime_gitf_Info[select(1, ...)][select(2, ...)] = 1
	end

	self:DispatchEvent(OpenSerVeGiftData.LimTimeGitfInfoChange)
end

--请求信息
function OpenSerVeGiftData:SendQGInfo()
	--请求所有正在开启的限时活动数据
	for i,v in ipairs(self:GetTabNameList()) do
		if v.id and self:GetTabVisList()[i] then
			OpenSerVeGiftCtrl.SendQGInfoReq(v.id)
		end
	end
end

--请求购买
function OpenSerVeGiftData:SendQGBuyReq(idx)
	OpenSerVeGiftCtrl.SendQGBuyReq(self.QG_gift_type, idx)
end

function OpenSerVeGiftData:GetMergeSeverList()
	if nil == self.merge_sever_list then
		self.merge_sever_list = {}
		-- 合服特惠
		for i,v in ipairs(CombinePreferentialGiftCfg.giftCfg) do
			table.insert(self.merge_sever_list, {name = v.giftName, id = v.id, tag = "LimitTimeBuy"})
		end
	end

	return self.merge_sever_list
end

-- 设置合服特惠信息
function OpenSerVeGiftData:SetMergeServerDiscountInfo(protocol)
	self.merge_server_info.day = protocol.day
	self.merge_server_info.type = protocol.type
	for i = 1, #protocol.buy_times_list do
		self.merge_server_info[protocol.type][i] = protocol.buy_times_list[i]
	end
	self:DispatchEvent(OpenSerVeGiftData.MERGE_SERVER_DISCOUNT_INFO_CHANGE)
end

-- 获取合服特惠信息
function OpenSerVeGiftData:GetMergeServerDiscountInfo(type)
	local list = {}
	local cfg = CombinePreferentialGiftCfg.giftCfg[type].GiftLevels
	for i = #self.merge_server_info[type], 1, -1 do
		if self.merge_server_info[type][i] == cfg[i].buyTms then
			table.insert(list, {type = type, index = i})
		else
			table.insert(list, 1, {type = type, index = i})
		end
	end
	return list
end

function OpenSerVeGiftData:GetMergeServerBuyTimes(type, index)
	return self.merge_server_info[type][index]
end

-- 获取合服特惠剩余时间
function OpenSerVeGiftData:GetMergeServerDiscountLeftTime(type)
	-- 合服特惠跨天结束,时间需转成当天开始的时间
	local combind_time = TimeUtil.NowDayTimeStart(OtherData.Instance:GetCombindTime())
	local length = #CombinePreferentialGiftCfg.giftCfg[type].combineDays * 86400
	local left_time = length - (os.time() - combind_time)
	return left_time
end