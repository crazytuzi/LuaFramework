PengLaiFairylandData = PengLaiFairylandData or BaseClass()

function PengLaiFairylandData:__init()
	if PengLaiFairylandData.Instance then
		ErrorLog("[PengLaiFairylandData]:Attempt to create singleton twice!")
	end
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
	PengLaiFairylandData.Instance = self
	self:InitPengLaiFairland()
	self:InitLuckyFlop()

	-- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetFreeCrossBrandRemind, self), RemindName.FreeCrossBrand)
end

function PengLaiFairylandData:__delete()
	PengLaiFairylandData.Instance = nil
	self.penglai_data = {}
	self.lucky_flop_data = {}
end

-- 根据转生数获取场景索引
function PengLaiFairylandData:GetScenesIndex()
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	for k, v in pairs(PengLaiXianJieCfg.sceneInfo) do
		if circle >= v.needmincircle and (circle <= v.needmaxcircle or nil == v.needmaxcircle) then
			return k - 151
		end
	end
	return 1
end


-------------------------------------
-- 蓬莱仙界 begin
-------------------------------------
PengLaiFairylandData.PengLaiInfoChange = "PengLaiInfoChange"

function PengLaiFairylandData:InitPengLaiFairland()
	self.penglai_data = {
		remaining_can_kill_boss_times = 0, 	--剩余可击杀次数
		buy_kill_boss_time_consume = 0,		--购买击杀BOSS次数消耗元宝
	}
end

-- 设置蓬莱仙境信息
function PengLaiFairylandData:SetPengLaiInfo(protocol)
	self.penglai_data.remaining_can_kill_boss_times = protocol.remaining_can_kill_boss_times
	self.penglai_data.buy_kill_boss_time_consume = PengLaiXianJieCfg.nBuyTimeConsume or 0
	self:DispatchEvent(PengLaiFairylandData.PengLaiInfoChange)
end

-- 获取蓬莱仙界信息
function PengLaiFairylandData:GetPengLaiFairyLandInfo()
	return self.penglai_data
end

-- 获取蓬莱仙界掉落奖励
function PengLaiFairylandData:GetDropAwardDataList(index)
	local cfg = PengLaiXianJieCfg and PengLaiXianJieCfg.dropGoodsShow
	if nil == cfg then return end
	local award_list = {}
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	for k, v in pairs(cfg[index]) do
		if (v.prof == prof or nil == v.prof)  and (v.sex == sex or nil == v.sex) then
			award_list[#award_list + 1] = {item_id = v.item_id, num = v.num, is_bind = v.is_bind}
		end
	end
	return award_list or {}
end

-- 获取说明文字
function PengLaiFairylandData:GetTipContent()
	return PengLaiXianJieCfg.TipContent or ""
end

-------------------------------------
-- 蓬莱仙界 end
-------------------------------------


-------------------------------------
-- 幸运翻牌 begin
-------------------------------------
PengLaiFairylandData.LuckyFlopInfoChange = "lucky_flop_info_change"

function PengLaiFairylandData:InitLuckyFlop()
	self.lucky_flop_data = {
		free_times = 0,
		can_turn = false,
		turn_gold = 0,
		brand_list = {},
	}
	for i = 1, #PengLaiXianJieCfg.allCards do
		self.lucky_flop_data.brand_list[i] = {
			index = i,
			is_open = false,
			item_index = 1,
			item_data = CommonStruct.ItemDataWrapper(),
		}
	end
end

function PengLaiFairylandData:IsCanBrandConsumeNow()
	return self.lucky_flop_data.can_turn
end

function PengLaiFairylandData:GetTurnCurBrandConsume()
	return self.lucky_flop_data.turn_gold
end

function PengLaiFairylandData:BrandCanTurn()
	return self.lucky_flop_data.can_turn
end

function PengLaiFairylandData:GetBrandDataList()
	return self.lucky_flop_data.brand_list
end

function PengLaiFairylandData.GetBrandFreeTimes()
	return PengLaiFairylandData.Instance.lucky_flop_data.free_times
end

function PengLaiFairylandData.GetBrandItemData(brand_index, item_index)
	local items_cfg = PengLaiXianJieCfg.allCards[brand_index]
	if items_cfg and items_cfg[item_index] then
		return ItemData.FormatItemData(items_cfg[item_index].awards[1])
	end
end

function PengLaiFairylandData:SetLuckyFlopInfo(protocol)
	if protocol.fuben_index ~= 1 then return end
	local brand_index = protocol.brand_index

	self.lucky_flop_data.can_turn = bit:_and(protocol.flop_info, 1) == 1

	local turn_times = 1
	local free_times = 1	-- 第一张牌免费
	for k, v in pairs(protocol.brands_data) do
		if self.lucky_flop_data.brand_list[k] then
			self.lucky_flop_data.brand_list[k].item_index = v.item_index
			self.lucky_flop_data.brand_list[k].is_open = v.item_index > 0
			self.lucky_flop_data.brand_list[k].item_data = PengLaiFairylandData.GetBrandItemData(v.prize_pool_index, v.item_index) or CommonStruct.ItemDataWrapper()
			if v.item_index > 0 then
				turn_times = turn_times + 1
				free_times = 0
			end
		end
	end
	self.lucky_flop_data.turn_gold = PengLaiXianJieCfg.nConsume and PengLaiXianJieCfg.nConsume[turn_times] or 0
	self.lucky_flop_data.free_times = self.lucky_flop_data.can_turn and self.lucky_flop_data.turn_gold == 0 and free_times or 0
	local view_is_open = ViewManager.Instance:IsOpen(ViewDef.PengLaiFairyland)
	if 0 ~= self.lucky_flop_data.free_times and IS_ON_CROSSSERVER and not view_is_open then
		self.get_brand_remind_view = GetBrandRemindView.New()
		self.get_brand_remind_view:AutoOpen()
	end
	RemindManager.Instance:DoRemindDelayTime(RemindName.FreeCrossBrand)
	self:DispatchEvent(PengLaiFairylandData.LuckyFlopInfoChange, brand_index)
end

function PengLaiFairylandData:GetBrandData(index)
	return self.lucky_flop_data.brand_list[index]
end

function PengLaiFairylandData:GetResetBrandInfo()
	return {left_reset_times = 3, gold_consume = 200}
end

-- 提醒
function PengLaiFairylandData:GetFreeCrossBrandRemind(remind_name)
	if remind_name == RemindName.FreeCrossBrand then
		local num = IS_ON_CROSSSERVER and self.lucky_flop_data.free_times or 0
		MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.FREE_CROSSBRAND, num, function ()
			ViewManager.Instance:OpenViewByDef(ViewDef.PengLaiFairyland.LuckyFlopSub)
		end)
		local view_is_open = ViewManager.Instance:IsOpen(ViewDef.PengLaiFairyland)
		if view_is_open then
			PengLaiFairylandCtrl.Instance.view:SetRemind(num)
		end
		return num
	end
end

function PengLaiFairylandData:GetFlopAwardDataList(index)
	local cfg = PengLaiXianJieCfg and PengLaiXianJieCfg.flopGoodsShow
	if nil == cfg then return end
	local award_list = {}
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	for k, v in pairs(cfg[index]) do
		if (v.prof == prof or nil == v.prof)  and (v.sex == sex or nil == v.sex) then
			award_list[#award_list + 1] = {item_id = v.item_id, num = v.num, is_bind = v.is_bind}
		end
	end
	return award_list or {}
end

function PengLaiFairylandData:GetFlopConsume()
	return self.lucky_flop_data.turn_gold
end

-------------------------------------
-- 幸运翻牌 end
-------------------------------------