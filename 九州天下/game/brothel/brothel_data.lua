BrothelData = BrothelData or BaseClass()

function BrothelData:__init()
	if BrothelData.Instance then
		ErrorLog("[BrothelData] attempt to create singleton twice!")
		return
	end
	BrothelData.Instance =self
end

function BrothelData:__delete()
	BrothelData.Instance = nil
end

function BrothelData:GetXYCfg()
	return ConfigManager.Instance:GetAutoConfig("cross_xycity_auto")
end

function BrothelData:GetQingLouCfg()
	if nil == self.qinglou_buff_cfg then
		local cfg = self:GetXYCfg()
		self.qinglou_buff_cfg = ListToMap(cfg.qinglou_buff, "buff_type")
	end
	return self.qinglou_buff_cfg
end

-- 根据buff类型获取价格
function BrothelData:GetConsume(type)
	local cfg = self:GetQingLouCfg()
	return cfg[type].need_server_gold 
end

-- 根据buff类型获取持续时间
function BrothelData:GetDuration(type)
	local cfg = self:GetQingLouCfg()
	return cfg[type].duration_min 
end

-- 根据buff类型获取属性
function BrothelData:GetEnhancement(type)
	local cfg = self:GetQingLouCfg()
	return cfg[type].female_worker_add_buff_per 
end

-- 根据buff类型获取属性
function BrothelData:GetValue(type)
	local cfg = self:GetQingLouCfg()
	return cfg[type].param1 
end

-- 艺伎数
function BrothelData:GetSingerNum()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local group = vo.server_group + 1

	local source_info = LianFuDailyData.Instance:GetSourceItemList()
	local singer_num = source_info[group].singer_num
	return singer_num or 0 
end

function BrothelData:GetSingerShow(pos_x, pos_y)
	if nil == self.dancer_pos_cfg then
		local cfg = self:GetXYCfg()
		self.dancer_pos_cfg = ListToMap(cfg.dancer_pos, "pos")
	end

	if pos_x == nil or pos_y == nil then
		return
	end

	return self.dancer_pos_cfg[pos_x .. "," .. pos_y]
end