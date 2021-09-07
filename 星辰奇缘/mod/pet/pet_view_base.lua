-- ----------------------------------------------------------
-- UI - 宠物窗口 信息面板
-- ----------------------------------------------------------
PetView_Base = PetView_Base or BaseClass(BasePanel)

function PetView_Base:__init(parent)
	self.parent = parent
    self.model = parent.model
    self.name = "PetView_Base"
    self.resList = {
        {file = AssetConfig.pet_window_base, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
        , {file = AssetConfig.headride, type = AssetType.Dep}
        ,{file = AssetConfig.petevaluation_texture,type = AssetType.Dep}
        ,{file = AssetConfig.petrunepanel_bg , type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil
    self.init = false

    ------------------------------------------------
    self.view_index = 1
    self.feed_itemlist = {}
    self.skillList = {}
    self.stoneList = {}
    self.stoneIconList = {}
    self.tabGroupObj = nil
    self.tabGroup = nil
    self.tempCurrTab =0  --jichushuxing  zizhishuxing

    self.slider1_tweenId = 0
    self.slider2_tweenId = 0
    self.slider3_tweenId = 0
    self.slider4_tweenId = 0
    self.slider5_tweenId = 0

    self.happyTips = {TI18N("1、宠物寿命没有上限，每场战斗消耗<color='#ffff00'>1点</color>")
                    , TI18N("2、宠物战斗死亡后将消耗<color='#ffff00'>50点</color>寿命")
                    , TI18N("3、神兽和珍兽拥有<color='#00ff00'>永生</color>效果")
                    , TI18N("4、宠物寿命低于<color='#ffff00'>50点</color>将无法参战")
                    , TI18N("5、喂养宠物<color='#ffff00'>长生果</color>可以增加宠物寿命值")}

    self.skillTips = {TI18N("1、宠物技能数不足<color='#ffff00'>4个</color>时，战斗和升级有几率领悟技能")
                , TI18N("2、打书可为宠物<color='#ffff00'>增加</color>技能，也有几率<color='#ffff00'>覆盖</color>当前已有技能")
                , TI18N("3、当前技能（符石技能除外）达到<color='#ffff00'>天生可拥有技能数量</color>时，打书不再增加技能数量")
                , TI18N("4、使用<color='#ffff00'>天赋异禀</color>可以随机习得一个<color='#ffff00'>天生技能</color>(已拥有的天生技能除外)，其中特殊技能概率较大")
                , TI18N("5、突破技能<color='#ffff00'>不会</color>被学习技能/洗髓<color='#00ff00'>替换掉</color>，会一直存在") }

    self.attriconList = {
        [1] = 20062,
        [2] = 20063,
        [3] = 20064,
        [4] = 20065,
        [5] = 20066,
        [6] = 20061,
        [7] = 29102,
    }
    self.recommendSkillButton = nil

    self.clickQualityPanel = false

    self.showArtificeButton = nil

    self.skinButton = nil
    self.spirtButton = nil

    self.imgLoader = {}
    ------------------------------------------------
    self._update_one = function(update) self:update_one(update) end
    self._gem_off = function(id) self:gem_off(id) end
    self._gem_replace = function(id) self:gem_replace(id) end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.onClickStoneShowWashPanelFun = function (slotItemData)
        self:onClickStoneShowWashPanel(slotItemData)
    end

    self.listener = function() self:updata_info() end
    self.checkGuidePoint = function() self:CheckGuidePoint() end

    self.guideBattleBtn = nil
    self.guideLearnBtn = nil

    -- effectMultiplex:为特效是否可能存在复用,当符石和护符特效一致,符石指引后特效可以直接给护符指引复用
    -- requireMent:激活的额外判断条件
    -- index优先级
    self.guideList ={
        [1] = {id = 41530,index = 2,notice = "给宠物镶嵌符石能增加宠物属性哦",effectId = 20103,effectScale = {0.9,0.9,1},effectPosition = {0,0,-400},effectMultiplex = true,step = 1,forward = TipsEumn.Forward.Left,gameObject = nil,requireMent = nil},
        [2] = {id = 41540,index = 1,notice = "给宠物镶嵌护符还能增加宠物技能哦",effectId = 20103,effectScale = {0.9,0.9,1},effectPosition = {0,0,-400},effectMultiplex = true,step = 1,forward = TipsEumn.Forward.Left,gameObject = nil,requireMent = nil},
        [3] = {id = 41800,index = 3,notice = "点击分配宠物属性点",effectId = 20104,effectScale = {0.9,0.9,1},effectPosition = {0,0,-400},effectMultiplex = true,step = 1,forward = TipsEumn.Forward.Left,gameObject = nil,requireMent = nil}
    }
    if self.model.cur_petdata ~= nil then
        self.guideList[3].requireMent = function()
            self.distribute = self.model.cur_petdata.point
            if self.model.cur_petdata ~= nil and self.distribute > 0 then
                return true
            else
                return false
            end
        end
    end

    self.effectList = {}
    self.guideListInit = false
end

function PetView_Base:InitPanel()

	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pet_window_base))
    self.gameObject.name = "PetView_Base"
    self.gameObject.transform:SetParent(self.parent.mainTransform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform
    -- self.transform:SetAsFirstSibling()
    self.transform:SetSiblingIndex(3)

    local transform = self.transform
    self.tabGroupObj = transform:FindChild("TabButtonGroup").gameObject

    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end, {perWidth = 90, perHeight = 35})
    --TabGroupself.tabGroup:Select(index)
    self.panel1 = transform:FindChild("BaseInformationPanel/Panel1").gameObject     --按钮一 基础属性按钮对应的面板
    self.panel2 = transform:FindChild("BaseInformationPanel/Panel2").gameObject     --按钮二 资质技能按钮对应的面板

    self.panel1.transform:FindChild("AttrPanel/AttrObject1/ValueText"):GetComponent(Text).color = Color(232/255, 250/255, 255/255)
    self.panel1.transform:FindChild("AttrPanel/AttrObject2/ValueText"):GetComponent(Text).color = Color(232/255, 250/255, 255/255)
    self.panel1.transform:FindChild("AttrPanel/AttrObject3/ValueText"):GetComponent(Text).color = Color(232/255, 250/255, 255/255)
    self.panel1.transform:FindChild("AttrPanel/AttrObject4/ValueText"):GetComponent(Text).color = Color(232/255, 250/255, 255/255)
    self.panel1.transform:FindChild("AttrPanel/AttrObject5/ValueText"):GetComponent(Text).color = Color(232/255, 250/255, 255/255)
    self.panel1.transform:FindChild("AttrPanel/AttrObject6/ValueText"):GetComponent(Text).color = Color(232/255, 250/255, 255/255)
    self.panel2.transform:FindChild("QualityPanel/ValueSlider1/Text"):GetComponent(Text).color = Color(232/255, 250/255, 255/255)
    self.panel2.transform:FindChild("QualityPanel/ValueSlider2/Text"):GetComponent(Text).color = Color(232/255, 250/255, 255/255)
    self.panel2.transform:FindChild("QualityPanel/ValueSlider3/Text"):GetComponent(Text).color = Color(232/255, 250/255, 255/255)
    self.panel2.transform:FindChild("QualityPanel/ValueSlider4/Text"):GetComponent(Text).color = Color(232/255, 250/255, 255/255)
    self.panel2.transform:FindChild("QualityPanel/ValueSlider5/Text"):GetComponent(Text).color = Color(232/255, 250/255, 255/255)

    --这写的真的蠢
    self.skinButton = transform:FindChild("TabButtonGroup/SkinButton"):GetComponent(Button)    --按钮三 皮肤按钮  对应PetSkinWindow新面板
    self.skinButtonRedPoint = self.skinButton.transform:FindChild("RedPoint").gameObject

    self.spirtButton = transform:FindChild("TabButtonGroup/SpiritButton"):GetComponent(Button)
    self.spirtButtonRedPoint = self.spirtButton.transform:FindChild("RedPoint").gameObject


    -- 按钮功能绑定
    local btn
    btn = transform:FindChild("OtherThing/ToBattleButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:tobattle() end)
    self.toBattleButton = btn
    self.guideBattleBtn = btn

    btn = transform:FindChild("OtherThing/SpiritOffButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnSpirtOffButtonClick() end)
    self.spirtOffButton = btn

    self.releaseButton = transform:FindChild("OtherThing/ReleaseButton").gameObject
    self.releaseButton:GetComponent(Button).onClick:AddListener(function() self:releasebuttonclick() end)

    btn = transform:FindChild("OtherThing/ReleaseButtonPanel/ReleaseButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:releasebuttonclick() end)

    btn = transform:FindChild("OtherThing/FeedButtom"):GetComponent(Button)
    btn.onClick:AddListener(function() self:openfeed_quality() end)

    self.recommendSkillButton = transform:FindChild("BaseInformationPanel/Panel2/SkillPanel/SoltPanel/Container/RecommendSkillButtom"):GetComponent(Button)
    self.recommendSkillButton.onClick:AddListener(function() self:openfeed_recommendskill() end)
    self.recommendSkillButton.gameObject:SetActive(false)

    ------------------  宠物改名  ---------------------
    btn = transform:FindChild("ModelPanel/NameEditButtom"):GetComponent(Button)
    btn.onClick:AddListener(function() self:opennameeditwindow() end)

    btn = transform:FindChild("OtherThing/EditNamePanel"):GetComponent(Button)
    btn.onClick:AddListener(function() self:hideeditnamepanel() end)

    btn = transform:FindChild("OtherThing/EditNamePanel/Main/OkButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:nameedit() end)

    ------------------  宠物放生  ---------------------
    btn = transform:FindChild("OtherThing/ReleasePanel"):GetComponent(Button)
    btn.onClick:AddListener(function() self:hidereleasepanel() end)

    btn = transform:FindChild("OtherThing/ReleasePanel/Main/CancelButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:hidereleasepanel() end)

    btn = transform:FindChild("OtherThing/ReleasePanel/Main/OkButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:releasepet() end)

    ------------------  宠物炼化  ---------------------
    self.showReleaseButton = transform:FindChild("OtherThing/ArtificeButton/ShowReleaseButton").gameObject
    self.showReleaseButton:GetComponent(Button).onClick:AddListener(function() self:showReleaseButtonpanel() end)
    self.showReleaseButton:SetActive(false)

    self.releaseButtonPanel = transform:FindChild("OtherThing/ReleaseButtonPanel").gameObject
    self.releaseButtonPanel:GetComponent(Button).onClick:AddListener(function() self:hideReleaseButtonpanel() end)

    self.artificeButton = transform:FindChild("OtherThing/ArtificeButton").gameObject
    self.artificeButton:GetComponent(Button).onClick:AddListener(function() self:OpenArtifice() end)

    ------------------  宠物锁定  ---------------------
    btn = transform:FindChild("ModelPanel/LockBtn"):GetComponent(Button)
    btn.onClick:AddListener(function() self:lockpetbuttonclick() end)

    btn = transform:FindChild("OtherThing/LockPanel"):GetComponent(Button)
    btn.onClick:AddListener(function() self:hidelockpetpanel() end)

    btn = transform:FindChild("OtherThing/LockPanel/Main/OkButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:lockpet() end)

    btn = transform:FindChild("OtherThing/LockPanel/Main/CancelButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:hidelockpetpanel() end)
    ------------------------------------------------------

    ------------------  宠物锁定  ---------------------
    btn = transform:FindChild("ModelPanel/HandBookButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:onHandBookButtonClick() end)
    btn.gameObject:SetActive(true)

    self.handBookPanel = transform:FindChild("OtherThing/HandBookPanel").gameObject
    self.handBookPanel:GetComponent(Button).onClick:AddListener(function() self:hideHandBookPanel() end)
    self.handBookPanel.transform:Find("Main/MoreButton"):GetComponent(Button).onClick:AddListener(function()
        self.handBookPanel.transform:Find("MorePanel").gameObject:SetActive(not self.handBookPanel.transform:Find("MorePanel").gameObject.activeSelf)
    end)
    self.handBookPanel.transform:Find("MorePanel/MoreButton"):GetComponent(Button).onClick:AddListener(function()
        self.handBookPanel:SetActive(false)
        self:openfeed_happy()
    end)
    local MorePanel = self.handBookPanel.transform:Find("MorePanel")
    self.moreAttrText = {}
    for i=1,7 do
        self.moreAttrText[i] = MorePanel:GetChild(i-1):GetComponent(Text)

        if self.imgLoader[i] == nil then
            local go = MorePanel:GetChild(i-1):Find("icon").gameObject
            self.imgLoader[i] = SingleIconLoader.New(go)
        end
        self.imgLoader[i]:SetSprite(SingleIconType.Item, DataItem.data_get[self.attriconList[i]].icon)
    end
    ------------------------------------------------------

    btn = self.panel1.transform:FindChild("InfoPanel/ExpGroup/Button"):GetComponent(Button)
    btn.onClick:AddListener(function() self:openfeed_happy() end)

    btn = self.panel1.transform:FindChild("InfoPanel/HappyGroup/Button"):GetComponent(Button)
    btn.onClick:AddListener(function() self:openfeed_happy() end)

    btn = self.panel1.transform:FindChild("InfoPanel/HappyGroup/NameText").gameObject:AddComponent(Button)
    btn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.panel1.transform:FindChild("InfoPanel/HappyGroup/NameText").gameObject, itemData = self.happyTips}) end)

    btn = self.panel1.transform:FindChild("InfoPanel/HappyGroup/HappyText").gameObject:AddComponent(Button)
    btn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.panel1.transform:FindChild("InfoPanel/HappyGroup/HappyText").gameObject, itemData = self.happyTips}) end)

    self.Equipbtn = self.panel1.transform:FindChild("EquipPanel/Button").gameObject
    self.Equipbtn:GetComponent(Button).onClick:AddListener(function() self:onupgradeclick() end)
    -- local fun = function(effectView)
    --     local effectObject = effectView.gameObject
    --     self.effect20118 = effectObject
    --     effectObject.transform:SetParent(self.Equipbtn.transform)
    --     effectObject.transform.localScale = Vector3(1, 0.85, 1)
    --     effectObject.transform.localPosition = Vector3(-50, 24, -10)
    --     effectObject.transform.localRotation = Quaternion.identity

    --     Utils.ChangeLayersRecursively(effectObject.transform, "UI")
    --     effectObject:SetActive(false)
    -- end
    -- BaseEffectView.New({effectId = 20118 , time = nil, callback = fun })



    btn = self.panel1.transform:FindChild("AttrPanel/PotentialButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:openaddpotentialwindow() end)

    btn = transform:FindChild("ModelPanel/TalkButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:opentalksetpanel() end)

    self.rideBtn = transform:Find("ModelPanel/RideButton").gameObject
    self.rideImg = self.rideBtn.transform:Find("Image"):GetComponent(Image)
    self.rideImgRect = self.rideImg.gameObject:GetComponent(RectTransform)
    self.rideBtn:SetActive(false)
    self.rideBtn:GetComponent("Button").onClick:AddListener(function() self:OpenRide() end)

    btn = self.panel2.transform:FindChild("SkillPanel/LearnSkillButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:openlearnskillwindow() end)
    self.guideLearnBtn = btn

    btn = self.panel2.transform:FindChild("SkillPanel/DescButton"):GetComponent(Button)
    btn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.panel2.transform:FindChild("SkillPanel/DescButton").gameObject, itemData = self.skillTips}) end)

    btn = self.panel2.transform:FindChild("QualityPanel"):GetComponent(Button)
    btn.onClick:AddListener(function() self:onQualityPanelClick() end)

    btn = self.panel2.transform:FindChild("QualityPanel/Growthbg"):GetComponent(Button)
    btn.onClick:AddListener(function() self:showgiftimagetips() end)

    btn = self.panel2.transform:FindChild("QualityPanel/GrowthImage"):GetComponent(Button)
    btn.onClick:AddListener(function() self:showgiftimagetips() end)

    btn = self.panel2.transform:FindChild("QualityPanel/GrowthText"):GetComponent(Button)
    btn.onClick:AddListener(function() self:showgiftimagetips() end)

    btn = transform:FindChild("OtherThing/GiftTips"):GetComponent(Button)
    btn.onClick:AddListener(function() self:hidegiftimagetips() end)

    btn = transform:FindChild("ModelPanel/Preview").gameObject:AddComponent(Button)
    btn.onClick:AddListener(function() self.parent:PlayAction() end)

    -- 初始化宝石图标
    local stonePanel = self.panel1.transform:FindChild("EquipPanel/panel").gameObject
    for i=1, 4 do
        local slot = ItemSlot.New()
        table.insert(self.stoneIconList, slot)
        slot.gameObject.name = "item_slot"
        local stone = stonePanel.transform:FindChild("gem"..i).gameObject
        stone.name = tostring(i)
        UIUtils.AddUIChild(stone, slot.gameObject)
        stone:SetActive(false)
        table.insert(self.stoneList, stone)
        stone:GetComponent(Button).onClick:AddListener(function() self:onstoneclick(stone) end)
    end

    -- 初始化技能图标
    local soltPanel = self.panel2.transform:FindChild("SkillPanel/SoltPanel/Container").gameObject
    for i=1, 15 do
        local slot = SkillSlot.New()
        UIUtils.AddUIChild(soltPanel.transform:FindChild("Solt"..i).gameObject, slot.gameObject)
        table.insert(self.skillList, slot)
    end


    self.evaluationbtn = self.transform:Find("ModelPanel/EvaluationButton").gameObject:GetComponent(Button)
    self.evaluationbtn.onClick:AddListener(function()
         WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petevaluation,{self.model.cur_petdata.base,1})
     end
    )

    self:InitGuideGameObject()
    --------------------------------------------
    self.init = true
    self:OnShow()
    self:ClearMainAsset()
end

function PetView_Base:InitGuideGameObject()
    self.guideListInit = true
    self.guideList[1].gameObject = self.stoneList[2].gameObject
    self.guideList[2].gameObject = self.stoneList[1].gameObject
    self.guideList[3].gameObject = self.panel1.transform:FindChild("AttrPanel/PotentialButton").gameObject
end

function PetView_Base:__delete()
    for k,v in pairs(self.effectList) do
        if v ~= nil then
            v:DeleteMe()
        end
    end

    for k,v in pairs(self.stoneIconList) do
        v:DeleteMe()
        v = nil
    end

    self:OnHide()

    for i,v in ipairs(self.imgLoader) do
        if v ~= nil then
            v:DeleteMe()
            v = nil
        end
    end

    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end

    for _, data in ipairs(self.skillList) do
        data:DeleteMe()
        data = nil
    end
    self.skillList = {}

    self.model:ClosePetRunePanel()

    self.rideImg.sprite = nil

    if self.gameObject ~= nil then
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function PetView_Base:OnInitCompleted()
    GuideManager.Instance:OpenWindow(self.parent.windowId)
end
--信息面板上方的changeTable
function PetView_Base:OnShow()
    self:RemoveListener()
    self:AddListener()
    if self.parent.openArgs ~= nil and #self.parent.openArgs > 1 then
        self.tabGroup:ChangeTab(self.parent.openArgs[2])
        self.parent.openArgs[2] =nil
    end
    self:update()

    if self.model.cur_petdata ~= nil and petEgg then
        GuideManager.Instance:OpenWindow(self.parent.windowId)
        self:CheckGuidePoint()
    end
end

function PetView_Base:OnHide()
    self:RemoveListener()
end

function PetView_Base:AddListener()
    PetManager.Instance.OnPetUpdate:Add(self._update_one)
    EventMgr.Instance:AddListener(event_name.quest_update,self.checkGuidePoint)
    EventMgr.Instance:AddListener(event_name.petgemoff, self._gem_off)
    EventMgr.Instance:AddListener(event_name.petgemreplace, self._gem_replace)
    RideManager.Instance.OnContractUpdate:Add(self.listener)
end

function PetView_Base:RemoveListener()
    PetManager.Instance.OnPetUpdate:Remove(self._update_one)
    EventMgr.Instance:RemoveListener(event_name.quest_update,self.checkGuidePoint)
    EventMgr.Instance:RemoveListener(event_name.petgemoff, self._gem_off)
    EventMgr.Instance:RemoveListener(event_name.petgemreplace, self._gem_replace)
    RideManager.Instance.OnContractUpdate:Remove(self.listener)
end

function PetView_Base:ChangeTab(index)        --上部按钮切换
    if self.view_index == index then return end
    self.view_index = index

    if self.view_index == 1 then
        --关闭内丹界面
        self.transform:Find("ModelPanel").gameObject:SetActive(true)
        self.transform:Find("BaseInformationPanel").gameObject:SetActive(true)
        self.transform:Find("OtherThing").gameObject:SetActive(true)
        if self.model.petRunePanel ~= nil then
            self.model.petRunePanel:Hiden()
        end
        
        self.panel1:SetActive(true)
        self.panel2:SetActive(false)
        if self.model.cur_petdata == nil then return end
        self:update_baseattrs()
        self:updata_base()
        self:updata_info()
        self:updata_stone()
        self:updata_upgradebtn()
    elseif self.view_index == 2 then 
        --关闭内丹界面
        self.transform:Find("ModelPanel").gameObject:SetActive(true)
        self.transform:Find("BaseInformationPanel").gameObject:SetActive(true)
        self.transform:Find("OtherThing").gameObject:SetActive(true)
        if self.model.petRunePanel ~= nil then
            self.model.petRunePanel:Hiden()
        end

        self.panel1:SetActive(false)
        self.panel2:SetActive(true)
        if self.model.cur_petdata == nil then return end
        self:update_qualityattrs()
        self:update_skill()
    elseif self.view_index == 3 then 
        self.transform:Find("ModelPanel").gameObject:SetActive(false)
        self.transform:Find("BaseInformationPanel").gameObject:SetActive(false)
        self.transform:Find("OtherThing").gameObject:SetActive(false)
        --打开内丹界面
        self.model:OpenPetRunePanel(self.assetWrapper, self.transform:Find("PetRunePanel").gameObject)
    elseif self.view_index == 4 then 
        if self.model.petRunePanel ~= nil then
            self.model.petRunePanel:Hiden()
        end
        self.model:OpenPetSkinWindow()
    elseif self.view_index == 5 then 
        if self.model.petRunePanel ~= nil then
            self.model.petRunePanel:Hiden()
        end
        self.model:OpenPetSpirtWindow()
    end
end

function PetView_Base:update()
    if BaseUtils.isnull(self.gameObject) then
        return
    end

    self.model:CheckTabOpen(self.tabGroup)
    self.tabGroup:Layout()

    if self.model.cur_petdata == nil then
        return
    end

    --只能这样写了，太坑了
    if self.model.petRunePanel ~= nil and not BaseUtils.isnull(self.model.petRunePanel.gameObject) and
        self.model.petRunePanel.gameObject.activeSelf then 
        self.model.petRunePanel:Update()
    end

    local curr_petData = self.model.cur_petdata
    if curr_petData.genre ~= 6 then
        self:NormalPetSetting()
        self:ChangeTab(self.view_index)
        self.tabGroup:ChangeTab(self.view_index)
    elseif curr_petData.genre == 6 then
        self:ChangeTab(1)
        self.tabGroup:ChangeTab(1)
    end

    self:update_model()
    self:updata_base()
    if self.view_index == 1 then
        self:update_baseattrs()
        self:updata_info()
        self:updata_stone() 
        self:updata_upgradebtn()
    else
        self:update_qualityattrs()
        self:update_skill()
    end
    self:hideeditnamepanel()
    self:hidereleasepanel()
    self:hidelockpetpanel()
    self:hideReleaseButtonpanel()
    self:hideHandBookPanel()

    if RoleManager.Instance.RoleData.lev < 30 then
        self.artificeButton:SetActive(false)
        self.releaseButton:SetActive(false)
    else
        self.artificeButton:SetActive(self.model.cur_petdata.lev >= 50)
        self.releaseButton:SetActive(self.model.cur_petdata.lev < 50)
    end

    if self.model.headbarTabIndex == 1 and RoleManager.Instance.RoleData.lev >= 75 then   --如果在面板一且角色等级大于75级展示附灵按钮
        self:UpdateSpirtButtonEffect()
    end

    if curr_petData.genre == 6 then   --小浣熊
        self:GodPetSetting()
    end

end


function PetView_Base:GodPetSetting()
    self.transform:FindChild("ModelPanel/LockBtn").gameObject:SetActive(false) --锁定按钮
    self.rideBtn:SetActive(false)                                              --不知名按钮
    self.transform:FindChild("ModelPanel/TalkButton").gameObject:SetActive(false) --talk按钮
    self.transform:FindChild("ModelPanel/HandBookButton").gameObject:SetActive(false) --资料按钮
    self.transform:Find("ModelPanel/EvaluationButton").gameObject:SetActive(false) --评价按钮

    self.panel1.transform:FindChild("EquipPanel/panel").gameObject:SetActive(false)   --宝石图标
    self.panel1.transform:FindChild("EquipPanel/Image/NameText"):GetComponent(Text).text = TI18N("活动说明")
    local equipText = self.panel1.transform:FindChild("EquipPanel/Text1").gameObject   --显示文字提示信息
    equipText:GetComponent(Text).text = string.format(TI18N("1.鸿福兔纸可携带出战升至<color='#ffff00'>30级</color>\n2.进化后在指定时间开启赢取大奖"))
    equipText:GetComponent(Text).lineSpacing = 1.3
    equipText:GetComponent(Text).color = Color(12/255, 82/255, 176/255)
    equipText:GetComponent(RectTransform).localPosition =Vector3(14, 44.5, 0)
    equipText:SetActive(true)

    self.panel1.transform:FindChild("EquipPanel/Text").gameObject:SetActive(false)
    self.panel1.transform:FindChild("EquipPanel/Button").gameObject:SetActive(true)    ---按钮显示
    self.panel1.transform:FindChild("EquipPanel/Button/Image").gameObject:SetActive(false)
    self.panel1.transform:FindChild("EquipPanel/Button/Text"):GetComponent(RectTransform).offsetMin = Vector2.zero
    self.panel1.transform:FindChild("EquipPanel/Button/Text"):GetComponent(Text).text = TI18N("30级可进化")

    self:updata_upgradebtn()
    self.panel1.transform:FindChild("AttrPanel/PotentialButton").gameObject:SetActive(false)   --加点按钮
    self.artificeButton:SetActive(false)   --炼化 按钮
    self.releaseButton:SetActive(false)    --放生按钮

    self.panel1.transform:FindChild("InfoPanel/ExpGroup/Button").gameObject:SetActive(false)
    self.panel1.transform:FindChild("InfoPanel/HappyGroup/Button").gameObject:SetActive(false)

    self.transform:FindChild("ModelPanel/Image2").gameObject:SetActive(false)
    self.transform:FindChild("ModelPanel/I18N_Text").gameObject:SetActive(false)
    self.transform:FindChild("ModelPanel/GifeText").gameObject:SetActive(false)
    self.toBattleButton:GetComponent(RectTransform).localPosition =Vector3(119,-205,0)   --出战按钮

    self.transform:FindChild("OtherThing/FeedButtom").gameObject:SetActive(false)   --培养按钮

    if self.model.cur_petdata ~= nil  then
        if self.model.cur_petdata.lev < 30 and self.model.cur_petdata.status == 0 then
            if self.toBattleButtonEffect == nil then
                local fun = function(effectView)
                    local effectObject = effectView.gameObject

                    effectObject.transform:SetParent(self.toBattleButton.transform)
                    effectObject.transform.localScale = Vector3(1, 0.8, 0.6)
                    effectObject.transform.localPosition = Vector3(-50, 24, -400)
                    effectObject.transform.localRotation = Quaternion.identity

                    Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                end
                self.toBattleButtonEffect = BaseEffectView.New({effectId = 20118, time = nil, callback = fun})
            else
                self.toBattleButtonEffect:SetActive(true)
            end
        else
            if self.toBattleButtonEffect ~= nil then
                self.toBattleButtonEffect:SetActive(false)
            end
        end
    end

    -- if PlayerPrefs.GetInt("GodEvolvePethasBattle") == 0 then
    --     if self.toBattleButtonEffect == nil then
    --         local fun = function(effectView)
    --             local effectObject = effectView.gameObject

    --             effectObject.transform:SetParent(self.toBattleButton.transform)
    --             effectObject.transform.localScale = Vector3(1, 0.8, 0.6)
    --             effectObject.transform.localPosition = Vector3(-50, 24, -400)
    --             effectObject.transform.localRotation = Quaternion.identity

    --             Utils.ChangeLayersRecursively(effectObject.transform, "UI")
    --         end
    --         self.toBattleButtonEffect = BaseEffectView.New({effectId = 20118, time = nil, callback = fun})
    --     else
    --         self.toBattleButtonEffect:SetActive(true)
    --     end
    -- end

    -- if PlayerPrefs.GetInt("GodEvolvePethasBattle") == 1 then
    --     if self.toBattleButtonEffect ~= nil then
    --         self.toBattleButtonEffect:SetActive(false)
    --     end
    -- end
end

function PetView_Base:NormalPetSetting()
    self.transform:FindChild("ModelPanel/LockBtn").gameObject:SetActive(true) --锁定按钮
    self.rideBtn:SetActive(true)                                              --不知名按钮
    self.transform:FindChild("ModelPanel/TalkButton").gameObject:SetActive(true) --talk按钮
    self.transform:FindChild("ModelPanel/HandBookButton").gameObject:SetActive(true) --资料按钮
    self.transform:Find("ModelPanel/EvaluationButton").gameObject:SetActive(true) --评价按钮

    self.panel1.transform:FindChild("EquipPanel/panel").gameObject:SetActive(true)   --宝石图标
    self.panel1.transform:FindChild("EquipPanel/Image/NameText"):GetComponent(Text).text = TI18N("宠物符石")
    local equipText = self.panel1.transform:FindChild("EquipPanel/Text1").gameObject   --隐藏文字提示信息
    equipText:SetActive(false)



    self.panel1.transform:FindChild("EquipPanel/Button/Image").gameObject:SetActive(true)
    self.panel1.transform:FindChild("EquipPanel/Button/Text"):GetComponent(RectTransform).offsetMin = Vector2(12,0)
    self.panel1.transform:FindChild("EquipPanel/Button/Text"):GetComponent(Text).text = TI18N("进阶")

    self.panel1.transform:FindChild("AttrPanel/PotentialButton").gameObject:SetActive(true)   --加点按钮
    self.artificeButton:SetActive(true)   --炼化 按钮
    self.releaseButton:SetActive(true)    --放生按钮

    self.panel1.transform:FindChild("InfoPanel/ExpGroup/Button").gameObject:SetActive(true)
    self.panel1.transform:FindChild("InfoPanel/HappyGroup/Button").gameObject:SetActive(true)

    self.transform:FindChild("ModelPanel/Image2").gameObject:SetActive(true)
    self.transform:FindChild("ModelPanel/I18N_Text").gameObject:SetActive(true)
    self.transform:FindChild("ModelPanel/GifeText").gameObject:SetActive(true)
    self.toBattleButton:GetComponent(RectTransform).localPosition = Vector3(301.6,-204.8,0)   --出战按钮
    self.transform:FindChild("OtherThing/FeedButtom").gameObject:SetActive(true)   --培养按钮

    if self.equipButtonEffect ~= nil then
        self.equipButtonEffect:SetActive(false)
    end
    if self.toBattleButtonEffect ~= nil then
        self.toBattleButtonEffect:SetActive(false)
    end
end



function PetView_Base:update_one(update)
    if BaseUtils.isnull(self.gameObject) then
        return
    end
    if self.model.cur_petdata == nil then return end

    self.parent:event_pet_update(update)

    if table.containValue(update, "base") then
        self:updata_base()
    end
    if table.containValue(update, "info") then
        self:updata_info()
    end
    if table.containValue(update, "attrs") then
        self:update_baseattrs()
    end
    if table.containValue(update, "skills") then
        if self.view_index == 2 then
            self:update_skill()
        end
    end
    if table.containValue(update, "stones") then
        self:updata_stone()
    end
    if table.containValue(update, "grade") then
        self:update_model()
        self:updata_upgradebtn()
    end
    if table.containValue(update, "upgrade") then
        self:update_model()
        self:updata_upgradebtn()
    end
end
--更新宠物预览
function PetView_Base:update_model()
    local transform = self.transform
    local preview = transform:FindChild("ModelPanel/Preview")

    local petData = self.model.cur_petdata
    local petModelData = self.model:getPetModel(petData)

    local data = {type = PreViewType.Npc, skinId = petModelData.skin, modelId = petModelData.modelId, animationId = petData.base.animation_id, scale = petData.base.scale / 100, effects = petModelData.effects}
    local isOpen = false;
    if petData ~= nil then
        local transList = petData.unreal;
        if transList ~= nil and #transList > 0 and DataPet.data_pet_trans_black[petData.base_id] == nil then
            isOpen = true
        end
        if isOpen and petData.unreal_looks_flag == 0 then
            local taransData = transList[1];
            local itemID = taransData.item_id
            local tmp = DataPet.data_pet_trans[itemID];
            if tmp ~= nil then
                local transFTmp = DataTransform.data_transform[tmp.skin_id];
                if transFTmp ~= nil then
                    data.modelId = transFTmp.res
                    data.skinId = transFTmp.skin
                    data.animationId = transFTmp.animation_id
                    data.effects = transFTmp.effects
                    data.scale = transFTmp.scale / 100
                end
            end
        end
    end
    self.parent:load_preview(preview, data)
end
--更新宠物预览边上的信息
function PetView_Base:updata_base()
    local transform = self.transform
    local petData = self.model.cur_petdata
    local gameObject = transform:FindChild("ModelPanel").gameObject

    gameObject.transform:FindChild("NameText"):GetComponent(Text).text = self.model:get_petname(petData)--petData.name
    gameObject.transform:FindChild("GifeText"):GetComponent(Text).text = string.format("%s(%s)", self.model:gettalentclass(petData.talent), petData.talent)
    if petData.genre==6 then
        gameObject.transform:FindChild("GenreImage"):GetComponent(Image).sprite
        = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("I18N_Genre%s", (petData.genre-5)))
    else
        gameObject.transform:FindChild("GenreImage"):GetComponent(Image).sprite
        = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("I18N_Genre%s", (petData.genre+1)))
    end

    gameObject.transform:FindChild("GenreImage").gameObject:SetActive(true)

    if self.model.cache_battle_id == petData.id then
        if petData.status == 1 then
            transform:FindChild("OtherThing/ToBattleButton/Text"):GetComponent(Text).text = TI18N("取消休息")
        else
            transform:FindChild("OtherThing/ToBattleButton/Text"):GetComponent(Text).text = TI18N("取消出战")
        end
        self.toBattleButton.gameObject:SetActive(true)
        self.spirtOffButton.gameObject:SetActive(false)
    else
        if petData.master_pet_id == 0 and petData.spirit_child_flag ~= 1 then
            if petData.status == 1 then
                transform:FindChild("OtherThing/ToBattleButton/Text"):GetComponent(Text).text = TI18N("休 息")
            else
                transform:FindChild("OtherThing/ToBattleButton/Text"):GetComponent(Text).text = TI18N("出 战")
            end
            self.toBattleButton.gameObject:SetActive(true)
            self.spirtOffButton.gameObject:SetActive(false)
        else
            self.toBattleButton.gameObject:SetActive(false)
            self.spirtOffButton.gameObject:SetActive(true)
        end
    end

    if petData.lock == 1 then
        gameObject.transform:FindChild("LockBtn/LockImg").gameObject:SetActive(true)
        gameObject.transform:FindChild("LockBtn/UnLockImg").gameObject:SetActive(false)
    else
        gameObject.transform:FindChild("LockBtn/LockImg").gameObject:SetActive(false)
        gameObject.transform:FindChild("LockBtn/UnLockImg").gameObject:SetActive(true)
    end

    local skinRedPoint = false
    for key, value in pairs(self.model.petlist) do
        if self.model:GetCanChangeSkin(value) and self.model:EnoughItemToChangeSkin(value) then
            skinRedPoint = true
            break
        end
    end
    if skinRedPoint then
        self.skinButtonRedPoint:SetActive(true)
    else
        self.skinButtonRedPoint:SetActive(false)
    end
end

function PetView_Base:updata_info()
    local transform = self.transform
    local petData = self.model.cur_petdata
    local gameObject = self.panel1.transform:FindChild("InfoPanel").gameObject
    gameObject.transform:FindChild("HpGroup/HpText"):GetComponent(Text).text = string.format("%s/%s", petData.hp, petData.hp_max)
    gameObject.transform:FindChild("HpGroup/HpSlider"):GetComponent(Slider).value = petData.hp / petData.hp_max
    gameObject.transform:FindChild("ExpGroup/ExpText"):GetComponent(Text).text = string.format("%s/%s", petData.exp, petData.max_exp)
    gameObject.transform:FindChild("ExpGroup/ExpSlider"):GetComponent(Slider).value = petData.exp / petData.max_exp

    gameObject.transform:FindChild("HpGroup/HpText"):GetComponent(Text).color = Color(232/255, 250/255, 255/255)
    gameObject.transform:FindChild("ExpGroup/ExpText"):GetComponent(Text).color = Color(232/255, 250/255, 255/255)
    if petData.genre == 2 or petData.genre == 4 then
        gameObject.transform:FindChild("HappyGroup/HappyText"):GetComponent(Text).text = string.format("<color='#ffff00'>%s</color>", TI18N("永生"))
        -- gameObject.transform:FindChild("HappyGroup/HappySlider"):GetComponent(Slider).value = 1
    else
        gameObject.transform:FindChild("HappyGroup/HappyText"):GetComponent(Text).text = string.format("<color='#ffff00'>%s</color>", petData.happy)
        -- gameObject.transform:FindChild("HappyGroup/HappySlider"):GetComponent(Slider).value = petData.happy / 100
    end
    --petdata.genre~=6
    if petData.genre~=6 then
      self.rideData = RideManager.Instance.model:GetContractRideByPetId(petData.id)
      if self.rideData == nil then
          if RideManager.Instance.model:CheckHasRideEx() then
              self.rideBtn:SetActive(true)
              self.rideImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "BidAddImage")
              self.rideImgRect.sizeDelta = Vector2(24,24)
          else
              self.rideBtn:SetActive(false)
              return
          end
      else
          self.rideBtn:SetActive(true)
          local headId = tostring(self.rideData.base.head_id)
        -- if self.rideData.transformation_id ~= nil and self.rideData.transformation_id ~= 0 then
        --     headId = tostring(DataMount.data_ride_data[self.rideData.transformation_id].head_id)
        -- end
          self.rideImg.sprite = self.assetWrapper:GetSprite(AssetConfig.headride, headId)
          self.rideImgRect.sizeDelta = Vector2(32,32)
      end
    end
end

function PetView_Base:updata_stone()
  local petData = self.model.cur_petdata
  if petData.genre~=6 then
    local transform = self.transform

    local gameObject = self.panel1.transform:FindChild("EquipPanel").gameObject
    local stone_hole = petData.grade + 2
    if stone_hole > 4 then stone_hole = 4 end

    for i=1,stone_hole do
        local icon = self.stoneList[i]
        local item_slot = icon.transform:FindChild("item_slot").gameObject

        local stonedata = nil
        for j=1,#petData.stones do
            if petData.stones[j].id == i then
                stonedata = petData.stones[j]
                break
            end
        end

        if stonedata ~= nil then
            local slot = self.stoneIconList[i]
            local itembase = BackpackManager.Instance:GetItemBase(stonedata.base_id)
            local itemData = ItemData.New()
            itemData.id = stonedata.id
            itemData.attr = stonedata.attr
            itemData.reset_attr = stonedata.reset_attr
            itemData.extra = stonedata.extra
            itemData:SetBase(itembase)

            local data = DataPet.data_pet_grade[string.format("%s_%s", self.model.cur_petdata.base.id, self.model.cur_petdata.grade+1)]
            if data ~= nil then
                slot:SetAll(itemData, { nobutton = true, white_list = { { id = 12, show = true } } })
            else
                slot:SetAll(itemData, { nobutton = true, white_list = { { id = 16, show = true } } })
            end
            icon:SetActive(true)
            item_slot:SetActive(true)

            slot:ShowState_ImgPos(false)
            --符石点击特殊处理
            if i > 1 then -- 除去第一个护符,只针对符石
                local dataTemp = DataPet.data_pet_grade[string.format("%s_%s", self.model.cur_petdata.base.id, self.model.cur_petdata.grade+1)]
                if dataTemp ~= nil then
                    --宠物还可以进阶
                    slot.noTips = false
                    slot.click_self_call_back = nil
                else
                    --宠物已经是最高阶了
                    slot.noTips = true
                    slot.click_self_call_back = self.onClickStoneShowWashPanelFun

                    local isShowGreenPoint = true
                    for kk,kkvv in ipairs(stonedata.extra) do
                        if kkvv.name == 8 and kkvv.value == 1 then
                            isShowGreenPoint = false
                        end
                    end
                    for i=1,#stonedata.attr do
                        local attr_data = stonedata.attr[i]
                        if attr_data.name == 100 then
                            isShowGreenPoint = false
                            break
                        end
                    end
                    if isShowGreenPoint == true then
                        slot:ShowState_ImgPos(true,"greenpoint",Vector3(25,25,0))
                    end
                end
            end
        else
            icon:SetActive(true)
            item_slot:SetActive(false)
        end
    end

    for i=stone_hole+1,#self.stoneList do
        local icon = self.stoneList[i]
        icon:SetActive(false)
    end
  end
end

function PetView_Base:onClickStoneShowWashPanel(slotItemData)
    -- BaseUtils.dump(slot,"PetView:onClickStoneShowWashPanel(slot)---")
    self.model.isMyPet = true
    self.model:OpenPetStoneWashPanel(true,slotItemData,true)
end

function PetView_Base:updata_upgradebtn()
    local petData = self.model.cur_petdata
    if petData.genre~=6 then
        local data = DataPet.data_pet_grade[string.format("%s_%s", self.model.cur_petdata.base.id, self.model.cur_petdata.grade+1)]
        if data ~= nil then
           self.panel1.transform:FindChild("EquipPanel/Button").gameObject:SetActive(true)
           self.panel1.transform:FindChild("EquipPanel/Button/Text"):GetComponent(Text).text = TI18N("进阶")
           self.panel1.transform:FindChild("EquipPanel/Button/Text"):GetComponent(Text).color = ColorHelper.DefaultButton1
           self.panel1.transform:FindChild("EquipPanel/Button"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
           self.panel1.transform:FindChild("EquipPanel/Text").gameObject:SetActive(false)
        elseif self.model.cur_petdata.base.has_break_skill > 0 and self.model.cur_petdata.break_times == 0 then
           self.panel1.transform:FindChild("EquipPanel/Button").gameObject:SetActive(true)
           self.panel1.transform:FindChild("EquipPanel/Button/Text"):GetComponent(Text).text = TI18N("突破")
           self.panel1.transform:FindChild("EquipPanel/Button/Text"):GetComponent(Text).color = ColorHelper.DefaultButton3
           self.panel1.transform:FindChild("EquipPanel/Button"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
           self.panel1.transform:FindChild("EquipPanel/Text").gameObject:SetActive(false)
        elseif self.model.cur_petdata.base.has_break_skill > 0 then
           self.panel1.transform:FindChild("EquipPanel/Button").gameObject:SetActive(false)
           self.panel1.transform:FindChild("EquipPanel/Text").gameObject:SetActive(true)
           self.panel1.transform:FindChild("EquipPanel/Text"):GetComponent(Text).text = TI18N("已经突破")
        else
           self.panel1.transform:FindChild("EquipPanel/Button").gameObject:SetActive(false)
           self.panel1.transform:FindChild("EquipPanel/Text").gameObject:SetActive(true)
           self.panel1.transform:FindChild("EquipPanel/Text"):GetComponent(Text).text = TI18N("已进至最高阶")
        end
    else
        --判断精灵蛋的级数如果小于三十级    显示不变
        --如果等于三十级    按钮变成黄色+闪烁
        self.panel1.transform:FindChild("EquipPanel/Text").gameObject:SetActive(false)
        if petData.lev >= 30 then
            if petData.grade == 0 then
              --没有进化
              self.panel1.transform:FindChild("EquipPanel/Button"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
              self.panel1.transform:FindChild("EquipPanel/Button/Text"):GetComponent(Text).color = Color(144/255, 96/255, 20/255, 1)
             --显示特效
                if self.equipButtonEffect == nil then
                    local fun = function(effectView)
                        local effectObject = effectView.gameObject

                        effectObject.transform:SetParent(self.Equipbtn.transform)
                        effectObject.transform.localScale = Vector3(1, 0.6, 0.6)
                        effectObject.transform.localPosition = Vector3(-50, 15, -400)
                        effectObject.transform.localRotation = Quaternion.identity

                        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                    end
                    self.equipButtonEffect = BaseEffectView.New({effectId = 20118, time = nil, callback = fun})
                else
                    self.equipButtonEffect:SetActive(true)
                end
            elseif petData.grade == 1 then
              --已进化   显示特效
                local equipText = self.panel1.transform:FindChild("EquipPanel/Text1").gameObject   --显示文字提示信息
                equipText:GetComponent(Text).color = Color(12/255,82/255,176/255)
                equipText:GetComponent(Text).text = string.format(TI18N("1.恭喜成功进化成瑞兔送福\n2.每晚<color='#ffff00'>21至23点</color>开启赢大奖"))
                local hour = tonumber(os.date("%H",BaseUtils.BASE_TIME))
                local petEggConfig = DataCampPetEgg.data_get_extra_cfg[1]
                local timeFlag = false
                if petEggConfig ~= nil then
                    timeFlag = tonumber(hour) >= petEggConfig.time[1][1] and tonumber(hour) < petEggConfig.time[1][4]
                end
                if timeFlag then
                    self.panel1.transform:FindChild("EquipPanel/Button"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                    self.panel1.transform:FindChild("EquipPanel/Button/Text"):GetComponent(Text).color = Color(144/255, 96/255, 20/255, 1)
                    self.panel1.transform:FindChild("EquipPanel/Button/Text"):GetComponent(Text).text = TI18N("点击开启")
                    if self.equipButtonEffect == nil then
                      local fun = function(effectView)
                          local effectObject = effectView.gameObject
                          effectObject.transform:SetParent(self.Equipbtn.transform)
                          effectObject.transform.localScale = Vector3(1, 0.6, 0.6)
                          effectObject.transform.localPosition = Vector3(-50, 15, -400)
                          effectObject.transform.localRotation = Quaternion.identity
                          Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                      end
                      self.equipButtonEffect = BaseEffectView.New({effectId = 20118, time = nil, callback = fun})
                    else
                      self.equipButtonEffect:SetActive(true)
                    end
                else
                    self.panel1.transform:FindChild("EquipPanel/Button"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
                    self.panel1.transform:FindChild("EquipPanel/Button/Text"):GetComponent(Text).color = Color(199/255, 249/255, 255/255, 1)
                    self.panel1.transform:FindChild("EquipPanel/Button/Text"):GetComponent(Text).text = TI18N("等待开启")
                    if self.equipButtonEffect ~= nil then
                        self.equipButtonEffect:SetActive(false)
                    end
                end
            end
        else
            if self.equipButtonEffect ~= nil then
                self.equipButtonEffect:SetActive(false)
            end
        end
    end
end

function PetView_Base:update_baseattrs()
    local transform = self.transform
    local petData = self.model.cur_petdata

    self.panel1.transform:FindChild("AttrPanel/AttrObject1/ValueText"):GetComponent(Text).text = tostring(petData.phy_dmg)
    self.panel1.transform:FindChild("AttrPanel/AttrObject2/ValueText"):GetComponent(Text).text = tostring(petData.magic_dmg)
    self.panel1.transform:FindChild("AttrPanel/AttrObject3/ValueText"):GetComponent(Text).text = tostring(petData.phy_def)
    self.panel1.transform:FindChild("AttrPanel/AttrObject4/ValueText"):GetComponent(Text).text = tostring(petData.magic_def)
    self.panel1.transform:FindChild("AttrPanel/AttrObject5/ValueText"):GetComponent(Text).text = tostring(petData.atk_speed)
    self.panel1.transform:FindChild("AttrPanel/AttrObject6/ValueText"):GetComponent(Text).text = tostring(petData.mp_max)
    if petData.genre~=6 then
        self.panel1.transform:FindChild("AttrPanel/PotentialButton").gameObject:SetActive(true)
        if petData.point > 0 then
            self.panel1.transform:FindChild("AttrPanel/PotentialButton/RedPointImage").gameObject:SetActive(true)
        else
            self.panel1.transform:FindChild("AttrPanel/PotentialButton/RedPointImage").gameObject:SetActive(false)
        end
    else
        self.panel1.transform:FindChild("AttrPanel/PotentialButton").gameObject:SetActive(false)
        self.panel1.transform:FindChild("AttrPanel/PotentialButton/RedPointImage").gameObject:SetActive(false)
    end
end

function PetView_Base:update_qualityattrs()
  local petData = self.model.cur_petdata
  if petData.genre~=6 then
    local transform = self.transform
    local petData = self.model.cur_petdata

    if (petData.phy_aptitude / petData.base.phy_aptitude) > 0.97 then
        self.panel2.transform:FindChild("QualityPanel/ValueSlider1/Text"):GetComponent(Text).text = string.format("<color='#ffffff'>%s/%s</color>", petData.phy_aptitude, petData.max_phy_aptitude)
    else
        self.panel2.transform:FindChild("QualityPanel/ValueSlider1/Text"):GetComponent(Text).text = string.format("%s/%s", petData.phy_aptitude, petData.max_phy_aptitude)
    end
    if (petData.pdef_aptitude / petData.base.pdef_aptitude) > 0.97 then
        self.panel2.transform:FindChild("QualityPanel/ValueSlider2/Text"):GetComponent(Text).text = string.format("<color='#ffffff'>%s/%s</color>", petData.pdef_aptitude, petData.max_pdef_aptitude)
    else
        self.panel2.transform:FindChild("QualityPanel/ValueSlider2/Text"):GetComponent(Text).text = string.format("%s/%s", petData.pdef_aptitude, petData.max_pdef_aptitude)
    end
    if (petData.hp_aptitude / petData.base.hp_aptitude) > 0.97 then
        self.panel2.transform:FindChild("QualityPanel/ValueSlider3/Text"):GetComponent(Text).text = string.format("<color='#ffffff'>%s/%s</color>", petData.hp_aptitude, petData.max_hp_aptitude)
    else
        self.panel2.transform:FindChild("QualityPanel/ValueSlider3/Text"):GetComponent(Text).text = string.format("%s/%s", petData.hp_aptitude, petData.max_hp_aptitude)
    end
    if (petData.magic_aptitude / petData.base.magic_aptitude) > 0.97 then
        self.panel2.transform:FindChild("QualityPanel/ValueSlider4/Text"):GetComponent(Text).text = string.format("<color='#ffffff'>%s/%s</color>", petData.magic_aptitude, petData.max_magic_aptitude)
    else
        self.panel2.transform:FindChild("QualityPanel/ValueSlider4/Text"):GetComponent(Text).text = string.format("%s/%s", petData.magic_aptitude, petData.max_magic_aptitude)
    end
    if (petData.aspd_aptitude / petData.base.aspd_aptitude) > 0.97 then
        self.panel2.transform:FindChild("QualityPanel/ValueSlider5/Text"):GetComponent(Text).text = string.format("<color='#ffffff'>%s/%s</color>", petData.aspd_aptitude, petData.max_aspd_aptitude)
    else
        self.panel2.transform:FindChild("QualityPanel/ValueSlider5/Text"):GetComponent(Text).text = string.format("%s/%s", petData.aspd_aptitude, petData.max_aspd_aptitude)
    end

    Tween.Instance:Cancel(self.slider1_tweenId)
    Tween.Instance:Cancel(self.slider2_tweenId)
    Tween.Instance:Cancel(self.slider3_tweenId)
    Tween.Instance:Cancel(self.slider4_tweenId)
    Tween.Instance:Cancel(self.slider5_tweenId)

    local slider1 = self.panel2.transform:FindChild("QualityPanel/ValueSlider1/Slider"):GetComponent(Slider)
    local fun1 = function(value) slider1.value = value end
    local slider_value1 = ((petData.phy_aptitude - petData.base.phy_aptitude * 0.8) / (petData.max_phy_aptitude - petData.base.phy_aptitude * 0.8 + 0.0001) * 0.8 + 0.2)
    self.slider1_tweenId = Tween.Instance:ValueChange(slider1.value, slider_value1, 0.3, nil, LeanTweenType.linear, fun1).id

    local slider2 = self.panel2.transform:FindChild("QualityPanel/ValueSlider2/Slider"):GetComponent(Slider)
    local fun2 = function(value) slider2.value = value end
    local slider_value2 = ((petData.pdef_aptitude - petData.base.pdef_aptitude * 0.8) / (petData.max_pdef_aptitude - petData.base.pdef_aptitude * 0.8 + 0.0001) * 0.8 + 0.2)
    self.slider2_tweenId = Tween.Instance:ValueChange(slider2.value, slider_value2, 0.3, nil, LeanTweenType.linear, fun2).id

    local slider3 = self.panel2.transform:FindChild("QualityPanel/ValueSlider3/Slider"):GetComponent(Slider)
    local fun3 = function(value) slider3.value = value end
    local slider_value3 = ((petData.hp_aptitude - petData.base.hp_aptitude * 0.8) / (petData.max_hp_aptitude - petData.base.hp_aptitude * 0.8 + 0.0001) * 0.8 + 0.2)
    self.slider3_tweenId = Tween.Instance:ValueChange(slider3.value, slider_value3, 0.3, nil, LeanTweenType.linear, fun3).id

    local slider4 = self.panel2.transform:FindChild("QualityPanel/ValueSlider4/Slider"):GetComponent(Slider)
    local fun4 = function(value) slider4.value = value end
    local slider_value4 = ((petData.magic_aptitude - petData.base.magic_aptitude * 0.8) / (petData.max_magic_aptitude - petData.base.magic_aptitude * 0.8 + 0.0001) * 0.8 + 0.2)
    self.slider4_tweenId = Tween.Instance:ValueChange(slider4.value, slider_value4, 0.3, nil, LeanTweenType.linear, fun4).id

    local slider5 = self.panel2.transform:FindChild("QualityPanel/ValueSlider5/Slider"):GetComponent(Slider)
    local fun5 = function(value) slider5.value = value end
    local slider_value5 = ((petData.aspd_aptitude - petData.base.aspd_aptitude * 0.8) / (petData.max_aspd_aptitude- petData.base.aspd_aptitude * 0.8 + 0.0001) * 0.8 + 0.2)
    self.slider5_tweenId = Tween.Instance:ValueChange(slider5.value, slider_value5, 0.3, nil, LeanTweenType.linear, fun5).id

    self.panel2.transform:FindChild("QualityPanel/GrowthImage"):GetComponent(Image).sprite
        = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("PetGrowth%s", petData.growth_type))
    self.panel2.transform:FindChild("QualityPanel/GrowthText"):GetComponent(Text).text = string.format("%.2f", petData.growth / 500)

    self.clickQualityPanel = false
    local slider_value = { petData.phy_aptitude ~= petData.max_phy_aptitude
                        , petData.pdef_aptitude ~= petData.max_pdef_aptitude
                        , petData.hp_aptitude ~= petData.max_hp_aptitude
                        , petData.magic_aptitude ~= petData.max_magic_aptitude
                        , petData.aspd_aptitude ~= petData.max_aspd_aptitude }
    for i = 1, 5 do
        self.panel2.transform:FindChild(string.format("QualityPanel/Recommend%s", i)).gameObject:SetActive(table.containValue(petData.base.recommend_aptitudes, i))
        self.panel2.transform:FindChild(string.format("QualityPanel/AddImage%s", i)).gameObject:SetActive(slider_value[i])
        if slider_value[i] then self.clickQualityPanel = true end
    end
  end
end

function PetView_Base:update_skill()
    local transform = self.transform
    local petData = self.model.cur_petdata
    local skills = self.model:makeBreakSkill(petData.base.id, petData.skills)

    for i=1,#skills do
        local skilldata = skills[i]
        local icon = self.skillList[i]
        icon.gameObject.name = skilldata.id
        local skill_data = DataSkill.data_petSkill[string.format("%s_1", skilldata.id)]
        icon:SetAll(Skilltype.petskill, skill_data)
        icon:ShowState(skilldata.source == 2)
        icon:ShowLabel(skilldata.source == 4 or skilldata.isBreak, TI18N("<color='#ffff00'>突破</color>"))
        icon:ShowBreak(skilldata.isBreak, TI18N("<color='#FF0000'>未激活</color>"))

        if skilldata.source == 5 then
            local data_pet_change_skill = DataPet.data_pet_change_skill[petData.base_id]
            if data_pet_change_skill ~= nil and data_pet_change_skill.skill_id == skilldata.id then
                icon:SetNotips(true)
                icon:SetSelectSelfCallback(function() self.model:OpenPetChangeSkillPanel({ petData.id, petData.base_id, 0 }) end)
                icon:ShowChangeSkill(true)
                icon:SetChangeSkillCallback(function() self.model:OpenPetChangeSkillPanel({ petData.id, petData.base_id, 0 }) end)
                icon:ShowLabel(true, TI18N("<color='#ffff00'>选择</color>"))
            else
                icon.noTips = false
                icon:SetSelectSelfCallback(nil)
                icon:ShowChangeSkill(true)
                icon:SetChangeSkillCallback(function() self.model:OpenPetChangeSkillPanel({ petData.id, petData.base_id, skilldata.id }) end)
            end
        else
            icon.noTips = false
            icon:SetSelectSelfCallback(nil)
            icon:ShowChangeSkill(false)
        end
    end

    for i=#skills+1,#self.skillList do
        local icon = self.skillList[i]
        icon.gameObject.name = ""
        icon:Default()
        icon:ShowState(false)
        icon:ShowChangeSkill(false)
        icon.skillData = nil
    end

    if #skills < #self.skillList then
        self.recommendSkillButton.gameObject:SetActive(true)
        self.recommendSkillButton.transform.localPosition = self.skillList[#skills+1].gameObject.transform.parent.localPosition
    else
        self.recommendSkillButton.gameObject:SetActive(false)
    end
end


function PetView_Base:tobattle()
    if self.model.cur_petdata ~= nil then
        if CombatManager.Instance.isFighting and not CombatManager.Instance.isWatching and not CombatManager.Instance.isWatchRecorder then
            if self.model.cache_battle_id == self.model.cur_petdata.id then
                self.model.cache_battle_id = nil
                NoticeManager.Instance:FloatTipsByString(TI18N("取消成功"))
            else
                self.model.cache_battle_id = self.model.cur_petdata.id

                if self.model.cur_petdata.status == 1 then
                    NoticeManager.Instance:FloatTipsByString(TI18N("将在战斗结束后休息，再次点击可取消"))
                else
                    NoticeManager.Instance:FloatTipsByString(TI18N("将在战斗结束后出战，再次点击可取消"))
                end
            end
            self:updata_base()

        else
            if self.model.cur_petdata.status == 0 then
                PetManager.Instance:Send10501(self.model.cur_petdata.id, 1)
            elseif self.model.cur_petdata.status == 1 then
                PetManager.Instance:Send10501(self.model.cur_petdata.id, 0)
            end
        end
        if self.model.cur_petdata.genre == 6 then
            if self.toBattleButtonEffect ~= nil then
                 self.toBattleButtonEffect:SetActive(false)
            end
        end
    end
end

function PetView_Base:OnSpirtOffButtonClick()
    if self.model.cur_petdata ~= nil then
        if self.model.cur_petdata.master_pet_id ~= 0 and self.model.cur_petdata.spirit_child_flag ~= 1 then
            PetManager.Instance:Send10562(self.model.cur_petdata.id, 0)
        elseif self.model.cur_petdata.master_pet_id == 0 and self.model.cur_petdata.spirit_child_flag == 1 then
            ChildrenManager.Instance:Require18641(self.model.cur_petdata.id)
        end
    end
end

function PetView_Base:releasebuttonclick()
    -- connection.send(9900, {cmd = "获取宠物"})
    if self.model.cur_petdata ~= nil then
        if #self.model.petlist == 1 then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Sure
            data.content = TI18N("你舍得抛弃最后的伙伴吗？")
            data.sureLabel = TI18N("确认")
            NoticeManager.Instance:ConfirmTips(data)
        else
            if self.model.cur_petdata.genre == 2 then
                NoticeManager.Instance:FloatTipsByString(TI18N("神兽无法放生"))
            elseif self.model.cur_petdata.genre == 4 then
                NoticeManager.Instance:FloatTipsByString(TI18N("珍兽无法放生"))
            elseif self.model.cur_petdata.lock == 1 then
                NoticeManager.Instance:FloatTipsByString(TI18N("锁定宠物无法放生"))
            elseif self.model.cur_petdata.genre == 3 then
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = string.format(TI18N("你确定要将<color='#00ff00'>%s lv.%s</color>放生吗"), self.model.cur_petdata.name, self.model.cur_petdata.lev)
                data.sureLabel = TI18N("确认")
                data.cancelLabel = TI18N("取消")
                data.sureCallback = function() PetManager.Instance:Send10522(self.model.cur_petdata.id)  end
                NoticeManager.Instance:ConfirmTips(data)
            else
                self.transform:FindChild("OtherThing/ReleasePanel").gameObject:SetActive(true)
                local input_field = self.transform:FindChild("OtherThing/ReleasePanel/Main/InputCon"):FindChild("InputField"):GetComponent(InputField)
                input_field.textComponent = self.transform:FindChild("OtherThing/ReleasePanel/Main/InputCon/InputField/Text"):GetComponent(Text)
                input_field.text = ""
            end
        end
    end
end

function PetView_Base:hidereleasepanel()
    self.transform:FindChild("OtherThing/ReleasePanel").gameObject:SetActive(false)
end

function PetView_Base:releasepet()
    if self.model.cur_petdata ~= nil then
        local input_field = self.transform:FindChild("OtherThing/ReleasePanel/Main/InputCon"):FindChild("InputField"):GetComponent(InputField)
        local str = string.lower(input_field.text)
        if str == "yes" then
            self:hidereleasepanel()
            PetManager.Instance:Send10522(self.model.cur_petdata.id)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("放生需要输入“yes”进行确认"))
        end
    end
end

function PetView_Base:showReleaseButtonpanel()
    self.releaseButtonPanel:SetActive(true)
    self.showReleaseButton.transform:FindChild("Image").localRotation = Quaternion.identity
end

function PetView_Base:hideReleaseButtonpanel()
    self.releaseButtonPanel:SetActive(false)
    self.showReleaseButton.transform:FindChild("Image").localRotation = Quaternion.identity
    self.showReleaseButton.transform:FindChild("Image"):Rotate(Vector3(0, 0, 180))
end

function PetView_Base:lockpetbuttonclick()
    if self.model.cur_petdata ~= nil then
        if self.model.cur_petdata.lock == 0 then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("对宠物加锁后，将无法进行<color='#ffff00'>洗髓、放生、学习技能、洗点、内丹</color>。解锁不需要消耗任何资源。是否进行加锁？")
            data.sureLabel = TI18N("加锁")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function() PetManager.Instance:Send10537(self.model.cur_petdata.id) end
            NoticeManager.Instance:ConfirmTips(data)
        else
            self.transform:FindChild("OtherThing/LockPanel").gameObject:SetActive(true)
            local input_field = self.transform:FindChild("OtherThing/LockPanel/Main/InputCon"):FindChild("InputField"):GetComponent(InputField)
            input_field.textComponent = self.transform:FindChild("OtherThing/LockPanel/Main/InputCon/InputField/Text"):GetComponent(Text)
            input_field.text = TI18N("请输入上方的验证码")

            -- self.lockKey = "1234"
            self.lockKey = tostring(math.random(1000, 9999))
            self.transform:FindChild("OtherThing/LockPanel/Main/Key_Text"):GetComponent(Text).text = self.lockKey
        end
    end
end

function PetView_Base:hidelockpetpanel()
    self.transform:FindChild("OtherThing/LockPanel").gameObject:SetActive(false)
end

function PetView_Base:lockpet()
    if self.model.cur_petdata ~= nil then
        local input_field = self.transform:FindChild("OtherThing/LockPanel/Main/InputCon"):FindChild("InputField"):GetComponent(InputField)
        local str = input_field.text
        if str == self.lockKey then
            self:hidelockpetpanel()
            PetManager.Instance:Send10538(self.model.cur_petdata.id)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("验证码错误"))
        end
    end
end

function PetView_Base:openaddpotentialwindow()
    if self.model.cur_petdata ~= nil then
        AddPointManager.Instance:Open({2, self.model.cur_petdata})
    end
end

function PetView_Base:opentalksetpanel()
    if self.model.cur_petdata ~= nil then
        PetManager.Instance:Send10535(self.model.cur_petdata.id)
        -- self.model:OpenPetSetTalkPanel()
    end
end

function PetView_Base:openlearnskillwindow()
    if self.model.cur_petdata ~= nil then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet_learnskill)
    end
end

function PetView_Base:onstoneclick(gameobject)
    self.model.select_gem = tonumber(gameobject.name)
    if self.model.cur_petdata ~= nil then
        local stonedata = nil
        for i=1,#self.model.cur_petdata.stones do
            if self.model.cur_petdata.stones[i].id == self.model.select_gem then
                stonedata = self.model.cur_petdata.stones[i]
                break
            end
        end
        if stonedata == nil then
            local data = DataPet.data_pet_grade[string.format("%s_%s", self.model.cur_petdata.base.id, self.model.cur_petdata.grade+1)]
            if data ~= nil then
                self.model.gem_type = 0
            else
                self.model.gem_type = 1
            end

            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petgemwindow)
        end
    end
end

function PetView_Base:onupgradeclick(gameobject)
    local petdata =self.model.cur_petdata
    if petdata ~= nil then
        -- mod_pet.send10509(mod_pet.cur_petdata.id)
        --curr_petData.agility==46
        if petdata.genre ~= 6 then
            local data = DataPet.data_pet_grade[string.format("%s_%s", petdata.base.id, petdata.grade+1)]
            if data ~= nil then
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet_upgrade)
            elseif petdata.base.has_break_skill > 0 and petdata.break_times == 0 then
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petbreakwindow)
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("宠物已进阶到最高等级"))
            end
        else
            --如果不满足30级，弹出提示框
            if petdata.lev < 30 then
                NoticeManager.Instance:FloatTipsByString(TI18N("等级达到30级再来进化吧{face_1,3}"))
            elseif petdata.lev >= 30 then
                if petdata.grade == 0 then
                    self.parent.model:ShowUpdateEffect2()
                elseif petdata.grade == 1  then
                    --孵化操作
                    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
                    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
                    SceneManager.Instance.sceneElementsModel:Self_PathToTarget("32043_1")
                    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.pet)
                end
            end

        end
    end
end

function PetView_Base:showgiftimagetips()
    if self.model.cur_petdata ~= nil then
        self.transform:FindChild("OtherThing/GiftTips").gameObject:SetActive(true)
        -- transform:FindChild("OtherThing/GiftTips/Tips/Text"):GetComponent(Text).text = tostring(math.floor(mod_pet.cur_petdata.growth / 5) / 100)
        self.transform:FindChild("OtherThing/GiftTips/Tips/Text"):GetComponent(Text).text = string.format("%.2f", self.model.cur_petdata.growth / 500)
    end
end

function PetView_Base:hidegiftimagetips()
    self.transform:FindChild("OtherThing/GiftTips").gameObject:SetActive(false)
end

function PetView_Base:openfeed_quality()
    if self.model.cur_petdata == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前没有宠物，快去获得一只宠物吧！"))
    else
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet_feed, {2})
    end
end

function PetView_Base:openfeed_happy()
    if self.model.cur_petdata == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前没有宠物，快去获得一只宠物吧！"))
    else
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet_feed, {1})
    end
end

function PetView_Base:openfeed_recommendskill()
    if self.model.cur_petdata == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前没有宠物，快去获得一只宠物吧！"))
    else
        self.model:OpenRecommendSkillWindow()
    end
end

function PetView_Base:opennameeditwindow()
    if self.model.cur_petdata ~= nil then
        -- mod_notify.open_input_win("改名", "输入新的宠物名字：（最多6个字）", "请输入宠物名字", ui_pet_base.nameedit)
        self.transform:FindChild("OtherThing/EditNamePanel").gameObject:SetActive(true)
        local input_field = self.transform:FindChild("OtherThing/EditNamePanel/Main/InputCon"):FindChild("InputField"):GetComponent(InputField)
        input_field.textComponent = self.transform:FindChild("OtherThing/EditNamePanel/Main/InputCon/InputField/Text"):GetComponent(Text)
        input_field.text = ""
    end
end

function PetView_Base:hideeditnamepanel()
    self.transform:FindChild("OtherThing/EditNamePanel").gameObject:SetActive(false)
end

function PetView_Base:nameedit()
    local input_field = self.transform:FindChild("OtherThing/EditNamePanel/Main/InputCon"):FindChild("InputField"):GetComponent(InputField)
    local str = input_field.text
    PetManager.Instance:Send10519(self.model.cur_petdata.id, str)
    self:hideeditnamepanel()
end

function PetView_Base:onQualityPanelClick()
    if self.clickQualityPanel then
        self:openfeed_quality()
    end
end

function PetView_Base:close_all_tips()
    self:hidelockpetpanel()
    self:hidegiftimagetips()
    self:hidereleasepanel()
    self:hideeditnamepanel()
end

function PetView_Base:gem_off(id)
    if self.model.cur_petdata ~= nil then
        PetManager.Instance:Send10507(self.model.cur_petdata.id, 0, id)
    end
end

function PetView_Base:gem_replace(id)
    if self.model.cur_petdata ~= nil then
        self.model.select_gem = tonumber(id)
        self.model.gem_type = 2
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petgemwindow)
    end
end

-- 打开坐骑契约
function PetView_Base:OpenRide()
    RideManager.Instance.model:OpenRidePet(self.model.cur_petdata)
end

-- 宠物洗炼
function PetView_Base:OpenArtifice()
    if self.model.cur_petdata.lock == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("该宠物已锁定，无法进行炼化"))
    elseif self.model.cur_petdata.status == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("该宠物当前处于<color='#ffff00'>出战状态</color>，无法炼化"))
    elseif self.model.cur_petdata.genre == 2 or self.model.cur_petdata.genre == 4 then
        NoticeManager.Instance:FloatTipsByString(TI18N("无法炼化<color='#ffff00'>神兽/珍兽</color>"))
    else
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petartificewindow, { self.model.cur_petdata })
    end
end

function PetView_Base:onHandBookButtonClick()
    -- self.handBookPanel:SetActive(true)
    -- local attrs = self.model:GetHandBookAttr(self.model.cur_petdata)
    -- local str1 = ""
    -- local str2 = ""
    -- local str3 = ""
    -- local str4 = ""
    -- local index = 0
    -- local mark_index = 0
    -- local mark = true

    -- for _, data in ipairs(attrs) do
    --     local key = data.key
    --     local value = data.value
    --     local attr_name = KvData.attr_name[key]
    --     if attr_name ~= nil then
    --         local color = "#23e3eb"
    --         if KvData.prop_percent[key] ~= nil then
    --             color = "#c179df"

    --             if mark then
    --                 mark = false
    --                 mark_index = index
    --                 str1 = string.format("%s\n", str1)
    --                 str2 = string.format("%s\n", str2)
    --                 str3 = string.format("%s\n", str3)
    --                 str4 = string.format("%s\n", str4)
    --                 if index % 2 == 1 then
    --                     str3 = string.format("%s\n", str3)
    --                     str4 = string.format("%s\n", str4)
    --                     index = index + 1
    --                 end
    --                 index = index + 2
    --             end
    --         end

    --         if index % 2 == 0 then
    --             if KvData.prop_percent[key] == nil then
    --                 str1 = string.format("%s\n<color='%s'>%s</color>", str1, color, attr_name)
    --                 str2 = string.format("%s\n<color='%s'>+%s</color>", str2, color, value)
    --             else
    --                 str1 = string.format("%s\n<color='%s'>%s</color>", str1, color, attr_name)
    --                 str2 = string.format("%s\n<color='%s'>+%s%%</color>", str2, color, value)
    --             end
    --         else
    --             if KvData.prop_percent[key] == nil then
    --                 str3 = string.format("%s\n<color='%s'>%s</color>", str3, color, attr_name)
    --                 str4 = string.format("%s\n<color='%s'>+%s</color>", str4, color, value)
    --             else
    --                 str3 = string.format("%s\n<color='%s'>%s</color>", str3, color, attr_name)
    --                 str4 = string.format("%s\n<color='%s'>+%s%%</color>", str4, color, value)
    --             end
    --         end
    --         index = index + 1
    --     end
    -- end

    -- self.handBookPanel.transform:FindChild("Main/I18NText1"):GetComponent(Text).text = str1
    -- self.handBookPanel.transform:FindChild("Main/NumText1"):GetComponent(Text).text = str2
    -- self.handBookPanel.transform:FindChild("Main/I18NText2"):GetComponent(Text).text = str3
    -- self.handBookPanel.transform:FindChild("Main/NumText2"):GetComponent(Text).text = str4

    -- self.handBookPanel.transform:FindChild("Main/StarText"):GetComponent(Text).text =
    --         string.format(TI18N("宠物图鉴已激活：%s/24\n1★图鉴已激活：%s/24\n已使用兽王丹:<color='#8de92a'>%s/20</color>"), 0, 0, self.model.cur_petdata.feed_point)

    -- local rect = self.handBookPanel.transform:FindChild("Main"):GetComponent(RectTransform)
    -- local width = rect.sizeDelta.x
    -- local line1 = self.handBookPanel.transform:FindChild("Main/Line1")
    -- local line2 = self.handBookPanel.transform:FindChild("Main/Line2")
    -- if index == 0 then
    --     self.handBookPanel.transform:FindChild("Main/NoItemTips").gameObject:SetActive(true)

    --     self.handBookPanel.transform:FindChild("Main/StarText").gameObject:SetActive(false)
    --     rect.sizeDelta = Vector2(width, 180)
    --     line1.gameObject:SetActive(false)
    --     line2.gameObject:SetActive(false)
    -- else
    --     self.handBookPanel.transform:FindChild("Main/NoItemTips").gameObject:SetActive(false)

    --     local preferredHeight = self.handBookPanel.transform:FindChild("Main/I18NText1"):GetComponent(Text).preferredHeight
    --     -- self.handBookPanel.transform:FindChild("Main/StarText").localPosition = Vector2(0, preferredHeight - 130)
    --     self.handBookPanel.transform:FindChild("Main/StarText").localPosition = Vector2(0, - preferredHeight - 54)
    --     local hight = 120 + preferredHeight + 17
    --     rect.sizeDelta = Vector2(width, hight)

    --     line1.gameObject:SetActive(true)
    --     line2.gameObject:SetActive(false)
    --     if mark then
    --         line1.localPosition = Vector2(0, -94 - math.floor(index/2) * 16)
    --     else
    --         line1.localPosition = Vector2(0, -94 - math.floor(mark_index/2) * 16)
    --     end
    -- end

    self.handBookPanel:SetActive(true)
    local attrs = self.model:GetHandBookAttr(self.model.cur_petdata)
    self.handBookPanel.transform:FindChild("Main/NumText1"):GetComponent(Text).text = string.format("+%s", attrs[4])
    self.handBookPanel.transform:FindChild("Main/NumText2"):GetComponent(Text).text = string.format("+%s", attrs[6])
    self.handBookPanel.transform:FindChild("Main/NumText3"):GetComponent(Text).text = string.format("+%s", attrs[5])
    self.handBookPanel.transform:FindChild("Main/NumText4"):GetComponent(Text).text = string.format("+%s", attrs[7])
    self.handBookPanel.transform:FindChild("Main/NumText5"):GetComponent(Text).text = string.format("+%s", attrs[1])
    self.handBookPanel.transform:FindChild("Main/NumText6"):GetComponent(Text).text = string.format("+%s", attrs[3])
    self.handBookPanel.transform:FindChild("Main/NumText7"):GetComponent(Text).text = string.format("+%s%%", attrs[54]/10)
    self.handBookPanel.transform:FindChild("Main/NumText8"):GetComponent(Text).text = string.format("+%s%%", attrs[51]/10)
    self.handBookPanel.transform:FindChild("Main/NumText9"):GetComponent(Text).text = string.format("+%s%%", attrs[55]/10)
    self.handBookPanel.transform:FindChild("Main/Line1").gameObject:SetActive(true)
    self.handBookPanel.transform:FindChild("Main/Line2").gameObject:SetActive(true)
    local handbookNumByActiveEffectType = HandbookManager.Instance:GetHandbookNumByActiveEffectType(1)
    local handbookNumByStarEffectType = HandbookManager.Instance:GetHandbookNumByStarEffectType(1)
    self.handBookPanel.transform:FindChild("Main/StarText"):GetComponent(Text).text =
            string.format(TI18N("宠物图鉴已激活：<color='#ffff00'>%s</color>/%s\n1★图鉴已激活：<color='#ffff00'>%s</color>/%s")
                , self.model.cur_petdata.handbook_num, handbookNumByActiveEffectType, self.model.cur_petdata.star_handbook_num, handbookNumByStarEffectType)
    self.moreAttrText[1].text = string.format("%s：<color='#%s'>%s</color>/%s", DataItem.data_get[self.attriconList[1]].name, "ffff00", self.model.cur_petdata.max_phy_apt_used, 10)
    self.moreAttrText[2].text = string.format("%s：<color='#%s'>%s</color>/%s", DataItem.data_get[self.attriconList[2]].name, "ffff00", self.model.cur_petdata.max_pdef_apt_used, 10)
    self.moreAttrText[3].text = string.format("%s：<color='#%s'>%s</color>/%s", DataItem.data_get[self.attriconList[3]].name, "ffff00", self.model.cur_petdata.max_hp_apt_used, 10)
    self.moreAttrText[4].text = string.format("%s：<color='#%s'>%s</color>/%s", DataItem.data_get[self.attriconList[4]].name, "ffff00", self.model.cur_petdata.max_magic_apt_used, 10)
    self.moreAttrText[5].text = string.format("%s：<color='#%s'>%s</color>/%s", DataItem.data_get[self.attriconList[5]].name, "ffff00", self.model.cur_petdata.max_aspd_apt_used, 10)
    self.moreAttrText[6].text = string.format("%s：<color='#%s'>%s</color>/%s", DataItem.data_get[self.attriconList[6]].name, "ffff00", self.model.cur_petdata.use_growth, 10)
    self.moreAttrText[7].text = string.format("%s：<color='#%s'>%s</color>/%s", DataItem.data_get[self.attriconList[7]].name, "ffff00", self.model.cur_petdata.feed_point, 20)
end

function PetView_Base:hideHandBookPanel()
    self.handBookPanel:SetActive(false)
end

function PetView_Base:UpdateSpirtButtonEffect()   --可附灵
    local data = self.model.cur_petdata
    if data ~= nil then
        if #data.attach_pet_ids == 0 then
            -- if self.spirtButtonEffect == nil then
            --     local fun = function(effectView)
            --         local effectObject = effectView.gameObject

            --         effectObject.transform:SetParent(self.spirtButton.transform)
            --         effectObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
            --         effectObject.transform.localPosition = Vector3(63, 15, -400)
            --         effectObject.transform.localRotation = Quaternion.identity

            --         Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            --     end
            --     self.spirtButtonEffect = BaseEffectView.New({effectId = 20122, time = nil, callback = fun})
            -- else
            --     self.spirtButtonEffect:SetActive(true)
            -- end
            self.spirtButton.transform:Find("Arrow").gameObject:SetActive(true)
        elseif self.spirtButtonEffect ~= nil then
            -- self.spirtButtonEffect:SetActive(false)
        else
            self.spirtButton.transform:Find("Arrow").gameObject:SetActive(false)
        end
    elseif self.spirtButtonEffect ~= nil then
        -- self.spirtButtonEffect:SetActive(false)
        self.spirtButton.transform:Find("Arrow").gameObject:SetActive(false)
    end
end


function PetView_Base:CheckGuidePoint()
    if self.guideListInit == true and self.view_index == 1 and self.model.cur_petdata ~= nil and petEgg then
        table.sort(self.guideList,function(a,b)
            if a.index ~= b.index then
                return a.index > b.index
            else
                return false
            end
        end)

        for k,v in pairs(self.effectList) do
            v:SetActive(false)
        end
        for k,v in pairs(self.guideList) do
            if self:CheckQuestActiveById(v.id) then
                if (v.requireMent == nil or (v.requireMent ~= nil and v.requireMent() == true)) and v.gameObject ~= nil then

                    TipsManager.Instance:ShowGuide({gameObject = v.gameObject, data = TI18N(v.notice), forward = v.forward})
                    if v.effectMultiplex == true then

                        -- if self.effectList[v.effectId] ~= nil then
                        --     self.effectList[v.effectId].transform:SetParent(v.gameObject.transform)
                        --     self.effectList[v.effectId].transform.localScale = Vector3(v.effectScale[1],v.effectScale[2],v.effectScale[3])
                        --     self.effectList[v.effectId].transform.localPosition = Vector3(v.effectPosition[1],v.effectPosition[2],v.effectPosition[3])
                        --     self.effectList[v.effectId].transform.localRotation = Quaternion.identity
                        -- end

                        if self.effectList[v.id] == nil then

                            self.effectList[v.id] = BaseUtils.ShowEffect(v.effectId,v.gameObject.transform,Vector3(v.effectScale[1],v.effectScale[2],v.effectScale[3]), Vector3(v.effectPosition[1],v.effectPosition[2],v.effectPosition[3]))
                        else

                            self.effectList[v.id]:SetActive(true)
                        end

                    end
                    break
                end
            else
                GuideManager.Instance.effect:Hide()
            end

        end
    end
end

function PetView_Base:CheckQuestActiveById(id)

    local isGuidePoint = false
    local data = DataQuest.data_get[id]
    local questData = QuestManager.Instance:GetQuest(data.id)
    if questData ~= nil and questData.finish == 1 then
        isGuidePoint = true

    end
    return isGuidePoint
end
