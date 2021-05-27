MeiBaShouTaoData = MeiBaShouTaoData or BaseClass()
-- consum ThanosGloveEquipConfig.makeCfg.consume
-- consum ThanosGloveEquipConfig.makeCfg.quality
-- addcfg ThanosGloveEquipConfig.IncreaseCfg.lvCfg
-- itGlove = 25,	            -- 灭霸手套

MeiBaShouTaoData.INPUT_CHANGE = "input_change"
MeiBaShouTaoData.HAND_COMPOSE_SUCC = "hand_compose_succ"
MeiBaShouTaoData.HAND_ADD_CHANGE = "hand_add_change"
MeiBaShouTaoData.HAND_COMPOSE_CHANGE = "hand_compose_change"
function MeiBaShouTaoData:__init()
	if MeiBaShouTaoData.Instance then
		ErrorLog("[MeiBaShouTaoData] attempt to create singleton twice!")
		return
	end
	MeiBaShouTaoData.Instance = self
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
end

function MeiBaShouTaoData:__delete()
end

function MeiBaShouTaoData:GetRewardRemind()
	return 0
end

function MeiBaShouTaoData:GetIsConsumeItem(id)
	if nil == self.consume_items then
		self.consume_items = {}
		for k,v in ipairs(ThanosGloveEquipConfig.makeCfg.consume) do
			self.consume_items[v.id] = true
		end
	end
	return self.consume_items[id]
end


------------------------------
---------- 打造
function MeiBaShouTaoData.GetConsumeCfg()
	return ThanosGloveEquipConfig.makeCfg.consume
end

function MeiBaShouTaoData.GetPreViewCfg()
	return ThanosGloveEquipConfig.makeCfg.quality
end

-- 打开界面时调用，模拟数值改变
function MeiBaShouTaoData:ClearItemNumData()
	self.input_items = nil
end

function MeiBaShouTaoData:InitItemNumData()
	self.input_items = {}
	for i,v in ipairs(ThanosGloveEquipConfig.makeCfg.consume) do
		local num = BagData.Instance:GetItemNumInBagById(v.id) 
		local vo = {item_id = v.id, need_count = v.count, input_num = num > v.count and v.count or num}
		self.input_items[i] = vo
	end
end

-- 打开界面时调用，模拟数值改变
function MeiBaShouTaoData:InPutItemCompose(data)
	-- 将背包物品投入
	for i,v in ipairs(self.input_items) do
		if v.item_id == data.item_id then
			local num = BagData.Instance:GetItemNumInBagById(v.item_id) 
			v.input_num = num > v.need_count and v.need_count or num
			break
		end
	end
	self:DispatchEvent(MeiBaShouTaoData.INPUT_CHANGE)
end

function MeiBaShouTaoData:IsInputCanCompose()
	for k,v in pairs(self:GetInputItemData()) do
		if v.input_num < v.need_count then
			return false, v.item_id
		end
	end
	return true
end

function MeiBaShouTaoData:GetInputItemData()
	-- if nil ==  self.input_items then self:InitItemNumData() end
	self:InitItemNumData()
	return self.input_items
end

function MeiBaShouTaoData:GetRemindNum()
		for k,v in ipairs(ThanosGloveEquipConfig.makeCfg.consume) do
			self.consume_items[v.id] = true
		end
end

function MeiBaShouTaoData:GetInputItemNumByIdx(idx)
	if nil ==  self.input_items then self:InitItemNumData() end
	return self.input_items[idx].input_num
end

function MeiBaShouTaoData:CanLingqu()
	return not self:GetIsComposing() and self:GetComposeData().q_idx ~= 0
end

function MeiBaShouTaoData:GetIsComposing()
	return self:GetComposeData().end_time - COMMON_CONSTS.SERVER_TIME_OFFSET >= 0 and  self:GetComposeData().end_time > TimeCtrl.Instance:GetServerTime()
end

function MeiBaShouTaoData:GetComposeData()
	return self.ComposeInfo or {end_time = 0, q_idx = 0, i_idx = 0}
end

function MeiBaShouTaoData:SetComposeData(info)
	self.ComposeInfo = info
	self:DispatchEvent(MeiBaShouTaoData.HAND_COMPOSE_CHANGE)
end


-------------------------------
-- 增幅
function MeiBaShouTaoData:GetAddData()
	return self.AddInfo
end

function MeiBaShouTaoData:SetAddData(info)
	self.AddInfo = info
	self:DispatchEvent(MeiBaShouTaoData.HAND_ADD_CHANGE)
end

function MeiBaShouTaoData.GetUpCfg()
	return ThanosGloveEquipConfig.IncreaseCfg.lvCfg
end

function MeiBaShouTaoData.GetConsumeConf(item_id)
	return ThanosGloveEquipConfig.IncreaseCfg.energy[item_id]
end


function MeiBaShouTaoData:GetAddAttrCfgByLv(level)
	return ThanosGloveEquipConfig.IncreaseCfg.lvCfg
end