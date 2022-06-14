 
-- wangzhen create  05.30.2014 @beijing

objectManager   = {}
 
--玩家自己的军团
objectManager.selfCrops = {}

--敌对的 玩家或者怪物
objectManager.warringCrops = {}

local cropsUnitClass = include("cropsUnit")

function objectManager.CreateCrops(actor,skill,uiActor)
		return cropsobjClass.new(actor,skill,uiActor)		
end

function objectManager.addCrops(actorObject,toself)
		
	objectManager.delCrops(actorObject,toself)		 
	table.insert(t,actorObject)		
end

function objectManager.delCrops(actorObject,delFromSelf)
		
	local t = nil
	if(delFromSelf)then	
		t = objectManager.selfCrops	
	else
		t = objectManager.warringCrops
	end			
	table.removeWithValue(t,actorObject)			
end

function objectManager.hasCrops(actorObject,self)
	local t = nil
	if(self)then	
		t = objectManager.selfCrops	
	else
		t = objectManager.warringCrops
	end		
	return  table.find(t, actorObject)	
end

function objectManager.CreateCropsUnit(actor,skill,uiActor, createdActor)
		return cropsUnitClass.new(actor,skill,uiActor, createdActor)		
end

function objectManager.CreateKing(actor,skill,uiActor)
		return kingClass.new(actor,skill,uiActor)		
end



function objectManager.CreateMainActor(actor,skill,uiActor)
	local actorManager = LORD.ActorManager:Instance()
	skill = skill or "idle"
	uiActor = uiActor or false   
	actor  = actor
	return actorManager:CreateActor(actor, skill, uiActor)	 	
end


function objectManager.CreateMainActor2(actor,bSingleThread,skill,uiActor)
	local actorManager = LORD.ActorManager:Instance()
	skill = skill or "idle"
	uiActor = uiActor or false   
	actor  = actor
	local AnUserData = 0
	bSingleThread = bSingleThread or false
	return actorManager:CreateActor(actor, skill,AnUserData, uiActor,false,bSingleThread,false)	 	
end