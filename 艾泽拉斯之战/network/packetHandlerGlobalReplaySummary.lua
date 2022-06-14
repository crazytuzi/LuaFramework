function GlobalReplaySummaryHandler( battleType, progressID, name, icon )
		 	global.GlobalReplaySummaryInfo.battleType = battleType
			global.GlobalReplaySummaryInfo.progressID = progressID
			global.GlobalReplaySummaryInfo.name = name
			global.GlobalReplaySummaryInfo.icon = icon
			eventManager.dispatchEvent({name = global_event.RECEIVE_BEST_BATTLE_RECORD})
end
