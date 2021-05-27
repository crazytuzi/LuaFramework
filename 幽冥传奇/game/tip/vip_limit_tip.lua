
VipLimitView = VipLimitView or BaseClass(BaseView)
function VipLimitView:__init()
	--self.view_name = GuideModuleName.Activity
	self:SetIsAnyClickClose(true)

	--self.texture_path_list[1] = "res/xui/activity.png"

	self.config_tab = {
		{"itemtip_ui_cfg", 8, {0}},
	}
	self.param = nil
end

function VipLimitView:__delete()
	
end

function VipLimitView:ReleaseCallBack()

end

function VipLimitView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		-- self:CreateTopTitle(Language.WaBao.WabaoName, nil, content_size.height - 53)
		self.node_t_list.btn_left.node:addClickEventListener(BindTool.Bind(self.OnClickLeftBtn, self))
		self.node_t_list.btn_right.node:addClickEventListener(BindTool.Bind(self.OnClickRightBtn, self))
	end
end

function VipLimitView:ShowIndexCallBack(index)
	self:Flush(index)
end
	
function VipLimitView:OpenCallBack()
end

function VipLimitView:CloseCallBack()
	self.param = nil
end


function VipLimitView:OnFlush(param_t, index)
	for k,v in pairs(param_t) do
		if k == "param" then
			self.node_t_list.btn_right.node:setTitleText(v.r_btn)
			RichTextUtil.ParseRichText(self.node_t_list.rich_tips.node, string.format(Language.Tip.VipPowerTips1, v.power_name))
			RichTextUtil.ParseRichText(self.node_t_list.rich_condition_1.node, string.format(Language.Tip.VipPowerTips2, v.vip, v.power_name))
			RichTextUtil.ParseRichText(self.node_t_list.rich_condition_2.node, string.format(Language.Tip.VipPowerTips3, v.scene_name, v.npc_name))
			self.param = v
		end
	end
end

function VipLimitView:OnClickLeftBtn()
	ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
	self:Close()
end

function VipLimitView:OnClickRightBtn()
	if nil == self.param then return end

	if self.param.r_btn_event then
		self.param.r_btn_event()
	end
	self:Close()
end