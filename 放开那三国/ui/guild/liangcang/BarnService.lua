-- FileName: BarnService.lua 
-- Author: 	zzh
-- Date: 14-11-7
-- Purpose: 粮仓网络层

module("BarnService", package.seeall)

require "script/ui/guild/liangcang/BarnData"
require "script/ui/guild/GuildDataCache"

--[[
	@des 	:获取粮仓数据信息
	@param 	:回调函数
	@return :
--]]
function getShopInfo(p_callBack)
	local getShopInfoCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		print("返回的数据")
		print_t(dictData.ret)

		if cbFlag == "barnshop.getShopInfo" then
			--设置数据
			BarnData.setShopInfo(dictData.ret)

			BarnData.dealVisibleOrNot()

			--UI回调
			p_callBack()
		end
	end

	Network.rpc(getShopInfoCallBack, "barnshop.getShopInfo","barnshop.getShopInfo", nil, true)
end

--[[
	@des 	:兑换物品
	@param 	: $ p_itemId 		:物品id
	@param 	: $ p_num 			:物品数量
	@param 	: $ p_callBack 		:回调函数
	@return :
--]]
function exchangeItem(p_itemId,p_num,p_callBack)
	local bugCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end

		if cbFlag == "barnshop.buy" then
			--设置数据
			BarnData.setBuyItemNumById(p_itemId,p_num)

			--UI回调
			p_callBack(p_num)
		end
	end

	local args = CCArray:create()
	args:addObject(CCInteger:create(p_itemId))
	args:addObject(CCInteger:create(p_num))

	Network.rpc(bugCallBack,"barnshop.buy","barnshop.buy",args,true)
end

-- /**
-- * 采集
-- * 
-- * @param int $p_id 		粮田id(1,2,3,4,5)	
-- * @param int $num 		采集次数	
-- * @return string $ret 		处理结果
-- * 'ok'						成功
-- */
function harvest(p_id,p_num,callbackFunc)
	local requestFunc = function ( cbFlag, dictData, bRet )
		print ("harvest---后端数据")
		if(dictData.err == "ok")then
			local dataRet = dictData.ret
			print("dictData.ret")
			print_t(dataRet)
			if(callbackFunc ~= nil)then
				callbackFunc(dataRet)
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(tonumber(p_id)))
	args:addObject(CCInteger:create(tonumber(p_num)))
	Network.rpc(requestFunc, "guild.harvest", "guild.harvest", args, true)
end

-- /**
-- * 刷新自己粮田
-- * 
-- * @return string $ret 		处理结果
-- * 'ok'						成功
-- */
function refreshOwn(callbackFunc)
	local requestFunc = function ( cbFlag, dictData, bRet )
		print ("refreshOwn---后端数据")
		if(dictData.err == "ok")then
			local dataRet = dictData.ret
			print("dictData.ret")
			print_t(dataRet)
			if(dataRet == "ok")then
				if(callbackFunc ~= nil)then
					callbackFunc()
				end
			end
		end
	end
	Network.rpc(requestFunc, "guild.refreshOwn", "guild.refreshOwn", nil, true)
end

-- /**
-- * 刷新全体粮田
-- * @param int $type 		 	1是用金币，2是用建设度	
-- * @return string $ret 		处理结果
-- * 'ok'						成功
-- */
function refreshAll(p_type, callbackFunc)
	local requestFunc = function ( cbFlag, dictData, bRet )
		print ("refreshAll---后端数据")
		if(dictData.err == "ok")then
			local dataRet = dictData.ret
			print("dictData.ret")
			print_t(dataRet)
			if(dataRet == "noexp")then
				require "script/ui/tip/AnimationTip"
				AnimationTip.showTip(GetLocalizeStringBy("lic_1401"))
				return
			elseif(dataRet == "ok")then
				if(callbackFunc ~= nil)then
					callbackFunc()
				end
			else
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(tonumber(p_type)))
	Network.rpc(requestFunc, "guild.refreshAll", "guild.refreshAll", args, true)
end

-- /**
-- * 购买战书
-- *
-- * @return string $ret 		处理结果
-- * 'ok'						成功
-- */
function buyFightBook(callbackFunc)
	local requestFunc = function ( cbFlag, dictData, bRet )
		print ("buyFightBook---后端数据")
		if(dictData.err == "ok")then
			local dataRet = dictData.ret
			print("dictData.ret")
			print_t(dataRet)
			if(dataRet == "ok")then
				-- 扣除金币
				local fightBookCost = BarnData.getZhanShuCost()
		    	-- 扣除军团建设度
	    		GuildDataCache.addGuildDonate(-fightBookCost)
		    	-- 增加挑战书数量
		    	GuildDataCache.addGuildFightBookNum(1)

				if(callbackFunc ~= nil)then
					callbackFunc()
				end
			end
		end
	end
	Network.rpc(requestFunc, "guild.buyFightBook", "guild.buyFightBook", nil, true)
end

-- /**
-- * 获得抢夺信息列表
-- * 
-- * @param int $offset	分页位置
-- * @param int $limit	每页大小
-- * 
-- * @return array
-- * <code>
-- * {
-- * 		{
-- *			'guild_id':			军团id
-- * 			'guild_name':		军团名称
-- * 			'rob_grain':		抢粮数量
-- * 			'rob_free':			可抢粮数量
-- * 			'rob_time':			抢粮时间
-- * 		}
-- * }
-- * </code>
-- */
function getEnemyList(p_offset, p_limit, callbackFunc )
	local requestFunc = function ( cbFlag, dictData, bRet )
		print ("getEnemyList---后端数据")
		if(dictData.err == "ok")then
			local dataRet = dictData.ret
			print("dictData.ret")
			print_t(dataRet)
			if(callbackFunc ~= nil)then
				callbackFunc(dataRet)
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(tonumber(p_offset)))
	args:addObject(CCInteger:create(tonumber(p_limit)))
	Network.rpc(requestFunc, "guild.getEnemyList", "guild.getEnemyList", args, true)
end


-- /**
-- * 分配粮草
-- * 
-- * @return int $num 个人分得粮草数量
-- */
function share(callbackFunc)
	local requestFunc = function ( cbFlag, dictData, bRet )
		print ("share---后端数据")
		if(dictData.err == "ok")then
			local dataRet = dictData.ret
			print("dictData.ret")
			print_t(dataRet)
			if(callbackFunc ~= nil)then
				callbackFunc(dataRet)
			end
		end
	end
	Network.rpc(requestFunc, "guild.share", "guild.share", nil, true)
end

-- /**
-- * 获取分粮信息(数组)
-- * 
-- * @return array 
-- * <code>
-- * {
-- *     职位=>(粮草数,人数)
-- *     0 => (total) 军团粮草总数
-- *     1 => (share, num) 军团长
-- *     2 => (share, num) 副军团长
-- *     3 => (share, num) 顶级精英(1-5)
-- *     4 => (share, num) 高级精英(6-10)
-- *     5 => (share, num) 精英成员(10-20)
-- *     6 => (share, num) 普通成员(20-30)
-- * }
-- * </code>
-- */
function getShareInfo(callbackFunc)
	local requestFunc = function ( cbFlag, dictData, bRet )
		print ("getShareInfo---后端数据")
		if(dictData.err == "ok")then
			local dataRet = dictData.ret
			print("dictData.ret")
			print_t(dataRet)
			-- 已经分过粮 重新拉数据更新
			if(dataRet == "nograin")then
				require "script/ui/tip/AnimationTip"
				AnimationTip.showTip(GetLocalizeStringBy("lic_1395"))
				-- 粮草置为0
				GuildDataCache.setGuildGrainNum(0)
				-- 刷新粮草数量
				require "script/ui/guild/liangcang/LiangCangMainLayer"
				LiangCangMainLayer.refreshGuildGrainNum()
			else
				if(callbackFunc ~= nil)then
					callbackFunc(dataRet)
				end
			end
		end
	end
	Network.rpc(requestFunc, "guild.getShareInfo", "guild.getShareInfo", nil, true)
end


-- /**
-- * 获取刷新的用户列表
-- * 
-- * @return array 
-- * <code>
-- * {
-- *   0 => $uname 用户名
-- * }
-- * </code>
-- * 
-- */
function getRefreshInfo(callbackFunc)
	local requestFunc = function ( cbFlag, dictData, bRet )
		print ("getRefreshInfo---后端数据")
		if(dictData.err == "ok")then
			local dataRet = dictData.ret
			print("dictData.ret")
			print_t(dataRet)
			-- 设置刷新粮田信息
			BarnData.setRefreshAllInfo(dataRet)
			if(callbackFunc ~= nil)then
				callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "guild.getRefreshInfo", "guild.getRefreshInfo", nil, true)
end

-- /**
-- * 获得粮田的采集列表
-- *
-- * @param int $fieldId			粮田id
-- * @return array
-- * <code>
-- * {
-- * 		{
-- *			'uname':			用户名称
-- *			'num':				采集次数
-- *			'time:				采集时间
-- *			'add_grain':		增加粮草
-- * 			'add_exp':			增加经验
-- * 			'add_level':		增加等级
-- * 			'grain_output':		粮草产量
-- * 			'merit_output':		功勋产量
-- * 		}
-- * }
-- * </code>
-- */
function getHarvestList(p_Id,callbackFunc)
	local requestFunc = function ( cbFlag, dictData, bRet )
		print ("getHarvestList---后端数据")
		if(dictData.err == "ok")then
			local dataRet = dictData.ret
			print("dictData.ret")
			print_t(dataRet)
			if(callbackFunc ~= nil)then
				callbackFunc(dataRet)
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(tonumber(p_Id)))
	Network.rpc(requestFunc, "guild.getHarvestList", "guild.getHarvestList", args, true)
end

-- /**
-- * 一键采集
-- * 
-- * @return array 
-- * <code>
-- * {
-- * 		0 => $grainNum	军团当前粮草
-- * 		1 => $meritNum	成员当前功勋
-- * 		2 => $sumGrain  军团增加粮草
-- * 		3 => $sum		采集次数
-- * 		4 => array
-- * 		{
-- * 			1 => array
-- * 			{
-- * 				0 => $addExp
-- * 				1 => $addLevel
-- * 			}
-- * 			2 => array
-- * 			{
-- * 				0 => $addExp
-- * 				1 => $addLevel
-- * 			}
-- * 		}
-- * }
-- * </code>
-- */
function quickHarvest(callbackFunc)
	local requestFunc = function ( cbFlag, dictData, bRet )
		print ("quickHarvest---后端数据")
		if(dictData.err == "ok")then
			print("dictData.ret")
			print_t(dictData.ret)
			if(callbackFunc ~= nil)then
				callbackFunc(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc, "guild.quickHarvest", "guild.quickHarvest", nil, true)
end


