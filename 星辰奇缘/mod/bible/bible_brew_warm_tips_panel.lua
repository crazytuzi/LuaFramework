BibleBrewWarmTipsPanel  =  BibleBrewWarmTipsPanel or BaseClass(BasePanel)

function BibleBrewWarmTipsPanel:__init(model)
    self.name  =  "BibleBrewWarmTipsPanel"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.bible_warm_tips_panel, type  =  AssetType.Main}
        ,{file = AssetConfig.bible_textures, type = AssetType.Dep}
    }

    self.is_open  =  false

    self.max_ok_num = 1
    self.data_list = nil
    self.data_index = 1
    return self
end


function BibleBrewWarmTipsPanel:__delete()
    self.data_list = nil
    self.data_index = 1
    self.is_open  =  false
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function BibleBrewWarmTipsPanel:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.bible_warm_tips_panel))
    self.gameObject.name  =  "BibleBrewWarmTipsPanel"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.MainCon = self.transform:Find("MainCon")

    self.ImgBg1 = self.MainCon:Find("ImgBg1").gameObject
    self.ImgBg1_close_btn = self.ImgBg1.transform:Find("closeBtn"):GetComponent(Button)
    self.ImgBg2 = self.MainCon:Find("ImgBg2").gameObject

    self.ImgBg1_btn = self.ImgBg1.transform:GetComponent(Button)
    self.ImgBg2_btn = self.ImgBg2.transform:GetComponent(Button)

    self.TxtDesc1 = self.ImgBg1.transform:Find("TxtDesc"):GetComponent(Text)
    self.TxtDesc2 = self.ImgBg2.transform:Find("TxtDesc"):GetComponent(Text)

    self.TxtDesc1.text = ""
    self.TxtDesc2.text = ""

    self.TxtDesc1_Msg = MsgItemExt.New(self.TxtDesc1, 202, 16, 23)
    self.TxtDesc2_Msg = MsgItemExt.New(self.TxtDesc2, 202, 16, 23)

    local rect = self.MainCon:GetComponent(RectTransform)

    self.ImgBg1_close_btn.onClick:AddListener(function()
        self.model:CloseWarmTipsUI()
    end)

    self.ImgBg1_btn.onClick:AddListener(function()
        self.data_index = self.data_index + 1
        if self.data_index > #self.data_list then
            self.model:CloseWarmTipsUI()
            return
        end
        if #self.data_list == 0 then
            return
        end
        self.TxtDesc1_Msg:SetData(self.data_list[self.data_index].content)
        -- self.TxtDesc1.text = self.data_list[self.data_index].content
    end)
    self.ImgBg2_btn.onClick:AddListener(function()
        self.data_index = self.data_index + 1
        if self.data_index > #self.data_list then
            self.model:CloseWarmTipsUI()
            BibleManager.Instance:start_timer(3600)
            return
        end
        if #self.data_list == 0 then
            return
        end
        self.TxtDesc2_Msg:SetData(self.data_list[self.data_index].content)
        -- self.TxtDesc2.text = self.data_list[self.data_index].content
    end)

    self.ImgBg1:SetActive(false)
    self.ImgBg2:SetActive(false)

    if self.model.warm_tips_type == 1 then
        rect.anchoredPosition = Vector2(-87.6, -169.7)
        self.ImgBg1:SetActive(true)
    else
        rect.anchoredPosition = Vector2(-112, 157)
        self.ImgBg2:SetActive(true)
    end

    self.is_open  =  true

    --更新内容
    self:update_info()
end

--更新显示内容
function BibleBrewWarmTipsPanel:update_info()
    self.data_index = 1
    self.data_list = self:build_data_list()

    if #self.data_list == 0 then
        return
    end

    -- self.TxtDesc1.text = self.data_list[self.data_index].content
    -- self.TxtDesc2.text = self.data_list[self.data_index].content
    self.TxtDesc1_Msg:SetData(self.data_list[self.data_index].content)
    self.TxtDesc2_Msg:SetData(self.data_list[self.data_index].content)
end

--构造符合条件的数据列表
function BibleBrewWarmTipsPanel:build_data_list()
    local ok_list = self.model:Get_Warm_Tips_List()

    local show_list = nil
    if #ok_list > self.max_ok_num then
        show_list = {}
        --超过最大条数，则从ok_list中随机选出max_ok_num个出来显示
        local rand_index = Random.Range(1,  #ok_list)
        --从rand_index开始向后取
        for i=1,self.max_ok_num do
            if rand_index < 0 then
                rand_index = #ok_list
            end
            table.insert(show_list, ok_list[rand_index])
            rand_index = rand_index - 1
        end
    else
        show_list = ok_list
    end

    return show_list
end