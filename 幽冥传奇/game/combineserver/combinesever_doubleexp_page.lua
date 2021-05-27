CombineServerDoubleExpPage = CombineServerDoubleExpPage or BaseClass()


function CombineServerDoubleExpPage:__init()
	
end	

function CombineServerDoubleExpPage:__delete()
	if self.map_alert ~= nil then
		self.map_alert:DeleteMe()
		self.map_alert = nil 
	end
	self:RemoveEvent()
end	

--初始化页面接口
function CombineServerDoubleExpPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:InitEvent()
	
end	


--初始化事件
function CombineServerDoubleExpPage:InitEvent()
	self.view.node_t_list["btn_guaji"].node:addClickEventListener(BindTool.Bind1(self.TransmitNpc, self))
end

--移除事件
function CombineServerDoubleExpPage:RemoveEvent()
	
end

--更新视图界面
function CombineServerDoubleExpPage:UpdateData(data)
	
end	

function CombineServerDoubleExpPage:TransmitNpc()
	if self.map_alert == nil then
		self.map_alert = Alert.New()
	end
	self.map_alert:SetShowCheckBox(true)
	self.map_alert:SetLableString(Language.Map.DeliveryNpcTips)
	self.map_alert:SetOkFunc(function ()
		Scene.Instance:CommonSwitchTransmitSceneReq(109)
		ViewManager.Instance:Close(ViewName.CombineServerActivity)
  	end)
	self.map_alert:Open()
end
