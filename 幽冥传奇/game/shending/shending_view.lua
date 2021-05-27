--------------------------------------------------------
-- 神鼎视图 配置 ActivityConfig  GodTripodConfig
--------------------------------------------------------

local ShenDingView = ShenDingView or BaseClass(SubView)

function ShenDingView:__init()
	self.texture_path_list[1] = 'res/xui/shending.png'
	self.texture_path_list[2] = "res/xui/vip.png"
	self.texture_path_list[3] = "res/xui/guild.png"
	self.texture_path_list[4] = "res/xui/wangchengzhengba.png"
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.config_tab = {
		-- {"common_ui_cfg", 1, {0}},
		{"shending_ui_cfg", 1, {0}},
		-- {"common_ui_cfg", 2, {0}},
	}

	-- self.child_level = nil -- 阶位等级
	-- self.effect = nil -- 神鼎特效
	-- self.power_view = nil --战力视图

	self.rew_index = 1

end

function ShenDingView:__delete()
end

--释放回调
function ShenDingView:ReleaseCallBack()
	self.hyd_progress = nil
end

--加载回调
function ShenDingView:LoadCallBack(index, loaded_times)
	
	self:CreateTaskView()
	self:ActivityReaedShow()

	local pos_x, pos_y = self.node_t_list.hyd_score.node:getPosition()
	RenderUnit.CreateEffect(1081, self.node_t_list.layout_shending.node, 10, nil, nil, pos_x+55, pos_y+10)
	-- RenderUnit.CreateEffect(1187, self.node_t_list.layout_shending.node, 10, nil, nil, pos_x+61, pos_y+2)

	-- 按钮监听
	for i = 1, 6 do
		XUI.AddClickEventListener(self.node_t_list["img_rew_" .. i].node, BindTool.Bind(self.OnReward, self, i))
		self.node_t_list["txt_hyd_num" .. i].node:setString(ActivityAllConfig.awardslist[i].needScore)
	end
	XUI.AddClickEventListener(self.node_t_list.btn_up.node, BindTool.Bind(self.OnClickUPBtn, self))

	-- 数据监听
	EventProxy.New(RoleData.Instance, self):AddEventListener(OBJ_ATTR.ACTOR_TRIPOD_LEVEL, BindTool.Bind(self.OnLevelChange, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(OBJ_ATTR.ACTOR_ACTIVITY, BindTool.Bind(self.OnActiveChange, self))
	EventProxy.New(ShenDingData.Instance, self):AddEventListener(ShenDingData.TASK_DATA_CHANGE, BindTool.Bind(self.FlushTaskView, self))

	self:SetRewIndex()
	self:CreateProgress()
end

-- 圆形特效遮罩
function ShenDingView:CreateProgress()
	if self.hyd_progress ~= nil then return end
	local pos_x, pos_y = self.node_t_list.hyd_score.node:getPosition()
	local x, y = pos_x-30, pos_y/2+62

	local sprite = XUI.CreateSprite(ResPath.GetVipResPath("img_vip_20"))  ----   一张圆环形状的图片
    local progress = cc.ProgressTimer:create(sprite)   ----创建ProgressTimer
    progress:setPercentage(0)
    progress:setName("per")
    progress:setScale(-1)
    progress:setPosition(x, y)

    local holesStencil = cc.Node:create()
    holesStencil:setName("holesStencil")
    holesStencil:addChild(progress)
    local spriteBg = XUI.CreateSprite(ResPath.GetVipResPath("img_vip_20"))  ----背景用于放置帧动画 可以和上面用同一张图片
 
    spriteBg:setName("spriteBg")
    spriteBg:setOpacity(0)
    holesStencil:setScale(1.5)
    spriteBg:setPosition(x*1.5, y*1.5)    	--holesStencil放大多少倍位置乘以多少 
 
    local eff =  RenderUnit.CreateEffect(1187, spriteBg, 10)  -----帧动画
    local clipS = cc.ClippingNode:create()  ----创建ClippingNode
    clipS:setStencil(holesStencil)
    clipS:addChild(spriteBg)
    clipS:setName("clipS")
 
    clipS:setInverted(false)   ---设置可视区为裁剪区域，还是裁剪剩余区域
    clipS:setAlphaThreshold(1)  ---根据alpha值控制显示
    clipS:setAnchorPoint(cc.p(0.5, 0.5))  
    self.node_t_list.layout_shending.node:addChild(clipS, 20) ----添加到节点

    local nodeClip = self.node_t_list.layout_shending.node:getChildByName("clipS")
	local nodeStencil = nodeClip:getStencil()
	local nodeProgess = nodeStencil:getChildByName("per")   

	self.hyd_progress = nodeProgess
end

function ShenDingView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ShenDingView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

-- 刷新任务列表
function ShenDingView:FlushTaskView()
	self.task_list:SetDataList(ShenDingData.Instance:GetTaskList())

	self:SetRewIndex()
	self:Flush()
end

function ShenDingView:OnFlush(param_t, index)

	local item_data = ActivityAllConfig.awardslist[self.rew_index].award
	
	local item = {}
	for k, v in pairs(item_data) do
		item[k] = {item_id = v.id, num = v.count, is_bind = v.bind}
	end
	self:FlushCellList(item)

	self:SetActScoreShow()
end

function ShenDingView:SetRewIndex()
	local index = ShenDingData.Instance:GetRewaedIndex()
	self.rew_index = index
end

-- 设置获得活跃度值显示
function ShenDingView:SetActScoreShow()
	local data = ShenDingData.Instance:GetTaskList()
	local index = 0
	for k, v in pairs(data) do
		local times2 = ActivityAllConfig.tasklist[v.index].daylimit -- 需完成的次数
		local score = ActivityAllConfig.tasklist[v.index].score -- 活跃点
		index = index + score * v.times
	end

	self.node_t_list.hyd_score.node:setString(index)

	self.hyd_progress:setPercentage(self:GetScorePro(index))

	self:SetAwardShow(index)
end

-- 获取当前活跃度的比例
function ShenDingView:GetScorePro(score)
	local data = ActivityAllConfig.awardslist
	local max_score = data[#data].needScore 		-- 阶段最大分数
	local rem = 100 / #data 		-- 每个阶段占据比例
	local index = 0
	for k, v in pairs(data) do
		if score <= v.needScore then
			index = k
			break
		end
	end
	if score > max_score then return 100 end
	local now = index * rem 			-- 当前阶段占据多少比例
	local s_now = score / data[index].needScore   			-- 当前分数占据当前阶段的比例
	local all_than = s_now * now

	return all_than
end

-- 设置领取提示
function ShenDingView:SetAwardShow(index)
	local rew_cfg = ShenDingData.Instance:GetIsRewIndex()
	for k, v in pairs(rew_cfg) do
		local score = ActivityAllConfig.awardslist[v.index].needScore

		self.node_t_list["img_rew_" .. v.index].node:setGrey(v.state == 1)

		local pos_x, pos_y = self.node_t_list["img_rew_" .. v.index].node:getPosition()
		-- local eff = RenderUnit.CreateEffect(1079, self.node_t_list.layout_shending.node, 10, nil, nil, pos_x, pos_y)
		-- eff:setVisible(score <= index and v.state == 0)

		self.node_t_list["img_remind_" .. v.index].node:setVisible(score <= index and v.state == 0)
		self.node_t_list["img_flag_" .. v.index].node:setVisible(v.state == 1)
		if self.rew_index == v.index then
			self.node_t_list.btn_up.node:setEnabled(score <= index and v.state == 0)
			self.node_t_list.img_btn_falg.node:setVisible(score <= index and v.state == 0)
	
			local txt = (score <= index) and (v.state == 1 and Language.Common.YiLingQu or Language.Common.LingQuJiangLi) or Language.Common.LingQuJiangLi
			self.node_t_list.btn_up.node:setTitleText(txt)
		end
	end

end

--显示指数回调
function ShenDingView:ShowIndexCallBack(index)
	self:FlushTaskView()
	self:Flush()
end

----------视图函数----------

-- 创建任务列表
function ShenDingView:CreateTaskView()
	local ph = self.ph_list.ph_task_list
	self.task_list = ListView.New()
	self.task_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, self.ShenDingTaskRender, nil, nil, self.ph_list.ph_task)
	self.task_list:SetItemsInterval(4)
	self.task_list:GetView():setAnchorPoint(0, 0)
	self.task_list:SetJumpDirection(ListView.Top)
	self.node_t_list.layout_shending.node:addChild(self.task_list:GetView(), 90)
	self:AddObj("task_list")
end

-- 奖励显示
function ShenDingView:ActivityReaedShow()
	local ph = self.ph_list["ph_award_list"]
	local ph_item = {w = BaseCell.SIZE, h = BaseCell.SIZE}
	local parent = self.node_t_list["layout_shending"].node
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.w + 10, BaseCell, ScrollDir.Horizontal, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	self.award_list = grid_scroll
	self:AddObj("award_list")
end

function ShenDingView:FlushCellList(show_list)
	self.award_list:SetDataList(show_list)

	-- 居中处理
	local view = self.award_list:GetView()
	local inner = view:getInnerContainer()
	local size = view:getContentSize()
	local ph_item = {w = BaseCell.SIZE, h = BaseCell.SIZE}
	local inner_width = ph_item.w * (#show_list) + (#show_list - 1) * 10 + 25
	local view_width = math.min(self.ph_list["ph_award_list"].w, inner_width)
	view:setContentSize(cc.size(view_width, size.height))
	view:setInnerContainerSize(cc.size(inner_width, size.height))
	view:jumpToTop()
end

-- 点击奖励显示
function ShenDingView:OnReward(index)
 	self.rew_index = index

 	self:Flush()
 end 

--------------------
-- 点击领取按钮回调
function ShenDingView:OnClickUPBtn()
	-- 发送领取请求
	ShenDingCtrl.SendActRewReq(self.rew_index)
end

function ShenDingView:OnLevelChange()
	
end

function ShenDingView:OnActiveChange()
	
end

--------------------

----------神鼎任务配置----------

-- 活跃任务"前往"按钮配置
	local name_cfg = {
		[1] = "每日签到",
		[2] = "羽毛副本",
		[3] = "魂珠副本",
		[4] = "护盾副本",
		[5] = "宝石副本",
		[6] = "经验副本",
		[7] = "每日充值",
		[8] = "每日寻宝",
		[9] = "降妖除魔",
		[10] = "参与任意活动",
		[11] = "击杀敌人",
		[12] = "膜拜城主",
		[13] = "试练关卡",
		[14] = "护送镖车",
		[15] = "消灭专属boss",
		[16] = "使用屠魔令",
		[17] = "挖掘BOSS",
		[18] = "消灭运势boss",
		[19] = "回收装备",
		[20] = "投入蚩尤神石",
		[21] = "矿洞挖掘",
		[22] = "矿洞掠夺",
		[23] = "元宝祈福",
		[24] = "等级祈福",
	}

	local config = {
		[1] = {view = ViewDef.Welfare.DailyRignIn, cs_id = nil},
		[2] = {view = nil, cs_id = 48},
		[3] = {view = nil, cs_id = 48},
		[4] = {view = nil, cs_id = 48},
		[5] = {view = nil, cs_id = 48},
		[6] = {view = nil, cs_id = 48},
		[7] = {view = ViewDef.ZsVip.Recharge, cs_id = nil},
		[8] = {view = ViewDef.Explore.Xunbao, cs_id = nil},
		[9] = {view = nil, cs_id = 51},
		[10] = {view = ViewDef.Activity.Activity, cs_id = nil},
		[11] = {view = ViewDef.NewlyBossView.Wild, cs_id = nil},
		[12] = {view = nil, cs_id = 3},
		[13] = {view = ViewDef.Experiment.Trial, cs_id = nil},
		[14] = {view = nil, cs_id = 20},
		[15] = {view = ViewDef.NewlyBossView.Wild.Specially, cs_id = nil},
		[16] = {view = ViewDef.NewlyBossView.Wild.CircleBoss, cs_id = nil},
		[17] = {view = ViewDef.NewlyBossView.Wild, cs_id = nil},
		[18] = {view = ViewDef.NewlyBossView.Drop.FortureBoss, cs_id = nil},
		[19] = {view = ViewDef.Recycle, cs_id = nil},
		[20] = {view = ViewDef.NewlyBossView.Drop.Chiyou, cs_id = nil},
		[21] = {view = ViewDef.Experiment.DigOre, cs_id = nil},
		[22] = {view = ViewDef.Experiment.DigOre, cs_id = nil},
		[23] = {view = ViewDef.Investment.Blessing, cs_id = nil},
		[24] = {view = ViewDef.Investment.Blessing, cs_id = nil},
	}

ShenDingView.ShenDingTaskRender = BaseClass(BaseRender)
local ShenDingTaskRender = ShenDingView.ShenDingTaskRender

function ShenDingTaskRender:__init()

	self.alert = nil --提示窗口
end

function ShenDingTaskRender:__delete()
	if self.alert then
		self.alert:DeleteMe()
		self.alert = nil
	end
end

function ShenDingTaskRender:CreateChild()
	BaseRender.CreateChild(self)

	if nil == self.data then return end
	local text = RichTextUtil.CreateLinkText("前往", 18, COLOR3B.GREEN, nil, true)
	text:setAnchorPoint(cc.p(0, 0))
	self.node_tree.layout_operation1.node:addChild(text, 20)
	XUI.AddClickEventListener(self.node_tree.layout_operation1.node, BindTool.Bind(self.OnClickOperationText, self), true)
end

function ShenDingTaskRender:OnFlush()
	if nil == self.data then return end

	local times = self.data.times -- 已完成的次数
	local times2 = ActivityAllConfig.tasklist[self.data.index].daylimit -- 需完成的次数
	local point = ActivityAllConfig.tasklist[self.data.index].score -- 活跃点

	local bool = times2 <= times -- true表示已完成,flase表示未完成
	local color =  bool and COLORSTR.GREEN or COLORSTR.RED

	local str = string.format("{wordcolor;%s;%d}/%d", color, self.data.times, times2)
	RichTextUtil.ParseRichText(self.node_tree.rich_times.node, str, 18, COLOR3B.GREEN)
	XUI.RichTextSetCenter(self.node_tree.rich_times.node)
	
	self.node_tree.layout_operation1.node:setVisible(not bool)
	self.node_tree.lbl_operation2.node:setVisible(bool)

	self.node_tree.lbl_task.node:setString(name_cfg[self.data.index])
	self.node_tree.lbl_active_point.node:setString(point)

end

function ShenDingTaskRender:OnClickOperationText()
	-- if self.alert == nil then
	-- 	self.alert = Alert.New()
	-- end

	-- if self.data.index == 18 then
	-- 	self.alert:SetShowCheckBox(true)
	-- 	self.alert:SetLableString(Language.Map.DeliveryNpcTips)
	-- 	self.alert:SetOkFunc(function ()
	-- 		Scene.SendQuicklyTransportReqByNpcId(config[self.data.index])
	-- 		self.alert:Close()
	-- 		-- ViewManager.Instance:CloseViewByDef(ViewDef.ShenDing)
	-- 	end)
	-- 	self.alert:Open()
	-- else
		
		local cfg = config[self.data.index]
		if cfg.view == nil and cfg.cs_id then
			GuajiCtrl.Instance:FlyByIndex(cfg.cs_id)
			ViewManager.Instance:CloseViewByDef(ViewDef.Activity)
		elseif cfg.view ~= nil then
			ViewManager.Instance:OpenViewByDef(cfg.view)
		end
	-- end
end

-- 屏蔽点击回调
function ShenDingTaskRender:CreateSelectEffect()
	return
end
function ShenDingTaskRender:OnClickBuyBtn()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end
function ShenDingTaskRender:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end

return ShenDingView
----------end----------
