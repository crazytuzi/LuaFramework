-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
--结婚进度说明
-------------------------------------------------------

wnd_marry_pro_instructions = i3k_class("wnd_marry_pro_instructions",ui.wnd_base)

function wnd_marry_pro_instructions:ctor()

end

function wnd_marry_pro_instructions:configure()
	local widgets = self._layout.vars
	self.closeBtn = widgets.close_btn
	self.closeBtn:onClick(self, self.closeButton)
	--self.gotoMarryBtn = widgets.gotoMarryBtn --我要结婚
	--self.gotoMarryBtn:onClick(self, self.onGotoMarryBtn)
	
	--self.gotoMarryBtn:disableWithChildren()--置灰
	self._bgTab = {}
	self.Pathtab = {} --记录姻缘到宴席四个按钮的三种状态 默认 高亮 灰话
	for i= 1,5 do
	   local bg_btn = string.format("bg_btn%s",i)
		self._bgTab[i] = {}
		self._bgTab[i] = {btn = widgets[bg_btn]}
		self._bgTab[i].btn:onClick(self, self.onGotoMarryBtn , i)
		if i~=5 then
			self.Pathtab[i] = {2706+(i-1)*3,2707+(i-1)*3,2708+(i-1)*3}--默认 高亮 灰话
		end
	end
end

function wnd_marry_pro_instructions:refresh()
	--判断条件 当前是否可点击
	local state = g_i3k_game_context:getEnterProNum() --1 代表月老处 可点 --2 代表姻缘处
	if state ==1 then
		--全可点击
		self:setBtnEnable()
	elseif state ==2 then
		local step = g_i3k_game_context:getRecordSteps() --1 ，结婚状态时间
		if step ==-1 then
			--TODO1--全部可点击
			self:setBtnEnable()
		elseif  step ==1 then
			--婚后 1，2，4 不可点击 3可点击（游街）
			self:setBtnEnable(3)
		elseif  step ==2 then
			--开始宴席 1,2,3,不可点击  4可点击
			self:setBtnEnable(4)
		elseif  step ==3 then
			--开始宴席 1,2,3,不可点击  4可点击
			--self:setBtnEnable(4)
		elseif  step ==0 then
			--不会出现（入口会走夫妻姻缘界面）
		end
	else
	end
end

function wnd_marry_pro_instructions:setBtnEnable(index)
	
	
	for i,v in ipairs(self._bgTab) do
		if index then
			if i ~= 5 then
				if i<index then
					--灰化	self.Pathtab[i]
					v.btn:setImage(i3k_db_icons[self.Pathtab[i][3]].path) 
					v.btn:setTouchEnabled(false)
					--不可点击
				elseif i == index then
					--高亮
					v.btn:setImage(i3k_db_icons[self.Pathtab[i][2]].path) 
					v.btn:setTouchEnabled(true)
					--可点击
				elseif i > index then
					--默认亮
					v.btn:setImage(i3k_db_icons[self.Pathtab[i][1]].path) 
					--不可点击
					v.btn:setTouchEnabled(false)
				end
			else
				v.btn:disableWithChildren() --置灰
			end
		else
			--v.btn:setImage(i3k_db_icons[self.Pathtab[i][1]].path) 
			--v.btn:enableWithChildren() --置亮
			--可点击
			v.btn:setTouchEnabled(true)
		end		
	end
end

function wnd_marry_pro_instructions:onGotoMarryBtn(sender,tag)
	local state = g_i3k_game_context:getEnterProNum()
	local step = g_i3k_game_context:getRecordSteps() 
	if tag ==1 then
		g_i3k_logic:OpenMerryCreate()
	elseif tag ==2 then
		--local other = g_i3k_game_context:GetTeamOtherMembersProfile() 
		--if next(other) then
			g_i3k_logic:OpenGotoMarry()
		--else
			--g_i3k_ui_mgr:PopupTipMessage("结婚必须两人且为异性")
		--end		
	elseif tag ==3 then
		--g_i3k_ui_mgr:PopupTipMessage("暂未开放")
		g_i3k_logic:OpenMarryWendding()
	elseif tag ==4 then	
		--g_i3k_ui_mgr:PopupTipMessage("暂未开放")
		g_i3k_logic:OpenMarryBanquet()
	elseif tag ==5  then
		--点我要结婚是寻路到月老
		--local state = g_i3k_game_context:getEnterProNum()
		--if state ~=1 then
			local tips = g_i3k_game_context:GetNotEnterTips() or g_i3k_game_context:GetNotEnterMapIdTips()
			if tips then
				return g_i3k_ui_mgr:PopupTipMessage(tips)
			end
			g_i3k_ui_mgr:PopupTipMessage("寻路到月老")
			g_i3k_game_context:gotoYueLaoNpc()
			
		--end
		--self:closeButton()
	end
	--self:closeButton()
end

function wnd_marry_pro_instructions:closeButton(sender)
	 --我要结婚 进入缔结姻缘Ui
	g_i3k_ui_mgr:CloseUI(eUIID_Marry_Progress_Inst)
end

function wnd_create(layout)
	local wnd = wnd_marry_pro_instructions.new()
		wnd:create(layout)
	return wnd
end
