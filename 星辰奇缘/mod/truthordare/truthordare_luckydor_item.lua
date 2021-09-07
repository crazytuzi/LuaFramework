-- 单项幸运儿
-- pwj
TruthordareLuckydorItem = TruthordareLuckydorItem or BaseClass()

function TruthordareLuckydorItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.data = nil

    self.parent = parent
    self.model = self.parent.model

    self.transform = self.gameObject.transform
		self.descText = self.transform:Find("bg/DescText"):GetComponent(Text)
		self.questType = self.transform:Find("DescText2"):GetComponent(Text)
		self.ansAndQuest = self.transform:Find("LookAnsButton")
		self.ansAndQuestText = self.ansAndQuest:Find("Text"):GetComponent(Text)
		--self.ansAndQuestBtn = self.ansAndQuest:GetComponent(Button)
		--self.ansAndQuestBtn.onClick:AddListener(function() self:ChangeDesc() end)
		self.flowerNum = self.transform:Find("FlowerNum/DescText"):GetComponent(Text)
		self.eggNum = self.transform:Find("EggNum/DescText"):GetComponent(Text)
			self.role = self.transform:Find("Role")
		self.roleSex = self.role:Find("Sex"):GetComponent(Image)
		self.nameText = self.role:Find("NameText"):GetComponent(Text)
		self.RoleImage = self.role:Find("RoleImage"):GetComponent(Image)
end

--设置
function TruthordareLuckydorItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function TruthordareLuckydorItem:Release()
end

--更新内容
function TruthordareLuckydorItem:update_my_self(data, _index)
		self.data = data
		self.descText.text = data.desc1
		if data.type == 0 then
			self.questType.text = TI18N("真心话")
		elseif data.type == 1 then
			self.questType.text = TI18N("大冒险")
		end

		self.flowerNum.text = string.format(TI18N("鲜花数: %d"),data.flower)
		self.eggNum.text = string.format(TI18N("鸡蛋数: %d"),data.egg)
		self.roleSex.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "IconSex"..data.sex)
		self.nameText.text = data.role_name
		self.RoleImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex)
		--取头像，待优化
end
