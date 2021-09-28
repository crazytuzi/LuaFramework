TipsCommonExplainView = TipsCommonExplainView or BaseClass(BaseView)

function TipsCommonExplainView:__init()
	self.ui_config = {"uis/views/tips/commontips_prefab", "CommonExplainTips"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.content_str = ""
end

function TipsCommonExplainView:ReleaseCallBack()
	-- 清理变量
	self.content_var = nil
	self.no_tip_toggle = nil
	self.show_prompt = nil
	self.show_complete = nil
end

function TipsCommonExplainView:LoadCallBack()
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickGoTo", BindTool.Bind(self.OnClickGoTo, self))
	self:ListenEvent("OnClickOneKeyToComplete", BindTool.Bind(self.OnClickOneKeyToComplete, self))

	self.content_var = self:FindVariable("Content")
	self.show_prompt = self:FindVariable("Show_Prompt")
	self.show_complete = self:FindVariable("show_complete")

	self.no_tip_toggle = self:FindObj("NoTipToggle").toggle
	if nil ~= self.is_value then
		self:ShowPrompt(self.is_value)
	end
end

function TipsCommonExplainView:OpenCallBack()
	self.no_tip_toggle.isOn = false
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

function TipsCommonExplainView:SetPrompt(value)
	self.is_value = value
end

function TipsCommonExplainView:ShowPrompt(value)
	self.show_prompt:SetValue(value)
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
	local is_complete = ShengXiaoData.Instance:IsGatherComplete()
	local can_one_key = true
	local skil_cfg = RelicData.Instance:GetSkipCfg(1)
	if skil_cfg then
		can_one_key = skil_cfg.limit_level <= GameVoManager.Instance:GetMainRoleVo().level
	end
	self.show_complete:SetValue(not is_complete and can_one_key)
end

-- 一键完成
function TipsCommonExplainView:OnClickOneKeyToComplete()
	local need_gold = ShengXiaoData.Instance:GetAllGatherNeedGold()
	local can_gather_count = ShengXiaoData.Instance:GetRemanentGatherCount()
	local str = string.format(Language.ShengXiao.OneKeyToComplete, need_gold, can_gather_count)
	TipsCtrl.Instance:ShowCommonAutoView(nil, str, function()
		self:Close()
		ShengXiaoCtrl.Instance:SendOneKeyToComplete()
	end)
end