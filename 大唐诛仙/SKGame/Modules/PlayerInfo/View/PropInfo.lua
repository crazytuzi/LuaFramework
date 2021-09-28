PropInfo =BaseClass(LuaUI)

PropInfo.IsDescBaseProShowing = false
PropInfo.IsDescSpecialProShowing = false

function PropInfo:__init( ... )
	self.URL = "ui://0oudtuxpcws9g";
	self:__property(...)
	self:Config()
end

function PropInfo:SetProperty(playerVo)
	self.playerVo = playerVo
end

function PropInfo:Config()
	self.PropItemPrefa = UIPackage.GetItemURL("PlayerInfo", "PropItem")
	self.model = PlayerInfoModel:GetInstance()
  	self.power.textFormat.font = UIPackage.GetItemURL("Common", "PowerFont2")

  	self.descBaseProPanel = nil
  	self.descSpecialProPanel = nil
end

--初始化属性面板
function PropInfo:Init(playerVo)
	self.playerVo = playerVo
	self.basePropList:RemoveChildrenToPool()
	self.fightPropList:RemoveChildrenToPool()
	self.InitGangInfo()
	self:InitBaseProp()
	self:InitBattleProp()
	--设置战力
	self.power.text = StringFormat("i{0}", self.playerVo.battleValue) 
end

function PropInfo:AddEvent()
	self.basePropList.onClick:Add(self.ShowBaseDescPanel, self)
	self.SpecialPropBtn.onClick:Add(self.ShowSpecialDescPanel, self)
end

function PropInfo:RemoveEvent()
	self.basePropList.onClick:Remove(self.ShowBaseDescPanel, self)
	self.SpecialPropBtn.onClick:Remove(self.ShowSpecialDescPanel, self)
end

function PropInfo:ShowBaseDescPanel()
	if PropInfo.IsDescBaseProShowing then
		UIMgr.HidePopup()
		PropInfo.IsDescBaseProShowing = false
	else
		local popUp = DescBaseProUI.New()
		UIMgr.ShowCenterPopup(popUp)
		PropInfo.IsDescBaseProShowing = true
	end
end

function PropInfo:ShowSpecialDescPanel()
	if PropInfo.IsDescSpecialProShowing then
		UIMgr.HidePopup()
		PropInfo.IsDescSpecialProShowing = false
	else
		local popUp = DescSpecialProUI.New()
		UIMgr.ShowCenterPopup(popUp)
		PropInfo.IsDescSpecialProShowing = true
	end
end

--初始化帮会信息
function PropInfo:InitGangInfo()
	-- if FamilyModel:GetInstance().familyName ~= "" then
	-- 	self.bangHuiLabel.text = FamilyModel:GetInstance().familyName
	-- end
end

--初始化玩家基础属性
function PropInfo:InitBaseProp()
	local playerBaseProp = self.model:GetPlayerBaseProp()
	if playerBaseProp then
		local num = 0
		for i,v in ipairs(playerBaseProp) do
			local item = self.basePropList:AddItemFromPool(self.PropItemPrefa)
			item:GetChild("PropName").text = StringFormat("{0}",v.name)
			item:GetChild("PropValue").text= StringFormat("{0}",v.value)
			num = num + 1  --最后一个属性下面不增加下划线
			if num == #playerBaseProp then
				item:GetChild("line").visible = false
			end
		end
	end
end

--初始化玩家战斗属性
function PropInfo:InitBattleProp()
	local playerBattleProp = self.model:GetPlayerBattleProp()
	if playerBattleProp then
		local num = 0
		for i,v in ipairs(playerBattleProp) do
			local item = self.fightPropList:AddItemFromPool(self.PropItemPrefa)
			item:GetChild("PropName").text = StringFormat("{0}",v.name)
			item:GetChild("PropValue").text= StringFormat("{0}",v.value)
			num = num + 1  --最后一个属性下面不增加下划线
			if num == #playerBattleProp then
				item:GetChild("line").visible = false
			end
		end
	end
end

-- Register UI classes to lua
function PropInfo:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("PlayerInfo","PropInfo");

	self.baseBg = self.ui:GetChild("BaseBg")
	self.basePropList = self.ui:GetChild("BasePropList")
	self.basePropLabel = self.ui:GetChild("BasePropLabel")
	self.basePropGround = self.ui:GetChild("BasePropGround")
	self.fightBg = self.ui:GetChild("FightBg")
	self.fightPropLabel = self.ui:GetChild("FightPropLabel")
	self.fightPropList = self.ui:GetChild("FightPropList")
	self.fightPropGround = self.ui:GetChild("FightPropGround")
	self.powerBg = self.ui:GetChild("PowerBg")
	self.power = self.ui:GetChild("Power")
	self.powerGround = self.ui:GetChild("PowerGround")
	self.bangHuiBg = self.ui:GetChild("BangHuiBg")
	self.bangHuiIcon = self.ui:GetChild("BangHuiIcon")
	self.zhanShenLevel = self.ui:GetChild("ZhanShenLevel")
	self.zhanShenLevelLabel = self.ui:GetChild("ZhanShenLevelLabel")
	self.bangHuiLabel = self.ui:GetChild("BangHuiLabel")
	self.bangHuiGround = self.ui:GetChild("BangHuiGround")
	self.TianFuBtn = self.ui:GetChild("TianFuBtn")
	self.SpecialPropBtn = self.ui:GetChild("SpecialPropBtn")

	self:AddEvent()
end

-- Combining existing UI generates a class
function PropInfo.Create( ui, ...)
	return PropInfo.New(ui, "#", {...})
end

-- Dispose use PropInfo obj:Destroy()
function PropInfo:__delete()
	self:RemoveEvent()

	if self.descBaseProPanel then
  		self.descBaseProPanel:Destroy()
  		self.descBaseProPanel = nil
	end

	if self.descSpecialProPanel then
  		self.descSpecialProPanel:Destroy()
  		self.descSpecialProPanel = nil
	end

end