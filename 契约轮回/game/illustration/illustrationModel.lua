illustrationModel = illustrationModel or class('illustrationModel',BaseModel)

function illustrationModel:ctor()
    illustrationModel.Instance = self

    self:Reset()
end

function illustrationModel:Reset()
    self.first_menu = {}  --一级菜单数据
    self.second_menu = {}  --二级菜单数据

    --[id] = cfg
    --[图鉴id] = {图鉴配置}
    self.ill_cfg = {}  --图鉴数据

    --[type_id][mid_type_id][sub_type_id] = {sname,ill_id,com_id}
    --[一级菜单id][二级带单id][三级菜单id] = {三级菜单名,图鉴id,组合id}
    self.menu_cfg = {}  --菜单数据

    --[id][star] = illustration_star
    --[图鉴id][星级] = 星级配置
    self.star_cfg = {}  --星级数据

    self.ill_info = {}  --图鉴信息列表


    self.ATTR = {

		[1] = "Current HP",

		[2] = "HP",

		[3] = "Speed (pixel/s), multiplier of 20",

		[4] = "ATK",

		[5] = "DEF",

		[6] = "Penetration",

		[7] = "Accuracy",

		[8] = "Dodge",

		[9] = "Crit",

		[10] = "TEN",

		[11] = "M. ATK",

		[12] = "M. DEF",

		[13] = "Attack Boost",

		[14] = "Damage Reduction",

		[15] = "Hit Chance",

		[16] = "Dodge Rate",

		[17] = "Armor",

		[18] = "Armor Penetration",

		[19] = "Block Rate",

		[20] = "Pierce",

		[21] = "Crit Rate",

		[22] = "Crit Resistance",

		[23] = "Concentrated Strike Rate",

		[24] = "Concentrated Strike Resistance",

		[25] = "Crit Damage",

		[26] = "Concentrated Strike Damage",

		[27] = "Increased Skill Damage",

		[28] = "Skill Damage Reduction",

		[29] = "Strike Rate",

		[30] = "Chance of Weakening",

		[31] = "Crit Damage Reduction",

		[32] = "Normal attack damage increase",

		[33] = "Block damage",

		[34] = "PVP Damage Resistance",

		[35] = "PVP Armor",

		[36] = "PVP Armor Penetration",

		[37] = "Boss Damage Boost",

		[38] = "Monster damage bonus",

		[39] = "Offensive skill CP",

		[40] = "Defensive skill CP",

		[41] = "Damage Reduction",

		[42] = "PVP Damage Resistance",

		[43] = "Concentrated skill damage reduction",

		[44] = "CP",

		[45] = "Absolute attack",

		[46] = "Absolute Evasion",

		[1100] = "Total Attribute Percentage (Overall)",

		[1102] = "HP Bonus",

		[1103] = "Speed bonus",

		[1104] = "Attack bonus",

		[1105] = "Defense Bonus",

		[1106] = "Penetration Bonus",

		[1107] = "Accuracy Bonus",

		[1108] = "Dodge Bonus",

		[1109] = "Crit Bonus",

		[1110] = "Tenacity Bonus",

		[1111] = "Spell damage bonus",

		[1112] = "Spell Defense Bonus",

		[1200] = "Total Attribute Percentage (Partial)",

		[1202] = "HP",

		[1204] = "ATK",

		[1205] = "DEF",

		[1206] = "Penetration",

		[1207] = "Accuracy",

		[1208] = "Dodge",

		[1209] = "Crit",

		[1210] = "TEN",

		[1211] = "M. ATK",

		[1212] = "M. DEF",

		[1302] = "Basic HP",

		[1304] = "Basic Attack",

		[1305] = "Basic Defense",

		[1306] = "Basic Penetration",

		[1404] = "Weapon Attack",

		[1406] = "Weapon Penetration",

		[1502] = "Armor HP",

		[1505] = "Armor Defense",

		[1604] = "Accessory Attack",

		[2000] = "EXP Bonus",

		[2001] = "Gold Drop Rate",

		[2002] = "Drop rate",

		[2003] = "Increase defense every 3 levels",

		[2004] = "Increase HP every 3 levels",

		[2005] = "Increase attack every 3 levels",

		[2006] = "Increase ATK by 10",

		[2007] = "Increase damage by 2% done to bosses every 50 levels",

		[2009] = "Reduce skill cd by",

		[2010] = "Enhancement Bonus",

	}
    self:InitMenuData()
end

function illustrationModel.GetInstance()
    if illustrationModel.Instance == nil then
        illustrationModel.new()
    end
    return illustrationModel.Instance
end

--初始化菜单数据
function illustrationModel:InitMenuData(  )

    local config = Config.db_illustration
    for i=1,#config do
        self.ill_cfg[config[i].id] = config[i]
    end


    local config = Config.db_illustration_menu

    for i=1,#config do
        self.first_menu[config[i].type_id] = {config[i].type_id,config[i].name}  

        self.second_menu[config[i].type_id] = self.second_menu[config[i].type_id] or {}
        self.second_menu[config[i].type_id][config[i].mid_type_id] = {config[i].mid_type_id,config[i].mname}
        
        self.menu_cfg[config[i].type_id] = self.menu_cfg[config[i].type_id] or {}
        self.menu_cfg[config[i].type_id][config[i].mid_type_id] = self.menu_cfg[config[i].type_id][config[i].mid_type_id] or {}
        
        local ill_id = String2Table(config[i].ill_id)
        local com_id = String2Table(config[i].com_id)
        self.menu_cfg[config[i].type_id][config[i].mid_type_id][config[i].sub_type_id] = {sname = config[i].sname,ill_id = ill_id,com_id = com_id}
    end

    local config = Config.db_illustration_star
    for i=1,#config do
        self.star_cfg[config[i].id] = self.star_cfg[config[i].id] or {}
        self.star_cfg[config[i].id][config[i].star] = config[i]
    end
end

--刷新图鉴信息
function illustrationModel:UpdateIllInfos(infos)
    self.ill_info = {}
    for k,v in pairs(infos) do
        self.ill_info[v.id] = v
    end
end

--刷新图鉴信息
function illustrationModel:UpdateIllInfo(info)
    self.ill_info[info.id] = info
end

function illustrationModel:GetAttrNameByIndex(index)

    if index == 3 then
        return "Speed"
    end

    return self.ATTR[index]
end

--获取指定颜色的图鉴列表
function illustrationModel:GetTargetColorItem(color_num)

    local items = BagModel.GetInstance().illustrationItems

    if color_num == -1 then
        return items
    end
   
    local color_items = {}
    for i,v in ipairs(items) do

       if Config.db_item[v.id].color == color_num then
          table.insert( color_items,v )
       end
    end
    return color_items
end

--根据id获取图鉴精华或图鉴数量
function illustrationModel:GetillItemNumByItemID(itemID)
    if (Constant.GoldIDMap[itemID]) then
        return RoleInfoModel:GetInstance():GetRoleValue(itemID)
    end
    local num = 0
    for i, v in pairs(BagModel.GetInstance().illustrationItems) do
        if v ~= 0 and v.id == itemID then
            num = num + v.num
        end
    end
    return num
end

--获取背包中已满星图鉴的升级物品列表（可分解的图鉴道具）
function illustrationModel:GetMaxStarUpIll()

    local tab = {}

    for k,v in pairs(self.ill_info) do
        if not self.star_cfg[v.id][v.star + 1] then
            local star_cfg = self.star_cfg[v.id][v.star]
            local item = String2Table(star_cfg.item)
            local id = item[1][1]
            tab[id] = true
        end
    end

    local items = BagModel.GetInstance().illustrationItems
    local max_star_ill_items = {}
    for k,v in pairs(items) do
        if tab[v.id] then
            table.insert( max_star_ill_items, v)
        end
    end


    return max_star_ill_items
end

--图鉴背包排序
--TODO:
function illustrationModel:SortIllustrationBag(items)
    
end

--检查所有图鉴中是否有可升星图鉴
function illustrationModel:CheckReddotByAll()

	local flag = false

	local cfg = Config.db_illustration
	for k,v in pairs(cfg) do
		
		local star = 0
		if self.ill_info[v.id] then
			--图鉴有星级 取info里的星级
			star = self.ill_info[v.id].star
		end

		if self:CheckReddotByTarget(v.id,star) then
			flag = true
			break
		end
	end

	--logError("图鉴红点检查，结果"..tostring(flag))
	GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger,66,flag)
	return flag
end

--检查目标图鉴是否为可升星图鉴
function illustrationModel:CheckReddotByTarget(id,star)

	local flag = false

	local cfg = self.star_cfg[id][star + 1]
	if not cfg then
		--满星图鉴 不可升星
		return flag
	end

	local item = String2Table(cfg.item)
	local essence = String2Table(cfg.essence)

	local item_have = self:GetillItemNumByItemID(item[1][1])
	local item_need = item[1][2]

	if item_have >= item_need then
		flag = true
	end

	if table.nums(essence) > 0 then
		local essence_have = self:GetillItemNumByItemID(essence[1][1])
		local essence_need = essence[1][2]
		
		if essence_have >= essence_need then
			flag = true
		end
	end

	--logError("图鉴"..id.."-当前星级"..star.."-是否可升星："..tostring(flag))

	return flag
end

--检查一级菜单中是否有可升星图鉴
function illustrationModel:CheckReddotByFirstMenu(first_menu_id)
	local cfg  = self.menu_cfg[first_menu_id]
	for k,v in pairs(cfg) do
		if self:CheckReddotBySecondMenu(first_menu_id,k) then
			return true
		end
	end

	return false
end

--检查二级菜单中是否有可升星图鉴
function illustrationModel:CheckReddotBySecondMenu(first_menu_id,second_menu_id)
	local cfg  = self.menu_cfg[first_menu_id][second_menu_id]
	for k,v in pairs(cfg) do
		if type(v) == "table" then
			if self:CheckReddotByTopBtn(first_menu_id,second_menu_id,k) then
				return true
			end
		end
	
	end

	return false
end

--检查三级菜单中是否有可升星图鉴
function illustrationModel:CheckReddotByTopBtn(first_menu_id,second_menu_id,top_btn_id)
	local cfg  = self.menu_cfg[first_menu_id][second_menu_id][top_btn_id]

	if cfg.ill_id[1] == 0 then
		--有组合

		for k,v in pairs(cfg.com_id) do
			local com_cfg =  Config.db_illustration_combination[v]
			local ills = com_cfg.illustrations
			ills = String2Table(ills)
			for k2,v2 in pairs(ills) do
				local id = v2
				local star = 0
				if self.ill_info[id] then
					--图鉴有星级 取info里的星级
					star = self.ill_info[id].star
				end
				if self:CheckReddotByTarget(id,star) then
					return true
				end
			end
		end
	else
		--无组合
		for k,v in pairs(cfg.ill_id) do
			local id = v
			local star = 0
			if self.ill_info[id] then
				--图鉴有星级 取info里的星级
				star = self.ill_info[id].star
			end

			if self:CheckReddotByTarget(id,star) then
				return true
			end
		end
	end

	return false
end

--检查是否有可分解图鉴道具红点
function illustrationModel:CheckDecomposeReddot()
	local tab = self:GetMaxStarUpIll()
	local flag = table.nums(tab) > 0
	return flag
end