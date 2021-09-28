--------------------------------------------------------------------------------------
-- 文件名:	Game_BattleSetting.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	yupingli
-- 日  期:	2015-1-7 19:37
-- 版  本:	1.0
-- 描  述:	战斗设置界面
-- 应  用:
---------------------------------------------------------------------------------------
Game_BattleSetting = class("Game_BattleSetting")
Game_BattleSetting.__index = Game_BattleSetting

local function setButton_BattleMusic(Button_BattleMusic, IsMuteBattleMusic)
	Button_BattleMusic:getChildByName("Image_Mute"):setVisible(IsMuteBattleMusic)
	if IsMuteBattleMusic then
		if g_Cfg.Platform == kTargetWindows then
			SimpleAudioEngine:sharedEngine():pauseBackgroundMusic()
		else
			SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(0)
		end
	else
		if g_Cfg.Platform == kTargetWindows then
			SimpleAudioEngine:sharedEngine():resumeBackgroundMusic()
		else
			SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(1)
		end
	end
end

local function setButton_BattleSound(Button_BattleSound, IsMuteBattleSound)
	Button_BattleSound:getChildByName("Image_Mute"):setVisible(IsMuteBattleSound)
	if IsMuteBattleSound then
		if g_Cfg.Platform == kTargetWindows then
			--Windos设置音量功能无
		else
			SimpleAudioEngine:sharedEngine():setEffectsVolume(0)
		end
	else
		if g_Cfg.Platform == kTargetWindows then
			--Windos设置音量功能无
		else
			SimpleAudioEngine:sharedEngine():setEffectsVolume(1)
		end
	end
end

function Game_BattleSetting:initWnd(widget)
	local Image_BattleSettingPNL = tolua.cast(self.rootWidget:getChildByName("Image_BattleSettingPNL"), "ImageView")
	
	local Button_BattleMusic =  tolua.cast(Image_BattleSettingPNL:getChildByName("Button_BattleMusic"),"Button")
	local function onClick_BattleMusic(pSender, nTag)
		local IsMuteBattleMusic = CCUserDefault:sharedUserDefault():getBoolForKey("IsMuteBattleMusic", false)
		CCUserDefault:sharedUserDefault():setBoolForKey("IsMuteBattleMusic", not IsMuteBattleMusic)
		setButton_BattleMusic(pSender, not IsMuteBattleMusic)
	end
	g_SetBtnWithEvent(Button_BattleMusic, 1, onClick_BattleMusic, true, true)
	
	local Button_BattleSound =  tolua.cast(Image_BattleSettingPNL:getChildByName("Button_BattleSound"),"Button")
	local function onClick_BattleSound(pSender, nTag)
		local IsMuteBattleSound = CCUserDefault:sharedUserDefault():getBoolForKey("IsMuteBattleSound", false)
		CCUserDefault:sharedUserDefault():setBoolForKey("IsMuteBattleSound", not IsMuteBattleSound)
		setButton_BattleSound(pSender, not IsMuteBattleSound)
	end
	g_SetBtnWithEvent(Button_BattleSound, 1, onClick_BattleSound, true, true)

	local Button_Restart =  tolua.cast(Image_BattleSettingPNL:getChildByName("Button_Restart"),"Button")
	local function onClick_Restart(pSender, nTag)
        if not self.bRestart then
            local instance = g_WndMgr:getWnd("Game_Battle")
            if instance then       
				g_ClientMsgTips:showMsgConfirm(_T("重置战斗功能暂未开放，敬请期待..."))
            else
                g_ClientMsgTips:showMsgConfirm(_T("重置战斗功能暂未开放，敬请期待..."))
            end
        end
	end
	g_SetBtnWithEvent(Button_Restart, 1, onClick_Restart, true, true)

	local Button_Escape =  tolua.cast(Image_BattleSettingPNL:getChildByName("Button_Escape"),"Button")
	local function onClickEscape(pSender, nTag)
		if g_PlayerGuide:checkIsInGuide() then
			g_ClientMsgTips:showMsgConfirm(_T("处于引导过程中, 无法退出副本"))
			return
		end
			
		if not TbBattleReport or TbBattleReport.bEscape then
			return
		end

		local function onClickConfirm()
			if not TbBattleReport then return end
			TbBattleReport.bEscape = true
			TbBattleReport.IsSettingOpening = nil
			g_IsExitBattleProcess = true
			
			g_ArenaKuaFuData:setExitBalttleFlag(true)
			
			gTalkingData:onFailed(nil, TDMission_Cause.TDMission_Cause_Exit)

			if g_BattleMgr:getBattleType() == macro_pb.Battle_Atk_Type_SceneBoss or g_BattleMgr:getBattleType() == macro_pb.Battle_Atk_Type_GuildSceneBoss then
				g_MsgMgr:sendMsg(msgid_pb.MSGID_MOVE_EXIT_BOSS_FIGHT)
			end

			local function executeWndCloseWndEndCall()
				local function executeClearUpAction()
					if g_PlayerGuide:checkIsInGuide() then
						EscapeClearAllResouce(true, true)
					else
						EscapeClearAllResouce(true, false)
					end
				end
				
				if not TbBattleReport  or TbBattleReport.TbBattleWnd.bShow or not TbBattleReport.nRepeatAttackNum or TbBattleReport.bResetBuZhen then
					executeClearUpAction()
				else
					TbBattleReport.GameObj_BattleProcess:startToExitBattleProcess(executeClearUpAction)
				end
			end
			
			g_WndMgr:closeWnd("Game_BattleSetting", executeWndCloseWndEndCall)
		end
		g_ClientMsgTips:showConfirm(_T("是否要退出本次战斗？"), onClickConfirm)
	end
	g_SetBtnWithEvent(Button_Escape, 1, onClickEscape, true, true)
	
	local Button_Close =  tolua.cast(Image_BattleSettingPNL:getChildByName("Button_Close"),"Button")
	local function onClickClose()
		g_WndMgr:closeWnd("Game_BattleSetting")
	end
	g_SetBtnWithEvent(Button_Close, 1, onClickClose, true, true)
end

function Game_BattleSetting:closeWnd()
	
end

function Game_BattleSetting:openWnd()
	local Image_BattleSettingPNL = tolua.cast(self.rootWidget:getChildByName("Image_BattleSettingPNL"), "ImageView")
	
	local IsMuteBattleMusic = CCUserDefault:sharedUserDefault():getBoolForKey("IsMuteBattleMusic", false)
	local Button_BattleMusic =  tolua.cast(Image_BattleSettingPNL:getChildByName("Button_BattleMusic"),"Button")
	Button_BattleMusic:getChildByName("Image_Mute"):setVisible(IsMuteBattleMusic)

	local IsMuteBattleSound = CCUserDefault:sharedUserDefault():getBoolForKey("IsMuteBattleSound", false)
	local Button_BattleSound =  tolua.cast(Image_BattleSettingPNL:getChildByName("Button_BattleSound"),"Button")
	Button_BattleSound:getChildByName("Image_Mute"):setVisible(IsMuteBattleSound)
	if TbBattleReport then
		TbBattleReport.IsSettingOpening = true
	end
	
end

function Game_BattleSetting:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_BattleSettingPNL = tolua.cast(self.rootWidget:getChildByName("Image_BattleSettingPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_BattleSettingPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_BattleSetting:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_BattleSettingPNL = tolua.cast(self.rootWidget:getChildByName("Image_BattleSettingPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_BattleSettingPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end