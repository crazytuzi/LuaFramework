CommonDataManager = CommonDataManager or {}

-- 匹配阶数（文字）
CommonDataManager.DAXIE =  { [0] = "零", "十", "一", "二", "三", "四", "五", "六", "七", "八", "九" }
CommonDataManager.FANTI =  { [0] = "零", "拾", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖" }

CommonDataManager.attrview_t = {{"hp", "max_hp"}, {"gongji", "gong_ji"}, {"fangyu", "fang_yu"}, {"mingzhong", "ming_zhong"}, {"shanbi", "shan_bi"}, {"baoji", "bao_ji"}, {"jianren", "jian_ren"}}

CommonDataManager.suit_att_t = {{"maxhp"}, {"gongji"}, {"fangyu"}, {"mingzhong"}, {"shanbi"}, {"baoji"}, {"jianren"}, {"maxhp_attr"}, {"gongji_attr"}, {"fangyu_attr"}, {"mingzhong_attr"}, {"shanbi_attr"}, {"jianren_attr"}, {"baoji_attr"}}

function CommonDataManager.GetDaXie(num, type)
	if nil == num or num < 0 or num >= 100 then
		return ""
	end
	local result = ""
	local index1 = num
	local index2 = -1
	if 10 == num then
		index1 = 0
	elseif num > 10 then
		index1 = math.floor(num / 10)
		index1 = (1 == index1) and 0 or index1
		index2 = num % 10
	elseif num == 0 then
		index1 = -1
	end

	local table = {}
	if nil == type then
		table = CommonDataManager.DAXIE
	else
		table = CommonDataManager.FANTI
	end

	result = table[index1 + 1]
	if math.floor(num / 10) > 1 and index2 ~= 0 then
		result = result .. table[1]
	end
	if index2 > -1 then
		result = result .. table[index2 + 1]
	end

	return result
end

--转换财富
function CommonDataManager.ConverMoney(value)
	value = tonumber(value)
	if value >= 100000 and value < 100000000 then
		local result = math.floor(value / 10000) .. Language.Common.Wan
		return result
	end

	if value >= 100000000 then
		local result = math.floor(value / 100000000) .. Language.Common.Yi
		return result
	end
	return value
end

--转换
function CommonDataManager.ConverNum(value)
	value = tonumber(value)
	if value >= 10000 and value < 100000000 then
		local result = math.floor(value / 1000)/10 .. Language.Common.Wan
		return result
	end

	if value >= 100000000 then
		local result = math.floor(value / 10000000)/10 .. Language.Common.Yi
		return result
	end
	return value
end

function CommonDataManager.ConverNum2(value)
	value = tonumber(value)
	if value >= 10000 and value < 100000000 then
		local result = math.floor(value / 1000)/10
		return result,Language.Common.Wan
	end

	if value >= 100000000 then
		local result = math.floor(value / 10000000)/10
		return result,Language.Common.Yi
	end
	return value
end

--最少10万
function CommonDataManager.ConverTenNum(value)
	value = tonumber(value)
	if value >= 100000 and value < 100000000 then
		local result = math.floor(value / 10000) .. Language.Common.Wan
		return result
	end

	if value >= 100000000 then
		local result = math.floor(value / 10000000)/10 .. Language.Common.Yi
		return result
	end
	return value
end

--战力值
-- is_next 是否下一未获得属性（默认 false 可不传）
-- own_attr 下一属性中已拥有部分属性的
-- is_others 是否其它人（默认 false 可不传）
function CommonDataManager.GetCapability(value, is_next, own_attr, is_others)
	value = CommonDataManager.GetAttributteByClass(value)
	local capability = 0
	if is_others then
		capability = CommonDataManager.GetCapabilityCalculation(value)
	else
		local role_less_cap, role_more_cap = 0, 0
		if is_next then
			if own_attr then
				own_attr = CommonDataManager.GetAttributteByClass(own_attr)
				local less_attr = CommonDataManager.LerpAttributeAttr(own_attr, CommonDataManager.GetMainRoleAttr())
				role_less_cap = CommonDataManager.GetCapabilityCalculation(less_attr)
				role_more_cap = CommonDataManager.GetCapabilityCalculation(CommonDataManager.AddAttributeAttr(value, less_attr))
			else
				role_less_cap = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetMainRoleAttr())
				role_more_cap = CommonDataManager.GetCapabilityCalculation(CommonDataManager.AddAttributeAttr(value, CommonDataManager.GetMainRoleAttr()))
			end
		else
			role_less_cap = CommonDataManager.GetCapabilityCalculation(CommonDataManager.LerpAttributeAttr(value, CommonDataManager.GetMainRoleAttr()))
			role_more_cap = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetMainRoleAttr())
		end
		capability = role_more_cap - role_less_cap
	end
	return capability
end

function CommonDataManager.GetMainRoleAttr()
	local attribute = CommonStruct.Attribute()
	local data = PlayerData.Instance and PlayerData.Instance:GetRoleVo() or {}
	attribute.gong_ji = data.gong_ji or 0
	attribute.max_hp = data.max_hp or 0
	attribute.fang_yu = data.fang_yu or 0
	attribute.ming_zhong = data.ming_zhong or 0
	attribute.shan_bi = data.shan_bi or 0
	attribute.bao_ji = data.bao_ji or 0
	attribute.jian_ren = data.jian_ren or 0
	attribute.per_jingzhun = data.per_jingzhun or 0
	attribute.per_baoji = data.per_baoji or 0
	attribute.per_mianshang = data.per_mianshang or 0
	attribute.per_pofang = data.per_pofang or 0
	attribute.per_gongji = data.per_gongji or 0
	attribute.per_maxhp = data.per_maxhp or 0
	attribute.goddess_gongji = data.fujia_shanghai or 0
	attribute.constant_zengshang = data.constant_zengshang or 0
	attribute.constant_mianshang = data.constant_mianshang or 0
	attribute.huixinyiji = data.huixinyiji or 0
	attribute.huixinyiji_hurt = data.huixinyiji_hurt or 0
	return attribute
end


-- 战力值计算（外部调用CommonDataManager.GetCapability）
-- value必须为格式化后的table
function CommonDataManager.GetCapabilityCalculation(value)
	if nil == value then
		return 0
	end

	-- 战力最后要乘1.875
	-- 因为ug05是乘0.625，Ug13需要在这个基础上再乘3
	return math.floor(
		  (math.floor(value.max_hp or value.maxhp or 0) * 0.2
		  		* (1 + math.floor(value.per_mianshang or 0) / 10000 * 1)
		  		+ math.floor(value.gong_ji or value.gongji or 0) * 4.1
		  		* (1 + math.floor(value.huixinyiji or 0) / 10000 * 0.6)
		  		* (1 + math.floor(value.per_baoji or 0) / 10000 * 0.3)
		  		* (1 + math.floor(value.per_jingzhun or 0) / 10000 * 0.8)
		  		* (1 + math.floor(value.per_pofang or 0) / 10000 * 1.3)
		  		+ math.floor(value.fang_yu or value.fangyu or 0) * 3.4
		  		+ math.floor(value.ming_zhong or value.mingzhong or 0) * 1.5
		  		+ math.floor(value.shan_bi or value.shanbi or 0) * 1.8
		  		+ math.floor(value.bao_ji or value.baoji or 0) * 2.4
		  		+ math.floor(value.jian_ren or value.jianren or 0) * 1.9
		  		+ math.floor(value.goddess_gongji or value.xiannv_gongji or 0) * 1.6
		  		+ math.floor(value.constant_zengshang or 0) * 3
		  		+ math.floor(value.constant_mianshang or 0) * 3) * 1.875
		)
end


-- 两个属性相加
function CommonDataManager.AddAttributeAttr(attribute1, attribute2)
	local m_attribute = CommonStruct.Attribute()
	m_attribute.gong_ji = attribute1.gong_ji + attribute2.gong_ji
	m_attribute.max_hp = attribute1.max_hp + attribute2.max_hp
	m_attribute.fang_yu = attribute1.fang_yu + attribute2.fang_yu
	m_attribute.ming_zhong = attribute1.ming_zhong + attribute2.ming_zhong
	m_attribute.shan_bi = attribute1.shan_bi + attribute2.shan_bi
	m_attribute.bao_ji = attribute1.bao_ji + attribute2.bao_ji
	m_attribute.jian_ren = attribute1.jian_ren + attribute2.jian_ren
	m_attribute.per_jingzhun = attribute2.per_jingzhun + attribute1.per_jingzhun
	m_attribute.per_baoji = attribute2.per_baoji + attribute1.per_baoji
	m_attribute.per_mianshang = attribute2.per_mianshang + attribute1.per_mianshang
	m_attribute.per_pofang = attribute2.per_pofang + attribute1.per_pofang
	m_attribute.goddess_gongji = (attribute1.goddess_gongji or attribute1.fujia_shanghai or 0) + (attribute2.goddess_gongji or attribute2.fujia_shanghai or 0)
	m_attribute.move_speed = attribute1.move_speed + attribute2.move_speed
	m_attribute.constant_zengshang = (attribute1.constant_zengshang or 0) + (attribute2.constant_zengshang or 0)
	m_attribute.constant_mianshang = (attribute1.constant_mianshang or 0) + (attribute2.constant_mianshang or 0)
	m_attribute.huixinyiji = (attribute1.huixinyiji or 0) + (attribute2.huixinyiji or 0)
	m_attribute.huixinyiji_hurt = (attribute1.huixinyiji_hurt or 0) + (attribute2.huixinyiji_hurt or 0)

	return m_attribute
end

-- is_no_underline 是否不要下换线
function CommonDataManager.AddAttributeBaseAttr(attribute1, vo, is_no_underline)
	local m_attribute = {}
	if not is_no_underline then
		m_attribute.gong_ji = attribute1.gong_ji + vo.base_gongji
		m_attribute.max_hp = attribute1.max_hp + vo.base_max_hp
		m_attribute.fang_yu = attribute1.fang_yu + vo.base_fangyu
		m_attribute.ming_zhong = attribute1.ming_zhong + vo.base_mingzhong
		m_attribute.shan_bi = attribute1.shan_bi + vo.base_shanbi
		m_attribute.bao_ji = attribute1.bao_ji + vo.base_baoji
		m_attribute.jian_ren = attribute1.jian_ren + vo.base_jianren
	else
		m_attribute.gongji = attribute1.gongji + vo.base_gongji
		m_attribute.maxhp = attribute1.maxhp + vo.base_max_hp
		m_attribute.fangyu = attribute1.fangyu + vo.base_fangyu
		m_attribute.mingzhong = attribute1.mingzhong + vo.base_mingzhong
		m_attribute.shanbi = attribute1.shanbi + vo.base_shanbi
		m_attribute.baoji = attribute1.baoji + vo.base_baoji
		m_attribute.jianren = attribute1.jianren + vo.base_jianren
	end
	m_attribute.per_jingzhun = vo.base_per_jingzhun + attribute1.per_jingzhun
	m_attribute.per_baoji = vo.base_per_baoji + attribute1.per_baoji
	m_attribute.per_mianshang = vo.base_per_mianshang + attribute1.per_mianshang
	m_attribute.per_pofang = vo.base_per_pofang + attribute1.per_pofang
	m_attribute.goddess_gongji = (attribute1.goddess_gongji or attribute1.fujia_shanghai or 0) + (vo.base_goddess_gongji or vo.base_fujia_shanghai or 0)
	if attribute1.move_speed and vo.base_move_speed then
		m_attribute.move_speed = attribute1.move_speed + vo.base_move_speed
	end
	return m_attribute
end

-- 两个属性差值(attribute2 - attribute1)
function CommonDataManager.LerpAttributeAttr(attribute1, attribute2)
	local m_attribute = CommonStruct.Attribute()
	m_attribute.gong_ji = attribute2.gong_ji - attribute1.gong_ji
	m_attribute.max_hp = attribute2.max_hp - attribute1.max_hp
	m_attribute.fang_yu = attribute2.fang_yu - attribute1.fang_yu
	m_attribute.ming_zhong = attribute2.ming_zhong - attribute1.ming_zhong
	m_attribute.shan_bi = attribute2.shan_bi - attribute1.shan_bi
	m_attribute.bao_ji = attribute2.bao_ji - attribute1.bao_ji
	m_attribute.jian_ren = attribute2.jian_ren - attribute1.jian_ren
	m_attribute.goddess_gongji = attribute2.goddess_gongji - attribute1.goddess_gongji
	m_attribute.per_jingzhun = attribute2.per_jingzhun - attribute1.per_jingzhun
	m_attribute.per_baoji = attribute2.per_baoji - attribute1.per_baoji
	m_attribute.per_mianshang = attribute2.per_mianshang - attribute1.per_mianshang
	m_attribute.per_pofang = attribute2.per_pofang - attribute1.per_pofang
	m_attribute.constant_mianshang = attribute2.constant_mianshang - attribute1.constant_mianshang
	m_attribute.constant_zengshang = attribute2.constant_zengshang - attribute1.constant_zengshang
	m_attribute.huixinyiji = attribute2.huixinyiji - attribute1.huixinyiji
	m_attribute.huixinyiji_hurt = attribute2.huixinyiji_hurt - attribute1.huixinyiji_hurt
	if attribute2.move_speed and attribute1.move_speed then
		m_attribute.move_speed = attribute2.move_speed - attribute1.move_speed
	end
	return m_attribute
end

-- 两个属性差值(attribute2 - attribute1)
function CommonDataManager.LerpAttributeAttrNoUnderLine(attribute1, attribute2)
	local m_attribute = CommonStruct.Attribute()
	m_attribute.gongji = attribute2.gongji - attribute1.gongji
	m_attribute.maxhp = attribute2.maxhp - attribute1.maxhp
	m_attribute.fangyu = attribute2.fangyu - attribute1.fangyu
	m_attribute.mingzhong = attribute2.mingzhong - attribute1.mingzhong
	m_attribute.shanbi = attribute2.shanbi - attribute1.shanbi
	m_attribute.baoji = attribute2.baoji - attribute1.baoji
	m_attribute.jianren = attribute2.jianren - attribute1.jianren
	m_attribute.goddess_gongji = attribute2.goddess_gongji - attribute1.goddess_gongji
	m_attribute.per_jingzhun = attribute2.per_jingzhun - attribute1.per_jingzhun
	m_attribute.per_baoji = attribute2.per_baoji - attribute1.per_baoji
	m_attribute.per_mianshang = attribute2.per_mianshang - attribute1.per_mianshang
	m_attribute.per_pofang = attribute2.per_pofang - attribute1.per_pofang
	m_attribute.constant_mianshang = attribute2.constant_mianshang - attribute1.constant_mianshang
	m_attribute.constant_zengshang = attribute2.constant_zengshang - attribute1.constant_zengshang
	m_attribute.huixinyiji = attribute2.huixinyiji - attribute1.huixinyiji
	m_attribute.huixinyiji_hurt = attribute2.huixinyiji_hurt - attribute1.huixinyiji_hurt
	if attribute2.move_speed and attribute1.move_speed then
		m_attribute.move_speed = attribute2.move_speed - attribute1.move_speed
	end
	return m_attribute
end

-- 属性乘以一个常数
function CommonDataManager.MulAttribute(attr, num)
	local attribute = CommonStruct.Attribute()

	if nil ~= attr and num then
		attribute.max_hp = attr.max_hp * num
		attribute.gong_ji = attr.gong_ji * num
		attribute.fang_yu = attr.fang_yu * num
		attribute.ming_zhong = attr.ming_zhong * num
		attribute.shan_bi = attr.shan_bi * num
		attribute.bao_ji = attr.bao_ji * num
		attribute.jian_ren = attr.jian_ren * num
		attribute.goddess_gongji = attr.goddess_gongji * num
	end

	return attribute
end


CommonDataManager.PROF_ATTR_RATE = {
	{max_hp = 1.1103, gong_ji = 0.89, fang_yu = 1},
	{max_hp = 0.9662, gong_ji = 1.03, fang_yu = 1},
	{max_hp = 1.0356, gong_ji = 0.98, fang_yu = 1},
	{max_hp = 0.8832, gong_ji = 1.09, fang_yu = 1}
}


-- 读取一个对象的属性值,没有下划线
function CommonDataManager.GetAttributteNoUnderline(info)
	local attribute = CommonStruct.AttributeNoUnderline()
	if nil ~= info then
		attribute.gongji = info.gong_ji or info.attack or info.gongji or 0
		attribute.maxhp = info.max_hp or info.maxhp or info.hp or info.qixue or 0
		attribute.fangyu = info.fang_yu or info.fangyu or 0
		attribute.mingzhong = info.ming_zhong or info.mingzhong or 0
		attribute.shanbi = info.shan_bi or info.shanbi or 0
		attribute.baoji = info.bao_ji or info.baoji or 0
		attribute.jianren = info.jian_ren or info.jianren or info.kangbao or info.kang_bao or 0
		attribute.per_jingzhun = info.per_jingzhun or info.jingzhun_per or 0
		attribute.per_baoji = info.per_baoji or info.baoji_per or 0
		attribute.per_mianshang = info.per_mianshang or info.per_mianshang or 0
		attribute.per_pofang = info.per_pofang or info.per_pofang or 0
		attribute.per_gongji = info.per_gongji or info.per_gongji or 0
		attribute.per_maxhp = info.per_maxhp or info.per_maxhp or 0
		attribute.goddess_gongji = info.goddess_gongji or info.fujia_shanghai or info.xiannv_gongji or 0
		attribute.constant_mianshang = info.constant_mianshang or info.mian_shang or info.mianshang or 0
		attribute.constant_zengshang = info.constant_zengshang or 0
		attribute.huixinyiji = info.huixinyiji or 0
		attribute.huixinyiji_hurt = info.huixinyiji_hurt or 0
	end
	return attribute
end

-- 读取一个对象的属性值,没有下划线(女神)
function CommonDataManager.GetGoddessAttributteNoUnderline(info)
	local attribute = CommonStruct.AttributeNoUnderline()

	if nil ~= info then
		attribute.gongji = info.gong_ji or info.attack or info.gongji or 0
		attribute.maxhp = info.max_hp or info.maxhp or info.hp or info.qixue or 0
		attribute.fangyu = info.fang_yu or info.fangyu or 0
		attribute.mingzhong = info.ming_zhong or info.mingzhong or 0
		attribute.shanbi = info.shan_bi or info.shanbi or 0
		attribute.baoji = info.bao_ji or info.baoji or 0
		attribute.jianren = info.jian_ren or info.jianren or 0
		attribute.per_jingzhun = info.per_jingzhun or info.jingzhun_per or 0
		attribute.per_baoji = info.per_baoji or info.baoji_per or 0
		attribute.per_mianshang = info.per_mianshang or info.per_mianshang or 0
		attribute.per_pofang = info.per_pofang or info.per_pofang or 0
		attribute.per_gongji = info.per_gongji or info.per_gongji or 0
		attribute.per_maxhp = info.per_maxhp or info.per_maxhp or 0
		attribute.goddess_gongji = info.goddess_gongji or info.fujia_shanghai or info.xiannv_gongji or info.fu_jia or info.fujia or 0
		attribute.constant_mianshang = info.constant_mianshang or info.mian_shang or info.mianshang or 0
		attribute.constant_zengshang = info.constant_zengshang or 0
		attribute.huixinyiji = info.huixinyiji or 0
		attribute.huixinyiji_hurt = info.huixinyiji_hurt or 0
	end
	return attribute
end

-- 读取一个对象的属性值，有下划线
function CommonDataManager.GetAttributteByClass(info)
	local attribute = CommonStruct.Attribute()

	if nil ~= info then
		attribute.gong_ji = info.gong_ji or info.attack or info.gongji or 0
		attribute.max_hp = info.max_hp or info.maxhp or info.hp or info.qixue or 0
		attribute.fang_yu = info.fang_yu or info.fangyu or 0
		attribute.ming_zhong = info.ming_zhong or info.mingzhong or 0
		attribute.shan_bi = info.shan_bi or info.shanbi or 0
		attribute.bao_ji = info.bao_ji or info.baoji or 0
		attribute.jian_ren = info.jian_ren or info.jianren or 0
		attribute.per_jingzhun = info.per_jingzhun or info.jingzhun_per or 0
		attribute.per_baoji = info.per_baoji or info.baoji_per or 0
		attribute.per_mianshang = info.per_mianshang or info.per_mianshang or 0
		attribute.per_pofang = info.per_pofang or info.per_pofang or 0
		attribute.per_gongji = info.per_gongji or info.per_gongji or 0
		attribute.per_maxhp = info.per_maxhp or info.per_maxhp or 0
		attribute.move_speed = info.move_speed or info.movespeed or 0
		attribute.goddess_gongji = info.goddess_gongji or info.fujia_shanghai or info.xiannv_gongji or 0
		attribute.constant_mianshang = info.constant_mianshang or info.mian_shang or info.mianshang or 0
		attribute.constant_zengshang = info.constant_zengshang or 0
		attribute.huixinyiji = info.huixinyiji or 0
		attribute.huixinyiji_hurt = info.huixinyiji_hurt or 0
	end
	return attribute
end

-- 读取一个对象的进阶属性值
function CommonDataManager.GetAdvanceAttributteByClass(info)
	local attribute = CommonStruct.AdvanceAttribute()

	if nil ~= info then
		attribute.mount_attr = info.mount_attr or info.mountattr or 0
		attribute.wing_attr = info.wing_attr or info.wingattr or 0
		attribute.halo_attr = info.halo_attr or info.haloattr or 0
		attribute.shengong_attr = info.shengong_attr or info.shengongattr or 0
		attribute.shenyi_attr = info.shenyi_attr or info.shenyiattr or 0
	end

	return attribute
end

-- 读取一个对象的进阶加成属性值
function CommonDataManager.GetAdvanceAddibutteByClass(info)
	local attribute = CommonStruct.AdvanceAddbute()

	if nil ~= info then
		attribute.mount_add = info.mount_add or info.mountadd or 0
		attribute.wing_add = info.wing_add or info.wingadd or 0
		attribute.halo_add = info.halo_add or info.haloadd or 0
		attribute.shengong_add = info.shengong_add or info.shengongadd or 0
		attribute.shenyi_add = info.shenyi_add or info.shenyiadd or 0
		attribute.footprint_add = info.footprint_add or info.shenyiadd or 0
		attribute.fightmount_add = info.fightmount_add or info.shenyiadd or 0
	end

	return attribute
end

function CommonDataManager.AttributeAddProfRate(attribute)
	if nil == attribute then return end
	local prof = PlayerData.Instance:GetRoleBaseProf()

	for k,v in pairs(attribute) do
		local prof_attr_rate = CommonDataManager.PROF_ATTR_RATE[prof] or {}
		if prof_attr_rate[k] then
			attribute[k] = math.floor(v * prof_attr_rate[k])
		end
	end
end

function CommonDataManager.GetProfAttrValue(value, attr_name)
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local prof_attr_rate = CommonDataManager.PROF_ATTR_RATE[prof]
	if nil == prof_attr_rate then return value end

	if attr_name == "attack" or attr_name == "gongji" or attr_name == "gong_ji" then
		return math.floor(value * prof_attr_rate["gong_ji"])
	end

	if attr_name == "fangyu" or attr_name == "fang_yu" then
		return math.floor(value * prof_attr_rate["fang_yu"])
	end

	if attr_name == "maxhp" or attr_name == "hp" or attr_name == "qixue" or attr_name == "max_hp" then
		return math.floor(value * prof_attr_rate["max_hp"])
	end
	return value
end

-- 读取一个显示属性列表
function CommonDataManager.GetAttrNameAndValueByClass(info, all_show)
	local list = {}
	local attribute = CommonDataManager.GetAttributteByClass(info)
	for k,v in pairs(attribute) do
		if all_show or v > 0 then
			local vo  = {}
			vo.attr_name = CommonDataManager.GetAttrName(k)
			vo.value = v
			list[#list + 1] = vo
		end
	end
	return list
end

-- 读取一个显示属性列表（根据新规则顺序排列属性表）
function CommonDataManager.GetNewAttrNameAndValueByClass(info, all_show)
	local list = {}
	local new_arr_data = Language.Common.Arrt_Data
	local attribute = CommonDataManager.GetAttributteByClass(info)
	for k, v in ipairs(new_arr_data) do
		if attribute[v] then
			local attr = attribute[v]
			if all_show or attr > 0 then
				local vo  = {}
				vo.attr_name = CommonDataManager.GetAttrName(v)
				vo.value = attribute[v]
				list[#list + 1] = vo
			end
		end
	end
	return list
end

-- 读取一个显示进阶加成列表
function CommonDataManager.GetAdvanceAddNameAndValueByClass(info, all_show)
	local list = {}
	local attribute = CommonDataManager.GetAdvanceAddibutteByClass(info)
	for k,v in pairs(attribute) do
		if all_show or v > 0 then
			local vo  = {}
			vo.attr_name = CommonDataManager.GetAdvanceAddName(k)
			vo.value = v
			vo.attr = k
			list[#list + 1] = vo
		end
	end
	return list
end

function CommonDataManager.GetAttrKeyList()
	return{
		[1] = "max_hp",
		[2] = "gong_ji",
		[3] = "fang_yu",
		[4] = "ming_zhong",
		[5] = "shan_bi",
		[6] = "bao_ji",
		[7] = "jian_ren",
		[8] = "move_speed",
	}
end

function CommonDataManager.FlushAttrView(widgets, attribute, showspd)
	if nil ~= widgets and nil ~= attribute then
		for k,v in pairs(CommonDataManager.attrview_t) do
			if widgets["lbl_" .. v[1] .. "_val"] then
				widgets["lbl_" .. v[1] .. "_val"].node:setString(attribute[v[2]])
			end
			if v[2] == "gong_ji" and widgets.lbl_mingongji_val then
				widgets.lbl_mingongji_val.node:setString(math.floor(attribute.gong_ji * 0.4))
			end
		end
		if true == showspd then
			-- local speed = (attribute.move_speed / COMMON_CONSTS.ROLE_MOVE_SPEED) * 100
			widgets.lbl_movespeed_val.node:setString("+" .. attribute.speed_percent .. "%")
		end
	end
end

-- 刷新下一级属性
function CommonDataManager.FlushNextAttrView(widgets, attribute, showspd)
	if nil ~= widgets and nil ~= attribute then
		for k,v in pairs(CommonDataManager.attrview_t) do
			if widgets["lbl_" .. v[1] .. "_add"] then
				local node = widgets["lbl_" .. v[1] .. "_add"].node
				node:setVisible(0 ~= attribute[v[2]])
				if 0 ~= attribute[v[2]] then
					node:setString("+" .. attribute[v[2]])
				end
				if widgets["img_" .. v[1] .. "_add"] then
					widgets["img_" .. v[1] .. "_add"].node:setVisible(0 ~= attribute[v[2]])
				end
			end
			if v[2] == "gong_ji" and widgets.lbl_mingongji_add then
				widgets.lbl_mingongji_add.node:setVisible(0 ~= math.floor(attribute.gong_ji * 0.4))
				if widgets.img_mingongji_add then
					widgets.img_mingongji_add.node:setVisible(0 ~= math.floor(attribute.gong_ji * 0.4))
				end
				if 0 ~= math.floor(attribute.gong_ji * 0.4) then
					widgets.lbl_mingongji_add.node:setString("+" .. math.floor(attribute.gong_ji * 0.4))
				end
			end
		end

		if true == showspd then
			widgets.lbl_movespeed_add.node:setVisible(0 ~= attribute.move_speed)
			widgets.img_arrow_speed.node:setVisible(0 ~= attribute.move_speed)
			if 0 ~= attribute.move_speed then
				widgets.lbl_movespeed_add.node:setString("+" .. attribute.speed_percent .. "%")
			end
		end
	end
end

-- 刷新下一级属性
function CommonDataManager.FlushArrowsNextAttrView(widgets, attribute, showspd)
	if nil ~= widgets and nil ~= attribute then
		for k,v in pairs(CommonDataManager.attrview_t) do
			if widgets["lbl_" .. v[1] .. "_add"] then
				local node = widgets["lbl_" .. v[1] .. "_add"].node
				local arrows = widgets["img_" .. v[1] .. "_add"].node
				node:setVisible(0 ~= attribute[v[2]])
				arrows:setVisible(0 ~= attribute[v[2]])
				if 0 ~= attribute[v[2]] then
					node:setString(attribute[v[2]])
				end
			end
			if v[2] == "gong_ji" and widgets.lbl_mingongji_add then
				widgets.lbl_mingongji_add.node:setVisible(0 ~= math.floor(attribute.gong_ji * 0.4))
				widgets.img_mingongji_add.node:setVisible(0 ~= math.floor(attribute.gong_ji * 0.4))
				if 0 ~= math.floor(attribute.gong_ji * 0.4) then
					widgets.lbl_mingongji_add.node:setString(math.floor(attribute.gong_ji * 0.4))
				end
			end
		end

		if true == showspd then
			widgets.lbl_movespeed_add.node:setVisible(0 ~= attribute.move_speed)
			widgets.img_movespeed_add.node:setVisible(0 ~= attribute.move_speed)
			if 0 ~= attribute.move_speed then
				widgets.lbl_movespeed_add.node:setString(attribute.speed_percent .. "%")
			end
		end
	end
end

-- 获取基础属性名字
function CommonDataManager.GetAttrName(attr_type)
	attr_type = attr_type == "fangyu" and "fang_yu" or attr_type
	attr_type = attr_type == "gongji" and "gong_ji" or attr_type
	attr_type = attr_type == "maxhp" and "max_hp" or attr_type
	attr_type = attr_type == "jianren" and "jian_ren" or attr_type
	attr_type = attr_type == "shanbi" and "shan_bi" or attr_type
	attr_type = attr_type == "baoji" and "bao_ji" or attr_type
	attr_type = attr_type == "mingzhong" and "ming_zhong" or attr_type

	return Language.Common.AttrName[attr_type] or "nil"
end

-- 获取进阶属性名字
function CommonDataManager.GetAdvanceAttrName(attr_type)
	attr_type = attr_type == "mountattr" and "mount_attr" or attr_type
	attr_type = attr_type == "wingattr" and "wing_attr" or attr_type
	attr_type = attr_type == "haloattr" and "halo_attr" or attr_type
	attr_type = attr_type == "shengongattr" and "shengong_attr" or attr_type
	attr_type = attr_type == "shenyiattr" and "shenyi_attr" or attr_type
	return Language.Common.AdvanceAttrName[attr_type] or "nil"
end

-- 获取进阶加成名字
function CommonDataManager.GetAdvanceAddName(attr_type)
	attr_type = attr_type == "mountadd" and "mount_add" or attr_type
	attr_type = attr_type == "wingadd" and "wing_add" or attr_type
	attr_type = attr_type == "haloadd" and "halo_add" or attr_type
	attr_type = attr_type == "shengongadd" and "shengong_add" or attr_type
	attr_type = attr_type == "shenyiadd" and "shenyi_add" or attr_type
	attr_type = attr_type == "footprintadd" and "footprint_add" or attr_type
	attr_type = attr_type == "fightmountadd" and "fightmount_add" or attr_type
	return Language.Common.AdvanceAddName[attr_type] or "nil"
end

-- 速度换算
function CommonDataManager.CountSpeedForPercent(speed)
	local speed_percent = (speed / COMMON_CONSTS.ROLE_MOVE_SPEED) * 100
	speed_percent = GameMath.Round(speed_percent / 5) * 5

	return speed_percent
end

--通过索引获得仓库的格子对应的编号 cell_index-滚动条索引(从1开始), row-列数 column-行数
function CommonDataManager.GetCellIndexList(cell_index, row, column)
	local cell_index_list = {}
	local x = math.floor(cell_index/row)
	if x > 0 and x * row ~= cell_index then
		cell_index = cell_index + row * (column - 1) * x
	elseif x > 1 and x * row == cell_index then
		cell_index = cell_index + row * (column - 1) * (x - 1)
	end
	for i=1,column do
		if i == 1 then
			cell_index_list[i] = cell_index + i - 1
		else
			cell_index_list[i] = cell_index + row * (i - 1)
		end
	end
	return cell_index_list
end

--=============================新ui控件重写=============================--

function CommonDataManager.ParseTagContent(content, font_size)
	font_size = font_size or 32
	--有名字替换，<player_name>主角</player_name>
	local name = PlayerData.Instance.role_vo.name--HtmlTool.GetHtml(PlayerData.Instance.role_vo.name, COLOR.YELLOW , font_size)
	content = XmlUtil.RelaceTagContent(content, "player_name", name)

	--有性别替换，<sex0>女娃儿</sex0><sex1>小兄弟</sex1>
	local sex = PlayerData.Instance.role_vo.sex
	local sex_tag_content = XmlUtil.GetTagContent(content, "sex" .. sex)
	if sex_tag_content ~= nil then
		content = XmlUtil.RelaceTagContent(content, "sex0", sex_tag_content)
		content = XmlUtil.RelaceTagContent(content, "sex1", "")
	end

	local camp = PlayerData.Instance.role_vo.camp
	local camp_tag_content = XmlUtil.GetTagContent(content, "camp" .. camp)
	if camp_tag_content ~= nil then
		content = XmlUtil.RelaceTagContent(content, "camp1", camp_tag_content)
		content = XmlUtil.RelaceTagContent(content, "camp0", "")
		content = XmlUtil.RelaceTagContent(content, "camp2", "")
		content = XmlUtil.RelaceTagContent(content, "camp3", "")
	end

	return content
end

-- 解析不同平台的游戏名字
function CommonDataManager.ParseGameName(content)
	return string.gsub(content, "{gamename;}", CommonDataManager.GetGameName())
end

function CommonDataManager.GetGameName()
	if nil ~= AgentAdapter and nil ~= AgentAdapter.GetGameName then
		return AgentAdapter:GetGameName()
	end

	return UnityEngine.Application.installerName
	-- return Language.Common.GameName[1]
end

function CommonDataManager.GetAgentGameName()
	local game_name = ""
	local spid = AgentAdapter:GetSpid()
	for k, v in pairs(Config.agent_adapt_auto.agent_adapt) do
		if spid == v.spid then
			game_name = v.game_name
		end
	end
	return game_name
end

--解析不同平台的交流群
function CommonDataManager.ParseContectGroup(content)

	local i, j = string.find(content, "{contectgroup_2;}")
	if i ~= nil and j ~= nil then
		local contect_group = CommonDataManager.GetAgentContectGroup2()
		content =  string.gsub(content, "{contectgroup_2;}", contect_group)
	end
	i, j = string.find(content, "{contectgroup;}")
	if i == nil or j == nil then return content end

	local contect_group = CommonDataManager.GetAgentContectGroup()
	return string.gsub(content, "{contectgroup;}", contect_group)
end

function CommonDataManager.GetAgentContectGroup2()
	local contect_group = ""
	local spid = AgentAdapter:GetSpid()
	for k, v in pairs(ConfigManager.Instance:GetAutoConfig("agent_adapt_auto").agent_adapt) do
		local is_spec = CommonDataManager.IsSpecAgentContect(v.spec_id)
		if spid == v.spid then
			if is_spec then
				contect_group = v.spec_contect_2
			else
				contect_group = v.contect_2
			end
		end
	end
	return contect_group
end

function CommonDataManager.GetAgentContectGroup()
	local contect_group = ""
	local spid = AgentAdapter:GetSpid()
	for k, v in pairs(ConfigManager.Instance:GetAutoConfig("agent_adapt_auto").agent_adapt) do
		local is_spec = CommonDataManager.IsSpecAgentContect(v.spec_id)
		if spid == v.spid then
			if is_spec then
				contect_group = v.spec_contect
			else
				contect_group = v.contect
			end
		end
	end
	return contect_group
end

function CommonDataManager.IsSpecAgentContect(spec_id)
	local list = Split(spec_id, "#")
	local server_id = GameVoManager.Instance:GetUserVo().plat_server_id
	for k,v in pairs(list) do
		if tonumber(v) == server_id then
			return true
		end
	end
	return false
end

-- 转换游戏品质
function CommonDataManager.ChangeQuality(obj, level)
	if nil ~= obj and nil ~= obj.gameObject and not IsNil(obj.gameObject) then
		local control_active_list = obj.gameObject:GetComponentsInChildren(typeof(QualityControlActive))
		for i = 0, control_active_list.Length - 1 do
			local control_active = control_active_list[i]
			if control_active then
				control_active:SetOverrideLevel(level or 0)
			end
		end
	end
end

-- 还原游戏品质
function CommonDataManager.ResetQuality(obj)
	if nil ~= obj and nil ~= obj.gameObject and not IsNil(obj.gameObject) then
		local control_active_list = obj.gameObject:GetComponentsInChildren(typeof(QualityControlActive))
		for i = 0, control_active_list.Length - 1 do
			local control_active = control_active_list[i]
			if control_active then
				control_active:ResetOverrideLevel()
			end
		end
	end
end

-- 设置头像(优化版)(show_image_variable是否展示默认头像的绑定变量)(image_asset_variable设置默认头像资源的绑定变量)
function CommonDataManager.NewSetAvatar(role_id, show_image_variable, image_asset_variable, raw_image_obj, sex, prof, is_big, download_callback)
	-- 如果是主角
	if role_id == GameVoManager.Instance:GetMainRoleVo().role_id then
		-- 如果是跨服中
		if IS_ON_CROSSSERVER then
			role_id = CrossServerData.Instance:GetRoleId()
		end
	end
	is_big = is_big or false
	if AvatarManager.Instance:isDefaultImg(role_id) == 0 then
		show_image_variable:SetValue(true)
		local bundle, asset = AvatarManager.GetDefAvatar(PlayerData.Instance:GetRoleBaseProf(prof), is_big, sex)
		image_asset_variable:SetAsset(bundle, asset)
	else
		local avatar_key = AvatarManager.Instance:GetAvatarKey(role_id, is_big)
		local path = AvatarManager.GetFilePath(role_id, is_big)
		if not AvatarManager.HasCache(avatar_key, path) then
			show_image_variable:SetValue(true)
			local bundle, asset = AvatarManager.GetDefAvatar(PlayerData.Instance:GetRoleBaseProf(prof), is_big, sex)
			image_asset_variable:SetAsset(bundle, asset)
		end

		local callback = function (path)
			if nil == raw_image_obj or IsNil(raw_image_obj.gameObject) then
				return
			end

			local avatar_path = path or AvatarManager.GetFilePath(role_id, is_big)
			raw_image_obj.raw_image:LoadSprite(avatar_path,
			function()
				if nil == raw_image_obj or IsNil(raw_image_obj.gameObject) then
					return
				end

				show_image_variable:SetValue(false)
			end)
		end
		AvatarManager.Instance:GetAvatar(role_id, is_big, download_callback or callback)
	end
end

-- 设置头像
function CommonDataManager.SetAvatar(role_id, raw_image_obj, default_image_obj, default_image_Assets, sex, prof, is_big)
	-- 如果是主角
	if role_id == GameVoManager.Instance:GetMainRoleVo().role_id then
		-- 如果是跨服中
		if IS_ON_CROSSSERVER then
			role_id = CrossServerData.Instance:GetRoleId()
		end
	end
	is_big = is_big or false
	if AvatarManager.Instance:isDefaultImg(role_id) == 0 then
		raw_image_obj.gameObject:SetActive(false)
		default_image_obj.gameObject:SetActive(true)
		local bundle, asset = AvatarManager.GetDefAvatar(PlayerData.Instance:GetRoleBaseProf(prof), is_big, sex)
		default_image_Assets:SetAsset(bundle, asset)
	else
		local avatar_key = AvatarManager.Instance:GetAvatarKey(role_id, is_big)
		local path = AvatarManager.GetFilePath(role_id, is_big)
		if not AvatarManager.HasCache(avatar_key, path) then
			raw_image_obj.gameObject:SetActive(false)
			default_image_obj.gameObject:SetActive(true)
			local bundle, asset = AvatarManager.GetDefAvatar(PlayerData.Instance:GetRoleBaseProf(prof), is_big, sex)
			default_image_Assets:SetAsset(bundle, asset)
		end

		local callback = function (path)
			if nil == raw_image_obj or IsNil(raw_image_obj.gameObject) then
				return
			end
			local avatar_path = path or AvatarManager.GetFilePath(role_id, is_big)
			raw_image_obj.raw_image:LoadSprite(avatar_path,
			function()
				if raw_image_obj and not IsNil(raw_image_obj.gameObject) then
					raw_image_obj.gameObject:SetActive(true)
				end
				if default_image_obj and not IsNil(default_image_obj.gameObject) then
					default_image_obj.gameObject:SetActive(false)
				end
			end)
		end
		AvatarManager.Instance:GetAvatar(role_id, is_big, callback)
	end
end

function CommonDataManager.SetAvatarFrame(role_id, image_variable, show_default)
	local key = AvatarManager.Instance:GetAvatarFrameKey(role_id)
	CoolChatCtrl.Instance:SetAvatarFrameImage(image_variable, key, show_default)
end

function CommonDataManager.GetRandomName(rand_num)
	local name_cfg = ConfigManager.Instance:GetAutoConfig("randname_auto").random_name[1]
	local sex = rand_num % 2

	local name_first_list = {}	-- 前缀
	local name_last_list = {}	-- 后缀
	if sex == GameEnum.FEMALE then
		name_first_list = name_cfg.female_first
		name_last_list = name_cfg.female_last
	else
		name_first_list = name_cfg.male_first
		name_last_list = name_cfg.male_last
	end

	local name_first_index = (rand_num % #name_first_list) + 1
	local name_last_index = (rand_num % #name_last_list) + 1
	local first_name = name_first_list[name_first_index] or ""
	local last_name = name_last_list[name_last_index] or ""
	return first_name .. last_name
end

-- 属性排序权重
local AttributeWeight =
{
	max_hp = 99,								-- 血量上限
	gong_ji = 98,								-- 攻击
	fang_yu = 97,								-- 防御
	ming_zhong = 96,							-- 命中
	shan_bi = 95,								-- 闪避
	bao_ji = 94,								-- 暴击
	jian_ren = 93,								-- 抗暴
	move_speed = 92,							-- 移动速度
	per_jingzhun = 91,							-- 破甲
	per_baoji = 90,								-- 暴伤
	per_pofang = 89,							-- 增伤
	per_mianshang = 88,							-- 免伤
	goddess_gongji = 87,						-- 女神攻击
	constant_zengshang = 86,					-- 固定增伤
	constant_mianshang = 85,					-- 固定免伤


	maxhp = 99,									-- 血量上限
	gongji = 98,								-- 攻击
	fangyu = 97,								-- 防御
	mingzhong = 96,								-- 命中
	shanbi = 95,								-- 闪避
	baoji = 94,									-- 暴击
	jianren = 93,								-- 抗暴
	movespeed = 92,								-- 移动速度

	["生命"] = 99,
	["攻击"] = 98,
	["防御"] = 97,
	["命中"] = 96,
	["闪避"] = 95,
	["暴击"] = 94,
	["抗暴"] = 93,
}


function CommonDataManager.SortAttribute(attribute)
	local temp_tbl = {}
	for k,v in pairs(attribute) do
		table.insert(temp_tbl, {key = k, value = v})
	end

	table.sort(temp_tbl, function(a, b)
		return (AttributeWeight[a.key] or 0) > (AttributeWeight[b.key] or 0)
	end)

	return temp_tbl
end

function CommonDataManager.SearchAttributeValue(attribute,name)
	for k,v in ipairs(attribute) do
		if v.key == name then
			return v.value
		end
	end
	return 0
end

function CommonDataManager.StringToTable(s)
    local tb = {}
    for utfChar in string.gmatch(s, "[%z\1-\127\194-\244][\128-\191]*") do
        table.insert(tb, utfChar)
    end

    return tb
end

function CommonDataManager.GetExpNumber(raltio, level)
   	--经验公式： 系数/10000 * MAX（10000*等级^2 -600000*等级 + 150000000，1000000000 * 2.72^(0.0095*（等级 - 400)))
	local num_1 = 10000 * math.pow(level, 2) - 600000 * level + 150000000
	local num_2 = 1000000000 * math.pow(2.72, (0.0095 * (level - 400)))

	local exp = raltio / 10000 * math.max(num_1, num_2)

    return exp
end