-- Filename：	GiftService.lua
-- Author：		lichenyang
-- Date：		2013-8-22
-- Purpose：		礼包网络



module ("GiftService", package.seeall)

local fnBuyVipGiftDelegate= nil

-- 购买VIP礼包
function buyVipGift( vipLevel, callbackFunc )
	require "script/model/user/UserModel"
	if(UserModel.getVipLevel() < vipLevel) then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_2704"))
		return
	end

	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
			setVipGiftPurchased(vipLevel)

			callbackFunc()

			-- 刷新礼包按钮的提示按钮 added by zhz
			-- require "script/ui/shop/ShopLayer"
			require "script/ui/main/MenuLayer"
			-- ShopLayer.refreshTipSprite()
			MenuLayer.refreshMenuItemTipSprite()
			if(fnBuyVipGiftDelegate ~= nil)then
                fnBuyVipGiftDelegate()
            end

		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(vipLevel))
	Network.rpc(requestFunc, "shop.buyVipGift", "shop.buyVipGift", args, true)
end

--设置礼包已购买
function setVipGiftPurchased( vipLevel )
	print("setVipGiftPurchased", vipLevel)
	require "script/model/DataCache"
	DataCache.setBuyedVipGift(vipLevel+1)
end

function regirsterBuyVipGiftCb( callbackFunc)
	fnBuyVipGiftDelegate = callbackFunc
end

