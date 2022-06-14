function SyncIncidentHandler( __optional_flag__infos,  infos)

	for i=1, 6 do
		if __optional_flag__infos:isSetbit(i-1) then
			local incidentInfo = infos[i];
			print("SyncIncidentHandler index: "..(i-1).." eventID "..incidentInfo.eventID.." position "..incidentInfo.position.." nextTime "..incidentInfo.nextTime:GetUInt());
			
			dataManager.mainBase:setIncidentInfo(i, incidentInfo);
		end
	end
		
	eventManager.dispatchEvent({name = global_event.INSTANCEINFOR_UPDATE_INCIDENT_INFO});	
end
