-- FileName: UseRefreshInfo.lua 
-- Author: licong 
-- Date: 14-11-24 
-- Purpose: 军团使用全部刷新粮田公告 


module("UseRefreshInfo", package.seeall)

require "script/ui/guild/GuildDataCache"
require "script/ui/guild/liangcang/BarnData"

local _bgSprite 			= nil
local _scrollView 			= nil
local _xiaoSp 				= nil

local _userInfo 			= {}
local _adddNum 				= nil

--[[
	@des 	: 初始化
	@param 	:
	@return :
--]]
function init( ... )
	_bgSprite 			= nil
	_scrollView 		= nil
	_xiaoSp 			= nil

	_userInfo 			= {}
	_adddNum 			= nil
end


--[[
	@des 	: 创建刷新全部sp
	@param 	:
	@return :
--]]
function createUseRefreshAllSprite()
	-- 初始化
	init()

	-- 使用刷新全部功能的信息
	_userInfo = BarnData.getRefreshAllInfo()
	-- 使用大丰收增加的次数
	local a = 1
	a,_adddNum = BarnData.getRefreshAllMaxNumAndAddNum()
	if(not table.isEmpty(_userInfo) )then
		local fullRect = CCRectMake(0, 0, 209, 49)
		local insetRect = CCRectMake(86, 14, 45, 20)
		_bgSprite = CCScale9Sprite:create("images/guild/liangcang/gonggao.png",fullRect,insetRect)
		_bgSprite:setContentSize(CCSizeMake(640,55))

		-- 小麦图标
	 	_xiaoSp = CCSprite:create("images/guild/liangcang/xiaomai_zhong.png")
	 	_xiaoSp:setAnchorPoint(ccp(0,0.5))
	 	_bgSprite:addChild(_xiaoSp)
	 	_xiaoSp:setPosition(ccp(20,_bgSprite:getContentSize().height*0.6))

		createScrollView()
	 	
	end

	return _bgSprite
end


--[[
	@des 	: 创建 ScrollView
	@param 	:
	@return :
--]]
function createScrollView( ... )
	_scrollView = CCScrollView:create()
	_scrollView:setTouchEnabled(false)
	_scrollView:setViewSize(CCSizeMake(510, 45))
	_scrollView:setPosition(ccp(_xiaoSp:getPositionX()+_xiaoSp:getContentSize().width,0))
	_bgSprite:addChild(_scrollView)

	local runLabel = getContentNode(_userInfo[1],_adddNum) 
	runLabel:setAnchorPoint(ccp(0,0.5))
	runLabel:setPosition(_scrollView:getContentSize().width, _scrollView:getViewSize().height*0.5)
	_scrollView:addChild(runLabel)

	runLabelRunAction(runLabel)
end

--[[
	@des 	: 得到公告内容
	@param 	: p_runLabel 滚动的内容
	@return :
--]]
function runLabelRunAction( p_runLabel )
	p_runLabel:setPosition(_scrollView:getContentSize().width, _scrollView:getViewSize().height*0.5)
	local actionArr = CCArray:create()
	local move = CCMoveTo:create(25, ccp(0-p_runLabel:getContentSize().width, _scrollView:getViewSize().height*0.5))
	actionArr:addObject(move)
	actionArr:addObject(CCCallFunc:create(function ( ... )
		runLabelRunAction(p_runLabel)
	end))
	local seq = CCSequence:create(actionArr)
	p_runLabel:runAction(seq)
end

--[[
	@des 	: 得到公告内容
	@param 	: p_name玩家名字, p_addNum增加的次数
	@return :
--]]
function getContentNode( p_name, p_addNum )
	local label = nil

	-- [xx] 使用 “xx”军团全体成员粮田重置
	local textInfo = {
        alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
        labelDefaultFont = g_sFontName,      -- 默认字体
        labelDefaultSize = 20,          -- 默认字体大小
        elements =
        {	
            {
            	type = "CCRenderLabel", 
            	text = "  【" .. p_name .. "】",
            	color = ccc3(0x00, 0xe4, 0xff)
        	},
        	{
        		type = "CCRenderLabel", 
        		text = GetLocalizeStringBy("lic_1342")
        	},
        	{	
        		type = "CCRenderLabel", 
        		text =  GetLocalizeStringBy("lic_1345"),
        		color = ccc3(0xff,0x00,0xe1)
        	},
        	{	
        	 	type = "CCRenderLabel", 
        		text = GetLocalizeStringBy("lic_1343",p_addNum)
        	}
        }
 	}
 	label = LuaCCLabel.createRichLabel(textInfo)

	return label
end






































