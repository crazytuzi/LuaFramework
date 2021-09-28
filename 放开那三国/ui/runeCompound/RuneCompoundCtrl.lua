-- Filename: RuneCompoundCtrl.lua
-- Author: zhangqiang
-- Date: 2016-07-26
-- Purpose: 符印合成控制

module("RuneCompoundCtrl", package.seeall)
require "script/ui/runeCompound/RuneCompoundData"
require "script/ui/runeCompound/RuneCompoundLayer"
require "script/ui/runeCompound/RuneCompoundCell"
require "script/ui/runeCompound/RuneCompoundService"
require "script/ui/runeCompound/RuneCompoundConst"
require "script/ui/chariot/ChariotUtil"
require "script/ui/item/ItemSprite"
require "script/ui/bag/BagLayer"


--[[
	@desc  : 显示界面
	@param :
	@return: 
--]]
function showLayer( pTouchPriority, pZOrder )
	init()                     --初始化

	RuneCompoundLayer.show(pTouchPriority, pZOrder)   --显示UI
	registerViewHandler()      --注册回调
end

--[[
	@desc  : 关闭界面
	@param :
	@return: 
--]]
function closeLayer( ... )
	RuneCompoundLayer.close()
end

--[[
	@desc  : 初始化
	@param :
	@return: 
--]]
function init( ... )
	--加载数据
	RuneCompoundData.load()
end

--[[
	@desc  : 界面关闭时处理
	@param :
	@return: 
--]]
function deinit( ... )
	RuneCompoundData.deinit()
end

--[[
	@desc  : 注册回调
	@param :
	@return: 
--]]
function registerViewHandler( ... )
	RuneCompoundLayer._fnOnExit = function ( ... )
		onMainExit()
	end

	RuneCompoundLayer._fnTapCloseCb = function ( pTag, pItem )
		tapCloseCb(pTag, pItem)
	end

	RuneCompoundLayer._fnTapMenuItemCb = function ( pTag, pItem )
		tapMenuItemCb(pTag, pItem)
	end

	RuneCompoundLayer._tapCompoundCb = function ( pTag, pItem )
		tapCompoundCb(pTag, pItem)
	end
end

--[[
	@desc  : 显示成功获取合成物品界面
	@param :
	@return: 
--]]
function showReward( pMethodId )
	local tbMethodData = RuneCompoundData.getCompoundDataById(pMethodId)
	if table.isEmpty(tbMethodData) then
		return
	end

	local achie_reward = ItemUtil.getItemsDataByStr( tbMethodData.desc.product)
    ReceiveReward.showRewardWindow( achie_reward, nil , 10008, RuneCompoundLayer._nBaseTouchPriority+RuneCompoundLayer.kShowRewardRelativeTouchPriority, GetLocalizeStringBy("zzh_1322") )
end


------------------------------回调------------------------------
--[[
	@desc  : 界面关闭时数据处理
	@param :
	@return: 
--]]
function onMainExit( ... )
	deinit()
end

--[[
	@desc  : 关闭按钮回调
	@param :
	@return: 
--]]
function tapCloseCb( pTag, pItem )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	closeLayer()
end

--[[
	@desc  : 点击菜单按钮回调
	@param :
	@return: 
--]]
function tapMenuItemCb( pTag, pItem )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	--设置页码指示器状态
	RuneCompoundLayer.setCurMenuItemIdx(pTag)

	--刷新整个界面
	RuneCompoundLayer.refreshAll()
end

--[[
	@desc  : 点击合成按钮
	@param :
	@return: 
--]]
function tapCompoundCb( pTag, pItem )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	local nCurMenuItemIdx, nCurPageIdx = RuneCompoundLayer.getCurMenuItemIdx(), RuneCompoundLayer.getCurPageIdx()
	local nCompoundState, sDesc = RuneCompoundData.sendComposeRune(nCurMenuItemIdx, nCurPageIdx, function ( ... )
		closeLayer()
	end)   --发送请求
	if nCompoundState ~= 0 then
		AnimationTip.showTip(sDesc)
		return
	end
end

--[[
	@desc  : 处理事件
	@param : pEvent = {
		name = string,   --事件名字
		data = table,    --事件数据
	}
	@return: 
--]]
function dispatchEvent( pEvent )
	if pEvent.name == RuneCompoundConst.EventName.RUNE_COMPOUND_SUCCESS then
		--合成成功
		local nMethodId = pEvent.data.nMethodId

		RuneCompoundLayer.lockOperation()
		RuneCompoundLayer.playCompoundEffect(function ( ... )
			--刷新合成配方tableView
			RuneCompoundLayer.refreshPageView()      

			--显示获取合成物品界面
			showReward(nMethodId)

			--解锁操作限制
			RuneCompoundLayer.unlockOperation()
		end)   --播放动画
	elseif pEvent.name == RuneCompoundConst.EventName.RUNE_COMPOUND_COST_ITEM_PUSH then
		--背包推送
		BagLayer.refreshDataByType()             --刷新背包界面（由于消耗并生成了符印）

		-- RuneCompoundLayer.refreshPageView()      --刷新合成配方tableView
	else

	end
end
















