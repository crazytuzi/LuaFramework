
-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_homeLandMain = i3k_class("wnd_homeLandMain",ui.wnd_base)

local JIAYUANT_NODE = "ui/widgets/jiayuant"
local JIAYUAN_DESC = "ui/widgets/jiayuant2"
-- 计时变量
local TimeCounter = 0

function wnd_homeLandMain:ctor()
	self._corp = {}
end

function wnd_homeLandMain:configure()
	local widgets = self._layout.vars
	
	self.enterHomeLand = widgets.enterHomeLand
	widgets.enterHomeLand:onClick(self, self.onEnterHomeLand)
	self.scroll = widgets.scroll
	widgets.homeLandProp:stateToPressed()
	widgets.homeLandBuild:onClick(self, self.onHomeLandBulid)
	widgets.homeLandEquip:onClick(self, self.onHomeLandEquip)
	widgets.homeLandHistorys:onClick(self, self.onHomeLandHistorys)
	--widgets.changeNameBtn:onClick(self, self.onChangeName)
	widgets.close:onClick(self, self.onCloseUI)
end

function wnd_homeLandMain:refresh(homeLandInfo)
	self:loadData(homeLandInfo)
end

function wnd_homeLandMain:loadData(homeLandInfo)
	--[[local widgets = self._layout.vars
	widgets.name:setText(homeLandInfo.name)
	widgets.homeID:setText(g_i3k_game_context:GetRoleId()) --家园ID是自己的roleID
	-- widgets.bulidValue:setText(homeLandInfo.bulidValue) --建设度
	-- widgets.houseLvl:setText("0") -- 房屋等级
	widgets.stealTimes:setText(g_i3k_game_context:GetHomelandStealTimes(homeLandInfo)) -- 偷菜次数
	widgets.homeLandLvl:setText(homeLandInfo.level)
	widgets.popular:setText(homeLandInfo.heat) 
	widgets.plantLvl:setText(homeLandInfo.plantData.plantLevel)--]]
	self:laodCropScroll(homeLandInfo)
	self:loadDescScroll(homeLandInfo)
	self.enterHomeLand:setVisible(not g_i3k_game_context:GetIsInHomeLandZone())
end

function wnd_homeLandMain:updateHomeLandName(name)
	local children = self._layout.vars.desc_scroll:getAllChildren()
	children[1].vars.desc:setText(name)
	--[[local widgets = self._layout.vars
	widgets.name:setText(name)--]]
end

-- 右侧作物列表
function wnd_homeLandMain:laodCropScroll(homeLandInfo)
	self.scroll:removeAllChildren()
	local crops = self:getCropsInfo(homeLandInfo.grounds)
	self._crops = crops
	if next(crops) then
		self._layout.vars.none_plant:hide()
		for _, e in ipairs(crops) do
			local node = require(JIAYUANT_NODE)()
			local plantCfg = i3k_db_home_land_corp[e.id]
			local percent, time = self:getMatureRateLeftTime(e, plantCfg)
			node.vars.name:setText(plantCfg.corpName)
			node.vars.leftTime:setText(time > 0 and i3k_get_time_show_text(time) or "成熟啦")
			node.vars.rateBar:setPercent(percent)
			self.scroll:addItem(node)
		end
	else
		self._layout.vars.none_plant:show()
	end
end

function wnd_homeLandMain:loadDescScroll(homeLandInfo)
	local descInfo =
	{
		{name = "家园名称：", desc = homeLandInfo.name, color = "ffed6114", showBtn = true},
		{name = "家园ID：", desc = g_i3k_game_context:GetRoleId(), color = "ffed6114", showBtn = false},
		{name = "家园等级：", desc = homeLandInfo.level, color = "ff7a64b7", showBtn = false},
		{name = "房屋等级：", desc = homeLandInfo.houseData.houseLevel, color = "ff7a64b7", showBtn = false},
		{name = "种植精通等级：", desc = homeLandInfo.plantData.plantLevel, color = "ff7a64b7", showBtn = false},
		{name = "建筑值：", desc = homeLandInfo.buildValue, color = "ff388777", showBtn = false},
		{name = "家园人气：", desc = homeLandInfo.heat, color = "ff388777", showBtn = false},
		{name = "偷菜次数：", desc = g_i3k_game_context:GetHomelandStealTimes(homeLandInfo), color = "ff388777", showBtn = false},
	}
	self._layout.vars.desc_scroll:removeAllChildren()
	for _, v in ipairs(descInfo) do
		local node = require(JIAYUAN_DESC)()
		node.vars.name:setText(v.name)
		node.vars.desc:setText(v.desc)
		node.vars.name:setTextColor(v.color)
		node.vars.desc:setTextColor(v.color)
		node.vars.changeNameBtn:setVisible(v.showBtn)
		if v.showBtn then
			node.vars.changeNameBtn:onClick(self, self.onChangeName)
		end
		self._layout.vars.desc_scroll:addItem(node)
	end
end

-- 获取作物成长百分比，剩余时间
function wnd_homeLandMain:getMatureRateLeftTime(plant, plantCfg)
	local nowTime = i3k_game_get_time()
	local _, seedInfo, strongInfo = g_i3k_db.i3k_db_getCurPlantStep(plant, plantCfg)
	local totalTime = seedInfo.realGrowTime + strongInfo.realGrowTime
	local percent = (nowTime - plant.plantTime) / totalTime * 100
	local leftTime = totalTime +  plant.plantTime - nowTime
	percent = percent <= 100 and percent or 100
	leftTime = leftTime > 0 and leftTime or 0
	return percent, leftTime
end

function wnd_homeLandMain:getCropsInfo(grounpsInfo)
	local crops = {}
	for _, v in pairs(grounpsInfo) do
		table.insert(crops, v.curPlant)
	end
	table.sort(crops, function (a, b)
		return a.plantTime < b.plantTime
	end)
	return crops
end

--进入家园
function wnd_homeLandMain:onEnterHomeLand(sender)
	local func = function ()
		g_i3k_game_context:gotoPlayerHomeLand(g_i3k_game_context:GetRoleId())
	end
	g_i3k_game_context:CheckMulHorse(func)
end

function wnd_homeLandMain:onUpdate(dTime)
	TimeCounter = TimeCounter + dTime
	if TimeCounter > 1 then -- 每秒更新
		for i, node in ipairs(self.scroll:getAllChildren()) do
			local plant = self._crops[i]
			local plantCfg = i3k_db_home_land_corp[plant.id]
			local percent, time = self:getMatureRateLeftTime(plant, plantCfg)
			if time > 0 then
				node.vars.leftTime:setText(time > 0 and i3k_get_time_show_text(time) or "成熟啦")
				node.vars.rateBar:setPercent(percent)
			end
		end
		TimeCounter = 0
	end
end

function wnd_homeLandMain:onHomeLandBulid(sender)
	g_i3k_logic:openHomelandStructureUI(nil, eUIID_HomeLandMain)
end

function wnd_homeLandMain:onHomeLandEquip(sender)
	g_i3k_logic:OpenHomeLandEquipUI()
end

function wnd_homeLandMain:onHomeLandHistorys(sender)
	g_i3k_logic:OpenHomeLandEventUI(eUIID_HomeLandMain)
end

--家园改名
function wnd_homeLandMain:onChangeName(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_HomeLandChangeName)
	g_i3k_ui_mgr:RefreshUI(eUIID_HomeLandChangeName)
end

function wnd_create(layout)
	local wnd = wnd_homeLandMain.new()
	wnd:create(layout)
	return wnd
end
