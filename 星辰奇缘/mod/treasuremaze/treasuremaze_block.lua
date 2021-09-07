-- 宝藏石板方块
-- hzf
-------------
MazeBlockStatus = {
    untouchable = 1, -- 不可操作
    touchable = 2, -- 可操作
    nothing = 3, -- 已经开启没东西
    endpoint = 4,  -- 终点
    startpoint = 5,  -- 起点
    slab = 6,  -- 石板状态
    slabbreak = 7, -- 碎裂石板
    hole = 8, -- 窟窿
    moster = 9,  -- 怪物
    lock = 10, -- 强制封锁
    item = 11,  -- 道具
    dragon = 12,  -- 炎龙
    mouse = 13,  -- 土拨鼠
    boom = 14, -- 连锁爆炸
    ghost = 15,  -- 放妖怪
    givepresent = 16,  -- 萌宠献礼
    dragoncat = 17,  -- 龙猫迷路
    helpanimal = 18,  -- 解救
    miner = 19,  -- 采矿精灵
    hotarea = 20,  -- 灼热之地
    monkey = 21,  -- 抓猴子
    guide = 22,  -- 精灵指引
}

TreasureMazeBlock = TreasureMazeBlock or BaseClass()

function TreasureMazeBlock:__init(transform, parent, x, y)
    self.transform = transform
    self.parent = parent
    self.model = self.parent.model
    self.gameObject = transform.gameObject
    self.gameObject.name = string.format("X=%sY=%s", tostring(x), tostring(y))
    self.x = x
    self.y = y
    self.previewData = nil
    self.iconloader = {}

    self.slabImg = self.transform:Find("slab"):GetComponent(Image)
    self.statusimg = self.transform:Find("statusimg"):GetComponent(Image)
    -- self.Text = self.transform:Find("StatueText"):GetComponent(Text)
    -- self.Text.gameObject:SetActive(false)
    -- self.Text.fontSize = 12
    -- self.Text.text = ""
    self.breakslab = self.transform:Find("breakslab"):GetComponent(Image)
    self.ItemImg = self.transform:Find("Item"):GetComponent(Image)
    self.Double = self.transform:Find("double"):GetComponent(Image)
    self.ItemImg.gameObject.transform.sizeDelta = Vector2(52, 52)
    self.LockImg = self.transform:Find("lock").gameObject
    self.animalBubble = self.transform:Find("animalBubble").gameObject
    self.animalBubbleItem = self.transform:Find("animalBubble/Image"):GetComponent(Image)

    self.slabImg.color = Color(0.5, 0.5, 0.5, 1)
    self.transform:GetComponent(Button).onClick:AddListener(function() self:OnClick() end)
    self.blockstatus = MazeBlockStatus.untouchable
    self.lastblockstatus = MazeBlockStatus.untouchable
    self.randomid = Random.Range(1,5)
    self.slabImg.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.treasuremazetexture, string.format("block%s", self.model:GetBlockSprite(self.x, self.y)))

    -- self:Update({})
end

function TreasureMazeBlock:__delete()
    for k,v in pairs(self.iconloader) do
        v:DeleteMe()
    end
    self.iconloader = {}
    if self.ItemTween ~= nil then
        Tween.Instance:Cancel(self.ItemTween.id)
        self.ItemTween = nil
    end
    if self.getTimer ~= nil then
        LuaTimer.Delete(self.getTimer)
        self.getTimer = nil
    end
    if self.previewCom ~= nil then
        self.previewCom:DeleteMe()
        self.previewCom = nil
    end
end

function TreasureMazeBlock:Update(data)
    self.lastdata = self.data
    self.data = data
    if data == nil or next(data) == nil then
        self.data = self.model:GetData(self.x, self.y)
    end
    if self:CheckMoster() then
        self:Lock()
    else
        self:Unlock()
    end
    self.eventdata = self.model:GetEventData(self.x, self.y)
    if self.data == nil or next(self.data) == nil then
        -- self.slabImg.color = Color(0.5, 0.5, 0.5, 1)
        -- self.statusimg.gameObject:SetActive(false)
        if self:CheckCanTouch() then
            self:Changetouchable()
        else
            self:ChangeUntouchable()
        end
        if self.eventdata ~= nil and next(self.eventdata) ~= nil then
            self:DealEvent(self.eventdata)
        end
        local picecdata = self.model:GetPieceData(self.x, self.y)
        if picecdata ~= nil then
            self:DealPiece(picecdata)
        end
        return
    end
    -- if #self.data.reward > 0 then
    --     self.Text.text = string.format("type = %s\nid = %s\nbase_id=%s", self.data.type, self.data.id, self.data.reward[1].base_id)
    -- else
    --     self.Text.text = string.format("type = %s\nid = %s", self.data.type, self.data.id)
    -- end
    if self.data.hard ~= self.data.times then
        self:ChangeStatus(MazeBlockStatus.slabbreak)
    elseif self.data.type == 0 then
        self:ChangeStatus(MazeBlockStatus.hole)
    elseif self.data.type == 1 then
        if self.data.hard ~= self.data.times then
            self:ChangeStatus(MazeBlockStatus.slabbreak)
        else
            -- if #self.data.reward == 0 then
            --     self:ChangeStatus(MazeBlockStatus.nothing)
            -- else
                self:ChangeStatus(MazeBlockStatus.item)
            -- end
        end
    elseif self.data.type == 2 then
        if self.data.id == 1 then
            self:ChangeStatus(MazeBlockStatus.moster)
        elseif self.data.id == 2 then
            if self.data.hard ~= self.data.times then
                self:ChangeStatus(MazeBlockStatus.slabbreak)
            else
                self:ChangeStatus(MazeBlockStatus.dragon)
            end
        elseif self.data.id == 3 then
            self:ChangeStatus(MazeBlockStatus.boom)
        elseif self.data.id == 4 then
            self:ChangeStatus(MazeBlockStatus.mouse)
        elseif self.data.id == 5 then
            self:ChangeStatus(MazeBlockStatus.ghost)
        elseif self.data.id == 6 then
            self:ChangeStatus(MazeBlockStatus.guide)
        elseif self.data.id == 7 then
            self:ChangeStatus(MazeBlockStatus.givepresent)
        elseif self.data.id == 8 then
            self:ChangeStatus(MazeBlockStatus.dragoncat)
        elseif self.data.id == 9 then
            self:ChangeStatus(MazeBlockStatus.helpanimal)
        elseif self.data.id == 10 then
            self:ChangeStatus(MazeBlockStatus.miner)
        elseif self.data.id == 11 then
            self:ChangeStatus(MazeBlockStatus.hotarea)
        elseif self.data.id == 12 then
            self:ChangeStatus(MazeBlockStatus.monkey)
        end
    elseif self.data.type == 3 then
        if self.data.id == 1 then
            self:ChangeStart()
        elseif self.data.id == 2 then
            self:ChangeEnd()
            if self:CheckCanTouch() then
                self:Changetouchable()
            else
                self:ChangeUntouchable()
            end
            -- self.blockstatus = MazeBlockStatus.endpoint
            self.slabImg.color = Color(1, 1, 1, 1)
        end
    end
    self.eventdata = self.model:GetEventData(self.x, self.y)
    if self.eventdata ~= nil and next(self.eventdata) ~= nil then
        self:DealEvent(self.eventdata)
    end
end

function TreasureMazeBlock:ChangeStatus(status)
    self.lastblockstatus = self.blockstatus
    self.blockstatus = status
    if status == MazeBlockStatus.untouchable then
        self:ChangeUntouchable()
    elseif status == MazeBlockStatus.touchable then
        self:Changetouchable()
    elseif status == MazeBlockStatus.nothing then
        self:ChangeNothing()
    elseif status == MazeBlockStatus.slab then
        self:ChangeSlab()
    elseif status == MazeBlockStatus.slabbreak then
        self:ChangeSlabbreak()
    elseif status == MazeBlockStatus.hole then
        self:ChangeHole()
    elseif status == MazeBlockStatus.moster then
        self:ChangeMoster()
    elseif status == MazeBlockStatus.lock then
        self:ChangeLock()
    elseif status == MazeBlockStatus.item then
        self:ChangeItem()
    elseif status == MazeBlockStatus.dragon then
        self:ChangeDragon()
    elseif status == MazeBlockStatus.mouse then
        self:ChangeMouse()
    elseif status == MazeBlockStatus.boom then
        self:ChangeBoom()
    elseif status == MazeBlockStatus.ghost then
        self:ChangeGhost()
    elseif status == MazeBlockStatus.guide then
        self:ChangeGuide()
    elseif status == MazeBlockStatus.givepresent then
        self:ChangeGivePresent()
    elseif status == MazeBlockStatus.dragoncat then
        self:ChangeDragonCat()
    elseif status == MazeBlockStatus.helpanimal then
        self:ChangeHelpAnimal()
    elseif status == MazeBlockStatus.miner then
        self:ChangeMiner()
    elseif status == MazeBlockStatus.hotarea then
        self:ChangeHotArea()
    elseif status == MazeBlockStatus.monkey then
        self:ChangeMonkey()
    end
    if (self.lastblockstatus == MazeBlockStatus.touchable or self.lastblockstatus == MazeBlockStatus.slabbreak) and self.blockstatus ~= MazeBlockStatus.startpoint and (self.lastdata == nil or (self.lastdata ~= nil and self.data ~= nil and self.lastdata.times ~= self.data.times)) and not self.parent.firstInit then
        self.parent:PlayFly(self.x, self.y)
        self.parent:PlayBreak(self.x, self.y)
    end
end

function TreasureMazeBlock:Unlock()
    self.LockImg:SetActive(false)
    if self.lock then
        self.lock = false
        if self.data == nil then
            self:DarkBlock()
        else
            self:Update(self.data)
        end
    end
end

function TreasureMazeBlock:Lock()
    self.LockImg:SetActive(true)
    self.lock = true
    self:DarkBlock()
end

function TreasureMazeBlock:DarkBlock()
    self.slabImg.enabled = true
    self.slabImg.color = Color(0.5, 0.5, 0.5, 1)
end


function TreasureMazeBlock:OnClick()
    -- BaseUtils.dump(self.data, "方块数据1")
    -- BaseUtils.dump(self.eventdata, "方块数据2")
    if self.data == nil then
        return
    end
    if (self.data.type == 0 and self.data.hard == self.data.times)or self.blockstatus == MazeBlockStatus.untouchable or self.blockstatus == MazeBlockStatus.nothing then
        if self.data.type == 3 and self.data.id == 2 then
            if self.parent.currpiece_num ~= 3 then
                NoticeManager.Instance:FloatTipsByString(TI18N("<color='#ffff00'>秘宝钥匙</color>尚未激活，无法开启<color='#ffff00'>神秘宝藏</color>"))
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("你尚未到达这里"))
            end
            self:Shake()
        elseif self.lock then
            NoticeManager.Instance:FloatTipsByString(TI18N("请先清除附近的妖怪"))
        end
        return
    end
    if self.lock then
        NoticeManager.Instance:FloatTipsByString(TI18N("请先清除附近的妖怪"))
        return
    end
    if self.eventdata ~= nil and next(self.eventdata) ~= nil then
        for k, event in pairs(self.eventdata) do
            if event.e_type == 2 and event.e_id == 12 and event.e_flag == 0 then
                if not self:CheckMonkey() then
                    local temp = event
                    temp.isfirst = self.parent.firstInit
                    self.model:OpenEventPanel(temp)
                    return
                end
            elseif event.e_type == 2 and event.e_id == 9 and event.e_flag == 0 then
                if self:CheckHelp() then
                    TreasureMazeManager.Instance:Send18814(event.e_x, event.e_y)
                else
                    NoticeManager.Instance:FloatTipsByString(TI18N("清除<color='#ffff00'>所有石板</color>救我{face_1, 21}"))
                end
                return
            end
        end
    end
    if self.data ~= nil and next(self.data) ~= nil then
        if self.data.type == 2 and self.data.id == 10 and self.data.flag == 0 and self.blockstatus ~= MazeBlockStatus.slabbreak then
            local temp = self.data
            -- temp.isfirst = self.parent.firstInit
            self.model:OpenEventPanel(temp)
            return
        elseif self.data.type == 2 and self.data.id == 9 and self.data.flag == 0 and self.blockstatus ~= MazeBlockStatus.slabbreak then
            if self:CheckHelp() then
                TreasureMazeManager.Instance:Send18814(self.data.x, self.data.y)
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("清除<color='#ffff00'>所有石板</color>救我{face_1, 21}"))
            end
            return
        elseif self.data.type == 2 and self.data.id == 7 and self.data.flag == 0 and self.blockstatus ~= MazeBlockStatus.slabbreak then
            local temp = self.data
            -- temp.isfirst = self.parent.firstInit
            self.model:OpenEventPanel(temp)
            return
        end
    end
    local num = BackpackManager.Instance:GetItemCount(21220)
    if self.blockstatus ~= MazeBlockStatus.endpoint and self.blockstatus ~= MazeBlockStatus.slabbreak and num <= 0 and self.blockstatus == MazeBlockStatus.touchable then
    -- not (self.blockstatus == MazeBlockStatus.item and self.data.hard == self.data.times)
        NoticeManager.Instance:FloatTipsByString(TI18N("道具不足，无法操作"))
        self.parent:PlayClick(self.x, self.y)
        self.parent:ShowItemTips()
        return
    end
    if self.blockstatus == MazeBlockStatus.moster then
        if self.data.flag == 1 then
            -- NoticeManager.Instance:FloatTipsByString(TI18N("已经被击败"))
        else
            -- self.model:OpenMosterPanel(self.data)
            TreasureMazeManager.Instance:Send18815(self.x, self.y)
        end
    elseif self.blockstatus == MazeBlockStatus.item then
        if self.getTimer ~= nil then
            LuaTimer.Delete(self.getTimer)
            self.getTimer = nil
        end
        TreasureMazeManager.Instance:Send18807(self.x, self.y)
    elseif self.blockstatus == MazeBlockStatus.endpoint then
        self:Shake()
        if self:CheckMoster(true) then
            NoticeManager.Instance:FloatTipsByString(TI18N("请先清除附近的妖怪"))
            return
        end
        if self.parent.currpiece_num ~= 3 then
            NoticeManager.Instance:FloatTipsByString(TI18N("<color='#ffff00'>秘宝钥匙</color>尚未激活，无法开启<color='#ffff00'>神秘宝藏</color>"))
            return
        end
        if self.data.flag ~= 1 then
            if not self.playingEnd then
                self.parent:PlayOpenEffect()
                self.playingEnd = true
                LuaTimer.Add(3000, function()
                    self.playingEnd = false
                    TreasureMazeManager.Instance:Send18808()
                end)
            end
        else
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("确定重置宝藏迷城吗？")
            data.sureLabel = TI18N("重置")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function()
                TreasureMazeManager.Instance:Send18811()
            end
            NoticeManager.Instance:ConfirmTips(data)
            -- NoticeManager.Instance:FloatTipsByString(TI18N("已经领取"))
        end
    elseif self.blockstatus == MazeBlockStatus.dragoncat then
        if self.data.flag == 0 then
            local temp = self.data
            temp.isfirst = self.parent.firstInit
            self.model:OpenEventPanel(temp)
        end
    else
        if not self.isnothing and not self.lock then
            self.parent:PlayClick(self.x, self.y)
        end
        TreasureMazeManager.Instance:Send18801(self.x, self.y)
    end
end


function TreasureMazeBlock:ChangeUntouchable()
    if self.data ~= nil and next(self.data) ~= nil and self.data.type ~= 3 and self.isnothing then return end
    self.isnothing = false
    self:HideAll()
    self:DarkBlock()
    if not BaseUtils.isnull(self.rawImage) then
        self.rawImage:SetActive(false)
    end
    self.blockstatus = MazeBlockStatus.untouchable
end

function TreasureMazeBlock:Changetouchable()
    if self.lock then return end
    if self.data == nil or next(self.data) == nil then
        self.isnothing = false
    end
    if self.previewCom ~= nil and self.previewCom.modelData.modelId == 30237 then
        local eventdata = self.model:GetEventData(self.x, self.y)
        if eventdata == nil or next(eventdata) == nil then
            self.previewCom:DeleteMe()
            self.previewCom = nil
        end
    end
    self:HideAll()
    if self.blockstatus == MazeBlockStatus.untouchable or self.data == nil or next(self.data) == nil then
        self.slabImg.color = Color(1, 1, 1, 1)
        self.blockstatus = MazeBlockStatus.touchable
    end
end

function TreasureMazeBlock:ChangeNothing()
    self.slabImg.color = Color(1, 1, 1, 0)
    self.isnothing = true
    -- self.Text.text = string.format("%s_%s", tostring(self.lastblockstatus), tostring(self.blockstatus))
    -- if self.lastblockstatus == self.blockstatus then
    --     return
    -- end
    if (self.lastblockstatus == MazeBlockStatus.touchable or self.lastblockstatus == MazeBlockStatus.slabbreak) and self.blockstatus ~= MazeBlockStatus.startpoint then
        -- self.parent:PlayFly(self.x, self.y)
        self.parent:PlayBreak(self.x, self.y)
    end
    self.slabImg.color = Color(1, 1, 1, 0)
    self:HideAll()
    if self.ItemTween ~= nil then
        Tween.Instance:Cancel(self.ItemTween.id)
        self.ItemTween = nil
    end
    if self.previewCom ~= nil then
        self.previewCom:DeleteMe()
        self.previewCom = nil
    end
end

function TreasureMazeBlock:ChangeSlab()
    -- if self.lastblockstatus == MazeBlockStatus.touchable then
    --     self.parent:PlayFly(self.x, self.y)
    -- end
end

function TreasureMazeBlock:ChangeSlabbreak()
    self.slabImg.color = Color(1, 1, 1, 1)
    -- if self.lastblockstatus == MazeBlockStatus.touchable then
    --     self.parent:PlayFly(self.x, self.y)
    -- end
    local breakid = 5-self.data.hard+self.data.times
    self.breakslab.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.treasuremazetexture, "break"..tostring(breakid))
    self.statusimg.gameObject:SetActive(false)
    self.breakslab.gameObject:SetActive(true)
    self.ItemImg.gameObject:SetActive(false)
    self.Double.gameObject:SetActive(false)
end

function TreasureMazeBlock:ChangeHole()
    if self.previewCom ~= nil then
        self.previewCom:DeleteMe()
        self.previewCom = nil
    end
    self.parent.FloorList[self.x][self.y].sprite = self.parent.assetWrapper:GetSprite(AssetConfig.treasuremazetexture, "hole"..tostring(self.parent.currstyleid))
    self.slabImg.color = Color(1, 1, 1, 0)
    self.isnothing = true
    self.statusimg.gameObject:SetActive(false)
    if (self.lastblockstatus == MazeBlockStatus.touchable or self.lastblockstatus == MazeBlockStatus.untouchable) and not self.parent.firstInit then
        -- self.parent:PlayFly(self.x, self.y)
        self.parent:PlayBreak(self.x, self.y)
    end
    self:HideAll()
end

function TreasureMazeBlock:ChangeMoster()
    self.hasmoster = true
    if self.data.flag ~= 1 then
        -- if self.previewCom ~= nil then
        --     self.previewCom:Show()
        --     if not BaseUtils.isnull(self.rawImage) then
        --         self.rawImage:SetActive(true)
        --     end
        -- end
        -- self:LoadPreview(30715)
    else
        -- if self.previewCom ~= nil then
        --     self.previewCom:Hide()
        --     if not BaseUtils.isnull(self.rawImage) then
        --         self.rawImage:SetActive(false)
        --     end
        -- end
    end
    self.slabImg.color = Color(1, 1, 1, 0)
    -- if self.lastblockstatus == MazeBlockStatus.touchable then
        -- self.parent:PlayFly(self.x, self.y)
        -- self.parent:PlayBreak(self.x, self.y)
        self.parent:PlayMoster(self.x, self.y, self.data.flag ~= 1)
    -- end
    self.breakslab.gameObject:SetActive(false)
    self.ItemImg.gameObject:SetActive(false)
    self.Double.gameObject:SetActive(false)
end

function TreasureMazeBlock:ChangeLock()
    self.slabImg.color = Color(1, 0, 0, 1)
    self.blockstatus = MazeBlockStatus.untouchable
end

function TreasureMazeBlock:ChangeStart()
    self.slabImg.color = Color(1, 1, 1, 0)
    self.blockstatus = MazeBlockStatus.startpoint
    self:HideAll()
    -- self.Text.text = ""
    self.statusimg.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.treasuremazetexture, "start")
    self.statusimg.gameObject.transform.anchoredPosition = Vector2(0, 0)
    self.statusimg.gameObject:SetActive(true)
    self.statusimg:SetNativeSize()
end


function TreasureMazeBlock:ChangeEnd()
    self.blockstatus = MazeBlockStatus.endpoint
    -- self.Text.text = ""
    self.slabImg.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.treasuremazetexture, "blockend"..tostring(self.parent.currstyleid))
    self.isnothing = true
    if self.data.flag ~= 1 then
        self.slabImg.color = Color(1, 1, 1, 1)
        self.statusimg.gameObject:SetActive(false)
    else
        -- self.Text.text = "重置"

        self.statusimg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "InfoIcon11")
        self.statusimg.gameObject.transform.anchoredPosition = Vector2(0, 0)
        self.statusimg.gameObject:SetActive(true)
        self.statusimg:SetNativeSize()
        self.slabImg.color = Color(1, 1, 1, 0)
    end
end

function TreasureMazeBlock:ChangeItem()
    self.slabImg.color = Color(1, 1, 1, 0)
    -- self.Text.text = ""
    if self.previewCom ~= nil then
        self.previewCom:DeleteMe()
        self.previewCom = nil
    end
    if #self.data.reward == 0 then
        if self.lastblockstatus == MazeBlockStatus.item then
            self.ItemImg.gameObject:SetActive(true)
            self:ItemGet()
        else
            self.blockstatus = MazeBlockStatus.nothing
            self:ChangeNothing()
        end
        return
    end
    if not BaseUtils.isnull(self.guideeffect) then
        GameObject.DestroyImmediate(self.guideeffect)
        self.guideeffect = nil
    end
    local icon = DataItem.data_get[self.data.reward[1].base_id].icon
    local old = false
    if self.ItemImg.sprite ~= nil and tostring(self.ItemImg.sprite.name) == tostring(icon) then
        old = true
    end
    self:SetGetItem(self.ItemImg.gameObject, icon)
    self.ItemImg.color = Color(1, 1, 1, 1)
    if DataMaze.data_items[self.data.reward[1].base_id] ~= nil and DataMaze.data_items[self.data.reward[1].base_id].is_cast == 1 then
        if self.special_obj == nil then
            self.special_obj = GameObject.Instantiate(self.parent:GetPrefab(self.parent.specialEffect))
            self.special_obj.transform:SetParent(self.ItemImg.gameObject.transform)
            self.special_obj.transform.localScale = Vector3.one
            self.special_obj.transform.localPosition = Vector3(0, 0, 1400)
            Utils.ChangeLayersRecursively(self.special_obj.transform, "UI")
            self.special_obj:SetActive(true)
        else
            self.special_obj.transform:SetParent(self.ItemImg.gameObject.transform)
            self.special_obj.transform.localScale = Vector3.one
            self.special_obj.transform.localPosition = Vector3(0, 0, 1400)
            self.special_obj:SetActive(true)
        end
        if not old then
            SoundManager.Instance:Play(238)
        end
    else
        if self.special_obj ~= nil then
            self.special_obj:SetActive(false)
        end
        if not old then
            SoundManager.Instance:Play(237)
        end
    end

    if self.data.flag == 1 and not self.Double.gameObject.activeSelf then
        if self.parent.firstInit then
            self.Double.transform.localPosition = Vector3(56, -17, 0)
            self.Double.color = Color(1, 1, 1, 1)
            self.Double.gameObject:SetActive(true)
        else
            local callback = function()
                self.Double.transform.localPosition = Vector3(56, -45, 0)
                -- self.Double.color = Color(1, 1, 1, 0)
                self.Double.gameObject:SetActive(true)
                Tween.Instance:Alpha(self.Double.gameObject, 1, 0.5, function() end)
                Tween.Instance:MoveLocalY(self.Double.gameObject, -17, 0.5, function() end)
            end
            self.parent:PlayDouble(self.x, self.y, callback)
        end
    elseif self.data.flag ~= 1 then
        self.Double.gameObject:SetActive(false)
    end
    if self.lastblockstatus == MazeBlockStatus.touchable then
        self.parent:PlayBreak(self.x, self.y)
    elseif self.lastblockstatus == MazeBlockStatus.slabbreak then
        self.parent:PlayBreak(self.x, self.y)
    end
    if self.lastblockstatus ~= MazeBlockStatus.nothing then
        -- self.parent:PlayFly(self.x, self.y)
    end
    -- self.ItemImg.gameObject.transform.anchoredPosition = Vector3.zero
    self.statusimg.gameObject:SetActive(false)
    self.breakslab.gameObject:SetActive(false)
    self.ItemImg.gameObject:SetActive(true)
    self.ItemImg.gameObject.transform.anchoredPosition = Vector2(0, 4)
    self.ItemImg.gameObject.transform.localPosition = self.ItemImg.gameObject.transform.localPosition + Vector3(0, -4, 0)
    if self.ItemTween == nil then
        self.ItemTween = Tween.Instance:MoveLocalY(self.ItemImg.gameObject, self.ItemImg.gameObject.transform.localPosition.y+8, 0.8, function() end, LeanTweenType.linear):setLoopPingPong()
    end
    if self.getTimer == nil then
        self.getTimer = LuaTimer.Add(3000, function()
            TreasureMazeManager.Instance:Send18807(self.x, self.y)
            self.getTimer = nil
        end)
    end
end

function TreasureMazeBlock:ChangeDragon()
    self.slabImg.color = Color(1, 1, 1, 0)
    if self.data.flag == 1 then
        self.isnothing = true
        -- self.statusimg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "fuben_bossicon")
        self.statusimg.gameObject:SetActive(false)
        self.breakslab.gameObject:SetActive(false)
        self.ItemImg.gameObject:SetActive(false)
        self.Double.gameObject:SetActive(false)
    else
        self.statusimg.gameObject:SetActive(false)
        self.breakslab.gameObject:SetActive(false)
        self.ItemImg.gameObject:SetActive(false)
        self.Double.gameObject:SetActive(false)
    end
    if not BaseUtils.isnull(self.hoteffect) then
        GameObject.DestroyImmediate(self.hoteffect)
        self.hoteffect = nil
    end
    if self.lastblockstatus == MazeBlockStatus.touchable then
        self.parent:PlayBreak(self.x, self.y)
    end
    if self.lastblockstatus ~= MazeBlockStatus.nothing then
        -- self.parent:PlayFly(self.x, self.y)
    end
    self.blockstatus = MazeBlockStatus.nothing
    self:ChangeNothing()
end

function TreasureMazeBlock:ChangeMouse()
    self.slabImg.color = Color(1, 1, 1, 0)
    if self.data.flag == 1 then
        -- self.statusimg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "fuben_bossicon")
        self.statusimg.gameObject:SetActive(false)
        self.breakslab.gameObject:SetActive(false)
        self.ItemImg.gameObject:SetActive(false)
        self.Double.gameObject:SetActive(false)
        self:ChangeNothing()
    else
        if self.data.hard == self.data.times then
            for k,v in pairs(BackpackManager.Instance.itemDic) do
                local key = string.format("%s_%s", v.base_id, self.data.special_id)
                if DataMaze.data_mouse[key] ~= nil then
                    TreasureMazeManager.Instance:Send18804(self.x, self.y, k)
                    break
                end
            end
        end
        self.statusimg.gameObject:SetActive(false)
        self.breakslab.gameObject:SetActive(false)
        self.ItemImg.gameObject:SetActive(false)
        self.Double.gameObject:SetActive(false)
    end
    if self.lastblockstatus == MazeBlockStatus.touchable then
        self.parent:PlayBreak(self.x, self.y)
    end
    if self.lastblockstatus ~= MazeBlockStatus.nothing then
        -- self.parent:PlayFly(self.x, self.y)
    end
end

function TreasureMazeBlock:ChangeGhost()
    self.slabImg.color = Color(1, 1, 1, 0)
    if self.data.flag == 1 then
        self.isnothing = true
        -- self.statusimg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "fuben_bossicon")
        self.statusimg.gameObject:SetActive(false)
        self.breakslab.gameObject:SetActive(false)
        self.ItemImg.gameObject:SetActive(false)
        self.Double.gameObject:SetActive(false)
        self.parent:SwitchGhostPanel(false, self.x, self.y, self.data.special_id)
    else
        self.parent:SwitchGhostPanel(true, self.x, self.y, self.data.special_id)
        self.statusimg.gameObject:SetActive(false)
        self.breakslab.gameObject:SetActive(false)
        self.ItemImg.gameObject:SetActive(false)
        self.Double.gameObject:SetActive(false)
    end
    if self.lastblockstatus == MazeBlockStatus.touchable then
        self.parent:PlayBreak(self.x, self.y)
    end
    if self.lastblockstatus ~= MazeBlockStatus.nothing then
        -- self.parent:PlayFly(self.x, self.y)
    end
    self.blockstatus = MazeBlockStatus.nothing
    self:ChangeNothing()
end

function TreasureMazeBlock:ChangeBoom()
    self.slabImg.color = Color(1, 1, 1, 0)
    if self.data.flag == 1 then
        self.isnothing = true
        -- self.statusimg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "fuben_bossicon")
        self.statusimg.gameObject:SetActive(false)
        self.breakslab.gameObject:SetActive(false)
        self.ItemImg.gameObject:SetActive(false)
        self.Double.gameObject:SetActive(false)
    else
        self.statusimg.gameObject:SetActive(false)
        self.breakslab.gameObject:SetActive(false)
        self.ItemImg.gameObject:SetActive(false)
        self.Double.gameObject:SetActive(false)
    end
    if self.lastblockstatus == MazeBlockStatus.touchable then
        self.parent:PlayBoom(self.x, self.y)
    end
    if self.lastblockstatus ~= MazeBlockStatus.nothing then
        -- self.parent:PlayFly(self.x, self.y)
    end
end

-- 萌宠献礼
function TreasureMazeBlock:ChangeGivePresent()
    self.slabImg.color = Color(1, 1, 1, 0)
    self:HideAll(true)
    if self.data.flag == 1 then
        self:HideAll()
        return
    end
    self.statusimg.gameObject:SetActive(true)
    -- if self.data.special_id == 0 then
        self.statusimg.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.treasuremazetexture, "animal")
        self.statusimg.gameObject.transform.anchoredPosition = Vector2.zero
        self.statusimg.gameObject.transform.sizeDelta = Vector2(60, 60)
        self.animalBubble:SetActive(true)
        local icon = DataItem.data_get[self.data.reward[1].base_id].icon
        self:SetGetItem(self.animalBubbleItem.gameObject, icon)
    -- end
    if self.event_obj == nil then
        self.event_obj = GameObject.Instantiate(self.parent:GetPrefab(self.parent.eventEffect))
        self.event_obj.transform:SetParent(self.statusimg.gameObject.transform)
        self.event_obj.transform.localScale = Vector3.one
        self.event_obj.transform.localPosition = Vector3(0, 0, 1400)
        Utils.ChangeLayersRecursively(self.event_obj.transform, "UI")
        self.event_obj:SetActive(true)
    else
        self.event_obj.transform:SetParent(self.statusimg.gameObject.transform)
        self.event_obj.transform.localScale = Vector3.one
        self.event_obj.transform.localPosition = Vector3(0, 0, 1400)
        self.event_obj:SetActive(true)
    end
    -- if self.lastblockstatus ~= MazeBlockStatus.miner and not self.parent.firstInit then
    --     local temp = self.data
    --     temp.isfirst = self.parent.firstInit
    --     self.model:OpenEventPanel(temp)
    -- end
end

--龙猫迷路
function TreasureMazeBlock:ChangeDragonCat()
    self.slabImg.color = Color(1, 1, 1, 0)
    self:HideAll(true)
    if self.data.flag == 1 then
        self:HideAll()
        return
    end
    self.statusimg.gameObject:SetActive(true)
    if self.data.special_id == 0 then
        self.statusimg.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.treasuremazetexture, "cathead")
        self.statusimg.gameObject.transform.anchoredPosition = Vector2.zero
        self.statusimg.gameObject.transform.sizeDelta = Vector2(60, 60)
        self.animalBubble:SetActive(true)
        -- local icon = DataItem.data_get[self.data.reward[1].base_id].icon
        self:SetGetItem(self.animalBubbleItem.gameObject, 20001)
    else
        self.statusimg.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.treasuremazetexture, "catnest")
        self.statusimg.gameObject.transform.anchoredPosition = Vector2.zero
        self.statusimg.gameObject.transform.sizeDelta = Vector2(60, 60)
    end
    if self.event_obj == nil then
        self.event_obj = GameObject.Instantiate(self.parent:GetPrefab(self.parent.eventEffect))
        self.event_obj.transform:SetParent(self.statusimg.gameObject.transform)
        self.event_obj.transform.localScale = Vector3.one
        self.event_obj.transform.localPosition = Vector3(0, -3, 1400)
        Utils.ChangeLayersRecursively(self.event_obj.transform, "UI")
        self.event_obj:SetActive(true)
    else
        self.event_obj.transform:SetParent(self.statusimg.gameObject.transform)
        self.event_obj.transform.localScale = Vector3.one
        self.event_obj.transform.localPosition = Vector3(0, -3, 1400)
        self.event_obj:SetActive(true)
    end
    if self.lastblockstatus ~= MazeBlockStatus.dragoncat and not self.parent.firstInit then
        local temp = self.data
        temp.isfirst = self.parent.firstInit
        -- self.model:OpenEventPanel(temp)
    end
end

--解救
function TreasureMazeBlock:ChangeHelpAnimal()
    self.slabImg.color = Color(1, 1, 1, 0)
    self.statusimg.gameObject:SetActive(false)
    self.breakslab.gameObject:SetActive(false)
    self.ItemImg.gameObject:SetActive(false)
    self.Double.gameObject:SetActive(false)
    self.animalBubble:SetActive(false)
    if self.data.flag == 1 then
        self:HideAll()
        self.parent:PlayHelpEnd(self.x, self.y)
        return
    end
    if self.lastblockstatus ~= MazeBlockStatus.helpanimal then
        -- NoticeManager.Instance:FloatTipsByString(TI18N("清除所有石板可救救我"))
    end
    if self.help_obj == nil then
        self.help_obj = GameObject.Instantiate(self.parent:GetPrefab(self.parent.animalEffect))
        self.help_obj.transform:SetParent(self.slabImg.gameObject.transform)
        self.help_obj.transform.localScale = Vector3.one
        self.help_obj.transform.localPosition = Vector3(41, -47, -250)
        Utils.ChangeLayersRecursively(self.help_obj.transform, "UI")
        self.help_obj:SetActive(true)
    else
        -- self.help_obj.transform:SetParent(self.slabImg.gameObject.transform)
        -- self.help_obj.transform.localScale = Vector3.one
        -- self.help_obj.transform.localPosition = Vector3(41, -36, 0)
        self.help_obj:SetActive(true)
    end
    -- self.statusimg.gameObject:SetActive(true)
    -- if self.data.special_id == 0 then
    -- self.statusimg.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.treasuremazetexture, "animal")
    -- self.statusimg.gameObject.transform.anchoredPosition = Vector2.zero
    -- self.statusimg.gameObject.transform.sizeDelta = Vector2(60, 60)
end

--采矿精灵
function TreasureMazeBlock:ChangeMiner()
    self.slabImg.color = Color(1, 1, 1, 0)
    self:HideAll(true)
    if self.data.flag == 1 then
        self:HideAll()
        return
    end
    self.breakslab.gameObject:SetActive(false)
    self.statusimg.gameObject:SetActive(true)
    -- if self.data.special_id == 0 then
        self.statusimg.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.treasuremazetexture, "fox")
        self.statusimg.gameObject.transform.anchoredPosition = Vector2.zero
        self.statusimg.gameObject.transform.sizeDelta = Vector2(60, 60)
        -- self.animalBubble:SetActive(true)
        -- local icon = DataItem.data_get[self.data.reward[1].base_id].icon
    -- end
    if self.lastdata ~= nil and next(self.lastdata) ~= nil and self.lastdata.id == 10 and (self.lastdata.reward[1] == nil or self.lastdata.reward[1].num ~= self.data.reward[1].num) then
        self.parent:PlayMiner(self.x, self.y)
    end
    if self.event_obj == nil then
        self.event_obj = GameObject.Instantiate(self.parent:GetPrefab(self.parent.eventEffect))
        self.event_obj.transform:SetParent(self.statusimg.gameObject.transform)
        self.event_obj.transform.localScale = Vector3.one
        self.event_obj.transform.localPosition = Vector3(-3.34, 3, 1400)
        Utils.ChangeLayersRecursively(self.event_obj.transform, "UI")
        self.event_obj:SetActive(true)
    else
        self.event_obj.transform:SetParent(self.statusimg.gameObject.transform)
        self.event_obj.transform.localScale = Vector3.one
        self.event_obj.transform.localPosition = Vector3(-3.34, 3, 1400)
        self.event_obj:SetActive(true)
    end
    if self.lastblockstatus ~= MazeBlockStatus.miner and not self.parent.firstInit then
        local temp = self.data
        temp.isfirst = self.parent.firstInit
        -- self.model:OpenEventPanel(temp)
    end
end

--灼热之地
function TreasureMazeBlock:ChangeHotArea()
    -- body
end

--抓猴子
function TreasureMazeBlock:ChangeMonkey()
    -- body
end

--精灵指引
function TreasureMazeBlock:ChangeGuide()
    if self.lastblockstatus ~= MazeBlockStatus.nothing then
        -- self.parent:PlayGuide(self.x, self.y)
    end
    self.blockstatus = MazeBlockStatus.nothing
    self.slabImg.color = Color(1, 1, 1, 0)
    self:HideAll()
    self:ChangeNothing()
end

function TreasureMazeBlock:CheckMoster(checkclick)
    if self.data ~= nil and next(self.data) ~= nil then
        if self.isnothing and checkclick == nil then
            return false
        elseif self.data.type == 0 and self.data.hard == self.data.times then
            return false
        elseif self.data.type == 1 and self.data.hard == self.data.times then
            return false
        elseif self.data.type == 2 and self.data.id == 1 and self.data.hard == self.data.times and self.data.flag == 1 then
            return false
        elseif self.data.type == 2 and self.data.id == 5 and self.data.hard == self.data.times then
            return false
        elseif self.data.type == 2 and self.data.id == 8 and self.data.hard == self.data.times and self.data.flag == 1 then
            return false
        elseif self.data.type == 2 and self.data.flag == 0 and self.data.hard == self.data.times then
            return false
        elseif self.data.type == 3 and checkclick == nil then
            return false
        end
    end

    local data = nil
    for i= -1, 1 do
        for j= -1, 1 do
            if i ~= 0 or j ~= 0 then
                data = self.model:GetData(self.x+i, self.y+j)
                if data ~= nil then
                    if data.type == 2 and data.id == 1 and data.flag ~= 1 and data.hard == data.times then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function TreasureMazeBlock:CheckCanTouch()
    local data = nil
    for i=-1,1 do
        for j=-1,1 do
            if math.abs(i) ~= math.abs(j) then
                data = self.model:GetData(self.x+i, self.y+j)
                if data ~= nil then
                    if ((data.type == 1 ) or (data.type == 2 and data.id == 1 and data.flag == 1) or (data.type == 2 and data.id ~= 1) or (data.type == 3 and data.id == 1)) and data.hard == data.times then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function TreasureMazeBlock:ItemGet()
    SoundManager.Instance:Play(257)
    self.blockstatus = MazeBlockStatus.nothing
    local target = self.ItemImg.gameObject:GetComponent(RectTransform)
    local pos = target.localPosition
    Tween.Instance:Alpha(target, 0, 0.3, function() self:ChangeNothing() end)
    Tween.Instance:MoveLocal(target.gameObject, Vector3(pos.x, pos.y + 30, pos.z), 0.3, function() end, LeanTweenType.linear)
end

function TreasureMazeBlock:ScanItem()
    local icon = DataItem.data_get[self.data.reward[1].base_id].icon
    self:SetGetItem(self.ItemImg.gameObject, icon)
    self.ItemImg.color = Color(0.5, 0.5, 0.5, 1)
    self.ItemImg.gameObject:SetActive(true)
end

function TreasureMazeBlock:Shake()
    if self.shaking then
        return
    end
    self.shaking = true
    local target = self.slabImg.gameObject:GetComponent(RectTransform)
    local pos = Vector3(-2.5, 10, 0)
    -- target.localPosition = Vector3(pos.x, pos.y + 2, pos.z)
    Tween.Instance:MoveLocal(target.gameObject, Vector3(pos.x, pos.y - 20, pos.z), 1.6, function() self.shaking = false target.localPosition = pos end, LeanTweenType.punch)
end


function TreasureMazeBlock:LoadPreview(base_id)
    local unit_data = DataUnit.data_unit[base_id]
    local setting = {
        name = "Block"
        ,orthographicSize = 0.5
        ,width = 70
        ,height = 70
        ,offsetY = -0.25
    }
    if base_id == 30729 then
        setting.orthographicSize = 0.45
        setting.offsetY = -0.43
    end
    local modelData = {type = PreViewType.Npc, skinId = unit_data.skin, modelId = unit_data.res, animationId = unit_data.animation_id, scale = 1}
    self.preview_loaded = function(com)
        self:PreviewLoaded(com)
    end
    if self.previewCom == nil then
        self.previewCom = PreviewComposite.New(self.preview_loaded, setting, modelData)

        -- 有缓存的窗口要写这个
        -- self.OnHideEvent:AddListener(function() self.previewCom:Hide() end)
        -- self.OnOpenEvent:AddListener(function() self.previewCom:Show() end)
    else
        if self.previewCom.modelData.modelId == modelData.modelId and self.previewCom.modelData.skinId == modelData.skinId then
        else
            self.previewCom:Reload(modelData, self.preview_loaded)
        end
    end

end


function TreasureMazeBlock:PreviewLoaded(composite)
    local rawImage = composite.rawImage
    if rawImage ~= nil then
        self.rawImage = rawImage
        rawImage.transform:SetParent(self.transform)
        if self.data ~= nil and next(self.data) ~= nil and self.blockstatus ~= MazeBlockStatus.touchable then
            rawImage.transform.anchoredPosition = Vector3(0, 15, 0)
        else
            rawImage.transform.anchoredPosition = Vector3(0, 12, 0)
        end
        local canvasG = self.rawImage.transform:GetComponent(CanvasGroup) or self.rawImage.transform.gameObject:AddComponent(CanvasGroup)
        canvasG.blocksRaycasts = false
        rawImage.transform.localScale = Vector3(1, 1, 1)
        composite.tpose.transform.localRotation = Quaternion.identity
        composite.tpose.transform:Rotate(Vector3(0, 45, 0))
        -- self.preview.texture = rawImage.texture
    end
end

function TreasureMazeBlock:HideAll(saveeffect)
    -- self.slabImg.color = Color(1, 1, 1, 0)
    if not saveeffect then
        if not BaseUtils.isnull(self.guideeffect) then
            GameObject.DestroyImmediate(self.guideeffect)
            self.guideeffect = nil
        end
        if not BaseUtils.isnull(self.event_obj) then
            GameObject.DestroyImmediate(self.event_obj)
            self.event_obj = nil
        end
        if not BaseUtils.isnull(self.hoteffect) and self.data ~= nil and next(self.data) ~= nil and self.data.flag == 1 then
            GameObject.DestroyImmediate(self.hoteffect)
            self.hoteffect = nil
        end
        if not BaseUtils.isnull(self.special_obj) then
            GameObject.DestroyImmediate(self.special_obj)
            self.special_obj = nil
        end
        if not BaseUtils.isnull(self.help_obj) then
            GameObject.DestroyImmediate(self.help_obj)
            self.help_obj = nil
        end
    end
    self.statusimg.gameObject:SetActive(false)
    self.breakslab.gameObject:SetActive(false)
    self.ItemImg.gameObject:SetActive(false)
    self.Double.gameObject:SetActive(false)
    self.animalBubble:SetActive(false)
end

function TreasureMazeBlock:SetDefault()
    self.slabImg.color = Color(0.5, 0.5, 0.5, 1)
    self:HideAll()
end

function TreasureMazeBlock:DealPiece(num)
    if num == nil then
        return
    end
    self.statusimg.gameObject:SetActive(false)
    if self.guideeffect == nil then
        self.guideeffect = GameObject.Instantiate(self.parent:GetPrefab(self.parent.guideEffect))
        Utils.ChangeLayersRecursively(self.guideeffect.transform, "UI")
        self.guideeffect.transform:SetParent(self.transform)
        self.guideeffect.transform.localScale = Vector3(1, 1, 1)
        self.guideeffect.transform.localPosition = Vector3(40, -24, -250)
    end
end

function TreasureMazeBlock:DealEvent(data)
    for k, event in pairs(data) do
        if event.e_flag == 0 then
            if event.e_type == 2 and event.e_id == 12 then
                -- if (self.blockstatus == MazeBlockStatus.untouchable or self.blockstatus == MazeBlockStatus.touchable or self.blockstatus == MazeBlockStatus.slabbreak) then
                    self.parent:PlayMonkey(self.x, self.y)
                -- else
                --     self.parent:HideMonkey()
                -- end
                if self.parent.firstInit then
                    local temp = event
                    temp.isfirst = self.parent.firstInit
                    self.model:OpenEventPanel(temp)
                end
            elseif event.e_type == 2 and event.e_id == 2 then
                if self.blockstatus == MazeBlockStatus.untouchable or self.blockstatus == MazeBlockStatus.touchable then
                    if BaseUtils.isnull(self.hoteffect) then
                        self.hoteffect = GameObject.Instantiate(self.parent:GetPrefab(self.parent.hotEffect))
                        Utils.ChangeLayersRecursively(self.hoteffect.transform, "UI")
                        self.hoteffect.transform:SetParent(self.transform)
                        self.hoteffect.transform.localScale = Vector3(1, 1, 1)
                        self.hoteffect.transform.localPosition = Vector3(38, -22, -250)
                    end
                end
            elseif event.e_type == 2 and event.e_id == 9 then
                self.blockstatus = MazeBlockStatus.helpanimal
                self:ChangeHelpAnimal()
            end
        else
            if event.e_type == 2 and event.e_id == 12 then
                self.parent:HideMonkey()
            end
        end
    end
end

function TreasureMazeBlock:CheckMonkey()
    local data = nil
    for i=-1,1 do
        for j=-1,1 do
            if math.abs(i) ~= math.abs(j) then
                data = self.model:GetData(self.x+i, self.y+j)
                if data ~= nil and next(data) == nil then
                    return true
                end
            end
        end
    end
    return false
end

function TreasureMazeBlock:CheckHelp()
    -- local data = nil
    -- for i= -1, 1 do
    --     for j= -1, 1 do
    --         if i ~= 0 or j ~= 0 then
    --             data = self.model:GetData(self.x+i, self.y+j)
    --             if data ~= nil and next(data) == nil then
    --                 return false
    --             elseif data ~= nil then
    --                 if not (data.flag == 3 or data.times == data.hard) then
    --                     return false
    --                 end
    --             end
    --             -- if data ~= nil and next(data) == nil then
    --             --     return false
    --             -- elseif data ~= nil and data.hard ~= data.times and data.type ~= 3 then
    --             --     return false
    --             -- end
    --         end
    --     end
    -- end
    return self.parent:CheckAll(self.x, self.y)
end

function TreasureMazeBlock:SetGetItem(go, iconid)
    local id = go:GetInstanceID()
    if self.iconloader[id] == nil then
        self.iconloader[id] = SingleIconLoader.New(go)
    end
    self.iconloader[id]:SetSprite(SingleIconType.Item, iconid)
end