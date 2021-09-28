-- Filename：	MineralElvesService.lua
-- Author：		bzx
-- Date：		2016-05-12
-- Purpose：		资源矿宝藏

module ("MineralElvesService", package.seeall)

require "script/ui/active/mineral/MineralElvesData"

-- /**
--  * 根据矿页domain_id获取当前页的精灵信息
--  * @param int $domain_id
--  * return  array(4) {
--  *                                ["domain_id"]=>int(60003)
--  *                                 ["uid"]=>int(20585)
--  *                                 ["start_time"]=>float(1462863620)
--  *                                 ["end_time"]=>float(1462863920)
--  *                                 }
--  */
function getMineralElvesByDomainId(p_domainId, p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			MineralElvesData.setCurMineralElvesDatas(dictData.ret);
			if(p_callbackFunc ~= nil) then
				p_callbackFunc(dictData.ret)
			end
		end
	end
	if not MineralElvesData.isOpen() then
		requestFunc(nil, {ret = {}}, true)
		return
	end
	local args = CCArray:create()	
	args:addObject(CCInteger:create(p_domainId))
	Network.no_loading_rpc(requestFunc, "mineralelves.getMineralElvesByDomainId", "mineralelves.getMineralElvesByDomainId", args, true)
	-- local dictData = {}
	-- dictData.ret = {
	-- 	{
	-- 		uid = 111,
	-- 		uname = "123155",
	-- 		guild_name = "ff",
	-- 		level = 14
	-- 	}
	-- }
	-- requestFunc(nil, dictData, true)
end

-- /**
--  * 占领这个矿精灵
--  * @param int $domain_id
--  * return array(
--  *                           ["fight_ret"]=>
-- 	 *			                             string(812) "战报"
-- 	 *	                          ["appraisal"]=>
--   *                                      string(3) "SSS"
--   *                           ["elves_info"]=>     
--   *                           				 array(4) {
--   *                                                           ["domain_id"]=>int(60005)
--   *                                                           ["uid"]=>int(20589)
--   *                                                           ["start_time"]=>float(1462862851)
--   *                                                            ["end_time"]=> float(1462863151)
--   *                                                            }
--   *                          )
--  */
function occupyMineralElves(p_domainId, p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(p_callbackFunc ~= nil) then
				p_callbackFunc(dictData.ret)
			end
		end
	end
	local args = CCArray:create()	
	args:addObject(CCInteger:create(p_domainId))
	Network.rpc(requestFunc, "mineralelves.occupyMineralElves", "mineralelves.occupyMineralElves", args, true)
end

-- /**
-- * 获取玩家自己的精灵信息，没有就返回空array
-- * return array(
-- * 												["domain_id"]=>int(60003)
-- *                                 				["uid"]=>int(20585)
-- *                                 				["start_time"]=>float(1462863620)
-- *                                 				["end_time"]=>float(1462863920)
-- * )
-- */
function getSelfMineralElves(p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			MineralElvesData.setSelfMineralElvesData(dictData.ret)
			if(p_callbackFunc ~= nil) then
				p_callbackFunc(dictData.ret)
			end
		end
	end
	if not MineralElvesData.isOpen() then
		requestFunc(nil, {ret = {}}, true)
		return
	end
	Network.rpc(requestFunc, "mineralelves.getSelfMineralElves", "mineralelves.getSelfMineralElves", nil, true)
end

-- 宝藏状态变化推送
function pushMineralelvesUpdate(p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(p_callbackFunc ~= nil) then
				p_callbackFunc(dictData.ret)
			end
		end
	end
	Network.re_rpc(requestFunc, "push.mineralelves.update", "push.mineralelves.update")
end

-- 宝藏抢夺推送
-- * <code>
--      * [
--      * 		'domain_id'
--      * 		'pre_capture'
--      * 		'now_capture'
--      * 		'rob_time'
--      * ]
function pushMineralelvesRob(p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(p_callbackFunc ~= nil) then
				p_callbackFunc(dictData.ret)
			end
		end
	end
	Network.re_rpc(requestFunc, "push.mineralelves.rob", "push.mineralelves.rob")
end

function leave(p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(p_callbackFunc ~= nil) then
				p_callbackFunc(dictData.ret)
			end
		end
	end
	Network.no_loading_rpc(requestFunc, "mineralelves.leave", "mineralelves.leave", nil, true)
end

