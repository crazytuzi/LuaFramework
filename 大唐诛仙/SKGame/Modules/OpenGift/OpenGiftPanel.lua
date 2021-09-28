OpenGiftPanel = BaseClass(BaseView)
function OpenGiftPanel:__init( ... )
	self.URL = "ui://ls8mguzvrmqhd";
	self.ui = UIPackage.CreateObject("OpenGift","OpenGiftPanel");

	self.modelName = self.ui:GetChild("modelName")
	self.depictText1 = self.ui:GetChild("depictText1")
	self.depictText2 = self.ui:GetChild("depictText2")
	self.modelConn = self.ui:GetChild("modelConn")
	self.btnClose = self.ui:GetChild("btnClose")
	self.giftList = self.ui:GetChild("giftList")
	self.btnBuy = self.ui:GetChild("btnBuy")
	self.btnState = self.btnBuy:GetController("btnState")
	self.model = OpenGiftModel:GetInstance() 

	self.isInited = true

	self:Config()
end

-- start
function OpenGiftPanel:Config()
	self:InitData()
	self:AddEvent()
	self:AddBtnClick()
	self:RefreshBtnBuy()
end

function OpenGiftPanel:AddHandler()
	self.buyHandler = self.model:AddEventListener(OpenGiftConst.HadBuy, function ()
		self:RefreshBtnBuy()
	end)

	self.modelHandler = GlobalDispatcher:AddEventListener(EventName.PLAYER_MODEL, function ()
		self:ChangeModel( true )
	end)
end

function OpenGiftPanel:RemoveHandler()
	OpenGiftModel:GetInstance():RemoveEventListener(self.buyHandler)
	GlobalDispatcher:RemoveEventListener(self.modelHandler)
end

function OpenGiftPanel:InitData()
	self:AddHandler()
	self.rewardList = {} -- 奖励列表
	self.gameObject = nil -- 模型
	self.career = LoginModel:GetInstance():GetLoginRole().career
	self.modelName.url = "Icon/OpenGift/".. self.career
	self:CreateModel()
end

function OpenGiftPanel:AddEvent()
	local rewardData = self.model:GetReward()
	self:ShowReward(rewardData)
end

function OpenGiftPanel:RefreshBtnBuy()
	local state = self.model:IsGetRewardState()
	if state then
		self.btnState.selectedIndex = 1
		self.btnBuy.touchable = false
	end
end

function OpenGiftPanel:ChangeModel( isShow )
	if self.gameObject and self.modelConn then
		self.modelConn.visible = isShow
	end
end

function OpenGiftPanel:CreateModel()
	if self.isInited then
		local position = {}
		local angles = {}
		local scale = {}
		if self.career == 1 then
			position = {8, 333, 0}
			scale = {210, 210, 210}
			angles = {0, 0, 90}
		elseif self.career == 2 then
			position = {8, 294, 0}
			scale = {220, 220, 220}
			angles = {0, 0, 90}
		elseif self.career == 3 then
			position = {8, 190, 0}
			scale = {180, 180, 180}
			angles = {0, 0, 270}
		end
	
		self.modelConn.visible = true
		local callback = function ( prefab )
			if prefab == nil then return end
			self.gameObject = GameObject.Instantiate(prefab)
			self.gameObject.transform.localPosition = Vector3.New(position[1], position[2], position[3])
			self.gameObject.transform.localScale = Vector3.New(scale[1], scale[2], scale[3])
			self.gameObject.transform.localEulerAngles = Vector3.New(angles[1], angles[2], angles[3])
			self.modelConn:SetNativeObject(GoWrapper.New(self.gameObject)) -- ui 3d对象加入
		end
		LoadWeapon(self.model:GetEquipment(), callback)
	end
end

function OpenGiftPanel:ShowReward( data )
	for i = 1, #data do
		local iconData = data[i]
		local icon = PkgCell.New(self.giftList)
		icon:OpenTips(true)
		icon:SetDataByCfg(iconData[1], iconData[2], iconData[3], iconData[4])
		self.rewardList[i] = icon
	end
	self:ShowWeaponDes()
end

function OpenGiftPanel:ShowWeaponDes()
	local des = self.model:GetEquipmentDes()
	if #des > 2 then
		self.depictText1.text = StringFormat("{0},{1}", des[1], des[2])
		self.depictText2.text = des[3]
	else
		self.depictText1.text = des[1]
		self.depictText2.text = des[2]
	end
end

function OpenGiftPanel:AddBtnClick()
	self.btnClose.onClick:Add(function ()
		-- self.model:DispatchEvent(OpenGiftConst.ClosePanel)
		self.model:ClosePopPanel( true )
		self:Close()
	end)

	self.btnBuy.onClick:Add(function ( e )
		self:ChangeModel( false )
		self.btnBuy.data = self.model:GetId()
		PayModel:GetInstance():OnCellClick( e )
	end)
end

function OpenGiftPanel:Clear()
	if self.rewardList then 
		for i,v in ipairs(self.rewardList) do
			v:Destroy()
		end
	end
	self:RemoveHandler()
	self.rewardList = {}
	self.modelConn.visible = false
	self.gameObject = nil
end

function OpenGiftPanel:__delete()
	self:Clear()
	self.model = nil
end