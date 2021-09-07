LoveActivePanel = LoveActivePanel or BaseClass(BasePanel)

function LoveActivePanel:__init(model,parent)
  self.model = model
  self.parent = parent
  self.resList = {
      {file = AssetConfig.love_active_panel,type = AssetType.Main}
      -- ,{file = AssetConfig.rechargepack_texture, type = AssetType.Dep}
      ,{file = AssetConfig.love_active_bg, type = AssetType.Main}
    }

   self.OnOpenEvent:AddListener(function()
      self:OnOpen()
    end)

    self.OnHideEvent:AddListener(function()
      self:OnHide()
    end)


   self.rewardSlot = nil
   self.extra = {inbag = false, nobutton = true}

   self.itemSlotList = {}
   self.effectList = {23675,22205,3274,23274,23275,23276}
   self.isGetReward = 0
   self.ItemList = {}
end

function LoveActivePanel:__delete()
   if self.itemSlotList ~= nil then
     for i,v in ipairs(self.itemSlotList) do
         v:DeleteMe()
     end
     self.itemSlotList = nil
   end
   if self.topItemLayout  ~= nil then
      self.topItemLayout:DeleteMe()
      self.topItemLayout  = nil
   end

  if self.gameObject ~= nil then
      GameObject.DestroyImmediate(self.gameObject)
      self.gameObject = nil
  end
  self:AssetClearAll()
end


function LoveActivePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.love_active_panel))
    self.gameObject.name = "LoveActivePanel"
    UIUtils.AddUIChild(self.parent,self.gameObject)


    self.transform = self.gameObject.transform


    self.bigBg = self.transform:Find("Bg/BackGroundBg")
    local bigObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.love_active_bg))
    UIUtils.AddBigbg(self.bigBg,bigObj)


    self.scrollRect = self.transform:Find("Bg/RectScroll"):GetComponent(ScrollRect)
    self.scrollRect.onValueChanged:AddListener(function(value)
        self:OnRectScroll(value)
    end)


    self.topItemContainer = self.transform:Find("Bg/RectScroll/Container")
    self.topItemLayout = LuaBoxLayout.New(self.topItemContainer.gameObject, {axis = BoxLayoutAxis.X, cspacing = 20,border = 7})



    self.countDownText = self.transform:Find("Bg/ButtonPanel/ActiveText"):GetComponent(Text)


    self.activeButton = self.transform:Find("Bg/ActiveButton"):GetComponent(Button)
    self.activeButton.gameObject:SetActive(true)
    self.activeButton.onClick:AddListener(function() self:ApplyPayButton() end)

    self.noticeButton = self.transform:Find("Bg/Notice"):GetComponent(Button)
    self.noticeButton.onClick:AddListener(function()
         TipsManager.Instance:ShowText({gameObject = self.noticeButton.gameObject, itemData ={
            TI18N("与一名异性好友前往领取同心锁后，组队完"),
            TI18N("成<color='#ffff00'>悬赏任务、上古妖魔</color>等(非挂野场景)组队任"),
            TI18N("务，即可增加同心锁的同心值哟~"),
            }})
    end)

    self:SetItemContainer()
    self:OnOpen()

end

function LoveActivePanel:OnHide()
end

function LoveActivePanel:OnOpen()
  self:OnRectScroll({x = 0})
  if self.campId ~= nil then
      self.countDownText.text = string.format("活动日期:%s月%s日-%s月%s日",DataCampaign.data_list[self.campId].cli_start_time[1][2],DataCampaign.data_list[self.campId].cli_start_time[1][3],DataCampaign.data_list[self.campId].cli_end_time[1][2],DataCampaign.data_list[self.campId].cli_end_time[1][3])
  end
  
end

function LoveActivePanel:RotationBg()
  self.rotationTweenId  = Tween.Instance:ValueChange(0,360,2, function() self.rotationTweenId = nil self:RotationBg(callback) end, LeanTweenType.Linear,function(value) self:RotationChange(value) end).id
end

function LoveActivePanel:RotationChange(value)
   self.localRotation = Vector3(0,0,value)
end

function LoveActivePanel:SetItemContainer()
  local data = DataCampaign.data_list[1187].reward

  for i,v in ipairs(data) do
    local id = v[1]
    local itemData = DataItem.data_get[id]
    local rechargePackSlot = RechargePackItem.New()
    rechargePackSlot.slot:SetAll(itemData,self.extra)
    rechargePackSlot.slot:SetNum(v[2])
    for i,v in ipairs(self.effectList) do
       if id == v then
           rechargePackSlot:ShowEffect(true,1)
       end
    end
    self.itemSlotList[i] = rechargePackSlot
    self.topItemLayout:AddCell(rechargePackSlot.slot.gameObject)
    self.ItemList[i] = rechargePackSlot
  end

end


function LoveActivePanel:ApplyPayButton()

    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Follow then
      NoticeManager.Instance:FloatTipsByString(TI18N("正在跟随队长，不能前往参与"))
    else
      NoticeManager.Instance:FloatTipsByString(TI18N("正在自动前往"))
    end

    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    SceneManager.Instance.sceneElementsModel:Self_PathToTarget("32020_1",false)
    -- CampaignManager.Instance.model.campWin:OnClose()
    WindowManager.Instance:CloseWindow(self.model.mainWin)
end

function LoveActivePanel:OnRectScroll(value)

end
