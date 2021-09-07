-- 单项成就
-- ljh 20160620
AchievementMemberItem = AchievementMemberItem or BaseClass()

function AchievementMemberItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.data = nil

    self.parent = parent
    self.model = self.parent.model

    self.transform = self.gameObject.transform

    self.nametext = self.gameObject.transform:FindChild("NameText"):GetComponent(Text)
	self.desctext = self.gameObject.transform:FindChild("DescText"):GetComponent(Text)
	self.timetext = self.gameObject.transform:FindChild("TimeText"):GetComponent(Text)
	self.staritem_desctext = self.gameObject.transform:FindChild("StarItem/DescText"):GetComponent(Text)
	self.star1 = self.gameObject.transform:FindChild("StarPanel/Star1/Image").gameObject
	self.star2 = self.gameObject.transform:FindChild("StarPanel/Star2/Image").gameObject
	self.star3 = self.gameObject.transform:FindChild("StarPanel/Star3/Image").gameObject
	self.reward = self.gameObject.transform:FindChild("Reward").gameObject
	self.gife = self.gameObject.transform:FindChild("gife").gameObject
	self.rewardtext = self.gameObject.transform:FindChild("Reward/RewardText"):GetComponent(Text)
	self.progress = self.gameObject.transform:FindChild("Progress").gameObject
	self.progress_recttransform = self.gameObject.transform:FindChild("Progress"):GetComponent(RectTransform)
	self.progress_numtext = self.gameObject.transform:FindChild("Progress/NumText"):GetComponent(Text)
	self.progress_slider = self.gameObject.transform:FindChild("Progress/Slider"):GetComponent(Slider)
	self.tag = self.gameObject.transform:FindChild("Tag").gameObject
	self.redpoint = self.gameObject.transform:FindChild("RedPoint").gameObject
	self.select = self.gameObject.transform:FindChild("Select").gameObject
	self.percentText = self.gameObject.transform:FindChild("PercentText"):GetComponent(Text)
	self.toggle = self.gameObject.transform:FindChild("Toggle"):GetComponent(Toggle)
	self.getRewardButton = self.gameObject.transform:FindChild("GetRewardButton").gameObject
	self.descButton = self.gameObject.transform:FindChild("DescButton").gameObject

    local btn = nil
    btn = self.gameObject:GetComponent(Button)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function() self.parent:CellClick(self.gameObject) end)

	btn = self.gameObject.transform:FindChild("ShareButton"):GetComponent(Button)
	btn.onClick:RemoveAllListeners()
	btn.onClick:AddListener(function() self.parent:ShareButtonClick(self.gameObject) end)

	btn = self.gameObject.transform:FindChild("StarPanel"):GetComponent(Button)
	btn.onClick:RemoveAllListeners()
	btn.onClick:AddListener(function() self.parent:StarPanelClick(self.gameObject) end)

	btn = self.gameObject.transform:FindChild("Reward/RewardText"):GetComponent(Button)
	btn.onClick:RemoveAllListeners()
	btn.onClick:AddListener(function() self.parent:RewardClick(self.gameObject) end)

    btn = self.gameObject.transform:FindChild("StarItem"):GetComponent(Button)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function() self.parent:StarItemClick(self.gameObject) end)

    btn = self.getRewardButton:GetComponent(Button)
    btn.onClick:RemoveAllListeners()
	btn.onClick:AddListener(function() self.parent:CellClick(self.gameObject) end)
	
	btn = self.descButton:GetComponent(Button)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function() self.parent:DetailsClick(self.gameObject) end)

    self.toggle.onValueChanged:AddListener(function(on) self.parent:ontogglechange(self.gameObject, on) end)
end

--设置
function AchievementMemberItem:SetActive(boo)
    self.gameObject:SetActive(boo)
end

function AchievementMemberItem:Release()
end

function AchievementMemberItem:InitPanel(_data)
    self:update_my_self(_data)
end

--更新内容
function AchievementMemberItem:update_my_self(_data, _index)
	local data = _data
	self.gameObject.name = tostring(data.id)

	self.nametext.text = data.name
	self.desctext.text = data.desc
	local timeText = TI18N("未达成")
	if data.finish_time ~= 0 then
		local year = os.date("%y", data.finish_time)
		local month = os.date("%m", data.finish_time)
		local day = os.date("%d", data.finish_time)
		timeText = string.format("%s/%s/%s", year, month, day)
	end
	self.timetext.text = timeText
	self.staritem_desctext.text = data.ach_num

	local completeNumberData = self.model.achievementCompleteNumber[data.id]
	if completeNumberData ~= nil then
	    local num = math.floor(completeNumberData.finish / self.model.achievementCompleteTotalNumber * 100)
	    if num == 0 and completeNumberData.finish > 0 then num = 1 end

	    self.percentText.text = string.format("%s%%", num)
	end

	local attention = self.model.attentionList[data.id]
	self.parent.offtogglechange = true
	if attention then
		self.toggle.isOn = true
		self.toggle.gameObject:SetActive(true)
	else
		self.toggle.isOn = false
		if self.parent.selectId ~= tonumber(self.gameObject.name) then
			self.toggle.gameObject:SetActive(false)
		end
	end
	self.parent.offtogglechange = false

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

	if self.model:getHasRewardById(data.id) then
		self.reward:SetActive(true)
		self.gife:SetActive(true)

		if data.honor ~= 0 then
			local honorData = DataHonor.data_get_honor_list[data.honor]
			if honorData == nil then
				self.rewardtext.text = ""
			else
				self.rewardtext.text = string.format(TI18N("称号<color='#225ee7'>[%s]</color>"), honorData.name)
			end
        elseif DataAchievement.data_attr[data.id] ~= nil then
            local attr = DataAchievement.data_attr[data.id].attr
            local attrText = ""
            for i, v in ipairs(attr) do
                attrText = string.format("%s %s", attrText, KvData.GetAttrString(v.key, v.val))
            end
            self.rewardtext.text = attrText
		elseif #data.rewards_commit > 0 then
			local rewardData = data.rewards_commit[1]
			local itemBaseData = BackpackManager:GetItemBase(rewardData[1])
			if rewardData[3] > 0 then
				self.rewardtext.text = string.format("%s×%s", ColorHelper.color_item_name(itemBaseData.quality , string.format("[%s]", itemBaseData.name)), rewardData[3])
			else
				self.rewardtext.text = ColorHelper.color_item_name(itemBaseData.quality , string.format("[%s]", itemBaseData.name))
			end

            -- local progress = self.model:getProgress(data.progress)
            -- if progress ~= nil then
            --     local progressString = string.format("<color='#ffff00'>%s</color>/%s", progress.value, progress.target_val)
            --     self.gameObject.transform:FindChild("DescText"):GetComponent(Text).text = string.format("%s<color='#ffffff'>(%s)</color>", data.desc, progressString)
            -- else
            --     self.gameObject.transform:FindChild("DescText"):GetComponent(Text).text = string.format("%s", data.desc)
            -- end
		end
	elseif data.finish == 0 then
		self.reward:SetActive(false)
		self.progress:SetActive(true)
        self.progress_recttransform.anchoredPosition = Vector2(-15, -30)
		self.gife:SetActive(false)
		if data.show_details == 0 then
			self.descButton:SetActive(false)
		else
			self.descButton:SetActive(true)
		end

		local progress = self.model:getProgress(data.progress)
		self.progress_numtext.text = string.format("%s/%s", progress.value, progress.target_val)
		self.progress_slider.value = progress.value / progress.target_val
	else
		self.reward:SetActive(false)
		self.progress:SetActive(false)
		self.gife:SetActive(false)
		self.descButton:SetActive(false)
	end

	if data.finish == 0 then
	    self.progress:SetActive(true)
		self.progress_recttransform.anchoredPosition = Vector2(-15, -41.5)
		if data.show_details == 0 then
			self.descButton:SetActive(false)
		else
			self.descButton:SetActive(true)
		end

	    local progress = self.model:getProgress(data.progress)
	    self.progress_numtext.text = string.format("%s/%s", progress.value, progress.target_val)
	    self.progress_slider.value = progress.value / progress.target_val
	else
		self.progress:SetActive(false)
		self.descButton:SetActive(false)
	end


	self.tag:SetActive(data.finish == 1 or data.finish == 2)
    self.redpoint:SetActive(data.finish == 1 and self.model:getHasRewardById(data.id))
    self.select:SetActive(self.parent.selectId == tonumber(self.gameObject.name))
    self.getRewardButton:SetActive(data.finish == 1 and self.model:getHasRewardById(data.id))
end

function AchievementMemberItem:Refresh(args)
    
end
