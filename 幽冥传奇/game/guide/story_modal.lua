--------------------------------------------------
--剧情模态（播放剧情时，上面放一层，防止操作）
--------------------------------------------------
StoryModal = StoryModal or BaseClass(XuiBaseView)
function StoryModal:__init()
	if StoryModal.Instance then
		ErrorLog("[StoryModal] Attemp to create a singleton twice !")
	end
	StoryModal.Instance = self

	self.texture_path_list[1] = 'res/xui/story.png'

	self.dialog_end_callback = nil
	self.skip_call_back = nil
	self.zodaer = COMMON_CONSTS.ZORDER_GUIDE

	self.skip_btn = nil
	self.is_visible = true
end

function StoryModal:__delete()
	StoryModal.Instance = nil
end

function StoryModal:CloseCallBack()
	if nil ~= self.skip_btn then
		self.skip_btn:removeFromParent()
		self.skip_btn = nil
	end
end

function StoryModal:ShowIndexCallBack()
	self:SetDialogSkipVisible(self.is_visible)
end

function StoryModal:LoadCallBack()
	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()
	self.root_node:setContentSize(cc.size(screen_w, screen_h))
	self.root_node:setPosition(0, 0)
	self.root_node:setAnchorPoint(0,0)
end

function StoryModal:OnFlush()
end

function StoryModal:SetSkipBtnVisible(is_visible)
	self.is_visible = is_visible
	self:Flush()
end

function StoryModal:SetSkipCallback(callback)
	self.skip_call_back = callback
end

function StoryModal:SkipHandler()
	self:Close()
	if self.skip_call_back ~= nil then
		self.skip_call_back()
	end
end

function StoryModal:SetDialogSkipVisible(is_visible)
	if nil == self.skip_btn and is_visible then
		local skip_path = ResPath.GetStory("skip_btn")
		self.skip_btn = XUI.CreateButton(HandleRenderUnit:GetWidth() - 122.5, HandleRenderUnit:GetHeight() - 160, 0, 0, false, skip_path, "", "", true)
		HandleRenderUnit:AddUi(self.skip_btn, COMMON_CONSTS.ZORDER_GUIDE)
		XUI.AddClickEventListener(self.skip_btn, BindTool.Bind(self.SkipHandler, self))
	else
		if nil ~= self.skip_btn then
			self.skip_btn:setVisible(is_visible)
		end
	end
end
