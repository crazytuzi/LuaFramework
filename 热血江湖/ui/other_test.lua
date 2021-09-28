-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_other_test = i3k_class("wnd_other_test", ui.wnd_base)

function wnd_other_test:ctor()
end

function wnd_other_test:configure(...)
	local btnClose = self._layout.vars.btnClose;
	if btnClose then
		btnClose:onTouchEvent(self, self.onBtnClose);
	end

	local btnT = {self._layout.vars.t1, self._layout.vars.t2, self._layout.vars.t3, self._layout.vars.t4, self._layout.vars.t5, self._layout.vars.t6, self._layout.vars.t7};

	for i,v in pairs(btnT) do
		v:setTag(i);
		v:onTouchEvent(self, self.onT);
	end

	if self.sceneflash == nil then
		self.sceneflash = {}
		for k,v in pairs(i3k_db_sceneFlash) do
			local mapname = string.sub(v.path, 17, string.find(v.path, "/", 17) - 1)
			table.insert(self.sceneflash, {id = v.id, path = v.path, desc = v.desc, mapname = mapname})
		end
	end
	self.myEditbox = self._layout.vars.e1
	self.currentFlashIndex = 1
end

function wnd_other_test:onShow()
end

function wnd_other_test:onHide()
end

function wnd_other_test:onUpdate(dTime)
end

function wnd_other_test:onBtnClose(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_OtherTest);
	end
end

function wnd_other_test:LoadScene()
	local sceneflash = self.sceneflash
	local currentFlashIndex = self.currentFlashIndex
	local loaded = function()
		g_i3k_ui_mgr:CloseUI(eUIID_Loading);
		g_i3k_ui_mgr:OpenUI(eUIID_BattleBase)
		i3k_game_play_scene_ani(sceneflash[currentFlashIndex].id)
	end
	if self.curmap ~= self.sceneflash[self.currentFlashIndex].mapname then
		self.curmap = self.sceneflash[self.currentFlashIndex].mapname
		local logic = i3k_game_get_logic();
		if logic then
			logic:LoadMap(self.curmap, Engine.SVector3(0, 0, 0):ToEngine(), "default", loaded, 0);
		end
	else
		loaded()
	end
end

function wnd_other_test:onT(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local v = sender:getTag();
		if v == 1 then
			local i=0
			for i=0,3 do
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "createChatItem", {
					type=1, fromId=1000001, msg="离开队伍后任务这块就不显示了离开队伍后任务这块就不显示了离开队伍后任务这块就不显示了", msgType=0, msgContent={msg="离开队伍后任务这块就不显示了离开队伍后任务这块就不显示了离开队伍后任务这块就不显示了", type=0}, time=1476993716, equips={}, fromName="莽撞的镖师", bwType=0, iconId=301
				})
			end
			--local allSize, unusedSize = cc.Director:getInstance():getAllTextureSizeAndUnusedTextureSize(10);
			--g_i3k_ui_mgr:PopupTipMessage("allSize: " .. allSize .. "|   unusedSize:" .. unusedSize);
			--g_i3k_ui_mgr:OpenUI(eUIID_GodEye);

			--g_i3k_ui_mgr:PopupTipMessage("nowSize: " .. nowSize .. "|   afterSize:" .. afterSize);
		elseif v == 2 then
			local value = g_i3k_game_context:getDebugOnUpdateUI()
			g_i3k_game_context:setDebugOnUpdateUI(not value)
			g_i3k_ui_mgr:PopupTipMessage("i3k_ui_mgr_update(dtime) = ".. (( value) and "true" or "false"))
		elseif v == 3 then
			local value = g_i3k_game_context:getDebugOnUpdateLogic()
			g_i3k_game_context:setDebugOnUpdateLogic(not value)
			g_i3k_ui_mgr:PopupTipMessage("g_i3k_game_logic:OnUpdate(dTime) = ".. (( value) and "true" or "false"))
		elseif v == 4 then
			self.currentFlashIndex = self.currentFlashIndex - 1
			if self.currentFlashIndex < 1 then
				self.currentFlashIndex = #self.sceneflash
			end
			g_i3k_ui_mgr:PopupTipMessage(self.sceneflash[self.currentFlashIndex].desc);
		elseif v == 5 then
			self.currentFlashIndex = self.currentFlashIndex + 1
			if self.currentFlashIndex > #self.sceneflash then
				self.currentFlashIndex = 1
			end
			g_i3k_ui_mgr:PopupTipMessage(self.sceneflash[self.currentFlashIndex].desc);
		elseif v == 6 then
			self:LoadScene()
		else
		end

	end
end

function wnd_create(layout, ...)
	local wnd = wnd_other_test.new();
		wnd:create(layout, ...);

	return wnd;
end
