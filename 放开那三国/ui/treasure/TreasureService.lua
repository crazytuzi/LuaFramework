-- Filename: TreasureService..lua
-- Author: lichenyang
-- Date: 2013-11-2
-- Purpose: 宝物网络业务层

module("TreasureService", package.seeall)
require "script/ui/treasure/TreasureData"
require "script/ui/tip/AnimationTip"
require "script/model/user/UserModel"
require "script/ui/treasure/RobBattleResultView"
require "script/ui/item/ItemUtil"
--[[
	@des 	:拉取玩家所有碎片
	@param 	:callbackFunc 完成回调方法
	@return :
]]
function getSeizerInfo( callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
			TreasureData.seizerInfoData = dictData.ret
			if(callbackFunc ~= nil) then
				callbackFunc()
			end
		end
	end
	local args = CCArray:create()
	Network.rpc(requestFunc, "fragseize.getSeizerInfo", "fragseize.getSeizerInfo", nil, true)
end

function getRecRicher( callbackFunc , item_temple_id)
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
			TreasureData.robberInfo = dictData.ret
			if(callbackFunc ~= nil) then
				callbackFunc()
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(item_temple_id))
	args:addObject(CCInteger:create(4))
	Network.rpc(requestFunc, "fragseize.getRecRicher", "fragseize.getRecRicher", args, true)
	
end

--[[
	@des 	:宝物融合
	@param 	:treasure_id 要融合的宝物id, num 要合成的个数,callbackFunc 完成回调方法
	@return :
]]
function fuse( treasure_id,num, callbackFunc )
	local fragments = TreasureData.getTreasureFragments(treasure_id)
	local function requestFunc( cbFlag, dictData, bRet )
		if(dictData.ret == "true" or dictData.ret == true) then
			--修改消耗的碎片
			for k,v in pairs(fragments) do
				TreasureData.addFragment(v, -num)
			end
			if(callbackFunc ~= nil) then
				callbackFunc(true)
			end
		else
			callbackFunc(false)
      		return
		end
	end
	local args = CCArray:create()
	args:addObject(CCString:create(treasure_id))
	args:addObject(CCInteger:create(num))
	Network.rpc(requestFunc, "fragseize.fuse", "fragseize.fuse", args, true)
end

--[[
	@des 	:宝物抢夺
	@param 	:item_temple_id 要抢夺宝物碎片的模板id, uid 抢夺用户的uid , callbackFunc 完成回调方法: isSucccess：当传true时，才刷新ui，否者只让抢夺按钮可以点击
	@return :
]]
function seizeRicher(  uid, item_temple_id, callbackFunc )
	--判断背包
	if ( ItemUtil.isBagFull() ) then 
		callbackFunc(true)  
      return 
    end

    -- 判断武将是否已满
    require "script/ui/hero/HeroPublicUI"
    if HeroPublicUI.showHeroIsLimitedUI() then
    	callbackFunc(true)
      return
    end

    local robberData = TreasureData.getRobberList()
    local npc =0 

    -- 本次抢夺对手的阵容
    local curRobData
    for k, v in pairs(robberData) do
      if(tonumber(v.uid ) == tonumber(uid) ) then
        npc = v.npc
        curRobData = v
        break
      end
    end

	if(UserModel.getStaminaNumber() < tonumber(TreasureData.getEndurance()) ) then
      	--耐力不足提示面板
      	require "script/ui/item/StaminaAlertTip"
      	StaminaAlertTip.showTip( RobTreasureView.refreshUI )
      	callbackFunc(true)
      	return
    end

    local robFunc = function ( ... )

	    local robTable = {}
	    robTable.uid 		= uid
	    robTable.fragmentId = item_temple_id

		local function requestFunc( cbFlag, dictData, bRet )
			if(bRet == true) then
				local robberData = curRobData
				-- 刷新数据
				local function doMatchBattleOverDelegate(  )
					-- 刷新数据
					local reward= dictData.ret.reward
					UserModel.addSilverNumber(tonumber(reward.silver))
					UserModel.addExpValue(tonumber(reward.exp),"treasureservice")
					UserModel.addStaminaNumber(-(TreasureData.getEndurance()))
					-- require "script/ui/treasure/RobTreasureView"
					-- RobTreasureView.refreshBottomUI()
					if(string.lower(dictData.ret.appraisal) ~= "e" and string.lower(dictData.ret.appraisal) ~= "f"  and reward.fragNum ~= nil ) then
						TreasureData.addFragment(item_temple_id, 1)
					end
					-- 如果抽取的是抢夺或银币 加银币
					if(dictData.ret.card ~= nil)then
						for k,v in pairs(dictData.ret.card) do
							if(k == "real")then
								for i,j in pairs(v) do
									if(i == "rob")then
										UserModel.addSilverNumber(tonumber(j))
									elseif(i == "silver")then
										UserModel.addSilverNumber(tonumber(j))
									elseif(i == "soul")then
										UserModel.addSoulNum(tonumber(j))
									elseif(i == "gold")then
										UserModel.addGoldNumber(tonumber(j))
									end
								end
							end
						end
					end
					callbackFunc(true)
				end
				if(dictData.ret == "fail") then
					AnimationTip.showTip(GetLocalizeStringBy("key_2477"))
					callbackFunc(false)
				elseif(dictData.ret == "white") then
					AnimationTip.showTip(GetLocalizeStringBy("key_2086"))
					callbackFunc(false)
				else
					local battleResultLayer = nil
					local fragmentInfo = DB_Item_treasure_fragment.getDataById(item_temple_id)
					local fragmentName = nil
					if(string.lower(dictData.ret.appraisal) ~= "e" and string.lower(dictData.ret.appraisal) ~= "f"  and dictData.ret.reward.fragNum ~= nil ) then
						fragmentName = fragmentInfo.name
					end
					--如果新手引导 则 显示抢夺到宝物
					if(NewGuide.guideClass == ksGuideRobTreasure) then
	    				fragmentName = fragmentInfo.name
	    			end
					-- 创建战斗面版
					if(tonumber(robberData.npc) == 1) then
						--与npc 战斗
						require "script/ui/common/CafterBattleLayer"
						battleResultLayer = RobBattleResultView.createBattleResultLayer( robTable,fragmentName, dictData.ret.appraisal, nil, robberData.uname, nil, dictData.ret.fightFrc, dictData.ret.reward.silver, dictData.ret.reward.exp, dictData.ret.card, nil,dictData.ret.fightStr )
					else
						--玩家 战斗
						require "script/ui/common/CafterBattleLayer"
						battleResultLayer = RobBattleResultView.createBattleResultLayer( robTable,fragmentName, dictData.ret.appraisal, robberData.uid, robberData.uname, nil, dictData.ret.fightFrc, dictData.ret.reward.silver, dictData.ret.reward.exp, dictData.ret.card, nil, dictData.ret.fightStr )
					end

					require "script/battle/BattleLayer"
					BattleLayer.showBattleWithString(dictData.ret.fightStr, doMatchBattleOverDelegate,battleResultLayer, "ducheng.jpg",nil,nil,nil,nil,true)
				end
			else
				AnimationTip.showTip(GetLocalizeStringBy("key_3146"))
				callbackFunc(false)
				return
			end
		end

		-- addby chengliang
    	PreRequest.setIsCanShowAchieveTip(false)
    	
		local args = CCArray:create()
		args:addObject(CCInteger:create(uid))
		args:addObject(CCInteger:create(item_temple_id))
		args:addObject(CCInteger:create(npc))
		Network.rpc(requestFunc, "fragseize.seizeRicher", "fragseize.seizeRicher", args, true)
    end


    --是否处于免战状态
    print("TreasureData.isShieldState() =", TreasureData.isShieldState() )
    print("tonumber(npc) = ", tonumber(npc))
    if(TreasureData.isShieldState() and tonumber(npc) == 0) then
    	local buttonFunc = function ( isConfirm )
    		if(isConfirm == false) then
				callbackFunc(true)
				return
			else
				--清除免战状态
				TreasureData.clearShieldTime()
				robFunc()
			end
    	end
    	local closeFunc  = function ( ... )
    		callbackFunc(true)
			return
    	end
    	require "script/ui/tip/AlertTip"
	    AlertTip.showAlert(GetLocalizeStringBy("key_2872"), buttonFunc, true, nil,nil,nil,closeFunc)
	else
		robFunc()
	end
end

--[[
	@des 	:被别人抢夺通知
	@param 	:item_temple_id 要抢夺宝物碎片的模板id, uid 抢夺用户的uid , callbackFunc 完成回调方法
	@return :
]]
function registerPushSeize( callback )
	local callback = function ( callbackFlag, dictReciveData, bSucceed )
		if (bSucceed == true) then

			TreasureData.addFragment(tostring(dictReciveData.ret.fragId), 0 - tonumber(dictReciveData.ret.fragNum))
			if(callback ~= nil) then
				callback()
			end
		end
	end
	Network.re_rpc(requestCallback, "push.fragseize.seize", "push.fragseize.seize")
end

--[[
	@des 	:花费金币或物品 获得免战时间
	@param 	:  int $type 1:金币免战 2:物品免战 ;callbackFunc 完成回调方法
	@return :
]]

function whiteFlag( freeType, callbackFunc)

	if(tonumber(freeType) ==1) then
		if(UserModel.getGoldNumber()< tonumber(TreasureData.getGlodByShieldTime())) then
			--AnimationTip.showTip(GetLocalizeStringBy("key_2464"))
			require "script/ui/tip/LackGoldTip"
			LackGoldTip.showTip()
			return
		end
	elseif(tonumber(freeType) ==2) then
		local itemTable = TreasureData.getShieldItemInfo()
		local itemInfo = ItemUtil.getCacheItemInfoBy(tonumber(itemTable[1].itemTid))
		if(itemInfo== nil or tonumber(itemInfo.item_num)< tonumber(itemTable[1].num) ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1387"))
			return 
		end
	end

	local function requestCallback( cbFlag, dictData, bRet )
		if(bRet == true) then

			--修改消耗的碎片
			if(freeType == 1 ) then
				print("============= ========== ====== =======  ====   === reasureData.getGlodByShieldTime() ", TreasureData.getGlodByShieldTime())
				UserModel.addGoldNumber(-tonumber(TreasureData.getGlodByShieldTime()))
			end

			require "script/ui/tip/AlertTip"
		    require "script/utils/TimeUtil"
		    if(TreasureData.isShieldState()) then
		        local message = GetLocalizeStringBy("key_2911") .. TreasureData.getUsingShieldAddTime()..GetLocalizeStringBy("key_2230")
		        AnimationTip.showTip(message)
		    else
		        local message = GetLocalizeStringBy("key_1239") .. TreasureData.getUsingShieldAddTime()..GetLocalizeStringBy("key_2230")
		        AnimationTip.showTip(message)
		    end
		    TreasureData.addShieldTime()
		    if(callbackFunc ~= nil) then
				callbackFunc(true)
			end
		end
	end

	local function requestFunc( ... )
		local args = CCArray:create()
		args:addObject(CCInteger:create(freeType))
		Network.rpc(requestCallback, "fragseize.whiteFlag", "fragseize.whiteFlag", args, true)
	end

	local preRequest = function ( ... )
		require "db/DB_Loot"
		require "db/DB_Item_treasure"
		local lootInfo 		= DB_Loot.getDataById(1)
		if(TreasureData.getHaveShieldTime() +  tonumber(lootInfo.shieldTime) > tonumber(lootInfo.shieldTimeLimit)) then
			require "script/ui/tip/AlertTip"
	        AlertTip.showAlert(GetLocalizeStringBy("key_2743") ..TreasureData.getUsingShieldAddTime() .. GetLocalizeStringBy("key_1654") , function ( isConfirm)
	            if(isConfirm == false) then
	                return
	            else
	                requestFunc()
	            end
	        end, true)
		else
			requestFunc()
		end
	end

	if(TreasureData.isGlobalShieldState()) then
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert(GetLocalizeStringBy("key_2623"), function ( isConfirm)
            if(isConfirm == false) then
                return
            else
                preRequest()
            end
        end, true)
    else
        preRequest()
    end
end



-- /**
-- *一键夺宝
-- *@param int uid
-- *@param int tid
-- *@param bool isNpc
-- *@param int times 抢夺cis
-- *@return
-- *'seize' => array
-- *{
-- *		times:
-- *		{
-- * 		'reward'	=> array
-- * 						{
-- * 							'exp' => int,
-- * 							'silver' => int,
-- * 							'fragNum' => int,
-- * 						},
-- *		'status' = success 0,lose 1,fail 2,
-- *		}
-- *	}
-- *'card'	=> array
-- *{
-- *	{		
-- *			'silver' => $num		银币，数量
-- *			'item':
-- *			{
-- *				'id':int			物品id
-- *				'num':int			数量
-- *			}
-- *			'hero':
-- *			{
-- *				'id':int			武将id
-- *				'num':int			数量
-- *			}
-- *	}
-- *}
-- **/
--[[
function quickSeize(  p_uid, p_tid, p_times, p_callbackFunc )
	
	local requestFunc = function( cbFlag, dictData, bRet )
		p_callbackFunc(dictData)
	end
	local args = CCArray:create()	
	args:addObject(CCInteger:create(p_uid))
	args:addObject(CCInteger:create(p_tid))
	args:addObject(CCInteger:create(p_times))
	Network.rpc(requestFunc, "fragseize.quickSeize", "fragseize.quickSeize", args, true)
end
--]]

function quickSeize(  p_uid, p_tid, p_times, p_callbackFunc )
	
	local requestFunc = function( cbFlag, dictData, bRet )
		require "script/ui/treasure/QuickRobData"
		--存下欲获取的碎片
	    QuickRobData.setItemid(p_tid)

	    if(dictData.ret == "fail" )then
	        --提示战斗失败，让用户返回检查是否有此碎片
	        --后端规则为：如果已经有了这个碎片，再抢夺，会返回fail
	        --在个活动中，有一个概率非常非常非常非常非常小的事件，抢夺的时候没有抢到想要的碎片，但是翻牌的时候翻到了，所以加这一层判断
	        AnimationTip.showTip(GetLocalizeStringBy("djn_7"))
	        p_callbackFunc(false)
	        return
	     end
	    if(dictData.ret ~= nil) then
	        local donum = tonumber(dictData.ret.donum)
	        --消耗一下耐力
	        UserModel.addStaminaNumber(-(donum*2)) 
	        --设置网络数据
	        QuickRobData.setQuickRobData(dictData)
	        --更新获得的reward中得银币
	        QuickRobData.UpdateSilverInReward(dictData.ret) 
	        p_callbackFunc(true)
	        return    
	    else
		    --提示战斗出错
		    AnimationTip.showTip(GetLocalizeStringBy("lic_1014"))
		    p_callbackFunc(false)
	        return
	    end
		
	end
	local args = CCArray:create()	
	args:addObject(CCInteger:create(p_uid))
	args:addObject(CCInteger:create(p_tid))
	args:addObject(CCInteger:create(p_times))
	Network.rpc(requestFunc, "fragseize.quickSeize", "fragseize.quickSeize", args, true)
end




