-- Filename: ReplaceSkillData.lua
-- Author: zhangqiang
-- Date: 2014-08-07
-- Purpose: 主角更换技能中宗师录相关数据

module("ReplaceSkillData", package.seeall)

require "script/model/DataCache"
require "db/DB_Star"
require "db/DB_Vip"
require "script/model/user/UserModel"
require "db/DB_Teach"
require "db/DB_Level_up_exp"


------------------------------------------------------------[[ 常量和变量 ]]----------------------------------------------------
-------------------------------------------------------[[ 主角学习技能界面 ]]-------------------------------------------------
local _allInfo = nil
local _curMasterInfo = nil

--[[
	_curMasterSkillInfo = {
		{
			starId = int
			starTid = int
			starName = string
			needFeelLevel = int
			skillId = int
			skillLevel = int
			skillName = string
			skillDesc = string
			skillIcon = string
			maxSkillLevel = int
			maxSkillId = int
		}
	}
--]]
local _curMasterSkillInfo = nil

--[[
	_attrPanelDataSrc = {
		{
			needFeelLevel = int      开放该能力需要的修行等级
			needUserLevel = int      开放该能力需要的用户等级
	        ability = {
		        id = int         属性id
				name = string    属性名称
				addNum = int     属性的增加值
	        }
		}
	}
--]]
_attrPanelDataSrc = nil

-------------------------------------------------------[[ 宗师录 ]]-------------------------------------------------
--存储宗实录的数据，一次添加，需要哪个返回哪个而不需要每次都去遍历查找
--用空间换时间
local masterTable = {
						[1] = {}, 	--全部宗师
						[2] = {},	--魏国
						[3] = {},	--蜀国
						[4] = {},	--吴国
						[5] = {},	--群雄
					}
-------------------------------------------------------[[ 选择学习技能 ]]-------------------------------------------------
local _skillList = nil
local _selectSkillIndex = nil

----------------------------------------------------------[[ 技能预览 ]]-------------------------------------------------
local _allSkillList = nil


------------------------------------------------------------[[ 方法 ]]----------------------------------------------------
-------------------------------------------------------[[ 主角更换技能主界面 ]]-------------------------------------------------
--[[
	desc :	初始化数据
--]]
function init( ... )
	_skillList = nil
	_selectSkillIndex = nil
end

--[[
	/**
	 * 获取用户拥有的所有名将信息
	 * 没有名将是不能开启名将系统的，调用这个接口会报错
	 *
	 * @return array 
	 * <code> 
	 * {
	 * 		'ret':string
	 *     		'ok'										成功
	 * 		'allStarInfo':array								所有名将信息
	 * 		{
	 * 			'send_num':int  							当天使用的金币赠送次数,
	 * 			'send_time':int								上次刷新时间,
	 * 			'draw_num':int								当天使用的翻牌次数,
	 * 			'challenge_num':int							当天使用的挑战次数,  --该字段已去掉
	 * 			'va_act_info':array							行为信息
	 * 			{ 
	 * 				'act':array
	 * 				{
	 * 					$actId=>$actNum
	 * 				}
	 * 				'draw':array
	 * 				{
	 * 					$sid:array
	 * 					{
	 * 						0:int							花型，1-9
	 * 						1-5:int							htid
	 * 					}
	 * 				}
	 * 				'skill'=>$sid							装备的技能是属于哪个武将的
	 * 			}
	 * 			'star_list':array							名将列表										
	 * 			{
	 * 				star_id:array							名将id
	 *				{
	 *					'star_id':int						名将id
	 *					'star_tid':int						名将模板id
	 *					'level':int							好感度等级
	 *          		'total_exp':int						好感度总值
	 *          		'feel_skill':int					感悟技能id
	 *          		'feel_level':int					感悟度等级
	 *          		'feel_total_exp':int				感悟度总值
	 *          		'pass_hcopy_num':int				武将列传副本通关次数
	 *      		}   
	 *      	}
	 * 		}
	 * }
	 * </code>
	 */
	public function getAllStarInfo();
	如果没有'skill'这个字段就说明主角是装备的自己本身的技能
	@desc :	设置主角学习技能中需要的所有信息
--]]
function setAllInfo(p_allInfo)
	-- print("设置allInfo之前")
	-- print_t(_allInfo)
	_allInfo = p_allInfo
	-- print("设置allInfo之后")
	-- print_t(_allInfo)
	-- print("读取的_allInfo信息")
	-- print_t(_allInfo)
end

--[[
	@desc :	获取主角学习技能中需要的所有信息
	@param:
	@ret  :	返回所有信息
--]]
function getAllInfo( ... )
	return _allInfo
end

--[[
	@desc :	每天晚上零点重新拉取名将信息时调用该函数
	@param:
	@ret  :	
--]]
function updateAllInfo( p_allInfo )
	setAllInfo(p_allInfo)

	if MainScene.getOnRunningLayerSign() == "SelectSkillLayer" then
		require "script/ui/replaceSkill/learnSkill/SelectSkillLayer"
		SelectSkillLayer.refreshBottomLabel()
	end

	if MainScene.getOnRunningLayerSign() == "LearnSkillLayer" then
		--在学习技能界面时，每天晚上0点系统自动重新拉取名将信息并刷新界面
		require "script/ui/replaceSkill/learnSkill/LearnSkillLayer"
		LearnSkillLayer.refreshGoldLabel()
		LearnSkillLayer.refreshRemainLabel()
	end
end


--[[
	@desc :	将当前的宗师信息设置为参数id对应的宗师信息
	@param:
	@ret  :	
--]]
function setCurMasterInfo(p_masterId)
	if _curMasterInfo ~= nil and tonumber(_curMasterInfo.star_id) == tonumber(p_masterId) then
		return
	end
	print("setCurMasterInfo",p_masterId)
	_curMasterInfo = _allInfo.star_list[tostring(p_masterId)]
	
	-- 查找名将的信息
	_curMasterInfo.starTemplate = DB_Star.getDataById(tonumber(_curMasterInfo.star_tid))

	-- 更新当前宗师的技能信息
	_curMasterSkillInfo = getSkillInfoBySid(tonumber(p_masterId))

	-- 更新修行等级能力
	updateAttrPanelDataSrc()
end

--[[
	@desc :	获取当前宗师的信息
	@param:
	@ret  :	
--]]
function getCurMasterInfo( ... )
	--[[
		断线后重连，登录时拉取的信息重新分配内存地址，因此要更新_curMasterInfo的指向，
		否则通过_curMasterInfo的信息读写还是在原内存中进行而使得操作无效
		如：刷新经验条时的数据获取
	--]]
	-- if g_network_status == g_network_connected then
	-- 	local masterId = _curMasterInfo.star_id
	-- 	_curMasterInfo = nil
	-- 	setCurMasterInfo(masterId)
	-- 	print("g_network_status")
	-- end
	if _curMasterInfo ~= _allInfo.star_list[tostring(_curMasterInfo.star_id)] then
		local masterId = _curMasterInfo.star_id
		_curMasterInfo = nil
		setCurMasterInfo(masterId)
	end

	return _curMasterInfo
end

--[[
	@desc :	获取当前宗师的所有技能信息
	@param:
	@ret  :	
--]]
function getCurMasterSkillInfo( ... )
	return _curMasterSkillInfo
end

--[[
	@desc : 获取关系等级等级提升到下一级还需要的修行值
	@param:
	@ret  :	技能提升到下一等级所需的经验值(已达最大等级时返回nil)
--]]
function getRightFeelValue()
	if _curMasterInfo.starTemplate.isFeel ~= 1 then
		return 0
	end

	local curFeelLevel = tonumber(_curMasterInfo.feel_level)
	--当前等级已达最大等级
	if curFeelLevel == getMaxConfigFeelLevel() then
		return nil
	end
	local levelUpExpTemplate = DB_Level_up_exp.getDataById(_curMasterInfo.starTemplate.feelExp)
	local nextLevelNeedFeelValue = levelUpExpTemplate["lv_" .. (curFeelLevel + 1)]
	return nextLevelNeedFeelValue
end

--[[
	@desc : 获取当前总亲密值中超出当前等级部分的修行值
	@param:
	@ret  :	总亲密值中超出当前等级部分的修行值
--]]
function getLeftFeelValue( ... )
	if _curMasterInfo.starTemplate.isFeel ~= 1 then
		return 0
	end
	
	local levelUpExpTemplate = DB_Level_up_exp.getDataById(_curMasterInfo.starTemplate.feelExp)
	local totalFeelValue = tonumber(_curMasterInfo.feel_total_exp)
	local level = 1
	while totalFeelValue >= levelUpExpTemplate["lv_" .. level] do
		totalFeelValue = totalFeelValue - levelUpExpTemplate["lv_" .. level]
		level = level + 1
	end
	return totalFeelValue
end

--[[
	@desc :	根据宗师id获取对应的修行能力数组（各个增加的属性和对应的属性值, 包含未开放的）
	@param:	宗师id(即名将id)
	@ret :	能力数组
			allFeelLevelAbilityArr = {
				{
					needFeelLevel = int      开放该能力需要的修行等级
					needUserLevel = int      开放该能力需要的用户等级
			        ability = {
			        	id = int         属性id
						name = string    属性名称
						addNum = int     属性的增加值
			        }
				}
			}
--]]
require "db/DB_Starfeelarr"
require "db/DB_Affix"
function getFeelAbilityBySid(p_masterId)
	local masterInfo = _allInfo.star_list[tostring(p_masterId)]
	local masterTemplate = DB_Star.getDataById(tonumber(masterInfo.star_tid))

	if masterTemplate.feelId == nil then
		return {}
	end
	
	--获取包含所有修行等级对应的能力字符串的表
	local allFeelLevelAbilityTable = lua_string_split(masterTemplate.feelId, ",")
	local allFeelLevelAbilityArr = {}
	local arrIndex = 1
	for k,v in ipairs(allFeelLevelAbilityTable) do
		--单个修行等级对应能力字符串解析：对应能力id ｜ 开放该能力需要的修行等级 ｜ 开放该能力需要的用户等级
		local singleFeelLevelAbilityInfo = lua_string_split(v, "|")
		--根据能力id获取能力增加的属性字符串(可能为多个属性)
		local allAbilityStr = DB_Starfeelarr.getDataById(tonumber(singleFeelLevelAbilityInfo[1])).arr
		local allAbilityStrTable = lua_string_split(allAbilityStr, ",")
		
		for s,t in ipairs(allAbilityStrTable) do
			--解析单个能力字符串：增加的属性id ｜ 增加值
			local singleAbilityTable = lua_string_split(t, "|")
			local abilityInfoTable = {ability = {}}
			abilityInfoTable.needFeelLevel = tonumber(singleFeelLevelAbilityInfo[2])
			abilityInfoTable.needUserLevel = tonumber(singleFeelLevelAbilityInfo[3])
			--获取属性id
			abilityInfoTable.ability.id = tonumber(singleAbilityTable[1])
			--获取属性名
			abilityInfoTable.ability.name = DB_Affix.getDataById(tonumber(singleAbilityTable[1])).displayName
			--属性增加值
			abilityInfoTable.ability.addNum = tonumber(singleAbilityTable[2])
			allFeelLevelAbilityArr[arrIndex] = abilityInfoTable
			arrIndex = arrIndex + 1
		end
	end
	return allFeelLevelAbilityArr
end

--[[
	@desc :	更新修行等级能力增加属性面板的数据
	@param:
	@ret  :	
--]]
function updateAttrPanelDataSrc( ... )
	-- if _curMasterInfo.starTemplate.feelId == nil then
	-- 	_attrPanelDataSrc = {}
	-- 	_attrPanelDataSrcMasterId = tonumber(_curMasterInfo.star_id)
	-- 	return
	-- end

	_attrPanelDataSrc = getFeelAbilityBySid(_curMasterInfo.star_id)
end

--[[
	@desc :	获得当前能够达到的最大修行等级(只受配置表的最大修行等级限制)
	@param:
	@ret  :	配置中最大的修行等级
--]]
function getMaxConfigFeelLevel()
	if _curMasterInfo.starTemplate.feelId == nil then
		error("feel ability do not be opened")
	end

	local maxFeelLevel = 0
	for _,v in ipairs(_attrPanelDataSrc) do
		if v.needFeelLevel > maxFeelLevel then
			maxFeelLevel = v.needFeelLevel
		end
	end

	return maxFeelLevel
end

--[[
	@desc :	获得当前能够达到的最大修行等级(同时受用户等级、配置表的最大修行等级限制)
	@param:
	@ret  :	当前用户能够达到的最大修行等级
--]]
function getMaxUserFeelLevel( ... )
	if _curMasterInfo.starTemplate.feelId == nil then
		error("feel ability do not be opened")
	end

	local userLevel = tonumber(UserModel.getAvatarLevel())
	local maxFeelLevel = 0
	for _,v in ipairs(_attrPanelDataSrc) do
		if v.needUserLevel <= userLevel then
			if v.needFeelLevel > maxFeelLevel then
				maxFeelLevel = v.needFeelLevel
			end
		end
	end

	return maxFeelLevel
end

--[[
	@desc :	获得当前能够达到的最大修行值(受用户等级、配置表配置得最大修行等级限制)
	@param:
	@ret  :	当前能够达到的最大修行值
--]]
require "db/DB_Level_up_exp"
function getMaxUserFeelValue()
	local maxFeelLevel = getMaxUserFeelLevel()

	if maxFeelLevel <= 0 then
		return 0
	end

	local levelUpTable = DB_Level_up_exp.getDataById(tonumber(_curMasterInfo.starTemplate.feelExp))
	local totalExp = 0
	print("getMaxUserFeelValue",maxFeelLevel)
	print_t(levelUpTable)
	for i = 1, maxFeelLevel do
		totalExp = totalExp + tonumber(levelUpTable["lv_" .. i])
	end
	return totalExp
end

--[[
	@des 	:增加当前名将的修行值
	@param 	:增加的修行值
	@return :是否升级
--]]
function addCurStarFeel(p_addFeel)
	local isUpGrade = false
	--local originalLeftValue = getLeftFeelValue()
	local originalLV = tonumber(_allInfo.star_list[_curMasterInfo.star_id].feel_level)
	local originalSkill = tonumber(_allInfo.star_list[_curMasterInfo.star_id].feel_skill)
	_allInfo.star_list[_curMasterInfo.star_id].feel_total_exp = tonumber(_allInfo.star_list[_curMasterInfo.star_id].feel_total_exp) + tonumber(p_addFeel)

	local remainExp = _allInfo.star_list[_curMasterInfo.star_id].feel_total_exp

	local starExpId = DB_Star.getDataById(tonumber(_allInfo.star_list[_curMasterInfo.star_id].star_tid)).feelExp
	local levelUpTable = DB_Level_up_exp.getDataById(tonumber(starExpId))
	local maxLevel = tonumber(getMaxConfigFeelLevel())

	for i = 1,tonumber(getMaxConfigFeelLevel()) do
		remainExp = remainExp - tonumber(levelUpTable["lv_" .. i])
		if remainExp < 0 then
			_allInfo.star_list[_curMasterInfo.star_id].feel_level = i - 1
			break
		else
			if i == maxLevel then
				_allInfo.star_list[_curMasterInfo.star_id].feel_level = i
			end
		end
	end

	--如果级别改变
	print("addCurStarFeel",_allInfo.star_list[_curMasterInfo.star_id].feel_level,originalLV)
	if _allInfo.star_list[_curMasterInfo.star_id].feel_level ~= originalLV then
	
		--获取自动升后级技能的信息
		local originalFeelSkill = _allInfo.star_list[_curMasterInfo.star_id].feel_skill	
		local skillInfo = getSkillByFeelLevel(_allInfo.star_list[_curMasterInfo.star_id].feel_level)
		--当师徒关系小于一级技能所需师徒关系等级时skillInfo为nil
		if skillInfo ~= nil then
			_allInfo.star_list[_curMasterInfo.star_id].feel_skill = tostring(skillInfo.skillId)
			--更新学习技能列表中的信息
			_skillList[_selectSkillIndex] = skillInfo
		end
		local curSkill,fromType  = UserModel.getUserRageSkill()	
		if(fromType == 1 and curSkill == tonumber(originalFeelSkill))then
			UserModel.setUserRangeSkill(_allInfo.star_list[_curMasterInfo.star_id].feel_skill,1)
		end
		--判断当前装备的是不是这个技能 如果当前装备的是升级的这个 升级后技能的模板id会变 要把UserModel中的缓存改一下
		
		--刷新学习技能界面的
		require "script/ui/replaceSkill/learnSkill/LearnSkillLayer"
		LearnSkillLayer.refreshAffinityLevel()
		LearnSkillLayer.refreshBottomLabel()

		require "script/ui/replaceSkill/FlipCardLayer"
		FlipCardLayer.showFLyTip(DB_Star.getDataById(tonumber(_allInfo.star_list[_curMasterInfo.star_id].star_tid)).name,_allInfo.star_list[_curMasterInfo.star_id].feel_level)

		-- --刷新信息面板
		-- require "script/ui/replaceSkill/AttributePanel"
		-- AttributePanel.refreshTableView()
	
	end

	if tonumber(_allInfo.star_list[_curMasterInfo.star_id].feel_skill) ~= originalSkill then
		isUpGrade = true
	end

	if originalSkill == 0 and isUpGrade then
		require "script/ui/replaceSkill/AlertGetLayer"
		AlertGetLayer.showLayer(tonumber(_curMasterInfo.star_id))
	end

	if isUpGrade and originalSkill > 0 then
		require "script/ui/replaceSkill/AlertLevelLayer"
		AlertLevelLayer.showLayer(tonumber(_curMasterInfo.star_id))
	end

	--刷新经验条
	-- require "script/ui/replaceSkill/ReplaceSkillLayer"
	-- ReplaceSkillLayer.refreshProgressBar()

	--刷新经验条
	require "script/ui/replaceSkill/learnSkill/LearnSkillLayer"
	LearnSkillLayer.refreshProgressLabel()
	--LearnSkillLayer.runProgressIncreaseAction(originalLV,originalLeftValue,p_addFeel)
	LearnSkillLayer.refreshProgressBar()

	return isUpGrade
end

--[[
	@des 	:如果增加了修行值，是否会超过主角级别上线
	@param 	:增加的修行级别
	@return :是否超出经验范围
--]]
function checkBeyondLevel(p_addFeel)
	local isBeyond = false

	require "script/ui/tip/AnimationTip"
	--获得加完经验后的总经验值
	local curExp = tonumber(_allInfo.star_list[_curMasterInfo.star_id].feel_total_exp) + tonumber(p_addFeel)
	--通往DB_Level_up_exp表的索引id
	local starExpId = DB_Star.getDataById(tonumber(_allInfo.star_list[_curMasterInfo.star_id].star_tid)).feelExp
	--主角当前等级
	local avatarLevelNum = UserModel.getAvatarLevel()

	local levelUpTable = DB_Level_up_exp.getDataById(tonumber(starExpId))

	--达到主角等级所需的经验值
	local avatarMaxExp = 0
	for i = 1,avatarLevelNum do
		avatarMaxExp = avatarMaxExp + tonumber(levelUpTable["lv_" .. i])
	end

	--如果当前经验超过主角等级所需经验
	if curExp >= avatarMaxExp then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1087"))
		isBeyond = true
	end

	return isBeyond
end

--[[
	@des 	:返回当前宗师是否满级
	@param 	:
	@return :是否满级
--]]
function isFullExp()
	-- local starInfo = DB_Star.getDataById(tonumber(_curMasterInfo.star_tid))
	-- local splitTable = string.split(starInfo.)

	local isFull = false
	if tonumber(_allInfo.star_list[_curMasterInfo.star_id].feel_level) == tonumber(getMaxConfigFeelLevel()) then
		isFull = true
	end

	return isFull
end

--[[
	@des 	:返回当前宗师级别
	@param 	:
	@return :当前宗师级别
--]]
function getCurFeelLv()
	return _allInfo.star_list[_curMasterInfo.star_id].feel_level
end

-------------------------------------------------------[[ 选择学习技能 ]]-------------------------------------------------
--[[
	@desc :	根据名将tid获取对应技能信息
	@param:	
	@ret  :	名将的技能信息列表(目前是1~20级)
	skillInfo = {
		{
			starTid = int
			starName = string
			needFeelLevel = int
			skillId = int
			skillLevel = int
			skillName = string
			skillDesc = string
			skillIcon = string
			maxSkillLevel = int
			maxSkillId = int
		}
	}
--]]
require "db/skill"
function getSkillInfoByStid( p_stid )
	local starTemplate = DB_Star.getDataById(tonumber(p_stid))

	if starTemplate.isFeel == nil or starTemplate.skillArr == nil then
		return nil
	end

	local skillInfoStrTable = lua_string_split(starTemplate.skillArr, ",")
	local maxSkillLevel = 0
	local maxSkillId = 0
	local skillInfo = { }
	for k,v in ipairs(skillInfoStrTable) do
		local skillinfoTable = lua_string_split(v, "|")
		local tempTable = {}
		tempTable.starTid = tonumber(p_stid)
		tempTable.starName = starTemplate.name
		tempTable.needFeelLevel = tonumber(skillinfoTable[1])
		tempTable.skillId = tonumber(skillinfoTable[2])
		tempTable.skillLevel = tonumber(skillinfoTable[3])
		tempTable.skillName = skill.getDataById(tempTable.skillId).name
		tempTable.skillDesc = skill.getDataById(tempTable.skillId).des
		tempTable.skillIcon = skill.getDataById(tempTable.skillId).roleSkillPic
		skillInfo[k] = tempTable

		if tempTable.skillLevel > maxSkillLevel then
			maxSkillLevel = tempTable.skillLevel
			maxSkillId = tempTable.skillId
		end
	end

	for _,v in ipairs(skillInfo) do
		v.maxSkillLevel = maxSkillLevel
		v.maxSkillId = maxSkillId
	end

	return skillInfo
end

--[[
	@desc :	根据名将id获取对应技能信息
	@param:	
	@ret  :	名将的技能信息列表(目前是1~10级)
	skillInfo = {
		{
			starId = int
			starTid = int
			starName = string
			needFeelLevel = int
			skillId = int
			skillLevel = int
			skillName = string
			skillDesc = string
			skillIcon = string
			maxSkillLevel = int
			maxSkillId = int
		}
	}
--]]
function getSkillInfoBySid( p_sid )
	print("getSkillInfoBySid",p_sid)
	local starInfo = _allInfo.star_list[tostring(p_sid)]
	local skillInfo = getSkillInfoByStid(starInfo.star_tid)
	if skillInfo ~= nil then
		for k,v in ipairs(skillInfo) do
			skillInfo[k].starId = tonumber(p_sid)
		end
	end
	return skillInfo
end

--[[
	@desc :	根据技能信息列表和技能id获取对应技能信息
	@param:	p_skillList 某个名将的技能信息列表
			p_skillId 技能id
	@ret  :	单个技能信息
	{
		(starId = int)	--名将在用户名将列表中才存在该字段
		starTid = int
		starName = string
		needFeelLevel = int
		skillId = int
		skillLevel = int
		skillName = string
		skillDesc = string
		skillIcon = string
		maxSkillLevel = int
		maxSkillId = int
	}
--]]
function getSkillById( p_skillList, p_skillId )
	if p_skillList == nil then
		return nil
	end

	if type(p_skillList) ~= "table" then
		error("parameters wrong type, table wanted")
	end

	local ret = nil
	for _,v in ipairs(p_skillList) do
		if v.skillId == tonumber(p_skillId) then
			ret = v
			break
		end
	end
	return ret
end

--[[
	@desc :	根据技能信息列表和技能等级获取对应技能信息
	@param:	p_skillList 某个名将的技能信息列表
			p_skillLevel 技能等级
	@ret  :	单个技能信息
	{
		(starId = int)	--名将在用户名将列表中才存在该字段
		starTid = int
		starName = string
		needFeelLevel = int
		skillId = int
		skillLevel = int
		skillName = string
		skillDesc = string
		skillIcon = string
		maxSkillLevel = int
		maxSkillId = int
	}
--]]
function getSkillByLevel( p_skillList, p_skillLevel )
	if p_skillList == nil then
		return nil
	end

	if type(p_skillList) ~= "table" then
		error("parameters wrong type, table wanted")
	end

	local ret = nil
	for _,v in ipairs(p_skillList) do
		if v.skillLevel == tonumber(p_skillLevel) then
			ret = v
			break
		end
	end
	return ret
end

--[[
	@desc :	根据当前师徒关系等级获取技能信息
	@param:
	@ret  :	当前师徒关系等级能够升级的最大技能信息（当前师徒关系等级还不满足学习1等级技能条件时返回nil）

--]]
function getSkillByFeelLevel(p_feelLevel)
	local skillNum = #_curMasterSkillInfo
	local skillInfo = nil
	print("getSkillByFeelLevel",p_feelLevel)
	print_t(_curMasterSkillInfo)
	for k,v in ipairs(_curMasterSkillInfo) do
		if v.needFeelLevel > tonumber(p_feelLevel) then
			skillInfo = _curMasterSkillInfo[k-1]
			break
		else
			if k == skillNum then
				skillInfo = _curMasterSkillInfo[k]
			end
		end
	end
	return skillInfo
end

--[[
	@desc :	判断用户的名将列表中是否存在该名将模版
	@param:
	@ret  :	true 在用户名将列表中
			false 不在用户列表中
--]]
function isInStarList( p_stid )
	if _allInfo.star_list == nil then
		return false
	end

	local ret = false
	for k,v in pairs(_allInfo.star_list) do
		if tonumber(v.star_tid) == tonumber(p_stid) then
			ret = true
			break
		end
	end
	return ret
end

--[[
	@desc :	获取能够选择的学习技能列表
	@param:	p_sid 名将id
			p_skillId 技能id
	@ret  :	单个技能信息
	skillList = {
		{
			(starId = int)  --名将在用户名将列表中才存在该字段
			starTid = int
			starName = string
			needFeelLevel = int
			skillId = int
			skillLevel = int
			skillName = string
			skillDesc = string
			skillIcon = string
			maxSkillLevel = int
			maxSkillId = int
		}
	}
--]]
function getSkillList( ... )
	if _skillList ~= nil then
		return _skillList
	end

	_skillList = {}
	for _,v in pairs(_allInfo.star_list) do
		--获取该名将的技能列表信息
		local curSkillList = getSkillInfoBySid(v.star_id)
		if curSkillList ~= nil then
			--获取当前技能信息
			local curSkillInfo = nil
			if tonumber(v.feel_skill) == 0 then
				curSkillInfo = getSkillByLevel(curSkillList, 1)
				curSkillInfo.skillLevel = 0
			else
				print("getSkillList",v.feel_skill)
				print_t(curSkillList)
				curSkillInfo = getSkillById(curSkillList, v.feel_skill)
			end
			table.insert(_skillList, curSkillInfo)
		end
	end

	
	for k,v in pairs(DB_Star.Star) do
		if not isInStarList(v[1]) then
			local curSkillList = getSkillInfoByStid(v[1])
			if curSkillList ~= nil then
				--获取当前技能信息
				local curSkillInfo = curSkillList[1]
				curSkillInfo.skillLevel = 0
				table.insert(_skillList, curSkillInfo)
			end
		end
	end

	local function sortFunc(p_element1, p_element2)
		return p_element1.skillLevel > p_element2.skillLevel
	end
	--table.sort(_skillList, sortFunc)
	sortSkillList(_skillList)

	--comfirmFirstBtnEnable(_skillList)

	return _skillList
end

--[[
	@desc :	三层排序:
			1. 属于用户名将列表中名将的技能排在前面
			2. 技能没达到最大最大等级的排在前面
			3. 技能等级高的排在前面
	@param:	p_skillList 技能学习选择界面展示的技能列表
	@ret  :	
--]]
function sortSkillList(p_skillList)
	local sortFunc = function (p_child1, p_child2)
		if p_child1.starId ~= nil then
			if p_child2.starId ~= nil then
				if p_child1.skillLevel < p_child1.maxSkillLevel then
					if p_child2.skillLevel < p_child2.maxSkillLevel then
						if p_child1.skillLevel > p_child2.skillLevel then
							return true
						else
							return false
						end
					else
						return true
					end
				else
					return false
				end
			else
				return true
			end
		else
			return false
		end
	end
	table.sort(p_skillList, sortFunc)
end

--[[
	@desc :	保证第一个按钮能够进入学习技能界面
	@param:	p_skillList 技能学习选择界面展示的技能列表
	@ret  :	
--]]
-- function comfirmFirstBtnEnable( p_skillList )
-- 	if p_skillList == nil then
-- 		return
-- 	end
-- 	for k,v in ipairs(p_skillList) do
-- 		--if v.isInStarList ~= nil and v.skillLevel < v.maxSkillLevel then
-- 		if v.starId ~= nil and v.skillLevel < v.maxSkillLevel then
-- 			p_skillList[1],p_skillList[k] = p_skillList[k],p_skillList[1]
-- 			break
-- 		end
-- 	end
-- end


--[[
	@desc :	记录选择学习的技能在列表中的索引
	@param:	p_index 索引值
	@ret  :	
--]]
function setSelectSkillIndex( p_index )
	_selectSkillIndex = tonumber(p_index)
end

--[[
	@desc :	获取当前所学技能在列表中的索引
	@param:	
	@ret  :	
--]]
function getSelectSkillIndex( ... )
	return _selectSkillIndex
end

--[[
	@desc :	获取当前所学技能的信息
	@param:	
	@ret  :	当前所学技能的信息
	{
		starId = int
		starTid = int
		starName = string
		needFeelLevel = int
		skillId = int
		skillLevel = int
		skillName = string
		skillDesc = string
		skillIcon = string
		maxSkillLevel = int
		maxSkillId = int
	}
--]]
function getSelectSkillInfo()
	if _skillList == nil or _selectSkillIndex == nil then
		return nil
	end
	return _skillList[_selectSkillIndex]
end

--[[
	@desc :	获取升级还需要的经验值
	@param:	p_feelLevel 升到的师徒关系等级
	@ret  :	升级还需要的经验值
--]]
function getFeelValueByLevel( p_feelLevel )
	local levelUpExpTemplate = DB_Level_up_exp.getDataById(_curMasterInfo.starTemplate.feelExp)
	return levelUpExpTemplate["lv_" .. p_feelLevel]
end

--[[
	@desc :	MainBaseLayer中天命按钮上是否显示红点提示
	@param:	
	@ret  :	true 显示 false 不显示
--]]
function isShowTip( ... )
	local ret = false
	if getFreeFlipNum() > 0 and DataCache.getSwitchNodeState(ksChangeSkill,false) then
		ret = true
		ret = true
	end
	return ret
end
----------------------------------------------------------[[ 技能预览 ]]-------------------------------------------------
--[[
	@desc : 初始化技能预览需要的数据
	@param:	
	@ret  :	
--]]
function initPreviewData( ... )
	_allSkillList = nil
end

--[[
	@desc : 在技能学习选择界面，预览技能时，根据选择的表格单元索引获取对应名将的所有技能信息
	@param:	
	@ret  :	
--]]
function getAllSkillList( ... )
	if _allSkillList ~= nil then
		return _allSkillList
	end

	_allSkillList = getSkillInfoByStid(_skillList[_selectSkillIndex].starTid)
	return _allSkillList
end
-------------------------------------------------------[[ 宗师录界面 ]]-------------------------------------------------
--[[
	@des 	:根据国家对宗师进行分类
			 以便不用每次调用不同国家都要进行遍历
	@param 	:
	@return :是否已经处理完
--]]
function dealMasterByCountry()
	--所有宗师信息
	local allMasterInfo = {}
	--table.hcopy(_allInfo.star_list,allMasterInfo)
	allMasterInfo = _allInfo.star_list

	--根据不同国家返回宗师录
	for k,v in pairs(allMasterInfo) do
		local masterInfo = DB_Star.getDataById(tonumber(v.star_tid))
		--如果该武将shi
		--设置成0，1是为了方便排序

		if masterInfo.skillArr == nil then
			v.isFeel = 0
		else
			v.isFeel = 1
		end
		if (masterInfo.skillArr ~= nil) or (masterInfo.isFeel ~= nil) then
			table.insert(masterTable[1],v)
			--魏国
			table.insert(masterTable[masterInfo.country + 1],v)
		end
	end

	-- for i = 1,5 do
	-- 	feelSortFunction = function(w1,w2)
	-- 		if w1.isFeel > w2.isFeel then
	-- 			return true
	-- 		else
	-- 			return false
	-- 		end
	-- 	end

	-- 	table.sort(masterTable[i],feelSortFunction)
	-- end
end

--[[
	@des 	:根据国家获得宗师
	@param 	:国家代号
			 1 所有宗师
			 2 魏国
			 3 蜀国
			 4 吴国
			 5 群雄
	@return :相应国家的宗师
--]]
function getMasterByCountry(p_countryId)
	feelSortFunction = function(w1,w2)
		if w1.isFeel > w2.isFeel then
			return true
		else
			return false
		end
	end

	table.sort(masterTable[p_countryId],feelSortFunction)

	return masterTable[p_countryId]
end

--[[
	@des 	:判断是否是宗师
	@param 	:star_id
	@return :是否是宗师
--]]
function isTeacher(p_starId)
	local isTeacher = false
	if tonumber(DB_Star.getDataById((_allInfo.star_list[tostring(p_starId)].star_tid)).isFeel) ~= 1 then
		isTeacher = true
	end

	return isTeacher
end
-------------------------------------------------------[[ 翻牌界面 ]]-------------------------------------------------
--[[
	@des 	:获得剩余免费翻牌次数
	@param 	:
	@return :免费翻牌次数
--]]
function getFreeFlipNum()
	local freeNum = 0
	local teachInfo = DB_Teach.getDataById(1)
	if _allInfo ~= nil and tonumber(_allInfo.draw_num) < tonumber(teachInfo.drawNum) then
		freeNum = tonumber(teachInfo.drawNum) - tonumber(_allInfo.draw_num)
	end

	return freeNum
end

--[[
	@des 	:获得剩余金币翻牌次数
	@param 	:
	@return :金币翻牌次数
--]]
function getGoldFilpNum()
	--用户vip级别
	local vipLevel = UserModel.getVipLevel()
	--因为vip级别从0开始，所以读表时索引+1
	local vipInfo = DB_Vip.getDataById(vipLevel + 1)

	local remainNum = tonumber(vipInfo.cardGoldTimes)

	if getFreeFlipNum() == 0 then
		remainNum = tonumber(vipInfo.cardGoldTimes) + tonumber(DB_Teach.getDataById(1).drawNum) - tonumber(_allInfo.draw_num)
	end

	return remainNum
end

--[[
	@des 	:获得本次翻牌花费金币数目
	@param 	:
	@return :本次翻牌花费金币数目（如果免费次数没用完，返回0）
--]]
function getUseGoldNum()
	local costGoldNum = 0
	if getFreeFlipNum() == 0 then
		local goldUseNum = tonumber(_allInfo.draw_num) - tonumber(DB_Teach.getDataById(1).drawNum)
		local costTable = string.split(DB_Teach.getDataById(1).buyDrawNum,"|")
		costGoldNum = tonumber(costTable[1]) + goldUseNum*tonumber(costTable[2])
		if costGoldNum >= tonumber(costTable[3]) then
			costGoldNum = tonumber(costTable[3])
		end
	end

	return costGoldNum
end

--[[
	@des 	:得到未领奖的奖励信息
	@param 	:
	@return :未领奖的奖励信息
--]]
function remainRewardInfo()
	--要返回的table
	local returnTable = {}

	if (not table.isEmpty(_allInfo.va_act_info)) and (_allInfo.va_act_info.draw ~= nil) then
		if _allInfo.va_act_info.draw[_curMasterInfo.star_id] ~= nil then
			returnTable = _allInfo.va_act_info.draw[_curMasterInfo.star_id]
		end
	end

	return returnTable
end

--[[
	@des 	:根据sid得到是否有未领取的奖励
	@param 	:sid
	@return :未领奖的奖励信息
--]]
function remainInfoBySid(p_sid)
	local returnTable = {}
	if (not table.isEmpty(_allInfo.va_act_info)) and (_allInfo.va_act_info.draw ~= nil) then
		if _allInfo.va_act_info.draw[tostring(p_sid)] ~= nil then
			returnTable = _allInfo.va_act_info.draw[tostring(p_sid)]
		end
	end

	return returnTable
end

--[[
	@des 	:领完奖删除对应的未领奖人物
	@param 	:
	@return :
--]]
function deleteDraw()
	if (not table.isEmpty(_allInfo.va_act_info)) and (_allInfo.va_act_info.draw ~= nil) then
		if  _allInfo.va_act_info.draw[_curMasterInfo.star_id] ~= nil then
			--删除相应字段
			_allInfo.va_act_info.draw[_curMasterInfo.star_id] = nil
		end
	end
end

--[[
	@des 	:添加未领奖的卡牌信息
	@param 	:$ p_cardTable 卡牌信息
	@return :
--]]
function addRemainData(p_cardTable)
	--如果没有这个字段
	if _allInfo.va_act_info.draw == nil then
		_allInfo.va_act_info.draw = {}
		_allInfo.va_act_info.draw[_curMasterInfo.star_id] = p_cardTable
		-- if p_haveChange == true then
		-- 	_allInfo.va_act_info.draw[_curMasterInfo.star_id][7] = 1
		-- end
	else
		_allInfo.va_act_info.draw[_curMasterInfo.star_id] = p_cardTable
		-- if p_haveChange == true then
		-- 	_allInfo.va_act_info.draw[_curMasterInfo.star_id][7] = 1
		-- end
	end
end

--[[
	@des 	:通过牌型id获得相应获得修行值
	@param 	:牌型id
	@return :修行值
--]]
function getHonorNumById(p_comboId)
	local teachInfo = DB_Teach.getDataById(1)
	--牌型信息
	local drawInfo = teachInfo.draw
	--初步分离
	local allCardInfo = string.split(drawInfo,",")
	--相应牌型的分离
	local curCardInfo = string.split(allCardInfo[p_comboId],"|")

	return tonumber(curCardInfo[3])
end

--[[
	@des 	:返回当日翻牌获得的总修行值
	@param 	:
	@return :当日翻牌获得的总修行值
--]]
function getCurDayMonkery()
	return _allInfo.draw_feel
end

--[[
	@des 	:增加当日修行值
	@param 	:增加的修行值
	@return :
--]]
function addCurDayMonkery(p_addPoint)
	_allInfo.draw_feel = tonumber(_allInfo.draw_feel) + tonumber(p_addPoint)
end

--[[
	@des 	:翻牌次数加1
	@param 	:
	@return :
--]]
function addFlipNum(p_num)
	local addNum = p_num or 1

	_allInfo.draw_num = tonumber(_allInfo.draw_num) + tonumber(addNum)
end

--[[
	@des 	:得到充值所需金币
	@param 	:扣牌数量
	@return :
--]]
function getResetCardGold(p_resetNum)
	local teachInfo = DB_Teach.getDataById(1)
	--需要金币信息
	local resetInfo = teachInfo.refreshCardCost
	--一级分解
	local oneTable = string.split(resetInfo,",")
	--二级分解
	local twoTable = string.split(oneTable[p_resetNum],"|")

	return tonumber(twoTable[2])
end

--[[
	@des 	:得到一键高富帅所需金币数
	@param 	:
	@return :所需金币数
--]]
function getOneSetGold()
	return tonumber(DB_Teach.getDataById(1).maxGold)
end

-------------------------------------------------------[[ 更换技能信息 ]]-------------------------------------------------
--[[
	@des 	:得到更换的技能
	@param 	:
	@return :更换的技能
--]]
function getChangeSkillInfo()
	local skillId = 0
	--如果主角换了技能
	if _allInfo ~= nil and _allInfo.va_act_info.skill ~= nil then
		skillId = _allInfo.star_list[_allInfo.va_act_info.skill].feel_skill

	end

	return skillId
end

--[[
	@des 	:得到更换后的普通技能
	@param 	:
	@return :更换的普通技能
--]]
function getNormalSkillInfo()
	local star_Tid = _allInfo.star_list[_allInfo.va_act_info.skill].star_tid
	local starDBInfo = DB_Star.getDataById(star_Tid)
	local skillString = starDBInfo.changeNormalSkill

	local firstTable = string.split(skillString,",")
	for i = 1,2 do
		local secondTable = string.split(firstTable[i],"|")
		if tonumber(secondTable[1]) ~= tonumber(UserModel.getUserSex()) then
			return   secondTable[2]
		end
	end
end

--[[
	@des 	:更换技能
	@param 	:更换的starId
	@return :
--]]
function changePlayerSkill(p_starId)
	if tonumber(p_starId) == 0 then
		_allInfo.va_act_info.skill = nil
	else
		_allInfo.va_act_info.skill = p_starId
	end
end

--[[
	@des 	:得到当前技能属于谁
	@param 	:
	@return :当前技能人得sid
--]]
function getCurSkillSid()
	local s_id = 0
	if _allInfo.va_act_info.skill ~= nil then
		s_id = tonumber(_allInfo.va_act_info.skill)
	end

	return s_id
end

--[[
	@des 	:添加新宗师
	@param 	:新宗师信息
	@return :
--]]
function addNewTeacher(p_newTeacherInfo)
	--因为宗实录每次调用不用每次都把分类都来一遍，所以当有新宗师的时候再分类一下
	for i = 1,5 do
		masterTable[i] = {}
	end

	--添加新宗师
	_allInfo.star_list[p_newTeacherInfo.star_id] = p_newTeacherInfo
end
--[[
	@des 	:获取怒气技能的列表
	@param 	:
	@return :
--]]
function getSpecialSkillList()
	require "db/DB_Heroes"
	local skillList = {}
	
	skillList[1] = {} --位置一先放上自己的技能
	local db_hero = DB_Heroes.getDataById(UserModel.getAvatarHtid())
	local skillId = db_hero.rage_skill_attack
	skillList[1].feel_skill = skillId
	skillList[1].from = 0

    --加通过学习获得的怒气技能
	local learnSkill = getAllInfo()
	if(table.isEmpty(learnSkill) == false)then
		learnSkill = table.hcopy(learnSkill,{})
		if(learnSkill ~= nil)then
			local count = table.count(skillList)
			for k,v in pairs(learnSkill.star_list) do
				 if(tonumber(v.feel_skill) ~= 0)then
			
	                table.insert(skillList,v)
	                count = count + 1 
	                skillList[count].from = 1
	            end
			end
		end
	end
	
	--加通过星魂系统获得的怒气技能
	require "script/ui/athena/AthenaData"
	local athenaSkill = AthenaData.getAthenaRangeSkill()
	if(table.isEmpty(athenaSkill) == false)then
		athenaSkill = table.hcopy(athenaSkill,{})
	
		if(table.isEmpty(athenaSkill) == false)then
			local count = table.count(skillList)
			for k,v in pairs(athenaSkill) do
				 if(tonumber(v) ~= 0)then
				 	
				 	count = count + 1 
				 	skillList[count] = {}
				 	skillList[count].feel_skill = tonumber(v)
				 	skillList[count].from = 2
	            end
			end
		end
	end

	local curSkill,fromType  = UserModel.getUserRageSkill()
	curSkill = tonumber(curSkill)
	fromType = tonumber(fromType)

	local doubleTab = {}
	local userGender = UserModel.getUserSex()
	local skillMap = AthenaData.getSkillMap(userGender)
	local isOnTag = 0 --记录第几个位置存放了正在装备的技能
	local resTab = {} --最后的返回结果
	local defaultRankId = -1
	--开始将结果排序
	for i=1,#skillList do
		local tmpDoubleTab = {}
		if(not skillList[i].isSelected)then
			if(tonumber(skillList[i].feel_skill) == curSkill and skillList[i].from == fromType)then
				skillList[i].isOn = true
				isOnTag = #doubleTab + 1
			end
			--当前这个技能还没被接入doubleTab中	
			tmpDoubleTab[1] = skillList[i]
			skillList[i].isSelected = true
	
			if not table.isEmpty( skillMap[tostring(skillList[i].feel_skill)] ) then
				local friendId = skillMap[tostring(skillList[i].feel_skill)].skill_id
				if(friendId ~= nil)then
					--如果找到可配对技能
					tmpDoubleTab.rankId = skillMap[tostring(skillList[i].feel_skill)].dbId
					--先获取排序的权重
					for k,v in pairs(skillList)do
						if v.feel_skill == friendId then
							if(tonumber(v.feel_skill) == curSkill and v.from == fromType)then
								v.isOn = true
								isOnTag = #doubleTab + 1
							end
							v.isSelected = true
							tmpDoubleTab[2] = v					
						end
					end
				end
			else
				--排序权重靠后赋值
				tmpDoubleTab.rankId = defaultRankId
				defaultRankId = defaultRankId -1
			end
			table.insert(doubleTab,tmpDoubleTab)
		end
		
	end

	if(isOnTag ~= 0)then
		local onTab = doubleTab[isOnTag]
		if tonumber(onTab[1].feel_skill) == curSkill then
			table.insert(resTab,onTab[1])
			if not table.isEmpty(onTab[2]) then
				table.insert(resTab,onTab[2])
			end
		elseif tonumber(onTab[2].feel_skill) == curSkill then
			table.insert(resTab,onTab[2])
			table.insert(resTab,onTab[1])
		end

		table.remove(doubleTab,isOnTag)
	end
	table.sort(doubleTab,doubleRankSort)
	for k,v in pairs(doubleTab) do 
		table.insert(resTab,v[1])
		if not table.isEmpty(v[2])  then
			table.insert(resTab,v[2])
		end
	end
    return resTab
end
function doubleRankSort(goods_1,goods_2 )

	if(tonumber(goods_1.rankId) > tonumber(goods_2.rankId))then
        return true
    elseif(tonumber(goods_1.rankId) == tonumber(goods_2.rankId) or tonumber(goods_1.rankId) < tonumber(goods_2.rankId))then
        return false
    end
end

--[[
    @des    :交换一个表中的两个位置的值
    @param  :
    @return :
--]]
-- function swap(table, indexA, indexB)
--     local temp = table[indexA]
--     table[indexA] = table[indexB]
--     table[indexB] = temp
-- end
--[[
	desc :	根据技能id创建技能图标
--]]
require "db/skill"
function createSkillIcon(p_skillId)
	p_skillId = tonumber(p_skillId)
	local skillIconBg = CCSprite:create("images/item/bg/itembg_4.png")
	local skillIconSize = skillIconBg:getContentSize()

	local skillTemplate = skill.getDataById(tonumber(p_skillId))
	print("createSkillIcon",p_skillId)
	local skillIconSprite = CCSprite:create("images/replaceskill/skillicon/" .. skillTemplate.roleSkillPic)
	skillIconSprite:setAnchorPoint(ccp(0.5,0.5))
	skillIconSprite:setPosition(skillIconSize.width/2, skillIconSize.height/2)
	skillIconBg:addChild(skillIconSprite)

	return skillIconBg
end