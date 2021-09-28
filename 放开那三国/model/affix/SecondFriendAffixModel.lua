-- Filename: SecondFriendAffixModel.lua.
-- Author: licheyang
-- Date: 2015-03-05
-- Purpose: 第二套小伙伴属性

module("SecondFriendAffixModel", package.seeall)

require "script/ui/formation/secondfriend/SecondFriendData"
require "script/model/affix/HeroAffixModel"
require "script/model/affix/AllStarAffixModel"
require "script/model/affix/UnionAffixModel"
require "script/model/affix/PillAffixModel"
require "script/ui/formation/secondfriend/stageenhance/StageEnhanceData"

-- DB_Secondfriends.attribute "1|51|1000" 
-- 公式: (好感，天赋，觉醒，进化，进阶，强化，羁绊，基础属性)[id1] * id3/100 增加到属性id2上

-- local _secondAttr 							= {} -- 缓存 { id = value, }  key全部都number类型

--[[
	@des :得到第二天小伙伴阵上所有武将增加的属性
	@parm:  p_isForce true为重新计算
	@ret:{
		affixId => affixValue,
		...
	}
--]]
function getAffixByHid( p_isForce )

    local retAffix = {}
	-- if(p_isForce ~= true and not table.isEmpty(_secondAttr) )then
	-- 	-- 优先返回缓存
	-- 	retAffix = _secondAttr
	-- 	return retAffix
	-- end

	-- 重新计算
	local secondFriendInfo = SecondFriendData.getSecondFriendInfo()
	for k_pos,v_hid in pairs(secondFriendInfo) do
		if(tonumber(v_hid) > 0)then
			local curAddtab = getOfferAffixByHid( v_hid )
			for k_affxid,v_num in pairs(curAddtab) do
				if( retAffix[k_affxid] ~= nil)then
					retAffix[k_affxid] =  retAffix[k_affxid] + v_num
				else
					retAffix[k_affxid] =  v_num
				end
			end
		end
	end
    require "script/ui/formation/secondfriend/stageenhance/StageEnhanceData"
    local locakAffix = StageEnhanceData.getLockAffiX(true)
    retAffix = table.add(locakAffix, retAffix)


	return retAffix
end



--[[
	@des :得到第二天小伙伴阵上单个武将增加的属性
	@parm: p_hid 武将id
	@ret:{
		affixId => affixValue,
		...
	}
--]]
function getOfferAffixByHid( p_hid )
	local affix = {}
	local curHid = p_hid
	local curPos = nil
	-- 第二套小伙伴属性
	local secondFriendInfo = SecondFriendData.getSecondFriendInfo()
	for k_pos,v_hid in pairs(secondFriendInfo) do
		if( tonumber(v_hid) == tonumber(p_hid) )then
			curPos = tonumber(k_pos)
			break
		end
	end
	if( curPos == nil)then
		return affix
	end
	local secondAffix = {}
	-- 好感属性
	secondAffix[1] = AllStarAffixModel.getAffixByHid(curHid)
	-- 天赋
	secondAffix[2] = HeroAffixModel.getHeroTalentAffixByHid( curHid )
	-- 觉醒
	secondAffix[3] = HeroAffixModel.getHeroAwakenAffix( curHid )
	-- 计算武将本身属性、武将的等级、进阶等级有关、进化
	secondAffix[4] = HeroAffixModel.getHeroAffix( curHid )
	-- 羁绊
	secondAffix[5] = UnionAffixModel.getAffixByHid(curHid)
	-- 丹药
	secondAffix[6] = PillAffixModel.getAffixByHid(curHid)
	-- print("hero hid", p_hid)

	-- printTable("starTab", secondAffix[1])
	-- printTable("telentTab", secondAffix[2])
	-- printTable("awakenTab", secondAffix[3])
	-- printTable("heroAffTab", secondAffix[4])
	-- printTable("unionTab", secondAffix[5])
	printTable("pillAffix",secondAffix[6])
	--  表配置增加属性组
	for i=1,#secondAffix do
		for k,v in pairs(secondAffix[i]) do
			if affix[tonumber(k)] == nil then
				affix[tonumber(k)] = v
			else
				affix[tonumber(k)] = affix[tonumber(k)] + v
			end
		end
	end
	for i=1,100 do
		affix[i] = affix[i] or 0
	end
	-- 统帅
	affix[6] = (affix[6] + affix[6]*(affix[16]/10000))/100
	-- 武力
	affix[7] = (affix[7] + affix[7]*(affix[17]/10000))/100
	-- 智力
	affix[8] = (affix[8] + affix[8]*(affix[18]/10000))/100
	-- 生命
	affix[1] = (affix[1] + affix[1]*(affix[11]/10000) + affix[51]) * (1+(affix[6]-50)/100)
	-- 通用攻击
	affix[9] = affix[9] + affix[9]*(affix[19]/10000) + affix[100]
	-- 法防
	affix[5] = affix[5] + affix[5]*(affix[15]/10000) + affix[55]
	-- 物防
	affix[4] = affix[4] + affix[4]*(affix[14]/10000) + affix[54]
	-- 物攻
	affix[2] = affix[2] + affix[2]*(affix[12]/10000)
	-- 法攻
	affix[3] = affix[3] + affix[3]*(affix[13]/10000)

	for k,v in pairs(affix) do
		affix[k] = math.floor(v)
	end

	-- printTable("affix", affix)
	printTable("secondAffix", affix)
	-- 表配置增加基础属性组
	local addAtrrTab = SecondFriendData.getSecFriendAddAttrByPos(curPos)

	-- 当前位置强化等级
	local curPosLv = StageEnhanceData.getCurStageLv( curPos )
	local curGrowAttrTab = StageEnhanceData.handleSingleUpAffix(curPos,curPosLv)

	local retAffix = {}
	for k,db_tab in pairs(addAtrrTab) do
		-- 总值的百分比增加到id2上	
		retAffix[tonumber(db_tab[2])] = math.floor( affix[tonumber(db_tab[1])]*(tonumber(db_tab[3]) + curGrowAttrTab[tonumber(db_tab[2])])/10000 )
	end
	-- printTable("addAtrrTab", addAtrrTab)
	-- printTable("retAffix", retAffix)
	printTable("SecondFriendAffixModel getOfferAffixByHid", retAffix)

	return retAffix
end
