-- Filename：	AthenaService.lua
-- Author：		zhang zihang
-- Date：		2015-3-30
-- Purpose：		主角星魂网络层

module("AthenaService",package.seeall)

require "script/ui/athena/AthenaData"

--[[
	-- Carry  15:36:52
	-- 雷雷，技能树的id是不是就是这个技能树要所在的页数
	-- Carry  15:37:05
	-- 比如id是1的技能树显示在第1页，是这个意思吗
	-- 唐雷  15:39:21
	-- 是
--]]
--总感觉这里不是很靠谱，所以还是留下聊天记录吧
--[[
	@des 	:得到主角星魂信息
	@param  :回调函数
--]]
function getAthenaInfo(p_callBack)
	local serviceCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "athena.getAthenaInfo" then
			AthenaData.setAthenaInfo(dictData.ret)
			if p_callBack ~= nil then
		    	p_callBack()
		    end
		end	

    end
    Network.rpc(serviceCallBack,"athena.getAthenaInfo","athena.getAthenaInfo",nil,true)
end

--[[
	@des 	:升级属性
	@param  :页数
	@param  :属性id
	@param  :回调函数
--]]
function upGrade(p_pageNum,p_attrId,p_callBack)
	local serviceCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "athena.upGrade" then
			if p_callBack ~= nil then
		    	p_callBack()
		    end
		end	

    end
    
    local arg = CCArray:create()
    arg:addObject(CCInteger:create(tonumber(p_pageNum)))
    arg:addObject(CCInteger:create(tonumber(p_attrId)))
    
    Network.rpc(serviceCallBack,"athena.upGrade","athena.upGrade",arg,true)
end

--[[
	@des 	:购买材料
	@param  :物品模板id
	@param  :购买数量
	@param  :回调函数
--]]
function buy(p_itemTid,p_num,p_callBack)
	local serviceCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "athena.buy" then
			if p_callBack ~= nil then
		    	p_callBack(p_num)
		    end
		end	

    end
    
    local arg = CCArray:create()
    arg:addObject(CCInteger:create(tonumber(p_itemTid)))
    arg:addObject(CCInteger:create(tonumber(p_num)))
    
    Network.rpc(serviceCallBack,"athena.buy","athena.buy",arg,true)
end

--[[
	@des 	:合成材料
	@param  :合成次数
	@param  :回调函数
--]]
function synthesis(p_num,p_callBack)
	local serviceCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "athena.synthesis" then
			if p_callBack ~= nil then
		    	p_callBack()
		    end
		end	

    end
    
    local arg = CCArray:create()
    arg:addObject(CCInteger:create(tonumber(p_num)))
    
    Network.rpc(serviceCallBack,"athena.synthesis","athena.synthesis",arg,true)
end
--[[
	@des 	:更换技能
	@param  :技能类型（1普通攻击 2怒气攻击） 技能id
	@param  :回调函数
--]]
function changeSkill(p_type,p_id,p_callBack)
	local serviceCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "athena.changeSkill" then
			if p_callBack ~= nil then
		    	p_callBack()
		    end
		end	

    end
    
    local arg = CCArray:create()
    arg:addObject(CCInteger:create(tonumber(p_type)))
    arg:addObject(CCInteger:create(tonumber(p_id)))
    
    Network.rpc(serviceCallBack,"athena.changeSkill","athena.changeSkill",arg,true)
end


