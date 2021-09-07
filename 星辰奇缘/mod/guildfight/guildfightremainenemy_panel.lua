-- 公会战剩余敌人面板
-- @author zgs
GuildfightRemainEnemyPanel = GuildfightRemainEnemyPanel or BaseClass(BasePanel)

function GuildfightRemainEnemyPanel:__init(model)
    self.model = model
    self.name = "GuildfightRemainEnemyPanel"

    self.resList = {
        {file = AssetConfig.guild_fight_remain_enemy_panel, type = AssetType.Main},
        {file = AssetConfig.heads, type = AssetType.Dep}

    }
    self.OnOpenEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        self:UpdatePanel()
    end)
    self.OnHideEvent:AddListener(function()
        self:DeleteMe()
    end)

    self.itemList = {}

    self.begin_fightFun = function ()
        self:Hiden()
    end
    EventMgr.Instance:AddListener(event_name.begin_fight, self.begin_fightFun)
end

function GuildfightRemainEnemyPanel:OnInitCompleted()
    --self.showType = self.openArgs[1]
    self:UpdatePanel()
end

function GuildfightRemainEnemyPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self.begin_fightFun)
    self.OnOpenEvent:RemoveAll()
    self.OnHideEvent:RemoveAll()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.model.guild_fight_remain_enemy_panel = nil
    self.model = nil
end

function GuildfightRemainEnemyPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_fight_remain_enemy_panel))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.closeBtn = self.transform:Find("MainCon/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function()
        self:OnClickClose()
    end)

    self.scorllObj = self.transform:Find("MainCon/InBgImage/ScrollPanel").gameObject
    local layoutContainer = self.transform:Find("MainCon/InBgImage/ScrollPanel/Grid")
    self.layout = LuaBoxLayout.New(layoutContainer.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 4})
    self.item = layoutContainer:Find("Item").gameObject
    self.item:SetActive(false)

    self.noneObj = self.transform:Find("MainCon/InBgImage/NoneObj").gameObject
    self.noneObj:SetActive(false)

    self:DoClickPanel()
end

function GuildfightRemainEnemyPanel:OnClickClose()
    self:Hiden()
end

function GuildfightRemainEnemyPanel:DoClickPanel()
    if self.gameObject ~= nil then
        local panel = self.gameObject.transform:FindChild("Panel")
        if panel ~= nil then
            local panelBut = panel:GetComponent(Button)
            if panelBut ~= nil then
                local onClick = function()
                    self:Hiden()
                end
                panelBut.onClick:AddListener(onClick)
            end
        end
    end
end

function GuildfightRemainEnemyPanel:UpdatePanel()
    if GuildfightManager.Instance.enemyInfo ~= nil and #GuildfightManager.Instance.enemyInfo > 0 then
        self.scorllObj:SetActive(true)
        self.noneObj:SetActive(false)
        for i,data in ipairs(GuildfightManager.Instance.enemyInfo) do
            local itemTemp = self.itemList[i]
            if itemTemp == nil then
                local obj = GameObject.Instantiate(self.item)
                obj:SetActive(true)
                obj.name = tostring(i)

                self.layout:AddCell(obj)
                local itemDic = {
                    index = i,
                    thisObj = obj,
                    dataItem = data,
                    headImg = obj.transform:Find("Head"):GetComponent(Image),
                    nameTxt = obj.transform:Find("name"):GetComponent(Text),
                    levTxt = obj.transform:Find("LevText"):GetComponent(Text),
                    classIcon = obj.transform:Find("ClassIcon"):GetComponent(Image),
                    -- sigTxt = obj.transform:Find("SigText"):GetComponent(Text),
                    button = obj.transform:Find("Button"):GetComponent(Button),
                    selectObj = obj.transform:Find("Select").gameObject,
                }

                itemDic.button.onClick:AddListener(function ()
                    --战斗
                    GuildfightManager.Instance:send15504(data.rid, data.platform, data.zone_id)
                    -- self:Hiden()
                end)

                itemTemp = itemDic
                self.itemList[i] = itemTemp
            end
            itemTemp.thisObj:SetActive(true)
            itemTemp.headImg.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex)
            itemTemp.nameTxt.text = data.name
            itemTemp.levTxt.text = tostring(data.lev)
            itemTemp.classIcon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(data.classes))
            -- itemTemp.sigTxt.text = "无"
            -- if data.signature ~= "" then
            --     itemTemp.sigTxt.text = data.signature
            -- end
        end

        for i=#GuildfightManager.Instance.enemyInfo + 1,#self.itemList do
            local item = self.itemList[i]
            if item ~= nil and item.thisObj ~= nil then
                item.thisObj:SetActive(false)
            end
        end
    else
        self.scorllObj:SetActive(false)
        self.noneObj:SetActive(true)
    end

end
