-- FileName: LittleFriendData.lua 
-- Author: Li Cong 
-- Date: 13-12-2 
-- Purpose: function description of module 

require "script/model/user/UserModel"
module("LittleFriendData", package.seeall)


local _littleFriendInfo 						= nil  -- 小伙伴界面数据


-- 设置小伙伴数据
function setLittleFriendeData( data )
	_littleFriendInfo = data
	-- print("小伙伴数据:_littleFriendInfo")
	-- print_t(_littleFriendInfo)
end

-- 得到小伙伴数据
function getLittleFriendeData( ... )
	-- print("小伙伴数据:_littleFriendInfo")
	-- print_t(_littleFriendInfo)
	return _littleFriendInfo
end


--[[
	@des 	:修改小伙伴数据
	@param 	:hid:小伙伴hid, position:位置
	@return :修改后的小伙伴信息 _littleFriendInfo
--]]
function setLittleFriendDataByPos( position, hid )
	for k,v in pairs(_littleFriendInfo) do
		if(tonumber(k) == tonumber(position))then
			print("更换hid：",v,hid)
			_littleFriendInfo[k] = hid
		end
	end
	-- print("更新小伙伴的数据:_littleFriendInfo")
	-- print_t(_littleFriendInfo)
end


--[[
	@des 	:得到该位置的开启等级
	@param 	:position:位置 从1开始 1-6
	@return :lv
--]]
function getOpenLv( position )
	local lv = 0
	require "db/DB_Formation"
	local data = DB_Formation.getDataById(1)
	local tab = string.split(data.openFriendByLv,",")
	for k,v in pairs(tab) do
		local t_data = string.split(v,"|")
		-- print("position",position,"t_data[2]",t_data[2])
		if(tonumber(position) == tonumber(t_data[2]))then
			lv = tonumber(t_data[1])
			break
		end
	end
	-- print("lv",lv)
	return lv
end


--[[
	@des 	:得到该位置是否开启 等级限制
	@param 	:position:位置 从1开始 1-7
	@return :开启ture，没开启false
--]]
function getIsOpenThisPosition( position )
	local heroLv = UserModel.getHeroLevel()
	local openLv = getOpenLv(position)
	if(heroLv < openLv)then
		return false
	else
		local costNum = getOpenCostByPosition(position)
		if(costNum ~= nil)then
			local hid = getHidFromPosition(position)
			if(tonumber(hid) >= 0 )then
				return true
			else
				return false
			end
		else
			return true
		end
	end
end

--[[
	@des 	:得到开启花费  
	@param 	: 
	@return :num
--]]
function getOpenCostByPosition( position )
	local costNum = nil
	require "db/DB_Formation"
	local data = DB_Formation.getDataById(1)
	local tab = string.split(data.openFriendCost,",")
	for k,v in pairs(tab) do
		local t_data = string.split(v,"|")
		-- print("position",position,"t_data[2]",t_data[2])
		-- 表配置从0-6 
		if(tonumber(position)-1 == tonumber(t_data[1]))then
			costNum = tonumber(t_data[2])
			break
		end
	end
	-- print("lv",lv)
	return costNum
end

--[[
	@des 	:得到第八个位置是否开启
	@param 	: 
	@return :false 
--]]
function getIsOpenEightPosition(p_pos)
	local hid = getHidFromPosition(p_pos)
	if(hid >= 0)then
		return true
	else 
		-- -1未开启
		return false
	end
end


--[[
	@des 	:得到该位置上的hid  hid为0时改位置没有上阵武将
	@param 	:position:位置 从1开始 1-6
	@return :返回hid，   >0 是英雄hid，0是没有英雄，-1是未开启
--]]
function getHidFromPosition( position )
	local hid = -1
	local data = getLittleFriendeData()
	if(data == nil)then
		return hid
	end
	for k,v in pairs(data) do
		if(tonumber(k) == tonumber(position))then
			hid = tonumber(v)
		end
	end
	return hid
end


-- 是否有相同将领已经在小伙伴阵上 这一类武将在小伙伴上的方法
function isHadSameTemplateOnLittleFriend(h_id)
	require "db/DB_Heroes"
	local isOn = false
	local heroInfo = HeroUtil.getHeroInfoByHid(tonumber(h_id))
	local formationInfo = getLittleFriendeData()
	if(formationInfo == nil)then
		return isOn
	end
	for k,v in pairs(formationInfo) do
		if(tonumber(v)>0)then
			local t_heroInfo = HeroUtil.getHeroInfoByHid(v)
			local modelIdA = DB_Heroes.getDataById(t_heroInfo.htid).model_id
			local modelIdB = DB_Heroes.getDataById(heroInfo.htid).model_id
			if(tonumber(modelIdA) == tonumber(modelIdB))then
				isOn = true
				break
			end
		end
	end
	return isOn
end

--判断武将是否在小伙伴阵容上 这一个武将在小伙伴上的
function isInLittleFriend(h_id)
	local isOn = false
	local formationInfo = getLittleFriendeData()
	if(formationInfo == nil)then
		return isOn
	end
	for k,v in pairs(formationInfo) do
		if tonumber(h_id) == tonumber(v) then
			isOn = true
			break
		end
	end
	return isOn
end

-- 得到阵容上武将的数据
function getHeroInFormation( ... )
	local tab = {}
	require "script/model/DataCache"
	local data = DataCache.getSquad()
	-- print(GetLocalizeStringBy("key_2735"))
	-- print_t(data)
	for i=0,5 do
		if(tonumber(data[""..i]) > 0)then
			-- 阵上的武将hid
			table.insert(tab,data[""..i])
		end
	end
	return tab
end

-- 得到阵型上武将的数据 (布阵界面)
function getHeroInFormationTwo( ... )
	local tab = {}
	require "script/model/DataCache"
	local data = DataCache.getFormationInfo()
	-- print(GetLocalizeStringBy("key_2735"))
	-- print_t(data)
	for i=0,5 do
		if(tonumber(data[""..i]) > 0)then
			-- 阵上的武将hid
			table.insert(tab,data[""..i])
		else
			table.insert(tab,0)
		end
	end
	return tab
end

-- 得到是否要提示新的小伙伴位置开启
function getIsShowTipNewLittle( ... )
	local isShow = false
	-- 得到开启的最后一个位置
	local finalPos = 0
	for i=1,6 do
		local isOpen = getIsOpenThisPosition(i)
		if(isOpen)then
			finalPos = i
		else
			break
		end
	end
	-- 最后一个位置大于0 否则一个没开启
	if(finalPos > 0)then
		-- 判断最后一个位置上是否有英雄
		local hid = getHidFromPosition(finalPos)
		if(tonumber(hid) > 0)then
			-- 有英雄 不提示了
			isShow = false
		else
			-- 判断这个位置是否提示过 本地是否有记录
			local savePos = getSaveTipLittlePos()
			print("savePos .. ",savePos)
			if(savePos)then
				-- 记录的有值
				if(tonumber(savePos) < finalPos)then
					-- 要提示的位置 大于 已保存的提示位置 时 提示
					isShow = true
				else
					isShow = false
				end
			else
				-- 无记录 提示
				isShow = true
			end
		end
	else
		-- 一个位置也没开启
		isShow = false
	end
	return isShow,finalPos
end

--保存当前提示位置
function saveCurTipLittlePos( curTipPos )
	print("save LittleFriendData pos = ", curTipPos)
	CCUserDefault:sharedUserDefault():setStringForKey("littleTipPos_" .. UserModel.getUserUid(), tostring(curTipPos))
	CCUserDefault:sharedUserDefault():flush()
end

--取出本地上次提示的位置
function getSaveTipLittlePos()
	local saveTipPos = CCUserDefault:sharedUserDefault():getStringForKey("littleTipPos_" .. UserModel.getUserUid())
	return tonumber(saveTipPos)
end

-- 提示完成后执行函数
function afterLittleTipCallFun( ... )
 	-- 保存
 	print("afterLittleTipCallFun")
 	local a,curTipPos = getIsShowTipNewLittle()
 	saveCurTipLittlePos(curTipPos)
 	-- 刷新阵容按钮上小红点
 	MenuLayer.refreshMenuItemTipSprite()
end 

--[[
	@des 	:是否可以更换该武将到该位置上 更换小伙伴用
	@param 	: h_id:要更换的武将hid，p_position:要更换的位置
	@return :true 可以 
--]]
function isSwapHeroOnLittleFriendByHid(h_id,p_position)
	local retData = false
	local onPos = nil
	require "db/DB_Heroes"
	local heroInfo = HeroUtil.getHeroInfoByHid(tonumber(h_id))
	local formationInfo = getLittleFriendeData()
	if(formationInfo == nil)then
		return retData
	end

	for k,v in pairs(formationInfo) do
		if(tonumber(v)>0)then
			local t_heroInfo = HeroUtil.getHeroInfoByHid(v)
			local modelIdA = DB_Heroes.getDataById(t_heroInfo.htid).model_id
			local modelIdB = DB_Heroes.getDataById(heroInfo.htid).model_id
			if(tonumber(modelIdA) == tonumber(modelIdB))then
				onPos = k
				break
			end
		end
	end

	if(onPos ~= nil)then
		if(tonumber(onPos) == tonumber(p_position))then
			retData = true
		else
			retData = false
		end
	else
		retData = true
	end
	return retData
end














