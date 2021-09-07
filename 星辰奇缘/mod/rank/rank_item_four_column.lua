RankItemFourColumn = RankItemFourColumn or BaseClass()

function RankItemFourColumn:__init(model, gameObject, assetWrapper)
    self.assetWrapper = assetWrapper
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform
    local t = self.transform
    self.img = self.gameObject:GetComponent(Image)
    self.rankText = t:Find("RankValue"):GetComponent(Text)
    self.rankImage = t:Find("RankValue/RankImage"):GetComponent(Image)
    self.rankCampImage = t:Find("RankValue/Camp"):GetComponent(Image)
    self.nameText = t:Find("Character/Name"):GetComponent(Text)
    self.centernameText = t:Find("Character/CenterName"):GetComponent(Text)
    self.iconObj = t:Find("Character/Icon").gameObject
    self.characterImage = t:Find("Character/Icon/Image"):GetComponent(Image)
    t:Find("Character/Icon/Image"):GetComponent(RectTransform).localScale = Vector2(1.1,1.1)
    self.name2Text = t:Find("Character2/Name"):GetComponent(Text)
    self.centername2Text = t:Find("Character2/CenterName"):GetComponent(Text)
    self.character2Obj = t:Find("Character2").gameObject
    self.icon2Obj = t:Find("Character2/Icon").gameObject
    self.character2Image = t:Find("Character2/Icon/Image"):GetComponent(Image)
    self.jobText = t:Find("Job"):GetComponent(Text)
    self.scoreText = t:Find("Score"):GetComponent(Text)
    self.bgObj = t:Find("Bg").gameObject
    self.bgObj:SetActive(false)
    self.selectObj = t:Find("Select").gameObject
    self.button = self.gameObject:GetComponent(Button)
    self.Subbutton = self.transform:Find("Button"):GetComponent(Button)
    self.playing = false
    self.data = nil

    self.listener = function(singdata, playing)
        self:SwitchPlayBtn(singdata, playing)
    end
end

function RankItemFourColumn:update_my_self(data, index)

    if data.virtual == true then
        self.gameObject:SetActive(false)
        self.isVirtual = true
        return
    else
        self.gameObject:SetActive(true)
        self.isVirtual = false
    end
    self.playing = false
    EventMgr.Instance:RemoveListener(event_name.sing_playing_status, self.listener)
    local model = self.model
    local color = nil
    local type = model.currentType

    if type ==  model.rank_type.Child or
        type == model.rank_type.Guild or
        type == model.rank_type.GuildBattle or
        type == model.rank_type.GoodVoice or
        type == model.rank_type.GoodVoice2 then
        if index < 4 then
            color = model.colorList[index]
        else
            color = ColorHelper.ListItem
        end
    else
        color = ColorHelper.ListItem
    end
    self.data = data
    self.jobText.color = color
    self.nameText.color = color
    self.scoreText.color = color
    self.name2Text.color = color
    self.centernameText.color = color
    self.centername2Text.color = color

    self.character2Obj:SetActive(false)
    self.rankCampImage.gameObject:SetActive(false)
    self.Subbutton.gameObject:SetActive(false)
    self.scoreText.gameObject:SetActive(true)
    self.selectObj:SetActive(model.selectIndex == index)

    if index % 2 == 1 then
        self.img.color = ColorHelper.ListItem1
    else
        self.img.color = ColorHelper.ListItem2
    end

    if (type ==  model.rank_type.Child or
        type == model.rank_type.Guild or
        type == model.rank_type.GuildBattle or
        type == model.rank_type.GoodVoice or
        type == model.rank_type.GoodVoice2) and
        index < 4 then
        self.rankImage.gameObject:SetActive(true)
        self.rankImage.sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "place_"..data.rank)
        self.rankText.text = ""
    else
        self.rankImage.gameObject:SetActive(false)
        self.rankText.text = string.format(ColorHelper.ListItemStr, tostring(data.rank))
    end

    self.centernameText.text = ""

    if type == model.rank_type.Lev then             -- 等级
        self.iconObj:SetActive(true)

        if self.characterLoader == nil then
            self.characterLoader = SingleIconLoader.New(self.characterImage.gameObject)
        end
        self.characterLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex))

        self.nameText.gameObject:SetActive(true)
        self.nameText.text = data.name
        self.jobText.text = KvData.classes_name[data.classes]
        self.scoreText.text = tostring(data.lev)
    elseif type == model.rank_type.RenQiWeekly
        or type == model.rank_type.RenQiHistory
        or type == model.rank_type.GetFlower
        or type == model.rank_type.SendFlower
        or type == model.rank_type.WarriorNewTalent
        or type == model.rank_type.WarriorElite
        or type == model.rank_type.WarriorCourage
        or type == model.rank_type.WarriorHero
        or type == model.rank_type.AdventureSkill
        or type == model.rank_type.Duanwei
        or type == model.rank_type.Achievement
        or type == model.rank_type.Students
        or type == model.rank_type.Teacher
        or type == model.rank_type.Wise
        or type == model.rank_type.Glory
        or type == model.rank_type.Sword
        or type == model.rank_type.Magic
        or type == model.rank_type.Orc
        or type == model.rank_type.Arrow
        or type == model.rank_type.Devine
        or type == model.rank_type.Moon
        or type == model.rank_type.Temple
        or type == model.rank_type.Universe
        or model:CheckCanyonType(type)
        then
        self.iconObj:SetActive(true)

        if self.characterLoader == nil then
            self.characterLoader = SingleIconLoader.New(self.characterImage.gameObject)
        end
        self.characterLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex))

        self.nameText.gameObject:SetActive(true)
        self.nameText.text = data.name
        self.jobText.text = KvData.classes_name[data.classes]

        self.scoreText.text = tostring(data.val1)
    elseif type == model.rank_type.Jingji_cup then          -- 竞技场
        self.iconObj:SetActive(true)
        
        if self.characterLoader == nil then
            self.characterLoader = SingleIconLoader.New(self.characterImage.gameObject)
        end
        self.characterLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex))
        
        self.nameText.gameObject:SetActive(true)
        self.nameText.text = data.name
        self.jobText.text = KvData.classes_name[data.classes]
        self.scoreText.text = tostring(data.val1)
    elseif type == model.rank_type.Guild then               -- 公会
        self.iconObj:SetActive(false)
        self.centernameText.text = data.desc
        self.jobText.text = tostring(data.val1)
        self.scoreText.text = tostring(data.val2)
    elseif type == model.rank_type.Weapon
        or type == model.rank_type.Cloth
        or type == model.rank_type.Belt
        or type == model.rank_type.Pant
        or type == model.rank_type.Shoes
        or type == model.rank_type.Ring
        or type == model.rank_type.Nacklace
        or type == model.rank_type.Bracelet
        --or type == model.rank_type.Pet
        or type == model.rank_type.Shouhu
        then
        self.iconObj:SetActive(true)

        if self.characterLoader == nil then
            self.characterLoader = SingleIconLoader.New(self.characterImage.gameObject)
        end
        self.characterLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex))

        self.nameText.gameObject:SetActive(true)
        self.nameText.text = data.name
        self.jobText.text = data.desc
        self.scoreText.text = tostring(data.val1)
    elseif type == model.rank_type.Pet
        then
        self.iconObj:SetActive(true)
    --self.characterImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex)
        self.nameText.gameObject:SetActive(true)
        self.nameText.text = data.desc
        self.jobText.text = data.name
        self.scoreText.text = tostring(data.val1)
        for k,v in pairs(DataPet.data_pet) do
            if v.name == data.desc then
                if self.characterLoader == nil then
                    self.characterLoader = SingleIconLoader.New(self.characterImage.gameObject)
                end

                -- self.characterImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.headother_textures, v.head_id)
                -- or PreloadManager.Instance:GetSprite(AssetConfig.headother_textures2, v.head_id)
                self.characterLoader:SetSprite(SingleIconType.Pet,v.head_id)
            break
            end
        end
    elseif type == model.rank_type.LoveWeekly
        or type == model.rank_type.LoveHistory
        then

        if self.characterLoader == nil then
            self.characterLoader = SingleIconLoader.New(self.characterImage.gameObject)
        end
        self.characterLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.male_sex))
        
        self.nameText.gameObject:SetActive(true)
        self.nameText.text = data.male_name

        self.character2Image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, data.female_classes.."_"..data.female_sex)
        self.name2Text.gameObject:SetActive(true)
        self.name2Text.text = data.female_name
        self.scoreText.text = tostring(data.val1)
        self.jobText.text = ""
        self.character2Obj:SetActive(true)
    elseif type == model.rank_type.Hero
        then
        self.rankCampImage.sprite = self.assetWrapper:GetSprite(AssetConfig.hero_textures, "Camp"..(3 - data.val2))
        self.rankCampImage.gameObject:SetActive(true)
        self.iconObj:SetActive(true)

        if self.characterLoader == nil then
            self.characterLoader = SingleIconLoader.New(self.characterImage.gameObject)
        end
        self.characterLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex))

        self.nameText.gameObject:SetActive(true)
        self.nameText.text = data.name
        self.jobText.text = KvData.classes_name[data.classes]
        self.scoreText.text = tostring(data.val1)
    elseif type == model.rank_type.DragonBoat
        then
        self.iconObj:SetActive(true)

        if self.characterLoader == nil then
            self.characterLoader = SingleIconLoader.New(self.characterImage.gameObject)
        end
        self.characterLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex))

        self.nameText.gameObject:SetActive(true)
        self.nameText.text = data.name
        self.jobText.text = KvData.classes_name[data.classes]
        local hour = nil
        local min = nil
        local sec = nil
        _,hour,min,sec = BaseUtils.time_gap_to_timer(data.val1)
        if hour > 0 then
            self.scoreText.text = string.format(TI18N("%s小时%s分%s秒"), hour, min, sec)
        else
            self.scoreText.text = string.format(TI18N("%s分%s秒"), min, sec)
        end
    elseif type == model.rank_type.GoodVoice or type == model.rank_type.GoodVoice2 then
        self.iconObj:SetActive(true)

        if self.characterLoader == nil then
            self.characterLoader = SingleIconLoader.New(self.characterImage.gameObject)
        end
        self.characterLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex))
        
        self.nameText.gameObject:SetActive(true)
        self.nameText.text = data.name
        if type == model.rank_type.GoodVoice then
            self.jobText.text = tostring(data.liked)
        elseif type == model.rank_type.GoodVoice2 then
            self.jobText.text = tostring(data.only_liked)
        end
        self.scoreText.gameObject:SetActive(false)
        self.Subbutton.gameObject:SetActive(true)
        EventMgr.Instance:AddListener(event_name.sing_playing_status, self.listener)
        self.Subbutton.onClick:RemoveAllListeners()
        self.Subbutton.onClick:AddListener(function()
            if not self.playing then
                local singdata = SingData.New()
                singdata:Update(data)
                SingManager.Instance.model:PlaySong(singdata, true)
            else
                self.playing = false
                SingManager.Instance.model:StopSong()
            end

        end)
        if SingManager.Instance.model.currtimer ~= nil and SingManager.Instance.model.currplaydata ~= nil and SingManager.Instance.model.currplaydata.rid == data.rid and SingManager.Instance.model.currplaydata.platform == data.platform and SingManager.Instance.model.currplaydata.zone_id == data.zone_id then
            self.playing = true
            self.Subbutton.transform:Find("icon").gameObject:SetActive(false)
            self.Subbutton.transform:Find("icon2").gameObject:SetActive(true)
        else
            self.playing = false
            self.Subbutton.transform:Find("icon").gameObject:SetActive(true)
            self.Subbutton.transform:Find("icon2").gameObject:SetActive(false)
        end
    elseif type == model.rank_type.Child then
        self.centernameText.transform.sizeDelta = Vector2(200,30)
        self.iconObj:SetActive(false)
        self.nameText.text = ""
        if data.father_name == "" then
            self.centernameText.text = data.mother_name
        elseif data.mother_name == "" then
            self.centernameText.text = data.father_name
        else
            self.centernameText.text = string.format("%s/%s", data.father_name, data.mother_name)
        end
        self.scoreText.text = data.val1
        self.jobText.text = data.name
    elseif model:CheckChampionType(type) then
        self.iconObj:SetActive(true)

        if self.characterLoader == nil then
            self.characterLoader = SingleIconLoader.New(self.characterImage.gameObject)
        end
        self.characterLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex))

        self.nameText.gameObject:SetActive(true)
        self.nameText.text = data.name
        self.jobText.text = KvData.classes_name[data.classes]
        self.scoreText.text = DataTournament.data_list[data.rank_lev].name
    elseif model:CheckGodswarType(type) then
        self.iconObj:SetActive(true)

        if self.characterLoader == nil then
            self.characterLoader = SingleIconLoader.New(self.characterImage.gameObject)
        end
        self.characterLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex))
        
        self.nameText.gameObject:SetActive(true)
        self.nameText.text = data.name
        self.jobText.text = BaseUtils.GetServerNameMerge(data.platform, data.zone_id)

        self.scoreText.text = model.GodsWarLevel[data.val1]
    end

    self.button.onClick:RemoveAllListeners()
    self.button.onClick:AddListener(function()
        if model.currentSelectItem ~= nil then
            model.currentSelectItem:SetActive(false)
        end
        model.selectIndex = index
        self.selectObj:SetActive(true)
        model.currentSelectItem = self.selectObj

        if type == model.rank_type.Lev
            or type == model.rank_type.Guild
            or type == model.rank_type.Guild
            or type == model.rank_type.Jingji_cup
            or type == model.rank_type.RenQiWeekly
            or type == model.rank_type.RenQiHistory
            or type == model.rank_type.GetFlower
            or type == model.rank_type.SendFlower
            or type == model.rank_type.Duanwei
            or type == model.rank_type.WarriorNewTalent
            or type == model.rank_type.WarriorElite
            or type == model.rank_type.WarriorCourage
            or type == model.rank_type.WarriorNewTalent
            or type == model.rank_type.AdventureSkill
            or type == model.rank_type.Achievement
            or type == model.rank_type.Universe
            or type == model.rank_type.Sword
            or type == model.rank_type.Magic
            or type == model.rank_type.Arrow
            or type == model.rank_type.Orc
            or type == model.rank_type.Devine
            or type == model.rank_type.Moon
            or type == model.rank_type.Temple
            or type == model.rank_type.Students
            or type == model.rank_type.Teacher
            or type == model.rank_type.Hero
            or type == model.rank_type.Glory
            or type == model.rank_type.GoodVoice
            or type == model.rank_type.GoodVoice2
            or model:CheckCanyonType(type)
            then
            BaseUtils.dump(data)
            local showData = {id = data.role_id, zone_id = data.zone_id, platform = data.platform, sex = data.sex, classes = data.classes, name = data.name, lev = data.lev, guild = data.guild, noChatStranger = true}
            --BaseUtils.dump(showData)
            TipsManager.Instance:ShowPlayer(showData)
        elseif type == model.rank_type.Shouhu then
            ShouhuManager.Instance.model.shouhu_look_lev = data.lev
            ShouhuManager.Instance.model.shouhu_look_owner_name = data.name
            local data = {type = type, role_id = data.role_id, platform = data.platform, zone_id = data.zone_id, sub_type = model.sub_type}
            RankManager.Instance:send12503(data)
        elseif type == model.rank_type.Pet then
            RankManager.Instance:send12502({type = type, sub_type = model.sub_type, role_id = data.role_id, platform = data.platform, zone_id = data.zone_id})
        elseif type == model.rank_type.Child then
            -- ChatManager.Instance:Send10421(data.platform, data.zone_id, data.id)
        elseif model:CheckGodswarType(type) then
            local currIndex = model.classList[model.currentMain].subList[model.currentSub].type - 66
            --print("currIndex"..currIndex)
            RankManager.Instance:send12506(data.role_id, data.platform, data.zone_id, currIndex)
        elseif self.model:CheckChampionType(type) then
            -- local showData = {id = data.rid, zone_id = data.zone_id, platform = data.platform, sex = data.sex, classes = data.classes, name = data.name,  noChatStranger = true}
            -- TipsManager.Instance:ShowPlayer(showData)
            --local showData = {id = data.rid, zone_id = data.zone_id, platform = data.platform, rid = data.rid}
            TipsManager.Instance:ShowPlayer(data)
        end
    end)
end

function RankItemFourColumn:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function RankItemFourColumn:__delete()
    self.rankImage.sprite = nil
    self.rankCampImage.sprite = nil
    self.characterImage.sprite = nil
    self.character2Image.sprite = nil

    self.assetWrapper = nil

    if self.characterLoader ~= nil then
        self.characterLoader:DeleteMe()
        self.characterLoader = nil
    end

    self.rankText = nil
    self.rankImage = nil
    self.nameText = nil
    self.centernameText = nil
    self.iconObj = nil
    self.characterImage = nil
    self.jobText = nil
    self.scoreText = nil
    self.bgObj = nil
    self.selectObj = nil
    self.button = nil
    self.gameObject = nil
    self.model = nil
    EventMgr.Instance:RemoveListener(event_name.sing_playing_status, self.listener)
end

function RankItemFourColumn:SwitchPlayBtn(data, isplaying)
    if self.data == nil then
        return
    end
    if data.rid == self.data.rid and data.platform == self.data.platform and data.zone_id == self.data.zone_id then
        if isplaying then
            self.playing = true
            self.Subbutton.transform:Find("icon").gameObject:SetActive(false)
            self.Subbutton.transform:Find("icon2").gameObject:SetActive(true)
        else
            self.playing = false
            self.Subbutton.transform:Find("icon").gameObject:SetActive(true)
            self.Subbutton.transform:Find("icon2").gameObject:SetActive(false)

        end
    end
end