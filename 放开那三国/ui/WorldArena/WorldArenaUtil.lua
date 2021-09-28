-- FileName: WorldArenaUtil.lua 
-- Author: licong 
-- Date: 15/7/6 
-- Purpose: WorldArenaUtil


module("WorldArenaUtil", package.seeall)
require "script/ui/WorldArena/WorldArenaMainData"

--[[
	@des 	: 得到倒计时显示描述
			分组时间（活动关闭状态，玩家看不到）
			报名时间（此时前端显示：距离报名结束：00:00:00）
			分房间时间（此时前端显示：距离活动开始：00:00:00）
			比赛时间（此时前端显示：距离活动结束：00:00:00）
			比赛结束发奖展示排行（此时前端短时：活动已结束）
	@param 	: 
	@return : 
--]]
function getTimeDesNode( ... )
	local retDesNode = nil
	local curTime = TimeUtil.getSvrTimeByOffset(0)
	local signEndTime = WorldArenaMainData.getSignUpEndTime()
	local atkStartTime = WorldArenaMainData.getAttackStartTime()
	local atkEndTime = WorldArenaMainData.getAttackEndTime()
	if( curTime < signEndTime )then
		-- 距离报名结束
		local timeStr = TimeUtil.getTimeString(signEndTime - curTime)
		local fontTab = {}
	    fontTab[1] = CCRenderLabel:create(GetLocalizeStringBy("lic_1681"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    fontTab[1]:setColor(ccc3(0xff,0xff,0xff))
	    fontTab[2] = CCRenderLabel:create(timeStr, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    fontTab[2]:setColor(ccc3(0x00,0xff,0x18))
	   	retDesNode = BaseUI.createHorizontalNode(fontTab)
	elseif( curTime >= signEndTime  and curTime < atkStartTime)then
		-- 距离活动开始
		local timeStr = TimeUtil.getTimeString(atkStartTime - curTime)
		local fontTab = {}
	    fontTab[1] = CCRenderLabel:create(GetLocalizeStringBy("lic_1682"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    fontTab[1]:setColor(ccc3(0xff,0xff,0xff))
	    fontTab[2] = CCRenderLabel:create(timeStr, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    fontTab[2]:setColor(ccc3(0x00,0xff,0x18))
	   	retDesNode = BaseUI.createHorizontalNode(fontTab)
	elseif( curTime >= atkStartTime  and curTime < atkEndTime)then
		-- 距离活动结束
		local timeStr = TimeUtil.getTimeString(atkEndTime - curTime)
		local fontTab = {}
	    fontTab[1] = CCRenderLabel:create(GetLocalizeStringBy("lic_1683"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    fontTab[1]:setColor(ccc3(0xff,0xff,0xff))
	    fontTab[2] = CCRenderLabel:create(timeStr, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    fontTab[2]:setColor(ccc3(0x00,0xff,0x18))
	   	retDesNode = BaseUI.createHorizontalNode(fontTab)
	elseif( curTime >= atkEndTime)then
		-- 活动结束
		local fontTab = {}
	    fontTab[1] = CCRenderLabel:create(GetLocalizeStringBy("lic_1684"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    fontTab[1]:setColor(ccc3(0xff,0xff,0xff))
	   	retDesNode = BaseUI.createHorizontalNode(fontTab)
	else
		print("no des ..")
	end
	return retDesNode
end


--[[
	@des 	: 显示购买次数
	@param 	: 
	@return : 
--]]
function showBuyAtkNumDialog( p_OKCallBack )
	require "script/utils/SelectNumDialog"
    local dialog = SelectNumDialog:create()
    dialog:setTitle(GetLocalizeStringBy("lic_1698"))
    dialog:show(-500, 1010)
    dialog:setMinNum(1)
    local maxNum = WorldArenaMainData.getBuyAtkMaxNum()
    local haveNum = WorldArenaMainData.getHaveBuyAtkNum()
    dialog:setLimitNum(maxNum-haveNum)

    -- 请选择购买挑战的次数
    local maxLabel = CCRenderLabel:create(GetLocalizeStringBy("lic_1601"), g_sFontName,30, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    maxLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    maxLabel:setAnchorPoint(ccp(0.5,0.5))
    maxLabel:setPosition(dialog:getContentSize().width*0.5, dialog:getContentSize().height*0.7)
    dialog:addChild(maxLabel)

    --金币
    local childNodes = {}
    childNodes[1] = CCRenderLabel:create(GetLocalizeStringBy("lic_1699"),g_sFontName, 30,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    childNodes[1]:setColor(ccc3(0xff, 0xf6, 0x00))

    childNodes[2] = CCSprite:create("images/common/gold.png")

    local costNum = WorldArenaMainData.getBuyAtkNumCost(1)
    childNodes[3] = CCRenderLabel:create(costNum,g_sFontName, 30, 1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    childNodes[3]:setColor(ccc3(0xff, 0xf6, 0x00))

    local costNode = BaseUI.createHorizontalNode(childNodes)
    costNode:setAnchorPoint(ccp(0.5,0.5))
    costNode:setPosition(ccpsprite(0.5, 0.3, dialog))
    dialog:addChild(costNode)

    dialog:registerOkCallback(function ()
        if(p_OKCallBack)then
      		p_OKCallBack( dialog:getNum() )
      	end
    end)

    dialog:registerChangeCallback(function ( pNum )
    	local costNum = WorldArenaMainData.getBuyAtkNumCost(pNum)
        childNodes[3]:setString(costNum)
    end)

end












































