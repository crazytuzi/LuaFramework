local CSysSettingView = class("CSysSettingView", CViewBase)

--内部类
local CSetBox = class("CSetBox", CBox)
CSysSettingView.CSetBox = CSetBox

function CSetBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_CheckSprite = self:NewUI(1, CSprite)   
	self.m_Slider = self:NewUI(2, CSlider, false)     
	self.m_TipsBtn = self:NewUI(3, CButton, false)
end

function CSetBox.SetSelected(self, bSelect)
	self.m_CheckSprite:SetSelected(bSelect)
	self:SetSliderEnabled(bSelect)
end

function CSetBox.SetCheckSpriteFunc(self, func)
	self.m_CheckSprite:AddUIEvent("click", function ()
		local isEnabled = self.m_CheckSprite:GetSelected()
		self:SetSliderEnabled(isEnabled)
		func(self.m_CheckSprite)
	end)
end

function CSetBox.SetSliderEnabled(self, isEnabled)
	if self.m_Slider then
		self.m_Slider:SetEnabled(isEnabled)
	end
end

function CSetBox.SetSliderChanged(self, func)
	self.m_Slider:AddUIEvent("click", func)
	self.m_Slider:AddUIEvent("dragend", func)
end

function CSetBox.SetSliderValue(self, value)
	self.m_Slider:SetValue(value)
end

function CSetBox.SetTipsBtnDesc(self, desc)
	if self.m_TipsBtn then
		self.m_TipsBtn:AddHelpTipClick(desc)
	end
end

function CSysSettingView.ctor(self, cb)
	CViewBase.ctor(self, "UI/SystemSettings/SystemSettingsMainView.prefab", cb)
	self.m_DepthType = "Dialog"  --层次
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
	self.m_IsAlwaysShow = true
end

function CSysSettingView.OnCreateView(self)
	self.m_CloseBtn                             = self:NewUI(1, CButton)
	self.m_HeadTexture                          = self:NewUI(2, CTexture)
	self.m_ServerLabel                          = self:NewUI(3, CLabel)
	self.m_RoleNameLabel                        = self:NewUI(4, CLabel)
	self.m_RoleIDLabel                          = self:NewUI(5, CLabel)
	self.m_LockScreenBtn                        = self:NewUI(6, CButton)
	self.m_SwitchAccountBtn                     = self:NewUI(7, CButton)
	self.m_QuitGameBtn                          = self:NewUI(8, CButton)
	self.m_UpdateGongGaoBtn                     = self:NewUI(9, CButton)
	self.m_Music                                = self:NewUI(10, CSetBox)
	self.m_Sound                                = self:NewUI(11, CSetBox)
	self.m_Dubbing                              = self:NewUI(12, CSetBox)
	self.m_SolveBtn                             = self:NewUI(13, CButton)
	self.m_ZoomLens                             = self:NewUI(14, CSetBox)
	self.m_SolveTipsBtn                         = self:NewUI(15, CButton)
	self.m_UpdateYuyinBtn 						= self:NewUI(16, CButton)
	self.PushSettingBtn							= self:NewUI(17, CButton)
	self.m_HidePlayer							= self:NewUI(18, CSetBox)
	self:InitContent()
end
--~CSysSettingView:ShowView()
function CSysSettingView.InitContent(self)
	local isWar = g_WarCtrl:IsWar()
	self.m_SolveBtn:SetActive(isWar)
	self.m_LockScreenBtn:SetActive(not isWar)
	--[[
	if isWar then
		self.m_UploadRecordBtn = self.m_SolveBtn:Clone()
		self.m_UploadRecordBtn:SetParent(self.m_SolveBtn:GetParent())
		local pos = self.m_UploadRecordBtn:GetLocalPos()
		local w  = self.m_UploadRecordBtn:GetWidth()
		pos.x = pos.x - w - 5
		self.m_UploadRecordBtn:SetLocalPos(pos)
		self.m_UploadRecordBtn:SetText("上传录像")
		self.m_UploadRecordBtn:AddUIEvent("click", callback(self, "OnUploadBtn"))
	end
	]]




	local tAccount = g_SysSettingCtrl:GetSysSettings()
	--table.print(tAccount)

	-- 关闭按钮
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))

	-- 头像
	local path = string.format("Texture/Friend/frd_%s.png", g_AttrCtrl.model_info.shape)
	self.m_HeadTexture:LoadPath(path)

	-- 服务器]
	if g_LoginCtrl.m_ConnectServer then
		self.m_ServerLabel:SetText(g_LoginCtrl.m_ConnectServer.name)
	else
		self.m_ServerLabel:SetText("未知")
	end

	-- 角色名
	self.m_RoleNameLabel:SetText(g_AttrCtrl.name)

	--ID
	self.m_RoleIDLabel:SetText(g_AttrCtrl.pid)

	-- 锁定屏幕
	self.m_LockScreenBtn:AddUIEvent("click", callback(self, "OnLockScreenBtn"))

	-- 切换帐号
	self.m_SwitchAccountBtn:AddUIEvent("click", callback(self, "OnSwitchAccountBtn"))

	-- 退出游戏
	self.m_QuitGameBtn:AddUIEvent("click", callback(self, "OnQuitGameBtn"))

	-- 更新公告
	self.m_UpdateGongGaoBtn:AddUIEvent("click", callback(self, "OnUpdateGongGaoBtn"))

	-- 更新语音
	self.m_UpdateYuyinBtn:AddUIEvent("click", callback(self, "OnUpdateYuyinBtn"))

	-- 音乐
	self.m_Music:SetCheckSpriteFunc(callback(self, "OnMusicCheckSprite"))
	self.m_Music:SetSelected(tAccount["music_enabled"])
	self.m_Music:SetSliderChanged(callback(self, "OnMusicSliderChanged"))
	self.m_Music:SetSliderValue(tAccount["music_percentage"])

	-- 音效
	self.m_Sound:SetCheckSpriteFunc(callback(self, "OnSoundEffectCheckSprite"))
	self.m_Sound:SetSelected(tAccount["sound_effect_enabled"])
	self.m_Sound:SetSliderChanged(callback(self, "OnSoundEffectSliderChanged"))
	self.m_Sound:SetSliderValue(tAccount["sound_effect_percentage"])

	-- 配音
	self.m_Dubbing:SetCheckSpriteFunc(callback(self, "OnDubbingCheckSprite"))
	self.m_Dubbing:SetSelected(tAccount["dubbing_enabled"])
	self.m_Dubbing:SetSliderChanged(callback(self, "OnDubbingSliderChanged"))
	self.m_Dubbing:SetSliderValue(tAccount["dubbing_percentage"])

	--解决卡机
	if g_WarCtrl:IsWar() and g_WarCtrl:GetIsEscape() and g_SysSettingCtrl:GetSolveKaJiEnabled() then
		self.m_SolveBtn:SetGrey(true)
		self.m_SolveBtn:EnableTouch(false)
	else
		self.m_SolveBtn:AddUIEvent("click", callback(self, "OnSolveBtn"))
	end
	self.m_SolveTipsBtn:SetHint("战斗中卡机的时候点我吧")

	-- 镜头缩放
	self.m_ZoomLens:SetCheckSpriteFunc(callback(self, "OnZoomlensCheckSprite"))
	self.m_ZoomLens:SetSelected(tAccount["zoomlens_enabled"])
	self.m_ZoomLens:SetTipsBtnDesc("zoom_lens")

	-- 屏蔽其他玩家
	self.m_HidePlayer:SetCheckSpriteFunc(callback(self, "OnHidePlayerCheckSprite"))
	self.m_HidePlayer:SetSelected(tAccount["hideplayer_enabled"])
	self.m_HidePlayer:SetTipsBtnDesc("hideplayer")
	
	if g_SdkCtrl:IsSupportService() then
		self.m_QuitGameBtn:SetText("客服反馈")
	end
	self.PushSettingBtn:AddUIEvent("click", callback(self, "OnShowPush"))
end

function CSysSettingView.OnShowPush(self)
	CPushSettingView:ShowView()
end

function CSysSettingView.OnUploadBtn(self)
	if not g_WarCtrl:IsWar() then
		g_NotifyCtrl:FloatMsg("战斗中才能使用")
		return
	end
	local windowInputInfo = {
		des             = "请描述战斗遇到的异常",
		title           = "反馈bug",
		inputLimit      = 960,
		okCallback      = function(oInput)
			local sInput = oInput:GetText()
			local sTime = os.date("%y_%m_%d(%H_%M_%S)",g_TimeCtrl:GetTimeS())
			local sKey = string.format("war_pid%d_%s_%s", g_AttrCtrl.pid, sTime, sInput)
			g_NetCtrl:SaveRecordsToServer(sKey, {side=g_WarCtrl:GetAllyCamp()})
		end,
		isclose = true,
	}
	g_WindowTipCtrl:SetWindowInput(windowInputInfo)
end

function CSysSettingView.OnLockScreenBtn(self, oBtn)
	--printc("系统设置界面，锁定屏幕 clicked")
	self:CloseView()
	CLockScreenView:ShowView()
end

function CSysSettingView.OnSwitchAccountBtn(self, oBtn)
	--printc("系统设置界面，切换帐号 clicked")
	self:CloseView()
	g_LoginCtrl:Logout()
end

function CSysSettingView.OnUpdateGongGaoBtn(self, oBtn)
	--printc("系统设置界面，更新公告 clicked")
	CLoginNoticeView:ShowView()
end

function CSysSettingView.OnUpdateYuyinBtn(self, oBtn)
	g_NotifyCtrl:FloatMsg("已经是最新语音包")
end

function CSysSettingView.OnQuitGameBtn(self, oBtn)
	if g_SdkCtrl:IsSupportService() then
		g_SdkCtrl:OpenService()
	else
		Utils.QuitGame()
	end
end

function CSysSettingView.OnSolveBtn(self, oBtn)
	--printc("系统设置界面，解决卡机 clicked")
	if g_WarCtrl:IsWar() then
		local windowConfirmInfo = {
			msg = "解决卡机将消耗5000金币，若金币不足则扣剩0金币\n是否确定进行本操作",
			title = "提示",
			okCallback = function () 
				g_WarCtrl:End()
				netwar.C2GSSolveKaji()
				g_SysSettingCtrl:SetSolveKaJiEnabled(true)
			end,
			okStr = "确定",
			cancelStr = "取消",
			countdown = 30,
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
		self:CloseView()
	else
		g_NotifyCtrl:FloatMsg("战斗场景点击可解决卡机")
	end
end

function CSysSettingView.ReverseFloatingNumber(self, number) -- 现在保留两位小数
	return number - number % 0.01
end

function CSysSettingView.OnMusicCheckSprite(self, oSprite)
	local isChecked = oSprite:GetSelected()
	--printc(string.format("系统设置音乐：isChecked = %s", tostring(isChecked)))
	g_SysSettingCtrl:SaveLocalSettings("music_enabled", isChecked)
	g_AudioCtrl:CheckAuidoAll()
end

function CSysSettingView.OnMusicSliderChanged(self, oSlider)
	local percentage = oSlider:GetValue()
	percentage = self:ReverseFloatingNumber(percentage)
	--printc(string.format("系统设置音乐大小：percentage = %s", percentage))
	g_SysSettingCtrl:SaveLocalSettings("music_percentage", percentage)
	g_AudioCtrl:CheckAuidoAll()
end

function CSysSettingView.OnSoundEffectCheckSprite(self, oSprite)
	local isChecked = oSprite:GetSelected()
	--printc(string.format("系统设置音效：isChecked = %s", tostring(isChecked)))
	g_SysSettingCtrl:SaveLocalSettings("sound_effect_enabled", isChecked)
	g_AudioCtrl:CheckAuidoAll()
end

function CSysSettingView.OnSoundEffectSliderChanged(self, oSlider)
	local percentage = oSlider:GetValue()
	percentage = self:ReverseFloatingNumber(percentage)
	--printc(string.format("系统设置音效大小：percentage = %s", percentage))
	g_SysSettingCtrl:SaveLocalSettings("sound_effect_percentage", percentage)
	g_AudioCtrl:CheckAuidoAll()
end

function CSysSettingView.OnDubbingCheckSprite(self, oSprite)
	local isChecked = oSprite:GetSelected()
	--printc(string.format("系统设置配音：isChecked = %s", tostring(isChecked)))
	g_SysSettingCtrl:SaveLocalSettings("dubbing_enabled", isChecked)
	g_AudioCtrl:CheckAuidoAll()
end

function CSysSettingView.OnDubbingSliderChanged(self, oSlider)
	local percentage = oSlider:GetValue()
	percentage = self:ReverseFloatingNumber(percentage)
	--printc(string.format("系统设置配音大小：percentage = %s", percentage))
	g_SysSettingCtrl:SaveLocalSettings("dubbing_percentage", percentage)
	g_AudioCtrl:CheckAuidoAll()
end

function CSysSettingView.OnZoomlensCheckSprite(self, oSprite)
	local isChecked = oSprite:GetSelected()
	--printc(string.format("系统设置镜头缩放：isChecked = %s", tostring(isChecked)))
	g_SysSettingCtrl:SaveLocalSettings("zoomlens_enabled", isChecked)
end

function CSysSettingView.OnHidePlayerCheckSprite(self, oSprite)
	local isChecked = oSprite:GetSelected()
	--printc(string.format("系统设置镜头缩放：isChecked = %s", tostring(isChecked)))
	g_SysSettingCtrl:SaveLocalSettings("hideplayer_enabled", isChecked)
	g_MapCtrl:SysCtrlCheckHidePlayer(isChecked)
end

return CSysSettingView