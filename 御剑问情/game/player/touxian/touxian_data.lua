TouxianData = TouxianData or BaseClass(BaseEvent)
 TouxianData.OPERA =
  {
   	PROMOTE_LEVEL = 0, -- 提升境界
   	GET_INFO = 1,
   	MAX = 2,
  }
function TouxianData:__init()
	if TouxianData.Instance then
		print_error("[TouxianData] 尝试创建第二个单例模式")
	end
	TouxianData.Instance = self
	self.touxian_level = 0
	self.wait_time = 0
	self.touxian_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("rolejingjie_auto").jingjie, "jingjie_level")
	RemindManager.Instance:Register(RemindName.Touxian, BindTool.Bind(self.GetTouxianRemind, self))
end

function TouxianData:__delete()
	RemindManager.Instance:UnRegister(RemindName.Touxian)
	TouxianData.Instance = nil
end

function TouxianData:GetTime()
	return self.wait_time or 0
end

function TouxianData:SetTime(time)
	self.wait_time = time
end

function TouxianData:SetTouxianInfo(info)
	self.touxian_level = info.jingjie_level
end

function TouxianData:GetTouxianLevel()
	return self.touxian_level
end

function TouxianData:GetTouxianCfg(level)
	return self.touxian_cfg[level]
end

function TouxianData:GetTouxianName(level)
	return self.touxian_cfg[level] and self.touxian_cfg[level].name or ""
end

function TouxianData:GetTouxianRemind()
	local cfg = self.touxian_cfg[self.touxian_level + 1]
	if cfg then
		local num = ItemData.Instance:GetItemNumInBagById(cfg.stuff_id)
		local role_cap = GameVoManager.Instance:GetMainRoleVo().capability
		if role_cap >= cfg.cap_limit and num >= cfg.stuff_num then
			return 1
		end
	end
	return 0
end

function TouxianData.GetTouxianColor(level)
	return TOUXIAN_COLOR[math.ceil(level / 10)] or TOUXIAN_COLOR[6]
end

function TouxianData.GetTouxianNum(level)
	if level > 0 then
		local num = level % 5
		return num == 0 and 5 or num
	end
	return 0
end

function TouxianData.GetTouxianIcon(level)
	if level > 0 then
		return math.ceil(level / 5) - 1
	end
	return 0
end