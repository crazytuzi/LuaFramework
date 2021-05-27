ChannelSelectView = ChannelSelectView or BaseClass(XuiBaseView)

function ChannelSelectView:__init()
	self:SetIsAnyClickClose(true)
	if ChannelSelectView.Instance then
		ErrorLog("[ChannelSelectView]:Attempt to create singleton twice!")
	end
	ChannelSelectView.Instance = self
end

function ChannelSelectView:__delete()
	ChannelSelectView.Instance = self
end

function ChannelSelectView:ReleaseCallBack()

end

function ChannelSelectView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		local screen_w = HandleRenderUnit:GetWidth()
		local screen_h = HandleRenderUnit:GetHeight()
		local btn_t = {
			CHANNEL_TYPE.NEAR, 
			CHANNEL_TYPE.WORLD, 
			CHANNEL_TYPE.GUILD, 
			CHANNEL_TYPE.TEAM, 
			CHANNEL_TYPE.PRIVATE, 
			CHANNEL_TYPE.SPEAKER}
		-- if IS_ON_CROSSSERVER then
		-- 	btn_t = {
		-- 	CHANNEL_TYPE.NEAR, 
		-- 	-- CHANNEL_TYPE.WORLD, 
		-- 	CHANNEL_TYPE.GUILD, 
		-- 	CHANNEL_TYPE.TEAM, 
		-- 	CHANNEL_TYPE.PRIVATE, 
		-- 	CHANNEL_TYPE.SPEAKER}
		-- end
		self.root_node:setPosition(screen_w / 2 - 395, screen_h / 2 - 240)
		self.root_node:setContentWH(160, #btn_t * 60 + 10)
		self.root_node:setAnchorPoint(0.5, 0)
		self.bg = XUI.CreateImageViewScale9(80, 0, 140, #btn_t * 60 + 30, ResPath.GetCommon("img9_203"), true)
		self.bg:setAnchorPoint(0.5, 0)
		self.root_node:addChild(self.bg)
		for k,v in ipairs(btn_t) do
			local btn = XUI.CreateButton(80, k * 60 - 16, 0, 0, false, ResPath.GetCommon("toggle_119_normal"), "", "", true)
			btn:setTitleFontSize(24)
			btn:setTitleFontName(COMMON_CONSTS.FONT)
			btn:setTitleText(Language.Chat.Channel[v])
			btn:setTitleColor(cc.c3b(217, 212, 194))
			self.root_node:addChild(btn)
			btn:addClickEventListener(BindTool.Bind(self.Changechannel, self, v))
		end
	end
end

function ChannelSelectView:Changechannel(channel)
	if self.call_back then
		self.call_back(channel)
	end
	self:Close()
end
function ChannelSelectView:OpenSelectChannel(call_back)
	self.call_back = call_back
	self:Open()
end

function ChannelSelectView:ShowIndexCallBack(index)
	self:Flush(index)
end
	
function ChannelSelectView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ChannelSelectView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end


function ChannelSelectView:OnFlush(param_t, index)
	
end