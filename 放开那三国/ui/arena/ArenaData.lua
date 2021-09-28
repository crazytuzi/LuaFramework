-- FileName: ArenaData.lua 
-- Author: Li Cong 
-- Date: 13-8-12 
-- Purpose: function description of module 

require "script/model/user/UserModel"
module("ArenaData", package.seeall)

-- 全局变量
arenaInfo = nil                         -- 竞技场数据
luckyListData = nil                     -- 幸运排名数据
rewardData = nil						-- 领取奖励数据
rankListData = nil                      -- 排行榜前十数据
challengeData = nil                     -- 挑战后返回数据
scheduleId_data = nil					-- 数据定时器
arenaScheduleId = {}           			-- 竞技UI定时器
rankScheduleId = nil 					-- 排名UI定时器

local listData 					=  nil 		-- 竞技场挑战对手列表缓存数据
allUserData = nil 							-- 竞技场创建挑战列表tableView用数据

--得到table的大小
function tableCount(ht)
    if(ht == nil) then
        return 0
    end
    local n = 0
    for _, v in pairs(ht) do
        n = n + 1
    end
    return n;
end

-- 得到自己竞技场当前排名
function getSelfRanking()
	return tonumber(arenaInfo.position)
end

-- 设置自己竞技场当前排名
function setSelfRanking( position )
	if(arenaInfo == nil)then
		return
	end
	arenaInfo.position = position
end

-- -- 得到今日剩余挑战次数 这种算法已舍弃
-- function getTodaySurplusNum()
-- 	return tonumber(arenaInfo.challenge_num)
-- end

-- -- 设置今日剩余挑战次数 这种算法已舍弃
-- function setTodaySurplusNum( num )
-- 	arenaInfo.challenge_num = num
-- end

-- 得到领奖倒计时
function getAwardTime()
	local time = arenaInfo.reward_time
	return tonumber(time)
end

-- 设置倒计时
function setAwardTime( time )
	arenaInfo.reward_time = time
end

-- 设置opponents 挑战列表数据
function setOpponentsData( opponents_data )
	listData = opponents_data
end

-- 得到opponents 挑战列表数据
function getOpponentsData( ... )
	local data = {}
	if(listData == nil)then
		return data
	end
	data = getAllUserData(listData)
	print("得到的opponents数据")
	print_t(data)
	return data
end

-- 得到竞技场玩家的数据(包括主角)
--[[
 Table[1] ={
    [level] => 17   		-- 等级
    [position] => 1 		-- 排名
    [utid] => 2   			-- 用户模板id
    [uid] => 21921 			-- 用户id
    [uname] => 789789 		-- 用户名字
    [luck] => 0				-- 是否处在幸运位置 0不是,1是
}
--]]
function getAllUserData( arenaUserData )
	local tData = {}
	for k,v in pairs(arenaUserData) do
		tData[#tData+1] = v
	end
	-- 按position从小到大重新生成新表
	for i=1,tableCount(tData) do
		for j=1,tableCount(tData)-i do
			if(tonumber(tData[j].position) > tonumber(tData[j+1].position) )then
				-- 交换位置
				tData[j],tData[j+1] = tData[j+1],tData[j]
			end
		end
	end
	-- print(GetLocalizeStringBy("key_3108"))
	-- print_t(tData)
	-- 添加新元素 是否是幸运位置 
	if(luckyListData ~= nil)then
		for k,v in pairs(tData) do
			-- 遍历当前幸运位置
			for x,y in pairs(luckyListData.current) do
				if(tonumber(v.position) == tonumber(y.position))then
					-- 在幸运位置 为1
					v.luck = 1
					break
				else 
					-- 否则为0
					v.luck = 0
				end
			end
		end
	end
	-- print(GetLocalizeStringBy("key_1367"))
	-- print_t(tData)
	return tData
end


-- 得到排名奖励
-- 参数 position:排名位置,level:等级
-- 返回
-- 银币数量,将魂数量,物品表
--[[
table = {
	 [1] => Table
        (
            [item_id] => 80001
            [item_num] => 1
        )
    [2] => Table
        (
            [item_id] => 80002
            [item_num] => 2
        )
	}
--]]
function getAwardItem( position, level)
	print("position",position)
	local  n_position = position
	require "db/DB_Arena_reward"
	-- 超过配置的奖励按最后一名显示
	print(GetLocalizeStringBy("key_3273"),table.count(DB_Arena_reward.Arena_reward))
	if( tonumber(position) > table.count(DB_Arena_reward.Arena_reward))then
		n_position = table.count(DB_Arena_reward.Arena_reward)
	end
	local data = DB_Arena_reward.getDataById( n_position )
	
	-- 表里基础值
	local coin = tonumber(data.reward_coin) 
	-- local soul = tonumber(data.reward_soul)
	-- 新需求 根据自己的等级计算奖励 显示为 自己的等级*奖励基础值  by 2013.12.09
	local level = UserModel.getHeroLevel()
	-- 基础值*max(level,30)
	local lv = math.max(tonumber(level),30)
	-- 声望
	local prestige = tonumber(data.reward_prestige)
	-- 活动奖励系数
	local active_rate = tonumber(arenaInfo.active_rate) or 1
	return coin*lv*active_rate, prestige*active_rate, data.reward_item_ids
end


-- 得到排行榜前十玩家数据
--[[
 Table[1] ={
    [level] => 17   		-- 等级
    [position] => 1 		-- 排名
    [utid] => 2   			-- 用户模板id
    [uid] => 21921 			-- 用户id
    [uname] => 789789 		-- 用户名字
    [luck] => 0				-- 是否处在幸运位置 0不是,1是
}
--]]
function getTopTenData( tUserData )
	local tData = {}
	for k,v in pairs(tUserData) do
		tData[#tData+1] = v
	end

	-- 如果只有一个人直接返回
	if(tableCount(tData) < 2 )then
		return tData
	end

	-- 按position从小到大重新生成新表
	for i=1,tableCount(tData) do
		for j=1,tableCount(tData)-i do
			if(tonumber(tData[j].position) > tonumber(tData[j+1].position) )then
				-- 交换位置
				tData[j],tData[j+1] = tData[j+1],tData[j]
			end
		end
	end
	-- 添加新元素 是否是幸运位置 
	if(luckyListData ~= nil)then
		for k,v in pairs(tData) do
			-- 遍历当前幸运位置
			for x,y in pairs(luckyListData.current) do
				if(tonumber(v.position) == tonumber(y.position))then
					-- 在幸运位置 为1
					v.luck = 1
					break
				else 
					-- 否则为0
					v.luck = 0
				end
			end 
		end
	end
	-- print(GetLocalizeStringBy("key_2283"))
	-- print_t(tData)
	return tData
end


-- 根据位置得到玩家的uid
function getUidByPosition( position )
	local uid = nil
	if(allUserData == nil)then
		return
	end
	for k,v in pairs(allUserData) do
		if(tonumber(position) == tonumber(v.position))then
			uid = tonumber(v.uid)
		end
	end
	return uid
end


-- 得到挑战胜利后获得的银币和将魂,exp
-- 表配置*自己等级
function getCoinAndSoulForWin()
	require "db/DB_Arena_properties"
	local data = DB_Arena_properties.getDataById(1)
	local base_coin = tonumber(data.win_base_coin)
	local base_soul = tonumber(data.win_base_soul)
	local base_exp = tonumber(data.win_base_exp)
	local base_prestige = tonumber(data.winPrestige)
	require "script/model/user/UserModel"
	local level = tonumber(UserModel.getUserInfo().level)
	return math.min(tonumber(data.win_max_coin),base_coin*level), base_soul*level, base_exp*level, base_prestige
end


-- 得到挑战失败后获得的银币和将魂,exp
-- 表配置*自己等级
function getCoinAndSoulForFail()
	require "db/DB_Arena_properties"
	local data = DB_Arena_properties.getDataById(1)
	local base_coin = tonumber(data.lose_base_coin)
	local base_soul = tonumber(data.lose_base_soul)
	local base_exp = tonumber(data.lose_base_exp)
	local base_prestige = tonumber(data.losePrestige)
	require "script/model/user/UserModel"
	local level = tonumber(UserModel.getUserInfo().level)
	return math.min(tonumber(data.lose_max_coin),base_coin*level), base_soul*level, base_exp*level, base_prestige
end


-- 得到竞技列表中玩家的信息 
function getHeroDataByUid( uid )
	local tab = {}
	-- print("zzzzzzzzz")
	-- print_t(allUserData)
	for k,v in pairs(allUserData) do
		-- print("uid = ",uid,"v.uid= ",v.uid)
		if(tonumber(uid) == tonumber(v.uid))then
			tab = v
		end
	end
	return tab
end


-- 玩家名字的颜色
function getHeroNameColor( utid )
	local name_color = nil
	local stroke_color = nil
	if(tonumber(utid) == 1)then
		-- 女性玩家
		name_color = ccc3(0xf9,0x59,0xff)
		stroke_color = ccc3(0x00,0x00,0x00)
	elseif(tonumber(utid) == 2)then
		-- 男性玩家 
		name_color = ccc3(0x00,0xe4,0xff)
		stroke_color = ccc3(0x00,0x00,0x00)
	end
	return name_color, stroke_color
end


-- 根据npc的hid得到对应的头像icon
function getNpcIconByhid( hid )
	-- 根据hid查找DB_Monsters表得到对应的htid
	require "db/DB_Monsters"
	local htid = DB_Monsters.getDataById(hid).htid
	-- 根据htid查找DB_Monsters_tmpl表得到icon
	require "db/DB_Monsters_tmpl"
	local heroData = DB_Monsters_tmpl.getDataById(htid)
	local icon ="images/base/hero/head_icon/" .. heroData.head_icon_id
	local quality_bg ="images/hero/quality/"..heroData.star_lv .. ".png"

	local icon_sprite  = CCSprite:create(icon)
	local quality_sprite = CCSprite:create(quality_bg)
	icon_sprite:setAnchorPoint(ccp(0.5, 0.5))
	icon_sprite:setPosition(ccp(quality_sprite:getContentSize().width/2, quality_sprite:getContentSize().height/2))
	quality_sprite:addChild(icon_sprite)
	return quality_sprite
end

-- 得到npc的名字
function getNpcName( uid, utid )
	require "db/DB_Npc_name"
	-- 表中第几个key
	local surname_index = nil
	local girl_name_index = nil
	local boy_name_index = nil
	for k,v in pairs(DB_Npc_name.keys) do
		if(v == "surname")then
			surname_index = k
		end
		if(v == "girl_name")then
			girl_name_index = k
		end
		if(v == "boy_name")then
			boy_name_index = k
		end
	end
	print("index",surname_index,girl_name_index,boy_name_index)
	-- 姓 个数
	local surname_count = 0
	for k,v in pairs(DB_Npc_name.Npc_name) do
		-- print_t(v)
		if(v[tonumber(surname_index)] ~= nil)then
			surname_count = surname_count + 1
		end
	end
	-- 男名 个数
	local boy_name_count = 0
	for k,v in pairs(DB_Npc_name.Npc_name) do
		if(v[tonumber(boy_name_index)] ~= nil)then
			boy_name_count = boy_name_count + 1
		end
	end
	-- 女名 个数
	local girl_name_count = 0
	for k,v in pairs(DB_Npc_name.Npc_name) do
		if(v[tonumber(girl_name_index)] ~= nil)then
			girl_name_count = girl_name_count + 1
		end
	end
	-- 取得姓的id
	print(uid,"+",surname_count)
	local surname_id = math.mod(tonumber(uid),surname_count)+1
	-- local surname_id = math.mod(111,2)
	print("surname_id",surname_id)
	-- 姓
	local surnameStr = DB_Npc_name.getDataById( surname_id ).surname
	-- 名字id
	local name_id = nil
	local nameStr = nil
	-- 男名id
	if(tonumber(utid) == 2)then
		name_id = math.mod(tonumber(uid),boy_name_count)+1
		print("boyname_id",name_id)
		nameStr = DB_Npc_name.getDataById( name_id ).boy_name
	end
	-- 女名id
	if(tonumber(utid) == 1)then
		name_id = math.mod(tonumber(uid),girl_name_count)+1
		print("girlname_id",name_id)
		nameStr = DB_Npc_name.getDataById( name_id ).girl_name
	end
	return surnameStr .. nameStr
end

-------------------------------------------------------------------------------
								-- 兑换商城
-------------------------------------------------------------------------------

-- 得到表配置的所有商品数据
function getArenaShopDBInfo()

	require "db/DB_Arena_shop"
	
	local tData = {}
	for k, v in pairs(DB_Arena_shop.Arena_shop) do
		table.insert(tData, v)
	end
	local allGoods = {}
	for k,v in pairs(tData) do
		-- isSold为1的显示到出售列表
		if( tonumber(DB_Arena_shop.getDataById(v[1]).isSold) == 1 )then
			table.insert(allGoods, DB_Arena_shop.getDataById(v[1]))
		end
	end
	tData = nil

	local function keySort ( goods_1, goods_2 )
	   	return tonumber(goods_1.sortType) > tonumber(goods_2.sortType)
	end
	table.sort( allGoods, keySort )

	return allGoods
end

-- 得到商店显示数据  
-- limitType 2:永久次数限制 此类型兑换次数达上限就不显示
function getArenaAllShopInfo()
	local showGoods = {}
	local dbGoods = getArenaShopDBInfo()
	for k,v in pairs(dbGoods) do
		if( tonumber(v.limitType) == 2 )then
			local haveNum = getBuyNumBy(v.id)
			if(haveNum < tonumber(v.baseNum))then
				table.insert(showGoods,v)
			end
		else
			table.insert(showGoods,v)
		end
	end
	return showGoods
end


-- 得到兑换物品的 物品类型，物品id，物品数量
function getItemData( item_str )
	local tab = string.split(item_str,"|")
	return tonumber(tab[1]),tonumber(tab[2]),tonumber(tab[3])
end


-- 获取某个物品的当前购买次数
function getBuyNumBy( goods_id )
	local goods_id = tonumber(goods_id)
	local number = 0
	if(arenaInfo.goods == nil)then
		return number
	end
	if(not table.isEmpty(arenaInfo.goods)) then
		for k_id, v in pairs(arenaInfo.goods) do
			if(tonumber(k_id) == goods_id) then
				number = tonumber(v.num)
				break
			end
		end
	end
	return number
end


-- 修改摸个商品的购买次数
function addBuyNumberBy( goods_id, n_addNum )
	local addNum = tonumber(n_addNum)
	if(table.isEmpty(arenaInfo.goods)) then
		arenaInfo.goods = {}
	end
	if(arenaInfo.goods["" .. goods_id])then
		arenaInfo.goods["" .. goods_id].num = tonumber(arenaInfo.goods["" .. goods_id].num) + addNum
	else
		arenaInfo.goods["" .. goods_id] = {}
		arenaInfo.goods["" .. goods_id].num = addNum
	end
end

--获取下一个级别，当前兑换次数
function getLevelnumber(goods_data)
	local nextLv = -1
	local curNum = 1
	local goodsStr = string.split(goods_data.level_num,",")
	local length = #goodsStr
	--对表进行倒序
	for i=1,length do
		local goods_info = string.split(goodsStr[length - i + 1],"|")
		local first_data = string.split(goodsStr[1],"|")
		
		if( UserModel.getHeroLevel() >= tonumber(goods_info[1]) )then
			
		 	curNum = tonumber(goods_info[2])  --当前刷新次数
		 	if( 1 == i )then
		 		-- 当达到最大等级的时候
		 		nextLv = -1
		 	else
		 		-- 正常情况
		 		local data_goods = string.split(goodsStr[length - i +1 +1],"|")
		 		nextLv = tonumber(data_goods[1])  --要显示的下一级别
		 	end
			break
		end
	end
	return curNum,nextLv
end

