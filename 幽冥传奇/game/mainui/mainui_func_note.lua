MainuiFuncNoteView = MainuiFuncNoteView or BaseClass()
function MainuiFuncNoteView:__init()
	self.mt_layout_root = nil
	self.data = nil
end	

function MainuiFuncNoteView:__delete()
	if self.achieve_handler then
		GlobalEventSystem:UnBind(self.achieve_handler)
		self.achieve_handler = nil
	end

	ClientCommonButtonDic[CommonButtonType.NAV_FUNCNOTE_BTN] = nil
end	

function MainuiFuncNoteView:Init(mt_layout_root)
	
	local screen_w, screen_h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()

	-- self.mt_layout_root = MainuiMultiLayout.CreateMultiLayout(380,711, cc.p(0.5, 0.5), cc.size(0, 0), mt_layout_root, 1)
	self.mt_layout_root = MainuiMultiLayout.CreateMultiLayout(screen_w-65,screen_h-150, cc.p(0.5, 0.5), cc.size(0, 0), mt_layout_root, 1)

	self.bg_img = XUI.CreateImageView(0,0,ResPath.GetMainui("func_note_bg"),true)
	self.mt_layout_root:TextureLayout():addChild(self.bg_img)

	-- self.bg_text_img = XUI.CreateImageView(-72,-42,ResPath.GetMainui("func_text_bg"),true)
	-- self.mt_layout_root:TextureLayout():addChild(self.bg_text_img)

	self.icon = XUI.CreateImageView(0,10,ResPath.GetMainui("icon_01_img"),true)
	self.mt_layout_root:TextureLayout():addChild(self.icon)

	ClientCommonButtonDic[CommonButtonType.NAV_FUNCNOTE_BTN] = self.icon

	self.word_img = XUI.CreateImageView(-3,-9,ResPath.GetMainui("icon_01_word"),true)
	self.mt_layout_root:TextureLayout():addChild(self.word_img)
	--红点提示
	self.remind_img = XUI.CreateImageView(21,32,ResPath.GetMainui("remind_flag"),true)
	self.mt_layout_root:TextureLayout():addChild(self.remind_img,999)
	self.remind_img:setVisible(false)

	self.desc_text = XUI.CreateRichText(0, -35, 150, 10, false)--XUI.CreateText(30-37+8,0-34,150,0,cc.TEXT_ALIGNMENT_CENTER)
	self.desc_text:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	self.desc_text:setVerticalAlignment(RichVAlignment.VA_CENTER)
	self.mt_layout_root:TextLayout():addChild(self.desc_text)

	self.img_effect = AnimateSprite:create()
	self.img_effect:setPosition(0,0)
	self.mt_layout_root:EffectLayout():addChild(self.img_effect)

	XUI.AddClickEventListener(self.bg_img,BindTool.Bind(self.OnImgClick,self),false)
	self.achieve_handler = GlobalEventSystem:Bind(AchievementEventType.NOTE_ACHIEVE_NUM, BindTool.Bind(self.UpdateData, self))
	self:SetVisible(false)
end	

function MainuiFuncNoteView:OnImgClick()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end
	GuideCtrl.Instance:ShowFuncNoteTipView(self.data)
end

function MainuiFuncNoteView:SetEnabled(v)
	self.bg_img:setEnabled(v)
end	

function MainuiFuncNoteView:SetVisible(v)
	self.mt_layout_root:setVisible(v)

	GlobalEventSystem:Fire(MainUIEventType.MAINUI_FUNNOTE_VISIBLE,v)
end	

function MainuiFuncNoteView:SetData(data)
	self.data = data
	if data then
		self.icon:loadTexture(ResPath.GetMainui("icon_" .. string.format("%02d",data.icon) .. "_img"))
		self.word_img:loadTexture(ResPath.GetMainui("icon_" .. string.format("%02d",data.icon) .. "_word"))
		local str = ""
		if self.data.circle > 0 then
			str =	string.format(Language.Guide.OpenCricleFormat,data.circle)
		else	
			str =	string.format(Language.Guide.OpenLevelFormat,data.level)
		end
		RichTextUtil.ParseRichText(self.desc_text, str, 20, COLOR3B.WHITE)
	end	
end	

function MainuiFuncNoteView:GetView()
	return self.mt_layout_root
end	

function MainuiFuncNoteView:PlayEffect()
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(37)
	self.img_effect:setAnimate(anim_path,anim_name,COMMON_CONSTS.MAX_LOOPS,FrameTime.Effect,false)
end	

function MainuiFuncNoteView:StopEffect()
	self.img_effect:setStop()
end	
function MainuiFuncNoteView:UpdateData()
	self.remind_img:setVisible(GuideData.Instance:GetNewFuncNoteRemind() > 0)
	if GuideData.Instance:GetNewFuncNoteRemind() > 0 then
		self:PlayEffect()
	else
		self:StopEffect()
	end
end
