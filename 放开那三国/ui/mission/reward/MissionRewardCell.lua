-- FileName: MissionRewardCell
-- Author: shengyixian
-- Date: 2015-09-06
-- Purpose: 奖励表单元

module("MissionRewardCell",package.seeall)

local _touchPriority = nil 
local _cell = nil
local _tableView = nil
local _currData = nil
local _currIndex = nil

function init( currData,index )
	-- body
	_touchPriority = -560
	_cell = nil
	_tableView = nil
	_currData = currData
	_currIndex = index
end
--[[
	@des 	: 初始化视图
	@param 	: 
--]]
function initView( ... )
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
    _cell:addChild(bg)
    -- 二级背景
    local innerBg = CCScale9Sprite:create(imagePath.innerBg)
    innerBg:setContentSize(CCSizeMake(520,130))
    innerBg:setAnchorPoint(ccp(0.5,0))
    innerBg:setPosition(ccp(bg:getContentSize().width/2,15))
    bg:addChild(innerBg)
    -- 标题背景
    local titleBg = CCScale9Sprite:create(imagePath.titleBg)
    titleBg:setContentSize(CCSizeMake(270,60))
    titleBg:setAnchorPoint(ccp(0,1))
    titleBg:setPosition(ccp(0,bg:getContentSize().height))
    titleBg:setScaleX(1.3)
    bg:addChild(titleBg)
    local titleBgSize = titleBg:boundingBox().size
    -- 标题文本
    local  titleLabel = CCRenderLabel:create(_currData[_currIndex].reward_des,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke) 
    titleLabel:setColor(ccc3(0xff,0xf6,0x00))
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setPosition(titleBg:getPositionX() + titleBgSize.width / 2,titleBg:getPositionY() - titleBgSize.height / 2)
    bg:addChild(titleLabel)
    createTableView()
end

--[[
	@des 	: 创建表单元
	@param 	: 
--]]
function create(currData,index)
	init(currData,index)
	_cell = CCTableViewCell:create()
	initView()
	return _cell
end
--[[
	@des 	: 创建表视图
	@param 	: 
--]]
function createTableView()
	local luaHandler = LuaEventHandler:create(function(fn,t,a1,a2)
			local tag = t:getTag()
			local reward = nil
			if (tag ~= -1) then
				reward = _currData[tag].rewardAry
			end
			local ret
			if fn == "cellSize" then
				ret = CCSizeMake(125, 130)
			elseif fn == "cellAtIndex" then
				if (tag == -1) then return CCTableViewCell:create() end
				ret = createInnerCell(reward[a1 + 1])
			elseif fn == "numberOfCells" then
				if reward then
					ret = table.count(reward)
				else 
					ret = 1
				end
			elseif fn == "cellTouched" then
			end
			return ret
		end)
	_tableView = LuaTableView:createWithHandler(luaHandler,CCSizeMake(500,130))
	_tableView:setTouchPriority(_touchPriority)
	_tableView:setBounceable(true)
	_tableView:setDirection(kCCScrollViewDirectionHorizontal)
	_tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_tableView:setPosition(ccp(40,15))
	_cell:addChild(_tableView,1,_currIndex)
	_tableView:reloadData()
end
--[[
	@des 	: 创建内部的表单元
	@param 	: 
--]]
function createInnerCell(data)
	local cell = CCTableViewCell:create()
	--商品图标
	local itemInfo = ItemUtil.getItemsDataByStr(data)[1]
	local icon = ItemUtil.createGoodsIcon(itemInfo,_touchPriority,1234,nil,nil,nil,false)
	icon:setAnchorPoint(ccp(0.5,0.5))
	icon:setPosition(ccp(60,85))
	cell:addChild(icon)
	return cell
end