YaoqianshuView = YaoqianshuView or BaseClass(ActBaseView)

function YaoqianshuView:__init(view, parent, act_id)
	-- self.ui_layout_name = "layout_yaoqianshu"
	self:LoadView(parent)
end

function YaoqianshuView:__delete()
	if self.world_record_list then
		self.world_record_list:DeleteMe()
		self.world_record_list = nil
	end	
	self:DeleteOnlineTimer()
end

function YaoqianshuView:InitView()
	self:InitWorldRecord()
	self:FlushWorldRecord()
	self:CreateAboutTimer()
	XUI.AddClickEventListener(self.node_t_list.btn_yaoqian.node, BindTool.Bind(self.OnClickBtnYaoqian, self), false)	
end

function YaoqianshuView:RefreshView(param_list)
	self:FlushWorldRecord()
	local data = ActivityBrilliantData.Instance
	if nil == data.yaoqian_num then
		return
	end
end


function YaoqianshuView:OnClickBtnYaoqian()
 	local act_id = ACT_ID.YQ
	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id)
end

function YaoqianshuView:InitWorldRecord()
	local ph = self.ph_list.ph_world_records_list
	self.world_record_list = ListView.New()
	self.world_record_list:Create(ph.x, ph.y, ph.w, ph.h, nil, WorldRecordYaoqianRender, nil, nil, self.ph_list.ph_wordrecord_item)
	self.world_record_list:GetView():setAnchorPoint(0, 0)
	self.world_record_list:SetJumpDirection(ListView.Top)
	self.node_t_list.layout_yaoqianshu.node:addChild(self.world_record_list:GetView(), 100)
end

function YaoqianshuView:FlushWorldRecord()
	local item_name_list,item_index_list = ActivityBrilliantData.Instance:GetYaoqianList()
	self.world_record_list:SetDataList(item_name_list)
end

function YaoqianshuView:UpdateOnlineTime()
	local cfg = ActivityBrilliantData.Instance:GetOperActCfg(ACT_ID.YQ)
	if nil == cfg then return end
	local yaoqian_max_num = cfg.config.params[2]
	local max_time = yaoqian_max_num * 30 * 60
	-- 在线时间
	local now_time =TimeCtrl.Instance:GetServerTime()
	local server_time = TimeCtrl.Instance:GetServerTime()
	local last_yj_time = ActivityBrilliantData.Instance.last_yaoqian_time
	local yj_time = ActivityBrilliantData.Instance.yaoqian_time
	self.online_time = math.floor(Status.NowTime - last_yj_time)
	local remain_time = max_time - self.online_time
	local str = TimeUtil.FormatSecond(max_time)
	if remain_time > 0 then
		str = TimeUtil.FormatSecond(self.online_time)
	end
	-- local str =  math.floor(self.online_time/60) .. Language.Common.TimeList.min
	
	self.node_t_list.layout_yaoqianshu.lbl_activity_tip.node:setString(str)
	self.node_t_list.layout_yaoqianshu.lbl_activity_tip.node:setColor(COLOR3B.GREEN)

	
	
	local allcan_yqnum = math.floor(self.online_time/60)
	local yaoqian_num = ActivityBrilliantData.Instance.yaoqian_num
	local can_yqnum = allcan_yqnum - yaoqian_num
	if allcan_yqnum > yaoqian_max_num then
		can_yqnum = 0
	end
	self.node_t_list.layout_yaoqianshu.lbl_spare_times.node:setString(yaoqian_max_num - yaoqian_num .."/"..yaoqian_max_num)
end

function YaoqianshuView:CreateAboutTimer()
	self.set_now_time =  TimeCtrl.Instance:GetServerTime()
	self.online_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.UpdateOnlineTime, self), 1)
	self:UpdateOnlineTime()
end

function YaoqianshuView:DeleteOnlineTimer()
	if self.online_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.online_timer)
		self.online_timer = nil
	end
end

WorldRecordYaoqianRender = WorldRecordYaoqianRender or BaseClass(BaseRender)
function WorldRecordYaoqianRender:__init()	
	
end

function WorldRecordYaoqianRender:__delete()	
end

function WorldRecordYaoqianRender:CreateChild()
	BaseRender.CreateChild(self)
end

function WorldRecordYaoqianRender:OnFlush()
	if self.data == nil then return end
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.YQ)
	if nil == cfg then return end
	local id = cfg.config.award[tonumber(self.data.index)].id
	local count = cfg.config.award[tonumber(self.data.index)].count

	if  ActivityBrilliantData.Instance == nil then return end
	local item_cfg = ItemData.Instance:GetItemConfig(id)
	if nil == item_cfg then 
		return 
	end
	local color = string.format("%06x", item_cfg.color)
	local playername = Scene.Instance:GetMainRole():GetName()
	local text = {}
	if playername == self.data.name then
		self.rolename_color = "CCCCCC"
	else
		self.rolename_color = "FFFF00"
	end
	local item_name = ItemData.Instance:GetItemName(id)
	local text2  = self.data.name ..item_name
	local text = string.format(Language.ActivityBrilliant.Txt, self.rolename_color, self.rolename_color, self.data.name, self.rolename_color, Language.XunBao.Prefix, color, item_cfg.name ,id,color,count)
	RichTextUtil.ParseRichText(self.node_tree.rich_explore_attr.node,text, 16)
end

function WorldRecordYaoqianRender:CreateSelectEffect()
end
