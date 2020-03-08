Activity.Winter = Activity.Winter or {}
local Winter = Activity.Winter
Winter.nTangYuanItemId = 3525
Winter.nJiaoZiItemId = 3524
Winter.nGatherFirstJoinActive = 20 			-- 参加
Winter.nGatherAnswerRightActive = 20 		-- 答对
Winter.nGatherAnswerWrongActive = 20 		-- 答错
Winter.nLimitLevel = 20 					-- 邮件发送等级
Winter.nTangYuanValidTime = 24*60*60 		-- 汤圆过期时间
Winter.nJiaoZiValidTime = 24*60*60 	        -- 饺子过期时间
Winter.nSendJiaoZiCount = 1 				-- 赠送饺子数量

function Winter:GetTangYuanItemId()
	return Winter.nTangYuanItemId
end

function Winter:GetJiaoZiItemId()
	return Winter.nJiaoZiItemId
end