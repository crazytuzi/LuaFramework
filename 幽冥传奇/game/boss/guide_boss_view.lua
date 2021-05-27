-- BOSS引导
BossGuideView = BossGuideView or BaseClass(XuiBaseView)

function BossGuideView:__init()
	self.zorder = -3
	--self.is_async_load = false
	self.texture_path_list[1] = 'res/xui/consign.png'
end

function BossGuideView:__delete()
end

function BossGuideView:ReleaseCallBack()
	if self.boss_list then
		self.boss_list:DeleteMe()
		self.boss_list = nil
	end
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
	-- if self.time_limited_consume_event then
	-- 	GlobalEventSystem:UnBind(self.time_limited_consume_event)
	-- 	self.time_limited_consume_event = nil
	-- end
	self.title_text = nil 
end

function BossGuideView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		local screen_w = HandleRenderUnit:GetWidth()
		local screen_h = HandleRenderUnit:GetHeight()
		self.root_node:setPosition(screen_w / 2 + 178, screen_h / 2 - 140)

		self.content_vis = true

		-- 引导列表背景
		local bg_w = 250
		local bg_h = 250
		self.layout_list = XUI.CreateLayout(0, 0, bg_w, bg_h)
		self.layout_list:setAnchorPoint(0, 0)
		self.layout_list:setVisible(self.content_vis)

		self.boss_list_bg = XUI.CreateImageViewScale9(bg_w * 0.5 , bg_h * 0.5, bg_w + 10, bg_h+10, ResPath.GetCommon("img9_168"), true)
		self.layout_list:addChild(self.boss_list_bg, 1)
		self.boss_list_bg_1 = XUI.CreateImageViewScale9(bg_w * 0.5 , bg_h * 0.5, bg_w-2, bg_h-2, ResPath.GetCommon("img9_170"), true)
		self.layout_list:addChild(self.boss_list_bg_1, -1)
		-- 引导列表
		self.boss_list = ListView.New()
		self.boss_list:Create(bg_w * 0.5, bg_h * 0.5, bg_w, bg_h - 8, ScrollDir.Vertical, GuideBossRender)
		self.boss_list:SetMargin(3)
		self.boss_list:SetItemsInterval(10)
		self.layout_list:addChild(self.boss_list:GetView(), 10)

		-- 界面展开按钮
		self.open_btn = XUI.CreateButton(0, 0, 0, 0, false, ResPath.GetCommon("btn_dow_2"), ResPath.GetCommon("btn_dow_2"), nil, true)
		local open_btn_size = self.open_btn:getContentSize()
		self.open_btn:setPosition(bg_w + open_btn_size.width * 0.5 - 20, bg_h + open_btn_size.height * 0.5 + 24)
		self.root_node:addChild(self.open_btn, 20)
		XUI.AddClickEventListener(self.open_btn, BindTool.Bind1(self.OnClickOpen, self), true)

		-- 界面标题背景
		local title_bg_h = open_btn_size.height
		self.layout_title = XUI.CreateLayout(0, bg_h, bg_w, title_bg_h)
		self.layout_title:setAnchorPoint(0, 0)

		self.title_bg = XUI.CreateImageViewScale9(bg_w * 0.5, title_bg_h * 0.5 + 5 , bg_w+10, title_bg_h, ResPath.GetCommon("img9_168"), true)
		self.layout_title:addChild(self.title_bg, 1)

		self.title_bg_1 = XUI.CreateImageViewScale9(bg_w * 0.5, title_bg_h * 0.5 + 5, bg_w, title_bg_h-2, ResPath.GetCommon("img9_170"), true)
		self.layout_title:addChild(self.title_bg_1, -1)

		-- -- 界面标题
		self.title_text = XUI.CreateText(12, title_bg_h * 0.5, 300, 28, cc.TEXT_ALIGNMENT_LEFT, "", nil, 21, COLOR3B.OLIVE)
		self.title_text:setAnchorPoint(0, 0.5)
		self.layout_title:addChild(self.title_text, 10)

		-- 点击查看
		-- self.see_text = RichTextUtil.CreateLinkText(Language.Boss.ClickSee, 20, COLOR3B.GREEN, text_attr, true)
		-- self.see_text:setAnchorPoint(0.5, 0.5)
		-- self.see_text:setPosition(bg_w - 58, title_bg_h * 0.5 + 3)
		-- XUI.AddClickEventListener(self.see_text, BindTool.Bind1(self.OnClickSee, self), true)
		-- self.layout_title:addChild(self.see_text, 10)

		self.layout_content = XUI.CreateLayout(-24, 20, 0, 0)
		self.layout_content:setAnchorPoint(0, 0)
		self.root_node:addChild(self.layout_content, 1)
		self.layout_content:setVisible(self.content_vis)
		self.layout_content:addChild(self.layout_list, 1)
		self.layout_content:addChild(self.layout_title, 1)
	end
	self:Flush(0, "open")
end

function BossGuideView:OnFlush(param_t, index)
	self:FlushTime(0)
	local boss_list = BossData.Instance:GetContent()
	self.boss_list:SetDataList(boss_list)
	if param_t["open"] then
		self.boss_list:JumpToTop(true)
	end
end

function BossGuideView:OpenCallBack()
	self:Flush(0, "open")
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
	-- if self.time_limited_consume_event then
	-- 	GlobalEventSystem:UnBind(self.time_limited_consume_event)
	-- 	self.time_limited_consume_event = nil
	-- end
	--self.time_limited_consume_event = GlobalEventSystem:Bind(OtherEventType.TIME_BOSS_TEMPLE_CHANGE, BindTool.Bind(self.UpdateTime, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self, -1),  1)
	
end


function BossGuideView:FlushTime()
	local title, totoltime = BossData.Instance:GetTitleData()
	local remaintime = totoltime - TimeCtrl.Instance:GetServerTime()
	if remaintime and remaintime < 0 then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
	end 
	title = title or ""
	self.title_text:setString(title .."  ".. ((remaintime <= 0 and "") or (remaintime == nil and "") or TimeUtil.FormatSecond(remaintime , 2)))
end

function BossGuideView:CloseCallBack()

end

function BossGuideView:OnClickOpen()
	self.content_vis = not self.content_vis
	self.layout_list:setVisible(self.content_vis)
	self.layout_content:setVisible(self.content_vis)
	self:Flush(0, "open")
end

function BossGuideView:OnClickSee()
	ViewManager.Instance:Open(ViewName.Map)
end

----------------------------------------------------
-- GuideBossRender
----------------------------------------------------
GuideBossRender = GuideBossRender or BaseClass(BaseRender)
GuideBossRender.Width = 219
GuideBossRender.Height = 52
function GuideBossRender:__init(x, y)
	self.view:setContentWH(GuideBossRender.Width, GuideBossRender.Height)
	
end

function GuideBossRender:__delete()
	self:DeleteRedEnvelopeTimer()
end

function GuideBossRender:CreateChild()
	BaseRender.CreateChild(self)

	self.btn_img = XUI.CreateImageViewScale9(GuideBossRender.Width * 0.5, GuideBossRender.Height * 0.5, 240, 55, ResPath.GetCommon("btn_135"), true)
	self.text = XUI.CreateText(4, 10, 210, 28, cc.TEXT_ALIGNMENT_LEFT, "", nil, 22)
	self.text:setAnchorPoint(0, 0)
	self.view:addChild(self.btn_img, 20)
	self.view:addChild(self.text, 21)
	XUI.AddClickEventListener(self.btn_img, BindTool.Bind2(self.OnClickGuide, self))
end

function GuideBossRender:CreateSelectEffect()
end
	
function GuideBossRender:OnClickGuide()
	local x, y = -1, -1
	if ACTIVITY_ID.ACTIVITY_DEFINE_DREAMLANDBOSS == BossData.Instance:GetActivityId() then
		x, y = BossData.Instance:GetDreamBossPos(Scene.Instance:GetSceneId(), self.data.boss_id)
	else
		x, y = BossData.Instance:GetBossPos(Scene.Instance:GetSceneId(), self.data.boss_id)
	end
	Scene.Instance:GetMainRole():LeaveFor(Scene.Instance:GetSceneId(), x, y, MoveEndType.FightByMonsterId, self.data.boss_id)
end

function GuideBossRender:OnFlush()
	if self.data == nil then return end
	self:CreateRedEnvelopeTimer()
end

function GuideBossRender:FlushTime()
	local remaintime = self.data.remaintime - TimeCtrl.Instance:GetServerTime()
	if remaintime < 0 then
		self:DeleteRedEnvelopeTimer()
		if self.data.time ~= 0 then
			local activity_id = BossData.Instance:GetActivityId()
			BossCtrl.Instance:ReqGuideBossData(activity_id)
		end
	end
	local content = DelNumByString(self.data.content) or ""
	self.text:setString(remaintime > 0 and content .. "(" .. TimeUtil.FormatSecond(remaintime, 2) .. ")" or content .. "(" .. Language.Boss.BossAppear .. ")")
	self.text:setColor(remaintime > 0 and COLOR3B.WHITE or COLOR3B.GREEN)
end

function GuideBossRender:CreateRedEnvelopeTimer()
	if self.boss_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.boss_timer)
		self.boss_timer = nil
	end
	self.boss_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind2(self.FlushTime, self, -1), 1)
end

function GuideBossRender:DeleteRedEnvelopeTimer()
	if self.boss_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.boss_timer)
		self.boss_timer = nil
	end
end

