
UIActivityBigNumberRewardPreview = {}

local view_award_lv
local luckDigit
local luckRewards

function UIActivityBigNumberRewardPreview.setLuckDigitAndRewards(digit,rewards)
	luckDigit = digit
	luckRewards = rewards
end

function UIActivityBigNumberRewardPreview.init()
	local image_basemap = UIActivityBigNumberRewardPreview.Widget:getChildByName("image_basemap")
	local btn_closed = image_basemap:getChildByName("btn_closed")
	local function onButtonEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			UIManager.popScene()
		end
	end
	btn_closed:addTouchEventListener(onButtonEvent)
	view_award_lv = image_basemap:getChildByName("view_award_lv")
end

function UIActivityBigNumberRewardPreview.setup()
	for i=1,5 do --字典表长度
		local image_base = view_award_lv:getChildByName("image_base_" .. i)
		for j=1,6-i do
			local label = image_base:getChildByName("label_" .. j)
			label:setString(luckDigit)
		end
		local rewards = luckRewards.message[tostring(6-i)].string.rewards
		local rewardArray = utils.stringSplit(rewards, ";")
		for j=1,2 do
			local image_frame_good = image_base:getChildByName("image_frame_good" .. j)
			if rewardArray[j] == nil then
				image_frame_good:setVisible(false)
			else
				image_frame_good:setVisible(true)
				local itemProps = utils.getItemProp(rewardArray[j])
				local image_good = image_frame_good:getChildByName("image_good")
				local text_number = image_good:getChildByName("text_number")
				local image_sui = image_good:getChildByName("image_sui")
				local image_di_name = image_frame_good:getChildByName("image_di_name")
				local text_name = image_di_name:getChildByName("text_name")
				image_good:loadTexture(itemProps.smallIcon)
				text_number:setString("x" .. itemProps.count)
				if itemProps.flagIcon then
					image_sui:loadTexture(itemProps.flagIcon)
					image_sui:setVisible(true)
				else
					image_sui:setVisible(false)
				end
				text_name:setString(itemProps.name)
			end
		end
	end
end

function UIActivityBigNumberRewardPreview.free()
end
