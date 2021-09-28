-- FileName: SevenLotteryController.lua 
-- Author: llp
-- Date: 16-8-3
-- Purpose: function description of module 

module ("SevenLotteryController", package.seeall)
require "script/ui/sevenlottery/SevenLotteryServices"
function getInfo( pCallBack )
	local requestCallback = function( pRetData )
		require "script/ui/sevenlottery/SevenLotteryData"
		SevenLotteryData.setData(pRetData)
	    if(pCallBack)then
	    	pCallBack(pRetData)
	    end
	end
	SevenLotteryServices.getInfo(requestCallback)
end

function lottery( pCallBack,pType )
	local requestCallback = function( pRetData )
	    if(pCallBack)then
	    	if(pType==2)then
	    		require "db/DB_Sevenstar_altar"
	    		require "script/ui/sevenlottery/SevenLotteryData"
	    		local data = SevenLotteryData.getData()
				local dbData = DB_Sevenstar_altar.getDataById(data.curr_id)
				local num = tonumber(dbData.cost_once)
	    		UserModel.addGoldNumber(-num)
	    	end
	    	pCallBack(pRetData)
	    end
	end
	SevenLotteryServices.lottery(requestCallback,pType)
end