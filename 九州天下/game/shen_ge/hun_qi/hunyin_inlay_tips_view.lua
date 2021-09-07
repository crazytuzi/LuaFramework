HunYinInlayTips = HunYinInlayTips or BaseClass(BaseView)
function HunYinInlayTips:__init()
	self.ui_config = {"uis/views/hunqiview", "HunYinInlayTips"}
end

function HunYinInlayTips:__delete()
	-- body
end

function HunYinInlayTips:LoadCallBack()
	self.name  = self:FindVariable("name")
	self.icon = self:FindVariable("icon")
	self.hp = self:FindVariable("hp")
	self.fangyu = self:FindVariable("fangyu")
	self.mingzhong = self:FindVariable("mingzhong")
	self.gongji = self:FindVariable("gongji")
	self.shanbi = self:FindVariable("shanbi")
	self.baoji = self:FindVariable("baoji")
	self.jianren = self:FindVariable("jianren")
	self.power = self:FindVariable("power")

	-- 魂印属性
	self.pai_attr_value = {}
	self.pai_attr_txt = {}
	for k = 1, 4 do
		self.pai_attr_value[k] = self:FindVariable("attr_" .. k)
		self.pai_attr_txt[k] = self:FindVariable("attr_txt_" .. k)
	end
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickInlay", BindTool.Bind(self.OnClickInlay, self))

	self.hunyin_info = HunQiData.Instance:GetHunQiInfo()
end

function HunYinInlayTips:ReleaseCallBack()
	self.name = nil
	self.icon = nil
	self.hp = nil
	self.fangyu = nil
	self.mingzhong = nil
	self.gongji = nil
	self.shanbi = nil
	self.baoji = nil
	self.jianren = nil
	self.power = nil
	for k = 1, 4 do
		self.pai_attr_value[k] = nil
		self.pai_attr_txt[k] = nil
	end
end

function HunYinInlayTips:OpenCallBack()
	self.current_hunqi_index, self.current_hunyin_index, self.current_item_id = self.open_callback()
	local item_config =  self.hunyin_info[self.current_item_id][1]
	if nil ~= item_config then
		self.name:SetValue(Language.HunYinSuit["color_"..item_config.hunyin_color]..item_config.name.."</color>")
		self.icon:SetAsset(ResPath.GetItemIcon(HunQiData.Instance:GetHunYinItemIconId(self.current_item_id)))
		self.hp:SetValue(item_config.maxhp)
		self.fangyu:SetValue(item_config.fangyu)
		self.mingzhong:SetValue(item_config.mingzhong)
		self.gongji:SetValue(item_config.gongji)
		self.shanbi:SetValue(item_config.shanbi)
		self.baoji:SetValue(item_config.baoji)
		self.jianren:SetValue(item_config.jianren)
		self.power:SetValue(CommonDataManager.GetCapability(item_config))
		self:FlushSoulAttr(item_config)
	end
end

function HunYinInlayTips:CloseCallBack()
	self.current_hunqi_index = nil
	self.current_hunyin_index = nil
	self.current_item_id = nil
end

function HunYinInlayTips:OnClickInlay()
	local is_lock, need_level = HunQiData.Instance:IsHunYinLockAndNeedLevel(self.current_hunqi_index, self.current_hunyin_index)
	if is_lock then
		SysMsgCtrl.Instance:ErrorRemind(Language.HunQi.HunYinLock)
		return
	end
	HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_HUNYIN_INLAY, self.current_hunqi_index - 1, 
		self.current_hunyin_index - 1, ItemData.Instance:GetItemIndex(self.current_item_id))
	self:OnClickClose()
end

function HunYinInlayTips:FlushSoulAttr(attr_data,next_attr_info)
	local result_data = HunQiData.Instance:GetSloatAndSortAttr(attr_data,next_attr_info)
	local count = 1
	for k,v in pairs(result_data) do
		for v1, v2 in pairs(v) do
			self.pai_attr_txt[count]:SetValue(v1)
			self.pai_attr_value[count]:SetValue(v2)
		end
		count = count + 1
		if count > 4 then
			break
		end
	end
end

function HunYinInlayTips:OnClickClose()
	self.close_callback()
	self:Close()
end

function HunYinInlayTips:SetCloseCallBack(callback)
	self.close_callback = callback
end

function HunYinInlayTips:SetOpenCallBack(callback)
	self.open_callback = callback
end