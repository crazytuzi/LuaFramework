an.btn21 = function (title, cb)
	local cb = cb or function ()
		return 
	end
	local btn = an.newBtn(res.gettex2("pic/common/btn20.png"), slot2, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			title,
			16,
			0,
			{
				color = def.colors.Cf0c896
			}
		}
	})

	return btn
end
an.btnQuestion = function (cb)
	local cb = cb or function ()
		return 
	end
	local btn = an.newBtn(res.gettex2("pic/common/question.png"), slot1, {
		pressImage = res.gettex2("pic/common/question.png")
	})

	return btn
end

return 
