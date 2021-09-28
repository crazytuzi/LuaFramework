ReturnCDBar =BaseClass(LuaUI)
function ReturnCDBar:__init( ... )
	self.URL = "ui://0tyncec1gp6dnfl";
	self:__property(...)
	self:Config(...)
end

function ReturnCDBar:SetProperty( ... )
	
end

function ReturnCDBar:Config(...)
	local args = {...}
	if args[1] and type(args[1]) == "table" then
		self.customData = args[1]
	end

	self.isChanging = false
	self:Init()
end
--初始化完就启动
function ReturnCDBar:Init()
	self.cd = CommonConst.HUICHENG_CD_TIME
	self.label = self.bar:GetChild("Label")
	self.deltaTime = 0
	local str = "回城中"
	if self.customData and self.customData.text then
		str = self.customData.text
		self.cd = CommonConst.RETURN_CD_TIME
	end
	local cd = math.floor(self.cd*10)
	local cd1 = math.floor(cd/10)
	local cd2 = cd%10
	local strTxt = StringFormat("{0}...{1}.{2}s", str, cd1, cd2)
	self.label.text = strTxt
	self.bar.max = self.cd
	self.bar.value = self.cd
	local loadCB = function ()
		RenderMgr.Add(function () self:Update() end, "ReturnCutDown")
	end
	self:LoadEffect("30008", loadCB)
end

function ReturnCDBar:Update()
	if not self.bar then return end
	self.deltaTime = self.deltaTime + Time.deltaTime
	if self.cd <= 0 then
		if self.customData and self.customData.tType then
			if self.customData.tType == "enterfb" and self.customData.args then
				FBController:GetInstance():RequireEnterInstance(self.customData.args)
			elseif self.customData.tType == "entertower" and self.customData.func then
				self.customData.func()
			else
				SceneController:GetInstance():C_EnterScene(self.customData.args)
			end
		else
			SceneController:GetInstance():C_EnterScene(1001)
		end
		self:Destroy()
	else
		self.deltaTime = 0
		self.cd = self.cd - Time.deltaTime
		local cd = math.floor(self.cd*10)
		local cd1 = math.floor(cd/10)
		local cd2 = cd%10
		local strTxt = StringFormat("回城中...{0}.{1}s",math.max(cd1,0),math.max(cd2,0))
		if self.customData and self.customData.text then
			strTxt = StringFormat("{0}...{1}.{2}s", self.customData.text, math.max(cd1,0), math.max(cd2,0))
		end
		self.label.text = strTxt
		self.bar.value = self.cd
	end	
end

function ReturnCDBar:LoadEffect(res, loadCB)
	if not res then return end
	if self.isChanging then return end
	self.isChanging = true
	EffectMgr.RealseEffect(self.effectId)
	local mainPlayer = SceneController:GetInstance():GetScene():GetMainPlayer()
	if mainPlayer then
		local callback = function (id)
			local effectGo = EffectMgr.GetEffectById(id)
			if effectGo == nil then return end 
			local tf = effectGo.transform
			tf.localPosition =Vector3.New(0,-0.28,0)
			tf.localScale = Vector3.New(1,1,1)
			if loadCB then loadCB() end
		end
		local destroyCallback = function ()
			self.isChanging = false
			EffectMgr.RealseEffect(self.effectId)
		end
		local tTime = CommonConst.HUICHENG_CD_TIME
		if self.customData and self.customData.text then
			tTime = CommonConst.RETURN_CD_TIME
		end
		self.effectId = EffectMgr.BindTo(res, mainPlayer.gameObject,tTime,nil,nil,nil,callback,nil,1,destroyCallback,nil)
	end
end

function ReturnCDBar:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Common","ReturnCDBar");
	self.bar = self.ui:GetChild("bar")
end

function ReturnCDBar.Create( ui, ...)
	return ReturnCDBar.New(ui, "#", {...})
end

function ReturnCDBar:__delete()
	RenderMgr.Remove("ReturnCutDown")
	EffectMgr.RealseEffect(self.effectId)
	self.isChanging = false
	self.bar = nil
end