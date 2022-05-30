-- 录音界面
-- author:cloud
--date:2016.12.26

VoiceRecordUI = class("VoiceRecordUI", function()
	return ccui.Widget:create()
end)

function VoiceRecordUI:ctor()
	self:setContentSize(184,174)
	-- local plist, prvCcz = PathTool.getTargetRes("chat", "chat", true)
	-- display.loadSpriteFrames(plist, prvCcz)

	local res = PathTool.getResFrame("mainui","mainui_voice_bg2")
	self.bg = createScale9Sprite(res,self:getContentSize().width/2,self:getContentSize().height/2,LOADTEXT_TYPE_PLIST,self)
	self.bg:setAnchorPoint(cc.p(0.5,0.5))
	self.bg:setContentSize(cc.size(259,253))
	-- local res  = PathTool.getResFrame("mainui","mainui_chat_sound_icon")
	-- local icon_bg = createSprite(res,self.bg:getContentSize().width/2,self.bg:getContentSize().height/2,self.bg,cc.p(0.5,0.5),LOADTEXT_TYPE_PLIST)
	local res = PathTool.getResFrame("mainui","mainui_voice1")
	self.icon = createSprite(res,self.bg:getContentSize().width/2,self.bg:getContentSize().height/2+10,self.bg,cc.p(0.5,0.5),LOADTEXT_TYPE_PLIST)

	res = PathTool.getResFrame("mainui","mainui_voice_bg")
	self.red_bg = createScale9Sprite(res,self.bg:getContentSize().width/2,15,LOADTEXT_TYPE_PLIST,self.bg)
	self.red_bg:setAnchorPoint(0.5,0)
	self.red_bg:setContentSize(cc.size(234,35))

	self.desc_label = createLabel(24,Config.ColorData.data_color4[1],nil,0,0, TI18N("手指上滑,取消发送"),self.bg)
	self.desc_label:setAnchorPoint(0.5,0)
	self.desc_label:setPosition(self.bg:getContentSize().width/2, 20)
end

function VoiceRecordUI:showAction()
end

function VoiceRecordUI:setIsRecord(bool)
	if bool then
		self.desc_label:setString(TI18N("手指上滑,取消发送"))
		self.red_bg:setVisible(false)
		loadSpriteTexture(self.icon, PathTool.getResFrame("mainui","mainui_voice1"), LOADTEXT_TYPE_PLIST)
	else
		self.desc_label:setString(TI18N("松开手指,取消发送"))
		self.red_bg:setVisible(true)
		loadSpriteTexture(self.icon, PathTool.getResFrame("mainui","mainui_voice2"), LOADTEXT_TYPE_PLIST)
	end
end
