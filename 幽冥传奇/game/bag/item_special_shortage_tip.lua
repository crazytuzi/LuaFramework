ItemSpecialShortageTipsView = ItemSpecialShortageTipsView or BaseClass(XuiBaseView)
function ItemSpecialShortageTipsView:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)
	self.def_index = 0
	self.texture_path_list[1] = 'res/xui/mainui.png'
	self.texture_path_list[2] = 'res/xui/welfare.png'
	self.config_tab = {
		{"itemtip_ui_cfg", 12, {0}}
	}
	
end

function ItemSpecialShortageTipsView:__delete()
end

function ItemSpecialShortageTipsView:ReleaseCallBack()
	
end

function ItemSpecialShortageTipsView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		XUI.AddClickEventListener(self.node_t_list.btn_check_activity.node, BindTool.Bind1(self.OpenView, self), true)
	end
end

function ItemSpecialShortageTipsView:ShowIndexCallBack(index)
	self:Flush(index)
end
	
function ItemSpecialShortageTipsView:OpenCallBack()
	
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ItemSpecialShortageTipsView:OnFlush(param_t, index)

	local data = BagData.Instance:GetSpecialCfg()
	RichTextUtil.ParseRichText(self.node_t_list.rich_content.node, data.desc, 20, COLOR3B.OLIVE)
	XUI.SetRichTextVerticalSpace(self.node_t_list.rich_content.node,10)
	local path = ResPath.GetWelfare("bg_101")
	if ChargeFirstData.Instance:GetFirstChargeInformation() == 0 then
		path = ResPath.GetCommon("word_bg")
	end
	self.node_t_list.img_charge_bg.node:loadTexture(path)
end

function ItemSpecialShortageTipsView:OpenView()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end

	local data = BagData.Instance:GetSpecialCfg()
	local view_name = data.fun.name
	local view_index = data.fun.index
	ViewManager.Instance:Open(view_name, view_index)
	local def_index = data.fun.def_index 
	local index = OpenServiceAcitivityData.Instance:GetIndexByType(def_index)
	if def_index ~= nil then
		ViewManager.Instance:FlushView(view_name, 0, "SelectData", {key = index})
	end
	ViewManager.Instance:Close(ViewName.ItemSpecialShortageTip)
end

function ItemSpecialShortageTipsView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end
