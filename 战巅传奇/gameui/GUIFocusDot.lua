----------------------------红点配置表----------------------------
----小红点功能

local GUIDE_TYPE = {
	DOT = 1, -- 红点
	HALO = 2, -- 右上角光圈类型
	BUTTON = 3, -- 按钮光晕
}


local redTable = {
	---------------------------首充-----------------------------------
	[1011]={
		[1]={root = "m_rtPartUI", node = {"extend_firstPay"}, guideType = GUIDE_TYPE.HALO},
	},
	[1012]={
		[1]={root = "m_rtPartUI", node = {"extend_firstPay"}, guideType = GUIDE_TYPE.HALO},
		--[2]={root = "GDivContainer", panel = "extend_firstPay", node = {"btn_recharge_receive"}, blnRes = "btn_normal_light9"},
	},
	--赞助大使
	[1013]={
		[1]={root = "m_rtPartUI", node = {"extend_rechargeGift"}, guideType = GUIDE_TYPE.HALO},
	},
	---------------------------经验炼制-----------------------------------
	[1021]={
		[1]={root = "m_rtPartUI", node = {"extend_makeExp"}, guideType = GUIDE_TYPE.HALO},
		[2]={root = "GDivContainer", panel = "extend_makeExp", node = {"btnGet"}, blnRes = "btn_normal_light13"},
	},
	---------------------------签到-----------------------------------
	[1031]={
		[1]={root = "m_rtPartUI", node = {"extend_awardHall"}, guideType = GUIDE_TYPE.HALO},
		[2]={root = "GDivContainer", panel = "extend_awardHall", node = {"btn_tab_sign"}, guideType = GUIDE_TYPE.DOT},
	},
	---------------------------在线-----------------------------------
	[1032]={
		[1]={root = "m_rtPartUI", node = {"extend_awardHall"}, guideType = GUIDE_TYPE.HALO},
		[2]={root = "GDivContainer", panel = "extend_awardHall", node = {"btn_tab_online"}, guideType = GUIDE_TYPE.DOT},
	},
	---------------------------15日-----------------------------------
	[1033]={
		[1]={root = "m_rtPartUI", node = {"extend_awardHall"}, guideType = GUIDE_TYPE.HALO},
		[2]={root = "GDivContainer", panel = "extend_awardHall", node = {"btn_tab_fifteen"}, guideType = GUIDE_TYPE.DOT},
	},
	---------------------------开服特惠-----------------------------------
	[1061]={
		[1]={root = "m_rtPartUI", node = {"extend_openServer"}, guideType = GUIDE_TYPE.HALO},
		[2]={root = "GDivContainer", panel = "extend_openServer", node = {"btn_tab_sale"}, guideType = GUIDE_TYPE.DOT},
	},
	---------------------------全民boss-----------------------------------
	[1062]={
		[1]={root = "m_rtPartUI", node = {"extend_openServer"}, guideType = GUIDE_TYPE.HALO},
		[2]={root = "GDivContainer", panel = "extend_openServer", node = {"btn_tab_boss"}, guideType = GUIDE_TYPE.DOT},
	},
	---------------------------世界活动-----------------------------------
	[1081]={
		[1]={root = "m_rtPartUI", node = {"extend_world"}, guideType = GUIDE_TYPE.HALO},
	},
	---------------------------护卫-----------------------------------
	[1091]={
		[1]={root = "m_rtPartUI", node = {"extend_mars"}, guideType = GUIDE_TYPE.HALO},
	},
	---------------------------功勋-----------------------------------
	[1101]={
		[1]={root = "m_rtPartUI", node = {"extend_exploit"}, guideType = GUIDE_TYPE.HALO},
	},
	---------------------------闯天关-----------------------------------
	[1111]={
		[1]={root = "m_rtPartUI", node = {"extend_breakup"}, guideType = GUIDE_TYPE.HALO},
	},
	---------------------------等级竞技-----------------------------------
	[1112]={
		[1]={root = "m_rtPartUI", node = {"extend_openServer"}, guideType = GUIDE_TYPE.HALO},
		[2]={root = "GDivContainer", panel = "extend_openServer", node = {"btn_tab_level"}, guideType = GUIDE_TYPE.DOT},
	},
	---------------------------神翼竞技-----------------------------------
	[1113]={
		[1]={root = "m_rtPartUI", node = {"extend_openServer"}, guideType = GUIDE_TYPE.HALO},
		[2]={root = "GDivContainer", panel = "extend_openServer", node = {"btn_tab_wing"}, guideType = GUIDE_TYPE.DOT},
	},
	---------------------------龙心竞技-----------------------------------
	[1114]={
		[1]={root = "m_rtPartUI", node = {"extend_openServer"}, guideType = GUIDE_TYPE.HALO},
		[2]={root = "GDivContainer", panel = "extend_openServer", node = {"btn_tab_lx"}, guideType = GUIDE_TYPE.DOT},
	},
	---------------------------狼牙竞技-----------------------------------
	[1115]={
		[1]={root = "m_rtPartUI", node = {"extend_openServer"}, guideType = GUIDE_TYPE.HALO},
		[2]={root = "GDivContainer", panel = "extend_openServer", node = {"btn_tab_ly"}, guideType = GUIDE_TYPE.DOT},
	},
	---------------------------登录有礼-----------------------------------
	[1116]={
		[1]={root = "m_rtPartUI", node = {"extend_activities"}, guideType = GUIDE_TYPE.HALO},
		[2]={root = "GDivContainer", panel = "extend_activities", node = {"tabName3"}, guideType = GUIDE_TYPE.DOT},
	},
	---------------------------充值有礼-----------------------------------
	[1117]={
		[1]={root = "m_rtPartUI", node = {"extend_activities"}, guideType = GUIDE_TYPE.HALO},
		[2]={root = "GDivContainer", panel = "extend_activities", node = {"tabName2"}, guideType = GUIDE_TYPE.DOT},
	},
	---------------------------开服活动-累计充值-----------------------------------
	[1118]={
		[1]={root = "m_rtPartUI", node = {"extend_openServer"}, guideType = GUIDE_TYPE.HALO},
	},
	---------------------------开服活动-连续充值-----------------------------------
	[1119]={
		[1]={root = "m_rtPartUI", node = {"extend_openServer"}, guideType = GUIDE_TYPE.HALO},
	},
	---------------------------开服活动-七天狂欢-----------------------------------
	[1120]={
		[1]={root = "m_rtPartUI", node = {"extend_openServer"}, guideType = GUIDE_TYPE.HALO},
	},

	-------------------------精彩活动-----------------------------------
	[1121]={
		[1]={root = "m_rtPartUI", node = {"extend_events"}, guideType = GUIDE_TYPE.HALO},
	},
	-------------------------投资计划-----------------------------------
	[1131]={
		[1]={root = "m_rtPartUI", node = {"extend_invest"}, guideType = GUIDE_TYPE.HALO},
	},
	-------------------------摇摇乐-----------------------------------
	[1141]={
		[1]={root = "m_rtPartUI", node = {"extend_dice"}, guideType = GUIDE_TYPE.HALO},
	},
	---------------------------官位-----------------------------------
	[2011]={
		[1]={root = "m_cbPartUI", node = {"btnEquip","btn_main_official"}, guideType = GUIDE_TYPE.DOT},
		[2]={root = "GDivContainer", panel = "main_official", node = {"btn_tab_post"}, guideType = GUIDE_TYPE.DOT},
	},
	---------------------------官印-----------------------------------
	[2012]={
		[1]={root = "m_cbPartUI", node = {"btnEquip","btn_main_official"}, guideType = GUIDE_TYPE.DOT},
		[2]={root = "GDivContainer", panel = "main_official", node = {"btn_tab_chop"}, guideType = GUIDE_TYPE.DOT},
	},
	---------------------------内功---------------------------
	[2021]={
		--暂时不显示内功红色按钮
		--[1]={root = "m_cbPartUI", node = {"btnRole"}, guideType = GUIDE_TYPE.DOT},
		--[2]={root = "GDivContainer", panel = "main_avatar", node = {"tab3"},guideType = GUIDE_TYPE.DOT},
	},
	--技能
	[2022]={
		--暂时不显示技能红色按钮
		--[1]={root = "m_cbPartUI", node = {"btnRole"}, guideType = GUIDE_TYPE.DOT},
		--[2]={root = "GDivContainer", panel = "main_avatar", node = {"tab1"},guideType = GUIDE_TYPE.DOT},
	},
		--转生
	[2023]={
		--暂时不显示转生红色按钮
		--[1]={root = "m_cbPartUI", node = {"btnRole"}, guideType = GUIDE_TYPE.DOT},
		--[2]={root = "GDivContainer", panel = "main_avatar", node = {"tab5"},guideType = GUIDE_TYPE.DOT},
	},

	--神炉四部件
	[2031]={
		[1]={root = "m_cbPartUI", node = {"btn_furnace"}, guideType = GUIDE_TYPE.DOT},
		[2]={root = "GDivContainer", panel = "main_furnace", node = {"tab1"},guideType = GUIDE_TYPE.DOT},
	},
	[2032]={
		[1]={root = "m_cbPartUI", node = {"btn_furnace"}, guideType = GUIDE_TYPE.DOT},
		[2]={root = "GDivContainer", panel = "main_furnace", node = {"tab2"},guideType = GUIDE_TYPE.DOT},
	},
	[2033]={
		[1]={root = "m_cbPartUI", node = {"btn_furnace"}, guideType = GUIDE_TYPE.DOT},
		[2]={root = "GDivContainer", panel = "main_furnace", node = {"tab3"},guideType = GUIDE_TYPE.DOT},
	},
	[2034]={
		[1]={root = "m_cbPartUI", node = {"btn_furnace"}, guideType = GUIDE_TYPE.DOT},
		[2]={root = "GDivContainer", panel = "main_furnace", node = {"tab4"},guideType = GUIDE_TYPE.DOT},
	},
	--勋章
	[2035]={
		[1]={root = "m_cbPartUI", node = {"btnAchieve"}, guideType = GUIDE_TYPE.DOT},
		[2]={root = "GDivContainer", panel = "main_achieve", node = {"tab2"},guideType = GUIDE_TYPE.DOT},
	},
	--成就
	[2036]={
		[1]={root = "m_cbPartUI", node = {"btnAchieve"}, guideType = GUIDE_TYPE.DOT},
		[2]={root = "GDivContainer", panel = "main_achieve", node = {"tab1"},guideType = GUIDE_TYPE.DOT},
	},

	[2051]={
		[1]={root = "m_cbPartUI", node = {"btnOther","btn_main_mail"}, guideType = GUIDE_TYPE.DOT},
	},
	---寄售
	[2062]={
		[1]={root = "m_cbPartUI", node = {"btnOther","btn_main_consign"}, guideType = GUIDE_TYPE.DOT},
		[2]={root = "GDivContainer", panel = "main_consign", node = {"tab2"},guideType = GUIDE_TYPE.DOT},
	},
	---背包
	--[2071]={
	--	[1]={root = "m_cbPartUI", node = {"btnBag"}, guideType = GUIDE_TYPE.DOT},
	--},
	---每日充值
	[2081]={
		[1]={root = "m_rtPartUI", node = {"extend_dailyPay"}, guideType = GUIDE_TYPE.HALO},
	},
	---合区活动
	[2082]={
		[1]={root = "m_rtPartUI", node = {"extend_heFu"}, guideType = GUIDE_TYPE.HALO},
	},
	--下载有礼
	[2084]={
		[1]={root = "m_rtPartUI", node = {"extend_download"}, guideType = GUIDE_TYPE.HALO},
	},
	---帮会红包
	[2091] = {
		[1]={root = "m_cbPartUI", node = {"btnOther","btn_main_guild"}, guideType = GUIDE_TYPE.DOT},	
	},
	--vip
	[3011]={
		[1]={root = "m_ltPartUI", node = {"btn_vip",}, guideType = GUIDE_TYPE.DOT},
		-- [2]={root = "GDivContainer", panel = "panel_vip", node = {"tab2"},guideType = GUIDE_TYPE.DOT},
	},
	--炼魂
	[3012]={
		[1]={root = "m_cbPartUI", node = {"btnBoss"}, guideType = GUIDE_TYPE.DOT},
		[2]={root = "GDivContainer", panel = "main_puzzle", node = {"tab2"},guideType = GUIDE_TYPE.DOT},
	},
	--拼图
	[3013]={
		[1]={root = "m_cbPartUI", node = {"btnBoss"}, guideType = GUIDE_TYPE.DOT},
		[2]={root = "GDivContainer", panel = "main_puzzle", node = {"tab1"},guideType = GUIDE_TYPE.DOT},
	},
	--v9
	--翅膀
	[4000]={
		[1]={root = "m_rcPartUI", node = {"menu_container_btn_wing"}, guideType = GUIDE_TYPE.DOT},
	},
	--天罡
	[4001]={
		[1]={root = "m_rcPartUI", node = {"extend_dice"}, guideType = GUIDE_TYPE.DOT},
	},
	--功勋
	[4002]={
		[1]={root = "m_rcPartUI", node = {"extend_exploit"}, guideType = GUIDE_TYPE.DOT},
	},
	--佛经
	[4003]={
		[1]={root = "m_rcPartUI", node = {"menu_container_btn_fojing"}, guideType = GUIDE_TYPE.DOT},
	},
	--剑鞘
	[4004]={
		[1]={root = "m_rcPartUI", node = {"menu_container_btn_jianqiao"}, guideType = GUIDE_TYPE.DOT},
	},
	--神器
	[4005]={
		[1]={root = "m_rcPartUI", node = {"extend_shenqi"}, guideType = GUIDE_TYPE.DOT},
		[2]={root = "m_rcPartUI", node = {"extend_moqi"}, guideType = GUIDE_TYPE.DOT},
		[3]={root = "m_rcPartUI", node = {"extend_guiqi"}, guideType = GUIDE_TYPE.DOT},
	},
	--切换按钮
	[4999]={
		[1]={root = "m_rcPartUI", node = {"btn_container_switch"}, guideType = GUIDE_TYPE.DOT},
	}
}


local GUIFocusDot = {}
local var = {}

function GUIFocusDot.init(scene)
	var = {
		panelDict = {},
		redPanels = {},
		panelRedParams = {},
		subMenuRedParams = {},
		menuDict = {},

		redDotGuides = {}, -- 用于避免频繁添加或者移除红点
	}

	cc.EventProxy.new(GameSocket, scene)
		:addEventListener(GameMessageCode.EVENT_UPDATE_PANELDICT, GUIFocusDot.handlePanelDictUpdate)
		:addEventListener(GameMessageCode.EVENT_UPDATE_MENUDICT, GUIFocusDot.handleMenuDictUpdate)
		:addEventListener(GameMessageCode.EVENT_SHOW_REDPOINT, GUIFocusDot.handleRedPointStart)
		:addEventListener(GameMessageCode.EVENT_REMOVE_REDPOINT, GUIFocusDot.hanldeRemoveRedPoint)
end

function GUIFocusDot.handlePanelDictUpdate(event)
	if event and event.panels then
		var.panelDict = (table.nums(event.panels) > 0 and event.panels) or {}
		if event.pName and var.panelRedParams[event.pName] and #var.panelRedParams[event.pName] > 0 then
			for _,v in ipairs(var.panelRedParams[event.pName]) do
				GUIFocusDot.showRedPoint(v)
			end
		end
	end
end

function GUIFocusDot.handleMenuDictUpdate(event)
	if event and event.menus then
		var.menuDict = (table.nums(event.menus) > 0 and event.menus) or {}
		if event.mName and var.subMenuRedParams[event.mName] and #var.subMenuRedParams[event.mName] > 0 then
			for _,v in ipairs(var.subMenuRedParams[event.mName]) do
				GUIFocusDot.showRedPoint(v)
			end
		end
	end
end

------------------------------------------------------红点引导相关代码------------------------------------------------------
-- target.redParams 记录按钮关联的下级红点控件信息
-- var.redPanels 待添加红点控件所在面板的缓存容器

function GUIFocusDot.recordRedParam(event)
	if not event.lv or not redTable[event.lv] then return end
	for i,param in ipairs(redTable[event.lv]) do
		-- print(GameUtilSenior.encode(param))
		if param.root == "GDivContainer" then

			var.panelRedParams[param.panel] = var.panelRedParams[param.panel] or {}

			GUIFocusDot.recordPanelRedParam(param.panel, {lv = event.lv, index = i})

		elseif param.root == "mSubMenu" then
			var.subMenuRedParams[param.menu] = var.subMenuRedParams[param.menu] or {}

			GUIFocusDot.recordMenuRedParam(param.menu, {lv = event.lv, index = i})
		end
	end
end

function GUIFocusDot.recordPanelRedParam(pName, redParam)
	local contain = false

	for i,v in ipairs(var.panelRedParams[pName]) do
		if v.lv == redParam.lv and v.index == redParam.index then
			contain = true
		end
	end

	if not contain then table.insert(var.panelRedParams[pName], redParam) end
end

function GUIFocusDot.recordMenuRedParam(pName, redParam)
	local contain = false

	for i,v in ipairs(var.subMenuRedParams[pName]) do
		if v.lv == redParam.lv and v.index == redParam.index then
			contain = true
		end
	end

	if not contain then table.insert(var.subMenuRedParams[pName], redParam) end
end

function GUIFocusDot.handleRedPointStart(event)
	-- print("/////////////////handleRedPointStart//////////////////////", event.lv)
	if event.lv and redTable[event.lv] then
		if table.indexof(var.redDotGuides, event.lv) then return end
		for i,v in ipairs(redTable[event.lv]) do
			GUIFocusDot.handleRedPoint({lv = event.lv, index = i})
		end
		table.insert(var.redDotGuides, event.lv)
	end
end


function GUIFocusDot.handleRedPoint(event)
	-- print("/////////////////handleRedPoint//////////////////////", event.lv)
	if not event.lv then return end
	event.index = event.index or 1

	local param 
	if redTable[event.lv] and redTable[event.lv][event.index] then
		param = redTable[event.lv][event.index]
	end
	if not param then return end
	if param.root == "GDivContainer" then
		if var.panelDict[param.panel] then --面板已经存在，直接引导
			GUIFocusDot.showRedPoint(event)
		end
		GUIFocusDot.recordRedParam(event)
	elseif param.root == "mSubMenu" then
		if var.menuDict[param.menu] then --面板已经存在，直接引导
			GUIFocusDot.showRedPoint(event)
		end
		GUIFocusDot.recordRedParam(event)
	else
		GUIFocusDot.showRedPoint(event)
	end
end

function GUIFocusDot.showRedPoint(event)
	-- print("/////////////////showRedPoint/////////////////", event.lv)
	local param = redTable[event.lv][event.index]
	if param.node then
		for i,v in ipairs(param.node) do
			local newParam = {root = param.root, panel = param.panel, node = v}
			local target = GUIMain.getGuideWidget(newParam, "showRedPoint") --取引导控件pos
			--print("/////////////////showRedPoint/////////////////", target,event.lv)
			if target then
				if param.guideType and param.guideType == GUIDE_TYPE.DOT then
					--print("--aa",param.root)
					GUIFocusDot.addRedPointToTarget(target)
				end

				if param.blnRes then
					GameUtilSenior.addHaloToButton(target, param.blnRes)
				end

				local redParam = {lv = event.lv, index = event.index }
				if not target.redParams then target.redParams = {} end
				GUIFocusDot.addRedParamToWidget(target, redParam)
				if target:getName() == "btn_control_func" and target.showProps then
					if target:getChildByName("redPoint") then
						target:getChildByName("redPoint"):hide()
					end
				end

				if target:getName() == "btn_main_mail" then
					local imgMailFull = target:getChildByName("img_mail_full")
					if imgMailFull and imgMailFull:isVisible() then
						if target:getChildByName("redPoint") then
							target:getChildByName("redPoint"):hide()
						end
					end
				end
				if target:getName() == "btn_main_bag" then
					local imgMailFull = target:getChildByName("img_bag_full")
					if imgMailFull and imgMailFull:isVisible() then
						if target:getChildByName("redPoint") then
							target:getChildByName("redPoint"):hide()
						end
					end
				end
			end
		end
		-- if event.lv==48 then
		-- 	GUILeftCenter.checkRedPointShow()
		-- end
	end
end

-- 记入红点数据
function GUIFocusDot.addRedParamToWidget(target, redParam)
	local contain = false
	for i,v in ipairs(target.redParams) do
		if v.lv == redParam.lv and v.index == redParam.index then
			contain = true
		end
	end
	if not contain then table.insert(target.redParams, redParam) end
end

-- 添加红点
function GUIFocusDot.addRedPointToTarget(target)
	if not target then return end
	local pSize = target:getContentSize()
	print("target target",target)
	GameUtilSenior.print_table(target)
	GameUtilSenior.print_table(pSize)
	local redPoint = target:getWidgetByName("redPoint")
	if not redPoint then
		redPoint = ccui.ImageView:create("img_red_dot", ccui.TextureResType.plistType)
			--:setOpacity(255 * 0)
			:align(display.CENTER, pSize.width-10, pSize.height-10)
			-- :align(display.CENTER, ((pSize.width * 0.2 < 30) and pSize.width * 0.8) or (pSize.width-30), pSize.height * 0.8)
			-- :align(display.CENTER, pSize.width * 0.9, pSize.height * 0.8)
			:addTo(target)
		local btnName = target:getName()
		local posX, posY = redPoint:getPosition()
		if GameBaseLogic.isMainButton(btnName) then
			redPoint:setPosition(posX - 10, posY - 2)
		elseif btnName == "btn_control_func" then
			local posX, posY = redPoint:getPosition()
			redPoint:setPosition(posX - 7, posY - 2)
		elseif target:getName() == "btn_vip" then
			--redPoint:setScale(1):setPositionX(0)
		end
		redPoint:setName("redPoint")
	end
end

-- --添加光圈
-- function GUIFocusDot.addBlnToTarget(target, blnRes)
-- 	if not target then return end
-- 	GameUtilSenior.addHaloToButton(target, blnRes)
-- end

function GUIFocusDot.hanldeRemoveRedPoint(event)
	if event and event.lv and redTable[event.lv] then
		if not table.indexof(var.redDotGuides, event.lv) then return end

		if redTable[event.lv] then
			for i,v in ipairs(redTable[event.lv]) do
				GUIFocusDot.clearWidgetParam({lv = event.lv, index = i})
			end
		end
		table.removebyvalue(var.redDotGuides, event.lv)
	end
end

-- 清理红点数据
function GUIFocusDot.clearWidgetParam(event)
	local param = redTable[event.lv][event.index]
	for _,name in ipairs(param.node) do
		local widget = GUIMain.getGuideWidget({root = param.root, panel = param.panel, node = name}, "clearWidgetParam"..event.lv)
		if widget then 
			if widget.redParams then
				for i,v in ipairs(widget.redParams) do
					if v.lv == event.lv and v.index == event.index then
						table.remove(widget.redParams, i)
					end 
				end
				if #widget.redParams == 0 then
					if widget:getChildByName("redPoint") then
						widget:removeChildByName("redPoint")
					end
					if widget:getChildByName("img_bln") then
						widget:removeChildByName("img_bln")
					end
				end
			else
				if widget:getChildByName("redPoint") then
					widget:removeChildByName("redPoint")
				end
				if widget:getChildByName("img_bln") then
					widget:removeChildByName("img_bln")
				end
			end
		end
		if param.panel and var.panelRedParams[param.panel] then
			for i,v in ipairs(var.panelRedParams[param.panel]) do
				if v.lv == event.lv and v.index == event.index then
					table.remove(var.panelRedParams[param.panel], i)
				end 
			end
		end
		if param.menu and var.subMenuRedParams[param.menu] then
			for i,v in ipairs(var.subMenuRedParams[param.menu]) do
				if v.lv == event.lv and v.index == event.index then
					table.remove(var.subMenuRedParams[param.menu], i)
				end 
			end
		end
	end
end

return GUIFocusDot