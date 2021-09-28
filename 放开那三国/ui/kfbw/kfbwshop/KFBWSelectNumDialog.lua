-- FileName: KFBWSelectNumDialog.lua
-- Author: shengyixian
-- Date: 2015-09-30
-- Purpose: 跨服比武商店选择数量对话框
require "script/utils/SelectNumDialog"

KFBWSelectNumDialog = class("KFBWSelectNumDialog",function ( ... )
	-- body
	return SelectNumDialog:create()
end)

KFBWSelectNumDialog.__index = KFBWSelectNumDialog
-- 需要的跨服荣誉值文本
local _honorLabel = nil
-- 名望值文本
local _prestigeLabel = nil
-- 金币文本
local _goldLabel = nil
-- 银币文本
local _silverLabel = nil
-- 武将精华文本
local _heroJhLabel = nil

local _itemInfo = nil

function KFBWSelectNumDialog:ctor()
	self:setMinNum(1)
	self:initCallBack()
end
--[[
	@des 	: 初始化视图
	@param 	: 
	@return : 
--]]
function KFBWSelectNumDialog:initView( ... )
	local size = self:getContentSize()
	local nameLabelHeight = size.height*0.7
	self:setTitle(GetLocalizeStringBy("lcyx_1910"))
    -- 商品名称
    local itemInfo = ItemUtil.getItemsDataByStr(_itemInfo.items)[1]
    local icon,nameStr,nameColor = ItemUtil.createGoodsIcon(itemInfo,-665,1234,nil,nil,nil,false,false)
	local goodNameLabel = CCRenderLabel:create(nameStr,g_sFontPangWa,33,1,ccc3(0,0x00,0x00))
	goodNameLabel:setColor(nameColor)
	goodNameLabel:setAnchorPoint(ccp(0.5,0.5))
	goodNameLabel:setPosition(ccp(size.width / 2,nameLabelHeight + 4))
	self:addChild(goodNameLabel)
	local goodLabelSize = goodNameLabel:getContentSize()
	-- “请选择兑换”
	local label = CCRenderLabel:create(GetLocalizeStringBy("key_1438"),g_sFontPangWa,24,1,ccc3(0,0x00,0x00))
	label:setColor(ccc3(0xff,0xff,0xff))
	label:setAnchorPoint(ccp(0.5,0.5))
	label:setPosition(ccp(goodNameLabel:getPositionX() - goodLabelSize.width / 2 - label:getContentSize().width / 2 - 8,nameLabelHeight))
	self:addChild(label)
	-- "的数量"
	local label2 = CCRenderLabel:create(GetLocalizeStringBy("key_2518"),g_sFontPangWa,24,1,ccc3(0,0x00,0x00))
	label2:setColor(ccc3(0xff,0xff,0xff))
	label2:setAnchorPoint(ccp(0.5,0.5))
	label2:setPosition(ccp(goodNameLabel:getPositionX() + goodLabelSize.width / 2 + label2:getContentSize().width / 2 + 8,nameLabelHeight))
	self:addChild(label2)
	local labelPosAry = {ccp(size.width*0.5 - 100, size.height*0.3 + 9),
						 ccp(size.width * 0.5 - 100,size.height * 0.3 + 34)
						}
	-- 当前价格类型在配置中的索引
	local priceIndex = 1
	for i,v in ipairs(_itemInfo.priceAry) do
		if (v.type == "silver") then
			-- 需要的银币值文本
		    _silverLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1020",v.num), g_sFontBold,20, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
		    _silverLabel:setColor(ccc3( 0xff, 0xff, 0xff))
		    _silverLabel:setAnchorPoint(ccp(0,0))
		    _silverLabel:setPosition(labelPosAry[priceIndex].x, labelPosAry[priceIndex].y)
		    self:addChild(_silverLabel)
		elseif(v.type == "gold") then
			-- 需要的金币值文本
		    _goldLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1024",v.num), g_sFontBold,20, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
		    _goldLabel:setColor(ccc3( 0xff, 0xff, 0xff))
		    _goldLabel:setAnchorPoint(ccp(0,0))
		    _goldLabel:setPosition(labelPosAry[priceIndex].x, labelPosAry[priceIndex].y)
		    self:addChild(_goldLabel)
		elseif(v.type == "prestige") then
			--“声望”文本
			_prestigeLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1017",v.num),g_sFontBold, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		   	_prestigeLabel:setAnchorPoint(ccp(0,0))
		   	_prestigeLabel:setColor(ccc3(0xff, 0xff, 0xff))
		   	_prestigeLabel:setPosition(ccp(labelPosAry[priceIndex].x,labelPosAry[priceIndex].y))
		   	self:addChild(_prestigeLabel)
		elseif(v.type == "cross_honor") then
			-- 需要的跨服荣誉值文本
		    _honorLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1016",v.num), g_sFontBold,20, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
		    _honorLabel:setColor(ccc3( 0xff, 0xff, 0xff))
		    _honorLabel:setAnchorPoint(ccp(0,0))
		    _honorLabel:setPosition(labelPosAry[priceIndex].x, labelPosAry[priceIndex].y)
		    self:addChild(_honorLabel)
	    elseif(v.type == "jh") then
			-- 需要的武将精华值文本
		    _heroJhLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1055",v.num), g_sFontBold,20, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
		    _heroJhLabel:setColor(ccc3( 0xff, 0xff, 0xff))
		    _heroJhLabel:setAnchorPoint(ccp(0,0))
		    _heroJhLabel:setPosition(labelPosAry[priceIndex].x, labelPosAry[priceIndex].y)
		    self:addChild(_heroJhLabel)
		end
		priceIndex = priceIndex + 1
	end
end
--[[
	@des 	: 初始化各操作回调
	@param 	: 
	@return : 
--]]
function KFBWSelectNumDialog:initCallBack()
	-- body
	self:registerChangeCallback(function ( ... )
		-- body
		self:changeCallback()
	end)
	self:registerOkCallback(function ( ... )
		-- body
		self:okCallBack()
	end)
end

function KFBWSelectNumDialog:setItemInfo( itemInfo )
	-- body
	_itemInfo = itemInfo
	local maxNum = itemInfo.exchangeTimes
	for i,v in ipairs(_itemInfo.priceAry) do
		if (v.type == "silver") then
			-- 根据银币确定可兑换的最大数量
			if (v.num * maxNum > UserModel.getSilverNumber()) then
				maxNum = math.floor(UserModel.getSilverNumber() / v.num)
			end
		elseif(v.type == "gold") then
			-- 根据金币确定可兑换的最大数量
			if (v.num * maxNum > UserModel.getGoldNumber()) then
				maxNum = math.floor(UserModel.getGoldNumber() / v.num)
			end
		elseif(v.type == "prestige") then
			-- 根据声望确定可兑换的最大数量
			if (v.num * maxNum > UserModel.getPrestigeNum()) then
				maxNum = math.floor(UserModel.getPrestigeNum() / v.num)
			end
		elseif(v.type == "cross_honor") then
			-- 根据跨服荣誉确定可兑换的最大数量
			if (tonumber(v.num * maxNum) > tonumber(UserModel.getCrossHonor())) then
				maxNum = math.floor(UserModel.getCrossHonor() / v.num)
			end
		elseif(v.type == "jh") then
			-- 根据武将精华确定可兑换的最大数量
			if (tonumber(v.num * maxNum) > tonumber(UserModel.getHeroJh())) then
				maxNum = math.floor(UserModel.getHeroJh() / v.num)
			end
		end
	end
	if(maxNum > 50) then maxNum = 50 end
	self:setLimitNum(maxNum)
	self:initView()
end

function KFBWSelectNumDialog:changeCallback()
	for i,v in ipairs(_itemInfo.priceAry) do
		if (v.type == "silver") then
			_silverLabel:setString(GetLocalizeStringBy("syx_1020",self:getNum() * v.num))
		elseif (v.type == "gold") then
			_goldLabel:setString(GetLocalizeStringBy("syx_1024",self:getNum() * v.num))
		elseif (v.type == "prestige") then
			_prestigeLabel:setString(GetLocalizeStringBy("syx_1017",self:getNum() * v.num))
		elseif (v.type == "cross_honor") then
			_honorLabel:setString(GetLocalizeStringBy("syx_1016",self:getNum() * v.num))
		elseif (v.type == "jh") then
			_heroJhLabel:setString(GetLocalizeStringBy("syx_1055",self:getNum() * v.num))
		end
	end
end

function KFBWSelectNumDialog:okCallBack( ... )
	-- body
	require "script/ui/kfbw/kfbwshop/KFBWShopController"
	KFBWShopController.sureToExchange(_itemInfo,self:getNum())
end