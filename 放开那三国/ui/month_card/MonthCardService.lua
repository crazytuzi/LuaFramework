-- Filename：	MonthCardService.lua
-- Author：		zhz
-- Date：		2013-6-13
-- Purpose：		月卡功能的网络层

module("MonthCardService", package.seeall)

require "script/ui/month_card/MonthCardData"
require "script/ui/tip/AnimationTip"
require "script/ui/hero/HeroPublicUI"
require "script/ui/item/ItemUtil"
     --  * @return array  如果玩家没有买过月卡  返回空array
     -- * <code>
     -- * [
     -- * 		1=>array	月卡1的信息
     -- * 		[
     -- *     		uid:Int
     -- *     		card_id:int
     -- *     		buy_time:int
     -- *     		due_time:int
     -- *     		va_card_info:array
     -- *     		[
     -- *         		monthly_card:array
     -- *         		[
     -- *             		reward_time:int   //领取每天奖励的时间
     -- *             		gift_status:int   //大礼包状态  1:没有大礼包  2:有大礼包，并且没有领取  3:已经领取了大礼包
     -- *         		]
     -- *     		] 
     -- *     		charge_gold:int
     -- *		] 
     -- *		2=>array	月卡2的信息
     -- * 		[
     -- *     		uid:Int
     -- *     		card_id:int
     -- *     		buy_time:int
     -- *     		due_time:int
     -- *     		va_card_info:array
     -- *     		[
     -- *         		monthly_card:array
     -- *         		[
     -- *             		reward_time:int   //领取每天奖励的时间
     -- *             		gift_status:int   //大礼包状态  1:没有大礼包  2:有大礼包，并且没有领取  3:已经领取了大礼包
     -- *         		]
     -- *     		]
     -- *     		charge_gold:int
     -- *		]  
     -- *      3 =>array
     -- *      [
     -- *		gift_status:int
     -- *]
     -- * ]
     -- * </code>
     -- */


-- 得到活动卡包的信息
function getCardInfo( callbackFunc )

	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
			MonthCardData.setCardInfo(dictData.ret )
			if(callbackFunc ~= nil) then
				callbackFunc()
			end
		end
	end
	
	local args = CCArray:create()
	Network.rpc(requestFunc, "monthlycard.getCardInfo", "monthlycard.getCardInfo", nil, true)
end


 -- /**
 --     * 领取每日奖励
 --     * 
 --     * @param int $cardId 月卡id     public function getDailyReward($cardId);

 --     * @return string 'ok'
 --     */

function getDailyReward( pCardId,callbackFunc )
	if(MonthCardData.isMonthCardEffect(pCardId) == false ) then
		AnimationTip.showTip(GetLocalizeStringBy("key_4021"))
		return
	end

	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(callbackFunc ~= nil) then
				callbackFunc()
			end
		end
	end

	local items= MonthCardData.getCardReward(pCardId)

	local hasHero= false
	local hasItem= false

	-- 判断是否有hero
	for i=1, #items do
		if(items[i].type== "hero" ) then
			hasHero=true
			break
		end
	end

	-- 判断是否有item
	for i=1, #items do
		if(items[i].type== "item" ) then
			hasItem=true
			break
		end
	end

	if( hasHero and HeroPublicUI.showHeroIsLimitedUI() ) then

	elseif( hasItem and ItemUtil.isBagFull() )then

	else
		local args = CCArray:create()
		args:addObject(CCInteger:create(pCardId))
		Network.rpc(requestFunc, "monthlycard.getDailyReward", "monthlycard.getDailyReward", args, true)
		
	end

	
end

  -- /**
  --    * 领取大礼包
  --    * 
  --    * @param int $cardId 月卡id  
  --    * @return string 'ok'
  --    */

function getGift(callbackFunc )
	--当还不能领取大礼包时
	if(MonthCardData.getGiftStatus() == 1)then
		AnimationTip.showTip(GetLocalizeStringBy("fqq_081"))
		return
	end
	if(MonthCardData.getGiftStatus() == 3 ) then
		AnimationTip.showTip(GetLocalizeStringBy("fqq_080"))
		return
	end

	
	local function requestFunc( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			if(callbackFunc ~= nil) then
				MonthCardData.setGiftStatus()
				callbackFunc()
			end
		end
	end


	local items= MonthCardData.getFirstReward()

	local hasHero= false
	local hasItem= false

	-- 判断是否有hero
	for i=1, #items do
		if(items[i].type== "hero" ) then
			hasHero=true
			break
		end
	end

	-- 判断是否有item
	for i=1, #items do
		if(items[i].type== "item" ) then
			hasItem=true
			break
		end
	end

	if( hasHero and HeroPublicUI.showHeroIsLimitedUI() ) then

	elseif( hasItem and ItemUtil.isBagFull() )then

	else
		local args = CCArray:create()
		Network.rpc(requestFunc, "monthlycard.getGift", "monthlycard.getGift", nil, true)
	end
end

    -- /**
    --  * 购买月卡
    --  * 
    --  * @param int $cardId 月卡id
    --  * @return array
    --  * <code>
    --  * [
    --  *     uid:Int
    --  *     card_id:int
    --  *     buy_time:int
    --  *     due_time:int
    --  *     va_card_info:array
    --  *     [
    --  *         monthly_card:array
    --  *         [
    --  *             reward_time:int   //领取每天奖励的时间
    --  *             gift_status:int   //大礼包状态  1:没有大礼包  2:有大礼包，并且没有领取  3:已经领取了大礼包
    --  *         ]
    --  *     ]  
    --  * ]     
    --  * </code>
    --  */

function buyMonthCard( pCardId,callbackFunc )
	
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(callbackFunc ~= nil) then
				callbackFunc()
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(pCardId))
	Network.rpc(requestFunc, "monthlycard.buyMonthlyCard", "monthlycard.buyMonthlyCard", args, true)
end



