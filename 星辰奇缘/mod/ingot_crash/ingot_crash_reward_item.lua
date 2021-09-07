IngotCrashRewardItem = IngotCrashRewardItem or BaseClass()

function IngotCrashRewardItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    self.bgImage = gameObject:GetComponent(Image)
    self.transform = gameObject.transform
    self.nameText = self.transform:Find("State"):GetComponent(Text)
    --self.singleExt = MsgItemExt.New(self.transform:Find("Single/Text"):GetComponent(Text), 200, 17, 19.6843)
    --self.totalExt = MsgItemExt.New(self.transform:Find("Total/Text"):GetComponent(Text), 200, 17, 19.6843)

    self.singleText = self.transform:Find("Single/Text"):GetComponent(Text)
    self.singleImage = self.transform:Find("Single/Image"):GetComponent(Image)
    self.totalText = self.transform:Find("Total/Text"):GetComponent(Text)
    self.totalImage = self.transform:Find("Total/Image"):GetComponent(Image)
end

function IngotCrashRewardItem:__delete()
    -- if self.singleExt ~= nil then
    --     self.singleExt:DeleteMe()
    --     self.singleExt = nil
    -- end
    -- if self.totalExt ~= nil then
    --     self.singleExt:DeleteMe()
    --     self.singleExt = nil
    -- end
    if self.singleImage ~= nil then
        BaseUtils.ReleaseImage(self.singleImage)
    end
    if self.totalImage ~= nil then
        BaseUtils.ReleaseImage(self.totalImage)
    end
end

function IngotCrashRewardItem:SetData(data, index)
    self.nameText.text = data.type
    if index == 1 then
        self.singleText.text = string.format("<color='#ffff00'>%s</color>", data.win_reward[1][2])
         self.singleImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..data.win_reward[1][1])

         self.totalText.text = string.format("<color='#ffff00'>%s</color>", data.total_reward[1][2])
         self.totalImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..data.total_reward[1][1])
    else
        self.singleText.text = string.format("%s", data.win_reward[1][2])
         self.singleImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..data.win_reward[1][1])

         self.totalText.text = string.format("%s", data.total_reward[1][2])
         self.totalImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..data.total_reward[1][1])
    end

    --local size = nil
    --local tab1 = {}
    --local tab2 = {}
    -- if index == 1 then
    --     for _,reward in ipairs(data.win_reward) do
    --         table.insert(tab1, string.format("<color='#ffff00'>%s</color>{assets_2,%s}", reward[2], reward[1]))
    --     end
    --     self.singleExt:SetData(table.concat(tab1))

    --     for _,reward in ipairs(data.total_reward) do
    --         table.insert(tab2, string.format("<color='#ffff00'>%s</color>{assets_2,%s}", reward[2], reward[1]))
    --     end
    --     self.totalExt:SetData(table.concat(tab2))
    -- else
    --     for _,reward in ipairs(data.win_reward) do
    --         table.insert(tab1, string.format("%s{assets_2,%s}", reward[2], reward[1]))
    --     end
    --     self.singleExt:SetData(table.concat(tab1))

    --     for _,reward in ipairs(data.total_reward) do
    --         table.insert(tab2, string.format("%s{assets_2,%s}", reward[2], reward[1]))
    --     end
    --     self.totalExt:SetData(table.concat(tab2))
    -- end

    --size = self.singleExt.contentTrans.sizeDelta
    --self.singleExt.contentTrans.anchoredPosition = Vector2(-20 - size.x, size.y / 2)
    --size = self.totalExt.contentTrans.sizeDelta
    --self.totalExt.contentTrans.anchoredPosition = Vector2(-20 - size.x, size.y / 2)
    if index % 2 == 1 then
        self.bgImage.color = ColorHelper.ListItem1
    else
        self.bgImage.color = ColorHelper.ListItem2
    end
end

