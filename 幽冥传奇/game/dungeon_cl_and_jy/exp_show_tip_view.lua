ExpShowTipView = ExpShowTipView or BaseClass(BaseView)

function ExpShowTipView:__init( ... )
	 self.texture_path_list = {
		'res/xui/fuben_cl.png',
		'res/xui/fuben.png',
	}

	self.order = 0
	 self.config_tab = {
        {"fuben_cl_and_jy_ui_cfg", 5, {0}},
    }
    self.remain_time  = 0
end

function ExpShowTipView:__delete( ... )
	-- body
end

function ExpShowTipView:ReleaseCallBack( ... )
	if self.skill_bo_num_change then
		GlobalEventSystem:UnBind(self.skill_bo_num_change)
		self.skill_bo_num_change = nil
	end

	if self.skill_monster_num_change then
		GlobalEventSystem:UnBind(self.skill_monster_num_change)
		self.skill_monster_num_change = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
	if self.alert then
		self.alert:DeleteMe()
		self.alert = nil
	end
end

function ExpShowTipView:LoadCallBack( ... )
	local content_size = self.node_t_list.layout_show_time.node:getContentSize()
	--PrintTable(content_size)
	local screen_height =  HandleRenderUnit:GetHeight()
	self.real_root_node:setPosition(content_size.width/2, screen_height/2)

	self:CreateCell()

	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.TimerCallBack, self), 1)
	self.remain_time = FubenData.Instance:GetRemainTime()
	self.node_t_list.img_get_level.node:setScale(0.6)
	XUI.AddClickEventListener(self.node_t_list.layout_exit_fuben.node, BindTool.Bind(self.OnExitFuben, self), true)
end


function ExpShowTipView:OnExitFuben( ... )
	self.alert = self.alert or Alert.New()
	self.alert:SetLableString(Language.JiYanFubenShow.OnExitFuben)
	self.alert:SetOkString(Language.Common.Confirm)
	self.alert:SetCancelString(Language.Common.Cancel)
	self.alert:SetOkFunc(function ( ... )
		local fuben_id = FubenData.Instance:GetFubenId()
		FubenCtrl.OutFubenReq(fuben_id)
	end)
	self.alert:Open()
end

function ExpShowTipView:HadChangeSkillNum()
	self:SetHadBoNum()
	self:SetHadSkillNUm()
	--self:SetMonsterHadShow()
	self.remain_time = FubenData.Instance:GetRemainTime()
	self:TimerCallBack()
end

function ExpShowTipView:CreateCell( ... )
	local ph = self.ph_list.ph_cell
	if self.cell == nil then
		self.cell = BaseCell.New()
		self.cell:GetView():setPosition(ph.x, ph.y)
		self.node_t_list.layout_show_time.node:addChild(self.cell:GetView(), 99)
	end
end

function ExpShowTipView:HadSkillMonsterNum()
	self:SetMonsterHadShow()
end

function ExpShowTipView:OpenCallBack()
	-- body
end

function ExpShowTipView:CloseCallBack()
	if self.skill_monster_num_change then
		GlobalEventSystem:UnBind(self.skill_monster_num_change)
		self.skill_monster_num_change = nil
	end

	if self.skill_bo_num_change then
		GlobalEventSystem:UnBind(self.skill_bo_num_change)
		self.skill_bo_num_change = nil
	end
end

function ExpShowTipView:ShowIndexCallBack(index)
	if nil == self.skill_bo_num_change then
		self.skill_bo_num_change = GlobalEventSystem:Bind(JI_YAN_FUBEN_EVENT.SKILL_BO_CHANGE, BindTool.Bind(self.HadChangeSkillNum,self))
	end

	if nil == self.skill_monster_num_change then
		self.skill_monster_num_change = GlobalEventSystem:Bind(JI_YAN_FUBEN_EVENT.SKILL_NUM_CHANGE, BindTool.Bind(self.HadSkillMonsterNum, self))
	end
	
	self:Flush(index)
end

function ExpShowTipView:OnFlush( ... )
	self:SetLevelShow()
	self:SetHadBoNum()
	self:SetHadSkillNUm()
	self:SetMonsterHadShow()
	self:TimerCallBack()
end

function ExpShowTipView:TimerCallBack( ... )
	local remain_time = self.remain_time -  TimeCtrl.Instance:GetServerTime()
	if remain_time <= 0 then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		self.node_t_list.text_remain_time.node:setString("")
		return 
	end
	local color = COLOR3B.GREEN
	if remain_time <= 30 then
		color = COLOR3B.RED
	end
	local text = TimeUtil.FormatSecond(remain_time, 2)
	self.node_t_list.text_remain_time.node:setString(text)
	self.node_t_list.text_remain_time.node:setColor(color)
end


function ExpShowTipView:SetLevelShow( ... )
	local level = FubenData.Instance:GetCurFightLevel()
	self.node_t_list.text_level.node:setString("难度："..level)
end

function ExpShowTipView:SetHadBoNum( ... )
	local level =   FubenData.Instance:GetCurFightLevel()
	local total_bo = DungeonData.Instance:GetHadMonsterLevel(level)
	local cur_bo = FubenData.Instance:GetCurBoNum()
	self.node_t_list.text_cur_bo.node:setString(cur_bo.."/".. total_bo)
end

function ExpShowTipView:SetHadSkillNUm()
	local cur_bo = FubenData.Instance:GetHadTongGuangBo()
	local level = FubenData.Instance:GetCurFightLevel()
	if cur_bo == 0 then  --如果通过当前波数为0，评分为D
		cur_bo = 1
	end
	local score = DungeonData.Instance:GetScore(level, cur_bo)
	local reward = DungeonData:GetRewardDataByScoreAndlevel(level, score)
	if self.cell then
		self.cell:SetData({item_id = reward[1].id, num = 1, is_bind = 0})
	end
	self.node_t_list.text_can_had.node:setString("X "..reward[1].count)

	self.node_t_list.img_get_level.node:loadTexture(ResPath.GetFubenCL("level_".. score))

end


function ExpShowTipView:SetMonsterHadShow()
	local cur_bo = FubenData.Instance:GetCurBoNum()
	local level = FubenData.Instance:GetCurFightLevel()

	local monster_list = expFubenConfig.level and expFubenConfig.level[level].MonsterWaveNum[cur_bo].refreshList
	local num = 0
	for k, v in pairs(monster_list) do
		num = num + v.count
	end
	local had_remain_monster =  FubenData.Instance:GetCurMonsterNum()
	local client_had_num = FubenData.Instance:GetHadSkillNum( )
	local remain_num = (had_remain_monster - client_had_num) <= 0 and 0 or (had_remain_monster - client_had_num)
	self.node_t_list.text_cur_num.node:setString(remain_num .."只")
end