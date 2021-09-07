--author:zzl
--time:2017/2/13
--武道大会战绩item

WorldChampionWarRankItem = WorldChampionWarRankItem or BaseClass()

function WorldChampionWarRankItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.data = nil

    self.parent = parent

    self.transform = self.gameObject.transform
    self.TxtDay = self.transform:FindChild("TxtDay"):GetComponent(Text)
    self.ImgIcon = self.transform:FindChild("ImgIcon"):GetComponent(Image)
    self.TxtHead = self.transform:FindChild("TxtHead"):GetComponent(Text)
    self.TxtResult = self.transform:FindChild("TxtResult"):GetComponent(Text)
    self.ImgMvp = self.transform:FindChild("ImgMvp"):GetComponent(Image)
    self.BtnLook = self.transform:FindChild("BtnLook"):GetComponent(Button)
    self.item_index = 1
    self.BtnLook.onClick:AddListener(function()
        WorldChampionManager.Instance:Require16424(self.data.r_id,self.data.r_platform,self.data.r_zone_id)
    end)
end

--更新内容
function WorldChampionWarRankItem:update_my_self(_data, _index)
    if _index%2 == 0 then
        self.transform:GetComponent(Image).color = Color(157/255, 199/255, 237/255, 1)
    else
        self.transform:GetComponent(Image).color = Color(131/255, 180/255, 231/255, 1)
    end
    self.data = _data
    local cfgData =  DataTournament.data_list[self.data.rank_lev]
    self.TxtDay.text = self:GetTimeGone(self.data.time)
    self.TxtHead.text = cfgData.name
    if self.data.is_win == 1 then
        --胜
        self.TxtResult.text = TI18N("<color='#2F8F29'>胜利</color>")
    else
        --负
        self.TxtResult.text = TI18N("<color='#BE383C'>战败</color>")
    end
    local mvpSprite = ""
    if self.data.best_result == 1 then
        mvpSprite = "I18NGodLike"
    elseif self.data.best_result == 2 then
        mvpSprite = "Attacker"
    elseif self.data.best_result == 3 then
        mvpSprite = "Killer"
    elseif self.data.best_result == 4 then
        mvpSprite = "Mvp"
    elseif self.data.best_result == 5 then
        mvpSprite = "Defender"
    elseif self.data.best_result == 6 then
        mvpSprite = "Ctr"
    end
    if mvpSprite == "" then
        self.ImgMvp.gameObject:SetActive(false)
    else
        self.ImgMvp.sprite = self.parent.parent.assetWrapper:GetSprite(AssetConfig.no1inworld_textures , mvpSprite)
        self.ImgMvp.gameObject:SetActive(true)
    end
    self.ImgIcon.sprite = self.parent.parent.assetWrapper:GetSprite(AssetConfig.worldchampion_LevIcon , tostring(self.data.rank_lev))

    -- PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(cfgData.icon), cfgData.icon)
end

function WorldChampionWarRankItem:GetTimeGone(time)
    local day = tonumber(os.date("%d", BaseUtils.BASE_TIME))
    local dataday = tonumber(os.date("%d", time))
    local timestr = BaseUtils.BASE_TIME - time
    if day ~= dataday then
        timestr = string.format(TI18N("%s天前"), tostring( math.max(1,math.floor(timestr/(3600*24)))))
    elseif timestr > 3600 or math.ceil(timestr/(60)) > 0 then
        timestr = TI18N("今天")
    else
        timestr = TI18N("今天")
    end
    return timestr
end