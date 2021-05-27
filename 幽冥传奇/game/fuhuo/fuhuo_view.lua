FuhuoView = FuhuoView or BaseClass(BaseView)

FuhuoView.FONTSIZE = 25								-- 字体大小
FuhuoView.RECORD_ALERT_STATUS = false

function FuhuoView:__init()
	self.texture_path_list[1] = 'res/xui/fuhuo.png'
	self.config_tab = {
		{"fuhuo_ui_cfg", 1, {0},},
	}

	self.ctrl = FuhuoCtrl.Instance
	self.rich_tips = nil
	self.fuhuo_layout = nil
	self.is_nolonger = false
	self.is_modal = true
	self.gongneng_sort = {}
	self.killer_name = ""
	self.fuhuo_item_id = CLIENT_GAME_GLOBAL_CFG.fuhuo_item_id
end

function FuhuoView:__delete()
end

function FuhuoView:ReleaseCallBack()
	if BagData.Instance and self.bag_item_change then
		BagData.Instance:RemoveEventListener(self.bag_item_change)
	end
end

function FuhuoView:LoadCallBack()
	self.fuhuo_layout = self.node_tree.layout_fuhuo
	self.rich_tips = self.node_t_list.rich_tips.node
	self.rich_manhuo = self.node_t_list.rich_manhuo.node
	XUI.RichTextSetCenter(self.rich_tips)
	self.btn_manhuo = self.node_t_list.btn_manhuo.node
	self.btn_fuhuodian = self.node_t_list.btn_fuhuodian.node
	self:RegisterEvents()
end

function FuhuoView:ShowIndexCallBack()
	self:Flush()
end

function FuhuoView:CloseCallBack()
	self:SetKillerName("")
end

function FuhuoView:SetKillerName(killer_name)
	self.killer_name = killer_name or ''
	self:Flush(0, "killer_name")
end

function FuhuoView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "all" then
			local area_info = Scene.Instance:GetCurAreaInfo()
			self.btn_manhuo:setEnabled(not area_info.attr_t[MapAreaAttribute.aaNotHereRelive])
			self:UpdateFuhuoStuff()
		elseif k == "killer_name" then
			if self.rich_tips then
				local tips = string.format(Language.Fuhuo.FuHuoTips, self.killer_name)
				RichTextUtil.ParseRichText(self.rich_tips, tips, FuhuoView.FONTSIZE, COLOR3B.WHITE)
			end
		elseif k == "stuff_change" then
			self:UpdateFuhuoStuff()
		end
	end
end
----------------------------------------------
function FuhuoView:RegisterEvents()
	XUI.AddClickEventListener(self.btn_manhuo, BindTool.Bind(self.OnGoldFuHuoHandler, self), true)
	XUI.AddClickEventListener(self.btn_fuhuodian, BindTool.Bind(self.OnFuhuoDianHandler, self), true)
	BagData.Instance:AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
end

function FuhuoView:UpdateFuhuoStuff()
	local stuff_cfg = ItemData.Instance:GetItemConfig(self.fuhuo_item_id)
	if nil == stuff_cfg then return end
	self.rich_manhuo:removeAllElements()
	local text_node = RichTextUtil.CreateLinkText(stuff_cfg.name, 22, COLOR3B.GREEN)
	if nil ~= text_node then
		XUI.RichTextAddElement(self.rich_manhuo, text_node)
		XUI.AddClickEventListener(text_node, function()
			TipCtrl.Instance:OpenQuickBuyItem({self.fuhuo_item_id})
		end, true)
	end
	local stuff_count = BagData.Instance:GetItemNumInBagById(self.fuhuo_item_id)
	local color = stuff_count > 0 and COLOR3B.GREEN or COLOR3B.RED
	RichTextUtil.AddText(self.rich_manhuo, "(" .. stuff_count .. "/1)", 22, color)
end

-- 复活成功后关闭面板和消除倒计时
function FuhuoView:FuhuoCallback()
	self:Close()
end

--点击元宝复活
function FuhuoView:OnGoldFuHuoHandler()
	if BagData.Instance:GetItemNumInBagById(self.fuhuo_item_id) <= 0 then	
		TipCtrl.Instance:OpenQuickTipItem(false, {self.fuhuo_item_id, 3, 1})
	else
		FuhuoCtrl.SendFuhuoReq(REALIVE_TYPE.REALIVE_TYPE_HERE_GOLD)
	end
end

-- 点击复活点复活
function FuhuoView:OnFuhuoDianHandler()
	 FuhuoCtrl.SendFuhuoReq(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
end

function FuhuoView:OnBagItemChange(event)
	event.CheckAllItemDataByFunc(function (vo)
		if vo.change_type == ITEM_CHANGE_TYPE.LIST or vo.data.item_id == self.fuhuo_item_id then
			self:Flush(0, "stuff_change")
		end
	end)
end
