PowerBattleItem = BaseClass(LuaUI)
function PowerBattleItem:__init( ... )
	self.URL = "ui://ic8go605psjw8";
	self:__property(...)
	self:Config()
end
-- Set self property
function PowerBattleItem:SetProperty( ... )
end
-- start
function PowerBattleItem:Config()
	self.model = PowerModel:GetInstance()
	self.pkgCellObjList = {}
	self:InitEvent()
end
-- wrap UI to lua
function PowerBattleItem:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("PowerLevelingActivitiesUI","ImproveItem");

	self.bg_item0 = self.ui:GetChild("bg_item0")
	self.imgArrow = self.ui:GetChild("imgArrow")
	self.lvNum = self.ui:GetChild("lvNum")
	self.surplusNum = self.ui:GetChild("surplusNum")
	self.rewardList = self.ui:GetChild("rewardList")
	local res = self.ui:GetChild("buttonGet")
	res.visible=false
	local btn = UIPackage.CreateObject("Common", "CustomBtn1")
	btn:SetXY(res.x+20, res.y)
	btn:SetSize(res.width - 40, res.height+10)

	self.ui:AddChild(btn)
	self.buttonGet = btn
	self.dian = self.ui:GetChild("dian")
	self.yiLingQuBtn = self.ui:GetChild("yiLingQuBtn")
end
-- Combining existing UI generates a class
function PowerBattleItem.Create( ui, ...)
	return PowerBattleItem.New(ui, "#", {...})
end

function PowerBattleItem:InitEvent()
	self.buttonGet.onClick:Add(
		function ()
		  local rewardState = self.model:GetImproveBattleBtnState(self.data.id)
		  	if self.data.total - self.data.num >0 then
				if rewardState == PowerConst.OnImproveBattleRewardState.CanGet then
					PowerLevelCtr:GetInstance():C_GetBattleValueAward(self.data.id)
					return
				end			
		  	else
		   		UIMgr.Win_FloatTip("该奖励已被领完！")
			end
			 PowerLevelCtr:GetInstance():C_GetBVAwardData() 
			
		end)

	local function OnImproveRewardNum(BattleNum)

		local index = self.model:GetIndexByBattleRewradId(self.data.id)
		local newData = self.model:GetImproveBattleData()[index]
		self:SetData(newData)
		self:BtnState(self.data)
	end	

	self.Handel1 = self.model:AddEventListener(PowerConst.ChangeBattleNum, OnImproveRewardNum)
end 

function PowerBattleItem:__delete()
	if self.model then
		self.model:RemoveEventListener(self.Handel1)
	end
	for i=1,#self.pkgCellObjList do
		if self.pkgCellObjList[i] then
			self.pkgCellObjList[i]:Destroy()
		end
	end
	self.data = {}
end

function PowerBattleItem:SetStartUi()
	self:BtnState(self.data)
	self:SetItemReward(self.data)
end

function PowerBattleItem:CleanBtnEvent()
	self.buttonGet.onClick:Clear()
end

function PowerBattleItem:RegistBtn()
	self:BtnState(self.data)
end
--状态
function PowerBattleItem:BtnState(data)

	local blueBg = UIPackage.GetItemURL("Common","btn_erji1")
	local yellowBg= UIPackage.GetItemURL("Common","btn_erji2")
	local yiLingQu= UIPackage.GetItemURL("PowerLevelingActivitiesUI","yilingqu")
	
	local serverNo = LoginModel:GetInstance():GetLastServerNo()

	local battleValue = self.model:GetCurrentRolebattleValue()

	self.lvNum.text = StringFormat("{0}",data.battleValue)
	self.surplusNum.text = (data.total - data.num) > 0 and  StringFormat("{0}/{1}",(data.total - data.num),data.total) or  StringFormat("[color=#ff0000]{0}/{1}[/color]",0,data.total)
	local  state = self.model:GetImproveBattleBtnState(data.id)
	if state == PowerConst.OnImproveBattleRewardState.CanNotGet then
		 self.buttonGet.title = "未达到"
		 self.buttonGet.icon = blueBg
		 self.yiLingQuBtn.visible = false
		 self.buttonGet.visible = true
		 self.buttonGet.touchable = false
	elseif  state == PowerConst.OnImproveBattleRewardState.AlreadyGet then
		 self.buttonGet.title = PowerConst.STR_YILINGQU
		 self.yiLingQuBtn.visible = true		 
		 self.buttonGet.visible = false
		 self.buttonGet.touchable = false
	else
		 self.buttonGet.title = PowerConst.STR_LINGQU
		 self.buttonGet.icon = yellowBg
		 self.yiLingQuBtn.visible = false
		 self.buttonGet.visible = true
		 self.buttonGet.touchable = true	
	end

end

function PowerBattleItem:SetItemReward(data)
	if data.id then
		local leveRewardCfg = self.model:GetLeveRewradCfgById(data.id)
		local career = LoginModel:GetInstance():GetLoginRole().career
		if not TableIsEmpty(leveRewardCfg) then
			local pkgDataList = leveRewardCfg.reward
			local dist = 18
			local pkgCellWidth = 77
			local pkgCellHeight = 77
			local bool = false
			for index = 1, #pkgDataList do
				if pkgDataList[index][1] == 1 then
				 if self.model:GetEquipNeedJob(pkgDataList[index][2]) == 0 or self.model:GetEquipNeedJob(pkgDataList[index][2]) == career  then
					bool = true
				 else
					bool = false
				 end
				else
					bool = true
				end
				if bool then
				--print("WUPIAN物品编号====",self.model:GetEquipNeedJob(tonumber(pkgDataList[index][2])) )
				 --print("WUPIAN物品编号====",pkgDataList[index][2])
				 local curPkgData = pkgDataList[index]
				 local pkgCellObj = PkgCell.New(self.rewardList)
				 table.insert(self.pkgCellObjList , pkgCellObj)
				 pkgCellObj:SetDataByCfg(curPkgData[1], curPkgData[2], curPkgData[3], curPkgData[4])
				 pkgCellObj:SetXY(238 + (pkgCellWidth + dist) * (index -1) , 0)

				 pkgCellObj:OpenTips(true)
			    end
			end
		end
	end
end

function PowerBattleItem:SetData(data)
	self.data = {}
	if data then
		self.data = data
	end
end