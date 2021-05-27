--------------------------------------------------------
-- 经脉数据
--------------------------------------------------------

MeridiansData = MeridiansData or BaseClass()

MeridiansData.MERIDIANS_LEVEL_CHANGE = "meridians_level_change"

function MeridiansData:__init()
	if MeridiansData.Instance then
		ErrorLog("[MeridiansData]:Attempt to create singleton twice!")
	end
	MeridiansData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.data = {
		level = 0,          -- 经脉基础等级(从服务端发送过来的等级)
		phase = 1,          -- 经脉阶数
		child_level = 0     -- 经脉等级
	}

	-- 绑定红点提示触发条件
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.Meridians)
	-- 背包数据监听
	BagData.Instance:AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagDataChange))
end

function MeridiansData:__delete()
	MeridiansData.Instance = nil
end

----------设置----------

-- 设置经脉等级
function MeridiansData:SetData(protocol)
	local level = protocol.level
	self.data.level = level
	self.data.phase = math.min((level - (level % 11)) / 11 + 1, 14) -- 经脉阶位	先减去当阶的等级再取阶位就能得出整数
	self.data.child_level = level % 11

	-- 当经脉事件是升级经脉时,触发经脉等级改变监听事件
	if protocol.index == 2 then
		self:DispatchEvent(MeridiansData.MERIDIANS_LEVEL_CHANGE)
		RemindManager.Instance:DoRemindDelayTime(RemindName.Meridians) -- 进阶无物品消耗,经脉等级变化时进行修正.
	end
end

----------获取----------

-- 获取经脉数据 .level基础等级 .phase阶数 .child_level等级
function MeridiansData:GetData()
    return self.data
end

-- 获取经脉基础等级
function MeridiansData:GetLevel()
    return self.data.level
end

-- 获取经脉阶数
function MeridiansData:GetPhase()
    return self.data.phase
end

-- 获取当前经脉等级
function MeridiansData:GetChildLevel()
    return self.data.child_level
end

----------end----------

----------红点提示----------

function MeridiansData.OnBagDataChange()
	RemindManager.Instance:DoRemindDelayTime(RemindName.Meridians)
end

-- 获取提醒显示索引 0不显示红点, 1显示红点
function MeridiansData.GetRemindIndex()
	local level = MeridiansData.Instance:GetLevel()
	if level >= #MeridiansCfg.upgrade then return 0 end
	
	local item = MeridiansCfg.upgrade[level + 1].consumes[1] -- 获取经脉丹配置
	local item_num = BagData.Instance:GetItemNumInBagById(item.id, nil)	--获取背包的经脉丹数量

	local index = item_num >= item.count and 1 or 0
	return index
end

----------end----------