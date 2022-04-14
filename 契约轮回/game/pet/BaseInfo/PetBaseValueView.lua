---
--- Created by R2D2.
--- DateTime: 2019/4/8 11:26
---
---
PetBaseValueView = PetBaseValueView or class("PetBaseValueView",Node)

function PetBaseValueView:ctor()

end

function PetBaseValueView:dctor()
    --self.GradeImage = nil
    self.scoreText = nil
    self.damageText = nil
    self.scoreRect = nil
end

function PetBaseValueView:InitUI(Grade, Score, Damage)
    self.scoreRect = Score
    --self.GradeImage = GetImage(Grade)
    self.scoreText = GetText(Score)
    self.damageText = GetText(Damage)

end

function PetBaseValueView:RefreshView(petData)
    if (petData.IsActive) then
        self:ShowDetail(petData.Data, petData.Config)
    else
        if (petData.Data) then
            self:ShowDetail(petData.Data, petData.Config)
        else
            self:ShowSimple(petData.Config)
        end
    end
end

---显示有详细数据的
function PetBaseValueView:ShowDetail(petData, petConfig)
    local grade = self:GetGrade(petData.score, petConfig.score)
    --lua_resMgr:SetImageTexture(self, self.GradeImage, "pet_image", "Appraise_Txt_" .. grade, true)
    --self.GradeImage.enabled = true
    self.scoreText.text = tostring(petData.score)
    SetSizeDeltaX(self.scoreRect, self.scoreText.preferredWidth)
    self.damageText.text = string.format(ConfigLanguage.Pet.DamageText, petConfig.atk / 100)
end

---显示简单数据的
function PetBaseValueView:ShowSimple(petConfig)
    --self.GradeImage.enabled = false
    self.scoreText.text = "???????"
    self.damageText.text = string.format(ConfigLanguage.Pet.DamageText, petConfig.atk / 100)
end

function PetBaseValueView:GetGrade(score, scoreText)
    local tab = String2Table(scoreText)
    for i, v in ipairs(tab) do
        if (v[1] <= score and v[2] >= score) then
            return i
        end
    end

    return #tab
end