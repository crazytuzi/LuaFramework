-- Filename：	MergeScrollView.lua
-- Author：		Zhang Zihang
-- Date：		2014-9-16
-- Purpose：		合服登录累积 & 合服充值回馈 奖励领取ScrollView
-- 				两个活动数据不同，界面几乎相同

module("MergeScrollView", package.seeall)

require "script/ui/mergeServer/accumulate/AccumulateData"
require "script/ui/mergeServer/accumulate/AccumulateService"
require "script/ui/item/ItemUtil"
require "script/ui/item/ReceiveReward"

local kLabelTag = 100 		--按钮描述文字tag
local _type

--[[
	@des 	:创建TableView
	@param 	:创建的TableView类型
			 1 登录累积 		2 充值回馈
	@return :创建好的tableView
--]]
function createScrollView(p_type)
	_type = p_type

	--tableView数量
	local tableNum
	--如果是登录累积
	if _type == 1 then
		tableNum = AccumulateData.getAccumulateNum()
	--如果是充值回馈
	else
		tableNum = AccumulateData.getRechargeNum()
	end

	local h = LuaEventHandler:create(function(fn,table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(605*g_fScaleX,220*g_fScaleX)
		elseif fn == "cellAtIndex" then
			a2 = createCell(tableNum - a1)
			a2:setScale(g_fScaleX)
			r = a2
		elseif fn == "numberOfCells" then
			r = tableNum
		else
			print("other function")
		end

		return r
	end)

	require "script/ui/mergeServer/accumulate/AccumulateActivity"

	return LuaTableView:createWithHandler(h, AccumulateActivity.getBgSize())
end

--[[
	@des 	:创建cell
	@param 	:a1+1值
	@return :创建好的cell
--]]
function createCell(p_tag)
	local tCell = CCTableViewCell:create()

	local bgSprite = CCScale9Sprite:create("images/common/bg/y_9s_bg.png")
	bgSprite:setPreferredSize(CCSizeMake(580,200))
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(605/2,110))
	tCell:addChild(bgSprite)

	if _type == 1 then
		local titleBgSprite = CCSprite:create("images/sign/sign_bottom.png")
		titleBgSprite:setAnchorPoint(ccp(0,1))
		titleBgSprite:setPosition(ccp(0,bgSprite:getContentSize().height))
		bgSprite:addChild(titleBgSprite)

		local titleLabel = CCRenderLabel:create(AccumulateData.getRewardName(p_tag),g_sFontPangWa,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
		titleLabel:setColor(ccc3(0xff,0xf6,0x00))
		titleLabel:setAnchorPoint(ccp(0,0.5))
		titleLabel:setPosition(ccp(30,titleBgSprite:getContentSize().height/2 + 5))
		titleBgSprite:addChild(titleLabel)
	else
		local tipLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1153") .. AccumulateData.getConfigRechargeNum(p_tag) .. GetLocalizeStringBy("zzh_1154") .. "(" .. AccumulateData.getMoneyNum() .. "/" .. AccumulateData.getConfigRechargeNum(p_tag) .. ")!",g_sFontPangWa,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
		tipLabel:setColor(ccc3(0xff,0xf6,0x00))
		tipLabel:setAnchorPoint(ccp(0,1))
		tipLabel:setPosition(ccp(10,bgSprite:getContentSize().height - 10))
		bgSprite:addChild(tipLabel)
	end

	--二级背景
	local scrollBgSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	scrollBgSprite:setPreferredSize(CCSizeMake(420,130))
	scrollBgSprite:setAnchorPoint(ccp(0,0))
	scrollBgSprite:setPosition(ccp(10,15))
	bgSprite:addChild(scrollBgSprite)

	local cellScrollView = createInnerView(p_tag)
	cellScrollView:setAnchorPoint(ccp(0,0))
	cellScrollView:setPosition(ccp(0,0))
	cellScrollView:setBounceable(true)
	cellScrollView:setDirection(kCCScrollViewDirectionHorizontal)
	cellScrollView:reloadData()
	cellScrollView:setTouchPriority(-550)
	scrollBgSprite:addChild(cellScrollView)

	local bgMenu = BTMenu:create()
	bgMenu:setPosition(ccp(0,0))
	bgSprite:addChild(bgMenu)

	--三态按钮
	local normalSprite  = CCSprite:create("images/level_reward/receive_btn_n.png")
    local selectSprite  = CCSprite:create("images/level_reward/receive_btn_h.png")
    local disabledSprite = BTGraySprite:create("images/level_reward/receive_btn_n.png")
    local getMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite,disabledSprite)
	getMenuItem:setAnchorPoint(ccp(0.5,0.5))
	getMenuItem:setPosition(ccp(bgSprite:getContentSize().width - 70,bgSprite:getContentSize().height/2))
	getMenuItem:registerScriptTapHandler(rewardCallBack)
	bgMenu:addChild(getMenuItem,1,p_tag)

	--得到当前奖励状态
	local rewardStatus = AccumulateData.getGotOrCan(_type,tonumber(p_tag))

	--按钮上面文字
	local itemLabel
	--如果已领取
	if rewardStatus == 1 then
		local fontStr = GetLocalizeStringBy("key_1369")
		itemLabel = CCRenderLabel:create(fontStr,g_sFontPangWa,35,1,ccc3(0x00, 0x00, 0x00),type_stroke)
		itemLabel:setColor(ccc3(0xf1,0xf1,0xf1))
		-- 按钮不可点，文字颜色置灰
		getMenuItem:setEnabled(false)
	--未领取
	else
		local fontStr = GetLocalizeStringBy("key_1085")
		itemLabel = CCRenderLabel:create(fontStr,g_sFontPangWa,35,1,ccc3(0x00, 0x00, 0x00),type_stroke)
		itemLabel:setColor(ccc3(0xfe,0xdb,0x1c))
		--资格不到，不可领取
		if rewardStatus == 3 then
			getMenuItem:setEnabled(false)
			itemLabel:setColor(ccc3(0xf1,0xf1,0xf1))
		end
	end

	--按钮上面文字添加到位置上
	itemLabel:setAnchorPoint(ccp(0.5,0.5))
	itemLabel:setPosition(ccp(getMenuItem:getContentSize().width*0.5,getMenuItem:getContentSize().height*0.5))
	getMenuItem:addChild(itemLabel,1,kLabelTag)

	return tCell
end

--[[
	@des 	:领奖回调
	@param 	:按钮tag值
	@return :
--]]
function rewardCallBack(tag,item)
	local rewardCallBack = function()
		--得到数值奖励
		AccumulateData.addReward(AccumulateData.getRewardInfo(_type,tag))
		--按钮置已领取
		item:setEnabled(false)
		
		tolua.cast(item:getChildByTag(kLabelTag),"CCRenderLabel"):setString(GetLocalizeStringBy("key_1369"))
		tolua.cast(item:getChildByTag(kLabelTag),"CCRenderLabel"):setColor(ccc3(0xf1,0xf1,0xf1))
		--更改缓存中按钮的状态
		AccumulateData.setButtomStatus(_type,tonumber(tag))

		--弹出恭喜您活动窗口
		ReceiveReward.showRewardWindow(AccumulateData.getRewardInfo(_type,tag))
	end 

	if not ItemUtil.isBagFull() then
		if _type == 1 then
			AccumulateService.getLoginReward(tag,rewardCallBack)
		else
			AccumulateService.getRechargeReward(tag,rewardCallBack)
		end
	end
end

--[[
	@des 	:得到内部TableView
	@param 	:下标
	@return :创建好的TableView
--]]
function createInnerView(p_index)
	local rewardTable = AccumulateData.getRewardInfo(_type,p_index)
	local tableNum = table.count(rewardTable)

	local h = LuaEventHandler:create(function(fn,table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(105,65)
		elseif fn == "cellAtIndex" then
			a2 = createInnerCell(rewardTable[a1+1])
			r = a2
		elseif fn == "numberOfCells" then
			r = tableNum
		else
			print("other function")
		end

		return r
	end)

	return LuaTableView:createWithHandler(h, CCSizeMake(420,130))
end

--[[
	@des 	:创建内部cell
	@param 	:当前奖励数据
	@return :创建好的内部cell
--]]
function createInnerCell(p_curData)
	local prizeViewCell = CCTableViewCell:create()

	local itemSprite = ItemUtil.createGoodsIcon(p_curData,nil,nil,nil,nil,true)
	itemSprite:setAnchorPoint(ccp(0.5,0.5))
	itemSprite:setPosition(ccp(105/2,65/2 + 40))
	prizeViewCell:addChild(itemSprite)

	return prizeViewCell
end