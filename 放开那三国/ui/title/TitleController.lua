-- Filename: TitleController.lua
-- Author: lgx
-- Date: 2016-05-04
-- Purpose: 称号系统控制层

module("TitleController", package.seeall)

require "script/ui/title/TitleService"
require "script/ui/title/TitleDef"
require "script/ui/title/TitleData"
require "script/model/DataCache"
require "script/ui/tip/AnimationTip"

--[[
	@desc 	: 获取玩家称号信息
	@param 	: 
	@return : 
--]]
function getStylishInfo( pCallback )
	-- 请求回调
	local requestCallback = function ( pData )
		-- 初始化称号数据
		TitleData.setTitleInfo(pData)

		if pCallback then
			pCallback()
		end
	end
	-- 发送请求
	TitleService.getStylishInfo(requestCallback)
end

--[[
	@desc 	: 玩家装备称号
	@param 	: pTitleId 称号ID
	@return : 
--]]
function setTitle( pCallback , pTitleId )
	-- 请求回调
	local requestCallback = function ( ... )
		-- 记录之前装备的称号
		local oldTitleId = UserModel.getTitleId()

		-- 更新当前装备称号
		UserModel.setTitleId(pTitleId)

		-- 如果装备了限时称号,开启称号失效定时器
		require "script/ui/title/TitleUtil"
		TitleUtil.openTitleDisappearTimer()

		-- 刷新界面
		require "script/ui/title/TitleMainLayer"
		TitleMainLayer.updateTitleInfoAndList()

		-- 提示及战斗力更新
		AnimationTip.showTip(GetLocalizeStringBy("key_1537"))
		TitleData.getEquipTitleAttrInfoByHid(nil,true)

		-- 加成属性飘字
		require "script/ui/tip/AttrTip"
		TitleUtil.showTitleAttrTip(pTitleId,oldTitleId)

		if pCallback then
			pCallback()
		end
	end
	-- 发送请求
	TitleService.setTitle(requestCallback,pTitleId)
end

--[[
	@desc 	: 玩家激活(使用)称号
	@param 	: pTitleId 称号ID pItemId 消耗物品ID
	@return : 
--]]
function activeTitle( pCallback , pTitleId , pItemId , pItemNum )
	-- 判断限制条件

	-- 1.未开启称号系统的玩家获得称号使用时，弹出悬浮提示“未开启称号系统，暂不能使用”。
	if (not DataCache.getSwitchNodeState(ksSwitchTitle,false)) then
		AnimationTip.showTip(GetLocalizeStringBy("lgx_1028"))
        return
    end

    -- 2.若玩家获得称号为重复称号时：
    -- 永久性称号不可重复使用，点击使用后，有悬浮提示“不可重复使用”，玩家可直接卖出。 
    -- 时效性称号可以重复使用，时效时间延长。
    local titleInfo = TitleData.getTitleInfoById(pTitleId)
    if (titleInfo ~= nil) then 
		if ( titleInfo.time_type == TitleDef.kTimeTypeForever and titleInfo.isGot == TitleDef.kTitleIllustrateHadGot) then
			AnimationTip.showTip(GetLocalizeStringBy("lgx_1029"))
	        return
	    end

		-- 请求回调
		local requestCallback = function ()
			-- 在背包中点击宝箱进行使用，直接激活称号及图鉴属性，且悬浮提示：“恭喜您获得XXXXX称号”。
			-- 若此时玩家想要装备或更换此称号，需在称号系统内进行更换称号。
			local titleName = TitleData.getTitleInfoById(pTitleId).signname
			AnimationTip.showTip(GetLocalizeStringBy("key_3311")..titleName..GetLocalizeStringBy("lgx_1030"))

			-- 更新获得的称号 和 战斗力
			TitleData.updateTitleIsGotAndDeadlineById(pTitleId,pItemNum)
			TitleData.getGotTitleAttrInfo(true)

			-- 更新最近获得称号数组
			TitleData.setLastGotTitleIdToArr(pTitleId)

			local curTitleId = UserModel.getTitleId()
			if (curTitleId == pTitleId) then
				-- 如果激活的称号 是当前装备的称号 刷新失效倒计时
				require "script/ui/title/TitleUtil"
				TitleUtil.openTitleDisappearTimer()
			end

			if pCallback then
				pCallback()
			end
		end
		-- 发送请求
		TitleService.activeTitle(requestCallback,pTitleId,pItemId,pItemNum)
	else
		print("activeTitle failed! Title not exist pTitleId ",pTitleId)
	end
end

--[[
	@desc 	: 玩家激活(使用)称号 批量或者单个
	@param 	: pItemInfo 称号物品信息
	@return : 
--]]
function activeTitleWithItemInfo( pItemInfo )
	if (pItemInfo == nil) then
		return
	end
	-- 1.未开启称号系统的玩家获得称号使用时，弹出悬浮提示“未开启称号系统，暂不能使用”。
	if (not DataCache.getSwitchNodeState(ksSwitchTitle,false)) then
		AnimationTip.showTip(GetLocalizeStringBy("lgx_1028"))
        return
    end
	local titleId = tonumber(pItemInfo.itemDesc.sign)
	local itemId = tonumber(pItemInfo.item_id)
	local itemNum = tonumber(pItemInfo.item_num)
	local isCanBatch = TitleData.isCanBatchActiveById(titleId)
	if (isCanBatch and tonumber(pItemInfo.item_num) > 1) then
		-- 批量使用
		local confirmCallback = function( pUseNum )
			-- 实际确认使用
			activeTitle( nil, titleId, itemId, pUseNum )
		end
		require "script/ui/title/TitleBatchActiveDialog"
		TitleBatchActiveDialog.showDialog( confirmCallback, pItemInfo, itemNum )
	else
		-- 单个使用
		activeTitle( nil, titleId, itemId, 1 )
	end
end