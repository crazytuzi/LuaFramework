BaoBaoBlessView = BaoBaoBlessView or BaseClass(BaseRender)
local BAOBAONUM = 5
function BaoBaoBlessView:__init(instance, mother_view)
	for i = 1, 3 do	
		self:ListenEvent("OnClickQifu"..i, BindTool.Bind(self.OnClickQifu, self, i))
		self["Capability" .. i] = self:FindVariable("Cap" .. i)
		self["baobao_name" .. i] = self:FindVariable("BaobaoName" .. i)
		self["qifu_cost" .. i] = self:FindVariable("Qifu1Cost" .. i)
		self["qifu_icon" .. i] = self:FindVariable("QifuIcon" .. i)
	end
	self.baobao_num = self:FindVariable("BaoBaoNum")

	self:ListenEvent("OnClickDetial", BindTool.Bind(self.OnClickDetial, self))
	self:ListenEvent("OnClickBuy", BindTool.Bind(self.OnClickBuy, self))

	self.baobao_model = {}
	self:SetYuanBaoIcon()
end

function BaoBaoBlessView:__delete()
	for k,v in pairs(self.baobao_model) do
		v:DeleteMe()
	end
	self.baobao_model = {}
end

function BaoBaoBlessView:OnClickQifu(bless_type)
	local qifu_tree = BaobaoData.Instance:GetBabyQiFuTreeCfg()
	local bless = ""
	if qifu_tree ~= nil then
		if bless_type == 1 then
			bless = string.format(Language.Marriage.CommonBabyTips, qifu_tree[1].qifu_consume_bind_gold)
		elseif bless_type == 2 then
			bless = string.format(Language.Marriage.SilverBabyTips, qifu_tree[2].qifu_consume_gold)
		elseif bless_type == 3 then
			bless = string.format(Language.Marriage.GoldBabyTips, qifu_tree[3].qifu_consume_gold)
		end
	end
	TipsCtrl.Instance:ShowCommonTip(BindTool.Bind(BaobaoCtrl.SendBabyBlessReq, bless_type), nil, bless, nil, nil, false)
end

function BaoBaoBlessView:SetYuanBaoIcon()
	local qifu_tree = BaobaoData.Instance:GetBabyQiFuTreeCfg()
	if not qifu_tree then return end
	for i = 1, 3 do	
		if tonumber(qifu_tree[i].qifu_consume_bind_gold) > 0 then
			self["qifu_icon" .. i]:SetAsset(ResPath.GetDiamonIcon(3))
		else
			self["qifu_icon" .. i]:SetAsset(ResPath.GetDiamonIcon(2))
		end
	end
end

function BaoBaoBlessView:OnClickDetial()
	local tips_id = 259 -- 宝宝帮助
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function BaoBaoBlessView:OnClickBuy()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_vo.lover_uid <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NotLoverDes)
		return
	end

	local born_again_cfg = BaobaoData.Instance:GetBabyChaoShengGold()
	local born_consume = ""
	if born_again_cfg ~= nil then
		born_consume = string.format(Language.Marriage.BornAgainConSume, born_again_cfg)
		TipsCtrl.Instance:ShowCommonTip(BindTool.Bind(BaobaoCtrl.SendBabyChaoshengReq), nil, born_consume, nil, nil, false)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.BaobaoMax)
	end
end


function BaoBaoBlessView:FlushView()
	local qifu_tree = BaobaoData.Instance:GetBabyQiFuTreeCfg()
	if qifu_tree ~= nil then
		self.qifu_cost1:SetValue(qifu_tree[1].qifu_consume_bind_gold)
		self.qifu_cost2:SetValue(qifu_tree[2].qifu_consume_gold)
		self.qifu_cost3:SetValue(qifu_tree[3].qifu_consume_gold)
	end

	local baby = BaobaoData.Instance:GetBaoBaoInfoCfg()
	for i = 1, 3 do
		if baby[i - 1] ~= nil then
			self["Capability" .. i]:SetValue(CommonDataManager.GetCapabilityCalculation(baby[i - 1]))
			local str = string.format(Language.Marriage["BaobaoName" .. i],baby[i - 1] and baby[i - 1].name or "")
			self["baobao_name" .. i]:SetValue(str)
		end

		if self.baobao_model[i] == nil then
			self["baobao" .. i] = self:FindObj("BaobaoDisplay" .. i)
			local baobao_model = RoleModel.New("baobao_bless_role_model"..i)
			baobao_model:SetDisplay(self["baobao" .. i].ui3d_display)
			baobao_model:SetMainAsset(ResPath.GetSpiritModel(BaobaoData.BabyModel[i]))
			self.baobao_model[i] = baobao_model
		end
	end
	local baobao_data = BaobaoData.Instance:GetHaveBaoBaoData()
	local baobao_chaosheng = BaobaoData.Instance:GetBabyChaoShengCount() or 0
	self.baobao_num:SetValue(#baobao_data .. " / " .. BAOBAONUM + baobao_chaosheng)
end
