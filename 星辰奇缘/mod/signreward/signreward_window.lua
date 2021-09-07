SignRewardWindow = SignRewardWindow or BaseClass(BaseWindow)

function SignRewardWindow:__init(model)
	self.mode = model
	self.mgr = SignRewardManager.Instance

	self.resList = {
         {file = AssetConfig.signreward_window, type = AssetType.Main}
         ,{file = AssetConfig.arena_textures,type = AssetType.Dep}
         ,{file = AssetConfig.signreward_texture,type =AssetType.Dep}
         ,{file = string.format(AssetConfig.effect,20325), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
         ,{file = string.format(AssetConfig.effect,20329), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }

    self.spendingTime = 0
    self.isReward = false
    self.direction = -1
    self.effectDirection = -1
    self.roll_time = 0
    self.targetNum = 0
    self.localNum = 0
    self.totaltime = 0
    self.showNum = 6
    self.spendingTime = 0
    self.data = nil

    self.signRewardItemList = {}
    self.datalist = {}

    -- self.isFinish = false
    self.currentItem = nil
    self.beginRotation = nil

    self.stepTimerId = nil
    self.changeTimerId = nil
    self.delayTimerId = nil

    self.effect = nil

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function()  self:OnHide() end)

    self.signRewardListener = function() self:Calculation() end
    self.signGetRewardListener = function(data) self:GetRewardNum(data) end
    self.isGetReward = false
    self.dicEffectId = nil
    self.monthDays = 0
 end

 function SignRewardWindow:__delete()
    if self.tweenId ~= nil then
      Tween.Instance:Cancel(self.tweenId)
       self.tweenId = nil
    end
    if self.tweeneffectId ~= nil then
      Tween.Instance:Cancel(self.tweeneffectId)
      self.tweeneffectId = nil
    end

 	SignRewardManager.Instance.rewardBackEvent:RemoveListener(self.signRewardListener)
    SignRewardManager.Instance.getRewardBackEvent:RemoveListener(self.signGetRewardListener)

     if self.stepTimerId ~= nil then
        LuaTimer.Delete(self.stepTimerId)
        self.stepTimerId = nil
    end

    if self.dicEffectId ~= nil then
        LuaTimer.Delete(self.dicEffectId)
        self.dicEffectId = nil
    end

    if self.changeTimerId ~= nil then
        LuaTimer.Delete(self.changeTimerId)
        self.changeTimerId = nil
    end

    if self.signRewardList ~= nil then
    	for i,v in ipairs(self.signRewardItemList) do
    		v:DeleteMe()
    	end
    end

     if self.delayTimerId ~= nil then
        LuaTimer.Delete(self.delayTimerId)
        self.delayTimerId = nil
    end
    self.signRewardItemList = nil

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    if self.isGetReward == true then
      local data = {type = 2,num = 0}
      self.mgr:send14108(data)
      self.isGetReward = false
    end
 	self:AssetClearAll()
 end

 function SignRewardWindow:InitPanel()
 	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.signreward_window))
 	self.gameObject.name = "SignRewardWindow"
 	UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)
 	local t = self.gameObject.transform
 	self.transform = t

 	self.closeBtn = t:Find("Main/Close"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)
 	self.roleArg = t:Find("Main/Bg/RoleArea")
 	self.descArg = t:Find("Main/Bg/DescArea")
 	self.dice = self.descArg:Find("RotationParent/DiceBg/Dice")
 	self.diceImage = self.dice:GetComponent(Image)
 	self.diceBtn = self.dice:GetComponent(Button)
 	self.rotationTarget = self.descArg:Find("RotationParent")
    self.rotationEffect = self.descArg:Find("RotationEffect")
    self.effectParent = self.descArg:Find("RotationEffect/EffectTarget")

    self.effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect,20325)))
    self.effect.transform:SetParent(self.effectParent)
    self.effect.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect.transform.localScale = Vector3(1, 1, 1)
    self.effect.transform.localPosition = Vector3(0,-30, -400)
    self.effect.gameObject:SetActive(false)


    self.dicEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect,20329)))
    self.dicEffect.transform:SetParent(self.gameObject.transform)
    self.dicEffect.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.dicEffect.transform, "UI")
    self.dicEffect.transform.localScale = Vector3(1, 1, 1)
    self.dicEffect.transform.localPosition = Vector3(108,-44,-400)
    self.dicEffect.gameObject:SetActive(false)


    -- self.rotationTarget:GetComponent(RectTransform).pivot = Vector2(0.5,-0.18)
 	self.beginRotation = self.rotationTarget.rotation
 	self.descText = self.descArg:Find("TmesText"):GetComponent(Text)

 	self.noticeBtn = self.descArg:Find("Notice"):GetComponent(Button)
    self.activeDic = self.descArg:Find("ActiveDice")
    self.activeDic.gameObject:SetActive(false)
    self.activeDic:GetComponent(RectTransform).sizeDelta = Vector2(55,60)
    self.activeDic.gameObject:SetActive(false)
    self.activeDicImg = self.activeDic:GetComponent(Image)

    self.targetNum = self.descArg:Find("TargetNum")
    self.targetLeftChangeNum = self.descArg:Find("TargetNum/LeftChangeColor")
    self.targetRightChangeNum = self.descArg:Find("TargetNum/RightChangeColor")
    self.mideBoudary = self.descArg:Find("TargetNum/MidelBoudary")
    self.mideBoudary.gameObject:SetActive(false)

    self.targetLeftChangeNum.gameObject:SetActive(false)
    self.targetRightChangeNum.gameObject:SetActive(false)



 	for i,v in ipairs(DataCheckin.data_signreward) do
 		self.datalist[i] = v
 	end

 	for i=1,17 do
 		local item = SignRewardItem.New(nil,nil,self.roleArg:Find(tostring(i)).gameObject)
 		--BaseUtils.dump(item, "=========================================")
 		UIUtils.AddUIChild(self.roleArg:Find(tostring(i)).gameObject.transform:Find("Slot"),item.slot.gameObject)
 		table.insert(self.signRewardItemList,item)
 	end


    -- self.signRewardItemList[17] = SignRewardItem.New(nil,nil,self.roleArg:Find("End").gameObject)
    -- UIUtils.AddUIChild(self.roleArg:Find("End").gameObject,self.signRewardItemList[17].slot.gameObject)

    self.noticeBtn.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData ={
         	TI18N("1.绯月宝藏次数可通过<color='#ffff00'>充值</color>获得"),
         	TI18N("2.每抽取一次宝藏，都会增加一定数量的<color='#ffff00'>幸运值</color>"),
         	TI18N("3.幸运值越高，获得<color='#ffff00'>珍品</color>的机会就越大；当幸运值满时，<color='#ffff00'>必定</color>获得珍品道具"),
            TI18N("4.获得珍品道具后，幸运值会<color='#ffff00'>重置</color>为0，进行重新累计，珍品道具可重复获得")
         	},isChance = true})
        --TipsManager.Instance.model:OpenChancePanel(201)
        TipsManager.Instance.model:ShowChance({chanceId = 201, special = true, isMutil = true})
    end)

    self:OnOpen()
end

function SignRewardWindow:OnClickClose()
    self.model:CloseWin()
end

function SignRewardWindow:OnOpen()
    self.isGetReward = false

    if self.openArgs ~= nil then
        self.totaltime = self.openArgs[1].rand_num
        self.roll_time = self.openArgs[1].rand_reward
        self.monthDays = self.openArgs[2]
    end

    if self.totaltime ~= nil and self.totaltime ~= 0 then
       self.currentItem = self.signRewardItemList[self.totaltime]
       self.currentItem:ShowMySelectImg(true)
    end

    SignRewardManager.Instance.rewardBackEvent:AddListener(self.signRewardListener)
    SignRewardManager.Instance.getRewardBackEvent:AddListener(self.signGetRewardListener)

	self.direction = -1
    self.effectDirection = -1
	self.isReward = false
	-- self.isFinish = false
	self.rotationTarget.rotation = self.beginRotation
	self.showNum = (BaseUtils.BASE_TIME - 1) % 6 + 1
	self.diceImage.sprite = self.assetWrapper:GetSprite(AssetConfig.arena_textures,"dice_"..self.showNum)
	self.descText.text = string.format(TI18N("剩余次数:<color=#00FF00>%s</color>"),tostring(self.roll_time))

	self.diceBtn.onClick:AddListener(function() self:GotoReward() end)

	self:UpdateItem()


	-- if self.totaltime >=17 then
	-- 	self.isFinish = true
	-- 	self:UpdateItem()
	-- end
end

function SignRewardWindow:OnHide()
	SignRewardManager.Instance.rewardBackEvent:RemoveListener(self.signRewardListener)
    SignRewardManager.Instance.getRewardBackEvent:RemoveListener(self.signGetRewardListener)

    if self.tweenId ~= nil then
	   Tween.Instance.Cancel(self.tweenId)
    end
    self.tweenId = nil

    if self.tweeneffectId ~= nil then
       Tween.Instance.Cancel(self.tweeneffectId)
    end
    self.tweeneffectId = nil

	 if self.stepTimerId ~= nil then
        LuaTimer.Delete(self.stepTimerId)
        self.stepTimerId = nil
    end

     if self.changeTimerId ~= nil then
        LuaTimer.Delete(self.changeTimerId)
        self.changeTimerId = nil
    end

     if self.delayTimerId ~= nil then
        LuaTimer.Delete(self.delayTimerId)
        self.delayTimerId = nil
    end


    if self.signRewardItemList ~= nil then
    	for i,v in ipairs(self.signRewardItemList) do
    	 	v:ShowGetImg(false)
    	 	v:ShowMySelectImg(false)
    	 end
    end


     self.effect.gameObject:SetActive(false)


end


function SignRewardWindow:UpdateItem()
	for i=1,17 do
		local data = DataItem.data_get[self.datalist[i].item_id]
 		self.signRewardItemList[i].slot:SetAll(data,{inbag = false, nobutton = true})
        self.signRewardItemList[i].slot:SetNum(self.datalist[i].num)
        self.signRewardItemList[i]:ShowEffect(self.datalist[i].isEffect)
	end
end

function SignRewardWindow:GotoReward()
    -- if self.isFinish == true then
    --     self:RefreshReward()
    -- end

    if  self.roll_time >= 1 then
        if self.isReward == false then
            self.isReward = true
            self.effect.gameObject:SetActive(true)
            self.changeTimerId = LuaTimer.Add(50,100, function() self:BeginChangeDice() end)
            self:RotatePoint()
            self:RotateEffect()
        else
            self:StopRotatePoint()
        end
    else
        print("我进来这里啦？")
        local t = 5 - BibleManager.Instance.model.dailyCheckData.signed % 5

        local distance = self.monthDays - BibleManager.Instance.model.dailyCheckData.signed
        if distance < 5 then
            t = distance + 5
         end
        NoticeManager.Instance:FloatTipsByString(TI18N("再签到" .. "<color='#ffff00'>" .. t .. "</color>" .. "次即可抽奖{face_1,3}"))
    end
    -- self.delayTimerId = LuaTimer.Add(100,function() self:SetIsRewardStatus() end).id
end

-- function SignRewardWindow:SetIsRewardStatus()
-- 	self.isReward = true
-- end
function SignRewardWindow:RotateEffect()
    if self.tweeneffectId ~= nil then
        Tween.Instance:Cancel(self.tweeneffectId)
        self.tweeneffectId = nil
    end

    self.tweeneffectId = Tween.Instance:ValueChange(-30 * self.effectDirection,30 * self.effectDirection,0.5, function() self.tweeneffectId = nil self:RotateEffect(callback) end, LeanTweenType.Linear,function(value) self:RotateEffectValueChange(value) end).id
    self.effectDirection = self.effectDirection * -1
end
function SignRewardWindow:RotateEffectValueChange(value)
     self.rotationEffect.localRotation = Quaternion.Euler(0, 0, value)
end

function SignRewardWindow:RotatePoint()
    self.mideBoudary.gameObject:SetActive(true)
    self.activeDic.gameObject:SetActive(false)
    self.targetLeftChangeNum.gameObject:SetActive(true)
	-- self.tweenId = Tween.Instance:ValueChange(self.rotationTarget.rotation.eulerAngles.z,30 * self.direction, 1, function() self.tweenId = nil self:RotatePoint(callback) end, LeanTweenType.Linear,function(value) self:RotateValueChange(value) end).id
    self.targetRightChangeNum.gameObject:SetActive(true)

    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end

	self.tweenId = Tween.Instance:ValueChange(-60 * self.direction,60 * self.direction,0.5, function() self.tweenId = nil self:RotatePoint(callback) end, LeanTweenType.Linear,function(value) self:RotateValueChange(value) end).id
	self.direction = self.direction * -1
end

function SignRewardWindow:BeginChangeDice()
    self.spendingTime = self.spendingTime + 1
	self.diceImage.sprite = self.assetWrapper:GetSprite(AssetConfig.arena_textures, "dice_Action_"..(self.spendingTime % 4))
end

function SignRewardWindow:RotateValueChange(value)
	self.rotationTarget.localRotation = Quaternion.Euler(0, 0, value)
end
function SignRewardWindow:StopRotatePoint()
	Tween.Instance:Cancel(self.tweenId)
    self.tweenId = nil
    Tween.Instance:Cancel(self.tweeneffectId)
    self.tweeneffectId = nil


    if self.rotationTarget.eulerAngles.z > 180 then
    	local rotationAngle = Quaternion.Angle(self.rotationTarget.rotation,self.beginRotation)
    	if rotationAngle >0 and rotationAngle <= 60 then
            self.targetNum = 2
            self.targetLeftChangeNum.gameObject:SetActive(false)
    	end
    elseif self.rotationTarget.eulerAngles.z < 180 then

    	local rotationAngle = Quaternion.Angle(self.rotationTarget.rotation,self.beginRotation)
    	if rotationAngle >= 0 and rotationAngle <= 60 then
    		self.targetNum = 1
            self.targetRightChangeNum.gameObject:SetActive(false)
    	end
    end

    if self.effect ~= nil then
        self.effect.gameObject:SetActive(false)
    end


    -- self.rotationTarget.rotation = self.beginRotation

    self.diceBtn.onClick:RemoveAllListeners()
    self.diceBtn.onClick:AddListener(function() self:GameNotice() end)

    self.isGetReward = true
    local data = {type = 1,num = self.targetNum}
    self.mgr:send14108(data)
end


function SignRewardWindow:GameNotice()
    NoticeManager.Instance:FloatTipsByString(TI18N"别着急,游戏还未完成")
end

function SignRewardWindow:GetRewardNum(data)

    if data.id < self.totaltime then
        self.targetNum = data.id + 17 - self.totaltime
    else
        self.targetNum = data.id - self.totaltime
    end
    self.localNum = self.targetNum

    self.dicEffect.gameObject:SetActive(true)
    if self.signRewardItemList[self.totaltime] ~= nil then
       self.signRewardItemList[self.totaltime]:ShowGetImg(false)
    end
    self.dicEffectId = LuaTimer.Add(500, function() self:SetActiveDice() end)
end

function SignRewardWindow:SetActiveDice()
    self.dicEffect.gameObject:SetActive(false)
    self.activeDicImg.sprite = self.assetWrapper:GetSprite(AssetConfig.arena_textures,"dice_"..self.targetNum)
    if self.changeTimerId ~= nil then
        LuaTimer.Delete(self.changeTimerId)
        self.changeTimerId = nil
    end
    self.activeDic.gameObject:SetActive(true)
    self:Calculation()
end

function SignRewardWindow:Calculation()
	 self.diceImage.sprite = self.assetWrapper:GetSprite(AssetConfig.arena_textures,"dice_"..self.targetNum)
	 self.stepTimerId = LuaTimer.Add(50,350,function() self:GotoTarget() end)
end

function SignRewardWindow:GotoTarget()
	 self.localNum = self.localNum - 1
     if self.localNum < 0 then
		if self.stepTimerId ~= nil then
			LuaTimer.Delete(self.stepTimerId)
			self.stepTimerId = nil
		end
        self.isGetReward = false
        local data = {type = 2,num = 0}
        self.mgr:send14108(data)

		self:HandleResult()
	 else
         self.totaltime = self.totaltime + 1
	 	 if self.currentItem ~= nil then
	 	   self.currentItem:ShowMySelectImg(false)
	 	 end

         if self.totaltime > 17 then
            self.totaltime = self.totaltime - 17
            -- self.isFinish = true
         end

        self.signRewardItemList[self.totaltime]:ShowMySelectImg(true)
        self.currentItem = self.signRewardItemList[self.totaltime]
	 end
end


function SignRewardWindow:HandleResult()
    self:UpdateData()
    self.diceBtn.onClick:RemoveAllListeners()
    self.diceBtn.onClick:AddListener(function() self:GotoReward() end)
end
function SignRewardWindow:UpdateData()
    self.direction = -1
    self.effectDirection = -1
    self.isReward = false
    self.roll_time = self.roll_time - 1
    if self.descText ~= nil then 
        self.descText.text = string.format(TI18N("剩余次数:<color=#00FF00>%s</color>"),tostring(self.roll_time))
    end
    self.signRewardItemList[self.totaltime]:ShowGetImg(true)
end

-- function SignRewardWindow:RefreshReward()
-- 	for i,v in ipairs(self.signRewardItemList) do
-- 		v:ShowMySelectImg(false)
-- 		v:ShowGetImg(false)
-- 	end
--     self:UpdateItem()
--     self.isFinish = false
-- end
