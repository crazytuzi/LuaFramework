WeddingTipsOne = WeddingTipsOne or BaseClass(BaseView)

function WeddingTipsOne:__init()
	self.ui_config = {"uis/views/marriageview_prefab","WeddingTips1"}
end

function WeddingTipsOne:__delete()

end

function WeddingTipsOne:LoadCallBack()
	self.item_list = {}
	for i=1, 2 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("Item_" .. i))
		table.insert(self.item_list, item)
	end
	self.fight_power = self:FindVariable("fight_power")
	self:ListenEvent("CloseView", BindTool.Bind(self.OnClickCloseView,self))
end

function WeddingTipsOne:ReleaseCallBack()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	self.fight_power = nil
end

function WeddingTipsOne:OpenCallBack()
	self:Flush()
end

function WeddingTipsOne:OnFlush()
	local hunli_type = MARRIAGE_SELECT_TYPE.MARRIAGE_SELECT_TYPE_SWEET.index - 1 or 0
	local hunli_data = MarriageData.Instance:GetHunliInfoByType(hunli_type)
	if nil ~= hunli_data then
		for k,v in pairs(self.item_list) do
			v:SetData(hunli_data.reward_type[0])
		end
		self.fight_power:SetValue(MarriageData.Instance:GetMarriageTipPower(hunli_type, WEDDING_TIPS_POWER_TYPE.RING))
	end
end

function WeddingTipsOne:OnClickCloseView()
	self:Close()
end