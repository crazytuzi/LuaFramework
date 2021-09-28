ReincarnationData = ReincarnationData or BaseClass()

function ReincarnationData:__init()
	if ReincarnationData.Instance ~= nil then
		print_error("[ReincarnationData] Attemp to create a singleton twice !")
	end
	ReincarnationData.Instance = self
	-- 红点显示
	self.is_one_show_redpt = true

	-- 配置表数据
	self.zhuansheng = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").zhuansheng
	self.job = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
	RemindManager.Instance:Register(RemindName.Reincarnation, BindTool.Bind(self.GetReincarnationRemind, self))
end

function ReincarnationData:__delete()
	RemindManager.Instance:UnRegister(RemindName.Reincarnation)
	
	ReincarnationData.Instance = nil
end

-- 获取属性通过等级 范围为1~9
function ReincarnationData:GetZsDataByLevel(level)
	local data = {}
	for k,v in pairs(self.zhuansheng) do
		if level == v.zhuansheng_level then
			table.insert(data,v)
		end
	end

	return data[1]
end

-- 根据主角实际等级获取转生等级
function ReincarnationData:GetZsLevel()
	local level = 0
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	level = math.ceil(role_level/100) - 1
	if level < 0 then
		level = 0
	end

	return level
end

-- 判断当前是否可以转生
function ReincarnationData:GetIsCanZs()
	local zs_level = self:GetZsLevel() + 1
	if zs_level > 9 then
		return false
	end

	local is_zs = false
	local role_level = GameVoManager.Instance:GetMainRoleVo().level

	local temp = role_level/100
	local value = math.floor(temp)
	if temp - value == 0 then
		is_zs = true
	else
		is_zs = false
	end

	return is_zs
end

function ReincarnationData:GetReincarnationRemind()
	return self:GetIsShowRedPoint() and 1 or 0
end

-- 判断是否显示转生红点
function ReincarnationData:GetIsShowRedPoint()
	local zs_level = self:GetZsLevel() + 1
	if zs_level > 9 then
		return false
	end

	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	if role_level == 0 or role_level % 100 ~= 0 then
		return false
	end
	local data = self:GetZsDataByLevel(zs_level)
	local have_num = ItemData.Instance:GetItemNumInBagById(data.consume_item.item_id)
	local item_num = data.consume_item.num
	return have_num >= item_num
end