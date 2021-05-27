require("scripts/game/recycleYB/recycle_yb_info")
require("scripts/game/recycleYB/recycle_yb_journal")


RecycleYBView = RecycleYBView or BaseClass(XuiBaseView)

function RecycleYBView:__init()
	self:SetModal(true)
	self.def_index = TabIndex.recycle_yb_info
	self.is_async_load = false
	self.texture_path_list[1] = 'res/xui/recycleYB.png'
    self.config_tab = {
    	{"common_ui_cfg", 5, {0}},
		{"common_ui_cfg", 1, {0}},
		{"recycle_yb_ui_cfg", 1, {TabIndex.recycle_yb_info}},
		{"recycle_yb_ui_cfg", 2, {TabIndex.recycle_yb_journal}},
		{"common_ui_cfg", 2, {0}},
	}
	--页面表
	self.page_list = {}
	self.page_list[TabIndex.recycle_yb_info] = RecycleYBInfoView.New()
	self.page_list[TabIndex.recycle_yb_journal] = RecycleYBJournalView.New()
	self.tabbar = TabbarTwo.New(Str2C3b("fff999"), Str2C3b("bdaa93"))
	self.tabbar:SetInterval(-4)
	self.tabbar:Init(Language.RecycleYB.TabGroup, {}, true)
	
	self.tabbar:SetSelectCallback(BindTool.Bind1(self.OnTabChangeHandler, self))
	--self.tabbar:SetGroupPosition(930, 600)
	self.title_img_path = ResPath.GetRecycleYB("txt_headbj")
	self.remind_temp = {}
	GlobalEventSystem:Bind(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.UptateTabbarRemind, self))
end


function RecycleYBView:__delete()
	self.tabbar:DeleteMe()
	self.tabbar = nil
end
function RecycleYBView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:Release()
	end
	--清理页面生成信息
	for k,v in pairs(self.page_list) do
		v:DeleteMe()
	end
		if self.time_event then
	 		GlobalEventSystem:UnBind(self.time_event)
	  		self.time_event = nil
  		end	
	ViewManager.Instance:UnRegsiterTabFunUi(ViewName.RecycleYB)
end

function RecycleYBView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		ViewManager.Instance:RegsiterTabFunUi(ViewName.RecycleYB, self.tabbar)
		self.time_event = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind1(self.OnCheckCloseView, self))
	end

	if nil == self.page_list[index] then
		return
	end
	--初始化页面接口
	self.page_list[index]:InitPage(self)
	
end
function RecycleYBView:OpenCallBack()
	self.tabbar:ChangeToIndex(self.show_index, self.root_node)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function RecycleYBView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function RecycleYBView:ShowIndexCallBack(index)
	self.tabbar:ChangeToIndex(index, self.root_node)
	self:Flush(index)
end

function RecycleYBView:OnTabChangeHandler(index)
	self:ChangeToIndex(index)
end


function RecycleYBView:OnGetUiNode(node_name)
	local node, is_next = XuiBaseView.OnGetUiNode(self, node_name)
	if node then
		return XuiBaseView.OnGetUiNode(self, node_name) 
	end
end
function RecycleYBView:OnFlush(param_t, index)
	for k,v in pairs(param_t) do
		if k == "all" then
			self:FlushTabbarRemind()
		elseif k == "key" then
			self:FlushTabbarRemind()
		end
	end
	if nil ~= self.page_list[index] then
		--更新页面接口
		self.page_list[index]:UpdateData(param_t)
	end
end
function RecycleYBView:UptateTabbarRemind()
	self:Flush(0, "key")
end

function RecycleYBView:FlushTabbarRemind()
	self.tabbar:SetRemindByIndex(TabIndex.recycle_yb_info, RemindManager.Instance:GetRemind(RemindName.RecycleYB) > 0)
end
function RecycleYBView:OnCheckCloseView()
	if  not RecycleYBData.Instance:RecycleYBOpen() then
		self:Close()
	end
end