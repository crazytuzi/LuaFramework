--wz
layout = class("layout")


function layout:ctor( id )
	
	assert(dataConfig.configs.uiConfig[id] ~= nil,
        "layout:ctor() - invalid id"..id)
		
	self._config = 	dataConfig.configs.uiConfig[id]
	self._view = nil
	self._loaded = false
	self._show = false
	
	self.rootWindowName = "";
	
	if(self._config.preload == true)then
	  self:preLoad()
	end	
	
	self._event = {}
	
	self._saveConfig = {};
	
	self._initKeys = {};
end	

function layout:saveInitKeys()
	
	local keys = {};
	
	for k,v in pairs(self) do
		--table.insert(keys, k);
		
		keys[k] = true;
	end
	
	--dump(keys);
	
	self._initKeys = keys;
end

function layout:clearKeys()

	-----------------------------------------------
	local keys = {};
	
	for k,v in pairs(self) do
		print(type(v));
		table.insert(keys, k);
	end
	
	print("beforekeys");
	dump(keys);
	-----------------------line-------------------------
	local deleteKeys = {};
	
	for k,v in pairs(self) do
		--if self._initKeys[k] ~= true and (type(v) == "userdata" or type(v) == "table")then
		if self._initKeys[k] ~= true then
			table.insert(deleteKeys, k);
		end 
	end

	for k, v in pairs(deleteKeys) do
		self[v] = nil;
	end
	
	-----------------------line--------------------------
	keys = {};
	
	for k,v in pairs(self) do
		table.insert(keys, k);
	end
	
	print("afterkeys");
	dump(keys);
		
end

function layout:setSaveConfig(data)
	--dump(data);
	self._saveConfig = data;
end

function layout:getSaveConfig()
	--dump(self._saveConfig);
	return self._saveConfig;
end

function layout:preLoad()
    self._view = engine.LoadWindowFromXML(self._config.xml)
	assert(self._view ~= nil,
        "layout:preLoad() - invalid ui xml"..self._config.xml)
	self._loaded = true
	
	self.rootWindowName = self._view:GetName();
	
end	
 
function layout:isLoaded()
	return self._loaded;
end

function layout:Load()	
	if(self._loaded)then  return end
    self._view = engine.LoadWindowFromXML(self._config.xml)
	assert(self._view ~= nil,
        "layout:Load() - invalid ui xml"..self._config.xml)
	self._loaded = true
	self.rootWindowName = self._view:GetName();		
end	

function layout:getRootWindowName()
	return self.rootWindowName;
end

function layout:Unload()
    if(self._loaded and self._view ~= nil) then	
			layoutManager.Unload(self);
			self._view = nil;
    end

    self._loaded = false;
end

function layout:addEvent(event )
    self._event[event.name] = event
end
function layout:GetEvent()
	 return self._event
end


function layout:RegiserEvent()
	 for k,v in pairs (self._event) do 			
		eventManager.addEventLister(k,self.onEvent,self)
	 end
end

function layout:onEvent(event)

	local beforeView = self._view;
	
     if(nil == self._event[event.name]) then
        echoInfo("layout:onEvent event.name %s not find",event.name)
     end
     local eventHandler = self._event[event.name].eventHandler
     if(eventHandler) then
           eventHandler(self,event)
     end
     
  -- 如果开始有view，结束没有，就是释放了，清理所有的table
  if beforeView ~= nil and self._view == nil then
		self:clearKeys();
  end
  
  -- check vip block
  if self._show then
  	global.checkBlockVIP();
  end
  
end
function layout:isShow()
	return self._show
end	
function layout:Show()
	
	if(self._show) then  return end
 
	self:Load()
	
	layoutManager.showView(self._view)
    self._show = true
    
	if(self._config.sound ~="-1")then
	   --Audio.playEffect(self._config.sound)	
	end

	if(self._config.showback) then
		--print(self._config.name);
		local topBackView = layoutManager.getTopBackView();
		eventManager.dispatchEvent({name = global_event.BLACKBACK_UI_SHOW, level = topBackView._view:GetLevel()+1 });
	end
		
	if self._config.showmoney then
		--print(self._config.name);
		local topMoneyView = layoutManager.getTopMoneyView();
		eventManager.dispatchEvent({name = global_event.RESOURCE_SHOW, level = topMoneyView._view:GetLevel(), ownerView = self });
	end
	
end

function layout:Close()
  if(self._show)then
      --layoutManager.CloseView(self._view)
      self._show = false
      self:Unload();
      
	  if(self._config.showback) then
			
			local topBackView = layoutManager.getTopBackView();
			
			--local stack, backData = layoutManager.decreaseBackStack();
			--dump(self._config)
			--print("decreaseBackStack stack "..stack);
			if topBackView == nil then
				eventManager.dispatchEvent({name = global_event.BLACKBACK_UI_HIDE});
			else
				eventManager.dispatchEvent({name = global_event.BLACKBACK_UI_UPDATE_LEVEL, level = topBackView._view:GetLevel()+1 });
			end
	  end
	  
	  
		if self._config.showmoney then
			local topMoneyView = layoutManager.getTopMoneyView();
			
			local level = nil;
			
			if topMoneyView then
				level = topMoneyView._view:GetLevel();
			end
			
			eventManager.dispatchEvent({name = global_event.RESOURCE_HIDE, level = level, ownerView = self });
			
		end
	
  end	
end	

function layout:Child(name)
	if(self._view == nil )then  return  nil end	
	return  engine.GetGUIWindowWithName(name)
end	


function layout:SetPosition(pos)
	if(self._view == nil )then  return    end	
	
 
	self._view:SetPosition(pos)
end	
