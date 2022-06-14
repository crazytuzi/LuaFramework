include(dataAtt)
local AttCollection = class("AttCollection")
AttCollection.debug_ = false
function AttCollection:ctor()
	self.att = {}
end 

function AttCollection:setAttr(key,value)
	     assert( key ~= nil,
        "DataBaseClass:setAttr() - invalid key")
			
	self.att[key]  = value
	if(AttCollection.debug_ )then
		 echoInfo("AttCollection:setAttr() key: [%s] value: %s", key, value)        
	end	
end 
function AttCollection:getAttr(key)
	
	 assert( key ~= nil,
        "AttCollection:getAttr() - invalid key")
		
	if(AttCollection.debug_ )then
		 echoInfo("AttCollection:getAttr() key: [%s] value: %s", key, self.att[key])        
	end	
	return self.att[key]
end 	

function AttCollection:dump()
	for k,v in pairs (self.att) do	
		 echoInfo("key: [%s]  value: %s", k, v)        
	end		
end	
 
return AttCollection