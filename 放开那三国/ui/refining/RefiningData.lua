-- Filename: RefiningData.lua
-- Author: zhang zihang
-- Date: 2015-2-27
-- Purpose: 炼化炉数据层

module ("RefiningData", package.seeall)

require "script/ui/refining/RefiningUtils"

kResolveMainTag = 1001 				--炼化tag
kResurrectMainTag = 1002 			--重生tag
kSoulMainTag = 1003					--化魂tag

kHeroTag = 1 						--英雄tag
kEquipTag = 2 						--装备tag
kTreasureTag = 3 					--宝物tag
kClothTag = 4 						--时装tag
kGodTag = 5 						--神兵tag
kTokenTag = 6                       --符印tag
kPocketTag = 7                      --锦囊tag
kHeroJHTag = 8                      --武将精华tag
kTallyTag = 9                       --兵符tag
kChariotTag = 10					--战车tag
--以后这里再加Tag必须顺次增加 因为涉及到炼化选择界面进来时scrollVew setoffest的问题

local _curMainTag = nil 			--当前主页面所在tag
local _curChooseNum = nil 			--已选择数目	
local _curChooseIdTable = nil 		--已选择的数组id
local _curResolveTag = kHeroTag		--炼化选择默认为英雄tag，不随重新进入而初始化
local _curResurrectTag = kHeroTag   --重生选择默认为英雄tag，不随重新进入而初始化
local _curSoulTag = kHeroTag 		--重生选择默认为英雄tag，不随重新进入而初始化

local _tempChooseNum = nil 			--临时已选择数目
local _tempChooseTag = nil 			--临时选择的tag
local _tempChooseIdTable = nil 		--临时选择的数组id

local _heroFitInfo = nil 			--符合条件的英雄
local _equipFitInfo	= nil 			--符合条件的武器
local _treasureFitInfo = nil 		--符合条件的宝物
local _clothFitInfo = nil 			--符合条件的时装
local _godFitInfo = nil 			--符合条件的神兵
local _tokenFitInfo = nil           --符合条件的符印
local _pocketFitInfo = nil          --符合条件的锦囊
local _heroJHFitInfo = nil          --符合条件的武将精华
local _tallyFitInfo = nil           --符合条件的兵符
local _chariotFitInfo = nil 		--符合条件的战车

local _fastBeginPos = nil 			--快速添加起始位置

local _selectArray = {} 			--选择的数组
-- 确定化魂的武将精华容器，键是武将精华的item_id，值是选择的数量
local _selectedHeroJHTabel = {}
--==================== 化魂 ====================

--被选择英雄hid的集合
local _heroHidAry = nil   
--消耗的银币
local _castSilver = 0
--4星级武将化魂需要的银币
local _fourCast = nil
--5星级武将化魂需要的银币      
local _fiveCast = nil
-- 化魂武将精华的价格
local _heroJHPrice = nil
--[[
	@des 	:对数据层数据进行初始化
			 从外部进入炼化功能的时候调用
--]]
function resetAllData()
	--设置为炼化页面
	setCurMainTag(kResolveMainTag)
	--重置选择的数据
	resetSelectData()
end

--[[
	@des 	:对选择的数据初始化
			 在主页面切换模式的时候调用
--]]
function resetSelectData()
	clearHeroFit()
	clearEquipFit()
	clearTreasureFit()
	clearClothFit()
	clearGodFit()
	clearTokenFit()
	clearPocketFit()
	clearTempHeroJHInfo()
	clearTallyFit()
	clearChariotFit()
	resetChooseData()
end

--[[
	@des 	:重置选择数据
--]]
function resetChooseData()
	setCurChooseNum(0)
	_curChooseIdTable = {}
	clearSelectArray()
end

--[[
	@des 	:重置临时数据
			 选择界面切换选择的时候调用
--]]
function resetTempData()
	setTempChooseNum(0)
	_tempChooseIdTable = {}
end

--==================== ClearFit ====================
--[[
	@des 	:重置选择的英雄
--]]
function clearHeroFit()
	_heroFitInfo = nil
end

--[[
	@des 	:重置选择的装备
--]]
function clearEquipFit()
	_equipFitInfo = nil
end

--[[
	@des 	:重置选择的宝物
--]]
function clearTreasureFit()
	_treasureFitInfo = nil
end

--[[
	@des 	:重置选择的时装
--]]
function clearClothFit()
	_clothFitInfo = nil
end

--[[
	@des 	:重置选择的神兵
--]]
function clearGodFit()
	_godFitInfo = nil
end
--[[
	@des 	:重置选择的符印
--]]
function clearTokenFit()
	_tokenFitInfo = nil
end
--[[
	@des 	:重置选择的锦囊
--]]
function clearPocketFit()
	_pocketFitInfo = nil
end
--[[
	@des 	:清除选择array
--]]
function clearSelectArray()
	_selectArray = {}
	if getCurMainTag() == kSoulMainTag then
		if _heroHidAry ~= nil then
			_heroHidAry:release()
			_heroHidAry = nil
		end
		_castSilver = 0
	end
end
--[[
	@des 	:重置选择的兵符
--]]
function clearTallyFit()
	_tallyFitInfo = nil
end

--[[
	@desc 	: 重置选择的战车
	@param 	:
	@return : 
--]]
function clearChariotFit()
	_chariotFitInfo = nil
end

--==================== setA2 ====================
--[[
	@des 	:设置英雄的a2
	@param  :下标
	@param  :a2
--]]
function setHeroA2(p_index,p_a2)
	_heroFitInfo[p_index].obj = p_a2
end

--[[
	@des 	:设置物品的a2
	@param  :下标
	@param  :a2
--]]
function setEquipA2(p_index,p_a2)
	_equipFitInfo[p_index].obj = p_a2
end

--[[
	@des 	:设置宝物的a2
	@param  :下标
	@param  :a2
--]]
function setTreasA2(p_index,p_a2)
	_treasureFitInfo[p_index].obj = p_a2
end

--[[
	@des 	:设置时装的a2
	@param  :下标
	@param  :a2
--]]
function setClothA2(p_index,p_a2)
	_clothFitInfo[p_index].obj = p_a2
end

--[[
	@des 	:设置神兵的a2
	@param  :下标
	@param  :a2
--]]
function setGodA2(p_index,p_a2)
	_godFitInfo[p_index].obj = p_a2
end
--[[
	@des 	:设置符印的a2
	@param  :下标
	@param  :a2
--]]
function setTokenA2(p_index,p_a2)
	_tokenFitInfo[p_index].obj = p_a2
end
--[[
	@des 	:设置锦囊的a2
	@param  :下标
	@param  :a2
--]]
function setPocketA2(p_index,p_a2)
	_pocketFitInfo[p_index].obj = p_a2
end
--[[
	@des 	:得到兵符的a2
	@param  :下标
	@return :a2
--]]
function setTallyA2(p_index,p_a2)
	_tallyFitInfo[p_index].obj = p_a2
end

--[[
	@desc 	: 设置战车的a2
	@param  : 下标
	@return : 
--]]
function setChariotA2( pIndex, pA2 )
	_chariotFitInfo[pIndex].obj = pA2
end

--==================== getA2 ====================
--[[
	@des 	:得到英雄的a2
	@param  :下标
	@return :a2
--]]
function getHeroA2(p_index)
	return _heroFitInfo[p_index].obj
end

--[[
	@des 	:得到装备的a2
	@param  :下标
	@return :a2
--]]
function getEquipA2(p_index)
	return _equipFitInfo[p_index].obj
end

--[[
	@des 	:得到宝物的a2
	@param  :下标
	@return :a2
--]]
function getTreasA2(p_index)
	return _treasureFitInfo[p_index].obj
end

--[[
	@des 	:得到时装的a2
	@param  :下标
	@return :a2
--]]
function getClothA2(p_index)
	return _clothFitInfo[p_index].obj
end

--[[
	@des 	:得到神兵的a2
	@param  :下标
	@return :a2
--]]
function getGodA2(p_index)
	return _godFitInfo[p_index].obj
end
--[[
	@des 	:得到符印的a2
	@param  :下标
	@return :a2
--]]
function getTokenA2(p_index)
	return _tokenFitInfo[p_index].obj
end
--[[
	@des 	:得到锦囊的a2
	@param  :下标
	@return :a2
--]]
function getPocketA2(p_index)
	return _pocketFitInfo[p_index].obj
end
--[[
	@des 	:得到兵符的a2
	@param  :下标
	@return :a2
--]]
function getTallyA2(p_index)
	return _tallyFitInfo[p_index].obj
end

--[[
	@desc 	: 获取战车的a2
	@param  : 下标
	@return : a2
--]]
function getChariotA2( pIndex )
	return _chariotFitInfo[pIndex].obj
end

--==================== getFit ====================
--[[
	@des 	:得到符合条件的英雄
	@return :符合条件的英雄
--]]
function getHeroFit()
	if getCurMainTag() == kResolveMainTag then
		_heroFitInfo = _heroFitInfo or RefiningUtils.getFitResolveHeroes()
	elseif getCurMainTag() == kSoulMainTag then
		_heroFitInfo = RefiningUtils.getFitSoulHeroes()
	elseif getCurMainTag() == kResurrectMainTag then
		_heroFitInfo = _heroFitInfo or RefiningUtils.getFitResurrectHeroes()
	end
	return _heroFitInfo
end

--[[
	@des 	:得到符合条件的装备
	@return :符合条件的装备
--]]
function getEquipFit()
	if getCurMainTag() == kResolveMainTag then
		_equipFitInfo = _equipFitInfo or RefiningUtils.getFitResolveEquip()
	else
		_equipFitInfo = _equipFitInfo or RefiningUtils.getFitResurrectEquip()
	end

	return _equipFitInfo	
end

--[[
	@des 	:得到符合条件的宝物
	@return :符合条件的宝物
--]]
function getTreasFit()
	if getCurMainTag() == kResolveMainTag then
		_treasureFitInfo = RefiningUtils.getFitResolveTreas()
	else
		_treasureFitInfo = _treasureFitInfo or RefiningUtils.getFitResurrectTreas()
	end

	return _treasureFitInfo
end

--[[
	@des 	:得到符合条件的时装
	@return :符合条件的时装
--]]
function getClothFit()
	if getCurMainTag() == kResolveMainTag then
		_clothFitInfo = _clothFitInfo or RefiningUtils.getFitResolveCloth()
	else
		_clothFitInfo = _clothFitInfo or RefiningUtils.getFitResurrectCloth()
	end

	return _clothFitInfo
end

--[[
	@des 	:得到符合条件的神兵
	@return :符合条件的神兵
--]]
function getGodFit()
	if getCurMainTag() == kResolveMainTag then
		_godFitInfo = _godFitInfo or RefiningUtils.getFitResolveGod()
	else
		_godFitInfo = _godFitInfo or RefiningUtils.getFitResurrectGod()
	end

	return _godFitInfo
end
--[[
	@des 	:得到符合条件的符印
	@return :符合条件的符印
--]]
function getTokenFit()
	if getCurMainTag() == kResolveMainTag then
		_tokenFitInfo = _tokenFitInfo or RefiningUtils.getFitResolveToken()
	else
		--符印暂时还没有重生
		--_godFitInfo = _godFitInfo or RefiningUtils.getFitResurrectGod()
	end

	return _tokenFitInfo
end
--[[
	@des 	:得到符合条件的兵符
	@return :符合条件的兵符
--]]
function getTallyFit( ... )
	if getCurMainTag() == kResolveMainTag then
		_tallyFitInfo = _tallyFitInfo or RefiningUtils.getFitResolveTally()
	elseif getCurMainTag() == kResurrectMainTag then
		_tallyFitInfo = _tallyFitInfo or RefiningUtils.getFitResurrectTally()
	end
	return _tallyFitInfo
end
--[[
	@des 	:得到符合条件的锦囊
	@return :符合条件的锦囊
--]]
function getPocketFit()
	if getCurMainTag() == kResolveMainTag then
		--锦囊暂时没有炼化
	else
		_pocketFitInfo = _pocketFitInfo or RefiningUtils.getFitResurrectPocket()
	end

	return _pocketFitInfo
end
function getHeroJHFit( ... )
	_heroJHFitInfo = _heroJHFitInfo or RefiningUtils.getFitSoulHeroJH()
	return _heroJHFitInfo
end

--[[
	@desc 	: 得到符合条件的战车
	@param 	:
	@return : 符合条件的战车
--]]
function getChariotFit()
	if getCurMainTag() == kResolveMainTag then
		_chariotFitInfo = _chariotFitInfo or RefiningUtils.getFitResolveChariot()
	elseif getCurMainTag() == kResurrectMainTag then
		_chariotFitInfo = _chariotFitInfo or RefiningUtils.getFitResurrectChariot()
	end
	return _chariotFitInfo
end

--==================== CurSet ====================
--[[
	@des 	:设置当前主页面所在标签
	@param  :当前主标签tag
--]]
function setCurMainTag(p_curTag)
	_curMainTag = p_curTag
end

--[[
	@des 	:设置当前选择页面标签
	@param  :当前选择tag
--]]
function setCurSelectTag(p_curTag)
	--如果是炼化
	if getCurMainTag() == kResolveMainTag then
		_curResolveTag = p_curTag
	--如果是重生
	elseif getCurMainTag() == kResurrectMainTag then
		_curResurrectTag = p_curTag
	elseif getCurMainTag() == kSoulMainTag then
	--化魂
		_curSoulTag = p_curTag
	end
end

--[[
	@des 	:设置当前选择数目
	@param  :当前选择数量
--]]
function setCurChooseNum(p_num)
	_curChooseNum = tonumber(p_num)
end

--[[
	@des 	:设置当前数据
--]]
function setCurData()
	setCurChooseNum(getTempChooseNum())
	setCurSelectTag(getTempChooseTag())
	_curChooseIdTable = _tempChooseIdTable
end

--[[
	@des 	:设置快速添加起始位置
--]]
function setFastBeginNum(p_pos)
	_fastBeginPos = p_pos
end

--[[
	@des 	:添加快速添加起始位置
--]]
function addFastBeginNum(p_num)
	_fastBeginPos = _fastBeginPos + tonumber(p_num)
end

--[[
	@des 	:当前选择数量加1
	@param  :增加的数量
--]]
function addCurChooseNum(p_num)
	_curChooseNum = _curChooseNum + tonumber(p_num)
end

--==================== TempSet ====================
--[[
	@des 	:设置临时数据
--]]
function setTempData()
	setTempChooseNum(getCurChooseNum())
	setTempChooseTag(getCurSelectTag())
	_tempChooseIdTable = _curChooseIdTable
end

--[[
	@des 	:设置当前临时选择标签
	@param  :临时选择tag
--]]
function setTempChooseTag(p_tempTag)
	_tempChooseTag = p_tempTag
end

--[[
	@des 	:设置当前临时选择数量
	@param  :临时选择数量
--]]
function setTempChooseNum(p_tempNum)
	_tempChooseNum = p_tempNum
end

--[[
	@des 	:当前选择数量加1
	@param  :增加的数量
--]]
function addTempChooseNum(p_num)
	_tempChooseNum = _tempChooseNum + tonumber(p_num)
	if _tempChooseNum < 0 then
		_tempChooseNum = 0
	end
end

--[[
	@des 	:将选中的数组下标置为true
	@param  :选中的数组下标
--]]
function addTempChooseId(p_id)
	_tempChooseIdTable[tonumber(p_id)] = true
end
--[[
	@des 	:将选中的id及其数量记录下来，目前仅用于武将精华化魂
	@param  :p_id，选中的数组下标,p_Num:对应的数量
--]]
function addTempChooseIdAndNum(p_id,p_Num)
	_tempChooseIdTable[tonumber(p_id)] = tonumber(p_Num)
end
--[[
	@des 	:将选中的id及其数量记录下来，目前仅用于武将精华化魂
	@param  :p_id，选中的数组下标,p_Num:对应的数量
--]]
function getTempChooseNumById( p_id )
	if _tempChooseIdTable[tonumber(p_id)] ~= nil then
		return _tempChooseIdTable[tonumber(p_id)]
	else
		return 0
	end
end

--[[
	@des 	:将取消的数组对应下标删除
	@param  :取消的数组下标
--]]
function delTempChooseId(p_id)
	_tempChooseIdTable[tonumber(p_id)] = nil
end

--[[
	@des 	:设置已经选择的物品的数组
	@param  :物品id
--]]
function addSelectArray(p_info)
	if(p_info == nil) then return end
	print("addSelectArray",p_info)
	table.insert(_selectArray,p_info)
	if getCurMainTag() == kSoulMainTag then
		if _curSoulTag == kHeroTag then
			if _heroHidAry == nil then
				_heroHidAry = CCArray:create()
				_heroHidAry:retain()
			end
			_heroHidAry:addObject(CCInteger:create(tonumber(p_info.hid)))
		end
		countSoulSilver(p_info)
	end

end

--==================== CurGet ====================
--[[
	@des 	:得到当前主页面标签
	@return :当前主页面标签
--]]
function getCurMainTag()
	return _curMainTag
end

--[[
	@des 	:得到当前选择标签
	@return :当前选择标签
--]]
function getCurSelectTag()
	--如果是炼化
	if getCurMainTag() == kResolveMainTag then
		return _curResolveTag
	--如果是重生
	elseif getCurMainTag() == kResurrectMainTag then
		return _curResurrectTag
	elseif getCurMainTag() == kSoulMainTag then
	--如果是化魂
		return _curSoulTag
	end
end

--[[
	@des 	:得到已经选择的数量
	@return :已经选择的数量
--]]
function getCurChooseNum()
	return _curChooseNum
end

--[[
	@des 	:得到最大选择数量
	@return :最大选择数量
--]]
function getMaxChooseNum()
	--重生最多选择1个
	if getCurMainTag() == kResurrectMainTag then
		return 1
	--炼化,化魂最多选择5个
	elseif getCurMainTag() == kResolveMainTag or getCurMainTag() == kSoulMainTag then
		return 5
	end
end

--[[
	@des 	:得到当前选中的table
	@return :当前选中的table
--]]
function getCurChooseIdTable()
	return _curChooseIdTable
end

--[[
	@des 	:将选中的数组下标置为true
	@param  :选中的数组下标
--]]
function addCurChooseId(p_id)
	_curChooseIdTable[tonumber(p_id)] = true
end
--[[
	@des 	:将选中的id及其数量记录下来，目前仅用于武将精华化魂
	@param  :p_id，选中的数组下标,p_value:对应的数量
--]]
function addCurChooseIdAndNum(p_id,p_num)
	_curChooseIdTable[tonumber(p_id)] = p_num
end

--[[
	@des 	:得到选择的array
	@return :选择的array
--]]
function getSelectArray()
	return _selectArray
end

--[[
	@des 	:得到快速添加起始位置
	@return :起始位置
--]]
function getFastBeginPos()
	return _fastBeginPos
end

--==================== TempGet ====================
--[[
	@des 	:得到临时选择标签
	@return :当前临时标签
--]]
function getTempChooseTag()
	return _tempChooseTag
end

--[[
	@des 	:得到临时选择的数量
	@return :临时选择的数量
--]]
function getTempChooseNum()
	return _tempChooseNum
end

--[[
	@des 	:相应的临时对象是否开启
	@param  :数组下标
	@return :是否已选择
--]]
function isTempChoose(p_id)
	local isChoose = false
	if _tempChooseIdTable[tonumber(p_id)] ~= nil then
		isChoose = true
	end

	return isChoose
end

--[[
	@des 	:得到已选择数组的table
	@return :已选择数组table
--]]
function getChooseTable()
	return _tempChooseIdTable
end

--==================== Offset ====================
--[[
	@des 	:得到最大的offset
	@return :最大offset
--]]
function getBiggestOffset()
	local biggestValue = 0
	if table.isEmpty(_tempChooseIdTable) then
		return nil
	else
		for k,v in pairs(_tempChooseIdTable) do
			if k > biggestValue then
				biggestValue = k
			end
		end
	end

	return biggestValue
end
--==================== 化魂 ====================
--[[
	@des 	:一键设置适合的化魂对象
	@return :
--]]
function setSoulFit( ... )
	local fitTable = nil
	local fun = nil
	if _curSoulTag == kHeroTag then
		fitTable = getHeroFit()
		fun = addCurChooseId
	elseif _curSoulTag == kHeroJHTag then
		fitTable = getHeroJHFit()
		fun = addCurChooseIdAndNum
	end
	if (table.isEmpty(fitTable)) then
		return
	end
	_fastBeginPos = 0
	_curChooseNum = 0
	local selectBeginPos = #fitTable - _fastBeginPos
	for i = selectBeginPos,selectBeginPos - 5 + 1,-1 do
		addCurChooseNum(1)
		addFastBeginNum(1)
		fitTable[i].selectNum = fitTable[i].item_num
		fun(i,fitTable[i].item_num)
		addSelectArray(fitTable[i])
		if i <= 1 then
			setFastBeginNum(0)
			break
		end
	end
end
--[[
	@des 	:获取被选择武将hid的数组
	@return :
--]]
function getSelectHidAry( ... )
	-- body
	return _heroHidAry
end
--[[
	@des 	:获取化魂需要的银币
	@return :
--]]
function getSoulSilver( ... )
	-- body
	return _castSilver
end
--[[
	@des 	:计算化魂需要的银币
	@return :
--]]
function countSoulSilver(info)
	-- body
	if _curSoulTag == kHeroTag then
		if(_fourCast == nil) then
			setCast()
		end
		if(tonumber(info.star_lv) == 4) then
			_castSilver = _castSilver + _fourCast
		else
			_castSilver = _castSilver + _fiveCast
		end
	elseif _curSoulTag == kHeroJHTag then
		if _heroJHPrice == nil then
			setHeroJHPrice()
		end
		local num = info.selectNum
		_castSilver = _castSilver + num * _heroJHPrice
	end
end
--[[
	@des 	:获取化魂价格
	@return :
--]]
function setCast( ... )
	-- body
	require "db/DB_Normal_config"
	local tConfig = DB_Normal_config.getDataById(1)
	local ary = string.split(tConfig.hero_recount,",")
	for i,v in ipairs(ary) do
		local t = string.split(v,"|")
		if(tonumber(t[1]) == 4) then
			_fourCast = t[2]
		else
			_fiveCast = t[2]
		end
	end
end
--[[
	@des 	:获取化魂武将精华的价格
	@return :
--]]
function setHeroJHPrice( ... )
	require "db/DB_Normal_config"
	local tConfig = DB_Normal_config.getDataById(1)
	_heroJHPrice = tConfig.jinghua_needsilver
end
--[[
	@des 	:获取解析后端的数据
	@return :
--]]
function getParseData(data)
	-- body
	local tReward = {}
	if _curSoulTag == kHeroTag then
		require "db/DB_Item_hero_fragment"
		for k,v in pairs(data) do
			local tConfig = DB_Item_hero_fragment.getDataById(k)
			local reward = {}
			reward.htid = k
			reward.num = v
			reward.name = tConfig.name
			reward.quality = tConfig.quality
			table.insert(tReward,reward)
		end
	elseif _curSoulTag == kHeroJHTag then
		for k,v in pairs(data) do
			table.insert(tReward,{type = k,id = 0,num = tonumber(v)})
			UserModel.addHeroJh(tonumber(v))
		end
	end
	return tReward
end
--[[
	@des 	:获取当前化魂选择的数据tag
	@return :
--]]
function getCurSoulTag( ... )
	return _curSoulTag
end
--[[
	@des 	:删除选择的武将
	@return :
--]]
function removeSelectedHeros( ... )
	-- body
	for i = 1,#_selectArray do
		HeroModel.deleteHeroByHid(_selectArray[i].hid)
	end
end
--[[
	@des 	:清理缓存的武将精华的数据
	@return :
--]]
function clearTempHeroJHInfo( ... )
	_heroJHFitInfo = nil
end

--==================== 兵符重生 ====================
function getTallyRebornCost( pItemId )
	local itemData = DB_Item_bingfu.getDataById(pItemId)
	local goldCost = tonumber(itemData.reborn_cost) or 100
	return goldCost
end

-------------------------- 战车重生 --------------------------
--[[
	@desc 	: 获取战车重生花费的金币
	@param 	: pItemTid 战车物品Tid
	@return : 战车重生花费金币数
--]]
function getChariotRebornCost( pItemTid )
	require "db/DB_Item_warcar"
	local itemData = DB_Item_warcar.getDataById(pItemTid)
	local goldCost = tonumber(itemData.reborn_cost) or 100
	return goldCost
end







