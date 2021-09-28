-- FileName: MyReportNode.lua 
-- Author: Zhang Zihang
-- Date: 2014/8/4
-- Purpose: 我的战报界面

module("MyReportNode", package.seeall)

require "script/audio/AudioUtil"
require "script/ui/lordWar/LordWarService"
require "script/ui/lordWar/LordWarData"

local _touchPriority
local _zOrder
local _bgNode
local _reportInfo 			--战报信息
local _secondSprite

----------------------------------------初始化函数----------------------------------------
local function init()
	_touchPriority = nil
	_zOrder = nil
	_bgNode = nil
	_secondSprite = nil
	_reportInfo = {}
end

----------------------------------------UI函数----------------------------------------
--[[
	@des 	:创建背景UI
	@param 	:
	@return :
--]]
function createBgUI()
    require "script/ui/lordWar/myReport/MyReportTableView"
    local reportTableView = MyReportTableView.createTableView(_reportInfo)
    reportTableView:setAnchorPoint(ccp(0,0))
    reportTableView:setPosition(ccp(0,0))
    reportTableView:setTouchPriority(_touchPriority - 1)
    _secondSprite:addChild(reportTableView)
end

function createMainBg()
	--二级背景
	_secondSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	_secondSprite:setContentSize(CCSizeMake(565,515))
	_secondSprite:setAnchorPoint(ccp(0.5,1))
	_secondSprite:setPosition(ccp(_bgNode:getContentSize().width/2,_bgNode:getContentSize().height - 40))
	_bgNode:addChild(_secondSprite)

	--目录标题
	local fullRect = CCRectMake(0,0,74,63)
	local insetRect = CCRectMake(34,18,4,1)
	local titleListBg = CCScale9Sprite:create("images/guild/city/titleBg.png", fullRect, insetRect)
	titleListBg:setContentSize(CCSizeMake(575,65))
	titleListBg:setAnchorPoint(ccp(0.5,1))
	titleListBg:setPosition(ccp(_bgNode:getContentSize().width/2,_bgNode:getContentSize().height))
	_bgNode:addChild(titleListBg)
	--3条分割线
	--坚持代码重用方针一百年不动摇 - - !
	local triLineXTable = {165,340,425}
	local spriteNameTable = {
								[1] = "images/lord_war/battlereport/round.png",
								[2] = "images/lord_war/battlereport/oppoent.png",
								[3] = "images/lord_war/battlereport/num.png",
								[4] = "images/lord_war/battlereport/final.png",
							}
	local nameXTable = {90,250,380,490}
	for i = 1,4 do
		if i ~= 4 then
			local lineSprite = CCSprite:create("images/guild/city/fen.png")
			lineSprite:setAnchorPoint(ccp(0.5,1))
			lineSprite:setPosition(ccp(triLineXTable[i],titleListBg:getContentSize().height - 5))
			titleListBg:addChild(lineSprite)
		end

		local listNameSprite = CCSprite:create(spriteNameTable[i])
		listNameSprite:setAnchorPoint(ccp(0.5,0.5))
		listNameSprite:setPosition(ccp(nameXTable[i],titleListBg:getContentSize().height/2 + 5))
		titleListBg:addChild(listNameSprite)
	end

	local indexTable = {
							[1] = "zzh_1059",
							[2] = "zzh_1060",
					   }
	--两行提示
	for i = 1,2 do
		local tipsLabel = CCLabelTTF:create(GetLocalizeStringBy(indexTable[i]),g_sFontPangWa,23)
		tipsLabel:setColor(ccc3(0x78,0x25,0x00))
		tipsLabel:setAnchorPoint(ccp(0.5,0))
		tipsLabel:setPosition(ccp(_bgNode:getContentSize().width/2,80 - 40*(i-1)))
		_bgNode:addChild(tipsLabel)
	end
end

----------------------------------------入口函数----------------------------------------
--[[
	@des 	:本来是一个layer，后来伟大的策划大人们改成了和“我的支持”合并为一个界面了
			 所以主体是刘立鹏写，我创建node让他add下就好了	
	@param 	:
	@return :创建好的node
--]]
function createNode(p_touchPriority,p_zOrder)
	init()

	_touchPriority = p_touchPriority or -550
	_zOrder = p_zOrder or 999

 	_bgNode = CCNode:create()
 	_bgNode:setContentSize(CCSizeMake(625,660))

 	createMainBg()

 	createUIFunciton = function(p_serverInfo)
 		--创建背景UI
 		_reportInfo = LordWarData.dealMyReportInfo(p_serverInfo)
    	createBgUI()
 	end

 	LordWarService.getMyRecord(createUIFunciton)

    return _bgNode
end

----------------------------------------工具函数----------------------------------------
--[[
	@des 	:得到界面触摸优先级
	@param 	:
	@return :返回触摸优先级
--]]
function getTouchPriority()
	return _touchPriority
end