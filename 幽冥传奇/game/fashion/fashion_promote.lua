FashionPromoteView = FashionPromoteView or BaseClass(XuiBaseView)

function FashionPromoteView:__init()
	self.texture_path_list[1] = 'res/xui/fashion.png'
	self.is_async_load = false
	self.is_any_click_close = true
	self.is_modal = true		
	self.config_tab = {
		{"fashion_ui_cfg", 2, {0}},

	}
end

function FashionPromoteView:__delete()
	
end

function FashionPromoteView:ReleaseCallBack()
	if self.promotevalue_list then
		self.promotevalue_list:DeleteMe()
		self.promotevalue_list = nil
	end

end

function FashionPromoteView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreatPromoteList()
		XUI.AddClickEventListener(self.node_t_list.btn_close_window.node, BindTool.Bind1(self.OnClose, self), true)
	end
	self.can_fetch_pos = FashionData.Instance:GetCanFetchAwardPos()
end

function FashionPromoteView:OpenCallBack()
	-- FashionCtrl.Instance:InfoFaceAward()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function FashionPromoteView:ShowIndexCallBack(index)
	self:Flush(index)
end

function FashionPromoteView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end


function FashionPromoteView:OnFlush(param_t, index)
	-- local remind = FashionData.Instance:GetFaceAwardRemind() > 0
	self:FlushAwardShow()
	self:FlushAtrr()
end

function FashionPromoteView:OnClose()
	self:Close()
end

function FashionPromoteView:CreatPromoteList()
	if nil == self.promotevalue_list then
		self.promotevalue_list = ListView.New()
		local ph = self.ph_list.ph_promote_list
		self.promotevalue_list:Create(ph.x, ph.y, ph.w, ph.h, direction, PromoteViewAttrRender, gravity, is_bounce, self.ph_list.ph_promote_item)
		self.promotevalue_list:SetMargin(5)
		self.promotevalue_list:SetItemsInterval(23)
		self.node_t_list.layout_promote.node:addChild(self.promotevalue_list:GetView(), 100)
	end
end

function FashionPromoteView:FlushAtrr()
	local exp = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BEAUTY_EXP) or 0
	local level, value, name, is_have_nxt = FashionData.Instance:GetFaceLevel(exp)
	local attr_t = FashionData.Instance:GetAttrAddCfg(level)
	self.promotevalue_list:SetDataList(attr_t)
	local next_level, next_value, next_name = FashionData.Instance:GetFaceLevel(value+1)
	if level <= 0 then
		next_level = 1
		next_value, next_name = FationColorCfg[1].value[2], FationColorCfg[1].name
	end
	local next_lv_txt = next_level .." ".. next_name
	if is_have_nxt == false then
		next_lv_txt = Language.Common.Man
	end
	self.node_tree.layout_promote.txt_now_lv_name.node:setString("Lv."..level.." "..name)
	self.node_tree.layout_promote.txt_next_lv_name.node:setString("Lv.".. next_lv_txt)
	self.node_t_list.txt_uplev.node:setString(exp .. "/" .. value)
	self.node_t_list.prog_fashion_uplev.node:setPercent(exp/value * 100)

end


function FashionPromoteView:FlushAwardShow()
	self.can_fetch_pos, is_all_fetched, nex_show_pos = FashionData.Instance:GetCanFetchAwardPos()
	-- local txt = Language.Role.FashionPromoteTxts[1]
	-- if self.can_fetch_pos then
	-- 	txt = Language.Role.FashionPromoteTxts[2]
	-- end

	if not is_all_fetched then
		local data = FashionData.Instance:GetAwardCfg()
		local show_pos = self.can_fetch_pos or nex_show_pos
		local cur_data = data[show_pos]
		self.node_t_list.txt_top_lv.node:setString("")
	else
		
		self.node_t_list.txt_top_lv.node:setString(Language.Common.MaxLvTips)
	end
end

PromoteViewAttrRender = PromoteViewAttrRender or BaseClass(BaseRender)
function PromoteViewAttrRender:__init()
end

function PromoteViewAttrRender:__delete()
end

function PromoteViewAttrRender:CreateChild()
	BaseRender.CreateChild(self)
end


function PromoteViewAttrRender:OnFlush()
	if not self.data then return end 
	local value_str = self.data.type_str.." "..":".." "..self.data.cur_value_str
	local next_value_str = self.data.type_str.." "..":".." "..self.data.nex_value_str
	self.node_tree.txt_now_defense.node:setString(value_str)
	self.node_tree.txt_next_defense.node:setString(next_value_str)
end

function PromoteViewAttrRender:CreateSelectEffect() 
	
end