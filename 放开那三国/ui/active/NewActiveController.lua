module ("NewActiveController", package.seeall)

require "script/ui/active/NewActiveData"

function getInfo()
	-- body
	local getNewActiveInfoCallbck = function (  cbFlag, dictData, bRet  )
		-- body
		NewActiveData.dealData(dictData.ret)
		NewActiveLayer.createDesUI()
		NewActiveLayer.createTableView()
	end
	NewActiveService.getDesactInfo(getNewActiveInfoCallbck)
end

function getReward( pIndex )
	-- body
	local getRewardBack = function ( cbFlag, dictData, bRet )
		-- body
		require "script/ui/item/ReceiveReward"
		local data = NewActiveData.getData()
		local reward = ItemUtil.getServiceReward(data.config.reward[pIndex+1].reward)
		for i=1,table.count(reward) do
			if(reward[i].type=="silver")then
				UserModel.addSilverNumber(tonumber(reward[i].num))
				break
			elseif(reward[i].type=="gold")then
				UserModel.addGoldNumber(tonumber(reward[i].num))
				break
			end
		end
		NewActiveData.changeDataStatus(tonumber(pIndex)+1)
		local freshAction = function ( ... )
			-- body
			NewActiveLayer.freshTableView()
		end
		ReceiveReward.showRewardWindow( reward, freshAction , 100, -500 )
	end
	NewActiveService.gainReward( pIndex,getRewardBack )
end