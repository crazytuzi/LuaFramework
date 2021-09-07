BaoBaoBlessView = BaoBaoBlessView or BaseClass(BaseRender)
local BAOBAONUM = 2
function BaoBaoBlessView:__init(instance)
	self.baobao_model = {}
end

function BaoBaoBlessView:__delete()
	if self.baobao_model ~= nil then
		for k,v in pairs(self.baobao_model) do
			v:DeleteMe()
		end
		self.baobao_model = nil
	end
end

function BaoBaoBlessView:LoadCallBack()
	for i = 1, 3 do	
		self:ListenEvent("OnClickQifu"..i, BindTool.Bind(self.OnClickQifu, self, i))
		self["Capability" .. i] = self:FindVariable("Cap" .. i)
		self["baobao_name" .. i] = self:FindVariable("BaobaoName" .. i)
		self["qifu_cost" .. i] = self:FindVariable("CostStr" .. i)
		self["qifu_icon" .. i] = self:FindVariable("QifuIcon" .. i)
	end
	self.baobao_num = self:FindVariable("BaoBaoNum")

	self:ListenEvent("OnClickDetial", BindTool.Bind(self.OnClickDetial, self))
	self:ListenEvent("OnClickBuy", BindTool.Bind(self.OnClickBuy, self))

	--self:SetYuanBaoIcon()
end

function BaoBaoBlessView:OnClickQifu(bless_type)
	if bless_type == nil then
		return
	end

	local qifu_tree = BaobaoData.Instance:GetBabyQiFuTreeCfg()
	local bless = ""
	-- if qifu_tree ~= nil and next(qifu_tree) ~= nil then
	-- 	if bless_type == 1 then
	-- 		bless = string.format(Language.Marriage.CommonBabyTips, qifu_tree[1].qifu_consume_bind_gold)
	-- 	elseif bless_type == 2 then
	-- 		bless = string.format(Language.Marriage.SilverBabyTips, qifu_tree[2].qifu_consume_gold)
	-- 	elseif bless_type == 3 then
	-- 		bless = string.format(Language.Marriage.GoldBabyTips, qifu_tree[3].qifu_consume_gold)
	-- 	end
	-- end

	if qifu_tree ~= nil and next(qifu_tree) ~= nil and qifu_tree[bless_type] ~= nil then
		local show_consume = qifu_tree[bless_type].qifu_consume_bind_gold
		local consume_type = Language.Common.Bind .. Language.Common.Gold
		if show_consume <= 0 then
			show_consume = qifu_tree[bless_type].qifu_consume_gold
			consume_type = Language.Common.Gold
		end

		local consume_item = qifu_tree[bless_type].replace_item
		if consume_item ~= nil then
			local has_num = ItemData.Instance:GetItemNumInBagById(consume_item)
			if has_num ~= nil and has_num > 0 then
				show_consume = has_num
				local item_data = ItemData.Instance:GetItemConfig(consume_item)
				if item_data ~= nil then
					show_consume = "1" .. Language.Common.UnitName[1] .. item_data.name
				else
					show_consume = ""
				end
			end
		end

		bless = string.format(Language.Marriage.BlessBabyStr, show_consume, Language.Marriage.BabyTypeStr[bless_type] or "")
	end
	TipsCtrl.Instance:ShowCommonTip(BindTool.Bind(BaobaoCtrl.SendBabyBlessReq, bless_type), nil, bless, nil, nil, false)
end

-- function BaoBaoBlessView:SetYuanBaoIcon()
-- 	local qifu_tree = BaobaoData.Instance:GetBabyQiFuTreeCfg()

-- 	if qifu_tree == nil or next(qifu_tree) == nil then
-- 		return
-- 	end

-- 	for i = 1, 3 do	
-- 		local gold = 0
-- 		if qifu_tree[i] ~= nil then
-- 			gold = qifu_tree[i].qifu_consume_bind_gold  or 0
-- 		end

-- 		if i < 3 then
-- 			if tonumber(qifu_tree[i].qifu_consume_bind_gold) > 0 then
-- 				self["qifu_icon" .. i]:SetAsset(ResPath.GetYuanBaoIcon(1))
-- 			else
-- 				self["qifu_icon" .. i]:SetAsset(ResPath.GetYuanBaoIcon(0))
-- 			end
-- 		end
-- 	end
-- end

function BaoBaoBlessView:OnClickDetial()
	local tips_id = 255 -- 宝宝帮助
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function BaoBaoBlessView:OnClickBuy()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_vo.lover_uid <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NotLoverDes)
		return
	end

	local born_again_cfg, replace_item = BaobaoData.Instance:GetBabyChaoShengGold()

	function call()
		--BaobaoCtrl.SendBabyChaoshengReq()
		if replace_item ~= nil and next(replace_item) ~= nil then
			local has_num = ItemData.Instance:GetItemNumInBagById(replace_item.item_id) or 0
			if has_num > 0 then
				if has_num < replace_item.num then
					TipsCtrl.Instance:ShowCommonBuyView(function (item_id, item_num, is_bind, is_use, is_buy_quick)  
						MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
						BaobaoCtrl.SendBabyChaoshengReq()
						end, replace_item.item_id, nil, replace_item.num - has_num, true)
				else
					BaobaoCtrl.SendBabyChaoshengReq()
				end
			else
				BaobaoCtrl.SendBabyChaoshengReq()
			end
		end
	end

	local born_consume = ""
	if born_again_cfg then
		born_consume = string.format(Language.Marriage.BornAgainConSume, born_again_cfg)
		if replace_item ~= nil and next(replace_item) ~= nil then
			local has_num = ItemData.Instance:GetItemNumInBagById(replace_item.item_id) or 0
			local item_cfg = ItemData.Instance:GetItemConfig(replace_item.item_id)
			if has_num > 0 and item_cfg ~= nil then
				born_consume = string.format(Language.Marriage.BornAgainItem, replace_item.num, item_cfg.name or "")
			end
		end

		TipsCtrl.Instance:ShowCommonTip(call, nil, born_consume, nil, nil, false)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.BaobaoMax)
	end
end


function BaoBaoBlessView:OnFlush()
	local qifu_tree = BaobaoData.Instance:GetBabyQiFuTreeCfg()
	if qifu_tree ~= nil then
		self.qifu_cost1:SetValue(qifu_tree[1].qifu_consume_gold)
		self.qifu_cost2:SetValue(qifu_tree[2].qifu_consume_gold)
		self.qifu_cost3:SetValue(qifu_tree[3].qifu_consume_gold)
	end

	local baby = BaobaoData.Instance:GetBaoBaoInfoCfg()
	if self.baobao_model ~= nil then
		for i = 1, 3 do
			if baby[i - 1] ~= nil then
				self["Capability" .. i]:SetValue(CommonDataManager.GetCapability(baby[i - 1]))
				--local str = string.format(Language.Marriage["BaobaoName" .. i],baby[i - 1] and baby[i - 1].name or "")
				local str = baby[i - 1] and baby[i - 1].name or ""
				self["baobao_name" .. i]:SetValue(str)
			end

			if self.baobao_model[i] == nil then
				self["baobao" .. i] = self:FindObj("BaobaoDisplay" .. i)
				local baobao_model = RoleModel.New("baobao_bless_role_model"..i)
				baobao_model:SetDisplay(self["baobao" .. i].ui3d_display)
				baobao_model:SetMainAsset(ResPath.GetBabyModel(BaobaoData.Instance:GetBabyResId(i - 1)))
				self.baobao_model[i] = baobao_model
			end
 
			if self["qifu_cost" .. i] ~= nil and qifu_tree[i] ~= nil then
				local show_consume = qifu_tree[i].qifu_consume_bind_gold
				local bundle, asset = ResPath.GetYuanBaoIcon(1)
				if show_consume <= 0 then
					show_consume = qifu_tree[i].qifu_consume_gold
					bundle, asset = ResPath.GetYuanBaoIcon(0)
				end

				local consume_item = qifu_tree[i].replace_item
				if consume_item ~= nil then
					local has_num = ItemData.Instance:GetItemNumInBagById(consume_item)
					if has_num ~= nil and has_num > 0 then
						show_consume = has_num
						bundle, asset = ResPath.GetItemIcon(consume_item)
					end
				end

				self["qifu_cost" .. i]:SetValue(show_consume)

				if self["qifu_icon" .. i] ~= nil then
					self["qifu_icon" .. i]:SetAsset(bundle, asset)
				end
			end
		end
	end

	local baobao_data = BaobaoData.Instance:GetHaveBaoBaoData()
	local baobao_chaosheng = BaobaoData.Instance:GetBabyChaoShengCount() or 0
	self.baobao_num:SetValue(#baobao_data .. " / " .. BAOBAONUM + baobao_chaosheng)
end
