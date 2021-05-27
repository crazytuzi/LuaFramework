------------------------------------------------------------
-- "印记祈福"视图
------------------------------------------------------------

local DragonSoulMarkBlessingView = BaseClass(SubView)

function DragonSoulMarkBlessingView:__init()
	self.texture_path_list[1] = 'res/xui/fire_vision.png'
	self.config_tab = {
		{"dragon_soul_ui_cfg", 3, {0}},
	}

	self.data = nil -- "龙魂圣域"数据
end

function DragonSoulMarkBlessingView:__delete()
end

function DragonSoulMarkBlessingView:ReleaseCallBack()

	-- if self.shop_mystical_grid then
	-- 	self.shop_mystical_grid:DeleteMe()
	-- 	self.shop_mystical_grid = nil
	-- end

end

function DragonSoulMarkBlessingView:LoadCallBack(index, loaded_times)
	self.data = DragonSoulData.Instance:GetData() -- 索引龙魂圣域数据(只需获取一次)

	--按钮监听
	XUI.AddClickEventListener(self.node_t_list.btn_2.node, BindTool.Bind(self.OnBtn, self, 1))
	XUI.AddClickEventListener(self.node_t_list.btn_box.node, BindTool.Bind(self.OnBox, self))

	-- 数据监听
	EventProxy.New(DragonSoulData.Instance, self):AddEventListener(DragonSoulData.DRAGON_SOUL_DATA_CHANGE, BindTool.Bind(self.OnDragonSoulDataChange, self))
	-- EventProxy.New(CrossServerData.Instance, self):AddEventListener(CrossServerData.COPY_DATA_CHANGE, BindTool.Bind(self.OnCopyDataChange, self))
end



--显示索引回调
function DragonSoulMarkBlessingView:ShowIndexCallBack(index)
	local text = "祈福次数:" ..  self.data.blessing .. "次"
	self.node_t_list.lbl_number.node:setString(text)
end

----------视图函数----------

-- 创建"物品图标"视图
-- function DragonSoulMarkBlessingView:CreateCellView()

-- end


----------end----------

-- "祈福"按钮点击回调
function DragonSoulMarkBlessingView:OnBtn(index)
	-- 发送"龙魂圣域"祈福请求(144, 2)
	CrossServerCtrl.Instance.SendCrossServerPrayReq(2, index)
end


--打开物品预览
function DragonSoulMarkBlessingView:OnBox()
	-- 设置极品预览显示索引为"商店极品预览"
	PreviewData.Instance:SetPreviewIndex(PreviewData.DRAGON_SOUL_PREVIEW)
	--打开极品预览
	ViewManager.Instance:OpenViewByDef(ViewDef.Preview)
end

function DragonSoulMarkBlessingView:OnDragonSoulDataChange()
	local text = "祈福次数:" ..  self.data.blessing .. "次"
	self.node_t_list.lbl_number.node:setString(text)
end
--------------------

return DragonSoulMarkBlessingView