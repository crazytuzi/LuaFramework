-- FileName: ActiveListData.lua 
-- Author: licong 
-- Date: 16/1/11 
-- Purpose: 活动列表数据


module("ActiveListData", package.seeall)


local _activeListInfo 			= nil
local _activeMenuTab 			= nil

--[[
	@des 	: 设置列表数据
	@param 	:
	@return :
--]]
function setListInfo( p_info )
	_activeListInfo = p_info
end


--[[
	@des 	: 得到列表数据
	@param 	:
	@return :
--]]
function getListInfo(  )
	return _activeListInfo
end


--[[
	@des 	: 得到列表数据
	@param 	:
	@return :
--]]
function initTopMenuTab()
	_activeMenuTab = {
		-- 木牛流马
	 	{ image_n = "images/active/activeList/top_icon/horse_n.png", image_h = "images/active/activeList/top_icon/horse_h.png", tag = ActiveList._ksTagHorse, isShowFun = isShowHorse, index = 1, },
	 	-- 跨服比武
	 	{ image_n = "images/active/activeList/top_icon/kfbw_n.png", image_h = "images/active/activeList/top_icon/kfbw_h.png", tag = ActiveList._ksTagkfbw, isShowFun = isShowWorldCompete, index = 2, },
	 	-- 跨服比武奖励
	 	{ image_n = "images/active/activeList/top_icon/kfbwreward_n.png", image_h = "images/active/activeList/top_icon/kfbwreward_h.png", tag = ActiveList._ksTagkfbw, isShowFun = isShowWorldCompeteReward, index = 3, },
	 	-- 炼狱挑战
	 	{ image_n = "images/active/activeList/top_icon/lianyu_n.png", image_h = "images/active/activeList/top_icon/lianyu_h.png", tag = ActiveList._ksTagLianYu, isShowFun = isShowWorldPass, index = 4, },
	 	-- 过关斩将
	 	{ image_n = "images/active/activeList/top_icon/guoguan_n.png", image_h = "images/active/activeList/top_icon/guoguan_h.png", tag = ActiveList._ksTagGodWeaponCopy, isShowFun = isShowPass, index = 5, },
	 	-- 水月之境普通副本
	 	{ image_n = "images/active/activeList/top_icon/shuiyue_n.png", image_h = "images/active/activeList/top_icon/shuiyue_h.png", tag = ActiveList._ksTagShuiYue, isShowFun = isShowMoon, index = 6, },
	 	-- 水月之境梦魇副本
	 	{ image_n = "images/active/activeList/top_icon/meng_n.png", image_h = "images/active/activeList/top_icon/meng_h.png", tag = ActiveList._ksTagShuiYue, isShowFun = isShowMoonHard, index = 7, },
	 	-- 寻龙探宝
	 	{ image_n = "images/active/activeList/top_icon/xunlong_n.png", image_h = "images/active/activeList/top_icon/xunlong_h.png", tag = ActiveList._ksTagxunlong, isShowFun = isShowDragon, index = 8, },
	 	-- 试练塔
	 	{ image_n = "images/active/activeList/top_icon/shilian_n.png", image_h = "images/active/activeList/top_icon/shilian_h.png", tag = ActiveList._ksTagshilianta, isShowFun = isShowTower, index = 9, },
	 	-- 试练梦魇
	 	{ image_n = "images/active/activeList/top_icon/deviltower_n.png", image_h = "images/active/activeList/top_icon/deviltower_h.png", tag = ActiveList._ksTagDevilTower, isShowFun = isShowDevilTower, index = 10, },
		-- 比武
	 	{ image_n = "images/active/activeList/top_icon/biwu_n.png", image_h = "images/active/activeList/top_icon/biwu_h.png", tag = ActiveList._ksTagbiwu, isShowFun = isShowCompete, index = 11, },
		-- 跨服比武膜拜
	 	{ image_n = "images/active/activeList/top_icon/kfbwworship_n.png", image_h = "images/active/activeList/top_icon/kfbwworship_h.png", tag = ActiveList._ksTagkfbw, isShowFun = isShowWorldCompeteWorship, index = 12, },
	}
end

--[[
	@des 	: 得到列表显示数据
	@param 	:
	@return :
--]]
function getShowMenuData( ... )
	local showData = {}
	for i=1,#_activeMenuTab do
		local isShow = _activeMenuTab[i].isShowFun()
		if(isShow)then
			table.insert(showData,_activeMenuTab[i])
		end
	end
	local sortFun = function (p_data1, p_data2 )
		return p_data1.index < p_data2.index
	end
	table.sort( showData, sortFun )

	return showData
end

--[[
	@des 	: 是否显示比武按钮
	@param 	:
	@return :
--]]
function isShowCompete()
	local isShow = false
	if(_activeListInfo.compete.status ~= "ok")then
		return isShow
	end

	-- 比武剩余次数大于0 显示
	if( tonumber(_activeListInfo.compete.extra.num) > 0 )then
		isShow = true
	end

	return isShow
end

--[[
	@des 	: 是否显示跨服比武按钮
	@param 	:
	@return :
--]]
function isShowWorldCompete()
	local isShow = false
	if(_activeListInfo.worldcompete.status ~= "ok")then
		return isShow
	end

	-- 跨服比武剩余次数大于0 显示
	if( tonumber(_activeListInfo.worldcompete.extra.num) > 0 )then
		isShow = true
	end

	return isShow
end

--[[
	@des 	: 是否显示跨服比武奖励按钮
	@param 	:
	@return :
--]]
function isShowWorldCompeteReward()
	local isShow = false
	if(_activeListInfo.worldcompete.status ~= "ok")then
		return isShow
	end

	-- 跨服比武剩余次数大于0 显示
	if( tonumber(_activeListInfo.worldcompete.extra.box_reward) > 0 )then
		isShow = true
	end

	return isShow
end

--[[
	@des 	: 是否显示跨服比武膜拜
	@param 	:
	@return :
--]]
function isShowWorldCompeteWorship()
	local isShow = false
	if(_activeListInfo.worldcompete.status ~= "ok")then
		return isShow
	end

	-- 跨服比武剩余膜拜次数大于0 显示
	if( tonumber(_activeListInfo.worldcompete.extra.can_worship) > 0 )then
		isShow = true
	end

	return isShow
end

--[[
	@des 	: 是否显示过关斩将按钮
	@param 	:
	@return :
--]]
function isShowPass()
	local isShow = false
	if(_activeListInfo.pass.status ~= "ok")then
		return isShow
	end

	-- 未通关且过关斩将通关数小于1 显示
	if( tonumber(_activeListInfo.pass.extra.pass) == 0 and tonumber(_activeListInfo.pass.extra.curr) <= 1 )then
		isShow = true
	end

	return isShow
end

--[[
	@des 	: 是否显示水月之境按钮
	@param 	:
	@return :
--]]
function isShowMoon()
	local isShow = false
	if(_activeListInfo.moon.status ~= "ok")then
		return isShow
	end

	-- 水月之境剩余次数大于0 显示
	if( tonumber(_activeListInfo.moon.extra.normal_num) > 0 )then
		isShow = true
	end

	return isShow
end

--[[
	@des 	: 是否显示水月之境梦魇按钮
	@param 	:
	@return :
--]]
function isShowMoonHard()
	local isShow = false
	if(_activeListInfo.moon.status ~= "ok")then
		return isShow
	end

	-- 剩余次数大于0 显示
	if( tonumber(_activeListInfo.moon.extra.nightmare_num) > 0 )then
		isShow = true
	end

	return isShow
end

--[[
	@des 	: 是否显示炼狱挑战按钮
	@param 	:
	@return :
--]]
function isShowWorldPass()
	local isShow = false
	if(_activeListInfo.worldpass.status ~= "ok")then
		return isShow
	end

	-- 剩余次数大于0 显示
	if( tonumber(_activeListInfo.worldpass.extra.num) > 0 )then
		isShow = true
	end

	return isShow
end

--[[
	@des 	: 是否显示试练塔
	@param 	:
	@return :
--]]
function isShowTower()
	local isShow = false
	if(_activeListInfo.tower.status ~= "ok")then
		return isShow
	end

	-- 剩余次数大于0 显示
	if( tonumber(_activeListInfo.tower.extra.reset_num) > 0 )then
		isShow = true
	end

	return isShow
end


--[[
	@des 	: 是否显示寻龙
	@param 	:
	@return :
--]]
function isShowDragon()
	local isShow = false
	if(_activeListInfo.dragon.status ~= "ok")then
		return isShow
	end

	-- 剩余次数大于0 显示
	if( tonumber(_activeListInfo.dragon.extra.num) > 0 )then
		isShow = true
	end

	return isShow
end

--[[
	@des 	: 是否显示木牛流马
	@param 	:
	@return :
--]]
function isShowHorse()
	local isShow = false
	if(_activeListInfo.dart.status ~= "ok")then
		return isShow
	end

	-- 剩余次数大于0 显示
	if( tonumber(_activeListInfo.dart.extra.num) > 0 )then
		isShow = true
	end

	return isShow
end


-- 限时开启类活动
--[[
	@des 	: 世界boss是否显示第一
	@param 	:
	@return :
--]]
function isBossNeedFirst()
	local retData = false
    local timeStamp = UserModel.getTimeConfig("boss")
    if(timeStamp)then
	    local beganTime = tonumber(timeStamp.begin_time)
	    local endTime = tonumber(timeStamp.end_time)
	    local curTime = TimeUtil.getSvrTimeByOffset(0)
	    if( beganTime-5*60 <= curTime and curTime < endTime )then
	    	retData = true
	    end
	end
	return retData
end

--[[
	@des 	: 擂台赛是否显示第一
	@param 	:
	@return :
--]]
function isOlympicNeedFirst()
	local retData = false
	if not DataCache.getSwitchNodeState(ksOlympic,false) then
		return retData
	end
	
	local timeStamp = UserModel.getTimeConfig("olympic")
	if(timeStamp)then
	    local beganTime = tonumber(timeStamp.begin_time)
	    local endTime = tonumber(timeStamp.end_time)
	    local curTime = TimeUtil.getSvrTimeByOffset(0)
	    if( beganTime-300 <= curTime and curTime < beganTime+15*60 )then
	    	retData = true
	    end
	end
	return retData
end

--[[
	@desc	: 是否显示试炼梦魇
    @param	: 
    @return	: 
—-]]
function isShowDevilTower()
	local isShow = false
	if (_activeListInfo.helltower == nil) then
		return isShow
	end
	
	if(_activeListInfo.helltower.status ~= "ok")then
		return isShow
	end

	-- 剩余次数大于0 显示
	if( tonumber(_activeListInfo.helltower.extra.reset_num) > 0 )then
		isShow = true
	end

	return isShow
end
