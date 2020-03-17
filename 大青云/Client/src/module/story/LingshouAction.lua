_G.LingshouAction = {}

function LingshouAction:ExeAction()
	--飞图标
	local showCompleteFunc = function(startPos)
		local flyVO = {};
		flyVO.objName = 'FlyVO'
		flyVO.url = ResUtil:GetFuncIconUrl('f_icontest');
		flyVO.startPos = startPos;
		flyVO.time = 1.5;
		flyVO.endPos = UIMainFunc:GetNewFuncBtnPos(FuncConsts.FaBao,nil,true);
		flyVO.tweenParam = {};
	    flyVO.tweenParam._width = 40;
	    flyVO.tweenParam._height = 40;
		-- flyVO.onComplete = flyCompleteFunc;
		FlyManager:FlyIcon(flyVO);
	end
	--显示面板
	UIFuncOpenLinshouModel:Open(showCompleteFunc);
end


















