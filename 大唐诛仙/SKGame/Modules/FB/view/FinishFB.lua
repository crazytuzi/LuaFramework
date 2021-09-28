FinishFB =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function FinishFB:__init( ... )
	self.URL = "ui://wetrdvlhxi0p1y";
	self:__property(...)
	self:Config()
end

-- Set self property
function FinishFB:SetProperty( ... )
	
end

-- Logic Starting
function FinishFB:Config()
	self.normalize = 0
	self.waitTime = 180000
	-- self.curFBVo = FBModel:GetInstance():GetFBVoByMapId()
	if self.curFBVo then 
		self.waitTime = 180000
	end
	self.Content.text = StringFormat("副本结束：{0}",TimeTool.GetTimeMS(self.waitTime/1000,true))
	RenderMgr.Add(function () self:Update() end, "fbCutDown")
end

function FinishFB:OnEnable()
	--激活的时候开始倒计时
	
end

function FinishFB:OnDisable()
	
end

function FinishFB:Init()
	
end

function FinishFB:Refresh()
	
end

function FinishFB:Update()
	self.normalize = self.normalize + Time.deltaTime
	if self.ui == nil then return end 
	-- if self.normalize >=1 then 
	-- 	self.normalize = 0
	-- 	self.waitTime = self.waitTime - 1000
	-- 	if self.waitTime <=0 then 
	-- 		--别想了，这个时候你已经被服务器踢出副本了
	-- 		self.Content.text = StringFormat("副本关闭：{0}",TimeTool.GetTimeMS(0,true))
	-- 		return
	-- 	end
	-- 	self.Content.text = StringFormat("副本关闭：{0}",TimeTool.GetTimeMS(self.waitTime/1000,true))
	-- end
end



function FinishFB:OnClickExitBtn()
	--直接退出副本
end

-- Register UI classes to lua
function FinishFB:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("FB","FinishFB");

	self.Content = self.ui:GetChild("Content")
	self.Notice = self.ui:GetChild("Notice")
end

-- Combining existing UI generates a class
function FinishFB.Create( ui, ...)
	return FinishFB.New(ui, "#", {...})
end

-- Dispose use FinishFB obj:Destroy()
function FinishFB:__delete()
	RenderMgr.Remove("fbCutDown")
	self.Content = nil
	self.Notice = nil
end