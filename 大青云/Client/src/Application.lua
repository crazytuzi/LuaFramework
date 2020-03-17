_G.CGameApp = 
{
	objAppCore = nil
};  


function CGameApp.OnMouseMove(nXPos,nYPos) 
	CControlBase:OnMouseMove(nXPos,nYPos);
	UIManager:SetMouseOn(false);
end;


function CGameApp.OnMouseDown(nButton,nXPos,nYPos)
	CControlBase:OnMouseDown(nButton,nXPos,nYPos);
end;


function CGameApp.OnMouseUp(nButton,nXPos,nYPos)
	CControlBase:OnMouseUp(nButton,nXPos,nYPos); 
end;


function CGameApp.OnMouseDbclick(nXPos,nYPos)
	CControlBase:OnMouseDbclick(nXPos,nYPos);  
end;
 

function CGameApp.OnMouseWheel(fDelta) 
	CControlBase:OnMouseWheel(fDelta);
end;

function CGameApp.OnKeyDown(dwKeyCode)  
	CControlBase:OnKeyDown(dwKeyCode);   
end;

function CGameApp.OnKeyUp(dwKeyCode)  
	CControlBase:OnKeyUp(dwKeyCode);	
end;

function CGameApp.OnActive(bIsActive)
	CGameApp.bIsActive = bIsActive
	CControlBase:OnActive(bIsActive)
end


function CGameApp.OnResize(dwWidth,dwHeight)
	if CGameApp.bCanUpdate then
		UIManager:OnWinResize(dwWidth,dwHeight);
	end;
	if dwWidth == 0 and dwHeight == 0 then
		CPlayerMap:OnWindowMin();
	else
		CPlayerMap:OnWindowBack();
    end

    _app.console.rect.x1 = 4
    _app.console.rect.x2 = _rd.w - 4
    _app.console.rect.y1 = _rd.h / 2 + 4
    _app.console.rect.y2 = _rd.h - 20
end;


local dwElapseBuffer = 0;
local SAMPLE_TIME = 20000;
_G.font = _Font.new('Arial', 10)
local fpsBuffer = {};
local avgFps = 0;
local lowFpsCancel = false;
local midFpsCancel = false;
local highFpsCancel = false;
function CGameApp.OnIdle(dwElapse)
    --[[
	if CGameApp.bIsActive and dwElapse <= 32 then
		dwElapseBuffer = dwElapseBuffer + dwElapse;
		dwElapse = dwElapseBuffer / 32;
		dwElapseBuffer = dwElapseBuffer - dwElapse;
	end
	--]]
    --print("dwElapse: ", dwElapse)
    --print("GetCurTime: ", GetCurTime())
	--[[
	if GameController.loadingState == false and GameController.currentState == enNormalUpdate and CGameApp.bIsActive == true  then
		dwElapseBuffer  = dwElapseBuffer + dwElapse
		table.insert(fpsBuffer, _sys.fps)
		if dwElapseBuffer > SAMPLE_TIME then
			avgFps = avgTbl(fpsBuffer)
			fpsBuffer = {}
			dwElapseBuffer = 0
			if avgFps < 25 then
				--show notice win
				if _G.lightShadowQuality ~= _G.lowQuality and lowFpsCancel == false then 
					UIConfirm:Open("当前帧频较低，是否进入低品质模式", 
							function() _G.lightShadowQuality = _G.lowQuality end, function() lowFpsCancel = true end);
				end
			elseif avgFps < 60 then
				if _G.lightShadowQuality ~= _G.midQuality and midFpsCancel == false then 
					UIConfirm:Open("当前帧频正常，是否进入中品质模式", 
							function() _G.lightShadowQuality = _G.midQuality end, function() midFpsCancel = true end);
				end
			else
				--show notice win
				if _G.lightShadowQuality ~= _G.highQuality and highFpsCancel == false then 
					UIConfirm:Open("当前帧频很高，是否进入高品质模式", 
							function() _G.lightShadowQuality = _G.highQuality end, function() highFpsCancel = true end);
				end
			end
		end
	end
	--]]
	
	CGameApp:Update(dwElapse);
    font.textColor = _Color.Yellow
    if _G.isDebug then
        --font:drawText(0, _rd.h - 24, 'Press TAB to toggle debug / ESC to toggle Console / G to collect garbage / A to toggle async load' .. (_sys.asyncLoad and '(On)' or '(Off)'))

        if CPlayerMap.objSceneMap and CPlayerMap.objSceneMap.objScene then
            --_app.console:print('scene.getNodeCount:' .. CPlayerMap.objSceneMap.objScene:getNodeCount())
        end
    end
end;


function CGameApp.OnExit()
	Debug("CGameApp.OnExit")
    CGameApp:Destroy();
end; 

function CGameApp.onCloseWindow()
	Debug("CGameApp.onCloseWindow")
	ConnManager:close()
	if _G.isDebug then
		bigMsg:close()
	end
end;

------------------------------------------------
--
------------------------------------------------
function CGameApp:Create()
	_G.dummy1 = _Mesh.new('dummy_1.msh')
	_G.dummy2 = _Mesh.new('dummy_2.msh')
	_G.aabb = _G.dummy1:getBoundBox()
	Debug("aabb = ", _G.aabb.z2 - _G.aabb.z1)
	local loader = _Loader.new()
	Debug("loader = ", loader.lowPriority)
	_G.c1 = _Clipper.new()
	_G.c2 = _Clipper.new()
    --资源创建 
    _sys.gpuSkinning = false;
	_rd.animaBlendTime = 300;
    _randomSeed(_now());
	math.randomseed(_now())
	SetCurTime(0);
	
	PlatformFacade:InitPlatform();
	
	--_Archive:beginRecord()
	if not UIManager:Create() then
	    return false;
	end;

	self.objAppCore = CBaseApp:Create(self);

	if not self.objAppCore then
		print("self.objAppCore create error");
		return false;
    end;
	
	self:StartCreate()
    return true;
end;

function CGameApp:StartCreate()

	--单体创建
	if not CSingleManager:Create() then
		print("CSingleManager:Create() Error");
		return false;
	end;

    GameController:Create()

    self.bCanUpdate = true;
    CPlayerControl.bIsUsable = true;
	
	print('We Game Start');
	LoginController:ExecuteEnterGame();
	return true;
end;

function CGameApp:Update(dwInterval)  
    SetCurTime(dwInterval);

	UIManager:Update(dwInterval);
	TimerManager:Update(dwInterval);
	
    if self.bCanUpdate then
		CSingleManager:Update(dwInterval);
        GameController:Update(dwInterval);
    end
	if _G.isDebug then
		CMemoryDebug:Update();
	end

	return true;
end;

function CGameApp:Destroy()
	ConnManager:close()
	UIManager:Destroy();
	CSingleManager:Destroy();
end;

function CGameApp:GetApp()
	return self.objAppCore;
end;




















