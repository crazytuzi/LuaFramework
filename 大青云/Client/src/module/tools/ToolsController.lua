--[[
工具
]]

_G.ToolsController = setmetatable({},{__index=IController});
ToolsController.name = "ToolsController";

--开启摄像机转换
ToolsController.cameraFree = false;
--开启场景自由拖动
ToolsController.sceneFree = false;
--开启UI隐藏
ToolsController.hideUI = false;
--隐藏光标
ToolsController.hideCursors = false;


function ToolsController:Create()
	CControlBase:RegControl(self, true);
end

function ToolsController:OnKeyDown(keyCode)

	if CControlBase.oldKey[_System.KeyESC] then
		if keyCode == _System.KeyD then
			_G.DebugActived = true;
		elseif keyCode == _System.KeyR then
			local state = not _G.Recording;
			_G.StepRecord(state);
			local desc = state and '开始录制' or '录制完成';
			UIChat:ClientText(desc);
		end
	end	

	------------------运营需求-------------------
	if isDebug or _sys:getGlobal("dGM") then
		if keyCode == _System.KeyO then
			GMView:Show();
		elseif keyCode == _System.KeyESC then
			if self.hideUI then
				UIManager:Switch();
				self.hideUI = false;
			end
			if self.hideCursors then
				CCursorManager:DelState("hide");
				self.hideCursors = false;
			end
		elseif CControlBase.oldKey[_System.KeyT] then
			if keyCode == _System.Key0 then
				if not UIToolsCameraMain:IsShow() then
					UIToolsCameraMain:Show();
				end
			end
		end
	end
	if not isDebug then return; end
	if CControlBase.oldKey[_System.KeyE] then
		-- 神兵模型编辑器
		if keyCode == _System.Key1 then
			if not UIToolsShenbingDraw:IsShow() then
				UIToolsShenbingDraw:Show()
			end
			return
		end
		-- 灵器模型编辑器
		if keyCode == _System.Key2 then
			if not UIToolsLingQiDraw:IsShow() then
				UIToolsLingQiDraw:Show()
			end
			return
		end
		-- 玉佩模型编辑器
		if keyCode == _System.Key3 then
			if not UIToolsMingYuDraw:IsShow() then
				UIToolsMingYuDraw:Show()
			end
			return
		end
		-- 宝甲模型编辑器
		if keyCode == _System.Key4 then
			if not UIToolsArmorDraw:IsShow() then
				UIToolsArmorDraw:Show()
			end
			return
		end
	end
	if CControlBase.oldKey[_System.KeyT] then
		if keyCode == _System.Key0 then
			if not UIToolsCameraMain:IsShow() then
				UIToolsCameraMain:Show();
			end
			return;
		end
		if keyCode == _System.Key1 then
			if not UIToolsNpcDraw:IsShow() then
				UIToolsNpcDraw:Show();
			end
			return;
		end
		-- 噬魂怪物模型编辑器
		if keyCode == _System.Key2 then 
			if not UIToolsShihunMonster:IsShow() then 
				UIToolsShihunMonster:Show();
			end;

		end;
		-- 坐骑模型编译器
		if keyCode == _System.Key3 then 
			if not UIToolMountModelDraw:IsShow() then 
				UIToolMountModelDraw:Show();
			end;

		end;
		-- 坐骑模型编译器2Inthe
		if keyCode == _System.Key4 then 
			if not UIToolMountModelDrawInthe:IsShow() then 
				UIToolMountModelDrawInthe:Show();
			end;

		end;
		-- 坐骑模型编译器3small
		if keyCode == _System.Key5 then 
			if not UIToolMountModelDrawSmall:IsShow() then 
				UIToolMountModelDrawSmall:Show();
			end;

		end;
		-- 人物模型编译器
		if keyCode == _System.Key6 then
			if not UIToolsRoleDraw:IsShow() then
				UIToolsRoleDraw:Show();
			end
			return;
		end
		-- 组队人物模型编译器
		if keyCode == _System.Key7 then
			if not UIToolsReamRoleDraw:IsShow() then
				UIToolsReamRoleDraw:Show();
			end
			return;
		end
		-- 技能人物模型编译器
		if keyCode == _System.Key8 then
			if not UIToolsRoleSkillDraw:IsShow() then
				UIToolsRoleSkillDraw:Show();
			end
			return;
		end
		--珍宝阁编译器
		if keyCode == _System.Key9 then
			if not UIToolsJewelleryDraw:IsShow() then
				UIToolsJewelleryDraw:Show();
			end
			return;
		end
	end
	if CControlBase.oldKey[_System.KeyY] then
		-- 竞技场人物编译工具
		if keyCode == _System.Key1 then
			if not UIToolsArenaRoleDraw:IsShow() then
				UIToolsArenaRoleDraw:Show();
			end
			return;
		end	
		-- 排行榜模型编译器
		if keyCode == _System.Key2 then 
			if not UIToolsRankList:IsShow() then 
				UIToolsRankList:Show();
			end
			return;
		end;
		-- 地宫炼狱模型编辑器(大)
		if keyCode == _System.Key4 then 
			if not UIToolsUnionHellDraw:IsShow() then 
				UIToolsUnionHellDraw:Show();
			end
			return;
		end
		-- 地宫炼狱模型编辑器(小)
		if keyCode == _System.Key5 then 
			-- 地宫炼狱模型编辑器(小)已删除
			-- 此快捷键可分配给其他
			-- 工具
			return
		end
		--
		if keyCode == _System.Key6 then
			if not UIToolsPfxDraw:IsShow() then
				UIToolsPfxDraw:Show();
			end
			return;
		end
		-- 打宝地宫BOSS模型编辑器
		if keyCode == _System.Key7 then 
			if not UIToolsXianYuanCaveDraw:IsShow() then 
				UIToolsXianYuanCaveDraw:Show();
			end
			return;
		end;
		
		-- 时装衣柜模型编辑器
		if keyCode == _System.Key8 then 
			if not UIToolsFashionsRoleDraw:IsShow() then 
				UIToolsFashionsRoleDraw:Show();
			end
			return;
		end;
		--NPC对话剧情框
		if keyCode == _System.Key9 then 
			if not  UIToolsNpcChatFrameDraw:IsShow() then 
				UIToolsNpcChatFrameDraw:Show();
			end
			return;
		end
		--野外BOSS模型编辑器
		if keyCode == _System.Key0 then
			if not  UIToolsFieldBossDraw:IsShow() then
				UIToolsFieldBossDraw:Show();
			end
			return;
		end
		if keyCode == _System.KeyNum1 then
			if not UIToolsRxtremityDraw:IsShow() then
				UIToolsRxtremityDraw:Show();
			end
			return ;
		end
		if keyCode == _System.KeyNum7 then
			if not ToolsRandomRaffleNpcDraw:IsShow() then
				ToolsRandomRaffleNpcDraw:Show();
			end
			return ;
		end
	end;
	
	if CControlBase.oldKey[_System.KeyU] then
		-- 封妖怪物模型编辑器
		if keyCode == _System.Key1 then 
			if not UIToolsFengyaoMonster:IsShow() then 
				UIToolsFengyaoMonster:Show();
			end
			
			-- 时装衣柜模型编辑器
			if not UIToolsFashionsRoleDraw:IsShow() then 
				UIToolsFashionsRoleDraw:Show();
			end
			
			-- 冰奴模型编辑器
			if not UIToolsBingNuDraw:IsShow() then
				UIToolsBingNuDraw:Show();
			end
			return;
		end;
		-- 世界boss怪物模型编辑器
		if keyCode == _System.KeyNum2 then 
			if not UIToolsWorldBossDraw:IsShow() then 
				UIToolsWorldBossDraw:Show();
			end
			return;
		end;
		-- 妖丹人物打坐模型编辑器
		if keyCode == _System.Key3 then 
			if not UIToolsBogeyPillDraw:IsShow() then 
				UIToolsBogeyPillDraw:Show();
			end
			return;
		end;
		-- 妖丹人物打坐模型编辑器
		if keyCode == _System.Key4 then 
			if not ToolBabelBossDraw:IsShow() then 
				ToolBabelBossDraw:Show();
			end
			return;
		end;
		if keyCode == _System.Key5 then 
			if not  UIToolsRoleChatFrameDraw:IsShow() then 
				UIToolsRoleChatFrameDraw:Show();
			end
			return;
		end;
		if keyCode == _System.Key6 then 
			if not  UIToolsCollectionShow:IsShow() then 
				UIToolsCollectionShow:Show();
			end
			return;
		end;
		if keyCode == _System.Key7 then 
			if not UIToolZhanshouDraw:IsShow() then 
				UIToolZhanshouDraw:Show()
			end
			return
		end
		if keyCode == _System.Key8 then 
			if not UIToolMountShowDraw:IsShow() then 
				UIToolMountShowDraw:Show();
			end
			return;
		end;
		if keyCode == _System.Key9 then
			if not UIToolWingTipsDraw:IsShow() then
				UIToolWingTipsDraw:Show();
			end
			return;
		end		
		--七日奖励
		if keyCode == _System.KeyNum7 then
			if not ToolWeekSignDraw:IsShow() then
				ToolWeekSignDraw:Show();
			end
			return ;
		end
		--个人BOSS
		if keyCode == _System.KeyNum9 then
			if not ToolPersonalBossDraw:IsShow() then
				ToolPersonalBossDraw:Show();
			end
			return ;
		end
		--挑战副本
		if keyCode == _System.KeyNum1 then
			if not ToolDekaronBossDraw:IsShow() then
				ToolDekaronBossDraw:Show();
			end
			return ;
		end
	end
	if CControlBase.oldKey[_System.KeyR] then
		if keyCode == _System.Key1 then 
			if not UIToolsVipShow:IsShow() then 
				UIToolsVipShow:Show();
			end			
		end;
		-- 噬魂怪物模型编辑器
		if keyCode == _System.Key2 then 
			if not UIToolsUnionBossMonster:IsShow() then 
				UIToolsUnionBossMonster:Show();
			end;
		end;
			-- 地宫怪物模型编辑器
		if keyCode == _System.Key3 then 
			if not UIToolsPalaceBossDraw:IsShow() then 
				UIToolsPalaceBossDraw:Show();
			end;
		end;
	end
	if CControlBase.oldKey[_System.KeyH] then
		if not UIGMCmd:IsShow() then 
			UIGMCmd:Show();
		else
			UIGMCmd:Hide();
		end
	end
	if _sys:isKeyDown(_System.KeyJ) then 
		if _sys:isKeyDown(_System.KeyX) then
			if _sys:isKeyDown(_System.KeyD) then 
				 SkillUtil.debugQuickly = true
			end
		end
    end
	--新增加GM界面
	if CControlBase.oldKey[_System.KeyG] then
		if keyCode == _System.Key5 then
			if not GmOrder:IsShow() then 
				GmOrder:Show();
			end			
		end
		-- GM快捷键更改提醒
		if keyCode == _System.Key1 then
			 -- FloatManager:AddCenter(UIStrConfig['autoBattle20'])
			  return;
		end
		if keyCode == _System.KeySpace then
			 -- FloatManager:AddCenter(UIStrConfig['autoBattle21'])
			 return;
		end
		if keyCode == _System.KeySpace then
			if not UIGMCmd:IsShow() then 
				UIGMCmd:Show();
			else
				UIGMCmd:Hide();
			end
		end
	end
end