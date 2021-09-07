-- ----------------------------------------------------------
-- UI - 宠物窗口 信息面板
-- ----------------------------------------------------------
PetReleasePanel = PetReleasePanel or BaseClass(BasePanel)

function PetReleasePanel:__init(parentPanel,petId,releaceType)
    self.name = "PetReleasePanel"
    self.resList = {
        {file = AssetConfig.pet_release_panel, type = AssetType.Main}
    }
    self.parentPanel = parentPanel
    self.petId = petId
    self.releaceType = releaceType

    self.gameObject = nil
    self.transform = nil
    self.init = false
end

function PetReleasePanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pet_release_panel))
    self.gameObject.name = "PetReleasePanel"
    -- self.gameObject.transform:SetParent(self.parent.mainTransform)
    -- self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    -- self.gameObject.transform.localScale = Vector3(1, 1, 1)

    -- self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    local btn = self.transform:Find("ReleasePanel"):GetComponent(Button)
    btn.onClick:AddListener(function() self:hidereleasepanel() end)

    btn = self.transform:Find("ReleasePanel/Main/CancelButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:hidereleasepanel() end)

    btn = self.transform:Find("ReleasePanel/Main/OkButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:releasepet() end)

    self.input_field = self.transform:Find("ReleasePanel/Main/InputCon"):FindChild("InputField"):GetComponent(InputField)

    self.init = true
end

function PetReleasePanel:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end
    self:AssetClearAll()
    self.gameObject = nil
end

function PetReleasePanel:OnInitCompleted()
end

-- function PetReleasePanel:releasebuttonclick()
--     -- connection.send(9900, {cmd = "获取宠物"})
--     if self.model.cur_petdata ~= nil then
--         if #self.model.petlist == 1 then
--             local data = NoticeConfirmData.New()
--             data.type = ConfirmData.Style.Sure
--             data.content = "你舍得抛弃最后的伙伴吗？"
--             data.sureLabel = "确认"
--             NoticeManager.Instance:ConfirmTips(data)
--         else
--             if self.model.cur_petdata.genre == 3 then
--                 local data = NoticeConfirmData.New()
--                 data.type = ConfirmData.Style.Normal
--                 data.content = string.format("你确定要将<color='#00ff00'>%s lv.%s</color>放生吗", self.model.cur_petdata.name, self.model.cur_petdata.lev)
--                 data.sureLabel = "确认"
--                 data.cancelLabel = "取消"
--                 data.sureCallback = function() PetManager.Instance:Send10522(self.model.cur_petdata.id)  end
--                 NoticeManager.Instance:ConfirmTips(data)
--             else
--                 self.transform:FindChild("ReleasePanel").gameObject:SetActive(true)
--                 local input_field = self.transform:FindChild("ReleasePanel/Main/InputCon"):FindChild("InputField"):GetComponent(InputField)
--                 input_field.textComponent = self.transform:FindChild("ReleasePanel/Main/InputCon/InputField/Text"):GetComponent(Text)
--                 input_field.text = ""
--             end
--         end
--     end
-- end

function PetReleasePanel:hidereleasepanel()
    self.input_field.text = ""
    self:Hiden()
    if self.parentPanel.petreleasepanel ~= nil then
        self.parentPanel.petreleasepanel = nil
    end
    self:DeleteMe()
end

function PetReleasePanel:releasepet()
    local str = string.lower(self.input_field.text)
    if str == "yes" then
        self:hidereleasepanel()
        if self.releaceType == nil or self.releaceType == 2 then
            PetManager.Instance:Send10522(self.petId)
        elseif self.releaceType == 1 then
            PetManager.Instance:Send10532(self.petId)
        end
        self.parentPanel:Reset()
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("放生需要输入“yes”进行确认"))
    end
end
