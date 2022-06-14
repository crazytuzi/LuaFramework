function SyncPrimalHandler( __optional_flag__primals,  primals )
	
	--dump(primals);
	
	for i=1, 4 do
		
		if __optional_flag__primals:isSetbit(i-1) then
			dataManager.idolBuildData:setPrimalItemCount(i-1, primals[i]);
		end
		
	end

	eventManager.dispatchEvent({name = global_event.IDOLSTATUSLEVELUP_UPDATE})
	eventManager.dispatchEvent({name = global_event.IDOLSTATUS_UPDATE})
end
