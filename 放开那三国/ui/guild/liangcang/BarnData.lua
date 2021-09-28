-- FileName: BarnData.lua 
-- Author: zzh
-- Date: 14-11-7
-- Purpose: 粮仓数据

module("BarnData", package.seeall)

require "db/DB_Grain_shop"
require "script/ui/item/ItemUtil"
require "db/DB_Legion_granary"
require "script/ui/guild/GuildDataCache"

local _shopInfo = nil 		--粮草兑换信息

local _shareInfo = nil      --从后端拉取的粮草分发信息

local _idTable = nil

--[[
	@des 	:设置粮仓信息
	@param 	:粮仓信息
	@return :
--]]
function setShopInfo(p_shopInfo)
	_shopInfo = p_shopInfo
end

--[[
	@des 	:得到粮仓DB数据
	@param 	:物品id
	@return :粮仓信息table
--]]
function getShopDBInfo(p_id)
	local DBInfo = DB_Grain_shop.getDataById(tonumber(p_id))

	--物品信息
	--local itemInfo = ItemUtil.getItemById(DBInfo.items)

	local returnTable = {
		granaryLv = tonumber(DBInfo.GranaryLv),
		id = DBInfo.items,
		costForage = tonumber(DBInfo.CostForage),
		exchangeTimes = tonumber(DBInfo.baseNum),
		--name = itemInfo.name,
		--quality = tonumber(itemInfo.quality),
		costExploit = tonumber(DBInfo.CostExploit),
		limitType = tonumber(DBInfo.limitType)
	}

	return returnTable
end

--[[
	@des 	:解析物品
	@param 	:db中的string
	@return :解析完的
--]]
function analyzeDBItem(p_string)
	return ItemUtil.getItemsDataByStr(p_string)
end

--[[
	@des 	:通过物品id获得商品信息
	@param 	:物品id
	@return :已领取数量
--]]
function getShopInfoById(p_id)
	--返回数据信息
	--因为后端只返回，已经领过奖的物品的信息，所以字段为空表示已领0次
	print("后端商品数据")
	print_t(_shopInfo)
	if _shopInfo[tostring(p_id)] == nil then
		return 0
	else
		return tonumber(_shopInfo[tostring(p_id)].num)
	end
end

--[[
	@des 	:通过id设置改物品已购买数量
	@param 	:物品id
	@return :
--]]
function setBuyItemNumById(p_id,p_num)
	if _shopInfo[tostring(p_id)] == nil then
		_shopInfo[tostring(p_id)] = {}
		_shopInfo[tostring(p_id)].num = p_num
	else
		_shopInfo[tostring(p_id)].num = tonumber(_shopInfo[tostring(p_id)].num) + p_num
	end
end

function dealVisibleOrNot()
	_idTable = {}
	for i = 1,getItemNum() do
		local grainInfo = DB_Grain_shop.getDataById(i)
		if not (tonumber(grainInfo.limitType) == 2
		   and _shopInfo[tostring(i)] ~= nil
		   and tonumber(_shopInfo[tostring(i)].num) >= tonumber(grainInfo.baseNum)) then
			table.insert(_idTable,i)
		end
	end
end

function getVisibleNum()
	return table.count(_idTable)
end

function getIdTable()
	return _idTable
end

--[[
	@des 	:得到粮仓物品数量
	@param 	:
	@return :数量
--]]
function getItemNum()
	return table.count(DB_Grain_shop.Grain_shop)
end

----------------------------------------------------------------- 粮仓数据 --------------------------------------------------

--[[
	@des 	:得到粮仓建筑开启需要军团等级 
	@param 	:
	@return :tab {需要军团大厅等级，需要关公殿等级，需要商店等级，需要军机大厅等级，需要任务大厅等级}
--]]
function getNeedGuildLvForBarn( ... )
	local retTab = {}
	local strTab = string.split(DB_Legion_granary.getDataById(1).needguildLv, ",")
	for k,v in pairs(strTab) do
		local tab = string.split(v, "|")
		table.insert(retTab,tonumber(tab[2]))
	end
	return retTab
end

--[[
	@des 	:得到粮田开启需要粮仓等级
	@param 	:p_id 粮田id
	@return :tab[id] = needLv
--]]
function getOpenLiangTianNeedLv( p_id )
	local retLv = nil
	local strTab = string.split(DB_Legion_granary.getDataById(1).Grainlv, ",")
	for k,v in pairs(strTab) do
		local tab = string.split(v, "|")
		if(tonumber(tab[1]) == tonumber(p_id))then
			retLv = tonumber(tab[2])
			break
		end
	end
	return retLv
end

--[[
	@des 	:得到粮田是否开启
	@param 	:p_id 粮田id
	@return :true 开启
--]]
function getLiangTianIsOpenById( p_id )
	local needBarnLv = getOpenLiangTianNeedLv(p_id)
	local barnLv = GuildDataCache.getGuildBarnLv()
	if(barnLv >= needBarnLv)then
		return true
	else
		return false
	end
end

--[[
	@des 	:得到粮田生产的粮食数量
	@param 	:p_id 粮田id,p_curLv:粮田当前等级
	@return :个人收益功勋，军团收益粮草
--]]
function getLiangTianProduceGrainNum( p_id, p_curLv )
	local retMyNum = 0
	local retGuildNum = 0
	local dbData = DB_Legion_granary.getDataById(1)
	local strTab = string.split(dbData["GrainYield" .. p_id], ",")
	for k,v in pairs(strTab) do
		local tab = string.split(v, "|")
		if(tonumber(tab[1]) == tonumber(p_curLv))then
			retMyNum = tonumber(tab[2])
			retGuildNum = tonumber(tab[3])
			break
		end
	end
	return retMyNum,retGuildNum
end

--[[
	@des 	:得到粮田当前最大等级
	@param 	:p_id 粮田id,
	@return :最大等级 
--]]
function getLiangTianMaxLvNum( p_id )
	local retLv = 0
	local dbData = DB_Legion_granary.getDataById(1)
	local strTab = string.split(dbData["GrainYield" .. p_id], ",")
	local tab = string.split(strTab[#strTab], "|")
	retLv = tonumber(tab[1])
	return retLv
end

--[[
	@des 	:得到粮田升级经验id
	@param 	:p_id 粮田id
	@return :经验id
--]]
function getLiangTianExpId( p_id )
	local dbData = DB_Legion_granary.getDataById(1)
	return tonumber(dbData["GrainUpgrade" .. p_id]) 
end


--[[
	@des 	:得到粮田每天可免费采集次数
	@param 	:p_id 粮田id
	@return :
--]]
function getFreeCollectNumById( p_id )
	local retNum = 0
	local dbData = DB_Legion_granary.getDataById(1)
	local strTab = string.split(dbData.collecttimes, ",")
	for k,v in pairs(strTab) do
		local tab = string.split(v, "|")
		if(tonumber(tab[1]) == tonumber(p_id))then
			retNum = tonumber(tab[2])
			break
		end
	end
	return retNum
end

--[[
	@des 	:得到粮田采集需要消耗的银币
	@param 	:
	@return :num
--]]
function getCollectCost()
	local dbData = DB_Legion_granary.getDataById(1)
	return tonumber(dbData.silverCollect)
end

--[[
	@des 	:得到采集粮田获得的经验
	@param 	:
	@return :num
--]]
function getCollectExp()
	local dbData = DB_Legion_granary.getDataById(1)
	return tonumber(dbData.CollectExp)
end

--[[
	@des 	:得到每天自己刷新粮田次数上限
	@param 	:
	@return :num
--]]
function getMaxRefreshLiangTianNum()
	local dbData = DB_Legion_granary.getDataById(1)
	return tonumber(dbData.refreshtimes)
end

--[[
	@des 	:得到当前刷新粮田花费
	@param 	:p_curNum已经刷新的次数, p_openNum:开启的粮田数量
	@return :num
--]]
function getCurRefreshLiangTianCost( p_curNum )
	local retNum = 0
	local needCost = 0
	local increasingGold = 0
	-- 粮田开启个数
	local openNum = getLiangTianOpenNum()
	local dbData = DB_Legion_granary.getDataById(1)
	-- 刷新基础值
	local strTab = string.split(dbData.refreshcost, ",")
	for k,v in pairs(strTab) do
		local tab = string.split(v, "|")
		if(tonumber(tab[1]) == tonumber(openNum))then
			needCost = tonumber(tab[2])
			break
		end
	end
	-- 递增基础值
	local strTab = string.split(dbData.IncreasingGold, ",")
	for k,v in pairs(strTab) do
		local tab = string.split(v, "|")
		if(tonumber(tab[1]) == tonumber(openNum))then
			increasingGold = tonumber(tab[2])
			break
		end
	end
	retNum = needCost + (tonumber(p_curNum) - 1)*increasingGold
	return retNum
end

--[[
	@des 	:得到每天全部刷新次数上限，一次增加的采集次数
	@param 	:
	@return :num
--]]
function getRefreshAllMaxNumAndAddNum()
	local retNum = 0
	local retAddNum = 0
	local dbData = DB_Legion_granary.getDataById(1)
	local strTab = string.split(dbData.RefreshNumber, ",")
	retNum = tonumber(strTab[1])
	retAddNum = tonumber(strTab[2])
	return retNum,retAddNum
end

--[[
	@des 	:得到购买战书花费
	@param 	:
	@return :num
--]]
function getZhanShuCost()
	local dbData = DB_Legion_granary.getDataById(1)
	return tonumber(dbData.challengecost)
end

--[[
	@des 	:得到分发粮饷冷却时间
	@param 	:
	@return :num
--]]
function getShareFoodCd()
	local dbData = DB_Legion_granary.getDataById(1)
	return tonumber(dbData.ShareForage)
end

--[[
	@des 	:得到粮仓储存粮草上限
	@param 	:p_curLv 粮仓当前等级
	@return :num
--]]
function getSaveGrainMaxNum( p_curLv )
	local retNum = 0
	local dbData = DB_Legion_granary.getDataById(1)
	local strTab = string.split(dbData.ForageUpper, ",")
	for k,v in pairs(strTab) do
		local tab = string.split(v, "|")
		if(tonumber(tab[1]) == tonumber(p_curLv))then
			retNum = tonumber(tab[2])
			break
		end
	end
	return retNum
end

--[[
	@des 	:得到全部刷新是否开启，需要vip，花费
	@param 	:
	@return :
--]]
function getIsOpenRefreshAll( ... )
	require "db/DB_Vip"
	-- 需要的vip
	local needVip = 0
	local needCost = 0
	local i = 1
	for k,v in pairs(DB_Vip.Vip) do
        local vInfo = DB_Vip.getDataById(tostring(i))
        local strArr = string.split(vInfo.GrainRefresh, "|")
        -- 1是开启0是未开启
        if(tonumber(strArr[1]) == 1)then
        	needVip = tonumber(vInfo.level)
        	needCost = tonumber(strArr[2])
            break
        end
        i = i+1
    end

    -- 是否开启
    local isOpen = false
    if( UserModel.getVipLevel() >= needVip )then
    	isOpen = true
    else
    	isOpen = false
    end

	return isOpen, needVip, needCost
end

--[[
	@des 	:得到粮田个数
	@param 	:
	@return :
--]]
function getLiangTianAllNum()
	local retNum = 0
	local strTab = string.split(DB_Legion_granary.getDataById(1).Grainlv, ",")
	retNum = table.count(strTab)
	return retNum
end

--[[
	@des 	:得到解锁的粮田个数
	@param 	:
	@return :
--]]
function getLiangTianOpenNum()
	local retNum = 0
	local allNum = getLiangTianAllNum()
	for i=1,allNum do
		local isOpen = getLiangTianIsOpenById(i)
    	if(isOpen)then
    		retNum = retNum + 1
    	end
	end
	return retNum
end

--[[
	@des 	:根据id得粮田名字
	@param 	:p_id 粮田id
	@return :str
--]]
function getNameById( p_id )
	local retName = " " 
	local dbData = DB_Legion_granary.getDataById(1)
	local strTab = string.split(dbData.ForageName, "|")
	for k,v in pairs(strTab) do
		if(tonumber(p_id) == tonumber(k))then
			retName = v
			break
		end
	end
	return retName
end

--[[
	@des 	:根据粮仓等级得到粮田的级别上限
	@param 	:p_curLv 粮仓等级
	@return :num
--]]
function getLiangTianMaxLvByBarnLv( p_curLv )
	local retNum = 0
	local dbData = DB_Legion_granary.getDataById(1)
	local strTab = string.split(dbData.LevelLimit, ",")
	for i=1,#strTab do
		local tab = string.split(strTab[i], "|")
		if(tonumber(p_curLv) >= tonumber(tab[1]))then
			retNum = tonumber(tab[2])
		end
	end
	return retNum
end

--[[
	@des 	:得到挑战书最大携带数量
	@param 	:
	@return :num
--]]
function getFightBookMaxNum( ... )
	local dbData = DB_Legion_granary.getDataById(1)
	return tonumber(dbData.challengeLimitnum)
end

--[[
	@des 	:得到小丰收刷新最大次数，小丰收增加采集次数，消耗建设度
	@param 	:
	@return :num
--]]
function getSmallRefreshMaxNum()
	local retMaxNum = 0
	local retAddNum = 0
	local retNeedCost = 0
	local dbData = DB_Legion_granary.getDataById(1)
	local strTab = string.split(dbData.DevoteRefresh, ",")
	retMaxNum = tonumber(strTab[1])
	retAddNum = tonumber(strTab[2])
	-- 开启的粮田数
	local openNum = getLiangTianOpenNum()
	-- 粮田对应的建设度
	local strTab = string.split(dbData.DevoteRefreshcost, ",")
	-- 已经使用的小丰收次数
	local useNum = GuildDataCache.getAlreadyUseSmallNum()
	if(useNum+1 < table.count(strTab) )then
		-- 需要的基础值
		local needCost1 = tonumber(strTab[useNum+1])
		retNeedCost = needCost1 * openNum
	else
		-- 需要的基础值
		local needCost1 = tonumber(strTab[#strTab])
		retNeedCost = needCost1 * openNum
	end
	return retMaxNum,retAddNum,retNeedCost
end

--[[
	@des 	:得到粮田的最大可累计采集次数
	@param 	:
	@return :num
--]]
function getLiangTianCollectMaxNum( ... )
	local dbData = DB_Legion_granary.getDataById(1)
	return tonumber(dbData.MaxCollectTimes)
end
-----------------------------[[ 粮草分发 ]]----------------------------------------
--[[
	@des 	: 存储粮草分发信息
	@param 	:
	@return :
--]]
function setShareInfo( pInfo )
	_shareInfo = pInfo
end

--[[
	@des 	: 获取粮草分发信息
	@param 	:
	@return :
--]]
function getShareInfo( ... )
	return _shareInfo
end

--[[
	@des 	: 获取分发的总粮草
	@param 	:
	@return :
--]]
function getTotalShare( ... )
	if table.isEmpty(_shareInfo) then
		return 0
	end

	local total = 0
	for k,v in pairs(_shareInfo) do
		if k ~= 1 then
			total = total + tonumber(v.share) * tonumber(v.num)
		end
	end
	return total
end

-----------------------------[[ 刷新全部粮田 ]]----------------------------------------
local _refreshAllInfo = {}

--[[
	@des 	: 设置刷新粮田信息
	@param 	: p_Info 谁刷新了全部粮田
	@return :
--]]
function setRefreshAllInfo( p_Info )
	_refreshAllInfo = p_Info
end

--[[
	@des 	: 得到刷新粮田信息
	@param 	:
	@return :
--]]
function getRefreshAllInfo( )
	return _refreshAllInfo 
end

--[[
	@des 	: 添加刷新粮田信息
	@param 	: p_name 刷新粮田玩家名字
	@return :
--]]
function addRefreshAllInfo( p_name )
	if( p_name ~= nil)then
		table.insert(_refreshAllInfo,p_name)
	end
end


--[[
	@des 	: 得到新成员分粮时间限制
	@param 	: 
	@return : 秒数
--]]
function getShareLimitTime()
	require "db/DB_Normal_config"
	local time = DB_Normal_config.getDataById(1).grainLimitTime
	return tonumber(time)
end

