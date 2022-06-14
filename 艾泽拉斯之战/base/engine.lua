
engine = {} 

engine.windowManager = LORD.GUIWindowManager:Instance();	

engine.uiRoot = engine.windowManager:CreateGUIWindow("DefaultWindow", "RootWindow");
engine.uiRoot:SetPosition(LORD.UVector2(LORD.UDim(0, 0), LORD.UDim(0, 0)));
engine.uiRoot:SetSize(LORD.UVector2(LORD.UDim(1, 0), LORD.UDim(1, 0)));

engine.guiSystem = LORD.GUISystem:Instance();
engine.guiSystem:SetRootWindow(engine.uiRoot);	 
engine.guiSystem:setHitTestOffset(5.0);

engine.guideUiVec = {}
engine.guideIndex = 0
 
engine.guideUiSceneVec = {} -- 挂到非ui上的指引
 


function addGuideUiInScene( ui )
	table.insert(engine.guideUiSceneVec,ui)
end	

function closeGuideUiInScene()
		for i,v in ipairs 	(engine.guideUiSceneVec) do
			if(v )then
					v:SetUserData(-1)
					v:SetVisible(false)
			end
		end
		engine.guideUiSceneVec = {}
 
		
		
end	

function getFreeGuideUi( id )
		print("getFreeGuideUi id :"..id)
		dump(engine.guideUiVec)
		local wname = "guideRootWindow"..id
		local key = table.keyOfItem(engine.guideUiVec,wname)
		
		if(key)then
			local n = 	engine.guideUiVec[key]	
			local v = engine.GetGUIWindowWithName(n)
			if(v)then
				return v
			end	
		end
	
		local w = engine.windowManager:CreateGUIWindow("DefaultWindow", wname);
		--engine.guideIndex = engine.guideIndex + 1
		w:SetPosition(LORD.UVector2(LORD.UDim(0, 0), LORD.UDim(0, 0)));
		w:SetSize(LORD.UVector2(LORD.UDim(0, 100), LORD.UDim(0, 100)));
		engine.uiRoot:AddChildWindow(w)
		w:SetEffectName("jiayuantexiao01_zhiyin.effect")
		w:SetVisible(false)
		w:SetLevel(100)
		w:SetTouchable(false)
		w:SetUserData(id)
		w:SetProperty("HorizontalAlignment","Centre")
		table.insert(engine.guideUiVec,wname)
		return w
end	


function FreeGuideUi( id )
		id = tonumber(id)
		if(id <= -1) then  return end
		local wname = "guideRootWindow"..id
		
		print("FreeGuideUi "..id)
		for i,_v in ipairs 	(engine.guideUiVec) do
			local v = engine.GetGUIWindowWithName(_v)
			if(v )then
				local tt = v:GetName()
				print("FreeGuideUi        "..tt)
				if(tt == wname )then
					v:SetUserData(-1)
					v:SetVisible(false)
					return 
				end
			end
		end
end	
 
function FreeGuideUiAll(  )
	
		local t = clone(engine.guideUiVec)
		for i,_v in ipairs 	(t) do
			local v = engine.GetGUIWindowWithName(_v)
			if(v )then
					v:SetUserData(-1)
					v:SetVisible(false)
			else
				    table.removeWithValue(engine.guideUiVec,_v)
			end
		end
end	

function engine.LoadWindowFromXML(xml)
	return engine.windowManager:LoadWindowFromXML(xml);
end

function engine.DestroyWindow(view)
    engine.windowManager:DestroyGUIWindow(view);
end

function engine.GetGUIWindowWithName(name)
	return engine.windowManager:GetGUIWindow(name);
end

engine.rootUiSize = {w = engine.uiRoot:GetPixelSize().x,h =  engine.uiRoot:GetPixelSize().y }



function engine.playBackgroundMusic(file ,loop)
	if(DEBUG_MUSIC_OPEN)then
		local  audioEngine = LORD.SoundSystem:Instance()
		audioEngine:playBackgroundMusic(file, true)
	end
end

function engine.centerWnd(wnd)
	
	local size =  wnd:GetPixelSize()	
	local x = (engine.rootUiSize.w - size.x)/2
	local y = (engine.rootUiSize.h- size.y)/2
	local xpos = LORD.UDim(0, x)
	local ypos = LORD.UDim(0, y)	
	wnd:SetPosition(LORD.UVector2(xpos, ypos));	
end	


function engine.centerWnd2(w1,w2)
	
	local size1 =  w1:GetPixelSize()	
	local size2 =  w2:GetPixelSize()	
	local x = (engine.rootUiSize.w - size1.x - size2.x)/2
	local y = (engine.rootUiSize.h- size1.y)/2
	local xpos = LORD.UDim(0, x)
	local ypos = LORD.UDim(0, y)	
	w1:SetPosition(LORD.UVector2(xpos, ypos));		
	xpos = LORD.UDim(0, x) + w1:GetWidth()
	w2:SetPosition(LORD.UVector2(xpos, ypos))
end	