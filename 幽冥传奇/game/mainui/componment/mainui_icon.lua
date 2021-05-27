
MainUiIcon = MainUiIcon or BaseClass()
MainUiIcon.CountDownNum = 0

function MainUiIcon:__init(w, h)
	self.width = w or 90
	self.height = h or 90

	self.view = MainuiMultiLayout.New()
	self.icon_name = nil

	self.icon_img = nil
	self.bottom_img = nil
	self.bg_frame_img = nil

	self.remind_bg_img = nil
	self.remind_txt = nil
	self.remind_num = 0
	self.remind_txt = nil
	self.remind_txt_num = 0

	self.bottom_text = nil
	self.bottom_text_bg = nil
	self.countdown_key = nil

	self.icon_effect = nil
	self.cd_key = nil

	self.icon_txt_name = nil
	self.complete_cd_handler = nil
end

function MainUiIcon:__delete()
	self:RemoveCountDown()
	self.bottom_text = nil
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
function MainUiIcon:SetIconPath(path)
	if nil == path or "" == path then return end

	if nil == self.icon_img then
		self.icon_img = XUI.CreateImageView(self.width / 2, self.height / 2, path, true)
		self.view:TextureLayout():addChild(self.icon_img, 0, 0)
	else
		self.icon_img:loadTexture(path)
	end
end
-- 设置文字背景框
function MainUiIcon:SetBgBottomPath(path)
	if path == nil or path == "" then return end

	if self.bg_bottom_img == nil then
		y = y or 0
		self.bg_bottom_img = XUI.CreateImageView(self.width / 2, y, path, true)
		self.view:TextureLayout():addChild(self.bg_bottom_img, -1, -1)
		return
	end
	self.bg_bottom_img:loadTexture(path)
end

function MainUiIcon:SetBgBottomPathVisible(vis)
	self.bg_bottom_img:setVisible(vis)
end

-- 设置下面文字
function MainUiIcon:SetBottomPath(path, y)
	if nil == path or "" == path then return end

	if nil == self.bottom_img then
		y = y or 23
		self.bottom_img = XUI.CreateImageView(self.width / 2, y, path, true)
		self.view:TextureLayout():addChild(self.bottom_img, 1, 1)
	else
		self.bottom_img:loadTexture(path)
	end
end

-- 设置背景框
function MainUiIcon:SetBgFramePath(path)
	if path == nil or path == "" then return end

	if self.bg_frame_img == nil then
		self.bg_frame_img = XUI.CreateImageView(self.width / 2, self.height / 2, path, true)
		self.view:TextureLayout():addChild(self.bg_frame_img, -1, -1)
		return
	end
	self.bg_frame_img:loadTexture(path)
end

function MainUiIcon:GetRemindNum()
	return self.remind_num
end

function MainUiIcon:SetRemindNum(num)
	self.remind_num = num

	if nil == self.remind_bg_img then
		self.remind_bg_img = XUI.CreateImageView(self.width - 25, self.height - 19, ResPath.GetMainui("remind_flag"), true)
		self.view:TextureLayout():addChild(self.remind_bg_img, 300, 300)
	end
	self.remind_bg_img:setVisible(num > 0)
end

function MainUiIcon:IsInRemind() -- 隐藏的按钮，开关按钮显示红点
	if self.remind_bg_img then
		return self.remind_bg_img:isVisible()
	end
	return false
end

function MainUiIcon:GetRemindNumTxt()
	return self.remind_txt_num
end

function MainUiIcon:SetRemindNumTxt(num, x, y, hide_num)
	self.remind_txt_num = num
	if nil == self.remind_txt then
		self.remind_txt_bg = XUI.CreateImageView(self.width - 9, self.height - 12, ResPath.GetMainui("remind_flag_1"), true)
		self.view:TextureLayout():addChild(self.remind_txt_bg, 300, 300)
		self.remind_txt = XUI.CreateText(self.width - 10, self.height - 12, 30, 0, cc.TEXT_ALIGNMENT_CENTER, "",  COMMON_CONSTS.FONT, 18)
		self.view:TextLayout():addChild(self.remind_txt, 300, 300)
	end
	if x ~= nil and y ~= nil then
		self.remind_txt_bg:setPosition(x , y)
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

function MainUiIcon:SetIconTxtName(name, x, y, color,is_show_bg)
	if nil == self.icon_txt_name then
		self.icon_text_bg = XUI.CreateImageViewScale9(self.width / 2, 0,self.width-15,25,ResPath.GetMainui("text_bg_1"),true,cc.rect(10,5,20,20))
		self.view:TextureLayout():addChild(self.icon_text_bg)
		self.icon_text_bg:setVisible(false)
		self.icon_txt_name = XUI.CreateText(self.width / 2, 0, 80, 0, cc.TEXT_ALIGNMENT_CENTER, "",  COMMON_CONSTS.FONT, 16)
		XUI.EnableOutline(self.icon_txt_name)
		self.view:TextLayout():addChild(self.icon_txt_name, 310, 310)
		self.icon_txt_name:setColor(color or COLOR3B.WHITE)
	end
	if x ~= nil and y ~= nil then
		self.icon_txt_name:setPosition(x, y)
		self.icon_text_bg:setPosition(x, y)
	end
	
	self.icon_txt_name:setString(name)
	self.icon_text_bg:setVisible(is_show_bg or false)

end

function MainUiIcon:AddClickEventListener(click_callback)
	self.view:AddClickEventListener(click_callback)
end

function MainUiIcon:RemoveCountDown()
	if nil ~= self.countdown_key and CountDownManager.Instance:HasCountDown(self.countdown_key) then
		CountDownManager.Instance:RemoveCountDown(self.countdown_key)
		self.countdown_key = nil
	end
end

function MainUiIcon:SetBottomContent(content)
	if nil == self.bottom_text then
		self.bottom_text_bg = XUI.CreateImageViewScale9(self.width / 2, 0,self.width-15,25,ResPath.GetMainui("text_bg_1"),true,cc.rect(10,5,20,20))
		self.view:TextureLayout():addChild(self.bottom_text_bg)
		self.bottom_text_bg:setVisible(false)
		self.bottom_text = XUI.CreateText(self.width / 2, 0, 0, 0, cc.TEXT_ALIGNMENT_LEFT, content, nil, 16, COLOR3B.WHITE)
		XUI.EnableOutline(self.bottom_text)
		self.view:TextLayout():addChild(self.bottom_text)
	else
		self.bottom_text:setString(content)
	end
end

function MainUiIcon:SetBottomBgVisible(v)
	self.bottom_text_bg:setVisible(v)
end	

function MainUiIcon:SetBuTTomTextPos(x, y)
	self.bottom_text:setPosition(x,y)
end

function MainUiIcon:SetBottomContentColor(c3b)
	self.bottom_text:setColor(c3b)
end	

function MainUiIcon:SetBottomContentSetVisible(vis)
	self.bottom_text:setVisible(vis)
end

--设置剩余时间 秒
function MainUiIcon:SetEndTime(end_time, countdown_update_callback, coundown_complete_callback)
	if nil == self.countdown_key then
		MainUiIcon.CountDownNum = MainUiIcon.CountDownNum + 1
		self.countdown_key = "icon_countdown" .. MainUiIcon.CountDownNum
	end

	local update_fun = function(elapse_time, total_time)
		local time_str = CountDownManager.Instance:GetRemainSecond2MS(self.countdown_key)
		self:SetBottomContent(time_str)

		if nil ~= countdown_update_callback then
			countdown_update_callback(CountDownManager.Instance:GetRemainTime(self.countdown_key))
		end
	end

	local complete_fun = function()
		self.countdown_key = nil

		if nil ~= coundown_complete_callback then
			coundown_complete_callback()
		end
	end

	update_fun()

	CountDownManager.Instance:AddCountDown( self.countdown_key, update_fun, complete_fun, end_time, nil, 0.5)
end

function MainUiIcon:SetCDTime(end_time, scale)
	if self.cd_end_time ~= end_time then
		self.cd_end_time = end_time

		if not self.cd_bar then
			local sprite = XUI.CreateSprite(ResPath.GetSkillIcon("skill_mask"))
			self.cd_bar = cc.ProgressTimer:create(sprite)
			self.cd_bar:setScale(scale or 1)
			self.cd_bar:setType(0)
			self.cd_bar:setPercentage(100)
			self.cd_bar:setReverseDirection(true)
			self.cd_bar:setPosition(self.width * 0.5, self.height * 0.5)
			self.view:EffectLayout():addChild(self.cd_bar)
		end	
		self.cd_bar:setVisible(true)

		if end_time > Status.NowTime then
			if self.cd_key == nil then
				MainUiIcon.CountDownNum = MainUiIcon.CountDownNum + 1
				self.cd_key = "main_icon_cd" .. MainUiIcon.CountDownNum
			end	
			self.cd_bar:setVisible(true)

			end_time = end_time - Status.NowTime
			CountDownManager.Instance:AddCountDown(self.cd_key, BindTool.Bind(self.UpdateCD, self), 
				BindTool.Bind(self.CompleteCd, self), nil, end_time, 0.05)
		else
			self.cd_bar:setVisible(false)
			CountDownManager.Instance:RemoveCountDown(self.cd_key)
		end
	end
end	

function MainUiIcon:IsInCD()
	return self.cd_bar and self.cd_bar:isVisible()
end	

function MainUiIcon:UpdateCD(elapse_time, total_time)
	self.cd_bar:setPercentage((1 - elapse_time / total_time) * 100)
end

function MainUiIcon:CompleteCd()
	self.cd_bar:setVisible(false)
	self.cd_bar:setPercentage(0)
	if self.complete_cd_handler then
		self.complete_cd_handler()
	end
end

function MainUiIcon:SetCompleteCdDoHandler(complete_handler)
	self.complete_cd_handler = complete_handler
end

function MainUiIcon:PlayIconEffect(effect_id, anim_pos, loop, is_top_layer)
	if nil == self.icon_effect then
		self.icon_effect = AnimateSprite:create()
		if is_top_layer then
			self.view:EffectLayout():addChild(self.icon_effect, 0)
		else
			self.view:BgEffectLayout():addChild(self.icon_effect, 0)
		end
	end

	anim_pos = anim_pos or {x = self.width / 2, y = self.height / 2}
	self.icon_effect:setPosition(anim_pos)

	local path, name = ResPath.GetEffectUiAnimPath(effect_id)
	self.icon_effect:setAnimate(path, name, loop or COMMON_CONSTS.MAX_LOOPS, 0.17, false)
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

function MainUiIcon:SetEnabled(v)
	self.view:SetEnabled(v)
	self.SetGrey(v)
end	

function MainUiIcon:SetGrey(v)
	if self.icon_img then
		self.icon_img:setGrey(not v)
	end	

	if self.bottom_img then
		self.bottom_img:setGrey(not v)
	end	
end	

--方法迁移到类静态方法,方便全局使用，而不需要每个类都定义一次方法
function MainUiIcon:CreateMainuiIcon(parent, res, data)
	local icon = MainUiIcon.New()
	icon:Create(parent)
	icon:SetData(data)
	icon:SetBgFramePath(ResPath.GetMainui("icon_bg"))
	-- icon:SetBgBottomPath(ResPath.GetMainui("icon_bg_1"))
	icon:SetIconPath(ResPath.GetMainui(string.format("icon_%s_img", res)))
	icon:SetBottomPath(ResPath.GetMainui(string.format("icon_%s_word", res)))
	return icon
end

--方法迁移到类静态方法,方便全局使用，而不需要每个类都定义一次方法,创建只有背景和一张图片的icon
function MainUiIcon:CreateSimpleMainuiIcon(parent, res, data)
	local icon = MainUiIcon.New()
	icon:Create(parent)
	icon:SetData(data)
	icon:SetBgFramePath(ResPath.GetMainui("icon_bg"))
	-- icon:SetBgBottomPath(ResPath.GetMainui("icon_bg_1"))
	icon:SetIconPath(ResPath.GetMainui(string.format("%s", res)))
	return icon
end

function MainUiIcon:CreateMainuiIcon1(parent, res, data)
	local icon = MainUiIcon.New()
	icon:Create(parent)
	icon:SetData(data)
	icon:SetBgFramePath(ResPath.GetMainui("switch_1"))
	--icon:SetBgBottomPath(ResPath.GetMainui("icon_text_bg"))
	icon:SetIconPath(ResPath.GetMainui(string.format("icon_%s_img", res)))
	icon:SetBottomPath(ResPath.GetMainui(string.format("icon_%s_word", res)))
	return icon
end
function MainUiIcon:CreateMainuiIcon2(parent, res, data)
	local icon = MainUiIcon.New()
	icon:Create(parent)
	icon:SetData(data)
	-- icon:SetBgFramePath(ResPath.GetMainui("switch_1"))
	--icon:SetBgBottomPath(ResPath.GetMainui("icon_text_bg"))
	icon:SetIconPath(ResPath.GetMainui(string.format("icon_%s_img", res)))
	-- icon:SetBottomPath(ResPath.GetMainui(string.format("icon_%s_word", res)))
	return icon
end
function MainUiIcon:CreateMainuiIcon4(parent, res, data)
	local icon = MainUiIcon.New()
	icon:Create(parent)
	icon:SetData(data)
	icon:SetIconPath(ResPath.GetMainui2(res))
	return icon
end

function MainUiIcon:CreateMainuiIcon3(parent, res, data)
	local icon = MainUiIcon.New()
	icon:Create(parent)
	icon:SetData(data)
	icon:SetBgFramePath(ResPath.GetMainui("icon_bg"))
	--icon:SetBgBottomPath(ResPath.GetMainui("icon_text_bg"))
	icon:SetIconPath(ResPath.GetMainui(string.format("icon_%s_img", res)))
	-- icon:SetBottomPath(ResPath.GetMainui(string.format("icon_%s_word", res)))
	return icon
end
