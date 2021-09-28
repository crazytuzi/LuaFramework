-- FileName: BagEnlargeService.lua 
-- Author: licong 
-- Date: 15/8/7 
-- Purpose: 背包扩充网络接口


module("BagEnlargeService", package.seeall)

-- /**
-- *
-- * 开启格子
-- * 每次开5个
-- *
-- * @param int $gridNum 格子数目, 只接受5
-- * @param int $bagType 背包类型,1装备2道具3宝物4装备碎片5时装6神兵7神兵碎片8符印9符印碎片10锦囊11兵符背包12兵符碎片背包
-- *
-- * @return ok
-- */
function openGridByGold(p_gridNum, p_bagType, p_callBack)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			-- print("--------后端返回数据--getWorldArenaInfo-----------")
			-- print_t(dictData)
			if(p_callBack ~= nil)then
				p_callBack(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ p_gridNum, p_bagType })
	Network.rpc(requestFunc,"bag.openGridByGold","bag.openGridByGold",args,true)
end

-- /**
--  * 开启格子
--  *
--  * @param int $gridNum 格子数目, 只接受5
--  * @param int $bagType 背包类型, 1装备2道具3宝物4装备碎片5时装6神兵7神兵碎片8符印9符印碎片10锦囊11兵符背包12兵符碎片背包
--  *
--  * @return ok
--  */
function openGridByItem(p_gridNum, p_bagType, p_callBack)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			-- print("--------后端返回数据--getWorldArenaInfo-----------")
			-- print_t(dictData)
			if(p_callBack ~= nil)then
				p_callBack(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ p_gridNum, p_bagType })
	Network.rpc(requestFunc,"bag.openGridByItem","bag.openGridByItem",args,true)
end

-- /**
-- * 开启宠物仓库栏位
-- * @param int $num 次数1次5个
-- * @param int $prop 是用物品(1)还是金币(0)
-- */
function openKeeperSlot( p_prop, p_num, p_callBack )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			print("--------后端返回数据--openKeeperSlot-----------")
			print_t(dictData)
			if(p_callBack ~= nil)then
				p_callBack(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ p_prop, p_num })
	Network.rpc(requestFunc,"pet.openKeeperSlot","pet.openKeeperSlot",args,true)
end


-- /**
-- * 开启武将栏位
-- * int $type 1 1是金币开启 2是道具开启   默认是1
-- */
function openHeroGrid( p_type, p_callBack )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			print("--------后端返回数据--openHeroGrid-----------")
			print_t(dictData)
			if(p_callBack ~= nil)then
				p_callBack(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ p_type })
	Network.rpc(requestFunc,"user.openHeroGrid","user.openHeroGrid",args,true)
end


















