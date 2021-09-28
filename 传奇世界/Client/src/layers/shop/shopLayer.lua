local g_shop_list = {}
local drugStoreSpeak={
	"救死扶伤，悬壶济世！",
	"人在江湖飘，哪能不卖药！",
	"年轻人，药不能停！",
}
return { new = function(params)
------------------------------------------------------------------------------------
local secondaryPass = require("src/layers/setting/SecondaryPassword")
if not secondaryPass.isSecPassChecked() then
	secondaryPass.inputPassword()
	return nil
end
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
local Mbaseboard = require "src/functional/baseboard"
local MMenuButton = require "src/component/button/MenuButton"
------------------------------------------------------------------------------------
local res = "res/layers/shop/"
------------------------------------------------------------------------------------
local params = params or {}
local shop = params.shop or 0
if shop == 0 and G_NO_OPEN_PAY then shop = 1 end
local isLayer = params.isLayer
dump(params, "params")
--dump(g_shop_list, "g_shop_list")
if g_shop_list[shop] then 
	removeFromParent(g_shop_list[shop])
	g_shop_list[shop] = nil
	--return 
end
------------------------------------------------------------------------------------
local addGoodsView = function(layer, storeId)
	local MGoodsView = require("src/layers/shop/GoodsView")
	local tv = MGoodsView.new({ storeId = storeId,  vSizeH = nil })
	Mnode.addChild(
	{
		parent = layer,
		child = tv,
		anchor = cc.p(0.5, 1),
		pos = cc.p(642, 533),
	})
	
	layer.tv = tv
end

-- 竞技场货币
local build_banggong = function(is_cross_server)
	-- 我的荣誉
	local honor = Mnode.createKVP(
	{
		k = Mnode.createLabel(
		{
			src = is_cross_server and (game.getStrByKey("my")..game.getStrByKey("feats").."：") or (game.getStrByKey("my")..game.getStrByKey("honor_s").."："),
			size = 20,
			color = MColor.lable_yellow,
		}),
		
		v = {
			src = "0",
			size = 20,
			color = MColor.lable_yellow,
		},
	})

	honor:setValue( is_cross_server and MRoleStruct:getAttr(PLAYER_MERITORIOUS) or MRoleStruct:getAttr(PLAYER_HONOUR) )
	------------------------------------------------------------------------------------
	local tmp = function(observable, attrId, objId, isMe, attrValue)
		if isMe then
			if (attrId == PLAYER_MERITORIOUS and is_cross_server) or (attrId == PLAYER_HONOUR and not is_cross_server) then
				honor:setValue(attrValue)
			end
		end
	end

	honor:registerScriptHandler(function(event)
		if event == "enter" then
			MRoleStruct:register(tmp)
		elseif event == "exit" then
			MRoleStruct:unregister(tmp)
		end
	end)
	
	return honor
end
----------------------------------------------------------------------------------------------
-- "元宝商城"
local yuanbao_store = game.getStrByKey("ingot")..game.getStrByKey("store")
-- "绑元商城"
local bangyuan_store = game.getStrByKey("bang_yuan_store")
-- "红包商城"
local hongbao_store = game.getStrByKey("dir_redbag")..game.getStrByKey("store")

-- "魂值商城"
local hunzhi_store = game.getStrByKey("soul_value")..game.getStrByKey("store")

-- "神秘商城"
local shenmi_store = game.getStrByKey("soul_value")..game.getStrByKey("store")

-- 帮派商城
local faction1_store = game.getStrByKey("faction")..game.getStrByKey("store")

-- 本服竞技场商城
local benfu_store = game.getStrByKey("this_server")..game.getStrByKey("jjc")..game.getStrByKey("store")

-- 跨服竞技场商城
local kuafu_store = game.getStrByKey("jjc")..game.getStrByKey("store")

-- 药品商城
local drug_store = game.getStrByKey("drug")..game.getStrByKey("store")

-- 书店商城
local book_store = game.getStrByKey("bookstore")..game.getStrByKey("store")

-- "限时商城"
local yunying_store = "限时商城"

local config = {
	[yuanbao_store] = {
		shop = 0,
		currency = { PLAYER_INGOT },
		build_act = function(root, layer)
			-- 货币
			-- Mnode.addChild(
			-- {
			-- 	parent = layer,
			-- 	child = Mcurrency.new(
			-- 	{
			-- 		cate = PLAYER_INGOT,
			-- 		--bg = "res/common/19.png",
			-- 		color = MColor.lable_yellow,
			-- 	}),
				
			-- 	anchor = cc.p(0, 0.5),
			-- 	pos = cc.p(35, 600),
			-- })
		end,
	},
	
	[bangyuan_store] = {
		shop = 1,
		currency = { PLAYER_BINDINGOT },
		build_act = function(root, layer)
			-- 货币
			-- Mnode.addChild(
			-- {
			-- 	parent = layer,
			-- 	child = Mcurrency.new(
			-- 	{
			-- 		cate = PLAYER_BINDINGOT,
			-- 		--bg = "res/common/19.png",
			-- 		color = MColor.lable_yellow,
			-- 	}),
				
			-- 	anchor = cc.p(0, 0.5),
			-- 	pos = cc.p(35, 600),
			-- })
		end,
	},
	
	[hongbao_store] = {
		shop = 12,
		build_act = function(root, layer)
			local jf = Mnode.createKVP(
			{
				k = Mnode.createLabel(
				{
					src = game.getStrByKey("shop_myScore"),
					size = 20,
					color = MColor.lable_yellow,
				}),
				
				v = {
					src = G_jifen,
					size = 20,
					color = MColor.lable_yellow,
				},
			})
			
			local CallFunc = cc.CallFunc:create(function(node)
				if type(node.setValue) == "function" then
					node:setValue(G_jifen)
				end
			end)
			local DelayTime = cc.DelayTime:create(1)
			local Sequence = cc.Sequence:create(CallFunc, DelayTime)
			local RepeatForever = cc.RepeatForever:create(Sequence)
			jf:runAction(RepeatForever)
			
			Mnode.addChild(
			{
				parent = layer,
				child = jf,
				
				anchor = cc.p(0, 0.5),
				pos = cc.p(35, 600),
			})
		end,
	},
	
	[hunzhi_store] = {
		shop = -2,
		currency = { PLAYER_SOUL_SCORE },
		build_act = function(root, layer)
			-- 刷新魂值商城
			MMenuButton.new(
			{
				parent = layer,
				src = {"res/component/button/50.png", "res/component/button/50_sel.png", "res/component/button/50_gray.png"},
				label = {
					src = game.getStrByKey("refresh"),
					size = 24,
					color = MColor.lable_yellow,
				},
				--effect = "b2s",
				cb = function(tag, node)
					local MConfirmBox = require "src/functional/ConfirmBox"
					local box = MConfirmBox.new(
					{
						handler = function(box)
							local MShopOp = require "src/layers/shop/ShopOp"
							local tv = root.layer.tv
							MShopOp:refreshMysteryStore(tv:getStoreId())
							if box then removeFromParent(box) box = nil end
						end,
						
						builder = function(box)
							local box_size = box:getContentSize()
							local tv = root.layer.tv
							local str = game.getStrByKey("consume_prefix_tips") .. tostring(tv:refreshIngotCost()) .. game.getStrByKey("ingot") .. "\n" .. game.getStrByKey("refresh_soul_shop_tips")
							Mnode.createLabel(
							{
								parent = box,
								src = str,
								color = MColor.lable_yellow,
								size = 20,
								pos = cc.p(box_size.width/2, 175),
							})
						end,
					})
				end,
				pos = cc.p(180, 75),
			})
			--[[
			-- 货币
			Mnode.addChild(
			{
				parent = layer,
				child = Mcurrency.new(
				{
					cate = PLAYER_SOUL_SCORE,
					--bg = "res/common/19.png",
					color = MColor.lable_yellow,
				}),
				
				anchor = cc.p(0, 0.5),
				pos = cc.p(70, 610),
			})
			]]
		end,
	},
	
	[shenmi_store] = {
		shop = -3,
		build_act = function(root, layer)
			-- 分隔线
			-- Mnode.createSprite(
			-- {
			-- 	parent = layer,
			-- 	src = "res/common/bg/bg51-1.png",
			-- 	pos = cc.p(642, 106),
			-- })
			-- 下次自动刷新
			local n_refresh_time = Mnode.createLabel(
			{
				src = "每日 12:00, 24:00 自动刷新",
				size = 18,
				color = MColor.lable_yellow,
			})
			
			Mnode.addChild(
			{
				parent = layer,
				child = n_refresh_time,
				anchor = cc.p(0, 0.5),
				pos = cc.p(570, 73),
			})
			
			-- 货币
			-- Mnode.addChild(
			-- {
			-- 	parent = layer,
			-- 	child = Mcurrency.new(
			-- 	{
			-- 		cate = PLAYER_SOUL_SCORE,
			-- 		--bg = "res/common/19.png",
			-- 		color = MColor.lable_yellow,
			-- 	}),
				
			-- 	anchor = cc.p(0, 0.5),
			-- 	pos = cc.p(35, 600),
			-- })
		end,
	},
	
	[faction1_store] = {
		shop = 5,
	},
	
	[benfu_store] = {
		shop = 11,
		build_act = function(root, layer)
			-- 货币
			-- Mnode.addChild(
			-- {
			-- 	parent = layer,
			-- 	child = build_banggong(false),
			-- 	anchor = cc.p(0, 0.5),
			-- 	pos = cc.p(70, 610),
			-- })
		end,
	},
	
	[kuafu_store] = {
		shop = 13,
		build_act = function(root, layer)
			-- 货币
			-- Mnode.addChild(
			-- {
			-- 	parent = layer,
			-- 	child = build_banggong(true),
			-- 	anchor = cc.p(0, 0.5),
			-- 	pos = cc.p(35, 600),
			-- })
		end,
	},
	
	[drug_store] = { -- 药品商城
		shop = 14,
		build_act = function(root, layer)
			-- 货币
			-- Mnode.addChild(
			-- {
			-- 	parent = layer,
			-- 	child = Mcurrency.new(
			-- 	{
			-- 		cate = PLAYER_MONEY,
			-- 		--bg = "res/common/19.png",
			-- 		color = MColor.lable_yellow,
			-- 	}),
				
			-- 	anchor = cc.p(0, 0.5),
			-- 	pos = cc.p(35, 600),
			-- })
		end,
	},
	
	[book_store] = { -- 书店商城
		shop = 19,
		build_act = function(root, layer)
			-- 货币
			-- Mnode.addChild(
			-- {
			-- 	parent = layer,
			-- 	child = Mcurrency.new(
			-- 	{
			-- 		cate = PLAYER_MONEY,
			-- 		--bg = "res/common/19.png",
			-- 		color = MColor.lable_yellow,
			-- 	}),
				
			-- 	anchor = cc.p(0, 0.5),
			-- 	pos = cc.p(35, 600),
			-- })
		end,
	},
	
	[yunying_store] = { -- 限时商城
		shop = 20,
		build_act = function(root, layer)
			-- 货币
			-- Mnode.addChild(
			-- {
			-- 	parent = layer,
			-- 	child = Mcurrency.new(
			-- 	{
			-- 		cate = PLAYER_INGOT,
			-- 		--bg = "res/common/19.png",
			-- 		color = MColor.lable_yellow,
			-- 	}),
				
			-- 	anchor = cc.p(0, 0.5),
			-- 	pos = cc.p(35, 600),
			-- })
			
			local DelayTime = cc.DelayTime:create(5)
			local CallFunc = cc.CallFunc:create(function(node)
				local MShopOp = require "src/layers/shop/ShopOp"
				--MShopOp:requestGoodsList(20)
			end)
			local Sequence = cc.Sequence:create(DelayTime, CallFunc)
			local RepeatForever = cc.RepeatForever:create(Sequence)
			layer:runAction(RepeatForever)
		end,
	},
}

local map = {}
for k, v in pairs(config) do
	map[v.shop] = k
end
------------------------------------------------------------------------------
local root = nil
if not isLayer then
	root = Mbaseboard.new(
	{
		src = "res/common/2.jpg",
		title = map[shop] ,
	})
else
	root = Mnode.createNode({ cSize = cc.size(960, 640) })
end
local rootSize = root:getContentSize()
------------------------------------------------------------------------------------
-- local bg = cc.Sprite:create("res/common/bg/bg-6.png")
-- local bg_size = bg:getContentSize()

-- Mnode.addChild(
-- {
-- 	parent = root,
-- 	child = bg,
-- 	pos = cc.p(rootSize.width/2, 288),
-- })

local uibar = createScale9Frame(
        root,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(33, 39),
        cc.size(754, 41),
        4
    )
uibar:setLocalZOrder(99)
local function openRaisePanel( ... )
	-- body
	__GotoTarget( { ru = "a33" } )
end

local btnRaise = createMenuItem( uibar , "res/component/button/49.png", cc.p(0,0), openRaisePanel )
btnRaise:setAnchorPoint(cc.p(0.5, 0.5))
btnRaise:setPosition(cc.p(830, 22))
local stSize = btnRaise:getContentSize()
local tfTitle = createLabel(btnRaise, "充值", cc.p(stSize.width/2 + 20, stSize.height/2), cc.p(0.5, 0.5), GetUiCfg().stFontSize.FirstTabsSize)
tfTitle:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)
createSprite(btnRaise, "res/group/currency/5.png", cc.p(stSize.width/2 - 30, stSize.height/2), cc.p(0.5, 0.5))
--货币显示
local Mcurrency = require "src/functional/currency"
local money_items = {
					[1] = Mcurrency.new(
					{
						cate = PLAYER_INGOT,
						color = MColor.white,
					}),					
					[2] = Mcurrency.new(
					{
						cate = PLAYER_BINDINGOT,
						color = MColor.white,
					}),
					[3] = Mcurrency.new(
					{
						cate = PLAYER_MONEY,
						color = MColor.white,
					})
				}
local item_margin = 60
if shop == -3 then
	item_margin = 20
	money_items={}
	money_items[#money_items+1] = Mcurrency.new(
					{
						cate = PLAYER_SOUL_SCORE,
						color = MColor.white,
					})
end
local uiGold = Mnode.combineNode(
			{
				nodes = money_items,
				margins = item_margin,
				orientation = "-"
			})

uibar:addChild(uiGold)
uiGold:setPosition(cc.p(5,5))
if shop == -3 then
	uiGold:setPosition(cc.p(550,5))
	Mnode.createLabel(
	{
		parent = uibar,
		src = "每天12点和24点熔炼商城自动刷新",
		color = MColor.white,
		size = 20,
		pos = cc.p(200, 22),
	})
end
-- local left_bg = cc.Sprite:create("res/common/bg/bg50.png")
-- local left_bg_size = left_bg:getContentSize()
local left_bg_size = cc.size(320, 450)
local left_bg = createScale9Frame(
        root,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(30, 90),
        left_bg_size,
        5
    )
--createScale9Sprite(root, "res/common/bg/bg50.png", cc.p(355, 315), left_bg_size, cc.p(1, 0.5))
-- Mnode.addChild(
-- {
-- 	parent = root,
-- 	child = left_bg,
-- 	anchor = cc.p(1, 0.5),
-- 	pos = cc.p(350+5, 286),
-- })

-- local right_bg = cc.Sprite:create("res/common/bg/bg51.png")
-- local right_bg_size = right_bg:getContentSize()
local right_bg_size = cc.size(570, 450)
local right_bg = createScale9Frame(
        root,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(358, 90),
        right_bg_size,
        5
    )
--createScale9Sprite(root, "res/common/bg/bg51.png", cc.p(358, 315), right_bg_size, cc.p(0, 0.5))
-- Mnode.addChild(
-- {
-- 	parent = root,
-- 	child = right_bg,
-- 	anchor = cc.p(0, 0.5),
-- 	pos = cc.p(350+8, 286),
-- })

-- 女主角
local strSprite = "res/mainui/npc_big_head/0-1.png"
local bTouchEnabled = true
local position=cc.p(left_bg_size.width/2, -15)
if shop == 14 then
	strSprite = "res/mainui/npc_big_head/10064.png"
	--bTouchEnabled = false
	position=cc.p(left_bg_size.width/2, 0)
end
local nvzhujiao = Mnode.createSprite(
{
	src = strSprite,
	parent = left_bg,
	anchor = cc.p(0.5, 0),
	pos = position,
})

local isSpeaking = false

local bubble = Mnode.createSprite(
{
	src = res.."bubble.png",
	parent = left_bg,
	anchor = cc.p(0.5, 1),
	pos = cc.p(left_bg_size.width/2, left_bg_size.height-5),
	opacity = 0,
})

local bubble_size = bubble:getContentSize()

local statement = Mnode.createLabel(
{
	src = "老板~~~，照顾下我的生意吧！",
	parent = bubble,
	size = 20,
	color = MColor.lable_yellow,
	pos = cc.p(bubble_size.width/2, bubble_size.height/2+12),
	hide = true,
})

local generate = function()
	-- local voiceTab = {}
	if shop == 14 then
		return drugStoreSpeak[math.random(1,#drugStoreSpeak)]
	end
	local tIdAsKey = getConfigItemByKey("scshb", "ID")
	local id = math.random(1,8)
	return tostring(tIdAsKey[id].nr), ("sounds/shopVoice/".. tostring(id) .. ".mp3")
end

local audio = nil
local function speak( ... )
	isSpeaking = true
	dump("speaking")
	
	-- 淡入
	local duration = 0.25
	local speakTime = 3
	local FadeIn = cc.FadeIn:create(duration)
	
	-- 说话
	statement:setVisible(true)
	local text, mp3 = generate()
	statement:setString(text)
	if mp3 then
		audio = AudioEnginer.playEffectOld(mp3, false)
	end
	local DelayTime = cc.DelayTime:create(speakTime)
	
	-- 淡出
	local FadeOut = cc.FadeOut:create(duration)
	
	local func = cc.CallFunc:create(function(node)
		statement:setVisible(false)
		isSpeaking = false
		--bubble:setOpacity(0)
	end)
	local final = cc.Sequence:create(FadeIn, DelayTime, FadeOut, func)
	bubble:runAction(final)
end
if bTouchEnabled then
	speak()
	Mnode.listenTouchEvent(
	{
		node = nvzhujiao,
		swallow = false,
		begin = function(touch, event)
			local node = event:getCurrentTarget()
			if node.catch then return false end
			
			local inside = Mnode.isTouchInNodeAABB(node, touch)
			if inside and not isSpeaking then
				node.catch = true
				speak()
				return true
			end
			
			return false
		end,
		
		ended = function(touch, event)
			local node = event:getCurrentTarget()
			node.catch = false
			
			--if Mnode.isTouchInNodeAABB(node, touch) then end
		end,
	})
end
------------------------------------------------------------------------------------
local overlay = function(layer)
	Mnode.addChild(
	{
		parent = root,
		child = layer,
		pos = cc.p(rootSize.width/2, rootSize.height/2),
		tag = 1,
	})
	
	root.layer = layer
end

local build_diff = function(node, config,title_str)
	local layer = root:getChildByTag(1)
	if layer then layer:removeFromParent() end
	local title_label = root:getChildByTag(12580)
	if title_label and title_str then title_label:setString(title_str) end
	local layer = Mnode.createNode({ cSize = cc.size(960, 640) })
	layer:registerScriptHandler(function(event)
		if event == "enter" then
			g_shop_list[config.shop] = root
			dump(g_shop_list, "g_shop_list")
		elseif event == "exit" then
			g_shop_list[config.shop] = nil
		end
	end)
	
	addGoodsView(layer, config.shop)
	local build_act = config.build_act
	if build_act then build_act(root, layer) end
	overlay(layer)					
end

local tabs = {}

if not params.title then
	if not G_NO_OPEN_PAY then
		tabs[#tabs+1] = yuanbao_store
	end
	tabs[#tabs+1] = bangyuan_store
	tabs[#tabs+1] = yunying_store
	--tabs[#tabs+1] = book_store
	--tabs[#tabs+1] = hongbao_store
	--tabs[#tabs+1] = hunzhi_store
	
	--tabs[#tabs+1] = drug_store
	
	--if G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn( NF_FURNACE )  then
		--tabs[#tabs+1] = shenmi_store
	--end
	--tabs[#tabs+1] = faction1_store
	--tabs[#tabs+1] = benfu_store
	--tabs[#tabs+1] = kuafu_store
else
	tabs[#tabs+1] = map[shop]
end

local TabControl = Mnode.createTabControl(
{
	src = {"res/common/TabControl/1.png", "res/common/TabControl/2.png"},
	size = 22,
	titles = tabs,
	margins = 2,
	ori = "|",
	align = "r",
	side_title = true,
	cb = function(node, tag)
		build_diff(node, config[tabs[tag]] ,tabs[tag])
	end,
	selected = map[shop],
})
--限时商城初始化时先隐藏，服务器返回有物品，才显示
local timeLimitShopIndex=nil
for k,v in pairs(tabs) do
	if v == yunying_store then
		timeLimitShopIndex=k
		break
	end
end
if timeLimitShopIndex then
	local timeLimitShop=TabControl:tabAtIdx(timeLimitShopIndex)
	if timeLimitShop then
	    timeLimitShop:setVisible(false)
	    local MShopOp = require "src/layers/shop/ShopOp"
	    MShopOp:requestGoodsList(20)
	    local dataSourceChanged = function(observable, event, data)
		    dump(event, "event")
		    if data.storeId ~= 20 then return end
		    if event == "store_list" then
			    if data and data.list and #data.list>0 then
	                timeLimitShop:setVisible(true)
	                if #tabs<=1 then TabControl:setVisible(false) end
	            end
		    end
	    end
		
	    timeLimitShop:registerScriptHandler(function(event)
		    if event == "enter" then
			    MShopOp:register(dataSourceChanged)
		    elseif event == "exit" then
			    MShopOp:unregister(dataSourceChanged)
		    end
	    end)
	end
end

local tab = TabControl:tabAtTitle(hongbao_store)
if tab then G_TUTO_NODE:setTouchNode(tab, TOUCH_SHOP_JIFEN) end

Mnode.addChild(
{
	parent = root,
	child = TabControl,
	anchor = cc.p(0, 0.0),
	pos = cc.p(931, 460),
})

if params.title or #tabs<=2 then TabControl:setVisible(false) end

root:registerScriptHandler(function(event)
	if event == "enter" then
		G_TUTO_NODE:setShowNode(root, SHOW_SHOP)
	elseif event == "exit" then
		if audio then
			AudioEnginer.stopEffect(audio)
	  		audio = nil
		end
        --为避免刚关闭就被刷新，在"关闭"熔炼商城时才消除熔炼界面的红点(不是打开时)
        if params.shop == -3 and params.title == true and G_RED_DOT_DATA.bool_shallShowSmelterRedDot then
            G_RED_DOT_DATA.bool_shallShowSmelterRedDot = false
            G_MAINSCENE:processEquipButtonRedDot()
            local childnode = G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP)
            if childnode then
                childnode = childnode:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BG)
                if childnode then
                    childnode = childnode:getChildByTag(require("src/config/CommDef").TAG_BUTTON_RONGLIAN)
                    if childnode then
                        childnode:removeChildByTag(require("src/config/CommDef").TAG_RED_DOT)
                    end
                end
            end

            childnode = G_MAINSCENE.base_node:getChildByTag(100 + require("src/config/CommDef").PARTIAL_TAG_SMELTER_DIALOG_TEMP)
            if childnode then
                childnode:getChildByTag(require("src/config/CommDef").TAG_SMELTER_NODE)
                if childnode then
                    childnode:getChildByTag(require("src/config/CommDef").TAG_SMELTER_RONGLIAN_SHOP_MENU)
                    if childnode then
                        childnode:getChildByTag(require("src/config/CommDef").TAG_SMELTER_RONGLIAN_SHOP_BTN)
                        if childnode then
                            childnode:removeChildByTag(require("src/config/CommDef").TAG_RED_DOT)
                        end
                    end
                end
            end
            
            g_msgHandlerInst:sendNetDataByTableEx(TRADE_CS_CHECK_NEW, "MallCheckNew", {mallType = 3, isClose = true})
        end
	end
end)
------------------------------------------------------------------------------------
return root
end }