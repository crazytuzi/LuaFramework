-- @author hze
-- @date 2018/06/07
--龙凤棋结算

DragonChessSettlePanel = DragonChessSettlePanel or BaseClass(BaseWindow)
function DragonChessSettlePanel:__init(model)
    self.model = model
    self.winEffect = "prefabs/effect/20366.unity3d"
    self.lossEffect = "prefabs/effect/20367.unity3d"
    self.pingEffect = "prefabs/effect/20405.unity3d"
    self.resList = {
        {file = AssetConfig.animalchesssettle, type = AssetType.Main},
        {file = AssetConfig.animal_chess_textures, type = AssetType.Dep},
        {file = self.winEffect, type = AssetType.Main},
        {file = self.lossEffect, type = AssetType.Main},
        {file = self.pingEffect, type = AssetType.Main},
    }
    self.showstr = {
        [1] = TI18N("你精湛的棋技，完美的发挥赢得了胜利"),
        [2] = TI18N("胜负乃兵家常事，请大侠再战一局"),
        [3] = TI18N("棋逢对手，激战良久，不分胜负"),
    }
    self.NewObjList = {}
    self.hasInit = false
end

function DragonChessSettlePanel:__delete()
    self.transform = nil
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId.id)
        self.tweenId = nil
    end
    if self.tweenId1 ~= nil then
        Tween.Instance:Cancel(self.tweenId1.id)
        self.tweenId1 = nil
    end
    if self.tweenId2 ~= nil then
        Tween.Instance:Cancel(self.tweenId2.id)
        self.tweenId2 = nil
    end
    if self.tweenId3 ~= nil then
        Tween.Instance:Cancel(self.tweenId3.id)
        self.tweenId3 = nil
    end
    if self.tweenId4 ~= nil then
        Tween.Instance:Cancel(self.tweenId4.id)
        self.tweenId4 = nil
    end
    if self.tweenId5 ~= nil then
        Tween.Instance:Cancel(self.tweenId5.id)
        self.tweenId5 = nil
    end

    DragonPhoenixChessManager.Instance.model:CloseMain()

    for k,v in pairs(self.NewObjList) do
        v:DeleteMe()
    end
    self.NewObjList = nil
    self:AssetClearAll()
end

function DragonChessSettlePanel:OnHide()
end

function DragonChessSettlePanel:OnOpen()

end

function DragonChessSettlePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.animalchesssettle))
    self.gameObject.name = "DragonChessSettlePanel"

    -- self.transform:SetParent(self.parent.main.transform)
    -- self.transform.localScale = Vector3.one
    -- self.transform.localPosition = Vector.zero
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.Panel = self.transform:Find("Panel")

    self.Main = self.transform:Find("Main")
    self.Effect = self.transform:Find("Main/Effect")
    self.Reward = self.transform:Find("Main/Reward")

    self.Exp1 = self.transform:Find("Main/Exp1"):GetComponent(Text)
    self.Exp1EXT = MsgItemExt.New(self.Exp1, 100, 20, 24)
    table.insert(self.NewObjList, self.Exp1EXT)
    self.Exp2 = self.transform:Find("Main/Exp2"):GetComponent(Text)
    self.Exp2EXT = MsgItemExt.New(self.Exp2, 100, 20, 24)
    table.insert(self.NewObjList, self.Exp2EXT)
    self.GradeText = self.transform:Find("Main/Text"):GetComponent(Text)
    self.Slider = self.transform:Find("Main/Slider"):GetComponent(Slider)
    self.Background = self.transform:Find("Main/Slider/Background")
    -- self.fillArea = self.transform:Find("Main/Slider/Fill Area")
    self.Fill = self.transform:Find("Main/Slider/Fill Area/Fill")
    self.currText = self.transform:Find("Main/Slider"):GetChild(2):GetComponent(Text)
    self.currText2 = self.transform:Find("Main/Slider"):GetChild(3):GetComponent(Text)
    self.Diff = self.transform:Find("Main/Diff"):GetComponent(Image)
    self.DiffText = self.transform:Find("Main/Diff/Text"):GetComponent(Text)
    self.Button = self.transform:Find("Main/Button"):GetComponent(Button)
    self.Button.onClick:AddListener(function()
        self.model:CloseSettlePanel()
    end)
    self.Text = self.transform:Find("Main/Button/Text"):GetComponent(Text)
    self.DescText = self.transform:Find("Main/DescText"):GetComponent(Text)
    -- self.effecttween = Tween.Instance:RotateZ(self.Effect.gameObject, -720, 30, function() end):setLoopClamp()
    self.data = self.openArgs
    -- BaseUtils.dump(self.openArgs, "界面数据")
    self.winObj = GameObject.Instantiate(self:GetPrefab(self.winEffect))
    self.winObj.transform:SetParent(self.Effect)
    self.winObj.transform.localScale = Vector3(1, 1, 1)
    self.winObj.transform.localPosition = Vector3(0,0,-200)
    Utils.ChangeLayersRecursively(self.winObj.transform, "UI")
    self.winObj:SetActive(false)

    self.lossObj = GameObject.Instantiate(self:GetPrefab(self.lossEffect))
    self.lossObj.transform:SetParent(self.Effect)
    self.lossObj.transform.localScale = Vector3(1, 1, 1)
    self.lossObj.transform.localPosition = Vector3(0,0,-200)
    Utils.ChangeLayersRecursively(self.lossObj.transform, "UI")
    self.lossObj:SetActive(false)

    self.pingObj = GameObject.Instantiate(self:GetPrefab(self.pingEffect))
    self.pingObj.transform:SetParent(self.Effect)
    self.pingObj.transform.localScale = Vector3(1, 1, 1)
    self.pingObj.transform.localPosition = Vector3(0,0,-200)
    Utils.ChangeLayersRecursively(self.pingObj.transform, "UI")
    self.pingObj:SetActive(false)

    if self.data ~= nil then
        if self.data.flag == 1 then
            self.winObj:SetActive(true)
        elseif self.data.flag == 2 then
            self.lossObj:SetActive(true)
        elseif self.data.flag == 3 then
            self.pingObj:SetActive(true)
        end
        self.DescText.text = self.showstr[self.data.flag]
        local oldData = self.data.olddata
        if self.data.flag == 1 or self.data.flag == 3 then
            self.Diff.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow2")
            if oldData.lev == self.data.grade then
                self.DiffText.text = tostring(self.data.score - oldData.score)
            else
                local realscore = DataCampBlackWhiteChess.data_grade[oldData.lev].next_grade - oldData.score + self.data.score
                self.DiffText.text =  tostring(realscore)
            end
        else
            self.Diff.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow1")
            if oldData.lev == self.data.grade then
                self.DiffText.text = string.format("<color=#ff0000>%s</color>" ,self.data.score - oldData.score)
            else
                local realscore = DataCampBlackWhiteChess.data_grade[self.data.grade].next_grade - self.data.score - oldData.score
                self.DiffText.text =  string.format("<color=#ff0000>%s</color>" ,realscore)
            end
        end
        self.GradeText.text = self:GetGradeName(oldData.lev)
        local otherreward = {}
        self.Exp1EXT.contentTrans.gameObject:SetActive(false)
        self.Exp2EXT.contentTrans.gameObject:SetActive(false)
        for k,v in pairs(self.data.reward) do
            if v.base_id == 90010 then
                self.Exp1EXT.contentTrans.gameObject:SetActive(true)
                self.Exp1EXT:SetData(string.format("{assets_2, 90010}%s",v.num))
            elseif v.base_id == 90005 then
                self.Exp2EXT.contentTrans.gameObject:SetActive(true)
                self.Exp2EXT:SetData(string.format("{assets_2, 90005}%s",v.num))
            else
                table.insert(otherreward, v)
            end
        end
        local rewardnum = #otherreward
        for i,v in ipairs(otherreward) do
            local slot = self:CreatSlot(v)
            slot.transform.anchoredPosition3D = Vector3(-40*rewardnum+40+(i-1)*80, 0, 0)
        end
        self:DoAnimation()
    end
end

function DragonChessSettlePanel:DoAnimation()
    local oldData = self.data.olddata
    if self.data.grade == oldData.lev then
        self.currText.text = string.format("%s/%s", tostring(oldData.score), tostring(DataCampBlackWhiteChess.data_grade[oldData.lev].next_grade))
        self.currText2.text = string.format("%s/%s", tostring(oldData.score), tostring(DataCampBlackWhiteChess.data_grade[oldData.lev].next_grade))

        local maxscore = DataCampBlackWhiteChess.data_grade[oldData.lev].next_grade
        local beginval = oldData.score
        local endval = self.data.score

        self.tweenId = Tween.Instance:ValueChange(beginval, endval, 1.87, function() self.tweenId = nil end, LeanTweenType.linear, function(value)
            self.Slider.value = value/maxscore
            local fullval = maxscore
            self.currText.text = string.format("%s/%s", tostring(value - value%1), tostring(fullval))
            self.currText2.text = string.format("%s/%s", tostring(value - value%1), tostring(fullval))
        end)
    else
        if self.data.grade > oldData.lev then
            self.currText.text = string.format("%s/%s", tostring(oldData.score), tostring(DataCampBlackWhiteChess.data_grade[oldData.lev].next_grade))
            self.currText2.text = string.format("%s/%s", tostring(oldData.score), tostring(DataCampBlackWhiteChess.data_grade[oldData.lev].next_grade))
            local currmaxscore = DataCampBlackWhiteChess.data_grade[oldData.lev].next_grade
            local newmaxscore = DataCampBlackWhiteChess.data_grade[self.data.grade].next_grade
            local beginval = oldData.score

            local tween1 = function()
                if self.transform == nil then
                    return
                end
                local gradename = self:GetGradeName(self.data.grade)
                local targetval = self.data.score
                self.GradeText.gameObject.transform.localScale = Vector3(0.6, 0.6, 0.6)
                self.tweenId1 = Tween.Instance:Scale(self.GradeText.gameObject.transform, Vector3(1,1,1), 0.6, function() end, LeanTweenType.easeOutElastic)
                self.GradeText.text = gradename

                self.tweenId2 = Tween.Instance:ValueChange(0, targetval, 1.87, function() end, LeanTweenType.linear, function(value)
                    self.Slider.value = value/newmaxscore
                    local fullval = newmaxscore
                    self.currText.text = string.format("%s/%s", tostring(value - value%1), tostring(fullval))
                    self.currText2.text = string.format("%s/%s", tostring(value - value%1), tostring(fullval))
                end)
            end

            self.tweenId3 = Tween.Instance:ValueChange(beginval, currmaxscore, 1.87, tween1, LeanTweenType.linear, function(value)
                self.Slider.value = value / currmaxscore
                local fullval = currmaxscore
                self.currText.text = string.format("%s/%s", tostring(value - value%1), tostring(fullval))
                self.currText2.text = string.format("%s/%s", tostring(value - value%1), tostring(fullval))
            end)
        else
            self.currText.text = tostring(oldData.score)
            -- self.maxText.text = DataCampBlackWhiteChess.data_grade[oldData.lev].next_grade
            local currmaxscore = DataCampBlackWhiteChess.data_grade[oldData.lev].next_grade
            local newmaxscore = DataCampBlackWhiteChess.data_grade[self.data.grade].next_grade
            local beginval = oldData.score/currmaxscore

            local tween1 = function()
                if self.transform == nil then
                    return
                end
                local gradename = self:GetGradeName(self.data.grade)
                local targetval = self.data.score/newmaxscore
                self.tweenId4 = Tween.Instance:ValueChange(1, targetval, 1.87, function()if self.transform == nil then return end self.GradeText.text = gradename end, LeanTweenType.linear, function(value)
                    self.Slider.value = value
                end)
            end

            self.tweenId5 = Tween.Instance:ValueChange(beginval, 0, 1.87, tween1, LeanTweenType.linear, function(value)
                self.Slider.value = value
            end)
        end
    end
end

function DragonChessSettlePanel:GetGradeName(grade)
    return DataCampBlackWhiteChess.data_grade[grade].name
end

function DragonChessSettlePanel:CreatSlot(data)
    local slot = ItemSlot.New()
    local info = ItemData.New()
    table.insert(self.NewObjList, slot)
    table.insert(self.NewObjList, info)
    local base = DataItem.data_get[data.base_id]
    info:SetBase(base)
    info.quantity = data.num
    local extra = {inbag = false, nobutton = true}
    slot:SetAll(info, extra)
    slot.transform:SetParent(self.Reward)
    slot.transform.localScale = Vector3.one
    return slot
end
