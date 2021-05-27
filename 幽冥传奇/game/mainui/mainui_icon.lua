
MainUiIcon = MainUiIcon or BaseClass()

function MainUiIcon:__init(w, h)
	self.width = w or 90
	self.height = h or 90

	self.view = MainuiMultiLayout.New()
	self.icon_name = nil

	self.icon_img = nil
	self.bottom_img = nil
	self.bg_frame_img = nil

	self.remind_num = 0
	self.remind_bg_img = nil

	self.remind_txt_num = 0
	self.remind_txt_bg = nil
	self.remind_txt = nil

	self.bottom_text = nil

	self.icon_effect = nil
end

function MainUiIcon:__delete()
end

function MainUiIcon:GetView()
	return self.view
end

function MainUiIcon:Create(multi_layout)
	self.view:CreateByMultiLayout(multi_layout)
	self.view:setContentSize(cc.size(self.width, self.height))
end

function MainUiIcon:SetIconName(name)
	self.icon_name = name
end

function MainUiIcon:GetIconName()
	return self.icon_name
end

function MainUiIcon:GetData()
	return self.view:GetData()
end

function MainUiIcon:SetData(data)
	self.view:SetData(data)
end

function MainUiIcon:GetIconImg()
	return self.icon_img
end

-- 设置图标
function MainUiIcon:SetIconPath(path, x, y)
	if nil == path or "" == path then return end

	if nil == self.icon_img then
		self.icon_img = XUI.CreateImageView(x or self.width / 2, y or self.height / 2, path, true)
		self.view:TextureLayout():addChild(self.icon_img, 10, 10)
	else
		self.icon_img:loadTexture(path)
	end
end


function MainUiIcon:SetButtomPath(path, x, y)
	if nil == path or "" == path then return end

	if nil == self.bottom_img then
		self.bottom_img = XUI.CreateImageView(x or self.width / 2, y or 20, path, true)
		self.view:TextureLayout():addChild(self.bottom_img, 10, 10)
	else
		self.bottom_img:loadTexture(path)
	end
end

function MainUiIcon:SetIconImg(path)
	self.icon_img:loadTexture(path)
end

-- 设置下面文字
function MainUiIcon:SetBottomPath(path, y)
	-- if nil == path or "" == path then return end

	-- if nil == self.bottom_img then
	-- 	y = y or 20
	-- 	self.bottom_img = XUI.CreateImageView(self.width / 2, y, path, true)
	-- 	self.view:TextureLayout():addChild(self.bottom_img, 30, 30)
	-- else
	-- 	self.bottom_img:loadTexture(path)
	-- end
end

-- 设置背景框
function MainUiIcon:SetBgFramePath(path, x, y)
	-- if path == nil or path == "" then return end

	-- if self.bg_frame_img == nil then
	-- 	self.bg_frame_img = XUI.CreateImageView(x or self.width / 2, y or self.height / 2, path, true)
	-- 	self.view:TextureLayout():addChild(self.bg_frame_img, 1, 1)
	-- else
	-- 	self.bg_frame_img:loadTexture(path)
	-- end
end

function MainUiIcon:GetRemindNum()
	return self.remind_num
end

function MainUiIcon:SetRemindNum(num, x, y, scale)
	self.remind_num = num
	if nil == self.remind_bg_img then
		self.remind_bg_img = XUI.CreateImageView(x or (self.width - 19), y or (self.height - 19), ResPath.GetMainui("remind_flag"), true)
		-- CommonAction.ShowRemindBlinkAction(self.remind_bg_img)
		self.view:TextureLayout():addChild(self.remind_bg_img, 300, 300)
	end
	self.remind_bg_img:setVisible(num > 0)
end

function MainUiIcon:GetRemindNumTxt()
	return self.remind_txt_num
end

function MainUiIcon:SetRemindNumTxt(num, x, y, hide_num)
	self.remind_txt_num = num
	if nil == self.remind_txt then
		self.remind_txt_bg = XUI.CreateImageView(self.width - 9, self.height - 12, ResPath.GetCommon("remind_bg_1"), true)
		self.view:TextureLayout():addChild(self.remind_txt_bg, 300, 300)
		self.remind_txt = XUI.CreateText(self.width - 10, self.height - 10, 30, 18, cc.TEXT_ALIGNMENT_CENTER, "",  COMMON_CONSTS.FONT, 18)
		self.view:TextLayout():addChild(self.remind_txt, 300, 300)
	end
	if x ~= nil and y ~= nil then
		self.remind_txt_bg:setPosition(x + 1, y - 2)
		self.remind_txt:setPosition(x, y)
	end
	if type(num) == "number" then
		hide_num = hide_num or 1
		if num > 99 then num = 99 end
		self.remind_txt:setString(tostring(num))
		self.remind_txt:setVisible(num > hide_num)
		self.remind_txt_bg:setVisible(num > hide_num)
	else
		self.remind_txt:setVisible(true)
		self.remind_txt_bg:setVisible(true)
		self.remind_txt:setString(num)
	end
end

function MainUiIcon:AddClickEventListener(click_callback)
	self.view:AddClickEventListener(click_callback)
end

function MainUiIcon:SetBottomContent(content)
	if nil == self.bottom_text then
		self.bottom_text = XUI.CreateRichText(self.width / 2, -5, 200, 20, false)
		XUI.RichTextSetCenter(self.bottom_text)
		self.view:TextLayout():addChild(self.bottom_text)
	end
	RichTextUtil.ParseRichText(self.bottom_text, content, nil, nil, nil, nil, nil, nil, nil, {outline_size = 1})
end


function MainUiIcon:SetRingthContent(content, color)
	if nil == self.right_text then
		self.right_text = XUI.CreateRichText(self.width - 30, self.height - 30, 200, 20, false)
		XUI.RichTextSetCenter(self.right_text)
		self.view:TextLayout():addChild(self.right_text)
	end
	RichTextUtil.ParseRichText(self.right_text, content, nil, color, nil, nil, nil, nil, nil, {outline_size = 1})
end


function MainUiIcon:SetTopContent(content, color)
	if nil == self.top_text then
		self.top_text = XUI.CreateRichText(self.width / 2, 20, 200, 20, false)
		XUI.RichTextSetCenter(self.top_text)
		self.view:TextLayout():addChild(self.top_text)
	end
	RichTextUtil.ParseRichText(self.top_text, content, nil, color, nil, nil, nil, nil, nil, {outline_size = 1})
end

function MainUiIcon:PlayIconEffect(effect_id, anim_pos, loop, scale)
	if nil == self.icon_effect then
		self.icon_effect = AnimateSprite:create()
		self.view:EffectLayout():addChild(self.icon_effect)
	end

	anim_pos = anim_pos or {x = self.width / 2, y = self.height / 2}
	self.icon_effect:setPosition(anim_pos)

	local path, name = ResPath.GetEffectUiAnimPath(effect_id)
	self.icon_effect:setAnimate(path, name, loop or COMMON_CONSTS.MAX_LOOPS, 0.17, false)
	if scale then
		self.icon_effect:setScale(scale)
	end
end

function MainUiIcon:RemoveIconEffect()
	if nil ~= self.icon_effect then
		self.icon_effect:removeFromParent()
		self.icon_effect = nil
	end
end

function MainUiIcon:SetPosition(x, y)
	self.view:setPosition(x, y)
end

function MainUiIcon:GetPosition()
	return self.view:getPosition()
end

function MainUiIcon:SetPositionX(x)
	self.view:setPositionX(x)
end

function MainUiIcon:SetPositionY(y)
	self.view:setPositionY(y)
end

function MainUiIcon:SetRoTaTion(angle )
	self.view:setRotation(angle)
end

function MainUiIcon:GetContentSize()
	return cc.size(self.width, self.height)
end

function MainUiIcon:SetContentSize(size)
	self.width = size.width
	self.height = size.height
	self.view:setContentSize(size)
end

function MainUiIcon:SetScale(scale)
	self.view:setScale(scale)
end

function MainUiIcon:IsVisible()
	return self.view:isVisible()
end

function MainUiIcon:SetVisible(is_visible)
	self.view:setVisible(is_visible)
end

function MainUiIcon:GetOpacity()
	return self.view:getOpacity()
end

function MainUiIcon:SetOpacity(opacity)
	self.view:setOpacity(opacity)
end


function MainUiIcon:SetGrey(vis)
	if nil ~= self.icon_img then
		XUI.MakeGrey(self.icon_img, vis)
	end
end

function MainUiIcon:CreateMainuiIcon(parent,res, x, y)
	local icon = MainUiIcon.New()
	icon:Create(parent)
	icon:SetPosition(x, y)
	icon:SetIconPath(ResPath.GetMainui(string.format("icon_%s_img", res)))
	return icon
end


function MainUiIcon:CreateMainuiIcon1(parent,res, x, y)
	local icon = MainUiIcon.New()
	icon:Create(parent)
	icon:SetPosition(x, y)
	icon:SetIconPath(res)
	return icon
end