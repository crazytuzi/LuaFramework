-- -----------------------------------
-- 孩子学习的课程元素
-- hosr
-- -----------------------------------
ChildrenStudyItem = ChildrenStudyItem or BaseClass()

function ChildrenStudyItem:__init(gameObject, parent, index)
	self.gameObject = gameObject
	self.parent = parent
	self.index = index
	self.isFinish = false

	self:InitPanel()
end

function ChildrenStudyItem:__delete()
end

function ChildrenStudyItem:InitPanel()
	self.transform = self.gameObject.transform
	self.select = self.transform:Find("Select").gameObject
	self.red = self.transform:Find("NotifyPoint").gameObject
	self.val = self.transform:Find("ratebg/Text"):GetComponent(Text)
	self.finish = self.transform:Find("Finish").gameObject
	self.finish:SetActive(false)

	self.gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickSelf() end)
end

-- 统一传入childdata，各取所需
function ChildrenStudyItem:SetData(data)
	self.data = data
	local ci = ChildrenEumn.PosToIndex[self.index]
	local val = 0
	local max = 100
	self.isFinish = false
	self.finish:SetActive(false)
	local hasplan = self:HasPlan(data)
	if ci == 1 then
		val = data.study_str
		if hasplan then
			max = data.study_str_plan_easy * 2 + data.study_str_plan_hard * 5
			if val ~= 0 and val >= max then
				self.finish:SetActive(true)
				self.isFinish = true
			end
		end
	elseif ci == 2 then
		val = data.study_con
		if hasplan then
			max = data.study_con_plan_easy * 2 + data.study_con_plan_hard * 5
			if val ~= 0 and val >= max then
				self.finish:SetActive(true)
				self.isFinish = true
			end
		end
	elseif ci == 3 then
		val = data.study_agi
		if hasplan then
			max = data.study_agi_plan_easy * 2 + data.study_agi_plan_hard * 5
			if val ~= 0 and val >= max then
				self.finish:SetActive(true)
				self.isFinish = true
			end
		end
	elseif ci == 4 then
		val = data.study_mag
		if hasplan then
			max = data.study_mag_plan_easy * 2 + data.study_mag_plan_hard * 5
			if val ~= 0 and val >= max then
				self.finish:SetActive(true)
				self.isFinish = true
			end
		end
	elseif ci == 5 then
		val = data.study_end
		if hasplan then
			max = data.study_end_plan_easy * 2 + data.study_end_plan_hard * 5
			if val ~= 0 and val >= max then
				self.finish:SetActive(true)
				self.isFinish = true
			end
		end
	end
	self.val.text = string.format("%s/%s", val, max)
end

function ChildrenStudyItem:ClickSelf()
	self:Select(true)
	self.parent:OnTabChange(self.index)
end

function ChildrenStudyItem:Select(bool)
	self.select:SetActive(bool)
end

function ChildrenStudyItem:ShowFinish(bool)
	self.finish:SetActive(bool)
end

function ChildrenStudyItem:HasPlan(data)
	if data == nil then
		return false
	end

	if data.study_end_plan_easy == 0
		and data.study_con_plan_easy == 0
		and data.study_mag_plan_easy == 0
		and data.study_agi_plan_easy == 0
		and data.study_str_plan_easy == 0
		and data.study_end_plan_hard == 0
		and data.study_con_plan_hard == 0
		and data.study_mag_plan_hard == 0
		and data.study_agi_plan_hard == 0
		and data.study_str_plan_hard == 0
	then
		return false
	end
	return true
end
