GuildApplyListWindow  =  GuildApplyListWindow or BaseClass(BaseWindow)

function GuildApplyListWindow:__init(model)
    self.name  =  "GuildApplyListWindow"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.guild_apply_list_win, type  =  AssetType.Main}
    }

    self.freshCdTime = 3
    self.list_has_init = false
    -- return self
end

function GuildApplyListWindow:__delete()
    self.is_open = false
    self.list_has_init = false
    self.freshCdTime = 3
    self:stop_timer()

    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function GuildApplyListWindow:InitPanel()
    if self.gameObject ~= nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_apply_list_win))
    self.gameObject.name = "GuildApplyListWindow"

    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.is_open = true

    self.MainCon = self.gameObject.transform:FindChild("MainCon").gameObject

    local CloseBtn =  self.MainCon.transform:FindChild("CloseButton"):GetComponent(Button)
    CloseBtn.onClick:AddListener(function() self.model:CloseApplyListUI()   end)

    self.BtnClear = self.MainCon.transform:FindChild("BtnClear"):GetComponent(Button)
    self.BtnFlesh = self.MainCon.transform:FindChild("BtnFlesh"):GetComponent(Button)

    self.BtnFleshTxt = self.BtnFlesh.transform:FindChild("Text"):GetComponent(Text)

    self.enableImg = self.BtnClear.image.sprite
    self.unEnableImg = self.BtnFlesh.image.sprite
    self.BtnFlesh.image.sprite = self.enableImg

    self.ApplyListCon = self.MainCon.transform:FindChild("ApplyListCon").gameObject
    self.MaskLayer = self.ApplyListCon.transform:FindChild("MaskLayer").gameObject
    self.ScrollLayer = self.MaskLayer.transform:FindChild("ScrollLayer").gameObject
    self.vScroll = self.ScrollLayer:GetComponent(LVerticalScrollRect)

    self.BtnClear.onClick:AddListener(function() self:on_btn_click(1) end)
    self.BtnFlesh.onClick:AddListener(function() self:on_btn_click(2) end)


    -- 非依赖资源，UI创建完就可以卸载
    self:ClearMainAsset()

    GuildManager.Instance:request11123()
end

local flesh_timer = nil
function GuildApplyListWindow:on_btn_click(index)
    if self.model:get_my_guild_post() < self.model.member_positions.elder then
        NoticeManager.Instance:FloatTipsByString(TI18N("权限不足无法操作"))
        return
    end
    if index == 1 then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("点击将清空申请列表中的所有申请信息，是否继续？")
        data.sureLabel = TI18N("清空")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function() GuildManager.Instance:request11127()  end
        NoticeManager.Instance:ConfirmTips(data)
    elseif index == 2 then
        self.BtnFlesh.enabled = false
        self.BtnFlesh.image.sprite = self.unEnableImg

        self:stop_timer()
        LuaTimer.Add(0, 1000, function(id) self:tick_cd_timer(id) end)

        GuildManager.Instance:request11123()
    end
end

function GuildApplyListWindow:tick_cd_timer(id)
    self.timer_id = id

    self.freshCdTime = self.freshCdTime - 1
    if self.freshCdTime < 0 then
        self.freshCdTime = 3
        -- self.BtnFleshTxt.fontSize = 20
        self.BtnFleshTxt.text = TI18N("刷新列表")

        self.BtnFlesh.enabled = true
        self.BtnFlesh.image.sprite = self.enableImg
        self:stop_timer()
        return
    end
    -- self.BtnFleshTxt.fontSize = 16
    self.BtnFleshTxt.text = string.format("%s(%s)",TI18N("刷新列表"),self.freshCdTime)
end

function GuildApplyListWindow:stop_timer()
    if self.timer_id ~= nil and self.timer_id ~= 0 then
        LuaTimer.Delete(self.timer_id)
        self.timer_id = 0
    end
end


function GuildApplyListWindow:update_apply_list()
    if self.vScroll == nil then
        return
    end
    if self.list_has_init == false then
        local GetData = function(index)
            return {item_index = index+1, data = self.model.apply_list[index+1]}
        end
        self.vScroll:SetPoolInfo(#self.model.apply_list, "GuildApplyListItem", GetData, {assetWrapper = self.assetWrapper})
        self.list_has_init = true
    else
        self.vScroll:RefreshList(#self.model.apply_list)
    end
end