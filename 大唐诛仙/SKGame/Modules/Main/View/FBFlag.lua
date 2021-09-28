FBFlag =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function FBFlag:__init( ... )
	self.URL = "ui://0042gnitsgyode";
	self:__property(...)
	self:Config()
	self.imgBg = self.ui:GetChild("Bg")
end

-- Set self property
function FBFlag:SetProperty( ... )
	
end

-- Logic Starting
function FBFlag:Config()
	self.isActivity = false
	self.QuitFBBtn.onClick:Add(self.OnClickQuitBtn,self)
end

function FBFlag:OnClickQuitBtn()
	local confirmCallBack = function ()
		--确认就回到主城
		if SceneModel:GetInstance():IsTower() then
			TowerController:GetInstance():RequireQuiteTower()
		else
			FBController:GetInstance():RequireQuitInstance()
		end
	end
	local title = ""
	local context = ""
	if SceneModel:GetInstance():IsTower() then
		title = "大荒塔"
		context = "确定退出大荒塔吗？"
	else
		title = "副本"
		context = "确定退出副本吗？"
	end
	self.quitPopPanel = UIMgr.Win_Confirm(title, context, "确定", "取消", confirmCallBack, nil)
end

function FBFlag:Init()
	if SceneModel:GetInstance():IsTower() then
		self:IsTower()
	else
		self:IsFB()
	end
	self.imgBg.visible = true
	self.title.visible = true
end

--副本需要倒计时
function FBFlag:IsFB()
	self.normalize = 0
	self.fbCutDown = false
	self.waitTime = 180000
	--当前服务器时间
	self.endTime = SceneModel:GetInstance().endSceneTime
	self.curFBVo = FBModel:GetInstance():GetFBVoByMapId()
	if self.curFBVo then 
		self.waitTime = self.curFBVo.waitingTime
	end
	self.deltaTime = self.endTime - TimeTool.GetCurTime()
	-- print(self.endTime .. "endTime --------")
	-- print(self.deltaTime .. "deltaTime --------")
	-- print(TimeTool.GetCurTime() .. "TimeTool.GetCurTime()--------")
	self.title.text = StringFormat("[color=#c6d6db]副本结束：{0}[/color]",TimeTool.GetTimeMS(math.floor(self.deltaTime/10000) * 10,true))
	--如果进入副本的时候是副本已经进入倒计时就开始倒计时
	if self.deltaTime < 0 then
		self.fbCutDown = true
		local t = self.endTime - TimeTool.GetCurTime()
		self.waitTime = self.waitTime - t 
	end
	RenderMgr.Remove("fbCutDown")
	RenderMgr.Add(function () self:Update() end, "fbCutDown")
	GlobalDispatcher:RemoveEventListener(self.handler)
	GlobalDispatcher:RemoveEventListener(self.handler2)
	self.handler=GlobalDispatcher:AddEventListener(EventName.FBFinishCutDown,function (data)
		self:FBFinishCutDown()
	end)
	self.handler2 = GlobalDispatcher:AddEventListener(EventName.SCENE_LOAD_FINISH, function ()
		self:OnChangeScene()
	end)
end

--大荒塔显示简单
function FBFlag:IsTower()
	GlobalDispatcher:RemoveEventListener(self.handler3)
	self.handler3 = GlobalDispatcher:AddEventListener(EventName.TowerLayerChange, function()
		self:RefreshLayerID()
	end)
	self:RefreshLayerID()
end

function FBFlag:RefreshLayerID()
	local curLevel = LoginModel:GetInstance():GetTowerLayer()
	self.title.text = StringFormat("所在层数：{0}", curLevel)
end

function FBFlag:OnEnable()
	if self.isActivity == true then return end 
	self.isActivity = true
	self:Init()
end

function FBFlag:Update()
	self.normalize = self.normalize + Time.deltaTime
	if self.ui == nil then return end 
	if self.normalize >=1 then 
		self.normalize = 0
		--进入副本关闭倒计时
		if self.fbCutDown == true then
			-- if self.waitTime > 0 then
			-- 	self.waitTime = self.waitTime - 1000
			-- 	self.title.text = StringFormat("[color=#fe4d4d]副本关闭：{0}[/color]",TimeTool.GetTimeMS(math.floor((self.waitTime)/1000),true))
			-- end
			-- if self.waitTime <= 0 then
			-- 	self.title.text = StringFormat("[color=#fe4d4d]副本关闭：{0}[/color]",TimeTool.GetTimeMS(0,true))
			-- 	RenderMgr.Remove("fbCutDown")
			-- end
			self.title.visible = false
			self.imgBg.visible = false
			RenderMgr.Remove("fbCutDown")
		end
		--持续期间
		if self.fbCutDown == false then
			self.deltaTime = self.deltaTime - 1000
			if self.deltaTime >= 0 then 
				self.title.text = StringFormat("[color=#c6d6db]副本结束：{0}[/color]",TimeTool.GetTimeMS(math.floor((self.deltaTime)/1000),true))
			end
		end
	end
end

function FBFlag:FBFinishCutDown()
	self.fbCutDown = true
end

function FBFlag:OnDisable()
	RenderMgr.Remove("fbCutDown")
	self.isActivity = false
	GlobalDispatcher:RemoveEventListener(self.handler)
	GlobalDispatcher:RemoveEventListener(self.handler2)
	GlobalDispatcher:RemoveEventListener(self.handler3)
	self:OnChangeScene()
end

-- Register UI classes to lua
function FBFlag:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Main","FBFlag");

	self.bg = self.ui:GetChild("Bg")
	self.title = self.ui:GetChild("title")
	self.QuitFBBtn = self.ui:GetChild("QuitFBBtn")

	self.bg.visible = true 
	self.title.visible = true 
end

-- Combining existing UI generates a class
function FBFlag.Create( ui, ...)
	return FBFlag.New(ui, "#", {...})
end

-- Dispose use FBFlag obj:Destroy()
function FBFlag:__delete()
	RenderMgr.Remove("fbCutDown")
	self.bg = nil
	self.title = nil
	self.QuitFBBtn = nil
	GlobalDispatcher:RemoveEventListener(self.handler)
	GlobalDispatcher:RemoveEventListener(self.handler2)
	GlobalDispatcher:RemoveEventListener(self.handler3)
end

function FBFlag:OnChangeScene()
	if self.quitPopPanel and self.quitPopPanel.ui then
		self.quitPopPanel:Destroy()
	end
	self.quitPopPanel = nil
end