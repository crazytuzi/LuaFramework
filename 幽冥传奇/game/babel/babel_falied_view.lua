
BabelFailedView = BabelFailedView or BaseClass(XuiBaseView)

function BabelFailedView:__init()
	self:SetModal(true)
 	self.texture_path_list[1] = "res/xui/strength_fb.png"
 	self.texture_path_list[2] = "res/xui/mainui.png"

 	
	self.config_tab = { --类dom模式,数组顺序决定渲染顺序
		{"welkin_ui_cfg", 9, {0}},
	}
	
end

function BabelFailedView:__delete()
	
end

function BabelFailedView:ReleaseCallBack()
	if self.failed_list ~= nil then
		self.failed_list:DeleteMe()
		self.failed_list = nil 
	end
end

function BabelFailedView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateFailedList()
	end
end

function BabelFailedView:CreateFailedList()
	if self.failed_list == nil then
		local ph = self.ph_list.ph_list
		self.failed_list = ListView.New()
		self.failed_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, FaliedListItem, nil, nil, self.ph_list.ph_list_item)
		self.node_t_list["layout_strength_fail_title"].node:addChild(self.failed_list:GetView(), 999)
		self.failed_list:SetMargin(5)
		self.failed_list:SetItemsInterval(5)
		self.failed_list:SelectIndex(1)
		self.failed_list:GetView():setAnchorPoint(0, 0)
		--self.failed_list:SetJumpDirection(ListView.Top)
		self.failed_list:SetSelectCallBack(BindTool.Bind1(self.SelectEquipListCallBack, self))
	end
end

function BabelFailedView:SelectEquipListCallBack(item, index)
	if item == nil or item:GetData() == nil then return end
	local data = item:GetData()
	if data.index > 0 then	
		ViewManager.Instance:Open(data.view_name, data.index)
	else
		ViewManager.Instance:Open(data.view_name)
	end
	self:Close()
	--end
end

function BabelFailedView:OpenCallBack()

end

function BabelFailedView:CloseCallBack()
	
end

function BabelFailedView:ShowIndexCallBack(index)
	self:Flush(index)
end

--接受信息刷新
function BabelFailedView:OnFlush(param_t, index)
	local data =  BabelData.Instance:GetFailedConfigData()
	self.failed_list:SetDataList(data)
	-- for i = 1, 4 do
	-- 	self.node_t_list["layout_btn_"..i].node:setVisible(false)
	-- end
	-- for i, v in ipairs(data) do
	-- 	if self.node_t_list["layout_btn_"..i] ~= nil then
	-- 		self.node_t_list["layout_btn_"..i].node:setVisible(true)
	-- 		self.node_t_list["btn_timg_"..i].node:loadTexture(ResPath.GetMainui(string.format("icon_%s_img", v.icon)))
	-- 		self.node_t_list["bg_world_"..i].node:loadTexture(ResPath.GetMainui(string.format("icon_%s_word", v.icon)))
	-- 	end 
	-- end
end

function BabelFailedView:OpenView(i)
	-- local data = BabelData.Instance:GetFailedConfigData() 
	-- local cur_data = data[i]
	-- if cur_data ~= nil then
	-- 	if cur_data.index > 0 then	
	-- 		ViewManager.Instance:Open(cur_data.view_name, cur_data.index)
	-- 	else
	-- 		ViewManager.Instance:Open(cur_data.view_name)
	-- 	end
	-- 	self:Close()
	-- end
end

FaliedListItem = FaliedListItem or BaseClass(BaseRender)
function FaliedListItem:__init()
	-- body
end

function FaliedListItem:__delete()
	-- body
end

function FaliedListItem:OnFlush()
	self.node_tree["btn_timg_"..1].node:loadTexture(ResPath.GetMainui(string.format("icon_%s_img", self.data.icon)))
	self.node_tree["bg_world_"..1].node:loadTexture(ResPath.GetMainui(string.format("icon_%s_word", self.data.icon)))
end