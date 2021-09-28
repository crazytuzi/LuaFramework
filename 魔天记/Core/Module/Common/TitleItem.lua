require "Core.Module.Common.UIItem"
local qulityColor =
{
    [1] = { ["bc"] = Color.New(49 / 255, 228 / 255, 36 / 255), ["tc"] = Color.New(233 / 255, 1, 215 / 255), ["ec"] = Color.New(36 / 255, 130 / 255, 53 / 255) },
    [2] = { ["bc"] = Color.New(44 / 255, 133 / 255, 1), ["tc"] = Color.New(228 / 255, 249 / 255, 1), ["ec"] = Color.New(16 / 255, 41 / 255, 210 / 255) },
    [3] = { ["bc"] = Color.New(137 / 255, 59 / 255, 1), ["tc"] = Color.New(237 / 255, 228 / 255, 1), ["ec"] = Color.New(113 / 255, 23 / 255, 155 / 255) },
    [4] = { ["bc"] = Color.New(239 / 255, 246 / 255, 38 / 255), ["tc"] = Color.New(254 / 255, 1, 228 / 255), ["ec"] = Color.New(157 / 255, 128 / 255, 13 / 255) },
    [5] = { ["bc"] = Color.New(1, 172 / 255, 28 / 255), ["tc"] = Color.New(1, 249 / 255, 228 / 255), ["ec"] = Color.New(191 / 255, 112 / 255, 0) },
}
TitleItem = UIItem:New();
function TitleItem:_Init()
    self.width = 0;
    self.height = 0;
    self._parent1 = UIUtil.GetChildByName(self.transform, "bg1")
    self._parent2 = UIUtil.GetChildByName(self.transform, "bg2")
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "bg1/titleName")
    self._img1 = UIUtil.GetChildByName(self.transform, "UISprite", "bg1/sp1")
    self._img2 = UIUtil.GetChildByName(self.transform, "UISprite", "bg1/sp2")
    self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "bg2/titleIcon")

    self:UpdateItem(self.data);
end

function TitleItem:_Dispose()
    self._parent1.gameObject:SetActive(false)
    self._parent2.gameObject:SetActive(false)
end  

function TitleItem:UpdateItem(data)
    self.data = data
    if self.data then
        if (self.data.show_type == 1) then
            self._parent1.gameObject:SetActive(true)
            self._parent2.gameObject:SetActive(false)
            self._img1.spriteName = tostring(self.data.quality)
            self._img2.spriteName = tostring(self.data.quality)
            self._txtName.text = self.data.name
            self._txtName.effectColor = qulityColor[self.data.quality].ec
            self._txtName.gradientTop = qulityColor[self.data.quality].tc
            self._txtName.gradientBottom = qulityColor[self.data.quality].bc
            self.width = self._img2.transform.localPosition.x - self._img1.transform.localPosition.x
            self.height = self._img2.height
        else
            self._parent1.gameObject:SetActive(false)
            self._parent2.gameObject:SetActive(true)
            self._imgIcon.spriteName = self.data.icon
            self._txtName.text = ""
            self.width = self._imgIcon.width
            self.height = self._imgIcon.height * 0.6
        end
    else
        self._parent1.gameObject:SetActive(false)
        self._parent2.gameObject:SetActive(false)
        self.width = 0
        self.height = 0
    end
end
 