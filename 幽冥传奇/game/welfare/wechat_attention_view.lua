-- 微信关注
local WelfareWechatView = BaseClass(SubView)

function WelfareWechatView:__init()
	self.texture_path_list = {
		'res/xui/welfare.png',
	}
	self.config_tab = {
		{"welfare_ui_cfg", 9, {0}},
	}
end

function WelfareWechatView:__delete()
	-- body
end

function WelfareWechatView:LoadCallBack(index, loaded_times)
	local ph = self.ph_list.ph_qr_code
	local index = 1
	self.qr_code = XUI.CreateImageView(ph.x, ph.y, ResPath.GetWelfare("img_qr_code_1"), true)
	self.node_t_list.layout_wechat_attention.node:addChild(self.qr_code, 99)
	self.qr_code:setVisible(false)
end

function WelfareWechatView:ReleaseCallBack()
	self.qr_code = nil
end

function WelfareWechatView:OnFlushWeChatAttentionView()
	
end
return WelfareWechatView