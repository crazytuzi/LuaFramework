function SuccessHandler( responseID,code )
 
		if(enum.SUCCESS_CODE.SUCCESS_SYSTEM_REWARD_CHAPTER  == code)then
			eventManager.dispatchEvent({name = global_event.SUCCESS_SYSTEM_REWARD_CHAPTER})
		elseif enum.SUCCESS_CODE.SUCCESS_FRIEND_REJECT == code or enum.SUCCESS_CODE.SUCCESS_FRIEND_DELETE  == code  then
			dataManager.buddyData:OnSuccess(code)
		elseif enum.SUCCESS_CODE.SUCCESS_AGIOTAGE_GOLD == code then
		elseif enum.SUCCESS_CODE.SUCCESS_AGIOTAGE_LUMBER == code then
		
		elseif enum.SUCCESS_CODE.SUCCESS_FRIEND_PRESENTED == code then
			eventManager.dispatchEvent({name = global_event.WARNINGHINT_SHOW,tip = "^FFFC0B体力赠送成功"})
		end
		
		
	 
	 
	 if responseID == enum.PACKET_ID.UPGRADE_IDOL then
	 
	 	homeland.notifyIdolLevelupOK();
	 	eventManager.dispatchEvent({name = global_event.IDOLSTATUSLEVELUP_UPDATE})
	 	eventManager.dispatchEvent({name = global_event.IDOLSTATUS_UPDATE})
	 
	 elseif responseID == enum.PACKET_ID.UPGRADE_MIRACLE then
	 
	 	homeland.notifyMiracleLevelupOK();
	 	eventManager.dispatchEvent({name = global_event.MIRACLE_UPDATE});
	 	
	 end
	 
	
	
	
	
end
