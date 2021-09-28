-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_sp_demo = i3k_class("wnd_sp_demo", ui.wnd_base)

function wnd_sp_demo:ctor()
end

function wnd_sp_demo:configure(...)
	local others = self._layout.vars.others;
	if others then
		others:onTouchEvent(self, self.onOthers);
	end
	
	local prevScene = self._layout.vars.preScene;
	if prevScene then
		prevScene:onTouchEvent(self, self.onPrevScene);
	end

	local nextScene = self._layout.vars.nextScene;
	if nextScene then
		nextScene:onTouchEvent(self, self.onNextScene);
	end

	local unloadScene = self._layout.vars.unloadScene;
	if unloadScene then
		unloadScene:onTouchEvent(self, self.onUnloadScene);
	end

	local disStaicNode = self._layout.vars.disStaicNode;
	if disStaicNode then
		disStaicNode:setTag(1);
		disStaicNode:onTouchEvent(self, self.onUpdateLoadFlags);
	end

	local disDynamicNode = self._layout.vars.disDynamicNode;
	if disDynamicNode then
		disDynamicNode:setTag(2);
		disDynamicNode:onTouchEvent(self, self.onUpdateLoadFlags);
	end

	local disSprNode = self._layout.vars.disSprNode;
	if disSprNode then
		disSprNode:setTag(3);
		disSprNode:onTouchEvent(self, self.onUpdateLoadFlags);
	end

	local disEffectNode = self._layout.vars.disEffectNode;
	if disEffectNode then
		disEffectNode:setTag(4);
		disEffectNode:onTouchEvent(self, self.onUpdateLoadFlags);
	end

	local disGroupNode = self._layout.vars.disGroupNode;
	if disGroupNode then
		disGroupNode:setTag(5);
		disGroupNode:onTouchEvent(self, self.onUpdateLoadFlags);
	end

	local disTerrain = self._layout.vars.disTerrain;
	if disTerrain then
		disTerrain:setTag(6);
		disTerrain:onTouchEvent(self, self.onUpdateLoadFlags);
	end

	local btnFunc = self._layout.vars.btnFunc;
	if btnFunc then
		btnFunc:onTouchEvent(self, self.onTestFunc);
	end

	self._loadStates = { { btn = disStaicNode, state = true }, { btn = disDynamicNode, state = true }, { btn = disSprNode, state = true }, { btn = disEffectNode, state = true }, { btn = disGroupNode, state = true }, { btn = disTerrain, state = true } };
end

function wnd_sp_demo:onShow()
end

function wnd_sp_demo:onHide()
end

function wnd_sp_demo:onUpdate(dTime)
end

function wnd_sp_demo:onOthers(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:OpenUI(eUIID_OtherTest);
	end
end

function wnd_sp_demo:onPrevScene(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local logic = i3k_game_get_logic();
		if logic then
			logic:PrevScene();
		end
	end
end

function wnd_sp_demo:onNextScene(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local logic = i3k_game_get_logic();
		if logic then
			logic:NextScene();
		end
	end
end

function wnd_sp_demo:onUnloadScene(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local logic = i3k_game_get_logic();
		if logic then
			logic:UnloadScene();
		end
	end
end

function wnd_sp_demo:onUpdateLoadFlags(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local tag = sender:getTag();

		self._loadStates[tag].state = not self._loadStates[tag].state;
		if self._loadStates[tag].state then
			self._loadStates[tag].btn:stateToNormal();
		else
			self._loadStates[tag].btn:stateToPressed();
		end

		local logic = i3k_game_get_logic();
		if logic then
			logic:UpdateLoadFlags(self._loadStates[1].state, self._loadStates[2].state, self._loadStates[3].state, self._loadStates[4].state, self._loadStates[5].state, self._loadStates[6].state);
		end
	end
end

function wnd_sp_demo:onTestFunc(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local logic = i3k_game_get_logic();
		if logic then
			logic:TestFunc();
		end
	end
end

function wnd_sp_demo:setSceneName(name)
	local ctrl = self._layout.vars.sceneName;
	if ctrl then
		ctrl:setText(name);
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_sp_demo.new();
		wnd:create(layout, ...);

	return wnd;
end

