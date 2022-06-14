function FriendRejectHandler( targetID )
		dataManager.buddyData:delFriendApplicants(targetID)
		dataManager.buddyData:delRecommandBuddyApply(targetID)
		eventManager.dispatchEvent({name = global_event.SOCIALNETWORK_UPDATE})
		eventManager.dispatchEvent({name = global_event.FRIEND_UPDATE})	
end
