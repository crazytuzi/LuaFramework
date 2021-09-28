-- Filename：	RunPreviewTableView.lua
-- Author：		Zhang Zihang
-- Date：		2014-7-11
-- Purpose：		充值大放送礼包预览tableView

module("RunPreviewTableView", package.seeall)

require "script/ui/rechargeActive/rechargeBigRun/RechargeBigRunData"
require "script/ui/item/ReceiveReward"

--[[
	@des 	:创建礼包预览tableView
	@param 	:
	@return :创建好的tableView
--]]
function createPreviewTableView()
	local h = LuaEventHandler:create(function(fn,table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(130, 135)
		elseif fn == "cellAtIndex" then
			a2 = createShowGiftCell(a1)
			r = a2
		elseif fn == "numberOfCells" then
			r = RechargeBigRunData.getDayNum()
		else
			print("other function")
		end

		return r
	end)

	return LuaTableView:createWithHandler(h, CCSizeMake(520, 135))
end

--[[
	@des 	:创建Cell
	@param 	:tableView的a1值
	@return :tableViewCell
--]]
function createShowGiftCell(index)
	local prizeViewCell = CCTableViewCell:create()
	
	--金色边框
	local edgeSprite = CCSprite:create("images/everyday/headBg1.png")
	edgeSprite:setAnchorPoint(ccp(0.5,1))
	edgeSprite:setPosition(ccp(60,135))
	prizeViewCell:addChild(edgeSprite)

	--每个背景的按钮层
	local cellMenu = BTMenu:create()
	cellMenu:setPosition(ccp(0,0))
	edgeSprite:addChild(cellMenu)

	--按钮第二层
	local purpleItemImage = CCMenuItemImage:create("images/base/potential/props_5.png","images/base/potential/props_5.png")
	purpleItemImage:setAnchorPoint(ccp(0.5,0.5))
	purpleItemImage:setPosition(ccp(edgeSprite:getContentSize().width/2,edgeSprite:getContentSize().height/2))
	purpleItemImage:registerScriptTapHandler(previewCallBack)
	cellMenu:addChild(purpleItemImage,1,index+1)

	--礼包图片
	local giftSprite = CCSprite:create("images/recharge/tuan/3.png")
	giftSprite:setAnchorPoint(ccp(0.5,0.5))
	giftSprite:setPosition(ccp(purpleItemImage:getContentSize().width/2,purpleItemImage:getContentSize().height/2))
	purpleItemImage:addChild(giftSprite)
	
	--第XX天图片
	local dayNumSprite = CCSprite:create("images/recharge/rechargeBigRun/dayNum.png")
	dayNumSprite:setAnchorPoint(ccp(0.5,0))
	dayNumSprite:setPosition(ccp(60,0))
	prizeViewCell:addChild(dayNumSprite)

	--天数
	local dayNumLabel = CCLabelTTF:create(index+1,g_sFontPangWa,18)
	dayNumLabel:setColor(ccc3(0xff,0xff,0xff))
	dayNumLabel:setAnchorPoint(ccp(0.5,0.5))
	dayNumLabel:setPosition(ccp(dayNumSprite:getContentSize().width/2,dayNumSprite:getContentSize().height/2))
	dayNumSprite:addChild(dayNumLabel)

	return prizeViewCell
end

--[[
	@des 	:点击物品图标回调
	@param 	:礼包id
	@return :
--]]
function previewCallBack(tag)
	ReceiveReward.showRewardWindow(RechargeBigRunData.getDataByDay(tag),nil,nil,nil,GetLocalizeStringBy("key_3213"))
end