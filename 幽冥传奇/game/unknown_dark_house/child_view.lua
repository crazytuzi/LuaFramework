------------------------------------------------------------
-- 神秘商店视图
------------------------------------------------------------

local ShopMysticalView = BaseClass(SubView)

function ShopMysticalView:__init()
	self.texture_path_list[1] = 'res/xui/shangcheng.png'
	self.config_tab = {
		{"shop_ui_cfg", 2, {0}},
	}
end

function ShopMysticalView:__delete()
end

function ShopMysticalView:ReleaseCallBack()

	-- if self.shop_mystical_grid then
	-- 	self.shop_mystical_grid:DeleteMe()
	-- 	self.shop_mystical_grid = nil
	-- end

end

function ShopMysticalView:LoadCallBack(index, loaded_times)

	--按钮监听
	-- XUI.AddClickEventListener(self.node_t_list.btn_re.node, BindTool.Bind(self.MyShopRefreshCallBack, self), true)

	-- 数据监听
	-- EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.OnRoleAttrChange, self))

end

--显示索引回调
function ShopMysticalView:ShowIndexCallBack(index)

end

----------视图函数----------

function ShopMysticalView:Create()

end

function ShopMysticalView:InitView()

end

function ShopMysticalView:FlushView()

end

----------end----------

--------------------



return ShopMysticalView