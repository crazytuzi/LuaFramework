BlessingData = BlessingData or BaseClass()

BlessingData.BLESSING_NUM = "blessing_num"
BlessingData.FORTUNE_DATA = "fortune_data"
BlessingData.SHARE_DATA = "share_data"

function BlessingData:__init()
	if BlessingData.Instance then
		ErrorLog("[BlessingData]:Attempt to create singleton twice!")
	end
	BlessingData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.bind_yuan_num = 0
	self.bing_zuan_num = 0
	self.boss_num = 0
	self.share_num = 0
	self.fortune_type = 0

	self.share_item = {}
end

function BlessingData:__delete()
	BlessingData.Instance = nil
end

function BlessingData:SetMakeVowData(protocol)
	self.bind_yuan_num = protocol.bind_gold_time
	self.bing_zuan_num = protocol.bind_yuan_time

	self:DispatchEvent(BlessingData.BLESSING_NUM)
end

function BlessingData:SetFortuneData(protocol)
	self.boss_num = protocol.boss_call_num
	self.share_num = protocol.share_num
	self.fortune_type = protocol.fortune

	self:DispatchEvent(BlessingData.FORTUNE_DATA)
end

-- 置空分享数据
function BlessingData:InitShareData()
	self.share_item = {}
	MainuiCtrl.Instance:InvateTip(10, 0)
end

function BlessingData:SetShareData(protocol)
	local vo = {
		share_id = protocol.share_id,
		share_name = protocol.share_name,
		fortune_lv = protocol.fortune_lv,
	}
	table.insert(self.share_item, vo)

	self:DispatchEvent(BlessingData.SHARE_DATA)
end

-- 接受后删除某一条
function BlessingData:RemoveData(idx)
	for k, v in pairs(self.share_item) do
		if idx == v.share_id then
			table.remove(self.share_item, k)
		end
	end
	self:DispatchEvent(BlessingData.SHARE_DATA)
end

function BlessingData:GetShareData()
	return self.share_item
end

-- 获得自己好友的信息
function BlessingData:GetHyInfo(name)
	local item = SocietyData.Instance:GetRelationshipList(0)
	for k, v in pairs(item) do
		if name == v.name then
			return v
		end
	end
	return nil
end

-- BOSS召唤次数，分享次数
function BlessingData:GetFortuneNum()
	return self.boss_num, self.share_num
end

-- 运势情况
function BlessingData:GetFortuneType()
	return self.fortune_type
end

function BlessingData:GetBlessNum()
	return self.bind_yuan_num, self.bing_zuan_num
end

-- 获取暴击的次数
function BlessingData:GetBinfYuanNum(index)
	local by_item = {}
	local data = {}
	if index == 1 then
		data = pray_money_cfg.bind_coin_list
	elseif index == 2 then
		data = pray_money_cfg.bind_yb_list
	end

	for k, v in pairs(data) do
		if v[3] == 1 then
			table.insert(by_item, k)
		end
	end

	return by_item
end

-- 取得还有多少次暴击
function BlessingData:GetCritNumRemind(index)
	local data = self:GetBinfYuanNum(index)
	local num_than = 0
	local remid_num = 0
	if index == 1 then
		num_than = self.bind_yuan_num
	elseif index == 2 then
		num_than = self.bing_zuan_num
	end

	for k, v in pairs(data) do
		if num_than <= v then
			remid_num = v - num_than
			break
		end
	end

	return remid_num
end

-- 获取祈福总次数
function BlessingData:GetAllNum()
	local vip_lv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE) or 0
	local all_num = 0
	if vip_lv < 1 then
		all_num = pray_money_cfg.vip_pray_count[1]
	elseif vip_lv >= #pray_money_cfg.vip_pray_count then
		all_num = pray_money_cfg.vip_pray_count[#pray_money_cfg.vip_pray_count]
	else
		all_num = pray_money_cfg.vip_pray_count[vip_lv]
	end

	return all_num
end

-- 获取祈福次数数值和消耗
local bless_consume_cfg = {}
function BlessingData:GetBlessCfg(index)
	if nil == bless_consume_cfg[index] then
		local bless_cfg = {}
		local item_data = {}
		if index == 1 then
			bless_cfg = pray_money_cfg.bind_coin_list
		elseif index == 2 then
			bless_cfg = pray_money_cfg.bind_yb_list
		end

		for k, v in pairs(bless_cfg) do
			local vo = {
				get_num = v[1],
				consume = v[2],
			}
			table.insert(item_data, vo)
		end

		bless_consume_cfg[index] = item_data
	end

	return bless_consume_cfg[index]
end

-- 判断祈福按钮次数是否足够
function BlessingData:IsNumHave(index)
	local all_num = self:GetAllNum()
	local remid_num = 0
	if index == 1 then
		num_than = self.bind_yuan_num
	elseif index == 2 then
		num_than = self.bing_zuan_num
	end

	return num_than < all_num
end

-- 祈福提示
function BlessingData:RemindBlessing()
	local gold = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
	local num_1, num_2 = self:GetBlessNum()
	local num_item_1 = self:GetBlessCfg(1)
	local num_item_2 = self:GetBlessCfg(2)
	local show_remind_times = pray_money_cfg and pray_money_cfg.show_remind_times or {0, 0}
	if num_1 < show_remind_times[1] or num_2 < show_remind_times[2] then
		num_1 = num_1 >= #num_item_1 and #num_item_1 or num_1+1
		num_2 = num_2 >= #num_item_2 and #num_item_2 or num_2+1
		if gold >= num_item_1[num_1].consume or gold >= num_item_2[num_2].consume then
			return 1
		end
	end
	return 0
end