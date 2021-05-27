local OpenServiceAcitivityLevelGiftView = OpenServiceAcitivityLevelGiftView or BaseClass(SubView)

function OpenServiceAcitivityLevelGiftView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/openserviceacitivity.png'
	self.config_tab = {
		{"openserviceacitivity_ui_cfg", 2, {0}},
	}
end

function OpenServiceAcitivityLevelGiftView:LoadCallBack()
	self:CreateList()
	EventProxy.New(OpenServiceAcitivityData.Instance, self):AddEventListener(OpenServiceAcitivityData.LevelGiftChange, BindTool.Bind(self.OnFlushLevelGiftView, self))
end

function OpenServiceAcitivityLevelGiftView:ReleaseCallBack()
	if self.level_gift_list then
		self.level_gift_list:DeleteMe()
		self.level_gift_list = nil
	end
end

function OpenServiceAcitivityLevelGiftView:OnFlushLevelGiftView()
	local data_list = OpenServiceAcitivityData.Instance:GetLevelGiftInfo()
	self.level_gift_list:SetDataList(data_list.item_list)
end

function OpenServiceAcitivityLevelGiftView:ShowIndexCallBack()
	OpenServiceAcitivityCtrl.SendGetLevelGiftInfo()
end

function OpenServiceAcitivityLevelGiftView:CreateList()
	if self.level_gift_list then return end
	local ph = self.ph_list.ph_level_gift_item_list
	self.level_gift_list = ListView.New()
	self.level_gift_list:Create(ph.x, ph.y, ph.w, ph.h, nil, LevelAwardListRender, nil, nil, self.ph_list.ph_level_gift_item)
	self.level_gift_list:GetView():setAnchorPoint(0, 0)
	self.node_t_list.layout_level_gift.node:addChild(self.level_gift_list:GetView(), 100)
	self.level_gift_list:SetItemsInterval(1)
	self.level_gift_list:SetJumpDirection(ListView.Top)
	-- self.level_gift_list:SetSelectCallBack(BindTool.Bind1(self.SelectSkillCallBack, self))
end

----------------------------------------------
-- 奖励列表item
----------------------------------------------

LevelAwardListRender = LevelAwardListRender or BaseClass(BaseRender)

function LevelAwardListRender:__init()
end

function LevelAwardListRender:__delete()
end

function LevelAwardListRender:CreateChild()
	BaseRender.CreateChild(self)
	self:CreateAwardScroll()
	self:CreateNeedLevelNum()
	XUI.AddClickEventListener(self.node_tree.btn_receive.node, BindTool.Bind(self.OnClickReceive, self))
	self.node_tree.btn_receive.node:setVisible(true)
	self.node_tree.img_stamp.node:setVisible(false)
	self.node_tree.btn_receive.remind_eff = RenderUnit.CreateEffect(23, self.node_tree.btn_receive.node, 1)
end

function LevelAwardListRender:OnFlush()
	if nil == self.data then return end
	local need_limit
	if self.data.need_level >= 1000 then
		need_limit = math.floor(self.data.need_level / 1000)
		self.node_tree.img_need_level.node:loadTexture(ResPath.GetOpenServerActivities("circle_word"))
	else
		need_limit = self.data.need_level
		self.node_tree.img_need_level.node:loadTexture(ResPath.GetOpenServerActivities("level_word"))
	end
	self.need_level_num:SetNumber(need_limit)
	self.node_tree.lbl_left_award.node:setString(self.data.left_award_num) -- 数量
	self:CreateAwardList()
	if self.data.btn_state == 0 then
		local btn_text = self.data.left_award_num > 0 and "未完成" or "已领完"
		self.node_tree.btn_receive.node:setEnabled(false)
		self.node_tree.btn_receive.node:setTitleText(btn_text)
		self.node_tree.btn_receive.remind_eff:setVisible(false)
		self.node_tree.img_stamp.node:setVisible(false)
	elseif self.data.btn_state == 1 then
		self.node_tree.btn_receive.node:setEnabled(true)
		self.node_tree.btn_receive.node:setTitleText("领    取")
		self.node_tree.btn_receive.remind_eff:setVisible(self.data.left_award_num > 0)
	else
		self.node_tree.btn_receive.node:setVisible(false)
		self.node_tree.img_stamp.node:setVisible(true)
	end
end

function LevelAwardListRender:CreateAwardList()
	if self.award_cell_list then 
		for k, v in pairs(self.award_cell_list) do
			v:GetView():removeFromParent()
			v:DeleteMe()
			v = nil
		end
		self.award_cell_list = {}
	end
	self.award_cell_list = {}
	local x, y = 0, 0
	local x_interval = 85
	for k, v in pairs(self.data.award_list) do
		-- local prof = math.max(RoleData.Instance:GetRoleBaseProf(), 1) --获取角色基础职业,默认是战士
		-- local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX) -- 性别
		-- if v.sex == nil or v.sex == sex then
		-- 	if v.job == prof or v.job == nil or v.job == 0 then
				local award_cell = BaseCell.New()
				award_cell:SetAnchorPoint(0, 0)
				self.reward_list_view:addChild(award_cell:GetView(), 99)
				award_cell:SetPosition(x, y)
				award_cell:SetData(v)
				x = x + x_interval
				table.insert(self.award_cell_list, award_cell)
		-- 	end
		-- end
	end
	local w = x
	self.reward_list_view:setInnerContainerSize(cc.size(w, 80))
end

function LevelAwardListRender:CreateAwardScroll()
	self.reward_items = {}
	self.reward_list_view = self.node_tree.scroll_award_view.node
	self.reward_list_view:setScorllDirection(ScrollDir.Horizontal)
end

-- 创建需要等级数字显示
function LevelAwardListRender:CreateNeedLevelNum()
	if self.need_level_num ~= nil then return end

	local x, y = self.node_tree.img_need_level.node:getPosition()
	local level_num = NumberBar.New()
	level_num:SetRootPath(ResPath.GetCommon("num_100_"))
	level_num:SetPosition(x - 30, y - 8)
	level_num:SetSpace(-1)
	self.need_level_num = level_num
	self.need_level_num:SetGravity(NumberBarGravity.Center)
	self:GetView():addChild(level_num:GetView(), 100, 100)
end

-- 创建选中特效
function LevelAwardListRender:CreateSelectEffect()
end

-- 领取奖励按钮回调
function LevelAwardListRender:OnClickReceive()
	OpenServiceAcitivityCtrl.SendGetLevelGift(self.data.index)
end

return OpenServiceAcitivityLevelGiftView