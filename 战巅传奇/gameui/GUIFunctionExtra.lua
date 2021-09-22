-- 主界面右侧快捷物品按钮
--控制主界面显示哪些按钮.

local GUIFunctionExtra = {}
local var = {}

--第一排按钮不变，二三排实现自动换行
local allExtButtons = {
	[1] = {
		"extend_store",
		--"extend_openServer",
		"extend_awardHall",
		"extend_invest",
		"extend_firstPay",
		"extend_rechargeLianXuGift",
		"extend_dailyPay",
		"extend_rechargePointGift",
		"extend_rechargeGift",
		--"extend_xianshijiangli",  --限时奖励
	},
	[2] = {
		"extend_lottory",
		"extend_world",
		"extend_kingWar",
		--"btn_main_consign",
		"extend_help",  --攻略
		-- "extend_mars", -- 战神
		--"extend_exploit", -- 功勋
		--"extend_breakup",  --天关
		--"extend_kingWar",
		"extend_offline",
		"extend_superVip",
		"extend_task",
		-- "extend_puzzle",
		"extend_makeExp",
	},
	[3] = {
		"extend_activities",  --庆典活动
		"extend_download",
		--"extend_dice",  --破天罡
		"extend_zhuanPan",
		"extend_events",  --超值回馈活动
		"extend_heFu",  --和服活动
		--"btn_main_rank",  --排行
		"extend_qungift",
		--"extend_help",  --攻略
		"extend_spread",  --推广
		"menu_container_btn_toushi",  --透视
	}
}

local extendButtons = {}

if PLATFORM_BANSHU then
	allExtButtons = {
		[1] = {
			"extend_store",
			"extend_activities",
		},
		[2] = {
			"extend_offline",
			"extend_makeExp",
		}
	}
end

if device.platform == "ios" then
	if table.indexof(allExtButtons[3],"extend_download") then
		table.removebyvalue(allExtButtons[3], "extend_download")
	end
end

local alwaysExtends = {
	"extend_mars", "extend_baobao", "menu_container_btn_shiwuduihuan"--"extend_store" ,"extend_breakup", 
}

local offX = -36;
local intervalH = 80;

local posY1 = 35; 
local posY2 = -35;
local posY3 = -105;

local function checkExtendHalo(btnExtend)
	if btnExtend.redParams and #btnExtend.redParams > 0 then
		return true
	end
end

-- 遍历显示光圈动画
local function doExtendAnimation()
	local children = var.boxExtend:getChildren()

	local btnExtend
	for i,v in ipairs(alwaysExtends) do
		btnExtend = var.righttop:getWidgetByName(v)
		if btnExtend then table.insert(children, btnExtend) end
	end
	
	local btnName, pSize, animaSprite, animate
	for i,v in ipairs(children) do
		btnName = v:getName()
		animaSprite = v:getChildByName("animaSprite")
		pSize = v:getContentSize()
		if animaSprite then animaSprite:stopAllActions():hide() end
		if checkExtendHalo(v) then
			if not animaSprite then
				animaSprite = cc.Sprite:create()
					:align(display.CENTER, 0.5 * pSize.width, 0.5 * pSize.height)
					:addTo(v)
					:setName("animaSprite")
			end
			animate = cc.AnimManager:getInstance():getPlistAnimate(4, 60040, 4, 5,false,false,0,function(animate,shouldDownload)
							animaSprite:show():runAction(animate)
							animaSprite:setBlendFunc({src=gl.SRC_ALPHA,dst=gl.ONE})
							if shouldDownload==true then
								animaSprite:release()
								var.boxExtend:release()
								v:release()
							end
						end,
						function(animate)
							animaSprite:retain()
							var.boxExtend:retain()
							v:retain()
						end)
		end
	end

end

--处理按钮动画同步问题
local function handleExtendAnimation()
	var.boxExtend:runAction(cca.repeatForever(
		cca.seq({
			cca.cb(function ()
				doExtendAnimation()
			end),
			cca.delay(1)
		})
	))
end

-- 按钮回调
local function pushExtendButton(sender)
	local btnName = sender:getName()
	
	local chrName = GameBaseLogic.chrName
	chrName = string.gsub(chrName, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    chrName = string.gsub(chrName, " ", "+")
	
	if btnName=="extend_spread" then
		--print("platform_id",GameCCBridge.getConfigString("platform_id"))
		print("game.zoneId",GameBaseLogic.zoneId)
		print("game.zoneId",chrName)
		if device.platform == "android" then
			print("android will open web")
			cc.Application:getInstance():openURL("http://www.bl20166.com/spread/index.php?channel="..GameCCBridge.getConfigString("platform_id").."&serverID="..GameBaseLogic.zoneId.."&chrname="..chrName)
		elseif device.platform == "ios" then
			print("ios will open safari web")
			GameCCBridge.callPlatformFunc({
				func="openURL",
				url="http://www.bl20166.com/spread/index.php?channel=0&serverID="..GameBaseLogic.zoneId.."&chrname="..chrName
			})
		end
	elseif btnName=="extend_baobao" then
		GameSocket:PushLuaTable("gui.ContainerWarProtecter.handlePanelData",GameUtilSenior.encode({actionid = "callBaoBao"}))
	elseif btnName=="extend_mars" then
		GameSocket:PushLuaTable("gui.ContainerWarProtecter.handlePanelData",GameUtilSenior.encode({actionid = "reqZhaoHuanOrZhaoHui"}))
	elseif btnName=="extend_qungift" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "V8_ContainerJiaQunLiBao"})
	elseif btnName=="extend_xianshijiangli" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "V8_ContainerXianShiJiangLi"})
	elseif btnName=="extend_help" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "container_help"})
	elseif btnName=="menu_container_btn_shiwuduihuan" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "v4_panel_ShiWuDuiHuan"})
	elseif btnName=="menu_container_btn_toushi" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "V8_ContainerXianShiJiangLi",tab=7})		
	elseif btnName=="btn_main_consign" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_consign"})	
	elseif btnName=="extend_rechargeGift" then
		GameSocket:NpcTalk(2000015,"100")		
	else
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = btnName})
	end
end

local function createExtendButton(name)
	
	
	--local bg_name = ccui.Button:create("btn_skill_small", "btn_skill_small", "", ccui.TextureResType.plistType) 
	--				:setPressedActionEnabled(true)
	--				:setZoomScale(-0.12)
	--				:setName(name)
	--				
	--local btnExtend = ccui.ImageView:create(name, ccui.TextureResType.plistType)
	--				:align(display.CENTER, bg_name:getContentSize().width/2, bg_name:getContentSize().height/2)
	--				:addTo(bg_name)
	--local btn_name = ccui.ImageView:create(name.."_name", ccui.TextureResType.plistType)
	--	:align(display.CENTER, bg_name:getContentSize().width/2, bg_name:getContentSize().height/2-28)
	--	:addTo(bg_name)
	-- bg_name.showAnima = true

	local btnExtend = ccui.Button:create(name, name, "", ccui.TextureResType.plistType)
		:setPressedActionEnabled(true)
		:setZoomScale(-0.12)
		:setName(name)
	-- btnExtend.showAnima = true
	return btnExtend
end

--默认第二行
local function getExtButtonLine(name)
	for line=1,3 do
		if extendButtons[line] then
			for i,v in ipairs(extendButtons[line]) do
				if name == v then
					return line
				end
			end		
		end
	end
	-- return 2
end

-- 刷新extend按钮
local function updateExtendButtons(index)
	local extButtons = extendButtons[index]
	if not extButtons then return end
	-- local posY = (index == 1) and posY1 or posY2
	-- local posY = posY1 - (index - 1) * 70
	local posY
	local btnExtend
	local count = 0;
	for i,v in ipairs(extButtons) do
		btnExtend = var.boxExtend:getChildByName(v)
		if GameSocket:checkGuiButton(v) then --按钮是否可见
			if not btnExtend then 
				print(v,var.boxExtend)
				btnExtend = createExtendButton(v):addTo(var.boxExtend) 
				GUIFocusPoint.addUIPoint(btnExtend, pushExtendButton)
			end
			local line = getExtButtonLine(v) or index
			posY = posY1 - (line - 1) * 80
			btnExtend:align(display.CENTER, offX - count * intervalH, posY)
			count = count + 1
		elseif btnExtend then
			btnExtend:removeFromParent()
		end
	end

	--清除老按钮
	extButtons = allExtButtons[index]
	if not extButtons then return end
	for i,v in ipairs(extButtons) do
		btnExtend = var.boxExtend:getChildByName(v)
		if btnExtend and not GameSocket:checkGuiButton(v) then
			btnExtend:removeFromParent()
		end
	end
end

local function updateAlwaysExtends()
	local btnExtend
	for i,v in ipairs(alwaysExtends) do
		btnExtend = var.righttop:getChildByName(v)
		if btnExtend then
			btnExtend:setVisible(GameSocket:checkGuiButton(v))
		end
	end
end

local function initAlwaysExtends()
	local btnExtend
	for i,v in ipairs(alwaysExtends) do
		btnExtend = var.righttop:getChildByName(v)
		if btnExtend then
			GUIFocusPoint.addUIPoint(btnExtend, pushExtendButton)
		end
	end
end


--重设extendButtons
local function resetExtendButtons()
	extendButtons[2] = {}
	extendButtons[3] = {}
	local count = 0
	for i=2,3 do
		for j,v in ipairs(allExtButtons[i]) do
			if GameSocket:checkGuiButton(v) then
				if count < 7 then
					table.insert(extendButtons[2], v)
					count = count + 1
				else
					table.insert(extendButtons[3], v)
				end
			end
		end
	end
end

local function handleExtendButtons()
	resetExtendButtons()
	-- print("/////////handleExtendButtons/////////////", GameUtilSenior.encode(extendButtons))

	updateExtendButtons(1)
	updateExtendButtons(2)
	updateExtendButtons(3)

	updateAlwaysExtends()
end

local function handleExtendVisibleByIndex(index, visible)
	local extButtons = extendButtons[index]
	if not extButtons then return end
	local btnExtend
	for i,v in ipairs(extButtons) do
		btnExtend = var.boxExtend:getChildByName(v)
		if btnExtend then btnExtend:setVisible(visible) end
	end
end

function GUIFunctionExtra.init(righttop)
	var = {
		righttop,
		boxExtend,
	}

	extendButtons = clone(allExtButtons)

	var.righttop = righttop
	if var.righttop then
		var.boxExtend = var.righttop:getWidgetByName("box_extend")
		initAlwaysExtends()
		handleExtendButtons()
		handleExtendAnimation()
		cc.EventProxy.new(GameSocket, boxExtend)
			:addEventListener(GameMessageCode.EVENT_GUI_BUTTON, handleExtendButtons)
	end
end

return GUIFunctionExtra