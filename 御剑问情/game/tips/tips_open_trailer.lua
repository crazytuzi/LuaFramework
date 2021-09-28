require("game/task/task_data")

TipsOpenTrailerView = TipsOpenTrailerView or BaseClass(BaseView)
function TipsOpenTrailerView:__init()
	self.ui_config = {"uis/views/tips/funtrailer_prefab", "FunTrailerTips"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function TipsOpenTrailerView:__delete()
end

function TipsOpenTrailerView:LoadCallBack()
	self.icon = self:FindVariable("icon")
	self.desc = self:FindVariable("desc")
	self.label = self:FindVariable("Label")
	self.open_desc = self:FindVariable("open_desc")
	self.btn_text = self:FindVariable("BtnText")

	self:ListenEvent("close", BindTool.Bind(self.OnCloseClick, self))
	self:ListenEvent("ClickReward", BindTool.Bind(self.OnClickReward, self))
	self:ListenEvent("ClickDoTask", BindTool.Bind(self.OnClickDoTask, self))
	
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
	self.label = nil
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
	local bundle, asset = ResPath.GetMainUI(self.cfg.icon_view)
	self.icon:SetAsset(bundle, asset)
	self.desc:SetValue(self.cfg.fun_dec)
	self.label:SetValue(self.cfg.open_name)
	local desc_list = Split(self.cfg.open_dec, "#")
	local desc = ""
	if #desc_list == 1 then
		desc = self.cfg.open_dec
	else
		desc = desc_list[1] .. desc_list[2]
	end
	self.open_desc:SetValue(desc)
	for k,v in pairs(self.item_list) do
		v.root:SetActive(self.cfg.reward_item[k -1] ~= nil)
		if self.cfg.reward_item[k -1] then
			v.item:SetData(self.cfg.reward_item[k -1])
		end
	end
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local last_reward_id = OpenFunData.Instance:GetTrailerLastRewardId()
	if level < self.cfg.end_level then
	self.btn_text:SetValue(Language.Mainui.TrailerBtnText[3])
    else
       self.btn_text:SetValue(self.cfg.open_panel_name ~= "" and Language.Mainui.TrailerBtnText[1] or Language.Mainui.TrailerBtnText[2])
    end
end

function TipsOpenTrailerView:OnCloseClick()
	self:Close()
end

function TipsOpenTrailerView:OnClickDoTask()
	TaskCtrl.Instance:DoTask()
	self:Close()
end

function TipsOpenTrailerView:OnClickReward()
	OpenFunCtrl.Instance:SendAdvanceNoitceOperate(ADVANCE_NOTICE_OPERATE_TYPE.ADVANCE_NOTICE_FETCH_REWARD, self.cfg.id)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if level >= self.cfg.end_level and OpenFunData.Instance:GetTrailerLastRewardId() < self.cfg.id then
		self:Close()
		if self.cfg.open_panel_name ~= "" then
			ViewManager.Instance:OpenByCfg(self.cfg.open_panel_name)
		end
	elseif level < self.cfg.end_level then
	    self:OnClickDoTask()
	end
end
