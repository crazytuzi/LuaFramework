GUIFloatTips = {}

local title2Name = {
	["更多"] = "btn_tips_more", 
	["使用"] = "btn_tips_use", 
	["装备"] = "btn_tips_dress", 
	["卸下"] = "btn_tips_dress", 
	["强化"] = "btn_tips_upgrade",
	["精炼"] = "btn_tips_refine", 
	["存放"] = "btn_tips_store", 
	["取出"] = "btn_tips_take", 
	["出售"] = "btn_tips_sell", 
	["丢弃"] = "btn_tips_drop", 
	["交易"] = "btn_tips_trade", 
	["合成"] = "btn_tips_compound",
	["拆分"] = "btn_tips_split", 
	["发送聊天"] = "btn_tips_send_chat",
	["寄售"] = "btn_tips_consign",
	["摧毁"] = "btn_tips_destory"
}

-- 特殊处理，绑定物品丢弃时候提示丢弃即是摧毁

local USE_TYPE = {
	NULL = 0,
	USEITEM = 1,
	DRESSEQUIP = 2,
	UNDRESSEQUIP = 3,
	DEPOTIN = 4, --存入仓库
	DEPOTOUT = 5, --仓库取出
	TRADEIN = 6, --交易
	-- DRESSGEM = 7, --镶嵌宝石
	-- UNDRESSGEM = 8, -- 卸下宝石
	TREASURE=7,
	CUSTOM = 10,
}

-- GameConst.TIPS_TYPE = {
-- 	GENERAL = 1,
-- 	BAG = 2,
-- 	DEPOT = 3,
-- 	TRADE = 4,
-- 	CONSIGN = 5,
-- 	GEM = 6,
-- 	UPGRADE = 7,
-- 	REFINE = 8,
-- 	GUILD = 9,
---TREASURE=10
-- }

-- tips分类依据：
-- 1 类别枚举；1(通用)，2(背包)，3(仓库)，4(交易)，5(寄售)，6(宝石)，7(强化)，8(精炼)，9(帮会)
-- 2，pos位枚举；1(身上),2(背包)，,3(仓库), 4(寻宝), 5(行会仓库), 6(自定义)
-- 3，物品类型枚举；0(所有物品),1(装备),2(药品)，3(其他)，4(帮会帮主副帮主看的tips)
-- tag = enmuType * 100 + enumPos * 10 + enmuItemType
local TIPS_TAG = {
	GENERAL_DRESSED_EQUIP = 111,

	BAG_BAG_EQUIP = 221,
	BAG_BAG_DRUG = 222,
	BAG_BAG_OTHER = 223,


	DEPOT_BAG_EQUIP = 321, -- 存放
	DEPOT_BAG_DRUG = 322, -- 存放， 更多(拆分)
	DEPOT_BAG_OTHER = 323, -- 存放， 更多(拆分)

	DEPOT_DEPOT_EQUIP = 331, -- 取出
	DEPOT_DEPOT_DRUG = 332, -- 取出， 更多(拆分)
	DEPOT_DEPOT_OTHER = 333, -- 取出， 更多(拆分)

	TRADE_BAG_EQUIP = 421, 
	TRADE_BAG_DRUG = 422,
	TRADE_BAG_OTHER = 423,

	CONSIGN_BAG_ALL=520,

	GEM_BAG_OTHER = 623,

	

	UPGRADE_BAG_EQUIP = 721,

	HUISHOU_GET_OUT=733,--回收取出

	GEM_GET_OUT=743,--宝石取下

	UPGRADE_IN_EQUIP = 761,

	HUISHOU_GET_IN=763,--回收投入

	GUILD_BAG_ALL = 920,
	GUILD_GUILD_ALL = 950,
	GUILD_GUILD_ALL_ADMIN = 954,

	TREASURE_BAG_ALL=1040,
	
	-- CONSIGN = 501,
	-- GEM = 601,
	-- UPGRADE = 701,
	-- REFINE = 801,
}

local buttonsConfig = {
	[TIPS_TAG.BAG_BAG_EQUIP] = {
		--useTitle = "装备", useType = USE_TYPE.DRESSEQUIP,  more = {"强化", "出售","丢弃","寄售",}
		useTitle = "装备", useType = USE_TYPE.DRESSEQUIP,  more = {"出售","丢弃",}
	},
	[TIPS_TAG.BAG_BAG_DRUG] = {
		--useTitle = "使用", useType = USE_TYPE.USEITEM, more = {"出售","丢弃","拆分","寄售",}
		useTitle = "使用", useType = USE_TYPE.USEITEM, more = {"出售","丢弃",}
	},
	[TIPS_TAG.BAG_BAG_OTHER] = {
		--useTitle = "使用", useType = USE_TYPE.USEITEM, more = {"出售","丢弃","拆分"}
		useTitle = "使用", useType = USE_TYPE.USEITEM, more = {"出售","丢弃",}
	},
	[TIPS_TAG.GENERAL_DRESSED_EQUIP] = {
		useTitle = "卸下", useType = USE_TYPE.UNDRESSEQUIP,
	},
	[TIPS_TAG.DEPOT_BAG_EQUIP] = {
		--useTitle = "存放", useType = USE_TYPE.DEPOTIN, more = {"强化", "出售",	"丢弃",}
		useTitle = "存放", useType = USE_TYPE.DEPOTIN, more = {"出售",	"丢弃",}
	},
	[TIPS_TAG.DEPOT_BAG_DRUG] = {
		--useTitle = "存放", useType = USE_TYPE.DEPOTIN, more = {"出售", "丢弃", "拆分"}
		useTitle = "存放", useType = USE_TYPE.DEPOTIN, more = {"出售", "丢弃",}
	},
	[TIPS_TAG.DEPOT_BAG_OTHER] = {
		--useTitle = "存放", useType = USE_TYPE.DEPOTIN, more = {"出售", "丢弃", "拆分"}
		useTitle = "存放", useType = USE_TYPE.DEPOTIN, more = {"出售", "丢弃",}
	},
	[TIPS_TAG.DEPOT_DEPOT_EQUIP] = {
		useTitle = "取出", useType = USE_TYPE.DEPOTOUT,
	},
	[TIPS_TAG.DEPOT_DEPOT_DRUG] = {
		useTitle = "取出", useType = USE_TYPE.DEPOTOUT,
	},
	[TIPS_TAG.DEPOT_DEPOT_OTHER] = {
		useTitle = "取出", useType = USE_TYPE.DEPOTOUT,
	},
	[TIPS_TAG.TRADE_BAG_EQUIP] = {
		useTitle = "放入", useType = USE_TYPE.CUSTOM,
	},
	[TIPS_TAG.TRADE_BAG_DRUG] = {
		useTitle = "放入", useType = USE_TYPE.CUSTOM, --more = {"拆分"}
	},
	[TIPS_TAG.TRADE_BAG_OTHER] = {
		useTitle = "放入", useType = USE_TYPE.CUSTOM, --more = {"拆分"}
	},
	[TIPS_TAG.GEM_BAG_OTHER] = {
		useTitle = "镶嵌", useType = USE_TYPE.CUSTOM,
	},
	[TIPS_TAG.UPGRADE_BAG_EQUIP] = {
		useTitle = "放入", useType = USE_TYPE.CUSTOM
	},
	[TIPS_TAG.TREASURE_BAG_ALL] = {
		useTitle = "取出", useType = USE_TYPE.TREASURE
	},

	[TIPS_TAG.CONSIGN_BAG_ALL] = {
		useTitle = "寄售", useType = USE_TYPE.CUSTOM
	},
	[TIPS_TAG.GUILD_BAG_ALL] = {
		useTitle = "投入", useType = USE_TYPE.CUSTOM
	},
	[TIPS_TAG.GUILD_GUILD_ALL] = {
		useTitle = "兑换", useType = USE_TYPE.CUSTOM
	},
	[TIPS_TAG.GUILD_GUILD_ALL_ADMIN] = {
		useTitle = "兑换", useType = USE_TYPE.CUSTOM, more = {"摧毁"}
	},
	[TIPS_TAG.UPGRADE_IN_EQUIP] = {
		useTitle = "取出", useType = USE_TYPE.CUSTOM
	},
	[TIPS_TAG.HUISHOU_GET_OUT] = {
		useTitle = "取出", useType = USE_TYPE.CUSTOM
	},
	[TIPS_TAG.HUISHOU_GET_IN] = {
		useTitle = "投入", useType = USE_TYPE.CUSTOM
	},
	[TIPS_TAG.GEM_GET_OUT] = {
		useTitle = "取下", useType = USE_TYPE.CUSTOM
	},

}

local function getTipsTag(xmlTips)
	local itemPos = xmlTips.itemPos
	local itemDef = xmlTips.itemDef
	local typeId = xmlTips.typeId
	local enmuType = xmlTips.tipsType or 0
	local enmuPos = xmlTips.enmuPos or 0
	local enmuItemType = 0

	if xmlTips.enmuItemType then
		enmuItemType = xmlTips.enmuItemType
	else
		if GameBaseLogic.IsEquipment(typeId) then
			enmuItemType = 1
		elseif GameBaseLogic.IsDrug(typeId) then
			enmuItemType = 2
		else
			enmuItemType = 3
		end
	end

	if enmuPos == 0 then
		if GameBaseLogic.IsPosInAvatar(itemPos) then
			enmuPos = 1
		elseif GameBaseLogic.IsPosInBag(itemPos) then
			enmuPos = 2
		elseif GameBaseLogic.IsPosInDepot(itemPos) then
			enmuPos = 3
		elseif GameBaseLogic.IsPosInLottoryDepot(itemPos) then -- 寻宝仓库强制为0
			enmuPos = 4
		end
	end

	if enmuType==5 then 
		enmuPos = 2
		enmuItemType = 0
	end
	-- if enmuType == 9 then
	-- 	enmuItemType = 0
	-- end
	if enmuType == 4 then
		if GameBaseLogic.IsEquipment(typeId) then
			enmuItemType = 1
		elseif GameBaseLogic.IsDrug(typeId) then
			enmuItemType = 2
		else
			enmuItemType = 3
		end
	end

	return enmuType * 100 + enmuPos * 10 + enmuItemType
end

local function DropBindItem(itemPos, typeId)
	local mParam = {
		name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = "绑定物品丢弃即摧毁(确认丢弃)",
		btnConfirm = "确定", btnCancel = "取消",
		confirmCallBack = function ()
			GameSocket:DestoryItem(itemPos, typeId)
		end
	}
	GameSocket:dispatchEvent(mParam)
end

local itemsChangeTab = {
	["depot"]	= {name = "仓库", begin = GameConst.ITEM_DEPOT_BEGIN,	size = GameConst.ITEM_DEPOT_SIZE, add = "mDepotSlotAdd"},
	["bag"]		= {name = "背包", begin = GameConst.ITEM_BAG_BEGIN,	size = GameConst.ITEM_BAG_SIZE, add = "mBagSlotAdd"},
	["treasure"]= {name = "背包", begin = GameConst.ITEM_BAG_BEGIN,	size = GameConst.ITEM_BAG_SIZE, add = "mBagSlotAdd"},
}

-- 存入和取出
local function changeItemPosTo(itemPos, slot)
	-- print("changeItemPosTo", itemPos, slot)
	local add = 0;
	local conf = itemsChangeTab[slot]
	if conf then
		-- print("has conf")
		local num = conf.size + GameSocket[conf.add]
		for i = 0, num - 1 do
			if not GameSocket:getNetItem(i + conf.begin) then -- 表示空位
				if GameSocket:getNetItem(itemPos) then
					GameSocket:ItemPositionExchange(itemPos, i + conf.begin)
					return
				end
			end
		end
		GameSocket:alertLocalMsg(conf.name.."空间不足")
	end
end

-- tips列表按钮的回调函数
local function pushTipsButtons(sender)
	local btnName = sender:getName()
	local xmlTips = sender.xmlTips
	local itemPos = xmlTips.itemPos
	local typeId = xmlTips.typeId
	local netItem = xmlTips.netItem
	local itemDef = xmlTips.itemDef

	-- print("pushTipsButtons", btnName, xmlTips, itemPos, typeId)
	if btnName == "btn_tips_split" then
		GameSocket:SplitItem(itemPos, typeId, 1)
	elseif btnName == "btn_tips_upgrade" then --强化
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="main_forge"})
	elseif btnName == "btn_tips_refine" then --精炼

	elseif btnName == "btn_tips_sell" then
		local num = GameBaseLogic.checkBatchSell(typeId) and netItem.mNumber or 1
		GameSocket:NPCSell(100, itemPos, typeId, num, 200)
	elseif btnName == "btn_tips_drop" then
		if bit.band(netItem.mItemFlags, GameConst.ITEM_FLAG_BIND) > 0 then
			DropBindItem(itemPos, typeId)
		else
			GameSocket:DropItem(itemPos, typeId, netItem.mNumber or 1)
		end
	elseif btnName == "btn_tips_destory" then
		if xmlTips.destoryCallFunc then
			xmlTips.destoryCallFunc()
		else
			GameSocket:DestoryItem(itemPos, typeId)
		end

		-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_DESTORY_ITEM, })
	elseif btnName == "btn_tips_trade" then

	elseif btnName == "btn_tips_store" then
		changeItemPosTo(itemPos, "depot")
	elseif btnName == "btn_tips_take" then
		changeItemPosTo(itemPos, "bag")
	elseif btnName == "btn_tips_merge" then

	elseif btnName == "btn_tips_compound" then

	elseif btnName == "btn_tips_send_chat" then
		if itemDef and netItem then
			local msg = "<item src=\""..itemDef.mName..","..netItem.mLevel..","..netItem.mZLevel.."\"/>"
			GameSocket:sendChatToLastChannel(msg)
		end
	elseif btnName == "btn_tips_consign" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="main_consign", tab = 2})
	end
	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HANDLE_TIPS, visible = false})
end

-- tips使用按钮的回调函数
local function pushTipsUseButton(sender)
	local mUseType = sender.useType
	local xmlTips = sender.xmlTips
	local itemPos = xmlTips.itemPos
	local typeId = xmlTips.typeId
	if mUseType == USE_TYPE.USEITEM then -- 使用，针对背包非装备
		if GameBaseLogic.IsPosInBag(itemPos) then
			print("GameBaseLogic.canBatchUse(typeId)")
			if GameBaseLogic.canBatchUse(typeId) then
				print("GameBaseLogic.canBatchUse(typeId)2",GameBaseLogic.canBatchUse(typeId))
				local netItem = xmlTips.netItem
				local num = netItem.mNumber
				GameSocket:BagUseItem(itemPos, typeId, num)
			else
				GameSocket:BagUseItem(itemPos, typeId)
			end
		end
	elseif mUseType == USE_TYPE.DRESSEQUIP then
		if GameBaseLogic.IsPosInBag(itemPos) then
			GameSocket:BagUseItem(itemPos, typeId)
		end
	elseif mUseType == USE_TYPE.UNDRESSEQUIP then
		if GameBaseLogic.IsPosInAvatar(itemPos) then
			GameSocket:UndressItem(itemPos)
		end
	elseif mUseType == USE_TYPE.DEPOTIN then
		if GameBaseLogic.IsPosInBag(itemPos) then
			changeItemPosTo(itemPos, "depot")
		end
	elseif mUseType == USE_TYPE.DEPOTOUT then
		if GameBaseLogic.IsPosInDepot(itemPos) then
			changeItemPosTo(itemPos, "bag")
		end
	elseif mUseType == USE_TYPE.TREASURE then
		if GameBaseLogic.IsPosInLottoryDepot(itemPos) then
			if GameSocket:takeItemFromLottory(itemPos) then 
				GameSocket:takeItemFromLottory(itemPos)
			else
				GameSocket:alertLocalMsg("背包空间不足")
			end 	
			--changeItemPosTo(itemPos, "treasure")
		end
	elseif mUseType == USE_TYPE.CUSTOM then
		if xmlTips.customCallFunc then
			xmlTips.customCallFunc()
		end

	end
	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HANDLE_TIPS, visible = false})
end

-- 控制tips列表按钮显隐
local function handleButtonsListVisible(sender, visible)
	local xmlTips = sender.xmlTips
	sender.showMore = visible
	local listButtons = xmlTips:getWidgetByName("list_buttons")
	listButtons:setVisible(visible)
	sender:getWidgetByName("img_more_flag"):setScaleY(visible and -1 or 1);
end

-- 初始化tips上通用按钮
local function initTipsButtons(xmlTips)

	local btnTips = xmlTips:getWidgetByName("btn_tips_more")
	btnTips.showMore = false
	GUIFocusPoint.addUIPoint(btnTips, function (sender)
		handleButtonsListVisible(sender, not sender.showMore)
	end)

	local btnTipsUse = xmlTips:getWidgetByName("btn_tips_use")
	btnTipsUse.xmlTips = xmlTips
	GUIFocusPoint.addUIPoint(btnTipsUse, pushTipsUseButton)

	local listButtons = xmlTips:getWidgetByName("list_buttons")
	listButtons:setItemsMargin(3)
end

-- tips创建函数
local function newTips(typeId,compare)
	local xmlTips
	if GameBaseLogic.IsEquipment(typeId) then
		xmlTips = GUIAnalysis.load("ui/layout/GDIVEquipTips.uif")
		xmlTips:getWidgetByName("list_base_attr"):setGravity(ccui.ListViewGravity.left)
		xmlTips:getWidgetByName("list_upd_attr"):setGravity(ccui.ListViewGravity.left)

		xmlTips:getWidgetByName("lbl_zhuling_pre"):hide()
		xmlTips:getWidgetByName("img_zhuling_bar_bg"):hide()

		local listBaseAttr = xmlTips:getWidgetByName("list_base_attr")
		if false then   --显示元素属性，true为不显示元素属性
			listBaseAttr:setContentSize(listBaseAttr:getContentSize().width, 240)
			xmlTips:getWidgetByName("lbl_upd_pre"):hide()
			xmlTips:getWidgetByName("list_upd_attr"):hide()
			xmlTips:getWidgetByName("img_tips_line2"):hide()
		else
			listBaseAttr:setContentSize(listBaseAttr:getContentSize().width, 85)
			xmlTips:getWidgetByName("lbl_upd_pre"):show()
			xmlTips:getWidgetByName("list_upd_attr"):show()
			xmlTips:getWidgetByName("img_tips_line2"):show()
		end
		
		--动态特效外观
		--物品介绍
		GameUtilSenior.addEffect(xmlTips:getWidgetByName("tips_animal_bg"),"spriteEffect",4,76003,false,false,true)
		xmlTips:getWidgetByName("tips_bg"):setLocalZOrder(10)
		--物品介绍
		--GameUtilSenior.addEffect(xmlTips:getWidgetByName("desp_tips_bg"),"spriteEffect",4,76004,false,false,true)
		--套装属性
		--GameUtilSenior.addEffect(xmlTips:getWidgetByName("suit_tips_bg"),"spriteEffect",4,76005,false,false,true)
	else
		xmlTips = GUIAnalysis.load("ui/layout/GDivPropsTips.uif")

		xmlTips:getWidgetByName("list_source"):setGravity(ccui.ListViewGravity.left)
		xmlTips:getWidgetByName("list_desp"):setGravity(ccui.ListViewGravity.left)
		
		--动态特效外观
		--物品介绍
		GameUtilSenior.addEffect(xmlTips:getWidgetByName("tips_animal_bg"),"spriteEffect",4,76006,false,false,true)
		xmlTips:getWidgetByName("tips_bg"):setLocalZOrder(10)
	end
	if not compare then
		initTipsButtons(xmlTips)
	else
		--对比窗口下不删除无法显示更多
		xmlTips:getWidgetByName("list_buttons"):setName("list_buttons_repeat")
		xmlTips:getWidgetByName("box_buttons"):setName("box_buttons_repeat")
	end
	return xmlTips
end

-- tips上的物品图标刷新
local function updateTipsIcon(xmlTips)
	local itemDef = xmlTips.itemDef
	if itemDef then
		if cc.FileUtils:getInstance():isFileExist(string.format("image/%s/%d%02d.png","cell",itemDef.mIconID,0)) and true==false then
			local imgIconFrame = xmlTips:getWidgetByName("img_icon_frame")
			local imgIcon = imgIconFrame:getWidgetByName("img_icon")
			
			--[[
			local maxPicID = 0
			for i=0,100,1 do
				local filepath = string.format("image/%s/%d%02d.png","cell",itemDef.mIconID,i)
				if not cc.FileUtils:getInstance():isFileExist(filepath) then
					break
				else
					maxPicID = i
				end
			end
		
			local startNum = 0
			local function startShowBg()
			
				local filepath = string.format("image/%s/%d%02d.png","cell",itemDef.mIconID,startNum)
				asyncload_callback(filepath, imgIcon, function(filepath, texture)
					imgIcon:loadTexture(filepath)
				end)
				
				startNum= startNum+1
				if startNum ==maxPicID+1 then
					startNum =0
				end
			end
			imgIcon:stopAllActions()
			imgIcon:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowBg)}),tonumber(maxPicID+1)))
			]]
			local size = itemIcon:getWidgetByName("img_icon"):getContentSize()
			GameUtilSenior.addEffect(imgIcon,"spriteEffect",4,itemdef.mItemBg,{x = size.width/2 , y = size.height/2},false,true)
		else
			local imgIconFrame = xmlTips:getWidgetByName("img_icon_frame")
			local filepath = "image/icon/"..itemDef.mIconID..".png"
			-- imgIconFrame.resLoaded = false
			asyncload_callback("image/icon/"..itemDef.mIconID..".png", imgIconFrame, function(filepath, texture)
			-- 	if GameUtilSenior.isObjectExist(xmlTips) and xmlTips.typeId then
					-- if not imgIconFrame.resLoaded then
						local imgIcon = imgIconFrame:getWidgetByName("img_icon")
						imgIcon:loadTexture(filepath)
						local size = imgIcon:getContentSize()
						local pSize = imgIconFrame:getContentSize()
						imgIcon:setScale(pSize.width / size.width * 0.7)
					-- end
				
					-- local itemdef = GameSocket:getItemDefByID(xmlTips.typeId)
					local img_icon_bg = imgIconFrame:getWidgetByName("img_icon_bg")
					-- if itemdef and "image/icon/"..itemdef.mIconID..".png" == filepath then
					-- 	imgIconFrame.resLoaded = true
					-- end
					if itemDef and itemDef.mItemBg > 0 then
						filepath = string.format("image/icon/iconbg%s.png", itemDef.mItemBg)
					else
						filepath = "image/icon/null.png"
					end
					img_icon_bg:loadTexture(filepath)
			-- 	end
			end)
			local size = imgIconFrame:getContentSize()
			GameUtilSenior.addEffect(imgIconFrame,"spriteEffect",4,itemDef.mItemBg,{x = size.width/2 , y = size.height/2},false,true)
		end
	end
end

-- tips上半部分基础信息
local function updateBasicInfo(xmlTips)
	local netItem = xmlTips.netItem
	local itemDef = xmlTips.itemDef

	if itemDef then
		local mNameType = ""
		local mNameTypeColor = ""
		if netItem then
			local holyDam = netItem.mSpecialHolyDam
			if holyDam>=100000 then
				mNameType = "[神器]"
				mNameTypeColor = cc.c3b(255, 0, 51)			
			elseif holyDam>=50000 then
				mNameType = "[传说]"
				mNameTypeColor = cc.c3b(0, 153, 204)
			elseif holyDam>=30000 then
				mNameType = "[精品]"
				mNameTypeColor = cc.c3b(255,255,0)
			elseif holyDam>=10000 then
				mNameType = "[良品]"
				mNameTypeColor = cc.c3b(204, 204, 0)
			else
				mNameType = "[普通]"
				mNameTypeColor = cc.c3b(255,255,255)
			end
			print("===================",holyDam)
			if holyDam>0 and xmlTips:getWidgetByName("lbl_name_type") then
				--显示品质
				xmlTips:getWidgetByName("lbl_name_type"):setString(mNameType):setColor(mNameTypeColor)
				xmlTips:getWidgetByName("lbl_name"):setPositionX(73)
			end
		end
		xmlTips:getWidgetByName("lbl_name"):setString(itemDef.mName):setColor(GameBaseLogic.getItemColor(itemDef.mEquipLevel))
		xmlTips:getWidgetByName("lbl_type"):setString(GameBaseLogic.getItemType(itemDef.mTypeID))

		local lblLevel = xmlTips:getWidgetByName("lbl_level")
		if itemDef.mNeedZsLevel > 0 then
			lblLevel:setString(itemDef.mNeedZsLevel.."转")
			-- lblLevel:setPosition(cc.p(190,315))
			if itemDef.mNeedZsLevel <= GameCharacter._mainAvatar:NetAttr(GameConst.net_zslevel) then
				lblLevel:setColor(cc.c3b(48,255,0))
			else
				lblLevel:setColor(cc.c3b(255,0,0))
			end
		elseif itemDef.mNeedParam >= 0 then
			lblLevel:setString(itemDef.mNeedParam.."级")
			if itemDef.mNeedParam <= GameCharacter._mainAvatar:NetAttr(GameConst.net_level) then
				lblLevel:setColor(cc.c3b(48,255,0))
			else
				lblLevel:setColor(cc.c3b(255,0,0))
			end
		end
	end
end

-- 物品tips描述和产出
local function updatePropsTips(xmlTips)
	local netItem = xmlTips.netItem
	local itemDef = xmlTips.itemDef

	if itemDef then
		local listDesp = xmlTips:getWidgetByName("list_desp")
		local size = listDesp:getInnerContainerSize()
		local richLabelDesp = xmlTips:getWidgetByName("richLabel_desp")
		richLabelDesp:setRichLabel("<font color=#B2A58B>"..itemDef.mDesp.."</font>", "tips_desp", 16)
		listDesp:requestDoLayout()

		local listSource = xmlTips:getWidgetByName("list_source")
		size = listSource:getInnerContainerSize()
		local richLabelSource = xmlTips:getWidgetByName("richLabel_source")
		richLabelSource:setRichLabel("<font color=#B2A58B>"..itemDef.mSource.."</font>", "tips_src", 16)
		listSource:requestDoLayout()
	end
end

-- 装备tips基础属性(包含强化加成)
-- 显示物防，魔防，物攻，法攻，道攻，血，暴击，内功，字号16

local MIN_VALUE = 0


local function buildEquipBaseAttr(itemDef, xmlTips)
	--GameUtilSenior.print_table(itemDef)
	local mUpdLevel = xmlTips.mUpdLevel
	local baseAttrs = {
		{key = "物理攻击：", value = {min = itemDef.mDC, max = itemDef.mDCMax}, color="#a8c87a"},
		{key = "魔法攻击：", value = {min = itemDef.mMC, max = itemDef.mMCMax}, color="#8c3936"},
		{key = "道士攻击：", value = {min = itemDef.mSC, max = itemDef.mSCMax}, color="#d2ee64"},
		{key = "物理防御：", value = {min = itemDef.mAC, max = itemDef.mACMax}, color="#faa74c"},
		{key = "魔法防御：", value = {min = itemDef.mMAC, max = itemDef.mMACMax}, color="#f8a14a"},
		{key = "生命上限：", value = itemDef.mMaxHp, color="#8addf9"},
		{key = "幸运值：", value = itemDef.mLuck, color="#f9f2b6"},
		--[[
		{key = "暴击概率：", value = itemDef.mBaojiProb, color="#f9f2b6"},
		{key = "暴击率：", value = itemDef.mBaojiPres, color="#f9f2b6"},
		{key = "内功：", value = itemDef.mAddPower, color="#f9f2b6"},
		{key = "反弹概率：", value = itemDef.mFantanProb, color="#8a059d"},
		{key = "反弹比例：", value = itemDef.mFantanPres, color="#3d16d0"},
		{key = "吸血概率：", value = itemDef.mXixueProb, color="#36deb8"},
		{key = "吸血比例：", value = itemDef.mXixuePres, color="#476986"},
		{key = "麻痹时间：", value = itemDef.mMabiDura, color="#57a065"},
		{key = "麻痹概率：", value = itemDef.mMabiProb, color="#a8c87a"},
		{key = "冰冻时间：", value = itemDef.mBingdongDura, color="#57a065"},
		{key = "冰冻概率：", value = itemDef.mBingdongProb, color="#a8c87a"},
		{key = "释毒时间：", value = itemDef.mShiduDura, color="#57a065"},
		{key = "释毒概率：", value = itemDef.mShiduProb, color="#a8c87a"},
		{key = "护身比例：", value = itemDef.mDixiaoPres, color="#8c3936"},
		{key = "复原CD时间：", value = itemDef.mFuyuanCd, color="#faa74c"},
		{key = "复原比例：", value = itemDef.mFuyuanPres, color="#d2ee64"},
		{key = "倍伤倍数：", value = itemDef.mBeiShang, color="#38d4b9"},
		{key = "免伤倍数：", value = itemDef.mMianShang, color="#3537c5"},
		{key = "生命提升比例：", value = itemDef.mMaxHpPres, color="#ED9A66"},
		{key = "吸收伤害概率：", value = itemDef.mXishouProb, color="#15da88"},
		{key = "吸收伤害比例：", value = itemDef.mXishouPres, color="#c43e75"},
		{key = "总体物防比例：", value = itemDef.mACRatio, color="#18a335"},
		{key = "总体魔防比例：", value = itemDef.mMCRatio, color="#f8a14a"},
		{key = "总体物攻比例：", value = itemDef.mDCRatio, color="#9c44a6"},
		{key = "忽视防御比例：", value = itemDef.mIgnoreDCRatio, color="#8addf9"},
		{key = "杀人爆率提升：", value = itemDef.mPlayDrop, color="#f9f2b6"},
		{key = "怪物爆率提升：", value = itemDef.mMonsterDrop, color="#29ed8e"},
		{key = "死亡爆率下降：", value = itemDef.mDropProtect, color="#1952a1"},
		{key = "防止麻痹概率：", value = itemDef.mMabiProtect, color="#bda134"},
		{key = "防止冰冻概率：", value = itemDef.mBingdongProtect, color="#bda134"},
		{key = "防止释毒概率：", value = itemDef.mShiduProtect, color="#bda134"},
		]]
		--{key = "切割伤害：", value = itemDef.holyDam, color="#a8c87a"},  --GS没有传输这个属性
		
	}

	local netItem = xmlTips.netItem
	if netItem then
		--baseAttrs[10].value = baseAttrs[10].value + netItem.mLuck
		-- baseAttrs[10].value = 100
	end

	--print(itemDef.mJob,itemDef.mEquipType)
	local updAttrs = {}
	if mUpdLevel and mUpdLevel > 0 then
		local updId = itemDef.mJob*10000+itemDef.mEquipType*100+mUpdLevel
		local uid = GameSocket.mUpgradeDesp[updId]
		--GameUtilSenior.print_table(uid)
		--print("//////////////////buildEquipBaseAttr//////////////////", updId, uid)
		if uid then
			--print("//////////////////buildEquipBaseAttr//////////////////", GameUtilSenior.encode(uid))
			updAttrs = {
				{min = uid.mDC, max = uid.mDCMax},
				{min = uid.mMC, max = uid.mMCMax},
				{min = uid.mSC, max = uid.mSCMax},
				{min = uid.mAC, max = uid.mACMax},
				{min = uid.mMAC, max = uid.mMACMax},
			}
		end
	end
	

	local str = ""
	for i,v in ipairs(baseAttrs) do
		--print(v.value)
		if GameUtilSenior.isTable(v.value) then
			if v.value.max > MIN_VALUE then
				if v.color~= nil and v.color~= "" then
					str = str.."<td color="..v.color.." size=16 width=35 ht=0>"..v.key.."</td><td color="..v.color.." size=16 width=64 ht=0>"..v.value.min.."-"..v.value.max
				else
					str = str.."<td size=16 width=35 ht=0>"..v.key.."</td><td size=16 width=64 ht=0>"..v.value.min.."-"..v.value.max
				end
				if updAttrs[i] and updAttrs[i].max > 0 then
					str = str.."</td><br><td size=16 width=35 ht=0 color=#FFF920>强化"..v.key.."</td><td size=16 width=64 ht=0>+("..updAttrs[i].min.."-"..updAttrs[i].max..")"
				end
				str = str.."</td><br>"
			end
		elseif v.value > MIN_VALUE then
			--if string.find(v.key,"率") ~= nil or string.find(v.key,"例") ~= nil then
			--	v.value = (v.value / 100).."%"
			--end
			--if v.color~= nil and v.color~= "" then
			--	str = str.."<font color="..v.color..">"..v.key..v.value.."</font><br>"
			--else
			--	str = str..v.key..v.value.."<br>"
			--end
			
			if string.find(v.key,"率") ~= nil or string.find(v.key,"例") ~= nil or string.find(v.key,"提升") ~= nil or string.find(v.key,"下降") ~= nil then
				v.value = (v.value / 100).."%"
			end
			if string.find(v.key,"倍数") ~= nil and v.value~=0 then
				v.value = (v.value / 10000)..""
			end
			if v.color~= nil and v.color~= "" then
				str = str.."<td color="..v.color.." size=16 width=35 ht=0>"..v.key.."</td><td color="..v.color.." size=16 width=64 ht=0>"..v.value.."</td><br>"
			else
				str = str..v.key..v.value.."<br>"
			end
		end
	end
	str = "<font color=#B2A58B>"..str.."</font>"
	return str
end

-- 装备tips强化可激活属性
local function buildEquipActivateAttr(itemDef)
	local str = ""
	if itemDef == nil then
		return str
	end
	--if not (mUpdLevel and mUpdLevel > 0) then
	--	return str 
	--end
	-- uid.mJob*10000+uid.mEquipType*100+uid.mLevel
	--local updId = itemDef.mJob*10000+itemDef.mEquipType*100+mUpdLevel
	--local uid = GameSocket.mUpgradeDesp[updId]
	--if not uid then 
	--	return str 
	--end
	--GameUtilSenior.print_table(itemDef)
	local activeAttrs = {
		{key = "物理攻击：", value = {min = itemDef.mSpecialDC, max = itemDef.mSpecialDCMax}, color="#a8c87a"},
		{key = "魔法攻击：", value = {min = itemDef.mSpecialMC, max = itemDef.mSpecialMCMax}, color="#8c3936"},
		{key = "道士攻击：", value = {min = itemDef.mSpecialSC, max = itemDef.mSpecialSCMax}, color="#d2ee64"},
		{key = "物理防御：", value = {min = itemDef.mSpecialAC, max = itemDef.mSpecialACMax}, color="#faa74c"},
		{key = "魔法防御：", value = {min = itemDef.mSpecialMAC, max = itemDef.mSpecialMACMax}, color="#f8a14a"},
		{key = "生命上限：", value = itemDef.mSpecialMax_hp, color="#29ed8e"},
		
		{key = "暴击概率：", value = itemDef.mSpecialBaoji_prob, color="#a8c87a"},
		{key = "暴击率：", value = itemDef.mSpecialBaoji_pres, color="#8c3936"},
		{key = "内功：", value = itemDef.mSpecialAddPower, color="#d2ee64"},
		{key = "幸运值：", value = itemDef.mSpecialLuck, color="#faa74c"},
		{key = "反弹概率：", value = itemDef.mSpecialFantan_prob, color="#f8a14a"},
		{key = "反弹比例：", value = itemDef.mSpecialFantan_pres, color="#a8c87a"},
		{key = "吸血概率：", value = itemDef.mSpecialXixue_prob, color="#8c3936"},
		{key = "吸血比例：", value = itemDef.mSpecialXixue_pres, color="#d2ee64"},
		{key = "麻痹时间：", value = itemDef.mSpecialMabiDura, color="#faa74c"},
		{key = "麻痹概率：", value = itemDef.mSpecialMabi_prob, color="#f8a14a"},
		{key = "护身比例：", value = itemDef.mSpecialDixiao_pres, color="#a8c87a"},
		{key = "复原CD时间：", value = itemDef.mSpecialFuyuan_cd, color="#8c3936"},
		{key = "复原比例：", value = itemDef.mSpecialFuyuan_pres, color="#d2ee64"},
		{key = "倍伤倍数：", value = itemDef.mSpecialBeiShang, color="#faa74c"},
		{key = "免伤倍数：", value = itemDef.mSpecialMianShang, color="#f8a14a"},
		{key = "生命提升比例：", value = itemDef.mSpecialMax_hp_pres, color="#FFFF66"},
		{key = "吸收伤害概率：", value = itemDef.mSpecialXishou_prob, color="#a8c87a"},
		{key = "吸收伤害比例：", value = itemDef.mSpecialXishou_pres, color="#d2ee64"},
		{key = "总体物防比例：", value = itemDef.mSpecialACRatio, color="#faa74c"},
		{key = "总体魔防比例：", value = itemDef.mSpecialMCRatio, color="#f8a14a"},
		{key = "总体物攻比例：", value = itemDef.mSpecialDCRatio, color="#33FF99"},
		{key = "忽视防御比例：", value = itemDef.mSpecialIgnoreDCRatio, color="#FF66FF"},
		{key = "杀人爆率提升：", value = itemDef.mSpecialPlayDrop, color="#d2ee64"},
		{key = "怪物爆率提升：", value = itemDef.mSpecialMonsterDrop, color="#faa74c"},
		{key = "死亡爆率下降：", value = itemDef.mSpecialDropProtect, color="#f8a14a"},
		{key = "防止麻痹概率：", value = itemDef.mSpecialMabiProtect, color="#a8c87a"},
		
		{key = "切割伤害：", value = itemDef.mSpecialHolyDam, color="#a8c87a"},
		{key = "冰冻概率：", value = itemDef.mSpecialBingdong_prob, color="#f8a14a"},
		{key = "冰冻持续时间：", value = itemDef.mSpecialBingdong_dura, color="#a8c87a"},
		{key = "施毒概率：", value = itemDef.mSpecialShidu_prob, color="#8c3936"},
		{key = "施毒持续时间：", value = itemDef.mSpecialShidu_dura, color="#d2ee64"},
		{key = "冰冻防护概率：", value = itemDef.mSpecialBingdongProtect, color="#faa74c"},
		{key = "施毒防护概率：", value = itemDef.mSpecialShiduProtect, color="#f8a14a"},
		{key = "攻速提升：", value = itemDef.mSpecialAttackSpeed, color="#f8a14a"},
		
		--{key = "物理攻击：", value = {min = uid.mDC, max = uid.mDCMax}},
		--{key = "魔法攻击：", value = {min = uid.mMC, max = uid.mMCMax}},
		--{key = "道士攻击：", value = {min = uid.mSC, max = uid.mSCMax}},
		--{key = "物理防御：", value = {min = uid.mAC, max = uid.mACMax}},
		--{key = "魔法防御：", value = {min = uid.mMAC, max = uid.mMACMax}},
		
	}

	--for i,v in ipairs(activeAttrs) do
		--if v.value.max > MIN_VALUE then
		--	str = str..v.key
		--	if v.value and v.value.max > 0 then
		--		str = str.."<font color=#BC813A> 强化+"..mUpdLevel.."("..v.value.min.."-"..v.value.max..")</font>"
		--	end
		--	str = str.."<br>"
		--end
	--	if v.value~=nil and tonumber(v.value) > MIN_VALUE then
	--		if string.find(v.key,"率") ~= nil or string.find(v.key,"例") ~= nil or string.find(v.key,"提升") ~= nil or string.find(v.key,"下降") ~= nil then
	--			v.value = (v.value / 100).."%"
	--		end
	--		if string.find(v.key,"倍数") ~= nil and v.value~=0 then
	--			v.value = (v.value / 10000)..""
	--		end
	--		if v.color~= nil and v.color~= "" then
	--			str = str.."<font color="..v.color..">"..v.key..v.value.."</font><br>"
	--		else
	--			str = str..v.key..v.value.."<br>"
	--		end
	--	end
	--end
	--str =  "<font color=#B2A58B>"..str.."</font>"
	--return str
	
	local str = ""
	--GameUtilSenior.print_table(activeAttrs)
	for i,v in ipairs(activeAttrs) do
		if GameUtilSenior.isTable(v.value) then
			if v.value.max > MIN_VALUE then
				if v.color~= nil and v.color~= "" then
					str = str.."<td color="..v.color.." size=16 width=35 ht=0>"..v.key.."</td><td color="..v.color.." size=16 width=64 ht=0>"..v.value.min.."-"..v.value.max.."</td>"
				else
					str = str.."<td size=16 width=35 ht=0>"..v.key.."</td><td size=16 width=64 ht=0>"..v.value.min.."-"..v.value.max.."</td>"
				end
				str = str.."<br>"
			end
		elseif v.value~=nil and v.value > MIN_VALUE then
			--if string.find(v.key,"率") ~= nil or string.find(v.key,"例") ~= nil then
			--	v.value = (v.value / 100).."%"
			--end
			--if v.color~= nil and v.color~= "" then
			--	str = str.."<font color="..v.color..">"..v.key..v.value.."</font><br>"
			--else
			--	str = str..v.key..v.value.."<br>"
			--end
			
			if string.find(v.key,"率") ~= nil or string.find(v.key,"例") ~= nil or string.find(v.key,"提升") ~= nil or string.find(v.key,"下降") ~= nil then
				v.value = (v.value / 100).."%"
			end
			if string.find(v.key,"倍数") ~= nil and v.value~=0 then
				v.value = (v.value / 10000)..""
			end
			if v.color~= nil and v.color~= "" then
				str = str.."<td color="..v.color.." size=16 width=35 ht=0>"..v.key.."</td><td color="..v.color.." size=16 width=64 ht=0>"..v.value.."</td><br>"
			else
				str = str.."<td color="..v.color.." size=16 width=35 ht=0>"..v.key.."</td><td color="..v.color.." size=16 width=64 ht=0>"..v.value.."</td><br>"
			end
		end
	end
	if str~="" then
		str = "<font color=#B2A58B>"..str.."</font>"
	end
	return str
end

-- 装备tips回收收益
local function buildAdditionalInfo(itemDef)
	local str = ""
	if itemDef.mRecycleExp > 0 then
		str = "回收可获得："..itemDef.mRecycleExp.."经验<br>"
	end
	if itemDef.mRecycleXuefu > 0 then
		if str == "" then
			str = "回收可获得："..itemDef.mRecycleXuefu.."玉佩<br>"
		else
			str = str.."                   "..itemDef.mRecycleXuefu.."玉佩<br>"
		end
	end
	if itemDef.mEquipContribute > 0 then
		str = str.."捐献帮会可获得："..itemDef.mEquipContribute.."贡献值"
	end
	str = "<font color=#88BD07>"..str.."</font>"
	return str
end

local function updateEquipUpdStar(xmlTips)
	local mUpdLevel = xmlTips.mUpdLevel
	local imgUpgradeStar
	local starLight = "img_star_light"
	local starGray = "img_star_gray"
	if mUpdLevel and mUpdLevel > 10 then
		starLight = "img_yang_light"
		starGray = "img_yang_gray"
		mUpdLevel = mUpdLevel - 10
	end
	for i=1,10 do
		imgUpgradeStar = xmlTips:getWidgetByName("img_upgrade_star"..i)
		if mUpdLevel and i <= mUpdLevel then
			imgUpgradeStar:loadTexture(starLight, ccui.TextureResType.plistType)
		else
			imgUpgradeStar:loadTexture(starGray, ccui.TextureResType.plistType)
		end
	end
end

-- 装备tips刷新函数 
local function updateEquipTips(xmlTips)
	local netItem = xmlTips.netItem
	local itemDef = xmlTips.itemDef
	xmlTips:getWidgetByName("lbl_bind"):setString("")
	xmlTips:getWidgetByName("img_equip_state"):hide()

	xmlTips:getWidgetByName("lbl_upd_level"):setString("")
	if (xmlTips.mUpdLevel and xmlTips.mUpdLevel > 0) then
		xmlTips:getWidgetByName("lbl_upd_level"):setString("+"..xmlTips.mUpdLevel)
	end

	if netItem then
		if netItem.position < 0 then
			xmlTips:getWidgetByName("img_equip_state"):show()
		else
			xmlTips:getWidgetByName("img_equip_state"):hide()
		end
	end

	if GameBaseLogic.IsViceEquipment(nil, itemDef) and GameBaseLogic.IsFurnaceEquipment(nil, itemDef) then
		xmlTips:getWidgetByName("lbl_upgrade_pre"):hide()
		xmlTips:getWidgetByName("box_upgrade_bg"):hide()
	else
		xmlTips:getWidgetByName("lbl_upgrade_pre"):show()
		xmlTips:getWidgetByName("box_upgrade_bg"):show()
		updateEquipUpdStar(xmlTips)
	end

	if itemDef then
		-- 职业 lbl_job
		local lblJob = xmlTips:getWidgetByName("lbl_job")
		if itemDef.mJob ~= 0 then
			if itemDef.mJob == GameConst.JOB_ZS then
				lblJob:setString(GameConst.str_zs)
			elseif itemDef.mJob == GameConst.JOB_FS then
				lblJob:setString(GameConst.str_fs)
			elseif itemDef.mJob == GameConst.JOB_DS then
				lblJob:setString(GameConst.str_ds)
			end
			if itemDef.mJob == GameCharacter._mainAvatar:NetAttr(GameConst.net_job) then
				lblJob:setColor(cc.c3b(48,255,0))
			else
				lblJob:setColor(cc.c3b(255,0,0))
			end
		else
			lblJob:setString("通用")
			lblJob:setColor(cc.c3b(48,255,0))
		end

		-- 性别 lbl_gender
		local lblGender = xmlTips:getWidgetByName("lbl_gender")
		if itemDef.mGender ~= 0 then
			if itemDef.mGender == GameConst.GENDER_MALE then
				lblGender:setString(GameConst.str_male)
			elseif itemDef.mGender == GameConst.GENDER_FEMALE then
				lblGender:setString(GameConst.str_female)
			end
			if itemDef.mGender == GameCharacter._mainAvatar:NetAttr(GameConst.net_gender) then
				lblGender:setColor(cc.c3b(48,255,0))
			else
				lblGender:setColor(cc.c3b(255,0,0))
			end
		else
			lblGender:setString("通用")
			lblGender:setColor(cc.c3b(48,255,0))
		end
		-- 基础属性
		local listBaseAttr = xmlTips:getWidgetByName("list_base_attr")
		local size = listBaseAttr:getInnerContainerSize()
		local richLabelBaseAttr = xmlTips:getWidgetByName("richLabel_base_attr")
		local strBaseAttr = buildEquipBaseAttr(itemDef, xmlTips)
		richLabelBaseAttr:setRichLabel(strBaseAttr, "tips_base_attr", 14)
		listBaseAttr:requestDoLayout()
		
		--物品介绍
		--print(itemDef.mDesp)
		if itemDef.mDesp==nil or itemDef.mDesp=="" then
			xmlTips:getWidgetByName("desp_tips_bg"):setVisible(false)
		else
			xmlTips:getWidgetByName("desp_tips_bg"):setVisible(false)
			local list_desp = xmlTips:getWidgetByName("list_desp")
			local list_desp_size = list_desp:getInnerContainerSize()
			local richLabelDesp = xmlTips:getWidgetByName("richLabel_desp")
			richLabelDesp:setRichLabel(itemDef.mDesp, "list_desp", 14)
			list_desp:requestDoLayout()
		end


		--套装介绍
		if itemDef.mSource==nil or itemDef.mSource=="" or string.len(itemDef.mSource)<10 then
			xmlTips:getWidgetByName("suit_tips_bg"):setVisible(false)
		else
			xmlTips:getWidgetByName("suit_tips_bg"):setVisible(false)
			local list_suit = xmlTips:getWidgetByName("list_suit")
			local list_suit_size = list_suit:getInnerContainerSize()
			local richLabelSuit = xmlTips:getWidgetByName("richLabel_suit")
			richLabelSuit:setRichLabel(itemDef.mSource, "list_suit", 14)
			list_suit:requestDoLayout()
		end
		
		-- local imgTipsLine2 = xmlTips:getWidgetByName("img_tips_line2")
		-- local lblUpdPre = xmlTips:getWidgetByName("lbl_upd_pre")
		-- local listUpdAttr = xmlTips:getWidgetByName("list_upd_attr")
		-- local listAdditionalInfo = xmlTips:getWidgetByName("list_additional_info")
		-- local imgTipsLine3 = xmlTips:getWidgetByName("img_tips_line3")

		--if not GameBaseLogic.IsViceEquipment(nil, itemDef) then
		--强化显示属性修改成元素
		local strActiveAttr = buildEquipActivateAttr(netItem)
		--print("strActiveAttr",strActiveAttr)
		if strActiveAttr~="" then
			xmlTips:getWidgetByName("tips_bg"):setContentSize(409, 553):pos(0, 0)
			xmlTips:getWidgetByName("box_other"):show()
			xmlTips:getWidgetByName("box_base"):pos(0, 240)

			--xmlTips:getWidgetByName("img_tips_line1"):setPositionY(156) --126
			--xmlTips:getWidgetByName("lbl_desp_pre"):setPositionY(111) --111
			--xmlTips:getWidgetByName("list_base_attr"):setPositionY(85) --85
			--xmlTips:getWidgetByName("list_base_attr"):setContentSize(340, 125)

			local strAdditionalInfo = buildAdditionalInfo(itemDef)
			local listAdditionalInfo = xmlTips:getWidgetByName("list_additional_info")
			size = listAdditionalInfo:getInnerContainerSize()
			local richLabelAdditionalInfo = xmlTips:getWidgetByName("richLabel_additional_info")
			richLabelAdditionalInfo:setRichLabel(strAdditionalInfo, "tips_additional", 16)
			listAdditionalInfo:requestDoLayout()
			
			-- 强化可激活
			local listUpdAttr = xmlTips:getWidgetByName("list_upd_attr")
			size = listUpdAttr:getInnerContainerSize()
			local richLabelUpdAttr = xmlTips:getWidgetByName("richLabel_upd_attr")
			--local strActiveAttr = buildEquipActivateAttr(netItem)
			richLabelUpdAttr:setRichLabel(strActiveAttr, "tips_upd_attr", 16)
			listUpdAttr:requestDoLayout()
		else
			xmlTips:getWidgetByName("tips_bg"):setContentSize(409, 553):pos(0, 0)
			xmlTips:getWidgetByName("box_other"):hide()
			xmlTips:getWidgetByName("box_base"):pos(0, 240)
			
			--xmlTips:getWidgetByName("img_tips_line1"):setPositionY(156) --126
			--xmlTips:getWidgetByName("lbl_desp_pre"):setPositionY(111) --111
			--xmlTips:getWidgetByName("list_base_attr"):setPositionY(85) --85
			--xmlTips:getWidgetByName("list_base_attr"):setContentSize(340, 190)
		end
		--else
		--	xmlTips:getWidgetByName("tips_bg"):setContentSize(409, 313):pos(0, 120)
		--	xmlTips:getWidgetByName("box_other"):hide()
		--	xmlTips:getWidgetByName("box_base"):pos(0, 0)

		--	if GameBaseLogic.IsFurnaceEquipment(nil, itemDef) then
		--		xmlTips:getWidgetByName("img_tips_line1"):setPositionY(167) --126
		--		xmlTips:getWidgetByName("lbl_desp_pre"):setPositionY(131) --111
		--		xmlTips:getWidgetByName("list_base_attr"):setPositionY(110) --85
		--	else
		--		xmlTips:getWidgetByName("img_tips_line1"):setPositionY(146) --126
		--		xmlTips:getWidgetByName("lbl_desp_pre"):setPositionY(131) --111
		--		xmlTips:getWidgetByName("list_base_attr"):setPositionY(105) --85
		--	end

		--end
	end
end

-- 刷新tips按钮列表
local function updateTipsButtons(xmlTips)
	
	local listButtons = xmlTips:getWidgetByName("list_buttons")
	listButtons:removeAllItems()

	local tipsTag = getTipsTag(xmlTips)
	local conf = buttonsConfig[tipsTag]
	local btnTipsUse = xmlTips:getWidgetByName("btn_tips_use")
	btnTipsUse.useType = USE_TYPE.NULL
	local btnTipsMore = xmlTips:getWidgetByName("btn_tips_more")
	if conf then
		if conf.useTitle then
			btnTipsUse:setTitleText(conf.useTitle):show()
			btnTipsUse.useType = conf.useType or USE_TYPE.NULL
		else
			btnTipsUse:hide()
			btnTipsUse.useType = USE_TYPE.NULL
		end

		if conf.more then
			local btnName
			for i,v in ipairs(conf.more) do
				btnTips = btnTipsUse:clone()
				btnName = title2Name[v] or "btn_tips_default"
				btnTips:setName(btnName)
				btnTips:setTitleText(v)
				btnTips:setScale9Enabled(true)
				local contsize = btnTipsMore:getContentSize()
				btnTips:setContentSize(cc.size(contsize.width,contsize.height))
				listButtons:pushBackCustomItem(btnTips)
				GUIFocusPoint.addUIPoint(btnTips, pushTipsButtons)
				btnTips.xmlTips = xmlTips
			end
			btnTipsMore:show()
			-- local innerSize = listButtons:getInnerContainerSize()
			local pSize = listButtons:getContentSize()
			local pMargin = listButtons:getItemsMargin()
			pSize.height = (42 + pMargin) * #conf.more - pMargin
			-- if innerSize.height > 
			listButtons:setContentSize(pSize)
		else
			btnTipsMore:hide()
		end
	else
		btnTipsUse:hide()
		btnTipsMore:hide()
	end
end

-- tips刷新函数 
local function updateTips(xmlTips, betterState,compare)
	--装备名字归位
	if xmlTips:getWidgetByName("lbl_name_type") then
		xmlTips:getWidgetByName("lbl_name_type"):setString("")
		xmlTips:getWidgetByName("lbl_name"):setPositionX(13)
	end
	if xmlTips.typeId then
		local netItem = xmlTips.netItem
		--非自己的物品操作按钮不显示
		if xmlTips:getWidgetByName("box_buttons") then
			xmlTips:getWidgetByName("box_buttons"):setVisible(netItem and true or false)
			if xmlTips.enmuPos == 5 then
				xmlTips:getWidgetByName("box_buttons"):show()
			end
		end
		
		xmlTips:getWidgetByName("lbl_bind"):setString("")
		if netItem then
			if bit.band(netItem.mItemFlags, GameConst.ITEM_FLAG_BIND) > 0 then
				xmlTips:getWidgetByName("lbl_bind"):setString("已绑定")
			else
				xmlTips:getWidgetByName("lbl_bind"):setString("未绑定")
			end
		end

		local betteFlag
		local worseFlag
		if betterState == nil or betterState == GameConst.ITEM_UNUSE_SELF or betterState == GameConst.ITEM_UNUSE_SELF then
			betteFlag = false
			worseFlag = false
		elseif betterState == GameConst.ITEM_BETTER_SELF then
			betteFlag = true
			worseFlag = false
		elseif betterState == GameConst.ITEM_WORSE_SELF then
			betteFlag = false
			worseFlag = true
		end
		local img_better_flag = xmlTips:getWidgetByName("img_better_flag")
		local img_worse_flag = xmlTips:getWidgetByName("img_worse_flag")
		if img_better_flag and img_worse_flag then
			img_better_flag:hide()--:setVisible(betteFlag)
			img_worse_flag:hide()--:setVisible(worseFlag)
		end

		updateTipsIcon(xmlTips)
		updateBasicInfo(xmlTips)
		
		if not compare then
			updateTipsButtons(xmlTips)
		end

		if GameBaseLogic.IsEquipment(xmlTips.typeId) then
			updateEquipTips(xmlTips)
		else
			updatePropsTips(xmlTips)
		end
	end
end

local function addComparetips(xmlTips, typeId, itemPos, param)
	local showTable = {
		GameConst.EQUIP_TYPE_WEAPON,
		GameConst.EQUIP_TYPE_CLOTH,
		GameConst.EQUIP_TYPE_HAT,
		GameConst.EQUIP_TYPE_NICKLACE,
		GameConst.EQUIP_TYPE_GLOVE,
		GameConst.EQUIP_TYPE_RING,
		GameConst.EQUIP_TYPE_BELT,
		GameConst.EQUIP_TYPE_BOOT,
		GameConst.EQUIP_TYPE_MIRROR_ARMOUR,
		GameConst.EQUIP_TYPE_DRAGON_BONE,
		GameConst.EQUIP_TYPE_FACE_CLOTH,
		GameConst.EQUIP_TYPE_CATILLA,
		GameConst.EQUIP_TYPE_XUEFU,
		GameConst.EQUIP_TYPE_FABAO,
		GameConst.EQUIP_TYPE_LINGFU,
		GameConst.EQUIP_TYPE_YINGHUN,
		GameConst.EQUIP_TYPE_BAODING,
		GameConst.EQUIP_TYPE_ZHANQI,
		GameConst.EQUIP_TYPE_SHOUHU,
		GameConst.EQUIP_TYPE_ZHANDUN,
		GameConst.EQUIP_TYPE_ZHUZHUANGPLUS1,
		GameConst.EQUIP_TYPE_ZHUZHUANGPLUS2,
		GameConst.EQUIP_TYPE_FUZHUANGPLUS1,
		GameConst.EQUIP_TYPE_FUZHUANGPLUS2,
		GameConst.EQUIP_TYPE_FUZHUANGPLUS3
	}
	local itemDef = GameSocket:getItemDefByID(typeId)
	local equipType = itemDef.mEquipType
	-- print("addComparetips", equipType, table.indexof(showTable, equipType))
	local index = table.indexof(showTable, equipType)
	if not (index and index > 0) then
		return
	end

	local pos = -2 * equipType
	local selfEquip = GameSocket:getNetItem(pos)
	if selfEquip then
		if GameBaseLogic.IsRing(selfEquip.mTypeID) or GameBaseLogic.IsGlove(selfEquip.mTypeID) then
			local other = GameSocket:getNetItem(pos - 1)
			if other then
				if GameSocket:getItemDefByID(other.mTypeID).mNeedParam > GameSocket:getItemDefByID(selfEquip.mTypeID).mNeedParam then
					selfEquip = other
				end
			end
		end

		local selfEquipDef = GameSocket:getItemDefByID(selfEquip.mTypeID)
		local betterState = GameBaseLogic.CompareItem(itemPos, pos, itemDef)
		if betterState ~= GameConst.ITEM_UNUSE_SELF then
			local selfEquiptip = newTips(selfEquip.mTypeID,true)
			if selfEquiptip then
				selfEquiptip:addTo(xmlTips):pos(-selfEquiptip:getContentSize().width, 0):setName("selfEquiptip")

				selfEquiptip.netItem = selfEquip
				selfEquiptip.itemDef = selfEquipDef
				selfEquiptip.itemPos = pos
				selfEquiptip.typeId = selfEquip.mTypeID
				selfEquiptip.tipsType = param.tipsType
				selfEquiptip.mUpdLevel = selfEquip.mLevel
				updateTips(selfEquiptip,nil,true)
				if selfEquiptip:getWidgetByName("box_buttons") then
					selfEquiptip:getWidgetByName("box_buttons"):hide()
				end
			end
		end
		return betterState
	end
end

-- 暴露给外部使用函数
function GUIFloatTips.showTips(param)
	local xmlTips
	local itemPos = param.itemPos
	local typeId = param.typeId
	local mUpdLevel = param.mUpdLevel
	local netItem = GameSocket:getNetItem(itemPos)
	if netItem then 
		typeId = netItem.mTypeID
		mUpdLevel = netItem.mLevel
	elseif param.mLevel then
		mUpdLevel = param.mLevel --外部传值
	end
	if typeId then
		local itemDef = GameSocket:getItemDefByID(typeId)
		if itemDef then
			xmlTips = param.tips or newTips(typeId,false)
			if xmlTips then
				xmlTips.netItem = netItem
				xmlTips.itemDef = itemDef
				xmlTips.itemPos = itemPos
				xmlTips.typeId = typeId
				xmlTips.tipsType = param.tipsType
				xmlTips.mUpdLevel = mUpdLevel
				xmlTips.customCallFunc = param.customCallFunc
				xmlTips.destoryCallFunc = param.destoryCallFunc
				xmlTips.enmuPos = param.enmuPos
				xmlTips.enmuItemType = param.enmuItemType

				xmlTips:removeChildByName("selfEquiptip")
				local betterState
				if param.compare then
					betterState = addComparetips(xmlTips, typeId, itemPos, param)
				end
				
				updateTips(xmlTips, betterState,compare)
				local btnTipsMore = xmlTips:getWidgetByName("btn_tips_more")
				btnTipsMore.xmlTips = xmlTips
				handleButtonsListVisible(btnTipsMore, false)
			end
		end
	end
	return xmlTips
end
