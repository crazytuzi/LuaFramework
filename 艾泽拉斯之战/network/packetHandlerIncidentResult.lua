function IncidentResultHandler( incidentIndex, eventID )
	
	print("IncidentResultHandler index "..incidentIndex.." eventID "..eventID);
	dataManager.mainBase:handleIncident(incidentIndex, eventID);
	
end
