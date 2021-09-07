-- 公会战，自己公会对战信息面板
-- @author zgs
GuildfightMinePanel = GuildfightMinePanel or BaseClass(BasePanel)

function GuildfightMinePanel:__init(model,parent)
    self.model = model
    self.parent = parent
    self.name = "GuildfightMinePanel"

    self.buffItemObjList = {}

    self.resList = {
        {file = AssetConfig.guild_fight_mine_panel, type = AssetType.Main}
        ,{file  =  AssetConfig.guild_dep_res, type  =  AssetType.Dep}
        , {file = AssetConfig.guild_totem_icon, type = AssetType.Dep}
        ,{file = AssetConfig.guild_fight_big_bg, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }
    self.OnOpenEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        self:UpdateWindow()
    end)
end

function GuildfightMinePanel:OnInitCompleted()
    --self.showType = self.openArgs[1]
    self:UpdateWindow()
end

function GuildfightMinePanel:__delete()
    if self.bev ~= nil then
        self.bev:DeleteMe()
    end
    self.OnOpenEvent:RemoveAll()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.model = nil
end

function GuildfightMinePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_fight_mine_panel))
    UIUtils.AddUIChild(self.parent, self.gameObject)
    local rect = self.gameObject:GetComponent(RectTransform)
    rect.offsetMin = Vector2(0,-7)
    rect.offsetMax = Vector2(0,-7)
    self.transform = self.gameObject.transform

    self.timeText = self.transform:Find("TimeBgImage/TimeText"):GetComponent(Text)
    local obj = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_fight_big_bg))
    UIUtils.AddBigbg(self.transform:Find("CenterBgImage/Bg"), obj)
    obj.transform.localScale = Vector3(1.1, 1.8, 1)
    self.transform:Find("CenterBgImage/Bg"):GetComponent(RectTransform).anchoredPosition = Vector2(11,22)

    self.leftText = self.transform:Find("CenterBgImage/LText"):GetComponent(Text)
    self.leftTextSecond = self.transform:Find("CenterBgImage/LTextSecond"):GetComponent(Text)
    self.rightText = self.transform:Find("CenterBgImage/RText"):GetComponent(Text)
    self.rightTextSecond = self.transform:Find("CenterBgImage/RTextSecond"):GetComponent(Text)
    self.leftImage = self.transform:Find("CenterBgImage/LeftImage"):GetComponent(Image)
    self.rightImage = self.transform:Find("CenterBgImage/RightImage"):GetComponent(Image)

    self.button = self.transform:Find("Button"):GetComponent(Button)
    self.button.onClick:AddListener(function ()
        self:onClickBtn()
    end)

    self.vsImageObj = self.transform:Find("CenterBgImage/VsImage")
    local fun = function(effectView)
        local effectObject = effectView.gameObject

        effectObject.transform:SetParent(self.vsImageObj)
        effectObject.transform.localScale = Vector3(1, 1, 1)
        effectObject.transform.localPosition = Vector3(0, 0, -1000)
        effectObject.transform.localRotation = Quaternion.identity

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
        effectObject:SetActive(true)
    end
    self.bev = BaseEffectView.New({effectId = 20135, time = nil, callback = fun})
end

function GuildfightMinePanel:getGuildFightData()
    local myGuildFightData = {}
    local othenGuildFightData = {}
    local isCheck = false
    local isMy_side_1 = false
    for i,v in ipairs(GuildfightManager.Instance.myGuildFightList) do
        if v.side == 1 then
            table.insert(myGuildFightData,v)
            if isCheck == false then
                isCheck = true
                isMy_side_1 = false
                for j,vv in ipairs(v.gids) do
                    if vv.guild_id == GuildManager.Instance.model.my_guild_data.GuildId
                        and vv.platform == GuildManager.Instance.model.my_guild_data.PlatForm
                        and vv.zone_id == GuildManager.Instance.model.my_guild_data.ZoneId then
                        isMy_side_1 = true
                    end
                end
            end
        else
            table.insert(othenGuildFightData,v)
        end
    end
    if isMy_side_1 == true then
        return myGuildFightData,othenGuildFightData
    else
        return othenGuildFightData,myGuildFightData
    end
end

function GuildfightMinePanel:UpdateWindow()
    local dataList = GuildfightManager.Instance.myGuildFightList
    -- BaseUtils.dump(dataList,"GuildfightMinePanel:UpdateWindow")
    if dataList == nil or #dataList ~= 2 then
        -- Log.Error("公会对阵信息出错")
        return
    end
    local weekday = tonumber(os.date("%w",BaseUtils.BASE_TIME))
    if weekday > 2 and weekday <=4 then
        self.timeText.text = TI18N("<color='#ffff00'>周四 晚上20:00</color>")
    else
        self.timeText.text = TI18N("<color='#ffff00'>周二 晚上20:00</color>")
    end
    local myGuildFightData, othenGuildFightData = self:getGuildFightData()
    -- BaseUtils.dump(myGuildFightData,"local myGuildFightData, othenGuildFightData 1===")
    -- BaseUtils.dump(othenGuildFightData,"local myGuildFightData, othenGuildFightData 1===")
    self.leftText.text = myGuildFightData[1].names[1].name
    if myGuildFightData[1].names[2] == nil then
        self.leftTextSecond.text = ""
        self.leftImage.gameObject:SetActive(true)
        self.leftImage.sprite = self.assetWrapper:GetSprite(AssetConfig.guild_totem_icon , tostring(myGuildFightData[1].totems[1].totem))
        self.leftImage:SetNativeSize()
    else
        self.leftImage.gameObject:SetActive(false)
        self.leftTextSecond.text = myGuildFightData[1].names[2].name
    end
    self.rightText.text = othenGuildFightData[1].names[1].name
    if othenGuildFightData[1].names[2] == nil then
        self.rightTextSecond.text = ""
        self.rightImage.gameObject:SetActive(true)
        self.rightImage.sprite = self.assetWrapper:GetSprite(AssetConfig.guild_totem_icon , tostring(othenGuildFightData[1].totems[1].totem))
        self.rightImage:SetNativeSize()
    else
        self.rightImage.gameObject:SetActive(false)
        self.rightTextSecond.text = othenGuildFightData[1].names[2].name
    end
    -- if GuildfightManager.Instance.mode == 1 then
    --     --初赛
    -- else
    -- end

end
--立即参赛
function GuildfightMinePanel:onClickBtn(itemDic)
    -- GuildfightManager.Instance:send15502()
    GuildfightManager.Instance:GuildFightCheckIn()
    self.model:CloseMain()
end


