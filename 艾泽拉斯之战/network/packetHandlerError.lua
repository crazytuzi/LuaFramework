function ErrorHandler( responseID, code )
	print("errorHandler responseID: "..responseID.." code "..code);
	
	
	if(code == enum.ERROR_CODE.ERROR_INVALID_NAME)then
		if(game.isLoginStates())then
				sendCreateRole(1,global.randomPlayerName(true))
		end
	elseif(code == enum.ERROR_CODE.ERROR_DUPLICATE_NAME)then
		if(game.isLoginStates())then
				sendCreateRole(1,global.randomPlayerName(true))
		end
	
	elseif code == enum.ERROR_CODE.ERROR_CANDIDATE_RANK_NO_DATA then
		
		dataManager.pvpData:refreshNewPlayer(true);
	
	elseif code == enum.ERROR_CODE.ERROR_CODE_IDOL_RES_NOT_ENOUGH then
		
		eventManager.dispatchEvent({name = global_event.IDOLSTATUSLEVELUP_UPDATE})
	 	eventManager.dispatchEvent({name = global_event.IDOLSTATUS_UPDATE})
	 	
	elseif code == enum.ERROR_CODE.ERROR_FRIEND_REJECT_TWICE then	
		dataManager.buddyData:onReject()	
	elseif code == enum.ERROR_CODE.ERROR_BATTLE_FRIEND_NOT_IN_LADDER then	
		dataManager.buddyData:setAskPkPlayerDetail(false )
	end 
 


	-- 有些错误提示要屏蔽掉 九 零  一 起 玩 ww w .9 0 1  7 5. com
	if code ~= enum.ERROR_CODE.ERROR_CAST_MAGIC_IN_PREPARE and 
		code ~= enum.ERROR_CODE.ERROR_BATTLE_NOT_PREPARE and
		code ~= enum.ERROR_CODE.ERROR_BATTLE_IN_BATTLE then
		
 		eventManager.dispatchEvent({name = global_event.TIP_INFO_SHOW,tip = enum.ERROR_CODE_STRING[code]});
	
	end
	
end
