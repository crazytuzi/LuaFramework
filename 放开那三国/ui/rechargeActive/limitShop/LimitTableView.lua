-- Filename：	LimitTableView.lua
-- Author：		Zhang Zihang
-- Date：		2014-11-24
-- Purpose：		限时商店table view

module("LimitTableView", package.seeall)

require "script/utils/BaseUI"
require "script/model/user/UserModel"
require "script/ui/rechargeActive/limitShop/LimitShopData"
require "script/ui/rechargeActive/limitShop/LimitShopService"
require "script/ui/item/ReceiveReward"
require "script/ui/item/ItemUtil"
require "script/ui/tip/AnimationTip"
require "script/ui/tip/LackGoldTip"
require "script/ui/tip/TipByNode"
require "script/libs/LuaCC"

local kBuyNum = 100 		--剩余购买次数下标

--[[
	@des 	:购买回调
	@param 	: $ p_tag 		:tag值
	@param 	: $ p_item 		:按钮元素
--]]
function buyCallBack(p_tag,p_item)
	--vip等级
	local vipLevel = tonumber(UserModel.getVipLevel())
	--金币数
	local goldNum = tonumber(UserModel.getGoldNumber())

	--当前cell的信息
	local cellInfo = LimitShopData.getCurCellInfoById(p_tag)

	--活动已结束
	if LimitShopData.gameOverOrNot() then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1201"))
	--已刷新
	elseif LimitShopData.refreshOrNot() then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1202"))
	--如果无购买次数
	elseif LimitShopData.remainNum(p_tag) <= 0 then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1200"))
	--如果VIP等级不足
	elseif vipLevel < tonumber(cellInfo.VIPLimited) then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1199",cellInfo.VIPLimited))
	--如果没钱
	elseif goldNum < tonumber(cellInfo.NowCost) then
		LackGoldTip.showTip()
	--如果包满了
	elseif ItemUtil.isBagFull() then
		return
	--可以购买了
	else
		local buyOver = function(p_num)
			--减金币
			UserModel.addGoldNumber(tonumber(-cellInfo.NowCost)*p_num)

			--刷新数目
			local numLabel = tolua.cast(p_item:getChildByTag(kBuyNum),"CCRenderLabel")
			numLabel:setString(GetLocalizeStringBy("zzh_1196",LimitShopData.remainNum(p_tag)))

			local splitString = string.split(cellInfo.ItemID,"|")
			local newNum = tonumber(splitString[3])*p_num
			local newString = splitString[1] .. "|" .. splitString[2] .. "|" .. newNum
			--弹出奖励物品提示
			ReceiveReward.showRewardWindow(LimitShopData.getCurDayReward(newString),nil,nil,nil,nil)
		end

		--确定购买
		local sureCallBack = function(p_buyNum)
			if goldNum < tonumber(cellInfo.NowCost)*p_buyNum then
				LackGoldTip.showTip()
			else
				LimitShopService.buyGoods(buyOver,cellInfo.id,p_buyNum)
			end
		end

		local nameInfo = LimitShopData.getCurDayReward(cellInfo.ItemID)[1]
		local itemData = ItemUtil.getItemById(nameInfo.tid)

		require "script/ui/common/BatchExchangeLayer"
		local paramTable = {}
		paramTable.title = GetLocalizeStringBy("key_1745")
		paramTable.first = GetLocalizeStringBy("key_2853")
		paramTable.max = LimitShopData.remainNum(p_tag)
		paramTable.name = itemData.name
		paramTable.need = {{needName = GetLocalizeStringBy("zzh_1238"),
							sprite = "images/common/gold.png",
							price = cellInfo.NowCost}}
		BatchExchangeLayer.showBatchLayer(paramTable,sureCallBack)



		-- local localInfo = {}
		-- localInfo.localColor = ccc3(0x78,0x25,0x00)
		-- localInfo.localFontSize = 25
		-- localInfo.localLabelType = "label"
		-- localInfo.font = g_sFontName
		-- local paramTable = {
		-- 						{
		-- 							ntype = "image",
		-- 							image = "images/common/gold.png"
		-- 						},
								
		-- 						{
		-- 							ntype = "label",
		-- 							fontSize = 25,
		-- 							text = cellInfo.NowCost,
		-- 							color = ccc3(0x78,0x25,0x00)
		-- 						},
		-- 				   }
		-- local tipSprite_1 = GetLocalizeLabelSpriteBy("zzh_1203",localInfo,paramTable)
		-- tipSprite_1:setAnchorPoint(ccp(0.5,1))

		-- local localInfo = {}
		-- localInfo.localColor = ccc3(0x78,0x25,0x00)
		-- localInfo.localFontSize = 25
		-- localInfo.localLabelType = "label"
		-- localInfo.font = g_sFontName
		-- local paramTable = {
		-- 						{
		-- 							ntype = "strokeLabel",
		-- 							fontSize = 25,
		-- 							text = itemData.name,
		-- 							color = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
		-- 						}
		-- 				   }
		-- local tipSprite_2 = GetLocalizeLabelSpriteBy("zzh_1204",localInfo,paramTable)
		-- tipSprite_2:setAnchorPoint(ccp(0.5,0))

		-- local baseNode = CCNode:create()
		-- baseNode:setContentSize(CCSizeMake(520,tipSprite_1:getContentSize().height + tipSprite_2:getContentSize().height + 10))

		-- tipSprite_1:setPosition(ccp(260,baseNode:getContentSize().height))
		-- tipSprite_2:setPosition(ccp(260,0))
		-- baseNode:addChild(tipSprite_1)
		-- baseNode:addChild(tipSprite_2)

		-- TipByNode.showLayer(baseNode,sureCallBack)
	end
end

--[[
	@des 	:创建cell
	@param 	:a1
	@return :创建好的cell
--]]
function createCell(p_index)
	local tCell = CCTableViewCell:create()

	--cell背景
	local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(52,44,6,4)
	local cellBgSprite = CCScale9Sprite:create("images/common/bg/change_bg.png",fullRect, insetRect)
	cellBgSprite:setPreferredSize(CCSizeMake(615,195))
	cellBgSprite:setAnchorPoint(ccp(0,0))
	cellBgSprite:setPosition(ccp(15/2,2.5))
	tCell:addChild(cellBgSprite)

	--cell背景大小
	local cellBgSize = cellBgSprite:getContentSize()

	--当前cell的信息
	local cellInfo = LimitShopData.getCurCellInfoById(p_index)

	--标题背景
	local titleBgSprite = CCSprite:create("images/sign/sign_bottom.png")
	titleBgSprite:setAnchorPoint(ccp(0,1))
	titleBgSprite:setPosition(ccp(0,cellBgSize.height + 10))
	cellBgSprite:addChild(titleBgSprite)

	print("表中信息")
	print_t(cellInfo)

	--标题问题
	local titleLabel
	-- -- --如果没有周年庆
	-- if cellInfo.worddisplay == "" then
	-- 	titleLabel = CCRenderLabel:create(cellInfo.ItemTitle,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_shadow)
	-- 	titleLabel:setColor(ccc3(0xff,0xff,0xff))
	-- --有周年庆，但没有vip
	-- elseif cellInfo.VIPdisplay == "" then
	-- 	local happySprite = CCSprite:create("images/recharge/limit_shop/happy.png")
	-- 	local vipNumSprite = LuaCC.createNodeOfNumbers("images/main/vip",cellInfo.numdisplay,15)
	-- 	titleLabel = BaseUI.createHorizontalNode({happySprite,vipNumSprite})
	-- else
	-- 	local vipSprite = CCSprite:create("images/common/vip.png")
	-- 	local vipNumSprite = LuaCC.createNodeOfNumbers("images/main/vip",cellInfo.numdisplay,20)
	-- 	local happySprite = CCSprite:create("images/recharge/limit_shop/happy.png")
	-- 	titleLabel = BaseUI.createHorizontalNode({vipSprite,vipNumSprite,happySprite})
	-- end
	if cellInfo.picture == "" then
		titleLabel = CCRenderLabel:create(cellInfo.ItemTitle,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_shadow)
		titleLabel:setColor(HeroPublicLua.getCCColorByStarLevel(tonumber(cellInfo.color)))
	else
		titleLabel = CCSprite:create("images/recharge/limit_shop/title_pic/" .. cellInfo.picture)
	end

	titleLabel:setAnchorPoint(ccp(0,0.5))
	titleLabel:setPosition(ccp(30,titleBgSprite:getContentSize().height/2))
	titleBgSprite:addChild(titleLabel)

	--原价
	local localInfo = {}
	localInfo.localColor = ccc3(0xab,0xab,0xab)
	localInfo.localFontSize = 21
	localInfo.localLabelType = "strokeLabel"
	localInfo.font = g_sFontName
	local paramTable = {
							{
								ntype = "image",
								image = "images/common/gold.png"
							},

							{
								ntype = "strokeLabel",
								fontSize = 21,
								text = cellInfo.OriginalCost,
								color = ccc3(0xff,0xf6,0x00)
							}
					   }
	local oriSprite = GetLocalizeLabelSpriteBy("zzh_1192",localInfo,paramTable)
	oriSprite:setAnchorPoint(ccp(0,1))
	oriSprite:setPosition(ccp(260,cellBgSize.height - 15))
	cellBgSprite:addChild(oriSprite)

	--大减价
	local noSprite = CCSprite:create("images/recharge/limit_shop/no_more.png")
	noSprite:setAnchorPoint(ccp(0,0.5))
	noSprite:setPosition(ccp(-10,oriSprite:getContentSize().height/2))
	oriSprite:addChild(noSprite)

	--现价
	local localInfo = {}
	localInfo.localColor = ccc3(0xff,0xf6,0x00)
	localInfo.localFontSize = 21
	localInfo.localLabelType = "strokeLabel"
	localInfo.font = g_sFontName
	local paramTable = {
							{
								ntype = "image",
								image = "images/common/gold.png"
							},

							{
								ntype = "strokeLabel",
								fontSize = 21,
								text = cellInfo.NowCost,
								color = ccc3(0xff,0xf6,0x00)
							}
					   }
	local nowSprite = GetLocalizeLabelSpriteBy("zzh_1194",localInfo,paramTable)
	nowSprite:setAnchorPoint(ccp(0,1))
	nowSprite:setPosition(ccp(450,cellBgSize.height - 15))
	cellBgSprite:addChild(nowSprite)

	--menu层
	local cellMenu = BTMenu:create()
	cellMenu:setAnchorPoint(ccp(0,0))
	cellMenu:setPosition(ccp(0,0))
	cellBgSprite:addChild(cellMenu)

	--按钮
	local buyMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_shop_n.png","images/common/btn/btn_shop_h.png",CCSizeMake(145,80),GetLocalizeStringBy("zz_116"),ccc3(0xfe,0xdb,0x1c),35,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
	buyMenuItem:setAnchorPoint(ccp(1,1))
	buyMenuItem:setPosition(ccp(cellBgSize.width - 15,cellBgSize.height - 55))
	buyMenuItem:registerScriptTapHandler(buyCallBack)
	cellMenu:addChild(buyMenuItem,1,p_index)

	--服务端返回的信息
	local costNum = LimitShopData.getCostNum(cellInfo.id)

	--限购次数
	local banTimeLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1196",LimitShopData.remainNum(p_index)),g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	banTimeLabel:setColor(ccc3(0x00,0xe4,0xff))
	banTimeLabel:setAnchorPoint(ccp(0.5,1))
	banTimeLabel:setPosition(ccp(buyMenuItem:getContentSize().width/2,-5))
	buyMenuItem:addChild(banTimeLabel,1,kBuyNum)

	--二级背景
	local secBgSprite = CCScale9Sprite:create("images/common/s9_2.png")
	secBgSprite:setPreferredSize(CCSizeMake(430,125))
	secBgSprite:setAnchorPoint(ccp(0,0))
	secBgSprite:setPosition(ccp(20,20))
	cellBgSprite:addChild(secBgSprite)

	--二级背景大小
	local secBgSize = secBgSprite:getContentSize()

	--物品信息
	local itemInfo = LimitShopData.getCurDayReward(cellInfo.ItemID)

	--显示菜单栏回调
	local function showDownMenu()
		MainScene.setMainSceneViewsVisible(true,false,true)
	end

	--物品图和名称
	local itemSprite = ItemUtil.createGoodsIcon(itemInfo[1],nil,nil,nil,showDownMenu,nil,nil,false)
	itemSprite:setAnchorPoint(ccp(0,0.5))
	itemSprite:setPosition(ccp(20,secBgSize.height*0.5))
	secBgSprite:addChild(itemSprite)

	--热卖、折扣还是vip
	-- local itemTypeSprite = CCSprite:create("images/recharge/limit_shop/" .. cellInfo.ItemTips .. ".png")
	-- itemTypeSprite:setAnchorPoint(ccp(0,1))
	-- itemTypeSprite:setPosition(ccp(0,secBgSize.height))
	-- secBgSprite:addChild(itemTypeSprite)

	-- local typeSize = itemTypeSprite:getContentSize()

	--特效
	local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create(LimitShopData.getEffectPath(tonumber(cellInfo.ItemTips))), -1,CCString:create(""))
	spellEffectSprite:setPosition(ccp(40,secBgSize.height - 20))
    secBgSprite:addChild(spellEffectSprite)

    local animationEnd = function(actionName,xmlSprite)
    end

    local animationFrameChanged = function(frameIndex,xmlSprite)
    end

    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    
    spellEffectSprite:setDelegate(delegate)

	--物品描述
	local desLabel = CCLabelTTF:create(cellInfo.Itemdes,g_sFontName,20,CCSizeMake(265,0),kCCTextAlignmentLeft)
	desLabel:setColor(ccc3(0x78,0x25,0x00))
	desLabel:setAnchorPoint(ccp(0,0.5))
	desLabel:setPosition(ccp(130,secBgSize.height/2))
	secBgSprite:addChild(desLabel)

	return tCell
end

--[[
	@des 	:创建tableView
	@param 	:背景层大小
	@return :创建好的tableView
--]]
function createTableView(p_bgSize)
	local h = LuaEventHandler:create(function(fn,table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(620*g_fScaleX,215*g_fScaleX)
		elseif fn == "cellAtIndex" then
			a2 = createCell(LimitShopData.giftsNum() - a1)
			a2:setScale(g_fScaleX)
			r = a2
		elseif fn == "numberOfCells" then
			r = LimitShopData.giftsNum()
		end

		return r
	end)

	return LuaTableView:createWithHandler(h,p_bgSize)
end