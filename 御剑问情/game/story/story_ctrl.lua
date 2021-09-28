require("game/story/storydef")
require("game/story/story")
require("game/story/xinshou_storys")
require("game/story/base_cg")
require("game/story/story_view")
require("game/story/story_entrance_view")
require("game/story/cgmanager")
require("game/story/robert_manager")
require("game/story/robertmgr")

StoryCtrl = StoryCtrl or  BaseClass(BaseController)

function StoryCtrl:__init()
	if StoryCtrl.Instance ~= nil then
		ErrorLog("[StoryCtrl] attempt to create singleton twice!")
		return
	end
	StoryCtrl.Instance = self

	self.cg_mgr = CgManager.New()
	-- 用于读配置表生成机器人
	self.robert_mgr = RobertManager.New()
	-- 客户端自己生成机器人（目前用于假装玩家跑主线，先合过来，后续整合到RobertManager中）
	self.robert_client_mgr = RobertMgr.New()
	self.entrance_view = StoryEntranceView.New(ViewName.StoryEntranceView)
end

function StoryCtrl:__delete()
	self.entrance_view:DeleteMe()
	self.robert_client_mgr:DeleteMe()
	self.robert_mgr:DeleteMe()
	self.cg_mgr:DeleteMe()

	StoryCtrl.Instance = nil
end

function StoryCtrl:DirectEnter(target_type)
	FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_GUIDE, self:GetFbGuideTypeByTargetType(target_type))
end

function StoryCtrl:OpenEntranceView(fuben_type, task_id)
	if SceneType.Common ~= Scene.Instance:GetSceneType() then
		return
	end

	if self:GetTaskIdByFbGuideType(GUIDE_FB_TYPE.HUSONG) == task_id then
		self:OpenHusongEntranceView(fuben_type, task_id)
	else
		self:OpenNormalEntranceView(fuben_type, task_id)
	end
end

function StoryCtrl:OpenHusongEntranceView(fuben_type, task_id)
	 -- 挂机那有个update一直调自动执行任务，导致有可以关闭后马上又会打开, 这里主
	local yunbiao_view = ViewManager.Instance:GetView(ViewName.YunbiaoView)
	if nil == yunbiao_view then
		return
	end

	yunbiao_view:SetHusongGuideEntrance(BindTool.Bind(self.DoEnter, self, fuben_type, task_id), 5)
	FunctionGuide.Instance:TriggerGuideByGuideName("husong_entrance")

	Scene.Instance:GetMainRole():StopMove()
	GuajiCtrl.Instance:ClearAllOperate()
end

function StoryCtrl:OpenNormalEntranceView(fuben_type, task_id)
	self.entrance_view:SetEnterCallback(BindTool.Bind(self.DoEnter, self, fuben_type, task_id))
	self.entrance_view:SetGuideFbType(self:GetFbGuideTypeByTaskId(task_id))
	self.entrance_view:Open()
	Scene.Instance:GetMainRole():StopMove()
	GuajiCtrl.Instance:ClearAllOperate()
end

function StoryCtrl:DoEnter(fuben_type, task_id)
	FuBenCtrl.Instance:SendEnterFBReq(fuben_type, self:GetFbGuideTypeByTaskId(task_id))
end

function StoryCtrl:CloseEntranceView()
	self.entrance_view:Close()
	ViewManager.Instance:Close(ViewName.YunbiaoView)
end

function StoryCtrl:GetTaskIdByFbGuideType(fb_guide_type)
	local guide_list = ConfigManager.Instance:GetAutoConfig("fb_guide_auto").guide_list
	if nil == guide_list then
		return 0
	end

	return guide_list[fb_guide_type] and guide_list[fb_guide_type].task_id or 0
end

function StoryCtrl:GetTaskRewardExpByFbGuideType(fb_guide_type)
	local guide_list = ConfigManager.Instance:GetAutoConfig("fb_guide_auto").guide_list
	if nil == guide_list then
		return 0
	end

	return guide_list[fb_guide_type] and guide_list[fb_guide_type].reward_exp or 0
end

function StoryCtrl:GetFbGuideTypeByTaskId(task_id)
	local guide_list = ConfigManager.Instance:GetAutoConfig("fb_guide_auto").guide_list
	if nil == guide_list then
		return 0
	end

	for _, v in pairs(guide_list) do
		if v.task_id == task_id then
			return v.type
		end
	end

	return 0
end

function StoryCtrl:GetFbGuideTypeByTargetType(target_type)
	local guide_list = ConfigManager.Instance:GetAutoConfig("fb_guide_auto").guide_list
	if nil == guide_list then
		return 0
	end

	for _, v in pairs(guide_list) do
		if v.target_type == target_type then
			return v.type
		end
	end
	return 0
end

function StoryCtrl:GetFunOpenFbTypeByTaskId(task_id)
	local fb_scene_cfg = ConfigManager.Instance:GetAutoConfig("funopenfbconfig_auto").fb_scene_cfg
	if nil == fb_scene_cfg then
		return 0
	end

	for _, v in pairs(fb_scene_cfg) do
		if v.task_id == task_id then
			return v.fb_type
		end
	end
	return 0
end

function StoryCtrl:GetFbCfg(task_id)
	local cfg = ConfigManager.Instance:GetAutoConfig("funopenfbconfig_auto").fb_scene_cfg
	if nil == cfg then
		return {}
	end

	for _, v in pairs(cfg) do
		if v.task_id == task_id then
			return v
		end
	end

	return {}
end