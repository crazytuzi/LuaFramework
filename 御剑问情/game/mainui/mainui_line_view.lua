MainUILineView = MainUILineView or BaseClass(BaseView)
function MainUILineView:__init()
	self.ui_config = {"uis/views/main_prefab", "LineView"}
	self.play_audio = true
	self.btn_list = {}
	self.line_count = 0
end

function MainUILineView:__delete()

end

function MainUILineView:LoadCallBack()
	self.list = self:FindObj("List")
	self:ListenEvent("Close", BindTool.Bind(self.ClickClose,self))
end

function MainUILineView:ReleaseCallBack()
	self:ClearBtn()
	self.list = nil
end

function MainUILineView:OpenCallBack()
	self.line_count = PlayerData.Instance:GetAttr("open_line") or 0
	if self.line_count <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CanNotChangeLine)
		self:Close()
	end
	self:ClearBtn()
	self:CreateBtn()
end

function MainUILineView:CloseCallBack()

end

function MainUILineView:OnFlush(param)

end

function MainUILineView:ClearBtn()
	for k,v in pairs(self.btn_list) do
		v.obj:Destroy()
		v.cell:DeleteMe()
	end
	self.btn_list = {}
end

function MainUILineView:ClickClose()
	self:Close()
	MapCtrl.Instance:CloseLocalLineButton()
end

function MainUILineView:ClickBtn(index)
	self:Close()
	index = index or 1
	local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
	if index - 1 == scene_key then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotChangeLine)
		return
	end
	Scene.SendChangeSceneLineReq(index - 1)
end

function MainUILineView:CreateBtn()
	PrefabPool.Instance:Load(AssetID("uis/views/main_prefab", "LineButton"), function (prefab)
		if nil == prefab then
			return
		end
		for i = 1, self.line_count do
			local obj = GameObject.Instantiate(prefab)
			PrefabPool.Instance:Free(prefab)
			
			obj.transform:SetParent(self.list.transform, false)
			local btn_view = MainUILineButton.New(obj)
			btn_view:SetCallBack(BindTool.Bind(self.ClickBtn,self, i))
			btn_view:SetIndex(i)
			table.insert(self.btn_list, {obj = obj, cell = btn_view})
		end
	end)
end


---------------------------------------------------------------------------------------------------------------------
MainUILineButton = MainUILineButton or BaseClass(BaseRender)

function MainUILineButton:__init()
	self.name = self:FindVariable("Name")
	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick,self))
	self.index = 1
end

function MainUILineButton:__delete()

end

function MainUILineButton:SetCallBack(call_back)
	self.call_back = call_back
end

function MainUILineButton:SetIndex(index)
	self.index = index
	self.name:SetValue(string.format(Language.Common.Line, index))
end

function MainUILineButton:OnClick()
	if self.call_back then
		self.call_back()
	end
end