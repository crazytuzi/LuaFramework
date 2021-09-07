--称号
BackPackHuoLiItem = BackPackHuoLiItem or BaseClass()

function BackPackHuoLiItem:__init(gameObject, args)
    self.gameObject = gameObject
    self.data = nil
    self.args = args

    self.transform = self.gameObject.transform
    self.SlotCon = self.transform:FindChild("SlotCon")
    self.Head = self.SlotCon:FindChild("Head"):GetComponent(Image)
    self.ImgName = self.transform:FindChild("ImgName"):GetComponent(Image)
    self.Txt_lev = self.transform:FindChild("Txt_lev"):GetComponent(Text)
    self.Txt_desc = self.transform:FindChild("Txt_desc"):GetComponent(Text)

    self.huoli_open_desc_list = {
        [10000]= TI18N("可进行栽培")
        ,[10001]= TI18N("可研制魔药")
        ,[10002]= TI18N("可制作工艺品")
        ,[10005]= TI18N("可进行打造")
        ,[10006]= TI18N("可进行裁缝")
        ,[10007]= TI18N("可进行制作")
    }

    self.huoli_unopen_desc_list = {
        [10000]= TI18N("技能等级不足，无法栽培")
        ,[10001]= TI18N("技能等级不足，无法研制")
        ,[10002]= TI18N("技能等级不足，无法制作")
        ,[10005]= TI18N("技能等级不足，无法打造")
        ,[10006]= TI18N("技能等级不足，无法裁缝")
        ,[10007]= TI18N("技能等级不足，无法制作")
    }

    self.x_ys = {
        [10000] = {x = 76, y = 24},
        [10001] = {x = 76, y = 24},
        [10005] = {x = 76, y = 20},
        [10006] = {x = 76, y = 20},
        [10007] = {x = 76, y = 20}
    }

    self.transform:GetComponent(Button).onClick:AddListener(function() self:on_click_myself() end)
end

function BackPackHuoLiItem:Release()

end

function BackPackHuoLiItem:InitPanel(_data)
    self.data = _data.data
    self.Head.sprite = self.args.assetWrapper:GetSprite(AssetConfig.skill_life_icon, tostring(self.data.id))
    self.ImgName.sprite = self.args.assetWrapper:GetSprite(AssetConfig.skill_life_name, tostring(self.data.id))
    -- self.ImgName:SetNativeSize()
    self.ImgName.transform:GetComponent(RectTransform).sizeDelta = Vector2(self.x_ys[self.data.id].x, self.x_ys[self.data.id].y)

    self.Txt_lev.text = string.format("Lv.%s", self.data.lev)

    if #self.data.product == 0 then
        self.Txt_desc.text = self.huoli_unopen_desc_list[self.data.id]
    else
        self.Txt_desc.text = self.huoli_open_desc_list[self.data.id]
    end
end

function BackPackHuoLiItem:Refresh(args)
    self.args = args
end

function BackPackHuoLiItem:on_click_myself()
    if #self.data.product == 0 then
        --打开学习界面
        -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.skill, {tab=3, id = self.data.id})
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.skill, {3})
    else
        --打开栽培界面
        SkillManager.Instance.model.life_produce_data = self.data
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.skill_life_produce)
    end
end