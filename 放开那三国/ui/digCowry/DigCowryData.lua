-- Filename：	DigCowryData.lua
-- Author：		Li Pan
-- Date：		2014-1-8
-- Purpose：		挖宝

module("DigCowryData", package.seeall)

--基本信息
local digInfo = nil

-- 挖宝得出的信息
local DigCowryInfo = nil

function isDigcowryOpen( )
	if(ActivityConfigUtil.isActivityOpen("robTomb")) then
		if( not table.isEmpty(ActivityConfigUtil.getDataByKey("robTomb").data) ) then
			return true
		end
		return false
	end
end


--[[
	@des 	:转换挖宝获得的数据
	@param 	:
	@return :
--]]
function getRewardData( p_rewardData )
	local retTab = {}
	for i,v_data in ipairs(p_rewardData) do
        if( v_data.item )then
        	for k_tid,v_num in pairs(v_data.item) do
        		local tab = {}
        		tab.type = "item"
	            tab.num  = tonumber(v_num)
	            tab.tid  = tonumber(k_tid)
	            -- 存入数组
        		table.insert(retTab,tab)
        	end
        elseif(v_data.treasFrag)then
        	for k_tid,v_num in pairs(v_data.treasFrag) do
        		local tab = {}
        		tab.type = "item"
	            tab.num  = tonumber(v_num)
	            tab.tid  = tonumber(k_tid)
	            -- 存入数组
        		table.insert(retTab,tab)
        	end
        elseif(v_data.hero)then
        	for k_tid,v_num in pairs(v_data.hero) do
        		local tab = {}
        		tab.type = "hero"
	            tab.num  = tonumber(v_num)
	            tab.tid  = tonumber(k_tid)
	            -- 存入数组
        		table.insert(retTab,tab)
        	end
        else
        end
    end
	return retTab
end