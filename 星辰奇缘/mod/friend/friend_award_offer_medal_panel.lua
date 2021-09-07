-- 作者:jia
-- 5/11/2017 8:19:23 PM
-- 功能:悬赏任颁发奖章界面

FriendAwardOfferMedalPanel = FriendAwardOfferMedalPanel or BaseClass(BasePanel)
function FriendAwardOfferMedalPanel:__init(model)
    self.model = model
    self.resList = {
        { file = AssetConfig.friendawardoffermedalpanel, type = AssetType.Main }
        ,{ file = AssetConfig.arena_textures, type = AssetType.Dep }
    }
    self.OnOpenEvent:Add( function() self:OnOpen() end)
    -- self.OnHideEvent:Add(function() self:OnHide() end)
    self.DescList = { TI18N("感谢队长的辛劳付出，小小奖章不成敬意^_^"), TI18N("队长棒棒的，带队不辞辛劳又体贴^_^"), TI18N("队长人真好，以后一起组队傲游星辰吧^_^") }
    self.ItemId = 0
    self.ItemData = nil
    self.capData = nil
    self.hasInit = false
end

function FriendAwardOfferMedalPanel:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function FriendAwardOfferMedalPanel:OnHide()

end

function FriendAwardOfferMedalPanel:OnOpen()
    self.ItemId = self.openArgs[1]
    if self.ItemId == nil or self.ItemId <= 0 then
        return
    end
    local index = math.random(3);
    self:OnBtnClick(index)
    self.ItemData = BackpackManager.Instance:GetItemById(self.ItemId)
    if  self.ItemData ~= nil then
        self:UpdateCaptain()
    end
end

function FriendAwardOfferMedalPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.friendawardoffermedalpanel))
    self.gameObject.name = "FriendAwardOfferMedalPanel"
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)

    self.transform = self.gameObject.transform

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(
    function()
        self.model:CloseAwardPanel()
    end )
    self.transform:Find("MainCon/CloseButton"):GetComponent(Button).onClick:AddListener(
    function()
        self.model:CloseAwardPanel()
    end )
    self.TxtToCap = self.transform:Find("MainCon/TopCon/TxtToCap"):GetComponent(Text)

    self.btnList = { }
    for index = 1, 3 do
        local btn = self.transform:Find("MainCon/TopCon/Btn" .. index):GetComponent(Button)
        btn.onClick:AddListener(
        function()
            self:OnBtnClick(index)
        end )
        table.insert(self.btnList, btn)
    end

    self.TxtDesc = self.transform:Find("MainCon/TopCon/InputField"):GetComponent(InputField)

    self.TglBtnAdd = self.transform:Find("MainCon/BottomCon/TglAdd"):GetComponent(Toggle)
    self.BtnApply = self.transform:Find("MainCon/BottomCon/BtnApply"):GetComponent(Button)
    self.BtnApply.onClick:AddListener(
    function()
        self:AwardMedal()
    end )
    self:OnOpen()
end

function FriendAwardOfferMedalPanel:OnBtnClick(index)
    for key, btn in ipairs(self.btnList) do
        if index == key then
            btn.transform:Find("ImgSelected").gameObject:SetActive(true)
        else
            btn.transform:Find("ImgSelected").gameObject:SetActive(false)
        end
    end
    self.TxtDesc.text = self.DescList[index]
end

function FriendAwardOfferMedalPanel:AwardMedal()
    local descStr = self.TxtDesc.text;
    if BaseUtils.is_null(descStr) or descStr == "" then
        NoticeManager.Instance:FloatTipsByString(TI18N("请输入感谢语"))
        return
    end
    if string.utf8len(descStr) > 26 then
        NoticeManager.Instance:FloatTipsByString(TI18N("感谢语最多25个字"))
        return
    end
    if self.TglBtnAdd.isOn then
        FriendManager.Instance:Require11804(self.roleid, self.platform, self.zoneid)
    end
    local msg = self.TxtDesc.text
    FriendManager.Instance:Send11890(self.ItemId,msg)
    self.model:CloseAwardPanel()
end

function FriendAwardOfferMedalPanel:UpdateCaptain()
    if self.ItemData == nil then
        return
    end
    self.roleid = 0;
    self.platform = "";
    self.zoneid = 0;
    local capname = "";
    for k,v in pairs(self.ItemData.extra) do
        if v.name == BackpackEumn.ExtraName.quest_offer_role_id then
            self.roleid = v.value
        elseif v.name == BackpackEumn.ExtraName.quest_offer_platform then
           self.platform = v.str
        elseif v.name == BackpackEumn.ExtraName.quest_offer_zone_id then
           self.zoneid = v.value
        elseif v.name == BackpackEumn.ExtraName.quest_offer_role_name then
            capname = v.str
        end
    end
    self.TxtToCap.text = string.format(TI18N("<color='#31f2f9'>%s</color>带你悬赏，颁发%s感谢Ta吧！"),capname,ColorHelper.color_item_name(self.ItemData.quality,self.ItemData.name))
    local capUid = BaseUtils.Key(self.roleid, self.platform, self.zoneid);
    if FriendManager.Instance.friend_List[capUid] == nil then
        self.TglBtnAdd.gameObject:SetActive(true)
        self.TglBtnAdd.isOn = true
        self.BtnApply.transform.localPosition = Vector2(100, 27.3)
    else
        self.TglBtnAdd.gameObject:SetActive(false)
        self.TglBtnAdd.isOn = false
        self.BtnApply.transform.localPosition = Vector2(0, 27.3)
    end
end