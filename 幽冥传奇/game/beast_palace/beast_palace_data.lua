--------------------------------------------------------
-- 圣兽宫殿数据 配置 beast_palace_cfg
--------------------------------------------------------

BeastPalaceData = BeastPalaceData or BaseClass()

BeastPalaceData.NUMBER_CHANGE = "number_change"

function BeastPalaceData:__init()
	if BeastPalaceData.Instance then
		ErrorLog("[BeastPalaceData]:Attempt to create singleton twice!")
	end
	BeastPalaceData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.data = {
		number = 0, -- 剩余击杀次数
	}

end

function BeastPalaceData:__delete()
	BeastPalaceData.Instance = nil
end

----------设置Data----------

-- 设置剩余击杀次数
function BeastPalaceData:SetNumber(protocol)
	self.data.number = (1 - protocol.free_num) + protocol.pqy_num
	self:DispatchEvent(BeastPalaceData.NUMBER_CHANGE)
end

-- 获取剩余击杀次数
function BeastPalaceData:GetNumber()
	return self.data.number
end

-- 获取Data
function BeastPalaceData:GetData()
	return self.data
end

--------------------

-- 获取圣兽宫殿需要显示的物品
function BeastPalaceData.GetItemData()
	--获取显示配置
	local show_cfg = therionPalaceCfg.item_list
	local prof = math.max(RoleData.Instance:GetRoleBaseProf(), 1)	-- 获取角色基础职业,默认是战士
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX) -- 获取性别

	return show_cfg[prof][sex + 1]
end
