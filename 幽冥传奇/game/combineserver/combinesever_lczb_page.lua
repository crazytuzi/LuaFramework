CombineServerLcZbPage = CombineServerLcZbPage or BaseClass()


function CombineServerLcZbPage:__init()
	
end	

function CombineServerLcZbPage:__delete()
	if self.reward_cell ~= nil then
		for k,v in pairs(self.reward_cell) do
			v:DeleteMe()
		end
		self.reward_cell = {}
	end
	self:RemoveEvent()
end	

--初始化页面接口
function CombineServerLcZbPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:CreateCells()
	self:InitEvent()
end	


--初始化事件
function CombineServerLcZbPage:InitEvent()
	
end

--移除事件
function CombineServerLcZbPage:RemoveEvent()
	
end

--更新视图界面
function CombineServerLcZbPage:UpdateData(data)
	local cur_data = CombineServerData.Instance:GetGongchengZhenReward()
	for k, v in pairs(self.reward_cell) do
		v:SetData(cur_data[k])
	end
end	

function CombineServerLcZbPage:CreateCells()
	self.reward_cell = {}
	for i = 1, 5 do
		local ph = self.view.ph_list["ph_cell_"..i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		self.view.node_t_list["layout_zb"].node:addChild(cell:GetView(), 103)
		table.insert(self.reward_cell, cell)
		self.act_eff = RenderUnit.CreateEffect(7, self.view.node_t_list["layout_zb"].node, 103, nil, nil, ph.x+37 ,  ph.y + 37)
	end	
end