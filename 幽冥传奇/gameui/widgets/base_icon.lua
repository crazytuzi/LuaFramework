----------------------------------------------
--基础图标，对游戏中图标常带的功能进行封装
--支持图标上显示提醒数量，图标倒计时，图标上播放特效等
--@author bzw
-----------------------------------------------
BaseIcon = BaseIcon or BaseClass()

BaseIcon.CountDownNum = 0

function BaseIcon:__init()
	self.width = 90
	self.height = 90

	self.icon_name = nil
	self.view = XUI.CreateLayout(0, 0, 90, 90)
	self.view:setAnchorPoint(0.5, 0.5)

	self.icon = XImage:create()
	self.view:addChild(self.icon)
	self.icon:setTouchEnabled(true)

	self.pe_x = self.width / 2 		--粒子特效x
	self.pe_y = self.height / 2 	--粒子特效y
	self.pe_plies = 3 				--层数

	self.pe_scale = 1 				--粒子特效大小

	self.remind_bg_sprite = nil
	self.remind_txt = nil

	self.bottom_rtxt = nil
	self.bottom_img = nil

	self.countdown_key = nil
	self.countdown_update_callback = nil
	self.coundown_complete_callback = nil

	self.icon_effect = nil
	self.icon_effect2 = nil

	self.data = nil

	self.view_touch_enabled = true
	self.remind_num = 0

	self.effect_visible_list = {}
end

function BaseIcon:__delete()
	-- if nil ~= self.countdown_key then 
	-- 	CountDownManager.Instance:RemoveCountDown(self.countdown_key)
	-- 	self.countdown_key = nil
	-- end
end

--设置view是否可点击
function BaseIcon:SetViewTouchEnabled(value)
	self.icon:setTouchEnabled(not value)
	self.view:setTouchEnabled(value)
	self.view_touch_enabled = value
end

function BaseIcon:GetView()
	return self.view
end

--对点击事件进行监听，请用该对象
function BaseIcon:GetUiImage()
	return self.icon
end

function BaseIcon:SetPosition(x, y)
	self.view:setPosition(x, y)
end

function BaseIcon:SetPositionX(x)
	self.view:setPositionX(x)
end

function BaseIcon:SetPositionY(y)
	self.view:setPositionY(y)
end

function BaseIcon:SetScale(scale)
	self.view:setScale(scale)
end

function BaseIcon:SetVisible(value)
	self.view:setVisible(value)
end

function BaseIcon:IsVisible()
	return self.view:isVisible()
end

function BaseIcon:SetOpacity(opacity)
	self.view:setOpacity(opacity)

	--令其点击失效
	if opacity == 0 then
		self.icon:setTouchEnabled(false)
		self.view:setTouchEnabled(false)
	else
		self:SetViewTouchEnabled(self.view_touch_enabled)
	end
end

function BaseIcon:GetOpacity()
	return self.view:getOpacity()
end

function BaseIcon:SetData(data)
	self.data = data
end

function BaseIcon:GetData(data)
	return self.data
end

--设置图标名字。名字从BaseIconName表中取
function BaseIcon:SetIconName(icon_name)
	self.icon_name = icon_name
end

--获得图标名字
function BaseIcon:GetIconName()
	return self.icon_name
end

function BaseIcon:GetContentSize()
	return cc.size(self.width, self.height)
end

--设置图标路径
function BaseIcon:SetIconPath(path)
	self.icon:loadTexture(path, true)
	local size = self.icon:getContentSize()
	self.width, self.height = size.width, size.height

	self.view:setContentSize(size)
	self.icon:setPosition(self.width / 2 , self.height /2)
end

function BaseIcon:MakeGrey(boolean)
	if nil ~= self.icon then
		self.icon:setGrey(boolean)
	end
	if nil ~= self.bottom_img then
		self.bottom_img:setGrey(boolean)
	end
end

--设置提醒数量
function BaseIcon:SetRemindNum(num)
	self.remind_num = num

	if nil == self.remind_bg_sprite then
		self.remind_bg_sprite = XUI.CreateImageView(self.width - 15,self.height - 15, ResPath.GetCommon("remind_1"), true)
		self.view:addChild(self.remind_bg_sprite, 1, 1)
	end

	if num < 10 then
		self.remind_bg_sprite:loadTexture(ResPath.GetCommon("remind_1"))
	else
		self.remind_bg_sprite:loadTexture(ResPath.GetCommon("remind_2"))
	end

	if nil == self.remind_txt then
		self.remind_txt = XUI.CreateText(self.width - 15, self.height - 15, 30, 18, cc.TEXT_ALIGNMENT_CENTER, "",  COMMON_CONSTS.FONT, 18)
		self.view:addChild(self.remind_txt, 1, 1)
	end

	if num > 99 then num = 99 end
	self.remind_txt:setString(tostring(num))
	self.remind_bg_sprite:setVisible(num > 0)
	self.remind_txt:setVisible(num > 0)
end

function BaseIcon:GetRemindNum()
	return self.remind_num
end

--设置剩余时间 秒
function BaseIcon:SetEndTime(end_time, countdown_update_callback, coundown_complete_callback)
	-- if nil == self.countdown_key then
	-- 	BaseIcon.CountDownNum = BaseIcon.CountDownNum + 1
	-- 	self.countdown_key = "icon_countdown" .. BaseIcon.CountDownNum
	-- end

	-- local update_fun = function(elapse_time, total_time)
	-- 	local time_str = CountDownManager.Instance:GetRemainSecond2MS(self.countdown_key)
	-- 	self:SetBottomContent(time_str)

	-- 	if nil ~= countdown_update_callback then
	-- 		countdown_update_callback(CountDownManager.Instance:GetRemainTime(self.countdown_key))
	-- 	end
	-- end

	-- local complete_fun = function()
	-- 	CountDownManager.Instance:RemoveCountDown(self.countdown_key)

	-- 	if nil ~= coundown_complete_callback then
	-- 		coundown_complete_callback()
	-- 	end
	-- end

	-- update_fun()
	-- CountDownManager.Instance:AddCountDown(
	-- 		self.countdown_key,
	-- 		update_fun,
	-- 		complete_fun,
	-- 		end_time,
	-- 		nil,
	-- 		1)
end

--设置图标底部文本内容。 支持html格式
function BaseIcon:SetBottomContent(content)
	if self.bottom_rtxt == nil then
		self.bottom_rtxt = XRichText:create()
		self.view:addChild(self.bottom_rtxt)
		self.bottom_rtxt:setPosition(self.width / 2, -10)
	end
	content = HtmlTool.GetHtml(content, COLOR3B.WHITE, 22)
	HtmlTextUtil.SetString(self.bottom_rtxt, content)
end

--设置图标底部图，如图片文字
function BaseIcon:SetBottomImg(path, pos_x, pos_y)
	if path == nil or path == "" then return end

	if self.bottom_img == nil then
		self.bottom_img = XUI.CreateImageView(0, 0, path, true)
		self.view:addChild(self.bottom_img)
	end
	self.bottom_img:loadTexture(path)
	pos_x = self.width / 2
	pos_y = 13
	self.bottom_img:setPosition(pos_x, pos_y)
end

--设置图标底框，主界面图标有底框
function BaseIcon:SetBottomImgFrame(path)
	if path == nil or path == "" then return end

	if self.bottom_imgFrame == nil then
		self.bottom_imgFrame = XUI.CreateImageView(self.width / 2, self.height / 2, path, true)
		self.view:addChild(self.bottom_imgFrame, -1, -1)
	end
	self.bottom_imgFrame:loadTexture(path)
end

--播放图标上的特效
function BaseIcon:PlayIconEffect(effect_id, anim_pos, loop)
	if nil == self.icon_effect then
		self.icon_effect = AnimateSprite:create()
		self.view:EffectLayout():addChild(self.icon_effect)
	end

	anim_pos = anim_pos or {x = self.width / 2, y = self.height / 2}
	self.icon_effect:setPosition(anim_pos)

	local path, name = ResPath.GetEffectAnimPath(effect_id)
	self.icon_effect:setAnimate(path, name, loop or COMMON_CONSTS.MAX_LOOPS, 0.17, false)
end

-- 设置粒子特效的坐标
function BaseIcon:SetPEPosition(x,y)
	self.pe_x = x
	self.pe_y = y
end

-- 设置粒子特效的大小
function BaseIcon:SetPEScale(scale)
	self.pe_scale = scale
end

-- 设置粒子特效的层数
function BaseIcon:SetPEPlies(plies)
	self.pe_plies = plies
end

--粒子特效是否显示
function BaseIcon:SetPEVisible(value, anim_pos, loop)
	if not value then
		if nil ~= self.icon_effect then
			self.icon_effect:setStop()
		end
		return
	end

	if nil == self.icon_effect2 then
		self.icon_effect2 = AnimateSprite:create()
		self.view:EffectLayout():addChild(self.icon_effect2)
	end

	anim_pos = anim_pos or {x = self.width / 2, y = self.height / 2}
	self.icon_effect2:setPosition(anim_pos)

	local path, name = ResPath.GetEffectAnimPath(3115)
	self.icon_effect2:setAnimate(path, name, loop or COMMON_CONSTS.MAX_LOOPS, 0.17, false)
end

function BaseIcon:RemoveIconEffect()
	if self.icon_effect ~= nil then  
		self.icon_effect:setStop()
	end
end

function BaseIcon:RemoveCountDown()
	-- if CountDownManager.Instance:HasCountDown(self.countdown_key) then
	-- 	CountDownManager.Instance:RemoveCountDown(self.countdown_key)
	-- end
end
