LoveWishTips = LoveWishTips or BaseClass(BasePanel)


function LoveWishTips:__init(parent)
    self.parent = parent
    self.name = "LoveWishTips"
    -- self.Effect = "prefabs/effect/20298.unity3d"
    self.resList = {
        {file = AssetConfig.love_wish_tips, type = AssetType.Main},
        {file = AssetConfig.valentine_textures, type = AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.effTimerId = nil
    self.effect = nil
    self.wishExt = nil
end


function LoveWishTips:OnInitCompleted()

end

function LoveWishTips:__delete()
    if self.wishExt ~= nil then
        self.wishExt:DeleteMe()
    end
    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end

    if self.floatTimerId ~= nil then
        LuaTimer.Delete(self.floatTimerId)
        self.floatTimerId = nil
    end
    
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    self.parent.tipsPanel = nil
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()

end

function LoveWishTips:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.love_wish_tips))
    self.gameObject:SetActive(false)
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.gameObject.name = "LoveWishTips"
    self.transform = self.gameObject.transform
    self.closeBtn = self.transform:Find("MainCon/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:DeleteMe() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.valentine_window) end)

    self.bg = self.transform:Find("MainCon/Bg")
    self.transform = self.gameObject.transform
    self.transform:SetAsFirstSibling()

    self.itemTagImg = self.transform:Find("MainCon/TopImg"):GetComponent(Image)
    self.itemConImg = self.transform:Find("MainCon/MiddleImg"):GetComponent(Image)
    self.itemText = self.transform:Find("MainCon/NoticeText"):GetComponent(Text)
    
    -- self.effect = BibleRewardPanel.ShowEffect(20401,self.itemTagImg.gameObject.transform, Vector3.one, Vector3(0, 0, -400))
    

   
    self:OnOpen()



end

-- 参数分别意义为：1.展示的物品列表，2.是否10哥物品两排显示，3.显示奖励的文字，4.设置奖励背景宽高，5.设置一行的最大个数
function LoveWishTips:OnOpen()
   
    if self.floatTimerId == nil then
        self.floatCounter = 0
        self.floatTimerId = LuaTimer.Add(0, 16, function() self:OnFloatItem() end)
    end
    self.wishExt = MsgItemExt.New(self.itemText,300, 19, 22)

    local text = nil

    self:SetActiveLot(false)
    if self.openArgs[1] == true then
        self.effect = BibleRewardPanel.ShowEffect(20401,self.itemTagImg.gameObject.transform, Vector3.one, Vector3(0, 0, -400))
        self.itemTagImg.sprite = self.assetWrapper:GetSprite(AssetConfig.valentine_textures, "i18nwish")
        self.itemConImg.sprite = self.assetWrapper:GetSprite(AssetConfig.valentine_textures, "wishicon")
        text = TI18N("恭喜你许愿成功静待有缘人看到吧！祝你愿望成真！")
        self.wishExt:SetData(text)
    else
        self.effect = BibleRewardPanel.ShowEffect(20402,self.itemTagImg.gameObject.transform, Vector3.one, Vector3(0, 0, -400))
        self.itemTagImg.sprite = self.assetWrapper:GetSprite(AssetConfig.valentine_textures, "i18nwishback")
        self.itemConImg.sprite = self.assetWrapper:GetSprite(AssetConfig.valentine_textures, "wishbackicon")
        text = TI18N("缘分天定，对方收到了你的礼物笑开了花！{face_1,3}")
        self.wishExt:SetData(text)
    end
    self.itemConImg:SetNativeSize()
    
    self.effTimerId = LuaTimer.Add(800, function()
           self:SetActiveLot(true)
           if self.effect ~= nil then
                self.effect:DeleteMe()
                self.effect = nil 
            end
    end)

end

function LoveWishTips:SetActiveLot(t)
    if t == false then
        self.itemConImg.gameObject:SetActive(false)
        self.itemText.gameObject:SetActive(false)
        self.bg.gameObject:SetActive(false)
    else
        self.itemConImg.gameObject:SetActive(true)
        self.itemText.gameObject:SetActive(true)
        self.bg.gameObject:SetActive(true)
    end


end


function LoveWishTips:OnFloatItem()
        self.floatCounter = self.floatCounter + 1
        local position = self.itemConImg.transform.localPosition
        self.itemConImg.transform.localPosition = Vector2(position.x, position.y + 0.5 * math.sin(self.floatCounter * math.pi / 90 * 1.5))
end
