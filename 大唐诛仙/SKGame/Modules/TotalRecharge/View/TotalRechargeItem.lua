TotalRechargeItem = BaseClass(LuaUI)

function TotalRechargeItem:__init( ... )
	self.URL = "ui://c76fl6zbkzveb";
	self:__property(...)
	self:Config()
end

-- Set self property
function TotalRechargeItem:SetProperty( ... )
end

-- start
function TotalRechargeItem:Config()
	self:InitData()
	self:InitUI()
	self:InitEvent()
end

-- wrap UI to lua
function TotalRechargeItem:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("TotalRechargeUI","TotalRechargeItem");

	self.bgSmallIcon = self.ui:GetChild("bgSmallIcon")
	self.bgSmallSelected = self.ui:GetChild("bgSmallSelected")
	self.smallIcon = self.ui:GetChild("smallIcon")
	self.bgSmallName = self.ui:GetChild("bgSmallName")
	self.labelSmallName = self.ui:GetChild("labelSmallName")
	self.smallType = self.ui:GetChild("smallType")
	self.bgBigIcon = self.ui:GetChild("bgBigIcon")
	self.bgBigSelected = self.ui:GetChild("bgBigSelected")
	self.bigIcon = self.ui:GetChild("bigIcon")
	self.bgBigName = self.ui:GetChild("bgBigName")
	self.labelBigName = self.ui:GetChild("labelBigName")
	self.bigType = self.ui:GetChild("bigType")
	self.effectRoot = self.ui:GetChild("effectRoot")

end

-- Combining existing UI generates a class
function TotalRechargeItem.Create( ui, ...)
	return TotalRechargeItem.New(ui, "#", {...})
end

function TotalRechargeItem:__delete()
	self.data = nil
	self:CleanEffect()
end

function TotalRechargeItem:InitData()
	self.data = {}
	self.effectObj = nil
end

function TotalRechargeItem:SetData(data)
	self.data = data or {}
end

function TotalRechargeItem:InitUI()

end

function TotalRechargeItem:InitEvent()
end

function TotalRechargeItem:SetUI()
	if not TableIsEmpty(self.data) then
		-- if TotalRechargeModel:GetInstance():IsHasEquipment(self.data.id or 0) then
		-- 	self.bigType.visible = true
		-- 	self.smallType.visible = false
		-- 	self.bigIcon.url = self:GetFirstRewardItemURL()
		-- 	self.smallIcon.url = ""
		-- 	self.labelSmallName.text = ""
		-- 	self.labelBigName.text = StringFormat("[color={0}]{1}[/color][color={2}]{3}[/color][color={4}]{5}[/color]" , "#f0fcee" ,"累积充值" , "#ffe400" , self.data.condition , "#f0fcee" , "元") 			
		-- else
		-- 	self.bigType.visible = false
		-- 	self.smallType.visible = true
		-- 	self.smallIcon.url = self:GetFirstRewardItemURL()
		-- 	self.bigIcon.url = ""
		-- 	self.labelBigName.text = ""
		-- 	self.labelSmallName.text = StringFormat("[color={0}]{1}[/color][color={2}]{3}[/color][color={4}]{5}[/color]" , "#f0fcee" ,"累积充值" , "#ffe400" , self.data.condition , "#f0fcee" , "元") 
		-- end
		--- 解决不了大圈的物品中心的位置  直接改成小圈
			self.bigType.visible = false
			self.smallType.visible = true
			self.smallIcon.url = self:GetFirstRewardItemURL()
			self.bigIcon.url = ""
			self.labelBigName.text = ""
			self.labelSmallName.text = StringFormat("[color={0}]{1}[/color][color={2}]{3}[/color][color={4}]{5}[/color]" , "#f0fcee" ,"累积充值" , "#ffe400" , self.data.condition , "#f0fcee" , "元") 
	end
end

function TotalRechargeItem:SetEffect()
	if not TableIsEmpty(self.data) then
		if self.data.state == TotalRechargeConst.RewardState.CanGet then
			self:LoadEffect(TotalRechargeConst.EffectName)
			self:SetEffectObjVisible(true)
		else
			self:SetEffectObjVisible(false)
		end
	end
end

function TotalRechargeItem:SetEffectObjVisible(bl)
	if bl ~= nil and type(bl) == "boolean" then
		if self.effectObj ~= nil then
			self.effectObj.gameObject:SetActive(bl) 
		end
	end
end


--获取IconUrl
--如果奖励第一个为武器，则前职业总数个都为各职业的武器，去当前职业的武器
--如果奖励第一个不为武器，直接取该Item
function TotalRechargeItem:GetFirstRewardItemURL()
	local rtnUrl = ""
	if not TableIsEmpty(self.data) then
		local rewardData = self.data.reward

		local rewardItems = TotalRechargeModel:GetInstance():GetRewardItemsData(self.data.id or 0)
		if #rewardItems > 0 then
			local firstItem = rewardItems[1] or nil
			if firstItem then
				rtnUrl = GoodsVo.GetIconUrl(firstItem[1], firstItem[2])		
			end		
		end

	end
	return rtnUrl
end

function TotalRechargeItem:SetY(y)
	if y then
		self.ui.y = y
	end
end


function TotalRechargeItem:CleanEffect()
	if self.effectObj ~= nil then
		GameObject.DestroyImmediate(self.effectObj)
		self.effectObj = nil
	end
end

function TotalRechargeItem:LoadEffect(res)
	if res == nil then return end
	if self.effectObj ~= nil then
		self.effectObj.gameObject:SetActive(true)
		return
	end
	local function LoadCallBack(effect)
		if effect then
			local effectObj = GameObject.Instantiate(effect)
			-- if TotalRechargeModel:GetInstance():IsHasEquipment(self.data.id or 0) then
			-- 	effectObj.transform.localPosition = Vector3.New(101 , -153 , 0)
			-- 	effectObj.transform.localScale = Vector3.New(1.2, 1.2, 1.2)
			-- else
			-- 	effectObj.transform.localPosition = Vector3.New(125 , -225 , 0)
			-- 	effectObj.transform.localScale = Vector3.New(1, 1, 1)
			-- end

			--- 解决不了大圈的物品中心的位置  直接改成小圈

			effectObj.transform.localPosition = Vector3.New(125 , -225 , 0)
			effectObj.transform.localScale = Vector3.New(1, 1, 1)
	 		effectObj.transform.localRotation = Quaternion.Euler(0, 0, 0)
	 		
	 		if effectObj  then
	 			self.effectRoot:SetNativeObject(GoWrapper.New(effectObj))
	 			self.effectObj = effectObj
	 		end
		end
	end
	LoadEffect(res , LoadCallBack)
end

function TotalRechargeItem:SetEffectVisible(bl)
	if bl ~= nil and type(bl) == 'boolean' then
		if self.effectRoot then
			self.effectRoot.visible = bl
		end
	end
end