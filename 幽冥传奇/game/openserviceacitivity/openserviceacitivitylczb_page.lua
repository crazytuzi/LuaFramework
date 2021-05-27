-- 龙城争霸
OpenServiceAcitivityLcZbPage = OpenServiceAcitivityLcZbPage or BaseClass()

function OpenServiceAcitivityLcZbPage:__init()
	
	
end	

function OpenServiceAcitivityLcZbPage:__delete()
	self:RemoveEvent()
	if self.show_cell ~= nil then
		for i, v in ipairs(self.show_cell) do
			v:DeleteMe()
		end
		self.show_cell = {}
	end
end	

--初始化页面接口
function OpenServiceAcitivityLcZbPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:CreateCell()
	self:InitEvent()
	
end	

--初始化事件
function OpenServiceAcitivityLcZbPage:InitEvent()

end

--移除事件
function OpenServiceAcitivityLcZbPage:RemoveEvent()
	
end

--更新视图界面
function OpenServiceAcitivityLcZbPage:UpdateData(data)
	local data = OpenServiceAcitivityData.Instance:GetGCData()
	for i, v in ipairs(data) do
		self.show_cell[i]:SetData(v)
	end
end

function OpenServiceAcitivityLcZbPage:CreateCell()
	self.show_cell = {}
	for i = 1, 5 do
		local ph = self.view.ph_list["ph_cell_"..i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:GetView():setAnchorPoint(0, 0)
		self.view.node_t_list["layout_lc_zb"].node:addChild(cell:GetView(), 103)
		table.insert(self.show_cell, cell)
	end
end