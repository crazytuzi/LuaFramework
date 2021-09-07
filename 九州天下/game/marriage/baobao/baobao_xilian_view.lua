BaoBaoXiLianView = BaoBaoXiLianView or BaseClass(BaseView)

function BaoBaoXiLianView:__init(instance)
	self.ui_config = {"uis/views/baby", "BaoBaoXiLian"}
	self:SetMaskBg(true)
end

function BaoBaoXiLianView:ReleaseCallBack()
	self.baby_name = nil
	self.level_asset = nil
	self.attr_asset = nil
	self.item_num = nil

	if self.item_cell then 
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	UnityEngine.PlayerPrefs.DeleteKey("show_baby_xilian")
end

function BaoBaoXiLianView:LoadCallBack()
	self.baby_name = self:FindVariable("baby_name")
	self.level_asset = self:FindVariable("level_asset")
	self.attr_asset = self:FindVariable("attr_asset")
	self.item_num = self:FindVariable("item_num")

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))

    self:ListenEvent("Close", BindTool.Bind(self.Close, self))
    self:ListenEvent("OnClickXiLian", BindTool.Bind(self.OnClickXiLian, self))

    self:Flush("all_info")
end

function BaoBaoXiLianView:OpenCallBack()
	self:Flush("all_info")
	self:Flush("xilian_info")
end

function BaoBaoXiLianView:CloseCallBack()
	if self.need_item ~= nil then
		TipsCommonBuyView.AUTO_LIST[self.need_item] = false
		self.need_item = nil
	end
end

function BaoBaoXiLianView:OnFlush(param_t)
	local baby_info = BaobaoData.Instance:GetSelectedBabyInfo()
	for k, v in pairs(param_t) do
		if k == "all_info" then
			if nil == baby_info or nil == next(baby_info) then return end

			self.baby_name:SetValue(baby_info.baby_name)
			self.level_asset:SetAsset(ResPath.GetBabyImage("img_level_" .. baby_info.master_level))
		    self.attr_asset:SetAsset(ResPath.GetBabyImage("img_type_" .. baby_info.master_type))
		elseif k == "xilian_info" then
			local _, master_type, master_level = BaobaoData.Instance:GetBabyMasterValue()
			self.level_asset:SetAsset(ResPath.GetBabyImage("img_level_" .. master_level))
		    self.attr_asset:SetAsset(ResPath.GetBabyImage("img_type_" .. master_type))
		end
	end
	
	local baobao_data = BaobaoData.Instance:GetBabyInfoCfg(baby_info.baby_id)
	self.item_cell:SetData({item_id = baobao_data.master_wash_item, num = 1, is_bind = 0})
   
    local item_num = ItemData.Instance:GetItemNumInBagById(baobao_data.master_wash_item)
    self.item_num:SetValue(item_num .. "/" .. 1)

    self.need_item = baobao_data.master_wash_item
end

function BaoBaoXiLianView:OnClickXiLian()
	local baby_info = BaobaoData.Instance:GetSelectedBabyInfo()
	if baby_info == nil or next(baby_info) == nil then
		return
	end
	local baobao_data = BaobaoData.Instance:GetBabyInfoCfg(baby_info.baby_id)
	if baobao_data == nil or next(baobao_data) == nil then
		return
	end

	local ok_fun = function (item_id, cur_num, is_bind, is_tip_use, is_buy_quick)
		if baby_info and baby_info.baby_index then
			BaobaoCtrl.SendBabyOperaReq(BABY_REQ_TYPE.BABY_REQ_TYPE_WASH_MASTER, baby_info.baby_index, is_buy_quick and 1 or 0)
		end
	end

	if UnityEngine.PlayerPrefs.GetInt("show_baby_xilian") == 1 then
		local is_auto = false
		if TipsCommonBuyView.AUTO_LIST[baobao_data.master_wash_item] then
			is_auto = true
		end

		local item_num = ItemData.Instance:GetItemNumInBagById(baobao_data.master_wash_item)

		if item_num < 1 and not is_auto then
			TipsCtrl.Instance:ShowCommonBuyView(ok_fun, baobao_data.master_wash_item, nil, 1)
		else
			ok_fun(nil, nil, nil, nil, is_auto)
		end
	else
		TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, Language.Marriage.DescXiLian, nil, nil, true, false, "show_baby_xilian")
	end
end