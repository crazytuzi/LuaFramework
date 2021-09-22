local GUIItem = {}

local equipFlagRes = {
	--[GameConst.ITEM_WEAPON_POSITION] 	=	"equip_flag_weapon",
	--[GameConst.ITEM_CLOTH_POSITION] 	=	"equip_flag_cloth",
	--[GameConst.ITEM_GLOVE1_POSITION] 	=	"equip_flag_glove",
	--[GameConst.ITEM_RING1_POSITION] 	=	"equip_flag_ring",
	--[GameConst.ITEM_BOOT_POSITION] 		=	"equip_flag_boot",
	--[GameConst.ITEM_HAT_POSITION] 		=	"equip_flag_hat",	
	--[GameConst.ITEM_NICKLACE_POSITION] 	=	"equip_flag_necklace",
	--[GameConst.ITEM_GLOVE2_POSITION] 	=	"equip_flag_glove",
	--[GameConst.ITEM_RING2_POSITION] 	=	"equip_flag_ring",
	--[GameConst.ITEM_BELT_POSITION] 		=	"equip_flag_belt",

	--玉佩
	--[GameConst.ITEM_JADE_PENDANT_POSITION] = "equip_flag_jade_pendant",
	--护盾
	--[GameConst.ITEM_SHIELD_POSITION] = "equip_flag_shield",
	--护心镜
	--[GameConst.ITEM_MIRROR_ARMOUR_POSITION] = "equip_flag_mirror_armour",
	--面巾
	--[GameConst.ITEM_FACE_CLOTH_POSITION] = "equip_flag_face_cloth",
	--龙心
	--[GameConst.ITEM_DRAGON_HEART_POSITION] = "equip_flag_dragon_heart",
	--狼牙
	--[GameConst.ITEM_WOLFANG_POSITION] = "equip_flag_wolfang",
	--龙骨
	--[GameConst.ITEM_DRAGON_BONE_POSITION] = "equip_flag_dragon_bone",
	--虎符
	[GameConst.ITEM_CATILLA_POSITION] = "equip_flag_catilla",
	
	--[GameConst.ITEM_XUEFU_POSITION] = "equip_flag_xuefu",
	--[GameConst.ITEM_FABAO_POSITION] = "equip_flag_fabao",
	--[GameConst.ITEM_LINGFU_POSITION] = "equip_flag_lingfu",
	--[GameConst.ITEM_YINGHUN_POSITION] = "equip_flag_yinghun",
	--[GameConst.ITEM_BAODING_POSITION] = "equip_flag_baoding",
	--[GameConst.ITEM_ZHANQI_POSITION] = "equip_flag_zhanqi",
	--[GameConst.ITEM_SHOUHU_POSITION] = "equip_flag_shouhu",
	--[GameConst.ITEM_ZHANDUN_POSITION] = "equip_flag_zhandun",
	
	--[GameConst.ITEM_ZHUZHUANGPLUS1_POSITION] = "equip_flag_zhuzhuangplus1",
	--[GameConst.ITEM_ZHUZHUANGPLUS2_POSITION] = "equip_flag_zhuzhuangplus2",
	
	--[GameConst.ITEM_FUZHUANGPLUS1_POSITION] = "equip_flag_fuzhuangplus1",
	--[GameConst.ITEM_FUZHUANGPLUS2_POSITION] = "equip_flag_fuzhuangplus2",
	--[GameConst.ITEM_FUZHUANGPLUS3_POSITION] = "equip_flag_fuzhuangplus3",
	
	--[GameConst.ITEM_SRSX1_POSITION] = "equip_flag_srsx1",
	--[GameConst.ITEM_SRSX2_POSITION] = "equip_flag_srsx2",
	--[GameConst.ITEM_SRSX3_POSITION] = "equip_flag_srsx3",
	--[GameConst.ITEM_SRSX4_POSITION] = "equip_flag_srsx4",
	--[GameConst.ITEM_SRSX5_POSITION] = "equip_flag_srsx5",
	--[GameConst.ITEM_SRSX6_POSITION] = "equip_flag_srsx6",
	--[GameConst.ITEM_SRSX7_POSITION] = "equip_flag_srsx7",
	--[GameConst.ITEM_SRSX8_POSITION] = "equip_flag_srsx8",
	--[GameConst.ITEM_SRSX9_POSITION] = "equip_flag_srsx9",
	--[GameConst.ITEM_SRSX10_POSITION] = "equip_flag_srsx10",
	--[GameConst.ITEM_SRSX11_POSITION] = "equip_flag_srsx11",
	--[GameConst.ITEM_SRSX12_POSITION] = "equip_flag_srsx12",
}

local function newItem(pSize)
	local itemIcon = ccui.Widget:create()
		:setName("item_icon")
		:setContentSize(pSize)

	local imgIconInner = ccui.ImageView:create("null", ccui.TextureResType.plistType)
		:align(display.CENTER, pSize.width * 0.5, pSize.height * 0.5+2)
		:addTo(itemIcon)
		:hide()
		:setName("img_icon_inner")

	local imgEquipFlag = ccui.ImageView:create("null", ccui.TextureResType.plistType)
		:align(display.CENTER, pSize.width * 0.5, pSize.height * 0.5)
		:addTo(itemIcon)
		-- :hide()
		:setName("img_equip_flag")

	local size = imgIconInner:getContentSize()
	imgIconInner:setScale(pSize.width / size.width)

	-- 品质背景
	ccui.ImageView:create()
		:align(display.CENTER, pSize.width * 0.5, pSize.height * 0.5)
		:addTo(itemIcon)
		:hide()
		:setName("img_icon_bg")

	-- icon图片
	ccui.ImageView:create()
		:align(display.CENTER, pSize.width * 0.5, pSize.height * 0.5)
		:addTo(itemIcon)
		:setName("img_icon")

	--强化等级
	ccui.Text:create()
		:align(display.RIGHT_TOP, (pSize.width<=60 and pSize.width * 0.95 or pSize.width * 0.9), (pSize.height<=60 and pSize.height*1 or pSize.height*0.9))
		:setFontName(FONT_NAME)
		:addTo(itemIcon)
		:setFontSize(16)
		:setName("lbl_upd_level")
		:enableOutline(GameBaseLogic.getColor(0x000000),1)

	--注灵等级(装备)
	ccui.Text:create()
		:align(display.RIGHT_BOTTOM, pSize.width * 0.9, pSize.height*0.1)
		:setFontName(FONT_NAME)
		:addTo(itemIcon)
		:setFontSize(20)
		:setName("lbl_zl_level")

	--数量 暂时写死
	ccui.Text:create()
		:align(display.RIGHT_BOTTOM, pSize.width * 0.9, pSize.height * 0.1)
		:enableOutline(GameBaseLogic.getColor(0x000000),1)
		:setFontName(FONT_NAME)
		:addTo(itemIcon)
		:setFontSize(16)
		:setName("lbl_num")

	-- 绑定标志
	ccui.ImageView:create("lock", ccui.TextureResType.plistType)
		:align(display.RIGHT_TOP, pSize.width * 0.95, pSize.height * 0.95)
		:addTo(itemIcon)
		:setOpacity(255 * 0.8)
		:hide()
		:setName("img_bind_mark")

	-- 红点
	ccui.ImageView:create("img_arrow_attr_up", ccui.TextureResType.plistType)
		:align(display.LEFT_TOP, pSize.width * 0.1, pSize.height * 0.9)
		:addTo(itemIcon)
		:hide()
		:setName("img_better_equip")

	ccui.ImageView:create("img_red_point", ccui.TextureResType.plistType)
		:align(display.CENTER, pSize.width * 0.81, pSize.height * 0.81)
		:addTo(itemIcon)
		:hide()
		:setName("img_use_item")
		
	return itemIcon
end

local function resetItem(itemIcon)
	if itemIcon then
		-- print("resetItem",itemIcon)
		itemIcon:getWidgetByName("img_icon"):loadTexture("null", ccui.TextureResType.plistType):stopAllActions()
		itemIcon:getWidgetByName("img_icon_bg"):removeChildByName("spriteEffect")
		itemIcon:getWidgetByName("img_icon_bg"):loadTexture("null", ccui.TextureResType.plistType)
		-- itemIcon.itemPos = nil
		itemIcon.typeId = nil
		itemIcon.mLevel = nil
		itemIcon.mClickTime = 0
		itemIcon.showBetter = nil
		if GameBaseLogic.itemSchedule then
			Scheduler.unscheduleGlobal(GameBaseLogic.itemSchedule)
			GameBaseLogic.itemSchedule = nil
		end

		-- itemIcon.updateFunc = nil
		-- itemIcon.itemCallBack = nil
		itemIcon:getWidgetByName("lbl_upd_level"):setString("")
		itemIcon:getWidgetByName("lbl_zl_level"):setString("")
		itemIcon:getWidgetByName("lbl_num"):setString("")
		itemIcon:getWidgetByName("img_better_equip"):hide()
		itemIcon:getWidgetByName("img_bind_mark"):hide()
		itemIcon:getWidgetByName("img_icon_inner"):hide()
		itemIcon:getWidgetByName("img_use_item"):stopAllActions():hide()
	end
end

local function singleClickItem(sender)
	-- print("singleClickItem");
	local itemIcon = sender.itemIcon
	if itemIcon then
		--张思帆说可以去掉限制----------还是加上吧
		if GameConst.ICONTYPE.DEPOT==itemIcon.iconType or GameConst.ICONTYPE.NOTIP==itemIcon.iconType then
			if itemIcon.callBack then itemIcon.callBack() end
		else
			GameSocket:dispatchEvent({
				name		= GameMessageCode.EVENT_HANDLE_TIPS, 
				itemPos		= itemIcon.itemPos, 
				typeId		= itemIcon.typeId,
				mLevel		= itemIcon.mLevel,
				mZLevel		= itemIcon.mZLevel,
				-- iconType    = itemIcon.iconType,
				tipsType	= itemIcon.tipsType,
				customCallFunc = itemIcon.customCallFunc,
				destoryCallFunc = itemIcon.destoryCallFunc,
				visible		= true,
				compare		= itemIcon.compare,
				enmuPos 	= itemIcon.enmuPos,
				enmuItemType = itemIcon.enmuItemType,
			})
		end
	end
end

local function doubleClickItem(sender)
	-- print("doubleClickItem");
	local itemIcon = sender.itemIcon
	if itemIcon.doubleCall then
		itemIcon.doubleCall()
	elseif GameConst.ICONTYPE.BAG == itemIcon.iconType then
		local netItem = GameSocket:getNetItem(itemIcon.itemPos)
		if netItem then
			if GameBaseLogic.canBatchUse(netItem.mTypeID) then
				GameSocket:BagUseItem(itemIcon.itemPos, netItem.mTypeID,netItem.mNumber)
			else
				GameSocket:BagUseItem(itemIcon.itemPos, netItem.mTypeID)
			end
		end
	end
end

local function handleEquipFlag(itemIcon)
	itemIcon:getWidgetByName("img_equip_flag"):loadTexture("null", ccui.TextureResType.plistType)
	if itemIcon.itemPos and itemIcon.itemPos < 0 and itemIcon.mShowEquipFlag then
		local netItem = GameSocket:getNetItem(itemIcon.itemPos)
		if not netItem and equipFlagRes[itemIcon.itemPos] then
			itemIcon:getWidgetByName("img_equip_flag"):loadTexture(equipFlagRes[itemIcon.itemPos], ccui.TextureResType.plistType)
		end
	end
end

--背包格子红点动画
local function handleRedPoint(itemIcon, netItem)
	itemIcon:getWidgetByName("img_use_item"):stopAllActions():hide()
	-- print("////////////////////////////////", netItem.position, GameBaseLogic.IsPosInBag(netItem.position), GameBaseLogic.checkItemShowUse(netItem.mTypeID))
	if GameBaseLogic.IsPosInBag(netItem.position) and GameBaseLogic.checkItemShowUse(netItem.mTypeID) then
		local milliSecond = math.floor(GameBaseLogic.getTime() % 1000 - 500)
		local scale = 1
		if milliSecond >= 0 then
			scale = 1.1 - (0.2 * milliSecond / 500)
		else
			scale = 0.9 + (0.2 * (500 + milliSecond) / 500)
		end

		local function scaleActionA (sender)
			if sender then sender:runAction(cca.repeatForever(cca.seq({cca.scaleTo(0.5, 1.1), cca.scaleTo(0.5, 0.9)}))) end
		end

		local function scaleActionB (sender)
			if sender then sender:runAction(cca.repeatForever(cca.seq({cca.scaleTo(0.5, 0.9), cca.scaleTo(0.5, 1.1)}))) end
		end

		local imgUseItem = itemIcon:getWidgetByName("img_use_item"):show():scale(scale)
		if milliSecond > 0 then
			imgUseItem:runAction(cca.seq({
				cca.scaleTo((500 - milliSecond) / 1000, 0.9),
				cca.cb(scaleActionA)
			}))
		else
			imgUseItem:runAction(cca.seq({
				cca.scaleTo(-milliSecond / 1000, 1.1),
				cca.cb(scaleActionB)
			}))
		end
	end
end

--整理使用批量刷新，不执行单个刷新
local function canItemFresh(pos)
	local can = true
	if GameSocket.mSortFlag then
		if GameSocket.mSortFlag == 0 then --背包
			if GameBaseLogic.IsPosInBag(pos) then can = false end
		elseif GameSocket.mSortFlag == 1 then -- 仓库
			if GameBaseLogic.IsPosInDepot(pos) then can = false end
		-- elseif GameSocket.mSortFlag == 3 then -- 寻宝
		-- 	if GameBaseLogic.IsPosInLottoryDepot(pos) then can = false end
		end
	end
	-- print("canItemFresh", GameSocket.mSortFlag, pos, can)
	return can
end

function GUIItem.getItem(param)
	--暂时先不对比装备
	--param.compare = false
	if param.parent then
		local itemIcon = param.parent:getWidgetByName("item_icon")
		--print("GUIItem.getItem", itemIcon)
		local addEvent = true
		if not itemIcon then
			local pSize = param.parent:getContentSize()
			itemIcon = newItem(pSize):align(display.CENTER, pSize.width * 0.5, pSize.height * 0.5):addTo(param.parent)
		else
			addEvent = false
			resetItem(itemIcon)
		end
		itemIcon.updateFunc = nil
		itemIcon.updateDesp = nil

		itemIcon.mShowEquipFlag = param.mShowEquipFlag
		itemIcon.mLevel = param.mLevel
		itemIcon.mZLevel = param.mZLevel
		itemIcon.showBetter = param.showBetter
		itemIcon.showBg = param.showBg
		itemIcon:getWidgetByName("lbl_upd_level"):setString(itemIcon.mLevel and itemIcon.mLevel>0 and "+"..itemIcon.mLevel or ""):setColor(cc.c3b(48,255,0))
		itemIcon:getWidgetByName("lbl_zl_level"):setString(itemIcon.mZLevel and itemIcon.mZLevel>0 and "+"..itemIcon.mZLevel or ""):setColor(cc.c3b(0,255,255))
		if param.pos or param.typeId then
			--print("param.pos", param.pos, param.typeId, param.titleText)
			
			param.parent:setTouchEnabled(true)
			param.parent.itemIcon = itemIcon
			itemIcon:setTouchEnabled(false)
			-- itemIcon.itemCallBack	= param.itemCallBack
			itemIcon.iconType		= param.iconType
			itemIcon.tipsType		= param.tipsType
			itemIcon.customCallFunc = param.customCallFunc
			itemIcon.destoryCallFunc = param.destoryCallFunc
			itemIcon.callBack		= param.callBack
			itemIcon.doubleCall		= param.doubleCall
			if itemIcon.customCallFunc then
				itemIcon.doubleCall = itemIcon.customCallFunc
			end
			param.parent.hitTestCall    = param.hitTest
			itemIcon.updateDesp 	= param.updateDesp
			itemIcon.updateFunc 	= param.updateFunc
			itemIcon.compare 	= param.compare
			itemIcon.enmuPos	= param.enmuPos
			itemIcon.enmuItemType = param.enmuItemType
			itemIcon.pos = param.pos
			itemIcon.showInnerLook = param.showInnerLook
			itemIcon.parent 	= param.parent
			
			if param.pos then
				GUIItem.updateItemIconByPos(itemIcon, param.pos)
				if addEvent then
					cc.EventProxy.new(GameSocket,itemIcon)
						:addEventListener(GameMessageCode.EVENT_ITEM_CHANGE, function (event)
							if canItemFresh(itemIcon.itemPos) then
								GUIItem.handleItemChange(itemIcon, event)
							end
						end)
						:addEventListener(GameMessageCode.EVENT_ITEM_USELIMIT_CHANGE, function (event)
							GUIItem.handleItemUseLimitChange(itemIcon, event)
						end)
						:addEventListener(GameMessageCode.EVENT_NOTIFY_GETITEMDESP, function (event)
							local netItem = GameSocket:getNetItem(param.pos)
							if netItem then
								if GameSocket:getItemDefByIDFromLocal(netItem.mTypeID) then
									if itemIcon.loading~=true then
										itemIcon.loading = true
										GUIItem.updateItemIconByTypeId(itemIcon, netItem.mTypeID)
									end
								end
							end
						end)
				end
			elseif param.typeId then 
				GUIItem.updateItemIconByTypeId(itemIcon, param.typeId)
				if addEvent then
					cc.EventProxy.new(GameSocket,itemIcon)
						:addEventListener(GameMessageCode.EVENT_NOTIFY_GETITEMDESP, function (event)
							if param.typeId == event.type_id then
								GUIItem.updateItemIconByTypeId(itemIcon, event.type_id)
							end
						end)
				end

				if param.num then
					GUIItem.updateItemNum(itemIcon, param.num)
				end
				if param.bind then
					if bit.band(param.bind, GameConst.ITEM_FLAG_BIND) > 0 then
						itemIcon:getWidgetByName("img_bind_mark"):show()
					else
						itemIcon:getWidgetByName("img_bind_mark"):hide()
					end
				end
			end
			param.parent:setSwallowTouches(true)
			GameUtilSenior.addMutilClickListener(param.parent, singleClickItem, doubleClickItem)
		end
	end
end

function GUIItem.updateItemIconByPos(itemIcon, pos)
	-- print("updateItemIconByPos", pos)
	itemIcon.itemPos = pos
	local netItem = GameSocket:getNetItem(pos)
	if netItem then
		itemIcon.mLevel = netItem.mLevel
		itemIcon.mZLevel = netItem.mZLevel

		GUIItem.updateItemIconByTypeId(itemIcon, netItem.mTypeID)
		local mNum = netItem.mNumber
		local color = cc.c3b(0, 255, 0)
		local itemdef = GameSocket:getItemDefByID(netItem.mTypeID)
		if itemdef then
			color = GameBaseLogic.getColor(itemdef.mColor)
		end
		if itemIcon.mLevel > 0 then
			itemIcon:getWidgetByName("lbl_upd_level"):setString("+"..itemIcon.mLevel):setColor(cc.c3b(48,255,0))
		else
			itemIcon:getWidgetByName("lbl_upd_level"):setString("")
		end
		if netItem.mZLevel > 0 then
			itemIcon:getWidgetByName("lbl_zl_level"):setString(itemIcon.mZLevel):setColor(cc.c3b(0,255,255))
		else
			itemIcon:getWidgetByName("lbl_zl_level"):setString("")
		end
		-- local mColor = cc.c3b(0,255,0)
		GUIItem.updateItemNum(itemIcon, mNum)

		if bit.band(netItem.mItemFlags, GameConst.ITEM_FLAG_BIND) > 0 then
			itemIcon:getWidgetByName("img_bind_mark"):show()
		else
			itemIcon:getWidgetByName("img_bind_mark"):hide()
		end
		handleRedPoint(itemIcon, netItem)
		
	
		--添加一个以物品typeid为名字的节点,用于做任务引导
		--print("===============",netItem.mTypeID)
		if not itemIcon:getChildByName(netItem.mTypeID) then
			local pSize = itemIcon:getContentSize()
			local redPoint = ccui.Layout:create()
			redPoint:setName(netItem.mTypeID)
			redPoint:setContentSize(cc.size(pSize.width,pSize.height)):setPosition(0,0):setAnchorPoint(cc.p(0,0))
			redPoint:addTo(itemIcon)
		end
		
	else
		resetItem(itemIcon)
	end

	if GameSocket:check_better_item(itemIcon.itemPos, true) then 
		itemIcon:getWidgetByName("img_better_equip"):show() 
	else
		if netItem and GameBaseLogic.checkBoxMatch(netItem.mTypeID) then
			itemIcon:getWidgetByName("img_better_equip"):show() 
		else
			itemIcon:getWidgetByName("img_better_equip"):hide() 
		end
	end
	handleEquipFlag(itemIcon, netItem)
	if itemIcon.updateFunc then itemIcon.updateFunc(itemIcon.itemPos) end
end

function GUIItem.updateItemNum(itemIcon, num ,color)
	-- print("/////////GUIItem.updateItemNum/////////////", itemIcon.itemPos, num)
	local lblNum = itemIcon:getWidgetByName("lbl_num")
	local pSize = itemIcon:getContentSize()
	if num then
		if type(num) == "number" and num >= 1 then
			if num == 1 then
				lblNum:setString("")
			else
				if num > 9999 then
					lblNum:align(display.CENTER_BOTTOM, pSize.width * 0.5, pSize.height * 0.1)
				else
					lblNum:align(display.RIGHT_BOTTOM, pSize.width * 0.9, pSize.height * 0.1)
				end

				lblNum:setString(num)
			end
		elseif type(num) == "string" then
			lblNum:setString(num)
		end
		if color then
			lblNum:setColor(color)
		end
	else
		lblNum:setString("")
	end
end

function GUIItem.updateItemIconByTypeId(itemIcon, typeId)
	-- print("updateItemIconByTypeId", typeId)
	local iconRes = "10000000"
	local itemdef = GameSocket:getItemDefByID(typeId)
	if itemdef then iconRes = itemdef.mIconID end
	itemIcon.typeId = typeId
	itemIcon.resLoaded = false
	if itemIcon.showInnerLook==true and cc.FileUtils:getInstance():isFileExist(string.format("image/%s/%d%02d.png","cell",iconRes,0)) then
		local itemIconWidget = itemIcon:getWidgetByName("img_icon")
		
		local maxPicID = 0
		for i=0,100,1 do
			local filepath = string.format("image/%s/%d%02d.png","cell",iconRes,i)
			if not cc.FileUtils:getInstance():isFileExist(filepath) then
				break
			else
				maxPicID = i
			end
		end
	
		local startNum = 0
		local function startShowBg()
		
			local filepath = string.format("image/%s/%d%02d.png","cell",iconRes,startNum)
			asyncload_callback(filepath, itemIconWidget, function(filepath, texture)
				itemIconWidget:loadTexture(filepath)
			end)
			
			startNum= startNum+1
			if startNum ==maxPicID+1 then
				startNum =0
			end
		end
		itemIconWidget:stopAllActions()
		itemIconWidget:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowBg)}),tonumber(maxPicID+1)))
	else
		local pSize = itemIcon.parent:getContentSize()
		local path = "image/icon/"..iconRes..".png"
		-- local imgIconInner = itemIcon:getWidgetByName("img_icon_inner"):hide()
		asyncload_callback(path, itemIcon, function(filepath, texture)
			-- if GameUtilSenior.isObjectExist(itemIcon) and itemIcon.typeId then
				-- if not itemIcon.resLoaded then
					-- imgIconInner:show()
					itemIcon:getWidgetByName("img_icon"):loadTexture(path)
							--:setContentSize(cc.size(pSize.width,pSize.height))
							--:setUnifySizeEnabled(false)
							--:ignoreContentAdaptWithSize(false)
					local size = itemIcon:getWidgetByName("img_icon"):getContentSize()
					local pSize = itemIcon:getContentSize()
					local wScale = pSize.width / size.width
					local hScale = pSize.height / size.height
					local scale = 1
					if wScale>hScale then
						scale = hScale 
					else
						scale = wScale
					end
					itemIcon:getWidgetByName("img_icon"):setScale(scale * 0.7)
				-- end
			
				-- local itemdef = GameSocket:getItemDefByID(itemIcon.typeId)
				-- if itemdef and "image/icon/"..itemdef.mIconID..".png" == filepath then
				-- 	itemIcon.resLoaded = true
				-- end
			-- end
		end)
	end

	local filepath
	if itemdef and itemdef.mItemBg > 0 then
		if itemdef.mItemBg<1000 then
			--普通背景
			filepath = string.format("image/icon/iconbg%s.png", itemdef.mItemBg)
		else
			--特效背景
			local size = itemIcon:getWidgetByName("img_icon_bg"):getContentSize()
			itemIcon:getWidgetByName("img_icon_bg"):show()
			GameUtilSenior.addEffect(itemIcon:getWidgetByName("img_icon_bg"),"spriteEffect",4,itemdef.mItemBg,{x = size.width/2 , y = size.height/2},false,true)
		end
	elseif itemIcon:getWidgetByName("img_icon_bg") then
		itemIcon:getWidgetByName("img_icon_bg"):loadTexture("null", ccui.TextureResType.plistType):hide()
	end
	if itemIcon.showBg ~= nil then
		filepath = nil
		itemIcon:getWidgetByName("img_icon_bg"):loadTexture("null", ccui.TextureResType.plistType):hide()
	end
	if filepath then
		asyncload_callback(filepath, itemIcon, function(filepath, texture)
			if GameUtilSenior.isObjectExist(itemIcon) and itemIcon.typeId then
				itemIcon:getWidgetByName("img_icon_bg"):show():loadTexture(filepath)
				local size = itemIcon:getWidgetByName("img_icon_bg"):getContentSize()
				local pSize = itemIcon:getContentSize()
				itemIcon:getWidgetByName("img_icon_bg"):setScale(1.0)
			end
		end)
	end

	if GameBaseLogic.IsShield(typeId) or GameBaseLogic.IsJewel(typeId) or GameBaseLogic.IsCrittoken(typeId) then
		-- GUIItem.updateSpecialItemName(itemIcon, typeId)
	end
	if itemdef and itemIcon.updateDesp then
		itemIcon.updateDesp(itemdef)
	end
	if itemIcon.showBetter then
		if GameSocket:check_better_item({mTypeID = typeId, mLevel = itemIcon.mLevel}, true) then 
			itemIcon:getWidgetByName("img_better_equip"):show() 
		end
	end

end

function GUIItem.handleItemChange(itemIcon, event)
	if event.pos == itemIcon.itemPos then
		-- if itemIcon.iconType == GameConst.ICONTYPE.UPGRADE then resetItem(itemIcon) return end
		if event.pos then 
			if GameUtilSenior.isObjectExist(itemIcon) then
				GUIItem.updateItemIconByPos(itemIcon, event.pos)
			end
		end
	end
	if itemIcon and itemIcon.itemPos then
		if GameSocket:check_better_item(itemIcon.itemPos, true) then 
			itemIcon:getWidgetByName("img_better_equip"):show() 
		else
			local netItem = GameSocket:getNetItem(itemIcon.itemPos)
			if netItem and GameBaseLogic.checkBoxMatch(netItem.mTypeID) then
				itemIcon:getWidgetByName("img_better_equip"):show() 
			else
				itemIcon:getWidgetByName("img_better_equip"):hide() 
			end
		end
	end
end

function GUIItem.handleItemUseLimitChange(itemIcon, event)
	if GameBaseLogic.IsPosInBag(itemIcon.itemPos) and event.typeId == itemIcon.typeId then
		local netItem = GameSocket:getNetItem(itemIcon.itemPos)
		if netItem then
			handleRedPoint(itemIcon, netItem)
		end
	end
end

function GUIItem.updateItemIcon(itemIcon)
	local netItem = GameSocket:getNetItem(itemIcon.itemPos)
	if netItem then
		local itemdef = GameSocket:getItemDefByID(netItem.mTypeID)
		if not itemdef then print("not this item3") return end
	end
end

return GUIItem