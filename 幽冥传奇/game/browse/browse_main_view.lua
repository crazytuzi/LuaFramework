BrowseMainView = BrowseMainView or BaseClass(BaseView)
function BrowseMainView:__init( ... )
	self.view_cache_time = 0
	self.config_tab = {
		
   		{"browse_ui_cfg", 2, {0}},
   		
	}
	self.btn_info = {ViewDef.Browse.Role, ViewDef.Browse.XingHun, }

	self.remind_list = {}
	
	require("scripts/game/browse/browse_view").New(ViewDef.Browse.Role)
	require("scripts/game/browse/browse_xinghun_view").New(ViewDef.Browse.XingHun)
end



function BrowseMainView:__delete( ... )
	-- body
end

function BrowseMainView:ReleaseCallBack( ... )
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil 
	end 
end

function BrowseMainView:LoadCallBack( ... )
	if  nil == self.tabbar then
		self.tabbar = Tabbar.New()
		self.tabbar:SetTabbtnTxtOffset(2, 12)
		self.tabbar:SetClickItemValidFunc(function(index)
			return ViewManager.Instance:CanOpen(self.btn_info[index]) 
		end)
		self.tabbar:CreateWithNameList(self:GetRootNode(), -46, 580, BindTool.Bind(self.TabSelectCellBack, self),
			Language.Browse.TabGroup, true, ResPath.GetCommon("toggle_110"), 25, true)
	end
	self.tabbar:ChangeToIndex(index or 1)
end

function BrowseMainView:TabSelectCellBack(index)
	ViewManager.Instance:OpenViewByDef(self.btn_info[index])
end

function BrowseMainView:OpenCallBack( ... )
	-- body
end

function BrowseMainView:ShowIndexCallBack(index)
	self:FlushIndex(index)
	--ViewManager.Instance:OpenViewByDef(self.btn_info[index])
end

function BrowseMainView:CloseCallBack( ... )
	-- body
end

function BrowseMainView:OnFlush( ... )
	-- body
end
