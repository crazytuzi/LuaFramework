CombineServerExplorePage = CombineServerExplorePage or BaseClass()


function CombineServerExplorePage:__init()
	
end	

function CombineServerExplorePage:__delete()
	self:RemoveEvent()
end	

--初始化页面接口
function CombineServerExplorePage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:InitEvent()
	
end	


--初始化事件
function CombineServerExplorePage:InitEvent()
	self.view.node_t_list["btn_xunbao"].node:addClickEventListener(BindTool.Bind1(self.OpenXunBaoView, self))
end

--移除事件
function CombineServerExplorePage:RemoveEvent()
	
end

--更新视图界面
function CombineServerExplorePage:UpdateData(data)
	
end	

function CombineServerExplorePage:OpenXunBaoView()
	ViewManager.Instance:Open(ViewName.Explore)
end