-- 离线经验
WelfareView = WelfareView or BaseClass(XuiBaseView)

function WelfareView:InitOfflineExpView()
	local ph = self.ph_list.ph_offline_list
	self.offline_list = ListView.New()
	self.offline_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, OfflineItemRender, nil, nil, self.ph_list.ph_offline_reward_render)
	self.offline_list:SetMargin(4)
	self.offline_list:SetItemsInterval(8)
	self.node_t_list.layout_offline_exp.node:addChild(self.offline_list:GetView(), 100)
end

function WelfareView:DeleteOfflineExpView()
	if self.offline_list then
		self.offline_list:DeleteMe()
		self.offline_list = nil
	end
end

function WelfareView:OnFlushOfflineExpView()

	local offline_data = WelfareData.Instance:GetOfflineExpInfo()
	local max_level = RankingListData.Instance:GetServerHighestLevel()
	local own_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local offline_time = offline_data.add_offline_time

	self.node_t_list.lbl_max_level.node:setString(max_level)
	self.node_t_list.lbl_own_level.node:setString(own_level)
	self.node_t_list.lbl_less_level.node:setString(max_level - own_level)

	local hour = math.floor(offline_time / 3600)
	local minute = math.floor((offline_time / 60) % 60)
	local second = math.floor(offline_time % 60)
	self.node_t_list.lbl_offline_hour.node:setString(hour)
	self.node_t_list.lbl_offline_min.node:setString(minute)
	self.node_t_list.lbl_offline_sec.node:setString(second)
	
	self.offline_list:SetDataList(offline_data.list_data)
end

----------------------------------------------------
-- OfflineItemRender
----------------------------------------------------
OfflineItemRender = OfflineItemRender or BaseClass(BaseRender)
function OfflineItemRender:__init()
end

function OfflineItemRender:__delete()
	if self.exp_num then
		self.exp_num:DeleteMe()
		self.exp_num = nil
	end
end

function OfflineItemRender:CreateChild()
	BaseRender.CreateChild(self)

	self.img_exp_times = self.node_tree["img_exp_times"].node

	self.exp_num = NumberBar.New()
	self.exp_num:SetRootPath(ResPath.GetWelfare("num_100_"))
	self.exp_num:SetPosition(262, 36)
	self.exp_num:SetSpace(-2)
	self.view:addChild(self.exp_num:GetView(), 100)

	self.node_tree.btn_receive.node:setTitleText(string.format(Language.Welfare.OfflineExpReceive, self.data.rate))
	XUI.AddClickEventListener(self.node_tree.btn_receive.node, BindTool.Bind2(self.OnClickViewHandler, self, self.data.index))
end

function OfflineItemRender:CreateSelectEffect()

end
	
function OfflineItemRender:OnClickViewHandler(index)
	WelfareCtrl.GetOfflineExp(index)
end

function OfflineItemRender:OnFlush()
	self.exp_num:SetNumber(self.data.exp)
	local rec_req_str = ""
	if self.data.viplv >= 1 then
		rec_req_str = string.format(Language.Welfare.OfflineExpReceiveReq, self.data.viplv)
	else
		rec_req_str = Language.Welfare.OfflineExpFreeReceive
	end 
	self.node_tree.lbl_rec_req.node:setString(rec_req_str)
	self.img_exp_times:loadTexture(ResPath.GetWelfare("word_exp_times_" .. self.data.rate), true)

	XUI.SetButtonEnabled(self.node_tree.btn_receive.node, self.data.exp > 0)
end