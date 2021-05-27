-- 特殊的特殊npc对话框
ItemUesSpecialView = ItemUesSpecialView or BaseClass(XuiBaseView)

function ItemUesSpecialView:__init()
end

function ItemUesSpecialView:__delete()

end

function ItemUesSpecialView:OnFlush(param_list, index)

end

function ItemUesSpecialView:ReleaseCallBack()

end

function ItemUesSpecialView:LoadCallBack(index, loaded_time)

end

function ItemUesSpecialView:Open(index)
	Scene.Instance:CommonSwitchTransmitSceneReq(index)
	ViewManager.Instance:Close(ViewName.Bag)
	self:Close()
end