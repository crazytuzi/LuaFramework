TipsCommonExplainView = TipsCommonExplainView or BaseClass(BaseView)

function TipsCommonExplainView:__init()
	self.ui_config = {"uis/views/tips/commontips", "CommonExplainTips"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.content_str = ""
end

function TipsCommonExplainView:ReleaseCallBack()
	-- 清理变量
	self.content_var = nil
	self.no_tip_toggle = nil
end

function TipsCommonExplainView:LoadCallBack()
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickGoTo", BindTool.Bind(self.OnClickGoTo, self))

	self.content_var = self:FindVariable("Content")

	self.no_tip_toggle = self:FindObj("NoTipToggle").toggle
end

function TipsCommonExplainView:OpenCallBack()
	self.no_tip_toggle.isOn = true
	self:Flush()
end

function TipsCommonExplainView:CloseCallBack()

end

function TipsCommonExplainView:SetContent(content)
	self.content_str = content or ""
end

function TipsCommonExplainView:SetOkCallBack(ok_call_back)
	self.ok_call_back = ok_call_back
end

function TipsCommonExplainView:SetPrefabKey(prefab_key)
	self.prefab_key = prefab_key
end

function TipsCommonExplainView:OnClickClose()
	self:Close()
end

function TipsCommonExplainView:OnClickGoTo()
	if nil ~= self.ok_call_back then
		self.ok_call_back()
		self.ok_call_back = nil
	end

	if self.no_tip_toggle.isOn and nil ~= self.prefab_key then
		UnityEngine.PlayerPrefs.SetInt(self.prefab_key, 1)
	end
	self:Close()
end

function TipsCommonExplainView:OnFlush(param_list)
	self.content_var:SetValue(self.content_str)
end