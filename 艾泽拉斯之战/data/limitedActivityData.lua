limitedActivityData = class("limitedActivityData")

function limitedActivityData:ctor()
	
	self.limitdActivityTab = {};
	
end

function limitedActivityData:destroy()

end

function limitedActivityData:getTabData()

	return self.limitdActivityTab;

end

function limitedActivityData:hasNotifyPoint()
	
	for k,v in pairs(self.limitdActivityTab) do
		if v:hasNotifyPoint() then
			return true;
		end
	end
	
	return false;
end

function limitedActivityData:shouldShow()
	
	for k,v in pairs(self.limitdActivityTab) do
		if v:shouldShow() then
			return true;
		end
	end
	
	return false;
end

function limitedActivityData:init()

	-- 从表格初始化所有的数据
	for k,v in pairs(dataConfig.configs.limitActivityContentConfig) do
		
		local tabInfo = limitedActivityTab.new();
		tabInfo:setConfigInfo(v);
		tabInfo:initChildActivity();
		
		table.insert(self.limitdActivityTab, tabInfo);
		
	end
	
	-- sort
	function limitedTabCompare(a, b)
		
		return a:getDrawOrder() < b:getDrawOrder();
	end
	
	table.sort(self.limitdActivityTab, limitedTabCompare);
	
end

function limitedActivityData:getActivityByID(id)
	
	for k,v in pairs(self.limitdActivityTab) do
		
		local instance = v:getActivityByID(id);
		if instance then
			return instance;
		end
	end
	
end
