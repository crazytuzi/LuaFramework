-- FileName: GodShopService.lua 
-- Author: DJN
-- Date: 14-12-20 
-- Purpose: 神兵商店后端 


module("GodShopService", package.seeall)
require "script/ui/shopall/godShop/GodShopData"
require "script/ui/item/ItemUtil"
require "script/ui/item/ReceiveReward"
--商店信息
function getShopInfo( callbackFunc,pArgs )
	-- body
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			local dataRet = dictData.ret
			-- print("商店信息")
			-- print_t(dataRet)
			GodShopData.setShopInfo(dataRet)
			-- 回调
			if(callbackFunc)then
				callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "pass.getShopInfo", "pass.getShopInfo", nil, true)
end
--兑换
function buyGoods( p_param,callbackFunc )
	-- body
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			local dataRet = dictData.ret.ret
            print(dataRet)
			if(dataRet == "ok")then
				----扣消耗
				GodShopData.updateCost(p_param)
				----加次数
				----扣数量
				GodShopData.changeGoodList(p_param,-1)
				local goods = GodShopData.getRewardInDb(p_param)
				ItemUtil.addRewardByTable(goods) ---发奖
				require "script/ui/shopall/godShop/GodShopAlertCost"
				if(callbackFunc)then
					callbackFunc()
				end
	            ReceiveReward.showRewardWindow(goods,nil,GodShopAlertCost.getZorder()+10,-650)  --奖励弹窗
        	end	
		end
	end
	local arg = CCArray:create()
	arg:addObject(CCInteger:create(p_param))
	Network.rpc(requestFunc, "pass.buyGoods", "pass.buyGoods", arg, true)
end
--刷新
--callbackFunc：结束后回调函数  p_goldCost：结束后要扣的金币数 p_param：是否是系统自动刷新 （true：是系统自动刷新 false：不是系统自动刷新）
function refreshShopInfo( callbackFunc,p_goldCost,p_param )
	-- body
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			local dataRet = dictData.ret
			--扣金币
			UserModel.addGoldNumber(p_goldCost)
			-- print("刷新后的商店信息")
			-- print_t(dataRet)
			GodShopData.setShopInfo(dataRet)
			--GodShopLayer.createUI()
			-- 回调
			if(callbackFunc)then
				callbackFunc()
			end
		end
	end
	local arg = CCArray:create()
	if(p_param == true)then
		--与后端约定 如果是系统免费刷新，传参数1，如果是花金币刷新，传0。
		arg:addObject(CCInteger:create(1))
	else
		arg:addObject(CCInteger:create(0))
	end
	Network.rpc(requestFunc, "pass.refreshGoodsList", "pass.refreshGoodsList", arg, true)
end
