BabelFubenInfoView = BabelFubenInfoView or BaseClass(BaseView)

function BabelFubenInfoView:__init( ... )
	 self.texture_path_list = {
		'res/xui/babel.png',
	}

	self.order = 0
	self.config_tab = {
        --{"common_ui_cfg", 1, {0}},
        {"babel_ui_cfg", 2, {0}},
		--{"common_ui_cfg", 2, {0}, nil , 999},
    }
    self.remain_time  = 0
end

function BabelFubenInfoView:__delete( ... )
	-- body
end

function BabelFubenInfoView:ReleaseCallBack( ... )
	if self.cell_list then
		self.cell_list:DeleteMe()
		self.cell_list = nil
	end
	if self.data_event then
		GlobalEventSystem:UnBind(self.data_event)
		self.data_event = nil 
	end
end

function BabelFubenInfoView:LoadCallBack( ... )
	local content_size = self.node_t_list.layout_babel_fuben_info.node:getContentSize()
	local screen_height =  HandleRenderUnit:GetHeight()
	self.real_root_node:setPosition(content_size.width/2, screen_height/2)

	if nil == self.cell_list then
		local ph = self.ph_list["ph_award_list"]
		local ph_item = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE}
		local parent = self.node_t_list.layout_babel_fuben_info.node
		local grid_scroll = GridScroll.New()
		grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.w + 10, ActBaseCell, ScrollDir.Horizontal, false, ph_item)
		parent:addChild(grid_scroll:GetView(), 99)
		self.cell_list = grid_scroll
	end

	--self.data_event = GlobalEventSystem:Bind(BABEL_EVENET.DATA_CHANGE, BindTool.Bind1(self.OnBabelDataChange,self))
end

function BabelFubenInfoView:OnBabelDataChange( ... )
	self:SetShowInfo()
end

function BabelFubenInfoView:OpenCallBack()
	-- body
end

function BabelFubenInfoView:CloseCallBack()
	-- body
end

function BabelFubenInfoView:ShowIndexCallBack(index)
	self:Flush(index)
end

function BabelFubenInfoView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k== "miaoshao" then
			local level = BabelData.Instance:GetTongguangLevel()
			local next_level = level + 1
			local dps = BabelData.Instance:GetRecondmonsFs(next_level)
			local color = v.daps >= dps and COLOR3B.GREEN or COLOR3B.RED
			self.node_t_list["lbl_dps_2"].node:setString(v.daps)
			self.node_t_list["lbl_dps_2"].node:setColor(color)

		elseif k == "all" then
			self:SetShowInfo()
		end
	end
	
end


function BabelFubenInfoView:SetShowInfo()
	local level = BabelData.Instance:GetTongguangLevel()
	local next_level = level + 1
	local rewards = BabelData.Instance:GetSweepRewardByLevel(next_level)
	local show_list = {}
	for i,v in ipairs(rewards) do
		show_list[#show_list + 1] = ItemData.InitItemDataByCfg(v)
	end
	self.cell_list:SetDataList(show_list)

	local text = string.format(Language.Babel.guanka_name, next_level)
	self.node_t_list.text_level.node:setString(text)

	local dps = BabelData.Instance:GetRecondmonsFs(next_level)
	self.node_t_list.lbl_dps_1.node:setString(dps)

	local boss_id = BabelData.Instance:GetBossIdBylevel(next_level)
	local boss_cfg = BossData.GetMosterCfg(boss_id)
	local boss_name = boss_cfg.name or ""
	self.node_t_list["lbl_boss_name"].node:setString(boss_name  .. "×1")

end