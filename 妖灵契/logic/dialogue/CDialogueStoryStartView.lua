
local CDialogueStoryStartView = class("CDialogueStoryStartView", CViewBase)

function CDialogueStoryStartView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Dialogue/DialogueStoryStartView.prefab", cb)
	self.m_CloseCB = nil
	self.m_CanContinue = false
	self.m_CanContinueTimer = nil
	self.m_ShowContentTimer = nil
	self.m_IsFadeOut = false
	
	--界面设置
	self.m_DepthType = "WindowTip"
	self.m_GroupName = "main"
	self.m_SwitchSceneClose = false	
end

function CDialogueStoryStartView.OnCreateView(self)
	self.m_CheckBox = self:NewUI(1, CBox)
	self.m_CenterMapTextrue = self:NewUI(2, CTexture)
	self.m_TitleLabel = self:NewUI(3, CLabel)
	self.m_ContenLabel = self:NewUI(4, CLabelWriteEffect)
	self.m_ContenLabel.m_UpdateDelta = 0.2
	self.m_CenterWidget = self:NewUI(5, CBox)
	self.m_RBWidget = self:NewUI(6, CBox)
	self.m_ContinueLabel = self:NewUI(7, CLabel)
	self.m_BgTexture = self:NewUI(8, CTexture)
	self.m_Container = self:NewUI(9, CWidget)
	self.m_BgTexture.m_Tween = self.m_BgTexture:GetComponent(classtype.TweenAlpha)
	self.m_TitleLabel.m_Tween = self.m_TitleLabel:GetComponent(classtype.TweenAlpha)
	--self.m_ContenLabel.m_Tween = self.m_ContenLabel:GetComponent(classtype.TweenAlpha)
	UITools.ResizeToRootSize(self.m_Container)
	self:InitContent()

	--5秒自动关闭
	self:DelayCall(5, "OnContinue")
end

function CDialogueStoryStartView.InitContent(self)
	self.m_CheckBox:AddUIEvent("click", callback(self, "OnContinue"))
end

function CDialogueStoryStartView.SetContent(self, storyData, cb)
	self.m_StoryData = storyData
	self.m_CloseCB = cb
	self:RefreshAll()
end

function CDialogueStoryStartView.RefreshAll(self)
	if not self.m_StoryData then
		return
	end
	local mapId = self.m_StoryData.mapId
	if mapId and mapId  ~= 1 then		
		if mapId == 0 then
			mapId = g_MapCtrl:GetMapID()
		end		
		if mapId then
			local path = string.format("Texture/Map/mask_map_%d.jpg", mapId)		
			self.m_CenterMapTextrue:LoadPath(path)		
		else
			self.m_CenterMapTextrue:SetMainTextureNil()		
		end
		
	else
		self.m_CenterMapTextrue:SetMainTextureNil()	
	end	

	if self.m_StoryData.content then

		local list = string.split(self.m_StoryData.content, ",")
		if list and #list == 2 then
			self.m_TitleLabel:SetText(list[1])
			self.m_ContenLabel.Text = list[2]
		end
	end
	self.m_CanContinue = false
	self.m_ContinueLabel:SetActive(false)	
	self.m_BgTexture.m_Tween:Toggle()
	local config = 
	{
		FinishCallBack = function ()
			if not Utils.IsNil(self) then
				self.m_CanContinue = true
				self.m_ContinueLabel:SetActive(true)
			end			
		end,
	}
	self.m_ContenLabel:InitLabel(config)

	if self.m_StoryData.show_content_time > 0 then
		self.m_TitleLabel:SetActive(false)		
		self.m_ContenLabel:SetActive(false)
		local function wrap()
			self.m_TitleLabel:SetActive(true)	
			self.m_TitleLabel.m_Tween:Toggle()			
			self.m_ContenLabel:SetActive(true)	
			self.m_ContenLabel:SetEffectText(self.m_ContenLabel.Text)
			--self.m_ContenLabel:SetActive(true)
			--self.m_ContenLabel.m_Tween:Toggle()
		end
		if self.m_ShowContentTimer ~= nil then
			Utils.DelTimer(self.m_ShowContentTimer)
			self.m_ShowContentTimer = nil
		end
		self.m_ShowContentTimer = Utils.AddTimer(wrap, 0, self.m_StoryData.show_content_time)
	else
		self.m_TitleLabel:SetActive(true)		
		self.m_ContenLabel:SetActive(true)
		self.m_ContenLabel:SetText(self.m_ContenLabel.Text)
		self.m_CanContinue = true
		self.m_ContinueLabel:SetActive(true)			
	end

	-- if self.m_StoryData.delay_time > 0 then
	-- 	self.m_CanContinue = false
	-- 	self.m_ContinueLabel:SetActive(false)		
	-- 	local function wrap()
	-- 		self.m_CanContinue = true
	-- 		self.m_ContinueLabel:SetActive(true)
	-- 	end
	-- 	if self.m_CanContinueTimer ~= nil then
	-- 		Utils.DelTimer(self.m_CanContinueTimer)
	-- 		self.m_CanContinueTimer = nil
	-- 	end
	-- 	self.m_CanContinueTimer = Utils.AddTimer(wrap, 0, self.m_StoryData.delay_time)
	-- else
	-- 	self.m_CanContinue = true
	-- 	self.m_ContinueLabel:SetActive(true)
	--end
end

function CDialogueStoryStartView.OnContinue(self)
	if not Utils.IsNil(self) and self.m_CanContinue == true then
		if self.m_IsFadeOut == false  then
			self.m_IsFadeOut = true
			self.m_TitleLabel:SetActive(false)
			self.m_ContenLabel:SetActive(false)
			self.m_ContinueLabel:SetActive(false)
			self.m_AlphaAction1 = CActionFloat.New(self.m_BgTexture, 1, "SetAlpha", 1, 0)
	   		self.m_AlphaAction1:SetEndCallback(callback(self, "FadeOutClose"))
	   		g_ActionCtrl:AddAction(self.m_AlphaAction1)
	   		self.m_AlphaAction2 = CActionFloat.New(self.m_CenterMapTextrue, 1, "SetAlpha", 1, 0)
	   		g_ActionCtrl:AddAction(self.m_AlphaAction2)
		end
	end
end

function CDialogueStoryStartView.FadeOutClose(self)
	self:CloseView()
	g_DialogueCtrl:SetPlayStoryState(false)
end

function CDialogueStoryStartView.Destroy(self)	
	if self.m_CanContinueTimer ~= nil then
		Utils.DelTimer(self.m_CanContinueTimer)
		self.m_CanContinueTimer = nil
	end
	if self.m_ShowContentTimer ~= nil then
		Utils.DelTimer(self.m_ShowContentTimer)
		self.m_ShowContentTimer = nil
	end		
	CViewBase.Destroy(self)
end

return CDialogueStoryStartView