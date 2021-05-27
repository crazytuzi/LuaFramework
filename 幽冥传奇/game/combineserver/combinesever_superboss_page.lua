CombineServerSuperBossPage = CombineServerSuperBossPage or BaseClass()


function CombineServerSuperBossPage:__init()
	
end	

function CombineServerSuperBossPage:__delete()
	self:RemoveEvent()
end	

--初始化页面接口
function CombineServerSuperBossPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:InitEvent()
	
end	


--初始化事件
function CombineServerSuperBossPage:InitEvent()
	self.view.node_t_list["btn_transmit"].node:addClickEventListener(BindTool.Bind(self.OnTransmitBoss, self))
	local boss_type = CombineServerData.GetBossActivityType() or 1
	self.view.node_t_list["img_bg_boss"].node:loadTexture(ResPath.GetBigPainting("combineserver_boss_"..boss_type, true))
end

--移除事件
function CombineServerSuperBossPage:RemoveEvent()
	
end

--更新视图界面
function CombineServerSuperBossPage:UpdateData(data)
	
end	

function CombineServerSuperBossPage:OnTransmitBoss()
	CombineServerCtrl.Instance:ReqTransmitToBoss()
end