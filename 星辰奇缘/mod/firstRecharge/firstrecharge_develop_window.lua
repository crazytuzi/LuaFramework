--首充二次改动窗口

FirstRechargeDevelopWindow = FirstDevelopRechargeWindow or BaseClass(BaseWindow)

function FirstRechargeDevelopWindow:__init(model)
    self.model = model
    self.name = "FirstDevelopRechargeWindow"

    self.windowId = WindowConfig.WinID.firstrecharge_window

    self.resList = {
        {file = AssetConfig.firstrechargedevelopwindow, type = AssetType.Main}
        ,{file  =  AssetConfig.firstrechargedeveloptexture, type  =  AssetType.Dep}
        ,{file = AssetConfig.firstrechargedevelopbig,type = AssetType.Main}
        ,{file = AssetConfig.backend_textures, type = AssetType.Dep}
        ,{file = AssetConfig.newmoon_textures, type = AssetType.Dep}
        ,{file = AssetConfig.firstrechargetextBigbg1, type = AssetType.Main}
        ,{file = AssetConfig.firstrechargetextBigbg2, type = AssetType.Main}
        ,{file = AssetConfig.firstrechargetextBigbg3, type = AssetType.Main}
        ,{file = AssetConfig.firstrechargetextBigbg4, type = AssetType.Main}
        ,{file = AssetConfig.firstrechargetextBigbg5, type = AssetType.Main}
        ,{file = AssetConfig.shop_textures,type = AssetType.Dep}
        ,{file = AssetConfig.grild_bigbg,type = AssetType.Dep}
        ,{file = AssetConfig.bigRound,type = AssetType.Dep}
        ,{file = AssetConfig.itemContanerRound,type = AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function()
      self:OnOpen()
    end)

    self.OnHideEvent:AddListener(function()
      self:OnHide()
    end)

    self.tabList = {}
    self.dataList = {}
    self.itemSlotList = {}

    self.effTimerId = nil
    self.tabLayout = nil
    self.luaGridLayout = nil
    self.lastSelectObj = nil
    self.previewComposite = nil
    self.tabIndex = 1
    self.nowTabIndex = 0
    self.extra = {inbag = false, nobutton = true}

    self.firstEffect = nil
    self.secondEffect = nil
    self.effTimerId = nil
    self.tweenId = nil
    self.refreshDataList = function() self:RefreshDateList() end
    self.haseGetListener = function() self:OnReplyHasGet() end

    self.textBgList = {}

    self.levelList = {60,1000,2000,10000,30000}
    self.nowLevel = 0

    self.nowDataIndex = 0
    self.nowCharge = 0
    self.effect = nil
    self.lastLevel = 0

    self.itemEffectList = {}
    self.newData = {}
    self.isInitOpen = false

    self.animationTimeId = nil
    self.isAnimator = false
end

function FirstRechargeDevelopWindow:InitPanel()
   self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.firstrechargedevelopwindow))
   self.gameObject.name = "FirstRechargeDevelopWindow"
   self.transform = self.gameObject.transform
   UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)

   local t = self.transform:Find("MainCon")
   t:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

   self.bigBg = t:Find("BigBg")
   local bigObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.firstrechargedevelopbig))
   UIUtils.AddBigbg(self.bigBg,bigObj)

   self.textBigBg = t:Find("Bg/TextBig")
   self.grildBigBg = t:Find("Bg/Grild"):GetComponent(Image)
   self.grildBigBg.sprite = self.assetWrapper:GetSprite(AssetConfig.grild_bigbg,"grild")

   self.myRoundBigBg = t:Find("EffectContainer/Image"):GetComponent(Image)
   self.myRoundBigBg.sprite = self.assetWrapper:GetSprite(AssetConfig.bigRound,"round")

   self.myItemBigBg = t:Find("Bg/ContainerBg"):GetComponent(Image)
   self.myItemBigBg.sprite = self.assetWrapper:GetSprite(AssetConfig.itemContanerRound,"itemcontainer")

   -- UIUtils.AddUIChild(main:Find("Slot").gameObject, self.slot.gameObject)

   self.tabContainer = t:Find("TabContainer")
   self.tabLayout = LuaBoxLayout.New(self.tabContainer.gameObject, {axis = BoxLayoutAxis.X, spacing = 5})

   self.tabTemplateTr = t:Find("TabTemplate")
   self.tabTemplateTr.gameObject:SetActive(false)

   for i=1,3 do
       local obj = GameObject.Instantiate(self.tabTemplateTr.gameObject)
       self.tabLayout:AddCell(obj)
       self.tabList[i] = obj
       self.tabList[i].transform:GetComponent(Button).onClick:AddListener(function() self:ChangeTab(i,false) end)
   end

    self.itemSetting = {
        column = 3
        ,cspacing = 31
        ,rspacing = 8
        ,cellSizeX = 64
        ,cellSizeY = 64
    }

   self.itemContainerTr = t:Find("Scrollbar/ItemContainer")
   self.luaGridLayout = LuaGridLayout.New(self.itemContainerTr.gameObject,self.itemSetting)


   self.rechargeBtn = t:Find("Recharge"):GetComponent(Button)
   self.rechargeBtn.onClick:AddListener(function() self:ApplyRechargeBtn() end)

   self.confirmButton = t:Find("ConfirmButton"):GetComponent(Button)

   self.hasGetButton = t:Find("HasGetButton"):GetComponent(Button)


   self.effectContainer = t:Find("EffectContainer")
   self.effectContainer:GetComponent(RectTransform).anchoredPosition = Vector2(230,-120)
   self.effectBottomRtr = t:Find("EffectContainer/Image"):GetComponent(RectTransform)
   self.effectBottomRtr.anchoredPosition = Vector2(-26,-11)
   self.effectBottomRtr.gameObject:SetActive(true)

   self.leftNoticeText = t:Find("Text"):GetComponent(Text)
   self.noticeText = t:Find("NoticeText"):GetComponent(Text)
   self.noticeText.text = TI18N("再充               元")
   self.textIcon = t:Find("Icon")
   self.RightButton = t:Find("I18NText/Button"):GetComponent(Button)
   self.RightButton.onClick:AddListener(function()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop,{3,2})
  end
  )

   self:OnOpen()
end

function FirstRechargeDevelopWindow:OnHide()
    self:RemoveListers()
    if self.effTimerId ~= nil then
       LuaTimer.Delete(self.effTimerId)
       self.effTimerId = nil
    end

     if self.animationTimeId ~= nil then
       LuaTimer.Delete(self.animationTimeId)
       self.animationTimeId = nil
    end


    if self.tweenId ~= nil then
      Tween.Instance:Cancel(self.tweenId)
      self.tweenId = nil
    end
end

function FirstRechargeDevelopWindow:__delete()
    self:RemoveListers()

    if self.animationTimeId ~= nil then
       LuaTimer.Delete(self.animationTimeId)
       self.animationTimeId = nil
    end

    if self.itemEffectList ~= nil then
        for i,v in ipairs(self.itemEffectList) do
          v:DeleteMe()
        end
        self.itemEffectList = nil
    end

    -- if self.effect ~= nil then
    --       self.effect:DeleteMe()
    --       self.effect = nil
    -- end
    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end

    if self.tweenId ~= nil then
      Tween.Instance:Cancel(self.tweenId)
      self.tweenId = nil
    end

    if self.firstEffect ~= nil then
        self.firstEffect:DeleteMe()
        self.firstEffect = nil
    end

    if self.secondEffect ~= nil then
        self.secondEffect:DeleteMe()
        self.secondEffect = nil
    end

    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
    end

    if self.luaGridLayout ~= nil then
        self.luaGridLayout:DeleteMe()
    end

    if self.tabLayout ~= nil then
        self.tabLayout:DeleteMe()
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function FirstRechargeDevelopWindow:OnOpen()
    self.isAnimator = false
    self.isInitOpen = false

    self:RemoveListers()
    self:AddListeners()
    PrivilegeManager.Instance:send9925()
    if self.effTimerId == nil then
       self.effTimerId = LuaTimer.Add(1000, 3000, function()
           self.rechargeBtn.gameObject.transform.localScale = Vector3(1.1,1.1,1)
           if self.tweenId == nil then
             self.tweenId = Tween.Instance:Scale(self.rechargeBtn.gameObject, Vector3(1,1,1), 1.2, function() self.tweenId = nil end, LeanTweenType.easeOutElastic).id
           end
       end)
    end


end


function FirstRechargeDevelopWindow:RefreshDateList()
    self.myIndex = nil
    if self.isInitOpen == false then
         self.nowCharge = PrivilegeManager.Instance.charge

         self.newData = {}

         for _,v in ipairs(self.levelList) do
             -- for i=1,DataPrivilege.data_section_length do
             for _,data in pairs(DataPrivilege.data_section) do
                 if v == data.min then
                    local tab1 = BaseUtils.copytab(data)
                    table.insert(self.newData,tab1)
                    tab1.index = tab1.lev
                 end
             end
         end

         self.nowLevel = 0
         for i=1,#self.levelList do
             if self.nowCharge >= self.levelList[i] and PrivilegeManager.Instance:GetPrivilegeState(self.newData[i].index) == 3 then
                 self.nowLevel = i
             else
                 break
             end
         end

        local myTargetCharge = nil
        if self.openArgs ~= nil and self.openArgs[1] ~= nil then
          self.openArgs[1] = self.openArgs[1] - 1
          for i=1,#self.levelList do
              if self.levelList[self.openArgs[1]] ~= nil then
                  myTargetCharge = self.levelList[self.openArgs[1]]

                  if self.nowLevel < self.openArgs[1] then
                      self.nowLevel = self.openArgs[1] - 1
                      self.myIndex = 2


                  elseif self.nowLevel > self.openArgs[1] then
                      self.nowLevel = self.openArgs[1]
                      self.myIndex = 1
                  else
                      self.nowLevel = self.openArgs[1]
                      self.myIndex = 1
                  end
                  print(self.nowLevel)
                  print(self.myIndex)
              else
                 print("<color='#00ff00'>首充奖励参数不符合格式</color>")
                 print(debug.traceback())
              end
          end
        end


         if self.nowLevel > #self.levelList - 3 then
            local distance = #self.levelList - self.nowLevel
            self.nowLevel = #self.levelList - 3
            if myTargetCharge ~= nil then
               self.myIndex = 4 - distance
            end
         end
    end


    for i=1,3 do
        self.dataList[i] = {}
        for _,v in ipairs(self.newData[i + self.nowLevel].item) do
            if v[4] == RoleManager.Instance.RoleData.classes or v[4] == 0 then
                table.insert(self.dataList[i],v)
                local id = v[1]
                local quality = DataItem.data_get[id].quality
                v[5] = quality
                self.dataList[i].topText = self.newData[i + self.nowLevel].topTitle
                self.dataList[i].bottomText = self.newData[i + self.nowLevel].bottomTitle
                self.dataList[i].title = self.newData[i + self.nowLevel].title
                self.dataList[i].attrs = self.newData[i + self.nowLevel].attrs
                self.dataList[i].min = self.newData[i + self.nowLevel].min
                self.dataList[i].state =  PrivilegeManager.Instance:GetPrivilegeState(self.newData[i + self.nowLevel].index)
                self.dataList[i].index = self.newData[i + self.nowLevel].index
            end
        end
    end

    local isInit = false
    local tabIndex = 1
    for i,v in ipairs(self.dataList) do
       if v.state == 2 then
         tabIndex = i
         break
       end

       if v.state == 1 and isInit == false then
         tabIndex = i
         isInit = true
       end
    end

    if self.isInitOpen == false then
      if self.myIndex ~= nil then
        self:ChangeTab(self.myIndex,true)
      else
        self:ChangeTab(tabIndex,true)
      end
       self.isInitOpen = true
    else
      self:RefreshData()
    end
end

function FirstRechargeDevelopWindow:RefreshTabText()
    for i=1,3 do
        local topText = self.tabList[i].transform:Find("TopText"):GetComponent(Text)
        topText.text = self.dataList[i].topText
        local bottomText = self.tabList[i].transform:Find("BottomText"):GetComponent(Text)
        bottomText.text = self.dataList[i].bottomText
    end
end

function FirstRechargeDevelopWindow:RefreshItem()
  if self.dataList[self.nowTabIndex] ~= nil then
    for i,v in ipairs(self.dataList[self.nowTabIndex]) do
        local Id = v[1]
        local num = v[3]
        local quality = v[5]
        local itemData = DataItem.data_get[Id]
        if self.itemSlotList[i] ~= nil then
            self.itemSlotList[i].gameObject:SetActive(true)
            self.itemSlotList[i]:SetAll(itemData,self.extra)
            self.itemSlotList[i]:SetNum(num)
        else
            local itemSlot = ItemSlot.New()
            itemSlot:SetAll(itemData,self.extra)
            self.itemSlotList[i] = itemSlot
            self.luaGridLayout:UpdateCellIndex(itemSlot.gameObject,i)
            self.itemSlotList[i]:SetNum(num)
        end

        if quality == 4 then
           if self.itemEffectList[i] ~= nil then
              if self.itemEffectList[i].effectId ~= 20224 then
                 self.itemEffectList[i]:DeleteMe()
                 self.itemEffectList[i] = nil
              end
          end
          if self.itemEffectList[i] == nil then
              self.itemEffectList[i] = BibleRewardPanel.ShowEffect(20224,self.itemSlotList[i].transform, Vector3(1, 1, 1), Vector3(32, -32, -400))
          else
            self.itemEffectList[i]:SetActive(true)
          end
        elseif quality == 3 then
          if self.itemEffectList[i] ~= nil then
              if self.itemEffectList[i].effectId ~= 20223 then
                 self.itemEffectList[i]:DeleteMe()
                 self.itemEffectList[i] = nil
              end
          end

          if self.itemEffectList[i] == nil then
              self.itemEffectList[i] = BibleRewardPanel.ShowEffect(20223,self.itemSlotList[i].transform, Vector3(1, 1, 1), Vector3(32, -32, -400))
          else
            self.itemEffectList[i]:SetActive(true)
          end
        else
          if self.itemEffectList[i] ~= nil then
            self.itemEffectList[i]:SetActive(false)
          end
        end

        self.itemSlotList[i].button.onClick:RemoveAllListeners()
        self.itemSlotList[i].button.onClick:AddListener(function() self.itemSlotList[i]:ClickSelf() end)


    end

   local maxLength = #self.dataList[self.nowTabIndex]
    if self.dataList[self.nowTabIndex].title ~= "" then

         local itemLength = #self.dataList[self.nowTabIndex]
         local itemData = DataItem.data_get[20000]
         if self.itemSlotList[itemLength + 1] ~= nil then
            self.itemSlotList[itemLength + 1].gameObject:SetActive(true)

         else
            print(#self.dataList[self.nowTabIndex])
             local itemSlot = ItemSlot.New()
            itemSlot:Default()
            self.itemSlotList[itemLength + 1] = itemSlot
            self.luaGridLayout:UpdateCellIndex(itemSlot.gameObject,itemLength + 1)
         end
         self.itemSlotList[itemLength + 1]:SetItemSprite(self.assetWrapper:GetSprite(AssetConfig.shop_textures,"Privilege"))
         self.itemSlotList[itemLength + 1]:SetNum(1)
        local itemDatatt = {}
        for i,v in ipairs(self.dataList[self.nowTabIndex].attrs) do
            table.insert(itemDatatt, string.format(v.val, tostring(DataPrivilege.data_exp[RoleManager.Instance.RoleData.lev].exp)))
        end

        self.itemSlotList[itemLength + 1].button.onClick:RemoveAllListeners()
        self.itemSlotList[itemLength + 1].button.onClick:AddListener(function()
            TipsManager.Instance:ShowText({gameObject = self.itemSlotList[itemLength + 1], itemData = itemDatatt}) end
        )
        if self.itemEffectList[itemLength + 1] ~= nil then
          self.itemEffectList[itemLength + 1]:SetActive(false)
        end

        maxLength = #self.dataList[self.nowTabIndex] + 1
    end


    if #self.itemSlotList > maxLength then
        for i=maxLength + 1,#self.itemSlotList do
            self.itemSlotList[i].gameObject:SetActive(false)
        end
        self.luaGridLayout:SetSizeForItemNum(#self.dataList)
    end
  end



end


function FirstRechargeDevelopWindow:ChangeTab(num,t)
    if self.nowTabIndex == num and t == false then
        return
    end





    local myIndex = self.nowTabIndex + self.lastLevel
    if self.textBgList[myIndex] ~= nil then
        self.textBgList[myIndex].gameObject:SetActive(false)
    end

    if self.tabList[self.nowTabIndex] ~= nil then
       self.tabList[self.nowTabIndex].transform:Find("Tab").gameObject:SetActive(true)
       self.tabList[self.nowTabIndex].transform:Find("TabSelect").gameObject:SetActive(false)
    end

    if self.tabList[num] ~= nil then
       self.tabList[num].transform:Find("Tab").gameObject:SetActive(false)
       self.tabList[num].transform:Find("TabSelect").gameObject:SetActive(true)
    end

    self.nowTabIndex = num


    myIndex = self.nowTabIndex + self.nowLevel


    if self.textBgList[myIndex] == nil then
        local bigObj = GameObject.Instantiate(self:GetPrefab(string.format(TI18N("prefabs/ui/bigatlas/rechargetexti18n%d.unity3d"),myIndex)))
        UIUtils.AddBigbg(self.textBigBg,bigObj)
        self.textBgList[myIndex] = bigObj
    end
    self.textBgList[myIndex].gameObject:SetActive(true)

    self:RefreshItem()
    self:InitRight(num)
    self:RefreshData()
    self:RefreshTabText()
    self.lastLevel = self.nowLevel

end

function FirstRechargeDevelopWindow:RefreshData()
    -- print(self.nowTabIndex .. "fsdkjfksdjfkjsd")
   if self.nowTabIndex == nil then return end
   if self.dataList[self.nowTabIndex].state == 1 then
        if self.effect ~= nil then
           self.effect:DeleteMe()
           self.effect = nil
        end
        -- if self.effect == nil then
        --     self.effect = BibleRewardPanel.ShowEffect(20053,self.rechargeBtn.transform,Vector3(2.3, 0.8, 1),Vector3(-72, -14.5, -400))
        --     self.effect:SetActive(true)
        -- end

        self.confirmButton.gameObject:SetActive(false)
        self.rechargeBtn.gameObject:SetActive(true)
        self.hasGetButton.gameObject:SetActive(false)


   elseif self.dataList[self.nowTabIndex].state == 2 then
        if self.effect ~= nil then
          self.effect:DeleteMe()
          self.effect = nil
        end
        -- if self.effect == nil then
        --   self.effect = BibleRewardPanel.ShowEffect(20053,self.confirmButton.transform,Vector3(2.2, 0.7, 1),Vector3(-69, -15, -400))
        --   self.effect:SetActive(true)
        -- end

        self.confirmButton.gameObject:SetActive(true)
        self.rechargeBtn.gameObject:SetActive(false)
        self.hasGetButton.gameObject:SetActive(false)
        self.confirmButton.onClick:RemoveAllListeners()



         self.nowCharge = PrivilegeManager.Instance.charge

        self.confirmButton.onClick:AddListener(function() self:OnReceive(self.dataList[self.nowTabIndex].index) end)

    elseif self.dataList[self.nowTabIndex].state == 3 then
        -- if self.effect ~= nil then
        --    self.effect:SetActive(false)
        -- end

        self.confirmButton.gameObject:SetActive(false)
        self.rechargeBtn.gameObject:SetActive(false)
        self.hasGetButton.gameObject:SetActive(true)
    end

    if self.nowCharge < self.dataList[self.nowTabIndex].min then
       local distance = self.dataList[self.nowTabIndex].min - self.nowCharge
       if distance > 0 then
          self.leftNoticeText.text =tostring(distance/10)

           if self.nowTabIndex + self.nowLevel > 1 then
              self.leftNoticeText.gameObject:SetActive(true)
              self.noticeText.gameObject:SetActive(true)
              self.textIcon.gameObject:SetActive(true)
           else
              self.leftNoticeText.gameObject:SetActive(false)
              self.noticeText.gameObject:SetActive(false)
              self.textIcon.gameObject:SetActive(false)
           end
       end
    else
      self.leftNoticeText.gameObject:SetActive(false)
      self.noticeText.gameObject:SetActive(false)
      self.textIcon.gameObject:SetActive(false)
    end
end


function FirstRechargeDevelopWindow:ApplyRechargeBtn()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop,{3})
end

function FirstRechargeDevelopWindow:InitRight(num)
    if self.firstEffect ~= nil then
          self.firstEffect:DeleteMe()
          self.firstEffect = nil
    end

    if self.secondEffect ~= nil then
          self.secondEffect:DeleteMe()
          self.secondEffect = nil
    end

    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end

    local index = self.nowLevel + num
    if  index ~= 1 then
      self.isAnimator = false
    end
    -- if index == 1 or index == 3 then
    if index == 1 or index == 3 then
      self:InitModel(10000,index)
      if index == 3 then
        -- if self.firstEffect == nil then
        --     self.firstEffect = BibleRewardPanel.ShowEffect(20375,self.effectContainer, Vector3.one, Vector3(-30,-7,-400))
        --     BaseUtils.dump(self.firstEffect,"new出来的数据形态")
        --     self.firstEffect.transform:Find("20375").gameObject:SetActive(false)
        -- end
      end

    elseif index == 2 then
     if self.firstEffect == nil then
          self.firstEffect = BibleRewardPanel.ShowEffect(20375, self.effectContainer, Vector3.one, Vector3(-30,-7,-400))
          self.firstEffect:SetActive(true)
      end
    elseif index == 4 then
      if self.firstEffect == nil then
          self.firstEffect = BibleRewardPanel.ShowEffect(20385, self.effectContainer, Vector3.one, Vector3(-30,-7,-400))
          self.firstEffect:SetActive(true)
      end
    elseif index == 5 then
      if self.firstEffect == nil then
          self.firstEffect = BibleRewardPanel.ShowEffect(20386, self.effectContainer, Vector3.one, Vector3(-30,-7,-400))
          self.firstEffect:SetActive(true)
      end
    end
end

---------------------------
function FirstRechargeDevelopWindow:InitModel(id,index)
    local petData = DataPet.data_pet[id] --跟据ID，取模型数据
    local data = nil
    if index == 1 then
      data = {type = PreViewType.Pet, skinId = petData.skin_id_0, modelId = petData.model_id, animationId = petData.animation_id, scale = petData.scale / 100, effects = petData.effects_0}
    elseif index == 3 then
      data = {scale = 1,sex = 1,type = 9,
        looks = {
            [1] = {
                looks_val = 1300,
                looks_type = 20,
            },
        },
        classes = 1,
        effects = {
        }
      }
    end

    local setting = {
        name = "FirstRechargeDevelopModelView"
        -- ,orthographicSize = 0.6
        ,orthographicSize = 0.6
        ,width = 300
        ,height = 300
        ,offsetY = -0.2
        ,noDrag = true
    }

    local fun = function(composite)
        local myScale = Vector3(1,1,1)
        local myRotation = Quaternion.identity
        if index == 1 then
          myScale = Vector3(1.5,1.5,1.5)
          if self.firstEffect == nil then
            self.firstEffect = BibleRewardPanel.ShowEffectInModel(20377, composite.tpose.transform, Vector3.one,Vector3(0,0,0),nil,nil,true)
            self.firstEffect:SetActive(true)

          end

          if self.secondEffect == nil then
            self.secondEffect = BibleRewardPanel.ShowEffectInModel(10203, composite.tpose.transform:Find("Bone_Other1_03"), Vector3.one, Vector3(0,0,0),nil,Quaternion.Euler(0,0,0),false)
            self.secondEffect:SetActive(true)

          end

        elseif index == 3 then
          if self.firstEffect == nil then
            self.firstEffect = BibleRewardPanel.ShowEffectInModel(20375,composite.tpose.transform, Vector3.one, Vector3(0.177,3.98,-0.171),nil,Quaternion.Euler(12.07,10.1,355.7))
            BaseUtils.dump(self.firstEffect,"new出来的数据形态")

            self.firstEffect.OnInitCompleted = function(myself) myself.transform:Find("20375").gameObject:SetActive(false) end
          end
          myScale = Vector3(1.2,1.2,1.2)
          myRotation = Quaternion.Euler(0, 0,0)
        end


        LuaTimer.Add(40, function()
          if BaseUtils.isnull(composite.rawImage) then
              return
          end
          local rawImage = composite.rawImage
          rawImage.gameObject:AddComponent(CanvasGroup)
          rawImage.transform:GetComponent(CanvasGroup).blocksRaycasts= false
          rawImage.transform:SetParent(self.effectContainer)
          rawImage.transform.localPosition = Vector3(-27,70, 0)
          if index == 1 then
            rawImage.transform.localPosition = Vector3(-27,70, 0)
          elseif index == 3 then
            rawImage.transform.localPosition = Vector3(-11,64, 0)
          end
          rawImage.transform.localScale = myScale
          --rawImage.transform.localScale = Vector3(1, 1, 1)
          rawImage.transform.localRotation = myRotation
            if index == 1 then
              composite.tpose:GetComponent(Animator):Play("Stand2")
            end
            if index == 3 then
              composite.tpose.transform.localRotation = Quaternion.Euler(353.384,25.66,354.648)
              composite.tpose.transform.localScale = Vector3(0.82,0.82,0.82)
            end
          end)


        --composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))
    end

    if self.previewComposite == nil then
        self.previewComposite = PreviewComposite.New(fun,setting,data)
        -- if index == 1 then
        --    if self.animationTimeId == nil then
        --      self.animationTimeId = LuaTimer.Add(0,100, function()
        --          print("hahah")
        --          if self.previewComposite.tpose ~= nil and self.isAnimator == false then
        --           print("我在这")
        --               self.previewComposite.tpose:GetComponent(Animator):Play("Move1")
        --              if self.isAnimator == false then
        --                  self.isAnimator = true
        --                   if self.animationTimeId ~= nil then
        --                     LuaTimer.Delete(self.animationTimeId)
        --                      self.animationTimeId = nil
        --                   end
        --              end
        --          end
        --       end
        --       )
        --    end

        -- end
    else
        self.previewComposite:Reload(data,fun)
        self.previewComposite:Show()
    end




end


function FirstRechargeDevelopWindow:AddListeners()
    PrivilegeManager.Instance.updateRecharge:AddListener(self.refreshDataList)
    PrivilegeManager.Instance.updateFirstRecharge:AddListener(self.haseGetListener)
end

function FirstRechargeDevelopWindow:RemoveListers()
    PrivilegeManager.Instance.updateRecharge:RemoveListener(self.refreshDataList)
    PrivilegeManager.Instance.updateFirstRecharge:RemoveListener(self.haseGetListener)
end

function FirstRechargeDevelopWindow:OnReceive(index)
    print(index)
    PrivilegeManager.Instance:send9926(index)
end

function FirstRechargeDevelopWindow:OnReplyHasGet()
   PrivilegeManager.Instance:send9925()
end












