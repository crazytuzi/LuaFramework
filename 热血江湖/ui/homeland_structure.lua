-- zengqingfeng
-- 2018/5/18 homeland_structure
--eUIID_HomeLandStructure --家园土地升级界面
-------------------------------------------------------
module(..., package.seeall)

local require = require;

local type_homeland_main = 100
local type_homeland_plant = 200 --
local type_homeland_ground = 201
local type_homeland_ground_point = 202
local type_homeland_fish = 300 --
local type_homeland_pool = 301
local type_homeland_fish_point = 302
local type_homeland_house = 400 -- 未开启

local groundName = {"花田", "果田", "林地"}
local cropName = {"花卉", "木材", "果树"}
-- 页签的类型分组和处理函数的对应表
local ClickFuncs = {
[type_homeland_main] = {"setHomelandMainView"},
[type_homeland_ground] = {"setHomelandGroundView"},
[type_homeland_ground_point] = {"setHomelandGroundPointView"},
[type_homeland_pool] = {"setHomelandFishView"},
[type_homeland_fish_point] = {"setHomelandFishPointView"},
[type_homeland_house] = {"setHomelandHouseView"},
}

local Icon_Res_ID = {
[type_homeland_main] = i3k_db_home_land_base.baseCfg.iconHomeland,
[type_homeland_plant] = i3k_db_home_land_base.baseCfg.iconGround,
[type_homeland_ground] = i3k_db_home_land_base.baseCfg.iconGround,
[type_homeland_ground_point] = i3k_db_home_land_base.baseCfg.iconGround,
[type_homeland_fish] = i3k_db_home_land_base.baseCfg.iconFish,
[type_homeland_pool] = i3k_db_home_land_base.baseCfg.iconFish,
[type_homeland_fish_point] = i3k_db_home_land_base.baseCfg.iconFish,
[type_homeland_house] = i3k_db_home_land_base.baseCfg.iconHouse,
}

local txtRes = "ui/widgets/jiayuanjzt4"

local ui = require("ui/base");
wnd_homeland_structure = i3k_class("homeland_structure", ui.wnd_base)

function wnd_homeland_structure:ctor()
	self._crop = nil -- 地图上作物的引用
	self._dropDownList = nil -- 下拉列表
	self._info = nil
	self._widgets = nil
	self._bagItems = nil
end

function wnd_homeland_structure:configure()
	local widgets = self._layout.vars
	self._widgets = widgets
	widgets.close:onClick(self,self.onCloseUI)
	
	widgets.homeLandBuild:stateToPressed()
	widgets.homeLandMain:onClick(self, self.onHomeLandMain)
	widgets.homeLandEquip:onClick(self, self.onHomeLandEquip)
	widgets.homeLandHistorys:onClick(self, self.onHomeLandHistorys)
	widgets.help3:setVisible(false)
	widgets.help2:setVisible(false)
	-- 设置要显示地块的数据
	local homeland = g_i3k_game_context:GetHomeLandData()
	local groundInfo = g_i3k_game_context:setHomelandGroundInfoByNetwork(homeland.grounds, homeland.level)
	local groundItemInfo = {}
	for groundIndex, value in ipairs(groundInfo) do
		table.insert(groundItemInfo, {_title_name = groundName[groundIndex], _data = value, _children = nil, _groupID = type_homeland_ground})
	end
	table.insert(groundItemInfo, {_title_name = i3k_get_string(5357), _data = homeland, _children = nil, _groupID = type_homeland_ground_point})
	
	local fishItemInfo = {
	{_title_name = "池塘等级", _data = homeland, _children = nil, _groupID = type_homeland_pool},
	{_title_name = i3k_get_string(5356), _data = homeland, _children = nil, _groupID = type_homeland_fish_point},
	}
	
	-- 合并和设置总数据
	self._info = {
	{_title_name = "家园等级", _data = homeland, _children = nil, _groupID = type_homeland_main},
	{_title_name = "家园耕地", _data = nil, _children = groundItemInfo, _groupID = type_homeland_plant},
	{_title_name = "家园钓鱼", _data = nil, _children = fishItemInfo, _groupID = type_homeland_fish},
	{_title_name = "房屋等级", _data = nil, _children = nil, _groupID = type_homeland_house},
	}
end

function wnd_homeland_structure:onShow()
	local widgets = self._layout.vars
	local itemView = require(txtRes)()
	widgets.scrollView1:addItem(itemView)
	self._itemView1 = itemView
	widgets.desc1 = itemView.vars.desc
	itemView = require(txtRes)()
	widgets.scrollView2:addItem(itemView)
	self._itemView2 = itemView
	widgets.desc2 = itemView.vars.desc
	widgets.scrollView1:setBounceEnabled(true)
	widgets.scrollView2:setBounceEnabled(true)
	
	local listener = {
	onInitView = self.onInitViewCallBack, -- 初始化页签时
	onSelected = self.onSelectedCallBack, -- 页签被选中时
	}
	self._dropDownList = g_i3k_ui_mgr:createDropDownList(self._widgets.totalList, self._info, i3k_getDropDownWidgetsMap(g_DROPDOWNLIST_HOMELAND_STRUCTURE))
	self._dropDownList:rgSelectedHandlers(self, ClickFuncs) -- 注册点击事件表
	self._dropDownList:rgListener(self, listener)
	self._dropDownList:show() -- 要放在注册回调之后
end

function wnd_homeland_structure:refresh()
	local size = self._widgets.desc1:getContentSize()
	self._itemView1.rootVar:changeSizeInScroll(self._widgets.scrollView1, size.width, size.height*1.5, true)
	local size = self._widgets.desc2:getContentSize()
	self._itemView2.rootVar:changeSizeInScroll(self._widgets.scrollView2, size.width, size.height*1.5, true)
	self._widgets.scrollView1:update()
	self._widgets.scrollView2:update()
end

function wnd_homeland_structure:showPlantTitle(groundId)
	self._dropDownList:clickItemByGroup(type_homeland_ground, function (nodeData)
		return nodeData.groundId == groundId
	end)
end

function wnd_homeland_structure:refreshCurNode()
	self._dropDownList:refreshCurNode()
end

-- 节点标签初始化时(除了名字和按钮点击外的其他页签初始化操作)
function wnd_homeland_structure:onInitViewCallBack(node, nodeData, view, childIndex)
	if not node:getTitleUIDesc() then
		return
	end
	
	local descStr, iconRes
	local nodeType = node:Type()
	local emptyTitleFun = function (node)
		descStr = ""
		node:setTitleUIName("", true)
		node:setTitleUISubName(node:TitleName(), true)
	end
	
	if nodeType == type_homeland_main then
		descStr = i3k_get_string(5151, nodeData.level)
	elseif nodeType == type_homeland_plant then
		emptyTitleFun(node)
	elseif nodeType == type_homeland_ground then
		descStr = self:getGroundLvlTagStr(nodeData)
	elseif nodeType == type_homeland_ground_point then
		descStr = i3k_get_string(5151, nodeData.plantData.plantLevel)
	elseif nodeType == type_homeland_fish then
		emptyTitleFun(node)
	elseif nodeType == type_homeland_pool then
		descStr = i3k_get_string(5151, nodeData.poolLevel)
	elseif nodeType == type_homeland_fish_point then
		descStr = i3k_get_string(5151, nodeData.fishData.fishLevel)
	elseif nodeType == type_homeland_house then
		if g_i3k_game_context:GetHomeLandHouseLevel() > 0 then
			descStr = i3k_get_string(5151, g_i3k_game_context:GetHomeLandHouseLevel())
		else
			descStr = "未解锁"
		end
	end
	
	iconRes = self:getIconPathByType(nodeType)
	node:setTitleDesc(descStr, true)
	node:setTitleIcon(iconRes, true)
end

-- 下拉菜单点击的公共回调
function wnd_homeland_structure:onSelectedCallBack(node, nodeData)
	local path = self:getIconPathByType(node:Type())
	if path then
		self._widgets.icon:setImage(path)
	end
end

function wnd_homeland_structure:setHomelandMainView(node, nodeData)
	local widgets = self._widgets
	local lvl = nodeData.level
	widgets.ok:setVisible(true)
	widgets.lockTips:setVisible(false)
	widgets.pointTips:setVisible(false)
	widgets.unlockTips:setVisible(true)
	widgets.costTips:setVisible(true)
	widgets.help1:setVisible(false)
	widgets.help2:setVisible(false)
	local curCfg = i3k_db_home_land_lvl[lvl]
	local nextCfg = i3k_db_home_land_lvl[lvl + 1]
	local okStr, desc1, desc2, condition = "", "", "", ""
	if not curCfg then
		okStr = i3k_get_string(451)
		desc1 = i3k_get_string(5141)
		widgets.lockTips:setVisible(true)
		widgets.unlockTips:setVisible(false)
		widgets.desc3:setText(i3k_get_string(5142))
	else
		okStr = i3k_get_string(449)
		desc1 = i3k_get_string(5131, curCfg.numLimit, curCfg.landLvlLimit, curCfg.poolLvlLimit, curCfg.houseLvlLimit)
		widgets.lockTips:setVisible(false)
		widgets.unlockTips:setVisible(true)
	end
	
	if not nextCfg then
		desc2 = i3k_get_string(5081, lvl)
		widgets.ok:setVisible(false)
		self._layout.vars.maxRoot:show()
		self._layout.anis.c_dakai.play()
		self._layout.vars.consume:hide()
	else
		self._layout.vars.maxRoot:hide()
		self._layout.anis.c_dakai.stop()
		self._layout.vars.consume:show()
		desc2 = i3k_get_string(5131, nextCfg.numLimit, nextCfg.landLvlLimit, nextCfg.poolLvlLimit, nextCfg.houseLvlLimit)
	end
	condition = i3k_get_string(5053, g_i3k_game_context:GetHomeLandLevel())
	
	widgets.fromName2:setText("") --(i3k_get_string(5053, lvl + 1))
	local needItems = self:getHomelandLevelUpNeedItems(lvl + 1)
	self:setPageIfno(condition, desc1, desc2, okStr, needItems)
	widgets.ok:onClick(self, self.homelandLevelUp, nodeData)
end

function wnd_homeland_structure:setHomelandGroundView(node, nodeData)
	local widgets = self._widgets
	widgets.ok:setVisible(true)
	widgets.pointTips:setVisible(false)
	widgets.costTips:setVisible(true)
	widgets.help1:setVisible(true)
	--widgets.help2:setVisible(true)
	local lvl = nodeData.level
	local curCfg = i3k_db_home_land_plant_lvl[lvl]
	local nextCfg = i3k_db_home_land_plant_lvl[lvl + 1]
	local okStr, desc1, desc2, condition = "", "", "", ""
	if lvl <= 0 then
		okStr = i3k_get_string(451)
		desc1 = i3k_get_string(5048)
		widgets.lockTips:setVisible(true)
		widgets.unlockTips:setVisible(false)
		widgets.desc3:setText(i3k_get_string(5143))
	else
		okStr = i3k_get_string(449)
		desc1 = g_i3k_db.i3k_db_getUnlockCropNameByGround(nodeData, lvl)
		
		desc1 = i3k_get_string(5049, lvl, cropName[nodeData.groundType]).."\n"..i3k_get_string(5133, desc1)
		widgets.lockTips:setVisible(false)
		widgets.unlockTips:setVisible(true)
	end
	
	if not i3k_db_home_land_land_lvl[lvl + 1] or (lvl + 1) > i3k_db_home_land_base.plantCfg.masterCanUpLvl then
		desc2 = i3k_get_string(5050)
		widgets.ok:setVisible(false)
		self._layout.vars.maxRoot:show()
		self._layout.anis.c_dakai.play()
		self._layout.vars.consume:hide()
	else
		self._layout.vars.maxRoot:hide()
		self._layout.anis.c_dakai.stop()
		self._layout.vars.consume:show()
		desc2 = g_i3k_db.i3k_db_getUnlockCropNameByGround(nodeData, lvl + 1)
		desc2 = i3k_get_string(5049, lvl + 1, cropName[nodeData.groundType]).."\n"..i3k_get_string(5133, desc2)
	end
	
	condition = i3k_get_string(5125 + node:Index(), lvl)
	widgets.fromName2:setText("") -- (i3k_get_string(5054, lvl + 1))
	local needItems = self:getLevelUpNeedItems(lvl + 1)
	self:setPageIfno(condition, desc1, desc2, okStr, needItems)
	widgets.ok:onClick(self, self.groundLevelUp, nodeData)
	if lvl > 0 then
		local homeland = g_i3k_game_context:GetHomeLandData()
		local plantLevel = homeland.plantData.plantLevel
		local equipLevel = g_i3k_game_context:GetHomeLandCurEquipPlantMaster()
		local totalLvl = lvl + plantLevel + equipLevel
		local realTotalLvl = math.min(i3k_db_home_land_base.plantCfg.masterMaxLvl, totalLvl)
		local nextRealTotalLvl = math.min(i3k_db_home_land_base.plantCfg.masterMaxLvl, totalLvl + 1)
		local str = i3k_get_string(5152).."\n"
		local curCfg = i3k_db_home_land_plant_lvl[realTotalLvl]
		local nextCfg = i3k_db_home_land_plant_lvl[nextRealTotalLvl]
		local curhelpinfo={
			i3k_get_string(5358, realTotalLvl),
			i3k_get_string(5359, plantLevel),
			i3k_get_string(5360, equipLevel),
			i3k_get_string(5361, lvl),
		}	
		local curhelpinforight={
			{desc = i3k_get_string(17394), descType = 1},
			{desc = i3k_get_string(17395)},
			{desc = i3k_get_string(17396, curCfg.reduceTimePercent / 100)},
			{desc = i3k_get_string(17397, nextCfg.reduceTimePercent / 100)},
		}
		widgets.help1:onClick(self, self.showHelpPanel, {curhelpinfo = curhelpinfo, curhelpinforight = curhelpinforight})
		--widgets.help2:onClick(self, self.showHelpPanel, str2)
	end
end

function wnd_homeland_structure:setHomelandGroundPointView(node, nodeData)
	local widgets = self._widgets
	widgets.ok:setVisible(false)
	widgets.pointTips:setVisible(true)
	widgets.costTips:setVisible(false)
	widgets.help1:setVisible(false)
	widgets.help2:setVisible(false)
	local lvl = nodeData.plantData.plantLevel
	local curCfg = i3k_db_home_land_plant_lvl[lvl]
	local nextCfg = i3k_db_home_land_plant_lvl[lvl + 1]
	local okStr, desc1, desc2, condition = "", "", "", ""
	-- local equipAddition = self:getPlantEquipReduceStr()
	okStr = i3k_get_string(449)
	desc1 = g_i3k_db.i3k_db_getUnlockCropNameByPoint(nodeData, lvl)
	desc1 = i3k_get_string(5134, lvl).."\n"..i3k_get_string(5133, desc1)
	widgets.lockTips:setVisible(false)
	widgets.unlockTips:setVisible(true)
	condition = i3k_get_string(5129, lvl)
	
	local percent, num = 0,""
	if not nextCfg then
		desc2 = i3k_get_string(17457, i3k_db_home_land_base.plantCfg.masterCanUpLvl)
		widgets.levelUptips:setText(i3k_get_string(5140))
		percent = 100
		num = curCfg.lvlUpNeedExp.."/"..curCfg.lvlUpNeedExp
		self._layout.vars.maxRoot:show()
		self._layout.anis.c_dakai.play()
		self._layout.vars.consume:hide()
	else
		desc2 = g_i3k_db.i3k_db_getUnlockCropNameByPoint(nodeData, lvl + 1)
		desc2 = i3k_get_string(5134, lvl + 1).."\n"..i3k_get_string(5133, desc2)
		percent = nodeData.plantData.plantExp / nextCfg.lvlUpNeedExp * 100
		num = nodeData.plantData.plantExp.."/"..nextCfg.lvlUpNeedExp
		self._layout.vars.maxRoot:hide()
		self._layout.anis.c_dakai.stop()
		self._layout.vars.consume:show()
	end
	if lvl >= i3k_db_home_land_base.plantCfg.masterCanUpLvl then
		desc2 = i3k_get_string(17457, i3k_db_home_land_base.plantCfg.masterCanUpLvl)
	end
	
	widgets.bar:setPercent(percent)
	widgets.barNum:setText(num)
	self:setPageIfno(condition, desc1, desc2, okStr)
end

function wnd_homeland_structure:setHomelandFishView(node, nodeData)
	local widgets = self._widgets
	widgets.ok:setVisible(true)
	widgets.pointTips:setVisible(false)
	widgets.costTips:setVisible(true)
	local lvl = nodeData.poolLevel
	widgets.lockTips:setVisible(false)
	widgets.unlockTips:setVisible(true)
	widgets.help1:setVisible(true)
	widgets.help2:setVisible(false)
	local curCfg = i3k_db_home_land_pool_lvl[lvl]
	local nextCfg = i3k_db_home_land_pool_lvl[lvl + 1]
	local okStr, desc1, desc2, condition = "", "", "", ""
	--[[	if not curCfg then
	okStr = i3k_get_string(451)
	desc1 = "池塘未解锁"
	widgets.lockTips:setVisible(true)
	widgets.unlockTips:setVisible(false)
	widgets.desc3:setText("解锁池塘可以钓鱼")
else--]]
	okStr = i3k_get_string(449)
	desc1 = i3k_get_string(5135, lvl)
	widgets.lockTips:setVisible(false)
	widgets.unlockTips:setVisible(true)
	--end
	
	if not nextCfg then
		desc2 = i3k_get_string(5144, lvl)
		widgets.ok:setVisible(false)
		self._layout.vars.maxRoot:show()
		self._layout.anis.c_dakai.play()
		self._layout.vars.consume:hide()
	else
		desc2 = i3k_get_string(5135, lvl + 1)
		self._layout.vars.maxRoot:hide()
		self._layout.anis.c_dakai.stop()
		self._layout.vars.consume:show()
	end
	condition = i3k_get_string(5145, g_i3k_game_context:GetHomeLandPoolLevel())
	self:setHomeFishhelpinfo(nodeData)
	widgets.fromName2:setText("") -- (string.format("池塘等级%s级", lvl + 1))
	local needItems = self:getPoolLevelUpNeedItems(lvl + 1)
	self:setPageIfno(condition, desc1, desc2, okStr, needItems)
	widgets.ok:onClick(self, self.poolLevelUp, nodeData)
end

function wnd_homeland_structure:setHomelandFishPointView(node, nodeData)
	local widgets = self._widgets
	widgets.ok:setVisible(false)
	widgets.pointTips:setVisible(true)
	widgets.costTips:setVisible(false)
	widgets.help1:setVisible(false)
	--widgets.help2:setVisible(true)
	local lvl = math.min(i3k_db_home_land_base.fishCfg.masterCanUpLvl, nodeData.fishData.fishLevel)
	local fishEquipPoint = g_i3k_game_context:GetHomeLandCurEquipFishMaster()
	local totalLvl = lvl + nodeData.poolLevel + fishEquipPoint
	local realTotalLvl = math.min(i3k_db_home_land_base.fishCfg.masterMaxLvl, totalLvl)
	local nextRealTotalLvl = math.min(i3k_db_home_land_base.fishCfg.masterMaxLvl, totalLvl + 1)
	local curCfg = i3k_db_home_land_fish_master[lvl]
	local nextCfg = i3k_db_home_land_fish_master[lvl + 1]
	local okStr, desc1, desc2, condition = "", "", "", ""
	okStr = i3k_get_string(449)
	--desc1 = g_i3k_db.i3k_db_getUnlockFishName(realTotalLvl)
	--desc1 = i3k_get_string(5136, realTotalLvl).."\n".."必然掉落:"..desc1
	desc1 = i3k_get_string(17424, lvl)
	widgets.lockTips:setVisible(false)
	widgets.unlockTips:setVisible(true)
	condition = i3k_get_string(5130, lvl)
	
	--desc2 = g_i3k_db.i3k_db_getUnlockFishName(nextRealTotalLvl)
	--desc2 = i3k_get_string(5136, nextRealTotalLvl).."\n".."必然掉落:"..desc2
	desc2 = i3k_get_string(17424, lvl + 1)
	
	local percent, num = 0, ""
	if not nextCfg or lvl >= i3k_db_home_land_base.fishCfg.masterCanUpLvl then
		widgets.levelUptips:setText(i3k_get_string(5136, lvl))
		desc2 = i3k_get_string(17458, i3k_db_home_land_base.fishCfg.masterCanUpLvl)
		percent = 100
		num = curCfg.lvlUpNeedExp.."/"..curCfg.lvlUpNeedExp
		self._layout.vars.maxRoot:show()
		self._layout.anis.c_dakai.play()
		self._layout.vars.consume:hide()
	else
		percent = nodeData.fishData.fishExp / nextCfg.lvlUpNeedExp * 100
		num = nodeData.fishData.fishExp.."/"..nextCfg.lvlUpNeedExp
		self._layout.vars.maxRoot:hide()
		self._layout.anis.c_dakai.stop()
		self._layout.vars.consume:show()
	end
	
	widgets.bar:setPercent(percent)
	widgets.barNum:setText(num)
	self:setPageIfno(condition, desc1, desc2, okStr)
end
--鱼塘介绍信息
function wnd_homeland_structure:setHomeFishhelpinfo(nodeData)
	local widgets = self._widgets
	local lvl = math.min(i3k_db_home_land_base.fishCfg.masterCanUpLvl, nodeData.fishData.fishLevel)
	local fishEquipPoint = g_i3k_game_context:GetHomeLandCurEquipFishMaster()
	local totalLvl = lvl + nodeData.poolLevel + fishEquipPoint
	local realTotalLvl = math.min(i3k_db_home_land_base.fishCfg.masterMaxLvl, totalLvl)
	--local nextRealTotalLvl = math.min(i3k_db_home_land_base.fishCfg.masterMaxLvl, totalLvl + 1)
	local curCfg = i3k_db_home_land_fish_master[lvl]
	--desc1 = i3k_get_string(5136, realTotalLvl).."\n".."必然掉落:"..desc1
	local curhelpinfo={
		i3k_get_string(5362, lvl + nodeData.poolLevel + fishEquipPoint),
		i3k_get_string(5363, lvl),
		i3k_get_string(5364, fishEquipPoint),
		i3k_get_string(5365, nodeData.poolLevel),
	}
	local curhelpinforight={
		{desc = i3k_get_string(17398), descType = 1},
		{desc = i3k_get_string(17399)},
		{desc = i3k_get_string(17400), descType = 1},
		{desc = g_i3k_db.i3k_db_getUnlockFishName(realTotalLvl) },
		{desc = i3k_get_string(17401), descType = 1},
		{desc = i3k_get_string(17402)},
		{desc = i3k_get_string(17403)},
	}
	widgets.help1:onClick(self, self.showHelpPanel, {curhelpinfo = curhelpinfo, curhelpinforight = curhelpinforight})
end

function wnd_homeland_structure:setHomelandHouseView(node)
	local level = g_i3k_game_context:GetHomeLandHouseLevel()
	local curHouse = i3k_db_home_land_house[level]
	local nextHouse = i3k_db_home_land_house[level + 1]
	local widgets = self._layout.vars
	widgets.ok:setVisible(true)
	widgets.lockTips:setVisible(false)
	widgets.pointTips:setVisible(false)
	widgets.unlockTips:setVisible(true)
	widgets.costTips:setVisible(true)
	widgets.help1:setVisible(false)
	widgets.help2:setVisible(false)
	local okStr, desc1, desc2, condition = "", "", "", ""
	if not curHouse then
		okStr = i3k_get_string(451)
		desc1 = i3k_get_string(5141)
		widgets.lockTips:setVisible(true)
		widgets.unlockTips:setVisible(false)
		widgets.desc3:setText("解锁房屋可以摆放家俱")
	else
		okStr = i3k_get_string(449)
		desc1 = i3k_get_string(17413, curHouse.needBuildValue, curHouse.furnitureMaxLvl)
		widgets.lockTips:setVisible(false)
		widgets.unlockTips:setVisible(true)
	end
	local needItems = {}
	if not nextHouse then
		desc2 = i3k_get_string(17426, level)
		widgets.ok:setVisible(false)
		self._layout.vars.maxRoot:show()
		self._layout.anis.c_dakai.play()
		self._layout.vars.consume:hide()
	else
		self._layout.vars.maxRoot:hide()
		self._layout.anis.c_dakai.stop()
		self._layout.vars.consume:show()
		for _, v in ipairs(nextHouse.needItems) do
			needItems[v.itemID] = {id = v.itemID, count = v.itemCount}
		end
		desc2 = i3k_get_string(17413, nextHouse.needBuildValue, nextHouse.furnitureMaxLvl)
	end
	condition = string.format("房屋等级：%s", level)
	widgets.fromName2:setText("")
	self:setPageIfno(condition, desc1, desc2, okStr, needItems)
	widgets.ok:onClick(self, self.onHouseUpLevel, {needItems = needItems, level = level})
	widgets.help1:show()
	widgets.help1:onClick(self, self.onHouseHelpBtn)
end

-- 设置界面的公共方法
function wnd_homeland_structure:setPageIfno(condition, desc1, desc2, okStr, needItems)
	local widgets = self._widgets
	widgets.condition:setText(condition)
	widgets.desc1:setText(desc1)
	widgets.desc2:setText(desc2)
	widgets.textOk:setText(okStr)
	if needItems then
		self._bagItems = g_i3k_ui_mgr:refreshScrollItems(widgets.scroll2, needItems, "ui/widgets/zbqht2", g_ITEM_NUM_SHOW_TYPE_COMPARE)
	end
end

-- 家园升级
function wnd_homeland_structure:homelandLevelUp(sender, homeland)
	local level = homeland.level
	if not i3k_db_home_land_lvl[level + 1] then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5081, level))
		return
	end
	local needItems = self:getHomelandLevelUpNeedItems(level + 1)
	if g_i3k_game_context:checkNeedCommonItems(needItems, true) then  -- 所需物品数量判断
		i3k_sbean.homeland_uplevel(level + 1, needItems, homeland)
	end
end

function wnd_homeland_structure:onHomelandLevelUp(req)
	local curNode = self._dropDownList:CurNode()
	local nodeData = curNode:Data()
	if nodeData == req.nodeData then -- 也可以用其他方式验证
		nodeData.level = req.nodeData.level -- 更新节点数据
		self:setHomelandMainView(curNode, nodeData)
		curNode:setTitleDesc(i3k_get_string(5151, req.nodeData.level))
		-- curNode:setTitleDesc("Lv"..nodeData.level, true) -- 更新标签表现
	end
end

-- 土地升级
function wnd_homeland_structure:groundLevelUp(sender, ground)
	if ground then
		local homelandCfg = i3k_db_home_land_lvl[g_i3k_game_context:GetHomeLandLevel()]
		if not homelandCfg or ground.level >= homelandCfg.landLvlLimit then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5055, homelandCfg.landLvlLimit))
			return
		end
		
		local needItems = self:getLevelUpNeedItems(ground.level + 1)
		if g_i3k_game_context:checkNeedCommonItems(needItems, true) then  -- 所需物品数量判断
			i3k_sbean.homeland_ground_uplevel(ground.groundType, ground.groundIndex, ground.level + 1, needItems, ground)
		end
	end
end

function wnd_homeland_structure:onGroundLevelUp(req)
	local curNode = self._dropDownList:CurNode()
	local nodeData = curNode:Data()
	if nodeData == req.nodeData then -- 也可以用其他方式验证
		nodeData.level = req.nodeData.level -- 更新节点数据
		self:setHomelandGroundView(curNode, nodeData)
		curNode:setTitleDesc(self:getGroundLvlTagStr(nodeData), true) -- 更新标签表现
	end
end

function wnd_homeland_structure:getGroundLvlTagStr(nodeData)
	if nodeData.level <= 0 then
		return "未开垦"
	else
		return i3k_get_string(5151, nodeData.level)
	end
end

-- 池塘升级
function wnd_homeland_structure:poolLevelUp(sender, homeland)
	local level = homeland.poolLevel
	if not i3k_db_home_land_pool_lvl[level + 1] then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5144, level))
		return
	end
	if i3k_db_home_land_lvl[homeland.level].poolLvlLimit <= level then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5338, level))
		return
	end
	local needItems = self:getPoolLevelUpNeedItems(level + 1)
	if g_i3k_game_context:checkNeedCommonItems(needItems, true) then  -- 所需物品数量判断
		i3k_sbean.homeland_pool_uplevel(level + 1, needItems, homeland)
	end
end

function wnd_homeland_structure:onPoolLevelUp(req)
	local curNode = self._dropDownList:CurNode()
	local nodeData = curNode:Data()
	if nodeData == req.nodeData then -- 也可以用其他方式验证
		nodeData.poolLevel = req.nodeData.poolLevel -- 更新节点数据
		self:setHomelandFishView(curNode, nodeData)
		curNode:setTitleDesc(i3k_get_string(5151, nodeData.poolLevel), true) -- 更新标签表现
	end
end

function wnd_homeland_structure:getIconPathByType(curType)
	local resID = Icon_Res_ID[curType]
	if resID then
		return g_i3k_db.i3k_db_get_icon_path(resID)
	end
end

function wnd_homeland_structure:getHomelandLevelUpNeedItems(targetLevel)
	local cfg = i3k_db_home_land_lvl[targetLevel]
	return i3k_db.i3k_db_cfgItemsToHashItems_safe(cfg)
end

function wnd_homeland_structure:getLevelUpNeedItems(targetLevel)
	local cfg = i3k_db_home_land_land_lvl[targetLevel]
	return i3k_db.i3k_db_cfgItemsToHashItems_safe(cfg)
end

function wnd_homeland_structure:getPoolLevelUpNeedItems(targetLevel)
	local cfg = i3k_db_home_land_pool_lvl[targetLevel]
	return i3k_db.i3k_db_cfgItemsToHashItems_safe(cfg)
end

function wnd_homeland_structure:onHomeLandMain(sender)
	i3k_sbean.homeland_sync(true)
end

function wnd_homeland_structure:onHomeLandEquip(sender)
	g_i3k_logic:OpenHomeLandEquipUI()
end

function wnd_homeland_structure:onHomeLandHistorys(sender)
	g_i3k_logic:OpenHomeLandEventUI(eUIID_HomeLandStructure)
end

function wnd_homeland_structure:getPlantEquipReduceStr()
	local flag, v, cfg = g_i3k_game_context:GetHomeLandCurEquipCanPlant()
	local str = ""
	if flag then
		local lvl = cfg.propTb[1].propValue
		if lvl then
			local cfg = i3k_db_home_land_plant_lvl[lvl]
			str = str.."+"..(cfg.reduceTimePercent / 100).."% ".."(装备精通加成)"
		end
	end
	return str
end

function wnd_homeland_structure:getLvlOverStr(lvl)
	local str = ""
	if lvl >= i3k_db_home_land_base.fishCfg.masterMaxLvl then
		str = string.format("(最大等级为%s)", i3k_db_home_land_base.fishCfg.masterMaxLvl)
	end
	return str
end

function wnd_homeland_structure:showHelpPanel(sender,info)
	g_i3k_ui_mgr:OpenUI(eUIID_HouseBuildinfo);
	g_i3k_ui_mgr:RefreshUI(eUIID_HouseBuildinfo, info.curhelpinfo, info.curhelpinforight);
end

function wnd_homeland_structure:onHouseUpLevel(sender, info)
	local level = info.level
	if not i3k_db_home_land_house[level + 1] then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5081, level))
		return
	end
	local homeland = g_i3k_game_context:GetHomeLandData()
	if i3k_db_home_land_lvl[homeland.level].houseLvlLimit <= g_i3k_game_context:GetHomeLandHouseLevel() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5339, i3k_db_home_land_lvl[homeland.level].houseLvlLimit))
	elseif not g_i3k_game_context:checkNeedCommonItems(info.needItems, true) then  -- 所需物品数量判断
	elseif homeland.buildValue < i3k_db_home_land_house[level + 1].needBuildValue then
		g_i3k_ui_mgr:PopupTipMessage(string.format("需要当前建筑值达到%s", i3k_db_home_land_house[level + 1].needBuildValue))
	else
		i3k_sbean.homeland_house_uplevel(level + 1, info.needItems)
	end
end

function wnd_homeland_structure:updateHouseUpLevel(level)
	local curNode = self._dropDownList:CurNode()
	self:setHomelandHouseView(curNode)
	curNode:setTitleDesc(i3k_get_string(5151, level))
end

function wnd_homeland_structure:jumpToHouse()
	self._dropDownList:clickItemByGroup(type_homeland_house)
end

function wnd_homeland_structure:onHouseHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(17415))
end

function wnd_create(layout,...)
	local wnd = wnd_homeland_structure.new()
	wnd:create(layout,...)
	return wnd
end
