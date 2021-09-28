TianShenHuTiSkillView = TianShenHuTiSkillView or BaseClass(BaseView)
function TianShenHuTiSkillView:__init()
	self.ui_config = {"uis/views/tianshenhutiview_prefab","TianShenSkillTips"}
	self.full_screen = false
end

function TianShenHuTiSkillView:__delete()
end

function TianShenHuTiSkillView:LoadCallBack()
	self.skill_list = {}
	self.list_view = self:FindObj("ListView")
	self:ListenEvent("OnClickClose", BindTool.Bind(self.CloseView,self))
	local scroller_delegate = self.list_view.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function TianShenHuTiSkillView:GetNumberOfCells()
	-- local info = ActivityData.Instance:GetActivityLogInfo()
	-- if info and info.count then
	-- 	return info.count
	-- end
	local cfg = TianshenhutiData.Instance:GetTaoZhuangSkillCfg()
	local num = 0

	if nil ~= next(cfg) then
		num = #cfg + 1
	end

	return num
end

function TianShenHuTiSkillView:RefreshCell(cell, data_index)
	-- local cfg = ActivityData.Instance:GetActivityLogInfo()
	local cfg = TianshenhutiData.Instance:GetTaoZhuangSkillCfg()
	local the_cell = self.skill_list[cell]

	if nil ~= cfg then
		if the_cell == nil then
			the_cell = TianShenHuTiSkillItem.New(cell.gameObject)
			self.skill_list[cell] = the_cell
		end
		the_cell:SetData(cfg[data_index])
	end
end

function TianShenHuTiSkillView:OpenCallBack()
	self.list_view.scroller:ReloadData(0)
end

function TianShenHuTiSkillView:OnFlush()

end

function TianShenHuTiSkillView:CloseView()
	self:Close()
end

function TianShenHuTiSkillView:CloseCallBack()

end

function TianShenHuTiSkillView:ReleaseCallBack()
	self.list_view = nil
	for k, v in pairs(self.skill_list) do
		v:DeleteMe()
	end

	self.skill_list = {}
end

--------------抽奖列表
TianShenHuTiSkillItem = TianShenHuTiSkillItem or BaseClass(BaseCell)
function TianShenHuTiSkillItem:__init()
	self.text = self:FindVariable("text")
	self.image = self:FindVariable("image")
	self.name = self:FindVariable("name")
end

function  TianShenHuTiSkillItem:__delete()

end

function TianShenHuTiSkillItem:OnFlush()
	local asset1, bundle1 = ResPath.GetTianShenSkill(self.data.active_skill_id)
	local asset2, bundle2 = ResPath.GetTianShenSkillName(self.data.active_skill_id)
	self.text:SetValue(self.data.skill_explain)
	self.image:SetAsset(asset1, bundle1)
	self.name:SetAsset(asset2, bundle2)
end