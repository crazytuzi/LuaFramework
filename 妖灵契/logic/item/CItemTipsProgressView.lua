local CItemTipsProgressView = class("CItemTipsProgressView", CViewBase)

function CItemTipsProgressView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemTipsProgressView.prefab", cb)
end

CItemTipsProgressView.Spr =
{
	FindPlace = "pic_tansuozhong", 
	UseItem = "pic_jinxingzhong",
	Pick = "pic_caijizhong",
	Other = "pic_tansuozhong",
	Treasure = "pic_tansuozhong",
}

CItemTipsProgressView.Text =
{
	FindPlace = "探索中...", 
	UseItem = "使用中...",
	Pick = "采集中...",
	Other = "探索中...",
	Treasure = "探索中...",
}

function CItemTipsProgressView.OnCreateView(self)
	self.m_ActionWidget = self:NewUI(1, CBox)
	self.m_ActionBtn = self:NewUI(2, CBox)
	self.m_ProgressBar = self:NewUI(3, CSlider)
	self.m_ProgressMaskBox = self:NewUI(4, CBox)
	self.m_ActionSprite = self:NewUI(5, CSprite)
	self.m_Container = self:NewUI(6, CWidget)
	self.m_TaskLabel = self:NewUI(7, CLabel)
	self.m_AniWidget = self:NewUI(8, CWidget)

	self.m_Type = 0
	self.m_SessionIdx = nil 
	self.m_TaskId = nil
	self.m_ProgressTimer = nil 
	self.m_Progress = 0
	self.m_ProgreeTimeMax = 5	--读条时间
	self.m_DeltaTime = 0.03
	self.m_IsProgress = false

	self.m_Speed = -10
	self.m_W = 10

	self:InitContent()
	UITools.ResizeToRootSize(self.m_Container)
	g_UITouchCtrl:TouchOutDetect(self.m_ActionBtn, callback(self, "TouchOutProcress"))
end

function CItemTipsProgressView.InitContent(self)
	self.m_ProgressBar:SetValue(0)
	self.m_ProgressMaskBox:SetActive(false)
	self.m_ActionBtn:AddUIEvent("click", callback(self, "OnAction"))
	
	-- if not g_GuideCtrl:IsCustomGuideFinishByKey("PickView") then
	-- 	--引导
	-- 	local d 
	-- 	if data.guidedata.PickView and data.guidedata.PickView.guide_list[1].effect_list[1] then 
	-- 		d = data.guidedata.PickView.guide_list[1].effect_list[1]
	-- 	end
	-- 	if d then
	-- 		self.m_ActionBtn:DelEffect(d.ui_effect)
	-- 		local pos = Vector2.New(0,0)
	-- 		if d.near_pos then
	-- 			pos.x = d.near_pos.x
	-- 			pos.y = d.near_pos.y
	-- 		end
	-- 		self.m_ActionBtn:AddEffect(d.ui_effect, nil, pos)	
	-- 		g_GuideCtrl:ReqCustomGuideFinish("PickView")				
	-- 	end			
	-- 	--引导	
	-- end
end

function CItemTipsProgressView.OnAction(self)
	self.m_IsProgress = true
	self.m_ProgressMaskBox:SetActive(true)
	--self.m_ActionSprite.m_Tween:Toggle()
	--self.m_AniWidget.m_Tween:Toggle()	
	self:StartProgress()
end

function CItemTipsProgressView.SetData(self, taskid, sessionidx, autoAction)
	local oTask = g_TaskCtrl:GetTaskById(taskid)
	if oTask then
		local type = oTask:GetValue("tasktype")
		if type == define.Task.TaskType.TASK_PICK then
			self.m_ActionSprite:SetSpriteName(CItemTipsProgressView.Spr.Pick)
			self.m_TaskLabel:SetText(CItemTipsProgressView.Text.Pick)

		elseif type == define.Task.TaskType.TASK_FIND_PLACE then
			self.m_ActionSprite:SetSpriteName(CItemTipsProgressView.Spr.FindPlace)
			self.m_TaskLabel:SetText(CItemTipsProgressView.Text.FindPlace)

		elseif type == define.Task.TaskType.TASK_USE_ITEM  then			
			local taskitem = oTask:GetValue("taskitem")
			if taskitem and taskitem.itemid then
				local oItem = CItem.NewBySid(taskitem.itemid)
				if oItem then
					self.m_ActionSprite:SpriteItemShape(oItem:GetValue("icon"))
				else
					self.m_ActionSprite:SetSpriteName(CItemTipsProgressView.Spr.UseItem)
				end
			else
				self.m_ActionSprite:SetSpriteName(CItemTipsProgressView.Spr.UseItem)
			end
			self.m_TaskLabel:SetText(CItemTipsProgressView.Text.UseItem)

		else
			self.m_ActionSprite:SetSpriteName(CItemTipsProgressView.Spr.Other)
			self.m_TaskLabel:SetText(CItemTipsProgressView.Text.Other)
		end
		self.m_Type = type
	end
	self.m_SessionIdx = sessionidx
	self.m_TaskId = taskid

	if autoAction == nil or autoAction == false then
		Utils.AddTimer(callback(self, "OnAction"), 0, 0.1)		
	end
end

function CItemTipsProgressView.StartProgress(self)
	self.m_Progress = self.m_Progress + (1 / self.m_ProgreeTimeMax) * self.m_DeltaTime
	self.m_ProgressBar:SetValue(self.m_Progress)
	if self.m_ProgressTimer ~= nil then
		Utils.DelTimer(self.m_ProgressTimer)
		self.m_ProgressTimer = nil
	end

	local r = 20	
	self.m_W = self.m_W + self.m_Speed * (1 / self.m_ProgreeTimeMax) * self.m_DeltaTime
	local x = math.cos(self.m_W) * r
	local y = math.sin(self.m_W) * r
	self.m_ActionSprite:SetLocalPos(Vector3.New(x, y , 0))

	if self.m_Progress >= 1 then
		self.m_ProgressMaskBox:SetActive(false)
		if self.m_SessionIdx ~= nil then
			netother.C2GSCallback(self.m_SessionIdx)
			g_DialogueCtrl:CacheTaskOpenBtn(self.m_TaskId)
			--防止读条中，界面关闭
			local function cb()
				g_DialogueCtrl:CacheTaskOpenBtn()
			end
			Utils.AddTimer(cb, 0, self.m_ProgreeTimeMax * 2)
		end
		if self.m_CBFunc then
			self.m_CBFunc()
		end
		self:OnClose()
	else
		self.m_ProgressTimer = Utils.AddTimer(callback(self, "StartProgress"), 0, self.m_DeltaTime)		
	end
end

function CItemTipsProgressView.TouchOutProcress(self)
	if self.m_IsProgress == false then
		self:OnClose()
	end
end

function CItemTipsProgressView.SetCallBackFunc(self, func, iTimeMax)
	self.m_CBFunc = func
	if iTimeMax then
		self.m_ProgreeTimeMax = iTimeMax
	end
end

function CItemTipsProgressView.SetActionSrptie(self, sprite)
	self.m_ActionSprite:SetSpriteName(sprite)
end

return CItemTipsProgressView