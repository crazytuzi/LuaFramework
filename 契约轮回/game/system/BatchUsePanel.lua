--
-- @Author: chk
-- @Date:   2018-11-12 16:36:50
--
BatchUsePanel = BatchUsePanel or class("BatchUsePanel",WindowPanel)
local BatchUsePanel = BatchUsePanel

function BatchUsePanel:ctor()
	self.abName = "system"
	self.assetName = "BatchUsePanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true
	self.maxCount = 1
	self.useCount = 1
	--self.oneSlider = 1
	self.globalEvents = {}
	self.events = {}
	self.panel_type = 4
	-- self.model = 2222222222222end:GetInstance()
end

function BatchUsePanel:dctor()
	for i, v in pairs(self.globalEvents) do
		GlobalEvent:RemoveListener(v)
	end

	for i, v in pairs(self.events) do
		BagModel.GetInstance():RemoveListener(v)
	end

	if self.iconSettor ~= nil then
		self.iconSettor:destroy()
	end
end

function BatchUsePanel:Open( data , auto_use_count)
	self.data = data
	if not self.data then
		return
	end
	self.maxCount = self.data.num
	self.auto_use_count = auto_use_count
	BatchUsePanel.super.Open(self)
end

function BatchUsePanel:LoadCallBack()
	self.nodes = {
		"Slider",
		"Slider/Handle Slide Area/Handle/countBG/count",
		"MinusBtn",
		"AddBtn",
		"CancleBtn",
		"ConfirmBtn",
		"nameTxt",
		"icon",
	}
	self:GetChildren(self.nodes)
	self:GetRectTransform()
	self:AddEvent()

	self:SetTileTextImage("bag_image", "bag_use_f")
	self.transform:SetAsLastSibling()
end

function BatchUsePanel:AddEvent()
	local function call_back()
		self:Close()
	end
	AddClickEvent(self.CancleBtn.gameObject,call_back)

	local function call_back()
		GoodsController.GetInstance():RequestUseItem(self.data.uid,self.useCount)
		self:Close()
	end
	AddClickEvent(self.ConfirmBtn.gameObject,call_back)

	self.sliderSder.onValueChanged:AddListener(handler(self,self.SliderChange))

	local function call_back()
		self.useCount = self.useCount - 1
		if self.useCount < 1 then
			self.useCount = 1
		end
		self.sliderSder.value = self.useCount
		self.countTxt.text = tostring(self.useCount)
	end
	AddClickEvent(self.MinusBtn.gameObject,call_back)

	local function call_back()
		self.useCount = self.useCount + 1
		if self.useCount >= self.maxCount then
			self.useCount = self.maxCount
		end

		self.sliderSder.value = self.useCount
		self.countTxt.text = tostring(self.useCount)
	end
	AddClickEvent(self.AddBtn.gameObject,call_back)

	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(GoodsEvent.DelItems,handler(self,self.DealDelItems))
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(GoodsEvent.UpdateNum,handler(self,self.UpdateNum))
end

function BatchUsePanel:GetRectTransform()
	self.countTxt = self.count:GetComponent('Text')
	self.nameTxtTxt  = self.nameTxt:GetComponent('Text')
	self.sliderSder = self.Slider:GetComponent('Slider')
end

function BatchUsePanel:OpenCallBack()
	self:UpdateView()
end

function BatchUsePanel:DealDelItems(bagId,uid)
	if self.data.uid == uid then
		self:Close()
	end
end

function BatchUsePanel:UpdateNum(bagId,uid,num)
	if self.data.uid == uid then
		self.maxCount = num

		--self.oneSlider = 1 / self.maxCount
		if self.useCount > self.maxCount then
			self.useCount = self.maxCount
			--self.sliderSder.value = 1
		end
		self.sliderSder.maxValue = self.maxCount
		self:SliderChange(self.useCount)
		self.countTxt.text = tostring(self.useCount)
	end
end

function BatchUsePanel:UpdateView( )
	if not self.data then
		self:Close()
		return
	end

	local itemCfg = Config.db_item[self.data.id]

	self.iconSettor = GoodsIconSettorTwo(self.icon)
	local param = {}
	param["item_id"] = self.data.id
	param["p_item_base"] = self.data
	param["num"] = self.maxCount
	self.iconSettor:SetIcon(param)
	--self.iconSettor:UpdateIcon(self.data,self.maxCount)
	self.nameTxtTxt.text = itemCfg.name
	self.countTxt.text = tostring(self.maxCount)
	if self.auto_use_count then
        self.useCount = self.auto_use_count
	elseif itemCfg.stype == enum.ITEM_STYPE.ITEM_STYPE_AFK then
		local hour = SettingModel:GetInstance():GetAfkTime()
        local total_hour = tonumber(String2Table(Config.db_game["afk_max_time"].val)[1]/3600)
        local use_count = math.ceil((total_hour-hour)/itemCfg.effect)
        use_count = (use_count <= 0 and 1 or use_count)
        use_count = (use_count >= self.maxCount and self.maxCount or use_count)
        self.useCount = use_count
    else
    	self.useCount = self.maxCount
	end
	self.sliderSder.maxValue = self.maxCount
	self:SliderChange(self.useCount)
end

function BatchUsePanel:CloseCallBack(  )

end

function BatchUsePanel:SliderChange(value)
	self.sliderSder.value = value
	self.countTxt.text = tostring(value)
	self.useCount = value
end