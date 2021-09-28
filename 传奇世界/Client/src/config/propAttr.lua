
local attr = {
	Item_Field_QualityLevel, --品质  BYTE
	Item_Field_StrengthLevel, -- 强化等级	BYTE
	Item_Field_StrengthXp, -- 强化经验	int
	Item_Field_StarLevel, -- 星级	BYTE
	Item_Field_Bind, -- 是否绑定	bool
}

local ret = {}
for i, v in ipairs(attr) do
	ret[v] = i
end

return ret
