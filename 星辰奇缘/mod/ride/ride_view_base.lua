-- ----------------------------------------------------------
-- UI - 坐骑窗口 信息面板
-- @ljh 2016.5.24
-- ----------------------------------------------------------
RideView_Base = RideView_Base or BaseClass(BasePanel)

function RideView_Base:__init(parent)
	self.parent = parent
    self.model = parent.model
    self.name = "RideView_Base"
    self.effect = nil
    self.effectPath = "prefabs/effect/20053.unity3d"
    self.resList = {
        {file = AssetConfig.ridewindow_base, type = AssetType.Main}
        , {file = AssetConfig.ride_texture, type = AssetType.Dep}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
        , {file = AssetConfig.dailyicon, type = AssetType.Dep}
        , {file = AssetConfig.bible_daily_gfit_bg2, type = AssetType.Dep}
        -- , {file = AssetConfig.base_textures, type = AssetType.Dep}
        , {file = AssetConfig.ridebg, type = AssetType.Dep}
        , {file = AssetConfig.wingsbookbg, type = AssetType.Dep}
        , {file = self.effectPath, type = AssetType.Main}
    }

    self.gameObject = nil
    self.transform = nil
    self.init = false

    ------------------------------------------------
    self.getEggPanel = nil
    self.eggPanel = nil
    self.basePanel = nil
    self.basePanel = nil
    self.skillPanel = nil
    self.clickBorn = false

    self.view_index = 1
    self.ride_goal_itemlist = {}
    self.skillList = {}
    self.equipList = {}
    self.equipIconList = {}

    self.attrItemList = {}

    self.slider1_tweenId = 0
    self.slider2_tweenId = 0

    self.getEggType = 0 -- 获取宠物蛋，0未达成条件，1达成条件，但没物品，2达成条件

    self.toHatchTips = {TI18N("每天完成以下战斗，将有几率可以获得<color='#ffff00'>灵犀值</color>，右方为每天可获得的上限：   ")
                    , ""
                    , TI18N("职业任务　<color='#00ff00'>20</color>　  宝图任务　<color='#00ff00'>20</color>")
                    , TI18N("野外挂机　<color='#00ff00'>100</color>　 上古封妖　<color='#00ff00'>10</color>")
                    , TI18N("世界boss  <color='#00ff00'>12</color>　  天空之塔　<color='#00ff00'>60</color>")
                    , TI18N("悬赏　　　<color='#00ff00'>100</color>　 荣耀试炼　<color='#00ff00'>60</color>")
                    , TI18N("公会强盗　<color='#00ff00'>10</color>　  历练任务　<color='#00ff00'>50</color>")
                    , TI18N("副本战斗　<color='#00ff00'>10</color>　  竞技场　　<color='#00ff00'>30</color>")
                }

    -- self.skillTips = {"1、宠物技能数不足<color='#ffff00'>4个</color>时，战斗和升级有几率领悟技能"
    --             , "2、打书可为宠物<color='#ffff00'>增加</color>技能，也有几率<color='#ffff00'>覆盖</color>当前已有技能"
    --             , "3、当前技能（符石技能除外）达到<color='#ffff00'>4</color>个，打书不再增加技能数量"
    --             , "4、使用<color='#ffff00'>天赋异禀</color>可以随机习得一个<color='#ffff00'>天生技能</color>(已拥有的天生技能除外)，其中特殊技能概率较大"}

    self.select_skillId = nil
    self.last_skill_id = nil

    self.itemSolt = nil

    self.eggTipsPanel = nil
    self.sliderEffect = nil
    self.sliderEffect2 = nil
    ------------------------------------------------
    self._update = function() self:update() end

    self._gem_off = function(id) self:gem_off(id) end
    self._gem_replace = function(id) self:gem_replace(id) end
    self.calculateTime = function(time) self:CalculateTime(time) end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function RideView_Base:InitPanel()

	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.ridewindow_base))
    self.gameObject.name = "RideView_Base"
    self.gameObject.transform:SetParent(self.parent.mainTransform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform
    -- self.transform:SetAsFirstSibling()

    self.getEggPanel = self.transform:FindChild("GetEggPanel").gameObject
    self.eggPanel = self.transform:FindChild("EggPanel").gameObject
    self.basePanel = self.transform:FindChild("BaseInformationPanel").gameObject
    self.timeText = self.transform:FindChild("BaseInformationPanel/TimeText"):GetComponent(Text)
    self.timeText.gameObject:SetActive(false)

   self.transfigurationButton = self.transform:FindChild("BaseInformationPanel/ModelPanel/TransfigurationButton"):GetComponent(Button)
   self.transfigurationButton.onClick:AddListener(function() self:TransfigurationButtonClick() end)

   self.transfigurationImage = self.transform:FindChild("BaseInformationPanel/ModelPanel/TransfigurationButton"):GetComponent(Image)

    self.basePanel.transform:Find("ModelPanel/Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.ridebg, "RideBg")
    self.eggPanel.transform:Find("Bg1"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.bible_daily_gfit_bg2, "DailyGiftBigBg")
    self.eggPanel.transform:Find("Bg2"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.getEggPanel.transform:Find("Bg1"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.bible_daily_gfit_bg2, "DailyGiftBigBg")
    self.getEggPanel.transform:Find("Bg2"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")

    self.growPanel =self.basePanel.transform:Find("AttrPanel/Grow")
    self.attrMask = self.basePanel.transform:Find("AttrPanel/Mask")
    self.speedAttrObj = self.basePanel.transform:Find("AttrPanel/SpeedAttrObject")
    self.levelAttrObject = self.basePanel.transform:Find("AttrPanel/LevelAttrObject")

    self.attrItemClone = self.basePanel.transform:Find("AttrPanel/Mask/Panel/AttrObject").gameObject
    self.attrItemClone:SetActive(false)
    
    self.mulityplayerimg = self.basePanel.transform:Find("MulityPlayer")
    self.mulityplayertext = self.basePanel.transform:Find("MulityplayerText")

    if self.imgLoader == nil then
        local go = self.basePanel.transform:Find("InfoPanel/ExpGroup/Icon").gameObject
        self.imgLoader = SingleIconLoader.New(go)
    end
    self.imgLoader:SetSprite(SingleIconType.Item, 90021)

    -- 按钮功能绑定
    local btn
    btn = self.getEggPanel.transform:FindChild("OkButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:getEgg() end)

    self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    self.effect.transform:SetParent(btn.gameObject.transform)
    self.effect.transform.localScale = Vector3(1.8, 0.8, 1)
    self.effect.transform.localPosition = Vector3(-58, -19, -500)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect:SetActive(false)

    btn = self.basePanel.transform:FindChild("ToUseButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:toUse() end)

    self.washBtn = self.basePanel.transform:FindChild("WashButton"):GetComponent(Button)
    self.washBtn.onClick:AddListener(function() self:toWash() end)

    btn = self.basePanel.transform:FindChild("InfoPanel/ExpGroup/Button"):GetComponent(Button)
    btn.onClick:AddListener(function() self:selectItem_exp() end)

    btn = self.basePanel.transform:FindChild("InfoPanel/ExpGroup/ExpText"):GetComponent(Button)
    btn.onClick:AddListener(function() self:selectItem_exp() end)

    -- btn = self.basePanel.transform:FindChild("AttrPanel/Button"):GetComponent(Button)
    -- btn.onClick:AddListener(function() self:selectItem_growth() end)

    btn = self.getEggPanel.transform:FindChild("Preview").gameObject:AddComponent(Button)
    btn.onClick:AddListener(function() self:PlayEggAction() end)

    btn = self.eggPanel.transform:FindChild("Preview").gameObject:AddComponent(Button)
    btn.onClick:AddListener(function() self:EggModelClick() end)

    btn = self.basePanel.transform:FindChild("ToDyeButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:toDye() end)
    self.dyeButton = btn
    self.dyeButton.gameObject:SetActive(false)

    self.itemSlot = ItemSlot.New()
    UIUtils.AddUIChild(self.getEggPanel.transform:FindChild("ItemSolt").gameObject, self.itemSlot.gameObject)

    self.breakEggText = MsgItemExt.New(self.eggPanel.transform:FindChild("BreakEgg/Text"):GetComponent(Text), 240, 18, 23)
    self.eggPanel.transform:FindChild("EggDesc/DescText1"):GetComponent(Text).text = TI18N("1、灵犀值<color='#ffff00'>大于500</color>后，每次增加都有<color='#ffff00'>一定几率</color>孵化")
    self.eggPanel.transform:FindChild("EggDesc/DescText2"):GetComponent(Text).text = TI18N("2、灵犀值达到<color='#ffff00'>1000</color>时，坐骑必定孵化")
    self.eggTipsPanel = self.eggPanel.transform:FindChild("TipsPanel").gameObject
    self.eggTipsPanel:GetComponent(Button).onClick:AddListener(function() self.eggTipsPanel:SetActive(false) end)

    -- local list = {1000, 0, 1004, 1001, 1}
    local list = {1, 2, 3, 4, 5, 6, 7, 8, 9}
    for i=1, #list do
        local id = list[i]
        local btn = self.eggPanel.transform:FindChild(string.format("Mask/Container/Btn%s", i))
        btn:GetComponent(Button).onClick:AddListener(function()
            self:toHatch(id, btn)
        end)
    end

    -- 初始化宝石图标
    local stonePanel = self.basePanel.transform:FindChild("EquipPanel/panel").gameObject
    for i=1, 2 do

        local slot = ItemSlot.New()
        table.insert(self.equipIconList, slot)
        slot.gameObject.name = "item_slot"
        local stone = stonePanel.transform:FindChild("gem"..i).gameObject
        stone.name = tostring(i)
        UIUtils.AddUIChild(stone, slot.gameObject)
        table.insert(self.equipList, stone)
        stone:GetComponent(Button).onClick:AddListener(function() self:onequipclick(stone) end)
        slot.gameObject:GetComponent(Button).onClick:AddListener(function() self:onequipclick(slot.gameObject) end)

    end

    --------------------------------------------
    self.init = true
    self:OnShow()
    self:ClearMainAsset()
end

function RideView_Base:__delete()
    if self.itemSlot ~= nil then
        self.itemSlot:DeleteMe()
        self.itemSlot = nil
    end

    if self.firstEffect ~= nil then
        self.firstEffect:DeleteMe()
        self.firstEffect = nil
    end

    for k,v in pairs(self.equipIconList) do
        v:DeleteMe()
        v = nil
    end

    self:OnHide()
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end
    if self.gameObject ~= nil then
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function RideView_Base:OnInitCompleted()

end

function RideView_Base:OnShow()
    if BaseUtils.IsIPhonePlayer() then
        self.parent.cacheMode = CacheMode.Destroy
    else
        self.parent.cacheMode = CacheMode.Visible
    end
    if self.firstEffect ~= nil then
        self.firstEffect:DeleteMe()
        self.firstEffect = nil
    end
    RideManager.Instance.OnUpdateRide:Remove(self._update)
	RideManager.Instance.OnUpdateRide:Add(self._update)
    RideManager.Instance.OnUpdateOneRide:Remove(self._update)
    RideManager.Instance.OnUpdateTime:RemoveListener(self.calculateTime)
    RideManager.Instance.OnUpdateOneRide:Add(self._update)
    RideManager.Instance.OnUpdateTime:AddListener(self.calculateTime)
    self:update()
end

function RideView_Base:OnHide()
    RideManager.Instance.OnUpdateRide:Remove(self._update)
    RideManager.Instance.OnUpdateOneRide:Remove(self._update)
    RideManager.Instance.OnUpdateTime:RemoveListener(self.calculateTime)

    if self.effectTimerId ~= nil then
        LuaTimer.Delete(self.effectTimerId)
        self.effectTimerId = nil
    end

    if self.expSlider_tweenId ~= nil then
        Tween.Instance:Cancel(self.expSlider_tweenId)
        self.expSlider_tweenId = nil
    end

     if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function RideView_Base:update()
    if self.model.cur_ridedata == nil then return end

    if self.model.cur_ridedata.live_status == 0 then
        self.view_index = 0
        self.basePanel:SetActive(false)
        self.getEggPanel:SetActive(true)
        self.eggPanel:SetActive(false)

        self:update_getEggPanel()
    elseif self.model.cur_ridedata.live_status == 1 or self.model.cur_ridedata.live_status == 2 then
    	self.view_index = 0
    	self.basePanel:SetActive(false)
        self.getEggPanel:SetActive(false)
    	self.eggPanel:SetActive(true)

        self:update_eggPanel()
    else
        if self.view_index ~= 1 then
            -- 状态切换的时候检查标签显示
            self.parent:CheckIsEgg()
        end

    	self.view_index = 1
    	self.basePanel:SetActive(true)
        self.getEggPanel:SetActive(false)
    	self.eggPanel:SetActive(false)
    end

    self.select_skillItem = nil

	if self.view_index == 1 then
    	self:update_model()
        self:update_baseattrs()
        self:updata_info()
        self:updata_equip()

        if DataMount.data_ride_dye[self.model.cur_ridedata.transformation_id] == nil then
            self.dyeButton.gameObject:SetActive(false)
        else
            self.dyeButton.gameObject:SetActive(true)
        end
    end

    if DataMount.data_ride_data[self.model.cur_ridedata.transformation_id] ~= nil and DataMount.data_ride_data[self.model.cur_ridedata.transformation_id].multiplayer == 1 then
        self.mulityplayerimg.gameObject:SetActive(true)
        self.mulityplayertext.gameObject:SetActive(true)
    else
        self.mulityplayerimg.gameObject:SetActive(false)
        self.mulityplayertext.gameObject:SetActive(false)
    end

end

function RideView_Base:update_getEggPanel()
    local rideData = self.model.cur_ridedata


    if rideData.base.ride_goal_list == nil then
        Log.Error("坐骑系统，服务端数据有问题，live_status为0")
        return
    end

    local myIndex = rideData.base.ride_goal_list[1].day
    BaseUtils.dump(rideData,"此时的坐骑信息===========================================================================")

    local mark = false -- 是否有
    local key = string.format("%s_%s", 0, myIndex)
    local cost = DataMount.data_ride_lev[key].lev_cost[1]

    local itembase = BackpackManager.Instance:GetItemBase(cost[1])

    local itemData = ItemData.New()
    itemData:SetBase(itembase)
    self.itemData = itemData
    self.itemSlot:SetAll(itemData)

    local num = BackpackManager.Instance:GetItemCount(cost[1])
    self.getEggPanel.transform:FindChild("ItemNameText"):GetComponent(Text).text = itemData.name
    local color = "#00ff00"
    if num < cost[2] then
        color = "#ff0000"
    end
    self.getEggPanel.transform:FindChild("ItemNumText"):GetComponent(Text).text = string.format("<color='%s'>%s</color>/%s", color, num, cost[2])

    local container = self.getEggPanel.transform:FindChild("Panel/Mask/Container")
    local clone = container.transform:FindChild("Item").gameObject
    clone:SetActive(false)
    -- 处理一般条件
    for i=1, #rideData.base.ride_goal_list do
        local item = self.ride_goal_itemlist[i]
        if item == nil then
            item = GameObject.Instantiate(clone)
            item:SetActive(true)
            item.transform:SetParent(container)
            item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
            self.ride_goal_itemlist[i] = item
        end
        item.gameObject:SetActive(true)

        local ride_goal_data = rideData.base.ride_goal_list[i]
        item.transform:FindChild("Text"):GetComponent(Text).text = ride_goal_data.desc

        local ride_goal = self.model:get_ride_goal(ride_goal_data.id)
        if ride_goal == nil or ride_goal.finish == 0 then
            mark = true
            item.transform:FindChild("PointImage"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "RedPoint")
            item.transform:FindChild("StateImage").gameObject:SetActive(false)
            item.transform:FindChild("StateText").gameObject:SetActive(true)
        else
            item.transform:FindChild("PointImage"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "greenpoint")
            item.transform:FindChild("StateImage").gameObject:SetActive(true)
            item.transform:FindChild("StateText").gameObject:SetActive(false)
        end
    end

    if #rideData.base.ride_goal_list < #self.ride_goal_itemlist then
        for i=#rideData.base.ride_goal_list + 1,#self.ride_goal_itemlist do
            self.ride_goal_itemlist[i].gameObject:SetActive(false)
        end
    end
    -- 处理特殊条件物品需求
    -- local i = #rideData.base.ride_goal_list + 1
    -- local item = self.ride_goal_itemlist[i]
    -- if item == nil then
    --     item = GameObject.Instantiate(clone)
    --     item:SetActive(true)
    --     item.transform:SetParent(container)
    --     item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
    --     self.ride_goal_itemlist[i] = item
    -- end

    -- item.transform:FindChild("Text"):GetComponent(Text).text = string.format("拥有%s个%s", cost[2], itemData.name)

    -- if num < cost[2] then
    --     item.transform:FindChild("PointImage"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "RedPoint")
    --     item.transform:FindChild("StateImage").gameObject:SetActive(false)
    --     item.transform:FindChild("StateText").gameObject:SetActive(true)
    -- else
    --     item.transform:FindChild("PointImage"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "greenpoint")
    --     item.transform:FindChild("StateImage").gameObject:SetActive(true)
    --     item.transform:FindChild("StateText").gameObject:SetActive(false)
    -- end

    self.effect:SetActive(false)
    if mark then
        self.getEggType = 0
        self.getEggPanel.transform:FindChild("OkButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        self.getEggPanel.transform:Find("OkButton/Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton1Str, TI18N("激活坐骑"))
    elseif num < cost[2] then
        self.getEggType = 1
        self.getEggPanel.transform:FindChild("OkButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        self.getEggPanel.transform:Find("OkButton/Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton1Str, TI18N("激活坐骑"))
    else
        self.getEggType = 2
        self.getEggPanel.transform:FindChild("OkButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        self.getEggPanel.transform:Find("OkButton/Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton2Str, TI18N("激活坐骑"))
        self.effect:SetActive(true)
    end

    local preview = self.getEggPanel.transform:FindChild("Preview")
    local data = {type = PreViewType.Npc, skinId = 40063, modelId = 40063, animationId = 4006301, scale = 2.5, isGetEgg = true}
    if rideData.index == 3 then
        data.skinId = 40163
    end
    self.parent:load_preview(preview, data)
end

function RideView_Base:update_eggPanel()
    local rideData = self.model.cur_ridedata

    local max = 1000
    if rideData.live_status == 1 then
        self.eggPanel.transform:FindChild("ExpGroup/ExpText"):GetComponent(Text).text = string.format("%s/%s", rideData.fight_times, max)
        self.eggPanel.transform:FindChild("ExpGroup/ExpSlider"):GetComponent(Slider).value = rideData.fight_times / max

        if BaseUtils.is_null(self.sliderEffect) then
            local fun = function(effectView)
                local effectObject = effectView.gameObject

                self.sliderEffect = effectObject

                effectObject.transform:SetParent(self.eggPanel.transform:FindChild("ExpGroup/ExpSlider/Handle Slide Area/Handle"))
                effectObject.transform.localScale = Vector3(1, 1, 1)
                effectObject.transform.localPosition = Vector3(0, 0, -400)
                effectObject.transform.localRotation = Quaternion.identity

                Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            end
            self.sliderEffect = BaseEffectView.New({effectId = 20161, time = nil, callback = fun})
        else
            self.sliderEffect:SetActive(true)
        end

        if not BaseUtils.is_null(self.sliderEffect2) then
            self.sliderEffect2:SetActive(false)
        end

        self.eggPanel.transform:FindChild("EggDesc").gameObject:SetActive(true)
        self.eggPanel.transform:FindChild("BreakEgg").gameObject:SetActive(false)

    else
        self.eggPanel.transform:FindChild("ExpGroup/ExpText"):GetComponent(Text).text = ""
        self.eggPanel.transform:FindChild("ExpGroup/ExpSlider"):GetComponent(Slider).value = 1

        if BaseUtils.is_null(self.sliderEffect2) then
            local fun = function(effectView)
                local effectObject = effectView.gameObject

                self.sliderEffect2 = effectObject

                effectObject.transform:SetParent(self.eggPanel.transform:FindChild("ExpGroup/ExpSlider"))
                effectObject.transform.localScale = Vector3(1.05, 1.3, 1)
                effectObject.transform.localPosition = Vector3(-238, 0, -400)
                effectObject.transform.localRotation = Quaternion.identity

                Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            end
            self.sliderEffect2 = BaseEffectView.New({effectId = 20173, time = nil, callback = fun})
        else
            self.sliderEffect2:SetActive(true)
        end

        if not BaseUtils.is_null(self.sliderEffect) then
            self.sliderEffect:SetActive(false)
        end

        self.eggPanel.transform:FindChild("EggDesc").gameObject:SetActive(false)
        self.eggPanel.transform:FindChild("BreakEgg").gameObject:SetActive(true)
        self.breakEggText:SetData(TI18N("坐骑蛋可孵化啦，快点击它孵化吧{face_1,9} "))
    end

    if rideData.live_status == 1 then
        if BaseUtils.is_null(self.egg_effect1) then
            local fun = function(effectView)
                if self.eggPanel ~= nil then
                    local effectObject = effectView.gameObject

                    self.egg_effect1 = effectObject

                    effectObject.transform:SetParent(self.eggPanel.transform:FindChild("Preview"))
                    effectObject.transform.localScale = Vector3.one
                    effectObject.transform.localPosition = Vector3(160, 90, -1000)
                    effectObject.transform.localRotation = Quaternion.identity

                    Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                end
            end
            self.egg_effect1 = BaseEffectView.New({effectId = 20171, time = nil, callback = fun})
        else
            self.egg_effect1:SetActive(true)
        end
        if not BaseUtils.is_null(self.egg_effect2) then
            self.egg_effect2:SetActive(false)
        end
    else
        if BaseUtils.is_null(self.egg_effect2) then
            local fun = function(effectView)
                local effectObject = effectView.gameObject

                self.egg_effect2 = effectObject

                effectObject.transform:SetParent(self.eggPanel.transform:FindChild("Preview"))
                effectObject.transform.localScale = Vector3.one
                effectObject.transform.localPosition = Vector3(0, 90, -1000)
                effectObject.transform.localRotation = Quaternion.identity

                Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            end
            self.egg_effect2 = BaseEffectView.New({effectId = 20172, time = nil, callback = fun})
        else
            self.egg_effect2:SetActive(true)
        end
        if not BaseUtils.is_null(self.egg_effect1) then
            self.egg_effect1:SetActive(false)
        end
    end

    local preview = self.eggPanel.transform:FindChild("Preview")
    local data = {type = PreViewType.Npc, skinId = 40063, modelId = 40063, animationId = 4006301, scale = 2.5, isEgg = true}
    if rideData.index == 3 then
        data.skinId = 40163
    end
    self.parent:load_preview(preview, data)
end

function RideView_Base:update_model()
    local transform = self.basePanel.transform
    local preview = transform:FindChild("ModelPanel/Preview")
    local rideData = self.model.cur_ridedata

    -- local ride_look = rideData.base.base_id
    -- local ride_jewelry1 = 0
    -- local ride_jewelry2 = 0
    -- if rideData.transformation_id == 0 then
    --     for _,value in ipairs(rideData.decorate_list) do
    --         if value.decorate_index == 1 and value.is_hide == 0 then
    --             ride_jewelry1 = value.decorate_base_id
    --         elseif value.decorate_index == 2 and value.is_hide == 0 then
    --             ride_jewelry2 = value.decorate_base_id
    --         end
    --     end
    -- else
    --     ride_look = rideData.transformation_id
    -- end

    -- local data = {type = PreViewType.Ride, classes = 1, sex = 1, looks = {}, scale = 1, effects = {}}
    -- table.insert(data.looks, { looks_type = SceneConstData.looktype_ride, looks_val = ride_look })
    -- table.insert(data.looks, { looks_type = SceneConstData.looktype_ride_jewelry1, looks_val = ride_jewelry1 })
    -- table.insert(data.looks, { looks_type = SceneConstData.looktype_ride_jewelry2, looks_val = ride_jewelry2 })
    local data = self.model:MakeRideLook(rideData)
    self.parent:load_preview(preview, data)
end

function RideView_Base:updata_info()
	local transform = self.basePanel.transform
    local rideData = self.model.cur_ridedata
    local gameObject = transform:FindChild("ModelPanel").gameObject
    -- local now_ride_data = DataMount.data_ride_data[string.format("%s_%s", rideData.mount_base_id, rideData.lev)]

    gameObject.transform:FindChild("PointText"):GetComponent(Text).text = tostring(rideData.score * 5)

    local isActive = false
    local myTransfigurationData = nil
    local myRideTransfData = DataMount.data_ride_transf_data[rideData.transformation_id]
    if myRideTransfData ~= nil then
        isActive = true
        myTransfigurationData = RideManager.Instance.model:GetTransfigurationData(rideData.transformation_id)
    end

    if isActive then
        if myTransfigurationData == nil then
            self.transfigurationButtonStatus = false
        else
            if myTransfigurationData.evolution_id == myRideTransfData.evolution_id then
                self.transfigurationButtonStatus = true
            else
                self.transfigurationButtonStatus = false
            end
        end

        if self.transfigurationButtonStatus == false then
            self.transfigurationImage.sprite = self.assetWrapper:GetSprite(AssetConfig.ride_texture,"RunI18N")
        elseif self.transfigurationButtonStatus == true then
            self.transfigurationImage.sprite = self.assetWrapper:GetSprite(AssetConfig.ride_texture,"StandI18N")
        end
        self.transfigurationButton.gameObject:SetActive(true)
    else
        self.transfigurationButton.gameObject:SetActive(false)
    end

    gameObject.transform:FindChild("LevText"):GetComponent(Text).text = string.format(TI18N("等级:%s"), rideData.lev)

     if self.model.cur_ridedata ~= nil then
        if DataMount.data_ride_new_data[self.model.cur_ridedata.mount_base_id] ~= nil then
            gameObject.transform:FindChild("LevText").gameObject:SetActive(false)
        else
            gameObject.transform:FindChild("LevText").gameObject:SetActive(true)
        end
     end
    -- gameObject.transform:FindChild("PowerText"):GetComponent(Text).text = string.format("%s/%s", rideData.spirit, now_ride_data.max_spirit)

    gameObject = transform:FindChild("InfoPanel/ExpGroup").gameObject
    gameObject.gameObject:SetActive(true)

    if self.model.cur_ridedata ~= nil and DataMount.data_ride_new_data[self.model.cur_ridedata.mount_base_id] ~= nil then
            gameObject.gameObject:SetActive(false)
     end

    local rideData_max = 500
    -- gameObject.transform:FindChild("ExpSlider"):GetComponent(Slider).value = rideData.spirit / rideData_max
    if self.expSlider_tweenId ~= nil then
        Tween.Instance:Cancel(self.expSlider_tweenId)
        self.expSlider_tweenId = nil
    end
    local expSlider = gameObject.transform:FindChild("ExpSlider"):GetComponent(Slider)
    local fun = function(value) expSlider.value = value end
    self.expSlider_tweenId = Tween.Instance:ValueChange(expSlider.value, rideData.spirit / rideData_max, 0.3, nil, LeanTweenType.linear, fun).id

    gameObject.transform:FindChild("ExpText"):GetComponent(Text).text = string.format("%s/%s", rideData.spirit, rideData_max)

    if rideData.spirit < 50 then
        transform:FindChild("InfoPanel/DescText"):GetComponent(Text).text = TI18N("精力值过低，宠物契约已失效")
        transform:FindChild("InfoPanel/DescText").gameObject:SetActive(true)

        gameObject.transform:FindChild("ExpSlider/Fill Area/Fill"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "ProgressBar2")
    else
        transform:FindChild("InfoPanel/DescText").gameObject:SetActive(false)
        gameObject.transform:FindChild("ExpSlider/Fill Area/Fill"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "ProgressBar1")
    end

    local btn_text = TI18N("骑 乘")
    if rideData.index == self.model.ride_mount then
        btn_text = TI18N("下 骑")
        transform:FindChild("ToUseButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        transform:Find("ToUseButton/Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton1Str, btn_text)
    else
        transform:FindChild("ToUseButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        transform:Find("ToUseButton/Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton2Str, btn_text)
    end
    -- transform:FindChild("ToUseButton/Text"):GetComponent(Text).text = btn_text
end

function RideView_Base:updata_equip()
    local rideData = self.model.cur_ridedata

    if rideData ~= nil then
        local stonedata = nil
        local equipIcon = nil
        for i=1,#self.equipList do
            self.equipList[i].name = tonumber(i)
            self.equipIconList[i].gameObject:SetActive(false)
            self.equipList[i].gameObject:SetActive(true)
        end


        for i=1,#rideData.decorate_list do
            stonedata = rideData.decorate_list[i]
            equipIcon = self.equipIconList[stonedata.decorate_index]

            local ride_jewelry = DataMount.data_ride_jewelry[stonedata.decorate_base_id]
            if ride_jewelry == nil then break end
            local itembase = BackpackManager.Instance:GetItemBase(ride_jewelry.item_id)
            local itemData = ItemData.New()
            itemData:SetBase(itembase)
            equipIcon:SetAll(itemData)
            equipIcon:SetNotips(true)

            self.equipList[stonedata.decorate_index].name = "equip"
            equipIcon.gameObject.name = string.format("equip_%s", stonedata.decorate_index)
            equipIcon.gameObject:SetActive(true)

        end


        self.washBtn.gameObject:SetActive(true)
        --新加
        if self.model.cur_ridedata ~= nil then
            if DataMount.data_ride_new_data[self.model.cur_ridedata.mount_base_id] ~= nil then
                self.equipList[1].gameObject:SetActive(false)
                self.washBtn.gameObject:SetActive(false)
            end
        end
    end
end

function RideView_Base:update_baseattrs()
    local transform = self.basePanel.transform
    local rideData = self.model.cur_ridedata
    local gameObject = transform:FindChild("AttrPanel").gameObject
    if rideData ~= nil then
        if DataMount.data_ride_new_data[rideData.mount_base_id] ~= nil then
            RideManager.Instance:Send17028()
            -- self:CalculateTime()
            -- self.timeText.gameObject:SetActive(true)
        else
            self.timeText.gameObject:SetActive(false)
            self:EndTime()
        end
    end


    if self.model.cur_ridedata.index == 3 then
        gameObject.transform:GetChild(1):GetComponent(Text).text = TI18N("加成宠物属性")
    else
        gameObject.transform:GetChild(1):GetComponent(Text).text = TI18N("坐骑属性")
    end

    gameObject.transform:FindChild("LevelAttrObject/NameText"):GetComponent(Text).text = TI18N("等级:")
    gameObject.transform:FindChild("LevelAttrObject/ValueText"):GetComponent(Text).text = tostring(rideData.lev)

    local attr_list = self.model:get_ride_all_attr_val(rideData.mount_base_id)
    local speed_attr = rideData.base.speed_attr[1]
    if rideData.transformation_id ~= 0 and DataMount.data_ride_data[rideData.transformation_id] ~= nil then
        speed_attr = DataMount.data_ride_data[rideData.transformation_id].speed_attr[1]
    end
    local item = gameObject.transform:FindChild("SpeedAttrObject").gameObject
    item.transform:FindChild("NameText"):GetComponent(Text).text = TI18N("移动速度:")
    item.transform:FindChild("ValueText"):GetComponent(Text).text = string.format("%s", speed_attr.val1)
    item.transform:FindChild("Icon"):GetComponent(Image).sprite
        = self.assetWrapper:GetSprite(AssetConfig.attr_icon, string.format("AttrIcon%s", tostring(KvData.attr_icon[speed_attr.attr_name])))

    -- table.insert(attr_list, { key = speed_attr.attr_name, value = speed_attr.val1 })
    -- for i=1, #attr_list do
    --     local item = gameObject.transform:FindChild(string.format("AttrObject%s", i+1)).gameObject
    --     item.gameObject:SetActive(true)

    --     if attr_list[i].key == 12 then
    --         item.transform:FindChild("NameText"):GetComponent(Text).text = TI18N("移动速度:")
    --         item.transform:FindChild("ValueText"):GetComponent(Text).text = string.format("%s", attr_list[i].value)
    --     else
    --         if string.len(KvData.GetAttrName(attr_list[i].key)) > 6 then
    --             item.transform:FindChild("ValueText").sizeDelta = Vector2(101, 27)
    --             item.transform:FindChild("ValueText").anchoredPosition = Vector2(97, 0)
    --         end
    --         item.transform:FindChild("NameText"):GetComponent(Text).text = string.format("%s:", KvData.GetAttrName(attr_list[i].key))
    --         item.transform:FindChild("ValueText"):GetComponent(Text).text = math.ceil(attr_list[i].value)
    --     end
    --     item.transform:FindChild("Icon"):GetComponent(Image).sprite
    --         = self.assetWrapper:GetSprite(AssetConfig.attr_icon, string.format("AttrIcon%s", tostring(KvData.attr_icon[attr_list[i].key])))
    -- end

    -- if #attr_list < 4 then
    --     for i=#attr_list+1, 4 do
    --         gameObject.transform:FindChild(string.format("AttrObject%s", i+1)).gameObject:SetActive(false)
    --     end
    -- end

    for i=1, #attr_list do
        item = self.attrItemList[i]
        if item == nil then
            item = GameObject.Instantiate(self.attrItemClone)
            item:SetActive(true)
            item.transform:SetParent(gameObject.transform:Find("Mask/Panel"))
            item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
            self.attrItemList[i] = item
        end

        item:SetActive(true)
        if string.len(KvData.GetAttrName(attr_list[i].key)) > 6 then
            item.transform:FindChild("ValueText").sizeDelta = Vector2(101, 27)
            item.transform:FindChild("ValueText").anchoredPosition = Vector2(97, 0)
        else
            item.transform:FindChild("ValueText").sizeDelta = Vector2(128.2, 27)
            item.transform:FindChild("ValueText").anchoredPosition = Vector2(72.2, 0)
        end
        item.transform:FindChild("NameText"):GetComponent(Text).text = string.format("%s:", KvData.GetAttrName(attr_list[i].key))
        item.transform:FindChild("ValueText"):GetComponent(Text).text = math.ceil(attr_list[i].value)

        item.transform:FindChild("Icon"):GetComponent(Image).sprite
            = self.assetWrapper:GetSprite(AssetConfig.attr_icon, string.format("AttrIcon%s", tostring(KvData.attr_icon[attr_list[i].key])))
    end

    if #attr_list < #self.attrItemList then
        for i=#attr_list+1, #self.attrItemList do
            item = self.attrItemList[i]
            if item ~= nil then
                item:SetActive(false)
            end
        end
    end

    gameObject.transform:FindChild("Grow/GrowthValueText"):GetComponent(Text).text = string.format("%.2f", rideData.growth)
    gameObject.transform:FindChild("Grow/GrowthIcon"):GetComponent(Image).sprite
            = self.assetWrapper:GetSprite(AssetConfig.ride_texture, string.format("RideGrowth%s", rideData.growth))


    if self.model.cur_ridedata ~= nil and DataMount.data_ride_new_data[self.model.cur_ridedata.mount_base_id] ~= nil then
        self.growPanel.gameObject:SetActive(false)
        self.levelAttrObject.gameObject:SetActive(false)
        self.speedAttrObj.transform.anchoredPosition = Vector2(-28.7,57)
        self.attrMask.transform.anchoredPosition = Vector2(-17.3,-25)
        self.attrMask.transform.sizeDelta = Vector2(213,131)
        self.attrMask.transform:GetComponent(ScrollRect).movementType = ScrollRect.MovementType.Clamped

    else
        self.growPanel.gameObject:SetActive(true)
        self.levelAttrObject.gameObject:SetActive(true)
        self.speedAttrObj.transform.anchoredPosition = Vector2(-28.7,-10.5)
        self.attrMask.transform.anchoredPosition = Vector2(-17.3,-81.975)
        self.attrMask.transform.sizeDelta = Vector2(213,111)
        self.attrMask.transform:GetComponent(ScrollRect).movementType = ScrollRect.MovementType.Elastic
    end

end

function RideView_Base:toHatch(id, btn)
    -- WindowManager.Instance:CloseWindowById(WindowConfig.WinID.ridewindow)
    -- if id == 0 then
    --     AgendaManager.Instance.model:OpenWindow({2})
    -- elseif id == 1 then
    --     WindowManager.Instance:OpenWindowById(WindowConfig.WinID.trialwindow)
    -- else
    --     AgendaManager.Instance.model:DoDaily(id)
    -- end
    -- AgendaManager.Instance.model:OpenWindow()

    -- TipsManager.Instance:ShowText({gameObject = btn.gameObject, itemData = self.toHatchTips})

    local str1 = ""
    local str2 = ""
    local str3 = ""
    local str4 = ""
    for i, data in ipairs(DataMount.data_ride_combat_egg_val) do
        if i % 2 == 1 then
            str1 = string.format("%s%s\n", str1, data.desc)
            local num = self.model:get_ride_combat_active_times(data.combat_type)
            if num < data.active_times then
                str2 = string.format("%s<color='#00ff00'>%s/%s</color>\n", str2, data.val*num, data.val*data.active_times)
            else
                str2 = string.format("%s<color='#ffff00'>%s/%s</color>\n", str2, data.val*num, data.val*data.active_times)
            end
        else
            str3 = string.format("%s%s\n", str3, data.desc)
            local num = self.model:get_ride_combat_active_times(data.combat_type)
            if num < data.active_times then
                str4 = string.format("%s<color='#00ff00'>%s/%s</color>\n", str4, data.val*num, data.val*data.active_times)
            else
                str4 = string.format("%s<color='#ffff00'>%s/%s</color>\n", str4, data.val*num, data.val*data.active_times)
            end
        end
    end
    self.eggTipsPanel.transform:FindChild("Main"):GetChild(1):GetComponent(Text).text = str1
    self.eggTipsPanel.transform:FindChild("Main"):GetChild(2):GetComponent(Text).text = string.format("%s", str2)
    self.eggTipsPanel.transform:FindChild("Main"):GetChild(3):GetComponent(Text).text = str3
    self.eggTipsPanel.transform:FindChild("Main"):GetChild(4):GetComponent(Text).text = string.format("%s", str4)

    self.eggTipsPanel:SetActive(true)
end

function RideView_Base:getEgg()
    if self.getEggType == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("达成所有条件可激活"))
    elseif self.getEggType == 1 then
        local name = ""
        if self.model.cur_ridedata.base.ride_goal_list[1].day == 100 then
            name = "<color='#ffff00'>试用坐骑</color>道具不足"
        else
            name = "<color='#ffff00'>认主灵石</color>道具不足"
        end
        NoticeManager.Instance:FloatTipsByString(name)
        self.itemSlot:SureClick()
    elseif self.getEggType == 2 then
        if self.model.cur_ridedata.base.ride_goal_list[1].day == 100 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rideChooseWindow,{1})
        else
            RideManager.Instance:Send17009()
        end
    end
end

function RideView_Base:toUse()
	if self.model.cur_ridedata ~= nil then
		if self.model.cur_ridedata.index == self.model.ride_mount then
		    RideManager.Instance:Send17001(0)
		else

            if DataMount.data_ride_new_data[self.model.cur_ridedata.base.base_id] ~= nil then
                RideManager.Instance:Send17001(100)
            else
		        RideManager.Instance:Send17001(self.model.cur_ridedata.index)
            end
		end
    end
end

function RideView_Base:toWash()
    if self.model.cur_ridedata ~= nil then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ridewash)
    end
end

function RideView_Base:toDye()
    if self.model.cur_ridedata ~= nil then
        SceneManager.Instance.sceneElementsModel:Self_PathToTarget("6_1")
        self.parent:OnClickClose()
    end
end

function RideView_Base:onequipclick(gameobject)
	self.model.select_equip = tonumber(gameobject.name)

    if self.model.cur_ridedata ~= nil then
        if self.model.select_equip == 1 or self.model.select_equip == 2 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rideequip, { self.model.select_equip, 0 })
        elseif gameobject.name == "equip_1" then
            local equipIcon = self.equipIconList[1]
            local decorate_data = nil
            for i, data in ipairs(self.model.cur_ridedata.decorate_list) do
                if data.decorate_index == 1 then
                    decorate_data = data
                end
            end
            BaseUtils.dump(decorate_data, "decorate_data")
            equipIcon.extra = { decorate_data = decorate_data, index = self.model.cur_ridedata.index }
            TipsManager.Instance:ShowRideEquip(equipIcon)
        elseif gameobject.name == "equip_2" then
            local equipIcon = self.equipIconList[2]
            equipIcon.extra = nil
            TipsManager.Instance:ShowRideEquip(equipIcon)
        end
    end
end

function RideView_Base:onskillclick(gameobject)
	if self.model.cur_ridedata ~= nil then
		self.select_skillId = tonumber(gameobject.name)

		if self.select_skillItem ~= nil then
			self.select_skillItem.transform:FindChild("Select").gameObject:SetActive(false)
		end

		self.select_skillItem = gameobject
		self.select_skillItem.transform:FindChild("Select").gameObject:SetActive(true)

		self:update_skillInfo()
	end
end

function RideView_Base:selectItem_exp()
    -- if self.useItemPanel == nil then
    --     self.useItemPanel = RideUseItemPanel.New(self)
    -- end
    -- self.useItemPanel:Show()
    self.parent.cacheMode = CacheMode.Visible
    self.model:OpenRideFeedPanel()
    -- local fun = function(gameObject)
    --     local list = StringHelper.Split(gameObject.name, "_")
    --     if list ~= nil and list[2] ~= nil then
    --         RideManager.Instance:Send17003(self.model.cur_ridedata.index, tonumber(list[2]))
    --     end
    -- end

    -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.selectitem, { fun, 1, { 23555 } })
end

function RideView_Base:close_selectItem_exp()
    if self.useItemPanel ~= nil then
        self.useItemPanel:DeleteMe()
        self.useItemPanel = nil
    end
end

function RideView_Base:selectItem_growth()
    local fun = function(gameObject)
        local list = StringHelper.Split(gameObject.name, "_")
        if list ~= nil and list[2] ~= nil then
            RideManager.Instance:Send16403(self.model.cur_ridedata.index, tonumber(list[2]))
        end
    end

    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.selectitem, { fun, 1, { 23552 } })
end

function RideView_Base:PlayEggAction()
    local animationData = DataAnimation.data_npc_data[4006301]
    self.parent.previewComposite.tpose:GetComponent(Animator):Play(string.format("Idle%s", animationData.idle_id))
end

function RideView_Base:EggModelClick()
    local rideData = self.model.cur_ridedata
    if rideData.live_status == 1 then
        self:PlayEggAction()
    else
        if self.clickBorn == false then
            self.clickBorn = true
            LuaTimer.Add(2400, function()
                        self.parent:OnClickClose()
                        RideManager.Instance:Send17010()
                    end)
        end

        local fun = function(effectView)
            local effectObject = effectView.gameObject

            effectObject.transform:SetParent(self.eggPanel.transform:FindChild("Preview"))
            effectObject.transform.localScale = Vector3.one
            effectObject.transform.localPosition = Vector3(0, -50, -1000)
            effectObject.transform.localRotation = Quaternion.identity

            Utils.ChangeLayersRecursively(effectObject.transform, "UI")

            SoundManager.Instance:Play(231)
        end
        if rideData.index == 3 then
            BaseEffectView.New({effectId = 20358, time = 2400, callback = fun})
        else
            BaseEffectView.New({effectId = 20169, time = 2400, callback = fun})
        end
    end
end

function RideView_Base:CalculateTime(myTime)

  self.timestamp = myTime
  if self.timerId  == nil then
    self.timerId = LuaTimer.Add(0, 1000, function() self:TimeLoop() end)
  end
  self.timeText.gameObject:SetActive(true)
end

function RideView_Base:TimeLoop()
    if self.timestamp > 0 then
        local h = math.floor(self.timestamp / 3600)
        local mm = math.floor((self.timestamp - (h * 3600)) / 60 )
        self.timeText.text = "剩余时间:" .. h .. "时" .. mm .. "分"
        self.timestamp = self.timestamp - 1
    else
        self:EndTime()
    end
end

function RideView_Base:EndTime()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function RideView_Base:TransfigurationButtonClick()


    if self.transfigurationButtonStatus == false then
        local myTransfigurationData = RideManager.Instance.model:GetTransfigurationData(self.model.cur_ridedata.transformation_id)
        if myTransfigurationData ~= nil then
             if self.firstEffect == nil then
                self.firstEffect = BibleRewardPanel.ShowEffect(20436, self.transform:FindChild("BaseInformationPanel/ModelPanel/Preview").gameObject.transform, Vector3.one, Vector3(0,-50, -400))
            end
             self.firstEffect:SetActive(false)
            self.firstEffect:SetActive(true)

            self.effectTimerId = LuaTimer.Add(1000, function() self:TimerDelay() end)
        else
            self.parent.tabGroup:ChangeTab(5,true)
        end
    elseif self.transfigurationButtonStatus == true then
        if self.firstEffect == nil then
            self.firstEffect = BibleRewardPanel.ShowEffect(20436, self.transform:FindChild("BaseInformationPanel/ModelPanel/Preview").gameObject.transform, Vector3.one, Vector3(0,-50, -400))
        end
        self.firstEffect:SetActive(false)
        self.firstEffect:SetActive(true)

        self.effectTimerId = LuaTimer.Add(1000, function() self:TimerDelay() end)
    end
end


function RideView_Base:TimerDelay()
    RideManager.Instance:Send17030(DataMount.data_ride_transf_data[self.model.cur_ridedata.transformation_id].base_id)
end

