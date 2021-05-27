CommonDataManager = CommonDataManager or {}

-- 匹配阶数（文字）
CommonDataManager.SIMPLIFIED_CHN_NUM =  { [0] = "零", "十", "一", "二", "三", "四", "五", "六", "七", "八", "九" }
CommonDataManager.TRADITIONAL_CHN_NUM =  { [0] = "零", "拾", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖" }

CommonDataManager.attrview_t = {{"hp", "max_hp"}, {"gongji", "gong_ji"}, {"fangyu", "fang_yu"}, {"mingzhong", "ming_zhong"}, {"shanbi", "shan_bi"}, {"baoji", "bao_ji"}, {"jianren", "jian_ren"}, {"fujiashanghai", "fujia_shanghai"}, {"dikangshanghai", "dikang_shanghai"}}

CommonDataManager.PROF_ATTR_RATE = {
	{max_hp = 1, gong_ji = 1, fang_yu = 1},
	{max_hp = 1, gong_ji = 1, fang_yu = 1},
	{max_hp = 1, gong_ji = 1, fang_yu = 1},
	{max_hp = 1, gong_ji = 1, fang_yu = 1}
}
function CommonDataManager.GetSimplifiedCHNNum(num, type)
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
		table = CommonDataManager.SIMPLIFIED_CHN_NUM
	else
		table = CommonDataManager.TRADITIONAL_CHN_NUM
	end

	result = table[index1 + 1]
	if index2 > -1 then
		result = result .. table[index2 + 1]
	end

	return result
end

--转换财富
function CommonDataManager.ConverMoney(value)
	if value >= 10000 and value < 100000000 then
		local result = value / 10000
		result = string.format("%.2f", result)
		result = result .. Language.Common.Wan
		return result
	end
	
	if value >= 100000000 then
		local result = value / 100000000
		result = string.format("%.2f", result)
		result = result .. Language.Common.Yi
		return result
	end
	return value
end

-- 战力值
function CommonDataManager.GetCapability(value)
	value = nil == value and CommonStruct.Attribute() or value

	local capability = math.floor(
		value.max_hp * 0.1
		+ value.fang_yu * 1.122
		+ value.gong_ji * 1.795
		+ value.fujia_shanghai * 1.36
		+ value.jian_ren * 5.714 * value.bao_ji / 10000)
	
	return capability
end

local pro2attr = {
	[1] = {[9] = true, [11] = true},
	[2] = {[13] = true, [15] = true},
	[3] = {[17] = true, [19] = true},
}

function CommonDataManager.GetAttrSetScore(attr_calc, prof)
	local spec_attrs = CommonDataManager.GetSpecialAttr(attr_calc)
	attr_calc = CommonDataManager.AddAttr(attr_calc, spec_attrs)
	local score = 0
	local attr_data_types = CommonDataManager.GetValuaionMap(prof)
	local attr_data
	for k, v in pairs(attr_calc) do
	 	attr_data = attr_data_types[v.type]
	 	if attr_data and attr_data.unitVal ~= 0 then
	 		if nil == v.job or (v.job and v.job == prof) then
 				score = score + v.value * attr_data.unitVal
 			end
	 	end
	 end 
	return math.floor(score)
end

function CommonDataManager.GetBaseAttrs(attrs)
	local new_attrs = {}
	for k, v in pairs(attrs or {}) do
		if nil ~= BASE_ATTR_TYPES[v.type] then
			new_attrs[#new_attrs + 1] = v
		end
	end
	return new_attrs
end

function CommonDataManager.GetSpecialAttr(attrs)
	local hp = 0
	local hp_per = 0

	for k, v in pairs(attrs) do
		if v.type == GAME_ATTRIBUTE_TYPE.MAX_HP_ADD then
			hp = v.value
		end
		if v.type == GAME_ATTRIBUTE_TYPE.MAX_HP_POWER then
			hp_per = v.value
		end
	end

	-- 无加成
	if hp_per == 0 then
		return {}
	end

	local role_hp = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_MAX_HP) or 0
	local role_hp_per = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_HP_PER) or 0

	local base_hp = role_hp / (1 + role_hp_per) -- 基础血量
	local real_add_value = base_hp * hp_per -- 真实血量增加值

	return {{type = GAME_ATTRIBUTE_TYPE.MAX_HP_ADD, value = real_add_value}}
end

local valuaion_list = {}
function CommonDataManager.GetValuaionMap(prof)
	prof = (nil == prof or 0 == prof) and RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF) or prof
	if nil == valuaion_list[prof] then
		if EquipValuation[prof] then
			valuaion_list[prof] = ListToMap(EquipValuation[prof], "attrId")
		else
			valuaion_list[prof] = {}
		end
	end
	return valuaion_list[prof]
end

function CommonDataManager.GetEquipValuaion()
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	return EquipValuation[prof] or {}
end

-- 两个属性相加
function CommonDataManager.AddAttributeAttr(attribute1, attribute2)
	local m_attribute = CommonStruct.Attribute()
	for k, v in pairs(m_attribute) do
		m_attribute[k] = (attribute1[k] or 0) + (attribute2[k] or 0)
	end

	return m_attribute
end

-- 两个属性相加
local BASE_ATTR = {[9] = true, [11] = true, [13] = true, [15] = true, [17] = true, [19] = true, [21] = true, [23] = true, [25] = true, [27] = true}
function CommonDataManager.AddAttr(attr1, attr2)
	attr1 = attr1 or {}
	attr2 = attr2 or {}
	local attr = {}
	local attr_real = {}
	for k,v in pairs(attr1) do
		attr[v.type] = v.value
	end
	for k,v in pairs(attr2) do
		if attr[v.type] then
			attr[v.type] = attr[v.type] + v.value
		else
			attr[v.type] = v.value
		end
	end
	for k,v in pairs(attr) do
		table.insert(attr_real, {type = k, value = v})
	end
	table.sort(attr_real, CommonDataManager.SortAttr())
	return attr_real
end

function CommonDataManager.SortAttr()
	return function(a, b)
		if BASE_ATTR[a.type] ~= BASE_ATTR[b.type] then
			return BASE_ATTR[a.type]
		else
			return a.type < b.type
		end
	end
end

--筛选职业属性
function CommonDataManager.ScreenJobOtherAttr(attrs, prof)
	prof = (nil == prof or 0 == prof) and RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF) or prof
	local pro_attrs = {}
	for i,v in ipairs(attrs) do
		if nil == v.job or (v.job and v.job == prof) then
			table.insert(pro_attrs, {type = v.type, value = v.value})
		end
	end

	table.sort(pro_attrs, CommonDataManager.SortAttr())
	return pro_attrs
end

-- 两个属性差值(attr2 - attr1)
function CommonDataManager.LerpAttributeAttr(attr1, attr2)
	attr1 = attr1 or {}
	attr2 = attr2 or {}
	local attr = {}
	local attr_real = {}
	for k,v in pairs(attr2) do
		attr[v.type] = v.value
	end
	for k,v in pairs(attr1) do
		if attr[v.type] then
			attr[v.type] = attr[v.type] - v.value
		end
	end
	for k,v in pairs(attr) do
		if v > 0 then
			table.insert(attr_real, {type = k, value = v})
		end
	end
	table.sort(attr_real, CommonDataManager.SortAttr())
	return attr_real
end

-- 属性乘以一个常数
function CommonDataManager.MulAttribute(attr, num)
	local m_attribute = CommonStruct.Attribute()
	for k, v in pairs(m_attribute) do
		m_attribute[k] = (attr[k] or 0) * num
	end

	return m_attribute
end


-- 属性乘以一个常数
function CommonDataManager.MulAtt(attr, num)
	local new_attr = {} 
	for k,v in ipairs(attr) do
		new_attr[k] = {type = v.type, value = v.value > 1 and math.floor(v.value * num) or v.value * num}
	end
	return new_attr
end

-- 读取一个对象的属性值
function CommonDataManager.GetAttributteByClass(info)
	local attribute = CommonStruct.Attribute()

	if nil ~= info then
		attribute.max_hp = info.max_hp or info.maxhp or info.hp or info.qixue or 0
		attribute.fang_yu = info.fang_yu or info.fangyu or 0
		attribute.gong_ji = info.gong_ji or info.attack or info.gongji or 0
		attribute.ming_zhong = info.ming_zhong or info.mingzhong or 0
		attribute.shan_bi = info.shan_bi or info.shanbi or 0
		attribute.bao_ji = info.bao_ji or info.baoji or 0
		attribute.jian_ren = info.jian_ren or info.jianren or info.baoji_shanghai or 0
		attribute.fujia_shanghai = info.fujia_shanghai or info.fujiashanghai or 0
		attribute.dikang_shanghai = info.dikang_shanghai or info.dikangshanghai or 0
	end

	return attribute
end

function CommonDataManager.GetProfAttrValue(value, attr_name)
	local prof = RoleData.Instance:GetRoleBaseProf()
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

function CommonDataManager.FlushAttrView(widgets, attribute, showspd)
	if nil ~= widgets and nil ~= attribute then
		for k,v in pairs(CommonDataManager.attrview_t) do
			if widgets["lbl_" .. v[1] .. "_val"] then
				widgets["lbl_" .. v[1] .. "_val"].node:setString(math.floor(attribute[v[2]] + 0.5))
			end
		end
		if showspd then
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
					node:setString("+" .. math.floor(attribute[v[2]] + 0.5))			
				end
				if widgets["img_" .. v[1] .. "_add"] then
					widgets["img_" .. v[1] .. "_add"].node:setVisible(0 ~= attribute[v[2]])
				end
			end
		end

		if true == showspd then
			widgets.lbl_movespeed_add.node:setVisible(0 ~= attribute.move_speed)
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

--=============================新ui控件重写=============================--
function CommonDataManager.FlushUiGradeView(jie1, jie2, grade)
	jie2:setVisible(false)
	local index1 = grade
	local index2 = -1
	if 10 == grade then
		index1 = 0
	elseif grade > 10 then
		index1 = math.floor(grade / 10)
		index2 = grade % 10
		index1 = (1 == index1) and 0 or index1
	end
	if 10 == index1 then index1 = 0 end
	if 10 == index2 then index2 = 0 end
	jie1:loadTexture(ResPath.GetCommon("daxie_" .. index1))
	if index2 > -1 then
		jie2:setVisible(true)
		jie2:loadTexture(ResPath.GetCommon("daxie_" .. index2))
	end
end

--图片特效数字，暂时没有小数点   num (number)
function CommonDataManager.CreateLabelAtlasImage(num, path, tag, num_pre)
	local rich_content = XUI.CreateRichText(0, 0, 0, 0)
	rich_content:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	rich_content:setVerticalAlignment(RichVAlignment.VA_CENTER)
	rich_content:setIgnoreSize(true)
	CommonDataManager.SetUiLabelAtlasImage(num, rich_content)

	return rich_content
end

function CommonDataManager.SetUiLabelAtlasImage(num, rich_text, num_type, folder_name, num_pre, not_clear)
	if rich_text == nil then return end
	
	if not not_clear then
		rich_text:removeAllElements()
	end
	
	local len = string.len(num)
	local list = {}
	for var=1, len do
		list[var] = string.sub(num, var, var)
		if list[var] == ":" then
			list[var] = "colon"
		end
	end	
	
	local respath = nil
	folder_name = folder_name or "common"
	respath = "res/xui/"..folder_name.."/%s.png"
	if num_pre ~= nil then
		XUI.RichTextAddImage(rich_text, string.format(respath, num_pre), true)
	end
	len = #list
	for var=1, len do
		respath = "res/xui/"..folder_name.."/%s.png"
		if nil ~= num_type then
			respath = string.format(respath, num_type .. list[var])
		else
			respath = ResPath.GetCommon(list[var])
		end
		XUI.RichTextAddImage(rich_text, respath, true)
	end
end

function CommonDataManager.ParseTagContent(content, font_size)
	font_size = font_size or 32
	--有名字替换，<player_name>主角</player_name>
	local name = HtmlTool.GetHtml(RoleData.Instance.role_vo.name, COLOR3B.YELLOW , font_size)
	content = XmlUtil.ReplaceTagContent(content, "player_name", name)

	--有性别替换，<sex0>女娃儿</sex0><sex1>小兄弟</sex1>
	local sex = RoleData.Instance.role_vo.sex
	local sex_tag_content = XmlUtil.GetTagContent(content, "sex" .. sex)
	if sex_tag_content ~= nil then
		content = XmlUtil.ReplaceTagContent(content, "sex0", sex_tag_content)
		content = XmlUtil.ReplaceTagContent(content, "sex1", "")
	end

	local camp = RoleData.Instance.role_vo.camp
	local camp_tag_content = XmlUtil.GetTagContent(content, "camp" .. camp)
	if camp_tag_content ~= nil then
		content = XmlUtil.ReplaceTagContent(content, "camp1", camp_tag_content)
		content = XmlUtil.ReplaceTagContent(content, "camp0", "")
		content = XmlUtil.ReplaceTagContent(content, "camp2", "")
		content = XmlUtil.ReplaceTagContent(content, "camp3", "")
	end

	return content
end

-- 解析不同平台的游戏名字
function CommonDataManager.ParseGameName(content)
	return string.gsub(content, "%$GAMENAME%$", CommonDataManager.GetGameName() or "gamename")
end

function CommonDataManager.GetGameName()
	if nil ~= AgentAdapter.GetGameName then
		return AgentAdapter:GetGameName()
	end
	return Language.Common.GameName[1]
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
