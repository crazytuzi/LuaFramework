-- Filename：	RecordTipSprite.lua
-- Author：		Cheng Liang
-- Date：		2015-4-1
-- Purpose：		录音的提示

require "script/animation/XMLSprite"

RecordTipSprite = class("RecordTipSprite", function ()
	local t_9sprite = CCScale9Sprite:create("images/chat/record_tip.png")
    t_9sprite:setContentSize(CCSizeMake(250,250))
	return t_9sprite
end)

function RecordTipSprite:ctor( ... )
	self.recordingTipSprite		= nil
	self.cancelTipSprite		= nil
	self.voiceLevelArr 			= {}
end

function RecordTipSprite:create( ... )
	local t_sprite = RecordTipSprite:new()

	-- 手指在录音的提示
	t_sprite.recordingTipSprite = CCSprite:create("images/chat/microphone.png")
	t_sprite.recordingTipSprite:setAnchorPoint(ccp(0.5, 0.5))
	t_sprite.recordingTipSprite:setPosition(ccp(125, 125))
	t_sprite:addChild(t_sprite.recordingTipSprite)

	local r_size = t_sprite.recordingTipSprite:getContentSize()

	-- 最下面
	local v_sp_1 = CCSprite:create("images/chat/xia.png")
	v_sp_1:setAnchorPoint(ccp(0.5, 0))
	v_sp_1:setPosition(ccp(r_size.width*0.5, 40))
	t_sprite.recordingTipSprite:addChild(v_sp_1)
	table.insert(t_sprite.voiceLevelArr, v_sp_1)
	
	local v_sp_2 = CCSprite:create("images/chat/heng.png")
	v_sp_2:setAnchorPoint(ccp(0.5, 0))
	v_sp_2:setPosition(ccp(r_size.width*0.5, 40+18))
	t_sprite.recordingTipSprite:addChild(v_sp_2)
	table.insert(t_sprite.voiceLevelArr, v_sp_2)

	local v_sp_3 = CCSprite:create("images/chat/heng.png")
	v_sp_3:setAnchorPoint(ccp(0.5, 0))
	v_sp_3:setPosition(ccp(r_size.width*0.5, 40+35))
	t_sprite.recordingTipSprite:addChild(v_sp_3)
	table.insert(t_sprite.voiceLevelArr, v_sp_3)

	local v_sp_4 = CCSprite:create("images/chat/heng.png")
	v_sp_4:setAnchorPoint(ccp(0.5, 0))
	v_sp_4:setPosition(ccp(r_size.width*0.5, 40+52))
	t_sprite.recordingTipSprite:addChild(v_sp_4)
	table.insert(t_sprite.voiceLevelArr, v_sp_4)

	local v_sp_5 = CCSprite:create("images/chat/xia.png")
	v_sp_5:setAnchorPoint(ccp(0.5, 1))
	v_sp_5:setPosition(ccp(r_size.width*0.5, 109))
	v_sp_5:setScaleY(-1)
	t_sprite.recordingTipSprite:addChild(v_sp_5)
	table.insert(t_sprite.voiceLevelArr, v_sp_5)

	local t_label = CCLabelTTF:create(GetLocalizeStringBy("key_10019"), g_sFontName, 21)
	t_label:setColor(ccc3(0xff,0xff,0xff))
	t_label:setAnchorPoint(ccp(0.5, 0.5))
	t_label:setPosition(ccp(t_sprite.recordingTipSprite:getContentSize().width*0.5, -t_sprite.recordingTipSprite:getContentSize().height*0.3))
	t_sprite.recordingTipSprite:addChild(t_label)

	-- 手指上划之后的提示
	t_sprite.cancelTipSprite = CCSprite:create("images/chat/record_back.png")
	t_sprite.cancelTipSprite:setAnchorPoint(ccp(0.5, 0.5))
	t_sprite.cancelTipSprite:setPosition(ccp(125, 125))
	t_sprite:addChild(t_sprite.cancelTipSprite)

	local c_sp = CCScale9Sprite:create("images/chat/wenzidi.png")
	c_sp:setContentSize(CCSizeMake(210, 36))
	c_sp:setAnchorPoint(ccp(0.5, 0.5))
	c_sp:setPosition(ccp(t_sprite.cancelTipSprite:getContentSize().width*0.5, -t_sprite.cancelTipSprite:getContentSize().height*0.45))
	t_sprite.cancelTipSprite:addChild(c_sp)

	local c_label = CCLabelTTF:create(GetLocalizeStringBy("key_10020"), g_sFontName, 21)
	c_label:setColor(ccc3(0xff,0xff,0xff))
	c_label:setAnchorPoint(ccp(0.5, 0.5))
	c_label:setPosition(ccp(c_sp:getContentSize().width*0.5, c_sp:getContentSize().height*0.5))
	c_sp:addChild(c_label)

	return t_sprite
end

function RecordTipSprite:showStaus( p_status )

	self.recordingTipSprite:setVisible(p_status)
	self.cancelTipSprite:setVisible( not p_status)

end

-- 控制音量大小
function RecordTipSprite:setVoiceCol( p_level )
	p_level = tonumber(p_level)
	for i=1,5 do
		if( i<= p_level )then
			self.voiceLevelArr[i]:setVisible(true)
		else
			self.voiceLevelArr[i]:setVisible(false)
		end
	end
end
