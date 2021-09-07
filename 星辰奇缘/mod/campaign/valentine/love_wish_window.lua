LoveWishWindow = LoveWishWindow or BaseClass(BaseWindow)

function LoveWishWindow:__init(model)
    self.model = model
    self.name = "LoveWishWindow"

    self.windowId = WindowConfig.WinID.love_wish

    self.resList = {
        {file = AssetConfig.love_wish, type = AssetType.Main},
        {file = AssetConfig.valentine_textures, type = AssetType.Dep},
    }
    self.selectIndex = -1

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.onSelect = function(index) self:OnSelect(index) end

    self.loveWishReplyListener = function() self:ReplyWish() end

    self.selectName = ""
    self.tipsPanel = nil
    self.wishExt = nil
end

function LoveWishWindow:__delete()
    self.OnHideEvent:Fire()
    self.selectIndex = -1

    if self.wishExt ~= nil then
        self.wishExt:DeleteMe()
    end
    if self.columnList ~= nil then
        for _, column in pairs(self.columnList) do
            column:DeleteMe()
        end
        self.columnList = {}
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function LoveWishWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function LoveWishWindow:OnOpen()
    self:RemoveListeners()
    ValentineManager.Instance.loveWishReply:AddListener(self.loveWishReplyListener)
end

function LoveWishWindow:OnHide()
    self:RemoveListeners()
end

function LoveWishWindow:RemoveListeners()
    ValentineManager.Instance.loveWishReply:RemoveListener(self.loveWishReplyListener)
end

function LoveWishWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.love_wish))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self:InitInput()
    self:InitDesc()
    self:InitButton()
    self:InitGiftList()

    self:Refresh()
    self:OnOpen()
end

function LoveWishWindow:InitInput()
    self.inputField = self.transform:Find("Main/InputField"):GetComponent(InputField)
end

function LoveWishWindow:InitDesc()
    if self.wishExt == nil then
      self.wishExt = MsgItemExt.New(self.transform:Find("Main/Desc"):GetComponent(Text),384, 19, 22)

      local text = TI18N("<color='#0c52b0'>选择喜欢的礼物类型，并写下祝福语即可许愿哦</color>{face_1,7}")
      self.wishExt:SetData(text)
    end
end

function LoveWishWindow:InitButton()
    local wishButton = self.transform:Find("Main/Wish"):GetComponent(Button)
    wishButton.onClick:AddListener(function() self:OnWish() end)

    local closeButton = self.transform:Find("Main/Close"):GetComponent(Button)
    closeButton.onClick:AddListener(function() self:OnClose() end)
end

function LoveWishWindow:InitGiftList()
    local transform = self.transform:Find("Main/Container")
    self.columnList = {}
    local index
    for i = 1, 9 do
        for k,v in ipairs(DataWedding.data_whiteday) do
            if v.type == i then
                 index = k
                 break
            end
        end

        local column = LoveWishGiftList.New(transform:Find(string.format("Reward%s", i)).gameObject,i,index)
        column.onSelect:AddListener(self.onSelect)
        self.columnList[i] = column
    end
end

function LoveWishWindow:Refresh()
    for index, column in ipairs(self.columnList) do
        column:ShowSelectBg(index == self.selectIndex)
    end
end

function LoveWishWindow:OnSelect(index)
    local setName = false
    if self.selectIndex == index then
        self.selectIndex = -1
    else
        self.selectIndex = index
        local reward = {}
        for k,v in pairs(DataWedding.data_whiteday) do
              if v.type == index then
                  if setName == false then
                     self.selectName = v.title
                     setName = true
                  end
                  local length = #reward + 1
                  reward[length] = {}
                  reward[length].id = v.item_id
                  reward[length].num = v.num
              end
        end
        self.model:OpenPossibleReward(string.format(TI18N("选择了<color='#F5A104'>%s</color>作为愿望,被其他玩家还愿，\n将有几率获得以下道具中的一个"),self.selectName),reward,TI18N("<color='#ffff00'>写下愿望</color><color='#3CD585'>可以提高被实现的几率哦^_^</color>"))
    end
    self:Refresh()
end

function LoveWishWindow:OnWish()
    if self.selectIndex ~= -1 then
        local confirmData = NoticeConfirmData.New()
        confirmData.sureCallback = function()
            if self.inputField.text == "" then
                self.inputField.text = TI18N("我将自己美好的愿望写下希望遇到有缘人帮我实现哦{face_1,3}")
            end

            ValentineManager.Instance:send17829(self.inputField.text, self.selectIndex)
        end
        if self.inputField.text ~= "" then
                confirmData.content = string.format(TI18N("您当前选择了<color='#FFFF00'>%s</color>礼物，是否确认许下愿望？"),self.selectName)
        else
                confirmData.content = string.format(TI18N("您当前选择了<color='#FFFF00'>%s</color>礼物，但未留下祝福语是否确认许下愿望？（<color='#00ff00'>留下你想说的话，愿望更容易被实现哦</color>{face_1,7}"),self.selectName)
        end

        NoticeManager.Instance:ConfirmTips(confirmData)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择愿望"))
    end
end

function LoveWishWindow:OnClose()
    self.model:CloseWish()
end

function LoveWishWindow:ReplyWish()
    if self.tipsPanel == nil then
        self.tipsPanel = LoveWishTips.New(self)
    end

    self.tipsPanel:Show({true})
end