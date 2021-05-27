------------------------------------------------------------
-- "印记祈福"视图 配置 flamingFantasyCfg
------------------------------------------------------------

local MarkBlessingView = BaseClass(SubView)

function MarkBlessingView:__init()
	self.texture_path_list[1] = 'res/xui/fire_vision.png'
	self.config_tab = {
		{"fire_vision_ui_cfg", 3, {0}},
	}

	self.data = nil -- "烈焰幻境"数据
end

function MarkBlessingView:__delete()
end

function MarkBlessingView:ReleaseCallBack()

	-- if self.shop_mystical_grid then
	-- 	self.shop_mystical_grid:DeleteMe()
	-- 	self.shop_mystical_grid = nil
	-- end

end

function MarkBlessingView:LoadCallBack(index, loaded_times)
	self.data = FireVisionData.Instance:GetData() -- 索引烈焰幻境数据(只需获取一次)

	--按钮监听
	XUI.AddClickEventListener(self.node_t_list.btn_2.node, BindTool.Bind(self.OnBtn, self, 1))
	XUI.AddClickEventListener(self.node_t_list.btn_box.node, BindTool.Bind(self.OnBox, self, 1))

	-- 数据监听
	EventProxy.New(FireVisionData.Instance, self):AddEventListener(FireVisionData.FIRE_VISION_DATA_CHANGE, BindTool.Bind(self.OnFireVisionDataChange, self))
	-- EventProxy.New(CrossServerData.Instance, self):AddEventListener(CrossServerData.COPY_DATA_CHANGE, BindTool.Bind(self.OnCopyDataChange, self))

end

--显示索引回调
function MarkBlessingView:ShowIndexCallBack(index)
	local text = "祈福次数:" ..  self.data.blessing .. "次"
	self.node_t_list["lbl_number"].node:setString(text)
end

----------视图函数----------


-- 创建"物品图标"视图
-- function MarkBlessingView:CreateCellView()

-- end


----------end----------

-- "挑战"按钮点击回调
function MarkBlessingView:OnBtn(index)
	-- 发送"烈焰幻境"祈福请求(144, 2)
	CrossServerCtrl.Instance.SendCrossServerPrayReq(1, index)
end

--打开极品预览
function MarkBlessingView:OnBox()
	-- 设置极品预览显示索引为"烈焰幻境"
	PreviewData.Instance:SetPreviewIndex(PreviewData.FIRE_VISION_PREVIEW)
	--打开极品预览
	ViewManager.Instance:OpenViewByDef(ViewDef.Preview)
end

function MarkBlessingView:OnFireVisionDataChange()
	local text = "祈福次数:" ..  self.data.blessing .. "次"
	self.node_t_list["lbl_number"].node:setString(text)
end

--------------------

return MarkBlessingView