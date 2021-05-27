
PrayTreeTipsView = PrayTreeTipsView or BaseClass(XuiBaseView)
function PrayTreeTipsView:__init()
	self.config_tab = {
		{"itemtip_ui_cfg", 14, {0}}
	}
	self.is_any_click_close = true
end

function PrayTreeTipsView:__delete()

end

function PrayTreeTipsView:LoadCallBack()

end

function PrayTreeTipsView:CloseCallBack()
end

function PrayTreeTipsView:ReleaseCallBack()
	
end

function PrayTreeTipsView:OnFlush(param_t, index)
	self.data = param_t.all
	if nil == self.data or not next(self.data) then
		return
	end
	RichTextUtil.ParseRichText(self.node_t_list.rich_tips.node, self.data[1])
end








