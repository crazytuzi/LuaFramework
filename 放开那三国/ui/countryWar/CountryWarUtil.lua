-- FileName: CountryWarUtil.lua
-- Author: lichenyang
-- Date: 2015-04-00
-- Purpose: TM_FILENAME
--[[TODO List]]

module("CountryWarUtil", package.seeall)
require "script/utils/BaseUI"
require "script/utils/TimeUtil"
require "script/ui/countryWar/signUp/CountryWarSignData"

function getCountdownSprite( ... )
	local des = getCountdownDes()
	local timeDesLabel = CCRenderLabel:create( des, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	timeDesLabel:setColor(ccc3(0xff, 0xf6, 0x00))

	local timeStr = getCountdownTime()
	local timeLabel = CCRenderLabel:create( timeStr, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	timeLabel:setColor(ccc3(0xff, 0xf6, 0x00))

	local timeNode = BaseUI.createHorizontalNode({timeDesLabel, timeLabel})
	timeNode:setScale(MainScene.elementScale)
	local lastStage = CountryWarMainData.getCurStage()
	local currStage = CountryWarMainData.getCurStage()
	schedule(timeNode, function ( ... )
		local des = getCountdownDes()
		timeDesLabel:setString(des)
		local timeStr = getCountdownTime()
		timeLabel:setString(timeStr)
		local width = timeDesLabel:getContentSize().width + timeLabel:getContentSize().width
		local height =  timeDesLabel:getContentSize().height
		timeNode:setContentSize(CCSizeMake(width, height))
		
		timeDesLabel:setAnchorPoint(ccp(0, 0.5))
		timeDesLabel:setPosition(ccpsprite(0, 0.5, timeNode))

		timeLabel:setAnchorPoint(ccp(0, 0.5))
		timeLabel:setPosition(ccp(timeDesLabel:getContentSize().width + 5, 0.5*height))
	end, 1)
	return timeNode
end

--[[
	@des:得到倒计时描述显示
--]]
function getCountdownDes( ... )
	local currStage = CountryWarMainData.getCurStage()
	local stageDes = {}
	local desStr = GetLocalizeStringBy("lcyx_2018") -- 准备中
	if currStage == CountryWarDef.TEAM then
		desStr = GetLocalizeStringBy("lcyx_2005") --活动倒计时
	elseif currStage == CountryWarDef.SIGNUP then
		desStr = GetLocalizeStringBy("lcyx_1997") --报名结束倒计时
		if CountryWarSignData.isSignedUp() then
			desStr = GetLocalizeStringBy("lcyx_1998") --初始开始倒计时
		end
	elseif currStage == CountryWarDef.ASSIGN_ROOM then
		desStr = GetLocalizeStringBy("lcyx_1999") --初始开始倒计时
	elseif currStage == CountryWarDef.AUDITION_READY then
		desStr = GetLocalizeStringBy("lcyx_2001") --开赛倒计时
	elseif currStage == CountryWarDef.AUDITION then
		desStr = GetLocalizeStringBy("lcyx_2001") --初赛结束倒计时
	elseif currStage == CountryWarDef.SUPPORT then
		desStr = GetLocalizeStringBy("lcyx_2002") --决赛开始倒计时
	elseif currStage == CountryWarDef.FINALTION_READY then
		desStr = GetLocalizeStringBy("lcyx_2004") --开赛倒计时
	elseif currStage == CountryWarDef.FINALTION then
		desStr = GetLocalizeStringBy("lcyx_2004") --决赛结束倒计时
	else
		print("其他没有倒计时阶段")
	end	print("CountryWarSignData.isSignedUp()",CountryWarSignData.isSignedUp())
	return desStr
end

--[[
	@des:得到倒计时时间显示
--]]
function getCountdownTime()
	local currStage = CountryWarMainData.getCurStage()
	local starTime = CountryWarMainData.getStageStartTime(currStage)
	local overTime = CountryWarMainData.getStageOverTime(currStage)
	--报名阶段已报名显示“初始开始倒计时”
	if currStage == CountryWarDef.SIGNUP then
		if CountryWarSignData.isSignedUp() then
			overTime = CountryWarMainData.getStageStartTime(CountryWarDef.AUDITION_READY)
		end
	end
	--分房阶段显示“初始开始倒计时”
	if currStage == CountryWarDef.ASSIGN_ROOM then
		overTime = CountryWarMainData.getStageStartTime(CountryWarDef.AUDITION_READY)
	end
	--初赛准备阶段显示初赛结束倒计时
	if currStage == CountryWarDef.AUDITION_READY then
		overTime = CountryWarMainData.getStageOverTime(CountryWarDef.AUDITION)
	end
	--决赛准备阶段显示决赛结束倒计时
	if currStage == CountryWarDef.FINALTION_READY then
		overTime = CountryWarMainData.getStageOverTime(CountryWarDef.FINALTION)
	end
	local timeInt = overTime - TimeUtil.getSvrTimeByOffset()
	local timeStr = TimeUtil.getTimeString(timeInt)
	return timeStr
end