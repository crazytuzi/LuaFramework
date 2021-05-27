BattleFuwenData = BattleFuwenData or BaseClass()

BattleFuwenData.ZHANWEN_SLOT_NUM = 18											--战纹数量

BattleFuwenData.BATTLE_FUWEN_INFO_CHANGE = "battle_fuwen_change"				--上线初始化所有数据
BattleFuwenData.BATTLE_FUWEN_JINGHUA_CHANGE = "battle_fuwen_jinghua_change"				--上线初始化所有数据
BattleFuwenData.BATTLE_FUWEN_ONE_INFO_CHANGE = "battle_fuwen_one_info_change"	--对战纹数据进行操作
BattleFuwenData.BATTLE_FUWEN_DECOMPOSE_GET_NUM_CHANGE = "battle_fuwen_decompose_get_num_change"	--对战纹数据进行操作

function BattleFuwenData:__init()
	if BattleFuwenData.Instance then
		ErrorLog("[BattleFuwenData] attempt to create singleton twice!")
		return
	end
	BattleFuwenData.Instance = self
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.zw_info = BattleFuwenData.CreateZhanwenData()	--战纹数据
	self.select_slot = 1
	self.decompose_list = {} 		--待分解战纹列表
	self.show_quality = {} 			--需展示的待分解的战纹的质量

    RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRewardRemind, self), RemindName.BattleFuwen)    --战纹提醒

    EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, function (event)
    	event.CheckAllItemDataByFunc(function (vo)
    		if ItemData.GetIsZhanwen(vo.item_id) or vo.item_id == 3766 then
				RemindManager.Instance:DoRemindDelayTime(RemindName.BattleFuwen)
				self:DispatchEvent(BattleFuwenData.BATTLE_FUWEN_INFO_CHANGE, {slot = self.select_slot})
			end
    	end)	
	end)
end

function BattleFuwenData:__delete()
end

--根据服务端数据 初始化战纹数据
--数据中加入函数 即在原有函数上封装多一层 
function BattleFuwenData.CreateZhanwenData()
	local list = {}
	for i = 1, BattleFuwenData.ZHANWEN_SLOT_NUM do
		list[i] = {
				item_data = nil,							--获取物品数据 包括等级，物品图标，品质

				slot = i,									--槽位

				--获取战纹类型
				get_zw_type = function ()
					if nil == list[i].item_data then return end
					return BattleFuwenData.Instance:GetZhanwenTypeAndQuality(list[i].item_data.item_id)
				end,								

				--获取展示属性 当前属性和下一级属性
				get_attr = function ()
					if nil == list[i].item_data then return end
					return BattleFuwenData.GetShowAttr(list[i].item_data), BattleFuwenData.GetNextShowAttr(list[i].item_data)
				end,							

				--槽位是否解锁 由策划配置
				check_is_lock = function ()
					return BattleFuwenData.CheckIsLock(i)
				end,

				--是否有可升级
				check_can_upgrade = function ()
					-- 未开放 或 未装备战纹 或 战纹无下级配置(已到顶级)
					if BattleFuwenData.CheckIsLock(i) or list[i].item_data == nil or (list[i].item_data ~= nil and BattleFuwenData.GetUpNeed(list[i].item_data) <= 0) then	
					  	return false
					end
					return BattleFuwenData.Instance:GetZhanwenJinghuaNum() >= BattleFuwenData.GetUpNeed(list[i].item_data)
				end,

				--是否有更好的
				check_have_better = function ()
					if BattleFuwenData.CheckIsLock(i) then return false end
					local best_zw_data = BattleFuwenData.Instance:GetBagBestZhanwen(i)
					return	BattleFuwenData.Instance:CheckIsBetter(list[i].item_data, best_zw_data)
				end,
			}
		--end
	end
	return list
end

--检测是否可穿戴 战纹类型是否已拥有
function BattleFuwenData:CheckIsConflictId(id, slot)
	local zw_type = self:GetZhanwenTypeAndQuality(id)			--待检测物品
	--该槽位镶嵌有战纹时 可更换相同类型战纹
	if self.zw_info[slot or self.select_slot] then 
		if self.zw_info[slot or self.select_slot].get_zw_type() == zw_type then
			return false
		end
	end

	--遍历槽位 是否有相同种类战纹
	for i,v in ipairs(self.zw_info) do
		if v.get_zw_type() and v.get_zw_type() == zw_type then
			return true
		end
	end
	return false
end

-- 检测是否弹出快速穿戴窗口
function BattleFuwenData:CheckIsWearable(equip)
	if type(equip) ~= "table" then return false end

	local bool = false
	local select_slot = nil

	BattleFuwenData.GetAttrSetScore(equip) -- 缓存评分,让通用评分获取接口能取得评分

	--遍历槽位 是否有相同种类战纹
	local zw_type = self:GetZhanwenTypeAndQuality(equip.item_id) --待检测物品
	for slot, v in ipairs(self.zw_info) do
		if not BattleFuwenData.CheckIsLock(slot) then
			local cur_zw_type = v.get_zw_type()
			if cur_zw_type then
				if cur_zw_type == zw_type then
					if BattleFuwenData:CheckIsBetter(v.item_data, equip) then
						bool = true
						select_slot = slot
					else
						bool = false
						select_slot = nil
					end
					break
				end
			else
				-- 有空槽位
				bool = true 
				select_slot = slot
			end
		end
	end

	return bool, select_slot
end

--获取背包中最佳战纹数据 跳过冲突战纹
function BattleFuwenData:GetBagBestZhanwen(slot)
	local bag_battle_line_list = BagData.Instance:GetBagBattleLineList()
	if nil == next(bag_battle_line_list) then return end
	local sorce = 0
	local series = 0
	for i, equip in pairs(bag_battle_line_list) do
		if not BattleFuwenData.Instance:CheckIsConflictId(equip.item_id, slot) then
			local cur_sorce = BattleFuwenData.GetAttrSetScore(equip)
			series = cur_sorce > sorce and i or series
			sorce = cur_sorce > sorce and cur_sorce or sorce
		end
	end

	return bag_battle_line_list[series], series, sorce 
end

--判断 need_check_data 是否比 data 更好
function BattleFuwenData:CheckIsBetter(data, need_check_data)
	if nil == data and need_check_data then return true end
	if nil == need_check_data then return false end
	return BattleFuwenData.GetAttrSetScore(need_check_data) > BattleFuwenData.GetAttrSetScore(data)
end

-- 获取战纹评分并缓存评分
function BattleFuwenData.GetAttrSetScore(equip, if_flush)
	local score = 0
	if type(equip) == "table" then
		if nil == equip.score or is_flush then
			score = CommonDataManager.GetAttrSetScore(BattleFuwenData.GetShowAttr(equip))
			equip.score = score -- 缓存评分
		else
			score = equip.score
		end
	end

	return score
end

--------------------------------------------------------
----数据操作 视图使用
--------------------------------------------------------
----背包战纹列表
--用于装备-替换 面板；按是否可装备排序
function BattleFuwenData:GetBagBattleLineList()
	local list = {}
	for k,v in pairs(BagData.Instance:GetBagBattleLineList()) do
		table.insert(list, v)
	end
	table.sort(list, function (a, b)
		local zw_type, a_quality = BattleFuwenData.Instance:GetZhanwenTypeAndQuality(a.item_id)
		local zw_type, b_quality = BattleFuwenData.Instance:GetZhanwenTypeAndQuality(b.item_id)
		if self:CheckIsConflictId(a.item_id) == self:CheckIsConflictId(b.item_id) then
			return a_quality > b_quality
		else
			return not self:CheckIsConflictId(a.item_id) and self:CheckIsConflictId(b.item_id)
		end
	end)
	return list
end

--用于分解面板 按品质排序
function BattleFuwenData:GetBagShowBattleLineList()
	local list = {}
	for k,v in pairs(BagData.Instance:GetBagBattleLineList()) do
		table.insert(list, v)
	end
	table.sort( list, function (a, b)
		local zw_type, a_quality = BattleFuwenData.Instance:GetZhanwenTypeAndQuality(a.item_id)
		local zw_type, b_quality = BattleFuwenData.Instance:GetZhanwenTypeAndQuality(b.item_id)
		return 	a_quality > b_quality
	end)

	return list
end

--判断背包中某物品 是否为更好的战纹
function BattleFuwenData:CheckIsBetterSlot(data)
	local best_zw_data = self:GetBagBestZhanwen(self.select_slot)
	if nil == best_zw_data then return false end
	return	best_zw_data.series == data.series and BattleFuwenData:CheckIsBetter(self.zw_info[self.select_slot].item_data, data)
end

----槽位数据
--储存槽位显示用数据 及相关方法
function BattleFuwenData:GetZhanwenInfo()
	return self.zw_info
end

function BattleFuwenData:GetCurrZhanwenInfo()
	return self.zw_info[self.select_slot]
end

--当前选中槽位
function BattleFuwenData:SetSelectSlot(slot)
	self.select_slot = slot
end

function BattleFuwenData:GetSelectSlot(slot)
	return self.select_slot
end

----分解相关
--累加
local calc_decompose_get = function ()
	local get_num = 0
	for i,v in pairs(BattleFuwenData.Instance.decompose_list) do
		get_num = get_num + v
	end
	return get_num
end

function BattleFuwenData:AddDecomseData(data)
	self.decompose_list[data.series] = BattleFuwenData.GetDecomposeObtian(data)
	self:DispatchEvent(BattleFuwenData.BATTLE_FUWEN_DECOMPOSE_GET_NUM_CHANGE, {num = calc_decompose_get()})
end

function BattleFuwenData:DeleteDecomseData(data)
	self.decompose_list[data.series] = nil
	self:DispatchEvent(BattleFuwenData.BATTLE_FUWEN_DECOMPOSE_GET_NUM_CHANGE, {num = calc_decompose_get()})
end

function BattleFuwenData:CheckIsInDecomposeList(uid)
	return self.decompose_list[uid]
end

function BattleFuwenData:ClearDecomseData()
	self.decompose_list = {}
end

--将某一品质 所有战纹勾选
function BattleFuwenData:AddSelectBagListQuality(quality)
	self.show_quality[quality] = true
	for i,v in pairs(BagData.Instance:GetBagBattleLineList()) do
		local zw_type, zw_quality = BattleFuwenData.Instance:GetZhanwenTypeAndQuality(v.item_id)
		if zw_quality == quality then
			self:AddDecomseData(v)
		end
	end
end

--将某一品质 所有战纹取消勾选
function BattleFuwenData:DeleteSelectBagListQuality(quality)
	self.show_quality[quality] = nil
	for i,v in pairs(BagData.Instance:GetBagBattleLineList()) do
		local zw_type, zw_quality = BattleFuwenData.Instance:GetZhanwenTypeAndQuality(v.item_id)
		if zw_quality == quality then
			self:DeleteDecomseData(v)
		end
	end
end

function BattleFuwenData:ClearShowQuality()
	self.show_quality = {}
end

----战纹精华数量
function BattleFuwenData:GetZhanwenJinghuaNum()
	return self.jinghua_num or 0
end

----当前槽位战纹升级所需精华
function BattleFuwenData:GetCurrUpNeed()
	return BattleFuwenData.GetUpNeed(self.zw_info[self.select_slot].item_data)
end

------------------------------------
----服务端交互
------------------------------------
function BattleFuwenData:SendDecompose()
	if nil == self.decompose_list then return end
	BattleFuwenCtrl.SendDecomposeBattleFuwenReq(self.decompose_list)
end

function BattleFuwenData:SendUpLevel()
	BattleFuwenCtrl.SendUpLevelBattleFuwenReq(self.select_slot)
end

function BattleFuwenData:SendCloth(data, slot)
	slot = slot or self.select_slot
	if nil == self.zw_info[slot].item_data then --当前槽位无镶嵌 则使用装备协议 否则使用替换协议
		BattleFuwenCtrl.SendBattleFuwenClothReq(data.series, slot)		--装备
	else
		BattleFuwenCtrl.SendBattleFuwenReplaceReq(data.series, slot)	--替换
	end
end

--战纹精华
function BattleFuwenData:SetZhanwenJinghuaNum(num)
	if self.jinghua_num == num then return end
	self.jinghua_num = num

	self:DispatchEvent(BattleFuwenData.BATTLE_FUWEN_ONE_INFO_CHANGE, {num = self.jinghua_num, slot = self.select_slot})		--派发事件监听
	RemindManager.Instance:DoRemindDelayTime(RemindName.BattleFuwen)	--刷新提醒组 可升级
end

--初始化槽位数据
function BattleFuwenData:SetZhanwenData(pro_info)
	--缓存服务端数据
	for slot, item_data in pairs(pro_info) do
		self.zw_info[slot].item_data = item_data
	end
	self:DispatchEvent(BattleFuwenData.BATTLE_FUWEN_INFO_CHANGE, {slot = self.select_slot})		--派发事件监听
	RemindManager.Instance:DoRemindDelayTime(RemindName.BattleFuwen)	--刷新提醒组
end

--更新数据
function BattleFuwenData:UpdateZhanwenData(slot, data, tag)
	if nil == tag then return end

	local cur_slot = self.zw_info and self.zw_info[slot] or {}
	if tag == "cloth"  then
		cur_slot.item_data = data
	elseif tag == "uplevel"  then
		local item_data = cur_slot.item_data or {}
		item_data.durability = data 	--在战纹中 其耐久为战纹等级
		BattleFuwenData.GetAttrSetScore(item_data, true) -- 更新评分缓存
	end
	self:DispatchEvent(BattleFuwenData.BATTLE_FUWEN_ONE_INFO_CHANGE, {num = self:GetZhanwenJinghuaNum(),tag = tag, slot = slot})
	RemindManager.Instance:DoRemindDelayTime(RemindName.BattleFuwen)
end

-----------------------------------------
----解析配置
-----------------------------------------
--不同职业 战纹属性配置
--BattlePatternLevelCfg 分解 升级相关配置
BattleFuwenData.ZhanwenAttrCfg = {
	[1] = require("scripts/config/server/config/battlePattern/JobLevelCfg/warrior")[1],
	[2] = require("scripts/config/server/config/battlePattern/JobLevelCfg/Master")[1],
	[3] = require("scripts/config/server/config/battlePattern/JobLevelCfg/Taoist")[1],
}

--获取战纹种类与品质
function BattleFuwenData:GetZhanwenTypeAndQuality(id)
	--根据物品配置查找
	if nil == id then return end
	local cfg = ItemData.Instance:GetItemConfig(id)
	--服务端战纹类型 战纹品质从零开始；客户端需与配置对应 故加一
	return cfg.stype + 1, cfg.quality + 1
end

--根据配置获取 当前id及等级的战纹 的属性
function BattleFuwenData.GetZhanwenAttr(id, level)
	if nil == id then return end
	local pro = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local cfg = BattleFuwenData.ZhanwenAttrCfg[pro]

	local zw_type, zw_quality = BattleFuwenData.Instance:GetZhanwenTypeAndQuality(id)
	return cfg[zw_type][zw_quality].attrs[level] or cfg[zw_type][zw_quality].attrs[1]
end

function BattleFuwenData.GetShowAttr(item_data)
	if nil == item_data then return end
	item_data.durability = item_data.durability or 1
	return BattleFuwenData.GetZhanwenAttr(item_data.item_id, item_data.durability)
end

function BattleFuwenData.GetNextShowAttr(item_data)
	if nil == item_data then return end
	item_data.durability = item_data.durability or 1
	return BattleFuwenData.GetZhanwenAttr(item_data.item_id, item_data.durability + 1)
end

function BattleFuwenData.GetDecomposeObtian(item_data)
	if nil == item_data then return 0 end
	local zw_type, zw_quality = BattleFuwenData.Instance:GetZhanwenTypeAndQuality(item_data.item_id)
	item_data.durability = item_data.durability or 1
	if nil == BattlePatternLevelCfg[zw_type] or nil == BattlePatternLevelCfg[zw_type][zw_quality][item_data.durability] then
		return 0
	end 
	return BattlePatternLevelCfg[zw_type][zw_quality][item_data.durability].decompose
end

--item_data.durability + 1; 配置为升级到当前等级所需精华数量，故取下一级配置
function BattleFuwenData.GetUpNeed(item_data)
	if nil == item_data then return 0 end
	local zw_type, zw_quality = BattleFuwenData.Instance:GetZhanwenTypeAndQuality(item_data.item_id)
	item_data.durability = item_data.durability or 1
	if nil == BattlePatternLevelCfg[zw_type] or nil == BattlePatternLevelCfg[zw_type][zw_quality][item_data.durability + 1] then
		return 0
	end 
	return BattlePatternLevelCfg[zw_type][zw_quality][item_data.durability + 1].Streng
end

--是否未开放
function BattleFuwenData.CheckIsLock(slot)
	--闯关数 < 槽位开放所需闯关数
	return BabelData.Instance:GetTongguangLevel() < BattlePatternCfg.openSlot[slot]
end

-------------------------------------
----提醒相关
-------------------------------------
--可操作数
function BattleFuwenData:GetRewardRemind()
	return self:GetExchageRemindNum() + self:GetCanClothRemindNum() + self:GetCanUpgradeRemindNum()
end

--可兑换数
function BattleFuwenData:GetExchageRemindNum()
	for i,v in ipairs(ItemSynthesisConfig[ITEM_SYNTHESIS_TYPES.BATTLE_LINE].list) do
		for i2,v2 in pairs(v.itemList) do
			if BagData.Instance:GetItemNumInBagById(v2.consume[1].id) > v2.consume[1].count then
				return 1
			end
		end
	end
	return 0
end

--可装备 替换
function BattleFuwenData:GetCanClothRemindNum()
	for i,v in ipairs(self.zw_info) do
		if v.check_have_better() then
			return 1
		end
	end
	return 0
end

--可升级
function BattleFuwenData:GetCanUpgradeRemindNum()
	for i,v in ipairs(self.zw_info) do
		if v.check_can_upgrade() then
			return 1
		end
	end
	return 0
end

--可分解
function BattleFuwenData:GetCanDecomposeRemindNum()
	return next(BagData.Instance:GetBagBattleLineList()) ~= 0
end

--当前槽位可装备 替换
function BattleFuwenData:GetCurrHaveBetter()
	if self.zw_info[self.select_slot].check_have_better() then return 1 end
	return 0
end

--当前槽位可装备 替换
function BattleFuwenData:GetCurrCanUpgrade()
	if self.zw_info[self.select_slot].check_can_upgrade() then return 1 end
	return 0
end

--获得全览配置
function BattleFuwenData:GetZhanWenViewList()
	local text = ""
	text = "scripts/config/client/battle_fuwen_all_cfg"

	return ConfigManager.Instance:GetConfig(text)
end
