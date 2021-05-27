LianYuGuideShowTipView = LianYuGuideShowTipView or BaseClass(BaseView)
function LianYuGuideShowTipView:__init()
	 self.texture_path_list = {
		'res/xui/fuben_cl.png',
		'res/xui/fuben.png',
	}

	self.order = 0
	 self.config_tab = {
        --{"common_ui_cfg", 1, {0}},
        {"fuben_cl_and_jy_ui_cfg", 7, {0}},
		--{"common_ui_cfg", 2, {0}, nil , 999},
    }
end

function LianYuGuideShowTipView:__delete()
	-- body
end

function LianYuGuideShowTipView:ReleaseCallBack()
	if self.alert then
		self.alert:DeleteMe()
		self.alert = nil 
	end
	if self.cell_list then
		self.cell_list:DeleteMe()
		self.cell_list = nil 
	end	

	if self.skill_moster_change then
		GlobalEventSystem:UnBind(self.skill_moster_change)
		self.skill_moster_change = nil 
	end
	if self.skill_bo_num_change then
		GlobalEventSystem:UnBind(self.skill_bo_num_change)
		self.skill_bo_num_change = nil 
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil 
	end

end

function LianYuGuideShowTipView:LoadCallBack( )
	local content_size = self.node_t_list.layout_lianyu_guide.node:getContentSize()
	--PrintTable(content_size)
	local screen_height =  HandleRenderUnit:GetHeight()
	self.real_root_node:setPosition(content_size.width/2, screen_height/2)

	XUI.AddClickEventListener(self.node_t_list.layout_exit_fuben_lianyu.node, BindTool.Bind1(self.OnExitFuben, self), true)

	self.skill_moster_change = GlobalEventSystem:Bind(LIAN_FUBEN_EVENT.SKILL_NUM_CHANGE, BindTool.Bind1(self.SKillMonsterNumChange, self))

	self.skill_bo_num_change = GlobalEventSystem:Bind(LIAN_FUBEN_EVENT.SKILL_BO_CHANGE, BindTool.Bind1(self.HadChangeSkillNum,self))

	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.TimerCallBack, self), 1)
	self.remain_time = FubenData.Instance:GetRemainTimeLianYu()

	if nil == self.cell_list then
		local ph = self.ph_list["ph_award_list"]
		local ph_item = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE}
		local parent = self.node_t_list.layout_lianyu_guide.node
		local grid_scroll = GridScroll.New()
		grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.w + 10, ActBaseCell, ScrollDir.Horizontal, false, ph_item)
		parent:addChild(grid_scroll:GetView(), 99)
		self.cell_list = grid_scroll
	end
	self.num = 0
end

function LianYuGuideShowTipView:HadChangeSkillNum()
	self.remain_time = FubenData.Instance:GetRemainTimeLianYu()
	self:TimerCallBack()
	self:SKillMonsterNumChange()
	self:FlushShowProgress()
end

function LianYuGuideShowTipView:OpenCallBack()
	-- body
end

function LianYuGuideShowTipView:ShowIndexCallBack()
	self:Flush(index)
end

function LianYuGuideShowTipView:OnFlush()
	self:TimerCallBack()
	self:SKillMonsterNumChange()
	self:FlushShowProgress()
end

function LianYuGuideShowTipView:CloseCallBack( ... )
	self.num = 0
end

function LianYuGuideShowTipView:SKillMonsterNumChange()
	local cur_bo = FubenData.Instance:GetLianyuCurBoNum()
	
	local had_remain_monster =  FubenData.Instance:GetHadBossNumLianyu()

	local client_had_num = FubenData.Instance:GetLianYuNum()
	local remain_num = (had_remain_monster - client_had_num) <= 0 and 0 or (had_remain_monster - client_had_num)
	self.node_t_list.text_cur_num_lianyu.node:setString(remain_num .."只")
end

function LianYuGuideShowTipView:TimerCallBack()
	local remain_time = self.remain_time -  TimeCtrl.Instance:GetServerTime()
	if remain_time <= 0 then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		self.node_t_list.text_remain_time_lianyu.node:setString("")
		return 
	end
	local color = COLOR3B.GREEN
	if remain_time <= 30 then
		color = COLOR3B.RED
	end
	if math.floor(remain_time) <=30 and self.num == 0 then
		self.num = 1
		DungeonCtrl.Instance:ShowTipsShow(30)
	end
	local text = TimeUtil.FormatSecond(remain_time, 2)
	self.node_t_list.text_remain_time_lianyu.node:setString(text)
	self.node_t_list.text_remain_time_lianyu.node:setColor(color)
end

function LianYuGuideShowTipView:FlushShowProgress( ... )
	local cur_bo = FubenData.Instance:GetLianyuCurBoNum()
	local total_bo = #PurgatoryFubenConfig.MonsterWaveNum
	self.node_t_list.text_cur_bo_lianyu.node:setString(cur_bo.."/".. total_bo)

	local reward = DungeonData.Instance:GetMonsterNumByBo(cur_bo)
	local show_list = {}
	for i,v in ipairs(reward) do
		show_list[#show_list + 1] = ItemData.InitItemDataByCfg(v)
	end
	self.cell_list:SetDataList(show_list)
end

function LianYuGuideShowTipView:OnExitFuben( ... )
	self.alert = self.alert or Alert.New()
	self.alert:SetLableString(Language.Lianyu.LianyuFubenExit)
	self.alert:SetOkString(Language.Common.Confirm)
	self.alert:SetCancelString(Language.Common.Cancel)
	self.alert:SetOkFunc(function ( ... )
		local fuben_id = FubenData.Instance:GetFubenId()
		FubenCtrl.OutFubenReq(fuben_id)
	end)
	self.alert:Open()
end