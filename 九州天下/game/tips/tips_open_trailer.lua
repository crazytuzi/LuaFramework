TipsOpenTrailerView = TipsOpenTrailerView or BaseClass(BaseView)
function TipsOpenTrailerView:__init()
	self.ui_config = {"uis/views/tips/funtrailer", "FunTrailerTips"}
	self:SetMaskBg(true)
	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function TipsOpenTrailerView:__delete()
end

function TipsOpenTrailerView:LoadCallBack()
	self.icon = self:FindVariable("icon")
	self.desc = self:FindVariable("desc")
	self.open_desc = self:FindVariable("open_desc")
	self.can_reward = self:FindVariable("CanReward")
	self.btn_text = self:FindVariable("BtnText")
	self:ListenEvent("close", BindTool.Bind(self.OnCloseClick, self))
	self:ListenEvent("ClickReward", BindTool.Bind(self.OnClickReward, self))
	self.item_list = {}
	for i = 1, 3 do
		self.item_list[i] = {}
		self.item_list[i].root = self:FindObj("Item" .. i)
		self.item_list[i].item = ItemCell.New()
		self.item_list[i].item:SetInstanceParent(self.item_list[i].root)
	end
end

function TipsOpenTrailerView:ReleaseCallBack()
	-- 清理变量和对象
	self.icon = nil
	self.desc = nil
	self.open_desc = nil
	self.can_reward = nil
	self.btn_text = nil
	for k,v in pairs(self.item_list) do
		v.item:DeleteMe()
	end
	self.item_list = {}
end

function TipsOpenTrailerView:SetData(cfg)
	self.cfg = cfg
	self:Flush()
end

function TipsOpenTrailerView:OpenCallBack()
	if self.cfg then
		self:Flush()
	end
end

function TipsOpenTrailerView:OnFlush()
	local bundle, asset = ResPath.GetMainUIButton(self.cfg.icon_view)
	self.icon:SetAsset(bundle, asset)
	self.desc:SetValue(self.cfg.fun_dec)
	local desc_list = Split(self.cfg.open_dec, "#")
	local desc = ""
	if #desc_list == 1 then
		desc = self.cfg.open_dec
	else
		desc = desc_list[1] .. desc_list[2]
	end
	self.open_desc:SetValue(desc)
	if self.cfg.reward_item then
		for k,v in pairs(self.item_list) do
			if self.cfg.reward_item[k -1] then
				v.item:SetData(self.cfg.reward_item[k -1])
			end
			v.root:SetActive(self.cfg.reward_item[k -1] ~= nil)
		end
	end
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if OpenFunData.Instance then
		local last_reward_id = OpenFunData.Instance:GetTrailerLastRewardId()
		self.can_reward:SetValue(level >= self.cfg.end_level and last_reward_id < self.cfg.id)
	end
	self.btn_text:SetValue(self.cfg.open_panel_name ~= "" and Language.Mainui.TrailerBtnText[1] or Language.Mainui.TrailerBtnText[2])
end

function TipsOpenTrailerView:OnCloseClick()
	self:Close()
end


function TipsOpenTrailerView:OnClickReward()
	OpenFunCtrl.Instance:SendAdvanceNoitceOperate(1, self.cfg.id)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if level >= self.cfg.end_level and OpenFunData.Instance:GetTrailerLastRewardId() < self.cfg.id then
		self:Close()
		if self.cfg.open_panel_name ~= "" then
			ViewManager.Instance:OpenByCfg(self.cfg.open_panel_name)
		end
	end
end
