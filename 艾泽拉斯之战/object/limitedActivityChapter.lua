limitedActivityChapter = class("limitedActivityChapter", limitedActivityBase);

function limitedActivityChapter:isTaskComplete()
	
	local zones = dataManager.instanceZonesData	
	local chapter = zones:getAllChapter()[self.config.params[1]]
	
	local adventureType = -1;
	
	if(self.config.params[2] == enum.ADVENTURE.ADVENTURE_ELITE ) then
		adventureType = enum.Adventure_TYPE.ELITE;
	elseif(self.config.params[2] == enum.ADVENTURE.ADVENTURE_NORMAL ) then	
		adventureType = enum.Adventure_TYPE.NORMAL;
	end
		
	local num ,all = chapter:getPerfectProcess(adventureType)
	
	return num == all;
end

function limitedActivityChapter:onClickGoto()
	
	local zones = dataManager.instanceZonesData	
	local chapter = zones:getAllChapter()[self.config.params[1]]

	local adventureType = -1;
	
	if(self.config.params[2] == enum.ADVENTURE.ADVENTURE_ELITE ) then
		adventureType = enum.Adventure_TYPE.ELITE;
	elseif(self.config.params[2] == enum.ADVENTURE.ADVENTURE_NORMAL ) then	
		adventureType = enum.Adventure_TYPE.NORMAL;
	end
	
	local stage = chapter:getFirstNotFullStarStage(adventureType);
	
	if not stage then
		return
	end
	
	if( not stage:isEnable())then
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
			messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
			textInfo = "关卡未开启" });
		return;
	end
	
	eventManager.dispatchEvent({name = global_event.ACTIVITYS_HIDE});
	eventManager.dispatchEvent({name = global_event.INSTANCECHOICE_SHOW, stage = stage});
	
end


