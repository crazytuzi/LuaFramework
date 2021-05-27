-- 微信关注界面
WeChatAttentionPage = WeChatAttentionPage or BaseClass()

function WeChatAttentionPage:__init()
	self.view = nil
end

function WeChatAttentionPage:__delete()
	self:RemoveEvent()
	
	
	self.view = nil
end

function WeChatAttentionPage:InitPage(view)
	self.view = view

end

function WeChatAttentionPage:RemoveEvent()
	
end

--更新视图界面
function WeChatAttentionPage:UpdateData(data)
	local agent_id = ClientQRCodeCfg[AgentAdapter:GetSpid()] 
	if agent_id > 0 then
		self.view.node_t_list.img_qrcode.node:loadTexture(ResPath.GetQRCode(agent_id,true), true)
	end
end	






