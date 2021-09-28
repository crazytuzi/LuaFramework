ShenShouExtraZhuZhanTip = ShenShouExtraZhuZhanTip or BaseClass(BaseView)

function ShenShouExtraZhuZhanTip:__init()
	self.ui_config = {"uis/views/shenshouview_prefab","ShenShouExtraZhuZhanTip"}
	self.play_audio = true
end

function ShenShouExtraZhuZhanTip:__delete()

end

function ShenShouExtraZhuZhanTip:ReleaseCallBack()
	if self.stuff_cell then
		self.stuff_cell:DeleteMe()
		self.stuff_cell = nil
	end
	self.text1 = nil
	self.text2 = nil
	self.text3 = nil
end

function ShenShouExtraZhuZhanTip:LoadCallBack()
	self.stuff_cell = ItemCell.New()
	self.stuff_cell:SetInstanceParent(self:FindObj("Item"))

	self.text1 = self:FindVariable("Text1")
	self.text2 = self:FindVariable("Text2")
	self.text3 = self:FindVariable("Text3")

	self:ListenEvent("OnClickYes",BindTool.Bind(self.OnClinkOkHandler, self))
	self:ListenEvent("OnClickNo",BindTool.Bind(self.Close, self))
	self:ListenEvent("OnClickClose",BindTool.Bind(self.Close, self))
end

function ShenShouExtraZhuZhanTip:ShowIndexCallBack()
	self:Flush()
end

function ShenShouExtraZhuZhanTip:OnFlush()
	local extra_num_cfg = ConfigManager.Instance:GetAutoConfig("shenshou_cfg_auto").extra_num_cfg
	local extra_zhuzhan_count = ShenShouData.Instance:GetExtraZhuZhanCount()
	local next_count = extra_zhuzhan_count + 1 < #extra_num_cfg and extra_zhuzhan_count + 1 or #extra_num_cfg
	local num_cfg = ShenShouData.Instance:GetExtraNumCfg(next_count)
	self.stuff_cell:SetData({item_id = num_cfg.stuff_id, is_bind = 1})

	local item_num = ItemData.Instance:GetItemNumInBagById(num_cfg.stuff_id)
	--local color = item_num >= num_cfg.stuff_num and "#0000f1"or "#001828"
	local color = "#0000f1"
	if item_num < num_cfg.stuff_num then
		color = TEXT_COLOR.RED_3
	end
	local str = string.format(Language.Rune.TreasureOneCost, color, item_num,num_cfg.stuff_num)
	self.text3:SetValue(str)
	--local str = "<color=%s>%s/%s</color>"
	--self.text3:SetValue(string.format(str, color, item_num, num_cfg.stuff_num))

	local stuff_name = ItemData.Instance:GetItemName(num_cfg.stuff_id)
	self.text1:SetValue(string.format(Language.ShenShou.RichDes1, stuff_name))
	self.text2:SetValue("")
end

function ShenShouExtraZhuZhanTip:OnClinkOkHandler()
	local extra_zhuzhan_count = ShenShouData.Instance:GetExtraZhuZhanCount()
	local extra_num_cfg = ConfigManager.Instance:GetAutoConfig("shenshou_cfg_auto").extra_num_cfg
	if extra_zhuzhan_count == #extra_num_cfg then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShenShou.ExtraZhuZhanError)
		return
	end
	ShenShouCtrl.Instance:SendShenshouOperaReq(SHENSHOU_REQ_TYPE.SHENSHOU_REQ_TYPE_ADD_ZHUZHAN)
	self:Close()
end