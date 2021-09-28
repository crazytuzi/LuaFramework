-- Filename: DestinyData.lua
-- Author: zhz
-- Date: 2013-12-18
-- Purpose: 天命系统的数据层

module ("DestinyData", package.seeall)

require "db/DB_Destiny"
require "script/ui/item/ItemUtil"
require "db/DB_Break"
require "db/DB_Heroes"
require "script/model/user/UserModel"
require "script/model/hero/HeroModel"

local _destinyInfo= nil
local _cacheAttr = {} --缓存的属性信息 加速战斗力计算
function getDestinyInfo( )
	return _destinyInfo
end

function setDestinyInfo( destinyInfo)
	_destinyInfo= destinyInfo
end

-- 当前的天命Id，若无为0
function getCurDestiny(  )
	--得到当前天命
	return tonumber(_destinyInfo.cur_destiny) 
end

-- 设置目前天命id,
function setCurDestiny( destinyId)
	_destinyInfo.cur_destiny = destinyId
end

--当前的天命数据
function getCurDestinyData( )
	return DB_Destiny.getDataById(getCurDestiny())
end

-- 下一个天命，也就是将要升级的天命系统
function getUpDestiny (  )
	local destinyId=1
	--若当前的天命为0，也就是说还没升过天命，则返回第一个天命
	if(tonumber(_destinyInfo.cur_destiny) ==0) then
		return destinyId
	--若当前有天命，则返回下一个天命作为要升级的（也就是中间的那个球）
	else
		--当前天命是最左边的那个，所以要升级的是中间那个
		local destinyData= DB_Destiny.getDataById(tonumber(_destinyInfo.cur_destiny))
		return destinyData.aftDestiny
	end
end

--升级天命的数据
function getUpDestinyData( )
	if(getUpDestiny() == nil) then
		return
	end
	return DB_Destiny.getDataById(getUpDestiny())
end

-- 最右边的星座，下下一个星座
function getAftDestiny(  )
	--得到当前要升级的天命（中间的那个）
	local upDestinyId= getUpDestiny()
	if(upDestinyId== nil ) then
		return
	end
	--得到当前要升级的天命的下一个天命（最右面的球）
	local aftDestinyId= DB_Destiny.getDataById(tonumber(upDestinyId)).aftDestiny
	return aftDestinyId
end

-- 下下一个星座的数据
function getAftDestinyData()
	if(getAftDestiny() == nil) then
		return
	end
	return DB_Destiny.getDataById(getAftDestiny())
end


-- 当前的突破表id，若无为0
function getCurBreak( )
	-- return tonumber(_destinyInfo.cur_break) 
	local curBreak=0
	if(tonumber(_destinyInfo.cur_destiny)== 0) then
		return curBreak
	end

	-- if(getUpDestiny()== nil) then
	-- 	 curBreak=2
	-- 	 return curBreak
	-- end
	-- local destinyData = DB_Destiny.getDataById(getUpDestiny())
	-- if(destinyData.isBreak ) then
	-- 		curBreak= destinyData.isBreak
	-- end
	-- return curBreak
	local destinyId=1
	for i=1, tonumber(_destinyInfo.cur_destiny ) do
		local destinyData= DB_Destiny.getDataById(destinyId)
		if(destinyData.isBreak ) then
			curBreak= destinyData.isBreak
		end
		destinyId= destinyData.aftDestiny
	end
	return curBreak
end

--  当前剩余的副本星数
function getHasScore( )
	return tonumber(_destinyInfo.has_score) 
end

-- 修改剩余的副本星数
function addHasScore( score)
	_destinyInfo.has_score = tonumber(_destinyInfo.has_score)+ tonumber(score) 
end

-- 当前第一个突破的Id
function getFirstBreakId( )
	local destinyId=1
	for i=1, table.count(DB_Destiny.Destiny) do
		local destinyData = DB_Destiny.getDataById(destinyId)
		if(destinyData.isBreak == 1) then
			return destinyId
		end
		destinyId= destinyData.aftDestiny
	end
end

--[[
	@des 	:通过index判断是否是break星座
	@param 	:星座id
	@return :true or false
--]]
function isBreakById(p_index)
	local destinyData = DB_Destiny.getDataById(tonumber(p_index))
	if destinyData.isBreak ~= nil then
		return true
	else
		return false
	end
end

-- 得到第index个可以突破的id
function getIndexBreakId( index)
	local destinyId=1
	for i=1, table.count(DB_Destiny.Destiny) do
		local destinyData = DB_Destiny.getDataById(destinyId)
		if(tonumber(destinyData.isBreak)  == index) then
			return destinyId
		end
		destinyId= destinyData.aftDestiny
	end
end

-- 判断本次天命表里的是否为空
function isBreak( )
	local isBreak= false
	if(getUpDestiny()== nil) then
		return false
	end
	local destinyData = DB_Destiny.getDataById(getUpDestiny())
	local breakData=nil
	if( destinyData.isBreak ) then
		isBreak= true
	end
	print("isBreak  is :", isBreak )
	return isBreak
end

-- 判断本次是否可以突破，若可以突破，得到本次突破所需的
function getTransferNum( )
	local transferNum = 0
	local destinyData = DB_Destiny.getDataById(getUpDestiny())
	if(isBreak()) then
		transferNum= DB_Break.getDataById(destinyData.isBreak).need_transfer_num
	end
	return tonumber(transferNum) 
end

-- 判断本次是否达到突破条件：突破表不为空 且 主角的突破等级达到上限
function isNessaryBreak( )
	local heroData = HeroModel.getNecessaryHero()
	if(isBreak() == true and tonumber(heroData.evolve_level ) >= getTransferNum() ) then
		return true
	else
		return false
	end
end

-- 当 isBreak()为true时，修改主角的htid
function changeHeroHtid( )
	if( isBreak()== false) then
		return
	end
	require "db/DB_Heroes"
	local htid = UserModel.getAvatarHtid()
	local destinyData = DB_Destiny.getDataById(getUpDestiny())
	local aft_roleId = DB_Break.getDataById(destinyData.isBreak).aft_roleId
	aft_roleId= lua_string_split(aft_roleId, ",")
	for i=1, #aft_roleId do
		local module_id = lua_string_split(aft_roleId[i], "|")
		
		local model_id = DB_Heroes.getDataById(UserModel.getAvatarHtid()).model_id
		if(tonumber(module_id[1]) == model_id ) then
			UserModel.setAvatarHtid(module_id[2])
			htid = module_id[2]
			break 
		end
	end
	-- print("htid  is : ", htid )
	return tonumber(htid ) 
	-- if(HeroModel.getSex(UserModel.getAvatarHtid())== 1 )
	-- UserModel.setAvatarHtid()
end

-- 当前天命升级需要的star
function getStarNumForUp( )
	local destinyId= 1
	local starNum=0
	if(tonumber(_destinyInfo.cur_destiny)== 0) then
		destinyId= 1
	else
		destinyId = DB_Destiny.getDataById(tonumber(_destinyInfo.cur_destiny)).aftDestiny
	end
	if(destinyId ) then
		starNum = DB_Destiny.getDataById(tonumber(destinyId)).costCopystar
	else
		starNum =0
	end	
	return starNum
end

-- 是否可以突破天命
function canUpDestiny( )
	
	-- local canBreak= true

	-- -- 防止新手引导的问题
	-- --_destinyInfo为后端拉取的天命信息
	-- if( table.isEmpty(_destinyInfo) or _destinyInfo == nil ) then
	-- 	return false
	-- end

	-- --如果要升级的天命为空
	-- if( DestinyData.getUpDestiny() == nil) then
	-- 	canBreak= false
	-- end
	-- --如果天命星数小于当前天命升级需要的星数
	-- if(DestinyData.getHasScore() <DestinyData.getStarNumForUp()) then
	-- 	canBreak= false
	-- end	
	-- --升级所需银币不够
	-- if(UserModel.getSilverNumber() < DestinyData.getSilverNumForUp() ) then
	-- 	canBreak = 	false
	-- end
	-- --虽然到了天命可以突破的点，可是主角不满足突破所需的条件
	-- if( DestinyData.isBreak( ) and  not DestinyData.isNessaryBreak( ) ) then
	-- 	canBreak= false
	-- end
	-- return canBreak

	print("红点判断")
	-- print("当前拥有星数",DestinyData.getHasScore())
	-- print("升级所需星数",DestinyData.getStarNumForUp())

	local canBreak = false

	if (_destinyInfo ~= nil) and (not table.isEmpty(_destinyInfo)) then
		--里面再来个if是因为怕外面写不下
		if((DestinyData.getHasScore() >= DestinyData.getStarNumForUp()) and (DestinyData.getUpDestiny() ~= nil) ) then
			canBreak= true
		end
	end	

	return canBreak
end


-- 当前天命升级需要的银币
function getSilverNumForUp( )
	local destinyId= 1
	local silverNum=0
	if(tonumber(_destinyInfo.cur_destiny)== 0) then
		destinyId= 1
	else
		destinyId = DB_Destiny.getDataById(tonumber(_destinyInfo.cur_destiny)).aftDestiny
	end
	if(destinyId ) then
		silverNum = DB_Destiny.getDataById(tonumber(destinyId)).silverCost
	else
		silverNum =0
	end	
	return silverNum
end


-- 计算点击X个星座后，主角变成紫卡
function destinyNumForQuality(  )
	local destinyId= 1
	for i=1, table.count(DB_Destiny.Destiny) do 
		local destinyData= DB_Destiny.getDataById(destinyId)
		if(destinyData.isBreak ==1 ) then
			return destinyId
		end
		destinyId= destinyData.aftDestiny
	end
end

-- 计算天命up时，主角属性的加成
function getUpProperty(  )
	-- local curDestiny = tonumber(_destinyInfo.cur_destiny)
	-- if(curDestiny)
	-- local destinyData = DB_Destiny.getDataById(curDestiny)
	local destinyId= 1
	local curDestiny= tonumber(_destinyInfo.cur_destiny)
	if(curDestiny==0) then
		destinyId=1
	else
		local destinyData= DB_Destiny.getDataById(curDestiny)
		destinyId = destinyData.aftDestiny
	end

	local upDestinyData = DB_Destiny.getDataById(destinyId)

	local attArr = string.split(upDestinyData.attArr, ",")

	return attArr
	-- for  i=1, #attArr do
	-- 	local propertyTable= lua_string_split(attArr[i],"|")

	-- end

	-- local attArr= lua_string_split(upDestinyData.attArr, "|")

	-- local affixDesc, displayNum, realNum= ItemUtil.getAtrrNameAndNum(attArr[1], attArr[2])
	-- return affixDesc, displayNum

end


-- 通过当前天命id和所给的affixID ,计算增加的属性
function  calHeroProperty( affixID)
	local curDestiny= tonumber(_destinyInfo.cur_destiny)
	if(curDestiny== 0) then
		return 0
	end

	local propertyNum=0
	local showPropertyNum=0
	local destinyId=1
	for i=1, table.count(DB_Destiny.Destiny) do
		if( destinyId <= curDestiny) then
			local destinyData= DB_Destiny.getDataById(destinyId)
			destinyId = tonumber(destinyData.aftDestiny)
			local attArr = string.split(destinyData.attArr, ",")
			-- print_t(attArr)
			for i=1, #attArr do 
				local propertyTable= lua_string_split(attArr[i],"|")

				if(tonumber(propertyTable[1])== affixID) then
					propertyNum= propertyNum+ tonumber(propertyTable[2])
					local desc, displayNum, realNum= ItemUtil.getAtrrNameAndNum(affixID, propertyTable[2])
					showPropertyNum= displayNum+showPropertyNum
				end
			end
		end
	end
	return showPropertyNum, propertyNum
end

-- 加成的属性
function getAddHeroProperty(  )
	local curDestiny= tonumber(_destinyInfo.cur_destiny)
	local destinyData = DB_Destiny.getDataById(curDestiny)
	local attArr = string.split(destinyData.attArr, ",")
	local descTables = {}
	for i=1, #attArr do
		local propertyTable = lua_string_split(attArr[i], "|")
		local descTable = { txt= "", num = 0 }-- {txt=GetLocalizeStringBy("key_2938"), num=2, displayNumType=1
		local desc, displayNum, realNum = ItemUtil.getAtrrNameAndNum(tonumber(propertyTable[1]), propertyTable[2])
		descTable.txt= desc.displayName
		descTable.num= displayNum
		table.insert(descTables, descTable)
	end

	return descTables
end

-- 所有的加成属性 { }
	-- 生命加成
	-- tRetValue.lifeAppend 
	-- -- 统帅
	-- tRetValue.commandAppend
	-- -- 武力
	-- tRetValue.strengthAppend
	-- -- 智力
	-- tRetValue.intelligenceAppend
	-- -- 通用攻击
	-- tRetValue.generalAttackAppend
	-- -- 法防
	-- tRetValue.magicDefendAppend
	-- -- 物防
	-- tRetValue.physicalDefendAppen
function getDestinyAppend( hid )

	local tRetValue = {
						lifeAppend= 0,
						commandAppend=0, 
						strengthAppend=0, 
						intelligenceAppend =0, 
						generalAttackAppend=0,
						magicDefendAppend=0,
						physicalDefendAppend=0  
					}

	local heroData= HeroModel.getNecessaryHero()
	-- print(" ++++++++++++++++++++++++++++++++++   ==============  ")
	-- print_t(heroData)
	if(tonumber( heroData.hid) ~=  hid or table.isEmpty(_destinyInfo)) then
		return tRetValue
	end
	local curDestiny= tonumber(_destinyInfo.cur_destiny)
	local destinyId=1
	for i=1, table.count(DB_Destiny.Destiny) do
		if( destinyId <= curDestiny) then
			local destinyData= DB_Destiny.getDataById(destinyId)
			destinyId = tonumber(destinyData.aftDestiny)
			local attArr = string.split(destinyData.attArr, ",")
			-- print_t(attArr)
			for i=1, #attArr do 
				local propertyTable= lua_string_split(attArr[i],"|")
				-- propertyNum= propertyNum+ tonumber(propertyTable[2])
				-- local desc, displayNum, realNum= ItemUtil.getAtrrNameAndNum(tonumber(propertyTable[1]), propertyTable[2])
				-- showPropertyNum= displayNum+showPropertyNum
				local affixID= tonumber(propertyTable[1])
				local affixNum = tonumber(propertyTable[2]) 
				if(affixID== 1) then
					tRetValue.lifeAppend = tRetValue.lifeAppend + affixNum
				elseif(affixID== 4) then
					tRetValue.physicalDefendAppend=tRetValue.physicalDefendAppend+ affixNum
				elseif(affixID== 5) then
					tRetValue.magicDefendAppend=tRetValue.magicDefendAppend+ affixNum
				elseif(affixID== 6) then
					tRetValue.commandAppend= tRetValue.commandAppend + affixNum
				elseif(affixID== 7) then
					tRetValue.strengthAppend= tRetValue.strengthAppend + affixNum
				elseif(affixID== 8) then
					tRetValue.intelligenceAppend= tRetValue.intelligenceAppend + affixNum
				elseif(affixID== 9) then
					tRetValue.generalAttackAppend= tRetValue.generalAttackAppend + affixNum
				end
			end
		end
	end
	return tRetValue
end


--[[
	@des:得到天命系统属性
	@parm:p_hid 武将id
	@ret:{
		affixId => affixValue,
		...
	}
--]]
function getDestinyAffix( p_hid,p_isForce)
	local p_hid = tonumber(p_hid)
	if(p_isForce ~= true and _cacheAttr[p_hid]~= nil)then
		return _cacheAttr[p_hid]
	end
	local affix = {}
	local heroData= HeroModel.getNecessaryHero()

	if(tonumber( heroData.hid) ~=  p_hid or table.isEmpty(_destinyInfo)) then
		return affix
	end
	local curDestiny= tonumber(_destinyInfo.cur_destiny)
	local destinyId=1
	for i=1, table.count(DB_Destiny.Destiny) do
		if( destinyId <= curDestiny) then
			local destinyData= DB_Destiny.getDataById(destinyId)
			destinyId = tonumber(destinyData.aftDestiny)
			local attArr = string.split(destinyData.attArr, ",")
			-- print_t(attArr)
			for i=1, #attArr do 
				local propertyTable= lua_string_split(attArr[i],"|")
				local affixID= tonumber(propertyTable[1])
				local affixNum = tonumber(propertyTable[2])
				if affix[affixID] == nil then
					affix[affixID] = affixNum
				else
					affix[affixID] = affix[affixID] + affixNum
				end
			end
		end
	end
	local heroAffix = {}
	heroAffix[tonumber(heroData.hid)] = affix
	_cacheAttr[p_hid] = heroAffix[p_hid]
	return heroAffix[p_hid]
end


--[[
	@des 	:因为副本的星数在打副本后发生变化，用于刷新当前剩余可用于天命的星数,函数用于天命的红圈提示
	@param 	:副本星数
	@return :
--]]
function refreshStarNum(p_copyScore)
	--每次副本星数发生变化副本通知天命，天命星数加一
	-- _destinyInfo.has_score = tonumber(_destinyInfo.has_score) + 1
	if not table.isEmpty(_destinyInfo) then
		_destinyInfo.has_score = tonumber(p_copyScore) - tonumber(_destinyInfo.all_score) + tonumber(_destinyInfo.has_score)
		_destinyInfo.all_score = tonumber(p_copyScore)
	end
end







