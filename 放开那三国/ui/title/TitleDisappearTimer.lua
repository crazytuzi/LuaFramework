-- Filename: TitleDisappearTimer.lua
-- Author: lgx
-- Date: 2016-05-05
-- Purpose: 称号失效计时器

module("TitleDisappearTimer", package.seeall)

require "script/utils/TimeUtil"

-- 定时器
local _updateTimeScheduler 	= nil

--[[
	@desc 	: 称号失效时调用
	@param 	: pDisappearTime 称号失效时间戳
	@return : 
--]]
function startTitleDisappearTimer( pDisappearTime )
	local disTimeInterval = pDisappearTime - TimeUtil.getSvrTimeByOffset() + 1
	print("TitleDisappearTimer startTitleDisappearTimer disTimeInterval=>", disTimeInterval)
	if (disTimeInterval > 0) then
		stopScheduler() -- 先停止之前的定时器
		startScheduler(disTimeInterval)
	else
		-- 已经失效
		updateTimeFunc()
	end
end

--[[
	@desc 	: 停止定时器
	@param 	: 
	@return : 
--]]
function stopScheduler()
	if(_updateTimeScheduler ~= nil)then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeScheduler)
		_updateTimeScheduler = nil
	end
end

--[[
	@desc 	: 启动定时器
	@param 	: pTimeInterval 间隔时间戳
	@return : 
--]]
function startScheduler( pTimeInterval )
	if(_updateTimeScheduler == nil) then
		_updateTimeScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTimeFunc, pTimeInterval, false)
	end
end

--[[
	@desc 	: 定时器到间隔时间戳的回调方法
	@param 	: 
	@return : 
--]]
function updateTimeFunc()
	local curTitleId = UserModel.getTitleId()
	print("TitleDisappearTimer updateTimeFunc curTitleId=>",curTitleId)
	-- BTUtil的 m_timeDiff 可能存在不一样的情况
	-- 每个请求回来会调用syncTime方法计算本地转换北京时间后和服务器时间的偏差(m_timeDiff)
	-- 先判断一下失效时间,避免失效按钮提前显示的问题 add by lgx 20160603
	if (curTitleId > 0) then
		require "script/ui/title/TitleData"
		local curTitleInfo = TitleData.getTitleInfoById(curTitleId)
		local disTimeInterval = curTitleInfo.deadline - TimeUtil.getSvrTimeByOffset() + 1
		print("TitleDisappearTimer updateTimeFunc disTimeInterval=>", disTimeInterval)
		if (disTimeInterval > 0) then
			stopScheduler() -- 先停止之前的定时器
			startScheduler(disTimeInterval)
		else
			-- 已经失效
			stopScheduler()
			doWithTitleDisappear()
		end
	else
		-- 已经失效
		stopScheduler()
		doWithTitleDisappear()
	end
end

--[[
	@desc 	: 称号消失时候处理一些事
	@param 	: 
	@return : 
--]]
function doWithTitleDisappear()
	print("TitleDisappearTimer doWithTitleDisappear")
	-- 记录失效的称号ID
	require "script/ui/title/TitleData"
	local disTitleId = UserModel.getTitleId()
	if (disTitleId > 0) then
		TitleData.setLastDisappearTitleId(disTitleId)
	end

	-- 调用后端接口
	require "script/ui/title/TitleController"
	TitleController.getStylishInfo()

	-- 移除失效称号
    UserModel.setTitleId(0)
    print("doWithTitleDisappear curTitleId:",UserModel.getTitleId())

	-- 刷新战斗力计算
	TitleData.getEquipTitleAttrInfoByHid(nil,true)

	-- 通知主界面显示"失效"图标
	require "script/ui/main/MainMenuLayer"
	MainMenuLayer.updateMiddleButton()

end
