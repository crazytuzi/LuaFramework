-- 开服寻宝
OpenServerExplorePage = OpenServerExplorePage or BaseClass()
function OpenServerExplorePage:__init()
	
end	

function OpenServerExplorePage:__delete()
	self:RemoveEvent()
end	

--初始化页面接口
function OpenServerExplorePage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:InitEvent()
	
end	


--初始化事件
function OpenServerExplorePage:InitEvent()
	self.view.node_t_list["btn_xunbao"].node:addClickEventListener(BindTool.Bind1(self.OpenXunBaoView, self))
end

--移除事件
function OpenServerExplorePage:RemoveEvent()
	
end

--更新视图界面
function OpenServerExplorePage:UpdateData(data)
	
end	

function OpenServerExplorePage:OpenXunBaoView()
	ViewManager.Instance:Open(ViewName.Explore)
end