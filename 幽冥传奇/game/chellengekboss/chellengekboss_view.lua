ChellengeKBossView = ChellengeKBossView or BaseClass(XuiBaseView)

function ChellengeKBossView:__init()
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"boss_ui_cfg", 14, {0}},
		{"common_ui_cfg", 2, {0}},
	}
	self.texture_path_list = {"res/xui/pray.png",}
	self:SetModal(true)
	self.title_img_path = ResPath.GetPray("chellenge_title")
end

function ChellengeKBossView:__delete()
end

function ChellengeKBossView:ReleaseCallBack()

end

function ChellengeKBossView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self.node_t_list.lookseeBtn.node:addClickEventListener(BindTool.Bind(self.ChargeFirstMoney, self))
		RichTextUtil.ParseRichText(self.node_t_list.txt_tip.node,Language.Boss.KuangChellengeBoss,22,cc.c3b(0xff, 0xff, 0x00)) 
	end
end

function ChellengeKBossView:ChargeFirstMoney()
	local todey =  CombineServerData.Instance:GetChargeMoney()
	if todey >= RechargeSceneConfig[1].enterDailyRechargeLimit then
		ChellengeKBossCtrl.Instance:BossReq()
	else
		ViewManager.Instance:Open(ViewName.ChargePlatForm)
	end
	self:Close()
end
 
function ChellengeKBossView:OnClose()
	AudioManager.Instance:PlayClickBtnSoundEffect()
end
function ChellengeKBossView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ChellengeKBossView:ShowIndexCallBack(index)
	self:Flush(index)
end

function ChellengeKBossView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ChellengeKBossView:OnFlush(param_t, index)

end
