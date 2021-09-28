-- FileName: KFBWRewardCell.lua 
-- Author: shengyixian
-- Date: 15-10-10
-- Purpose: 跨服比武奖励预览表单元

module("KFBWRewardCell", package.seeall)
local _touchPriority = -560

function create(data)
	-- body
	local cell = CCTableViewCell:create()
	local currData = data

	-- body
	-- 资源路径
	local imagePath = {
		bg = "images/reward/cell_back.png",
		titleBg = "images/sign/sign_bottom.png",
		innerBg = "images/recycle/reward/rewardbg.png"
	}
	-- 背景
	local bg = CCScale9Sprite:create(imagePath.bg)
    bg:setContentSize(CCSizeMake(555,200))
    bg:setAnchorPoint(ccp(0,0))
    bg:setPosition(ccp(10,10))
    cell:addChild(bg)
    -- 二级背景
    local innerBg = CCScale9Sprite:create(imagePath.innerBg)
    innerBg:setContentSize(CCSizeMake(520,130))
    innerBg:setAnchorPoint(ccp(0.5,0))
    innerBg:setPosition(ccp(bg:getContentSize().width/2,15))
    bg:addChild(innerBg)
    -- 标题背景
    local titleBg = CCScale9Sprite:create(imagePath.titleBg)
    titleBg:setContentSize(CCSizeMake(240,60))
    titleBg:setAnchorPoint(ccp(0,1))
    titleBg:setPosition(ccp(0,bg:getContentSize().height))
    titleBg:setScaleX(1.3)
    bg:addChild(titleBg)
    local titleBgSize = titleBg:boundingBox().size
    -- 标题文本
    local  titleLabel = CCRenderLabel:create(currData.desc,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke) 
    titleLabel:setColor(ccc3(0xff,0xf6,0x00))
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setPosition(titleBg:getPositionX() + titleBgSize.width / 2,titleBg:getPositionY() - titleBgSize.height / 2)
    bg:addChild(titleLabel)

	local luaHandler = LuaEventHandler:create(function(fn,t,a1,a2)
			local ret
			if fn == "cellSize" then
				ret = CCSizeMake(125, 130)
			elseif fn == "cellAtIndex" then
				ret = createInnerCell(currData.rewardAry[a1 + 1])
			elseif fn == "numberOfCells" then
				ret = table.count(currData.rewardAry)
			elseif fn == "cellTouched" then
			end
			return ret
		end)
	local tableView = LuaTableView:createWithHandler(luaHandler,CCSizeMake(500,130))
	tableView:setTouchPriority(_touchPriority+1)
	tableView:setDirection(kCCScrollViewDirectionHorizontal)
	tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	tableView:setPosition(ccp(40,15))
	cell:addChild(tableView,1)

	return cell
end

--[[
	@des 	: 创建内部的表单元
	@param 	: 
--]]
function createInnerCell(data)
	local cell = CCTableViewCell:create()
	--商品图标
	local itemInfo = ItemUtil.getItemsDataByStr(data)[1]
	local icon = ItemUtil.createGoodsIcon(itemInfo,_touchPriority+2,1234,_touchPriority-30,nil,nil,false)
	icon:setAnchorPoint(ccp(0.5,0.5))
	icon:setPosition(ccp(60,85))
	cell:addChild(icon)
	return cell
end