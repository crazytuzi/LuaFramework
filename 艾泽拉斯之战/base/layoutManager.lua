 
-- wangzhen create  04.21.2014 @beijing

layoutManager   = {}
layoutManager.views = {}

-- 需要记录显示背景的堆栈，
-- 显示一个就+1
-- 隐藏一个就-1，

layoutManager.backgroudstack = 0;
layoutManager.backgroudLevelList = {};

function layoutManager.loadView()
	 for k,v in ipairs(dataConfig.configs.uiConfig) do		
	    echoInfo("loadView -- :%d  %s %s",(k),v.name,v.script)		
  
		local ui  = include(v.script).new(k)
		layoutManager.views[v.name] = ui
		ui:RegiserEvent();		
		
		ui:saveInitKeys();
	end
	
end	

function layoutManager.showView(view)
	engine.uiRoot:AddChildWindow(view)	
end

function layoutManager.increaseBackStack(backLevel, ownerView)
	layoutManager.backgroudstack = layoutManager.backgroudstack + 1;
	layoutManager.backgroudLevelList[layoutManager.backgroudstack] = {};
	layoutManager.backgroudLevelList[layoutManager.backgroudstack].backLevel = backLevel;
	layoutManager.backgroudLevelList[layoutManager.backgroudstack].ownerView = ownerView;
end

function layoutManager.decreaseBackStack()
	layoutManager.backgroudstack = layoutManager.backgroudstack - 1;
	
	return layoutManager.backgroudstack, layoutManager.backgroudLevelList[layoutManager.backgroudstack];
end

function layoutManager.getTopBackView()
	
	local minLevelView = nil;
	
	for k,v in pairs(layoutManager.views) do
		
		if v._show and v._config.showback then
			
			if minLevelView then
				if v._view:GetLevel() < minLevelView._view:GetLevel() then
					minLevelView = v;
				end
			else
				minLevelView = v;
			end
			
		end
		
	end

	return minLevelView;
end

function layoutManager.getTopMoneyView()
	
	local minLevelView = nil;
	
	for k,v in pairs(layoutManager.views) do
		
		if v._show and v._config.showmoney then
			
			if minLevelView then
				if v._view:GetLevel() < minLevelView._view:GetLevel() then
					minLevelView = v;
				end
			else
				minLevelView = v;
			end
			
		end
		
	end

	return minLevelView;
end

--function layoutManager.CloseView(view)
	--engine.uiRoot:RemoveChildWindow(view)
--end

function layoutManager.getUI(name)
	return layoutManager.views[name]
end


function layoutManager.Unload(ui)

	if LORD.GUIWindowManager:Instance():GetGUIWindow(ui:getRootWindowName()) then
		engine.DestroyWindow(ui._view);
	end
					
	layoutManager.handleDelay()

end

function layoutManager.hideAllUI()
	for k, v in pairs(layoutManager.views) do
		if v and v._show == true then
			--print(k);
			v:onHide();
		end 
	end
end

function layoutManager.handleDelay()
	if(not layoutManager.delayEvent)then
		return
	end
	local dispatch = true
	for _ ,d in  pairs (layoutManager.delayEvent) do
		 
		for k ,v in  pairs (d.v) do
			local ui = layoutManager.getUI(v)
			if(ui and ui._show)then
				dispatch = false
				break
			end	
		end
		if(dispatch == true)then
			eventManager.dispatchEvent(d.e)
			d.over = true
		end						
	end	
	
	local num = #layoutManager.delayEvent
	for i = num, 1,-1 do
		if(layoutManager.delayEvent[i] and layoutManager.delayEvent[i].over)then
			table.remove(layoutManager.delayEvent,i)
		end			
	end		
end	
function layoutManager.delay(event,viewList)
	local delayEvent = false
	for i ,v in  pairs (viewList) do
		local ui = layoutManager.getUI(v)
		if(ui and ui._show)then
			delayEvent = true
		end	
	end
	if(delayEvent == false)then
		eventManager.dispatchEvent(event)
	else
		layoutManager.delayEvent = layoutManager.delayEvent  or {}
		table.insert( layoutManager.delayEvent, {e = event, v = viewList, over = false})		
	end
	
end