--2017/8/18
--zyh
--情缘查看界面
LoveCheckWindow = LoveCheckWindow or BaseClass(BaseWindow)

function LoveCheckWindow:__init(model)
    self.model = model
    self.mgr = LoveCheckWindow.Instance

    self.resList = {
       {file = AssetConfig.love_check,type = AssetType.Main,holdTime = 5}
      ,{file = AssetConfig.love_check_bg,type = AssetType.Dep}
      ,{file = AssetConfig.love_texture,type = AssetType.Dep}
      ,{file  =  AssetConfig.firstrechargedeveloptexture,type = AssetType.Dep}
      ,{file = AssetConfig.specialitem_bigbg,type = AssetType.Dep}
      -- ,{file = AssetConfig.specialitem_text_bigbg,type = AssetType.Main}
      -- ,{file = AssetConfig.specialitem_icon_bigbg,type = AssetType.Main}

    }
    self.OnOpenEvent:Add(function() self:OnOpen() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.windowId = WindowConfig.WinID.love_check

    self.refreshData = function() self:RefreshData() end
    self.itemDataList = {}
    self.itemList = {}
    self.itemEffectList = {}

    self.distance = 5
    self.tagetIndex = 0

    self.topImgLoader = nil
    self.leftImgLoader = nil
    self.rightImgLoader = nil
    self.extra = {inbag = false, nobutton = true}
    self.SetSetConcentricValueFun = function() self:SetSetSetConcentricValue() end
    self.setDataFun = function() self:SetData() end
    self.signRewardEffect = nil

end

function LoveCheckWindow:__delete()
    self:RemoveListeners()


    if self.signRewardEffect ~= nil then
      self.signRewardEffect:DeleteMe()
      self.signRewardEffect = nil
    end
     if self.itemEffectList ~= nil then
        for i,v in ipairs(self.itemEffectList) do
          v:DeleteMe()
        end
        self.itemEffectList = {nil}
     end

     if self.itemList ~= nil then
        for i,v in ipairs(self.itemList) do
            v:DeleteMe()
        end
        self.itemList = {}
     end

     if self.itemLayout ~= nil then
        self.itemLayout:DeleteMe()
     end
     if self.topLayout ~= nil then
        self.topLayout:DeleteMe()
     end
     if self.leftLayout ~= nil then
        self.leftLayout:DeleteMe()
     end
     if self.rightLayout ~= nil then
        self.rightLayout:DeleteMe()
     end

     if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
     end
     self:AssetClearAll()

end

function LoveCheckWindow:RemoveListeners()
  QiXiLoveManager.Instance.onUpdateCheck:RemoveListener(self.setDataFun)
  EventMgr.Instance:RemoveListener(event_name.role_asset_change,self.SetSetConcentricValueFun)
end

function LoveCheckWindow:AddListeners()
    QiXiLoveManager.Instance.onUpdateCheck:AddListener(self.setDataFun)
    EventMgr.Instance:AddListener(event_name.role_asset_change,self.SetSetConcentricValueFun)
end

function LoveCheckWindow:OnHide()
    self:RemoveListeners()
end

function LoveCheckWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.love_check))
    self.gameObject.name = "LoveCheckWindow"

    UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)

    local t = self.gameObject.transform

    self.transform = t



    -- t:Find("MainCon/CloseButton"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    t:Find("Panel"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    t:Find("MainCon/LeftCloseButton"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    t:Find("MainCon/RightCoselButton"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    self.scrollRectRtr = t:Find("MainCon/ScrollRect"):GetComponent(RectTransform)
    self.scrollRectRtr.anchoredPosition = Vector2(0,-45)
    self.scrollRectTT = t:Find("MainCon/ScrollRect"):GetComponent(ScrollRect)
    self.scrollRectTT.onValueChanged:AddListener(function(value)
        self:OnRectScroll(value)
    end)


    self.itemContainer = t:Find("MainCon/ScrollRect/ImageContainer")

  self.button = t:Find("MainCon/ConfirmButton"):GetComponent(Button)
    self.button.onClick:AddListener(function() self:ApplyButton() end)

    self.itemLayout = LuaBoxLayout.New(self.itemContainer.gameObject,{axis = BoxLayoutAxis.X, border = self.distance})


    self.numTemplate = t:Find("MainCon/NumTemplate")
    self.slider = t:Find("MainCon/Slider"):GetComponent(Slider)
    self.sliderText = t:Find("MainCon/Slider/Text"):GetComponent(Text)
    self.loveNameText = t:Find("MainCon/NameText"):GetComponent(Text)
    self.talkButton = t:Find("MainCon/TalkButton"):GetComponent(Button)
    self.talkButton.onClick:AddListener(function() self:ApplyTalkButton() end)
    self.backGround = t:Find("MainCon/Bg/BigBg/BackGround"):GetComponent(Image)
    self.backGround.sprite = self.assetWrapper:GetSprite(AssetConfig.love_check_bg,"QiXiLoveI18N")

    self.noticeButton = t:Find("MainCon/Notice"):GetComponent(Button)
    self.noticeButton.onClick:AddListener(function()
         TipsManager.Instance:ShowText({gameObject = self.noticeButton.gameObject, itemData ={
            TI18N("与一名异性好友前往领取同心锁后，组队完"),
            TI18N("成<color='#ffff00'>悬赏任务、上古妖魔</color>等(非挂野场景)组队任"),
            TI18N("务，即可增加同心锁的同心值哟~"),
            }})
    end)


    self:OnOpen()
end

function LoveCheckWindow:OnOpen()
    self:RemoveListeners()
    self:AddListeners()

    if self.openArgs ~= nil then
       self.rewardId = self.openArgs[1]
    end
    -- self:SetDataItem()
    -- self:SetBaseData()
    self:OnRectScroll({x = 0})
    self:SetData()
    -- if self.effTimerId == nil then
    --      self.effTimerId = LuaTimer.Add(990, 3000, function()
    --             self.button.gameObject.transform.localScale = Vector3(1.1,1.1,1)
    --             Tween.Instance:Scale(self.button.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
    --         end)
    -- end
end
function LoveCheckWindow:SetData()
    self:SetDataItem()
    self:SetBaseData()
    self:SetSetSetConcentricValue()
end
function LoveCheckWindow:SetBaseData()
  self.loveNameText.text = QiXiLoveManager.Instance.checkData.other_name
  if QiXiLoveManager.Instance.checkData.point >= 99 then
      if self.signRewardEffect == nil then
        self.signRewardEffect = BibleRewardPanel.ShowEffect(20053,self.button.transform,Vector3(1.9, 0.8, 1),Vector3(-52, -19, -400))
      end
      self.signRewardEffect:SetActive(true)
  else
      if self.signRewardEffect ~= nil then
          self.signRewardEffect:SetActive(false)
      end
  end
end
function LoveCheckWindow:SetDataItem()
    self.itemDataList = {}
    local data = QiXiLoveManager.Instance.checkData.reward
    for k,v in pairs(data) do
    -- if v.gift_id == self.rewardId and RoleManager.Instance.RoleData.lev >= v.min_lev and RoleManager.Instance.RoleData <= v.max_lev and ((RoleManager.Instance.RoleData.sex == v.sex) or (v.sex == 2)) and RoleManager.Instance.RoleData.lev_break_times >= v.min_lev_break and RoleManager.Instance.RoleData.lev_break_times <= v.max_lev_break then
        -- if v.gift_id == self.rewardId and ((RoleManager.Instance.RoleData.sex == v.sex) or (v.sex == 2)) then
        --     self.tagetIndex = k
        table.insert(self.itemDataList,v)
        -- end
    end


    local nownum = 0
    for i,v in pairs(self.itemDataList) do
        nownum = nownum + 1
        local id = v.id
        local num = v.num
        local itemtype = v.is_effet
        local nowData = DataItem.data_get[id]
        if self.itemList[nownum] ~= nil then
            self.itemList[nownum].gameObject:SetActive(true)
            self.itemList[nownum]:SetAll(nowData,self.extra)
            self.itemList[nownum]:SetNum(num)
        else
            local itemSlot = ItemSlot.New()
            itemSlot:SetAll(nowData,self.extra)
            itemSlot:SetNum(num)
            self.itemList[nownum] = itemSlot
            self.itemLayout:AddCell(itemSlot.gameObject)
        end


        if itemtype == true then
          if self.itemEffectList[nownum] == nil then
              self.itemEffectList[nownum] = BibleRewardPanel.ShowEffect(20223,self.itemList[nownum].transform, Vector3(1, 1, 1), Vector3(32,0, -400))
          else
            self.itemEffectList[nownum]:SetActive(true)
          end
        else
          if self.itemEffectList[nownum] ~= nil then
            self.itemEffectList[nownum]:SetActive(false)
          end
        end
    end
    local lenghtNum = #self.itemDataList

    if  self.scrollRectRtr ~= nil then
      if lenghtNum > 5 then
          lenghtNum = 5
          self.scrollRectRtr.transform:GetComponent(ScrollRect).movementType = 1
      else
          self.scrollRectRtr.transform:GetComponent(ScrollRect).movementType = 2
      end
      self.scrollRectRtr.sizeDelta = Vector2(lenghtNum * 64 + lenghtNum * self.distance,self.scrollRectRtr.sizeDelta.y)
    end

end


function LoveCheckWindow:ApplyButton()
    if QiXiLoveManager.Instance.checkData.point >= 99 then
        if BackpackManager.Instance:GetCurrentGirdNum() < 2 then
            NoticeManager.Instance:FloatTipsByString("背包空间不足，请整理后再尝试哟{face_1,3}")
            return
        end
        QiXiLoveManager.Instance:send17882()
        WindowManager.Instance:CloseWindow(self,false)
    else
        NoticeManager.Instance:FloatTipsByString("同心值到达99可解锁")
    end
end


function LoveCheckWindow:OnRectScroll(value)
  if #self.itemDataList > 5 then
    local Left = (value.x-1)*(self.scrollRectTT.content.sizeDelta.x - 345) + 172.5 - 62
    local Right = Left + 345 + 128
    for i,v in ipairs(self.itemList) do
      local ax = v.transform.anchoredPosition.x
      local sx = v.transform.sizeDelta.x

      if ax + sx > Right or ax < Left then
          v.gameObject:SetActive(false)
      else
          v.gameObject:SetActive(true)
      end
    end
   end
end

function LoveCheckWindow:SetSetSetConcentricValue()
  self.slider.value = QiXiLoveManager.Instance.checkData.point / 99
  self.sliderText.text = QiXiLoveManager.Instance.checkData.point .. "/99"
end

function LoveCheckWindow:ApplyTalkButton()
    local data = {id = QiXiLoveManager.Instance.checkData.rid,platform = QiXiLoveManager.Instance.checkData.platform,zone_id = QiXiLoveManager.Instance.checkData.zone_id,sex = QiXiLoveManager.Instance.checkData.other_sex,classes = QiXiLoveManager.Instance.checkData.other_classes,lev = QiXiLoveManager.Instance.checkData.lev,name = QiXiLoveManager.Instance.checkData.other_name}
    FriendManager.Instance:TalkToUnknowMan(data)
end