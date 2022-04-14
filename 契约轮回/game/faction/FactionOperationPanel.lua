--
-- @Author: chk
-- @Date:   2018-12-07 11:28:04
--
FactionOperationPanel = FactionOperationPanel or class("FactionOperationPanel",WindowPanel)
local FactionOperationPanel = FactionOperationPanel

function FactionOperationPanel:ctor()
	self.abName = "faction"
	self.assetName = "FactionOperationPanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true

	self.model = FactionModel:GetInstance()
	self.viewNodes = {}
	self.viewCls = {}
	self.viewCls[1] = FactionLogView
	self.viewCls[2] = FactionCareerApplyView
	self.show_sidebar = true		--是否显示侧边栏
	if self.show_sidebar then		-- 侧边栏配置
		self.sidebar_data = {
			{text = ConfigLanguage.Faction.Log,id = 1,img_title = "faction:faction_operate_f",},
			{text = ConfigLanguage.Faction.CareerApply,id = 2,img_title = "faction:faction_operate_f",},
		}
	end
end

function FactionOperationPanel:dctor()
end

function FactionOperationPanel:Open( index )
	self.default_table_index = index
	FactionOperationPanel.super.Open(self)
end

function FactionOperationPanel:LoadCallBack()
	self.nodes = {
		"panelContain",
	}
	self:GetChildren(self.nodes)

	self:AddEvent()
end

function FactionOperationPanel:AddEvent()

end

function FactionOperationPanel:OpenCallBack()
	self:SetTabIndex(self.model.equipUpPanelIndex)
	--self:UpdateView()
end

function FactionOperationPanel:UpdateView( )

end

function FactionOperationPanel:CloseCallBack( index )
	if self.lastView ~= nil then
		SetVisible(self.lastView.gameObject,false)
	end

	if self.viewNodes[index] == nil then
		self.viewNodes[index] = self.viewCls[index](self.panelContain)
	else
		SetVisible(self.viewNodes[index].gameObject,true)
	end

	self.lastView = self.viewNodes[index]
end