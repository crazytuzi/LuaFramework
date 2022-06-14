 
local attCollection = class("attCollectionClass")
attCollection.debug_ = false
function attCollection:ctor()
	self.att = {}
end 

function attCollection:setAttr(key,value)
	     assert( key ~= nil,
        "attCollection:setAttr() - invalid key")
			
	self.att[key]  = value
	if(attCollection.debug_ )then
		 echoInfo("attCollection:setAttr() key: [%s] value: %s", key, value)        
	end	
end 
function attCollection:getAttr(key)
	
	 assert( key ~= nil,
        "attCollection:getAttr() - invalid key")
		
	if(attCollection.debug_ )then
		 echoInfo("attCollection:getAttr() key: [%s] value: %s", key, self.att[key])        
	end	
	return self.att[key]
end 	

function attCollection:dump()
	for k,v in pairs (self.att) do	
		 echoInfo("key: [%s]  value: %s", k, v)        
	end		
end	
 
return attCollection