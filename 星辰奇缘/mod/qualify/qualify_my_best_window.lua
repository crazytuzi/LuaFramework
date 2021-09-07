QualifyMyBestWindow  =  QualifyMyBestWindow or BaseClass(BasePanel)

function QualifyMyBestWindow:__init(model)
    self.name  =  "QualifyMyBestWindow"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.qualifying_mybest, type  =  AssetType.Main}
        ,{file  =  AssetConfig.qualifying_lev_icon, type  =  AssetType.Dep}
        ,{file  =  AssetConfig.stongbg, type  =  AssetType.Dep}
    }

    return self
end


function QualifyMyBestWindow:__delete()
    self.bigbg.sprite = nil
    self.ImgLeftIcon.sprite = nil
    self.is_open  =  false
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function QualifyMyBestWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.qualifying_mybest))
    self.gameObject.name  =  "QualifyMyBestWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.MainCon = self.transform:FindChild("MainCon")

    -- 大图 hosr
    self.bigbg = self.MainCon:Find("Bg"):GetComponent(Image)
    self.bigbg.sprite = self.assetWrapper:GetSprite(AssetConfig.stongbg, "StoneBg")

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseQualifyMyBestUI() end)


    self.CloseButton =  self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    self.CloseButton.onClick:AddListener(function() self.model:CloseQualifyMyBestUI() end)


    self.ImgLeftIconCon = self.MainCon:FindChild("ImgLeftIconCon")
    self.ImgLeftIcon = self.ImgLeftIconCon:FindChild("ImgLeftIcon"):GetComponent(Image)
    self.TxtLeftIconName = self.ImgLeftIconCon:FindChild("TxtLeftIconName"):GetComponent(Text)
    self.TxtLeftIconPoint = self.ImgLeftIconCon:FindChild("TxtLeftIconPoint"):GetComponent(Text)

    self.Txt1 = self.MainCon:FindChild("Txt1"):GetComponent(Text)  --我的最高段位：<color="#d781f2">华贵铂金V</color>
    self.Txt2 = self.MainCon:FindChild("Txt2"):GetComponent(Text)  --赛季结算时间：2016/06/30
    self.Txt3 = self.MainCon:FindChild("Txt3"):GetComponent(Text)  --25天


    self.TxtLeftIconName.text = ""
    self.TxtLeftIconPoint.text = ""
    self.Txt1.text = ""
    self.Txt2.text = ""
    self.Txt3.text = ""

    self:update_info()
end

--更新内容
function QualifyMyBestWindow:update_info()
    local cfg_data = self.model:get_cfg_data_by_point(self.model.mine_qualify_data.season_max_rank_point)
    local duanwei_name = cfg_data.lev_name
    self.ImgLeftIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.qualifying_lev_icon,tostring(cfg_data.rank_type))

    self.ImgLeftIcon.gameObject:SetActive(true)

    self.TxtLeftIconName.text = duanwei_name -- 段位新人
    self.TxtLeftIconPoint.text = tostring(self.model.mine_qualify_data.season_max_rank_point) --2070
    self.Txt1.text = string.format("%s<color='#d781f2'>%s</color>", TI18N("我的最高段位："), duanwei_name)

    local left_time = self.model.season_time - BaseUtils.BASE_TIME
    local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(left_time)
    self.Txt3.text = string.format("%s%s", my_date, TI18N("天"))




    local time = os.date("*t", self.model.season_time)
    local month = time.month < 10 and string.format("0%s",time.month) or time.month
    local day = time.day < 10 and string.format("0%s", time.day) or time.day
    self.Txt2.text = string.format("<color='#13fc60'>%s%s/%s/%s</color>", TI18N("赛季结算时间："), time.year, month, day)
end