-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
-- endregion
ConstellationHonorItem = ConstellationHonorItem or BaseClass()

function ConstellationHonorItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.data = nil
    self.parent = parent
    self.transform = self.gameObject.transform

    self.nametext = self.gameObject.transform:FindChild("NameText"):GetComponent(Text)
	self.desctext = self.gameObject.transform:FindChild("DescText"):GetComponent(Text)
	self.staritem_desctext = self.gameObject.transform:FindChild("StarItem/DescText"):GetComponent(Text)

	self.star1 = self.gameObject.transform:FindChild("StarPanel/Star1/Image").gameObject
	self.star2 = self.gameObject.transform:FindChild("StarPanel/Star2/Image").gameObject
	self.star3 = self.gameObject.transform:FindChild("StarPanel/Star3/Image").gameObject
	self.percentText = self.gameObject.transform:FindChild("PercentText"):GetComponent(Text)

end
function ConstellationHonorItem:SetActive(boo)
    self.gameObject:SetActive(boo)
end

function ConstellationHonorItem:InitPanel(_data)
    self:update_my_self(_data)
end

--更新内容
function ConstellationHonorItem:update_my_self(_data, _index)
	local data = _data
	self.gameObject.name = tostring(data.id)
	self.nametext.text = data.name
	self.desctext.text = data.desc
	self.staritem_desctext.text = data.ach_num

	local completeNumberData = AchievementManager.Instance.model.achievementCompleteNumber[data.id]
	if completeNumberData ~= nil then
	    local num = math.floor(completeNumberData.finish / AchievementManager.Instance.model.achievementCompleteTotalNumber * 100)
	    if num == 0 and completeNumberData.finish > 0 then 
            num = 1
        end
	    self.percentText.text = string.format("%s%%", num)
	end

	local star = data.star
	if data.finish ~= 1 and data.finish ~= 2 then
		star = star - 1
	end
	if star == 10 then star = 3 end -- 填10星的显示为3星
	if star == 9 then star = 0 end -- 填10星且未完成的显示为0星
	if star == 0 then
		self.star1:SetActive(false)
		self.star2:SetActive(false)
		self.star3:SetActive(false)
	elseif star == 1 then
		self.star1:SetActive(true)
		self.star2:SetActive(false)
		self.star3:SetActive(false)
	elseif star == 2 then
		self.star1:SetActive(true)
		self.star2:SetActive(true)
		self.star3:SetActive(false)
	elseif star == 3 then
		self.star1:SetActive(true)
		self.star2:SetActive(true)
		self.star3:SetActive(true)
	end
end