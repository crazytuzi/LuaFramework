function NotifyShakeCountHandler( addShakeCount )
		 dataManager.redEnvelopeData:setAddShakeCount(addShakeCount)
		 eventManager.dispatchEvent({name = global_event.REDENVELOPE_UPDATE})
end
