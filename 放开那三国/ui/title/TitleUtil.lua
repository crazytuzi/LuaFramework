-- Filename: TitleUtil.lua
-- Author: lgx
-- Date: 2016-05-04
-- Purpose: 称号系统工具类 用创建公有UI 等等

module("TitleUtil", package.seeall)
require "script/ui/title/TitleData"
require "db/DB_Sign"
require "script/utils/LuaUtil"
require "script/utils/TimeUtil"

--[[
	@desc 	: 根据称号ID创建正常的称号Sprite
	@param 	: number pTitleId 称号ID 
	@return : sprite 正常的称号Sprite
--]]
function createTitleNormalSpriteById( pTitleId )
	local titleSprite = nil
	if (pTitleId ~= nil and tonumber(pTitleId) > 0) then
		local titleInfo = DB_Sign.getDataById(pTitleId)
		if (titleInfo) then
			if (titleInfo.imageshows ~= nil) then
				-- 有特效 特效的锚点(0.5,0.5) 无法修改哦 加在空的Sprite上可以控制锚点
				titleSprite = XMLSprite:create("images/title/effect/"..titleInfo.imageshows.."/"..titleInfo.imageshows)
			else
				-- 只有图片
				titleSprite = CCSprite:create("images/title/picture/" .. titleInfo.picture)
			end
		else
			-- 空sprite
			titleSprite = CCSprite:create()
			print("createTitleNormalSpriteById pTitleId error!",pTitleId)
		end
	else
		-- 空sprite
		titleSprite = CCSprite:create()
	end
	return titleSprite
end

--[[
	@desc 	: 根据称号ID创建置灰的称号Sprite,特效或图片
	@param 	: number pTitleId 称号ID 
	@return : sprite 置灰的称号Sprite
--]]
function createTitleGraySpriteById( pTitleId )
	local titleSprite = nil
	if (pTitleId ~= nil and tonumber(pTitleId) > 0) then
		local titleInfo = DB_Sign.getDataById(pTitleId)
		if (titleInfo) then
			if (titleInfo.imageshows ~= nil) then
				-- 有特效
				titleSprite = BTGraySprite:create("images/title/picture/" .. titleInfo.picture)
			else
				-- 只有图片
				titleSprite = BTGraySprite:create("images/title/picture/" .. titleInfo.picture)
			end
		else
			-- 空sprite
			titleSprite = CCSprite:create()
			print("createTitleGraySpriteById pTitleId error!")
		end
	else
		-- 空sprite
		titleSprite = CCSprite:create()
	end
	return titleSprite
end

--[[
	@des 	: 给定时间，和当前时间比较，得到剩余时间
	@param 	: 给定的时间
	@return : xx天xx:xx:xx
--]]
function getRemainTime( pMagicTime )
	--得到比服务器慢1秒的服务器时间
	local serverTime = TimeUtil.getSvrTimeByOffset()
	--剩余时间
	local remainTime = pMagicTime - serverTime

	if tonumber(remainTime) < 0 then
		return "0" .. GetLocalizeStringBy("key_2825") .. "00:00:00"
	end

	--天数
	local DNum = math.floor(remainTime/(3600*24))
	remainTime = remainTime - DNum*3600*24
	--小时数
	local HNum = math.floor(remainTime/3600)
	remainTime = remainTime - HNum*3600
	--分数
	local MNum = math.floor(remainTime/60)
	remainTime = remainTime - MNum*60
	--秒数
	local SNum = remainTime

	local timeString = string.format("%i%s%02i:%02i:%02i",DNum,GetLocalizeStringBy("key_2825"),HNum,MNum,SNum)

	return timeString
end

--[[
	@des 	: 根据装备的称号 是否限时 开启定时器
	@param 	: 
	@return : 
--]]
function openTitleDisappearTimer()
	-- 如果装备了限时称号,开启称号 失效定时器
	local curTitleId = UserModel.getTitleId()
	if (curTitleId > 0) then
		require "script/ui/title/TitleDisappearTimer"
		local userTitleInfo = TitleData.getTitleInfoById(curTitleId)
		if (userTitleInfo.time_type == TitleDef.kTimeTypeLimited) then
			TitleDisappearTimer.startTitleDisappearTimer(userTitleInfo.deadline)
		else
			TitleDisappearTimer.stopScheduler()
		end
	end
end

--[[
	@desc 	: 装备称号属性加成提示 
	@param	: pCurTitleId 新装备的称号ID
	@param	: pOldTitleId 之前装备的称号ID
	@return	:
--]]
function showTitleAttrTip( pCurTitleId, pOldTitleId )
	if (pCurTitleId <= 0) then
		return
	end

	local curTitleAttr = TitleData.getTitleEquipAttrInfoById(pCurTitleId)
	local oldTitleAttr = nil
	if (pOldTitleId > 0) then
		oldTitleAttr = TitleData.getTitleEquipAttrInfoById(pOldTitleId)
		-- 合并数据
		for k,v in pairs(curTitleAttr) do
			if ( oldTitleAttr[k] ~= nil ) then
				curTitleAttr[k] = v - oldTitleAttr[k]
			end
		end
	end

	local textTab = {}
    for k,v in pairs(curTitleAttr) do
    	local affixDesc, displayNum, realNum = ItemUtil.getAtrrNameAndNum(k,v)
    	if (v ~= 0) then	
	    	local text = {}
			text.txt = affixDesc.sigleName
			text.num = displayNum
			table.insert(textTab,text)
		end
    end

	if (table.isEmpty(textTab)) then
		return
	end

	require "script/utils/LevelUpUtil"
	LevelUpUtil.showFlyText(textTab)
end