LoadingBackToCityPanel =BaseClass(BaseView)

-- (Constructor) use LoadingBackToCityPanel.New(...)
function LoadingBackToCityPanel:__init( ... )
	self.URL = "ui://2bw6ypvmj4usd";

	self.ui = UIPackage.CreateObject("Collect","LoadingBackToCityPanel");

	
	self.process_bar_back_to_city = self.ui:GetChild("process_bar_back_to_city")
	self.label_process_title = self.ui:GetChild("label_process_title")

	self:InitEvent()
	self:InitData()
	self:InitUI()
end
function LoadingBackToCityPanel:InitEvent()
	--[[
		self.closeCallback = function () end
		self.openCallback  = function () end
	--]]
end
function LoadingBackToCityPanel:__delete()
	self.process_bar_back_to_city = nil
	self.label_process_title = nil
end

function LoadingBackToCityPanel:InitUI()
	self.process_bar_back_to_city.value = 0
	self.process_bar_back_to_city.max = 100
	self.label_process_title.text = ""
end

function LoadingBackToCityPanel:InitData()
	self.model = CollectModel:GetInstance()
end


function LoadingBackToCityPanel:SetProcessUI(curProcessValue)
	if curProcessValue then
		self.process_bar_back_to_city.value = curProcessValue
		self.process_bar_back_to_city.max = 100
	end
end

function LoadingBackToCityPanel:SetTitleUI(strTitle)
	if strTitle then
		self.label_process_title.text = strTitle
	end
end

function LoadingBackToCityPanel:SetUI()
	local collectData = self.model:GetCollectData()
	if not TableIsEmpty(collectData) then
		--倒计时
		self:SetProcessUI(collectData.countDown or 0)
		--标题
		self:SetTitleUI(collectData.title or "")
	end
end