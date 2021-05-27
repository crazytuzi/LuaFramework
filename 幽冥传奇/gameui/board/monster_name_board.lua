MosterNameBoard = MosterNameBoard or BaseClass(NameBoard)
MosterNameBoard.shift_y = 24
function MosterNameBoard:__init()
	self.relive_remaintime = 0
	self.owner_name_txt_rich = XUI.CreateRichText(0, 0, 200, 24)
	XUI.RichTextSetCenter(self.owner_name_txt_rich)
	self.root_node:addChild(self.owner_name_txt_rich, -2)

	self.desc_txt_rich = XUI.CreateRichText(0, 0, 200, 24)
	XUI.RichTextSetCenter(self.desc_txt_rich)
	self.root_node:addChild(self.desc_txt_rich, -2)
	self.temp_awards_title_t = {}
end

function MosterNameBoard:__delete()
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
	self:ClearTempAwardsTitle()
end

function MosterNameBoard:SetMonsterRole(role_vo, logic_pos_x, logic_pos_y)
	self.role_vo = role_vo
	self.owner_name_txt_rich:removeAllElements()
	local name_list, special_list = Scene.Instance:GetSceneLogic():GetRoleNameBoardText(role_vo)
	if GlobalData.is_show_role_pos and logic_pos_x and logic_pos_y then
		local text = string.format("(%d, %d)", logic_pos_x, logic_pos_y)
		table.insert(name_list, {text = text, color = COLOR3B.WHITE})
	end
	
	self:SetNameList(name_list)
	if self.role_vo.owner_name and self.role_vo.owner_name ~= "" then
		self.name_text_rich:setPositionY(MosterNameBoard.shift_y)
		XUI.RichTextAddText(self.owner_name_txt_rich, RoleData.SubRoleName(self.role_vo.owner_name), COMMON_CONSTS.FONT, NameBoard.FontSize, UInt2C3b(self.role_vo.name_color or 0), 255, nil, 1) 
	end
end

function MosterNameBoard:SetNameText(text)
	self.desc_txt_rich:setPositionY(MosterNameBoard.shift_y)
	XUI.RichTextAddText(self.desc_txt_rich, text, COMMON_CONSTS.FONT, 24, COLOR3B.GREEN, 255, nil, 1) 
end

function MosterNameBoard:SetMonsterFuHuoTime(time)
	self.relive_remaintime = time

	if self.monster_time_text == nil then
		self.monster_time_text = XUI.CreateRichText(0, -24, 200, 24)
		XUI.RichTextSetCenter(self.monster_time_text)
		self.root_node:addChild(self.monster_time_text)
	end	

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

	if self.relive_remaintime > 0 then
		self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self, -1),  1)
		self:FlushTime()
	end

end


function MosterNameBoard:FlushTime()
	local server_time =  self.relive_remaintime - TimeCtrl.Instance:GetServerShortTime() 

	if server_time <= 0 then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
			return
		end
	end

	local time = TimeUtil.FormatSecond(server_time, 3)
	RichTextUtil.ParseRichText(self.monster_time_text, time)
end

local gap = 2
local cellSize = 64
function MosterNameBoard:SetTempAwardItemTitle(item_list)
	self:ClearTempAwardsTitle()
	if self.temp_award_title_layout then
		self.temp_award_title_layout:removeAllChildren()
	end
	if not next(item_list) then return end
	-- print("head_item=======")
	-- PrintTable(item_list)
	self.owner_name_txt_rich:refreshView()
	self.desc_txt_rich:refreshView()
	local innerHeight = self.owner_name_txt_rich:getInnerContainerSize().height
	innerHeight = self.desc_txt_rich:getInnerContainerSize().height + innerHeight
	local s_y = innerHeight + 20
	if self.temp_award_title_layout == nil then
		self.temp_award_title_layout = XLayout:create(0, 0)
		self.temp_award_title_layout:setAnchorPoint(0.5, 0)
		self.root_node:addChild(self.temp_award_title_layout, 100)
	end	
	local itemCnt = #item_list
	local layout_wid = cellSize * itemCnt + (itemCnt - 1) * gap
	self.temp_award_title_layout:setContentWH(layout_wid, cellSize)
	self.temp_award_title_layout:setPosition(0, s_y)

	for k_2,v_2 in pairs(item_list) do
		-- if v_2 > 0 then
			local cell = BaseCell.New()
			cell:SetAnchorPoint(0, 0)
			cell:SetContentSize(cellSize, cellSize)
			cell:GetView():setScale(0.8)
			cell:SetPosition((k_2 - 1) * (cellSize + gap), 0)
			cell:SetData({item_id = v_2.id, num = 1, is_bind = 0})
			self.temp_award_title_layout:addChild(cell:GetView(), 100)
			self.temp_awards_title_t[#self.temp_awards_title_t + 1] = cell
		--end
	end
end

function MosterNameBoard:ClearTempAwardsTitle()
	for k, v in pairs(self.temp_awards_title_t) do
		if v then
			v:DeleteMe()
		end
	end
	self.temp_awards_title_t = {}
end