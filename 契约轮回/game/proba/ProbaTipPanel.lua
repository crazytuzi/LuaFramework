ProbaTipPanel = ProbaTipPanel or class("ProbaTipPanel",WindowPanel)
local ProbaTipPanel = ProbaTipPanel

function ProbaTipPanel:ctor()
	self.abName = "proba"
	self.assetName = "ProbaTipPanel"
	self.layer = "UI"

	-- self.change_scene_close = true 				--切换场景关闭
	-- self.default_table_index = 1					--默认选择的标签
	-- self.is_show_money = {Constant.GoldType.Coin,Constant.GoldType.BGold,Constant.GoldType.Gold}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置
	
	self.panel_type = 4								--窗体样式  1 1280*720  2 850*545
	self.model = ProbaTipModel:GetInstance()
	self.item_list = {}
end

function ProbaTipPanel:dctor()
	
end

function ProbaTipPanel:Open(sys_id)
	self.sys_id = sys_id
	ProbaTipPanel.super.Open(self)
end

function ProbaTipPanel:LoadCallBack()
	self.nodes = {
		"ScrollView/Viewport/Content","ScrollView/Viewport/Content/ProbaTipItem",
	}
	self:GetChildren(self.nodes)

	self.ProbaTipItem_go = self.ProbaTipItem.gameObject
	SetVisible(self.ProbaTipItem_go, false)
	self:AddEvent()
	self:SetTileTextImage("proba_image", "proba_title_img")
end

function ProbaTipPanel:AddEvent()

end

function ProbaTipPanel:OpenCallBack()
	self:UpdateView()
end

function ProbaTipPanel:UpdateView( )
	local list = self.model:GetTipList(self.sys_id) or {}
	for i=1, #list do
		local item = ProbaTipItem(self.ProbaTipItem_go, self.Content)
		item:SetData(list[i],i)
		self.item_list[#self.item_list+1] = item
	end
end

function ProbaTipPanel:CloseCallBack(  )
	for i=1, #self.item_list do
		self.item_list[i]:destroy()
	end
	self.item_list = nil
end
function ProbaTipPanel:SwitchCallBack(index)
	if self.table_index == index then
		return
	end
	if self.child_node then
	 	self.child_node:SetVisible(false)
	end
	self.table_index = index
	--if self.table_index == 1 then
		-- if not self.show_panel then
		-- 	self.show_panel = ChildPanel(self.transform)
		-- end
		-- self:PopUpChild(self.show_panel)
	--end
end