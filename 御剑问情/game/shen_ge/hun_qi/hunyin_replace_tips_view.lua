HunYinReplaceTipsView = HunYinReplaceTipsView or BaseClass(BaseView)
function HunYinReplaceTipsView:__init()
	self.ui_config = {"uis/views/hunqiview_prefab", "HunYinReplaceTips"}
end

function HunYinReplaceTipsView:__delete()
	-- body
end

function HunYinReplaceTipsView:LoadCallBack()
	self.name_new = self:FindVariable("name_new")
	self.icon_new = self:FindVariable("icon_new")
	self.hp_new = self:FindVariable("hp_new")
	self.fangyu_new = self:FindVariable("fangyu_new")
	self.mingzhong_new = self:FindVariable("mingzhong_new")
	self.gongji_new = self:FindVariable("gongji_new")
	self.baoji_new = self:FindVariable("baoji_new")
	self.jianren_new = self:FindVariable("jianren_new")
	self.sanbi_new = self:FindVariable("sanbi_new")
	self.power_new = self:FindVariable("power_new")

	self.name_old = self:FindVariable("nane_old")
	self.icon_old = self:FindVariable("icon_old")
	self.hp_old = self:FindVariable("hp_old")
	self.fangyu_old = self:FindVariable("fangyu_old")
	self.mingzhong_old = self:FindVariable("mingzhong_old")
	self.gongji_old = self:FindVariable("gongji_old")
	self.baoji_old = self:FindVariable("baoji_old")
	self.jianren_old = self:FindVariable("jianren_old")
	self.shanbi_old = self:FindVariable("shanbi_old")
	self.power_old = self:FindVariable("power_old")

	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickYes", BindTool.Bind(self.OnClickYes, self))

	self.hunyin_info = HunQiData.Instance:GetHunQiInfo()
	self.current_hunqi_index = 0
	self.current_hunyin_index = 0
	self.current_item_id = 0
end

function HunYinReplaceTipsView:ReleaseCallBack()
	self.name_new = nil
	self.icon_new = nil
	self.hp_new = nil
	self.fangyu_new = nil
	self.mingzhong_new = nil
	self.gongji_new = nil
	self.baoji_new = nil
	self.jianren_new = nil
	self.sanbi_new = nil
	self.power_new = nil

	self.name_old = nil
	self.icon_old = nil
	self.hp_old = nil
	self.fangyu_old = nil
	self.mingzhong_old = nil
	self.gongji_old = nil
	self.baoji_old = nil
	self.jianren_old = nil
	self.shanbi_old = nil
	self.power_old = nil

	self.current_item_id = nil
	self.current_hunqi_index = nil
	self.current_hunyin_index = nil
end

function HunYinReplaceTipsView:OpenCallBack()
	local old_item_id = 0
	old_item_id , self.current_item_id, self.current_hunqi_index, self.current_hunyin_index = self.open_callback()
	local old_item_info = self.hunyin_info[old_item_id][1]
	local new_item_info = self.hunyin_info[self.current_item_id][1]

	self.name_new:SetValue(Language.HunYinSuit["color_"..new_item_info.hunyin_color]..new_item_info.name.."</color>")
	self.icon_new:SetAsset(ResPath.GetItemIcon(HunQiData.Instance:GetHunYinItemIconId(new_item_info.hunyin_id)))
	self.hp_new:SetValue(new_item_info.maxhp)
	self.fangyu_new:SetValue(new_item_info.fangyu)
	self.mingzhong_new:SetValue(new_item_info.mingzhong)
	self.gongji_new:SetValue(new_item_info.gongji)
	self.baoji_new:SetValue(new_item_info.baoji)
	self.jianren_new:SetValue(new_item_info.jianren)
	self.sanbi_new:SetValue(new_item_info.shanbi)
	self.power_new:SetValue(CommonDataManager.GetCapability(new_item_info))

	self.name_old:SetValue(Language.HunYinSuit["color_"..old_item_info.hunyin_color]..old_item_info.name.."</color>")
	self.icon_old:SetAsset(ResPath.GetItemIcon(HunQiData.Instance:GetHunYinItemIconId(old_item_info.hunyin_id)))
	self.hp_old:SetValue(old_item_info.maxhp)
	self.fangyu_old:SetValue(old_item_info.fangyu)
	self.mingzhong_old:SetValue(old_item_info.mingzhong)
	self.gongji_old:SetValue(old_item_info.gongji)
	self.baoji_old:SetValue(old_item_info.baoji)
	self.jianren_old:SetValue(old_item_info.jianren)
	self.shanbi_old:SetValue(old_item_info.shanbi)
	self.power_old:SetValue(CommonDataManager.GetCapability(old_item_info))
end

function HunYinReplaceTipsView:OnClickYes()
	HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_HUNYIN_INLAY, self.current_hunqi_index - 1, 
		self.current_hunyin_index - 1, ItemData.Instance:GetItemIndex(self.current_item_id))
	self:OnClickClose()
end

function HunYinReplaceTipsView:OnClickClose()
	self.close_callback()
	self:Close()
end

function HunYinReplaceTipsView:SetOpenCallBack(callback)
	self.open_callback = callback
end

function HunYinReplaceTipsView:SetCloseCallBack(callback)
	self.close_callback = callback
end