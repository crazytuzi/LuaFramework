CDMessageBox =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function CDMessageBox:__init( ... )
	self.URL = "ui://wetrdvlhtr2p1r";
	self:__property(...)
	self:Config()
end

-- Set self property
function CDMessageBox:SetProperty( ... )
	
end

-- Logic Starting
function CDMessageBox:Config()
	self.btnCancel.onClick:Add(self.OnClickExitBtn,self)
	self.btnAgree.onClick:Add(self.OnClickReadyBtn,self)
	self.cd = 10
	self.normalize = 0
	self.txt_cd.UBBEnabled = true
	self.txt_cd.text = self:GetCDStr()
	RenderMgr.Add(function () self:Update() end, "fbReadyCutDown")
	self.prefabList = {}
end

function CDMessageBox:GetCDStr()
	local model = PkgModel:GetInstance()
	local now = #model:GetOnGrids() or 0
	local total = model.bagGrid or 0
	local str = ""
	if total - now < 8 then
		str = StringFormat("*注意 您的背包将满( [COLOR=#ff0000]{0}[/COLOR]/{1} ) 即将开始 : {2}", now, total, self.cd)
	else
		str = StringFormat("即将开始 : {0}", self.cd)
	end
	return str
end

function CDMessageBox:OnClickExitBtn()
	FBController:GetInstance():AgreeEnter(2) --拒绝
	FBModel:GetInstance():DispatchEvent(FBConst.E_DestroyCDMessageBox)
end

function CDMessageBox:OnClickReadyBtn()
	-- if SceneModel:GetInstance():IsMain() then
		FBController:GetInstance():AgreeEnter(1) --同意
		self.txt_cd.visible = true
		self.btnCancel.visible = false
		self.btnAgree.visible = false
		RenderMgr.Remove("fbReadyCutDown")
		self.txt_cd.text= StringFormat("等待其他玩家准备")
	-- else
	-- 	UIMgr.Win_FloatTip("请先回到主城")
	-- end
end

function CDMessageBox:Update()
	self.normalize = self.normalize + Time.deltaTime
	if self.ui == nil then return end 
	if self.normalize >=1 then 
		self.normalize = 0
		self.cd = self.cd - 1
		if self.cd <=0 then 
			self.txt_cd.text = StringFormat("即将开始：{0}",0)
			self:OnClickExitBtn()
			return
		end
		--self.txt_cd.text = StringFormat("即将开始：{0}",self.cd)
		self.txt_cd.text = self:GetCDStr()
	end
end

function CDMessageBox:OnDisable()

end

function CDMessageBox:Refresh(pName)
	self.btnCancel:GetChild("title").text = StringFormat("放弃")
	self.btnAgree:GetChild("title").text = StringFormat("准备")
	self.title.text = pName
	local offset = 150
	local interval = 0
	local list = ZDModel:GetInstance():GetMember()
	if list == nil then return end  
	local teamerNum = 0
	for _,vo in pairs(list) do
		teamerNum = teamerNum + 1
	end
	if teamerNum == 1 then 
		interval = 300
	end
	if teamerNum == 2 then 
		interval = 150
	end
	if teamerNum == 3 then 
		interval = 100
	end
	if teamerNum == 4 then 
		interval = 0
	end
	i = 0
	for _,vo in pairs(list) do
		local prefab = UIPackage.CreateObject("FB" , "FBTeamHead")
		table.insert(self.prefabList,prefab)
		self.teamerConn:AddChild(prefab)
		i = i+1
		prefab:SetXY(interval + (i-1)*offset,0)
		if vo then 
			prefab:GetChild("headIcon").title = StringFormat("{0}",vo.level)
			prefab.title = StringFormat("{0}",vo.playerName)
			prefab:GetChild("headIcon").icon = StringFormat("Icon/Head/r{0}",vo.career)
		end
	end
end
-- Register UI classes to lua
function CDMessageBox:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("FB","CDMessageBox");

	self.bg = self.ui:GetChild("Bg")
	self.bg2 = self.ui:GetChild("Bg2")
	self.line = self.ui:GetChild("line")
	self.txt_cd = self.ui:GetChild("txt_cd")
	self.title = self.ui:GetChild("title")
	self.btnCancel = self.ui:GetChild("btnCancel")
	self.btnAgree = self.ui:GetChild("btnAgree")
	self.teamerConn = self.ui:GetChild("teamerConn")
end

-- Combining existing UI generates a class
function CDMessageBox.Create( ui, ...)
	return CDMessageBox.New(ui, "#", {...})
end

-- Dispose use CDMessageBox obj:Destroy()
function CDMessageBox:__delete()
	-- self:OnClickExitBtn()
	RenderMgr.Remove("fbReadyCutDown")
	self.bg = nil
	self.bg2 = nil
	self.line = nil
	self.playerName = nil
	self.txt_cd = nil
	self.title = nil
	self.btnCancel = nil
	self.btnAgree = nil
	self.Head = nil
	self.teamerConn = nil
end