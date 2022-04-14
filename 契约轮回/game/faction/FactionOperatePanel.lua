--
-- @Author: chk
-- @Date:   2018-12-21 18:43:43
--
FactionOperatePanel = FactionOperatePanel or class("FactionOperatePanel",WindowPanel)
local FactionOperatePanel = FactionOperatePanel

function FactionOperatePanel:ctor()
	self.abName = "faction"
	self.assetName = "FactionOperatePanel"
	self.layer = "UI"

	self.panel_type = 5
	self.viewIndex = 1
	self.viewNodes = {}
	self.viewCls = {}
	self.events = {}
	self.model = FactionModel:GetInstance()
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

function FactionOperatePanel:dctor()
	for i, v in pairs(self.viewNodes) do
		v:destroy()
	end
	for i, v in pairs(self.events) do
		self.model:RemoveListener(v)
	end
end

function FactionOperatePanel:Open( index)
	self.default_table_index = index
	FactionOperatePanel.super.Open(self)
end

function FactionOperatePanel:LoadCallBack()
	self.nodes = {
		"panelContain",
	}
	self:GetChildren(self.nodes)

	self:AddEvent()
	self:UpdateRedDot()
end

function FactionOperatePanel:AddEvent()
	self.events[#self.events + 1] = self.model:AddListener(FactionEvent.UpdateRedDot, handler(self, self.UpdateRedDot))
end

function FactionOperatePanel:OpenCallBack()
	--self:SetTabIndex(self.index)
end

function FactionOperatePanel:UpdateRedDot()
	self:SetIndexRedDotParam(2,self.model.redPoints[1])
end

function FactionOperatePanel:UpdateView( )

end

function FactionOperatePanel:CloseCallBack(  )

end

function FactionOperatePanel:SwitchCallBack(index)
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