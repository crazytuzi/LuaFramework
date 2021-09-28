LoadingCollectItem =BaseClass(LuaUI)
function LoadingCollectItem:__init( ... )
	self.URL = "ui://2bw6ypvmj4usb";
	self:__property(...)
	self:Config()
end
function LoadingCollectItem:SetProperty( ... )
	
end
function LoadingCollectItem:Config()
	self:InitData()
	self:InitUI()
end

function LoadingCollectItem:InitUI()
	self.label_process_title.text = ""
	self.process_bar_collect.value = self.collectData.countDown or 0
	self.process_bar_collect.max = self.collectData.countDown or 100
end

function LoadingCollectItem:InitData()
	self.model = CollectModel:GetInstance()
	self.renderKey = "LoadingCollectItem.PlayProcess"..tostring(self)
	self.collectData = self.model:GetCollectData()
	self.countDownData = 0
	self.endFun = nil
end

function LoadingCollectItem:SetProcessUI(curProcessValue)
	curProcessValue = curProcessValue or 0
	if curProcessValue ~= 0 then
		self.process_bar_collect.max = curProcessValue
		RenderMgr.CreateFrameRender(function() self:UpdateProcess() end, 1, -1, self.renderKey)
	end
end

function LoadingCollectItem:PlayProcess(lessTime)
	if self.process_bar_collect ~= nil then
		self.process_bar_collect.value = self.process_bar_collect.max - lessTime
		
		local a, b =  math.modf(lessTime)
		
		if not TableIsEmpty(self.collectData) then
			self:SetTitleUI(self.collectData.title or "", a)
		end
		if self.process_bar_collect.value >= self.process_bar_collect.max then
			self.process_bar_collect.value = self.process_bar_collect.max
		end
	end
end

function LoadingCollectItem:UpdateProcess()
	self.countDownData = self.countDownData + Time.deltaTime
	if not TableIsEmpty(self.collectData) and self.collectData.countDown >= self.countDownData then
		--self.collectData.countDown = self.collectData.countDown - Time.deltaTime

		local cd = math.floor(self.countDownData * 10)
		local integerCd = math.floor(cd / 10)
		local remainderCd = cd % 10
		local strCountDown = StringFormat("{0}.{1}", math.max(integerCd, 0), math.max(remainderCd, 0))
		self:SetTitleUI(self.collectData.title or "", strCountDown)
		self.process_bar_collect.value = self.countDownData
	else
		if self.endFun then
			
			self.endFun()
		end
	end
end

function LoadingCollectItem:SetEndFun(endFun)
	if endFun then
		self.endFun = endFun
	end
end

function LoadingCollectItem:EndProcess()
	-- if self.co then
	-- 	self.co = nil
	-- end

	self:EndCollect()

	self:Destroy()

	UIMgr.Win_FloatTip("采集成功")
end


function LoadingCollectItem:SetTitleUI(strTitle, strCountDown)
	if strTitle then
		self.label_process_title.text = strTitle .. strCountDown .."s"
	end
end

function LoadingCollectItem:SetUI()
	self.label_process_title.text = ""
	self.process_bar_collect.value = 0
	
	if not TableIsEmpty(self.collectData) then
		
		self:SetTitleUI(self.collectData.title or "", self.collectData.countDown or 0)
		self:SetProcessUI(self.collectData.countDown or 0)
	end
end

function LoadingCollectItem:EndCollect()
	local collectVo = CollectModel:GetInstance():GetCollectVo()
	if not TableIsEmpty(collectVo) then
		
		SceneController:GetInstance():C_EndCollect(collectVo.playerCollectId)
	end
end

function LoadingCollectItem:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Collect","LoadingCollectItem");

	self.process_bar_collect = self.ui:GetChild("process_bar_collect")
	self.label_process_title = self.ui:GetChild("label_process_title")
end
function LoadingCollectItem.Create( ui, ...)
	return LoadingCollectItem.New(ui, "#", {...})
end
function LoadingCollectItem:__delete()
	RenderMgr.Remove(self.renderKey)

	self.model = nil
	self.collectData = nil

	self.process_bar_collect = nil
	self.label_process_title = nil

end