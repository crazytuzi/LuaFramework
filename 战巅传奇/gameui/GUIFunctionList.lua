-- 主界面右侧快捷物品按钮
local GUIFunctionList = {}
local var = {}

-- 编辑器编辑按钮
local basic_func = {
	"btn_main_avatar", "btn_main_skill", "btn_main_equip", "btn_main_furnace", "btn_main_wing", "btn_main_puzzle", "btn_main_achieve", "btn_main_social", "btn_main_rank", "btn_main_system", 
}

-- 代码生成按钮
local subMenus = {
	["equip"] = {
		"btn_main_forge", "btn_main_official", "btn_main_compose", "btn_main_convert", 
	},
	["social"] = {
		"btn_main_friend", "btn_main_group", "btn_main_guild", "btn_main_mail", "btn_main_consign"
	},
}


if PLATFORM_BANSHU then
	subMenus = {
		["equip"] = {
			"btn_main_forge", "btn_main_furnace", "btn_main_official", 
		},
		["social"] = {
			"btn_main_friend", "btn_main_group", "btn_main_mail", "btn_main_consign"
		},
	}
end

local separateWidth = 3;
local offX = 5;
local mHeight = 90;
local intervalH = 90;
local mWidth = 90;

local function hideSubMenuBox()
	if var.boxSubMenu then var.boxSubMenu:hide() end
end

local function handleMailFull(full)
	local btnMainMail = var.boxSubMenu:getWidgetByName("btn_main_mail")
	if not btnMainMail then return end
	local imgFullFlag = btnMainMail:getChildByName("img_mail_full")
	local redPoint = btnMainMail:getChildByName("redPoint")

	if full then
		if not imgFullFlag then
			imgFullFlag = ccui.ImageView:create("img_bag_full", ccui.TextureResType.plistType)
				:align(display.CENTER, 52 , 54 )
				:addTo(btnMainMail, 1)
				:setName("img_mail_full")
		end
		imgFullFlag:show()
		if redPoint then redPoint:hide() end

	else
		if imgFullFlag then
			imgFullFlag:hide()
		end
		if redPoint then redPoint:show() end
	end
end

local function handleBasicFuncVisible(visible)
	var.btnControlFunc:stopAllActions()
	local btnBasic
	for i,v in ipairs(basic_func) do
		btnBasic = var.boxBasicFunc:getWidgetByName(v)
		if btnBasic then
			btnBasic:setVisible(visible)
		end
	end

	if var.boxSubMenu then var.boxSubMenu:setVisible(visible) end

	if var.btnControlFunc then
		var.btnControlFunc.showProps = visible
		if visible then
			if PLATFORM_BANSHU then
				var.btnControlFunc:setPositionX(53):setScale(1)
			else
				var.btnControlFunc:setPositionX(-220):getChildByName("img_control_func"):setScale(1)
			end
		else
			var.btnControlFunc:setPositionX(455):getChildByName("img_control_func"):setScale(-1)
		end
		local redPoint = var.btnControlFunc:getWidgetByName("redPoint")
		if redPoint then redPoint:setVisible(not visible) end
	end
	hideSubMenuBox()
	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CHAT_VISIBLE, visible = not visible})
end

local function doDelayHideBasicFunc()
	var.btnControlFunc:stopAllActions()
	var.btnControlFunc:runAction(cca.seq({
		cca.delay(5),
		cca.cb(function ()
			handleBasicFuncVisible(false)
		end)
	}))
end

local function pushSubMenuButton(sender)
	local btnName = sender:getName()
	if btnName == "btn_main_furnace" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_furnace"})
	elseif btnName == "btn_main_forge" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_forge"})
	elseif btnName == "btn_main_official" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_official"})
	elseif btnName == "btn_main_convert" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_convert"})
	elseif btnName == "btn_main_friend" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_friend"})
	elseif btnName == "btn_main_group" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_group"})
	elseif btnName == "btn_main_guild" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_guild"})
	elseif btnName == "btn_main_mail" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_mail"})
	elseif btnName == "btn_main_consign" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_consign"})
	elseif btnName == "btn_main_compose" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_compose"})
	end
end

-- 显示二级菜单
local function handleSubMenuBox(subType, posX)
	local subMenu = subMenus[subType]
	if not subMenu then return end
	
	if var.btnControlFunc.showProps then -- 按钮点开状态下5秒后收回
		doDelayHideBasicFunc()
	else
		return;
	end
	if subType == var.boxSubMenu.subType and var.boxSubMenu:isVisible() then
		return var.boxSubMenu:hide()
	end

	local pWidth = offX * 2 + #subMenu * (intervalH + separateWidth) - separateWidth
	local imgSubMenuBg = var.boxSubMenu:getChildByName("img_sub_menu_bg")
	if imgSubMenuBg.subType == subType then
		var.boxBasicFunc:getWidgetByName("box_sub_menu"):setVisible(not var.boxBasicFunc:getWidgetByName("box_sub_menu"):isVisible())
		return
	end
	imgSubMenuBg.subType = subType
	imgSubMenuBg:removeAllChildren()
	imgSubMenuBg:setContentSize(pWidth, mHeight)
	local imgSubMenuInner = var.boxSubMenu:getChildByName("img_sub_menu_inner")
	imgSubMenuInner:setContentSize(pWidth - 15, imgSubMenuInner:getContentSize().height)

	local btnSubMenu, imgSepatate, mPosX
	for i,v in ipairs(subMenu) do
		mPosX = offX + i * (intervalH + separateWidth) - separateWidth
		if i < #subMenu then
			imgSepatate = ccui.ImageView:create("img_sub_menu_separate", ccui.TextureResType.plistType)
				:align(display.LEFT_BOTTOM, mPosX, 0)
				:addTo(imgSubMenuBg)
		end
		btnSubMenu = ccui.Button:create(v, v, "", ccui.TextureResType.plistType)
			:align(display.CENTER, mPosX - 0.5 * intervalH, mHeight * 0.5)
			:addTo(imgSubMenuBg)
			:setPressedActionEnabled(true)
			:setZoomScale(-0.12)
			:setName(v)
		if v=="btn_main_mail" then 
			handleMailFull(#GameSocket.mails >= 25)
		end
		GUIFocusPoint.addUIPoint(btnSubMenu, pushSubMenuButton)
	end
	var.boxSubMenu:show():setPosition(posX, 90)
	var.boxSubMenu.subType = subType

	GameSocket:dispatchEvent({ name = GameMessageCode.EVENT_UPDATE_MENUDICT, menus = {
		["btn_main_"..subType] = 1,
	}, mName = "btn_main_"..subType})

end

local function pushBasicFuncButton(sender)
	local btnName = sender:getName()
	-- print("pushBasicFuncButton", btnName)
	local params = string.split(btnName,"_")
	-- print(params[3])
	if btnName == "btn_main_avatar" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_avatar"})
	elseif btnName == "btn_main_equip" then
		handleSubMenuBox("equip", sender:getPositionX())
	elseif btnName == "btn_main_furnace" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_furnace"})
	elseif btnName == "btn_main_wing" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "btn_main_wing"})
	elseif btnName == "btn_main_puzzle" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_puzzle"})
	elseif btnName == "btn_main_achieve" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_achieve"})
	elseif btnName == "btn_main_social" then
		handleSubMenuBox("social", sender:getPositionX())
	elseif btnName == "btn_main_skill" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_skill"})
	elseif btnName == "btn_main_rank" then	
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "btn_main_rank"})
	elseif btnName == "btn_main_system" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "menu_setting"})
	end
end

local function initBoxEquipFunc()
	var.boxSubMenu = var.boxBasicFunc:getWidgetByName("box_sub_menu"):hide()
	local pWidth = offX * 2 + #sub_menu * (intervalH + separateWidth) - separateWidth
	local imgSubMenuBg = var.boxSubMenu:getChildByName("img_sub_menu_bg"):setTouchEnabled(true)
	-- imgSubMenuBg:setScale9Enabled(true)
	-- imgSubMenuBg:setCapInsets(cc.rect(28, 28, 30, 30))
	imgSubMenuBg:setContentSize(pWidth, mHeight)

	local imgSubMenuInner = var.boxSubMenu:getChildByName("img_sub_menu_inner"):setOpacity(0.66 * 255)
	imgSubMenuInner:setContentSize(pWidth - 15, imgSubMenuInner:getContentSize().height)

	local btnEquipFunc, imgSepatate, posX
	for i,v in ipairs(sub_menu) do
		posX = offX + i * (intervalH + separateWidth) - separateWidth
		if i < #sub_menu then
			imgSepatate = ccui.ImageView:create("img_sub_menu_separate", ccui.TextureResType.plistType)
				:align(display.LEFT_BOTTOM, posX, 0)
				:addTo(imgSubMenuBg)
		end
		btnEquipFunc = ccui.Button:create(v, v, "", ccui.TextureResType.plistType)
			:align(display.CENTER, posX - 0.5 * intervalH, mHeight * 0.5)
			:addTo(imgSubMenuBg)
			:setPressedActionEnabled(true)
			:setZoomScale(-0.12)
			:setName(v)
		GUIFocusPoint.addUIPoint(btnEquipFunc, pushBasicFuncButton)
	end
end

local function initBoxBasicFunc()
	var.btnControlFunc = var.boxBasicFunc:getWidgetByName("btn_control_func"):setPressedActionEnabled(true)
	var.btnControlFunc.showProps = true
	GUIFocusPoint.addUIPoint(var.btnControlFunc, function (sender)
		handleBasicFuncVisible(not sender.showProps)
		if var.btnControlFunc.showProps  then -- 按钮点开状态下5秒后收回
			doDelayHideBasicFunc()
		end
	end)
	handleBasicFuncVisible(false)

	local btnBasic
	for i,v in ipairs(basic_func) do
		btnBasic = var.boxBasicFunc:getWidgetByName(v)
		if btnBasic then
			btnBasic:setPressedActionEnabled(true)
			GUIFocusPoint.addUIPoint(btnBasic, pushBasicFuncButton)
		end
	end
	-- initBoxEquipFunc()
end

function GUIFunctionList.init(boxBasicFunc)
	var = {
		boxBasicFunc,
		boxSubMenu,
	}
	var.boxBasicFunc = boxBasicFunc

	if var.boxBasicFunc then
		var.boxSubMenu = var.boxBasicFunc:getWidgetByName("box_sub_menu")
		var.boxSubMenu:getChildByName("img_sub_menu_bg"):setTouchEnabled(true)
		var.boxSubMenu:getChildByName("img_sub_menu_inner"):setOpacity(0.66 * 255)
		initBoxBasicFunc()
		cc.EventProxy.new(GameSocket,var.boxSubMenu)
			:addEventListener(GameMessageCode.EVENT_CHECK_MAIL_FULL,function (event)
				handleMailFull(#GameSocket.mails >=25)
			end)
	end
end


function GUIFunctionList.update()
	if not var.boxBasicFunc then return end
	-- if GameCharacter._autoFight ~= var.btnAutoFight._selected then
	-- 	var.btnAutoFight:loadTextureNormal(GameCharacter._autoFight and "btn_auto_on" or "btn_auto", ccui.TextureResType.plistType)
	-- 	var.btnAutoFight._selected = GameCharacter._autoFight
	-- end
end

return GUIFunctionList