-------------------------------------------------------
module(..., package.seeall)

local require = require;

local l_uiid = eUIID_GodEye
local l_closeAll = false
local l_profiling = false
local l_isDynLoadMap = true

local ui = require("ui/base");

-------------------------------------------------------
wnd_godeye = i3k_class("wnd_set_blood", ui.wnd_base)

function wnd_godeye:ctor()
	self._is_ok = false
	self._percent = 1
	self._btnClose = nil
	self._btnFPS = nil
	self._btnPause = nil
	self._btnCloseAll = nil
	self._btnProfile = nil
	self._btnDynLoadMap = nil
	self._btnDrawNodes = { }
	self._btnLoadNodes = { }
	self._btnUINodes = { }
end

function wnd_godeye:configure(...)

	local widgets = self._layout.vars

	self._btnClose = widgets.close
	self._btnClose:onClick(self, 
		function()
			g_i3k_ui_mgr:CloseUI(l_uiid)
			if l_closeAll then
				g_i3k_logic:OpenMainUI()
				l_closeAll = false
			end
		end
		)

	self._btnCloseAll = widgets.closeAll
	self._btnCloseAll:onClick(self, 
		function()
			g_i3k_ui_mgr:CloseAllOpenedUI(l_uiid)
			l_closeAll = true
		end
		)

	self._btnFPS = widgets.showFPS
	self._btnFPS:onClick(self, 
		function()
			cc.Director:getInstance():setDisplayStats(not cc.Director:getInstance():isDisplayStats())
			self:refresh()
		end
		)

	self._btnPause = widgets.pauseLogic
	self._btnPause:onClick(self, 
		function()
			if i3k_game_is_pause() then
				i3k_game_resume()
			else
				i3k_game_pause()
			end
			self:refresh()
		end
		)

	self._btnDynLoadMap = widgets.dynLoadMap
	self._btnDynLoadMap:onClick(self, 
		function()
			if l_isDynLoadMap then
				g_i3k_mmengine:EnableSceneCheckPos(false, Engine.SVector3():ToEngine(), 32)
			else
				g_i3k_mmengine:EnableSceneCheckPos(true, Engine.SVector3():ToEngine(), 32)
			end
			l_isDynLoadMap = not l_isDynLoadMap
			self:refresh()
		end
		)

	self._btnProfile = widgets.profile
	self._btnProfile:onClick(self, 
		function()
			if l_profiling then
				Debugger.EndProfileAndroid()
			else
				Debugger.StartProfileAndroid()
			end
			l_profiling = not l_profiling
			self:refresh()
		end
		)
	
	self._btnDrawNodes[0] = { name = "static", btn = widgets.drawStatic }
	self._btnDrawNodes[2] = { name = "terrain", btn = widgets.drawTerrain }
	self._btnDrawNodes[4] = { name = "sprite", btn = widgets.drawSprite }
	self._btnDrawNodes[7] = { name = "water", btn = widgets.drawWater }
	self._btnDrawNodes[23] = { name = "shake", btn = widgets.drawCameraShake }
	self._btnDrawNodes[25] = { name = "ocean", btn = widgets.drawSNTOcean }
	self._btnDrawNodes[26] = { name = "animesh", btn = widgets.drawAniMesh }
	self._btnDrawNodes[32] = { name = "all3d", btn = widgets.drawAll3D }
	self._btnDrawNodes[33] = { name = "title", btn = widgets.drawSNTTitle }
	self._btnDrawNodes[41] = { name = "simplemesh2", btn = widgets.drawSimpleMesh2 }
	self._btnDrawNodes[42] = { name = "envparticle", btn = widgets.drawEnvParticle }
	self._btnDrawNodes[43] = { name = "conversation", btn = widgets.drawSNTConversation }

	for k, v in pairs(self._btnDrawNodes) do
		v.btn:onClick(self, 
			function()
				if Debugger.IsRendererSceneNode(k) == 1 then
					Debugger.PauseRendererSceneNode(k)
				else
					Debugger.ResumeRendererSceneNode(k)
				end
				self:refresh()
			end		
		)
	end

	self._btnLoadNodes[1] = { name = "texture", btn = widgets.loadTexture }

	for k, v in pairs(self._btnLoadNodes) do
		v.btn:onClick(self, 
			function()
				if Debugger.IsLoadResource(k) == 1 then
					Debugger.PauseLoadResource(k)
				else
					Debugger.ResumeLoadResource(k)
				end
				self:refresh()
			end		
		)
	end

	self._btnUINodes[0] = { name = "update", btn = widgets.uiStopUpdate }
	self._btnUINodes[1] = { name = "draw", btn = widgets.uiStopDraw }
	self._btnUINodes[2] = { name = "draw sprite", btn = widgets.uiStopDrawSprite }
	self._btnUINodes[3] = { name = "draw particle", btn = widgets.uiStopDrawParticle }
	self._btnUINodes[4] = { name = "draw label", btn = widgets.uiStopDrawLabel }
	self._btnUINodes[5] = { name = "renderer", btn = widgets.uiStopRenderer }
	self._btnUINodes[6] = { name = "breadth first", btn = widgets.uiStopBreadthFirst }

	
	for k, v in pairs(self._btnUINodes) do
		v.btn:onClick(self, 
			function()
				if cc.Director:getInstance():getDebugFlag(k) == 0 then
					cc.Director:getInstance():setDebugFlag(k, 1)
				else
					cc.Director:getInstance():setDebugFlag(k, 0)
				end
				self:refresh()
			end		
		)
	end
end

function wnd_godeye:refresh()
	self._btnFPS:setText(cc.Director:getInstance():isDisplayStats() and "hide fps" or "show fps")
	self._btnPause:setText(i3k_game_is_pause() and "resume logic" or "pause logic")
	self._btnProfile:setText(l_profiling and "stop android profile" or "start android profile")
	self._btnDynLoadMap:setText(l_isDynLoadMap and "pre load map" or "dyn load map")
	for k, v in pairs(self._btnDrawNodes) do
		v.btn:setText(Debugger.IsRendererSceneNode(k) == 1 and ("hide " .. v.name) or ("draw " .. v.name))
	end
	for k, v in pairs(self._btnLoadNodes) do
		v.btn:setText(Debugger.IsLoadResource(k) == 1 and ("ignore " .. v.name) or ("load " .. v.name))
	end
	for k, v in pairs(self._btnUINodes) do
		v.btn:setText(cc.Director:getInstance():getDebugFlag(k) == 0 and ("uistop " .. v.name) or ("uiresume " .. v.name))
	end
end

function wnd_godeye:onShow()
	self:refresh()
end

function wnd_godeye:onHide()
end

function wnd_godeye:Update()
end

function wnd_godeye:OnUpdate()
end

function wnd_godeye:onUpdate()
end

function wnd_create(layout,...)
	local wnd = wnd_godeye.new()
	wnd:create(layout,...)
	return wnd
end
