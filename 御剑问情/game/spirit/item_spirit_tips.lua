ItemSpritSkill = ItemSpritSkill or BaseClass(BaseView)

function ItemSpritSkill:__init()
	self.ui_config = {"uis/views/spiritview_prefab", "ItemSpritSkill"}
	self.view_layer = UiLayer.Pop
end

function ItemSpritSkill:__delete()

end

function ItemSpritSkill:ReleaseCallBack()

end

function ItemSpritSkill:LoadCallBack()

	self:ListenEvent("click1", BindTool.Bind(self.click1, self))
	self:ListenEvent("click2", BindTool.Bind(self.click2, self))
	self:ListenEvent("CloseView", BindTool.Bind(self.CloseView, self))

end

function ItemSpritSkill:OpenCallBack()

end

function ItemSpritSkill:CloseCallBack()

end

function ItemSpritSkill:click1()
	ViewManager.Instance:Open(ViewName.Shop, TabIndex.shop_sprits_skill)
	self:Close()
end

function ItemSpritSkill:click2()
	SpiritCtrl.Instance:OpenHunt()
	self:Close()
end

function ItemSpritSkill:CloseView()
	self:Close()
end