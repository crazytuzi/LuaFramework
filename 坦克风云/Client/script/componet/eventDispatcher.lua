eventDispatcher=
{
	eventTb={}
}

function eventDispatcher:addEventListener(event,listener)
	print("add event listener:",event,listener)
	if(listener==nil)then
		do return end
	end
	if(self.eventTb[event]==nil)then
		self.eventTb[event]={}
	end
    local flag=false
    for k,v in pairs(self.eventTb[event]) do
    	if(v==listener)then
    		flag=true
    		break
    	end
    end
    if(flag==false)then
    	table.insert(self.eventTb[event],listener)
    end
end

function eventDispatcher:removeEventListener(event,listener)
	print("remove event listener:",event,listener)
	if(listener==nil or self.eventTb[event]==nil)then
		do return end
	end
	local length=#self.eventTb[event]
	for i=1,length do
		if(self.eventTb[event][i]==listener)then
			table.remove(self.eventTb[event],i)
			i=i-1
		end
	end
end

function eventDispatcher:dispatchEvent(event,data)
	print("dispatch event:",event)
	if(self.eventTb[event])then
		for k,v in pairs(self.eventTb[event]) do
			print("listener:",v)
			if(v)then
				v(event,data)
			end
		end
	end
end

function eventDispatcher:hasEventHandler(event,listener)
	if(self.eventTb[event]==nil)then
		return false
	end
	if(listener==nil)then
		if(self.eventTb[event] and #self.eventTb[event]>0)then
			return true
		else
			return false
		end
	end
	for k,v in pairs(self.eventTb[event]) do
		if(v==listener)then
			return true
		end
	end
	return false
end

function eventDispatcher:clear()
	self.eventTb={}
end