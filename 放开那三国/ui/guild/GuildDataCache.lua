-- Filename：	GuildDataCache.lua
-- Author：		Cheng Liang
-- Date：		2013-12-21
-- Purpose：		缓存军团的数据


module("GuildDataCache", package.seeall)

local _isInGuild 			= false -- 是否在军团的相关界面

local va_hall_index 		= 1 	-- 公告
local va_zhongyitang_index 	= 2 	-- 军团大厅等级也就是军团等级
local va_guanyu_index 		= 3 	-- 关公殿的下标
local va_shop_index			= 4		-- 军团商店的下标
local va_copy_index			= 5		-- 军机大厅（也就是军团副本）的下标
local va_book_index 		= 6 	-- 军团任务（也是就军团任务）的下标
local va_liangcang_index 	= 7     -- 粮仓下标
local va_skill_index 		= 8		-- 科技下标

local _mineSigleGuildInfo 	= nil	-- 我自己个人在联盟中的信息
local _guildInfo 			= nil	-- 我所在的军团的信息
local _memberInfoList 		= nil 	-- 成员列表

local _requestMemberDelegate = nil 	-- 拉取成员信息列表

local _recordList = nil -- record 信息

local _guildShopInfo		= nil	-- 军团商店的信息 added by zhz


-- 是否在军团界面
function isInGuildFunc()
	return _isInGuild
end

-- 设置是否在军团界面
function setIsInGuildFunc(isInGuild)
	_isInGuild = isInGuild
end

-- 清理缓存
function cleanCache()
	_mineSigleGuildInfo 	= nil
	_guildInfo 				= nil
	_memberInfoList 		= nil

	_requestMemberDelegate = nil
end

-- 设置个人军团信息
function setMineSigleGuildInfo( mineSigleGuildInfo)
	_mineSigleGuildInfo = mineSigleGuildInfo
end

-- 获取个人军团信息
-- /**
-- * 获得成员的详细信息
-- * 
-- * @return array 
-- * <code>
-- * {
-- * 		'uid':				用户id
-- * 		'guild_id':			军团id, 0是没有在任何军团里
-- * 		'guild_level':		军团等级
-- * 		'member_type':		成员类型：0团员，1团长，2副团
-- * 		'contri_point':		贡献值
-- * 		'contri_num':		当天剩余贡献次数
-- * 		'contri_time':		贡献时间
-- * 		'reward_num':		当天剩余领奖次数
-- * 		'reward_time':		领奖时间
-- * 		'reward_buy_num':	奖励购买次数
-- * 		'reward_buy_time':	奖励购买时间
-- * 		'lottery_num':		当天摇奖次数
-- * 		'lottery_time':		摇奖时间
-- * 		'grain_num':		粮草数量
-- * 		'merit_num':		功勋值
-- * 		'refresh_num':		自己刷新已用次数
-- * 		'rejoin_cd':		冷却时间
-- *        'playwith_num':     当天切磋次数
-- *        'be_playwith_num':  当天被切磋次数
-- *        'city_id':			占领的城池Id
-- *        'fight_force':int	军团战斗力
-- * 		'rank':int			军团排名
-- *		'member_num':int 	成员数量
-- * 		'va_member':array
-- * 		{
-- * 			'fields':array
-- * 			{
-- * 				$id				粮田id
-- * 				{
-- * 					0 => $num	剩余次数
-- * 					1 => $time	采集时间
-- * 				}
-- * 			}
-- * 		}
-- * }
-- * </code>
-- */
function getMineSigleGuildInfo()
	return _mineSigleGuildInfo
end

-- 增减切磋次数
function addPlayDefeautNum( add_times )
	_mineSigleGuildInfo.playwith_num = tonumber(_mineSigleGuildInfo.playwith_num) + add_times
end

-- 设置军团信息
function setGuildInfo( guildInfo)
	_guildInfo = guildInfo
end

-- 获取军团信息
-- /**
-- * 获取军团信息
-- * 
-- * @return array 
-- * <code>
-- * {
-- * 		'guild_id':			军团id
-- * 		'guild_name':		军团名称
-- * 		'guild_level':		军团等级
-- * 		'fight_force':		军团战斗力
-- * 		'upgrade_time':		升级时间
-- * 		'create_uid':		创建者uid
-- * 		'create_time':		创建时间
-- * 		'join_num':			当天加入人数
-- * 		'join_time':		上次加入时间
-- * 		'contri_num':		当天贡献次数
-- * 		'contri_time':		上次贡献时间
-- * 		'reward_num':		当天领奖次数
-- * 		'reward_time':		上次领奖时间
-- * 		'grain_num':		粮草数量
-- * 		'refresh_num':		军团刷新已用次数
-- *		"refresh_num_byexp":军团建设度刷新粮田次数
-- * 		'attack_num':		抢粮次数
-- * 		'fight_book':		战书数量
-- * 		'curr_exp':			当前贡献值
-- * 		'share_cd':			分粮冷却时间
-- * 		'status':			状态
-- * 		'va_info':
-- * 		{	
-- * 			0 =>			
-- * 			{	
-- * 				'slogan':	宣言
-- * 				'post':		公告
-- * 			}
-- * 			1 =>			忠义堂
-- * 			{
-- * 				'level':	等级
-- * 				'allExp':	贡献总值
-- * 			}
-- * 			2 =>			关公殿
-- * 			{
-- * 				'level':	等级
-- * 				'allExp':	贡献总值
-- * 			}
-- * 			3 =>			商城
-- * 			{
-- * 				'level':	等级
-- * 				'allExp':	贡献总值
-- * 			}
-- * 			4 =>			副本
-- * 			{
-- * 				'level':	等级
-- * 				'allExp':	贡献总值
-- * 			}
-- * 			5 =>			任务
-- * 			{
-- * 				'level':	等级
-- * 				'allExp':	贡献总值
-- * 			}
-- * 			6 =>			粮仓
-- * 			{
-- * 				'level':	等级
-- * 				'allExp':	贡献总值
-- *				'fields':array
-- * 						{
-- * 					$id				粮田id
-- * 					{
-- * 						0 => $level	等级
-- * 						1 => $exp	经验
-- * 					}
-- * 				}
-- * 			}
-- * 		}
-- * 		'leader_uid':		团长uid
-- * 		'leader_uid':		团长utid
-- * 		'leader_name':		团长名字
-- * 		'leader_level':		团长等级
-- * 		'leader_force':		团长战斗力
-- * 		'member_num':		成员数量
-- * 		'member_limit':		成员上限
-- * 		'vp_num':			副团长数量
-- * 		'rank':				战斗力排行
-- * }
-- * </code>
-- */
function getGuildInfo()
	return _guildInfo
end

-- 获取加入军团时间
function getMyJoinGuildTime( ... )
	return tonumber(_mineSigleGuildInfo.join_time)
end

-- 获取军团名称
function getGuildName( ... )
	if( not table.isEmpty(_guildInfo) ) then
		return _guildInfo.guild_name
	else
		return nil
	end	
end

-- 设置军团名称
function setGuildName( p_name )
	if( not table.isEmpty(_guildInfo) ) then
		_guildInfo.guild_name = p_name
	end	
end

-- 得到修改军团名称花费
function getGuildNameCost()
	require "db/DB_Normal_config"
	local data = DB_Normal_config.getDataById(1)
	local retNum = tonumber(data.changeLegionName)
	return retNum
end


-- 获取军团战斗力 没有返回nil
function getGildFightForce( ... )
	if( not table.isEmpty(_guildInfo) ) then
		return _guildInfo.fight_force
	else
		return nil
	end	
end

-- 获得个人信息中的军团id
function getMineSigleGuildId( ... )
	local guild_id = 0
	if( (not table.isEmpty(_mineSigleGuildInfo)) and _mineSigleGuildInfo.guild_id ~= nil  and tonumber(_mineSigleGuildInfo.guild_id) > 0 ) then
		guild_id = tonumber(_mineSigleGuildInfo.guild_id)
	end
	return guild_id
end

-- 获得军团id, guild_id
function getGuildId( ... )
	local guild_id = 0
	if( (not table.isEmpty(_guildInfo))  and tonumber(_guildInfo.guild_id) > 0 ) then
		guild_id = tonumber(_guildInfo.guild_id)
	end
	return guild_id
end

--增加军团副团长个数
function addGuildVPNum(addVPNum)
	_guildInfo.vp_num = tonumber(_guildInfo.vp_num) + tonumber(addVPNum)
end

-- 获取军团的宣言
function getSlogan()
	return _guildInfo.va_info[va_hall_index].slogan
end

-- 修改军团的宣言
function setSlogan(slogan)
	_guildInfo.va_info[va_hall_index].slogan = slogan
end

-- 获取军团的公告
function getPost()
	return _guildInfo.va_info[va_hall_index].post
end

-- 修改军团的公告
function setPost(post)
	_guildInfo.va_info[va_hall_index].post = post
end

-- 得到军团成员个数
function getGuildMemberNum()
	return tonumber(_guildInfo.member_num)
end

-- 我今天的捐献次数
function getMineDonateTimes()
	return tonumber(_mineSigleGuildInfo.contri_num)
end

-- 增减我今天的捐献次数
function addMineDonateTimes(addLv)
	_mineSigleGuildInfo.contri_num = tonumber(_mineSigleGuildInfo.contri_num) + tonumber(addLv)
end

-- 修改我的权限信息
function changeMineMemberType(m_type)
	_mineSigleGuildInfo.member_type = m_type
end

-- 得到我在军团中的职务 0为平民，1为会长，2为副会长
function getMineMemberType()
	return tonumber(_mineSigleGuildInfo.member_type)
end

-- 增减军团成员个数
function addGuildMemberNum( addLv )
	_guildInfo.member_num = tonumber(_guildInfo.member_num) + addLv
end

-- 增加建筑物等级
function addGuildLevelBy( b_type, addLv, addDonate )
	if(b_type == 2)then
		-- 是军团大厅
		_guildInfo.guild_level = tostring( tonumber(_guildInfo.guild_level) + tonumber(addLv) )
		_mineSigleGuildInfo.guild_level = tonumber(_mineSigleGuildInfo.guild_level) + tonumber(addLv) 

	end
	_guildInfo.va_info[b_type].level = tostring( tonumber(_guildInfo.va_info[b_type].level) + tonumber(addLv) )
	_guildInfo.va_info[b_type].allExp = tostring( tonumber(_guildInfo.va_info[b_type].allExp) + tonumber(addDonate) )
end

-- 军团大厅的等级
function getGuildHallLevel()
	
	return tonumber(_mineSigleGuildInfo.guild_level )
end

-- 获得个人总贡献
function getSigleDoante()
	if(_mineSigleGuildInfo and _mineSigleGuildInfo.contri_point)then
		return tonumber(_mineSigleGuildInfo.contri_point)
	else
		return 0
	end
end

-- 增减个人总贡献
function addSigleDonate(p_addDonate)
	local addDonate = p_addDonate or 0
	_mineSigleGuildInfo.contri_point = tonumber(_mineSigleGuildInfo.contri_point) + tonumber(addDonate)
end

-- 增减军团建设度
function addGuildDonate( p_addDonate )
	local addDonate = p_addDonate or 0
	_guildInfo.curr_exp = tonumber(_guildInfo.curr_exp) +  tonumber(addDonate)
end

--获得军团建设度
function getGuildDonate()
	if(_guildInfo and _guildInfo.curr_exp)then
		return tonumber(_guildInfo.curr_exp)
	else
		return 0
	end
end

-- 获得关公殿的等级
function getGuanyuTempleLevel()
	return tonumber(_guildInfo.va_info[va_guanyu_index].level)
end

-- 修改关公殿的等级
function addGuanyuTempleLevel( addLv)
	_guildInfo.va_info[va_guanyu_index].level = tonumber(_guildInfo.va_info[va_guanyu_index].level) + tonumber(addLv)
end

-- 获得军团商店的等级
function getShopLevel( )
	return tonumber(_guildInfo.va_info[va_shop_index].level) 
end

-- 获得军机大厅的等级
function getCopyHallLevel( ... )
	return tonumber(_guildInfo.va_info[va_copy_index].level) 
end

-- 任务大厅等级
function getGuildBookLevel( ... )
	return tonumber(_guildInfo.va_info[va_book_index].level )
end

--军团总参拜次数
function getGuildRewardTimes()
	return tonumber(_guildInfo.reward_num)
end

--增减军团总参拜次数
function addGuildRewardTimes(addTimes)
	_guildInfo.reward_num = tonumber(_guildInfo.reward_num) + tonumber(addTimes)
end

-- 剩余拜关公次数
function getBaiGuangongTimes()
	return tonumber(_mineSigleGuildInfo.reward_num)
end

-- 增减拜关公次数
function addBaiGuangongTimes( addTimes )
	_mineSigleGuildInfo.reward_num = tonumber(_mineSigleGuildInfo.reward_num) + tonumber(addTimes)
end

--金币参拜关公殿次数
function getCoinBaiTimes()
	return tonumber(_mineSigleGuildInfo.reward_buy_num)
end

--增减金币拜关公次数
function addCoinBaiTimes(addTimes)
	_mineSigleGuildInfo.reward_buy_num = tonumber(_mineSigleGuildInfo.reward_buy_num) + tonumber(addTimes)
end

-- 设置成员列表
function setMemberInfoList(memberInfoList)
	_memberInfoList = memberInfoList
end

-- 获取成员列表
function getMemberInfoList()
	return _memberInfoList
end

-- 军团请求回调
function sendRequestMemberCallback(  cbFlag, dictData, bRet  )
	if(dictData.err == "ok")then
		_memberInfoList = dictData.ret
		if(_requestMemberDelegate)then
			_requestMemberDelegate()
		end
	end
end

--- 获取成员列表
function sendRequestForMemberList(requestMemberDelegate)
	_requestMemberDelegate = requestMemberDelegate
	local args = Network.argsHandler(0, 99)
	RequestCenter.guild_getMemberList(sendRequestMemberCallback, args)
end

-- 获取某个成员的信息
function getMemberInfoBy( uid )
	uid = tonumber(uid)
	local m_info = {}
	for k,v in pairs(_memberInfoList.data) do
		if(tonumber(v.uid) == uid )then
			m_info = v
			break
		end
	end

	return m_info
end

--获得军团人数上限
function getMemberLimit()
	return tonumber(_guildInfo.member_limit)
end


-- 设置军团商店 added by zhz
function setShopInfo( shopInfo )
	_guildShopInfo = shopInfo
	print("获得军团商店信息_guildShopInfo")
	print_t(_guildShopInfo)
end

-- 获得军团商店信息
function getShopInfo( )
	
	return _guildShopInfo
end

-- 获得军团商店珍品信息
function getSpecialGoodsInfo( )
	return _guildShopInfo.special_goods
end

-- 获得军团商店刷新刷新时间
function getShopRefreshCd()
	-- return  tonumber(_guildShopInfo.refresh_cd) - BTUtil:getSvrTimeInterval()
	require "script/utils/TimeUtil"
	local endShieldTime = tonumber(_guildShopInfo.refresh_cd)
	-- print(" time  is : ")
	-- print_t(os.date("*t",tonumber(_guildShopInfo.refresh_cd)))
    local havaTime = endShieldTime - TimeUtil.getSvrTimeByOffset()--BTUtil:getSvrTimeInterval()+1
    if(havaTime > 0) then
        return havaTime
    else
        return 0
    end
end

-- 设置军团商店珍品信息和刷新时间
function setSpecialGoodsInfo( special_goods,refreshCd )
	_guildShopInfo.special_goods= special_goods
	_guildShopInfo.refresh_cd= refreshCd
end


--[[
    @des:       通过DB_Legion_goods的id来获得道具中已经购买的次数v{sum ,num}
    @return:    sum: 军团购买次数 
    			num: 个人购买次数
    			若无则 sum 和num都为 0
]]
function getNorBuyNumById( id)
	local normal_goods= _guildShopInfo.normal_goods
	for goodId,v  in pairs(normal_goods) do
		if(tonumber(goodId) == tonumber(id)) then
			return v 
		end
	end
	return {num=0,sum=0 }
end



--
function getNorAlreadyBuyNumById( id )
	local alreadyBuyNum = 0
	local normal_goods= _guildShopInfo.normal_goods
	if(not table.isEmpty(normal_goods))then
		for goodId,v  in pairs(normal_goods) do
			if(tonumber(goodId) == tonumber(id)) then
				alreadyBuyNum = tonumber(v.num) 
			end
		end
	end
	return alreadyBuyNum
end


--[[
    @des:       通过DB_Legion_goods的id来获得珍品已经购买的次数v{sum ,num}
    @return:    sum: 军团购买次数 
    			num: 个人购买次数
    			若无则 sum 和num都为 0
]]
function getSpecialBuyNumById( id)
	local special_goods= _guildShopInfo.special_goods
	for goodId,v  in pairs(special_goods) do
		if(tonumber(goodId) == tonumber(id) and not table.isEmpty(v) ) then
			return v 
		end
	end
	return {num=0,sum=0 }
end

--通过ID，设置guildShopInfo 中珍品的
function addSpecialBuyNumById(id,addSum, addNum )
	for goodId,v  in pairs(_guildShopInfo.special_goods) do
		if(tonumber(goodId) == tonumber(id)) then
			if(_guildShopInfo.special_goods[tostring(goodId)].sum) then
				_guildShopInfo.special_goods[tostring(goodId)].sum= _guildShopInfo.special_goods[tostring(goodId)].sum+ addSum
			else
				_guildShopInfo.special_goods[tostring(goodId)].sum= addSum
			end
			if(	_guildShopInfo.special_goods[tostring(goodId)].num) then
				_guildShopInfo.special_goods[tostring(goodId)].num= _guildShopInfo.special_goods[tostring(goodId)].num+ addNum
			else
				_guildShopInfo.special_goods[tostring(goodId)].num= addNum
			end
			ishas = true
		end
	end
end

-- 通过id, 设置
function addNorBuyNumById(id,addSum, addNum )
	
	local ishas= false
	
	for goodId,v  in pairs(_guildShopInfo.normal_goods) do
		if(tonumber(goodId) == tonumber(id)) then
			print("addNum=======",addNum)
			_guildShopInfo.normal_goods[tostring(goodId)].num= _guildShopInfo.normal_goods[tostring(goodId)].num+ addNum
			print("_guildShopInfo.normal_goods[tostring(goodId)].num")
			print_t(_guildShopInfo.normal_goods[tostring(goodId)])
			if (GuildUtil.getNormalGoodById(id).baseNum - _guildShopInfo.normal_goods[tostring(goodId)].num) <= 0 then
				--如果剩余次数为0了
				require "script/ui/shopall/GuildShopLayer"
				GuildShopLayer.refreshGoodTableView()
			end
			if(_guildShopInfo.normal_goods[tostring(goodId)].sum) then
				_guildShopInfo.normal_goods[tostring(goodId)].sum= _guildShopInfo.normal_goods[tostring(goodId)].sum+ addSum
			end
			ishas = true
		end
	end

	if(ishas==false) then
		_guildShopInfo.normal_goods[tostring(id)]= {sum= addSum, num = addNum}
	end
end

-- 后端推送商品信息的处理
function addPushGoodsInfo( goodInfo)
	
	-- 道具处理
	local normal_goods= _guildShopInfo.normal_goods
	for id , v in pairs(goodInfo) do
		-- 判断id是否为道具
		local goodData= DB_Legion_goods.getDataById(id)
		if(goodData.goodType == 2 ) then

			local ishas= false
			for goodId, values in pairs(normal_goods) do
				if(tonumber(id) == tonumber(goodId)) then
					normal_goods[tostring(goodId)].sum = v.sum
					ishas = true
				end
			end
			if(ishas== false) then
				normal_goods[tostring(id)]= { sum = v.sum, num= 0}
			end
		end
	end

	-- 珍品处理
	local special_goods =  _guildShopInfo.special_goods
	for id , v in pairs(goodInfo) do
		-- local ishas= false
		local goodData= DB_Legion_goods.getDataById(id)
		if(goodData.goodType == 1 ) then
			for goodId, values in pairs(special_goods) do
				if(tonumber(id) == tonumber(goodId)) then
					special_goods[tostring(goodId)].sum = v.sum
					-- ishas = true
				end
			end
		end
		-- if(ishas== false) then
		-- 	special_goods[tostring(id)]= { sum = v.sum, num= 0}
		-- end
	end

end

function isCanBaiGuangong()
	require "script/utils/TimeUtil"
	local curTime = TimeUtil.getSvrTimeByOffset()
	local date = os.date("*t", curTime)
	local nowHour = date.hour
	local nowMin = date.min
	local nowSec = date.sec

	local nowTime = tonumber(nowHour)*10000 + tonumber(nowMin)*100 + tonumber(nowSec)

	local canBai = false
	local mineData = getMineSigleGuildInfo()
	if ((not table.isEmpty(mineData))  and tonumber(mineData.guild_id) > 0 ) then
		--在军团
		require "db/DB_Legion_feast"
		if (tonumber(nowTime) >= tonumber(DB_Legion_feast.getDataById(1).beginTime)) and (tonumber(nowHour) <= tonumber(DB_Legion_feast.getDataById(1).endTime))then
			if tonumber(getBaiGuangongTimes()) > 0 then
				canBai = true
			end
		end
	end

	return canBai
end

function isShowTip()
	require "script/ui/guild/copy/GuildTeamData"
	local isShow = false
	--因为军机大厅没有判断是否在军团里，所以又加了一层
	if ((not table.isEmpty(getMineSigleGuildInfo()))  and tonumber(getMineSigleGuildInfo().guild_id) > 0 ) then
		if (isCanBaiGuangong()) or (GuildTeamData.getLeftGuildAtkNum() > 0) then
			isShow = true
		end
	end

	return isShow
end


-- 城池加成只有该玩家所在军团占领的城池有相应加成的时候 才会进行加成
--- added by zhz 
--[[ 
	rewardType: 
	1.军团组队银币奖励
	2.试练塔银币奖励
	3.摇钱树银币奖励
	4.普通副本银币奖励
	5.精英副本银币奖励
	6.资源矿银币奖励
--]]
--[[
	@des 	:得到城池对其他模块的银币加成，首先判断玩家是否有军团，是否占领的城池，并且
	@param 	: 加成类型rewardType: 同上
	@return : rewardTab= {
			isHas: 		是否有加成
			rate：		加成比例 (< 1, 需要加成)
			rewardType:	同上
			name:		加成类型的名字
		}
]]
function getGuildCityRewardRate( rewardType )

	require "script/ui/guild/city/CityData"
	local rewardTab =  { isHas= false , rate= 0, reardType=0 }
	local rewardType = tonumber(rewardType)

	-- print("_mineSigleGuildInfo.city_id ", _mineSigleGuildInfo.city_id)
	-- _mineSigleGuildInfo.city_id = 5

	if( table.isEmpty(_mineSigleGuildInfo) or _mineSigleGuildInfo.city_id== nil or tonumber(_mineSigleGuildInfo.city_id)== 0) then
		return rewardTab
	end

	local city_id = tonumber(_mineSigleGuildInfo.city_id)
	local dataTab=  CityData.getExtraRewardByCityId(city_id)

	if(dataTab.rewardType== rewardType ) then
		rewardTab= dataTab
		rewardTab.isHas = true 
	end
	return rewardTab

end

------------------------------------------ 主界面军团按钮小红圈优化 ---------------------
-- 每次登录就显示一次，点击后消失
local _isShowTip 			= nil   -- 小红圈

function setIsShowRedTip( p_isShow )
	_isShowTip = p_isShow
end

function getIsShowRedTip( ... )
	return _isShowTip
end

-- 是否显示主界面军团上小红点
function isShowRedTip( ... )
	local retData = false
	require "script/ui/guild/GuildDataCache"
	require "script/ui/guild/city/CityData"
	if( GuildDataCache.isShowTip() or CityData.getIsShowTip() )then
		retData = true
	end
	return retData
end

---------------------------------------------军团成员列表中 官阶相关 开始---------------------------------------
--[[
	@desc : 根据排名获得对应官阶（军团长、副军团长除外）
	@param:
	@ret  : 官阶
	3 顶级精英 排名：1-5（军团长、副军团长除外）
	4 高级精英 排名：6-10
	5 精英成员 排名：11-20
	6 普通成员 排名：20-30
--]]
local function getGradeByRank( pRank )
	if pRank <= 5 then
		return 3
	elseif pRank <= 10 then
		return 4
	elseif pRank <= 20 then
		return 5
	else
		return 6
	end
end

--[[
	@desc : 根据对应官阶颜色（军团长、副军团长除外）
	@param:
	@ret  : 官阶颜色
--]]
function getGradeColorByType( pGrade )   
	-- 前两个充数的 团员从3开始
	local colorArr = {
		ccc3(0xff, 0xff, 0xff),
		ccc3(0xff, 0xff, 0xff),
		ccc3(0xff, 0x00, 0xe1),
		ccc3(0x51, 0xfb, 0xff),
		ccc3(0x00, 0xeb, 0x21),
		ccc3(0xff, 0xff, 0xff)
	}
	return colorArr[tonumber(pGrade)]
end

--根据官阶获得官阶名称
function getGradeName( pGrade )
	local gradeNameTable = {
		[1] = GetLocalizeStringBy("zz_142"), [2] = GetLocalizeStringBy("zz_143"), 
		[3] = GetLocalizeStringBy("zz_144"), [4] = GetLocalizeStringBy("zz_145"), 
		[5] = GetLocalizeStringBy("zz_146"), [6] = GetLocalizeStringBy("zz_147"),
	}
	return gradeNameTable[tonumber(pGrade)]
end

--[[
	@desc : 排序方便划分官阶
	1.总贡献值越大越靠前
	2.总贡献值相同时，贡献时间越先越靠前
	@param:
	@ret  : 
--]]
local function sortMemberGrade( pDataTable )
	local sortFunc = function ( pData1, pData2 )
		if tonumber(pData1.contri_total) > tonumber(pData2.contri_total) then
			return true
		elseif tonumber(pData1.contri_total) == tonumber(pData2.contri_total) then
			if tonumber(pData1.contri_time) < tonumber(pData2.contri_time) then
				return true
			else
				return false
			end
		else
			return false
		end
	end
	table.sort(pDataTable, sortFunc)
end

--[[
	成员划分官阶
	1 军团长
	2 副军团长
	3 顶级精英 排名：1-5（军团长、副军团长除外）
	4 高级精英 排名：6-10
	5 精英成员 排名：11-20
	6 普通成员 排名：20-30
--]]
function updateMemberGrade( )
	local copyData = {}
	for k,v in pairs(_memberInfoList.data) do
		table.insert(copyData,v)   --copyData中的table元素仍指向_memberInfoList.data的table元素
	end

	--为后面方便划分官阶进行排序
	sortMemberGrade(copyData)

	-- print("copyData==")
	-- print_t(copyData)
	local count = 0
	for i=1,#copyData do
		if tonumber(copyData[i].member_type) == 1 then
			copyData[i].member_grade = 1
		elseif tonumber(copyData[i].member_type) == 2 then
			copyData[i].member_grade = 2
		else
			-- member_type = 0 普通团员
			count = count + 1
			copyData[i].member_grade = getGradeByRank(count)
		end
		-- 添加军团成员总贡献排名
		copyData[i].contri_rank = i
	end
end
---------------------------------------------军团成员列表中 官阶相关 结束---------------------------------------
-------------------------------------------------------军团粮仓数据--------------------------------

--[[
	@des 	:得到军团粮仓是否开启
	@param 	:
	@return :num
--]]
function getBarnIsOpen()
	local retData = false
	if GuildDataCache.getMineSigleGuildId() == 0 then
		return false
	end
	-- 军团等级
	local guildLv = getGuildHallLevel()
	local guanGongLv = getGuanyuTempleLevel()
	local shopLv = getShopLevel()
	local copyLv = getCopyHallLevel()
	local taskLv = getGuildBookLevel()
	require "script/ui/guild/liangcang/BarnData"
	local needLvTab = BarnData.getNeedGuildLvForBarn()
	print("guildLv",guildLv,"guanGongLv",guanGongLv,"shopLv",shopLv,"copyLv",copyLv,"taskLv",taskLv)
	print_t(needLvTab)
	if( guildLv >= needLvTab[1] and guanGongLv >= needLvTab[2] and shopLv >= needLvTab[3] and copyLv >= needLvTab[4] and taskLv >= needLvTab[5])then
		retData = true
	end
	return retData
end


--[[
	@des 	:得到军团粮仓等级
	@param 	:
	@return :num
--]]
function getGuildBarnLv()
	return tonumber(_guildInfo.va_info[va_liangcang_index].level)
end

--[[
	@des 	:得到军团粮挑战书数量
	@param 	:
	@return :num
--]]
function getGuildFightBookNum()
	local retNum = 0
	if(_guildInfo.fight_book ~= nil)then 
		retNum = tonumber(_guildInfo.fight_book)
	end
	return retNum
end

--[[
	@des 	:增加军团粮挑战书数量
	@param 	:p_num
	@return :num
--]]
function addGuildFightBookNum(p_num)
	if(_guildInfo.fight_book ~= nil)then 
		_guildInfo.fight_book = tonumber(_guildInfo.fight_book) + tonumber(p_num)
	else
		_guildInfo.fight_book = tonumber(p_num)
	end
end


function setGuildFightBookNum( p_num )
	_guildInfo.fight_book = tonumber(p_num)
end

--[[
	@des 	:得到军团下次发粮时间
	@param 	:
	@return :num
--]]
function getGuildShareNextTime()
	local retNum = 0
	if(_guildInfo.share_cd ~= nil)then 
		retNum = tonumber(_guildInfo.share_cd)
	end
	return retNum
end

--[[
	@des 	:设置军团下次发粮时间
	@param 	:p_time 下次粮时间戳
	@return :num
--]]
function setGuildShareNextTime( p_time )
	_guildInfo.share_cd = tonumber(p_time)
end

--[[
	@des 	:得到军团粮草数量
	@param 	:
	@return :num
--]]
function getGuildGrainNum()
	local retNum = 0
	if(_guildInfo.grain_num ~= nil)then 
		retNum = tonumber(_guildInfo.grain_num)
	end
	return retNum
end

--[[
	@des 	:设置军团粮草数量
	@param 	:p_num
	@return :num
--]]
function setGuildGrainNum( p_num )
	_guildInfo.grain_num = tonumber(p_num)
end

--[[
	@des 	:增加军团粮草数量
	@param 	:p_num
	@return :num
--]]
function addGuildGrainNum( p_num )
	local num = p_num or 0
	_guildInfo.grain_num = tonumber(_guildInfo.grain_num) + tonumber(p_num)
end


--[[
	@des 	:得到我自己的粮草数量
	@param 	:
	@return :num
--]]
function getMyselfGrainNum()
	local retNum = 0
	if(_mineSigleGuildInfo.grain_num ~= nil)then  
		retNum = tonumber(_mineSigleGuildInfo.grain_num)
	end
	return retNum
end

--[[
	@des 	:设置个人粮草数量
	@param 	:p_num
	@return :num
--]]
function setMyselfGrainNum( p_num )
	_mineSigleGuildInfo.grain_num = tonumber(p_num)
end


--[[
	@des 	:设置个人粮草数量
	@param 	:p_num
	@return :num
--]]
function addMyselfGrainNum( p_num )
	if(table.isEmpty(_mineSigleGuildInfo) or _mineSigleGuildInfo.grain_num == nil)then 
		return
	end
	local num = p_num or 0
	_mineSigleGuildInfo.grain_num = tonumber(_mineSigleGuildInfo.grain_num) + tonumber(num)
end



--[[
	@des 	:得到我自己的功勋值
	@param 	:
	@return :num
--]]
function getMyselfMeritNum()
	local retNum = 0
	if(_mineSigleGuildInfo.merit_num ~= nil)then  
		retNum = tonumber(_mineSigleGuildInfo.merit_num)
	end
	return retNum
end

--[[
	@des 	:设置我自己的功勋值
	@param 	: p_num
	@return :num
--]]
function setMyselfMeritNum( p_num )
	_mineSigleGuildInfo.merit_num = tonumber(p_num)
end


--[[
	@des 	:增加自己的功勋值
	@param 	:p_num
	@return :num
--]]
function addMyselfMeritNum( p_num )
	local num = p_num or 0
	_mineSigleGuildInfo.merit_num = tonumber(_mineSigleGuildInfo.merit_num) + tonumber(num)
end


--[[
	@des 	:得到刷新粮田已用次数
	@param 	:
	@return :num
--]]
function getAlreadyRefreshOwnNum()
	local retNum = 0
	if(_mineSigleGuildInfo.refresh_num ~= nil)then  
		retNum = tonumber(_mineSigleGuildInfo.refresh_num)
	end
	return retNum
end

--[[
	@des 	:设置刷新粮田已用次数
	@param 	:p_num 已用的次数
	@return :num
--]]
function setAlreadyRefreshOwnNum( p_num )
	_mineSigleGuildInfo.refresh_num = tonumber(p_num)
end

--[[
	@des 	:得到金币刷新全部已用次数 大丰收已经使用次数
	@param 	:
	@return :num
--]]
function getAlreadyRefreshAllNum()
	local retNum = 0
	if(_guildInfo.refresh_num ~= nil)then  
		retNum = tonumber(_guildInfo.refresh_num)
	end
	return retNum
end


--[[
	@des 	:设置金币刷新全部已用次数 大丰收已经使用次数
	@param 	:p_num 已用的次数
	@return :num
--]]
function setAlreadyRefreshAllNum( p_num )
	_guildInfo.refresh_num = tonumber(p_num)
end

--[[
	@des 	:得到建设度刷新全部已用次数 小丰收已经使用次数
	@param 	:
	@return :num
--]]
function getAlreadyUseSmallNum()
	local retNum = 0
	if(_guildInfo.refresh_num_byexp ~= nil)then  
		retNum = tonumber(_guildInfo.refresh_num_byexp)
	end
	return retNum
end


--[[
	@des 	:设置建设度刷新全部已用次数 小丰收已经使用次数
	@param 	:p_num 已用的次数
	@return :num
--]]
function setAlreadyUseSmallNum( p_num )
	_guildInfo.refresh_num_byexp = tonumber(p_num)
end


--[[
	@des 	:得到粮田的剩余采集次数,等级,总经验
	@param 	:p_id
	@return :num
--]]
function getSurplusCollectNumAndExpLv(p_id)
	local retNum = 0
	local retExp = 0
	local retLv = 0
	if(not table.isEmpty(_mineSigleGuildInfo.va_member.fields) )then 
		if( _mineSigleGuildInfo.va_member.fields[tostring(p_id)] )then
			retNum = tonumber(_mineSigleGuildInfo.va_member.fields[tostring(p_id)][1])
		end
	end
	if(not table.isEmpty(_guildInfo.va_info[va_liangcang_index].fields) )then  
		if( _guildInfo.va_info[va_liangcang_index].fields[tostring(p_id)] )then
			retLv = tonumber(_guildInfo.va_info[va_liangcang_index].fields[tostring(p_id)][1])
			retExp = tonumber(_guildInfo.va_info[va_liangcang_index].fields[tostring(p_id)][2])
		end
	end
	return retNum,retLv,retExp
end

--[[
	@des 	:设置粮田的剩余采集次数
	@param 	:p_id粮田id p_curNum 当前剩余次数
	@return :num
--]]
function setSurplusCollectNumById(p_id,p_curNum)
	if(not table.isEmpty(_mineSigleGuildInfo.va_member.fields) )then  
		if(_mineSigleGuildInfo.va_member.fields[tostring(p_id)] ~= nil)then
			_mineSigleGuildInfo.va_member.fields[tostring(p_id)][1] = tonumber(p_curNum)
		end
	end
end

--[[
	@des 	:设置粮田的总经验,等级
	@param 	:p_id p_allExp p_curLv
	@return :num
--]]
function setLiangTianExpAndLv(p_id,p_allExp,p_curLv)
	if(not table.isEmpty(_guildInfo.va_info[va_liangcang_index].fields) )then  
		if(_guildInfo.va_info[va_liangcang_index].fields[tostring(p_id)] ~= nil)then
			_guildInfo.va_info[va_liangcang_index].fields[tostring(p_id)][1] = tonumber(p_curLv)
			_guildInfo.va_info[va_liangcang_index].fields[tostring(p_id)][2] = tonumber(p_allExp)
		end
	end
end
 
--[[
	@des 	:推送更新 粮田的剩余采集次数,等级,总经验
	@param 	: p_newData
	@return :
--]]
-- 推送结构
-- 军团粮田全体刷新推送
 -- * const GUILD_REFRESH_ALL			= 'push.guild.refreshAll';
 -- * <code>
 -- * [
 -- * 		0 => $uname
 -- * 		1 => array
 -- * 		{
 -- *    		$id 粮田id
 -- * 	  		{
 -- * 		 		0 => $num	剩余次数
 -- * 		 		1 => $time	时间
 -- * 			}
 -- * 		}
 -- * 		2 => $type 1是花费金币大丰收推送 2是建设度刷新小丰收推送
 -- * ]
 -- * </code> 
function updateSurplusCollectNum( p_newData )
	if( not table.isEmpty(p_newData) )then
		if(tonumber(p_newData[3]) == 1)then
			-- 花费金币大丰收推送
			setAlreadyRefreshAllNum( getAlreadyRefreshAllNum() + 1 )
			-- 谁使用了这个功能
			require "script/ui/guild/liangcang/BarnData"
			BarnData.addRefreshAllInfo(p_newData[1])
		elseif(tonumber(p_newData[3]) == 2)then
			-- 建设度刷新小丰收推送
			setAlreadyUseSmallNum( getAlreadyUseSmallNum() + 1 )
		else
			print("updateSurplusCollectNum no type")
		end

		-- 粮田信息
		for n_id,n_data in pairs(p_newData[2]) do
			_mineSigleGuildInfo.va_member.fields[tostring(n_id)] = n_data
		end
	end
	print("push newData")
	print_t(_mineSigleGuildInfo.va_member.fields)
end
 
--[[
	@des 	:推送更新 粮田的等级,总经验
	@param 	: p_newData
	@return :
--]]
-- [42] 军团粮仓粮田等级经验信息推送
--     * const GUILD_FIELD_HARVEST		= 'push.guild.fieldHarvest';
--     * <code>
--     * [
--     * 		0 => $level
--     * 		1 => $exp
--     * ]
--     * </code>
function updateLiangTianLvAndExp( p_newData )
	if( table.isEmpty(_guildInfo) )then
		return
	end
	if( not table.isEmpty(p_newData) )then
		-- 粮田信息
		for n_id,n_data in pairs(p_newData) do
			_guildInfo.va_info[va_liangcang_index].fields[tostring(n_id)] = n_data
		end
	end
	print("push newData")
	print_t(_guildInfo.va_info[va_liangcang_index].fields)
end

--[[
	@des 	:推送更新 只有第一次进入粮仓界面cd使用 初始cd
	@param 	: p_newData
	@return :
--]]
-- [42] 军团粮仓分粮冷却时间推送
--     * const GUILD_FIELD_HARVEST		= 'push.guild.shareCd';
--     * <code>
--     * [
--     * 		$time
--     * ]
--     * </code>
function updateShareCd( p_newData )
	print("+++++++++++++++++++++++++++++++++++++++++++++++p_newData")
	print_t(p_newData)
	if( not table.isEmpty(p_newData) )then
		local shareCd = getGuildShareNextTime()
		if(shareCd == 0)then
			setGuildShareNextTime(p_newData[1])
		end
	end
end

--[[
	@des 	:得到所有粮田的剩余采集次数
	@param 	:
	@return :num
--]]
function getAllSurplusCollectNum( ... )
	require "script/ui/guild/liangcang/BarnData"
	local retNum = 0
	local liangtianNum = BarnData.getLiangTianAllNum()
    for i=1,liangtianNum do
    	local isOpen = BarnData.getLiangTianIsOpenById(i)
    	if(isOpen)then
    		-- 开启的粮田的剩余次数
    		local surplusCollectNum,a,b = GuildDataCache.getSurplusCollectNumAndExpLv(i)
    		retNum = retNum + surplusCollectNum
    	end
    end
    return retNum
end

-----------------------------------------------------军团开宝箱数据----------------------------------------------------
--[[
	@des 	:得到开宝箱已用次数
	@param 	:
	@return :num
--]]
function getGuildBoxAlreadyUseNum()
	local retNum = 0
	if(_mineSigleGuildInfo.lottery_num ~= nil)then  
		retNum = tonumber(_mineSigleGuildInfo.lottery_num)
	end
	return retNum
end


--[[
	@des 	:设置开宝箱已用次数
	@param 	:p_num 已用的次数
	@return :num
--]]
function setGuildBoxAlreadyUseNum( p_num )
	_mineSigleGuildInfo.lottery_num = tonumber(p_num)
end

-- added by bzx
-------------------------------军团军旗-------------------------
--[[
	@desc: 		得到军团军旗的ID
	@return:	number
--]]
function getGuildIconId()
	local guildIconId = tonumber(_guildInfo.guild_icon)
	return guildIconId
end

--[[
	@desc:				设置军团军旗的Id
	@p_guildIconId: 	军团军旗的Id
	@return:			nil
--]]
function setGuildIconId( p_guildIconId )
	_guildInfo.guild_icon = p_guildIconId
end

--[[
	@des:得到所在军团人数
--]]
function getMemberCount()
	return tonumber(_mineSigleGuildInfo.member_num)
end


--[[
	@des:	得到战功
--]]
function getExploitsCount( ... )
	return tonumber(_mineSigleGuildInfo.zg_num)
end

--[[
	@des:	增加/减少战功
--]]
function addExploitsCount( p_addValue )
	_mineSigleGuildInfo.zg_num = tonumber(_mineSigleGuildInfo.zg_num) + p_addValue
end

-------------------------------- 军团科技 ----------------------------------
--[[
	@desc: 		获取军团科技大厅是否开启
	@return:	number 军团科技是否开启
--]]
function getGuildSkillIsOpen()
	local isOpen = false
	if (GuildDataCache.getMineSigleGuildId() == 0) then
		return isOpen
	end
	-- 军团大厅等级
	local guildHallLv = getGuildHallLevel()
	require "script/ui/guild/GuildUtil"
	local skillneedLvTab = GuildUtil.getGuildSkillOpenNeedLv()
	if( guildHallLv >= skillneedLvTab[1] )then
		isOpen = true
	end
	return isOpen
end

--[[
	@desc:		获取后端军团科技等级
	@param:		pSkillId 科技Id
	@return:	number 军团科技等级
--]]
function getGuildGroupSkillLv( pSkillId )
	local retLevel = 0
	local skillsInfo = _guildInfo.va_info[va_skill_index].skills or {}
	if (skillsInfo[tostring(pSkillId)] ~= nil) then
		retLevel = tonumber(skillsInfo[tostring(pSkillId)])
	end
	return retLevel
end

--[[
	@desc:		获取后端军团成员科技信息
	@return:	tab {id - level} 军团成员科技信息 
--]]
function getGuildMemberSkillInfo()
	-- 判断没有开启军团的情况
	if (table.isEmpty(_mineSigleGuildInfo) or table.isEmpty(_mineSigleGuildInfo.va_member)) then
		return nil
	end
	local skillInfo = {}
	if (not table.isEmpty(_mineSigleGuildInfo.va_member.skills)) then
		skillInfo = _mineSigleGuildInfo.va_member.skills
	end
	return skillInfo
end

--[[
	@desc:		获取后端军团成员科技等级
	@param:		pSkillId 科技Id
	@return:	number 军团成员科技等级
--]]
function getGuildMemberSkillLv( pSkillId )
	local retLevel = 0
	local skillsInfo = _mineSigleGuildInfo.va_member.skills or {}
	if (skillsInfo[tostring(pSkillId)] ~= nil) then
		retLevel = tonumber(skillsInfo[tostring(pSkillId)])
	end
	return retLevel
end

--[[
	@desc:		设置军团的科技等级
	@param:		pSkillId 科技Id
	@param:		pSkillLv 科技等级
--]]
function setGuildGroupSkillLv( pSkillId , pSkillLv )
	if (table.isEmpty(_guildInfo.va_info[va_skill_index].skills)) then
		-- 初始化 skills
		_guildInfo.va_info[va_skill_index].skills = {}
	end
	_guildInfo.va_info[va_skill_index].skills[tostring(pSkillId)] = tonumber(pSkillLv)
end

--[[
	@desc:		设置军团成员科技等级
	@param:		pSkillId 科技Id
	@param:		pSkillLv 科技等级
--]]
function setGuildMemberSkillLv( pSkillId , pSkillLv )
	if (table.isEmpty(_mineSigleGuildInfo.va_member.skills)) then
		-- 初始化 skills
		_mineSigleGuildInfo.va_member.skills = {}
	end
	_mineSigleGuildInfo.va_member.skills[tostring(pSkillId)] = tonumber(pSkillLv)
end

--[[
	@desc:	增减军团人数上限
	@param:	pNum 人数
--]] 
function addGuildMemberLimit( pNum )
	_guildInfo.member_limit = tonumber(_guildInfo.member_limit) + tonumber(pNum)
end